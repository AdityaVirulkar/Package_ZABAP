*++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*
* CHANGE ID : HANA-001
* USER: ACC11346068
* DATE: 02.06.2017
* TR : S7HK900166
* DESCRIPTION: HANA CORRECTION
* TEAM : HANA-MIGRATION
*++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*
REPORT (sy-repid)
       NO STANDARD PAGE HEADING
       LINE-COUNT 65
       LINE-SIZE  255
       message-id zz.
*&---------------------------------------------------------------------*
*& Report  ZMMMR400
*&
*&---------------------------------------------------------------------*
*& Author : C. Campbell

*& Purpose: This process aims to improve the visibility of materials
*&          availability & deficiencies across the supply chain spectrum
*&
*&
*&
*&---------------------------------------------------------------------*
*-----------------------------------------------------------------------
*                M O D I F I C A T I O N  L O G
*-----------------------------------------------------------------------
* Date     | Mod #    | Person     | Description
*-----------------------------------------------------------------------
*06/03/2011 126542      MKQURESHI    Report should also display the rental
*                                    equipment details specified as mobilization
*&                                   item on work order service specification.

*11/25/2011 MD1K998735 MSWAMINATHAN Output modified to incl.Delv.date
*12/20/2011 MD1K999157 MSWAMINATHAN fixing syntax eros after moving to MQ1
*12/26/2011 MD1K999215 MSWAMINATHAN created a new suboutine to hold my
*03/15/2012 MD1K9A002X mswaminathan Add sub contract qty to output
*05/10/2012 MD1K9A00AH MSWAMINATHAN Added custom  table by Validating date for
*                                   Final issue/Commit qty
* 30/05/17   NWDK902274   ABHARDWAJ     HANA Corrections
*---------------------------------------------------------------------*
*   Tables
*---------------------------------------------------------------------*

TABLES: aufk           ,    "Order master data
        viaufkst       ,    "PM Order Selection by Status
        proj           ,    "Project definition
        prps           ,    "WBS Elements
        mspr           ,    "Project Stock
        mssq           ,    "Project Stock Total
        resb           ,    "Reservation/dependent requirements
        oio_cm_oplnt   ,    "RLM Plants
        oio_cm_doc_flow,    "RLM document flow index
        mara           ,    "General Material Data
        mkpf           ,    "Header: Material Document
        mseg           ,    "Document Segment: Material
        marc           ,    "Plant Data for Material
        mard           ,    "Storage Location Data for Material
        eban           ,    "Purchase Requisition
        ekpo           ,    "Purchasing Document Item
        eket           ,    "Scheduling Agreement Schedule Lines
        ekbe           ,    "History per Purchasing Document
        ekko           ,    "Purchasing Document Header
        likp           ,    "SD Document: Delivery Header Data
        lips           ,    "SD document: Delivery: Item data
        vbup           ,    "Sales Document: Item Status
        vbfa           ,    "Sales Document Flow
        t001w          ,    "Plants/Branches
        rihea          ,    "IO Table for PM hierarchy selection/list screen
        tj02t          ,    "System status texts
        tj30t          ,    "Texts for User Status
        klah           ,    "Class Header Data
        t356_t         ,    "Priority Text
        rmclf          ,
        afvc           ,     "Operation within an order
        esll            .    "RENTAL EQUIPMENT
*----------------------------------------------------------------------*
* Classes with definition deferred
*----------------------------------------------------------------------*
* Predefine a local class for event handling to allow the declaration
* of a reference variable before the class is defined.
CLASS lcl_event_receiver DEFINITION DEFERRED.

*---------------------------------------------------------------------*
*   Type Declarations
*---------------------------------------------------------------------*

* Structure to hold the current stock levels
TYPES: BEGIN OF stk,
         matnr  TYPE matnr,
         werks  TYPE werks,
         reswk  TYPE werks,
         pspel  TYPE ps_posnr,
         unrqty TYPE labst,         "Unrestricted Stock
         reqqty TYPE resbt,         "Reservation
         outqty TYPE resbt,         "Outstanding Qty
         alriss TYPE enmng,         "Already Issued
         comqty TYPE zcoms,         "Committed (Picked & Ready)
         intran TYPE trame,         "Stock In Transit
         blkqty TYPE speme,         "Blocked/Quarantined Qty
       END OF stk.

* Structure to hold Transport requisitions and Purchase Reqs
TYPES: BEGIN OF prs,
         matnr   TYPE resb-matnr,    "Material
         werks   TYPE resb-werks,    "Plant
         aufnr   TYPE resb-aufnr,    "Order
         avail   TYPE dats,          "Availability Date
         banfn   TYPE eket-banfn,    "PR Doc Header
         bnfpo   TYPE eket-bnfpo,
         menge   TYPE eban-menge,    "Total Outstanding on Req
         afnam   TYPE eban-afnam,    "Requisitioner
         rfqdoch TYPE eket-banfn,
         rfqdocl TYPE eket-bnfpo,
         menge1  TYPE eket-menge,    "Total Scheduled Quantity on Req
         ekgrp   TYPE eban-ekgrp,
*ms
         eindt   TYPE eket-eindt, "Delivery Date.

*ms
       END OF prs.

* Structure to Hold the Purchase/Transport Orders
TYPES: BEGIN OF pos,
         matnr TYPE resb-matnr,    "Material
         werks TYPE resb-werks,    "Plant
         aufnr TYPE resb-aufnr,    "Order
         avail TYPE dats,          "Availability Date
         ebeln TYPE ekpo-ebeln,    "PR Doc Header
         ebelp TYPE ekpo-ebelp,    "PR Doc Line
         type  TYPE char3,         "PR Doc Type 'STO' or 'PO'
         menge TYPE ekpo-menge,    "PO Quantity
         webaz TYPE ekpo-webaz,    "GR Proc Time
         eindt TYPE eket-eindt,    "Item Deliv.Date
         banfn TYPE eket-banfn,
         bnfpo TYPE eket-bnfpo,
         sp3fn TYPE eket-banfn,
         sp3po TYPE eket-bnfpo,
         rsnum TYPE eban-rsnum,
         arsps TYPE eban-arsps,
         remai TYPE eket-menge,
         pspel LIKE aufk-pspel,
         ekgrp LIKE ekko-ekgrp,
       END OF pos.

* Structure to hold the Work Orders (and reservations)
TYPES: BEGIN OF ttwo,
         aufnr     TYPE aufk-aufnr,     "Order Number
         werks     TYPE aufk-werks,     "Plant
         gstrp     TYPE afko-gstrp,     "Basic Start date
         bdmng     TYPE resb-bdmng,
         banfn     TYPE eket-banfn,
         bnfpo     TYPE eket-bnfpo,
         rsnum     TYPE resb-rsnum,
         rspos     TYPE resb-rspos,
         matnr     TYPE resb-matnr,
         comp      TYPE i,
         index     TYPE i,
         banfn2    TYPE eket-banfn,
         bnfpo2    TYPE eket-bnfpo,
         bdmng2    TYPE resb-bdmng,
         bdmng3    TYPE resb-bdmng,
         bdmng4    TYPE resb-bdmng,
         prs       TYPE  prs OCCURS 0,
         prs2      TYPE  prs OCCURS 0,
         pspel     LIKE aufk-pspel,
         bdter     LIKE resb-bdter,
         enmng     LIKE resb-enmng,
         bdmngx    LIKE resb-enmng,
         oio_sproc LIKE resb-oio_sproc,
         remai     TYPE eket-menge,
       END OF ttwo.



*---------------------------------------------------------------------*
*   Data Declarations
*---------------------------------------------------------------------*

DATA: v_datum LIKE sy-datum.


*  structure of supplying plants
DATA:
  BEGIN OF t_oio_cm_oplnt OCCURS 0,
    werks LIKE oio_cm_oplnt-werks,  "plant
    reswk LIKE oio_cm_oplnt-reswk,  "supplying plant
    loccd LIKE oio_cm_oplnt-loccd,  "Location Code
    dismm LIKE marc-dismm,          "MRP Type
  END   OF t_oio_cm_oplnt,

*  Initial table containing RESB based on selection criteria
  BEGIN OF t_main OCCURS 0,
    rsnum  LIKE resb-rsnum,          "reservation nbr
    rspos  LIKE resb-rspos,          "item nbr
    rsart  LIKE resb-rsart,          "record type
    matnr  LIKE resb-matnr,          "material nbr
    werks  LIKE resb-werks,          "plant
    posnr  LIKE resb-posnr,          "BOM Item
    sortf  LIKE resb-sortf,          "Sort String
    tplnr  LIKE viaufkst-tplnr,      "functional location
    priok  LIKE viaufkst-priok,      "wo priority
    equnr  LIKE viaufkst-equnr,      "equipment number
    ingpr  LIKE viaufkst-ingpr,      "Planner Group
    bdmng  LIKE resb-bdmng,          "Requirement Total Quantity
    enmng  LIKE resb-enmng,          "Quantity Withdrawn
    bdter  LIKE resb-bdter,          "requirement date
    postp  LIKE resb-postp,          "Item cat
    aufnr  LIKE resb-aufnr,          "Order Number
    vornr  LIKE resb-vornr,          "Operation Number
    objnr  LIKE jest-objnr,          "Object Number
    pspel  LIKE resb-pspel,          "WBS Element
    projn  LIKE resb-projn,          "WBS Project Definition
    stat   LIKE jest-stat,           "Status
    outqty LIKE resb-bdmng,          "Outstanding Quantity
    vmeng  LIKE resb-vmeng,          "Confirmed Quantity for availability check
    kzear  LIKE resb-kzear,          "Final Issue flag
    mflic  LIKE rsadd-mflic,         "Proc Type
  END OF t_main,

* Begin of changes in PhaseII "MKQURESHI MD1K994820
  it_main1 LIKE TABLE OF t_main,
  gf_main1 LIKE LINE OF t_main,
  gf_main  LIKE LINE OF t_main,
*  End of changes in PhaseII "MKQURESHI MD1K994820

*  Table containing RESB and ZMM_COMMIT after status field filtered out.
  BEGIN OF t_main_stat OCCURS 0,
    rsnum             LIKE resb-rsnum,          "reservation nbr
    rspos             LIKE resb-rspos,          "item nbr
    rsart             LIKE resb-rsart,          "record type
    matnr             LIKE resb-matnr,          "material nbr
    werks             LIKE resb-werks,          "plant
    posnr             LIKE resb-posnr,          "BOM Item
    sortf             LIKE resb-sortf,          "Sort String
    tplnr             LIKE viaufkst-tplnr,      "functional location
    priok             LIKE viaufkst-priok,      "wo priority
    equnr             LIKE viaufkst-equnr,      "equipment number
    ingpr             LIKE viaufkst-ingpr,      "Planner Group
    bdmng             LIKE resb-bdmng,          "reqmts qty
    enmng             LIKE resb-enmng,          "withdrawel qty
    bdter             LIKE resb-bdter,          "requirement date
    postp             LIKE resb-postp,          "Item cat
    aufnr             LIKE resb-aufnr,          "Order Number
    vornr             LIKE resb-vornr,          "Operation Number
    objnr             LIKE jest-objnr,          "Object Number
    pspel             LIKE resb-pspel,          "WBS Element
    projn             LIKE resb-projn,          "WBS Project Definition
    outqty            LIKE resb-bdmng,          "Outstanding Quantity
    vmeng             LIKE resb-vmeng,          "Confirmed Quantity for availability check
    qty               LIKE resb-bdmng,          "Hold variable
    zcoms             LIKE zmm_commit-zcoms,    "Qty
    kzear             LIKE resb-kzear,          "Final Issue flag
    mflic             LIKE rsadd-mflic,       "Proc Type
    oio_matnr         TYPE oio_rn_matnr,        " Mobilization material
    oio_mbtxt         TYPE oio_rn_mbtxt,        "Text for mobilization of rented equipment
    oio_mbmng         TYPE oio_rn_mbmng,        "Mobilization quantity
    oio_mbmei         TYPE oio_rn_mbmei,        "Mobilization unit
    oio_rmobstat      TYPE oio_rn_mobstat,       "Mobilization Status
    oio_rmobstat_text TYPE char20,
    oio_rnumpack      TYPE oio_rn_numpack,       "Number of Packages
    oio_rvendref      TYPE oio_rn_vendref,        "Vendor's Reference
    aufpl             TYPE co_aufpl,
    packno            TYPE packno,
    sub_packno        TYPE sub_packno,
  END OF t_main_stat,



* Table containing Material Classes
  BEGIN OF t_main_mat_class OCCURS 0,
    matnr LIKE resb-matnr,          "material nbr
    class LIKE sclass-class,        "material class
  END OF t_main_mat_class,

* Table containing 'Hard Reservations'
  BEGIN OF t_zmm_commit OCCURS 0,
    rsnum LIKE zmm_commit-rsnum,    "reservation nbr
    rspos LIKE zmm_commit-rspos,    "item nbr
    rsart LIKE zmm_commit-rsart,    "record type
    matnr LIKE zmm_commit-matnr,    "material nbr
    werks LIKE zmm_commit-werks,    "plant
    zcoms LIKE zmm_commit-zcoms,    "Current Qty
    zcomo LIKE zmm_commit-zcomo,    "Overall Committed Qty
  END OF t_zmm_commit,

* System status texts
  BEGIN OF t_sys_stat_text OCCURS 0,
    istat LIKE tj02t-istat,         "system status
    txt04 LIKE tj02t-txt04,         "status text
  END OF t_sys_stat_text,

* User status texts
  BEGIN OF t_usr_stat_text OCCURS 0,
    estat LIKE tj30t-estat,         "user status
    txt04 LIKE tj30t-txt04,         "user text
  END OF t_usr_stat_text,

* Table containing WBS Elements for Project Stock
  BEGIN OF t_wbs OCCURS 0,
    pspnr LIKE prps-pspnr,                       "WBS Element (Internal)
    posid LIKE prps-posid,                       "WBS Element (External)
  END OF t_wbs.


DATA: t_main_temp  LIKE t_main OCCURS 0 WITH HEADER LINE.



* Offshore Purchase Reqs, Orders and Stock
DATA: t_pr TYPE TABLE OF prs WITH HEADER  LINE.
DATA: t_po TYPE TABLE OF pos WITH HEADER  LINE.
DATA: t_stk TYPE TABLE OF stk WITH HEADER  LINE.

* Onshore Purchase Reqs, Orders and Stock
DATA: t_b_pr TYPE TABLE OF prs WITH HEADER  LINE.
DATA: t_b_po TYPE TABLE OF pos WITH HEADER  LINE.
DATA: t_b_stk TYPE TABLE OF stk WITH HEADER  LINE.

* Structure to hold reservations/work orders
DATA: t_wo  TYPE TABLE OF ttwo WITH HEADER  LINE,
      t_wo2 TYPE TABLE OF ttwo WITH HEADER  LINE.

* Layout tables for Material Tracking details
DATA: BEGIN OF gt_mat_layout OCCURS 0.
    INCLUDE  STRUCTURE zmmtracklayout.
DATA: light TYPE c.
DATA: ebelp LIKE ekpo-ebelp.
*DATA: LIFNR LIKE LFA1-LIFNR.
DATA: bstyp LIKE ekko-bstyp."TYPE C.
DATA: END OF gt_mat_layout.

* Final layout tables for Material Tracking details
DATA: gt_mat_layout_final LIKE gt_mat_layout OCCURS 0 WITH HEADER LINE.

DATA: gt_fieldcat TYPE lvc_t_fcat WITH HEADER LINE,
      gs_layout   TYPE lvc_s_layo,
      gs_vari     TYPE disvariant,                  "for parameter IS_VARIANT
      gt_sort     TYPE lvc_t_sort WITH HEADER LINE.

DATA: g_lights_name      TYPE lvc_cifnm VALUE 'LIGHT'.

DATA: gv_title_text      TYPE c LENGTH 40.

DATA: gv_curr_year  TYPE gjahr,
      gv_curr_poper LIKE t009b-poper,
      gv_first_day  TYPE dats,
      gv_last_day   TYPE dats.


*----------------------------------------------------------------------*
* Variables  (global)
*----------------------------------------------------------------------*
DATA:
  g_sup_stock   LIKE mard-labst,         "Stock
  g_saved_tabix LIKE sy-tabix.           "saved index

*----------------------------------------------------------------------*
* Constants
*----------------------------------------------------------------------*
CONSTANTS:
  c_l(1)      TYPE c VALUE 'L',    "Stock Item
  c_n(1)      TYPE c VALUE 'N',    "Non-stock item
  c_i(01)     TYPE c VALUE 'I',    "include
  c_e(01)     TYPE c VALUE 'E',    "exclude
  c_bt(02)    TYPE c VALUE 'BT',   "between
  c_eq(02)    TYPE c VALUE 'EQ',   "equal
  c_0(01)     TYPE c VALUE '0',    "no selection criteria
  c_2(1)      TYPE c VALUE '2',    "Released status indicator
  c_double(2) TYPE c VALUE '**',   "Double Material Indicator
  c_rel(3)    TYPE c VALUE 'REL',  "Released status ind
  c_ns(2)     TYPE c VALUE 'NS',   "Non-stock status
  c_s(1)      TYPE c VALUE 'S',    "Stock Status
  c_nd(2)     TYPE c VALUE 'ND',   "SAP Non stock status ind
  c_on        TYPE c VALUE 'X',    "On flag
  c_off       TYPE c VALUE ' ',    "Off Flag
  c_period    TYPE c VALUE ',',    "Period
  c_pst(3)    TYPE c VALUE 'PST',  "PS Procurement Type PST
  c_pfv(3)    TYPE c VALUE 'PFV',  "PS Procurement Type PFV
  c_xfr(3)    TYPE c VALUE 'XFR'.  "PS Procurement Type XFR



*----------------------------------------------------------------------*
* Ranges
*----------------------------------------------------------------------*
RANGES:
   r_iphas               FOR viaufkst-iphas,  "order phase
   r_objnr               FOR viaufkst-objnr,  "include/exclude orders
   r_werks               FOR viaufkst-werks,  "Plant
   r_kzear               FOR resb-kzear,      "Final Issue
   r_priok               FOR viaufkst-priok,  "Order Priority
   r_wbs                 FOR prps-pspnr.      "WBS Elements

*-------------------------------------------------------------------*
* INCLUDES                                                          *
*-------------------------------------------------------------------*
INCLUDE <icon>.


*-------------------------------------------------------------------*
*   Selection Screen
*-------------------------------------------------------------------*
*
* PM or Project Stock Reporting (Block 1)
*
SELECTION-SCREEN BEGIN OF BLOCK zmmmr400_a WITH FRAME TITLE TEXT-f05.

* ... PM Reporting
SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN COMMENT 03(18) TEXT-003.
* FOR FIELD p_pmrep.
PARAMETERS p_pmrep RADIOBUTTON GROUP rad1 DEFAULT 'X'.
SELECTION-SCREEN END   OF LINE.

* ... PS Reporting
SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN COMMENT 03(18) TEXT-004.
PARAMETERS p_prjrep RADIOBUTTON GROUP rad1.
SELECTION-SCREEN COMMENT 24(03) TEXT-018.
PARAMETERS p_prjpst AS CHECKBOX.
SELECTION-SCREEN COMMENT 29(10) TEXT-015 FOR FIELD p_prjpst.
PARAMETERS p_prjpfv AS CHECKBOX.
SELECTION-SCREEN COMMENT 41(10) TEXT-016 FOR FIELD p_prjpfv.
PARAMETERS p_prjxfr AS CHECKBOX.
SELECTION-SCREEN COMMENT 53(10) TEXT-017 FOR FIELD p_prjxfr.
SELECTION-SCREEN END   OF LINE.

