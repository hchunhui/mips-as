%{
	#include <stdio.h>
	#include <stdlib.h>
	#include <string.h>
	#include <stdint.h>

	uint32_t codes[10240];
	char    *labels[10240];
	char     inss[10240][64];
	int cx;

	struct symbol {
		char *label;
		int x;
	};
	struct symbol sym[10240];
	int dx;
	
	struct mips_ins
	{
		const char *op;
		uint32_t code;
	};
	struct mips_ins r_type[] =
	{
		{"add" , 0x00000020},
		{"addu", 0x00000021},
		{"and" , 0x00000024},
		{"jalr", 0x00000009},
		{"jr"  , 0x00000008},
		{"nor" , 0x00000027},
		{"or"  , 0x00000025},
		{"sll" , 0x00000000},
		{"sllv", 0x00000004},
		{"sra" , 0x00000003},
		{"srav", 0x00000007},
		{"srl" , 0x00000002},
		{"srlv", 0x00000006},
		{"slt" , 0x0000002a},
		{"sltu", 0x0000002b},
		{"sub" , 0x00000022},
		{"subu", 0x00000023},
		{"syscall", 0x0000000c},
		{"eret", 0x42000018},
		{"xor" , 0x00000026},
		{NULL, 0},
	};
	
	struct mips_ins i_type[] =
	{
		{"addi" , 0x20000000},
		{"addiu", 0x24000000},
		{"andi" , 0x30000000},
		{"ori"  , 0x34000000},
		{"xori" , 0x38000000},
		{"beq"  , 0x10000000},
		{"bne"  , 0x14000000},
		{"slti" , 0x28000000},
		{"sltiu", 0x2c000000},
		{"lui"  , 0x3c000000},
		{"lw"   , 0x8c000000},
		{"sw"   , 0xac000000},
		{NULL, 0},
	};

	struct mips_ins j_type[] =
	{
		{"j"    , 0x08000000},
		{"jal"  , 0x0c000000},
		{NULL, 0},
	};

	struct mips_ins *find_op(struct mips_ins *tab, char *op)
	{
		int i;
		for(i = 0; tab[i].op; i++)
		{
			if(strcmp(tab[i].op, op) == 0)
				return tab + i;
		}
		return NULL;
	}

	int gen_r(char *op,
		  unsigned int rd,
		  unsigned int rs,
		  unsigned int rt,
		  unsigned int shamt)
	{
		unsigned int tmp;
		struct mips_ins *ops;
		if(ops = find_op(r_type, op))
		{
			if(rs >= 32 || rt >= 32 || rd >= 32 || shamt >= 32)
				yyerror("invalid number");
			if(strlen(op) == 4 && op[3] == 'v') /* shift variable , flip rs and rt */
			{
				tmp = rs;
				rs = rt;
				rt = tmp;
			}
			sprintf(inss[cx], "  -- %s $%d,$%d,$%d,%d", op, rd, rs, rt, shamt);
			codes[cx++] = (ops->code) |
				(shamt << 6)  |
				(rd    << 11) |
				(rt    << 16) |
				(rs    << 21);
			return 1;
		}
		return 0;
	}

	int gen_i(char *op,
		  unsigned int rt,
		  unsigned int rs,
		  short imm16)
	{
		struct mips_ins *ops;
		unsigned int imm;

		imm = imm16;
		imm &= 0xffff;
		
		if(ops = find_op(i_type, op))
		{
			if(rs >= 32 || rt >= 32)
				yyerror("invalid number");
			sprintf(inss[cx], "  -- %s $%d,$%d,0x%04hx", op, rt, rs, imm16);
			codes[cx++] = (ops->code) |
				imm           |
				(rt    << 16) |
				(rs    << 21);
			return 1;
		}
		return 0;
	}

	int gen_br(char *op,
		  unsigned int rs,
		  unsigned int rt,
		  char *label)
	{
		struct mips_ins *ops;
		
		if(ops = find_op(i_type, op))
		{
			if(rs >= 32 || rt >= 32)
				yyerror("invalid number");
			sprintf(inss[cx], "  -- %s $%d,$%d,%s", op, rs, rt, label);
			codes[cx] = (ops->code) |
				(rt    << 16) |
				(rs    << 21);
			labels[cx] = label;
			cx++;
			return 1;
		}
		return 0;
	}
	
	int gen_j(char *op,
		  char *label)
	{
		struct mips_ins *ops;
		
		if(ops = find_op(j_type, op))
		{
			sprintf(inss[cx], "  -- %s %s", op, label);
			codes[cx] = ops->code | 1;
			labels[cx] = label;
			cx++;
			return 1;
		}
		return 0;
	}

	void handle_label(char *label)
	{
		if(label)
		{
			if(find_label(label) == -1)
			{
				sym[dx].label = label;
				sym[dx].x = cx;
				dx++;
			}
			else
				yyerror("redefined label!");
		}
	}

	int find_label(char *label)
	{
		int i;
		for(i = 0; i < dx; i++)
			if(strcmp(label, sym[i].label) == 0)
				return sym[i].x;
		return -1;
	}

	void fix_labels()
	{
		int i;
		int x;
		short imm16;
		uint32_t imm;
		for(i = 0; i < cx; i++)
		{
			if(labels[i])
			{
				x = find_label(labels[i]);
				if(x == -1)
				{
					fprintf(stderr,
						"can't find label: %s\n",
						labels[i]);
					exit(1);
				}
				/*fprintf(stderr,
						"label is at %d\n"
						"now is at %d\n",
						x,
						i);*/
				if((codes[i]&1) == 0)
				{
					/* branch */
					imm16 = x-i-1;
					imm = imm16&0xffff;
					codes[i] |= imm;
				}
				else
				{
					codes[i]&=~1;
					imm = x&((1<<26)-1);
					codes[i] |= imm;
				}
				free(labels[i]);
				labels[i] = NULL;
			}
		}
	}

	void list_code()
	{
		int i;
		for(i = 0; i < 512; i++)
			printf("\t%03x : %08x; %s\n", i, codes[i], inss[i]);
	}
%}

