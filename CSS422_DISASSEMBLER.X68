*-----------------------------------------------------------
* Title      : Dissasembler
* Written by : Richard Ross, Maxwell Fischer, Chris Kim
* Date       : 5/14/21
* Description: Input portion of Dissasembler
*-----------------------------------------------------------
    ORG    $1000
START:
                
*OUTPUT TO USER*
        LEA WELCOME, A1
        MOVE.B #14, D0
        TRAP #15
        LEA INSTRUCTIONS, A1
        TRAP #15
        LEA INSTRUCTIONS2, A1
        TRAP #15
INPUT   LEA     INPUTPMT1, A1  *LOAD INPUT MESSAGE
        MOVE.B  #14, D0     *LOAD TRAP TASK
        TRAP #15            *EXECUTE TRAP TASK TO DISPLAY MESSAGE
        CLR.L D0            *CLEAR D0 TO HELP CLEAR A0
        MOVE.L D0, A1       *CLEAR A0
        
        MOVE.B #$38, D6     *LOAD QUIT CHARACTER (8) IN D7
        LEA     STARTADR, A1  * Load loc for to store start address
        MOVE.B #2, D0       *LOAD NEW TRAP TASK
        TRAP #15            *EXECUTE TRAP TASK TO STORE USER INPUT
        CMP.B (A1), D6      *COMPARE INPUT TO CHECK FOR ENDING REQUEST
        BEQ DONE            *BRANCH TO DONE IF USER IS FINISHED
  
        JSR CHECKADDRESS    *CHECK IF ADDRESS IS USABLE

        JSR STORESTART           *BRANCH TO STORE TO STORE START AND END ADDRESS OF INPUT
        

        
STORESTART   *USER INPUT IS IN STARTADR STORE TRANSLATED BYTES IN A3

        LEA STARTADR,A2       *STORE START ADDRESS IN A2
        MOVE.B  D1, D3      *SAVE LENGTH IN NEW REGISTER
        CLR D4
        CLR D5
STORELP CMP.B   D1, D4      *CHECK IF FINISHED
        BEQ STOREFINISHED
        CMP.B   #$40, (A2)
        BGT TRANSLETTERS    * TRANSLATE LETTERS A-F
        
        SUB.B #$30, (A2)
        ADD.B (A2), D5
        CMP.B   D1,D4
        BEQ STOREFINISHED
      
LETDONE ADDA.L  #1, A2
        ADD.B   #1, D4
        CMP.B   D1,D4       
        BEQ STOREFINISHED
        LSL.L   #$04,D5
        JMP STORELP
        
TRANSLETTERS
        SUB.B #$37, (A2)
        
        ADD.B (A2), D5
        JMP LETDONE        
STOREFINISHED
        MOVE.L D5, A5
        JSR INPUTEND       

INPUTEND
        LEA     INPUTPMT2, A1  *LOAD INPUT MESSAGE
        MOVE.B  #14, D0     *LOAD TRAP TASK
        TRAP #15            *EXECUTE TRAP TASK TO DISPLAY MESSAGE
        MOVE.B #$38, D6     *LOAD QUIT CHARACTER (8) IN D7
        LEA     ENDADR, A1  * Load loc for to store start address
        MOVE.B #2, D0       *LOAD NEW TRAP TASK
        TRAP #15            *EXECUTE TRAP TASK TO STORE USER INPUT
        
        CMP.B (A1), D6      *COMPARE INPUT TO CHECK FOR ENDING REQUEST
        BEQ DONE            *BRANCH TO DONE IF USER IS FINISHED 
        JSR CHECKADDRESS    *CHECK IF ADDRESS IS USABLE
        
        JSR STOREEND 
        
STOREEND   *USER INPUT IS IN STARTADR STORE TRANSLATED BYTES IN A3

        LEA ENDADR,A2       *STORE START ADDRESS IN A2
        MOVE.B  D1, D3      *SAVE LENGTH IN NEW REGISTER
        CLR D4
        CLR D5
