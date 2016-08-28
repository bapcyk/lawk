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
