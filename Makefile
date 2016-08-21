AWK := gawk
MKDIR := mkdir
RM := rm
CD := cd


.SUFFIXES: .md
.PHONES: all clean

clean:
	$(RM) -rf build/

build:
	$(MKDIR) build
	$(MKDIR) build/.cache

define mk-stream
$(MKDIR) build/.cache/$<
$(AWK) -f stream.awk $< > build/.cache/$</stream
endef

define mk-defs
$(MKDIR) build/.cache/$</defs
$(AWK) -v 'BUILDDIR=build/.cache/$<' -f defs.awk build/.cache/$</stream
endef

# FIXME for several sources!!!
tangle: example.md
	$(mk-stream)
	$(mk-defs)

all: build tangle
