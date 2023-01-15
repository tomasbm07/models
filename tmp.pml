/*
Intersection includes Zone 0 (shared) and three directions Z1, Z2, Z3
Respective sensors S0, S1, S2, S3 show if vehicles are in any of the zones
Traffic lights light1, light2, light3 can be red/green
Can't "check" vehicle count, access is only binary using sensors

MODEL IS ONLY CORRECT UNDER WEAK FAIRNESS DUE TO INFINITE LOOPS.
*/

// After 100 "ticks", force the light to continue round robin
#define ROUND_ROBIN_MAX (5)

// Count of directions
#define DIRECTIONS (3)

// Amount of incoming cars
#define INCOMING_CAR_COUNT (5)

// Can't be more than X vehicles in the intersection (Z0)
#define MAX_VEHICLES_INTERSECTION (3)

#define SENSOR_COUNT (4)

// Add vehicles asynchronously (true) or synchronously (false)
// Asynchronous is more realistic, and allows vehicles to enter in the middle
// of the simulation, but is considerably slower as the decision tree
// is much larger.
#define ADD_VEHICLES_ASYNCHRONOUSLY (true)

// three traffic lights
mtype = {red, green}
mtype light1 = red , light2 = red , light3 = red ; 

// four presence sensors
bool sensor0 = false , sensor1 = false , sensor2 = false , sensor3 = false ;

// count the vehicles in each zone
byte countZ0 = 0, countZ1 = 0, countZ2 = 0, countZ3 = 0;

// Directions vehicles are currently coming from
byte current_direction = 1;

// Direction change request event/flag
bool change_request = false;
byte next_direction = 1;  // [1..DIRECTIONS]

// All vehicles were dispatched.
bool dispatch_ended = false;

#define simulation_ended (dispatch_ended && ((countZ0 | countZ1 | countZ2 | countZ3) == 0))

/*********** Sensor Control ***********/
// bitwise sensor (first bit (LSB) == sensor0, second bit == sensor1, ...)
byte bitwise_sensor = 0;
// bitwise flags stating which sensors have been checked since last reset
byte sensors_checked = 0;

inline reset_sensor_check() {
    sensors_checked = 0
}
#define wait_all_sensors (sensors_checked == ((1 << SENSOR_COUNT) - 1))
#define wait_sensor(num) (sensors_checked & (1 << num))
inline set_sensor_checked(num) {
    sensors_checked = sensors_checked | (1 << num);
}

#define get_sensor(num) ((bitwise_sensor & (1 << num)) != 0)

inline set_bitwise_sensor(num, state) {
    bitwise_sensor = ( 
        state -> (bitwise_sensor | 1 << num) : (bitwise_sensor & ~(1 << num)))
}

#define check_light(light) (light == green)

proctype Sensors () {
do
:: atomic{
        sensor0 = ( countZ0 > 0)
        set_bitwise_sensor(0, sensor0)
    };
    set_sensor_checked(0);
    if
    :: simulation_ended -> break;
    :: else -> skip
    fi;
:: atomic {
        sensor1 = ( countZ1 > 0)
        set_bitwise_sensor(1, sensor1)
    };
    set_sensor_checked(1);
    if
    :: simulation_ended -> break;
    :: else -> skip
    fi;
:: atomic {
        sensor2 = ( countZ2 > 0)
        set_bitwise_sensor(2, sensor2)
    };
    set_sensor_checked(2);
    if
    :: simulation_ended -> break;
    :: else -> skip
    fi;
:: atomic {
        sensor3 = (countZ3 > 0)
        set_bitwise_sensor(3, sensor3)
    };
    
    set_sensor_checked(3);
    
    if
    :: simulation_ended -> break;
    :: else -> skip
    fi;
od ;
}



// Check if the lights should switch
// Implements round robin mechanism to avoid starvation
proctype CheckLightSwitch () {
    byte counter = 0;
    // Simple Goto Loop
    start_lightswitch: skip
    counter++;
    if
    :: ((get_sensor(current_direction)) -> (counter >= ROUND_ROBIN_MAX) : true) ->
        counter = 0
        // Wait until there are vehicles in any other direction sensor (except
        // Z0) or the simulation has ended, keep the current direction
        ((bitwise_sensor & (~(( 1 << current_direction) | 1))) || simulation_ended)
        if
        :: (simulation_ended) -> goto lightswitch_loop_end
        :: else -> skip;
        fi;
        // Time to request a direction switch
        next_direction = current_direction;
        byte i;
        // Round robin the directions
        for (i : 1 .. DIRECTIONS - 1) {
            next_direction = (next_direction % DIRECTIONS) + 1
            if
            // We found a direction where the sensor is active
            :: get_sensor(next_direction) -> break
            :: else -> skip
            fi;
        }
        // Request the direction switch
        change_request = true;
        // Wait until the direction was changed or sim ended
        (!change_request || simulation_ended)
    :: else -> skip
    fi;

lightswitch_loop_end: skip
    // Check if the simulation has ended
    if
    :: (!simulation_ended) -> goto start_lightswitch
    :: else -> skip
    fi;
}


