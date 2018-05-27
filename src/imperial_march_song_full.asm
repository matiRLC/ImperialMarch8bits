; *****************************************************************************
; Proyect: Imperial March Song (FULL)
; Author:  Matias Quintana Rosales
; Date: inicio - 19/8/2011
;       fin    - 19/9/2011
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
   .org $06
   rjmp isr_oc1a

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
;
; Primera parte: imperial_march_song
;
; orden    1  2  3  4   5   6  7   8   9  10 11 12  13  14  15  16  17  18
; nota     G  G  G  D#  A#  G  D#  A#  G  D  D  D   D#  A#  F#  D#  A#  G
; octava   3  3  3  3   3   3  3   3   3  4  4  4   4   3   3   3   3   3
; avance   x  x  x  x   x   x  x   x   x  x  x  x   x   x   x   x   x   x
;
;    G   = 392Hz
;    A#  = 466Hz
;    D#  = 311Hz
;    D4  = 587Hz
;    F#  = 370Hz	
;    D#4 = 622Hz
;
; Resto:         imperial_march_song_full
;
; orden   19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42
; nota    G  G  G  G  F# F  E  D#  E G# C#  C  B A#  A A# D#  G D#  G A#  G A#  D	
; octava  5  3  3  5  5  5  5  5   5  3  4  4  4  4  4  4  3  3  3  3  3  3  3  3
; avance  x  x  x  x  x  x  x  x   x  x  x  x  x  x  x  x  x  x  x  x  x  x  x  x
;
; orden   43 44 45 46 47 48 49 50 51 52 53 54 55 56 57 58 59 60 61 62 63 64
; nota
; octava
; avance
;
;    G5  = 1568Hz
;    F#5 = 1480Hz
;    F5  = 1397Hz
;    E5  = 1319Hz
;    D#5 = 1245Hz
;    G#  =  415Hz
;    C#4 =  544Hz
;    C4  =  523Hz
;    B4  =  988Hz
;    A#4 =  932Hz
;    A4  =  880Hz
;
;  Para determinar el valor de OCR1A:
;  P=1
;  N = fin/(2*fout) - 1;
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
start:
	ldi temp, high(ramend)
	out SPH, temp
	ldi temp, low(ramend)
	out SPL, temp
	ldi temp, 2        ;todos como salida
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
	breq notaGnollega
	rjmp sigue1

notaGnollega:
	rjmp notaG
		
sigue1:	
	cpi notas, 2
	breq notaGnollega
		
	cpi notas, 3
	breq notaGnollega
	
	cpi notas, 4
	breq notaDsharpnollega
	rjmp sigue2
	
notaDsharpnollega:
	rjmp notaDsharp
		
sigue2:
	cpi notas, 5
	breq notaAsharpnollega
	rjmp sigue3
	
notaAsharpnollega:
	rjmp notaAsharp
	
sigue3:	
	cpi notas, 6
	breq notaGnollega
		
	cpi notas, 7
	breq notaDsharpnollega
	
	cpi notas, 8
	breq notaAsharpnollega
	
	cpi notas, 9
	breq notaG2nollega
	rjmp sigue4
	
notaG2nollega:
	rjmp notaG2	
	
sigue4:	
	cpi notas, 10
	breq notaD4nollega
	rjmp sigue5
	
notaD4nollega:
	rjmp notaD4		
		
sigue5:	
	cpi notas, 11
	breq notaD4nollega
	
	cpi notas, 12
	breq notaD4nollega
	
	cpi notas, 13
	breq notaDsharp4nollega
	rjmp sigue6
	
notaDsharp4nollega:
	rjmp notaDsharp4
				
sigue6:	
	cpi notas, 14
	breq notaAsharpcarajonollega
	rjmp sigue7
	
notaAsharpcarajonollega:
	rjmp notaAsharpcarajo
		
sigue7:	
	cpi notas, 15
	breq notaFsharpnollega
	rjmp sigue8
	
notaFsharpnollega:
	rjmp notaFsharp
	
sigue8:	
	cpi notas, 16
	breq notaDsharpnollega

	cpi notas, 17
	breq notaAsharpnollega
	
	cpi notas, 18
	breq notaGlarganollega
	rjmp sigue9

notaGlarganollega:
	rjmp notaGlarga	
	
sigue9:	
	cpi notas, 19
	breq notaG5nollega
	rjmp sigue10

notaG5nollega:
	rjmp notaG5
	
sigue10:	
	cpi notas, 20
	breq notaGestacatonollega
	rjmp sigue11

notaGestacatonollega:
	rjmp notaGestacato
	
sigue11:	
	cpi notas, 21
	breq notaGcortanollega
	rjmp sigue12
	
notaGcortanollega:
	rjmp notaGcorta	
	
sigue12:	
	cpi notas, 22
	breq notaG5nollega
	
	cpi notas, 23
	breq notaFsharp5nollega
	rjmp sigue13
	
notaFsharp5nollega:
	rjmp notaFsharp5	
		
sigue13:	
	cpi notas, 24
   breq notaF5nollega
   rjmp sigue14

notaF5nollega:
	rjmp notaF5

sigue14:
   cpi notas, 25
   breq notaE5nollega
	rjmp sigue15

notaE5nollega:
	rjmp notaE5

sigue15:
   cpi notas, 26
   breq notaDsharp5nollega
   rjmp sigue16

notaDsharp5nollega:
	rjmp notaDsharp5

sigue16:
   cpi notas, 27
   breq notaE5silencionollega
   rjmp sigue17

notaE5silencionollega:
	rjmp notaE5silencio

sigue17:
   cpi notas, 28
   breq nota28Gsharpnollega
   rjmp sigue18

nota28Gsharpnollega:
	rjmp nota28Gsharp
	
sigue18:
   cpi notas, 29
   breq nota29Csharpnollega
   rjmp sigue19

nota29Csharpnollega:		
	rjmp nota29Csharp

sigue19:
   cpi notas, 30
   breq nota30Cnollega
   rjmp sigue20

nota30Cnollega:
	rjmp nota30C

sigue20:
   cpi notas, 31
   breq nota31Bnollega
	rjmp sigue21
	
nota31Bnollega:
	rjmp nota31B
		
sigue21:
   cpi notas, 32
   breq nota32Asharpnollega
	rjmp sigue22
	
