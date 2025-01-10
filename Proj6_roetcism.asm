TITLE Designing Low_Level I/O Procedures     (Proj6_roetcism.asm)

; Author: Mark Roetcisoender
; Last Modified: 12/7/23
; OSU email address: roetcism@oregonstate.edu
; Course number/section:   CS271 Section 401
; Project Number: Project 6                Due Date: 12/10/23
; Description: Program which prompts the user for 10 numbers. The program utilizes macros to read and write integers via string processing rather than ReadInt
; and WriteInt. Each integer must be able to fit into a 32-bit register (range of [-2147483648, 2147483647])- the sum of the integers must do the same. The 
; program validates the user's string input, converts it into an integer, and stores it in an array. The sum and average are calculated, and then the integers,
; the sum, and the average are displayed by converting the integers into strings and using a macro to print each.


INCLUDE Irvine32.inc


; --------------------------------------------------------------------------------------------------------
; Name: mGetString
; Description:			Prompts the user to enter an integer, reads it as a string, and passes the string back in an output parameter
; Preconditions:		prompt is the address of a string which prompts the user to enter an integer that will fit into 32 bits
;						output_str is the address of a string to hold the user's entry
;						count is an integer that represents is the maximum number of characters that can be entered
;						bytes_read is a SDWORD
;						
; Postconditions:		
; Receives:				prompt = address of a string prompting the user to enter a number less than 32 bits
;						count = an integer which will be the maximum number of characters that will be read
;
; Returns:				output_str = the string where the user's entry will be stored (reference, output)
;						bytes_read = the number of bytes entered by the user that the macro read (reference, output)
; --------------------------------------------------------------------------------------------------------
	mGetString MACRO  prompt:REQ, output_str:REQ, count:REQ, bytes_read:REQ


			pushad

			mDisplayString	prompt
			mov			EDX, output_str
			mov			ECX, count			
			call		ReadString
			mov			bytes_read, EAX

			popad		

	ENDM

; --------------------------------------------------------------------------------------------------------
; Name: mDisplayString
; Description:			Displays a string passed to the macro
; Preconditions:		output is the address of a string to be printed
;						
; Postconditions:		
; Receives:				output = the address of a string to be printed
;
; Returns:				None
; --------------------------------------------------------------------------------------------------------
	mDisplayString MACRO output:REQ

			pushad							; preserve registers

			mov			EDX, output
			call		WriteString

			popad							; restore registers

	ENDM

	MAX_DIGITS = 13
	ARRAY_LENGTH = 10

.data

	intro_1			BYTE	"Designing Low Level I/O Procedures						by Mark Roetcisoender", 13, 10, 13, 10, 0
	intro_2			BYTE	"Please enter 10 signed decimal integers. After you have done so, the integers, their sum,", 13, 10, "and their average will be"
					BYTE	" displayed. Please note that each integer must fit into a 32-bit register.", 13, 10, 13, 10, 0
	farewell_msg	BYTE	13, 10, "Thank you for playing- goodbye!", 13, 10, 0
	prompt			BYTE	"Please enter a signed integer: ", 0
	user_input		BYTE	15 DUP(0)
	invalid_char	BYTE	13, 10, "You have entered an invalid integer", 13, 10, 0
	nums_statement	BYTE	13, 10, "The entered numbers are:", 13, 10, 0
	avg_statement	BYTE	13, 10, "The truncated average of the numbers is: ", 0
	sum_statement	BYTE	13, 10, "The sum of the numbers is: ", 0
	text_min1		BYTE	"-2147483648", 0
	space			BYTE	" ", 0
	avg_str			BYTE	15 DUP(0)					
	rev_avg_str		BYTE	15 DUP(0)
	sum_str			BYTE	15 DUP(0)
	rev_sum_str		BYTE	15 DUP(0)
	num_str			BYTE	16 DUP(0)
	rev_num_str		BYTE	16 DUP(0)
	null_str		BYTE	1 DUP(0)

	
	int_array		SDWORD	10 DUP(?)
	bytes_read		SDWORD	?
	converted_int	SDWORD	?
	average			SDWORD	?
	sum				SDWORD	?

.code

