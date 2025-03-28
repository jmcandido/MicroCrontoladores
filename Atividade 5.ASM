;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*              MODIFICAÃ?Ã?ES PARA USO COM 12F675                   *
;*                FEITAS PELO PROF. MARDSON                        *
;*                      DEZEMBRO DE 2024                           *
;*                 BASEADO NO EXEMPLO DO LIVRO                     *
;*           Desbravando o PIC. David JosÃ© de Souza                *
;*-----------------------------------------------------------------*
;*   MODELO PARA O PIC 12F675                                      *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                     ARQUIVOS DE DEFINIÃ?Ã?ES                      *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
#INCLUDE <p12f675.inc>	;ARQUIVO PADRÃ?O MICROCHIP PARA 12F675

	__CONFIG _BODEN_OFF & _CP_OFF & _PWRTE_ON & _WDT_OFF & _MCLRE_OFF & _INTRC_OSC_NOCLKOUT

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                    PAGINAÃ?Ã?O DE MEMÃ?RIA                         *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;DEFINIÃ?Ã?O DE COMANDOS DE USUÃ?RIO PARA ALTERAÃ?Ã?O DA PÃ?GINA DE MEMÃ?RIA
#DEFINE	BANK0	     BCF STATUS,RP0	;SETA BANK 0 DE MEMÃ?RIA
#DEFINE	BANK1	     BSF STATUS,RP0      ;SETA BANK 1 DE MAMÃ?RIA
	
#DEFINE RED_OFF	     BCF GPIO, GP0
#DEFINE GREEN_OFF    BCF GPIO, GP1
#DEFINE BLUE_OFF     BCF GPIO, GP2
	
#DEFINE RED_ON       BSF GPIO, GP0
#DEFINE GREEN_ON     BSF GPIO, GP1
#DEFINE BLUE_ON      BSF GPIO, GP2
	

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                         VARIÃ?VEIS                               *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; DEFINIÃ?Ã?O DOS NOMES E ENDEREÃ?OS DE TODAS AS VARIÃ?VEIS UTILIZADAS 
; PELO SISTEMA

	CBLOCK	0x20	;ENDEREÃ?O INICIAL DA MEMÃ?RIA DE
					;USUÃ?RIO
		W_TEMP		;REGISTRADORES TEMPORÃ?RIOS PARA USO
		STATUS_TEMP	;JUNTO Ã?S INTERRUPÃ?Ã?ES
		RED_CYCLE
		BLUE_CYCLE
		GREEN_CYCLE
		RESULT_ALTO
		RESULT_BAIXO
		CONTADOR_AUX
		CONTADOR_ATRASO
		DUTY_CYCLE
		LED_ATUAL
		AUX_VAL
		;COLOQUE AQUI SUAS NOVAS VARIÃ?VEIS
		;NÃ?O ESQUEÃ?A COMENTÃ?RIOS ESCLARECEDORES

	ENDC			;FIM DO BLOCO DE DEFINIÃ?Ã?O DE VARIÃ?VEIS

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                        FLAGS INTERNOS                           *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; DEFINIÃ?Ã?O DE TODOS OS FLAGS UTILIZADOS PELO SISTEMA

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                         CONSTANTES                              *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; DEFINIÃ?Ã?O DE TODAS AS CONSTANTES UTILIZADAS PELO SISTEMA

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                           ENTRADAS                              *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; DEFINIÃ?Ã?O DE TODOS OS PINOS QUE SERÃ?O UTILIZADOS COMO ENTRADA
; RECOMENDAMOS TAMBÃ?M COMENTAR O SIGNIFICADO DE SEUS ESTADOS (0 E 1)

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                           SAÃ?DAS                                *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; DEFINIÃ?Ã?O DE TODOS OS PINOS QUE SERÃ?O UTILIZADOS COMO SAÃ?DA
; RECOMENDAMOS TAMBÃ?M COMENTAR O SIGNIFICADO DE SEUS ESTADOS (0 E 1)

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                       VETOR DE RESET                            *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

	ORG	0x00			;ENDEREÃ?O INICIAL DE PROCESSAMENTO
	GOTO	INICIO
	
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                    INÃ?CIO DA INTERRUPÃ?Ã?O                        *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; ENDEREÃ?O DE DESVIO DAS INTERRUPÃ?Ã?ES. A PRIMEIRA TAREFA Ã? SALVAR OS
; VALORES DE "W" E "STATUS" PARA RECUPERAÃ?Ã?O FUTURA

	ORG	0x04			;ENDEREÃ?O INICIAL DA INTERRUPÃ?Ã?O
	MOVWF	W_TEMP		;COPIA W PARA W_TEMP
	SWAPF	STATUS,W
	MOVWF	STATUS_TEMP	;COPIA STATUS PARA STATUS_TEMP

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                    ROTINA DE INTERRUPÃ?Ã?O                        *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; AQUI SERÃ?O ESCRITAS AS ROTINAS DE RECONHECIMENTO E TRATAMENTO DAS
; INTERRUPÃ?Ã?ES

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                 ROTINA DE SAÃ?DA DA INTERRUPÃ?Ã?O                  *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; OS VALORES DE "W" E "STATUS" DEVEM SER RECUPERADOS ANTES DE 
; RETORNAR DA INTERRUPÃ?Ã?O

