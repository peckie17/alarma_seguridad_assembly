


;LCD_CXX.ASM
 
;El conjunto de rutinas que se presentan a continuación permiten realizar
;las tareas básicas de control del módulo de visualización LCD. Se emplean
;con los PIC 16cxx. En el programa principal se debe reservar memoria
;para el bloque de variables que utiliza el LCD del modo:

;LCD_VAR EQU dir_inicio_del_bloque

;BLOQUE DE ETIQUETAS
 
#define ENABLE 		bsf PORTE,2 	;Activa E
#define DISABLE 	bcf PORTE,2 	;Desactiva
#define LEER 		bsf PORTE,1 	;Pone LCD en Modo RD
#define ESCRIBIR 	bcf PORTE,1 	;Pone LCD en Modo WR
#define ON_COMANDO 	bcf PORTE,0 	;Desactiva RS (modo comando)
#define OFF_COMANDO bsf PORTE,0 	;Activa RS (modo datos)

 CBLOCK			LCD_VAR
			LCD_TEMP_2				;Inicio de las variables. Ser  la primera
									;dirección libre disponible 
		 	LCD_TEMP_1	
 ENDC		
 
;RUTINA UP_LCD: Con esta rutina se configura el PIC para que trabaje con el LCD.
 
 
UP_LCD			bsf	STATUS,RP0 		;Banco 1
	 		clrf 	PORTD 			;RD <0-7> salidas digitales
			clrf 	PORTE 			;RE <0-2> salidas digitales
	 		bcf 	STATUS,RP0 		;Banco 0
			ON_COMANDO 				;RS=0
			DISABLE 				;E=0
			return
 
 
;RUTINA LCD_BUSY: Con esta rutina se chequea el estado del 
;flag BUSY del m¢dulo LCD, que indica, cuando est  activado, que el
;m¢dulo a£n no ha terminado el comando anterior. La rutina espera a
;que se complete cualquier comando anterior antes de retornar al
;programa principal, para poder enviar un nuevo comando.
 
LCD_BUSY		LEER 					;Pone el LCD en Modo RD
			bsf 	STATUS,RP0 
			movlw 	H'FF'
			movwf 	TRISD 			;Puerto B como entrada
			bcf 	STATUS,RP0 		;Selecciona el banco 0
			ENABLE 					;Activa el LCD
			nop
			nop
			nop
			nop
			nop
L_BUSY			btfsc 	PORTD,7			;Checa bit de Busy
			goto 	L_BUSY
			DISABLE 	 			;Desactiva LCD
			bsf 	STATUS,RP0 
			clrf 	TRISD 			;Puerto B salida
			bcf 	STATUS,RP0 
			ESCRIBIR				;Pone LCD en modo WR
			return
 
;RUTINA LCD_E: Se trata de una peque¤a rutina que se encarga de generar
;un impulso de 1æ s (para una frecuencia de funcionamiento de 4 Mhz)
;por la patita de salida de la Puerta A RA2, que se halla conectada
;a la se¤al E (Enable) del m¢dulo LCD. Con esta rutina se pretende activar
;al m¢dulo LCD.
 
LCD_E			ENABLE					;Activa E
			nop
			nop
			nop
			nop
			nop
			DISABLE					;Desactiva E
			return
 
;RUTINA LCD_DATO: Es una rutina que pasa el contenido cargado en el
;registro W, el cual contiene un caracter ASCII, al PUERTO D, para 
;visualizarlo por el LCD o escribirlo en la CGRAM.
 
LCD_DATO		ON_COMANDO 				;Desactiva RS (modo comando)
			movwf	PORTD 			;Valor ASCII a sacar por PORTD
			call 	LCD_BUSY 		;Espera a que se libere el LCD
			OFF_COMANDO 			;Activa RS (modo dato)
			call 	LCD_E 			;Genera pulso de E
 			return
 
;RUTINA LCD_REG: Rutina parecida a la anterior, pero el contenido de W
;ahora es el código de un comando para el LCD, que es necesario pasar
;también al PUERTO D para su ejecución.
 
LCD_REG 	ON_COMANDO 				;Desactiva RS (modo comando)
			movwf 	PORTD 			;Código de comando
			call 	LCD_BUSY 		;LCD libre?.
			call 	LCD_E 			;Si. Genera pulso de E.
 			return
 
;RUTINA LCD_INI: Esta rutina se encarga de realizar la secuencia de 
;inicialización del módulo LCD de acuerdo con los tiempos dados por 
;el fabricante (15 ms). Se especifican los valores de DL, N y F,
;así como la configuración de un interfaz de 8 líneas con el bus
;de datos del PIC, y 2 líneas de 16 caracteres de 5 x 7 pixels. 
 
LCD_INI			movlw	b'00111000'
			call	LCD_REG 		;Código de instrucción
			call	LCD_DELAY		;Temporiza
			movlw	b'00111000'
			call	LCD_REG			;Código de instrucción
			call	LCD_DELAY		;Temporiza
			movlw 	b'00111000'
			call	LCD_REG			;Código de instrucción
			call 	LCD_DELAY		;Temporiza
			return
 
;RUTINA BORRA_Y_HOME: Borra el display y retorna el cursor a la posición 0. 
 
BORRA_Y_HOME	
			movlw 	b'00000001'		;Borra LCD y Home.
			call 	LCD_REG
			return
 
;RUTINA DISPLAY_ON_CUR_OFF: Control del display y cursor.
;Activa el display y desactiva el cursor
 
DISPLAY_ON_CUR_OFF	
			movlw	b'00001100' 		;LCD on, cursor off.
			call 	LCD_REG
			return
 
;RUTINA LCD_DELAY: Se trata de una rutina que implementa un retardo 
;o temporización de 5 ms. Utiliza dos variables llamadas LCD_TEMP_1 
;y LCD_TEMP_2, que se van decrementando hasta alcanzar dicho tiempo.
 
LCD_DELAY		clrwdt
			movlw 	50
			movwf 	LCD_TEMP_1
			clrf 	LCD_TEMP_2
LCD_DELAY_1		decfsz	LCD_TEMP_2,F
			goto	LCD_DELAY_1
			decfsz	LCD_TEMP_1,F
			goto	LCD_DELAY_1
			return
	
