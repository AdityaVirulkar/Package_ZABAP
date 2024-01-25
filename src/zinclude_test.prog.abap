REPORT (sy-repid)
       NO STANDARD PAGE HEADING
       LINE-COUNT 65
       LINE-SIZE  132
       MESSAGE-ID ih.

*-------------------------------------------------------------------*
* Type pools                                               *
*-------------------------------------------------------------------*

TYPE-POOLS: vrm , esp6 .

*-------------------------------------------------------------------*
* Datenbanktabellen                                                 *
*-------------------------------------------------------------------*
TABLES: viaufkst,
        rihaufk,
        rihaufk_list,
        diaufk,
        hikola,
        caufvd,                        " Orderdialog workarea
        riwo1,                         " Equi/Tplnr incl workarea
        crfhd,                         " Fertigungshilfsmittel
        ihsg,                          " Genehmigungen
        prps,                          " PSP_Elemente
        cobrb.                         " Abrechungsempfänger
*-------------------------------------------------------------------*
* ATAB-Tabellen                                                     *
*-------------------------------------------------------------------*
TABLES: t370a,
        t352r,                         "revision number
        t003o.

TABLES: sscrfields.
*ENHANCEMENT-POINT riaufk20_01 SPOTS es_riaufk20 STATIC.
*-------------------------------------------------------------------*
* Interne Tabellen                                                  *
*-------------------------------------------------------------------*

DATA: BEGIN OF object_tab OCCURS 1.
        INCLUDE STRUCTURE rihaufk_list.
DATA:  ppsid LIKE viaufkst-ppsid.
DATA:  igewrk LIKE viaufkst-gewrk.          "Int Verant.Arbeitsplatz
DATA:  aufpt  LIKE viaufkst-aufpt.          "Int Netzwerknummer
DATA:  aplzt  LIKE viaufkst-aplzt.          "Int Netzwerkvorgang
DATA:  adrnr_iloa  LIKE viaufkst-adrnr_iloa."Adresse Bezugsobjekt
DATA:  tplnr_int   LIKE viaufkst-tplnr.     "T.Platz int. Format
DATA:  no_disp    LIKE viaufkst-no_disp.    "Dispokennzeichen Datenb.
DATA:  selected,
       lights,
       pm_selected TYPE pm_selected,
      END OF object_tab.

* sort table

 DATA: BEGIN OF sort_tab OCCURS 0,

       aufnr TYPE viaufkst-aufnr,
       auart TYPE viaufkst-auart,
       gstrp TYPE viaufkst-gstrp,
       priok TYPE viaufkst-priok,
       revnr TYPE viaufkst-revnr,
       sttxt LIKE object_tab-sttxt,
       ustxt LIKE object_tab-ustxt,
       ilart TYPE viaufkst-ilart,
       ingpr TYPE viaufkst-ingpr,
       gstri TYPE viaufkst-gstri,

       END OF sort_tab.   "sunil


* Internal table for the planning table call.
DATA: i_fil_tab LIKE cyfil_tab OCCURS 10 WITH HEADER LINE.
*--- Selektionstab wenn in Auswahlmodus
DATA: sel_tab LIKE rihaufk_list OCCURS 1 WITH HEADER LINE.
*--- itab für Druck
DATA: iworkpaper LIKE wworkpaper OCCURS 0 WITH HEADER LINE.
*--- prefetchtabellen
DATA: l_jsto_pre_tab LIKE jsto_pre OCCURS 0 WITH HEADER LINE.
DATA: l_tarbid LIKE crid OCCURS 0 WITH HEADER LINE.

DATA g_adrnr_sel_tab LIKE addr1_sel OCCURS 50 WITH HEADER LINE.
DATA g_adrnr_val_tab LIKE addr1_val OCCURS 50 WITH HEADER LINE.

*--- itab für Vorselektion über Genehmigungen -----------------------
DATA: BEGIN OF g_sogen_object OCCURS 10,
        objnr LIKE equi-objnr,
      END OF g_sogen_object.
*--- Auswahltabelle für Ampelfunktion -------------------------------
DATA: BEGIN OF g_monitor_tab OCCURS 5,
       counter  LIKE rihea-pm_selfield,
       textline LIKE rihea-pm_reffield,
       fieldname LIKE dfies-fieldname,
      END OF g_monitor_tab.
*--- Feld für Ampelfunktion -----------------------------------------
DATA: g_monitor_field LIKE dfies-fieldname.
*--- Prioritätsarten ------------------------------------------------
DATA: BEGIN OF t_t356 OCCURS 0.
        INCLUDE STRUCTURE t356.
DATA:   color(1),
      END OF t_t356.
DATA: t_t350   LIKE t350 OCCURS 10 WITH HEADER LINE.
DATA g_bor_tab LIKE borident OCCURS 0 WITH HEADER LINE.

DATA: device LIKE itcpp-tddevice.
*--- Logisches System (Pagingstatus)
DATA g_logsys LIKE borident-logsys.


* for list box

DATA: lt_vrm_values TYPE TABLE OF vrm_value.
DATA: wa_vrm_values TYPE vrm_value.

DATA: lt_vrm_values1 TYPE TABLE OF vrm_value. "for ascen/descen
DATA: wa_vrm_values1 TYPE vrm_value.  " for ascen/descen

*for sorting

DATA : sorttab TYPE esp6_sortfield_tab_type WITH HEADER LINE.


*eject
*-------------------------------------------------------------------*
* INCLUDES                                                          *
*-------------------------------------------------------------------*
INCLUDE miolxtop.
*--- itabs für prefetch Bezeichungen Stammdaten
DATA: g_equnr_tab TYPE irep1_equnr_wa OCCURS 100 WITH HEADER LINE.
DATA: g_tplnr_tab TYPE irep1_tplnr_wa OCCURS 100 WITH HEADER LINE.
DATA: g_matnr_tab TYPE irep1_matnr_wa OCCURS 100 WITH HEADER LINE.
DATA: g_ihpap_tab TYPE irep1_ihpa_wa  OCCURS 100 WITH HEADER LINE.
*eject
*####################################################################*
* Selektionsbild                                                     *
*####################################################################*
*ENHANCEMENT-POINT riaufk20_02 SPOTS es_riaufk20 STATIC.

* sunil sorting criteria

SELECTION-SCREEN BEGIN OF BLOCK sort
                 WITH FRAME
                 TITLE text006.
SELECTION-SCREEN BEGIN OF LINE.

SELECTION-SCREEN COMMENT 1(30)  text1.
SELECTION-SCREEN COMMENT 32(10) text2.
SELECTION-SCREEN COMMENT 43(10) text3.
SELECTION-SCREEN COMMENT 56(50) text4.

SELECTION-SCREEN END OF LINE.

SELECTION-SCREEN SKIP 1.

SELECTION-SCREEN BEGIN OF LINE.

SELECTION-SCREEN COMMENT 1(30) text5.
PARAMETER p_auart AS LISTBOX VISIBLE LENGTH 10.  " order type
PARAMETER p1_auart AS LISTBOX VISIBLE LENGTH 10.  " ascending or descending

SELECT-OPTIONS s_auart FOR viaufkst-auart VISIBLE LENGTH 10 NO INTERVALS .

SELECTION-SCREEN END OF LINE.

SELECTION-SCREEN BEGIN OF LINE.

SELECTION-SCREEN COMMENT 1(30) text6.
PARAMETER p_gstrp AS LISTBOX VISIBLE LENGTH 10.  " basic start date
PARAMETER p1_gstrp AS LISTBOX VISIBLE LENGTH 10.  " basic start date

SELECT-OPTIONS s_gstrp FOR viaufkst-gstrp NO INTERVALS .

SELECTION-SCREEN END OF LINE.

SELECTION-SCREEN BEGIN OF LINE.

SELECTION-SCREEN COMMENT 1(30) text7.
PARAMETER p_priok AS LISTBOX VISIBLE LENGTH 10.  " priority
PARAMETER p1_priok AS LISTBOX VISIBLE LENGTH 10.  " priority

SELECT-OPTIONS s_priok FOR viaufkst-priok NO INTERVALS .

SELECTION-SCREEN END OF LINE.

SELECTION-SCREEN BEGIN OF LINE.

SELECTION-SCREEN COMMENT 1(30) text8.
PARAMETER p_revnr AS LISTBOX VISIBLE LENGTH 10.  " rivision code
PARAMETER p1_revnr AS LISTBOX VISIBLE LENGTH 10.  " rivision code

SELECT-OPTIONS s_revnr FOR viaufkst-revnr NO INTERVALS .

SELECTION-SCREEN END OF LINE.

SELECTION-SCREEN BEGIN OF LINE.

SELECTION-SCREEN COMMENT 1(30) text9.
PARAMETER p_sttxt AS LISTBOX VISIBLE LENGTH 10.  " sytem status
PARAMETER p1_sttxt AS LISTBOX VISIBLE LENGTH 10.  " sytem status

SELECT-OPTIONS s_sttxt FOR object_tab-sttxt NO INTERVALS .

SELECTION-SCREEN END OF LINE.

SELECTION-SCREEN BEGIN OF LINE.

SELECTION-SCREEN COMMENT 1(30) text10.
PARAMETER p_ustxt AS LISTBOX VISIBLE LENGTH 10.  " user status
PARAMETER p1_ustxt AS LISTBOX VISIBLE LENGTH 10.  " user status

SELECT-OPTIONS s_ustxt FOR object_tab-ustxt NO INTERVALS .

SELECTION-SCREEN END OF LINE.


SELECTION-SCREEN BEGIN OF LINE.

SELECTION-SCREEN COMMENT 1(30) text11.
PARAMETER p_ilart AS LISTBOX VISIBLE LENGTH 10.  " Maintanance acitivy stype
PARAMETER p1_ilart AS LISTBOX VISIBLE LENGTH 10.  " Maintanance acitivy stype

SELECT-OPTIONS s_ilart FOR viaufkst-ilart NO INTERVALS .

SELECTION-SCREEN END OF LINE.


SELECTION-SCREEN BEGIN OF LINE.

SELECTION-SCREEN COMMENT 1(30) text12.
PARAMETER p_ingpr AS LISTBOX VISIBLE LENGTH 10.  " Planner group
PARAMETER p1_ingpr AS LISTBOX VISIBLE LENGTH 10.  " Planner group

SELECT-OPTIONS s_ingpr FOR viaufkst-ingpr NO INTERVALS .

SELECTION-SCREEN END OF LINE.


SELECTION-SCREEN BEGIN OF LINE.

SELECTION-SCREEN COMMENT 1(30) text13.
PARAMETER p_gstri AS LISTBOX VISIBLE LENGTH 10.  " Actual start date
PARAMETER p1_gstri AS LISTBOX VISIBLE LENGTH 10.  " Actual start date

SELECT-OPTIONS s_gstri FOR viaufkst-gstri NO INTERVALS .

SELECTION-SCREEN END OF LINE.

SELECTION-SCREEN END OF BLOCK sort.


* end of sorting  criteria.



*--- Select-options für allgmeine Auftragsdaten ------------------*
SELECTION-SCREEN BEGIN OF BLOCK riaufk20_2 WITH FRAME TITLE text-f01.
PARAMETERS: dy_obl LIKE rihea-dy_obl.
SELECT-OPTIONS:
lead_auf   FOR   viaufkst-lead_aufnr  MATCHCODE OBJECT ordp          ,
maufnr     FOR   viaufkst-maufnr      MATCHCODE OBJECT ordp          ,
iwerk      FOR   caufvd-iwerk                                        ,
priok      FOR   viaufkst-priok                                      ,
ernam      FOR   viaufkst-ernam       MATCHCODE OBJECT user_addr     ,
erdat      FOR   viaufkst-erdat                                      ,
stai1      FOR      rihea-i_astatin   MATCHCODE OBJECT i_status      ,
stae1      FOR      rihea-i_astatex   DEFAULT 'NMAT' MATCHCODE OBJECT i_status      ,
ktext      FOR   viaufkst-ktext                                      ,
aenam      FOR   viaufkst-aenam       MATCHCODE OBJECT user_addr     ,
aedat      FOR   viaufkst-aedat                                      ,
anlbd      FOR   viaufkst-anlbd                                      ,
gstrp      FOR   viaufkst-gstrp                                      ,
gltrp      FOR   viaufkst-gltrp                                      ,
warpl      FOR   viaufkst-warpl      MATCHCODE OBJECT mpla           ,
wapos      FOR   viaufkst-wapos                                      ,
revnr      FOR   viaufkst-revnr                                      ,
pspel      FOR       prps-posid      MATCHCODE OBJECT prpm           ,
kostv      FOR   viaufkst-kostv                                      ,
gltrs      FOR   viaufkst-gltrs                                      ,
ftrmi      FOR   viaufkst-ftrmi                                      ,
getri      FOR   viaufkst-getri                                      ,
gstri      FOR   viaufkst-gstri                                      ,
gstrs      FOR   viaufkst-gstrs                                      ,
*egauzt     for    rihaufk-egauzt                                     ,
anlvd      FOR   viaufkst-anlvd                                      ,
plnnr      FOR   viaufkst-plnnr      MATCHCODE OBJECT plks           ,
plnal      FOR   viaufkst-plnal                                      ,
plknz      FOR   viaufkst-plknz                                      ,
bautl      FOR   viaufkst-bautl      MATCHCODE OBJECT mat1           .
SELECTION-SCREEN END OF BLOCK riaufk20_2.
*--- Select-options für Standort und Kontierungsdaten ----------------*
SELECTION-SCREEN BEGIN OF BLOCK riaufk20_3 WITH FRAME TITLE text-f02.
SELECT-OPTIONS:
swerk      FOR   viaufkst-swerk                                      ,
ilart      FOR   viaufkst-ilart                                      ,
arbpl      FOR    rihaufk-arbpl      MATCHCODE OBJECT cram           ,
kostl      FOR   viaufkst-kostl      MATCHCODE OBJECT kost           ,
proid      FOR   prps-posid          MATCHCODE OBJECT prpm,
aufnt      FOR   viaufkst-aufnt      MATCHCODE OBJECT auko,
vorue      FOR   rihaufk-vorue                         ,
adpsp      FOR   viaufkst-adpsp                                      ,
kdauf      FOR   viaufkst-kdauf      MATCHCODE OBJECT vmva,
kdpos      FOR   viaufkst-kdpos                         ,
vkorg      FOR   viaufkst-vkorg                         ,
vtweg      FOR   viaufkst-vtweg                         ,
spart      FOR   viaufkst-spart                         ,
gsber      FOR   viaufkst-gsber                                      ,
bukrs      FOR   viaufkst-bukrs                                      ,
anlnr      FOR   viaufkst-anlnr      MATCHCODE OBJECT aanl           ,
beber      FOR   viaufkst-beber                                      ,
stort      FOR   viaufkst-stort                                      ,
eqfnr      FOR   viaufkst-eqfnr                                      ,
abckz      FOR   viaufkst-abckz                                      ,
ingpr      FOR   viaufkst-ingpr                                      ,
msgrp      FOR   viaufkst-msgrp                                      ,
aufpl      FOR   viaufkst-aufpl                                      ,
plgrp      FOR   viaufkst-plgrp                                      ,
kunum      FOR   viaufkst-kunum      MATCHCODE OBJECT debi           ,
gesist     FOR   rihaufk-gesist                                      ,
gespln     FOR   rihaufk-gespln                                      ,
sogen      FOR      ihsg-pmsog                                       ,
prctr      FOR    caufvd-prctr                                       .
SELECTION-SCREEN END OF BLOCK riaufk20_3.

SELECTION-SCREEN BEGIN OF BLOCK riaufk20_4 WITH FRAME TITLE text-son.
SELECT-OPTIONS: pagestat FOR rihaufk_list-pagestat MODIF ID pag.
PARAMETERS: variant LIKE disvariant-variant.
PARAMETERS: monitor LIKE rihea-pm_selfield.
SELECTION-SCREEN END OF BLOCK riaufk20_4.




*--- Select-options für Abrechungsempfänger --------------------------*
SELECTION-SCREEN BEGIN OF SCREEN 100 AS WINDOW TITLE text-f09.
SELECTION-SCREEN BEGIN OF BLOCK riaufk20_6 WITH FRAME TITLE text-f09.
PARAMETERS:     abkonty LIKE cobrb-konty.
SELECT-OPTIONS: abkostl FOR cobrb-kostl MATCHCODE OBJECT kost,
                abaufnr FOR cobrb-aufnr MATCHCODE OBJECT orde,
                abkstrg FOR cobrb-kstrg MATCHCODE OBJECT kkpk,
                abpspnr FOR prps-posid  MATCHCODE OBJECT prpm,
                abnplnr FOR cobrb-nplnr MATCHCODE OBJECT auko,
                abkdauf FOR cobrb-kdauf MATCHCODE OBJECT vmva,
                abkdpos FOR cobrb-kdpos,
                abhkont FOR cobrb-hkont MATCHCODE OBJECT sako,
                abgsber FOR cobrb-gsber,
                abanln1 FOR cobrb-anln1 MATCHCODE OBJECT aanl,
                abanln2 FOR cobrb-anln2,
                abmatnr FOR cobrb-matnr MATCHCODE OBJECT mat1.

*--- select option for RealEstate
SELECTION-SCREEN BEGIN OF BLOCK riaufk20_6a WITH FRAME TITLE text-f11.
INCLUDE ifviexso.
SELECTION-SCREEN END OF BLOCK riaufk20_6a.

SELECTION-SCREEN END OF BLOCK riaufk20_6.
SELECTION-SCREEN END OF SCREEN 100.

*--- Select-options für Fertigungshilfsmittel ----------------------*
SELECTION-SCREEN BEGIN OF SCREEN 200 AS WINDOW TITLE text-f04.
SELECTION-SCREEN BEGIN OF BLOCK riaufk20_7 WITH FRAME  TITLE text-f04.
SELECT-OPTIONS: s_sfhnr FOR crfhd-sfhnr MATCHCODE OBJECT fhms,
                s_matnr FOR crfhd-matnr MATCHCODE OBJECT mat1,
                s_werks FOR crfhd-fhwrk,
                s_doknr FOR crfhd-doknr MATCHCODE OBJECT cv01,
                s_dokar FOR crfhd-dokar,
                s_doktl FOR crfhd-doktl,
                s_dokvr FOR crfhd-dokvr,
                s_equnr FOR crfhd-equnr MATCHCODE OBJECT equi.
PARAMETERS: p_loekz AS CHECKBOX DEFAULT 'X'.
SELECTION-SCREEN END OF BLOCK riaufk20_7.
SELECTION-SCREEN END OF SCREEN 200.
*ENHANCEMENT-POINT riaufk20_25 SPOTS es_riaufk20 STATIC .

*ENHANCEMENT-POINT riaufk20_20 SPOTS es_riaufk20.

*####################################################################*
*Ranges
*####################################################################*
RANGES: object   FOR object_tab-aufnr,
        i_equnr  FOR object_tab-equnr,
        i_tplnr  FOR object_tab-tplnr,
        i_bautl  FOR object_tab-bautl,
        i_gewrk  FOR viaufkst-gewrk,
        i_ppsid  FOR viaufkst-ppsid,
        i_iphas  FOR viaufkst-iphas,
        i_proid  FOR viaufkst-proid,
        i_pspel  FOR viaufkst-pspel,
        gr_proid_all FOR viaufkst-proid,
        gr_pspel_all FOR viaufkst-pspel,
        i_aufnr  FOR viaufkst-aufnr,
        i_owner  FOR viaufkst-owner,
        gr_date  FOR sy-datum.

*---Selektionstabelle für Hikola
DATA g_selfields_tab_hiko LIKE g_selfields_tab
                          OCCURS 0 WITH HEADER LINE.
*-------------------------------------------------------------------*
* Datenfelder für Einheitenkonvertierung                            *
*-------------------------------------------------------------------*
DATA: g_emaueh     LIKE viaufkst-gaueh.
DATA: g_imaueh     LIKE viaufkst-gaueh.
DATA: g_answer.
DATA: g_kost_flag.
DATA: g_sttxt_flag.
DATA: g_arbpl_flag.
DATA: g_gewrk_flag.
DATA: g_egauzt_flag.
DATA: g_stasl_flag.
DATA: g_eqktx_flag.
DATA: g_pltxt_flag.
DATA: g_adres_flag.
DATA: g_maktx_flag.
DATA: g_vorue_flag.
DATA: g_fhm_flag.
DATA: g_pmsdo_flag.
DATA: g_variant_flag.
DATA: g_page_flag.
DATA: g_page_active.
DATA: g_priokx_flag.
DATA: g_crhd_flag.
DATA: g_statbuf_flag.
*--- Max.Anzahl Treffer für Prefetch Partner
DATA: g_par_dbcnt LIKE sy-dbcnt VALUE 2000.
*--- Hilfsflags für Objektlistenselektion -------------------------*
DATA: g_flag1.
DATA: g_flag2.
*--- Hilfsflag für Auftragsabschluß ------------------------------*
DATA: xclnot.
*--- Globles Feld für SY-Ucomm -----------------------------------*
DATA: g_ucomm LIKE sy-ucomm.
*--- VCI local table for bal
DATA: lt_msg TYPE bal_t_msg WITH HEADER LINE.

*-------------------------------------------------------------------*
* WPS fields                                                        *
*-------------------------------------------------------------------*
DATA: gr_ex_wps TYPE REF TO if_ex_wps_connection,
      gv_wps_ini.

PARAMETERS:
  dy_selm DEFAULT '0' NO-DISPLAY,
  dy_tcode LIKE sy-tcode NO-DISPLAY,
  dy_msgty LIKE sy-msgty DEFAULT 'I' NO-DISPLAY.

*--- Drucktasten auf Selektionsbild F-codes zuordnen ---------------*
SELECTION-SCREEN FUNCTION KEY 1.
SELECTION-SCREEN FUNCTION KEY 2.

*eject
*---------------------------------------------------------------------
* Initialization
*---------------------------------------------------------------------
INITIALIZATION.

*--- Drucktasten auf Selektionsbild Texte zuordnen ------------------
  sscrfields-functxt_01 = 'Abrechungsempfänger  '(f09).
  sscrfields-functxt_02 = 'Fertigungshilfsmittel'(f10).
*--- SAPPHONE aktiv -------------------------------------------------
  PERFORM check_sapphone_aktive_f14.
*--- Paging aktiv?
  PERFORM prepare_selection_paging_f19.
*--- Aktivitätstyp bestimmen -----------------------------------------
  PERFORM determine_acttype_aufk_l.
*--- Auswahltabelle für Monitorfunktion -----------------------------
  PERFORM create_monitor_tab_l.

  PERFORM variant_start_f16.

*--- BADI IWOC_LIST_TUNING active?
  PERFORM is_badi_active_f69 USING g_badi_list_tuning_ref
                                   g_badi_list_tuning_act
                                   g_badi_list_tuning_ini
                                   'IWOC_LIST_TUNING'.

*--- BADI IWO_MASS_CHANGE active?
  PERFORM is_iwo_mass_badi_active_f71 CHANGING
                                        g_badi_iwo_mass_change_ref
                                        g_badi_mass_change_act
                                        g_badi_mass_change_ini.

  g_second_value = 'GESIST'.
  g_port_title1 = 'Hohe Anzahl, hohe Kosten'(po1).
  g_port_title2 = 'Niedrige Anzahl, hohe Kosten'(po2).
  g_port_title3 = 'Hohe Anzahl, niedrige Kosten'(po3).
  g_port_title4 = 'Niedrige Anzahl, niedrige Kosten'(po4).
  g_port_value_text = 'Istkosten'(p05).
  g_key = 'AUFNR'.
  g_text = 'KTEXT'.
*ENHANCEMENT-POINT riaufk20_07 SPOTS es_riaufk20.


  PERFORM sorting_selection.


*eject
*---------------------------------------------------------------------
* AT SELECTION_SCREEN-output
*---------------------------------------------------------------------
AT SELECTION-SCREEN OUTPUT.
*--- Paging aktiv/inaktiv Screen modifzieren ------------------------
  PERFORM check_screen_paging_f19.
  PERFORM init_selection_screen_f16.
*--- Listvariante initialisieren ------------------------------------
  PERFORM variant_init_l.
*--- defaultvariante fürs Selektionsbild ermitteln ------------------
*--- Wegen Parameterübergabe Aufruf im PBO, über Flag nur einmal ----
  IF variant IS INITIAL AND
    g_variant_flag IS INITIAL.
    PERFORM get_default_variant_f14 USING variant.
    g_variant_flag = g_x.


  ENDIF.

*--- Control visibility of WPS fields (PM/PS reference element)
  PERFORM wps_field_control.

*--- change Real Estate fields in settlement receivers screen
  IF sy-dynnr = '0100'.
    PERFORM re_modif_selection_screen.
  ENDIF.

*ENHANCEMENT-SECTION     riaufk20_03 SPOTS es_riaufk20.
  LOOP AT SCREEN.
    IF screen-name = 'DY_MAB' OR screen-name = 'DY_HIS'
        OR screen-name = 'SELSCHEM' OR screen-name = 'DY_ADRFL'
          OR screen-name = 'P_ADDR' OR screen-name = 'AD_ICON'
             OR screen-name =  '%F004009_1000' OR screen-name =  '%F005010_1000'.
      screen-active = 0.
      MODIFY SCREEN.
    ENDIF.
  ENDLOOP.

    LOOP AT SCREEN.
    IF screen-group1 = 'ISU'.
      screen-active = 0.
      MODIFY SCREEN.
    ENDIF.
  ENDLOOP.


PERFORM listboxes.

*END-ENHANCEMENT-SECTION.
*eject
*---------------------------------------------------------------------
* AT SELECTION_SCREEN
*---------------------------------------------------------------------
AT SELECTION-SCREEN.

 IF ( p1_auart IS NOT INITIAL AND s_auart IS NOT INITIAL ) OR
    ( p1_gstrp IS NOT INITIAL AND s_gstrp IS NOT INITIAL ) OR
    ( p1_priok IS NOT INITIAL AND s_priok IS NOT INITIAL ) OR
    ( p1_revnr IS NOT INITIAL AND s_revnr IS NOT INITIAL ) OR
    ( p1_sttxt IS NOT INITIAL AND s_sttxt IS NOT INITIAL ) OR
    ( p1_ustxt IS NOT INITIAL AND s_ustxt IS NOT INITIAL ) OR
    ( p1_ilart IS NOT INITIAL AND s_ilart IS NOT INITIAL ) OR
    ( p1_ingpr IS NOT INITIAL AND s_ingpr IS NOT INITIAL ) OR
    ( p1_gstri IS NOT INITIAL AND s_gstri IS NOT INITIAL ).

   MESSAGE e000(zz) WITH ' Select either Asc/Desc or Priority Values'.


 ENDIF.



*--- Select-options für FHM und Abrechung auf separatem screen ------*
  CASE sscrfields-ucomm.
    WHEN 'FC01'.
      CLEAR sscrfields-ucomm.
      CALL SELECTION-SCREEN 100.
    WHEN 'FC02'.
      CLEAR sscrfields-ucomm.
      CALL SELECTION-SCREEN 200.
  ENDCASE.
*--- Mindestens ein Bearbeitungsstatus markiert ? -------------------*
  IF sy-dynnr = '1000'.
    IF dy_ofn IS INITIAL AND
       dy_iar IS INITIAL AND
       dy_mab IS INITIAL AND
       dy_his IS INITIAL.
      SET CURSOR FIELD dy_ofn.
      MESSAGE e041.
    ENDIF.
*ENHANCEMENT-POINT riaufk20_04 SPOTS es_riaufk20.
*--- Selektionbild bei Objektlistenselektion prüfen ----------------*
    IF NOT dy_obl IS INITIAL.
      PERFORM check_screen_objlist_l.
    ENDIF.
*--- Datumsprüfung                                               "788761
    IF datub >= datuv.                                      "788761
    ELSE.                                                   "788761
      MESSAGE e884(ih) WITH datuv datub.                    "788761
    ENDIF.                                                  "788761
*--- immer Defaultvariante nehmen, da ALV-GRID diese immer nimmt
    IF variant IS INITIAL.
      PERFORM get_default_variant_f14 USING variant.
    ENDIF.
*--- Korrekte Listvariante ausgewählt ? -----------------------------*
    PERFORM variant_existence_f14 USING variant.
  ENDIF.
*eject
*--------------------------------------------------------------------*
* at selection-screen on value-request for abkonty
*--------------------------------------------------------------------*
AT SELECTION-SCREEN ON VALUE-REQUEST FOR abkonty.
  CALL FUNCTION 'HELP_REQUEST_FOR_OBART'
    EXPORTING
      fieldname                = 'KONTY'
      tabname                  = 'COBRB'
      settlement_receiver_only = 'X'
    IMPORTING
      select_value             = abkonty.

*---------------------------------------------------------------------
*--- F4 Eingabehilfe für Listvariante
*---------------------------------------------------------------------
AT SELECTION-SCREEN ON VALUE-REQUEST FOR variant.
  PERFORM variant_inputhelp_f14 USING variant.
*---------------------------------------------------------------------
*--- F4 Eingabehilfe für Monitorfunktion (Bezugsgröße für Ampel)
*---------------------------------------------------------------------
AT SELECTION-SCREEN ON VALUE-REQUEST FOR monitor.
  PERFORM monitor_inputhelp_l USING monitor.

*---------------------------------------------------------------------
*--- F4 Eingabehilfe für Revisionsnummer -----------------------------
*---------------------------------------------------------------------
AT SELECTION-SCREEN ON VALUE-REQUEST FOR revnr-low.
  PERFORM help_f4_revnr_l USING revnr-low.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR revnr-high.
  PERFORM help_f4_revnr_l USING revnr-high.

*---------------------------------------------------------------------
* AT SELECTION SCREEN
*---------------------------------------------------------------------
AT SELECTION-SCREEN ON p_revnr.
 check not p_revnr is initial.
  IF ( p_revnr = p_priok ) OR
     ( p_revnr = p_auart ) OR
     ( p_revnr = p_gstrp ) OR
     ( p_revnr = p_sttxt ) OR
     ( p_revnr = p_ustxt ) OR
     ( p_revnr = p_ilart ) OR
     ( p_revnr = p_ingpr ) OR
     ( p_revnr = p_gstri ).
     MESSAGE 'Two or more items with the same sort sequence number' TYPE 'I'.
     STOP.
  ENDIF.

AT SELECTION-SCREEN ON p_priok.
 check not p_priok is initial.
  IF ( p_priok = p_revnr ) OR
     ( p_priok = p_auart ) OR
     ( p_priok = p_gstrp ) OR
     ( p_priok = p_sttxt ) OR
     ( p_priok = p_ustxt ) OR
     ( p_priok = p_ilart ) OR
     ( p_priok = p_ingpr ) OR
     ( p_priok = p_gstri ).
     MESSAGE 'Two or more items with the same sort sequence number' TYPE 'I'.
     STOP.
  ENDIF.

AT SELECTION-SCREEN ON p_auart.
 check not p_auart is initial.

  IF ( p_auart = p_revnr ) OR
     ( p_auart = p_priok ) OR
     ( p_auart = p_gstrp ) OR
     ( p_auart = p_sttxt ) OR
     ( p_auart = p_ustxt ) OR
     ( p_auart = p_ilart ) OR
     ( p_auart = p_ingpr ) OR
     ( p_auart = p_gstri ).
     MESSAGE 'Two or more items with the same sort sequence number' TYPE 'I'.
     STOP.
  ENDIF.

AT SELECTION-SCREEN ON p_gstrp.
 check not p_gstrp is initial.

  IF ( p_gstrp = p_revnr ) OR
     ( p_gstrp = p_priok ) OR
     ( p_gstrp = p_auart ) OR
     ( p_gstrp = p_sttxt ) OR
     ( p_gstrp = p_ustxt ) OR
     ( p_gstrp = p_ilart ) OR
     ( p_gstrp = p_ingpr ) OR
     ( p_gstrp = p_gstri ).
     MESSAGE 'Two or more items with the same sort sequence number' TYPE 'I'.
     STOP.
  ENDIF.

AT SELECTION-SCREEN ON p_sttxt.
 check not p_sttxt is initial.

  IF ( p_sttxt = p_revnr ) OR
     ( p_sttxt = p_priok ) OR
     ( p_sttxt = p_auart ) OR
     ( p_sttxt = p_gstrp ) OR
     ( p_sttxt = p_ustxt ) OR
     ( p_sttxt = p_ilart ) OR
     ( p_sttxt = p_ingpr ) OR
     ( p_sttxt = p_gstri ).
     MESSAGE 'Two or more items with the same sort sequence number' TYPE 'I'.
     STOP.
  ENDIF.

AT SELECTION-SCREEN ON p_ustxt.
 check not p_ustxt is initial.

  IF ( p_ustxt = p_revnr ) OR
     ( p_ustxt = p_priok ) OR
     ( p_ustxt = p_auart ) OR
     ( p_ustxt = p_gstrp ) OR
     ( p_ustxt = p_sttxt ) OR
     ( p_ustxt = p_ilart ) OR
     ( p_ustxt = p_ingpr ) OR
     ( p_ustxt = p_gstri ).
     MESSAGE 'Two or more items with the same sort sequence number' TYPE 'I'.
     STOP.
  ENDIF.

AT SELECTION-SCREEN ON p_ilart.
 check not p_ilart is initial.

  IF ( p_ilart = p_revnr ) OR
     ( p_ilart = p_priok ) OR
     ( p_ilart = p_auart ) OR
     ( p_ilart = p_gstrp ) OR
     ( p_ilart = p_sttxt ) OR
     ( p_ilart = p_ustxt ) OR
     ( p_ilart = p_ingpr ) OR
     ( p_ilart = p_gstri ).
     MESSAGE 'Two or more items with the same sort sequence number' TYPE 'I'.
     STOP.
  ENDIF.

AT SELECTION-SCREEN ON p_ingpr.
 check not p_ingpr is initial.

  IF ( p_ingpr = p_revnr ) OR
     ( p_ingpr = p_priok ) OR
     ( p_ingpr = p_auart ) OR
     ( p_ingpr = p_gstrp ) OR
     ( p_ingpr = p_sttxt ) OR
     ( p_ingpr = p_ustxt ) OR
     ( p_ingpr = p_ilart ) OR
     ( p_ingpr = p_gstri ).
     MESSAGE 'Two or more items with the same sort sequence number' TYPE 'I'.
     STOP.
  ENDIF.

AT SELECTION-SCREEN ON p_gstri.
 check not p_gstri is initial.

  IF ( p_gstri = p_revnr ) OR
     ( p_gstri = p_priok ) OR
     ( p_gstri = p_auart ) OR
     ( p_gstri = p_gstrp ) OR
     ( p_gstri = p_sttxt ) OR
     ( p_gstri = p_ustxt ) OR
     ( p_gstri = p_ilart ) OR
     ( p_gstri = p_ingpr ).
     MESSAGE 'Two or more items with the same sort sequence number' TYPE 'I'.
     STOP.
  ENDIF.


*eject
*---------------------------------------------------------------------
* START-OF-SELECTION
*---------------------------------------------------------------------
START-OF-SELECTION.
*--- Datumsrange aufbauen
  PERFORM create_date_range_f67 TABLES gr_date
                                USING  datuv datub.
*--- Feldkatalog aufbauen -------------------------------------------
  PERFORM create_fieldcat_f14 USING 'RIHAUFK_LIST'.
  PERFORM create_fieldgroups_l.
*--- Aktivitätstyp bestimmen -----------------------------------------
  PERFORM determine_g_tcode_f16.
  PERFORM determine_acttype_aufk_l.
*--- Select-option sichern da interen Manipulation möglich -----------*
  i_aufnr[] = aufnr[].

  REFRESH sel_tab.
  PERFORM export_seltab_mem_f16.

  PERFORM check_sel_fhm_l.
