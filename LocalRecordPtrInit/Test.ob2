<* GENPTRINIT+ *> (* Make sure local pointers are initialized, including RECORD fields. *)
<* PROCINLINE+ *> (* Allow procedure inlining. *)
<* MAIN+ *>
MODULE Test;

(* ------------------------------------------------------------------------
 * (C) 2012 by Alexander Iljin
 * ------------------------------------------------------------------------ *)

IMPORT
   Out;

TYPE
   (* A stack-based RECORD type with a POINTER field. *)
   Writer = RECORD
      ptr: POINTER TO ARRAY OF CHAR; (* any pointer type will do *)
   END;

PROCEDURE InitModule; (* This procedure will be inlined. *)
VAR
   wr: Writer;
BEGIN
   (* Since GENPTRINIT is ON, the field wr.ptr must be set NIL, but that
    * does not happen if the procedure is inlined. The compiler simply does 
    * not generate the initialization code (typically that would be a "push 0"
    * instruction), and whatever is in the stack is left in the pointer field.
    * In real-life programs this leads to random 'invalid location' traps. *)
   IF wr.ptr # NIL THEN
      Out.String('Error!');
   ELSE
      Out.String('Test passed.');
   END;
END InitModule;

BEGIN
   InitModule;
END Test.
