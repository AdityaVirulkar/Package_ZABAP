REPORT ZTEST_AM2.

  CALL FUNCTION 'WS_FILENAME_GET'
    EXPORTING
      def_filename     = 'test'
      def_path         = 'V:\'
      mask             = ' Text files (*.txt)|*.txt|ALC Excel files (*.xlsx)|*.xlsx|'
      mode             = '0'
      title            = 'test '
    IMPORTING
      filename         = file
*     RC               =
    EXCEPTIONS
      inv_winsys       = 1
      no_batch         = 2
      selection_cancel = 3
      selection_error  = 4
      OTHERS           = 5.
  IF sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.
