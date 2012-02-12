MODULE A;

(* ------------------------------------------------------------------------
 * (C) 2010 by Alexander Iljin
 * ------------------------------------------------------------------------ *)

TYPE
   Object* = POINTER TO ObjectDesc;
   ObjectDesc* = RECORD
   END;

PROCEDURE (obj: Object) Init*; (* the method Init is introduced, exported *)
BEGIN
END Init;

END A.
