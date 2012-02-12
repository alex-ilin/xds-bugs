MODULE Test;

(* ------------------------------------------------------------------------
 * (C) 2011 by Alexander Iljin
 * ------------------------------------------------------------------------ *)

VAR
   tmp: SHORTINT; (* any integer type will do *)
BEGIN
   INC(tmp, LONG(1000000)); (* Compiler breaks with error F450: "compilation
                             * aborted: invalid case in CASE statement".
                             * Remove "LONG" and it will work. *)
END Test.
