*&---------------------------------------------------------------------*
*& Report  ZTEST_PRG
*&
*&---------------------------------------------------------------------*
REPORT  ztest_prg.
*****test for FM UPLOAD (SID 15)
****filetyp = DAT
DATA: lv_filename LIKE  rlgrap-filename.
DATA: zeile TYPE TABLE OF standard.
DATA : lv_file_size TYPE i.


CALL FUNCTION 'UPLOAD'
  EXPORTING
    filetype                = 'ASC'
  IMPORTING
    filesize                = lv_file_size
  TABLES
    data_tab                = zeile
  EXCEPTIONS
    conversion_error        = 1
    invalid_table_width     = 2
    invalid_type            = 3
    no_batch                = 4
    unknown_error           = 5
    gui_refuse_filetransfer = 6
    OTHERS                  = 7.



*****test for FM WS_UPLOAD (SID 21)
**filetyp = DAT
*DATA: lv_filename LIKE  rlgrap-filename VALUE 'C:\Users\priyanka.s.tevare\Desktop\testing.xlsx'.
DATA: zeileq TYPE TABLE OF standard.
DATA : lv_file_sizeq TYPE i.
*

CALL FUNCTION 'WS_UPLOAD'       "no filename
 EXPORTING
   FILETYPE                      = 'DAT'
 IMPORTING
   FILELENGTH                    = LV_FILE_SIZEq
  TABLES
    data_tab                      = ZEILEq
 EXCEPTIONS
   CONVERSION_ERROR              = 1
   FILE_OPEN_ERROR               = 2
   FILE_READ_ERROR               = 3
   INVALID_TYPE                  = 4
   NO_BATCH                      = 5
   UNKNOWN_ERROR                 = 6
   INVALID_TABLE_WIDTH           = 7
   GUI_REFUSE_FILETRANSFER       = 8
   CUSTOMER_ERROR                = 9
   NO_AUTHORITY                  = 10
   OTHERS                        = 11.


IF sy-subrc eq 0 .
  WRITE:/'Successful!'.
  WRITE:/ LV_FILE_SIZE.
ENDIF.


******test for FM DOWNLOAD (SID 24)
****filetyp = ASC
DATA: lv_filename22 LIKE  rlgrap-filename.
DATA: zeile22 TYPE TABLE OF standard.
DATA : lv_file_size22 TYPE i.


CALL FUNCTION 'DOWNLOAD'
 IMPORTING
   FILESIZE                      = lv_file_size22
  TABLES
    data_tab                      = ZEILE22
*   FIELDNAMES                    =
 EXCEPTIONS
   INVALID_FILESIZE              = 1
   INVALID_TABLE_WIDTH           = 2
   INVALID_TYPE                  = 3
   NO_BATCH                      = 4
   UNKNOWN_ERROR                 = 5
   GUI_REFUSE_FILETRANSFER       = 6
   OTHERS                        = 7.

IF sy-subrc eq 0 .
  WRITE:/'Successful!'.
  WRITE:/ lv_file_size22.
ENDIF.

***case2
****filetyp = DAT
DATA: lv_filename21 LIKE  rlgrap-filename.
DATA: zeile21 TYPE TABLE OF standard.
DATA : lv_file_size21 TYPE i.

CALL FUNCTION 'DOWNLOAD'
 EXPORTING
   FILENAME                      = lv_filename21
   FILETYPE                      = 'DAT'
 IMPORTING
   FILESIZE                      = lv_file_size21
  TABLES
    data_tab                      = ZEILE21
*   FIELDNAMES                    =
 EXCEPTIONS
   INVALID_FILESIZE              = 1
   INVALID_TABLE_WIDTH           = 2
   INVALID_TYPE                  = 3
   NO_BATCH                      = 4
   UNKNOWN_ERROR                 = 5
   GUI_REFUSE_FILETRANSFER       = 6
   OTHERS                        = 7.



*****test for FM WS_DOWNLOAD (SID 25)
**filetyp = ASC
DATA: lv_filename66 LIKE  rlgrap-filename.
DATA: zeile66 TYPE TABLE OF standard.
DATA : lv_file_size66 TYPE i.

CALL FUNCTION 'WS_DOWNLOAD'
 EXPORTING
   FILENAME                      = lv_filename66
   FILETYPE                      = 'DAT'
 IMPORTING
   FILELENGTH                    = lv_file_size66
  TABLES
    data_tab                      = zeile66
*   FIELDNAMES                    =
 EXCEPTIONS
   FILE_OPEN_ERROR               = 1
   FILE_WRITE_ERROR              = 2
   INVALID_FILESIZE              = 3
   INVALID_TYPE                  = 4
   NO_BATCH                      = 5
   UNKNOWN_ERROR                 = 6
   INVALID_TABLE_WIDTH           = 7
   GUI_REFUSE_FILETRANSFER       = 8
   CUSTOMER_ERROR                = 9
   NO_AUTHORITY                  = 10
   OTHERS                        = 11.



***filetyp = DAT (without exceptions)
DATA: lv_filename65 LIKE  rlgrap-filename.
DATA: zeile65 TYPE TABLE OF standard.
data: lt_fld  TYPE TABLE OF standard.
DATA : lv_file_size65 TYPE i.
*

CALL FUNCTION 'WS_DOWNLOAD'
 EXPORTING
   FILENAME                      = lv_filename65
   FILETYPE                      = 'DAT'
 IMPORTING
   FILELENGTH                    = lv_file_size65
  TABLES
    data_tab                     = zeile65
   FIELDNAMES                    = lt_fld.



*******Test ws_filename_get (SID 22)
****case1 MODE: 'S'
DATA: lv_filename_c LIKE  rlgrap-filename.
DATA: lv_def_filename_c TYPE string,
      lv_path_c TYPE string,
      lv_rc_c TYPE i,
      lv_mask1 TYPE string.

lv_mask1 = ',*.xls.'.

lv_def_filename_c = 'myfile1'.
lv_path_c = 'C:\Users\priyanka.s.tevare\Desktop'.

CALL FUNCTION 'WS_FILENAME_GET'
 EXPORTING
   DEF_FILENAME           = lv_def_filename_c
   DEF_PATH               = lv_path_c
   MASK                   = lv_mask1
   MODE                   = 'S'   "S = Save, O = Open
   TITLE                  = 'mytitle'
 IMPORTING
   FILENAME               = lv_filename_c
   RC                     = lv_rc_c
 EXCEPTIONS
   INV_WINSYS             = 1
   NO_BATCH               = 2
   SELECTION_CANCEL       = 3
   SELECTION_ERROR        = 4
   OTHERS                 = 5.


*****case2 MODE: 'O'
DATA: lv_filename_s LIKE  rlgrap-filename.
DATA: lv_def_filename_s TYPE string,
      lv_path_s TYPE string,
      lv_rc_s TYPE i,
      lv_mask2 TYPE string.

lv_mask2 = ',*.xls.'.

lv_def_filename_s = 'myfile3'.
lv_path_s = 'C:\Users\priyanka.s.tevare\Desktop'.


CALL FUNCTION 'WS_FILENAME_GET'
 EXPORTING
   DEF_FILENAME           = lv_def_filename_s
   DEF_PATH               = lv_path_s
   MASK                   = lv_mask2
   MODE                   = 'O'   "S = Save, O = Open
   TITLE                  = 'mytitle'
 IMPORTING
   FILENAME               = lv_filename_s
   RC                     = lv_rc_s
 EXCEPTIONS
   INV_WINSYS             = 1
   NO_BATCH               = 2
   SELECTION_CANCEL       = 3
   SELECTION_ERROR        = 4
   OTHERS                 = 5.


*********Test popup_to_confirm_step (SID 28)
*****CONSTANTS and variables declared
DATA :  xflag     TYPE c,
        lv_text1 TYPE string,
        lv_text2 TYPE string,
        lv_titl   TYPE string.

CONSTANTS: lc_x TYPE c VALUE 'X'.

lv_text1 = 'DO YOU WANTO  DISPLY'.
lv_text2 = 'SCREEN ?'.
lv_titl = 'mytltle'.


CALL FUNCTION 'POPUP_TO_CONFIRM_STEP'
  EXPORTING
    defaultoption  = 'Y'
    textline1      = lv_text1
    textline2      = lv_text2
    titel          = lv_titl
    start_column   = 25
    start_row      = 6
    cancel_display = lc_x
  IMPORTING
    answer         = xflag.


*"case2 (only one textline)
CALL FUNCTION 'POPUP_TO_CONFIRM_STEP'
  EXPORTING
    defaultoption  = 'Y'
    textline1      = lv_text1
    titel          = lv_titl
    start_column   = 25
    start_row      = 6
    cancel_display = lc_x
  IMPORTING
    answer         = xflag.


*********Test popup_to_decide (SID 30)
*****CONSTANTS and variables declared
DATA :  xflag1     TYPE c,
        lv_text11 TYPE string,
        lv_text21 TYPE string,
        lv_text31 TYPE string,
        lv_op1 TYPE string,
        lv_op2 TYPE string,
        lv_titl1   TYPE string.

CONSTANTS: lc_x1 TYPE c VALUE 'X',
           lc_one    TYPE c VALUE '1'.

lv_text11 = 'DWOLLEN SIE DIE VERARBEITUNG FÜR'(701).
lv_text21 = 'ALLE NOCH NICHT BEARBEITETEN'(702).
lv_text31 = 'SELEKTIERTEN OBJEKTE ABBRECHEN?'(703).
lv_titl = 'mytltle'.
lv_op1 = 'YES'.
lv_op2 = 'NO'.

CALL FUNCTION 'POPUP_TO_DECIDE'
  EXPORTING
    defaultoption  = lc_one
    textline1      = lv_text11
    textline2      = lv_text21
    textline3      = lv_text31
    text_option1   = lv_op1
    text_option2   = lv_op2
    titel          = lv_titl1
    start_column   = 25
    start_row      = 6
    cancel_display = 'X'
  IMPORTING
    answer         = xflag1.


*********Test popup_to_confirm_with_value (SID 32)
*****CONSTANTS and variables declared
DATA :  xflag3     TYPE c,
        lv_text13 TYPE string,
        lv_text23 TYPE string,
        lv_text33 TYPE string,
        lv_titl3   TYPE string.

lv_text13 = 't1'.
lv_text23 = text-001.
lv_text33 = 't2'.
lv_titl3 = 'mytltle'.


CALL FUNCTION 'POPUP_TO_CONFIRM_WITH_VALUE'
  EXPORTING
    defaultoption  = 'Y'
    objectvalue    = lv_text23
    text_after     = lv_text33
    text_before    = lv_text13
    titel          = lv_titl3
    start_column   = 25
    start_row      = 6
    cancel_display = 'X'
  IMPORTING
    answer         = xflag3
  EXCEPTIONS
    text_too_long  = 1
    OTHERS         = 2.

*********Test ws_execute (SID 34)
****CONSTANTS and variables declared
DATA: lv_doc1 TYPE string VALUE 'X',
      lv_prog TYPE string VALUE 'http://www.google.co.in'.
*

CALL FUNCTION 'WS_EXECUTE'
 EXPORTING
   DOCUMENT                 = lv_doc1
*   CD                       =
*   COMMANDLINE              = ' '
*   INFORM                   = ' '
   PROGRAM                  = lv_prog
 EXCEPTIONS
   FRONTEND_ERROR           = 1
   NO_BATCH                 = 2
   PROG_NOT_FOUND           = 3
   ILLEGAL_OPTION           = 4
   GUI_REFUSE_EXECUTE       = 5
   OTHERS                   = 6.



