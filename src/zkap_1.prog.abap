*&---------------------------------------------------------------------*
*&  Include           ZEHR_MAND_COURSE_EDB_FORM
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  F_INITIALIZE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_initialize .

  REFRESH: gt_cse_mand,
           gt_hrp1001_exist,
           gt_cse_mand_tmp,
           gt_hri1001,
           gt_hrp1001,
           gt_p1001,
           gt_output.
  CLEAR:  gw_cse_mand,
          gv_future_cse,
          gw_cse_mand_tmp,
          gv_attended,
          gw_hri1001,
          gw_hrp1001,
          gw_p1001,
          gw_output,
          gv_success,
          gv_error.
ENDFORM.                    " F_INITIALIZE
*&---------------------------------------------------------------------*
*&      Form  F_CHECK_FUTURE_COURSE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_GV_NO_FUTURE_CSE  text
*      -->P_GW_CSE_MAND  text
*----------------------------------------------------------------------*
FORM f_check_future_course  USING     pi_cse_mand TYPE zhr_s_cse_mand
                            CHANGING  pe_future_cse  TYPE c.
  DATA: lt_hrp1001 TYPE STANDARD TABLE OF hrp1001,
        lw_hrp1001 TYPE hrp1001,
        lw_hrp1026 TYPE hrp1026.

  CLEAR: lw_hrp1001, lw_hrp1026.
  REFRESH: lt_hrp1001.

  SELECT * FROM hrp1001 INTO TABLE lt_hrp1001 WHERE
                otype EQ c_ctype AND
                objid EQ pi_cse_mand-zcse_type AND
                relat EQ c_specialize AND
                begda GE p_exe AND
                sclas EQ c_cssn.
  IF lt_hrp1001 IS NOT INITIAL.
    LOOP AT lt_hrp1001 INTO lw_hrp1001.

      SELECT SINGLE * FROM hrp1026 INTO lw_hrp1026 WHERE
                    otype EQ c_cssn AND
                    objid EQ lw_hrp1001-sobid AND
                    begda EQ lw_hrp1001-begda.

      IF lw_hrp1026 IS NOT INITIAL AND lw_hrp1026-delet EQ c_false.
        pe_future_cse = c_true.
        EXIT.
      ENDIF.
      CLEAR: lw_hrp1001, lw_hrp1026.
    ENDLOOP.
  ENDIF.
ENDFORM.                    " F_CHECK_FUTURE_COURSE
*&---------------------------------------------------------------------*
*&      Form  F_CHECK_ATTENDANCE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_GW_CSE_MAND  text
*      <--P_GV_ATTENDED  text
*----------------------------------------------------------------------*
FORM f_check_attendance  USING    pi_cse_mand TYPE zhr_s_cse_mand
                         CHANGING pe_attended TYPE c.
  DATA: lt_hrp1001        TYPE STANDARD TABLE OF hrp1001,
        lw_hrp1001        TYPE hrp1001,
        lw_hrp1026        TYPE hrp1026,
        lt_hrp1001_attend TYPE STANDARD TABLE OF hrp1001.

  CLEAR: lw_hrp1001, lw_hrp1026.
  REFRESH: lt_hrp1001, lt_hrp1001_attend.

  SELECT * FROM hrp1001 INTO TABLE lt_hrp1001 WHERE
                otype EQ c_ctype AND
                objid EQ pi_cse_mand-zcse_type AND
                relat EQ c_specialize AND
                sclas EQ c_cssn.
  IF lt_hrp1001 IS NOT INITIAL.
    LOOP AT lt_hrp1001 INTO lw_hrp1001.
      SELECT SINGLE * FROM hrp1026 INTO lw_hrp1026 WHERE
                    otype EQ c_cssn AND
                    objid EQ lw_hrp1001-sobid AND
                    begda EQ lw_hrp1001-begda.

      IF lw_hrp1026 IS NOT INITIAL AND lw_hrp1026-delet EQ c_false.
        SELECT * FROM hrp1001 INTO TABLE lt_hrp1001_attend WHERE
                      otype EQ c_cssn AND
                      objid EQ lw_hrp1001-sobid AND
                      relat EQ c_attended AND
                      begda EQ lw_hrp1001-begda AND
                      sclas EQ c_pernr.
        READ TABLE lt_hrp1001_attend TRANSPORTING NO FIELDS WITH KEY
                    sobid = pi_cse_mand-zpernr.
        IF sy-subrc = 0.
          pe_attended = c_true.
          EXIT.
        ENDIF.
