*&---------------------------------------------------------------------*
*& Report  ZEHR_MAND_COURSE_EDB
*&
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
* CHANGE HISTORY                                                       *
*   Change ID    : AC_BHAVANI                                          *
*   Date         : 23/01/2014                                          *
*   Changed By   : Bhavani                                             *
*   Transport No.: DE0K9A28X9                                          *
*   SIR/CR No.   : CR-1758                                             *
*   Description  : Email reminder to register upcoming courses based   *
*                  on the customised control tables.                   *
*----------------------------------------------------------------------*
* CHANGE HISTORY                                                       *
*   Change ID    : AC_BHAVANI                                          *
*   Date         : 08/05/2014                                          *
*   Changed By   : Bhavani                                             *
*   Transport No.: DE0K9A2EUZ                                          *
*   SIR/CR No.   : IR-2380527 [EDB]                                    *
*   Description  : Sending Multiple coursed for same person            *
*----------------------------------------------------------------------*
*  Change ID    : AC_BHAVANI                                           *
*  Date         : 30.06.2014                                           *
*  Changed By   : Bhavani                                              *
*  Transport No.: DE0K9A2GUN                                           *
*  IR/CR No.    : SSR                                                  *
*  Description  : Added Date check for OM objects Retrival             *
*----------------------------------------------------------------------*
REPORT  zhana_demo_edb LINE-SIZE 200.

* Data Declarations
INCLUDE ZHANA_DEMO_EDB_TOP.
*INCLUDE zehr_mand_course_edb_top.
* Selection Screen
INCLUDE ZHANA_DEMO_EDB_SEL.
*INCLUDE zehr_mand_course_edb_sel.
* Subroutings
INCLUDE ZHANA_DEMO_EDB_FORM.
*INCLUDE zehr_mand_course_edb_form.

AT SELECTION-SCREEN.


AT SELECTION-SCREEN OUTPUT.

INITIALIZATION.
  PERFORM f_initialize.


START-OF-SELECTION.

* Get the list of cse - pernr mandatory relationship from FM
  CALL FUNCTION 'ZHR_MAND_COURSE'
    EXPORTING
      exe_date        = p_exe
    IMPORTING
      course_employee = gt_cse_mand.

* Get the list of existing cse-pernr mandatory relationship from HRP1001
  SELECT * INTO TABLE gt_hrp1001_exist FROM hrp1001 WHERE
                otype EQ c_ctype AND
                begda LE p_exe AND
                endda GE p_exe AND
                relat EQ c_mand AND
                sclas EQ c_pernr
                AND begda LE p_exe AND endda GE p_exe."Added by Bhavani on 30/6/2014 SSR-


END-OF-SELECTION.

* Remove mand course relationship where no future course session available
  WHILE gt_cse_mand IS NOT INITIAL.
    READ TABLE gt_cse_mand INTO gw_cse_mand INDEX 1.
    PERFORM f_check_future_course USING gw_cse_mand CHANGING gv_future_cse.
    IF gv_future_cse IS NOT INITIAL.            " Future course session available
      LOOP AT gt_cse_mand INTO gw_cse_mand_tmp WHERE
                    zcse_type = gw_cse_mand-zcse_type.
        APPEND gw_cse_mand_tmp TO gt_cse_mand_tmp.
        DELETE TABLE gt_cse_mand FROM gw_cse_mand_tmp.
        CLEAR: gw_cse_mand_tmp.
      ENDLOOP.
    ELSE.
      LOOP AT gt_cse_mand INTO gw_cse_mand_tmp WHERE
                    zcse_type = gw_cse_mand-zcse_type.
        DELETE TABLE gt_cse_mand FROM gw_cse_mand_tmp.
        CLEAR: gw_cse_mand_tmp.
      ENDLOOP.
    ENDIF.
    CLEAR: gv_future_cse, gw_cse_mand.
  ENDWHILE.
  gt_cse_mand = gt_cse_mand_tmp.
  REFRESH: gt_cse_mand_tmp.

* Remove mand course relationship if employee has already attended the course
  WHILE gt_cse_mand IS NOT INITIAL.
    READ TABLE gt_cse_mand INTO gw_cse_mand INDEX 1.
    PERFORM f_check_attendance USING gw_cse_mand CHANGING gv_attended.
    IF gv_attended IS INITIAL.            " Course not attended
      APPEND gw_cse_mand TO gt_cse_mand_tmp.
      DELETE TABLE gt_cse_mand FROM gw_cse_mand.
      CLEAR: gw_cse_mand.
    ELSE.
      DELETE TABLE gt_cse_mand FROM gw_cse_mand.
      CLEAR: gw_cse_mand.
    ENDIF.
    CLEAR: gv_attended, gw_cse_mand.
  ENDWHILE.
  gt_cse_mand = gt_cse_mand_tmp.
  REFRESH: gt_cse_mand_tmp.

