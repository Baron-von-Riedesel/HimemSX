
name = copyfile

$(name).exe: $*.obj
	@jwlink format dos file \hx\LibOMF\jmppm32.obj,$*.obj name $*.EXE lib \hx\LibOMF\jmppm32.lib op map=$*.MAP,quiet

$(name).obj: $(name).asm
	@jwasm -nologo -Fl$* -Fo$* $(name).asm

