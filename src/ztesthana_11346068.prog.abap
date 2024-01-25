*&---------------------------------------------------------------------*

REPORT ztesthana_11346068.
****=================================data declaration====================================================****
**
DATA: it_bseg TYPE STANDARD TABLE OF bseg,
      wa_bseg TYPE bseg.
DATA: it_mara TYPE TABLE OF mara,
      wa_mara TYPE mara.

*  where ersda le '20.10.2015'.
***=================================data declaration====================================================****
*+++++++++++++++++++++++++++++OP Code 11 check+++++++++++++++++++++
DATA: lv_date TYPE sy-datum.
**EXEC SQL.
**  select stdate into lv_date
**    from ldera
**    where lang = :sy-langu
**    ORDER BY PRIMARY KEY.
**ENDEXEC.
**+++++++++++++++++++++++++++++OP Code 11 check+++++++++++++++++++++

*+++++++++++++++++++++++++++++OP Code 12 check+++++++++++++++++++++
DATA : lv_re TYPE char10.

TYPES: BEGIN OF ty_ztet,
         zmat TYPE konv-kposn,
         zkar TYPE konv-stunr,
         zjik TYPE konv-kdatu,
       END OF ty_ztet.
DATA : lv_objky TYPE char10 VALUE 1000222000.
FIELD-SYMBOLS <fs>.
SELECT  kunnr FROM vbpa INTO TABLE @DATA(it_tab) WHERE vbeln = @lv_objky ORDER BY PRIMARY KEY." ORDER BY kunnr.
READ TABLE it_tab ASSIGNING <fs> INDEX 1.
*select * from VBPA where
DATA: lv_subrc TYPE sy-subrc.

* HANA Corrections - BEGIN OF MODIFY - <HANA-001>
* HANA Corrections - BEGIN OF MODIFY - <HANA-001>
CALL FUNCTION 'DB_EXISTS_INDEX'
  EXPORTING
    dbindex         = '/BA1/F4_RELEASE'
    tabname         = ' '
    indexname       = '001'
*  IMPORTING
*   CONSTRAINT      =
*   REALNAME        =
*   subrc           = lv_subrc
*   UNIQUE          =
  EXCEPTIONS
    parameter_error = 1
    OTHERS          = 2.
* HANA Corrections - END OF MODIFY - <HANA-001>
* HANA Corrections - END OF MODIFY - <HANA-001>
IF sy-subrc <> 0.
* Implement suitable error handling here
ENDIF.

*+++++++++++++++++++++++++++++OP Code 12 check+++++++++++++++++++++

*+++++++++++++++++++++++++++++OP Code 13 check+++++++++++++++++++++
DATA: it_knvh TYPE knvh.
* HANA Corrections - BEGIN OF MODIFY - <HANA-001>
*SELECT SINGLE * FROM knvh
*  INTO it_knvh
*WHERE hityp = 'A'  AND
*hkunnr = 'kunnr' AND
*hvkorg = 's_vkorg' AND
*hvtweg = '00' AND
*hspart = '00' AND
*datab <= sy-datum AND
*datbi >= sy-datum
*%_HINTS ORACLE 'index(knvh knvh______a)'.
SELECT * UP TO 1 ROWS FROM knvh
INTO it_knvh
WHERE hityp = 'A' AND
hkunnr = 'KUNNR' AND
hvkorg = 'S_VKORG' AND
hvtweg = '00' AND
hspart = '00' AND
datab <= sy-datum AND
datbi >= sy-datum
%_HINTS ORACLE 'INDEX(KNVH KNVH______A)'
ORDER BY PRIMARY KEY.
ENDSELECT.
* HANA Corrections - END OF MODIFY - <HANA-001>

*+++++++++++++++++++++++++++++OP Code 13 check+++++++++++++++++++++

*+++++++++++++++++++++++++++++OP Code 14 check+++++++++++++++++++++
*data: it_bseg type STANDARD TABLE OF bseg,
*    DATA : wa_bseg type bseg.
* HANA Corrections - BEGIN OF MODIFY - <HANA-001>
*SELECT * FROM bseg
*INTO CORRESPONDING FIELDS OF TABLE it_bseg.
SELECT * FROM bseg
INTO CORRESPONDING FIELDS OF TABLE it_bseg
ORDER BY PRIMARY KEY.
* HANA Corrections - END OF MODIFY - <HANA-001>

