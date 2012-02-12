<* O2EXTENSIONS+ *> (* Allow string concatenation for the constants below.    *)
<* MAIN+ *>
MODULE Test;

(* ------------------------------------------------------------------------
 * (C) 2009 by Alexander Iljin
 * ------------------------------------------------------------------------ *)

CONST
   Str1 = 'some string' + 09X; (* this is compiled, no error *)
   Tab = 09X;
   Str2 = 'some string' + Tab; (* same thing, but produces a compilation error:
                                * incompatible types:
                                *   "string constant (SS)"
                                *   "CHAR"
                                *)

END Test.
