*&---------------------------------------------------------------------*
*& Report ZDB_CORRECTION_V77
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zdb_correction_am.

**************************************************
*Data Declaration
**************************************************
TABLES : sscrfields.

DATA: l_imp_class TYPE string,
      l_rest      TYPE string.
***********************************
*       ZAUCT_CORRECTION Structure
***********************************
TYPES : BEGIN OF zauct_struct,
          mandt             TYPE  mandt,
          session_id        TYPE  zdb_analysis_v74-session_id,
          pgname(40)        TYPE  c,
          error_type(3)     TYPE  c,
          error_message(50) TYPE  c,
          line_no(7)        TYPE  i,
          runn(1)           TYPE c,
          skip(1)           TYPE  c,
          impact(2)         TYPE  c,
          status(1)         TYPE  c,
          actual_corr(1)    TYPE  c,
          info(50)          TYPE  c,
          repcfm(8000)      TYPE   c,
          obj_name          TYPE zdb_analysis_v74-obj_name,
          " added for result display
          sub_program(40)   TYPE c,
          opercd            TYPE i,
          loops(100)        TYPE c, "added for opcd 45,46
          code(8000)        TYPE c,
*{ Begin of change by Twara - 12/02/2016
          sub_type          TYPE zdb_analysis_v74-sub_type,
*} End of change by Twara - 12/02/2016
        END OF zauct_struct.

* Added for correction results display
TYPES: BEGIN OF ty_correction_results,
         obj_name    TYPE zdb_analysis_v74-obj_name,
         sub_program TYPE zdb_analysis_v74-sub_program,
         line_org    TYPE zdb_analysis_v74-line_no,
         line_no     TYPE zdb_analysis_v74-line_no,
         opcode      TYPE zdb_analysis_v74-opercd,
*{ Begin of change by Twara - 12/02/2016
         message     TYPE string,
*} End of change by Twara - 12/02/2016
       END OF ty_correction_results.

DATA: gt_correction_results TYPE TABLE OF ty_correction_results,
      wa_correction_results TYPE ty_correction_results.
* End of addition
FIELD-SYMBOLS:     <fs_hana_err>          TYPE ty_correction_results.
TYPES: BEGIN OF t_badi,
         imp_class TYPE char40,
         program   TYPE char40,
       END OF t_badi.

DATA: i_badi  TYPE STANDARD TABLE OF t_badi,
      wa_badi TYPE t_badi.

TYPES: BEGIN OF t_imp_name,
         pgname TYPE char40,
       END OF t_imp_name.

DATA: l_badi_prog      TYPE char40,
      l_badi_prog_main TYPE char40,
      l_badi_class     TYPE char30,
      l_badi_class1    TYPE char30,
*{ Begin of change by Twara - 12/02/2016 to change length
      l_methodname     TYPE char30,
*      l_methodname     TYPE /grcpi/gria_sourcef,
*} End of change by Twara - 12/02/2016 to change length
      l_method_prog    TYPE char120,
      l_badi_flag      TYPE flag,
      l_meth_len       TYPE tmdir-methodindx.

TYPES: BEGIN OF ty_defin,
         fieldname     TYPE fieldname,
         ref_tabname   TYPE tabname,
         ref_fieldname TYPE fieldname,
       END OF ty_defin.

TYPES: BEGIN OF ty_code,
         line(150),
       END   OF ty_code.

DATA: lv_prog TYPE trdir-name,
**** Begin of changes by Kanika - 16/3/2016
      lv_temp TYPE string.
**** End of changes by Kanika - 16/3/2016

DATA: g_headflg   TYPE c,
      g_corr_done TYPE c,
      g_prog_name TYPE program.

DATA: BEGIN OF code,
        text(255) TYPE c,
      END OF code.

TYPES: BEGIN OF t_code_strat ,
         line(150),
       END OF t_code_strat.

TYPES: BEGIN OF t_func_repl,
         fm     LIKE fupararef-funcname,
         fm_rep LIKE fupararef-funcname,
       END OF t_func_repl.

TYPES : BEGIN OF t_tadir,  "TYPE DECLARATION USED FOR TR TAGGING
          pgmid    TYPE pgmid,
          object   TYPE trobjtype,
*{ Begin of change by Twara - 16/03/2016
          obj_name TYPE trobj_name,
*} End of change by Twara - 16/03/2016
          devclass TYPE devclass,
        END OF t_tadir.

TYPES :BEGIN OF ty_reposrc,
         progname TYPE progname,
       END OF ty_reposrc.

DATA: v_str  TYPE string,
      v_str1 TYPE string.

* PRETTY PAINTER GLOBAL DATA
TYPES: ty_t_edlineindx TYPE TABLE OF edlineindx.
DATA:  l_indentation_wrong TYPE i.

* DATA DECLARATION
DATA:
  buffer       TYPE rswsourcet,
  content_c    TYPE rswsourcet WITH HEADER LINE,
  wa_content_c LIKE LINE OF content_c,
  wa_buffer    LIKE LINE OF content_c.

DATA: tk           TYPE stokesx OCCURS 0,
      w_tk         TYPE stokesx,
      stm          TYPE sstmnt OCCURS 0,
      w_stm        TYPE sstmnt,
      row          LIKE sy-index,
      col          LIKE sy-index,
      incl         LIKE sy-repid,
      msg(255),
      wrd(30),
      content_fill LIKE sy-index,
      case_mode(5) VALUE 'HIKEY',
      false,
      edit         LIKE s38e,
      true(1)      VALUE 'X'.

* END OF PRETTY PAINTER GLOBAL DATA.

CONSTANTS: ca_starpp(1) VALUE '*',
           ca_astpp(1)  VALUE '"',
           ca_dotpp(1)  VALUE '.',
           c_encoding   TYPE char25 VALUE ' ENCODING'.

DATA:  g_offset  TYPE i.

DATA : line           TYPE i,
       gv_ccount      TYPE i,
       lv_op          TYPE i,
       lv_newline     TYPE i,
       line_check     TYPE i,
       v_header_lines TYPE i.
DATA:lv_indx TYPE sy-tabix.
DATA: i_zauct_errors  TYPE STANDARD TABLE OF zauct_struct,

      wa_zauct_errors TYPE zauct_struct.
DATA: i_zauct_errors_tmp  LIKE i_zauct_errors,
      wa_zauct_errors_tmp LIKE wa_zauct_errors,
      gv_encoding         TYPE char25.

DATA : lt_auctcopy TYPE TABLE OF zauct_copy WITH HEADER LINE .

* START OF DATA DECLARATION FOR TRANSPORT REQUEST.
TYPE-POOLS: trwbo.

DATA: BEGIN OF rtab OCCURS 0,
        text(1000),
      END OF rtab,
      wa_rtab LIKE LINE OF rtab[].

TYPES: BEGIN OF t_progvar,
         object_id   TYPE pgmid,
         object_type TYPE trobjtype,
         object_name TYPE trobj_name,
       END OF t_progvar.

DATA: comment_start LIKE LINE OF rtab,
      comment_end   LIKE LINE OF rtab.

DATA: lt_tadir           TYPE STANDARD TABLE OF t_tadir,
      lt_tadir1          TYPE STANDARD TABLE OF t_tadir,
      wa_tadir           TYPE t_tadir,
      lt_request         TYPE trwbo_request_headers,
      ls_request         TYPE trwbo_request_header,
      lt_messages        TYPE ctsgerrmsgs,
      ls_message         TYPE ctsgerrmsg,
      ls_request_repair  TYPE trwbo_request_header,
      lt_messages_repair TYPE ctsgerrmsgs,
      ls_message_repair  TYPE ctsgerrmsg,
      lv_message_repair  TYPE char255,
      lt_e071            TYPE TABLE OF e071,
      wa_e071            TYPE e071,
      wa_e071r           TYPE e071,
      lv_message         TYPE char255.

DATA: l_entry_check1 TYPE i,
      l_entry_check2 TYPE i,
      len_entry      TYPE i,
      prog_entry     TYPE char40,
      go_further     TYPE i.

TYPES: BEGIN OF t_issue,
         name    TYPE string,
         message TYPE string,
       END OF t_issue.

TYPES: BEGIN OF ty_skipped_code,
         name     TYPE string,
         old_line TYPE i,
         new_line TYPE i,
         opcode   TYPE i,
         reason   TYPE string,
       END OF ty_skipped_code.

TYPES: BEGIN OF ty_itab_header,
         text(1000),
       END OF ty_itab_header.
DATA: itab_header TYPE TABLE OF ty_itab_header,
      wa_header   LIKE LINE OF itab_header.

DATA: fugr_name   TYPE rs38l-area,
      lv_progname TYPE string,
      fm_sap      TYPE string VALUE 'SAPL',
      inc_no      TYPE tfdir-include,
      v_namespace TYPE rs38l-namespace,
      v_obj_name  TYPE tadir-obj_name.

DATA: i_issue         TYPE STANDARD TABLE OF t_issue,
      wa_issue        TYPE t_issue,
      gt_skipped_code TYPE TABLE OF ty_skipped_code,
      wa_skipped_code TYPE ty_skipped_code.

*IN ORDER TO  TAKE CARE OF ISSUE PERTAINING TO CODEPAGE NUMBER. THIS
*VARIABLE TAKES CARE OF NON-NUMERIC CODE PAGE NO. CASES.
DATA: g_codepage_check TYPE i.

"VERSION GLOBAL VARIABLE.
DATA: g_version_type   TYPE i,
      g_version_object TYPE e071-obj_name.
DATA: l_len1   TYPE i,
      iinclude TYPE includenr,
      inname   TYPE pname,
      l_func   TYPE rs38l_fnam.

TYPES : BEGIN OF param_name,
          param_name TYPE string,
          param_type TYPE char1,
        END OF param_name.

DATA : gv_sessionc TYPE zdb_analysis_v74-session_id.
** begin of hana check
DATA : it_hana       TYPE STANDARD TABLE OF zdb_analysis_v74,
       wa_hana       TYPE zdb_analysis_v74,
*       begin of change by vrishti - 24/1/2017: Def_2
       wa_hana_check TYPE zdb_analysis_v74,
*       end of change by vrishti - 24/1/2017: Def_2
*{ Begin of change by Twara - 12/02/2016
       wa_hana1      TYPE zdb_analysis_v74,
*} End of change by Twara - 12/02/2016
*{ Begin of Change by Rohit - 24/02/2016
       it_hana_corr  TYPE STANDARD TABLE OF zdb_analysis_v74,
*} End of change by Rohit - 24/02/2016
       it_dp_hana    TYPE STANDARD TABLE OF zdb_analysis_v74,
       wa_dp_hana    TYPE zdb_analysis_v74,
       i_auct        TYPE STANDARD TABLE OF  zauct_struct,
       wa_auct       TYPE  zauct_struct,
       v_keys        TYPE string,
       i_keys        TYPE STANDARD TABLE OF ty_code,
       wa_keys       TYPE ty_code,
       v_strc1       TYPE string,
       v_strc2       TYPE string.
DATA : lv_str1 TYPE string,
       lv_str2 TYPE string,
       lv_str3 TYPE string.
DATA: gr_nspace  TYPE RANGE OF namespace."Name Space Logic Declaration
DATA : lwr_nspace  LIKE LINE OF gr_nspace."Name Space Logic Declaration
DATA: lv_namespace  TYPE namespace."Name Space Logic Declaration
** end of hana check

DATA: gv_initial TYPE sy-tabix.
DATA: gv_line TYPE i.
DATA : lv_len TYPE i.

DATA: v_fae   TYPE flag,
      v_fae_m TYPE flag.
DATA: i_keys1  TYPE STANDARD TABLE OF ty_code,
      wa_keys1 TYPE ty_code,
      v_keys1  TYPE string,
      v_keys2  TYPE string,
      v_keys3  TYPE string.

DATA: gt_tokens TYPE sedi_tk,
      wa_tokens TYPE stokesx,
      gt_stmts  TYPE sedi_stm,
      wa_stmts  TYPE sstmnt.
*{ Begin of Change by Rohit - 09/02/2016
DATA: lv_length TYPE i.
DATA: lv_tr TYPE string.
RANGES: gr_object FOR tadir-obj_name,
        wa_obj FOR tadir-obj_name.
*} End of change by Rohit - 09/02/2016
CLASS lcl_hana_corrections DEFINITION FINAL.

  PUBLIC SECTION.
    METHODS:  fetch_data,
      perform_checks,
      display_result,
      check_opcode12,
*      check_opcode13,    "changes by vrishti- 24/1/2017: Def_2
      check_opcode16,
*      check_opcode37,    "changes by vrishti- 24/1/2017: Def_2
*      check_opcode41,    "changes by vrishti- 24/1/2017: Def_2
      check_opcode45,
      check_opcode46,
*      begin of change by vrishti - 24/1/2017: Def_2
      check_hana_opcode,
*      end of changes by vrishti - 24/1/2017: Def_2
*{ Begin of change by Twara - 12/02/2016
      check_opcode45_18_19,
*} End of change by Twara - 12/02/2016
      pretty_printer,
      change_case_for_content
        IMPORTING
          p_case_mode TYPE char5
        CHANGING
          p_content   TYPE sedi_source
          p_lineindex TYPE ty_t_edlineindx,
      inline_keywords_conversion
        IMPORTING
          p_case_mode TYPE char5
        CHANGING
          p_token     TYPE stokesx
          p_done      TYPE abap_bool,
      version_create,
      lock_object,
      "begin of change for def_18
      check_opcode57,
      get_scenerio
        IMPORTING
          i_code     TYPE comt_mv_attr_alv
        EXPORTING
          e_scenerio TYPE char2,
      check_opcode57_2scene
        IMPORTING
          i_line TYPE i
          "end of change for def_18
        .

ENDCLASS.                    "lcl_hana_corrections DEFINITION

DATA: go_hana TYPE REF TO lcl_hana_corrections.

**************************************************
*Selection Block for Input values - as below
*Session ID , Program Name and Transport Request
**************************************************
SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE TEXT-001.

SELECT-OPTIONS: s_sess FOR gv_sessionc OBLIGATORY ,
                s_obj FOR g_version_object.

PARAMETERS: p_task     TYPE e071-trkorr.
SELECTION-SCREEN SKIP.
PARAMETERS: p_reqrd TYPE c AS CHECKBOX DEFAULT 'X'.

SELECTION-SCREEN END OF BLOCK b1.

***************************************************


START-OF-SELECTION.
  IF p_task IS INITIAL.
    MESSAGE 'Please provide Transport request' TYPE 'S'.
    EXIT.
  ENDIF.

  CREATE OBJECT go_hana.

  CALL METHOD go_hana->fetch_data( ).
  CALL METHOD go_hana->perform_checks( ).
  CALL METHOD go_hana->display_result( ).


*&---------------------------------------------------------------------*
*&  Methods implementations
*&---------------------------------------------------------------------*

CLASS lcl_hana_corrections IMPLEMENTATION.

  METHOD fetch_data.

    DATA: lt_r_opcodes  TYPE RANGE OF zdb_analysis_v74-opercd,
          lwa_r_opcodes LIKE LINE OF lt_r_opcodes.
**************************************************
*Taking values from zdb_analysis_v74 and putting it
*in ZAUCT_DETECTION to sync the correction
**************************************************
    REFRESH: it_hana,
             gr_nspace,
             i_auct,
             i_zauct_errors,
             lt_r_opcodes.

    IF p_reqrd EQ 'X'.  " If mandatory Opcodes only checkbox is selected
      CLEAR lwa_r_opcodes.
      lwa_r_opcodes-sign = 'I'.
      lwa_r_opcodes-option = 'EQ'.
      lwa_r_opcodes-low = 12.
      APPEND lwa_r_opcodes TO lt_r_opcodes.
      APPEND lwa_r_opcodes TO lt_r_opcodes.
      lwa_r_opcodes-low = 13.
      APPEND lwa_r_opcodes TO lt_r_opcodes.
      lwa_r_opcodes-low = 16.
      APPEND lwa_r_opcodes TO lt_r_opcodes.
*{ Begin of change by Twara - 12/02/2016
      lwa_r_opcodes-low = 37.
      APPEND lwa_r_opcodes TO lt_r_opcodes.
*} End of change by Twara - 12/02/2016
      "begin of code change for def_21
      lwa_r_opcodes-low = 57.
      APPEND lwa_r_opcodes TO lt_r_opcodes.
***********BOC Shreeda 1/05/2017************
lwa_r_opcodes-low = 77.
      APPEND lwa_r_opcodes TO lt_r_opcodes.
      lwa_r_opcodes-low = 78.
      APPEND lwa_r_opcodes TO lt_r_opcodes.
      lwa_r_opcodes-low = 79.
      APPEND lwa_r_opcodes TO lt_r_opcodes.
***********BOC Shreeda 1/05/2017************
      "end of code change for def_21
    ELSE. " consider all Opcodes if checkbox is not selected
      CLEAR lwa_r_opcodes.
      lwa_r_opcodes-sign = 'I'.
      lwa_r_opcodes-option = 'EQ'.
      "begin of code change for def_21
*      lwa_r_opcodes-low = 12.
*      APPEND lwa_r_opcodes TO lt_r_opcodes.
*      lwa_r_opcodes-low = 13.
*      APPEND lwa_r_opcodes TO lt_r_opcodes.
      "end of code change for def_21
*      lwa_r_opcodes-low = 16.
*      APPEND lwa_r_opcodes TO lt_r_opcodes.
*      lwa_r_opcodes-low = 37.
*      APPEND lwa_r_opcodes TO lt_r_opcodes.
      "begin of code change for def_21
      lwa_r_opcodes-low = 41.
      APPEND lwa_r_opcodes TO lt_r_opcodes.
      "begin of code change for def_21
*{ Begin of change by Twara - 12/02/2016
      lwa_r_opcodes-low = 18.
      APPEND lwa_r_opcodes TO lt_r_opcodes.
      lwa_r_opcodes-low = 19.
      APPEND lwa_r_opcodes TO lt_r_opcodes.
      lwa_r_opcodes-low = 21.
      APPEND lwa_r_opcodes TO lt_r_opcodes.
*} End of change by Twara - 12/02/2016
      lwa_r_opcodes-low = 45.
      APPEND lwa_r_opcodes TO lt_r_opcodes.
      lwa_r_opcodes-low = 46.
      APPEND lwa_r_opcodes TO lt_r_opcodes.
      "beging of code change for def_18
*      lwa_r_opcodes-low = 57.
*      APPEND lwa_r_opcodes TO lt_r_opcodes.
      "end of code change for def_18

    ENDIF.

    IF s_sess IS NOT INITIAL AND s_obj IS INITIAL.
      SELECT * FROM zdb_analysis_v74 INTO TABLE it_hana WHERE
        session_id IN s_sess
            AND opercd IN lt_r_opcodes.

    ELSEIF s_sess IS NOT INITIAL AND s_obj IS NOT INITIAL.
      SELECT * FROM zdb_analysis_v74 INTO TABLE it_hana WHERE
     session_id IN s_sess
     AND ( obj_name IN s_obj
      OR sub_program IN s_obj )
         AND opercd IN lt_r_opcodes.
    ENDIF.

    IF sy-subrc = 0 AND it_hana IS NOT INITIAL.
      LOOP AT it_hana INTO wa_hana.
        CLEAR : lv_namespace , lv_str1 , lv_str2 , lv_str3.
        CHECK wa_hana-obj_name IS NOT INITIAL.
** For Siemens namespace objects
        IF wa_hana-obj_name+0(1) = '/' .
          REPLACE FIRST OCCURRENCE OF '/' IN wa_hana-obj_name WITH ''.
          CONDENSE wa_hana-obj_name.
          CLEAR: lv_str1, lv_str2.
          SPLIT wa_hana-obj_name AT '/' INTO lv_str1 lv_str2.
          CHECK lv_str2 IS NOT INITIAL.
          CLEAR: wa_hana-obj_name.
          lv_len = strlen( lv_str1 ).
          IF lv_len GT 4.
            IF lv_str1+0(4) = 'SAPL'.
              SPLIT lv_str1 AT 'L' INTO lv_str3 lv_str1.
            ENDIF.
          ENDIF.
          CONCATENATE '/' lv_str1 '/' lv_str2 INTO wa_hana-obj_name.
          CONCATENATE '/' lv_str1 '/' INTO lv_str1.
          lwr_nspace-low = lv_str1.
          SELECT SINGLE namespace INTO lv_namespace FROM
            trnspacet WHERE namespace = lwr_nspace-low.
          IF sy-subrc = 0.
            CONCATENATE lv_str1  '*' INTO lv_str1.
            lwr_nspace-low = lv_str1.
            lwr_nspace-sign = 'I'.
            lwr_nspace-option = 'CP'.
            APPEND lwr_nspace TO gr_nspace.
          ELSE.
            CONTINUE.
          ENDIF.
        ENDIF.
        IF wa_hana-obj_name CS 'SAPLZ' OR
           wa_hana-obj_name CS 'SAPLY' OR
           wa_hana-obj_name CS 'SAPMZ' OR
           wa_hana-obj_name CS 'SAPMY' OR
           wa_hana-obj_name+0(1) = 'Z' OR
           wa_hana-obj_name+0(1) = 'Y' OR
           ( wa_hana-obj_name  IN  gr_nspace[] AND NOT
           gr_nspace[] IS INITIAL ).
          wa_auct-session_id = wa_hana-session_id.
          wa_auct-pgname = wa_hana-read_prog.
          wa_auct-error_type = wa_hana-opercd.
          wa_auct-error_message = wa_hana-operation.
          wa_auct-line_no = wa_hana-line_no.
          wa_auct-impact = wa_hana-act_st.
          wa_auct-actual_corr = wa_hana-actual_corr.
          wa_auct-impact = wa_hana-act_st.
          wa_auct-repcfm = wa_hana-keys.
          wa_auct-runn = wa_hana-runn.
          wa_auct-obj_name = wa_hana-obj_name.
          wa_auct-sub_program = wa_hana-sub_program.
          wa_auct-opercd = wa_hana-opercd.
          wa_auct-loops = wa_hana-loops.
          wa_auct-code = wa_hana-code.
*{ Begin of change by Twara - 12/02/2016
          wa_auct-sub_type = wa_hana-sub_type.
*} End of change by Twara - 12/02/2016
          APPEND wa_auct TO i_auct.
          CLEAR : wa_auct.
        ENDIF.
      ENDLOOP.
    ENDIF.

**************************************************
*Fetching data from AUCT errors for correction
**************************************************
    LOOP AT i_auct INTO wa_auct.
      IF wa_auct-runn EQ '' AND wa_auct-skip = ''.
**Check to compare errors if they are not run earlier**
        APPEND wa_auct TO i_zauct_errors.
      ENDIF.
    ENDLOOP.

    IF i_zauct_errors IS INITIAL.
      MESSAGE 'No Entries applicable for processing' TYPE 'S' DISPLAY
      LIKE 'E'.
      LEAVE LIST-PROCESSING.
    ENDIF.

* Build header comments table
    DATA: lv_uname TYPE sy-uname.
    lv_uname = sy-uname.
*    CONSTANTS: cs1 TYPE string VALUE
*    '* Start of Changes by',
*               cs2 TYPE string VALUE
*    'for HANA Corrections C25K900138',
*               ce1 TYPE string VALUE
*    '* End of Changes by'.
*    comment_start = ''.
*    comment_end = ''.
**begin of chnage by Priyanka
    comment_start = '*HANA UPGRADE- BEGIN OF MODIFY'.
    CONCATENATE '<' p_task '>' INTO lv_tr.
    CONCATENATE comment_start lv_tr INTO comment_start SEPARATED BY space.

    comment_end = '*HANA UPGRADE- END OF MODIFY'.
    CONCATENATE comment_end lv_tr INTO comment_end SEPARATED BY space.

*    CONCATENATE cs1 lv_uname cs2
*      INTO comment_start
*      SEPARATED BY space.
*    CONCATENATE ce1 lv_uname cs2
*      INTO comment_end
*      SEPARATED BY space.
*    REFRESH: itab_header.
    IF i_zauct_errors IS NOT INITIAL.

      DATA: lv_date     TYPE string.
      CONSTANTS: head_l1 TYPE string VALUE
'*----------------------------------------------------------------------*',
                 head_l2 TYPE string VALUE
'* Author        : &NAME&                                               *',
                 head_l3 TYPE string VALUE
'* Date          : &DATE&                                             *',
                 head_l4 TYPE string VALUE
'* Change Marker : &TR&                                           *',
                 head_l5 TYPE string VALUE
'* Description   : HANA Corrections                                     *'.

      CLEAR: wa_header.
      wa_header-text = head_l1.
      APPEND wa_header TO itab_header.

      CLEAR: wa_header.
      wa_header-text = head_l2.
      REPLACE '&NAME&' IN wa_header-text WITH lv_uname.
      APPEND wa_header TO itab_header.

      CLEAR: wa_header,
             lv_date.

      CONCATENATE sy-datum+4(2) '/' sy-datum+6(2) '/' sy-datum+2(2) INTO
      lv_date.
      wa_header-text = head_l3.
      REPLACE '&DATE&' IN wa_header-text WITH lv_date.
      APPEND wa_header TO itab_header.
      CLEAR: wa_header.
      wa_header-text = head_l4.
      REPLACE '&TR&' IN wa_header-text WITH p_task.
      APPEND wa_header TO itab_header.
      CLEAR: wa_header.
      wa_header-text = head_l5.
      APPEND wa_header TO itab_header.

      CLEAR: wa_header.
      wa_header-text = head_l1.
      APPEND wa_header TO itab_header.

      CLEAR: wa_header.


    ENDIF.

    CLEAR v_header_lines.
    DESCRIBE TABLE itab_header LINES v_header_lines.

  ENDMETHOD.                    "fetch_data

  METHOD perform_checks.

    DATA:lt_reposrc        TYPE TABLE OF ty_reposrc,
         wa_repsorc        TYPE ty_reposrc,
         lv_tr_target      TYPE tr_target,
         lv_devlayer       TYPE devlayer,
         lt_cons_paths     TYPE tab_tcerele,
         wa_cons_paths     LIKE LINE OF lt_cons_paths,
         lv_obj_target     TYPE tr_target,
         lv_count_comments TYPE i.
*{ Begin of Change by Rohit - 09/02/2016
*    DATA lv_prog TYPE string.
*} End of change by Rohit - 09/02/2016
*{ Begin of change by Twara - 12/02/2016
*    DATA:lv_indx TYPE sy-tabix.
*} End of change by Twara - 12/02/2016
    REFRESH: i_issue,
             gt_skipped_code.
**************************************************
* Logic for TR tagging of objects
**************************************************

    CLEAR lv_tr_target.
    SELECT SINGLE tarsystem
                  INTO lv_tr_target
                  FROM e070 WHERE trkorr = p_task.

    CONCATENATE c_encoding 'DEFAULT' INTO gv_encoding SEPARATED BY space
    .

    CALL FUNCTION 'TR_READ_REQUEST_WITH_TASKS'
      EXPORTING
        iv_trkorr          = p_task
      IMPORTING
        et_request_headers = lt_request
      EXCEPTIONS
        invalid_input      = 1
        OTHERS             = 2.

    LOOP AT lt_request INTO  ls_request
                       WHERE as4user = sy-uname AND trfunction EQ 'S'
                       AND trstatus = 'D'.
      EXIT.
    ENDLOOP.
**************************************************
* BEGIN OF CHANGES TO INCOPORATE REPAIR OBJECTS
* IN SAME REQUEST UNDER TASK REPAIR.
**************************************************

    LOOP AT lt_request INTO  ls_request_repair
                       WHERE as4user = sy-uname AND trfunction EQ 'R'
                       AND
                       trstatus = 'D'.
      EXIT.
    ENDLOOP.

**************************************************
* END OF CHANGES TO INCOPORATE REPAIR OBJECTS
* IN SAME REQUEST UNDER TASK REPAIR.
**************************************************
*Check if given TR has modifiable Development/Correction and Repair
*tasks
    IF ls_request-trkorr IS INITIAL OR ls_request_repair-trkorr IS
    INITIAL.
      MESSAGE
'Given TR must contain modifiable tasks for both Development/Correcti' &
'on and Repair'
      TYPE 'S' DISPLAY LIKE 'E'.
      LEAVE LIST-PROCESSING.
    ENDIF.


    SORT i_zauct_errors BY pgname     ASCENDING
                           line_no    ASCENDING
                           opercd ASCENDING.

    DELETE ADJACENT DUPLICATES FROM i_zauct_errors
                               COMPARING pgname line_no opercd.

    i_zauct_errors_tmp[] = i_zauct_errors[].

    DELETE ADJACENT DUPLICATES FROM i_zauct_errors_tmp COMPARING pgname
    line_no error_message.

    IF NOT i_zauct_errors_tmp IS INITIAL.
      SELECT pgmid object obj_name devclass
         FROM tadir
         INTO TABLE lt_tadir
         FOR ALL ENTRIES IN i_zauct_errors_tmp
         WHERE obj_name = i_zauct_errors_tmp-pgname
*Begin of changes by Kritika - 16/2/2016
        AND object IN ('PROG', 'FUGR', 'CLAS').
*End of changes by Kritika - 16/2/2016

****Begin of Changes on Include issue

      SELECT progname
        FROM  reposrc
        INTO TABLE lt_reposrc
        FOR ALL ENTRIES IN i_zauct_errors_tmp
        WHERE progname = i_zauct_errors_tmp-pgname.
****End of change on Include issue
    ENDIF.

    SORT i_zauct_errors_tmp BY pgname     ASCENDING
                           line_no    ASCENDING
                           error_message ASCENDING.
**************************************************
*FIND BADI IMPLEMENATATION NAME + PGMID OBJECT
*OBJ_NAME  VALUES FOR THESE FIELDS CORRESPONDING
*TO SELECTION.
**************************************************
*{ Begin of Change by Rohit - 09/02/2016
    CLEAR lv_length.
*} End of change by Rohit - 09/02/2016
    LOOP AT i_zauct_errors_tmp INTO  wa_zauct_errors.
*{ Begin of Change by Rohit - 09/02/2016
      lv_prog = wa_zauct_errors-sub_program.
      lv_length = strlen( lv_prog ).
*} End of change by Rohit - 09/02/2016
*{ Begin of Change by Rohit - 09/02/2016
*      IF wa_zauct_errors-pgname CS '=' AND wa_zauct_errors-pgname+30(2)
*      EQ 'CM'.
*        CLEAR: l_imp_class, l_rest.
*        SPLIT wa_zauct_errors-pgname AT '=' INTO l_imp_class l_rest.
*        CLEAR wa_badi.
*        wa_badi-imp_class = l_imp_class.
*        wa_badi-program = wa_zauct_errors-pgname.
*        APPEND wa_badi TO i_badi.
*      ELSE.
*        CONTINUE.
*      ENDIF.
      IF lv_length = 30
      AND wa_zauct_errors-pgname+30(2) EQ 'CM'.
        CLEAR: l_imp_class, l_rest.
        SPLIT wa_zauct_errors-pgname AT 'CM' INTO l_imp_class l_rest.
        CLEAR wa_badi.
        wa_badi-imp_class = l_imp_class.
        wa_badi-program = wa_zauct_errors-pgname.
        APPEND wa_badi TO i_badi.
      ELSEIF lv_length < 30 AND
      wa_zauct_errors-pgname CS '=' AND wa_zauct_errors-pgname+30(2)
      EQ 'CM'.
        CLEAR: l_imp_class, l_rest.
        SPLIT wa_zauct_errors-pgname AT '=' INTO l_imp_class l_rest.
        CLEAR wa_badi.
        wa_badi-imp_class = l_imp_class.
        wa_badi-program = wa_zauct_errors-pgname.
        APPEND wa_badi TO i_badi.
      ELSE.
        CONTINUE.
      ENDIF.
*} End of change by Rohit - 09/02/2016
    ENDLOOP.

    SORT i_badi BY imp_class.

    IF NOT i_badi[] IS INITIAL.
      REFRESH lt_tadir1[].
      SELECT pgmid object obj_name devclass
        FROM tadir
        INTO TABLE lt_tadir1
        FOR ALL ENTRIES IN i_badi
        WHERE obj_name = i_badi-imp_class
*Begin of changes by Kritika - 16/2/2016
        AND object IN ('PROG', 'FUGR', 'CLAS').
*End of changes by Kritika - 16/2/2016


      APPEND LINES OF lt_tadir1 TO lt_tadir.
    ENDIF.
* END OF BADI RELATED THINGS.

    SORT lt_tadir BY obj_name.
    SORT lt_reposrc BY progname.

    REFRESH: gt_correction_results.
*{ Begin of Change by Rohit - 09/02/2016
    CLEAR gr_object.
*} End of change by Rohit - 09/02/2016
    LOOP AT i_zauct_errors_tmp INTO wa_zauct_errors_tmp.
      CLEAR: g_headflg,
             g_corr_done,
             g_prog_name.
* START -- BADI COMPATIBLITY
      CLEAR: l_badi_flag.
      CLEAR:  l_badi_prog.
*{ Begin of Change by Rohit - 09/02/2016
*      IF wa_zauct_errors_tmp-pgname CS '=' AND
*      wa_zauct_errors_tmp-pgname+30(2) EQ 'CM'.
*        l_badi_flag = 'X'.
*        l_badi_prog  =   wa_zauct_errors_tmp-pgname.
*        CLEAR: l_imp_class, l_rest.
*SPLIT wa_zauct_errors_tmp-pgname AT '=' INTO l_imp_class l_rest.
*        l_badi_class =   l_imp_class.
*        CLEAR: l_imp_class, l_rest.
*        SPLIT wa_zauct_errors_tmp-pgname AT '=CM' INTO l_badi_prog_main
*        l_rest.
*        CONCATENATE l_badi_prog_main '=CP' INTO l_badi_prog_main.
*        l_badi_class1 = l_badi_class.
*        l_meth_len = l_rest.
*
*        CLEAR l_methodname.
*        SELECT SINGLE methodname INTO l_methodname FROM tmdir
*                     WHERE classname = l_badi_class AND
*                                 methodindx = l_meth_len.
*        CONCATENATE l_badi_class1 l_methodname INTO l_method_prog
*        RESPECTING BLANKS.
*
*      ENDIF.
      IF lv_length = 30 AND
         wa_zauct_errors_tmp-pgname+30(2) EQ 'CM'.
        l_badi_flag = 'X'.
        l_badi_prog  =   wa_zauct_errors_tmp-pgname.
        CLEAR: l_imp_class, l_rest.
        SPLIT wa_zauct_errors_tmp-pgname AT 'CM' INTO l_imp_class l_rest
        .
        l_badi_class =   l_imp_class.
*        CLEAR: l_imp_class, l_rest.
*        SPLIT wa_zauct_errors_tmp-pgname AT '=CM' INTO l_badi_prog_main
*        l_rest.
*        CONCATENATE l_badi_prog_main '=CP' INTO l_badi_prog_main.
        l_badi_class1 = l_badi_class.
        l_meth_len = l_rest.

        CLEAR l_methodname.
        SELECT SINGLE methodname INTO l_methodname FROM tmdir
                     WHERE classname = l_badi_class AND
                                 methodindx = l_meth_len.
        CONCATENATE l_badi_class1 l_methodname INTO l_method_prog
        RESPECTING BLANKS.
      ELSEIF lv_length < 30 AND
         wa_zauct_errors_tmp-pgname CS '=' AND
         wa_zauct_errors_tmp-pgname+30(2) EQ 'CM'.
        l_badi_flag = 'X'.
        l_badi_prog  =   wa_zauct_errors_tmp-pgname.
        CLEAR: l_imp_class, l_rest.
        SPLIT wa_zauct_errors_tmp-pgname AT '=' INTO l_imp_class l_rest.
        l_badi_class =   l_imp_class.
        CLEAR: l_imp_class, l_rest.
        SPLIT wa_zauct_errors_tmp-pgname AT '=CM' INTO l_badi_prog_main
        l_rest.
        CONCATENATE l_badi_prog_main '=CP' INTO l_badi_prog_main.
        l_badi_class1 = l_badi_class.
        l_meth_len = l_rest.

        CLEAR l_methodname.
        SELECT SINGLE methodname INTO l_methodname FROM tmdir
                     WHERE classname = l_badi_class AND
                                 methodindx = l_meth_len.
        CONCATENATE l_badi_class1 l_methodname INTO l_method_prog
        RESPECTING BLANKS.
      ENDIF.
*} End of change by Rohit - 09/02/2016
* END -- BADI COMPATIBLITY

      g_codepage_check = 0.
      g_offset = 0.
      CLEAR: l_entry_check1.


      g_prog_name = wa_zauct_errors_tmp-pgname.

