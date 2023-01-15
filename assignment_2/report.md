# Report for Assignment #2 - Modeling and verifying a fast road intersection

## Models of Software Systems 2022/23 - Raúl Barbosa

### DEI - FCTUC - MES

### Authors

- Tomás Mendes
- Bar Harel

### Report

Our model consists of an intersection, with 3 traffic lights, and 4 sensors covering 4 zones, out of them 1 is shared. A car can move between the zones only when the respective traffic light is green.

The model creates a few processes - IncomingVehicles, Sensors, RoadSideUnit, CheckLightSwitch and VehicleMovement.

- IncomingVehicles: Adds a predefined amount of cars defined in INCOMING_CAR_COUNT, to random zones, excluding the intersection (shared zone).
- Sensors: Checks if there are any cars in the specific zone.
- RoadSideUnit: Changes the traffic lights based on the ‘next_direction’ variable, defined by CheckLightSwitch.
- CheckLightSwitch: Implements a round robin algorithm to determine which light will be green next.

There is a constant for the max amount of cars that can be in the intersection at any time - MAX_VEHICLES_INTERSECTION

Cars can be added to any zone at any given moment.

The following were properties required from the model:

1. There may never be cars coming from different directions simultaneously in the shared zone Z0.
2. If there is a car in Z1 then sem1 will eventually turn green and likewise for Z2 and Z3.
3. If there are only cars coming in from Z1 then sem1 turns green before any of the other traffic lights turn green again and likewise for Z2 and Z3.

Our model checks the sensors and makes sure only one traffic light is green at a time, ensuring property number 1.

By using a round robin approach, the model makes sure there is no stagnation in any zone even if an infinite amount of cars come from one direction. This ensures the implementation of property number 2.

If there are no other cars coming from a different direction, our round robin mechanism does not change the lights, ensuring property number 3.

All the test were run using the following comand:

```bash
spin -a -DSAFETY tmp.pml && gcc -o pan pan.c && ./pan -a -m4000 -w26 -X
```

Our code has several configuration options, which include the number of vehicles modeled, the amount of vehicles allowed inside the intersection at once, and the allowing of vehicles to come on any moment, dubbed “ADD_VEHICLES_ASYNCHRONOUSLY”, which exists in order to simplify the SPIN decision tree.

Recommended run settings:

INCOMING_CAR_COUNT=3, ADD_VEHICLES_ASYNCHRONOUSLY=True
or
INCOMING_CAR_COUNT=5, ADD_VEHICLES_ASYNCHRONOUSLY=False

Using 5 cars that can enter asynchronously at any time creates a very large decision space, which does not finish verifying even after 10+ hours running on a typical machine. By setting it to False, all of the cars are first loaded, and only then does the model start running.

The LTL’s - Linear temporal logic, where implemented as described in part 2 of the assignment.

Two of the LTLs use the progress label to ensure that there would be no infinite loops during check. Unfortunately, weak fairness does not seem to work across processes, only inside do loops.
