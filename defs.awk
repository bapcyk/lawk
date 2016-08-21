# streams is input
# BUILDDIR is external var

function _lp_parse_redir(   arr, res, fname) {
    if (match($0, /redir \.\.>(.*)/, arr)) {
        if (_lp_pathsplit(arr[1], res)) {
            fname = BUILDDIR "/defs/" res[2]
            printf("_LP_REDIR: %s\n\n", arr[1]) > fname
            close(fname)
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

// {
    #print _lp_pathsplit($0, res)
    #print res[1], ">>", res[2]
    _lp_parse_redir()
}
