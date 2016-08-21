AWK := gawk
MKDIR := mkdir
RM := rm
CD := cd
CP := cp

LPSRCS = example0.md example1.md


.SUFFIXES: .md .deps
.PHONES: all clean deps

DEPS := $(patsubst %.md,%.deps,$(LPSRCS))

.md.deps:
	$(AWK) -v GENDEPS=1 -f stream.awk $< > $(patsubst %.md,%.deps,$<)

clean:
	-$(RM) -rf build/
	-$(RM) -f *.deps

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

$(DEPS): $(LPSRCS)

deps: $(DEPS)

# FIXME for several sources!!!
test: example0.md
	$(mk-stream)
	$(mk-defs)

all: build test
