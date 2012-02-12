(* Adding <* PROCINLINE- *> removes the bug *)
MODULE BugHere;

IMPORT
  Out, Disp:=Display;

TYPE
  Field = POINTER TO RECORD
    Vz, Vr, SqrV, weight: Disp.ArrayPtr;
  END;
  Fields = POINTER TO ARRAY OF Field;

  PropertiesDesc = RECORD (Disp.PropertiesDesc)
    new: Fields;
  END;
  Properties = POINTER TO PropertiesDesc;

VAR
  areas: POINTER TO ARRAY OF CHAR;

PROCEDURE NewField (AreaIndex: LONGINT): Field;
  VAR
    f: Field;
  BEGIN
    (* Adding calls to Disp.String makes the bug magically disappear. Remove one or both calls
     * to make the bug reappear. *)
    Disp.String(20, 20, '', 0);                     (* Another invalid location error in optimized code is removed by this call *)
    NEW(f);
    f.Vz := Disp.NewArray(AreaIndex, 0);            (* The crash happens in this assignment *)
    f.Vr := Disp.NewArray(AreaIndex, 0);
    Disp.String(20, 20, '', 0);                     (* Another invalid location error in optimized code is removed by this call *)
    f.SqrV := Disp.NewArray(AreaIndex, 0);
    f.weight := Disp.NewArray(AreaIndex, 0);

    (* The 'invalid location' trap in the above code happens due to an optimizer bug, it does not
     * happen in a less optimized version of the same code, i.e. it is triggered by a combination
     * of compiler options. The trap only happens if Disp.String calls are removed. Disassembly
     * shows that 'invalid location' is the attempt to do "mov [edx], eax", but the value of EDX
     * is 1, and not a stored address due to the bug of the code generator. Here is a relevant
     * piece of disassembly:
call    Disp_NewArray
mov     ecx, [esp+10h]  ; pay no attention to this line
push    0               ; THE BAD PUSH
mov     edx, [esp+1Ch]  ; Get local variable 'f' from stack
push    0
mov     [edx], eax      ; f.Vz := 'result of Disp_NewArray'
     * The 'push' commands are pushing parameters for a next call to Disp_NewArray, while EAX
     * contains the result of the previous call. The result must be assigned to f.Vz. The 'f'
     * pointer is stored in stack at the shift of 1Ch. But then "THE BAD PUSH" adds another
     * value to the stack, changes ESP, and the new correct shift is now 20h. Therefore when we
     * retrieve the 'f' pointer from stack to EDX (mov edx, [esp+1Ch]) we use the wrond shift.
     * So, instead of the pointer value we get an adjacent variable, which happens to have the
     * value 1. Trying to subsequently write data at the 0x01 address (mov [edx], eax) is the
     * reason for the 'invalid location' trap.
     * The solution would be either to swap "the bad push" with "mov edx, [esp+1Ch]" or to update
     * the shift value and generate "mov edx, [esp+20h]" instead.
     *)

    RETURN f
  END NewField;

PROCEDURE NewFields (): Fields;
  VAR
    f: Fields;
    i, AreaCount: LONGINT;
  BEGIN
    AreaCount := LEN(areas^); (* replacing LEN(areas^) with 1 removes the bug *)
    NEW(f, AreaCount);
    FOR i := 0 TO AreaCount - 1 DO (* removing FOR removes the bug *)
      f[i] := NewField(i);
    END;
    RETURN f
  END NewFields;

PROCEDURE Init* ();
  VAR
    p: Properties;
  BEGIN
    (* The use of Out module makes no effect on the bug reproduction, it only helped localize
     * the bug in a bigger program and reduce the code base to a minimum. *)
    Out.String('Start Init');
    NEW(p);
    Disp.InitProperties(p); (* the procedure is empty, but removing it removes the bug *)
    p.new := NewFields();   (* manually inlining NewFields removes the bug *)
    Out.String(' - End Init');
  END Init;

BEGIN
  NEW(areas, 1);
END BugHere.
