
section .text
	global _start

	
	global data
;%include "linetest.asm"	

org 100h
_start:
	mov ah,00h
	mov al,13h ;use al 13h vid mode
	int  10h 
	
	mov ah, 0bh
	mov bh, 00h
	mov bl, 00h
	int 10h
	
	mov ah,2ch
	mov ecx, 0
	int 21h ; hours are stored in ch reg, mins in cl  , sec in dl 
	
	mov cl,ch   ;add hours
	mov ch ,0  ; int 21h loads hours in high part of cx, move high part into low part and delete high part
	imul ecx, 3600
	mov dword [hour], ecx
	
	mov ah,2ch
	mov ecx, 0 
	int 21h

	mov ch,0
	imul ecx, 60   ;add minutes
	add dword [hour], ecx
	
	 mov edx, 0
	 mov ah,2ch
	 mov ecx, 0
	 int 21h
	 mov dh, 0
	 add dword [hour], edx
	
	;mov dword [hour], 12320
	
	mov eax, [hour]
	mov edx, 0
	mov ebx, 43200 ; 12 hours max, get mod of 43200 seconds
	div ebx     ;hour mod 240
	mov dword [hour], edx
	
	
	
	
	
	
	;mov dword [hour], 25200
	.wloop:
		
	
	
	
		 
	 ;==========================================================================
	 ;seconds
	 mov byte [color], 0fh
		 call sleep2
		 call cls
		
		 mov eax, [hour]
		 mov edx, 0
		 mov ebx, 60
		 div ebx     ;hour mod 240
		 mov eax, edx
		 imul eax,4
		 
		 mov eax, [x_cords+eax]
		 mov dword [x0], 160
		 mov dword [x1], eax
		
		
		mov eax, [hour]
		mov edx ,0
		mov ebx, 60
		div ebx     ;hour mod 240
		mov eax, edx
		imul eax,4
		 
		mov eax, [y_cords+eax]
		mov dword [y0], 100
		mov dword [y1], eax
		call DRAW_LINE
		
		
		;=============================================================================
		;mins
		mov byte [color], 0ah
		
		mov eax, [hour]

		 mov edx, 0
		 mov ebx, 60
		 div ebx     ;hour mod 240
		 mov edx, 0
		 div ebx
		 mov eax, edx
		 imul eax,4
		 
		 
		 
		 mov eax, [x_min_cords+eax]
		 mov dword [x0], 160
		 mov dword [x1], eax
		
		
		mov eax, [hour]

		mov edx ,0
		mov ebx, 60
		div ebx     ;hour mod 240
		mov edx, 0
		div ebx
		mov eax, edx
		imul eax,4
		
		
		 
		mov eax, [y_min_cords+eax]
		mov dword [y0], 100
		mov dword [y1], eax
		call DRAW_LINE
		
		
		
		;====================================================
		;hours
		mov byte [color], 0bh
		mov eax, [hour]

		 mov edx, 0
		 mov ebx, 720 ; need to split 60 segments in 12 hours, so 12/60*3600 =  mod 720. should only advance in 1 hour intervals
		 div ebx     ;hour mod 240
		 
		 imul eax,4
		 
		 
		 
		 mov eax, [x_hour_cords+eax]
		 mov dword [x0], 160
		 mov dword [x1], eax
		
		
		mov eax, [hour]

		mov edx ,0
		mov ebx, 720
		div ebx     ;hour mod 240
		imul eax,4
		
		
		 
		mov eax, [y_hour_cords+eax]
		mov dword [y0], 100
		mov dword [y1], eax
		call DRAW_LINE
		
		
		
		
		inc dword [hour]
		
		call DRAW_CIRCLE
		call DRAW_POINTS
		
		
		
		
	jmp .wloop
	; mov eax, [x1]
	; cmp eax, [x2]
	; jl x1_less_x2 ; if(x1<x2)
	; jmp x1_less_x2
	


