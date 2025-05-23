;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*              MODIFICA��ES PARA USO COM 12F675                   *
;*                FEITAS PELO PROF. MARDSON                        *
;*                     Mar�o DE 2025                              *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                       NOME DO PROJETO                           *
;*                           CLIENTE                               *
;*         DESENVOLVIDO PELA MOSAICO ENGENHARIA E CONSULTORIA      *
;*   VERS�O: 1.0                           DATA: 17/06/03          *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                     DESCRI��O DO ARQUIVO                        *
;*-----------------------------------------------------------------*
;*   MODELO PARA O PIC 12F675                                      *
;*                                                                 *
;*                                                                 *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                     ARQUIVOS DE DEFINI��ES                      *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
#INCLUDE <p12f675.inc>	;ARQUIVO PADR�O MICROCHIP PARA 12F675

	__CONFIG _BODEN_OFF & _CP_OFF & _PWRTE_ON & _WDT_OFF & _MCLRE_ON & _INTRC_OSC_NOCLKOUT

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                    PAGINA��O DE MEM�RIA                         *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;DEFINI��O DE COMANDOS DE USU�RIO PARA ALTERA��O DA P�GINA DE MEM�RIA
#DEFINE	BANK0	BCF STATUS,RP0	;SETA BANK 0 DE MEM�RIA
#DEFINE	BANK1	BSF STATUS,RP0	;SETA BANK 1 DE MAM�RIA

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                         VARI�VEIS                               *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; DEFINI��O DOS NOMES E ENDERE�OS DE TODAS AS VARI�VEIS UTILIZADAS 
; PELO SISTEMA

	CBLOCK	0x20	;ENDERE�O INICIAL DA MEM�RIA DE
					;USU�RIO
		W_TEMP		;REGISTRADORES TEMPOR�RIOS PARA USO
		STATUS_TEMP	;JUNTO �S INTERRUP��ES
		DADO		;ARMAZENA O DADO PARA A EEPROM
		SOMA_BAIXA
		SOMA_ALTA
		CONT_AUX
		CONT_DESLOC
		CONT_OVERFLOW
		MAIOR_VALOR
		AUX_LOOP
		;NOVAS VARI�VEIS

	ENDC			;FIM DO BLOCO DE MEM�RIA
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                        FLAGS INTERNOS                           *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; DEFINI��O DE TODOS OS FLAGS UTILIZADOS PELO SISTEMA

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                         CONSTANTES                              *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; DEFINI��O DE TODAS AS CONSTANTES UTILIZADAS PELO SISTEMA
; INICIALIZA��O DA EEPROM, DE ACORDO COM A DESCRI��O NO ARQUIVO "Def_Rega_Formigas.inc"

;A PARTIR DO ENDERE�O ZERO DA EEPROM, DADOS EM ORDEM ALEAT�RIA
	ORG 0x2100
	DE	0X89,0X1E,0X39,0X9F,0XC2,0X0C,0XAB,0X33,0X63,0XD3,0X95,0X7B,0X38,0XD6,0X1E,0X48
	DE	0XDB,0XD8,0X86,0XFD,0XA5,0XFC,0X0C,0XBE,0X68,0X9B,0XD9,0X10,0XD8,0XEC,0X90,0X91
	DE	0XAA,0XBB,0XCC,0XDD,0XEE,0XF1,0XC9,0X77

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                           ENTRADAS                              *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; DEFINI��O DE TODOS OS PINOS QUE SER�O UTILIZADOS COMO ENTRADA
; RECOMENDAMOS TAMB�M COMENTAR O SIGNIFICADO DE SEUS ESTADOS (0 E 1)

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                           SA�DAS                                *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; DEFINI��O DE TODOS OS PINOS QUE SER�O UTILIZADOS COMO SA�DA
; RECOMENDAMOS TAMB�M COMENTAR O SIGNIFICADO DE SEUS ESTADOS (0 E 1)

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                       VETOR DE RESET                            *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

	ORG	0x00			;ENDERE�O INICIAL DE PROCESSAMENTO
	GOTO	INICIO
	
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                    IN�CIO DA INTERRUP��O                        *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; ENDERE�O DE DESVIO DAS INTERRUP��ES. A PRIMEIRA TAREFA � SALVAR OS
; VALORES DE "W" E "STATUS" PARA RECUPERA��O FUTURA

	ORG	0x04			;ENDERE�O INICIAL DA INTERRUP��O
	MOVWF	W_TEMP		;COPIA W PARA W_TEMP
	SWAPF	STATUS,W
	MOVWF	STATUS_TEMP	;COPIA STATUS PARA STATUS_TEMP

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                    ROTINA DE INTERRUP��O                        *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; AQUI SER�O ESCRITAS AS ROTINAS DE RECONHECIMENTO E TRATAMENTO DAS
; INTERRUP��ES

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                 ROTINA DE SA�DA DA INTERRUP��O                  *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; OS VALORES DE "W" E "STATUS" DEVEM SER RECUPERADOS ANTES DE 
; RETORNAR DA INTERRUP��O

