AWK := gawk
MKDIR := mkdir
RM := rm


.SUFFIXES: .md
.PHONES: all clean

clean:
	$(RM) -rf build/

build:
	$(MKDIR) build
	$(MKDIR) build/.cache

define mk-stream
$(MKDIR) build/.cache/$<
$(AWK) -f stream.awk $< > build/.cache/$</stream
endef

# FIXME for several sources!!!
tangle: example.md
	$(mk-stream)

all: build tangle
