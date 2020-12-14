# TrainTrainer

This is currently a work-in-progress. The existing features are likely to be useful, but there's more to come, including bugfixes.

## Current features

### Train spawner stop

Creates trains out of thin air every 200 ticks after having been placed (i.e. you have to place it again after loading a save). Trains are copied from any normal stop called "TT_SOURCE" - you should have only one. The train schedule is copied as well, so you should place a train at "TT_SOURCE", put it in manual mode, and then change its schedule to what you want it to be once it's cloned (the train will go to the first station in the list after having been copied).

## Planned features

### Train spawner stop

Creates trains out of thin air. You can customize which stations they're copied from (if there are multiple stops with the same name, they're chosen from randomly), as well as the spawning frequency. The circuit network can be used to clone a train at any given time.

### Train void stop

Deletes trains. You can choose whether it deletes only trains that arrive there by schedule or any trains that pass through it.

### Train meter stop

Acts as a normal stop, and also measures train throughput. You can view statistics, including graphs, in the stop's GUI; it can also send its data to the circuit network.
