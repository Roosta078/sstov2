print "Ap velocity = " + getApVelocity() + "m/s".
//print "20 m/s burn takes " + getBurnTime(20) + "s".
print "Ap circular vel = " + getCircularVelocity(ship:apoapsis) + "s".
print "current pitch is " + getPitch() + "deg".


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

function getPitch{
    return 90-VECTORANGLE(ship:up:forevector,ship:facing:forevector).
}