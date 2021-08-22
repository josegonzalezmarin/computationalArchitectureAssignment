* ---------------------------------> Inicializa el SP y el PC

        ORG     $0
        DC.L    $8000           * Pila
        DC.L    INICIO          * PC

        ORG     $400

* ---------------------------------> Definición de equivalencias

MR1A    EQU     $effc01       * de modo A (escritura)
MR2A    EQU     $effc01       * de modo A (2º escritura)
SRA     EQU     $effc03       * de estado A (lectura)
CSRA    EQU     $effc03       * de seleccion de reloj A (escritura)
CRA     EQU     $effc05       * de control A (escritura)
TBA     EQU     $effc07       * buffer transmision A (escritura)
RBA     EQU     $effc07       * buffer recepcion A  (lectura)
ACR		EQU		$effc09	      * de control auxiliar
IMR     EQU     $effc0B       * de mascara de interrupcion A (escritura)
ISR     EQU     $effc0B       * de estado de interrupcion A (lectura)
MR1B    EQU     $effc11       * de modo B (escritura)
MR2B    EQU     $effc11       * de modo B (2º escritura)
CRB     EQU     $effc15	      * de control A (escritura)
TBB     EQU     $effc17       * buffer transmision B (escritura)
RBB		EQU		$effc17       * buffer recepcion B (lectura)
SRB     EQU     $effc13       * de estado B (lectura)
CSRB	EQU		$effc13       * de seleccion de reloj B (escritura)
IVR 	EQU		$effc19		  * del vector de interrupcion 

CR		EQU		$0D	     	 * Carriage Return
LF		EQU		$0A	     	 * Line Feed
FLAGT	EQU		2	      	 * Flag de transmisión
FLAGR   EQU     0	     	 * Flag de recepción

* ---------------------------------> VARIABLES AUXILIARES 

IMR_C:	 	DC.B 	0

* ---------------------------------> BUFFERS INTERNOS
TAM_BUF: 		EQU		2001

PI_RECA:	DC.L	0		* Puntero insercion, buffer recepcion A
PE_RECA:	DC.L 	0		* Puntero extraccion, buffer recepcion A
BRECA:		DS.B 	TAM_BUF	* Buffer recepcion A

PI_RECB:	DC.L	0		* Puntero insercion, buffer recepcion B
PE_RECB:	DC.L 	0		* Puntero extraccion, buffer recepcion B
BRECB:		DS.B 	TAM_BUF	* Buffer recepcion B

PI_TRANA:	DC.L	0		* Puntero insercion, buffer transmision A
PE_TRANA:	DC.L 	0		* Puntero extraccion, buffer transmision A
BTRANA:		DS.B 	TAM_BUF	* Buffer transmision A

PI_TRANB:	DC.L	0		* Puntero insercion, buffer transmision B
PE_TRANB:	DC.L 	0		* Puntero extraccion, buffer transmision B
BTRANB:		DS.B 	TAM_BUF	* Buffer transmision B

* ---------------------------------> BUFFER PRUEBA

PI_PRUEBA:	DC.L	0		
PE_PRUEBA:	DC.L 	0		
BPRUEBA:	DS.B 	TAM_BUF	

* ---------------------------------> SUBRUTINAS

* -----------------------------------------------------------------------------------------------------------> LEECAR
LEECAR:		AND.L 	#3,D0				* Mantenemos los 3 bits menos significativos dejando el resto a 0
			
			CMP.L 	#1,D0				* Si D0=1 estamos en el buffer de recepcion de B
			BEQ		LEE_BREC
			
			CMP.L 	#2,D0				* Si D0=2 estamos en el buffer de transmision de A
			BEQ		LEE_ATRAN
			
			CMP.L 	#3,D0				* Si D0=3 estamos en el buffer de transmision de B
			BEQ		LEE_BTRAN
			
			* Si no ha saltado ninguna estamos en el buffer interno de recepcion de A
			
			MOVE.L 	PI_RECA,A0
			MOVE.L 	PE_RECA,A1
			SUBA.L 	A1,A0
			CMP.L 	#0,A0 				* Si PI-PE es 0, los punteros estan en el mismo sitio y el buffer esta vacio
			BEQ 	LEE_VAC
				
			MOVE.B 	(A1)+,D0			* Cargamos el caracter en D0 y postincrementamos A1
			
			MOVE.L 	A1,PE_RECA			* Actualizamos el puntero incrementado
			CMP.L 	#BRECA+TAM_BUF,A1   * ¿Se ha salido del buffer el puntero con el incremento?
			BLE		FIN_LEE				* No: terminamos
			MOVE.L 	#BRECA,PE_RECA		* Si: reiniciamos el puntero al inicio del buffer
			BRA		FIN_LEE
			
