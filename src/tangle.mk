# Commands
#-------------------------------------------------------------------------------
AWK := gawk
MKDIR := mkdir -p
RMDIR := rm -rf
MAKE := make
RM := rm
PANDOC := pandoc


# Paths and related
#-------------------------------------------------------------------------------
BUILDDIR := .cache
LIBDIR ?= ../src
CTAGSFILE := lp.ctags


# Files
#-------------------------------------------------------------------------------
# SRCNAMES - names of .md files (without ext - to force as nonexistent requisities,
# other way is to add them into .PHONY)
SRCNAMES := $(patsubst %.md,%,$(wildcard *.md))
# REDNAMES - names of .red files (without ext - to force as nonexistent requisities,
# other way is to add them into .PHONY); INDIR is external var where is def/
REDNAMES := $(patsubst %.red,%,$(wildcard $(BUILDDIR)/$(INDIR)/.def/*.red))
# HTML files
HTMLS := $(addsuffix .html,$(SRCNAMES))


.SUFFIXES: .md .html

.md.html:
	$(PANDOC) -s $< -o $@


# Goals
# rec- means recursive
#-------------------------------------------------------------------------------
.PHONY: all clean mk-build-dir rm-build-dir tangle-all rec-tangle-all \
		rec-tangle-one ctags weave


all: mk-build-dir $(SRCNAMES) tangle-all weave

rec-tangle-all: $(SRCNAMES)

clean: rm-build-dir
	-$(RM) $(CTAGSFILE)

rm-build-dir:
	$(RMDIR) $(BUILDDIR)

mk-build-dir:
	$(MKDIR) $(BUILDDIR)

tangle-all: $(SRCNAMES)
	$(MAKE) TANGLEALL=1 rec-tangle-all --no-print-directory

rec-tangle-one: $(REDNAMES)

$(REDNAMES):
	$(eval RED:=$(addsuffix .red,$@))
# MD is available from rec-tangle-one make call variable MD (now is not used)
	$(AWK) -vINDIR=$(dir $(RED)) -vOUTDIR=$(BUILDDIR)/.. -vMKDIR='$(MKDIR)' \
		-f$(LIBDIR)/lib.awk -f$(LIBDIR)/tangle.awk $(RED)

ifdef TANGLEALL
$(SRCNAMES):
	$(eval MD:=$(addsuffix .md,$@))
	$(MAKE) MD=$(MD) INDIR=$(addsuffix .md,$@) rec-tangle-one
#$(RMDIR) $(BUILDDIR)/$(MD) # do't remove for ctags
else
$(SRCNAMES):
	$(eval MD:=$(addsuffix .md,$@))
	$(MKDIR) $(BUILDDIR)/$(MD)
	$(MKDIR) $(BUILDDIR)/$(MD)/.def
	$(AWK) -f$(LIBDIR)/lib.awk -f$(LIBDIR)/tokens.awk $(MD) > $(BUILDDIR)/$(MD)/.tokens
	$(AWK) -vOUTDIR=$(BUILDDIR)/$(MD)/.def -f$(LIBDIR)/lib.awk	\
		-f$(LIBDIR)/defs.awk $(BUILDDIR)/$(MD)/.tokens
endif

ctags:
	$(eval TAGGED:=$(addsuffix .md,$(SRCNAMES)))
	@$(AWK) -f$(LIBDIR)/lib.awk -f$(LIBDIR)/tags.awk $(TAGGED) > $(CTAGSFILE)

weave: $(HTMLS)

x:
	@$(AWK) -f$(LIBDIR)/lib.awk -f$(LIBDIR)/parse.awk cons.md
