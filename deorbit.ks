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
set calcTime to TIME:seconds+timeToAngle(90).
set deorbitNode to calcDeorbit(calcTime, -20000).

set burnTime to getBurnTime(deorbitNode:DELTAV:MAG).
set burnStart to calcTime - burnTime/2.
set burnEnd to burnStart + burnTime.

if burnStart < TIME:SECONDS {
    print "vessel too close to target".
    
}

add deorbitNode.
// EXECUTE BURN
set mySteer to deorbitNode:burnvector.
until TIME:SECONDS >= burnStart {
    WAIT(0.001).
}
lock THROTTLE to 1.0.
until TIME:SECONDS >= burnEnd {
    WAIT(0.001).
}
lock THROTTLE to 0.0.

remove deorbitNode.
//RENTRY
UNTIL SHIP:altitude < 5000 {
    set mySteer to HEADING(90,8).
    WAIT(0.001).
}



//LANDING


//Return control
SET SHIP:CONTROL:PILOTMAINTHROTTLE TO 0.
SAS on.