nota32Asharpnollega:
	rjmp nota32Asharp

sigue22:
	cpi notas, 33
	breq nota33Anollega
	rjmp sigue23

nota33Anollega:
	rjmp nota33A

sigue23:	
   cpi notas, 34
   breq nota34Asharpnollega
   rjmp sigue24

nota34Asharpnollega:
	rjmp nota34Asharp

sigue24:
	cpi notas, 35
	breq nota35Dsharpnollega
	rjmp sigue25
	
nota35Dsharpnollega:	
	rjmp nota35Dsharp	
		
sigue25:	
	cpi notas, 36
	breq nota36Gnollega
	rjmp sigue26
	
nota36Gnollega:
	rjmp nota36G	
		
sigue26:	
	cpi notas, 37
	breq nota37Dsharpnollega
	rjmp sigue27
	
nota37Dsharpnollega:
	rjmp nota37Dsharp	
		
sigue27:	
	cpi notas, 38
	breq nota38Gnollega
	rjmp sigue28
	
nota38Gnollega:
	rjmp nota38G	
		
sigue28:	
	cpi notas, 39
	breq nota39Asharpnollega
	rjmp sigue29
	
nota39Asharpnollega:
	rjmp nota39Asharp	
sigue29:	
	cpi notas, 40
	breq nota40Gnollega
	rjmp sigue30
	
nota40Gnollega:
	rjmp nota40G	
			
sigue30:	
	cpi notas, 41
	breq nota41Asharpnollega
	rjmp sigue31
	
nota41Asharpnollega:
	rjmp nota41Asharp
	
sigue31:	
	cpi notas, 42
	breq nota42Dnollega
	rjmp sigue32
	
nota42Dnollega:
	rjmp nota42D	
		
sigue32:	
	cpi notas, 43
	breq notaG5_2
   rjmp sigue33

notaG5_2:
	rjmp notaG5
	
sigue33:	
	cpi notas, 44
	breq notaGestacato_2
   rjmp sigue34

notaGestacato_2:
	rjmp notaGestacato	

sigue34:	
	cpi notas, 45
	breq notaGcorta_2
	rjmp sigue35
	
notaGcorta_2:
	rjmp notaGcorta	

sigue35:	 	
	cpi notas, 46
	breq notaG5_3
	rjmp sigue36
	
notaG5_3:
	rjmp notaG5	
	
sigue36:	
	cpi notas, 47
	breq notaFsharp5_2
	rjmp sigue37
	
notaFsharp5_2:
	rjmp notaFsharp5	
		
sigue37:	
	cpi notas, 48
	breq notaF5_2
	rjmp sigue38

notaF5_2:
	rjmp notaF5
		
sigue38:	
	cpi notas, 49
	breq notaE5_2
	rjmp sigue39

notaE5_2:
	rjmp notaE5
	
sigue39:		
	cpi notas, 50
	breq notaDsharp5_2
	rjmp sigue40

notaDsharp5_2:
	rjmp notaDsharp5
		
sigue40:	
	cpi notas, 51
	breq notaE5silencio_2
   rjmp sigue41

notaE5silencio_2:
 	rjmp notaE5silencio
 	
sigue41:		
	cpi notas, 52
	breq nota28Gsharp_2
	rjmp sigue42

nota28Gsharp_2:
	rjmp nota28Gsharp
		
sigue42:	
	cpi notas, 53
	breq nota29Csharp_2
	rjmp sigue43

nota29Csharp_2:
	rjmp nota29Csharp
		
sigue43:	
	cpi notas, 54
	breq nota30C_2
   rjmp sigue44

nota30C_2:
	rjmp nota30C
	
sigue44:	
	cpi notas, 55
	breq nota31B_2
	rjmp sigue45
	
nota31B_2:
	rjmp nota31B
		
sigue45:	
	cpi notas, 56
	breq nota32Asharp_2
	rjmp sigue46
	
nota32Asharp_2:
	rjmp nota32Asharp	
	
sigue46:	
	cpi notas, 57
	breq nota33A_2
	rjmp sigue47
	
nota33A_2:
	rjmp nota33A	
	
sigue47:	
	cpi notas, 58
	breq nota34Asharp_2
	rjmp sigue48
	
nota34Asharp_2:
	rjmp nota34Asharp
	
sigue48:	
	cpi notas, 59
	breq nota35Dsharp_2
	rjmp sigue49
	
nota35Dsharp_2:	
	rjmp nota35Dsharp
	
sigue49:	
	cpi notas, 60
	breq nota36G_2
	rjmp sigue50
	
nota36G_2:
	rjmp nota36G
		
sigue50:	
	cpi notas, 61
	breq nota37Dsharp_2
	rjmp sigue51

nota37Dsharp_2:
	rjmp nota37Dsharp
		
sigue51:	
	cpi notas, 62
	breq nota38G_2
	rjmp sigue52

nota38G_2:
	rjmp nota38G
		
sigue52:	
	cpi notas, 63
	breq nota39Asharp_2
	rjmp sigue53

nota39Asharp_2:
	rjmp nota39Asharp	
	
sigue53:	
	cpi notas, 64                      ;AQUI ESTAMOS!
	breq nota64Dsharp_2
	rjmp sigue54

nota64Dsharp_2:
	rjmp nota64Dsharp
	
sigue54:	
	cpi notas, 65
	breq nota65Asharp_2
   rjmp sigue55

nota65Asharp_2:
	rjmp nota65Asharp	
	
sigue55:	
	cpi notas, 66
	breq nota66G_2
   rjmp forever

nota66G_2:
	rjmp nota66G	
								
forever:
   CLI
   ldi temp, 0
   out portb, temp
	rjmp forever

;***********************************NOTA 1*************************************
;***********************************NOTA 2*************************************
;***********************************NOTA 3*************************************
;***********************************NOTA 6*************************************
notaG:
	ldi sonar, 0
	ldi temp, high(1275)
	out OCR1AH, temp
	ldi temp, low(1275)
	out OCR1AL, temp
	ldi temp, 2
	out ddrb, temp
	ldi cont10ms, 251      ;tiempo que durara la nota
	cpi notas, 1
	breq sec1_G
	cpi notas, 2
	breq sec2_G
	cpi notas, 3
	breq sec1_G
	cpi notas, 6
	breq sec2_G
	
sec1_G:
	inc notas
	out portd, sec1
	rjmp sonando1236
	
