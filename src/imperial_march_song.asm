; *****************************************************************************
; Proyect: Imperial March Song (Intro)
; Author:  Matias Quintana Rosales
; Date: inicio - 19/8/2011
;       fin    -
;       fecha de entrega - 20/10/11
; *****************************************************************************

.include "C:\VMLAB\include\m8def.inc"
.def temp     = r16
.def cont10ms = r17
.def sonar    = r18 ; O : nota
						  ; 1 : silencio
.def sec1     = r19
.def sec2     = r20
.def silencio = r21
.def cont 	  = r22
.def notas    = r23
.def aux      = r24



reset:
   rjmp start
   reti      ; Addr $01
   reti      ; Addr $02
   reti      ; Addr $03
   reti      ; Addr $04
   reti      ; Addr $05
   rjmp isr_oc1a; Addr $06        Use 'rjmp myVector'
   reti      ; Addr $07        to define a interrupt vector
   reti      ; Addr $08
   reti      ; Addr $09
   reti      ; Addr $0A
   reti      ; Addr $0B        This is just an example
   reti      ; Addr $0C        Not all MCUs have the same
   reti      ; Addr $0D        number of interrupt vectors
   reti      ; Addr $0E
   reti      ; Addr $0F
   reti      ; Addr $10



;******************************************************************************
;******************************************************************************
;**********************  SUBRUTINA DE INTERRUPCION  ***************************
;******************************************************************************
;******************************************************************************

isr_oc1a:
   push temp
	in temp, sreg
	push temp
	cp cont, cont10ms   ;compara con el tiempo de espera deseado
	breq pasaron10ms
	inc cont            ;sino, incrementa el cont de entradas
   rjmp salir_isr

pasaron10ms:
	ldi cont, 0			  ;reiniciamos el contador
	cpi sonar, 0        ;es el silencio de la nota o del silencio en si?
	breq silencio_sonar
   rjmp silencio_silencio

silencio_sonar:     ;sonar = 0

	ldi silencio, 1
	rjmp salir_isr
	
silencio_silencio:  ;sonar = 1

	ldi silencio, 0	
	rjmp salir_isr
	
salir_isr:
	
	pop temp
	out sreg, temp
	pop temp
	reti

;******************************************************************************
;******************************************************************************
;**********************     CONFIGURACION TIMER1    ***************************
;******************************************************************************
;******************************************************************************
;                           Modo CTC con OCR1A
;                 0<<WGM13 1<<WGM12  0<<WGM11 0<<WGM10
;
;                          Preescalador = 1
;                       0<<CS12 0<<CS11 1<<CS10
;
;                      interrupciones habilitadas
;                              1<<OCIE1A
;
;                    generador de ondas habilitado
;                          0<<COM1A1 1<<COM1A0

conf_timer1:
	push temp
	ldi temp, (0<<COM1A1)|(1<<COM1A0)|(0<<WGM11)|(0<<WGM10)
	out TCCR1A, temp
	ldi temp, (0<<WGM13) |(1<<WGM12) | (1<<CS10)
	out TCCR1B, temp
	ldi temp, 1<<OCIE1A
	out TIMSK, temp
	pop temp
	ret	
	
;******************************************************************************
;******************************************************************************
;**********************    PROGRAMA PRINCIPAL  ********************************
;******************************************************************************
;******************************************************************************
; 										IMPERIAL MARCH
; orden    1  2  3  4   5   6  7   8   9  10 11 12  13  14  15  16  17  18
; nota     G  G  G  D#  A#  G  D#  A#  G  D  D  D   D#  A#  F#  D#  A#  G
; octava   3  3  3  3   3   3  3   3   3  4  4  4   4   3   3   3   3   3
; avance   x  x  x  x   x   x  x   x   x  x  x  x       x       x   x   x
;
; Disposicion de LEDS
;
;                   PD0   PD1                  PD2  PD3
;                   sec1 sec2                 sec2  sec1
;
;
;
;                              DARTH VADER
;
;
;
;                   PD4   PD5                  PD6  PD7
;                   sec1 sec2                 sec2  sec1
;
;
;
;    G   = 392Hz
;    A#  = 466Hz
;    D#  = 311Hz
;    D4  = 587Hz
;    F#  = 370Hz	
;    D#4 = 622Hz

start:
	ldi temp, high(ramend)
	out SPH, temp
	ldi temp, low(ramend)
	out SPL, temp
	ldi temp, 2
	out ddrb, temp  		;OC1A salida
	ldi temp, $FF
	out ddrd, temp       ;PORTD como salida
	ldi temp, 0
	out portd, temp      ;comenzan apagados
	ldi notas, 1         ;inicializamos a la primera nota
	ldi silencio, 0
	ldi cont, 0
	ldi sonar, 0
	ldi sec1, 0b10011001
	ldi sec2, 0b01100110
	rcall conf_timer1

	SEI
	