SELECTION-SCREEN END   OF BLOCK zmmmr400_a.

* Order Phase                   (Block 2)
*
SELECTION-SCREEN BEGIN OF BLOCK zmmmr400_1 WITH FRAME TITLE TEXT-f01.
SELECTION-SCREEN BEGIN OF LINE.
* ... Outstanding
PARAMETERS p_out LIKE rihea-dy_ofn DEFAULT 'X'.
SELECTION-SCREEN COMMENT 03(11) TEXT-001 FOR FIELD p_out.
* ... In Process
PARAMETERS p_prc LIKE rihea-dy_iar DEFAULT 'X'.
SELECTION-SCREEN COMMENT 16(10) TEXT-002 FOR FIELD p_prc.
SELECTION-SCREEN END   OF LINE.
SELECTION-SCREEN END   OF BLOCK zmmmr400_1.

* General Order Selections      (Block 3)
*
SELECTION-SCREEN BEGIN OF BLOCK zmmmr400_2 WITH FRAME TITLE TEXT-f02.

SELECT-OPTIONS:
  s_werks    FOR  viaufkst-werks                                     ,  "Plant
  s_aufnr    FOR  viaufkst-aufnr    MATCHCODE OBJECT ordp            ,  "Order Number
  s_auart    FOR  viaufkst-auart                                     ,  "Order Type
  s_tplnr    FOR  viaufkst-tplnr                                     ,  "Function Location
  s_stort    FOR  viaufkst-stort                                     ,  "System Location (Floc)
  s_swerk    FOR  viaufkst-swerk                                     ,  "Maintenance Plant
  s_iwerk    FOR  viaufkst-iwerk                                     ,  "Planning Plant
  s_revnr    FOR  viaufkst-revnr    MATCHCODE OBJECT revi            ,  "Revision Code
  s_ingpr    FOR  viaufkst-ingpr                                     .


PARAMETERS:
  p_priokx   LIKE t356_t-priokx     MATCHCODE OBJECT z_h_t356        .  "Priority Code

SELECT-OPTIONS:
  s_gstrp    FOR  viaufkst-gstrp                                     ,  "Basic Start date/Cutoff Date
  s_naufnr   FOR  resb-aufnr                                         ,  "Network Order
  s_vornr    FOR  resb-vornr                                         ,  "Network Activity
*  s_pspel    FOR  viaufkst-pspel    MATCHCODE OBJECT prpm            ,  "WBS Element
  s_projid   FOR  proj-pspid        NO INTERVALS NO-EXTENSION        ,  "Project definition.
  s_sytsta   FOR  tj02t-txt04       MATCHCODE OBJECT z_i_status_sys  ,  "System Status
  s_usrsta   FOR  tj30t-txt04       MATCHCODE OBJECT z_i_status_usr  ,  "User Status
  s_sortf    FOR  resb-sortf                                         ,  "Sort String
  s_matnr    FOR  eban-matnr                                         ,  "Material number
  s_matkl    FOR  eban-matkl                                         .  "Material Group

PARAMETERS:

  p_klart LIKE  rmclf-klart      NO-DISPLAY                       ,  "Class Type (Material Class)
  p_class LIKE  rmclf-class                                       .  "

SELECTION-SCREEN END OF BLOCK zmmmr400_2.

* Additional Selections      (Block 4)
*
SELECTION-SCREEN BEGIN OF BLOCK zmmmr400_3 WITH FRAME TITLE TEXT-f03.

PARAMETER : p_ship(5) TYPE c DEFAULT '5'.                        " ship time

SELECT-OPTIONS:
  s_pltoth   FOR  viaufkst-werks                                     .  "Stock at Other Locations

SELECTION-SCREEN SKIP.

PARAMETERS:

  p_finiss  AS CHECKBOX          .                                      "Item Final Issued
*  p_fulcom  AS CHECKBOX DEFAULT 'X',                                    "Item Fully Committed
*  p_hrdres  AS CHECKBOX DEFAULT 'X'.

SELECTION-SCREEN END OF BLOCK zmmmr400_3.

* Additional Selections      (Block 5)
*
SELECTION-SCREEN BEGIN OF BLOCK zmmmr400_4 WITH FRAME TITLE TEXT-f04.

SELECTION-SCREEN SKIP.

SELECTION-SCREEN BEGIN OF BLOCK zmmmr400_41 WITH FRAME TITLE TEXT-f06.
SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN COMMENT 01(19) TEXT-013 FOR FIELD p_vari.
SELECTION-SCREEN POSITION 20.
PARAMETERS  p_vari      LIKE disvariant-variant.
SELECTION-SCREEN POSITION 38.
PARAMETERS  p_print    AS CHECKBOX.
SELECTION-SCREEN COMMENT 41(30) TEXT-014 FOR FIELD p_print.
SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN END OF BLOCK zmmmr400_41.


SELECTION-SCREEN END OF BLOCK zmmmr400_4.


*----------------------------------------------------------------------*
* ABAP OO section
*----------------------------------------------------------------------*

* Container for the GUI Report Control
DATA container TYPE REF TO cl_gui_custom_container.

* ALV Grid
DATA grid1 TYPE REF TO cl_gui_alv_grid.

* Event Receivers
DATA event_receiver1     TYPE REF TO lcl_event_receiver.

*SET SCREEN 100.
**************************************************************
* Class Definition and Implementation
**************************************************************
* class lcl_event_receiver: local class to
*                         define and handle own functions.
*
* Definition
* ~~~~~~~~~~~

CLASS lcl_event_receiver DEFINITION.

  PUBLIC SECTION.

    CLASS-METHODS:

      handle_double_click FOR EVENT double_click OF cl_gui_alv_grid
        IMPORTING
            e_row
            e_column
            es_row_no
            sender,

      handle_toolbar      FOR EVENT toolbar OF cl_gui_alv_grid
        IMPORTING e_object e_interactive,

      handle_user_command FOR EVENT user_command OF cl_gui_alv_grid
        IMPORTING e_ucomm.


  PRIVATE SECTION.

ENDCLASS.                    "lcl_event_receiver DEFINITION

* Implementation
CLASS lcl_event_receiver IMPLEMENTATION.

*-------------------------------------------------------------------
* Method for event DOUBLE CLICK
*
  METHOD handle_double_click.


  ENDMETHOD.                    "handle_double_click

*-------------------------------------------------------------------
* Method for event TOOLBAR: Append own functions
*   by using event parameter E_OBJECT.
  METHOD handle_toolbar.

    DATA: ls_toolbar  TYPE stb_button.

* Stock Overview Pushbutton
* append a separator to normal toolbar
    CLEAR ls_toolbar.
    MOVE 3                     TO ls_toolbar-butn_type.
    APPEND ls_toolbar          TO e_object->mt_toolbar.
* append an icon to show Stock Overview
    CLEAR ls_toolbar.
    MOVE 'MMBE'                TO ls_toolbar-function.
    MOVE icon_material         TO ls_toolbar-icon.
    MOVE 'Stock Overview'      TO ls_toolbar-quickinfo.
    MOVE 'OverView'            TO ls_toolbar-text.
    MOVE ' '                   TO ls_toolbar-disabled.
    APPEND ls_toolbar          TO e_object->mt_toolbar.

* Stock Requirement Pushbutton
* append a separator to normal toolbar
    CLEAR ls_toolbar.
    MOVE 3                     TO ls_toolbar-butn_type.
    APPEND ls_toolbar          TO e_object->mt_toolbar.
* append an icon to Stock Requirement
    CLEAR ls_toolbar.
    MOVE 'MD04'                TO ls_toolbar-function.
    MOVE icon_material         TO ls_toolbar-icon.
    MOVE 'Stock Requirement'   TO ls_toolbar-quickinfo.
    MOVE 'Reqmnt'              TO ls_toolbar-text.
    MOVE ' '                   TO ls_toolbar-disabled.
    APPEND ls_toolbar          TO e_object->mt_toolbar.

* PO Display Pushbutton
* append a separator to normal toolbar
    CLEAR ls_toolbar.
    MOVE 3                     TO ls_toolbar-butn_type.
    APPEND ls_toolbar          TO e_object->mt_toolbar.
* append an icon to show Purchase Order
    CLEAR ls_toolbar.
    MOVE 'POPR'                TO ls_toolbar-function.
    MOVE icon_order            TO ls_toolbar-icon.
    MOVE 'PO/Req Display'      TO ls_toolbar-quickinfo.
    MOVE 'PO/Req Display'      TO ls_toolbar-text.
    MOVE ' '                   TO ls_toolbar-disabled.
    APPEND ls_toolbar          TO e_object->mt_toolbar.

* Work Order Display Pushbutton
* append a separator to normal toolbar
    CLEAR ls_toolbar.
    MOVE 3                     TO ls_toolbar-butn_type.
    APPEND ls_toolbar          TO e_object->mt_toolbar.
* append an icon to show Work Order
    CLEAR ls_toolbar.
    MOVE 'ORDE'                TO ls_toolbar-function.
*    MOVE icon_order            TO ls_toolbar-icon.
    MOVE 'Work Order'          TO ls_toolbar-quickinfo.
    MOVE 'Work Order'          TO ls_toolbar-text.
    MOVE ' '                   TO ls_toolbar-disabled.
    APPEND ls_toolbar          TO e_object->mt_toolbar.

* Material Documents Display Pushbutton
* append a separator to normal toolbar
    CLEAR ls_toolbar.
    MOVE 3                     TO ls_toolbar-butn_type.
    APPEND ls_toolbar          TO e_object->mt_toolbar.
* append an icon to show Material Documents
    CLEAR ls_toolbar.
    MOVE 'MB51'                TO ls_toolbar-function.
    MOVE icon_list             TO ls_toolbar-icon.
    MOVE 'Material Documents'  TO ls_toolbar-quickinfo.
    MOVE 'Mat. Docs.'          TO ls_toolbar-text.
    MOVE ' '                   TO ls_toolbar-disabled.
    APPEND ls_toolbar          TO e_object->mt_toolbar.

* Committed Material Enquiry Display Pushbutton
* append a separator to normal toolbar
    CLEAR ls_toolbar.
    MOVE 3                     TO ls_toolbar-butn_type.
    APPEND ls_toolbar          TO e_object->mt_toolbar.
* append an icon to show Committed Material
    CLEAR ls_toolbar.
    MOVE 'ZMMMR130'            TO ls_toolbar-function.
    MOVE icon_list             TO ls_toolbar-icon.
    MOVE 'Committed Material'  TO ls_toolbar-quickinfo.
    MOVE 'Comm. Mat.'          TO ls_toolbar-text.
    MOVE ' '                   TO ls_toolbar-disabled.
    APPEND ls_toolbar          TO e_object->mt_toolbar.

  ENDMETHOD.                    "handle_toolbar

*-------------------------------------------------------------------
* Method for event USER_COMMAND: Query your
*   function codes defined and react accordingly.

  METHOD handle_user_command.

    DATA: lt_rows           TYPE lvc_t_row.
    DATA: ls_selected_line  TYPE lvc_s_row.
    DATA: lv_row_index      TYPE lvc_index.
    DATA: ls_mat_layout     LIKE LINE OF gt_mat_layout.

    DATA: ls_aufk LIKE aufk,
          ls_ekko LIKE ekko,
          ls_eban LIKE eban.

    CALL METHOD grid1->get_selected_rows
      IMPORTING
        et_index_rows = lt_rows.

    CALL METHOD cl_gui_cfw=>flush.

    IF sy-subrc EQ 0.

      LOOP AT lt_rows INTO ls_selected_line.

        lv_row_index = ls_selected_line-index.

        READ TABLE gt_mat_layout_final INDEX lv_row_index INTO ls_mat_layout.

        EXIT.

      ENDLOOP.
      IF sy-subrc NE 0.

        MESSAGE s000 WITH 'Please select a line'.
        EXIT.

      ENDIF.

    ENDIF.

    SET PARAMETER ID 'MAT' FIELD ls_mat_layout-matnr.

    CASE e_ucomm.

* Call Stock Overview transaction based on row selected.
      WHEN 'MMBE'.
        CALL TRANSACTION 'MMBE' AND SKIP FIRST SCREEN.

* Call Stock Requirement transaction based on row selected.
      WHEN 'MD04'.
        SET PARAMETER ID 'WRK' FIELD ls_mat_layout-werks.
        CALL TRANSACTION 'MD04'.

* Call Material Documents transaction based on row selected.
      WHEN 'MB51'.
        SET PARAMETER ID 'WRK' FIELD ls_mat_layout-werks.
        SET PARAMETER ID 'ANR' FIELD ' '.
        CALL TRANSACTION 'MB51' AND SKIP FIRST SCREEN.

* Call Committed Material transaction based on row selected.
      WHEN 'ZMMMR130'.
        SET PARAMETER ID 'WRK' FIELD ls_mat_layout-werks.
        CALL TRANSACTION 'ZMMMR130' AND SKIP FIRST SCREEN.

* Check contents of Purchase Doc field and determine whether PO or Req
* Call PO or Req Display transaction based on row selected.
      WHEN 'POPR'.

        SET PARAMETER ID 'WRK' FIELD ls_mat_layout-werks.

        IF NOT ls_mat_layout-zpurdoc IS INITIAL.

          SELECT SINGLE * FROM ekko
                          INTO ls_ekko
                          WHERE ebeln = ls_mat_layout-zpurdoc.
          IF sy-subrc = 0.

            IF ls_ekko-bstyp = 'F'.       "PO

              SET PARAMETER ID 'BES' FIELD ls_mat_layout-zpurdoc.
              CALL TRANSACTION 'ME23N'.

            ELSEIF ls_ekko-bstyp = 'A'.   "RFQ

              SET PARAMETER ID 'ANF' FIELD ls_mat_layout-zpurdoc.
              CALL TRANSACTION 'ME43'.

            ENDIF.

          ELSE.

*Begin of Modify for NWDK902274
*            SELECT SINGLE * FROM eban
*                            INTO ls_eban
*                            WHERE banfn = ls_mat_layout-zpurdoc.
            SELECT * UP TO 1 ROWS FROM eban
            INTO ls_eban
            WHERE banfn = ls_mat_layout-zpurdoc
            ORDER BY PRIMARY KEY.
            ENDSELECT.
*End of Modify for NWDK902274
            IF sy-subrc = 0.
              SET PARAMETER ID 'BAN' FIELD ls_mat_layout-zpurdoc.
              CALL TRANSACTION 'ME53N'.
            ENDIF.

          ENDIF.

        ENDIF.


*Check type of Work Order selected (PM or PS) and call
*relevant Work Order Display transaction based on row selected.
      WHEN 'ORDE'.

        SET PARAMETER ID 'ANR' FIELD ls_mat_layout-aufnr.
        SET PARAMETER ID 'WRK' FIELD ls_mat_layout-werks.

        SELECT SINGLE * FROM aufk
                        INTO ls_aufk
                        WHERE aufnr = ls_mat_layout-aufnr.
        IF sy-subrc = 0.
          CASE ls_aufk-autyp.
            WHEN '20'.
              CALL TRANSACTION 'CN23' AND SKIP FIRST SCREEN.
            WHEN '30'.
              CALL TRANSACTION 'IW33' AND SKIP FIRST SCREEN.
          ENDCASE.
        ENDIF.

    ENDCASE.

  ENDMETHOD.                    "handle_user_command


ENDCLASS.                    "lcl_event_receiver IMPLEMENTATION

*-------------------------------------------------------------------*
*   Initialisation
*-------------------------------------------------------------------*
INITIALIZATION.

  p_klart = '001' .                            "Material Class type
  SET PARAMETER ID 'KAR' FIELD p_klart.

* Default Basic Start date

  gv_curr_year  = sy-datum+0(4).
  gv_curr_poper = sy-datum+4(2).
  gv_first_day  = sy-datum.
  MOVE '01' TO gv_first_day+6(2).


  CALL FUNCTION 'LAST_DAY_IN_PERIOD_GET'
    EXPORTING
      i_gjahr        = gv_curr_year
*     I_MONMIT       = 00
      i_periv        = 'K4'
      i_poper        = gv_curr_poper
    IMPORTING
      e_date         = gv_last_day
    EXCEPTIONS
      input_false    = 1
      t009_notfound  = 2
      t009b_notfound = 3
      OTHERS         = 4.
  IF sy-subrc <> 0.
  ENDIF.

*  CLEAR s_gstrp.
*  s_gstrp-option = 'BT'.
*  s_gstrp-sign   = 'I'.
*  s_gstrp-low    = gv_first_day.
*  s_gstrp-high   = gv_last_day.
*  APPEND s_gstrp.

*----------------------------------------------------------------------*
* Process on value request
*----------------------------------------------------------------------*
*AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_priokx.
*  PERFORM sub_f4_for_priok
*     CHANGING p_priokx.

* ALV layout
AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_vari.
  PERFORM sub_f4_for_variant
     CHANGING p_vari.


*-------------------------------------------------------------------*
*   Select Screen OUTPUT
*-------------------------------------------------------------------*

*AT SELECTION-SCREEN OUTPUT.
  BREAK-POINT.
  LOOP AT SCREEN.
  ENDLOOP.

*-------------------------------------------------------------------*
*   Select Screen
*-------------------------------------------------------------------*
AT SELECTION-SCREEN ON BLOCK zmmmr400_a.
  PERFORM sub_validate_report_options.

AT SELECTION-SCREEN ON BLOCK zmmmr400_1.
* validate phases
  PERFORM sub_validate_desired_phase.

AT SELECTION-SCREEN ON BLOCK zmmmr400_2.
  PERFORM sub_validate_parameters.

AT SELECTION-SCREEN ON BLOCK zmmmr400_3.
  PERFORM sub_validate_added_parameters.

*-------------------------------------------------------------------*
*   Start of Selection
*-------------------------------------------------------------------*
START-OF-SELECTION.

  CALL SCREEN 100.

*-------------------------------------------------------------------*
*   End of Selection
*-------------------------------------------------------------------*
END-OF-SELECTION.


*&---------------------------------------------------------------------*
*&      Module  STATUS_0100  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE status_0100 OUTPUT.

  SET PF-STATUS 'ZMMTRACK'.
  SET TITLEBAR 'ZMMTRK'.

  IF container IS INITIAL.

    PERFORM sub_get_supplying_plants.
    PERFORM sub_get_status_texts.

    IF NOT p_prjrep IS INITIAL.               "Project Stock Reporting

      PERFORM sub_get_wbs_elements.

    ENDIF.

* Pick up all Work Order reservations
    PERFORM sub_get_work_orders.

* Only need to do the MRP part for PM & PS (PST Proc Type)

    SORT t_main_stat BY matnr rsnum rspos rsart ASCENDING.

    IF NOT p_pmrep  IS INITIAL OR
       NOT p_prjpst IS INITIAL.

      PERFORM sub_get_order_material_details.

    ENDIF.

* Check to see if any of the other PS options have been chosen
    IF NOT p_prjpfv IS INITIAL OR
       NOT p_prjxfr IS INITIAL.

      PERFORM sub_get_direct_procure_details.

    ENDIF.

