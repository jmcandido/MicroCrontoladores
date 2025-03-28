;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*              MODIFICAÇÕES PARA USO COM 12F675                   *
;*                FEITAS PELO PROF. MARDSON                        *
;*                     Março DE 2025                              *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                       NOME DO PROJETO                           *
;*                           CLIENTE                               *
;*         DESENVOLVIDO PELA MOSAICO ENGENHARIA E CONSULTORIA      *
;*   VERSÃO: 1.0                           DATA: 17/06/03          *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                     DESCRIÇÃO DO ARQUIVO                        *
;*-----------------------------------------------------------------*
;*   MODELO PARA O PIC 12F675                                      *
;*                                                                 *
;*                                                                 *
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
		DADO		;ARMAZENA O DADO PARA A EEPROM
		SOMA_BAIXA
		SOMA_ALTA
		CONT_AUX
		CONT_DESLOC
		CONT_OVERFLOW
		MAIOR_VALOR
		AUX_LOOP
		;NOVAS VARIÁVEIS

	ENDC			;FIM DO BLOCO DE MEMÓRIA
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                        FLAGS INTERNOS                           *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; DEFINIÇÃO DE TODOS OS FLAGS UTILIZADOS PELO SISTEMA

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                         CONSTANTES                              *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
; DEFINIÇÃO DE TODAS AS CONSTANTES UTILIZADAS PELO SISTEMA
; INICIALIZAÇÃO DA EEPROM, DE ACORDO COM A DESCRIÇÃO NO ARQUIVO "Def_Rega_Formigas.inc"

;A PARTIR DO ENDEREÇO ZERO DA EEPROM, DADOS EM ORDEM ALEATÓRIA
	ORG 0x2100
	DE	0X89,0X1E,0X39,0X9F,0XC2,0X0C,0XAB,0X33,0X63,0XD3,0X95,0X7B,0X38,0XD6,0X1E,0X48
	DE	0XDB,0XD8,0X86,0XFD,0XA5,0XFC,0X0C,0XBE,0X68,0X9B,0XD9,0X10,0XD8,0XEC,0X90,0X91
	DE	0XAA,0XBB,0XCC,0XDD,0XEE,0XF1,0XC9,0X77

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
LE_EEPROM
;LER DADO DA EEPROM, CUJO ENDEREÇO É INDICADO EM W
;O DADO LIDO RETORNA EM W
	ANDLW	.127		;LIMITA ENDEREÇO MAX. 127
	BANK1				;ACESSO VIA BANK 1
	MOVWF	EEADR		;INDICA O END. DE LEITURA
	BSF		EECON1,RD	;INICIA O PROCESSO DE LEITURA
	MOVF	EEDATA,W	;COLOCA DADO LIDO EM W
	BANK0				;POSICIONA PARA BANK 0
	RETURN

GRAVA_EEPROM
;ESCREVE UM DADO NA EEPROM, CUJO ENDEREÇO É INDICADO EM W
;O DADO A SER ESCRITO DEVE ESTAR ARMAZENADO NA VARIÁVEL DADO
	ANDLW	.127		;LIMITA ENDEREÇO MAX. 127
	BANK1				;ACESSO VIA BANK 1
	MOVWF	EEADR
	MOVF	DADO,W
	MOVWF	EEDATA
	BSF		EECON1,WREN ;HABILITA ESCRITA
	BCF		INTCON,GIE	;DESLIGA INTERRUPÇÕES
	MOVLW	B'01010101'	;DESBLOQUEIA ESCRITA
	MOVWF	EECON2		;
	MOVLW	B'10101010'	;DESBLOQUEIA ESCRITA
	MOVWF	EECON2		;
	BSF		EECON1,WR ;INICIA A ESCRITA
AGUARDA
	BTFSC	EECON1,WR ;TERMINOU?
	GOTO	AGUARDA
	BSF		INTCON,GIE ;HABILITA INTERRUPÇÕES
	BANK0				;POSICIONA PARA BANK 0
	RETURN
	

SETA_420
	MOVLW   D'215'	    ; Limita a 420m 
	MOVWF	SOMA_BAIXA
	RETURN

DESLOCA_5
	 RRF     SOMA_ALTA   ; Rotaciona à direita a parte alta (através do Carry)
	 RRF     SOMA_BAIXA   ; Rotaciona à direita a parte baixa
	 DECFSZ  CONT_DESLOC  ; Repete 5 vezes
	 GOTO    DESLOCA_5
	 RETURN

LIMITA_420
	MOVLW   D'215'         ; Carrega o valor 215 em W (valor máximo correspondente a 420 m)
	SUBWF   SOMA_BAIXA, W  ; Calcula: SOMA_BAIXA - 215; se SOMA_BAIXA < 215 ocorrerá
	BTFSC   STATUS, C       ; Se Carry estiver setado, significa que SOMA_BAIXA >= 215
	CALL	SETA_420
	RETURN
	