SAI_INT
	SWAPF	STATUS_TEMP,W
	MOVWF	STATUS		;MOVE STATUS_TEMP PARA STATUS
	SWAPF	W_TEMP,F
	SWAPF	W_TEMP,W	;MOVE W_TEMP PARA W
	RETFIE

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*	            	 ROTINAS E SUBROTINAS                      *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; CADA ROTINA OU SUBROTINA DEVE POSSUIR A DESCRI��O DE FUNCIONAMENTO
; E UM NOME COERENTE �S SUAS FUN��ES.
LE_EEPROM
;LER DADO DA EEPROM, CUJO ENDERE�O � INDICADO EM W
;O DADO LIDO RETORNA EM W
	ANDLW	.127		;LIMITA ENDERE�O MAX. 127
	BANK1				;ACESSO VIA BANK 1
	MOVWF	EEADR		;INDICA O END. DE LEITURA
	BSF		EECON1,RD	;INICIA O PROCESSO DE LEITURA
	MOVF	EEDATA,W	;COLOCA DADO LIDO EM W
	BANK0				;POSICIONA PARA BANK 0
	RETURN

GRAVA_EEPROM
;ESCREVE UM DADO NA EEPROM, CUJO ENDERE�O � INDICADO EM W
;O DADO A SER ESCRITO DEVE ESTAR ARMAZENADO NA VARI�VEL DADO
	ANDLW	.127		;LIMITA ENDERE�O MAX. 127
	BANK1				;ACESSO VIA BANK 1
	MOVWF	EEADR
	MOVF	DADO,W
	MOVWF	EEDATA
	BSF		EECON1,WREN ;HABILITA ESCRITA
	BCF		INTCON,GIE	;DESLIGA INTERRUP��ES
	MOVLW	B'01010101'	;DESBLOQUEIA ESCRITA
	MOVWF	EECON2		;
	MOVLW	B'10101010'	;DESBLOQUEIA ESCRITA
	MOVWF	EECON2		;
	BSF		EECON1,WR ;INICIA A ESCRITA
AGUARDA
	BTFSC	EECON1,WR ;TERMINOU?
	GOTO	AGUARDA
	BSF		INTCON,GIE ;HABILITA INTERRUP��ES
	BANK0				;POSICIONA PARA BANK 0
	RETURN
	

SETA_420
	MOVLW   D'215'	    ; Limita a 420m 
	MOVWF	SOMA_BAIXA
	RETURN

DESLOCA_5
	 RRF     SOMA_ALTA   ; Rotaciona � direita a parte alta (atrav�s do Carry)
	 RRF     SOMA_BAIXA   ; Rotaciona � direita a parte baixa
	 DECFSZ  CONT_DESLOC  ; Repete 5 vezes
	 GOTO    DESLOCA_5
	 RETURN

LIMITA_420
	MOVLW   D'215'         ; Carrega o valor 215 em W (valor m�ximo correspondente a 420 m)
	SUBWF   SOMA_BAIXA, W  ; Calcula: SOMA_BAIXA - 215; se SOMA_BAIXA < 215 ocorrer�
	BTFSC   STATUS, C       ; Se Carry estiver setado, significa que SOMA_BAIXA >= 215
	CALL	SETA_420
	RETURN
	
DELAY_5S
    MOVLW   .10           ; Carrega o literal 10 em W. Esse valor representa o n�mero de ciclos de delay (cada um de ~500ms) para totalizar 5 segundos (10 x 500ms = 5s)
    MOVWF   CONT_OVERFLOW ; Armazena 10 no contador de overflow, que controla quantas vezes a rotina DELAY deve ser executada
    CALL    DELAY         ; Chama a rotina DELAY, que gera um atraso de  5s.
    BSF     GPIO, GP1     ; Ap�s o delay de 5s, seta o pino GP1 em n�vel HIGH


