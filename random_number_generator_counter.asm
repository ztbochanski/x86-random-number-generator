TITLE random_number_generator_counter     (random_number_generator_counter.asm)

; ------------------------------------------------------------------------
; Author: Zachary Bochanski
; Last Modified: 2021.07.31
; Description: This program generate 200 random numbers in a specific range, then counts how many
; times each number is generated. Finally it displays the count of instances for each value.
; ------------------------------------------------------------------------


INCLUDE Irvine32.inc

; ------------------------------------------------------------------------
; DECLARE CONSTANTS - values to easily modify program
; ------------------------------------------------------------------------
LO = 19
HI = 29
ARRAYSIZE = 200
NUMS_PER_LINE = 20


; ------------------------------------------------------------------------
; DATA SECTION - declare variable definitions
; ------------------------------------------------------------------------
.data
    ; introduction
    intro1      BYTE    "Generating and Counting Random integers! Programmed by: zbochans ",13,10,13,10     ; 13 = ASCII CR, 10 = LF
                BYTE    "This program generates ",0
    intro2      BYTE    " random numbers in the range [",0
    intro3      BYTE    " ... ",0
    intro4      BYTE    "], displays the ",13,10
                BYTE    "array of generated numbers, counts how many times each number appears, ",13,10
                BYTE    "and then displays the number of instances of each value, ",13,10
                BYTE    "starting with the number of 10s.",13,10,13,10,0

    ; randum numbers and display
    yourNumbers BYTE    "Your random numbers:",13,10,0
    randArray   DWORD    ARRAYSIZE DUP(?)
    zeroPad     DWORD    0

    ; output statement and counts array
    yourCounts  BYTE    13,10,"I counted all of the values and computed the following results. The top line",13,10
                BYTE    "shows the value and the lower line shows the corresponding count.",13,10,0
    counts      DWORD    30 DUP(?)
    range       DWORD   0

    ; outro message
    outro       BYTE    13,10,"Goodbye, and thanks for using this program!",13,10,0

; ------------------------------------------------------------------------
; CODE SECTION - instructions for logic here
; ------------------------------------------------------------------------
.code
main PROC
 
    ; introduction message
    PUSH    OFFSET intro1    ; take note of bytes pushed on call stack and add n bytes to RET
    PUSH    OFFSET intro2
    PUSH    OFFSET intro3
    PUSH    OFFSET intro4
    PUSH    LO
    PUSH    HI
    PUSH    ARRAYSIZE
    CALL    introduction

    ; initialize starting seed value for Random32
    CALL    Randomize

    ; fill array with random numbers
    PUSH    LO
    PUSH    HI
    PUSH    OFFSET randArray
    PUSH    ARRAYSIZE
    CALL    fillArray

    ; display random numbers title
    MOV     EDX, OFFSET yourNumbers
    CALL    WriteString

    ; display list
    PUSH    zeroPad
    PUSH    NUMS_PER_LINE
    PUSH    OFFSET randArray
    PUSH    ARRAYSIZE
    CALL    displayList

    ; display counts title
    MOV     EDX, OFFSET yourCounts
    CALL    WriteString

    ; toggle zeroPad
    MOV     EAX, zeroPad    
    INC     EAX             ; zeropad true = 1
    MOV     zeroPad, EAX

    ; display header
    PUSH    LO
    PUSH    HI
    CALL    displayHeader

    ; count instances, put counts in array
    PUSH    OFFSET randArray
    PUSH    OFFSET counts
    PUSH    LO
    PUSH    HI
    PUSH    ARRAYSIZE
    CALL    countList

    ; calculate 
    MOV     EAX, HI
    MOV     EBX, LO
    SUB     EAX, EBX
    ADD     EAX, 1
    MOV     range, EAX
    ; dispaly list
    PUSH    zeroPad
    PUSH    NUMS_PER_LINE
    PUSH    OFFSET counts
    PUSH    range
    CALL    displayList

    ; outro message
    PUSH    OFFSET outro
    CALL    goodBye
   
  
    Invoke ExitProcess,0    ; exit to operating system
