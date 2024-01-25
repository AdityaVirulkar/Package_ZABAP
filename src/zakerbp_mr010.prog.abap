*++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*
* CHANGE ID : HANA-001
* USER: ACC11346068
* DATE: 05.06.2017
* TR : S7HK900166
* DESCRIPTION: HANA CORRECTION
* TEAM : HANA-MIGRATION
*++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*
REPORT (sy-repid)
       no standard page heading
       line-size  132
       line-count 065
       message-id ze.

************************************************************************
* Author     : Dustin Locatelli                                        *
*              PricewaterhouseCoopers - Dallas Solution Delivery Center*
* Date       : 05/08/2001                                              *
* Title      : ZMMMR010 - Expedite Purchase Orders                     *
* Description: Program to produce a Purchase Order Expediting Report   *
*                                                                      *
*----------------------------------------------------------------------*
*               M O D I F I C A T I O N  L O G                         *
*----------------------------------------------------------------------*
* Date     | Mod #      | Person      | Description                    *
*----------------------------------------------------------------------*
* 05/08/01   MD1K900716   D Locatelli   Initial construction           *
* 02/04/02   MD1K920966   Chris LaRocco add created by to sel screen
* 02/04/02   MD1K921015   Chris LaRocco fix exp notes checkbox funct
* 07/19/05   MD1K956365   D.McIntyre    Implement Plant security
* 05/06/09   MD1K977580   Erassampally  changed the logic for ovedue.
*                         Srinivasulu
************************************************************************

************************************************************************
* Tables                                                               *
************************************************************************

TABLES: ekko,                          " Purchasing Document Header
        ekpo,                          " Purchasing Document Item
        eket,                          " Delivery Schedules
        mara,                          " Material Master: General Data
        ekkn,                          " Acct Assign in Purchasing Doc
        ekes,                          " Ord Accept/Fulfillment Confirms
        eban,                          " Purchase Requisition
        lfa1,                          " Vendor master (general section)
        afih,                          " Maintenance Order Header
        resb,                          " Reservation/dependent requireme
        cdhdr.                         " Change document header

************************************************************************
* Variables                                                            *
************************************************************************
DATA: g_checks     TYPE i,                  " counter for opts selected
      g_sched      TYPE i,                  " flag for option 1 output
      g_lines      TYPE i,                  " size of i_data
      g_date       LIKE ekes-eindt,         " delivery date from EKES
      g_qty        LIKE eket-wemng,         " total quantity delivered
      g_shqty      LIKE eket-menge,         " total scheduled quantity
      g_outst      LIKE eket-menge,         " Outstanding qty
      g_tmpqty(12) TYPE c,                  " formatted quantity
      g_sysubrc    LIKE sy-subrc,           " Temp store sy-subrc
      g_tabix      LIKE sy-tabix,           " Table index
      g_flag(1)    TYPE c,                  " On/Off flag
      g_date_diff  TYPE p,                  " Date Difference
      g_objectid   LIKE cdhdr-objectid,     " Object ID
      g_udate      LIKE cdhdr-udate,        " Last Expedited Date
      g_key(15)    TYPE c.                  " Key

DATA: g_fieldname(30),                      " Field Name
      g_fieldvalue    LIKE g_udate,           " Field Value
      g_name          LIKE thead-tdname,      " Last Expedited Date
      g_txlines       TYPE i,                 " Lines
      g_costobj(12)   TYPE c,                 " Cost Object
      g_lines2        TYPE i.                 " Size of aufnr and kostl
" from selection screen

************************************************************************
* Internal Tables                                                      *
************************************************************************
DATA: BEGIN OF t_data OCCURS 0,
        lifnr LIKE ekko-lifnr,              " Vendor number
        name1 LIKE lfa1-name1,              " Vendor name
        labnr LIKE ekpo-labnr,              " Vendor ack ref
        ebeln LIKE ekko-ebeln,              " PO number
        ebelp LIKE ekpo-ebelp,              " PO item
        bednr LIKE ekpo-bednr,              " PO item Tracking no
        matnr LIKE ekpo-matnr,              " Material number
        txz01 LIKE ekpo-txz01,              " Material Description
        menge LIKE ekpo-menge,              " Quantity ordered
        outst LIKE ekpo-menge,              " Quantity outstanding
        meins LIKE ekpo-meins,              " UOM
        aedat LIKE ekko-aedat,              " Date order issued
        slfdt LIKE eket-slfdt,              " Original due date
        eindt LIKE eket-eindt,              " Latest due date
        banfn LIKE eban-banfn,              " Requisition no.
        bnfpo LIKE eban-bnfpo,              " Requisition item no.
        lfdat LIKE eban-lfdat,              " ROS date.
        ekgrp LIKE ekko-ekgrp,              " PO group
        bsart LIKE ekko-bsart,              " PO type
        kostl LIKE ekkn-kostl,              " Cost Center
      END OF t_data.

DATA: BEGIN OF t_ekko OCCURS 0,
        ebeln LIKE ekko-ebeln,              " PO number
        bsart LIKE ekko-bsart,              " PO type
        aedat LIKE ekko-aedat,              " Date order issued
        lifnr LIKE ekko-lifnr,              " Vendor number
        ekgrp LIKE ekko-ekgrp,              " PO group
        kostl LIKE ekkn-kostl,              " Cost Center
      END OF t_ekko.