LEE_BREC:	MOVE.L 	PI_RECB,A0
			MOVE.L 	PE_RECB,A1
			SUBA.L 	A1,A0
			CMP.L 	#0,A0 				* Si PI-PE es 0, los punteros estan en el mismo sitio y el buffer esta vacio
			BEQ 	LEE_VAC
				
			MOVE.B 	(A1)+,D0			* Cargamos el caracter en D0 y postincrementamos A1
			
			MOVE.L 	A1,PE_RECB			* Actualizamos el puntero incrementado
			CMP.L 	#BRECB+TAM_BUF,A1   * ¿Se ha salido del buffer el puntero con el incremento?
			BLE		FIN_LEE				* No: terminamos
			MOVE.L 	#BRECB,PE_RECB		* Si: reiniciamos el puntero al inicio del buffer
			BRA		FIN_LEE
			
LEE_ATRAN:	MOVE.L 	PI_TRANA,A0		
			MOVE.L 	PE_TRANA,A1	
			SUBA.L 	A1,A0
			CMP.L 	#0,A0 				* Si PI-PE es 0, los punteros estan en el mismo sitio y el buffer esta vacio
			BEQ 	LEE_VAC
			
			MOVE.B 	(A1)+,D0			* Cargamos el caracter en D0 y postincrementamos A1
			
			MOVE.L 	A1,PE_TRANA			* Actualizamos el puntero incrementado
			CMP.L 	#BTRANA+TAM_BUF,A1  * ¿Se ha salido del buffer el puntero con el incremento?
			BLE		FIN_LEE				* No: terminamos
			MOVE.L 	#BTRANA,PE_TRANA	* Si: reiniciamos el puntero al inicio del buffer
			BRA		FIN_LEE
			
LEE_BTRAN:	MOVE.L 	PI_TRANB,A0	
			MOVE.L 	PE_TRANB,A1
			SUBA.L 	A1,A0
			CMP.L 	#0,A0 				* Si PI-PE es 0, los punteros estan en el mismo sitio y el buffer esta vacio
			BEQ 	LEE_VAC
			
			MOVE.B 	(A1)+,D0			* Cargamos el caracter en D0 y postincrementamos A1
			
			MOVE.L 	A1,PE_TRANB			* Actualizamos el puntero incrementado
			CMP.L 	#BTRANB+TAM_BUF,A1  * ¿Se ha salido del buffer el puntero con el incremento?
			BLE		FIN_LEE				* No: terminamos
			MOVE.L 	#BTRANB,PE_TRANB	* Si: reiniciamos el puntero al inicio del buffer
			BRA		FIN_LEE

LEE_VAC:	MOVE.L	#-1,D0				* D0 <- -1

FIN_LEE:	RTS

* -----------------------------------------------------------------------------------------------------------> ESCCAR
ESCCAR:		AND.L 	#3,D0				* Mantenemos los 3 bits menos significativos dejando el resto a 0
			
			CMP.L 	#1,D0				* Si D0=1 estamos en el buffer de recepcion de B
			BEQ		ESC_BREC
			
			CMP.L 	#2,D0				* Si D0=2 estamos en el buffer de transmision de A
			BEQ		ESC_ATRAN
			
			CMP.L 	#3,D0				* Si D0=3 estamos en el buffer de transmision de B
			BEQ		ESC_BTRAN

			* Si no ha saltado ninguna estamos en el buffer interno de recepcion de A
			
			MOVE.L 	PI_RECA,A0			
			MOVE.L 	PE_RECA,A1
			SUBA.L 	A1,A0
			CMP.L 	#-1,A0 				* Si PI-PE es -1, los punteros estan al lado uno del otro y el buffer esta lleno
			BEQ 	ESC_LLEN
			CMP.L 	#2000,A0			* Si PI-PE es 2001, PE esta al inicio del buffer y PE al final. El buffer esta lleno
			BEQ 	ESC_LLEN
			
			MOVE.L 	#0,D0				* Ya sabemos que hay hueco por lo que la escritura va a tener exito
			MOVE.L 	PI_RECA,A0
			MOVE.B 	D1,(A0)				* Guardamos el dato en el buffer
			
			CMP.L 	#BRECA+TAM_BUF,A0	* ¿Estamos al final del buffer?
			BNE		CONT_AREC
			MOVE.L	#BRECA,PI_RECA		* Si: reiniciamos el puntero al inicio del buffer
			BRA 	FIN_ESC
