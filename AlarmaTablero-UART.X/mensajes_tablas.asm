HEX_ASCII	    movf	DATO,W
		    addwf	PCL,F
		    retlw	'0'
		    retlw	'1'
		    retlw	'2'		
		    retlw	'3'
		    retlw	'4'
		    retlw	'5'
		    retlw	'6'		
		    retlw	'7'
		    retlw	'8'
		    retlw	'9'
		    retlw	'A'		
		    retlw	'B'
		    retlw	'C'
		    retlw	'D'
		    retlw	'E'		
		    retlw	'F'

CODIGO		    movf	DATO,W
		    addwf	PCL,F
		    retlw	'P'
		    retlw	'I'
		    retlw	'N'		
		    retlw	':'
		    retlw	' '
		  
		    retlw	0x00
		    
ACEPTADO	    movf	DATO,W
		    addwf	PCL,F
		    retlw	'O'
		    retlw	'K'
		    retlw	' '		
		    retlw	' '
		    retlw	' '      
		    retlw	0x00
		    
MSG_ERROR	    movf	DATO,W
		    addwf	PCL,F
		    retlw	'E'
		    retlw	'R'
		    retlw	'R'		
		    retlw	'O'
		    retlw	'R'
		    retlw	0x00

NADA		    movf	DATO,W
		    addwf	PCL,F
		    retlw	'.'
		    retlw	'.'
		    retlw	'.'		
		    retlw	'.'		      
		    retlw	0x00
		    
NUEVO		    movf	DATO,W
		    addwf	PCL,F
		    retlw	'N'
		    retlw	' '
		    retlw	'P'		
		    retlw	'I'
		    retlw	'N'
		    retlw	':'
		   
		    retlw	0x00
		    	    
		    
WAIT_ARMAR	    movf	DATO,W
		    addwf	PCL,F
		    retlw	'W'
		    retlw	'T'
		    retlw	' '
		    retlw	'S'
		    retlw	'2'	    
		      
		    retlw	0x00
		    
BLOCK		    movf	DATO,W
		    addwf	PCL,F
		    retlw	'B'
		    retlw	'L'
		    retlw	'O'
		    retlw	'C'
		    retlw	'K'	    
		      
		    retlw	0x00
		    

		    
		    
		    