DATA: BEGIN OF t_lfa1 OCCURS 0,
        lifnr LIKE lfa1-lifnr,              " Vendor Number
        name1 LIKE lfa1-name1,              " Vendor Name
      END OF t_lfa1.

DATA: BEGIN OF t_ekpo OCCURS 0,
        ebeln LIKE ekpo-ebeln,              " PO number
        ebelp LIKE ekpo-ebelp,              " PO item
        bednr LIKE ekpo-bednr,              " PO item Tracking no
        labnr LIKE ekpo-labnr,              " Ord acknowledgment number
        matnr LIKE ekpo-matnr,              " Material number
        txz01 LIKE ekpo-txz01,              " Material Description
        menge LIKE ekpo-menge,              " Quantity ordered
        meins LIKE ekpo-meins,              " UOM
      END OF t_ekpo.

DATA: BEGIN OF t_header.
    INCLUDE STRUCTURE thead.            " Text header
DATA: END OF t_header.

DATA: BEGIN OF t_lines OCCURS 0.
    INCLUDE STRUCTURE tline.            " Text Lines
DATA: END OF t_lines.

DATA: BEGIN OF t_cdhdr OCCURS 0.
    INCLUDE STRUCTURE cdhdr.            " Change Header
DATA: END OF t_cdhdr.

DATA: BEGIN OF t_edit OCCURS 0.
    INCLUDE STRUCTURE cdshw.            " Chg docs, formatting tab
DATA: END OF t_edit.

DATA: BEGIN OF t_ausg OCCURS 0.
    INCLUDE STRUCTURE cdshw.            " Chg docs, formatting tab
DATA: changenr LIKE cdhdr-changenr,         " Change Number
      udate    LIKE cdhdr-udate,       " Change Date
      utime    LIKE cdhdr-utime,       " Time of Change
      END OF t_ausg.

DATA: BEGIN OF t_expedite OCCURS 0,
        udate      LIKE cdhdr-udate,       " Change Date
        changenr   LIKE cdhdr-changenr,    " Change Number
        objectclas LIKE cdhdr-objectclas,  " Object Class
        objectid   LIKE cdhdr-objectid,    " Object ID
      END OF t_expedite.

DATA: BEGIN OF t_ekkey,
        ebeln LIKE ekko-ebeln,        " PO Number
        ebelp LIKE ekpo-ebelp,        " PO Item
        zekkn LIKE ekkn-zekkn,        " Seq num of acct assignment
        etenr LIKE eket-etenr,        " Del sched line counter
        abruf LIKE ekek-abruf,        " Release number
      END OF t_ekkey.

************************************************************************
* Selection Screen                                                     *
************************************************************************
CONSTANTS: c_on(1)      TYPE c VALUE 'X',   " On flag
           c_off(1)     TYPE c VALUE ' ',   " Off flag
           c_req(1)     TYPE c VALUE 'B',
           c_id         LIKE thead-tdid        VALUE 'F06', "text elem
           c_object     LIKE thead-tdobject    VALUE 'EKPO', "Object
           c_ekl_object LIKE cdhdr-objectclas  VALUE 'EINKBELEG'.
" Object Class

************************************************************************
* Selection Screen                                                     *
************************************************************************
SELECTION-SCREEN BEGIN OF BLOCK global WITH FRAME TITLE TEXT-001.
"text-001 - Global Criteria
SELECT-OPTIONS: s_ebeln  FOR ekpo-ebeln MATCHCODE OBJECT mekk,
                s_ekgrp  FOR ekko-ekgrp MEMORY ID ekg,
                s_ernam  FOR ekko-ernam,                    "CL02042002
                s_lifnr  FOR ekko-lifnr MATCHCODE OBJECT kred,
                s_matkl  FOR ekpo-matkl DEFAULT 'M*' OPTION CP,
                                                            "CL01042002
                s_bednr3 FOR ekpo-bednr,
                s_werks3 FOR ekpo-werks MEMORY ID wrk,
                s_bsart  FOR ekko-bsart,
*                  s_aufnr  for ekkn-aufnr,            "start DG
                s_aufnr  FOR ekkn-aufnr MATCHCODE OBJECT ordp,
*                                                      "end DG
                s_kostl  FOR ekkn-kostl,
                s_pspnr3 FOR ekkn-ps_psp_pnr MATCHCODE OBJECT prpm.

SELECTION-SCREEN END OF BLOCK global.

SELECTION-SCREEN BEGIN OF BLOCK sort WITH FRAME
                                     TITLE TEXT-021.
"text-021 - Sort Order
SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN COMMENT 1(15) TEXT-t01.
SELECTION-SCREEN POSITION 21.
PARAMETERS: p_svendr RADIOBUTTON GROUP sort DEFAULT 'X'.
SELECTION-SCREEN COMMENT 27(15) TEXT-t02.
SELECTION-SCREEN POSITION 47.
PARAMETERS: p_strack RADIOBUTTON GROUP sort.
SELECTION-SCREEN COMMENT 53(15) TEXT-t03.
SELECTION-SCREEN POSITION 73.
PARAMETERS: p_nddate RADIOBUTTON GROUP sort.
SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN END OF BLOCK sort.

SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE TEXT-002.
"text-002 - Select Order Items
PARAMETERS: p_opt1 RADIOBUTTON GROUP rsel DEFAULT 'X'.
PARAMETERS: p_opt2 RADIOBUTTON GROUP rsel,
            p_opt4 RADIOBUTTON GROUP rsel,
            p_opt5 RADIOBUTTON GROUP rsel,
            p_opt3 AS CHECKBOX.

SELECTION-SCREEN END OF BLOCK b1.

SELECTION-SCREEN BEGIN OF BLOCK option3 WITH FRAME TITLE TEXT-005.
"text-005 - Additional Selection Options
SELECT-OPTIONS: s_eindt3 FOR eket-eindt.
SELECT-OPTIONS: s_ingpr  FOR afih-ingpr,
                s_udate  FOR cdhdr-udate.

SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN COMMENT (31) TEXT-202.
PARAMETERS: p_exp AS CHECKBOX               DEFAULT 'X'.
SELECTION-SCREEN END OF LINE.

SELECTION-SCREEN END OF BLOCK option3.

************************************************************************
* Event AT SELECTION-SCREEN                                            *
************************************************************************
AT SELECTION-SCREEN.

AT SELECTION-SCREEN ON s_werks3.
  CALL FUNCTION 'Z_PLANT_SECURITY_SEL_SCR'
    EXPORTING
      e_parameter_type = 'S'
    TABLES
      r_werks          = s_werks3
    EXCEPTIONS
      incorrect_call   = 1
      OTHERS           = 2.


************************************************************************
* Event START-OF-SELECTION                                             *
************************************************************************
START-OF-SELECTION.

  PERFORM sub_main_processing.

  PERFORM sub_get_work_orders.

************************************************************************
* Event END-OF-SELECTION                                               *
************************************************************************
END-OF-SELECTION.

  DESCRIBE TABLE t_data LINES g_lines.
  IF g_lines > 0.
    PERFORM sub_write_output.
  ELSE.
    WRITE: /2 'No records found'.
  ENDIF.                               " g_lines > 0

  PERFORM sub_end_of_report.

************************************************************************
* Event TOP-OF-PAGE                                                    *
************************************************************************
TOP-OF-PAGE.

  PERFORM sub_top_of_page.

************************************************************************
* Event AT LINE-SELECTION                                              *
************************************************************************
AT LINE-SELECTION.

  PERFORM sub_line_selection.

************************************************************************
* Form SUB_MAIN_PROCESSING
************************************************************************
* Subroutine that takes care of the main processing of the report
************************************************************************
FORM sub_main_processing.

  PERFORM sub_main_selects.

  LOOP AT t_ekko.
* Get Vendor name
    CLEAR t_lfa1.
    READ TABLE t_lfa1 WITH KEY lifnr = t_ekko-lifnr BINARY SEARCH.

    LOOP AT t_ekpo WHERE ebeln = t_ekko-ebeln.

      CLEAR g_sched.
      PERFORM sub_get_quantity.

* Check that total delivered < scheduled quantity
      IF g_qty < g_shqty.

        SELECT * FROM eket
          WHERE ebeln = t_ekko-ebeln
          AND   ebelp = t_ekpo-ebelp
          ORDER BY slfdt ASCENDING.

          CHECK eket-wemng < eket-menge.

* If Additional Selection Option checkbox is blank, just check
* date radiobuttons and get ROS details.
          IF p_opt3 = c_off.
            g_flag = c_off.

            PERFORM sub_check_dates USING g_flag.
            IF g_flag = c_on.
*--Get requisition details from EBAN if they exist.
              CLEAR eban.
              SELECT SINGLE * FROM eban
              WHERE banfn = eket-banfn
              AND   bnfpo = eket-bnfpo.

              PERFORM sub_store_data.
            ENDIF.

* Else if Additional Selection Option checkbox isn't blank,
* check dates radiobuttons as well as additional selection criteria.
          ELSEIF p_opt3 = 'X' AND g_sched = 0.
            g_flag = c_off.
            PERFORM sub_check_dates USING g_flag.

            CHECK g_flag = c_on.
* All outstanding items by various criteria
*            g_char = ekko-ekgrp+2(1).
            PERFORM sub_get_latest_eindt.
* Only test first item
            g_sched = 1.

*             Stock POs never have an account assignment
*             so only check against EKKN if a WBS element
*             was given on the seln screen.
            IF s_pspnr3-sign NE space.
* AUCT-UPGRADE -  Begin of Modification by <USER> on <17.02.2017> for <EHP8>
*                select single * from ekkn
*                  where ebeln       = t_ekko-ebeln
*                  and   ebelp       = t_ekpo-ebelp
*                  and   ps_psp_pnr in s_pspnr3.
              SELECT * UP TO 1 ROWS FROM ekkn
              WHERE ebeln = t_ekko-ebeln
              AND ebelp = t_ekpo-ebelp
              AND ps_psp_pnr IN s_pspnr3
              ORDER BY PRIMARY KEY.
              ENDSELECT.
