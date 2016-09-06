function _lp_parse_bcode(eof,  ind) {
    match($0, "^[ \t]+"); ind = substr($0, RSTART, RLENGTH)
    match($0, /[^ \t\r]/); _lp_emptyline = (RLENGTH == -1)
    ind = _lp_emptyline? 0:length(ind) + 1
    #print "_lp_inbcode:", _lp_inbcode, "ind:", ind, "_lp_indent:", _lp_indent, substr($0, 0, 60)
    if (_lp_inbcode) {
        if (eof || 1==ind) {
            _lp_inbcode = 0
            print "ecode"
        } else {
            print "bcode", substr($0, _lp_indentln0)
        }
    } else {
        if (0==_lp_indent && ind>1) {
            _lp_inbcode = 1
            _lp_indentln0 = ind
            print "bcode", substr($0, _lp_indentln0)
        }
    }
    _lp_indent = ind
    return _lp_inbcode
}

function _lp_parse() {
    if (!_lp_parse_bcode()) {
        while ($0) {
            if (match($0, "^" redir_pt)) print "redir", substr($0, RSTART, RLENGTH)
            else if (match($0, "^" subst_pt)) print "icode", substr($0, RSTART, RLENGTH)
            else if (match($0, "^" defin_pt)) print "defin", substr($0, RSTART, RLENGTH)
            else if (match($0, "^" icode_pt)) print "icode", substr($0, RSTART, RLENGTH)
            $0 = substr($0, 2)
        }
    }
}

/\r/ { RS = "\r\n" }
{
    _lp_parse()
}

BEGIN {
    _lp_indent = -1
}
END {
    _lp_parse_bcode(1)
}
