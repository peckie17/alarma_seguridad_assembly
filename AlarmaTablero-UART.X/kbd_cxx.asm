;KBD_CXX.ASM
 
;El conjunto de rutinas que se presentan a continuación permiten realizar
;las tareas básicas de control del teclado. En el programa  principal  se
;debe reservar memoria para el bloque de variables que utiliza el teclado

;BLOQUE DE VARIABLES

 CBLOCK			KBD_VAR
			TECLA					;Código de tecla presionada
			BARRIDO					;Variable para barrido de teclado
 ENDC		

;**********************************************************************
;Tablas de datos

KEY_TAB			movf	DATO,w
			addwf	PCL,F
			retlw	0xBE				;Código tecla 0
			retlw	0x77				;Código tecla 1
			retlw	0xB7				;Código tecla 2			
			retlw	0xD7				;Código tecla 3
			retlw	0x7B				;Código tecla 4
			retlw	0xBB				;Código tecla 5
			retlw	0xDB				;Código tecla 6			
			retlw	0x7D				;Código tecla 7
			retlw	0xBD				;Código tecla 8
			retlw	0xDD				;Código tecla 9
			retlw	0x7E				;Código tecla A			
			retlw	0xDE				;Código tecla B
			retlw	0xEE				;Código tecla C
			retlw	0xED				;Código tecla D
			retlw	0xEB				;Código tecla E			
			retlw	0xE7				;Código tecla F

TONO			movf	DATO,w
			addwf	PCL,F
			retlw	0x6C				; 0 DO
			retlw	0x75				; 1 DO#
			retlw	0x7C				; 2 RE		
			retlw	0x84				; 3 RE#
			retlw	0x8B				; 4 MI
			retlw	0x91				; 5 FA
			retlw	0x97				; 6 FA#	
			retlw	0x9D				; 7 SOL
			retlw	0xA3				; 8 SOL#
			retlw	0xA8				; 9 LA
			retlw	0xAD				; A LA#	
			retlw	0xB2				; B SI
			retlw	0xB6				; C DO
			retlw	0xBB				; D DO#
			retlw	0xBF				; E RE	
			retlw	0xC3				; F RE#
 
;**********************************************************************
; Rutina que inicializa puerto D para leer el teclado

KBD_INI			bsf	STATUS,RP0
			movlw	0x01				; Inicializa puertos
			movwf	TRISB
			movlw	0xF0
			movwf	TRISD
			bcf	STATUS,RP0
			return

;**********************************************************************
;Subrutina que barre teclado para detectar tecla presionada. Si se presionó
;tecla el bit 4 de la variable BARRIDO será 1, de lo contrario será 0.

KBD_BARRE		movlw	0xFE
			movwf	BARRIDO
BARRE1			movwf	PORTD
			NOP
			NOP
			NOP
			NOP
			NOP
			NOP
			NOP
			NOP
			NOP
			NOP
			movf	PORTD,W
			movwf	TECLA
			andlw	0xF0
			sublw	0xF0
			btfss	STATUS,Z
			goto	BARREFIN
			bsf	STATUS,C			; Establece carry en 1
			rlf	BARRIDO,F			; rota un bit a la izquierda
			btfss	BARRIDO,4
			goto	BARREFIN
			movf	BARRIDO,W
			goto	BARRE1
BARREFIN		return

;**********************************************************************
;Subrutina que valida tecla presionada. Si la tecla presionada es validada
;establece Z=1, de lo contrario Z=0.

KBD_VALID		movf	PORTD,W
			movwf	TECLA

			movlw	0x13
			movwf	T_DELAY

			call	DELAY				;Retardo 15 ms.

			movf	PORTD,W
			subwf	TECLA,W
			return

;**********************************************************************
;Subrutina que convierte código de tecla presionada a dato numérico
;el valor numérico se guarda en DATO

KBD_NUM			clrf	DATO
NUM1			call	KEY_TAB

			subwf	TECLA,W
			btfsc	STATUS,Z
			goto	NUMFIN

			incf	DATO,F

			goto	NUM1
NUMFIN			return

;**********************************************************************
;Subrutina que emite tono durante 100 ms. según la tecla presionada

KBD_TONO		call	TONO				;Obtiene valor de tono
			movwf	TMR0				;Carga TMR0 con valor de tono	
			movwf	FREC

			movlw	0xA0
			movwf	INTCON				;Habilita interrupción del timer

			movlw	0xFF
			movwf	T_DELAY

			;bsf	PORTB,4				;Enciende LED
			call	DELAY				;Retardo 50 ms.
			call	DELAY				;Retardo 50 ms.
			
			;bcf	PORTB,4				;Apaga LED

			movlw	0x00				;Inhabilita interrupción del timer
			movwf	INTCON
			return

;**********************************************************************
;Subrutina que espera a que la tecla sea liberada

KBD_LIB			movf	PORTD,W
			andlw	0xF0
			sublw	0xF0
			btfss	STATUS,Z
			goto	KBD_LIB
			return