* Format table of results for final output
    PERFORM sub_build_output.
*
* Create a custom container for the GUI framework control
    CREATE OBJECT container
      EXPORTING
        container_name = 'MAT_TRACK'.

* create an instance of alv control
    CREATE OBJECT grid1
      EXPORTING
        i_parent = container.


*MS


    PERFORM functional_loc_desc.


    PERFORM delivery_date.

    PERFORM  sub_contarct_qty.

*MS

* Build field catlog for the

    PERFORM alv_build_fieldcat TABLES gt_fieldcat.

    LOOP AT gt_fieldcat.
*
      IF gt_fieldcat-fieldname = 'ZSUB'.
*
        gt_fieldcat-coltext   = 'Stock Prvd to Vendor'.
*
        gt_fieldcat-scrtext_l = 'Stock Prvd to Vendor'.

*    GT_fieldcat-SCRTEXT_M = 'SuB'.
*
*    gt_fieldcat-SELTEXT = 'SUB'.
*
*    gt_fieldcat-REPTEXT = 'SUB1'.
*
        gt_fieldcat-ref_field = 'ZLABST1 '.

        gt_fieldcat-ref_table  = ' '.

        MODIFY gt_fieldcat..
*
      ENDIF.
*
    ENDLOOP.

    PERFORM alv_build_sort TABLES gt_sort.

*
* Set a titlebar for the grid control
*
*
    CLEAR: gs_layout-grid_title.

    IF NOT p_pmrep IS INITIAL.           "PM Stock

      gs_layout-grid_title = 'PM Stock Reporting'(024).

    ELSEIF NOT p_prjrep IS INITIAL.

      gs_layout-grid_title = 'Project Stock Reporting'(025).

      IF NOT p_prjpst IS INITIAL.
        CONCATENATE gs_layout-grid_title ' - PST' INTO gs_layout-grid_title.
      ENDIF.

      IF NOT p_prjpfv IS INITIAL.
        CONCATENATE gs_layout-grid_title ' - PFV' INTO gs_layout-grid_title.
      ENDIF.

      IF NOT p_prjxfr IS INITIAL.
        CONCATENATE gs_layout-grid_title ' - XFR' INTO gs_layout-grid_title.
      ENDIF.

    ENDIF.

* Set exception 'light' process
    gs_layout-excp_fname = g_lights_name.

* Set selection mode
    gs_layout-sel_mode   = 'A'.


* Set Program name to enable save of layout variant
    gs_vari-report = sy-repid.

    CALL METHOD grid1->set_table_for_first_display
      EXPORTING
        i_structure_name = 'ZMMTRACKLAYOUT'
        is_layout        = gs_layout
        is_variant       = gs_vari
        i_save           = 'A'
      CHANGING
        it_outtab        = gt_mat_layout_final[]
        it_fieldcatalog  = gt_fieldcat[]
        it_sort          = gt_sort[].

* Create Object to receive events and link them to handler methods.
    CREATE OBJECT event_receiver1.

* Set event handler
    SET HANDLER event_receiver1->handle_double_click FOR grid1.
    SET HANDLER event_receiver1->handle_user_command FOR grid1.
    SET HANDLER event_receiver1->handle_toolbar FOR grid1.

* § 4.Call method 'set_toolbar_interactive' to raise event TOOLBAR.
    CALL METHOD grid1->set_toolbar_interactive.

  ENDIF.


ENDMODULE.                 " STATUS_0100  OUTPUT

*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0100  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_0100 INPUT.

  IF sy-ucomm EQ 'BACK' OR
     sy-ucomm EQ 'EXIT'.

    CALL METHOD container->free.
    SET SCREEN 0. LEAVE SCREEN.

  ENDIF.

ENDMODULE.                 " USER_COMMAND_0100  INPUT
*&---------------------------------------------------------------------*
*&      Form  SUB_VALIDATE_REPORT_OPTIONS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM sub_validate_report_options .

* Ensure at least one option is chosen for PS Report if selected
  IF NOT p_prjrep IS INITIAL.

    IF p_prjpst IS INITIAL AND
       p_prjpfv IS INITIAL AND
       p_prjxfr IS INITIAL.

      MESSAGE e000(zz) WITH TEXT-020.

    ENDIF.

  ENDIF.

ENDFORM.                    " SUB_VALIDATE_REPORT_OPTIONS

*&---------------------------------------------------------------------*
*&      Form  SUB_VALIDATE_DESIRED_PHASE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM sub_validate_desired_phase .

*     no phase was selected
  IF p_out IS INITIAL AND
     p_prc IS INITIAL.
*     text-029: No order status selected
    MESSAGE e000(zz) WITH TEXT-029.
  ENDIF.

*     outstanding orders desired
  IF NOT p_out IS INITIAL.
    r_iphas-sign   = c_i.
    r_iphas-option = c_eq.
    r_iphas-low    = c_0.
    APPEND r_iphas.
  ENDIF.

*     in process orders desired
  IF NOT p_prc IS INITIAL.
    r_iphas-sign   = c_i.
    r_iphas-option = c_eq.
    r_iphas-low    = c_2.
    APPEND r_iphas.
  ENDIF.

ENDFORM.                    " SUB_VALIDATE_DESIRED_PHASE
*&---------------------------------------------------------------------*
*&      Form  SUB_VALIDATE_ADDED_PARAMETERS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM sub_validate_added_parameters .

* Finally Issued items required

  CLEAR: r_kzear.
  IF p_finiss IS INITIAL.
    r_kzear-sign   = c_e.
    r_kzear-option = c_eq.
    r_kzear-low    = c_on.
    APPEND r_kzear.
  ENDIF.

ENDFORM.                    " SUB_VALIDATE_ADDED_PARAMETERS

*&---------------------------------------------------------------------*
*&      Form  SUB_VALIDATE_PARAMETERS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM sub_validate_parameters .

  DATA: ls_artpr       LIKE t356-artpr.

* Verify Project Definition
  IF NOT s_projid IS INITIAL.
    SELECT * FROM proj
             WHERE pspid = s_projid-low.
    ENDSELECT.
    IF sy-subrc <> 0.
      MESSAGE e000(zz) WITH 'Invalid Project Definition'.
    ENDIF.
  ENDIF.

* Verify Network. You can enter a network without any activity
  IF NOT s_naufnr[] IS INITIAL AND s_vornr[] IS INITIAL.
    SELECT * FROM aufk
             WHERE aufnr IN s_naufnr.
    ENDSELECT.
    IF sy-subrc <> 0.
      MESSAGE e000(zz) WITH 'Invalid Network Order'.
    ENDIF.
  ENDIF.

* Verify Material Number
  IF NOT s_matnr[] IS INITIAL.
    SELECT * FROM mara
             WHERE matnr IN s_matnr.
    ENDSELECT.
    IF sy-subrc <> 0.
      MESSAGE e000(zz) WITH 'Invalid Material Number'.
    ENDIF.
  ENDIF.


* Check that the Plant supplied is RLM specific and remote
  IF NOT p_pmrep IS INITIAL OR
     NOT p_prjpst IS INITIAL.

    REFRESH r_werks.
    SELECT * FROM t001w
             WHERE werks IN s_werks.
      CLEAR: r_werks.
      SELECT SINGLE * FROM oio_cm_oplnt
                      WHERE werks EQ t001w-werks
                      AND  ( loccd EQ 0 OR loccd EQ 2 ).
      IF sy-subrc EQ 0.
        r_werks-sign   = c_i.
        r_werks-option = c_eq.
        r_werks-low    = t001w-werks.
        APPEND r_werks.
      ENDIF.

    ENDSELECT.

  ENDIF.


* Check Priority Code
  IF NOT p_priokx IS INITIAL.

    IMPORT ls_artpr FROM MEMORY ID 'ZMM_PRIOR'.

    CLEAR: t356_t, r_priok.
    SELECT * FROM t356_t
             WHERE spras  = sy-langu
             AND   artpr  = ls_artpr
             AND   priokx = p_priokx.

    ENDSELECT.

    IF sy-subrc EQ 0.
      r_priok-sign   = c_i.
      r_priok-option = c_eq.
      r_priok-low    = t356_t-priok.
      APPEND r_priok.
    ENDIF.

  ENDIF.


ENDFORM.                    " SUB_VALIDATE_PARAMETERS

*&---------------------------------------------------------------------*
*&      Form  SUB_GET_SUPPLYING_PLANTS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM sub_get_supplying_plants .

*Begin of Modify for NWDK902274
*  SELECT
*         werks     "plant
*         reswk     "supplying plant
*         loccd     "location code
*   INTO TABLE t_oio_cm_oplnt
*   FROM oio_cm_oplnt
*  WHERE werks IN r_werks.
  SELECT
         werks     "plant
         reswk     "supplying plant
         loccd     "location code
   INTO TABLE t_oio_cm_oplnt
   FROM oio_cm_oplnt
  WHERE werks IN r_werks
  ORDER BY PRIMARY KEY.
*End of Modify for NWDK902274

  IF sy-subrc NE 0.
    MESSAGE e000 WITH
       'Error retrieving supplying plants table.'(028).
  ENDIF.

ENDFORM.                    " SUB_GET_SUPPLYING_PLANTS
*&---------------------------------------------------------------------*
*&      Form  SUB_GET_STATUS_TEXTS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM sub_get_status_texts .

* Get System Status Text

* HANA Corrections - BEGIN OF MODIFY - <HANA-001>
*  SELECT   istat txt04
*     FROM  tj02t
*     INTO  TABLE t_sys_stat_text
*     WHERE spras = sy-langu.
  SELECT   istat txt04
     FROM  tj02t
     INTO  TABLE t_sys_stat_text
     WHERE spras = sy-langu
ORDER BY PRIMARY KEY.
* HANA Corrections - END OF MODIFY - <HANA-001>

* Filter out unwanted status
  IF s_sytsta-sign = 'E'.
    LOOP AT s_sytsta.
      READ TABLE t_sys_stat_text WITH KEY txt04 = s_sytsta-low.
      IF sy-subrc EQ 0.
        DELETE t_sys_stat_text WHERE istat = t_sys_stat_text-istat.
      ENDIF.
    ENDLOOP.
  ELSE.
    LOOP AT t_sys_stat_text.
      IF t_sys_stat_text-txt04 IN s_sytsta.
        CONTINUE.
      ELSE.
        DELETE t_sys_stat_text INDEX sy-tabix.
      ENDIF.
    ENDLOOP.
  ENDIF.

* Get User Status Text
* HANA Corrections - BEGIN OF MODIFY - <HANA-001>
*  SELECT   estat txt04
*     FROM  tj30t
*     INTO  TABLE t_usr_stat_text
*     WHERE spras = sy-langu.
  SELECT   estat txt04
     FROM  tj30t
     INTO  TABLE t_usr_stat_text
     WHERE spras = sy-langu
ORDER BY PRIMARY KEY.
* HANA Corrections - END OF MODIFY - <HANA-001>

* Filter out unwanted status
  IF s_usrsta-sign = 'E'.
    LOOP AT s_usrsta.
      READ TABLE t_usr_stat_text WITH KEY txt04 = s_usrsta-low.
      IF sy-subrc EQ 0.
        DELETE t_usr_stat_text WHERE estat = t_usr_stat_text-estat.
      ENDIF.
    ENDLOOP.
  ELSE.
    LOOP AT t_usr_stat_text.
      IF t_usr_stat_text-txt04 IN s_usrsta.
        CONTINUE.
      ELSE.
        DELETE t_usr_stat_text INDEX sy-tabix.
      ENDIF.
    ENDLOOP.
  ENDIF.


ENDFORM.                    " SUB_GET_STATUS_TEXTS
*&---------------------------------------------------------------------*
*&      Form  SUB_GET_WORK_ORDERS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM sub_get_work_orders .

  DATA: l_sys_flag, l_usr_flag.

  DATA: l_objek LIKE ausp-objek.

  DATA: lt_objdata LIKE clobjdat OCCURS 0,
        lt_class   LIKE sclass   OCCURS 0 WITH HEADER LINE.

  DATA: lv_tabix LIKE sy-tabix.

* Check whether we are dealing with PM or Project Stock reservations

  IF NOT p_pmrep IS INITIAL.                                 "PM Stock

* Select orders from view viaufkst (remote ONLY)
    SELECT resb~rsnum
           resb~rspos
           resb~rsart
           resb~matnr
           resb~werks
           resb~posnr
           resb~sortf
           resb~kzear
           resb~vmeng
           viaufkst~tplnr
           viaufkst~priok
           viaufkst~equnr
           viaufkst~ingpr
           resb~bdmng
           resb~enmng
           resb~bdter
           resb~postp
           viaufkst~aufnr
           resb~vornr
           jest~objnr
           jest~stat
    INTO CORRESPONDING FIELDS OF TABLE t_main
    FROM viaufkst
    JOIN resb
      ON ( viaufkst~rsnum   = resb~rsnum  )
    JOIN jest
      ON ( viaufkst~objnr   = jest~objnr  )
    WHERE viaufkst~aufnr   IN s_aufnr                AND
          viaufkst~auart   IN s_auart                AND
          viaufkst~werks   IN r_werks                AND
          viaufkst~stort   IN s_stort                AND
          viaufkst~gstrp   IN s_gstrp                AND
          viaufkst~tplnr   IN s_tplnr                AND
          viaufkst~revnr   IN s_revnr                AND
          viaufkst~ingpr   IN s_ingpr                AND
*          viaufkst~pspel   IN s_pspel                AND
          viaufkst~iphas   IN r_iphas                AND
          viaufkst~priok   IN r_priok                AND
          resb~sortf       IN s_sortf                AND
          resb~postp       EQ c_l                    AND
          resb~kzear       IN r_kzear                AND
          resb~xloek       EQ space                  AND
          jest~inact       EQ space                  AND
          resb~matnr       IN s_matnr                AND
          resb~matkl       IN s_matkl                AND
          viaufkst~swerk   IN s_swerk                AND
          viaufkst~iwerk   IN s_iwerk                .

* Begin of changes in PhaseII "MKQURESHI MD1K994820
*Fetching orders for rental equipment
    PERFORM rental_order_fetch.
    LOOP AT it_main1 INTO gf_main1 WHERE matnr IS INITIAL.
      APPEND gf_main1 TO t_main.
    ENDLOOP.
*End of changes in PhaseII "MKQURESHI MD1K994820

  ELSEIF NOT p_prjrep IS INITIAL.                       "Project Stock (All)

    IF NOT p_prjpst IS INITIAL.                         "Project Stock (PST)

      SELECT resb~rsnum
             resb~rspos
             resb~rsart
             resb~matnr
             resb~werks
             resb~posnr
             resb~sortf
             resb~aufnr
             resb~bdmng
             resb~enmng
             resb~pspel
             resb~bdter
             resb~postp
             resb~projn
             resb~vornr
             jest~objnr
             jest~stat
             rsadd~mflic

      APPENDING CORRESPONDING FIELDS OF TABLE t_main
      FROM resb
      JOIN rsadd
        ON ( resb~rsnum = rsadd~rsnum                 AND
             resb~rspos = rsadd~rspos                 AND
             resb~rsart = rsadd~rsart )
      JOIN aufk
        ON ( resb~aufnr = aufk~aufnr )
      JOIN jest
        ON ( aufk~objnr = jest~objnr )
      WHERE  resb~bdart  EQ 'AR'                      AND
             resb~xloek  EQ space                     AND
             resb~kzear  EQ space                     AND
             jest~inact  EQ space                     AND
             resb~werks  IN r_werks                   AND
             resb~vornr  IN s_vornr                   AND
             resb~aufnr  IN s_naufnr                  AND
             resb~pspel  IN r_wbs                     AND
             resb~matnr  IN s_matnr                   AND
             resb~postp  EQ c_l                       AND
             rsadd~mflic EQ c_pst                     AND
             resb~sobkz  EQ 'Q'.

    ENDIF.

**
    IF NOT p_prjpfv IS INITIAL.                           "Project Stock (PFV)

      SELECT resb~rsnum
             resb~rspos
             resb~rsart
             resb~matnr
             resb~werks
             resb~posnr
             resb~sortf
             resb~aufnr
             resb~bdmng
             resb~enmng
             resb~pspel
             resb~bdter
             resb~postp
             resb~projn
             resb~vornr
             jest~objnr
             jest~stat
             rsadd~mflic

      APPENDING CORRESPONDING FIELDS OF TABLE t_main
      FROM resb
      JOIN rsadd
        ON ( resb~rsnum = rsadd~rsnum                 AND
             resb~rspos = rsadd~rspos                 AND
             resb~rsart = rsadd~rsart )
      JOIN aufk
        ON ( resb~aufnr = aufk~aufnr )
      JOIN jest
        ON ( aufk~objnr = jest~objnr )
      WHERE  resb~bdart  EQ 'AR'                            AND
             resb~xloek  EQ space                           AND
             resb~kzear  EQ space                           AND
             jest~inact  EQ space                           AND
             resb~werks  IN s_werks                         AND
             resb~vornr  IN s_vornr                         AND
             resb~aufnr  IN s_naufnr                        AND
             resb~pspel  IN r_wbs                           AND
             resb~matnr  IN s_matnr                         AND
             resb~postp  EQ c_l                             AND
             rsadd~mflic EQ c_pfv                           AND
             resb~sobkz  EQ 'Q'.

    ENDIF.
**
    IF NOT p_prjxfr IS INITIAL.                          "Project Stock (XFR)

      SELECT resb~rsnum
             resb~rspos
             resb~rsart
             resb~matnr
             resb~werks
             resb~posnr
             resb~sortf
             resb~aufnr
             resb~bdmng
             resb~enmng
             resb~pspel
             resb~bdter
             resb~postp
             resb~projn
             resb~vornr
             jest~objnr
             jest~stat
             rsadd~mflic

      APPENDING CORRESPONDING FIELDS OF TABLE t_main
      FROM resb
      JOIN rsadd
        ON ( resb~rsnum = rsadd~rsnum                 AND
             resb~rspos = rsadd~rspos                 AND
             resb~rsart = rsadd~rsart )
      JOIN aufk
        ON ( resb~aufnr = aufk~aufnr )
      JOIN jest
        ON ( aufk~objnr = jest~objnr )
      WHERE  resb~bdart  EQ 'AR'                            AND
             resb~xloek  EQ space                           AND
             resb~kzear  EQ space                           AND
             jest~inact  EQ space                           AND
             resb~werks  IN s_werks                         AND
             resb~vornr  IN s_vornr                         AND
             resb~aufnr  IN s_naufnr                        AND
             resb~pspel  IN r_wbs                           AND
             resb~matnr  IN s_matnr                         AND
             resb~postp  EQ c_l                             AND
             rsadd~mflic EQ c_xfr                           AND
             resb~sobkz  EQ 'Q'.

    ENDIF.

  ENDIF.            " End of PS checks


* if no orders, output message
  IF sy-subrc = 0.
*Begin of Modify for NWDK902274
*    DELETE ADJACENT DUPLICATES FROM t_main.
    SORT t_main.
    DELETE ADJACENT DUPLICATES FROM t_main.
*End of Modify for NWDK902274
    LOOP AT t_main.

