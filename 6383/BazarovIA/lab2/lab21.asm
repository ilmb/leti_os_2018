TESTPC     SEGMENT
           ASSUME  CS:TESTPC, DS:TESTPC, ES:NOTHING, SS:NOTHING
		   org 100h
START:     JMP     BEGIN
; ������
MEM db 13, 10, "Locked memory address:     h$" ; 17 symbols
ENV db 13, 10, "Environment address:     h$" ; 23 symbols
TAIL db 13, 10, "Command line tail:        $" ; 21 symbols
EMP db 13, 10, "There are no sybmols$"
CONT db 13, 10, "Content:", 13, 10, "$"
ENT db 13, 10, "$"
PATH db 13, 10, "Path:", 13, 10, "$" ; 8 symbols

;���������
;-------------------------------
WRITE PROC near
	push ax
	mov ah, 09h
	int 21h
	pop ax
	ret
WRITE ENDP
;-------------------------------
INFO PROC near 
	; Memory
	mov ax, ds:[02h]
	mov di, offset MEM
	add di, 28
	call WRD_TO_HEX
	mov dx, offset MEM
	call WRITE
	
	; Environment
	mov ax, ds:[2Ch]
	mov di, offset ENV
	add di, 26
	call WRD_TO_HEX
	mov dx, offset ENV
	call WRITE
	
	; Tail
	xor cx, cx
	mov cl, ds:[80h]
	mov si, offset TAIL
	add si, 20
	test cl, cl
	jz empty
	xor di, di
	xor ax, ax
	readtail: 
		mov al, ds:[81h+di]
		mov [si], al
		inc di
		inc si
		loop readtail
		mov dx, offset TAIL
		call WRITE
		jmp nextaction
	empty:
		mov dx, offset EMP
		call WRITE
	nextaction: nop
	
	; Envrironment content
	mov dx, offset CONT
	call WRITE
	xor di, di
	mov bx, 2Ch
	mov ds, [bx]
	readstring:
		cmp byte ptr [di], 00h
		jz pressenter
		mov dl, [di]
		mov ah, 02h
		int 21h
		jmp findend
	pressenter:
		push ds
		mov cx, cs
		mov ds, cx
		mov dx, offset ENT
		call WRITE
		pop ds
	findend:
		inc di
		cmp word ptr [di], 0001h
		jz readpath
		jmp readstring
	readpath:
		push ds
		mov ax, cs
		mov ds, ax
		mov dx, offset PATH
		call WRITE
		pop ds
		add di, 2
	pathloop:
		cmp byte ptr [di], 00h
		jz final
		mov dl, [di]
		mov ah, 02h
		int 21h
		inc di
		jmp pathloop
	final:
		ret
INFO ENDP
;-------------------------------

;-------------------------------
TETR_TO_HEX   PROC  near
           and      AL,0Fh
           cmp      AL,09
           jbe      NEXT
           add      AL,07
NEXT:      add      AL,30h
           ret
TETR_TO_HEX   ENDP
;-------------------------------
BYTE_TO_HEX   PROC  near
; ���� � AL ����������� � ��� ������� �����. ����� � AX
           push     CX
           mov      AH,AL
           call     TETR_TO_HEX
           xchg     AL,AH
           mov      CL,4
           shr      AL,CL
           call     TETR_TO_HEX ;� AL ������� �����
           pop      CX          ;� AH �������
           ret
BYTE_TO_HEX  ENDP
;-------------------------------
WRD_TO_HEX   PROC  near
;������� � 16 �/� 16-�� ���������� �����
; � AX - �����, DI - ����� ���������� �������
           push     BX
           mov      BH,AH
           call     BYTE_TO_HEX
           mov      [DI],AH
           dec      DI
           mov      [DI],AL
           dec      DI
           mov      AL,BH
           call     BYTE_TO_HEX
           mov      [DI],AH
           dec      DI
           mov      [DI],AL
           pop      BX
           ret
WRD_TO_HEX ENDP
;--------------------------------------------------
BYTE_TO_DEC   PROC  near
; ������� � 10�/�, SI - ����� ���� ������� �����
           push     CX
           push     DX
           xor      AH,AH
           xor      DX,DX
           mov      CX,10
loop_bd:   div      CX
           or       DL,30h
           mov      [SI],DL
		   dec		si
           xor      DX,DX
           cmp      AX,10
           jae      loop_bd
           cmp      AL,00h
           je       end_l
           or       AL,30h
           mov      [SI],AL
		   
end_l:     pop      DX
           pop      CX
           ret
BYTE_TO_DEC    ENDP
;-------------------------------
; ���
BEGIN:   
		   call INFO
		   mov ah, 10h
		   int 16h
; ����� � DOS
           xor     AL,AL
           mov     AH,4Ch
           int     21H
		   
TESTPC    ENDS
END       START     ;����� ������, START - ����� �����
