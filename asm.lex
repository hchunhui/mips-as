%{
#include <stdio.h>
#include "asm.tab.h"

int yycolumn = 0;
const char *reg_name[] = {
	"$0",
	"$at",
	"$v0",
	"$v1",
	"$a0",
	"$a1",
	"$a2",
	"$a3",
	"$t0",
	"$t1",
	"$t2",
	"$t3",
	"$t4",
	"$t5",
	"$t6",
	"$t7",
	"$s0",
	"$s1",
	"$s2",
	"$s3",
	"$s4",
	"$s5",
	"$s6",
	"$s7",
	"$t8",
	"$t9",
	"$k0",
	"$k1",
	"$gp",
	"$sp",
	"$s8",
	"$ra",
	"$0",
	"$1",
	"$2",
	"$3",
	"$4",
	"$5",
	"$6",
	"$7",
	"$8",
	"$9",
	"$10",
	"$11",
	"$12",
	"$13",
	"$14",
	"$15",
	"$16",
	"$17",
	"$18",
	"$19",
	"$20",
	"$21",
	"$22",
	"$23",
	"$24",
	"$25",
	"$26",
	"$27",
	"$28",
	"$29",
	"$fp",
	"$31",
	NULL,
};
#define YY_USER_ACTION yylloc.first_line = yylloc.last_line = yylineno; \
    yylloc.first_column = yycolumn; yylloc.last_column = yycolumn+yyleng-1; \
    yycolumn += yyleng;
%}

%option yylineno

D	   [0-9]
L	   [a-zA-Z_]
H	   [a-fA-F0-9]

%%
\#[^\r\n]*(\r|\n)	{ fprintf(stderr, "#comment\n"); return EOL;}
\.{L}({L}|{D})*		{
	fprintf(stderr, "%s", yytext);
	yylval.name = strdup(yytext);
	return DIRECTIVE;
     }

{L}({L}|{D})*\:		{
	fprintf(stderr, "%s", yytext);
	yylval.name = strdup(yytext);
	yylval.name[yyleng-1] = 0;
	return LABEL;
   }

{L}({L}|{D})*		{
	fprintf(stderr, "%s", yytext);
	yylval.name = strdup(yytext);
	return IDENT;
   }

\$({L}|{D})*		{
	int i;
	fprintf(stderr, "%s", yytext);
	for(i = 0; reg_name[i]; i++)
		if(strcmp(yytext, reg_name[i]) == 0)
		{
			yylval.ival = i%32;
			return REG;
		}
	yylval.name = strdup(yytext);
	return IDENT;
}

0[xX]{H}+		{
	fprintf(stderr, "%s", yytext);
	yylval.ival = strtol(yytext, NULL, 16);
	return NUMBER;
	}
0{D}+			{
	fprintf(stderr, "%s", yytext);
	yylval.ival = strtol(yytext, NULL, 8);
	return NUMBER;
    }
(\+|\-)?{D}+			{
	fprintf(stderr, "%s", yytext);
	yylval.ival = strtol(yytext, NULL, 10);
	return NUMBER;
   }

,			{ fprintf(stderr, "%s", yytext); return ','; }
\(			{ fprintf(stderr, "%s", yytext); return '('; }
\)			{ fprintf(stderr, "%s", yytext); return ')'; }
[ \v\f]			{ fprintf(stderr, "%s", yytext); }
\t			{ fprintf(stderr, "%s", yytext); yycolumn += 8 - yycolumn%8; }
[\n\r]			{ fprintf(stderr, "%s", yytext); yycolumn = 0; return EOL; }
\"[^\"]*\"		{ return STRING; }
.			{ fprintf(stderr, "unmatched: %s\n", yytext); return 1; }

%%

int yywrap(void)
{
	return 1;
}

void yyerror(char const *s)
{
	fflush(stdout);
	fprintf(stderr, "Error@(%d:%d-%d:%d): %s\n",
	       yylloc.first_line,
	       yylloc.first_column,
		   yylloc.last_line,
		   yylloc.last_column,
	       s);
	exit(1);
	/*printf("\n%*s\n%*s\n",
	       yylloc.first_column,
	       "^",
	       yylloc.first_column,
	       s);*/
}