*      delete records based on the inclusive/exclusive system status
      IF t_main-stat(1) = 'I' AND NOT s_sytsta[] IS INITIAL.
        READ TABLE t_sys_stat_text WITH KEY istat = t_main-stat.
        IF sy-subrc NE 0.
          IF s_sytsta-sign = 'E'.
            DELETE t_main WHERE aufnr = t_main-aufnr.
          ELSE.
            DELETE t_main.
          ENDIF.
          CONTINUE.
        ENDIF.
      ENDIF.

*      delete records based on the inclusive/exclusive user status
      IF t_main-stat(1) = 'E' AND NOT s_usrsta[] IS INITIAL.
        READ TABLE t_usr_stat_text WITH KEY estat = t_main-stat.
        IF sy-subrc NE 0.
          IF s_usrsta-sign = 'E'.
            DELETE t_main WHERE aufnr = t_main-aufnr.
          ELSE.
            DELETE t_main.
          ENDIF.
          CONTINUE.
        ENDIF.
      ENDIF.

*     Modify the Outstanding Quantity from the reservation
      IF t_main-bdmng GT t_main-enmng.
        t_main-outqty = t_main-bdmng - t_main-enmng.
        MODIFY t_main.
*      ELSE.
*        DELETE t_main.
      ENDIF.
    ENDLOOP.
  ELSE.

    IF t_main[] IS INITIAL.
      MESSAGE w000 WITH 'No orders selected for given criteria.'(022).
    ENDIF.

  ENDIF.

* If both status used, make sure both status exist
  LOOP AT t_main.
    IF NOT s_sytsta[] IS INITIAL AND NOT s_usrsta[] IS INITIAL.
      CLEAR: l_sys_flag, l_usr_flag.
      LOOP AT t_main WHERE aufnr = t_main-aufnr.
        READ TABLE t_sys_stat_text WITH KEY istat = t_main-stat.
        IF sy-subrc EQ 0.
          l_sys_flag = c_on.
        ENDIF.
        READ TABLE t_usr_stat_text WITH KEY estat = t_main-stat.
        IF sy-subrc EQ 0.
          l_usr_flag = c_on.
        ENDIF.
      ENDLOOP.

      IF l_sys_flag = c_off OR l_usr_flag = c_off.
        DELETE t_main WHERE aufnr = t_main-aufnr.
      ENDIF.
*  If only one status used, delete other status entries
    ELSEIF NOT s_sytsta[] IS INITIAL AND s_usrsta[] IS INITIAL.
      DELETE t_main WHERE aufnr = t_main-aufnr AND stat(1) = 'E'.
    ELSEIF s_sytsta[] IS INITIAL AND NOT s_usrsta[] IS INITIAL.
      DELETE t_main WHERE aufnr = t_main-aufnr AND stat(1) = 'I'.
    ENDIF.
  ENDLOOP.

* Print error if no work orders
  IF t_main[] IS INITIAL.
    MESSAGE w000 WITH 'No orders selected for given criteria.'(022).
  ENDIF.

* Remove status from table for ongoing processing
  LOOP AT t_main.

    CLEAR: t_main_stat.
    MOVE-CORRESPONDING t_main TO t_main_stat.
    APPEND t_main_stat.

  ENDLOOP.

  SORT t_main_stat BY rsnum rspos matnr.
  DELETE ADJACENT DUPLICATES FROM t_main_stat COMPARING ALL FIELDS.


* Now Find Classes for Material
  LOOP AT t_main_stat.

* Check if Material has already been processed.
    READ TABLE t_main_mat_class WITH KEY matnr = t_main_stat-matnr.
    IF sy-subrc EQ 0.

      CONTINUE.

    ELSE.

      l_objek = t_main_stat-matnr.

      CALL FUNCTION 'CLAF_CLASSIFICATION_OF_OBJECTS'
        EXPORTING
*         CLASS              = p_class
          classtype          = p_klart            "Material Class (default '001')
          language           = sy-langu
          object             = l_objek
        TABLES
          t_class            = lt_class
          t_objectdata       = lt_objdata
        EXCEPTIONS
          no_classification  = 1
          no_classtypes      = 2
          invalid_class_type = 3
          OTHERS             = 4.
      IF sy-subrc = 0.

* If Material Class option has been selected then filter out materials
* for the specified class'
        IF NOT p_class IS INITIAL.

          LOOP AT lt_class
               WHERE class = p_class.
          ENDLOOP.

          IF sy-subrc NE 0.

            DELETE t_main_stat WHERE matnr = t_main_stat-matnr.

          ENDIF.

        ENDIF.

      ENDIF.

      LOOP AT lt_class
           WHERE class <> 'MISCELLANEOUS'.

        CLEAR: t_main_mat_class.

        t_main_mat_class-matnr = t_main_stat-matnr.
        t_main_mat_class-class = lt_class-class.
        APPEND t_main_mat_class.

      ENDLOOP.

    ENDIF. "Material already processed

  ENDLOOP.



ENDFORM.                    " SUB_GET_WORK_ORDERS
*&---------------------------------------------------------------------*
*&      Form  SUB_GET_ORDER_MATERIAL_DETAILS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM sub_get_order_material_details .

*   Get quantity from zmm_commit & check final issue settings
  PERFORM sub_get_hard_reservation.

*   Get Stock Requirements for Material
  PERFORM sub_get_stock_requirement.


ENDFORM.                    " SUB_GET_ORDER_MATERIAL_DETAILS
*&---------------------------------------------------------------------*
*&      Form  SUB_GET_HARD_RESERVATION
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM sub_get_hard_reservation .

  DATA: lv_comm_qty LIKE zmm_commit-zcoms.


* HANA Corrections - BEGIN OF MODIFY - <HANA-001>
  IF NOT t_main_stat[] IS INITIAL.
* HANA Corrections - END OF MODIFY - <HANA-001>
    SELECT rsnum
               rspos
               rsart
               matnr
               werks
               zcoms
               zcomo
        FROM zmm_commit
        INTO TABLE t_zmm_commit
        FOR ALL ENTRIES IN t_main_stat
        WHERE rsnum = t_main_stat-rsnum
          AND rspos = t_main_stat-rspos
          AND rsart = t_main_stat-rsart
          AND matnr = t_main_stat-matnr
          AND werks = t_main_stat-werks
          AND zdel  = ' '.
* HANA Corrections - BEGIN OF MODIFY - <HANA-001>
  ENDIF.
* HANA Corrections - END OF MODIFY - <HANA-001>

  IF sy-subrc EQ 0.

    SORT t_zmm_commit BY rsnum rspos rsart.

    LOOP AT t_main_stat
       WHERE mflic EQ ' ' OR
             mflic EQ 'PST'.

      g_saved_tabix = sy-tabix.

      CLEAR: t_zmm_commit.
      READ TABLE t_zmm_commit WITH KEY rsnum = t_main_stat-rsnum
                                       rspos = t_main_stat-rspos
                                       rsart = t_main_stat-rsart
                                       BINARY SEARCH.

      IF sy-subrc = 0.

* Check if final issue flag has been set and ignore committed qty.
* Otherwise, if not, then to ensure committed qty is adjusted correctly (committed qty is
* NOT updated in real time, only on NEXT picklist run) we need to take the requirement qty
* and subtract the withdrawal qty on reservation. This result
* should then be checked against the CURRENT stock committment qty. The lesser of
* these 2 values should be the value provided in the committed qty column!

* Note:
* The ZMM_COMMIT record is flagged for deletion upon next picklist run.
*
        IF t_main_stat-kzear IS INITIAL.

*          lv_comm_qty = t_zmm_commit-zcomo - t_main_stat-enmng.

          lv_comm_qty = t_main_stat-bdmng - t_main_stat-enmng.


          IF lv_comm_qty LE t_zmm_commit-zcoms.

            t_main_stat-zcoms = lv_comm_qty.

          ELSE.

            t_main_stat-zcoms = t_zmm_commit-zcoms.

          ENDIF.

        ENDIF.

        MODIFY: t_main_stat INDEX g_saved_tabix.

      ENDIF.

    ENDLOOP.

  ENDIF.

ENDFORM.                    " SUB_GET_HARD_RESERVATION
*&---------------------------------------------------------------------*
*&      Form  SUB_GET_STOCK_REQUIREMENT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM sub_get_stock_requirement .

  DATA: lv_date_week TYPE d,
        lv_gjahr     LIKE mseg-gjahr.

  DATA: lv_menge  TYPE mseg-menge,
        lv_labst  TYPE mard-labst,
        lv_prlab  TYPE mspr-prlab,
        lv_prspe  TYPE mspr-prspe,
        lv_sqtra  TYPE mssq-sqtra,
        lv_lfimg  TYPE lips-lfimg,
        lv_matref TYPE ekbe-xblnr.

  DATA: lv_wbs_group    LIKE grpga-grpnr,
        lv_wbs_external LIKE prps-posid.


  DATA: lv_stat_flag TYPE c.

  DATA: ls_gtmat     LIKE gt_mat_layout.

  DATA: lv_tabix     LIKE sy-tabix.

  DATA: lt_mat_layout_temp LIKE gt_mat_layout OCCURS 0 WITH HEADER LINE.

  RANGES: lr_olocs    FOR viaufkst-werks.


* Find Stock Availability for all materials found and start initial build of report layout
  LOOP AT t_main_stat
       WHERE mflic EQ ' ' OR
             mflic EQ 'PST'.

    CLEAR: gt_mat_layout, lv_wbs_group, v_datum.

    PERFORM sub_initialise.

    CLEAR: t_oio_cm_oplnt.
    READ TABLE t_oio_cm_oplnt WITH KEY werks = t_main_stat-werks
                                   BINARY SEARCH.

*
* Get Requirements List for Offshore plant for material

* If dealing with PS stock get Group WBS element where applicable
    IF NOT p_prjpst IS INITIAL.           "PS Stock

      CALL FUNCTION 'GRPG_FIND_GRPNR_WITH_MATNR'
        EXPORTING
          i_pspnr              = t_main_stat-pspel
          i_werks              = t_main_stat-werks
          i_matnr              = t_main_stat-matnr
        IMPORTING
          e_grpnr              = lv_wbs_group
        EXCEPTIONS
          wrong_input          = 1
          no_valid_grpnr_found = 2
          OTHERS               = 3.

* Prepare internal WBS for external formatting

      CALL FUNCTION 'CONVERSION_EXIT_ABPSP_OUTPUT'
        EXPORTING
          input  = lv_wbs_group
        IMPORTING
          output = lv_wbs_external.

    ENDIF.

* Ensure we havent already picked up this reservation
    READ TABLE t_stk WITH KEY matnr = t_main_stat-matnr
                              werks = t_main_stat-werks
                              pspel = lv_wbs_group.
    IF sy-subrc <> 0.

      PERFORM get_mrp_list TABLES t_stk t_po t_pr t_wo
                           USING  t_main_stat-werks
                                  t_main_stat-matnr
                                  t_main_stat-aufnr
                                  lv_wbs_group
                                  t_main_stat-enmng
                                  t_main_stat-zcoms
                                  'R'.

    ENDIF.
*
* Get Requirements List for Base plant for material

* Ensure we havent already picked up this reservation
    READ TABLE t_b_stk WITH KEY matnr = t_main_stat-matnr
                                werks = t_oio_cm_oplnt-reswk
                                pspel = lv_wbs_group.
    IF sy-subrc <> 0.

      PERFORM get_mrp_list TABLES t_b_stk t_b_po t_b_pr t_wo2
                           USING  t_oio_cm_oplnt-reswk
                                  t_main_stat-matnr
                                  t_main_stat-aufnr
                                  lv_wbs_group
                                  t_main_stat-enmng
                                  t_main_stat-zcoms
                                  'B'.

    ENDIF.

* Start initial build of entries for output

    gt_mat_layout-matnr     = t_main_stat-matnr.
    gt_mat_layout-werks     = t_main_stat-werks.
    gt_mat_layout-aufnr     = t_main_stat-aufnr.
    gt_mat_layout-vornr     = t_main_stat-vornr.
    gt_mat_layout-posnr     = t_main_stat-posnr.
    gt_mat_layout-sortf     = t_main_stat-sortf.
    gt_mat_layout-ingpr     = t_main_stat-ingpr.
    gt_mat_layout-posid     = lv_wbs_external.
    gt_mat_layout-zreqdate  = t_main_stat-bdter.
    gt_mat_layout-ztotreq   = t_main_stat-bdmng.                             "Reservation
    gt_mat_layout-zjobiss   = t_main_stat-enmng.                             "Already Issued
    gt_mat_layout-zoutqty   = gt_mat_layout-ztotreq - gt_mat_layout-zjobiss. "Outstanding Qty
*MS

*    IF p_hrdres IS INITIAL.
*      gt_mat_layout-zpickrdy  = t_main_stat-vmeng.                      "Standard commitment facility
*    ELSE.
*      gt_mat_layout-zpickrdy  = t_main_stat-zcoms.                      "Bespoke 'Hard Reservation' committment (Picked & Ready)
*    ENDIF.

*MS

* AUCT-UPGRADE -  Begin of Modification by <USER> on <17.02.2017> for <EHP8>
*    select SINGLE hard_resn from zpm_plant_params INTO V_DATUM where SWERK = t_main_stat-werks. "(resb-werks)
    SELECT hard_resn FROM zpm_plant_params INTO v_datum WHERE swerk = t_main_stat-werks "(resb-werks)
    ORDER BY PRIMARY KEY.
      EXIT.
    ENDSELECT.
* AUCT-UPGRADE -  End of Modification by <USER> on <17.02.2017> for <EHP8>
*
    IF sy-subrc = 0 AND v_datum <> space AND v_datum IS NOT INITIAL.
*
      IF sy-datum GE v_datum.
*
        gt_mat_layout-zpickrdy  = t_main_stat-zcoms.
*
      ELSE.

        gt_mat_layout-zpickrdy  = t_main_stat-vmeng.


      ENDIF.
*
    ELSE.

      gt_mat_layout-zpickrdy  = t_main_stat-vmeng."t_main_stat-zcoms.

    ENDIF.


    APPEND gt_mat_layout.

  ENDLOOP.

*MS
* Potential to have the same item on the same work order/reservation. Consolidate any of this potential if at all.
  LOOP AT gt_mat_layout.
    lt_mat_layout_temp = gt_mat_layout.
    COLLECT lt_mat_layout_temp.
  ENDLOOP.

  CLEAR:   gt_mat_layout.
  REFRESH: gt_mat_layout.
  gt_mat_layout[] = lt_mat_layout_temp[].


*****************************************************************************************************
* Now loop thru initial layout details and supply additional material details from Offshore & Onshore
* ie Stock Onshore, Stock Offshore

  lv_date_week = sy-datum - 7.
  lv_gjahr     = sy-datum+0(4).

  LOOP AT gt_mat_layout.

    CLEAR: lr_olocs.
    REFRESH lr_olocs.


* Pick up Offshore material record
    READ TABLE t_stk WITH KEY matnr = gt_mat_layout-matnr.

* Pick up Onshore material record
    READ TABLE t_b_stk WITH KEY matnr = gt_mat_layout-matnr.

* Find any issues within that last week for Offshore (Consumption) Material - (PM or PS)

    CLEAR: lv_menge.

    IF NOT p_prjpst IS INITIAL.           "PS Stock

      SELECT SUM( mseg~menge )
      INTO lv_menge
      FROM mseg
      JOIN mkpf
        ON ( mseg~mblnr = mkpf~mblnr )
      WHERE mkpf~mjahr EQ lv_gjahr       AND
            mseg~matnr EQ t_stk-matnr    AND
            mseg~werks EQ t_stk-werks    AND
            mseg~bwart EQ '281'          AND        "GI to Network Order
            mkpf~bldat GE lv_date_week.             "Within last week

    ELSE.

      SELECT SUM( mseg~menge )
      INTO lv_menge
      FROM mseg
      JOIN mkpf
        ON ( mseg~mblnr = mkpf~mblnr )
      WHERE mkpf~mjahr EQ lv_gjahr       AND
            mseg~matnr EQ t_stk-matnr    AND
            mseg~werks EQ t_stk-werks    AND
            mseg~bwart EQ '261'          AND        "GI to Order
            mkpf~bldat GE lv_date_week.             "Within last week

    ENDIF.

    IF sy-subrc EQ 0.

      gt_mat_layout-zissweek     = lv_menge.                       "Issued within Last Week

    ENDIF.

*
*
    lr_olocs[] = s_pltoth[].

    lr_olocs-sign   = 'E'.
    lr_olocs-option = 'EQ'.
    lr_olocs-low    = t_stk-werks.
    APPEND lr_olocs.

    CLEAR: lr_olocs.
    lr_olocs-sign   = 'E'.
    lr_olocs-option = 'EQ'.
    lr_olocs-low    = t_b_stk-werks.
    APPEND lr_olocs.

*
*
    IF NOT p_prjpst IS INITIAL.           "PS Stock

*
* Get PS Stock from Other Specified Locations (excl. Onshore/Offshore settings for item just found)

      SELECT SUM( prlab )
      INTO lv_prlab
      FROM mspr
      WHERE matnr EQ t_stk-matnr AND
            werks IN lr_olocs.

      IF sy-subrc EQ 0.

        gt_mat_layout-zstkother = lv_prlab.

      ENDIF.
*
* Get unrestricted PS Stock (Offshore)

      CLEAR: lv_prlab, lv_prspe.

      SELECT * FROM mspr
               WHERE matnr EQ t_stk-matnr AND
                     werks EQ t_stk-werks.

        ADD mspr-prlab TO lv_prlab.

      ENDSELECT.

      IF sy-subrc EQ 0.

        gt_mat_layout-zstkoff = lv_prlab + t_stk-unrqty.             "Total of Plant + Project stock (Offshore)

      ENDIF.

*
* Get unrestricted PS Stock (Onshore)

      CLEAR: lv_prlab.

      SELECT * FROM mspr
               WHERE matnr EQ t_b_stk-matnr AND
                     werks EQ t_b_stk-werks.

        ADD mspr-prlab TO lv_prlab.
        ADD mspr-prspe TO lv_prspe.

      ENDSELECT.

      IF sy-subrc EQ 0.

        gt_mat_layout-zstkon    = lv_prlab + t_b_stk-unrqty.         "Total of Plant + Project Stock (Onshore)
        gt_mat_layout-zquartine = lv_prspe + t_b_stk-blkqty.         "Total of Plant + Project Blocked Stock Qty (Base ONLY)

      ENDIF.

*
* Get In-Transit Project Stock

      SELECT * FROM mssq
               WHERE matnr EQ t_stk-matnr AND
                     werks EQ t_stk-werks.

        ADD mssq-sqtra TO lv_sqtra.

      ENDSELECT.

      IF sy-subrc EQ 0.

        gt_mat_layout-zintrans  = lv_sqtra.                           "Project Stock (In-Transit)

      ENDIF.


    ELSE.

* Into PM related stock quantities....

      SELECT SUM( labst )
      INTO lv_labst
      FROM mard
      WHERE matnr EQ t_stk-matnr AND
            werks IN lr_olocs.

      IF sy-subrc EQ 0.

        gt_mat_layout-zstkother = lv_labst.                          "Stock from Other Specified Locations

      ENDIF.

* Unrestricted Stock Offshore
      gt_mat_layout-zstkoff   = t_stk-unrqty.                        "Unrestricted Stock (Offshore)

