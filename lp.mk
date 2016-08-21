AWK := gawk
MKDIR := mkdir
RM := rm
CD := cd
CP := cp
ECHO := echo
MAKE := make


.SUFFIXES: .md .deps
.PHONES: all deps clean
LPMAKEFILE := .LpMakefile

DEPS := $(patsubst %.md,%.deps,$(LPSRCS))

.md.deps:
	$(AWK) -v GENDEPS=1 -f stream.awk $< > $(patsubst %.md,%.deps,$<)

clean:
	-$(RM) -rf build/
	-$(RM) -f *.deps
	-$(RM) -f $(LPMAKEFILE)

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

define tangle
$(mk-stream)
$(mk-defs)
endef

all: deps build
	$(ECHO) "LPTARGETS :=" > $(LPMAKEFILE)
	$(ECHO) ".PHONES: tangle" > $(LPMAKEFILE)
	$(ECHO) "include lp.mk" >> $(LPMAKEFILE)
	$(ECHO) "include $(DEPS)" >> $(LPMAKEFILE)
	$(ECHO) 'tangle: $$(LPTARGETS)' >> $(LPMAKEFILE)
	$(MAKE) -f $(LPMAKEFILE) tangle
