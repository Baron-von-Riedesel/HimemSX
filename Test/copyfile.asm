
;*** copy a file

	.386
	.MODEL SMALL
	option proc:private

?TRAPI13 equ 0

CStr macro text:vararg
local sym
	.const
sym db text,0
	.code
	exitm <offset sym>
endm

	public __pMoveHigh	;avoid being moved in extended memory
@flat	equ <gs>

if ?TRAPI13
_TEXT16 segment use16 para public 'CODE'

dwOldInt13rm	dd 0
dwReads			dd 0
dwRdSecs		dd 0
dwWrites		dd 0
dwWrSecs		dd 0

myint13rm:
	cmp ah,02h
	jz readcnt1
	cmp ah,42h
	jz readcnt2
	cmp ah,03h
	jz writecnt1
	cmp ah,43h
	jz writecnt2
	jmp dword ptr cs:[dwOldInt13rm]
readcnt1:
	inc dword ptr cs:[dwReads]
	push eax
	movzx eax,al
	add cs:[dwRdSecs],eax
	pop eax
	jmp dword ptr cs:[dwOldInt13rm]
readcnt2:
	inc dword ptr cs:[dwReads]
	push eax
	movzx eax,word ptr [si+2]
	add cs:[dwRdSecs],eax
	pop eax
	jmp dword ptr cs:[dwOldInt13rm]
writecnt1:
	inc dword ptr cs:[dwWrites]
	push eax
	movzx eax,al
	add cs:[dwWrSecs],eax
	pop eax
	jmp dword ptr cs:[dwOldInt13rm]
writecnt2:
	inc dword ptr cs:[dwWrites]
	push eax
	movzx eax,word ptr [si+2]
	add cs:[dwWrSecs],eax
	pop eax
	jmp dword ptr cs:[dwOldInt13rm]

_TEXT16 ends
endif

	.DATA

__pMoveHigh dd 0

	.CODE

	include printf.inc
	include timerms.inc

main proc c

local	hFileSrc:DWORD
local	hFileDst:DWORD
local	dwSize:DWORD
local	pMem:DWORD
local	time1:DWORD
local	time2:DWORD
local	bInt13:BYTE
local	szSrc[128]:byte
local	szDst[128]:byte

	mov bInt13,0

	mov ah,51h
	int 21h
	mov esi,80h
	push ds
	mov ds,ebx
	lodsb
	mov cl,al
	.while (cl)
		mov al,[esi]
		.break .if ((al != 20h) && (al != 9))
		inc esi
		dec cl
	.endw
	lea edi,szSrc
	.while (cl)
		lodsb
		dec cl
		.break .if ((al == 20h) || (al == 9))
		stosb
	.endw
	mov al,0
	stosb
	.while (cl)
		mov al,[esi]
		.break .if ((al != 20h) && (al != 9))
		inc esi
		dec cl
	.endw
	lea edi,szDst
	.while (cl)
		lodsb
		dec cl
		.break .if ((al == 20h) || (al == 9))
		stosb
	.endw
	mov al,0
	stosb
	pop ds
	cmp szDst, 0
	jz usageerr

if ?TRAPI13
;--- get real-mode int 13h
	mov bl,13h
	mov ax,0200h
	int 31h
	push cx
	push dx
	pop esi

;--- allocate 1 selector
	mov cx,1
	mov ax,0
	int 31h
	mov fs,eax
	mov ebx,eax

	mov ax,seg _TEXT16
	movzx eax,ax
	shl eax,4
	push eax
	pop dx
	pop cx
	mov ax,7
	int 31h
	mov dx,0ffh
	xor cx,cx
	mov ax,8
	int 31h

	assume fs:_TEXT16
	mov fs:[dwOldInt13rm],esi

;--- set real-mode int 13h
	mov cx,seg _TEXT16
	mov dx,offset myint13rm
	mov bl,13h
	mov ax,0201h
	int 31h
	mov bInt13,1
endif

;------------------------ open source

	lea esi, szSrc
	mov cx,0			;normal file
	mov di,0
	mov dl,1h			;fail if file not exists
	mov dh,0
	mov bx,0			;read
	mov ax,716Ch		;open
	int 21h
	jnc @F
	cmp ax,7100h
	jnz openerr1
	mov ax,6C00h
	int 21h
	jc openerr1
