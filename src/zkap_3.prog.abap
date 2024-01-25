*&---------------------------------------------------------------------*
*&  Include           ZRHR_EML_GET_TEXT
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  F_GET_TEXT
*&---------------------------------------------------------------------*
*       text: Get Field Text
*----------------------------------------------------------------------*
*++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*
* CHANGE ID : HANA-001
* USER: ACC11343254
* DATE: 13.07.2017
* TR : S7HK900506
* DESCRIPTION: HANA CORRECTION
* TEAM : HANA-MIGRATION
*++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*
FORM f_get_text.

  PERFORM f_zhr_om_subgrades.     "Subtantive Grade
  PERFORM f_t501t.                "EE Group
  PERFORM f_t503t.                "EE Sub Group
  PERFORM f_t500p.                "Personnel Area
**Added by A_ATIKAJA SSC CR1202 06/12/2012
  PERFORM f_t526.                 "Pers Admin
**Ended by A_ATIKAJA SSC CR1202 06/12/2012
  PERFORM f_t001p.                "Personnel Sub Area
  PERFORM f_hrp1513.              "Job Index Key
  PERFORM f_t527x.                "Org Unit
  PERFORM f_t528t.                "Position
*  PERFORM f_hrp1001.              "Second Position & Reporting Officer
  PERFORM f_t516t.                "Religious Denomination Texts
  PERFORM f_t505s.                "Race Text
  PERFORM f_t502t.                "Marital Status Designators
  PERFORM f_cskt.                 "Cost Center Texts
  PERFORM f_t5r06.                "Types of Identification - Texts
  PERFORM f_t547s.                "Contract Type Texts
  PERFORM f_t5uca.                "Benefit Scheme & Medical Scheme texts
  PERFORM f_t5pbsr3at.            "Text table for leave schemes
  PERFORM f_t554d.                "Military Service Ranks Text
  PERFORM f_t5pbsr1bt.            "National Service Status Text
  PERFORM f_t5pbsr1dt.            "Text For Vocation
  PERFORM f_t517t.                "Educational Establishment Type Designations
  PERFORM f_t005t.                "Country Names
  PERFORM f_t519t.                "Final Certificates
  PERFORM f_t517x.                "Branches of Study
  PERFORM f_zhr_honor.            "Class of Honors
  PERFORM f_zhr_study.            "Mode of Study
*  PERFORM f_t7cn69.               "Project or Achievement Related Infomation
  PERFORM f_t522t.                "Title Salutation Text

*--> Begin SR-19799 by AC_Chopper : 1-time select & call FM's
  PERFORM f_get_struc TABLES gt-qklstab
                              gt-qktab2
                    USING     gc_language_spoken
                              'QK'
                              'B030'
                              pn-endda
                              pn-endda.
  PERFORM f_get_struc TABLES gt-qklwtab
                              gt-qktab2
                    USING     gc_language_written
                              'QK'
                              'B030'
                              pn-endda
                              pn-endda.


*For Language:
  SELECT * INTO TABLE gt-hrp1001qkb030q FROM  hrp1001
                                  WHERE otype = 'QK' "Qualification group
                                  AND   plvar EQ '01'
                                  AND   rsign = 'B'
                                  AND   relat = '030' "Is a specialization of
                                  AND   istat = '1' "Active
*            Assume BEGDA/ENDDA are LOW/HIGH
                                  AND   sclas = 'Q'. "Qualification
  SELECT * FROM hrp1000 INTO  TABLE gt-hrp1000q
      WHERE plvar EQ '01'
      AND   otype = 'Q'  "qualification
*               and objid = gv_objid
*            Assume BEGDA/ENDDA are LOW/HIGH
      AND   langu = sy-langu.
  SELECT
  pernr
  subty
  objps
  sprps
  endda
  begda
  seqnr
  usrid
    INTO TABLE gt-pa0105_ro
    FROM pa0105
    WHERE subty = gc_username.
*--> End SR-19799 by AC_Chopper
ENDFORM.                    " F_GET_TEXT
*&---------------------------------------------------------------------*
*&      Form  F_ZHR_OM_SUBGRADES
*&---------------------------------------------------------------------*
*       text: Get Substantive Grade Text
*----------------------------------------------------------------------*
FORM f_zhr_om_subgrades.