**************************************************
* TR LOCK RELATED.
**************************************************
      IF l_badi_flag = 'X'.
        g_prog_name = l_badi_class.
      ENDIF.
      CLEAR wa_tadir.
*Begin of changes by Kritika - 16.3.2016
      SORT lt_tadir BY object obj_name.
      SORT lt_tadir1 BY object obj_name.
      SORT lt_reposrc BY progname.
*End of changes by Kritika - 16.3.2016

      READ TABLE lt_tadir INTO wa_tadir
                             WITH KEY obj_name =
                              g_prog_name
                            BINARY SEARCH.
***Start of change on include issue
      IF sy-subrc NE 0 .
        READ TABLE lt_reposrc INTO wa_repsorc
                           WITH KEY progname =
                           wa_zauct_errors_tmp-pgname
                            BINARY SEARCH.
        IF sy-subrc EQ 0.
          wa_tadir-pgmid = 'LIMU'.
          wa_tadir-object = 'REPS' .
          wa_tadir-obj_name = wa_zauct_errors_tmp-pgname.
        ENDIF.
      ENDIF.
***End of change on include issue
      IF sy-subrc = 0.
        l_entry_check1 = '1'.
        g_version_type = 1.
      ELSE.
        CLEAR: l_entry_check2.
        g_version_type = 2.
        len_entry = strlen( wa_zauct_errors_tmp-pgname ).
        CLEAR: prog_entry.
        len_entry  = len_entry  - 4.
        IF wa_zauct_errors_tmp-pgname+0(2) EQ 'LZ' OR
        wa_zauct_errors_tmp-pgname+0(2) EQ 'LY'.
          CALL FUNCTION 'RS_PROGNAME_SPLIT'
            EXPORTING
              progname_with_namespace = wa_zauct_errors_tmp-pgname
            IMPORTING
              fugr_group              = fugr_name
              fugr_include_number     = inc_no
            EXCEPTIONS
              delimiter_error         = 1
              OTHERS                  = 2.
          IF sy-subrc <> 0.
          ENDIF.
          CONCATENATE fm_sap fugr_name INTO lv_progname.
          SELECT SINGLE funcname FROM tfdir INTO prog_entry WHERE pname
          = lv_progname AND include = inc_no.
          IF sy-subrc IS NOT INITIAL.

            l_entry_check2 = '1'.
            wa_tadir-pgmid = 'LIMU'.
            wa_tadir-object = 'REPS' .
            wa_tadir-obj_name = wa_zauct_errors_tmp-pgname.
          ELSE.

            l_entry_check2 = '1'.
            wa_tadir-pgmid = 'LIMU'.

            wa_tadir-object = 'FUNC' .

            wa_tadir-obj_name = prog_entry.
          ENDIF.
        ENDIF.
      ENDIF.

*Ignore entries for objects with different transport layers from that of
*given TR
      IF wa_tadir-devclass IS INITIAL.
        CLEAR: v_obj_name,
               v_namespace,
               fugr_name.
        CALL FUNCTION 'RS_PROGNAME_SPLIT'
          EXPORTING
            progname_with_namespace = wa_zauct_errors_tmp-pgname
          IMPORTING
            namespace               = v_namespace
            fugr_group              = fugr_name
          EXCEPTIONS
            delimiter_error         = 1
            OTHERS                  = 2.
        IF sy-subrc <> 0.
        ENDIF.
        CONCATENATE v_namespace fugr_name INTO v_obj_name.
        SELECT SINGLE devclass INTO wa_tadir-devclass
                               FROM tadir
                               WHERE obj_name = v_obj_name.
      ENDIF.
      CLEAR lv_devlayer.
      SELECT SINGLE pdevclass
                    INTO lv_devlayer
                    FROM tdevc
                    WHERE devclass = wa_tadir-devclass.

      CALL FUNCTION 'TR_READ_TRANSPORT_LAYER'
        EXPORTING
          iv_layer           = lv_devlayer
        IMPORTING
          et_cons_paths      = lt_cons_paths
        EXCEPTIONS
          layer_doesnt_exist = 1
          OTHERS             = 2.
      IF sy-subrc <> 0.
      ENDIF.

***Begin of Change by Vrishti 10/2/2016
*Internal table from the FM read with current system ID to get the
*target system

*      READ TABLE lt_cons_paths INTO wa_cons_paths INDEX 1 . "commented
      READ TABLE lt_cons_paths INTO wa_cons_paths WITH KEY intsys =
      sy-sysid.

***End of Change by Vrishti 10/2/2016
      CLEAR lv_obj_target.
      lv_obj_target = wa_cons_paths-consys.
      IF lv_tr_target NE lv_obj_target.
        wa_issue-name = wa_zauct_errors_tmp-pgname..
        wa_issue-message =
'Object not tagged to TR as Transport Layers/Target systems are diffe' &
'rent for object and given TR'
        .
        APPEND wa_issue TO i_issue.
        DELETE i_zauct_errors_tmp
        WHERE pgname = wa_zauct_errors_tmp-pgname.
        CONTINUE. " Go to next object
      ENDIF.


      IF l_entry_check1 = '1' OR  l_entry_check2 = '1'.

        REFRESH rtab[].
        CLEAR rtab.
        IF l_badi_flag = 'X'.
          wa_zauct_errors_tmp-pgname = l_badi_prog.
        ENDIF.
        READ REPORT wa_zauct_errors_tmp-pgname INTO rtab.

        LOOP AT rtab[] INTO rtab.
          IF rtab-text CS 'AB-1060-1'.
            g_headflg = 'X'.
            EXIT.
          ENDIF.
        ENDLOOP.

        CLEAR: gv_initial, gv_line.
        LOOP AT i_zauct_errors INTO wa_zauct_errors  WHERE
                             pgname = wa_zauct_errors_tmp-pgname
                             AND runn IS INITIAL.

*{ Begin of change by Twara - 12/02/2016
          lv_indx = sy-tabix.
*} End of change by Twara - 12/02/2016

          CLEAR : wa_hana.
          TRANSLATE wa_zauct_errors-error_message TO UPPER CASE.
          wa_hana-session_id =  wa_zauct_errors-session_id.
          wa_hana-read_prog = wa_zauct_errors-pgname.
          wa_hana-opercd = wa_zauct_errors-error_type.
          wa_hana-operation = wa_zauct_errors-error_message.
          wa_hana-line_no = wa_zauct_errors-line_no.
          wa_hana-act_st =  wa_zauct_errors-impact.
          wa_hana-actual_corr = wa_zauct_errors-actual_corr.
          wa_hana-keys =  wa_zauct_errors-repcfm.
          wa_hana-runn =  wa_zauct_errors-runn.
          wa_hana-sub_program = wa_zauct_errors-sub_program.

*OFFSET ERROR
          CLEAR: lv_prog.
          lv_prog = wa_zauct_errors_tmp-pgname.
          line = wa_zauct_errors-line_no.
*          begin of change by Vrishti- 24/1/2017 : Def_2
          line_check = wa_zauct_errors-line_no.
*          end of change by Vrishti- 24/1/2017 : Def_2
**************************************************
* begin of HANA checks - First check is for
* % DB Hints used
**************************************************
*{ Begin of defect 3820 Change by Rohit - 24/02/2016
          FREE it_hana_corr.
*          begin of changes by vrishti - 24/1/2017 : Def_2
*} End of defect 3820 change by Rohit - 24/02/2016
*          IF ( wa_zauct_errors-opercd = 13 )
*            AND  wa_zauct_errors-runn = ''.
*
*            CALL METHOD go_hana->check_opcode13( ).
*            wa_hana-detected = 'X'.
**{ Begin of Change by Rohit - 09/02/2016
**            MODIFY zdb_analysis_v74 FROM wa_hana .
*            APPEND wa_hana TO it_hana_corr.
**} End of change by Rohit - 09/02/2016
*            CLEAR : wa_hana.

          IF ( wa_zauct_errors-opercd = 13 OR wa_zauct_errors-opercd = 16 OR wa_zauct_errors-opercd = 37 OR
            wa_zauct_errors-opercd = 41 OR
***********BOC Shreeda 3/05/2017************
            wa_zauct_errors-opercd = 77 OR
            wa_zauct_errors-opercd = 78
***********EOC Shreeda 3/05/2017************
            )
            AND  wa_zauct_errors-runn = ''.

            CALL METHOD go_hana->check_hana_opcode( ).
            wa_hana-detected = 'X'.

            lv_newline = gv_ccount + line + 1.
            LOOP AT gt_correction_results INTO wa_correction_results
                      WHERE obj_name = lv_prog AND
                          line_org = line_check .

              CASE  wa_correction_results-opcode .
                WHEN '13'.
                  lv_op = 13.
                WHEN '16'.
                  lv_op = 16.
                WHEN '37'.
                  lv_op = 37.
                WHEN '41'.
                  lv_op = 41.
***********BOC Shreeda 3/05/2017************
                   WHEN '77'.
                lv_op = 77 .
                WHEN '78'.
                lv_op = 78.
***********EOC Shreeda 3/05/2017************
                WHEN OTHERS.
                  lv_op = 0.
              ENDCASE.

              IF lv_op <> 0.
                READ TABLE gt_correction_results ASSIGNING <fs_hana_err> WITH KEY
                        obj_name = wa_zauct_errors-obj_name
                        sub_program = wa_zauct_errors-sub_program
                        opcode = lv_op
                        line_org =  line_check.
                IF sy-subrc = 0.
                  <fs_hana_err>-line_no =  lv_newline.
                  MODIFY gt_correction_results FROM <fs_hana_err>.
                ENDIF.
              ENDIF.
              CLEAR  wa_correction_results.
            ENDLOOP.
            CLEAR  wa_correction_results.
*{ Begin of Change by Rohit - 09/02/2016
*            MODIFY zdb_analysis_v74 FROM wa_hana .
            APPEND wa_hana TO it_hana_corr.
*} End of change by Rohit - 09/02/2016
            CLEAR : wa_hana.
*        end of changes by vrishti - 24/1/2017: Def_2
**************************************************
* Second Logic is for ORDER BY KEYS LOGIC
**************************************************
*          begin of changes by vrishti - 24/1/2017 : Def_2
*          ELSEIF ( wa_zauct_errors-opercd = 16 )
*            AND  wa_zauct_errors-runn = ''.
*
*            CALL METHOD go_hana->check_opcode16( ).
*            wa_hana-detected = 'X'.
**{ Begin of Change by Rohit - 09/02/2016
**            MODIFY zdb_analysis_v74 FROM wa_hana .
*            APPEND wa_hana TO it_hana_corr.
**} End of change by Rohit - 09/02/2016
*
*            CLEAR : wa_hana.
*        end of changes by vrishti - 24/1/2017 : Def_2
*{ Begin of change by Twara - 12/02/2016 for opcode21
**************************************************
* Logic for correcting OPcode 21
**************************************************

          ELSEIF ( wa_zauct_errors-opercd = 21 )
            AND  wa_zauct_errors-runn = ''.

            CALL METHOD go_hana->check_opcode16( ).
            wa_hana-detected = 'X'.
*{ Begin of Change by Rohit - 09/02/2016
*            MODIFY zdb_analysis_v74 FROM wa_hana .
            APPEND wa_hana TO it_hana_corr.
*} End of change by Rohit - 09/02/2016
            MODIFY it_hana FROM wa_hana INDEX lv_indx.
*} End of change by Twara - 12/02/2016 for opcode21

**************************************************
* DELETE ADJACENT DUPLICATES IS USED WITHOUT SORTING
**************************************************

****Begin of change by Vrishti, 16/2/2016
*          ELSEIF  ( wa_zauct_errors-loops <> '' AND " to check loops
*           " 'DELETE ADJACENT DUPLICATES IS USED WITHOUT SORTING'
*             wa_zauct_errors-opercd = 46 )
          ELSEIF ( wa_zauct_errors-opercd = 46
***********BOC Shreeda 3/05/2017************
            OR wa_zauct_errors-opercd = 79
***********EOC Shreeda 3/05/2017************
            )
****End of change by Vrishti, 16/2/2016
           AND  wa_zauct_errors-runn = ''.

            CALL METHOD go_hana->check_opcode46( ).
            wa_hana-detected = 'X'.
*{ Begin of Change by Rohit - 09/02/2016
*            MODIFY zdb_analysis_v74 FROM wa_hana .
            APPEND wa_hana TO it_hana_corr.
*} End of change by Rohit - 09/02/2016
            CLEAR : wa_hana.

**************************************************
* BYPASS TABLE BUFFER - Syntax Error
**************************************************
*begin of change by vrishti-24/1/2017 : Def_2
*          ELSEIF (
*            wa_zauct_errors-opercd = 37 )
*            AND  wa_zauct_errors-runn = ''.
*
*            CALL METHOD go_hana->check_opcode37( ).
*            wa_hana-detected = 'X'.
**{ Begin of Change by Rohit - 09/02/2016
**            MODIFY zdb_analysis_v74 FROM wa_hana .
*            APPEND wa_hana TO it_hana_corr.
**} End of change by Rohit - 09/02/2016
*            CLEAR : wa_hana.
*end of change by vrishti-24/1/2017 : Def_2

*{ Begin of change by Twara - 12/02/2016
**************************************************
* READ STATEMENT WITH BINARY AND WITHOUT SORTING
**************************************************
*          ELSEIF ( wa_zauct_errors-loops <> '' AND " to check loops
*         " 'READ STATEMENT WITH BINARY AND WITHOUT SORTING'
*             wa_zauct_errors-opercd = 45 )
*            AND  wa_zauct_errors-runn = ''.
*
*            CALL METHOD go_hana->check_opcode45( ).
*            wa_hana-detected = 'X'.
**{ Begin of Change by Rohit - 09/02/2016
**            MODIFY zdb_analysis_v74 FROM wa_hana .
*            APPEND wa_hana TO it_hana_corr.
**} End of change by Rohit - 09/02/2016
*            CLEAR : wa_hana.
*} End of change by Twara - 12/02/2016

*{ Begin of change by Twara - 12/02/2016
**************************************************
* READ STATEMENT with BINARY, Unsorted Internal table
* With Index, Control Statement in loop of Unsorted
* Internal Table
**************************************************
          ELSEIF "( wa_zauct_errors-loops <> '' AND
            ( wa_zauct_errors-opercd = 45 OR
              wa_zauct_errors-opercd = 18 OR
              wa_zauct_errors-opercd = 19 )
            AND  wa_zauct_errors-runn = ''.

            CALL METHOD go_hana->check_opcode45_18_19( ).
            wa_hana-detected = 'X'.
*{ Begin of Change by Rohit - 09/02/2016
*            MODIFY zdb_analysis_v74 FROM wa_hana .
            APPEND wa_hana TO it_hana_corr.
*} End of change by Rohit - 09/02/2016
            CLEAR : wa_hana.

*} End of change by Twara - 12/02/2016

**************************************************
* Logic for DDIC function modules
**************************************************

          ELSEIF ( wa_zauct_errors-opercd = 12 )
            AND  wa_zauct_errors-runn = ''.

            CALL METHOD go_hana->check_opcode12( ).
            wa_hana-detected = 'X'.
*{ Begin of Change by Rohit - 09/02/2016
*            MODIFY zdb_analysis_v74 FROM wa_hana .
            APPEND wa_hana TO it_hana_corr.
*} End of change by Rohit - 09/02/2016
            CLEAR : wa_hana.

**************************************************
* NOT INITIAL CHECK - FOR ALL ENTRIES
**************************************************
*          begin of changes by vrishti - 24/1/2017 : Def_2
*          ELSEIF (
*            wa_zauct_errors-opercd = 41 )
*            AND  wa_zauct_errors-runn = ''.
*
*            CALL METHOD go_hana->check_opcode41( ).
*            wa_hana-detected = 'X'.
**{ Begin of Change by Rohit - 09/02/2016
**            MODIFY zdb_analysis_v74 FROM wa_hana .
*            APPEND wa_hana TO it_hana_corr.
**} End of change by Rohit - 09/02/2016
*            CLEAR : wa_hana.
*          end of changes by vrishti - 24/1/2017 : Def_2
            "begin of code change for def_18
          ELSEIF (
            wa_zauct_errors-opercd = 57 )
            AND  wa_zauct_errors-runn = ''.
            CALL METHOD go_hana->check_opcode57( ).
            wa_hana-detected = 'X'.
            APPEND wa_hana TO it_hana_corr.
*} End of change by Rohit - 09/02/2016
            CLEAR : wa_hana.
            "end of code change of def_18
          ENDIF.

************************
** end of HANA checks
************************
          MODIFY i_zauct_errors FROM wa_zauct_errors.
          CLEAR: wa_zauct_errors.
        ENDLOOP.

        IF g_corr_done = 'X'.
          CALL METHOD go_hana->lock_object( ).
        ENDIF.


**************************************************
* SPLIT SCREEN ADDITION *** START ****
* Need to check the logic
**************************************************

*SELECT * INTO TABLE lt_auctcopy FROM zauct_copy  WHERE pname =
*            wa_zauct_errors_tmp-pgname.
*            IF NOT sy-subrc IS INITIAL.
*              go_hana->version_create( ).
*              CLEAR lt_auctcopy.
*              lt_auctcopy-pname =  wa_zauct_errors_tmp-pgname.
*              APPEND lt_auctcopy TO lt_auctcopy[].
*              MODIFY zauct_copy FROM TABLE lt_auctcopy.
*            ENDIF.


**************************************************
* SPLIT SCREEN ADDITION *** END ****
* Need to check the logic
**************************************************

        IF NOT wa_zauct_errors_tmp-pgname IS INITIAL.
          DELETE i_zauct_errors_tmp WHERE pgname =
    wa_zauct_errors_tmp-pgname.
        ENDIF.
        CLEAR: lt_messages, wa_e071,lt_messages_repair, wa_e071r,
        wa_tadir
        , wa_zauct_errors_tmp.
      ENDIF.
    ENDLOOP.
*{ Begin of Change by Rohit - 09/02/2016
    "/ Delete entries of inactive objects from Output table
    IF NOT gr_object IS INITIAL.
      DELETE gt_correction_results
        WHERE obj_name NOT IN gr_object.
    ENDIF.
*} End of change by Rohit - 09/02/2016
  ENDMETHOD.                    "perform_checks

  METHOD display_result.
    TYPES: BEGIN OF ty_final,
             status      TYPE string,
             obj_name    TYPE string,
             sub_program TYPE string,
             line_org    TYPE string,
             line_no     TYPE string,
             opcode      TYPE string,
             mssg        TYPE string,
             scol        TYPE lvc_t_scol,
           END OF ty_final.
    DATA: lt_final     TYPE TABLE OF ty_final,
          lwa_final    TYPE ty_final,
          lo_alv       TYPE REF TO cl_salv_table,
          lwa_color    TYPE lvc_s_scol,
          lt_color     TYPE lvc_t_scol,
          lo_columns   TYPE REF TO cl_salv_columns_table,
          lo_column    TYPE REF TO cl_salv_column_list,
          lo_functions TYPE REF TO cl_salv_functions_list.
    CLEAR: lt_final[],
           lwa_final.
    IF NOT i_issue[] IS INITIAL.
      CLEAR: lt_color[],
              lwa_color.
      lwa_color-color-col = 6.   " red color
      lwa_color-color-int = 1.
      APPEND lwa_color TO lt_color.
      LOOP AT i_issue INTO wa_issue.
        lwa_final-status = 'ISSUE'.
        lwa_final-obj_name = wa_issue-name.
        lwa_final-mssg = wa_issue-message.
        lwa_final-scol = lt_color.
        APPEND lwa_final TO lt_final.
        CLEAR lwa_final.
      ENDLOOP.
    ENDIF.

    IF NOT gt_skipped_code IS INITIAL.
      CLEAR: lt_color[],
              lwa_color.
      lwa_color-color-col = 3.   " yellow color
      lwa_color-color-int = 1.
      APPEND lwa_color TO lt_color.
      LOOP AT gt_skipped_code INTO wa_skipped_code.
        lwa_final-status = 'SKIPPED'.
        lwa_final-obj_name = wa_skipped_code-name.
        lwa_final-line_org = wa_skipped_code-old_line.
        lwa_final-line_no = wa_skipped_code-new_line.
        lwa_final-opcode = wa_skipped_code-opcode.
        lwa_final-mssg = wa_skipped_code-reason.
        lwa_final-scol = lt_color.
        APPEND lwa_final TO lt_final.
        CLEAR lwa_final.
      ENDLOOP.
    ENDIF.

    SORT gt_correction_results BY obj_name sub_program line_no opcode.
    DELETE ADJACENT DUPLICATES FROM gt_correction_results COMPARING
    obj_name sub_program line_no opcode.
    IF NOT gt_correction_results IS INITIAL.
      CLEAR: lt_color[],
              lwa_color.
      lwa_color-color-col = 5.   " green color
      lwa_color-color-int = 1.
      APPEND lwa_color TO lt_color.
      LOOP AT gt_correction_results INTO wa_correction_results.
        lwa_final-status = 'CORRECTED'.
        lwa_final-obj_name = wa_correction_results-obj_name.
        lwa_final-sub_program = wa_correction_results-sub_program.
        lwa_final-line_org = wa_correction_results-line_org.
        lwa_final-line_no = wa_correction_results-line_no.
        lwa_final-opcode = wa_correction_results-opcode.
        lwa_final-mssg = wa_correction_results-message.
        lwa_final-scol = lt_color.
        APPEND lwa_final TO lt_final.
        CLEAR lwa_final.
      ENDLOOP.
    ENDIF.

    IF NOT lt_final IS INITIAL.
      TRY.
          CALL METHOD cl_salv_table=>factory
            IMPORTING
              r_salv_table = lo_alv
            CHANGING
              t_table      = lt_final.

          lo_functions = lo_alv->get_functions( ).
          lo_functions->set_all( ).

          lo_columns = lo_alv->get_columns( ).
          lo_columns->set_color_column( 'SCOL' ).

          lo_column ?= lo_columns->get_column( 'STATUS' ).
          lo_column->set_long_text( 'Status' ).

          lo_column ?= lo_columns->get_column( 'OBJ_NAME' ).
          lo_column->set_long_text( 'Object Name' ).

          lo_column ?= lo_columns->get_column( 'SUB_PROGRAM' ).
          lo_column->set_long_text( 'Sub Program Name' ).

          lo_column ?= lo_columns->get_column( 'LINE_ORG' ).
          lo_column->set_long_text( 'Old Line No' ).

          lo_column ?= lo_columns->get_column( 'LINE_NO' ).
          lo_column->set_long_text( 'New Line NO' ).

          lo_column ?= lo_columns->get_column( 'OPCODE' ).
          lo_column->set_long_text( 'Operation Code' ).

          lo_column ?= lo_columns->get_column( 'MSSG' ).
          lo_column->set_long_text( 'Comments' ).

          lo_columns->set_optimize( 'X' ).

          lo_alv->display( ).

        CATCH cx_salv_msg .
        CATCH cx_salv_not_found.
      ENDTRY.
    ELSE.
      MESSAGE 'No data to display' TYPE 'S' DISPLAY LIKE 'E'.
    ENDIF.

  ENDMETHOD.                    "display_result

  METHOD check_opcode12.

    TYPES: BEGIN OF ty_rtab1,
             text(1000),
           END OF ty_rtab1.

    DATA: v_line         TYPE i,
          lv_index1      TYPE i,
          lv_code        TYPE string,
          p_line         TYPE i,
          lv_result_line TYPE i,
          lt_code        TYPE TABLE OF ty_rtab1,
          wa_code        TYPE ty_rtab1,
          lv_idx         TYPE i.

    DATA : wa_rtab LIKE LINE OF rtab.

    line = line + g_offset.
    READ TABLE it_hana INTO wa_hana WITH KEY
    session_id = wa_zauct_errors-session_id
    read_prog = wa_zauct_errors-pgname
    sub_program = wa_zauct_errors-sub_program
    opercd = wa_zauct_errors-error_type
    operation = wa_zauct_errors-error_message
    line_no = wa_zauct_errors-line_no.
    wa_hana-runn = 'X'.
    wa_zauct_errors-runn = 'X'.

    p_line = line.
    v_line = p_line.

    REFRESH: lt_code.

    LOOP AT rtab INTO wa_rtab FROM p_line.

      lv_index1 = sy-tabix.
      CLEAR v_str.
      v_str = wa_rtab-text.
      IF v_str IS INITIAL.
        CONTINUE.
      ENDIF.
      CONDENSE v_str.
      IF v_str(1) EQ ca_starpp OR v_str(1) EQ ca_astpp.
        APPEND wa_rtab TO lt_code.
      ELSE.

        CLEAR: v_str, v_str1.
        SPLIT wa_rtab-text AT ca_astpp  INTO v_str v_str1.
        TRANSLATE wa_rtab-text TO UPPER CASE.
        TRANSLATE v_str TO UPPER CASE.
        IF v_str1 IS NOT INITIAL.
          FIND FIRST OCCURRENCE OF ca_astpp IN wa_rtab-text MATCH OFFSET
          lv_idx.
          lv_idx = lv_idx + 1.
          wa_rtab-text+lv_idx = v_str1.
        ELSE.
          wa_rtab-text = v_str.
        ENDIF.

        SHIFT v_str LEFT DELETING LEADING space.
        CHECK v_str IS NOT INITIAL.
        IF v_str CS ca_dotpp.
          SPLIT v_str AT ca_dotpp INTO v_str v_str1.
          CONCATENATE lv_code v_str INTO lv_code SEPARATED BY space.
          APPEND wa_rtab TO lt_code.
          EXIT.
        ELSE.
          CONCATENATE lv_code v_str INTO lv_code SEPARATED BY space.
          APPEND wa_rtab TO lt_code.
        ENDIF.
      ENDIF.
    ENDLOOP.


    LOOP AT lt_code INTO wa_code.
      CLEAR v_str.
      v_str1 = wa_code-text.
      CONDENSE v_str.
      IF v_str CS 'CALL FUNCTION'.
        EXIT.
      ENDIF.
    ENDLOOP.

    IF v_str CS 'CALL FUNCTION' AND
     ( v_str CS 'DB_EXISTS_INDEX' OR v_str CS 'DD_INDEX_NAME' ).
      LOOP AT rtab INTO wa_rtab FROM v_line TO lv_index1.
        CONDENSE wa_rtab.
        IF wa_rtab+0(1) NE ca_starpp AND wa_rtab+0(1) NE ca_astpp.
          SHIFT wa_rtab LEFT DELETING LEADING space.
          CONCATENATE '*' wa_rtab INTO wa_rtab.
          MODIFY rtab FROM wa_rtab.
        ELSEIF wa_rtab CS ca_dotpp AND ( wa_rtab+0(1) NE ca_starpp
          AND wa_rtab+0(1) NE ca_astpp ).
          SHIFT wa_rtab LEFT DELETING LEADING space.
          CONCATENATE '*' wa_rtab INTO wa_rtab.
          MODIFY rtab FROM wa_rtab.
          EXIT.
        ENDIF.
      ENDLOOP.
    ENDIF.
    IF NOT sy-subrc = 0.
      CLEAR: wa_skipped_code.
      wa_skipped_code-name = wa_zauct_errors-pgname.
      wa_skipped_code-old_line = wa_zauct_errors-line_no.
      wa_skipped_code-new_line = line.
      wa_skipped_code-opcode = wa_zauct_errors-error_type.
      wa_skipped_code-reason =
'Code fix skipped as the code does not contain FM DB_EXISTS_INDEX/DD_' &
'INDEX_NAME'
      .
      APPEND wa_skipped_code TO gt_skipped_code.
      EXIT.
    ENDIF.
    INSERT comment_start INTO rtab INDEX p_line.
    lv_result_line = p_line.
    p_line = p_line + 1.
    v_line = v_line + 1.
    lv_index1 = lv_index1 + 2.
    INSERT comment_end INTO rtab INDEX lv_index1.
    p_line = p_line + 1.
    v_line = v_line + 1.
    g_offset = g_offset + 2.
    wa_hana-actual_corr = 'Y'.
    wa_zauct_errors-actual_corr = 'Y'.
    g_corr_done = 'X'.

    CLEAR: wa_correction_results.
    wa_correction_results-obj_name = wa_zauct_errors-obj_name.
    wa_correction_results-sub_program = wa_zauct_errors-sub_program.
    wa_correction_results-line_org = wa_zauct_errors-line_no.
    wa_correction_results-line_no = lv_result_line.
    wa_correction_results-opcode = wa_zauct_errors-error_type.
    APPEND wa_correction_results TO gt_correction_results.

  ENDMETHOD.                    "check_opcode12

***begin of changes by Vrishti - 24/1/2017 : Def_2
*  METHOD check_opcode13.
*
*    DATA: p_line TYPE i.
*    DATA: v_line            TYPE i,
*          v_str             TYPE string,
*          v_str1            TYPE string,
*          v_str2            TYPE string,
*          v_strf            TYPE string,
*          lv_code           TYPE string,
*          lv_flag           TYPE c,
*          lv_index          TYPE sy-tabix,
*          lv_flag_no_append TYPE c.
*    TYPES: BEGIN OF ty_rtab1,
*             text(1000),
*           END OF ty_rtab1.
*    DATA: it_break TYPE TABLE OF ty_rtab1.
*
*    DATA: rtab1    TYPE TABLE OF ty_rtab1,
*          wa_rtab1 TYPE ty_rtab1,
*          lt_code  TYPE TABLE OF ty_rtab1,
*          wa_code  TYPE ty_rtab1,
*          lv_idx   TYPE i.
*
*    FIELD-SYMBOLS: <fs_code> TYPE ty_rtab1.
*
*    DATA : wa_break LIKE LINE OF it_break,
*           lv_len   TYPE i,
*           lv_len1  TYPE i,
*           lv_tlen  TYPE i,
*           lv_tlen1 TYPE i.
*
*    line = line + g_offset.
*    READ TABLE it_hana INTO wa_hana WITH KEY
*     session_id = wa_zauct_errors-session_id
*     read_prog = wa_zauct_errors-pgname
*     sub_program = wa_zauct_errors-sub_program
*     opercd = wa_zauct_errors-error_type
*     operation = wa_zauct_errors-error_message
*     line_no = wa_zauct_errors-line_no.
*
*    wa_hana-runn = 'X'.
*    wa_zauct_errors-runn = 'X'.
*
*    p_line = line.
*    v_line = p_line.
*
*    REFRESH: lt_code.
*
*    CLEAR: lv_flag_no_append.
*
*    LOOP AT rtab INTO wa_rtab FROM p_line.
*
*      v_line = sy-tabix.
*      CLEAR v_str.
*      v_str = wa_rtab-text.
*      IF v_str IS INITIAL.
*        CONTINUE.
*      ENDIF.
*      CONDENSE v_str.
*      IF v_str(1) EQ ca_starpp OR v_str(1) EQ ca_astpp.
*        IF lv_flag_no_append IS INITIAL.
*          APPEND wa_rtab TO lt_code.
*        ENDIF.
*      ELSE.
*
*        CLEAR: v_str, v_str1.
*        IF lv_flag_no_append IS INITIAL.
*          SPLIT wa_rtab-text AT ca_astpp  INTO v_str v_str1.
*        ELSE.
*          v_str = wa_rtab-text.
*        ENDIF.
*
*        TRANSLATE v_str TO UPPER CASE.
*        IF v_str CS '%_HINTS'.
*          lv_flag_no_append = 'X'.
*          SPLIT v_str AT '%_HINTS'  INTO v_str v_str1.
*          CONCATENATE v_str '.' INTO v_strf.
*          CLEAR: v_str,
*                 v_str1.
*          v_str = wa_rtab-text.
*          TRANSLATE v_str TO UPPER CASE.
*          wa_rtab-text = v_strf.
*          APPEND wa_rtab TO lt_code.
*
*        ENDIF.
*        TRANSLATE wa_rtab-text TO UPPER CASE.
*
*        IF NOT v_str1 IS INITIAL.
*          FIND FIRST OCCURRENCE OF ca_astpp IN wa_rtab-text MATCH OFFSET
*          lv_idx.
*          lv_idx = lv_idx + 1.
*          wa_rtab-text+lv_idx = v_str1.
*        ELSE.
*          wa_rtab-text = v_str.
*        ENDIF.
*
*        SHIFT v_str LEFT DELETING LEADING space.
*        CHECK NOT v_str IS INITIAL.
*        IF v_str CS ca_dotpp.
*          SPLIT v_str AT ca_dotpp INTO v_str v_str1.
*          CONCATENATE lv_code v_str INTO lv_code SEPARATED BY space.
*          IF lv_flag_no_append IS INITIAL.
*            APPEND wa_rtab TO lt_code.
*          ENDIF.
*          EXIT.
*        ELSE.
*          CONCATENATE lv_code v_str INTO lv_code SEPARATED BY space.
*          IF lv_flag_no_append IS INITIAL.
*            APPEND wa_rtab TO lt_code.
*          ENDIF.
*        ENDIF.
*      ENDIF.
*    ENDLOOP.
*
*** Check if error is real**
*    CONDENSE lv_code.
*    TRANSLATE lv_code TO UPPER CASE.
*    IF NOT lv_code CS '%_HINTS'.
*      CLEAR: wa_skipped_code.
*      wa_skipped_code-name = wa_zauct_errors-pgname.
*      wa_skipped_code-old_line = wa_zauct_errors-line_no.
*      wa_skipped_code-new_line = line.
*      wa_skipped_code-opcode = wa_zauct_errors-error_type.
*      wa_skipped_code-reason =
*      'Code fix skipped as the code does not contain %_HINTS'.
*      APPEND wa_skipped_code TO gt_skipped_code.
*      EXIT.
*    ENDIF.
*** End Check **
*
*    IF lv_flag = ''.
*
*      INSERT comment_start INTO rtab INDEX p_line.
*      p_line = p_line + 1.
*      v_line = v_line + 1.
*      LOOP AT rtab INTO wa_rtab FROM p_line TO v_line.
*        CONCATENATE '*'  wa_rtab-text INTO wa_rtab-text.
*        MODIFY rtab FROM wa_rtab.
*      ENDLOOP.
*      CLEAR rtab1[].
*
*      rtab1[] = lt_code[].
*      CLEAR : lv_tlen , lv_len , lv_len1 , lv_tlen1.
*      APPEND comment_end TO rtab1.
*      v_line = v_line + 1.
*      DESCRIBE TABLE rtab1 LINES lv_tlen.
*      INSERT LINES OF rtab1 INTO rtab INDEX v_line .
*
*      g_offset = g_offset + 1 + lv_tlen.
*      wa_hana-actual_corr = 'Y'.
*      wa_zauct_errors-actual_corr = 'Y'.
*      g_corr_done = 'X'.
*      CLEAR : lv_tlen.
*
*      CLEAR: wa_correction_results.
*      wa_correction_results-obj_name = wa_zauct_errors-obj_name.
*      wa_correction_results-sub_program = wa_zauct_errors-sub_program.
*      wa_correction_results-line_org = wa_zauct_errors-line_no.
*      wa_correction_results-line_no = v_line.
*      wa_correction_results-opcode = wa_zauct_errors-error_type.
*      APPEND wa_correction_results TO gt_correction_results.
*    ENDIF.
*  ENDMETHOD.
***end of changes by Vrishti - 24/1/2017 : Def_2

