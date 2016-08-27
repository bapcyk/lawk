AWK := gawk
MKDIR := mkdir
RM := rm
CD := cd
CP := cp
ECHO := echo
MAKE := make


.SUFFIXES: .md .lpdeps
.PHONES: all deps clean
LPMAKEFILE := .LpMakefile

DEPS := $(patsubst %.md,%.lpdeps,$(LPSRCS))
# TODO make list of dirs where are defs/
# then add to LPMAKEFILE:
# _REDIRS += $(foreach d $(LPDIR) $(wildcard $d/*.lpredir))
# tangle: $(_REDIRS)
#     awk -f tangle.awk $*
#LPDIRS := 

.md.lpdeps:
	$(AWK) -v GENDEPS=1 -f stream.awk $< > $(patsubst %.md,%.lpdeps,$<)

clean:
	-$(RM) -rf build/
	-$(RM) -f *.lpdeps
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

define mk-tangle
$(AWK) -f tangle.awk build/.cache/$</defs/*.lpredir
endef

$(DEPS): $(LPSRCS)

deps: $(DEPS)

define pre-tangle
$(mk-stream)
$(mk-defs)
endef

all: deps build
	$(ECHO) "LPTARGETS :=" > $(LPMAKEFILE)
	$(ECHO) ".PHONES: tangle pre-tangle tangle" > $(LPMAKEFILE)
	$(ECHO) 'tangle: $(DEPS)' >> $(LPMAKEFILE)
	$(ECHO) -e '$(DEPS):\n\techo $$@' >> $(LPMAKEFILE)
	$(ECHO) "include lp.mk" >> $(LPMAKEFILE)
	$(ECHO) "include $(DEPS)" >> $(LPMAKEFILE)
	$(ECHO) 'pre-tangle: $$(LPTARGETS)' >> $(LPMAKEFILE)
	$(MAKE) -f $(LPMAKEFILE) pre-tangle tangle