*  IF gt_emp_master_list IS NOT INITIAL.
  REFRESH gt_zhr_om_subgrades.
  SELECT zzbtrtl
         zzpersk
         zzendda
         zzsubcode
         zzbegda
         zzdescription
         FROM zhr_om_subgrades
         INTO TABLE gt_zhr_om_subgrades

* Changed by Lawrence on 14 July 09
*--------------------------------------------------------------------*
**           FOR ALL ENTRIES IN gt_emp_master_list
**           WHERE zzbtrtl   EQ gt_emp_master_list-btrtl
**           AND   zzpersk   EQ gt_emp_master_list-persk
**           AND   zzendda   GE gv_begda
*        WHERE zzendda   GE gv_begda
**           AND   zzsubcode EQ gt_emp_master_list-zzsubg
*         AND   zzbegda   LE gv_endda.
**  ENDIF.
      WHERE zzendda   >= pn-endda
        AND   zzbegda   <= pn-endda.
*--------------------------------------------------------------------*

ENDFORM.                    " F_ZHR_OM_SUBGRADES
*&---------------------------------------------------------------------*
*&      Form  F_T501T
*&---------------------------------------------------------------------*
*       text: Get EE Group Text
*----------------------------------------------------------------------*
FORM f_t501t.

*  IF gt_emp_master_list IS NOT INITIAL.
  REFRESH gt_t501t.
  SELECT sprsl
         persg
         ptext
         FROM t501t
         INTO TABLE gt_t501t
*           FOR ALL ENTRIES IN gt_emp_master_list
         WHERE sprsl EQ sy-langu.
*           AND   persg EQ gt_emp_master_list-persg.
*  ENDIF.

ENDFORM.                                                    " F_T501T
*&---------------------------------------------------------------------*
*&      Form  F_T503T
*&---------------------------------------------------------------------*
*       text: Get EE Sub Group Text
*----------------------------------------------------------------------*
FORM f_t503t.

*  IF gt_emp_master_list IS NOT INITIAL.
  REFRESH gt_t503t.
  SELECT sprsl
         persk
         ptext
         FROM t503t
         INTO TABLE gt_t503t
*           FOR ALL ENTRIES IN gt_emp_master_list
         WHERE sprsl EQ sy-langu.
*           AND   persk EQ gt_emp_master_list-persk.
*  ENDIF.

ENDFORM.                                                    " F_T503T
*&---------------------------------------------------------------------*
*&      Form  F_T500P
*&---------------------------------------------------------------------*
*       text: Get Personnel Area Text
*----------------------------------------------------------------------*
FORM f_t500p.

*  IF gt_emp_master_list IS NOT INITIAL.
  REFRESH gt_t500p.
  SELECT persa
         molga
         name1
         FROM t500p
         INTO TABLE gt_t500p.
*           FOR ALL ENTRIES IN gt_emp_master_list
*           WHERE persa EQ gt_emp_master_list-werks.
*  ENDIF.

ENDFORM.                                                    " F_T500P
**Added by A_ATIKAJA SSC CR1202 06/12/2012
*&---------------------------------------------------------------------*
*&      Form  F_T526
*&---------------------------------------------------------------------*
*       text: Get EE Sub Group Text
*----------------------------------------------------------------------*
FORM f_t526.

  REFRESH gt_t526.
* HANA Corrections - BEGIN OF MODIFY - <HANA-001>
*  SELECT werks
*         sachx
*         sachn
*         FROM t526
*         INTO TABLE gt_t526
*         WHERE werks EQ 'SSC'.
  SELECT werks
         sachx
         sachn
         FROM t526
         INTO TABLE gt_t526
         WHERE werks EQ 'SSC'
ORDER BY PRIMARY KEY.
* HANA Corrections - END OF MODIFY - <HANA-001>

ENDFORM.                                                    " F_T526
**Ended by A_ATIKAJA SSC CR1202 06/12/2012
*&---------------------------------------------------------------------*
*&      Form  F_T001P
*&---------------------------------------------------------------------*
*       text: Get Personnel Sub Area Text
*----------------------------------------------------------------------*
FORM f_t001p.

