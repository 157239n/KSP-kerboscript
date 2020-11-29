
// goes to orbit. Parameters:
// - desiredAltitude: the desired altitude, which should be a few kms more than the Karman line. Suggested values:
//      - Kerbin: 75000
//      - Mun: 13000
// - angle: the desired inclination. Suggested values:
//      - Low orbit: 90
//      - Polar orbit (north): -5
//      - Polar orbit (south): 185

run lib.

local desiredAltitude to 75000.
local angle to 90.

lock throttle to 1.
automaticStaging().

print "Radial burn...".
lock steering to heading(angle, 85, -90). wait until ship:orbit:apoapsis >= desiredAltitude * 1 / 5.

print "Steeper...".
lock steering to heading(angle, 78, -90). wait until ship:orbit:apoapsis >= desiredAltitude * 2 / 5.

print "Steeper...".
lock steering to heading(angle, 70, -90). wait until ship:orbit:apoapsis >= desiredAltitude * 3 / 5.

print "Steeper...".
lock steering to heading(angle, 63, -90). wait until ship:orbit:apoapsis >= desiredAltitude * 4 / 5.

print "Steeper...".
lock steering to heading(angle, 55, -90). wait until ship:orbit:apoapsis >= desiredAltitude.

local waitingFor to (eta:apoapsis - (sqrt(ship:body:mu / desiredAltitude) - velocityAt(ship, eta:apoapsis):orbit:mag) / (2 * ship:maxThrust / ship:mass)).
print "Coast phase, waiting " + round(waitingFor) + " s...".
lock throttle to 0.
lock steering to heading(angle, 0, -90).
wait waitingFor.

print "Circularization phase".
lock throttle to 1.
wait until ship:orbit:periapsis >= desiredAltitude.

print "Achieved orbit! You can move freely now".
unlock throttle. unlock steering.

beep().
