<* NOOPTIMIZE+ *> (* This option is here to prevent removing the ASSERTs: 
                   * compiler thinks that the conditions are TRUE and 
                   * eliminates the checks. *)
<* MAIN+ *>
MODULE Test;

(* ------------------------------------------------------------------------
 * (C) 2009 by Alexander Iljin
 * ------------------------------------------------------------------------ *)

IMPORT
   SYSTEM, Out;

PROCEDURE ReproduceBug ();
TYPE
   LowHigh = RECORD
      low, high: INTEGER;
   END;
VAR
   lh: LowHigh;
   longLow, longHigh: LONGINT;
BEGIN
   lh.high := 2000H;
   lh.low  := 1000H;
   ASSERT (lh.high = 2000H, 20);
   ASSERT (lh.low  = 1000H, 21);
   longHigh := lh.high;                      (* this works                   *)
   longLow  := SYSTEM.VAL (LONGINT, lh.low); (* same thing, but doesn't work *)
   ASSERT (longHigh = 2000H, 60);
   ASSERT (longLow  = 1000H, 61);      (* error is here: longLow = 20001000H *)
   Out.String ('Test passed.');
END ReproduceBug;

BEGIN
   ReproduceBug;
END Test.
