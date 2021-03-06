
// performs a rendezvous to the target. The orbit has to be close enough (within 5%) in the first place, or
//      else this won't work. Will have 3 distinct segments, each dealing with ever finer accuracy. The final
//      distance will be less than 50 meters, and speed will be practically 0.
// after this finishes, you are expected to do the last rendezvous step. If you are grabbing a simple object
//      and would rather have that automated, then you can run `encounter` to do this.

run lib.

function _do1Cycle {
    parameter maxThrottle_, separationTarget_, velocityTarget_.

    local lock targetRetrograde_ to target:velocity:orbit - ship:velocity:orbit.

    if target:position:mag < separationTarget_ return true.

    print "- Warping until distances are increasing...".
    wait 1. set kuniverse:timewarp:warp to 2.
    local lastDistance to 1e50.
    until target:position:mag > lastDistance {
        set lastDistance to target:position:mag.
        wait 1.
    }

    print "- Slowing down...".
    set kuniverse:timewarp:warp to 0. wait 1.
    lock steering to targetRetrograde_:direction. wait until pointingInSameDirection(targetRetrograde_).
    lock throttle to maxThrottle_ * min(targetRetrograde_:mag / velocityTarget_, 1). // if really close to target, then throttle down even more
    wait until targetRetrograde_:mag < velocityTarget_ / 5.
    lock throttle to 0.

    if target:position:mag < separationTarget_ return true.

    print "- Speeding up...".
    lock steering to target:position:direction. wait until pointingInSameDirection(target:position).
    lock throttle to maxThrottle_.
    wait until targetRetrograde_:mag > velocityTarget_.
    lock throttle to 0. wait 1.

    unlock steering. unlock throttle.
    return false.
}

function nullOutVelocity {
    print "Nulling out velocity completely...".
    lock targetRetrograde_ to target:velocity:orbit - ship:velocity:orbit.
    lock steering to targetRetrograde_:direction. wait 10.

    lock throttle to 0.001.
    wait until targetRetrograde_:mag < 0.01.
    lock throttle to 0.
}

function rendezvous {    
    print "Coarse segment:". wait until _do1Cycle(0.5, 1000, 10).
    print "Fine segment:". wait until _do1Cycle(0.1, 200, 4).
    print "Very fine segment:". wait until _do1Cycle(0.05, 50, 1).

    nullOutVelocity().
}

if not (defined automaticExecution)
    rendezvous().
    beep().