DELAY_5S
    MOVLW   .10           ; Carrega o literal 10 em W. Esse valor representa o número de ciclos de delay (cada um de ~500ms) para totalizar 5 segundos (10 x 500ms = 5s)
    MOVWF   CONT_OVERFLOW ; Armazena 10 no contador de overflow, que controla quantas vezes a rotina DELAY deve ser executada
    CALL    DELAY         ; Chama a rotina DELAY, que gera um atraso de  5s.
    BSF     GPIO, GP1     ; Após o delay de 5s, seta o pino GP1 em nível HIGH


ABRE_PARAQUEDAS
    MOVLW   .4            ; Carrega o literal 4 em W. Este valor indica que serão executados 4 ciclos de delay (4 x 500ms = 2s)
    MOVWF   CONT_OVERFLOW ; Armazena 4 no contador de overflow
    CALL    DELAY         ; Chama a rotina DELAY, que gera um atraso de 2s
    BCF     GPIO, GP1     ; Após o delay de 2s, limpa GP1
    GOTO    FIM           ; Encerra a execução 

	
DELAY
    BCF   PIR1, TMR1IF   ; Limpa o flag de overflow do Timer1 para garantir que não há um overflow pendente
    MOVLW   .11          ; Carrega o valor 11 em W para a pré-carga do byte alto do Timer1
    MOVWF   TMR1H        ; Armazena 11 em TMR1H
    MOVLW   .220         ; Carrega o valor 220 em W para a pré-carga do byte baixo do Timer1
    MOVWF   TMR1L        ; Armazena 220 em TMR1L
    BSF   T1CON, TMR1ON  ; Liga o Timer1 para iniciar a contagem a partir do valor pré-carregado

ESPERA_DELAY
    BTFSS PIR1, TMR1IF   ; Testa o flag de estouro do Timer1; se TMR1IF ainda estiver limpo (contagem não completou), pula a próxima instrução
    GOTO  ESPERA_DELAY   ; Continua aguardando até que TMR1IF seja setado
    DECFSZ CONT_OVERFLOW ; Decrementa o contador de ciclos; se o resultado for zero, a próxima instrução é executada
    GOTO  DELAY         ; Se CONT_OVERFLOW não for zero, reinicia a rotina DELAY para gerar outro período de ~500ms
    BSF   GPIO, GP1
    RETURN              ; Retorna da rotina DELAY
 
    
CONFIG_MEDIA
    MOVLW   D'32'
    MOVWF   CONT_AUX       ; Inicializa o contador para 32 conversões
    CLRF    SOMA_BAIXA     ; Zera o acumulador (parte baixa)
    CLRF    SOMA_ALTA      ; Zera o acumulador (parte alta)
    
CALCULO_MEDIA
    BSF     ADCON0, GO     ; Inicia a conversão do ADC

ESPERA
    BTFSC   ADCON0, GO     ; Enquanto o ADC estiver convertendo
    GOTO    ESPERA         ; permanece aguardando
    MOVFW    ADRESH     ; Move o resultado (ADRESH) para W
    ADDWF   SOMA_BAIXA  ; Acumula o valor em SOMA_BAIXA
    BTFSC   STATUS, C      ; Se houve carry na soma
    INCF    SOMA_ALTA    ; incrementa a parte alta do acumulador
    DECFSZ  CONT_AUX   ; Decrementa o contador de conversões
    GOTO    CALCULO_MEDIA      ; Se ainda faltam conversões  inicia nova conversão

    ; Ao final de 32 conversões, o acumulador SOMA_ALTA:SOMA_BAIXA contém a soma.
    ; Para obter a média, divide-se por 32 (deslocando 5 vezes à direita).
    MOVLW   D'5'
    MOVWF   CONT_DESLOC    ; Prepara o contador para 5 deslocamentos
    CALL DESLOCA_5	   ; chama função para dividir por 32
    CALL LIMITA_420	   ; chama a função para checar se a altitude passou de 420
    MOVLW .1
    SUBWF AUX_LOOP ; variavel para ajudar a saber qual iteração do loop esta ocorrendo
    BTFSC STATUS, Z ; se ao fazer aux - 1 = 0, quer dizer que estou  executando calcular media pela primeira vez
    GOTO INICIA	    ; checa se o valor é maior ou igual a 10m
    CLRF AUX_LOOP; limpando aux loop para evitar o salto incorreto na situação hipotetica em que 255 valores de media (MENOR QUE A ATUAL) sejam inseridos.
    RETURN
    
    