CONT_AREC: 	ADDA.L 	#1,A0				* No: incrementamos el puntero y lo actualizamos
			MOVE.L 	A0,PI_RECA
			BRA 	FIN_ESC
			
ESC_BREC: 	MOVE.L 	PI_RECB,A0			
			MOVE.L 	PE_RECB,A1			
			SUBA.L 	A1,A0
			CMP.L 	#-1,A0 				* Si PI-PE es -1, los punteros estan al lado uno del otro y el buffer esta lleno
			BEQ 	ESC_LLEN
			CMP.L 	#2000,A0			* Si PI-PE es 2001, PE esta al inicio del buffer y PE al final. El buffer esta lleno
			BEQ 	ESC_LLEN
			
			MOVE.L 	#0,D0				* Ya sabemos que hay hueco por lo que la escritura va a tener exito
			MOVE.L 	PI_RECB,A0
			MOVE.B 	D1,(A0)				* Guardamos el dato en el buffer
			
			CMP.L 	#BRECB+TAM_BUF,A0	* ¿Estamos al final del buffer?
			BNE		CONT_BREC
			MOVE.L	#BRECB,PI_RECB		* Si: reiniciamos el puntero al inicio del buffer
			BRA 	FIN_ESC
CONT_BREC: 	ADDA.L 	#1,A0				* No: incrementamos el puntero y lo actualizamos
			MOVE.L 	A0,PI_RECB
			BRA 	FIN_ESC		
			
ESC_ATRAN:	MOVE.L 	PI_TRANA,A0			
			MOVE.L 	PE_TRANA,A1
			SUBA.L 	A1,A0
			CMP.L 	#-1,A0 				* Si PI-PE es -1, los punteros estan al lado uno del otro y el buffer esta lleno
			BEQ 	ESC_LLEN
			CMP.L 	#2000,A0			* Si PI-PE es 2001, PE esta al inicio del buffer y PE al final. El buffer esta lleno
			BEQ 	ESC_LLEN
			
			MOVE.L 	#0,D0				* Ya sabemos que hay hueco por lo que la escritura va a tener exito
			MOVE.L 	PI_TRANA,A0
			MOVE.B 	D1,(A0)				* Guardamos el dato en el buffer
			
			CMP.L 	#BTRANA+TAM_BUF,A0	* ¿Estamos al final del buffer?
			BNE		CONT_ATRAN
			MOVE.L	#BTRANA,PI_TRANA		* Si: reiniciamos el puntero al inicio del buffer
			BRA 	FIN_ESC
CONT_ATRAN: ADDA.L 	#1,A0				* No: incrementamos el puntero y lo actualizamos
			MOVE.L 	A0,PI_TRANA
			BRA 	FIN_ESC
			
ESC_BTRAN:	MOVE.L 	PI_TRANB,A0		
			MOVE.L 	PE_TRANB,A1	
			SUBA.L 	A1,A0
			CMP.L 	#-1,A0 				* Si PI-PE es -1, los punteros estan al lado uno del otro y el buffer esta lleno
			BEQ 	ESC_LLEN
			CMP.L 	#2000,A0			* Si PI-PE es 2001, PE esta al inicio del buffer y PE al final. El buffer esta lleno
			BEQ 	ESC_LLEN
			
			MOVE.L 	#0,D0				* Ya sabemos que hay hueco por lo que la escritura va a tener exito
			MOVE.L 	PI_TRANB,A0
			MOVE.B 	D1,(A0)				* Guardamos el dato en el buffer
			
			CMP.L 	#BTRANB+TAM_BUF,A0	* ¿Estamos al final del buffer?
			BNE		CONT_BTRAN
			MOVE.L	#BTRANB,PI_TRANB		* Si: reiniciamos el puntero al inicio del buffer
			BRA 	FIN_ESC