main ENDP


; ------------------------------------------------------------------------
; Name: introduction
; 
; Description: Shows the programmer informatoin, program purpose, and directions.
;
; Preconditons: EDX = intro message segments, LO, HI, SIZE
; 
; Postconditions: none
; 
; Receives: intro1, 2, 3, 4, LO, HI, SIZE
;
; Returns: none  
; 
; ------------------------------------------------------------------------
introduction PROC
    
    PUSH    EBP             
    MOV     EBP, ESP
    PUSH    EAX
    PUSH    EDX

    MOV     EDX, [EBP + 32]  ; intro1 [register + constant] to access intro variable on the stack
    CALL    WriteString
    MOV     EAX, [EBP + 8]   ; size 
    CALL    WriteDec
    MOV     EDX, [EBP + 28]
    CALL    WriteString
    MOV     EAX, [EBP + 16]
    CALL    WriteDec
    MOV     EDX, [EBP + 24]
    CALL    WriteString
    MOV     EAX, [EBP + 12]
    CALL    WriteDec
    MOV     EDX, [EBP + 20]
    CALL    WriteString

    POP     EDX
    POP     EAX
    POP     EBP
    RET     28

introduction ENDP


; ------------------------------------------------------------------------
; Name: fillArray
; 
; Description: generates random numbers and fills array
;
; Preconditons: Irvine library randomize procedure called
; 
; Postconditions: array filled to arraysize with random integers
; 
; Receives: hi, lo, array, arraysize
;
; Returns: array full of rand nums at requested size  
; 
; ------------------------------------------------------------------------
fillArray PROC
    
    PUSH    EBP             ; create stack frame
    MOV     EBP, ESP
    PUSH    EAX             ; preserve registers
    PUSH    ECX
    PUSH    EDI

    MOV     ECX, [EBP + 8]  ; list length
    MOV     EDI, [EBP + 12] ; address of list

_IterateToFill:
    ; generate random int and store in EAX
    MOV     EAX, [EBP + 16] ; HI          
    SUB     EAX, [EBP + 20] ; LO
    INC     EAX             
    CALL    RandomRange     ; EAX = upper limit, returns rand int in EAX
    ADD     EAX, [EBP + 20]

    ; add generated int to list
    MOV     [EDI], EAX           ; overwrite value in memory pointed to by EDI
    ADD     EDI, TYPE randArray  ; increment pointer by TYPE size
    LOOP    _IterateToFill

    POP     EDI
    POP     ECX
    POP     EAX
    POP     EBP
    RET     16

fillArray ENDP


; ------------------------------------------------------------------------
; Name: displayList
; 
; Description: displays list of random numbers
;
; Preconditons: array is filled with rand ints
; 
; Postconditions: write array to window
; 
; Receives: arraysize, array, nums per line, zeroPad
;
; Returns: none  
; 
; ------------------------------------------------------------------------
displayList PROC
    
    PUSH    EBP
    MOV     EBP, ESP
    PUSH    EAX             ; preserve registers
    PUSH    EBX
    PUSH    ECX
    PUSH    EDX
    PUSH    ESI

    MOV     ECX, [EBP + 8]  ; size
    MOV     ESI, [EBP + 12] ; list address
    
    MOV     EBX, 0          ; intitialize numPerLine count at 0
    MOV     EDX, [EBP + 16] ; nums per line parameter
_DisplayInt:
    CMP     EBX, EDX
    JL      _Print          ; skip over new line, go straight to print
    CALL    CrLf            ; new line 
    MOV     EBX, 0          ; reset EBX to 0

_Print:
    ; number
    MOV     EAX, [EBP + 20]
    CMP     EAX, 0
    JE      _NoPadding
    MOV     EAX, 0
    CALL    WriteDec
_NoPadding:
    MOV     EAX, [ESI]      ; move start of array into EAX
    CMP     EAX, 10
    JGE      _WhiteSpace
    PUSH    EAX
    MOV     EAX, 0
    CALL    WriteDec
    POP     EAX