* Create new mandatory relationships
  LOOP AT gt_cse_mand INTO gw_cse_mand.
    READ TABLE gt_hrp1001_exist TRANSPORTING NO FIELDS WITH KEY
                objid = gw_cse_mand-zcse_type
                sobid = gw_cse_mand-zpernr.
    IF sy-subrc IS INITIAL.           " Existing relationship
* Do nothing
    ELSE.
      gw_hri1001-mandt = sy-mandt.
      gw_hri1001-otype = c_ctype.
      gw_hri1001-objid = gw_cse_mand-zcse_type.
      gw_hri1001-plvar = c_plvar.
      gw_hri1001-rsign = 'A'.
      gw_hri1001-relat = c_mand.
      gw_hri1001-istat = '1'.
      gw_hri1001-begda = p_exe.
      gw_hri1001-endda = '99991231'.
      gw_hri1001-aedtm = sy-datum.
      gw_hri1001-uname = sy-uname.
      gw_hri1001-sclas = c_pernr.
      gw_hri1001-sobid = gw_cse_mand-zpernr.
      APPEND gw_hri1001 TO gt_hri1001.
      CLEAR gw_hri1001.
      CALL FUNCTION 'RH_RELATION_WRITE'
        TABLES
          relation             = gt_hri1001
*         ERR_RELATION         =
        EXCEPTIONS
          no_authority         = 1
          relation_not_allowed = 2
          object_not_found     = 3
          wrong_date_format    = 4
          time_not_valid       = 5
          error_during_insert  = 6
          undefined            = 7
          OTHERS               = 8.
      IF sy-subrc <> 0.
* Implement suitable error handling here
        CASE sy-subrc.
          WHEN 1.
            PERFORM f_create_output USING gw_cse_mand-zcse_type gw_cse_mand-zpernr text-o03 c_error.
          WHEN 2.
            PERFORM f_create_output USING gw_cse_mand-zcse_type gw_cse_mand-zpernr text-o04 c_error.
          WHEN 3.
            PERFORM f_create_output USING gw_cse_mand-zcse_type gw_cse_mand-zpernr text-o05 c_error.
          WHEN 4.
            PERFORM f_create_output USING gw_cse_mand-zcse_type gw_cse_mand-zpernr text-o06 c_error.
          WHEN 5.
            PERFORM f_create_output USING gw_cse_mand-zcse_type gw_cse_mand-zpernr text-o07 c_error.
          WHEN 6.
            PERFORM f_create_output USING gw_cse_mand-zcse_type gw_cse_mand-zpernr text-o08 c_error.
          WHEN 7.
            PERFORM f_create_output USING gw_cse_mand-zcse_type gw_cse_mand-zpernr text-o09 c_error.
          WHEN OTHERS.
            PERFORM f_create_output USING gw_cse_mand-zcse_type gw_cse_mand-zpernr text-o10 c_error.
        ENDCASE.
        gv_error = gv_error + 1.
      ELSE.
        PERFORM f_create_output USING gw_cse_mand-zcse_type gw_cse_mand-zpernr text-o01 c_ok.
        gv_success = gv_success + 1.
      ENDIF.
    ENDIF.
    CLEAR: gw_cse_mand.
    REFRESH: gt_hri1001.
  ENDLOOP.


* Delimit existing course types
  LOOP AT gt_hrp1001_exist INTO gw_hrp1001.
    READ TABLE gt_cse_mand TRANSPORTING NO FIELDS WITH KEY
                zcse_type = gw_hrp1001-objid
                zpernr = gw_hrp1001-sobid.
    IF sy-subrc = 0.            " Mandatory course
* Do nothing
    ELSE.
      MOVE-CORRESPONDING gw_hrp1001 TO gw_p1001.
      APPEND gw_p1001 TO gt_p1001.
*      gw_hri1001-aedtm = sy-datum.
*      gw_hri1001-uname = sy-uname.
*      APPEND gw_hri1001 TO gt_hri1001.
      CALL FUNCTION 'RH_CUT_INFTY'
        EXPORTING
*         LOAD               = 'X'
          gdate              = p_exe
          histo              = ''
*         DEL_SUCC           = ' '
          vtask              = 'D'
*         ORDER_FLG          = 'X'
*         COMMIT_FLG         = 'X'
          authy              = ''
*         PPPAR_IMP          =
*         KEEP_LUPD          =
*         WORKF_ACTV         = 'X'
        TABLES
          innnn              = gt_p1001