*  IF gt_emp_master_list IS NOT INITIAL.
  REFRESH gt_t001p.
  SELECT werks
         btrtl
         btext
         molga
         FROM t001p
         INTO TABLE gt_t001p.
*           FOR ALL ENTRIES IN gt_emp_master_list
*           WHERE werks EQ gt_emp_master_list-werks
*           AND   btrtl EQ gt_emp_master_list-btrtl.
*  ENDIF.

ENDFORM.                                                    " F_T001P
*&---------------------------------------------------------------------*
*&      Form  F_HRP1513
*&---------------------------------------------------------------------*
*       text: Get Job Index key
*----------------------------------------------------------------------*
FORM f_hrp1513.

  IF gt_emp_master_list IS NOT INITIAL.
    REFRESH gt_hrp1513.
    SELECT plvar
           otype
           objid
           subty
           istat
           begda
           endda
           mgrp
           sgrp
           adtkey
           FROM hrp1513
           INTO TABLE gt_hrp1513
           FOR ALL ENTRIES IN gt_emp_master_list
           WHERE otype EQ gc_s
           AND   objid EQ gt_emp_master_list-plans
           AND   subty EQ gc_9000
           AND   istat EQ 1
           AND   begda LE gv_endda
           AND   endda GE gv_begda
           AND   mgrp  EQ gv_c51
           AND   sgrp  EQ gv_c52.
    IF sy-subrc EQ 0.
      SORT gt_hrp1513 BY objid begda endda DESCENDING.
      DELETE ADJACENT DUPLICATES FROM gt_hrp1513 COMPARING objid.
    ENDIF.
  ENDIF.

ENDFORM.                                                    " F_HRP1513
*&---------------------------------------------------------------------*
*&      Form  F_T527X
*&---------------------------------------------------------------------*
*       text: Get Org Unit Text
*----------------------------------------------------------------------*
FORM f_t527x.

  REFRESH gt_t527x.
  SELECT sprsl
         orgeh
         endda
         begda
         orgtx
         FROM t527x
         INTO TABLE gt_t527x
         WHERE sprsl EQ sy-langu
* Changed by Lawrence on 14 July 09
*--------------------------------------------------------------------*
*         AND   endda GE gv_begda
*         AND   begda LE gv_endda.
     AND   endda >= pn-endda
         AND   begda <= pn-endda.
*--------------------------------------------------------------------*

ENDFORM.                                                    " F_T527X
*&---------------------------------------------------------------------*
*&      Form  F_T528T
*&---------------------------------------------------------------------*
*       text: Get Position Text
*----------------------------------------------------------------------*
FORM f_t528t.

  REFRESH gt_t528t.
  SELECT sprsl
         otype
         plans
         endda
         begda
         plstx
         FROM t528t
         INTO TABLE gt_t528t
         WHERE sprsl EQ sy-langu
         AND   otype EQ gc_s
* Changed by Lawrence on 2 July 09
*--------------------------------------------------------------------*
*         AND   endda GE gv_begda
*         AND   begda LE gv_endda.
        AND   endda >= pn-endda
        AND   begda <= pn-endda.
*--------------------------------------------------------------------*

ENDFORM.                                                    " F_T528T
*&---------------------------------------------------------------------*
*&      Form  F_HRP1001
*&---------------------------------------------------------------------*
*       text: Get Secondary Position & Reporting Officer
*----------------------------------------------------------------------*
FORM f_hrp1001_notcalled.
*--> Begin SR-19799 by AC_Chopper : commented out.  gt_emp_master_list is not built yet!
  IF gt_emp_master_list IS NOT INITIAL.
*** Secondary Position
    REFRESH gt_sec_pos_temp.
    SELECT otype
           objid
           begda
           endda
           infty
           subty
           sclas
           sobid
           prozt
           FROM hrp1001
           INTO TABLE gt_sec_pos_temp
           FOR ALL ENTRIES IN gt_emp_master_list
           WHERE otype EQ gc_p
           AND   objid EQ gt_emp_master_list-pernr
           AND   infty EQ gc_it1001
           AND   subty EQ gv_c49
           AND   begda LE gv_endda
           AND   endda GE gv_begda
           AND   sclas EQ gc_s.
    IF sy-subrc EQ 0.
      PERFORM f_delete_primary_pos.
      SORT gt_sec_pos BY objid begda endda sobid prozt DESCENDING.
      DELETE ADJACENT DUPLICATES FROM gt_sec_pos COMPARING objid sobid.

      PERFORM f_convertion_sp.
    ENDIF.


