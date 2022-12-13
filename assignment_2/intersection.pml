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
  do
  :: // update sem1, sem2 and sem3 according to s0, s1, s2 and s3
  od;
}

proctype Vehicles() {
  do
  :: // non-deterministically move vehicles through zones Z0, Z1, Z2, and Z3
  od;
}

init {
  run Sensors();
  run RoadsideUnit();
  run Vehicles();
}