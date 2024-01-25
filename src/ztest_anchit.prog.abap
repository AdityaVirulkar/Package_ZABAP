REPORT ZTEST_ANCHIT.

*******************************************************************************
*                               T A B L E S
*******************************************************************************
TABLES: VRSD, TADIR.
*******************************************************************************
*                               T Y P E S
*******************************************************************************
TYPE-POOLS : SLIS,TRUXS.

TYPES:
  BEGIN OF TY_TAB,
    OBJ_NAME  TYPE VRSD-OBJNAME,
    OBJ_TYP   TYPE VRSD-OBJTYPE,
    FLAG(128) TYPE C,
  END OF TY_TAB,

  BEGIN OF TY_TADIR,
    OBJ_NAME TYPE SY-REPID,
    OBJECT   TYPE TADIR-OBJECT,
  END OF TY_TADIR,

  BEGIN OF TY_FM,
    OBJNAME TYPE VRSD-OBJNAME,
*    OBJTYP   TYPE VRSD-OBJTYPE,
  END OF TY_FM,

  BEGIN OF TY_FM1,
    OBJ_NAME TYPE VRSD-OBJNAME,
    OBJTYP   TYPE VRSD-OBJTYPE,
  END OF TY_FM1.

*******************************************************************************
*                    D A T A   D E C L A R A T I O N S
*******************************************************************************

DATA : WA_FM        TYPE TY_FM,
       LV_FUGR_NAME TYPE TADIR-OBJ_NAME,
       LV_PROGNAME  TYPE RSNEWLENG-PROGRAMM,
       LV_TYPE      TYPE VRSD-OBJTYPE,
       IT_TYPE      TYPE TRUXS_T_TEXT_DATA.



DATA: LS_VERS_1     TYPE VRSD,
      LS_VERS_2     TYPE VRSD,
      LV_OBJNAME1_L TYPE VRSD-OBJNAME,
      LV_OBJNAME2_L TYPE VRSD-OBJNAME,
      LV_PROG       TYPE VRSD-OBJNAME.

DATA: IT_FIELDCAT TYPE SLIS_T_FIELDCAT_ALV,
      WA_FIELDCAT TYPE SLIS_FIELDCAT_ALV.

*******************************************************************************
*          I N T E R N A L  T A B L E  D E C L A R A T I O N S
*******************************************************************************
DATA: IT_DISPLAY TYPE TABLE OF TY_TAB,
      IT_FM      TYPE TABLE OF TY_FM,
      IT_TFDIR   TYPE TABLE OF  TFDIR,
      LT_TAB     TYPE TABLE OF VRSN,
      LT_TAB1    TYPE TABLE OF VRSD,
      LT_TAB2    TYPE TABLE OF VRSD,
      IT_VRSD    TYPE TABLE OF VRSD.


DATA: ABAPTEXT_SEC1 LIKE ABAPTXT255 OCCURS 0 WITH HEADER LINE,
      TRDIR_SEC1    LIKE TRDIR OCCURS 1 WITH HEADER LINE,
      ABAPTEXT_SEC2 LIKE ABAPTXT255 OCCURS 0 WITH HEADER LINE,
      TRDIR_SEC2    LIKE TRDIR OCCURS 1 WITH HEADER LINE,
      IT_FM1        TYPE TABLE OF TY_FM1,
      IT_TADIR      TYPE TABLE OF TY_TADIR.

*******************************************************************************
*          W O R K  A R E A  D E C L A R A T I O N S
*******************************************************************************

DATA : WA_DISPLAY TYPE TY_TAB,
       LWA_TAB1   LIKE LINE OF LT_TAB1,
       WA_VRSD    TYPE VRSD,
       WA_TADIR   TYPE  TY_TADIR,
       WA_FM1     TYPE  TY_FM1.


        TYPES: BEGIN OF TY_CLS,
                 OBJNAME TYPE VRSD-OBJNAME,
                 OBJTYP  TYPE VRSD-OBJTYPE,
               END OF TY_CLS.
        DATA : WA_CLS TYPE TY_CLS,
               IT_CLS TYPE TABLE OF TY_CLS.