@@:
	mov hFileSrc, eax

;------------------------ open destination

	lea esi, szDst
	mov cx,0			;normal file
	mov di,0
	mov dl,10h			;fail if file exists
	mov dl,11h			;open if file exists, create if file not exists
	mov dh,0
	mov bx,1			;write
	mov ax,716Ch		;open
	int 21h
	jnc @F
	cmp ax,7100h
	jnz openerr2
	mov ax,6C00h
	int 21h
	jc openerr2
@@:
	mov hFileDst, eax

;------------------------ get file size

	mov ebx,hFileSrc
	mov ax,4202h
	xor cx,cx
	xor dx,dx
	int 21h
	push dx
	push ax
	pop eax
	mov dwSize, eax
	mov ax,4200h
	xor cx,cx
	xor dx,dx
	int 21h

;------------------------ display file size

	mov ebx,CStr("Bytes")
	mov eax, dwSize
	cdq
	cmp eax, 1024*8
	jb @F
	mov ebx,CStr("kB")
	mov ecx, 1024
	div ecx
@@:
	invoke printf, CStr(<"file size: %lu %s",10>), eax, ebx

;------------------------ alloc buffer

	push dwSize
	pop cx
	pop bx
	mov ax,501h
	int 31h
	jc memerr
	push bx
	push cx
	pop eax
	mov pMem, eax

;------------------------ get start time
	call gettimer
	mov time1, eax

;------------------------ read file into buffer

	mov ebx, hFileSrc
	mov ecx, dwSize
	mov edx, pMem
	push ds
	push @flat
	pop ds
	mov ah,3Fh
	int 21h
	pop ds
	jc readerr
	cmp eax, dwSize
	jnz readerr

;------------------------ close file
	mov ebx, hFileSrc
	mov ah,3Eh
	int 21h

;------------------------ display read time
	call gettimer
	mov time2, eax
	sub eax, time1
	invoke printf, CStr(<"time for read: %lu ms",10>), eax

;------------------------ write file from buffer
	mov ebx, hFileDst
	mov ecx, dwSize
	mov edx, pMem
	push ds
	push @flat
	pop ds
	mov ah,40h
	int 21h
	pop ds
	jc writeerr1
	cmp eax, dwSize
	jnz writeerr2

;------------------------ close file
	mov ebx, hFileDst
	mov ah,3Eh
	int 21h

;------------------------ display write time
	call gettimer
	sub eax, time2
	invoke printf, CStr(<"time for write: %lu ms",10>), eax


if ?TRAPI13
	mov ecx,fs:[dwReads]
	mov edx,fs:[dwRdSecs]
	invoke printf, CStr(<"  int 13h reads: %lu, sectors: %lu",10>), ecx, edx

	mov ecx,fs:[dwWrites]
	mov edx,fs:[dwWrSecs]
	invoke printf, CStr(<"  int 13h writes: %lu, sectors: %lu",10>), ecx, edx
endif

	jmp @exit

openerr1:
	movzx eax,ax
	invoke printf, CStr(<"source file open error %X",10>), eax
	jmp @exit
openerr2:
	movzx eax,ax
	invoke printf, CStr(<"destination file open error %X",10>), eax
	jmp @exit
readerr:
;	movzx eax,ax
	invoke printf, CStr(<"read error %lX",10>), eax
	jmp @exit
writeerr1:
	movzx eax,ax
	invoke printf, CStr(<"write error %X",10>), eax
	jmp @exit
writeerr2:
	invoke printf, CStr(<"could write %lu bytes only",10>), eax
	jmp @exit
memerr:
	invoke printf, CStr(<"out of memory",10>)
	jmp @exit
usageerr:
	invoke printf, CStr(<"usage: copyfile src dst",10>)
@exit:
if ?TRAPI13
	.if (bInt13)
		mov dx,word ptr [dwOldInt13rm+0]
		mov cx,word ptr [dwOldInt13rm+2]
		mov bl,13h
		mov ax,0201h
		int 31h
	.endif
endif
	ret
	align 4

main endp

mainCRTStartup proc c public

	invoke main
	mov ah,4Ch
	int 21h

mainCRTStartup endp

	END