*****begin of changes by Vrishti - 24/1/2017 : Def_2
  METHOD check_hana_opcode.

    DATA: v_line                TYPE i,
          lv_sort               TYPE i,
          lv_sort1              TYPE i,
          v_str                 TYPE string,
          v_app                 TYPE string,
          v_app1                TYPE string,
          lv_code               TYPE string,
          lv_flag               TYPE c,
          lv_flag_close_comment TYPE c,
          lv_flag_comment       TYPE c,
          lv_comment            TYPE c,
          lv_type_of_table      TYPE c,
          v_str2                TYPE string,
          v_str3                TYPE string.

    TYPES: BEGIN OF ty_rtab1,
             text(1000),
           END OF ty_rtab1.
    DATA:
      p_line    TYPE i,
      lv_v_line TYPE i,
      lv_appl   TYPE i.

    DATA: rtab1          TYPE TABLE OF ty_rtab1,
          rtab2          TYPE TABLE OF ty_rtab1,
          wa_rtab1       TYPE ty_rtab1,
          lt_code        TYPE TABLE OF ty_rtab1,
          wa_code        TYPE ty_rtab1,
          rtab13         TYPE TABLE OF ty_rtab1,
          rtab37         TYPE TABLE OF ty_rtab1,
          rtab3_7        TYPE TABLE OF ty_rtab1,
          rtab41         TYPE TABLE OF ty_rtab1,
          wa_hana_41     TYPE zdb_analysis_v74,
          lv_last_idx    TYPE i,
          lv_idx         TYPE i,
          lv_new(1000)   TYPE c,
          lv_flag2_start TYPE c.

    FIELD-SYMBOLS: <fs_code>     TYPE ty_rtab1,
                   <fs_auct_err> TYPE zauct_struct.


    DATA : lv_len   TYPE i,
           lv_len1  TYPE i,
           lv_tlen  TYPE i,
           lv_tlen1 TYPE i,
           v_strc1  TYPE string,
           v_strc2  TYPE string.

    TYPES: BEGIN OF ty_code11,
             text(1000) TYPE c,
           END OF ty_code11,

           BEGIN OF ty_code,
             line(150),
           END   OF ty_code.
    DATA:  lt_tab4   TYPE TABLE OF ty_code11.
    DATA: lwa_tab4 TYPE ty_code11.
    DATA: lv_pos1 TYPE sy-tabix.
    DATA: lv_pos2 TYPE sy-tabix.
    DATA: lv_flag1 TYPE flag.
    DATA: lv_flag2     TYPE flag,
          v_keys       TYPE string,
          i_keys       TYPE STANDARD TABLE OF ty_code,
          wa_keys      TYPE ty_code,
          v_fae        TYPE flag,
          v_fae_m      TYPE flag,
          i_keys1      TYPE STANDARD TABLE OF ty_code,
          wa_keys1     TYPE ty_code,
          v_keys1      TYPE string,
          v_keys2      TYPE string,
          v_keys3      TYPE string,
          gv_line      TYPE i,
          lv_temp      TYPE string,
          lv_opcode_13 TYPE c,
          lv_opcode_16 TYPE c,
          lv_opcode_37 TYPE c,
          lv_ccount    TYPE i,
          i_result1    TYPE TABLE OF match_result,
          l_times1     TYPE i,
          wa_result    TYPE match_result,
          pos_dot      TYPE i,
          line1        TYPE i.

    DATA: v_strf            TYPE string,
          lv_index          TYPE sy-tabix,
          lv_flag_no_append TYPE c.

    line = line + g_offset.
    p_line = line.
    v_line = p_line.
    lv_v_line = p_line.

*SELECT * FROM zdb_analysis_v751 INTO TABLE it_hana_check
*  WHERE obj_name = lv_prog AND
*        line_no = line_check AND
*        session_id IN s_sid.
*    LOOP AT it_hana_check INTO wa_hana_check.
    LOOP AT it_hana INTO wa_hana_check
      WHERE obj_name = lv_prog AND
          line_no = line_check AND
          session_id IN s_sess .

      IF wa_hana_check-opercd = '13' AND wa_hana_check-runn = ' ' .

        wa_hana-runn = 'X'.
        wa_zauct_errors-runn = 'X'.
        wa_hana_check-runn = 'X'.
        REFRESH: lt_code.

        CLEAR: lv_flag_no_append.

        LOOP AT rtab INTO wa_rtab FROM p_line.

          v_line = sy-tabix.
          CLEAR v_str.
          v_str = wa_rtab-text.
          IF v_str IS INITIAL.
            CONTINUE.
          ENDIF.
          CONDENSE v_str.
          IF v_str(1) EQ ca_starpp OR v_str(1) EQ ca_astpp.
            IF lv_flag_no_append IS INITIAL.
              APPEND wa_rtab TO lt_code.
            ENDIF.
          ELSE.

            CLEAR: v_str, v_str1.
            IF lv_flag_no_append IS INITIAL.
              SPLIT wa_rtab-text AT ca_astpp  INTO v_str v_str1.
            ELSE.
              v_str = wa_rtab-text.
            ENDIF.

            TRANSLATE v_str TO UPPER CASE.
            IF v_str CS '%_HINTS'.
              lv_flag_no_append = 'X'.
              SPLIT v_str AT '%_HINTS'  INTO v_str v_str1.
              CONCATENATE v_str '.' INTO v_strf.
              CLEAR: v_str,
                     v_str1.
              v_str = wa_rtab-text.
              TRANSLATE v_str TO UPPER CASE.
              wa_rtab-text = v_strf.
              APPEND wa_rtab TO lt_code.

            ENDIF.
            TRANSLATE wa_rtab-text TO UPPER CASE.

            IF NOT v_str1 IS INITIAL.
              FIND FIRST OCCURRENCE OF ca_astpp IN wa_rtab-text MATCH OFFSET
              lv_idx.
              lv_idx = lv_idx + 1.
              wa_rtab-text+lv_idx = v_str1.
            ELSE.
              wa_rtab-text = v_str.
            ENDIF.

            SHIFT v_str LEFT DELETING LEADING space.
            CHECK NOT v_str IS INITIAL.
            IF v_str CS ca_dotpp.
              SPLIT v_str AT ca_dotpp INTO v_str v_str1.
              CONCATENATE lv_code v_str INTO lv_code SEPARATED BY space.
              IF lv_flag_no_append IS INITIAL.
                APPEND wa_rtab TO lt_code.
              ENDIF.
              EXIT.
            ELSE.
              CONCATENATE lv_code v_str INTO lv_code SEPARATED BY space.
              IF lv_flag_no_append IS INITIAL.
                APPEND wa_rtab TO lt_code.
              ENDIF.
            ENDIF.
          ENDIF.
        ENDLOOP.

** Check if error is real**
        CONDENSE lv_code.
        TRANSLATE lv_code TO UPPER CASE.
        IF NOT lv_code CS '%_HINTS'.
          CLEAR: wa_skipped_code.
          wa_skipped_code-name = wa_hana_check-obj_name.
          wa_skipped_code-old_line = wa_hana_check-line_no.
          wa_skipped_code-new_line = line.
          wa_skipped_code-opcode = wa_hana_check-opercd.
          wa_skipped_code-reason =
          'Code fix skipped as the code does not contain %_HINTS'.
          APPEND wa_skipped_code TO gt_skipped_code.
          EXIT.
        ENDIF.


** End Check **

        IF lv_flag = ''.
*      INSERT comment_start_hana INTO ritab INDEX p_line.   "common
*      p_line = p_line + 1.                                 "common
*      v_line = v_line + 1.                                 "common
*          lv_flag_comment = 'X'.
*          LOOP AT ritab INTO wa_rtab FROM p_line TO v_line.
*            lv_ccount = lv_ccount + 1.
*            CONCATENATE '*'  wa_rtab-text INTO wa_rtab-text.
*            MODIFY ritab FROM wa_rtab.
*          ENDLOOP.
          CLEAR rtab13[].

          rtab13[] = lt_code[].

          IF rtab13 IS NOT INITIAL.
            lv_opcode_13 = 'X'.
            wa_hana_check-actual_corr = 'Y'.

            IF wa_zauct_errors-opercd = wa_hana_check-opercd.
              wa_hana-actual_corr = 'Y'.
              wa_zauct_errors-actual_corr = 'Y'.
            ENDIF.
          ENDIF.

          CLEAR : lv_tlen , lv_len , lv_len1 , lv_tlen1.
*      APPEND comment_end_hana TO rtab1.  "common
*      v_line = v_line + 1.               "common
*      DESCRIBE TABLE rtab1 LINES lv_tlen. "13 specific
*      INSERT LINES OF rtab1 INTO ritab INDEX v_line . "13specific
*
*      g_offset = g_offset + 1 + lv_tlen.
*          wa_hana_check-actual_corr = 'Y'.
*      wa_zauct_errors-actual_corr = 'Y'.
          g_corr_done = 'X'.
          CLEAR : lv_tlen.

          CLEAR: wa_correction_results.
          wa_correction_results-obj_name = wa_hana_check-obj_name.
          wa_correction_results-sub_program = wa_hana_check-sub_program.
          wa_correction_results-line_org = wa_hana_check-line_no.
          wa_correction_results-line_no = v_line.
          wa_correction_results-opcode = wa_hana_check-opercd.
          APPEND wa_correction_results TO gt_correction_results.
        ENDIF.



        READ TABLE i_zauct_errors ASSIGNING <fs_auct_err> WITH KEY
                     session_id = wa_zauct_errors-session_id
                     obj_name = wa_zauct_errors-obj_name
                     sub_program = wa_zauct_errors-sub_program
                     opercd = 13
                     line_no = wa_zauct_errors-line_no
                     runn = ''.
        IF sy-subrc = 0.
          <fs_auct_err>-runn = 'X'.
          <fs_auct_err>-actual_corr = wa_hana_check-actual_corr.
*        <fs_auct_err>-new_line =  lv_newline.
          MODIFY i_zauct_errors FROM <fs_auct_err> INDEX lv_indx.
        ENDIF.


      ENDIF.

      IF wa_hana_check-opercd = '16' AND wa_hana_check-runn = ' ' .

        wa_hana-runn = 'X'.
        wa_zauct_errors-runn = 'X'.
        wa_hana_check-runn = 'X'.
        CLEAR : v_strc1 , v_keys , v_strc2,
              i_keys,wa_keys.
        REFRESH : i_keys[].
        v_keys = wa_hana_check-keys.
        SPLIT v_keys AT '|' INTO TABLE i_keys.
        LOOP AT i_keys INTO wa_keys.
          IF wa_keys CS '~'.
            SPLIT wa_keys-line AT '~' INTO v_strc1 v_keys.
            wa_keys = v_keys.
            MODIFY i_keys FROM wa_keys.
          ELSEIF wa_keys CS '-'.
            SPLIT wa_keys-line AT '-' INTO v_strc1 v_strc2.
            wa_keys = v_strc2.
            MODIFY i_keys FROM wa_keys.
          ELSE.
            CONTINUE.
          ENDIF.
          CLEAR : v_strc1 , v_keys , v_strc2,
                  wa_keys.
        ENDLOOP.
        DELETE ADJACENT DUPLICATES FROM i_keys.
        DELETE i_keys WHERE line = space.
        DELETE i_keys WHERE line = 'MANDT'.
        CLEAR v_keys.
        CONCATENATE LINES OF i_keys INTO v_keys SEPARATED BY space.
        IF NOT v_keys IS INITIAL.
****Start of change for select fields for all entries issue
          CLEAR: v_fae,
                 v_fae_m.
          CLEAR: v_keys1,
                 v_keys2,
                 v_keys3.
          IF wa_hana_check-code CS 'SELECT' AND wa_hana_check-code CS 'FOR ALL ENTRIES'.
            IF wa_hana_check-code CS 'SELECT *'.
              CLEAR v_keys2.
              v_fae = 'X'.
***Begin of change by Vrishti, 12/2/2016
            ELSEIF wa_hana_check-fields = ''.
              CLEAR: wa_skipped_code.
              wa_skipped_code-name = wa_hana_check-obj_name.
              wa_skipped_code-old_line = wa_hana_check-line_no.
              wa_skipped_code-new_line = line.
              wa_skipped_code-opcode = wa_hana_check-opercd.
              wa_skipped_code-reason = ' Manual Intervention Required '.
              APPEND wa_skipped_code TO gt_skipped_code.
              EXIT.

***End of change by Vrishti, 12/2/2016
            ELSE.
              v_keys1 = wa_hana_check-fields.
              FIELD-SYMBOLS: <fs_keys1> TYPE ty_code.

              SPLIT v_keys1 AT '|' INTO TABLE i_keys1.
              LOOP AT i_keys1 INTO wa_keys1.
                IF wa_keys1 CS '~'.
                  SPLIT wa_keys1-line AT '~' INTO v_strc1 v_keys1.
                  wa_keys1 = v_keys1.
                  MODIFY i_keys1 FROM wa_keys1.
                ELSEIF wa_keys1 CS '-'.
                  SPLIT wa_keys1-line AT '-' INTO v_strc1 v_strc2.
                  wa_keys1 = v_strc2.
                  MODIFY i_keys1 FROM wa_keys1.
                ELSE.
                  CONTINUE.
                ENDIF.
                CLEAR : v_strc1 , v_keys1 , v_strc2,
                       wa_keys1.
              ENDLOOP.
              DELETE ADJACENT DUPLICATES FROM i_keys1.
              DELETE i_keys1 WHERE line = space.
              CLEAR v_keys1.
              CONCATENATE LINES OF i_keys1 INTO v_keys1 SEPARATED BY space.
              LOOP AT i_keys
                ASSIGNING <fs_keys1>.
                READ TABLE i_keys1
                  TRANSPORTING NO FIELDS
                  WITH KEY line = <fs_keys1>-line.
                IF sy-subrc EQ 0.
                  "/ do-nothing
                  CONCATENATE v_keys2 <fs_keys1>-line INTO v_keys2 SEPARATED
                  BY space.
                ELSE.
                  CLEAR v_fae_m.
                  v_fae_m = 'X'.
                ENDIF.
              ENDLOOP.
              IF v_fae_m IS INITIAL. " for all matched keys
                CLEAR v_keys2.
                v_fae = 'X'.
              ENDIF.
              IF NOT v_keys2 IS INITIAL.
                CONDENSE v_keys2.
                CONCATENATE 'SORT' wa_hana_check-itab 'BY' v_keys2 '.' INTO
                v_keys2 SEPARATED BY space.
              ENDIF.
            ENDIF.
*****Begin of change by Vrishti, 15/2/2016
            "Changes Made for select<dyanmic field> issue
*{ Begin of change by Twara - 12/02/2016
*      ELSEIF wa_hana-code CS 'SELECT ('
            CONDENSE wa_hana_check-code.
          ELSEIF wa_hana_check-code CS 'SELECT (' OR
            wa_hana_check-code CS 'FROM ('.
*} End of change by Twara - 12/02/2016
            CLEAR: wa_skipped_code.
            wa_skipped_code-name = wa_hana_check-obj_name.
            wa_skipped_code-old_line = wa_hana_check-line_no.
            wa_skipped_code-new_line = line.
            wa_skipped_code-opcode = wa_hana_check-opercd.
            wa_skipped_code-reason =
            'Code fix skipped as SELECT contains dynamic fields/dynamic table'.
            APPEND wa_skipped_code TO gt_skipped_code.
            EXIT.
****End of change by Vrishti, 15/2/2016
          ELSE.
****End of change for select fields for all entries issue
            CONCATENATE 'ORDER BY' v_keys INTO v_keys SEPARATED BY space.
          ENDIF.
        ENDIF.

        REFRESH : lt_tab4[].


        CLEAR: lv_pos1, lv_pos2.
        CLEAR: lv_flag2, lv_flag_close_comment.
        p_line = line.
        v_line = p_line.
        gv_line = p_line.

        REFRESH: lt_code.
        CLEAR lv_code.
        LOOP AT rtab INTO wa_rtab FROM p_line.

          v_line = sy-tabix.
          CLEAR v_str.
          v_str = wa_rtab-text.
          IF v_str IS INITIAL.
            CONTINUE.
          ENDIF.
          CONDENSE v_str.
          IF v_str(1) EQ ca_starpp OR v_str(1) EQ ca_astpp.
            APPEND wa_rtab TO lt_code.
          ELSE.

            CLEAR: v_str, v_str1.
            SPLIT wa_rtab-text AT ca_astpp  INTO v_str v_str1.
            TRANSLATE wa_rtab-text TO UPPER CASE.
            TRANSLATE v_str TO UPPER CASE.

************
            IF v_str CS '%_HINTS'.
              lv_flag_no_append = 'X'.
              SPLIT v_str AT '%_HINTS'  INTO v_str v_str1.
              v_strf = v_str.
              CLEAR: v_str,
                     v_str1.
              v_str = wa_rtab-text.
              TRANSLATE v_str TO UPPER CASE.
              wa_rtab-text = v_strf.
*              APPEND wa_rtab TO lt_code.

            ENDIF.
******************

            IF NOT v_str1 IS INITIAL.
              FIND FIRST OCCURRENCE OF ca_astpp IN wa_rtab-text MATCH OFFSET
              lv_idx.
              lv_idx = lv_idx + 1.
              wa_rtab-text+lv_idx = v_str1.
            ELSE.
              wa_rtab-text = v_str.
            ENDIF.

            SHIFT v_str LEFT DELETING LEADING space.
            CHECK NOT v_str IS INITIAL.
            IF v_str CS ca_dotpp.

              FIND ALL OCCURRENCES OF '.' IN wa_rtab RESULTS i_result1.
              DESCRIBE TABLE i_result1 LINES l_times1.

*              if l_times1 > 1.
              READ TABLE i_result1 INTO wa_result INDEX l_times1.
              pos_dot = wa_result-offset.
              line1 = wa_result-length.
              CLEAR: wa_result.
              IF pos_dot > 0."change for def_27
                v_str = wa_rtab+0(pos_dot).
                v_str1 = wa_rtab+pos_dot.
              ENDIF."change for def_27
              CONCATENATE lv_code v_str INTO lv_code SEPARATED BY space.
*              CONDENSE wa_rtab.
              REPLACE SECTION OFFSET pos_dot LENGTH 1 OF wa_rtab WITH ' '.
              APPEND wa_rtab TO lt_code.
              EXIT.
*                ELSE.
*              SPLIT v_str AT ca_dotpp INTO v_str v_str1.
*              CONCATENATE lv_code v_str INTO lv_code SEPARATED BY space.
*              REPLACE FIRST OCCURRENCE OF '.' IN wa_rtab WITH ' '.
*              APPEND wa_rtab TO lt_code.
*              EXIT.
*              endif.
            ELSE.
              CONCATENATE lv_code v_str INTO lv_code SEPARATED BY space.
              APPEND wa_rtab TO lt_code.
            ENDIF.
          ENDIF.
        ENDLOOP.

        DESCRIBE TABLE lt_code LINES lv_sort.
** Check if error is real**
        CONDENSE lv_code.
        TRANSLATE lv_code TO UPPER CASE.
        IF NOT ( lv_code CS 'SELECT' AND lv_code CS 'FROM' ).
          CLEAR: wa_skipped_code.
          wa_skipped_code-name = wa_hana_check-obj_name.
          wa_skipped_code-old_line = wa_hana_check-line_no.
          wa_skipped_code-new_line = line.
          wa_skipped_code-opcode = wa_hana_check-opercd.
          wa_skipped_code-reason =
          'Code fix skipped as the code does not contain SELECT statement'.
          APPEND wa_skipped_code TO gt_skipped_code.
          EXIT.
        ENDIF.
** End Check **
******Changes Made for select single issue
        IF lv_code CS 'SELECT SINGLE'.
          IF lv_code CS 'SELECT SINGLE *'.
            IF lv_code CS 'CLIENT SPECIFIED'.
              CLEAR: wa_skipped_code.
              wa_skipped_code-name = wa_hana_check-obj_name.
              wa_skipped_code-old_line = wa_hana_check-line_no.
              wa_skipped_code-new_line = line.
              wa_skipped_code-opcode = wa_hana_check-opercd.
              wa_skipped_code-reason =
    'Code fix skipped as it contains SELECT SINGLE * with CLIENT SPECIFIED'
              .
              APPEND wa_skipped_code TO gt_skipped_code.
              EXIT.
            ENDIF.
          ELSE.
            CLEAR: wa_skipped_code.
            wa_skipped_code-name = wa_hana_check-obj_name.
            wa_skipped_code-old_line = wa_hana_check-line_no.
            wa_skipped_code-new_line = line.
            wa_skipped_code-opcode = wa_hana_check-opercd.
            wa_skipped_code-reason =
    'Code fix skipped as it contains SELECT SINGLE with fields list provi' &
    'ded'
            .
            APPEND wa_skipped_code TO gt_skipped_code.
            EXIT.
          ENDIF.
        ENDIF.
******End of change for select single issue
** Check for the order by existence**
        "Rest of the checks already added

        IF lv_code CS 'ORDER BY'.
          CLEAR: wa_skipped_code.
          wa_skipped_code-name = wa_hana_check-obj_name.
          wa_skipped_code-old_line = wa_hana_check-line_no.
          wa_skipped_code-new_line = line.
          wa_skipped_code-opcode = wa_hana_check-opercd.
          wa_skipped_code-reason =
          'Code fix skipped as it already contains ORDER BY clause'.
          APPEND wa_skipped_code TO gt_skipped_code.
          EXIT.
        ENDIF.
**End Check**


**** Begin of changes by Kanika - 16/3/2016
*    IF lv_code CS 'SELECT COUNT(*)'.
        lv_temp = lv_code.
        CONDENSE lv_temp NO-GAPS.
        IF lv_temp CS 'SELECTCOUNT(*)'.
          CLEAR : lv_temp.
**** End of changes by Kanika - 16/3/2016
          CLEAR: wa_skipped_code.
          wa_skipped_code-name = wa_hana_check-obj_name.
          wa_skipped_code-old_line = wa_hana_check-line_no.
          wa_skipped_code-new_line = line.
          wa_skipped_code-opcode = wa_hana_check-opercd.
          wa_skipped_code-reason =
          'Code fix skipped as it contains SELECT COUNT(*)'.
          APPEND wa_skipped_code TO gt_skipped_code.
          EXIT.
        ENDIF.

        CLEAR:lv_pos1, lv_pos2.
        IF lv_flag = ''.
          TRANSLATE lv_code TO UPPER CASE.
          SPLIT lv_code AT space INTO TABLE rtab1.
          DELETE rtab1 WHERE text IS INITIAL.
          CLEAR lv_code.

          LOOP AT rtab1 INTO wa_rtab1.
            CONCATENATE lv_code wa_rtab1-text INTO lv_code SEPARATED BY
            space.
          ENDLOOP.
          CONDENSE lv_code.

          " select single UP TO 1 ROWS.
          CLEAR: lv_flag1.

          IF lv_code CS 'SELECT SINGLE'.
            REPLACE FIRST OCCURRENCE OF 'SELECT SINGLE' IN lv_code WITH
              'SELECT'.
            LOOP AT lt_code ASSIGNING <fs_code>.
              CLEAR v_str.
              v_str = <fs_code>-text.
              CONDENSE v_str.
              IF v_str IS INITIAL.
                CONTINUE.
              ENDIF.
              IF v_str(1) EQ ca_starpp OR v_str(1) EQ ca_astpp.
                CONTINUE.
              ENDIF.
**** Begin of changes by Kanika - 16/03/2016
* Begin of changes by Sahil for DEF_16 - 5/2/2017
              CONDENSE <fs_code>-text.
* End of changes by Sahil for DEF_16 - 5/2/2017
              IF <fs_code>-text CS 'SELECT SINGLE'.
                REPLACE FIRST OCCURRENCE OF 'SELECT SINGLE' IN
                <fs_code>-text WITH
              'SELECT'.
*            IF v_str CS 'SELECT SINGLE'.
*            REPLACE FIRST OCCURRENCE OF 'SELECT SINGLE' IN
*            v_str WITH
*          'SELECT'.
**** End of changes by Kanika - 16/03/2016
                EXIT.
              ENDIF.
            ENDLOOP.
            CONDENSE lv_code.
            SPLIT lv_code AT '' INTO TABLE lt_tab4[].
            DELETE lt_tab4 WHERE text = ''.
            READ TABLE lt_tab4 INTO lwa_tab4 WITH KEY text = 'FROM'.
            IF sy-subrc = 0.
              lv_pos1 = sy-tabix.
            ENDIF.
            CLEAR: lwa_tab4.
            READ TABLE lt_tab4 INTO lwa_tab4 WITH KEY text = 'INTO'.
            IF sy-subrc = 0.
              lv_pos2 = sy-tabix.
            ELSE.
              lv_pos2 = lv_pos1.
            ENDIF.
            IF lv_pos1 > lv_pos2.
              lwa_tab4 = 'UP TO 1 ROWS'.
              INSERT lwa_tab4 INTO lt_tab4 INDEX  lv_pos2.
            ELSE.
              lwa_tab4 = 'UP TO 1 ROWS'.
              INSERT lwa_tab4 INTO lt_tab4 INDEX  lv_pos1.
            ENDIF.
            LOOP AT lt_code ASSIGNING <fs_code>.
              CLEAR v_str.
              v_str = <fs_code>-text.
              CONDENSE v_str.
              IF v_str IS INITIAL.
                CONTINUE.
              ENDIF.
              IF v_str(1) EQ ca_starpp OR v_str(1) EQ ca_astpp.
                CONTINUE.
              ENDIF.
              IF v_str CS ca_astpp.
                SPLIT v_str AT ca_astpp INTO v_str v_str1.
              ENDIF.
              IF lv_pos1 > lv_pos2.
                IF v_str CS 'INTO'.
                  REPLACE FIRST OCCURRENCE OF 'INTO' IN <fs_code>-text WITH
                  'UP TO 1 ROWS INTO'.
                  EXIT.
                ENDIF.
              ELSE.
                IF v_str CS 'FROM'.
                  REPLACE FIRST OCCURRENCE OF 'FROM' IN <fs_code>-text WITH
                  'UP TO 1 ROWS FROM'.
                  EXIT.
                ENDIF.
              ENDIF.
            ENDLOOP.
            CLEAR: lv_code.
            LOOP AT lt_tab4 INTO lwa_tab4.
              CONCATENATE lv_code lwa_tab4-text INTO lv_code SEPARATED BY
              space.
            ENDLOOP.
            CONCATENATE lv_code 'ORDER BY PRIMARY KEY' INTO lv_code
            SEPARATED
            BY space.
            lv_flag1 = 'X'.

            wa_code-text = 'ORDER BY PRIMARY KEY'.
            APPEND wa_code TO lt_code.

******Additon made - For All Enteries Clause******
*****Start of code change for select for all entries issue
          ELSEIF lv_code CS 'SELECT' AND lv_code CS 'FOR ALL ENTRIES' AND
          v_fae IS INITIAL.
            IF NOT v_keys2 IS INITIAL.
              lv_flag2 = 'X'.
            ELSE.
              CLEAR: wa_skipped_code.
              wa_skipped_code-name = wa_hana_check-obj_name.
              wa_skipped_code-old_line = wa_hana_check-line_no.
              wa_skipped_code-new_line = line.
              wa_skipped_code-opcode = wa_hana_check-opercd.
              wa_skipped_code-reason =
              'Code fix skipped as no primary key field in select list'.
              APPEND wa_skipped_code TO gt_skipped_code.
              EXIT.
            ENDIF.

**Begin of DEF_1 by priyanka <24-01-2017>
          ELSEIF ( lv_code CS '~' ) AND ( lv_code CS 'JOIN' ).
            CLEAR: wa_skipped_code.
            wa_skipped_code-name = wa_zauct_errors-pgname.
            wa_skipped_code-old_line = wa_zauct_errors-line_no.
            wa_skipped_code-new_line = line.
            wa_skipped_code-opcode = wa_zauct_errors-error_type.
            wa_skipped_code-reason =
            'Code fix skipped as select statement has a join condition'.
            APPEND wa_skipped_code TO gt_skipped_code.
            EXIT.
**End of DEF_1 by priyanka <24-01-2017>

          ELSE.
****End of code change for select for all entries issue
            CONCATENATE lv_code 'ORDER BY PRIMARY KEY' INTO lv_code
            SEPARATED
            BY space.
            wa_code-text = 'ORDER BY PRIMARY KEY'.
            APPEND wa_code TO lt_code.
          ENDIF.
          IF lv_code NS ca_dotpp.
            CONCATENATE lv_code ca_dotpp INTO lv_code.
          ENDIF.

          DESCRIBE TABLE lt_code LINES lv_last_idx.
          READ TABLE lt_code ASSIGNING <fs_code> INDEX lv_last_idx.
          IF sy-subrc = 0.
            CONCATENATE <fs_code>-text '.' INTO <fs_code>-text.
          ENDIF.

*If internal table is of type sorted table then no need to put sort by
*statement
          CLEAR lv_type_of_table.
          IF lv_code CS 'INTO TABLE' OR lv_code CS
          'INTO CORRESPONDING FIELDS OF TABLE'
            OR lv_code CS 'APPENDING TABLE' OR lv_code CS
            'APPENDING CORRESPONDING FIELDS OF TABLE'.

            IF lv_code NS 'APPENDING'.
              CLEAR: v_str.
              REFRESH: lt_tab4[].
              SPLIT lv_code AT '' INTO TABLE lt_tab4[].
              DELETE lt_tab4 WHERE text = ''.
              READ TABLE lt_tab4 INTO lwa_tab4 WITH KEY text = 'TABLE'.
              READ TABLE lt_tab4 INTO lwa_tab4 INDEX sy-tabix + 1.
              IF sy-subrc = 0.
                v_str = lwa_tab4-text.
                TRANSLATE v_str TO UPPER CASE.
                REPLACE ALL OCCURRENCES OF '[' IN v_str WITH ''.
                REPLACE ALL OCCURRENCES OF ']' IN v_str WITH ''.
                CONDENSE v_str.
                LOOP AT rtab INTO wa_rtab.
                  CLEAR: v_str1,v_str2, v_str3.
                  v_str1 = wa_rtab-text.
                  CONDENSE v_str1.
                  IF v_str1 IS INITIAL.
                    CONTINUE.
                  ENDIF.
                  IF v_str1(1) EQ ca_starpp OR v_str1(1) EQ ca_astpp.
                    CONTINUE.
                  ENDIF.
                  TRANSLATE v_str1 TO UPPER CASE.
                  REPLACE ALL OCCURRENCES OF '[' IN v_str1 WITH ''.
                  REPLACE ALL OCCURRENCES OF ']' IN v_str1 WITH ''.
                  CONDENSE v_str1.
                  CONCATENATE v_str 'TYPE' INTO v_str2 SEPARATED BY space.
                  CONCATENATE v_str 'LIKE' INTO v_str3 SEPARATED BY space.
                  IF v_str1 CS v_str2 OR v_str1 CS v_str3.
                    IF v_str1 CS 'SORTED TABLE OF'.
                      lv_type_of_table = 'S'.
                      EXIT.
                    ENDIF.
                  ELSE.
                    CONTINUE.
                  ENDIF.

                ENDLOOP.
              ENDIF.
            ENDIF.
          ENDIF.




          CLEAR rtab1[].

          IF lv_flag2 IS INITIAL.
            rtab1[] = lt_code[].

          ENDIF.


          IF NOT v_keys2 IS INITIAL
              AND lv_type_of_table NE 'S'.
*            APPEND comment_start_hana TO rtab1.
            APPEND v_keys2 TO rtab1.
            lv_flag_close_comment = 'X'.
            lv_flag2_start = 'X'.
          ENDIF.

          IF rtab1 IS NOT INITIAL.
            lv_opcode_16 = 'X'.

            wa_hana_check-actual_corr = 'Y'.
            g_corr_done = 'X'.
            IF wa_zauct_errors-opercd = wa_hana_check-opercd.
              wa_hana-actual_corr = 'Y'.
              wa_zauct_errors-actual_corr = 'Y'.
            ENDIF.
          ENDIF.

          CLEAR: lv_tlen.
          CLEAR: wa_correction_results.
          wa_correction_results-obj_name = wa_hana_check-obj_name.
          wa_correction_results-sub_program = wa_hana_check-sub_program.
          wa_correction_results-line_org = wa_hana_check-line_no.
          wa_correction_results-line_no = v_line.
          wa_correction_results-opcode = wa_hana_check-opercd.
          APPEND wa_correction_results TO gt_correction_results.
        ENDIF.


        READ TABLE i_zauct_errors ASSIGNING <fs_auct_err> WITH KEY
              session_id = wa_zauct_errors-session_id
              obj_name = wa_zauct_errors-obj_name
              sub_program = wa_zauct_errors-sub_program
              opercd = 16
              line_no = wa_zauct_errors-line_no
              runn = ''.
        IF sy-subrc = 0.
          <fs_auct_err>-runn = 'X'.
          <fs_auct_err>-actual_corr = wa_hana_check-actual_corr.
*        <fs_auct_err>-new_line =  lv_newline.
          MODIFY i_zauct_errors FROM <fs_auct_err> INDEX lv_indx.
        ENDIF.

      ENDIF.
      IF wa_hana_check-opercd = '37' AND wa_hana_check-runn = ' ' .

        wa_hana-runn = 'X'.
        wa_zauct_errors-runn = 'X'.
        wa_hana_check-runn = 'X'.
        REFRESH: lt_code.

        LOOP AT rtab INTO wa_rtab FROM p_line.

          v_line = sy-tabix.
          CLEAR v_str.
          v_str = wa_rtab-text.
          IF v_str IS INITIAL.
            CONTINUE.
          ENDIF.
          CONDENSE v_str.
          IF v_str(1) EQ ca_starpp OR v_str(1) EQ ca_astpp.
            APPEND wa_rtab TO lt_code.
          ELSE.

            CLEAR: v_str, v_str1.
            SPLIT wa_rtab-text AT ca_astpp  INTO v_str v_str1.
            TRANSLATE wa_rtab-text TO UPPER CASE.
            TRANSLATE v_str TO UPPER CASE.

