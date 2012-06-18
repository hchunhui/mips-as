## 针对C1后端生成指令的测试程序
## 运行结果
## 00 55AAAA55  读写测试
## 04 AA5555AA
## 08 00005555  算术运算
## 0C 00003311
## 10 FFFFCCEF
## 14 FFFFFFFF
## 18 55AA5555  逻辑运算
## 1C 55AAAAFF
## 20 AB5554AA
## 24 56AAA954
## 28 2AD5552A
## 2C 156AAA95
## 30 00000001  条件置位
## 34 00000000
## 38 0000900D  控制指令  若为0BAD或1BAD则错
## 3C 0000900D
## 40 00001234  数据转发
## 44 00001235
## 48 00005556
## 4C 00004321
## 50 00000001
.text
.align 2
main:	
	lui $gp, 4096
	ori $gp, $gp, 0
	ori $fp,$ra, 0		#存返回地址
	## 读写测试
	lui $1, 0x55aa
	ori $1, $1, 0xaa55		#$1 =0x55aaaa55
	sw $1, 0($gp)
	lw  $2, 0($gp)
	sll $0, $0, 0
	nor $2, $2, $0		#$2 =0xaa5555aa
	sw  $2, 4($gp)

	## 运算测试
	## 算术运算
	ori $3, $0, 0x1122
	ori $4, $0, 0x4433
	addu $5, $3, $4		#$5 =0x00005555
	subu $6, $4, $3		#$6 =0x00003311
	subu $7, $3, $4		#$7 =0xffffccef
	addiu $8, $7, 0x3310	#$8 =0xffffffff
	sw $5, 8($gp)
	sw $6, 12($gp)
	sw $7, 16($gp)
	sw $8, 20($gp)
	## 逻辑运算
	xori $9, $1, 0xff00	#$9 =0x55aa5555
	ori $10, $1, 0x00ff	#$10=0x55aaaaff
	sw $9, 24($gp)
	sw $10,28($gp)
	sll $9, $1, 1		#$9 =0xab5554aa
	sll $10, $1,2		#$10=0x56aaa954
	sw $9, 32($gp)
	sw $10, 36($gp)
	sra $9, $1, 1		#$9 =0x2ad5552a
	sra $10, $1,2		#$10=0x156aaa95
	sw $9, 40($gp)
	sw $10, 44($gp)
	## 条件置位
	slt $11, $6, $5		#$11=1
	slt $12, $1, $2		#$12=0
	sw $11, 48($gp)
	sw $12, 52($gp)

	## 控制类
	bne $0, $0, ctl_w	#此句不转
	ori $13, $0, 0x0bad	#延迟槽
	beq $0, $0, ctl_w	#此句转
	ori $13, $0, 0x900d
	ori $13, $0, 0x1bad
ctl_w:	sw $13, 56($gp)		#$13=0x0000900d
	jal proc1
	ori $14, $0, 0x0bad	#延迟槽
apr1:	sw $14, 60($gp)		#$14=0x0000900d

	## 数据转发测试
	ori $16, $0, 0x1234	#$16=0x00001234
	addu $17, $0, $16	#$17=0x00001234
	addiu $17, $17, 1	#$17=0x00001235
	subu $18, $17, $16	#$18=0x00000001
	addiu $19, $17, 0x4321	#$19=0x00005556
	subu  $20, $19, $17	#$20=0x00004321
	sw $16, 64($gp)
	sw $17, 68($gp)
	sw $19, 72($gp)
	sw $20, 76($gp)
	lw $21, 76($gp)
	sll $0, $0, 0
	addiu $21, $21, 1
	slt $21, $20, $21
	sw $21, 80($gp)		#$21=0x00000001

halt:
	jr $fp
	sll $0, $0, 0

proc1:	jr $ra
	ori $14, $0, 0x900d
	ori $14, $0, 0x1bad
	j apr1

## 中断处理程序，每次加一
.text 1024
	lw $k1, 2040($0)
	sll $0, $0, 0
	addiu $k1, $k1, 1
	sw $k1, 2040($0)
	sll $0, $0, 0
	sll $0, $0, 0
	eret

## 异常处理程序，每次加一
.text 1536
	lw $k1, 2044($0)
	sll $0, $0, 0
	addiu $k1, $k1, 1
	sw $k1, 2044($0)
	ori $1, $0, 0
	ori $2, $0, 0
	ori $3, $0, 0
	ori $4, $0, 0
	ori $5, $0, 0
	ori $6, $0, 0
	ori $7, $0, 0
	ori $8, $0, 0
	ori $9, $0, 0
	ori $10, $0, 0
	ori $11, $0, 0
	ori $12, $0, 0
	ori $13, $0, 0
	ori $14, $0, 0
	ori $15, $0, 0
	ori $16, $0, 0
	ori $17, $0, 0
	ori $18, $0, 0
	ori $19, $0, 0
	ori $20, $0, 0
	ori $21, $0, 0
	ori $22, $0, 0
	ori $23, $0, 0
	ori $24, $0, 0
	ori $25, $0, 0
	sll $0, $0, 0
	sll $0, $0, 0
	eret
	