CONT_BTRAN: ADDA.L 	#1,A0				* No: incrementamos el puntero y lo actualizamos
			MOVE.L 	A0,PI_TRANB
			BRA 	FIN_ESC		
			
ESC_LLEN:	MOVE.L	#-1,D0				* D0 <- -1

FIN_ESC:	RTS
		
* -----------------------------------------------------------------------------------------------------------> SCAN
SCAN:
			LINK	A6,#-10
			MOVE.L 	8(A6),A0			* A0 guarda Buffer
			MOVE.W	12(A6),D1			* D1 guarda Descriptor
			MOVE.W 	14(A6),D2			* D2 guarda Tamaño
			MOVE.L 	#0,D0				* Ponemos a 0 el contador
			
			CMP.W	#0,D2
			BEQ 	FIN_SCAN
			
			CMP.W 	#0,D1				* Si D1=0 estamos en la linea A
			BEQ		SCAN_ALIN
			
			CMP.W 	#1,D1				* Si D1=1 estamos en la linea B
			BEQ		SCAN_BLIN
			
			BRA 	SCAN_ERR
			
SCAN_ALIN:	MOVE.L 	A0,-4(A6)			* Salvaguardamos variables locales en marco de pila
			MOVE.W 	D2,-6(A6)
			MOVE.L 	D0,-10(A6)
			
			MOVE.L 	#0,D0				* Elegimos la linea de recepcion de A
			BSR 	LEECAR				* Llamamos a LEECAR
			MOVE.L 	D0,D1 				* Guardamos el byte sacado del buffer en D1
			MOVE.L 	-10(A6),D0			* Recuperamos ya el contador por si el buffer esta vacio y hay que acabar
			CMP.L 	#-1,D1				* Comprobamos que no hemos vaciado el buffer
			BEQ 	FIN_SCAN
			
			MOVE.L 	-4(A6),A0			* Recuperamos variables locales del marco de pila
			MOVE.W 	-6(A6),D2
			
			MOVE.B 	D1,(A0)+			* Guardamos el bit en el buffer
			ADD.L	#1,D0 				* Incrementamos contador
			CMP.W	D0,D2				* Si contador = tamaño, acabamos
			BEQ		FIN_SCAN
			BRA 	SCAN_ALIN			* Cuando contador != tamaño, repetimos
			
SCAN_BLIN:	MOVE.L 	A0,-4(A6)			* Salvaguardamos variables locales en marco de pila
			MOVE.W 	D2,-6(A6)
			MOVE.L 	D0,-10(A6)
			
			MOVE.L 	#1,D0				* Elegimos la linea de recepcion de B
			BSR 	LEECAR				* Llamamos a LEECAR
			MOVE.L 	D0,D1 				* Guardamos el bit sacado del buffer en D1
			MOVE.L 	-10(A6),D0			* Recuperamos ya el contador por si el buffer esta vacio y hay que acabar
			CMP.L 	#-1,D1				* Comprobamos que no hemos vaciado el buffer
			BEQ 	FIN_SCAN
			
			MOVE.L 	-4(A6),A0			* Recuperamos variables locales del marco de pila
			MOVE.W 	-6(A6),D2
			
			MOVE.B 	D1,(A0)+			* Guardamos el bit en el buffer
			ADD.L	#1,D0 				* Incrementamos contador
			CMP.W	D0,D2				* Si contador = tamaño, acabamos
			BEQ		FIN_SCAN
			BRA 	SCAN_BLIN			* Cuando contador != tamaño, repetimos
			
SCAN_ERR:	MOVE.L 	#-1,D0
			
FIN_SCAN:	UNLK	A6
			RTS
		
* -----------------------------------------------------------------------------------------------------------> PRINT
PRINT:
			LINK	A6,#-10
			MOVE.L 	8(A6),A0			* A0 guarda Buffer
			MOVE.W	12(A6),D1			* D1 guarda Descriptor
			MOVE.W 	14(A6),D2			* D2 guarda Tamaño
			MOVE.L 	#0,D0				* Ponemos a 0 el contador
				
			CMP.W 	#0,D1				* Si D1=0 estamos en la linea A
			BEQ		PRINT_ALIN
			
			CMP.W 	#1,D1				* Si D1=1 estamos en la linea B
			BEQ		PRINT_BLIN
			
			BRA 	PRINT_ERR
			
