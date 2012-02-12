<* O2EXTENSIONS+ *> (* This allows applying a type guard to a procedure result. *)
<* MAIN+ *>
MODULE Test;

IMPORT Out;

TYPE
   Ansector = POINTER TO AnsectorDesc;
   AnsectorDesc = RECORD
   END;

   Descendant = POINTER TO DescendantDesc;
   DescendantDesc = RECORD (AnsectorDesc)
   END;

VAR
   desc: Descendant;
   counter: INTEGER;

PROCEDURE GetThis (): Ansector;
VAR res: Descendant;
BEGIN
   INC(counter);
   NEW (res);
   RETURN res
END GetThis;

BEGIN
   counter := 0;
   desc := GetThis ()(Descendant);
   (* Although the GetThis procedure is called only once, it will be executed
    * twice because of the type guard bug. *)
   CASE counter OF
   | 1: Out.String('Test passed.'); 
   | 2: Out.String('Test failed!'); 
   END;
END Test.
