
;--- simple printf implementation for DOS 32-bit
;--- supports:
;--- %x  : word (dword pushed)
;--- %lx : dword 
;--- %u  : word (dword pushed)
;--- %lu : dword 
;--- %s  : near32 string out
;--- %c  : character (dword pushed)


	.386

strlen proc c uses edi string:ptr sbyte
	mov ecx,-1
	mov edi,string
	mov al,0
	cld
	repnz scasb
	mov eax,ecx
	inc eax
	not eax
	ret
strlen endp

;--- convert long to string - always base 16
;--- stdcall ltoa( long n, char * s, base n );

ltoa PROC c uses ebx esi number:dword, tbuffer:ptr byte, base:dword

	mov ecx, tbuffer
	mov esi, number
nextitem:
	mov eax,esi
	xor edx,edx
	div base
	mov eax,esi
	mov ebx,edx
	xor edx,edx
	div base
	cmp ebx,9
	mov esi,eax
	jbe @F
	add bl,57h		;convert to 'a'-'f'
	jmp xtoa_2
@@:
	add bl,'0'
xtoa_2:
	mov byte ptr [ecx],bl
	inc ecx
	test esi,esi
	ja nextitem
	and byte ptr [ecx],00
	mov ebx, ecx
	sub ebx, tbuffer
	mov esi, tbuffer
	.while esi < ecx
		dec ecx
		mov al,[esi]
		xchg al,[ecx]
		mov [esi],al
		inc esi
	.endw
	mov eax,ebx
	ret

ltoa ENDP

printf PROC c uses ebx esi edi fmt:ptr sbyte, args:VARARG

local flag:byte
local longarg:byte
local size_:dword
local fillchr:dword
local base:dword
local szTmp[12]:byte

	lea edi,args
@@L335:
	mov esi,fmt
nextchar:
	lodsb
	or al,al
	je done
	cmp al,'%'
	je formatitem
	push eax
	call handle_char
	jmp nextchar
done:
	xor eax,eax
	ret 

formatitem:
	push offset @@L335
	xor edx,edx
	mov [longarg],dl
	mov bl,1
	mov cl,' '
	cmp BYTE PTR [esi],'-'
	jne @F
	dec bl
	inc esi
@@:
	mov [flag],bl
	cmp BYTE PTR [esi],'0'
	jne @F
	mov cl,'0'
	inc esi
@@:
	mov [fillchr],ecx
	mov [size_],edx
	mov ebx,edx

	.while ( byte ptr [esi] >= '0' && byte ptr [esi] <= '9' )
		lodsb
		sub al,'0'
		movzx eax,al
		imul ecx,ebx,10		;ecx = ebx * 10
		add eax,ecx
		mov ebx,eax
	.endw

	mov [size_],ebx
	cmp BYTE PTR [esi],'l'
	jne @F
	mov [longarg],1
	inc esi
@@:
	lodsb
	mov [fmt],esi
	or al,al
	je done
	cmp al,'x'
	je handle_x
	cmp al,'X'
	je handle_x
	cmp al,'u'
	je handle_u
	cmp al,'s'
	je handle_s
handle_c:
	push DWORD PTR ss:[edi]
	add edi, 4
	call handle_char
	retn

handle_s:
	mov esi,ss:[edi]
	add edi,4
	push esi
	call strlen
	pop ebx
	jmp print_string
handle_u:
	mov base, 10
	jmp @F
handle_x:
	mov base, 16
@@:
	mov eax,ss:[edi]
	add edi,4
	cmp [longarg],0
	jne @F
	movzx eax,ax	;unsigned short
@@:
	lea esi, szTmp
	invoke ltoa, eax, esi, base
print_string:		;print string ESI
	sub [size_],eax
	cmp [flag],1
	jne print_string_chars
	mov ebx,[size_]
	jmp @@L363
@@F270:
	push [fillchr]
	call handle_char	;print leading filler chars
	dec ebx
@@L363:
	or ebx,ebx
	jg @@F270
	mov [size_],ebx

print_string_chars:

	.while (byte ptr [esi])
		lodsb
		push eax
		call handle_char	;print char of string
	.endw

	mov ebx,[size_]
@@:
	or ebx,ebx
	jle @F
	push [fillchr]
	call handle_char	;print trailing spaces
	dec ebx
	jmp @B
@@:
	retn

handle_char:
	pop ecx
	pop edx
	cmp dl,10
	jnz @F
	mov dl,13
	mov ah,2
	int 21h
	mov dl,10
@@:
	mov ah,2
	int 21h
	jmp ecx

	align 4

printf ENDP