*//Start of Chages by Bhavani 23.01.2014 10:16:46 CR-1758*//
* Get Session Details
        gwa_mand_cse-zcse_type = lw_hrp1001-objid.
        gwa_mand_cse-sesid = lw_hrp1001-sobid.
        gwa_mand_cse-zpernr = pi_cse_mand-zpernr.
        gwa_mand_cse-begda = lw_hrp1001-begda.
        gwa_mand_cse-endda = lw_hrp1001-endda.
        APPEND gwa_mand_cse TO gt_mand_cse.
        CLEAR: gwa_mand_cse.
*//End of Chages by Bhavani 23.01.2014 10:16:46 CR-1758 *//
      ENDIF.
      CLEAR: lw_hrp1001, lw_hrp1026.
      REFRESH: lt_hrp1001_attend.
    ENDLOOP.
  ENDIF.
ENDFORM.                    " F_CHECK_ATTENDANCE
*&---------------------------------------------------------------------*
*&      Form  F_CREATE_OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_GW_CSE_MAND  text
*      -->P_TEXT_O01  text
*      -->P_GC_OK  text
*----------------------------------------------------------------------*
FORM f_create_output  USING    pi_cse_type
                               pi_pernr
                               pi_text
                               pi_status.
  CLEAR gw_output.

  IF pi_status = c_error.
    gw_output-typ = icon_led_red.
  ELSE.
    gw_output-typ = icon_led_green.
  ENDIF.
  gw_output-cse_type = pi_cse_type.
  gw_output-pernr = pi_pernr.
  gw_output-message = pi_text.
  APPEND gw_output TO gt_output.
  CLEAR gw_output.
ENDFORM.                    " F_CREATE_OUTPUT
*&---------------------------------------------------------------------*
*&      Form  F_PRINT_OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_print_output.
  DATA: lv_total    TYPE i,
        lv_sno      TYPE i,
        lv_date(10) TYPE c.

  lv_total = gv_error + gv_success.
  CONCATENATE p_exe+6(2) '.' p_exe+4(2) '.' p_exe(4) INTO lv_date.

  WRITE: TEXT-o17, sy-datum, '/', sy-uzeit.
  NEW-LINE.
  WRITE: /.
  WRITE: TEXT-o18, 45 lv_total.
  NEW-LINE.
  WRITE: TEXT-o19, 45 gv_success.
  NEW-LINE.
  WRITE: TEXT-o20, 45 gv_error.
  NEW-LINE.
  WRITE: TEXT-o27, 54 lv_date.
  NEW-LINE.

  FORMAT INTENSIFIED ON.
  WRITE: /, 2 TEXT-o21.
  FORMAT INTENSIFIED OFF.

  FORMAT COLOR 1 ON.
  ULINE AT /(150).

  WRITE: /1 sy-vline, TEXT-o22.
  WRITE: 7 sy-vline, TEXT-o23.
  WRITE: 16 sy-vline, TEXT-o24.
  WRITE: 40 sy-vline, TEXT-o25.
  WRITE: 75 sy-vline, TEXT-o26.
  WRITE: 150 sy-vline.

  ULINE AT /(150).
  FORMAT COLOR 1 OFF.

  SORT gt_output BY typ ASCENDING.

  LOOP AT gt_output INTO gw_output.
    lv_sno = lv_sno + 1.
    WRITE: /1 sy-vline, lv_sno LEFT-JUSTIFIED.
    WRITE: 7 sy-vline,  gw_output-typ.
    WRITE: 16 sy-vline, gw_output-cse_type.
    WRITE: 40 sy-vline, gw_output-pernr.
    WRITE: 75 sy-vline, gw_output-message.
    WRITE: 150 sy-vline.
    ULINE AT /(150).
    CLEAR: gw_output.
  ENDLOOP.

ENDFORM.                    " F_PRINT_OUTPUT
*&---------------------------------------------------------------------*
*&      Form  SEND_EMAIL
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM send_email .
  DATA: lv_emp_id TYPE sysid,
        lv_dir_id TYPE sysid,
        lv_hr_id  TYPE sysid.

  REFRESH: gt_pa0105, gt_pa0001, gt_pernr.
* Send Notification
  IF gt_mand_sess[]  IS NOT INITIAL.
    LOOP AT gt_mand_sess INTO gwa_mand_sess.
      gwa_pernr-pernr = gwa_mand_sess-zpernr.
      APPEND gwa_pernr TO gt_pernr.
      CLEAR: gwa_mand_sess, gwa_pernr.
    ENDLOOP.
    SORT gt_mand_sess BY zpernr.
*//Start of Chages by Bhavani 08.05.2014 10:27:32 IR-2380527 EDB *//
    SORT gt_pernr BY pernr.
    DELETE ADJACENT DUPLICATES FROM gt_pernr  COMPARING pernr.
