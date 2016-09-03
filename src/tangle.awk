# external vars: OUTDIR - where to save redirected files, INDIR - where are .red
# files, MKDIR - command from tangle.mk to create dir (full path)
function _lp_cat(fpath,   buf, line) {
    while ((getline line < fpath) > 0) {
        buf = buf "\n" line
    }
    close(fpath)
    return buf
}

function _lp_subst(   defname, defpath, arr, buf) {
    if ($0 ~ /_LP_REDIR:/) {
        REDIRTO = OUTDIR "/" $2
    } else {
        while (match($0,  "\\.\\._([a-zA-Z0-9.\\-]+)", arr)) {
            # if find - replace, so subst all (recursively)
            defname = arr[1]
            defpath = INDIR "/" defname ".def"
            buf = _lp_cat(defpath)
            sub(/^[\r\n]+/, "", buf)
            sub(/[\r\n]+$/, "", buf)
            gsub("\\.\\._" defname, buf)
        }
        REPLBUF = REPLBUF (!REPLBUF?"":"\n") $0
    }
}


BEGIN {
    REPLBUF = ""
    REDIRTO = ""
}

END {
    if (!REDIRTO) {
        print "*** .red file without target file name!"
        exit 1
    }
    _lp_pathsplit(REDIRTO, res)
    system(MKDIR " " res[1])
    print REPLBUF > REDIRTO
}

{
    _lp_subst()
}
