  FUNCTION ZRFC.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(ID) TYPE  SCPR_ID OPTIONAL
*"  TABLES
*"      I_PARAM STRUCTURE  CHAR8000
*"      I_PROG STRUCTURE  LINE
*"      O_RESULT STRUCTURE  CHAR8000
*"  EXCEPTIONS
*"      NO_PROGRAM_GENERATED
*"----------------------------------------------------------------------

DATA : prog TYPE string,
          mess TYPE string,
          sid TYPE string,
          lin(4) TYPE c,
          wrd(10) TYPE c,
          off(1) TYPE c,
      wa_result TYPE char8000.


  GENERATE SUBROUTINE POOL i_prog NAME prog
      MESSAGE mess
      SHORTDUMP-ID sid
      LINE lin
      WORD wrd
      OFFSET off.

  IF sy-subrc = 0.
    PERFORM get_config IN PROGRAM (prog)
                                         TABLES i_param
                                                o_result
                                         USING ID.
  ELSE.
    RAISE no_program_generated.
  ENDIF.


ENDFUNCTION.
