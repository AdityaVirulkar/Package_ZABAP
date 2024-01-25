*---------------------------------------------------------------------*
* REPORT ZFEBNL00                                                     *
*---------------------------------------------------------------------*
* The Program includes:                                               *
*                                                                     *
* RFEBKAT9  Definition of AUSZUG and UMSATZ layout MULTICASH          *
* ZFEBNLI1  Definition of the inputrecord-layout GMU (POSTBANK)       *
* ZFEBNLI3  Definition of the inputrecord-layout VERWINFO (INTERPAY)  *
* ZFEBNLI4  Definition of the inputrecord-layout MT940 (ABNAMRO)      *
* Korr: Verwijdering EURO afvraging en BGC formaat
* Korr: IBAN overnemen in (bank)rekeningnummer
*---------------------------------------------------------------------*
* CHANGES:
* SEPA_03 - Incoming payments in SEPA project
*@----------------------------------------------------------------------
*@ JASAM.2013.09.19 - SEPA_03
*@ Fill additional info (totals) in header file
*@----------------------------------------------------------------------
******************************************************************
* CHANGE ID : AUCT-001
* AUTHOR : AUCT
* DATE : 06.06.2017
* TR : ECDK900336
* DESCRIPTION: AUCT CORRECTION
* TEAM : AUCT-UPGRADE
******************************************************************
REPORT zfebnl00
       MESSAGE-ID fb.


*- Table - definitions -----------------------------------------------*
TABLES:
  t012,                                "bank data
  t012k,                               "account data
  varid.                               "report versions

*- Global definitions of AUSZUG and UMSATZ ---------------------------*
"INCLUDE rfebkat9. "-SEPA_03 IZBOG 29.07.2013
INCLUDE rfebkat9_coda_fica. "+SEPA_03 IZBOG 29.07.2013

*- Global definitions of input record layout -------------------------*
INCLUDE zfebnli1.                      "include gmu LAYOUT

INCLUDE zfebnli3.                      "include verw LAYOUT

INCLUDE zfebnli4.                      "include MT940 LAYOUT

*- Data definitions --------------------------------------------------*
DATA: first       TYPE i,
*      h_text(300) TYPE c,    " Xjech 02.02.2011
      h_text(600) TYPE c,     " xjech 02.02.2011
      h_wrbtr LIKE umsatz-wrbtr,       " hulpveld mt940
      h_gcode LIKE umsatz-gcode,       " hulpveld mt940
      h_agkto LIKE umsatz-agkto,       " hulpveld mt940
      h_shkzg LIKE bsid-shkzg,         " mutatiecode 471C => 196
      h_tabix LIKE sy-tabix,
      st_text(80),                     "storno tekst
      l              TYPE i,           "positie in string
      h_verwz        TYPE n,           "verwendungszweck zahler
      h_hex_code(3)  TYPE x,           "umsetzung im hex
      h_char_code(6) TYPE c.           "umsetzung im char.

DATA: gv_first_25(1)  TYPE c,          "xdael insert 2009-02-01
      gv_first_28c(1) TYPE c,          "xdael insert 2009-02-01
      gv_first_1f(1)  TYPE c.          "xdael insert 2009-02-01

DATA:
  BEGIN OF tab_eingabe OCCURS 100,
    text(256),
  END OF tab_eingabe,

  BEGIN OF tab_auszug OCCURS 100,
    text(300),                         "is enough for any AUSZUG-rec
  END OF tab_auszug,

  BEGIN OF tab_umsatz OCCURS 100,
    text(778),                         "SEPA_03 IZBOG add 10 characters
  END OF tab_umsatz.


DATA:
  BEGIN OF date_ddmmyy,
    dd(2) TYPE n,
    mm(2) TYPE n,
    yy(2) TYPE n,
  END OF date_ddmmyy,

  BEGIN OF date_yymmdd,
    yy(2) TYPE n,
    mm(2) TYPE n,
    dd(2) TYPE n,
  END OF date_yymmdd.

*- Constants ---------------------------------------------------------*
CONSTANTS:
   con_bank     LIKE umsatz-agbnk VALUE 'B',
   con_post     LIKE umsatz-agbnk VALUE 'P',
   zeros        TYPE n            VALUE '0'.

CONSTANTS:
   con_split(2) TYPE n            VALUE '27'.

DATA: h_pack    TYPE p.

* Beg JASAM.2013.09.19+
DATA:
  gt_auszug   LIKE auszug OCCURS 1,
  gt_umsatz   LIKE umsatz OCCURS 1.
* End JASAM.2013.09.19+
DATA:
  gv_statement_id TYPE zgmu_file-statement_id.  "JASAM.2013.10.24+

*- Selection-Screen --------------------------------------------------*
SELECTION-SCREEN:
  BEGIN OF BLOCK 1 WITH FRAME TITLE text-101.
PARAMETERS:
  par_fmt(5)               DEFAULT 'GMU  ',
  par_hbid LIKE t012-hbkid DEFAULT 'POSTB'.
SELECTION-SCREEN: BEGIN OF LINE.
PARAMETERS:
  par_pri                DEFAULT space    AS CHECKBOX.
SELECTION-SCREEN COMMENT  5(27) text-s01
              FOR FIELD par_pri.
PARAMETERS:
  par_pre(1)              TYPE n.
SELECTION-SCREEN COMMENT 35(10) text-s02
              FOR FIELD par_pre.
SELECTION-SCREEN: END OF LINE.
SELECTION-SCREEN: END OF BLOCK 1.

SELECTION-SCREEN:
  BEGIN OF BLOCK 5 WITH FRAME TITLE text-101.
SELECTION-SCREEN: BEGIN OF LINE.
PARAMETERS:
   par_cdat               DEFAULT space    AS CHECKBOX.
SELECTION-SCREEN COMMENT 5(30) text-s05
            FOR FIELD par_cdat.
PARAMETERS:
   par_dat                LIKE sy-datum    DEFAULT sy-datum.
SELECTION-SCREEN: END OF LINE.
* Beg JASAM.2013.11.04+
PARAMETERS:
  p_duplic                AS CHECKBOX.
* End JASAM.2013.11.04+
SELECTION-SCREEN: END OF BLOCK 5.


SELECTION-SCREEN:
  BEGIN OF BLOCK 2 WITH FRAME TITLE text-102.
PARAMETERS:
  par_pcup LIKE rfpdo1-febpcupld,
  par_fil1 LIKE rlgrap-filename,
  par_type LIKE rlgrap-filetype    DEFAULT 'ASC'.
SELECTION-SCREEN:
  END OF BLOCK 2.

SELECTION-SCREEN:
  BEGIN OF BLOCK 3 WITH FRAME TITLE text-103.
PARAMETERS:
  par_pcdw LIKE rfpdo1-febpcdwld,
  par_fil2 LIKE rlgrap-filename,
  par_fil3 LIKE rlgrap-filename.
SELECTION-SCREEN:
  END OF BLOCK 3.

SELECTION-SCREEN:
  BEGIN OF BLOCK 4 WITH FRAME TITLE text-104.
PARAMETERS:
*  par_subm AS CHECKBOX,               "JASAM.2013.10.24-
  par_call RADIOBUTTON GROUP subm,     "JASAM.2013.10.24+
  par_subm RADIOBUTTON GROUP subm,     "JASAM.2013.10.24+
  par_vari LIKE febpdo-varia_ebbe.
SELECTION-SCREEN:
  END OF BLOCK 4.


*- AT SELECTION-SCREEN -----------------------------------------------*
AT SELECTION-SCREEN ON VALUE-REQUEST FOR par_fil1.
  CALL FUNCTION 'KD_GET_FILENAME_ON_F4'
    EXPORTING
      mask      = 'c:\*.*,'
      static    = 'X'
    CHANGING
      file_name = par_fil1.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR par_fil2.
  PERFORM value_req_file_out USING par_fil2.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR par_fil3.
  PERFORM value_req_file_out USING par_fil3.

AT SELECTION-SCREEN ON par_fmt.
  IF par_fmt NE 'GMU  ' AND
     par_fmt NE 'VERW ' AND
     par_fmt NE 'MT940'.
    SET CURSOR FIELD 'PAR_FMT'.
    MESSAGE e186(f0) WITH 'GMU , VERW, MT940'.
  ENDIF.

AT SELECTION-SCREEN ON par_pre.
  IF par_pri NE space            AND
     par_pre IS INITIAL.
    MESSAGE ID '38' TYPE 'E' NUMBER '000'
        WITH 'Prefix aangeven !'(e55).
  ENDIF.

AT SELECTION-SCREEN ON par_vari.
  IF par_vari NE space AND
     par_subm NE space.
    SELECT * FROM varid WHERE report = 'ZRFEBKA00'
                        AND   variant = par_vari.
      EXIT.
    ENDSELECT.
    IF sy-subrc NE 0.
      SET CURSOR FIELD 'PAR_VARI'.
      MESSAGE ID 'DS' TYPE 'E' NUMBER '057'
              WITH par_vari 'zrfebka00'.
    ENDIF.
  ENDIF.

AT SELECTION-SCREEN.
  PERFORM check_input_file.
  PERFORM check_output_files.

*---------------------------------------------------------------------*
* Main Program                                                        *
*---------------------------------------------------------------------*
START-OF-SELECTION.

  PERFORM read_inputfile.

  auszug-bank       = par_hbid.        "default-bank-id
  CASE par_fmt.
    WHEN 'GMU'.
      PERFORM process_gmu.             "process_giro.
    WHEN 'VERW'.
      PERFORM process_verw.            "process_verw.
    WHEN 'MT940'.
      PERFORM process_mt940.           "process_MT940
  ENDCASE.

* JASAM.2013.10.24 - SEPA_03
* In case we processed this file already (with the same: file type, statement id and amount)
* we should use previously used AZNUM value for next runs
* to achieve that, we serach table ZGMU_FILE to get statement number if such key found
* Using the same AZNUM, makes generated files identical to previous once
* Then, FPB17 transaction raises (standard solution) a confirmation message
* if we really want to process the same payment data again
  IF p_duplic = abap_false.
* search for AZNUM used previously only if "Allow duplicates" is inactive
    PERFORM check_and_update_aznum.
  ENDIF.

  PERFORM store_auszug.
  PERFORM store_umsatz.

  IF par_subm NE space.
    PERFORM submit_zrfebka00.
  ELSEIF par_call NE space.   "JASAM.2013.10.24+
    PERFORM call_fpb17.
  ELSE.
    PERFORM message_nl USING ' ' 'S' 611 par_fil2 par_fil3 ' ' ' '.
  ENDIF.
*---------------------------------------------------------------------*
* End of Main Program                                                 *
*---------------------------------------------------------------------*

*---------------------------------------------------------------------*
*       FORM CHECK_INPUT_FILE                                         *
*---------------------------------------------------------------------*
* Check, whether the input file exists already. If not, only a        *
* warning message to enable the maintenance of any kind of variant.   *
*---------------------------------------------------------------------*
FORM check_input_file.

  DATA: up_return      TYPE p,
        up_open_failed TYPE c.

  IF par_pcup IS INITIAL.              "read file-system
    OPEN DATASET par_fil1 FOR INPUT IN TEXT MODE ENCODING DEFAULT.
    IF sy-subrc NE 0.
      up_open_failed = 'X'.
    ELSE.
      CLOSE DATASET par_fil1.
    ENDIF.
  ELSE.                                "PC-File
* AUCT-UPGRADE - BEGIN OF MODIFY - <AUCT-001>
* CALL FUNCTION 'WS_QUERY'
* EXPORTING
* FILENAME = PAR_FIL1
* QUERY = 'FE' "ABBREV. FOR 'FILE EXISTS'
* IMPORTING
* RETURN = UP_RETURN "IS '1', IF FILE WAS FOUND
* EXCEPTIONS
* OTHERS.
DATA L_QUERY_FILE_0 TYPE STRING. "FILE
TYPES: ABAP_BOOL.
DATA L_QUERY_RETURN_0 TYPE ABAP_BOOL. "RESULT
L_QUERY_FILE_0 =  PAR_FIL1 .
CALL METHOD CL_GUI_FRONTEND_SERVICES=>FILE_EXIST
EXPORTING
FILE = L_QUERY_FILE_0
RECEIVING
RESULT = L_QUERY_RETURN_0
EXCEPTIONS
CNTL_ERROR           = 1
 ERROR_NO_GUI        = 2
 WRONG_PARAMETER     = 3
NOT_SUPPORTED_BY_GUI = 4
 OTHERS              = 5.
IF L_QUERY_RETURN_0 = 'X' .
UP_RETURN = 1.
ELSE.
UP_RETURN = 0.
ENDIF.
* AUCT-UPGRADE - END OF MODIFY - <AUCT-001>
    IF sy-subrc NE 0 OR up_return IS INITIAL.
      up_open_failed = 'X'.
    ENDIF.
  ENDIF.

  IF up_open_failed EQ 'X'.
    SET CURSOR FIELD 'PAR_FIL1'.
    MESSAGE w002 WITH par_fil1.
  ENDIF.

ENDFORM.                               "CHECK_INPUT_FILE


*---------------------------------------------------------------------*
*       FORM READ_INPUTFILE                                           *
*---------------------------------------------------------------------*
* The reading depends a) on whether to read from file-system or PC    *
*                and  b) on whether the recs have length 50/70/50     *
*---------------------------------------------------------------------*
FORM read_inputfile.

  FIELD-SYMBOLS: <str_ein>.

  DATA: up_gmu(050),
        up_verw(050),
        up_swft(064),
        up_len(3).

*- define record length
  CASE par_fmt.
    WHEN 'GMU'.
      up_len = '050'.
      ASSIGN up_gmu  TO <str_ein>.
    WHEN 'VERW'.
      up_len = '050'.
      ASSIGN up_verw TO <str_ein>.
    WHEN 'MT940'.
      up_len = co_linelenmt940. "'064'. SEPA_03 IZBOG 06082013 (64-> constant)
      ASSIGN up_verw TO <str_ein>.
    WHEN OTHERS.
      EXIT.
  ENDCASE.

  IF par_pcup EQ 'X'.                  "PC-file
    PERFORM read_pc_file USING up_len.
  ELSE.                                "read file-system
    OPEN DATASET par_fil1 FOR INPUT IN TEXT MODE ENCODING DEFAULT.
    IF sy-subrc NE 0.
      PERFORM message_nl USING ' ' 'E' 703 par_fil1 ' ' ' ' ' '.
    ENDIF.
    DO.
      CLEAR <str_ein>.
      READ DATASET par_fil1 INTO <str_ein>.
      IF sy-subrc NE 0.
        EXIT.
      ENDIF.
      tab_eingabe-text = <str_ein>.
      APPEND tab_eingabe.
    ENDDO.
    CLOSE DATASET par_fil1.
  ENDIF.

ENDFORM.                               "READ_INPUTFILE


*---------------------------------------------------------------------*
*       FORM READ_PC_FILE                                             *
*---------------------------------------------------------------------*
FORM read_pc_file USING length.

  DATA: BEGIN OF up_gmu OCCURS 100,
          text(050),
        END OF up_gmu,
        BEGIN OF up_verw OCCURS 100,
          text(050),
        END OF up_verw,
        BEGIN OF up_mt940 OCCURS 100,
          text(co_linelenmt940)," SEPA_03 IZBOG 06082013, 64->constant
        END OF up_mt940.
  DATA: up_filelength TYPE i.

  DATA: lv_string TYPE string,
        lt_up_gmu   LIKE STANDARD TABLE OF up_gmu,
        lt_up_verw  LIKE STANDARD TABLE OF up_verw,
        lt_up_mt940  LIKE STANDARD TABLE OF up_mt940,
        lv_type     TYPE char10.


  CASE length.
    WHEN 50.
      CASE par_fmt.
        WHEN 'GMU'.

          lv_string = par_fil1.
          lv_type   = par_type.

          CALL METHOD cl_gui_frontend_services=>gui_upload
            EXPORTING
              filename                = lv_string
              filetype                = lv_type
            IMPORTING
              filelength              = up_filelength
            CHANGING
              data_tab                = lt_up_gmu
            EXCEPTIONS
              file_open_error         = 1
              file_read_error         = 2
              no_batch                = 3
              gui_refuse_filetransfer = 4
              invalid_type            = 5
              no_authority            = 6
              unknown_error           = 7
              bad_data_format         = 8
              header_not_allowed      = 9
              separator_not_allowed   = 10
              header_too_long         = 11
              unknown_dp_error        = 12
              access_denied           = 13
              dp_out_of_memory        = 14
              disk_full               = 15
              dp_timeout              = 16
              not_supported_by_gui    = 17
              error_no_gui            = 18
              OTHERS                  = 19.

          IF sy-subrc <> 0.
*           MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*                      WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
          ENDIF.
          APPEND LINES OF lt_up_gmu TO up_gmu.

*          CALL FUNCTION 'WS_UPLOAD'
*               EXPORTING
*                    filename   = par_fil1
*                    filetype   = par_type
*               IMPORTING
*                    filelength = up_filelength
*               TABLES
*                    data_tab   = up_gmu
*               EXCEPTIONS
*                    OTHERS.
        WHEN 'VERW'.

          lv_string = par_fil1.
          lv_type   = par_type.

          CALL METHOD cl_gui_frontend_services=>gui_upload
            EXPORTING
              filename                = lv_string
              filetype                = lv_type
            IMPORTING
              filelength              = up_filelength
            CHANGING
              data_tab                = lt_up_verw
            EXCEPTIONS
              file_open_error         = 1
              file_read_error         = 2
              no_batch                = 3
              gui_refuse_filetransfer = 4
              invalid_type            = 5
              no_authority            = 6
              unknown_error           = 7
              bad_data_format         = 8
              header_not_allowed      = 9
              separator_not_allowed   = 10
              header_too_long         = 11
              unknown_dp_error        = 12
              access_denied           = 13
              dp_out_of_memory        = 14
              disk_full               = 15
              dp_timeout              = 16
              not_supported_by_gui    = 17
              error_no_gui            = 18
              OTHERS                  = 19.
          IF sy-subrc <> 0.
*           MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*                      WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
          ENDIF.

          APPEND LINES OF lt_up_verw TO up_verw.