SAI_INT
	SWAPF	STATUS_TEMP,W
	MOVWF	STATUS		;MOVE STATUS_TEMP PARA STATUS
	SWAPF	W_TEMP,F
	SWAPF	W_TEMP,W	;MOVE W_TEMP PARA W
	RETFIE

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*	            	 ROTINAS E SUBROTINAS                      *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; CADA ROTINA OU SUBROTINA DEVE POSSUIR A DESCRIÃ?Ã?O DE FUNCIONAMENTO
; E UM NOME COERENTE Ã?S SUAS FUNÃ?Ã?ES.

SUBROTINA1
	
CHECA_ENTRADA
	          ; Lê o estado do GPIO para o registrador W
    MOVFW    GPIO

    ; Verifica se GP3 está em nível alto
    BTFSS   GPIO, GP3        ; Se GP3=1, salta para GP3_1
    GOTO    GP3_0 
    GOTO    GP3_1; Senão (GP3=0), vai para GP3_0

GP3_0
    ; Aqui GP3=0
    ; Agora testa GP5
    BTFSS   GPIO, GP5         ; Se GP5=1, salta para RED
    GOTO    LED_DESLIGADOS      ; Se GP5=0, é desligado
    GOTO    ATIVA_RED       ; Se GP5=1, ativa o LED vermelho

GP3_1
    ; Aqui GP3=1
    ; Agora testa GP5
    BTFSS   GPIO, GP5         ; Se GP5=1, salta para BLUE
    GOTO    ATIVA_GREEN     ; Se GP5=0, ativa o LED verde
    GOTO    ATIVA_BLUE      ; Se GP5=1, ativa o LED azul

    
ATIVA_100
        MOVFW   LED_ATUAL       ; W = LED_ATUAL
        XORLW  .1
        BTFSC  STATUS, Z         ; Se LED_ATUAL == 0
        GOTO   RED_100
	

        MOVFW   LED_ATUAL
        XORLW  .2
        BTFSC  STATUS, Z         ; Se LED_ATUAL == 1
        GOTO   GREEN_100

        MOVF   LED_ATUAL, W
        XORLW  .3
        BTFSC  STATUS, Z         ; Se LED_ATUAL == 2
        GOTO   BLUE_100

RED_100
	MOVLW .100
	MOVWF  RED_CYCLE
	GOTO PWM
	
GREEN_100
	MOVLW .100
	MOVWF  GREEN_CYCLE
	GOTO PWM
BLUE_100
	MOVLW .100
	MOVWF  BLUE_CYCLE
	GOTO PWM
	
        
	
; DESLIGA TODOS OS LEDS
LED_DESLIGADOS
		RED_OFF 
		GREEN_OFF
		BLUE_OFF
		GOTO MAIN
		 
	
