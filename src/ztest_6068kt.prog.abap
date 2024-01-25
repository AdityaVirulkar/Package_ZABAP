REPORT ztest_6068kt.

SELECT SINGLE * FROM PA0002 INTO CORRESPONDING FIELDS OF iI_P0002 WHERE PERNR = iI_P0000-PERNR and endda = c_endda.


SELECT SINGLE stext INTO W_VALS-VAL  FROM hrp1000 WHERE otype = 'C' AND objid = p0001-stell AND istat = '1'
AND langu  = 'EN'
AND infty = '1000'
AND endda GE sy-datum.

*SELECT SINGLE NAME_TEXTc
**  UP TO 1 rows
*    FROM USER_ADDR
*    INTO USERNAME
*    WHERE BNAME = sy-uname.
**ORDER BY PRIMARY KEY.
**EXIT.
**ENDSELECT.


* HANA Corrections - BEGIN OF MODIFY - <HANA-001>
*          SELECT SINGLE * FROM konv WHERE knumv = vbrk-knumv AND
*                                   kschl = 'ZDES'.
*SELECT * UP TO 1 ROWS FROM konv WHERE knumv = vbrk-knumv AND
*                         kschl = 'ZDES'
*ORDER BY PRIMARY KEY.
* HANA Corrections - END OF MODIFY - <HANA-001>