*--- Allgem. Einstellungen für Listviewer ----------------------------
  PERFORM prepare_display_list_f14.
*--- zusätzliche Einstelltung wenn Monitor aktiv ---------------------
  PERFORM check_monitor_input_l.
*--- ausgewählte Listfelder ermitteln für dynamischen select ---------
  PERFORM update_fieldcat_variant_f14.
*--- bei submit kann Feldcatalog auch importiert werden --------------
  IF NOT sy-calld IS INITIAL.
    PERFORM import_fieldcat_f14.
  ENDIF.
  PERFORM check_fieldcat_variant_l.
*--- Auftragsartentabelle lesen
  PERFORM select_t350_l.
*ENHANCEMENT-POINT riaufk20_05 SPOTS es_riaufk20.
*--- Datenbankselektion ----------------------------------------------
  PERFORM selection_l.


* new atp check logic
  PERFORM atpcheck.
* end of new atp check logic

*eject
*---------------------------------------------------------------------
* END-OF-SELECTION
*---------------------------------------------------------------------
END-OF-SELECTION.

  g_ucomm = 'IHKZ'.
*--- Da Monitor möglich kein ALV A Puffer !!!
  CLEAR g_alv_buffer.
*--- Liste ausgeben --------------------------------------------------*
  PERFORM display_list_f14 USING g_ucomm.

*---------------------------------------------------------------------*
*       FORM USER_COMMAND_L                                           *
*---------------------------------------------------------------------*
*       will be called out of listviewer                              *
*---------------------------------------------------------------------*
*  -->  P_UCOMM                                                       *
*  -->  P_SELFIELD                                                    *
*---------------------------------------------------------------------*
FORM user_command_l USING p_ucomm LIKE sy-ucomm
                          p_selfield TYPE slis_selfield.

*--- data definition
  DATA: l_ind_link_mplan(1) TYPE c,
        l_answer(1)         TYPE c.
*ENHANCEMENT-POINT RIAUFK20_REV_03 SPOTS ES_RIAUFK20 STATIC .

  PERFORM set_p_selfield_general_f16 USING p_selfield.

  p_selfield-refresh = g_s.
  g_index = p_selfield-tabindex.

*--- pf2 umbiegen je nach modus (Auswählen/Anzeigen) ---------------
  PERFORM check_pf2_with_object_f16 USING p_ucomm.

*--- Fcode umbiegen bei Doppelcklick auf Auftragsnummer oder text --
  PERFORM check_object_display_f16 USING p_ucomm
                                         p_selfield
                                         'OBJECT_TAB-AUFNR'
                                         'IHKZ'.
  PERFORM check_object_display_f16 USING p_ucomm
                                         p_selfield
                                         'OBJECT_TAB-KTEXT'
                                         'IHKZ'.
*--- Fcode umbiegen bei Doppelcklick auf Meldungsnummer oder text --
  PERFORM check_object_display_f16 USING p_ucomm
                                         p_selfield
                                         'OBJECT_TAB-QMNUM'
                                         'QMEL'.

  CASE p_ucomm.
    WHEN g_ol0.
*--- Aktuelle Feldauswahl ändern -------------------------------------
      PERFORM refresh_l USING p_selfield.
    WHEN g_olx.
*--- Feldauswahl ändern ---------------------------------------------
      PERFORM refresh_l USING p_selfield.
    WHEN g_oad.
*--- Feldauswahl auswählen ------------------------------------------
      PERFORM refresh_l USING p_selfield.
    WHEN g_lis.
*--- Grundliste aufbauen --------------------------------------------
      PERFORM refresh_l USING p_selfield.
*   when g_eta.
*--- Quickinfo einblenden -------------------------------------------
*     perform select_for_quickinfo_l using p_selfield.
    WHEN 'AKTU'.
*--- Auffrischen ----------------------------------------------------
      p_selfield-refresh = g_x.
      PERFORM selection_l.
    WHEN 'IOBJ'.
*--- Objektstammsatz anzeigen ---------------------------------------
      PERFORM check_object_tab_marked_f14 USING p_ucomm
                                                p_selfield.
      MOVE-CORRESPONDING object_tab TO rihaufk.
      MOVE-CORRESPONDING object_tab TO rihaufk_list.
      PERFORM master_data_f16 USING p_ucomm
                                    p_selfield.
*--- Wegen doppelclick sicherstellen das F-Code nicht zweimal -------
      CLEAR p_ucomm.
    WHEN 'LIDO'.
*--- Download Auftrag plus Umfeld -----------------------------------
      PERFORM prepare_download_f16.
      PERFORM fcodes_with_mark_f16 USING p_ucomm
                                       p_selfield.
      PERFORM finish_download_f16 USING 'O'.

    WHEN 'IGRF'.
*--- Grafik aufrufen ------------------------------------------------
      PERFORM check_object_tab_marked_f14 USING p_ucomm
                                                p_selfield.
      PERFORM grafics_l USING p_selfield.
    WHEN 'EQAZ'.
*--- Equiliste aufrufen ---------------------------------------------
      PERFORM check_object_tab_marked_f14 USING p_ucomm
                                                p_selfield.
      PERFORM display_equi_l.
    WHEN 'MONI'.
*--- Monitor ein/ausschalten
      PERFORM monitor_on_off_l USING p_selfield.
    WHEN 'TPAZ'.
*--- Platzliste aufrufen --------------------------------------------
      PERFORM check_object_tab_marked_f14 USING p_ucomm
                                                p_selfield.
      PERFORM display_iflo_l.
    WHEN 'BTAZ'.
*--- Materialliste aufrufen -----------------------------------------
      PERFORM check_object_tab_marked_f14 USING p_ucomm
                                                p_selfield.
      PERFORM display_mara_l.
    WHEN 'IHKZ'.
*--- Detail Auftrag -------------------------------------------------
      PERFORM fcodes_with_mark_f16 USING p_ucomm
                                         p_selfield.
    WHEN 'KO22'.
      PERFORM fcodes_with_mark_f16 USING p_ucomm
                                         p_selfield.
    WHEN 'KO23'.
      PERFORM fcodes_with_mark_f16 USING p_ucomm
                                         p_selfield.
    WHEN 'QMEL'.
*--- Meldungsliste ---------------------------------------------------
      PERFORM check_object_tab_marked_f14 USING p_ucomm
                                                p_selfield.
*ENHANCEMENT-SECTION     riaufk20 SPOTS es_riaufk20.
      PERFORM display_qmel_l.
*END-ENHANCEMENT-SECTION.
      CLEAR p_ucomm.
    WHEN 'WABE'.
*--- Warenbewegungen -------------------------------------------------
      PERFORM check_object_tab_marked_f14 USING p_ucomm
                                                p_selfield.
      PERFORM display_wabe_l.
    WHEN 'MUEQ'.
*--- mehrstufige Equiliste ------------------------------------------
      PERFORM check_object_tab_marked_f14 USING p_ucomm
                                                p_selfield.
      PERFORM multi_equi_l.
    WHEN 'MUTP'.
*--- mehrstufige Platzliste -----------------------------------------
      PERFORM check_object_tab_marked_f14 USING p_ucomm
                                                p_selfield.
      PERFORM multi_iflo_l.
    WHEN 'MUQM'.
*--- mehrstufige Meldungsliste --------------------------------------
      PERFORM check_object_tab_marked_f14 USING p_ucomm
                                                p_selfield.
      PERFORM multi_qmel_l.
    WHEN 'MUAU'.
*--- mehrstufige Auftragsliste --------------------------------------
      PERFORM check_object_tab_marked_f14 USING p_ucomm
                                                p_selfield.
      PERFORM multi_aufk_l.
    WHEN 'CONF'.
*--- Sammelrückmeldung ----------------------------------------------
      PERFORM check_object_tab_marked_f14 USING p_ucomm
                                                p_selfield.
      PERFORM display_conf_l.
    WHEN 'CMFU'.
*--- Gesamtrückmeldung -------------------------------------------
      PERFORM fcodes_with_mark_f16 USING p_ucomm
                                         p_selfield.
    WHEN 'AVOL'.
*--- Vorgänge -------------------------------------------------------
      PERFORM check_object_tab_marked_f14 USING p_ucomm
                                                p_selfield.
      PERFORM display_avol_l USING ' '.
    WHEN 'AFRU'.
*--- Rückmeldungen --------------------------------------------------
      PERFORM check_object_tab_marked_f14 USING p_ucomm
                                                p_selfield.
      PERFORM display_afru_l.

    WHEN 'AVOS'.
*--- Vorgänge Sammelerfassung ---------------------------------------
      PERFORM check_object_tab_marked_f14 USING p_ucomm
                                                p_selfield.
      PERFORM display_avol_l USING 'X'.
    WHEN 'AMVK'.
*--- Liste Materialverfügbarkeitsstatus ----------------------------
      PERFORM check_object_tab_marked_f14 USING p_ucomm
                                                p_selfield.
      PERFORM display_amvk_l.
*---- Komponentenübersicht
    WHEN 'IW3L'.
      PERFORM fcodes_with_mark_f16 USING p_ucomm
                                         p_selfield.
*--- Rücknahme Abschluß ---------------------------------------------
    WHEN 'LIRA'.
      PERFORM fcodes_with_mark_f16 USING p_ucomm
                                         p_selfield.
      IF return_code =  0.
        MESSAGE s105(ih).
      ENDIF.
    WHEN g_plt.
*--- Ruf die Plantafel.
      PERFORM create_range_aufnr_plantafel.
      PERFORM call_plantafel.

    WHEN 'PSTU'.
*--- Projekttermine übernehmen Netzvorgang -> Auftragsecktermin ------
      PERFORM fcodes_with_mark_f16 USING p_ucomm
                                         p_selfield.
      IF return_code =  0.
        MESSAGE s095(ih).              " Termine wurden übernommen
      ENDIF.
*--- Auftrag techn. oder kaufm. abschliessen
    WHEN 'LIAR' OR 'LIAB'.
*--- check the selected orders and the included notifications
*    for a maintenance plan link
      PERFORM check_linked_mplan_l USING l_ind_link_mplan
                                         l_answer.
      IF l_ind_link_mplan = 'X' OR
        l_answer = 'A'.
        IF l_answer <> 'A'.
*--- continue with the initialization of the
*    business application log BAL
          PERFORM init_bal.
        ENDIF.
*--- no objects related to maintenance plans
      ELSE.
        CALL FUNCTION 'POPUP_TO_DECIDE'
          EXPORTING
            defaultoption = 'Y'
            textline1     = text-710
            textline2     = text-71a
            textline3     = ' '
            text_option1  = text-714
            text_option2  = text-715
            titel         = text-713
          IMPORTING
            answer        = l_answer.
      ENDIF.
      CASE l_answer.
        WHEN '1'.                      "nur Auftrag abschl.
          CLEAR xclnot.
          PERFORM fcodes_with_mark_f16 USING p_ucomm
                                             p_selfield.
        WHEN '2'.                      "Auftrag u. Meldung
          xclnot = 'X'.
          PERFORM fcodes_with_mark_f16 USING p_ucomm
                                             p_selfield.
        WHEN OTHERS.
          CLEAR xclnot.
          EXIT.
      ENDCASE.
      MESSAGE s140(ih).                "Aufträge bearbeitet.

      PERFORM memory_liar_clear.
*--- sent business application log
      PERFORM commit_bal.

    WHEN 'LIFR'.
*--- Aufträge freigeben ---------------------------------------------
      PERFORM fcodes_with_mark_f16 USING p_ucomm
                                         p_selfield.
      IF return_code =  0.
        MESSAGE s067(ih).              "aufträge freigegeben
      ENDIF.
    WHEN 'PRLT'.
*--- Drucken --------------------------------------------------------
      REFRESH iworkpaper.    " IMPORTANT CLEAR PAPERS before starting
      EXPORT iworkpaper device TO MEMORY ID 'ID_IPRT_PAPERS'.
      PERFORM fcodes_with_mark_f16 USING p_ucomm
                                         p_selfield.
      IF return_code =  0.
        MESSAGE s069(ih).              " aufträge gedruckt
      ENDIF.
    WHEN 'REVS'.                       "set a revsion number
*--- Revision zuordnen ----------------------------------------------
*ENHANCEMENT-SECTION     RIAUFK20_REV_01 SPOTS ES_RIAUFK20.
      CALL FUNCTION 'PM_GET_REVISION_NUMBER'
        IMPORTING
          exp_t352r  = t352r
          user_abort = g_exit_flag.
*END-ENHANCEMENT-SECTION.
      IF g_exit_flag = space.
        EXPORT t352r TO MEMORY ID 'ID_REVS'.
*ENHANCEMENT-POINT RIAUFK20_REV_02 SPOTS ES_RIAUFK20.
        PERFORM fcodes_with_mark_f16 USING p_ucomm
                                           p_selfield.
        IF return_code =  0.
*         MESSAGE s109(ih) WITH t352r-revnr. "Revsion number set "793679
          MESSAGE s136(ih).                                 "793679
        ENDIF.
      ENDIF.
    WHEN 'REVA'.
*--- Termine über Revisionsnummer aktualisieren ---------------------
      PERFORM fcodes_with_mark_f16 USING p_ucomm
                                         p_selfield.
      IF return_code =  0.
        MESSAGE s110(ih).              " Revsion dates actualised
      ENDIF.
    WHEN 'LGTX'.
*--- Langtext anzeigen ----------------------------------------------
      PERFORM fcodes_with_mark_f16 USING p_ucomm
                                         p_selfield.
    WHEN 'PHON'.
*--- Telefonanruf starten -------------------------------------------
      PERFORM fcodes_with_mark_f16 USING p_ucomm
                                         p_selfield.

    WHEN 'DOWN'.
*--- Download Daten nach MS-Access (Sonderlocke Meldung/Auftrag)
      p_selfield-refresh = space.
      PERFORM prepare_data_f_download_l USING p_ucomm
                                              p_selfield.
      PERFORM download_f16.
*--- Create Order Group
    WHEN 'GRUP'.
      PERFORM order_group USING p_ucomm.
*--- Löschen Historischer Aufträge
    WHEN 'DHIK'.
      PERFORM check_object_tab_marked_f14 USING p_ucomm
                                                p_selfield.
      PERFORM delete_hiko_l.
*--- mass change of orders
    WHEN 'MASS'.
      PERFORM call_iwo_mass_badi_f71 TABLES object_tab
                                      USING g_badi_iwo_mass_change_ref
                                            g_badi_mass_change_act
                                   CHANGING p_selfield.
    WHEN OTHERS.
*--- zentrale F-codes für alle Meldungslisten -----------------------
      PERFORM user_command_f16 USING p_ucomm p_selfield.
  ENDCASE.

*--- If list is empty now - leave ALV
  IF object_tab[] IS INITIAL AND g_variant_save NE g_x.
    p_selfield-exit = g_x.
    MESSAGE s047(ih).
  ENDIF.

ENDFORM.                    "user_command_l

*eject
*---------------------------------------------------------------------*
*       FORM SELECTION_L                                              *
*---------------------------------------------------------------------*
*       Aufträge selektieren                                          *
*---------------------------------------------------------------------*
FORM selection_l.

  DATA: h_viaufkst  TYPE TABLE OF viaufkst_iflos ,
        h_hikola    TYPE TABLE OF hikola_iflos.
  DATA: h_ktext     LIKE viaufkst-ktext,
        l_lines     LIKE sy-tabix,
        l_use_aufnr TYPE flag VALUE 'X',
        l_use_fae   TYPE flag.

  RANGES: lr_aufnr      FOR afih-aufnr,
          lr_aufnr_save FOR afih-aufnr.

  FIELD-SYMBOLS: <ls_viaufkst> TYPE viaufkst_iflos,
                 <ls_hikola>   TYPE hikola_iflos.

  CLEAR:
      g_kost_flag,
      g_sttxt_flag,
      g_arbpl_flag,
      g_gewrk_flag,
      g_egauzt_flag,
      g_stasl_flag,
      g_eqktx_flag,
      g_pltxt_flag,
      g_vorue_flag,
      g_adres_flag,
      g_maktx_flag,
      g_priokx_flag,
      g_statbuf_flag,
      g_crhd_flag.

  REFRESH i_iphas.
  REFRESH object_tab.
  REFRESH g_tplnr_tab.
  REFRESH g_equnr_tab.
  REFRESH g_adrnr_sel_tab.
  CLEAR object_tab.
*--- clear all flags for post read data
  PERFORM clear_flags_l.
*--- puffer status initialisieren ----------------------------------
  CALL FUNCTION 'STATUS_BUFFER_REFRESH'.

*--- Save original selection criteria
  lr_aufnr_save[] = aufnr[].

*--- Konvertierungsexit T.P. berücksichtigen ------------------------*
*  perform check_tplnr_f16 tables strno
*                                 tplnr
*                          using  g_x.

*--- Bei Suche nach TPLNR=SPACE Originalview benutzen
  PERFORM use_iflos_view_f65 USING strno[]
                                   g_altern_act
                                   g_use_alt.

*--- selection with PRT
  IF g_fhm_flag = yes.
    CALL FUNCTION 'CF_DB_AUFPL_TO_PRT_READ'
      EXPORTING
        deleted_incl_imp = p_loekz
      TABLES
        r_aufpl          = aufpl
        r_matnr          = s_matnr
        r_werks          = s_werks
        r_equnr          = s_equnr
        r_doknr          = s_doknr
        r_dokar          = s_dokar
        r_dokvr          = s_dokvr
        r_doktl          = s_doktl
        r_sfhnr          = s_sfhnr.
    IF aufpl[] IS INITIAL.
      MESSAGE s047(ih).
      STOP.
    ELSE.
      PERFORM select_aufnr_via_aufpl.
    ENDIF.
  ENDIF.

*--- Soll u.a. über Genehmigungen selektiert werden ---------------*
  PERFORM select_via_sogen_f18 USING '3'.
  PERFORM fill_aufnr_from_sogen_l.
*--- wenn über ILOA-Felder selektiert dann owner füllen wegen index
  PERFORM set_owner_l.
*--- Soll u.a. über Abrechungsempfänger selektiert werden ---------*
  PERFORM select_via_cobrb_l.
*--- Constrain orders selected by notification if links maintained in
*    the WPS cross ref table exist.
  PERFORM select_via_wps_xref.
*--- Update saved order numbers for changes from notif selection
  lr_aufnr_save[] = aufnr[].

*--- Soll über verantw. Arbeitsplatz selektiert werden ---------------*
  PERFORM check_sel_workcenter_f66 TABLES gewrk vawrk i_gewrk
                                   USING  g_crhd_flag 'GEWRK'.
*--- Soll über PPS-Arbeitsplatz selektiert werden ---------------*
  PERFORM check_sel_workcenter_f66 TABLES arbpl swerk i_ppsid
                                   USING  g_crhd_flag 'PPSID'.

*--- Soll u.a. über PSP-Element selektiert werden -----------------*
  PERFORM check_sel_proid_f24 TABLES proid i_proid gr_proid_all
                              USING  'PROID'.
  PERFORM check_sel_proid_f24 TABLES pspel i_pspel gr_pspel_all
                              USING  'PSPEL'.

*--- Soll über Adresse vorselektiert werden? ----------------------*
  IF NOT dy_adrfl IS INITIAL.
    PERFORM read_aufnr_via_adrnr(sapdbafi).
  ENDIF.
*--- Soll über Status inclusive selektiert werden -----------------*
  PERFORM check_sel_stati_l USING g_answer.
  IF g_answer = no.
    EXIT.
  ENDIF.

*--- Welche Sonderverarbeitungen sind erforderlich ? --------------*
*    Ausfalldauer
*  g_egauzt_flag = yes.
  PERFORM dimension_unit_l.

  IF g_selmod <> selmod_d.
    CALL FUNCTION 'SAPGUI_PROGRESS_INDICATOR'
      EXPORTING
        percentage = 20
        text       = 'Auftragsselektion'(207).
  ENDIF.
*--- Statusabgrenzung in Selektionstabelle eintragen ---------------
  IF NOT dy_ofn IS INITIAL.
    CLEAR i_iphas.
    i_iphas-option = 'EQ'.
    i_iphas-sign   = 'I'.
    i_iphas-low    = '0'.
    APPEND i_iphas.
  ENDIF.
  IF NOT dy_iar IS INITIAL.
    CLEAR i_iphas.
    i_iphas-option = 'EQ'.
    i_iphas-sign   = 'I'.
    i_iphas-low    = '2'.
    APPEND i_iphas.
  ENDIF.
  IF NOT dy_mab IS INITIAL.
    CLEAR i_iphas.
    i_iphas-option = 'EQ'.
    i_iphas-sign   = 'I'.
    i_iphas-low    = '3'.
    APPEND i_iphas.
*--- auch alle Aufträge mit Löschvormerkung (i_iphas = 4)
    i_iphas-low    = '4'.
    APPEND i_iphas.
*--- auch alle Aufträge betriebswirt.abgeschlossen (i_iphas = 6)
    i_iphas-low    = '6'.
    APPEND i_iphas.
  ENDIF.

*--- Groß und Kleinschreibung bei Kurztext ignorieren
  LOOP AT ktext.
    TRANSLATE ktext-low TO UPPER CASE.                   "#EC TRANSLANG
    TRANSLATE ktext-high TO UPPER CASE.                  "#EC TRANSLANG
    MODIFY ktext.
  ENDLOOP.

*--- Selektion Partner
  IF NOT dy_parnr IS INITIAL OR NOT dy_parvw IS INITIAL.
    PERFORM get_aufnr_from_ihpa_l USING g_answer.
*--- no orders for partner -> nothing found
    IF g_answer = no.
      EXIT.
    ENDIF.
  ENDIF.

  DESCRIBE TABLE aufnr LINES l_lines.
*--- IH-Aufträge lesen -----------------------------------------------
  IF NOT dy_ofn IS INITIAL OR
     NOT dy_iar IS INITIAL OR
     NOT dy_mab IS INITIAL.
*--- if G_ALTERN_ACT is activ use speial views
    IF g_use_alt = g_x.
      g_viewname_st   = 'VIAUFKST_IFLOS'.
      PERFORM add_to_g_selfields_tab_f14 USING 'TPLNR_INT'.
    ELSE.
      g_viewname_st   = 'VIAUFKST'.
    ENDIF.
*--- zu selektierende Felder prüfen
    PERFORM check_g_selfields_tab_f16 TABLES g_selfields_tab
                                      USING g_viewname_st.
*--- Wenn Primärrangetab zu groß -> select ändern -------------------*
    IF l_lines > 50.
      l_use_fae = 'X'.
*--- keine generische selektion bei FOR ALL ENTRIES erlaubt
      LOOP AT aufnr TRANSPORTING NO FIELDS
                    WHERE sign <> 'I' OR option <> 'EQ'.
        CLEAR l_use_fae.
        EXIT.
      ENDLOOP.
    ENDIF.
*--- call BADI IWOC_LIST_TUNING
    PERFORM call_badi_f69 USING g_badi_list_tuning_ref
                                g_badi_list_tuning_act
                                g_viewname_st
                                l_lines
                                l_use_aufnr.
*--- Do not use AUFNR for selection. Filter out later.
    IF l_use_aufnr <> 'X'.
      lr_aufnr[] = aufnr[].
      CLEAR aufnr. REFRESH aufnr.
      CLEAR l_use_fae.
    ENDIF.
*ENHANCEMENT-SECTION     riaufk20_21 SPOTS es_riaufk20.
*--- mit FOR ALL ENTRIES selektieren
    IF l_use_fae = 'X'.
      SELECT (g_selfields_tab) FROM (g_viewname_st)
              INTO CORRESPONDING FIELDS OF TABLE h_viaufkst
                               FOR ALL ENTRIES IN aufnr
                               WHERE aufnr = aufnr-low
                               AND   owner IN i_owner
                               AND   iphas IN i_iphas
                               AND   qmnum IN qmnum
                               AND   ilart IN ilart
                               AND   auart IN auart
                               AND   ernam IN ernam
                               AND   erdat IN erdat
                               AND   aenam IN aenam
                               AND   aedat IN aedat
                               AND   bukrs IN bukrs
                               AND   gsber IN gsber
                               AND   abckz IN abckz
                               AND   eqfnr IN eqfnr
                               AND   priok IN priok
                               AND   equnr IN equnr
                               AND   sermat   IN sermat
                               AND   serialnr IN serialnr
                               AND   deviceid IN deviceid
                               AND   bautl IN bautl
                               AND   iwerk IN iwerk
                               AND   ingpr IN ingpr
                               AND   plgrp IN plgrp
                               AND   kunum IN kunum
                               AND   anlbd IN anlbd
                               AND   anlvd IN anlvd
                               AND   kostl IN kostl
                               AND   swerk IN swerk
                               AND   stort IN stort
                               AND   msgrp IN msgrp
                               AND   beber IN beber
                               AND   tplnr IN strno
                               AND   anlnr IN anlnr
                               AND   gltrp IN gltrp
                               AND   gstrp IN gstrp
                               AND   gltrs IN gltrs
                               AND   gstrs IN gstrs
                               AND   gstri IN gstri
                               AND   getri IN getri
                               AND   ftrmi IN ftrmi
                               AND   revnr IN revnr
                               AND   warpl IN warpl
                               AND   wapos IN wapos
                               AND   aufpl IN aufpl
                               AND   maufnr     IN maufnr
                               AND   lead_aufnr IN lead_auf
                               AND   ppsid IN i_ppsid
                               AND   gewrk IN i_gewrk
                               AND   kdauf IN kdauf
                               AND   kdpos IN kdpos
                               AND   plknz IN plknz
                               AND   proid IN i_proid
                               AND   pspel IN i_pspel
                               AND   aufnt IN aufnt
                               AND   adpsp IN adpsp
                               AND   addat IN gr_date
                               AND   vkorg IN vkorg
                               AND   vtweg IN vtweg
                               AND   spart IN spart
                               AND   plnnr IN plnnr
                               AND   plnal IN plnal
                               AND   prctr IN prctr
                               AND   kostv IN kostv.
    ELSE.
      SELECT (g_selfields_tab) FROM (g_viewname_st)
              INTO CORRESPONDING FIELDS OF TABLE h_viaufkst
                               WHERE iphas IN i_iphas
                               AND   owner IN i_owner
                               AND   aufnr IN aufnr
                               AND   qmnum IN qmnum
                               AND   ilart IN ilart
                               AND   auart IN auart
                               AND   ernam IN ernam
                               AND   erdat IN erdat
                               AND   aenam IN aenam
                               AND   aedat IN aedat
                               AND   bukrs IN bukrs
                               AND   gsber IN gsber
                               AND   abckz IN abckz
                               AND   eqfnr IN eqfnr
                               AND   priok IN priok
                               AND   equnr IN equnr
                               AND   sermat   IN sermat
                               AND   serialnr IN serialnr
                               AND   deviceid IN deviceid
                               AND   bautl IN bautl
                               AND   iwerk IN iwerk
                               AND   ingpr IN ingpr
                               AND   plgrp IN plgrp
                               AND   kunum IN kunum
                               AND   anlbd IN anlbd
                               AND   anlvd IN anlvd
                               AND   kostl IN kostl
                               AND   swerk IN swerk
                               AND   stort IN stort
                               AND   msgrp IN msgrp
                               AND   beber IN beber
                               AND   tplnr IN strno
                               AND   anlnr IN anlnr
                               AND   gltrp IN gltrp
                               AND   gstrp IN gstrp
                               AND   gltrs IN gltrs
                               AND   gstrs IN gstrs
                               AND   gstri IN gstri
                               AND   getri IN getri
                               AND   ftrmi IN ftrmi
                               AND   revnr IN revnr
                               AND   warpl IN warpl
                               AND   wapos IN wapos
                               AND   aufpl IN aufpl
                               AND   maufnr     IN maufnr
                               AND   lead_aufnr IN lead_auf
                               AND   ppsid IN i_ppsid
                               AND   gewrk IN i_gewrk
                               AND   kdauf IN kdauf
                               AND   kdpos IN kdpos
                               AND   plknz IN plknz
                               AND   proid IN i_proid
                               AND   pspel IN i_pspel
                               AND   aufnt IN aufnt
                               AND   adpsp IN adpsp
                               AND   addat IN gr_date
                               AND   vkorg IN vkorg
                               AND   vtweg IN vtweg
                               AND   spart IN spart
                               AND   plnnr IN plnnr
                               AND   plnal IN plnal
                               AND   prctr IN prctr
                               AND   kostv IN kostv.
    ENDIF.
*END-ENHANCEMENT-SECTION.
*   Include notification values from WPS
    PERFORM fill_wps_noti_link TABLES h_viaufkst.
    LOOP AT h_viaufkst ASSIGNING <ls_viaufkst>.
*--- If not used AUFNR for selection, filter out now.
      IF l_use_aufnr <> 'X'.
        CHECK <ls_viaufkst>-aufnr IN lr_aufnr.
      ENDIF.
      MOVE-CORRESPONDING <ls_viaufkst> TO viaufkst.
      IF g_use_alt = g_x.
        viaufkst-tplnr = <ls_viaufkst>-tplnr_int.
      ENDIF.
      h_ktext = viaufkst-ktext.
      TRANSLATE h_ktext TO UPPER CASE.                   "#EC TRANSLANG
      CHECK h_ktext IN ktext.
*--- if no preselection for WBS possible -> check now
      CHECK viaufkst-proid IN gr_proid_all.
      CHECK viaufkst-pspel IN gr_pspel_all.
      PERFORM move_viaufkst_to_object_tab_l.
      APPEND object_tab.
    ENDLOOP.
*--- Restore AUFNR if cleared
    IF l_use_aufnr <> 'X'.
      aufnr[] = lr_aufnr[].
    ENDIF.
  ENDIF.
  FREE h_viaufkst.
  CLEAR viaufkst.
  PERFORM status_check_f16 USING selschem.
*--- bei Adressselektion werden historische Aufträge ausgeschlossen -
  IF NOT dy_his IS INITIAL AND dy_adrfl IS INITIAL.
*--- In Hikola anderes Feld für verantw. Arbeitsplatz ---------------
    PERFORM change_selfields_for_hikola_l.
*--- if G_ALTERN_ACT is activ use speial views
    IF g_use_alt = g_x.
      g_viewname   = 'HIKOLA_IFLOS'.
    ELSE.
      g_viewname   = 'HIKOLA'.
    ENDIF.

*--- Wenn Primärrangetab zu groß -> select ändern -------------------*
    IF l_lines > 50.
      l_use_fae = 'X'.
*--- keine generische selektion bei FOR ALL ENTRIES erlaubt
      LOOP AT aufnr TRANSPORTING NO FIELDS
                    WHERE sign <> 'I' OR option <> 'EQ'.
        CLEAR l_use_fae.
        EXIT.
      ENDLOOP.
    ENDIF.
*--- call BADI IWOC_LIST_TUNING
    PERFORM call_badi_f69 USING g_badi_list_tuning_ref
                                g_badi_list_tuning_act
                                g_viewname
                                l_lines
                                l_use_aufnr.
*--- Do not use AUFNR for selection. Filter out later.
    IF l_use_aufnr <> 'X'.
      lr_aufnr[] = aufnr[].
      CLEAR aufnr. REFRESH aufnr.
      CLEAR l_use_fae.
    ENDIF.
*--- mit FOR ALL ENTRIES selektieren
    IF l_use_fae = 'X'.
      SELECT (g_selfields_tab_hiko) FROM (g_viewname)
             INTO CORRESPONDING FIELDS OF TABLE h_hikola
                           FOR ALL ENTRIES IN aufnr
                           WHERE aufnr =  aufnr-low
                           AND   owner IN i_owner
                           AND   qmnum IN qmnum
                           AND   ilart IN ilart
                           AND   auart IN auart
                           AND   tplnr IN strno
                           AND   equnr IN equnr
                           AND   sermat   IN sermat
                           AND   serialnr IN serialnr
                           AND   deviceid IN deviceid
                           AND   ernam IN ernam
                           AND   erdat IN erdat
                           AND   aenam IN aenam
                           AND   aedat IN aedat
                           AND   bukrs IN bukrs
                           AND   gsber IN gsber
                           AND   abckz IN abckz
                           AND   eqfnr IN eqfnr
                           AND   priok IN priok
                           AND   equnr IN equnr
                           AND   bautl IN bautl
                           AND   iwerk IN iwerk
                           AND   ingpr IN ingpr
                           AND   apgrp IN plgrp
                           AND   kunum IN kunum
                           AND   anlbd IN anlbd
                           AND   anlvd IN anlvd
                           AND   kostl IN kostl
                           AND   swerk IN swerk
                           AND   stort IN stort
                           AND   msgrp IN msgrp
                           AND   beber IN beber
                           AND   anlnr IN anlnr
                           AND   gltrp IN gltrp
                           AND   gstrp IN gstrp
                           AND   gstri IN gstri
                           AND   getri IN getri
                           AND   revnr IN revnr
                           AND   warpl IN warpl
                           AND   wapos IN wapos
                           AND   maufnr     IN maufnr
                           AND   lead_aufnr IN lead_auf
                           AND   proid IN i_proid
                           AND   pspel IN i_pspel
                           AND   addat IN gr_date
                           AND   ppsid IN i_ppsid
                           AND   gewrk IN i_gewrk
                           AND   plknz IN plknz
                           AND   vkorg IN vkorg
                           AND   vtweg IN vtweg
                           AND   spart IN spart
                           AND   plnnr IN plnnr
                           AND   plnal IN plnal.
    ELSE.
      SELECT (g_selfields_tab_hiko) FROM (g_viewname)
              INTO CORRESPONDING FIELDS OF TABLE h_hikola
                             WHERE aufnr IN aufnr
                             AND   owner IN i_owner
                             AND   qmnum IN qmnum
                             AND   ilart IN ilart
                             AND   auart IN auart
                             AND   tplnr IN strno
                             AND   equnr IN equnr
                             AND   sermat   IN sermat
                             AND   serialnr IN serialnr
                             AND   deviceid IN deviceid
                             AND   ernam IN ernam
                             AND   erdat IN erdat
                             AND   aenam IN aenam
                             AND   aedat IN aedat
                             AND   bukrs IN bukrs
                             AND   gsber IN gsber
                             AND   abckz IN abckz
                             AND   eqfnr IN eqfnr
                             AND   priok IN priok
                             AND   equnr IN equnr
                             AND   bautl IN bautl
                             AND   iwerk IN iwerk
                             AND   ingpr IN ingpr
                             AND   apgrp IN plgrp
                             AND   kunum IN kunum
                             AND   anlbd IN anlbd
                             AND   anlvd IN anlvd
                             AND   kostl IN kostl
                             AND   swerk IN swerk
                             AND   stort IN stort
                             AND   msgrp IN msgrp
                             AND   beber IN beber
                             AND   anlnr IN anlnr
                             AND   gltrp IN gltrp
                             AND   gstrp IN gstrp
                             AND   gstri IN gstri
                             AND   getri IN getri
                             AND   revnr IN revnr
                             AND   warpl IN warpl
                             AND   wapos IN wapos
                             AND   maufnr     IN maufnr
                             AND   lead_aufnr IN lead_auf
                             AND   proid IN i_proid
                             AND   pspel IN i_pspel
                             AND   addat IN gr_date
                             AND   ppsid IN i_ppsid
                             AND   gewrk IN i_gewrk
                             AND   plknz IN plknz
                             AND   vkorg IN vkorg
                             AND   vtweg IN vtweg
                             AND   spart IN spart
                             AND   plnnr IN plnnr
                             AND   plnal IN plnal.
    ENDIF.
    LOOP AT h_hikola ASSIGNING <ls_hikola>.
