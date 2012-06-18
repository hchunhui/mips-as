main:
sub $0,$0,$0
add $5,$0,$0
		

lui $10,0x000a
addi $10,$10,1
sw $10,0($5) 
addi $10,$0,3
sw $10,4($5)	

lw $1,0($5) 	
addi $0,$0,0 
lw $2,4($5)	
addi $0,$0,0

add $4,$1,$2
sw $4,0($5)	
addi $0,$0,0 
addi $5,$5,4	

addu $4,$1,$2
sw $4,0($5)	
addi $0,$0,0 
addi $5,$5,4	

sub $4,$1,$2
sw $4,0($5)	
addi $0,$0,0 
addi $5,$5,4	

subu $4,$1,$2
sw $4,0($5)	
addi $0,$0,0 
addi $5,$5,4	

and $4,$1,$2
sw $4,0($5)	
addi $0,$0,0 
addi $5,$5,4	

or $4,$1,$2
sw $4,0($5)	
addi $0,$0,0 
addi $5,$5,4	

xor $4,$1,$2
sw $4,0($5)	
addi $0,$0,0 
addi $5,$5,4	

nor $4,$1,$2
sw $4,0($5)
addi $0,$0,0 
addi $5,$5,4	

slt $4,$1,$2
sw $4,0($5)	
addi $0,$0,0 
addi $5,$5,4	

sltu $4,$1,$2
sw $4,0($5)	
addi $0,$0,0 
addi $5,$5,4	

sll $4,$1,3
sw $4,0($5)	
addi $0,$0,0 
addi $5,$5,4	

srl $4,$1,3
sw $4,0($5)	
addi $0,$0,0 
addi $5,$5,4	

sra $4,$1,3
sw $4,0($5)	
addi $0,$0,0 
addi $5,$5,4	

sllv $4,$1,$2
sw $4,0($5)	
addi $0,$0,0 
addi $5,$5,4	

srlv $4,$1,$2
sw $4,0($5)	
addi $0,$0,0 
addi $5,$5,4	

srav $4,$1,$2
sw $4,0($5)	
addi $0,$0,0 
addi $5,$5,4	

jal labjal
addi $0,$0,0 
labjal:
addi $31,$31,24
jr $31
addi $0,$0,0 
sw $0,0($0)
addi $0,$0,0
sw $0,0($5)	
addi $0,$0,0 
addi $5,$5,4	

addi $4,$1,20
sw $4,0($5)	
addi $0,$0,0 
addi $5,$5,4	

addiu $4,$1,-20
sw $4,0($5)	
addi $0,$0,0 
addi $5,$5,4	

andi $4,$1,5
sw $4,0($5)	
addi $0,$0,0 
addi $5,$5,4	

ori $4,$1,5
sw $4,0($5)	
addi $0,$0,0 
addi $5,$5,4	

xori $4,$1,5
sw $4,0($5)	
addi $0,$0,0 
addi $5,$5,4	

addi $4,$0,0
lui $4,100
sw $4,0($5)	
addi $0,$0,0 
addi $5,$5,4	

beq $1,$1,labb1
addi $0,$0,0
sw $0,0($0)
labb1:
bne $5,$0,labb2
addi $0,$0,0
sw $0,0($0)
labb2:

slti $4,$1,10
sw $4,0($5)	
addi $0,$0,0 
addi $5,$5,4	

sltiu $4,$1,-20
sw $4,0($5)	
addi $0,$0,0 
addi $5,$5,4	

j halt
addi $0,$0,0
sw $0,0($0)

halt:
beq $0,$0,halt
addi $0,$0,0
