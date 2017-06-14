INCLUDE \masm32\include\masm32rt.inc
INCLUDE \masm32\include\Irvine32.inc
INCLUDELIB \masm32\lib\Irvine32.lib
INCLUDE \masm32\include\debug.inc
INCLUDELIB \masm32\lib\debug.lib
INCLUDE \masm32\procs\textcolors.asm

Coord STRUCT
	X WORD ?
	Y WORD ?
Coord ENDS 

Rectang STRUCT
	Direction BYTE ?
	Vertex1 Coord <>
	Vertex2 Coord <>
Rectang ENDS

OutputRectangle PROTO, rect:Rectang
DrawRectangle PROTO, rect:Rectang, rect2:Rectang, rect3:Rectang
DetermineColor PROTO, rect:Rectang, rect2:Rectang, rect3:Rectang

.DATA	 

	rectan1 Rectang < 0, {0, 0}, {0, 0}>
	rectan2 Rectang < 0, {0, 0}, {0, 0}>
	intersect Rectang < 0, {0, 0}, {0, 0}>
	box Rectang < 0, {0, 0}, {0, 0}>
	input1 BYTE "Input Rectangle 1 Values:", 0
	input2 BYTE "Input Rectangle 2 Values:", 0
	output1 BYTE "x1: ", 0
	output2 BYTE "y1: ", 0
	output3 BYTE "x2: ", 0
	output4 BYTE "y2: ", 0
	output5 BYTE "Do another? (Y/N)", 0
	fail BYTE "The rectangles do not intersect.", 0
	success BYTE "The rectangles intersect ", 0
	result1 BYTE "on a point!", 0
	result2 BYTE "on a line!", 0
	result3 BYTE "on a plane!", 0
	legend1 BYTE "Black - Neither", 0
	legend2 BYTE "Blue - Rectangle 1", 0
	legend3 BYTE "Yellow - Rectangle 2", 0
	legend4 BYTE "Green - Intersection of 1 & 2", 0