************
            IF v_str CS '%_HINTS'.
              lv_flag_no_append = 'X'.
              SPLIT v_str AT '%_HINTS'  INTO v_str v_str1.
              v_strf = v_str.
              CLEAR: v_str,
                     v_str1.
              v_str = wa_rtab-text.
              TRANSLATE v_str TO UPPER CASE.
              wa_rtab-text = v_strf.
*              APPEND wa_rtab TO lt_code.

            ENDIF.
******************
            IF NOT v_str1 IS INITIAL.
              FIND FIRST OCCURRENCE OF ca_astpp IN wa_rtab-text MATCH OFFSET
              lv_idx.
              lv_idx = lv_idx + 1.
              wa_rtab-text+lv_idx = v_str1.
            ELSE.
              wa_rtab-text = v_str.
            ENDIF.

            SHIFT v_str LEFT DELETING LEADING space.
            CHECK NOT v_str IS INITIAL.
            IF v_str CS ca_dotpp.
              SPLIT v_str AT ca_dotpp INTO v_str v_str1.
              CONCATENATE lv_code v_str INTO lv_code SEPARATED BY space.
              APPEND wa_rtab TO lt_code.
              EXIT.
            ELSE.
              CONCATENATE lv_code v_str INTO lv_code SEPARATED BY space.
              APPEND wa_rtab TO lt_code.
            ENDIF.
          ENDIF.
        ENDLOOP.

**Check for Error if its Real**
        CONDENSE lv_code.
        TRANSLATE lv_code TO UPPER CASE.
        IF NOT lv_code CS 'BYPASSING BUFFER'.
          CLEAR: wa_skipped_code.
          wa_skipped_code-name = wa_hana_check-obj_name.
          wa_skipped_code-old_line = wa_hana_check-line_no.
          wa_skipped_code-new_line = line.
          wa_skipped_code-opcode = wa_hana_check-opercd.
          wa_skipped_code-reason =
          'Code fix skipped as the code does not contain BYPASSING BUFFER'.
          APPEND wa_skipped_code TO gt_skipped_code.
          EXIT.
        ENDIF.
**End Check**

        IF lv_flag = ''.
          SPLIT lv_code AT space INTO TABLE rtab37.
          DELETE rtab37 WHERE text IS INITIAL.
          READ TABLE rtab37 WITH KEY text = 'BYPASSING' TRANSPORTING NO
          FIELDS.
          IF sy-subrc = 0.
            lv_index = sy-tabix + 1.
            DELETE rtab37 INDEX lv_index.
            DELETE rtab37 INDEX sy-tabix.
            DELETE rtab37 WHERE text IS INITIAL.
          ENDIF.

          LOOP AT lt_code ASSIGNING <fs_code>.
            lv_index = sy-tabix.
            CLEAR v_str.
            v_str = <fs_code>-text.
            CONDENSE v_str.
            IF v_str IS INITIAL.
              CONTINUE.
            ENDIF.
            IF v_str(1) EQ ca_starpp OR v_str(1) EQ ca_astpp.
              CONTINUE.
            ENDIF.
            IF <fs_code>-text CS 'BYPASSING BUFFER'.
              REPLACE FIRST OCCURRENCE OF 'BYPASSING BUFFER' IN
              <fs_code>-text WITH ''.
              IF <fs_code>-text IS INITIAL.
                DELETE lt_code INDEX lv_index.
              ENDIF.
              EXIT.
            ENDIF.
          ENDLOOP.

* INSERT comment_start_hana INTO ritab INDEX p_line.
*      p_line = p_line + 1.
*      v_line = v_line + 1.

          CLEAR rtab37[].

          rtab37[] = lt_code[].

          IF rtab37 IS NOT INITIAL.
            lv_opcode_37 = 'X'.

            wa_hana_check-actual_corr = 'Y'.
            IF wa_zauct_errors-opercd = wa_hana_check-opercd.
              wa_hana-actual_corr = 'Y'.
              wa_zauct_errors-actual_corr = 'Y'.
            ENDIF.
          ENDIF.

          CLEAR : lv_tlen , lv_len , lv_len1 , lv_tlen1.
*      APPEND comment_end_hana TO rtab1.
*      v_line = v_line + 1.
*      DESCRIBE TABLE rtab1 LINES lv_tlen.
*      INSERT LINES OF rtab1 INTO ritab INDEX v_line .

*      g_offset = g_offset + 1 + lv_tlen.
*          wa_hana_check-actual_corr = 'Y'.
*      wa_zauct_errors-actual_corr = 'Y'.
          g_corr_done = 'X'.
          CLEAR : lv_tlen.
          CLEAR: wa_correction_results.
          wa_correction_results-obj_name = wa_hana_check-obj_name.
          wa_correction_results-sub_program = wa_hana_check-sub_program.
          wa_correction_results-line_org = wa_hana_check-line_no.
          wa_correction_results-line_no = v_line.
          wa_correction_results-opcode = wa_hana_check-opercd.
          APPEND wa_correction_results TO gt_correction_results.
        ENDIF.

        READ TABLE i_zauct_errors ASSIGNING <fs_auct_err> WITH KEY
              session_id = wa_zauct_errors-session_id
              obj_name = wa_zauct_errors-obj_name
              sub_program = wa_zauct_errors-sub_program
              opercd = 37
              line_no = wa_zauct_errors-line_no
              runn = ''.
        IF sy-subrc = 0.
          <fs_auct_err>-runn = 'X'.
          <fs_auct_err>-actual_corr = wa_hana_check-actual_corr.
*        <fs_auct_err>-new_line =  lv_newline.
          MODIFY i_zauct_errors FROM <fs_auct_err> INDEX lv_indx.
        ENDIF.

      ENDIF.

      MODIFY it_hana FROM wa_hana_check
                                                TRANSPORTING runn actual_corr.
*
* MODIFY i_zauct_errors FROM wa_zauct_errors
*                                                TRANSPORTING runn actual_corr.

      CLEAR wa_hana_check.
    ENDLOOP.

    IF lv_opcode_13 IS INITIAL AND lv_opcode_16 IS INITIAL AND lv_opcode_37 IS INITIAL .
      lv_flag_comment = 'X'.
    ENDIF.

    IF lv_flag_comment IS INITIAL.

      IF  lv_flag2_start = 'X' AND lv_opcode_13 IS INITIAL  AND lv_opcode_37 IS INITIAL .
        lv_comment = 'X'.
        p_line = line + lv_sort.
      ENDIF.

      IF lv_comment IS INITIAL.
        LOOP AT rtab INTO wa_rtab FROM p_line TO v_line.
          lv_ccount = lv_ccount + 1.
          CONCATENATE '*'  wa_rtab-text INTO wa_rtab-text.
          MODIFY rtab FROM wa_rtab.
        ENDLOOP.
      ENDIF.
      INSERT comment_start INTO rtab INDEX p_line.   "common
      p_line = p_line + 1.                                 "common
      v_line = v_line + 1.
    ENDIF.

    "common



    IF lv_opcode_13 IS NOT INITIAL AND lv_opcode_16 IS INITIAL AND lv_opcode_37 IS INITIAL .
      lv_v_line = p_line.
      DESCRIBE TABLE rtab13 LINES lv_tlen. "13 specific

      lv_v_line = lv_v_line + lv_ccount.
      INSERT LINES OF rtab13 INTO rtab INDEX lv_v_line. "13specific
      g_offset = g_offset + 2 + lv_tlen.
      lv_v_line = lv_v_line + lv_tlen.
*         wa_hana_auct-actual_corr = 'Y'.

    ENDIF.

    IF lv_opcode_16 IS NOT INITIAL AND lv_opcode_13 IS INITIAL AND lv_opcode_37 IS INITIAL .

      lv_v_line = p_line.
      DESCRIBE TABLE rtab1 LINES lv_tlen. "13 specific
      lv_v_line = lv_v_line + lv_ccount.
      INSERT LINES OF rtab1 INTO rtab INDEX lv_v_line. "13specific
      g_offset = g_offset + 2 + lv_tlen.
      lv_v_line = lv_v_line + lv_tlen.
*         wa_hana_auct-actual_corr = 'Y'.

    ENDIF.

    IF lv_opcode_37 IS NOT INITIAL AND lv_opcode_13 IS INITIAL AND lv_opcode_16 IS INITIAL .
      lv_v_line = p_line.
      DESCRIBE TABLE rtab37 LINES lv_tlen. "13 specific

      lv_v_line = lv_v_line + lv_ccount.
      INSERT LINES OF rtab37 INTO rtab INDEX lv_v_line. "13specific
      g_offset = g_offset + 2 + lv_tlen.
      lv_v_line = lv_v_line + lv_tlen.
*         wa_hana_auct-actual_corr = 'Y'.
    ENDIF.

    IF lv_opcode_13 IS NOT INITIAL AND lv_opcode_16 IS INITIAL AND lv_opcode_37 IS NOT INITIAL .
      lv_v_line = p_line.
      REFRESH lt_code.
      CLEAR lv_code.
      LOOP AT rtab13 INTO wa_rtab.

*          v_line = sy-tabix.
        CLEAR v_str.
        v_str = wa_rtab-text.
        IF v_str IS INITIAL.
          CONTINUE.
        ENDIF.
        CONDENSE v_str.
        IF v_str(1) EQ ca_starpp OR v_str(1) EQ ca_astpp.
          APPEND wa_rtab TO lt_code.
        ELSE.

          CLEAR: v_str, v_str1.
          SPLIT wa_rtab-text AT ca_astpp  INTO v_str v_str1.
          TRANSLATE wa_rtab-text TO UPPER CASE.
          TRANSLATE v_str TO UPPER CASE.
          IF NOT v_str1 IS INITIAL.
            FIND FIRST OCCURRENCE OF ca_astpp IN wa_rtab-text MATCH OFFSET
            lv_idx.
            lv_idx = lv_idx + 1.
            wa_rtab-text+lv_idx = v_str1.
          ELSE.
            wa_rtab-text = v_str.
          ENDIF.

          SHIFT v_str LEFT DELETING LEADING space.
          CHECK NOT v_str IS INITIAL.
          IF v_str CS ca_dotpp.
            SPLIT v_str AT ca_dotpp INTO v_str v_str1.
            CONCATENATE lv_code v_str INTO lv_code SEPARATED BY space.
            APPEND wa_rtab TO lt_code.
            EXIT.
          ELSE.
            CONCATENATE lv_code v_str INTO lv_code SEPARATED BY space.
            APPEND wa_rtab TO lt_code.
          ENDIF.
        ENDIF.
      ENDLOOP.

**Check for Error if its Real**
      CONDENSE lv_code.
      TRANSLATE lv_code TO UPPER CASE.
      IF NOT lv_code CS 'BYPASSING BUFFER'.
        CLEAR: wa_skipped_code.
        wa_skipped_code-name = wa_zauct_errors-obj_name.
        wa_skipped_code-old_line = wa_zauct_errors-line_no.
        wa_skipped_code-new_line = line.
        wa_skipped_code-opcode = wa_zauct_errors-opercd.
        wa_skipped_code-reason =
        'Code fix skipped as the code does not contain BYPASSING BUFFER'.
        APPEND wa_skipped_code TO gt_skipped_code.
        EXIT.
      ENDIF.
**End Check**

      IF lv_flag = ''.
        SPLIT lv_code AT space INTO TABLE rtab2.
        DELETE rtab2 WHERE text IS INITIAL.
        READ TABLE rtab2 WITH KEY text = 'BYPASSING' TRANSPORTING NO
        FIELDS.
        IF sy-subrc = 0.
          lv_index = sy-tabix + 1.
          DELETE rtab2 INDEX lv_index.
          DELETE rtab2 INDEX sy-tabix.
          DELETE rtab2 WHERE text IS INITIAL.
        ENDIF.

        LOOP AT lt_code ASSIGNING <fs_code>.
          lv_index = sy-tabix.
          CLEAR v_str.
          v_str = <fs_code>-text.
          CONDENSE v_str.
          IF v_str IS INITIAL.
            CONTINUE.
          ENDIF.
          IF v_str(1) EQ ca_starpp OR v_str(1) EQ ca_astpp.
            CONTINUE.
          ENDIF.
          IF <fs_code>-text CS 'BYPASSING BUFFER'.
            REPLACE FIRST OCCURRENCE OF 'BYPASSING BUFFER' IN
            <fs_code>-text WITH ''.
            IF <fs_code>-text IS INITIAL.
              DELETE lt_code INDEX lv_index.
            ENDIF.
            EXIT.
          ENDIF.
        ENDLOOP.

* INSERT comment_start_hana INTO ritab INDEX p_line.
*      p_line = p_line + 1.
*      v_line = v_line + 1.

        rtab37[] = lt_code[].


        CLEAR : lv_tlen , lv_len , lv_len1 , lv_tlen1.
*      APPEND comment_end_hana TO rtab1.
*      v_line = v_line + 1.
*      DESCRIBE TABLE rtab1 LINES lv_tlen.
*      INSERT LINES OF rtab1 INTO ritab INDEX v_line .

*      g_offset = g_offset + 1 + lv_tlen.
*          wa_hana_auct-actual_corr = 'Y'.
*      wa_zauct_errors-actual_corr = 'Y'.
        g_corr_done = 'X'.
        CLEAR : lv_tlen.
        DESCRIBE TABLE rtab37 LINES lv_tlen. "13 specific

        lv_v_line = lv_v_line + lv_ccount.
        INSERT LINES OF rtab37 INTO rtab INDEX lv_v_line. "13specific
        g_offset = g_offset + 2 + lv_tlen.
        lv_v_line = lv_v_line + lv_tlen.

      ENDIF.



    ENDIF.

    IF lv_opcode_13 IS NOT INITIAL AND lv_opcode_16 IS NOT INITIAL AND lv_opcode_37 IS INITIAL .
      REFRESH: lt_code.

      lv_v_line = p_line.
      CLEAR: lv_flag_no_append.

      IF lv_flag2_start IS INITIAL.
        LOOP AT rtab1 INTO wa_rtab.

          v_line = sy-tabix.
          CLEAR v_str.
          v_str = wa_rtab-text.
          IF v_str IS INITIAL.
            CONTINUE.
"$$
"$$
"$$
"$$
"$$
          ENDIF.
          CONDENSE v_str.
          IF v_str(1) EQ ca_starpp OR v_str(1) EQ ca_astpp.
            IF lv_flag_no_append IS INITIAL.
              APPEND wa_rtab TO lt_code.
            ENDIF.
          ELSE.
"$$
"$$

            CLEAR: v_str, v_str1.
            IF lv_flag_no_append IS INITIAL.
              SPLIT wa_rtab-text AT ca_astpp  INTO v_str v_str1.
            ELSE.
              v_str = wa_rtab-text.
            ENDIF.
"$$
"$$
"$$
"$$

            TRANSLATE v_str TO UPPER CASE.
            IF v_str CS '%_HINTS'.
              lv_flag_no_append = 'X'.
              SPLIT v_str AT '%_HINTS'  INTO v_str v_str1.
              v_strf = v_str.
              CLEAR: v_str,
                     v_str1.
              v_str = wa_rtab-text.
              TRANSLATE v_str TO UPPER CASE.
              wa_rtab-text = v_strf.

            ENDIF.

            IF v_str CS 'ORDER BY'.
              v_app = v_str.
            ELSEIF v_str CS 'SORT'.
              v_app1 = v_str.
            ENDIF.
            TRANSLATE wa_rtab-text TO UPPER CASE.

            IF NOT v_str1 IS INITIAL.
              FIND FIRST OCCURRENCE OF ca_astpp IN wa_rtab-text MATCH OFFSET
              lv_idx.
              lv_idx = lv_idx + 1.
              wa_rtab-text+lv_idx = v_str1.
            ELSE.
              wa_rtab-text = v_str.
            ENDIF.

            SHIFT v_str LEFT DELETING LEADING space.
            CHECK NOT v_str IS INITIAL.
            IF v_str CS ca_dotpp.
              SPLIT v_str AT ca_dotpp INTO v_str v_str1.
              CONCATENATE lv_code v_str INTO lv_code SEPARATED BY space.
              IF lv_flag_no_append IS INITIAL.
                APPEND wa_rtab TO lt_code.
              ENDIF.
              EXIT.
            ELSE.
              CONCATENATE lv_code v_str INTO lv_code SEPARATED BY space.
              IF lv_flag_no_append IS INITIAL.
                APPEND wa_rtab TO lt_code.
              ENDIF.
            ENDIF.
          ENDIF.
        ENDLOOP.
        IF v_app IS NOT INITIAL.
          APPEND v_app TO lt_code.
        ELSEIF v_app1 IS NOT INITIAL.
          DESCRIBE TABLE lt_code LINES lv_appl.
          READ TABLE lt_code INTO wa_rtab INDEX lv_appl.
          CONCATENATE wa_rtab '.' INTO wa_rtab SEPARATED BY space.
          DELETE lt_code INDEX lv_appl.
          INSERT wa_rtab INTO lt_code INDEX lv_appl.
          APPEND v_app1 TO lt_code.
        ENDIF.
** Check if error is real**
        CONDENSE lv_code.
        TRANSLATE lv_code TO UPPER CASE.
        IF NOT lv_code CS '%_HINTS'.
          CLEAR: wa_skipped_code.
          wa_skipped_code-name = wa_hana_check-obj_name.
          wa_skipped_code-old_line = wa_hana_check-line_no.
          wa_skipped_code-new_line = line.
          wa_skipped_code-opcode = wa_hana_check-opercd.
          wa_skipped_code-reason =
          'Code fix skipped as the code does not contain %_HINTS'.
          APPEND wa_skipped_code TO gt_skipped_code.
          EXIT.
        ENDIF.


** End Check **

        IF lv_flag = ''.
*      INSERT comment_start_hana INTO ritab INDEX p_line.   "common
*      p_line = p_line + 1.                                 "common
*      v_line = v_line + 1.                                 "common
*          lv_flag_comment = 'X'.
*          LOOP AT ritab INTO wa_rtab FROM p_line TO v_line.
*            lv_ccount = lv_ccount + 1.
*            CONCATENATE '*'  wa_rtab-text INTO wa_rtab-text.
*            MODIFY ritab FROM wa_rtab.
*          ENDLOOP.
          CLEAR rtab13[].

          rtab13[] = lt_code[].
        ENDIF.

      ELSE.
        DESCRIBE TABLE rtab13 LINES lv_sort1.
        LOOP AT rtab1 INTO wa_rtab.
          APPEND wa_rtab TO rtab13 .
        ENDLOOP.
      ENDIF.
      CLEAR : lv_tlen , lv_len , lv_len1 , lv_tlen1.
      CLEAR : lv_tlen.


      DESCRIBE TABLE rtab13 LINES lv_tlen. "13 specific

      lv_v_line = lv_v_line + lv_ccount.
      INSERT LINES OF rtab13 INTO rtab INDEX lv_v_line. "13specific
      g_offset = g_offset + 2 + lv_tlen.
      lv_v_line = lv_v_line + lv_tlen.

    ENDIF.

    IF lv_opcode_13 IS INITIAL AND lv_opcode_16 IS NOT INITIAL AND lv_opcode_37 IS NOT INITIAL .
      REFRESH: lt_code.

      lv_v_line = p_line.

      IF lv_flag2_start IS INITIAL.
        LOOP AT rtab1 INTO wa_rtab.

*          v_line = sy-tabix.
          CLEAR v_str.
          v_str = wa_rtab-text.
          IF v_str IS INITIAL.
            CONTINUE.
          ENDIF.
          CONDENSE v_str.
          IF v_str(1) EQ ca_starpp OR v_str(1) EQ ca_astpp.
            APPEND wa_rtab TO lt_code.
          ELSE.

            CLEAR: v_str, v_str1.
            SPLIT wa_rtab-text AT ca_astpp  INTO v_str v_str1.
            TRANSLATE wa_rtab-text TO UPPER CASE.
            TRANSLATE v_str TO UPPER CASE.
            IF NOT v_str1 IS INITIAL.
              FIND FIRST OCCURRENCE OF ca_astpp IN wa_rtab-text MATCH OFFSET
              lv_idx.
              lv_idx = lv_idx + 1.
              wa_rtab-text+lv_idx = v_str1.
            ELSE.
              wa_rtab-text = v_str.
            ENDIF.

            SHIFT v_str LEFT DELETING LEADING space.
            CHECK NOT v_str IS INITIAL.
            IF v_str CS ca_dotpp.
              SPLIT v_str AT ca_dotpp INTO v_str v_str1.
              CONCATENATE lv_code v_str INTO lv_code SEPARATED BY space.
              APPEND wa_rtab TO lt_code.
              EXIT.
            ELSE.
              CONCATENATE lv_code v_str INTO lv_code SEPARATED BY space.
              APPEND wa_rtab TO lt_code.
            ENDIF.
          ENDIF.
        ENDLOOP.

**Check for Error if its Real**
        CONDENSE lv_code.
        TRANSLATE lv_code TO UPPER CASE.
        IF NOT lv_code CS 'BYPASSING BUFFER'.
          CLEAR: wa_skipped_code.
          wa_skipped_code-name = wa_zauct_errors-obj_name.
          wa_skipped_code-old_line = wa_zauct_errors-line_no.
          wa_skipped_code-new_line = line.
          wa_skipped_code-opcode = wa_zauct_errors-opercd.
          wa_skipped_code-reason =
          'Code fix skipped as the code does not contain BYPASSING BUFFER'.
          APPEND wa_skipped_code TO gt_skipped_code.
          EXIT.
        ENDIF.
**End Check**
*
        IF lv_flag = ''.
          SPLIT lv_code AT space INTO TABLE rtab2.
          DELETE rtab2 WHERE text IS INITIAL.
          READ TABLE rtab2 WITH KEY text = 'BYPASSING' TRANSPORTING NO
          FIELDS.
          IF sy-subrc = 0.
            lv_index = sy-tabix + 1.
            DELETE rtab2 INDEX lv_index.
            DELETE rtab2 INDEX sy-tabix.
            DELETE rtab2 WHERE text IS INITIAL.
          ENDIF.

          LOOP AT lt_code ASSIGNING <fs_code>.
            lv_index = sy-tabix.
            CLEAR v_str.
            v_str = <fs_code>-text.
            CONDENSE v_str.
            IF v_str IS INITIAL.
              CONTINUE.
            ENDIF.
            IF v_str(1) EQ ca_starpp OR v_str(1) EQ ca_astpp.
              CONTINUE.
            ENDIF.
            IF <fs_code>-text CS 'BYPASSING BUFFER'.
              REPLACE FIRST OCCURRENCE OF 'BYPASSING BUFFER' IN
              <fs_code>-text WITH ''.
              IF <fs_code>-text IS INITIAL.
                DELETE lt_code INDEX lv_index.
              ENDIF.
              EXIT.
            ENDIF.
          ENDLOOP.
          rtab37[] = lt_code[].

        ENDIF.


      ELSE.

        DESCRIBE TABLE rtab37 LINES lv_sort1.
        LOOP AT rtab1 INTO wa_rtab.
          APPEND wa_rtab TO rtab37 .
        ENDLOOP.
      ENDIF.
      CLEAR : lv_tlen , lv_len , lv_len1 , lv_tlen1.
*      APPEND comment_end_hana TO rtab1.
*      v_line = v_line + 1.
*      DESCRIBE TABLE rtab1 LINES lv_tlen.
*      INSERT LINES OF rtab1 INTO ritab INDEX v_line .

*      g_offset = g_offset + 1 + lv_tlen.
*          wa_hana_auct-actual_corr = 'Y'.
*      wa_zauct_errors-actual_corr = 'Y'.
      g_corr_done = 'X'.
      CLEAR : lv_tlen.
      DESCRIBE TABLE rtab37 LINES lv_tlen. "13 specific

      lv_v_line = lv_v_line + lv_ccount.
      INSERT LINES OF rtab37 INTO rtab INDEX lv_v_line. "13specific
      g_offset = g_offset + 2 + lv_tlen.
      lv_v_line = lv_v_line + lv_tlen.

    ENDIF.

    IF lv_opcode_13 IS NOT INITIAL AND lv_opcode_16 IS NOT INITIAL AND lv_opcode_37 IS NOT INITIAL .
      REFRESH: lt_code.
      lv_v_line = p_line.
      CLEAR lv_code.

      IF lv_flag2_start IS INITIAL.
        LOOP AT rtab1 INTO wa_rtab.

*          v_line = sy-tabix.
          CLEAR v_str.
          v_str = wa_rtab-text.
          IF v_str IS INITIAL.
            CONTINUE.
          ENDIF.
          CONDENSE v_str.
          IF v_str(1) EQ ca_starpp OR v_str(1) EQ ca_astpp.
            APPEND wa_rtab TO lt_code.
          ELSE.

            CLEAR: v_str, v_str1.
            SPLIT wa_rtab-text AT ca_astpp  INTO v_str v_str1.
            TRANSLATE wa_rtab-text TO UPPER CASE.
            TRANSLATE v_str TO UPPER CASE.
            IF NOT v_str1 IS INITIAL.
              FIND FIRST OCCURRENCE OF ca_astpp IN wa_rtab-text MATCH OFFSET
              lv_idx.
              lv_idx = lv_idx + 1.
              wa_rtab-text+lv_idx = v_str1.
            ELSE.
              wa_rtab-text = v_str.
            ENDIF.

            SHIFT v_str LEFT DELETING LEADING space.
            CHECK NOT v_str IS INITIAL.
            IF v_str CS ca_dotpp.
              SPLIT v_str AT ca_dotpp INTO v_str v_str1.
              CONCATENATE lv_code v_str INTO lv_code SEPARATED BY space.
              APPEND wa_rtab TO lt_code.
              EXIT.
            ELSE.
              CONCATENATE lv_code v_str INTO lv_code SEPARATED BY space.
              APPEND wa_rtab TO lt_code.
            ENDIF.
          ENDIF.
        ENDLOOP.

**Check for Error if its Real**

        CONDENSE lv_code.
        TRANSLATE lv_code TO UPPER CASE.
        IF NOT lv_code CS 'BYPASSING BUFFER'.
          CLEAR: wa_skipped_code.
          wa_skipped_code-name = wa_zauct_errors-obj_name.
          wa_skipped_code-old_line = wa_zauct_errors-line_no.
          wa_skipped_code-new_line = line.
          wa_skipped_code-opcode = wa_zauct_errors-opercd.
          wa_skipped_code-reason =
          'Code fix skipped as the code does not contain BYPASSING BUFFER'.
          APPEND wa_skipped_code TO gt_skipped_code.
          EXIT.
        ENDIF.
**End Check**

        IF lv_flag = ''.
          SPLIT lv_code AT space INTO TABLE  rtab2.
          DELETE rtab2 WHERE text IS INITIAL.
          READ TABLE rtab2 WITH KEY text = 'BYPASSING' TRANSPORTING NO
          FIELDS.
          IF sy-subrc = 0.
            lv_index = sy-tabix + 1.
            DELETE rtab2 INDEX lv_index.
            DELETE rtab2 INDEX sy-tabix.
            DELETE rtab2 WHERE text IS INITIAL.
          ENDIF.

          LOOP AT lt_code ASSIGNING <fs_code>.
            lv_index = sy-tabix.
            CLEAR v_str.
            v_str = <fs_code>-text.
            CONDENSE v_str.
            IF v_str IS INITIAL.
              CONTINUE.
            ENDIF.
            IF v_str(1) EQ ca_starpp OR v_str(1) EQ ca_astpp.
              CONTINUE.
            ENDIF.
            IF <fs_code>-text CS 'BYPASSING BUFFER'.
              REPLACE FIRST OCCURRENCE OF 'BYPASSING BUFFER' IN
              <fs_code>-text WITH ''.
              IF <fs_code>-text IS INITIAL.
                DELETE lt_code INDEX lv_index.
              ENDIF.
              EXIT.
            ENDIF.
          ENDLOOP.
          rtab37[] = lt_code[].
        ENDIF.
      ELSE.
        LOOP AT rtab37 INTO wa_rtab.
          IF wa_rtab CS ca_dotpp.
            REPLACE FIRST OCCURRENCE OF '.' IN wa_rtab WITH ' '.
          ENDIF.
          APPEND wa_rtab TO rtab3_7.
          CLEAR wa_rtab.
        ENDLOOP.
        REFRESH rtab37.
        rtab37[] = rtab3_7[].
        DESCRIBE TABLE rtab37 LINES lv_sort1.
        LOOP AT rtab1 INTO wa_rtab.
          APPEND wa_rtab TO rtab37 .
        ENDLOOP.
      ENDIF.
      CLEAR: lv_flag_no_append.

      REFRESH lt_code.
      CLEAR lv_code.
      LOOP AT rtab37 INTO wa_rtab.

*          v_line = sy-tabix.
        CLEAR v_str.
        v_str = wa_rtab-text.
        IF v_str IS INITIAL.
          CONTINUE.
        ENDIF.
        CONDENSE v_str.
        IF v_str(1) EQ ca_starpp OR v_str(1) EQ ca_astpp.
          IF lv_flag_no_append IS INITIAL.
            APPEND wa_rtab TO lt_code.
          ENDIF.
        ELSE.

          CLEAR: v_str, v_str1.
          IF lv_flag_no_append IS INITIAL.
            SPLIT wa_rtab-text AT ca_astpp  INTO v_str v_str1.
          ELSE.
            v_str = wa_rtab-text.
          ENDIF.

          TRANSLATE v_str TO UPPER CASE.
          IF v_str CS '%_HINTS'.
            lv_flag_no_append = 'X'.
            SPLIT v_str AT '%_HINTS'  INTO v_str v_str1.
            v_strf = v_str.
            CLEAR: v_str,
                   v_str1.
            v_str = wa_rtab-text.
            TRANSLATE v_str TO UPPER CASE.
            wa_rtab-text = v_strf.
*              APPEND wa_rtab TO lt_code.

          ENDIF.

          IF v_str CS 'ORDER BY'.
            v_app = v_str.
          ELSEIF v_str CS 'SORT'.
            v_app1 = v_str.
          ENDIF.

          TRANSLATE wa_rtab-text TO UPPER CASE.

          IF NOT v_str1 IS INITIAL.
            FIND FIRST OCCURRENCE OF ca_astpp IN wa_rtab-text MATCH OFFSET
            lv_idx.
            lv_idx = lv_idx + 1.
            wa_rtab-text+lv_idx = v_str1.
          ELSE.
            wa_rtab-text = v_str.
          ENDIF.

          SHIFT v_str LEFT DELETING LEADING space.
          CHECK NOT v_str IS INITIAL.
          IF v_str CS ca_dotpp.
            SPLIT v_str AT ca_dotpp INTO v_str v_str1.
            CONCATENATE lv_code v_str INTO lv_code SEPARATED BY space.
            IF lv_flag_no_append IS INITIAL.
              APPEND wa_rtab TO lt_code.
            ENDIF.
            EXIT.
          ELSE.
            CONCATENATE lv_code v_str INTO lv_code SEPARATED BY space.
            IF lv_flag_no_append IS INITIAL.
              APPEND wa_rtab TO lt_code.
            ENDIF.
          ENDIF.
        ENDIF.
      ENDLOOP.
      IF v_app IS NOT INITIAL.
        APPEND v_app TO lt_code.
      ELSEIF v_app1 IS NOT INITIAL.
        DESCRIBE TABLE lt_code LINES lv_appl.
        READ TABLE lt_code INTO wa_rtab INDEX lv_appl.
        CONCATENATE wa_rtab '.' INTO wa_rtab SEPARATED BY space.
        DELETE lt_code INDEX lv_appl.
        INSERT wa_rtab INTO lt_code INDEX lv_appl.
        APPEND v_app1 TO lt_code.
      ENDIF.
** Check if error is real**
      CONDENSE lv_code.
      TRANSLATE lv_code TO UPPER CASE.
      IF NOT lv_code CS '%_HINTS'.
        CLEAR: wa_skipped_code.
        wa_skipped_code-name = wa_zauct_errors-obj_name.
        wa_skipped_code-old_line = wa_zauct_errors-line_no.
        wa_skipped_code-new_line = line.
        wa_skipped_code-opcode = wa_zauct_errors-opercd.
        wa_skipped_code-reason =
        'Code fix skipped as the code does not contain %_HINTS'.
        APPEND wa_skipped_code TO gt_skipped_code.
        EXIT.
      ENDIF.


** End Check **

      CLEAR rtab13[].

      rtab13[] = lt_code[].



      CLEAR : lv_tlen , lv_len , lv_len1 , lv_tlen1.

*          wa_hana_auct-actual_corr = 'Y'.
*      wa_zauct_errors-actual_corr = 'Y'.
      CLEAR : lv_tlen.

      DESCRIBE TABLE rtab13 LINES lv_tlen. "13 specific

      lv_v_line = lv_v_line + lv_ccount.
      INSERT LINES OF rtab13 INTO rtab INDEX lv_v_line. "13specific
      g_offset = g_offset + 2 + lv_tlen.
      lv_v_line = lv_v_line + lv_tlen.



    ENDIF.


    IF lv_flag_comment IS INITIAL.
      INSERT comment_end INTO rtab INDEX lv_v_line.   "common
      lv_v_line = lv_v_line + 1.               "common
    ENDIF.


    READ TABLE it_hana INTO wa_hana_41 WITH KEY
  session_id = wa_zauct_errors-session_id
        obj_name = wa_zauct_errors-obj_name
        sub_program = wa_zauct_errors-sub_program
        opercd = 41
        line_no = wa_zauct_errors-line_no
        runn = ''.

    IF sy-subrc = 0 .
      IF lv_opcode_13 IS INITIAL AND lv_opcode_16 IS INITIAL AND lv_opcode_37 IS INITIAL .
        p_line = line.
        wa_hana_41-runn = 'X'.
        wa_hana-runn = 'X'.
        wa_zauct_errors-runn = 'X'.
        REFRESH: lt_code.

        LOOP AT rtab INTO wa_rtab FROM p_line.

          v_line = sy-tabix.
          CLEAR v_str.
          v_str = wa_rtab-text.
          IF v_str IS INITIAL.
            CONTINUE.
          ENDIF.
          CONDENSE v_str.
          IF v_str(1) EQ ca_starpp OR v_str(1) EQ ca_astpp.
            APPEND wa_rtab TO lt_code.
          ELSE.

            CLEAR: v_str, v_str1.
            SPLIT wa_rtab-text AT ca_astpp  INTO v_str v_str1.
            TRANSLATE wa_rtab-text TO UPPER CASE.
            TRANSLATE v_str TO UPPER CASE.
            IF NOT v_str1 IS INITIAL.
              FIND FIRST OCCURRENCE OF ca_astpp IN wa_rtab-text MATCH OFFSET
              lv_idx.
              lv_idx = lv_idx + 1.
              wa_rtab-text+lv_idx = v_str1.
            ELSE.
              wa_rtab-text = v_str.
            ENDIF.

            SHIFT v_str LEFT DELETING LEADING space.
            CHECK NOT v_str IS INITIAL.
            IF v_str CS ca_dotpp.
              SPLIT v_str AT ca_dotpp INTO v_str v_str1.
              CONCATENATE lv_code v_str INTO lv_code SEPARATED BY space.

              APPEND wa_rtab TO lt_code.
              EXIT.
            ELSE.
              CONCATENATE lv_code v_str INTO lv_code SEPARATED BY space.
              APPEND wa_rtab TO lt_code.
            ENDIF.
          ENDIF.
        ENDLOOP.


