#
# HIMEMSX.EXE is build with JWasm.
#

!ifndef DEBUG
DEBUG=0
!endif

NAME=HimemSX
!if $(DEBUG)
OUTD=Debug
OPTD=-D_DEBUG
!else
OUTD=Release
OPTD=
!endif

ALL: $(OUTD) $(OUTD)\$(NAME).exe

$(OUTD):
	@mkdir $(OUTD)

$(OUTD)\$(NAME).exe: $(NAME).asm Makefile
	@jwasm.exe -mz -nologo $(OPTD) -D?ALTSTRAT=1 -Sg -Fl$*.lst -Fo$*.exe $(NAME).asm

clean:
	@erase $(OUTD)\*.exe
