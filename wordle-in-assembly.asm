ORG 100h

.DATA
    ;WORD BANK (contains words that have 5 letters each and are uppercase)
    WORD_BANK   DB 'W','O','R','D','S'
                DB 'C','H','E','S','S'
                DB 'S','M','A','R','T'
                DB 'T','R','A','I','N'
                DB 'H','A','P','P','Y'
                DB 'S','P','A','I','N'
    NUM_WORDS   DB 6   ;total no of words

    ;Game Data
    TARGET      DB 5 DUP(?)   ;variable that will store the chosen word
    GUESS       DB 5 DUP(?)   ;stores current user guess
    RESULT      DB 5 DUP(0)   ;2 = Green, 1 = Yellow, 0 = Grey
    TARGET_USED DB 5 DUP(0)   ;keeps track of letters already matched or are yellow              ; Tracks which TARGET letters are already
                         
    ATTEMPTS    DB 0    ;counter to track no of tries(6)                   ; Max 6 attempts

    ;displaying messages
    WELCOME_MSG DB '---WELCOME TO ASSEMBLY WORDLE (5 LETTERS)---$', 0Dh, 0Ah
    PROMPT_MSG  DB 0Dh, 0Ah, 'Enter guess (5 letters): $'
    WIN_MSG     DB 0Dh, 0Ah, 0Dh, 0Ah, 'CONGRATULATIONS! YOU WON!$', 0Dh, 0Ah
    LOSE_MSG    DB 0Dh, 0Ah, 0Dh, 0Ah, 'GAME OVER! The word was: $'
    NEWLINE     DB 0Dh, 0Ah, '$'

.CODE
START:
    ;Selecting Random Word(Timer)
    MOV AH,2Ch    ;Get System Time Function
    INT 21h        ;Returns CH=hour, CL=min, DH=sec, DL=hundredths of second

    MOV AL,DL        ;Use hundredths of a second as a random no
    MOV AH,0
    DIV NUM_WORDS     ;AX/NUM_WORDS ->AL=quotient(discard),AH=remainder (0-5)

    MOV AL,AH     ;AL holds a random index between 0 and 5
    MOV AH,0
    MOV BL,5      ;storing 5 in BL as each word is 5 letters
    MUL BL        ;AX=Index*5(starting position of the chosen word)

    ;Copy chosen word from WORD_BANK into TARGET array
    MOV SI, AX      ; SI(Source Index) points to chosen word in bank
    MOV DI, 0       ; DI(Destination Index) set to 0
COPY_WORD:
    MOV DL,WORD_BANK[SI]    ;grabs first letter of word using SI pointer
    MOV TARGET[DI],DL       ;copies that letter to TARGET array
    INC SI
    INC DI
    CMP DI, 5      ;check if 5 letter word is copied
    JL  COPY_WORD  ;loop back to copy next letter

    ;Print Welcome Message
    MOV DX, OFFSET WELCOME_MSG
    MOV AH, 09h
    INT 21h

GAME_LOOP:
    CMP ATTEMPTS, 6
    JE  GAME_OVER_LOSE

    MOV DX,OFFSET PROMPT_MSG
    MOV AH,09h
    INT 21h

    ;GET USER GUESS(5 characters)
    MOV SI, 0
GET_CHARS:
    MOV AH, 01h
    INT 21h

    ;If lowercase a-z,convert to uppercase (subtract 20h / 32 decimal)
    CMP AL, 'a'
    JL  STORE_CHAR
    CMP AL, 'z'
    JG  STORE_CHAR
    SUB AL, 20h
STORE_CHAR:
    MOV GUESS[SI],AL
    INC SI
    CMP SI,5
    JL  GET_CHARS

    MOV DX, OFFSET NEWLINE
    MOV AH, 09h
    INT 21h

    ; -----------------------------------------------
    ; RESET RESULT + TARGET_USED for this round
    ; -----------------------------------------------
    MOV SI, 0