ABRE_PARAQUEDAS
    MOVLW   .4            ; Carrega o literal 4 em W. Este valor indica que ser�o executados 4 ciclos de delay (4 x 500ms = 2s)
    MOVWF   CONT_OVERFLOW ; Armazena 4 no contador de overflow
    CALL    DELAY         ; Chama a rotina DELAY, que gera um atraso de 2s
    BCF     GPIO, GP1     ; Ap�s o delay de 2s, limpa GP1
    GOTO    FIM           ; Encerra a execu��o 

	
DELAY
    BCF   PIR1, TMR1IF   ; Limpa o flag de overflow do Timer1 para garantir que n�o h� um overflow pendente
    MOVLW   .11          ; Carrega o valor 11 em W para a pr�-carga do byte alto do Timer1
    MOVWF   TMR1H        ; Armazena 11 em TMR1H
    MOVLW   .220         ; Carrega o valor 220 em W para a pr�-carga do byte baixo do Timer1
    MOVWF   TMR1L        ; Armazena 220 em TMR1L
    BSF   T1CON, TMR1ON  ; Liga o Timer1 para iniciar a contagem a partir do valor pr�-carregado

ESPERA_DELAY
    BTFSS PIR1, TMR1IF   ; Testa o flag de estouro do Timer1; se TMR1IF ainda estiver limpo (contagem n�o completou), pula a pr�xima instru��o
    GOTO  ESPERA_DELAY   ; Continua aguardando at� que TMR1IF seja setado
    DECFSZ CONT_OVERFLOW ; Decrementa o contador de ciclos; se o resultado for zero, a pr�xima instru��o � executada
    GOTO  DELAY         ; Se CONT_OVERFLOW n�o for zero, reinicia a rotina DELAY para gerar outro per�odo de ~500ms
    BSF   GPIO, GP1
    RETURN              ; Retorna da rotina DELAY
 
    
CONFIG_MEDIA
    MOVLW   D'32'
    MOVWF   CONT_AUX       ; Inicializa o contador para 32 convers�es
    CLRF    SOMA_BAIXA     ; Zera o acumulador (parte baixa)
    CLRF    SOMA_ALTA      ; Zera o acumulador (parte alta)
    
CALCULO_MEDIA
    BSF     ADCON0, GO     ; Inicia a convers�o do ADC

ESPERA
    BTFSC   ADCON0, GO     ; Enquanto o ADC estiver convertendo
    GOTO    ESPERA         ; permanece aguardando
    MOVFW    ADRESH     ; Move o resultado (ADRESH) para W
    ADDWF   SOMA_BAIXA  ; Acumula o valor em SOMA_BAIXA
    BTFSC   STATUS, C      ; Se houve carry na soma
    INCF    SOMA_ALTA    ; incrementa a parte alta do acumulador
    DECFSZ  CONT_AUX   ; Decrementa o contador de convers�es
    GOTO    CALCULO_MEDIA      ; Se ainda faltam convers�es  inicia nova convers�o

    ; Ao final de 32 convers�es, o acumulador SOMA_ALTA:SOMA_BAIXA cont�m a soma.
    ; Para obter a m�dia, divide-se por 32 (deslocando 5 vezes � direita).
    MOVLW   D'5'
    MOVWF   CONT_DESLOC    ; Prepara o contador para 5 deslocamentos
    CALL DESLOCA_5	   ; chama fun��o para dividir por 32
    CALL LIMITA_420	   ; chama a fun��o para checar se a altitude passou de 420
    MOVLW .1
    SUBWF AUX_LOOP ; variavel para ajudar a saber qual itera��o do loop esta ocorrendo
    BTFSC STATUS, Z ; se ao fazer aux - 1 = 0, quer dizer que estou  executando calcular media pela primeira vez
    GOTO INICIA	    ; checa se o valor � maior ou igual a 10m
    CLRF AUX_LOOP; limpando aux loop para evitar o salto incorreto na situa��o hipotetica em que 255 valores de media (MENOR QUE A ATUAL) sejam inseridos.
    RETURN
    
    
GRAVA_VALOR_APOGEU
    MOVFW   MAIOR_VALOR    ; Move o valor m�ximo (apogeu) armazenado em MAIOR_VALOR para o registrador W.
    MOVWF   DADO           ; Armazena esse valor em DADO, que � a vari�vel a ser gravada na EEPROM.
    MOVLW   0x13           ; Carrega o literal 0x13 (endere�o 13h) em W  este ser� o endere�o de destino na EEPROM.
    CALL    GRAVA_EEPROM   ; Chama a rotina de grava��o na EEPROM, que utiliza o endere�o (0x13) e o dado (DADO).
    GOTO    DELAY_5S       ; Ap�s a grava��o, redireciona o fluxo para a rotina DELAY_5S

 
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                     INICIO DO PROGRAMA                          *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
	
