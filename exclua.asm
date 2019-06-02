#for(x = 0; x < 10; x++)
#    A[x] = B[x] + x;
		
		.data


vector_A:	.space    40

	.text
main:
	la $s0, vector_A   		# S0 armazena A[0]
	lw $t6, 0($s0)



