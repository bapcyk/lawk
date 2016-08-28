# Commands
#-------------------------------------------------------------------------------
AWK := gawk
MKDIR := mkdir -p
RM := rm
CD := cd
CP := cp
ECHO := echo
MAKE := make


# Paths and related
#-------------------------------------------------------------------------------
BUILDDIR := build
LIBDIR ?= ../src


# Files
#-------------------------------------------------------------------------------
# SRCNAMES - names of .md files (without ext - to force as nonexistent requisities,
# other way is to add them into .PHONY)
SRCNAMES := $(patsubst %.md,%,$(wildcard *.md))
# REDNAMES - names of .red files (without ext - to force as nonexistent requisities,
# other way is to add them into .PHONY); INDIR is external var where is def/
REDNAMES := $(patsubst %.red,%,$(wildcard $(BUILDDIR)/$(INDIR)/.def/*.red))


# Goals
# rec- means recursive
#-------------------------------------------------------------------------------
.PHONY: all clean mk-build-dir tangle-all rec-tangle-all rec-tangle-one


all: mk-build-dir $(SRCNAMES) tangle-all

rec-tangle-all: $(SRCNAMES)

clean:
	$(RM) -rf $(BUILDDIR)

mk-build-dir:
	$(MKDIR) $(BUILDDIR)

tangle-all: $(SRCNAMES)
	$(MAKE) TANGLEALL=1 rec-tangle-all --no-print-directory

rec-tangle-one: $(REDNAMES)

$(REDNAMES):
	$(eval RED:=$(addsuffix .red,$@))
# MD is got from rec-tangle-one make call variable MD
	$(AWK) -vINDIR=$(dir $(RED)) -vOUTDIR=$(BUILDDIR)/$(MD) -vMKDIR='$(MKDIR)' \
		-f$(LIBDIR)/lib.awk -f$(LIBDIR)/tangle.awk $(RED)

ifdef TANGLEALL
$(SRCNAMES):
	$(eval MD:=$(addsuffix .md,$@))
	$(MAKE) MD=$(MD) INDIR=$(addsuffix .md,$@) rec-tangle-one
else
$(SRCNAMES):
	$(eval MD:=$(addsuffix .md,$@))
	$(MKDIR) $(BUILDDIR)/$(MD)
	$(MKDIR) $(BUILDDIR)/$(MD)/.def
	$(AWK) -f$(LIBDIR)/tokens.awk $(MD) > $(BUILDDIR)/$(MD)/.tokens
	$(AWK) -vOUTDIR=$(BUILDDIR)/$(MD)/.def \
		-f$(LIBDIR)/lib.awk -f$(LIBDIR)/defs.awk $(BUILDDIR)/$(MD)/.tokens
endif
