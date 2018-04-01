; ������ ⥪�� �ணࠬ�� ��� ����� ⨯� .COM
TESTPC SEGMENT
 ASSUME CS:TESTPC, DS:TESTPC, ES:NOTHING, SS:NOTHING
 ORG 100H
START: JMP BEGIN
; ������
OS db '��� ��: $'
OS_VERS db '����� ��:   .  ',0DH,0AH,'$'
OS_OEM db 'OEM:    ',0DH,0AH,'$' ; additional 3 bytes for digits
USER_NUMBER db '��਩�� ����� ���짮��⥫�: ','$'
PUT db '    $'
ENDSTR db 0DH,0AH,'$'

PC db 'PC',0DH,0AH,'$'
PCXT db 'PC/XT',0DH,0AH,'$'
_AT db 'AT',0DH,0AH,'$'
PS2_30 db 'PS2 model 30',0DH,0AH,'$'
PS2_80 db 'PS2 model 80',0DH,0AH,'$'
PCjr db 'PCjr',0DH,0AH,'$'
PC_Cnv db 'PC Convertible',0DH,0AH,'$'
; ���������
;---------------------------------------
; ��뢠�� ���뢠���, �����饥 ��ப�.
WRT_MSG PROC near
	mov AH,09h
	int 21h
	ret
WRT_MSG ENDP
	
;---------------------------------------
; ���⠥� ⨯ ��
GET_TYPE_OS PROC near
	mov dx, OFFSET OS
	call WRT_MSG
	mov ax,0F000h
	mov es,ax
	mov ax,es:0FFFEh
	
	; ��।��塞 ⨯ ��	
	cmp al,0FFh
	je PC_MARK
	cmp al,0FEh
	je PCXT_MARK
	cmp al,0FBh
	je PCXT_MARK
	cmp al,0FCh
	je AT_MARK
	cmp al,0FAh
	je PS2_30_MARK
	cmp al,0F8h
	je PS2_80_MARK
	cmp al,0FDh
	je PCjr_MARK
	cmp al,0F9h
	je PC_Cnv_MARK
	
	PC_MARK:
		mov dx, OFFSET PC
		jmp end1
	PCXT_MARK:
		mov dx, OFFSET PCXT
		jmp end1
	AT_MARK:
		mov dx, OFFSET _AT
		jmp end1
	PS2_30_MARK:
		mov dx, OFFSET PS2_30
		jmp end1
	PS2_80_MARK:
		mov dx, OFFSET PS2_80
		jmp end1
	PCjr_MARK:
		mov dx, OFFSET PCjr
		jmp end1
	PC_Cnv_MARK:
		mov dx, OFFSET PC_Cnv
		jmp end1
	
	end1:
	call WRT_MSG
	ret
GET_TYPE_OS ENDP

;---------------------------------------
; ���⠥� ����� ��⥬�
GET_VERS_OS PROC near
	; ����砥� �����
	mov ax,0
	mov ah,30h
	int 21h
	
	; ��襬 � ��ப� OS_VERS ����� �᭮���� ���ᨨ ��
	mov si,offset OS_VERS
	add si,12
	push ax
	call BYTE_TO_DEC 
	
	; ��襬 ����䨪��� ��
	pop ax
	mov al,ah
	add si,3
	call BYTE_TO_DEC 
	
	; ��襬 ����� �� � ���᮫�
	mov dx,offset OS_VERS 
	call WRT_MSG
	
	; ��襬 OEM
	mov si,offset OS_OEM
	add si,7
	mov al,bh
	call BYTE_TO_DEC
	
	mov dx,offset OS_OEM
	call WRT_MSG
	
	; ��襬 �਩�� ����� ���짮��⥫�
	mov dx,offset USER_NUMBER
	call WRT_MSG
	mov  al,bl
	call BYTE_TO_HEX
	mov bx,ax
	mov dl,bl
	mov ah,02h
	int 21h
	mov dl,bh
	int 21h
	mov di,offset PUT
	add di,3
	mov ax,cx
	call WRD_TO_HEX
	mov dx,offset PUT
	call WRT_MSG
	
	mov dx,offset ENDSTR
	call WRT_MSG
	
	ret
GET_VERS_OS ENDP
;---------------------------------------
TETR_TO_HEX PROC near
	and AL,0Fh
	cmp AL,09
	jbe NEXT
	add AL,07
NEXT: add AL,30h
	ret
TETR_TO_HEX ENDP
;---------------------------------------
BYTE_TO_HEX PROC near
	push CX
	mov AH,AL
	call TETR_TO_HEX
	xchg AL,AH
	mov CL,4
	shr AL,CL
	call TETR_TO_HEX
	pop CX 
	ret
BYTE_TO_HEX ENDP
;---------------------------------------
; ��ॢ�� � 16�/� 16-� ࠧ�來��� �᫠
; � AX - �᫮, DI - ���� ��᫥����� ᨬ����
WRD_TO_HEX PROC near
	push BX
	mov BH,AH
	call BYTE_TO_HEX
	mov [DI],AH
	dec DI
	mov [DI],AL
	dec DI
	mov AL,BH
	call BYTE_TO_HEX
	mov [DI],AH
	dec DI
	mov [DI],AL
	pop BX
	ret
WRD_TO_HEX ENDP
;---------------------------------------
; ��ॢ�� � 10�/�, SI - ���� ���� ����襩 ����
BYTE_TO_DEC PROC near
	push CX
	push DX
	xor AH,AH
	xor DX,DX
	mov CX,10
loop_bd: div CX
	or DL,30h
	mov [SI],DL
	dec SI
	xor DX,DX
	cmp AX,10
	jae loop_bd
	cmp AL,00h
	je end_l
	or AL,30h
	mov [SI],AL
end_l: pop DX
	pop CX
	ret
BYTE_TO_DEC ENDP
;---------------------------------------
BEGIN:
	call GET_TYPE_OS
	call GET_VERS_OS
	xor AL,AL
	mov AH,4Ch
	int 21H
TESTPC ENDS
 END START