**Check for the Error if its Real**
        CONDENSE lv_code.
        TRANSLATE lv_code TO UPPER CASE.
        IF NOT ( lv_code CS 'SELECT' AND lv_code CS 'FOR ALL ENTRIES IN' ).
          CLEAR: wa_skipped_code.
          wa_skipped_code-name = wa_zauct_errors-obj_name.
          wa_skipped_code-old_line = wa_zauct_errors-line_no.
          wa_skipped_code-new_line = line.
          wa_skipped_code-opcode = wa_zauct_errors-opercd.
          wa_skipped_code-reason =
    'Code fix skipped as the code does not contain FOR ALL ENTRIES case'.
          APPEND wa_skipped_code TO gt_skipped_code.
          EXIT.
        ENDIF.
**End Check**

        IF lv_flag = ''.

          SPLIT lv_code AT space INTO TABLE rtab41.
          DELETE rtab41 WHERE text IS INITIAL.
          READ TABLE rtab41 WITH KEY text = 'ENTRIES' TRANSPORTING NO FIELDS.
          IF sy-subrc = 0.
            lv_index = sy-tabix + 2.
            CLEAR wa_rtab1.
            READ TABLE rtab41 INTO wa_rtab1 INDEX lv_index.
            CONDENSE wa_rtab1-text.
            IF wa_rtab1-text CS '[]'.
              CONCATENATE 'IF NOT' wa_rtab1-text 'IS INITIAL.' INTO
           lv_new SEPARATED BY space.
            ELSE.
              CONCATENATE wa_rtab1-text '[]' INTO wa_rtab1-text.
              CONCATENATE 'IF NOT' wa_rtab1-text 'IS INITIAL.' INTO
           lv_new SEPARATED BY space.
            ENDIF.
          ENDIF.


          IF ( lv_code CS 'INTO TABLE' OR lv_code CS
          'INTO CORRESPONDING FIELDS OF TABLE'
                  OR lv_code CS 'APPENDING TABLE' OR lv_code CS
                  'APPENDING CORRESPONDING FIELDS OF TABLE' ).

            INSERT comment_start INTO rtab INDEX p_line.
            p_line = p_line + 1.
            v_line = v_line + 1.
            INSERT lv_new INTO rtab INDEX p_line.
            p_line = p_line + 1.
            v_line = v_line + 1.
            INSERT comment_end INTO rtab INDEX p_line.
            p_line = p_line + 1.
            v_line = v_line + 1.

          ELSE.
            INSERT comment_start INTO rtab INDEX p_line.
            p_line = p_line + 1.
            v_line = v_line + 1.
            INSERT lv_new INTO rtab INDEX p_line.
            p_line = p_line + 1.
            v_line = v_line + 1.
            INSERT comment_end INTO rtab INDEX p_line.
            p_line = p_line + 1.
            v_line = v_line + 1.
*            CLEAR: wa_skipped_code.
*            wa_skipped_code-name = wa_zauct_errors-obj_name.
*            wa_skipped_code-old_line = wa_zauct_errors-line_no.
*            wa_skipped_code-new_line = line.
*            wa_skipped_code-opcode = wa_zauct_errors-opercd.
*            wa_skipped_code-reason =
*    'Code fix skipped as this case is FOR ALL ENTRIES with SELECT-ENDSELE' &
*    'CT. Please correct it manually'
*            .
*            APPEND wa_skipped_code TO gt_skipped_code.
*            EXIT.

          ENDIF.

          CLEAR rtab41[].
          APPEND comment_start TO rtab41.

          lv_new = 'ENDIF.'.
          APPEND lv_new TO rtab41.
          APPEND comment_end TO rtab41.
          v_line = v_line + 1.
          INSERT LINES OF rtab41 INTO rtab INDEX v_line .

          g_offset = g_offset + 6.
          wa_hana_41-actual_corr = 'Y'.
          wa_hana-actual_corr = 'Y'.
          wa_zauct_errors-actual_corr = 'Y'.
          g_corr_done = 'X'.
          lv_ccount = 0.

          CLEAR: wa_correction_results.
          wa_correction_results-obj_name = wa_hana_41-obj_name.
          wa_correction_results-sub_program = wa_hana_41-sub_program.
          wa_correction_results-line_org = wa_hana_41-line_no.
          wa_correction_results-line_no = v_line.
          wa_correction_results-opcode = wa_hana_41-opercd.
          APPEND wa_correction_results TO gt_correction_results.
        ENDIF.

      ELSE.

        p_line = line + lv_ccount + 1.
        wa_hana_41-runn = 'X'.
        REFRESH: lt_code.

        LOOP AT rtab INTO wa_rtab FROM p_line.

          v_line = sy-tabix.
          CLEAR v_str.
          v_str = wa_rtab-text.
          IF v_str IS INITIAL.
            CONTINUE.
          ENDIF.
          CONDENSE v_str.
          IF v_str(1) EQ ca_starpp OR v_str(1) EQ ca_astpp.
            APPEND wa_rtab TO lt_code.
          ELSE.

            CLEAR: v_str, v_str1.
            SPLIT wa_rtab-text AT ca_astpp  INTO v_str v_str1.
            TRANSLATE wa_rtab-text TO UPPER CASE.
            TRANSLATE v_str TO UPPER CASE.
            IF NOT v_str1 IS INITIAL.
              FIND FIRST OCCURRENCE OF ca_astpp IN wa_rtab-text MATCH OFFSET
              lv_idx.
              lv_idx = lv_idx + 1.
              wa_rtab-text+lv_idx = v_str1.
            ELSE.
              wa_rtab-text = v_str.
            ENDIF.

            SHIFT v_str LEFT DELETING LEADING space.
            CHECK NOT v_str IS INITIAL.
            IF v_str CS ca_dotpp.
              SPLIT v_str AT ca_dotpp INTO v_str v_str1.
              CONCATENATE lv_code v_str INTO lv_code SEPARATED BY space.

              APPEND wa_rtab TO lt_code.
              EXIT.
            ELSE.
              CONCATENATE lv_code v_str INTO lv_code SEPARATED BY space.
              APPEND wa_rtab TO lt_code.
            ENDIF.
          ENDIF.
        ENDLOOP.


**Check for the Error if its Real**
        CONDENSE lv_code.
        TRANSLATE lv_code TO UPPER CASE.
        IF NOT ( lv_code CS 'SELECT' AND lv_code CS 'FOR ALL ENTRIES IN' ).
          CLEAR: wa_skipped_code.
          wa_skipped_code-name = wa_zauct_errors-obj_name.
          wa_skipped_code-old_line = wa_zauct_errors-line_no.
          wa_skipped_code-new_line = line.
          wa_skipped_code-opcode = wa_zauct_errors-opercd.
          wa_skipped_code-reason =
    'Code fix skipped as the code does not contain FOR ALL ENTRIES case'.
          APPEND wa_skipped_code TO gt_skipped_code.
          EXIT.
        ENDIF.
**End Check**

        IF lv_flag = ''.

          SPLIT lv_code AT space INTO TABLE rtab41.
          DELETE rtab41 WHERE text IS INITIAL.
          READ TABLE rtab41 WITH KEY text = 'ENTRIES' TRANSPORTING NO FIELDS.
          IF sy-subrc = 0.
            lv_index = sy-tabix + 2.
            CLEAR wa_rtab1.
            READ TABLE rtab41 INTO wa_rtab1 INDEX lv_index.
            CONDENSE wa_rtab1-text.
            IF wa_rtab1-text CS '[]'.
              CONCATENATE 'IF NOT' wa_rtab1-text 'IS INITIAL.' INTO
           lv_new SEPARATED BY space.
            ELSE.
              CONCATENATE wa_rtab1-text '[]' INTO wa_rtab1-text.
              CONCATENATE 'IF NOT' wa_rtab1-text 'IS INITIAL.' INTO
           lv_new SEPARATED BY space.
            ENDIF.
          ENDIF.


          IF ( lv_code CS 'INTO TABLE' OR lv_code CS
          'INTO CORRESPONDING FIELDS OF TABLE'
                  OR lv_code CS 'APPENDING TABLE' OR lv_code CS
                  'APPENDING CORRESPONDING FIELDS OF TABLE' ).

            IF  lv_comment IS NOT INITIAL .

              p_line = line.
              v_line = lv_v_line - 1.
              INSERT comment_start INTO rtab INDEX p_line.
              p_line = p_line + 1.
              v_line = v_line + 1.
              INSERT lv_new INTO rtab INDEX p_line.
              p_line = p_line + 1.
              v_line = v_line + 1.
              INSERT comment_end INTO rtab INDEX p_line.
              p_line = p_line + 1.
              v_line = v_line + 1.
              g_offset = g_offset + 2.
            ELSE.
              INSERT lv_new INTO rtab INDEX p_line.
              p_line = p_line + 1.
              v_line = v_line + 1.
            ENDIF.

          ELSE.
            IF  lv_comment IS NOT INITIAL .

              p_line = line.
              v_line = lv_v_line - 1.
              INSERT comment_start INTO rtab INDEX p_line.
              p_line = p_line + 1.
              v_line = v_line + 1.
              INSERT lv_new INTO rtab INDEX p_line.
              p_line = p_line + 1.
              v_line = v_line + 1.
              INSERT comment_end INTO rtab INDEX p_line.
              p_line = p_line + 1.
              v_line = v_line + 1.
              g_offset = g_offset + 2.
            ELSE.
              INSERT lv_new INTO rtab INDEX p_line.
              p_line = p_line + 1.
              v_line = v_line + 1.
            ENDIF.
*            CLEAR: wa_skipped_code.
*            wa_skipped_code-name = wa_zauct_errors-obj_name.
*            wa_skipped_code-old_line = wa_zauct_errors-line_no.
*            wa_skipped_code-new_line = line.
*            wa_skipped_code-opcode = wa_zauct_errors-opercd.
*            wa_skipped_code-reason =
*    'Code fix skipped as this case is FOR ALL ENTRIES with SELECT-ENDSELE' &
*    'CT. Please correct it manually'
*            .
*            APPEND wa_skipped_code TO gt_skipped_code.
*            EXIT.

          ENDIF.

          CLEAR rtab41[].

          lv_new = 'ENDIF.'.
*          APPEND lv_new TO rtab41.
          IF  lv_comment IS NOT INITIAL .
            INSERT lv_new INTO rtab INDEX v_line.
            v_line = v_line + 1.
          ELSE.
            INSERT lv_new INTO rtab INDEX lv_v_line.
            lv_v_line = lv_v_line + 1.
*          INSERT LINES OF rtab41 INTO ritab INDEX v_line .
          ENDIF.
          g_offset = g_offset + 2.
          wa_hana_41-actual_corr = 'Y'.
          wa_zauct_errors-actual_corr = 'Y'.
          g_corr_done = 'X'.
          CLEAR: wa_correction_results.
          wa_correction_results-obj_name = wa_hana_41-obj_name.
          wa_correction_results-sub_program = wa_hana_41-sub_program.
          wa_correction_results-line_org = wa_hana_41-line_no.
          wa_correction_results-line_no = v_line.
          wa_correction_results-opcode = wa_hana_41-opercd.
          APPEND wa_correction_results TO gt_correction_results.
        ENDIF.


      ENDIF.
*  MODIFY it_hana_auct FROM wa_hana_41
*                                           TRANSPORTING runn actual_corr.
      gv_ccount = lv_ccount.


      READ TABLE i_zauct_errors ASSIGNING <fs_auct_err> WITH KEY
              session_id = wa_zauct_errors-session_id
              obj_name = wa_zauct_errors-obj_name
              sub_program = wa_zauct_errors-sub_program
              opercd = 41
              line_no = wa_zauct_errors-line_no
              runn = ''.
      IF sy-subrc = 0.
        <fs_auct_err>-runn = 'X'.
        <fs_auct_err>-actual_corr = 'Y'.
*        <fs_auct_err>-new_line =  lv_newline.
        MODIFY i_zauct_errors FROM <fs_auct_err> INDEX lv_indx.
      ENDIF.
    ENDIF.


    gv_ccount = lv_ccount.


  ENDMETHOD.                    "check_hana_opcode

***end of changes by Vrishti - 24/1/2017 : Def_2
  METHOD check_opcode16.

    DATA: v_line                TYPE i,
          v_str                 TYPE string,
          lv_code               TYPE string,
          lv_flag               TYPE c,
          lv_flag_close_comment TYPE c,
          lv_type_of_table      TYPE c,
          v_str2                TYPE string,
          v_str3                TYPE string.

    TYPES: BEGIN OF ty_rtab1,
             text(1000),
           END OF ty_rtab1.
    DATA: it_break TYPE TABLE OF ty_rtab1,
          p_line   TYPE i.

    DATA: rtab1              TYPE TABLE OF ty_rtab1,
          wa_rtab1           TYPE ty_rtab1,
          lt_code            TYPE TABLE OF ty_rtab1,
          wa_code            TYPE ty_rtab1,
          rtab41             TYPE TABLE OF ty_rtab1,
          wa_rtab41          TYPE ty_rtab1,
          wa_auct_err41      TYPE zauct_struct,
          lv_last_idx        TYPE i,
          lv_idx             TYPE i,
          lv_opcode41_offset TYPE i,
          lv_flag_opcode41   TYPE c,
          lv_new(1000)       TYPE c,
          lv_new_end(1000)   TYPE c,
          lv_index41         TYPE sy-tabix,
          lv_flag2_start     TYPE c.

    FIELD-SYMBOLS: <fs_code>     TYPE ty_rtab1,
                   <fs_auct_err> TYPE zauct_struct,
                   <fs_hana>     TYPE zdb_analysis_v74.

    DATA : wa_break LIKE LINE OF it_break,
           lv_len   TYPE i,
           lv_len1  TYPE i,
           lv_tlen  TYPE i,
           lv_tlen1 TYPE i.

    TYPES: BEGIN OF ty_code11,
             text(1000) TYPE c,
           END OF ty_code11.
    DATA:  lt_tab4   TYPE TABLE OF ty_code11.
    DATA: lwa_tab4 TYPE ty_code11.
    DATA: lv_pos1 TYPE sy-tabix.
    DATA: lv_pos2 TYPE sy-tabix.
    DATA: lv_flag1 TYPE flag.
    DATA: lv_flag2 TYPE flag.

    line = line + g_offset.
    READ TABLE it_hana INTO wa_hana WITH KEY
    session_id = wa_zauct_errors-session_id
    read_prog = wa_zauct_errors-pgname
    sub_program = wa_zauct_errors-sub_program
    opercd = wa_zauct_errors-error_type
    operation = wa_zauct_errors-error_message
    line_no = wa_zauct_errors-line_no.
    wa_hana-runn = 'X'.
    wa_zauct_errors-runn = 'X'.

    CLEAR : v_strc1 , v_keys , v_strc2,
            i_keys,wa_keys.
    REFRESH : i_keys[].
    v_keys = wa_zauct_errors-repcfm.
    SPLIT v_keys AT '|' INTO TABLE i_keys.
    LOOP AT i_keys INTO wa_keys.
      IF wa_keys CS '~'.
        SPLIT wa_keys-line AT '~' INTO v_strc1 v_keys.
        wa_keys = v_keys.
        MODIFY i_keys FROM wa_keys.
      ELSEIF wa_keys CS '-'.
        SPLIT wa_keys-line AT '-' INTO v_strc1 v_strc2.
        wa_keys = v_strc2.
        MODIFY i_keys FROM wa_keys.
      ELSE.
        CONTINUE.
      ENDIF.
      CLEAR : v_strc1 , v_keys , v_strc2,
              wa_keys.
    ENDLOOP.
    DELETE ADJACENT DUPLICATES FROM i_keys.
    DELETE i_keys WHERE line = space.
    DELETE i_keys WHERE line = 'MANDT'.
    CLEAR v_keys.
    CONCATENATE LINES OF i_keys INTO v_keys SEPARATED BY space.
    IF NOT v_keys IS INITIAL.
****Start of change for select fields for all entries issue
      CLEAR: v_fae,
             v_fae_m.
      CLEAR: v_keys1,
             v_keys2,
             v_keys3.
      IF wa_hana-code CS 'SELECT' AND wa_hana-code CS 'FOR ALL ENTRIES'.
        IF wa_hana-code CS 'SELECT *'.
          CLEAR v_keys2.
          v_fae = 'X'.
***Begin of change by Vrishti, 12/2/2016
        ELSEIF wa_hana-fields = ''.
          CLEAR: wa_skipped_code.
          wa_skipped_code-name = wa_zauct_errors-pgname.
          wa_skipped_code-old_line = wa_zauct_errors-line_no.
          wa_skipped_code-new_line = line.
          wa_skipped_code-opcode = wa_zauct_errors-error_type.
          wa_skipped_code-reason = ' Manual Intervention Required '.
          APPEND wa_skipped_code TO gt_skipped_code.
          EXIT.

***End of change by Vrishti, 12/2/2016
        ELSE.
          v_keys1 = wa_hana-fields.
          FIELD-SYMBOLS: <fs_keys1> TYPE ty_code.

          SPLIT v_keys1 AT '|' INTO TABLE i_keys1.
          LOOP AT i_keys1 INTO wa_keys1.
            IF wa_keys1 CS '~'.
              SPLIT wa_keys1-line AT '~' INTO v_strc1 v_keys1.
              wa_keys1 = v_keys1.
              MODIFY i_keys1 FROM wa_keys1.
            ELSEIF wa_keys1 CS '-'.
              SPLIT wa_keys1-line AT '-' INTO v_strc1 v_strc2.
              wa_keys1 = v_strc2.
              MODIFY i_keys1 FROM wa_keys1.
            ELSE.
              CONTINUE.
            ENDIF.
            CLEAR : v_strc1 , v_keys1 , v_strc2,
                   wa_keys1.
          ENDLOOP.
          DELETE ADJACENT DUPLICATES FROM i_keys1.
          DELETE i_keys1 WHERE line = space.
          CLEAR v_keys1.
          CONCATENATE LINES OF i_keys1 INTO v_keys1 SEPARATED BY space.
          LOOP AT i_keys
            ASSIGNING <fs_keys1>.
            READ TABLE i_keys1
              TRANSPORTING NO FIELDS
              WITH KEY line = <fs_keys1>-line.
            IF sy-subrc EQ 0.
              "/ do-nothing
              CONCATENATE v_keys2 <fs_keys1>-line INTO v_keys2 SEPARATED
              BY space.
            ELSE.
              CLEAR v_fae_m.
              v_fae_m = 'X'.
            ENDIF.
          ENDLOOP.
          IF v_fae_m IS INITIAL. " for all matched keys
            CLEAR v_keys2.
            v_fae = 'X'.
          ENDIF.
          IF NOT v_keys2 IS INITIAL.
            CONDENSE v_keys2.
            CONCATENATE 'SORT' wa_hana-itab 'BY' v_keys2 '.' INTO
            v_keys2 SEPARATED BY space.
          ENDIF.
        ENDIF.
*****Begin of change by Vrishti, 15/2/2016
        "Changes Made for select<dyanmic field> issue
*{ Begin of change by Twara - 12/02/2016
*      ELSEIF wa_hana-code CS 'SELECT ('
        CONDENSE wa_hana-code.
      ELSEIF wa_hana-code CS 'SELECT (' OR
        wa_hana-code CS 'FROM ('.
*} End of change by Twara - 12/02/2016
        CLEAR: wa_skipped_code.
        wa_skipped_code-name = wa_zauct_errors-pgname.
        wa_skipped_code-old_line = wa_zauct_errors-line_no.
        wa_skipped_code-new_line = line.
        wa_skipped_code-opcode = wa_zauct_errors-error_type.
        wa_skipped_code-reason =
        'Code fix skipped as SELECT contains dynamic fields/dynamic table'.
        APPEND wa_skipped_code TO gt_skipped_code.
        EXIT.
****End of change by Vrishti, 15/2/2016
      ELSE.
****End of change for select fields for all entries issue
        CONCATENATE 'ORDER BY' v_keys INTO v_keys SEPARATED BY space.
      ENDIF.
    ENDIF.

    REFRESH : lt_tab4[].


    CLEAR: lv_pos1, lv_pos2.
    CLEAR: lv_flag2, lv_flag_close_comment.
    p_line = line.
    v_line = p_line.
    gv_line = p_line.

    REFRESH: lt_code.

    LOOP AT rtab INTO wa_rtab FROM p_line.

      v_line = sy-tabix.
      CLEAR v_str.
      v_str = wa_rtab-text.
      IF v_str IS INITIAL.
        CONTINUE.
      ENDIF.
      CONDENSE v_str.
      IF v_str(1) EQ ca_starpp OR v_str(1) EQ ca_astpp.
        APPEND wa_rtab TO lt_code.
      ELSE.

        CLEAR: v_str, v_str1.
        SPLIT wa_rtab-text AT ca_astpp  INTO v_str v_str1.
        TRANSLATE wa_rtab-text TO UPPER CASE.
        TRANSLATE v_str TO UPPER CASE.
        IF NOT v_str1 IS INITIAL.
          FIND FIRST OCCURRENCE OF ca_astpp IN wa_rtab-text MATCH OFFSET
          lv_idx.
          lv_idx = lv_idx + 1.
          wa_rtab-text+lv_idx = v_str1.
        ELSE.
          wa_rtab-text = v_str.
        ENDIF.

        SHIFT v_str LEFT DELETING LEADING space.
        CHECK NOT v_str IS INITIAL.
        IF v_str CS ca_dotpp.
          SPLIT v_str AT ca_dotpp INTO v_str v_str1.
          CONCATENATE lv_code v_str INTO lv_code SEPARATED BY space.
          REPLACE FIRST OCCURRENCE OF '.' IN wa_rtab WITH ' '.
          APPEND wa_rtab TO lt_code.
          EXIT.
        ELSE.
          CONCATENATE lv_code v_str INTO lv_code SEPARATED BY space.
          APPEND wa_rtab TO lt_code.
        ENDIF.
      ENDIF.
    ENDLOOP.

** Check if error is real**
    CONDENSE lv_code.
    TRANSLATE lv_code TO UPPER CASE.
    IF NOT ( lv_code CS 'SELECT' AND lv_code CS 'FROM' ).
      CLEAR: wa_skipped_code.
      wa_skipped_code-name = wa_zauct_errors-pgname.
      wa_skipped_code-old_line = wa_zauct_errors-line_no.
      wa_skipped_code-new_line = line.
      wa_skipped_code-opcode = wa_zauct_errors-error_type.
      wa_skipped_code-reason =
      'Code fix skipped as the code does not contain SELECT statement'.
      APPEND wa_skipped_code TO gt_skipped_code.
      EXIT.
    ENDIF.
** End Check **
******Changes Made for select single issue
    IF lv_code CS 'SELECT SINGLE'.
      IF lv_code CS 'SELECT SINGLE *'.
        IF lv_code CS 'CLIENT SPECIFIED'.
          CLEAR: wa_skipped_code.
          wa_skipped_code-name = wa_zauct_errors-pgname.
          wa_skipped_code-old_line = wa_zauct_errors-line_no.
          wa_skipped_code-new_line = line.
          wa_skipped_code-opcode = wa_zauct_errors-error_type.
          wa_skipped_code-reason =
'Code fix skipped as it contains SELECT SINGLE * with CLIENT SPECIFIED'
          .
          APPEND wa_skipped_code TO gt_skipped_code.
          EXIT.
        ENDIF.
      ELSE.
        CLEAR: wa_skipped_code.
        wa_skipped_code-name = wa_zauct_errors-pgname.
        wa_skipped_code-old_line = wa_zauct_errors-line_no.
        wa_skipped_code-new_line = line.
        wa_skipped_code-opcode = wa_zauct_errors-error_type.
        wa_skipped_code-reason =
'Code fix skipped as it contains SELECT SINGLE with fields list provi' &
'ded'
        .
        APPEND wa_skipped_code TO gt_skipped_code.
        EXIT.
      ENDIF.
    ENDIF.
******End of change for select single issue
** Check for the order by existence**
    "Rest of the checks already added

    IF lv_code CS 'ORDER BY'.
      CLEAR: wa_skipped_code.
      wa_skipped_code-name = wa_zauct_errors-pgname.
      wa_skipped_code-old_line = wa_zauct_errors-line_no.
      wa_skipped_code-new_line = line.
      wa_skipped_code-opcode = wa_zauct_errors-error_type.
      wa_skipped_code-reason =
      'Code fix skipped as it already contains ORDER BY clause'.
      APPEND wa_skipped_code TO gt_skipped_code.
      EXIT.
    ENDIF.
**End Check**


**** Begin of changes by Kanika - 16/3/2016
*    IF lv_code CS 'SELECT COUNT(*)'.
    lv_temp = lv_code.
    CONDENSE lv_temp NO-GAPS.
    IF lv_temp CS 'SELECTCOUNT(*)'.
      CLEAR : lv_temp.
**** End of changes by Kanika - 16/3/2016
      CLEAR: wa_skipped_code.
      wa_skipped_code-name = wa_zauct_errors-pgname.
      wa_skipped_code-old_line = wa_zauct_errors-line_no.
      wa_skipped_code-new_line = line.
      wa_skipped_code-opcode = wa_zauct_errors-error_type.
      wa_skipped_code-reason =
      'Code fix skipped as it contains SELECT COUNT(*)'.
      APPEND wa_skipped_code TO gt_skipped_code.
      EXIT.
    ENDIF.

    CLEAR:lv_pos1, lv_pos2.
    IF lv_flag = ''.
      TRANSLATE lv_code TO UPPER CASE.
      SPLIT lv_code AT space INTO TABLE rtab1.
      DELETE rtab1 WHERE text IS INITIAL.
      CLEAR lv_code.

      LOOP AT rtab1 INTO wa_rtab1.
        CONCATENATE lv_code wa_rtab1-text INTO lv_code SEPARATED BY
        space.
      ENDLOOP.
      CONDENSE lv_code.

      " select single UP TO 1 ROWS.
      CLEAR: lv_flag1.

      IF lv_code CS 'SELECT SINGLE'.
        REPLACE FIRST OCCURRENCE OF 'SELECT SINGLE' IN lv_code WITH
          'SELECT'.
        LOOP AT lt_code ASSIGNING <fs_code>.
          CLEAR v_str.
          v_str = <fs_code>-text.
          CONDENSE v_str.
          IF v_str IS INITIAL.
            CONTINUE.
          ENDIF.
          IF v_str(1) EQ ca_starpp OR v_str(1) EQ ca_astpp.
            CONTINUE.
          ENDIF.
**** Begin of changes by Kanika - 16/03/2016
* Begin of changes by  for DEF_16  - 5/2/2017
          CONDENSE <fs_code>-text.
* End of changes by  for DEF_16 - 5/2/2017
          IF <fs_code>-text CS 'SELECT SINGLE'.
            REPLACE FIRST OCCURRENCE OF 'SELECT SINGLE' IN
            <fs_code>-text WITH
          'SELECT'.
*            IF v_str CS 'SELECT SINGLE'.
*            REPLACE FIRST OCCURRENCE OF 'SELECT SINGLE' IN
*            v_str WITH
*          'SELECT'.
**** End of changes by Kanika - 16/03/2016
            EXIT.
          ENDIF.
        ENDLOOP.
        CONDENSE lv_code.
        SPLIT lv_code AT '' INTO TABLE lt_tab4[].
        DELETE lt_tab4 WHERE text = ''.
        READ TABLE lt_tab4 INTO lwa_tab4 WITH KEY text = 'FROM'.
        IF sy-subrc = 0.
          lv_pos1 = sy-tabix.
        ENDIF.
        CLEAR: lwa_tab4.
        READ TABLE lt_tab4 INTO lwa_tab4 WITH KEY text = 'INTO'.
        IF sy-subrc = 0.
          lv_pos2 = sy-tabix.
        ELSE.
          lv_pos2 = lv_pos1.
        ENDIF.
        IF lv_pos1 > lv_pos2.
          lwa_tab4 = 'UP TO 1 ROWS'.
          INSERT lwa_tab4 INTO lt_tab4 INDEX  lv_pos2.
        ELSE.
          lwa_tab4 = 'UP TO 1 ROWS'.
          INSERT lwa_tab4 INTO lt_tab4 INDEX  lv_pos1.
        ENDIF.
        LOOP AT lt_code ASSIGNING <fs_code>.
          CLEAR v_str.
          v_str = <fs_code>-text.
          CONDENSE v_str.
          IF v_str IS INITIAL.
            CONTINUE.
          ENDIF.
          IF v_str(1) EQ ca_starpp OR v_str(1) EQ ca_astpp.
            CONTINUE.
          ENDIF.
          IF v_str CS ca_astpp.
            SPLIT v_str AT ca_astpp INTO v_str v_str1.
          ENDIF.
          IF lv_pos1 > lv_pos2.
            IF v_str CS 'INTO'.
              REPLACE FIRST OCCURRENCE OF 'INTO' IN <fs_code>-text WITH
              'UP TO 1 ROWS INTO'.
              EXIT.
            ENDIF.
          ELSE.
            IF v_str CS 'FROM'.
              REPLACE FIRST OCCURRENCE OF 'FROM' IN <fs_code>-text WITH
              'UP TO 1 ROWS FROM'.
              EXIT.
            ENDIF.
          ENDIF.
        ENDLOOP.
        CLEAR: lv_code.
        LOOP AT lt_tab4 INTO lwa_tab4.
          CONCATENATE lv_code lwa_tab4-text INTO lv_code SEPARATED BY
          space.
        ENDLOOP.
        CONCATENATE lv_code 'ORDER BY PRIMARY KEY' INTO lv_code
        SEPARATED
        BY space.
        lv_flag1 = 'X'.

        wa_code-text = 'ORDER BY PRIMARY KEY'.
        APPEND wa_code TO lt_code.

******Additon made - For All Enteries Clause******
*****Start of code change for select for all entries issue
      ELSEIF lv_code CS 'SELECT' AND lv_code CS 'FOR ALL ENTRIES' AND
      v_fae IS INITIAL.
        IF NOT v_keys2 IS INITIAL.
          lv_flag2 = 'X'.
        ELSE.
          CLEAR: wa_skipped_code.
          wa_skipped_code-name = wa_zauct_errors-pgname.
          wa_skipped_code-old_line = wa_zauct_errors-line_no.
          wa_skipped_code-new_line = line.
          wa_skipped_code-opcode = wa_zauct_errors-error_type.
          wa_skipped_code-reason =
          'Code fix skipped as no primary key field in select list'.
          APPEND wa_skipped_code TO gt_skipped_code.
          EXIT.
        ENDIF.
**Begin of DEF_1 by priyanka <08-02-2017>
      ELSEIF ( lv_code CS '~' ) AND ( lv_code CS 'JOIN' ).
        CLEAR: wa_skipped_code.
        wa_skipped_code-name = wa_zauct_errors-pgname.
        wa_skipped_code-old_line = wa_zauct_errors-line_no.
        wa_skipped_code-new_line = line.
        wa_skipped_code-opcode = wa_zauct_errors-error_type.
        wa_skipped_code-reason =
        'Code fix skipped as select statement has a join condition'.
        APPEND wa_skipped_code TO gt_skipped_code.
        EXIT.
**End of DEF_1 by priyanka <08-02-2017>
      ELSE.
** Begin of changes by Sahil for DEF_15  - 5/2/2017
        IF lv_code CS 'SELECT DISTINCT' AND v_keys IS NOT INITIAL.
          CONCATENATE lv_code v_keys INTO lv_code
         SEPARATED
         BY space.
          wa_code-text = v_keys.
          APPEND wa_code TO lt_code.
        ELSE .
* End of changes by Sahil for DEF_15  - 5/2/2017
****End of code change for select for all entries issue
          CONCATENATE lv_code 'ORDER BY PRIMARY KEY' INTO lv_code
          SEPARATED
          BY space.
          wa_code-text = 'ORDER BY PRIMARY KEY'.
          APPEND wa_code TO lt_code.
        ENDIF.
* Begin of changes by  for DEF_15  - 5/2/2017
      ENDIF.
* End of changes by  for DEF_15 - 5/2/2017
      IF lv_code NS ca_dotpp.
        CONCATENATE lv_code ca_dotpp INTO lv_code.
      ENDIF.

      DESCRIBE TABLE lt_code LINES lv_last_idx.
      READ TABLE lt_code ASSIGNING <fs_code> INDEX lv_last_idx.
      IF sy-subrc = 0.
        CONCATENATE <fs_code>-text '.' INTO <fs_code>-text.
      ENDIF.

****End of Additon made - For All Enteries Clause***
      " Check possibility of Opcode 41 in this case
      CLEAR: lv_flag_opcode41,
             lv_opcode41_offset,
             lv_new,
             lv_new_end,
             lv_index41,
             lv_flag2_start.
      READ TABLE i_zauct_errors INTO wa_auct_err41 WITH KEY
      session_id = wa_zauct_errors-session_id
      pgname = wa_zauct_errors-pgname
      sub_program = wa_zauct_errors-sub_program
      error_type = 41
      line_no = wa_zauct_errors-line_no
      runn = ''.
      IF sy-subrc = 0.
        IF lv_code CS 'FOR ALL ENTRIES'.
          IF lv_code CS 'INTO TABLE' OR lv_code CS
          'INTO CORRESPONDING FIELDS OF TABLE'
            OR lv_code CS 'APPENDING TABLE' OR lv_code CS
            'APPENDING CORRESPONDING FIELDS OF TABLE'.

            lv_flag_opcode41 = 'X'.

            REFRESH: rtab41[].
            SPLIT lv_code AT space INTO TABLE rtab41.
            DELETE rtab41 WHERE text IS INITIAL.
            READ TABLE rtab41 WITH KEY text = 'ENTRIES' TRANSPORTING NO
            FIELDS.
            IF sy-subrc = 0.
              lv_index41 = sy-tabix + 2.
              CLEAR wa_rtab41.
              READ TABLE rtab41 INTO wa_rtab41 INDEX lv_index41.
              CONDENSE wa_rtab41-text.
              IF wa_rtab41-text CS '[]'.
                CONCATENATE 'IF NOT' wa_rtab41-text 'IS INITIAL.' INTO
             lv_new SEPARATED BY space.
              ELSE.
                CONCATENATE wa_rtab41-text '[]' INTO wa_rtab41-text.
                CONCATENATE 'IF NOT' wa_rtab41-text 'IS INITIAL.' INTO
             lv_new SEPARATED BY space.
              ENDIF.
            ENDIF.

            lv_new_end = 'ENDIF.'.
          ENDIF.

        ENDIF.
      ENDIF.

      IF lv_flag2 IS INITIAL.
        INSERT comment_start INTO rtab INDEX p_line.
        p_line = p_line + 1.
        v_line = v_line + 1.

        IF lv_flag_opcode41 EQ 'X'.
          INSERT lv_new INTO rtab INDEX p_line.
          p_line = p_line + 1.
          v_line = v_line + 1.
          lv_opcode41_offset = lv_opcode41_offset + 1.
        ENDIF.

        lv_flag_close_comment = 'X'.

        LOOP AT rtab INTO wa_rtab FROM p_line TO v_line.
          CONCATENATE '*'  wa_rtab-text INTO wa_rtab-text.
          MODIFY rtab FROM wa_rtab.
        ENDLOOP.
      ENDIF.
      CLEAR rtab1[].

      IF lv_flag2 IS INITIAL.
        rtab1[] = lt_code[].

      ENDIF.

