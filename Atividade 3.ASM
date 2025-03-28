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
		CONTADOR_OVERFLOW
				    ;COLOQUE AQUI SUAS NOVAS VARIÁVEIS
		;		    NÃO ESQUEÇA COMENTÁRIOS ESCLARECEDORES

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
; CADA ROTINA OU SUBROTINA DEVE POSSUIR A DESCRI  O DE FUNCIONAMENTO
; E UM NOME COERENTE  S SUAS FUN  ES.

SUBROTINA1

; Testes para verificar se o sinal de entrada   maior ou menor que a referencia atual.

TESTA_100
    BANK1
    MOVLW   B'10001110'     ; Configura VRCON para n vel ~100%
    MOVWF   VRCON           ; V = 3,43V
    BANK0
    BTFSC   CMCON, COUT
    GOTO    DEFINE_100      ; Se maior ou igual a 100%, define 100%
    GOTO    TESTA_75        ; Caso contr rio, testa pr ximo n vel

; Teste para valores entre 75% e 100%
TESTA_75
    BANK1
    MOVLW   B'10001001'     ; Configura VRCON para n vel ~75%
    MOVWF   VRCON           ; V = 2,63V
    BANK0
    BTFSC   CMCON, COUT
    GOTO    DEFINE_75       ; Se maior ou igual a 75%, define 75%
    GOTO    TESTA_50        ; Caso contr rio, testa pr ximo n vel

; Teste para valores entre 50% e 75%
TESTA_50
    BANK1
    MOVLW   B'10000011'     ; Configura VRCON para n vel ~50%
    MOVWF   VRCON           ; V = 1,718V
    BANK0
    BTFSC   CMCON, COUT
    GOTO    DEFINE_50       ; Se maior ou igual a 50%, define 50%
    GOTO    TESTA_25        ; Caso contr rio, testa pr ximo n vel

; Teste para valores entre 25% e 50%
TESTA_25
    BANK1
    MOVLW   B'10100100'     ; Configura VRCON para n vel ~25%
    MOVWF   VRCON           ; V = 0,8333V
    BANK0
    BTFSC   CMCON, COUT
    GOTO    DEFINE_25       ; Se maior ou igual a 25%, define 25%
    GOTO    DEFINE_0        ; Caso contr rio, define 0%
  

 ; Define o delay para cada DUTY CYCLE com base na quantidade de OVERFLOW
 ; (tempo em HIGH e LOW)
 
DEFINE_0
    BSF     GPIO, GP4        
    MOVLW   .4           
    MOVWF   CONTADOR_OVERFLOW
    CALL    DELAY_500HZ  
    GOTO MAIN
    
DEFINE_25
    BSF     GPIO, GP4        ; Liga LED
    MOVLW   .1              
    MOVWF   CONTADOR_OVERFLOW
    CALL    DELAY_500HZ  

    BCF     GPIO, GP4        ; Desliga LED
    MOVLW   .3              
    MOVWF   CONTADOR_OVERFLOW
    CALL    DELAY_500HZ     

    GOTO    MAIN
   

DEFINE_50
    BSF     GPIO, GP4
    MOVLW   .2               
    MOVWF   CONTADOR_OVERFLOW
    CALL    DELAY_500HZ
    
    BCF     GPIO, GP4
    MOVLW   .2               
    MOVWF   CONTADOR_OVERFLOW
    CALL    DELAY_500HZ
    
    GOTO    MAIN
    
DEFINE_75
    BSF     GPIO, GP4
    MOVLW   .3               
    MOVWF   CONTADOR_OVERFLOW
    CALL    DELAY_500HZ
    
    BCF     GPIO, GP4
    MOVLW   .1               
    MOVWF   CONTADOR_OVERFLOW
    CALL    DELAY_500HZ
    
    GOTO    MAIN

DEFINE_100
    BSF     GPIO, GP4            
    GOTO    MAIN     
    
; Rotina de atraso para 500Hz
; O timer est  configurado com um prescaler de 1:16
; O PIC12F675 utiliza um clock de 4MHz, resultando em um ciclo de instru  o de 1 s.
; Com um prescaler de 1:16, cada incremento no Timer0 ocorre a cada 16 s.
; Para obter um overflow a cada ~500 s,   necess rio que o Timer0 conte at  31:
; 31 * 16 s = 496 s (~500 s)

DELAY_500HZ
    MOVLW   .224
    MOVWF   TMR0
    BCF     INTCON, T0IF

ESPERANDO_OVERFLOW
    BTFSS   INTCON, T0IF
    GOTO    ESPERANDO_OVERFLOW
    BCF     INTCON, T0IF

    DECFSZ  CONTADOR_OVERFLOW
    GOTO    DELAY_500HZ
    
    RETURN

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                     INICIO DO PROGRAMA                          *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
	
INICIO
    BANK1		     ; ALTERA PARA O BANCO 1
    MOVLW    B'00001010'     ; CONFIGURA TODAS AS PORTAS DO GPIO (PINOS)
    MOVWF    TRISIO	    
    MOVLW    B'10001110'  
    MOVWF    VRCON        ; CONFIGURA A TENSAO DE REFERENCIA INTERNA
    MOVLW    B'00000010'    ;DEFINE GP1 COMO ENTRADA ANAL GICA
    MOVWF    ANSEL      
    MOVLW    B'10000011'
    MOVWF    OPTION_REG    ; DEFINE OPCOES DE OPERACAO E PRESCLAE DE 1:16
    MOVLW    B'00000000'
    MOVWF    INTCON        ; DEFINE OPCOES DE INTERRUPCOES
    BANK0		   ; RETORNA PARA O BANCO 0 
    MOVLW    B'00010100'   ; CONFIGURA O COMPARADOR PARA UTILIZAR REFER NCIA INTERNA
    MOVWF    CMCON
    
    BCF GPIO,GP4	    ; INICIA GP4 EM LOW
	

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                     INICIALIZA  O DAS VARI VEIS                 *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
 
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                     ROTINA PRINCIPAL                            *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
MAIN 
    CALL    TESTA_100
    GOTO    MAIN
END
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                       FIM DO PROGRAMA                           *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
	
	


