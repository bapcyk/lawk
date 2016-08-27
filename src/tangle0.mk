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
TOKS := $(patsubst %.md,%.tok,$(wildcard *.md))
CACHEDIRS := $(addprefix $(BUILDDIR)/,$(SRCS))
DEFDIRS := $(addsuffix /def,$(CACHEDIRS))

x:
	echo $(TOKS)

# Suffixes and related
#-------------------------------------------------------------------------------
.SUFFIXES: .md .tok

.md.tok:
	$(AWK) -f $(LIBDIR)/tokens.awk $< > $(BUILDDIR)/$</$(patsubst %.md,%.tok,$<)


# Goals
#-------------------------------------------------------------------------------
.PHONY:

default: all

mk-build-dir:
	$(MKDIR) $(BUILDDIR)

rm-build-dir:
	$(RM) -rf $(BUILDDIR)

$(CACHEDIRS):
	$(MKDIR) $@
	$(AWK) -f $(LIBDIR)/tokens.awk $< > $(BUILDDIR)/$</$(patsubst %.md,%.tok,$<)


$(DEFDIRS): $(TOKS)
	$(MKDIR) $@
	$(AWK) -v OUTDIR=$@ -f $(LIBDIR)/defs.awk $(BUILDDIR)/$(patsubst %.tok,%.md,$<)/$<

#x:

# Main goals
clean: rm-build-dir

all: mk-build-dir $(CACHEDIRS) $(TOKS) $(DEFDIRS)