*If internal table is of type sorted table then no need to put sort by
*statement
      CLEAR lv_type_of_table.
      IF lv_code CS 'INTO TABLE' OR lv_code CS
      'INTO CORRESPONDING FIELDS OF TABLE'
        OR lv_code CS 'APPENDING TABLE' OR lv_code CS
        'APPENDING CORRESPONDING FIELDS OF TABLE'.

        IF lv_code NS 'APPENDING'.
          CLEAR: v_str.
          REFRESH: lt_tab4[].
          SPLIT lv_code AT '' INTO TABLE lt_tab4[].
          DELETE lt_tab4 WHERE text = ''.
          READ TABLE lt_tab4 INTO lwa_tab4 WITH KEY text = 'TABLE'.
          READ TABLE lt_tab4 INTO lwa_tab4 INDEX sy-tabix + 1.
          IF sy-subrc = 0.
            v_str = lwa_tab4-text.
            TRANSLATE v_str TO UPPER CASE.
            REPLACE ALL OCCURRENCES OF '[' IN v_str WITH ''.
            REPLACE ALL OCCURRENCES OF ']' IN v_str WITH ''.
            CONDENSE v_str.
            LOOP AT rtab INTO wa_rtab.
              CLEAR: v_str1,v_str2, v_str3.
              v_str1 = wa_rtab-text.
              CONDENSE v_str1.
              IF v_str1 IS INITIAL.
                CONTINUE.
              ENDIF.
              IF v_str1(1) EQ ca_starpp OR v_str1(1) EQ ca_astpp.
                CONTINUE.
              ENDIF.
              TRANSLATE v_str1 TO UPPER CASE.
              REPLACE ALL OCCURRENCES OF '[' IN v_str1 WITH ''.
              REPLACE ALL OCCURRENCES OF ']' IN v_str1 WITH ''.
              CONDENSE v_str1.
              CONCATENATE v_str 'TYPE' INTO v_str2 SEPARATED BY space.
              CONCATENATE v_str 'LIKE' INTO v_str3 SEPARATED BY space.
              IF v_str1 CS v_str2 OR v_str1 CS v_str3.
                IF v_str1 CS 'SORTED TABLE OF'.
                  lv_type_of_table = 'S'.
                  EXIT.
                ENDIF.
              ELSE.
                CONTINUE.
              ENDIF.

            ENDLOOP.
          ENDIF.
        ENDIF.

        IF NOT v_keys2 IS INITIAL
            AND lv_type_of_table NE 'S'.
          APPEND comment_start TO rtab1.
          APPEND v_keys2 TO rtab1.
          lv_flag_close_comment = 'X'.
          lv_flag2_start = 'X'.
        ENDIF.

        IF lv_flag_opcode41 EQ 'X' AND lv_flag2 EQ 'X'.
          INSERT comment_start INTO rtab INDEX p_line.
          p_line = p_line + 1.
          v_line = v_line + 1.
          INSERT lv_new INTO rtab INDEX p_line.
          p_line = p_line + 1.
          v_line = v_line + 1.
          INSERT comment_end INTO rtab INDEX p_line.
          p_line = p_line + 1.
          v_line = v_line + 1.
          lv_opcode41_offset = lv_opcode41_offset + 3.
          IF lv_flag2_start EQ 'X'.
            APPEND lv_new_end TO rtab1.
          ELSE.
            APPEND comment_start TO rtab1.
            APPEND lv_new_end TO rtab1.
            lv_flag_close_comment = 'X'.
          ENDIF.

        ENDIF.

      ENDIF.


      CLEAR : lv_tlen , lv_len , lv_len1 , lv_tlen1.
      IF lv_flag1 = 'X'.
        lv_code = 'ENDSELECT.'.
        APPEND lv_code TO rtab1.
      ENDIF.

      IF lv_flag_opcode41 EQ 'X'
        AND lv_flag2 IS INITIAL.
        APPEND lv_new_end TO rtab1.
      ENDIF.

      IF lv_flag_close_comment = 'X'.
        APPEND comment_end TO rtab1.
        v_line = v_line + 1.
      ENDIF.

      DESCRIBE TABLE rtab1 LINES lv_tlen.
      INSERT LINES OF rtab1 INTO rtab INDEX v_line .


      IF lv_tlen GT 0.
***Code change for select For all entries
        IF NOT v_keys2 IS INITIAL.
          g_offset = g_offset + lv_tlen.
          gv_initial = lv_tlen.
        ELSE.
***end of changes
          g_offset = g_offset + 1 + lv_tlen.
          gv_initial = 1 + lv_tlen.
        ENDIF.

        IF lv_flag_opcode41 EQ 'X'.
          g_offset = g_offset + lv_opcode41_offset.
          IF <fs_auct_err> IS ASSIGNED.
            UNASSIGN <fs_auct_err>.
          ENDIF.
          READ TABLE i_zauct_errors ASSIGNING <fs_auct_err> WITH KEY
          session_id = wa_zauct_errors-session_id
          pgname = wa_zauct_errors-pgname
          sub_program = wa_zauct_errors-sub_program
          error_type = 41
          line_no = wa_zauct_errors-line_no
          runn = ''.
          IF sy-subrc = 0.
            <fs_auct_err>-runn = 'X'.
            <fs_auct_err>-actual_corr = 'Y'.
            READ TABLE it_hana ASSIGNING <fs_hana> WITH KEY
            session_id = wa_zauct_errors-session_id
            read_prog = wa_zauct_errors-pgname
            sub_program = wa_zauct_errors-sub_program
            opercd = 41
            operation = wa_zauct_errors-error_message
            line_no = wa_zauct_errors-line_no.
            IF sy-subrc = 0.
              <fs_hana>-runn = 'X'.
              <fs_hana>-detected = 'X'.
              <fs_hana>-actual_corr = 'Y'.
              MODIFY zdb_analysis_v74 FROM <fs_hana>.
            ENDIF.

            CLEAR: wa_correction_results.
            wa_correction_results-obj_name = wa_zauct_errors-obj_name.
            wa_correction_results-sub_program =
            wa_zauct_errors-sub_program.
            wa_correction_results-line_org = wa_zauct_errors-line_no.
            wa_correction_results-line_no = v_line.
            wa_correction_results-opcode = 41.
            APPEND wa_correction_results TO gt_correction_results.
          ENDIF.
        ENDIF.

        wa_hana-actual_corr = 'Y'.
        wa_zauct_errors-actual_corr = 'Y'.
        g_corr_done = 'X'.

        CLEAR: wa_correction_results.
        wa_correction_results-obj_name = wa_zauct_errors-obj_name.
        wa_correction_results-sub_program = wa_zauct_errors-sub_program.
        wa_correction_results-line_org = wa_zauct_errors-line_no.
        wa_correction_results-line_no = v_line.
        wa_correction_results-opcode = wa_zauct_errors-error_type.
        APPEND wa_correction_results TO gt_correction_results.

      ELSE.
        CLEAR: wa_skipped_code.
        wa_skipped_code-name = wa_zauct_errors-pgname.
        wa_skipped_code-old_line = wa_zauct_errors-line_no.
        wa_skipped_code-new_line = line.
        wa_skipped_code-opcode = wa_zauct_errors-error_type.
        wa_skipped_code-reason =
'Code fix skipped as no correction could be performed at given line'.
        APPEND wa_skipped_code TO gt_skipped_code.
      ENDIF.

      CLEAR : lv_tlen.
    ENDIF.

  ENDMETHOD.                    "check_opcode16
***begin of changes by Vrishti - 24/1/2017 : Def_2
*  METHOD check_opcode37.
*
*    DATA: v_line   TYPE i,
*          v_str    TYPE string,
*          lv_code  TYPE string,
*          lv_flag  TYPE c,
*          lv_index TYPE sy-tabix,
*          lv_idx   TYPE i.
*
*    TYPES: BEGIN OF ty_rtab1,
*             text(1000),
*           END OF ty_rtab1.
*    DATA: it_break TYPE TABLE OF ty_rtab1.
*
*    DATA: rtab1    TYPE TABLE OF ty_rtab1,
*          wa_rtab1 TYPE ty_rtab1,
*          lt_code  TYPE TABLE OF ty_rtab1,
*          wa_code  TYPE ty_rtab1.
*
*    FIELD-SYMBOLS: <fs_code> TYPE ty_rtab1.
*
*    DATA : wa_break LIKE LINE OF it_break,
*           lv_len   TYPE i,
*           lv_len1  TYPE i,
*           lv_tlen  TYPE i,
*           lv_tlen1 TYPE i,
*           p_line   TYPE i.
*
*    line = line + g_offset.
*    READ TABLE it_hana INTO wa_hana WITH KEY
*    session_id = wa_zauct_errors-session_id
*    read_prog = wa_zauct_errors-pgname
*    sub_program = wa_zauct_errors-sub_program
*    opercd = wa_zauct_errors-error_type
*    operation = wa_zauct_errors-error_message
*    line_no = wa_zauct_errors-line_no.
*    wa_hana-runn = 'X'.
*    wa_zauct_errors-runn = 'X'.
*
*    p_line = line.
*    v_line = p_line.
*
*    REFRESH: lt_code.
*
*    LOOP AT rtab INTO wa_rtab FROM p_line.
*
*      v_line = sy-tabix.
*      CLEAR v_str.
*      v_str = wa_rtab-text.
*      IF v_str IS INITIAL.
*        CONTINUE.
*      ENDIF.
*      CONDENSE v_str.
*      IF v_str(1) EQ ca_starpp OR v_str(1) EQ ca_astpp.
*        APPEND wa_rtab TO lt_code.
*      ELSE.
*
*        CLEAR: v_str, v_str1.
*        SPLIT wa_rtab-text AT ca_astpp  INTO v_str v_str1.
*        TRANSLATE wa_rtab-text TO UPPER CASE.
*        TRANSLATE v_str TO UPPER CASE.
*        IF NOT v_str1 IS INITIAL.
*          FIND FIRST OCCURRENCE OF ca_astpp IN wa_rtab-text MATCH OFFSET
*          lv_idx.
*          lv_idx = lv_idx + 1.
*          wa_rtab-text+lv_idx = v_str1.
*        ELSE.
*          wa_rtab-text = v_str.
*        ENDIF.
*
*        SHIFT v_str LEFT DELETING LEADING space.
*        CHECK NOT v_str IS INITIAL.
*        IF v_str CS ca_dotpp.
*          SPLIT v_str AT ca_dotpp INTO v_str v_str1.
*          CONCATENATE lv_code v_str INTO lv_code SEPARATED BY space.
*          APPEND wa_rtab TO lt_code.
*          EXIT.
*        ELSE.
*          CONCATENATE lv_code v_str INTO lv_code SEPARATED BY space.
*          APPEND wa_rtab TO lt_code.
*        ENDIF.
*      ENDIF.
*    ENDLOOP.
*
***Check for Error if its Real**
*    CONDENSE lv_code.
*    TRANSLATE lv_code TO UPPER CASE.
*    IF NOT lv_code CS 'BYPASSING BUFFER'.
*      CLEAR: wa_skipped_code.
*      wa_skipped_code-name = wa_zauct_errors-pgname.
*      wa_skipped_code-old_line = wa_zauct_errors-line_no.
*      wa_skipped_code-new_line = line.
*      wa_skipped_code-opcode = wa_zauct_errors-error_type.
*      wa_skipped_code-reason =
*      'Code fix skipped as the code does not contain BYPASSING BUFFER'.
*      APPEND wa_skipped_code TO gt_skipped_code.
*      EXIT.
*    ENDIF.
***End Check**
*
*    IF lv_flag = ''.
*      SPLIT lv_code AT space INTO TABLE rtab1.
*      DELETE rtab1 WHERE text IS INITIAL.
*      READ TABLE rtab1 WITH KEY text = 'BYPASSING' TRANSPORTING NO
*      FIELDS.
*      IF sy-subrc = 0.
*        lv_index = sy-tabix + 1.
*        DELETE rtab1 INDEX lv_index.
*        DELETE rtab1 INDEX sy-tabix.
*        DELETE rtab1 WHERE text IS INITIAL.
*      ENDIF.
*
*      LOOP AT lt_code ASSIGNING <fs_code>.
*        lv_index = sy-tabix.
*        CLEAR v_str.
*        v_str = <fs_code>-text.
*        CONDENSE v_str.
*        IF v_str IS INITIAL.
*          CONTINUE.
*        ENDIF.
*        IF v_str(1) EQ ca_starpp OR v_str(1) EQ ca_astpp.
*          CONTINUE.
*        ENDIF.
*        IF <fs_code>-text CS 'BYPASSING BUFFER'.
*          REPLACE FIRST OCCURRENCE OF 'BYPASSING BUFFER' IN
*          <fs_code>-text WITH ''.
*          IF <fs_code>-text IS INITIAL.
*            DELETE lt_code INDEX lv_index.
*          ENDIF.
*          EXIT.
*        ENDIF.
*      ENDLOOP.
*
*      INSERT comment_start INTO rtab INDEX p_line.
*      p_line = p_line + 1.
*      v_line = v_line + 1.
*      LOOP AT rtab INTO wa_rtab FROM p_line TO v_line.
*        CONCATENATE '*'  wa_rtab-text INTO wa_rtab-text.
*        MODIFY rtab FROM wa_rtab.
*      ENDLOOP.
*      CLEAR rtab1[].
*
*      rtab1[] = lt_code[].
*      CLEAR : lv_tlen , lv_len , lv_len1 , lv_tlen1.
*      APPEND comment_end TO rtab1.
*      v_line = v_line + 1.
*      DESCRIBE TABLE rtab1 LINES lv_tlen.
*      INSERT LINES OF rtab1 INTO rtab INDEX v_line .
*
*      g_offset = g_offset + 1 + lv_tlen.
*      wa_hana-actual_corr = 'Y'.
*      wa_zauct_errors-actual_corr = 'Y'.
*      g_corr_done = 'X'.
*      CLEAR : lv_tlen.
*
*      CLEAR: wa_correction_results.
*      wa_correction_results-obj_name = wa_zauct_errors-obj_name.
*      wa_correction_results-sub_program = wa_zauct_errors-sub_program.
*      wa_correction_results-line_org = wa_zauct_errors-line_no.
*      wa_correction_results-line_no = v_line.
*      wa_correction_results-opcode = wa_zauct_errors-error_type.
*      APPEND wa_correction_results TO gt_correction_results.
*
*    ENDIF.
*
*  ENDMETHOD.
***end of changes by Vrishti - 24/1/2017 : Def_2

  METHOD check_opcode45.

    DATA: v_line       TYPE i,
          v_str        TYPE string,
          p_line       TYPE i,
          lv_code      TYPE string,
          lv_flag      TYPE c,
          lv_index     TYPE sy-tabix,
          lv_num       TYPE i,
          lv_new(1000) TYPE c,
          lv_itab      TYPE string,
          lv_index1    TYPE i,
          lv_index2    TYPE i,
          lv_inst      TYPE i,
          lv_start     TYPE i,
          lv_end       TYPE i.

    TYPES: BEGIN OF ty_rtab1,
             text(1000),
           END OF ty_rtab1.

    DATA: rtab1    TYPE TABLE OF ty_rtab1,
          wa_rtab1 TYPE ty_rtab1.

    line = line + g_offset.
    READ TABLE it_hana INTO wa_hana WITH KEY
    session_id = wa_zauct_errors-session_id
    read_prog = wa_zauct_errors-pgname
    sub_program = wa_zauct_errors-sub_program
    opercd = wa_zauct_errors-error_type
    operation = wa_zauct_errors-error_message
    line_no = wa_zauct_errors-line_no.
    wa_hana-runn = 'X'.
    wa_zauct_errors-runn = 'X'.

    p_line = line.
    v_line = p_line.

    LOOP AT rtab INTO wa_rtab FROM p_line.

      CHECK wa_rtab-text(1) NE ca_starpp.
      CHECK wa_rtab-text(1) NE ca_astpp.

      SPLIT wa_rtab-text AT ca_astpp  INTO v_str v_str1.
      TRANSLATE v_str TO UPPER CASE.
      SHIFT v_str LEFT DELETING LEADING space.
      CHECK v_str IS NOT INITIAL.

      IF v_str CS ca_dotpp.
        SPLIT v_str AT ca_dotpp INTO v_str v_str1.
        CONCATENATE lv_code v_str INTO lv_code SEPARATED BY space.
        CONDENSE lv_code.
        v_line = sy-tabix.
        EXIT.
      ELSE.
        CONCATENATE lv_code v_str INTO lv_code SEPARATED BY space.
      ENDIF.
    ENDLOOP.

**Check for Error if its real**
    CONDENSE lv_code.
    TRANSLATE lv_code TO UPPER CASE.
    IF NOT ( lv_code CS 'READ TABLE' AND lv_code CS 'BINARY SEARCH' ).
      CLEAR: wa_skipped_code.
      wa_skipped_code-name = wa_zauct_errors-pgname.
      wa_skipped_code-old_line = wa_zauct_errors-line_no.
      wa_skipped_code-new_line = line.
      wa_skipped_code-opcode = wa_zauct_errors-error_type.
      wa_skipped_code-reason =
'Code fix skipped as the code does not contain READ TABLE statement'.
      APPEND wa_skipped_code TO gt_skipped_code.
      EXIT.
    ENDIF.
**End Check**

    IF lv_flag = ''.
      SPLIT lv_code AT space INTO TABLE rtab1.
      DELETE rtab1 WHERE text IS INITIAL.
      READ TABLE rtab1 INTO wa_rtab1 INDEX 3.
      IF sy-subrc IS INITIAL.
        lv_itab = wa_rtab1-text.
      ENDIF.
      IF lv_code CS 'BINARY SEARCH'.
        READ TABLE rtab1 WITH KEY text = 'KEY' TRANSPORTING NO FIELDS.
        IF sy-subrc = 0.
          lv_index = sy-tabix + 1.
          lv_index1 = lv_index.
          LOOP AT rtab1 INTO wa_rtab1 FROM lv_index1.
            IF lv_index1 LT lv_index2.
              lv_index1 = lv_index1 + 1.
              CONTINUE.
            ENDIF.
            IF lv_num IS INITIAL.
              IF wa_rtab1-text = 'BINARY' OR wa_rtab1-text IS INITIAL.
                EXIT.
              ELSE.
                CONCATENATE 'SORT' lv_itab 'BY' wa_rtab1-text INTO
                lv_new
                SEPARATED BY space.
                lv_num = 1.
              ENDIF.
            ELSE.
              IF wa_rtab1-text = 'BINARY' OR wa_rtab1-text IS INITIAL.
                EXIT.
              ENDIF.
              CONCATENATE lv_new wa_rtab1-text INTO lv_new SEPARATED BY
              space.
            ENDIF.
            IF lv_inst IS INITIAL.
              lv_index2 = lv_index + 3.
              lv_index1 = lv_index + 1.
              lv_inst = 1.
            ELSE.
              lv_index2 = lv_index1 + 3.
              lv_index1 = lv_index1 + 1.
            ENDIF.
          ENDLOOP.
        ENDIF.
      ENDIF.

** for inserting above the loop entry.
      lv_start = p_line - 10.
      lv_end = p_line - 1.
      LOOP AT rtab INTO wa_rtab FROM lv_start TO lv_end.
        IF wa_rtab-text CS 'LOOP' .
          EXIT.
        ENDIF.
        lv_start = lv_start + 1.
      ENDLOOP.
      p_line = lv_start.
      v_line = lv_start.
** end of insertion for above loop code.
      INSERT comment_start INTO rtab INDEX p_line.
      p_line = p_line + 1.
      v_line = v_line + 1.
      CONCATENATE lv_new '.' INTO lv_new.
      INSERT lv_new INTO rtab INDEX p_line.
      p_line = p_line + 1.
      v_line = v_line + 1.
      INSERT comment_end INTO rtab INDEX p_line.
      p_line = p_line + 1.
      v_line = v_line + 1.

      g_offset = g_offset + 3.
      wa_hana-actual_corr = 'Y'.
      wa_zauct_errors-actual_corr = 'Y'.
      g_corr_done = 'X'.

      CLEAR: wa_correction_results.
      wa_correction_results-obj_name = wa_zauct_errors-obj_name.
      wa_correction_results-sub_program = wa_zauct_errors-sub_program.
      wa_correction_results-line_org = wa_zauct_errors-line_no.
      wa_correction_results-line_no = lv_start.
      wa_correction_results-opcode = wa_zauct_errors-error_type.
      APPEND wa_correction_results TO gt_correction_results.

    ENDIF.

  ENDMETHOD.                    "check_opcode45

  METHOD check_opcode45_18_19.

    line = line + g_offset.
    CLEAR: wa_hana, wa_hana1.
    READ TABLE it_hana INTO wa_hana WITH KEY
    session_id = wa_zauct_errors-session_id
    read_prog = wa_zauct_errors-pgname
    sub_program = wa_zauct_errors-sub_program
    opercd = wa_zauct_errors-error_type
    operation = wa_zauct_errors-error_message
    line_no = wa_zauct_errors-line_no.
    wa_hana-runn = 'X'.
    wa_zauct_errors-runn = 'X'.
    IF sy-subrc IS INITIAL.
      READ TABLE it_hana INTO wa_hana1 WITH KEY
          session_id = wa_zauct_errors-session_id
          read_prog = wa_zauct_errors-pgname
          sub_program = wa_zauct_errors-sub_program
          opercd = '21'
          line_no = wa_hana-select_line
          select_line = ''.
      IF sy-subrc IS INITIAL.
        IF NOT wa_hana1-actual_corr IS INITIAL.
          wa_hana-actual_corr = 'Y'.
          wa_zauct_errors-actual_corr = 'Y'.
          g_corr_done = 'X'.
          CLEAR: wa_correction_results.
          wa_correction_results-obj_name = wa_zauct_errors-obj_name.
          wa_correction_results-sub_program =
          wa_zauct_errors-sub_program.
          wa_correction_results-line_org = wa_zauct_errors-line_no.
          wa_correction_results-line_no = line.
          wa_correction_results-opcode = wa_zauct_errors-error_type.
          CONCATENATE 'Respective SELECT corrected at line:'
          wa_hana-select_line INTO wa_correction_results-message.
          APPEND wa_correction_results TO gt_correction_results.
        ELSE.
          CLEAR: wa_skipped_code.
          wa_skipped_code-name = wa_zauct_errors-pgname.
          wa_skipped_code-old_line = wa_zauct_errors-line_no.
          wa_skipped_code-new_line = line.
          wa_skipped_code-opcode = wa_zauct_errors-error_type.
          wa_skipped_code-reason = 'Manual Intervention Required'.
          APPEND wa_skipped_code TO gt_skipped_code.
        ENDIF.
      ELSE.
        CLEAR wa_skipped_code.
        wa_skipped_code-name = wa_zauct_errors-pgname.
        wa_skipped_code-old_line = wa_zauct_errors-line_no.
        wa_skipped_code-new_line = line.
        wa_skipped_code-opcode = wa_zauct_errors-error_type.
        wa_skipped_code-reason = 'Manual Intervention Required'.
        APPEND wa_skipped_code TO gt_skipped_code.
      ENDIF.
    ENDIF.
  ENDMETHOD.                    "check_opcode45_18_19

  METHOD check_opcode46.

    DATA: v_line       TYPE i,
          v_str        TYPE string,
          p_line       TYPE i,
          lv_code      TYPE string,
          lv_flag      TYPE c,
          lv_index     TYPE sy-tabix,
          lv_num       TYPE i,
          lv_new(1000) TYPE c,
          lv_itab      TYPE string.

    TYPES: BEGIN OF ty_rtab1,
             text(1000),
           END OF ty_rtab1.

    DATA: rtab1    TYPE TABLE OF ty_rtab1,
          wa_rtab1 TYPE ty_rtab1,
          lt_code  TYPE TABLE OF ty_rtab1,
          wa_code  TYPE ty_rtab1,
          lv_idx   TYPE i,
          lv_tlen  TYPE i.

    line = line + g_offset.
    READ TABLE it_hana INTO wa_hana WITH KEY
    session_id = wa_zauct_errors-session_id
    read_prog = wa_zauct_errors-pgname
    sub_program = wa_zauct_errors-sub_program
    opercd = wa_zauct_errors-error_type
    operation = wa_zauct_errors-error_message
    line_no = wa_zauct_errors-line_no.
    wa_hana-runn = 'X'.
    wa_zauct_errors-runn = 'X'.

    p_line = line.
    v_line = p_line.

    REFRESH: lt_code.

    LOOP AT rtab INTO wa_rtab FROM p_line.

      v_line = sy-tabix.
      CLEAR v_str.
      v_str = wa_rtab-text.
      IF v_str IS INITIAL.
        CONTINUE.
      ENDIF.
      CONDENSE v_str.
      IF v_str(1) EQ ca_starpp OR v_str(1) EQ ca_astpp.
        APPEND wa_rtab TO lt_code.
      ELSE.

        CLEAR: v_str, v_str1.
        SPLIT wa_rtab-text AT ca_astpp  INTO v_str v_str1.
        TRANSLATE wa_rtab-text TO UPPER CASE.
        TRANSLATE v_str TO UPPER CASE.
        IF NOT v_str1 IS INITIAL.
          FIND FIRST OCCURRENCE OF ca_astpp IN wa_rtab-text MATCH OFFSET
          lv_idx.
          lv_idx = lv_idx + 1.
          wa_rtab-text+lv_idx = v_str1.
        ELSE.
          wa_rtab-text = v_str.
        ENDIF.

        SHIFT v_str LEFT DELETING LEADING space.
        CHECK NOT v_str IS INITIAL.
        IF v_str CS ca_dotpp.
          SPLIT v_str AT ca_dotpp INTO v_str v_str1.
          CONCATENATE lv_code v_str INTO lv_code SEPARATED BY space.

          APPEND wa_rtab TO lt_code.
          EXIT.
        ELSE.
          CONCATENATE lv_code v_str INTO lv_code SEPARATED BY space.
          APPEND wa_rtab TO lt_code.
        ENDIF.
      ENDIF.
    ENDLOOP.


**Check for the Error if its Real**
    CONDENSE lv_code.
    TRANSLATE lv_code TO UPPER CASE.
    IF NOT lv_code CS 'DELETE ADJACENT DUPLICATES'.
      CLEAR: wa_skipped_code.
      wa_skipped_code-name = wa_zauct_errors-pgname.
      wa_skipped_code-old_line = wa_zauct_errors-line_no.
      wa_skipped_code-new_line = line.
      wa_skipped_code-opcode = wa_zauct_errors-error_type.
      wa_skipped_code-reason =
'Code fix skipped as the code does not contain DELETE ADJACENT DUPLIC' &
'ATES'
      .
      APPEND wa_skipped_code TO gt_skipped_code.
      EXIT.
    ENDIF.
**End Check**

    IF lv_flag = ''.

      SPLIT lv_code AT space INTO TABLE rtab1.
      DELETE rtab1 WHERE text IS INITIAL.
      READ TABLE rtab1 INTO wa_rtab1 INDEX 5.
      IF sy-subrc IS INITIAL.
        lv_itab = wa_rtab1-text.
      ENDIF.
      IF lv_code CS 'ALL FIELDS'.
        CONCATENATE 'SORT' lv_itab INTO lv_new SEPARATED BY space.
      ELSE.
        READ TABLE rtab1 WITH KEY text = 'COMPARING' TRANSPORTING NO
        FIELDS.
        IF sy-subrc = 0.
          lv_index = sy-tabix + 1.
          LOOP AT rtab1 INTO wa_rtab1 FROM lv_index.
            IF lv_num IS INITIAL.
              CONCATENATE 'SORT' lv_itab 'BY' wa_rtab1-text INTO lv_new
              SEPARATED BY space.
              lv_num = 1.
              lv_index = lv_index + 1.
            ELSE.
              CONCATENATE lv_new wa_rtab1-text INTO lv_new SEPARATED BY
              space.
              lv_index = lv_index + 1.
            ENDIF.
          ENDLOOP.
        ELSE.
          CONCATENATE 'SORT' lv_itab INTO lv_new SEPARATED BY space.
        ENDIF.
      ENDIF.
      INSERT comment_start INTO rtab INDEX p_line.
      p_line = p_line + 1.
      v_line = v_line + 1.
      LOOP AT rtab INTO wa_rtab FROM p_line TO v_line.
        CONCATENATE '*'  wa_rtab-text INTO wa_rtab-text.
        MODIFY rtab FROM wa_rtab.
      ENDLOOP.
      CLEAR rtab1[].
      CONCATENATE lv_new '.' INTO lv_new.
      APPEND lv_new TO rtab1.


      APPEND LINES OF lt_code TO rtab1.
      APPEND comment_end TO rtab1.
      v_line = v_line + 1.
      DESCRIBE TABLE rtab1 LINES lv_tlen.
      INSERT LINES OF rtab1 INTO rtab INDEX v_line .

      g_offset = g_offset + 1 + lv_tlen.
      wa_hana-actual_corr = 'Y'.
      wa_zauct_errors-actual_corr = 'Y'.
      g_corr_done = 'X'.

      CLEAR: wa_correction_results.
      wa_correction_results-obj_name = wa_zauct_errors-obj_name.
      wa_correction_results-sub_program = wa_zauct_errors-sub_program.
      wa_correction_results-line_org = wa_zauct_errors-line_no.
      wa_correction_results-line_no = v_line.
      wa_correction_results-opcode = wa_zauct_errors-error_type.
      APPEND wa_correction_results TO gt_correction_results.

    ENDIF.

  ENDMETHOD.                    "check_opcode46

***begin of changes by Vrishti - 24/1/2017 : Def_2
*  METHOD check_opcode41.
*
*    DATA:   v_line       TYPE i,
*            v_str        TYPE string,
*            p_line       TYPE i,
*            lv_code      TYPE string,
*            lv_flag      TYPE c,
*            lv_index     TYPE sy-tabix,
*            lv_num       TYPE i,
*            lv_new(1000) TYPE c,
*            lv_itab      TYPE string.
*
*    TYPES: BEGIN OF ty_rtab1,
*             text(1000),
*           END OF ty_rtab1.
*
*    DATA: rtab1    TYPE TABLE OF ty_rtab1,
*          wa_rtab1 TYPE ty_rtab1,
*          lt_code  TYPE TABLE OF ty_rtab1,
*          wa_code  TYPE ty_rtab1,
*          lv_idx   TYPE i,
*          lv_tlen  TYPE i,
*          lv_count TYPE i.
*
*    line = line + g_offset.
*    READ TABLE it_hana INTO wa_hana WITH KEY
*    session_id = wa_zauct_errors-session_id
*    read_prog = wa_zauct_errors-pgname
*    sub_program = wa_zauct_errors-sub_program
*    opercd = wa_zauct_errors-error_type
*    operation = wa_zauct_errors-error_message
*    line_no = wa_zauct_errors-line_no.
*    wa_hana-runn = 'X'.
*    wa_zauct_errors-runn = 'X'.
*
*    p_line = line.
*    v_line = p_line.
*
*    REFRESH: lt_code.
*
*    LOOP AT rtab INTO wa_rtab FROM p_line.
*
*      v_line = sy-tabix.
*      CLEAR v_str.
*      v_str = wa_rtab-text.
*      IF v_str IS INITIAL.
*        CONTINUE.
*      ENDIF.
*      CONDENSE v_str.
*      IF v_str(1) EQ ca_starpp OR v_str(1) EQ ca_astpp.
*        APPEND wa_rtab TO lt_code.
*      ELSE.
*
*        CLEAR: v_str, v_str1.
*        SPLIT wa_rtab-text AT ca_astpp  INTO v_str v_str1.
*        TRANSLATE wa_rtab-text TO UPPER CASE.
*        TRANSLATE v_str TO UPPER CASE.
*        IF NOT v_str1 IS INITIAL.
*          FIND FIRST OCCURRENCE OF ca_astpp IN wa_rtab-text MATCH OFFSET
*          lv_idx.
*          lv_idx = lv_idx + 1.
*          wa_rtab-text+lv_idx = v_str1.
*        ELSE.
*          wa_rtab-text = v_str.
*        ENDIF.
*
*        SHIFT v_str LEFT DELETING LEADING space.
*        CHECK NOT v_str IS INITIAL.
*        IF v_str CS ca_dotpp.
*          SPLIT v_str AT ca_dotpp INTO v_str v_str1.
*          CONCATENATE lv_code v_str INTO lv_code SEPARATED BY space.
*
*          APPEND wa_rtab TO lt_code.
*          EXIT.
*        ELSE.
*          CONCATENATE lv_code v_str INTO lv_code SEPARATED BY space.
*          APPEND wa_rtab TO lt_code.
*        ENDIF.
*      ENDIF.
*    ENDLOOP.
*
*
***Check for the Error if its Real**
*    CONDENSE lv_code.
*    TRANSLATE lv_code TO UPPER CASE.
*    IF NOT ( lv_code CS 'SELECT' AND lv_code CS 'FOR ALL ENTRIES IN' ).
*      CLEAR: wa_skipped_code.
*      wa_skipped_code-name = wa_zauct_errors-pgname.
*      wa_skipped_code-old_line = wa_zauct_errors-line_no.
*      wa_skipped_code-new_line = line.
*      wa_skipped_code-opcode = wa_zauct_errors-error_type.
*      wa_skipped_code-reason =
*'Code fix skipped as the code does not contain FOR ALL ENTRIES case'.
*      APPEND wa_skipped_code TO gt_skipped_code.
*      EXIT.
*    ENDIF.
***End Check**
*
*    IF lv_flag = ''.
*
*      SPLIT lv_code AT space INTO TABLE rtab1.
*      DELETE rtab1 WHERE text IS INITIAL.
*      READ TABLE rtab1 WITH KEY text = 'ENTRIES' TRANSPORTING NO FIELDS.
*      IF sy-subrc = 0.
*        lv_index = sy-tabix + 2.
*        CLEAR wa_rtab1.
*        READ TABLE rtab1 INTO wa_rtab1 INDEX lv_index.
*        CONDENSE wa_rtab1-text.
*        IF wa_rtab1-text CS '[]'.
*          CONCATENATE 'IF NOT' wa_rtab1-text 'IS INITIAL.' INTO
*       lv_new SEPARATED BY space.
*        ELSE.
*          CONCATENATE wa_rtab1-text '[]' INTO wa_rtab1-text.
*          CONCATENATE 'IF NOT' wa_rtab1-text 'IS INITIAL.' INTO
*       lv_new SEPARATED BY space.
*        ENDIF.
*      ENDIF.
*
*
*      IF ( lv_code CS 'INTO TABLE' OR lv_code CS
*      'INTO CORRESPONDING FIELDS OF TABLE'
*              OR lv_code CS 'APPENDING TABLE' OR lv_code CS
*              'APPENDING CORRESPONDING FIELDS OF TABLE' ).
*
*        INSERT comment_start INTO rtab INDEX p_line.
*        p_line = p_line + 1.
*        v_line = v_line + 1.
*        INSERT lv_new INTO rtab INDEX p_line.
*        p_line = p_line + 1.
*        v_line = v_line + 1.
*        INSERT comment_end INTO rtab INDEX p_line.
*        p_line = p_line + 1.
*        v_line = v_line + 1.
*
*      ELSE.
*
*        CLEAR: wa_skipped_code.
*        wa_skipped_code-name = wa_zauct_errors-pgname.
*        wa_skipped_code-old_line = wa_zauct_errors-line_no.
*        wa_skipped_code-new_line = line.
*        wa_skipped_code-opcode = wa_zauct_errors-error_type.
*        wa_skipped_code-reason =
*'Code fix skipped as this case is FOR ALL ENTRIES with SELECT-ENDSELE' &
*'CT. Please correct it manually'
*        .
*        APPEND wa_skipped_code TO gt_skipped_code.
*        EXIT.
**        REFRESH: gt_tokens,
**                 gt_stmts.
**        SCAN ABAP-SOURCE rtab[]
**          TOKENS      INTO gt_tokens
**          STATEMENTS  INTO gt_stmts
**          PRESERVING IDENTIFIER ESCAPING
**          WITH ANALYSIS
**          WITHOUT TRMAC.
**        IF sy-subrc <> 0.
**
**        ENDIF.
**        CLEAR: wa_tokens,
**               wa_stmts.
**        READ TABLE gt_tokens INTO wa_tokens WITH KEY row = p_line.
**        lv_index = sy-tabix.
**READ TABLE gt_stmts INTO wa_stmts WITH KEY from = lv_index terminator =
**'.'.
**        lv_index = wa_stmts-to.
**        lv_count = 1.
**        LOOP AT gt_tokens INTO wa_tokens FROM lv_index.
**          IF wa_tokens-str CS 'ENDSELECT'.
**            lv_count = lv_count - 1.
**          ELSEIF wa_tokens-str CS 'SELECT'.
**            lv_count = lv_count + 1.
**          ENDIF.
**
**          IF lv_count = 0.
**            v_line = wa_tokens-row.
**            EXIT.
**          ENDIF.
**
**        ENDLOOP.
*      ENDIF.
*
*      CLEAR rtab1[].
*      APPEND comment_start TO rtab1.
*
*      lv_new = 'ENDIF.'.
*      APPEND lv_new TO rtab1.
*      APPEND comment_end TO rtab1.
*      v_line = v_line + 1.
*      INSERT LINES OF rtab1 INTO rtab INDEX v_line .
*
*      g_offset = g_offset + 6.
*      wa_hana-actual_corr = 'Y'.
*      wa_zauct_errors-actual_corr = 'Y'.
*      g_corr_done = 'X'.
*
*      CLEAR: wa_correction_results.
*      wa_correction_results-obj_name = wa_zauct_errors-obj_name.
*      wa_correction_results-sub_program = wa_zauct_errors-sub_program.
*      wa_correction_results-line_org = wa_zauct_errors-line_no.
*      wa_correction_results-line_no = p_line.
*      wa_correction_results-opcode = wa_zauct_errors-error_type.
*      APPEND wa_correction_results TO gt_correction_results.
*
*    ENDIF.
*
*  ENDMETHOD.

