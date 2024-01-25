**&---------------------------------------------------------------------*
Report ZTEST_11346068.

data: lit_essr type STANDARD TABLE OF  essr.
data: lit_ekbe type STANDARD TABLE OF  ekbe.
select * from ekbe into table lit_ekbe.
select mandt lblni packno ebeln from essr CLIENT SPECIFIED into table lit_essr FOR ALL ENTRIES IN lit_ekbe where mandt = sy-mandt
  and lblni = lit_ekbe-lfbnr
  and loekz = ' ' ORDER BY PRIMARY KEY.
**&---------------------------------------------------------------------*
**&
**&---------------------------------------------------------------------*
**++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*
** CHANGE ID : HANA-001
**1.) ACC11346068
**       BHARDWAA                             CR0093193* 29.05.2017
** TR : S7HK900203
** DESCRIPTION: HANA CORRECTION
** TEAM : HANA-MIGRATION
**++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*
*REPORT ztest_11346068.
**&---------------------------------------------------------------------*
**& Report ZTESTHANA_11346068
**&---------------------------------------------------------------------*
**&
**&---------------------------------------------------------------------*
*
**  CONCATENATE path w_tadir-obj_name '\TLIBT.txt' INTO filename.
**  PERFORM read_file USING filename CHANGING it_tlibt[].
**  IF NOT it_tlibt[] IS INITIAL.
**    READ TABLE it_tlibt INDEX 1.
**  ENDIF.
*****=================================data declaration====================================================****
***data: lv_subrc type sy-subrc.
**data: it_bseg type STANDARD TABLE OF bseg,
**      it_bsec TYPE STANDARD TABLE OF bsec,
**      wa_bseg type bseg.
*DATA: it_mara TYPE TABLE OF mara,
*      wa_mara TYPE mara.
** HANA Corrections - BEGIN OF MODIFY - <HANA-001>
**select * from mara into table it_mara.
*SELECT * FROM mara INTO TABLE it_mara
*ORDER BY PRIMARY KEY.
** HANA Corrections - END OF MODIFY - <HANA-001>
*READ TABLE it_mara INTO wa_mara WITH  KEY matnr = '000' BINARY SEARCH.
**  if sy-subrc eq 0.
**    sort it_mara.
**    endif.
**SELECT * FROM bseg
**INTO CORRESPONDING FIELDS OF TABLE it_bseg
**FOR ALL ENTRIES in it_bsec
**WHERE bukrs = it_bsec-bukrs.
*
**  where ersda le '20.10.2015'.
*****=================================data declaration====================================================****
**+++++++++++++++++++++++++++++OP Code 11 check+++++++++++++++++++++
** data: lv_date type sy-datum.
**EXEC SQL.
**  select stdate into :lv_date
**    from ldera
**    where lang = :sy-langu
**    ORDER BY PRIMARY KEY.
**  ENDEXEC.
**+++++++++++++++++++++++++++++OP Code 11 check+++++++++++++++++++++
*
**+++++++++++++++++++++++++++++OP Code 12 check+++++++++++++++++++++
**CALL FUNCTION 'DB_EXISTS_INDEX'
** EXPORTING
**   DBINDEX               = '/BA1/F4_RELEASE'
**   TABNAME               = ' '
**   INDEXNAME             = '001'
** IMPORTING
***   CONSTRAINT            =
***   REALNAME              =
**   SUBRC                 = lv_subrc
***   UNIQUE                =
** EXCEPTIONS
**   PARAMETER_ERROR       = 1
**   OTHERS                = 2
**          .
**IF SY-SUBRC <> 0.
*** Implement suitable error handling here
**ENDIF.
**+++++++++++++++++++++++++++++OP Code 12 check+++++++++++++++++++++
*
**+++++++++++++++++++++++++++++OP Code 13 check+++++++++++++++++++++
**SELECT SINGLE * FROM knvh
**WHERE hityp = ’A’ AND
**hkunnr = z_kunnr AND
**hvkorg = s_vkorg AND
**hvtweg = ‘00’ AND
**hspart = ‘00’ AND
**datab <= sy-datum AND
**datbi >= sy-datum
**  %_HINTS ORACLE ‘index(knvh knvh______a)'.
**+++++++++++++++++++++++++++++OP Code 13 check+++++++++++++++++++++
*
**+++++++++++++++++++++++++++++OP Code 14 check+++++++++++++++++++++
**data: it_bseg type STANDARD TABLE OF bseg,
**      wa_bseg type bseg.
**SELECT * FROM bseg
**INTO CORRESPONDING FIELDS OF TABLE it_bseg.
** SELECT SINGLE * FROM bseg INTO wa_bseg.
**+++++++++++++++++++++++++++++OP Code 14 check+++++++++++++++++++++
*
**+++++++++++++++++++++++++++++OP Code 18 check+++++++++++++++++++++
*DATA: it_bseg TYPE STANDARD TABLE OF bseg,
*      wa_bseg TYPE bseg.
** HANA Corrections - BEGIN OF MODIFY - <HANA-001>
**SELECT * FROM bseg
**INTO CORRESPONDING FIELDS OF TABLE it_bseg.
*SELECT * FROM bseg
*INTO CORRESPONDING FIELDS OF TABLE it_bseg
*ORDER BY PRIMARY KEY.
** HANA Corrections - END OF MODIFY - <HANA-001>
**  if sy-subrc eq 0.
**READ TABLE it_bseg INTO wa_bseg INDEX 2.
**endif.
**+++++++++++++++++++++++++++++OP Code 18 check+++++++++++++++++++++
*
**+++++++++++++++++++++++++++++OP Code 19 check+++++++++++++++++++++
**
**SELECT * FROM bseg INTO CORRESPONDING FIELDS OF TABLE it_bseg.
**  sort it_bseg by bukrs belnr GJAHR buzei.
**LOOP AT it_bseg into wa_bseg.
**  AT NEW belnr.
**  ENDAT.
**ENDLOOP.
*
**+++++++++++++++++++++++++++++OP Code 19 check+++++++++++++++++++++
*
**+++++++++++++++++++++++++++++OP Code 31 check+++++++++++++++++++++
**data: it_mara type STANDARD TABLE OF mara.
**select MATNR ERSDA ERNAM LAEDA from mara
**  into CORRESPONDING FIELDS OF table it_mara.
**  WHERE matnr = '000000000000000012'.
**+++++++++++++++++++++++++++++OP Code 31 check+++++++++++++++++++++
*
**+++++++++++++++++++++++++++++OP Code 31 34 35 check+++++++++++++++
**Data: a1 type I, b1 type I.
**
**a1 = 0.
**b1 = 0.
**
**Do 2 times.
**
**a1 = a1 + 1.
**
**Write: /'Outer', a1.
**
**Do 10 times.
**b1 = b1 + 1.
**
**Write: /'Inner', b1.
**
**ENDDo.
**ENDDo.
**"-----------------------------------
**data: lt_vbpa type STANDARD TABLE OF vbpa,
**      lt_kna1 type STANDARD TABLE OF kna1,
**       v_kna1_index type sy-index,
**       wa_vbpa type vbpa,
**       wa_kna1 type kna1.
***select single * from vbpa into wa_vbpa.
**select * from vbpa into table lt_vbpa.
**  select * from kna1 into table lt_kna1.
**
**sort: lt_vbpa by kunnr,
**      lt_kna1 by kunnr.
**loop at lt_vbpa into wa_vbpa.
**   read TABLE lt_kna1 into wa_kna1     "
**       with key kunnr = wa_vbpa-kunnr
**       binary search.
**  if sy-subrc = 0.
**    v_kna1_index = sy-tabix.
**    loop at lt_kna1 into wa_kna1 from v_kna1_index.
**      if wa_kna1-kunnr <> wa_vbpa-kunnr.
**        exit.
**      endif.
**
**   endloop.
**  endif.
**endloop.
**+++++++++++++++++++++++++++++OP Code 31 34 35 check+++++++++++++++
*
**+++++++++++++++++++++++++++++OP Code 33 check+++++++++++++++++++++
**DATA: WA_T005 TYPE T005,
** IT_T005 TYPE STANDARD TABLE OF T005.
**
**SELECT *
**       FROM T005
**       INTO WA_T005.
**  APPEND WA_T005 TO IT_T005.
**ENDSELECT.
**+++++++++++++++++++++++++++++OP Code 33 check+++++++++++++++++++++
*
*
**+++++++++++++++++++++++++++++OP Code 37 check+++++++++++++++++++++
**data: it_kna type STANDARD TABLE OF kna1.
***
**SELECT kunnr name1 FROM kna1
**INTO CORRESPONDING FIELDS OF TABLE it_kna
** BYPASSING BUFFER.
**+++++++++++++++++++++++++++++OP Code 37 check+++++++++++++++++++++
*
**+++++++++++++++++++++++++++++OP Code 38 40 41 check+++++++++++++++
**TYPES:
**  BEGIN OF ty_t100,
**    arbgb TYPE t100-arbgb,
**    msgnr TYPE t100-msgnr,
**    text  TYPE t100-text,
**  END   OF ty_t100.
**
**DATA: t_ids       TYPE STANDARD TABLE OF t100-msgnr.
**DATA: t_t100_all  TYPE STANDARD TABLE OF t100.
**DATA: t_t100      TYPE STANDARD TABLE OF ty_t100.
**
**APPEND  '001' TO t_ids.
**APPEND  '002' TO t_ids.
**
***IF t_ids IS NOT INITIAL.
**  SELECT  arbgb
**          msgnr
**          text           "comment to see more records are dropping
**    INTO TABLE t_t100
**    FROM t100
**    FOR ALL ENTRIES IN t_ids
**    WHERE arbgb LIKE '0%'
**    AND   msgnr = t_ids-table_line.
**  WRITE: / 'Without All Key Fields', sy-dbcnt.
***ENDIF.
**+++++++++++++++++++++++++++++OP Code 38 40 41 check+++++++++++++++
*
**+++++++++++++++++++++++++++++OP Code 39 check+++++++++++++++++++++
**  TYPES: BEGIN OF T_MARA,
**  MATNR LIKE MARA-MATNR,  "FIELD1 FROM MARA TABLE
**  MTART TYPE MARA-MTART,  "FIELD2 FROM MARA TABLE
**  MAKTX TYPE MAKT-MAKTX,  "FIELD1 FROM MAKT TABLE
**  SPRAS TYPE MAKT-SPRAS,  "FIELD2 FROM MAKT TABLE
**END OF T_MARA.
**
**DATA: IT_MARA TYPE  TABLE OF T_MARA .
**DATA : WA_MARA TYPE T_MARA.
**SELECT MARA~MATNR
**       MARA~MTART
**       MAKT~MAKTX
**       MAKT~SPRAS
**  INTO  TABLE IT_MARA
**  FROM MARA INNER JOIN MAKT ON ( MARA~MATNR = MAKT~MATNR )
**  UP TO 50 ROWS.
**
**LOOP AT IT_MARA INTO WA_MARA.
**  WRITE : / WA_MARA-MATNR, WA_MARA-MTART, WA_MARA-MAKTX, WA_MARA-SPRAS .
**ENDLOOP.
**+++++++++++++++++++++++++++++OP Code 39 check+++++++++++++++++++++
*
**+++++++++++++++++++++++++++++OP Code 42 43 44 check+++++++++++++++
**data: return type BAPIRET2.
**do 10 times.
**CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
** EXPORTING
**   WAIT          = 'X'
** IMPORTING
**   RETURN        = Return
**          .
**ENDDO.
**
**DATA: gd_fcurr TYPE tcurr-fcurr,
**      gd_tcurr TYPE tcurr-tcurr,
**      gd_date  TYPE sy-datum,
**      gd_value TYPE i.
**
**gd_fcurr = 'EUR'.
**gd_tcurr = 'GBP'.
**gd_date  = sy-datum.
**gd_value = 10.
**
**PERFORM currency_conversion USING gd_fcurr
**                                 gd_tcurr
**                                 gd_date
**                        CHANGING gd_value.
**
**FORM currency_conversion  USING    p_fcurr
**                                  p_tcurr
**                                   p_date
**                          CHANGING p_value.
**
**  DATA: t_er        TYPE tcurr-ukurs,
**       t_ff        TYPE tcurr-ffact,
**       t_lf        TYPE tcurr-tfact,
**        t_vfd       TYPE datum,
**        ld_erate(12)   TYPE c.
**
** CALL FUNCTION 'READ_EXCHANGE_RATE'
**   EXPORTING
***       CLIENT                  = SY-MANDT
**      date                    = p_date
**            foreign_currency        = p_fcurr
**     local_currency          = p_tcurr
**      TYPE_OF_RATE            = 'M'
***       EXACT_DATE              = ' '
**   IMPORTING
**      exchange_rate           = t_er
**      foreign_factor          = t_ff
**      local_factor            = t_lf
**      valid_from_date         = t_vfd
***       DERIVED_RATE_TYPE       =
***       FIXED_RATE              =
***       OLDEST_RATE_FROM        =
**   EXCEPTIONS
**     no_rate_found           = 1
**     no_factors_found        = 2
**     no_spread_found         = 3
**    derived_2_times         = 4
**     overflow                = 5
**     zero_rate               = 6
**    OTHERS                  = 7
**            .
** IF sy-subrc EQ 0.
**    ld_erate = t_er / ( t_ff / t_lf ).
**    p_value = p_value * ld_erate.
**  ENDIF.
**ENDFORM.                    " currency_conversion
**+++++++++++++++++++++++++++++OP Code 42 43 44 check++++++++++++++
*
**+++++++++++++++++++++++++++++OP Code 56 check++++++++++++++++++++
**TYPES:
**  BEGIN OF ty_t100,
**    arbgb TYPE t100-arbgb,
**    msgnr TYPE t100-msgnr,
**    text  TYPE t100-text,
**  END   OF ty_t100.
**
**DATA: t_ids       TYPE STANDARD TABLE OF t100-msgnr.
**DATA: t_t100_all  TYPE STANDARD TABLE OF t100.
**DATA: t_t100      TYPE STANDARD TABLE OF ty_t100.
**
**APPEND  '001' TO t_ids.
**APPEND  '002' TO t_ids.
**  SELECT  arbgb
**          msgnr
**          text
**    INTO TABLE t_t100
**    FROM t100
**    WHERE arbgb ne '60'.
**+++++++++++++++++++++++++++++OP Code 56 check++++++++++++++++++++
**DATA: it_vbap TYPE STANDARD TABLE OF z6068_vbap,
**      wa_vbap TYPE z6068_vbap.
***SELECT * FROM z6068_vbap
**SELECT SINGLE * FROM z6068_vbap
**            INTO wa_vbap
***   where pmatn = 'L_MG01'.
***  where posnr = '10'.
**  where ARKTX = 'ZTAT'.
***  where vbeln in ( '2209008590', '2209008600' ).
***  where vbeln eq '2209008590'.
***  delete ADJACENT DUPLICATES FROM it_vbap COMPARING vbeln. "posnr.
**IF sy-subrc EQ 0.
***    sort it_vbap.
**  READ TABLE it_vbap INTO wa_vbap WITH KEY posnr = '10' BINARY SEARCH.
**  IF sy-subrc EQ 0.
**  ENDIF.
**ENDIF.
**&---------------------------------------------------------------------*
**& Report ZTEST_AM123
**&---------------------------------------------------------------------*
**&
**&---------------------------------------------------------------------*
*
**
**INCLUDE: <icon>.
**
**SELECTION-SCREEN BEGIN OF BLOCK blk1 WITH FRAME TITLE TEXT-001.
**
***SELECTION-SCREEN SKIP 1.
***
***SELECTION-SCREEN BEGIN OF LINE.
***SELECTION-SCREEN COMMENT 10(16) TEXT-002 FOR FIELD p_prod.
***SELECTION-SCREEN POSITION 38."POS_LOW.
**PARAMETERS : p_prod TYPE afpo-aufnr.
***SELECTION-SCREEN END OF LINE.
***
***SELECTION-SCREEN BEGIN OF LINE.
***SELECTION-SCREEN COMMENT 15(11) TEXT-003 FOR FIELD p_sales.
***SELECTION-SCREEN POSITION POS_LOW.
**PARAMETERS : p_sales TYPE vbak-vbeln.
***SELECTION-SCREEN POSITION 45.
***SELECTION-SCREEN COMMENT 45(11) TEXT-004 FOR FIELD p_delvry.
**PARAMETERS: p_delvry TYPE lips-vbeln.
***
***SELECTION-SCREEN END OF LINE.
****
***SELECTION-SCREEN BEGIN OF LINE.
***SELECTION-SCREEN COMMENT 18(8) TEXT-005 FOR FIELD p_matnr.
***SELECTION-SCREEN POSITION POS_LOW.
**PARAMETERS p_matnr LIKE mara-matnr. .
***SELECTION-SCREEN POSITION 49.
**PARAMETERS p_maktx LIKE makt-maktx.
***SELECTION-SCREEN END OF LINE.
***
***SELECTION-SCREEN BEGIN OF LINE.
***SELECTION-SCREEN COMMENT 4(26) TEXT-006 FOR FIELD p_qty.
***SELECTION-SCREEN POSITION 30.
**PARAMETERS : p_qty TYPE anzgl5 MODIF ID m01.
***SELECTION-SCREEN END OF LINE.
***
***SELECTION-SCREEN BEGIN OF LINE.
***SELECTION-SCREEN COMMENT 11(15) TEXT-007 FOR FIELD p_totqty.
***SELECTION-SCREEN POSITION POS_LOW.
**PARAMETERS : p_totqty TYPE afpo-psmng.
***SELECTION-SCREEN END OF LINE.
****
***SELECTION-SCREEN BEGIN OF LINE.
***SELECTION-SCREEN COMMENT 16(10) TEXT-008 FOR FIELD p_date.
***SELECTION-SCREEN POSITION POS_LOW.
**PARAMETERS : p_date TYPE dats DEFAULT sy-datum.
***SELECTION-SCREEN END OF LINE.
****
***SELECTION-SCREEN BEGIN OF LINE.
***SELECTION-SCREEN COMMENT 16(10) TEXT-009 FOR FIELD p_prntr.
***SELECTION-SCREEN POSITION POS_LOW.
**PARAMETERS : p_prntr TYPE tsp01-rqdest.
***SELECTION-SCREEN END OF LINE.
***
***SELECTION-SCREEN BEGIN OF LINE.
***SELECTION-SCREEN COMMENT 13(13) TEXT-010 FOR FIELD p_asline.
***SELECTION-SCREEN POSITION POS_LOW.
**PARAMETERS : p_asline TYPE mkal-verid.
***SELECTION-SCREEN END OF LINE.
****
***SELECTION-SCREEN BEGIN OF LINE.
***SELECTION-SCREEN COMMENT 10(16) TEXT-011 FOR FIELD p_copies.
***SELECTION-SCREEN POSITION POS_LOW.
**PARAMETERS : p_copies TYPE charkind MODIF ID m02.
***SELECTION-SCREEN END OF LINE.
**
**SELECTION-SCREEN END OF BLOCK blk1.
**
**SELECTION-SCREEN BEGIN OF BLOCK blk2 WITH FRAME TITLE TEXT-012.
***SELECTION-SCREEN BEGIN OF LINE.
***SELECTION-SCREEN POSITION 35.
**PARAMETERS: p_scl RADIOBUTTON GROUP grp DEFAULT 'X' USER-COMMAND rd.
***SELECTION-SCREEN COMMENT 36(23) TEXT-013 FOR FIELD p_scl .
***SELECTION-SCREEN END OF LINE.
**
***SELECTION-SCREEN BEGIN OF LINE.
***SELECTION-SCREEN POSITION 35.
**PARAMETERS: p_ecl RADIOBUTTON GROUP grp .
***SELECTION-SCREEN COMMENT 36(26) TEXT-014 FOR FIELD p_ecl.
***SELECTION-SCREEN END OF LINE.
**
***SELECTION-SCREEN BEGIN OF LINE.
***SELECTION-SCREEN POSITION 35.
**PARAMETERS: p_bcl RADIOBUTTON GROUP grp  .
***SELECTION-SCREEN COMMENT 36(23) TEXT-015 FOR FIELD p_bcl.
***SELECTION-SCREEN END OF LINE.
**
**SELECTION-SCREEN END OF BLOCK blk2.
**
***selection-screen skip 1.
***selection-screen begin of block blk3 with frame title text-016.
***selection-screen skip 1.
***selection-screen begin of line.
***selection-screen position 3.
***parameters: c_ovrd1 as checkbox.
***selection-screen comment 6(29) text-017 for field c_ovrd1.
***selection-screen end of line.
***selection-screen begin of line.
***selection-screen comment 3(30) text-018.
***parameter p_filenm like rlgrap-filename modif id M02
***          default 'C:\<your path\name here>'.
***selection-screen: pushbutton (6) bt_path1 user-command get_file.
***selection-screen end of line.
***selection-screen skip 1.
***selection-screen end of block blk3.
**
**
****** declarations
**
**TYPES: BEGIN OF ty_tab,
**         posnr TYPE co_posnr,
**         matnr TYPE matnr,
**         dwerk TYPE werks_d,
**       END OF ty_tab.
**
**DATA: lwa_afpo TYPE ty_tab.
**DATA: lt_imdrqx  TYPE STANDARD TABLE OF mdrq,
**      lt_imdrqx1 TYPE STANDARD TABLE OF mdrq,
**      lwa_imdrqx TYPE mdrq.
**DATA: lv_line TYPE i.
**DATA: lv_posnr TYPE delps.
**
*********
**
**
**INITIALIZATION.
**  GET PARAMETER ID 'SPOOL_DEV' FIELD p_prntr.
**
**
**AT SELECTION-SCREEN OUTPUT.
**
**
**  IF p_ecl = 'X' OR p_bcl = 'X'.
**
**    LOOP AT SCREEN.
**      IF screen-group1 = 'M01' or screen-group1 = 'M02'.
**        screen-input = '0'.
**        p_qty = '1'.
**        p_copies = '1'.
**        MODIFY SCREEN.
**      ENDIF.
**    ENDLOOP.
**
**
**  ELSE.
**    LOOP AT SCREEN.
**      IF screen-group1 = 'M01' or screen-group1 = 'M02'.
**        screen-input = '1'.
**        p_qty = ' '.
**        p_copies = ' '.
**        MODIFY SCREEN.
**      ENDIF.
**    ENDLOOP.
**  ENDIF.
***    ENDIF.
***  ENDLOOP.
**
**
**AT SELECTION-SCREEN.
**
**
**  IF p_scl = 'X'.
***    IF screen-group1 = 'M01' or screen-group1 = 'M02'.
***      if screen-input = '0'.
***        screen-input = '1'.
***        p_qty = '1'.
***        p_copies = '1'.
***        MODIFY SCREEN.
***        endif.
***      ENDIF.
**
**    IF p_prod IS NOT INITIAL.
**      SELECT SINGLE psmng matnr verid INTO ( p_totqty , p_matnr , p_asline ) FROM afpo
**         WHERE aufnr = p_prod.
**    ENDIF.
**
**    SELECT SINGLE maktx  INTO p_maktx FROM makt WHERE matnr = p_matnr.
**
**    IF p_sales  IS INITIAL AND p_delvry  IS INITIAL.
**      SELECT SINGLE posnr matnr dwerk INTO lwa_afpo FROM afpo WHERE
**          aufnr = p_prod.
**
**      lv_posnr = lwa_afpo-posnr.
**
**      CALL FUNCTION 'MD_PEGGING_NODIALOG'
**        EXPORTING
***         EDELET = 0000
**          edelkz = 'FE'
**          edelnr = p_prod
**          edelps = lv_posnr
***         EPLSCN = 000
**          ematnr = lwa_afpo-matnr
**          ewerks = lwa_afpo-dwerk
***         EPLWRK = ' '
***         EPLAAB = ' '
***         EPLANR = ' '
***         EBERID = ' '
***         EDAT00 = 00000000
**        TABLES
***         EMDPSX =
**          imdrqx = lt_imdrqx
***       EXCEPTIONS
***         ERROR  = 1
***         NO_REQUIREMENTS_FOUND       = 2
***         ORDER_NOT_FOUND             = 3
***         OTHERS = 4
**        .
**      IF sy-subrc <> 0.
*** Implement suitable error handling here
**      ENDIF.
**
**      LOOP AT lt_imdrqx INTO lwa_imdrqx.
**        IF lwa_imdrqx-delkz = 'VC' OR lwa_imdrqx-delkz = 'VJ'.
**          APPEND lwa_imdrqx TO lt_imdrqx1.
**          CLEAR: lwa_imdrqx.
**        ENDIF.
**      ENDLOOP.
**
**      IF lt_imdrqx1 IS INITIAL.
**        MESSAGE 'No sales order or delivery is pegged to the production order' TYPE 'S'
**         DISPLAY LIKE 'I'.
**      ELSE.
**        lv_line = lines( lt_imdrqx1 ).
**        IF lv_line > 1.
**          MESSAGE 'More than one sales order / delivery are pegged to the production order' TYPE 'I'.
**        ENDIF.
**      ENDIF.
**
**      READ TABLE lt_imdrqx1 INTO lwa_imdrqx INDEX 1.
**      IF lwa_imdrqx-delkz = 'VC'.
**        p_sales = lwa_imdrqx-extra+0(9).
**      ELSE.
**        p_delvry = lwa_imdrqx-extra+0(9).
**      ENDIF.
**    ENDIF.
**  ENDIF.
**
**  IF p_ecl = 'X' OR p_bcl = 'X'.
**
**
**    IF p_prod IS NOT INITIAL.
**      SELECT SINGLE psmng matnr  verid  INTO ( p_totqty , p_matnr , p_asline ) FROM afpo
**        WHERE aufnr = p_prod.
**    ENDIF.
**
**    SELECT SINGLE maktx  INTO p_maktx FROM makt WHERE
**      matnr = p_matnr.
**
**  ENDIF.
*
**
**TABLES: PERNR.
**
**INFOTYPES: 0001.
**GET PERNR.
**PROVIDE * FROM P0001 BETWEEN P0001-BEGDA AND P0001-ENDDA.
**WRITE:/ PERNR-PERNR.
**WRITE:/ P0001-STELL.
**ENDPROVIDE.
**end-of-selection.
**DATA: BEGIN OF line,
**        index(4) TYPE c,
**        text(8)  TYPE c,
**      END OF line.
**
**DATA : "itab LIKE SORTED TABLE OF line WITH UNIQUE KEY index,
**  itab       TYPE STANDARD TABLE OF line,
**  result_tab TYPE match_result_tab.
**
**DATA num(2) TYPE n.
**
**DO 10 TIMES.
**  line-index = sy-index.
**  num = sy-index.
**  CONCATENATE TEXT-001 num INTO line-text.
**  APPEND line TO itab.
**ENDDO.
**
**SEARCH itab FOR TEXT-001 AND MARK.
**FIND ALL OCCURRENCES OF TEXT-002 IN
**     TABLE itab
**     RESULTS result_tab.
**REPLACE ALL OCCURRENCES OF TEXT-002 IN TABLE itab WITH TEXT-003.
**IF itab IS NOT INITIAL.
**  WRITE: / '''string05'' found at line', (1) sy-tabix,
**         'with offset', (1) sy-fdpos.
**ENDIF.
**
**WRITE: / '''string05'' found at line', (1) sy-tabix,
**         'with offset', (1) sy-fdpos.
*
**SKIP.
*
**READ TABLE itab INTO line INDEX sy-tabix.
**WRITE: / line-index, line-text.
*
*TYPES: BEGIN OF st_vbbe ,
*         matnr TYPE vbbe-matnr,
*         werks TYPE vbbe-werks,
*         omeng TYPE vbbe-omeng,
*       END OF st_vbbe.
*
*
*DATA : it_vbbe TYPE TABLE OF st_vbbe,
*       wa_vbbe TYPE st_vbbe.
*
*
*START-OF-SELECTION.
*  SELECT matnr werks omeng
*  FROM vbbe INTO TABLE it_vbbe
*  WHERE matnr EQ 'S4FG2002'.
*
*  LOOP AT it_vbbe INTO wa_vbbe.
*    COLLECT wa_vbbe INTO it_vbbe.
*  ENDLOOP.