PRINT_ALIN:	CMP.W	#0,D2				* Si tamaño = 0 terminamos
			BEQ 	FIN_PRINT
			
			MOVE.W 	D2,-6(A6)			* Salvaguardamos variables locales en marco de pila
			MOVE.L 	D0,-10(A6)
			
			MOVE.L 	#2,D0 				* Seleccionamos el buffer correspondiente (transmision de A)
			MOVE.B 	(A0)+,D1			* Pasamos como parametro el bit a insertar en el buffer
			MOVE.L 	A0,-4(A6)			* Salvaguardamos A0 tras el incremento
			BSR 	ESCCAR
			MOVE.L 	D0,D1 				* Guardamos el estado de la llamada en D1
			MOVE.L 	-10(A6),D0			* Recuperamos ya el contador por si el buffer esta lleno y hay que acabar
			CMP.L 	#-1,D1				* Comprobamos que el buffer no está lleno
			BEQ 	FIN_ALIN
			
			MOVE.L 	-4(A6),A0			* Recuperamos variables locales del marco de pila
			MOVE.W 	-6(A6),D2
			
			ADD.L	#1,D0 				* Incrementamos contador
			CMP.W	D0,D2				* Si contador != tamaño, repetimos
			BNE		PRINT_ALIN
			
FIN_ALIN:	CMP.L 	#0,D0 				* Si no ha habido inserciones, terminamos
			BEQ		FIN_PRINT
			MOVE.W  #$2700,SR			* Seccion critica
			BSET  	#0,IMR_C
			MOVE.B	IMR_C,IMR			* Si las ha habido, activamos interrupciones de transmision
			MOVE.W  #$2000,SR			* Fin seccion critica
			BRA 	FIN_PRINT
			
PRINT_BLIN:	CMP.W	#0,D2				* Si tamaño = 0 terminamos
			BEQ 	FIN_PRINT

			MOVE.W 	D2,-6(A6)			* Salvaguardamos variables locales en marco de pila
			MOVE.L 	D0,-10(A6)
			
			MOVE.L 	#3,D0 				* Seleccionamos el buffer correspondiente (transmision de B)
			MOVE.B 	(A0)+,D1			* Pasamos como parametro el bit a insertar en el buffer
			MOVE.L 	A0,-4(A6)			* Salvaguardamos A0 tras el incremento
			BSR 	ESCCAR
			MOVE.L 	D0,D1 				* Guardamos el estado de la llamada en D1
			MOVE.L 	-10(A6),D0			* Recuperamos ya el contador por si el buffer esta lleno y hay que acabar
			CMP.L 	#-1,D1				* Comprobamos que el buffer no está lleno
			BEQ 	FIN_BLIN
			
			MOVE.L 	-4(A6),A0			* Recuperamos variables locales del marco de pila
			MOVE.W 	-6(A6),D2
			
			ADD.L	#1,D0 				* Incrementamos contador
			CMP.W	D0,D2				* Si contador != tamaño, repetimos
			BNE		PRINT_BLIN
			
FIN_BLIN:	CMP.L 	#0,D0 				* Si no ha habido inserciones, terminamos
			BEQ		FIN_PRINT
			MOVE.W  #$2700,SR			* Seccion critica
			BSET  	#4,IMR_C
			MOVE.B	IMR_C,IMR			* Si las ha habido, activamos interrupciones de transmision
			MOVE.W  #$2000,SR			* Fin seccion critica
			BRA 	FIN_PRINT
			
PRINT_ERR:	MOVE.L 	#-1,D0
			
FIN_PRINT:	UNLK  	A6
			RTS
		
