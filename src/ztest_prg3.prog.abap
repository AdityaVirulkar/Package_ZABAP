*&---------------------------------------------------------------------*
*& Report ztest_prg2
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ZTEST_PRG3.

TABLES : SFLIGHT.

"table types
TYPES :
  BEGIN OF TY_SFLIGHT,
    CARRID TYPE S_CARR_ID,
    CONNID TYPE S_CONN_ID,
    FLDATE TYPE S_DATE,
  END OF TY_SFLIGHT.

TYPES:
  BEGIN OF TS_NAMED_DREF,
    NAME TYPE STRING,
    DREF TYPE REF TO DATA,
  END OF TS_NAMED_DREF.
"Internal tables & structures
DATA: LT_SELTABS TYPE CL_SHDB_SELTAB=>TT_NAMED_SELTABLES,
      LS_SELTAB  TYPE TS_NAMED_DREF,
      LT_TAB     TYPE STANDARD TABLE OF TY_SFLIGHT,
      LS_TAB     TYPE TY_SFLIGHT.
"Variables
DATA : LV_CLIENT TYPE STRING.


*- Selection Screen
SELECT-OPTIONS: S_CARRID FOR SFLIGHT-CARRID.

LS_SELTAB-NAME  =   'carrid'.
GET REFERENCE OF S_CARRID[] INTO LS_SELTAB-DREF.
APPEND LS_SELTAB TO  LT_SELTABS.

LV_CLIENT = SY-MANDT.


TRY.

    DATA(LV_WHERE) = CL_SHDB_SELTAB=>COMBINE_SELTABS(
                        IT_NAMED_SELTABS  = LT_SELTABS
                        IV_CLIENT_FIELD   = LV_CLIENT
                      ).
ENDTRY.

CALL METHOD ZCL_TEST_SEL_OPT=>GET_DETAILS
  EXPORTING
    IV_CLIENT = LV_CLIENT
    IV_WHERE  = LV_WHERE
  IMPORTING
    ET_TOP    = LT_TAB.

LOOP AT LT_TAB INTO LS_TAB.
  WRITE : / LS_TAB-CARRID , LS_TAB-CONNID, LS_TAB-FLDATE.
ENDLOOP.
