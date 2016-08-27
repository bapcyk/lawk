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
	$(eval MD:=$(addsuffix .md,$@))
	$(MKDIR) $(BUILDDIR)/$(MD)
	$(MKDIR) $(BUILDDIR)/$(MD)/def
	$(AWK) -f$(LIBDIR)/tokens.awk $(MD) > $(BUILDDIR)/$(MD)/tokens
	$(AWK) -vOUTDIR=$(BUILDDIR)/$(MD)/def \
		-f $(LIBDIR)/defs.awk $(BUILDDIR)/$(MD)/tokens
