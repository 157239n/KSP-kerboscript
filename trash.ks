
// sort of failed/not useful attempts at stuff that may have value in the future

function quickHoverToTarget {
    parameter _target.
    sas off.
    local lock groundSpeed to vxcl(ship:up:vector, ship:velocity:surface).
    local lock groundDistance to vxcl(ship:up:vector, _target:position).
    local expectedSpeedExp to 0.8.
    local expectedSpeedOffset to 0.
    local lock expectedSpeed to min(groundDistance:mag * 0.9, 10000) ^ expectedSpeedExp - expectedSpeedOffset.
    local lock backwardsMagnitude to 2 * max(0, sCurve((groundSpeed:mag - expectedSpeed) / 5)).
    local steeringComponent to 0.5.
    lock steering to lookDirUp(steeringComponent*(groundDistance:normalized - groundSpeed:normalized * backwardsMagnitude) + ship:up:vector, ship:up:vector).
    //lock steering to lookDirUp(0.3*groundDistance:normalized + ship:up:vector, ship:up:vector).
    local thr to 1.
    lock throttle to thr.
    until groundDistance:mag < 100 {
        set thr to getThrottle(thr, 10, ship:verticalspeed, 1, 0.9).
        print("ground distance to target: " + round(groundDistance:mag, 2) + "   ") at (0, 0).
        print("ground speed: " + round(groundSpeed:mag, 2) + "   ") at (0, 1).
        print("0th") at (0, 2).
        wait 0.01.
    }
    set expectedSpeedExp to 0.6.
    set steeringComponent to 0.3.
    until groundDistance:mag < 50 and groundSpeed:mag < 30 {
        set thr to getThrottle(thr, -2, ship:verticalspeed, 1, 0.9).
        print("ground distance to target: " + round(groundDistance:mag, 2) + "   ") at (0, 0).
        print("ground speed: " + round(groundSpeed:mag, 2) + "   ") at (0, 1).
        print("1st") at (0, 2).
        wait 0.01.
    }
    set expectedSpeedExp to 0.5.
    set expectedSpeedOffset to 0.
    set steeringComponent to 0.1.
    until groundDistance:mag < 30 and groundSpeed:mag < 7 {
        set thr to getThrottle(thr, 100, alt:radar, 1, 0.9) * 0.7 + getThrottle(thr, -1, ship:verticalspeed, 1, 0.9) * 0.3.
        print("ground distance to target: " + round(groundDistance:mag, 2) + "   ") at (0, 0).
        print("ground speed: " + round(groundSpeed:mag, 2) + "   ") at (0, 1).
        print("2nd") at (0, 2).
        wait 0.01.
    }
    set thr to 0.
    run suicide.
}

function hoverToTarget {
    parameter _target.
    sas off.
    parameter initialBoost to false.
    parameter tolerance to 50. // when closer than 40 meters, then start suicide burn
    parameter cruisingAltitude to 100.
    local lock groundSpeed to vxcl(ship:up:vector, ship:velocity:surface).
    local lock groundDistance to vxcl(ship:up:vector, _target:position).
    local lock expectedSpeed to sqrt(min(groundDistance:mag * 0.9, 10000)) - 3.
    local lock backwardsMagnitude to 2 * max(0, sCurve((groundSpeed:mag - expectedSpeed) / 5)).
    lock steering to lookDirUp(0.2*(groundDistance:normalized - groundSpeed:normalized * backwardsMagnitude) + ship:up:vector, ship:up:vector).
    local thr to 0.
    lock throttle to thr.
    if initialBoost {
        set thr to 1.
        wait until alt:radar > 10.
        set thr to 0.
    }
    until groundDistance:mag < tolerance {
        set thr to getThrottle(thr, cruisingAltitude, alt:radar, 1, 0.9) * 0.25 + getThrottle(thr, 0, ship:verticalspeed, 1, 0.9) * 0.8.
        print("ground distance to target: " + round(groundDistance:mag, 2) + "   ") at (0, 0).
        print("ground speed: " + round(groundSpeed:mag, 2) + "   ") at (0, 1).
        wait 0.01.
    }
    set thr to 0.
    run suicide.
}

local persistentStartTime_ to 20.
function predictLandingTime {
    parameter cachedStartTime to persistentStartTime_.
    local startTime to max(cachedStartTime - 10, 2). // first predict the cache - 10.
    until (positionAt(ship, startTime) - ship:body:position):mag - (ship:body:radius + ship:geoposition:terrainheight) < 0 {
        set startTime to startTime + 1.
    }
    set persistentStartTime_ to startTime.
    return startTime.
}

function _correctR {
    parameter altitude_.
    return altitude_ + ship:body:radius.
}

function _getV { // vis-visa eqn
    parameter r, a.
    return sqrt(ship:body:mu * (2 / r - 1 / a)).
}

function hohmannDeltaV {
    parameter targetAltitude.
    parameter ship_ to ship.
    return _getV(_correctR(ship_:altitude), (_correctR(ship_:altitude) + _correctR(targetAltitude)) / 2) - _getV(_correctR(ship_:altitude), (_correctR(ship:orbit:periapsis) + _correctR(ship:orbit:apoapsis)) / 2).
}

function argmax {
    parameter list_.
    local maxIdx_ to -1.
    local max_ to -1e50.
    local idx to 0.
    until idx >= list_:length {
        if list_[idx] > max_ {
            set max_ to list_[idx].
            set maxIdx_ to idx.
        }
        set idx to idx + 1.
    }
    return maxIdx_.
}

function argmin {
    parameter list_.
    local minIdx_ to -1.
    local min_ to 1e50.
    local idx to 0.
    until idx >= list_:length {
        if list_[idx] < min_ {
            set min_ to list_[idx].
            set minIdx_ to idx.
        }
        set idx to idx + 1.
    }
    return minIdx_.
}