sec2_G:
	inc notas
	out portd, sec2
	rjmp sonando1236
	
sonando1236:
	cpi silencio, 1        ;aqui "ocurren" interrupciones
	brne sonando1236       ;sino son iguales sigo reproduciendo la nota
	                       ;si llego aca sono lo que debia sonar
	ldi sonar, 1           ;le toca el silencio al silencio en si
	ldi cont10ms, 220      ;tiempo que durara el silencio
	ldi temp, 0<<COM1A0    ;dejamos de emitir la nota
	out TCCR1A, temp
	ldi temp, 0
	out portb, temp
	
silencio1236:
   cpi silencio, 0        ;aqui "ocurren" interrupciones
	brne silencio1236
	
	ldi temp, 1<<COM1A0
	out TCCR1A, temp
	ldi temp, 0
	out OCR1AH, temp
	out OCR1AL, temp
	rjmp imperial_march

;***********************************NOTA 4*************************************
;***********************************NOTA 7*************************************
;***********************************NOTA 16************************************
notaDsharp:
	ldi sonar, 0
	ldi temp, high(1607)
	out OCR1AH, temp
	ldi temp, low(1607)
	out OCR1AL, temp
	ldi cont10ms, 181   ;tiempo que durara la nota
	cpi notas, 4
	breq sec2_Dsharp
	cpi notas, 7
	breq sec1_Dsharp
	cpi notas, 16
	breq sec2_Dsharp

sec1_Dsharp:
	inc notas
	out portd, sec1
	rjmp sonando47_16
	
sec2_Dsharp:
	inc notas
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
	brne silencio47_16
	
	ldi temp, 1<<COM1A0
	out TCCR1A, temp
	ldi temp, 0
	out OCR1AH, temp
	out OCR1AL, temp
	rjmp imperial_march

;***********************************NOTA 5*************************************
;***********************************NOTA 8*************************************
notaAsharp:
	ldi sonar, 0
	ldi temp, high(1072)
	out OCR1AH, temp
	ldi temp, low(1072)
	out OCR1AL, temp
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
	inc notas
	out portd, sec1
	rjmp sonando58
	
sec2_Asharp:
   inc notas
	out portd, sec2
	rjmp sonando58		
	
sonando58:
	cpi silencio, 1      ;aqui "ocurren" interrupciones
	brne sonando58       ;sino son iguales sigo reproduciendo la nota
	                     ;si llego aca sono lo que debia sonar
	ldi sonar, 1         ;le toca el silencio al silencio en si
	ldi cont10ms, 80    ;tiempo que durara el silencio
	ldi temp, 0<<COM1A0  ;dejamos de emitir la nota
	out TCCR1A, temp
	ldi temp, 0
	out portb, temp
	
silencio58:
   cpi silencio, 0      ;aqui "ocurren" interrupciones
	brne silencio58
	
	ldi temp, 1<<COM1A0
	out TCCR1A, temp
	ldi temp, 0
	out OCR1AH, temp
	out OCR1AL, temp
	rjmp imperial_march

;***********************************NOTA 9*************************************
notaG2:
	ldi sonar, 0
	ldi temp, high(1275)
	out OCR1AH, temp
	ldi temp, low(1275)
	out OCR1AL, temp
	ldi cont10ms, 251    ;con ese valor espera el tiempo deseado
   inc notas
	out portd, sec2		
	
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

;***********************************NOTA 10************************************
;***********************************NOTA 11************************************
;***********************************NOTA 12************************************
notaD4:
	ldi sonar, 0
	ldi temp, high(851)
	out OCR1AH, temp
	ldi temp, low(851)
	out OCR1AL, temp
	ldi cont10ms, 251     ;el valor calculado enverdad es 384
	cpi notas, 10
	breq sec2_D4
	cpi notas, 11
	breq sec1_D4
	cpi notas, 12
	breq sec2_D4

sec1_D4:
	inc notas
	out portd, sec1
	rjmp sonando10_11_12
	
sec2_D4:
   inc notas
	out portd, sec2
	rjmp sonando10_11_12
	
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

;***********************************NOTA 13************************************
notaDsharp4:
	ldi sonar, 0
	ldi temp, high(803)
	out OCR1AH, temp
	ldi temp, low(803)
	out OCR1AL, temp
	inc notas
	ldi cont10ms, 251   ;valor para que suene
	out portd, sec1
	
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

;***********************************NOTA 14************************************
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
	brne silencio14
	
	ldi temp, 1<<COM1A0
	out TCCR1A, temp
	ldi temp, 0
	out OCR1AH, temp
	out OCR1AL, temp
	rjmp imperial_march

;***********************************NOTA 15************************************
notaFsharp:
   ldi sonar, 0
	ldi temp, high(1350)
	out OCR1AH, temp
	ldi temp, low(1350)
	out OCR1AL, temp
	inc notas
	ldi cont10ms, 251   ;valor para que suene
	out portd, sec1
	
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

;***********************************NOTA 18************************************
notaGlarga:
	ldi sonar, 0
	ldi temp, high(1275)
	out OCR1AH, temp
	ldi temp, low(1275)
	out OCR1AL, temp
	ldi temp, 2
	out ddrb, temp
	inc notas
	ldi cont10ms, 251      ;tiempo que durara la nota
	out portd, sec2
	
sonando18:
	cpi silencio, 1        ;aqui "ocurren" interrupciones
	brne sonando18    ;sino son iguales sigo reproduciendo la nota
	
	ldi silencio, 0
	
sonando18_extra:
	cpi silencio, 1
	brne sonando18_extra
	                       ;si llego aca sono lo que debia sonar
	ldi sonar, 1           ;le toca el silencio al silencio en si
	ldi cont10ms, 220      ;tiempo que durara el silencio
	ldi temp, 0<<COM1A0    ;dejamos de emitir la nota
	out TCCR1A, temp
	ldi temp, 0
	out portb, temp
	
silencio18:
   cpi silencio, 0        ;aqui "ocurren" interrupciones
	brne silencio18
	
	ldi temp, 1<<COM1A0
	out TCCR1A, temp
	ldi temp, 0
	out OCR1AH, temp
	out OCR1AL, temp
	rjmp imperial_march

