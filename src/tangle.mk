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
all: mk-build-dir $(SRCNAMES)

clean:
	$(RM) -rf $(BUILDDIR)

mk-build-dir:
	$(MKDIR) $(BUILDDIR)

$(SRCNAMES):
	$(MKDIR) $(BUILDDIR)/$(addsuffix .md,$@)
	$(MKDIR) $(BUILDDIR)/$(addsuffix .md,$@)/def
	$(AWK) -f$(LIBDIR)/tokens.awk $(addsuffix .md,$@) > $(BUILDDIR)/$(addsuffix .md,$@)/tokens
	$(AWK) -vOUTDIR=$(BUILDDIR)/$(addsuffix .md,$@)/def \
		-f $(LIBDIR)/defs.awk $(BUILDDIR)/$(addsuffix .md,$@)/tokens
