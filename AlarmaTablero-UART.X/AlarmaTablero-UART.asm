;**********************************************************************
;                                                                     *
;    Archivo:	    AlarmaTablero-UART.asm                            *
;    Fecha:         18-01-21                                          *
;    Versión:	    final                                             *
;                                                                     *
;    Autor:	    Rebeca Alvarado Contreras                         *
;    Materia:       Lenguaje ensamblador		              *
;                                                                     * 
;**********************************************************************
;                                                                     *
;    Archivos requeridos: p16F877A.inc                                *
;                         LCD_CXX.ASM                                 *
;                         KBD_CXX.ASM				      *	
;			  mensajes_tablas.asm			      *
;		    	  UART_LIB.asm				      *
;                         macros_alarma.inc                                            *
;**********************************************************************
;                                                                     *
;								      *
;								      *
;**********************************************************************

	list      p=16F877A            		; Indica el modelo de PIC que se usa
						; Es una directiva de ensamblador
	#include "p16f877a.inc"
	#include <macros_alarma.inc>

; CONFIG
; __config 0xFF72
; __CONFIG _HS_OSC & _WDT_OFF & _PWRTE_ON & _BODEN_ON & _LVP_OFF & _CPD_OFF & _WRT_OFF & _CP_OFF
	
	__CONFIG _FOSC_HS & _WDTE_OFF & _PWRTE_ON & _BOREN_ON & _LVP_OFF & _CPD_OFF & _WRT_OFF & _CP_OFF

#DEFINE	CLR_PTR	    clrf	EI_ARR			;limpiar apuntador

;***** CONSTANTES
IGUAL_ARR	    EQU		0			;Será el bit 0 de la bandera flag
F_VIDAS		    EQU		1			;bit para indicar que se le acabaron las vidas
L_ERROR		    EQU		6
L_VIDAS		    EQU		4
L_ARMADA	    EQU		7
F_INT		    EQU		7

	
;***** DEFINICION DE VARIABLES

DATO		    EQU		0x20			; Variable de intercambio de datos
T_DELAY		    EQU		0x21			; Retardo de tiempo
DELL		    EQU		0x22			; Parte baja del delay
DELH		    EQU		0x23			; Parte alta del delay
LCD_VAR		    EQU 	0x24			; Variables para manejo del LCD
KBD_VAR		    EQU		0x26			; Variables para manejo del Teclado
FREC		    EQU		0x28

CONTT		    EQU		0X29
EI_ARR		    EQU		0x30			;Contador de elementos
LETRA		    EQU		0x31	

elementoI	    EQU		0x32
LIMITE		    EQU		0x33

aNUM_1		    EQU		0x34
aNUM_2		    EQU		0x35
FLAGS		    EQU		0x36
		    
MATCH		    EQU		0x37
VIDAS		    EQU		0x38			    ;oportinidades para poner contraseña
CONTDEL		    EQU		0x39
		    
VAR_AUX		    EQU		0x40			;variable auxiliar para rutina de servicio

varTx		    EQU		0x41	    ;variable donde pondré los datos a transmitir en TXREG
varRx		    EQU		0x42	    ;variable donde pondré los datos que recibo de RXREG		    

;arreglo de contraseña, ahorita será cte
ARR_C0		    EQU		0x45
ARR_C1		    EQU		0x46
ARR_C2		    EQU		0x47
ARR_C3		    EQU		0x48
		    
		    
ARR_U		    EQU		0x55			;arreglo donde se guarda la codigo ingresada por el usuario

		    
;la variable tecla es donde se guarda el valor presionado
;**********************************************************************
		    ORG		0x00			; vector de reset
		    goto	main			; salta al inicio del programa

		    ORG		0x04
		    goto	INTER			; Vector de interrupción

		    ORG		0x05

		    INCLUDE	"lcd_cxx.asm"		; Librerias incluidas
		    INCLUDE	"kbd_cxx.asm"
		    INCLUDE	"mensajes_tablas.asm"
		    INCLUDE	"UART_LIB.asm"