;***********************************NOTA 19************************************
;***********************************NOTA 22************************************
notaG5:
   ldi sonar, 0
	ldi temp, high(318)
	out OCR1AH, temp
	ldi temp, low(318)
	out OCR1AL, temp
	ldi cont10ms, 251   ;valor para que suene
	cpi notas, 19
	breq sec1_G5
	cpi notas, 22
	breq sec2_G5

sec1_G5:
	inc notas
	out portd, sec1
	rjmp sonando19_22
	
sec2_G5:
   inc notas
	out portd, sec2
	rjmp sonando19_22
	
sonando19_22:
	cpi silencio, 1       ;aqui "ocurren" interrupciones
	brne sonando19_22  ;sino son iguales sigo reproduciendo la nota
	
	ldi silencio, 0
	
sonando19_22_extra:
	cpi silencio, 1
	brne sonando19_22_extra
	
	ldi silencio, 0
	
sonando19_22_extra1:
	cpi silencio, 1
	brne sonando19_22_extra1	
	
	ldi silencio, 0
	
sonando19_22_extra2:
	cpi silencio, 1
	brne sonando19_22_extra2
	
	ldi silencio, 0
	
sonando19_22_extra3:
	cpi silencio, 1
	brne sonando19_22_extra3
	
	ldi silencio, 0
	ldi cont10ms, 100
	
sonando19_22_extra4:
	cpi silencio, 1
	brne sonando19_22_extra4			
		
	                      ;si llego aca sono lo que debia sonar
	ldi sonar, 1          ;le toca el silencio al silencio en si
	ldi cont10ms, 251       ;valor para que no suene
	ldi temp, 0<<COM1A0 ;dejamos de emitir la nota
	out TCCR1A, temp
	ldi temp, 0
	out portb, temp
	
silencio19:
   cpi silencio, 0       ;aqui "ocurren" interrupciones
	brne silencio19
	
	ldi temp, 1<<COM1A0
	out TCCR1A, temp
	ldi temp, 0
	out OCR1AH, temp
	out OCR1AL, temp
	rjmp imperial_march

;***********************************NOTA 20************************************
notaGestacato:
	ldi sonar, 0
	ldi temp, high(1275)
	out OCR1AH, temp
	ldi temp, low(1275)
	out OCR1AL, temp
	inc notas
	ldi cont10ms, 240      ;tiempo que durara la nota
	out portd, sec2
	
sonando20:
	cpi silencio, 1        ;aqui "ocurren" interrupciones
	brne sonando20    ;sino son iguales sigo reproduciendo la nota
	                       ;si llego aca sono lo que debia sonar
	ldi sonar, 1           ;le toca el silencio al silencio en si
	ldi cont10ms, 150      ;tiempo que durara el silencio
	ldi temp, 0<<COM1A0    ;dejamos de emitir la nota
	out TCCR1A, temp
	ldi temp, 0
	out portb, temp
	
silencio20:
   cpi silencio, 0        ;aqui "ocurren" interrupciones
	brne silencio20
	
	ldi temp, 1<<COM1A0
	out TCCR1A, temp
	ldi temp, 0
	out OCR1AH, temp
	out OCR1AL, temp
	rjmp imperial_march

;***********************************NOTA 21************************************
notaGcorta:
   ldi sonar, 0
	ldi temp, high(1275)
	out OCR1AH, temp
	ldi temp, low(1275)
	out OCR1AL, temp
	inc notas
	ldi cont10ms, 100  ;valor para que suene
	out portd, sec1
	
sonando21:
	cpi silencio, 1       ;aqui "ocurren" interrupciones
	brne sonando21  ;sino son iguales sigo reproduciendo la nota
	                      ;si llego aca sono lo que debia sonar
	ldi sonar, 1          ;le toca el silencio al silencio en si
	ldi cont10ms, 10       ;valor para que no suene
	ldi temp, 0<<COM1A0 ;dejamos de emitir la nota
	out TCCR1A, temp
	ldi temp, 0
	out portb, temp
	
silencio21:
   cpi silencio, 0       ;aqui "ocurren" interrupciones
	brne silencio21
	ldi temp, 1<<COM1A0
	out TCCR1A, temp
	ldi temp, 0
	out OCR1AH, temp
	out OCR1AL, temp

	rjmp imperial_march

;***********************************NOTA 23************************************
notaFsharp5:
   ldi sonar, 0
	ldi temp, high(337)
	out OCR1AH, temp
	ldi temp, low(337)
	out OCR1AL, temp
	inc notas
	ldi cont10ms, 251   ;valor para que suene
	out portd, sec1
	
sonando23:
	cpi silencio, 1       ;aqui "ocurren" interrupciones
	brne sonando23  ;sino son iguales sigo reproduciendo la nota

	ldi silencio, 0
	ldi cont10ms, 160
	
sonando23_extra:
	cpi silencio, 1
	brne sonando23_extra
	
	                      ;si llego aca sono lo que debia sonar
	ldi sonar, 1          ;le toca el silencio al silencio en si
	ldi cont10ms, 251       ;valor para que no suene
	
	ldi temp, 0<<COM1A0 ;dejamos de emitir la nota
	out TCCR1A, temp
	ldi temp, 0
	out portb, temp
	
silencio23:
   cpi silencio, 0       ;aqui "ocurren" interrupciones
	brne silencio23
	
	ldi silencio, 1
	
silencio23_extra:
   cpi silencio, 0       ;aqui "ocurren" interrupciones
	brne silencio23_extra
	
	
	ldi temp, 1<<COM1A0
	out TCCR1A, temp
	ldi temp, 0
	out OCR1AH, temp
	out OCR1AL, temp
	rjmp imperial_march

;***********************************NOTA 24************************************
notaF5:
   ldi sonar, 0
	ldi temp, high(357)
	out OCR1AH, temp
	ldi temp, low(357)
	out OCR1AL, temp
	inc notas
	ldi cont10ms, 251   ;valor para que suene
	out portd, sec2
	
sonando24:
	cpi silencio, 1       ;aqui "ocurren" interrupciones
	brne sonando24  ;sino son iguales sigo reproduciendo la nota
	
	ldi silencio, 0
	ldi cont10ms, 30
	
sonando24_extra:
	cpi silencio, 1
	brne sonando24_extra
	
