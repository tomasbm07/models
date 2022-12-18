#define CARS 2 // Total number of cars
#define canMove(x) (sem1 == red && sem2 == red && sem3 == red)

mtype = {red, green}

mtype sem1 = red, sem2 = red, sem3 = red;    // three semaphores
bool  s0, s1, s2, s3;                        // four presence sensors
byte  countZ0, countZ1, countZ2, countZ3;    // count the vehicles in each zone

proctype Check(){
  do
  :: assert (countZ0 <= 1 && countZ0 >= 0);
  od;
}

proctype Sensors() {
  do
  :: s0 = (countZ0 > 0)
  :: s1 = (countZ1 > 0)
  :: s2 = (countZ2 > 0)
  :: s3 = (countZ3 > 0)
  od;
}


inline sem_wait(mutex){
  if
  :: (mutex > 0) -> mutex--;
  fi
}

inline sem_post(mutex){
  mutex++;
}

inline updateSem(mutex, sem){
  sem_wait(mutex); 
  if 
    :: canMove() && sem -> sem=green;
  fi
  sem_post(mutex);
}

proctype RoadsideUnit() {
  // update sem1, sem2 and sem3 according to s0, s1, s2 and s3
  short mutex = 1;
  do
    :: s1 -> updateSem(mutex, sem1);
    :: s2 -> updateSem(mutex, sem2);
    :: s3 -> updateSem(mutex, sem3);
  od;
}

proctype Vehicles() {
  // non-deterministically move vehicles through zones Z0, Z1, Z2, and Z3
  do
  :: printf("CountZ0: %d\n", countZ0)
    printf("CountZ1: %d\n", countZ1)
    printf("CountZ2: %d\n", countZ2)
    printf("CountZ3: %d\n", countZ3)
    printf("Sem1: %e\n", sem1)
    printf("Sem2: %e\n", sem2)
    printf("Sem3: %e\n", sem3)
    printf("--------------------\n")
  od;
}

init {
  // Create CARS vehicles
  int i;
  for (i: 1 .. CARS) {
    if
    :: countZ1++;
    :: countZ2++;
    :: countZ3++;
    fi;
  }

  run Check();
  run Sensors();
  run RoadsideUnit();
  run Vehicles();
}