_WhiteSpace:
    CALL    WriteDec
    MOV     al,' '
    CALL    WriteChar

    ; increment line count and array index
    INC     EBX
    ADD     ESI, TYPE randArray
    LOOP    _DisplayInt
    CALL    CrLf

    POP     ESI
    POP     EDX
    POP     ECX
    POP     EBX
    POP     EAX
    POP     EBP
    RET     16

displayList ENDP


; ------------------------------------------------------------------------
; Name: displayHeader
; 
; Description: displays header of range of numbers
;
; Preconditons: zeroPad = 1
; 
; Postconditions: header is displayed
; 
; Receives: hi, lo
;
; Returns: none  
; 
; ------------------------------------------------------------------------
displayHeader PROC
    
    PUSH    EBP
    MOV     EBP, ESP
    PUSH    EAX             ; preserve registers
    PUSH    EBX
    PUSH    ECX
    PUSH    EDX

    MOV     EDX, [EBP + 8]  ; HI
    MOV     EBX, [EBP + 12] ; LO
    SUB     EDX, EBX
    INC     EDX
    MOV     ECX, EDX
    
_DisplayHead:
    ; pad
    MOV     EAX, 0
    CALL    WriteDec

    ; number
    MOV     EAX, EBX
    CALL    WriteDec
    INC     EBX

    ; white space
    MOV     al,' '
    CALL    WriteChar

    LOOP    _DisplayHead
    CALL    CrLf

    POP     EDX
    POP     ECX
    POP     EBX
    POP     EAX
    POP     EBP
    RET     8

displayHeader ENDP


; ------------------------------------------------------------------------
; Name: countList
; 
; Description: counts instances of numbers in one array and adds them
;              to another array.
;
; Preconditons: random nums generated
; 
; Postconditions: array counts is filled
; 
; Receives: randArray, counts, LO, HI, ARRAYSIZE
;
; Returns: sorted array of counts
; 
; ------------------------------------------------------------------------
countList PROC

    PUSH    EBP
    MOV     EBP, ESP
    PUSH    EAX             ; preserve registers
    PUSH    EBX
    PUSH    ECX
    PUSH    EDX
    PUSH    ESI
    PUSH    EDI
    
    ; [EBP + 8] ARRAYSIZE
    ; [EBP + 12] HI
    ; [EBP + 16] LO
    ; [EBP + 20] counts
    ; [EBP + 24] randArray

    MOV     ESI, [EBP + 24] ; random nums array
    MOV     EDI, [EBP + 20] ; counts array

    ; comparte each number in range to every number in randArray
    MOV     EBX, [EBP + 16]
_ForNumInRange:
    
    MOV     EDX, 0                  
    MOV     ECX, [EBP + 8]
    _Counter:
        MOV     EAX, 0
        MOV     EAX, [ESI]              ; n-th element of randArray into EAX
        CMP     EAX, EBX
        JNE      _NumsDoNotMatch
        INC     EDX
        _NumsDoNotMatch:
        ADD     ESI, 4                 
        LOOP     _Counter

    MOV     ESI, [EBP + 24]             ; reset ESI to beginning again
    MOV     [EDI], EDX
    ADD     EDI, 4
    INC     EBX
    CMP     EBX, [EBP + 12]
    JLE     _ForNumInRange


    POP     EDI
    POP     ESI
    POP     EDX
    POP     ECX
    POP     EBX
    POP     EAX
    POP     EBP
    RET     20

countList ENDP


; ------------------------------------------------------------------------
; Name: goodBye
; 
; Description: Displays the goodby message.
;
; Preconditons: edx = outro message
; 
; Postconditions: none
; 
; Receives: outro
;
; Returns: none
; 
; ------------------------------------------------------------------------
goodBye PROC
    PUSH    EBP
    MOV     EBP, ESP
    MOV     EDX, [EBP + 8]
    CALL    WriteString
    POP     EBP
    RET     4
goodBye ENDP


END main