* Unrestricted Stock Onshore
      gt_mat_layout-zstkon    = t_b_stk-unrqty.                      "Unrestricted Stock (Onshore)

*Begin of Modify for NWDK902274
*      SELECT SINGLE * FROM mard
*                      WHERE matnr = t_b_stk-matnr
*                      AND   werks = t_b_stk-werks.
      SELECT * UP TO 1 ROWS FROM mard
      WHERE matnr = t_b_stk-matnr
      AND werks = t_b_stk-werks
      ORDER BY PRIMARY KEY.
      ENDSELECT.
*End of Modify for NWDK902274

      gt_mat_layout-zquartine = t_b_stk-blkqty.                      "Blocked/Quarantined Stock Qty (Base ONLY)

* Transfers back onshore

      SELECT SINGLE * FROM marc
                      WHERE matnr = t_b_stk-matnr
                      AND   werks = t_b_stk-werks.

      gt_mat_layout-ztranson = marc-umlmc.                           "Transfers to Onshore

    ENDIF.

* Try to establish a 'status' on where the material is at ie is the
* Calculate Best 'Guesstimate' Date of Material On-Site....
* This is best calculated as follows:
*
* Stock Requisitioned?  - Expected Date of Delivery: Undetermined
* Stock Not Received?   - Expected Date of Delivery: PO Delivery Date + GR Proc Time
* Stock OnShore?        - Expected Date of Delivery: = 7 days
* Stock In-Transit?     - Expected Date of Delivery: < 7 days

* Try a 'hierarchy' approach to determining 'Best Guess' date by
* remembering that the MRP details from BAPI are a current 'state of affairs' of a material item

* So first check:

* Any PO's against the material item - if found determine date and details from this & stop
* Any STO's against the material item - if found determine date and details from this & stop
* Any Reqs against the material item - no date


    CLEAR: lv_stat_flag, gt_mat_layout_final.
    MOVE-CORRESPONDING gt_mat_layout TO gt_mat_layout_final.

*
* PO's Offshore (reference to those at Onshore location)
    LOOP AT t_po
         WHERE matnr EQ gt_mat_layout-matnr
         AND   type  EQ 'PO'.

      CLEAR: gt_mat_layout_final-zpurdoc, gt_mat_layout_final-zpurqty, gt_mat_layout_final-zonsite,
             gt_mat_layout_final-ekgrp.

      lv_stat_flag = 'X'.

      gt_mat_layout_final-zpurdoc = t_po-ebeln.
      gt_mat_layout_final-ekgrp   = t_po-ekgrp.

* ..... Calculate 'On Site' date
*Begin of Modify for NWDK902274
*      SELECT * UP TO 1 ROWS
*               FROM eket
*               WHERE ebeln = t_po-ebeln
*               AND   ebelp = t_po-ebelp.
      SELECT * UP TO 1 ROWS
               FROM eket
               WHERE ebeln = t_po-ebeln
               AND   ebelp = t_po-ebelp
ORDER BY PRIMARY KEY.
*End of Modify for NWDK902274
      ENDSELECT.

*      gt_mat_layout_final-zonsite =  eket-eindt + t_po-webaz.
      gt_mat_layout_final-zonsite =  eket-eindt + t_po-webaz + p_ship.
*ms
      gt_mat_layout_final-eindt  =  eket-eindt.

*ms

* ..... Calculate quantity still on order from PO History if available
      SELECT SINGLE * FROM ekpo
                      WHERE ebeln = t_po-ebeln
                      AND   ebelp = t_po-ebelp.

      IF sy-subrc EQ 0.

        gt_mat_layout_final-zpurqty =  ekpo-menge.

        SELECT * FROM ekbe
                 WHERE ebeln = t_po-ebeln
                 AND   ebelp = t_po-ebelp.

          CASE ekbe-shkzg.
            WHEN 'S'.
              SUBTRACT ekbe-menge FROM gt_mat_layout_final-zpurqty.
            WHEN 'H'.
              ADD ekbe-menge        TO gt_mat_layout_final-zpurqty.
          ENDCASE.

        ENDSELECT.

      ENDIF.

      gt_mat_layout_final-zpurqty =  t_po-menge.

      APPEND gt_mat_layout_final.

    ENDLOOP.

* PO's Onshore

    LOOP AT t_b_po
         WHERE matnr EQ gt_mat_layout-matnr
         AND   type  EQ 'PO'.

      READ TABLE gt_mat_layout_final WITH KEY matnr   = t_b_po-matnr
                                              werks   = t_b_po-werks
                                              aufnr   = t_b_po-aufnr
                                              zpurdoc = t_b_po-ebeln.

      IF sy-subrc NE 0.

        CLEAR: gt_mat_layout_final-zpurdoc, gt_mat_layout_final-zpurqty, gt_mat_layout_final-zonsite,
               gt_mat_layout_final-ekgrp.

        lv_stat_flag = 'X'.

        gt_mat_layout_final-zpurdoc = t_b_po-ebeln.
        gt_mat_layout_final-ekgrp   = t_b_po-ekgrp.

* ..... Calculate 'On Site' date
*Begin of Modify for NWDK902274
*        SELECT * UP TO 1 ROWS
*                 FROM eket
*                 WHERE ebeln = t_b_po-ebeln
*                 AND   ebelp = t_b_po-ebelp.
        SELECT * UP TO 1 ROWS
                 FROM eket
                 WHERE ebeln = t_b_po-ebeln
                 AND   ebelp = t_b_po-ebelp
ORDER BY PRIMARY KEY.
*End of Modify for NWDK902274
        ENDSELECT.

*        gt_mat_layout_final-zonsite =  eket-eindt + t_b_po-webaz.
        gt_mat_layout_final-zonsite =  eket-eindt + t_b_po-webaz + p_ship.
*ms
        gt_mat_layout_final-eindt  =  eket-eindt.

*ms

* ..... Calculate quantity still on order from PO History if available
        SELECT SINGLE * FROM ekpo
                        WHERE ebeln = t_b_po-ebeln
                        AND   ebelp = t_b_po-ebelp.

        IF sy-subrc EQ 0.

          gt_mat_layout_final-zpurqty =  ekpo-menge.

          SELECT * FROM ekbe
                   WHERE ebeln = t_b_po-ebeln
                   AND   ebelp = t_b_po-ebelp.

            CASE ekbe-shkzg.
              WHEN 'S'.
                SUBTRACT ekbe-menge FROM gt_mat_layout_final-zpurqty.
              WHEN 'H'.
                ADD ekbe-menge        TO gt_mat_layout_final-zpurqty.
            ENDCASE.

          ENDSELECT.

        ENDIF.

        APPEND gt_mat_layout_final.

      ENDIF.

    ENDLOOP.


* Pur Req's

* Check to see whether PO's have already been added for the material. If so this is the
* highest succession document to report on so no further requirement to add Preqs or RFQ's
* If not then check for PReqs or any RFQ's for the material. If any RFQ's then add this as
* the next highest purchase document. If no RFQ then add the PReq as the lowest starting
* purchase document

*    if not lv_stat_flag is initial.

    LOOP AT t_pr
         WHERE matnr EQ gt_mat_layout-matnr.

* Does PReq have a PO attached. If so ignore this record and move onto others
*Begin of Modify for NWDK902274
*      SELECT SINGLE * FROM eban
*                      WHERE banfn = t_pr-banfn.
      SELECT * UP TO 1 ROWS FROM eban
      WHERE banfn = t_pr-banfn
      ORDER BY PRIMARY KEY.
      ENDSELECT.
*End of Modify for NWDK902274
      IF sy-subrc EQ 0.

        READ TABLE gt_mat_layout_final WITH KEY matnr   = t_pr-matnr
                                                werks   = gt_mat_layout-werks
                                                aufnr   = gt_mat_layout-aufnr
                                                zpurdoc = eban-ebeln.

        IF sy-subrc EQ 0.
          CONTINUE.
        ENDIF.

      ENDIF.

* Check to see if PReq already added.....
      READ TABLE gt_mat_layout_final WITH KEY matnr   = t_pr-matnr
                                              werks   = gt_mat_layout-werks
                                              aufnr   = gt_mat_layout-aufnr
                                              zpurdoc = t_pr-banfn.

      IF sy-subrc NE 0.

        CLEAR: gt_mat_layout_final-zpurdoc, gt_mat_layout_final-zpurqty, gt_mat_layout_final-zonsite,
               gt_mat_layout_final-ekgrp.

        lv_stat_flag = 'X'.

        IF NOT t_pr-rfqdoch IS INITIAL.

          gt_mat_layout_final-zpurdoc = t_pr-rfqdoch.
          gt_mat_layout_final-zpurqty = t_pr-menge1.

        ELSEIF NOT t_pr-banfn IS INITIAL.

          gt_mat_layout_final-zpurdoc = t_pr-banfn.
          gt_mat_layout_final-zpurqty = t_pr-menge.

*ms
          gt_mat_layout_final-eindt = t_pr-eindt.

* ms


        ENDIF.

        gt_mat_layout_final-ekgrp = t_pr-ekgrp.

        APPEND gt_mat_layout_final.

      ENDIF.

    ENDLOOP.

*

    LOOP AT t_b_pr
         WHERE matnr EQ gt_mat_layout-matnr.

* Does PReq have a PO attached. If so ignore this record and move onto others
*Begin of Modify for NWDK902274
*      SELECT SINGLE * FROM eban
*                      WHERE banfn = t_b_pr-banfn.
      SELECT * UP TO 1 ROWS FROM eban
      WHERE banfn = t_b_pr-banfn
      ORDER BY PRIMARY KEY.
      ENDSELECT.
*End of Modify for NWDK902274
      IF sy-subrc EQ 0.

        READ TABLE gt_mat_layout_final WITH KEY matnr   = t_b_pr-matnr
                                                werks   = gt_mat_layout-werks
                                                aufnr   = gt_mat_layout-aufnr
                                                zpurdoc = eban-ebeln.

        IF sy-subrc EQ 0.
          CONTINUE.
        ENDIF.

      ENDIF.

* Check to see if PReq already added.....
      READ TABLE gt_mat_layout_final WITH KEY matnr   = t_b_pr-matnr
                                              werks   = gt_mat_layout-werks
                                              aufnr   = gt_mat_layout-aufnr
                                              zpurdoc = t_b_pr-banfn.

      IF sy-subrc NE 0.

        CLEAR: gt_mat_layout_final-zpurdoc, gt_mat_layout_final-zpurqty, gt_mat_layout_final-zonsite,
               gt_mat_layout_final-ekgrp.

        lv_stat_flag = 'X'.

        IF NOT t_b_pr-rfqdoch IS INITIAL.

          gt_mat_layout_final-zpurdoc = t_b_pr-rfqdoch.
          gt_mat_layout_final-zpurqty = t_b_pr-menge1.

        ELSEIF NOT t_b_pr-banfn IS INITIAL.

          gt_mat_layout_final-zpurdoc = t_b_pr-banfn.
          gt_mat_layout_final-zpurqty = t_b_pr-menge.
*ms
          gt_mat_layout_final-eindt = t_b_pr-eindt.
*ms
        ENDIF.

        gt_mat_layout_final-ekgrp = t_b_pr-ekgrp.

        APPEND gt_mat_layout_final.

      ENDIF.

    ENDLOOP.

*    endif.      " On check for Pur Req's...

* If no PO's or Req's then just add the record
    IF lv_stat_flag IS INITIAL.

      IF sy-subrc NE 0.                            "No materials already in table
        "then just add the record.
        APPEND gt_mat_layout_final.

      ENDIF.

    ENDIF.

* The following check is for adjusting material lines with 'in transit' details
* where appropriate.
* STO's (Only for determining the possibility of 'in-transit' materials
* and if 'in-transit', the date of availability)

    LOOP AT t_po
         WHERE matnr EQ gt_mat_layout-matnr
         AND   type  EQ 'STO'.

      CLEAR: lv_lfimg.

* ....Find PO History for STO for Movement Type '641' for Material - Transfer to Stk In Transit
      SELECT * FROM ekbe
               WHERE ebeln = t_po-ebeln
               AND   matnr = t_po-matnr
               AND   bwart = '641'.

        lv_matref = ekbe-xblnr.

* .....Find document flow of Delivery Note just found and determine In Transit quantities

        SELECT * FROM vbfa
                 WHERE vbelv EQ lv_matref
                 AND   matnr EQ t_po-matnr
                 AND   bwart NE ' '.

* ..... Adjust totals for the Delivery Note based on document flow of transactions
          CASE vbfa-vbtyp_n.
            WHEN 'R'.                            "Goods Movement
              ADD      vbfa-rfmng TO   lv_lfimg.
            WHEN 'i'.                            "Goods Receipt
              SUBTRACT vbfa-rfmng FROM lv_lfimg.
            WHEN OTHERS.
          ENDCASE.

        ENDSELECT.

      ENDSELECT.

      ADD lv_lfimg TO gt_mat_layout_final-zintrans.              "Stock In Transit

*     gt_mat_layout_final-zintrans  = lv_lfimg.     "Stock In Transit
*     gt_mat_layout_final-zonsite   =  t_po-avail.

    ENDLOOP.

* .... Apply 'in-transit' changes to materials
    LOOP AT gt_mat_layout_final INTO ls_gtmat
         WHERE matnr EQ gt_mat_layout-matnr.

      lv_tabix          = sy-tabix.

      ls_gtmat-zintrans = gt_mat_layout_final-zintrans.
*     ls_gtmat-zonsite  = gt_mat_layout_final-zonsite.

      MODIFY gt_mat_layout_final FROM ls_gtmat INDEX lv_tabix.

    ENDLOOP.

  ENDLOOP.

*Begin of changes in PhaseII "MKQURESHI MD1K994820
* Only for PM reporting fetching the rental equipment details
  IF p_pmrep = 'X'.
    PERFORM rental_detail.
  ENDIF.
*End of changes in PhaseII "MKQURESHI MD1K994820
ENDFORM.                    " SUB_GET_STOCK_REQUIREMENT
*&---------------------------------------------------------------------*
*&      Form  GET_MRP_LIST
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->PT_STK  text
*      -->PT_PO  text
*      -->PT_PR  text
*      -->PT_WO  text
*----------------------------------------------------------------------*
FORM get_mrp_list  TABLES   pt_stk STRUCTURE t_stk
                            pt_po STRUCTURE t_po
                            pt_pr STRUCTURE t_pr
                            pt_wo STRUCTURE t_wo
                   USING    pt_werks
                            pt_matnr
                            pt_aufnr
                            pt_pspel
                            pt_enmng
                            pt_zcoms
                            pt_onoff.

  DATA: mrp_list         TYPE  bapi_mrp_list,
        mrp_stock_detail TYPE  bapi_mrp_stock_detail,
        return           TYPE  bapiret2,
        mrp_items        TYPE TABLE OF bapi_mrp_items WITH HEADER LINE,
        mrp_items_temp   TYPE TABLE OF bapi_mrp_items WITH HEADER LINE,
        mrp_ind_lines    TYPE TABLE OF bapi_mrp_ind_lines WITH HEADER LINE,
        mrp_total_lines  TYPE TABLE OF bapi_mrp_total_lines WITH HEADER LINE.

  DATA: lv_wbs_group      LIKE grpga-grpnr,
        lv_plan_seg_n(12) TYPE n,
        lv_plan_seg       TYPE planr.

* Get 'everything' for the material whether PM or PS related
  CALL FUNCTION 'BAPI_MATERIAL_STOCK_REQ_LIST'
    EXPORTING
      material         = pt_matnr
      plant            = pt_werks
      get_item_details = 'X'
      get_ind_lines    = 'X'
      get_total_lines  = 'X'
    IMPORTING
      mrp_list         = mrp_list
      mrp_stock_detail = mrp_stock_detail
      return           = return
    TABLES
      mrp_items        = mrp_items
      mrp_ind_lines    = mrp_ind_lines
      mrp_total_lines  = mrp_total_lines.

  IF sy-subrc NE 0.
    EXIT.
  ENDIF.

*
* Filter through the MRP list to determine whether PM or PS items apply
  IF p_prjpst IS INITIAL.           "PM Stock

    DELETE mrp_items WHERE NOT plngsegno IS INITIAL.

  ELSE.

* Get Group WBS element where applicable
*    CALL FUNCTION 'GRPG_FIND_GRPNR_WITH_MATNR'
*       EXPORTING
*          I_PSPNR              =  pt_pspel
*          I_WERKS              =  pt_werks
*          I_MATNR              =  pt_matnr
*       IMPORTING
*          E_GRPNR              =  lv_wbs_group
*       EXCEPTIONS
*          WRONG_INPUT          =  1
*          NO_VALID_GRPNR_FOUND =  2
*          OTHERS               =  3.

    CONCATENATE pt_pspel lv_plan_seg_n INTO lv_plan_seg.

* Demand for PS material driven at the Group level so access MRP list by this WBS to filter
* out items which don't apply.
    REFRESH: mrp_items_temp.

    LOOP AT mrp_items
         WHERE plngsegno EQ lv_plan_seg.

      CLEAR: mrp_items_temp.
      MOVE-CORRESPONDING mrp_items TO mrp_items_temp.
      APPEND mrp_items_temp.

    ENDLOOP.

    REFRESH mrp_items.
    mrp_items[] = mrp_items_temp[].

  ENDIF.


*
* MRP_ITEMS ordered by required date

  pt_stk-matnr  = pt_matnr.
  pt_stk-werks  = pt_werks.
  pt_stk-pspel  = pt_pspel.
  pt_stk-unrqty = mrp_stock_detail-unrestricted_stck.
  pt_stk-reqqty = mrp_stock_detail-reservations.
  pt_stk-outqty = mrp_stock_detail-reservations - pt_enmng.
  pt_stk-alriss = pt_enmng.
  pt_stk-comqty = pt_zcoms.
  pt_stk-blkqty = mrp_stock_detail-blkd_stkc.

* If routine call is made from Remote then assign Supplying Plant
*
  IF pt_onoff EQ 'R'.

    pt_stk-reswk = t_oio_cm_oplnt-reswk.

  ENDIF.

  APPEND pt_stk.


* For each item returned (Reqs, POs, Reservation etc)
  LOOP AT mrp_items.

    CLEAR pt_po.
    CLEAR pt_pr.
    pt_pr-matnr = pt_matnr.
    pt_pr-werks = pt_werks.
    pt_pr-aufnr = pt_aufnr.
    pt_pr-avail = mrp_items-avail_date.
    pt_po-matnr = pt_matnr.
    pt_po-werks = pt_werks.
    pt_po-aufnr = pt_aufnr.
    pt_po-avail = mrp_items-avail_date.

    IF mrp_items-mrp_element_ind EQ 'BE'.               " Order Item

* Type F = Procurement, its a STO or PO
      IF mrp_items-proc_type = 'F'.

        pt_po-ebeln = mrp_items-mrp_no.
        pt_po-ebelp = mrp_items-mrp_pos+1(5).

