AWK := gawk


.SUFFIXES: .md

all:
	@$(AWK) -f stream.awk example.md