*** Reporting Officer
    REFRESH gt_rep_offcr_temp.
    SELECT otype
           objid
           begda
           endda
           infty
           subty
           sclas
           sobid
           prozt
           FROM hrp1001
           INTO TABLE gt_rep_offcr_temp
           FOR ALL ENTRIES IN gt_emp_master_list
           WHERE otype EQ gc_s
           AND   objid EQ gt_emp_master_list-plans
           AND   infty EQ gc_it1001
           AND   subty EQ gv_c50
           AND   begda LE gv_endda
           AND   endda GE gv_begda
           AND   sclas EQ gc_s.
    IF sy-subrc EQ 0.
      SORT gt_rep_offcr_temp BY objid begda endda sobid DESCENDING.
      DELETE ADJACENT DUPLICATES FROM gt_rep_offcr_temp COMPARING objid sobid.

      PERFORM f_convertion_ro.
      PERFORM f_get_ro_name.
    ENDIF.
  ENDIF.
*--> End SR-19799 by AC_Chopper :commented out.  gt_emp_master_list is not built yet!

ENDFORM.                                                    " F_HRP1001
*&---------------------------------------------------------------------*
*&      Form  F_T516T
*&---------------------------------------------------------------------*
*       text: Get Religious Denomination Texts
*----------------------------------------------------------------------*
FORM f_t516t.

*  IF gt_emp_master_list IS NOT INITIAL.
  REFRESH gt_t516t.
  SELECT sprsl
         konfe
         kitxt
         ktext
         FROM t516t
         INTO TABLE gt_t516t
*           FOR ALL ENTRIES IN gt_emp_master_list
         WHERE sprsl EQ sy-langu.
*           AND   konfe EQ gt_emp_master_list-konfe.
*  ENDIF.

ENDFORM.                                                    " F_T516T
*&---------------------------------------------------------------------*
*&      Form  F_T505S
*&---------------------------------------------------------------------*
*       text: Get Race Text
*----------------------------------------------------------------------*
FORM f_t505s.

*  IF gt_emp_master_list IS NOT INITIAL.
  REFRESH gt_t505s.
  SELECT sprsl
         molga
         racky
         ltext
         FROM t505s
         INTO TABLE gt_t505s
*           FOR ALL ENTRIES IN gt_emp_master_list
         WHERE sprsl EQ sy-langu
              AND molga = gc_sg.
*           AND   racky EQ gt_emp_master_list-racky.
*  ENDIF.

ENDFORM.                                                    " F_T505S
*&---------------------------------------------------------------------*
*&      Form  F_T502T
*&---------------------------------------------------------------------*
*       text: Get Marital Status Designators Text
*----------------------------------------------------------------------*
FORM f_t502t.

*  IF gt_emp_master_list IS NOT INITIAL.
  REFRESH gt_t502t.
  SELECT sprsl
         famst
         ftext
         FROM t502t
         INTO TABLE gt_t502t
*           FOR ALL ENTRIES IN gt_emp_master_list
         WHERE sprsl EQ sy-langu.
*           AND   famst EQ gt_emp_master_list-famst.
*  ENDIF.

ENDFORM.                                                    " F_T502T
*&---------------------------------------------------------------------*
*&      Form  F_CSKT
*&---------------------------------------------------------------------*
*       text: Get Cost Center Text
*----------------------------------------------------------------------*
FORM f_cskt.

*  IF gt_emp_master_list IS NOT INITIAL.
  REFRESH gt_cskt.
  SELECT spras
         kostl
         ktext
         FROM cskt
         INTO TABLE gt_cskt
*           FOR ALL ENTRIES IN gt_emp_master_list
         WHERE spras EQ sy-langu
*           AND   kokrs EQ gt_emp_master_list-kokrs
*           AND   kostl EQ gt_emp_master_list-kostl
         AND ( datbi GE gv_begda
         OR    datbi LE gv_endda ).
