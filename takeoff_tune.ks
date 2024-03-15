clearscreen.
BRAKES off.
SAS off.
AG1 on.
SET MYSTEER TO HEADING(90,0).
set myengines to ship:engines().
LOCK STEERING TO MYSTEER.
SET PID TO PIDLOOP(0.8, 0.5, 0.8).
set PID.MAXOUTPUT to 70.
set PID.MINOUTPUT to -5.
set logindex to 1.
set mylog to "0:/takeoff"+logindex+".csv".
until not exists(mylog){
    set logindex to logindex+1.
    set mylog to "0:/takeoff"+logindex+".csv".
}
log "time,input,output,setpoint,"+PID:kp+","+PID:ki+","+PID:kd+"," to mylog.
lock throttle to 1.0.
set runway_end to -74.51.
set runway_pitch to getPitch().
set segment to 1.

UNTIL SHIP:APOAPSIS > 85000 { //Remember, all altitudes will be in meters, not kilometers

    //IF SHIP:VELOCITY:SURFACE:MAG < 130 {
    IF SHIP:LONGITUDE < runway_end {
        
        //SET MYSTEER TO HEADING(90,runway_pitch).
        set PID:setpoint to runway_pitch.
        set request to PID:update(TIME:SECONDS,getPitch()).
        SET MYSTEER TO HEADING(90,request).
        PRINT SHIP:LONGITUDE AT (0,16).
        pidLog(PID).

    } ELSE IF SHIP:VELOCITY:SURFACE:MAG < 300 and segment <= 2{
        //SET MYSTEER TO HEADING(90,10).
        set segment to 2.
        set PID:setpoint to 10.
        set request to PID:update(TIME:SECONDS,getPitch()).
        SET MYSTEER TO HEADING(90,request).
        PRINT "Pitching to 5 degrees" AT(0,15).
        PRINT SHIP:LONGITUDE AT (0,16).
        pidLog(PID).
        if ship:altitude >100 {
            GEAR off.
        }

    //Each successive IF statement checks to see if our velocity
    //is within a 100m/s block and adjusts our heading down another
    //ten degrees if so
    } ELSE IF segment<=3 AND SHIP:VELOCITY:SURFACE:MAG < 460 { //430 prevents falling back to this
        set segment to 3.
        //SET MYSTEER TO HEADING(90,4).
        set PID:setpoint to 4.
        set request to PID:update(TIME:SECONDS,getPitch()).
        SET MYSTEER TO HEADING(90,request).
        PRINT "Pitching to 3 degrees" AT(0,15).
        PRINT ROUND(SHIP:APOAPSIS,0) AT (0,16).
        pidLog(PID).

    } ELSE IF segment <=4 AND SHIP:VELOCITY:SURFACE:MAG < 480  {
        set segment to 4.
        //SET MYSTEER TO HEADING(90,12).
        set PID:setpoint to 12.
        set request to PID:update(TIME:SECONDS,getPitch()).
        SET MYSTEER TO HEADING(90,request).
        PRINT "Pitching to 15 degrees" AT(0,15).
        PRINT ROUND(SHIP:APOAPSIS,0) AT (0,16).
        pidLog(PID).
    }ELSE IF segment <=5 AND SHIP:altitude < 10000 {
        set segment to 5.
        //SET MYSTEER TO HEADING(90,17).
        set PID:setpoint to 17.
        set request to PID:update(TIME:SECONDS,getPitch()).
        SET MYSTEER TO HEADING(90,request).
        PRINT "Pitching to 17 degrees" AT(0,15).
        PRINT ROUND(SHIP:APOAPSIS,0) AT (0,16).
        pidLog(PID).
    } else if segment <=6 and ship:altitude < 22000 {
        set segment to 6.
        //SET MYSTEER TO HEADING(90,9).
        set PID:setpoint to 11.
        set request to PID:update(TIME:SECONDS,getPitch()).
        SET MYSTEER TO HEADING(90,request).
        PRINT "Pitching to 11 degrees" AT(0,15).
        PRINT ROUND(SHIP:APOAPSIS,0) AT (0,16).
        pidLog(PID).
    }else if segment <= 7 and ship:altitude < 26000 {
        set segment to 7.
        AG2 on.
        //SET MYSTEER TO HEADING(90,12).
        set PID:setpoint to 12.
        set request to PID:update(TIME:SECONDS,getPitch()).
        SET MYSTEER TO HEADING(90,request).
        pidLog(PID).
        PRINT "Pitching to 12 degrees" AT(0,15).
        PRINT ROUND(SHIP:APOAPSIS,0) AT (0,16).
    }else if segment <= 8 and myengines[5]:thrust > 0 {
        //set PID.KP to 0.0.
        set segment to 8.
        AG3 on.
        set PID:setpoint to 35.
        set request to PID:update(TIME:SECONDS,getPitch()).
        SET MYSTEER TO HEADING(90,request).
        PRINT "Pitching to pid " + request + " degrees" AT(0,14).
        PRINT "Currently " + getPitch() + " degrees" at(0,15).
        PRINT ROUND(SHIP:APOAPSIS,0) AT (0,16).
        pidLog(PID).
    }else if segment <= 9 and ship:altitude >= 28000  {
        //set PID.KP to 1.1.
        set segment to 9.
        AG3 on.
        SET MYSTEER TO ship:prograde.// + R(9,0,0).
        //print "prograde: " + ship:prograde at (0,18).
        //set PID:setpoint to 10.
        //set request to PID:update(TIME:SECONDS,getPitch()).
        //SET MYSTEER TO HEADING(90,request).
        print "mysteer: " + MYSTEER at (0,19).
        PRINT "Pitching to prograde" AT(0,15).
        PRINT ROUND(SHIP:APOAPSIS,0) AT (0,16).
        pidLog(PID).
    }.
}

SET SHIP:CONTROL:PILOTMAINTHROTTLE TO 0.
SAS on.

function getPitch{
    return 90-VECTORANGLE(ship:up:forevector,ship:facing:forevector).
}

function pidLog{
    parameter mypid.
    log mypid:lastsampletime +","+ mypid:input +","+ mypid:output +","+ mypid:setpoint +","+ mypid:pterm +","+ mypid:iterm +","+ mypid:dterm +"," to mylog.
}