**************** Begin of Changes By Vimal For Def_3
*  METHOD check_opcode41.
*
*    DATA: v_line       TYPE i,
*          v_str        TYPE string,
*          p_line       TYPE i,
*          lv_code      TYPE string,
*          lv_flag      TYPE c,
*          lv_index     TYPE sy-tabix,
*          lv_num       TYPE i,
*          lv_new(1000) TYPE c,
*          lv_itab      TYPE string.
*
*    TYPES: BEGIN OF ty_rtab1,
*             text(1000),
*           END OF ty_rtab1.
*
*    DATA: rtab1    TYPE TABLE OF ty_rtab1,
*          wa_rtab1 TYPE ty_rtab1,
*          lt_code  TYPE TABLE OF ty_rtab1,
*          wa_code  TYPE ty_rtab1,
*          lv_idx   TYPE i,
*          lv_tlen  TYPE i,
*          lv_count TYPE i.
*
*    line = line + g_offset.
*    READ TABLE it_hana INTO wa_hana WITH KEY
*    session_id = wa_zauct_errors-session_id
*    read_prog = wa_zauct_errors-pgname
*    sub_program = wa_zauct_errors-sub_program
*    opercd = wa_zauct_errors-error_type
*    operation = wa_zauct_errors-error_message
*    line_no = wa_zauct_errors-line_no.
*    wa_hana-runn = 'X'.
*    wa_zauct_errors-runn = 'X'.
*
*    p_line = line.
*    v_line = p_line.
*
*    REFRESH: lt_code.
*
*    LOOP AT rtab INTO wa_rtab FROM p_line.
*
*      v_line = sy-tabix.
*      CLEAR v_str.
*      v_str = wa_rtab-text.
*      IF v_str IS INITIAL.
*        CONTINUE.
*      ENDIF.
*      CONDENSE v_str.
*      IF v_str(1) EQ ca_starpp OR v_str(1) EQ ca_astpp.
*        APPEND wa_rtab TO lt_code.
*      ELSE.
*
*        CLEAR: v_str, v_str1.
*        SPLIT wa_rtab-text AT ca_astpp  INTO v_str v_str1.
*        TRANSLATE wa_rtab-text TO UPPER CASE.
*        TRANSLATE v_str TO UPPER CASE.
*        IF NOT v_str1 IS INITIAL.
*          FIND FIRST OCCURRENCE OF ca_astpp IN wa_rtab-text MATCH OFFSET
*          lv_idx.
*          lv_idx = lv_idx + 1.
*          wa_rtab-text+lv_idx = v_str1.
*        ELSE.
*          wa_rtab-text = v_str.
*        ENDIF.
*
*        SHIFT v_str LEFT DELETING LEADING space.
*        CHECK NOT v_str IS INITIAL.
*        IF v_str CS ca_dotpp.
*          SPLIT v_str AT ca_dotpp INTO v_str v_str1.
*          CONCATENATE lv_code v_str INTO lv_code SEPARATED BY space.
*
*          APPEND wa_rtab TO lt_code.
*          EXIT.
*        ELSE.
*          CONCATENATE lv_code v_str INTO lv_code SEPARATED BY space.
*          APPEND wa_rtab TO lt_code.
*        ENDIF.
*      ENDIF.
*    ENDLOOP.
*
*
***Check for the Error if its Real**
*    CONDENSE lv_code.
*    TRANSLATE lv_code TO UPPER CASE.
*    IF NOT ( lv_code CS 'SELECT' AND lv_code CS 'FOR ALL ENTRIES IN' ).
*      CLEAR: wa_skipped_code.
*      wa_skipped_code-name = wa_zauct_errors-pgname.
*      wa_skipped_code-old_line = wa_zauct_errors-line_no.
*      wa_skipped_code-new_line = line.
*      wa_skipped_code-opcode = wa_zauct_errors-error_type.
*      wa_skipped_code-reason =
*'Code fix skipped as the code does not contain FOR ALL ENTRIES case'.
*      APPEND wa_skipped_code TO gt_skipped_code.
*      EXIT.
*    ENDIF.
***End Check**
*
*    IF lv_flag = ''.
*
*      SPLIT lv_code AT space INTO TABLE rtab1.
*      DELETE rtab1 WHERE text IS INITIAL.
*      READ TABLE rtab1 WITH KEY text = 'ENTRIES' TRANSPORTING NO FIELDS.
*      IF sy-subrc = 0.
*        lv_index = sy-tabix + 2.
*        CLEAR wa_rtab1.
*        READ TABLE rtab1 INTO wa_rtab1 INDEX lv_index.
*        CONDENSE wa_rtab1-text.
*        IF wa_rtab1-text CS '[]'.
*          CONCATENATE 'IF NOT' wa_rtab1-text 'IS INITIAL.' INTO
*       lv_new SEPARATED BY space.
*        ELSE.
*          CONCATENATE wa_rtab1-text '[]' INTO wa_rtab1-text.
*          CONCATENATE 'IF NOT' wa_rtab1-text 'IS INITIAL.' INTO
*       lv_new SEPARATED BY space.
*        ENDIF.
*      ENDIF.
*
*      IF ( lv_code CS 'INTO TABLE' OR lv_code CS
*      'INTO CORRESPONDING FIELDS OF TABLE'
*              OR lv_code CS 'APPENDING TABLE' OR lv_code CS
*              'APPENDING CORRESPONDING FIELDS OF TABLE' ).
*
*        INSERT comment_start INTO rtab INDEX p_line.
*        p_line = p_line + 1.
*        v_line = v_line + 1.
*        INSERT lv_new INTO rtab INDEX p_line.
*        p_line = p_line + 1.
*        v_line = v_line + 1.
*        INSERT comment_end INTO rtab INDEX p_line.
*        p_line = p_line + 1.
*        v_line = v_line + 1.
*
*      ELSE.
*        "begin of code chagnes for def_3 - code copied from above rather than commenting condition because
*        " if in future there is an change required for diffrent conditions we should be able to do it with if condition given above.
*        INSERT comment_start INTO rtab INDEX p_line.
*        p_line = p_line + 1.
*        v_line = v_line + 1.
*        INSERT lv_new INTO rtab INDEX p_line.
*        p_line = p_line + 1.
*        v_line = v_line + 1.
*        INSERT comment_end INTO rtab INDEX p_line.
*        p_line = p_line + 1.
*        v_line = v_line + 1.
*
**        CLEAR: wa_skipped_code.
**        wa_skipped_code-name = wa_zauct_errors-pgname.
**        wa_skipped_code-old_line = wa_zauct_errors-line_no.
**        wa_skipped_code-new_line = line.
**        wa_skipped_code-opcode = wa_zauct_errors-error_type.
**        wa_skipped_code-reason =
**'Code fix skipped as this case is FOR ALL ENTRIES with SELECT-ENDSELE' &
**'CT. Please correct it manually'
**        .
**        APPEND wa_skipped_code TO gt_skipped_code.
**        EXIT.
**        REFRESH: gt_tokens,
**                 gt_stmts.
**        SCAN ABAP-SOURCE rtab[]
**          TOKENS      INTO gt_tokens
**          STATEMENTS  INTO gt_stmts
**          PRESERVING IDENTIFIER ESCAPING
**          WITH ANALYSIS
**          WITHOUT TRMAC.
**        IF sy-subrc <> 0.
**
**        ENDIF.
**        CLEAR: wa_tokens,
**               wa_stmts.
**        READ TABLE gt_tokens INTO wa_tokens WITH KEY row = p_line.
**        lv_index = sy-tabix.
**READ TABLE gt_stmts INTO wa_stmts WITH KEY from = lv_index terminator =
**'.'.
**        lv_index = wa_stmts-to.
**        lv_count = 1.
**        LOOP AT gt_tokens INTO wa_tokens FROM lv_index.
**          IF wa_tokens-str CS 'ENDSELECT'.
**            lv_count = lv_count - 1.
**          ELSEIF wa_tokens-str CS 'SELECT'.
**            lv_count = lv_count + 1.
**          ENDIF.
**
**          IF lv_count = 0.
**            v_line = wa_tokens-row.
**            EXIT.
**          ENDIF.
**
**        ENDLOOP.
*      ENDIF.
*      "end of changes for def_3
*      CLEAR rtab1[].
*      APPEND comment_start TO rtab1.
*
*      lv_new = 'ENDIF.'.
*      APPEND lv_new TO rtab1.
*      APPEND comment_end TO rtab1.
*      v_line = v_line + 1.
*      INSERT LINES OF rtab1 INTO rtab INDEX v_line .
*
*      g_offset = g_offset + 6.
*      wa_hana-actual_corr = 'Y'.
*      wa_zauct_errors-actual_corr = 'Y'.
*      g_corr_done = 'X'.
*
*      CLEAR: wa_correction_results.
*      wa_correction_results-obj_name = wa_zauct_errors-obj_name.
*      wa_correction_results-sub_program = wa_zauct_errors-sub_program.
*      wa_correction_results-line_org = wa_zauct_errors-line_no.
*      wa_correction_results-line_no = p_line.
*      wa_correction_results-opcode = wa_zauct_errors-error_type.
*      APPEND wa_correction_results TO gt_correction_results.
*
*    ENDIF.
*
*  ENDMETHOD.
**************** END of Changes By Vimal For Def_3
***end of changes by Vrishti - 24/1/2017 : Def_2
  METHOD pretty_printer.
**************************************************
* To adjust syntaxes and code looks and case
**************************************************
    DATA: lv_object TYPE e071-obj_name.

    DATA : wa_lineindex TYPE edlineindx,
           l_rseumod    TYPE rseumod,
           l_case_mode  TYPE char5,
           lt_lineindex TYPE STANDARD TABLE OF  edlineindx.
    DATA: lv_program TYPE programm.

    IF g_headflg IS INITIAL.
      LOOP AT rtab INTO wa_rtab.
        CONDENSE wa_rtab.
        IF wa_rtab+0(1) <> '*' AND wa_rtab+0(1) <> '"' AND wa_rtab <>
          space AND wa_rtab NS 'method'.
          INSERT LINES OF itab_header INTO rtab INDEX sy-tabix.
          EXIT.
        ELSEIF wa_rtab+0(1) EQ '*' OR wa_rtab+0(1) EQ '"'.
          INSERT LINES OF itab_header INTO rtab INDEX sy-tabix.
          EXIT.
        ENDIF.
      ENDLOOP.

      FIELD-SYMBOLS: <fs_skipped_code>       TYPE ty_skipped_code,
                     <fs_correction_results> TYPE ty_correction_results.

      LOOP AT gt_skipped_code ASSIGNING <fs_skipped_code>
                              WHERE name = wa_zauct_errors_tmp-pgname.
        <fs_skipped_code>-new_line = <fs_skipped_code>-new_line +
        v_header_lines.
      ENDLOOP.

      LOOP AT gt_correction_results ASSIGNING <fs_correction_results>
                              WHERE obj_name =
                              wa_zauct_errors_tmp-obj_name.
        <fs_correction_results>-line_no =
        <fs_correction_results>-line_no + v_header_lines.
      ENDLOOP.

    ENDIF.

    CLEAR: g_headflg.


    REFRESH : content_c,
              buffer,
              lt_lineindex.

* READ CONTENT OF PROGARM INTO AN INTERNAL TABLE.
    LOOP AT rtab INTO wa_rtab.
      wa_content_c = wa_rtab.
      APPEND wa_content_c TO content_c.

      CLEAR: wa_rtab,
             wa_content_c.
    ENDLOOP.

    CALL FUNCTION 'PRETTY_PRINTER'
      EXPORTING
        inctoo                  = space
      IMPORTING
        indentation_maybe_wrong = l_indentation_wrong
      TABLES
        ntext                   = buffer
        otext                   = content_c
      EXCEPTIONS
        enqueue_table_full      = 1
        include_enqueued        = 2
        include_readerror       = 3
        include_writeerror      = 4
        OTHERS                  = 5.
    IF sy-subrc NE 0.
      CLEAR wa_issue.
      wa_issue-name = wa_zauct_errors_tmp-pgname.
      wa_issue-message = 'Pretty print failed'.
      APPEND wa_issue TO i_issue.
      EXIT.
    ELSE.
      CALL FUNCTION 'RS_WORKBENCH_CUSTOMIZING'
        EXPORTING
          suppress_dialog = 'X'
        IMPORTING
          setting         = l_rseumod.

      IF l_rseumod-lowercase = 'X' AND l_rseumod-style NE space.
        l_case_mode = 'LOWER'.
      ELSEIF l_rseumod-lowercase = 'G' AND l_rseumod-style NE space.
        l_case_mode = 'HIKEY'.
      ELSEIF l_rseumod-style NE space.
        l_case_mode = 'UPPER'.
      ELSEIF l_rseumod-lowercase = 'L'.
        l_case_mode = 'LOKEY'.
      ELSE.
        l_case_mode = 'EMPTY'.
      ENDIF.
*{ Begin of Change by Rohit - 09/02/2016
*      IF l_case_mode <> 'EMPTY' AND l_rseumod-style IS NOT INITIAL.
*
*        LOOP AT buffer INTO wa_buffer.
*          wa_lineindex-index = sy-tabix.
*          APPEND wa_lineindex TO lt_lineindex.
*          CLEAR wa_lineindex.
*        ENDLOOP.
*
*        CALL METHOD go_hana->change_case_for_content
*          EXPORTING
*            p_case_mode = l_case_mode
*          CHANGING
*            p_content   = buffer[]
*            p_lineindex = lt_lineindex[].
*      ENDIF.
*} End of change by Rohit - 09/02/2016
    ENDIF.

*     Update the pretty printer changes to the programs
    INSERT REPORT wa_zauct_errors_tmp-pgname FROM buffer[].

    CLEAR: lv_object.
    lv_object = wa_zauct_errors_tmp-pgname.
    CALL FUNCTION 'REPS_OBJECT_ACTIVATE'
      EXPORTING
        object_name  = lv_object
*       OBJECT_TYPE  = 'REPS'
      EXCEPTIONS
        not_executed = 1
        OTHERS       = 2.

    IF sy-subrc <> 0.
      CLEAR wa_issue.
      wa_issue-name = wa_zauct_errors_tmp-pgname.
      wa_issue-message = 'Object could not be activated'.
      APPEND wa_issue TO i_issue.
    ENDIF.

*  REFRESHING INTERNAL TABLE RTAB.
    REFRESH rtab[].
*{ Begin of Change by Rohit - 09/02/2016
    "/ Creating range of objects to include it in output display table
    CLEAR wa_obj.
    wa_obj-sign = 'I'.
    wa_obj-option = 'EQ'.
    wa_obj-low = wa_zauct_errors_tmp-pgname.
    APPEND wa_obj TO gr_object.
    "/ Modify zdb_analysis_v74 Table
    MODIFY zdb_analysis_v74 FROM TABLE it_hana_corr.
*} End of change by Rohit - 09/02/2016
    COMMIT WORK.

  ENDMETHOD.                    "pretty_printer

  METHOD change_case_for_content.

    DATA l_tokens            TYPE sedi_tk.
    DATA l_tks_string_marker TYPE sedi_tk.
    DATA l_token             TYPE stokesx.
    DATA l_tk_string_marker  TYPE stokesx.
    DATA l_stmts             TYPE sedi_stm.
    DATA l_stmt              TYPE sstmnt.
    DATA l_tabix             TYPE sy-tabix.
    DATA l_lineindex         TYPE edlineindx.
    DATA l_conv_done         TYPE abap_bool.

    FIELD-SYMBOLS <f_line_char> TYPE string.
    FIELD-SYMBOLS <f_stmt>      TYPE sstmnt.
    DATA : lo_wb_editor TYPE REF TO cl_wb_editor.
    CREATE OBJECT lo_wb_editor.

    SCAN ABAP-SOURCE p_content
      TOKENS      INTO l_tokens
      STATEMENTS  INTO l_stmts
      PRESERVING IDENTIFIER ESCAPING
      WITH ANALYSIS
      WITHOUT TRMAC.

    IF sy-subrc <> 0.
      CLEAR wa_issue.
      wa_issue-name = wa_zauct_errors_tmp-pgname.
      wa_issue-message =
      'Failed to scan ABAP source from internal code table'.
      APPEND wa_issue TO i_issue.
      RETURN.
    ENDIF.

    l_tks_string_marker = l_tokens.

    "ignore:
    "M - scan_stmnt_type-macro_definition
    "B - scan_stmnt_type-opaque_body String Blobs
    "E - scan_stmt_type-native_sql
    LOOP AT l_stmts ASSIGNING <f_stmt> WHERE type NA 'MBE'.

* ignore read only lines for pretty printer
      IF lo_wb_editor->edit-app_disp <> abap_true. "display
        READ TABLE p_lineindex INTO l_lineindex INDEX <f_stmt>-trow.
        IF l_lineindex-noedit_flg IS NOT INITIAL.
          CONTINUE.
        ENDIF.
      ENDIF.

* qualify tokens for key indication - poor performance
      IF p_case_mode = 'HIKEY' OR p_case_mode = 'LOKEY'.
        IF lo_wb_editor->edit-app_id = 'DY' .
          CALL FUNCTION 'RS_QUALIFY_DYNPRO_TOKENS_STR'
            EXPORTING
              statement_type = <f_stmt>-type
              index_from     = <f_stmt>-from
              index_to       = <f_stmt>-to
              simplified     = abap_true
            CHANGING
              stokesx_tab    = l_tokens
            EXCEPTIONS
              OTHERS         = 0.
        ELSE. "abap
          CALL FUNCTION 'RS_QUALIFY_ABAP_TOKENS_STR'
            EXPORTING
              statement_type = <f_stmt>-type
              index_from     = <f_stmt>-from
              index_to       = <f_stmt>-to
              simplified     = abap_true
            CHANGING
              stokesx_tab    = l_tokens
            EXCEPTIONS
              OTHERS         = 0.
        ENDIF.
      ENDIF.

* upper/lower case conversion
      LOOP AT l_tokens INTO l_token FROM <f_stmt>-from TO <f_stmt>-to
        WHERE " ignore some operators and numbers for better performance
          NOT ( len1 = 1 AND str CA '=()0123456789<>+-*/' ).

        l_tabix = sy-tabix.

* ignore strings
        READ TABLE l_tks_string_marker INTO l_tk_string_marker INDEX
        l_tabix.
        CHECK l_tk_string_marker-type CA 'IL'
        "SCAN_TOKEN_TYPE-IDENTIFIER, SCAN_TOKEN_TYPE-LIST
          AND l_token-str NA ```'`. "ignore quotes

* change to upper or lower case
        CLEAR l_conv_done.

        CASE p_case_mode.
          WHEN 'HIKEY'.
            IF l_token-type <> sana_tok_word AND l_token-type <>
            sana_tok_keyword.

              IF ( l_token-type = sana_tok_field OR l_token-type =
              sana_tok_field_def )
                AND l_token-off3 > 0 AND l_token-off2 = 0
                "inline keyword check
                AND ( l_token-len1 = 4 OR l_token-len1 = 9 OR
                l_token-len1 = 5 OR l_token-len1 = 12 ).
                "length of inline keywords

                CALL METHOD go_hana->inline_keywords_conversion
                  EXPORTING
                    p_case_mode = p_case_mode
                  CHANGING
                    p_token     = l_token
                    p_done      = l_conv_done.
              ENDIF.

              IF l_conv_done IS INITIAL.
                TRANSLATE l_token-str TO LOWER CASE.
              ENDIF.
            ENDIF.

          WHEN 'LOKEY'.
            CASE l_token-type.
              WHEN sana_tok_word OR sana_tok_keyword.
                TRANSLATE l_token-str TO LOWER CASE.
              WHEN sana_tok_field OR sana_tok_field_def.
                IF l_token-off3 > 0 AND l_token-off2 = 0
                "inline keyword check
                  AND ( l_token-len1 = 4 OR l_token-len1 = 9 OR
                  l_token-len1 = 5 OR l_token-len1 = 12 ).
                  "length of inline keywords

                  CALL METHOD go_hana->inline_keywords_conversion
                    EXPORTING
                      p_case_mode = p_case_mode
                    CHANGING
                      p_token     = l_token
                      p_done      = l_conv_done.
                ENDIF.
            ENDCASE.

          WHEN 'LOWER'.
            TRANSLATE l_token-str TO LOWER CASE.
        ENDCASE.

* replace section in string
        READ TABLE p_content ASSIGNING <f_line_char> INDEX l_token-row.

        TRY.
            REPLACE SECTION OFFSET l_token-col LENGTH strlen(
            l_token-str ) OF <f_line_char> WITH l_token-str.
          CATCH cx_sy_range_out_of_bounds.
        ENDTRY.

      ENDLOOP.
    ENDLOOP.

  ENDMETHOD.                    "change_case_for_content

  METHOD inline_keywords_conversion.

    DATA word TYPE c LENGTH 60.

    IF   ( p_token-len1 = 5  AND p_token-str(5)  = 'VALUE' )
      OR ( p_token-len1 = 4  AND p_token-str(4)  = 'DATA' )
      OR ( p_token-len1 = 12 AND p_token-str(12) = 'FIELD-SYMBOL' )
      OR ( p_token-len1 = 9  AND p_token-str(9)  = 'REFERENCE' ).
      word = p_token-str.
      CASE p_case_mode.
        WHEN 'HIKEY'.
          TRANSLATE word+p_token-off3(p_token-len3) TO LOWER CASE.
        WHEN 'LOKEY'.
          TRANSLATE word(p_token-off3) TO LOWER CASE.
      ENDCASE.
      p_token-str = word.
      p_done = abap_true.
    ENDIF.

  ENDMETHOD.                    "inline_keywords_conversion

  METHOD version_create.

    DATA: l_e071            TYPE e071.

    IF g_version_type = 1 AND l_badi_flag =''.
      l_e071-pgmid =        'LIMU'.
      l_e071-object =       'REPS'.
    ENDIF.

    IF g_version_type = 2.
      l_e071-pgmid =       'LIMU'.
      l_e071-object   =    'FUNC'.
    ENDIF.

    IF g_version_type = 1 AND l_badi_flag ='X'.
      l_e071-pgmid =        'LIMU'.
      l_e071-object =       'METH'.

      g_version_object = l_method_prog.
    ENDIF.


    l_e071-obj_name           = g_version_object.


    CALL FUNCTION 'SVRS_AFTER_CHANGED_ONLINE_NEW'
      EXPORTING
        e071_entry              = l_e071
      EXCEPTIONS
        non_versionable_objtype = 1
        no_tadir_entry          = 2
        object_not_found        = 3
        object_not_locked       = 4
        OTHERS                  = 5.
    IF sy-subrc = 0.
      COMMIT WORK.
    ENDIF.

  ENDMETHOD.                    "version_create

  METHOD lock_object.

    "***** TRANSPORT CONCEPT ******
    CLEAR: wa_e071, lt_e071,go_further.
    " start of changes for methods
*{ Begin of Change by Rohit - 09/02/2016
*    IF l_badi_prog CS '=CM'.
*      wa_tadir-obj_name = l_method_prog.
*      wa_tadir-pgmid = 'LIMU'.
*      wa_tadir-object = 'METH'.
*    ENDIF.
    IF  lv_length EQ 30
    AND l_badi_prog+30(2) EQ 'CM'.
      wa_tadir-obj_name = l_method_prog.
      wa_tadir-pgmid = 'LIMU'.
      wa_tadir-object = 'METH'.
    ELSEIF lv_length < 30
       AND l_badi_prog CS '=CM'.
      wa_tadir-obj_name = l_method_prog.
      wa_tadir-pgmid = 'LIMU'.
      wa_tadir-object = 'METH'.
    ENDIF.
    " end of changes for methods
*} End of change by Rohit - 09/02/2016


    wa_e071-pgmid    = wa_tadir-pgmid.
    wa_e071-object   = wa_tadir-object.
    wa_e071-obj_name = wa_tadir-obj_name.
    wa_e071-lockflag = 'X'.


    wa_e071r = wa_e071.
    wa_e071-trkorr   = ls_request-trkorr.

    wa_issue-name = wa_e071-obj_name.


    CALL FUNCTION 'TRINT_LOCK_OBJECT'
      EXPORTING
        is_request_header = ls_request
        iv_edit           = 'X'
        iv_collect_mode   = 'X'
      CHANGING
        ct_messages       = lt_messages
        cs_object         = wa_e071
      EXCEPTIONS
        objlock_failed    = 1
        OTHERS            = 2.
    IF sy-subrc NE 0.
      wa_issue-message = 'OBJECT NOT LOCKED'.
      APPEND wa_issue TO i_issue.
    ENDIF.
    READ TABLE lt_messages INTO ls_message INDEX 1.
    IF sy-subrc = 0.
      CLEAR lv_message.
      MESSAGE ID ls_message-msgid TYPE 'S' NUMBER  ls_message-msgno
            WITH ls_message-msgv1 ls_message-msgv2 ls_message-msgv3
                 ls_message-msgv4 INTO lv_message.
      IF lv_message EQ ''.
        go_further = '1'.
        APPEND wa_e071 TO lt_e071.
      ELSEIF lv_message CS
      'REPAIRED OBJECTS CANNOT BE INCLUDED IN DEV./CORRECTION'.
        go_further = '2'.
      ELSE.
        go_further = '3'.
        wa_issue-message = lv_message.
        APPEND wa_issue TO i_issue.
      ENDIF.
    ELSE.
      go_further = '1'.
      APPEND wa_e071 TO lt_e071.
    ENDIF.

    IF go_further = '2'.
      wa_e071r-trkorr = ls_request_repair-trkorr.
      wa_issue-name = wa_e071r-obj_name.
      CALL FUNCTION 'TRINT_LOCK_OBJECT'
        EXPORTING
          is_request_header = ls_request_repair
          iv_edit           = 'X'
          iv_collect_mode   = 'X'
        CHANGING
          ct_messages       = lt_messages_repair
          cs_object         = wa_e071r
        EXCEPTIONS
          objlock_failed    = 1
          OTHERS            = 2.
      IF sy-subrc NE 0.
        wa_issue-message = 'OBJECT NOT LOCKED'.
        APPEND wa_issue TO i_issue.
      ENDIF.
      READ TABLE lt_messages_repair INTO ls_message_repair INDEX 1.
      IF sy-subrc = 0.
        CLEAR lv_message_repair.
        MESSAGE ID     ls_message_repair-msgid
          TYPE   'S'
          NUMBER ls_message_repair-msgno
          WITH   ls_message_repair-msgv1
                 ls_message_repair-msgv2
                 ls_message_repair-msgv3
                 ls_message_repair-msgv4 INTO lv_message_repair.

        IF lv_message EQ ''.
          go_further = '1'.
          APPEND wa_e071r TO lt_e071.
          ls_request-trkorr = ls_request_repair-trkorr.
        ELSE.
          go_further = '3'.
          wa_issue-message = lv_message_repair.
          APPEND wa_issue TO i_issue.
        ENDIF.
      ELSE.
        go_further = '1'.
        APPEND wa_e071r TO lt_e071.
        ls_request-trkorr = ls_request_repair-trkorr.
      ENDIF.
    ENDIF.

    IF go_further = '1'.
********************************************
      CALL FUNCTION 'TRINT_APPEND_COMM'
        EXPORTING
          wi_sel_e071        = 'X'
          wi_trkorr          = ls_request-trkorr   "L_TASK
        TABLES
          wt_e071            = lt_e071
        EXCEPTIONS
          e071k_append_error = 1
          e071_append_error  = 2
          trkorr_empty       = 3
          OTHERS             = 4.
      IF sy-subrc = 0.
**************************************************
*VERSION CREATION LOGIC START
**************************************************
        CLEAR:l_len1, iinclude,l_func.
        IF g_version_type = 2.
          l_len1  = strlen( wa_zauct_errors_tmp-pgname ).
          l_len1 = l_len1 - 3.
          inname  = wa_zauct_errors_tmp-pgname+0(l_len1).
          CONCATENATE 'SAP' inname INTO inname.
          l_len1 = l_len1 + 1.
          iinclude = wa_zauct_errors_tmp-pgname+l_len1(2).

          SELECT SINGLE funcname FROM tfdir INTO l_func WHERE pname
          EQ inname  AND include = iinclude.
          IF sy-subrc = 0.
            g_version_object = l_func.
          ELSE." added to take care of includes in FUGR other than FM
            g_version_type = 1.
          ENDIF.

        ENDIF.

        IF g_version_type = 1.
          g_version_object = wa_zauct_errors_tmp-pgname .
        ENDIF.

        SELECT * INTO TABLE lt_auctcopy FROM zauct_copy  WHERE pname
        = wa_zauct_errors_tmp-pgname.
        IF NOT sy-subrc IS INITIAL.
          go_hana->version_create( ).
          CLEAR lt_auctcopy.
          lt_auctcopy-pname =  wa_zauct_errors_tmp-pgname.
          APPEND lt_auctcopy TO lt_auctcopy[].
          MODIFY zauct_copy FROM TABLE lt_auctcopy.
        ENDIF.


**************************************************
*VERSION CREATION LOGIC END
**************************************************
*{ Begin of Change by Rohit - 09/02/2016 - comment pretty printer
        CALL METHOD go_hana->pretty_printer( ).
*} End of change by Rohit - 09/02/2016
      ENDIF.

    ENDIF.

  ENDMETHOD.                    "lock_object
  METHOD check_opcode57.
    "init internal tables & sturuc
    "begin of def_18
    DATA: v_line                TYPE i,
          v_str                 TYPE string,
          lv_code               TYPE string,
          lv_flag               TYPE c,
          lv_flag_close_comment TYPE c,
          lv_type_of_table      TYPE c,
          v_str2                TYPE string,
          v_str3                TYPE string.

    TYPES: BEGIN OF ty_rtab1,
             text(1000),
           END OF ty_rtab1.
    DATA: it_break TYPE TABLE OF ty_rtab1,
          p_line   TYPE i.

    DATA: rtab1              TYPE TABLE OF ty_rtab1,
          wa_rtab1           TYPE ty_rtab1,
          lt_code            TYPE TABLE OF ty_rtab1,
          wa_code            TYPE ty_rtab1,
          rtab41             TYPE TABLE OF ty_rtab1,
          wa_rtab41          TYPE ty_rtab1,
          wa_auct_err41      TYPE zauct_struct,
          lv_last_idx        TYPE i,
          lv_idx             TYPE i,
          lv_opcode41_offset TYPE i,
          lv_flag_opcode41   TYPE c,
          lv_new(1000)       TYPE c,
          lv_new_end(1000)   TYPE c,
          lv_index41         TYPE sy-tabix,
          lv_flag2_start     TYPE c.

    FIELD-SYMBOLS: <fs_code>     TYPE ty_rtab1,
                   <fs_auct_err> TYPE zauct_struct,
                   <fs_hana>     TYPE zdb_analysis_v74.

    DATA : wa_break LIKE LINE OF it_break,
           lv_len   TYPE i,
           lv_len1  TYPE i,
           lv_tlen  TYPE i,
           lv_tlen1 TYPE i.

    TYPES: BEGIN OF ty_code11,
             text(1000) TYPE c,
           END OF ty_code11.
    DATA:  lt_tab4   TYPE TABLE OF ty_code11.
    DATA: lwa_tab4 TYPE ty_code11.
    DATA: lv_pos1 TYPE sy-tabix.
    DATA: lv_pos2 TYPE sy-tabix.
    DATA: lv_flag1 TYPE flag.
    DATA: lv_flag2    TYPE flag,
          lv_scenerio TYPE char2.

    line = line + g_offset.
    READ TABLE it_hana INTO wa_hana WITH KEY
    session_id = wa_zauct_errors-session_id
    read_prog = wa_zauct_errors-pgname
    sub_program = wa_zauct_errors-sub_program
    opercd = wa_zauct_errors-error_type
    operation = wa_zauct_errors-error_message
    line_no = wa_zauct_errors-line_no.
    wa_hana-runn = 'X'.
    wa_zauct_errors-runn = 'X'.

    REFRESH : lt_tab4[].

    CLEAR: lv_pos1, lv_pos2.
    CLEAR: lv_flag2, lv_flag_close_comment.
    p_line = line.
    v_line = p_line.
    gv_line = p_line.

    READ TABLE rtab INTO wa_rtab INDEX p_line.
    CALL METHOD get_scenerio
      EXPORTING
        i_code     = wa_rtab-text
      IMPORTING
        e_scenerio = lv_scenerio.
    CLEAR: wa_rtab.
    IF lv_scenerio EQ '01'.
      CALL METHOD check_opcode57_2scene
        EXPORTING
          i_line = p_line.