*  ENDIF.

ENDFORM.                    " F_CSKT
*&---------------------------------------------------------------------*
*&      Form  F_T5R06
*&---------------------------------------------------------------------*
*       text: Get Types of Identification - Texts
*----------------------------------------------------------------------*
FORM f_t5r06.

*  IF gt_emp_master_list IS NOT INITIAL.
  REFRESH gt_t5r06.
  SELECT sprsl
         molga
         ictyp
         ictxt
         FROM t5r06
         INTO TABLE gt_t5r06
*         FOR ALL ENTRIES IN gt_emp_master_list
         WHERE sprsl EQ sy-langu.
*           AND   ictyp EQ gt_emp_master_list-ictyp.
*  ENDIF.

ENDFORM.                                                    " F_T5R06
*&---------------------------------------------------------------------*
*&      Form  F_T547S
*&---------------------------------------------------------------------*
*       text: Get Contract Type Texts
*----------------------------------------------------------------------*
FORM f_t547s.

*  IF gt_emp_master_list IS NOT INITIAL.
  REFRESH gt_t547s.
  SELECT sprsl
         cttyp
         cttxt
         FROM t547s
         INTO TABLE gt_t547s
*         FOR ALL ENTRIES IN gt_emp_master_list
         WHERE sprsl EQ sy-langu.
*           AND   cttyp EQ gt_emp_master_list-cttyp.
*  ENDIF.

ENDFORM.                                                    " F_T547S
*&---------------------------------------------------------------------*
*&      Form  F_T517T
*&---------------------------------------------------------------------*
*       text: Get Educational Establishment Type Designations Text
*----------------------------------------------------------------------*
FORM f_t517t.

  REFRESH gt_t517t.
  SELECT sprsl
         slart
         stext
         FROM t517t
         INTO TABLE gt_t517t
         WHERE sprsl EQ sy-langu.

ENDFORM.                                                    " F_T517T
*&---------------------------------------------------------------------*
*&      Form  F_T005T
*&---------------------------------------------------------------------*
*       text: Get Country Names Text
*----------------------------------------------------------------------*
FORM f_t005t.

  REFRESH gt_t005t.
  SELECT spras
         land1
         landx
         natio
         natio50
         FROM t005t
         INTO TABLE gt_t005t
         WHERE spras EQ sy-langu.

ENDFORM.                                                    " F_T005T
*&---------------------------------------------------------------------*
*&      Form  F_T519T
*&---------------------------------------------------------------------*
*       text: Get Final Certificates Text
*----------------------------------------------------------------------*
FORM f_t519t.

*  IF gt_emp_master_list IS NOT INITIAL.
  REFRESH gt_t519t.
  SELECT sprsl
         slabs
         stext
         FROM t519t
         INTO TABLE gt_t519t
*         FOR ALL ENTRIES IN gt_emp_master_list
         WHERE sprsl EQ sy-langu.
*           AND   slabs EQ gt_emp_master_list-educ_lvl.
*  ENDIF.

ENDFORM.                                                    " F_T519T
*&---------------------------------------------------------------------*
*&      Form  F_T5UCA
*&---------------------------------------------------------------------*
*       text: Get Benefit & Medical Scheme Texts
*----------------------------------------------------------------------*
FORM f_t5uca.

  REFRESH gt_t5uca.
  SELECT langu
         bplan
         ltext
         FROM t5uca
         INTO TABLE gt_t5uca
         WHERE langu EQ sy-langu.

ENDFORM.                                                    " F_T5UCA
*&---------------------------------------------------------------------*
*&      Form  F_T5PBSR3AT
*&---------------------------------------------------------------------*
*       text: Get Text table for leave schemes
*----------------------------------------------------------------------*
FORM f_t5pbsr3at.

*  IF gt_emp_master_list IS NOT INITIAL.
  REFRESH gt_t5pbsr3at.
  SELECT sprsl
         schem
         stext
         FROM t5pbsr3at
         INTO TABLE gt_t5pbsr3at
*         FOR ALL ENTRIES IN gt_emp_master_list
         WHERE sprsl EQ sy-langu.
*           AND   schem EQ gt_emp_master_list-schem.
*  ENDIF.

