# LAWK - AWK Literate Programming Personal Tool

## What is it?

Literate programming is an approach to programming introduced by Donald Knuth in
which a program is given as an explanation of the program logic in a natural
language, such as English, interspersed with snippets of macros and traditional
source code, from which a compilable source code can be generated (see
http://literateprogramming.com).

LAWK is the simple literate programming tool for personal usage (no
collaboration features). For collaboration nanolp can be used (see
https://github.com/bapcyk/nanolp).

Input files are markdown, output - any one. Generation of ctags (for VIM) are
supported.

## How is it look?

You writes not program but detailed story which can contains pictures, links,
schemes, diagrams, etc because it is in markdown then you create simple
Makefile:

    LIBDIR = ../src
    include ../src/tangle.mk

where `LIBDIR` is the path to directory of LAWK (where is placed tangle.mk and
others) and call it:

    make clean all

which will produce all output files (.c, .h, .py, any!)

Markdown files must have `.md` extension and to contain LAWK instructions:

* ..:SOMETHING - to define some code (inline or block)
* .._SOMETHING - to paste here early defined code
* ..>FILE - the same as `..:` but save its content to file `FILE`

where `SOMETHING` is string without symbols: `, ;:!?` (they are treated as end
of `SOMETHING`). See example in `example/` folder.

Inline and block code thunks are in standard markdown format. Definition body is
such thunk which follows the definition of `SOMETHING` (with `..:`).

If you need to jump over definitions, you should generate ctags file (default
name is `lp.ctags):

    make ctags

and then to jump to some tag:

    vim -t sometag

this was tested under Vim (but does not work yet for `less`); Emacs ETAGS is in
plans.

## Testing

Author tested this under Windows with cyrillic/ASCII .md files (see `example/`)
with MinGW environment.

All paths should not contains spaces and other special symbols. Tags was tested
with Vim (tags file is unsorted).

## Requirement

They are POSIX compatible: awk, mkdir, rm, make. Their path and syntax is
defined in `tangle.mk` as:

    AWK := gawk
    MKDIR := mkdir -p
    RM := rm
    MAKE := make

## Licence

GNU GPL

Author: bapcyk, 2016