;---------------------------------------------------------------------------------
;
; main procedure
; 
;---------------------------------------------------------------------------------
main PROC

	;--------------------------------------------------------------------------------------
	;
	; introduce program
	;
	;--------------------------------------------------------------------------------------
		push			OFFSET intro_2
		push			OFFSET intro_1
		call			introduction	

	;--------------------------------------------------------------------------------------
	;
	; Prompt user for 10 integers that can fit into a 32-bit register. Utilize the ReadVal
	; procedure, which takes the user's string input and converts a valid input into a numeric
	; value. Use a loop to call ReadVal 10 times and store each result in an array
	;
	;--------------------------------------------------------------------------------------

		mov				ECX, ARRAY_LENGTH							; move ARRAY_LENGTH constant into ECX to use as a counter					
		mov				EDI, OFFSET int_array						; point EDI at the address of the integer array

	_collectVals:

		push			OFFSET text_min1
		push			OFFSET invalid_char
		push			OFFSET bytes_read
		push			OFFSET user_input
		push			OFFSET prompt
		push			OFFSET converted_int
		call			ReadVal										; call ReadVal to get a signed integer from the user
		mov				EAX, converted_int	
		mov				[EDI], EAX			
		add				EDI, TYPE int_array							; move the signed intger into the int_array variaable and point EDI to the next element of int_array

		loop			_collectVals								; loop until 10 integers have been collected


	;--------------------------------------------------------------------------------------
	;
	; Calculates the sum of the integers in the array, then calculates the average. Stores
	; the values in global variables sum and average, respectively
	;
	;--------------------------------------------------------------------------------------
																	
		mov				ESI, OFFSET int_array					
		mov				ECX, LENGTHOF int_array
		mov				EBX, 0										; EBX tracks the running total
	_sumLoop:
		mov				EAX, [ESI]									; move the current element in the array that ESI points to into EAX & add it to the running total
		add				EBX, EAX
		add				ESI, TYPE int_array							; increment to next element
		loop			_sumLoop
		mov				sum, EBX									; the sum of the integers is now stored in global variable sum

																	; calculate the average of the integers in the array
		mov				EAX, sum
		mov				EBX, ARRAY_LENGTH
		mov				EDX, 0
		CDQ
		idiv			EBX
		mov				average, EAX								; the average of the integers is now in global variable average

	;--------------------------------------------------------------------------------------
	;
	; Print each integer in the array by utilizing a loop and calling WriteVal each iteration.
	;
	;--------------------------------------------------------------------------------------

		mDisplayString	OFFSET nums_statement		

		mov				ESI, OFFSET	int_array
		mov				EAX, [ESI]
		mov				ESI, OFFSET int_array						; move the address of int_array into ESI and it's length into ECX as a counter
		mov				ECX, LENGTHOF int_array
	_arrayPrint:

		push			ECX											; preserve counter in ECX while we 'reset' the num_str to null each loop
		mov				AL, 0										; move null character into AL
		mov				EDI, OFFSET num_str
		mov				ECX, LENGTHOF num_str
		rep				STOSB										; copy the null character into each spot in num_str each loop to avoid printing old characters
		
		pop				ECX

		push			OFFSET num_str								; set up WriteVal
		push			OFFSET rev_num_str
		push			[ESI]										; integer to be converted & printed is what ESI is currently pointing at
		call			WriteVal
		mDisplayString	OFFSET space
		add				ESI, TYPE int_array							; increment ESI to point at next integer in array
		loop			_arrayPrint

	;--------------------------------------------------------------------------------------
	;
	; Print the sum and average of the integers in the array
	;
	;--------------------------------------------------------------------------------------

		mDisplayString	OFFSET sum_statement	

		push			OFFSET sum_str
		push			OFFSET rev_sum_str
		push			sum
		call			WriteVal

		mDisplayString	OFFSET avg_statement	

		push			OFFSET avg_str
		push			OFFSET rev_avg_str
		push			average
		call			WriteVal

	;--------------------------------------------------------------------------------------
	;
	; Display farewell message to user
	;
	;--------------------------------------------------------------------------------------

		push		OFFSET farewell_msg	
		call		farewell

