clearscreen.

AG1 on.
SET MYSTEER TO HEADING(90,0).
set myengines to ship:engines().
LOCK STEERING TO MYSTEER.

lock throttle to 1.0.

UNTIL SHIP:APOAPSIS > 80000 { //Remember, all altitudes will be in meters, not kilometers

    IF SHIP:VELOCITY:SURFACE:MAG < 100 {
        
        SET MYSTEER TO HEADING(90,0.9).

    } ELSE IF SHIP:VELOCITY:SURFACE:MAG >= 100 AND SHIP:VELOCITY:SURFACE:MAG < 200 {
        SET MYSTEER TO HEADING(90,5).
        PRINT "Pitching to 5 degrees" AT(0,15).
        PRINT ROUND(SHIP:APOAPSIS,0) AT (0,16).

    //Each successive IF statement checks to see if our velocity
    //is within a 100m/s block and adjusts our heading down another
    //ten degrees if so
    } ELSE IF SHIP:VELOCITY:SURFACE:MAG >= 200 AND SHIP:VELOCITY:SURFACE:MAG < 450 {
        SET MYSTEER TO HEADING(90,3).
        PRINT "Pitching to 3 degrees" AT(0,15).
        PRINT ROUND(SHIP:APOAPSIS,0) AT (0,16).

    } ELSE IF SHIP:VELOCITY:SURFACE:MAG >= 450 AND SHIP:altitude < 10000 {
        SET MYSTEER TO HEADING(90,17).
        PRINT "Pitching to 15 degrees" AT(0,15).
        PRINT ROUND(SHIP:APOAPSIS,0) AT (0,16).
    } else if ship:altitude >= 10000 and ship:altitude < 22000 {
        SET MYSTEER TO HEADING(90,8).
        PRINT "Pitching to 8 degrees" AT(0,15).
        PRINT ROUND(SHIP:APOAPSIS,0) AT (0,16).
    } else if ship:altitude >= 22000 and ship:altitude < 25000 {
        AG2 on.
        SET MYSTEER TO HEADING(90,8).
        PRINT "Pitching to 8 degrees" AT(0,15).
        PRINT ROUND(SHIP:APOAPSIS,0) AT (0,16).
    }else if ship:altitude >= 25000 and myengines[5]:thrust > 0 {
        AG3 on.
        SET MYSTEER TO HEADING(90,40).
        PRINT "Pitching to 40 degrees" AT(0,15).
        PRINT ROUND(SHIP:APOAPSIS,0) AT (0,16).
    }else  {
        AG3 on.
        SET MYSTEER TO ship:prograde.
        PRINT "Pitching to prograde" AT(0,15).
        PRINT ROUND(SHIP:APOAPSIS,0) AT (0,16).
    }.

}.

PRINT "80km apoapsis reached, cutting throttle".

lock THROTTLE TO 0.



//Create Circularization maneuver
set circDV to getCircularVelocity(SHIP:APOAPSIS) - getApVelocity().
set circNode to NODE(SHIP:OBT:ETA:APOAPSIS, 0, 0, circDV).

PRINT "Circularization burn computed:".
PRINT "Node of " + circDV + "m/s will take " + getBurnTime(circDV) + "s".
PRINT "Result Orbit has ecc of " + circNode:orbit:eccentricity.

//If we have extra time, stay prograde until out of atmosphere
set burnStart to circNode:time - (getBurnTime(circDV)/2).
until TIME:seconds >= burnStart {
    if SHIP:ALTITUDE > KERBIN:ATM:HEIGHT {
        set MYSTEER to circNode:burnvector.
    } else {
        set MYSTEER to SHIP:prograde.
    }.
    WAIT(0.001).
}.
lock THROTTLE to 1.0.
set timeStart to TIME:SECONDS.
until SHIP:periapsis > 80000 {
    WAIT(0.001).
}
lock THROTTLE to 0.
set timeEnd to TIME:SECONDS.
print "burn took " + (timeEnd-timeStart) + "s".

print "Launch is complete".

//This sets the user's throttle setting to zero to prevent the throttle
//from returning to the position it was at before the script was run.
SET SHIP:CONTROL:PILOTMAINTHROTTLE TO 0.


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
    return sqrt(SHIP:VELOCITY:ORBIT:MAG^2 + 2*KERBIN:MU*((1/(SHIP:ALTITUDE + KERBIN:RADIUS)) - (1/(SHIP:APOAPSIS + KERBIN:RADIUS)))).
}

function getCircularVelocity {
    parameter height.
    return sqrt(KERBIN:MU/(height+KERBIN:RADIUS)).
}