; Bresenham line alg	
DRAW_LINE:
	
	
	
	
	
	mov eax, [y1]
	sub eax, [y0] ; y1-y0
	cmp eax, 0
	jl .swapy
	jmp .noswapy
	.swapy:
		neg eax        ; abs(y1-y0)
	.noswapy:
	mov [y0_sub_y1], eax
	
	
	
	mov eax, [x1]
	sub eax, [x0] ; y1-y0
	
	cmp eax, 0
	jl .swapx
	jmp .noswapx
	.swapx:
		neg eax        ; abs(y1-y0)
	.noswapx:
	mov [x0_sub_x1], eax
	
	mov eax, [y0_sub_y1]
	cmp eax, [x0_sub_x1] ; abs(y1-y0) < abs(x1 - x0)
	jl .y_less_x
	jmp .x_less_y
	.y_less_x:
		mov eax, [x1]
		cmp eax, [x0]
		jl .x0_less_x1
		jmp .x1_less_x0
		.x0_less_x1:
			mov eax, [x0]
			mov esi, [x1]
			mov [x0], esi
			mov [x1], eax
			
			mov eax, [y0]
			mov esi, [y1]
			mov [y0], esi
			mov [y1], eax
			
			jmp LineLow
		.x1_less_x0:
			jmp LineLow
	.x_less_y:
		mov eax, [y1]
		cmp eax, [y0]
		jl .y0_less_y1
		jmp .y1_less_y0
		.y0_less_y1:
			mov eax, [x0]
			mov esi, [x1]
			mov [x0], esi
			mov [x1], eax
			
			mov eax, [y0]
			mov esi, [y1]
			mov [y0], esi
			mov [y1], eax
			
			jmp LineHigh
		.y1_less_y0:
			jmp LineHigh
	
	
	LineLow:
		
		

		mov eax, [x0] ; x=x0
		mov [x], eax
		
	
		
		xor eax, eax
		mov eax, [x1] ;dx = x1-x0
		sub eax, [x0]  
		mov [d_x], eax
		
		mov eax, [y1]
		sub eax, [y0] ;dy = y1-y0
		mov [d_y], eax
		
		mov dword [yi], 1
		cmp dword [d_y], 0
		jl .dy_less
		jmp .dy_less_else ; if dy<0 -> yi = -1  , dy = -dy
		.dy_less:
			mov dword [yi], -1
			mov eax, [d_y]
			neg eax
			mov [d_y], eax
			
		.dy_less_else:
		
		mov eax, [d_y] 
		imul eax, 2    ; p = 2dy- dx
		sub eax, [d_x]
		mov [p], eax
		
		mov eax, [y0]
		mov [y], eax
		
		.w_loop:
			MOV AH, 0Ch
			MOV AL, [color] ;vid pixel mode
			MOV BH, 00h
			mov ecx, [x] 
			mov edx, [y] ; x,y para int 10
			
			int 10h
			inc dword [x] ;x++
		
			
			cmp  dword [p],0 ;if (p<0)
			jl .if_true
			jmp .if_false    
			
			.if_true:
				mov eax, [d_y] 
				imul eax, 2
				add eax, [p] ;p = p+2*dy
				mov [p], eax
				jmp .end_if
			
			.if_false:
				mov eax, [d_y] 
				sub eax, [d_x] 
				imul eax, 2
				      ;p = p+2dx - 2dy
				add eax,[p]
				mov [p], eax
				
				mov eax, [y]
				add eax, [yi]
				mov [y], eax
				jmp .end_if

			.end_if:
				mov eax, [x]
				cmp eax, [x1]  ; for x,x1
				jl .w_loop
				jmp end_cuadrif
				
				
	LineHigh:
		

	
		
		
		mov eax, [y0] ; y=y0
		mov [y],eax
		
		xor eax, eax
		mov eax, [x1] ;dx = x1-x0
		sub eax, [x0]  
		mov [d_x], eax
		
		mov eax, [y1]
		sub eax, [y0] ;dy = y1-y0
		mov [d_y], eax
		
		mov dword [xi], 1
		
		
		cmp dword [d_x], 0
		jl .dx_less
		jmp .dx_less_else ; if dy<0 -> yi = -1  , dy = -dy
		.dx_less:
			mov dword [xi], -1
			mov eax, [d_x]
			neg eax
			mov [d_x], eax
			
		.dx_less_else:
		
		mov eax, [d_x] 
		imul eax, 2    ; p = 2dx- dy
		sub eax, [d_y]
		mov [p], eax
		
		mov eax, [x0]
		mov [x], eax
		
		.w_loop:
			MOV AH, 0Ch
			MOV AL, [color] ;empieza video
			MOV BH, 00h
			mov ecx, [x] 
			mov edx, [y] ; x,y para int 10
			
			int 10h
			inc dword [y] ;y++
		
			
			cmp  dword [p],0 ;if (p<0)
			jl .if_true
			jmp .if_false    
			
			.if_true:
				mov eax, [d_x] 
				imul eax, 2
				add eax, [p] ;p = p+2*dx
				mov [p], eax
				jmp .end_if
			
			.if_false:
				mov eax, [d_x] 
				sub eax, [d_y] 
				imul eax, 2
				      ;p = p+2dx - 2dy
				add eax,[p]
				mov [p], eax
				
				mov eax, [x]
				add eax, [xi]
				mov [x], eax
				jmp .end_if

			.end_if:
				mov eax, [y]
				cmp eax, [y1]  ; for x,x1
				jl .w_loop
				jmp end_cuadrif
				
				
				
	end_cuadrif:
		ret
				
				
