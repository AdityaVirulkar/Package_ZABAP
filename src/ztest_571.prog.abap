REPORT ZVIM_PODSCANLINK1.

DATA LT_LIST TYPE TABLE OF SALFLDIR.
DATA LS_LIST TYPE SALFLDIR.

DATA LC_PATH TYPE SAEPFAD.
DATA LV_ARCDOCID TYPE SAEARDOID.

PARAMETERS: P_DTYPE TYPE SAPB-SAPDOKTYP DEFAULT 'ZPOD'.
PARAMETERS: P_ARCID TYPE TOAAR-ARCHIV_ID DEFAULT 'V1'.

TYPES:      BEGIN OF TY_DATA,
            FLD1(100),
            FLD2(100),
            FLD3(100),
            FLD4(100),
            FLD5(100),
            FLD6(100),
            FLD7(100),
            FLD8(100),
            FLD9(100),
            FLD10(100),
            FLD11(100),
            END OF TY_DATA.
DATA: T_DATA TYPE TABLE OF TY_DATA.
DATA: L_DATA TYPE TY_DATA.

PARAMETERS: P_DIR TYPE PFEFLNAMEL DEFAULT
'C:\Enterprise Scan\Archive\1\'.

START-OF-SELECTION.
* get the list of files
  BREAK-POINT.
* get the folder contents
  CALL FUNCTION 'RZL_READ_DIR_LOCAL'
    EXPORTING
      NAME           = P_DIR
    TABLES
      FILE_TBL       = LT_LIST
    EXCEPTIONS
      ARGUMENT_ERROR = 1
      NOT_FOUND      = 2
      OTHERS         = 3.
  IF SY-SUBRC <> 0.
    WRITE: / SY-DATUM, SY-UZEIT, 'Error RZL_READ_DIR_LOCAL failed with RC', SY-SUBRC.
    EXIT.
  ENDIF.

  DATA: LS_FILENAME TYPE STRING.
  DATA: LW_TEXT(1000).

  LOOP AT LT_LIST INTO LS_LIST.

    IF SY-TABIX EQ '3'.

     CONCATENATE P_DIR
                 LS_LIST-NAME
                  '_line                  'COMMANDS'
            INTO LS_FILENAME.

* open in text mode
*      OPEN DATASET  ls_filename FOR INPUT  in binary mode .
*      if sy-subrc eq 0.
*        READ DATASET LS_FILENAME INTO lw_text.
*        WRITE: / lw_text.

CALL FUNCTION 'GUI_UPLOAD'
  EXPORTING
    FILENAME                      = LS_FILENAME
    FILETYPE                      = 'ASC'
    READ_BY_LINE                  = 'X'
   IGNORE_CERR                    = ABAP_TRUE
   REPLACEMENT                    = '#'
  TABLES
    DATA_TAB                      = T_DATA
EXCEPTIONS
   FILE_OPEN_ERROR               = 1
   FILE_READ_ERROR               = 2
   NO_BATCH                      = 3
   GUI_REFUSE_FILETRANSFER       = 4
   INVALID_TYPE                  = 5
   NO_AUTHORITY                  = 6
   UNKNOWN_ERROR                 = 7
   BAD_DATA_FORMAT               = 8
   HEADER_NOT_ALLOWED            = 9
   SEPARATOR_NOT_ALLOWED         = 10
   HEADER_TOO_LONG               = 11
   UNKNOWN_DP_ERROR              = 12
   ACCESS_DENIED                 = 13
   DP_OUT_OF_MEMORY              = 14
   DISK_FULL                     = 15
   DP_TIMEOUT                    = 16
OTHERS                        = 17
          .
IF SY-SUBRC <> 0.
* Implement suitable error handling here
ENDIF.
"<fnc1>944378641
"COMP data1 image/tiff 1.pg

DATA: LW_BARCODE(10).
DATA: LW_IMG(50).

LOOP AT T_DATA INTO L_DATA.

  IF L_DATA(7) EQ 'BARCODE'.
    LW_BARCODE = L_DATA+14(10).
    CONDENSE LW_BARCODE.
    WRITE:/ LW_BARCODE.
  ENDIF.

  IF L_DATA(10) EQ 'COMP data1'.
    LW_IMG = L_DATA+21(50).
    CONDENSE LW_IMG.
    WRITE:/ LW_IMG.

* GET THE BILLING DOCUMENT.
    DATA: LW_VBRK TYPE VBRK.
    DATA: LW_VBFA TYPE VBFA.
    DATA: LW_DELDOC TYPE LIKP-VBELN.


* just for test
    BREAK-POINT.
    LW_BARCODE = '0090005178'.

    CLEAR: LW_VBRK.

    SELECT SINGLE * INTO LW_VBRK FROM VBRK WHERE VBELN = LW_BARCODE.

    SELECT SINGLE * INTO LW_VBFA FROM VBFA WHERE VBELN EQ LW_VBRK-VBELN.

    IF SY-SUBRC EQ 0.
      LW_DELDOC = LW_VBFA-VBELV.
    ENDIF.

    IF SY-SUBRC EQ 0.

      CONCATENATE P_DIR
                  LS_LIST-NAME
                        '_line                        LW_IMG
                   INTO LC_PATH.
      BREAK-POINT.

