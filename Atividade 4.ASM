;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*              MODIFICAÇÕES PARA USO COM 12F675                   *
;*                FEITAS PELO PROF. MARDSON                        *
;*                      DEZEMBRO DE 2024                           *
;*                 BASEADO NO EXEMPLO DO LIVRO                     *
;*           Desbravando o PIC. David José de Souza                *
;*-----------------------------------------------------------------*
;*   MODELO PARA O PIC 12F675                                      *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                     ARQUIVOS DE DEFINIÇÕES                      *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
#INCLUDE <p12f675.inc>	;ARQUIVO PADRÃO MICROCHIP PARA 12F675

	__CONFIG _BODEN_OFF & _CP_OFF & _PWRTE_ON & _WDT_OFF & _MCLRE_ON & _INTRC_OSC_NOCLKOUT

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                    PAGINAÇÃO DE MEMÓRIA                         *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;DEFINIÇÃO DE COMANDOS DE USUÁRIO PARA ALTERAÇÃO DA PÁGINA DE MEMÓRIA
#DEFINE	BANK0	BCF STATUS,RP0	;SETA BANK 0 DE MEMÓRIA
#DEFINE	BANK1	BSF STATUS,RP0	;SETA BANK 1 DE MAMÓRIA

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                         VARIÁVEIS                               *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; DEFINIÇÃO DOS NOMES E ENDEREÇOS DE TODAS AS VARIÁVEIS UTILIZADAS 
; PELO SISTEMA

	CBLOCK	0x20	;ENDEREÇO INICIAL DA MEMÓRIA DE
					;USUÁRIO
		W_TEMP		;REGISTRADORES TEMPORÁRIOS PARA USO
		STATUS_TEMP	;JUNTO ÀS INTERRUPÇÕES
		DUTY_CYCLE
		RESULT_ALTO
		RESULT_BAIXO
		CONTADOR_AUX
		CONTADOR_ATRASO
	
		;COLOQUE AQUI SUAS NOVAS VARIÁVEIS
		;NÃO ESQUEÇA COMENTÁRIOS ESCLARECEDORES

	ENDC			;FIM DO BLOCO DE DEFINIÇÃO DE VARIÁVEIS

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                        FLAGS INTERNOS                           *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; DEFINIÇÃO DE TODOS OS FLAGS UTILIZADOS PELO SISTEMA

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                         CONSTANTES                              *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; DEFINIÇÃO DE TODAS AS CONSTANTES UTILIZADAS PELO SISTEMA

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                           ENTRADAS                              *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; DEFINIÇÃO DE TODOS OS PINOS QUE SERÃO UTILIZADOS COMO ENTRADA
; RECOMENDAMOS TAMBÉM COMENTAR O SIGNIFICADO DE SEUS ESTADOS (0 E 1)

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                           SAÍDAS                                *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; DEFINIÇÃO DE TODOS OS PINOS QUE SERÃO UTILIZADOS COMO SAÍDA
; RECOMENDAMOS TAMBÉM COMENTAR O SIGNIFICADO DE SEUS ESTADOS (0 E 1)

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                       VETOR DE RESET                            *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

	ORG	0x00			;ENDEREÇO INICIAL DE PROCESSAMENTO
	GOTO	INICIO
	
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                    INÍCIO DA INTERRUPÇÃO                        *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; ENDEREÇO DE DESVIO DAS INTERRUPÇÕES. A PRIMEIRA TAREFA É SALVAR OS
; VALORES DE "W" E "STATUS" PARA RECUPERAÇÃO FUTURA

	ORG	0x04			;ENDEREÇO INICIAL DA INTERRUPÇÃO
	MOVWF	W_TEMP		;COPIA W PARA W_TEMP
	SWAPF	STATUS,W
	MOVWF	STATUS_TEMP	;COPIA STATUS PARA STATUS_TEMP

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                    ROTINA DE INTERRUPÇÃO                        *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; AQUI SERÃO ESCRITAS AS ROTINAS DE RECONHECIMENTO E TRATAMENTO DAS
; INTERRUPÇÕES

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                 ROTINA DE SAÍDA DA INTERRUPÇÃO                  *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; OS VALORES DE "W" E "STATUS" DEVEM SER RECUPERADOS ANTES DE 
; RETORNAR DA INTERRUPÇÃO

SAI_INT
	SWAPF	STATUS_TEMP,W
	MOVWF	STATUS		;MOVE STATUS_TEMP PARA STATUS
	SWAPF	W_TEMP,F
	SWAPF	W_TEMP,W	;MOVE W_TEMP PARA W
	RETFIE

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*	            	 ROTINAS E SUBROTINAS                      *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; CADA ROTINA OU SUBROTINA DEVE POSSUIR A DESCRIÇÃO DE FUNCIONAMENTO
; E UM NOME COERENTE ÀS SUAS FUNÇÕES.

SUBROTINA1
	
LIGA
	BSF GPIO, GP0
	GOTO MAIN
PWM
        
	MOVLW   DUTY_CYCLE    ; W = DUTY_CYCLE
        BTFSC   STATUS, Z        ; Se DUTY_CYCLE == 0, Zero flag estar� setada
        GOTO    PWM_DESLIGADO     ; Pula a parte de ligar o LED
	
	
	; Liga a sa�da 
	
        BSF     GPIO, GP0

        ; Tempo ON = DUTY_CYCLE * 20�s
        MOVFW   DUTY_CYCLE
        CALL    ATRASO_MULTIPLICADOR

        ; Desliga a sa�da (GP0 = LOW)
