<* GENPTRINIT+ *> (* Make sure local pointers are initialized. *)
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
   ptr: POINTER TO ARRAY OF CHAR;
BEGIN
   (* Since GENPTRINIT is ON, the 'ptr' variable must be set NIL, but that
    * does not happen. The compiler thinks that there will be an 'invalid
    * location' trap and simply generates a call to the trap routine. This is
    * very strange, since we don't even dereference the pointer here, so there
    * is no reason for that kind of error. *)
   IF ptr # NIL THEN
      Out.String('Error!');
   ELSE
      Out.String('Test passed.');
   END;
END InitModule;

BEGIN
   InitModule;
END Test.
