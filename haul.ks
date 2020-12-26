
// hauls the rocket upward to a desired height range and velocity range

run lib.

function haul {
    parameter heightRange.
    parameter velocityRange.

    local meanVelocity to (velocityRange[0] + velocityRange[1]) / 2.
    local thr to 1. lock throttle to thr.
    lock steering to heading(0, 90).
    automaticStaging().

    lock inHeightRange to (ship:altitude >= heightRange[0] and ship:altitude < heightRange[1]).
    lock inVelocityRange to (ship:verticalspeed >= velocityRange[0] and ship:verticalspeed < velocityRange[1]).

    until inHeightRange {
        if inVelocityRange {
            set thr to getThrottle(thr, meanVelocity, ship:verticalspeed, 10).
            clearScreen.
            print "Velocity: " + round(ship:verticalspeed, 2) + ", throttle: " + round(thr, 2).
        }
        wait 0.01.
    }

    print "Achieved desired height and velocity!".
    unlock throttle.
    unlock steering.
}

if not (defined automaticExecution)
    haul(list(5000, 10000), list(40, 180)).
    beep().