PWM_DESLIGADO
	; Calcula Tempo OFF = (100 - DUTY_CYCLE) * 20�s
        BCF     GPIO, GP0 
	MOVFW DUTY_CYCLE
	SUBLW .100
        CALL    ATRASO_MULTIPLICADOR

        GOTO    MAIN             


ATRASO_MULTIPLICADOR
        MOVWF   CONTADOR_ATRASO     ; CONTADOR_ATRASO = n�mero de intervalos de 20�s
ATRASO_LOOP
        CALL    DELAY_20US          ; Atraso de 20�s
        DECFSZ  CONTADOR_ATRASO, F
        GOTO    ATRASO_LOOP
        RETURN

DELAY_20US
    MOVLW   .254    ; Pr�-carrega TMR0 com 254
    MOVWF   TMR0    ;
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
    MOVLW    B'00011000'    ;CONFIGURA TODAS AS PORTAS DO GPIO (PINOS)
    MOVWF    TRISIO        ;COMO SAÍDAS
    MOVLW    B'00011000'    ;DEFINE PORTAS COMO Digital I/O
    MOVWF    ANSEL
    MOVLW    B'10000000'
    MOVWF    OPTION_REG ;DEFINE OP�?�?ES DE OPERA�?�?O
    MOVLW    B'00000000'
    MOVWF    INTCON        ;DEFINE OP�?�?ES DE INTERRUP�?�?ES
    BANK0                ;RETORNA PARA O BANCO
    MOVLW    B'00000111'
    MOVWF    CMCON        ;DEFINE O MODO DE OPERA�?�?O DO COMPARADOR ANAL�?GICO
    MOVLW    B'00001101'    
    MOVWF    ADCON0
    
    
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                     INICIALIZAÇÃO DAS VARIÁVEIS                 *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
    
    BCF GPIO, GP0

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                     ROTINA PRINCIPAL                            *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

MAIN	
        ; Inicia a convers�o ADC 
        BSF     ADCON0, GO      ;

ESPERA
        BTFSC   ADCON0, GO
        GOTO    ESPERA          ; aguarda

        ; Compara ADRESH com 249
        MOVLW   .249       ; Carrega 249 em W
        SUBWF   ADRESH, W       ; W = ADRESH - 249
        BTFSS   STATUS, C       ; Se Carry = 0 (ou seja, ADRESH < 249)
        GOTO    CALCULO_PROPORCAO  ; vai calcular proporcionalmente
        GOTO    LIGA            ; Se ADRESH >= 249, fixa DUTY_CYCLE em 100


; Para calcular o DUTY_CYCLE como (ADRESH * 100)/250 ? ADRESH * 0,4,
; optei por aproximar 0,4 por 13/32. 
; 13/32 = 0,40625, o que tem um erro de apenas ~1,56% em rela��o a 0,4.
; Al�m disso, dividir por 32 pode ser feito com 5 deslocamentos � direita
; Assim, DUTY_CYCLE ? (ADRESH * 13) >> 5.

	
	
CALCULO_PROPORCAO
        ; Zera os registradores de 16 bits (produto)
        CLRF    RESULT_ALTO
        CLRF    RESULT_BAIXO

        ; Prepara o contador com 13 (para multiplicar ADRESH por 13)
        MOVLW   .13
        MOVWF   CONTADOR_AUX

MULTIPLICADOR_LOOP
        ; Soma ADRESH � vari�vel de 16 bits (RESULT_ALTO:RESULT_BAIXO)
	; W = ADRESH
	; RESULT_BAIXO = RESULT_BAIXO + ADRESH
	; Se houve carry da soma
	; incrementa RESULT_ALTO
	; Decrementa o contador
	; Repete at� somar 13 vezes
	
        MOVFW    ADRESH   
        ADDWF   RESULT_BAIXO  
        BTFSC   STATUS, C     
        INCF    RESULT_ALTO 
        DECFSZ  CONTADOR_AUX    
        GOTO    MULTIPLICADOR_LOOP     

        ; Agora RESULT_ALTO:RESULT_BAIXO = ADRESH * 13 (em 16 bits)
        ; Em seguida, divide esse valor por 32 realizando 5 deslocamentos � direita
        MOVLW   .5
        MOVWF   CONTADOR_AUX          ; CONTADOR conta os shifts (5 vezes)
	
DESLOCA_5
        RRF     RESULT_ALTO  ; Desloca o bit menos significativo de RESULT_ALTO para RESULT_BAIXO
        RRF     RESULT_BAIXO ; Desloca RESULT_BAIXO(equivale a dividir por 2)
        DECFSZ  CONTADOR_AUX
        GOTO    DESLOCA_5			; Ap�s 5 deslocamentos, RESULT_BAIXO cont�m o valor aproximado de (ADRESH * 13)/32
        MOVFW   RESULT_BAIXO
        MOVWF   DUTY_CYCLE    ; Armazena o resultado final no DUTY_CYCLE
        GOTO    PWM

    END