*          IT_VRSD TYPE TABLE OF vrsd.

        CLASS CL_OO_INCLUDE_NAMING DEFINITION LOAD.
        DATA OREF TYPE REF TO IF_OO_CLASS_INCL_NAMING.
        DATA: MTDS_W_INCL  TYPE SEOP_METHODS_W_INCLUDE,
              MTDS_W_INCL2 TYPE SEOP_METHODS_W_INCLUDE.

        DATA CLSKEY  TYPE  SEOCLSKEY.
*******************************************************************************
*                S E L E C T I O N   S C R E E N
*******************************************************************************
SELECTION-SCREEN BEGIN OF BLOCK B2.
PARAMETERS: P_INPUT  RADIOBUTTON GROUP A DEFAULT 'X' USER-COMMAND RG1,
            P_UPLOAD RADIOBUTTON GROUP A.
SELECTION-SCREEN END OF BLOCK B2.

SELECTION-SCREEN BEGIN OF BLOCK B1.

SELECT-OPTIONS: SO_PROG FOR VRSD-OBJNAME NO INTERVALS  MODIF ID RG1.

PARAMETERS  PA_TYPE TYPE TROBJTYPE MODIF ID RG1.

SELECTION-SCREEN END OF BLOCK B1.

PARAMETERS P_FILE TYPE RLGRAP-FILENAME MODIF ID RG2.

*******************************************************************************
*              A T   S E L E C T I O N   S C R E E N
*******************************************************************************


AT SELECTION-SCREEN OUTPUT.

  LOOP AT SCREEN.
    IF P_UPLOAD = 'X'.
      IF SCREEN-GROUP1 = 'RG1'.
        SCREEN-INPUT = 0.
        MODIFY SCREEN.
      ENDIF.
      IF SCREEN-GROUP1 = 'RG2'.
        SCREEN-INPUT = 1.
        MODIFY SCREEN.
      ENDIF.
    ENDIF.
    IF P_INPUT = 'X'.
      IF SCREEN-GROUP1 = 'RG2'.
        SCREEN-INPUT = 0.
        MODIFY SCREEN.
      ENDIF.
      IF SCREEN-GROUP1 = 'RG1'.
        SCREEN-INPUT = 1.
        MODIFY SCREEN.
      ENDIF.
    ENDIF.
  ENDLOOP.


*
AT SELECTION-SCREEN ON VALUE-REQUEST FOR P_FILE.
  CALL FUNCTION 'F4_FILENAME'
    EXPORTING
*     PROGRAM_NAME  = SYST-CPROG
*     DYNPRO_NUMBER = SYST-DYNNR
      FIELD_NAME = 'P_FILE'
    IMPORTING
      FILE_NAME  = P_FILE.






*Validation for Valid Output type
*AT SELECTION-SCREEN.
*  IF PA_TYPE IS INITIAL.
*    MESSAGE 'Please enter Object Type' TYPE 'E'.
*  ELSE.
*    IF PA_TYPE NE 'CLS' AND
*       PA_TYPE NE 'FUGR' AND
*       PA_TYPE NE 'REPS'.
*      MESSAGE 'Please enter Valid Object Type' TYPE 'E'.
*    ENDIF.
*  ENDIF.




START-OF-SELECTION.



  IF P_UPLOAD = 'X'.
* Uploading the data in the file into internal table
    CALL FUNCTION 'TEXT_CONVERT_XLS_TO_SAP'
      EXPORTING
