
// changes the current orbit into another. Parameters:
// - precision: how much precision do you want the final orbit to be. Default: 1000
// - target_: the desired periapsis and apoapsis. Does not have to be in order.

run lib.

local precision to 1000.
local target_ to list(500000, 500000).

automaticStaging().
lock current_ to list(ship:orbit:periapsis, ship:orbit:apoapsis).
lock timeRemaining to list(eta:periapsis, eta:apoapsis).

local distances to list(abs(current_[0] - target_[0]), abs(current_[0] - target_[1]), abs(current_[1] - target_[0]), abs(current_[1] - target_[1])).
local option to argmin(distances).

function closeEnough {
    parameter from_, to_.
    // main condition or (both conditions reversed at lower tolerance). This is to deal with apoapsis and periapsis switching places all of a sudden.
    return close(current_[from_], target_[to_], precision) or (close(current_[from_], target_[1 - to_], 10 * precision) and close(current_[1 - from_], target_[to_], 10 * precision)).
}

function burn {
    parameter from_, to_.

    if (closeEnough(from_, to_)) {
        print "- Actually, it's close enough, so skipping...".
        return.
    }

    print "- Warping to 90% opposite site...". warpFor(timeRemaining[1 - from_] * 0.9).

    print "- Correcting direction...".
    lock heading_ to ship:prograde + R(0, (choose 0 if current_[from_] < target_[to_] else 180), 0).
    lock steering to heading_.
    wait until abs(vAng(ship:facing:vector, heading_:vector)) < 0.1.

    print "- Warping to opposite site...". warpFor(timeRemaining[1 - from_] - hohmannDeltaV(target_[to_]) / (ship:maxthrust / ship:mass)).

    print "- Burning...".
    lock throttle to 1. lock steering to heading_.
    wait until closeEnough(from_, to_).

    print "- Finished burning...".
    lock throttle to 0. unlock throttle. unlock steering.
    wait 1.
}

print "1st burn at " + (choose "apoapsis" if round(option / 2) = 0 else "periapsis") + ":".
burn(round(option / 2), mod(option, 2)).
print "2nd burn at " + (choose "apoapsis" if round(option / 2) = 1 else "periapsis") + ":".
burn(1 - round(option / 2), 1 - mod(option, 2)).

beep().
