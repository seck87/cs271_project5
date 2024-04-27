TITLE Generating, Sorting, Counting Random integers     (Proj5_kuvandim.asm)

; Author: Murat Seckin Kuvandik
; Last Modified: 5/30/2023 (GMT+03:00 Time Zone)
; OSU email address: kuvandim@oregonstate.edu
; Course number/section: CS271		Section: 400
; Project Number: Project 5			Due Date: 5/29/2023 (GMT+03:00 Time Zone)
; Description: This program generates a list of integers generated randomly between low and high limits (defined as LO and HI), with a size of ARRAYSIZE.
;			   First, the list is displayed, then the program sorts this list using gnome sort, calculates the median, and displays the sorted list.
;			   Then it calculates instances of each generated number, stores them in another array, then displays it.

INCLUDE Irvine32.inc

; (insert macro definitions here)

; (insert constant definitions here)

	ARRAYSIZE = 200
	LO = 15
	HI = 50

.data

; (insert variable definitions here)

	intro1				BYTE	"Generating, Sorting, and Counting Random integers!		Programmed by Murat",13,10,13,10
						BYTE	"In this program, 200 random integers between 15 and 50 (both inclusive) are generated.",13,10
						BYTE	"Afterwards, it displays the original list, sorts the list, displays the median value,",13,10
						BYTE	"sorts the list ascendingly, and displays the number of instances of each generated value,",13,10
						BYTE	"beginning with the lowest number.",13,10,13,10,0
	randArray			DWORD	ARRAYSIZE DUP(?)
	type_randArray		DWORD	TYPE randArray
	length_randArray	DWORD	LENGTHOF randArray
	size_randArray		DWORD	SIZEOF randArray
	median_text			BYTE	"The median value of the array: ",0
	unsorted			BYTE	"Your unsorted random numbers: ",13,10,0
	sorted				BYTE	"Your sorted random numbers: ",13,10,0
	one_space			BYTE	" ",0
	line_counter		DWORD	?
	counts_text			BYTE	13,10,"Your list of instances of each generated number, starting with the smallest value: ",13,10,0
	counts				DWORD	HI-LO+1 DUP(?)
	length_counts		DWORD	LENGTHOF counts


.code
main PROC

	; display intro
	push		OFFSET intro1
	call		introduction

	; fillArray
	push		OFFSET randArray
	push		length_randArray
	call		Randomize
	call		fillArray

	; displayList for unsorted array
	mov			line_counter, 0
	push		OFFSET randArray
	push		length_randArray
	push		OFFSET unsorted
	push		OFFSET one_space
	push		OFFSET line_counter
	call		displayList

	; sortList
	push		OFFSET randArray
	push		length_randArray
	call		sortList

	; display median
	push		OFFSET randArray
	push		OFFSET median_text
	call		displayMedian

	; displayList for sorted array
	mov			line_counter, 0
	push		OFFSET randArray
	push		length_randArray
	push		OFFSET sorted
	push		OFFSET one_space
	push		OFFSET line_counter
	call		displayList

	; count array
	push		OFFSET counts
	push		OFFSET randArray
	call		countList

	; display list for counts
	mov			line_counter, 0
	push		OFFSET counts
	push		length_counts			
	push		OFFSET counts_text
	push		OFFSET one_space
	push		OFFSET line_counter
	call		displayList

	Invoke ExitProcess,0	; exit to operating system
main ENDP


; ********************************************************
;
; Name: introduction
; Description: Displays introduction
; Preconditions: intro1 adress pushed to stack
; Postconditions: changes EDX
; Receives: intro1 adress from stack
; Returns: None
;
; ********************************************************

introduction PROC

	; Display introduction
	push		EBP
	mov			EBP, ESP
	mov			EDX, [EBP+8]			;intro1 adress in EDX
	call		WriteString
	pop			EBP
	ret			4

introduction ENDP


; ********************************************************
;
; Name: fillArray
; Description: Fill randArray with randomly generated integers
; Preconditions: randArray adress and length of randArray on stack
; Postconditions: changes EAX
; Receives: randArray adress and length of randArray from stack
; Returns: modifies the randArray, filling it with random integers
;
; ********************************************************

fillArray PROC

	; Fill array
	push		EBP
	mov			EBP, ESP
	mov			ECX, [EBP+8]			;list length in ECX
	mov			EDI, [EBP+12]			;list adress in EDI

	push		EAX
