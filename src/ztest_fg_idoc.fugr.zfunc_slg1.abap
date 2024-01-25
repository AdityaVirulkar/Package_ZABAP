FUNCTION ZFUNC_SLG1.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     REFERENCE(PROGNAME) TYPE  SY-REPID
*"----------------------------------------------------------------------
data: ls_log TYPE bal_s_log,

ls_log_handle TYPE balloghndl,
li_log_handle TYPE BAL_T_LOGH,

zobsolete TYPE c,

lt_log_handle TYPE BDCMSGCOLL,

ls_msg TYPE bal_s_msg,

lt_new_lognumbers TYPE bal_t_lgnm.

clear: ls_log, ls_log_handle.

*ls_log-aluser = sy-uname.
*
*ls_log-alprog = 'ZTEST'.
ls_log-extnumber  = 'Application Log Demo'.
ls_log-object =  'ZOBSOLETE'   .
ls_log-subobject  = 'ZOBS'.

*ls_log-object = lc_object.          "“Object name
*
  ls_log-aluser = sy-uname.        "“Username

  ls_log-alprog = progname.          "“Report name



***Open Log

CALL FUNCTION 'BAL_LOG_CREATE'
  EXPORTING
    i_s_log                       = LS_LOG
 IMPORTING
   E_LOG_HANDLE                  = ls_log_handle
 EXCEPTIONS
   LOG_HEADER_INCONSISTENT       = 1
   OTHERS                        = 2
          .


  IF sy-subrc EQ 0.



***Create message
*
*    ls_msg-msgty = 'E'.              "“Message type
*
**    ls_msg-msgid = lc_msgid.            "“Message id
**
**    ls_msg-msgno = lc_msgno.          "“Message number
*
*    ls_msg-msgv1 = 'Test'.      "“Text that you want to pass as message
*
**    ls_msg-msgv2 = lv_message2.
**
**    ls_msg-msgv3 = lv_message3.
**
**    ls_msg-msgv4 = lv_message4.
*
*    ls_msg-probclass = 2.

LS_MSG-MSGTY     = 'E'.
LS_MSG-MSGID     = 'ZMESSAGE'.
LS_MSG-MSGNO     = '000'.
LS_MSG-MSGV1     = 'The log of the program'.
LS_MSG-MSGV2     = 'is displayed'.
*LS_MSG-MSGV3     = SY-MSGV3.
*LS_MSG-MSGV4     = SY-MSGV4.


    CALL FUNCTION 'BAL_LOG_MSG_ADD'

      EXPORTING

       i_log_handle              = ls_log_handle

        i_s_msg                   = ls_msg

* IMPORTING

*   E_S_MSG_HANDLE            =

*   E_MSG_WAS_LOGGED          =

*   E_MSG_WAS_DISPLAYED       =

     EXCEPTIONS

       log_not_found             = 1

       msg_inconsistent          = 2

       log_is_full               = 3

       OTHERS                    = 4.

    IF sy-subrc NE 0.

*      “Do nothing

    ENDIF.

    INSERT ls_log_handle INTO TABLE li_log_handle.



***Save message

    CALL FUNCTION 'BAL_DB_SAVE'

     EXPORTING

       i_client               = sy-mandt

*   I_IN_UPDATE_TASK       = ‘ ‘

*       i_save_all             = lc_set

       i_t_log_handle         = li_log_handle

* IMPORTING

*   E_NEW_LOGNUMBERS       =

     EXCEPTIONS

       log_not_found          = 1

       save_not_allowed       = 2

       numbering_error        = 3

       OTHERS                 = 4.

    IF sy-subrc EQ 0.

      REFRESH: li_log_handle.

    ENDIF.
ENDIF.


*******************
*******************

DATA : lv_filename TYPE rlgrap-filename,
*       lv_file(60) TYPE c,
        lv_string(100) TYPE c ,
        c_filename type c,
        c_con_tab TYPE c VALUE cl_abap_char_utilities=>horizontal_tab.
** Parameters to enter the path
*DATA: filename(128) TYPE c VALUE '/usr/tmp/testfile.dat'.
DATA: filename(128) TYPE c VALUE '/tmp/testfile.dat'.
*parameters p_path LIKE rlgrap-filename OBLIGATORY .

* Data Declaration
DATA d_msg_text(50).
DATA: p_path LIKE rlgrap-filename.

DATA: it_demo TYPE TABLE OF balhdr,
      lw_demo type balhdr.
DATA: lt_msg TYPE TABLE OF BALM,
      lt_msg1 TYPE TABLE OF BALMP.


CALL FUNCTION 'APPL_LOG_READ_DB'
  EXPORTING
    object           = 'ZOBSOLETE'
    subobject        = 'ZOBS'
    external_number  = ' '
*   DATE_FROM        =
    date_to          = sy-datum
    time_from        = '000000'
    time_to          = sy-uzeit
    log_class        = '4'
    program_name     = '*'
    transaction_code = '*'
    user_id          = ' '
    mode             = '+'
    put_into_memory  = ' '
* IMPORTINGb
*   NUMBER_OF_LOGS   =
  TABLES
    header_data      = it_demo
*   HEADER_PARAMETERS        =
   MESSAGES         = lt_msg
   MESSAGE_PARAMETERS       = lt_msg1
*   CONTEXTS         =
*   T_EXCEPTIONS     =
  .
IF  sy-subrc <> 0.

ENDIF.

*CONCATENATE p_path c_filename INTO lv_filename.

lv_filename = filename.


**Placing the file in Application server
OPEN DATASET lv_filename FOR OUTPUT IN TEXT MODE ENCODING DEFAULT.
IF sy-subrc <> 0.
 write:/ 'file does not exist'.

ENDIF.
LOOP AT it_demo INTO lw_demo.

  CONCATENATE lw_demo-lognumber
                               lw_demo-object
                               lw_demo-subobject
                               lw_demo-aldate

              INTO lv_string SEPARATED BY c_con_tab.

  TRANSFER lv_string   TO lv_filename.
ENDLOOP.
CLOSE DATASET lv_filename.



ENDFUNCTION.