* HANA Corrections - BEGIN OF MODIFY - <HANA-001>
* SELECT SINGLE * FROM bseg INTO wa_bseg.
  SELECT * UP TO 1 ROWS FROM bseg INTO wa_bseg
 ORDER BY PRIMARY KEY.
* HANA Corrections - END OF MODIFY - <HANA-001>

*   insert wa_bseg INTO it_bseg.
*+++++++++++++++++++++++++++++OP Code 14 check+++++++++++++++++++++

*+++++++++++++++++++++++++++++OP Code 16/17 check+++++++++++++++++++++
*DATA: it_bseg TYPE STANDARD TABLE OF bseg,
*      wa_bseg TYPE bseg.
* HANA Corrections - BEGIN OF MODIFY - <HANA-001>
*SELECT * FROM bseg
*INTO CORRESPONDING FIELDS OF TABLE it_bseg.
    SELECT * FROM bseg
    INTO CORRESPONDING FIELDS OF TABLE it_bseg
    ORDER BY PRIMARY KEY.
* HANA Corrections - END OF MODIFY - <HANA-001>

      IF sy-subrc EQ 0.
        READ TABLE it_bseg INTO wa_bseg INDEX 1.
        IF sy-subrc EQ 0.
        ENDIF.
      ENDIF.
*+++++++++++++++++++++++++++++OP Code 16.17 check+++++++++++++++++++++

*+++++++++++++++++++++++++++++OP Code 18 check+++++++++++++++++++++
*DATA: "it_bseg TYPE STANDARD TABLE OF bseg,
*      wa_bseg TYPE bseg.
* HANA Corrections - BEGIN OF MODIFY - <HANA-001>
* HANA Corrections - BEGIN OF MODIFY - <HANA-001>
*SELECT * FROM bseg
*INTO CORRESPONDING FIELDS OF TABLE it_bseg.
      SELECT * FROM bseg
      INTO CORRESPONDING FIELDS OF TABLE it_bseg
      ORDER BY PRIMARY KEY.
* HANA Corrections - END OF MODIFY - <HANA-001>
        SELECT * FROM bseg
        INTO CORRESPONDING FIELDS OF TABLE it_bseg
        ORDER BY PRIMARY KEY.
* HANA Corrections - END OF MODIFY - <HANA-001>
          IF sy-subrc EQ 0.
            READ TABLE it_bseg INTO wa_bseg INDEX 2.
          ENDIF.
*+++++++++++++++++++++++++++++OP Code 18 check+++++++++++++++++++++

*+++++++++++++++++++++++++++++OP Code 19 check+++++++++++++++++++++

* HANA Corrections - BEGIN OF MODIFY - <HANA-001>
*SELECT * FROM bseg INTO CORRESPONDING FIELDS OF TABLE it_bseg.
          SELECT * FROM bseg INTO CORRESPONDING FIELDS OF TABLE it_bseg
          ORDER BY PRIMARY KEY.
* HANA Corrections - END OF MODIFY - <HANA-001>
            LOOP AT it_bseg INTO wa_bseg.
              AT NEW belnr.
              ENDAT.
            ENDLOOP.

*+++++++++++++++++++++++++++++OP Code 19 check+++++++++++++++++++++

*+++++++++++++++++++++++++++++OP Code 31 check+++++++++++++++++++++
            SELECT * FROM mara
              INTO CORRESPONDING FIELDS OF TABLE it_mara.
*+++++++++++++++++++++++++++++OP Code 31 check+++++++++++++++++++++

*+++++++++++++++++++++++++++++OP Code 31 34 35 check+++++++++++++++
              DATA: a1 TYPE i, b1 TYPE i.

              a1 = 0.
              b1 = 0.

              DO 2 TIMES.

                a1 = a1 + 1.

                WRITE: /'Outer', a1.

                DO 10 TIMES.
                  b1 = b1 + 1.

                  WRITE: /'Inner', b1.

                ENDDO.
              ENDDO.
              "-----------------------------------
              DATA: lt_vbpa      TYPE STANDARD TABLE OF vbpa,
                    lt_kna1      TYPE STANDARD TABLE OF kna1,
                    wa_vbbe      TYPE vbbe,
                    v_kna1_index TYPE sy-index,
                    wa_vbpa      TYPE vbpa,
                    wa_kna1      TYPE kna1.
              DATA: mara TYPE mara.
