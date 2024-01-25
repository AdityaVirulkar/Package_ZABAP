FUNCTION ZFUNC_SLG.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     REFERENCE(PROGRAM) TYPE  SY-REPID
*"----------------------------------------------------------------------


*REPORT ZSLG_1.
data: ls_log TYPE bal_s_log,

ls_log_handle TYPE balloghndl,

zobsolete TYPE c,

lt_log_handle TYPE BDCMSGCOLL,

ls_msg TYPE bal_s_msg,

lt_new_lognumbers TYPE bal_t_lgnm.

clear: ls_log, ls_log_handle.

ls_log-aluser = sy-uname.

ls_log-alprog = program.

ls_log-object =  'ZOBSOLETE'   .

CALL FUNCTION 'BAL_LOG_MSG_ADD'

EXPORTING

i_log_handle = ls_log_handle

i_s_msg = ls_msg

EXCEPTIONS

log_not_found = 1

msg_inconsistent = 2

log_is_full = 3

OTHERS = 4.

CALL FUNCTION 'BAL_DB_SAVE'

EXPORTING

i_t_log_handle = lt_log_handle

IMPORTING

e_new_lognumbers = lt_new_lognumbers

EXCEPTIONS

log_not_found = 1

save_not_allowed = 2

numbering_error = 3

OTHERS = 4.


ENDFUNCTION.
