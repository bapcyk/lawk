function _lp_tags(   cmd, tagname, arr) {
    while (match($0,  "\\.\\.([:>])([a-zA-Z0-9.\\-\\/]+)", arr)) {
        cmd = arr[1]
        tagname = arr[2]
        printf("%s\t%s\t/%s/;\"\t%s\n", tagname, FILENAME, "\\.\\." cmd tagname, "v")
        $0 = substr($0, RSTART+RLENGTH)
    }
}

BEGIN {
    print "!_TAG_FILE_FORMAT	2	/extended format; --format=1 will not append ;\" to lines/"
    print "!_TAG_FILE_SORTED	0	/0=unsorted, 1=sorted, 2=foldcase/"
    print "!_TAG_PROGRAM_AUTHOR	Darren Hiebert	/dhiebert@users.sourceforge.net/"
    print "!_TAG_PROGRAM_NAME	Exuberant Ctags	//"
    print "!_TAG_PROGRAM_URL	http://ctags.sourceforge.net	/official site/"
    print "!_TAG_PROGRAM_VERSION	5.8	//"
}

{
    _lp_tags()
}