*       I_FIELD_SEPERATOR    =
*       I_LINE_HEADER        = 'X'
        I_TAB_RAW_DATA       = IT_TYPE
        I_FILENAME           = P_FILE
      TABLES
        I_TAB_CONVERTED_DATA = IT_TADIR[]
      EXCEPTIONS
        CONVERSION_FAILED    = 1
        OTHERS               = 2.
    IF SY-SUBRC NE  0.
      MESSAGE ID SY-MSGID
              TYPE SY-MSGTY
              NUMBER SY-MSGNO
              WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
    ENDIF.
  ENDIF.

  IF P_INPUT = 'X'.
    SELECT OBJECT OBJ_NAME INTO CORRESPONDING FIELDS OF TABLE IT_TADIR
    FROM TADIR WHERE OBJ_NAME IN SO_PROG. "OBJECT = PA_TYPE
*             AND OBJ_NAME IN SO_PROG.
    IF SY-SUBRC NE 0.
      MESSAGE 'Object Not Found' TYPE 'E'.
    ELSE.
      SORT IT_TADIR BY OBJECT OBJ_NAME.
    ENDIF.
  ENDIF.

IF NOT IT_TADIR IS INITIAL.
     LOOP AT IT_TADIR INTO WA_TADIR.
          WA_FM1-OBJ_NAME = WA_TADIR-OBJ_NAME.
          IF WA_TADIR-OBJECT = 'PROG'.
            WA_FM1-OBJTYP = 'REPS'.
          ELSE.
            WA_FM1-OBJTYP = WA_TADIR-OBJECT.
          ENDIF.
        ENDLOOP.
      ENDIF.

  LOOP AT IT_FM1 INTO WA_FM1.

    CASE WA_FM1-OBJTYP.
      WHEN 'CLAS'.
*----------------------------------------------------------------------*
*   Logic to process class
          CLSKEY =  WA_FM1-OBJ_NAME ."'ZCL_NIKS_HANA_PROFILER_TEST'.
          FIELD-SYMBOLS <MWI> TYPE LINE OF SEOP_METHODS_W_INCLUDE.

          OREF ?= CL_OO_INCLUDE_NAMING=>GET_INSTANCE_BY_CIFKEY( CLSKEY ).
          MTDS_W_INCL = OREF->GET_ALL_METHOD_INCLUDES( ).

          LOOP AT MTDS_W_INCL ASSIGNING <MWI>.
            DATA ST TYPE STRING.
            CALL METHOD CL_ABAP_CONTAINER_UTILITIES=>FILL_CONTAINER_C
              EXPORTING
                IM_VALUE               = <MWI>-CPDKEY
              IMPORTING
                EX_CONTAINER           = ST
              EXCEPTIONS
                ILLEGAL_PARAMETER_TYPE = 1
                OTHERS                 = 2.
            WA_CLS-OBJNAME = ST.
            APPEND WA_CLS TO IT_CLS.
            CLEAR: WA_CLS, ST.
          ENDLOOP.

          IF NOT IT_CLS IS INITIAL.

            SELECT OBJTYPE
                   OBJNAME
               FROM VRSD
             INTO CORRESPONDING FIELDS OF TABLE IT_VRSD
              FOR ALL ENTRIES IN IT_CLS
             WHERE OBJNAME = IT_CLS-OBJNAME.

            IF SY-SUBRC NE 0.
              MESSAGE  'Invalid Object' TYPE 'E'.
            ENDIF.
          ENDIF.

      WHEN 'PROG'.

        REFRESH IT_VRSD.
        SELECT OBJTYPE
               OBJNAME
           FROM VRSD
         INTO CORRESPONDING FIELDS OF TABLE IT_VRSD
         FOR ALL ENTRIES IN IT_FM1
         WHERE OBJNAME EQ IT_FM1-OBJ_NAME AND
               OBJTYPE EQ IT_FM1-OBJTYP.
        IF SY-SUBRC NE 0.
          MESSAGE 'Invalid Object' TYPE 'E'.
        ENDIF.
*      ENDIF.

