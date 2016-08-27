# Commands
#-------------------------------------------------------------------------------
AWK := gawk
MKDIR := mkdir
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
SRCNAMES := $(patsubst %.md,%,$(wildcard *.md))


# Goals
#-------------------------------------------------------------------------------
.PHONY: all pre clean mk-build-dir tangle

all: pre

pre: mk-build-dir $(SRCNAMES) tangle

post: $(SRCNAMES)

clean:
	$(RM) -rf $(BUILDDIR)

mk-build-dir:
	$(MKDIR) $(BUILDDIR)

tangle: $(SRCNAMES)
	$(MAKE) POST=1 post --no-print-directory

ifndef POST
$(SRCNAMES):
	$(eval MD:=$(addsuffix .md,$@))
	$(MKDIR) $(BUILDDIR)/$(MD)
	$(MKDIR) $(BUILDDIR)/$(MD)/def
	$(AWK) -f$(LIBDIR)/tokens.awk $(MD) > $(BUILDDIR)/$(MD)/tokens
	$(AWK) -vOUTDIR=$(BUILDDIR)/$(MD)/def \
		-f $(LIBDIR)/defs.awk $(BUILDDIR)/$(MD)/tokens
else
$(SRCNAMES):
	$(eval MD:=$(addsuffix .md,$@))
	$(eval REDS:=$(wildcard build/$(MD)/def/*.red))
	@echo FOUND REDS FOR $@: $(REDS)
endif
