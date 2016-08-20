BEGIN {
    _lp_prefix = "\\.\\."
    _lp_terminator = "[^ ,;:!?]"
    _lp_terms["redir"] = _lp_prefix ">" _lp_terminator "+"
    _lp_terms["subst"] = _lp_prefix "_" _lp_terminator "+"
    _lp_terms["def"] = _lp_prefix ":" _lp_terminator "+"
    _lp_terms["icode"] = "`[^`]+`"
}

function _lp_extract_pat(pat, prn) {
    match(_LP0, pat)
    if (RSTART) {
        r = substr(_LP0, RSTART, RLENGTH)
        _LP0 = gensub("(" pat ")", "", 1, _LP0)
        #print pat, "0::", x
        #print pat, "1::", _LP0
    } else {
        r = ""
    }
    if (prn && r) print r
    else return r
}

# special case of term - block code
function _lp_extract_bcode(prn) {
    if (0 == _lp_bcodenl) {
        if (!$0) _lp_bcodenl = 1
    } else {
        indent = _lp_extract_pat("^([ \t]+).*")
        if (1 == _lp_bcodenl) {
            if (indent) {
                _lp_bcodeindent = indent
            } else {
                _lp_bcodenl = 0
                return
            }
        }
        if (indent >= _lp_bcodeindent || !$0) {
            r = "bcode " $0
            if (prn) print r
            else return r
        } else if ($0) {
            _lp_bcodenl = 0
            return
        }
        _lp_bcodenl++ # line number in bcode
    }
}

# special case - extract def and icode
function _lp_extract_icodep_1(prn) {
    lp0 = _LP0
    def = _lp_extract_term("def")
    code = _lp_extract_term("icode")
    if (def && code) {
        r = "icode+ " def " " code
    } else {
        r = ""
        _LP0 = lp0
    }
    if (prn && r) print r
    else return r
}

# special case - extract def and icode
function _lp_extract_icodep(prn) {
    rs = ""
    while (1) {
        r = _lp_extract_icodep_1()
        if (!r) {
            if (prn) { print rs; return }
            else return rs
        } else {
            rs = rs "\n" r
        }
    }
}

# special case - extract def and bcode
function _lp_extract_bcodep(prn) {
    lp0 = _LP0
    def = _lp_extract_term("def")
    code = _lp_extract_term("bcode")
    if (def && code) {
        r = "bcode+ " def " " code
    } else {
        r = ""
        _LP0 = lp0
    }
    if (prn && r) print r
    else return r
}

function _lp_extract_term(name, prn) {
    if (name == "bcode") {
        return _lp_extract_bcode(prn)
    } else if (name == "icode+") {
        return _lp_extract_icodep(prn)
    } else if (name == "bcode+") {
        return _lp_extract_bcodep(prn)
    } else {
        pat = _lp_terms[name]
        r = _lp_extract_pat(pat)
        if (r) r = name " " r
        if (prn && r) print r
        else return r
    }
}


{ _LP0 = $0 }
/\r/ { RS = "\r\n" }
{
    _lp_extract_term("icode+", 1)
    _lp_extract_term("redir", 1)
}
