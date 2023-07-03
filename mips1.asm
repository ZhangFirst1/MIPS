.text
	ori $29, $0, 12
	ori $2, $0, 0x1234
	ori $3, $0, 0x3456
	addu $4, $2, $3
	subu $6, $3, $4	# 2 0x1234 3 0x3456 4 0x468a 6 0xffffedcc 29 0x000c
	sw $2, 0($0)
	sw $3, 4($0)
	sw $4, 4($29)
	lw $5, 0($0)
	beq $2, $5, _lb2
	sll $0, $0, 0
	_lb1:
	lw $3, 4($29)		# error
	_lb2:
	lw $5, 4($0)
	beq $3, $5, _lb1	
	sll $0, $0, 0
	jal F_Test_JAL		# $31 change
	sll $0, $0, 0
	# Never return
	
F_Test_JAL:
	subu $6, $6, $2	# db98
	sw $6, -4($29)		
	_loop:
	beq $3, $4, _loop
	sll $0, $0, 0
	# Never return back