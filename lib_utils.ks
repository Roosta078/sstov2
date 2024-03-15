print "Loading lib_utils".

set DEBUG_STATEMENTS to false.

function assert{
    parameter statement.
    if not statement{
        this:is:error.
    }
    set checks to checks+1.
}

function debug{
    parameter str.
    if DEBUG_STATEMENTS {
        print str.
    }
}