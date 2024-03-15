// SETUP
clearscreen.
BRAKES off.
SAS off.
GEAR off.
AG1 off.
AG2 on.
AG3 off.
print "SSTOV2 Deorbit Script".
run once lib_deorbit.

set mySteer to SHIP:retrograde.
lock STEERING to mysteer.
lock THROTTLE to 0.0.
// CIRCULATIZE
// TODO


// COMPUTE BURN
set calcTime to TIME:seconds+timeToAngle(121).
set deorbitNode to calcDeorbit(calcTime, -52000).
add deorbitNode.
set burnTime to getBurnTime(deorbitNode:DELTAV:MAG).
set burnStart to calcTime - burnTime/2.
set burnEnd to burnStart + burnTime.

if burnStart < TIME:SECONDS {
    print "vessel too close to target".
}
print "90 at " + timeToAngle(121).
print "computed burn of " + deorbitNode:DELTAV:MAG + " m/s dV".
print "burn will take " + burnTime + " s".
kuniverse:timewarp:warpto(burnStart-60).
until kuniverse:timewarp:warp > 0{
    wait(0.001).
}
until kuniverse:timewarp:warp = 0{
    wait(0.001).
}
set kuniverse:timewarp:mode to "PHYSICS".
set kuniverse:timewarp:warp to 2.
// EXECUTE BURN
set mySteer to deorbitNode:burnvector.
until TIME:SECONDS >= burnStart {
    set mySteer to deorbitNode:burnvector.
    WAIT(0.001).
}
lock THROTTLE to 1.0.
until TIME:SECONDS >= burnEnd {
    set mySteer to deorbitNode:burnvector.
    WAIT(0.001).
}
lock THROTTLE to 0.0.

remove deorbitNode.
set bankAngle to 25.
set rentryAngle to 7.
//RENTRY
//UNTIL angle0to360(SHIP:longitude) > angle0to360(-84.51) {
UNTIL ship:velocity:surface:mag < 1000 {
    set mySteer to HEADING(heading_of_vector(ship:prograde:vector),rentryAngle,bankAngle).
    WAIT(0.001).
}

//UNTIL angle0to360(SHIP:longitude) > angle0to360(-79) {
UNTIL ship:velocity:surface:mag < 600 {
    set mySteer to SHIP:PROGRADE.
    WAIT(0.001).
}

//LANDING


//Return control
SET SHIP:CONTROL:PILOTMAINTHROTTLE TO 0.
unlock steering.

set sasMode to "PROGRADE".
SAS on.