# DesignScript Language Specification (Draft)

## Introduction

This is the specification for DesignScript programming language. DesignScript is a dynamic language and provides support for flow-based programming environment.

The grammar in this specification is in Extended Backus-Naur Form (EBNF)

This document doesn’t contain information about APIs and Foreign Function Interface (FFI). The latter is implementation dependent.

## Lexical elements

### Comments

DesignScript supports two kinds of comments.

* Single line comment starts with // and stop at the end of the line.

* Block comments starts with /* and ends with */.

Example:

```
x = 1; // single line comment

/*
   Block comments
*/
y = 2;
```

### Semicolons

Semicolon ";" is used as a terminator of a certain class of statements.

### Identifiers

Identifiers in DesignScript name variables, types, functions and namespaces.

```
Identifier =
    identifier_start_letter { identifier_part_letter }
```

"identifier_start_letter" is the unicode character in the following categories:

* Uppercase letter (Lu)
* Lowercase letter (Ll)
* Titlecase letter (Lt)
* Modifier letter (Lm)
* Other letter (Lo)
* Letter number (Nl)

"identifier_part_letter" is the unicode character in the categories of “identifier_start_letter” including the following categories:

* Combining letter (Mn, Mc)
* Decimal digital letter (Nd)
* Connecting letter (Nc)
* Zero Width Non-Joiner
* Zero Width Joiner

### Keywords

The following words are reserved as keywords

```
break, continue, def, else, elseif, for, if, in, return, while, imperative
```

### Operators

The following character sequences represent operators.

```
+    -    *    /   %
==   <    >    <=  >=  !=
&&   ||   !
..   @    @@  
```

### Bool literal

```
true, false
```

### Number literal

DesignScript doesn't have integer type. The range of number is defined by the range of double-precision floating-point.

```
digit = ‘0’..’9’

decimal_format = digit { digit }

floating_point_format =
    digit { digit } ‘.’ [digit { digit }] [ exponent ]
  | digit { digit } exponent
  | ‘.’ digit { digit } [ exponent ]

exponent = (‘E’ | ‘e’) [‘+’ | ‘-’] digit { digit }

number = decimal_format | floating_point_format
```

Example:

```
123    1.2e3    1.234    .123
```

### String literal

