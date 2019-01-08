# DEBUG=1 for Debugging options
!ifndef DEBUG
DEBUG=0
!endif

# 32-bit is C:\Program Files, 64-bit is C:\Program Files (x86)
PROGRAMFILES=C:\Program Files (x86)

NUL=
D=\$(NUL)

# To disable print/convert, set VIEWONLY=1
!ifndef VIEWONLY
VIEWONLY=0
!endif

BINDIR=.\bin
OBJDIR=.\obj
SRCDIR=.\src
SRCWINDIR=.\srcwin

COMMONBASE=$(PROGRAMFILES)\Windows Kits\10
PLATLIBDIR=$(COMMONBASE)\Lib\10.0.17763.0\um\x64
UCRTLIBDIR=$(COMMONBASE)\Lib\10.0.17763.0\ucrt\x64
PLATINCDIR=$(COMMONBASE)\Include\10.0.17763.0\um\

DEVBASE   =$(PROGRAMFILES)\Microsoft Visual Studio\2017\Community
COMPBASE = $(DEVBASE)\VC
COMPDIR  = $(COMPBASE)\Tools\MSVC\14.16.27023\bin\Hostx64\x64
INCDIR   = $(COMPBASE)\Tools\MSVC\14.16.27023\include
LIBDIR   = $(COMPBASE)\Tools\MSVC\14.16.27023\lib\x64

# MSVC 8 (2005) warns about deprecated common functions like fopen.
VC8WARN=/wd4996

CDEFS=-D_Windows -D__WIN64__  -I"$(PLATINCDIR)" -I"$(INCDIR)"
CFLAGS=$(CDEFS) /MT /nologo $(VC8WARN)

LINKMACHINE=X64
WINEXT=64
MODEL=64

!if $(DEBUG)
DEBUGLINK=/DEBUG
CDEBUG=/Zi
!endif

# Microsoft Visual Studio 2017 native compiler
#CC =      "$(COMPDIR)\cl" $(CDEBUG)
#CPP =     "$(COMPDIR)\cl" $(CDEBUG)
#LINK =    "$(COMPDIR)\link"
CC =       "$(COMPDIR)\cl" $(CDEBUG)
CPP =      "$(COMPDIR)\cl" $(CDEBUG)
LINK =     "$(COMPDIR)\link"

!if $(VIEWONLY)
VIEWFLAGS=-DVIEWONLY -DPREREGISTER
!else
VIEWFLAGS=
!endif

COMP=   $(CC) -I$(SRCDIR) -I$(SRCWINDIR) -I$(OBJDIR) $(CFLAGS) $(VIEWFLAGS)
CPPCOMP=$(CC) -I$(SRCDIR) -I$(SRCWINDIR) -I$(OBJDIR) $(CFLAGS) $(VIEWFLAGS)


SRC=$(SRCDIR)\$(NUL)
SRCWIN=$(SRCWINDIR)\$(NUL)

OD=$(OBJDIR)\$(NUL)
BD=$(BINDIR)\$(NUL)

OBJ=.obj
EXE=.exe
CO=-c
FOO=-Fo$(OD)

LOUT=/OUT:
LCONSOLE=/SUBSYSTEM:CONSOLE 
LIBRSP=@$(OD)lib.rsp

target: $(BD)gsprint.exe

#################################################################
# Common

#################################################################
# Windows files

$(OD)lib.rsp: makefile
	echo "$(PLATLIBDIR)$(D)kernel32.lib"   > $(OD)lib.rsp
	echo "$(PLATLIBDIR)$(D)user32.lib"    >> $(OD)lib.rsp
	echo "$(PLATLIBDIR)$(D)gdi32.lib"     >> $(OD)lib.rsp
	echo "$(PLATLIBDIR)$(D)shell32.lib"   >> $(OD)lib.rsp
	echo "$(PLATLIBDIR)$(D)comdlg32.lib"  >> $(OD)lib.rsp
	echo "$(PLATLIBDIR)$(D)winspool.lib"  >> $(OD)lib.rsp
	echo "$(PLATLIBDIR)$(D)advapi32.lib"  >> $(OD)lib.rsp
	echo "$(PLATLIBDIR)$(D)ole32.lib"     >> $(OD)lib.rsp
	echo "$(PLATLIBDIR)$(D)uuid.lib"      >> $(OD)lib.rsp
	echo "$(UCRTLIBDIR)$(D)libucrt.lib"   >> $(OD)lib.rsp
	echo "$(LIBDIR)$(D)libcmt.lib"        >> $(OD)lib.rsp
	echo "$(LIBDIR)$(D)vcruntime.lib"     >> $(OD)lib.rsp
	echo /NODEFAULTLIB:LIBC.lib           >> $(OD)lib.rsp



$(OD)gvwfile$(OBJ): $(SRCWIN)gvwfile.c $(SRC)gvcfile.h
	$(COMP) $(FOO)gvwfile$(OBJ) $(CO) $(SRCWIN)gvwfile.c

$(OD)gvwdib$(OBJ): $(SRCWIN)gvwdib.cpp $(HDRS)
	$(COMP) $(FOO)gvwdib$(OBJ) $(CO) $(SRCWIN)gvwdib.cpp

$(OD)gvwpdib$(OBJ): $(SRCWIN)gvwpdib.cpp $(HDRS)
	$(COMP) $(FOO)gvwpdib$(OBJ) $(CO) $(SRCWIN)gvwpdib.cpp


$(BD):
	if NOT EXIST "$@" mkdir "$@"
$(OD):
	if NOT EXIST "$@" mkdir "$@"


GSPRINTOBJS=$(OD)gsprint$(OBJ) $(OD)gvwfile$(OBJ) $(OD)gvwdib$(OBJ) $(OD)gvwpdib$(OBJ)

$(BD)gsprint.exe: $(BD) $(GSPRINTOBJS) $(OD)lib.rsp
	$(LINK) $(DEBUGLINK) $(LCONSOLE) $(LOUT)$(BD)xgsprint.exe $(GSPRINTOBJS) $(LIBRSP)


$(OD)gsprint$(OBJ): $(OD) $(SRCWIN)gsprint.cpp $(SRC)gvcfile.h $(SRCWIN)gvwdib.h $(SRCWIN)gvwpdib.h
	$(CPPCOMP) $(FOO)gsprint$(OBJ) $(CO) $(SRCWIN)gsprint.cpp


#################################################################