*          CALL FUNCTION 'WS_UPLOAD'
*               EXPORTING
*                    filename   = par_fil1
*                    filetype   = par_type
*               IMPORTING
*                    filelength = up_filelength
*               TABLES
*                    data_tab   = up_verw
*               EXCEPTIONS
*                    OTHERS.
      ENDCASE.
    WHEN co_linelenmt940."64. SEPA_03 IZBOG 06082013 (64-> constant)

      lv_string = par_fil1.
      lv_type   = par_type.

      CALL METHOD cl_gui_frontend_services=>gui_upload
        EXPORTING
          filename                = lv_string
          filetype                = lv_type
        IMPORTING
          filelength              = up_filelength
        CHANGING
          data_tab                = lt_up_mt940
        EXCEPTIONS
          file_open_error         = 1
          file_read_error         = 2
          no_batch                = 3
          gui_refuse_filetransfer = 4
          invalid_type            = 5
          no_authority            = 6
          unknown_error           = 7
          bad_data_format         = 8
          header_not_allowed      = 9
          separator_not_allowed   = 10
          header_too_long         = 11
          unknown_dp_error        = 12
          access_denied           = 13
          dp_out_of_memory        = 14
          disk_full               = 15
          dp_timeout              = 16
          not_supported_by_gui    = 17
          error_no_gui            = 18
          OTHERS                  = 19.
      IF sy-subrc <> 0.
*           MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*                      WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
      ENDIF.

      APPEND LINES OF lt_up_mt940 TO up_mt940.

*      CALL FUNCTION 'WS_UPLOAD'
*           EXPORTING
*                filename   = par_fil1
*                filetype   = par_type
*           IMPORTING
*                filelength = up_filelength
*           TABLES
*                data_tab   = up_mt940
*           EXCEPTIONS
*                OTHERS.

  ENDCASE.
  IF sy-subrc NE 0.
    PERFORM message_nl USING ' ' 'A' '657' par_fil1 ' ' ' ' ' '.
  ENDIF.
  IF up_filelength EQ 0.
    PERFORM message_nl USING ' ' 'I' '662' ' ' ' ' ' ' ' '.
    PERFORM message_nl USING ' ' 'A' '657' par_fil1 ' ' ' ' ' '.
  ENDIF.

  DATA: xo_conv TYPE REF TO cl_abap_conv_out_ce,
        lv_buffer  TYPE xstring.

  REFRESH tab_eingabe.
  CASE length.
    WHEN 50.
      CASE par_fmt.
        WHEN 'GMU'.
          LOOP AT up_gmu.
*            TRY.
*                CALL METHOD CL_ABAP_CONV_OUT_CE=>CREATE
*                  EXPORTING
*                    ENCODING    = '1100'
*                IGNORE_CERR = 'X'
*                  RECEIVING
*                    CONV        = xo_conv
*                    .
*              CATCH CX_PARAMETER_INVALID_RANGE .
*              CATCH CX_SY_CODEPAGE_CONVERTER_INIT .
*            ENDTRY.
*
**xo_conv = cl_abap_conv_out_ce=>create( encoding = '1100' IGNORE_CERR =
**ABAP_TRUE ).
*            TRY.
*                CALL METHOD XO_CONV->CONVERT
*                  EXPORTING
*                    DATA   =  up_gmu-text
**                    N      = -1
*                  IMPORTING
*                    BUFFER = lv_buffer
**    LEN    =
*                    .
*              CATCH CX_SY_CODEPAGE_CONVERTER_INIT .
*              CATCH CX_SY_CONVERSION_CODEPAGE .
*              CATCH CX_PARAMETER_INVALID_TYPE .
*            ENDTRY.
*
**           xo_conv->convert( EXPORTING data = up_gmu-text
**                 IMPORTING buffer = lv_buffer ).
*            tab_eingabe-text = lv_buffer.
*            TRANSLATE up_gmu-text FROM CODE PAGE '1133'.
            tab_eingabe-text = up_gmu-text.
            APPEND tab_eingabe.
          ENDLOOP.
        WHEN 'VERW'.
          LOOP AT up_verw.
*            xo_conv = cl_abap_conv_out_ce=>create(
*                                                   encoding = '1133'
*                                                   endian = ' ' ).
*
*            xo_conv->convert( EXPORTING data = up_verw-text
*                  IMPORTING buffer = lv_buffer ).
*            tab_eingabe-text = lv_buffer.
**            TRANSLATE up_verw-text FROM CODE PAGE '1133'.
            tab_eingabe-text = up_verw-text.
            IF tab_eingabe-text+2(9) EQ 'BGCBYLAGE'.
              MESSAGE e000 WITH 'BGCBYLAGE mag niet worden'
                                'ingelezen !!'.
            ENDIF.
            APPEND tab_eingabe.
          ENDLOOP.
      ENDCASE.
    WHEN co_linelenmt940." SEPA_03 IZBOG 06082013, 64->constant
      LOOP AT up_mt940.
*        xo_conv = cl_abap_conv_out_ce=>create(
*                                               encoding = '1133'
*                                               endian = ' ' ).
*
*        xo_conv->convert( EXPORTING data = up_mt940-text
*              IMPORTING buffer = lv_buffer ).
*        tab_eingabe-text = lv_buffer.
**        TRANSLATE up_mt940-text FROM CODE PAGE '1133'.
        tab_eingabe-text = up_mt940-text.
        APPEND tab_eingabe.
      ENDLOOP.

  ENDCASE.

ENDFORM.                               "READ_PC_FILE


*---------------------------------------------------------------------*
*       FORM PROCESS_GMU                                              *
*---------------------------------------------------------------------*
FORM process_gmu.
  REFRESH: auszug,
           umsatz.
  REFRESH: gt_umsatz.                                     "JASAM.2013.09.19+
  LOOP AT tab_eingabe.
    CASE tab_eingabe(4).
      WHEN '0001'.
        PERFORM verarbeitung-gmu.
        auszug-updat      = gmu_datei_vorlauf-altdat. "datum vorig afsch
        PERFORM get_aznum USING auszug-aznum.
      WHEN '0010'.
        PERFORM verarbeitung-gmu.
        IF NOT ( par_pri IS INITIAL ).
          gmu_batch_vorlauf2-konto+0(1) = par_pre.
        ENDIF.
        auszug-ktonr      = gmu_batch_vorlauf2-konto.
        PERFORM get_bank  USING 'NL'
                                auszug-ktonr
                                auszug-bank
                                auszug-waers.
      WHEN '0100'.
        MOVE-CORRESPONDING auszug TO umsatz.
        IF first NE 0.
          PERFORM transactie-gmu.
          PERFORM init_gmu.
        ENDIF.
        ADD 1 TO first.
      WHEN '0110'.
        PERFORM verarbeitung-gmu.

        IF NOT ( par_pri IS INITIAL ).
          gmu_batch_vorlauf2-konto+0(1) = par_pre.
        ENDIF.
        auszug-ktonr      = gmu_batch_vorlauf2-konto.
        PERFORM get_bank  USING 'NL'
                                auszug-ktonr
                                auszug-bank
                                gmu_euro-valuta.
      WHEN '9990'.
        IF first NE 0.
          MOVE-CORRESPONDING auszug TO umsatz.
          PERFORM transactie-gmu.
          PERFORM init_gmu.
        ENDIF.
        CLEAR first.
        PERFORM fill_hdr_add_fields CHANGING auszug.      "JASAM.2013.09.19+
        tab_auszug-text = auszug.
        APPEND tab_auszug.
        REFRESH: gt_umsatz.                               "JASAM.2013.09.19+
    ENDCASE.
    PERFORM verarbeitung-gmu.
  ENDLOOP.
ENDFORM.                               "PROCESS_GMU

*---------------------------------------------------------------------*
*       FORM PROCESS_VERW                                             *
*---------------------------------------------------------------------*
FORM process_verw.
  REFRESH: auszug, umsatz.
  REFRESH: gt_umsatz.                                     "JASAM.2013.09.19+
  auszug-koart = 'VERW'.
  LOOP AT tab_eingabe.
    CASE tab_eingabe(3).
      WHEN '010'.
        PERFORM verarbeitung-verw.
      WHEN '050'.
        PERFORM verarbeitung-verw.
        IF verw_btchvoor1-btsrt EQ 'B'.
          MESSAGE w000 WITH 'VERWINFO batchsoort B'
                            'mag niet verwerkt worden !!'.
        ENDIF.
        PERFORM get_aznum USING auszug-aznum.
      WHEN '051'.
        PERFORM verarbeitung-verw.
        auszug-waers   = verw_btchvoor2-wears.
      WHEN '100'.
        IF NOT ( par_pri IS INITIAL ).
          verw_btchvoor1-kondd+0(1) = par_pre.
        ENDIF.
        auszug-ktonr      = verw_btchvoor1-kondd.
        PERFORM get_bank  USING 'NL'
                          verw_btchvoor1-kondd
                          auszug-bank
                          auszug-waers.

        MOVE-CORRESPONDING auszug TO umsatz.
        IF first NE 0.
          PERFORM transactie-verw.
          PERFORM init_verw.
        ENDIF.
        PERFORM verarbeitung-verw.
        ADD 1 TO first.
      WHEN '950'.
        IF first NE 0.
          MOVE-CORRESPONDING auszug TO umsatz.
          PERFORM transactie-verw.
          PERFORM init_verw.
          PERFORM fill_hdr_add_fields CHANGING auszug.    "JASAM.2013.09.19+
          tab_auszug-text = auszug.
          APPEND tab_auszug.
          REFRESH: gt_umsatz.                             "JASAM.2013.09.19+
        ENDIF.
        CLEAR: verw_btchvoor1,
               verw_btchvoor2,
               verw_btch_sluss,
               first.
    ENDCASE.
    PERFORM verarbeitung-verw.
  ENDLOOP.
ENDFORM.                               "PROCESS_VERW

*---------------------------------------------------------------------*
*       FORM PROCESS_MT940                                            *
*---------------------------------------------------------------------*
FORM process_mt940.

  REFRESH: auszug, umsatz.
  REFRESH: gt_umsatz.                                     "JASAM.2013.09.19+

* SEPA_03 BEGIN IZBOG 05082013
* select table with key codes for MT940
  PERFORM select_keycodes.
* select table with mutation codes mapping
  PERFORM select_mutationcodes.
* SEPA_03 END IZBOG 05082013
  LOOP AT tab_eingabe.
    CASE tab_eingabe(4).
      WHEN '{1:F'.
        IF gv_first_1f EQ space.
          "xdael insert 2009-02-01
          PERFORM get_aznum USING auszug-aznum.
          MOVE 'X' TO gv_first_1f.
          "xdael insert 2009-02-01
        ENDIF.
        "xdael insert 2009-02-01
      WHEN ':20:'.
      WHEN '-}{5'.
      WHEN ':25:'.
        PERFORM verarbeitung-mt940.
      WHEN ':61:'.
*        MOVE MT940_REKENING+4(9) TO auszug-ktonr.
*        SHIFT auszug-ktonr RIGHT.
*        MOVE '0'                 TO auszug-ktonr+0(1).
*        IF NOT ( par_pri IS INITIAL ).
*          auszug-ktonr+0(1) = par_pre.
*        ENDIF.
        auszug-koart = 'MT940'.

        MOVE mt940_rekening+4(10) TO auszug-ktonr.

        PERFORM get_bank  USING 'NL'
                                auszug-ktonr
                                auszug-bank
                                auszug-waers.
        MOVE-CORRESPONDING auszug TO umsatz.
        IF first NE 0.
          PERFORM transactie-mt940.
          PERFORM init_mt940.
        ENDIF.
        ADD 1 TO first.
      WHEN ':62F'.
        IF first NE 0.
          MOVE-CORRESPONDING auszug TO umsatz.
          PERFORM transactie-mt940.
          PERFORM init_mt940.
          CLEAR first.
        ENDIF.
        PERFORM fill_hdr_add_fields CHANGING auszug.      "JASAM.2013.09.19+
        tab_auszug-text = auszug.
        APPEND tab_auszug.
        REFRESH: gt_umsatz.                               "JASAM.2013.09.19+
    ENDCASE.
    PERFORM verarbeitung-mt940.
  ENDLOOP.

ENDFORM.                               "PROCESS_MT940

*---------------------------------------------------------------------*
*       FORM SHIFT                                                    *
*---------------------------------------------------------------------*
FORM shift USING strng.

  DATA: up_strng(100).

  up_strng = strng.

  IF up_strng CN ' 0'.
    SHIFT up_strng BY sy-fdpos PLACES.
  ENDIF.
  strng = up_strng.

ENDFORM.                               "SHIFT


*---------------------------------------------------------------------*
*       FORM GET_AZNUM                                                *
*---------------------------------------------------------------------*
FORM get_aznum USING aznum LIKE auszug-aznum.

  DATA: up_kukey LIKE febkey-kukey,
        up_tname LIKE febkey-tname.

  CASE par_fmt.
    WHEN 'GMU'.
      up_tname = 'FEBNLGMU01'.
    WHEN 'VERW'.
      up_tname = 'FEBNLVERW1'.
    WHEN 'MT940'.
      up_tname = 'FEBNLMT940'.
  ENDCASE.

  CALL FUNCTION 'GET_SHORTKEY_FOR_FEBKO'
    EXPORTING
      i_tname = up_tname
    IMPORTING
      e_kukey = up_kukey
    EXCEPTIONS
      OTHERS.
  UNPACK up_kukey TO aznum.

ENDFORM.                               "GET_AZNUM


*---------------------------------------------------------------------*
*       FORM GET_BANK                                                 *
*---------------------------------------------------------------------*
* The function module GET_BANK_ACCOUNT cannot be used. The field      *
* I_BANKS is not supported (yet). And I_BANKL is unknown here.        *
*---------------------------------------------------------------------*
FORM get_bank USING value(ctry) value(acctno) bankl waers.
  DATA:
    up_acctno LIKE t012k-bankn,
    up_ctry   LIKE t012-banks,
    up_waers  LIKE t012k-waers,
    up_tablen TYPE p.

  DATA: BEGIN OF tab_t012k OCCURS 1.
          INCLUDE STRUCTURE t012k.
  DATA: END OF tab_t012k.

  up_ctry   = ctry.
  up_acctno = acctno.

*- 1) read all house-banks with fitting account number
  SELECT * FROM t012k INTO TABLE tab_t012k
           WHERE bankn = up_acctno.
  LOOP AT tab_t012k.
    SELECT SINGLE * FROM t012 WHERE bukrs = tab_t012k-bukrs
                              AND   hbkid = tab_t012k-hbkid.
    IF t012-banks NE up_ctry.          "check country of bank
      DELETE tab_t012k.
    ENDIF.
  ENDLOOP.

*- 2) If there's more than one bank, compare currencies
  DESCRIBE TABLE tab_t012k LINES up_tablen.
  CHECK up_tablen GT 0.                "if nothing was found -> EXIT
  IF up_tablen GT 1.                   "more than one bank found
    up_waers  = waers.
    LOOP AT tab_t012k WHERE waers <> up_waers.
      DELETE tab_t012k.
    ENDLOOP.
  ENDIF.

*- 3) If only one entry was found, return it
  DESCRIBE TABLE tab_t012k LINES up_tablen.
  CHECK up_tablen EQ 1.                "check, that only one bank fits
  READ TABLE tab_t012k INDEX 1 INTO t012k.
  SELECT SINGLE * FROM  t012           "read bank-data for this account
         WHERE  bukrs = t012k-bukrs
         AND    hbkid = t012k-hbkid.
  bankl = t012-bankl.
  waers = t012k-waers.

ENDFORM.                               "GET_BANK


*---------------------------------------------------------------------*
*       FORM STORE_AUSZUG                                             *
*---------------------------------------------------------------------*
FORM store_auszug.

  IF par_pcdw IS INITIAL.              "no PC-Download
    OPEN DATASET par_fil2 FOR OUTPUT IN TEXT MODE ENCODING DEFAULT.

    LOOP AT tab_auszug.
      TRANSFER tab_auszug-text TO par_fil2.
    ENDLOOP.

    CLOSE DATASET par_fil2.
  ELSE.                                "PC-Download

    DATA: lv_string TYPE string,
          lt_auszug LIKE STANDARD TABLE OF tab_auszug.

    lv_string = par_fil2.
    APPEND LINES OF tab_auszug TO lt_auszug.

    CALL METHOD cl_gui_frontend_services=>gui_download
      EXPORTING
        filename                = lv_string
        filetype                = 'ASC'
      CHANGING
        data_tab                = lt_auszug
      EXCEPTIONS
        file_write_error        = 1
        no_batch                = 2
        gui_refuse_filetransfer = 3
        invalid_type            = 4
        no_authority            = 5
        unknown_error           = 6
        header_not_allowed      = 7
        separator_not_allowed   = 8
        filesize_not_allowed    = 9
        header_too_long         = 10
        dp_error_create         = 11
        dp_error_send           = 12
        dp_error_write          = 13
        unknown_dp_error        = 14
        access_denied           = 15
        dp_out_of_memory        = 16
        disk_full               = 17
        dp_timeout              = 18
        file_not_found          = 19
        dataprovider_exception  = 20
        control_flush_error     = 21
        not_supported_by_gui    = 22
        error_no_gui            = 23
        OTHERS                  = 24.
    IF sy-subrc <> 0.
      PERFORM message_nl USING 'FZ' 'E' 230 sy-subrc ' ' ' ' ' '.
    ENDIF.



*    CALL FUNCTION 'WS_DOWNLOAD'
*         EXPORTING
*              filename = par_fil2
*              mode     = 'ASC'
*         TABLES
*              data_tab = tab_auszug
*         EXCEPTIONS
*              OTHERS.
*    IF sy-subrc NE 0.
*      PERFORM message_nl USING 'FZ' 'E' 230 sy-subrc ' ' ' ' ' '.
*    ENDIF.
  ENDIF.

ENDFORM.                               "STORE_AUSZUG