*
*  IF IT_TADIR IS NOT INITIAL.
*    SELECT OBJTYPE
*           OBJNAME
*      FROM VRSD
*      INTO CORRESPONDING FIELDS OF TABLE IT_VRSD
*      FOR ALL ENTRIES IN IT_TADIR
*      WHERE OBJNAME EQ IT_TADIR-OBJ_NAME.
*  ENDIF.
      WHEN 'FUGR'.

*          IF WA_FM1-OBJTYP = 'FUGR'.
*            CLEAR : LV_FUGR_NAME, LV_PROGNAME.
*            LV_FUGR_NAME = WA_FM1-OBJ_NAME.
*            CALL FUNCTION 'RS_TADIR_TO_PROGNAME'
*              EXPORTING
*                OBJECT   = 'FUGR'
*                OBJ_NAME = LV_FUGR_NAME
*              IMPORTING
*                PROGNAME = LV_PROGNAME.
*            WA_FM1-OBJ_NAME = LV_PROGNAME.
*            MODIFY IT_FM1 FROM WA_FM1 INDEX SY-TABIX.
*          ENDIF.
*        IF NOT IT_FM1 IS INITIAL.
*          SELECT FUNCNAME INTO TABLE IT_FM "CORRESPONDING FIELDS OF TABLE it_tfdir
*          FROM TFDIR
*          FOR ALL ENTRIES IN IT_FM1
*          WHERE PNAME = IT_FM1-OBJ_NAME.
*
*          IF NOT IT_FM IS INITIAL.
*            SELECT OBJTYPE
*                 OBJNAME
*             FROM VRSD
*           INTO CORRESPONDING FIELDS OF TABLE IT_VRSD
*            FOR ALL ENTRIES IN IT_FM
*           WHERE OBJNAME = IT_FM-OBJNAME. "it_tfdir-funcname.
*          ENDIF.
*          IF SY-SUBRC = 0.
*          ENDIF.
*        ENDIF.
    ENDCASE.
    CLEAR WA_FM1.
  ENDLOOP.
*----------------------------------------------------------------------*
    LOOP AT IT_VRSD INTO WA_VRSD.

      CLEAR: LV_PROG,
             LV_TYPE.

      REFRESH: LT_TAB , LT_TAB1, LT_TAB2.

      LV_PROG = WA_VRSD-OBJNAME.
      LV_TYPE = WA_VRSD-OBJTYPE.

*      LOOP AT so_prog INTO lw_prog.
*        lv_prog = lw_prog-low.

      CALL FUNCTION 'SVRS_GET_VERSION_DIRECTORY_46'
        EXPORTING
          OBJNAME      = LV_PROG
          OBJTYPE      = LV_TYPE
        TABLES
          LVERSNO_LIST = LT_TAB
          VERSION_LIST = LT_TAB1.
      IF SY-SUBRC <> 0.
* Implement suitable error handling here
      ENDIF.


      SORT LT_TAB1 BY VERSNO DESCENDING.
      DO 2 TIMES.
        READ TABLE LT_TAB1 INTO LWA_TAB1 INDEX SY-INDEX.
        APPEND LWA_TAB1 TO LT_TAB2.
      ENDDO.


      READ TABLE LT_TAB2 INDEX 1 INTO LS_VERS_1.
      READ TABLE LT_TAB2 INDEX 2 INTO LS_VERS_2.
      CALL FUNCTION 'SVRS_SHORT2LONG_NAME'
        EXPORTING
          OBJTYPE       = LS_VERS_1-OBJTYPE
          OBJNAME_SHORT = LS_VERS_1-OBJNAME
        IMPORTING
          OBJNAME_LONG  = LV_OBJNAME1_L.

      CALL FUNCTION 'SVRS_SHORT2LONG_NAME'
        EXPORTING
          OBJTYPE       = LS_VERS_2-OBJTYPE
          OBJNAME_SHORT = LS_VERS_2-OBJNAME
        IMPORTING
          OBJNAME_LONG  = LV_OBJNAME2_L.

