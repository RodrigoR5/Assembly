###########SUMARIO##################
# $s0=	largura da matriz  	   #
# $s1=	largura*altura	   	   #
# $s2= endereço de 'Campo'   	   #
# $s3= endereço de 'guardaT'       #
# $s4= endereço de 'CampoMostrado' #		  
####################################

	.data
##Matriz##
campo:	.space	324	#81*4
campoMostrado:	.space	324	#81*4
guardaT: .space 36      #9*4
##Strings##
st_pedeTamanho:	.asciiz	"######COMEÇO DO PROGRAMA######\n Escolha o tamanho do campo!\n 5)5x5\n 7)7x7\n 9)9x9\n"			 	
st_pulaLinha: .asciiz "\n"
st_valorInvalido: .asciiz "O valor digitado é invalido, tente novamente\n"
st_pedeCampo: .asciiz "Escolha um campo\n"
st_pedeLinha: .asciiz "Digite o numero da linha\n"
st_pedeColuna: .asciiz "Digite o numero da coluna\n"
st_perdeu: .asciiz "Você perdeu o jogo!"
st_ganhou: .asciiz "Você ganhou o jogo!!!!"
st_opcaoNaoExiste: .asciiz "A opção escolhida não existe, tente novamente\n"
st_espaco: .asciiz " "
st_x: .asciiz "x"


	.text
main:
	la $s2, campo
	la $s3, guardaT
	la $s4, campoMostrado
##########Adiciona 0 para todos os espaços do vetor "Campo"###########
	move $t0, $s2
	move $t3, $s4
	li $t1, 0
	li $t2, 81
	li $t4, -1
zeraMatriz:
	beq $t1, $t2, fimZeraMatriz
	sw $0,($t0)
	sw $t4($t3)
	addi $t0, $t0, 4	#define o endereço do proximo campo
	addi $t3, $t3, 4	#define o endereço do proximo campoMostrado
	addi $t1, $t1, 1	#i++
	j zeraMatriz
fimZeraMatriz:

##########Pede tamanho##########
pedeTamanho:	
	la $a0, st_pedeTamanho #Printa o pedido de tamanho da matriz
	li $v0, 4
	syscall
	
	li $v0, 5	#Lê o tamanho da matriz
	syscall

	##guarda em $s0 a largura da matriz e em $s1 a largura*altura#
	move $s0,$v0
	li $t3, 5	
	bne $t3,$s0,naoEh5x5
	li $s1,25
	j fimDoCalculaTamanho
naoEh5x5:
	li $t3, 7
	bne $t3,$s0,naoEh7x7
	li $s1,49
	j fimDoCalculaTamanho
naoEh7x7:
	li $t3, 9
	bne $t3,$s0,naoEh9x9
	li $s1,81
	j fimDoCalculaTamanho
naoEh9x9:
	##Se está aqui, não é 7x7 nem 5x5 nem 9x9
	la $a0, st_valorInvalido #Printa o pedido de tamanho da matriz
	li $v0, 4
	syscall
	j pedeTamanho
fimDoCalculaTamanho:
######Adiciona Bombas#########
#Vai ser implementada pelo professor, isso é só uma simulação
	li $t0,9
	sw $t0,4($s2)
	sw $t0,8($s2)
	sw $t0,32($s2)

##########Calcula Bombas##########
	move $a0,$s2
	move $a1,$s0
	jal calculaBombas

#########Começa o jogo############	
escolheCampo:
	move $a0,$s0        		
	move $a1,$s1        
	move $a2,$s4  
	jal fcPrintaMatriz
	
	li $t4,4
	la $a0,st_pedeCampo #Pede p/ preencher os campos
	li $v0,4
	syscall
	la $a0,st_pedeLinha #Pede a linha
	li $v0,4
	syscall
	li $v0,5 #Lê a linha
	syscall
	move $t0, $v0 #$t0 guarda a linha
	addi $t0, $t0,-1
	la $a0,st_pedeColuna #Pede a coluna
	li $v0,4
	syscall
	li $v0,5 #Lê a coluna
	syscall
	move $t1,$v0 #$t1 guarda a coluna
	addi $t1,$t1, -1
 	##Transforma o numero informado em um da matriz##
 	mult $t1,$t4 #coluna*4
	mflo $t1 #Coloca linha*coluna no registrador $t1
	mult $t0,$t4 #coluna*4
	mflo $t0 #Coloca coluna*4 no registrador $t0
	mult $t0,$s0 #(coluna*4)*elementos numa linha
	mflo $t0
	add $t2, $t1, $t0
	##Calcula o que vai mostrar para o usuário##
	move $a0,$s2
	move $a1,$s4
	move $a2,$t2
	jal alteraCampoMostrado
	move $t9, $v0
	