*--- If not used AUFNR for selection, filter out now.
      IF l_use_aufnr <> 'X'.
        CHECK <ls_hikola>-aufnr IN lr_aufnr.
      ENDIF.
      MOVE-CORRESPONDING <ls_hikola> TO hikola.
      IF g_use_alt = g_x.
        hikola-tplnr = <ls_hikola>-tplnr_int.
      ENDIF.
      h_ktext = hikola-ktext.
      TRANSLATE h_ktext TO UPPER CASE.                   "#EC TRANSLANG
      CHECK h_ktext IN ktext.
*--- if no preselection for WBS possible -> check now
      CHECK hikola-proid IN gr_proid_all.
      CHECK hikola-pspel IN gr_pspel_all.
      MOVE-CORRESPONDING hikola       TO viaufkst.
      MOVE               hikola-apgrp TO viaufkst-plgrp.

      PERFORM move_viaufkst_to_object_tab_l.
      object_tab-gewrk = hikola-vaplz.
      APPEND object_tab.
    ENDLOOP.
*--- Restore AUFNR if cleared
    IF l_use_aufnr <> 'X'.
      aufnr[] = lr_aufnr[].
    ENDIF.
  ENDIF.
*--- Es werden auch Aufträge über Objektliste selektiert
  IF NOT dy_obl IS INITIAL.
    PERFORM sel_via_objlist_l.
  ENDIF.
*--- nur weiter wenn Daten selektiert
  CHECK NOT object_tab[] IS INITIAL.
*--- Nachselektion Partner
  IF g_par_dbcnt IS INITIAL.
    PERFORM post_read_parnr_l.
  ENDIF.
  PERFORM status_check_l.
*--- nur weiter wenn Daten selektiert
  CHECK NOT object_tab[] IS INITIAL.
*--- If alternativ labeling is activ/deactiv delete duplicate entries
*--- object_tab.
  IF g_use_alt = g_x.
    SORT object_tab BY aufnr.
    DELETE ADJACENT DUPLICATES FROM object_tab
                                    COMPARING aufnr tplnr_int.
  ENDIF.
*--- Berechtigungsprüfung, Zusatzdaten nachlesen
  PERFORM authority_check_l.
  PERFORM fill_object_tab_l.
*--- Defaultsortiertung wenn nichts über SALV eingestellt
  IF g_sortfields_tab[] IS INITIAL.
    SORT object_tab BY aufnr.
  ENDIF.

*--- Restore original selection criteria
  aufnr[] = lr_aufnr_save[].

ENDFORM.                    "selection_l

*eject
*---------------------------------------------------------------------*
*       FORM FCODES_WITH_MARK_L                                       *
*---------------------------------------------------------------------*
*       FCodes, die auch im Loop verarbeitet werden können            *
*---------------------------------------------------------------------*
FORM fcodes_with_mark_l USING f_ucomm    LIKE sy-ucomm
                              f_selfield TYPE slis_selfield.

*--- aus checkbox wird Haken
  PERFORM mark_selected_f16 CHANGING object_tab-selected
                                     object_tab-pm_selected.

  MOVE-CORRESPONDING object_tab TO rihaufk.
  MOVE-CORRESPONDING object_tab TO rihaufk_list.
  CASE f_ucomm.
    WHEN 'KO22'.
      PERFORM call_budget_l USING f_ucomm.
    WHEN 'KO23'.
      PERFORM call_budget_l USING f_ucomm.
    WHEN 'LGTX'.
      PERFORM display_longtext_l.
    WHEN 'PHON'.
      PERFORM phon_f70 USING f_selfield.
    WHEN 'CMFU'.
      PERFORM call_completion_conf USING f_selfield.
    WHEN OTHERS.
      PERFORM call_auftrag_l USING f_ucomm f_selfield.
  ENDCASE.

ENDFORM.                    "fcodes_with_mark_l

*---------------------------------------------------------------------*
*       FORM call_completion_conf                                     *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
*  -->  p_selfield                                                    *
*---------------------------------------------------------------------*
FORM call_completion_conf USING p_selfield TYPE slis_selfield.

*--- Datenvereinbarung -----------------------------------------------*
  DATA l_tcode   LIKE sy-tcode VALUE 'IW42'.
  DATA l_retc    LIKE sy-subrc.
  DATA l_retcode LIKE sy-subrc.

  SET PARAMETER ID 'ANR' FIELD rihaufk_list-aufnr.
  SET PARAMETER ID 'RCK' FIELD space.                       "note216322
  SET PARAMETER ID 'VGN' FIELD space.                       "note216322

*--- Berechtigungsprüfung auf T-code -------------------------------*
  PERFORM auth_check_tcode_f16 USING l_tcode
                               CHANGING l_retc.
  IF l_retc IS INITIAL.
*--- Gesamtrückmeldung aufrufen
    FREE MEMORY ID 'CMFU'.
    CALL TRANSACTION l_tcode.
    IMPORT l_retcode FROM MEMORY ID 'CMFU'.
    return_code = l_retcode.
*--- Object-tab aktualisieren (Status)
    IF l_retcode IS INITIAL.
      PERFORM fill_object_tab_late_l.
    ENDIF.
  ENDIF.

ENDFORM.                    "call_completion_conf
*eject
*---------------------------------------------------------------------*
*       FORM  CALL_AUFTRAG_L
*---------------------------------------------------------------------*
* Form um den Auftrag zu aendern
*---------------------------------------------------------------------*
FORM call_auftrag_l USING f_ucomm LIKE sy-ucomm
                          f_selfield TYPE slis_selfield.
*--- Datenvereinbarung -----------------------------------------------*
  DATA: ok_memory LIKE sy-ucomm.
  DATA: f_tcode   LIKE sy-tcode.
  DATA: f_retc    LIKE sy-subrc.

  DATA: l_riarch   LIKE riarch.
  DATA: l_t_riarch LIKE riarch OCCURS 0 WITH HEADER LINE.

*--- Verarbeitung ----------------------------------------------------*
  IF f_ucomm <> 'ISEL' AND
     f_ucomm <> 'IOBJ'.
    ok_memory = f_ucomm.
  ENDIF.

  EXPORT xclnot    TO MEMORY ID 'CLNOT'.
  EXPORT ok_memory TO MEMORY ID 'PM'.

  IF f_ucomm = 'LIAR'.
*--- export function code teco to memory
    EXPORT f_ucomm TO MEMORY ID 'TECO'.                     "969337
*--- g_t_riarch and g_riarch were filled in ARCH_POPUP_SEND
    IF g_t_riarch[] IS INITIAL.
*--- export riarch to memory
      EXPORT l_riarch TO MEMORY ID 'GI_VCI'.
    ELSE.
*--- export riarch to memory
      MOVE g_t_riarch[] TO l_t_riarch[].
      EXPORT l_t_riarch TO MEMORY ID 'GI_VCI'.
    ENDIF.
  ENDIF.

  SET PARAMETER ID 'ANR' FIELD rihaufk_list-aufnr.
  IF t370a-aktyp = 'V'.
    f_tcode = 'IW32'.
  ELSE.
    f_tcode = 'IW33'.
  ENDIF.
*--- sprezielle T-Codes für Drucken
  IF f_ucomm = 'PRLT'.
    f_tcode = 'IW3D'.
  ENDIF.
*--- spezielle T-Codes für Komponentenübersicht
  IF f_ucomm = 'IW3L'.
    IF t370a-aktyp = 'V'.
      f_tcode = 'IW3K'.
    ELSE.
      f_tcode = 'IW3L'.
    ENDIF.
  ENDIF.
*--- Berechtigungsprüfung auf T-code -------------------------------*
  PERFORM auth_check_tcode_f16 USING f_tcode
                               CHANGING f_retc.
  IF f_retc IS INITIAL.
    CALL TRANSACTION f_tcode AND SKIP FIRST SCREEN.
*********************************************************** W C M *****
    FREE MEMORY ID 'ASGN'.
    FREE MEMORY ID rihaufk_list-objnr.
*********************************************************** W C M *****

    IMPORT lt_msg FROM MEMORY ID 'VCI_MSGTAB'.
    IF sy-subrc = 0.
      LOOP AT lt_msg.
        PERFORM fill_bal USING lt_msg.
      ENDLOOP.
      FREE MEMORY ID 'VCI_MSGTAB'.
    ENDIF.

    IMPORT return_code caufvd riwo1
                       FROM MEMORY ID 'PMWOC'.
    FREE MEMORY ID  'PMWOC'.

    IF sy-subrc = 0  AND return_code = 0.
      IF f_ucomm = 'PRLT'.
*--- ausgabe Drucksymbol in Liste
        PERFORM mark_printed_f16 CHANGING object_tab-selected
                                          object_tab-pm_selected.
      ENDIF.
      IF caufvd-aufnr = object_tab-aufnr.
*--- Keep notification link (case: WPS)
        IF NOT object_tab-qmnum IS INITIAL.
          caufvd-qmnum = object_tab-qmnum.
        ENDIF.
*--- update Object_tab
        MOVE-CORRESPONDING  caufvd TO object_tab.
        MOVE  caufvd-vaplz TO object_tab-gewrk.
        MOVE  caufvd-tplnr TO object_tab-tplnr_int.
*--- write wegen Konvertierung PSP-Element/Platz
        WRITE caufvd-tplnr TO object_tab-tplnr.
        WRITE caufvd-pspel TO object_tab-pspel.
        WRITE caufvd-proid TO object_tab-proid.

        MOVE-CORRESPONDING object_tab TO rihaufk.
        MOVE-CORRESPONDING object_tab TO rihaufk_list.
        PERFORM fill_object_tab_late_l.
        MOVE  caufvd-sttxt TO object_tab-sttxt.
        MOVE  caufvd-asttx TO object_tab-ustxt.
        MODIFY object_tab.
      ENDIF.
    ELSEIF return_code = 4.
*---  fehler in statusverwaltung -> statusänderung nicht erlaubt
      IF g_ucomm = 'LIRA' OR
         g_ucomm = 'LIAB' OR
         g_ucomm = 'LIAR' OR
         g_ucomm = 'LIFR'.
        MESSAGE i120 WITH object_tab-aufnr.
      ENDIF.
    ENDIF.
  ELSE.
* Berechtigungsprüfung fehlgeschlagen
    MOVE 16 TO return_code.
  ENDIF.

ENDFORM.                    "call_auftrag_l

*---------------------------------------------------------------------*
*       FORM CALL_MELDUNG_L                                           *
*---------------------------------------------------------------------*
*       Meldung aufrufen                                              *
*---------------------------------------------------------------------*
*  -->  F_UCOMM                                                       *
*  -->  F_AUFNR                                                       *
*  -->  F_OBKNR                                                       *
*---------------------------------------------------------------------*
FORM call_meldung_l USING f_ucomm LIKE sy-ucomm
                          f_obknr LIKE caufvd-obknr
                          f_qmnum LIKE caufvd-qmnum.

*--- Datenvereinbarung -----------------------------------------------*
  DATA: ok_memory LIKE sy-ucomm.
  DATA: BEGIN OF idiqmel.
          INCLUDE STRUCTURE diqmel.
  DATA: END OF idiqmel.

  DATA: f_retc LIKE sy-subrc.
  DATA: f_tcode LIKE sy-tcode.
  DATA: BEGIN OF h_objk OCCURS 20,
    qmnum LIKE qmel-qmnum.
  DATA: END OF h_objk.
  TABLES: objk.

*--- Verarbeitung ----------------------------------------------------*

*--- Meldungen zum Auftrag ermitteln ---------------------------------*
  IF NOT f_obknr IS INITIAL.
    REFRESH h_objk.
    SELECT * FROM objk
             WHERE obknr    =  f_obknr.
      IF NOT objk-ihnum IS INITIAL.
        h_objk-qmnum = objk-ihnum.
        APPEND h_objk.
      ENDIF.
    ENDSELECT.
    IF NOT f_qmnum IS INITIAL.
      h_objk-qmnum = f_qmnum.
      COLLECT h_objk.
    ENDIF.
  ENDIF.

*--- Meldungstransaktion aufrufen ------------------------------------*
  LOOP AT h_objk.
    ok_memory = f_ucomm.
    EXPORT ok_memory TO MEMORY ID 'PM'.
    SET PARAMETER ID 'IQM' FIELD h_objk-qmnum.

    IF t370a-aktyp = 'V'.
      f_tcode = 'IQS2'.                "IH-Meldung ändern
    ELSE.
      f_tcode = 'IQS3'.                "IH-Meldung anzeigen
    ENDIF.

*--- Berechtigungsprüfung auf T-code ---------------------------------*
    PERFORM auth_check_tcode_f16 USING f_tcode
                                 CHANGING f_retc.
    IF f_retc IS INITIAL.
      CALL TRANSACTION f_tcode AND SKIP FIRST SCREEN.
*--- return_code is set in Meldung with 8 when BEENDEN is selected ---*
      IMPORT idiqmel return_code FROM MEMORY ID 'QMOB'.
      FREE MEMORY ID 'QMOB'.
    ENDIF.
  ENDLOOP.

ENDFORM.                    "call_meldung_l
*eject
*---------------------------------------------------------------------*
*       FORM DISPLAY_QMEL_L                                           *
*---------------------------------------------------------------------*
*       Meldungen                                                     *
*---------------------------------------------------------------------*
FORM display_qmel_l.

  DATA: f_tcode LIKE sy-tcode.
  DATA: f_retc  LIKE sy-subrc.

  DATA: BEGIN OF lt_qmnum OCCURS 1,
          qmnum LIKE qmel-qmnum,
        END OF lt_qmnum.

  RANGES lr_qmnum FOR qmel-qmnum.

*--- Wenn in Serviceliste (Auft) dann in Serviceliste (Meld) springen*
  IF g_aktyp = 'V'.
    IF dy_tcode = 'IW72' OR dy_tcode = 'IW73'.
      f_tcode = 'IW58'.
    ELSE.
      f_tcode = 'IW28'.
    ENDIF.
  ELSE.
    IF dy_tcode = 'IW72' OR dy_tcode = 'IW73'.
      f_tcode = 'IW59'.
    ELSE.
      f_tcode = 'IW29'.
    ENDIF.
  ENDIF.
*--- Berechtigungsprüfung auf T-code --------------------------------*
  PERFORM auth_check_tcode_f16 USING f_tcode
                               CHANGING f_retc.
  IF f_retc IS INITIAL.
    PERFORM create_range_l.
*--- wenn Range zu groß, Meldungsnummer übergeben
    DESCRIBE TABLE object LINES sy-tfill.
    IF sy-tfill < 256.
      IF sy-tfill > 0.
        EXPORT f_tcode TO MEMORY ID 'RIQMEL20'.
        SUBMIT riqmel20 WITH aufnr IN object
                        WITH dy_ofn   = 'X'
                        WITH dy_rst   = 'X'
                        WITH dy_iar   = 'X'
                        WITH dy_mab   = 'X'
                        WITH dy_tcode = f_tcode
                        WITH datuv    = '19000101'
                        WITH datub    = '99991231'
               AND RETURN.
      ELSE.
        MESSAGE s047.
      ENDIF.
    ELSE.
*--- Vorselektion der Meldungsnummern
      SELECT qmnum FROM qmel INTO TABLE lt_qmnum
                   FOR ALL ENTRIES IN object
                   WHERE aufnr = object-low.

      IF NOT sy-dbcnt IS INITIAL.
        lr_qmnum-sign = 'I'.
        lr_qmnum-option = 'EQ'.
        LOOP AT lt_qmnum.
          lr_qmnum-low = lt_qmnum-qmnum.
          APPEND lr_qmnum.
        ENDLOOP.

        EXPORT f_tcode TO MEMORY ID 'RIQMEL20'.
        SUBMIT riqmel20 WITH qmnum IN lr_qmnum
                        WITH dy_ofn   = 'X'
                        WITH dy_rst   = 'X'
                        WITH dy_iar   = 'X'
                        WITH dy_mab   = 'X'
                        WITH dy_tcode = f_tcode
                        WITH datuv    = '19000101'
                        WITH datub    = '99991231'
               AND RETURN.
      ELSE.
        MESSAGE s047.
      ENDIF.
    ENDIF.
  ENDIF.

ENDFORM.                    "display_qmel_l
*eject
*---------------------------------------------------------------------*
*       FORM MULTI_IFLO_l                                             *
*---------------------------------------------------------------------*
*       Techn. Pl. mehrstufig                                         *
*---------------------------------------------------------------------*
FORM multi_iflo_l.

  DATA: f_retc LIKE sy-subrc.

*--- Berechtigungsprüfung auf T-code -------------------------------*
  PERFORM auth_check_tcode_f16 USING 'IL07'
                               CHANGING f_retc.
  IF f_retc IS INITIAL.
    PERFORM create_range_iflo_l.
    IF NOT i_tplnr IS INITIAL.
      SUBMIT riiflo30 WITH tplnr IN i_tplnr
             VIA SELECTION-SCREEN
             AND RETURN.
    ENDIF.
  ENDIF.

ENDFORM.                    "multi_iflo_l

*eject
*---------------------------------------------------------------------*
*       FORM MULTI_EQUI_l                                             *
*---------------------------------------------------------------------*
*       Equipments mehrstufig                                         *
*---------------------------------------------------------------------*
FORM multi_equi_l.

  DATA: f_retc LIKE sy-subrc.
*--- Berechtigungsprüfung auf T-code -------------------------------*
  PERFORM auth_check_tcode_f16 USING 'IE07'
                               CHANGING f_retc.
  IF f_retc IS INITIAL.
    PERFORM create_range_equi_l.
    IF NOT i_equnr IS INITIAL.
      SUBMIT riequi30 WITH equnr IN i_equnr
             VIA SELECTION-SCREEN
             AND RETURN.
    ENDIF.
  ENDIF.

ENDFORM.                    "multi_equi_l

*eject
*---------------------------------------------------------------------*
*       FORM MULTI_QMEL_l                                             *
*---------------------------------------------------------------------*
*       Meldungen mehrstufig                                          *
*---------------------------------------------------------------------*
FORM multi_qmel_l.

  DATA: f_retc LIKE sy-subrc.

*--- Berechtigungsprüfung auf T-code -------------------------------*
  PERFORM auth_check_tcode_f16 USING 'IW30'
                               CHANGING f_retc.
  IF f_retc IS INITIAL.
    PERFORM create_range_l.
    IF NOT object IS INITIAL.
      SUBMIT riqmel10 WITH aufnr IN object
                      WITH dy_ofn   = 'X'
                      WITH dy_rst   = 'X'
                      WITH dy_iar   = 'X'
                      WITH dy_mab   = 'X'
                      WITH datuv    = '00000000'
                      WITH datub    = '99991231'
             VIA SELECTION-SCREEN
             AND RETURN.
    ENDIF.
  ENDIF.

ENDFORM.                    "multi_qmel_l

*---------------------------------------------------------------------*
*       FORM MULTI_AUFK_l                                             *
*---------------------------------------------------------------------*
*       Aufträge mehrstufig                                           *
*---------------------------------------------------------------------*
FORM multi_aufk_l.

  DATA: f_retc LIKE sy-subrc.

*--- Berechtigungsprüfung auf T-code -------------------------------*
  PERFORM auth_check_tcode_f16 USING 'IW40'
                               CHANGING f_retc.
  IF f_retc IS INITIAL.
    PERFORM create_range_l.
    IF NOT object IS INITIAL.
      SUBMIT riaufk10 WITH aufnr IN object
                      WITH dy_ofn   = dy_ofn
                      WITH dy_iar   = dy_iar
                      WITH dy_mab   = dy_mab
                      WITH dy_his   = dy_his
                      WITH datuv    = datuv
                      WITH datub    = datub
             VIA SELECTION-SCREEN
             AND RETURN.
    ENDIF.
  ENDIF.

ENDFORM.                    "multi_aufk_l

*eject
*---------------------------------------------------------------------*
*       FORM MOVE_VIAUFKST_TO_OBJECT_TAB_L                            *
*---------------------------------------------------------------------*
*       Move von VIAUFKST nach OBJECT_TAB                             *
*       mit versorgen aller besonders zu ermittelnden Felder          *
*---------------------------------------------------------------------*
FORM move_viaufkst_to_object_tab_l.

  MOVE-CORRESPONDING viaufkst TO object_tab.
*--- write wegen Konvertierung
  WRITE viaufkst-proid TO object_tab-proid.
  WRITE viaufkst-pspel TO object_tab-pspel.
  WRITE viaufkst-tplnr TO object_tab-tplnr.

  object_tab-tplnr_int = viaufkst-tplnr.

*--- Interne AUSZT ind EGAUZT umrechnen ------------------------------*
  IF g_egauzt_flag = yes.
    PERFORM extern_gauzt_ermitteln_l USING
                                     viaufkst-gauzt
                                     object_tab-egauzt
                                     viaufkst-gaueh.
  ENDIF.

  object_tab-objnr = viaufkst-objnr.
  IF viaufkst-iphas <> '9'.
    l_jsto_pre_tab = viaufkst-objnr.
    APPEND l_jsto_pre_tab.
  ENDIF.
  object_tab-ppsid = viaufkst-ppsid.
  object_tab-igewrk = viaufkst-gewrk.
*--- Bezugsobjektnummern in separater Tabelle w. Authority check -----*
  IF NOT object_tab-equnr IS INITIAL.
    g_equnr_tab-equnr = object_tab-equnr.
    COLLECT g_equnr_tab.
  ENDIF.
  IF NOT object_tab-tplnr_int IS INITIAL.
    g_tplnr_tab-tplnr = object_tab-tplnr_int.
    COLLECT g_tplnr_tab.
  ENDIF.

ENDFORM.                    "move_viaufkst_to_object_tab_l

*eject
*---------------------------------------------------------------------*
*       FORM FILL_OBJECT_TAB_L                                        *
*---------------------------------------------------------------------*
*       Statustexte und Arbeitsplätze nachlesen                       *
*---------------------------------------------------------------------*
FORM fill_object_tab_l.

  DATA h_rihaufk_tab TYPE TABLE OF rihaufk WITH HEADER LINE.
  DATA h_org         TYPE pmsdo.    " Organisationsdaten Vertrieb
  DATA ht_pmsdo      TYPE TABLE OF pmsdo WITH HEADER LINE.

  DATA: BEGIN OF h_afvc_wa,
    aufpl LIKE afvc-aufpl,
    aplzl LIKE afvc-aplzl,
    vornr LIKE afvc-vornr.
  DATA: END OF h_afvc_wa.

  DATA: BEGIN OF h_qmnum_tab OCCURS 0,
    qmnum LIKE qmel-qmnum.
  DATA: END OF h_qmnum_tab.

  DATA: BEGIN OF h_qmel_tab OCCURS 0,
    qmnum LIKE qmel-qmnum,
    adrnr LIKE qmel-adrnr.
  DATA: END OF h_qmel_tab.

* DFPS Datendeklaration für BADI Aufruf
  DATA: lo_dfps_badi01 TYPE REF TO dfps_badi_pm_is_sap.

  FIELD-SYMBOLS: <ls_object_tab> LIKE LINE OF object_tab,
                 <ls_rihaufk>    TYPE rihaufk,
                 <ls_pmsdo>      TYPE pmsdo.

*--- nur weiter wenn object_tab gefüllt
  CHECK NOT object_tab[] IS INITIAL.
*--- prefetch-Tabellen initialisieren
  REFRESH: g_equnr_tab,
           g_tplnr_tab,
           g_matnr_tab,
           g_adrnr_sel_tab,
           g_ihpap_tab,
           g_bor_tab,
           l_tarbid,
           l_jsto_pre_tab.
*--- Sortieren wegen binary search ----------------------------------*
  SORT g_fieldcat_tab BY fieldname.
  SORT t_t350         BY auart.
*--- Statuszeile nachlesen ? ----------------------------------------*
  IF g_grstat IS INITIAL.
    PERFORM check_field_display_f14 USING 'STTXT' g_sttxt_flag.
    IF g_sttxt_flag <> yes.
      PERFORM check_field_display_f14 USING 'USTXT' g_sttxt_flag.
    ENDIF.
  ELSE.
    g_sttxt_flag = yes.
  ENDIF.
*--- Prioritätstext nachlesen? -------------------------------------*
  PERFORM check_field_display_f14 USING 'PRIOKX' g_priokx_flag.
*--- Pagingstatus nachlesen ? --------------------------------------*
  PERFORM check_field_display_f14 USING 'PAGESTAT' g_page_flag.
*--- externe Arbeitsplatzbez. nachlesen ? --------------------------*
  PERFORM check_field_display_f14 USING 'ARBPL' g_arbpl_flag.
*--- Sel.option gefüllt, jedoch kein prefetch -> nachlesen nötig
  IF g_crhd_flag = yes. g_arbpl_flag = yes. ENDIF.
*--- externe Arbeitsplatzbez. nachlesen ? --------------------------*
  PERFORM check_field_display_f14 USING 'GEWRK' g_gewrk_flag.
  IF g_gewrk_flag <> yes.
    PERFORM check_field_display_f14 USING 'AWERK' g_gewrk_flag.
  ENDIF.
*--- Sel.option gefüllt, jedoch kein prefetch -> nachlesen nötig
  IF g_crhd_flag = yes. g_gewrk_flag = yes. ENDIF.
*--- Equipmentbezeichnung nachlesen ? ------------------------------*
  PERFORM check_field_display_f14 USING 'EQKTX' g_eqktx_flag.
*--- Tech. Platzbezeichnung nachlesen ? ----------------------------*
  PERFORM check_field_display_f14 USING 'PLTXT' g_pltxt_flag.
*--- Materialbezeichung nachlesen ? --------------------------------*
  PERFORM check_field_display_f14 USING 'MAKTX' g_maktx_flag.
  IF g_maktx_flag <> yes.
    PERFORM check_field_display_f14 USING 'BAUTLX' g_maktx_flag.
    IF g_maktx_flag <> yes.
      PERFORM check_field_display_f14 USING 'SERV_MAKTX' g_maktx_flag.
    ENDIF.
  ENDIF.
*--- zugeordneter Netzwerkvorgang ----------------------------------*
  PERFORM check_field_display_f14 USING 'VORUE' g_vorue_flag.
*--- Nachselektion PMSDO (SD-Orgdaten) notwendig ? -----------------*
  PERFORM check_pmsdo_l.
*--- Wenn beide Select-options gesetzt -> Flag setzten ------------*
  DESCRIBE TABLE aufnt LINES sy-tabix.
  IF NOT sy-tabix IS INITIAL.
    DESCRIBE TABLE vorue LINES sy-tabix.
    IF NOT sy-tabix IS INITIAL.
      g_vorue_flag = yes.
    ENDIF.
  ELSE.
*--- nur Vorgang ohne Netzwerk macht keinen Sinn ------------------*
    CLEAR   vorue.
    REFRESH vorue.
  ENDIF.
*--- Wird nach Pagestatus selektiert Flag für Nachlesen setzten
  IF NOT pagestat[] IS INITIAL. g_page_flag = yes. ENDIF.
*--- Adresse erforderlich ? ----------------------------------------
  PERFORM check_adress_sel_necc_17.
*--- Kosten ermitteln ? ---------------------------------------------
  PERFORM check_cost_fields_l.
*--- wird report dunkel aufgerufen -> alle Flags setzten -----------*
  IF g_selmod = selmod_d.
    PERFORM check_flags_with_selmod_l.
  ENDIF.

* DFPS Start
  BREAK-POINT ID dfps_pm_is.
  TRY.
      GET BADI lo_dfps_badi01.

    CATCH cx_badi_not_implemented.                      "#EC NO_HANDLER
    CATCH cx_badi_multiply_implemented.                 "#EC NO_HANDLER
    CATCH cx_badi_initial_context.                      "#EC NO_HANDLER
  ENDTRY.

  IF NOT lo_dfps_badi01 IS INITIAL.
    TRY.
        CALL BADI lo_dfps_badi01->set_riaufk20_fld_flag
          CHANGING
            pt_fieldcat = g_fieldcat_tab[].

      CATCH cx_badi_initial_reference.                  "#EC NO_HANDLER
      CATCH cx_sy_dyn_call_illegal_method.              "#EC NO_HANDLER
    ENDTRY.
  ENDIF.
* DFPS End

*--- pre-fetch-Tabellen füllen
  LOOP AT object_tab ASSIGNING <ls_object_tab>.
*--- Status für PMSDO/Statusverwaltung
    l_jsto_pre_tab-objnr = <ls_object_tab>-objnr.
    APPEND l_jsto_pre_tab.
*--- pps-Arbeitsplatz
    IF NOT <ls_object_tab>-ppsid IS INITIAL.
      l_tarbid-mandt = sy-mandt.
      l_tarbid-objty = 'A '.
      l_tarbid-objid = <ls_object_tab>-ppsid.
      COLLECT l_tarbid.
    ENDIF.
*--- Verantw. Arbeitsplatz
    IF NOT <ls_object_tab>-igewrk IS INITIAL.
      l_tarbid-mandt = sy-mandt.
      l_tarbid-objty = 'A '.
      l_tarbid-objid = <ls_object_tab>-igewrk.
      COLLECT l_tarbid.
    ENDIF.
*--- Equi
    IF NOT <ls_object_tab>-equnr IS INITIAL.
      g_equnr_tab-equnr = <ls_object_tab>-equnr.
      COLLECT g_equnr_tab.
    ENDIF.
*--- Platz
    IF NOT <ls_object_tab>-tplnr_int IS INITIAL.
      g_tplnr_tab-tplnr = <ls_object_tab>-tplnr_int.
      COLLECT g_tplnr_tab.
    ENDIF.
*--- Auftrags- bzw. Bezugsobjektadresse in prefetch-Tab stellen -----*
    IF NOT <ls_object_tab>-adrnra IS INITIAL.
      g_adrnr_sel_tab-addrnumber = <ls_object_tab>-adrnra.
      APPEND g_adrnr_sel_tab.
    ELSE.
*--- Meldungsnummer zweck Nachselektion Adresse
      IF NOT <ls_object_tab>-qmnum IS INITIAL.
        h_qmnum_tab-qmnum = <ls_object_tab>-qmnum.
        APPEND h_qmnum_tab.
      ENDIF.
      IF NOT <ls_object_tab>-adrnr_iloa IS INITIAL.
        g_adrnr_sel_tab-addrnumber = <ls_object_tab>-adrnr_iloa.
        COLLECT g_adrnr_sel_tab.
      ENDIF.
    ENDIF.
*--- Materialnummern sammeln für eventl.prefetch -------------------*
    IF NOT <ls_object_tab>-sermat IS INITIAL.
      g_matnr_tab-matnr = <ls_object_tab>-sermat.
      COLLECT g_matnr_tab.
    ENDIF.
    IF NOT <ls_object_tab>-bautl IS INITIAL.
      g_matnr_tab-matnr = <ls_object_tab>-bautl.
      COLLECT g_matnr_tab.
    ENDIF.
*--- Kundennummer und Objeknummer für prefetch sammeln
    IF NOT <ls_object_tab>-kunum IS INITIAL.
      g_ihpap_tab-objnr = <ls_object_tab>-objnr.
      g_ihpap_tab-parnr = <ls_object_tab>-kunum.
      IF <ls_object_tab>-auart <> t_t350-auart.
        READ TABLE t_t350 WITH KEY auart = <ls_object_tab>-auart
                                   BINARY SEARCH.
      ENDIF.
      g_ihpap_tab-parvw = t_t350-parvw.
      APPEND g_ihpap_tab.
    ENDIF.
*--- Prefetch Paging
    IF <ls_object_tab>-auart <> t_t350-auart.
      READ TABLE t_t350 WITH KEY auart = <ls_object_tab>-auart
                                 BINARY SEARCH.
    ENDIF.
    g_bor_tab-objkey = <ls_object_tab>-aufnr.
    IF t_t350-service = g_x.
      g_bor_tab-objtype = 'BUS2088'.
    ELSE.
      g_bor_tab-objtype = 'BUS2007'.
    ENDIF.
    g_bor_tab-logsys = g_logsys.
    APPEND g_bor_tab.
*--- PMCO-kosten
    MOVE-CORRESPONDING <ls_object_tab> TO h_rihaufk_tab.
    APPEND h_rihaufk_tab.
  ENDLOOP.

*--- Prefetch ausführen
  IF g_arbpl_flag = yes OR g_gewrk_flag = yes.
    CALL FUNCTION 'CR_WORKCENTER_PRE_READ'
      TABLES
        tarbid = l_tarbid.
    FREE l_tarbid.
  ENDIF.

  IF g_stasl_flag = yes OR g_sttxt_flag = yes.
    IF g_statbuf_flag IS INITIAL.
      CALL FUNCTION 'STATUS_PRE_READ'
        TABLES
          jsto_pre_tab = l_jsto_pre_tab.
    ENDIF.
  ENDIF.

  IF g_pmsdo_flag = yes.
    CALL FUNCTION 'PMSDO_PRE_READ'
      TABLES
        ti_objnr = l_jsto_pre_tab
        te_pmsdo = ht_pmsdo
      EXCEPTIONS
        OTHERS   = 0.
    IF g_maktx_flag = yes.
*--- Materialtab. für prefetch Bezeichung füllen
      LOOP AT ht_pmsdo ASSIGNING <ls_pmsdo> WHERE matnr <> space.
        g_matnr_tab-matnr = <ls_pmsdo>-matnr.
        APPEND g_matnr_tab.
      ENDLOOP.
    ENDIF.
  ENDIF.

  IF g_kost_flag = yes.
*--- Kosten zu IH-Aufträgen ermitteln -------------------------------
    CALL FUNCTION 'PM_WORKORDER_COSTS_LIST'
      EXPORTING
        list_currency  = waers
        all_currencies = 'X'
        external_call  = 'X'
      TABLES
        list_aufk      = h_rihaufk_tab
      EXCEPTIONS
        no_currency    = 1
        OTHERS         = 2.
*--- object_tab with mit kosten aus h_rihaufk_tab aktualisiert -------*
    IF sy-subrc <> 1.

*ENHANCEMENT-POINT riaufk20_22 SPOTS es_riaufk20.
      LOOP AT h_rihaufk_tab ASSIGNING <ls_rihaufk>.
*ENHANCEMENT-SECTION     riaufk20_23 SPOTS es_riaufk20.
        READ TABLE object_tab ASSIGNING <ls_object_tab>
                              WITH KEY aufnr = <ls_rihaufk>-aufnr.
*END-ENHANCEMENT-SECTION.
        IF sy-subrc IS INITIAL.
*--- update cost fields in object_tab
          MOVE:
            <ls_rihaufk>-gksti    TO <ls_object_tab>-gksti,
            <ls_rihaufk>-gkstp    TO <ls_object_tab>-gkstp,
            <ls_rihaufk>-gksta    TO <ls_object_tab>-gksta,
            <ls_rihaufk>-gerti    TO <ls_object_tab>-gerti,
            <ls_rihaufk>-gertp    TO <ls_object_tab>-gertp,
            <ls_rihaufk>-gesist   TO <ls_object_tab>-gesist,
            <ls_rihaufk>-gespln   TO <ls_object_tab>-gespln,
            <ls_rihaufk>-user4    TO <ls_object_tab>-user4,
            <ls_rihaufk>-waers    TO <ls_object_tab>-waers.
          IF NOT <ls_object_tab>-gesist IN gesist
             OR NOT <ls_object_tab>-gespln IN gespln.
            DELETE object_tab INDEX sy-tabix.
          ENDIF.
        ENDIF.
      ENDLOOP.
    ENDIF.
  ENDIF.
*--- Adressen lesen -------------------------------------------------*
  IF g_adres_flag = yes.
