
@lazyGlobal off.

// boilerplate code
clearScreen.
sas off.

// sigmoid(delta) * 2 - 1
function sCurve {
    parameter delta.
    if delta < -100
        return -1.
    local exp to constant:E ^ (-delta).
    return (1 - exp) / (1 + exp).
}

// auto adjusting throttle so that `actual` meets `desired`. `actual` and `desired` meaning may be switch in
//      your particular use case. The general principle still stands:
//      - if desired >> actual, then throttle will be 1.
//      - if desired > actual, then somewhere between 0 and 1.
//      - if desired < actual, then throttle will be 0.
function getThrottle {
    // smoothness (0, +inf), the higher, the smoother
    parameter thr, desired, actual, smoothness is 1, alpha is 0.99.
    return thr * alpha + max(sCurve((desired - actual) / smoothness), 0) * (1 - alpha).
}

// warp for a specified number of seconds
function warpFor {
    parameter seconds.
    if seconds < 0
        return.
    local rates to kuniverse:timewarp:ratelist.
    local idx to rates:length - 1.
    until idx < 0 {
        if 5 * rates[idx] < seconds {
            set kuniverse:timewarp:warp to idx.
            wait seconds * 0.9.
            set seconds to seconds * 0.1.
        }
        set idx to idx - 1.
    }
    set kuniverse:timewarp:warp to 0.
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

// whether 2 numbers are close to each other
function close {
    parameter a, b, epsilon to 0.01.
    return abs(a - b) < epsilon.
}

// setup automatic staging
function automaticStaging {
    local lastMaxThrust to ship:maxthrust.
    when ship:maxthrust < lastMaxThrust * 0.9 or ship:maxthrust = 0 then {
        print "Staging...".
        wait 1. stage. wait 1.
        set lastMaxThrust to ship:maxthrust.
        preserve.
    }
}

local voiceObj_ to getvoice(0).
// plays a beeping sound
function beep {
    voiceObj_:play(note(440, 1)).
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

local persistentStartTime_ to 20.
function predictLandingTime {
    parameter cachedStartTime to persistentStartTime_.
    local startTime to cachedStartTime - 10. // first predict the cache - 10.
    until (positionAt(ship, startTime) - ship:body:position):mag - ship:body:radius < 0 {
        set startTime to startTime + 1.
    }
    set persistentStartTime_ to startTime.
    return startTime.
}