clsno:
	MOV AH, 06h
	MOV AL, 00h 
	MOV BH, 00h
	mov ecx, 0
	mov edx, 0
	
	.jmp1:
		mov ecx,0
		.jmp2:
			inc ecx
			int 10h
		cmp ecx, 380
		jle .jmp2
		inc edx
		cmp edx, 200
		jle .jmp1
	
	
	ret
	
	
cls:
	MOV AH, 06h
	MOV AL, 00h 
	MOV BH, 00h
	mov dl, 79
	mov dh, 24
	
	mov cx, 0000h
	
	int 10h
	
	
	ret


  
sleep2:
	mov eax,0
	mov esi, 0
	mov edx, 0
	.loop2:
		mov eax,0
			.loop:
			inc eax
			cmp eax, 17000 ;why?
			jl .loop
			inc esi
			cmp esi, 60
			jl .loop2
			
	
	ret
		
DRAW_OCTS:
	MOV AH, 0Ch
	MOV AL, 0fh ;empieza video
	MOV BH, 00h
	

	
	
	mov ecx, [xc0]
	add ecx, [xc]
	mov edx, [yc0]          ;x0+x, y0+y
	add edx, [yc]
	int 10h
	

	mov ecx, [xc0]
	sub ecx, [xc]
	mov edx, [yc0]          ;x0-x, y0+y
	add edx, [yc]
	int 10h
	
	mov ecx, [xc0]
	add ecx, [xc]
	mov edx, [yc0]          ;x0+x, y0-y
	sub edx, [yc]
	int 10h
	
	mov ecx, [xc0]
	sub ecx, [xc]
	mov edx, [yc0]          ;x0-x, y0-y
	sub edx, [yc]
	int 10h
	
	mov ecx, [xc0]
	add ecx, [yc]
	mov edx, [yc0]          ;x0+y, y0+x
	add edx, [xc]
	int 10h
	
	mov ecx, [xc0]
	sub ecx, [yc]
	mov edx, [yc0]          ;x0+y, y0+x
	add edx, [xc]
	int 10h
	
	mov ecx, [xc0]
	add ecx, [yc]
	mov edx, [yc0]          ;x0+y, y0+x
	sub edx, [xc]
	int 10h
	
	mov ecx, [xc0]
	sub ecx, [yc]
	mov edx, [yc0]          ;x0+y, y0+x
	sub edx, [xc]
	int 10h
	
	
	
	
		ret
		

;midpoint circle alg	
DRAW_CIRCLE:
	mov eax, [radius]
	mov [xc], eax
	mov dword [yc], 0
	mov dword [err], 0
	
	.m_loop:
		call DRAW_OCTS
		
		inc dword [yc]
		mov eax, [yc]
		imul eax, 2
		inc eax
		add eax, [err] ; err += 1+2*y
		mov [err], eax
		
		mov eax, [err]
		sub eax, [xc]
		imul eax,2
		inc eax
		
		cmp eax,0
		jg .iff   ;if (2*(err-x) + 1 > 0)
		jmp .elseff
		
		.iff:
			dec dword [xc]
			mov eax, [xc]
			imul eax, 2
			neg eax
			inc eax
			add eax, [err]  ;err += 1-2*x
			mov [err], eax
		
		.elseff:
	
		

		mov eax, [xc]
		cmp eax, [yc] ; while x>=y
		jge .m_loop
	ret

