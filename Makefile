AWK := gawk
MKDIR := mkdir
RM := rm
CD := cd

LPSRCS = example0.md example1.md


.SUFFIXES: .md
.PHONES: all clean

clean:
	$(RM) -rf build/

build:
	$(MKDIR) build
	$(MKDIR) build/.cache

define mk-deps
	$(AWK) -v GENDEPS=1 -f stream.awk $<
endef

define mk-stream
$(MKDIR) build/.cache/$<
$(AWK) -f stream.awk $< > build/.cache/$</stream
endef

define mk-defs
$(MKDIR) build/.cache/$</defs
$(AWK) -v 'BUILDDIR=build/.cache/$<' -f defs.awk build/.cache/$</stream
endef

# FIXME for several sources!!!
test: example0.md
	$(mk-stream)
	$(mk-defs)

all: build test
