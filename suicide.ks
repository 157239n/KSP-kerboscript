
run lib.

function suicide {
    parameter radarOffset to 6. // alt:radar of the landing ship while on the ground. The program will make the ship stop completely at this height
    parameter velocityCoefficient to 0.9. // number from 0 to 1. The higher, the more suicidal it gets. 0.8 for safety, 0.95 for normal, 1 for risky

    print "Coasting until falling down...".
    wait until ship:verticalSpeed < -1.

    local thr to 1. lock throttle to thr.
    local lock netAcc to ship:maxthrust / ship:mass - ship:body:mu / ship:body:radius ^ 2.
    //local lock velocity to max(-ship:verticalspeed, 0).
    local lock velocity to ship:velocity:surface:mag.
    local lock altitude to max(alt:radar - radarOffset, 0).
    lock desiredVelocity to sqrt(max(altitude * netAcc, 0)) * velocityCoefficient.

    print "Begin suicide burn.             " at (0, 0).

    when altitude < 200 then gear on.
    set thr to 0.
    lock steering to ship:srfRetrograde.
    until velocity < 5 and altitude < 20 {
        set thr to getThrottle(thr, velocity, desiredVelocity, 1, 0.9).
        print "altitude: " + round(altitude, 2) at (0, 1).
        print "velocity: " + round(velocity, 2) at (0, 2).
        print "desired velocity: " + round(desiredVelocity, 2) + "   " at (0, 3).
        print "net acceleration: " + round(netAcc, 2) + "   " at (0, 4).
    }
    set thr to 0. lock steering to ship:up.
    wait 5. unlock throttle. unlock steering. sas on.
}

if not (defined automaticExecution)
    suicide(6, 0.8).
    beep().