calculaSePerdeu:	
	##Vê se o jogo foi perdido, ganho ou se ainda não acabou##
	li $t5,0
	bne $t5,$v0,naoPerdeuOJogo
	move $a0,$s0        		
	move $a1,$s1        
	move $a2,$s2  
	jal fcPrintaMatriz
	la $a0,st_perdeu #Avisa que perdeu
	li $v0,4
	syscall
	j fim
naoPerdeuOJogo:
	###Verifica se o jogo terminou### 
	move $t0, $s2
	move $t3, $s4
	li $t1, 0
	li $t2, 81
	li $t4, -1
verificaSeTerminou:
	beq $t1, $t2, fimVerificaSeTerminou
	lw $t4,($t0)
	lw $t5,($t3)
	li $t6,9
	beq $t4,$t6,pulaVerificacao 
	li $t6,-1
	bne $t5,$t6,pulaVerificacao
	#Então o jogo ainda não foi vencido#
	j escolheCampo
pulaVerificacao:
	addi $t0, $t0, 4	#define o endereço do proximo campo
	addi $t3, $t3, 4	#define o endereço do proximo campoMostrado
	addi $t1, $t1, 1	#i++
	j verificaSeTerminou
fimVerificaSeTerminou:
	move $a0,$s0        		
	move $a1,$s1        
	move $a2,$s2  
	jal fcPrintaMatriz
	la $a0, st_ganhou #Printa o pedido de tamanho da matriz
	li $v0, 4
	syscall
	j fim
	
##FIM DA MAIN##

#############FUNÇÕES########################################
	
##########Função Altera campoMostrado##############
############Parametros##################
#$a0= endereço de 'campo'	       #	
#$a1= endereço de 'campoMostrado'      #
#$a2= endereço escolhido pelo usuario  #
#Retornos: 			       #
#$v0 = 0 = jogador perdeu o jogo       #
#$v1 = 1 = jogador não perdeu o jogo   #     
########################################
alteraCampoMostrado:
	move $t0,$a0
	move $t1,$a1
	move $t2,$a2
	add $t0,$t0,$t2
	add $t1,$t1,$t2
	lw $t3,0($t0)#Lê o campo da matriz 'Campo'
	sw $t3,0($t1)#Passa o campo lido para a matriz 'CampoMostrado'
	li $t4, 9
	bne $t3,$t4,naoPerdeu
	li $v0, 0
	j fimAlteraCampoMostrado
naoPerdeu:
	li $v0, 1
fimAlteraCampoMostrado:
	jr $ra
		
##########Função Calcula Bombas########## 		
calculaBombas:
############Parametros############
#$a0= endereço de 'campo'	 #	
#$a1= numero de linhas da matriz #
##################################
	move $t5,$ra #guarda o $ra pois usaremos uma função dentro de outra
	move $t0,$a0 #vai ser alterado
	move $t1,$a1 #vai ser alterado
	move $t6,$a1 #não vai ser alterado
	mult $t1,$t1 #multiplica linha*coluna
	mflo $t2 #coloca linha*coluna no registrador $t2
	li $t3,0 # i
	li $t4,5
	beq $t4,$t1,calculaNovoCampo5x5
	li $t4,7	
	beq $t4,$t1,calculaNovoCampo7x7
	li $t4,9
	beq $t4,$t1,calculaNovoCampo9x9
calculaNovoCampo5x5:
	lw $t7,0($t0)
	beq $t7,9,pulaSeForBomba5x5#caso seja bomba, nada deve ser alterado, já pula para o fim do looping	
	beq $t3,$t2,fimDoCalculaBombas
	li $t7, 0
	bne $t3,$t7,naoEhEsseTipo5x5.1 
	li $t8,1 #t8 guarda o tipo do campo
	j fimDoLooping5x5
naoEhEsseTipo5x5.1:
	li $t7, 4
	bne $t3,$t7,naoEhEsseTipo5x5.2 
	li $t8,3 #t8 guarda o tipo do campo
	j fimDoLooping5x5
naoEhEsseTipo5x5.2:
	li $t7, 5
	bge $t3,$t7,naoEhEsseTipo5x5.3 
	li $t8,2 #t8 guarda o tipo do campo
	j fimDoLooping5x5
