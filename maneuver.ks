
// executes maneuver, taken from https://ksp-kos.github.io/KOS/tutorials/exenode.html, with modifications

run lib.

function maneuver {
    set nd to nextnode.
    lock max_acc to ship:maxthrust/ship:mass.
    set burn_duration to nd:deltav:mag/max_acc.

    print("Warping to node...").
    warpFor(nd:eta - (burn_duration/2 + 60)).

    print("Correcting direction...").
    local dv0 to nd:deltav.
    lock steering to dv0.
    wait until pointingInSameDirection(dv0).
    print("Warping to node...").
    warpFor(nd:eta - burn_duration/2).

    set dv0 to nd:deltav. // initial deltav
    lock throttle to min(nd:deltav:mag/max_acc, 1). // 100% until there is less than 1 second of time left to burn, then linearly decreasing

    print("Start burn...").
    until false {
        if vdot(dv0, nd:deltav) < 0 { // cut throttle when vectors diverge too much
            print "End burn, remain dv " + round(nd:deltav:mag,1) + "m/s, vdot: " + round(vdot(dv0, nd:deltav),1).
            lock throttle to 0. break.
        }

        if nd:deltav:mag < 0.1 { // we have very little left to burn, less then 0.1m/s
            print "Finalizing burn, remain dv " + round(nd:deltav:mag,1) + "m/s, vdot: " + round(vdot(dv0, nd:deltav),1).
            wait until vdot(dv0, nd:deltav) < 0.5.
            print "End burn, remain dv " + round(nd:deltav:mag,1) + "m/s, vdot: " + round(vdot(dv0, nd:deltav),1).
            lock throttle to 0. break.
        }
    }
    unlock steering. unlock throttle. wait 1.
}

if not (defined automaticExecution)
    maneuver().
    beep().