;**********************************************************************
;Tablas de datos


		    

;****COMPARAR ARRAYS->SI SON IGUALES, SE PONE FLAG,0 en 1
;<editor-fold defaultstate="collapsed" desc="subrutina compararar arrays">
COMPARAR_ARRAY
	clrf	    MATCH	    ;limpio match	
	clrf	    elementoI	    ;limpio comtador de elementos
	
WLCOMPARAR
	
	read_arr    ARR_C0,elementoI, aNUM_1	    ;pone el elemento I en NUM1
		
	read_arr   ARR_U,elementoI, aNUM_2	    ;pone el elemento I en NUM2	
	
	;comparo NUM1 y NUM2->si son iguales 
	comparar    aNUM_1, aNUM_2, MatchMM, SIGUEMM
	
MatchMM	;incrementar Match si son iguales
	incf	    MATCH, f
	
SIGUEMM	incf	    elementoI,f
	
	;veo si elementoI llegó al límite (4 elementos)
	comparar    elementoI, LIMITE, FINC, WLCOMPARAR
						;continua otra iteración
	;sí , ya acabé el array
	;ahora, solo veo si los arrays son iguales

FINC	comparar    MATCH, LIMITE, IGUAL, DIFF
	
IGUAL	bsf	    FLAGS,0
	return
	
DIFF	bcf	    FLAGS,0
	return
;</editor-fold>
;**********************************************************************
; Rutina de inicialización
;<editor-fold defaultstate="collapsed" desc="inicializacion">
INICIALIZA  bsf		STATUS,RP0 		;Banco 1
	    bcf		STATUS,RP1
	    movlw	0x06
	    movwf	ADCON1
		    
	    movlw	0xFF		;configura los 6 pines de A como entrada
	    movwf	TRISA		;para los botones
	    bcf 	STATUS,RP0 	;Banco 0
		    	
	    call 	UP_LCD		; Configura el PIC para trabajar con LCD
	    call 	LCD_INI		; Inicializa LCD
	    call	BORRA_Y_HOME	; Borra LCD y posiciona cursor en dir. 0
	    call 	DISPLAY_ON_CUR_OFF  ; Activa display y desactiva cursor
	    movlw 	0x80 		; Primera posición de primera fila
	    call 	LCD_REG
	    movlw	0x06		; Programa incremento en  dirección del
	    call 	LCD_REG		; cursor y trabajo en modo normal

	    bsf		STATUS,RP0
	    movlw	0x05
	    movwf	OPTION_REG	; Programa preescalador
	    movlf	0x01, TRISB
	    clrf	PORTB
	    movlw	0x80
	    movwf	TRISC
	    bcf		STATUS,RP0	
		    
	    movlf	0x6C, FREC
	    movlf	0x04, LIMITE     
	    msg_cte	0x00,NUEVO
	    call	INIT_RES 
		    
	    return
;</editor-fold>		    
;**********************************************************************
;Subrutina de retardo
;<editor-fold defaultstate="collapsed" desc="retardos">
DELAY		    movf	T_DELAY,w
		    movwf	DELH
DEL2		    movlw	0xFF
		    movwf	DELL
DEL1		    decfsz	DELL,f
		    goto	DEL1
		    decfsz	DELH,f
		    goto	DEL2
		    return		    

	
	
GranD	call	    DELAY
	call	    DELAY
	call	    DELAY
	call	    DELAY
	call	    DELAY
	call	    DELAY
	call	    DELAY
	call	    DELAY
	call	    DELAY
	call	    DELAY
	call	    DELAY
	
	return
;</editor-fold>
;**********************************************************************