naoEhEsseTipo5x5.3:
	li $t7, 5
	bne $t3,$t7,naoEhEsseTipo5x5.4 
	li $t8,4 #t8 guarda o tipo do campo
	j fimDoLooping5x5
naoEhEsseTipo5x5.4:
	li $t7, 10
	bne $t3,$t7,naoEhEsseTipo5x5.5
	li $t8,4 #t8 guarda o tipo do campo
	j fimDoLooping5x5
naoEhEsseTipo5x5.5:
	li $t7, 15
	bne $t3,$t7,naoEhEsseTipo5x5.6 
	li $t8,4 #t8 guarda o tipo do campo
	j fimDoLooping5x5
naoEhEsseTipo5x5.6:
	li $t7, 9
	bne $t3,$t7,naoEhEsseTipo5x5.7
	li $t8,5 #t8 guarda o tipo do campo
	j fimDoLooping5x5
naoEhEsseTipo5x5.7:
	li $t7, 14
	bne $t3,$t7,naoEhEsseTipo5x5.8
	li $t8,5 #t8 guarda o tipo do campo
	j fimDoLooping5x5
naoEhEsseTipo5x5.8:
	li $t7, 19
	bne $t3,$t7,naoEhEsseTipo5x5.9
	li $t8,5 #t8 guarda o tipo do campo
	j fimDoLooping5x5
naoEhEsseTipo5x5.9:
	li $t7, 20
	bne $t3,$t7,naoEhEsseTipo5x5.10
	li $t8,6 #t8 guarda o tipo do campo
	j fimDoLooping5x5
naoEhEsseTipo5x5.10:
	li $t7, 24
	bne $t3,$t7,naoEhEsseTipo5x5.11
	li $t8,8 #t8 guarda o tipo do campo
	j fimDoLooping5x5
naoEhEsseTipo5x5.11:
	li $t7,20
	blt $t3,$t7,naoEhEsseTipo5x5.12
	li $t8,7 #t8 guarda o tipo do campo
	j fimDoLooping5x5
naoEhEsseTipo5x5.12:
	li $t8,0
fimDoLooping5x5:
####Guarda as variaveis usadas nessa função pois serão sobrescritas pela próxima####
	sw $t0,0($s3)
	sw $t1,4($s3)
	sw $t2,8($s3)
	sw $t3,12($s3)
	sw $t4,16($s3)
	sw $t5,20($s3)
	sw $t6,24($s3)
	sw $t7,28($s3)
	sw $t8,32($s3)
	sw $t9,36($s3)
###Fim do guarda as variaveis da função###
	move $a0,$t8
	move $a1,$t0
	move $a2,$t6
	jal calculaUmCampo
##Recebe de volta os valores dos registradores dessa função##
	lw $t0,0($s3)
	lw $t1,4($s3)
	lw $t2,8($s3)
	lw $t3,12($s3)
	lw $t4,16($s3)
	lw $t5,20($s3)
	lw $t6,24($s3)
	lw $t7,28($s3)
	lw $t8,32($s3)
	lw $t9,36($s3)
###Fim do recebe de volta as variaveis da função###
	move $t9,$v0
	sw $t9,0($t0)
pulaSeForBomba5x5:
	addi $t0,$t0,4
	addi $t3,$t3,1 #i++
	j calculaNovoCampo5x5


calculaNovoCampo7x7:	
	lw $t7,0($t0)
	beq $t7,9,pulaSeForBomba7x7#caso seja bomba, nada deve ser alterado, já pula para o fim do looping	
	beq $t3,$t2,fimDoCalculaBombas
	li $t7, 0
	bne $t3,$t7,naoEhEsseTipo7x7.1 
	li $t8,1 #t8 guarda o tipo do campo
	j fimDoLooping7x7
naoEhEsseTipo7x7.1:
	li $t7,6
	bne $t3,$t7,naoEhEsseTipo7x7.2 
	li $t8,3 #t8 guarda o tipo do campo
	j fimDoLooping7x7
naoEhEsseTipo7x7.2:
	li $t7,6
	bge $t3,$t7,naoEhEsseTipo7x7.3 
	li $t8,2 #t8 guarda o tipo do campo
	j fimDoLooping7x7
naoEhEsseTipo7x7.3:
	li $t7, 7
	bne $t3,$t7,naoEhEsseTipo7x7.4 
	li $t8,4 #t8 guarda o tipo do campo
	j fimDoLooping7x7
naoEhEsseTipo7x7.4:
	li $t7, 14
	bne $t3,$t7,naoEhEsseTipo7x7.5
	li $t8,4 #t8 guarda o tipo do campo
	j fimDoLooping7x7