* AUCT-UPGRADE -  End of Modification by <USER> on <17.02.2017> for <EHP8>

              g_sysubrc = sy-subrc.
            ELSE.
              g_sysubrc = 0.
            ENDIF.

            IF    g_sysubrc        = 0
              AND eket-slfdt      IN s_eindt3.
*                and eket-EINDT      in s_eindt3.

              .
*              Get requisition details from EBAN.
              CLEAR eban.
              SELECT SINGLE banfn
                            bnfpo
                            lfdat
                FROM eban
                INTO (eban-banfn,
                      eban-bnfpo,
                      eban-lfdat)
              WHERE banfn = eket-banfn
              AND   bnfpo = eket-bnfpo.

              PERFORM sub_store_data.

            ENDIF.                   " if eket-slfdt ...
          ENDIF.                       " If p_opt3 checkbox is set
        ENDSELECT.                     " * from eket
      ENDIF.                           " eket-wemng < eket-menge.
    ENDLOOP.                            " loop at t_ekpo
  ENDLOOP.                               " loop at t_ekko

ENDFORM.        "sub_main_processing
************************************************************************
* Form SUB_MAIN_SELECTS
************************************************************************
* Most of the selects for this program will take place in this
* subroutine
************************************************************************
FORM sub_main_selects.

  DATA: l_lines_aufnr TYPE i,                " Check if s_aufnr is initial
        l_lines_kostl TYPE i.                " Check is s_kostl is initial

  DESCRIBE TABLE s_aufnr LINES l_lines_aufnr.
  DESCRIBE TABLE s_kostl LINES l_lines_kostl.
  g_lines2 = l_lines_aufnr + l_lines_kostl.

  IF g_lines2 > 0.
* Get data from EKKO
    SELECT ekko~ebeln
           ekko~bsart
           ekko~aedat
           ekko~lifnr
           ekko~ekgrp
           ekkn~kostl
      INTO TABLE t_ekko
      FROM ekkn JOIN ekko
        ON ( ekkn~ebeln = ekko~ebeln )
     WHERE ekko~ebeln IN s_ebeln
       AND ekko~ekgrp IN s_ekgrp
       AND ekko~lifnr IN s_lifnr
       AND ekko~bsart IN s_bsart
       AND ekkn~aufnr IN s_aufnr
       AND ekkn~kostl IN s_kostl
       AND ekko~ernam IN s_ernam.                           "CL02042002

  ELSE.
    SELECT ebeln
           bsart
           aedat
           lifnr
           ekgrp
      INTO TABLE t_ekko
      FROM ekko
     WHERE ebeln IN s_ebeln
       AND ekgrp IN s_ekgrp
       AND lifnr IN s_lifnr
       AND bsart IN s_bsart
       AND ekko~ernam IN s_ernam.                           "CL02042002

  ENDIF.

  SORT t_ekko BY ebeln.
  DELETE ADJACENT DUPLICATES FROM t_ekko.
* Get vendor name for each PO
  SELECT lifnr
         name1
    FROM lfa1
    INTO TABLE t_lfa1
     FOR ALL ENTRIES IN t_ekko
   WHERE lifnr = t_ekko-lifnr.

  IF sy-subrc = 0.
    SORT t_lfa1 BY lifnr.
  ENDIF.

  SELECT ebeln
         ebelp
         bednr
         labnr
         matnr
         txz01
         menge
         meins
    FROM ekpo
    INTO TABLE t_ekpo
     FOR ALL ENTRIES IN t_ekko
   WHERE ebeln = t_ekko-ebeln
     AND matkl IN s_matkl
     AND bednr IN s_bednr3
     AND werks IN s_werks3
     AND ( wepos <> space
     OR  weunb <> space )
     AND elikz =  space
     AND loekz =  space.

ENDFORM.     "sub_main_selects

************************************************************************
* Form Sub_Get_Quantity                                                *
************************************************************************
FORM sub_get_quantity.

* Routine to get total quantity delivered
  CLEAR: g_qty,
         g_shqty.

  SELECT * FROM eket
    WHERE ebeln = t_ekko-ebeln
    AND   ebelp = t_ekpo-ebelp.

    g_qty   = g_qty   + eket-wemng.
    g_shqty = g_shqty + eket-menge.
    g_outst = g_shqty - g_qty.

  ENDSELECT.

ENDFORM.                              "sub_get_quantity

*&---------------------------------------------------------------------*
*&      Form  SUB_CHECK_DATES
*&---------------------------------------------------------------------*
*       Check dates are within specified range, if so set flag to on.  *
*----------------------------------------------------------------------*
FORM sub_check_dates USING flag.

  IF p_opt1 = 'X' AND g_sched = 0.
* All overdue order items
* Check that date is earlier than today.
*    eket-slfdt with space. "no-gaps. " spaces.
*  if  eket-slfdt ne '00000000'.
*    if eket-slfdt < sy-datum.
    IF eket-eindt < sy-datum.                               "MD1K977580
      flag = c_on.
      g_sched = 1.
    ENDIF.