* Check for Order type (PO or STO)
        SELECT SINGLE * FROM ekko WHERE ebeln = pt_po-ebeln.
        IF sy-subrc = 0.

          IF ekko-bsart EQ 'UB'.                        " STO
            pt_po-type = 'STO'.
          ELSE.
            pt_po-type = 'PO'.
          ENDIF.

          pt_po-ekgrp = ekko-ekgrp.

          SELECT SINGLE * FROM ekpo WHERE ebeln = pt_po-ebeln    AND
                                          ebelp = pt_po-ebelp.

          IF sy-subrc = 0.

            pt_po-menge = ekpo-menge.
            pt_po-webaz = ekpo-webaz.

          ENDIF.

        ENDIF.

      ENDIF.

      APPEND pt_po.

    ELSEIF mrp_items-mrp_element_ind EQ 'BA'.           " Pur Req Order Item

* Its a Purchase Req
      IF mrp_items-order_type = 'NB'.
        pt_pr-banfn = mrp_items-mrp_no.
        pt_pr-bnfpo = mrp_items-mrp_pos+1(5).
*        pt_pr-menge = mrp_items-rec_reqd_qty.

        SELECT SINGLE * FROM eban WHERE banfn = pt_pr-banfn
                                    AND bnfpo = pt_pr-bnfpo.
        IF sy-subrc = 0.

          pt_pr-afnam = eban-afnam.
          pt_pr-menge = eban-menge.
          pt_pr-ekgrp = eban-ekgrp.

*ms
          pt_pr-eindt = eban-lfdat.

*ms

* .... Check to see if any RFQ's exist from Purchase Req. (from Deliv. Schedule)
          SELECT * FROM eket WHERE banfn = pt_pr-banfn
                               AND bnfpo = pt_pr-bnfpo.

            SELECT SINGLE * FROM ekko WHERE ebeln = eket-ebeln
                                      AND   bsart = 'AN'.                "RFQ Type
            IF sy-subrc EQ 0.

              pt_pr-rfqdoch = ekko-ebeln.
*              pt_pr-rfqdocl = ekko-ebelp.
              ADD eket-menge TO pt_pr-menge1.

            ENDIF.

            SUBTRACT eket-menge FROM pt_pr-menge.

          ENDSELECT.

        ENDIF.

      ENDIF.

      APPEND pt_pr.

    ENDIF.

  ENDLOOP.


ENDFORM.                    " GET_MRP_LIST
*&---------------------------------------------------------------------*
*&      Form  ALV_BUILD_FIELDCAT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->PT_FIELDCAT  text
*----------------------------------------------------------------------*
FORM            alv_build_fieldcat  TABLES   pt_fieldcat STRUCTURE gt_fieldcat.

  CLEAR pt_fieldcat.
  pt_fieldcat-fieldname = 'MATNR'.
*  pt_fieldcat-COL_POS  = 1.  "added additionally
  pt_fieldcat-just      = 'X'.
  pt_fieldcat-coltext   = TEXT-100.
  pt_fieldcat-sp_group  = 'UL'.
  pt_fieldcat-outputlen = 10.
  APPEND pt_fieldcat.

  CLEAR pt_fieldcat.
  pt_fieldcat-fieldname = 'MAKTX'.
*  pt_fieldcat-COL_POS  = 2.  "added additionally
  pt_fieldcat-just      = 'X'.
*  pt_fieldcat-coltext   = text-113.
  pt_fieldcat-coltext   = 'Material Description'.
  pt_fieldcat-outputlen = 35.
  APPEND pt_fieldcat.

  CLEAR pt_fieldcat.
  pt_fieldcat-fieldname = 'AUFNR'.
*  pt_fieldcat-COL_POS  = 3.  "added additionally
  pt_fieldcat-coltext   = TEXT-101.
  pt_fieldcat-outputlen = 10.
  APPEND pt_fieldcat.

  CLEAR pt_fieldcat.
  pt_fieldcat-fieldname = 'KTEXT'.
*  pt_fieldcat-COL_POS  = 4.  "added additionally
  pt_fieldcat-coltext   = TEXT-113.
  pt_fieldcat-outputlen = 30.
  APPEND pt_fieldcat.

  CLEAR pt_fieldcat.
  pt_fieldcat-fieldname = 'VORNR'.
*  pt_fieldcat-COL_POS  = 5.  "added additionally
  pt_fieldcat-do_sum    = 'X'.
  pt_fieldcat-coltext   = TEXT-102.
  pt_fieldcat-outputlen = 5.
  APPEND pt_fieldcat.

  CLEAR pt_fieldcat.
  pt_fieldcat-fieldname = 'POSNR'.
*  pt_fieldcat-COL_POS  = 6.  "added additionally
  pt_fieldcat-coltext   = TEXT-115.
  pt_fieldcat-outputlen = 7.
  APPEND pt_fieldcat.

  CLEAR pt_fieldcat.
  pt_fieldcat-fieldname = 'ZTOTREQ'.
*  pt_fieldcat-COL_POS  = 7.  "added additionally
*  pt_fieldcat-do_sum    = 'X'.
  pt_fieldcat-coltext   = TEXT-103.
  pt_fieldcat-outputlen = 8.
  APPEND pt_fieldcat.

  CLEAR pt_fieldcat.
  pt_fieldcat-fieldname = 'ZOUTQTY'.
*  pt_fieldcat-COL_POS  = 8.  "added additionally
*  pt_fieldcat-do_sum    = 'X'.
  pt_fieldcat-coltext   = TEXT-104.
  pt_fieldcat-outputlen = 8.
  APPEND pt_fieldcat.

  CLEAR pt_fieldcat.
  pt_fieldcat-fieldname = 'ZJOBISS'.
*  pt_fieldcat-COL_POS  = 9.  "added additionally
  pt_fieldcat-coltext   = TEXT-105.
  pt_fieldcat-outputlen = 8.
  APPEND pt_fieldcat.

  CLEAR pt_fieldcat.
  pt_fieldcat-fieldname = 'ZISSWEEK'.
*  pt_fieldcat-COL_POS  = 10.  "added additionally
  pt_fieldcat-coltext   = TEXT-106.
  pt_fieldcat-outputlen = 8.
  APPEND pt_fieldcat.

  CLEAR pt_fieldcat.
  pt_fieldcat-fieldname = 'ZPICKRDY'.
*  pt_fieldcat-COL_POS  = 11.  "added additionally
  pt_fieldcat-coltext   = TEXT-107.
  pt_fieldcat-outputlen = 9.
  APPEND pt_fieldcat.

  CLEAR pt_fieldcat.
  pt_fieldcat-fieldname = 'ZSTKOFF'.
*  pt_fieldcat-COL_POS  = 12.  "added additionally
  pt_fieldcat-coltext   = TEXT-108.
  pt_fieldcat-outputlen = 10.
  APPEND pt_fieldcat.

  CLEAR pt_fieldcat.
  pt_fieldcat-fieldname = 'ZSTKON'.
*  pt_fieldcat-COL_POS  = 13.  "added additionally
  pt_fieldcat-coltext   = TEXT-109.
  pt_fieldcat-outputlen = 8.
  APPEND pt_fieldcat.

  CLEAR pt_fieldcat.
  pt_fieldcat-fieldname = 'ZSTKOTHER'.
*  pt_fieldcat-COL_POS  = 14.  "added additionally
  pt_fieldcat-coltext   = TEXT-110.
  pt_fieldcat-outputlen = 8.
  APPEND pt_fieldcat.

  CLEAR pt_fieldcat.
  pt_fieldcat-fieldname = 'ZQUARTINE'.
*  pt_fieldcat-COL_POS  = 15.  "added additionally
  pt_fieldcat-coltext   = TEXT-111.
  pt_fieldcat-outputlen = 8.
  APPEND pt_fieldcat.

  CLEAR pt_fieldcat.
  pt_fieldcat-fieldname = 'ZPURQTY'.
*  pt_fieldcat-COL_POS  = 16.  "added additionally
  pt_fieldcat-coltext   = TEXT-114.
  pt_fieldcat-outputlen = 8.
  APPEND pt_fieldcat.
*ms

  CLEAR pt_fieldcat.
  pt_fieldcat-fieldname = 'EINDT'.
  pt_fieldcat-col_pos  = 27.  "added additionally
  pt_fieldcat-coltext   = 'Delivery Date'.
  pt_fieldcat-outputlen = 10.
  APPEND pt_fieldcat.




  CLEAR pt_fieldcat.
  pt_fieldcat-fieldname = 'TPLNR'.
  pt_fieldcat-col_pos  = 6.  "added additionally
  pt_fieldcat-coltext   = 'Functional Loc'.
  pt_fieldcat-outputlen = 12.
  APPEND pt_fieldcat.


  CLEAR pt_fieldcat.
  pt_fieldcat-fieldname = 'PLTXT'.
  pt_fieldcat-col_pos  = 7.  "added additionally
  pt_fieldcat-coltext   = 'Description of Functional location'.
  pt_fieldcat-outputlen = 40.
  APPEND pt_fieldcat.


  CLEAR pt_fieldcat.
  pt_fieldcat-fieldname = 'ZSUB'.
  pt_fieldcat-col_pos  = 39.  "added additionally
  pt_fieldcat-coltext   = 'Subcontarct'.
  pt_fieldcat-outputlen = 13.
  APPEND pt_fieldcat.




*ms
  CLEAR pt_fieldcat.
  pt_fieldcat-fieldname = 'ZINTRANS'.
*  pt_fieldcat-COL_POS  = 17.  "added additionally
  pt_fieldcat-coltext   = TEXT-112.
  pt_fieldcat-outputlen = 10.
  APPEND pt_fieldcat.

  CLEAR pt_fieldcat.
  pt_fieldcat-fieldname = 'ZTRANSON'.
*  pt_fieldcat-COL_POS  = 18.  "added additionally
  pt_fieldcat-coltext   = TEXT-116.
  pt_fieldcat-outputlen = 8.
  APPEND pt_fieldcat.

  IF NOT p_pmrep IS INITIAL.              "For PS reporting only

    CLEAR pt_fieldcat.
    pt_fieldcat-fieldname = 'POSID'.
    pt_fieldcat-no_out    = 'X'.
    pt_fieldcat-coltext   = TEXT-117.
    pt_fieldcat-outputlen = 20.
    APPEND pt_fieldcat.

  ENDIF.


  IF NOT p_pmrep IS INITIAL.
    CLEAR pt_fieldcat.

    CLEAR pt_fieldcat.
    pt_fieldcat-fieldname = 'OIO_MATNR'.
*  pt_fieldcat-COL_POS  = 19.  "added additionally
*    pt_fieldcat-coltext   = text-121.
    pt_fieldcat-outputlen = 10.
    APPEND pt_fieldcat.

    pt_fieldcat-fieldname = 'OIO_MBTXT'.
*  pt_fieldcat-COL_POS  = 20.  "added additionally
*    pt_fieldcat-coltext   = text-122.
    pt_fieldcat-outputlen = 15.
    APPEND pt_fieldcat.

    CLEAR pt_fieldcat.
    pt_fieldcat-fieldname = 'OIO_MBMNG'.
*  pt_fieldcat-COL_POS  = 21.  "added additionally
*    pt_fieldcat-coltext   = text-127.
    pt_fieldcat-outputlen = 6.
    APPEND pt_fieldcat.

    CLEAR pt_fieldcat.
    pt_fieldcat-fieldname = 'OIO_MBMEI'.
*  pt_fieldcat-COL_POS  = 22.  "added additionally
*    pt_fieldcat-coltext   = text-123.
    pt_fieldcat-outputlen = 3.
    APPEND pt_fieldcat.

    CLEAR pt_fieldcat.
    pt_fieldcat-fieldname = 'OIO_RNUMPACK'.
*  pt_fieldcat-COL_POS  = 23.  "added additionally
*    pt_fieldcat-coltext   = text-125.
    pt_fieldcat-outputlen = 4.
    APPEND pt_fieldcat.

    CLEAR pt_fieldcat.
    pt_fieldcat-fieldname = 'OIO_RVENDREF'.
*  pt_fieldcat-COL_POS  = 24.  "added additionally
*    pt_fieldcat-coltext   = text-126.
    pt_fieldcat-outputlen = 10.
    APPEND pt_fieldcat.

    CLEAR pt_fieldcat.
    pt_fieldcat-fieldname = 'OIO_RMOBSTAT_TEXT'.
*  pt_fieldcat-COL_POS  = 25.  "added additionally
*    pt_fieldcat-coltext   = text-124.
    pt_fieldcat-outputlen = 10.
    APPEND pt_fieldcat.



  ELSEIF NOT p_prjrep IS INITIAL.

    CLEAR pt_fieldcat.
    pt_fieldcat-fieldname = 'OIO_MATNR'.
    pt_fieldcat-no_out    = 'X'.
*  pt_fieldcat-COL_POS  = 19.  "added additionally
    pt_fieldcat-coltext   = TEXT-121.
    pt_fieldcat-outputlen = 21.
    APPEND pt_fieldcat.
*
    CLEAR pt_fieldcat.
    pt_fieldcat-fieldname = 'OIO_MBTXT'.
    pt_fieldcat-no_out    = 'X'.
*  pt_fieldcat-COL_POS  = 20.  "added additionally
    pt_fieldcat-coltext   = TEXT-122.
    pt_fieldcat-outputlen = 32.
    APPEND pt_fieldcat.

    CLEAR pt_fieldcat.
    pt_fieldcat-fieldname = 'OIO_MBMNG'.
    pt_fieldcat-no_out    = 'X'.
*  pt_fieldcat-COL_POS  = 21.  "added additionally
    pt_fieldcat-coltext   = TEXT-123.
    pt_fieldcat-outputlen = 21.
    APPEND pt_fieldcat.

    CLEAR pt_fieldcat.
    pt_fieldcat-fieldname = 'OIO_MBMEI'.
    pt_fieldcat-no_out    = 'X'.
*  pt_fieldcat-COL_POS  = 22.  "added additionally
    pt_fieldcat-coltext   = TEXT-125.
    pt_fieldcat-outputlen = 17.
    APPEND pt_fieldcat.

    CLEAR pt_fieldcat.
    pt_fieldcat-fieldname = 'OIO_RNUMPACK'.
    pt_fieldcat-no_out    = 'X'.
*  pt_fieldcat-COL_POS  = 23.  "added additionally
    pt_fieldcat-coltext   = TEXT-126.
    pt_fieldcat-outputlen = 18.
    APPEND pt_fieldcat.

    CLEAR pt_fieldcat.
    pt_fieldcat-fieldname = 'OIO_RVENDREF'.
    pt_fieldcat-no_out    = 'X'.
*  pt_fieldcat-COL_POS  = 24.  "added additionally
    pt_fieldcat-coltext   = TEXT-127.
    pt_fieldcat-outputlen = 18.
    APPEND pt_fieldcat.

    CLEAR pt_fieldcat.
    pt_fieldcat-fieldname = 'OIO_RMOBSTAT_TEXT'.
    pt_fieldcat-no_out    = 'X'.
*  pt_fieldcat-COL_POS  = 25.  "added additionally
    pt_fieldcat-coltext   = TEXT-124.
    pt_fieldcat-outputlen = 19.
    APPEND pt_fieldcat.
  ENDIF.

  IF NOT p_prjrep IS INITIAL OR
    NOT p_pmrep IS INITIAL.

    CLEAR pt_fieldcat.
    pt_fieldcat-fieldname = 'ACT_MENGE'.
    pt_fieldcat-no_out    = 'X'.

    pt_fieldcat-coltext   = 'text-128'.
    pt_fieldcat-outputlen = 8.
    APPEND pt_fieldcat.


    CLEAR pt_fieldcat.
    pt_fieldcat-fieldname = 'MEINS'.
    pt_fieldcat-no_out    = 'X'.

    pt_fieldcat-coltext   = 'text-129'.
    pt_fieldcat-outputlen = 8.
    APPEND pt_fieldcat.
  ENDIF.



ENDFORM.                    " ALV_BUILD_FIELDCAT
*&---------------------------------------------------------------------*
*&      Form  ALV_BUILD_SORT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_SORT  text
*----------------------------------------------------------------------*
FORM alv_build_sort  TABLES   pt_sort STRUCTURE gt_sort.

* Default Sort for initial display

  CLEAR pt_sort.
  pt_sort-spos       = '1'.
  pt_sort-fieldname  = 'AUFNR'.
  pt_sort-group      = 'UL'.
  pt_sort-up         = 'X'.
  APPEND pt_sort.

ENDFORM.                    " ALV_BUILD_SORT

*&---------------------------------------------------------------------*
*&      Form  SUB_BUILD_OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM sub_build_output .

  DATA: lv_green_light_chk1      TYPE zcoms.

  DATA: lv_yellow_light_chk1     TYPE zcoms.

  DATA: lv_yellow_light_chk2     TYPE zcoms.

  DATA: lv_date_light_chk1 TYPE dats,
        lv_date_light_chk2 TYPE dats,
        lv_date_light_chk3 TYPE dats.

  DATA: lv_temp_field(13)        TYPE c.


  LOOP AT gt_mat_layout_final.

    REPLACE ALL OCCURRENCES OF '.000' IN gt_mat_layout_final-ztotreq WITH space.
    REPLACE ALL OCCURRENCES OF '.000' IN gt_mat_layout_final-zjobiss WITH space.
    REPLACE ALL OCCURRENCES OF '.000' IN gt_mat_layout_final-zoutqty WITH space.
    REPLACE ALL OCCURRENCES OF '.000' IN gt_mat_layout_final-zpickrdy WITH space.
    REPLACE ALL OCCURRENCES OF '.000' IN gt_mat_layout_final-zstkoff WITH space.
    REPLACE ALL OCCURRENCES OF '.000' IN gt_mat_layout_final-zintrans WITH space.
    REPLACE ALL OCCURRENCES OF '.000' IN gt_mat_layout_final-zstkon  WITH space.
    REPLACE ALL OCCURRENCES OF '.000' IN gt_mat_layout_final-zstkother WITH space.
    REPLACE ALL OCCURRENCES OF '.000' IN gt_mat_layout_final-zissweek WITH space.
    REPLACE ALL OCCURRENCES OF '.000' IN gt_mat_layout_final-zquartine WITH space.
    REPLACE ALL OCCURRENCES OF '.000' IN gt_mat_layout_final-ztranson WITH space.
    REPLACE ALL OCCURRENCES OF '.000' IN gt_mat_layout_final-zpurqty WITH space.

* Check whether Fully Committed items required - potential to filter out "noise"
*    IF p_fulcom IS INITIAL.
*      IF gt_mat_layout_final-zpickrdy GE gt_mat_layout_final-zoutqty.
*        DELETE gt_mat_layout_final.
*      ENDIF.
*    ENDIF.

* Get Material Description
    PERFORM sub_get_material_desc.

* Get Material Class
    LOOP AT t_main_mat_class
         WHERE matnr = gt_mat_layout_final-matnr.

      gt_mat_layout_final-class = t_main_mat_class-class.
      EXIT.

    ENDLOOP.

* Get Order Description
    PERFORM sub_get_work_order_desc.

* Set traffic lights according to 'status' of material as follows:
*
* Committed or Committed and On Order exceeds Outstanding Qty  - 'Green'
* Any other stock held within Marathon                         - 'Amber'
* Outside Marathon                                             - 'Red' ie Deficient
*

* Red checks

    lv_date_light_chk1    = gt_mat_layout_final-zonsite.
    lv_date_light_chk2    = gt_mat_layout_final-zreqdate.
    lv_date_light_chk3    = sy-datum.