* HANA Corrections - BEGIN OF MODIFY - <HANA-001>
*select single ersda from mara into mara where ersda = sy-datum.
              SELECT ersda FROM mara INTO mara WHERE ersda = sy-datum
              ORDER BY PRIMARY KEY.
                EXIT.
              ENDSELECT.
* HANA Corrections - END OF MODIFY - <HANA-001>
* HANA Corrections - BEGIN OF MODIFY - <HANA-001>
*  select single kunnr from kna1 into wa_kna1 where ERDAT = sy-datum.
              SELECT kunnr FROM kna1 INTO wa_kna1 WHERE erdat = sy-datum
              ORDER BY PRIMARY KEY.
                EXIT.
              ENDSELECT.
* HANA Corrections - END OF MODIFY - <HANA-001>
* HANA Corrections - BEGIN OF MODIFY - <HANA-001>
*    select single mandt vbeln posnr etenr from vbbe into wa_vbbe where vbeln = '0000000006' and posnr = '10'.
              SELECT mandt vbeln posnr etenr FROM vbbe INTO wa_vbbe WHERE vbeln = '0000000006' AND posnr = '10'
              ORDER BY PRIMARY KEY.
                EXIT.
              ENDSELECT.
* HANA Corrections - END OF MODIFY - <HANA-001>
              IF sy-subrc EQ 0.

              ENDIF.
              SELECT vbeln posnr parvw _dataaging  FROM vbpa INTO TABLE lt_vbpa FOR ALL ENTRIES IN lt_kna1 WHERE _dataaging = lt_kna1-aedat.
* HANA Corrections - BEGIN OF MODIFY - <HANA-001>
*  select * from kna1 into table lt_kna1.
                SELECT * FROM kna1 INTO TABLE lt_kna1
              ORDER BY PRIMARY KEY.
* HANA Corrections - END OF MODIFY - <HANA-001>

                  SORT: lt_vbpa BY kunnr,
                        lt_kna1 BY kunnr.
                  LOOP AT lt_vbpa INTO wa_vbpa.
                    READ TABLE lt_kna1 INTO wa_kna1     "
                        WITH KEY kunnr = wa_vbpa-kunnr
                        BINARY SEARCH.
                    IF sy-subrc = 0.
                      v_kna1_index = sy-tabix.
                      LOOP AT lt_kna1 INTO wa_kna1 FROM v_kna1_index.
                        IF wa_kna1-kunnr <> wa_vbpa-kunnr.
                          EXIT.
                        ENDIF.

                      ENDLOOP.
                    ENDIF.
                  ENDLOOP.
*+++++++++++++++++++++++++++++OP Code 31 34 35 check+++++++++++++++

*+++++++++++++++++++++++++++++OP Code 33 check+++++++++++++++++++++
                  DATA: wa_t005 TYPE t005,
                        it_t005 TYPE STANDARD TABLE OF t005.

                  SELECT *
                         FROM t005
                         INTO wa_t005.
                    APPEND wa_t005 TO it_t005.
                  ENDSELECT.
*+++++++++++++++++++++++++++++OP Code 33 check+++++++++++++++++++++


*+++++++++++++++++++++++++++++OP Code 37/ 46 check+++++++++++++++++++++
                  DATA: it_kna TYPE STANDARD TABLE OF kna1.

                  SELECT kunnr name1 FROM kna1
                  INTO CORRESPONDING FIELDS OF TABLE it_kna.
*  BYPASSING BUFFER.
                    IF it_kna IS NOT INITIAL.
*  SORT it_kna.
* HANA Corrections - BEGIN OF MODIFY - <HANA-001>
*  DELETE ADJACENT DUPLICATES FROM it_kna.
                      SORT it_kna.
                      DELETE ADJACENT DUPLICATES FROM it_kna.
