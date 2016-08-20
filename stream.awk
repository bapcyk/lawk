BEGIN {
    _lp_prefix = "\\.\\."
    _lp_terminator = "[^ ,;:!?]"
    _lp_terms["redir"] = _lp_prefix ">" _lp_terminator "+"
    _lp_terms["subst"] = _lp_prefix "_" _lp_terminator "+"
    _lp_terms["def"] = _lp_prefix ":" _lp_terminator "+"
    _lp_terms["icode"] = "`.*`"
}

function _lp_extract_pat(pat, prn) {
    r = gensub(".*(" pat ").*", "\\1", 1)
    if (r == $0) r = ""
    if (prn && r) print r
    else return r
}

function _lp_extract_term(name, prn) {
    if (name == "bcode") {
        return _lp_extract_bcode(prn)
    } else {
        pat = _lp_terms[name]
        r = _lp_extract_pat(pat)
        if (r) r = name " " r
        if (prn && r) print r
        else return r
    }
}

# special case of term - block code
function _lp_extract_bcode(prn) {
    if (0 == _lp_bcodenl) {
        if (!$0) _lp_bcodenl = 1
    } else {
        indent = gensub("^([ \t]+).*", "\\1", "g")
        if (indent == $0) {
            indent = ""
        }
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

/\r/ { RS = "\r\n" }
{ _lp_extract_term("def", 1) }
#{ _lp_extract_term("subst", 1) }
{ _lp_extract_term("redir", 1) }
{ _lp_extract_term("icode", 1) }
{ _lp_extract_term("bcode", 1) }
