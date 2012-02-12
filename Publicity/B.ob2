MODULE B;

(* ------------------------------------------------------------------------
 * (C) 2010 by Alexander Iljin
 * ------------------------------------------------------------------------ *)

IMPORT
   A;

TYPE
   Object* = POINTER TO ObjectDesc;
   ObjectDesc = RECORD (A.ObjectDesc)
   END;
   SomeType* = RECORD
      obj-: ObjectDesc;
   END;

PROCEDURE (obj: Object) Init; (* the method Init is redefined, NOT exported *)
BEGIN
END Init;

(* The compiler must complain about Init not being exported, like it would
complain if we add the export mark after the ObjectDesc type in this module.
ObjectDesc is still exported, albeit indirectly, via the exported pointer type.
There are other ways of indirect export that must be handled as well, e.g. as
part of a record:
TYPE
   SomeType* = RECORD
      obj-: ObjectDesc;
   END;

The point is that the Init method, even if not exported, is still accessible via
the base object's Init method. So, there is no point in allowing it not to be
exported. Hence, all redefined methods must be exported if ultimately they are
derived from a class in a different module. *)

END B.