* -----------------------------------------------------------------------------------------------------------> INIT
INIT:
			MOVE.B	#%00000011,MR1A		* 8 bits por caracter y solicitud de interrupcion
			MOVE.B	#%00000011,MR1B
			
			MOVE.B	#%00000000,MR2A		* No activado el eco
			MOVE.B	#%00000000,MR2B
			
			MOVE.B 	#%00000000,ACR		* Conjunto 1
			MOVE.B 	#%11001100,CSRA		* Velocidad de recepcion y transmision 38400
			MOVE.B 	#%11001100,CSRB
			
			MOVE.B 	#%00000101,CRA		* Full Duplex
			MOVE.B 	#%00000101,CRB
			
			MOVE.B 	#%01000000,IVR		* Vector de interrupcion = 0x40
			
			MOVE.B 	#%00100010,IMR		* Interrupciones de recepcion activadas y de transmision desactivadas
			MOVE.B 	#%00100010,IMR_C
			
			MOVE.L 	#$100,A0
			MOVE.L 	#RTI,(A0)			* Ponemos la dirección de la RTI en la dirección 0x100 (la correspondiente en la tabla de vectores)
			
			*--- INICIALIZAR PUNTEROS ---
			MOVE.L	#BRECA,PI_RECA
			MOVE.L	#BRECA,PE_RECA
			MOVE.L	#BRECB,PI_RECB
			MOVE.L	#BRECB,PE_RECB

			MOVE.L	#BTRANA,PI_TRANA
			MOVE.L	#BTRANA,PE_TRANA
			MOVE.L	#BTRANB,PI_TRANB
			MOVE.L	#BTRANB,PE_TRANB
			RTS
			
* -----------------------------------------------------------------------------------------------------------> RTI
RTI:
			MOVE.L 	D0,-(A7)			* Guardamos los registros sensibles en pila para recuperarlos al final
			MOVE.L 	D1,-(A7)
			MOVE.L 	D2,-(A7)
			MOVE.L 	A0,-(A7)
			MOVE.L 	A1,-(A7)
			MOVE.L 	A2,-(A7)
			
SIG_INTER:	MOVE.L 	#0,D2				* Borramos lo que hubiese en D2 (y utilizamos D2 para evitar condiciones de carrera)
			MOVE.B 	ISR,D2			
			AND.B 	IMR_C,D2			* En D2 acabamos con el idenficador de interrupciones
			
			BTST 	#1,D2				* Si el bit 5 esta activo es interrupcion de recepcion en A
			BNE 	RTI_AREC
			
			BTST 	#5,D2				* Si el bit 5 esta activo es interrupcion de recepcion en B
			BNE 	RTI_BREC
			
			BTST 	#0,D2				* Si el bit 0 esta activo es interrupcion de transmision en A
			BNE 	RTI_ATRAN
			
			BTST 	#4,D2				* Si el bit 4 esta activo es interrupcion de transmision en B
			BNE 	RTI_BTRAN
			
			BRA 	FIN_RTI
		
RTI_AREC:	MOVE.L 	#0,D0				* Seleccionamos el buffer pertinente para ESCCAR
			MOVE.B 	RBA,D1				* Pasamos como parametro el caracter recibido por linea
			BSR 	ESCCAR
			BRA 	SIG_INTER
		
RTI_BREC:	MOVE.L 	#1,D0
			MOVE.B 	RBB,D1
			BSR 	ESCCAR
			BRA 	SIG_INTER

RTI_ATRAN:	MOVE.L 	#2,D0				* Seleccionamos el buffer pertinente para LEECAR
			BSR 	LEECAR
			CMP.L 	#-1,D0				* Si el buffer no esta vacio continuamos
			BNE 	RTI_ACON
			BCLR	#0,IMR_C			* Si el buffer esta vacio desactivamos las interrupciones de transmision
			MOVE.B	IMR_C,IMR
			BRA 	SIG_INTER
RTI_ACON:	MOVE.B 	D0,TBA				* Pasamos el caracter sacado del buffer interno al buffer de transmision de la linea A
			BRA 	SIG_INTER

RTI_BTRAN:	MOVE.L 	#3,D0
			BSR 	LEECAR
			CMP.L 	#-1,D0
			BNE 	RTI_BCON
			BCLR	#4,IMR_C
			MOVE.B	IMR_C,IMR
			BRA 	SIG_INTER
RTI_BCON	MOVE.B 	D0,TBB
			BRA 	SIG_INTER
		
FIN_RTI:	MOVE.L 	(A7)+,A2
			MOVE.L 	(A7)+,A1 
			MOVE.L 	(A7)+,A0
			MOVE.L 	(A7)+,D2			* Recuperamos los registros sensibles de la pila
			MOVE.L  (A7)+,D1
			MOVE.L 	(A7)+,D0
			RTE