*//End of Chages by Bhavani 08.05.2014 10:27:32 IR-2380527 EDB *//
* UserID Details
    SELECT * FROM pa0105 INTO TABLE gt_pa0105
                         FOR ALL ENTRIES IN gt_pernr
                         WHERE pernr = gt_pernr-pernr
                         AND subty = gc_0001
                         AND begda LE sy-datum
                         AND endda GE sy-datum.
    IF sy-subrc = 0.
      SORT gt_pa0105 BY begda DESCENDING.
    ENDIF.
* Personal Info
    SELECT * FROM pa0001 INTO TABLE gt_pa0001
                         FOR ALL ENTRIES IN gt_pernr
                         WHERE pernr = gt_pernr-pernr
                           AND begda LE sy-datum
                           AND endda GE sy-datum.
    IF sy-subrc = 0.
      SORT gt_pa0001 BY begda DESCENDING.
    ENDIF.
    DELETE ADJACENT DUPLICATES FROM gt_pernr COMPARING ALL FIELDS.
    LOOP AT gt_pernr INTO gwa_pernr.
      CLEAR : gwa_receiver.
* Empployee ID
      CLEAR: lv_emp_id, gwa_pa0105.
      READ TABLE gt_pa0105 INTO gwa_pa0105 WITH KEY pernr = gwa_pernr-pernr.
      IF sy-subrc EQ 0.
        lv_emp_id = gwa_pa0105-usrid.
      ENDIF.
      IF lv_emp_id IS NOT INITIAL.
        gwa_receiver-rec_type = 'B'.
        gwa_receiver-notif_del  = gc_x.
        gwa_receiver-notif_ndel = gc_x.
        gwa_receiver-receiver = lv_emp_id.
        APPEND gwa_receiver TO gt_receiver.
        CLEAR: gwa_receiver.

* Send Email
        PERFORM f_set_emp_table.
        PERFORM f_process_mail_parameters.
        PERFORM f_actual_send_retirees.
        PERFORM f_clear.
        CLEAR: gwa_pernr.
      ENDIF.
    ENDLOOP.
  ENDIF.
ENDFORM.                    " SEND_EMAIL
*&---------------------------------------------------------------------*
*&      Form  F_SET_EMP_TABLE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_set_emp_table.
  DATA: lv_no(3) TYPE n,
        lv_sno   TYPE string.

  CLEAR: gv_subject, gv_name, lv_no, lv_sno, gv_startdate.

* Subject
  gv_subject = TEXT-003. " [LEARN] Register for your upcoming training programmes
  CLEAR: gwa_pa0001.
  READ TABLE gt_pa0001 INTO gwa_pa0001 WITH KEY pernr = gwa_pernr-pernr.
  IF gwa_pa0001 IS NOT INITIAL.
    gv_name = gwa_pa0001-ename.
  ENDIF.

* Dear Staff
  CONCATENATE  TEXT-001 gv_name INTO gwa_bodymsg SEPARATED BY space. " Ename
  APPEND gwa_bodymsg TO gt_bodymsg.
  CLEAR gwa_bodymsg.

  APPEND gwa_bodymsg TO gt_bodymsg." blank line

  MOVE TEXT-002 TO gwa_bodymsg.
  APPEND gwa_bodymsg TO gt_bodymsg.
  CLEAR gwa_bodymsg.

  MOVE TEXT-004 TO gwa_bodymsg.
  APPEND gwa_bodymsg TO gt_bodymsg.
  CLEAR gwa_bodymsg.

* Course Details
  SORT gt_mand_sess ASCENDING BY begda.
  LOOP AT gt_mand_sess INTO gwa_mand_sess WHERE zpernr = gwa_pernr-pernr.
    CLEAR: gv_ctname, gv_csname, gwa_evtyptxt, gwa_eventtxt, gv_startdate.
    lv_no = lv_no + 1.
    lv_sno = lv_no.
    CONDENSE lv_sno.
    CONCATENATE lv_sno gc_dot INTO lv_sno.
    SHIFT lv_sno LEFT DELETING LEADING '0'.
    READ TABLE git_evtyptxt INTO gwa_evtyptxt WITH KEY objid = gwa_mand_sess-zcse_type.
    IF sy-subrc EQ 0.
      gv_ctname = gwa_evtyptxt-stext.
      CONCATENATE gv_ctname ',' INTO gv_ctname.
    ENDIF.
    READ TABLE git_eventtxt INTO gwa_eventtxt WITH KEY objid = gwa_mand_sess-sesid.
    IF sy-subrc EQ 0.
      gv_csname = gwa_eventtxt-stext.
    ENDIF.
    CONCATENATE gwa_mand_sess-begda+6(2) gwa_mand_sess-begda+4(2) gwa_mand_sess-begda(4) INTO gv_startdate SEPARATED BY '.'.
    IF lv_sno IS NOT INITIAL AND gv_ctname IS NOT INITIAL AND gv_csname IS NOT INITIAL.
      CONCATENATE lv_sno gv_ctname gv_startdate INTO gwa_bodymsg SEPARATED BY space.
      APPEND gwa_bodymsg TO gt_bodymsg.
    ENDIF.
    CLEAR: gwa_bodymsg, gwa_mand_sess.
  ENDLOOP.

  MOVE TEXT-006 TO gwa_bodymsg.
  APPEND gwa_bodymsg TO gt_bodymsg.
  CLEAR gwa_bodymsg.

  APPEND gwa_bodymsg TO gt_bodymsg." blank line
  MOVE TEXT-005 TO gwa_bodymsg.
  APPEND gwa_bodymsg TO gt_bodymsg.
  CLEAR gwa_bodymsg.

  APPEND gwa_bodymsg TO gt_bodymsg." blank line
  MOVE TEXT-009 TO gwa_bodymsg.
  APPEND gwa_bodymsg TO gt_bodymsg.
  CLEAR gwa_bodymsg.

  APPEND gwa_bodymsg TO gt_bodymsg." blank line
  MOVE TEXT-007 TO gwa_bodymsg.
  APPEND gwa_bodymsg TO gt_bodymsg.
  CLEAR gwa_bodymsg.

  MOVE TEXT-008 TO gwa_bodymsg.
  APPEND gwa_bodymsg TO gt_bodymsg.
  CLEAR gwa_bodymsg.


