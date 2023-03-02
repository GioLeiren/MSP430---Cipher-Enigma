;-------------------------------------------------------------------------------
; MSP430 Assembler Code Template for use with TI Code Composer Studio
;
;
;-------------------------------------------------------------------------------
            .cdecls C,LIST,"msp430.h"       ; Include device header file
            
;-------------------------------------------------------------------------------
            .def    RESET                   ; Export program entry-point to
                                            ; make it known to linker.
;-------------------------------------------------------------------------------
            .text                           ; Assemble into program memory.
            .retain                         ; Override ELF conditional linking
                                            ; and retain current section.
            .retainrefs                     ; And retain any sections that have
                                            ; references to current section.

;-------------------------------------------------------------------------------
RESET       mov.w   #__STACK_END,SP         ; Initialize stackpointer
StopWDT     mov.w   #WDTPW|WDTHOLD,&WDTCTL  ; Stop watchdog timer


;-------------------------------------------------------------------------------
; Main loop here
;-------------------------------------------------------------------------------
EXP2:		MOV		#MSG,	R5
			MOV		#GSM,	R6
			MOV	    #RT1,	R8
			CALL	#ENIGMA1
			MOV		#GSM,	R6
			MOV		#RF1,	R9
			CALL	#ENIGMA2_PT1
			;
			MOV		#GSM,	R5
			MOV		#DCF,	R6
			MOV		RT1,	R8
			CALL	#ENIGMA2_PT2
			JMP		$
			NOP

ENIGMA1:	TST.B	0(R5)
			MOV		#RT1,	R8	;Volta o ponteiro pro primeiro elemento do vetor RT1
			JNZ		SEG1
			RET

SEG1:	    MOV.B	@R5+,0(R6)
			SUB.B	#'A',0(R6)
			MOV.B	@R6,R7
			ADD		R7, R8		;Incrementa o ponteiro de R8 (ponteiro do vetor RT1)
			MOV.B	0(R8),0(R6)
			ADD.B	#'A',0(R6)
			INC		R6
			JMP		ENIGMA1

ENIGMA2_PT1:TST.B	0(R6)
			MOV		#RF1,	R9
			JNZ		SEG2
			RET

SEG2:		SUB.B	#'A',0(R6)
			MOV.B	@R6,R7
			ADD		R7, R9		;Incrementa o ponteiro de R9 (ponteiro do vetor RF1)
			MOV.B	0(R9),0(R6)
			ADD.B	#'A',0(R6)
			INC		R6
			JMP		ENIGMA2_PT1

ENIGMA2_PT2:TST.B	0(R5)
			MOV		#RT1,	R8
			CLR		R10
			JNZ		SEG3_1
			RET

SEG3_1:
			MOV.B	@R5+,0(R6)
			SUB.B	#'A',0(R6)
			MOV.B	@R6,R7

SEG3_2:		CMP.B	@R8+, R7
			JZ		SEG3_3
			INC		R10
			MOV.B	R10,0(R6)
			ADD		#'A',0(R6)
			INC		R6
			JMP		ENIGMA2_PT2
			NOP

SEG3_3:		MOV.B	R10,0(R6)
			ADD		#'A',0(R6)
			INC		R6
			JMP		ENIGMA2_PT2
			NOP


			.data
MSG:        .byte   "CABECAFEFACAFAD",0		;Mensagem em claro
GSM:        .byte   "XXXXXXXXXXXXXXX",0     ;Mensagem cifrada
DCF:        .byte   "XXXXXXXXXXXXXXX",0     ;Mensagem decifrada
RT1:        .byte   2, 4, 1, 5, 3, 0        ;Trama do Rotor
RF1:        .byte   3, 5, 4, 0, 2, 1        ;Tabela do Refletor
                                            

;-------------------------------------------------------------------------------
; Stack Pointer definition
;-------------------------------------------------------------------------------
            .global __STACK_END
            .sect   .stack
            
;-------------------------------------------------------------------------------
; Interrupt Vectors
;-------------------------------------------------------------------------------
            .sect   ".reset"                ; MSP430 RESET Vector
            .short  RESET
            