ENDFORM.                    " F_T5PBSR3AT
*&---------------------------------------------------------------------*
*&      Form  F_T554D
*&---------------------------------------------------------------------*
*       text: Get Military Service Ranks Text
*----------------------------------------------------------------------*
FORM f_t554d.

*  IF gt_emp_master_list IS NOT INITIAL.
  REFRESH gt_t554d.
  SELECT sprsl
         wdgrd
         wdgtx
         FROM t554d
         INTO TABLE gt_t554d
*         FOR ALL ENTRIES IN gt_emp_master_list
         WHERE sprsl EQ sy-langu.
*           AND   wdgrd EQ gt_emp_master_list-wdgrd.
*  ENDIF.

ENDFORM.                                                    " F_T554D
*&---------------------------------------------------------------------*
*&      Form  F_T5PBSR1BT
*&---------------------------------------------------------------------*
*       text: Get National Service Status Text
*----------------------------------------------------------------------*
FORM f_t5pbsr1bt.

*  IF gt_emp_master_list IS NOT INITIAL.
  REFRESH gt_t5pbsr1bt.
  SELECT sprsl
         stats
         stdes
         FROM t5pbsr1bt
         INTO TABLE gt_t5pbsr1bt
*         FOR ALL ENTRIES IN gt_emp_master_list
         WHERE sprsl EQ sy-langu.
*           AND   stats EQ gt_emp_master_list-zzsta.
*  ENDIF.

ENDFORM.                    " F_T5PBSR1BT
*&---------------------------------------------------------------------*
*&      Form  F_T5PBSR1DT
*&---------------------------------------------------------------------*
*       text: Get Vocation Text
*----------------------------------------------------------------------*
FORM f_t5pbsr1dt.

*  IF gt_emp_master_list IS NOT INITIAL.
  REFRESH gt_t5pbsr1dt.
  SELECT sprsl
         nstyp
         vocac
         vodes
         FROM t5pbsr1dt
         INTO TABLE gt_t5pbsr1dt
*         FOR ALL ENTRIES IN gt_emp_master_list
         WHERE sprsl EQ sy-langu.
*           AND   vocac EQ gt_emp_master_list-zzvocation.
*  ENDIF.

ENDFORM.                    " F_T5PBSR1DT
*&---------------------------------------------------------------------*
*&      Form  F_T517X
*&---------------------------------------------------------------------*
*       text: Get Branch of Study Text
*----------------------------------------------------------------------*
FORM f_t517x.

  REFRESH gt_t517x.
  SELECT langu
         faart
         ftext
         FROM t517x
         INTO TABLE gt_t517x
         WHERE langu EQ sy-langu.

ENDFORM.                                                    " F_T517X
*&---------------------------------------------------------------------*
*&      Form  F_ZHR_HONOR
*&---------------------------------------------------------------------*
*       text: Get Class of Honors Text
*----------------------------------------------------------------------*
FORM f_zhr_honor.

  REFRESH gt_zhr_honor.
  SELECT endda
         zzhonor_code
         zzhonor
         begda
         FROM zhr_honor
         INTO TABLE gt_zhr_honor
         WHERE endda GE gv_begda AND
               begda LE gv_endda.

ENDFORM.                    " F_ZHR_HONOR
*&---------------------------------------------------------------------*
*&      Form  F_ZHR_STUDY
*&---------------------------------------------------------------------*
*       text: Get Mode of Study Text
*----------------------------------------------------------------------*
FORM f_zhr_study.

  REFRESH gt_zhr_study.
  SELECT endda
         begda
         zzstudy_code
         zzmode_study
         FROM zhr_study
         INTO TABLE gt_zhr_study
         WHERE endda GE gv_begda AND
               begda LE gv_endda.

