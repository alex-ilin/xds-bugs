# Ошибки компилятора Native XDS-x86 Modula-2/Oberon-2

[Компилятор XDS](http://www.excelsior.ru/products/xds.html) хороший, но он ошибается. Иногда просто не может что-то переварить, а иногда и создаёт программу, не соответствующую исходнику. С первым можно как-то мириться, ведь ошибка видна уже в процессе компиляции, и можно попытаться написать по-другому. А во втором случае приходится проявлять особую осторожность: из-за нестабильной природы ошибок здесь не всегда поможет даже тестирование.

За время работы с XDS (с 2007 по 2012 год) я повстречал несколько ошибок. Для всех из них я смог создать проекты минимального размера - такие, чтобы присутствие именно этой конкретной ошибки стало очевидно и надёжно воспроизводилось. Этот набор тестов я и предлагаю вашему вниманию. С помощью этого набора я оцениваю прогресс, когда выходит очередная версия XDS. Правда, понятно, что такой метод оценивания не учитывает привнесённые ошибки новых версий, которые ещё только предстоит найти. Да и невозможность воспроизвести ошибку иной раз может не означать, что ошибка исправлена. Может быть, она просто надёжнее спряталась. К сожалению, разработчики XDS не радуют подробной отчётностью о проделанной работе, поэтому и приходится изобретать свои способы оценки.

Кроме того, учёт найденных сбоев просто позволяет следовать принципу "знай свой инструмент", и учит избегать тех или иных "опасных" (в смысле ненадёжности) конструкций, опций и т. п.

Все сбои воспроизводятся в свежеустановленном XDS. Если требуются какие-либо дополнительные опции, то они включены в исходный текст модулей в виде директив компилятора <*…*>. Консольная выдача записана с помощью последней версии XDS, в которой удалось воспроизвести проблему. Если в какой-то версии ошибка не проявляется, об этом указано в комментариях.

## Содержание

1.  [Выводы](#Results)
2.  Ошибки компиляции
    *   [Enum(-1)](#Enum(-1))
    *   [LocalRecordAssert](#LocalRecordAssert)
    *   [LongInvalidCase](#LongInvalidCase)
    *   [LongInvalidLocation](#LongInvalidLocation)
    *   [StrPlusChar](#StrPlusChar)
3.  Ошибки кодогенерации
    *   [LocalPtrInit](#LocalPtrInit)
    *   [LocalRecordPtrInit](#LocalRecordPtrInit)
    *   [OptimizerBug](#OptimizerBug)
    *   [RecordUnpack](#RecordUnpack) - не воспроизводится в версии 2.60 beta
    *   [TypeGuard](#TypeGuard) - не воспроизводится в версии 2.60 beta

## <a name="Results">1\. Выводы</a>

В самом деле, почему бы не начать сразу с выводов? Как видно из последующих примеров, директиву **`PROCINLINE` лучше отключить** и не включать. Заинлайненые процедуры не дружат с локальными указателями, будь то [простые переменные](#LocalPtrInit) или [поля `RECORD`'ов](#LocalRecordPtrInit). Встречаются и более [серьёзные проблемы](#OptimizerBug), пропадающие при отключении директивы `PROCINLINE`.

Все эти найденные ошибки - это не повод сказать "плохой компилятор". Наоборот, компилятор весьма неплох. Просто иной раз вылетает исключение "invalid location" на пустом месте, и не знаешь, что с этим делать и как исправлять. А когда ошибка локализована, и найдена конкретная причина, то появляется определённость. И тогда понимаешь: отдельные мелкие недоработки есть, но их мало, а в остальном-то всё прекрасно работает!

## 2\. Ошибки компиляции

*   ### <a name="Enum(-1)">Enum(-1)</a>

    #### Исходные тексты модулей для проверки

    Для этого теста нам понадобятся два модуля: `Definition.def` и `Test.ob2`.

    ```
    <* ENUMSIZE="4" *><* M2EXTENSIONS+ *>
    DEFINITION MODULE ['StdCall'] Definition;

    IMPORT SYSTEM;

    TYPE
      FORMAT = (
        FIF_BMP,
        FIF_ICO
      );

    CONST
      FIF_UNKNOWN = SYSTEM.CAST (FORMAT, 0FFFFFFFFh);

    END Definition.
    ```

    ```
    (* **Why is the assignment below impossible, although the comparison works?** *)
    <* NOOPTIMIZE+ *> (* This is to avoid constant check elimination. *)
    <* MAIN+ *>
    MODULE Test;

    IMPORT
       Definition, Out, SYSTEM;

    VAR
       fmt: Definition.FORMAT;
    BEGIN
       (* **The SYSTEM.VAL version works as expected.** *)
       fmt := SYSTEM.VAL (Definition.FORMAT, Definition.FIF_UNKNOWN);
       (* **But the following line would not compile (E122 expression out of bounds)** *)
       fmt := Definition.FIF_UNKNOWN;
       (* **The comparison below is compiled without any complaints.** *)
       IF fmt = Definition.FIF_UNKNOWN THEN
          Out.String ('Constant check 1: OK.');
          Out.Ln;
       ELSE
          Out.String ('Constant check 1: FAILED.');
          Out.Ln;
       END;
    END Test.
    ```

    #### Результат запуска компилятора

    ```
    >xc =make Test.ob2 && Test.exe
    O2/M2 development system **v2.60** TS  (c) 1991-2011 Excelsior, LLC. (build 16.11.2011)
    **XDS Modula-2 v2.40 [x86, v1.50] - build 16.11.2011**
    Compiling "Definition.def"
    no errors, no warnings, lines   15, time  0.00, new symfile
    XDS Oberon-2 v2.40 [x86, v1.50] - build 16.11.2011
    Compiling "test.ob2"

    * [test.ob2 15.11 E122]
    * **expression out of bounds
       fmt := $Definition.FIF_UNKNOWN;**
    errors  1, no warnings, lines   24, time  0.02
    -------------------------------------------------------------------
    files: 2  errors: 1(0)  lines 39  time: 0:00  speed 10000 l/m
    ```

    #### Комментарий

    Странность здесь заключается в том, что константа `Definition.FIF_UNKNOWN` по определению имеет тип `Definition.FORMAT`, но при этом не может напрямую быть присвоена переменной `fmt` того же типа. Если же с помощью `SYSTEM.VAL` привести тип к тому, что и так имеется, то присваивание почему-то работает. Возникает вопрос: раз нужно приведение типа, то имеет ли константа изначально тип `FORMAT` или нет? Тот факт, что `IF` компилируется без вопросов, говорит о том, что таки да, тип тот самый, иначе была бы ошибка несовпадения типов при сравнении. Но почему же не компилируется присваивание?

*   ### <a name="LocalRecordAssert">LocalRecordAssert</a>

    #### Исходный текст модуля для проверки

    ```
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
       wr: RECORD
          int: INTEGER; (* Any variable will do *)
       END;
    BEGIN
       (* **The following code results in compiler crash with message "compilation**
        * **aborted: ASSERT(FALSE,9999) at line 133 of formOMF.ob2".** *)
       IF wr.int # 0 THEN
          Out.String('Test passed!');
       END;
    END InitModule;

    BEGIN
       InitModule;
    END Test.
    ```

    #### Результат запуска компилятора

    ```
    >xc =make Test.ob2 && Test.exe
    O2/M2 development system **v2.60** TS  (c) 1991-2011 Excelsior, LLC. (build 16.11.2011)
    **XDS Oberon-2 v2.40 [x86, v1.50] - build 16.11.2011**
    Compiling "Test.ob2"
    Generating Test
    * [Test.ob2 28.04 W330]
    * function InitModule inlined
       $InitModule;

    * **[*** 0.00 F450]**
    * **compilation aborted: ASSERT(FALSE,9999) at line 133 of formOMF.ob2**
    ```

    #### Комментарий

    Если отключить директиву `PROCINLINE`, то модуль компилируется успешно.

*   ### <a name="LongInvalidCase">LongInvalidCase</a>

    #### Исходный текст модуля для проверки

    ```
    MODULE Test;

    (* ------------------------------------------------------------------------
     * (C) 2011 by Alexander Iljin
     * ------------------------------------------------------------------------ *)

    VAR
       tmp: SHORTINT; (* any integer type will do *)
    BEGIN
       INC(tmp, LONG(1000000)); (* **Compiler breaks with error F450: "compilation**
                                 * **aborted: invalid case in CASE statement".**
                                 * **Remove "LONG" and it will work.** *)
    END Test.
    ```

    #### Результат запуска компилятора

    ```
    >xc Test.ob2
    **XDS Oberon-2 v2.40 [x86, v1.50] - build 16.11.2011**
    Compiling "Test.ob2"

    * **[*** 0.00 F450]**
    * **compilation aborted: invalid case in CASE statement at line 1000 of pcF.ob2**
    ```

*   ### <a name="LongInvalidLocation">LongInvalidLocation</a>

    #### Исходный текст модуля для проверки

    ```
    MODULE Test;

    (* ------------------------------------------------------------------------
     * (C) 2010 by Alexander Iljin
     * ------------------------------------------------------------------------ *)

    CONST
       c = LONG (0 + 1); (* **This makes the compiler abort with "invalid location".**
                          * **The value of the constant does not matter, and neither**
                          * **does its name. Just as soon as there is an expression**
                          * **inside the LONG: +, -, *.** *)

    END Test.
    ```

    #### Результат запуска компилятора

    ```
    >xc Test.ob2
    **XDS Oberon-2 v2.40 [x86, v1.50] - build 16.11.2011**
    Compiling "Test.ob2"

    * **[*** 0.00 F450]**
    * **compilation aborted: invalid location**
    ```

    #### Комментарий

    `LONG здесь` - бессмысленная операция с точки зрения языка Oberon. Я ожидал бы, чтобы компилятор её проигнорировал. Возможно, выдал бы какое-то предупреждение или сообщил об ошибке в данном месте. Сообщение же "compilation aborted: invalid location" говорит о том, что внутри самого компилятора есть ошибка, не позволяющая ему штатно обработать ситуацию.

*   ### <a name="StrPlusChar">StrPlusChar</a>

    #### Исходный текст модуля для проверки

    ```
    <* O2EXTENSIONS+ *> (* Allow string concatenation for the constants below.  *)
    <* MAIN+ *>
    MODULE Test;

    (* ------------------------------------------------------------------------
     * (C) 2009 by Alexander Iljin
     * ------------------------------------------------------------------------ *)

    CONST
       Str1 = 'some string' + 09X; (* **this is compiled, no error** *)
       Tab = 09X;
       Str2 = 'some string' + Tab; (* **same thing, but produces a compilation error:**
                                    * **incompatible types:**
                                    * **  "string constant (SS)"**
                                    * **  "CHAR"**
                                    *)
    END Test.
    ```

    #### Результат запуска компилятора

    ```
    >xc =make Test.ob2 && Test.exe
    O2/M2 development system **v2.60** TS  (c) 1991-2011 Excelsior, LLC. (build 16.11.2011)
    **XDS Oberon-2 v2.40 [x86, v1.50] - build 16.11.2011**
    Compiling "Test.ob2"

    * [Test.ob2 12.25 E029]
    * **incompatible types:
        "string constant (SS)"
        "CHAR"**
       Str2 = 'some string' **$+** Tab; (* same thing, but produces a compilatio...
    errors  1, no warnings, lines   18, time  0.01
    ```

    #### Комментарий

    Не знаю, есть ли действительные причины для этой ошибки, или это просто недоработка. Просто мне такое непоследовательное поведение компилятора кажется странным, поэтому я считаю это ошибкой. Даже если бы константа `Tab` была определена в другом модуле, нет причины запрещать использовать её в выражении.

## 3\. Ошибки кодогенерации

*   ### <a name="LocalPtrInit">LocalPtrInit</a>

    #### Исходный текст модуля для проверки

    ```
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
       (* **Since GENPTRINIT is ON, the 'ptr' variable must be set NIL, but that**
        * **does not happen. The compiler thinks that there will be an 'invalid**
        * **location' trap and simply generates a call to the trap routine. This is**
        * **very strange, since we don't even dereference the pointer here, so there**
        * **is no reason for that kind of error.** *)
       IF ptr # NIL THEN
          Out.String('Error!');
       ELSE
          Out.String('Test passed.');
       END;
    END InitModule;

    BEGIN
       InitModule;
    END Test.
    ```

    #### Результат запуска компилятора

    ```
    >xc =make Test.ob2 && Test.exe
    O2/M2 development system **v2.60** TS  (c) 1991-2011 Excelsior, LLC. (build 16.11.2011)
    **XDS Oberon-2 v2.40 [x86, v1.50] - build 16.11.2011**
    Compiling "Test.ob2"
    Generating Test
    * [Test.ob2 23.07 W304]
    * possibly used before definition "ptr"
       IF $ptr # NIL THEN

    * [Test.ob2 23.11 W915]
    * invalidLocation exception will be raised here
       IF ptr $# NIL THEN

    * [Test.ob2 24.07 W311]
    * unreachable code
          $Out.String('Error!');

    * [Test.ob2 26.07 W311]
    * unreachable code
          $Out.String('Test passed.');

    * [Test.ob2 31.04 W330]
    * function InitModule inlined
       $InitModule;
    no errors, warnings  5, lines   32, time  0.21, new symfile
    New "tmp.lnk" is generated using template "d:/Programs/Dev/XDS/bin/xc.tem"

    XDS Link Version 2.13.3 Copyright (c) Excelsior 1995-2009.
    No errors, no warnings

    #RTS: unhandled exception #3: **invalid location at line 23 of Test.ob2**

    File errinfo.$$ created.

      EAX = 00000001  EBX = 7FFD5000
      ECX = 00000000  EDX = 0044B000
      ESI = 00000000  EDI = 00000000
      EBP = 0006FFB8  ESP = 0006FF7C
      EIP = 00401041
     STACK:
      0006FF7C:  00000003 0040E018 00000017 0040E034
      0006FF8C:  0006FFA4 00092170 00000001 001E8480
      0006FF9C:  003D0900 0040C36A 00000001 00092170
      0006FFAC:  00092198 00000001 00092170 0006FFF0
      0006FFBC:  0006FFE0 0040CB91 7C816FD7 00000000
      0006FFCC:  00000000 7FFD5000 8054A6ED 0006FFC8
      0006FFDC:  89288930 FFFFFFFF 7C839AA8 7C816FE0
      0006FFEC:  00000000 00000000 00000000 0040CB60
    ```

    #### Комментарий

    Если отключить директиву `PROCINLINE`, то тест проходит успешно. Т. е. именно комбинация `PROCINLINE+` и `GENPTRINIT+` приводит к ошибке кодогенерации.

*   ### <a name="LocalRecordPtrInit">LocalRecordPtrInit</a>

    #### Исходный текст модуля для проверки

    ```
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
       (* **Since GENPTRINIT is ON, the field wr.ptr must be set NIL, but that**
        * **does not happen if the procedure is inlined. The compiler simply does**
        * **not generate the initialization code (typically that would be a "push 0"**
        * **instruction), and whatever is in the stack is left in the pointer field.**
        * **In real-life programs this leads to random 'invalid location' traps.** *)
       IF wr.ptr # NIL THEN
          Out.String('Error!');
       ELSE
          Out.String('Test passed.');
       END;
    END InitModule;

    BEGIN
       InitModule;
    END Test.
    ```

    #### Результат запуска компилятора

    ```
    >xc =make Test.ob2 && Test.exe
    O2/M2 development system **v2.60** TS  (c) 1991-2011 Excelsior, LLC. (build 16.11.2011)
    **XDS Oberon-2 v2.40 [x86, v1.50] - build 16.11.2011**
    Compiling "Test.ob2"
    Generating Test
    * [Test.ob2 37.04 W330]
    * function InitModule inlined
       $InitModule;
    no errors, warnings  1, lines   38, time  0.01, new symfile
    New "tmp.lnk" is generated using template "d:/Programs/Dev/XDS/bin/xc.tem"

    XDS Link Version 2.13.3 Copyright (c) Excelsior 1995-2009.
    No errors, no warnings
    **Error!**
    ```

    #### Комментарий

    Отличие от [предыдущего теста](#LocalPtrInit) заключается в том, что здесь неинициализированный указатель находится внутри стековой записи (`RECORD`). Как в и предыдущем случае, если отключить директиву `PROCINLINE`, то тест проходит успешно. Т. е. именно комбинация `PROCINLINE+` и `GENPTRINIT+` приводит к ошибке кодогенерации.

*   ### <a name="OptimizerBug">OptimizerBug</a>

    #### Исходный текст проекта для проверки

    Полный проект [OptimizerBug](/OptimizerBug) состоит из трёх модулей, проектного файла с опциями и двух командных bat-файлов. Для проверки нужно запустить файл `Run.bat`.

    #### Результат запуска проверки

    ```
    >Run.bat
    O2/M2 development system **v2.60** TS  (c) 1991-2011 Excelsior, LLC. (build 16.11.2011)
    Make project "Test.prj"
    **XDS Oberon-2 v2.40 [x86, v1.50] - build 16.11.2011**
    Compiling "Display.ob2"
    no errors, no warnings, lines   24, time  0.01, new symfile
    XDS Oberon-2 v2.40 [x86, v1.50] - build 16.11.2011
    Compiling "BugHere.ob2"
    Generating BugHere
    * [BugHere.ob2 70.15 W330]
    * function NewField inlined
          f[i] := $NewField(i);

    * [BugHere.ob2 84.14 W330]
    * function NewFields inlined
        p.new := $NewFields();   (* manually inlining NewFields removes the ...
    no errors, warnings  2, lines   90, time  0.05, new symfile
    XDS Oberon-2 v2.40 [x86, v1.50] - build 16.11.2011
    Compiling "Main.ob2"
    no errors, no warnings, lines    9, time  0.03, new symfile
    New "obj/tmp.lnk" is generated using template "d:/Programs/Dev/XDS/bin/xc.tem"
    -------------------------------------------------------------------
    files: 3  errors: 0(2)  lines 123  time: 0:00  speed 10000 l/m

    XDS Link Version 2.13.3 Copyright (c) Excelsior 1995-2009.
    No errors, no warnings
    **Start Init - End Init

    The Bug has disappeared**
    O2/M2 development system v2.60 TS  (c) 1991-2011 Excelsior, LLC. (build 16.11.2011)
    Make project "Test.prj"
    XDS Oberon-2 v2.40 [x86, v1.50] - build 16.11.2011
    Compiling "BugHere.ob2"
    Generating BugHere
    * [BugHere.ob2 68.15 W330]
    * function NewField inlined
          f[i] := $NewField(i);

    * [BugHere.ob2 82.14 W330]
    * function NewFields inlined
        p.new := $NewFields();   (* manually inlining NewFields removes the ...
    no errors, warnings  2, lines   88, time  0.05, new symfile
    XDS Oberon-2 v2.40 [x86, v1.50] - build 16.11.2011
    Compiling "Main.ob2"
    no errors, no warnings, lines    9, time  0.03
    -------------------------------------------------------------------
    files: 2  errors: 0(2)  lines 97  time: 0:00  speed 10000 l/m

    XDS Link Version 2.13.3 Copyright (c) Excelsior 1995-2009.
    No errors, no warnings

    #RTS: unhandled exception #3: invalid location

    File errinfo.$$ created.

      EAX = 00000000  EBX = 0040F000
      ECX = 00000000  EDX = 00000001
      ESI = 00000000  EDI = 100340C0
      EBP = 100340D0  ESP = 0006FF44
      EIP = 004010CD
     STACK:
      0006FF44:  00000000 00000000 0040F000 0006FF68
      0006FF54:  00000010 00000000 00000000 0006FFB8
      0006FF64:  00000001 1003C078 100340D0 100340C0
      0006FF74:  00000000 00000000 7FFDF000 0006FFB8
      0006FF84:  00401228 0040F29C 0006FFA4 00092170
      0006FF94:  00000001 001E8480 003D0900 0040C78A
      0006FFA4:  00000001 00092170 00092198 00000001
      0006FFB4:  00092170 0006FFF0 0006FFE0 0040CFB1
    **Start Init

    The Bug is still present

    The Bug was reproduced successfully.**
    ```

    #### Комментарий

    Комбинация из следующих опций приводит к воспроизведению данной ошибки: `NOPTRALIAS+`, `CHECKNIL-`, `DOREORDER+`, `GENDEBUG-`, `PROCINLINE+`. Если удалить любую из них из файла `Test.prj` (заменив тем самым на значение по умолчанию), то ошибка не проявится.

    Данная ошибка была выделена из большого проекта, что стоило немалых усилий. На помощь была призвана бесплатная версия дизассемблера IDA Pro. Естественно, в процессе минимизации потребовалось автоматизировать компиляцию и проверку наличия именно искомой ошибки. Для этого были использованы утилиты `sed.exe`, `grep.exe`, интерпретатор `cmd.exe` и отладочная выдача с помощью стандартного модуля `Out`. Чтобы выполнить проверку, запустите файл `Run.bat`. Он скомпилирует тестовый проект и вызовет `CheckBug.bat`, чтобы убедиться, что _ошибки нет_. (Изначально ошибка "исправлена" двумя пустыми вызовами `Disp.String` в процедуре `BugHere.NewField`.) После этого `sed.exe` используется для того, чтобы удалить вызовы `Disp.String`, и проект компилируется заново. `CheckBug.bat` вызывается снова, чтобы убедиться, что удаление этих вызовов _вызвало ошибку_. Вывод о наличии ошибки выводится в консоль (последняя строка выдачи).

*   ### <a name="RecordUnpack">RecordUnpack</a>

    #### Исходный текст модуля для проверки

    ```
    <* NOOPTIMIZE+ *> (* This option is here to prevent removing the ASSERTs:
                       * compiler thinks that the conditions are TRUE and
                       * eliminates the checks. *)
    <* MAIN+ *>
    MODULE Test;

    (* ------------------------------------------------------------------------
     * (C) 2009 by Alexander Iljin
     * ------------------------------------------------------------------------ *)

    IMPORT
       SYSTEM, Out;

    PROCEDURE ReproduceBug ();
    TYPE
       LowHigh = RECORD
          low, high: INTEGER;
       END;
    VAR
       lh: LowHigh;
       longLow, longHigh: LONGINT;
    BEGIN
       lh.high := 2000H;
       lh.low  := 1000H;
       ASSERT (lh.high = 2000H, 20);
       ASSERT (lh.low  = 1000H, 21);
       longHigh := lh.high;                      (* **this works                  ** *)
       longLow  := SYSTEM.VAL (LONGINT, lh.low); (* **same thing, but doesn't work** *)
       ASSERT (longHigh = 2000H, 60);
       ASSERT (longLow  = 1000H, 61);      (* **error is here: longLow = 20001000H** *)
       Out.String ('Test passed.');
    END ReproduceBug;

    BEGIN
       ReproduceBug;
    END Test.
    ```

    #### Результат запуска компилятора

    ```
    >xc =make Test.ob2 && Test.exe
    O2/M2 development system **v2.51** (c) 1999-2003 Excelsior, LLC. (build 10.05.2005)
    **XDS Oberon-2 v2.40 [x86, v1.50] - build 10.05.2005**
    Compiling "Test.ob2"
    no errors, no warnings, lines   36, time  0.01, new symfile
    New "tmp.lnk" is generated using template "d:/Programs/Dev/XDS/bin/xc.tem"

    XDS Link  Version 2.6 Copyright (c) 1995-2001 Excelsior
    No errors, no warnings

    #RTS: unhandled exception #61: **ASSERT(FALSE, 61)**

    File errinfo.$$ created.
    ```

    #### Комментарий

    В XDS v2.60 beta данная ошибка не воспроизводится, на консоль выдаётся "Test passed".

*   ### <a name="TypeGuard">TypeGuard</a>

    #### Исходный текст модуля для проверки

    ```
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
       (* **Although the GetThis procedure is called only once, it will be executed**
        * **twice because of the type guard bug.** *)
       CASE counter OF
       | 1: Out.String('Test passed.');
       | 2: Out.String('Test failed!');
       END;
    END Test.
    ```

    #### Результат запуска компилятора

    ```
    >xc =make Test.ob2 && Test.exe
    O2/M2 development system **v2.51** (c) 1999-2003 Excelsior, LLC. (build 10.05.2005)
    **XDS Oberon-2 v2.40 [x86, v1.50] - build 10.05.2005**
    Compiling "Test.ob2"
    no errors, no warnings, lines   37, time  0.02, new symfile
    New "tmp.lnk" is generated using template "d:/Programs/Dev/XDS/bin/xc.tem"

    XDS Link  Version 2.6 Copyright (c) 1995-2001 Excelsior
    No errors, no warnings
    **Test failed!**
    ```

    #### Комментарий

    В XDS v2.60 beta данная ошибка не воспроизводится, на консоль выдаётся "Test passed".

## Автор

Нашёл ошибки, создал минимальные проекты для их воспроизведения и разместил в данном документе: [Александр Ильин](https://github.com/alex-ilin/).