imperial_march:
   cpi notas, 1
	breq notaG
	cpi notas, 2
	breq notaG
	cpi notas, 3
	breq notaG
	cpi notas, 4
	breq notaDsharpnollega
	cpi notas, 5
	breq notaAsharpnollega
	cpi notas, 6
	breq notaG
	cpi notas, 7
	breq notaDsharpnollega
	cpi notas, 8
	breq notaAsharpnollega
	cpi notas, 9
	breq notaG2nollega
	cpi notas, 10
	breq notaD4nollega
	cpi notas, 11
	breq notaD4nollega
	cpi notas, 12
	breq notaD4nollega
	cpi notas, 13
	breq notaDsharp4nollega
	cpi notas, 14
	breq notaAsharpcarajonollega
	cpi notas, 15
	breq notaFsharpnollega
	cpi notas, 16
	breq notaDsharp
	cpi notas, 17
	breq notaAsharpnollega
	cpi notas, 18
	breq notaG
   rjmp forever

notaAsharpcarajonollega:
	rjmp notaAsharpcarajo
	
notaDsharpnollega:
	rjmp notaDsharp

notaAsharpnollega:
	rjmp notaAsharp

notaFsharpnollega:
	rjmp notaFsharp
	
notaDsharp4nollega:
	rjmp notaDsharp4
		
notaG2nollega:
	rjmp notaG2
	
notaD4nollega:
	rjmp notaD4	
	
forever:
   CLI
   ldi temp, 0
   out portb, temp
	rjmp forever
;  Para determinar el valor de OCR1A:
;  P=1
;  N = fin/(2*fout) - 1

;********************************PRIMERA NOTA**********************************
;********************************SEGUNDA NOTA**********************************
;********************************TERCERA NOTA**********************************
;**********************************SEXTA NOTA**********************************
;***************************DECIMOOCTAVA NOTA**********************************
notaG:
	ldi sonar, 0
	ldi temp, high(1275)
	out OCR1AH, temp
	ldi temp, low(1275)
	out OCR1AL, temp
	ldi temp, 2
	out ddrb, temp
	inc notas
	ldi cont10ms, 251      ;tiempo que durara la nota
	cpi notas, 1
	breq sec1_G
	cpi notas, 2
	breq sec2_G
	cpi notas, 3
	breq sec1_G
	cpi notas, 6
	breq sec2_G
	cpi notas, 18
	breq sec2_G
sec1_G:
	out portd, sec1
	rjmp sonando1236_18
sec2_G:
	out portd, sec2
	rjmp sonando1236_18
	
sonando1236_18:
	cpi silencio, 1        ;aqui "ocurren" interrupciones
	brne sonando1236_18    ;sino son iguales sigo reproduciendo la nota
	                       ;si llego aca sono lo que debia sonar
	ldi sonar, 1           ;le toca el silencio al silencio en si
	ldi cont10ms, 220      ;tiempo que durara el silencio
	ldi temp, 0<<COM1A0    ;dejamos de emitir la nota
	out TCCR1A, temp
	ldi temp, 0
	out portb, temp
	
silencio1236_18:
   cpi silencio, 0        ;aqui "ocurren" interrupciones
   ldi temp, 0
   out portd, temp        ;apagamos leds
	brne silencio1236_18
	ldi temp, 1<<COM1A0
	out TCCR1A, temp
	ldi temp, 0
	out OCR1AH, temp
	out OCR1AL, temp
	rjmp imperial_march
;******************************************************************************


;*********************************CUARTA NOTA**********************************
;*********************************SETIMA NOTA**********************************
;****************************DECIMOSEXTA NOTA**********************************
notaDsharp:
	ldi sonar, 0
	ldi temp, high(1607)
	out OCR1AH, temp
	ldi temp, low(1607)
	out OCR1AL, temp
	inc notas
	ldi cont10ms, 181   ;tiempo que durara la nota
	cpi notas, 4
	breq sec2_Dsharp
	cpi notas, 7
	breq sec1_Dsharp
	cpi notas, 16
	breq sec2_Dsharp

sec1_Dsharp:
	out portd, sec1
	rjmp sonando47_16
sec2_Dsharp:
	out portd, sec2
	rjmp sonando47_16	
	
	
