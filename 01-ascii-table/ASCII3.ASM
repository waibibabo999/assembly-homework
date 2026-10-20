	ifndef	??version
?debug	macro
	endm
$comm	macro	name,dist,size,count
	comm	dist name:BYTE:count*size
	endm
	else
$comm	macro	name,dist,size,count
	comm	dist name[size]:BYTE:count
	endm
	endif
	?debug	S "ascii3.c"
	?debug	C E9E1534F5D086173636969332E63
	?debug	C E9D0296C5615643A5C74635C696E636C7564655C737464696F2E68
	?debug	C E9D0296C5615643A5C74635C696E636C7564655C5F646566732E68
	?debug	C E9D0296C5615643A5C74635C696E636C7564655C5F6E756C6C2E68
_TEXT	segment byte public 'CODE'
_TEXT	ends
DGROUP	group	_DATA,_BSS
	assume	cs:_TEXT,ds:DGROUP
_DATA	segment word public 'DATA'
d@	label	byte
d@w	label	word
_DATA	ends
_BSS	segment word public 'BSS'
b@	label	byte
b@w	label	word
_BSS	ends
_TEXT	segment byte public 'CODE'
   ;	
   ;	int main(void)
   ;	
	assume	cs:_TEXT
_main	proc	near
	push	bp
	mov	bp,sp
	sub	sp,2
   ;	
   ;	{
   ;	    int i;
   ;	
   ;	    for (i = 0; i < 26; i++) {
   ;	
	mov	word ptr [bp-2],0
	jmp	short @1@282
@1@58:
   ;	
   ;	        putchar('a' + i);          /* 输出当前字母 */
   ;	
	inc	word ptr DGROUP:__streams+16
	jge	short @1@114
	mov	al,byte ptr [bp-2]
	add	al,97
	mov	bx,word ptr DGROUP:__streams+26
	inc	word ptr DGROUP:__streams+26
	mov	byte ptr [bx],al
	mov	ah,0
	jmp	short @1@142
@1@114:
	mov	ax,offset DGROUP:__streams+16
	push	ax
	mov	al,byte ptr [bp-2]
	add	al,97
	push	ax
	call	near ptr __fputc
	pop	cx
	pop	cx
@1@142:
   ;	
   ;	        if ((i + 1) % 13 == 0)     /* 每输出 13 个换一行 */
   ;	
	mov	ax,word ptr [bp-2]
	inc	ax
	mov	bx,13
	cwd	
	idiv	bx
	or	dx,dx
	jne	short @1@254
   ;	
   ;	            putchar('\n');
   ;	
	inc	word ptr DGROUP:__streams+16
	jge	short @1@226
	mov	bx,word ptr DGROUP:__streams+26
	inc	word ptr DGROUP:__streams+26
	mov	al,10
	mov	byte ptr [bx],al
	mov	ah,0
	jmp	short @1@254
@1@226:
	mov	ax,offset DGROUP:__streams+16
	push	ax
	mov	al,10
	push	ax
	call	near ptr __fputc
	pop	cx
	pop	cx
@1@254:
	inc	word ptr [bp-2]
@1@282:
	cmp	word ptr [bp-2],26
	jl	short @1@58
   ;	
   ;	    }
   ;	
   ;	    return 0;
   ;	
	xor	ax,ax
	jmp	short @1@338
@1@338:
   ;	
   ;	}
   ;	
	mov	sp,bp
	pop	bp
	ret	
_main	endp
	?debug	C E9
_TEXT	ends
_DATA	segment word public 'DATA'
s@	label	byte
_DATA	ends
_TEXT	segment byte public 'CODE'
_TEXT	ends
	public	_main
	extrn	__fputc:near
	extrn	__streams:word
_s@	equ	s@
	end
