
// hauls the rocket upward to a desired height range and velocity range. Parameters:
// - heightRange
// - velocityRange

run lib.

local heightRange to list(5000, 10000).
local velocityRange to list(40, 180).

local meanVelocity to (velocityRange[0] + velocityRange[1]) / 2.
local thr to 1. lock throttle to thr.
lock steering to heading(0, 90).
stage.

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

beep().
