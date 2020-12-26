
// simple script to execute after rendezvous for final encounter, if the encounter is simple enough

run lib.

function encounter {
    lock targetRetrograde_ to target:velocity:orbit - ship:velocity:orbit.

    print "Slight nudge to target...".
    lock steering to target:position:direction.
    wait 10.
    lock throttle to 0.001.
    wait until targetRetrograde_:mag > 0.1.

    print "Slowly coasting to target...".
    lock throttle to 0.
    set mass_ to ship:mass.
    wait until abs(ship:mass - mass_) > mass_ * 0.01.
    print "Done".
}

if not (defined automaticExecution)
    encounter().
