grammar DesignScript;

program:
    ( coreStmt )*
	;

coreStmt:
    assignStmt ';'
|   exprStmt
|   returnStmt ';'
|   funcDef
|   imperBlock
|   imperBlockReturnStmt
|   imperBlockAssignStmt
    ;

funcDef:
	'def' (':' typeAnnotation)? Ident '(' identList? ')' '{' (coreStmt)* '}'
	;

expr:
    primary                                     #primaryExpr
|   qualifiedIdent '(' exprList? ')'            #funcCallExpr
|   expr ('++' | '--')                          #postDecExpr
|   ('!'|'+'|'-'|'++'|'--') expr                #unaryExpr
|   expr Op=('*'|'/'|'%') expr                  #mulDivModExpr
|   expr Op=('+'|'-') expr                      #addSubExpr
|   expr Op=('<=' | '>=' | '>' | '<') expr      #compExpr
|   expr Op=('=='|'!=') expr                    #eqExpr
|   expr ('&&') expr                            #andExpr
|   expr ('||') expr                            #orExpr
|   expr '..' expr                              #unitRangeExpr
|   expr '..' expr '..' '#' expr                #countRangeExpr
|   expr '[' expr ']'                           #indexExpr
|   expr repGuideList                           #repGuideExpr
|   imperBlock                                  #imperBlockExpr
    ;

primary:
    parExpr        #parenExpr
|   lit            #litExpr
|   Ident          #ident
    ;

parExpr:
    '(' expr ')'
    ;

lit:
     NumLit                               #numLit
|    StringLit                            #stringLit
|    BoolLit                              #boolLit
|    'null'                               #nullLit
|    '{' exprList? '}'                    #arrayLit
    ;

repGuideList:
    RepGuide+
    ;

forControl:
    forInit? ';' expr? ';' forUpdate?
    ;

forInit:
    assignStmt
|   exprList
    ;

forUpdate:
    exprList
    ;

exprStmt:
    expr ';'
    ;

returnStmt:
    'return' '=' expr
    ;

imperBlock:
    '[' ImperKeyword ']' depCaptureList? '{' imperBlockBody '}'
    ;

imperBlockReturnStmt:
	'return' '=' imperBlock
	;

imperBlockAssignStmt:
	typedIdent '=' imperBlock
	;

imperBlockBody:
    ( imperStmt )*
    ;

imperStmt:
     coreStmt                                          #imperCoreStmt
|    'if' '(' expr ')' imperStmt ('else' imperStmt)?   #ifStmt
|    'for' '(' forControl ')' imperStmt                #forStmt
|    'while' parExpr imperStmt                         #whileStmt
|    'do' imperStmt 'while' parExpr ';'                #doStmt
|    'break' Ident? ';'                                #breakStmt
|    'continue' Ident? ';'                             #continueStmt
|    '{' imperBlockBody '}'                            #blockStmt
    ;

depCaptureList:
    ('(' identList ')')
    ;

assignStmt:
    typedIdent '=' expr
    ;

typedIdent:
	Ident (':' typeAnnotation)?
	;

exprList:
    expr (',' expr)*
    ;

identList:
    qualifiedIdent (',' qualifiedIdent)*
    ;

typeAnnotation:
    qualifiedIdent?
    ;

qualifiedIdent:
    Ident ('.' Ident)*
    ;

RepGuide:
    '<' INT '>'
    ;

// keywords must precede identifier tokens
// otherwise you'll get identifiers with keyword names :(

NULL : 'null';
RETURN : 'return';
LOCAL : 'local';
FOR: 'for';
WHILE: 'while';
DO: 'do';
BREAK: 'break';
CONTINUE: 'continue';

BoolLit:
    'true'
|   'false'
    ;

ImperKeyword:
    'Imperative'
    ;

NumLit:
    INT '.' [0-9]+ EXP? | INT EXP | INT
    ;

fragment INT:
    '0' | [1-9] [0-9]*
    ;

fragment EXP:
    [Ee] [+\-]? INT
    ;

StringLit
    :   '"' StringChars? '"'
    ;

fragment StringChars:
    StringChar+
    ;

fragment StringChar:
    ~["\\]
|   EscapeSeq
    ;

fragment EscapeSeq:
    '\\' [abtnfrv"'\\]
|   UnicodeEscape
|   HexByteEscape
    ;

fragment HexByteEscape
    :   '\\' 'x' HexDigit HexDigit
    ;

fragment UnicodeEscape
    :   '\\' 'u' HexDigit HexDigit HexDigit HexDigit
    ;

fragment HexDigit
    :   [0-9a-fA-F]
    ;

Ident:
    [a-zA-Z$_] [a-zA-Z0-9$_]*
    ;

WS
    : [ \t\n\r] + -> skip
    ;

COMMENT
    : '/*' .*? '*/' -> skip
    ;

LINE_COMMENT
    : '//' ~[\r\n]* -> skip
    ;

ADDADD    : '++';
SUBSUB    : '--';
ADD    : '+';
SUB    : '-';
MUL    : '*';
DIV    : '/';
MOD    : '%';
NOT    : '!';
AND    : '&&';
OR    : '||';
GT    : '>';
GE    : '>=';
LT    : '<';
LE    : '<=';
NE    : '!=';
EQ    : '==';
