AWK := gawk
MKDIR := mkdir


.SUFFIXES: .md

all:
	-@$(MKDIR) build
	-@$(MKDIR) build/.cache
	@$(AWK) -f stream.awk example.md > build/.cache/stream
