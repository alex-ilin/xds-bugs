<*+main*> (* This marks the main module of a program or library.            *)
<*heaplimit="0"*> (* Automatic heap size. Set other values to see effect.   *)

MODULE Test;

(* ------------------------------------------------------------------------
 * (C) 2011 by Alexander Iljin
 * ------------------------------------------------------------------------ *)

IMPORT oberonRTS, Out;

TYPE
   Chain = POINTER TO ChainDesc;
   ChainDesc = RECORD
      (* data size is 1 MByte minus pointer variable size *)
      data: ARRAY 1024 * 1024 DIV SIZE (LONGINT) - 1 OF LONGINT;
      next: Chain;
   END;

PROCEDURE CheckMaxHeapSize ();
(* Output the number of megabytes that were successfully allocated in heap.
 * The whole chain of allocated blocks stays rooted in the 'root' variable.
 * This test shows that it's impossible to allocate more than 1 Gb of heap
 * in XDS v2.51. The number goes up to 1066 Mb, while the expected limit would
 * be around 2 Gb on 32-bit systems. *)
VAR
   root, new: Chain;
   i: INTEGER;
BEGIN
   root := NIL;
   new := NIL;
   NEW (root);
   root.next := NIL;
   i := 1;
   Out.Int (i, 0);
   Out.Char (' ');
   LOOP
      NEW (new);
      new.next := root;
      root := new;
      INC (i);
      Out.Int (i, 0);
      Out.Char (' ');
   END;
END CheckMaxHeapSize;

PROCEDURE CheckCollector ();
(* The newly allocated blocks are not rooted in any global variable. The local
 * variable 'root' references only one block at a time, and oberonRTS.Collect
 * is called after every allocation, so the heap use does not grow, and the
 * procedure never stops. *)
VAR
   root: Chain;
   i: INTEGER;
BEGIN
   root := NIL;
   NEW (root);
   root.next := NIL;
   i := 1;
   LOOP
      NEW (root.next);
      root := root.next;
      INC (i);
      oberonRTS.Collect;
   END;
END CheckCollector;

BEGIN
   ASSERT (SIZE (ChainDesc) = 1024*1024, 20);
   Out.Open;
   CheckMaxHeapSize;
   CheckCollector;
END Test.
