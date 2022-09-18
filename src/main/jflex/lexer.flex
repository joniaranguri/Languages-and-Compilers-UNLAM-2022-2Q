package lyc.compiler;

import java_cup.runtime.Symbol;
import lyc.compiler.ParserSym;
import lyc.compiler.model.*;
import java.math.BigInteger;
import static lyc.compiler.constants.Constants.*;

%%

%public
%class Lexer
%unicode
%cup
%line
%column
%throws CompilerException
%eofval{
  return symbol(ParserSym.EOF);
%eofval}

%{
  private Symbol symbol(int type) {
    return new Symbol(type, yyline, yycolumn);
  }
  private Symbol symbol(int type, Object value) {
    return new Symbol(type, yyline, yycolumn, value);
  }
%}

LineTerminator = \r|\n|\r\n
InputCharacter = [^\r\n]
Identation =  [ \t\f]

If = "if"
Else = "else"
Begin = "begin"
End = "end"
For = "for"
Write = "write"
Read = "read"
Init = "init"
Equal = "=="
Plus = "+"
Mult = "*"
Sub = "-"
Div = "/"
Assig = ":="
Higher = ">>"
Lower = "<<"
HigherEqual = ">="
LowerEqual = "<="
And = "and"
Or = "or"
Not = "not"
Distinct  = "!="
True_Bool = "true"
False_Bool = "false"
Increment = ":+"
Decrement = ":-"
Semicolon = ";"
OpenBracket = "("
CloseBracket = ")"
OpenCurlyBracket = "{"
CloseCurlyBracket = "}"

Letter = [a-zA-Z]
Digit = [0-9]
Dot = "."

WhiteSpace = {LineTerminator} | {Identation}

Comment = "/*" ~ "*/"

Identifier = {Letter} ({Letter}|{Digit})*
NumberConstant = {Digit}+
NumberOptionalConstant = {Digit}*

// DataTypeValues
FloatConstant = {Sub}? ({NumberConstant} {Dot} {NumberOptionalConstant} | {NumberOptionalConstant} {Dot} {NumberConstant})
IntegerConstant = {Sub}? {NumberConstant}
StringConstant =  \"({Letter}|{NumberConstant})*\"

%%


/* keywords */

<YYINITIAL> {
  /* operators */
  {Plus}                                    { return symbol(ParserSym.PLUS); }
  {Sub}                                     { return symbol(ParserSym.SUB); }
  {Mult}                                    { return symbol(ParserSym.MULT); }
  {Div}                                     { return symbol(ParserSym.DIV); }
  {Assig}                                   { return symbol(ParserSym.ASSIG); }
  {OpenBracket}                             { return symbol(ParserSym.OPEN_BRACKET); }
  {CloseBracket}                            { return symbol(ParserSym.CLOSE_BRACKET); }
  {OpenCurlyBracket}                        { return symbol(ParserSym.OPEN_CURLY_BRACKET); }
  {CloseCurlyBracket}                       { return symbol(ParserSym.CLOSE_CURLY_BRACKET); }
  {Equal}                                   {return symbol((ParserSym.EQUAL));}
  {Higher}                                  {return symbol((ParserSym.HIGHER));}
  {Lower}                                   {return symbol((ParserSym.LOWER));}
  {HigherEqual}                             {return symbol((ParserSym.HIGHER_EQUAL));}
  {LowerEqual}                              {return symbol((ParserSym.LOWER_EQUAL));}
  {And}                                     {return symbol((ParserSym.AND));}
  {Or}                                      {return symbol((ParserSym.OR));}
  {Not}                                     {return symbol((ParserSym.NOT));}
  {Distinct}                                {return symbol((ParserSym.DISTINCT));}
  {True_Bool}                               {return symbol((ParserSym.TRUE_BOOL));}
  {False_Bool}                              {return symbol((ParserSym.FALSE_BOOL));}
  {Increment}                               {return symbol((ParserSym.INCREMENT));}
  {Decrement}                               {return symbol((ParserSym.DECREMENT));}
  {Semicolon}                               {return symbol((ParserSym.SEMICOLON));}



  /* reserved words */

  {If}                                      { return symbol(ParserSym.IF);}
  {Else}                                    { return symbol(ParserSym.ELSE);}
  {Begin}                                   { return symbol(ParserSym.BEGIN);}
  {End}                                     { return symbol(ParserSym.END);}
  {For}                                     { return symbol(ParserSym.FOR);}
  {Write}                                   { return symbol(ParserSym.WRITE);}
  {Read}                                    { return symbol(ParserSym.READ);}
  {Init}                                    { return symbol(ParserSym.INIT);}

  {Comment}	                                { /* do nothing */ }

  /* identifiers */
  {Identifier}                              { return symbol(ParserSym.IDENTIFIER, yytext()); }

  /* DataTypeValues */
  {FloatConstant}                           {
                                             final Double floatConstantValue = Double.parseDouble(yytext());
                                             final boolean isValidPositiveRange = floatConstantValue <= FLOAT_RANGE_POS;
                                             final boolean isValidNegativeRange = floatConstantValue >= FLOAT_RANGE_NEG;
                                             if (isValidPositiveRange && isValidNegativeRange)
                                                 return symbol(ParserSym.FLOAT_CONSTANT, yytext());

                                             String errorMessage = "La constante [" + yytext() + "] esta por encima del limite de los flotantes. (Se obtuvo " + floatConstantValue + ", maximo permitido: " + FLOAT_RANGE_POS + ")";
                                             if(!isValidNegativeRange)
                                                 errorMessage = "La constante [" + yytext() + "] esta por debajo del limite de los flotantes. (Se obtuvo " + floatConstantValue + ", mínimo permitido: " + FLOAT_RANGE_NEG + ")";

                                             throw new InvalidFloatException(errorMessage);
                                             }

  {IntegerConstant}                           {
                                               final BigInteger integerConstantValue = new BigInteger(yytext());
                                               final boolean isValidPositiveRange = integerConstantValue.compareTo(BigInteger.valueOf(INT_RANGE_POS)) != 1;
                                               final boolean isValidNegativeRange = integerConstantValue.compareTo(BigInteger.valueOf(INT_RANGE_NEG)) != -1;

                                               if (isValidPositiveRange && isValidNegativeRange)
                                                   return symbol(ParserSym.INTEGER_CONSTANT, yytext());

                                               String errorMessage = "La constante [" + yytext() + "] esta por encima del limite de los flotantes. (Se obtuvo " + integerConstantValue + ", maximo permitido: " + INT_RANGE_POS + ")";
                                               if(!isValidNegativeRange)
                                                   errorMessage = "La constante [" + yytext() + "] esta por debajo del limite de los flotantes. (Se obtuvo " + integerConstantValue + ", mínimo permitido: " + INT_RANGE_NEG + ")";

                                               throw new InvalidIntegerException(errorMessage);
                                               }

  {StringConstant}                           {
                                             final String stringConstant = new String(yytext());
                                             if (stringConstant.length() - 2 <= STRING_RANGE)
                                                 return symbol(ParserSym.STRING_CONSTANT, yytext());

                                             String errorMessage = "La constante [" + yytext() + "] excede el largo permitido para un string. (Se obtuvo una cadena de tamaño " + stringConstant.length() + ", maximo permitido: " + STRING_RANGE + ")";

                                             throw new InvalidLengthException(errorMessage);
                                             }

  /* whitespace */
  {WhiteSpace}                   { /* ignore */ }
}


/* error fallback */
[^]                              { throw new UnknownCharacterException(yytext()); }