sonando24_extra1:
	cpi silencio, 1
	brne sonando24_extra1	
	                      ;si llego aca sono lo que debia sonar
	ldi sonar, 1          ;le toca el silencio al silencio en si
	ldi cont10ms, 50      ;valor para que no suene
	ldi temp, 0<<COM1A0 ;dejamos de emitir la nota
	out TCCR1A, temp
	ldi temp, 0
	out portb, temp
	
silencio24:
   cpi silencio, 0       ;aqui "ocurren" interrupciones
	brne silencio24
	
	ldi temp, 1<<COM1A0
	out TCCR1A, temp
	ldi temp, 0
	out OCR1AH, temp
	out OCR1AL, temp
	rjmp imperial_march

;***********************************NOTA 25************************************
notaE5:
   ldi sonar, 0
	ldi temp, high(378)
	out OCR1AH, temp
	ldi temp, low(378)
	out OCR1AL, temp
	inc notas
	ldi cont10ms, 251   ;valor para que suene
	out portd, sec1
	
sonando25:
	cpi silencio, 1       ;aqui "ocurren" interrupciones
	brne sonando25  ;sino son iguales sigo reproduciendo la nota
	
	ldi cont10ms, 10
	ldi silencio, 0
	
sonando25_extra:
	cpi silencio, 1
	brne sonando25_extra
	                      ;si llego aca sono lo que debia sonar
	ldi sonar, 1          ;le toca el silencio al silencio en si
	ldi cont10ms, 80      ;valor para que no suene
	ldi temp, 0<<COM1A0 ;dejamos de emitir la nota
	out TCCR1A, temp
	ldi temp, 0
	out portb, temp
	
silencio25:
   cpi silencio, 0       ;aqui "ocurren" interrupciones
	brne silencio25
	
	ldi temp, 1<<COM1A0
	out TCCR1A, temp
	ldi temp, 0
	out OCR1AH, temp
	out OCR1AL, temp
	rjmp imperial_march

;***********************************NOTA 26************************************
notaDsharp5:
   ldi sonar, 0
	ldi temp, high(401)
	out OCR1AH, temp
	ldi temp, low(401)
	out OCR1AL, temp
	inc notas
	ldi cont10ms, 251   ;valor para que suene
	out portd, sec2
	
sonando26:
	cpi silencio, 1       ;aqui "ocurren" interrupciones
	brne sonando26  ;sino son iguales sigo reproduciendo la nota
	
	ldi cont10ms, 10
	ldi silencio, 0
			
sonando26_extra:
	cpi silencio, 1
	brne sonando26_extra		
	                      ;si llego aca sono lo que debia sonar
	ldi sonar, 1          ;le toca el silencio al silencio en si
	ldi cont10ms, 80      ;valor para que no suene
	ldi temp, 0<<COM1A0 ;dejamos de emitir la nota
	out TCCR1A, temp
	ldi temp, 0
	out portb, temp
	
silencio26:
   cpi silencio, 0       ;aqui "ocurren" interrupciones
	brne silencio26
	
	ldi temp, 1<<COM1A0
	out TCCR1A, temp
	ldi temp, 0
	out OCR1AH, temp
	out OCR1AL, temp
	rjmp imperial_march

;***********************************NOTA 27************************************
notaE5silencio:
   ldi sonar, 0
	ldi temp, high(378)
	out OCR1AH, temp
	ldi temp, low(378)
	out OCR1AL, temp
	inc notas
	ldi cont10ms, 251   ;valor para que suene
	out portd, sec1
	
sonando27:
	cpi silencio, 1       ;aqui "ocurren" interrupciones
	brne sonando27  ;sino son iguales sigo reproduciendo la nota
	
	ldi silencio, 0
	
sonando27_extra:
	cpi silencio, 1
	brne sonando27_extra
	
	ldi silencio, 0
	ldi cont10ms, 120
	
sonando27_extra1:
	cpi silencio, 1
	brne sonando27_extra1	

	                      ;si llego aca sono lo que debia sonar
	ldi sonar, 1          ;le toca el silencio al silencio en si
	ldi cont10ms, 251     ;valor para que no suene	
	ldi temp, 0<<COM1A0 ;dejamos de emitir la nota
	out TCCR1A, temp
	ldi temp, 0
	out portb, temp
	
silencio27:
   cpi silencio, 0       ;aqui "ocurren" interrupciones
	brne silencio27
	
	ldi silencio, 1
	
silencio27_extra:
	cpi silencio, 0
	brne silencio27_extra
	
	ldi temp, 1<<COM1A0
	out TCCR1A, temp
	ldi temp, 0
	out OCR1AH, temp
	out OCR1AL, temp
	rjmp imperial_march

;***********************************NOTA 28************************************
nota28Gsharp:
   ldi sonar, 0
	ldi temp, high(1204)
	out OCR1AH, temp
	ldi temp, low(1204)
	out OCR1AL, temp
	inc notas
	ldi cont10ms, 251   ;valor para que suene
	out portd, sec2
	
sonando28:
	cpi silencio, 1       ;aqui "ocurren" interrupciones
	brne sonando28  ;sino son iguales sigo reproduciendo la nota
	
	ldi silencio, 0
	ldi cont10ms, 5

sonando28_extra:
	cpi silencio, 1
	brne sonando28_extra
	
	                      ;si llego aca sono lo que debia sonar
	ldi sonar, 1          ;le toca el silencio al silencio en si
	ldi cont10ms, 90      ;valor para que no suene
	ldi temp, 0<<COM1A0 ;dejamos de emitir la nota
	out TCCR1A, temp
	ldi temp, 0
	out portb, temp
	
silencio28:
   cpi silencio, 0       ;aqui "ocurren" interrupciones
	brne silencio28
	
	ldi temp, 1<<COM1A0
	out TCCR1A, temp
	ldi temp, 0
	out OCR1AH, temp
	out OCR1AL, temp
	rjmp imperial_march

;***********************************NOTA 29************************************
nota29Csharp:
   ldi sonar, 0
	ldi temp, high(918)
	out OCR1AH, temp
	ldi temp, low(918)
	out OCR1AL, temp
	inc notas
	ldi cont10ms, 251   ;valor para que suene
	out portd, sec1
	
sonando29:
	cpi silencio, 1       ;aqui "ocurren" interrupciones
	brne sonando29  ;sino son iguales sigo reproduciendo la nota
	
	ldi silencio, 0
   ldi cont10ms, 50

