mtype = {red, green}

mtype sem1 = red, sem2 = red, sem3 = red;    // three semaphores
bool  s0, s1, s2, s3;                        // four presence sensors
byte  countZ0, countZ1, countZ2, countZ3;    // count the vehicles in each zone

proctype Sensors() {
  do
  :: s0 = (countZ0 > 0)
  :: s1 = (countZ1 > 0)
  :: s2 = (countZ2 > 0)
  :: s3 = (countZ3 > 0)
  od;
}

proctype RoadsideUnit() {
  // update sem1, sem2 and sem3 according to s0, s1, s2 and s3
  do
  :: skip;
    if
    :: s0 -> printf("Car at Z0\n"); // car at Z0
    :: s1 -> printf("Car at Z1\n"); // car at Z1
    :: s2 -> printf("Car at Z2\n"); // car at Z2
    :: s3 -> printf("Car at Z3\n"); // car at Z3
    fi;
  od;
}

proctype Vehicles() {
  // non-deterministically move vehicles through zones Z0, Z1, Z2, and Z3
  do
  :: (countZ1 + countZ2 + countZ3) >= 1 -> break; // limit max number of cars
  :: if
    :: true -> countZ1++;
    :: true -> countZ2++;
    :: true -> countZ3++;
    fi;
  od;
}

init {
  run Sensors();
  run RoadsideUnit();
  run Vehicles();
}