* HANA Corrections - END OF MODIFY - <HANA-001>
                    ENDIF.

*+++++++++++++++++++++++++++++OP Code 37/ 46 check+++++++++++++++++++++

*+++++++++++++++++++++++++++++OP Code 38 40 41 check+++++++++++++++
                    TYPES:
                      BEGIN OF ty_t100,
                        arbgb TYPE t100-arbgb,
                        msgnr TYPE t100-msgnr,
                        text  TYPE t100-text,
                      END   OF ty_t100.

                    DATA: t_ids       TYPE STANDARD TABLE OF t100-msgnr.
                    DATA: t_t100_all  TYPE STANDARD TABLE OF t100.
                    DATA: t_t100      TYPE STANDARD TABLE OF ty_t100.
                    DATA: t_t100_1      TYPE STANDARD TABLE OF ty_t100.

                    APPEND  '001' TO t_ids.
                    APPEND  '002' TO t_ids.

*IF t_ids IS NOT INITIAL.
*SELECT  arbgb
*        msgnr
*        text           "comment to see more records are dropping
*  INTO TABLE t_t100_1
*  FROM t100
*  WHERE arbgb LIKE '0%'.
                    DATA : v_vrt TYPE mapl
                          .
* HANA Corrections - BEGIN OF MODIFY - <HANA-001>
*SELECT SINGLE * FROM MAPL into v_vrt WHERE PLNTY = 'N'.
                    SELECT * UP TO 1 ROWS FROM mapl INTO v_vrt WHERE plnty = 'N'
                    ORDER BY PRIMARY KEY.
                    ENDSELECT.
* HANA Corrections - END OF MODIFY - <HANA-001>

                    SELECT  arbgb
                            msgnr
                            text           "comment to see more records are dropping
                      INTO TABLE t_t100
                      FROM t100
                      FOR ALL ENTRIES IN t_ids
                      WHERE arbgb LIKE '0%'
                      AND   msgnr = t_ids-table_line.
                      WRITE: / 'Without All Key Fields', sy-dbcnt.
*ENDIF.
*+++++++++++++++++++++++++++++OP Code 38 40 41 check+++++++++++++++

*+++++++++++++++++++++++++++++OP Code 39 check+++++++++++++++++++++
                      TYPES: BEGIN OF t_mara,
                               matnr LIKE mara-matnr,  "FIELD1 FROM MARA TABLE
                               mtart TYPE mara-mtart,  "FIELD2 FROM MARA TABLE
                               maktx TYPE makt-maktx,  "FIELD1 FROM MAKT TABLE
                               spras TYPE makt-spras,  "FIELD2 FROM MAKT TABLE
                             END OF t_mara.

*DATA: IT_MARA TYPE  TABLE OF T_MARA .
*DATA : WA_MARA TYPE T_MARA.
                      SELECT mara~matnr
                             mara~mtart
                             makt~maktx
                             makt~spras
                        INTO  TABLE it_mara
                        FROM mara INNER JOIN makt ON ( mara~matnr = makt~matnr )
                        UP TO 50 ROWS.

*LOOP AT IT_MARA INTO WA_MARA.
*  WRITE : / WA_MARA-MATNR, WA_MARA-MTART, WA_MARA-MAKTX, WA_MARA-SPRAS .
*ENDLOOP.
**+++++++++++++++++++++++++++++OP Code 39 check+++++++++++++++++++++

*+++++++++++++++++++++++++++++OP Code 42 43 44 check+++++++++++++++
                        DATA :l_date(10) TYPE c.
                        DO 6 TIMES.
                          CALL FUNCTION 'CONVERT_DATE_TO_EXTERNAL'
                            EXPORTING
                              date_internal            = sy-datum
                            IMPORTING
                              date_external            = l_date
                            EXCEPTIONS
                              date_internal_is_invalid = 1
                              OTHERS                   = 2.
                          IF sy-subrc <> 0.