*********Test ws_execute (SID 35)
*****CONSTANTS and variables declared
DATA: lv_doc12 TYPE string VALUE 'X',
      lv_prog12 TYPE string VALUE 'C:\Users\priyanka.s.tevare\Desktop\ws_execute.xlsx',
      lv_comm12 TYPE string VALUE 'ws_execute.xlsx'.

CALL FUNCTION 'WS_EXECUTE'
 EXPORTING
   DOCUMENT                 = lv_doc12
*   CD                       =
   COMMANDLINE              = lv_comm12
*   INFORM                   = ' '
   PROGRAM                  = lv_prog12.


**********Test ws_file_delete (SID 36)
DATA : lv_file TYPE RLGRAP-FILENAME VALUE 'C:\Users\priyanka.s.tevare\Desktop\testing.txt' ,
       return TYPE i.

CALL FUNCTION 'WS_FILE_DELETE'
  EXPORTING
    file          = lv_file
 IMPORTING
   RETURN        = return.
DATA LV_fnam_1 type string.
DATA LV_rc_1 type I.
LV_fnam_1 =  LV_FILE.
LV_rc_1 = RETURN.



**********Test ws_WS_EXCEL (SID 40)
**Create a type
TYPES:  BEGIN OF ty_table_1,
        matnr TYPE mara-matnr,
        ersda TYPE mara-ersda,
        ernam TYPE mara-ernam,
      END OF ty_table_1.


*  create a table and workspace
DATA:
      filenamev  TYPE string,
      i_table_1 TYPE TABLE OF ty_table_1.

SELECT matnr ersda ernam
  FROM mara
  INTO TABLE i_table_1
  UP TO 10 ROWS.

filenamev ='C:\Users\priyanka.s.tevare\Desktop\tesing.xls'.

CALL FUNCTION 'WS_EXCEL'
EXPORTING
FILENAME = filenamev
*SYNCHRON = ' '
TABLES
DATA = i_table_1
EXCEPTIONS
UNKNOWN_ERROR = 1
OTHERS = 2.




******test for FM STRING_CENTER (SID 42)
*"with exceptions
DATA: lv_in TYPE char100 VALUE 'Priyanka',
      lv_out TYPE char100.

CALL FUNCTION 'STRING_CENTER'
  EXPORTING
    string         = lv_in
 IMPORTING
   CSTRING         = lv_out
 EXCEPTIONS
   TOO_SMALL       = 1
   OTHERS          = 2.



******test for FM STRING_MOVE_RIGHT (SID 43)
DATA: lv_inr TYPE string VALUE 'RIGHT',
      lv_outr TYPE char100.

CALL FUNCTION 'STRING_MOVE_RIGHT'
  EXPORTING
    string          = lv_inr
 IMPORTING
   RSTRING         = lv_outr
 EXCEPTIONS
   TOO_SMALL       = 1
   OTHERS          = 2.


IF sy-subrc eq 0.
WRITE:/ lv_inr.
WRITE:/ lv_outr.
ENDIF.



*****test for FM STRING_SPLIT (SID 47)
DATA: lv_h2 TYPE char100,
      lv_t2 TYPE char100.

CALL FUNCTION 'STRING_SPLIT'
EXPORTING
delimiter       = '.'
string          = 'testpartdhj.part2dgg'
IMPORTING
HEAD            = lv_h2
TAIL            = lv_t2
EXCEPTIONS
NOT_FOUND       = 1
NOT_VALID       = 2
TOO_LONG        = 3
TOO_SMALL       = 4
OTHERS          = 5.

IF sy-subrc eq 0.
  WRITE:/ 'head=', lv_h2.
  WRITE:/ 'tail=', lv_t2.
ENDIF.


******case1:head not provided
DATA: lv_h TYPE char100,
      lv_t TYPE char100.

CALL FUNCTION 'STRING_SPLIT'
EXPORTING
delimiter       = '.'
string          = 'testpartdhj.part2dgg'
IMPORTING
*HEAD            = lv_h
TAIL            = lv_t
EXCEPTIONS
NOT_FOUND       = 1
NOT_VALID       = 2
TOO_LONG        = 3
TOO_SMALL       = 4
OTHERS          = 5.
data lv_head_2 type char250.
data lv_tail_2 type char250.
lv_head_2 = lv_head_2.
lv_tail_2 = LV_T.
SPLIT 'TESTPARTDHJ.PART2DGG' AT '.' INTO lv_head_2 lv_tail_2.
lv_head_2 = lv_head_2.
LV_T = lv_tail_2.


IF sy-subrc eq 0.
  WRITE:/ 'head=', lv_h.
  WRITE:/ 'tail=', lv_t.
ENDIF.


