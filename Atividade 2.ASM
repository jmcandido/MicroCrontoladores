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
		CONTADOR
		CONTADOR_OVERFLOW
		AUX
		
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

	;CORPO DA ROTINA

	RETURN

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                     INICIO DO PROGRAMA                          *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
	
INICIO
	BANK1				;ALTERA PARA O BANCO 1
	MOVLW	B'00000000' ;CONFIGURA TODAS AS PORTAS DO GPIO (PINOS)
	MOVWF	TRISIO		;COMO SAÍDAS
	CLRF	ANSEL 		;DEFINE PORTAS COMO Digital I/O
	MOVLW	B'00000111'
	MOVWF	OPTION_REG	;DEFINE OPÇÕES DE OPERAÇÃO
	MOVLW	B'00000000'
	MOVWF	INTCON		;DEFINE OPÇÕES DE INTERRUPÇÕES
	BANK0				;RETORNA PARA O BANCO
	MOVLW	B'00000111'
	MOVWF	CMCON		;DEFINE O MODO DE OPERAÇÃO DO COMPARADOR ANALÓGICO

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                     INICIALIZAÇÃO DAS VARIÁVEIS                 *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
        MOVLW .10
        MOVWF CONTADOR
	
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                     ROTINA PRINCIPAL                            *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
	
	
MAIN
	DECF CONTADOR, F    ;decrementa a contagem (o contador inicia com 10, pois estou realizando o decremento no come�o)
	BTFSS CONTADOR, 7   ;Testando o bit 7 do contador (mais significatio) que no format0 complemento de 2 indica o sinal do numero.
	GOTO  TROCA_DISPLAY ;ou seja, se contador for negativo ele n�o atualiza o display, primeiro reinicia a contagem para 9.
	BTFSS GPIO, GP0	    ;verica o estado atual do led, caso esteja em 1, ira pular para a subrotina desliga led
	GOTO LIGA_LED	    ;subrotina para ligar o led
	GOTO DESLIGA_LED    ;subrotina para desligar o led

	
TROCA_DISPLAY
	CALL CONVERTE_BCD   ;chama a subrotina que ir� converter o valor do contador para o formato bcd (alterando ou n�o os valores de gp5, gp4, gp2, gp1)
	CALL DELAY	    ;introduz um atraso , garantindo que o valor do contador (ou a mudan�a do led) seja vis�vel por um tempo antes de prosseguir
	GOTO MAIN	    ;retorna para a main para continuar o ciclo
	
DESLIGA_LED
	MOVLW .9	    ;valor de CONTADOR ser� reiniciado para 9 quando o LED for desligado
        MOVWF CONTADOR
	CALL CONVERTE_BCD   ;chama  CONVERTE_BCD para atualizar o display com o valor atual de 9
	CALL    DELAY	    ;introduz um atraso
	BCF GPIO, GP0	    ;limpa o pino GP0, desligando o led
	GOTO MAIN
LIGA_LED
	MOVLW .9	    ;valor de CONTADOR ser� reiniciado para 9 quando o LED for ligado
        MOVWF CONTADOR
	CALL CONVERTE_BCD   ;chama  CONVERTE_BCD para atualizar o display com o valor atual de 9
	CALL    DELAY	    ;introduz um atraso
	BSF GPIO, GP0	    ;seta o pino GP0, ligando o led
	GOTO MAIN

 CONVERTE_BCD
 
	;armazena o valor de W em AUX para us�-lo nos proximos testes
	;Para cada bit de AUX, a subrotina testa se o bit � 1 ou 0 e, com base nisso, seta ou limpa o pino correspondente da porta GPIO.
	
	MOVF    CONTADOR, W
        MOVWF   AUX	   
	
	;GP1 controlado pelo bit 0 de AUX
	BTFSC   AUX, 0
	BSF     GPIO, GP1
	BTFSS   AUX, 0
	BCF     GPIO, GP1

	;GP2 controlado pelo bit 1 de AUX
	BTFSC   AUX, 1
	BSF     GPIO, GP2
	BTFSS   AUX, 1
	BCF     GPIO, GP2

	;GP4 controlado pelo bit 2 de AUX
	BTFSC   AUX, 2
	BSF     GPIO, GP4
	BTFSS   AUX, 2
	BCF     GPIO, GP4

	;GP5 controlado pelo bit 3 de AUX
	BTFSC   AUX, 3
	BSF     GPIO, GP5
	BTFSS   AUX, 3
	BCF     GPIO, GP5
	RETURN
    
	
		    ;Utilizei um intervalo de 25ms por overflow
		    ;Para atingir 25 ms, � necess�rio que o timer0 n�o conte at� 255, mas sim at� certo valor que fa�a demorar 25 ms.

		    ;cicloTimer = (prescaler / freqClock) x 4
		    ;cicloTimer = (256/ 4x10^6) x 4 
		    ;cicloTimer = 256us
		    ;25ms/ 256us = 97
		    ;Valor inicial do timer = 256 - 97 = 159

		    ;Se o Timer0 parte de 159 e ele s� conta at� 255, ser� contado 97 incrementos
		    ;Dessa forma, ele demora 97 � 256 �s ? 24,8 = 25 ms para estourar.
		    ;Se cada overflow (partindo de 159) demora 25 ms, quantos overflows precisamos?
		    ;qtdOverflow = 500ms/25ms = 20
	
DELAY
    MOVLW   .20             
    MOVWF   CONTADOR_OVERFLOW

DELAY_LOOP
    MOVLW   .159         
    MOVWF   TMR0		;carrega TMR0 com 159  
    BCF     INTCON, T0IF	;limpa a flag de overflow

ESPERANDO_OVERFLOW
    BTFSS   INTCON, T0IF	;espera at� TMR0 estourar
    GOTO    ESPERANDO_OVERFLOW	
    BCF     INTCON, T0IF	;limpa flag para pr�xima contagem
    DECFSZ  CONTADOR_OVERFLOW	;decrementa o loop de 20
    GOTO    DELAY_LOOP		;repete at� zerar
    RETURN

END