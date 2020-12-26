
run lib.

function orbit { // note that this will form an orbit with periapsis of desiredAltitude * 0.95, so make sure it stays clear from the atmosphere
    parameter desiredAltitude to 75000. // mun: 10000
    parameter direction to 90. // default east. -5 for polar orbit (north) and 185 for polar orbit (south)

    local thr to 1.
    lock throttle to thr.
    automaticStaging().

    print "Radial burn...".
    lock steering to heading(direction, 85, -90). wait until ship:orbit:apoapsis >= desiredAltitude * 1 / 5.

    print "Steeper...".
    lock steering to heading(direction, 78, -90). wait until ship:orbit:apoapsis >= desiredAltitude * 2 / 5.

    print "Steeper...".
    lock steering to heading(direction, 70, -90). wait until ship:orbit:apoapsis >= desiredAltitude * 3 / 5.

    print "Steeper...".
    lock steering to heading(direction, 63, -90). wait until ship:orbit:apoapsis >= desiredAltitude * 4 / 5.

    print "Steeper...".
    lock steering to heading(direction, 55, -90). wait until ship:orbit:apoapsis >= desiredAltitude.

    print "Waiting for any SRBs left over to run out...".
    set thr to 0.
    lock steering to heading(direction, 0, -90).
    wait until acceleration() < 0.01. wait 0.2.

    lock predictedVelocity to sqrt(ship:body:mu * (2/(ship:body:radius + ship:apoapsis) - 1/ship:orbit:semimajoraxis)). // velocityAt(ship, eta:apoapsis):orbit:mag for some reason doesn't work
    lock deltaVRequired to sqrt(ship:body:mu / (ship:body:radius + ship:apoapsis)) - predictedVelocity.
    lock burnTime to deltaVRequired / (ship:maxThrust / ship:mass).
    lock waitingFor to (eta:apoapsis - burnTime * 0.66).

    print "Coast phase, waiting " + round(waitingFor) + "s...".
    wait waitingFor.

    print "Circularization phase".
    print "DeltaV required: " + round(deltaVRequired, 2) + "m/s".
    print "Burn time: " + round(burnTime, 2) + "s".
    set thr to 1.
    lock throttle to thr.
    // burn a lot before apoapsis
    trackChanges(0, eta:apoapsis).
    until trackChanges(0, eta:apoapsis) {
        wait 0.01.
        set thr to getThrottle(thr, 0, waitingFor).
    }
    // burn a bit after apoapsis, to make sure the orbit formed is stable
    set thr to 1.
    wait until ship:orbit:periapsis >= desiredAltitude * 0.95.

    set thr to 0.
    print "Achieved orbit! You can move freely now".
    unlock throttle. unlock steering.
}

if not (defined automaticExecution)
    orbit(75000).
    beep().
