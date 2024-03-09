// SETUP
clearscreen.
BRAKES off.
SAS off.
GEAR off.
print "SSTOV2 Deorbit Script".
run once lib_deorbit.

set mySteer to SHIP:retrograde.
lock STEERING to mysteer.
lock THROTTLE to 0.0.
// CIRCULATIZE
// TODO


// COMPUTE BURN
set calcTime to TIME:seconds+timeToAngle(110).
set deorbitNode to calcDeorbit(calcTime, -52000).
add deorbitNode.
set burnTime to getBurnTime(deorbitNode:DELTAV:MAG).
set burnStart to calcTime - burnTime/2.
set burnEnd to burnStart + burnTime.

if burnStart < TIME:SECONDS {
    print "vessel too close to target".
}
print "90 at " + timeToAngle(110).
print "computed burn of " + deorbitNode:DELTAV:MAG + " m/s dV".
print "burn will take " + burnTime + " s".


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
//RENTRY
UNTIL SHIP:VELOCITY:SURFACE:MAG < 900 {
    set mySteer to HEADING(90,7).
    WAIT(0.001).
}

UNTIL SHIP:VELOCITY:SURFACE:MAG < 80 {
    set mySteer to SHIP:PROGRADE.
    WAIT(0.001).
}

//LANDING


//Return control
SET SHIP:CONTROL:PILOTMAINTHROTTLE TO 0.
unlock steering.

set sasMode to "PROGRADE".
SAS on.