sonando47_16:
	cpi silencio, 1     ;aqui "ocurren" interrupciones
	brne sonando47_16   ;sino son iguales sigo reproduciendo la nota
	                    ;si llego aca sono lo que debia sonar
	ldi sonar, 1        ;le toca el silencio al silencio en si
	ldi cont10ms, 50    ;tiempo que durara el silencio
	ldi temp, 0<<COM1A0 ;dejamos de emitir la nota
	out TCCR1A, temp
	ldi temp, 0
	out portb, temp
silencio47_16:
   cpi silencio, 0     ;aqui "ocurren" interrupciones
   ldi temp, 0
   out portd, temp
	brne silencio47_16
	ldi temp, 1<<COM1A0
	out TCCR1A, temp
	ldi temp, 0
	out OCR1AH, temp
	out OCR1AL, temp
	rjmp imperial_march
;******************************************************************************


;*********************************QUINTA NOTA**********************************
;*********************************OCTAVA NOTA**********************************	
;***************************DECIMOSETIMA NOTA**********************************
notaAsharp:
	ldi sonar, 0
	ldi temp, high(1072)
	out OCR1AH, temp
	ldi temp, low(1072)
	out OCR1AL, temp
	inc notas
	ldi cont10ms, 200    ;tiempo que durara la nota
	cpi notas, 5
	breq sec1_Asharp
	cpi notas, 8
	breq sec2_Asharp
	cpi notas, 14
	breq sec2_Asharp
	cpi notas, 17
	breq sec1_Asharp

sec1_Asharp:
	out portd, sec1
	rjmp sonando47_16
sec2_Asharp:
	out portd, sec2
	rjmp sonando47_16		
	
sonando58_14_17:
	cpi silencio, 1      ;aqui "ocurren" interrupciones
	brne sonando58_14_17 ;sino son iguales sigo reproduciendo la nota
	                     ;si llego aca sono lo que debia sonar
	ldi sonar, 1         ;le toca el silencio al silencio en si
	ldi cont10ms, 120    ;tiempo que durara el silencio
	ldi temp, 0<<COM1A0  ;dejamos de emitir la nota
	out TCCR1A, temp
	ldi temp, 0
	out portb, temp
	
silencio58_14_17:
   cpi silencio, 0      ;aqui "ocurren" interrupciones
   ldi temp, 0
   out portd, temp
	brne silencio58_14_17
	ldi temp, 1<<COM1A0
	out TCCR1A, temp
	ldi temp, 0
	out OCR1AH, temp
	out OCR1AL, temp

	rjmp imperial_march
;******************************************************************************


;*********************************NOVENA NOTA**********************************
notaG2:
	ldi sonar, 0
	ldi temp, high(1275)
	out OCR1AH, temp
	ldi temp, low(1275)
	out OCR1AL, temp
	inc notas
	ldi cont10ms, 251    ;con ese valor espera el tiempo deseado
	
sonando9:
	cpi silencio, 1     ;aqui "ocurren" interrupciones
	brne sonando9
	ldi silencio, 0
	
sonando9_extra:	
	cpi silencio, 1     ;aqui "ocurren" interrupciones
	brne sonando9_extra  ;si llego aca sono lo que debia sonar
	
	ldi sonar, 1        ;le toca el silencio al silencio en si
	ldi cont10ms, 220     ;valor para que no suene
	ldi temp, 0<<COM1A0 ;dejamos de emitir la nota
	out TCCR1A, temp
	ldi temp, 0
	out portb, temp
	
silencio9:
   cpi silencio, 0   ;aqui "ocurren" interrupciones
	brne silencio9
	ldi silencio, 1
	
silencio9_extra:
	cpi silencio, 0
	brne silencio9_extra
	
	ldi temp, 1<<COM1A0
	out TCCR1A, temp
	ldi temp, 0
	out OCR1AH, temp
	out OCR1AL, temp
	rjmp imperial_march
;******************************************************************************


;*********************************DECIMA NOTA**********************************
;*******************************UNDECIMA NOTA**********************************
;******************************DUODECIMA NOTA**********************************
notaD4:
	ldi sonar, 0
	ldi temp, high(851)
	out OCR1AH, temp
	ldi temp, low(851)
	out OCR1AL, temp
	inc notas
	ldi cont10ms, 251     ;el valor calculado enverdad es 384
	
sonando10_11_12:
	cpi silencio, 1       ;aqui "ocurren" interrupciones
	brne sonando10_11_12  ;sino son iguales sigo reproduciendo la nota
	ldi silencio, 0
	ldi cont10ms, 133     ;por esto se usan 2 veces, no cabe en 8 bits
	
