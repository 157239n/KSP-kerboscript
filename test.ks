
run hop.

clearscreen.

local a to getTargets(list("Runway 1 start", "Runway 1 end")).

//print latlng(1.39444, -62.35361).
//local _target to latlng(-1.5, -144.233).
//local _target to getTargets(list("Moon base 1"))[0].
//hopToTarget(_target).
//hopOffset(0, -2000).
stopAutomaticExecution().
run rendezvous.
nullOutVelocity().
//hopToWaypoint("Minmus - Flats").

//suborbitalToTarget(a[0], 70, 1).
//wait 5.
//suborbitalToTarget(a[0], 75, 1).
//wait 5.
//quickHoverToTarget(a[0]).
//hoverToTarget(a[0], true).

// print(ship:position).
// print(a[0]:position).
// print(a[1]:position).
// print("---------").
// print(a[1]:position - a[0]:position).
// print(a[0]:position - ship:position).
// print(a[1]:position - ship:position).
// print("---------").


// set thr to 1.
// lock throttle to thr.
// lock steering to heading(180, 80).
// stage.

// wait until ship:altitude > 1000.
// set thr to 0.
// print "Done initial boosting, waiting to fall back down" at (0, 0).
// wait until ship:verticalspeed < 1.

// unlock throttle.
// unlock steering.

// run suicide.
