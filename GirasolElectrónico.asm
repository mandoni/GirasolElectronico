;DISPLAY
LIGHT 	EQU 0x20
sLIGHT 	EQU 0x21
wLIGHT 	EQU 0x22
ID	EQU 0x23
CONT 	EQU 0x24
DATO	EQU 0x25

;MOTOR 
DATO_M	EQU 0X26
d1	EQU 0X27
d2	EQU 0X28
COUNT	EQU 0X29
X		EQU 0X30
Y		EQU 0X31
XS		EQU 0X32
YS		EQU 0X33

;LIGHTS
STRONGER	EQU 0X34
WEAKER	EQU 0X35
LECTURE	EQU 0X36

INICIO	
	ORG	0x00
	GOTO	START

START
	BSF	STATUS, 5
	CLRF 	TRISB		;Se configuran los puertos B y D como salidas.
	CLRF 	TRISD

	BCF	STATUS,	5
	MOVLW	0X00
	MOVWF	PORTD		;Se limpia el puerto D, poniendo 0 en la salida.

	BSF	STATUS,RP0
	BCF	STATUS,RP1
	MOVLW	D'14'
	MOVWF	ADCON1		;Se convierte los bits del puerto A de analogo a digital.
	MOVLW	B'111'
	MOVWF	TRISE		;Se configura el puerto B como entradas.	
	BCF	STATUS,RP0
	BCF	STATUS,RP1	
	
	;Inicializacion de Variables
	MOVLW	B'00000101'
	MOVWF	LIGHT
	MOVLW	B'00001001'
	MOVWF	sLIGHT
	MOVLW	B'00000000'
	MOVWF	wLIGHT
	MOVLW	B'00000001'
	MOVWF	ID
	MOVLW	B'00000000'
	MOVWF	CONT
	MOVLW	B'00000000'
	MOVWF	DATO
	MOVLW	B'00000000'
	MOVWF	X
	MOVLW	B'00000000'
	MOVWF	Y
	MOVLW	B'00000000'
	MOVWF	XS
	MOVLW	B'00000000'
	MOVWF	YS
	MOVLW 	B'00000000'
	MOVWF	STRONGER
	MOVLW 	B'00001001'
	MOVWF	WEAKER
	GOTO	MENU

MENU
	BTFSC	PORTE,1		;Boton que llama al movimiento de los motores.
	CALL	LOOP
	BTFSC	PORTE,0		;Boton que realiza el incremento para deplegar en el display.
	CALL	INC
	GOTO	SWITCH
	GOTO	MENU

INC
	INCF	CONT,1		;Incrementa en 1 la variable CONT.
	BTFSC	CONT,2		;CONT se resetea si llega a 4, por lo cual se verifica el bit 2.
	CALL	RESET
	RETURN

RESET
	MOVLW	B'00000000'	;Reset de la Variable CONT.
	MOVWF	CONT
	RETURN

SWITCH
	BTFSC	CONT,0		;Si el primer bit es 0 quiere decir que es par, por lo cual se 
	GOTO	ODD		;va a EVEN, de lo contrario se mueve a ODD.
	GOTO	EVEN
	
EVEN
	BTFSC	CONT,1		
	GOTO	WEAK	;10	Luz mas debil
	GOTO	OWN	;00	Lus Propia
	
ODD
	BTFSC	CONT,1
	GOTO	ID_M	;11	ID del Grupo
	GOTO	STRONG	;01	Luz mas fuerte
	
OWN
	MOVFW	LIGHT		;Se mueve el valor de la variable correspondiente a DATO
	MOVWF	DATO		;que es la variable que se envia al display por medio del
	GOTO 	PRINT		;metodo PRINT.
	
STRONG
	MOVFW	sLIGHT
	MOVWF	DATO
	GOTO 	PRINT
	
WEAK
	MOVFW	wLIGHT
	MOVWF	DATO
	GOTO 	PRINT
	
ID_M
	MOVFW	ID
	MOVWF	DATO
	GOTO 	PRINT