sonando29_extra:
	cpi silencio, 1
	brne sonando29_extra
	
	                      ;si llego aca sono lo que debia sonar
	ldi sonar, 1          ;le toca el silencio al silencio en si
	ldi cont10ms, 100      ;valor para que no suene
	ldi temp, 0<<COM1A0 ;dejamos de emitir la nota
	out TCCR1A, temp
	ldi temp, 0
	out portb, temp
	
silencio29:
   cpi silencio, 0       ;aqui "ocurren" interrupciones
	brne silencio29
	
	ldi temp, 1<<COM1A0
	out TCCR1A, temp
	ldi temp, 0
	out OCR1AH, temp
	out OCR1AL, temp
	rjmp imperial_march

;***********************************NOTA 30************************************
nota30C:
   ldi sonar, 0
	ldi temp, high(955)
	out OCR1AH, temp
	ldi temp, low(955)
	out OCR1AL, temp
	inc notas
	ldi cont10ms, 220   ;valor para que suene
	out portd, sec2
	
sonando30:
	cpi silencio, 1       ;aqui "ocurren" interrupciones
	brne sonando30  ;sino son iguales sigo reproduciendo la nota
	
	                      ;si llego aca sono lo que debia sonar
	ldi sonar, 1          ;le toca el silencio al silencio en si
	ldi cont10ms, 100      ;valor para que no suene
	ldi temp, 0<<COM1A0 ;dejamos de emitir la nota
	out TCCR1A, temp
	ldi temp, 0
	out portb, temp
	
silencio30:
   cpi silencio, 0       ;aqui "ocurren" interrupciones
	brne silencio30
	
	ldi temp, 1<<COM1A0
	out TCCR1A, temp
	ldi temp, 0
	out OCR1AH, temp
	out OCR1AL, temp
	rjmp imperial_march
	
;***********************************NOTA 31************************************
nota31B:
   ldi sonar, 0
	ldi temp, high(505)
	out OCR1AH, temp
	ldi temp, low(505)
	out OCR1AL, temp
	inc notas
	ldi cont10ms, 200   ;valor para que suene
	out portd, sec1
	
sonando31:
	cpi silencio, 1       ;aqui "ocurren" interrupciones
	brne sonando31  ;sino son iguales sigo reproduciendo la nota
	
	                      ;si llego aca sono lo que debia sonar
	ldi sonar, 1          ;le toca el silencio al silencio en si
	ldi cont10ms, 120      ;valor para que no suene
	ldi temp, 0<<COM1A0 ;dejamos de emitir la nota
	out TCCR1A, temp
	ldi temp, 0
	out portb, temp
	
silencio31:
   cpi silencio, 0       ;aqui "ocurren" interrupciones
	brne silencio31
	
	ldi temp, 1<<COM1A0
	out TCCR1A, temp
	ldi temp, 0
	out OCR1AH, temp
	out OCR1AL, temp
	rjmp imperial_march

;***********************************NOTA 32************************************
nota32Asharp:
   ldi sonar, 0
	ldi temp, high(535)
	out OCR1AH, temp
	ldi temp, low(535)
	out OCR1AL, temp
	inc notas
	ldi cont10ms, 160   ;valor para que suene
	out portd, sec2
	
sonando32:
	cpi silencio, 1       ;aqui "ocurren" interrupciones
	brne sonando32  ;sino son iguales sigo reproduciendo la nota
	
	                      ;si llego aca sono lo que debia sonar
	ldi sonar, 1          ;le toca el silencio al silencio en si
	ldi cont10ms, 80      ;valor para que no suene
	ldi temp, 0<<COM1A0 ;dejamos de emitir la nota
	out TCCR1A, temp
	ldi temp, 0
	out portb, temp
	
silencio32:
   cpi silencio, 0       ;aqui "ocurren" interrupciones
	brne silencio32
	
	ldi temp, 1<<COM1A0
	out TCCR1A, temp
	ldi temp, 0
	out OCR1AH, temp
	out OCR1AL, temp
	rjmp imperial_march	
	
;***********************************NOTA 33************************************
nota33A:
   ldi sonar, 0
	ldi temp, high(567)
	out OCR1AH, temp
	ldi temp, low(567)
	out OCR1AL, temp
	inc notas
	ldi cont10ms, 160   ;valor para que suene
	out portd, sec1
	
sonando33:
	cpi silencio, 1       ;aqui "ocurren" interrupciones
	brne sonando33  ;sino son iguales sigo reproduciendo la nota
	
	                      ;si llego aca sono lo que debia sonar
	ldi sonar, 1          ;le toca el silencio al silencio en si
	ldi cont10ms, 80      ;valor para que no suene
	ldi temp, 0<<COM1A0 ;dejamos de emitir la nota
	out TCCR1A, temp
	ldi temp, 0
	out portb, temp
	
silencio33:
   cpi silencio, 0       ;aqui "ocurren" interrupciones
	brne silencio33
	
	ldi temp, 1<<COM1A0
	out TCCR1A, temp
	ldi temp, 0
	out OCR1AH, temp
	out OCR1AL, temp
	rjmp imperial_march	

;***********************************NOTA 34************************************
nota34Asharp:
   ldi sonar, 0
	ldi temp, high(535)
	out OCR1AH, temp
	ldi temp, low(535)
	out OCR1AL, temp
	inc notas
	ldi cont10ms, 251   ;valor para que suene
	out portd, sec2
	
sonando34:
	cpi silencio, 1       ;aqui "ocurren" interrupciones
	brne sonando34  ;sino son iguales sigo reproduciendo la nota
	
	                      ;si llego aca sono lo que debia sonar
	ldi sonar, 1          ;le toca el silencio al silencio en si
	ldi cont10ms, 251      ;valor para que no suene	
	ldi temp, 0<<COM1A0 ;dejamos de emitir la nota
	out TCCR1A, temp
	ldi temp, 0
	out portb, temp
	
silencio34:
   cpi silencio, 0       ;aqui "ocurren" interrupciones
	brne silencio34
	
	ldi silencio, 1
	
silencio34_extra:
	cpi silencio, 0
	brne silencio34_extra
	
	ldi silencio, 1
	ldi cont10ms, 100

silencio34_extra1:
	cpi silencio, 0
	brne silencio34_extra1
	
	ldi temp, 1<<COM1A0
	out TCCR1A, temp
	ldi temp, 0
	out OCR1AH, temp
	out OCR1AL, temp
	rjmp imperial_march	
	