*---------------------------------------------------------------------*
*       FORM STORE_UMSATZ                                             *
*---------------------------------------------------------------------*
FORM store_umsatz.

  IF par_pcdw IS INITIAL.              "no PC-Download
    OPEN DATASET par_fil3 FOR OUTPUT IN TEXT MODE ENCODING DEFAULT.


    LOOP AT tab_umsatz.
      TRANSFER tab_umsatz-text TO par_fil3.
    ENDLOOP.

    CLOSE DATASET par_fil3.
  ELSE.                                "PC-Download
    DATA: lv_string TYPE string,
          lt_umsatz LIKE STANDARD TABLE OF tab_umsatz.

    lv_string = par_fil3.
    APPEND LINES OF tab_umsatz TO lt_umsatz.

    CALL METHOD cl_gui_frontend_services=>gui_download
      EXPORTING
        filename                = lv_string
        filetype                = 'ASC'
      CHANGING
        data_tab                = lt_umsatz
      EXCEPTIONS
        file_write_error        = 1
        no_batch                = 2
        gui_refuse_filetransfer = 3
        invalid_type            = 4
        no_authority            = 5
        unknown_error           = 6
        header_not_allowed      = 7
        separator_not_allowed   = 8
        filesize_not_allowed    = 9
        header_too_long         = 10
        dp_error_create         = 11
        dp_error_send           = 12
        dp_error_write          = 13
        unknown_dp_error        = 14
        access_denied           = 15
        dp_out_of_memory        = 16
        disk_full               = 17
        dp_timeout              = 18
        file_not_found          = 19
        dataprovider_exception  = 20
        control_flush_error     = 21
        not_supported_by_gui    = 22
        error_no_gui            = 23
        OTHERS                  = 24.

    IF sy-subrc <> 0.
      PERFORM message_nl USING 'FZ' 'E' 230 sy-subrc ' ' ' ' ' '.
    ENDIF.

*
*    CALL FUNCTION 'WS_DOWNLOAD'
*         EXPORTING
*              filename = par_fil3
*              mode     = 'ASC'
*         TABLES
*              data_tab = tab_umsatz
*         EXCEPTIONS
*              OTHERS.
*    IF sy-subrc NE 0.
*      PERFORM message_nl USING 'FZ' 'E' 230 sy-subrc ' ' ' ' ' '.
*    ENDIF.
  ENDIF.

ENDFORM.                               "STORE_UMSATZ


*---------------------------------------------------------------------*
*       FORM SUBMIT_zrfebka00                                          *
*---------------------------------------------------------------------*
FORM submit_zrfebka00.

  DATA : BEGIN OF up_pri_param.
          INCLUDE STRUCTURE %_print.
  DATA : END OF up_pri_param.

  IF par_vari NE space.
    IF sy-batch = space.
      SUBMIT zrfebka00 USING SELECTION-SET par_vari
*     submit rfebka00 using selection-set par_vari
                        WITH einlesen INCL 'X'
                        WITH format   INCL 'M'
                        WITH auszfile INCL par_fil2
                        WITH umsfile  INCL par_fil3
                        WITH pcupload INCL par_pcdw
                        AND RETURN .
    ELSE.
      CLEAR up_pri_param.
      up_pri_param = %_print.
      SUBMIT zrfebka00 USING SELECTION-SET par_vari
*     submit rfebka00 using selection-set par_vari
                        TO SAP-SPOOL
                        SPOOL PARAMETERS up_pri_param
                        WITHOUT SPOOL DYNPRO
                        WITH batch    INCL 'X'
                        WITH einlesen INCL 'X'
                        WITH format   INCL 'M'
                        WITH auszfile INCL par_fil2
                        WITH umsfile  INCL par_fil3
                        WITH pcupload INCL par_pcdw
                        AND RETURN .
    ENDIF.
  ELSE.
    IF sy-batch EQ space.
      SUBMIT zrfebka00 VIA SELECTION-SCREEN
                        WITH einlesen INCL 'X'
                        WITH format   INCL 'M'
                        WITH auszfile INCL par_fil2
                        WITH umsfile  INCL par_fil3
                        WITH pcupload INCL par_pcdw
                        AND RETURN .
    ENDIF.
  ENDIF.

ENDFORM.                               "SUBMIT_RFEBKA00


*---------------------------------------------------------------------*
*       FORM VALUE_REQ_FILE_IN                                         *
*---------------------------------------------------------------------*
* FILENAME: for PC-files FILENAME contains the new filename selected. *
*---------------------------------------------------------------------*
FORM value_req_file_in USING filename.

  DATA: up_file LIKE rlgrap-filename.

  PERFORM get_button USING 'PAR_PCUP' par_pcup.
  IF par_pcup IS INITIAL.              "no PC-Upload
    MESSAGE s608.                      "Kein F4 für UniX-Files
  ELSE.                                "PC-Upload
* AUCT-UPGRADE - BEGIN OF MODIFY - <AUCT-001>
*CALL FUNCTION 'WS_FILENAME_GET'
*EXPORTING
*DEF_FILENAME = ' '
*DEF_PATH     = ' '
*MASK         = ',*.*,*.*.'
*MODE         = 'O'
*TITLE        = TEXT-110
*IMPORTING
*FILENAME     = UP_FILE
*EXCEPTIONS
*OTHERS.
DATA:
 V_UPG1_LT_FILES TYPE FILETABLE ,
 V_UPG1_L_DEF_FILE TYPE STRING ,
 V_UPG1_L_DEF_MASK TYPE STRING ,
 V_UPG1_L_FILE TYPE FILE_TABLE ,
 V_UPG1_L_SUBRC TYPE I ,
 V_UPG1_L_TITLE TYPE STRING ,
 V_UPG1_L_USRACT TYPE I .
V_UPG1_L_TITLE = TEXT-110 .
V_UPG1_L_DEF_FILE = UP_FILE .
V_UPG1_L_DEF_MASK = ',*.*,*.*.' .
CALL METHOD CL_GUI_FRONTEND_SERVICES=>FILE_OPEN_DIALOG
EXPORTING
WINDOW_TITLE = V_UPG1_L_TITLE
DEFAULT_FILENAME = V_UPG1_L_DEF_FILE
FILE_FILTER = V_UPG1_L_DEF_MASK
CHANGING
FILE_TABLE = V_UPG1_LT_FILES
RC = V_UPG1_L_SUBRC
USER_ACTION = V_UPG1_L_USRACT
EXCEPTIONS
FILE_OPEN_DIALOG_FAILED = 1
CNTL_ERROR = 2
ERROR_NO_GUI = 3
NOT_SUPPORTED_BY_GUI  = 4
OTHERS =  5.
IF SY-SUBRC = 0
AND V_UPG1_L_USRACT <> CL_GUI_FRONTEND_SERVICES=>ACTION_CANCEL.
LOOP AT V_UPG1_LT_FILES INTO V_UPG1_L_FILE .
MOVE V_UPG1_L_FILE-FILENAME TO UP_FILE .
EXIT.
ENDLOOP.
ENDIF.
* AUCT-UPGRADE - END OF MODIFY - <AUCT-001>

    IF sy-subrc EQ 0.                  "Only if name has been changed,
      filename = up_file.              "copy the new name
    ENDIF.
  ENDIF.

ENDFORM.                               "VALUE_REQ_FILE_IN


*---------------------------------------------------------------------*
*       FORM VALUE_REQ_FILE_OUT                                       *
*---------------------------------------------------------------------*
* FILENAME: for PC-files FILENAME contains the new filename selected. *
*---------------------------------------------------------------------*
FORM value_req_file_out USING filename.

  DATA: up_file LIKE rlgrap-filename.

  PERFORM get_button USING 'PAR_PCDW' par_pcdw.
  IF par_pcdw IS INITIAL.              "no PC-Download
    MESSAGE s608.                      "Kein F4 für UniX-Files
  ELSE.                                "PC-Download
* AUCT-UPGRADE - BEGIN OF MODIFY - <AUCT-001>
*CALL FUNCTION 'WS_FILENAME_GET'
*EXPORTING
*DEF_FILENAME = ' '
*DEF_PATH     = ' '
*MASK         = ',*.*,*.*.'
*MODE         = 'S'
*TITLE        = TEXT-110
*IMPORTING
*FILENAME     = UP_FILE
*EXCEPTIONS
*OTHERS.
DATA:
 V_UPG2_FILEN TYPE STRING ,
 V_UPG2_FILENAME TYPE STRING ,
 V_UPG2_FULLPATH TYPE STRING ,
 V_UPG2_L_MASK TYPE STRING ,
 V_UPG2_L_TITLE TYPE STRING ,
 V_UPG2_PATH TYPE STRING ,
 V_UPG2_USR_ACT TYPE I .
V_UPG2_FILENAME = UP_FILE .
V_UPG2_L_TITLE = TEXT-110 .
V_UPG2_L_MASK = ',*.*,*.*.' .
CALL METHOD CL_GUI_FRONTEND_SERVICES=>FILE_SAVE_DIALOG
EXPORTING
WINDOW_TITLE = V_UPG2_L_TITLE
DEFAULT_FILE_NAME = V_UPG2_FILENAME
FILE_FILTER = V_UPG2_L_MASK
CHANGING
FILENAME = V_UPG2_FILEN
PATH = V_UPG2_PATH
FULLPATH = V_UPG2_FULLPATH
USER_ACTION = V_UPG2_USR_ACT
EXCEPTIONS
CNTL_ERROR =  1
ERROR_NO_GUI =  2
NOT_SUPPORTED_BY_GUI =  3
OTHERS =  4.
V_UPG2_FILENAME = V_UPG2_FILEN .
* AUCT-UPGRADE - END OF MODIFY - <AUCT-001>

    IF sy-subrc EQ 0.                  "Only if name has been changed,
      filename = up_file.              "copy the new name
    ENDIF.
  ENDIF.

ENDFORM.                               "VALUE_REQ_FILE_OUT


*---------------------------------------------------------------------*
*       FORM CHECK_OUTPUT_FILES                                       *
*---------------------------------------------------------------------*
* Check, whether is is possible to create PAR_FIL2 and PAR_FIL3.      *
*---------------------------------------------------------------------*
FORM check_output_files.

  DATA: up_ret2 TYPE n,
        up_ret3 TYPE n.

  IF par_pcdw EQ 'X'.
    PERFORM check_pcfile USING: par_fil2 up_ret2,
                                par_fil3 up_ret3.
  ELSE.
    PERFORM check_uxfile USING: par_fil2 up_ret2,
                                par_fil3 up_ret3.
  ENDIF.
  IF up_ret2 NE 0.
    SET CURSOR FIELD 'PAR_FIL2'.
    MESSAGE w603 WITH par_fil2.
  ELSEIF up_ret3 NE 0.
    SET CURSOR FIELD 'PAR_FIL3'.
    MESSAGE w603 WITH par_fil3.
  ENDIF.

ENDFORM.                               "CHECK_OUTPUT_FILES


*---------------------------------------------------------------------*
*       FORM CHECK_PCFILE                                             *
*---------------------------------------------------------------------*
FORM check_pcfile USING value(file) error.

  DATA: up_in  LIKE rlgrap-filename,
        up_out LIKE rlgrap-filename,
        up_ret TYPE p.

  up_in = file.
  WHILE up_in+1 CA '/\'.
    CONCATENATE up_out up_in+0(1) INTO up_out.
    SHIFT up_in.
  ENDWHILE.

* AUCT-UPGRADE - BEGIN OF MODIFY - <AUCT-001>
* CALL FUNCTION 'WS_QUERY'
* EXPORTING
* FILENAME = UP_OUT
* QUERY = 'DE'
* IMPORTING
* RETURN = UP_RET
* EXCEPTIONS
* OTHERS.
DATA L_QUERY_FILE_1 TYPE STRING. "FILE
DATA L_QUERY_RESULT_1 TYPE C. "RESULT
L_QUERY_FILE_1 =  UP_OUT .
CALL METHOD CL_GUI_FRONTEND_SERVICES=>DIRECTORY_EXIST
EXPORTING
DIRECTORY = L_QUERY_FILE_1
RECEIVING
RESULT = L_QUERY_RESULT_1
EXCEPTIONS
CNTL_ERROR           = 1
 ERROR_NO_GUI        = 2
 WRONG_PARAMETER     = 3
NOT_SUPPORTED_BY_GUI = 4
 OTHERS              = 5.
IF L_QUERY_RESULT_1 = 'X' .
UP_RET = 1.
ELSE.
UP_RET = 0.
ENDIF.
* AUCT-UPGRADE - END OF MODIFY - <AUCT-001>
  IF sy-subrc NE 0 OR
     up_ret   EQ 0.
    error = 1.
  ENDIF.

ENDFORM.                               "CHECK_PCFILE


*---------------------------------------------------------------------*
*       FORM CHECK_UXFILE                                             *
*---------------------------------------------------------------------*
FORM check_uxfile USING value(file) error.

  DATA: up_in  LIKE rlgrap-filename.

  up_in = file.
  OPEN DATASET up_in FOR OUTPUT IN TEXT MODE  ENCODING DEFAULT.
  error = sy-subrc.
  IF sy-subrc EQ 0.                    "remove created dummy
    CLOSE DATASET up_in.
    DELETE DATASET up_in.
  ENDIF.

ENDFORM.                               "CHECK_UXFILE


*---------------------------------------------------------------------*
*       FORM GET_BUTTON                                               *
*---------------------------------------------------------------------*
FORM get_button USING fieldname fieldvalue.

  DATA: BEGIN OF up_tab OCCURS 1.
          INCLUDE STRUCTURE dynpread.
  DATA: END OF up_tab.

  MOVE fieldname TO up_tab-fieldname.
  APPEND up_tab.

  CALL FUNCTION 'DYNP_VALUES_READ'
    EXPORTING
      dyname             = 'ZFEBNL00'
      dynumb             = '1000'
      translate_to_upper = ' '
    TABLES
      dynpfields         = up_tab
    EXCEPTIONS
      OTHERS.
  IF sy-subrc EQ 0.
    READ TABLE up_tab WITH KEY fieldname = fieldname.
    IF sy-subrc EQ 0.
      fieldvalue = up_tab-fieldvalue.
    ENDIF.
  ENDIF.

ENDFORM.                               "GET_BUTTON


*---------------------------------------------------------------------*
*       FORM MESSAGE_NL                                               *
*---------------------------------------------------------------------*
FORM message_nl USING value(id)        "id of message-class
                      value(ty)        "message-type
                      value(no)        "message-number
                      value(v1)                             "variable 1
                      value(v2)                             "variable 2
                      value(v3)                             "variable 3
                      value(v4).                            "variable 4

  DATA: up_id LIKE fimsg-msgid,
        up_ty LIKE fimsg-msgty.

  up_id = id.
  IF up_id IS INITIAL.
    up_id = 'FB'.                      "like MSG-ID in REPORT-TOP
  ENDIF.

  up_ty = ty.
  IF sy-batch NE space OR
     up_ty IS INITIAL.
    up_ty = 'S'.
  ENDIF.

  MESSAGE ID up_id
          TYPE up_ty
          NUMBER no
          WITH v1 v2 v3 v4.
  IF sy-batch NE space.
    MESSAGE s094(f0).
    STOP.
  ENDIF.

ENDFORM.                               "MESSAGE_DK

*---------------------------------------------------------------------*
*       FORM verarbeitung-MT940                                       *
*---------------------------------------------------------------------*
FORM verarbeitung-mt940.

  DATA:
    l          TYPE i,
    lv_is_iban TYPE kennzx.


  CASE tab_eingabe-text(4).
    WHEN '{1:F'.
    WHEN '-}{5'.
    WHEN ':20:'.
    WHEN ':25:'.
      IF gv_first_25 EQ space.
        "xdael insert 2009-02-01
        MOVE: tab_eingabe-text TO mt940_rekening.
        MOVE 'X' TO gv_first_25.
        "xdael insert 2009-02-01
      ENDIF.
    WHEN ':28:'.
      MOVE: tab_eingabe-text TO mt940_volgnummer.
      PERFORM get_aznum USING auszug-aznum.
    WHEN ':60F'.
      MOVE: tab_eingabe-text TO mt940_beginsaldo.
    WHEN ':61:'.
      MOVE: tab_eingabe-text TO mt940_transactie.
      PERFORM mt940_splits_transactie.
    WHEN ':86:'.
      MOVE: tab_eingabe-text TO mt940_omschrijving.
      APPEND mt940_omschrijving.
      IF tab_eingabe-text+4(4) EQ 'GIRO'.
        h_agkto = tab_eingabe-text+10(7).
        CONDENSE h_agkto NO-GAPS.
        l = strlen( h_agkto ).
        WHILE l < 7.
          SHIFT h_agkto RIGHT.
          MOVE '0' TO h_agkto(1).
          l = strlen( h_agkto ).
        ENDWHILE.
        SHIFT h_agkto RIGHT.
        MOVE 'P' TO h_agkto(1).
      ENDIF.
      IF tab_eingabe-text+4(1) EQ space.
        h_agkto = tab_eingabe-text+5(12).
        DO 3 TIMES.
          REPLACE '.' WITH ' ' INTO h_agkto.
          CONDENSE h_agkto NO-GAPS.
        ENDDO.
        SHIFT h_agkto RIGHT.
        MOVE '0' TO h_agkto(1).
      ENDIF.
      IF h_agkto IS INITIAL.
*       Not recognized yet, try the dutch IBAN format.
        PERFORM is_iban USING tab_eingabe-text+4(18)
                        CHANGING lv_is_iban.
        IF ( lv_is_iban IS NOT INITIAL ).
          IF ( tab_eingabe-text+12(3) = '000' ).
            h_agkto = tab_eingabe-text+15(7).
          ELSE.
            h_agkto = tab_eingabe-text+12(10).
          ENDIF.
        ENDIF.
      ENDIF.
      IF h_agkto IS INITIAL.
