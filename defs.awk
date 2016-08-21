# streams is input
# BUILDDIR is external var

function _lp_parse_redir(   arr, res) {
    if (match($0, /redir \.\.>(.*)/, arr)) {
        if (_lp_pathsplit(arr[1], res)) {
            _LP_REDIRTO = BUILDDIR "/defs/" res[2] ".lp-redir"
            printf("_LP_REDIR: %s\n", arr[1]) > _LP_REDIRTO
            close(_LP_REDIRTO)
        }
    }
}

function _lp_parse_defin(   arr, res) {
    if (match($0, /defin \.\.:(.*)/, arr)) {
        if (_lp_pathsplit(arr[1], res)) {
            _LP_REDIRTO = BUILDDIR "/defs/" res[2] ".lp-defin"
            printf("", arr[1]) > _LP_REDIRTO
            close(_LP_REDIRTO)
        }
    }
}

function _lp_parse_bcode(   arr0, arr1) {
    if (match($0, /bcode (.*)/, arr0)) {
        if (_LP_REDIRTO) {
            if (!length(_lp_bcodeindent)) {
                if (match(arr0[1], /([\t ]+)(.*)/, arr1)) {
                    _lp_bcodeindent = arr1[1] " " # FIXME why I cant del space with 1st regex?
                    arr0[1] = arr1[2]
                }
            } else {
                arr0[1] = substr(arr0[1], length(_lp_bcodeindent))
            }
            print arr0[1] >> _LP_REDIRTO
            close(_LP_REDIRTO)
            _LP_REDIRTO = ""
        }
    }
}

function _lp_parse_icode(   arr) {
    if (match($0, /icode `([^`]+)`/, arr)) {
        if (_LP_REDIRTO) {
            print arr[1] >> _LP_REDIRTO
            close(_LP_REDIRTO)
            _LP_REDIRTO = ""
        }
    }
}

function _lp_join(sep, arr,   res) { # res is local var
    for (i=1; i<=length(arr); i++) {
        res = res (i!=1?sep:"") arr[i]
    }
    return res
}

# res is [dir, name, name-only, ext-with-dot]
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
        delete arr
        if (match(name, /(.*)(\.[^.]*$)/, arr)) {
            res[3] = arr[1]
            res[4] = arr[2]
        } else {
            res[3] = name
            res[4] = ""
        }
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
    _lp_parse_icode()
}