* Where calcs include Purch Qty ensure:
* i)  The On Site date is within the Required date AND
* ii) The On Site date is otherwise amount cannot be used

    IF lv_date_light_chk1 IS INITIAL              OR
       lv_date_light_chk1 GT lv_date_light_chk2   OR
       lv_date_light_chk3 GT lv_date_light_chk1.

* .... Set Green and yellow lights WITHOUT Purchase Qty included
      lv_green_light_chk1  = gt_mat_layout_final-zpickrdy.

      lv_yellow_light_chk1 = gt_mat_layout_final-zpickrdy  +
                             gt_mat_layout_final-zstkother +
                             gt_mat_layout_final-zintrans  +
                             gt_mat_layout_final-zquartine +
                             gt_mat_layout_final-zstkoff   +
                             gt_mat_layout_final-zstkon.

    ELSE.

* .... Set Green and yellow lights WITH Purchase Qty included
*      lv_green_light_chk1  = gt_mat_layout_final-zpickrdy + gt_mat_layout_final-zpurqty.
      lv_yellow_light_chk2  = gt_mat_layout_final-zpickrdy + gt_mat_layout_final-zpurqty.

      lv_yellow_light_chk1 = gt_mat_layout_final-zpickrdy  +
                             gt_mat_layout_final-zstkother +
                             gt_mat_layout_final-zintrans  +
                             gt_mat_layout_final-zquartine +
                             gt_mat_layout_final-zstkoff   +
                             gt_mat_layout_final-zstkon    +
                             gt_mat_layout_final-zpurqty.
    ENDIF.

*
* .... Now set traffic lights according to required checks

    CLEAR: gt_mat_layout_final-light.
    IF gt_mat_layout_final-maktx NE TEXT-128."IF ORDER HAS NO RENTAL DETAILS
      IF lv_green_light_chk1 GE gt_mat_layout_final-zoutqty.
*      or
*      gt_mat_layout_final-OIO_RMOBSTAT_TEXT = text-119.

        gt_mat_layout_final-light     = '3'.

      ELSEIF lv_yellow_light_chk2 GE gt_mat_layout_final-zoutqty .
*      or
*      ( gt_mat_layout_final-OIO_RMOBSTAT_TEXT = text-118 and  gt_mat_layout_final-ACT_MENGE is not INITIAL ).

        gt_mat_layout_final-light     = '2'.

      ELSEIF lv_yellow_light_chk1 GE gt_mat_layout_final-zoutqty.

        gt_mat_layout_final-light     = '2'.

      ELSEIF lv_yellow_light_chk1 LT gt_mat_layout_final-zoutqty .
*      or
*      ( gt_mat_layout_final-OIO_RMOBSTAT_TEXT = text-118 and  gt_mat_layout_final-ACT_MENGE is  INITIAL ).

        gt_mat_layout_final-light     = '1'.

      ENDIF.
*      Begin of changes in PhaseII "MKQURESHI MD1K994820
    ELSEIF gt_mat_layout_final-maktx EQ TEXT-128.
*      If mobilizatioon status is mobilized or demobilized,light = Green
      IF gt_mat_layout_final-oio_rmobstat_text = TEXT-119 OR gt_mat_layout_final-oio_rmobstat_text = TEXT-120.
        gt_mat_layout_final-light     = '3'.

*If mobilizatioon status is Waiting and there is no PO,light = Amber
      ELSEIF  gt_mat_layout_final-oio_rmobstat_text = TEXT-118 AND  gt_mat_layout_final-zonsite NE space .
        gt_mat_layout_final-light     = '2'.

*     If mobilizatioon status is Waiting and there is no PO,light = red
      ELSE.
        "IF  gt_mat_layout_final-oio_rmobstat_text = text-118 AND  gt_mat_layout_final-zonsite EQ space  .
        gt_mat_layout_final-light     = '1'.

      ENDIF.
*Begin of changes in PhaseII "MKQURESHI MD1K994820
    ENDIF.
    MODIFY gt_mat_layout_final.


  ENDLOOP.


ENDFORM.                    " SUB_BUILD_OUTPUT
*&---------------------------------------------------------------------*
*&      Form  SUB_GET_MATERIAL_DESC
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM sub_get_material_desc .

  DATA: ktext LIKE sktext OCCURS 0 WITH HEADER LINE.

  CALL FUNCTION 'MAKT_GENERIC_READ_WITH_MATNR'
    EXPORTING
      matnr     = gt_mat_layout_final-matnr
    TABLES
      ktext     = ktext
    EXCEPTIONS
      not_found = 01
      OTHERS    = 02.

  IF sy-subrc EQ 0.
*
    READ TABLE ktext INDEX 1.
    IF sy-subrc EQ 0.

      gt_mat_layout_final-maktx = ktext-maktx.

    ENDIF.
*
  ENDIF.



ENDFORM.                    " SUB_GET_MATERIAL_DESC
*&---------------------------------------------------------------------*
*&      Form  SUB_GET_WORK_ORDER_DESC
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM sub_get_work_order_desc .

  DATA: lv_caufv LIKE caufv.

  CALL FUNCTION 'CO_DB_HEADER_READ'
    EXPORTING
      aufnr     = gt_mat_layout_final-aufnr
    IMPORTING
      caufvwa   = lv_caufv
    EXCEPTIONS
      not_found = 1.

  IF sy-subrc EQ 0.

    gt_mat_layout_final-ktext = lv_caufv-ktext.

  ENDIF.

ENDFORM.                    " SUB_GET_WORK_ORDER_DESC
*&---------------------------------------------------------------------*
*&      Form  SUB_F4_FOR_VARIANT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      <--P_VARI  text
*----------------------------------------------------------------------*
FORM sub_f4_for_variant  CHANGING p_vari.

* Data
  DATA:
    gs_variant        TYPE disvariant.

* Report
  gs_variant-report = sy-repid.

* Search help for ALV variant
  CALL FUNCTION 'REUSE_ALV_VARIANT_F4'
    EXPORTING
      is_variant         = gs_variant
      i_save             = ' '
      i_display_via_grid = 'X'
    IMPORTING
      es_variant         = gs_variant
    EXCEPTIONS
      not_found          = 1
      program_error      = 2
      OTHERS             = 3.

* Return
  IF sy-subrc <> 0.
    MESSAGE ID     sy-msgid
            TYPE   'S'
            NUMBER sy-msgno
            WITH   sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.

  ELSE.
    p_vari = gs_variant-variant.
  ENDIF.

ENDFORM.                    " SUB_F4_FOR_VARIANT
*&---------------------------------------------------------------------*
*&      Form  SUB_F4_FOR_PRIOR
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      <--P_PRIOR  text
*----------------------------------------------------------------------*
FORM sub_f4_for_priok  CHANGING p_priokx.

*  TABLES: T356_T.
*
*  SELECT * FROM T356_T
*           WHERE SPRAS  EQ SY-LANGU
*           AND   ARTPR  EQ 'PM'.
*    WRITE: T356_t-PRIOKX.
*
*  ENDSELECT.
*
*
*
*  CALL FUNCTION 'HELP_PRIO_ART'
*       EXPORTING
*            artpr             = 'PM'
*            display           = ' '
*       IMPORTING
*            select_priok      = p_priok
*       EXCEPTIONS
*            no_priok_to_artpr = 01.
*  IF sy-subrc = 1.
*    MESSAGE i192(iw).
*  ENDIF.


ENDFORM.                    " SUB_F4_FOR_PRIOR
*&---------------------------------------------------------------------*
*&      Form  SUB_GET_WBS_ELEMENTS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM sub_get_wbs_elements .

* Pick up all relevant WBS items for entered Project Definition

  IF NOT s_projid[] IS INITIAL. .
    SELECT prps~pspnr          "WBS (Internal)
           prps~posid          "WBS (External)
    INTO TABLE t_wbs
    FROM   ( prps JOIN proj ON prps~psphi = proj~pspnr )
    WHERE  proj~pspid = s_projid-low.

    IF sy-subrc NE 0.
      MESSAGE e000 WITH
         'Error retrieving supplying WBS Elements table.'(010).
      STOP.
    ENDIF.
  ENDIF.

* Build WBS range for Reservation
  LOOP AT t_wbs.
    CLEAR  r_wbs.
    MOVE:  t_wbs-pspnr TO r_wbs-low,
           'I'         TO r_wbs-sign,
           'EQ'        TO r_wbs-option.
    APPEND r_wbs.
  ENDLOOP.


ENDFORM.                    " SUB_GET_WBS_ELEMENTS
*&---------------------------------------------------------------------*
*&      Form  SUB_INITIALISE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM sub_initialise .

  gt_mat_layout-ztotreq   = 0.
  gt_mat_layout-zjobiss   = 0.
  gt_mat_layout-zoutqty   = 0.
  gt_mat_layout-zpickrdy  = 0.
  gt_mat_layout-zstkoff   = 0.
  gt_mat_layout-zintrans  = 0.
  gt_mat_layout-zstkon    = 0.
  gt_mat_layout-zstkother = 0.
  gt_mat_layout-zissweek  = 0.
  gt_mat_layout-zquartine = 0.
  gt_mat_layout-ztranson  = 0.
  gt_mat_layout-zpurqty   = 0.

ENDFORM.                    " SUB_INITIALISE
*&---------------------------------------------------------------------*
*&      Form  SUB_GET_DIRECT_PROCURE_DETAILS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM sub_get_direct_procure_details .

  DATA: lv_rsdbs TYPE rsdbs,
        lv_prlab TYPE mspr-prlab.

  DATA: lt_xekbe     LIKE ekbe OCCURS 0 WITH HEADER LINE.

  LOOP AT t_main_stat
       WHERE mflic EQ 'PFV' OR
             mflic EQ 'XFR'.

    CLEAR: gt_mat_layout, gt_mat_layout_final.

* Initialise quantity/value fields
    PERFORM sub_initialise.

    MOVE-CORRESPONDING gt_mat_layout TO gt_mat_layout_final.

* Pick up Purchasing Documents and Onsite Dates/Quantities where applicable
    SELECT * FROM rsdbs
             INTO  lv_rsdbs
             WHERE rsnum EQ t_main_stat-rsnum
             AND   rspos EQ t_main_stat-rspos
             AND   rsart EQ t_main_stat-rsart.


      IF NOT lv_rsdbs-ebeln IS INITIAL.

        CLEAR: lt_xekbe.
        REFRESH: lt_xekbe.

        CALL FUNCTION 'ME_READ_HISTORY'
          EXPORTING
            ebeln = lv_rsdbs-ebeln
            ebelp = lv_rsdbs-ebelp
            webre = ' '
*           I_BYPASSING_BUFFER =
*           I_REFRESH_BUFFER   =
*           I_EKBEH            =
*           LFGJA =
*           LFBNR =
*           LFPOS =
          TABLES
            xekbe = lt_xekbe.
*           XEKBES                   =
*           XEKBEZ                   =
*           XEKBNK                   =
*           XEKBZ                    =
*           XRSEG                    =              .

        SELECT SINGLE * FROM ekko
                        WHERE ebeln = lv_rsdbs-ebeln.
        IF sy-subrc = 0.

          gt_mat_layout_final-ekgrp = ekko-ekgrp.

          SELECT SINGLE * FROM ekpo
                          WHERE ebeln = lv_rsdbs-ebeln
                          AND   ebelp = lv_rsdbs-ebelp.
          IF sy-subrc EQ 0.

            gt_mat_layout_final-zpurqty = ekpo-menge.

            LOOP AT lt_xekbe.

              CASE lt_xekbe-shkzg.
                WHEN 'S'.
                  SUBTRACT lt_xekbe-menge FROM gt_mat_layout_final-zpurqty.
                WHEN 'H'.
                  ADD      lt_xekbe-menge   TO gt_mat_layout_final-zpurqty.
              ENDCASE.

            ENDLOOP.

          ENDIF.

        ENDIF.

        gt_mat_layout_final-zpurdoc = lv_rsdbs-ebeln.

      ELSEIF NOT lv_rsdbs-banfn IS INITIAL.

        gt_mat_layout_final-zpurdoc = lv_rsdbs-banfn.

        SELECT SINGLE * FROM eban WHERE banfn = lv_rsdbs-banfn
                                    AND bnfpo = lv_rsdbs-bnfpo.
        IF sy-subrc = 0.

          gt_mat_layout_final-zpurqty = eban-menge.
          gt_mat_layout_final-ekgrp   = eban-ekgrp.

        ENDIF.

      ENDIF.

    ENDSELECT.

* Build remaining fields for output:
*  i) Total Reservation Qty
* ii) Total Stock Onshore

    gt_mat_layout_final-matnr     = t_main_stat-matnr.                  "Material
    gt_mat_layout_final-werks     = t_main_stat-werks.                  "Plant
    gt_mat_layout_final-aufnr     = t_main_stat-aufnr.                  "Order
    gt_mat_layout_final-vornr     = t_main_stat-vornr.                  "Activity
    gt_mat_layout_final-posnr     = t_main_stat-posnr.                  "BOM
    gt_mat_layout_final-ztotreq   = t_main_stat-bdmng.                  "Reservation
*    gt_mat_layout_final-OIO_MATNR = t_main_stat-OIO_MATNR.
*    gt_mat_layout_final-OIO_MBTXT = t_main_stat-OIO_MBTXT.
*    gt_mat_layout_final-OIO_MBMNG = t_main_stat-OIO_MBMNG.
*    gt_mat_layout_final-OIO_MBMEI = t_main_stat-OIO_MBMEI.
*    gt_mat_layout_final-OIO_RNUMPACK = t_main_stat-OIO_RNUMPACK.
*    gt_mat_layout_final-OIO_RVENDREF = t_main_stat-OIO_RVENDREF.
*    gt_mat_layout_final-OIO_RMOBSTAT = t_main_stat-OIO_RMOBSTAT.



* Get WBS format
    CALL FUNCTION 'CONVERSION_EXIT_ABPSP_OUTPUT'
      EXPORTING
        input  = t_main_stat-pspel
      IMPORTING
        output = gt_mat_layout_final-posid.                       "WBS
    .
* Get Onshore Stock of supplying Plant
*   read table t_oio_cm_oplnt with key werks = t_main_stat-werks.
*   if sy-subrc eq 0.

    SELECT SINGLE prlab INTO lv_prlab
    FROM mspr
    WHERE matnr EQ t_main_stat-matnr AND
*           werks EQ t_oio_cm_oplnt-reswk.
          werks EQ t_main_stat-werks.

    IF sy-subrc EQ 0.

      gt_mat_layout_final-zstkon = lv_prlab.                          "Stock Onshore

    ENDIF.

*   endif.

    APPEND gt_mat_layout_final.

  ENDLOOP.

ENDFORM.                    " SUB_GET_DIRECT_PROCURE_DETAILS
*&---------------------------------------------------------------------*
*&      Form  RENTAL_DETIAL
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM rental_detail .

***********Structure Declaration****************************************
  TYPES: BEGIN OF ty_aufpl,
           aufnr TYPE aufnr,
           aufpl TYPE co_aufpl,
         END OF ty_aufpl.

  TYPES: BEGIN OF ty_packno,
           aufpl      TYPE co_aufpl,
           packno     TYPE packno,
           sub_packno TYPE sub_packno,
         END OF ty_packno.

  TYPES: BEGIN OF ty_package,
           packno     TYPE packno,
           sub_packno TYPE sub_packno,
         END OF ty_package.

  TYPES: BEGIN OF ty_esll,
           packno                TYPE packno,
           sub_packno            TYPE sub_packno,
           oio_matnr             TYPE oio_rn_matnr,
           oio_mbtxt             TYPE oio_rn_mbtxt,
           oio_mbmng             TYPE oio_rn_mbmng,
           oio_mbmei             TYPE oio_rn_mbmei,
           oio_rmobstat          TYPE oio_rn_mobstat,
           oio_rnumpack          TYPE oio_rn_numpack,
           oio_rvendref          TYPE oio_rn_vendref,
           oio_rmobstat_text(20) TYPE c,
           act_menge             TYPE act_menge,
         END OF ty_esll.

  TYPES: BEGIN OF ty_main_stat1 .
      INCLUDE STRUCTURE zmmtracklayout.
  TYPES: aufpl      TYPE co_aufpl,
         banfn      TYPE co_banfn,
         bnfpo      TYPE co_bnfpo,
         packno     TYPE packno,
         sub_packno TYPE sub_packno.
  TYPES : END OF ty_main_stat1.

**********Table types*******************************************
  TYPES: tt_main_stat1 TYPE STANDARD TABLE OF ty_main_stat1,
         tt_esll       TYPE STANDARD TABLE OF ty_esll,
         tt_aufpl      TYPE STANDARD TABLE OF ty_aufpl,
         tt_packno     TYPE STANDARD TABLE OF ty_packno,
         tt_package    TYPE STANDARD TABLE OF ty_package.

******************Global variables**************************************

  DATA : g_aufnr TYPE aufnr,
         g_count TYPE i,
         g_n     TYPE i.

