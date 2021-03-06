# streams is input
# OUTDIR is external var

function _lp_parse_redir(   arr, res) {
    if (match($0, /redir \.\.>(.*)/, arr)) {
        if (_lp_pathsplit(arr[1], res)) {
            _LP_REDIRTO = OUTDIR "/" res[2] ".red"
            printf("_LP_REDIR: %s\n", arr[1]) > _LP_REDIRTO
            close(_LP_REDIRTO)
        }
    }
}

function _lp_parse_defin(   arr, res) {
    if (match($0, /defin \.\.:(.*)/, arr)) {
        if (_lp_pathsplit(arr[1], res)) {
            _LP_REDIRTO = OUTDIR "/" res[2] ".def"
            printf("", arr[1]) > _LP_REDIRTO
            close(_LP_REDIRTO)
        }
    }
}

function _lp_parse_bcode(   arr) {
    if (match($0, /bcode (.*)/, arr)) {
        if (_LP_REDIRTO) {
            print arr[1] >> _LP_REDIRTO
        }
    } else if ($0 == "ecode") {
        close(_LP_REDIRTO)
        _LP_REDIRTO = ""
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

BEGIN {
    _LP_REDIRTO = ""
}
{
    _lp_parse_redir()
    _lp_parse_defin()
    _lp_parse_bcode()
    _lp_parse_icode()
}
