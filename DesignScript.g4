grammar DesignScript;

program:
	( coreStmt )*
    ;

//assocBlock:
//    '[' AssocKeyword ']' argList? '{' assocBlockBody '}'
//    ;

//assocBlockBody:
//    ( coreStmt )*
//    ;

//langBlock:
//    imperBlock
//    ;

coreStmt:
    assignStmt ';'
|   funcDef
|   exprStmt
|   returnStmt ';'
|   langReturnStmt
|   langAssignStmt
//|   langBlock
    ;

langReturnStmt:
	'return' '=' imperBlock
	;

langAssignStmt:
    Ident (':' typeAnnotation)? '=' imperBlock
    ;

argList:
    ('(' identList ')')
    ;

imperBlock:
    '[' ImperKeyword ']' argList? '{' imperBlockBody '}'
    ;

// what happens when an imper block lacks a return? return last expr?
// should nested imper blocks be discovered in static analysis? or prevented in parser?
// what are the limitations on function definition inlining?
// should assignment be an expr?
// should unary increment, decrement be an expr?
// should unary inc/dec be allowed in associative?
// can imperative blocks just be syntactic sugar on function calls?
// scoped blocks in flow blocks?

funcDef:
	'def' (':' typeAnnotation)? argList? '{' (coreStmt)* '}'
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

assignStmt:
    Ident (':' typeAnnotation)? '=' expr
    ;

exprList:
    expr (',' expr)*
    ;

identList:
    Ident (',' Ident)*
    ;

typeAnnotation:
    ('local')? qualifiedIdent?
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

AssocKeyword:
    'Associative'
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
