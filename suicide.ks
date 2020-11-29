
// executes a suicide burn. Parameters:
// - radarOffset: alt:radar while on the ground. This is just to make the calculations more accurate.
// - velocityCoefficient: the closer to 1, the more the rocket will try to adhere to the desired velocity,
//      and the more fuel saved. It also means it's more risky. Suggested 0.8 for safety, 0.95 for normal,
//      and 0.99 for risky.

run lib.

local radarOffset to 4.
local velocityCoefficient to 0.8.

local thr to 1. lock throttle to thr.
local lock netAcc to ship:maxthrust / ship:mass - ship:body:mu / ship:body:radius ^ 2.
local lock velocity to abs(ship:verticalspeed).
local lock altitude to max(alt:radar - radarOffset, 0).
lock desiredVelocity to sqrt(max(altitude * netAcc, 0)) * velocityCoefficient.

print "Begin suicide burn. " at (0, 0).

set thr to 0.
if hasTarget {
    print "Target landing spot was selected" at (20, 0).
    lock landingTime_ to predictLandingTime().
    lock towardsTarget_ to target:position - positionAt(ship, landingTime_).
    lock steering to (ship:srfRetrograde:vector + towardsTarget_:normalized * ln(towardsTarget_:mag)):direction.
} else {
    lock steering to ship:srfRetrograde.
}
until altitude < 2 {
    set thr to getThrottle(thr, velocity, desiredVelocity, 1, 0.9).
    print "altitude: " + round(altitude, 2) at (0, 1).
    print "velocity: " + round(velocity, 2) at (0, 2).
    print "desired velocity: " + round(desiredVelocity, 2) + "   " at (0, 3).
    print "net acceleration: " + round(netAcc, 2) + "   " at (0, 4).
}
set thr to 0.
unlock throttle.
unlock steering.

beep().
