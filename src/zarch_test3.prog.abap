*&---------------------------------------------------------------------*
*& Report ZARCH_TEST3
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ZARCH_TEST3.


CONSTANTS cns_tcode TYPE char10 VALUE 'XD01'.

DATA: v_xd01 TYPE char5 VALUE 'XD01'.


PERFORM f_set_cdhdr USING 'XD01'.

FORM f_set_cdhdr USING xd01.
  CALL TRANSACTION 'xd01'.
  CALL TRANSACTION xd01.
  CALL TRANSACTION cns_tcode.
  ENDFORM.