*       Still not recognized, use default.
        h_agkto = 'P9999999'.
      ENDIF.
    WHEN 'BETA'.
      MOVE: tab_eingabe-text TO mt940_betalingskenmerk.
      MOVE: tab_eingabe-text TO mt940_omschrijving.   " XJECH 2011.02.03
      APPEND mt940_omschrijving.                      " XJECH 2011.02.03
    WHEN ':62F'.
      MOVE: tab_eingabe-text TO mt940_eindsaldo.
    WHEN ':60M'.
      "xdael insert 2009-02-01
    WHEN ':62M'.
      "xdael insert 2009-02-01
    WHEN ':28C'.
      gv_statement_id = tab_eingabe-text+5(20).   "JASAM.2013.10.24+
      "xdael insert 2009-02-01
      IF gv_first_28c EQ space.
        "only first time       "xdael insert 2009-02-01
        MOVE: tab_eingabe-text TO mt940_omschrijving.
        "xdael insert 2009-02-01
        APPEND mt940_omschrijving.
        "xdael insert 2009-02-01
        MOVE 'X' TO gv_first_28c.
        "xdael insert 2009-02-01
      ENDIF.
      "xdael insert 2009-02-01
    WHEN OTHERS.
      MOVE: tab_eingabe-text TO mt940_omschrijving.
      APPEND mt940_omschrijving.
  ENDCASE.
ENDFORM.                    "VERARBEITUNG-MT940

*---------------------------------------------------------------------*
*       FORM verarbeitung-GMU                                        *
*---------------------------------------------------------------------*
FORM verarbeitung-gmu.
  CASE tab_eingabe-text(4).
    WHEN '0001'.
      MOVE: tab_eingabe-text   TO gmu_datei_vorlauf.
      IF gmu_datei_vorlauf-prodcd CA '23'.
      ENDIF.
      CONCATENATE gmu_datei_vorlauf-credat gmu_datei_vorlauf-duplic INTO gv_statement_id. "JASAM.2013.10.24+
    WHEN '0010'.
      "      IF gmu_datei_vorlauf-datei = 'GMU02'.
      "SEPA version, without leading zeros in account
      MOVE: tab_eingabe-text   TO gmu_batch_vorlauf2.
      IF gmu_batch_vorlauf2-konto+0(3) = '000'.
        gmu_batch_vorlauf2-konto = gmu_batch_vorlauf2-konto+3(7).
      ENDIF.
      MOVE-CORRESPONDING gmu_batch_vorlauf2 TO gmu_batch_vorlauf.
    WHEN '0100'.
      MOVE: tab_eingabe-text   TO gmu_transactie.
    WHEN '0110'.
      MOVE: tab_eingabe-text   TO gmu_euro.
    WHEN '0200'.
      MOVE: tab_eingabe-text   TO gmu_storting.
    WHEN '0210'.
      MOVE: tab_eingabe-text   TO gmu_overschrijving_bij.
    WHEN '0220'.
      MOVE: tab_eingabe-text   TO gmu_overschrijving_af_a.
    WHEN '0225'.
      MOVE: tab_eingabe-text   TO gmu_overschrijving_af_b.
    WHEN '0230'.
      MOVE: tab_eingabe-text   TO gmu_acceptgiro_bij.
    WHEN '0235'.
      MOVE: tab_eingabe-text   TO gmu_acgs_record.
    WHEN '0236'.
      MOVE: tab_eingabe-text   TO gmu_acgb_record.
    WHEN '0240'.
      MOVE: tab_eingabe-text   TO gmu_intercompany.
    WHEN '0250'.
      CLEAR st_text.
      MOVE: tab_eingabe-text   TO gmu_inkasso_bij.
      CASE gmu_inkasso_bij-reden.
        WHEN 'A'.
          MOVE: 'Storno: opdracht niet uitvoerbaar'
                TO st_text.
        WHEN 'B'.
          MOVE: 'Storno: naam/nummer stemmen niet overeen'
                TO st_text.
        WHEN 'C'.
          MOVE: 'Storno: opdracht niet uitvoerbaar'
                TO st_text.
        WHEN 'D'.
          MOVE: 'Storno: rekeningnummer niet accoord'
                TO st_text.
        WHEN 'E'.
          MOVE: 'Storno: mutatie niet toegestaan'
                TO st_text.
        WHEN 'F'.
          MOVE: 'Storno: op verzoek debiteur ingetrokken'
                TO st_text.
        WHEN 'G'.
          MOVE: 'Storno: geen incassomachtiging verstrekt'
                TO st_text.
        WHEN 'H'.
          MOVE: 'Storno: niet accoord met afschrijving'
                TO st_text.
        WHEN 'I'.
          MOVE: 'Storno: intrekking door opdrachtgever'
                TO st_text.
        WHEN 'J'.
          MOVE: 'Storno: niet volgens Clieop-richtlijnen'
                TO st_text.
        WHEN OTHERS.
          MOVE: 'Storno: reden niet bekend'
                TO st_text.
      ENDCASE.
      "      APPEND gmu_specificatie_text. - SEPA_03
    WHEN '0260'.
      MOVE: tab_eingabe-text   TO gmu_toonbank.
    WHEN '0270'.
      MOVE: tab_eingabe-text   TO gmu_geldopname.
    WHEN '0280'.
      MOVE: tab_eingabe-text   TO gmu_cheque.
    WHEN '0290'.
      MOVE: tab_eingabe-text   TO gmu_sammel_ueber_ab.
    WHEN '0300'.
      MOVE: tab_eingabe-text   TO gmu_point_of_sale.
    WHEN '0310'.
      MOVE: tab_eingabe-text   TO gmu_pak_kaarten.
    WHEN '0320'.
      MOVE: tab_eingabe-text   TO gmu_inkasso_p_p.
    WHEN '0330'.
      MOVE: tab_eingabe-text   TO gmu_diversen_rec.
*** +SEPA_03 BEGIN IZBOG 30072013
* new/changed processing of records
    WHEN '0400'.
*     IBAN number is the part of the 0400 record.
      MOVE: tab_eingabe-text   TO gmu_specificatie_0400.
    WHEN '0420'.
      MOVE: tab_eingabe-text   TO gmu_specificatie_0420.
      REPLACE ALL OCCURRENCES OF ';' IN gmu_specificatie_0420 WITH '\'.
    WHEN '0425'.
* it can be several lines of this type
      MOVE: tab_eingabe-text   TO gmu_specificatie_0425.
      APPEND gmu_specificatie_0425 TO gmu_specificatie_0425_tab.
    WHEN '0435'.
* it can be several lines of this type
      MOVE: tab_eingabe-text   TO gmu_specificatie_0435.
      APPEND gmu_specificatie_0425 TO gmu_specificatie_0425_tab.
    WHEN '0440'.
      MOVE: tab_eingabe-text   TO gmu_specificatie_0440.
      REPLACE ALL OCCURRENCES OF ';' IN gmu_specificatie_0440 WITH '\'.
    WHEN '0450'.
      MOVE: tab_eingabe-text   TO gmu_specificatie_0450.
    WHEN '0460'.
* not used for the time being
*     MOVE: tab_eingabe-text   TO gmu_specificatie_0460.
    WHEN '0470'.
* not used for the time being
*     MOVE: tab_eingabe-text   TO gmu_specificatie_0470.
*      REPLACE ALL OCCURRENCES OF ';' IN gmu_specificatie_0470 WITH '\'.
    WHEN '0480'.
* not used for the time being
*     MOVE: tab_eingabe-text   TO gmu_specificatie_0480.
    WHEN '0490'.
* not used for the time being
* it can be several lines of this type
*     MOVE: tab_eingabe-text   TO gmu_specificatie_0490.
*     APPEND gmu_specificatie_0490 to gmu_specificatie_0490_tab.
*     REPLACE ALL OCCURRENCES OF ';' IN gmu_specificatie_0490 WITH '\'.
    WHEN '0500'.
      MOVE: tab_eingabe-text   TO gmu_specificatie_0500.
      REPLACE ALL OCCURRENCES OF ';' IN gmu_specificatie_0500 WITH '\'.
    WHEN '0510'.
      MOVE: tab_eingabe-text   TO gmu_specificatie_0510.
      REPLACE ALL OCCURRENCES OF ';' IN gmu_specificatie_0510 WITH '\'.
      APPEND gmu_specificatie_0510 TO gmu_specificatie_0510_tab.
    WHEN '0520'.
      MOVE: tab_eingabe-text   TO gmu_specificatie_0520.
      REPLACE ALL OCCURRENCES OF ';' IN gmu_specificatie_0520 WITH '\'.
      APPEND gmu_specificatie_0520 TO gmu_specificatie_0520_tab.
    WHEN '0530'.
      MOVE: tab_eingabe-text   TO gmu_specificatie_0530.
      REPLACE ALL OCCURRENCES OF ';' IN gmu_specificatie_0530 WITH '\'.
    WHEN '0540'.
      MOVE: tab_eingabe-text   TO gmu_specificatie_0540.
      REPLACE ALL OCCURRENCES OF ';' IN gmu_specificatie_0540 WITH '\'.
    WHEN '0550'.
      MOVE: tab_eingabe-text   TO gmu_specificatie_0550.
      REPLACE ALL OCCURRENCES OF ';' IN gmu_specificatie_0550 WITH '\'.
      APPEND gmu_specificatie_0550 TO gmu_specificatie_0550_tab.
    WHEN '0560'.
      MOVE: tab_eingabe-text   TO gmu_specificatie_0560.
      REPLACE ALL OCCURRENCES OF ';' IN gmu_specificatie_0560 WITH '\'.
* +SEPA_03 END IZBOG 30072013

    WHEN '9990'.
      MOVE: tab_eingabe-text   TO gmu_batch_ende.
    WHEN '9999'.
      MOVE: tab_eingabe-text   TO gmu_datei_ende.
  ENDCASE.
ENDFORM.                    "VERARBEITUNG-GMU

*---------------------------------------------------------------------*
*       FORM verarbeitung-VERW                                       *
*---------------------------------------------------------------------*
FORM verarbeitung-verw.
  CASE tab_eingabe-text(3).
    WHEN '010'.
      MOVE: tab_eingabe-text TO verw_anfang.
      CONCATENATE verw_anfang-datum verw_anfang-uitvv verw_anfang-bstvl INTO gv_statement_id. "JASAM.2013.10.24+
    WHEN '050'.
      MOVE: tab_eingabe-text TO verw_btchvoor1.
    WHEN '051'.
      MOVE: tab_eingabe-text TO verw_btchvoor2.
    WHEN '100'.
      MOVE: tab_eingabe-text TO verw_postrec1.
    WHEN '101'.
      MOVE: tab_eingabe-text TO verw_eurorec.
    WHEN '105'.
      MOVE: tab_eingabe-text TO verw_postrec2.
    WHEN '110'.
      MOVE:    tab_eingabe-text TO verw_omsrec.
      APPEND   verw_omsrec.
    WHEN '500'.
      MOVE: tab_eingabe-text TO verw_bgcrec1.
    WHEN '505'.
      MOVE: tab_eingabe-text TO verw_naamrec.
    WHEN '510'.
      MOVE: tab_eingabe-text TO verw_adresrec.
    WHEN '515'.
      MOVE: tab_eingabe-text TO verw_woonrec.
    WHEN '600'.
      MOVE: tab_eingabe-text TO verw_bgcrec2.
    WHEN '950'.
      MOVE: tab_eingabe-text TO verw_btch_sluss.
    WHEN '990'.
      MOVE: tab_eingabe-text TO verw_datei_sluss.
  ENDCASE.
ENDFORM.                    "VERARBEITUNG-VERW

*---------------------------------------------------------------------*
* rueksetzen felder GMU
*---------------------------------------------------------------------*
FORM init_gmu.
  PERFORM clear_umsatz.
  CLEAR: gmu_transactie,
         gmu_euro,
         gmu_storting,
         gmu_overschrijving_bij,
         gmu_overschrijving_af_a,
         gmu_overschrijving_af_b,
         gmu_acceptgiro_bij,
         gmu_acgs_record,
         gmu_acgb_record,
         gmu_intercompany,
         gmu_inkasso_bij,
         gmu_toonbank,
         gmu_geldopname,
         gmu_cheque,
         gmu_sammel_ueber_ab,
         gmu_point_of_sale,
         gmu_pak_kaarten,
         gmu_inkasso_p_p,
         gmu_diversen_rec,
         gmu_specificatie,
*  SEPA_03
*         gmu_betalingskenmerk,
*         gmu_naam,
*         gmu_adres,
*         gmu_ort,
*         gmu_specificatie_text.
*  REFRESH gmu_specificatie_text.
        gmu_specificatie_0400,
        gmu_specificatie_0420,
        gmu_specificatie_0425,
        gmu_specificatie_0440,
        gmu_specificatie_0450,
        gmu_specificatie_0500,
        gmu_specificatie_0510,
        gmu_specificatie_0520,
        gmu_specificatie_0530,
        gmu_specificatie_0540,
        gmu_specificatie_0550,
        gmu_specificatie_0560.

  REFRESH: gmu_specificatie_0425_tab,
       gmu_specificatie_0435_tab,
       gmu_specificatie_0510_tab,
       gmu_specificatie_0520_tab,
       gmu_specificatie_0550_tab.
ENDFORM.                    "INIT_GMU

*---------------------------------------------------------------------*
* rueksetzen felder VERW
*---------------------------------------------------------------------*
FORM init_verw.
  PERFORM clear_umsatz.
  CLEAR: verw_postrec1,
         verw_eurorec,
         verw_postrec2,
         verw_omsrec,
         verw_bgcrec1,
         verw_naamrec,
         verw_adresrec,
         verw_woonrec,
         verw_bgcrec2.
  REFRESH: verw_omsrec.
ENDFORM.                    "INIT_VERW
*---------------------------------------------------------------------*
* rueksetzen felder BGC
*---------------------------------------------------------------------*
FORM init_mt940.
  PERFORM clear_umsatz.
  CLEAR: mt940_transactie,
         mt940_betalingskenmerk,
         h_text,
         h_agkto.
  REFRESH: mt940_omschrijving.
ENDFORM.                                                    "INIT_MT940
*---------------------------------------------------------------------*
* clear umsatz fuer felder
*---------------------------------------------------------------------*
FORM clear_umsatz.
  CLEAR: umsatz-bank,
         umsatz-ktonr,
         umsatz-aznum,
         umsatz-valut,
         umsatz-prima,
         umsatz-vwz01,
         umsatz-butxt,
         umsatz-uzeit,
         umsatz-tschl,
         umsatz-schnr,
         umsatz-wrbtr,
         umsatz-sampo,
         umsatz-folgs,
         umsatz-budat,
         umsatz-zinf1,
         umsatz-zinf2,
         umsatz-vwz02,
         umsatz-vwz03,
         umsatz-vwz04,
         umsatz-vwz05,
         umsatz-vwz06,
         umsatz-vwz07,
         umsatz-vwz08,
         umsatz-vwz09,
         umsatz-vwz10,
         umsatz-vwz11,
         umsatz-vwz12,
         umsatz-vwz13,
         umsatz-vwz14,
         umsatz-aufg1,
         umsatz-aufg2,
         umsatz-agbnk,
         umsatz-agkto,
         umsatz-gcode,
         umsatz-storn.
ENDFORM.                    "CLEAR_UMSATZ

*---------------------------------------------------------------------*
* transactie-verw
*---------------------------------------------------------------------*
FORM transactie-verw.
  CLEAR: h_verwz.
* valutadatum und vereff.dat
  date_yymmdd                =  verw_anfang-datum.
  MOVE-CORRESPONDING date_yymmdd
                             TO date_ddmmyy.
  WRITE: date_ddmmyy         TO umsatz-valut USING EDIT MASK '__.__.__'.

  IF par_cdat IS INITIAL.
    WRITE date_ddmmyy         TO auszug-azdat USING EDIT MASK '__.__.__'.
* buchungsdatum post im datei
    date_yymmdd                =  verw_bgcrec1-vedat.
    MOVE-CORRESPONDING date_yymmdd    TO  date_ddmmyy.
    WRITE date_ddmmyy          TO umsatz-budat USING EDIT MASK '__.__.__'.
  ELSE.
    date_ddmmyy+0(2)         =  par_dat+6(2).
    date_ddmmyy+2(4)         =  par_dat+4(2).
    date_ddmmyy+4(2)         =  par_dat+2(2).
    WRITE date_ddmmyy        TO umsatz-budat USING EDIT MASK '__.__.__'.
    WRITE date_ddmmyy        TO auszug-azdat USING EDIT MASK '__.__.__'.
  ENDIF.
* zahlungskenzahl 16 pos
  IF verw_postrec2-kenmr NE space.
    MOVE:  verw_postrec2-kenmr TO umsatz-schnr.      " betaalkenmerk
    ADD 1 TO h_verwz.
    PERFORM verwendungzweck_fuhlen USING h_verwz verw_postrec2-kenmr.
  ENDIF.
* grund der stornierung
* reverse sign
  IF NOT verw_postrec2-reden IS INITIAL.
    MOVE: verw_postrec2-reden      TO umsatz-storn.
  ENDIF.
* reverse description
  IF NOT verw_bgcrec2+3(27) IS INITIAL.
    ADD 1 TO h_verwz.
    PERFORM verwendungzweck_fuhlen
                            USING h_verwz verw_bgcrec2+3(27).
  ENDIF.
  IF NOT verw_bgcrec2+30(5) IS INITIAL.
    ADD 1 TO h_verwz.
    PERFORM verwendungzweck_fuhlen
                            USING h_verwz verw_bgcrec2+30(5).
  ENDIF.
* beschreibung
  CLEAR h_text.
  LOOP AT verw_omsrec.
    CASE sy-tabix.
      WHEN 1.
        MOVE: verw_omsrec-tekst(32) TO h_text+00(32).
      WHEN 2.
        MOVE: verw_omsrec-tekst(32) TO h_text+32(32).
      WHEN 3.
        MOVE: verw_omsrec-tekst(32) TO h_text+64(32).
      WHEN 4.
        MOVE: verw_omsrec-tekst(32) TO h_text+96(32).
    ENDCASE.
  ENDLOOP.
  CONDENSE h_text.
  REFRESH verw_omsrec.

  CALL FUNCTION 'Z_SPLIT_STRING_IN_BLOCKS'
    EXPORTING
      i_input_string       = h_text
      i_block_lenght       = con_split
    TABLES
      e_t_output           = verw_omsrec
    EXCEPTIONS
      string_empty         = 1
      block_lenght_empty   = 2
      block_lenght_invalid = 3
      OTHERS               = 4.
  CLEAR h_tabix.

  LOOP AT verw_omsrec
    WHERE reccd NE space.
    h_tabix = h_tabix + 1.
    ADD 1 TO h_verwz.
    PERFORM verwendungzweck_fuhlen
                        USING h_verwz verw_omsrec(27).
  ENDLOOP.