sonando10_11_12_extra:
	cpi silencio, 1
	brne sonando10_11_12_extra
	                      ;si llego aca sono lo que debia sonar
	ldi sonar, 1          ;le toca el silencio al silencio en si
	ldi cont10ms, 251     ;el verdadero valor es 336
	ldi temp, 0<<COM1A0 ;dejamos de emitir la nota
	out TCCR1A, temp
	ldi temp, 0
	out portb, temp
	
silencio10_11_12:
   cpi silencio, 0       ;aqui "ocurren" interrupciones
	brne silencio10_11_12
	ldi silencio, 1
	ldi cont10ms, 85
	
silencio10_11_12_extra:
	cpi silencio, 0
	brne silencio10_11_12_extra
		
	ldi temp, 1<<COM1A0
	out TCCR1A, temp
	ldi temp, 0
	out OCR1AH, temp
	out OCR1AL, temp
	rjmp imperial_march
;******************************************************************************


;******************************DECIMOTERCER NOTA*******************************
notaDsharp4:
	ldi sonar, 0
	ldi temp, high(803)
	out OCR1AH, temp
	ldi temp, low(803)
	out OCR1AL, temp
	inc notas
	ldi cont10ms, 251   ;valor para que suene
	
sonando13:
	cpi silencio, 1       ;aqui "ocurren" interrupciones
	brne sonando13  ;sino son iguales sigo reproduciendo la nota
	ldi silencio, 0
	ldi cont10ms, 150
	
sonando13_extra:
	cpi silencio, 1
	brne sonando13_extra
	                      ;si llego aca sono lo que debia sonar
	ldi sonar, 1          ;le toca el silencio al silencio en si
	ldi cont10ms, 90     ;valor para que no suene
	ldi temp, 0<<COM1A0 ;dejamos de emitir la nota
	out TCCR1A, temp
	ldi temp, 0
	out portb, temp
	
silencio13:
   cpi silencio, 0       ;aqui "ocurren" interrupciones
	brne silencio13
	ldi silencio, 1
			
	ldi temp, 1<<COM1A0
	out TCCR1A, temp
	ldi temp, 0
	out OCR1AH, temp
	out OCR1AL, temp
	rjmp imperial_march
;******************************************************************************


;***************************DECIMOCUARTA NOTA**********************************
notaAsharpcarajo:
	ldi sonar, 0
	ldi temp, high(1072)
	out OCR1AH, temp
	ldi temp, low(1072)
	out OCR1AL, temp
	inc notas
	ldi cont10ms, 180    ;tiempo que durara la nota
   out portd, sec2	
	ldi silencio, 0
sonando14:
	cpi silencio, 1      ;aqui "ocurren" interrupciones
	brne sonando14 ;sino son iguales sigo reproduciendo la nota
	                     ;si llego aca sono lo que debia sonar
	ldi sonar, 1         ;le toca el silencio al silencio en si
	ldi cont10ms, 60    ;tiempo que durara el silencio
	ldi temp, 0<<COM1A0  ;dejamos de emitir la nota
	out TCCR1A, temp
	ldi temp, 0
	out portb, temp
	
silencio14:
   cpi silencio, 0      ;aqui "ocurren" interrupciones
   ldi temp, 0
   out portd, temp
	brne silencio14
	ldi temp, 1<<COM1A0
	out TCCR1A, temp
	ldi temp, 0
	out OCR1AH, temp
	out OCR1AL, temp

	rjmp imperial_march
;******************************************************************************


;******************************DECIMOQUINTA NOTA*******************************
notaFsharp:
   ldi sonar, 0
	ldi temp, high(1350)
	out OCR1AH, temp
	ldi temp, low(1350)
	out OCR1AL, temp
	inc notas
	ldi cont10ms, 251   ;valor para que suene
sonando15:
	cpi silencio, 1       ;aqui "ocurren" interrupciones
	brne sonando15  ;sino son iguales sigo reproduciendo la nota
	                      ;si llego aca sono lo que debia sonar
	ldi sonar, 1          ;le toca el silencio al silencio en si
	ldi cont10ms, 251       ;valor para que no suene
	ldi temp, 0<<COM1A0 ;dejamos de emitir la nota
	out TCCR1A, temp
	ldi temp, 0
	out portb, temp
silencio15:
   cpi silencio, 0       ;aqui "ocurren" interrupciones
	brne silencio15
	ldi temp, 1<<COM1A0
	out TCCR1A, temp
	ldi temp, 0
	out OCR1AH, temp
	out OCR1AL, temp

	rjmp imperial_march
;******************************************************************************	






