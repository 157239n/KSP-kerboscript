
run lib.

print "Stats:" at (0, 0).
until false {
    print "- Orbital velocity: " + round(ship:velocity:orbit:mag, 2) + " m/s   " at (0, 1).
    print "- Vertical speed: " + round(ship:verticalspeed, 2) + " m/s   " at (0, 2).
    print "- Vehicle mass: " + round(ship:mass, 2) + " tons   " at (0, 3).
    print "- Max thrust: " + round(ship:maxthrust, 2) + " kN, max acceleration: " + round(ship:maxthrust / ship:mass) + " m/s^2   " at (0, 4).
    print "- Altitude (alt:radar): " + round(alt:radar, 2) + " m   " at (0, 5).
    print "- Periapsis: " + round(ship:orbit:periapsis) + " m in " + round(eta:periapsis, 1) + " s   " at (0, 6).
    print "- Apoapsis: " + round(ship:orbit:apoapsis) + " m in " + round(eta:apoapsis, 1) + " s   " at (0, 7).
    wait 0.01.
}