DRAW_POINTS:
	
	 
	 mov ah, 0ch
	 mov bh, 0h
	 
	 mov  al, [colour]
	 
	 mov si ,0
	loop4:
	 mov cx, [x_cords+si]
	 mov dx, [y_cords+si]
	 
		inc si
		inc si
		inc si
		inc si ; dos veces porque x_cords es dword
		int 10h
		cmp si, 239
		jle loop4
	ret

						
section .data
	x_center: dd 160
	 y_center: dd 100
	 
	 x_center_rad: dd 280
	 y_center_rad: dd 180
	 
	 
	 
	 radius: dd 80 
	 xc0: dd 160
	 xc : dd 0
	 yc0 : dd 100
	 err : dd 0
	 ycup: dd 0
	 yc: dd 0
	 f: dd 0
	 ddf_x : dd 0
	 ddf_y : dd 0
	 
	 

	 colour: dw 15
	 color: db 15

	 hour: dd 0
	 
	 counter : dd 0
	 point_amt: dd 50
	 x0: dd 160
	 y0 : dd 100
	 
	 x1 : dd 160
	 y1 : dd 26
	 
	 x : dd 0
	 y : dd 0
	 xi : dd 0
	 yi : dd 0
	 ahprro : dd 100
	 d_x : dd 0
	 d_y : dd 0
	 p: dd 0
	 y0_sub_y1 : dd 0
	 x0_sub_x1: dd 0
	 
	 
	x_cords : dd  167, 175, 183, 190, 197, 204, 210, 215, 220, 224, 228, 231, 233, 234, 235, 234, 233, 231, 228, 224, 220, 215, 210, 204, 197, 190, 183, 175, 167, 160, 152, 144, 136, 129, 122, 115, 109, 104, 99, 95, 91, 88, 86, 85, 85, 85, 86, 88, 91, 95, 99, 104, 109, 115, 122, 129, 136, 144, 152, 160
	y_cords : dd 25, 26, 28, 31, 35, 39, 44, 49, 55, 62, 69, 76, 84, 92, 100, 107, 115, 123, 130, 137, 144, 150, 155, 160, 164, 168, 171, 173, 174, 175, 174, 173, 171, 168, 164, 160, 155, 150, 144, 137, 130, 123, 115, 107, 99, 92, 84, 76, 69, 62, 55, 49, 44, 39, 35, 31, 28, 26, 25, 25
	
	
	x_min_cords: dd 165, 170, 175, 180, 185, 189, 193, 197, 200, 203, 205, 207, 208, 209, 210, 209, 208, 207, 205, 203, 200, 197, 193, 189, 185, 180, 175, 170, 165, 160, 154, 149, 144, 139, 134, 130, 126, 122, 119, 116, 114, 112, 111, 110, 110, 110, 111, 112, 114, 116, 119, 122, 126, 130, 135, 139, 144, 149, 154, 160
	y_min_cords: dd 50, 51, 52, 54, 56, 59, 62, 66, 70, 75, 79, 84, 89, 94, 100, 105, 110, 115, 120, 125, 129, 133, 137, 140, 143, 145, 147, 148, 149, 150, 149, 148, 147, 145, 143, 140, 137, 133, 129, 124, 120, 115, 110, 105, 99, 94, 89, 84, 79, 74, 70, 66, 62, 59, 56, 54, 52, 51, 50, 50
	
	
	x_hour_cords: dd 163, 166, 169, 172, 175, 177, 180, 182, 184, 185, 187, 188, 189, 189, 190, 189, 189, 188, 187, 185, 184, 182, 180, 177, 175, 172, 169, 166, 163, 160, 156, 153, 150, 147, 145, 142, 139, 137, 135, 134, 132, 131, 130, 130, 130, 130, 130, 131, 132, 134, 135, 137, 139, 142, 145, 147, 150, 153, 156, 160
	y_hour_cords: dd 70, 70, 71, 72, 74, 75, 77, 79, 82, 85, 87, 90, 93, 96, 100, 103, 106, 109, 112, 115, 117, 120, 122, 124, 125, 127, 128, 129, 129, 130, 129, 129, 128, 127, 125, 124, 122, 120, 117, 114, 112, 109, 106, 103, 100, 96, 93, 90, 87, 84, 82, 79, 77, 75, 74, 72, 71, 70, 70, 70