proctype RoadsideUnit () {
    // Simple Goto loop
    start_rsu: skip
    if
    :: (change_request) -> skip
        printf("Direction change request: %d -> %d\n", current_direction, next_direction)
        // Turn off the old light
        if
        :: (current_direction == 1) -> light1 = red
        :: (current_direction == 2) -> light2 = red
        :: (current_direction == 3) -> light3 = red
        fi;
        printf("Turned %d to red\n", current_direction)
        reset_sensor_check()
        (wait_sensor(0) || simulation_ended)  // Wait until Z0 is clear or sim ended
        printf("Turned %d to green\n", next_direction)
        // Change the light
        if
        :: (next_direction == 1) -> light1 = green
        :: (next_direction == 2) -> light2 = green
        :: (next_direction == 3) -> light3 = green
        fi;

        // Assert that only one light is on, at a time  // TODO: CHANGE TO AN LTL
        assert((check_light(light1) || check_light(light2) || check_light(light3)) && !(check_light(light1) && check_light(light2) &&  check_light(light3)))

        // Update the current direction
        current_direction = next_direction;
        // Reset the change request
        change_request = false;
        goto start_rsu
    // Check if simulation has ended
    :: (simulation_ended) -> skip
    fi;
}

// Vehicles are moving according to traffic lights
proctype VehicleMovement () {
    // Simple Goto loop
start_movement: skip
    if
    // Intersection is full, vehicle is leaving.
    :: (countZ0 == MAX_VEHICLES_INTERSECTION) ->
        printf("Intersection is full, vehicle leaving intersection\n")
        countZ0--;
    
    // Make sure that reducing a counter and increasing Z0 is atomic
    // otherwise vehicles can disappear :-(
    // Writing the atomic here as I don't wish to repeat it everywhere (DRY)
    :: else -> atomic {
            if
            :: (light1 == green && countZ1) -> 
                printf("Light 1 is green and there are %d cars in Z1\n", countZ1)
                countZ1--
                countZ0++
                printf("Car moved. Z1: %d (-1), Z0: %d (+1)\n", countZ1, countZ0)
            :: (light2 == green && countZ2) ->
                printf("Light 2 is green and there are %d cars in Z2\n", countZ2)
                countZ2--
                countZ0++
                printf("Car moved. Z2: %d (-1), Z0: %d (+1)\n", countZ2, countZ0)
            :: (light3 == green && countZ3) ->
                printf("Light 3 is green and there are %d cars in Z3\n", countZ3)
                countZ3--
                countZ0++
                printf("Car moved. Z3: %d (-1), Z0: %d (+1)\n", countZ3, countZ0)
            :: countZ0 -> countZ0--
                printf("Car left Z0: %d (-1)\n", countZ0)
            :: simulation_ended -> goto vehcile_movement_end;
            fi;
        }
    fi;
    
    goto start_movement

vehcile_movement_end: skip
    printf("\n\n\n\nVehicle Movement Simulation ended.\n")
}

proctype IncomingVehicles () {
    // Vehicles are non-deterministically, asynchronously, entering the zones.
    byte i;
    for (i : 1 .. INCOMING_CAR_COUNT) {
        if
        :: true -> printf("Adding car to Z1\n"); countZ1++;
        :: true -> printf("Adding car to Z2\n"); countZ2++;
        :: true -> printf("Adding car to Z3\n"); countZ3++;
        fi;
    }
    dispatch_ended = true;
}

init {
    // Make sure we can reach the max
    assert(INCOMING_CAR_COUNT>=MAX_VEHICLES_INTERSECTION);

    // Make sure that the code relevant for decreasing Z0 is reachable
    assert(MAX_VEHICLES_INTERSECTION>1)

    // Reduce the decision tree a little, no need for a random initial direction
    if
    :: light1 = green; printf("Starting with traffic light 1 as green.\n");
    // :: light2 = green; printf("Starting with traffic light 2 as green.\n");
    // :: light3 = green; printf("Starting with traffic light 3 as green.\n");
    fi;

    run IncomingVehicles ();
    
    if
    :: ADD_VEHICLES_ASYNCHRONOUSLY -> skip
    // Wait until the vehicles are added (join IncomingVehicles)
    :: else -> (_nr_pr == 1);
    fi;

    run Sensors ();
    run RoadsideUnit ();
    run CheckLightSwitch ();
    run VehicleMovement ();
}