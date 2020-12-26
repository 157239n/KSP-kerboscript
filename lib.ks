
@lazyGlobal off.

function boilerplate {
    clearScreen.
    sas off.
}
boilerplate().

function stopAutomaticExecution { // stops other scripts from running stuff immediately and just use them as a library instead
    global automaticExecution to False. // other scripts check for existence, not value, so be aware of that
}

function sCurve { // sigmoid(delta) * 2 - 1
    parameter delta.
    if delta < -100 return -1.
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

local _trackChanges to list(0, 0, 0, 0, 0, 0, 0, 0, 0, 0).
function trackChanges {
    parameter variableIndex. // what variable #no are we tracking?
    parameter value. // the current value
    parameter threshold to 0.1. // if changes more than 10%, then notify that something is up
    local oldValue to _trackChanges[variableIndex].
    set _trackChanges[variableIndex] to value.
    return abs(oldValue - value) > abs(value) * threshold.
}

function warpFor { // warp for a specified number of seconds
    parameter seconds.
    if seconds < 0 return.
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

function close { // whether 2 numbers are close to each other
    parameter a, b, epsilon to 0.01.
    return abs(a - b) < epsilon.
}

function automaticStaging { // setup automatic staging
    trackChanges(9, ship:maxthrust).
    when trackChanges(9, ship:maxthrust) or ship:maxthrust = 0 then {
        print "Staging...". wait 0.2. stage. wait 0.2. preserve.
    }
}

local voiceObj_ to getvoice(0).
function beep { // plays a beeping sound
    voiceObj_:play(note(440, 1)).
}

function acceleration { // calculates the current acceleration.
    local vStart to ship:velocity:orbit:mag.
    wait 0.01.
    local vEnd to ship:velocity:orbit:mag.
    return (vEnd - vStart) / 0.01.
}

function getTargets { // given a list of strings, get the targets with those names and return the list
    parameter targetNames.
    local _targets to list().
    list targets in _targets.
    local answer to list().
    for targetName in targetNames {
        local found to false.
        for _target in _targets {
            if _target:name = targetName{
                answer:add(_target).
                set found to true.
                break.
            }
        }
        if (not found) print(targetName + " not found").
    }
    return answer.
}

function offsetFromGeo { // get offsetted geolocation from another geoposition
    parameter metersNorth.
    parameter metersEast.
    parameter location to ship:geoPosition.
    local degreesNorth to location:lat + metersNorth * 180 / (ship:body:radius * constant:pi).
    local degreesEast to location:lng + metersEast * 180 / (ship:body:radius * constant:pi).
    return latlng(degreesNorth, degreesEast).
}

function pointingInSameDirection {
    parameter v1.
    parameter v2 to ship:facing:vector.
    parameter maxAngleDifference to 3.
    return vang(v1, v2) < maxAngleDifference.
}