*         ILFCODE            =
        EXCEPTIONS
          error_during_cut   = 1
          no_authorization   = 2
          gdate_before_begda = 3
          cut_of_timco_one   = 4
          corr_exit          = 5
          OTHERS             = 6.
      IF sy-subrc <> 0.
* Implement suitable error handling here
        CASE sy-subrc.
          WHEN 1.
            PERFORM f_create_output USING gw_hrp1001-objid gw_hrp1001-sobid(8) text-o11 c_error.
          WHEN 2.
            PERFORM f_create_output USING gw_hrp1001-objid gw_hrp1001-sobid(8) text-o12 c_error.
          WHEN 3.
            PERFORM f_create_output USING gw_hrp1001-objid gw_hrp1001-sobid(8) text-o13 c_error.
          WHEN 4.
            PERFORM f_create_output USING gw_hrp1001-objid gw_hrp1001-sobid(8) text-o14 c_error.
          WHEN 5.
            PERFORM f_create_output USING gw_hrp1001-objid gw_hrp1001-sobid(8) text-o15 c_error.
          WHEN OTHERS.
            PERFORM f_create_output USING gw_hrp1001-objid gw_hrp1001-sobid(8) text-o16 c_error.
        ENDCASE.
        gv_error = gv_error + 1.
      ELSE.
        PERFORM f_create_output USING gw_hrp1001-objid gw_hrp1001-sobid(8) text-o02 c_ok.
        gv_success = gv_success + 1.
      ENDIF.

      CLEAR: gw_p1001, gw_hrp1001.
      REFRESH: gt_hrp1001, gt_p1001.
    ENDIF.
    CLEAR: gw_hrp1001.
  ENDLOOP.

*//Start of Chages by Bhavani 23.01.2014 10:10:34 CR-1758 *//
* Send email on 7th and 15th of every month to Employee for Mandetory courses
  IF p_exe+6(2) = '07' OR p_exe+6(2) = '15'.
  LOOP AT gt_cse_mand INTO gwa_cse_mand.
    CLEAR: gwa_mand_cse.
    LOOP AT gt_mand_cse INTO gwa_mand_cse WHERE zcse_type = gwa_cse_mand-zcse_type
                                             AND zpernr = gwa_cse_mand-zpernr.
      IF gwa_mand_cse-sesid IS NOT INITIAL AND gwa_mand_cse-begda GE sy-datum.
        gwa_mand_sess-zcse_type = gwa_mand_cse-zcse_type.
        gwa_mand_sess-sesid  = gwa_mand_cse-sesid.
        gwa_mand_sess-zpernr = gwa_mand_cse-zpernr.
        gwa_mand_sess-begda = gwa_mand_cse-begda.
        gwa_mand_sess-endda = gwa_mand_cse-endda.
        APPEND gwa_mand_sess TO gt_mand_sess.
        CLEAR: gwa_mand_sess.
      ENDIF.
    ENDLOOP.
    CLEAR: gwa_cse_mand.
  ENDLOOP.

* Get Course Type Name
  LOOP AT gt_mand_sess INTO gwa_mand_sess.
    gwa_evtyp-objid = gwa_mand_sess-zcse_type.
    COLLECT gwa_evtyp INTO git_evtyp.
    CLEAR: gwa_evtyp,gwa_mand_sess.
  ENDLOOP.

  SORT git_evtyp.
  DELETE ADJACENT DUPLICATES FROM git_evtyp.

  SELECT objid stext
    FROM hrp1000
    INTO TABLE git_evtyptxt
    FOR ALL ENTRIES IN git_evtyp
    WHERE plvar = '01'
    AND   otype = 'D'
    AND   objid = git_evtyp-objid
    AND begda LE p_exe AND endda GE p_exe. "Added by Bhavani on 30/6/2014 SSR-
  SORT git_evtyptxt BY objid.

* Get Session Name
  SELECT objid stext FROM hrp1000
                     INTO TABLE git_eventtxt
                     FOR ALL ENTRIES IN gt_mand_sess
                     WHERE plvar = '01'
                       AND otype = 'E'
                       AND objid = gt_mand_sess-sesid
                       AND begda LE p_exe AND endda GE p_exe."Added by Bhavani on 30/6/2014 SSR-
  SORT git_eventtxt BY objid.
  DELETE ADJACENT DUPLICATES FROM git_eventtxt.
* Send Notification to Employee
  PERFORM send_email.
  ENDIF.
*//End of Chages by Bhavani 23.01.2014 10:10:34 CR-1758 *//
  PERFORM f_print_output.
  CLEAR: gw_cse_mand.