ATIVA_RED
	MOVLW	.1
	MOVWF	LED_ATUAL
	BSF     ADCON0, GO
	
ESPERA_RED
	BTFSC   ADCON0, GO
        GOTO    ESPERA_RED          ; aguarda conversao para o led_red
	GOTO	COMPARA

ATIVA_GREEN
	MOVLW	.2
	MOVWF	LED_ATUAL
	BSF     ADCON0, GO
	
ESPERA_GREEN
	
	BTFSC   ADCON0, GO
        GOTO    ESPERA_GREEN	    ; aguarda conversao para o led_green
	GOTO	COMPARA

ATIVA_BLUE
	MOVLW	.3
	MOVWF	LED_ATUAL
	BSF     ADCON0, GO
	
ESPERA_BLUE
	BTFSC   ADCON0, GO
        GOTO    ESPERA_BLUE	; aguarda conversao para o led_blue
	GOTO	COMPARA

	
;desliga  os leds no instante em que o duty_cycle atual sincroniza com os demais
INVERTE_RED
	    RED_OFF 
	    RETURN

INVERTE_GREEN
	    GREEN_OFF
	    RETURN

INVERTE_BLUE
	    BLUE_OFF
	    RETURN

PWM
        ; Verifica se DUTY_CYCLE é zero; se sim, pula para o tempo OFF
	MOVFW  DUTY_CYCLE
        BTFSC  STATUS, Z          ; Se DUTY_CYCLE == 0
        GOTO   PWM_DESLIGADO	  ; desliga

        MOVFW   LED_ATUAL      ; W = LED_ATUAL
        XORLW  .1
        BTFSC  STATUS, Z         ; Se LED_ATUAL == 0
        GOTO   LIGA_VERMELHO

        MOVFW  LED_ATUAL
        XORLW  .2
        BTFSC  STATUS, Z         ; Se LED_ATUAL == 1
        GOTO   LIGA_VERDE

        MOVFW   LED_ATUAL
        XORLW  .3
        BTFSC  STATUS, Z         ; Se LED_ATUAL == 2
        GOTO   LIGA_AZUL
	
LIGA_VERMELHO  
	RED_ON ; ativa para delay
        GOTO   PWM_DELAY_LIGADO

LIGA_VERDE    
	GREEN_ON ; ativa para delay
        GOTO   PWM_DELAY_LIGADO

LIGA_AZUL
        BLUE_ON   ; ativa para delay
	
PWM_DELAY_LIGADO
        ; Tempo ON = DUTY_CYCLE * 20µs
        MOVFW   DUTY_CYCLE
        CALL   ATRASO_MULTIPLICADOR

PWM_DESLIGADO
       
        ; Desliga a saída correta conforme LED_ATUAL:
        MOVFW   LED_ATUAL
        XORLW  .1
        BTFSC  STATUS, Z         ; Se LED_ATUAL == 0
        GOTO   DESLIGA_VERMELHO

        MOVFW   LED_ATUAL
        XORLW  .2
        BTFSC  STATUS, Z         ; Se LED_ATUAL == 1
        GOTO   DESLIGA_VERDE

        MOVFW   LED_ATUAL
        XORLW  .3
        BTFSC  STATUS, Z         ; Se LED_ATUAL == 2
        GOTO   DESLIGA_AZUL

DESLIGA_VERMELHO
		MOVFW RED_CYCLE		; Z = 1, QUER DIZER QUE O DUTY_CYCLE DA COR = 100%
		SUBLW .100
		BTFSC STATUS, Z
		GOTO MAIN
		RED_OFF                ; Desliga GP0 (vermelho)
        	GOTO PWM_DELAY_DESLIGADO

DESLIGA_VERDE	
		MOVFW GREEN_CYCLE
		SUBLW .100
		BTFSC STATUS, Z		
		GOTO MAIN
		GREEN_OFF              ; Desliga GP1 (verde)
		GOTO PWM_DELAY_DESLIGADO

DESLIGA_AZUL	
		MOVFW BLUE_CYCLE
		SUBLW .100
		BTFSC STATUS, Z
		GOTO MAIN
		BLUE_OFF               ; Desliga GP2 (azul)

