# Report for Assignment #2 - Modeling and verifying a fast road intersection

## Models of Software Systems 2022/23 - Raúl Barbosa

### DEI - FCTUC - MES

### Authors

- Tomás Mendes
- Bar Harel

### Report

To test, we limit the maxium number of vehicles that can exist at one time.

#### 1

Part 1 specifies that there can be multiple cars in the intersection Z0, but they can only be coming from one direction. To achieve this behaviour, we can simply use a mutex to only allow one zone at a time to move cars into the intersection.

Todo this, we created a `short` type variable and some basic functions `sem_wait` to add and `sem_post`to remove items from the semaphore queue. As there is only 1 space in the queue, only one zone can have the mutex lock. The wait function is non_blocking.

#### 2

TODO: Already some formulas. Check if all conditions are corrected

#### 3