naoEhEsseTipo7x7.5:
	li $t7, 21
	bne $t3,$t7,naoEhEsseTipo7x7.6 
	li $t8,4 #t8 guarda o tipo do campo
	j fimDoLooping7x7
naoEhEsseTipo7x7.6:
	li $t7, 28
	bne $t3,$t7,naoEhEsseTipo7x7.7 
	li $t8,4 #t8 guarda o tipo do campo
	j fimDoLooping7x7
naoEhEsseTipo7x7.7:
	li $t7, 35
	bne $t3,$t7,naoEhEsseTipo7x7.8 
	li $t8,4 #t8 guarda o tipo do campo
	j fimDoLooping7x7
naoEhEsseTipo7x7.8:
	li $t7, 13
	bne $t3,$t7,naoEhEsseTipo7x7.9
	li $t8,5 #t8 guarda o tipo do campo
	j fimDoLooping7x7
naoEhEsseTipo7x7.9:
	li $t7, 20
	bne $t3,$t7,naoEhEsseTipo7x7.10
	li $t8,5 #t8 guarda o tipo do campo
	j fimDoLooping7x7
naoEhEsseTipo7x7.10:
	li $t7, 27
	bne $t3,$t7,naoEhEsseTipo7x7.11
	li $t8,5 #t8 guarda o tipo do campo
	j fimDoLooping7x7
naoEhEsseTipo7x7.11:
	li $t7, 34
	bne $t3,$t7,naoEhEsseTipo7x7.12
	li $t8,5 #t8 guarda o tipo do campo
	j fimDoLooping7x7
naoEhEsseTipo7x7.12:
	li $t7,41
	bne $t3,$t7,naoEhEsseTipo7x7.13
	li $t8,5 #t8 guarda o tipo do campo
	j fimDoLooping7x7
naoEhEsseTipo7x7.13:
	li $t7,42
	bne $t3,$t7,naoEhEsseTipo7x7.14
	li $t8,6 #t8 guarda o tipo do campo
	j fimDoLooping7x7
naoEhEsseTipo7x7.14:
	li $t7,48
	bne $t3,$t7,naoEhEsseTipo7x7.15
	li $t8,8 #t8 guarda o tipo do campo
	j fimDoLooping7x7
naoEhEsseTipo7x7.15:
	li $t7,42
	blt $t3,$t7,naoEhEsseTipo7x7.16
	li $t8,7 #t8 guarda o tipo do campo
	j fimDoLooping7x7
naoEhEsseTipo7x7.16:
	li $t8,0
fimDoLooping7x7:
####Guarda as variaveis usadas nessa função pois serão sobrescritas pela próxima####
	sw $t0,0($s3)
	sw $t1,4($s3)
	sw $t2,8($s3)
	sw $t3,12($s3)
	sw $t4,16($s3)
	sw $t5,20($s3)
	sw $t6,24($s3)
	sw $t7,28($s3)
	sw $t8,32($s3)
	sw $t9,36($s3)
###Fim do guarda as variaveis da função###
	move $a0,$t8
	move $a1,$t0
	move $a2,$t6
	jal calculaUmCampo
##Recebe de volta os valores dos registradores dessa função##
	lw $t0,0($s3)
	lw $t1,4($s3)
	lw $t2,8($s3)
	lw $t3,12($s3)
	lw $t4,16($s3)
	lw $t5,20($s3)
	lw $t6,24($s3)
	lw $t7,28($s3)
	lw $t8,32($s3)
	lw $t9,36($s3)
###Fim do recebe de volta as variaveis da função###
	move $t9,$v0
	sw $t9,0($t0)
pulaSeForBomba7x7:
	addi $t0,$t0,4
	addi $t3,$t3,1 #i++
	j calculaNovoCampo7x7
	
calculaNovoCampo9x9:	
	lw $t7,0($t0)
	beq $t7,9,pulaSeForBomba9x9#caso seja bomba, nada deve ser alterado, já pula para o fim do looping	
	beq $t3,$t2,fimDoCalculaBombas
	li $t7, 0
	bne $t3,$t7,naoEhEsseTipo9x9.1 
	li $t8,1 #t8 guarda o tipo do campo
	j fimDoLooping9x9
naoEhEsseTipo9x9.1:
	li $t7,8
	bne $t3,$t7,naoEhEsseTipo9x9.2 
	li $t8,3 #t8 guarda o tipo do campo
	j fimDoLooping9x9
naoEhEsseTipo9x9.2:
	li $t7,8
	bge $t3,$t7,naoEhEsseTipo9x9.3 
	li $t8,2 #t8 guarda o tipo do campo
	j fimDoLooping9x9