*--- Adressnummern von Kopfmeldungen in globale pre-fetch Tab stellen
    IF NOT h_qmnum_tab[] IS INITIAL.
      SELECT qmnum adrnr FROM qmel INTO TABLE h_qmel_tab
             FOR ALL ENTRIES IN h_qmnum_tab
             WHERE   qmnum = h_qmnum_tab-qmnum
             AND     adrnr <> space.
      IF sy-subrc IS INITIAL.
        SORT h_qmel_tab BY qmnum.
        LOOP AT h_qmel_tab.
          g_adrnr_sel_tab-addrnumber = h_qmel_tab-adrnr.
          APPEND g_adrnr_sel_tab.
        ENDLOOP.
      ENDIF.
    ENDIF.
*--- Pre-fetch Adressen
    PERFORM pre_read_adrnr_f17.
    PERFORM pre_read_adrnr_ihpa_f17 TABLES g_ihpap_tab.
  ENDIF.
*--- Bezeichnung Technischer Platz lesen ----------------------------*
  IF g_pltxt_flag = yes.
    CALL FUNCTION 'IREP1_LOCATION_TEXT_PRE_FETCH'
      TABLES
        tplnr_tab     = g_tplnr_tab
      EXCEPTIONS
        no_text_found = 1
        OTHERS        = 2.
  ENDIF.
*--- Bezeichung Equipment lesen -------------------------------------*
  IF g_eqktx_flag = yes.
    CALL FUNCTION 'IREP1_EQUIPMENT_TEXT_PRE_FETCH'
      TABLES
        equnr_tab     = g_equnr_tab
      EXCEPTIONS
        no_text_found = 1
        OTHERS        = 2.
  ENDIF.
*--- Bezeichung Material lesen --------------------------------------*
  IF g_maktx_flag = yes.
    CALL FUNCTION 'IREP1_MATERIAL_TEXT_PRE_FETCH'
      TABLES
        matnr_tab     = g_matnr_tab
      EXCEPTIONS
        no_text_found = 1
        OTHERS        = 2.
  ENDIF.
*--- Prefetch Pagestatus --------------------------------------------*
  IF g_page_flag = yes.
    PERFORM prefetch_paging_f19.
  ENDIF.
*--- Sortieren wegen performace -------------------------------------*
  IF g_vorue_flag = yes.
    SORT object_tab BY aufpt aplzt.
  ENDIF.

* DFPS Start
  IF NOT lo_dfps_badi01 IS INITIAL.
    BREAK-POINT ID dfps_pm_is.
    TRY.
        CALL BADI lo_dfps_badi01->pre_fetch_riaufk20_data
          EXPORTING
            object_tab = object_tab[].

      CATCH cx_badi_initial_reference.                  "#EC NO_HANDLER
      CATCH cx_sy_dyn_call_illegal_method.              "#EC NO_HANDLER
    ENDTRY.
  ENDIF.
* DFPS End

  LOOP AT object_tab ASSIGNING <ls_object_tab>.
    CLEAR sy-subrc.                                         "1047323
*--- Netzwerkvorgang bestimmen ---------------------------------------*
    IF g_vorue_flag = yes.
      IF NOT <ls_object_tab>-aufpt IS INITIAL.
        IF h_afvc_wa-aufpl = <ls_object_tab>-aufpt AND
           h_afvc_wa-aplzl = <ls_object_tab>-aplzt.
        ELSE.
          SELECT SINGLE aufpl
                        aplzl
                        vornr
                           FROM afvc INTO h_afvc_wa
                           WHERE aufpl = <ls_object_tab>-aufpt
                             AND aplzl = <ls_object_tab>-aplzt.
        ENDIF.
        IF sy-subrc IS INITIAL.
          IF h_afvc_wa-vornr IN vorue.
            <ls_object_tab>-vorue = h_afvc_wa-vornr.
          ELSE.
            DELETE object_tab. CONTINUE.
          ENDIF.
        ENDIF.
      ENDIF.
    ENDIF.
*--- Externe Arbeitsplatznummer bestimmen ----------------------------*
    IF g_arbpl_flag = yes.
      IF NOT <ls_object_tab>-ppsid IS INITIAL.
        CALL FUNCTION 'CR_WORKSTATION_READ'
          EXPORTING
            id        = <ls_object_tab>-ppsid
            msgty     = 'S'
          IMPORTING
            arbpl     = <ls_object_tab>-arbpl
          EXCEPTIONS
            not_found = 01.
        IF sy-subrc <> 0.
          CLEAR <ls_object_tab>-arbpl.
        ENDIF.
      ELSE.
        CLEAR <ls_object_tab>-arbpl.
      ENDIF.
      IF NOT arbpl[] IS INITIAL.
        IF NOT <ls_object_tab>-arbpl IN arbpl.
          DELETE object_tab. CONTINUE.
        ENDIF.
      ENDIF.
    ENDIF.
*--- Externes Leitgewerk bestimmen -----------------------------------*
    IF g_gewrk_flag = yes.
      IF NOT <ls_object_tab>-igewrk IS INITIAL.
        CALL FUNCTION 'CR_WORKSTATION_READ'
          EXPORTING
            id        = <ls_object_tab>-igewrk
            msgty     = 'S'
          IMPORTING
            werks     = <ls_object_tab>-awerk
            arbpl     = <ls_object_tab>-gewrk
          EXCEPTIONS
            not_found = 01.
        IF sy-subrc <> 0.
          CLEAR <ls_object_tab>-gewrk.
        ENDIF.
      ELSE.
        CLEAR <ls_object_tab>-gewrk.
      ENDIF.
      IF NOT gewrk[] IS INITIAL.
        IF NOT <ls_object_tab>-gewrk IN gewrk
           OR NOT <ls_object_tab>-awerk IN vawrk.
          DELETE object_tab. CONTINUE.
        ENDIF.
      ENDIF.
    ENDIF.
*--- Pagestatus lesen ------------------------------------------------*
    IF g_page_flag = yes.
      PERFORM read_pagestat_f19 USING <ls_object_tab>-aufnr
                                      <ls_object_tab>-pagestat.
      IF NOT <ls_object_tab>-pagestat IN pagestat.
        DELETE object_tab. CONTINUE.
      ENDIF.
    ENDIF.
*--- Statusleiste füllen ---------------------------------------------*
    IF g_sttxt_flag = yes.
      CLEAR: <ls_object_tab>-sttxt, <ls_object_tab>-ustxt.
      IF <ls_object_tab>-iphas <> '9'.
        CALL FUNCTION 'STATUS_TEXT_EDIT'
          EXPORTING
            objnr            = <ls_object_tab>-objnr
            spras            = sy-langu
            flg_user_stat    = 'X'
          IMPORTING
            line             = <ls_object_tab>-sttxt
            user_line        = <ls_object_tab>-ustxt
          EXCEPTIONS
            object_not_found = 01.
        IF NOT sy-subrc IS INITIAL.
          CLEAR <ls_object_tab>-sttxt.
          CLEAR <ls_object_tab>-ustxt.
        ENDIF.
      ENDIF.
    ENDIF.
    IF g_pmsdo_flag = yes.
*-- Organisationsdaten lesen ---------------------------------------*
      CALL FUNCTION 'PMSDO_READ'
        EXPORTING
          objnr     = <ls_object_tab>-objnr
        IMPORTING
          org       = h_org
        EXCEPTIONS
          not_found = 1
          OTHERS    = 2.
      IF sy-subrc = 0.
        <ls_object_tab>-vkorg_pmsdo = h_org-vkorg.
        <ls_object_tab>-vtweg_pmsdo = h_org-vtweg.
        <ls_object_tab>-spart_pmsdo = h_org-spart.
        <ls_object_tab>-vkgrp       = h_org-vkgrp.
        <ls_object_tab>-vkbur       = h_org-vkbur.
        <ls_object_tab>-bstkd       = h_org-bstkd.
        <ls_object_tab>-bstdk       = h_org-bstdk.
        <ls_object_tab>-serv_matnr  = h_org-matnr.
        <ls_object_tab>-menge       = h_org-menge.
        <ls_object_tab>-meins       = h_org-meins.
        <ls_object_tab>-faktf       = h_org-faktf.
        IF g_maktx_flag = yes.
*--- Bezeichung Serviceprodukt nachlesen
          IF NOT <ls_object_tab>-serv_matnr IS INITIAL.
            CALL FUNCTION 'IREP1_MATERIAL_TEXT_READ'
              EXPORTING
                i_matnr       = <ls_object_tab>-serv_matnr
              IMPORTING
                e_maktx       = <ls_object_tab>-serv_maktx
              EXCEPTIONS
                no_text_found = 1
                OTHERS        = 2.
          ENDIF.
        ENDIF.
      ENDIF.
    ENDIF.
*--- Equipmentbezeichnung bestimmen ---------------------------------*
    IF g_eqktx_flag = yes.
      IF NOT <ls_object_tab>-equnr IS INITIAL.
        CALL FUNCTION 'IREP1_EQUIPMENT_TEXT_READ'
          EXPORTING
            i_equnr       = <ls_object_tab>-equnr
          IMPORTING
            e_eqktx       = <ls_object_tab>-eqktx
          EXCEPTIONS
            no_text_found = 1
            OTHERS        = 2.
      ENDIF.
    ENDIF.
*--- Platzbezeichnung bestimmen -------------------------------------*
    IF g_pltxt_flag = yes.
      IF NOT <ls_object_tab>-tplnr_int IS INITIAL.
        CALL FUNCTION 'IREP1_LOCATION_TEXT_READ'
          EXPORTING
            i_tplnr       = <ls_object_tab>-tplnr_int
          IMPORTING
            e_pltxt       = <ls_object_tab>-pltxt
          EXCEPTIONS
            no_text_found = 1
            OTHERS        = 2.
      ENDIF.
    ENDIF.
*--- Materialbezeichung bestimmen ------------------------------------*
    IF g_maktx_flag = yes.
      IF NOT <ls_object_tab>-sermat IS INITIAL.
        CALL FUNCTION 'IREP1_MATERIAL_TEXT_READ'
          EXPORTING
            i_matnr       = <ls_object_tab>-sermat
          IMPORTING
            e_maktx       = <ls_object_tab>-maktx
          EXCEPTIONS
            no_text_found = 1
            OTHERS        = 2.
      ENDIF.
      IF NOT <ls_object_tab>-bautl IS INITIAL.
        CALL FUNCTION 'IREP1_MATERIAL_TEXT_READ'
          EXPORTING
            i_matnr       = <ls_object_tab>-bautl
          IMPORTING
            e_maktx       = <ls_object_tab>-bautlx
          EXCEPTIONS
            no_text_found = 1
            OTHERS        = 2.
      ENDIF.
    ENDIF.
*--- Adresse bestimmen -----------------------------------------------*
    IF g_adres_flag = yes OR g_adres_flag = ok.
*--- Wenn keine Adresse gepflegt, Adresse aus Meldung übernehmen
      IF <ls_object_tab>-adrnra IS INITIAL AND NOT
         <ls_object_tab>-qmnum IS INITIAL.
        READ TABLE h_qmel_tab WITH KEY qmnum = <ls_object_tab>-qmnum
                                   BINARY SEARCH.
        IF sy-subrc IS INITIAL.
          <ls_object_tab>-adrnra = h_qmel_tab-adrnr.
        ENDIF.
      ENDIF.
      PERFORM get_adress_l USING <ls_object_tab>-objnr
                                 <ls_object_tab>-adrnra
                                 <ls_object_tab>-adrnr_iloa
                                 <ls_object_tab>-kunum
                                 <ls_object_tab>-name_list
                                 <ls_object_tab>-post_code1
                                 <ls_object_tab>-city1
                                 <ls_object_tab>-city2
                                 <ls_object_tab>-country
                                 <ls_object_tab>-region
                                 <ls_object_tab>-street
                                 <ls_object_tab>-tel_number.
    ENDIF.
*--- Dispokennzeichen setzten
    PERFORM set_audisp_l CHANGING <ls_object_tab>.
*--- Ampel setzten
    IF NOT g_monitor_field IS INITIAL.
      PERFORM set_object_tab_lights_l CHANGING <ls_object_tab>.
    ENDIF.
*--- Text zur Priorität nachlesen
    IF g_priokx_flag = yes.
      PERFORM get_priokx_f23 USING <ls_object_tab>-artpr
                                   <ls_object_tab>-priok
                          CHANGING <ls_object_tab>-priokx.
    ENDIF.

* DFPS Start
    IF NOT lo_dfps_badi01 IS INITIAL.
      BREAK-POINT ID dfps_pm_is.
      TRY.
          CALL BADI lo_dfps_badi01->get_riaufk20_data
            CHANGING
              object_rec = <ls_object_tab>.

        CATCH cx_badi_initial_reference.                "#EC NO_HANDLER
        CATCH cx_sy_dyn_call_illegal_method.            "#EC NO_HANDLER
      ENDTRY.
    ENDIF.
* DFPS End
  ENDLOOP.

  IF g_kost_flag = yes.
    g_kost_flag = ok.
  ENDIF.

  IF g_arbpl_flag = yes.
    g_arbpl_flag = ok.
  ENDIF.

  IF g_eqktx_flag = yes.
    g_eqktx_flag = ok.
  ENDIF.

  IF g_pltxt_flag = yes.
    g_pltxt_flag = ok.
  ENDIF.

  IF g_maktx_flag = yes.
    g_maktx_flag = ok.
  ENDIF.

  IF g_gewrk_flag = yes.
    g_gewrk_flag = ok.
  ENDIF.

  IF g_adres_flag = yes.
    g_adres_flag = ok.
  ENDIF.

  IF g_vorue_flag = yes.
    g_vorue_flag = ok.
  ENDIF.

ENDFORM.                    "fill_object_tab_l



*eject
*---------------------------------------------------------------------*
*       FORM STATUS_PROOF_L                                           *
*---------------------------------------------------------------------*
*       Statusbedingungen überprüfen                                  *
*---------------------------------------------------------------------*
*  -->  i_objnr
*  -->  F_ANSWER                                                      *
*---------------------------------------------------------------------*
FORM status_proof_l USING i_objnr  TYPE j_objnr
                          f_answer TYPE char01.

  DATA: BEGIN OF h_status_tab OCCURS 20.
          INCLUDE STRUCTURE jstat.
  DATA: END OF h_status_tab.

  DATA: BEGIN OF h_status_text_tab OCCURS 20,
          txt04 LIKE tj02t-txt04.
  DATA: END OF h_status_text_tab.
  DATA: h_stat_flag.

  REFRESH: h_status_tab,
           h_status_text_tab.

*--- If order has no status show it ever
  f_answer = yes.

  CALL FUNCTION 'STATUS_READ'
    EXPORTING
      objnr       = i_objnr
      only_active = 'X'
    TABLES
      status      = h_status_tab
    EXCEPTIONS
      OTHERS      = 01.
  CHECK sy-subrc = 0.

*--- Texte zur Tabelle besorgen -------------------------------------*
  LOOP AT h_status_tab.
    CALL FUNCTION 'STATUS_NUMBER_CONVERSION'
      EXPORTING
        language      = sy-langu
        objnr         = i_objnr
        status_number = h_status_tab-stat
      IMPORTING
        txt04         = h_status_text_tab-txt04
      EXCEPTIONS
        OTHERS        = 01.
    IF sy-subrc = 0.
      APPEND h_status_text_tab.
    ENDIF.
  ENDLOOP.

  f_answer = no.

*--- 1. Status inclusiv ----------------------------------------------*
  IF NOT g_stai1_lines IS INITIAL.
    h_stat_flag = ' '.
    LOOP AT h_status_text_tab.
      CHECK h_status_text_tab-txt04 IN stai1.
      h_stat_flag = 'X'.
      EXIT.
    ENDLOOP.
    IF h_stat_flag = ' '.
      EXIT.
    ENDIF.
  ENDIF.

*--- 1. Status exclusiv ---------------------------------------------
  IF NOT g_stae1_lines IS INITIAL.
    h_stat_flag = ' '.
    LOOP AT h_status_text_tab.
      CHECK h_status_text_tab-txt04 IN stae1.
      h_stat_flag = 'X'.
      EXIT.
    ENDLOOP.
    IF h_stat_flag = 'X'.
      EXIT.
    ENDIF.
  ENDIF.

  f_answer = yes.

ENDFORM.                    "status_proof_l
*eject
*---------------------------------------------------------------------*
*       FORM DISPLAY_CONF_L                                           *
*---------------------------------------------------------------------*
*       Rückmeldung über Auftragsvorgangsliste                        *
*---------------------------------------------------------------------*
FORM display_conf_l.

  DATA: f_tcode LIKE sy-tcode.
  DATA: f_retc LIKE sy-subrc.

  f_tcode = 'IW48'.

*--- Berechtigungsprüfung auf T-code -------------------------------*
  PERFORM auth_check_tcode_f16 USING f_tcode
                               CHANGING f_retc.
  IF f_retc IS INITIAL.
    PERFORM create_range_l.
    IF NOT object IS INITIAL.
      SET PARAMETER ID 'WRK' FIELD space.
      SET PARAMETER ID 'AGR' FIELD space.
      SUBMIT riafvc10 WITH aufnr IN object
                      WITH dy_tcode = f_tcode
                      WITH dy_ofn   = 'X'
                      WITH dy_mab   = 'X'
                      WITH dy_pmonl = 'X'
                      WITH dy_mulen = 'X'
             AND RETURN.
    ENDIF.
  ENDIF.

ENDFORM.                    "display_conf_l


*eject
*---------------------------------------------------------------------*
*       FORM DISPLAY_AVOL_L                                           *
*---------------------------------------------------------------------*
*       Auftragsvorgangsliste                                         *
*---------------------------------------------------------------------*
FORM display_avol_l USING f_sel TYPE c.

  DATA: f_tcode LIKE sy-tcode.
  DATA: f_retc LIKE sy-subrc.
  DATA: h_akt.

  IF t370a-aktyp = 'V'.
    f_tcode = 'IW37'.
  ELSE.
    f_tcode = 'IW49'.
  ENDIF.

*--- aktuelle Vorgänge nur wenn auch aktuelle Aufträge --------------
*--- historische Vorgänge nur wenn auch historische Auträge ---------
  IF dy_ofn IS INITIAL AND
     dy_iar IS INITIAL AND
     dy_mab IS INITIAL.
    CLEAR h_akt.
  ELSE.
    h_akt = g_x.
  ENDIF.

*--- Berechtigungsprüfung auf T-code -------------------------------*
  PERFORM auth_check_tcode_f16 USING f_tcode
                               CHANGING f_retc.
  IF f_retc IS INITIAL.
    PERFORM create_range_l.
    IF NOT object IS INITIAL.
      SET PARAMETER ID 'WRK' FIELD space.
      SET PARAMETER ID 'AGR' FIELD space.
      IF f_sel IS INITIAL.
        SUBMIT riafvc20 WITH aufnr IN object
                        WITH dy_akt = h_akt
                        WITH dy_ofn = h_akt
                        WITH dy_mab = h_akt
                        WITH dy_his = dy_his
                        WITH dy_tcode = f_tcode
               AND RETURN.
      ELSE.
        SUBMIT riafvc20 WITH aufnr IN object
                        WITH dy_akt = h_akt
                        WITH dy_ofn = h_akt
                        WITH dy_mab = h_akt
                        WITH dy_his = dy_his
                        WITH dy_tcode = f_tcode
               VIA SELECTION-SCREEN
               AND RETURN.
      ENDIF.
    ENDIF.
  ENDIF.

ENDFORM.                    "display_avol_l

*eject
*---------------------------------------------------------------------*
*       FORM DISPLAY_AFRU_L                                           *
*---------------------------------------------------------------------*
*       Auftragsrückmeldeliste                                        *
*---------------------------------------------------------------------*
FORM display_afru_l.

  DATA: f_tcode LIKE sy-tcode VALUE 'IW47'.
  DATA: f_retc LIKE sy-subrc.

  RANGES h_date FOR  sy-datum.

*--- Berechtigungsprüfung auf T-code -------------------------------*
  PERFORM auth_check_tcode_f16 USING f_tcode
                               CHANGING f_retc.
  IF f_retc IS INITIAL.
*--- Datum vorbelegen
    h_date-sign   = 'I'.
    h_date-option = 'BT'.
    h_date-low    = '00000000'.
    h_date-high   = '99991231'.
    APPEND h_date.
*--- Auftragsnummern sammeln
    PERFORM create_range_l.
    IF NOT object[] IS INITIAL.
      SUBMIT riafru20 WITH aufnr_o      IN object
                      WITH dy_iar       = dy_iar
                      WITH dy_abg       = dy_mab
                      WITH dy_tcode     = f_tcode
                      WITH ersda_c      IN h_date
                      VIA SELECTION-SCREEN
             AND RETURN.
    ENDIF.
  ENDIF.

ENDFORM.                    "display_afru_l

*eject
*---------------------------------------------------------------------*
*       FORM DISPLAY_IFLO_L                                           *
*---------------------------------------------------------------------*
*       Technische Plätze                                             *
*---------------------------------------------------------------------*
FORM display_iflo_l.

  DATA: f_tcode LIKE sy-tcode.
  DATA: f_retc LIKE sy-subrc.

*--- Wenn in Serviceliste (Auft) dann in Serviceliste (T.P.) springen *
  IF dy_tcode = 'IW72' OR dy_tcode = 'IW73'.
    f_tcode = 'IH11'.
  ELSE.
    f_tcode = 'IH06'.
  ENDIF.

*--- Berechtigungsprüfung auf T-code -------------------------------*
  PERFORM auth_check_tcode_f16 USING f_tcode
                               CHANGING f_retc.
  IF f_retc IS INITIAL.
    PERFORM create_range_iflo_l.
    IF NOT i_tplnr IS INITIAL.
      EXPORT f_tcode TO MEMORY ID 'RIIFLO20'.
      SUBMIT riiflo20 WITH tplnr IN i_tplnr
                      WITH dy_tcode = f_tcode
             AND RETURN.
    ENDIF.
  ENDIF.

ENDFORM.                    "display_iflo_l

*eject
*---------------------------------------------------------------------*
*       FORM DISPLAY_EQUI_L                                           *
*---------------------------------------------------------------------*
*       Equipments                                                    *
*---------------------------------------------------------------------*
FORM display_equi_l.

  DATA: f_tcode LIKE sy-tcode.
  DATA: f_retc LIKE sy-subrc.

*--- Wenn in Serviceliste (Auft) dann in Serviceliste (Equi) springen *
  IF dy_tcode = 'IW72' OR dy_tcode = 'IW73'.
    f_tcode = 'IH10'.
  ELSE.
    f_tcode = 'IH08'.
  ENDIF.

*--- Berechtigungsprüfung auf T-code -------------------------------*
  PERFORM auth_check_tcode_f16 USING f_tcode
                               CHANGING f_retc.
  IF f_retc IS INITIAL.
    PERFORM create_range_equi_l.
    IF NOT i_equnr IS INITIAL.
      EXPORT f_tcode TO MEMORY ID 'RIEQUI20'.
      SUBMIT riequi20 WITH equnr IN i_equnr
                      WITH dy_tcode = f_tcode
             AND RETURN.
    ENDIF.
  ENDIF.

ENDFORM.                    "display_equi_l

*eject
*---------------------------------------------------------------------*
*       FORM DISPLAY_MARA_L                                           *
*---------------------------------------------------------------------*
*       IH-Baugruppen                                                 *
*---------------------------------------------------------------------*
FORM display_mara_l.

  DATA: f_tcode LIKE sy-tcode.
  DATA: f_retc LIKE sy-subrc.

  f_tcode = 'IH09'.

*--- Berechtigungsprüfung auf T-code -------------------------------*
  PERFORM auth_check_tcode_f16 USING f_tcode
                               CHANGING f_retc.
  IF f_retc IS INITIAL.
    PERFORM create_range_mara_l.
    IF NOT i_bautl IS INITIAL.
      SUBMIT rimara20 WITH ms_matnr IN i_bautl
                      WITH dy_tcode = f_tcode
             AND RETURN.
    ENDIF.
  ENDIF.

ENDFORM.                    "display_mara_l

*eject
*---------------------------------------------------------------------*
*       FORM AUTHORITY_CHECK_L                                        *
*---------------------------------------------------------------------*
*       Berechtigungen prüfen                                         *
*---------------------------------------------------------------------*
FORM authority_check_l.

  DATA: BEGIN OF h_equi_tab OCCURS 100,
            mandt LIKE sy-mandt,
            equnr LIKE equi-equnr,
            begru LIKE equi-begru.
  DATA: END OF h_equi_tab.

  DATA: BEGIN OF h_iflo_tab OCCURS 100,
             mandt LIKE sy-mandt,
             tplnr LIKE iflot-tplnr,
             begru LIKE iflot-begru.
  DATA: END OF h_iflo_tab.

  DATA: h_t370b_wa   LIKE t370b.
  DATA: h_begru      LIKE equi-begru.
  DATA: f_tcode      LIKE sy-tcode VALUE 'IW33'.
  DATA: h_no_auth.
  DATA: h_begru_ind  LIKE sy-dbcnt.

  FIELD-SYMBOLS: <ls_object_tab> LIKE LINE OF object_tab.

*--- Prüfung Berechtigungsgruppe nur wenn im Cust. gepflegt --------*
  SELECT SINGLE * FROM t370b INTO h_t370b_wa.
  IF sy-subrc IS INITIAL. h_begru_ind = 1. ENDIF.
*--- Berechtigungen aus Objekstammsatz nachlesen für Prüfung --------*
  IF NOT g_equnr_tab[] IS INITIAL.
    SORT g_equnr_tab.
    DELETE ADJACENT DUPLICATES FROM g_equnr_tab.
    IF NOT h_begru_ind IS INITIAL.
      SELECT mandt equnr begru INTO TABLE h_equi_tab FROM equi
                                    FOR ALL ENTRIES IN g_equnr_tab
                                    WHERE equnr = g_equnr_tab-equnr
                                    ORDER BY PRIMARY KEY.
    ENDIF.
  ENDIF.
  IF NOT g_tplnr_tab[] IS INITIAL.
    SORT g_tplnr_tab.
    DELETE ADJACENT DUPLICATES FROM g_tplnr_tab.
    IF NOT h_begru_ind IS INITIAL.
      SELECT mandt tplnr begru INTO TABLE h_iflo_tab FROM iflot
                                    FOR ALL ENTRIES IN g_tplnr_tab
                                    WHERE tplnr = g_tplnr_tab-tplnr
                                    ORDER BY PRIMARY KEY.
    ENDIF.
  ENDIF.

  h_no_auth = no.
*--- Sortieren wegen Pufferung FB -----------------------------------*
  SORT object_tab BY auart iwerk swerk equnr tplnr.

  LOOP AT object_tab ASSIGNING <ls_object_tab>.
*--- Berechtigungsgruppe aus Bezugsobject ermitteln -----------------*
    IF NOT h_begru_ind IS INITIAL.
      CLEAR h_begru.
      IF NOT <ls_object_tab>-equnr IS INITIAL.
        IF NOT h_equi_tab-equnr = <ls_object_tab>-equnr.
          READ TABLE h_equi_tab WITH KEY mandt = sy-mandt
                                         equnr = <ls_object_tab>-equnr
                                         BINARY SEARCH.
        ENDIF.
        IF sy-subrc IS INITIAL.
          h_begru = h_equi_tab-begru.
        ENDIF.
      ELSEIF NOT <ls_object_tab>-tplnr_int IS INITIAL.
        IF NOT h_iflo_tab-tplnr = <ls_object_tab>-tplnr_int.
          READ TABLE h_iflo_tab WITH KEY mandt = sy-mandt
                                     tplnr = <ls_object_tab>-tplnr_int
                                         BINARY SEARCH.
        ENDIF.
        IF sy-subrc IS INITIAL.
          h_begru = h_iflo_tab-begru.
        ENDIF.
      ENDIF.
    ENDIF.
    CALL FUNCTION 'INST_AUTHORITY_CHECK_ALL'
         EXPORTING
              begrp                    = h_begru
              iwerk                    = <ls_object_tab>-iwerk
              swerk                    = <ls_object_tab>-swerk
              tcode                    = f_tcode
              auart                    = <ls_object_tab>-auart
              ingrp                    = <ls_object_tab>-ingpr
*             AKTTYP                   = ' '
              kokrs                    = <ls_object_tab>-kokrs
              kostl                    = <ls_object_tab>-kostl
         EXCEPTIONS
              keine_berechtigung_begrp = 1
              keine_berechtigung_iwerk = 2
              keine_berechtigung_swerk = 3
              keine_berechtigung_auart = 4
              keine_berechtigung_ingrp = 5
              keine_berechtigung_kostl = 6
              OTHERS                   = 7.

    IF sy-subrc <> 0.
      h_no_auth = yes.
      DELETE object_tab. CONTINUE.
    ENDIF.
  ENDLOOP.

  IF h_no_auth = yes AND NOT dy_msgty IS INITIAL.
    MESSAGE ID 'IH' TYPE dy_msgty NUMBER '046'.
  ENDIF.

ENDFORM.                    "authority_check_l

*eject
*---------------------------------------------------------------------*
*       FORM CREATE_RANGE_L                                           *
*---------------------------------------------------------------------*
*       Range mit selektierten Objekten erstellen                     *
*---------------------------------------------------------------------*
FORM create_range_l.

  CLEAR object.
  REFRESH object.
  LOOP AT object_tab WHERE selected = g_x.
    PERFORM mark_selected_f16 CHANGING object_tab-selected
                                       object_tab-pm_selected.
    CLEAR object.
    object-option = 'EQ'.
    object-sign   = 'I'.
    object-low    = object_tab-aufnr.
    APPEND object.
  ENDLOOP.
  IF object IS INITIAL.
    MESSAGE i011.
  ENDIF.


ENDFORM.                    "create_range_l

*eject
*---------------------------------------------------------------------*
*       FORM CREATE_RANGE_IFLO_L                                      *
*---------------------------------------------------------------------*
*       Range mit selektierten Techn. Plätzen                         *
*---------------------------------------------------------------------*
FORM create_range_iflo_l.

  CLEAR i_tplnr.
  REFRESH i_tplnr.
  LOOP AT object_tab WHERE selected = g_x.
    PERFORM mark_selected_f16 CHANGING object_tab-selected
                                       object_tab-pm_selected.
    CHECK NOT object_tab-tplnr_int IS INITIAL.
    CLEAR i_tplnr.
    i_tplnr-option = 'EQ'.
    i_tplnr-sign   = 'I'.
    i_tplnr-low    = object_tab-tplnr_int.
    COLLECT i_tplnr.
  ENDLOOP.
  IF i_tplnr IS INITIAL.
    MESSAGE i170.
  ENDIF.


ENDFORM.                    "create_range_iflo_l

*eject
*---------------------------------------------------------------------*
*       FORM CREATE_RANGE_EQUI_L                                      *
*---------------------------------------------------------------------*
*       Range mit selektierten Equipments                             *
*---------------------------------------------------------------------*
FORM create_range_equi_l.

  CLEAR i_equnr.
  REFRESH i_equnr.
  LOOP AT object_tab WHERE selected = g_x.
    PERFORM mark_selected_f16 CHANGING object_tab-selected
                                       object_tab-pm_selected.
    CHECK NOT object_tab-equnr IS INITIAL.
    CLEAR i_equnr.
    i_equnr-option = 'EQ'.
    i_equnr-sign   = 'I'.
    i_equnr-low    = object_tab-equnr.
    COLLECT i_equnr.
  ENDLOOP.
  IF i_equnr IS INITIAL.
    MESSAGE i171.
  ENDIF.


ENDFORM.                    "create_range_equi_l

*eject
*---------------------------------------------------------------------*
*       FORM CREATE_RANGE_AUFNR_PLANTAFEL.                            *
*---------------------------------------------------------------------*
*       Range mit selektierten Aufträge.                              *
*---------------------------------------------------------------------*
FORM create_range_aufnr_plantafel.

  CLEAR: i_fil_tab,i_fil_tab[].

  LOOP AT object_tab WHERE selected = g_x.
    PERFORM mark_selected_f16 CHANGING object_tab-selected
                                       object_tab-pm_selected.
    CHECK NOT object_tab-aufnr IS INITIAL.
    CLEAR i_fil_tab.
* here 01 as filter.......
* change later for gruppe
    i_fil_tab-filgru = '01'.
    i_fil_tab-feld   = 'AUFNR'.
    i_fil_tab-sign   = 'I'.
    i_fil_tab-option = 'EQ'.
    i_fil_tab-low    = object_tab-aufnr.
    i_fil_tab-high   = object_tab-aufnr.
    COLLECT i_fil_tab.
  ENDLOOP.
  IF i_fil_tab[] IS INITIAL.
    MESSAGE i011.
  ENDIF.


ENDFORM.                    "create_range_aufnr_plantafel

*eject
*---------------------------------------------------------------------*
*       FORM CREATE_RANGE_MARA_L                                      *
*---------------------------------------------------------------------*
*       Range mit selektierten Equipments                             *
*---------------------------------------------------------------------*
FORM create_range_mara_l.

  CLEAR i_bautl.
  REFRESH i_bautl.
  LOOP AT object_tab WHERE selected = g_x.
    PERFORM mark_selected_f16 CHANGING object_tab-selected
                                       object_tab-pm_selected.
    CHECK NOT object_tab-bautl IS INITIAL.
    CLEAR i_bautl.
    i_bautl-option = 'EQ'.
    i_bautl-sign   = 'I'.
    i_bautl-low    = object_tab-bautl.
    COLLECT i_bautl.
  ENDLOOP.
  IF i_bautl IS INITIAL.
    MESSAGE i174.
  ENDIF.
ENDFORM.                    "create_range_mara_l


*---------------------------------------------------------------------*
*       FORM FILL_OBJECT_TAB_LATE_L                                   *
*---------------------------------------------------------------------*
*       Sonderbehandlung Felder nach Ausflug                          *
*---------------------------------------------------------------------*
FORM fill_object_tab_late_l.

  DATA h_org LIKE pmsdo.

  CALL FUNCTION 'STATUS_BUFFER_REFRESH'
    EXPORTING
      i_free = ' '.

*--- Statusleiste füllen ---------------------------------------------*
  IF g_sttxt_flag = yes OR g_sttxt_flag = ok.
    CLEAR: object_tab-sttxt, object_tab-ustxt.
    IF object_tab-iphas <> '9'.
      CALL FUNCTION 'STATUS_TEXT_EDIT'
        EXPORTING
          objnr            = object_tab-objnr
          spras            = sy-langu
          flg_user_stat    = 'X'
        IMPORTING
          line             = object_tab-sttxt
          user_line        = object_tab-ustxt
        EXCEPTIONS
          object_not_found = 01.
      IF NOT sy-subrc IS INITIAL.
        CLEAR object_tab-sttxt.
        CLEAR object_tab-ustxt.
      ENDIF.
    ENDIF.
  ENDIF.
*--- Externes Leitgewerk bestimmen -----------------------------------*
  IF g_gewrk_flag = yes OR g_gewrk_flag = ok.
    IF NOT object_tab-igewrk IS INITIAL.
      CALL FUNCTION 'CR_WORKSTATION_READ'
        EXPORTING
          id        = object_tab-igewrk
          msgty     = 'S'
        IMPORTING
          werks     = object_tab-awerk
          arbpl     = object_tab-gewrk
        EXCEPTIONS
          not_found = 01.
      IF sy-subrc <> 0.
        CLEAR object_tab-gewrk.
        CLEAR object_tab-awerk.
      ENDIF.
    ELSE.
      CLEAR object_tab-gewrk.
      CLEAR object_tab-awerk.
    ENDIF.
  ENDIF.