INICIO
	BANK1				;ALTERA PARA O BANCO 1
	MOVLW	B'00000101' ;CONFIGURA TODAS AS PORTAS DO GPIO (PINOS)
	MOVWF	TRISIO	;COMO SA�DAS
	MOVLW   B'00010100'
	MOVWF	ANSEL 	;DEFINE PORTAS COMO Digital I/O
	MOVLW	B'00000000'
	MOVWF	OPTION_REG	;DEFINE OP��ES DE OPERA��O
	MOVLW	B'00000001'
	MOVWF	WPU
	MOVLW	B'00000000'
	MOVWF	INTCON		;DEFINE OP��ES DE INTERRUP��ES
	BANK0				;RETORNA PARA O BANCO
	MOVLW	B'00000111'
	MOVWF	CMCON		;DEFINE O MODO DE OPERA��O DO COMPARADOR ANAL�GICO
	MOVLW	B'00001001'
	MOVWF	ADCON0
	MOVLW	B'00110000'
	MOVWF	T1CON



;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                     INICIALIZA��O DAS VARI�VEIS                 *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

	    
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                     ROTINA PRINCIPAL                            *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
MAIN  
    MOVLW .1
    MOVWF AUX_LOOP ; variavel para auxiliar a identificar se est� no primeiro loop
    
    BTFSS   GPIO, GP0      ; Se GP0 estiver em n�vel HIGH 
    GOTO    CONFIG_MEDIA     ; Se GP0 estiver em LOW inicia a convers�o
    GOTO    MAIN           ; Caso contr�rio, permanece na MAIN

INICIA
    MOVLW   D'5'          ; Carrega o limiar (5) em W (correspondente a 10 m)
    SUBWF   SOMA_BAIXA, W   ; Calcula: SOMA_BAIXA - 5; o resultado � colocado em W
                          ; Se SOMA_BAIXA < 5 (Carry = 0)
                          ; Se SOMA_BAIXA >= 5 (Carry = 1)
    BTFSS   STATUS, C      ; Se Carry estiver setado (ou seja, m�dia >= 5)
    GOTO    MAIN      ; Se Carry estiver limpo (m�dia < 5), continua novas medi��es
    GOTO    APOGEU         ; Se Carry setado, a m�dia atingiu (ou ultrapassou) o limiar; vai para APOGEU

					;Supondo que a rotina de m�dia j� foi chamada na fase inicial e que SOMA_BAIXA cont�m
					;a primeira m�dia que ultrapassou o limiar, vamos copiar esse valor para MAIOR_VALOR.
APOGEU
    MOVFW    SOMA_BAIXA   ; Primeiro valor m�dio
    MOVWF    MAIOR_VALOR           ; Inicializa MAIOR_VALOR com esse valor

LOOP_DO_APOGEU
       ; Chama a rotina que calcula a m�dia de 32 convers�es, resultando em um novo valor m�dio armazenado em SOMA_BAIXA.
    CALL    CONFIG_MEDIA      ; CONFIG_MEDIA: rotina que realiza 32 convers�es e deixa a m�dia em SOMA_BAIXA

    ; Compara o novo valor m�dio (SOMA_BAIXA) com o valor m�ximo atual (MAIOR_VALOR).
    MOVFW   MAIOR_VALOR       ; Copia o valor m�ximo atual (MAIOR_VALOR) para o W 
    SUBWF   SOMA_BAIXA, W    ; Subtrai SOMA_BAIXA (novo valor m�dio) de W:
                             ; Se o novo valor for maior que o m�ximo atual (Carry = 1)
                             ; Se o novo valor for menor ou igual (Carry = 0)
    BTFSS   STATUS, C			    ; Testa o bit Carry:
					    ;  Se Carry est� setado (C = O), isso significa que MAIOR_VALOR (o valor anterior) �
					    ;   maior que novo valor m�dio (SOMA_BAIXA), ou seja, a altitude caiu.
    GOTO    GRAVA_VALOR_APOGEU		    ; Se o Carry est� setado, indica que a altitude aumentou (novo valor maior) ou seja, o foguete ainda est� subindo.

    MOVFW   SOMA_BAIXA       ; Copia o novo valor m�dio (SOMA_BAIXA) para W
    MOVWF   MAIOR_VALOR      ; Atualiza a vari�vel MAIOR_VALOR com o novo valor (o foguete atingiu uma altitude maior)
    GOTO    LOOP_DO_APOGEU   ; Volta para o loop de medi��o de altitude (continua a verificar novos valores)
    
FIM
	GOTO FIM
 
 END