ENDFORM.                    " F_ZHR_STUDY
*&---------------------------------------------------------------------*
*&      Form  F_T7CN69
*&---------------------------------------------------------------------*
*       text: Get Project or Achievement Related Infomation TExt
*----------------------------------------------------------------------*
*FORM f_t7cn69.
*
*  REFRESH gt_t7cn69.
*  SELECT achtp
*         achnm
*         begdt
*         enddt
*         prjna
*         FROM t7cn69
*         INTO TABLE gt_t7cn69.
*
*ENDFORM.                                                    " F_T7CN69
*&---------------------------------------------------------------------*
*&      Form  F_CONVERTION_RO
*&---------------------------------------------------------------------*
*       text: Convertion of Data Type
*----------------------------------------------------------------------*
FORM f_convertion_ro.

  REFRESH gt_rep_offcr.
  CLEAR gwa_rep_offcr_temp.
  LOOP AT gt_rep_offcr_temp INTO gwa_rep_offcr_temp.
    MOVE-CORRESPONDING gwa_rep_offcr_temp TO gwa_rep_offcr.

*** Convert Data Type
    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
      EXPORTING
        input  = gwa_rep_offcr_temp-sobid
      IMPORTING
        output = gwa_rep_offcr-sobid.

    APPEND gwa_rep_offcr TO gt_rep_offcr.
    CLEAR gwa_rep_offcr.
  ENDLOOP.

ENDFORM.                    " F_CONVERTION_RO
*&---------------------------------------------------------------------*
*&      Form  F_GET_RO_NAME
*&---------------------------------------------------------------------*
*       text: Get Reporting Officer Name
*----------------------------------------------------------------------*
FORM f_get_ro_name.
*--> Begin SR-19799 by AC_Chopper : Commented gt_ro_name becos never used
*  IF gt_rep_offcr IS NOT INITIAL.
*    REFRESH gt_ro_name.
*    SELECT plans
*           endda
*           begda
*           ename
*           FROM pa0001
*           INTO TABLE gt_ro_name
*           FOR ALL ENTRIES IN gt_rep_offcr
*           WHERE plans EQ gt_rep_offcr-sobid.
*    IF sy-subrc EQ 0.
*      SORT gt_ro_name BY plans begda endda DESCENDING.
*      DELETE ADJACENT DUPLICATES FROM gt_ro_name COMPARING plans.
*    ENDIF.
*  ENDIF.
*--> End SR-19799 by AC_Chopper : Commented gt_ro_name becos never used

ENDFORM.                    " F_GET_RO_NAME
*&---------------------------------------------------------------------*
*&      Form  F_CONVERTION_SP
*&---------------------------------------------------------------------*
*       text: Convertion of Data Type
*----------------------------------------------------------------------*
FORM f_convertion_sp.

  REFRESH gt_sec_pos.
  CLEAR gwa_sec_pos_temp.
  LOOP AT gt_sec_pos_temp INTO gwa_sec_pos_temp.
    MOVE-CORRESPONDING gwa_sec_pos_temp TO gwa_sec_pos.

*** Convert Data Type
    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
      EXPORTING
        input  = gwa_sec_pos_temp-sobid
      IMPORTING
        output = gwa_sec_pos-sobid.

    APPEND gwa_sec_pos TO gt_sec_pos.
    CLEAR gwa_sec_pos.
  ENDLOOP.

ENDFORM.                    " F_CONVERTION_SP
*&---------------------------------------------------------------------*
*&      Form  F_DELETE_PRIMARY_POS
*&---------------------------------------------------------------------*
*       text: Exclude the Primary Position
*----------------------------------------------------------------------*
FORM f_delete_primary_pos.

  CLEAR gwa_emp_master_list.
  LOOP AT gt_emp_master_list INTO gwa_emp_master_list.
    DELETE gt_sec_pos_temp WHERE objid EQ gwa_emp_master_list-pernr
                           AND   sobid EQ gwa_emp_master_list-plans.
  ENDLOOP.

ENDFORM.                    " F_DELETE_PRIMARY_POS
*&---------------------------------------------------------------------*
*&      Form  F_T522T
*&---------------------------------------------------------------------*
*       text: Get Title Salutation Text
*----------------------------------------------------------------------*
FORM f_t522t.

*  IF gt_emp_master_list IS NOT INITIAL.
  REFRESH gt_t522t.
  SELECT sprsl
         anred
         atext
         anrlt
         FROM t522t
         INTO TABLE gt_t522t
*         FOR ALL ENTRIES IN gt_emp_master_list
         WHERE sprsl EQ sy-langu.
*          AND   anred EQ gt_emp_master_list-anred.
*  ENDIF.

ENDFORM.                                                    " F_T522T