naoEhEsseTipo9x9.3:
	li $t7, 9
	bne $t3,$t7,naoEhEsseTipo9x9.4 
	li $t8,4 #t8 guarda o tipo do campo
	j fimDoLooping9x9
naoEhEsseTipo9x9.4:
	li $t7, 18
	bne $t3,$t7,naoEhEsseTipo9x9.5
	li $t8,4 #t8 guarda o tipo do campo
	j fimDoLooping9x9
naoEhEsseTipo9x9.5:
	li $t7, 27
	bne $t3,$t7,naoEhEsseTipo9x9.6 
	li $t8,4 #t8 guarda o tipo do campo
	j fimDoLooping9x9
naoEhEsseTipo9x9.6:
	li $t7, 36
	bne $t3,$t7,naoEhEsseTipo9x9.7 
	li $t8,4 #t8 guarda o tipo do campo
	j fimDoLooping9x9
naoEhEsseTipo9x9.7:
	li $t7, 45
	bne $t3,$t7,naoEhEsseTipo9x9.8 
	li $t8,4 #t8 guarda o tipo do campo
	j fimDoLooping9x9
naoEhEsseTipo9x9.8:
	li $t7, 54
	bne $t3,$t7,naoEhEsseTipo9x9.9 
	li $t8,4 #t8 guarda o tipo do campo
	j fimDoLooping9x9
naoEhEsseTipo9x9.9:
	li $t7, 63
	bne $t3,$t7,naoEhEsseTipo9x9.10 
	li $t8,4 #t8 guarda o tipo do campo
	j fimDoLooping9x9
naoEhEsseTipo9x9.10:
	li $t7, 17
	bne $t3,$t7,naoEhEsseTipo9x9.11
	li $t8,5 #t8 guarda o tipo do campo
	j fimDoLooping9x9
naoEhEsseTipo9x9.11:
	li $t7, 26
	bne $t3,$t7,naoEhEsseTipo9x9.12
	li $t8,5 #t8 guarda o tipo do campo
	j fimDoLooping9x9
naoEhEsseTipo9x9.12:
	li $t7, 35
	bne $t3,$t7,naoEhEsseTipo9x9.13
	li $t8,5 #t8 guarda o tipo do campo
	j fimDoLooping9x9
naoEhEsseTipo9x9.13:
	li $t7, 44
	bne $t3,$t7,naoEhEsseTipo9x9.14
	li $t8,5 #t8 guarda o tipo do campo
	j fimDoLooping9x9
naoEhEsseTipo9x9.14:
	li $t7,53
	bne $t3,$t7,naoEhEsseTipo9x9.15
	li $t8,5 #t8 guarda o tipo do campo
	j fimDoLooping9x9
naoEhEsseTipo9x9.15:
	li $t7,62
	bne $t3,$t7,naoEhEsseTipo9x9.16
	li $t8,5 #t8 guarda o tipo do campo
	j fimDoLooping9x9
naoEhEsseTipo9x9.16:
	li $t7,71
	bne $t3,$t7,naoEhEsseTipo9x9.17
	li $t8,5 #t8 guarda o tipo do campo
	j fimDoLooping9x9
naoEhEsseTipo9x9.17:
	li $t7,72
	bne $t3,$t7,naoEhEsseTipo9x9.18
	li $t8,6 #t8 guarda o tipo do campo
	j fimDoLooping9x9
naoEhEsseTipo9x9.18:
	li $t7,80
	bne $t3,$t7,naoEhEsseTipo9x9.19
	li $t8,8 #t8 guarda o tipo do campo
	j fimDoLooping9x9
naoEhEsseTipo9x9.19:
	li $t7,72
	blt $t3,$t7,naoEhEsseTipo9x9.20
	li $t8,7 #t8 guarda o tipo do campo
	j fimDoLooping9x9
naoEhEsseTipo9x9.20:
	li $t8,0
fimDoLooping9x9:
####Guarda as variaveis usadas nessa função pois serão sobrescritas pela próxima####
	sw $t0,0($s3)
	sw $t1,4($s3)
	sw $t2,8($s3)
	sw $t3,12($s3)
	sw $t4,16($s3)
	sw $t5,20($s3)
	sw $t6,24($s3)
	sw $t7,28($s3)
	sw $t8,32($s3)
	sw $t9,36($s3)
###Fim do guarda as variaveis da função###
	move $a0,$t8
	move $a1,$t0
	move $a2,$t6
	jal calculaUmCampo
