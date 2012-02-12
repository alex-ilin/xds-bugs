<* MAIN+ *>
MODULE Test;

(* ------------------------------------------------------------------------
 * (C) 2010 by Alexander Iljin
 * ------------------------------------------------------------------------ *)

IMPORT
   B;

VAR
   obj: B.Object;
   st : B.SomeType;
BEGIN
   st.obj.Init; (* compilation error: field "Init" is not exported *)
   NEW (obj);
   obj.Init; (* compilation error: field "Init" is not exported *)
END Test.
