clearscreen.
BRAKES off.
SAS off.
AG1 on.
SET MYSTEER TO HEADING(90,0).
set myengines to ship:engines().
LOCK STEERING TO MYSTEER.
SET PID TO PIDLOOP(1.1, 0.4, 0.2).
set mylog to "0:/log.csv".
//log "time,input,output,setpoint,pterm("+PID:kp+"),iterm("+PID:ki+"),dterm("+PID:kd+")," to mylog.
lock throttle to 1.0.

UNTIL SHIP:APOAPSIS > 75000 { //Remember, all altitudes will be in meters, not kilometers

    IF SHIP:VELOCITY:SURFACE:MAG < 130 {
        
        SET MYSTEER TO HEADING(90,0.9).

    } ELSE IF SHIP:VELOCITY:SURFACE:MAG >= 130 AND SHIP:VELOCITY:SURFACE:MAG < 300 {
        SET MYSTEER TO HEADING(90,10).
        PRINT "Pitching to 5 degrees" AT(0,15).
        PRINT ROUND(SHIP:APOAPSIS,0) AT (0,16).
        if ship:altitude >100 {
            GEAR off.
        }

    //Each successive IF statement checks to see if our velocity
    //is within a 100m/s block and adjusts our heading down another
    //ten degrees if so
    } ELSE IF SHIP:VELOCITY:SURFACE:MAG >= 300 AND SHIP:VELOCITY:SURFACE:MAG < 430 { //430 prevents falling back to this
        SET MYSTEER TO HEADING(90,4).
        PRINT "Pitching to 3 degrees" AT(0,15).
        PRINT ROUND(SHIP:APOAPSIS,0) AT (0,16).

    } ELSE IF SHIP:VELOCITY:SURFACE:MAG >= 470 AND SHIP:VELOCITY:SURFACE:MAG < 480  {
        SET MYSTEER TO HEADING(90,12).
        PRINT "Pitching to 15 degrees" AT(0,15).
        PRINT ROUND(SHIP:APOAPSIS,0) AT (0,16).
    }ELSE IF SHIP:VELOCITY:SURFACE:MAG >= 480 AND SHIP:altitude < 10000 {
        SET MYSTEER TO HEADING(90,17).
        PRINT "Pitching to 17 degrees" AT(0,15).
        PRINT ROUND(SHIP:APOAPSIS,0) AT (0,16).
    } else if ship:altitude >= 10000 and ship:altitude < 22000 {
        SET MYSTEER TO HEADING(90,11).
        PRINT "Pitching to 11 degrees" AT(0,15).
        PRINT ROUND(SHIP:APOAPSIS,0) AT (0,16).
    } else if ship:altitude >= 22000 and ship:altitude < 28000 {
        AG2 on.
        SET MYSTEER TO HEADING(90,12).
        PRINT "Pitching to 12 degrees" AT(0,15).
        PRINT ROUND(SHIP:APOAPSIS,0) AT (0,16).
    }else if ship:altitude >= 28000 and myengines[5]:thrust > 0 {
        AG3 on.
        set PID:setpoint to 35.
        set request to PID:update(TIME:SECONDS,getPitch()).
        SET MYSTEER TO HEADING(90,request).
        PRINT "Pitching to pid " + request + " degrees" AT(0,14).
        PRINT "Currently " + getPitch() + " degrees" at(0,15).
        PRINT ROUND(SHIP:APOAPSIS,0) AT (0,16).
        //pidLog(PID).
    }else if ship:altitude >= 28000  {
        AG3 on.
        SET MYSTEER TO ship:prograde.// + R(9,0,0).
        //print "prograde: " + ship:prograde at (0,18).
        //set PID:setpoint to 10.
        //set request to PID:update(TIME:SECONDS,getPitch()).
        //SET MYSTEER TO HEADING(90,request).
        print "mysteer: " + MYSTEER at (0,19).
        PRINT "Pitching to prograde" AT(0,15).
        PRINT ROUND(SHIP:APOAPSIS,0) AT (0,16).
        //pidLog(PID).
    }.

}.
AG1 off.
clearScreen.
PRINT "75km apoapsis reached, cutting throttle".

lock THROTTLE TO 0.



//Create Circularization maneuver
set circDV to getCircularVelocity(SHIP:APOAPSIS) - getApVelocity().
set circNode to NODE(TIME:seconds + SHIP:OBT:ETA:APOAPSIS, 0, 0, circDV).
add(circNode).
PRINT "Circularization burn computed:".
PRINT "Node of " + circDV + "m/s will take " + getBurnTime(circDV) + "s".
PRINT "Result Orbit has ecc of " + circNode:orbit:eccentricity.

//If we have extra time, stay prograde until out of atmosphere
set burnStart to circNode:time - (getBurnTime(circDV)/2).
PRINT "starting burn at " + burnStart.
set recompute to false.
until TIME:seconds >= burnStart {
    if SHIP:ALTITUDE > KERBIN:ATM:HEIGHT {
        set MYSTEER to circNode:burnvector.
        if recompute {
            remove circNode.
            set circDV to getCircularVelocity(SHIP:APOAPSIS) - getApVelocity().
            set circNode to NODE(TIME:seconds + SHIP:OBT:ETA:APOAPSIS, 0, 0, circDV).
            add(circNode).
            set burnStart to circNode:time - (getBurnTime(circDV)/2).
            set recompute to false.
            print "burn recomputed".
        }
    } else {
        set MYSTEER to SHIP:prograde.
        set recompute to true.
    }.
    WAIT(0.001).
}.

if recompute {
            remove circNode.
            set circDV to getCircularVelocity(SHIP:APOAPSIS) - getApVelocity().
            set circNode to NODE(TIME:seconds + SHIP:OBT:ETA:APOAPSIS, 0, 0, circDV).
            add(circNode).
            set burnStart to circNode:time - (getBurnTime(circDV)/2).
            set recompute to false.
            print "burn recomputed".
        }
lock THROTTLE to 1.0.
set timeStart to TIME:SECONDS.
set burntarget to ship:apoapsis - 50.
set burnEnd to TIME:SECONDS + getBurnTime(circDV).
set newTarget to ship:apoapsis * 2.
//until TIME:SECONDS > burnEnd{
until ship:apoapsis+ship:periapsis > newTarget{
    set MYSTEER to circNode:burnvector.
    WAIT(0.001).
}
lock THROTTLE to 0.
set timeEnd to TIME:SECONDS.
print "burn took " + (timeEnd-timeStart) + "s".
remove(circNode).
print "Launch is complete".

//This sets the user's throttle setting to zero to prevent the throttle
//from returning to the position it was at before the script was run.
SET SHIP:CONTROL:PILOTMAINTHROTTLE TO 0.
SAS on.



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