String literal represents a string constant. It is obtained by putting character sequence between double quote (").

Any character can be in the sequence except newline and double quote ("). Backslash character in the sequence could be combined with the next character to become an escape character (NOTE:  https://en.wikipedia.org/wiki/Escape_character):

* \a
* \b
* \f
* \n
* \t
* \v
* \r

Example:

```
// "Hello        DesignScript
// Language"
“\”Hello\tDesignScript\nLanguage\””;
```

## Types

### Primitive Types

The type system in DesignScript is dynamic. DesignScript supports following primitive types

<table>
  <tr>
	<td>Type</td>
    <td>Value range</td>
    <td>Default value</td>
  </tr>
  <tr>
    <td>string</td>
    <td>n.a.</td>
    <td>""</td>
  </tr>
  <tr>
    <td>number</td>
    <td>IEEE 754 double-precision</td>
    <td>0</td>
  </tr>
  <tr>
    <td>bool</td>
    <td>true, false</td>
    <td>false</td>
  </tr>
  <tr>
    <td>null</td>
    <td>null</td>
    <td>null</td>
  </tr>
  <tr>
    <td>var</td>
    <td>n.a.</td>
    <td>null</td>
  </tr>
</table>


The default value of all other types is "null".

### List

In DesignScript, List is used to keep a collection of object. It is *immutable*, that is, we could use index to get value that stored in a list, but we should always call `Set(list, index, value)` to get a new list which stores new value at specified location.

#### Rank

If a type has rank suffix, it declares a list. The number of "[]" specifies rank of this list. “[]..[]” specifies arbitrary rank. For example,

```
number[]     // a number list whose rank is 1
number[][]   // a number list whose rank is 2
number[]..[] // a number list with arbitrary rank
```

The rank of type decides how do [replication ](#heading=h.f51u2x6ertfi)and [replication guide](#heading=h.f51u2x6ertfi) work in function dispatch.

#### List as dictionary

List in DesignScript is just a special case of dictionary whose keys are continuous integers start from 0. We could use built-in function `Set()` to set value for any kind of key.

Lists are dynamic. It is possible to index into any location of the list. If setting value to an index which is beyond the length of list, list will be automatically expanded. For example,

```
x = {1, 2, 3};

y = Set(x, 5, "foo")
length = len(x);    // length == 6;
v = y[5];           // v == "foo"
```

When a dictionary is used in "in" clause of “[for](#heading=h.wl3kjkvppdmk)” loop, it returns all values associated with keys.

### Type conversion rules

Following implicit type conversion rules specify the result of converting one type to another:

#### Non-list case

"yes" means convertible, “no” means no convertible.

<table>
  <tr>
	<td>From To</td>
    <td>var</td>
    <td>number</td>
    <td>bool</td>
    <td>string</td>
    <td>FFI type</td>
  </tr>
  <tr>
    <td>var</td>
    <td>yes</td>
    <td>no</td>
    <td>no</td>
    <td>no</td>
    <td>no</td>
  </tr>
  <tr>
    <td>number</td>
    <td>yes</td>
    <td>yes</td>
    <td>no</td>
    <td>no</td>
    <td>no</td>
  </tr>
  <tr>
    <td>bool</td>
    <td>yes</td>
    <td>no</td>
    <td>yes</td>
    <td>no</td>
    <td>no</td>
  </tr>
  <tr>
    <td>string</td>
    <td>yes</td>
    <td>no</td>
    <td>no</td>
    <td>yes</td>
    <td>no</td>
  </tr>
  <tr>
    <td>FFI type</td>
    <td>yes</td>
    <td>no</td>
    <td>no</td>
    <td>no</td>
    <td>yes</td>
  </tr>
</table>


#### Rank promotion

<table>
  <tr>
    <td>From To</td>
    <td>var[]</td>
    <td>number[]</td>
    <td>bool[]</td>
    <td>string[]</td>
    <td>FFI type []</td>
  </tr>
  <tr>
    <td>var</td>
    <td>yes</td>
    <td>no</td>
    <td>no</td>
    <td>no</td>
    <td>no</td>
  </tr>
  <tr>
    <td>number</td>
    <td>yes</td>
    <td>yes</td>
    <td>no</td>
    <td>no</td>
    <td>no</td>
  </tr>
  <tr>
    <td>bool</td>
    <td>yes</td>
    <td>no</td>
    <td>yes</td>
    <td>no</td>
    <td>no</td>
  </tr>
  <tr>
    <td>string</td>
    <td>yes</td>
    <td>no</td>
    <td>no</td>
    <td>yes</td>
    <td>no</td>
  </tr>
  <tr>
    <td>FFI type</td>
    <td>yes</td>
    <td>no</td>
    <td>no</td>
    <td>no</td>
    <td>Covariant</td>
  </tr>
</table>

## Variables

A variable is storage location for a value. As DesignScript is dynamic, it is free to assign any kind of value to a variable. Variable in global scope is immutable. That is, a variable is only allowed to be assigned once. For example,

```
a = 1;
a = 2; // error: double assignment
```

But a variable is mutable in imperative block. For example,
```
[Imperative]
{
    x = 1;
    x = 2; // OK
}
```

All variables should be defined before being used. For example,

```
b = a; // error: "a" is not defined yet
a = 1;
```

### Scope

Unlike block scope (NOTE:  https://en.wikipedia.org/wiki/Scope_(computer_science)#Block_scope) in most programming language, DesignScript only looks up variables defined in current block, and a block could be either function or imperative block.

```
x = 1;
y = 2;

def foo(x) {
    z = 3;          // "z" is local variable
    return = x + y; // “x” is parameter
                    // error: “y” is not defined
}

[Imperative](x) {
    x = 3;          // "x" is not the "x" defined outside.
                    // OK to change its value
}
```

## Declarations

### Function declaration

```
FunctionDeclaration =
    "def" identifier [“:” TypeSpecification] ParameterList StatementBlock.

ParameterList =
    “(“ [Parameter {“,” Parameter}] “)”

Parameter =
    identifier [“:” TypeSpecification] [DefaultArgument]

StatementBlock =
    “{“ { Statement } “}”
```

The return type of function is optional. By default the return type is var. If the return type is specified, [type conversion](#heading=h.l30kv4fz02il) may happen. It is not encouraged to specify return type unless it is necessary.

Function must be defined in the global scope.

For parameters, if their types are not specified, by default is var. The type of parameters should be carefully specified so that [replication and replication guide](#heading=h.f51u2x6ertfi) will work as desired. For example, if a parameter’s type is var[]..[] ([arbitrary rank](#heading=h.x5qwed3vbjgx)), it means no replication on this parameter.

Example:

```
def foo:var(x:number[]..[], y:number = 3)
{
    return x + y;
}
```

#### Default parameters

Function declaration allows to have default parameter, but with one restriction: all default parameters should be the rightmost parameters.

For example:

```
// it is valid because "y" and “z” are the rightmost default parameters
def foo(x, y = 1, z = 2)
{
    return = x + y + z;
}

// it is invalid because “x” is not the rightmost default parameter
def bar(x = 1, y, z = 2)
{
    return = x + y + z;
}
```

#### Function overloads

Like most dynamic languages, DesignScript doesn't supports function overload. See FFI.

## Expressions

### List creation expression

```
ListCreationExpression = "{“ [[Expression ":"] Expression { “," [Expression ":"] Expression } ] “}”
```

List creation expression is to create a list. Example:

```
x = {{1, 2, 3}, null, {true, false}, "DesignScript"};
y = {0:"foo", 1:"bar", "qux":"quz"};
```

### Range expression

Range expression is a convenient way to generate a list.

```
RangeExpression =
     Expression [".." [“#”] Expression [“..” [“#”] Expression]
```


There are three forms of range expressions:

* start_value..end_value

    * If start_value < end_value, it generates a list in ascendant order which starts at start_value, and the last value < end_value, the increment is 1

    * If start_value > end_value, it generates a list in descendent order which starts at start_value and the last value >= end_value, the increment is -1.

* start_value..#number_of_elements..increment: it generates a list that contains number_of_elements elements. Element starts at start_value and the increment is increment.

* start_value..end_value..#number_of_elements: it generates a list that contains number_of_elements elements. Element starts at start_value and ends at end_value. Depending on if start_value <= end_value, the generated list will be in ascendant order or in descendent order.

Example:

```
1..5;       // {1, 2, 3, 4, 5}

5..1;       // {5, 4, 3, 2, 1}

1.2 .. 5.1; // {1.2, 2.2, 3.2, 4.2}

5.1 .. 1.2; // {5.1, 4.1, 3.1, 2.1}

1..#5..2;   // {1, 3, 5, 7, 9}

1..5..#3;   // {1, 3, 5}
```

Range expression  is handled specially for strings with single character. For example, following range expressions are valid as well:

```
"a"..”e”;     // {“a”, “b”, “c”, “d”, “e”}

“a”..#4..2;   // {“a”, “c”, “e”, “g”}

“a”..”g”..#3; // {“a”, “d”, “g”}
```

### Inline conditional expression

```
InlineConditionalExpression = Expression ? Expression : Expression;
```


The first expression in inline conditional expression is condition expression whose type is bool. If it is true, the value of "?" clause will be returned; otherwise the value of “:” clause will be returned. The types of expressions for true and false conditions are not necessary to be the same. Example:

```
x = 2;
y = (x % 2 == 0) ? "foo" : 21;
```


Inline conditional expressions replicate on all three expressions. Example:

```
x = {true, false, true};
y = {"foo", “bar”, “qux”};
z = {“ding”, “dang”, “dong”};

r = x ? y : z;  // replicates, r = {“foo”, “dang”, “qux”}
```

### List access expression

List access expression is of the form

```
a[x]
```

"x" could be integer value or a key of any kind of types (if “a” is a [list](#heading=h.x6hkvoejht8r)).

The following rules apply:

* If it is just getting value, if "a" is not a list, or the length of “a” is less than “x”, or the rank of “a” is less than the number of indexer, for example the rank of “a” is 2 but the expression is a[x][y][z], there will be a “IndexOutOfRange” warning and null will be returned.

* If it is assigning a value to the list,  if "a" is not a list, or the length of “a” is less than “x”, or the rank of “a” is less than the number of indexer, “a” will be extended or its dimension will promoted so that it is able to accommodate the value. For example,

```
a = 1;
a[1] = 2;      // "a" will be promoted, a = {1, 2} now
a[3] = 3;      // “a” will be extended, a = {1, 2, null, 3} now
a[0][1] = 3;   // “a” will be promoted, a = {{1, 3}, 2, null, 3} now
```


### Operators

The following operators are supported in DesignScript:

```
+         Arithmetic addition
-         Arithmetic subtraction
*         Arithmetic multiplication
/         Arithmetic division
%         Arithmetic mod
>         Comparison large
>=        Comparison large than
<         Comparison less
<=        Comparison less than
==        Comparison equal
!=        Comparison not equal
&&        Logical and
||        Logical or
!         Logical not
-         Negate
```

All operators support replication. Except unary operator "!", all other operators also support replication guide. That is, the operands could be appended replication guides.

```
x = {1, 2, 3};
y = {4, 5, 6};
r1 = x + y;       // replication
                  // r1 = {5, 7, 9}

r2 = x<1> + y<2>; // replication guide
                  // r2 = {
                  //          {5, 6, 7},
                  //          {6, 7, 8},
                  //          {7, 8, 9}
                  //      }
```


Operator precedence

<table><tr><td>
Precedence</td>
    <td>Operator</td>
  </tr>
  <tr>
    <td>6</td>
    <td>-</td>
  </tr>
  <tr>
    <td>5</td>
    <td>*, /, %</td>
  </tr>
  <tr>
    <td>4</td>
    <td>+, -</td>
  </tr>
  <tr>
    <td>3</td>
    <td>>, >=, <, <=, ==, !=</td>
  </tr>
  <tr>
    <td>2</td>
    <td>&&</td>
  </tr>
  <tr>
    <td>1</td>
    <td>||</td>
  </tr>
</table>

### Arithmetic operators

```
+, -, *, /, %
```

Normally the operands are either integer value or floating-point value. "+" can be used as string concatenation:

```
s1 = "Design";
s2 = “Script”;
s = s1 + s2;  // “DesignScript”
```

### Comparison operators

```
>, >=, <, <=, ==, !=
```

### Logical operators

```
&&, ||, !
```

The operand should be bool type; otherwise type conversion will be incurred.

## Statements

### Empty statements

Empty statement is

```
;
```

### Expression statement

```
ExpressionStatement = Expression ";"
```

Expression statements are expressions without assignment.

### Assignment statement

```
Assignment = Expression "=" ((Expression “;”) | LanguageBlock)
```

The left hand side of "=" should be assignable. Typically, it is [member access expression](#heading=h.rf6u7s9js69k) or [array access expression](#heading=h.7iw1e1npd4z) or variable. If the left hand side is a variable which hasn’t been defined before, the assignment statement will define this variable.

### Flow statements

Flow statements change the execution flow of the program. A flow statement is one of the followings:

1. A [return ](#heading=h.xw8lqigquohf)statement.

2. A [break ](#heading=h.wf15sn8vv9wg)statement in the block of [for](#heading=h.wl3kjkvppdmk) or [while ](#heading=h.55s0w9n1v8k2)statement in imperative block.

3. A [continue ](#heading=h.4yawi3g9ookh)statement in the block of [for](#heading=h.wl3kjkvppdmk) or [while ](#heading=h.55s0w9n1v8k2)statement in imperative block.

### Return statement

```
ReturnStatement = "return" Expression “;”
```

A "return" statement terminates the execution of the innermost function and returns to its caller, or terminates the innermost imperative block, and returns to the upper-level language block or function.

### Break statement

```
BreakStatement = "break" “;”
```

A "break" statement terminates the execution of the innermost “[for](#heading=h.wl3kjkvppdmk)” loop or “[while](#heading=h.55s0w9n1v8k2)” loop.

### Continue statement

```
ContinueStatement = "continue" “;”
```

A "continue" statement begins the next iteration of the innermost “[for](#heading=h.wl3kjkvppdmk)” loop or “[while](#heading=h.55s0w9n1v8k2)” loop.

### If statement

"if" statements specify the conditional execution of multiple branches based on the boolean value of each conditional expression. “if” statements are only valid in imperative block.

```
IfStatement =
    "if" “(” Expression “)” StatementBlock
    { “elseif” “(” Expression “)” StatementBlock }
    [ “else” StatementBlock ]
```


For example:

```
x = 5;
if (x > 10) {
    y = 1;
}
elseif (x > 5) {
    y = 2;
}
elseif (x > 0) {
    y = 3;
}
else {
    y = 4;
}
```

### While statement

A "while" statement repeatedly executes a block until the condition becomes false. “while” statements are only valid in imperative block.

```
WhileStatement = "while" “(” Expression “)” StatementBlock
```


Example:

```
sum = 0;
x = 0;
while (x < 10)
{
    sum = sum + x;
    x = x + 1;
}
// sum == 55
```

### For statements

"for" iterates all values in “in” clause and assigns the value to the loop variable. The expression in “in” clause should return a list; if it is a singleton, it is a single statement evaluation. “for” statements are only valid in imperative block.

```
ForStatement = "for" “(” Identifier “in” Expression “)” StatementBlock
```

Example:

```
sum = 0;
for (x in 1..10)
{
    sum = sum + x;
}
// sum == 55
```

## Language blocks

### Default block

By default, all statements are in a default top block. No return statement is allowed in top block. The execution order of statements in top block is *not* guaranteed to be executed in sequential.

### Imperative block

Imperative block provides a convenient way to use imperative semantics. All statements in imperative block will be executed sequentially. Variables defined in imperative block is mutable. It is not allowed to nest an imperative block inside the other imperative block.

Examples of imperative block:

```
x = 1;

// define an imperative block
y = [Imperative](x)
{
    if (x > 10) {
        return = 3;
    }
    else if (x > 5) {
        return = 2;
    }
    else {
        return = 1;
    }
}

def sum(x)
{
    // define an imperative block inside a function
    return = [Imperative](x)
    {
        s = 0;
        for (i in 1..x)
        {
            s = s + i;
        }
        return = s;
    }
}

[Imperative]
{
    // invalid nested imperative block
    [Imperative]
    {
    }
}
```

## Replication and replication guides

### Replication and replication guide

Replication is a way to express iteration. It applies to a function call when the rank of input arguments exceeds the rank of parameters. In other words, a function may be called multiple times in replication, and the return value from each function call will be aggregated and returned as a list.

There are two kinds of replication:

* Zip replication: for multiple input lists, zip replication is about taking every element from each list at the same position and calling the function; the return value from each function call is aggregated and returned as a list. For example, for input arguments {x1, x2, ..., xn} and {y1, y2, ..., yn}, when calling function f() with zip replication, it is equivalent to {f(x1, y1}, f(x2, y2), ..., f(xn, yn)}. As the lengths of input arguments could be different, zip replication could be

    * Shortest zip replication: use the shorter length.

    * Longest zip replication: use the longest length, the last element in the short input list will be repeated.

	The default zip replication is the shortest zip replication; otherwise need to use replication guide

to specify the longest approach.

* Cartesian replication: it is equivalent to nested loop in imperative block. For example, for input arguments {x1, x2, ..., xn} and {y1, y2, ..., yn}, when calling function f() with cartesian replication and the cartesian indices are {0, 1}, which means the iteration over the first argument is the first loop, and the iteration over the second argument is the nested loop; it is equivalent to {f(x1, y1}, f(x1, y2), ..., f(x1, yn}, f(x2, y1), f(x2, y2), ..., f(x2, yn), ..., f(xn, y1), f(xn, y2), ..., f(xn, yn)}.

Replication guide is used to specify the order of cartesian replication indices; the lower replication guide, the outer loop. If two replication guides are the same value, zip replication will be applied.

```
ReplicationGuide = "<" number [“L”] “>” {“<” number [“L”] “>”}
```

Only integer value is allowed in replication guide. Postfix "L" denotes if the replication is zip replication, then use the longest zip replication strategy. The number of replication guide specifies the nested level. For example, replication guide xs<1><2> indicates the argument should be at least of 2 dimensional and its nested level is 2; it could also be expressed by the following pseudo code:

```
// xs<1><2>
for (ys in xs)
{
    for (y in ys)
    {
        ...
    }
}
```


Example:

```
def add(x: var, y: var)
{
    return = x + y;
}

xs = {1, 2};
ys = {3, 4};
zs = {5, 6, 7};

// use zip replication
// r1 = {4, 6}
r1 = add(xs, ys);

// use the shortest zip replication
// r2 = {6, 8};
r2 = add(xs, zs);

// the longest zip replication should be specified through replication guide.
// the application guides should be the same value; otherwise cartesian
// replication will be applied
// r3 = {6, 8, 9}
r3 = add(xs<1L>, zs<1L>);

// use cartesian replication
// r4 = {{4, 5}, {5, 6}};
r4 = add(xs<1>, ys<2>);

// use cartesian replication
// r5 = {{4, 5}, {5, 6}};
r5 = add(xs<2>, ys<1>);
```

Besides replication for explicit function call, replication and replication guide could also be applied to the following expressions:

1. Binary operators like +, -, *, / and so on. All binary operators in DesignScript can be viewed as a function which accepts two parameters, and unary operator can be viewed as a function which accepts one parameters. Therefore, replication will apply to expression "xs + ys" if “xs” and “ys” are lists.

2. Range expression.

3. Inline conditional expression in the form of "xs ? ys : zs" where “xs”, “ys” and “zs” are lists.

4. Array indexing. For example, xs[ys] where ys is a list. Replication could apply to array indexing on the both sides of assignment expression. Note replication does not apply to multiple indices.

### Function dispatch rule for replication and replication guide

Using zip replication or cartesian replication totally depends on the specified replication guide, the types of input arguments and the types of parameters. Because the input argument could be a heterogenous list, the implementation will compute which replication combination will generate the shortest type conversion distance.

Note if argument is jagged list, the replication result is undefined.

Formally, for a function "f(x1: t1, x2: t2, ..., xn: tn)" and input arguments “a1, a2, ..., an”, function dispatch rule is:

1. Get a list of overloaded function f() with same number of parameters. These functions are candidates.

2. If there are replication guides, they will be processed level by level. For example, for function call f(as<1><1>, bs, cs<1><2>, ds<2><1L>), there are two levels of replication guides.

3. For each level, sort replication guides in ascendant order. If replication guide is less than or equal to 0, this replication guide will be skipped (it is a stub replication guide).

	1. For each replication guide, if it appears in multiple arguments, zip replication applies. By default using shortest lacing. If any replication guide number has suffix "L", longest lacing applies.
	2. Otherwise cartesian replication applies.
	3. Repeat step b until all replication guides have been processed.

4. Repeat step a until all replication levels have been processed.

5. For this example, following replications will be generated:

	1. Zip replication on as, cs
	2. Cartesian replication on ds
	3. Zip replication on as, ds
	4. Cartesian replication on ds

3. After the processing of replication guide, the rank of each input argument is computed: r1 = rank(a1), r2 = rank(a2), ..., rn = rank(an); for each rank, update it to r = r - <number of replication guide on argument>. The final list {r1, r2, ..., rn} is called a reduction list, each reduction value represents a possible maximum nested loop on the corresponding argument.  

4. Based on this reduction list, compute a combination of reduction list whose element value is less than or equal to the corresponding reduction value in base reduction list. For each reduction list {r1, r2, ..., rn}, iteratively do the following computation to generate replications:

	1. For any ri > 0, ri = ri - 1. If there are multiple reductions whose values are larger than or equal to 1, zip replication applies; otherwise cartesian replication applies.

5. Combine the replications generated on step 3 and step 4, based on the input arguments and the signature of candidate functions, choose the best matched function and best replication strategy. During the process, if the type of parameter and the type of argument are different, the type distance score will be calculated.

## Built-in functions

### Types

##### `TypeOf(value : var[]..[]) : string`

Get a `string` representation of the type of a value.

Examples:

```
a = 1;
b = TypeOf( a ); // "number"
```

```
a = {};
b = TypeOf( a ); // "table"
```

### Dictionaries

#### Modification

##### `Append(table : var[]..[], value: var[]..[]) : var[]..[] `

`Append` creates a new `table` with a new element inserted at the end. If the `table` is not array-like, returns an `error`.

Examples:

```
a = {1, 2, 3};
b = Append(a, 4); // {1,2,3,4}
```

##### `Set(table : var[]..[], key : var, value : var) : var[]..[]`

`Set` sets a key in a `table`, returning a new `table`. If the key is not present, it is added. If the key is not a non-negative integer `number` or `string`, returns an `error`.

Examples:

```
a = {1, 2, 3};
b = Set(a, 0, 10); // {10,2,3}
```

```
a = {"foo" : 1};
b = Set(a, "bar", 2); // {"foo" : 1, "bar" : 2}
```

##### `Remove(table : var[]..[], index: int) : var[]..[]`

`Remove` removes the value at the specified key of the `table`. If the key is not present, returns the `table` unmodified.

Examples:

```
a = {1, 2, 3};
b = Remove(a, 0); // {1 : 2, 2 : 3}
```

```
a = {"foo" : "bar"};
b = Remove(a, "foo"); // {}
```

```
a = {};
b = Remove(a, "foo"); // {}
```

#### Query

##### `Count(table : var[]..[]) : number`

Returns the number of elements in the specified `table`.

Examples:

```
a = {1, 2, 3};
b = Count(a); // 3
```

```
a = {"foo" : 1, 0 : 3};
b = Count(a); // 3
```

##### `Keys(table : var[]..[]) : var[]`

Gets all keys from the specified `table` and returns them as a list-like `table`. The keys could be strings or numbers. The order the keys are provided is not defined.

Examples:

```
a = {1, 2, 3};
b = Keys(a); // {0,1,2}
```

```
a = {"foo" : 1, 0 : 3};
b = Keys(a); // {"foo", 0}
```

##### `Values(table : var[]..[]) : var[]`

Gets all values stored in the specified `table`. The values could be of any type. The order the values are provided is not defined.

Examples:

```
a = {1, 2, 3};
b = Keys(a); // {1, 2, 3}
```

```
a = {"foo" : 1, 0 : 3};
b = Keys(a); // {"foo", 0}
```

### Other

##### `ToString(object: var[]..[])`

Returns object in string representation.

Examples:

```
a = {1, 2, 3};
c = ToString(a, b); // "{1, 2, 3}"
```

```
a = {"foo" : 1, 0 : 3};
b = ToString(a); // "{"foo" : 1, 0 : 3}"
```

```
a = 1;
b = ToString(a); // "1"
```