;***********************************NOTA 35************************************
nota35Dsharp:
   ldi sonar, 0
	ldi temp, high(1607)
	out OCR1AH, temp
	ldi temp, low(1607)
	out OCR1AL, temp
	inc notas
	ldi cont10ms, 200   ;valor para que suene
	out portd, sec1
	
sonando35:
	cpi silencio, 1       ;aqui "ocurren" interrupciones
	brne sonando35  ;sino son iguales sigo reproduciendo la nota
	
	                      ;si llego aca sono lo que debia sonar
	ldi sonar, 1          ;le toca el silencio al silencio en si
	ldi cont10ms, 50      ;valor para que no suene
	ldi temp, 0<<COM1A0 ;dejamos de emitir la nota
	out TCCR1A, temp
	ldi temp, 0
	out portb, temp
	
silencio35:
   cpi silencio, 0       ;aqui "ocurren" interrupciones
	brne silencio35
	
	ldi temp, 1<<COM1A0
	out TCCR1A, temp
	ldi temp, 0
	out OCR1AH, temp
	out OCR1AL, temp
	rjmp imperial_march	
	
	
;***********************************NOTA 36************************************
nota36G:
   ldi sonar, 0
	ldi temp, high(1275)
	out OCR1AH, temp
	ldi temp, low(1275)
	out OCR1AL, temp
	inc notas
	ldi cont10ms, 240   ;valor para que suene
	out portd, sec2
	
sonando36:
	cpi silencio, 1       ;aqui "ocurren" interrupciones
	brne sonando36  ;sino son iguales sigo reproduciendo la nota
	
	                      ;si llego aca sono lo que debia sonar
	ldi sonar, 1          ;le toca el silencio al silencio en si
	ldi cont10ms, 80      ;valor para que no suene
	ldi temp, 0<<COM1A0 ;dejamos de emitir la nota
	out TCCR1A, temp
	ldi temp, 0
	out portb, temp
	
silencio36:
   cpi silencio, 0       ;aqui "ocurren" interrupciones
	brne silencio36
	
	ldi temp, 1<<COM1A0
	out TCCR1A, temp
	ldi temp, 0
	out OCR1AH, temp
	out OCR1AL, temp
	rjmp imperial_march	
	
;***********************************NOTA 37************************************
nota37Dsharp:
   ldi sonar, 0
	ldi temp, high(1607)
	out OCR1AH, temp
	ldi temp, low(1607)
	out OCR1AL, temp
	inc notas
	ldi cont10ms, 130   ;valor para que suene
	out portd, sec1
	
sonando37:
	cpi silencio, 1       ;aqui "ocurren" interrupciones
	brne sonando37  ;sino son iguales sigo reproduciendo la nota
	
	                      ;si llego aca sono lo que debia sonar
	ldi sonar, 1          ;le toca el silencio al silencio en si
	ldi cont10ms, 80      ;valor para que no suene
	ldi temp, 0<<COM1A0 ;dejamos de emitir la nota
	out TCCR1A, temp
	ldi temp, 0
	out portb, temp
	
silencio37:
   cpi silencio, 0       ;aqui "ocurren" interrupciones
	brne silencio37
	
	ldi temp, 1<<COM1A0
	out TCCR1A, temp
	ldi temp, 0
	out OCR1AH, temp
	out OCR1AL, temp
	rjmp imperial_march		
	
;***********************************NOTA 38************************************
nota38G:
   ldi sonar, 0
	ldi temp, high(1275)
	out OCR1AH, temp
	ldi temp, low(1275)
	out OCR1AL, temp
	inc notas
	ldi cont10ms, 160   ;valor para que suene
	out portd, sec2
	
sonando38:
	cpi silencio, 1       ;aqui "ocurren" interrupciones
	brne sonando38  ;sino son iguales sigo reproduciendo la nota
	
	                      ;si llego aca sono lo que debia sonar
	ldi sonar, 1          ;le toca el silencio al silencio en si
	ldi cont10ms, 50      ;valor para que no suene
	ldi temp, 0<<COM1A0 ;dejamos de emitir la nota
	out TCCR1A, temp
	ldi temp, 0
	out portb, temp
	
silencio38:
   cpi silencio, 0       ;aqui "ocurren" interrupciones
	brne silencio38
	
	ldi temp, 1<<COM1A0
	out TCCR1A, temp
	ldi temp, 0
	out OCR1AH, temp
	out OCR1AL, temp
	rjmp imperial_march
	
;***********************************NOTA 39************************************
nota39Asharp:
   ldi sonar, 0
	ldi temp, high(1072)
	out OCR1AH, temp
	ldi temp, low(1072)
	out OCR1AL, temp
	inc notas
	ldi cont10ms, 200   ;valor para que suene
	out portd, sec1
	
sonando39:
	cpi silencio, 1       ;aqui "ocurren" interrupciones
	brne sonando39  ;sino son iguales sigo reproduciendo la nota
	
	                      ;si llego aca sono lo que debia sonar
	ldi sonar, 1          ;le toca el silencio al silencio en si
	ldi cont10ms, 80      ;valor para que no suene
	ldi temp, 0<<COM1A0 ;dejamos de emitir la nota
	out TCCR1A, temp
	ldi temp, 0
	out portb, temp
	
silencio39:
   cpi silencio, 0       ;aqui "ocurren" interrupciones
	brne silencio39
	
	ldi temp, 1<<COM1A0
	out TCCR1A, temp
	ldi temp, 0
	out OCR1AH, temp
	out OCR1AL, temp
	rjmp imperial_march	
	
;***********************************NOTA 40************************************
nota40G:
   ldi sonar, 0
	ldi temp, high(1275)
	out OCR1AH, temp
	ldi temp, low(1275)
	out OCR1AL, temp
	inc notas
	ldi cont10ms, 200   ;valor para que suene
	out portd, sec2
	
sonando40:
	cpi silencio, 1       ;aqui "ocurren" interrupciones
	brne sonando40  ;sino son iguales sigo reproduciendo la nota
	
	                      ;si llego aca sono lo que debia sonar
	ldi sonar, 1          ;le toca el silencio al silencio en si
	ldi cont10ms, 100      ;valor para que no suene
	ldi temp, 0<<COM1A0 ;dejamos de emitir la nota
	out TCCR1A, temp
	ldi temp, 0
	out portb, temp
	