_fillLoop:
	mov			EAX, (HI-LO+1)			;calculate upper limit for RandomRange, this will generate an integer 0 - (HI-LO+1)
	call		RandomRange
	add			EAX, LO					;offset this random number by the value of Lo, now it is in range LO - (HI+1)
	mov			[EDI], EAX
	add			EDI, 4
	loop		_fillLoop
;end fillLoop
	pop			EAX

	pop			EBP
	ret			8

fillArray ENDP


; ********************************************************
;
; Name: displayList
; Description: Display a list on screen, 20 integers per line
; Preconditions: line_counter must be set to zero. array address, array length, text adress, " " adress, line_counter adress must be on stack
; Postconditions: changes EAX, EBX, ECX, EDX
; Receives: array address, array length, text adress, " " adress, line_counter adress from the stack
; Returns: None
;
; ********************************************************

displayList PROC

	; Display unsorted title
	push		EBP
	mov			EBP, ESP
	mov			EDX, [EBP+16]			;unsorted title in EDX
	call		WriteString

	; Get parameters from the stack
	mov			ECX, [EBP+20]			;list length in ECX
	mov			ESI, [EBP+24]			;list adress in ESI

	
_displayLoop:
	mov			EAX, [ESI]
	call		WriteDec
	mov			EDX, [EBP+12]
	call		WriteString
	
	; save registers before entering inner loop
	push		EAX
	push		EBX
	push		ECX
	push		ESI
	push		EDI

	; 20 integers per line
	mov			ESI, [EBP+8]
	mov			EDI, [EBP+8]
	mov			EAX, [ESI]
	Inc			EAX
	mov			[EDI], EAX

	mov			EBX, 20
	mov			EDX, 0
	div			EBX
	cmp			EDX, 0
	je			_lineFeed
	jmp			_nolineFeed

_lineFeed:
	call	CrLf
_nolineFeed:
	; recover registers
	pop			EDI
	pop			ESI
	pop			ECX
	pop			EBX
	pop			EAX


	add			ESI, 4
	loop		_displayLoop
;end displayLoop
	
	pop			EBP
	ret			20

displayList ENDP


; ********************************************************
;
; Name: sortList
; Description: Sorts an array using gnomesort. Uses a separate procedure to exchange elements during sorting.
; Preconditions: array adress and length array must be on stack
; Postconditions: changes EAX, EBX, ECX, EDX, ESI, EDI
; Receives: array adress and length array from the stack
; Returns: sorted array
;
; ********************************************************

sortList PROC

	; sort the array
	push		EBP
	mov			EBP, ESP
	mov			ECX, [EBP+8]			;list length in ECX
	mov			EDI, [EBP+12]			;list adress in EDI

	; do not forget to save registers first!!!!!!!!!!!!!!!!!!!!!!!!!!!!
	
	; gnome sort pseudocode from wikipedia
	;
	; pos = 0
	; while pos < length(a):
	;	if (pos == 0 or a[pos] >= a[pos-1]):
	;		pos := pos + 1
	;	else:
	;		swap a[pos] and a[pos-1]
	;		pos := pos - 1
	;
	;
	; gnomesort pseudocode for assembly
	;
	; pos = 0
	; _loopLabel:
	; compare list length to index, jump to _endLoopLabel if pos >= list length.
	; code for while pos < length(a)
	; 	
	;	check first condition pos == 0
	;		if first condition is true jump to true block
	;	check second condition a[pos] >= a[pos-1]
	;		if second condition is true jump to true block
	;		
	;	both conditions are false, execute the following:
	;	swap a[pos] and a[pos-1]
	;	pos := pos - 1
	;	jump over true block to land on _endblock
	;
	;   _trueBlock:
	;   pos := pos + 1 increment index (EAX)
	;	increment EDI adress 4 bytes
	;   
	;	_endblock
	;   jump to _loopLabel
	;  
	; _endLoopLabel:
	;

	mov			EAX, 0					;pos = 0

_loopLabel:

	cmp			EAX, ECX				;compare list length to index
	jae			_endLoopLabel

	cmp			EAX, 0					;check first condition pos == 0
	je			_trueBlock

	mov			EBX, [EDI]				;a[pos]
	mov			EDX, [EDI-4]			;a[pos-1]
	cmp			EBX, EDX				;check second condition a[pos] >= a[pos-1]
	jae			_trueBlock

;both conditions are false, execute the following: 

	pushad
	;swap list elements by push-pop in wrong order, THIS BLOCK WILL BE WRITTEN AS A SEPARATE PROCEDURE
	push		EDI
	lea			EAX, [EDI-4]			;someone suggested this instruction on ed discussion #317
	push		EAX
	call		exchangeElements
	
	popad


	;end of SEPARATE PROCEDURE

	sub			EDI, 4					;pos := pos - 1
	dec			EAX		
	jmp			_endblock