STOREENDLP
        
        
        CMP.B   D1, D4      *CHECK IF FINISHED
        BEQ STOREENDFINISHED
        CMP.B   #$40, (A2)
        BGT TRANSLETTERSEND    * TRANSLATE LETTERS A-F
        SUB.B #$30, (A2)
        ADD.B (A2), D5
ENDLETDONE
        ADDA.L  #1, A2
        ADD.B   #1, D4
        CMP.B   D1,D4
        BEQ STOREENDFINISHED
        LSL.L   #$04,D5
        JMP STOREENDLP
        
TRANSLETTERSEND
        SUB.B #$37, (A2)
        ADD.B (A2), D5
        JMP ENDLETDONE        
STOREENDFINISHED
        MOVE.L D5, A6
        CMP.L A5, A6
        BLT OUTOFRANGE
        JMP DECODE
OUTOFRANGE
        JSR INVALID
        JSR INPUT
CHECKADDRESS
        
        CMP.B   #1,D1                 * CHECK LENGTH OF INPUT
        BLT     INVALID       * <1
        CMP.B   #8,D1
        BGT     INVALID       * >8

        CLR     D3
        MOVE.B (A1), D2
CHARS   

        CMP.B   #$30,D2         * <0
        BLT     INPUTINVALID
        CMP.B   #$3A,D2         * :
        BEQ     INPUTINVALID
        CMP.B   #$3B,D2         * ;
        BEQ     INPUTINVALID
        CMP.B   #$3C,D2         * <
        BEQ     INPUTINVALID
        CMP.B   #$3D,D2         * =
        BEQ     INPUTINVALID
        CMP.B   #$3E,D2         * >
        BEQ     INPUTINVALID
        CMP.B   #$3F,D2         * ?
        BEQ     INPUTINVALID
        CMP.B   #$40,D2         * @
        BEQ     INPUTINVALID
        CMP.B   #$46,D2         *>F
        BGT     INPUTINVALID
        MOVE.B  (A1)+,D2        * MOVE CURRENT BYTE TO D2
        CMP.B   D1,D3           * COUNT CHARACTERS AND COMPARE WITH TOTAL LENGHT
        BEQ     CHECKFINISHED
        ADD     #1,D3           *MVOE TO NEXT BYTE                                                 
        JMP     CHARS
INPUTINVALID
        JSR INVALID
        JMP INPUT
       
INVALID
        LEA INPUTERROR, A1
        MOVE.B #14, D0
        TRAP #15
        RTS       
        
CHECKFINISHED
        RTS 

    *AT THIS POINT THE STARTING MEMORY ADDRESS IS STORED IN A5
    *THE ENDING MEMORY ADDRESS IS STORED IN D5
    *DECODING BEGINS HERE
DECODE
    

        
DONE    LEA THANKS, A1      *LOAD ENDING MESSAGE
        MOVE.B #14, D0      *LOAD TRAP TASK
        TRAP #15            *EXECUTE TRAP TASK TO DISPLAY MESSAGE
    SIMHALT             ; halt simulator
CR      EQU $0D
LF      EQU $0A
WELCOME DC.B    'Welcome to Group3s 68k Disassembler',CR,LF,0 
INSTRUCTIONS DC.B  'All input digits must be 0-9 or A-F (Only Capital letters)',cr,lf,0
INSTRUCTIONS2 DC.B 'Memory locations must be the start of a Word location',cr,lf,0
INPUTPMT1  DC.B    'Enter the starting location in memory OR "8" to exit: ',0
INPUTPMT2  DC.B   'Enter the ending location in memory OR "8" to exit: ',0
INPUTERROR  DC.B    'Invalid Address range Start again.' ,CR,LF,0
THANKS  DC.B    'Have a nice day.',0
STARTADR DC.L   0
ENDADR  DC.L    0

    END    START        ; last line of source






*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