*    ELSEIF lv_scenerio EQ '02'  .

    ELSEIF lv_scenerio EQ '03' OR lv_scenerio EQ '02'.
      REFRESH: lt_code.
      LOOP AT rtab INTO wa_rtab FROM p_line.

        v_line = sy-tabix.
        CLEAR v_str.
        v_str = wa_rtab-text.
        IF v_str IS INITIAL.
          CONTINUE.
        ENDIF.
        CONDENSE v_str.
        IF v_str(1) EQ ca_starpp OR v_str(1) EQ ca_astpp.
          APPEND wa_rtab TO lt_code.
        ELSE.

          CLEAR: v_str, v_str1.
          SPLIT wa_rtab-text AT ca_astpp  INTO v_str v_str1.
          TRANSLATE wa_rtab-text TO UPPER CASE.
          TRANSLATE v_str TO UPPER CASE.
          IF NOT v_str1 IS INITIAL.
            FIND FIRST OCCURRENCE OF ca_astpp IN wa_rtab-text MATCH OFFSET
            lv_idx.
            lv_idx = lv_idx + 1.
            wa_rtab-text+lv_idx = v_str1.
          ELSE.
            wa_rtab-text = v_str.
          ENDIF.

          SHIFT v_str LEFT DELETING LEADING space.
          CHECK NOT v_str IS INITIAL.
          IF v_str CS ca_dotpp.
            SPLIT v_str AT ca_dotpp INTO v_str v_str1.
            CONCATENATE lv_code v_str INTO lv_code SEPARATED BY space.
            REPLACE FIRST OCCURRENCE OF '.' IN wa_rtab WITH ' '.
            APPEND wa_rtab TO lt_code.
            EXIT.
          ELSE.
            CONCATENATE lv_code v_str INTO lv_code SEPARATED BY space.
            APPEND wa_rtab TO lt_code.
          ENDIF.
        ENDIF.
      ENDLOOP.

** Check if error is real**
      CONDENSE lv_code.
      TRANSLATE lv_code TO UPPER CASE.


      CLEAR:lv_pos1, lv_pos2.
      IF lv_flag = ''.
        TRANSLATE lv_code TO UPPER CASE.
        SPLIT lv_code AT space INTO TABLE rtab1.
        DELETE rtab1 WHERE text IS INITIAL.
        CLEAR lv_code.

        LOOP AT rtab1 INTO wa_rtab1.
          CONCATENATE lv_code wa_rtab1-text INTO lv_code SEPARATED BY
          space.
        ENDLOOP.
        CONDENSE lv_code.

        " select single UP TO 1 ROWS.
        CLEAR: lv_flag1.

        IF lv_code CS 'SELECT SINGLE'.
          REPLACE FIRST OCCURRENCE OF 'SELECT SINGLE' IN lv_code WITH
            'SELECT'.
          LOOP AT lt_code ASSIGNING <fs_code>.
            CLEAR v_str.
            v_str = <fs_code>-text.
            CONDENSE v_str.
            IF v_str IS INITIAL.
              CONTINUE.
            ENDIF.
            IF v_str(1) EQ ca_starpp OR v_str(1) EQ ca_astpp.
              CONTINUE.
            ENDIF.
**** Begin of changes by Kanika - 16/03/2016
            IF <fs_code>-text CS 'SELECT SINGLE'.
              REPLACE FIRST OCCURRENCE OF 'SELECT SINGLE' IN
              <fs_code>-text WITH
            'SELECT'.
*            IF v_str CS 'SELECT SINGLE'.
*              REPLACE FIRST OCCURRENCE OF 'SELECT SINGLE' IN
*              v_str WITH
*            'SELECT'.
**** End of changes by Kanika - 16/03/2016
              EXIT.
            ENDIF.
          ENDLOOP.
          CONDENSE lv_code.
          SPLIT lv_code AT '' INTO TABLE lt_tab4[].
          DELETE lt_tab4 WHERE text = ''.
*        READ TABLE lt_tab4 INTO lwa_tab4 WITH KEY text = 'FROM'.
*        IF sy-subrc = 0.
*          lv_pos1 = sy-tabix.
*        ENDIF.
*        CLEAR: lwa_tab4.
*        READ TABLE lt_tab4 INTO lwa_tab4 WITH KEY text = 'INTO'.
*        IF sy-subrc = 0.
*          lv_pos2 = sy-tabix.
*        ELSE.
*          lv_pos2 = lv_pos1.
*        ENDIF.

          CLEAR: lv_code.
          LOOP AT lt_tab4 INTO lwa_tab4.
            CONCATENATE lv_code lwa_tab4-text INTO lv_code SEPARATED BY
            space.
          ENDLOOP.
          CONCATENATE lv_code 'ORDER BY PRIMARY KEY' INTO lv_code
          SEPARATED
          BY space.
          lv_flag1 = 'X'.

          wa_code-text = 'ORDER BY PRIMARY KEY'.
          APPEND wa_code TO lt_code.

******Additon made - For All Enteries Clause******
*****Start of code change for select for all entries issue
        ELSEIF lv_code CS 'SELECT' AND lv_code CS 'FOR ALL ENTRIES' AND
        v_fae IS INITIAL.
          IF NOT v_keys2 IS INITIAL.
            lv_flag2 = 'X'.
          ELSE.
            CLEAR: wa_skipped_code.
            wa_skipped_code-name = wa_zauct_errors-pgname.
            wa_skipped_code-old_line = wa_zauct_errors-line_no.
            wa_skipped_code-new_line = line.
            wa_skipped_code-opcode = wa_zauct_errors-error_type.
            wa_skipped_code-reason =
            'Code fix skipped as no primary key field in select list'.
            APPEND wa_skipped_code TO gt_skipped_code.
            EXIT.
          ENDIF.
        ELSE.
****End of code change for select for all entries issue
          CONCATENATE lv_code 'ORDER BY PRIMARY KEY' INTO lv_code
          SEPARATED
          BY space.
          wa_code-text = 'ORDER BY PRIMARY KEY'.
          APPEND wa_code TO lt_code.
        ENDIF.
        IF lv_code NS ca_dotpp.
          CONCATENATE lv_code ca_dotpp INTO lv_code.
        ENDIF.

        DESCRIBE TABLE lt_code LINES lv_last_idx.
        READ TABLE lt_code ASSIGNING <fs_code> INDEX lv_last_idx.
        IF sy-subrc = 0.
          CONCATENATE <fs_code>-text '.' INTO <fs_code>-text.
        ENDIF.


        IF lv_flag2 IS INITIAL.
          INSERT comment_start INTO rtab INDEX p_line.
          p_line = p_line + 1.
          v_line = v_line + 1.

          IF lv_flag_opcode41 EQ 'X'.
            INSERT lv_new INTO rtab INDEX p_line.
            p_line = p_line + 1.
            v_line = v_line + 1.
            lv_opcode41_offset = lv_opcode41_offset + 1.
          ENDIF.

          lv_flag_close_comment = 'X'.

          LOOP AT rtab INTO wa_rtab FROM p_line TO v_line.
            CONCATENATE '*'  wa_rtab-text INTO wa_rtab-text.
            MODIFY rtab FROM wa_rtab.
          ENDLOOP.
        ENDIF.
        CLEAR rtab1[].

        IF lv_flag2 IS INITIAL.
          rtab1[] = lt_code[].

        ENDIF.

        CLEAR : lv_tlen , lv_len , lv_len1 , lv_tlen1.
        IF lv_flag1 = 'X'.
          lv_code = 'EXIT.'.
          APPEND lv_code TO rtab1.
          lv_code = 'ENDSELECT.'.
          APPEND lv_code TO rtab1.
        ENDIF.

        IF lv_flag_close_comment = 'X'.
          APPEND comment_end TO rtab1.
          v_line = v_line + 1.
        ENDIF.

        DESCRIBE TABLE rtab1 LINES lv_tlen.
        INSERT LINES OF rtab1 INTO rtab INDEX v_line .


        IF lv_tlen GT 0.
***Code change for select For all entries
          IF NOT v_keys2 IS INITIAL.
            g_offset = g_offset + lv_tlen.
            gv_initial = lv_tlen.
          ELSE.
***end of changes
            g_offset = g_offset + 1 + lv_tlen.
            gv_initial = 1 + lv_tlen.
          ENDIF.

          wa_hana-actual_corr = 'Y'.
          wa_zauct_errors-actual_corr = 'Y'.
          g_corr_done = 'X'.

          CLEAR: wa_correction_results.
          wa_correction_results-obj_name = wa_zauct_errors-obj_name.
          wa_correction_results-sub_program = wa_zauct_errors-sub_program.
          wa_correction_results-line_org = wa_zauct_errors-line_no.
          wa_correction_results-line_no = v_line.
          wa_correction_results-opcode = wa_zauct_errors-error_type.
          APPEND wa_correction_results TO gt_correction_results.

        ELSE.
          CLEAR: wa_skipped_code.
          wa_skipped_code-name = wa_zauct_errors-pgname.
          wa_skipped_code-old_line = wa_zauct_errors-line_no.
          wa_skipped_code-new_line = line.
          wa_skipped_code-opcode = wa_zauct_errors-error_type.
          wa_skipped_code-reason =
  'Code fix skipped as no correction could be performed at given line'.
          APPEND wa_skipped_code TO gt_skipped_code.
        ENDIF.
        CLEAR : lv_tlen.
      ENDIF.
    ELSE.
      CLEAR: wa_skipped_code.
      wa_skipped_code-name = wa_zauct_errors-pgname.
      wa_skipped_code-old_line = wa_zauct_errors-line_no.
      wa_skipped_code-new_line = line.
      wa_skipped_code-opcode = wa_zauct_errors-error_type.
      wa_skipped_code-reason =
'Code fix skipped as no correction could be performed at given line'.
      APPEND wa_skipped_code TO gt_skipped_code.
    ENDIF.
    "end of def_18
  ENDMETHOD.

  METHOD check_opcode57_2scene.
    "begin of def_18
    DATA: v_line                TYPE i,
          v_str                 TYPE string,
          lv_code               TYPE string,
          lv_flag               TYPE c,
          lv_flag_close_comment TYPE c,
          lv_type_of_table      TYPE c,
          v_str2                TYPE string,
          v_str3                TYPE string.

    TYPES: BEGIN OF ty_rtab1,
             text(1000),
           END OF ty_rtab1.
    DATA: it_break TYPE TABLE OF ty_rtab1,
          p_line   TYPE i.

    DATA: rtab1              TYPE TABLE OF ty_rtab1,
          wa_rtab1           TYPE ty_rtab1,
          lt_code            TYPE TABLE OF ty_rtab1,
          wa_code            TYPE ty_rtab1,
          rtab41             TYPE TABLE OF ty_rtab1,
          wa_rtab41          TYPE ty_rtab1,
          wa_auct_err41      TYPE zauct_struct,
          lv_last_idx        TYPE i,
          lv_idx             TYPE i,
          lv_opcode41_offset TYPE i,
          lv_flag_opcode41   TYPE c,
          lv_new(1000)       TYPE c,
          lv_new_end(1000)   TYPE c,
          lv_index41         TYPE sy-tabix,
          lv_flag2_start     TYPE c.

    FIELD-SYMBOLS: <fs_code>     TYPE ty_rtab1,
                   <fs_auct_err> TYPE zauct_struct,
                   <fs_hana>     TYPE zdb_analysis_v74.

    DATA : wa_break LIKE LINE OF it_break,
           lv_len   TYPE i,
           lv_len1  TYPE i,
           lv_tlen  TYPE i,
           lv_tlen1 TYPE i.

    TYPES: BEGIN OF ty_code11,
             text(1000) TYPE c,
           END OF ty_code11.
    DATA:  lt_tab4   TYPE TABLE OF ty_code11.
    DATA: lwa_tab4 TYPE ty_code11.
    DATA: lv_pos1 TYPE sy-tabix.
    DATA: lv_pos2 TYPE sy-tabix.
    DATA: lv_flag1 TYPE flag.
    DATA: lv_flag2 TYPE flag.

    line = i_line.
    READ TABLE it_hana INTO wa_hana WITH KEY
    session_id = wa_zauct_errors-session_id
    read_prog = wa_zauct_errors-pgname
    sub_program = wa_zauct_errors-sub_program
    opercd = wa_zauct_errors-error_type
    operation = wa_zauct_errors-error_message
    line_no = wa_zauct_errors-line_no.
    wa_hana-runn = 'X'.
    wa_zauct_errors-runn = 'X'.

    REFRESH : lt_tab4[].
    CLEAR: lv_pos1, lv_pos2.
    CLEAR: lv_flag2, lv_flag_close_comment.
    p_line = line.
    v_line = p_line.
    gv_line = p_line.

    REFRESH: lt_code.

    LOOP AT rtab INTO wa_rtab FROM p_line.

      v_line = sy-tabix.
      CLEAR v_str.
      v_str = wa_rtab-text.
      IF v_str IS INITIAL.
        CONTINUE.
      ENDIF.
      CONDENSE v_str.
      IF v_str(1) EQ ca_starpp OR v_str(1) EQ ca_astpp.
        APPEND wa_rtab TO lt_code.
      ELSE.

        CLEAR: v_str, v_str1.
        SPLIT wa_rtab-text AT ca_astpp  INTO v_str v_str1.
        TRANSLATE wa_rtab-text TO UPPER CASE.
        TRANSLATE v_str TO UPPER CASE.
        IF NOT v_str1 IS INITIAL.
          FIND FIRST OCCURRENCE OF ca_astpp IN wa_rtab-text MATCH OFFSET
          lv_idx.
          lv_idx = lv_idx + 1.
          wa_rtab-text+lv_idx = v_str1.
        ELSE.
          wa_rtab-text = v_str.
        ENDIF.

        SHIFT v_str LEFT DELETING LEADING space.
        CHECK NOT v_str IS INITIAL.
        IF v_str CS ca_dotpp.
          SPLIT v_str AT ca_dotpp INTO v_str v_str1.
          CONCATENATE lv_code v_str INTO lv_code SEPARATED BY space.
          REPLACE FIRST OCCURRENCE OF '.' IN wa_rtab WITH ' '.
          APPEND wa_rtab TO lt_code.
          EXIT.
        ELSE.
          CONCATENATE lv_code v_str INTO lv_code SEPARATED BY space.
          APPEND wa_rtab TO lt_code.
        ENDIF.
      ENDIF.
    ENDLOOP.

** Check if error is real**
    CONDENSE lv_code.
    TRANSLATE lv_code TO UPPER CASE.
    IF NOT ( lv_code CS 'SELECT' AND lv_code CS 'FROM' ).
      CLEAR: wa_skipped_code.
      wa_skipped_code-name = wa_zauct_errors-pgname.
      wa_skipped_code-old_line = wa_zauct_errors-line_no.
      wa_skipped_code-new_line = line.
      wa_skipped_code-opcode = wa_zauct_errors-error_type.
      wa_skipped_code-reason =
      'Code fix skipped as the code does not contain SELECT statement'.
      APPEND wa_skipped_code TO gt_skipped_code.
      EXIT.
    ENDIF.
** End Check **
******Changes Made for select single issue
    IF lv_code CS 'SELECT SINGLE'.
      IF lv_code CS 'SELECT SINGLE *'.
        IF lv_code CS 'CLIENT SPECIFIED'.
          CLEAR: wa_skipped_code.
          wa_skipped_code-name = wa_zauct_errors-pgname.
          wa_skipped_code-old_line = wa_zauct_errors-line_no.
          wa_skipped_code-new_line = line.
          wa_skipped_code-opcode = wa_zauct_errors-error_type.
          wa_skipped_code-reason =
'Code fix skipped as it contains SELECT SINGLE * with CLIENT SPECIFIED'
          .
          APPEND wa_skipped_code TO gt_skipped_code.
          EXIT.
        ENDIF.
      ELSE.
        CLEAR: wa_skipped_code.
        wa_skipped_code-name = wa_zauct_errors-pgname.
        wa_skipped_code-old_line = wa_zauct_errors-line_no.
        wa_skipped_code-new_line = line.
        wa_skipped_code-opcode = wa_zauct_errors-error_type.
        wa_skipped_code-reason =
'Code fix skipped as it contains SELECT SINGLE with fields list provi' &
'ded'
        .
        APPEND wa_skipped_code TO gt_skipped_code.
        EXIT.
      ENDIF.
    ENDIF.
******End of change for select single issue
** Check for the order by existence**
    "Rest of the checks already added

    IF lv_code CS 'ORDER BY'.
      CLEAR: wa_skipped_code.
      wa_skipped_code-name = wa_zauct_errors-pgname.
      wa_skipped_code-old_line = wa_zauct_errors-line_no.
      wa_skipped_code-new_line = line.
      wa_skipped_code-opcode = wa_zauct_errors-error_type.
      wa_skipped_code-reason =
      'Code fix skipped as it already contains ORDER BY clause'.
      APPEND wa_skipped_code TO gt_skipped_code.
      EXIT.
    ENDIF.
**End Check**


**** Begin of changes by Kanika - 16/3/2016
*    IF lv_code CS 'SELECT COUNT(*)'.
    lv_temp = lv_code.
    CONDENSE lv_temp NO-GAPS.
    IF lv_temp CS 'SELECTCOUNT(*)'.
      CLEAR : lv_temp.
**** End of changes by Kanika - 16/3/2016
      CLEAR: wa_skipped_code.
      wa_skipped_code-name = wa_zauct_errors-pgname.
      wa_skipped_code-old_line = wa_zauct_errors-line_no.
      wa_skipped_code-new_line = line.
      wa_skipped_code-opcode = wa_zauct_errors-error_type.
      wa_skipped_code-reason =
      'Code fix skipped as it contains SELECT COUNT(*)'.
      APPEND wa_skipped_code TO gt_skipped_code.
      EXIT.
    ENDIF.

    CLEAR:lv_pos1, lv_pos2.
    IF lv_flag = ''.
      TRANSLATE lv_code TO UPPER CASE.
      SPLIT lv_code AT space INTO TABLE rtab1.
      DELETE rtab1 WHERE text IS INITIAL.
      CLEAR lv_code.

      LOOP AT rtab1 INTO wa_rtab1.
        CONCATENATE lv_code wa_rtab1-text INTO lv_code SEPARATED BY
        space.
      ENDLOOP.
      CONDENSE lv_code.

      " select single UP TO 1 ROWS.
      CLEAR: lv_flag1.

      IF lv_code CS 'SELECT SINGLE'.
        REPLACE FIRST OCCURRENCE OF 'SELECT SINGLE' IN lv_code WITH
          'SELECT'.
        LOOP AT lt_code ASSIGNING <fs_code>.
          CLEAR v_str.
          v_str = <fs_code>-text.
          CONDENSE v_str.
          IF v_str IS INITIAL.
            CONTINUE.
          ENDIF.
          IF v_str(1) EQ ca_starpp OR v_str(1) EQ ca_astpp.
            CONTINUE.
          ENDIF.
**** Begin of changes by Kanika - 16/03/2016
*          IF <fs_code>-text CS 'SELECT SINGLE'.
*            REPLACE FIRST OCCURRENCE OF 'SELECT SINGLE' IN
*            <fs_code>-text WITH
*          'SELECT'.
          IF v_str CS 'SELECT SINGLE'.
            REPLACE FIRST OCCURRENCE OF 'SELECT SINGLE' IN
            v_str WITH
          'SELECT *'.
**** End of changes by Kanika - 16/03/2016
            EXIT.
          ENDIF.
        ENDLOOP.
        CONDENSE lv_code.
        SPLIT lv_code AT '' INTO TABLE lt_tab4[].
        DELETE lt_tab4 WHERE text = ''.
        READ TABLE lt_tab4 INTO lwa_tab4 WITH KEY text = 'FROM'.
        IF sy-subrc = 0.
          lv_pos1 = sy-tabix.
        ENDIF.
        CLEAR: lwa_tab4.
        READ TABLE lt_tab4 INTO lwa_tab4 WITH KEY text = 'INTO'.
        IF sy-subrc = 0.
          lv_pos2 = sy-tabix.
        ELSE.
          lv_pos2 = lv_pos1.
        ENDIF.
        IF lv_pos1 > lv_pos2.
          lwa_tab4 = 'UP TO 1 ROWS'.
          INSERT lwa_tab4 INTO lt_tab4 INDEX  lv_pos2.
        ELSE.
          lwa_tab4 = 'UP TO 1 ROWS'.
          INSERT lwa_tab4 INTO lt_tab4 INDEX  lv_pos1.
        ENDIF.
        LOOP AT lt_code ASSIGNING <fs_code>.
          CLEAR v_str.
          v_str = <fs_code>-text.
          CONDENSE v_str.
          IF v_str IS INITIAL.
            CONTINUE.
          ENDIF.
          IF v_str(1) EQ ca_starpp OR v_str(1) EQ ca_astpp.
            CONTINUE.
          ENDIF.
          IF v_str CS ca_astpp.
            SPLIT v_str AT ca_astpp INTO v_str v_str1.
          ENDIF.
          IF v_str CS 'SELECT SINGLE *'.
            REPLACE FIRST OCCURRENCE OF 'SELECT SINGLE *' IN <fs_code>-text WITH
              'SELECT *'.
          ENDIF.
          IF lv_pos1 > lv_pos2.
            IF v_str CS 'INTO'.
              REPLACE FIRST OCCURRENCE OF 'INTO' IN <fs_code>-text WITH
              'UP TO 1 ROWS INTO'.
              EXIT.
            ENDIF.
          ELSE.
            IF v_str CS 'FROM'.
              REPLACE FIRST OCCURRENCE OF 'FROM' IN <fs_code>-text WITH
              'UP TO 1 ROWS FROM'.
              EXIT.
            ENDIF.
          ENDIF.
        ENDLOOP.
        CLEAR: lv_code.
        LOOP AT lt_tab4 INTO lwa_tab4.
          CONCATENATE lv_code lwa_tab4-text INTO lv_code SEPARATED BY
          space.
        ENDLOOP.
        CONCATENATE lv_code 'ORDER BY PRIMARY KEY' INTO lv_code
        SEPARATED
        BY space.
        lv_flag1 = 'X'.

        wa_code-text = 'ORDER BY PRIMARY KEY'.
        APPEND wa_code TO lt_code.

******Additon made - For All Enteries Clause******
*****Start of code change for select for all entries issue
      ELSEIF lv_code CS 'SELECT' AND lv_code CS 'FOR ALL ENTRIES' AND
      v_fae IS INITIAL.
        IF NOT v_keys2 IS INITIAL.
          lv_flag2 = 'X'.
        ELSE.
          CLEAR: wa_skipped_code.
          wa_skipped_code-name = wa_zauct_errors-pgname.
          wa_skipped_code-old_line = wa_zauct_errors-line_no.
          wa_skipped_code-new_line = line.
          wa_skipped_code-opcode = wa_zauct_errors-error_type.
          wa_skipped_code-reason =
          'Code fix skipped as no primary key field in select list'.
          APPEND wa_skipped_code TO gt_skipped_code.
          EXIT.
        ENDIF.
      ELSE.
****End of code change for select for all entries issue
        CONCATENATE lv_code 'ORDER BY PRIMARY KEY' INTO lv_code
        SEPARATED
        BY space.
        wa_code-text = 'ORDER BY PRIMARY KEY'.
        APPEND wa_code TO lt_code.
      ENDIF.
      IF lv_code NS ca_dotpp.
        CONCATENATE lv_code ca_dotpp INTO lv_code.
      ENDIF.

      DESCRIBE TABLE lt_code LINES lv_last_idx.
      READ TABLE lt_code ASSIGNING <fs_code> INDEX lv_last_idx.
      IF sy-subrc = 0.
        CONCATENATE <fs_code>-text '.' INTO <fs_code>-text.
      ENDIF.

****End of Additon made - For All Enteries Clause***
      " Check possibility of Opcode 41 in this case
      CLEAR: lv_flag_opcode41,
             lv_opcode41_offset,
             lv_new,
             lv_new_end,
             lv_index41,
             lv_flag2_start.
      READ TABLE i_zauct_errors INTO wa_auct_err41 WITH KEY
      session_id = wa_zauct_errors-session_id
      pgname = wa_zauct_errors-pgname
      sub_program = wa_zauct_errors-sub_program
      error_type = 41
      line_no = wa_zauct_errors-line_no
      runn = ''.
      IF sy-subrc = 0.
        IF lv_code CS 'FOR ALL ENTRIES'.
          IF lv_code CS 'INTO TABLE' OR lv_code CS
          'INTO CORRESPONDING FIELDS OF TABLE'
            OR lv_code CS 'APPENDING TABLE' OR lv_code CS
            'APPENDING CORRESPONDING FIELDS OF TABLE'.

            lv_flag_opcode41 = 'X'.

            REFRESH: rtab41[].
            SPLIT lv_code AT space INTO TABLE rtab41.
            DELETE rtab41 WHERE text IS INITIAL.
            READ TABLE rtab41 WITH KEY text = 'ENTRIES' TRANSPORTING NO
            FIELDS.
            IF sy-subrc = 0.
              lv_index41 = sy-tabix + 2.
              CLEAR wa_rtab41.
              READ TABLE rtab41 INTO wa_rtab41 INDEX lv_index41.
              CONDENSE wa_rtab41-text.
              IF wa_rtab41-text CS '[]'.
                CONCATENATE 'IF NOT' wa_rtab41-text 'IS INITIAL.' INTO
             lv_new SEPARATED BY space.
              ELSE.
                CONCATENATE wa_rtab41-text '[]' INTO wa_rtab41-text.
                CONCATENATE 'IF NOT' wa_rtab41-text 'IS INITIAL.' INTO
             lv_new SEPARATED BY space.
              ENDIF.
            ENDIF.

            lv_new_end = 'ENDIF.'.
          ENDIF.

        ENDIF.
      ENDIF.

      IF lv_flag2 IS INITIAL.
        INSERT comment_start INTO rtab INDEX p_line.
        p_line = p_line + 1.
        v_line = v_line + 1.

        IF lv_flag_opcode41 EQ 'X'.
          INSERT lv_new INTO rtab INDEX p_line.
          p_line = p_line + 1.
          v_line = v_line + 1.
          lv_opcode41_offset = lv_opcode41_offset + 1.
        ENDIF.

        lv_flag_close_comment = 'X'.

        LOOP AT rtab INTO wa_rtab FROM p_line TO v_line.
          CONCATENATE '*'  wa_rtab-text INTO wa_rtab-text.
          MODIFY rtab FROM wa_rtab.
        ENDLOOP.
      ENDIF.
      CLEAR rtab1[].

      IF lv_flag2 IS INITIAL.
        rtab1[] = lt_code[].

      ENDIF.

*If internal table is of type sorted table then no need to put sort by
*statement
      CLEAR lv_type_of_table.
      IF lv_code CS 'INTO TABLE' OR lv_code CS
      'INTO CORRESPONDING FIELDS OF TABLE'
        OR lv_code CS 'APPENDING TABLE' OR lv_code CS
        'APPENDING CORRESPONDING FIELDS OF TABLE'.

        IF lv_code NS 'APPENDING'.
          CLEAR: v_str.
          REFRESH: lt_tab4[].
          SPLIT lv_code AT '' INTO TABLE lt_tab4[].
          DELETE lt_tab4 WHERE text = ''.
          READ TABLE lt_tab4 INTO lwa_tab4 WITH KEY text = 'TABLE'.
          READ TABLE lt_tab4 INTO lwa_tab4 INDEX sy-tabix + 1.
          IF sy-subrc = 0.
            v_str = lwa_tab4-text.
            TRANSLATE v_str TO UPPER CASE.
            REPLACE ALL OCCURRENCES OF '[' IN v_str WITH ''.
            REPLACE ALL OCCURRENCES OF ']' IN v_str WITH ''.
            CONDENSE v_str.
            LOOP AT rtab INTO wa_rtab.
              CLEAR: v_str1,v_str2, v_str3.
              v_str1 = wa_rtab-text.
              CONDENSE v_str1.
              IF v_str1 IS INITIAL.
                CONTINUE.
              ENDIF.
              IF v_str1(1) EQ ca_starpp OR v_str1(1) EQ ca_astpp.
                CONTINUE.
              ENDIF.
              TRANSLATE v_str1 TO UPPER CASE.
              REPLACE ALL OCCURRENCES OF '[' IN v_str1 WITH ''.
              REPLACE ALL OCCURRENCES OF ']' IN v_str1 WITH ''.
              CONDENSE v_str1.
              CONCATENATE v_str 'TYPE' INTO v_str2 SEPARATED BY space.
              CONCATENATE v_str 'LIKE' INTO v_str3 SEPARATED BY space.
              IF v_str1 CS v_str2 OR v_str1 CS v_str3.
                IF v_str1 CS 'SORTED TABLE OF'.
                  lv_type_of_table = 'S'.
                  EXIT.
                ENDIF.
              ELSE.
                CONTINUE.
              ENDIF.

            ENDLOOP.
          ENDIF.
        ENDIF.

        IF NOT v_keys2 IS INITIAL
            AND lv_type_of_table NE 'S'.
          APPEND comment_start TO rtab1.
          APPEND v_keys2 TO rtab1.
          lv_flag_close_comment = 'X'.
          lv_flag2_start = 'X'.
        ENDIF.

        IF lv_flag_opcode41 EQ 'X' AND lv_flag2 EQ 'X'.
          INSERT comment_start INTO rtab INDEX p_line.
          p_line = p_line + 1.
          v_line = v_line + 1.
          INSERT lv_new INTO rtab INDEX p_line.
          p_line = p_line + 1.
          v_line = v_line + 1.
          INSERT comment_end INTO rtab INDEX p_line.
          p_line = p_line + 1.
          v_line = v_line + 1.
          lv_opcode41_offset = lv_opcode41_offset + 3.
          IF lv_flag2_start EQ 'X'.
            APPEND lv_new_end TO rtab1.
          ELSE.
            APPEND comment_start TO rtab1.
            APPEND lv_new_end TO rtab1.
            lv_flag_close_comment = 'X'.
          ENDIF.

        ENDIF.

      ENDIF.


      CLEAR : lv_tlen , lv_len , lv_len1 , lv_tlen1.
      IF lv_flag1 = 'X'.
        lv_code = 'ENDSELECT.'.
        APPEND lv_code TO rtab1.
      ENDIF.

      IF lv_flag_opcode41 EQ 'X'
        AND lv_flag2 IS INITIAL.
        APPEND lv_new_end TO rtab1.
      ENDIF.

      IF lv_flag_close_comment = 'X'.
        APPEND comment_end TO rtab1.
        v_line = v_line + 1.
      ENDIF.

      DESCRIBE TABLE rtab1 LINES lv_tlen.
      INSERT LINES OF rtab1 INTO rtab INDEX v_line .


      IF lv_tlen GT 0.
***Code change for select For all entries
        IF NOT v_keys2 IS INITIAL.
          g_offset = g_offset + lv_tlen.
          gv_initial = lv_tlen.
        ELSE.
***end of changes
          g_offset = g_offset + 1 + lv_tlen.
          gv_initial = 1 + lv_tlen.
        ENDIF.

        IF lv_flag_opcode41 EQ 'X'.
          g_offset = g_offset + lv_opcode41_offset.
          IF <fs_auct_err> IS ASSIGNED.
            UNASSIGN <fs_auct_err>.
          ENDIF.
          READ TABLE i_zauct_errors ASSIGNING <fs_auct_err> WITH KEY
          session_id = wa_zauct_errors-session_id
          pgname = wa_zauct_errors-pgname
          sub_program = wa_zauct_errors-sub_program
          error_type = 41
          line_no = wa_zauct_errors-line_no
          runn = ''.
          IF sy-subrc = 0.
            <fs_auct_err>-runn = 'X'.
            <fs_auct_err>-actual_corr = 'Y'.
            READ TABLE it_hana ASSIGNING <fs_hana> WITH KEY
            session_id = wa_zauct_errors-session_id
            read_prog = wa_zauct_errors-pgname
            sub_program = wa_zauct_errors-sub_program
            opercd = 41
            operation = wa_zauct_errors-error_message
            line_no = wa_zauct_errors-line_no.
            IF sy-subrc = 0.
              <fs_hana>-runn = 'X'.
              <fs_hana>-detected = 'X'.
              <fs_hana>-actual_corr = 'Y'.
              MODIFY zdb_analysis_v74 FROM <fs_hana>.
            ENDIF.

            CLEAR: wa_correction_results.
            wa_correction_results-obj_name = wa_zauct_errors-obj_name.
            wa_correction_results-sub_program =
            wa_zauct_errors-sub_program.
            wa_correction_results-line_org = wa_zauct_errors-line_no.
            wa_correction_results-line_no = v_line.
            wa_correction_results-opcode = 41.
            APPEND wa_correction_results TO gt_correction_results.
          ENDIF.
        ENDIF.

        wa_hana-actual_corr = 'Y'.
        wa_zauct_errors-actual_corr = 'Y'.
        g_corr_done = 'X'.

        CLEAR: wa_correction_results.
        wa_correction_results-obj_name = wa_zauct_errors-obj_name.
        wa_correction_results-sub_program = wa_zauct_errors-sub_program.
        wa_correction_results-line_org = wa_zauct_errors-line_no.
        wa_correction_results-line_no = v_line.
        wa_correction_results-opcode = wa_zauct_errors-error_type.
        APPEND wa_correction_results TO gt_correction_results.

      ELSE.
        CLEAR: wa_skipped_code.
        wa_skipped_code-name = wa_zauct_errors-pgname.
        wa_skipped_code-old_line = wa_zauct_errors-line_no.
        wa_skipped_code-new_line = line.
        wa_skipped_code-opcode = wa_zauct_errors-error_type.
        wa_skipped_code-reason =
'Code fix skipped as no correction could be performed at given line'.
        APPEND wa_skipped_code TO gt_skipped_code.
      ENDIF.

      CLEAR : lv_tlen.
    ENDIF.
    "end of def_18
  ENDMETHOD.

  METHOD get_scenerio.
    "begin of def_18
    "Declaration
    CONSTANTS : lc_select_star   TYPE string VALUE 'SELECT SINGLE *',
                lc_select_upto   TYPE string VALUE 'SELECT * UP TO',
                lc_select_single TYPE string VALUE 'SELECT SINGLE'.
    "check cases & return
    IF i_code IS NOT INITIAL.
      IF i_code CS lc_select_star.
        e_scenerio  = '01'.
      ELSEIF i_code CS lc_select_upto.
        e_scenerio  = '02'.
      ELSEIF i_code CS lc_select_single.
        e_scenerio  = '03'  .
      ENDIF.
    ENDIF.
    "end of def_18
  ENDMETHOD.

ENDCLASS.                    "lcl_hana_corrections IMPLEMENTATION