*--- PPS-Arbeitsplatz lesen
  IF g_arbpl_flag = yes OR g_arbpl_flag = ok.
    IF NOT object_tab-ppsid IS INITIAL.
      CALL FUNCTION 'CR_WORKSTATION_READ'
        EXPORTING
          id        = object_tab-ppsid
          msgty     = 'S'
        IMPORTING
          arbpl     = object_tab-arbpl
        EXCEPTIONS
          not_found = 01.
      IF sy-subrc <> 0.
        CLEAR object_tab-arbpl.
      ENDIF.
    ELSE.
      CLEAR object_tab-arbpl.
    ENDIF.
  ENDIF.
*--- Equibezeichnung bestimmen -------------------------------------*
  IF g_eqktx_flag = yes OR g_eqktx_flag = ok.
    CLEAR object_tab-eqktx.
    IF NOT object_tab-equnr IS INITIAL.
      CALL FUNCTION 'IREP1_EQUIPMENT_TEXT_READ'
        EXPORTING
          i_equnr       = object_tab-equnr
        IMPORTING
          e_eqktx       = object_tab-eqktx
        EXCEPTIONS
          no_text_found = 1
          OTHERS        = 2.
      IF NOT sy-subrc IS INITIAL.
        CLEAR object_tab-eqktx.
      ENDIF.
    ENDIF.
  ENDIF.
*--- Platzbezeichnung bestimmen -------------------------------------*
  IF g_pltxt_flag = yes OR g_pltxt_flag = ok.
    CLEAR object_tab-pltxt.
    IF NOT object_tab-tplnr_int IS INITIAL.
      CALL FUNCTION 'IREP1_LOCATION_TEXT_READ'
        EXPORTING
          i_tplnr       = object_tab-tplnr_int
        IMPORTING
          e_pltxt       = object_tab-pltxt
        EXCEPTIONS
          no_text_found = 1
          OTHERS        = 2.
    ENDIF.
  ENDIF.
  IF g_maktx_flag = yes OR g_maktx_flag = ok.
    CLEAR object_tab-maktx.
    CLEAR object_tab-bautlx.
    IF NOT object_tab-sermat IS INITIAL.
      CALL FUNCTION 'IREP1_MATERIAL_TEXT_READ'
        EXPORTING
          i_matnr       = object_tab-sermat
        IMPORTING
          e_maktx       = object_tab-maktx
        EXCEPTIONS
          no_text_found = 1
          OTHERS        = 2.
    ENDIF.
    IF NOT object_tab-bautl IS INITIAL.
      CALL FUNCTION 'IREP1_MATERIAL_TEXT_READ'
        EXPORTING
          i_matnr       = object_tab-bautl
        IMPORTING
          e_maktx       = object_tab-bautlx
        EXCEPTIONS
          no_text_found = 1
          OTHERS        = 2.
    ENDIF.
  ENDIF.
*--- Adresse bestimmen ----------------------------------------------*
  IF g_adres_flag = yes OR g_adres_flag = ok.
*--- Wenn keine Adresse gepflegt, Adresse aus Meldung übernehmen
    IF object_tab-adrnra IS INITIAL AND NOT
       object_tab-qmnum IS INITIAL.
      SELECT SINGLE adrnr INTO object_tab-adrnra FROM qmel
                          WHERE qmnum = object_tab-qmnum.
    ENDIF.
    PERFORM get_adress_l USING object_tab-objnr
                               object_tab-adrnra
                               object_tab-adrnr_iloa
                               object_tab-kunum
                               object_tab-name_list
                               object_tab-post_code1
                               object_tab-city1
                               object_tab-city2
                               object_tab-country
                               object_tab-region
                               object_tab-street
                               object_tab-tel_number.
  ENDIF.
*--- Dispokennzeichen setzten
  PERFORM set_audisp_l CHANGING object_tab.
*--- Ampel setzten
  IF NOT g_monitor_field IS INITIAL.
    PERFORM set_object_tab_lights_l CHANGING object_tab.
  ENDIF.
*--- Text zur Priorität nachlesen
  IF g_priokx_flag = yes.
    PERFORM get_priokx_f23 USING object_tab-artpr
                                 object_tab-priok
                        CHANGING object_tab-priokx.
  ENDIF.
*-- Organisationsdaten lesen ---------------------------------------*
  IF g_pmsdo_flag = yes OR g_pmsdo_flag = ok.
    CALL FUNCTION 'PMSDO_READ'
      EXPORTING
        objnr     = object_tab-objnr
      IMPORTING
        org       = h_org
      EXCEPTIONS
        not_found = 1
        OTHERS    = 2.
    IF sy-subrc = 0.
      object_tab-vkorg_pmsdo = h_org-vkorg.
      object_tab-vtweg_pmsdo = h_org-vtweg.
      object_tab-spart_pmsdo = h_org-spart.
      object_tab-vkgrp       = h_org-vkgrp.
      object_tab-vkbur       = h_org-vkbur.
      object_tab-bstkd       = h_org-bstkd.
      object_tab-bstdk       = h_org-bstdk.
      object_tab-serv_matnr  = h_org-matnr.
      object_tab-menge       = h_org-menge.
      object_tab-meins       = h_org-meins.
      object_tab-faktf       = h_org-faktf.
      IF g_maktx_flag = yes OR g_maktx_flag = ok.
*--- Bezeichung Serviceprodukt nachlesen
        IF NOT object_tab-serv_matnr IS INITIAL.
          CALL FUNCTION 'IREP1_MATERIAL_TEXT_READ'
            EXPORTING
              i_matnr       = object_tab-serv_matnr
            IMPORTING
              e_maktx       = object_tab-serv_maktx
            EXCEPTIONS
              no_text_found = 1
              OTHERS        = 2.
        ENDIF.
      ENDIF.
    ENDIF.
  ENDIF.

  MODIFY object_tab.

ENDFORM.                    "fill_object_tab_late_l




*eject
*----------------------------------------------------------------------
* FORM EXTERN_AUSZT_ERMITTELN_L
*----------------------------------------------------------------------
* Externe / Interne dauer Umrechnen und ermitteln
*----------------------------------------------------------------------
FORM extern_gauzt_ermitteln_l USING
                              f_iauszt TYPE auszt
                              f_oauszt TYPE eauszt
                              f_maueh  TYPE maueh.

  DATA: h_liauszt TYPE f.
  DATA: h_loauszt TYPE f.

  IF f_iauszt IS INITIAL.
    CLEAR f_oauszt.
*   clear f_maueh.
    EXIT.
  ENDIF.

*--- data in Floatingpoint -------------------------------------------*
  h_liauszt = f_iauszt.
  h_loauszt = f_oauszt.

*---- Konvertierung der Werte ----------------------------------------*
  CALL FUNCTION 'UNIT_CONVERSION_SIMPLE'
    EXPORTING
      input    = h_liauszt
      unit_in  = g_imaueh
      unit_out = g_emaueh
    IMPORTING
      output   = h_loauszt.

*--- Rueck-konvertierung ---------------------------------------------*
  f_iauszt = h_liauszt.
  f_oauszt = h_loauszt.
  f_maueh  = g_emaueh.

ENDFORM.                    "extern_gauzt_ermitteln_l

*eject
*----------------------------------------------------------------------*
*     FORM DIMENSION_UNIT_L USING IMAUEH EMAUEH                        *
*----------------------------------------------------------------------*
* Ermittlung der Dimension / Interne bzw Externe Einheit               *
* Interne Einheit immer in Sekunde
* Externe Einheit immer in stunden
*----------------------------------------------------------------------*

FORM dimension_unit_l.

  DATA: h_dimid LIKE t006d-dimid.
  DATA: h_ltimex LIKE t006d-timex VALUE 1.
  DATA: h_lzaehl LIKE t006-zaehl VALUE 1.
  DATA: h_lnennr LIKE t006-nennr VALUE 1.

*--- Dimension fuer Sekunde ermitteln --------------------------------*
  CALL FUNCTION 'FIND_BASE_DIMENSION'
    EXPORTING
      timex = h_ltimex
    IMPORTING
      dimid = h_dimid.

*--- Einheit fuer Sekunde ermitteln ----------------------------------*
  CALL FUNCTION 'FIND_BASE_UNIT'
    EXPORTING
      dimid          = h_dimid
      nennr          = h_lnennr
      zaehl          = h_lzaehl
    IMPORTING
      msehi          = g_imaueh
    EXCEPTIONS
      unit_not_found = 4.

*--- Einheit fuer Stunde  ermitteln ----------------------------------*
  h_lzaehl = 3600.
  CALL FUNCTION 'FIND_BASE_UNIT'
    EXPORTING
      dimid          = h_dimid
      nennr          = h_lnennr
      zaehl          = h_lzaehl
    IMPORTING
      msehi          = g_emaueh
    EXCEPTIONS
      unit_not_found = 4.

ENDFORM.                    "dimension_unit_l
*### Grafik ##########################################################*

*### Datenvereinbarungen ############################################*

*----------------------------------------------------------------------*
* Definition der ITEM-Tabelle (Zeilen der Grafik)
*----------------------------------------------------------------------*

DATA: BEGIN OF item OCCURS 1.
        INCLUDE STRUCTURE ggait.
DATA: END OF item.

*----------------------------------------------------------------------*
* Definition der ELEM-Tabelle (Objekte in der Grafik)
*----------------------------------------------------------------------*

DATA: BEGIN OF elem OCCURS 1.
        INCLUDE STRUCTURE ggael.
DATA: END OF elem.
DATA: BEGIN OF lgel OCCURS 1.
        INCLUDE STRUCTURE ggael.
DATA: END OF lgel.
DATA: BEGIN OF dfel.
        INCLUDE STRUCTURE ggael.
DATA: END OF dfel.

*----------------------------------------------------------------------*
* Definition der MIST-Tabelle (Objekte in der Grafik)
*----------------------------------------------------------------------*

DATA: BEGIN OF mist OCCURS 1.
        INCLUDE STRUCTURE ggami.
DATA: END OF mist.
DATA: BEGIN OF dfms.
        INCLUDE STRUCTURE ggami.
DATA: END OF dfms.

*----------------------------------------------------------------------*
* Definition der Rueckmeldetabelle
*----------------------------------------------------------------------*

DATA: BEGIN OF back OCCURS 1.
        INCLUDE STRUCTURE ggaba.
DATA: END OF back.

*---------------------------------------------------------------------*
*       FORM GRAFICS_L                                                *
*---------------------------------------------------------------------*
*       Grafik aufrufen                                               *
*---------------------------------------------------------------------*
FORM grafics_l USING p_selfield TYPE slis_selfield.

  DATA: h_dur LIKE ggael-dur,
        h_tabix LIKE sy-tabix,
        h_selec,
        h_strlen     LIKE sy-fdpos,
        h_strlen_tmp LIKE sy-fdpos.


  REFRESH: item,
           mist,
           elem,
           lgel,
           back.

  h_selec = no.
  h_tabix = 0.
  h_strlen = 0.
  h_strlen_tmp = 0.

  LOOP AT object_tab WHERE selected = g_x.
    PERFORM select_for_quickinfo_l USING p_selfield.
    PERFORM mark_selected_f16 CHANGING object_tab-selected
                                       object_tab-pm_selected.
    h_selec = yes.
    h_tabix = h_tabix + 1.
    IF ( NOT object_tab-gltrp IS INITIAL ) AND
       ( NOT object_tab-gstrp IS INITIAL ).
      h_dur = object_tab-gltrp - object_tab-gstrp.
      h_dur = h_dur * 24 * 60 * 60.
      h_dur = h_dur + ( object_tab-gluzp - object_tab-gsuzp ).
      PERFORM fill_elem USING
                  h_tabix              "Itemnummer
                  ' '                  "Balkenbeschriftung
                  object_tab-gstrp     "Beginndatum
                  object_tab-gsuzp     "Beginnuhrzeit
                  h_dur                "Dauer
                  'S'                  "Zeiteinheit Dauer
                  'BLUE'               "Farbe Balken
                  '4'                  "Größe Balken
                  'U'.                 "Position Balken
    ENDIF.
    IF ( NOT object_tab-anlvd IS INITIAL ) AND
       ( NOT object_tab-anlbd IS INITIAL ).
      h_dur = object_tab-anlbd - object_tab-anlvd.
      h_dur = h_dur * 24 * 60 * 60.
      h_dur = h_dur + ( object_tab-anlbz - object_tab-anlvz ).
      PERFORM fill_elem USING
                  h_tabix              "Itemnummer
                  ' '                  "Balkenbeschriftung
                  object_tab-anlvd     "Beginndatum
                  object_tab-anlvz     "Beginnuhrzeit
                  h_dur                "Dauer
                  'S'                  "Zeiteinheit Dauer
                  'RED'                "Farbe Balken
                  '4'                  "Größe Balken
                  'C'.                 "Position Balken
    ENDIF.
    IF ( NOT object_tab-gstri IS INITIAL ) AND
       ( NOT object_tab-getri IS INITIAL ).
      h_dur = object_tab-getri - object_tab-gstri.
      h_dur = h_dur * 24 * 60 * 60.
      h_dur = h_dur + ( object_tab-geuzi - object_tab-gsuzi ).
      PERFORM fill_elem USING
                  h_tabix              "Itemnummer
                  ' '                  "Balkenbeschriftung
                  object_tab-gstri     "Beginndatum
                  object_tab-gsuzi     "Beginnuhrzeit
                  h_dur                "Dauer
                  'S'                  "Zeiteinheit Dauer
                  'GREEN'              "Farbe Balken
                  '4'                  "Größe Balken
                  'L'.                 "Position Balken
    ENDIF.
    WRITE object_tab-aufnr TO item-itext.
    WRITE object_tab-ktext TO item-itext+13.
    CONDENSE item-itext.
    h_strlen_tmp = STRLEN( item-itext ).
    IF h_strlen_tmp > h_strlen.
      h_strlen = h_strlen_tmp.
    ENDIF.

    APPEND item.
  ENDLOOP.

  IF h_selec = no.
    MESSAGE i011.
  ELSE.
    REFRESH back.
    dfel-filld = '1'.
    dfel-brdon = '1'.
    CLEAR g_ttext.
    g_ttext-typ     = tstct-ttext.
    g_ttext-filler = ':'.
    g_ttext-seltext = text-204.
    CONDENSE g_ttext.

*--- Legende aufbauen ----------------------------------------------*
    lgel-itemno = 1.
    lgel-txt = text-201.
    lgel-dur = 60 * 60 * 24 * 5.
    lgel-bakgr = 'BLUE'.
    lgel-heigh = 4.
    lgel-place = 'CENTER'.
    APPEND lgel.
    lgel-itemno = 1.
    lgel-txt = text-202.
    lgel-dur = 60 * 60 * 24 * 5.
    lgel-bakgr = 'RED'.
    lgel-heigh = 4.
    lgel-place = 'CENTER'.
    APPEND lgel.
    lgel-itemno = 1.
    lgel-txt = text-203.
    lgel-dur = 60 * 60 * 24 * 5.
    lgel-bakgr = 'GREEN'.
    lgel-heigh = 4.
    lgel-place = 'CENTER'.
    APPEND lgel.

*--- PF-Status setzten (sichern inaktiv)
    CALL FUNCTION 'GRAPH_SET_CUA_STATUS'
      EXPORTING
        program      = 'SAPLIESC'
        status       = 'GANT'
      EXCEPTIONS
        inv_cua_info = 1
        OTHERS       = 2.

    CALL FUNCTION 'GRAPH_GANTT'
      EXPORTING
        vgrid       = ' '
        hgrid       = 'X'
        wheader     = g_ttext    "Aufträge: Terminübersicht
        ttext       = text-205   "Aufträge
        legend      = text-206   "Legende
        tlength     = h_strlen
        notxt       = space
        tunit       = 'D'
        dfel        = dfel
        dfms        = dfms
        no_ex_popup = 'X'
      TABLES
        item        = item
        mist        = mist
        elem        = elem
        lgms        = mist
        lgel        = lgel
        msgt        = back.
  ENDIF.

ENDFORM.                    "grafics_l

*---------------------------------------------------------------------*
*       FORM FILL_ELEM                                                *
*---------------------------------------------------------------------*
*       Grafik-Balken erstellen                                       *
*---------------------------------------------------------------------*
*  -->  F_ITEMNO               Itemnummer                             *
*  -->  F_TEXT                 Balkentext                             *
*  -->  F_DBEG                 Beginntag                              *
*  -->  F_TBEG                 Beginnuhrzeit                          *
*  -->  F_F_DUR                  Dauer
*  -->  F_UNIT                 Zeiteinheit Dauer                      *
*  -->  f_COL                  Farbe Balken                           *
*  -->  F_SIZE                 Größe Balken                           *
*  -->  F_POS                  Position Balken                        *
*---------------------------------------------------------------------*
FORM fill_elem USING f_itemno TYPE sytabix
                     f_text   TYPE char80
                     f_dbeg   TYPE d
                     f_tbeg   TYPE t
                     f_dur    TYPE sekunden
                     f_unit   TYPE char01
                     f_col    TYPE char20
                     f_size   TYPE char5
                     f_pos    TYPE char01.

*### Datenvereinbarungen #############################################*
  DATA: t TYPE t,
        d TYPE d.

*### Verarbeitung ####################################################*
  elem-itemno = f_itemno.
  elem-txt = f_text.
  d = f_dbeg.
  t = f_tbeg.
  elem-beg = ( d - date_null ) * 86400 + t.
  CASE f_unit.
    WHEN 'S'.
      elem-dur = f_dur.
    WHEN 'M'.
      elem-dur = f_dur * 60.
    WHEN 'H'.
      elem-dur = f_dur * 60 * 60.
    WHEN 'D'.
      elem-dur = f_dur * 60 * 60 * 24.
    WHEN 'W'.
      elem-dur = f_dur * 60 * 60 * 24 * 7.
    WHEN 'N'.
      elem-dur = f_dur * 60 * 60 * 24 * 30.
    WHEN 'Q'.
      elem-dur = f_dur * 60 * 60 * 24 * 90.
    WHEN 'Y'.
      elem-dur = f_dur * 60 * 60 * 24 * 365.
  ENDCASE.
  elem-bakgr = f_col.
  elem-heigh = f_size.
  CASE f_pos.
    WHEN 'U'.
      elem-place = 'OVER'.
    WHEN 'C'.
      elem-place = 'CENTER'.
    WHEN 'L'.
      elem-place = 'BELOW'.
  ENDCASE.
  CHECK elem-dur > 0.
  APPEND elem.
ENDFORM.                    "fill_elem

*&---------------------------------------------------------------------*
*&      Form  CHECK_SEL_FHM_L
*&---------------------------------------------------------------------*
*       Report als Verwendungsnachweis für FHM                      *
*----------------------------------------------------------------------*
FORM check_sel_fhm_l.

  DESCRIBE TABLE s_matnr LINES sy-tabix.
  IF NOT sy-tabix IS INITIAL. g_fhm_flag = yes. ENDIF.
  DESCRIBE TABLE s_werks LINES sy-tabix.
  IF NOT sy-tabix IS INITIAL. g_fhm_flag = yes. ENDIF.
  DESCRIBE TABLE s_equnr LINES sy-tabix.
  IF NOT sy-tabix IS INITIAL. g_fhm_flag = yes. ENDIF.
  DESCRIBE TABLE s_doknr LINES sy-tabix.
  IF NOT sy-tabix IS INITIAL. g_fhm_flag = yes. ENDIF.
  DESCRIBE TABLE s_dokar LINES sy-tabix.
  IF NOT sy-tabix IS INITIAL. g_fhm_flag = yes. ENDIF.
  DESCRIBE TABLE s_dokvr LINES sy-tabix.
  IF NOT sy-tabix IS INITIAL. g_fhm_flag = yes. ENDIF.
  DESCRIBE TABLE s_doktl LINES sy-tabix.
  IF NOT sy-tabix IS INITIAL. g_fhm_flag = yes. ENDIF.
  DESCRIBE TABLE s_sfhnr LINES sy-tabix.
  IF NOT sy-tabix IS INITIAL. g_fhm_flag = yes. ENDIF.

ENDFORM.                               " CHECK_SEL_FHM_L

*&---------------------------------------------------------------------*
*&      Form  SEL_VIA_OBJLIST_L
*&---------------------------------------------------------------------*
*       IH-Aufträge zu Obekten in Objektliste                          *
*----------------------------------------------------------------------*
FORM sel_via_objlist_l.

  RANGES: lr_owner FOR iloa-owner,
          lr_tplnr FOR iloa-tplnr.

  DATA: h_viaufkst TYPE TABLE OF viaufkst,
        h_hikola   TYPE TABLE OF hikola.

  DATA: BEGIN OF h_iloa OCCURS 0,
      iloan LIKE iloa-iloan.
  DATA: END OF h_iloa.

  DATA: BEGIN OF h_objk OCCURS 0,
      obknr LIKE objk-obknr.
  DATA: END OF h_objk.

  DATA: BEGIN OF h_qmel OCCURS 0,
      qmnum LIKE qmel-qmnum.
  DATA: END OF h_qmel.

  DATA: h_ktext     LIKE viaufkst-ktext.

  FIELD-SYMBOLS: <ls_viaufkst> TYPE viaufkst,
                 <ls_hikola>   TYPE hikola.

*--- Range-Tabelle für ILOA selektion füllen ----------------------*
  lr_owner-sign   = 'I'.
  lr_owner-option = 'EQ'.
  lr_owner-low    = ' '.
  APPEND lr_owner.
  lr_owner-low    = '1'.
  APPEND lr_owner.
  lr_owner-low    = '2'.
  APPEND lr_owner.

*--- Equi, Baugruppe, Meldung in Objektliste ---------------------*
  IF NOT g_flag1 IS INITIAL.
    SELECT obknr FROM objk INTO TABLE h_objk
                       WHERE equnr IN equnr
                       AND   matnr IN sermat
                       AND   sernr IN serialnr
                       AND   bautl IN bautl
                       AND   ihnum IN qmnum
                       AND   objvw EQ 'A'.
  ENDIF.
*--- Techn.Platz, Equi, Baugruppe, Meldung in Objektliste ---------*
  IF NOT g_flag2 IS INITIAL.
*--- if G_ALTERN_ACT is activ use speial views
    IF g_use_alt = g_x.
      SELECT ilo~iloan
        INTO TABLE h_iloa
        FROM iflos AS alt INNER JOIN
             iloa  AS ilo
         ON  alt~mandt = ilo~mandt AND
             alt~tplnr = ilo~tplnr
         WHERE strno IN strno
          AND  owner IN lr_owner
          AND  actvs =  'X'.
    ELSE.
*--- create select-option for iflo-tplnr out of select-option
*--- for iflos-strno (due to conversion exit)
      LOOP AT strno.
        lr_tplnr-sign   = strno-sign.
        lr_tplnr-option = strno-option.
        lr_tplnr-low    = strno-low.
        lr_tplnr-high   = strno-high.
        APPEND lr_tplnr.
      ENDLOOP.
      SELECT iloan FROM iloa INTO TABLE h_iloa
                             WHERE tplnr IN lr_tplnr
                               AND owner IN lr_owner.
    ENDIF.

    DESCRIBE TABLE h_iloa LINES sy-tabix.
    IF NOT sy-tabix IS INITIAL.
      SELECT obknr FROM objk APPENDING TABLE h_objk
                         FOR ALL ENTRIES IN h_iloa
                         WHERE iloan = h_iloa-iloan
                         AND   equnr IN equnr
                         AND   matnr IN sermat
                         AND   sernr IN serialnr
                         AND   bautl IN bautl
                         AND   ihnum IN qmnum
                         AND   objvw EQ 'A'.
    ENDIF.
  ENDIF.
*--- Objekt indirekt (über Meldung) in Objektliste ----------------*
  IF NOT g_flag1 IS INITIAL OR NOT
         g_flag2 IS INITIAL.
*--- if G_ALTERN_ACT is activ use speial views
    IF g_use_alt = g_x.
      g_viewname = 'VIQMEL_IFLOS'.
    ELSE.
      g_viewname = 'VIQMEL'.
    ENDIF.

    SELECT qmnum FROM (g_viewname) INTO TABLE h_qmel
                         WHERE equnr IN equnr
                           AND matnr IN sermat
                           AND serialnr IN serialnr
                           AND tplnr IN strno
                           AND bautl IN bautl
                           AND qmnum IN qmnum
                           AND aufnr NE space.
    DESCRIBE TABLE h_qmel LINES sy-tabix.
    IF NOT sy-tabix IS INITIAL.
      SELECT obknr FROM objk APPENDING TABLE h_objk
                        FOR ALL ENTRIES IN h_qmel
                        WHERE   ihnum = h_qmel-qmnum
                        AND     objvw = 'A'.
      FREE h_qmel.
    ENDIF.
  ENDIF.

*--- Mehrfach selektierte Objektlisten löschen --------------------*
  SORT h_objk BY obknr.
  DELETE ADJACENT DUPLICATES FROM h_objk COMPARING obknr.

*--- use old view ever - no TPLNR_INT !
  IF g_use_alt = g_x.
    DELETE TABLE g_selfields_tab WITH TABLE KEY field = 'TPLNR_INT'.
  ENDIF.

*--- Aufträge zu Objektlisten -------------------------------------*
  DESCRIBE TABLE h_objk LINES sy-tabix.
  IF NOT sy-tabix IS INITIAL.
*--- aktive Aufträge über Objektliste selektieren
    IF NOT dy_ofn IS INITIAL OR
       NOT dy_iar IS INITIAL OR
       NOT dy_mab IS INITIAL.
      SELECT (g_selfields_tab) FROM viaufkst
            INTO CORRESPONDING FIELDS OF TABLE h_viaufkst
                       FOR ALL ENTRIES IN h_objk
                       WHERE obknr = h_objk-obknr
                               AND   iphas  IN i_iphas
                               AND   aufnr IN aufnr
                               AND   ilart IN ilart
                               AND   auart IN auart
                               AND   ernam IN ernam
                               AND   erdat IN erdat
                               AND   aenam IN aenam
                               AND   aedat IN aedat
*                               AND   ktext IN ktext
                               AND   bukrs IN bukrs
                               AND   gsber IN gsber
                               AND   abckz IN abckz
                               AND   eqfnr IN eqfnr
                               AND   priok IN priok
                               AND   iwerk IN iwerk
                               AND   ingpr IN ingpr
                               AND   plgrp IN plgrp
                               AND   kunum IN kunum
                               AND   anlbd IN anlbd
                               AND   anlvd IN anlvd
                               AND   kostl IN kostl
                               AND   swerk IN swerk
                               AND   stort IN stort
                               AND   msgrp IN msgrp
                               AND   beber IN beber
                               AND   anlnr IN anlnr
                               AND   gltrp IN gltrp
                               AND   gstrp IN gstrp
                               AND   gltrs IN gltrs
                               AND   gstrs IN gstrs
                               AND   gstri IN gstri
                               AND   getri IN getri
                               AND   ftrmi IN ftrmi
                               AND   revnr IN revnr
                               AND   warpl IN warpl
                               AND   wapos IN wapos
                               AND   aufpl IN aufpl
                               AND   maufnr IN maufnr
                               AND   lead_aufnr IN lead_auf
                               AND   ppsid IN i_ppsid
                               AND   gewrk IN i_gewrk
                               AND   kdauf IN kdauf
                               AND   kdpos IN kdpos
                               AND   plknz IN plknz
                               AND   proid IN i_proid
                               AND   pspel IN i_pspel
                               AND   aufnt IN aufnt
                               AND   addat IN gr_date
                               AND   vkorg IN vkorg
                               AND   vtweg IN vtweg
                               AND   spart IN spart
                               AND   plnnr IN plnnr
                               AND   plnal IN plnal
                               AND   prctr IN prctr
                               AND   kostv IN kostv.
*--- Object_tab versorgen und daten für pre-fetch sammeln ---------*
      LOOP AT h_viaufkst ASSIGNING <ls_viaufkst>.
        viaufkst = <ls_viaufkst>.

        h_ktext = viaufkst-ktext.
        TRANSLATE h_ktext TO UPPER CASE.                 "#EC TRANSLANG
        CHECK h_ktext IN ktext.

        PERFORM move_viaufkst_to_object_tab_l.
        APPEND object_tab.
      ENDLOOP.
      FREE h_viaufkst.
    ENDIF.
    CLEAR viaufkst.
*--- Historische Aufträge über Objektliste selektieren ------------*
    IF NOT dy_his IS INITIAL.
*--- anderes Feld für verantw.Arbeitsplatz in Hikola ---------------
      PERFORM change_selfields_for_hikola_l.
      DELETE TABLE g_selfields_tab_hiko
                   WITH TABLE KEY field = 'TPLNR_INT'.
      SELECT (g_selfields_tab_hiko) FROM hikola
              INTO CORRESPONDING FIELDS OF TABLE h_hikola
                       FOR ALL ENTRIES IN h_objk
                       WHERE obknr = h_objk-obknr
                         AND   aufnr IN aufnr
                         AND   ilart IN ilart
                         AND   auart IN auart
                         AND   ernam IN ernam
                         AND   erdat IN erdat
                         AND   aenam IN aenam
                         AND   aedat IN aedat
*                         AND   ktext IN ktext
                         AND   bukrs IN bukrs
                         AND   gsber IN gsber
                         AND   abckz IN abckz
                         AND   eqfnr IN eqfnr
                         AND   priok IN priok
                         AND   iwerk IN iwerk
                         AND   ingpr IN ingpr
                         AND   apgrp IN plgrp
                         AND   kunum IN kunum
                         AND   anlbd IN anlbd
                         AND   anlvd IN anlvd
                         AND   kostl IN kostl
                         AND   swerk IN swerk
                         AND   stort IN stort
                         AND   msgrp IN msgrp
                         AND   beber IN beber
                         AND   anlnr IN anlnr
                         AND   gltrp IN gltrp
                         AND   gstrp IN gstrp
                         AND   gstri IN gstri
                         AND   getri IN getri
                         AND   revnr IN revnr
                         AND   warpl IN warpl
                         AND   wapos IN wapos
                         AND   maufnr IN maufnr
                         AND   lead_aufnr IN lead_auf
                         AND   proid IN i_proid
                         AND   pspel IN i_pspel
                         AND   addat IN gr_date
                         AND   ppsid IN i_ppsid
                         AND   gewrk IN i_gewrk
                         AND   plknz IN plknz
                         AND   vkorg IN vkorg
                         AND   vtweg IN vtweg
                         AND   spart IN spart
                         AND   plnnr IN plnnr
                         AND   plnal IN plnal.
*--- Object_tab versorgen und daten für pre-fetch sammeln -----------
      LOOP AT h_hikola ASSIGNING <ls_hikola>.
        MOVE-CORRESPONDING <ls_hikola>       TO viaufkst.
        MOVE               <ls_hikola>-apgrp TO viaufkst-plgrp.

        h_ktext = viaufkst-ktext.
        TRANSLATE h_ktext TO UPPER CASE.                 "#EC TRANSLANG
        CHECK h_ktext IN ktext.

        PERFORM move_viaufkst_to_object_tab_l.
        object_tab-gewrk = <ls_hikola>-vaplz.
        APPEND object_tab.
      ENDLOOP.
      FREE h_hikola.
    ENDIF.
*--- Doppelte Einträge aus Object_Tab entfernen ---------------------
    SORT object_tab BY aufnr.
    DELETE ADJACENT DUPLICATES FROM object_tab COMPARING aufnr.
  ENDIF.
ENDFORM.                               " SEL_VIA_OBJLIST_L

*&---------------------------------------------------------------------*
*&      Form  CHECK_SCREEN_OBJLIST_L
*&---------------------------------------------------------------------*
*       Wenn Sel. incl. Objektliste müssen Equi, T.P. oder             *
*       Baugruppen-ranges gefüllt sein                                 *
*----------------------------------------------------------------------*
FORM check_screen_objlist_l.

  CLEAR g_flag1.
  CLEAR g_flag2.

  IF NOT equnr[]    IS INITIAL.  g_flag1 = g_x. ENDIF.
  IF NOT sermat[]   IS INITIAL.  g_flag1 = g_x. ENDIF.
  IF NOT serialnr[] IS INITIAL.  g_flag1 = g_x. ENDIF.
  IF NOT tplnr[]    IS INITIAL.  g_flag2 = g_x. ENDIF.
  IF NOT strno[]    IS INITIAL.  g_flag2 = g_x. ENDIF.
  IF NOT bautl[]    IS INITIAL.  g_flag1 = g_x. ENDIF.
  IF NOT qmnum[]    IS INITIAL.  g_flag1 = g_x. ENDIF.

  IF g_flag1 IS INITIAL AND
     g_flag2 IS INITIAL.
    MESSAGE e107.
  ENDIF.

ENDFORM.                               " CHECK_SCREEN_OBJLIST_L

*&---------------------------------------------------------------------*
*&      Form  CALL_BUDGET_L
*&---------------------------------------------------------------------*
*       Absprung in Budgetierung                                      *
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM call_budget_l USING f_ucomm LIKE sy-ucomm.

  DATA: f_tcode LIKE sy-tcode.

  f_tcode = f_ucomm.
  IF NOT t003o-auart = rihaufk-auart.
    SELECT SINGLE * FROM t003o WHERE auart = object_tab-auart.
  ENDIF.
*--- Ausflug nur wenn für Auftragsart Budgetprofil gepflegt wurde --*
  IF NOT t003o-bprof IS INITIAL.
    SET PARAMETER ID 'ANR' FIELD rihaufk-aufnr.
    CALL TRANSACTION f_tcode AND SKIP FIRST SCREEN.
  ELSE.
    MESSAGE s018(bp).
  ENDIF.

ENDFORM.                               " CALL_BUDGET_L

*&---------------------------------------------------------------------*
*&      Form  DISPLAY_WABE_L
*&---------------------------------------------------------------------*
*       Warenbewegungen zum Auftrag                                    *
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM display_wabe_l.

  PERFORM create_range_l.
  IF NOT object IS INITIAL.
    SUBMIT riaufm20 WITH aufnr IN object
                    WITH dy_wap   = 'X'
                    WITH dy_wau   = 'X'
                    WITH dy_web   = 'X'
                    WITH dy_wef   = 'X'
                    WITH dy_auth  = 'X'
                    WITH dy_tcode = 'IW3M'
           AND RETURN.
  ENDIF.


ENDFORM.                               " DISPLAY_WABE_L

*&---------------------------------------------------------------------*
*&      Form  DETERMINE_ACTTYPE_AUFK_L
*&---------------------------------------------------------------------*
*       text                                                           *
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM determine_acttype_aufk_l.

  SELECT SINGLE * FROM t370a WHERE tcode = g_tcode.
  IF sy-subrc <> 0.
    SELECT SINGLE * FROM t370a WHERE tcode = 'IW39'.
    IF sy-subrc <> 0.
      MESSAGE x160 WITH 'IW39'.
    ENDIF.
  ENDIF.
  g_aktyp = t370a-aktyp.

ENDFORM.                               " DETERMINE_ACTTYPE_AUFK_L
*&---------------------------------------------------------------------*
*&      Form  GET_AUFNR_FROM_IHPA_L
*&---------------------------------------------------------------------*
*       Über Objeknummer aus IHPA wird Auftragnummer ermittelt         *
*----------------------------------------------------------------------*
*  <--  E_OBJ_FOUND Orders for partner found? Yes/No
*----------------------------------------------------------------------*
FORM get_aufnr_from_ihpa_l USING e_obj_found TYPE c.

  DATA: BEGIN OF h_objnr_tab OCCURS 0,
          objnr LIKE aufk-objnr,
        END OF h_objnr_tab.

  DATA: BEGIN OF h_ionra.
          INCLUDE STRUCTURE ionra.
  DATA: END OF h_ionra.

  RANGES: lr_aufnr FOR afih-aufnr.

  CLEAR e_obj_found.

  g_par_dbcnt = 2000.

  SELECT objnr FROM ihpa UP TO g_par_dbcnt ROWS
                     INTO TABLE h_objnr_tab
                     WHERE parnr = dy_parnr
                     AND   parvw = dy_parvw
                     AND   obtyp = 'ORI'
                     AND   kzloesch = ' '.