*   endif.
  ELSEIF p_opt2 = 'X' AND g_sched = 0.
* All items where largest delivery estimate is larger than orig due date
    IF eket-eindt > eket-slfdt.
      flag = c_on.
      g_sched = 1.
    ENDIF.
  ELSEIF p_opt4 = 'X' AND g_sched = 0.
* All items where latest known due date is less than today's date.
*     if eket-eindt < sy-datum.
    IF eket-eindt < sy-datum.
      flag = c_on.
      g_sched = 1.
    ENDIF.
  ELSEIF p_opt5 = 'X' AND g_sched = 0.
    flag = c_on.
    g_sched = 1.
  ENDIF.

ENDFORM.                    " SUB_CHECK_DATES

************************************************************************
* Form Sub_Store_Data                                                  *
************************************************************************
FORM sub_store_data.
  CLEAR t_data.
  t_data-lifnr = t_ekko-lifnr.         " Vendor number
  t_data-name1 = t_lfa1-name1.         " Vendor name
  t_data-ebeln = t_ekko-ebeln.         " PO number
  t_data-ebelp = t_ekpo-ebelp.         " PO item
  t_data-bednr = t_ekpo-bednr.         " Item Tracking no
  t_data-labnr = t_ekpo-labnr.         " Vendor ack ref
  t_data-matnr = t_ekpo-matnr.         " Material number
  t_data-txz01 = t_ekpo-txz01.         " Material Description
  t_data-menge = t_ekpo-menge.         " Quantity ordered
  t_data-outst = g_outst.              " Outstanding qty
  t_data-meins = t_ekpo-meins.         " UOM
  t_data-aedat = t_ekko-aedat.         " Date order issued
  t_data-slfdt = eket-slfdt.           " Latest due date
  t_data-eindt = eket-eindt.           " Original due date
  t_data-banfn = eban-banfn.           " Requisition number
  t_data-bnfpo = eban-bnfpo.           " Requisition item
  t_data-lfdat = eban-lfdat.           " Reqstn Reqd Dt
  t_data-ekgrp = t_ekko-ekgrp.         " PO Group
  t_data-bsart = t_ekko-bsart.         " PO type
  t_data-kostl = t_ekko-kostl.         " Cost Center
  APPEND t_data.

ENDFORM.                               "sub_store_data

************************************************************************
* Form Sub_Get_Latest_Eindt                                            *
************************************************************************
FORM sub_get_latest_eindt.

  CLEAR g_date.

  SELECT MAX( eindt ) FROM ekes INTO g_date
    WHERE ebeln = t_ekko-ebeln
    AND   ebelp = t_ekpo-ebelp.

ENDFORM.                               "sub_get_latest_eindt

************************************************************************
* FORM SUB_GET_WORK_ORDERS                                             *
************************************************************************
FORM sub_get_work_orders.

*--Only require 'SB' documents if doing an MRP run.
  CLEAR t_data.

  CLEAR t_data.
*--If Mntnce Plan Grp selected get Work Orders which contains PO's in
*--i_data and which lie within the s_ingpr range. Otherwise delete.
  IF s_ingpr-sign NE space.
    LOOP AT t_data.

      CLEAR: resb, afih, g_tabix, g_sysubrc.
      g_tabix = sy-tabix.
      SELECT * FROM resb WHERE ebeln = t_data-ebeln
                         AND   ebelp = t_data-ebelp.

        IF resb-banfn NE space
          AND  resb-bnfpo NE space
           AND resb-aufnr NE space.

          SELECT SINGLE * FROM afih WHERE aufnr = resb-aufnr
                                    AND   ingpr IN s_ingpr.
          g_sysubrc = sy-subrc.
          IF g_sysubrc NE 0.
            DELETE t_data INDEX g_tabix.
          ENDIF.
        ELSE.
          DELETE t_data INDEX g_tabix.
        ENDIF.
      ENDSELECT.

      g_sysubrc = sy-subrc.
      IF g_sysubrc NE 0.
        DELETE t_data INDEX g_tabix.
      ENDIF.
    ENDLOOP.
  ENDIF.

ENDFORM.                               "sub_get_work_orders

************************************************************************
* Form Sub_End_Of_Report                                               *
************************************************************************
FORM sub_end_of_report.

  RESERVE 5 LINES.
  SKIP 2.
  ULINE /54(25).
  WRITE: /54 sy-vline NO-GAP,
            TEXT-201 NO-GAP,           "*****END OF REPORT*****
            sy-vline.
  ULINE /54(25).

ENDFORM.                               "SUB_END_OF_REPORT

