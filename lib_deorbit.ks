run once lib_utils.
print "Loading lib_deorbit".
function timeToAngle{ // assumes circular orbit
    parameter angle.
    parameter targetLong is -74.51.

    set theta_i to angle0to360(targetLong-SHIP:LONGITUDE).
    set ang_vel to 360/SHIP:ORBIT:PERIOD.
    set surf_ang_vel to 360/SHIP:ORBIT:BODY:ROTATIONPERIOD.
    
    debug("theta_i: " + theta_i).
    debug("ang_vel: " + ang_vel).
    debug("surf_ang_vel: " + surf_ang_vel).
    return angle0to360(theta_i-angle)/(ang_vel-surf_ang_vel).
}

function angle0to360{
    parameter angle.
    until angle >= 0 {
        set angle to angle+360.
    }
    until angle < 360 {
        set angle to angle -360.
    }
    return angle.
}


function calcDeorbit{ //again assumes circular orbit
    parameter Btime.
    parameter PeHeight.
    set burnHeight to ship:altitude.  //this should change if not circ
    
    set ri to burnHeight+ship:body:radius.
    set rf to PeHeight+ship:body:radius.
    debug("ri " + ri).
    debug("rf " + rf).
    set p1 to ((1/ri)-(1/rf)).
    set p2 to (1-(rf^2/ri^2)).
    debug(p1).
    debug(p2).
    set calcVel to sqrt(2*ship:body:mu*((1/ri)-(1/rf))/(1-(ri^2/rf^2))).
    set dV to calcVel - ship:velocity:orbit:mag.
    return node(Btime, 0,0,dV).
}

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

FUNCTION heading_of_vector { // heading_of_vector returns the heading of the vector (number range 0 to 360)
	PARAMETER vecT.

	LOCAL east IS VCRS(SHIP:UP:VECTOR, SHIP:NORTH:VECTOR).

	LOCAL trig_x IS VDOT(SHIP:NORTH:VECTOR, vecT).
	LOCAL trig_y IS VDOT(east, vecT).

	LOCAL result IS ARCTAN2(trig_y, trig_x).

	IF result < 0 {RETURN 360 + result.} ELSE {RETURN result.}
}