*   create an entry in the archive
      CALL FUNCTION 'ARCHIVOBJECT_CREATE_SYNCHRON'
        EXPORTING
*               ARCHIV_DOC_ID            = ' '
*               ARCHIV_ID                = ' '
          DOCUMENT_TYPE                  = 'ZPOD'
*               NOTE                           = ' '
          PATH                           = LC_PATH
*               POOLINFO                       = ' '
*               SIGN                           = ' '
          TARGETARCHIV_ID                = P_ARCID
          PTC                            = 'X'
*       EXTENSION                      = ' '
          NO_ARC_DELETE                  = ' '
       IMPORTING
         ARCHIV_DOC_ID                  = LV_ARCDOCID
*              RETURN_CODE                    =
*            TABLES
*              COMPONENTS                     =
       EXCEPTIONS
        ERROR_ARCHIV                   = 1
        ERROR_COMMUNICATIONTABLE       = 2
        ERROR_KERNEL                   = 3
        OTHERS                         = 4
                .
      IF SY-SUBRC <> 0.
        WRITE: / SY-DATUM, SY-UZEIT, 'Error ARCHIVOBJECT_CREATE_SYNCHRON failed with RC', SY-SUBRC.
      ENDIF.

**Then make another call to fm ARCHIV_CONNECTION_INSERT, with the ARC_DOC_ID from earlier, and the object id of the delivery
*This call makes the link, the std delivery display transaction can then view the image using standard object services menu
      BREAK-POINT.

      DATA: LW_OBJECTID TYPE SAPB-SAPOBJID.

      LW_DELDOC = '0080003372'.

      MOVE LW_DELDOC TO LW_OBJECTID.

      CALL FUNCTION 'ARCHIV_CONNECTION_INSERT'
        EXPORTING
*               ARCHIV_ID             =
          ARC_DOC_ID            = LV_ARCDOCID
*               AR_DATE               = ' '
          AR_OBJECT             = 'ZPOD'
*               DEL_DATE              = ' '
*               MANDANT               = ' '
          OBJECT_ID             = LW_OBJECTID
          SAP_OBJECT            = 'LIKP'
*               DOC_TYPE              = ' '
*               BARCODE               = ' '
        EXCEPTIONS
          ERROR_CONNECTIONTABLE = 1
          OTHERS                = 2.
      IF SY-SUBRC <> 0.
* Implement suitable error handling here
      ENDIF.
    ENDIF.

  ENDIF.

ENDLOOP.
ENDIF.
ENDLOOP.
_
*       NO STANDARD PAGE HEADING LINE-SIZE 255.
*PARAMETERS:     p_ebeln LIKE ekko-ebeln.
*INCLUDE bdcrecx1.
*
*START-OF-SELECTION.
*
*  PERFORM open_group.
*
*  PERFORM bdc_dynpro      USING 'SAPLMLSR' '0400'.
*  PERFORM bdc_field       USING 'BDC_OKCODE'
*                                '=SELP'.
*  PERFORM bdc_field       USING 'BDC_CURSOR'
*                                'RM11P-NEW_ROW'.
*  PERFORM bdc_field       USING 'RM11P-NEW_ROW'
*                                '10'.
*  PERFORM bdc_dynpro      USING 'SAPLMLSR' '0340'.
*  PERFORM bdc_field       USING 'BDC_CURSOR'
*                                'RM11R-EBELN'.
*  PERFORM bdc_field       USING 'BDC_OKCODE'
*                                '=ENTE'.
*  PERFORM bdc_field       USING 'RM11R-EBELN'
*                                p_ebeln.
*  PERFORM bdc_dynpro      USING 'SAPLMLSR' '0400'.
*  PERFORM bdc_field       USING 'BDC_OKCODE'
*                                '=NEU'.
*  PERFORM bdc_field       USING 'BDC_CURSOR'
*                                'RM11P-NEW_ROW'.
*  PERFORM bdc_field       USING 'RM11P-NEW_ROW'
*                                '10'.
*  PERFORM bdc_dynpro      USING 'SAPLMLSR' '0400'.
*  PERFORM bdc_field       USING 'BDC_OKCODE'
*                                '/00'.
*  PERFORM bdc_field       USING 'ESSR-TXZ01'
*                                ' '.
*  PERFORM bdc_field       USING 'BDC_CURSOR'
*                                'ESSR-LZBIS'.
*  PERFORM bdc_field       USING 'ESSR-LBLNE'
*                                ' '.
*  PERFORM bdc_field       USING 'ESSR-LBLDT'
*                                '19.06.2013'.
*  PERFORM bdc_field       USING 'ESSR-DLORT'
*                                ''.
*  PERFORM bdc_field       USING 'ESSR-SBNAMAG'
*                                ' '.
*  PERFORM bdc_field       USING 'ESSR-LZVON'
*                                ' '.
*  PERFORM bdc_field       USING 'ESSR-LZBIS'
*                                ' '.
*  PERFORM bdc_field       USING 'ESSR-BLDAT'
*                                '19.06.2013'.
*  PERFORM bdc_field       USING 'ESSR-BUDAT'
*                                '19.06.2013'.
*  PERFORM bdc_field       USING 'RM11P-NEW_ROW'
*                                '10'.
*
*  PERFORM bdc_transaction USING 'ML81N'.
*
*  PERFORM close_group.