ENDFORM.                    " F_SET_EMP_TABLE
*&************************************************************************************************************&*
*&      Form  F_PROCESS_MAIL_PARAMETERS
*&************************************************************************************************************&*
FORM f_process_emp_mail_parameters .
  CLEAR: gwa_packinglist,
         gwa_docs.

  DATA: l_cnt TYPE i.
* Get the number of lines for the text message
  PERFORM f_build_packinglist.
  gwa_docs-obj_langu = sy-langu.
  gwa_docs-obj_descr = gv_subject.         " Notification Subject
ENDFORM.                    " F_PROCESS_MAIL_PARAMETERS
*&************************************************************************************************************&*
*         FORM F_ACTUAL_SEND_RETIREES .
*&************************************************************************************************************&*
FORM f_actual_send_retirees .
  DATA: lv_sender TYPE soextreci1-receiver.
  lv_sender = sy-uname.

  CALL FUNCTION 'SO_DOCUMENT_SEND_API1'
    EXPORTING
      document_data              = gwa_docs
      sender_address             = lv_sender
      commit_work                = 'X'       " Added by Bhavani on 6/12/2013 CR-1467
    TABLES
      packing_list               = gt_packinglist
      contents_txt               = gt_bodymsg
      contents_hex               = gt_hex
      receivers                  = gt_receiver
    EXCEPTIONS
      too_many_receivers         = 1
      document_not_sent          = 2
      document_type_not_exist    = 3
      operation_no_authorization = 4
      parameter_error            = 5
      x_error                    = 6
      enqueue_error              = 7
      OTHERS                     = 8.
  IF sy-subrc EQ 0.
  ELSE.
    CLEAR: lv_sender.
  ENDIF.

ENDFORM.                    "
*&************************************************************************************************************&*
*&      Form  F_PROCESS_MAIL_PARAMETERS
*&************************************************************************************************************&*
FORM f_process_mail_parameters .
  CLEAR: gwa_packinglist,
         gwa_docs.

  DATA: l_cnt TYPE i.
* Get the number of lines for the text message
  PERFORM f_build_packinglist.

  gwa_docs-obj_langu = sy-langu.
  gwa_docs-obj_descr = gv_subject.         " Notification Subject
ENDFORM.                    " F_PROCESS_MAIL_PARAMETERS
*&---------------------------------------------------------------------*
*&      Form  F_CLEAR
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f_clear .
  CLEAR :gwa_docs,
  gt_packinglist[],
  gt_bodymsg[],
  gt_hex[],
  gt_receiver[].
ENDFORM.                    " F_CLEAR
*&************************************************************************************************************&*
*&      Form  f_build_packinglist
*&************************************************************************************************************&*
FORM f_build_packinglist .
  DATA: lv_bodymsglines TYPE i.

  CLEAR lv_bodymsglines.
  DESCRIBE TABLE gt_bodymsg LINES lv_bodymsglines.
  " Describe the body of the message
  REFRESH gt_packinglist.
  gwa_packinglist-transf_bin = space.
  gwa_packinglist-head_start = 1.
  gwa_packinglist-head_num   = 0.
  gwa_packinglist-body_start = 1.
  gwa_packinglist-body_num   = lv_bodymsglines.
  gwa_packinglist-doc_type   = gc_raw.
  gwa_packinglist-doc_size   = lv_bodymsglines.
  APPEND gwa_packinglist TO gt_packinglist.
  CLEAR gwa_packinglist.
ENDFORM.                    "f_build_packinglist