%union {
	int ival;
	char *name;
}

%locations
%token NUMBER REG
%token IDENT DIRECTIVE LABEL STRING
%token EOL

%start program

%type <ival> NUMBER REG number_opt
%type <name> IDENT DIRECTIVE label_opt LABEL

%destructor { free($$); } IDENT DIRECTIVE LABEL
%error-verbose
%%

program
	: stmts
	;
stmts
	: stmts stmt
	| /* E */
	;

label_opt
	: LABEL
	| /* E */
	{
		$$ = NULL;
	}
	;
number_opt
	: NUMBER
	|
	{
		$$ = 0;
	}
	;
stmt
	: label_opt DIRECTIVE EOL
	{
		handle_label($1);
		free($2);
	}
	| label_opt DIRECTIVE NUMBER EOL
	{
		handle_label($1);
		if(strcmp($2, ".text") == 0)
		{
			fprintf(stderr, "switch to %d\n", $3);
			if($3%4)
				yyerror("start addr % 4 != 0");
			cx = $3/4;
		}
		free($2);
	}
	| label_opt DIRECTIVE IDENT EOL
	{
		handle_label($1);
		free($2);
		free($3);
	}
	| label_opt DIRECTIVE STRING EOL
	| label_opt IDENT REG ',' REG ',' REG EOL     /* R-TYPE */
	{
		handle_label($1);
		if(!gen_r($2, $3, $5, $7, 0))
			yyerror("undefined R-type op");
		free($2);
	}
	| label_opt IDENT REG ',' REG ',' NUMBER EOL  /* R/I-TYPE */
	{
		handle_label($1);
		if(!gen_r($2, $3, 0, $5, $7))
			if(!gen_i($2, $3, $5, $7))
				yyerror("undefined R/I-type op");
		free($2);
	}
	| label_opt IDENT REG ',' REG ',' IDENT EOL   /* BR */
	{
		handle_label($1);
		if(!gen_br($2, $3, $5, $7))
			yyerror("undefined BR op");
		free($2);
	}
	| label_opt IDENT IDENT EOL                   /* JAL xxx */
	{
		handle_label($1);
		if(!gen_j($2, $3))
			yyerror("undefined R2-type op");
		free($2);
	}
	| label_opt IDENT REG ',' number_opt '(' REG ')' /* LW SW   */
	{
		handle_label($1);
		if(!gen_i($2, $3, $7, $5))
			yyerror("undefined lw sw op");
		free($2);
	}
	| label_opt IDENT REG EOL                     /* JR.. JALR */
	{
		handle_label($1);
		if(strcmp($2, "jalr") == 0)
			gen_r($2, 31, $3, 0, 0);
		else if(!gen_r($2, 0, $3, 0, 0))
			yyerror("undefined JR op");
		free($2);
	}
	| label_opt IDENT REG ',' NUMBER EOL          /* LUI.. */
	{
		handle_label($1);
		if(!gen_i($2, $3, 0, $5))
			yyerror("undefined LUI op");
		free($2);
	}
	| label_opt EOL
	{
		handle_label($1);
	}
	| label_opt IDENT EOL
	{
		handle_label($1);
		gen_r($2, 0, 0, 0, 0);
		free($2);
	}
	;


%%

int parse()
{
	int ret;
	//yydebug = 1;
	if(ret = yyparse())
		fprintf(stderr, "\nFAIL\n");
	else
		fprintf(stderr, "\nPASS\n");
	return ret;
}

int main()
{
	char *main_label;
	char *loop_label;
	cx = 0;
	dx = 0;
	memset(labels, 0, sizeof(labels));
	
	main_label = strdup("main");
	loop_label = strdup("__loop");
	gen_j("jal", main_label);
	gen_i("ori", 29, 0, 384*4); //利用延迟槽
	handle_label(loop_label);
	gen_br("beq", 0, 0, loop_label);
	gen_r("sll", 0, 0, 0, 0);

	yyparse();
	fix_labels();

	printf("WIDTH=32;\n"
	       "DEPTH=512;\n"
	       "ADDRESS_RADIX=HEX;\n"
	       "DATA_RADIX=HEX;\n"
	       "CONTENT BEGIN\n");
	
	list_code();
	printf("END;\n");
	/*printf("\t[%03x..1FF] : 00000000;\n"
	       "END;\n",
	       cx);*/
}