##Recebe de volta os valores dos registradores dessa função##
	lw $t0,0($s3)
	lw $t1,4($s3)
	lw $t2,8($s3)
	lw $t3,12($s3)
	lw $t4,16($s3)
	lw $t5,20($s3)
	lw $t6,24($s3)
	lw $t7,28($s3)
	lw $t8,32($s3)
	lw $t9,36($s3)
###Fim do recebe de volta as variaveis da função###
	move $t9,$v0
	sw $t9,0($t0)
pulaSeForBomba9x9:
	addi $t0,$t0,4
	addi $t3,$t3,1 #i++
	j calculaNovoCampo9x9
	
fimDoCalculaBombas:
	move $ra,$t5 
	jr $ra
	
##função de printar matriz###
########Parâmetros:##########
#	move $a0,$s0        #		
#	move $a1,$s1        #
#	move $a2,$s2        #
#	jal fcPrintaMatriz  #
#       return: void   	    #
#############################
fcPrintaMatriz: #jal FcPrintaMatriz         p/ invoca-la
	move $t0, $a2
	li $t1, 0
	move $t2, $a1
	li $t3, 0
	move $t4, $a0
	li $t5, -1
printaMatriz:
	beq $t1, $t2, fimPrintaMatriz
	lw $a0,($t0)
	bne $t5,$a0,naoEhMenos1
	la $a0, st_x
	li $v0, 4
	syscall
	j fimnaoEhMenos1
naoEhMenos1:	
	li $v0, 1	
	syscall
fimnaoEhMenos1:
	la $a0, st_espaco
	li $v0, 4	
	syscall
	addi $t0, $t0, 4	
	addi $t1, $t1, 1	
	addi $t3, $t3, 1	
	bne $t3,$t4,naoPulaLinha
	la $a0, st_pulaLinha
	li $v0, 4
	syscall
	li $t3,0
naoPulaLinha:
	j printaMatriz
fimPrintaMatriz:
	jr $ra
##Fim da função printa matriz##

calculaUmCampo:
###############################
# $a0 = tipo do campo         #
# $a1 = endereço do 'Campo'   #
# $a2 = largura da matriz     #
# Return: o valor do 'Campo'  #
###############################
	move $t6,$a1
	move $t1, $a2
	li $t2, 4 # constante 4
	li $t3, 0 # quantidadeDeBombas
	li $t5, 9 # usado para comparar se tem bomba
	
	#Valores que serão usados várias vezes#
	li $t2, 4 # constante 4
	sll $t1,$t1,2 # $a0*4
	sub $t8,$a1,$t1# endereço - ($a0*4)
	add $t7,$a1,$t1# endereço + ($a0*4)
	
	###Começo das comparações###	
	li $t0,0
	bne $a0,$t0,naoEhTipo0
	#Procura na esquerda
	sub $t4,$t6,$t2 
	lw $t4,0($t4)
	bne $t4, $t5,naoEncontrado1
	addi $t3,$t3,1 #quantidadeDeBombas+1
naoEncontrado1:
	#Procura na direita		
	add $t4,$t6,$t2
	lw $t4,0($t4)
	bne $t4, $t5,naoEncontrado2
	addi $t3,$t3,1 #quantidadeDeBombas+1
naoEncontrado2:
	#Procura em cima
	move $t4,$t8
	lw $t4,0($t4)
	bne $t4, $t5,naoEncontrado3
	addi $t3,$t3,1 #quantidadeDeBombas+1
naoEncontrado3:
	#Procura em baixo
	move $t4,$t7
	lw $t4,0($t4)
	bne $t4, $t5,naoEncontrado4
	addi $t3,$t3,1 #quantidadeDeBombas+1
naoEncontrado4:
	#Procura na diagonal superior esquerda
	sub $t4,$t8,$t2
	lw $t4,0($t4)
	bne $t4, $t5,naoEncontrado5
	addi $t3,$t3,1 #quantidadeDeBombas+1
naoEncontrado5:
	#Procura na diagonal superior direita
	add $t4,$t8,$t2
	lw $t4,0($t4)
	bne $t4, $t5,naoEncontrado6
	addi $t3,$t3,1 #quantidadeDeBombas+1
naoEncontrado6:
	#Procura na diagonal inferior esquerda
	sub $t4,$t7,$t2
	lw $t4,0($t4)
	bne $t4, $t5,naoEncontrado7
	addi $t3,$t3,1 #quantidadeDeBombas+1
