(* Why is the assignment below impossible, although the comparison works? *)
<* NOOPTIMIZE+ *> (* This is to avoid constant check elimination. *)
<* MAIN+ *>
MODULE Test;

IMPORT
   Definition, Out, SYSTEM;

VAR
   fmt: Definition.FORMAT;
BEGIN
   (* The SYSTEM.VAL version works as expected. *)
   fmt := SYSTEM.VAL (Definition.FORMAT, Definition.FIF_UNKNOWN);
   (* But the following line would not compile (E122 expression out of bounds) *)
   fmt := Definition.FIF_UNKNOWN;
   (* The comparison below is compiled without any complaints. *)
   IF fmt = Definition.FIF_UNKNOWN THEN
      Out.String ('Constant check 1: OK.');
      Out.Ln;
   ELSE
      Out.String ('Constant check 1: FAILED.');
      Out.Ln;
   END;
END Test.