************************************************************************
* FORM SUB_TOP_OF_PAGE                                                 *
************************************************************************
FORM sub_top_of_page.

  FORMAT INTENSIFIED OFF.
  FORMAT COLOR COL_HEADING.
  PERFORM sub_header.
  ULINE.

  WRITE: 00 TEXT-012,               " 'Order'
         12 TEXT-013,               " 'Item'
         20 TEXT-014,               " 'Material No'
         35 TEXT-015,               " 'Description'
         76 TEXT-016,               " 'Outstanding Qty'
         93 TEXT-017,               " 'Dt Raised'
        104 TEXT-018,               " 'Orig Due'
        115 TEXT-019,               " 'Now Due'
        122(12) space.
  NEW-LINE.
  WRITE: 00 TEXT-025,               " 'Req Number'
         12 TEXT-026,               " 'Req Item'
         20 TEXT-023,               " 'Tracking No'
         35 TEXT-020,               " 'Acknowledgement No'
         93 TEXT-027,               " 'Last Expedited'
        115 TEXT-024,               " 'Reqstn Reqd Dt'
        129(5) space.

  NEW-LINE.
  WRITE: 00 TEXT-033,               " 'Cost Object'
        102(32) space.

  WRITE: 00 'Expediting Notes',                             "CL02042002
         102(32) space.                                     "CL02042002


  ULINE.
  FORMAT COLOR OFF.
  NEW-LINE.

ENDFORM.                               "sub_top_of_page

************************************************************************
* FORM SUB_LINE_SELECTION                                              *
************************************************************************
FORM sub_line_selection.

* Check to see if user has clicked on heading or blank line.
  CLEAR: t_data-ebeln,
         t_data-ebelp.

  CLEAR: g_udate.

  READ LINE sy-lilli.

  IF t_data-ebeln = space.
    MESSAGE s802(za).
  ELSE.
    GET CURSOR FIELD g_fieldname VALUE g_fieldvalue.
    IF sy-subrc = 0 AND g_fieldname = 'G_UDATE'.
      PERFORM sub_write_text_window.

    ELSEIF sy-subrc = 0 AND g_fieldname = 'G_COSTOBJ'
                        AND NOT g_costobj IS INITIAL.
      SET PARAMETER ID 'ANR' FIELD g_costobj.
      CALL TRANSACTION 'KO03' AND SKIP FIRST SCREEN.
    ELSE.

      SET PARAMETER ID 'BES' FIELD t_data-ebeln.
      CALL TRANSACTION 'ZE22' AND SKIP FIRST SCREEN.

    ENDIF.
  ENDIF.

ENDFORM.                               "sub_line_selection

************************************************************************
* Form Sub_WRITE_OUTPUT                                                *
************************************************************************
FORM sub_write_output.

  DATA: g_lifnr LIKE lfa1-lifnr.

  DATA:  l_name  LIKE thead-tdname.                         "CL02042002
  DATA:  t_text  LIKE tline OCCURS 0 WITH HEADER LINE.      "CL02042002

  CLEAR: g_lifnr.

  IF p_svendr EQ 'X'.
    SORT t_data BY lifnr aedat ebeln ebelp.
  ELSEIF p_strack EQ 'X'.
    SORT t_data BY bednr lifnr aedat ebeln ebelp.
  ELSE.
    SORT t_data BY eindt lifnr aedat ebeln ebelp.
  ENDIF.

  LOOP AT t_data.
*--Get change document header to find out last expedite update on
*--text block
    PERFORM sub_check_cdhdr USING t_data-ebeln
                                  t_data-ebelp
                                  g_udate.

    CHECK g_udate IN s_udate.

    FORMAT HOTSPOT ON.

    IF g_lifnr NE t_data-lifnr.

      FORMAT: COLOR COL_NEGATIVE, INVERSE OFF, INTENSIFIED OFF.

      SKIP.

      WRITE:/00 TEXT-010,                 " Vendor:
                t_data-lifnr,
                t_data-name1,
            132 space.

      FORMAT: COLOR OFF.

      g_lifnr = t_data-lifnr.

    ENDIF.

    SKIP.

*--Get change document header to find out last expedite update on
*--text block
    PERFORM sub_check_cdhdr USING t_data-ebeln
                                   t_data-ebelp
                                   g_udate.

    WRITE:  /00 t_data-ebeln,
             12 t_data-ebelp,
             20 t_data-matnr,
             35 t_data-txz01.

    HIDE: t_data-ebeln,
          t_data-ebelp.

    MOVE t_data-outst TO g_tmpqty.

    WRITE:  g_tmpqty,
            t_data-meins,
            t_data-aedat,
            t_data-slfdt,
            t_data-eindt.

    NEW-LINE.

    WRITE: 00 t_data-banfn,
           12 t_data-bnfpo,
           20 t_data-bednr,
           35 t_data-labnr.
    IF NOT g_udate IS INITIAL.
      WRITE: 92 space.
      FORMAT: COLOR COL_GROUP.
      WRITE:  93 g_udate.
      FORMAT: COLOR COL_GROUP OFF.
    ELSE.
      WRITE:  93 g_udate.
    ENDIF.
    WRITE: 115 t_data-lfdat.

    HIDE: t_data-ebeln,
          t_data-ebelp,
          g_udate.

    NEW-LINE.
    IF g_lines2 = 0.
* AUCT-UPGRADE -  Begin of Modification by <USER> on <17.02.2017> for <EHP8>
*     select single kostl
*       from ekkn
*       into g_costobj
*      where ebeln = t_data-ebeln
*        and ebelp = t_data-ebelp.
      SELECT kostl
             FROM ekkn
             INTO g_costobj
            WHERE ebeln = t_data-ebeln
              AND ebelp = t_data-ebelp
      ORDER BY PRIMARY KEY.
        EXIT.
      ENDSELECT.
