# Script_Medorent
Insieme di script per la missione addestrativa semidinamica Syria


--   * @{#SPAWN.SpawnScheduled}(): Spawn groups at scheduled but randomized intervals.
---  * @{#SPAWN.SpawnScheduleStart}(): Start or continue to spawn groups at scheduled time intervals.
--   * @{#SPAWN.SpawnScheduleStop}(): Stop the spawning of groups at scheduled time intervals.

SPAWN:New( "spawnelementi" )
    :InitLimit( 1, 10 )
    :InitRandomizeTemplate( "spawnelementi" )
    :SpawnScheduled( 1, 10, 60, 0.5 )
    :SpawnScheduleStart()


--scheduler all'interno della funzione di spawn per farlo partire dopo un certo tempo

function 