_trueBlock:
	Inc			EAX						
	add			EDI, 4					;pos := pos + 1
_endblock:	
	jmp			_loopLabel


_endLoopLabel:
	; do not forget to recover registers first!!!!!!!

	pop			EBP
	ret			8

sortList ENDP


; ********************************************************
;
; Name: exchangeElements
; Description: Exchanges positions for sorting procedure
; Preconditions: Adresses of positions must be on stack
; Postconditions: changes EAX, EBX, ECX, EDX
; Receives: Adresses of positions from the stack
; Returns: Exchanged positions on given adresses
;
; ********************************************************

exchangeElements PROC

	; Exchange elements
	push		EBP
	mov			EBP, ESP
	mov			EAX, [EBP+8]				; EDI-4 adress to EAX
	mov			EBX, [EBP+12]				; EDI adress to EBC
	mov			ECX, [EAX]					; EDI-4 value to ECX
	mov			EDX, [EBX]					; EDI value to EDX
	mov			[EBX], ECX
	mov			[EAX], EDX

	pop			EBP
	ret			8

exchangeElements ENDP


; ********************************************************
;
; Name: displayMedian
; Description: calculates the median of an array
; Preconditions: array adress and text adress must be on stack
; Postconditions: changes EDX, EDI, EAX, EBX, EDX
; Receives: array adress and text adress from the stack
; Returns: the median
;
; ********************************************************

displayMedian PROC

	; Display median
	push		EBP
	mov			EBP, ESP
	mov			EDX, [EBP+8]			;median_text adress in EDX
	mov			EDI, [EBP+12]			;list adress in EDI
	call		CrLf
	call		WriteString

	; check is list length is odd or even by dividing it to 2
	mov			EAX, ARRAYSIZE
	mov			EBX, 2
	mov			EDX, 0
	div			EBX
	cmp			EDX, 0
	je			_remainderZero

	; remainder is not zero, list length is odd, value in the middle is median
	mov			EAX, [EDI + 4*EAX]
	call		WriteDec
	jmp			_theEnd

_remainderZero:
	; remainder is zero, two values in the middle
	; median is average of these two numbers

	mov			EBX, [EDI + 4*EAX-4]		; left of the middle in EBX
	mov			ECX, [EDI + 4*EAX]			; right of the middle in ECX
	mov			EAX, 0
	add			EAX, EBX
	add			EAX, ECX					; EAX = EBX + ECX

	mov			EDX, 0
	mov			EBX, 2
	div			EBX							; divide sum of left+right to 2
	cmp			EDX, 0						; another even or odd check
	je			_secondRemainderZero

	; second remainder is not zero, sum of left+right is odd
	; since we round half up to the nearest integer, we display the quotient plus 1
	add			EAX, 1
	call		WriteDec
	jmp			_theEnd

_secondRemainderZero:
	; second remainder is zero, sum of left+right is even
	; we display the quotient
	
	call		Writedec					;(left+right) divided by two already in EAX

_theEnd:

	call		CrLf
	call		CrLf
	pop			EBP
	ret			8

displayMedian ENDP


; ********************************************************
;
; Name: countList
; Description: counts the occurrences of every integer on an array
; Preconditions: adresses of instance array and randArray on stack
; Postconditions: changes EAX, EBX, ECX, EDX, ESI, EDI
; Receives: adresses of instance array and randArray from the stack
; Returns: generates an array of instances for every integer
;
; ********************************************************

countList PROC

	; Display the count for each number
	push		EBP
	mov			EBP, ESP
	mov			ESI, [EBP+8]			;randArray adress
	mov			EDI, [EBP+12]			;counts adress
	
	mov			EAX, 4
	mov			EBX, LO
	mov			ECX, HI-LO+1
	mov			EDX, 0

_outerLoop:
	push		ECX
	mov			ECX, ARRAYSIZE-1
	_innerLoop:
	cmp			EBX, [ESI]
	jne			_notEqual
	inc			EDX
	jmp			_innerLoopEnd
	_notEqual:
	mov			[EDI], EDX
	add			EDI, 4
	mov			EDX, 0
	jmp			_backToOuterLoop
	_innerLoopEnd:
	add			ESI, 4
	loop		_innerLoop

_backToOuterLoop:

	inc			EBX
	pop			ECX
	loop		_outerLoop
	

	pop			EBP
	ret			8				;fixed after TA review

countList ENDP

END main