naoEncontrado7:
	#Procura na diagonal inferior direita
	add $t4,$t7,$t2
	lw $t4,0($t4)
	bne $t4, $t5,fimCalculaUmCampo
	addi $t3,$t3,1 #quantidadeDeBombas+1
	j fimCalculaUmCampo
naoEhTipo0:
	li $t0,1
	bne $a0,$t0,naoEhTipo1
	#Procura na direita
	add $t4,$t6,$t2
	lw $t4,0($t4) 
	bne $t4, $t5,naoEncontrado8
	addi $t3,$t3,1 #quantidadeDeBombas+1
naoEncontrado8:
	#Procura em baixo
	move $t4,$t7
	lw $t4,0($t4)
	bne $t4, $t5,naoEncontrado9
	addi $t3,$t3,1 #quantidadeDeBombas+1
naoEncontrado9:
	#Procura na diagonal inferior direita
	add $t4,$t7,$t2
	lw $t4,0($t4)
	bne $t4, $t5,fimCalculaUmCampo
	addi $t3,$t3,1 #quantidadeDeBombas+1
	j fimCalculaUmCampo
	
naoEhTipo1:
	li $t0,2
	bne $a0,$t0,naoEhTipo2
	#Procura na esquerda
	sub $t4,$t6,$t2 
	lw $t4,0($t4)
	bne $t4, $t5,naoEncontrado10
	addi $t3,$t3,1 #quantidadeDeBombas+1
naoEncontrado10:
	#Procura na direita		
	add $t4,$t6,$t2
	lw $t4,0($t4)
	bne $t4, $t5,naoEncontrado11
	addi $t3,$t3,1 #quantidadeDeBombas+1
naoEncontrado11:
	#Procura em baixo
	move $t4,$t7
	lw $t4,0($t4)
	bne $t4, $t5,naoEncontrado12
	addi $t3,$t3,1 #quantidadeDeBombas+1
naoEncontrado12:
	#Procura na diagonal inferior esquerda
	sub $t4,$t7,$t2
	lw $t4,0($t4)
	bne $t4, $t5,naoEncontrado13
	addi $t3,$t3,1 #quantidadeDeBombas+1
naoEncontrado13:
	#Procura na diagonal inferior direita
	add $t4,$t7,$t2
	lw $t4,0($t4)
	bne $t4, $t5,fimCalculaUmCampo
	addi $t3,$t3,1 #quantidadeDeBombas+1
	j fimCalculaUmCampo
	
naoEhTipo2:
	li $t0,3
	bne $a0,$t0,naoEhTipo3
	#Procura na esquerda
	sub $t4,$t6,$t2
	lw $t4,0($t4) 
	bne $t4, $t5,naoEncontrado14
	addi $t3,$t3,1 #quantidadeDeBombas+1
naoEncontrado14:
	#Procura em baixo
	move $t4,$t7
	lw $t4,0($t4)
	bne $t4, $t5,naoEncontrado15
	addi $t3,$t3,1 #quantidadeDeBombas+1
naoEncontrado15:
	#Procura na diagonal inferior esquerda
	sub $t4,$t7,$t2
	lw $t4,0($t4)
	bne $t4, $t5,fimCalculaUmCampo
	addi $t3,$t3,1 #quantidadeDeBombas+1
	j fimCalculaUmCampo
		
naoEhTipo3:
	li $t0,4
	bne $a0,$t0,naoEhTipo4
	#Procura na direita		
	add $t4,$t6,$t2
	lw $t4,0($t4)
	bne $t4, $t5,naoEncontrado16
	addi $t3,$t3,1 #quantidadeDeBombas+1
naoEncontrado16:
	#Procura em cima
	move $t4,$t8
	lw $t4,0($t4)
	bne $t4, $t5,naoEncontrado17
	addi $t3,$t3,1 #quantidadeDeBombas+1
naoEncontrado17:
	#Procura em baixo
	move $t4,$t7
	lw $t4,0($t4)
	bne $t4, $t5,naoEncontrado18
	addi $t3,$t3,1 #quantidadeDeBombas+1
naoEncontrado18:
	#Procura na diagonal superior direita
	add $t4,$t8,$t2
	lw $t4,0($t4)
	bne $t4, $t5,naoEncontrado19
	addi $t3,$t3,1 #quantidadeDeBombas+1
naoEncontrado19:
	#Procura na diagonal inferior direita
	add $t4,$t7,$t2
	lw $t4,0($t4)
	bne $t4, $t5,fimCalculaUmCampo
	addi $t3,$t3,1 #quantidadeDeBombas+1
	j fimCalculaUmCampo
	
