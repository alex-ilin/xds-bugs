<*+main*> (* This marks the main module of a program or library.            *)
<*heaplimit="1000000"*> (* Maximum heap size should be set in the main module,
because the changes do not take effect until the main module is recompiled. *)

MODULE Test;

(* ------------------------------------------------------------------------
 * (C) 2010 by Alexander Iljin
 * ------------------------------------------------------------------------ *)

IMPORT Out, SYSTEM;

(* This bug was originally discovered by E.Temirgaleev in BlackBox Component
 * Builder and reported here: http://forum.oberoncore.ru/viewtopic.php?f=16&t=2854
 * I was going to reproduce it to see if the same bug exists in the XDS
 * compiler, but it was impossible due to the compiler crash on LONG (expr).
 * When and if that bug gets fixed, then the updated compiler should be subjected
 * to this test.
 * The point of the test is it is expected that c2 is a LONG constant, since c1
 * used in the expression is LONG. But in fact, BlackBox compiler makes c2
 * an INTEGER constant based on the fact that the expression value fits INTEGER.
 *)

PROCEDURE ReproduceBug;
CONST
   c1 = LONG (2);
   c2 = c1 * 1024;
   c3 = LONG (c1 * 1024);
VAR
   a: INTEGER;
   x: LONGINT;
BEGIN
   a := MAX (INTEGER);
   x := c1 * a; Out.Int (x, 0); Out.Ln;
   x := c2 * a; Out.Int (x, 0); Out.Ln;
   x := c3 * a; Out.Int (x, 0); Out.Ln;
END ReproduceBug;

BEGIN
   Out.Open;
   ReproduceBug;
   Out.Ln;
END Test.