*--- Maximale Trefferzahl erreicht -> Prefetch nicht sinnvoll
  IF sy-dbcnt = g_par_dbcnt.
    CLEAR g_par_dbcnt.
    e_obj_found = asterisk.
    EXIT.
  ENDIF.

*--- sichern der Auftragsnummern
  lr_aufnr[] = aufnr[].
  REFRESH aufnr. CLEAR aufnr.
  aufnr-sign   = 'I'.
  aufnr-option = 'EQ'.

  LOOP AT h_objnr_tab.
*--- aus der Objectnummer wird die Auftragsnummer ermittelt ---------*
    CALL FUNCTION 'OBJECT_KEY_GET'
      EXPORTING
        i_objnr = h_objnr_tab-objnr
      IMPORTING
        e_ionra = h_ionra
      EXCEPTIONS
        OTHERS  = 1.
    IF sy-subrc IS INITIAL.
*--- selektionsergebnis mit select-option abmischen ----------------*
      CHECK h_ionra-aufnr IN lr_aufnr.
      aufnr-low = h_ionra-aufnr.
      APPEND aufnr.
    ENDIF.
  ENDLOOP.

  IF aufnr[] IS INITIAL.
*--- es wurde nicht selektiert
    MESSAGE s047.
    e_obj_found = no.
    EXIT.
  ELSE.
    e_obj_found = yes.
  ENDIF.

ENDFORM.                               " GET_AUFNR_FROM_IHPA_L
*&---------------------------------------------------------------------*
*&      Form  DISPLAY_LONGTEXT_L
*&---------------------------------------------------------------------*
*       Langtext zum Auftrag anzeigen                                  *
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM display_longtext_l.

  TABLES: tco09.

  DATA h_ltsch   LIKE stxh-tdname.
  DATA h_autyp   LIKE aufk-autyp VALUE '30'.
  DATA h_spalten LIKE tco09-lnsze_ord.
  DATA h_result  LIKE itcer.
  DATA h_langu   LIKE sy-langu.

*--- fill language key
  h_langu = object_tab-ltext.

*--- check longtext maintained
  IF object_tab-ltext IS INITIAL.
    MESSAGE ID 'BS' TYPE 'S' NUMBER '243'. EXIT.
  ENDIF.

  IF tco09-aufty IS INITIAL.
    CALL FUNCTION 'CO_TA_TCO09_READ'
      EXPORTING
        autyp  = h_autyp
      IMPORTING
        struct = tco09
      EXCEPTIONS
        OTHERS = 1.
  ENDIF.

  IF NOT tco09-lnsze_ord IS INITIAL.
    h_spalten = tco09-lnsze_ord.
  ELSE.
    h_spalten = 072.
  ENDIF.

  CALL FUNCTION 'CO_ZK_TEXTKEY_CAUFV'
    EXPORTING
      aufnr  = object_tab-aufnr
    IMPORTING
      ltsch  = h_ltsch
    EXCEPTIONS
      OTHERS = 1.

  CALL FUNCTION 'TEXT_FOR_HEADER'
    EXPORTING
      id        = tco09-idord
      object    = tco09-objec
      ktext     = object_tab-ktext
      language  = h_langu
      ltsch     = h_ltsch
      ltsch_neu = h_ltsch
      show_flag = 'X'
      spalten   = h_spalten
    IMPORTING
      RESULT    = h_result
    EXCEPTIONS
      OTHERS    = 1.

  IF NOT sy-subrc IS INITIAL.
    MESSAGE ID 'IT' TYPE 'S' NUMBER '011' WITH h_langu.
  ENDIF.
*--- Longtext left with pf15 -> end of loop-session (popup)
  IF h_result-userexit = 'E'.
    return_code = 8.
  ENDIF.

ENDFORM.                               " DISPLAY_LONGTEXT_L

*&---------------------------------------------------------------------*
*&      Form  CHECK_FLAGS_WITH_SELMOD_L
*&---------------------------------------------------------------------*
*       text                                                           *
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM check_flags_with_selmod_l.

*--- wurde Feldcatalog importiert, Flags nicht automatisch setzen
  CHECK g_fieldcat_imp IS INITIAL.

  g_kost_flag     = yes.
  g_sttxt_flag    = yes.
  g_arbpl_flag    = yes.
  g_gewrk_flag    = yes.
  g_eqktx_flag    = yes.
  g_pltxt_flag    = yes.
  g_adres_flag    = yes.
  g_vorue_flag    = yes.
  g_maktx_flag    = yes.
  g_page_flag     = yes.
  g_priokx_flag   = yes.

ENDFORM.                               " CHECK_FLAGS_WITH_SELMOD_L

*&---------------------------------------------------------------------*
*&      Form  SELECT_VIA_COBRB_L
*&---------------------------------------------------------------------*
*       Aufträge über Abrechungsempfänger selektieren
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM select_via_cobrb_l.

  RANGES: h_konty   FOR cobrb-konty.
  RANGES: h_aufnr   FOR viaufkst-aufnr.

  DATA: h_select.
  DATA: h_ionra LIKE ionra.

  DATA: BEGIN OF h_objnr_tab OCCURS 100,
    objnr LIKE viaufkst-objnr.
  DATA: END OF h_objnr_tab.

  DATA: BEGIN OF h_aufnr_tab OCCURS 100,
    aufnr LIKE viaufkst-aufnr.
  DATA: END OF h_aufnr_tab.

  DATA: BEGIN OF h_pspnr_tab OCCURS 10,
    pspnr LIKE prps-pspnr.
  DATA: END OF h_pspnr_tab.

  DATA: lt_imkeys TYPE TABLE OF virekey,
        l_re_used TYPE flag.

*--- soll über Abrechungsempfänger selekiert werden? ----------------*
  DESCRIBE TABLE abkostl LINES sy-tabix.
  IF NOT sy-tabix IS INITIAL. h_select = g_x. ENDIF.
  DESCRIBE TABLE abaufnr LINES sy-tabix.
  IF NOT sy-tabix IS INITIAL. h_select = g_x. ENDIF.
  DESCRIBE TABLE abkstrg LINES sy-tabix.
  IF NOT sy-tabix IS INITIAL. h_select = g_x. ENDIF.
  DESCRIBE TABLE abnplnr LINES sy-tabix.
  IF NOT sy-tabix IS INITIAL. h_select = g_x. ENDIF.
  DESCRIBE TABLE abkdauf LINES sy-tabix.
  IF NOT sy-tabix IS INITIAL. h_select = g_x. ENDIF.
  DESCRIBE TABLE abkdpos LINES sy-tabix.
  IF NOT sy-tabix IS INITIAL. h_select = g_x. ENDIF.
  DESCRIBE TABLE abhkont LINES sy-tabix.
  IF NOT sy-tabix IS INITIAL. h_select = g_x. ENDIF.
  DESCRIBE TABLE abgsber LINES sy-tabix.
  IF NOT sy-tabix IS INITIAL. h_select = g_x. ENDIF.
  DESCRIBE TABLE abanln1 LINES sy-tabix.
  IF NOT sy-tabix IS INITIAL. h_select = g_x. ENDIF.
  DESCRIBE TABLE abanln2 LINES sy-tabix.
  IF NOT sy-tabix IS INITIAL. h_select = g_x. ENDIF.
  DESCRIBE TABLE abmatnr LINES sy-tabix.
  IF NOT sy-tabix IS INITIAL. h_select = g_x. ENDIF.
  DESCRIBE TABLE abaufnr LINES sy-tabix.
  IF NOT sy-tabix IS INITIAL. h_select = g_x. ENDIF.

*--- bei PSP-Element Sonderbehandlung wegen Konvertierung -----------*
  DESCRIBE TABLE abpspnr LINES sy-tabix.
  IF NOT sy-tabix IS INITIAL.
    h_select = g_x.
    SELECT pspnr FROM prps INTO TABLE h_pspnr_tab
         WHERE posid IN abpspnr.
*--- keine PSP-Elemente selektiert -------------------------------*
    IF NOT sy-subrc IS INITIAL.
      MESSAGE s047.
      STOP.
    ENDIF.
  ENDIF.

*--- Parameter Kontierungstyp in Range umwandeln -------------------*
  IF NOT abkonty IS INITIAL.
    h_konty-low    = abkonty.
    h_konty-option = 'EQ'.
    h_konty-sign   = 'I'.
    APPEND h_konty.
    h_select = g_x.
  ENDIF.

*--- check for Real Estate fields
  PERFORM re_check_selection USING l_re_used.
  IF NOT l_re_used IS INITIAL.
    PERFORM re_get_object_keys USING s_bukrs-low
                                     p_stich
                               CHANGING lt_imkeys.
    IF NOT lt_imkeys IS INITIAL.
      h_select = g_x.
    ELSE.
      MESSAGE s047(ih).
      STOP.
    ENDIF.
  ENDIF.

  IF h_select = g_x.
*--- if Real Estate object is entered only search for Object number
    IF NOT lt_imkeys IS INITIAL.
      SELECT objnr FROM cobrb INTO TABLE h_objnr_tab
               FOR ALL ENTRIES IN lt_imkeys
               WHERE   rec_objnr1 = lt_imkeys-objnr
                 AND   objnr      LIKE 'OR%'
                 AND   konty      IN h_konty.
    ELSEIF NOT h_pspnr_tab[] IS INITIAL.
*--- es wird u.A. über PSP-Element selektiert ------------------------*
      SELECT objnr FROM cobrb INTO TABLE h_objnr_tab
               FOR ALL ENTRIES IN h_pspnr_tab
               WHERE   ps_psp_pnr = h_pspnr_tab-pspnr
                 AND   objnr      LIKE 'OR%'
                 AND   konty      IN h_konty
                 AND   kostl      IN abkostl
                 AND   aufnr      IN abaufnr
                 AND   kstrg      IN abkstrg
                 AND   nplnr      IN abnplnr
                 AND   kdauf      IN abkdauf
                 AND   kdpos      IN abkdpos
                 AND   hkont      IN abhkont
                 AND   gsber      IN abgsber
                 AND   anln1      IN abanln1
                 AND   anln2      IN abanln2
                 AND   matnr      IN abmatnr.
    ELSE.
      SELECT objnr FROM cobrb INTO TABLE h_objnr_tab
               WHERE   objnr      LIKE 'OR%'
                 AND   konty      IN h_konty
                 AND   kostl      IN abkostl
                 AND   aufnr      IN abaufnr
                 AND   kstrg      IN abkstrg
                 AND   nplnr      IN abnplnr
                 AND   kdauf      IN abkdauf
                 AND   kdpos      IN abkdpos
                 AND   hkont      IN abhkont
                 AND   gsber      IN abgsber
                 AND   anln1      IN abanln1
                 AND   anln2      IN abanln2
                 AND   matnr      IN abmatnr.
    ENDIF.
    IF NOT sy-subrc IS INITIAL.
      MESSAGE s047.
      STOP.
    ENDIF.
*--- Mehrfacheinträge löschen ---------------------------------------*
    SORT h_objnr_tab BY objnr.
    DELETE ADJACENT DUPLICATES FROM h_objnr_tab COMPARING objnr.

    h_aufnr-sign   = 'I'.
    h_aufnr-option = 'EQ'.
    LOOP AT h_objnr_tab.
*--- aus Objektnummer die Auftragsnummer ermitteln ------------------*
      CALL FUNCTION 'OBJECT_KEY_GET'
        EXPORTING
          i_objnr = h_objnr_tab-objnr
        IMPORTING
          e_ionra = h_ionra
        EXCEPTIONS
          OTHERS  = 1.
      IF sy-subrc IS INITIAL.
*--- Selektionsergebnis mit select-option abgleichen -----------------*
        CHECK h_ionra-aufnr IN i_aufnr.
        h_aufnr-low = h_ionra-aufnr.
        APPEND h_aufnr.
      ENDIF.
    ENDLOOP.
*--- bei großer Treffermenge -> Vorselektion damit nur IH-Aufträge --*
    DESCRIBE TABLE h_aufnr LINES sy-tabix.
    IF sy-tabix > 500.
      SELECT aufnr FROM afih INTO TABLE h_aufnr_tab
         FOR ALL ENTRIES IN h_aufnr
         WHERE aufnr =  h_aufnr-low
         AND   iphas IN i_iphas.
*--- PM-Aufträge gefunden? ------------------------------------------*
      IF NOT sy-subrc IS INITIAL.
        MESSAGE s047.
        STOP.
      ENDIF.
      REFRESH aufnr.
      CLEAR   aufnr.
      aufnr-sign   = 'I'.
      aufnr-option = 'EQ'.
      LOOP AT h_aufnr_tab.
        aufnr-low = h_aufnr_tab-aufnr.
        APPEND aufnr.
      ENDLOOP.
    ELSE.
      aufnr[] = h_aufnr[].
    ENDIF.
  ENDIF.

ENDFORM.                               " SELECT_VIA_COBRB_L


*&---------------------------------------------------------------------*
*&      Form  VARIANT_INIT_L
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM variant_init_l.

  CASE g_tcode.
    WHEN 'IW38'.
      PERFORM variant_init_f14 USING 'INST'
                                     'INST'
                                     'INST'.
    WHEN 'IW39'.
      PERFORM variant_init_f14 USING 'INST'
                                     'INST'
                                     'INST'.
    WHEN 'IW72'.
      PERFORM variant_init_f14 USING 'SERV'
                                     'INST'
                                     'INST'.
    WHEN 'IW73'.
      PERFORM variant_init_f14 USING 'SERV'
                                     'INST'
                                     'INST'.
    WHEN OTHERS.
      PERFORM variant_init_f14 USING 'INST'
                                     'INST'
                                     'INST'.
  ENDCASE.

ENDFORM.                               " VARIANT_INIT_L
*&---------------------------------------------------------------------*
*&      Form  CREATE_FIELDGROUPS_L
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM create_fieldgroups_l.

  DATA h_fieldgroups TYPE slis_sp_group_alv.

  FIELD-SYMBOLS: <ls_fieldcat> TYPE slis_fieldcat_alv.

*--- create fieldgroups ---------------------------------------------*
*--- allgem.Daten
  h_fieldgroups-sp_group = 'A'.
  h_fieldgroups-text     = text-fg1.
  APPEND h_fieldgroups TO g_fieldgroups_tab.
*--- Standortdaten --------------------------------------------------*
  h_fieldgroups-sp_group = 'B'.
  h_fieldgroups-text     = text-fg2.
  APPEND h_fieldgroups TO g_fieldgroups_tab.
*--- Adressdata -----------------------------------------------------*
  h_fieldgroups-sp_group = 'C'.
  h_fieldgroups-text     = text-fg3.
  APPEND h_fieldgroups TO g_fieldgroups_tab.
*--- Termindaten ----------------------------------------------------*
  h_fieldgroups-sp_group = 'D'.
  h_fieldgroups-text     = text-fg4.
  APPEND h_fieldgroups TO g_fieldgroups_tab.
*--- Kosten Erlöse -------------------------------------------------*
  h_fieldgroups-sp_group = 'E'.
  h_fieldgroups-text     = text-fg5.
  APPEND h_fieldgroups TO g_fieldgroups_tab.
*--- Servicedata   -------------------------------------------------*
  h_fieldgroups-sp_group = 'F'.
  h_fieldgroups-text     = text-fg6.
  APPEND h_fieldgroups TO g_fieldgroups_tab.

*--- assign fields in g_fieldcat_tab to fieldgroups -----------------*
  LOOP AT g_fieldcat_tab ASSIGNING <ls_fieldcat>.
    CLEAR <ls_fieldcat>-sp_group.
    CASE <ls_fieldcat>-fieldname.
      WHEN 'MANDT'.
        <ls_fieldcat>-sp_group = 'A'.
        <ls_fieldcat>-tech     = g_x.
      WHEN 'IPHAS'.
        <ls_fieldcat>-sp_group = 'A'.
        <ls_fieldcat>-tech     = g_x.
      WHEN 'AUFNR'.
        <ls_fieldcat>-sp_group = 'A'.
      WHEN 'AUART'.
        <ls_fieldcat>-sp_group = 'A'.
      WHEN 'AUTYP'.
        <ls_fieldcat>-sp_group = 'A'.
      WHEN 'KTEXT'.
        <ls_fieldcat>-sp_group = 'A'.
      WHEN 'LTEXT'.
        <ls_fieldcat>-sp_group = 'A'.
      WHEN 'EQUNR'.
        <ls_fieldcat>-sp_group = 'A'.
      WHEN 'EQKTX'.
        <ls_fieldcat>-sp_group = 'A'.
      WHEN 'TPLNR'.
        <ls_fieldcat>-sp_group = 'A'.
      WHEN 'PLTXT'.
        <ls_fieldcat>-sp_group = 'A'.
      WHEN 'QMNUM'.
        <ls_fieldcat>-sp_group = 'A'.
      WHEN 'IWERK'.
        <ls_fieldcat>-sp_group = 'A'.
      WHEN 'PRIOK'.
        <ls_fieldcat>-sp_group = 'A'.
      WHEN 'ERNAM'.
        <ls_fieldcat>-sp_group = 'A'.
      WHEN 'ERDAT'.
        <ls_fieldcat>-sp_group = 'A'.
      WHEN 'USTXT'.
        <ls_fieldcat>-sp_group = 'A'.
      WHEN 'STTXT'.
        <ls_fieldcat>-sp_group = 'A'.
      WHEN 'AENAM'.
        <ls_fieldcat>-sp_group = 'A'.
      WHEN 'AEDAT'.
        <ls_fieldcat>-sp_group = 'A'.
      WHEN 'WARPL'.
        <ls_fieldcat>-sp_group = 'A'.
      WHEN 'WAPOS'.
        <ls_fieldcat>-sp_group = 'A'.
      WHEN 'REVNR'.
        <ls_fieldcat>-sp_group = 'A'.
      WHEN 'PLNNR'.
        <ls_fieldcat>-sp_group = 'A'.
      WHEN 'PLNAL'.
        <ls_fieldcat>-sp_group = 'A'.
      WHEN 'PLKNZ'.
        <ls_fieldcat>-sp_group = 'A'.
      WHEN 'BAUTL'.
        <ls_fieldcat>-sp_group = 'A'.
      WHEN 'GEWRK'.
        <ls_fieldcat>-sp_group = 'A'.
      WHEN 'LOEKZ'.
        <ls_fieldcat>-sp_group = 'A'.
      WHEN 'FEVOR'.
        <ls_fieldcat>-sp_group = 'A'.
        <ls_fieldcat>-tech     = g_x.
      WHEN 'ANING'.
*--- field is not used in application
*       <ls_fieldcat>-sp_group = 'A'.
        <ls_fieldcat>-tech     = g_x.
      WHEN 'EGAUZT'.
*--- field is not used in application
*       <ls_fieldcat>-sp_group = 'A'.
        <ls_fieldcat>-tech     = g_x.
      WHEN 'KALSM'.
        <ls_fieldcat>-sp_group = 'A'.
      WHEN 'ZSCHL'.
        <ls_fieldcat>-sp_group = 'A'.
      WHEN 'AWERK'.
        <ls_fieldcat>-sp_group = 'A'.
      WHEN 'RKEOBJNR'.
*--- field is not used in application
*        <ls_fieldcat>-sp_group = 'A'.
        <ls_fieldcat>-tech     = g_x.
      WHEN 'OBJNR'.
        <ls_fieldcat>-sp_group = 'A'.
      WHEN 'LEAD_AUFNR'.
        <ls_fieldcat>-sp_group = 'A'.
      WHEN 'MAUFNR'.
        <ls_fieldcat>-sp_group = 'A'.
      WHEN 'KOSTV'.
        <ls_fieldcat>-sp_group = 'A'.
      WHEN 'SERMAT'.
        <ls_fieldcat>-sp_group = 'A'.
      WHEN 'SERIALNR'.
        <ls_fieldcat>-sp_group = 'A'.
      WHEN 'DEVICEID'.
        <ls_fieldcat>-sp_group = 'A'.
      WHEN 'MAKTX'.
        <ls_fieldcat>-sp_group = 'A'.
      WHEN 'BAUTLX'.
        <ls_fieldcat>-sp_group = 'A'.
      WHEN 'PAGESTAT'.
        <ls_fieldcat>-sp_group = 'A'.
      WHEN 'PSPEL'.
        <ls_fieldcat>-sp_group = 'A'.
      WHEN 'AUDISP'.
        <ls_fieldcat>-sp_group = 'A'.
      WHEN 'PRIOKX'.
        <ls_fieldcat>-sp_group = 'A'.

      WHEN 'KOKRS'.
        <ls_fieldcat>-sp_group = 'B'.
      WHEN 'SWERK'.
        <ls_fieldcat>-sp_group = 'B'.
      WHEN 'ILART'.
        <ls_fieldcat>-sp_group = 'B'.
      WHEN 'ARBPL'.
        <ls_fieldcat>-sp_group = 'B'.
      WHEN 'KOSTL'.
        <ls_fieldcat>-sp_group = 'B'.
      WHEN 'PROID'.
        <ls_fieldcat>-sp_group = 'B'.
      WHEN 'AUFNT'.
        <ls_fieldcat>-sp_group = 'B'.
      WHEN 'VORUE'.
        <ls_fieldcat>-sp_group = 'B'.
      WHEN 'KDAUF'.
        <ls_fieldcat>-sp_group = 'B'.
      WHEN 'KDPOS'.
        <ls_fieldcat>-sp_group = 'B'.
      WHEN 'GSBER'.
        <ls_fieldcat>-sp_group = 'B'.
      WHEN 'BUKRS'.
        <ls_fieldcat>-sp_group = 'B'.
      WHEN 'WERKS'.
        <ls_fieldcat>-sp_group = 'B'.
      WHEN 'ANLNR'.
        <ls_fieldcat>-sp_group = 'B'.
      WHEN 'ANLUN'.
        <ls_fieldcat>-sp_group = 'B'.
      WHEN 'ANLZU'.
        <ls_fieldcat>-sp_group = 'B'.
      WHEN 'BEBER'.
        <ls_fieldcat>-sp_group = 'B'.
      WHEN 'STORT'.
        <ls_fieldcat>-sp_group = 'B'.
      WHEN 'EQFNR'.
        <ls_fieldcat>-sp_group = 'B'.
      WHEN 'ABCKZ'.
        <ls_fieldcat>-sp_group = 'B'.
      WHEN 'INGPR'.
        <ls_fieldcat>-sp_group = 'B'.
      WHEN 'MSGRP'.
        <ls_fieldcat>-sp_group = 'B'.
      WHEN 'AUFPL'.
        <ls_fieldcat>-sp_group = 'B'.
      WHEN 'PLGRP'.
        <ls_fieldcat>-sp_group = 'B'.
      WHEN 'APGRP'.
        <ls_fieldcat>-sp_group = 'B'.
        <ls_fieldcat>-tech     = g_x.
      WHEN 'KUNUM'.
        <ls_fieldcat>-sp_group = 'B'.
      WHEN 'PRCTR'.
        <ls_fieldcat>-sp_group = 'B'.
      WHEN 'VKORG'.
        <ls_fieldcat>-sp_group = 'B'.
      WHEN 'VTWEG'.
        <ls_fieldcat>-sp_group = 'B'.
      WHEN 'SPART'.
        <ls_fieldcat>-sp_group = 'B'.

      WHEN 'ADRNRA'.
        <ls_fieldcat>-sp_group = 'C'.
      WHEN 'NAME_LIST'.
        <ls_fieldcat>-sp_group = 'C'.
      WHEN 'TEL_NUMBER'.
        <ls_fieldcat>-sp_group = 'C'.
      WHEN 'POST_CODE1'.
        <ls_fieldcat>-sp_group = 'C'.
      WHEN 'CITY1'.
        <ls_fieldcat>-sp_group = 'C'.
      WHEN 'CITY2'.
        <ls_fieldcat>-sp_group = 'C'.
      WHEN 'COUNTRY'.
        <ls_fieldcat>-sp_group = 'C'.
      WHEN 'REGION'.
        <ls_fieldcat>-sp_group = 'C'.
      WHEN 'STREET'.
        <ls_fieldcat>-sp_group = 'C'.

      WHEN 'ADDAT'.
        <ls_fieldcat>-sp_group = 'D'.
      WHEN 'ADUHR'.
        <ls_fieldcat>-sp_group = 'D'.
      WHEN 'GLTRP'.
        <ls_fieldcat>-sp_group = 'D'.
      WHEN 'GSTRP'.
        <ls_fieldcat>-sp_group = 'D'.
      WHEN 'GLTRS'.
        <ls_fieldcat>-sp_group = 'D'.
      WHEN 'GSTRS'.
        <ls_fieldcat>-sp_group = 'D'.
      WHEN 'GSTRI'.
        <ls_fieldcat>-sp_group = 'D'.
      WHEN 'GETRI'.
        <ls_fieldcat>-sp_group = 'D'.
      WHEN 'FTRMI'.
        <ls_fieldcat>-sp_group = 'D'.
      WHEN 'HISDA'.
        <ls_fieldcat>-sp_group = 'D'.
      WHEN 'GEUZI'.
        <ls_fieldcat>-sp_group = 'D'.
      WHEN 'GSUZI'.
        <ls_fieldcat>-sp_group = 'D'.
      WHEN 'GLUZS'.
        <ls_fieldcat>-sp_group = 'D'.
      WHEN 'GSUZS'.
        <ls_fieldcat>-sp_group = 'D'.
      WHEN 'GLUZP'.
        <ls_fieldcat>-sp_group = 'D'.
      WHEN 'GSUZP'.
        <ls_fieldcat>-sp_group = 'D'.
      WHEN 'ANLBD'.
        <ls_fieldcat>-sp_group = 'D'.
      WHEN 'ANLVD'.
        <ls_fieldcat>-sp_group = 'D'.
      WHEN 'ANLBZ'.
        <ls_fieldcat>-sp_group = 'D'.
      WHEN 'ANLVZ'.
        <ls_fieldcat>-sp_group = 'D'.

      WHEN 'GKSTI'.
        <ls_fieldcat>-sp_group = 'E'.
      WHEN 'GKSTP'.
        <ls_fieldcat>-sp_group = 'E'.
      WHEN 'GKSTA'.
        <ls_fieldcat>-sp_group = 'E'.
      WHEN 'GERTI'.
        <ls_fieldcat>-sp_group = 'E'.
      WHEN 'GERTP'.
        <ls_fieldcat>-sp_group = 'E'.
      WHEN 'GESIST'.
        <ls_fieldcat>-sp_group = 'E'.
      WHEN 'GESPLN'.
        <ls_fieldcat>-sp_group = 'E'.
      WHEN 'USER4'.
        <ls_fieldcat>-sp_group = 'E'.
      WHEN 'WAERS'.
        <ls_fieldcat>-sp_group = 'E'.

      WHEN 'BEMOT'.
        <ls_fieldcat>-sp_group = 'F'.
      WHEN 'VKORG_PMSDO'.
        <ls_fieldcat>-sp_group = 'F'.
        CONCATENATE <ls_fieldcat>-seltext_l text-sdo
                    INTO <ls_fieldcat>-seltext_l.
        CONCATENATE <ls_fieldcat>-seltext_m text-sdo
                    INTO <ls_fieldcat>-seltext_m.
        CONCATENATE <ls_fieldcat>-reptext_ddic text-sdo
                    INTO <ls_fieldcat>-reptext_ddic.
      WHEN 'VTWEG_PMSDO'.
        <ls_fieldcat>-sp_group = 'F'.
        CONCATENATE <ls_fieldcat>-seltext_l text-sdo
                    INTO <ls_fieldcat>-seltext_l.
        CONCATENATE <ls_fieldcat>-seltext_m text-sdo
                    INTO <ls_fieldcat>-seltext_m.
        CONCATENATE <ls_fieldcat>-reptext_ddic text-sdo
                    INTO <ls_fieldcat>-reptext_ddic.
      WHEN 'SPART_PMSDO'.
        <ls_fieldcat>-sp_group = 'F'.
        CONCATENATE <ls_fieldcat>-seltext_l text-sdo
                    INTO <ls_fieldcat>-seltext_l.
        CONCATENATE <ls_fieldcat>-seltext_m text-sdo
                    INTO <ls_fieldcat>-seltext_m.
        CONCATENATE <ls_fieldcat>-reptext_ddic text-sdo
                    INTO <ls_fieldcat>-reptext_ddic.
      WHEN 'VKBUR'.
        <ls_fieldcat>-sp_group = 'F'.
      WHEN 'VKGRP'.
        <ls_fieldcat>-sp_group = 'F'.
      WHEN 'BSTKD'.
        <ls_fieldcat>-sp_group = 'F'.
      WHEN 'BSTDK'.
        <ls_fieldcat>-sp_group = 'F'.
      WHEN 'SERV_MATNR'.
        <ls_fieldcat>-sp_group = 'F'.
      WHEN 'SERV_MAKTX'.
        <ls_fieldcat>-sp_group = 'F'.
      WHEN 'MENGE'.
        <ls_fieldcat>-sp_group = 'F'.
      WHEN 'MEINS'.
        <ls_fieldcat>-sp_group = 'F'.
      WHEN 'FAKTF'.
        <ls_fieldcat>-sp_group = 'F'.

    ENDCASE.
  ENDLOOP.


ENDFORM.                               " CREATE_FIELDGROUPS_L

*&---------------------------------------------------------------------*
*&      Form  CREATE_MONITOR_TAB_L
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM create_monitor_tab_l.
*--- Prio -----------------------------------------------------------
  g_monitor_tab-counter = 1.
  g_monitor_tab-fieldname = 'PRIOK'.
  g_monitor_tab-textline  = text-mo1.
  APPEND g_monitor_tab.
*--- Eckstart -------------------------------------------------------
  g_monitor_tab-counter = 2.
  g_monitor_tab-fieldname = 'GSTRP'.
  g_monitor_tab-textline  = text-mo2.
  APPEND g_monitor_tab.
*--- Term.Start -----------------------------------------------------
  g_monitor_tab-counter = 3.
  g_monitor_tab-fieldname = 'GSTRS'.
  g_monitor_tab-textline  = text-mo3.
  APPEND g_monitor_tab.

ENDFORM.                               " CREATE_MONITOR_TAB_L
*&---------------------------------------------------------------------*
*&      Form  CHECK_MONITOR_INPUT_L
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM check_monitor_input_l.

  DATA h_count LIKE sy-tabix.

  IF NOT monitor IS INITIAL.
    READ TABLE g_monitor_tab WITH KEY counter = monitor.
    IF sy-subrc IS INITIAL.
      g_monitor_field = g_monitor_tab-fieldname.
      PERFORM fill_layout_lights_f14.
*      g_layout-lights_fieldname = 'LIGHTS'.
      IF g_monitor_field = 'PRIOK'.
        SELECT * FROM t356 INTO TABLE t_t356.           "#EC CI_GENBUFF
        h_count = 1.
*--- die ersten drei Prio's pro prioritätsart werden mit 1,2,3    --
*--- vorbelegt für Ampelfunktion alle weiteren vorbelegt mit 3    --
        LOOP AT t_t356.
*--- bei gruppenwechsel zurücksetzten -------------------------------
          ON CHANGE OF t_t356-artpr.
            h_count = 1.
          ENDON.
          t_t356-color = h_count.
          MODIFY t_t356.
          IF h_count <> 3.
            h_count = h_count + 1.
          ENDIF.
        ENDLOOP.
        SORT t_t356 BY artpr priok.
      ENDIF.
      CALL FUNCTION 'IREP2_ALV_TOOLTIPS_FILL'
        EXPORTING
          i_monitor = g_monitor_field
        IMPORTING
          et_qinf   = gt_qinf.
    ENDIF.
  ENDIF.

ENDFORM.                               " CHECK_MONITOR_INPUT_L
*&---------------------------------------------------------------------*
*&      Form  CHECK_FIELDCAT_VARIANT_L
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM check_fieldcat_variant_l.

  STATICS h_dfies_tab TYPE TABLE OF dfies WITH HEADER LINE.

  FIELD-SYMBOLS: <ls_fieldcat> TYPE slis_fieldcat_alv.

*--- Feldkatalog zu View lesen (nur einmal in Puffer)
  IF h_dfies_tab[] IS INITIAL.
    CALL FUNCTION 'DDIF_NAMETAB_GET'
      EXPORTING
        tabname   = 'VIAUFKST'
        all_types = g_x
      TABLES
        dfies_tab = h_dfies_tab
      EXCEPTIONS
        OTHERS    = 1.
    SORT h_dfies_tab BY fieldname.
  ENDIF.

  DESCRIBE TABLE g_selfields_tab LINES sy-tabix.
  IF sy-tabix IS INITIAL.
    LOOP AT g_fieldcat_tab ASSIGNING <ls_fieldcat>.
      CASE <ls_fieldcat>-fieldname.
        WHEN 'PM_SELECTED'.
          <ls_fieldcat>-no_out  = space.
          <ls_fieldcat>-col_pos = 1.
        WHEN 'AUFNR'.
          <ls_fieldcat>-no_out  = space.
          <ls_fieldcat>-col_pos = 2.
        WHEN 'AUART'.
          <ls_fieldcat>-no_out  = space.
          <ls_fieldcat>-col_pos = 3.
        WHEN 'GSTRP'.
          <ls_fieldcat>-no_out = space.
          <ls_fieldcat>-col_pos = 4.
        WHEN 'KTEXT'.
          <ls_fieldcat>-no_out = space.
          <ls_fieldcat>-col_pos = 5.
        WHEN OTHERS.
          <ls_fieldcat>-no_out = g_x.
      ENDCASE.
    ENDLOOP.
  ENDIF.

  PERFORM create_g_selfields_tab_f14.
*--- bestimmte Felder müssen immer selektiert werden ----------------*
*--- wegen Detailanzeige, Ausflugfunktion sowie Berechtigung --------*
  PERFORM add_to_g_selfields_tab_f14 USING 'MANDT'.
  PERFORM add_to_g_selfields_tab_f14 USING 'EQUNR'.
  PERFORM add_to_g_selfields_tab_f14 USING 'TPLNR'.
  PERFORM add_to_g_selfields_tab_f14 USING 'BAUTL'.
  PERFORM add_to_g_selfields_tab_f14 USING 'IPHAS'.
  PERFORM add_to_g_selfields_tab_f14 USING 'AUFNR'.
  PERFORM add_to_g_selfields_tab_f14 USING 'ADDAT'.
  PERFORM add_to_g_selfields_tab_f14 USING 'KTEXT'.
  PERFORM add_to_g_selfields_tab_f14 USING 'LTEXT'.
  PERFORM add_to_g_selfields_tab_f14 USING 'OBJNR'.
  PERFORM add_to_g_selfields_tab_f14 USING 'QMNUM'.
  PERFORM add_to_g_selfields_tab_f14 USING 'AUART'.
  PERFORM add_to_g_selfields_tab_f14 USING 'IWERK'.
  PERFORM add_to_g_selfields_tab_f14 USING 'SWERK'.
  PERFORM add_to_g_selfields_tab_f14 USING 'INGPR'.
  PERFORM add_to_g_selfields_tab_f14 USING 'KOKRS'.
  PERFORM add_to_g_selfields_tab_f14 USING 'KOSTL'.
  PERFORM add_to_g_selfields_tab_f14 USING 'AUFPT'.
  PERFORM add_to_g_selfields_tab_f14 USING 'APLZT'.
  PERFORM add_to_g_selfields_tab_f14 USING 'GAUZT'.
  PERFORM add_to_g_selfields_tab_f14 USING 'GAUEH'.
  PERFORM add_to_g_selfields_tab_f14 USING 'WAERS'.
  PERFORM add_to_g_selfields_tab_f14 USING 'KUNUM'.
  PERFORM add_to_g_selfields_tab_f14 USING 'ADRNRA'.
  PERFORM add_to_g_selfields_tab_f14 USING 'ADRNR_ILOA'.
  PERFORM add_to_g_selfields_tab_f14 USING 'WARPL'.
  PERFORM add_to_g_selfields_tab_f14 USING 'OBKNR'.