*    IF LV_TYPE EQ 'REPS'.
      IF LS_VERS_1 IS NOT INITIAL .
        CALL FUNCTION 'SVRS_GET_REPS_FROM_OBJECT'
          EXPORTING
            OBJECT_NAME = LV_OBJNAME2_L
            OBJECT_TYPE = LV_TYPE
            VERSNO      = LS_VERS_1-VERSNO
*           DESTINATION = ' '
*           IV_NO_RELEASE_TRANSFORMATION       = ' '
          TABLES
            REPOS_TAB   = ABAPTEXT_SEC1
            TRDIR_TAB   = TRDIR_SEC1.
        IF SY-SUBRC <> 0.
* Implement suitable error handling here
        ENDIF.
      ENDIF.
      IF LS_VERS_2 IS NOT INITIAL.
        CALL FUNCTION 'SVRS_GET_REPS_FROM_OBJECT'
          EXPORTING
            OBJECT_NAME = LV_OBJNAME2_L
            OBJECT_TYPE = LV_TYPE
            VERSNO      = LS_VERS_2-VERSNO
          TABLES
            REPOS_TAB   = ABAPTEXT_SEC2
            TRDIR_TAB   = TRDIR_SEC2.
        IF SY-SUBRC <> 0.
* Implement suitable error handling here
        ENDIF.
      ENDIF.


      IF ABAPTEXT_SEC1[] NE ABAPTEXT_SEC2[].
        WA_DISPLAY-OBJ_NAME = LV_OBJNAME2_L.
        WA_DISPLAY-OBJ_TYP = LV_TYPE.
        WA_DISPLAY-FLAG = 'Changes Present'.
        APPEND WA_DISPLAY TO IT_DISPLAY.
        CLEAR WA_DISPLAY.
      ELSE.
        WA_DISPLAY-OBJ_NAME = LV_OBJNAME2_L.
        WA_DISPLAY-OBJ_TYP = LV_TYPE.
        WA_DISPLAY-FLAG = 'Reset to Original'.
        APPEND WA_DISPLAY TO IT_DISPLAY.
        CLEAR WA_DISPLAY.
      ENDIF.
*    ENDIF.


    ENDLOOP.

  PERFORM BUILD_FIELDCATALOG.

  PERFORM BUILD_ALV.

*&---------------------------------------------------------------------*
*& Form BUILD_FIELDCATALOG
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM BUILD_FIELDCATALOG .



  CLEAR: WA_FIELDCAT.
  WA_FIELDCAT-COL_POS   = 1.
  WA_FIELDCAT-FIELDNAME = 'OBJ_TYP'.
  WA_FIELDCAT-SELTEXT_M = 'Object type'.
  APPEND WA_FIELDCAT TO IT_FIELDCAT.

  CLEAR: WA_FIELDCAT.
  WA_FIELDCAT-COL_POS   = 2.
  WA_FIELDCAT-FIELDNAME = 'OBJ_NAME'.
  WA_FIELDCAT-SELTEXT_M = 'Object Name'.
  WA_FIELDCAT-OUTPUTLEN =  20.
  APPEND WA_FIELDCAT TO IT_FIELDCAT.


  CLEAR: WA_FIELDCAT.
  WA_FIELDCAT-COL_POS   = 3.
  WA_FIELDCAT-FIELDNAME = 'FLAG'.
  WA_FIELDCAT-SELTEXT_M = 'Status'.
  WA_FIELDCAT-OUTPUTLEN =  25.
  APPEND WA_FIELDCAT TO IT_FIELDCAT.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form BUILD_ALV
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM BUILD_ALV .

  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
    EXPORTING
      I_CALLBACK_PROGRAM = SY-REPID
      IT_FIELDCAT        = IT_FIELDCAT
      I_SAVE             = 'X'
    TABLES
      T_OUTTAB           = IT_DISPLAY
    EXCEPTIONS
      PROGRAM_ERROR      = 1
      OTHERS             = 2.
  IF SY-SUBRC <> 0.
* Implement suitable error handling here
  ENDIF.
ENDFORM.
