#DEFINE	 TX_EN	bsf	TXSTA,TXEN	;habilitar transmisi�n (banco 1)
#DEFINE	 TX_DIS	bcf	TXSTA,TXEN	;deshabilitar transmisi�n (banco 1)

#DEFINE	 RX_EN	bsf	RCSTA,CREN	;habilitar transmisi�n (banco 0)
#DEFINE	 RX_DIS	bcf	RCSTA,CREN	;deshabilitar transmisi�n (banco 0)	
	
#DEFINE	 SC_EN	bsf	RCSTA,SPEN	;habilitar comunicaci�n serial (banco 0)
    
;inicializar UART
INIT_UART
	bcf	STATUS,RP1	
	bsf	STATUS,RP0	;selecciona banco 1
	
	bsf	TRISC,6
	bsf	TRISC,7
	
	;configurar baud rate
	movlw	.129		;129 a BRG (baud rate 9600)
	movwf	SPBRG
	
	;modo 8 bits, as�ncrono, high speed, habilitar transmisi�n
	movlw	b'10100100'
	movwf	TXSTA
	
	bcf	STATUS,RP0	;banco 0
	;habilitar comunicaci�n serial
	RX_EN			;habilitar recepci�n
	movlw	b'10010000'	
	movwf	RCSTA
	
	bcf	PIR1,RCIF; LIMPIAMOS FLAG RX
	
	return
	
UART_ENVIAR
	; el contenido a enviar debe de estar en W	
	bcf	STATUS,RP0
	
wtT	btfss	PIR1,TXIF	;TXREG vac�o?
	goto	wtT		;no
	
	movwf	TXREG		;mover a txreg
	
	return
	
UART_RECIBIR	
;se asume que externamente se checa la bandera RCIF
;los datos recibidos se ponen en la variable varRx
	bcf	STATUS,RP0			;banco 0
	
	;primero veo si hay overrun error
	btfsc	RCSTA,OERR	;hay overrun error?
	call	RX_OERR		;s�-> desactivar error
	
	movfw	RCREG		;no->lo que sea que recib� lo pongo en W
	movwf	varRx
	
	return
	
	
RX_OERR	
	;si hay overrun error, hay que resetear CREN
	
	RX_DIS
	RX_EN
	return