GRAVA_VALOR_APOGEU
    MOVFW   MAIOR_VALOR    ; Move o valor máximo (apogeu) armazenado em MAIOR_VALOR para o registrador W.
    MOVWF   DADO           ; Armazena esse valor em DADO, que é a variável a ser gravada na EEPROM.
    MOVLW   0x13           ; Carrega o literal 0x13 (endereço 13h) em W  este será o endereço de destino na EEPROM.
    CALL    GRAVA_EEPROM   ; Chama a rotina de gravação na EEPROM, que utiliza o endereço (0x13) e o dado (DADO).
    GOTO    DELAY_5S       ; Após a gravação, redireciona o fluxo para a rotina DELAY_5S

 
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                     INICIO DO PROGRAMA                          *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
	
INICIO
	BANK1				;ALTERA PARA O BANCO 1
	MOVLW	B'00000101' ;CONFIGURA TODAS AS PORTAS DO GPIO (PINOS)
	MOVWF	TRISIO	;COMO SAÍDAS
	MOVLW   B'00010100'
	MOVWF	ANSEL 	;DEFINE PORTAS COMO Digital I/O
	MOVLW	B'00000000'
	MOVWF	OPTION_REG	;DEFINE OPÇÕES DE OPERAÇÃO
	MOVLW	B'00000001'
	MOVWF	WPU
	MOVLW	B'00000000'
	MOVWF	INTCON		;DEFINE OPÇÕES DE INTERRUPÇÕES
	BANK0				;RETORNA PARA O BANCO
	MOVLW	B'00000111'
	MOVWF	CMCON		;DEFINE O MODO DE OPERAÇÃO DO COMPARADOR ANALÓGICO
	MOVLW	B'00001001'
	MOVWF	ADCON0
	MOVLW	B'00110000'
	MOVWF	T1CON



;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                     INICIALIZAÇÃO DAS VARIÁVEIS                 *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

	    
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;*                     ROTINA PRINCIPAL                            *
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
MAIN  
    MOVLW .1
    MOVWF AUX_LOOP ; variavel para auxiliar a identificar se está no primeiro loop
    
    BTFSS   GPIO, GP0      ; Se GP0 estiver em nível HIGH 
    GOTO    CONFIG_MEDIA     ; Se GP0 estiver em LOW inicia a conversão
    GOTO    MAIN           ; Caso contrário, permanece na MAIN

INICIA
    MOVLW   D'5'          ; Carrega o limiar (5) em W (correspondente a 10 m)
    SUBWF   SOMA_BAIXA, W   ; Calcula: SOMA_BAIXA - 5; o resultado é colocado em W
                          ; Se SOMA_BAIXA < 5 (Carry = 0)
                          ; Se SOMA_BAIXA >= 5 (Carry = 1)
    BTFSS   STATUS, C      ; Se Carry estiver setado (ou seja, média >= 5)
    GOTO    MAIN      ; Se Carry estiver limpo (média < 5), continua novas medições
    GOTO    APOGEU         ; Se Carry setado, a média atingiu (ou ultrapassou) o limiar; vai para APOGEU

					;Supondo que a rotina de média já foi chamada na fase inicial e que SOMA_BAIXA contém
					;a primeira média que ultrapassou o limiar, vamos copiar esse valor para MAIOR_VALOR.
APOGEU
    MOVFW    SOMA_BAIXA   ; Primeiro valor médio
    MOVWF    MAIOR_VALOR           ; Inicializa MAIOR_VALOR com esse valor

LOOP_DO_APOGEU
       ; Chama a rotina que calcula a média de 32 conversões, resultando em um novo valor médio armazenado em SOMA_BAIXA.
    CALL    CONFIG_MEDIA      ; CONFIG_MEDIA: rotina que realiza 32 conversões e deixa a média em SOMA_BAIXA

    ; Compara o novo valor médio (SOMA_BAIXA) com o valor máximo atual (MAIOR_VALOR).
    MOVFW   MAIOR_VALOR       ; Copia o valor máximo atual (MAIOR_VALOR) para o W 
    SUBWF   SOMA_BAIXA, W    ; Subtrai SOMA_BAIXA (novo valor médio) de W:
                             ; Se o novo valor for maior que o máximo atual (Carry = 1)
                             ; Se o novo valor for menor ou igual (Carry = 0)
    BTFSS   STATUS, C			    ; Testa o bit Carry:
					    ;  Se Carry está setado (C = O), isso significa que MAIOR_VALOR (o valor anterior) é
					    ;   maior que novo valor médio (SOMA_BAIXA), ou seja, a altitude caiu.
    GOTO    GRAVA_VALOR_APOGEU		    ; Se o Carry está setado, indica que a altitude aumentou (novo valor maior) ou seja, o foguete ainda está subindo.

    MOVFW   SOMA_BAIXA       ; Copia o novo valor médio (SOMA_BAIXA) para W
    MOVWF   MAIOR_VALOR      ; Atualiza a variável MAIOR_VALOR com o novo valor (o foguete atingiu uma altitude maior)
    GOTO    LOOP_DO_APOGEU   ; Volta para o loop de medição de altitude (continua a verificar novos valores)
    
FIM
	GOTO FIM
 
 END