********case2: tail not p[rovided
DATA: lv_h1 TYPE char100,
      lv_t1 TYPE char100.


CALL FUNCTION 'STRING_SPLIT'
EXPORTING
delimiter       = '.'
string          = 'testpartdhj.part2dgg'
IMPORTING
HEAD            = lv_h1
*TAIL            = lv_t1
EXCEPTIONS
NOT_FOUND       = 1
NOT_VALID       = 2
TOO_LONG        = 3
TOO_SMALL       = 4
OTHERS          = 5.
data lv_head_3 type char250.
data lv_tail_3 type char250.
lv_head_3 = LV_H1.
lv_tail_3 = lv_tail_3.
SPLIT 'TESTPARTDHJ.PART2DGG' AT '.' INTO lv_head_3 lv_tail_3.
LV_H1 = lv_head_3.
lv_tail_3 = lv_tail_3.


IF sy-subrc eq 0.
  WRITE:/ 'head=', lv_h1.
  WRITE:/ 'tail=', lv_t1.
ENDIF.


********test for FM STRING_LENGHT (SID 51)
DATA: lv_str TYPE string VALUE 'I AM PRIYANKA',
      lv_len  TYPE i.

CALL FUNCTION 'STRING_LENGTH'
  EXPORTING
    string        = lv_str
 IMPORTING
   LENGTH        = lv_len.


IF sy-subrc eq 0.
  WRITE:/ lv_len.
ENDIF.

********test for FM GET_FIELDTAB(SID 48)
DATA: lv_tabnam TYPE DFIES-TABNAME VALUE 'MARA',
      wa_header TYPE X030L,
      lt_tab  TYPE STANDARD TABLE OF DFIES,
      lwa_tab TYPE DFIES.

CALL FUNCTION 'GET_FIELDTAB'
 EXPORTING
   LANGU                     = SY-LANGU
*   ONLY                      = ' '
   TABNAME                   = lv_tabnam
*   WITHTEXT                  = 'X'
 IMPORTING
   HEADER                    = wa_header
*   RC                        =
  TABLES
    fieldtab                  = lt_tab
 EXCEPTIONS
   INTERNAL_ERROR            = 1
   NO_TEXTS_FOUND            = 2
   TABLE_HAS_NO_FIELDS       = 3
   TABLE_NOT_ACTIV           = 4
   OTHERS                    = 5.


********test for FM CONVERT_DATE_INPUT(SID 51)
DATA: lv_out3 TYPE sy-datum.

CALL FUNCTION 'CONVERT_DATE_INPUT'
  EXPORTING
    input                          = '20112016'
   PLAUSIBILITY_CHECK              = 'X'
 IMPORTING
   OUTPUT                          = lv_out3
 EXCEPTIONS
   PLAUSIBILITY_CHECK_FAILED       = 1
   WRONG_FORMAT_IN_INPUT           = 2
   OTHERS                          = 3.


IF sy-subrc eq 0.
  WRITE:/ lv_out3.
ENDIF.


*********test for FM SAP_TO_ISO_MEASURE_UNIT_CODE(SID 51)
DATA: lv_iso TYPE T006-ISOCODE.

CALL FUNCTION 'SAP_TO_ISO_MEASURE_UNIT_CODE'
  EXPORTING
    SAP_CODE         = 'KG'
 IMPORTING
   ISO_CODE          = lv_iso
 EXCEPTIONS
   NOT_FOUND         = 1
   NO_ISO_CODE       = 2
   OTHERS            = 3.

IF SY-SUBRC eq 0.
  WRITE:/ lv_iso.
ENDIF.


********test for FM SAP_TO_ISO_CURRENCY_CODE(SID 51)
DATA: lv_isoc TYPE TCURC-ISOCD.

CALL FUNCTION 'SAP_TO_ISO_CURRENCY_CODE'
  EXPORTING
    SAP_CODE          = 'USD'
 IMPORTING
   ISO_CODE          = lv_isoc
 EXCEPTIONS
   NOT_FOUND         = 1
   NO_ISO_CODE       = 2
   OTHERS            = 3.


IF SY-SUBRC eq 0.
  WRITE:/ lv_isoc.
ENDIF.

*******test for FM LOG_SYSTEM_GET_RFC_DESTINATION(SID 51)
tables bkpf.
data:begin of tab_rfc occurs 0,             "destination for 3rd party
 bukrs           like regup-bukrs,          "remittance
 belnr           like regup-belnr,
 gjahr           like regup-gjahr,
 dest            like tbdestination-rfcdest,
 awsys           like bkpf-awsys,
 lifnr           like regup-lifnr,
 xblnr           like regup-xblnr,
 zbukr           like reguh-zbukr,
 vblnr           like reguh-vblnr,
 zfbdt           like regup-zfbdt,
end of tab_rfc.
*
DATA: log_sys  TYPE TBLSYSDEST-LOGSYS,
      rfc_dest TYPE TBLSYSDEST-RFCDEST.

CONCATENATE sy-sysid sy-mandt INTO log_sys.
log_sys = 'ACRCLNT200'.           "data from table T000

 CALL FUNCTION 'LOG_SYSTEM_GET_RFC_DESTINATION'
 EXPORTING
 LOGICAL_SYSTEM = log_sys
 IMPORTING
 RFC_DESTINATION = rfc_dest
 EXCEPTIONS
 NO_RFC_DESTINATION_MAINTAINED       = 1
 OTHERS                              = 2.


IF sy-subrc eq 0.
  WRITE:/ TAB_RFC-DEST.
ENDIF.
**
**
********test for FM HELPSCREEN_NA_CREATE(SID 51)
CALL FUNCTION 'HELPSCREEN_NA_CREATE'
  EXPORTING
    dynpro   = '1000'
    langu    = sy-langu
   MELDUNG  = ' '
    meld_id  = 'SH'
    meld_nr  = '720'
    msgv1    = ' '
    msgv2    = ' '
    msgv3    = ' '
   MSGV4    = ' '
   PFKEY    = ' '
   PROGRAMM = ' '
    titel    = 'helppp!'.

**
**********test for FM NAMETAB_GET(SID 51)
DATA : lt_dtab TYPE STANDARD TABLE OF dntab,
      lwa_dtab TYPE dntab.

CALL FUNCTION 'NAMETAB_GET'
 EXPORTING
   LANGU                     = SY-LANGU
   ONLY                      = ' '
   TABNAME                   = 'MARA'
* IMPORTING
*   HEADER                    =
*   RC                        =
  TABLES
    NAMETAB                   = lt_dtab
 EXCEPTIONS
   INTERNAL_ERROR            = 1
   TABLE_HAS_NO_FIELDS       = 2
   TABLE_NOT_ACTIV           = 3
   NO_TEXTS_FOUND            = 4
   OTHERS                    = 5.



******test DELETING LEADING 0.
DATA: h_kunnr(10),
      p_kunnr(10),
        h_kunwe(10).

DATA: wa_kna1 TYPE kna1.


SELECT SINGLE * FROM kna1 INTO wa_kna1
WHERE kunnr = p_kunnr.

WRITE p_kunnr TO h_kunnr.

  SHIFT h_kunnr LEFT DELETING LEADING 0.

  SHIFT lv_str LEFT DELETING LEADING 0.


********Test TRANSLATE STATEMENT
****case1
DATA f(72).

TRANSLATE F FROM CODE PAGE '1110' TO CODE PAGE '0100'.

****case2
DATA f1(72).

TRANSLATE F1 FROM NUMBER FORMAT '1110' TO CODE PAGE '0100'.


***case3
DATA f2(72).
TRANSLATE F2 FROM NUMBER FORMAT '0000' TO NUMBER FORMAT '0100'.


***case4
DATA f3(72).
TRANSLATE F3 TO CODE PAGE '1110'.

***case5
DATA f4(72).
TRANSLATE F4 FROM CODE PAGE '1110'.


********CLEAR SPELL+403
tables: spell.

CLEAR SPELL+403.


********OPEN DATASET ERROR
PARAMETERS:
  p_file(100) TYPE c OBLIGATORY  LOWER CASE
             DEFAULT  'C:\Users\priyanka.s.tevare\Desktop\testing.xlsx'.
*
open dataset p_file for input.

OPEN DATASET p_file IN LEGACY TEXT MODE FOR APPENDING.     "check this case


open dataset p_file
             for APPENDING
             in text mode.


OPEN DATASET p_file for output
                    in text mode.


OPEN DATASET p_file for output in text mode.


open dataset p_file for output in binary mode.          "skiping binary mode


*********DESCRIBE STATEMENT
data : len type i.
data a(10) type c.
data type(1).


 DESCRIBE FIELD A LENGTH LEN.



*********FM HELP_VALUES_GET_NO_DD_NAME
DATA: lv_sel_ind TYPE sy-tabix,
      lv_sel_field TYPE help_info-fieldname,
      lt_tab_fld TYPE STANDARD TABLE OF help_value,
      lt_fu_table TYPE  STANDARD TABLE OF mara.

CALL FUNCTION 'HELP_VALUES_GET_NO_DD_NAME'
  EXPORTING
    CUCOL                        = 0
    CUROW                        = 0
    DISPLAY                      = ' '
    selectfield                  = lv_sel_field
    TITEL                        = 'ttileee'
*   NO_PERS_HELP_SELECT          = ' '
  IMPORTING
    IND                          = lv_sel_ind
*   SELECT_VALUE                 =
  TABLES
    fields                       = lt_tab_fld
    full_table                   = lt_fu_table
  EXCEPTIONS
    FULL_TABLE_EMPTY             = 1
    NO_TABLESTRUCTURE_GIVEN      = 2
    NO_TABLEFIELDS_IN_DICTIONARY = 3
    MORE_THEN_ONE_SELECTFIELD    = 4
    NO_SELECTFIELD               = 5
    OTHERS                       = 6.


********FM WS_QUERY
*****CASE1 :FE
DATA: g_subrc TYPE i,
      p_filen(255) TYPE c.

p_filen = 'C:\Users\priyanka.s.tevare\Desktop\testing.txt'.
CONSTANTS: lc_query(2) TYPE c VALUE 'FE'.

 CALL FUNCTION 'WS_QUERY'
 EXPORTING
 FILENAME = P_FILEN
 QUERY = lc_query
 IMPORTING
 RETURN = G_SUBRC
 EXCEPTIONS
 OTHERS = 1.



***CASE2 :FL
DATA: lenhh TYPE i,
      p_filen1(255) TYPE c.

p_filen1 = 'C:\Users\priyanka.s.tevare\Desktop\testing.txt'.

 CALL FUNCTION 'WS_QUERY'
 EXPORTING
 FILENAME = P_FILEN1
 QUERY = 'FL'
 IMPORTING
 RETURN = LENhh
 EXCEPTIONS
 OTHERS = 1.

*
*****CASE3 :XP
DATA: lv_ret TYPE string,
      p_filent(255) TYPE c.

p_filent = 'C:\Users\priyanka.s.tevare\Desktop\testing.txt'.


 CALL FUNCTION 'WS_QUERY'
 EXPORTING
 FILENAME = P_FILENt
 QUERY = 'XP'
 IMPORTING
 RETURN = LV_RET
 EXCEPTIONS
 OTHERS = 1.

**
*******CASE1 :EN
DATA: lv_ret13 TYPE string,
      p_filenf(255) TYPE c.

p_filenf = 'C:\Users\priyanka.s.tevare\Desktop\testing.txt'.

CALL FUNCTION 'WS_QUERY'
  EXPORTING
    filename = p_filenf
    query    = 'EN'
  IMPORTING
    return   = lv_ret13
  EXCEPTIONS
    OTHERS   = 1.

**CASE1 :DE
DATA: lv_ret2e TYPE string,
      p_filen1e(255) TYPE c.

p_filen1 = 'C:\Users\priyanka.s.tevare\Desktop\testing.txt'.

CALL FUNCTION 'WS_QUERY'
  EXPORTING
    filename = p_filen1e
    query    = 'DE'
  IMPORTING
    return   = lv_ret2e
  EXCEPTIONS
    OTHERS   = 1.

***CASE1 :CD  "current directory
DATA: lv_retb TYPE string.

CALL FUNCTION 'WS_QUERY'
  EXPORTING
    filename = ' '
    query    = 'CD'
  IMPORTING
    return   = lv_retb
  EXCEPTIONS
    OTHERS   = 1.


****CASE2 :OS
DATA returnf(10) TYPE c.

CALL FUNCTION 'WS_QUERY'
  EXPORTING
    environment = ' '
    filename    = ' '
    query       = 'OS'
    winid       = ' '
  IMPORTING
    return      = returnf.

IF sy-subrc EQ 0.
  WRITE returnf.
ENDIF.

***CASE2 :WS
data returnd(10) type c.

 CALL FUNCTION 'WS_QUERY'
 EXPORTING
 QUERY = 'WS'
 IMPORTING
 RETURN = RETURNd.

*******Test ws_filename_get (SID 22)
DATA: lv_filenamevv LIKE  rlgrap-filename.
DATA: lv_def_filename TYPE string,
      lv_path TYPE string,
      lv_rc TYPE i.

lv_def_filename = 'myfile'.
lv_path = 'C:\Users\priyanka.s.tevare\Desktop'.


CALL FUNCTION 'WS_FILENAME_GET'
 EXPORTING
   DEF_FILENAME           = lv_def_filename
   DEF_PATH               = lv_path
   MASK                   = ' '
   MODE                   = 'O'   "S = Save, O = Open
   TITLE                  = 'mytitle'
 IMPORTING
   FILENAME               = lv_filenamevv
   RC                     = lv_rc
 EXCEPTIONS
   INV_WINSYS             = 1
   NO_BATCH               = 2
   SELECTION_CANCEL       = 3
   SELECTION_ERROR        = 4
   OTHERS                 = 5.

case2 type O
DATA: lv_filename9 LIKE  rlgrap-filename.
DATA: lv_def_filename9 TYPE string,
      lv_path9 TYPE string,
      lv_rc9 TYPE i.

lv_def_filename9 = 'myfile'.
lv_path9 = 'C:\Users\priyanka.s.tevare\Desktop'.

CALL FUNCTION 'WS_FILENAME_GET'
 EXPORTING
   DEF_FILENAME           = lv_def_filename9
   DEF_PATH               = lv_path9
   MASK                   = ' ,txt,'
   MODE                   = 'O'   "S = Save, O = Open
   TITLE                  = 'mytitle'
 IMPORTING
   FILENAME               = lv_filename9
   RC                     = lv_rc9
 EXCEPTIONS
   INV_WINSYS             = 1
   NO_BATCH               = 2
   SELECTION_CANCEL       = 3
   SELECTION_ERROR        = 4
   OTHERS                 = 5.*&---------------------------------------------------------------------*
*& Report  ZTEST_PRG
*&
*&---------------------------------------------------------------------*
REPORT  ztest_prg.
*****test for FM UPLOAD (SID 15)
****filetyp = DAT
DATA: lv_filename LIKE  rlgrap-filename.
DATA: zeile TYPE TABLE OF standard.
DATA : lv_file_size TYPE i.


CALL FUNCTION 'UPLOAD'
  EXPORTING
    filetype                = 'ASC'
  IMPORTING
    filesize                = lv_file_size
  TABLES
    data_tab                = zeile
  EXCEPTIONS
    conversion_error        = 1
    invalid_table_width     = 2
    invalid_type            = 3
    no_batch                = 4
    unknown_error           = 5
    gui_refuse_filetransfer = 6
    OTHERS                  = 7.



*****test for FM WS_UPLOAD (SID 21)
**filetyp = DAT
*DATA: lv_filename LIKE  rlgrap-filename VALUE 'C:\Users\priyanka.s.tevare\Desktop\testing.xlsx'.
DATA: zeileq TYPE TABLE OF standard.
DATA : lv_file_sizeq TYPE i.
*

CALL FUNCTION 'WS_UPLOAD'       "no filename
 EXPORTING
   FILETYPE                      = 'DAT'
 IMPORTING
   FILELENGTH                    = LV_FILE_SIZEq
  TABLES
    data_tab                      = ZEILEq
 EXCEPTIONS
   CONVERSION_ERROR              = 1
   FILE_OPEN_ERROR               = 2
   FILE_READ_ERROR               = 3
   INVALID_TYPE                  = 4
   NO_BATCH                      = 5
   UNKNOWN_ERROR                 = 6
   INVALID_TABLE_WIDTH           = 7
   GUI_REFUSE_FILETRANSFER       = 8
   CUSTOMER_ERROR                = 9
   NO_AUTHORITY                  = 10
   OTHERS                        = 11.


IF sy-subrc eq 0 .
  WRITE:/'Successful!'.
  WRITE:/ LV_FILE_SIZE.
ENDIF.


******test for FM DOWNLOAD (SID 24)
****filetyp = ASC
DATA: lv_filename22 LIKE  rlgrap-filename.
DATA: zeile22 TYPE TABLE OF standard.
DATA : lv_file_size22 TYPE i.


CALL FUNCTION 'DOWNLOAD'
 IMPORTING
   FILESIZE                      = lv_file_size22
  TABLES
    data_tab                      = ZEILE22
*   FIELDNAMES                    =
 EXCEPTIONS
   INVALID_FILESIZE              = 1
   INVALID_TABLE_WIDTH           = 2
   INVALID_TYPE                  = 3
   NO_BATCH                      = 4
   UNKNOWN_ERROR                 = 5
   GUI_REFUSE_FILETRANSFER       = 6
   OTHERS                        = 7.

IF sy-subrc eq 0 .
  WRITE:/'Successful!'.
  WRITE:/ lv_file_size22.
ENDIF.

***case2
****filetyp = DAT
DATA: lv_filename21 LIKE  rlgrap-filename.
DATA: zeile21 TYPE TABLE OF standard.
DATA : lv_file_size21 TYPE i.

CALL FUNCTION 'DOWNLOAD'
 EXPORTING
   FILENAME                      = lv_filename21
   FILETYPE                      = 'DAT'
 IMPORTING
   FILESIZE                      = lv_file_size21
  TABLES
    data_tab                      = ZEILE21
*   FIELDNAMES                    =
 EXCEPTIONS
   INVALID_FILESIZE              = 1
   INVALID_TABLE_WIDTH           = 2
   INVALID_TYPE                  = 3
   NO_BATCH                      = 4
   UNKNOWN_ERROR                 = 5
   GUI_REFUSE_FILETRANSFER       = 6
   OTHERS                        = 7.



*****test for FM WS_DOWNLOAD (SID 25)
**filetyp = ASC
DATA: lv_filename66 LIKE  rlgrap-filename.
DATA: zeile66 TYPE TABLE OF standard.
DATA : lv_file_size66 TYPE i.

CALL FUNCTION 'WS_DOWNLOAD'
 EXPORTING
   FILENAME                      = lv_filename66
   FILETYPE                      = 'DAT'
 IMPORTING
   FILELENGTH                    = lv_file_size66
  TABLES
    data_tab                      = zeile66
*   FIELDNAMES                    =
 EXCEPTIONS
   FILE_OPEN_ERROR               = 1
   FILE_WRITE_ERROR              = 2
   INVALID_FILESIZE              = 3
   INVALID_TYPE                  = 4
   NO_BATCH                      = 5
   UNKNOWN_ERROR                 = 6
   INVALID_TABLE_WIDTH           = 7
   GUI_REFUSE_FILETRANSFER       = 8
   CUSTOMER_ERROR                = 9
   NO_AUTHORITY                  = 10
   OTHERS                        = 11.



***filetyp = DAT (without exceptions)
DATA: lv_filename65 LIKE  rlgrap-filename.
DATA: zeile65 TYPE TABLE OF standard.
data: lt_fld  TYPE TABLE OF standard.
DATA : lv_file_size65 TYPE i.
*

CALL FUNCTION 'WS_DOWNLOAD'
 EXPORTING
   FILENAME                      = lv_filename65
   FILETYPE                      = 'DAT'
 IMPORTING
   FILELENGTH                    = lv_file_size65
  TABLES
    data_tab                     = zeile65
   FIELDNAMES                    = lt_fld.



*******Test ws_filename_get (SID 22)
****case1 MODE: 'S'
DATA: lv_filename_c LIKE  rlgrap-filename.
DATA: lv_def_filename_c TYPE string,
      lv_path_c TYPE string,
      lv_rc_c TYPE i,
      lv_mask1 TYPE string.

lv_mask1 = ',*.xls.'.

lv_def_filename_c = 'myfile1'.
lv_path_c = 'C:\Users\priyanka.s.tevare\Desktop'.

CALL FUNCTION 'WS_FILENAME_GET'
 EXPORTING
   DEF_FILENAME           = lv_def_filename_c
   DEF_PATH               = lv_path_c
   MASK                   = lv_mask1
   MODE                   = 'S'   "S = Save, O = Open
   TITLE                  = 'mytitle'
 IMPORTING
   FILENAME               = lv_filename_c
   RC                     = lv_rc_c
 EXCEPTIONS
   INV_WINSYS             = 1
   NO_BATCH               = 2
   SELECTION_CANCEL       = 3
   SELECTION_ERROR        = 4
   OTHERS                 = 5.


*****case2 MODE: 'O'
DATA: lv_filename_s LIKE  rlgrap-filename.
DATA: lv_def_filename_s TYPE string,
      lv_path_s TYPE string,
      lv_rc_s TYPE i,
      lv_mask2 TYPE string.

lv_mask2 = ',*.xls.'.

lv_def_filename_s = 'myfile3'.
lv_path_s = 'C:\Users\priyanka.s.tevare\Desktop'.


CALL FUNCTION 'WS_FILENAME_GET'
 EXPORTING
   DEF_FILENAME           = lv_def_filename_s
   DEF_PATH               = lv_path_s
   MASK                   = lv_mask2
   MODE                   = 'O'   "S = Save, O = Open
   TITLE                  = 'mytitle'
 IMPORTING
   FILENAME               = lv_filename_s
   RC                     = lv_rc_s
 EXCEPTIONS
   INV_WINSYS             = 1
   NO_BATCH               = 2
   SELECTION_CANCEL       = 3
   SELECTION_ERROR        = 4
   OTHERS                 = 5.


*********Test popup_to_confirm_step (SID 28)
*****CONSTANTS and variables declared
DATA :  xflag     TYPE c,
        lv_text1 TYPE string,
        lv_text2 TYPE string,
        lv_titl   TYPE string.

CONSTANTS: lc_x TYPE c VALUE 'X'.

lv_text1 = 'DO YOU WANTO  DISPLY'.
lv_text2 = 'SCREEN ?'.
lv_titl = 'mytltle'.


CALL FUNCTION 'POPUP_TO_CONFIRM_STEP'
  EXPORTING
    defaultoption  = 'Y'
    textline1      = lv_text1
    textline2      = lv_text2
    titel          = lv_titl
    start_column   = 25
    start_row      = 6
    cancel_display = lc_x
  IMPORTING
    answer         = xflag.


*"case2 (only one textline)
CALL FUNCTION 'POPUP_TO_CONFIRM_STEP'
  EXPORTING
    defaultoption  = 'Y'
    textline1      = lv_text1
    titel          = lv_titl
    start_column   = 25
    start_row      = 6
    cancel_display = lc_x
  IMPORTING
    answer         = xflag.


*********Test popup_to_decide (SID 30)
*****CONSTANTS and variables declared
DATA :  xflag1     TYPE c,
        lv_text11 TYPE string,
        lv_text21 TYPE string,
        lv_text31 TYPE string,
        lv_op1 TYPE string,
        lv_op2 TYPE string,
        lv_titl1   TYPE string.

CONSTANTS: lc_x1 TYPE c VALUE 'X',
           lc_one    TYPE c VALUE '1'.

lv_text11 = 'DWOLLEN SIE DIE VERARBEITUNG FÜR'(701).
lv_text21 = 'ALLE NOCH NICHT BEARBEITETEN'(702).
lv_text31 = 'SELEKTIERTEN OBJEKTE ABBRECHEN?'(703).
lv_titl = 'mytltle'.
lv_op1 = 'YES'.
lv_op2 = 'NO'.

CALL FUNCTION 'POPUP_TO_DECIDE'
  EXPORTING
    defaultoption  = lc_one
    textline1      = lv_text11
    textline2      = lv_text21
    textline3      = lv_text31
    text_option1   = lv_op1
    text_option2   = lv_op2
    titel          = lv_titl1
    start_column   = 25
    start_row      = 6
    cancel_display = 'X'
  IMPORTING
    answer         = xflag1.


*********Test popup_to_confirm_with_value (SID 32)
*****CONSTANTS and variables declared
DATA :  xflag3     TYPE c,
        lv_text13 TYPE string,
        lv_text23 TYPE string,
        lv_text33 TYPE string,
        lv_titl3   TYPE string.

lv_text13 = 't1'.
lv_text23 = text-001.
lv_text33 = 't2'.
lv_titl3 = 'mytltle'.


CALL FUNCTION 'POPUP_TO_CONFIRM_WITH_VALUE'
  EXPORTING
    defaultoption  = 'Y'
    objectvalue    = lv_text23
    text_after     = lv_text33
    text_before    = lv_text13
    titel          = lv_titl3
    start_column   = 25
    start_row      = 6
    cancel_display = 'X'
  IMPORTING
    answer         = xflag3
  EXCEPTIONS
    text_too_long  = 1
    OTHERS         = 2.

*********Test ws_execute (SID 34)
****CONSTANTS and variables declared
DATA: lv_doc1 TYPE string VALUE 'X',
      lv_prog TYPE string VALUE 'http://www.google.co.in'.
*

CALL FUNCTION 'WS_EXECUTE'
 EXPORTING
   DOCUMENT                 = lv_doc1
*   CD                       =
*   COMMANDLINE              = ' '
*   INFORM                   = ' '
   PROGRAM                  = lv_prog
 EXCEPTIONS
   FRONTEND_ERROR           = 1
   NO_BATCH                 = 2
   PROG_NOT_FOUND           = 3
   ILLEGAL_OPTION           = 4
   GUI_REFUSE_EXECUTE       = 5
   OTHERS                   = 6.



*********Test ws_execute (SID 35)
*****CONSTANTS and variables declared
DATA: lv_doc12 TYPE string VALUE 'X',
      lv_prog12 TYPE string VALUE 'C:\Users\priyanka.s.tevare\Desktop\ws_execute.xlsx',
      lv_comm12 TYPE string VALUE 'ws_execute.xlsx'.

CALL FUNCTION 'WS_EXECUTE'
 EXPORTING
   DOCUMENT                 = lv_doc12
*   CD                       =
   COMMANDLINE              = lv_comm12
*   INFORM                   = ' '
   PROGRAM                  = lv_prog12.


**********Test ws_file_delete (SID 36)
DATA : lv_file TYPE RLGRAP-FILENAME VALUE 'C:\Users\priyanka.s.tevare\Desktop\testing.txt' ,
       return TYPE i.

CALL FUNCTION 'WS_FILE_DELETE'
  EXPORTING
    file          = lv_file
 IMPORTING
   RETURN        = return.
DATA LV_fnam_1 type string.
DATA LV_rc_1 type I.
LV_fnam_1 =  LV_FILE.
LV_rc_1 = RETURN.



**********Test ws_WS_EXCEL (SID 40)
**Create a type
TYPES:  BEGIN OF ty_table_1,
        matnr TYPE mara-matnr,
        ersda TYPE mara-ersda,
        ernam TYPE mara-ernam,
      END OF ty_table_1.


*  create a table and workspace
DATA:
      filenamev  TYPE string,
      i_table_1 TYPE TABLE OF ty_table_1.

SELECT matnr ersda ernam
  FROM mara
  INTO TABLE i_table_1
  UP TO 10 ROWS.

filenamev ='C:\Users\priyanka.s.tevare\Desktop\tesing.xls'.

CALL FUNCTION 'WS_EXCEL'
EXPORTING
FILENAME = filenamev
*SYNCHRON = ' '
TABLES
DATA = i_table_1
EXCEPTIONS
UNKNOWN_ERROR = 1
OTHERS = 2.




******test for FM STRING_CENTER (SID 42)
*"with exceptions
DATA: lv_in TYPE char100 VALUE 'Priyanka',
      lv_out TYPE char100.

CALL FUNCTION 'STRING_CENTER'
  EXPORTING
    string         = lv_in
 IMPORTING
   CSTRING         = lv_out
 EXCEPTIONS
   TOO_SMALL       = 1
   OTHERS          = 2.



******test for FM STRING_MOVE_RIGHT (SID 43)
DATA: lv_inr TYPE string VALUE 'RIGHT',
      lv_outr TYPE char100.

CALL FUNCTION 'STRING_MOVE_RIGHT'
  EXPORTING
    string          = lv_inr
 IMPORTING
   RSTRING         = lv_outr
 EXCEPTIONS
   TOO_SMALL       = 1
   OTHERS          = 2.


IF sy-subrc eq 0.
WRITE:/ lv_inr.
WRITE:/ lv_outr.
ENDIF.



*****test for FM STRING_SPLIT (SID 47)
DATA: lv_h2 TYPE char100,
      lv_t2 TYPE char100.

CALL FUNCTION 'STRING_SPLIT'
EXPORTING
delimiter       = '.'
string          = 'testpartdhj.part2dgg'
IMPORTING
HEAD            = lv_h2
TAIL            = lv_t2
EXCEPTIONS
NOT_FOUND       = 1
NOT_VALID       = 2
TOO_LONG        = 3
TOO_SMALL       = 4
OTHERS          = 5.

IF sy-subrc eq 0.
  WRITE:/ 'head=', lv_h2.
  WRITE:/ 'tail=', lv_t2.
ENDIF.


******case1:head not provided
DATA: lv_h TYPE char100,
      lv_t TYPE char100.

CALL FUNCTION 'STRING_SPLIT'
EXPORTING
delimiter       = '.'
string          = 'testpartdhj.part2dgg'
IMPORTING
*HEAD            = lv_h
TAIL            = lv_t
EXCEPTIONS
NOT_FOUND       = 1
NOT_VALID       = 2
TOO_LONG        = 3
TOO_SMALL       = 4
OTHERS          = 5.
data lv_head_2 type char250.
data lv_tail_2 type char250.
lv_head_2 = lv_head_2.
lv_tail_2 = LV_T.
SPLIT 'TESTPARTDHJ.PART2DGG' AT '.' INTO lv_head_2 lv_tail_2.
lv_head_2 = lv_head_2.
LV_T = lv_tail_2.


IF sy-subrc eq 0.
  WRITE:/ 'head=', lv_h.
  WRITE:/ 'tail=', lv_t.
ENDIF.


********case2: tail not p[rovided
DATA: lv_h1 TYPE char100,
      lv_t1 TYPE char100.


CALL FUNCTION 'STRING_SPLIT'
EXPORTING
delimiter       = '.'
string          = 'testpartdhj.part2dgg'
IMPORTING
HEAD            = lv_h1
*TAIL            = lv_t1
EXCEPTIONS
NOT_FOUND       = 1
NOT_VALID       = 2
TOO_LONG        = 3
TOO_SMALL       = 4
OTHERS          = 5.
data lv_head_3 type char250.
data lv_tail_3 type char250.
lv_head_3 = LV_H1.
lv_tail_3 = lv_tail_3.
SPLIT 'TESTPARTDHJ.PART2DGG' AT '.' INTO lv_head_3 lv_tail_3.
LV_H1 = lv_head_3.
lv_tail_3 = lv_tail_3.


IF sy-subrc eq 0.
  WRITE:/ 'head=', lv_h1.
  WRITE:/ 'tail=', lv_t1.
ENDIF.


********test for FM STRING_LENGHT (SID 51)
DATA: lv_str TYPE string VALUE 'I AM PRIYANKA',
      lv_len  TYPE i.

CALL FUNCTION 'STRING_LENGTH'
  EXPORTING
    string        = lv_str
 IMPORTING
   LENGTH        = lv_len.


IF sy-subrc eq 0.
  WRITE:/ lv_len.
ENDIF.

********test for FM GET_FIELDTAB(SID 48)
DATA: lv_tabnam TYPE DFIES-TABNAME VALUE 'MARA',
      wa_header TYPE X030L,
      lt_tab  TYPE STANDARD TABLE OF DFIES,
      lwa_tab TYPE DFIES.

CALL FUNCTION 'GET_FIELDTAB'
 EXPORTING
   LANGU                     = SY-LANGU
*   ONLY                      = ' '
   TABNAME                   = lv_tabnam
*   WITHTEXT                  = 'X'
 IMPORTING
   HEADER                    = wa_header
*   RC                        =
  TABLES
    fieldtab                  = lt_tab
 EXCEPTIONS
   INTERNAL_ERROR            = 1
   NO_TEXTS_FOUND            = 2
   TABLE_HAS_NO_FIELDS       = 3
   TABLE_NOT_ACTIV           = 4
   OTHERS                    = 5.


********test for FM CONVERT_DATE_INPUT(SID 51)
DATA: lv_out3 TYPE sy-datum.

CALL FUNCTION 'CONVERT_DATE_INPUT'
  EXPORTING
    input                          = '20112016'
   PLAUSIBILITY_CHECK              = 'X'
 IMPORTING
   OUTPUT                          = lv_out3
 EXCEPTIONS
   PLAUSIBILITY_CHECK_FAILED       = 1
   WRONG_FORMAT_IN_INPUT           = 2
   OTHERS                          = 3.


IF sy-subrc eq 0.
  WRITE:/ lv_out3.
ENDIF.


*********test for FM SAP_TO_ISO_MEASURE_UNIT_CODE(SID 51)
DATA: lv_iso TYPE T006-ISOCODE.

CALL FUNCTION 'SAP_TO_ISO_MEASURE_UNIT_CODE'
  EXPORTING
    SAP_CODE         = 'KG'
 IMPORTING
   ISO_CODE          = lv_iso
 EXCEPTIONS
   NOT_FOUND         = 1
   NO_ISO_CODE       = 2
   OTHERS            = 3.

IF SY-SUBRC eq 0.
  WRITE:/ lv_iso.
ENDIF.


********test for FM SAP_TO_ISO_CURRENCY_CODE(SID 51)
DATA: lv_isoc TYPE TCURC-ISOCD.

CALL FUNCTION 'SAP_TO_ISO_CURRENCY_CODE'
  EXPORTING
    SAP_CODE          = 'USD'
 IMPORTING
   ISO_CODE          = lv_isoc
 EXCEPTIONS
   NOT_FOUND         = 1
   NO_ISO_CODE       = 2
   OTHERS            = 3.


IF SY-SUBRC eq 0.
  WRITE:/ lv_isoc.
ENDIF.

*******test for FM LOG_SYSTEM_GET_RFC_DESTINATION(SID 51)
tables bkpf.
data:begin of tab_rfc occurs 0,             "destination for 3rd party
 bukrs           like regup-bukrs,          "remittance
 belnr           like regup-belnr,
 gjahr           like regup-gjahr,
 dest            like tbdestination-rfcdest,
 awsys           like bkpf-awsys,
 lifnr           like regup-lifnr,
 xblnr           like regup-xblnr,
 zbukr           like reguh-zbukr,
 vblnr           like reguh-vblnr,
 zfbdt           like regup-zfbdt,
end of tab_rfc.
*
DATA: log_sys  TYPE TBLSYSDEST-LOGSYS,
      rfc_dest TYPE TBLSYSDEST-RFCDEST.

CONCATENATE sy-sysid sy-mandt INTO log_sys.
log_sys = 'ACRCLNT200'.           "data from table T000

 CALL FUNCTION 'LOG_SYSTEM_GET_RFC_DESTINATION'
 EXPORTING
 LOGICAL_SYSTEM = log_sys
 IMPORTING
 RFC_DESTINATION = rfc_dest
 EXCEPTIONS
 NO_RFC_DESTINATION_MAINTAINED       = 1
 OTHERS                              = 2.


IF sy-subrc eq 0.
  WRITE:/ TAB_RFC-DEST.
ENDIF.
**
**
********test for FM HELPSCREEN_NA_CREATE(SID 51)
CALL FUNCTION 'HELPSCREEN_NA_CREATE'
  EXPORTING
    dynpro   = '1000'
    langu    = sy-langu
   MELDUNG  = ' '
    meld_id  = 'SH'
    meld_nr  = '720'
    msgv1    = ' '
    msgv2    = ' '
    msgv3    = ' '
   MSGV4    = ' '
   PFKEY    = ' '
   PROGRAMM = ' '
    titel    = 'helppp!'.

**
**********test for FM NAMETAB_GET(SID 51)
DATA : lt_dtab TYPE STANDARD TABLE OF dntab,
      lwa_dtab TYPE dntab.

CALL FUNCTION 'NAMETAB_GET'
 EXPORTING
   LANGU                     = SY-LANGU
   ONLY                      = ' '
   TABNAME                   = 'MARA'
* IMPORTING
*   HEADER                    =
*   RC                        =
  TABLES
    NAMETAB                   = lt_dtab
 EXCEPTIONS
   INTERNAL_ERROR            = 1
   TABLE_HAS_NO_FIELDS       = 2
   TABLE_NOT_ACTIV           = 3
   NO_TEXTS_FOUND            = 4
   OTHERS                    = 5.



******test DELETING LEADING 0.
DATA: h_kunnr(10),
      p_kunnr(10),
        h_kunwe(10).

DATA: wa_kna1 TYPE kna1.


SELECT SINGLE * FROM kna1 INTO wa_kna1
WHERE kunnr = p_kunnr.

WRITE p_kunnr TO h_kunnr.

  SHIFT h_kunnr LEFT DELETING LEADING 0.

  SHIFT lv_str LEFT DELETING LEADING 0.


********Test TRANSLATE STATEMENT
****case1
DATA f(72).

TRANSLATE F FROM CODE PAGE '1110' TO CODE PAGE '0100'.

****case2
DATA f1(72).

TRANSLATE F1 FROM NUMBER FORMAT '1110' TO CODE PAGE '0100'.


***case3
DATA f2(72).
TRANSLATE F2 FROM NUMBER FORMAT '0000' TO NUMBER FORMAT '0100'.


***case4
DATA f3(72).
TRANSLATE F3 TO CODE PAGE '1110'.

***case5
DATA f4(72).
TRANSLATE F4 FROM CODE PAGE '1110'.


********CLEAR SPELL+403
tables: spell.

CLEAR SPELL+403.


********OPEN DATASET ERROR
PARAMETERS:
  p_file(100) TYPE c OBLIGATORY  LOWER CASE
             DEFAULT  'C:\Users\priyanka.s.tevare\Desktop\testing.xlsx'.
*
open dataset p_file for input.

OPEN DATASET p_file IN LEGACY TEXT MODE FOR APPENDING.     "check this case


open dataset p_file
             for APPENDING
             in text mode.


OPEN DATASET p_file for output
                    in text mode.


OPEN DATASET p_file for output in text mode.


open dataset p_file for output in binary mode.          "skiping binary mode


*********DESCRIBE STATEMENT
data : len type i.
data a(10) type c.
data type(1).


 DESCRIBE FIELD A LENGTH LEN.



*********FM HELP_VALUES_GET_NO_DD_NAME
DATA: lv_sel_ind TYPE sy-tabix,
      lv_sel_field TYPE help_info-fieldname,
      lt_tab_fld TYPE STANDARD TABLE OF help_value,
      lt_fu_table TYPE  STANDARD TABLE OF mara.

CALL FUNCTION 'HELP_VALUES_GET_NO_DD_NAME'
  EXPORTING
    CUCOL                        = 0
    CUROW                        = 0
    DISPLAY                      = ' '
    selectfield                  = lv_sel_field
    TITEL                        = 'ttileee'
*   NO_PERS_HELP_SELECT          = ' '
  IMPORTING
    IND                          = lv_sel_ind
*   SELECT_VALUE                 =
  TABLES
    fields                       = lt_tab_fld
    full_table                   = lt_fu_table
  EXCEPTIONS
    FULL_TABLE_EMPTY             = 1
    NO_TABLESTRUCTURE_GIVEN      = 2
    NO_TABLEFIELDS_IN_DICTIONARY = 3
    MORE_THEN_ONE_SELECTFIELD    = 4
    NO_SELECTFIELD               = 5
    OTHERS                       = 6.


********FM WS_QUERY
*****CASE1 :FE
DATA: g_subrc TYPE i,
      p_filen(255) TYPE c.

p_filen = 'C:\Users\priyanka.s.tevare\Desktop\testing.txt'.
CONSTANTS: lc_query(2) TYPE c VALUE 'FE'.

 CALL FUNCTION 'WS_QUERY'
 EXPORTING
 FILENAME = P_FILEN
 QUERY = lc_query
 IMPORTING
 RETURN = G_SUBRC
 EXCEPTIONS
 OTHERS = 1.



***CASE2 :FL
DATA: lenhh TYPE i,
      p_filen1(255) TYPE c.

p_filen1 = 'C:\Users\priyanka.s.tevare\Desktop\testing.txt'.

 CALL FUNCTION 'WS_QUERY'
 EXPORTING
 FILENAME = P_FILEN1
 QUERY = 'FL'
 IMPORTING
 RETURN = LENhh
 EXCEPTIONS
 OTHERS = 1.

*
*****CASE3 :XP
DATA: lv_ret TYPE string,
      p_filent(255) TYPE c.

p_filent = 'C:\Users\priyanka.s.tevare\Desktop\testing.txt'.


 CALL FUNCTION 'WS_QUERY'
 EXPORTING
 FILENAME = P_FILENt
 QUERY = 'XP'
 IMPORTING
 RETURN = LV_RET
 EXCEPTIONS
 OTHERS = 1.

**
*******CASE1 :EN
DATA: lv_ret13 TYPE string,
      p_filenf(255) TYPE c.

p_filenf = 'C:\Users\priyanka.s.tevare\Desktop\testing.txt'.

CALL FUNCTION 'WS_QUERY'
  EXPORTING
    filename = p_filenf
    query    = 'EN'
  IMPORTING
    return   = lv_ret13
  EXCEPTIONS
    OTHERS   = 1.

**CASE1 :DE
DATA: lv_ret2e TYPE string,
      p_filen1e(255) TYPE c.

p_filen1 = 'C:\Users\priyanka.s.tevare\Desktop\testing.txt'.

CALL FUNCTION 'WS_QUERY'
  EXPORTING
    filename = p_filen1e
    query    = 'DE'
  IMPORTING
    return   = lv_ret2e
  EXCEPTIONS
    OTHERS   = 1.

***CASE1 :CD  "current directory
DATA: lv_retb TYPE string.

CALL FUNCTION 'WS_QUERY'
  EXPORTING
    filename = ' '
    query    = 'CD'
  IMPORTING
    return   = lv_retb
  EXCEPTIONS
    OTHERS   = 1.


****CASE2 :OS
DATA returnf(10) TYPE c.

CALL FUNCTION 'WS_QUERY'
  EXPORTING
    environment = ' '
    filename    = ' '
    query       = 'OS'
    winid       = ' '
  IMPORTING
    return      = returnf.

IF sy-subrc EQ 0.
  WRITE returnf.
ENDIF.

***CASE2 :WS
data returnd(10) type c.

 CALL FUNCTION 'WS_QUERY'
 EXPORTING
 QUERY = 'WS'
 IMPORTING
 RETURN = RETURNd.

*******Test ws_filename_get (SID 22)
DATA: lv_filenamevv LIKE  rlgrap-filename.
DATA: lv_def_filename TYPE string,
      lv_path TYPE string,
      lv_rc TYPE i.

lv_def_filename = 'myfile'.
lv_path = 'C:\Users\priyanka.s.tevare\Desktop'.


CALL FUNCTION 'WS_FILENAME_GET'
 EXPORTING
   DEF_FILENAME           = lv_def_filename
   DEF_PATH               = lv_path
   MASK                   = ' '
   MODE                   = 'O'   "S = Save, O = Open
   TITLE                  = 'mytitle'
 IMPORTING
   FILENAME               = lv_filenamevv
   RC                     = lv_rc
 EXCEPTIONS
   INV_WINSYS             = 1
   NO_BATCH               = 2
   SELECTION_CANCEL       = 3
   SELECTION_ERROR        = 4
   OTHERS                 = 5.

case2 type O
DATA: lv_filename9 LIKE  rlgrap-filename.
DATA: lv_def_filename9 TYPE string,
      lv_path9 TYPE string,
      lv_rc9 TYPE i.

lv_def_filename9 = 'myfile'.
lv_path9 = 'C:\Users\priyanka.s.tevare\Desktop'.

CALL FUNCTION 'WS_FILENAME_GET'
 EXPORTING
   DEF_FILENAME           = lv_def_filename9
   DEF_PATH               = lv_path9
   MASK                   = ' ,txt,'
   MODE                   = 'O'   "S = Save, O = Open
   TITLE                  = 'mytitle'
 IMPORTING
   FILENAME               = lv_filename9
   RC                     = lv_rc9
 EXCEPTIONS
   INV_WINSYS             = 1
   NO_BATCH               = 2
   SELECTION_CANCEL       = 3
   SELECTION_ERROR        = 4
   OTHERS                 = 5.*&---------------------------------------------------------------------*
*& Report  ZTEST_PRG
*&
*&---------------------------------------------------------------------*
REPORT  ztest_prg.
*****test for FM UPLOAD (SID 15)
****filetyp = DAT
DATA: lv_filename LIKE  rlgrap-filename.
DATA: zeile TYPE TABLE OF standard.
DATA : lv_file_size TYPE i.


CALL FUNCTION 'UPLOAD'
  EXPORTING
    filetype                = 'ASC'
  IMPORTING
    filesize                = lv_file_size
  TABLES
    data_tab                = zeile
  EXCEPTIONS
    conversion_error        = 1
    invalid_table_width     = 2
    invalid_type            = 3
    no_batch                = 4
    unknown_error           = 5
    gui_refuse_filetransfer = 6
    OTHERS                  = 7.



*****test for FM WS_UPLOAD (SID 21)
**filetyp = DAT
*DATA: lv_filename LIKE  rlgrap-filename VALUE 'C:\Users\priyanka.s.tevare\Desktop\testing.xlsx'.
DATA: zeileq TYPE TABLE OF standard.
DATA : lv_file_sizeq TYPE i.
*

CALL FUNCTION 'WS_UPLOAD'       "no filename
 EXPORTING
   FILETYPE                      = 'DAT'
 IMPORTING
   FILELENGTH                    = LV_FILE_SIZEq
  TABLES
    data_tab                      = ZEILEq
 EXCEPTIONS
   CONVERSION_ERROR              = 1
   FILE_OPEN_ERROR               = 2
   FILE_READ_ERROR               = 3
   INVALID_TYPE                  = 4
   NO_BATCH                      = 5
   UNKNOWN_ERROR                 = 6
   INVALID_TABLE_WIDTH           = 7
   GUI_REFUSE_FILETRANSFER       = 8
   CUSTOMER_ERROR                = 9
   NO_AUTHORITY                  = 10
   OTHERS                        = 11.


IF sy-subrc eq 0 .
  WRITE:/'Successful!'.
  WRITE:/ LV_FILE_SIZE.
ENDIF.


******test for FM DOWNLOAD (SID 24)
****filetyp = ASC
DATA: lv_filename22 LIKE  rlgrap-filename.
DATA: zeile22 TYPE TABLE OF standard.
DATA : lv_file_size22 TYPE i.


CALL FUNCTION 'DOWNLOAD'
 IMPORTING
   FILESIZE                      = lv_file_size22
  TABLES
    data_tab                      = ZEILE22
*   FIELDNAMES                    =
 EXCEPTIONS
   INVALID_FILESIZE              = 1
   INVALID_TABLE_WIDTH           = 2
   INVALID_TYPE                  = 3
   NO_BATCH                      = 4
   UNKNOWN_ERROR                 = 5
   GUI_REFUSE_FILETRANSFER       = 6
   OTHERS                        = 7.

IF sy-subrc eq 0 .
  WRITE:/'Successful!'.
  WRITE:/ lv_file_size22.
ENDIF.

***case2
****filetyp = DAT
DATA: lv_filename21 LIKE  rlgrap-filename.
DATA: zeile21 TYPE TABLE OF standard.
DATA : lv_file_size21 TYPE i.

CALL FUNCTION 'DOWNLOAD'
 EXPORTING
   FILENAME                      = lv_filename21
   FILETYPE                      = 'DAT'
 IMPORTING
   FILESIZE                      = lv_file_size21
  TABLES
    data_tab                      = ZEILE21
*   FIELDNAMES                    =
 EXCEPTIONS
   INVALID_FILESIZE              = 1
   INVALID_TABLE_WIDTH           = 2
   INVALID_TYPE                  = 3
   NO_BATCH                      = 4
   UNKNOWN_ERROR                 = 5
   GUI_REFUSE_FILETRANSFER       = 6
   OTHERS                        = 7.



*****test for FM WS_DOWNLOAD (SID 25)
**filetyp = ASC
DATA: lv_filename66 LIKE  rlgrap-filename.
DATA: zeile66 TYPE TABLE OF standard.
DATA : lv_file_size66 TYPE i.

CALL FUNCTION 'WS_DOWNLOAD'
 EXPORTING
   FILENAME                      = lv_filename66
   FILETYPE                      = 'DAT'
 IMPORTING
   FILELENGTH                    = lv_file_size66
  TABLES
    data_tab                      = zeile66
*   FIELDNAMES                    =
 EXCEPTIONS
   FILE_OPEN_ERROR               = 1
   FILE_WRITE_ERROR              = 2
   INVALID_FILESIZE              = 3
   INVALID_TYPE                  = 4
   NO_BATCH                      = 5
   UNKNOWN_ERROR                 = 6
   INVALID_TABLE_WIDTH           = 7
   GUI_REFUSE_FILETRANSFER       = 8
   CUSTOMER_ERROR                = 9
   NO_AUTHORITY                  = 10
   OTHERS                        = 11.



***filetyp = DAT (without exceptions)
DATA: lv_filename65 LIKE  rlgrap-filename.
DATA: zeile65 TYPE TABLE OF standard.
data: lt_fld  TYPE TABLE OF standard.
DATA : lv_file_size65 TYPE i.
*

CALL FUNCTION 'WS_DOWNLOAD'
 EXPORTING
   FILENAME                      = lv_filename65
   FILETYPE                      = 'DAT'
 IMPORTING
   FILELENGTH                    = lv_file_size65
  TABLES
    data_tab                     = zeile65
   FIELDNAMES                    = lt_fld.



*******Test ws_filename_get (SID 22)
****case1 MODE: 'S'
DATA: lv_filename_c LIKE  rlgrap-filename.
DATA: lv_def_filename_c TYPE string,
      lv_path_c TYPE string,
      lv_rc_c TYPE i,
      lv_mask1 TYPE string.

lv_mask1 = ',*.xls.'.

lv_def_filename_c = 'myfile1'.
lv_path_c = 'C:\Users\priyanka.s.tevare\Desktop'.

CALL FUNCTION 'WS_FILENAME_GET'
 EXPORTING
   DEF_FILENAME           = lv_def_filename_c
   DEF_PATH               = lv_path_c
   MASK                   = lv_mask1
   MODE                   = 'S'   "S = Save, O = Open
   TITLE                  = 'mytitle'
 IMPORTING
   FILENAME               = lv_filename_c
   RC                     = lv_rc_c
 EXCEPTIONS
   INV_WINSYS             = 1
   NO_BATCH               = 2
   SELECTION_CANCEL       = 3
   SELECTION_ERROR        = 4
   OTHERS                 = 5.


*****case2 MODE: 'O'
DATA: lv_filename_s LIKE  rlgrap-filename.
DATA: lv_def_filename_s TYPE string,
      lv_path_s TYPE string,
      lv_rc_s TYPE i,
      lv_mask2 TYPE string.

lv_mask2 = ',*.xls.'.

lv_def_filename_s = 'myfile3'.
lv_path_s = 'C:\Users\priyanka.s.tevare\Desktop'.


CALL FUNCTION 'WS_FILENAME_GET'
 EXPORTING
   DEF_FILENAME           = lv_def_filename_s
   DEF_PATH               = lv_path_s
   MASK                   = lv_mask2
   MODE                   = 'O'   "S = Save, O = Open
   TITLE                  = 'mytitle'
 IMPORTING
   FILENAME               = lv_filename_s
   RC                     = lv_rc_s
 EXCEPTIONS
   INV_WINSYS             = 1
   NO_BATCH               = 2
   SELECTION_CANCEL       = 3
   SELECTION_ERROR        = 4
   OTHERS                 = 5.


*********Test popup_to_confirm_step (SID 28)
*****CONSTANTS and variables declared
DATA :  xflag     TYPE c,
        lv_text1 TYPE string,
        lv_text2 TYPE string,
        lv_titl   TYPE string.

CONSTANTS: lc_x TYPE c VALUE 'X'.

lv_text1 = 'DO YOU WANTO  DISPLY'.
lv_text2 = 'SCREEN ?'.
lv_titl = 'mytltle'.


CALL FUNCTION 'POPUP_TO_CONFIRM_STEP'
  EXPORTING
    defaultoption  = 'Y'
    textline1      = lv_text1
    textline2      = lv_text2
    titel          = lv_titl
    start_column   = 25
    start_row      = 6
    cancel_display = lc_x
  IMPORTING
    answer         = xflag.


*"case2 (only one textline)
CALL FUNCTION 'POPUP_TO_CONFIRM_STEP'
  EXPORTING
    defaultoption  = 'Y'
    textline1      = lv_text1
    titel          = lv_titl
    start_column   = 25
    start_row      = 6
    cancel_display = lc_x
  IMPORTING
    answer         = xflag.


*********Test popup_to_decide (SID 30)
*****CONSTANTS and variables declared
DATA :  xflag1     TYPE c,
        lv_text11 TYPE string,
        lv_text21 TYPE string,
        lv_text31 TYPE string,
        lv_op1 TYPE string,
        lv_op2 TYPE string,
        lv_titl1   TYPE string.

CONSTANTS: lc_x1 TYPE c VALUE 'X',
           lc_one    TYPE c VALUE '1'.

lv_text11 = 'DWOLLEN SIE DIE VERARBEITUNG FÜR'(701).
lv_text21 = 'ALLE NOCH NICHT BEARBEITETEN'(702).
lv_text31 = 'SELEKTIERTEN OBJEKTE ABBRECHEN?'(703).
lv_titl = 'mytltle'.
lv_op1 = 'YES'.
lv_op2 = 'NO'.

CALL FUNCTION 'POPUP_TO_DECIDE'
  EXPORTING
    defaultoption  = lc_one
    textline1      = lv_text11
    textline2      = lv_text21
    textline3      = lv_text31
    text_option1   = lv_op1
    text_option2   = lv_op2
    titel          = lv_titl1
    start_column   = 25
    start_row      = 6
    cancel_display = 'X'
  IMPORTING
    answer         = xflag1.


*********Test popup_to_confirm_with_value (SID 32)
*****CONSTANTS and variables declared
DATA :  xflag3     TYPE c,
        lv_text13 TYPE string,
        lv_text23 TYPE string,
        lv_text33 TYPE string,
        lv_titl3   TYPE string.

lv_text13 = 't1'.
lv_text23 = text-001.
lv_text33 = 't2'.
lv_titl3 = 'mytltle'.


CALL FUNCTION 'POPUP_TO_CONFIRM_WITH_VALUE'
  EXPORTING
    defaultoption  = 'Y'
    objectvalue    = lv_text23
    text_after     = lv_text33
    text_before    = lv_text13
    titel          = lv_titl3
    start_column   = 25
    start_row      = 6
    cancel_display = 'X'
  IMPORTING
    answer         = xflag3
  EXCEPTIONS
    text_too_long  = 1
    OTHERS         = 2.

*********Test ws_execute (SID 34)
****CONSTANTS and variables declared
DATA: lv_doc1 TYPE string VALUE 'X',
      lv_prog TYPE string VALUE 'http://www.google.co.in'.
*

CALL FUNCTION 'WS_EXECUTE'
 EXPORTING
   DOCUMENT                 = lv_doc1
*   CD                       =
*   COMMANDLINE              = ' '
*   INFORM                   = ' '
   PROGRAM                  = lv_prog
 EXCEPTIONS
   FRONTEND_ERROR           = 1
   NO_BATCH                 = 2
   PROG_NOT_FOUND           = 3
   ILLEGAL_OPTION           = 4
   GUI_REFUSE_EXECUTE       = 5
   OTHERS                   = 6.



*********Test ws_execute (SID 35)
*****CONSTANTS and variables declared
DATA: lv_doc12 TYPE string VALUE 'X',
      lv_prog12 TYPE string VALUE 'C:\Users\priyanka.s.tevare\Desktop\ws_execute.xlsx',
      lv_comm12 TYPE string VALUE 'ws_execute.xlsx'.

CALL FUNCTION 'WS_EXECUTE'
 EXPORTING
   DOCUMENT                 = lv_doc12
*   CD                       =
   COMMANDLINE              = lv_comm12
*   INFORM                   = ' '
   PROGRAM                  = lv_prog12.


**********Test ws_file_delete (SID 36)
DATA : lv_file TYPE RLGRAP-FILENAME VALUE 'C:\Users\priyanka.s.tevare\Desktop\testing.txt' ,
       return TYPE i.

CALL FUNCTION 'WS_FILE_DELETE'
  EXPORTING
    file          = lv_file
 IMPORTING
   RETURN        = return.
DATA LV_fnam_1 type string.
DATA LV_rc_1 type I.
LV_fnam_1 =  LV_FILE.
LV_rc_1 = RETURN.



**********Test ws_WS_EXCEL (SID 40)
**Create a type
TYPES:  BEGIN OF ty_table_1,
        matnr TYPE mara-matnr,
        ersda TYPE mara-ersda,
        ernam TYPE mara-ernam,
      END OF ty_table_1.


*  create a table and workspace
DATA:
      filenamev  TYPE string,
      i_table_1 TYPE TABLE OF ty_table_1.

SELECT matnr ersda ernam
  FROM mara
  INTO TABLE i_table_1
  UP TO 10 ROWS.

filenamev ='C:\Users\priyanka.s.tevare\Desktop\tesing.xls'.

CALL FUNCTION 'WS_EXCEL'
EXPORTING
FILENAME = filenamev
*SYNCHRON = ' '
TABLES
DATA = i_table_1
EXCEPTIONS
UNKNOWN_ERROR = 1
OTHERS = 2.




******test for FM STRING_CENTER (SID 42)
*"with exceptions
DATA: lv_in TYPE char100 VALUE 'Priyanka',
      lv_out TYPE char100.

CALL FUNCTION 'STRING_CENTER'
  EXPORTING
    string         = lv_in
 IMPORTING
   CSTRING         = lv_out
 EXCEPTIONS
   TOO_SMALL       = 1
   OTHERS          = 2.



******test for FM STRING_MOVE_RIGHT (SID 43)
DATA: lv_inr TYPE string VALUE 'RIGHT',
      lv_outr TYPE char100.

CALL FUNCTION 'STRING_MOVE_RIGHT'
  EXPORTING
    string          = lv_inr
 IMPORTING
   RSTRING         = lv_outr
 EXCEPTIONS
   TOO_SMALL       = 1
   OTHERS          = 2.


IF sy-subrc eq 0.
WRITE:/ lv_inr.
WRITE:/ lv_outr.
ENDIF.



*****test for FM STRING_SPLIT (SID 47)
DATA: lv_h2 TYPE char100,
      lv_t2 TYPE char100.

CALL FUNCTION 'STRING_SPLIT'
EXPORTING
delimiter       = '.'
string          = 'testpartdhj.part2dgg'
IMPORTING
HEAD            = lv_h2
TAIL            = lv_t2
EXCEPTIONS
NOT_FOUND       = 1
NOT_VALID       = 2
TOO_LONG        = 3
TOO_SMALL       = 4
OTHERS          = 5.

IF sy-subrc eq 0.
  WRITE:/ 'head=', lv_h2.
  WRITE:/ 'tail=', lv_t2.
ENDIF.


******case1:head not provided
DATA: lv_h TYPE char100,
      lv_t TYPE char100.

CALL FUNCTION 'STRING_SPLIT'
EXPORTING
delimiter       = '.'
string          = 'testpartdhj.part2dgg'
IMPORTING
*HEAD            = lv_h
TAIL            = lv_t
EXCEPTIONS
NOT_FOUND       = 1
NOT_VALID       = 2
TOO_LONG        = 3
TOO_SMALL       = 4
OTHERS          = 5.
data lv_head_2 type char250.
data lv_tail_2 type char250.
lv_head_2 = lv_head_2.
lv_tail_2 = LV_T.
SPLIT 'TESTPARTDHJ.PART2DGG' AT '.' INTO lv_head_2 lv_tail_2.
lv_head_2 = lv_head_2.
LV_T = lv_tail_2.


IF sy-subrc eq 0.
  WRITE:/ 'head=', lv_h.
  WRITE:/ 'tail=', lv_t.
ENDIF.


********case2: tail not p[rovided
DATA: lv_h1 TYPE char100,
      lv_t1 TYPE char100.


CALL FUNCTION 'STRING_SPLIT'
EXPORTING
delimiter       = '.'
string          = 'testpartdhj.part2dgg'
IMPORTING
HEAD            = lv_h1
*TAIL            = lv_t1
EXCEPTIONS
NOT_FOUND       = 1
NOT_VALID       = 2
TOO_LONG        = 3
TOO_SMALL       = 4
OTHERS          = 5.
data lv_head_3 type char250.
data lv_tail_3 type char250.
lv_head_3 = LV_H1.
lv_tail_3 = lv_tail_3.
SPLIT 'TESTPARTDHJ.PART2DGG' AT '.' INTO lv_head_3 lv_tail_3.
LV_H1 = lv_head_3.
lv_tail_3 = lv_tail_3.


IF sy-subrc eq 0.
  WRITE:/ 'head=', lv_h1.
  WRITE:/ 'tail=', lv_t1.
ENDIF.


********test for FM STRING_LENGHT (SID 51)
DATA: lv_str TYPE string VALUE 'I AM PRIYANKA',
      lv_len  TYPE i.

CALL FUNCTION 'STRING_LENGTH'
  EXPORTING
    string        = lv_str
 IMPORTING
   LENGTH        = lv_len.


IF sy-subrc eq 0.
  WRITE:/ lv_len.
ENDIF.

********test for FM GET_FIELDTAB(SID 48)
DATA: lv_tabnam TYPE DFIES-TABNAME VALUE 'MARA',
      wa_header TYPE X030L,
      lt_tab  TYPE STANDARD TABLE OF DFIES,
      lwa_tab TYPE DFIES.

CALL FUNCTION 'GET_FIELDTAB'
 EXPORTING
   LANGU                     = SY-LANGU
*   ONLY                      = ' '
   TABNAME                   = lv_tabnam
*   WITHTEXT                  = 'X'
 IMPORTING
   HEADER                    = wa_header
*   RC                        =
  TABLES
    fieldtab                  = lt_tab
 EXCEPTIONS
   INTERNAL_ERROR            = 1
   NO_TEXTS_FOUND            = 2
   TABLE_HAS_NO_FIELDS       = 3
   TABLE_NOT_ACTIV           = 4
   OTHERS                    = 5.


********test for FM CONVERT_DATE_INPUT(SID 51)
DATA: lv_out3 TYPE sy-datum.

CALL FUNCTION 'CONVERT_DATE_INPUT'
  EXPORTING
    input                          = '20112016'
   PLAUSIBILITY_CHECK              = 'X'
 IMPORTING
   OUTPUT                          = lv_out3
 EXCEPTIONS
   PLAUSIBILITY_CHECK_FAILED       = 1
   WRONG_FORMAT_IN_INPUT           = 2
   OTHERS                          = 3.


IF sy-subrc eq 0.
  WRITE:/ lv_out3.
ENDIF.


*********test for FM SAP_TO_ISO_MEASURE_UNIT_CODE(SID 51)
DATA: lv_iso TYPE T006-ISOCODE.

CALL FUNCTION 'SAP_TO_ISO_MEASURE_UNIT_CODE'
  EXPORTING
    SAP_CODE         = 'KG'
 IMPORTING
   ISO_CODE          = lv_iso
 EXCEPTIONS
   NOT_FOUND         = 1
   NO_ISO_CODE       = 2
   OTHERS            = 3.

IF SY-SUBRC eq 0.
  WRITE:/ lv_iso.
ENDIF.


********test for FM SAP_TO_ISO_CURRENCY_CODE(SID 51)
DATA: lv_isoc TYPE TCURC-ISOCD.

CALL FUNCTION 'SAP_TO_ISO_CURRENCY_CODE'
  EXPORTING
    SAP_CODE          = 'USD'
 IMPORTING
   ISO_CODE          = lv_isoc
 EXCEPTIONS
   NOT_FOUND         = 1
   NO_ISO_CODE       = 2
   OTHERS            = 3.


IF SY-SUBRC eq 0.
  WRITE:/ lv_isoc.
ENDIF.

*******test for FM LOG_SYSTEM_GET_RFC_DESTINATION(SID 51)
tables bkpf.
data:begin of tab_rfc occurs 0,             "destination for 3rd party
 bukrs           like regup-bukrs,          "remittance
 belnr           like regup-belnr,
 gjahr           like regup-gjahr,
 dest            like tbdestination-rfcdest,
 awsys           like bkpf-awsys,
 lifnr           like regup-lifnr,
 xblnr           like regup-xblnr,
 zbukr           like reguh-zbukr,
 vblnr           like reguh-vblnr,
 zfbdt           like regup-zfbdt,
end of tab_rfc.
*
DATA: log_sys  TYPE TBLSYSDEST-LOGSYS,
      rfc_dest TYPE TBLSYSDEST-RFCDEST.

CONCATENATE sy-sysid sy-mandt INTO log_sys.
log_sys = 'ACRCLNT200'.           "data from table T000

 CALL FUNCTION 'LOG_SYSTEM_GET_RFC_DESTINATION'
 EXPORTING
 LOGICAL_SYSTEM = log_sys
 IMPORTING
 RFC_DESTINATION = rfc_dest
 EXCEPTIONS
 NO_RFC_DESTINATION_MAINTAINED       = 1
 OTHERS                              = 2.


IF sy-subrc eq 0.
  WRITE:/ TAB_RFC-DEST.
ENDIF.
**
**
********test for FM HELPSCREEN_NA_CREATE(SID 51)
CALL FUNCTION 'HELPSCREEN_NA_CREATE'
  EXPORTING
    dynpro   = '1000'
    langu    = sy-langu
   MELDUNG  = ' '
    meld_id  = 'SH'
    meld_nr  = '720'
    msgv1    = ' '
    msgv2    = ' '
    msgv3    = ' '
   MSGV4    = ' '
   PFKEY    = ' '
   PROGRAMM = ' '
    titel    = 'helppp!'.

**
**********test for FM NAMETAB_GET(SID 51)
DATA : lt_dtab TYPE STANDARD TABLE OF dntab,
      lwa_dtab TYPE dntab.

CALL FUNCTION 'NAMETAB_GET'
 EXPORTING
   LANGU                     = SY-LANGU
   ONLY                      = ' '
   TABNAME                   = 'MARA'
* IMPORTING
*   HEADER                    =
*   RC                        =
  TABLES
    NAMETAB                   = lt_dtab
 EXCEPTIONS
   INTERNAL_ERROR            = 1
   TABLE_HAS_NO_FIELDS       = 2
   TABLE_NOT_ACTIV           = 3
   NO_TEXTS_FOUND            = 4
   OTHERS                    = 5.



******test DELETING LEADING 0.
DATA: h_kunnr(10),
      p_kunnr(10),
        h_kunwe(10).

DATA: wa_kna1 TYPE kna1.


SELECT SINGLE * FROM kna1 INTO wa_kna1
WHERE kunnr = p_kunnr.

WRITE p_kunnr TO h_kunnr.

  SHIFT h_kunnr LEFT DELETING LEADING 0.

  SHIFT lv_str LEFT DELETING LEADING 0.


********Test TRANSLATE STATEMENT
****case1
DATA f(72).

TRANSLATE F FROM CODE PAGE '1110' TO CODE PAGE '0100'.

****case2
DATA f1(72).

TRANSLATE F1 FROM NUMBER FORMAT '1110' TO CODE PAGE '0100'.


***case3
DATA f2(72).
TRANSLATE F2 FROM NUMBER FORMAT '0000' TO NUMBER FORMAT '0100'.


***case4
DATA f3(72).
TRANSLATE F3 TO CODE PAGE '1110'.

***case5
DATA f4(72).
TRANSLATE F4 FROM CODE PAGE '1110'.


********CLEAR SPELL+403
tables: spell.

CLEAR SPELL+403.


********OPEN DATASET ERROR
PARAMETERS:
  p_file(100) TYPE c OBLIGATORY  LOWER CASE
             DEFAULT  'C:\Users\priyanka.s.tevare\Desktop\testing.xlsx'.
*
open dataset p_file for input.

OPEN DATASET p_file IN LEGACY TEXT MODE FOR APPENDING.     "check this case


open dataset p_file
             for APPENDING
             in text mode.


OPEN DATASET p_file for output
                    in text mode.


OPEN DATASET p_file for output in text mode.


open dataset p_file for output in binary mode.          "skiping binary mode


*********DESCRIBE STATEMENT
data : len type i.
data a(10) type c.
data type(1).


 DESCRIBE FIELD A LENGTH LEN.



*********FM HELP_VALUES_GET_NO_DD_NAME
DATA: lv_sel_ind TYPE sy-tabix,
      lv_sel_field TYPE help_info-fieldname,
      lt_tab_fld TYPE STANDARD TABLE OF help_value,
      lt_fu_table TYPE  STANDARD TABLE OF mara.

CALL FUNCTION 'HELP_VALUES_GET_NO_DD_NAME'
  EXPORTING
    CUCOL                        = 0
    CUROW                        = 0
    DISPLAY                      = ' '
    selectfield                  = lv_sel_field
    TITEL                        = 'ttileee'
*   NO_PERS_HELP_SELECT          = ' '
  IMPORTING
    IND                          = lv_sel_ind
*   SELECT_VALUE                 =
  TABLES
    fields                       = lt_tab_fld
    full_table                   = lt_fu_table
  EXCEPTIONS
    FULL_TABLE_EMPTY             = 1
    NO_TABLESTRUCTURE_GIVEN      = 2
    NO_TABLEFIELDS_IN_DICTIONARY = 3
    MORE_THEN_ONE_SELECTFIELD    = 4
    NO_SELECTFIELD               = 5
    OTHERS                       = 6.


********FM WS_QUERY
*****CASE1 :FE
DATA: g_subrc TYPE i,
      p_filen(255) TYPE c.

p_filen = 'C:\Users\priyanka.s.tevare\Desktop\testing.txt'.
CONSTANTS: lc_query(2) TYPE c VALUE 'FE'.

 CALL FUNCTION 'WS_QUERY'
 EXPORTING
 FILENAME = P_FILEN
 QUERY = lc_query
 IMPORTING
 RETURN = G_SUBRC
 EXCEPTIONS
 OTHERS = 1.



***CASE2 :FL
DATA: lenhh TYPE i,
      p_filen1(255) TYPE c.

p_filen1 = 'C:\Users\priyanka.s.tevare\Desktop\testing.txt'.

 CALL FUNCTION 'WS_QUERY'
 EXPORTING
 FILENAME = P_FILEN1
 QUERY = 'FL'
 IMPORTING
 RETURN = LENhh
 EXCEPTIONS
 OTHERS = 1.

*
*****CASE3 :XP
DATA: lv_ret TYPE string,
      p_filent(255) TYPE c.

p_filent = 'C:\Users\priyanka.s.tevare\Desktop\testing.txt'.


 CALL FUNCTION 'WS_QUERY'
 EXPORTING
 FILENAME = P_FILENt
 QUERY = 'XP'
 IMPORTING
 RETURN = LV_RET
 EXCEPTIONS
 OTHERS = 1.

**
*******CASE1 :EN
DATA: lv_ret13 TYPE string,
      p_filenf(255) TYPE c.

p_filenf = 'C:\Users\priyanka.s.tevare\Desktop\testing.txt'.

CALL FUNCTION 'WS_QUERY'
  EXPORTING
    filename = p_filenf
    query    = 'EN'
  IMPORTING
    return   = lv_ret13
  EXCEPTIONS
    OTHERS   = 1.

**CASE1 :DE
DATA: lv_ret2e TYPE string,
      p_filen1e(255) TYPE c.

p_filen1 = 'C:\Users\priyanka.s.tevare\Desktop\testing.txt'.

CALL FUNCTION 'WS_QUERY'
  EXPORTING
    filename = p_filen1e
    query    = 'DE'
  IMPORTING
    return   = lv_ret2e
  EXCEPTIONS
    OTHERS   = 1.

***CASE1 :CD  "current directory
DATA: lv_retb TYPE string.

CALL FUNCTION 'WS_QUERY'
  EXPORTING
    filename = ' '
    query    = 'CD'
  IMPORTING
    return   = lv_retb
  EXCEPTIONS
    OTHERS   = 1.


****CASE2 :OS
DATA returnf(10) TYPE c.

CALL FUNCTION 'WS_QUERY'
  EXPORTING
    environment = ' '
    filename    = ' '
    query       = 'OS'
    winid       = ' '
  IMPORTING
    return      = returnf.

IF sy-subrc EQ 0.
  WRITE returnf.
ENDIF.

***CASE2 :WS
data returnd(10) type c.

 CALL FUNCTION 'WS_QUERY'
 EXPORTING
 QUERY = 'WS'
 IMPORTING
 RETURN = RETURNd.

*******Test ws_filename_get (SID 22)
DATA: lv_filenamevv LIKE  rlgrap-filename.
DATA: lv_def_filename TYPE string,
      lv_path TYPE string,
      lv_rc TYPE i.

lv_def_filename = 'myfile'.
lv_path = 'C:\Users\priyanka.s.tevare\Desktop'.


CALL FUNCTION 'WS_FILENAME_GET'
 EXPORTING
   DEF_FILENAME           = lv_def_filename
   DEF_PATH               = lv_path
   MASK                   = ' '
   MODE                   = 'O'   "S = Save, O = Open
   TITLE                  = 'mytitle'
 IMPORTING
   FILENAME               = lv_filenamevv
   RC                     = lv_rc
 EXCEPTIONS
   INV_WINSYS             = 1
   NO_BATCH               = 2
   SELECTION_CANCEL       = 3
   SELECTION_ERROR        = 4
   OTHERS                 = 5.

case2 type O
DATA: lv_filename9 LIKE  rlgrap-filename.
DATA: lv_def_filename9 TYPE string,
      lv_path9 TYPE string,
      lv_rc9 TYPE i.

lv_def_filename9 = 'myfile'.
lv_path9 = 'C:\Users\priyanka.s.tevare\Desktop'.

CALL FUNCTION 'WS_FILENAME_GET'
 EXPORTING
   DEF_FILENAME           = lv_def_filename9
   DEF_PATH               = lv_path9
   MASK                   = ' ,txt,'
   MODE                   = 'O'   "S = Save, O = Open
   TITLE                  = 'mytitle'
 IMPORTING
   FILENAME               = lv_filename9
   RC                     = lv_rc9
 EXCEPTIONS
   INV_WINSYS             = 1
   NO_BATCH               = 2
   SELECTION_CANCEL       = 3
   SELECTION_ERROR        = 4
   OTHERS                 = 5.