Invoke ExitProcess,0		
main ENDP

;---------------------------------------------------------------------------------------------------------
; Name: introduction
; Description:			Introduces the program
; Preconditions:		intro_1 and intro_2, are all strings describing the program
;						
; Postconditions:		None
; Receives:				[EBP + 8] = address of the title_name string to be printed (reference, input)
;						[EBP + 12] = address of the string intro_1 to be printed (reference, input)
;
; Returns:				None
;---------------------------------------------------------------------------------------------------------
introduction PROC
	push		EBP
	mov			EBP, ESP

	mDisplayString [EBP + 8]										; use macro and address of title_name

	mDisplayString [EBP + 12]										; use macro and address of intro_1
							
	pop			EBP
	RET			8

introduction ENDP

; --------------------------------------------------------------------------------------------------------
; Name: readVal
; Description:			Prompts the user to enter a signed integer that will fit inside a 32-bit register. Checks that the value entered is valid, and re-prompts the user
;						to re-enter if the value is not valid. Converts the entry from a string to an integer and returns the value. Utilizes macro 'mGetString' to collect 
;						user input. Returns the value entered as an integer
; Preconditions:		'prompt', 'user_input', 'text_min1' and 'invalid_char' are all strings
;						'text_min1' is a string representing the smallest integer that can fit into a 32-bit register (-2147483648)
;						converted_int and num_bytes are both SDWORDs
;						
; Postconditions:		
; Receives:				[EBP + 8] = address of the DWORD (converted_int) where the converted integer will be placed (reference, output)
;						[EBP + 12] = address of the string 'prompt' to be printed (reference, input)
;						[EBP + 16] = address of the string 'user_input' which will be passed & returned to the mGetString macro (reference, input)
;						[EBP + 20] = the address of the SDWORD num_bytes which is the number bytes read by the mGetString macro. Passed to the macro (reference, input)
;						[EBP + 24]	= the address of the string 'invalid_char' to be printed (reference, input)
;						[EBP + 28] = the address of the string text_min1 holding the minimum valid value (reference, input)
;
; Returns:				[EBP + 8]	address of the SDWORD (converted_int) where the converted integer will be placed (reference, output)
; --------------------------------------------------------------------------------------------------------
readVal PROC

		push		EBP
		mov			EBP, ESP
		pushad


	_start:
		mov			EDI, [EBP + 8]									; move address of converted_int SDWORD into EDI 
		mGetString	[EBP + 12], [EBP + 16], MAX_DIGITS, [EBP + 20]

		mov			ESI, [EBP + 16]									; offset user input string
		mov			ECX, [EBP + 20]									; move number of bytes read into ecx to be the counter. 
		CLD															; clear direction flag
		mov			EDX, 0											; 'reset' EDX each run through

		cmp			ECX, MAX_DIGITS - 1								; check to make sure there's no more than 11 digits ('-' or '+' plus 10 digits is the 'max')
		je			_invalidChar

	_checkChar:	
		LODSB														; loop through to make sure the ASCII character is valid using LODSB by subtracting 48 to get decimal value
																	
		sub			AL, 48	

		cmp			AL, -3											; check for leading '-'
		je			_negCheck
		
		cmp			AL, -5											; check for leading '+'
		je			_posCheck

		cmp			AL, 0											; check if the converted value is between 0-9, indicating a integer
		jl			_invalidChar
		cmp			AL, 9
		jg			_invalidChar
		jmp			_checkCharLoop

	_negCheck:

		cmp			ECX, [EBP + 20]									; check if this is the first value by comparing bytes_read to ECX
		jne			_invalidChar									; if not first value -> invalid entry. If it is the first value, set EDX to 1 to indicate a negative value
		mov			EDX, 0
		mov			EDX, 1							
		cmp			ECX, 1											; if bytes_read = 1, and we're here only '-' was entered -> invalid entry
		je			_invalidChar
																	
		jmp			_checkCharLoop

	_posCheck:

		cmp			ECX, [EBP + 20]									; check if this is the first value by comparing bytes_read to ECX
		jne			_invalidChar									; if not first value -> invalid entry. If it is the first value, set EDX to 2 to indicate a positive with a + sign
		mov			EDX, 0
		mov			EDX, 2
		cmp			ECX, 1
		je			_invalidChar									; if bytes_read = 1 and we're here, only a '+' was entered -> invalid entry
		mov			EBX, [EBP + 20]

		jmp			_checkCharLoop

	_checkCharLoop:
		cmp			EDX, 0											; if 11 bytes were read, we now should check to see if we have a leading '+' or '-'. If not, the entry is invalid
		je			_byteCheck										; jump if EDX is 0 (will have a 1 or 2 if there is a leading sign)
	_beforeCheckChar:
		LOOP		_checkChar
		jmp			_beforeConvertChar

	_byteCheck:
		mov			EBX, [EBP + 20]									; compare bytes read to 11. If equal, invalid entry
		cmp			EBX, MAX_DIGITS - 2
		je			_invalidChar
		jmp			_beforeCheckChar 

	_beforeConvertChar:															
		mov			ESI, [EBP + 16]									; offset user input string back to ESI
		mov			ECX, [EBP + 20]									; move number of bytes read into back into ecx to be the counter.
		mov			EBX, 0											; use EBX to hold the running total
		push		EDX												; preserve EDX for possible reference later (- or +)
							
	_convertChar:													; conversion to integer loop

		mov			EAX, 0											; move 0 into EAX to 'clear' it (and AL inside it)
		LODSB
		cmp			EDX, 1											; if there is a leading '-' or '+', jump to just before the loop to skip past the manipulation (won't work on '-' and '+')
		je			_leadingSign

		cmp			EDX, 2											; "+'
		je			_leadingSign

		sub			EAX, 48											; subtract 48 from the character to get it's integer value

		push		EAX												; preserve EAX (integer value of the current char)
		mov			EAX, EBX										; move running total into EAX for multiplication by 10
		mov			EBX, 10											
		imul		EBX												; 
		mov			EBX, EAX										; move old running total * 10 into EBX
		pop			EAX												; pop EAX to balance stack & restore integer value of current char
		jo			_balanceStack									; jump if there is an overflow generated by imul- too large of an integer
		add			EBX, EAX										; add integer value of current char to running total * 10
		jo			_balanceStack									; jump if there is an overflow generated by imul- too large of an integer
		jmp			_toCCLoop										; jump past _leadingSign

	_leadingSign:
		mov			EDX, 0											; if EDX was 1 or 2, move another value into it to avoid hitting the check at the top of this loop.
	_toCCLoop:
		LOOP		_convertChar
		jmp			_negativeCheck

	_balanceStack:
		pop			EDX												; keep stack balanced by popping stored EDX prior to displaying error message
		cmp			EDX, 1											; check if it's negative number to compare against the minimum value
		je			_minValCheck
		jmp			_invalidChar

	_minValCheck:
		mov			ECX, [EBP + 20]									; move number of bytes read into back into ecx
		mov			ESI, [EBP + 16]									; offset user input string back to ESI
		mov			EDI, [EBP + 28]									; offset of the string containing '-2147483648' to compare to user input

	_minValLoop:
		cmpsb														; compare characters of user input string and string containing '-2147483648' and escape if not the same
		jne			_invalidChar
		loop		_minValLoop

		mov			EDI, [EBP + 8]									; if we made it this far, we have -2147483648- move final integer into the converted integer variable & jump to end
		mov			[EDI], EBX										
		jmp			_toEnd

	_negativeCheck:
		pop			EDX												; restore EDX from push in convertChar set up to so we can check if the value is negative. Jump to negativeNum if so
		cmp			EDX, 1
		je			_negativeNum

		mov			[EDI], EBX										; move final integer into the converted integer variable & jump to the end
		jmp			_toEnd											

	_negativeNum:
		neg			EBX												; if negative, convert to negative value, move final integer into the converted integer variable & jump to end
		mov			[EDI], EBX										
		jmp			_toEnd					

	_invalidChar:

		mDisplayString [EBP + 24]									; use macro to display invalid character message

		jmp			_start

	_toEnd:
		
		popad
		pop			EBP
		RET			24

readVal ENDP

; --------------------------------------------------------------------------------------------------------
; Name: writeVal
; Description:			Converts a numeric value to it's equivalent string representation (eg 55 (int) is converted to '55' (string).
;						Utilizes the mDisplayStringMacro to print the string.
; Preconditions:		[EBP + 8] is an intger which fits inside a 32-bit register
;						[EBP + 12] and [EBP + 16] are both unitialized strings
;						
; Postconditions:		None
; Receives:				[EBP + 8] = numeric value to be converted to a string and printed printed (value, input)
;						[EBP + 12] = offset to a string which will be overwritten with ASCII characters representing the numberic value (reference, output)
;						[EBP + 16] = offset to a string which will be the reverse of [EBP + 12], and display the 'number' in correct order
;
; Returns:				None
; --------------------------------------------------------------------------------------------------------
writeVal PROC

		push		EBP
		mov			EBP, ESP
		pushad

		mov			EAX, 0										; clear EAX and move initial numeric value into it
		mov			EAX, [EBP + 8]								
		mov			EDI, [EBP + 12]								; move offset of string destination into EDI
		CLD														; clear direction flag
		cmp			EAX, 0										; compare value to see if it's a negative
		jl			_negativeNum
		jmp			_beforeConversionLoop

	_negativeNum:
		mov			EBX, -1										; if number is negative, store a -1 in EBX that will be referenced later. Use it to 
		CLD														; multiply value in EAX by -1 to get positive value for conversion as well
		imul		EBX


	_beforeConversionLoop:
		push		EBX											; push EBX so we can reference it after the conversion loop
		mov			ECX, 0										; move 0 into ecx so we can use it to know the length of the string

	_conversionLoop:

		mov			EDX, 0										; divide the integer by 10 and  check to see if the remainder is positive or negative (edge case -2147483648) & mult by -1 if negative
		CDQ
		mov			EBX, 10
		idiv		EBX

																
		push		EAX											
		mov			EAX, EDX
		cmp			EAX, 0
		jl			_absoluteVal
	_backToAdd:
		add			EAX, 48										; add 48 to the remainder so that it is now it's value in ASCII and use STOSB to store in the string EDI points at
		STOSB
		inc			ECX											; increment number of characters in the string
		pop			EAX
		cmp			EAX, 0										; check if quotient is 0, jump back to top of loop if not
		je			_conversionDone
		jmp			_conversionLoop

	_absoluteVal:												; if there's a negative ASCII value, multiply by -1
		mov			EBX, -1
		imul		EBX
		jmp			_backToAdd

	_conversionDone:

		pop			EBX											; pop EBX so we can add a '-' if the numeric value was negative
		cmp			EBX, -1
		jne			_reverseStringSetUp							; if not negative, jump directly to the reverseString part

		mov			EBX, 45
		mov			[EDI], EBX									; add a '45', or '-' to the end of the string if it is a negative
		inc			ECX											; increment ECX to account for the '-'



	_reverseStringSetUp:										; loop to reverse the string so it reads correctly
		mov			ESI, [EBP + 12]								; move OFFSET of 'original' string into ESI
		add			ESI, ECX									; add the length of the string to ESI to start from the end
		dec			ESI
		mov			EDI, [EBP + 16]								; move OFFSET of 'reversed' string into EDI

	_reverseLoop:												; load the string from the initial string into the destination string using string primitives & direction flag
		STD
		LODSB
		CLD
		STOSB
		loop _reverseLoop


		mDisplayString	[EBP + 16]								; use macro to display final string

		popad
		pop			EBP
		RET			12

writeVal ENDP
; --------------------------------------------------------------------------------------------------------
; Name: farewell
; Description:			Displays a farewell message to the user
; Preconditions:		farewell_msg is a string stating a farewell message
;						
; Postconditions:		None
; Receives:				[EBP + 8] = address of the farewell_msg string to be printed (reference, input)
;
; Returns:				None
; --------------------------------------------------------------------------------------------------------
farewell PROC
		push		EBP
		mov			EBP, ESP
		push		EDX							

		mDisplayString	[EBP + 8]								; use macro to display farewell message

		pop			EDX							
		pop			EBP
		RET			4

farewell ENDP

END main