*******************internal tables and work areas************************
*  DATA: BEGIN OF it_main_stat1 OCCURS 0.
*          INCLUDE STRUCTURE zmmtracklayout.
*  DATA: aufpl TYPE co_aufpl,
*        banfn TYPE co_banfn,
*        bnfpo TYPE co_bnfpo,
*        packno TYPE packno,
*        sub_packno TYPE sub_packno.
*
*  DATA: END OF it_main_stat1.
  DATA : it_main_stat1 TYPE tt_main_stat1,
         gf_main_stat1 TYPE ty_main_stat1,
         gf_main_stat3 TYPE ty_main_stat1,
         gf_main_stat  TYPE ty_main_stat1.

  DATA : it_eban TYPE TABLE OF eban,
         gf_eban TYPE eban.

  DATA : it_aufpl TYPE tt_aufpl,
         gf_aufpl TYPE ty_aufpl.

  DATA: it_packno TYPE  tt_packno,
        gf_packno TYPE ty_packno.

  DATA : it_package TYPE tt_package,
         gf_package TYPE ty_package.

  DATA : it_main_stat2 TYPE tt_main_stat1,
         gf_main_stat2 LIKE LINE OF gt_mat_layout_final.

  DATA : it_esll TYPE tt_esll,
         gf_esll TYPE ty_esll.

  DATA : it_packno1 TYPE TABLE OF ty_packno,
         gf_packno1 TYPE ty_packno.

  DATA : it_afvc1 TYPE TABLE OF afvc,
         gf_afvc1 TYPE afvc.



  it_main_stat1[] = gt_mat_layout_final[] .
  it_main_stat2[] = gt_mat_layout_final[] .
  CHECK gt_mat_layout_final[] IS NOT INITIAL.
  SELECT aufnr aufpl  INTO TABLE it_aufpl FROM afko FOR ALL ENTRIES IN gt_mat_layout_final
    WHERE aufnr = gt_mat_layout_final-aufnr.

  CHECK it_aufpl[] IS NOT INITIAL.

  SELECT aufpl  packno INTO TABLE it_packno FROM afvc FOR ALL ENTRIES IN it_aufpl
    WHERE aufpl = it_aufpl-aufpl.

  DELETE it_packno WHERE packno IS INITIAL.

  IF it_packno[] IS NOT INITIAL.
    SELECT packno sub_packno INTO TABLE it_package FROM esll FOR ALL ENTRIES IN it_packno
      WHERE packno = it_packno-packno.

    CHECK it_package[] IS NOT INITIAL.

    SELECT * FROM esll INTO CORRESPONDING FIELDS OF TABLE it_esll FOR ALL ENTRIES IN it_package
      WHERE packno = it_package-sub_packno AND
      oio_xrent = 'X'.

    LOOP AT it_esll INTO gf_esll.
      IF gf_esll-oio_rmobstat EQ 'W'.
        gf_esll-oio_rmobstat_text = TEXT-118.
      ELSEIF gf_esll-oio_rmobstat EQ 'M'.
        gf_esll-oio_rmobstat_text = TEXT-119 .
      ELSEIF gf_esll-oio_rmobstat EQ 'D'.
        gf_esll-oio_rmobstat_text = TEXT-120 .
      ELSEIF gf_esll-oio_rmobstat IS INITIAL.
        gf_esll-oio_rmobstat_text = space.
      ENDIF.
      MODIFY it_esll FROM gf_esll TRANSPORTING oio_rmobstat_text WHERE oio_rmobstat = gf_esll-oio_rmobstat.
    ENDLOOP.


    SORT it_main_stat1 BY aufnr.
    CLEAR gf_main_stat1.
    LOOP AT it_main_stat1 INTO gf_main_stat1.

      IF gf_main_stat1-aufnr NE g_aufnr.
        CLEAR gf_aufpl.
        READ TABLE it_aufpl INTO gf_aufpl WITH  KEY
        aufnr = gf_main_stat1-aufnr.
        IF sy-subrc EQ 0.
          CLEAR gf_packno.
          LOOP AT it_packno INTO gf_packno WHERE aufpl = gf_aufpl-aufpl.
            IF sy-subrc EQ 0.
              CLEAR gf_package.
              LOOP AT it_package INTO gf_package WHERE packno = gf_packno-packno.
                CLEAR gf_esll.
                LOOP AT it_esll INTO gf_esll WHERE packno = gf_package-sub_packno.
                  CLEAR gf_main_stat3.
                  gf_main_stat3-aufnr = gf_main_stat1-aufnr.
                  gf_main_stat3-werks = gf_main_stat1-werks.
                  gf_main_stat3-ingpr = gf_main_stat1-ingpr.
                  gf_main_stat3-oio_matnr = gf_esll-oio_matnr .
                  gf_main_stat3-oio_mbtxt = gf_esll-oio_mbtxt .
                  gf_main_stat3-oio_mbmng = gf_esll-oio_mbmng.
                  gf_main_stat3-oio_mbmei = gf_esll-oio_mbmei .
                  gf_main_stat3-oio_rmobstat_text = gf_esll-oio_rmobstat_text.
                  gf_main_stat3-oio_rnumpack = gf_esll-oio_rnumpack.
                  gf_main_stat3-oio_rvendref = gf_esll-oio_rvendref.
                  gf_main_stat3-sub_packno = gf_esll-packno.
                  APPEND gf_main_stat3 TO gt_mat_layout_final.
                  APPEND gf_main_stat3 TO it_main_stat2.
                ENDLOOP.
              ENDLOOP.
            ENDIF.
          ENDLOOP.
        ENDIF.
        g_aufnr = gf_main_stat1-aufnr.
      ENDIF.
    ENDLOOP.

*Selecting the purchase document,quantity for orders having rental details
    it_main_stat1[] = it_main_stat2[] .
*      CHECK it_main_stat1[] IS NOT INITIAL.
* HANA Corrections - BEGIN OF MODIFY - <HANA-001>
    IF NOT it_main_stat1[] IS INITIAL.
* HANA Corrections - END OF MODIFY - <HANA-001>
      SELECT packno sub_packno FROM esll INTO CORRESPONDING FIELDS OF TABLE it_packno1
        FOR ALL ENTRIES IN it_main_stat1 WHERE sub_packno = it_main_stat1-sub_packno.
* HANA Corrections - BEGIN OF MODIFY - <HANA-001>
    ENDIF.
* HANA Corrections - END OF MODIFY - <HANA-001>

    LOOP AT it_packno1 INTO gf_packno1.
      gf_main_stat1-packno = gf_packno1-packno .
      gf_main_stat1-sub_packno = gf_packno1-sub_packno.
      MODIFY it_main_stat1 FROM gf_main_stat1 TRANSPORTING packno WHERE sub_packno = gf_main_stat1-sub_packno.
    ENDLOOP.


* HANA Corrections - BEGIN OF MODIFY - <HANA-001>
    IF NOT it_main_stat1[] IS INITIAL.
* HANA Corrections - END OF MODIFY - <HANA-001>
      SELECT aufpl vornr banfn bnfpo packno FROM afvc INTO CORRESPONDING FIELDS OF TABLE it_afvc1
        FOR ALL ENTRIES IN it_main_stat1 WHERE packno = it_main_stat1-packno.
* HANA Corrections - BEGIN OF MODIFY - <HANA-001>
    ENDIF.
* HANA Corrections - END OF MODIFY - <HANA-001>

    LOOP AT it_afvc1 INTO gf_afvc1.
      gf_main_stat1-packno = gf_afvc1-packno.
      gf_main_stat1-vornr = gf_afvc1-vornr.
      gf_main_stat1-aufpl = gf_afvc1-aufpl.
      gf_main_stat1-banfn = gf_afvc1-banfn.
      gf_main_stat1-bnfpo = gf_afvc1-bnfpo.
      gf_main_stat1-maktx = TEXT-128.
      MODIFY it_main_stat1 FROM gf_main_stat1 TRANSPORTING maktx vornr aufpl banfn bnfpo WHERE packno = gf_main_stat1-packno.

    ENDLOOP.


* HANA Corrections - BEGIN OF MODIFY - <HANA-001>
    IF NOT it_main_stat1[] IS INITIAL.
* HANA Corrections - END OF MODIFY - <HANA-001>
      SELECT * FROM eban INTO CORRESPONDING FIELDS OF TABLE it_eban
             FOR ALL ENTRIES IN it_main_stat1 WHERE banfn = it_main_stat1-banfn  AND
                                           bnfpo  = it_main_stat1-bnfpo .
* HANA Corrections - BEGIN OF MODIFY - <HANA-001>
    ENDIF.
* HANA Corrections - END OF MODIFY - <HANA-001>


    LOOP AT it_eban INTO gf_eban.
      gf_main_stat1-ekgrp = gf_eban-ekgrp.
      IF gf_eban-ebeln IS NOT INITIAL."IF PO EXIST
        gf_main_stat1-zpurdoc = gf_eban-ebeln.
        gf_main_stat1-zpurqty = gf_eban-bsmng.
        gf_main_stat1-zonsite = gf_eban-bedat + p_ship.
      ELSE. "IF PO DOESNT EXIST THEN PR
        gf_main_stat1-zpurdoc = gf_eban-banfn.
        gf_main_stat1-zpurqty = gf_eban-menge.
        gf_main_stat1-zonsite = space.
      ENDIF.
      gf_main_stat1-banfn = gf_eban-banfn.
      gf_main_stat1-bnfpo = gf_eban-bnfpo.
      MODIFY it_main_stat1 FROM gf_main_stat1
      TRANSPORTING zpurdoc ekgrp zpurqty zonsite WHERE banfn = gf_main_stat1-banfn AND bnfpo = gf_main_stat1-bnfpo.
    ENDLOOP.

*Deleting the orders with no rental equipment and material.
*    DELETE gt_mat_layout_final WHERE
*  MATNR IS INITIAL and OIO_RMOBSTAT_TEXT is INITIAL .
    LOOP AT it_main_stat1 INTO gf_main_stat1 WHERE
*           OIO_MATNR is NOT INITIAL and
      oio_mbtxt IS NOT INITIAL OR oio_mbmng IS NOT INITIAL OR
      oio_mbmei IS NOT INITIAL OR oio_rmobstat_text IS NOT INITIAL .
      MOVE-CORRESPONDING  gf_main_stat1 TO gf_main_stat2.
      MODIFY gt_mat_layout_final FROM gf_main_stat2 TRANSPORTING maktx vornr zpurdoc ekgrp zpurqty zonsite
      WHERE oio_matnr = gf_main_stat1-oio_matnr AND oio_mbtxt = gf_main_stat1-oio_mbtxt AND aufnr = gf_main_stat1-aufnr.
    ENDLOOP.

  ELSE.
*  Deleting teh order which has neither service nor component.
    DELETE gt_mat_layout_final WHERE
  matnr IS INITIAL AND maktx  IS INITIAL .
    "and (  oio_rmobstat_text IS INITIAL or OIO_MBTXT is initial ).
  ENDIF.


*  DATA: WA_CELLCOLOR like line of  gt_mat_layout_final.
*
*  WA_CELLCOLOR-FNAME = 'MAKTX'.
*    WA_CELLCOLOR-COL = 4.  "color code 1-7, if outside rage defaults to 7
*    WA_CELLCOLOR-INT = '1'.  "1 = Intensified on, 0 = Intensified off
*    WA_CELLCOLOR-INV = '0'.  "1 = text colour, 0 = background colour
**     WA_CELLCOLOR = wa_main_stat1-LVC_S_SCOL.
*    MODIFY gt_mat_layout_final from WA_CELLCOLOR TRANSPORTING fname col int inv where maktx = text-128.

  DELETE gt_mat_layout_final WHERE
    matnr IS INITIAL AND maktx  IS INITIAL .
ENDFORM.                    " RENTAL_DETIAL
*&---------------------------------------------------------------------*
*&      Form  RENTAL_ORDER_FETCH
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM rental_order_fetch .
*  CHECKING THE FOLLOWING SELECTION PARAMETERS AS THEY ARE COMPONENT SPECIFIC.
  IF s_sortf IS INITIAL AND r_kzear IS NOT INITIAL AND s_matnr IS INITIAL AND s_matkl IS INITIAL AND
    s_naufnr IS INITIAL AND s_vornr IS INITIAL AND s_projid IS INITIAL.
    SELECT viaufkst~rsnum
               viaufkst~werks
               viaufkst~tplnr
               viaufkst~priok
               viaufkst~equnr
               viaufkst~ingpr
               viaufkst~aufnr
               jest~objnr
               jest~stat
        INTO CORRESPONDING FIELDS OF TABLE it_main1
        FROM viaufkst
        JOIN jest
          ON ( viaufkst~objnr   = jest~objnr  )
        WHERE viaufkst~aufnr   IN s_aufnr                AND
              viaufkst~auart   IN s_auart                AND
              viaufkst~swerk   IN s_swerk                AND
              viaufkst~iwerk   IN s_iwerk                AND
              viaufkst~werks   IN r_werks                AND
              viaufkst~stort   IN s_stort                AND
              viaufkst~gstrp   IN s_gstrp                AND
              viaufkst~tplnr   IN s_tplnr                AND
              viaufkst~revnr   IN s_revnr                AND
              viaufkst~ingpr   IN s_ingpr                AND
              viaufkst~autyp   EQ '30'                   AND
              viaufkst~iphas   IN r_iphas                AND
              viaufkst~priok   IN r_priok                AND
              jest~inact       EQ space .

  ENDIF.

*FILTERING THE ORDER FOR RENTAL EQUIPMENT.
  LOOP AT t_main INTO gf_main.
    DELETE it_main1 WHERE aufnr  =  gf_main-aufnr.
  ENDLOOP.
ENDFORM.                    " RENTAL_ORDER_FETCH
*&---------------------------------------------------------------------*
*&      Form  DELIVERY_DATE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM delivery_date .

  DATA:BEGIN OF it_ekpo OCCURS 0,
         ebeln LIKE ekpo-ebeln,
         ebelp LIKE ekpo-ebelp,
         matnr LIKE ekpo-matnr,
       END OF it_ekpo.

  DATA: v_eindt LIKE eket-eindt.

  DATA: v_bstyp LIKE ekko-bstyp.

  SORT gt_mat_layout_final BY zpurdoc DESCENDING.

  IF gt_mat_layout_final[] IS NOT INITIAL.

    SELECT ebeln ebelp matnr FROM ekpo
    INTO CORRESPONDING FIELDS OF TABLE it_ekpo
    FOR ALL ENTRIES IN gt_mat_layout_final
    WHERE ebeln = gt_mat_layout_final-zpurdoc
    AND matnr = gt_mat_layout_final-matnr.

  ENDIF.

  LOOP AT gt_mat_layout_final.

    SELECT SINGLE bstyp FROM ekko INTO v_bstyp WHERE  ebeln = gt_mat_layout_final-zpurdoc.

    IF sy-subrc = 0.

      gt_mat_layout_final-bstyp = v_bstyp.

      CLEAR gt_mat_layout.

      MODIFY gt_mat_layout_final.



    ENDIF.



  ENDLOOP.



  LOOP AT gt_mat_layout_final.

    IF gt_mat_layout_final-zpurdoc CP '60*'.

      READ TABLE it_ekpo WITH KEY ebeln = gt_mat_layout_final-zpurdoc
                                  matnr = gt_mat_layout_final-matnr.

      IF sy-subrc = 0.

        gt_mat_layout_final-ebelp = it_ekpo-ebelp.

        MODIFY gt_mat_layout_final." transporting ebelp.

      ENDIF.

    ENDIF.

  ENDLOOP.

  FREE it_ekpo[].

  LOOP AT gt_mat_layout_final.

*IF GT_MAT_LAYOUT_FINAL-ZPURDOC CP '60*'.

    IF gt_mat_layout_final-zpurdoc CP '47*' OR gt_mat_layout_final-zpurdoc CP '45*'.

*Begin of Modify for NWDK902274
*      SELECT SINGLE EINDT FROM EKET INTO V_EINDT WHERE EBELN = GT_MAT_LAYOUT_FINAL-ZPURDOC
*      AND EBELP =  GT_MAT_LAYOUT_FINAL-EBELP.
      SELECT eindt FROM eket INTO v_eindt WHERE ebeln = gt_mat_layout_final-zpurdoc
      AND ebelp =  gt_mat_layout_final-ebelp
      ORDER BY PRIMARY KEY.
      ENDSELECT.
*End of Modify for NWDK902274
      IF sy-subrc = 0.

        gt_mat_layout_final-eindt = v_eindt.

        MODIFY gt_mat_layout_final.


      ENDIF.

    ENDIF.

  ENDLOOP.

ENDFORM.                    " DELIVERY_DATE
*&---------------------------------------------------------------------*
*&      Form  FUNCTIONAL_LOC_DESC
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM functional_loc_desc .
  DATA: v_tplnr     LIKE viaufkst-tplnr,
        v_pltxt(40) TYPE c.


  LOOP AT gt_mat_layout_final.


    CHECK gt_mat_layout_final-aufnr IS NOT INITIAL.

    CLEAR v_tplnr.

    SELECT SINGLE tplnr FROM viaufkst INTO v_tplnr
     WHERE aufnr =  gt_mat_layout_final-aufnr .

    IF sy-subrc  = 0.


      gt_mat_layout_final-tplnr = v_tplnr.

      MODIFY gt_mat_layout_final.




    ENDIF.


  ENDLOOP.


  LOOP AT  gt_mat_layout_final .

    CHECK gt_mat_layout_final-tplnr IS NOT INITIAL.



*Begin of Modify for NWDK902274
*    Select single pltxt from IFLOTX into v_PLTXT
*     where TPLNR  =  gt_mat_layout_final-TPLNR .
    SELECT pltxt FROM iflotx INTO v_pltxt
    WHERE tplnr  =  gt_mat_layout_final-tplnr
    ORDER BY PRIMARY KEY.
    ENDSELECT.
*End of Modify for NWDK902274

    IF sy-subrc  = 0.


      gt_mat_layout_final-pltxt = v_pltxt.

      MODIFY gt_mat_layout_final.


    ENDIF.


  ENDLOOP.



ENDFORM.                    " FUNCTIONAL_LOC_DESC
*&---------------------------------------------------------------------*
*&      Form  SUB_CONTARCT_QTY
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM sub_contarct_qty .

  DATA: BEGIN OF it_vendor OCCURS 0,
          ebeln LIKE ekko-ebeln,
          lifnr LIKE ekko-lifnr,
          blab  LIKE mslb-lblab,
          matnr LIKE mslb-matnr,
*      lifnr like mslb-matnr,
          lblab LIKE mslb-lblab,
        END OF it_vendor.

  DATA: BEGIN OF it_qty OCCURS 0,
          ebeln LIKE ekko-ebeln,
*      LIFNR
          lblab LIKE mslb-lblab,
          matnr LIKE mslb-matnr,
          lifnr LIKE mslb-matnr,
        END OF it_qty.


  IF  gt_mat_layout_final[] IS NOT INITIAL.

    SELECT lifnr ebeln FROM ekko INTO CORRESPONDING FIELDS OF TABLE it_vendor FOR  ALL ENTRIES IN gt_mat_layout_final
    WHERE ebeln =  gt_mat_layout_final-zpurdoc." and

  ENDIF.


  LOOP AT gt_mat_layout_final.

*if gt_mat_layout_final-light = 1 or  gt_mat_layout_final-light = 2.

    IF gt_mat_layout_final-bstyp NE 'F'.

      gt_mat_layout_final-eindt  = '  '.

      MODIFY gt_mat_layout_final.


    ENDIF.

  ENDLOOP.



*loop at gt_mat_layout_final.
*
*if gt_mat_layout_final-light = 1 or  gt_mat_layout_final-light = 2.
*
**IF GT_MAT_LAYOUT_FINAL-STTP NE 'F'.
*
*gt_mat_layout_final-eindt  = '  '.
*
*modify gt_mat_layout_final.
*
**endif.
*
*ENDIF.
*
*endloop.


  LOOP AT gt_mat_layout_final.

    READ TABLE it_vendor WITH KEY ebeln = gt_mat_layout_final-zpurdoc.

    IF sy-subrc = 0.

      gt_mat_layout_final-lifnr  =  it_vendor-lifnr.

      MODIFY gt_mat_layout_final.


    ENDIF.


  ENDLOOP.


*LOOP AT GT_MAT_LAYOUT_FINAL.

  SELECT matnr werks lblab lifnr FROM mslb INTO CORRESPONDING FIELDS OF TABLE it_qty  FOR ALL ENTRIES
  IN gt_mat_layout_final  WHERE
  matnr = gt_mat_layout_final-matnr AND
  lifnr = gt_mat_layout_final-lifnr.

*ENDLOOP.

*loop at it_vendor.
**
*read table it_qty with key lifnr = it_vendor-lifnr.
**
*if sy-subrc = 0.
***
*it_vendor-lifnr = it_qty-lifnr.
*
*it_vendor-matnr  = it_qty-matnr.
*
*IT_VENDOR-LBLAB = IT_QTY-LBLAB.
*
*modify table it_vendor.
***
***
*endif.
**
**
*endloop.
**
*SORT IT_VENDOR BY EBELN MATNR.

  LOOP AT gt_mat_layout_final.

    READ TABLE it_qty  WITH KEY matnr = gt_mat_layout_final-matnr
                            lifnr     =  gt_mat_layout_final-lifnr.


    IF sy-subrc = 0.

      gt_mat_layout_final-zsub = it_qty-lblab.
*
*GT_MAT_LAYOUT_FINAL-LIFNR = IT_VENDOR-LIFNR.

      MODIFY TABLE gt_mat_layout_final.

    ENDIF.


  ENDLOOP.

  FREE: it_vendor[],
        it_qty.


ENDFORM.                    " SUB_CONTARCT_QTY
