# external vars: OUTDIR - where to save redirected files, INDIR - where are .red
# files, MKDIR - command from tangle.mk to create dir (full path)
function _lp_cat(fpath,   buf, line) {
    while ((getline line < fpath) > 0) {
        buf = buf "\n" line
    }
    close(fpath)
    return buf
}

function _lp_subst(   re, defname, defpath, arr, buf) {
    if ($0 ~ /_LP_REDIR:/) {
        REDIRTO = OUTDIR "/" $2
    } else {
        while (match($0,  "\\.\\._([^ ,;:!?]+)", arr)) {
            # if find - replace, so subst all (recursively)
            defname = arr[1]
            defpath = INDIR "/" defname ".def"
            buf = _lp_cat(defpath)
            sub(/^[\r\n]+/, "", buf)
            sub(/[\r\n]+$/, "", buf)
            gsub("\\.\\._" defname, buf)
        }
        REPLBUF = REPLBUF "\n" $0
    }
}

function _lp_join(sep, arr,   res) { # res is local var
    for (i=1; i<=length(arr); i++) {
        res = res (i!=1?sep:"") arr[i]
    }
    return res
}

# res is [dir, name, name-only, ext-with-dot] (FIXME include from defs.awk)
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
    REPLBUF = ""
    REDIRTO = ""
}

END {
    if (!REDIRTO) {
        print "*** .red file without target file name!"
        exit 1
    }
    #print "!!!! TRY TO CREATE DIR: " MKDIR " " REDIRTO
    _lp_pathsplit(REDIRTO, res)
    system(MKDIR " " res[1])
    print REPLBUF > REDIRTO
}

{
    _lp_subst()
}