* ---------------------------------> FIN SUBRUTINAS

* ---------------------------------> PROGRAMA PRINCIPAL

BUFFER: 	DS.B 	2100 				* Buffer para lectura y escritura de caracteres
PARDIR: 	DC.L 	0 					* Direcci´on que se pasa como par´ametro
PARTAM:		DC.W 	0 					* Tama~no que se pasa como par´ametro
CONTC: 		DC.W 	0 					* Contador de caracteres a imprimir
DESA: 		EQU 	0 					* Descriptor l´ınea A
DESB: 		EQU 	1 					* Descriptor l´ınea B
TAMBS: 		EQU 	100 					* Tama~no de bloque para SCAN
TAMBP: 		EQU 	100 					* Tama~no de bloque para PRINT

INICIO: 	MOVE.L 	#BUS_ERROR,8 		* Bus error handler
			MOVE.L 	#ADDRESS_ER,12 		* Address error handler
			MOVE.L 	#ILLEGAL_IN,16 		* Illegal instruction handler
			MOVE.L 	#PRIV_VIOLT,32 		* Privilege violation handler
			MOVE.L 	#ILLEGAL_IN,40 		* Illegal instruction handler
			MOVE.L 	#ILLEGAL_IN,44 		* Illegal instruction handler
			
			BSR 	INIT
			MOVE.W #$2000,SR 			* Permite interrupciones
			
			* -- SCAN -- *
BUCPR: 		MOVE.W 	#TAMBS,PARTAM 		* Inicializa par´ametro de tama~no
			MOVE.L 	#BUFFER,PARDIR 		* Par´ametro BUFFER = comienzo del buffer
OTRAL: 		MOVE.W 	PARTAM,-(A7) 		* Tama~no de bloque
			MOVE.W 	#DESA,-(A7) 		* Puerto A
			MOVE.L 	PARDIR,-(A7) 		* Direcci´on de lectura
ESPL: 		BSR 	SCAN
			ADD.L 	#8,A7 				* Restablece la pila
			ADD.L 	D0,PARDIR 			* Calcula la nueva direcci´on de lectura
			SUB.W 	D0,PARTAM 			* Actualiza el n´umero de caracteres le´ıdos
			BNE 	OTRAL 				* Si no se han le´ıdo todas los caracteres
										* del bloque se vuelve a leer
			
			* -- PRINT -- *
			MOVE.W 	#TAMBS,CONTC 		* Inicializa contador de caracteres a imprimir
			MOVE.L 	#BUFFER,PARDIR 		* Par´ametro BUFFER = comienzo del buffer
OTRAE:		MOVE.W 	#TAMBP,PARTAM 		* Tama~no de escritura = Tama~no de bloque
ESPE: 		MOVE.W 	PARTAM,-(A7) 		* Tama~no de escritura
			MOVE.W 	#DESA,-(A7) 		* Puerto A
			MOVE.L 	PARDIR,-(A7) 		* Direcci´on de escritura
			BSR 	PRINT
			ADD.L 	#8,A7 				* Restablece la pila
			ADD.L 	D0,PARDIR 			* Calcula la nueva direcci´on del buffer
			SUB.W 	D0,CONTC 			* Actualiza el contador de caracteres
			BEQ 	SALIR 				* Si no quedan caracteres se acaba
			SUB.W 	D0,PARTAM 			* Actualiza el tama~no de escritura
			BNE 	ESPE 				* Si no se ha escrito todo el bloque se insiste
			CMP.W 	#TAMBP,CONTC 		* Si el no de caracteres que quedan es menor que
										* el tama~no establecido se imprime ese n´umero
			BHI 	OTRAE 				* Siguiente bloque
			MOVE.W 	CONTC,PARTAM
			BRA 	ESPE 				* Siguiente bloque
			
SALIR: 		BRA 	BUCPR


BUS_ERROR: 	BREAK 						* Bus error handler
			NOP
			
ADDRESS_ER: BREAK 						* Address error handler
			NOP
			
ILLEGAL_IN: BREAK 						* Illegal instruction handler
			NOP
			
PRIV_VIOLT: BREAK						* Privilege violation handler
			NOP

FIN_FIN:    BREAK
			NOP
