
run lib.

function suborbitalToTarget {
    parameter _target.
    parameter angleOfAttack to 60. // in range [10, 90]. 10 is going pretty much horizontally, and 90 is completely vertical. Not advised to go below 20
    parameter verticalSpeed to 30. // if aiming at a target far away (>3km), increase this
    boilerplate().
    local a to -ship:body:mu / ship:body:radius ^ 2.
    local lock timeTilGround to (-ship:verticalspeed - sqrt(ship:verticalspeed ^ 2 - 2 * a * alt:radar)) / a.
    local lock groundSpeed to vxcl(ship:up:vector, ship:velocity:surface).
    local lock groundDistance to vxcl(ship:up:vector, _target:position) * 1.05. // extend it by 5% to account for errors
    local lock difference to groundDistance:mag - groundSpeed:mag * timeTilGround.
    lock steering to lookDirUp(cos(angleOfAttack) * groundDistance:normalized + sin(angleOfAttack) * ship:up:vector, ship:up:vector).
    local thr to (ship:body:mu / ship:body:radius ^ 2) / 10. // at 10m/s^2 g, thr is 1, at 1m/s^2, thr is 0.1
    print thr at (0, 10).
    lock throttle to thr.
    until difference < 0 {
        set thr to getThrottle(thr, verticalSpeed, ship:verticalspeed, 1, 0.99).
        print("ground distance to target: " + round(groundDistance:mag, 2) + "   ") at (0, 0).
        print("predicted ground distance to target: " + round(difference, 2)) at (0, 1).
        print("ground speed: " + round(groundSpeed:mag, 2) + "   ") at (0, 2).
        wait 0.01.
    }
    print("Coasting...").
    set thr to 0.
    run suicide.
}

function hopToTarget { // like suborbitalToTarget, but all the appropriate parameters have been figured out, so you only need to figure out the target
    parameter _target.
    local distance to _target:position:mag.
    if distance < 100 {
        suborbitalToTarget(_target, 85, 15).
    } else if distance > 10000 and distance < 100000 {
        suborbitalToTarget(_target, 45, 60).
    } else if distance > 100000 {
        suborbitalToTarget(_target, 30, 60).
    } else {
        suborbitalToTarget(_target).
    }
}

function hopOffset {
    parameter metersNorth.
    parameter metersEast.
    hopToTarget(offsetFromGeo(metersNorth, metersEast)).
}

function hopToWaypoint {
    parameter waypointName.
    hopToTarget(waypoint(waypointName):geoposition).
}
