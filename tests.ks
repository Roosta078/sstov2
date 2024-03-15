run once lib_deorbit.
set checks to 0.
//set DEBUG_STATEMENTS to true.
//testCalcDeorbit().

lock STEERING to mysteer.
wait(1000).
testAngle0to360().
testTimeToAngle().
test_heading().

print "All tests passed with " + checks + " assertion checks".

function testCalcDeorbit {
    debug(calcDeorbit(time:seconds, 0000)).
}

function testAngle0to360{
   assert(30=angle0to360(30)).
   assert(30=angle0to360(390)).
   assert(30=angle0to360(-330)).
   assert(0=angle0to360(0)).
   assert(0=angle0to360(360)).
}

function testTimeToAngle{
    debug(timeToAngle(0)).
}


function test_heading{
    //assert(0=heading_of_vector(ship:north:vector)).
}