PWM_DELAY_DESLIGADO
        ; Tempo OFF = (100 - DUTY_CYCLE) * 20µs
        MOVFW   DUTY_CYCLE
        SUBLW   .100
	BTFSS	STATUS, Z
        CALL    ATRASO_MULTIPLICADOR

        GOTO MAIN
    


ATRASO_MULTIPLICADOR
    MOVWF   CONTADOR_ATRASO    ; CONTADOR_ATRASO = número total de intervalos de 20µs
    CLRF    AUX_VAL            ; Zera AUX_VAL
ATRASO_LOOP
    CALL    DELAY_20US         ; Aguarda 20µs
    INCF    AUX_VAL       ; Incrementa AUX_VAL (tempo atual)

    ;Compara AUX_VAL com RED_CYCLE
    MOVFW   AUX_VAL				; W = AUX_VAL
    SUBWF   RED_CYCLE, W			; W = RED_CYCLE - AUX_VAL
    BTFSC   STATUS, Z				 ; Se AUX_VAL == RED_CYCLE
    CALL INVERTE_RED				; Inverte LED vermelho (GP0)

    ;Compara AUX_VAL com GREEN_CYCLE
    MOVFW   AUX_VAL
    SUBWF   GREEN_CYCLE, W			 ; W = GREEN_CYCLE - AUX_VAL
    BTFSC   STATUS, Z
    CALL INVERTE_GREEN				 ; Inverte LED verde (GP1)

    ;Compara AUX_VAL com BLUE_CYCLE
    MOVFW   AUX_VAL
    SUBWF   BLUE_CYCLE, W			 ; W = BLUE_CYCLE - AUX_VAL
    BTFSC   STATUS, Z
    CALL INVERTE_BLUE				 ; Inverte LED azul (GP2)

    DECFSZ  CONTADOR_ATRASO			; Decrementa CONTADOR_ATRASO; se zero, pula a proxima instrução
    GOTO    ATRASO_LOOP        
    RETURN


    
; estava usando o delay correto de 2ms, porem por conta da  minha logica de checagem, acabei dando um overhead de instrucoes que 
; que aumentou consideravelmente o tempo de execucao, subi um pouco o valor inicial do timer para amenizar (3ms), mas nao consegui pensar em outra forma.
DELAY_20US
    MOVLW   .255 
    MOVWF   TMR0    
    BCF     INTCON, T0IF   ; Zera a flag de overflow do Timer0

ESPERA_TMR0
    BTFSS   INTCON, T0IF   ; Aguarda o overflow do Timer0
    GOTO    ESPERA_TMR0
    RETURN
	


	
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                     INICIO DO PROGRAMA                          *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
	
INICIO
    BANK1            ;ALTERA PARA O BANCO 1
    MOVLW    B'00111000'    ;CONFIGURA TODAS AS PORTAS DO GPIO (PINOS)
    MOVWF    TRISIO        ;COMO SAÃ?DAS
    MOVLW    B'00011000'    ;DEFINE PORTAS COMO Digital I/O
    MOVWF    ANSEL
    MOVLW    B'10000000'
    MOVWF    OPTION_REG ;DEFINE OPÃ?Ã?ES DE OPERAÃ?Ã?O
    MOVLW    B'00000000'
    MOVWF    INTCON        ;DEFINE OPÃ?Ã?ES DE INTERRUPÃ?Ã?ES
    BANK0                ;RETORNA PARA O BANCO
    MOVLW    B'00000111'
    MOVWF    CMCON        ;DEFINE O MODO DE OPERAÃ?Ã?O DO COMPARADOR ANALÃ?GICO
    MOVLW    B'00001101'    
    MOVWF    ADCON0
    
    
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                     INICIALIZAÃ?Ã?O DAS VARIÃ?VEIS                 *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
 
  GOTO LED_DESLIGADOS
  
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                     ROTINA PRINCIPAL                            *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

MAIN	
  
  
 GOTO CHECA_ENTRADA  ; checa valor do gp3 e gp5
 
