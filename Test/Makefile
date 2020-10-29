
name = copyfile

$(name).exe: $*.obj
	@jwlink format dos file \lib\omf\jmppm32.obj,$*.obj name $*.EXE lib \lib\omf\jmppm32.lib op map=$*.MAP,quiet

$(name).obj: $(name).asm $(name).mak
	@jwasm -c -nologo -Sg -Fl$* -Fo$* -I\asm\inc $(name).asm