* Implement suitable error handling here
                          ENDIF.
                        ENDDO.


                        DATA: return TYPE bapiret2.
                        DO 10 TIMES.
                          CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
                            EXPORTING
                              wait   = 'X'
                            IMPORTING
                              return = return.
                        ENDDO.

                        DATA: gd_fcurr TYPE tcurr-fcurr,
                              gd_tcurr TYPE tcurr-tcurr,
                              gd_date  TYPE sy-datum,
                              gd_value TYPE i.

                        gd_fcurr = 'EUR'.
                        gd_tcurr = 'GBP'.
                        gd_date  = sy-datum.
                        gd_value = 10.

                        PERFORM currency_conversion USING gd_fcurr
                                                         gd_tcurr
                                                         gd_date
                                                CHANGING gd_value.

FORM currency_conversion  USING    p_fcurr
                                  p_tcurr
                                   p_date
                          CHANGING p_value.

  DATA: t_er         TYPE tcurr-ukurs,
        t_ff         TYPE tcurr-ffact,
        t_lf         TYPE tcurr-tfact,
        t_vfd        TYPE datum,
        ld_erate(12) TYPE c.

  CALL FUNCTION 'READ_EXCHANGE_RATE'
    EXPORTING
*     CLIENT           = SY-MANDT
      date             = p_date
      foreign_currency = p_fcurr
      local_currency   = p_tcurr
      type_of_rate     = 'M'
*     EXACT_DATE       = ' '
    IMPORTING
      exchange_rate    = t_er
      foreign_factor   = t_ff
      local_factor     = t_lf
      valid_from_date  = t_vfd
*     DERIVED_RATE_TYPE       =
*     FIXED_RATE       =
*     OLDEST_RATE_FROM =
    EXCEPTIONS
      no_rate_found    = 1
      no_factors_found = 2
      no_spread_found  = 3
      derived_2_times  = 4
      overflow         = 5
      zero_rate        = 6
      OTHERS           = 7.
  IF sy-subrc EQ 0.
    ld_erate = t_er / ( t_ff / t_lf ).
    p_value = p_value * ld_erate.
  ENDIF.
ENDFORM.                    " currency_conversion
*+++++++++++++++++++++++++++++OP Code 42 43 44 check++++++++++++++

*+++++++++++++++++++++++++++++OP Code 56 check++++++++++++++++++++
*TYPES:
*  BEGIN OF ty_t100,
*    arbgb TYPE t100-arbgb,
*    msgnr TYPE t100-msgnr,
*    text  TYPE t100-text,
*  END   OF ty_t100.

*DATA: t_ids       TYPE STANDARD TABLE OF t100-msgnr.
*DATA: t_t100_all  TYPE STANDARD TABLE OF t100.
*DATA: t_t100      TYPE STANDARD TABLE OF ty_t100.

*APPEND  '001' TO t_ids.
*APPEND  '002' TO t_ids.
**  SELECT  arbgb
*          msgnr
*          text
*    INTO TABLE t_t100
*    FROM t100
*    WHERE arbgb ne '60'.
*+++++++++++++++++++++++++++++OP Code 56 check++++++++++++++++++++
*
*+++++++++++++++++++++++++++++OP Code 15 check++++++++++++++++++++
DATA: v_name1 TYPE kna1-name1 VALUE '%SAP%',
      v_mandt TYPE kna1-mandt.

DATA: o_adapter   TYPE REF TO cl_sql_statement,
      o_result    TYPE REF TO cl_sql_result_set,
      o_ref_kna1  TYPE REF TO data,
      o_ref_mandt TYPE REF TO data,
      o_ref_name1 TYPE REF TO data.

*      wa_kna1     TYPE kna1.


*v_mandt = sy-mandt.

