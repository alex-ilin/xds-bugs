<* PROCINLINE+ *> (* Allow procedure inlining. *)
<* MAIN+ *>
MODULE Test;

(* ------------------------------------------------------------------------
 * (C) 2012 by Alexander Iljin
 * ------------------------------------------------------------------------ *)

IMPORT
   Out;

PROCEDURE InitModule; (* This procedure will be inlined. *)
VAR
   wr: RECORD
      int: INTEGER; (* any variable will do *)
   END;
BEGIN
   (* The following code results in compiler crash with message "compilation
    * aborted: ASSERT(FALSE,9999) at line 133 of formOMF.ob2". *)
   IF wr.int # 0 THEN
      Out.String('Test passed!');
   END;
END InitModule;

BEGIN
   InitModule;
END Test.
