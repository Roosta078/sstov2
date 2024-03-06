print "Ap velocity = " + getApVelocity() + "m/s".
//print "20 m/s burn takes " + getBurnTime(20) + "s".
print "Ap circular vel = " + getCircularVelocity(ship:apoapsis) + "s".
print "current pitch is " + getPitch() + "deg".
print "new ap vel = " + newGetApVelocity(80168.4) + "m/s".
print "correct ap vel = " + getApVelocity(80168.4,70595,2295.1).

SET PID TO PIDLOOP(1.6, 0.05, 0.2).
set mylog to "1:/log.csv".
log "time,input,output,setpoint,pterm,iterm,dterm," to mylog.
pidLog(PID).


function getBurnTime {
    parameter deltaV.
    set engineCount to 3.  //TODO figure out better way later
    set engineIndex to 1.  //TODO check this, then find better way

    set massFlow to SHIP:ENGINES[engineIndex]:MAXMASSFLOW * engineCount.
    set thrust to SHIP:ENGINES[engineIndex]:maxThrust * engineCount.
    set coeff to SHIP:MASS / (massFlow).
    set natural to constant:e ^ (-deltaV*massFlow/thrust).

    return coeff * (1 - natural).
}

function getApVelocity {
    parameter height is ship:apoapsis.
    parameter alti is SHIP:ALTITUDE.
    parameter vel is SHIP:VELOCITY:ORBIT:MAG.
    return sqrt(vel^2 -2*KERBIN:MU*((1/(alti + KERBIN:RADIUS)) - (1/(height + KERBIN:RADIUS)))).
}
function newGetApVelocity {
    parameter height is ship:apoapsis.
    return sqrt(KERBIN:MU/(height+KERBIN:RADIUS)).
}

function getCircularVelocity {
    parameter height.
    return sqrt(KERBIN:MU/(height+KERBIN:RADIUS)).
}

function getPitch{
    return 90-VECTORANGLE(ship:up:forevector,ship:facing:forevector).
}

function pidLog{
    parameter mypid.
    log mypid:lastsampletime +","+ mypid:input +","+ mypid:output +","+ mypid:setpoint +","+ mypid:pterm +","+ mypid:iterm +","+ mypid:dterm +"," to mylog.
}