PRINT			
	BTFSS 	DATO, 0		;De igual manera que antes, se verifica si el valor de la
	GOTO	EVEN_D		;variable es par o impar, para eventualmente llegar al numero
	GOTO 	ODD_D		;que se desea desplegar.

EVEN_D	;0,2,4,8
	BTFSS	DATO,1
	GOTO	EVEN_D2 
	GOTO	EVEN_D4

EVEN_D2	;0,4,8
	BTFSS	DATO,2
	GOTO	EVEN_D3
	GOTO	FOUR

EVEN_D3	;0,8
	BTFSS	DATO,3
	GOTO	CERO
	GOTO	EIGHT	

EVEN_D4	;2,6
	BTFSS	DATO,2
	GOTO	TWO
	GOTO	SIX
	
ODD_D	;1,3,5,7,9
	BTFSC	DATO,1
	GOTO	ODD_D4 
	GOTO	ODD_D2 

ODD_D2	;1,5,9
	BTFSC	DATO,2
	GOTO	FIVE
	GOTO	ODD_D3

ODD_D3	;1,9
	BTFSC	DATO,3
	GOTO	NINE
	GOTO	ONE

ODD_D4	;3,7
	BTFSC	DATO,2
	GOTO	SEVEN
	GOTO	THREE

;Metodos multiples para el despliegue de los numeros, debido a que el display de 
;7 segmentos es de anodo com�n los 1 y 0 han sido invertidos, a su vez para una mejor
;distribucion en el protoboard se cambiaron los puertos de salida.
;a	PORTD,3
;b	PORTD,4
;c	PORTD,2
;d	PORTD,0
;e	PORTD,1
;f	PORTD,5
;g	PORTD,6

CERO				
	MOVLW	B'11000000'	
	MOVWF	DATO		
	CALL	DISPLAY
	GOTO	MENU

ONE
	MOVLW	B'11101011'
	MOVWF	DATO
	CALL	DISPLAY
	GOTO	MENU

TWO
	MOVLW	B'10100100'
	MOVWF	DATO
	CALL	DISPLAY
	GOTO	MENU

THREE
	MOVLW	B'10100010'
	MOVWF	DATO
	CALL	DISPLAY
	GOTO	MENU

FOUR
	MOVLW	B'10001011'
	MOVWF	DATO
	CALL	DISPLAY
	GOTO	MENU

FIVE
	MOVLW	B'10010010'
	MOVWF	DATO
	CALL	DISPLAY
	GOTO	MENU

SIX
	MOVLW	B'10010000'
	MOVWF	DATO
	CALL	DISPLAY
	GOTO	MENU

SEVEN
	MOVLW	B'11100011'
	MOVWF	DATO
	CALL	DISPLAY
	GOTO	MENU

EIGHT
	MOVLW	B'10000000'
	MOVWF	DATO
	CALL	DISPLAY
	GOTO	MENU

NINE
	MOVLW	B'10000011'
	MOVWF	DATO
	CALL	DISPLAY
	GOTO	MENU

DISPLAY
	MOVF	DATO, W		;Se mueve el valor de DATO a W para luego moverlo al puerto D.
	MOVWF	PORTD
	CALL	RETARD		;Se utilizan retardo debido a la diferencia de velocidades
	CALL	RETARD		;entre la que opera el PIC y la del boton presionado.
	CALL	RETARD
	CALL	RETARD
	RETURN
	
LOOP				;Controla las llamadas para el movimiento de ambos motores.
	CALL	RESET_MOTORS	;Desde un inicio se resetean los motores para regresarlos a 
				;su posicion inicial.

	MOVLW	D'246'		;Ciclo con 246 iteraciones para mover el motor 180�
	MOVWF	COUNT
X_FOR
	CALL	CLOCKWISEX	;Llamada al movimiento
	DECFSZ	COUNT,1		;Decremento
	GOTO	X_FOR	
	
	MOVLW	D'246'		;Ciclo con 246 iteraciones para regresar el motor 180�
	MOVWF	COUNT