* name
  IF NOT verw_naamrec-naam1 IS INITIAL.
    ADD 1 TO h_verwz.
    PERFORM verwendungzweck_fuhlen
                            USING h_verwz verw_naamrec-naam1(27).
  ENDIF.
* adresse
  IF NOT verw_adresrec-adres IS INITIAL.
    ADD 1 TO h_verwz.
    PERFORM verwendungzweck_fuhlen
                            USING h_verwz verw_adresrec-adres(27).
  ENDIF.
* ort
  IF NOT verw_woonrec-ort01 IS INITIAL.
    ADD 1 TO h_verwz.
    PERFORM verwendungzweck_fuhlen
                            USING h_verwz verw_woonrec-ort01(27).
  ENDIF.
* setzen interne code abhangig der grund
  CASE verw_bgcrec1-trsrt.
    WHEN '01' OR '02'.                                 " Niet inbaar
      IF verw_bgcrec2-sgncd  IS INITIAL.
        CASE verw_postrec2-reden.
          WHEN '01'.
            MOVE:  'V51'        TO umsatz-gcode(3).   " Admin reden
          WHEN '02'.
            MOVE:  'V52'        TO umsatz-gcode(3).   " Rek vervallen
          WHEN '03'.
            MOVE:  'V53'        TO umsatz-gcode(3).   " Rek niet uitgeg
          WHEN '04'.
            MOVE:  'V54'        TO umsatz-gcode(3).   " Vrij
          WHEN '05'.
            MOVE:  'V55'        TO umsatz-gcode(3).   " geen machtiging
          WHEN '06'.
            MOVE:  'V56'        TO umsatz-gcode(3).   " niet akkoord
          WHEN '07'.
            MOVE:  'V57'        TO umsatz-gcode(3).   " dubbel betaald
          WHEN '08'.
            MOVE:  'V58'        TO umsatz-gcode(3).   " Vrij
          WHEN '09'.
            MOVE:  'V59'        TO umsatz-gcode(3).   " Vrij
*            ' '                 to umsatz-storn,      " incasso storno
        ENDCASE.
      ELSE.
        CLEAR:      h_hex_code,
                    h_char_code.
        h_hex_code  = h_hex_code        +  verw_bgcrec2-sgncd.
        MOVE:         h_hex_code        TO h_char_code.
        MOVE:         h_char_code+3(3)  TO umsatz-gcode(3).
      ENDIF.
    WHEN OTHERS.

      MOVE:  'V01'               TO umsatz-gcode(3).   " Terugboeking
  ENDCASE.

* uebernehmen konto kunde
  IF verw_postrec1-koemp+1(9)       NE auszug-ktonr+1(9).
    MOVE: verw_postrec1-koemp      TO umsatz-agkto.
  ELSEIF  verw_postrec1-konto+1(9)  NE auszug-ktonr+1(9).
    MOVE: verw_postrec1-konto      TO umsatz-agkto.
  ENDIF.

* uebernehmen konto bank
  IF umsatz-agkto(1) EQ 'P'.
    umsatz-agkto(1) =  '0'.
  ENDIF.
  h_agkto = umsatz-agkto.
  CONDENSE: h_agkto.
  SHIFT h_agkto LEFT DELETING LEADING zeros.

* IF UMSATZ-AGKTO(1) EQ '0'.
  IF h_agkto+7(3)    NE space.
    umsatz-agbnk    = con_bank.
  ELSE.
    umsatz-agkto(1) = '0'.
    WRITE: umsatz-agkto TO umsatz-agkto NO-ZERO.
    CONDENSE umsatz-agkto.
    MOVE:    umsatz-agkto   TO h_pack.
    UNPACK   h_pack         TO umsatz-agkto(7).
    ADD 1 TO h_verwz.
    PERFORM verwendungzweck_fuhlen USING h_verwz umsatz-agkto.
    umsatz-agbnk    = con_post.
  ENDIF.

* uebernehemen betrag
  MOVE: '00000'              TO umsatz-wrbtr(5).
  CONCATENATE verw_postrec1-betrg(11)
              verw_postrec1-betrg+11(2)
              INTO umsatz-wrbtr+3(14) SEPARATED BY '.'.
  CASE verw_btchvoor1-btsrt.
    WHEN 'A'    OR   'B'.
      MOVE: '-'   TO   umsatz-wrbtr+17(1).
  ENDCASE.
*  ENDIF.

**********************************************************
* DONG SPECIFIC CODE
***--->>>*************************************************
  DATA: lv_blnr(12) TYPE c.
  lv_blnr = verw_postrec2-bronn+7.
  IF lv_blnr(2) = '16'            " starts with 16
  AND lv_blnr(12) CO '0123456789'. " only numbers.
*   Then we have the document reference.
    CONCATENATE 'B' lv_blnr INTO umsatz-zinf1.
  ENDIF.

* Set directly in the HEADER record.
  auszug-ktokl = verw_bgcrec1-trsrt.

***<<<---*************************************************


* uebernehmen aufbereitete satz im tabelle
  APPEND umsatz TO gt_umsatz.                             "JASAM.2013.09.19+
  tab_umsatz-text = umsatz.
  APPEND tab_umsatz.
ENDFORM.                    "TRANSACTIE-VERW

*---------------------------------------------------------------------*
*       FORM TRANSACTIE-MT940                                         *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM transactie-mt940.

* SEPA_03 IZBOG BEGIN
  DATA: lv_86_full  TYPE string.
  DATA: lt_codewords TYPE TABLE OF zmt940_codewords_result.
* SEPA_03 IZBOG END

  IF par_cdat IS INITIAL.
    date_ddmmyy+0(2)         =  mt940_transactie-record+12(2).
    date_ddmmyy+2(4)         =  mt940_transactie-record+10(2).
    date_ddmmyy+4(2)         =  mt940_transactie-record+4(2).
    WRITE date_ddmmyy        TO auszug-azdat USING EDIT MASK '__.__.__'.
  ELSE.
    date_ddmmyy+0(2)         =  par_dat+6(2).
    date_ddmmyy+2(4)         =  par_dat+4(2).
    date_ddmmyy+4(2)         =  par_dat+2(2).
    WRITE date_ddmmyy        TO auszug-azdat USING EDIT MASK '__.__.__'.
  ENDIF.
  date_ddmmyy+0(2)         =  mt940_transactie-record+8(2).
  date_ddmmyy+2(4)         =  mt940_transactie-record+6(2).
  date_ddmmyy+4(2)         =  mt940_transactie-record+4(2).
  WRITE date_ddmmyy        TO umsatz-valut USING EDIT MASK '__.__.__'.

*** DONG SPECIFIC CODE
*** There is only one year in the file but 2 dates. So if the second
*** date is less than the first we add 1 year!
*** modified to only add one year if is month 01 and 12.
  DATA: lv_year2(2) TYPE n.
*  IF  MT940_TRANSACTIE-record+6(2) > MT940_TRANSACTIE-record+10(2)
  IF  mt940_transactie-record+6(2) = '12'
  AND mt940_transactie-record+10(2) = '01'.
    date_ddmmyy+0(2) = mt940_transactie-record+12(2).
    date_ddmmyy+2(4) = mt940_transactie-record+10(2).
    lv_year2 = mt940_transactie-record+4(2) + 1.
    date_ddmmyy+4(2) = lv_year2.
    WRITE date_ddmmyy        TO auszug-azdat USING EDIT MASK '__.__.__'.
  ENDIF.

  IF mt940_betalingskenmerk-record+16(16) CO '0123456789'.
    MOVE: mt940_betalingskenmerk-record+16(16)  TO umsatz-schnr.
  ENDIF.
  MOVE:  h_gcode                               TO umsatz-gcode,
         h_wrbtr                               TO umsatz-wrbtr.

  umsatz-agkto       = h_agkto.
  IF umsatz-agkto(1)     EQ '0'.
    umsatz-agbnk        =  con_bank.
  ELSEIF umsatz-agkto(1) EQ 'P'.
    umsatz-agkto(1)     =  '0'.
    umsatz-agkto        = umsatz-agkto+1(7).
    umsatz-agbnk        =  con_post.
  ENDIF.
  CLEAR h_text.
  IF NOT ( mt940_omschrijving IS INITIAL ).