*--- bestimmte Felder nur selektieren wenn für Monitor nötig    -----*
  CASE g_monitor_field.
    WHEN 'PRIOK'.                      "Priorität
      PERFORM add_to_g_selfields_tab_f14 USING 'PRIOK'.
      PERFORM add_to_g_selfields_tab_f14 USING 'ARTPR'.
    WHEN 'GSTRP'.                      "Eckstart
      PERFORM add_to_g_selfields_tab_f14 USING 'GSTRP'.
      PERFORM add_to_g_selfields_tab_f14 USING 'GLTRP'.
      PERFORM add_to_g_selfields_tab_f14 USING 'GLUZP'.
      PERFORM add_to_g_selfields_tab_f14 USING 'GSUZP'.
    WHEN 'GSTRS'.                      "Term.Start
      PERFORM add_to_g_selfields_tab_f14 USING 'GSTRS'.
      PERFORM add_to_g_selfields_tab_f14 USING 'GLTRS'.
      PERFORM add_to_g_selfields_tab_f14 USING 'GLUZS'.
      PERFORM add_to_g_selfields_tab_f14 USING 'GSUZS'.
  ENDCASE.
*--- bestimmte Felder müssen selektiert werden wenn für         -----*
*--- Nachselektion ausgwählter Felder nötig                     -----*
*--- sortieren wegen binary search                              -----*
  SORT g_fieldcat_tab BY fieldname.
  PERFORM check_field_for_selection_f14 USING 'AWERK' 'GEWRK'.
  PERFORM check_field_for_selection_f14 USING 'ARBPL' 'PPSID'.
  PERFORM check_field_for_selection_f14 USING 'PROID' 'PSPEL'.
  PERFORM check_field_for_selection_f14 USING 'MAKTX' 'SERMAT'.
  PERFORM check_field_for_selection_f14 USING 'AUDISP' 'NO_DISP'.
  PERFORM check_field_for_selection_f14 USING 'PRIOKX' 'PRIOK'.
  PERFORM check_field_for_selection_f14 USING 'PRIOKX' 'ARTPR'.

*--- if costs in different currency - ERDAT is needed for conversion
  PERFORM check_cost_fields_l.
  IF g_kost_flag = yes.
    PERFORM add_to_g_selfields_tab_f14 USING 'ERDAT'.
  ENDIF.

*--- Felder die nicht im View sind müssen gelöscht werden
  LOOP AT g_selfields_tab.
    READ TABLE h_dfies_tab WITH KEY fieldname = g_selfields_tab-field
                                TRANSPORTING NO FIELDS
                                BINARY SEARCH.
    IF NOT sy-subrc IS INITIAL.
      DELETE g_selfields_tab.
    ENDIF.
  ENDLOOP.
*--- Sort. für gleiche Reihenfolge bei dyn. Select.
  SORT g_selfields_tab BY field.

ENDFORM.                               " CHECK_FIELDCAT_VARIANT_L
*&---------------------------------------------------------------------*
*&      Form  CHECK_COST_FIELDS_L
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM check_cost_fields_l.

  CHECK g_kost_flag <> ok.
  g_kost_flag = no.
  PERFORM check_field_display_f14 USING 'GKSTI' g_kost_flag.
  CHECK g_kost_flag <> yes.
  PERFORM check_field_display_f14 USING 'GKSTP' g_kost_flag.
  CHECK g_kost_flag <> yes.
  PERFORM check_field_display_f14 USING 'GERTI' g_kost_flag.
  CHECK g_kost_flag <> yes.
  PERFORM check_field_display_f14 USING 'GERTP' g_kost_flag.
  CHECK g_kost_flag <> yes.
  PERFORM check_field_display_f14 USING 'GKSTA' g_kost_flag.
  CHECK g_kost_flag <> yes.
  PERFORM check_field_display_f14 USING 'GESIST' g_kost_flag.
  CHECK g_kost_flag <> yes.
  PERFORM check_field_display_f14 USING 'GESPLN' g_kost_flag.
  CHECK g_kost_flag <> yes.
  PERFORM check_field_display_f14 USING 'USER4' g_kost_flag.
  CHECK g_kost_flag <> yes.
*--- Wenn nach Kosten selektiert flag auch setzten ------------------
  IF NOT gesist[] IS INITIAL.
    g_kost_flag = yes.
  ENDIF.
  IF NOT gespln[] IS INITIAL.
    g_kost_flag = yes.
  ENDIF.

ENDFORM.                               " CHECK_COST_FIELDS_L
*&---------------------------------------------------------------------*
*&      Form  SET_OBJECT_TAB_LIGHTS_L
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM set_object_tab_lights_l
                      CHANGING cs_object_tab LIKE LINE OF object_tab.

  CASE g_monitor_field.
    WHEN 'PRIOK'.                      "Prio
      PERFORM set_lights_by_prio_l USING    cs_object_tab-priok
                                            cs_object_tab-artpr
                                   CHANGING cs_object_tab-lights.
    WHEN 'GSTRP'.                      "Eckstart
      PERFORM set_lights_by_date_l USING    cs_object_tab-gstrp
                                            cs_object_tab-gsuzp
                                            cs_object_tab-gltrp
                                            cs_object_tab-gluzp
                                   CHANGING cs_object_tab-lights.
    WHEN 'GSTRS'.                      "Term.Start
      PERFORM set_lights_by_date_l USING    cs_object_tab-gstrs
                                            cs_object_tab-gsuzs
                                            cs_object_tab-gltrs
                                            cs_object_tab-gluzs
                                   CHANGING cs_object_tab-lights.
  ENDCASE.

ENDFORM.                               " SET_OBJECT_TAB_LIGHTS_L
*&---------------------------------------------------------------------*
*&      Form  SET_LIGHTS_BY_DATE_L
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_OBJECT_TAB-ADDAT  text                                     *
*      -->P_OBJECT_TAB-ADUHR  text                                     *
*      -->P_OBJECT_TAB-ADDAT  text                                     *
*      -->P_OBJECT_TAB-ADUHR  text                                     *
*      <--e_lights            traffic light
*----------------------------------------------------------------------*
FORM set_lights_by_date_l USING    h_datvon LIKE sy-datlo
                                   h_timvon LIKE sy-timlo
                                   h_datbis LIKE sy-datlo
                                   h_timbis LIKE sy-timlo
                          CHANGING e_lights TYPE c.

  IF h_datvon IS INITIAL AND h_datbis IS INITIAL.
    CLEAR e_lights.           " Keine Termine
  ELSE.
    IF sy-datlo < h_datvon OR
       ( sy-datlo = h_datvon AND
         sy-timlo < h_timvon ).
      e_lights = '3'.         "start nicht erreicht -> grün
    ELSE.
      IF ( sy-datlo < h_datbis ) OR
         ( h_datbis IS INITIAL ) OR
         ( sy-datlo = h_datbis AND
         sy-timlo < h_timbis ).
        e_lights = '2'.       "ende nicht erreicht -> gelb
      ELSE.
        e_lights = '1'.       "ende erreicht -> rot
      ENDIF.
    ENDIF.
  ENDIF.

ENDFORM.                               " SET_LIGHTS_BY_DATE_L
*&---------------------------------------------------------------------*
*&      Form  SET_LIGHTS_BY_PRIO_L
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  i_priok   priority
*  -->  i_artpr   priority type
*  <--  e_lights  Monitor-light
*----------------------------------------------------------------------*
FORM set_lights_by_prio_l USING    i_priok TYPE priok
                                   i_artpr TYPE artpr
                          CHANGING e_lights TYPE c.

  IF NOT i_priok IS INITIAL AND
     NOT i_artpr IS INITIAL.
*--- Farbe (1,2,3) wird aus t_t356 übernommen ------------------------
    IF  t_t356-artpr = i_artpr AND
        t_t356-priok = i_priok.
      e_lights = t_t356-color.
    ELSE.
      READ TABLE t_t356 WITH KEY artpr = i_artpr
                                 priok = i_priok
                                 BINARY SEARCH.
      IF sy-subrc IS INITIAL.
        e_lights = t_t356-color.
      ENDIF.
    ENDIF.
  ELSE.
*--- keine Prio -> Ampel macht keinen Sinn --------------------------
    e_lights = '0'.
  ENDIF.

ENDFORM.                               " SET_LIGHTS_BY_PRIO_L

*&---------------------------------------------------------------------*
*&      Form  REFRESH_L
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM refresh_l USING p_selfield TYPE slis_selfield.

  DATA h_change        LIKE sy-ucomm.
  DATA h_selfields_tab LIKE TABLE OF g_selfields_tab.
*--- letzte itab für dynn. select merken
  h_selfields_tab[] = g_selfields_tab[].
  PERFORM get_fieldcat_actual_f14 USING h_change.
*--- Nachselektion nur wenn Feldkatalog verändert ------------------*
  IF h_change = yes.
    p_selfield-refresh = g_x.
    PERFORM check_fieldcat_variant_l.
*--- Neuselektion nur wenn sich itab für select geändert hat
    IF h_selfields_tab[] <> g_selfields_tab[].
      PERFORM selection_l.
    ELSE.
*--- es wurden nur weitere Zusatzinfos ausgewählt (z.B. EQKTX)
      PERFORM fill_object_tab_l.
    ENDIF.
  ENDIF.

ENDFORM.                               " REFRESH_L
*&---------------------------------------------------------------------*
*&      Form  SELECT_FOR_QUICKINFO_L
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_P_SELFIELD  text                                           *
*----------------------------------------------------------------------*
FORM select_for_quickinfo_l USING p_selfield TYPE slis_selfield.

  IF NOT object_tab-aufnr IS INITIAL.
    IF object_tab-iphas = '5'.
      SELECT SINGLE * FROM hikola WHERE aufnr = object_tab-aufnr.
      MOVE-CORRESPONDING hikola TO viaufkst.
      viaufkst-gewrk = hikola-vaplz.
    ELSE.
      SELECT SINGLE * FROM viaufkst WHERE aufnr = object_tab-aufnr.
    ENDIF.
*--- move data into object_tab
    PERFORM move_viaufkst_to_object_tab_l.
*--- post read data
    PERFORM fill_object_tab_late_l.
  ENDIF.

ENDFORM.                               " SELECT_FOR_QUICKINFO_L
*&---------------------------------------------------------------------*
*&      Form  MONITOR_INPUTHELP_L
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_MONITOR  text                                              *
*----------------------------------------------------------------------*
FORM monitor_inputhelp_l USING    p_monitor TYPE pm_selfield.

  DATA  h_fields_tab LIKE help_value OCCURS 1 WITH HEADER LINE.

  DATA h_tabix LIKE sy-tabix.

  h_fields_tab-tabname = 'RIHEA'.
  h_fields_tab-fieldname = 'SLKNZ'.
  h_fields_tab-selectflag = g_x.
  APPEND h_fields_tab.

  h_fields_tab-tabname = 'RIHEA'.
  h_fields_tab-fieldname = 'PM_REFFIELD'.
  h_fields_tab-selectflag = space.
  APPEND h_fields_tab.

  CALL FUNCTION 'HELP_VALUES_GET_NO_DD_NAME'
       EXPORTING
*           CUCOL                         = 0
*           CUROW                         = 0
*           DISPLAY                       = ' '
            selectfield                   = 'SELMO'
            titel                         = text-f08
*           NO_PERS_HELP_SELECT           = ' '
*           title_in_values_list          = ' '
*           show_all_values_at_first_time = ' '
*           USE_USER_SELECTIONS           = ' '
            write_selectfield_in_colours  = g_x
*           no_scroll                     =
*           NO_CONVERSION                 = ' '
*           reduced_status_only           = g_x
*           NO_MARKING_OF_CHECKVALUE      = ' '
*           NO_DISPLAY_OF_PERS_VALUES     = ' '
*           FILTER_FULL_TABLE             = ' '
       IMPORTING
            ind                           = h_tabix
*           select_value                  =
       TABLES
            fields                        = h_fields_tab
            full_table                    = g_monitor_tab
*           USER_SEL_FIELDS               =
*           HEADING_TABLE                 =
       EXCEPTIONS
            full_table_empty              = 1
            no_tablestructure_given       = 2
            no_tablefields_in_dictionary  = 3
            more_then_one_selectfield     = 4
            no_selectfield                = 5
            OTHERS                        = 6.

  IF sy-subrc IS INITIAL.
    IF NOT h_tabix IS INITIAL.
      READ TABLE g_monitor_tab INDEX h_tabix.
      p_monitor = g_monitor_tab-counter.
    ENDIF.
  ENDIF.


ENDFORM.                               " MONITOR_INPUTHELP_L
*&---------------------------------------------------------------------*
*&      Form  ADD_TO_SELFIELDS_FOR_HIKOLA_L
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM change_selfields_for_hikola_l.

  STATICS h_dfies_tab LIKE dfies OCCURS 115 WITH HEADER LINE.
*--- Selektionstabelle für HIKOLA initialisieren
  CLEAR g_selfields_tab_hiko. REFRESH g_selfields_tab_hiko.
*--- Feldinfo zu hikola lesen (nur einmal in puffer)
  IF h_dfies_tab[] IS INITIAL.
    CALL FUNCTION 'DDIF_NAMETAB_GET'
      EXPORTING
        tabname   = 'HIKOLA'
        all_types = 'X'
      TABLES
        dfies_tab = h_dfies_tab
      EXCEPTIONS
        not_found = 1
        OTHERS    = 2.
    SORT h_dfies_tab BY fieldname.
  ENDIF.
  IF h_dfies_tab[] IS INITIAL. EXIT. ENDIF.
*--- Selektionstabelle kopieren, nicht vorhandene Einträge löschen
  g_selfields_tab_hiko[] = g_selfields_tab[].
  LOOP AT g_selfields_tab_hiko.
    READ TABLE h_dfies_tab WITH KEY
                           fieldname = g_selfields_tab_hiko-field
                           BINARY SEARCH.
    IF NOT sy-subrc IS INITIAL.
      DELETE g_selfields_tab_hiko.
    ENDIF.
  ENDLOOP.
*--- best. Felder immer in Selektionstabelle hinzufügen
  g_selfields_tab_hiko-field = 'VAPLZ'. COLLECT g_selfields_tab_hiko.
  g_selfields_tab_hiko-field = 'APGRP'. COLLECT g_selfields_tab_hiko.
  IF g_use_alt = g_x.
    g_selfields_tab_hiko-field = 'TPLNR_INT'.
    COLLECT g_selfields_tab_hiko.
  ENDIF.

ENDFORM.                               " ADD_TO_SELFIELDS_FOR_HIKOLA_L
*&---------------------------------------------------------------------*
*&      Form  HELP_F4_REVNR_L
*&---------------------------------------------------------------------*
*       Eingabehilfe Revisionsnummer
*----------------------------------------------------------------------*
*      -->P_REVNR-LOW  text                                            *
*----------------------------------------------------------------------*
FORM help_f4_revnr_l USING h_revnr TYPE c.

  DATA: h_dynpfields LIKE dynpread     OCCURS 0 WITH HEADER LINE.
  DATA: itab_feldnamen LIKE help_value OCCURS 2 WITH HEADER LINE.
  DATA: BEGIN OF itab_werte OCCURS 50,
          value(40) TYPE c.            "längstes Feld aus Struktur
  DATA: END OF itab_werte.

  IF iwerk[] IS INITIAL.
*--- Feld aus Selektionsbild holen ----------------------------------*
    h_dynpfields-fieldname = 'IWERK-LOW'.
    APPEND h_dynpfields.
    CALL FUNCTION 'DYNP_VALUES_READ'
      EXPORTING
        dyname     = sy-cprog
        dynumb     = sy-dynnr
      TABLES
        dynpfields = h_dynpfields
      EXCEPTIONS
        OTHERS     = 1.

    IF sy-subrc IS INITIAL.
      READ TABLE h_dynpfields WITH KEY fieldname = 'IWERK-LOW'.
      IF NOT h_dynpfields-fieldvalue IS INITIAL.
        iwerk-low = h_dynpfields-fieldvalue.
        iwerk-option = 'EQ'.
        iwerk-sign   = 'I'.
        APPEND iwerk.
      ENDIF.
    ENDIF.
  ENDIF.
*--- Tabelle mit Übergabe der Felder füllen
  REFRESH itab_feldnamen.
  CLEAR itab_feldnamen.
*--- Revisionen
  MOVE 'T352R'  TO itab_feldnamen-tabname.
  MOVE 'REVNR'  TO itab_feldnamen-fieldname.
  MOVE 'X'      TO itab_feldnamen-selectflag. "Feld, das selektiert wird
  APPEND itab_feldnamen.
*--- Instandhaltungswerk
  MOVE 'T352R'  TO itab_feldnamen-tabname.
  MOVE 'IWERK'  TO itab_feldnamen-fieldname.
  MOVE ' '      TO itab_feldnamen-selectflag. "Feld, das selektiert wird
  APPEND itab_feldnamen.
*--- Texte zu den Revisionen
  MOVE 'T352R' TO itab_feldnamen-tabname.
  MOVE 'REVTX' TO itab_feldnamen-fieldname.
  MOVE ' '     TO itab_feldnamen-selectflag.
  APPEND itab_feldnamen.
*--- Beginndatum zu den Revisionen
  MOVE 'T352R' TO itab_feldnamen-tabname.
  MOVE 'REVBD' TO itab_feldnamen-fieldname.
  MOVE ' '     TO itab_feldnamen-selectflag.
  APPEND itab_feldnamen.
*--- Endedatum zu den Revisionen
  MOVE 'T352R' TO itab_feldnamen-tabname.
  MOVE 'REVED' TO itab_feldnamen-fieldname.
  MOVE ' '     TO itab_feldnamen-selectflag.
  APPEND itab_feldnamen.
*--- Kennzeichen Revision abgeschlossen
  MOVE 'T352R' TO itab_feldnamen-tabname.
  MOVE 'REVAB' TO itab_feldnamen-fieldname.
  MOVE ' '     TO itab_feldnamen-selectflag.
  APPEND itab_feldnamen.

*--- Tabelle für Übergabe der Werte füllen
  CLEAR itab_werte.
  REFRESH itab_werte.
*--- Revisionen selektieren
  SELECT * FROM t352r                                 "#EC CI_SGLSELECT
    WHERE iwerk IN iwerk.
*--- Revision
    CLEAR itab_werte.
    MOVE t352r-revnr TO itab_werte-value.
    APPEND itab_werte.
*--- Instandhaltungswerk
    CLEAR itab_werte.
    MOVE t352r-iwerk TO itab_werte-value.
    APPEND itab_werte.
*--- Text zur Revision
    CLEAR itab_werte.
    MOVE t352r-revtx TO itab_werte-value.
    APPEND itab_werte.
*---  Beginndatum zur Revision
    CLEAR itab_werte.
    MOVE t352r-revbd TO itab_werte-value.
    APPEND itab_werte.
*---  Endedatum zur Revision
    CLEAR itab_werte.
    MOVE t352r-reved TO itab_werte-value.
    APPEND itab_werte.
*---  Kennzeichen Revision abgeschlossen
    CLEAR itab_werte.
    MOVE t352r-revab TO itab_werte-value.
    APPEND itab_werte.
  ENDSELECT.

*--- Revisionen selektiert ?
  IF itab_werte[] IS INITIAL.
    MESSAGE s047.
  ELSE.
    CALL FUNCTION 'HELP_VALUES_GET_WITH_TABLE'
         EXPORTING
*             display                  =
              no_marking_of_checkvalue = g_x
              fieldname                = 'REVNR'
              tabname                  = 'T352R'
         IMPORTING
              select_value             = h_revnr
         TABLES
              fields                   = itab_feldnamen
              valuetab                 = itab_werte.
  ENDIF.

ENDFORM.                               " HELP_F4_REVNR_L
*---------------------------------------------------------------------*
*       FORM GET_PHONE_DATA_L                                         *
*---------------------------------------------------------------------*
*       Supply Phone number for outgoing call                         *
*---------------------------------------------------------------------*
*  -->  P_SELFIELD                                                    *
*---------------------------------------------------------------------*
FORM get_phone_data_l USING p_selfield TYPE slis_selfield.

  CASE p_selfield-sel_tab_field.
    WHEN trans_struc-ernam.
      PERFORM get_user_f16 USING object_tab-ernam.
    WHEN trans_struc-aenam.
      PERFORM get_user_f16 USING object_tab-aenam.
    WHEN trans_struc-kunum.
      PERFORM get_customer_data_f16 USING object_tab-kunum.
  ENDCASE.

ENDFORM.                    "get_phone_data_l
*&---------------------------------------------------------------------*
*&      Form  CHECK_PMSDO_L
*&---------------------------------------------------------------------*
*       Muß PMSDO für Orgdaten SD nachgelesen werden
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM check_pmsdo_l.

  g_pmsdo_flag = no.

  PERFORM check_field_display_f14 USING 'VKORG_PMSDO' g_pmsdo_flag.
  CHECK g_pmsdo_flag <> yes.
  PERFORM check_field_display_f14 USING 'VTWEG_PMSDO' g_pmsdo_flag.
  CHECK g_pmsdo_flag <> yes.
  PERFORM check_field_display_f14 USING 'SPART_PMSDO' g_pmsdo_flag.
  CHECK g_pmsdo_flag <> yes.
  PERFORM check_field_display_f14 USING 'VKBUR' g_pmsdo_flag.
  CHECK g_pmsdo_flag <> yes.
  PERFORM check_field_display_f14 USING 'VKGRP' g_pmsdo_flag.
  CHECK g_pmsdo_flag <> yes.
  PERFORM check_field_display_f14 USING 'BSTKD' g_pmsdo_flag.
  CHECK g_pmsdo_flag <> yes.
  PERFORM check_field_display_f14 USING 'BSTDK' g_pmsdo_flag.
  CHECK g_pmsdo_flag <> yes.
  PERFORM check_field_display_f14 USING 'SERV_MATNR' g_pmsdo_flag.
  CHECK g_pmsdo_flag <> yes.
  PERFORM check_field_display_f14 USING 'SERV_MAKTX' g_pmsdo_flag.
  CHECK g_pmsdo_flag <> yes.
  PERFORM check_field_display_f14 USING 'MENGE' g_pmsdo_flag.
  CHECK g_pmsdo_flag <> yes.
  PERFORM check_field_display_f14 USING 'MEINS' g_pmsdo_flag.
  CHECK g_pmsdo_flag <> yes.
  PERFORM check_field_display_f14 USING 'FAKTF' g_pmsdo_flag.
  CHECK g_pmsdo_flag <> yes.

ENDFORM.                               " CHECK_PMSDO_L
*&---------------------------------------------------------------------*
*&      Form  GET_ADRESS_L
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_OBJECT_TAB_ADRNR  text                                     *
*      -->P_OBJECT_TAB_ADRNR_ILOA  text                                *
*      -->P_OBJECT_TAB_KUNUM  text                                     *
*      -->P_OBJECT_TAB_NAME_LIST  text                                 *
*      -->P_OBJECT_TAB_POST_CODE1  text                                *
*      -->P_OBJECT_TAB_CITY1  text                                     *
*      -->P_OBJECT_TAB_CITY2  text                                     *
*      -->P_OBJECT_TAB_COUNTRY  text                                   *
*      -->P_OBJECT_TAB_REGION  text                                    *
*      -->P_OBJECT_TAB_STREET  text                                    *
*      -->P_OBJECT_TAB_TEL_NUMBER  text                                *
*----------------------------------------------------------------------*
FORM get_adress_l USING
                   p_object_tab_objnr      LIKE rihaufk-objnr
                   p_object_tab_adrnr      LIKE rihaufk-adrnra
                   p_object_tab_adrnr_iloa LIKE rihaufk-adrnra
                   p_object_tab_kunum      LIKE rihaufk-kunum
                   p_object_tab_name_list  LIKE rihaufk-name_list
                   p_object_tab_post_code1 LIKE rihaufk-post_code1
                   p_object_tab_city1      LIKE rihaufk-city1
                   p_object_tab_city2      LIKE rihaufk-city2
                   p_object_tab_country    LIKE rihaufk-country
                   p_object_tab_region     LIKE rihaufk-region
                   p_object_tab_street     LIKE rihaufk-street
                   p_object_tab_tel_number LIKE rihaufk-tel_number.

  IF NOT p_object_tab_adrnr IS INITIAL.
    PERFORM get_adress_f17 USING p_object_tab_adrnr
                                 p_object_tab_tel_number
                                 p_object_tab_name_list
                                 p_object_tab_post_code1
                                 p_object_tab_city1
                                 p_object_tab_city2
                                 p_object_tab_country
                                 p_object_tab_region
                                 p_object_tab_street.

  ELSE.
    IF NOT p_object_tab_adrnr_iloa IS INITIAL.
      PERFORM get_adress_f17 USING p_object_tab_adrnr_iloa
                                   p_object_tab_tel_number
                                   p_object_tab_name_list
                                   p_object_tab_post_code1
                                   p_object_tab_city1
                                   p_object_tab_city2
                                   p_object_tab_country
                                   p_object_tab_region
                                   p_object_tab_street.
    ELSE.
      IF NOT p_object_tab_kunum IS INITIAL.
        PERFORM customer_adress_read_f17 USING
                                 p_object_tab_objnr
                                 p_object_tab_kunum
                                 p_object_tab_tel_number
                                 p_object_tab_name_list
                                 p_object_tab_post_code1
                                 p_object_tab_city1
                                 p_object_tab_city2
                                 p_object_tab_country
                                 p_object_tab_region
                                 p_object_tab_street.
      ENDIF.
    ENDIF.
  ENDIF.
ENDFORM.                               " GET_ADRESS_L
*&---------------------------------------------------------------------*
*&      Form  CALL_PLANTAFEL
*&---------------------------------------------------------------------*
*       Call the planning table
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM call_plantafel.

  DATA: fields LIKE sval OCCURS 1 WITH HEADER LINE.
  DATA: profile_id_tmp LIKE tco43-profile_id.
  DATA: loc_rc(1) TYPE c.
  DATA: cycrppro_tmp LIKE cycrppro.
  DATA: cycrpcopro_tmp LIKE cycrpcopro.
  DATA: t_return_code TYPE i.
  CLEAR: fields, fields[].

  CHECK NOT i_fil_tab[] IS INITIAL.


  fields-tabname    = 'TCY30'.
  fields-fieldname  = 'PROFILE_ID'.

  GET PARAMETER ID 'CYG' FIELD profile_id_tmp.

  SET LOCALE LANGUAGE sy-langu.
  TRANSLATE profile_id_tmp TO UPPER CASE.                "#EC TRANSLANG
  IF NOT profile_id_tmp IS INITIAL.
    fields-value = profile_id_tmp.
  ELSE.
    fields-value = 'SAPPM_G006'.
  ENDIF.

  APPEND fields.

  CALL FUNCTION 'POPUP_GET_VALUES_USER_HELP'
    EXPORTING
      f4_formname    = 'HELP_VALUES_GET'
      f4_programname = 'RCCYHELP'
      popup_title    = text-pro
    IMPORTING
      returncode     = loc_rc
    TABLES
      fields         = fields
    EXCEPTIONS
      OTHERS         = 0.


  IF loc_rc = 'A' .                    "// User aborted from the jump.
    EXIT.                   "=====================================>
  ENDIF.

  READ TABLE fields INDEX 1.
  profile_id_tmp = fields-value.

  IF profile_id_tmp IS INITIAL.
    EXIT.
  ELSE.
    SET PARAMETER ID 'CYG' FIELD profile_id_tmp.
  ENDIF.

* Gesamtprofil lesen

  CALL FUNCTION 'CY01_GET_OVERALL_PROFILE'
    EXPORTING
      profile_id = profile_id_tmp
    IMPORTING
      crppro     = cycrppro_tmp.
* Steuerungsprofil lesen
  CALL FUNCTION 'CY01_GET_CONTROL_PROFILE'
    EXPORTING
      profile_id = cycrppro_tmp-copro_id
    IMPORTING
      crpcopro   = cycrpcopro_tmp.

* Modus setzen


  IF t370a-aktyp = 'V'.
* Nicht Anzeigen
    cycrpcopro_tmp-modifymode = 'X'.
  ELSE.
* Anzeigen
    CLEAR cycrpcopro_tmp-modifymode.
  ENDIF.
* Steuerungsprofil zurückschreiben
  CALL FUNCTION 'CY01_SET_CONTROL_PROFILE'
    EXPORTING
      crpcopro = cycrpcopro_tmp.

* Auswertungszeitraum setzen
* call function 'CY01_MODIFY_TIME_PROFILE'
*      exporting
*           profile_id = profile_id_tmp
*           datum_von  = start_date
*           datum_bis  = end_date
*      exceptions
*           others     = 1.

* Kapazitätsplanung aufrufen
  CALL FUNCTION 'CY01_EXTERNAL_INTERFACE'
    EXPORTING
      function             = 'INIT'
      profile_id           = profile_id_tmp
      save_popup_imp       = 'X'
      reset_all_tables_imp = 'X'
    IMPORTING
      return_code          = t_return_code
    TABLES
      fil_tab              = i_fil_tab.
* Aufträge entsperren.
* would be better here to use lock_multi!
  DATA: loc_order LIKE caufvd-aufnr.
  LOOP AT i_fil_tab.
    loc_order = i_fil_tab-low.
    CALL FUNCTION 'CO_ZF_ORDER_DELOCK'
      EXPORTING
        aufnr  = loc_order
      EXCEPTIONS
        OTHERS = 1.
  ENDLOOP.


  LOOP AT object_tab WHERE selected = asterisk.
    object_tab-selected = space.
    MODIFY object_tab TRANSPORTING selected.
  ENDLOOP.


ENDFORM.                               " CALL_PLANTAFEL

INCLUDE miolxf18.
*&---------------------------------------------------------------------*
*&      Form  FILL_AUFNR_FROM_SOGEN_L
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM fill_aufnr_from_sogen_l.

  DATA    h_ionra LIKE ionra.
  RANGES  h_aufnr FOR viaufkst-aufnr.

*--- Über Genehmigungen Aufträge gefunden ?
  CHECK NOT g_sogen_object[] IS INITIAL.

*--- Aktuelle Selektionseinschränkung sichern
  h_aufnr[] = aufnr[].

  REFRESH aufnr.
  CLEAR   aufnr.
  aufnr-sign = 'I'.
  aufnr-option = 'EQ'.

*--- Select-option aufbauen, mit vorh. Einschränkung abmischen
  LOOP AT g_sogen_object.
    CALL FUNCTION 'OBJECT_KEY_GET'
      EXPORTING
        i_objnr = g_sogen_object-objnr
      IMPORTING
        e_ionra = h_ionra
      EXCEPTIONS
        OTHERS  = 1.
    CHECK sy-subrc IS INITIAL AND h_ionra-aufnr IN h_aufnr.
    aufnr-low = h_ionra-aufnr.
    APPEND aufnr.
  ENDLOOP.
  IF aufnr[] IS INITIAL.
*--- es wurde nicht selektiert
    MESSAGE s047.
    STOP.
  ENDIF.

ENDFORM.                               " FILL_AUFNR_FROM_SOGEN_L
*&---------------------------------------------------------------------*
*&      Form  MONITOR_ON_OFF_L
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_P_SELFIELD  text                                           *
*----------------------------------------------------------------------*
FORM monitor_on_off_l USING  p_selfield TYPE slis_selfield.

  PERFORM get_fieldcat_actual_info_f14.

  IF monitor IS INITIAL.
*--- monitor is switched on
    PERFORM monitor_inputhelp_l USING monitor.
    CHECK NOT monitor IS INITIAL.
    PERFORM check_monitor_input_l.
    PERFORM check_fieldcat_variant_l.
    PERFORM selection_l.
  ELSE.
*--- monitor is switched off
    LOOP AT object_tab.
      CLEAR object_tab-lights.
      MODIFY object_tab.
    ENDLOOP.
    CLEAR monitor.
    CLEAR g_layout-lights_fieldname.
    CLEAR g_monitor_field.
  ENDIF.

  PERFORM set_fieldcat_actual_f14.

ENDFORM.                               " MONITOR_ON_OFF_L
*&---------------------------------------------------------------------*
*&      Form  SET_OWNER_L
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM set_owner_l.

  CLEAR i_owner. REFRESH i_owner.
*--- nur füllen wenn nach Iloa-Feldern eingegrenzt --------
  IF strno[] IS INITIAL AND
     kostl[] IS INITIAL AND
     anlnr[] IS INITIAL AND
     eqfnr[] IS INITIAL AND
     swerk[] IS INITIAL.
    EXIT.
  ENDIF.
  i_owner-sign = 'I'.
  i_owner-option = 'EQ'.
*--- Auftrag aus Release 2.2
  i_owner-low    = space.
  APPEND i_owner.
*--- Auftrag mit Platz als Bezugsobject
  i_owner-low    = '2'.
  APPEND i_owner.
*--- Auftrag ohne Bezugsobject
  i_owner-low    = '6'.
  APPEND i_owner.
  IF dy_his IS INITIAL AND dy_mab IS INITIAL.
    EXIT.
  ELSE.
*--- abgeschlossener oder historischer Auftrag
    i_owner-low    = '7'.
    APPEND i_owner.
  ENDIF.

ENDFORM.                               " SET_OWNER_L
*&---------------------------------------------------------------------*
*&      Form  SELECT_T350_L
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM select_t350_l.

  SELECT * INTO TABLE t_t350
                  FROM t350 WHERE auart IN auart.
  SORT t_t350 BY auart.

ENDFORM.                               " SELECT_T350_L
*&---------------------------------------------------------------------*
*&      Form  DISPLAY_AMVK_L
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM display_amvk_l.

  DATA: f_tcode LIKE sy-tcode.
  DATA: f_retc LIKE sy-subrc.
  DATA: h_erof(1), h_iarb(1), h_abge(1), h_hist(1).
  f_tcode = 'IWBK'.

*--- Berechtigungsprüfung auf T-code -------------------------------*
  PERFORM auth_check_tcode_f16 USING f_tcode
                               CHANGING f_retc.

  IF f_retc IS INITIAL.
    PERFORM create_range_l.
    DESCRIBE TABLE object LINES sy-tfill.
    IF sy-tfill > 200.
*--- Zuviel für Selektion
      MESSAGE e103.
      EXIT.
    ELSEIF NOT object[] IS INITIAL.
*--- Aufträge mit welcher Phase wurden ausgewählt?
      READ TABLE object_tab WITH KEY selected = g_x
                                     iphas    = '0'.
      IF sy-subrc IS INITIAL. h_erof = g_x. ENDIF.
      READ TABLE object_tab WITH KEY selected = g_x
                                     iphas    = '2'.
      IF sy-subrc IS INITIAL. h_iarb = g_x. ENDIF.
      READ TABLE object_tab WITH KEY selected = g_x
                                     iphas    = '3'.
      IF sy-subrc IS INITIAL. h_abge = g_x. ENDIF.
*--- Historische Aufträge relevant?
      h_hist = dy_his.
*--- Aufruf Verfügbarkeitsreport
      SUBMIT riaufmvk WITH aufnr IN object
                      WITH offen = h_erof
                      WITH inarb = h_iarb
                      WITH abges = h_abge
                      WITH histo = h_hist
             AND RETURN.
    ENDIF.
  ENDIF.