COMPARA
	RED_ON ; inicia todos os leds ligados para que seja possivel paralelizar a execucao
	GREEN_ON
	BLUE_ON
        ; Compara ADRESH com 249
        MOVLW   .249       ; Carrega 249 em W
        SUBWF   ADRESH, W       ; W = ADRESH - 249
        BTFSS   STATUS, C       ; Se Carry = 0 (ou seja, ADRESH < 249)
        GOTO    CALCULO_PROPORCAO  ; vai calcular proporcionalmente
	MOVLW   .100
	MOVWF   DUTY_CYCLE
        GOTO    ATIVA_100            ; Se ADRESH >= 249, fixa DUTY_CYCLE em 100


; Para calcular o DUTY_CYCLE como (ADRESH * 100)/250 ? ADRESH * 0,4,
; optei por aproximar 0,4 por 13/32. 
; 13/32 = 0,40625, o que tem um erro de apenas ~1,56% em relação a 0,4.
; Além disso, dividir por 32 pode ser feito com 5 deslocamentos à direita
; Assim, DUTY_CYCLE ? (ADRESH * 13) >> 5.

	
	
CALCULO_PROPORCAO
	
        ; Zera os registradores de 16 bits (produto)
        CLRF    RESULT_ALTO
        CLRF    RESULT_BAIXO

        ; Prepara o contador com 13 (para multiplicar ADRESH por 13)
        MOVLW   .13
        MOVWF   CONTADOR_AUX

MULTIPLICADOR_LOOP
        ; Soma ADRESH à variável de 16 bits (RESULT_ALTO:RESULT_BAIXO)
	; W = ADRESH
	; RESULT_BAIXO = RESULT_BAIXO + ADRESH
	; Se houve carry da soma
	; incrementa RESULT_ALTO
	; Decrementa o contador
	; Repete até somar 13 vezes
	
        MOVFW    ADRESH   
        ADDWF   RESULT_BAIXO  
        BTFSC   STATUS, C     
        INCF    RESULT_ALTO 
        DECFSZ  CONTADOR_AUX    
        GOTO    MULTIPLICADOR_LOOP     

        ; Agora RESULT_ALTO:RESULT_BAIXO = ADRESH * 13 (em 16 bits)
        ; Em seguida, divide esse valor por 32 realizando 5 deslocamentos à direita
        MOVLW   .5
        MOVWF   CONTADOR_AUX          ; CONTADOR conta os shifts (5 vezes)
DESLOCA_5
        RRF     RESULT_ALTO  ; Desloca o bit menos significativo de RESULT_ALTO para RESULT_BAIXO
        RRF     RESULT_BAIXO ; Desloca RESULT_BAIXO(equivale a dividir por 2)
        DECFSZ  CONTADOR_AUX
        GOTO    DESLOCA_5	; Após 5 deslocamentos, RESULT_BAIXO contém o valor aproximado de (ADRESH * 13)/32
        MOVFW   RESULT_BAIXO
	
        BTFSC   GPIO, GP3         ; Se GP3 = 1, vai para o bloco de Green/Blue
        GOTO    CHECA_BLUE
        ; Caso GP3 = 0, testa GP5:
        BTFSC   GPIO, GP5         ; Se GP5 = 1 (e GP3 = 0) ? LED vermelho
        MOVWF   RED_CYCLE
	MOVWF	DUTY_CYCLE
        GOTO    PWM
        ; Se GP5 também = 0 ? LEDs desligados
        GOTO    LED_DESLIGADOS

CHECA_BLUE
        ; Aqui, GP3 = 1. Agora verifica GP5:
        BTFSS   GPIO, GP5 
	GOTO	CHECA_GREEN	    ; Se GP5 = 1 ? LED azul
        MOVWF   BLUE_CYCLE
	MOVWF	DUTY_CYCLE
        GOTO    PWM
CHECA_GREEN
        ; Se GP5 = 0 ? LED verde
        MOVWF   GREEN_CYCLE
	MOVWF	DUTY_CYCLE
        GOTO    PWM

    END