*GET REFERENCE OF v_mandt INTO o_ref_mandt.
*GET REFERENCE OF v_name1 INTO o_ref_name1.
*GET REFERENCE OF wa_kna1 INTO o_ref_kna1.
*
*CREATE OBJECT o_adapter.
*
*o_adapter->set_param( o_ref_mandt ).
*o_adapter->set_param( o_ref_name1 ).
*
*o_result = o_adapter->execute_query( 'select * from kna1 where mandt = v_mandt and upper(name1) like :v_name1' ).
*
*o_result->set_param_struct( o_ref_kna1 ).
*
*WHILE o_result->next( ) > 0.
*
*  WRITE: / wa_kna1-kunnr, wa_kna1-name1.
*ENDWHILE.
*+++++++++++++++++++++++++++++OP Code 15 check++++++++++++++++++++
*DATA: "it_kna1 TYPE TABLE OF kna1,
*      it_vbap TYPE vbap.
*SELECT name1 land1 ort01
* AUCT-UPGRADE -  Begin of Modification by <USER> on <17.02.2017> for <EHP8>
*SELECT SINGLE *
*  FROM vbap
*  INTO it_vbap
*  WHERE vbeln = '0000000119'.
*SELECT *
*UP TO 1 ROWS FROM vbap
*INTO it_vbap
*WHERE vbeln = '0000000119'
*ORDER BY PRIMARY KEY.
*ENDSELECT.
* AUCT-UPGRADE -  End of Modification by <USER> on <17.02.2017> for <EHP8>
*  order by primary key.
*  exit.
*  ENDSELECT.
*IF sy-subrc EQ 0.
*ENDIF.
*
*+++++++++++++++++++++++++++++OP Code 45 check++++++++++++++++++++
*DATA: it_kna1 TYPE TABLE OF kna1.
*      wa_kna1 TYPE kna1.
* HANA Corrections - BEGIN OF MODIFY - <HANA-001>
*SELECT kunnr name1 FROM kna1
*    APPENDING TABLE it_kna1
*   WHERE kunnr = '0000000010'.
*SELECT kunnr name1 FROM kna1
*    APPENDING TABLE it_kna1
*   WHERE kunnr = '0000000010'
*ORDER BY PRIMARY KEY.
* HANA Corrections - END OF MODIFY - <HANA-001>
*READ TABLE it_kna1
*  INTO wa_kna1
*  BINARY SEARCH
*  WITH KEY kunnr = '0000000010'.
*+++++++++++++++++++++++++++++OP Code 45 check++++++++++++++++++++
*
*+++++++++++++++++++++++++++++OP Code 47 check++++++++++++++++++++
*
*DATA: BEGIN OF POINTS OCCURS 5,
*      TITLE(4)  TYPE C,
*      NAME(20)  TYPE C,
*      MARKS(3)  TYPE P DECIMALS 0,
*     END OF POINTS.
*     POINTS-TITLE = 'MR.'.
*     POINTS-NAME  = 'Patrick'.
*     POINTS-MARKS = 100.
*     COLLECT POINTS.
*
*    POINTS-MARKS = 250.
*     COLLECT POINTS.
*
*    POINTS-MARKS = 200.
*     APPEND POINTS.
*
*    POINTS-TITLE = 'MISS'.
*     POINTS-NAME  = 'vanessa'.
*     POINTS-MARKS = 100.
*     COLLECT POINTS.
*
*   POINTS-MARKS = 150.
*   COLLECT POINTS.
*
*   COLLECT POINTS.
*
*   READ TABLE POINTS INDEX 2.
*    POINTS-TITLE = 'M/S.'.
*   POINTS-NAME  = 'Cindy'.
*    MODIFY POINTS INDEX 2.
*    LOOP AT POINTS.
*    WRITE:/5 POINTS-TITLE, POINTS-NAME, POINTS-MARKS.
*  ENDLOOP.
* DATA: STR(5) TYPE C OCCURS 5 WITH HEADER LINE,
*       CNT1   TYPE I.
* STR = 'XELL'.
*
*DO 6 TIMES.
* CNT1 = SY-INDEX + 7.
* STR+0(1) = SY-ABCDE+CNT1(1).
*  IF STR+0(1) <> 'I' AND STR+0(1) <> 'O'.
*   APPEND STR.
*  ENDIF.
* ENDDO.
* LOOP AT STR.
* WRITE: /10 STR.
* ENDLOOP.
* DATA: CNT  TYPE I,
*       BUF  TYPE I.
* DO.
* IF SY-INDEX GT 10.
*   EXIT.
* ENDIF.
* BUF = SY-INDEX MOD 3.
* IF BUF = 0.
*   CNT = CNT + SY-INDEX.
* ELSE.
*   CNT = CNT - SY-INDEX.
* ENDIF.
* ENDDO.
* WRITE:/5(3) CNT.
**+++++++++++++++++++++++++++++OP Code 45 check++++++++++++++++++++