.CODE

	mov ah,00h
	mov al,13h
	int 10h

	;mov ds,0a000h
	;a000h = 40960 decimal
	mov ax, 44h
	;44h is yellow! ;)
	mov bx,0000
	
	Start:
	
		main PROC

			Do_it:
			
				;Rectangle 1 Input
				mov edx, OFFSET input1
				Call WriteString
				Call Crlf
				
				mov edx, OFFSET output1
				Call WriteString
				Call ReadInt
				mov rectan1.Vertex1.X, ax
				
				mov edx, OFFSET output2
				Call WriteString
				Call ReadInt
				mov rectan1.Vertex1.Y, ax
				
				input_x2:
				mov edx, OFFSET output3
				Call WriteString
				Call ReadInt
				cmp rectan1.Vertex1.X, ax
				je input_x2
				jl skip_west
				add rectan1.Direction, 1
				skip_west:
				mov rectan1.Vertex2.X, ax
				
				input_y2:
				mov edx, OFFSET output4
				Call WriteString
				Call ReadInt
				cmp rectan1.Vertex1.Y, ax
				je input_y2
				jl skip_south
				add rectan1.Direction, 2
				skip_south:
				mov rectan1.Vertex2.Y, ax

				;Switch Coords to normalize rectangle (Make Direction NE)
				cmp rectan1.Direction, 1
				jl skip_switch ;NE
				je switch_x ;NW
				
				;Switch Y values (if South)
				mov ax, rectan1.Vertex1.Y
				mov bx, rectan1.Vertex2.Y
				mov rectan1.Vertex1.Y, bx
				mov rectan1.Vertex2.Y, ax
				cmp rectan1.Direction, 2
				je skip_switch ;SE
				
				;Switch X values (if West)
				switch_x:
				cmp rectan1.Direction, 1
				mov ax, rectan1.Vertex1.X
				mov bx, rectan1.Vertex2.X
				mov rectan1.Vertex1.X, bx
				mov rectan1.Vertex2.X, ax
				
				skip_switch:
				mov rectan1.Direction, 0 ;Rectangle will always be moving NE now
				
				;Rectangle 2 Input
				mov edx, OFFSET input2
				Call WriteString
				Call Crlf
				
				mov edx, OFFSET output1
				Call WriteString
				Call ReadInt
				mov rectan2.Vertex1.X, ax
				
				mov edx, OFFSET output2
				Call WriteString
				Call ReadInt
				mov rectan2.Vertex1.Y, ax
				
				input_x22:
				mov edx, OFFSET output3
				Call WriteString
				Call ReadInt
				cmp rectan2.Vertex1.X, ax
				je input_x22
				jl skip_west2
				add rectan2.Direction, 1
				skip_west2:
				mov rectan2.Vertex2.X, ax
				
				input_y22:
				mov edx, OFFSET output4
				Call WriteString
				Call ReadInt
				cmp rectan2.Vertex1.Y, ax
				je input_y22
				jl skip_south2
				add rectan2.Direction, 2
				skip_south2:
				mov rectan2.Vertex2.Y, ax

				;Switch Coords to normalize rectangle (Make Direction NE)
				cmp rectan2.Direction, 1
				jl skip_switch2 ;NE
				je switch_x2 ;NW
				
				;Switch Y values (if South)
				mov ax, rectan2.Vertex1.Y
				mov bx, rectan2.Vertex2.Y
				mov rectan2.Vertex1.Y, bx
				mov rectan2.Vertex2.Y, ax
				cmp rectan2.Direction, 2
				je skip_switch2 ;SE
				
				;Switch X values (if West)
				switch_x2:
				cmp rectan2.Direction, 1
				mov ax, rectan2.Vertex1.X
				mov bx, rectan2.Vertex2.X
				mov rectan2.Vertex1.X, bx
				mov rectan2.Vertex2.X, ax
				
				skip_switch2:
				mov rectan2.Direction, 0 ;Rectangle will always be moving NE now
				
				;Calculate The Larger Box
				mov box.Direction, 0 ;Direction of the box will always be NE because the rectangles are normalized to NE
				;X1
				mov ax, rectan1.Vertex1.X
				cmp rectan2.Vertex1.X, ax
				jg skip_movx12
				mov ax, rectan2.Vertex1.X
				
				skip_movx12:
				mov box.Vertex1.X, ax
				
				;Y1
				mov ax, rectan1.Vertex1.Y
				cmp rectan2.Vertex1.Y, ax
				jg skip_movy12
				mov ax, rectan2.Vertex1.Y
				
				skip_movy12:
				mov box.Vertex1.Y, ax
				
				;X2
				mov ax, rectan1.Vertex2.X
				cmp rectan2.Vertex2.X, ax
				jl skip_movx22
				mov ax, rectan2.Vertex2.X
				
				skip_movx22:
				mov box.Vertex2.X, ax
				
				;Y2 
				mov ax, rectan1.Vertex2.Y
				cmp rectan2.Vertex2.Y, ax
				jl skip_movy22
				mov ax, rectan2.Vertex2.Y
				
				skip_movy22:
				mov box.Vertex2.Y, ax
				
				
				;Calculate The Intersection
				mov intersect.Direction, 0 ;Direction of the intersect will always be NE because the rectangles are normalized to NE
				;X1
				mov ax, rectan1.Vertex1.X
				cmp rectan2.Vertex1.X, ax
				jl skip_movx1
				mov ax, rectan2.Vertex1.X
				cmp ax, rectan1.Vertex2.X
				jg no_intersection ;If the x value is not between the other 2 x values of the other rectangle there is no intersection
				
				skip_movx1:
				cmp ax, rectan2.Vertex2.X
				jg no_intersection
				mov intersect.Vertex1.X, ax
				
				;Y1
				mov ax, rectan1.Vertex1.Y
				cmp rectan2.Vertex1.Y, ax
				jl skip_movy1
				mov ax, rectan2.Vertex1.Y
				cmp ax, rectan1.Vertex2.Y
				jg no_intersection ;If the y value is not between the other 2 y values of the other rectangle there is no intersection
				
				skip_movy1:
				cmp ax, rectan2.Vertex2.Y
				jg no_intersection
				mov intersect.Vertex1.Y, ax
				
				;X2
				mov ax, rectan1.Vertex2.X
				cmp rectan2.Vertex2.X, ax
				jg skip_movx2
				mov ax, rectan2.Vertex2.X
				
				skip_movx2:
				mov intersect.Vertex2.X, ax
				
				;Y2 
				mov ax, rectan1.Vertex2.Y
				cmp rectan2.Vertex2.Y, ax
				jg skip_movy2
				mov ax, rectan2.Vertex2.Y
				
				skip_movy2:
				mov intersect.Vertex2.Y, ax
				
				mov edx, OFFSET success
				Call WriteString
				
				;Determine the Intersection type
				mov ax, intersect.Vertex1.X
				cmp ax, intersect.Vertex2.X
				jne test_y
				
				mov ax, intersect.Vertex1.Y
				cmp ax, intersect.Vertex2.Y
				je point_intersect
				jmp line_intersect
				
				test_y:
				mov ax, intersect.Vertex1.Y
				cmp ax, intersect.Vertex2.Y
				je line_intersect
				jmp regular_intersect
				
				point_intersect:
				mov edx, OFFSET result1
				Call WriteString
				Call Crlf
				jmp output_intersect
				
				line_intersect:
				mov edx, OFFSET result2
				Call WriteString
				Call Crlf
				jmp output_intersect
				
				regular_intersect:
				mov edx, OFFSET result3
				Call WriteString
				Call Crlf				
				
				;Output the rectangle intersection
				output_intersect:
				INVOKE OutputRectangle, intersect
				Call Crlf
				
				;Output rectangle display
				INVOKE SetTextColor, black, white
				mov edx, OFFSET legend1
				Call WriteString
				Call Crlf
				INVOKE SetTextColor, lightBlue, 0
				mov edx, OFFSET legend2
				Call WriteString
				Call Crlf
				INVOKE SetTextColor, yellow, 0
				mov edx, OFFSET legend3
				Call WriteString
				Call Crlf
				INVOKE SetTextColor, lightGreen, 0
				mov edx, OFFSET legend4
				Call WriteString
				Call Crlf
				Call Crlf
				
				INVOKE DrawRectangle, rectan1, rectan2, box
				Call Crlf
				INVOKE SetTextColor, white, 0
				
				jmp skip_no_intersect
				
				;If there is no intersection
				no_intersection:
				mov edx, OFFSET fail
				Call WriteString
				Call Crlf
				Call Crlf
				
				;Output rectangle display
				INVOKE SetTextColor, black, white
				mov edx, OFFSET legend1
				Call WriteString
				Call Crlf
				INVOKE SetTextColor, lightBlue, 0
				mov edx, OFFSET legend2
				Call WriteString
				Call Crlf
				INVOKE SetTextColor, yellow, 0
				mov edx, OFFSET legend3
				Call WriteString
				Call Crlf
				INVOKE SetTextColor, lightGreen, 0
				mov edx, OFFSET legend4
				Call WriteString
				Call Crlf
				Call Crlf
				INVOKE DrawRectangle, rectan1, rectan2, box
				INVOKE SetTextColor, white, 0
				
				skip_no_intersect:
				;Repeat or exit loop
				mov edx, OFFSET output5
				Call WriteString
				Call ReadChar
				Call Crlf
				cmp al, 'y'
				je Do_it

			
			Call Crlf
			inkey ; then console build should be performed
			INVOKE ExitProcess, 0
			
		main ENDP
		
		;Text Output
		OutputRectangle PROC, rect:Rectang
			
			
			;Output rectangle in this format [(x1, y1), (x2, y2), Direction]
			mov al, '('
			call WriteChar
			movsx eax, rect.Vertex1.X
			call WriteInt
			mov al, ','
			call WriteChar
			mov al, ' '
			call WriteChar
			movsx eax, rect.Vertex1.Y
			call WriteInt
			mov al, ')'
			
			call WriteChar
			mov al, ','
			call WriteChar
			mov al, ' '
			call WriteChar

			mov al, '('
			call WriteChar
			movsx eax, rect.Vertex2.X
			call WriteInt
			mov al, ','
			call WriteChar
			mov al, ' '
			call WriteChar
			movsx eax, rect.Vertex2.Y
			call WriteInt
			mov al, ')'
			call WriteChar
			
			mov al, ','
			call WriteChar
			mov al, ' '
			call WriteChar

			cmp rect.Direction, 1
			jle dir_north
			
			mov al, 'S'
			call WriteChar
			jmp skip_dir_n
			
			dir_north:
			mov al, 'N'
			call WriteChar
			
			skip_dir_n:
			cmp rect.Direction, 0
			je dir_east
			cmp rect.Direction, 2
			je dir_east
			
			mov al, 'W'
			call WriteChar
			jmp skip_dir_e
			
			dir_east:
			mov al, 'E'
			call WriteChar
			
			skip_dir_e:

			call Crlf

			ret
				
		OutputRectangle ENDP
		
		;Visual Output
		DrawRectangle PROC, rect:Rectang, rect2:Rectang, rect3:Rectang
			
			mov bx, rect3.Vertex2.Y
			loop_1:
			
				mov cx, rect3.Vertex1.X
				loop_2:
					INVOKE DetermineColor, rect, rect2, rect3
					mov al, ' '
					call WriteChar
					call WriteChar
					inc cx
					cmp cx, rect3.Vertex2.X
					jge exit_loop
					
				jmp loop_2
				
				exit_loop:
				call Crlf
				dec bx
				cmp bx, rect3.Vertex1.Y
				jle done_draw
					
			jmp loop_1
			
			done_draw:
			
			ret
		
		DrawRectangle ENDP
		
		;Determine the color at current point
		DetermineColor PROC, rect:Rectang, rect2:Rectang, rect3:Rectang
			
			cmp cx, rect.Vertex1.X
			jl check_rect2
			cmp cx, rect.Vertex2.X
			jge check_rect2
			cmp bx, rect.Vertex1.Y
			jl check_rect2
			cmp bx, rect.Vertex2.Y
			jg check_rect2
			
			cmp cx, rect2.Vertex1.X
			jl blue_color
			cmp cx, rect2.Vertex2.X
			jg blue_color
			cmp bx, rect2.Vertex1.Y
			jle blue_color
			cmp bx, rect2.Vertex2.Y
			jg blue_color
			jmp green_color
			
			check_rect2:
			cmp cx, rect2.Vertex1.X
			jl black_color
			cmp cx, rect2.Vertex2.X
			jg black_color
			cmp bx, rect2.Vertex1.Y
			jle black_color
			cmp bx, rect2.Vertex2.Y
			jg black_color
			
			yellow_color:
			INVOKE SetTextColor, 0, yellow
			jmp done_color
			
			blue_color:
			INVOKE SetTextColor, 0, lightBlue
			jmp done_color
			
			green_color:
			INVOKE SetTextColor, 0, lightGreen
			jmp done_color
			
			black_color:
			INVOKE SetTextColor, 0, 0
			done_color:
			
			ret
		
		DetermineColor ENDP
		
END main