* SEPA_03 IZBOG BEGIN - add a new logic, for the new row layout
* check if the line (only type ':86:' is with key-codes of not.
* prepare the data - concatenate all rows into one string
    CLEAR lv_86_full .
    LOOP AT mt940_omschrijving.
      IF mt940_omschrijving(4) = ':86:'.
        " begin of a section, always stars from ':86:'
        lv_86_full = mt940_omschrijving+4.
      ELSEIF mt940_omschrijving(4) <> ':28C'. "without this line
        CONCATENATE lv_86_full mt940_omschrijving INTO lv_86_full.
      ENDIF.
    ENDLOOP.
* line :86: is prepared in lv_86_full - check if it is structured with code words or not.
    FREE lt_codewords.
    REPLACE ALL OCCURRENCES OF ';' IN lv_86_full WITH ''.
    PERFORM split_row_codewords USING ':86:' lv_86_full
            CHANGING lt_codewords.


    IF lt_codewords IS NOT INITIAL.
* codewords exist in the line 86, they should be mapped
      PERFORM new_86_mapping USING lt_codewords. "and changing umsatz
    ELSE.
* leave the old logic.
* SEPA_03 IZBOG END.
      LOOP AT mt940_omschrijving.
        CONDENSE mt940_omschrijving.
        CASE sy-tabix.
          WHEN 1.
            MOVE: mt940_omschrijving+4(36) TO h_text+00(36).
          WHEN 2.
            MOVE: mt940_omschrijving(40)   TO h_text+36(40).
          WHEN 3.
            MOVE: mt940_omschrijving(40)   TO h_text+76(40).
          WHEN 4.
            MOVE: mt940_omschrijving(40)   TO h_text+116(40).
          WHEN 5.
            MOVE: mt940_omschrijving(40)   TO h_text+156(40).
* -->> XJECH 02.02.2011
          WHEN 6.
            MOVE: mt940_omschrijving(40)   TO h_text+196(40).
          WHEN 7.
            MOVE: mt940_omschrijving(40)   TO h_text+236(40).
          WHEN 8.
            MOVE: mt940_omschrijving(40)   TO h_text+276(40).
          WHEN 9.
            MOVE: mt940_omschrijving(40)   TO h_text+316(40).
          WHEN 10.
            MOVE: mt940_omschrijving(40)   TO h_text+356(40).
          WHEN 11.
            MOVE: mt940_omschrijving(40)   TO h_text+396(40).
          WHEN 12.
            MOVE: mt940_omschrijving(40)   TO h_text+436(40).
          WHEN 13.
            MOVE: mt940_omschrijving(40)   TO h_text+476(40).
          WHEN 14.
            MOVE: mt940_omschrijving(40)   TO h_text+516(40).
          WHEN 15.
            MOVE: mt940_omschrijving(40)   TO h_text+556(40).
** <<-- XJECH 02.02.2011
        ENDCASE.
      ENDLOOP.

************************************************************************
*     DONG SPECIFIC CODE
***--->>>***************************************************************
      PERFORM get_document_ref_dong USING h_text
                                    CHANGING umsatz-zinf1.

*    IF h_shkzg EQ 'D'.                "JASAM.2013.09.12- Moved down outside IF block
**       set minus sign.
*      CONCATENATE umsatz-wrbtr+1
*                  '-'
*                  INTO umsatz-wrbtr.
*    ENDIF.
***<<<---***************************************************************



      IF umsatz-schnr IS INITIAL.
        SEARCH h_text FOR 'BETALINGSKENM'.
        IF sy-fdpos NE 0.
          l = sy-fdpos + 17.
          MOVE: h_text+l  TO umsatz-schnr+0(16).
          IF NOT umsatz-schnr CO '0123456789'.
            CLEAR umsatz-schnr.
          ENDIF.
        ENDIF.
      ENDIF.

      CONDENSE h_text.

************************************************************************
*     DONG SPECIFIC CODE
*     Do not break words in each block/line
***--->>>***************************************************************
*    MOVE: h_text(27)     TO umsatz-vwz01,
*          h_text+27(27)  TO umsatz-vwz02,
*          h_text+54(27)  TO umsatz-vwz03,
*          h_text+81(27)  TO umsatz-vwz04,
*          h_text+108(27) TO umsatz-vwz05.
      DATA:  lt_words TYPE string OCCURS 0 WITH HEADER LINE,
             lv_line(132) TYPE c,
             lv_line_temp(132) TYPE c,
*       lv_len type i,
             lv_lin_num TYPE i.
      .
      SPLIT h_text AT space INTO TABLE lt_words.
      LOOP AT lt_words.
        IF lv_line IS INITIAL.
          lv_line_temp = lt_words.
        ELSE.
          CONCATENATE lv_line lt_words INTO lv_line_temp
          SEPARATED BY space.
        ENDIF.

        IF strlen( lv_line_temp )  > 27
        AND NOT lv_line IS INITIAL.
*           Flush
          ADD 1 TO lv_lin_num.
          CASE lv_lin_num.
            WHEN 1.  umsatz-vwz01 = lv_line.
            WHEN 2.  umsatz-vwz02 = lv_line.
            WHEN 3.  umsatz-vwz03 = lv_line.
            WHEN 4.  umsatz-vwz04 = lv_line.
            WHEN 5.  umsatz-vwz05 = lv_line.
            WHEN 6.  umsatz-vwz06 = lv_line.
            WHEN 7.  umsatz-vwz07 = lv_line.
            WHEN 8.  umsatz-vwz08 = lv_line.
            WHEN 9.  umsatz-vwz09 = lv_line.
            WHEN 10. umsatz-vwz10 = lv_line.
            WHEN 11. umsatz-vwz11 = lv_line.
            WHEN 12. umsatz-vwz12 = lv_line.
            WHEN 13. umsatz-vwz13 = lv_line.
            WHEN 14. umsatz-vwz14 = lv_line.
          ENDCASE.
          lv_line_temp = lt_words.   " first word that spilled over.
        ENDIF.
        lv_line = lv_line_temp.
      ENDLOOP.
      IF NOT lv_line IS INITIAL.
        ADD 1 TO lv_lin_num.
        CASE lv_lin_num.
          WHEN 1. umsatz-vwz01 = lv_line.
          WHEN 2. umsatz-vwz02 = lv_line.
          WHEN 3. umsatz-vwz03 = lv_line.
          WHEN 4. umsatz-vwz04 = lv_line.
          WHEN 5. umsatz-vwz05 = lv_line.
          WHEN 6.  umsatz-vwz06 = lv_line.
          WHEN 7.  umsatz-vwz07 = lv_line.
          WHEN 8.  umsatz-vwz08 = lv_line.
          WHEN 9.  umsatz-vwz09 = lv_line.
          WHEN 10. umsatz-vwz10 = lv_line.
          WHEN 11. umsatz-vwz11 = lv_line.
          WHEN 12. umsatz-vwz12 = lv_line.
          WHEN 13. umsatz-vwz13 = lv_line.
          WHEN 14. umsatz-vwz14 = lv_line.
        ENDCASE.
      ENDIF.

***<<<---***************************************************************
    ENDIF. "SEPA_03 IZBOG 06082013 end of an "old" logic

    IF h_shkzg EQ 'D'.  "JASAM.2013.09.12+
* set minus sign.
      CONCATENATE umsatz-wrbtr+1 '-' INTO umsatz-wrbtr.
    ENDIF.

  ENDIF.
  APPEND umsatz TO gt_umsatz.                             "JASAM.2013.09.19+
  tab_umsatz-text = umsatz.
  APPEND tab_umsatz.
ENDFORM.                    "TRANSACTIE-MT940


*&--------------------------------------------------------------------*
*&      Form  GET_DOCUMENT_REF_DONG
*&--------------------------------------------------------------------*
*       text
*---------------------------------------------------------------------*
*      -->P_TEXT     text
*      -->P_INFO1    text
*---------------------------------------------------------------------*
FORM get_document_ref_dong USING p_text
                           CHANGING p_info1.
  DATA: lt_text(255) OCCURS 0 WITH HEADER LINE.



***************************************************
*  Se if there is a document number in the line.
***************************************************

  SPLIT p_text AT ',' INTO TABLE lt_text.
* find last text.
  LOOP AT lt_text.
  ENDLOOP.
  CONDENSE lt_text.

  IF lt_text+12 IS INITIAL         " only 12 positions
  AND lt_text(2) = '16'            " starts with 16
  AND lt_text(12) CO '0123456789'. " only numbers.
*   Then we have the document reference.
    CONCATENATE 'B' lt_text INTO p_info1.
    EXIT.
  ENDIF.


ENDFORM.                    "GET_DOCUMENT_REF_DONG

*---------------------------------------------------------------------*
* transactie-gmu
*---------------------------------------------------------------------*
FORM transactie-gmu.

  DATA: lv_texts_concat(378) TYPE c, "+SEPA_03
        lv_texts_temp(378) TYPE c,
        lv_adres_tmp(40) TYPE c.
  IF par_cdat IS INITIAL.
    date_yymmdd              =  gmu_transactie-budat+2(6).
    MOVE-CORRESPONDING       date_yymmdd TO date_ddmmyy.
    WRITE: date_ddmmyy       TO umsatz-valut USING EDIT MASK '__.__.__',
           date_ddmmyy       TO auszug-azdat USING EDIT MASK '__.__.__'.
  ELSE.
    date_yymmdd              =  gmu_transactie-budat+2(6).
    MOVE-CORRESPONDING       date_yymmdd TO date_ddmmyy.
    WRITE: date_ddmmyy       TO umsatz-valut USING EDIT MASK '__.__.__'.
    date_ddmmyy+0(2)         =  par_dat+6(2).
    date_ddmmyy+2(4)         =  par_dat+4(2).
    date_ddmmyy+4(2)         =  par_dat+2(2).
    WRITE date_ddmmyy        TO auszug-azdat USING EDIT MASK '__.__.__'.
  ENDIF.
  MOVE:  '000000'          TO umsatz-wrbtr(6).

* SG Inserted 08-08-2005: Debet / Credit boeking wijzigen
  CASE gmu_transactie-soort.
    WHEN 'INCB'.
      IF gmu_inkasso_bij CS 'INCT'.
        CONCATENATE gmu_transactie-betrg(10)
                    gmu_transactie-betrg+10(2)
                    INTO umsatz-wrbtr+5 SEPARATED BY '.'.
      ELSE.
        CONCATENATE gmu_transactie-betrg(10)
                    gmu_transactie-betrg+10(2)
                    INTO umsatz-wrbtr+4 SEPARATED BY '.'.
        MOVE: '-'   TO   umsatz-wrbtr+17(1).
      ENDIF.
* SG Insert 15-09-2005: add OVSA code
    WHEN 'OVSA'.
* WH Insert 13-12-2005 add VOVC code
      IF gmu_overschrijving_af_a CS 'VOVC'
         OR gmu_overschrijving_af_a CS 'TBKB'.
        CONCATENATE gmu_transactie-betrg(10)
                    gmu_transactie-betrg+10(2)
                   INTO umsatz-wrbtr+4 SEPARATED BY '.'.
      ELSE.
        CONCATENATE gmu_transactie-betrg(10)
                    gmu_transactie-betrg+10(2)
               INTO umsatz-wrbtr+4 SEPARATED BY '.'.
        MOVE: '-'   TO   umsatz-wrbtr+17(1).
      ENDIF.
*/SG Insert
    WHEN 'DIVS'.
      IF gmu_diversen_rec-ssoort CS 'RCHA'.
        CONCATENATE gmu_transactie-betrg(10)
                    gmu_transactie-betrg+10(2)
                    INTO umsatz-wrbtr+4 SEPARATED BY '.'.
        MOVE: '-'   TO   umsatz-wrbtr+17(1).
      ELSE.
        CONCATENATE gmu_transactie-betrg(10)
                    gmu_transactie-betrg+10(2)
                    INTO umsatz-wrbtr+5 SEPARATED BY '.'.
      ENDIF.
    WHEN OTHERS.
      IF gmu_overschrijving_af_a CS 'VOVA'.
        CONCATENATE gmu_transactie-betrg(10)
                    gmu_transactie-betrg+10(2)
                    INTO umsatz-wrbtr+4 SEPARATED BY '.'.
        MOVE: '-'   TO   umsatz-wrbtr+17(1).
      ELSE.
        CONCATENATE gmu_transactie-betrg(10)
                    gmu_transactie-betrg+10(2)
                    INTO umsatz-wrbtr+5 SEPARATED BY '.'.
      ENDIF.
  ENDCASE.

  IF NOT ( gmu_inkasso_bij IS INITIAL ).
*      move:  ST_TEXT                to H_TEXT+224,       " xjech 20100304
    MOVE:  st_text                TO h_text+315,       " xjech 20100304
          gmu_inkasso_bij-reden  TO umsatz-storn.
  ENDIF.

  CASE gmu_transactie-soort.
    WHEN 'STOR'.
      MOVE: 'A'            TO umsatz-gcode(1).
      CASE gmu_storting-ssoort.
        WHEN 'STAB'.
          MOVE: '01'       TO umsatz-gcode+1(2).
        WHEN 'STEB'.
          MOVE: '02'       TO umsatz-gcode+1(2).
        WHEN 'STFB'.
          MOVE: '03'       TO umsatz-gcode+1(2).
      ENDCASE.
    WHEN 'OVSB'.
      MOVE: 'B'            TO umsatz-gcode(1).
      CASE gmu_overschrijving_bij-ssoort.
        WHEN 'OVSB'.
          MOVE: '01'       TO umsatz-gcode+1(2).
        WHEN 'VOVB'.
          MOVE: '02'       TO umsatz-gcode+1(2).
        WHEN 'POVB'.
          MOVE: '03'       TO umsatz-gcode+1(2).
        WHEN 'GOVB'.
          MOVE: '04'       TO umsatz-gcode+1(2).
        WHEN 'GRFB'.
          MOVE: '05'       TO umsatz-gcode+1(2).
        WHEN 'EOVB'.
          MOVE: '06'       TO umsatz-gcode+1(2).
        WHEN 'BOVB'.
          MOVE: '07'       TO umsatz-gcode+1(2).
      ENDCASE.

    WHEN 'OVSA'.
      MOVE: 'C'            TO umsatz-gcode(1).
      CASE gmu_overschrijving_af_a-ssoort.
        WHEN 'OVSA'.
          MOVE: '01'       TO umsatz-gcode+1(2).
        WHEN 'TBKB'.
          MOVE: '02'       TO umsatz-gcode+1(2).
        WHEN 'VOVA'.
          MOVE: '03'       TO umsatz-gcode+1(2).
          lv_texts_concat = 'Excasso totaal-af'.
        WHEN 'VOVC'.
          MOVE: '04'       TO umsatz-gcode+1(2).
        WHEN 'ACGA'.
          MOVE: '05'       TO umsatz-gcode+1(2).
        WHEN 'POVA'.
          MOVE: '06'       TO umsatz-gcode+1(2).
        WHEN 'GOVA'.
          MOVE: '07'       TO umsatz-gcode+1(2).
        WHEN 'GRFA'.
          MOVE: '08'       TO umsatz-gcode+1(2).
        WHEN 'EOVA'.
          MOVE: '09'       TO umsatz-gcode+1(2).
        WHEN 'BOVA'.
          MOVE: '10'       TO umsatz-gcode+1(2).
        WHEN 'INCA'.
          MOVE: '11'       TO umsatz-gcode+1(2).
        WHEN 'INCE'.
          MOVE: '12'       TO umsatz-gcode+1(2).
      ENDCASE.
    WHEN 'ACCB'.
      MOVE: 'D'            TO umsatz-gcode(1).
      CASE gmu_acceptgiro_bij-ssoort.
        WHEN 'ACGS'.
          MOVE: '01'       TO umsatz-gcode+1(2).
        WHEN 'ACGB'.
          MOVE: '02'       TO umsatz-gcode+1(2).
        WHEN 'TAGB'.
          MOVE: '03'       TO umsatz-gcode+1(2).
      ENDCASE.
    WHEN 'AINT'.
      MOVE: 'E'            TO umsatz-gcode(1).
      CASE gmu_intercompany-ssoort.
        WHEN 'FOVB'.
          MOVE: '01'       TO umsatz-gcode+1(2).
        WHEN 'FOVA'.
          MOVE: '02'       TO umsatz-gcode+1(2).
        WHEN 'COVB'.
          MOVE: '03'       TO umsatz-gcode+1(2).
        WHEN 'COVA'.
          MOVE: '04'       TO umsatz-gcode+1(2).
      ENDCASE.
    WHEN 'INCB'.
      MOVE: 'F'            TO umsatz-gcode(1).
      CASE gmu_inkasso_bij-ssoort.
        WHEN 'INCT'.
          MOVE: '01'       TO umsatz-gcode+1(2).
          lv_texts_concat = 'Incasso totaal-bij'.
        WHEN 'INCC'.
          CASE gmu_inkasso_bij-hasht.
            WHEN '00000000'.
              CASE gmu_inkasso_bij-reden.
                WHEN 'A'.
                  MOVE: '5A' TO umsatz-gcode+1(2). "niet uitvoerbaar
                WHEN 'B'.
                  MOVE: '5B' TO umsatz-gcode+1(2). "naam/nummer niet kor
                WHEN 'C'.
                  MOVE: '5C' TO umsatz-gcode+1(2). "rek.nr.niet acc.
                WHEN 'D'.
                  MOVE: '5D' TO umsatz-gcode+1(2). "mutatie niet toeges.
                WHEN 'E'.
                  MOVE: '5E' TO umsatz-gcode+1(2). "intrekking debit.
                WHEN 'F'.
                  MOVE: '5F' TO umsatz-gcode+1(2). "geen machteging
                WHEN 'G'.
                  MOVE: '5G' TO umsatz-gcode+1(2). "dubbel betaald
                WHEN 'H'.
                  MOVE: '5H' TO umsatz-gcode+1(2). "niet akkoord
                WHEN 'I'.
                  MOVE: '5I' TO umsatz-gcode+1(2). "intrekking opdr.
                WHEN 'J'.
                  MOVE: '6J' TO umsatz-gcode+1(2). "Vrij
                WHEN 'K'.
                  MOVE: '6K' TO umsatz-gcode+1(2). "Invalid file format
                WHEN 'L'.
                  MOVE: '6L' TO umsatz-gcode+1(2). "Incorrect account number (IBAN)
                WHEN 'M'.
                  MOVE: '6M' TO umsatz-gcode+1(2). "Closed account number
                WHEN 'N'.
                  MOVE: '6N' TO umsatz-gcode+1(2). "Blocked account
                WHEN 'O'.
                  MOVE: '6O' TO umsatz-gcode+1(2). "Transaction forbidden
* SEPA_03 IZBOG BEGIN 06082013
* new codes
                WHEN 'P'.
                  MOVE: '6P' TO umsatz-gcode+1(2). "Missing creditor address
                WHEN 'Q'.
                  MOVE: '6Q' TO umsatz-gcode+1(2). "Regulatory reason
                WHEN 'R'.
                  MOVE: '6R' TO umsatz-gcode+1(2). "Cancelled on customers request
                WHEN 'S'.
                  MOVE: '6S' TO umsatz-gcode+1(2). "Administrative reason
                WHEN 'T'.
                  MOVE: '6T' TO umsatz-gcode+1(2). "Mandate information incomplete
                WHEN 'U'.
                  MOVE: '7U' TO umsatz-gcode+1(2). "Invalid bank operation code
                WHEN 'V'.
                  MOVE: '7V' TO umsatz-gcode+1(2). "Invalid file format
                WHEN 'W'.
                  MOVE: '7W' TO umsatz-gcode+1(2). "BIC not accepted
* SEPA_03 IZBOG END 06082013
              ENDCASE.
            WHEN OTHERS.
              MOVE: '12'       TO umsatz-gcode+1(2). "niet geboekt storn
          ENDCASE.
*          IF NOT gmu_betalingskenmerk IS INITIAL. "-SEPA_03 field not used
*            MOVE: ' '        TO umsatz-storn. "-SEPA_03 field not used
*          ENDIF. "-SEPA_03 field not used
      ENDCASE.
    WHEN 'TOON'.
      MOVE: 'G'            TO umsatz-gcode(1).
      CASE gmu_toonbank-ssoort.
        WHEN 'POST'.
          MOVE: '01'       TO umsatz-gcode+1(2).
        WHEN 'POSA'.
          MOVE: '02'       TO umsatz-gcode+1(2).
        WHEN 'GBKB'.
          MOVE: '03'       TO umsatz-gcode+1(2).
        WHEN 'GBKA'.
          MOVE: '04'       TO umsatz-gcode+1(2).
        WHEN 'GBKC'.
          MOVE: '05'       TO umsatz-gcode+1(2).
        WHEN 'GBKP'.
          MOVE: '06'       TO umsatz-gcode+1(2).
        WHEN 'BECB'.
          MOVE: '07'       TO umsatz-gcode+1(2).
      ENDCASE.
    WHEN 'OPNM'.
      MOVE: 'H'            TO umsatz-gcode(1).
      CASE gmu_geldopname-ssoort.
        WHEN 'GBKV'.
          MOVE: '01'       TO umsatz-gcode+1(2).
        WHEN 'KCHA'.
          MOVE: '02'       TO umsatz-gcode+1(2).
        WHEN 'TCHA'.
          MOVE: '03'       TO umsatz-gcode+1(2).
        WHEN 'GUAA'.
          MOVE: '04'       TO umsatz-gcode+1(2).
      ENDCASE.
    WHEN 'CHQS'.
      MOVE: 'I'            TO umsatz-gcode(1).
      CASE gmu_cheque-ssoort.
        WHEN 'CHQA'.
          MOVE: '01'       TO umsatz-gcode+1(2).
        WHEN 'ZCHT'.
          MOVE: '02'       TO umsatz-gcode+1(2).
        WHEN 'ZCHL'.
          MOVE: '03'       TO umsatz-gcode+1(2).
        WHEN 'VZHT'.
          MOVE: '04'       TO umsatz-gcode+1(2).
        WHEN 'VZHU'.
          MOVE: '05'       TO umsatz-gcode+1(2).
        WHEN 'VCHT'.
          MOVE: '06'       TO umsatz-gcode+1(2).
        WHEN 'VCHL'.
          MOVE: '07'       TO umsatz-gcode+1(2).
      ENDCASE.
    WHEN 'VOVD'.
      MOVE: 'J'            TO umsatz-gcode(1).
      CASE gmu_sammel_ueber_ab-ssoort.
        WHEN 'VOVD'.
          MOVE: '01'       TO umsatz-gcode+1(2).
      ENDCASE.
    WHEN 'POSD'.
      MOVE: 'K'            TO umsatz-gcode(1).
      CASE gmu_point_of_sale-ssoort.
        WHEN 'POVD'.
          MOVE: '01'       TO umsatz-gcode+1(2).
      ENDCASE.
    WHEN 'PGBD'.
      MOVE: 'L'            TO umsatz-gcode(1).
      CASE gmu_pak_kaarten-ssoort.
        WHEN 'GBKD'.
          MOVE: '01'       TO umsatz-gcode+1(2).
      ENDCASE.
    WHEN 'INCD'.
      MOVE: 'M'            TO umsatz-gcode(1).
      CASE gmu_inkasso_p_p-ssoort.
        WHEN 'INCD'.
          MOVE: '01'       TO umsatz-gcode+1(2).
      ENDCASE.
    WHEN 'DIVS'.
      MOVE: 'N'            TO umsatz-gcode(1).
      CASE gmu_diversen_rec-ssoort.
        WHEN 'AOVB'.
          MOVE: '01'       TO umsatz-gcode+1(2).
        WHEN 'AOVA'.
          MOVE: '02'       TO umsatz-gcode+1(2).
        WHEN 'TDIA'.
          MOVE: '03'       TO umsatz-gcode+1(2).
        WHEN 'TDEB'.
          MOVE: '04'       TO umsatz-gcode+1(2).
        WHEN 'TDVA'.
          MOVE: '05'       TO umsatz-gcode+1(2).
        WHEN 'RENB'.
          MOVE: '06'       TO umsatz-gcode+1(2).
        WHEN 'RENA'.
          MOVE: '07'       TO umsatz-gcode+1(2).
        WHEN 'RCHA'.
          MOVE: '08'       TO umsatz-gcode+1(2).
        WHEN 'NWZB'.
          MOVE: '09'       TO umsatz-gcode+1(2).
        WHEN 'DSPA'.
          MOVE: '10'       TO umsatz-gcode+1(2).
      ENDCASE.
  ENDCASE.
  IF gmu_transactie-soort   EQ 'OVSB'  OR
     gmu_transactie-soort   EQ 'OVSA'  OR
     gmu_transactie-soort   EQ 'ACCB'  OR
     gmu_transactie-soort   EQ 'INCB'  OR
     gmu_transactie-soort   EQ 'INCD'  OR
     gmu_transactie-soort   EQ 'VOVD'.

    IF gmu_specificatie_0500 IS NOT INITIAL.
      IF gmu_inkasso_bij-ssoort  <> 'INCC' AND
         gmu_inkasso_bij-ssoort  <> 'TBKB' AND
         gmu_inkasso_bij-ssoort  <> 'VOVC'.
        umsatz-gcode+1(1)   = umsatz-gcode+1(1) + 5.
      ENDIF.
    ENDIF.

  ENDIF.
  IF umsatz-gcode IS INITIAL.
    MOVE: 'XXX'           TO umsatz-gcode.
  ENDIF.
*** -SEPA_03 BEGIN IZBOG 30072013
*  IF gmu_transactie-aardt CO '13'.
*    IF gmu_transactie-konte+0(3) EQ '000'.
*      umsatz-vwz01    = gmu_transactie-konte+3(7).
*      umsatz-agkto    = gmu_transactie-konte+3(7).
*      IF umsatz-agkto EQ 0.
*        umsatz-agkto =  '9999999'.
*        umsatz-vwz01 =  '9999999'.
*      ENDIF.
*      umsatz-agbnk    = con_post.
*    ELSE.
*      umsatz-vwz01    = gmu_transactie-konte.
*      umsatz-agkto    = gmu_transactie-konte.
*      IF umsatz-agkto EQ 0.
*        umsatz-agkto =  '9999999999'.
*        umsatz-vwz01 =  '9999999999'.
*      ENDIF.
*      umsatz-agbnk    = con_bank.
*    ENDIF.
*  ELSE.
*    PERFORM get_bank_account
*            USING gmu_transactie-kontz
*            CHANGING umsatz.
****  ENDIF.
*** GMU_OVERSCHRIJVING_AF_B-reden processing
  IF gmu_overschrijving_af_b-reden IS NOT INITIAL.
    MOVE 'F' TO umsatz-gcode(1).
    CASE gmu_overschrijving_af_b-reden.
      WHEN 'A'.
        MOVE: '5A' TO umsatz-gcode+1(2). "niet uitvoerbaar
      WHEN 'B'.
        MOVE: '5B' TO umsatz-gcode+1(2). "naam/nummer niet kor
      WHEN 'C'.
        MOVE: '5C' TO umsatz-gcode+1(2). "rek.nr.niet acc.
      WHEN 'D'.
        MOVE: '5D' TO umsatz-gcode+1(2). "mutatie niet toeges.
      WHEN 'E'.
        MOVE: '5E' TO umsatz-gcode+1(2). "intrekking debit.
      WHEN 'F'.
        MOVE: '5F' TO umsatz-gcode+1(2). "geen machteging
      WHEN 'G'.
        MOVE: '5G' TO umsatz-gcode+1(2). "dubbel betaald
      WHEN 'H'.
        MOVE: '5H' TO umsatz-gcode+1(2). "niet akkoord
      WHEN 'I'.
        MOVE: '5I' TO umsatz-gcode+1(2). "intrekking opdr.
      WHEN 'J'.
        MOVE: '6J' TO umsatz-gcode+1(2). "Vrij
      WHEN 'K'.
        MOVE: '6K' TO umsatz-gcode+1(2). "Invalid file format
      WHEN 'L'.
        MOVE: '6L' TO umsatz-gcode+1(2). "Incorrect account number (IBAN)
      WHEN 'M'.
        MOVE: '6M' TO umsatz-gcode+1(2). "Closed account number
      WHEN 'N'.
        MOVE: '6N' TO umsatz-gcode+1(2). "Blocked account
      WHEN 'O'.
        MOVE: '6O' TO umsatz-gcode+1(2). "Transaction forbidden
      WHEN 'P'.
        MOVE: '6P' TO umsatz-gcode+1(2). "Missing creditor address
      WHEN 'Q'.
        MOVE: '6Q' TO umsatz-gcode+1(2). "Regulatory reason
      WHEN 'R'.
        MOVE: '6R' TO umsatz-gcode+1(2). "Cancelled on customers request
      WHEN 'S'.
        MOVE: '6S' TO umsatz-gcode+1(2). "Administrative reason
      WHEN 'T'.
        MOVE: '6T' TO umsatz-gcode+1(2). "Mandate information incomplete
      WHEN 'U'.
        MOVE: '7U' TO umsatz-gcode+1(2). "Invalid bank operation code
      WHEN 'V'.
        MOVE: '7V' TO umsatz-gcode+1(2). "Invalid file format
      WHEN 'W'.
        MOVE: '7W' TO umsatz-gcode+1(2). "BIC not accepted
    ENDCASE.

  ENDIF.
*** -SEPA_03 END IZBOG 30072013

*** +SEPA_03 BEGIN IZBOG 30072013
* record 0400 processing
  IF gmu_specificatie_0400 IS NOT INITIAL.
* record 0400 is present, transfer IBAN and BIC to umsatz
    umsatz-agkto = gmu_specificatie_0400-iban.
    umsatz-agbnk = gmu_specificatie_0400-bic.
  ELSE.
* record 0400 is not present, use information from record 0100

    CASE gmu_transactie-aardt.
      WHEN '2' OR '4'.
        PERFORM get_bank_account
                USING gmu_transactie-kontz
                CHANGING umsatz.
      WHEN '1' OR '3'  .
        PERFORM get_bank_account
           USING gmu_transactie-konte
           CHANGING umsatz.
      WHEN OTHERS.
    ENDCASE.
  ENDIF.

* record 0420 processing
  IF gmu_specificatie_0420-eteref IS NOT INITIAL
    AND ( ( gmu_transactie-soort  EQ 'INCB' AND gmu_inkasso_bij-ssoort  EQ 'INCC' )
      OR ( gmu_transactie-soort  EQ 'OVSA' AND gmu_overschrijving_af_a-ssoort  EQ 'TBKB' )
      OR ( gmu_transactie-soort  EQ 'OVSA' AND gmu_overschrijving_af_a-ssoort   EQ 'VOVC' ) ).

    CONCATENATE c_return gmu_specificatie_0420-eteref INTO umsatz-zinf1.
* and also mapped to VWZ01 - VWZ014
    PERFORM collect_text USING gmu_specificatie_0420-eteref
          CHANGING lv_texts_concat.
  ENDIF.
* record 0425 processing
* no mapping needed, until at least february 2014
* record 0435 processing
* no mapping needed, until at least february 2014
* record 0440 processing
* mapped to VWZ01 - VWZ014
  IF gmu_specificatie_0440-mandref IS NOT INITIAL.
    PERFORM collect_text USING gmu_specificatie_0440-mandref
          CHANGING lv_texts_concat.
  ENDIF.
* record 0450 processing
* mapped to UMSATZ-ZINF2
  IF gmu_specificatie_0450-rtype IS NOT INITIAL.
    umsatz-zinf2 = gmu_specificatie_0450-rtype.
  ENDIF.
* record 0460 processing
* no mapping needed, until at least february 2014
* record 0470 processing
* no mapping needed, until at least february 2014
* record 0480 processing
* no mapping needed, until at least february 2014
* record 0490 processing
* no mapping needed, until at least february 2014
* record 0500 processing
* mapped  VWZ01 - VWZ014
  IF gmu_specificatie_0500-remittstr IS NOT INITIAL.
*will be inserted into schnr or/and VWZ01 to VWZ014
    IF gmu_specificatie_0500-remittstr(16) CO '0123456789'.
* if first 16 characters are digits, move also to SCHNR
      umsatz-schnr = gmu_specificatie_0500-remittstr.
    ENDIF.
* if characters or not, always move to VWZ01 to VWZ014
    IF gmu_transactie-soort = 'ACCB'.
* we do not want the checkdigit.
      PERFORM collect_text USING gmu_specificatie_0500-remittstr(15)
         CHANGING lv_texts_concat.
    ELSE.
      PERFORM collect_text USING gmu_specificatie_0500-remittstr
         CHANGING lv_texts_concat.
    ENDIF.
  ENDIF.
* record 0510 processing
* mapped to VWZ01 - VWZ014
  CLEAR lv_texts_temp.
  LOOP AT gmu_specificatie_0510_tab INTO gmu_specificatie_0510.
    PERFORM get_document_ref_dong USING gmu_specificatie_0510
                                    CHANGING umsatz-zinf1.
    CONCATENATE lv_texts_temp gmu_specificatie_0510-remittunstr
    INTO lv_texts_temp.
  ENDLOOP.
  PERFORM collect_text USING lv_texts_temp
      CHANGING lv_texts_concat.
* record 0520 processing
* mapped to VWZ01 - VWZ014
  CLEAR lv_texts_temp.
  LOOP AT gmu_specificatie_0520_tab INTO gmu_specificatie_0520.
    CONCATENATE lv_texts_temp gmu_specificatie_0520-debtname
    INTO lv_texts_temp.
  ENDLOOP.
  PERFORM collect_text USING lv_texts_temp
      CHANGING lv_texts_concat.
* record 0530 processing
* mapped to VWZ01 - VWZ014
  CLEAR lv_texts_temp.
* add a '@@' between address - used in a search
  IF gmu_specificatie_0530-adres IS NOT INITIAL
    AND gmu_specificatie_0530-postc IS NOT INITIAL.
    CONDENSE gmu_specificatie_0530-adres.
    CONDENSE gmu_specificatie_0530-postc.
    CONCATENATE gmu_specificatie_0530-adres gmu_specificatie_0530-postc
    INTO lv_adres_tmp SEPARATED BY '@@'.
  ELSE.
    CONCATENATE gmu_specificatie_0530-adres gmu_specificatie_0530-postc
  INTO lv_adres_tmp SEPARATED BY space.
  ENDIF.
  PERFORM collect_text USING lv_adres_tmp
        CHANGING lv_texts_concat.
* record 0540 processing
* mapped to VWZ01 - VWZ014
  CLEAR lv_texts_temp.
  PERFORM collect_text USING gmu_specificatie_0540-ort01
       CHANGING lv_texts_concat.
* record 0550 processing
* mapped to VWZ01 - VWZ014
  CLEAR lv_texts_temp.
  LOOP AT gmu_specificatie_0550_tab INTO gmu_specificatie_0550.
* 550 is concatenated with spaces, or with @@ (2 first lines
    IF sy-tabix = 2.
      CONCATENATE lv_texts_temp gmu_specificatie_0550-debtddress
    INTO lv_texts_temp SEPARATED BY '@@'.
    ELSE.
      CONCATENATE lv_texts_temp gmu_specificatie_0550-debtddress
       INTO lv_texts_temp SEPARATED BY space.
    ENDIF.
  ENDLOOP.
  PERFORM collect_text USING lv_texts_temp
      CHANGING lv_texts_concat.

* record 0560 processing
* mapped to VWZ01 - VWZ014
  PERFORM collect_text USING gmu_specificatie_0560-debtland
       CHANGING lv_texts_concat.
* map texts from lines 0440, 0500, 0510, 0520, 0550 , 0560 into VWZ01 - VWZ014
  SHIFT lv_texts_concat LEFT DELETING LEADING ' '.
  PERFORM texts_to_vzwxx USING lv_texts_concat
        CHANGING umsatz.
*+SEPA_03 END IZBOG 30072013

*** move the data to the table ***
  APPEND umsatz TO gt_umsatz.                             "JASAM.2013.09.19+
  tab_umsatz-text = umsatz.
  APPEND tab_umsatz.
ENDFORM.                    "TRANSACTIE-GMU

*&---------------------------------------------------------------------*
*&      Form  get_bank_account
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->IF_BANKNR    text
*      -->CS_BANK_DET  text
*----------------------------------------------------------------------*
FORM get_bank_account
     USING    if_banknr   TYPE char10
     CHANGING cs_bank_det LIKE LINE OF umsatz.

*-SEPA_03 BEGIN IZBOG 30072013
  IF ( if_banknr CO '0' ).
*   Empty banknumber field, do nothing.
  ELSEIF if_banknr(3) EQ '000'.
    umsatz-vwz01    = if_banknr+3(7).
    umsatz-agkto    = if_banknr+3(7).
    IF umsatz-agkto EQ 0.
      umsatz-agkto =  '9999999'.
      umsatz-vwz01 =  '9999999'.
    ENDIF.
    umsatz-agbnk    = con_post.
  ELSE.
    umsatz-vwz01    = if_banknr.
    umsatz-agkto    = if_banknr.
    IF umsatz-agkto EQ 0.
      umsatz-agkto =  '9999999999'.
      umsatz-vwz01 =  '9999999999'.
    ENDIF.
    umsatz-agbnk    = con_bank.
  ENDIF.
*-SEPA_03 END IZBOG 30072013
* processing changed for SEPA + simplification of a code
*  IF if_banknr(3) EQ '000' AND if_banknr+3(7) CN '0 '.
*    umsatz-agkto    = if_banknr+3(7).
*    umsatz-agbnk    = con_post.
*  ELSE.
*    umsatz-agkto    = if_banknr.
*    umsatz-agbnk    = con_bank.
*  ENDIF.
ENDFORM.                    "get_bank_account

*&---------------------------------------------------------------------*
*&      Form  get_banknr_from_specification
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM get_banknr_from_specification.

* +SEPA_03 BEGIN IZBOG 30072013
* we are not populating kontz from line 0400 under SEPA
*  DATA:
*    lv_is_iban TYPE kennzx.
**
** Only if the original bankaccount number of the payer is empty then
** try to get it from the 0400 specification.
*  IF ( gmu_transactie-kontz CO '0' ).
**    PERFORM is_iban USING gmu_specificatie_0400-specf(18)
**                    CHANGING lv_is_iban.
*    IF ( lv_is_iban IS NOT INITIAL ).
**     It contains an IBAN number from NL.
*      gmu_transactie-kontz = gmu_specificatie_0400-specf+8(10).
*    ENDIF.
*  ENDIF.
* +SEPA_03 END IZBOG 30072013
ENDFORM.                    "get_banknr_from_specification

*&---------------------------------------------------------------------*
*&      Form  is_IBAN
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->IF_IBAN_NR text
*      -->CF_IS_IBAN text
*----------------------------------------------------------------------*
FORM is_iban
     USING if_iban_nr TYPE char18
     CHANGING cf_is_iban TYPE kennzx.

* Check if given IBAN is a Dutch IBAN format.
  CLEAR cf_is_iban.

  IF ( if_iban_nr(2)     = 'NL'         AND
       if_iban_nr+2(2)  CO '0123456789' AND
       if_iban_nr+4(4)  CO sy-abcde     AND
       if_iban_nr+8(10) CO '0123456789' ).
    cf_is_iban = 'X'.
  ENDIF.

ENDFORM.                    "is_IBAN

*---------------------------------------------------------------------*
*       FORM MT940_SPLITS_TRANSACTIE                                  *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM mt940_splits_transactie.

  DATA:  h_pos1 LIKE sy-fdpos,
         h_pos2 LIKE sy-fdpos.

  CLEAR: h_gcode, h_wrbtr, h_shkzg.

  MOVE: mt940_transactie+14(1) TO h_shkzg.

  MOVE: '000000000000000000' TO h_wrbtr.
  SEARCH mt940_transactie-record FOR ','.
  h_pos1 = sy-fdpos - 16 + 1.
  h_pos2 = 16 - h_pos1 - 1.
  sy-fdpos = sy-fdpos + 1.
  MOVE:
    mt940_transactie-record+15(h_pos1)     TO h_wrbtr+h_pos2(h_pos1),
    '.'                                    TO h_wrbtr+15(1),
    mt940_transactie-record+sy-fdpos(2)    TO h_wrbtr+16(2).

* xdael insert start 2009-01-30
* When the decimals is equal to zero, the bank don't send this signs.
* Therefore we have to add the zero sign to the file
  IF h_wrbtr+16(1) NA '0123456789'.
    MOVE '00' TO h_wrbtr+16(2).
  ELSEIF h_wrbtr+17(1) NA '0123456789'.
    MOVE '0' TO h_wrbtr+17(1).
  ENDIF.
* xdael insert end 2009-01-30

* CHG 9689, XSEPL, 19-03-2012, Do not use string NONREF to search but ','.
*  search MT940_TRANSACTIE-RECORD for 'NONREF'.
*  H_POS1 = SY-FDPOS - 3.
  SEARCH mt940_transactie-record FOR ','.
  h_pos1 = sy-fdpos + 4.
* END CHG 9689, XSEPL
  MOVE: mt940_transactie-record+h_pos1(3)  TO h_gcode.

* creditboeking onder intercompany mutatiecode => 196 gewone overschr.
  IF h_gcode EQ '471' AND h_shkzg EQ 'C'.
    h_gcode = '196'.
  ENDIF.
* debetboeking => 439 NTTB debet
  IF h_gcode EQ '407' AND h_shkzg EQ 'D'.
    h_gcode = '439'.
  ENDIF.
ENDFORM.                    "MT940_SPLITS_TRANSACTIE

*---------------------------------------------------------------------*
*      Form  VERWENDUNGZWECK_FUHLEN
*----------------------------------------------------------------------*
*      -->P_H_VERWZ  text
*      -->P_h_input  text
*----------------------------------------------------------------------*
FORM verwendungzweck_fuhlen USING    p_h_verwz
                                     p_h_input.
  CASE p_h_verwz.
    WHEN '1'.
      MOVE: p_h_input       TO umsatz-vwz01.
    WHEN '2'.
      MOVE: p_h_input       TO umsatz-vwz02.
    WHEN '3'.
      MOVE: p_h_input       TO umsatz-vwz03.
    WHEN '4'.
      MOVE: p_h_input       TO umsatz-vwz04.
    WHEN '5'.
      MOVE: p_h_input       TO umsatz-vwz05.
    WHEN '6'.
      MOVE: p_h_input       TO umsatz-vwz06.
    WHEN '7'.
      MOVE: p_h_input       TO umsatz-vwz07.
    WHEN '8'.
      MOVE: p_h_input       TO umsatz-vwz08.
    WHEN '9'.
      MOVE: p_h_input       TO umsatz-vwz09.
    WHEN '10'.
      MOVE: p_h_input       TO umsatz-vwz10.
    WHEN '11'.
      MOVE: p_h_input       TO umsatz-vwz11.
    WHEN '12'.
      MOVE: p_h_input       TO umsatz-vwz12.
    WHEN '13'.
      MOVE: p_h_input       TO umsatz-vwz13.
    WHEN '14'.
      MOVE: p_h_input       TO umsatz-vwz14.
  ENDCASE.
ENDFORM.                    " VERWENDUNGZWECK_FUHLEN
*&---------------------------------------------------------------------*
*&      Form  DONG_GMU_510_FORMATING
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      <--P_GMU_SPECIFICATIE_TEXT  text
*----------------------------------------------------------------------*
FORM dong_gmu_510_formating  CHANGING p_gmu_text.
*** SEPA_03 IZBOG - commented out - not used in SEPA
*  DATA: lv_text(132) TYPE c.
*
***********************************************************************
** IF PAYMENT REFERENCE IS SPLIT into 3 parts condence then into one.
***********************************************************************
*
*
*  lv_text = p_gmu_text.
*
** 0510A3000 1300 0000 2353 *MP*
**          ^    ^    ^    ^
*  IF   lv_text+9(1)  = ' '
*  AND  lv_text+14(1) = ' '
*  AND  lv_text+19(1) = ' '
*  AND  lv_text+24(1) = ' '.
*
** 0510A3000 1300 0000 2353 *MP*
**           ^^^^ ^^^^ ^^^^
*    IF   lv_text+10(4) CO '0123456789'
*    AND  lv_text+15(4) CO '0123456789'
*    AND  lv_text+20(4) CO '0123456789'
**           ^^
*    AND  lv_text+10(2) = '13'.
*
** 0510A3000 1300 0000 2353 *MP*
** ^^^^^^^^^^^^^^ ^^^^ ^^^^^^^^^^^^
**               X    X
*      CONCATENATE lv_text+0(14)
*                  lv_text+15(4)
*                  lv_text+20
*                  INTO p_gmu_text.
** result:
** 0510A3000 130000002353 *MP*
*
*    ENDIF.
*  ENDIF.
***

ENDFORM.                    " DONG_GMU_510_FORMATING
*&---------------------------------------------------------------------*
*&      Form  COLLECT_TEXT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_GMU_SPECIFICATIE_0440_MANDREF  text
*      <--P_LV_TEXTS_CONCAT  text
*----------------------------------------------------------------------*
FORM collect_text  USING    p_text
                   CHANGING p_texts_concat.

  DATA: lv_text_tmp TYPE string.
  lv_text_tmp = p_text.
  CONDENSE lv_text_tmp.
  CONCATENATE p_texts_concat lv_text_tmp INTO
       p_texts_concat SEPARATED BY space.

ENDFORM.                    " COLLECT_TEXT
*&---------------------------------------------------------------------*
*&      Form  TEXTS_TO_VZWXX
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_LV_TEXTS_CONCAT  text
*      <--P_UMSATZ  text
*----------------------------------------------------------------------*
FORM texts_to_vzwxx  USING    p_texts_concat
                     CHANGING p_umsatz.
* SEPA_03 - split texts and map to the correct fields in umzatz file.
  DATA: ls_split_text TYPE char50, "50 is the max for a line
        lt_split_text LIKE TABLE OF ls_split_text.

  CALL FUNCTION 'Z_SPLIT_STRING_IN_BLOCKS'
    EXPORTING
      i_input_string       = p_texts_concat
      i_block_lenght       = con_split "27
    TABLES
      e_t_output           = lt_split_text
    EXCEPTIONS
      string_empty         = 1
      block_lenght_empty   = 2
      block_lenght_invalid = 3
      OTHERS               = 4.
  CLEAR h_tabix.

  LOOP AT lt_split_text INTO ls_split_text.
    h_tabix = h_tabix + 1.
    CASE h_tabix.
      WHEN 1.
        MOVE: ls_split_text TO umsatz-vwz01.
      WHEN 2.
        MOVE: ls_split_text TO umsatz-vwz02.
      WHEN 3.
        MOVE: ls_split_text TO umsatz-vwz03.
      WHEN 4.
        MOVE: ls_split_text TO umsatz-vwz04.
      WHEN 5.
        MOVE: ls_split_text TO umsatz-vwz05.
      WHEN 6.
        MOVE: ls_split_text TO umsatz-vwz06.
      WHEN 7.
        MOVE: ls_split_text TO umsatz-vwz07.
      WHEN 8.
        MOVE: ls_split_text TO umsatz-vwz08.
      WHEN 9.
        MOVE: ls_split_text TO umsatz-vwz09.
      WHEN 10.
        MOVE: ls_split_text TO umsatz-vwz10.
      WHEN 11.
        MOVE: ls_split_text TO umsatz-vwz11.
      WHEN 12.
        MOVE: ls_split_text TO umsatz-vwz12.
      WHEN 13.
        MOVE: ls_split_text TO umsatz-vwz13.
      WHEN 14.
        MOVE: ls_split_text TO umsatz-vwz14.
    ENDCASE.
  ENDLOOP.

ENDFORM.                    " TEXTS_TO_VZWXX
*&---------------------------------------------------------------------*
*&      Form  SPLIT_86_CODEWORDS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_LV_86_FULL  text
*      <--P_LT_CODEWORDS  text
*----------------------------------------------------------------------*
FORM split_row_codewords  USING    p_linetype
                                   p_row_full
                          CHANGING tb_codes_values TYPE zmt940_codewords_result_tab.
* split row 86 according to code words
* code words are stored in a global table  gt_codewords
* look for a code word, if found, find the value for it
* using offset and lenght of a string

  DATA: lv_txtlen TYPE i,
        lv_tblines TYPE i,
        ls_result TYPE match_result,
        lt_result TYPE match_result_tab,
        ls_codes_values TYPE zmt940_codewords_result,
        ls_codes_prev TYPE zmt940_codewords_result,
        ls_codes_next TYPE zmt940_codewords_result,
        ls_codewords TYPE zmt940_codewords,
        lv_offset TYPE int4,
        lv_lenght TYPE int4.


  FIELD-SYMBOLS: <ls_codes_values> TYPE zmt940_codewords_result.
*
  lv_txtlen = strlen( p_row_full ).


  LOOP AT gt_codewords INTO ls_codewords
      WHERE linetype = p_linetype.
    REFRESH lt_result.
* find all occurences of a keyword
    FIND ALL OCCURRENCES OF ls_codewords-codeword
      IN p_row_full
      RESULTS lt_result.
* add them to the table and calculate the offsets
    LOOP AT lt_result INTO ls_result.
      CLEAR ls_codes_values.
      MOVE-CORRESPONDING ls_codewords TO ls_codes_values.
      ls_codes_values-offset = ls_result-offset.
      ls_codes_values-length = ls_result-length.
      ls_codes_values-start = ls_result-offset + ls_result-length.
      INSERT ls_codes_values INTO TABLE tb_codes_values.
    ENDLOOP.
  ENDLOOP.

* prepare the table for further checks
  DELETE tb_codes_values WHERE length = 0.
  SORT tb_codes_values BY start covered ASCENDING.
*
* additional loop to delete overlapped codes
  LOOP AT tb_codes_values INTO ls_codes_values WHERE covered = 'X'.
    CHECK sy-tabix  > 1.
    READ TABLE tb_codes_values INTO ls_codes_prev INDEX sy-tabix - 1.
*  if field start is the same, delete the row
    IF ls_codes_values-start = ls_codes_prev-start.
      DELETE tb_codes_values INDEX sy-tabix + 1.
    ENDIF.
  ENDLOOP.

* now, find the values
  DESCRIBE TABLE tb_codes_values LINES lv_tblines.

  LOOP AT tb_codes_values ASSIGNING <ls_codes_values>.
    CLEAR: lv_offset, lv_lenght, ls_codes_next.
    IF sy-tabix < lv_tblines.
* use the next row for finding an end of a value
      READ TABLE tb_codes_values INTO ls_codes_next INDEX sy-tabix + 1.
      lv_lenght = ls_codes_next-offset - <ls_codes_values>-start.
    ELSE.
* for the last row processing can't use a next row
* end of a string should be taken into calculation
      lv_lenght = lv_txtlen - <ls_codes_values>-start.
    ENDIF.
* value = row+start(lenght)
    <ls_codes_values>-value = p_row_full+<ls_codes_values>-start(lv_lenght).
  ENDLOOP.
ENDFORM.                    " SPLIT_86_CODEWORDS
*&---------------------------------------------------------------------*
*&      Form  SELECT_KEYCODES
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM select_keycodes .

  DATA: ls_codewords TYPE zmt940_codewords.

  SELECT * FROM zmt940_codewords
    INTO TABLE gt_codewords.

* additional loop to add sub codes
  LOOP AT gt_codewords INTO  ls_codewords
    WHERE subcode IS NOT INITIAL AND
     subcode <> 'X'.
    ls_codewords-codeword = ls_codewords-subcode.
    ls_codewords-subcode = 'X'.
    ls_codewords-covered = ''.
    APPEND ls_codewords TO gt_codewords.
  ENDLOOP.

ENDFORM.                    " SELECT_KEYCODES

*&---------------------------------------------------------------------*
*&      Form  select_mutationcodes
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM select_mutationcodes .

  DATA: ls_mutcode TYPE zmutcode_mapping.

  SELECT * FROM zmutcode_mapping
    INTO TABLE gt_mutcode
    WHERE zrtype <> ''.


ENDFORM.                    " SELECT_KEYCODES
*&---------------------------------------------------------------------*
*&      Form  NEW_86_MAPPING
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_LT_CODEWORDS  text
*----------------------------------------------------------------------*
FORM new_86_mapping  USING    pt_codewords TYPE zmt940_codewords_result_tab.
* SEPA_03 IZBOG 06082013
* new mapping of row type :86: to umsatz, based on keywords
  TYPES: BEGIN OF ty_aufg,
         code1 LIKE umsatz-aufg1,
         code2 LIKE umsatz-aufg2,
       END OF ty_aufg.

  DATA: ls_aufg TYPE ty_aufg.
  DATA: ls_codewords TYPE zmt940_codewords_result,
        ls_codewords_rtrn TYPE zmt940_codewords_result,
        ls_subcode TYPE zmt940_codewords_result.
  DATA: lv_texts_concat(378) TYPE c,
        lv_remi_value(140) TYPE c,
        ls_mutcode TYPE zmutcode_mapping.

  LOOP AT pt_codewords INTO ls_codewords
    WHERE value IS NOT INITIAL.
    CASE ls_codewords-codeword.
      WHEN '/IBAN/'.
        umsatz-agkto = ls_codewords-value.
      WHEN '/BIC/'.
        umsatz-agbnk = ls_codewords-value.
      WHEN '/NAME/'.
* split per 2 parts of lenght 27 and move to AUGF1 and AUFG2.
        MOVE ls_codewords-value TO ls_aufg. "temporary variable used for splitting
        umsatz-aufg1 = ls_aufg-code1.
        umsatz-aufg2 = ls_aufg-code2.
      WHEN '/EREF/'.
* check if we have a /RTRN/ code present
        CLEAR ls_codewords_rtrn.
        READ TABLE pt_codewords INTO ls_codewords_rtrn
          WITH KEY codeword =  '/RTRN/'.
* RTRN code is not present, map EREF value to ZINF2
        IF ls_codewords_rtrn IS INITIAL.
          umsatz-zinf2 = ls_codewords-value.
        ELSE.
* is present, map EREF value to ZINF1
          CONCATENATE c_return ls_codewords-value INTO umsatz-zinf1.  "here we have EREF value
        ENDIF.
      WHEN '/RTRN/'.
*map return reason to UMSATZ-BUTXT (posting text), clear GCODE.
*re-set the gcode value, if a code word exist
        umsatz-butxt = ls_codewords-value.
        umsatz-gcode = ''.
*Then map mutation code from :61: record (h_gcode) to UMSATZ-ZINF2
        CLEAR ls_mutcode.
        READ TABLE gt_mutcode INTO ls_mutcode
        WITH KEY zmutationcode = h_gcode.
        CLEAR umsatz-zinf2.
        IF ls_mutcode-zrtype IS NOT INITIAL.
          umsatz-zinf2 = ls_mutcode-zrtype.
        ENDIF.
      WHEN '/REMI/'.
* special case for /REMI/ code
* searching for it's subcode in the table
        CLEAR ls_subcode.
        IF ls_codewords-subcode IS NOT INITIAL.
          CLEAR ls_subcode.
          READ TABLE pt_codewords INTO ls_subcode
            WITH KEY codeword = ls_codewords-subcode.
        ENDIF.
        IF ls_subcode-value IS NOT INITIAL.
* subcode maintained, found and filled
          lv_remi_value = ls_subcode-value.
        ELSE.
* all other cases
          lv_remi_value = ls_codewords-value.
        ENDIF.
* will be mapped to VWZ01 - VWZ014
        PERFORM collect_text USING lv_remi_value
          CHANGING lv_texts_concat.
      WHEN '/ORDP//ID/'.
* not used, for the time being
      WHEN '/BENM//ID/'.
* not used, for the time being
      WHEN '/UDTR/'.
* not used, for the time being
      WHEN '/UCRD/'.
* not used, for the time being
      WHEN '/PURP/'.
* not used, for the time being
      WHEN '/PREF/'.
* will be mapped to SCHNR and/or VWZ01 - VWZ014
        IF  ls_codewords-value(16) CO '123456789'.
          umsatz-schnr = ls_codewords-value.
        ENDIF.
* and it will be also mapped to VWZ01 - VWZ014
        PERFORM collect_text USING ls_codewords-value
           CHANGING lv_texts_concat.
      WHEN '/NRTX/'.
* not used, for the time being
      WHEN '/FX/'.
* not used, for the time being
      WHEN '/MARF/'.
* will be mapped to VWZ01 - VWZ014
        PERFORM collect_text USING ls_codewords-value
           CHANGING lv_texts_concat.
      WHEN '/SVCL/'.
* not used, for the time being
      WHEN '/SCID/'.
* not used, for the time being
      WHEN '/IREF/'.
* not used, for the time being
      WHEN '/BENM//NAME/'.
* not used, for the time being
    ENDCASE.
  ENDLOOP.

*** additional processing
  IF  umsatz-zinf2 IS INITIAL.
* if the /EREF/ is not provided, fill with NOTPROVIDED
    umsatz-zinf2 = 'NOTPROVIDED'.
  ENDIF.
* map values of code words /REMI/, /MARF/ into VWZ01 - VWZ014
  SHIFT lv_texts_concat LEFT DELETING LEADING ' '.
  PERFORM texts_to_vzwxx USING lv_texts_concat
        CHANGING umsatz.
ENDFORM.                    " NEW_86_MAPPING
*&---------------------------------------------------------------------*
*&      Form  FILL_HDR_ADD_FIELDS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      <--P_AUSZUG  text
*----------------------------------------------------------------------*
FORM fill_hdr_add_fields  CHANGING p_auszug LIKE auszug.
* JASAM.2013.09.19+

  DATA: ls_umsatz LIKE umsatz,
        lv_value  TYPE p LENGTH 15 DECIMALS 2,
        lv_ssald  TYPE p LENGTH 15 DECIMALS 2,
        lv_sumso  TYPE p LENGTH 15 DECIMALS 2,
        lv_sumha  TYPE p LENGTH 15 DECIMALS 2,
        lv_esald  TYPE p LENGTH 15 DECIMALS 2.

  lv_ssald = 0.
  LOOP AT gt_umsatz INTO ls_umsatz.
    MOVE ls_umsatz-wrbtr TO lv_value.
    IF lv_value < 0.
      lv_value = abs( lv_value ).
      ADD lv_value TO lv_sumso.
    ELSE.
      ADD lv_value TO lv_sumha.
    ENDIF.
  ENDLOOP.
  lv_esald = lv_ssald + lv_sumha - lv_sumso.

  PERFORM convert_alpha_input USING lv_ssald CHANGING p_auszug-ssald.
  PERFORM convert_alpha_input USING lv_sumso CHANGING p_auszug-sumso.
  PERFORM convert_alpha_input USING lv_sumha CHANGING p_auszug-sumha.
  PERFORM convert_alpha_input USING lv_esald CHANGING p_auszug-esald.

ENDFORM.                    " FILL_HDR_ADD_FIELDS
*&---------------------------------------------------------------------*
*&      Form  CONVERT_TO_NUMBER
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_LS_UMSATZ_WRBTR  text
*      <--P_LV_VALUE  text
*----------------------------------------------------------------------*
FORM convert_alpha_input USING    p_value_n
                         CHANGING p_value_c.
* JASAM.2013.09.19+
  DATA: lv_string TYPE string,
        lv_length TYPE i,
        lv_start  TYPE i.

  lv_string = p_value_n.
  CONDENSE lv_string.
  lv_length = strlen( lv_string ).
  p_value_c = '000000000000000000'.
  lv_start = 18 - lv_length.
  p_value_c+lv_start(lv_length) = lv_string.

ENDFORM.                    " CONVERT_TO_NUMBER

*&---------------------------------------------------------------------*
*&      Form  check_and_update_aznum
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM check_and_update_aznum.

  FIELD-SYMBOLS:
    <ls_auszug>   LIKE LINE OF tab_auszug,
    <ls_umsatz>   LIKE LINE OF tab_umsatz.
  DATA:
    lv_aznum      TYPE zgmu_file-aznum,
    lv_esald      TYPE zgmu_file-amount,
    ls_zgmu_file  TYPE zgmu_file.

  CLEAR: lv_aznum, lv_esald, ls_zgmu_file.
  READ TABLE tab_auszug ASSIGNING <ls_auszug> INDEX 1.
  IF sy-subrc = 0.
    lv_esald = <ls_auszug>+113(18).
    SELECT SINGLE aznum INTO lv_aznum FROM zgmu_file
           WHERE file_type    = par_fmt
             AND statement_id = gv_statement_id
             AND amount       = lv_esald.
    IF sy-subrc = 0 AND lv_aznum IS NOT INITIAL.
* change AZNUM in AUSZUG table
      <ls_auszug>+38(4) = lv_aznum.
* change AZNUM in UMSATZ table
      LOOP AT tab_umsatz ASSIGNING <ls_umsatz>.
        <ls_umsatz>+38(4) = lv_aznum.
      ENDLOOP.
    ELSE.
* if no such entry in table -> add it
      ls_zgmu_file-file_type    = par_fmt.
      ls_zgmu_file-statement_id = gv_statement_id.
      ls_zgmu_file-amount       = lv_esald.
      ls_zgmu_file-aznum        = auszug-aznum.
      ls_zgmu_file-created_by   = sy-uname.
      ls_zgmu_file-created_on   = sy-datum.
      ls_zgmu_file-created_at   = sy-uzeit.
      MODIFY zgmu_file FROM ls_zgmu_file.
    ENDIF.
  ENDIF.

ENDFORM.                    "check_and_update_aznum

*&---------------------------------------------------------------------*
*&      Form  call_fpb17
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM call_fpb17.

  DATA:                               "JASAM.2013.10.24+
    lt_bdc    TYPE TABLE OF bdcdata,
    ls_bdc    TYPE bdcdata,
    ls_opt    TYPE ctu_params.

*    SUBMIT rfkkka00 USING SELECTION-SCREEN '1000'
*                    WITH p_tcode  = 'FPB17'
*                    WITH p_rundat = sy-datum
*                    WITH p_auszf  = par_fil2
*                    WITH p_umsf   = par_fil3
*                    AND RETURN.

* call transaction instead submit to remain in FPB17 after it's processed
* fill BDC data
  CLEAR: ls_bdc.
  ls_bdc-program  = 'RFKKKA00'.
  ls_bdc-dynpro   = '1000'.
  ls_bdc-dynbegin = abap_true.
  APPEND ls_bdc TO lt_bdc.
  CLEAR: ls_bdc.
  ls_bdc-fnam     = 'BDC_CURSOR'.
  ls_bdc-fval     = 'P_RUNDAT'.
  APPEND ls_bdc TO lt_bdc.
  CLEAR: ls_bdc.
  ls_bdc-fnam     = 'P_RUNDAT'.
  CONCATENATE sy-datum+6(2) sy-datum+4(2) sy-datum(4)
    INTO ls_bdc-fval SEPARATED BY '.'.
  APPEND ls_bdc TO lt_bdc.
  CLEAR: ls_bdc.
  ls_bdc-fnam     = 'P_AUSZF'.
  ls_bdc-fval     = par_fil2.
  APPEND ls_bdc TO lt_bdc.
  CLEAR: ls_bdc.
  ls_bdc-fnam     = 'P_UMSF'.
  ls_bdc-fval     = par_fil3.
  APPEND ls_bdc TO lt_bdc.
* fill options structure
  ls_opt-racommit = abap_true.
  ls_opt-nobinpt  = abap_true.
  ls_opt-nobiend  = abap_true.
* call transaction
  CALL TRANSACTION 'FPB17'
       USING lt_bdc
       OPTIONS FROM ls_opt.

ENDFORM.                    "call_fpb17