X_BACK
	CALL	ANTICLOCKWISEX	;Llamada al movimiento
	DECFSZ	COUNT,1		;Decremento
	GOTO	X_BACK
	
	MOVLW	D'0'		;Reinicio del contador X
	MOVWF	X
	
	CALL 	STRONGXY	;Llamada al metodo que mueve el motor al punto con mas luz.
	RETURN


CLOCKWISEX			;Movimeinto del motor X en sentido horario.
	INCF	X,1		;Incremento de la variable X para eventualmente saber en que
				;posicion se encuentra el punto con mas luz.

	MOVLW	B'00001001'	;Cuatro pasos necesarios para dar un FULL STEP con el motor.
	MOVWF	DATO_M		;Se mueve a DATO_M que es la variable que utiliza el metodo MOVE.
	CALL	MOVE

	MOVLW	B'00001100'
	MOVWF	DATO_M
	CALL	MOVE

	MOVLW	B'00000110'
	MOVWF	DATO_M
	CALL	MOVE

	MOVLW	B'00000011'
	MOVWF	DATO_M
	CALL	MOVE

	MOVLW	D'246'		;Ciclo con 246 iteraciones para mover el motor Y 180�
	MOVWF	COUNT		;Esto quiere decir que por cada paso en X, el motor Y
LOP				;recorrera los 180�.
	CALL	CLOCKWISEY
	DECFSZ	COUNT,1
	GOTO	LOP

	MOVLW	D'246'		;Ciclo con 246 iteraciones para regresar el motor Y 180�
	MOVWF	COUNT
LOP1
	CALL	ANTICLOCKWISEY
	DECFSZ	COUNT,1
	GOTO	LOP1	
	
	MOVLW	D'0'		;Reinicio del contador Y
	MOVWF	Y
	
	RETURN

CLOCKWISEY			;Movimeinto del motor Y en sentido horario.
	INCF	Y,1		;Incremento de la variable X para eventualmente saber en que
				;posicion se encuentra el punto con mas luz.

	MOVLW	B'10010000'
	MOVWF	DATO_M
	CALL	MOVE

	MOVLW	B'11000000'
	MOVWF	DATO_M
	CALL	MOVE

	MOVLW	B'01100000'
	MOVWF	DATO_M
	CALL	MOVE

	MOVLW	B'00110000'
	MOVWF	DATO_M
	CALL	MOVE	
	
	;HERE IT GOES THE LIGHT LECTURE & COMPARISSON
	
	RETURN

ANTICLOCKWISEX			;Movimeinto del motor X en sentido anti-horario.
	MOVLW	B'00000011'
	MOVWF	DATO_M
	CALL	MOVE	

	MOVLW	B'00000110'
	MOVWF	DATO_M
	CALL	MOVE

	MOVLW	B'00001100'
	MOVWF	DATO_M
	CALL	MOVE

	MOVLW	B'00001001'
	MOVWF	DATO_M
	CALL	MOVE

	RETURN	

ANTICLOCKWISEY			;Movimeinto del motor Y en sentido anti-horario.
	MOVLW	B'00110000'
	MOVWF	DATO_M
	CALL	MOVE

	MOVLW	B'01100000'
	MOVWF	DATO_M
	CALL	MOVE

	MOVLW	B'11000000'
	MOVWF	DATO_M
	CALL	MOVE

	MOVLW	B'10010000'
	MOVWF	DATO_M
	CALL	MOVE

	RETURN	


MOVE				;Metodo que envia los valores a PORT B para el movimiento de motores.
	MOVF	DATO_M, W
	MOVWF	PORTB
	CALL	RETARD		;Retardo para que los motores funcionen correctamente.
	RETURN
	
RETARD				;Metodo que genera el retardo.
	MOVLW	0xA8
	MOVWF	d1
	MOVLW	0x01
	MOVWF	d2
	
DELAY_0
	DECFSZ	d1, f
	GOTO	$+2
	DECFSZ	d2, f
	GOTO	DELAY_0

			;3 cycles
	GOTO	$+1
	NOP	
	RETURN
	 
