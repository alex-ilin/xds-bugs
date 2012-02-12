MODULE Test;

(* ------------------------------------------------------------------------
 * (C) 2010 by Alexander Iljin
 * ------------------------------------------------------------------------ *)

CONST
   c = LONG (0 + 1); (* This makes the compiler abort with "invalid location".
                      * The value of the constant does not matter, and neither
                      * does its name. Just as soon as there is an expression
                      * inside the LONG: +, -, *. *)

END Test.
