# streams is input
# BUILDDIR is external var

function _lp_parse_redir(   arr, res) {
    if (match($0, /redir \.\.>(.*)/, arr)) {
        if (_lp_pathsplit(arr[1], res)) {
            _LP_REDIRTO = BUILDDIR "/defs/" res[2]
            printf("_LP_REDIR: %s\n\n", arr[1]) > _LP_REDIRTO
            close(_LP_REDIRTO)
        }
    }
}

function _lp_parse_defin(   arr, res, fname) {
    if (match($0, /defin \.\.:(.*)/, arr)) {
        if (_lp_pathsplit(arr[1], res)) {
            _LP_REDIRTO = BUILDDIR "/defs/" res[2] ".lpdef" # XXX denied ext for tangled files
            printf("", arr[1]) > _LP_REDIRTO
            close(_LP_REDIRTO)
        }
    }
}

# FIXME remove leading indent
function _lp_parse_bcode() {
    if (match($0, /bcode (.*)/, arr)) {
        #print "bcode ", arr[1], _LP_REDIRTO
        if (_LP_REDIRTO) {
            print arr[1] >> _LP_REDIRTO
            close(_LP_REDIRTO)
        }
    }
}

function _lp_join(sep, arr,   res) { # res is local var
    for (i=1; i<=length(arr); i++) {
        res = res (i!=1?sep:"") arr[i]
    }
    return res
}

function _lp_pathsplit(path, res,   arr, dir, arrlen, name) {
    split(path, arr, "/")
    arrlen = length(arr)
    if (arrlen) {
        name = arr[arrlen]
        delete arr[arrlen]
        dir = _lp_join("/", arr)
        if (!length(dir)) {
            if (arrlen == 2) dir = "/"
            else if (arrlen == 1) dir = "."
        }
        res[1] = dir
        res[2] = name
        return 1
    } else {
        return 0
    }
}

BEGIN {
    _LP_REDIRTO = ""
}
{
    _lp_parse_redir()
    _lp_parse_defin()
    _lp_parse_bcode()
}