;<editor-fold defaultstate="collapsed" desc="Rutina de servicio">
INTER	
	    movwf	VAR_AUX		;guardar lo que tenía en W
	
	    btfss	INTCON,INTF
	    goto	INT_TMR0
	    call	TRIGGER	
	    bcf		INTCON,INTF
	    goto	FIN_INT
	
INT_TMR0    btfss	INTCON,T0IF	;TMR0 se encargarpa de hacer las señales
	    goto	INTER
	    call	SERV_TMR0
	    bcf		INTCON,T0IF
	
FIN_INT	    movfw	VAR_AUX    
	 
	    retfie
;</editor-fold>
	

;<editor-fold defaultstate="collapsed" desc="init_res">
INIT_RES    
		    clrf	PORTB
		    clrf	FLAGS
		    clrf	EI_ARR			;limpiar ei_arr
		    movlf	0x03, VIDAS
		    msg_cte	0xC0,NADA
		    movlf	0x00, INTCON		;DESACTIVAR INTS
		    
		    return
    ;</editor-fold>

;<editor-fold defaultstate="collapsed" desc="kbd-lcd">
KBD_LCD		    
    call	KBD_VALID		; Valida tecla presionada
    btfss	STATUS,Z		; Verifica si la tecla fue válidada
    goto	KB_LC_FIN		; Si tecla no válida va a LOOP2

    call	KBD_NUM			; Convierte código de tecla a numérico
    call	KBD_LIB			; Espera a que la tecla sea liberada			
    call	HEX_ASCII		; Convierte valor numérico a ASCII
		  
    movwf	LETRA			;aquí guardo el código ascii de la letra	    
    write_arr	ARR_U, EI_ARR, LETRA	;escribo en el arreglo	    
		    
    call	LCD_DATO		; Despliega dato en LCD
KB_LC_FIN	    return
;</editor-fold>


;**********************************************************************
;Servicio de interrupción del timer

;<editor-fold defaultstate="collapsed" desc="tmr0">
SERV_TMR0	    btfsc	PORTC,0			; Verifica estado de RA3
		    goto	APAGA
		    bsf		PORTC,0			; RA3 = 1
		    goto	CONTINUA
APAGA		    bcf		PORTC,0			; RA3 = 0
CONTINUA	    movf	FREC,W
		    movwf	TMR0			; Carga cuenta en TMR0
		    movlw	0xA0			;activar interrupciones
		    movwf	INTCON
		    
    return
    ;</editor-fold>
		    
;<editor-fold defaultstate="collapsed" desc="trigger">
TRIGGER	
    bsf	PORTB,1	;prender LED

    movlw	'E'
    call	UART_ENVIAR
    
    bsf	FLAGS,F_INT		
    movlf	0xA0, INTCON		

	
    return
    
    ;</editor-fold>

;**********************************************************************
;Definir nuevo pin
    
NUEVO_PIN
;solo regreso al presionar S2

nueva_otra  clrf	EI_ARR
	    msg_cte	0xC0, NADA
		    
wtR_pin	    btfss	PIR1,RCIF	;algo se recibió?
	    goto	wtR_pin		;no->seguir esperando 
		    
	    call	UART_RECIBIR	 ;el caracter recibido está en Rx y W
	    call	LCD_DATO	 ;ver carcater recibido
	    
	    ;ahora escribir dato en ARR_C0
	    write_arr	ARR_C0, EI_ARR, varRx	
		    
	    ;ahora hay que preguntar si ya fueron los 4 dígitos
	    movfw	EI_ARR
	    sublw	0x04
	    btfss	STATUS,Z	;ya puso 4 digitos
	    goto	wtR_pin		;no->espera el otro caracter
					
		    		    
	    ;si presiono S3 significa que la contraseña se define y continuo
WT_S3	    btfsc	PORTA,4
	    goto	WT_S2		;no se presionó, checo S2
	    goto	FIN_PIN		;continuar
		    
	    ;si presiono S2 significa, defino otra contraseña
WT_S2	    btfsc	PORTA,5
	    goto	WT_S3
	    goto	nueva_otra
	    
