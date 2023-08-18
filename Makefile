#
# Makefile for 'lcal' under Unix/Linux, DOS+DJGPP, and DOS/Windows+Cygwin
# 
# Use these commands:
# 
#    Unix/Linux: make
# 
#    DOS+DJGPP: make OS=DJGPP
# 
# 
# v2.0.0: Bill Marr
#    
#    Accommodate the fact that the use of 'pcalinit.{c,h}' and 'lcal_{p,l}.ps'
#    is no longer needed.  PostScript output is now directly generated by C
#    code, without the use of PostScript templates (1 each for portrait and
#    landscape orientations) which were converted to a C header file.
#    
#    Lots of cleanups. Basically, this file has been altered to match the
#    improved 'pcal' 'Makefile'.
#    
#    Expand the explanation and provide more examples of the use of the 
#    timezone setting.
#    
#    Support DOS+DJGPP build environment.  (Basic MS-DOS is now supported via
#    'Makefile.DOS'.)
#    
#    Removed obsolete 'make' targets ('uuencode', 'compress') and related
#    setup.
#    
#    Removal of various other obsolete content (settings, etc).
#    
#    Enable warnings on compilation.
#    
#    Fix backwards sign on sample values for 'D_YOFFSET'.
#    
#    Remove the now-unneeded 'VERSION = x.y' declaration.
# 
# v1.2.0: Andrew Rogers
#    
#    "make uuencode" creates compressed/uuencoded tar file
#    
#    "make compress" creates compressed tar file
#    
#    "make clean" leaves lcal intact but removes other by-products
#    
#    "make clobber" blows everything away
#    
#    "make fresh" rebuilds from scratch
#    

# -----------------------------------------------------------------------------
# 
# Depending on whether we're compiling for Unix/Linux or DOS+DJGPP, use
# appropriate values for the OS name, the 'build environment' flag, the names
# of the executable files, the compiler, and the 'PACK' value.
# 
# The 'PACK' value is used for packing the 'man' page.  Note that setting
# 'PACK' to ":" will cause no packing to be done; otherwise, choose
# "compress", "pack", or "gzip" as your system requires.
# 
ifeq ($(OS),DJGPP)   # DOS+DJGPP
	OS_NAME = "DOS+DJGPP"
	D_BUILD_ENV	= -DBUILD_ENV_DJGPP
	LCAL		= lcal.exe
	CC		= gcc
	PACK =		:
else   # Unix
	OS_NAME = "Unix"
	D_BUILD_ENV	= -DBUILD_ENV_UNIX
	LCAL		= lcal
	CC		= /usr/bin/gcc
	PACK		= gzip
	PREFIX          = /usr/local
endif

# 
# Define various directories for the following items:
# 
#    - source code
#    - object code
#    - installed 'lcal' executable
#    - documentation
#    - 'man' pages
# 
# Unlike 'pcal', the simpler 'lcal' program really doesn't necessitate the use
# of separate directories for all these items.  Therefore, the source, object,
# executable, and documentation directories are all set to the 'current'
# directory.
# 
SRCDIR	= .
OBJDIR	= .
EXECDIR	= .
DOCDIR	= .

# 
# Compiling for DOS+DJGPP requires different directories for the installed
# executable and the 'man' pages.  Unix uses the values shown below.
# 
ifeq ($(OS),DJGPP)   # DOS+DJGPP
	BINDIR = $(DJDIR)/bin
	MANDIR = $(DJDIR)/man/man1
else   # Unix
	BINDIR = $(PREFIX)/bin
	MANDIR = $(PREFIX)/share/man/man1
endif

OBJECTS = $(OBJDIR)/lcal.o

# ------------------------------------------------------------------
# 
# Site-specific defaults which may be overridden here (cf. lcaldefs.h);
# uncomment the examples below and/or change them to your liking
# 

# redefine title and date fonts
# D_TITLEFONT = '-DTITLEFONT="Helvetica-Bold"'
# D_DATEFONT  = '-DDATEFONT="Helvetica-Bold"'

# 
# Specify the timezone ('-z') for determining the correct day when
# calculating the moon phases:
#    
#    "0"    = UTC/GMT (default)
#    "5"    = New York EST
#    "-3"   = Moscow
#    "-5.5" = India
# 
# D_TIMEZONE = '-DTIMEZONE="5 [New York EST]"'
# D_TIMEZONE = '-DTIMEZONE="4 [New York EDT]"'
# D_TIMEZONE = '-DTIMEZONE="8 [Los Angeles PST]"'
# D_TIMEZONE = '-DTIMEZONE="7 [Los Angeles PDT]"'
# D_TIMEZONE = '-DTIMEZONE="-3 [Moscow]"'
# D_TIMEZONE = '-DTIMEZONE="-5.5 [India]"'

# specify local default X/Y offsets
# D_XOFFSET = '-DX_OFFSET="-20/20"'
# D_YOFFSET = '-DY_OFFSET="20/-20"'

# ------------------------------------------------------------------

COPTS = $(D_TITLEFONT) $(D_DATEFONT) $(D_TIMEZONE) $(D_XOFFSET) $(D_YOFFSET) \
	$(D_BUILD_ENV)

# 
# Depending on whether we're compiling for Unix/Linux or DOS+DJGPP, use
# appropriate values as flags for the C compiler.
# 
#    '-O2' enables a 2nd-level code optimization
#    '-Wall' enables many compile-time warning messages
#    '-W' enables some additional compile-time warning messages
# 
ifeq ($(OS),DJGPP)   # DOS+DJGPP
	CFLAGS = -Wall -W
else   # Unix
	CFLAGS = -O2 -Wall -W
endif

$(EXECDIR)/$(LCAL):	$(OBJECTS)
	$(CC) $(LDFLAGS) -o $(EXECDIR)/$(LCAL) $(OBJECTS) -lm
	@ echo Build of $(LCAL) for $(OS_NAME) completed.

$(OBJDIR)/lcal.o:	$(SRCDIR)/lcal.c $(SRCDIR)/lcaldefs.h
	$(CC) $(CFLAGS) $(COPTS) -o $@ -c $(SRCDIR)/lcal.c

# 
# This target will delete everything except the 'lcal' executable.
# 
clean:
	rm -f $(OBJECTS) \
		$(DOCDIR)/lcal-help.ps \
		$(DOCDIR)/lcal-help.html \
		$(DOCDIR)/lcal-help.txt

# 
# This target will delete everything, including the 'lcal' executable.
# 
clobber: clean
	rm -f $(EXECDIR)/$(LCAL)

# 
# This target will delete everything and rebuild 'lcal' from scratch.
# 
fresh:	clobber $(LCAL)

man:	$(DOCDIR)/lcal.man
	groff -man -Tps $(DOCDIR)/lcal.man >$(DOCDIR)/lcal-help.ps
	groff -man -Thtml $(DOCDIR)/lcal.man >$(DOCDIR)/lcal-help.html
	groff -man -Tascii $(DOCDIR)/lcal.man >$(DOCDIR)/lcal-help.txt

install:	$(EXECDIR)/$(LCAL) man
	cp $(EXECDIR)/$(LCAL) $(BINDIR)
	if [ -d $(MANDIR) ]; then \
		cp $(DOCDIR)/lcal.man $(MANDIR)/lcal.1; \
		$(PACK) $(MANDIR)/lcal.1; \
	fi