* AUCT-UPGRADE -  End of Modification by <USER> on <17.02.2017> for <EHP8>
    ELSE.
      MOVE t_ekko-kostl TO g_costobj.
    ENDIF.

    WRITE: 00 g_costobj.

    HIDE: t_data-ebeln,
          t_data-ebelp,
          g_udate,
          g_costobj.

*************begin of CL02042002 changes
    IF p_exp = c_on.
      CONCATENATE t_data-ebeln t_data-ebelp INTO l_name.

*   Write expediting notes
      CALL FUNCTION 'READ_TEXT'
        EXPORTING
          client                  = sy-mandt
          id                      = 'F06'
          language                = 'E'
          name                    = l_name
          object                  = 'EKPO'
        TABLES
          lines                   = t_text
        EXCEPTIONS
          id                      = 1
          language                = 2
          name                    = 3
          not_found               = 4
          object                  = 5
          reference_check         = 6
          wrong_access_to_archive = 7
          OTHERS                  = 8.

      IF sy-subrc = 0.
        LOOP AT t_text.
          WRITE:  / t_text-tdline.
        ENDLOOP.
      ENDIF.
    ENDIF.
*************end of CL02042002 changes

    FORMAT HOTSPOT OFF.

  ENDLOOP.

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  SUB_CHECK_REQUISITION_DETAILS
*&---------------------------------------------------------------------*
*       If ROS date set, get requisition details.                      *
*----------------------------------------------------------------------*
FORM sub_check_requisition_details.

  g_flag = c_off.

  CLEAR eban.
*--Get requisition details from EBAN.
  SELECT SINGLE * FROM eban WHERE banfn = eket-banfn
                            AND   bnfpo = eket-bnfpo.

  CHECK sy-subrc EQ 0.
  PERFORM sub_store_data.
  g_flag = c_on.

  CHECK g_flag = c_off.
*--If one of ROS endangered flag is set,
*--Check Req has processing status = 'B'
  CHECK eban-bstyp = c_req.

  IF eban-lfdat > eket-eindt.
    CLEAR g_date_diff.
*--calculate the difference between the ROS date and the PO item del. dt
    CALL FUNCTION 'SD_DATETIME_DIFFERENCE'
      EXPORTING
        date1            = eban-lfdat
        time1            = sy-uzeit
        date2            = eket-eindt
        time2            = sy-uzeit
      IMPORTING
        datediff         = g_date_diff
      EXCEPTIONS
        invalid_datetime = 1
        OTHERS           = 2.

    CHECK sy-subrc EQ 0.
    CHECK g_date_diff < 5.
    PERFORM sub_store_data.
  ELSE.
    PERFORM sub_store_data.
  ENDIF.
ENDFORM.                    " SUB_CHECK_REQUISITION_DETAILS

*&---------------------------------------------------------------------*
*&      Form  SUB_CHECK_CDHDR
*&---------------------------------------------------------------------*
*       Find out if Expediting comments have been updated on PO item.  *
*----------------------------------------------------------------------*
FORM sub_check_cdhdr USING l_ebeln l_ebelp l_udate.

  DATA: l_newebeln(10) TYPE n.         "PO with leading zeros

  REFRESH: t_cdhdr.
  CLEAR:   t_cdhdr, l_udate.

  l_newebeln = l_ebeln.
  g_objectid = l_newebeln.

  CALL FUNCTION 'CHANGEDOCUMENT_READ_HEADERS'
    EXPORTING
      objectclass       = c_ekl_object
      objectid          = g_objectid
      username          = ' '
    TABLES
      i_cdhdr           = t_cdhdr
    EXCEPTIONS
      no_position_found = 1
      OTHERS            = 2.

  CHECK sy-subrc EQ 0.

  DELETE t_cdhdr WHERE change_ind EQ 'I'.
  CHECK NOT t_cdhdr[] IS INITIAL.

  SORT t_cdhdr BY udate changenr.

  LOOP AT t_cdhdr.
    CALL FUNCTION 'CHANGEDOCUMENT_READ_POSITIONS'
      EXPORTING
        changenumber      = t_cdhdr-changenr
      IMPORTING
        header            = cdhdr
      TABLES
        editpos           = t_edit
      EXCEPTIONS
        no_position_found = 1
        OTHERS            = 2.

    CHECK sy-subrc EQ 0.

*-- ?nderungsbelegzeilen in Ausgabeformat.-----------------------------*
**-- Changed to use different text element.
    LOOP AT t_edit WHERE textart = c_id.                   "F06
      PERFORM ekkey_aufbauen.
      MOVE t_edit TO t_ausg.
      t_ausg-changenr = t_cdhdr-changenr.
      t_ausg-tabkey   = t_ekkey.
      t_ausg-udate    = t_cdhdr-udate.
      t_ausg-utime    = t_cdhdr-utime.
      APPEND t_ausg.
    ENDLOOP.
  ENDLOOP.

  CONCATENATE l_ebeln l_ebelp INTO g_key.
  SORT t_ausg BY udate utime.
  LOOP AT t_ausg WHERE tabkey(15) = g_key.
    MOVE: t_ausg-udate TO l_udate.
  ENDLOOP.

