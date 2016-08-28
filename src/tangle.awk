function rewind(   i)
{
    # shift remaining arguments up
    for (i = ARGC; i > ARGIND; i--)
        ARGV[i] = ARGV[i-1]
    # make sure gawk knows to keep going
    ARGC++
    # make current file next to get done
    ARGV[ARGIND+1] = FILENAME
    # do it
    nextfile
}

function _lp_subst(   defname, arr) {
    while (match($0, /\.\._([^ ,;:!?]+)/, arr)) {
        defname = arr[1]
        print defname
        $0 = substr($0, RSTART + RLENGTH)
    }
}

{
    _lp_subst()
}