FIN_PIN	    return
	    
	    
INCORRECTO_3
	    bsf		PORTB,L_VIDAS
	    bsf		FLAGS, F_VIDAS	    ;poner en 1 la bandera de vidas
	    msg_cte	0x00, BLOCK
	    movlw	'B'
	    call	UART_ENVIAR
	    
	    return
	    
DESBLOQUEAR

wtRF	    btfss	PIR1,RCIF	;algo se recibió?
	    goto	wtRF		;no->seguir esperando
		    
	    call	UART_RECIBIR	;sí->ver qué se recibió
		    
	    xorlw	'H'		;el carcter recibido está en W
	    btfss	STATUS,Z
	    goto	wtRF
	    
	    return
	    
PIN_MAL
	    msg_cte	0x80,MSG_ERROR
	    mdelay	0xFF
	    bsf		PORTB, L_ERROR	;prender led 6,indicando error
	    return
	    
PIN_OK	    msg_cte	0x80,ACEPTADO		    
	    mdelay	0xFF
	    
	    return
	    
ACTIVADA    bsf		PORTB,7			;prender pin 7
	    msg_cte	0x00, CODIGO
	    msg_cte	0xC0, NADA
		    
	    ;activar interrupcion por RB0 e GIE (NO TRM0)
	    movlf	0x90, INTCON
	    return
    
;**********************************************************************
; Programa principal

main	    call	INICIALIZA		;Rutina de inicialización
	    call	INIT_UART		;Inicializa uart
		    
;Definir contraseña
	    call	NUEVO_PIN
	     mdelay	0xAF
;Esperar a que se active la alarma
		    
	    ;reiniciar:vidas, leds, flags, ptr, deplegar msg, desactivar ints
WT_0	    msg_cte	0x00,WAIT_ARMAR	    ;mensaje de espera
	    call	INIT_RES	    ;
	    movlf	0x00, INTCON	    ;desactivar interrupciones
	    
WT_ARMAR
	    btfsc	PORTA,5
	    goto	WT_ARMAR	;esperar a que se arme 
		    		
    ;ya fue activada la alarma
	    call	ACTIVADA     
		    
LOOP1	    call	KBD_INI		; Inicializa puerto para leer teclado
	    call	KBD_BARRE	; Efectua barrido de teclado
	    btfss	BARRIDO,4	; Verifica si se presionó tecla
	    goto	CHECAR		; Checa si se escribieron 4 carcteres
				
	    call	KBD_LCD		; Reconoce tecla, y exhibe
		    
		    
	    ;checar si ya se presionaron 4 teclas
	    ;EI_ARR debería de estar en 4
		   
CHECAR	    movfw	EI_ARR
	    sublw	0x04
	    btfss	STATUS,Z		;si es 0->comparar arrays
	    goto	LOOP2			;no->continua   
		  	    
	    ;aquí es donde comparo ARR_C0 y ARR_U
	    call	COMPARAR_ARRAY
	    btfss	FLAGS,0		
	    goto	SHOW_ERROR
		    
	;contraseña correcta
	    call	PIN_OK
	    goto	WT_0
	
	;contraseña incorrecta
SHOW_ERROR	    
	    call	PIN_MAL
	    decfsz	VIDAS,f
	    goto	PASS		 ;aun tiene vidas
		    
	;contraseña incorrecta 3 veces		   
 	    call	INCORRECTO_3

	;esperar a recibir comando 'H' para reiniciar
	    call	DESBLOQUEAR
	    goto	WT_0

	;reiniciar para seguir revisando teclado

PASS	    clrf	EI_ARR
	    msg_cte	0xC0,NADA
		    	    
LOOP2	    movlw	0x7D		; Retardo 20 ms.
	    movwf	T_DELAY
	    call	DELAY
	    goto	LOOP1			

	    END					; directiva 'fin del programa'

	    