ENDFORM.                    " SUB_CHECK_CDHDR
*&---------------------------------------------------------------------*
*&      Form  EKKEY_AUFBAUEN
*&---------------------------------------------------------------------*
*       text                                                           *
*----------------------------------------------------------------------*
FORM ekkey_aufbauen.

  CLEAR t_ekkey.
  IF t_edit-text_case NE space.
    MOVE t_edit-tabkey TO t_ekkey.
  ELSE.
    MOVE t_edit-tabkey+3 TO t_ekkey.
  ENDIF.
  IF t_ekkey-ebelp CO space.
    t_ekkey-ebelp = '00000'.
  ENDIF.
  CASE t_edit-tabname.
    WHEN 'EKET'.
      t_ekkey-etenr = t_ekkey+15(5).
      CLEAR t_ekkey-zekkn.
    WHEN 'EKES'.
      t_ekkey-etenr = t_ekkey+15(5).
      t_ekkey-zekkn = 99.
    WHEN 'EKEK'.
      t_ekkey-etenr = '00000'.
      t_ekkey-abruf = t_ekkey+20(10).
      t_ekkey-zekkn = 99.
  ENDCASE.
ENDFORM.                    " EKKEY_AUFBAUEN

*&---------------------------------------------------------------------*
*&      Form  SUB_WRITE_TEXT_WINDOW
*&---------------------------------------------------------------------*
*       text                                                           *
*----------------------------------------------------------------------*
FORM sub_write_text_window.

  WINDOW STARTING AT 5   5
  ENDING AT          80 15.

  REFRESH t_lines.

  CONCATENATE t_data-ebeln t_data-ebelp INTO g_name.
  CALL FUNCTION 'READ_TEXT'            " Fetch Memo Data.
    EXPORTING
      id                      = c_id
      language                = sy-langu
      name                    = g_name
      object                  = c_object
    IMPORTING
      header                  = t_header
    TABLES
      lines                   = t_lines
    EXCEPTIONS
      id                      = 1
      language                = 2
      name                    = 3
      not_found               = 4
      object                  = 5
      reference_check         = 6
      wrong_access_to_archive = 7
      OTHERS                  = 8.


  FORMAT INTENSIFIED OFF.
  FORMAT COLOR COL_NEGATIVE.
  WRITE:  /002 'Expediting Text for', t_data-ebeln, t_data-ebelp.
  DESCRIBE TABLE t_lines LINES g_txlines.   " If any entries.

  FORMAT COLOR COL_TOTAL.
  IF g_txlines > 0.
    LOOP AT t_lines.
      WRITE : /002 t_lines-tdline.      " Output Memo Text.
    ENDLOOP.
  ELSE.
    WRITE : /002 'No text found.'.
  ENDIF.
ENDFORM.                    " SUB_WRITE_TEXT_WINDOW

************************************************************************
* Form SUB_WRITE_HEADER                                                *
************************************************************************
FORM sub_header.

  DATA: l_msg(255)   TYPE c,
        l_eoffset    TYPE i,
        l_coffset    TYPE i,
        l_id_coffset TYPE i,
        l_toffset    TYPE i,
        l_hd1len     TYPE i,
        l_hd2len     TYPE i,
        l_page(10)   TYPE c,
        l_rptwid     TYPE i,
        l_repid      LIKE sy-repid.

  CONCATENATE '(' sy-repid ')' INTO l_repid.

  l_rptwid = sy-linsz.                             "Width of Report
  l_hd1len = strlen( sy-title ).                   "Length of title
  l_hd2len = strlen( l_repid ).                    "Length of Program ID

* Calculate offsets into line
  l_id_coffset = ( l_rptwid / 2 ) - ( l_hd2len / 2 ). "id center offset
  l_coffset    = ( l_rptwid / 2 ) - ( l_hd1len / 2 ). "center offset
  l_eoffset    = l_rptwid  - 12.                      "18 chars from end
  l_toffset    = l_eoffset - 7.                       "Label offset.

  CLEAR l_msg.
  WRITE: 'System:'             TO l_msg,
         sy-sysid              TO l_msg+9,
         sy-title              TO l_msg+l_coffset,    "write title
         'Date:'               TO l_msg+l_toffset,
         sy-datum              TO l_msg+l_eoffset.
  WRITE l_msg.

  CLEAR l_msg.
  WRITE: 'Client:'             TO l_msg,
          sy-mandt             TO l_msg+9,
          l_repid              TO l_msg+l_id_coffset,
         'Time:'               TO l_msg+l_toffset,
         sy-uzeit              TO l_msg+l_eoffset.
  WRITE l_msg.


  CLEAR l_msg.
  l_page = sy-pagno.
  WRITE: 'User  :'             TO l_msg,
         sy-uname              TO l_msg+9,
         'Page:'               TO l_msg+l_toffset,
         l_page                TO l_msg+l_eoffset.
  WRITE l_msg.

ENDFORM.