naoEhTipo4:
	li $t0,5
	bne $a0,$t0,naoEhTipo5
	#Procura na esquerda
	sub $t4,$t6,$t2
	lw $t4,0($t4) 
	bne $t4, $t5,naoEncontrado20
	addi $t3,$t3,1 #quantidadeDeBombas+1
naoEncontrado20:
	#Procura em cima
	move $t4,$t8
	lw $t4,0($t4)
	bne $t4, $t5,naoEncontrado21
	addi $t3,$t3,1 #quantidadeDeBombas+1
naoEncontrado21:
	#Procura em baixo
	move $t4,$t7
	lw $t4,0($t4)
	bne $t4, $t5,naoEncontrado22
	addi $t3,$t3,1 #quantidadeDeBombas+1
naoEncontrado22:
	#Procura na diagonal superior esquerda
	sub $t4,$t8,$t2
	lw $t4,0($t4)
	bne $t4, $t5,naoEncontrado23
	addi $t3,$t3,1 #quantidadeDeBombas+1
naoEncontrado23:
	#Procura na diagonal inferior esquerda
	sub $t4,$t7,$t2
	lw $t4,0($t4)
	bne $t4, $t5,fimCalculaUmCampo
	addi $t3,$t3,1 #quantidadeDeBombas+1
	j fimCalculaUmCampo
	
naoEhTipo5:
	li $t0,6
	bne $a0,$t0,naoEhTipo6
	#Procura na direita		
	add $t4,$t6,$t2
	lw $t4,0($t4)
	bne $t4, $t5,naoEncontrado24
	addi $t3,$t3,1 #quantidadeDeBombas+1
naoEncontrado24:
	#Procura em cima
	move $t4,$t8
	lw $t4,0($t4)
	bne $t4, $t5,naoEncontrado25
	addi $t3,$t3,1 #quantidadeDeBombas+1
naoEncontrado25:
	#Procura na diagonal superior direita
	add $t4,$t8,$t2
	lw $t4,0($t4)
	bne $t4, $t5,fimCalculaUmCampo
	addi $t3,$t3,1 #quantidadeDeBombas+1
	j fimCalculaUmCampo
	
naoEhTipo6:
	li $t0,7
	bne $a0,$t0,naoEhTipo7
	#Procura na esquerda
	sub $t4,$t6,$t2 
	lw $t4,0($t4)
	bne $t4, $t5,naoEncontrado26
	addi $t3,$t3,1 #quantidadeDeBombas+1
naoEncontrado26:
	#Procura na direita		
	add $t4,$t6,$t2
	lw $t4,0($t4)
	bne $t4, $t5,naoEncontrado27
	addi $t3,$t3,1 #quantidadeDeBombas+1
naoEncontrado27:
	#Procura em cima
	move $t4,$t8
	lw $t4,0($t4)
	bne $t4, $t5,naoEncontrado28
	addi $t3,$t3,1 #quantidadeDeBombas+1
naoEncontrado28:
	#Procura na diagonal superior esquerda
	sub $t4,$t8,$t2
	lw $t4,0($t4)
	bne $t4, $t5,naoEncontrado29
	addi $t3,$t3,1 #quantidadeDeBombas+1
naoEncontrado29:
	#Procura na diagonal superior direita
	add $t4,$t8,$t2
	lw $t4,0($t4)
	bne $t4, $t5,fimCalculaUmCampo
	addi $t3,$t3,1 #quantidadeDeBombas+1
	j fimCalculaUmCampo
	
naoEhTipo7:
	li $t0,8
	bne $a0,$t0,fimCalculaUmCampo
	#Procura na esquerda
	sub $t4,$t6,$t2
	lw $t4,0($t4) 
	bne $t4, $t5,naoEncontrado30
	addi $t3,$t3,1 #quantidadeDeBombas+1
naoEncontrado30:
	#Procura em cima
	move $t4,$t8
	lw $t4,0($t4)
	bne $t4, $t5,naoEncontrado31
	addi $t3,$t3,1 #quantidadeDeBombas+1
naoEncontrado31:
	#Procura na diagonal superior esquerda
	sub $t4,$t8,$t2
	lw $t4,0($t4)
	bne $t4, $t5,fimCalculaUmCampo
	addi $t3,$t3,1 #quantidadeDeBombas+1
	j fimCalculaUmCampo
	
fimCalculaUmCampo:
	move $v0,$t3
	jr $ra
#####Fim da função CalculaUmCampo#####	
	
fim:
	##finaliza o programa:##
	li $v0, 10 
	syscall 						
