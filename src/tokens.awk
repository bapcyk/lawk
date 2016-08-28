# .md is input
BEGIN {
    _lp_prefix = "\\.\\."
    _lp_terminator = "[^ ,;:!?\r\n]"
    _lp_terms["redir"] = _lp_prefix ">" _lp_terminator "+"
    _lp_terms["subst"] = _lp_prefix "_" _lp_terminator "+"
    _lp_terms["defin"] = _lp_prefix ":" _lp_terminator "+"
    _lp_terms["icode"] = "`[^`]+`"
}

function _lp_extract_pat(pat) {
    match(_LP0, pat)
    if (RSTART) {
        r = substr(_LP0, RSTART, RLENGTH)
        _LP0 = gensub("(" pat ")", "", 1, _LP0)
        #print pat, "0::", x
        #print pat, "1::", _LP0
    } else {
        r = ""
    }
    return r
}

# special case of term - block code
function _lp_extract_bcode() {
    #print " ..", _LP0, _lp_bcodenl
    if (0 == _lp_bcodenl) {
        if (!$0) _lp_bcodenl = 1
    } else {
        indent = _lp_extract_pat("^[ \t]+")
        if (1 == _lp_bcodenl) {
            if (indent) {
                _lp_bcodeindent = indent
            } else {
            #print " .. kill-1", $0, _lp_bcodenl
                _lp_bcodenl = 0
                return
            }
        }
        if (indent >= _lp_bcodeindent || !$0) {
            r = "bcode " $0
            _lp_bcodenl++ # line number in bcode
            return r
        } else if ($0) {
            #print " .. ", $0, "kill-2", _lp_bcodenl
            #printf(" .. kill-2 %s '%s'->'%s' %d\n", $0, _lp_bcodeindent, indent, _lp_bcodenl)
            _lp_bcodenl = 0
            return
        }
    }
}

# special case - extract def and icode
function _lp_extract_icodep_1() {
    lp0 = _LP0
    def = _lp_extract_term("defin")
    code = _lp_extract_term("icode")
    if (def && code) {
        r = def "\n" code
    } else {
        r = ""
        _LP0 = lp0
    }
    return r
}

# special case - extract def and icode
function _lp_extract_icodep() {
    rs = ""
    while (1) {
        r = _lp_extract_icodep_1()
        if (!r) {
            return rs
        } else {
            rs = rs "\n" r
        }
    }
}

function _lp_extract_term(name) {
    if (name == "bcode") {
        return _lp_extract_bcode()
    } else if (name == "icode+") {
        return _lp_extract_icodep()
    } else {
        pat = _lp_terms[name]
        r = _lp_extract_pat(pat)
        if (r) r = name " " r
        return r
    }
}

function _lp_print(s) {
    if (s) {
        print s  # FIXME there are 1 line with spaces only!!
        #printf("%d '%s'\n", length(s), s)
        return 1
    } else {
        return 0
    }
}


function tokenize() {
    _lp_print(_lp_extract_term("icode+")) # eats all defs for icode
    _lp_print(_lp_extract_term("redir")) # XXX redir doesn't support several on one line!
    _lp_print(_lp_extract_term("defin")) # defs for bcode are lost only
    _lp_print(_lp_extract_term("bcode")) # XXX redir doesn't support inline definition block
}

{
    _LP0 = $0 # _LP0 are needed for multi-terms per line
}

/\r/ { RS = "\r\n" }
{
    tokenize()
}