RESET_RES:
    MOV RESULT[SI], 0
    MOV TARGET_USED[SI], 0
    INC SI
    CMP SI, 5
    JL  RESET_RES

    ;CHECK 1: Greens(exact position matches)

    MOV SI, 0
CHECK_GREEN:
    MOV AL, GUESS[SI]
    CMP AL, TARGET[SI]
    JNE NOT_GREEN
    MOV RESULT[SI], 2        ;Mark as Green
    MOV TARGET_USED[SI], 1   ;This TARGET letter is now claimed
NOT_GREEN:
    INC SI
    CMP SI, 5
    JL  CHECK_GREEN

    ;CHECK 2: Yellows(letter exist in the target word but are in wrong position)

    MOV SI, 0
CHECK_YELLOW_OUTER:
    CMP RESULT[SI],2        ;Skip if already Green
    JE  NEXT_YELLOW_BYTE

    MOV DI,0  
CHECK_YELLOW_INNER:
    CMP TARGET_USED[DI], 1   ;check if already claimed by another letter?
    JE  SKIP_USED
    MOV AL, GUESS[SI]   ;current guess letter
    CMP AL, TARGET[DI]  ;check if guess letter exists anywhere in the word
    JE  FOUND_YELLOW
SKIP_USED:
    INC DI
    CMP DI, 5
    JL  CHECK_YELLOW_INNER
    JMP NEXT_YELLOW_BYTE

FOUND_YELLOW:
    MOV RESULT[SI],1     ;Mark as Yellow
    MOV TARGET_USED[DI],1   ;Claim this TARGET letter so it can't be reused
NEXT_YELLOW_BYTE:
    INC SI
    CMP SI, 5
    JL  CHECK_YELLOW_OUTER

    ;PRINT GUESS WITH COLORS (Green/Yellow/Red)

    MOV SI, 0
PRINT_RESULT_LOOP:
    MOV AL, GUESS[SI]
    MOV AH, 09h      ;commands for colors
    MOV BH, 0

    CMP RESULT[SI],2
    JE  SET_GREEN
    CMP RESULT[SI],1
    JE  SET_YELLOW

    MOV BL, 40h              ;Red text, black background(letter not in word)
    JMP DO_PRINT
SET_GREEN:
    MOV BL, 20h              ;Black text, green background
    JMP DO_PRINT
SET_YELLOW:
    MOV BL, 60h              ;Black text, yellow background

DO_PRINT:
    MOV CX, 1
    INT 10h

    ;Move cursor right manually 
    MOV AH, 03h
    MOV BH, 0
    INT 10h
    INC DL
    MOV AH, 02h
    INT 10h

    INC SI
    CMP SI, 5
    JL  PRINT_RESULT_LOOP

    MOV DX, OFFSET NEWLINE
    MOV AH, 09h
    INT 21h


    ;CHECK WIN CONDITION(all letters green)

    MOV SI, 0
CHECK_WIN_STATUS:
    CMP RESULT[SI], 2
    JNE CONTINUE_GAME
    INC SI
    CMP SI, 5
    JL  CHECK_WIN_STATUS

    JMP GAME_OVER_WIN

CONTINUE_GAME:
    INC ATTEMPTS
    JMP GAME_LOOP

GAME_OVER_WIN:
    MOV DX,OFFSET WIN_MSG
    MOV AH,09h
    INT 21h
    JMP EXIT_PROGRAM

GAME_OVER_LOSE:
    MOV DX, OFFSET LOSE_MSG
    MOV AH, 09h
    INT 21h

    MOV SI, 0
PRINT_REVEAL:
    MOV AL, TARGET[SI]
    MOV AH, 0Eh        
    INT 10h
    INC SI
    CMP SI, 5
    JL  PRINT_REVEAL

EXIT_PROGRAM:
    MOV AH, 00h
    INT 16h
    MOV AX, 4C00h     ;standard DOS exit

END START