STRONGXY			;Metodo que mueve los motores de vuelta al punto con mas luz.
	INCF	XS,0		;Se verifica que los valores de XS o YS no sean 0, de ser
	BTFSC	STATUS,Z	;asi se hace la llamada al metodo correspondiente.
	CALL	MOVEX
	
	INCF	YS,0
	BTFSC	STATUS,Z
	CALL	MOVEY
	RETURN

MOVEX				;Metodo que hace un ciclo con la cantidad de pasos necesarios
	MOVF	XS,W		;para llegar al punto con mas luz en X.
	MOVWF	COUNT
X_FINAL
	CALL	STRONGX
	DECFSZ	COUNT,1
	GOTO	X_FINAL
	RETURN
	
MOVEY				;Metodo que hace un ciclo con la cantidad de pasos necesarios
	MOVF	YS,W		;para llegar al punto con mas luz en Y.
	MOVWF	COUNT
Y_FINAL
	CALL	STRONGY
	DECFSZ	COUNT,1
	GOTO	Y_FINAL
	RETURN
	
STRONGX				;Mueve el motor SOLAMENTE en X.
	MOVLW	B'00001001'
	MOVWF	DATO_M
	CALL	MOVE

	MOVLW	B'00001100'
	MOVWF	DATO_M
	CALL	MOVE

	MOVLW	B'00000110'
	MOVWF	DATO_M
	CALL	MOVE

	MOVLW	B'00000011'
	MOVWF	DATO_M
	CALL	MOVE
	
	RETURN
	
STRONGY				;Mueve el motor SOLAMENTE en Y.
	MOVLW	B'10010000'
	MOVWF	DATO_M
	CALL	MOVE

	MOVLW	B'11000000'
	MOVWF	DATO_M
	CALL	MOVE

	MOVLW	B'01100000'
	MOVWF	DATO_M
	CALL	MOVE

	MOVLW	B'00110000'
	MOVWF	DATO_M
	CALL	MOVE	
	
	RETURN

RESET_MOTORS			;Metodo que mueve los motores de vuelta al punto inicial.
	INCF	XS,0		;Se verifica que los valores de XS o YS no sean 0, de ser
	BTFSC	STATUS,Z	;asi se hace la llamada al metodo correspondiente.
	CALL	RESETX
	
	INCF	YS,0
	BTFSC	STATUS,Z
	CALL	RESETY

	RETURN

RESETX				;Metodo que hace un ciclo con la cantidad de pasos necesarios
	MOVF	XS,W		;para llegar al punto inicial en X.
	MOVWF	COUNT
X_RESET
	CALL	ANTICLOCKWISEX
	DECFSZ	COUNT,1
	GOTO	X_RESET
	RETURN

RESETY				;Metodo que hace un ciclo con la cantidad de pasos necesarios
	MOVF	YS,W		;para llegar al punto inicial en Y.
	MOVWF	COUNT
Y_RESET
	CALL	ANTICLOCKWISEY
	DECFSZ	COUNT,1
	GOTO	Y_RESET
	RETURN
	
COMPARE				;Metodo que compara los valores de Lectura de la fotoresistencia.
	MOVF	LECTURE,W
	SUBWF	WEAKER,W	;Se realiza una resta, dependiendo si esta da un resultado  
	BTFSC	STATUS,C	;negativo o positivo es una lectura de menor o mayor valor 
	CALL	MINORLECTURE	;a las anteriores.

	MOVF	LECTURE,W
	SUBWF	STRONGER,W
	BTFSS	STATUS,C
	CALL 	GREATERLECTURE
	RETURN

GREATERLECTURE			;Metodo que almacena los valores de lectura y posicion
	MOVF	LECTURE,W	;del punto con mas luz en las variables correspondientes.
	MOVWF	STRONGER
	MOVF	X,W
	MOVWF	XS
	MOVF	Y,W
	MOVWF	YS
	RETURN

MINORLECTURE			;Metodo que almacena el valore de lectura del punto con 
	MOVF	LECTURE,W	;menos luz en la variable correspondiente.
	MOVWF	WEAKER
	RETURN	
END