ENDFORM.                               " DISPLAY_AMVK_L
*&---------------------------------------------------------------------*
*&      Form  CHECK_SEL_STATI_L
*&---------------------------------------------------------------------*
*       preselect ordernumbers for status inclusive
*----------------------------------------------------------------------*
*  <--  E_OBJ_FOUND Object for status found? Yes/No
*----------------------------------------------------------------------*
FORM check_sel_stati_l USING e_obj_found TYPE c.

  RANGES h_dummy FOR jest-stat.
  RANGES h_aufnr  FOR viaufkst-aufnr.

  STATICS: h_once.

  STATICS: BEGIN OF h_aufnr2 OCCURS 0,
            sign(1),
            option(2),
            low  LIKE viaufkst-aufnr,
            high LIKE viaufkst-aufnr,
           END OF h_aufnr2.

  CLEAR e_obj_found.

*--- not if historical orders are selected.
  CHECK NOT stai1[] IS INITIAL AND dy_his IS INITIAL .

  IF h_once IS INITIAL.
    h_aufnr2[] = aufnr[].
    h_once = g_x.
  ENDIF.

  PERFORM preselect_status_f22 TABLES stai1
                                      h_dummy
                                      h_aufnr
                               USING  'OR'
                                      e_obj_found.

*--- nothing found or too many entries
  IF e_obj_found NE yes.
    EXIT.
  ENDIF.

*--- Select-option für AUFNR füllen, vorhanden Eingrenzungen
*--- berücksichtigen, Mehrfacheinträge löschen
  CHECK NOT h_aufnr[] IS INITIAL.

  CLEAR aufnr. REFRESH aufnr.

  LOOP AT h_aufnr WHERE low IN h_aufnr2.
    APPEND h_aufnr TO aufnr.
  ENDLOOP.

  IF aufnr[] IS INITIAL.
*--- es wurde nicht selektiert
    MESSAGE s047(ih).
    e_obj_found = no.
    EXIT.
  ELSE.
    e_obj_found = yes.
  ENDIF.

  SORT aufnr.
  DELETE ADJACENT DUPLICATES FROM aufnr.

ENDFORM.                               " CHECK_SEL_STATI_L

*&---------------------------------------------------------------------*
*&      Form  SET_AUDISP_L
*&---------------------------------------------------------------------*
*       Dispokennzeichen Auftragskopf setzten
*----------------------------------------------------------------------*
*       object_tab-audisp  -> Dispokennzeichen auf Dynpro
*       object_tab-no_disp -> Dispokennzeichen auf Datenbank
*----------------------------------------------------------------------*
FORM set_audisp_l CHANGING is_object_tab LIKE LINE OF object_tab.

  CLEAR is_object_tab-audisp.

  CASE is_object_tab-no_disp.
    WHEN space.
      is_object_tab-audisp = '3'.
    WHEN '1'.
      is_object_tab-audisp = '1'.
    WHEN 'X'.
      is_object_tab-audisp = '2'.
  ENDCASE.

ENDFORM.                               " SET_AUDISP_L

*---------------------------------------------------------------------*
*       FORM post_read_parnr_l                                        *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM post_read_parnr_l.

  DATA: BEGIN OF ht_ihpa OCCURS 0,
          objnr LIKE ihpa-objnr,
        END OF ht_ihpa.

  FIELD-SYMBOLS: <ls_object_tab> LIKE LINE OF object_tab.

*--- Vorraussetzungen für Nachselektion prüfen
  IF object_tab[] IS INITIAL.
    EXIT.
  ENDIF.
  IF dy_parnr IS INITIAL OR dy_parvw IS INITIAL.
    EXIT.
  ENDIF.
*--- Nachselektion Partner zum Object/Beleg
  SELECT objnr FROM ihpa INTO TABLE ht_ihpa
               FOR ALL ENTRIES IN object_tab
               WHERE   objnr     = object_tab-objnr
               AND     parvw     = dy_parvw
               AND     parnr     = dy_parnr
               AND     kzloesch  =  space.

  SORT ht_ihpa BY objnr.

  CLEAR l_jsto_pre_tab. REFRESH l_jsto_pre_tab.
*--- Object_tab aktualisieren
  LOOP AT object_tab ASSIGNING <ls_object_tab>.
    READ TABLE ht_ihpa WITH KEY objnr = <ls_object_tab>-objnr
                                BINARY SEARCH.
    IF NOT sy-subrc IS INITIAL.
      DELETE object_tab.
    ELSE.
*--- Tabelle für Status Check neu aufbauen
      l_jsto_pre_tab = <ls_object_tab>-objnr.
      APPEND l_jsto_pre_tab.
    ENDIF.
  ENDLOOP.

ENDFORM.                                                    "
*---------------------------------------------------------------------*
*       FORM status_check_l                                           *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM status_check_l.

  FIELD-SYMBOLS: <ls_object_tab> LIKE LINE OF object_tab.

*--- Sortieren wegen binary search ----------------------------------*
  SORT g_fieldcat_tab BY fieldname.
*--- Statuszeile nachlesen ? ----------------------------------------*
  IF g_grstat IS INITIAL.
    PERFORM check_field_display_f14 USING 'STTXT' g_sttxt_flag.
    IF g_sttxt_flag <> yes.
      PERFORM check_field_display_f14 USING 'USTXT' g_sttxt_flag.
    ENDIF.
  ELSE.
    g_sttxt_flag = yes.
  ENDIF.
*--- Selektion Status inclusive/exclusisve -------------------------*
  DESCRIBE TABLE stai1 LINES g_stai1_lines.
  DESCRIBE TABLE stae1 LINES g_stae1_lines.
  IF g_stai1_lines IS INITIAL AND
     g_stae1_lines IS INITIAL.
    g_stasl_flag = no.
  ELSE.
    g_stasl_flag = yes.
  ENDIF.
*--- prefetch Status, merker setzten --------------------------------*
  IF g_stasl_flag = yes OR g_sttxt_flag = yes.
    CALL FUNCTION 'STATUS_PRE_READ'
      TABLES
        jsto_pre_tab = l_jsto_pre_tab.
    g_statbuf_flag = yes.
  ELSE.
    g_statbuf_flag = space.
  ENDIF.
*--- Status Einträge in Object_tab prüfen ggf. löschen
*--- nachfolgende pre-fetch Tabellen neu aufbauen
  IF g_stasl_flag = yes.
    REFRESH: g_equnr_tab,
             g_tplnr_tab.
    LOOP AT object_tab ASSIGNING <ls_object_tab>.
*--- Statusprüfung
      PERFORM status_proof_l USING <ls_object_tab>-objnr g_answer.
      IF g_answer = no.
        DELETE object_tab.
      ENDIF.
      CHECK g_answer = yes.
*--- Prefetchtabellen für Authority check neu füllen
      IF NOT <ls_object_tab>-equnr IS INITIAL.
        g_equnr_tab-equnr = <ls_object_tab>-equnr.
        COLLECT g_equnr_tab.
      ENDIF.
      IF NOT <ls_object_tab>-tplnr_int IS INITIAL.
        g_tplnr_tab-tplnr = <ls_object_tab>-tplnr_int.
        COLLECT g_tplnr_tab.
      ENDIF.
    ENDLOOP.
  ENDIF.

ENDFORM.                               " STATUS_CHECK_F30
*---------------------------------------------------------------------*
*       FORM prepare_data_f_download_l                                *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
*  -->  p_ucomm                                                       *
*  -->  p_selfield                                                    *
*---------------------------------------------------------------------*
FORM prepare_data_f_download_l USING p_ucomm    LIKE sy-ucomm
                                     p_selfield TYPE slis_selfield.

  DATA lt_rihaufk LIKE rihaufk OCCURS 0 WITH HEADER LINE.

*--- check enties marked
  PERFORM check_object_tab_marked_f14 USING p_ucomm
                                             p_selfield.
*--- activate all flags for post read data
  PERFORM check_flags_with_selmod_l.
*--- post read data for marked entries
  LOOP AT object_tab WHERE selected = g_x.
    PERFORM select_for_quickinfo_l USING p_selfield.
*--- fill pre-fetch table for cost selection
    MOVE-CORRESPONDING object_tab TO lt_rihaufk.
    APPEND lt_rihaufk.
  ENDLOOP.
*--- post read cost data
  PERFORM post_read_costs_l TABLES lt_rihaufk.
*--- clear all flags
  PERFORM clear_flags_l.

ENDFORM.                               " PREPARE_DATA_F_DOWNLOAD_F30

*---------------------------------------------------------------------*
*       FORM clear_flags_l                                            *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM clear_flags_l.

  CLEAR:
      g_kost_flag,
      g_sttxt_flag,
      g_arbpl_flag,
      g_gewrk_flag,
      g_egauzt_flag,
      g_stasl_flag,
      g_eqktx_flag,
      g_pltxt_flag,
      g_vorue_flag,
      g_adres_flag,
      g_maktx_flag,
      g_priokx_flag,
      g_statbuf_flag,
      g_crhd_flag.

ENDFORM.                    "clear_flags_l
*&---------------------------------------------------------------------*
*&      Form  DELETE_HIKO_L
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM delete_hiko_l.

*--- Funktion zum Löschen aufrufen
  DATA lt_aufnr LIKE aufnr OCCURS 0 WITH HEADER LINE.
*--- Tabelle mit hist. Aufträgen füllen
  LOOP AT object_tab WHERE iphas = '5' AND selected = g_x.
    lt_aufnr = object_tab-aufnr. APPEND lt_aufnr.
*--- Markierung Ändern
    PERFORM mark_selected_f16 CHANGING object_tab-selected
                                       object_tab-pm_selected.
  ENDLOOP.
*--- keine Aufträge markiert -> exit
  IF NOT sy-subrc IS INITIAL.
    MESSAGE i011.
    EXIT.
  ENDIF.
*--- Funktion zum Löschen aufrufen
  CALL FUNCTION 'PM_HIS_ORDER_DELETE_PREP'
    TABLES
      it_aufnr = lt_aufnr.

ENDFORM.                    " DELETE_HIKO_L

*&---------------------------------------------------------------------*
*&      Form  SELECT_AUFNR_VIA_AUFPL
*&---------------------------------------------------------------------*
*       Selektieren der Auftragsnummer aus VIAFKOS über AUFPL
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM select_aufnr_via_aufpl.


  REFRESH aufnr.
  CLEAR aufnr.
  aufnr-sign   = 'I'.
  aufnr-option = 'EQ'.

  SELECT aufnr FROM viafkos
               INTO aufnr-low
               FOR ALL ENTRIES IN aufpl
               WHERE aufpl = aufpl-low
               AND   aufnr IN i_aufnr
               AND   auart IN auart
               AND   addat IN gr_date.
    APPEND aufnr.
  ENDSELECT.

  IF NOT sy-subrc IS INITIAL.
    MESSAGE s047.
    LEAVE TO TRANSACTION dy_tcode.
  ENDIF.
  REFRESH aufpl.

ENDFORM.                    " SELECT_AUFNR_VIA_AUFPL
*&---------------------------------------------------------------------*
*&      Form  post_read_costs_l
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_LT_RIHAUFK  text
*----------------------------------------------------------------------*
FORM post_read_costs_l TABLES pt_rihaufk STRUCTURE rihaufk.

*--- check input table
  IF pt_rihaufk[] IS INITIAL.
    EXIT.
  ENDIF.
*--- read cost data
  CALL FUNCTION 'PM_WORKORDER_COSTS_LIST'
    EXPORTING
      list_currency  = waers
      all_currencies = 'X'
      external_call  = 'X'
    TABLES
      list_aufk      = pt_rihaufk
    EXCEPTIONS
      no_currency    = 1
      OTHERS         = 2.
*--- update global object_tab with cost data
  IF sy-subrc <> 1.
    LOOP AT pt_rihaufk.
      READ TABLE object_tab WITH KEY aufnr = pt_rihaufk-aufnr.
      IF sy-subrc IS INITIAL.
        MOVE-CORRESPONDING pt_rihaufk TO object_tab.
        MODIFY object_tab INDEX sy-tabix.
      ENDIF.
    ENDLOOP.
  ENDIF.

ENDFORM.                    " post_read_costs_l

*&---------------------------------------------------------------------*
*&      Form  check_linked_mplan_l
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_L_IND_LINK_MPLAN  text
*      -->P_ANSWER  text
*----------------------------------------------------------------------*
FORM check_linked_mplan_l  USING    p_ind_linked_mplan TYPE char01
                                    p_answer           TYPE char01.

*--- data definition
  DATA:   l_t_object              TYPE TABLE OF conf_objects
                                       WITH HEADER LINE.
  DATA:   l_ind_confirmation_date LIKE t399w-mpconfdate.

*--- init local data
  CLEAR p_ind_linked_mplan.

*--- check whether the functionality related to the confirmation date
*    of a maintenance plan is active or not
*    (maintenance plan type; table t399w)
  CALL FUNCTION 'IWP3_GET_IND_CONFIRMATION_DATE'
    EXPORTING
      i_ind_one               = 'X'
    IMPORTING
      e_ind_confirmation_date = l_ind_confirmation_date
    EXCEPTIONS
      OTHERS                  = 1.

  IF sy-subrc = 0.
    IF l_ind_confirmation_date EQ 'X'.
*--- at least one maintenance plan type with an active flag
*    "CONFIRMATION DATE" was found
    ELSE.
*--- no maintenance plan type with active flag found
      CLEAR p_ind_linked_mplan.
      EXIT.
    ENDIF.
  ELSE.
*--- no existing maintenance plan type found
    CLEAR p_ind_linked_mplan.
    EXIT.
  ENDIF.

*---  fill object tab
  LOOP AT object_tab WHERE selected = g_x.
    l_t_object-aufnr = object_tab-aufnr.
    l_t_object-obknr = object_tab-obknr.
    l_t_object-warpl = object_tab-warpl.
    APPEND l_t_object.
  ENDLOOP.

  CLEAR g_riarch.
  CLEAR g_t_riarch. REFRESH g_t_riarch.

  CALL FUNCTION 'CO_I0_ARCH_POPUP'
    EXPORTING
      SOURCE     = 'IW38'
    IMPORTING
      riarch_exp = g_riarch
    TABLES
      t_object   = l_t_object
      t_riarch   = g_t_riarch
    EXCEPTIONS
      escape     = 8.

  IF sy-subrc = 8.
    CLEAR g_ucomm.
    CLEAR g_riarch.
    p_answer = 'A'.
  ELSE.
    READ TABLE g_t_riarch INDEX 1.
*--- in case of active funktionality "confirmation date"
    IF g_t_riarch-ind_confdate = g_x.
      p_ind_linked_mplan = g_x.
    ENDIF.

    IF g_t_riarch-close_notific IS INITIAL.
*--- don't close notification in object list
      p_answer = '1'.
    ELSE.
*--- close notifications in object list
      p_answer = '2'.
    ENDIF.
  ENDIF.

ENDFORM.                    " check_linked_mplan_l

*eject
*-------------------------------------------------------------------*
* INCLUDES                                                          *
*-------------------------------------------------------------------*
INCLUDE miolxf14.
INCLUDE miolxf16.
INCLUDE miolxf17.
INCLUDE miolxf19.
INCLUDE miolxf22.
INCLUDE miolxf23.
INCLUDE miolxf24.
INCLUDE miolxf65.
INCLUDE miolxf66.
INCLUDE miolxf67.
INCLUDE miolxf69.
INCLUDE miolxf70.
INCLUDE miolxf71.
INCLUDE miolxf89.
INCLUDE rivci000.
INCLUDE exwpsf01.
INCLUDE ifviexev.     " include for RealEstate
INCLUDE ifviexfo.     " include for RealEstate
*ENHANCEMENT-POINT riaufk20_06 SPOTS es_riaufk20 STATIC.
*&---------------------------------------------------------------------*
*&      Form  ATPCHECK
*&---------------------------------------------------------------------*
FORM atpcheck .

 PERFORM get_sort_table.


* end sort table sunil

*  data : et_messages type bal_t_msg.
*
*LOOP at sort_tab.
*
*    call function 'IBAPI_ALM_ORDER_ATP_CHECK'
*    exporting
*      iv_orderid  = sort_tab-aufnr
*    tables
*      et_messages = et_messages.
*
*  call function 'BAPI_TRANSACTION_COMMIT'.
*
*
*ENDLOOP .



  DATA : methods      TYPE STANDARD TABLE OF bapi_alm_order_method,
         lt_return    TYPE STANDARD TABLE OF bapiret2,

         ls_return LIKE LINE OF lt_return.

  DATA : xmethod      LIKE bapi_alm_order_method.

  LOOP AT object_tab.


    CLEAR: xmethod, methods, lt_return.

  xmethod-refnumber     = 1.
  xmethod-objecttype    = 'HEADER'.
  xmethod-method        = 'ATPCHECK'.
  xmethod-objectkey(12) = object_tab-aufnr.
  APPEND xmethod TO methods.


  CLEAR xmethod.
  xmethod-refnumber     = 2.
  xmethod-method        = 'SAVE'.
  xmethod-objectkey(12) = object_tab-aufnr.
  APPEND xmethod TO methods.


*  CALL FUNCTION 'BUFFER_REFRESH_ALL'.

  CALL FUNCTION 'BAPI_ALM_ORDER_MAINTAIN'
    TABLES
      it_methods   = methods
      return       = lt_return.



  CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
   EXPORTING
     wait          = 'X'
*   IMPORTING
*     RETURN        = ls_return.
  .




  ENDLOOP .



ENDFORM.                    " ATPCHECK
*&---------------------------------------------------------------------*
*&      Form  SORTING_SELECTION
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM sorting_selection .




  text006 = 'Sort criteria'.
  text1 = 'Sort Field'.
  text2 = 'Sort Posn'.
  text3 = 'Asc/Desc'.
  text4 = 'Priority Values'.
  text5 = 'Order type'.
  text6 = 'Basic start Date'.
  text7 = 'Priority'.
  text8 = 'Revision Code'.
  text9 = 'System Status'.
  text10 = 'User Status'.
  text11 = 'Maintanance activity type'.
  text12 = 'Planner group'.
  text13 = 'Actual start date'.



APPEND INITIAL LINE TO lt_vrm_values.

  wa_vrm_values-key = '1'.
  wa_vrm_values-text = '1'.
  APPEND wa_vrm_values TO lt_vrm_values.

  wa_vrm_values-key = '2'.
  wa_vrm_values-text = '2'.
  APPEND wa_vrm_values TO lt_vrm_values.

  wa_vrm_values-key = '3'.
  wa_vrm_values-text = '3'.
  APPEND wa_vrm_values TO lt_vrm_values.

    wa_vrm_values-key = '4'.
  wa_vrm_values-text = '4'.
  APPEND wa_vrm_values TO lt_vrm_values.

  wa_vrm_values-key = '5'.
  wa_vrm_values-text = '5'.
  APPEND wa_vrm_values TO lt_vrm_values.

  wa_vrm_values-key = '6'.
  wa_vrm_values-text = '6'.
  APPEND wa_vrm_values TO lt_vrm_values.

    wa_vrm_values-key = '7'.
  wa_vrm_values-text = '7'.
  APPEND wa_vrm_values TO lt_vrm_values.

  wa_vrm_values-key = '8'.
  wa_vrm_values-text = '8'.
  APPEND wa_vrm_values TO lt_vrm_values.

  wa_vrm_values-key = '9'.
  wa_vrm_values-text = '9'.
  APPEND wa_vrm_values TO lt_vrm_values.


* valules for ascen/descen

  APPEND INITIAL LINE TO lt_vrm_values1.

  wa_vrm_values1-key = 'A'.
  wa_vrm_values1-text = 'A'.
  APPEND wa_vrm_values1 TO lt_vrm_values1.

  wa_vrm_values1-key = 'D'.
  wa_vrm_values1-text = 'D'.
  APPEND wa_vrm_values1 TO lt_vrm_values1.

ENDFORM.                    " SORTING_SELECTION
*&---------------------------------------------------------------------*
*&      Form  LISTBOXES
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM listboxes .


  CALL FUNCTION 'VRM_SET_VALUES'
       EXPORTING
            id              = 'P_AUART'
            values          = lt_vrm_values
       EXCEPTIONS
            id_illegal_name = 1
            OTHERS          = 2.
  IF sy-subrc =  0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.

    CALL FUNCTION 'VRM_SET_VALUES'
       EXPORTING
            id              = 'P_GSTRP'
            values          = lt_vrm_values
       EXCEPTIONS
            id_illegal_name = 1
            OTHERS          = 2.
  IF sy-subrc =  0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.


    CALL FUNCTION 'VRM_SET_VALUES'
       EXPORTING
            id              = 'P_PRIOK'
            values          = lt_vrm_values
       EXCEPTIONS
            id_illegal_name = 1
            OTHERS          = 2.
  IF sy-subrc =  0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.

    CALL FUNCTION 'VRM_SET_VALUES'
       EXPORTING
            id              = 'P_REVNR'
            values          = lt_vrm_values
       EXCEPTIONS
            id_illegal_name = 1
            OTHERS          = 2.
  IF sy-subrc =  0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.

    CALL FUNCTION 'VRM_SET_VALUES'
       EXPORTING
            id              = 'P_STTXT'
            values          = lt_vrm_values
       EXCEPTIONS
            id_illegal_name = 1
            OTHERS          = 2.
  IF sy-subrc =  0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.

    CALL FUNCTION 'VRM_SET_VALUES'
       EXPORTING
            id              = 'P_USTXT'
            values          = lt_vrm_values
       EXCEPTIONS
            id_illegal_name = 1
            OTHERS          = 2.
  IF sy-subrc =  0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.

    CALL FUNCTION 'VRM_SET_VALUES'
       EXPORTING
            id              = 'P_ILART'
            values          = lt_vrm_values
       EXCEPTIONS
            id_illegal_name = 1
            OTHERS          = 2.
  IF sy-subrc =  0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.

    CALL FUNCTION 'VRM_SET_VALUES'
       EXPORTING
            id              = 'P_INGPR'
            values          = lt_vrm_values
       EXCEPTIONS
            id_illegal_name = 1
            OTHERS          = 2.
  IF sy-subrc =  0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.

    CALL FUNCTION 'VRM_SET_VALUES'
       EXPORTING
            id              = 'P_GSTRI'
            values          = lt_vrm_values
       EXCEPTIONS
            id_illegal_name = 1
            OTHERS          = 2.
  IF sy-subrc =  0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.


*for AsCEN/DESCN


CALL FUNCTION 'VRM_SET_VALUES'
       EXPORTING
            id              = 'P1_AUART'
            values          = lt_vrm_values1
       EXCEPTIONS
            id_illegal_name = 1
            OTHERS          = 2.
  IF sy-subrc =  0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.

    CALL FUNCTION 'VRM_SET_VALUES'
       EXPORTING
            id              = 'P1_GSTRP'
            values          = lt_vrm_values1
       EXCEPTIONS
            id_illegal_name = 1
            OTHERS          = 2.
  IF sy-subrc =  0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.


    CALL FUNCTION 'VRM_SET_VALUES'
       EXPORTING
            id              = 'P1_PRIOK'
            values          = lt_vrm_values1
       EXCEPTIONS
            id_illegal_name = 1
            OTHERS          = 2.
  IF sy-subrc =  0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.

    CALL FUNCTION 'VRM_SET_VALUES'
       EXPORTING
            id              = 'P1_REVNR'
            values          = lt_vrm_values1
       EXCEPTIONS
            id_illegal_name = 1
            OTHERS          = 2.
  IF sy-subrc =  0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.

    CALL FUNCTION 'VRM_SET_VALUES'
       EXPORTING
            id              = 'P1_STTXT'
            values          = lt_vrm_values1
       EXCEPTIONS
            id_illegal_name = 1
            OTHERS          = 2.
  IF sy-subrc =  0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.

    CALL FUNCTION 'VRM_SET_VALUES'
       EXPORTING
            id              = 'P1_USTXT'
            values          = lt_vrm_values1
       EXCEPTIONS
            id_illegal_name = 1
            OTHERS          = 2.
  IF sy-subrc =  0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.

    CALL FUNCTION 'VRM_SET_VALUES'
       EXPORTING
            id              = 'P1_ILART'
            values          = lt_vrm_values1
       EXCEPTIONS
            id_illegal_name = 1
            OTHERS          = 2.
  IF sy-subrc =  0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.

    CALL FUNCTION 'VRM_SET_VALUES'
       EXPORTING
            id              = 'P1_INGPR'
            values          = lt_vrm_values1
       EXCEPTIONS
            id_illegal_name = 1
            OTHERS          = 2.
  IF sy-subrc =  0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.

    CALL FUNCTION 'VRM_SET_VALUES'
       EXPORTING
            id              = 'P1_GSTRI'
            values          = lt_vrm_values1
       EXCEPTIONS
            id_illegal_name = 1
            OTHERS          = 2.
  IF sy-subrc =  0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.

ENDFORM.                    " LISTBOXES
*&---------------------------------------------------------------------*
*&      Form  GET_SORT_TABLE
*&---------------------------------------------------------------------*

FORM get_sort_table .

  DATA: temp_object_tab LIKE object_tab OCCURS 0.


  PERFORM get_sortkey.

  LOOP AT object_tab.
    CLEAR sort_tab.

    sort_tab-aufnr = object_tab-aufnr.


* AUART order type sort
    IF p_auart IS INITIAL .

      sort_tab-auart = object_tab-auart.

     ELSE.

        IF p1_auart IS NOT INITIAL .

          sort_tab-auart = object_tab-auart.

        ELSE.

          READ TABLE s_auart TRANSPORTING NO FIELDS WITH KEY low = object_tab-auart.

          IF sy-subrc = 0.

            sort_tab-auart = sy-tabix.

          ELSE.

            sort_tab-auart = '9999'.

          ENDIF.



        ENDIF.



     ENDIF.



* Basic start date.
IF p_gstrp IS INITIAL .

      sort_tab-gstrp = object_tab-gstrp.

     ELSE.

        IF p1_gstrp IS NOT INITIAL .

          sort_tab-gstrp = object_tab-gstrp.

        ELSE.

          READ TABLE s_gstrp TRANSPORTING NO FIELDS WITH KEY low = object_tab-gstrp.

          IF sy-subrc = 0.

            sort_tab-gstrp = sy-tabix.

          ELSE.

            sort_tab-gstrp = '99999999'.

          ENDIF.



        ENDIF.



     ENDIF.


* priority


IF p_priok IS INITIAL .

      sort_tab-priok = object_tab-priok.

     ELSE.
*          if P1_PRIOK is INITIAL. P1_PRIOK = 'A'. ENDIF.      "+

        IF p1_priok IS NOT INITIAL .

          sort_tab-priok = object_tab-priok.

        ELSE.


          READ TABLE s_priok TRANSPORTING NO FIELDS WITH KEY low = object_tab-priok.

          IF sy-subrc = 0.

            sort_tab-priok = sy-tabix.

          ELSE.

            sort_tab-priok = '9'.

          ENDIF.



        ENDIF.



     ENDIF.

* revision code

     IF p_revnr IS INITIAL .

      sort_tab-revnr = object_tab-revnr.

     ELSE.
*       if P1_REVNR is INITIAL. P1_REVNR = 'A'. ENDIF.      "+

        IF p1_revnr IS NOT INITIAL .

          sort_tab-revnr = object_tab-revnr.

        ELSE.

          READ TABLE s_revnr TRANSPORTING NO FIELDS WITH KEY low = object_tab-revnr.

          IF sy-subrc = 0.

            sort_tab-revnr = sy-tabix.

          ELSE.

            sort_tab-revnr = '99999999'.

          ENDIF.



        ENDIF.



     ENDIF.

* system status.

IF p_sttxt IS INITIAL .

      sort_tab-sttxt = object_tab-sttxt.

     ELSE.
*           IF p1_sttxt IS INITIAL. p1_sttxt = 'A'. ENDIF.      "+

        IF p1_sttxt IS NOT INITIAL .

          sort_tab-sttxt = object_tab-sttxt.

        ELSE.

          READ TABLE s_sttxt TRANSPORTING NO FIELDS WITH KEY low = object_tab-sttxt.

          IF sy-subrc = 0.

            sort_tab-sttxt = sy-tabix.

          ELSE.

            sort_tab-sttxt = '9999'.

          ENDIF.



        ENDIF.



     ENDIF.

*user status.
IF p_ustxt IS INITIAL .

      sort_tab-ustxt = object_tab-ustxt.

     ELSE.
*           IF p1_ustxt IS INITIAL. p1_ustxt = 'A'. ENDIF.      "+

        IF p1_ustxt IS NOT INITIAL .

          sort_tab-ustxt = object_tab-ustxt.

        ELSE.

          READ TABLE s_ustxt TRANSPORTING NO FIELDS WITH KEY low = object_tab-ustxt.

          IF sy-subrc = 0.

            sort_tab-ustxt = sy-tabix.

          ELSE.

            sort_tab-ustxt = '9999'.

          ENDIF.



        ENDIF.



     ENDIF.


* maintanance activity type.

IF p_ilart IS INITIAL .

      sort_tab-ilart = object_tab-ilart.

     ELSE.
*           IF p1_ilart IS INITIAL. p1_ilart = 'A'. ENDIF.      "+

        IF p1_ilart IS NOT INITIAL .

          sort_tab-ilart = object_tab-ilart.

        ELSE.

          READ TABLE s_ilart TRANSPORTING NO FIELDS WITH KEY low = object_tab-ilart.

          IF sy-subrc = 0.

            sort_tab-ilart = sy-tabix.

          ELSE.

            sort_tab-ilart = '999'.

          ENDIF.



        ENDIF.



     ENDIF.


*Planner group.
IF p_ingpr IS INITIAL .

      sort_tab-ingpr = object_tab-ingpr.

     ELSE.
*           IF p1_ingpr IS INITIAL. p1_ingpr = 'A'. ENDIF.      "+

        IF p1_ingpr IS NOT INITIAL .

          sort_tab-ingpr = object_tab-ingpr.

        ELSE.

          READ TABLE s_ingpr TRANSPORTING NO FIELDS WITH KEY low = object_tab-ingpr.

          IF sy-subrc = 0.

            sort_tab-ingpr = sy-tabix.

          ELSE.

            sort_tab-ingpr = '999'.

          ENDIF.



        ENDIF.



     ENDIF.


* actual start date.

IF p_gstri IS INITIAL .

      sort_tab-gstri = object_tab-gstri.

     ELSE.
*           IF p1_gstri IS INITIAL. p1_gstri = 'A'. ENDIF.      "+

        IF p1_gstri IS NOT INITIAL .

          sort_tab-gstri = object_tab-gstri.

        ELSE.

          READ TABLE s_gstri TRANSPORTING NO FIELDS WITH KEY low = object_tab-gstri.

          IF sy-subrc = 0.

            sort_tab-gstri = sy-tabix.

          ELSE.

            sort_tab-gstri = '99999999'.

          ENDIF.



        ENDIF.



     ENDIF.


     APPEND sort_tab.


ENDLOOP .


    CALL FUNCTION 'C140_TABLE_DYNAMIC_SORT'
      TABLES
        i_sortfield_tab      = sorttab
        x_tab                = sort_tab
      EXCEPTIONS
        sortfieldtab_too_big = 1
        OTHERS               = 2.


LOOP AT sort_tab.

  READ TABLE object_tab WITH KEY aufnr = sort_tab-aufnr.

  IF sy-subrc = 0.

    APPEND object_tab TO temp_object_tab .

  ENDIF.


ENDLOOP .

CLEAR: object_tab, object_tab[].

object_tab[] = temp_object_tab[].


ENDFORM.                    " GET_SORT_TABLE
*&---------------------------------------------------------------------*
*&      Form  GET_SORTKEY
*&---------------------------------------------------------------------*
FORM get_sortkey .


  DATA: BEGIN OF temp_sorttab OCCURS 0,
         posn        TYPE numc1,
         name(30)    TYPE c,
         flg_desc(1) TYPE c,
        END OF temp_sorttab.


  IF p_auart IS NOT INITIAL.

      temp_sorttab-posn = p_auart.
      temp_sorttab-name = 'AUART'.

    IF p1_auart = 'D'.

      temp_sorttab-flg_desc = 'X'.
    ELSE.
      temp_sorttab-flg_desc = ''    .

    ENDIF.

    APPEND temp_sorttab.

  ENDIF.

    IF p_gstrp IS NOT INITIAL.

      temp_sorttab-posn = p_gstrp.
      temp_sorttab-name = 'GSTRP'.

    IF p1_gstrp = 'D'.

      temp_sorttab-flg_desc = 'X'.
    ELSE.
      temp_sorttab-flg_desc = ''    .

    ENDIF.

    APPEND temp_sorttab.

  ENDIF.

    IF p_priok IS NOT INITIAL.

      temp_sorttab-posn = p_priok.
      temp_sorttab-name = 'PRIOK'.

    IF p1_priok = 'D'.

      temp_sorttab-flg_desc = 'X'.
    ELSE.
      temp_sorttab-flg_desc = ''    .

    ENDIF.

    APPEND temp_sorttab.

  ENDIF.

    IF p_revnr IS NOT INITIAL.

      temp_sorttab-posn = p_revnr.
      temp_sorttab-name = 'REVNR'.

    IF p1_revnr = 'D'.

      temp_sorttab-flg_desc = 'X'.

    ELSE.
      temp_sorttab-flg_desc = ''    .
    ENDIF.

    APPEND temp_sorttab.

  ENDIF.

    IF p_sttxt IS NOT INITIAL.

      temp_sorttab-posn = p_sttxt.
      temp_sorttab-name = 'STTXT'.

    IF p1_sttxt = 'D'.

      temp_sorttab-flg_desc = 'X'.
    ELSE.
      temp_sorttab-flg_desc = ''    .

    ENDIF.

    APPEND temp_sorttab.

  ENDIF.

    IF p_ustxt IS NOT INITIAL.

      temp_sorttab-posn = p_ustxt.
      temp_sorttab-name = 'USTXT'.

    IF p1_ustxt = 'D'.

      temp_sorttab-flg_desc = 'X'.
    ELSE.
      temp_sorttab-flg_desc = ''    .

    ENDIF.

    APPEND temp_sorttab.

  ENDIF.

    IF p_ilart IS NOT INITIAL.

      temp_sorttab-posn = p_ilart.
      temp_sorttab-name = 'ILART'.

    IF p1_ilart = 'D'.

      temp_sorttab-flg_desc = 'X'.
    ELSE.
      temp_sorttab-flg_desc = ''    .

    ENDIF.

    APPEND temp_sorttab.

  ENDIF.

    IF p_ingpr IS NOT INITIAL.

      temp_sorttab-posn = p_ingpr.
      temp_sorttab-name = 'INGPR'.

    IF p1_ingpr = 'D'.

      temp_sorttab-flg_desc = 'X'.
    ELSE.
      temp_sorttab-flg_desc = ''    .

    ENDIF.

    APPEND temp_sorttab.

  ENDIF.

    IF p_gstri IS NOT INITIAL.

      temp_sorttab-posn = p_gstri.
      temp_sorttab-name = 'GSTRI'.

    IF p1_gstri = 'D'.

      temp_sorttab-flg_desc = 'X'.
    ELSE.
      temp_sorttab-flg_desc = ''    .

    ENDIF.

    APPEND temp_sorttab.

  ENDIF.


  SORT temp_sorttab BY posn.

  LOOP AT temp_sorttab.

    sorttab-name = temp_sorttab-name.
    sorttab-flg_desc = temp_sorttab-flg_desc.

    APPEND sorttab.

 ENDLOOP .



ENDFORM.                    " GET_SORTKEY
