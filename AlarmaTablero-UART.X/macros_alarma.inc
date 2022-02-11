bank0	    MACRO			;macro to select data RAM bank 0
	    bcf	STATUS,RP0
	    bcf	STATUS,RP1
	    ENDM

bank1	    MACRO			;macro to select data RAM bank 1
	    bsf	STATUS,RP0
	    bcf	STATUS,RP1
	    ENDM
	
	
movlf	    MACRO   const,varReg
;mover constante a registro
	    movlw   const
	    movwf   varReg

	    ENDM
	    
movff	    MACRO   original,destino
;mover constante a registro
	    movfw   original
	    movwf   destino

	    ENDM
	
prenderX    MACRO   pin
;prender pin del puerto B
	    bsf	    PORTB,pin		;ya sabemos que todos los pines están en B
	    
	    ENDM
	    
comparar    MACRO   num1,num2, Ltrue, Lfalse
;saber si son iguales  
	    movfw   num1
	    subwf   num2,W
	    
	    btfss	    STATUS, Z
	    goto	    Lfalse
	
	    goto	    Ltrue

	    ENDM
	    


	    
read_arr   MACRO   arreglo, elemento,numx
;solo es para leer el elemento I del arreglo	    
	    movlw   arreglo	;dirección del elemento 1 del arreglo
	    addwf   elemento,W	;dirección del elemento i-ésimo gaurdada en W
	    movwf   FSR		;ahora ya estoy apuntando a ese elemento
	    
	    movfw   INDF
	    movwf   numx
	    
	    ENDM
	    
write_arr   MACRO   arreglo, elementoCont,var
	    ;Arreglo es el apuntador/dirección del arreglo
	    ;elemento es el contador de cuátos escribió
	    ;var es la variable desde la cual va a leer y poner en INDF
	    
	    movlw   arreglo	    ;dirección del elemento 1 del arreglo
	    addwf   elementoCont,W  ;dirección del elemento i guardada en W
	    movwf   FSR		    ;ahora ya estoy apuntando a ese elemento

	    ;aqui quiero escribir en indf el código ascii de la letra
	    movfw   var
	    movwf   INDF	    ;estoy escribiendo en INDF

	    incf    elementoCont,f  ;está listo para escribir en el sig elemento
	    
	    ENDM
	    
msg_cte	    MACRO   posicion,TABLA_MSG
	    
;0x80: primera fila
;0xC0:segunda fila
	    
;va a desplegar un mensaje constante, dada la tabla que contiene los caracteres
;después de despleagrlo, se va a la primera posicion de segunda fila
	    
;DATO es una variable definida en el main
	    local   LAZO
	    local   FINMEN
	    
	    ;call	BORRA_Y_HOME
	    movlw	posicion
	    call	LCD_REG
	    
	    movlw	0x00		; Despliega mensaje
	    movwf	DATO
LAZO	    call	TABLA_MSG
	    iorlw	0x00
	    btfsc	STATUS,Z
	    goto	FINMEN
	    call	LCD_DATO
	    incf	DATO,F
	    goto	LAZO

FINMEN	    movlw 	0xC0 		; Primera posición de segunda fila
	    call 	LCD_REG
	    
	    ENDM
	    
	    
mdelay	    MACRO	veces_delay
		    
	    local	delayaso
		   
	    movlw	veces_delay
	    movwf	CONTDEL
		
		    
delayaso    call	DELAY
	    decfsz	CONTDEL,f
	    goto	delayaso
		    
	    ENDM
	    
