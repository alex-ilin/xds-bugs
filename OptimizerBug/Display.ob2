<* WOFF301+ *>
MODULE Display;

TYPE
  ArrayPtr * = POINTER TO ARRAY OF CHAR;

  PropertiesDesc * = RECORD
  END;
  Properties * = POINTER TO PropertiesDesc;

PROCEDURE InitProperties * (p:Properties);
BEGIN
END InitProperties;

PROCEDURE String * (x, y: LONGINT; s: ARRAY OF CHAR; MinLength: LONGINT);
BEGIN
END String;

PROCEDURE NewArray * (AreaIndex: LONGINT; default: LONGREAL): ArrayPtr;
BEGIN
  RETURN NIL
END NewArray;

END Display.