*REPORT demo_select_cursor_1.
*SELECT SINGLE lsrea INTO rel_hkont
*                  FROM t030h
*                  WHERE ktopl = 'SS7'
*                  AND   hkont = l_hkont
*                  AND   waers = ' '
*                  AND   curtp = ''.
*
** AUCT-UPGRADE -  Begin of Modification by <USER> on <17.02.2017> for <EHP8>
**SELECT SINGLE name FROM fplayout INTO objname WHERE name = objname.
*SELECT name FROM fplayout INTO objname WHERE name = objname
*ORDER BY PRIMARY KEY.
*  EXIT.
*ENDSELECT.
** AUCT-UPGRADE -  End of Modification by <USER> on <17.02.2017> for <EHP8>
** AUCT-UPGRADE -  Begin of Modification by <USER> on <17.02.2017> for <EHP8>
**SELECT SINGLE * FROM ddtypet INTO ws_ddtypet WHERE typegroup = w_typepool.
*SELECT * UP TO 1 ROWS FROM ddtypet INTO ws_ddtypet WHERE typegroup = w_typepool
*ORDER BY PRIMARY KEY.
*ENDSELECT.
** AUCT-UPGRADE -  End of Modification by <USER> on <17.02.2017> for <EHP8>
*
*
*
**REPORT YFAR1010.
***++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*
*** Report:  YFAR1010                                                    *
*** Topic:   Credit management --> Standard credit order report          *
***                                                                      *
*** Author:  Santosh Kumar MYLAPUR                                       *
*** Date:    29.04.2015                 Original: D89                    *
*** Change-Request: <CR0058764>         Release : 740                    *
***                                                                      *
*** Responsible                                                          *
*** internal:                           external: Santosh Mylapur        *
*** Project: Henkel                                                      *
***                                                                      *
***++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*
*** Modification history                                                 *
*** Number  Date        Name                           Change-Request    *
***         Comment                                                      *
***----------------------------------------------------------------------*
***    1.)                                             CR.......         *
***                                                                      *
***++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*
**
**INCLUDE YFAR1010_TOP.
**
**INCLUDE YFAR1010_SEL.
**
**INCLUDE YFAR1010_F01.
**
**INITIALIZATION.
**  GV_REPID = SY-REPID.
**
**AT SELECTION-SCREEN.
**  PERFORM VALIDATE_SCREEN.
**
**AT SELECTION-SCREEN OUTPUT.
**  MODIFY SCREEN.
**
**START-OF-SELECTION.
**
*** Read data from database and fill GT_FINAL
**  PERFORM FETCH_DATA.
**
**  IF GT_VBAK IS NOT INITIAL.
**    IF RB_DET EQ GK_X.
***     Show GT_FINAL
**      PERFORM OUTPUT_DETAILS.
**    ELSE.
***     Show totals
**      PERFORM OUTPUT_TOTALS.
**    ENDIF.
*ENDIF.
*
**SELECT MANDT
**       BUKRS
**        AFABER
**         XRESTV
**          XKTDAU
**           AFBRHY
**            SOPNET
**             ZINBUC
**              AFBKST
**               AFBAUF
**                AFBLPE
**                 AFBLGJ
**                  AFBANZ
**                   XBAFAS
**                    AFSLBE
**                     STATUS
**                      CPUDT
**                       CPUTM
**                        AUFBUC
**                         BUBEG
**                          BUEND
**                   FROM T093D INTO TABLE GT_T093D
**                   WHERE BUKRS  EQ P_BUKRS  AND
**                         AFABER EQ P_AFABER AND
**                         AFBLPE EQ P_AFBLPE AND
**                         AFBLGJ EQ P_AFBLGJ.
*
*
*
**DATA: c1 TYPE cursor,
**
**c2 TYPE cursor.
**
**DATA: wa1 TYPE spfli,
**
**wa2 TYPE spfli.
**
**DATA: flag1(1) TYPE c,
**
**flag2(1) TYPE c.
**
**OPEN CURSOR: c1 FOR SELECT carrid connid
**
**FROM spfli
**
**WHERE carrid = 'LH',
**
**c2 FOR SELECT carrid connid cityfrom cityto
**
**FROM spfli
**
**WHERE carrid = 'AZ'.
**
**DO.
**
**IF flag1 NE 'X'.
**
**FETCH NEXT CURSOR c1 INTO CORRESPONDING FIELDS OF wa1.
**
**IF sy-subrc <> 0.
**
**CLOSE CURSOR c1.
**
**flag1 = 'X'.
**
**ELSE.
**
**WRITE: / wa1-carrid, wa1-connid.
**
**ENDIF.
**
**ENDIF.
**
**IF flag2 NE 'X'.
**
**FETCH NEXT CURSOR c2 INTO CORRESPONDING FIELDS OF wa2.
**
**IF sy-subrc <> 0.
**
**CLOSE CURSOR c2.
**
**flag2 = 'X'.
**
**ELSE.
**
**WRITE: / wa2-carrid, wa2-connid,
**
**wa2-cityfrom, wa2-cityto.
**
**ENDIF.
**
**ENDIF.
**
**IF flag1 = 'X' AND flag2 = 'X'.
**
**EXIT.
**
**ENDIF.
**
**ENDDO.
***IF sy-subrc EQ 0.
**** HANA Corrections - BEGIN OF MODIFY - <HANA-001>
****        SELECT mblnr mjahr zeile werks bukrs belnr lifnr ebeln ebelp aufnr sgtxt
****          FROM mseg
****          INTO CORRESPONDING FIELDS OF TABLE it_mseg
****          FOR ALL ENTRIES IN it_mkpf
****          WHERE mblnr = it_mkpf-mblnr
****            AND mjahr = it_mkpf-mjahr
*****            AND ebeln BETWEEN c_docnolow AND c_docnohigh      "--PGUPTA02122015
****            AND ebeln IN lr_po_range                           "++PGUPTA02122015
****            AND bukrs IN s_bukrs.
***  SELECT mblnr mjahr zeile werks bukrs belnr lifnr ebeln ebelp aufnr sgtxt
***    FROM mseg
***    INTO CORRESPONDING FIELDS OF TABLE it_mseg
***    FOR ALL ENTRIES IN it_mkpf
***    WHERE mblnr = it_mkpf-mblnr
***      AND mjahr = it_mkpf-mjahr
****            AND ebeln BETWEEN c_docnolow AND c_docnohigh      "--PGUPTA02122015
***      AND ebeln IN lr_po_range                           "++PGUPTA02122015
***      AND bukrs IN s_bukrs
***ORDER BY PRIMARY KEY.
**** HANA Corrections - END OF MODIFY - <HANA-001>
***
***ELSE.
**** HANA Corrections - BEGIN OF MODIFY - <HANA-001>
****        SELECT mblnr mjahr zeile werks bukrs belnr lifnr ebeln ebelp aufnr sgtxt
****            FROM mseg
****            INTO CORRESPONDING FIELDS OF TABLE it_mseg
****            FOR ALL ENTRIES IN it_mkpf
****            WHERE mblnr = it_mkpf-mblnr
****              AND mjahr = it_mkpf-mjahr
*****            AND ebeln BETWEEN c_docnolow AND c_docnohigh      "--PGUPTA02122015
****            AND ebeln IN lr_po_range                           "++PGUPTA02122015
****              AND bukrs IN lr_bukrs.
***  SELECT mblnr mjahr zeile werks bukrs belnr lifnr ebeln ebelp aufnr sgtxt
***      FROM mseg
***      INTO CORRESPONDING FIELDS OF TABLE it_mseg
***      FOR ALL ENTRIES IN it_mkpf
***      WHERE mblnr = it_mkpf-mblnr
***        AND mjahr = it_mkpf-mjahr
****            AND ebeln BETWEEN c_docnolow AND c_docnohigh      "--PGUPTA02122015
***      AND ebeln IN lr_po_range                           "++PGUPTA02122015
***        AND bukrs IN lr_bukrs
***ORDER BY PRIMARY KEY.
**** HANA Corrections - END OF MODIFY - <HANA-001>
***ENDIF.
***
***IF sy-subrc EQ 0.
***
****AWKEY field being added to MSEG
***  LOOP AT it_mseg INTO wa_mseg.
***    CONCATENATE wa_mseg-mblnr wa_mseg-mjahr INTO wa_mseg-awkey.
***    MODIFY it_mseg FROM wa_mseg INDEX sy-tabix.
***  ENDLOOP.
****data: lt_bukrs type TABLE OF t001,
****      lt_bseg type table of bseg,
****      wa type t001.
****                SELECT bukrs
****                FROM t001
****                INTO TABLE lt_bukrs
****                WHERE bukrs = 's_bukrs'.
*****                  ORDER BY PRIMARY KEY.
***** < END OF MODIFY - ++SKUDALE24072017 > <HANA-001>
****
****                IF sy-subrc IS NOT INITIAL.
*****---Enter a valid value for Company code.
****                  LOOP at lt_bukrs into wa_bukrs where bukrs = 'CH01'.
****                  write: 'error'.
****                  LEAVE LIST-PROCESSING.
****                  ENDLOOP.
****                ENDIF.
*****                SELECT * FROM tbslt.
*****                   WHERE spras = sy-langu.
****                  SELECT bukrs belnr gjahr buzei  matnr  menge meins ebeln ebelp
****     paobjnr pasubnr xref1 xref2
****    INTO TABLE lt_bseg
****    FROM bseg
*****    FOR ALL ENTRIES IN gt_tab
****    WHERE bukrs EQ 'gt_tab-bukrs'
****    AND   belnr EQ 'gt_tab-belnr'
****    AND   gjahr EQ 'gt_tab-gjahr'
****    AND   buzei EQ 'gt_tab-buzei'.
***  DATA: it_mara TYPE STANDARD TABLE OF mara.
***  SELECT * FROM mara INTO TABLE it_mara.
***    SELECT matnr ersda ernam FROM mara INTO TABLE it_mara.
**REPORT  ZTEST_NP.
**
***
**
*** ==== LCL_A ===== *
**
***
**
**CLASS lcl_a DEFINITION.
**
**  PUBLIC SECTION.
**
**    CLASS-METHODS: class_constructor.
**
**    CONSTANTS: c_a TYPE char1 VALUE 'A'.
**
**    METHODS: constructor.
**
**ENDCLASS.                    "lcl_a DEFINITION
**
***
**
**CLASS lcl_a IMPLEMENTATION.
**
**  METHOD class_constructor.
**
**    WRITE: / ' Class Constructor A'.
**
**  ENDMETHOD.                    "class_constructor
**
**  METHOD constructor.
**
**    WRITE: / '  Constructor A'.
**
**  ENDMETHOD.                    "constructor
**
**ENDCLASS.                    "lcl_a IMPLEMENTATION
**
***
**
*** ==== LCL_B ===== *
**
***
**
**CLASS lcl_b DEFINITION INHERITING FROM lcl_a.
**
**  PUBLIC SECTION.
**
**    CONSTANTS: c_b TYPE char1 VALUE 'B'.
**
**    CLASS-METHODS: class_constructor.
**
**    METHODS constructor.
**
**ENDCLASS.                    "lcl_b DEFINITION
**
***
**
**CLASS lcl_b IMPLEMENTATION.
**
**  METHOD class_constructor.
**
**    WRITE : / ' Class Constructor B'.
**
**  ENDMETHOD.                    "class_constructor
**
**  METHOD constructor.
**
**    super->constructor( ).
**
**    WRITE : / '  Constructor B'.
**
**  ENDMETHOD.                    "constructor
**
**ENDCLASS.                    "lcl_b IMPLEMENTATION
**
***
**
*** ==== LCL_C ===== *
**
***
**
**CLASS lcl_c DEFINITION INHERITING FROM lcl_b.
**
**  PUBLIC SECTION.
**
**    CLASS-METHODS: class_constructor.
**
**    METHODS constructor.
**
**ENDCLASS.                    "lcl_b DEFINITION
**
***
**
**CLASS lcl_c IMPLEMENTATION.
**
**  METHOD class_constructor.
**
**    WRITE : / ' Class Constructor C'.
**
**  ENDMETHOD.                    "class_constructor
**
**  METHOD constructor.
**
**    super->constructor( ).
**
**    WRITE : / '  Constructor C'.
**
**  ENDMETHOD.                    "constructor
**
**ENDCLASS.                    "lcl_b IMPLEMENTATION
**
***
**
*** ==== LCL_D ===== *
**
***
**
**CLASS lcl_d DEFINITION INHERITING FROM lcl_c.
**
**  PUBLIC SECTION.
**
**    CONSTANTS: c_d TYPE char1 VALUE 'D'.
**
**    CLASS-METHODS: class_constructor.
**
**    METHODS constructor.
**
**ENDCLASS.                    "lcl_b DEFINITION
**
***
**
**CLASS lcl_d IMPLEMENTATION.
**
**  METHOD class_constructor.
**
**    WRITE : / ' Class Constructor D'.
**
**  ENDMETHOD.                    "class_constructor
**
**  METHOD constructor.
**
**    super->constructor( ).
**
**    WRITE : / '  Constructor D'.
**
**  ENDMETHOD.                    "constructor
**
**ENDCLASS.                    "lcl_b IMPLEMENTATION
**
***
**
*** ==== LCL_Z ===== *
**
***
**
**CLASS lcl_z DEFINITION.
**
**  PUBLIC SECTION.
**
**    CLASS-METHODS: class_constructor.
**
**    CONSTANTS: c_z TYPE char1 VALUE 'Z'.
**
**    METHODS: constructor.
**
**ENDCLASS.                    "lcl_z DEFINITION
**
***
**
**CLASS lcl_z IMPLEMENTATION.
**
**  METHOD class_constructor.
**
**    WRITE: / ' Class Constructor Z'.
**
**  ENDMETHOD.                    "class_constructor
**
**  METHOD constructor.
**
**    WRITE: / '  Constructor Z'.
**
**  ENDMETHOD.                    "constructor
**
**ENDCLASS.
**
**INITIALIZATION.
**data: a type REF TO lcl_d.
**      create OBJECT a.