silencio40:
   cpi silencio, 0       ;aqui "ocurren" interrupciones
	brne silencio40
	
	ldi temp, 1<<COM1A0
	out TCCR1A, temp
	ldi temp, 0
	out OCR1AH, temp
	out OCR1AL, temp
	rjmp imperial_march	
	
;***********************************NOTA 41************************************
nota41Asharp:
   ldi sonar, 0
	ldi temp, high(1072)
	out OCR1AH, temp
	ldi temp, low(1072)
	out OCR1AL, temp
	inc notas
	ldi cont10ms, 160   ;valor para que suene
	out portd, sec1
	
sonando41:
	cpi silencio, 1       ;aqui "ocurren" interrupciones
	brne sonando41  ;sino son iguales sigo reproduciendo la nota
	
	                      ;si llego aca sono lo que debia sonar
	ldi sonar, 1          ;le toca el silencio al silencio en si
	ldi cont10ms, 70      ;valor para que no suene
	ldi temp, 0<<COM1A0 ;dejamos de emitir la nota
	out TCCR1A, temp
	ldi temp, 0
	out portb, temp
	
silencio41:
   cpi silencio, 0       ;aqui "ocurren" interrupciones
	brne silencio41
	
	ldi temp, 1<<COM1A0
	out TCCR1A, temp
	ldi temp, 0
	out OCR1AH, temp
	out OCR1AL, temp
	rjmp imperial_march
	
;***********************************NOTA 42************************************
nota42D:
	ldi sonar, 0
	ldi temp, high(851)
	out OCR1AH, temp
	ldi temp, low(851)
	out OCR1AL, temp
	ldi cont10ms, 251     ;el valor calculado enverdad es 384
	inc notas
	out portd, sec2
	
sonando42:
	cpi silencio, 1       ;aqui "ocurren" interrupciones
	brne sonando42  ;sino son iguales sigo reproduciendo la nota
	
	ldi silencio, 0
	ldi cont10ms, 160     ;por esto se usan 2 veces, no cabe en 8 bits
	
sonando42_extra:
	cpi silencio, 1
	brne sonando42_extra
	                      ;si llego aca sono lo que debia sonar
	ldi sonar, 1          ;le toca el silencio al silencio en si
	ldi cont10ms, 251     ;el verdadero valor es 336
	ldi temp, 0<<COM1A0 ;dejamos de emitir la nota
	out TCCR1A, temp
	ldi temp, 0
	out portb, temp
	
silencio42:
   cpi silencio, 0       ;aqui "ocurren" interrupciones
	brne silencio42
	ldi silencio, 1
	ldi cont10ms, 85
	
silencio42_extra:
	cpi silencio, 0
	brne silencio42_extra
		
	ldi temp, 1<<COM1A0
	out TCCR1A, temp
	ldi temp, 0
	out OCR1AH, temp
	out OCR1AL, temp
	rjmp imperial_march

;***********************************NOTA 64************************************
nota64Dsharp:
   ldi sonar, 0
	ldi temp, high(1607)
	out OCR1AH, temp
	ldi temp, low(1607)
	out OCR1AL, temp
	inc notas
	ldi cont10ms, 150   ;valor para que suene
	out portd, sec2
	
sonando64:
	cpi silencio, 1       ;aqui "ocurren" interrupciones
	brne sonando64  ;sino son iguales sigo reproduciendo la nota
	
	                      ;si llego aca sono lo que debia sonar
	ldi sonar, 1          ;le toca el silencio al silencio en si
	ldi cont10ms, 100     ;valor para que no suene
	ldi temp, 0<<COM1A0 ;dejamos de emitir la nota
	out TCCR1A, temp
	ldi temp, 0
	out portb, temp
	
silencio64:
   cpi silencio, 0       ;aqui "ocurren" interrupciones
	brne silencio64
	
	ldi temp, 1<<COM1A0
	out TCCR1A, temp
	ldi temp, 0
	out OCR1AH, temp
	out OCR1AL, temp
	rjmp imperial_march	
	
;***********************************NOTA 65************************************
nota65Asharp:
   ldi sonar, 0
	ldi temp, high(1072)
	out OCR1AH, temp
	ldi temp, low(1072)
	out OCR1AL, temp
	inc notas
	ldi cont10ms, 160   ;valor para que suene
	out portd, sec1
	
sonando65:
	cpi silencio, 1       ;aqui "ocurren" interrupciones
	brne sonando65        ;sino son iguales sigo reproduciendo la nota
	
	                      ;si llego aca sono lo que debia sonar
	ldi sonar, 1          ;le toca el silencio al silencio en si
	ldi cont10ms, 100      ;valor para que no suene
	ldi temp, 0<<COM1A0 ;dejamos de emitir la nota
	out TCCR1A, temp
	ldi temp, 0
	out portb, temp
	
silencio65:
   cpi silencio, 0       ;aqui "ocurren" interrupciones
	brne silencio65
	
	ldi temp, 1<<COM1A0
	out TCCR1A, temp
	ldi temp, 0
	out OCR1AH, temp
	out OCR1AL, temp
	rjmp imperial_march

;***********************************NOTA 66************************************
nota66G:
   ldi sonar, 0
	ldi temp, high(1275)
	out OCR1AH, temp
	ldi temp, low(1275)
	out OCR1AL, temp
	inc notas
	ldi cont10ms, 240   ;valor para que suene
	out portd, sec2
	
sonando66:
	cpi silencio, 1       ;aqui "ocurren" interrupciones
	brne sonando66  ;sino son iguales sigo reproduciendo la nota
	
	                      ;si llego aca sono lo que debia sonar
	ldi sonar, 1          ;le toca el silencio al silencio en si
	ldi cont10ms, 100      ;valor para que no suene
	ldi temp, 0<<COM1A0 ;dejamos de emitir la nota
	out TCCR1A, temp
	ldi temp, 0
	out portb, temp
	
silencio66:
   cpi silencio, 0       ;aqui "ocurren" interrupciones
	brne silencio66
	
	ldi temp, 1<<COM1A0
	out TCCR1A, temp
	ldi temp, 0
	out OCR1AH, temp
	out OCR1AL, temp
	rjmp imperial_march			

