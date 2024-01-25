
* Changes as per 20.10.2011,4 pm and user UNDER statement for InPeriod section
*----------------------------------------------------------------------*
* ACE Program                                                          *
* Copyright @ 2008 Accenture All Rights Reserved                       *
*----------------------------------------------------------------------*
* Program Name        : Z_RPPY_PAY_GLACC                               *
* Created By          : Chinna.S                                       *
* Created On          : 26-09-2011                                     *
* CR No.              : CR-PA-0000000739                               *
* Functional Design ID:                                                *
*----------------------------------------------------------------------*
* Functionality:                                                       *
*----------------------------------------------------------------------*
*Paysheet summary report- group by WT and GL ac -Tcode:ZRHR_PAYSHEET_GL*
* This prog is copy of existing PaySheet report-ZRHR_PAYSHEET,and      *
* grouped by WT and GL ac,it displays all the WTs maintained in confg  *
* table ZHRPY_PY_CFG,GL ac are fetching using standard report RPDKON00 *
*    ACE Subscription check : None at present
*----------------------------------------------------------------------*

* Remarks      :                                                       *
* Assumptions  :                                                       *
*----------------------------------------------------------------------*
* CHANGE HISTORY                                                       *
*   Change ID    :                                                     *
*   Date         :                                                     *
*   Changed By   :                                                     *
*   Transport No.:                                                     *
*   SIR/CR No.   :                                                     *
*   Description  :                                                     *
*----------------------------------------------------------------------*
REPORT z_rppy_pay_glacc  NO STANDARD PAGE HEADING
                     LINE-SIZE 250 "161
                     MESSAGE-ID z_mcpa_message.

INFOTYPES: 0000,                       " personal actions
           0001,                       " Org assignment
           0002,                       " Personal data
           0008,                                            "
           0009,                       " Bank detail
           0077,                       " Additional Personal data
           0186,
           0027.

************************************************************************
* Tables
************************************************************************
TABLES : pernr,                        " HR master data
         zvpa_subst_grade,           " View for substantive grade
         ztpa_code_post,             " Table for position type
         t505r,                      " Ethnic origin
         t505s,                      " Ethnic origin text
         t516t,                      " Religious Denomination text
         t527x,                      " organisational unit
         t501t,                      " Employee Group Names
         t500p,                      " personnel area
         t512t,                      " wage type text
         t5r0p,                      " plant section singapore
*          t510,
         t001p,                      " Personnel Sub area
         t591b,                      "Time Constraints for Wage Types
         pa0001,                     " HR master data, Infotype 0001
         pa0002,                     " Organisation assignment, 0002
         pa0008,                     " Basic Pay, infotype 0008
         pa0009,                     " Bank details, infotype 0009
         pa0186,                     " Social insurance
         pa0077,                     " Additional personal data
         hrrootob,                   " Root objects
         pc261,                      " Cluster directory
*           hrp9002,                    " DB table of infotype 9002   ACE 17 Feb 09
         hrp1001,                    " infotype 1001 db table
         hrp1000,
         pa0027.

DATA: BEGIN OF emp_details OCCURS 0,
        begda           LIKE pa0008-begda,
        orgeh           LIKE p0001-orgeh,
        org_desc        LIKE hrp1000-stext,   "t527x-orgtx,
        srno            TYPE i,
        perno           LIKE pernr-pernr,
        nric            LIKE p0002-perid,
        fname           LIKE p0002-nachn,
        lname           LIKE p0002-vorna,
        ename           LIKE p0001-ename,  "added this field
        m_sex           TYPE c,
        sex             LIKE  p0002-gesch,
*       subapp LIKE p0001-zzpa_sub_gr,                          "ACE 17 Feb 09
        subapp          LIKE p0001-zzsubg,                               "ACE 17 Feb 09
*       subappdesc LIKE zvpa_subst_grade-zzpa_abbr_desc,        "ACE 17 Feb 09
        subappdesc      LIKE zhr_om_subgrades-zzdescription,         "ACE 17 Feb 09
        bassal          LIKE p0001-kostl,
        position        LIKE p0001-plans,
*       posttyp LIKE hrp9002-zzpa_post_type,                      "ACE 17 Feb 09
        posttyp         LIKE p0001-stell,                                 "ACE 17 Feb 09
*       pos_desc LIKE ztpa_code_post-zzpa_abbr_desc,              "ACE 17 Feb 09
        pos_desc        LIKE hrp1000-short,                                "ACE 17 Feb 09
        race_type       LIKE  p0077-racky,
        race_desc       LIKE t505s-ltext,
        bankkey         LIKE p0009-bankl,
        baccno          LIKE p0009-bankn,
        divstatus       LIKE p0001-btrtl,
        divstatus_desc  LIKE t001p-btext,
        persarea        LIKE p0001-werks,
        emp_cpfno       LIKE t5r0p-epcpf,
        type_svc        LIKE pa0186-cpfna,
        tenure          LIKE pa0016-cttyp,
*        tenure_desc LIKE t547s-cttxt," ting ting commented 26.05.2009
        tenure_desc(25) TYPE c, "LIKE t501t-ptext,
        sal_code        LIKE p0008-trfgr,
        npc_count       TYPE  c,
        pay_scale       LIKE p0008-trfst,
        sal_point       TYPE t510-betrg,
*       nex_salbar LIKE p0008-zzpa_bar_level,             "ACE 17 Feb 09
        nex_salbar      LIKE p0008-zzebarsc1,                  "ACE 17 Feb 09
        inc_date        LIKE p0008-stvor,
        inc_date1(10),
        religion        LIKE p0002-konfe,
        religion_desc   LIKE t516t-ktext,
*        wage_type LIKE t512t-lgart,
*        wage_desc LIKE t512t-lgtxt,
        type_payroll    LIKE pc261a-ocrsn,  "modified 03/11/2000 by LTS
        sqcount         TYPE  i,
        ocrsn           LIKE pc261-ocrsn,          "modified 03/11/2000 by LTS
        rundt           LIKE pc261-rundt,
        subgrp          LIKE p0001-persk,
        pay_r_area      LIKE t549t-atext,     "modified 03/11/2000 by LTS
*      zzpa_per_grp LIKE p0001-zzpa_per_grp, " 07/11/2001 SR 01/0058     "ACE 17 Feb 09
        zzpa_per_grp    LIKE pa0001-persg, " 07/11/2001 SR 01/0058            "ACE 17 Feb 09
*      per_grp_desc LIKE ztpa_code_per_gp-zzpa_desc1,                   "ACE 17 Feb 09
        per_grp_desc    LIKE t503t-ptext,                                   "ACE 17 Feb 09 " Ting ting commented 22.05.2009
*   per_grp_desc LIKE t500p-name1,                                   "ACE 17 Feb 09
*  zzpa_per_subgrp LIKE pa0001-persk, " ting ting added 16.06.2009 CE00007776
      END OF emp_details.

* Internal table to store payroll data
DATA: BEGIN OF itab_payroll OCCURS 0.
    INCLUDE STRUCTURE zspa_payroll_result.
DATA: END OF itab_payroll.

DATA: itab_payroll_02 LIKE itab_payroll OCCURS 0 WITH HEADER LINE.

DATA: itab_payroll_tmp LIKE itab_payroll OCCURS 0 WITH HEADER LINE.

* Internal table to store wage types
DATA: BEGIN OF itab_wage OCCURS 0.
    INCLUDE STRUCTURE wrart_ran . " ting ting commented 27.05.2009
*  INCLUDE STRUCTURE ZRHR_PAYSHEET.
DATA: END OF itab_wage.

DATA: BEGIN OF itab_wagedec OCCURS 0.
    INCLUDE STRUCTURE wrart_ran . " ting ting commented 27.05.2009
*  INCLUDE STRUCTURE ZRHR_PAYSHEET.
DATA: END OF itab_wagedec.

* Internal table to store wage types
DATA: BEGIN OF itab_wage1 OCCURS 0.
    INCLUDE STRUCTURE wrart_ran . " ting ting commented 27.05.2009
*  INCLUDE STRUCTURE ZRHR_PAYSHEET.
DATA: END OF itab_wage1.

* internal table itab_total to store values

DATA: BEGIN OF itab_total OCCURS 0.
    INCLUDE STRUCTURE zspa_payroll_result.

DATA:  total_wage TYPE p DECIMALS 2.
DATA:  bas_ind TYPE c.
DATA: wage_desc TYPE t512t-lgtxt.
DATA: END OF itab_total.


DATA: BEGIN OF itab_totaltemp OCCURS 0.
    INCLUDE STRUCTURE zspa_payroll_result.

DATA:  total_wage TYPE p DECIMALS 2.
DATA:  bas_ind TYPE c.
DATA: wage_desc TYPE t512t-lgtxt.
DATA: END OF itab_totaltemp.


" Ting Ting added 11 August 2009
DATA: BEGIN OF itab_wagesel1 OCCURS 0.
    INCLUDE STRUCTURE wrart_ran . " ting ting commented 27.05.2009
*  INCLUDE STRUCTURE ZRHR_PAYSHEET.
DATA: END OF itab_wagesel1.

" Ting Ting added 11 August 2009
DATA: BEGIN OF itab_wagesel2 OCCURS 0.
    INCLUDE STRUCTURE wrart_ran . " ting ting commented 27.05.2009
*  INCLUDE STRUCTURE ZRHR_PAYSHEET.
DATA: END OF itab_wagesel2.


DATA: BEGIN OF itab_cost OCCURS 0.
    INCLUDE STRUCTURE wrart_ran . " ting ting commented 27.05.2009
*  INCLUDE STRUCTURE ZRHR_PAYSHEET.
DATA: END OF itab_cost.


* Internal table to store data from pa0001.
DATA: BEGIN OF itab_p1 OCCURS 0,
        perno        LIKE pa0001-pernr,
        ename        LIKE pa0001-ename,
        orgunit      LIKE pa0001-orgeh,
        begda        LIKE pa0001-begda,
*       subapp LIKE p0001-zzpa_sub_gr,                 "ACE 17 Feb 09
        subapp       LIKE p0001-zzsubg,
        bassal       LIKE p0001-kostl,
        divstatus    LIKE p0001-btrtl,
        persarea     LIKE p0001-werks,
        position     LIKE p0001-plans,
        job          LIKE p0001-stell,
        subgrp       LIKE p0001-persk,
*       zzpa_per_grp LIKE p0001-zzpa_per_grp, "07/11/2001 SR 01/0058    ACE 17 Feb 09
        zzpa_per_grp LIKE p0001-persk,    "07/11/2001 SR 01/0058    "ACE 17 Feb 09
      END OF itab_p1.

DATA: itab_p1tmp LIKE itab_p1.
DATA: run_date1 LIKE p0001-begda.     "kkl

* Internal table to store data from pa0002.
DATA: BEGIN OF itab_p2  OCCURS 0,
        perno    LIKE pa0002-pernr,
        nric     LIKE p0002-perid,
        begda    LIKE p0002-begda,
        fname    LIKE p0002-nachn,
        lname    LIKE p0002-vorna,
        sex      LIKE  p0002-gesch,
        religion LIKE p0002-konfe,
      END OF itab_p2.

* Internal table to store data from pa0008.
DATA: BEGIN OF itab_p8 OCCURS 0,
        perno      LIKE pa0008-pernr,
        sal_code   LIKE p0008-trfgr,
        begda      LIKE p0008-begda,
*       nex_salbar LIKE p0008-zzpa_bar_level,           "ACE 17 Feb 09
        nex_salbar LIKE p0008-zzebarsc1,                 "ACE 17 Feb 09
        inc_date   LIKE p0008-stvor,
        pay_scale  LIKE p0008-trfst,
      END OF itab_p8.

* Internal table to store data from pa0009.
DATA: BEGIN OF itab_p9 OCCURS 0,
        perno   LIKE pa0009-pernr,
        begda   LIKE pa0009-begda,
        bankkey LIKE p0009-bankl,
        baccno  LIKE p0009-bankn,
      END OF itab_p9.

* Internal table to store data from pa0077.
DATA: BEGIN OF itab_p77 OCCURS 0,
        perno     LIKE pa0077-pernr,
        begda     LIKE pa0077-begda,
        race_type LIKE  p0077-racky,
      END OF itab_p77.

* Internal table to store data from pa0186
DATA: BEGIN OF itab_p186 OCCURS 0,
        perno    LIKE pa0186-pernr,
        begda    LIKE pa0186-begda,
        fundname LIKE pa0186-cpfna,
      END OF itab_p186.

* Internal table to store data from pa0016
DATA: BEGIN OF itab_p16 OCCURS 0,
        perno LIKE pa0016-pernr,
        begda LIKE pa0016-begda,
        cont  LIKE pa0016-cttyp,
      END OF itab_p16.

* internal table for storing sequence count for each employee
DATA: BEGIN OF itab_seqcount OCCURS 0,
        perno   LIKE pernr-pernr,
        sqcount TYPE i,
      END OF itab_seqcount.

*Global Data declaration
DATA: l_subrc      LIKE sy-subrc,
      strin_period TYPE string,
      str_date     TYPE string,
      str_date2    TYPE string,
      str_date3    TYPE string,
      run_date     LIKE pc261-rundt,
      tmp_orgeh    LIKE t527x-orgtx,
      f            LIKE pa0001-orgeh,
      t_orgeh      LIKE hrrootob-objid,
      year         TYPE string,
      month        TYPE string,
      dis_date     TYPE string,
      period       TYPE  string,
      d_datum      LIKE pc261-inper,
      action       TYPE i,
      repid        LIKE sy-repid,
      rundt2       LIKE itab_payroll-rundt,
      rundt3       LIKE itab_payroll-rundt,
      rundt4       LIKE itab_payroll-rundt,
      rundtfinal   LIKE itab_payroll-rundt,
      in_per       LIKE pc261-inper,
      fp_per       LIKE pc261-inper.

*for header.
DATA: period_from(15),
      period_to(15),
      display_string(70),
      date_display(15),
      date2_display(15),
      payroll_area       LIKE t549t-atext,
      personnel_area     LIKE t500p-name1,
      org_unit           LIKE hrp1000-stext.

DATA: BEGIN OF itab_monthly OCCURS 0,
        pernr LIKE p0001-pernr,
      END OF itab_monthly.

DATA: domname  LIKE dcobjdef-name,
      domvalue LIKE dd07v-domvalue_l,
      idd07v   LIKE dd07v.

DATA: BEGIN OF itab_cpf OCCURS 0,
        pernr LIKE pernr-pernr,
        pscpf LIKE idd07v-ddtext,
      END OF itab_cpf.

DATA: BEGIN OF it591b OCCURS 0.
    INCLUDE STRUCTURE t591b.
DATA: END OF it591b.

DATA: monthly_sal    LIKE zspa_payroll_result-betrg,
      total_wage(15) TYPE c.

* internal table itab_subtotal1
DATA: BEGIN OF itab_subtotal1 OCCURS 0,
        wage   LIKE itab_total-lgart,                       "wage type
        desc   LIKE itab_total-wage_desc,
        sum    LIKE itab_total-total_wage,
        ind(1),
      END OF itab_subtotal1.

* internal table itab_subtotal2
DATA: BEGIN OF itab_subtotal2 OCCURS 0,
        wage   LIKE itab_total-lgart,                       "wage type
        desc   LIKE itab_total-wage_desc,
        sum    LIKE itab_total-total_wage,
        ind(1),
      END OF itab_subtotal2.

* internal table itab_subtotal3
DATA: BEGIN OF itab_subtotal3 OCCURS 0,
        wage   LIKE itab_total-lgart,                       "wage type
        desc   LIKE itab_total-wage_desc,
        sum    LIKE itab_total-total_wage,
        ind(1),
      END OF itab_subtotal3.

* internal table itab_subtotal4
DATA: BEGIN OF itab_subtotal4 OCCURS 0,
        wage   LIKE itab_total-lgart,                       "wage type
        desc   LIKE itab_total-wage_desc,
        sum    LIKE itab_total-total_wage,
        ind(1),
      END OF itab_subtotal4.

* internal table itab_subtotal5
DATA: BEGIN OF itab_subtotal5 OCCURS 0,
        wage   LIKE itab_total-lgart,                       "wage type
        desc   LIKE itab_total-wage_desc,
        sum    LIKE itab_total-total_wage,
        ind(1),
      END OF itab_subtotal5.

DATA: BEGIN OF itab_compare OCCURS 0,
        s1(20),
        s2(20),
        s3(20),
        s4(20),
        desc(20),
        amt      LIKE itab_total-total_wage,
        pernr    LIKE itab_total-pernr,
      END OF itab_compare.

DATA: BEGIN OF payroll_curr OCCURS 0,
        s1(20),
        s2(20),
        s3(20),
        s4(20),
        desc(20),
        amt      LIKE itab_total-total_wage,
        pernr    LIKE itab_total-pernr,
      END OF payroll_curr.

DATA: BEGIN OF payroll_prev OCCURS 0,
        s1(20),
        s2(20),
        s3(20),
        s4(20),
        desc(20),
        amt      LIKE itab_total-total_wage,
        pernr    LIKE itab_total-pernr,
      END OF payroll_prev.

*==>Start of addition, Bernard, 20 Oct 2009
DATA: BEGIN OF psg_pscpf OCCURS 0,
        pscpf   TYPE t5rcpf_sch-pscpf,
        pscpfst TYPE t5rcpf_scht-pscpfst,
      END OF psg_pscpf.
*<==End of addition, Bernard, 20 Oct 2009

*<==Start of addition, Reuben, 06/07/2010 AVA-128188 =======================>
DATA: temp_itab_total_2 LIKE itab_total OCCURS 0 WITH HEADER LINE,
      temp_itab_total_1 LIKE itab_total OCCURS 0 WITH HEADER LINE.
*<==End of addition, Reuben, 06/07/2010 AVA-128188 =======================>

* Data to store summary 1
DATA officer_bf1(9) VALUE 0.
DATA officer_bf_amt1 LIKE zspa_payroll_result-betrg.

DATA officer_paid_last1(9) VALUE 0.
DATA officer_paid_last_amt1 LIKE zspa_payroll_result-betrg.

DATA other_adjust_amt1 LIKE zspa_payroll_result-betrg.

DATA officer_paid_this1(9) VALUE 0.
DATA officer_paid_this_amt1 LIKE zspa_payroll_result-betrg.

DATA officer_cf1(9) VALUE 0.
DATA officer_cf_amt1 LIKE zspa_payroll_result-betrg.

* Data to store summary 2
DATA officer_bf2(9) VALUE 0.
DATA officer_bf_amt2 LIKE zspa_payroll_result-betrg.

DATA officer_paid_last2(9) VALUE 0.
DATA officer_paid_last_amt2 LIKE zspa_payroll_result-betrg.

DATA other_adjust_amt2 LIKE zspa_payroll_result-betrg.

DATA officer_paid_this2(9) VALUE 0.
DATA officer_paid_this_amt2 LIKE zspa_payroll_result-betrg.

DATA officer_cf2(9) VALUE 0.
DATA officer_cf_amt2 LIKE zspa_payroll_result-betrg.

* Data to store summary 3
DATA officer_bf3(9) VALUE 0.
DATA officer_bf_amt3 LIKE zspa_payroll_result-betrg.

DATA officer_paid_last3(9) VALUE 0.
DATA officer_paid_last_amt3 LIKE zspa_payroll_result-betrg.

DATA other_adjust_amt3 LIKE zspa_payroll_result-betrg.

DATA officer_paid_this3(9) VALUE 0.
DATA officer_paid_this_amt3 LIKE zspa_payroll_result-betrg.

DATA officer_cf3(9) VALUE 0.
DATA officer_cf_amt3 LIKE zspa_payroll_result-betrg.

* Data to store summary 4
DATA officer_bf4(9) VALUE 0.
DATA officer_bf_amt4 LIKE zspa_payroll_result-betrg.

DATA officer_paid_last4(9) VALUE 0.
DATA officer_paid_last_amt4 LIKE zspa_payroll_result-betrg.

DATA other_adjust_amt4 LIKE zspa_payroll_result-betrg.

DATA officer_paid_this4(9) VALUE 0.
DATA officer_paid_this_amt4 LIKE zspa_payroll_result-betrg.

DATA officer_cf4(9) VALUE 0.
DATA officer_cf_amt4 LIKE zspa_payroll_result-betrg.

DATA: payroll_last_day LIKE sy-datum.

** SR To show payment summary
DATA: total_net_payment LIKE zspa_payroll_result-betrg.
DATA: total_bank_transfer LIKE zspa_payroll_result-betrg.
DATA: total_cash_payment LIKE zspa_payroll_result-betrg.
DATA: total_negative_payment LIKE zspa_payroll_result-betrg.
DATA: num_net_payment(5) VALUE '0'.
DATA: num_zero_payment(5) VALUE '0'.
DATA: num_bank_transfer(5) VALUE '0'.
DATA: num_cash_payment(5) VALUE '0'.
DATA: num_negative_payment(5) VALUE '0'.
DATA: num_neg_sdf(5) VALUE '0'.
DATA: num_claim_prev(5) VALUE '0'.
DATA: num_neg_ee_cpf(5) VALUE '0'.
DATA: num_ee_inactive(5) VALUE '0'.
DATA: num_ee_balance_pay(5) VALUE '0'.
*{ Insert ncslts 29.11.2004
DATA: num_ee_short(5) VALUE '0'.
DATA: num_er_short(5) VALUE '0'.
*}
* Added by ytm on 04.10.2002 PAY-245
* this internal table stores employee who is inactive
* in current run.
DATA: BEGIN OF itab_ee_inactive OCCURS 0.
DATA:  pernr LIKE p0001-pernr.
DATA:  nric LIKE p0002-perid.
DATA:  ename LIKE p0001-ename.
DATA:  amount LIKE zspa_payroll_result-betrg.
DATA:  cost_center LIKE p0001-kostl.
DATA: END OF itab_ee_inactive.

DATA: BEGIN OF itab_ee_cash_payment OCCURS 0.
DATA:  pernr LIKE p0001-pernr.
DATA:  nric LIKE p0002-perid.
DATA:  ename LIKE p0001-ename.
DATA:  amount LIKE zspa_payroll_result-betrg.
DATA:  cost_center LIKE p0001-kostl.
DATA: END OF itab_ee_cash_payment.

DATA: BEGIN OF itab_ee_neg_payment OCCURS 0.
DATA:  pernr LIKE p0001-pernr.
DATA:  nric LIKE p0002-perid.
DATA:  ename LIKE p0001-ename.
DATA:  amount LIKE zspa_payroll_result-betrg.
DATA:  cost_center LIKE p0001-kostl.
DATA: END OF itab_ee_neg_payment.

* List of EE paid last month but not this month.
DATA: BEGIN OF itab_ee_paid_last_month OCCURS 0.
DATA:  pernr LIKE p0001-pernr.
DATA:  nric LIKE p0002-perid.
DATA:  ename LIKE p0001-ename.
DATA:  amount LIKE zspa_payroll_result-betrg.
DATA:  cost_center LIKE p0001-kostl.
DATA: END OF itab_ee_paid_last_month.

* List of EE paid this month but not last month.
DATA: BEGIN OF itab_ee_paid_this_month OCCURS 0.
DATA:  pernr LIKE p0001-pernr.
DATA:  nric LIKE p0002-perid.
DATA:  ename LIKE p0001-ename.
DATA:  amount LIKE zspa_payroll_result-betrg.
DATA:  cost_center LIKE p0001-kostl.
DATA: END OF itab_ee_paid_this_month.

* List of EE with negative SDF Contribution.
DATA: BEGIN OF itab_ee_neg_sdf OCCURS 0.
DATA:  pernr LIKE p0001-pernr.
DATA:  nric LIKE p0002-perid.
DATA:  ename LIKE p0001-ename.
DATA:  amount LIKE zspa_payroll_result-betrg.
DATA:  cost_center LIKE p0001-kostl.
DATA: END OF itab_ee_neg_sdf.

* List of EE with claim from prev month wage type.
DATA: BEGIN OF itab_ee_claim_prev OCCURS 0.
DATA:  pernr LIKE p0001-pernr.
DATA:  nric LIKE p0002-perid.
DATA:  ename LIKE p0001-ename.
DATA:  amount LIKE zspa_payroll_result-betrg.
DATA:  cost_center LIKE p0001-kostl.
DATA: END OF itab_ee_claim_prev.

* List of EE with negative EE CPF Contrib.
DATA: BEGIN OF itab_ee_neg_cpf OCCURS 0.
DATA:  pernr LIKE p0001-pernr.
DATA:  nric LIKE p0002-perid.
DATA:  ename LIKE p0001-ename.
DATA:  amount LIKE zspa_payroll_result-betrg.
DATA:  cost_center LIKE p0001-kostl.
DATA: END OF itab_ee_neg_cpf.

* List of EE with balance of payment.
DATA: BEGIN OF itab_ee_balance_pay OCCURS 0.
DATA:  pernr LIKE p0001-pernr.
DATA:  nric LIKE p0002-perid.
DATA:  ename LIKE p0001-ename.
DATA:  amount LIKE zspa_payroll_result-betrg.
DATA:  cost_center LIKE p0001-kostl.
DATA: END OF itab_ee_balance_pay.

*{ Insert ncslts 29.11.2004 AW CPF Ceiling
* List of EE with shortfall on EE Contribution.
DATA: BEGIN OF itab_ee_short OCCURS 0.
DATA:  pernr LIKE p0001-pernr.
DATA:  nric LIKE p0002-perid.
DATA:  ename LIKE p0001-ename.
DATA:  amount LIKE zspa_payroll_result-betrg.
DATA:  cost_center LIKE p0001-kostl.
DATA: END OF itab_ee_short.
* List of EE with shortfall on EY Contribution.
DATA: BEGIN OF itab_er_short OCCURS 0.
DATA:  pernr LIKE p0001-pernr.
DATA:  nric LIKE p0002-perid.
DATA:  ename LIKE p0001-ename.
DATA:  amount LIKE zspa_payroll_result-betrg.
DATA:  cost_center LIKE p0001-kostl.
DATA: END OF itab_er_short.
*}
* Added by ytm PAY-225
* enhancement, allows download to text file.

DATA: BEGIN OF fieldnames OCCURS 3,    "Display Header
        title(60),
        table(6),
        field(10),
      END OF fieldnames.

DATA: BEGIN OF data_tab OCCURS 10,       "Table Contents
        perno      LIKE pernr-pernr,
        nric       LIKE p0002-perid,
        ename      LIKE p0001-ename,
        bassal     LIKE p0001-kostl,
        orgeh      LIKE p0001-orgeh,
        lgart      LIKE t512t-lgart,
        wage_desc  LIKE t512t-lgtxt,
        total_wage LIKE itab_total-total_wage,
      END OF data_tab.

" Ting Ting added cost center 21.09.2009
DATA : gv_kstar TYPE pa0027-kstar.
DATA : gv_kpr01 TYPE pa0027-kpr01.
*<-- Start modification SR-PA-000?0011353 DE0K9A0XQP A_JACKY 22.06.2011  Zero Amount Officers’ summary added into report output-->
TYPES : BEGIN OF ty_zero_payment,
          pernr       LIKE p0001-pernr,
          nric        LIKE p0002-perid,
          ename       LIKE p0001-ename,
          amount      LIKE zspa_payroll_result-betrg,
          cost_center LIKE p0001-kostl,
        END OF ty_zero_payment.
DATA : itab_zero_payment TYPE STANDARD TABLE OF ty_zero_payment,
       gwa_zero_payment  TYPE ty_zero_payment.
*<-- End modification SR-PA-000?0011353 DE0K9A0XQP A_JACKY 22.06.2011  Zero Amount Officers’ summary added into report output-->
TYPES : BEGIN OF ty_ee_group, "CR-0000000739
          pernr TYPE pernr_d,
          persg TYPE persg, "Emp Grp
          abart TYPE abrar, "
          momag TYPE t52emt-momag, "EE Grouping for Account Determination
        END OF ty_ee_group.
TYPES : BEGIN OF ty_wt_gl_acc,
          lgart TYPE t512w-lgart, "Wage Type
          lgtxt TYPE lgtxt, "Wage Type Long Text
          symko TYPE t52ek-symko, "Symbolic Account
          momag TYPE t52em-momag, "EE Grouping for Account Determination
          acct  TYPE acct_det_bf-gl_account, "G/L Account Number
        END OF ty_wt_gl_acc.

TYPES : BEGIN OF ty_final_tab,
          lgart           TYPE t512w-lgart, "Wage Type
          lgtxt           TYPE lgtxt, "WT text
          acct            TYPE acct_det_bf-gl_account, "G/L Account Number
          total_wage      TYPE p DECIMALS 2, "Amount
          total_wage_pa   TYPE p DECIMALS 2, "Amount
          total_wage_tr   TYPE p DECIMALS 2, "Amount
          total_wage_cow  TYPE p DECIMALS 2, "Amount
          total_wage1     TYPE p DECIMALS 2, "Amount"for previous month
          total_wage_pa1  TYPE p DECIMALS 2, "Amount
          total_wage_tr1  TYPE p DECIMALS 2, "Amount
          total_wage_cow1 TYPE p DECIMALS 2, "Amount
*          persg TYPE persg,"Employee Group
        END OF ty_final_tab.
TYPES : BEGIN OF ty_final_tab1,
          lgart           TYPE t512w-lgart, "Wage Type
          persg           TYPE persg, "Employee Group
          pernr           TYPE pernr_d,
          lgtxt           TYPE lgtxt, "WT text
          acct            TYPE acct_det_bf-gl_account, "G/L Account Number
*            total_wage TYPE p DECIMALS 2,"Amount
          total_wage_tr   TYPE p DECIMALS 2, "Amount
          total_wage_cow  TYPE p DECIMALS 2, "Amount
          total_wage_pa   TYPE p DECIMALS 2, "Amount
          total_wage_tr1  TYPE p DECIMALS 2, "Amount"for previous month
          total_wage_cow1 TYPE p DECIMALS 2, "Amount
          total_wage_pa1  TYPE p DECIMALS 2, "Amount
        END OF ty_final_tab1.
TYPES : BEGIN OF ty_sec_details,
          main    TYPE zhrpy_py_cfg-main,
          sec     TYPE zhrpy_py_cfg-sec,
          sub_sec TYPE zhrpy_py_cfg-sub_sec,
        END OF ty_sec_details.
TYPES : BEGIN OF ty_final_sub_tot,
          sub_total       TYPE string,
          total_wage_pa   TYPE p DECIMALS 2,
          total_wage_tr   TYPE p DECIMALS 2,
          total_wage_cow  TYPE p DECIMALS 2,
          total_wage      TYPE p DECIMALS 2,
          total_wage_pa1  TYPE p DECIMALS 2, "for previous month
          total_wage_tr1  TYPE p DECIMALS 2,
          total_wage_cow1 TYPE p DECIMALS 2,
          total_wage1     TYPE p DECIMALS 2,
        END OF ty_final_sub_tot.
TYPES : BEGIN OF ty_final_count,
          pymnt_ibg_pa   TYPE sy-tabix,
          pymnt_ibg_tr   TYPE sy-tabix,
          pymnt_ibg_cow  TYPE sy-tabix,
          tot_ibg        TYPE sy-tabix,
          pymnt_ibg_pa1  TYPE sy-tabix,
          pymnt_ibg_tr1  TYPE sy-tabix,
          pymnt_ibg_cow1 TYPE sy-tabix,
          tot_ibg1       TYPE sy-tabix,
          pymnt_chq_pa   TYPE sy-tabix,
          pymnt_chq_tr   TYPE sy-tabix,
          pymnt_chq_cow  TYPE sy-tabix,
          tot_chq        TYPE sy-tabix,
          pymnt_chq_pa1  TYPE sy-tabix,
          pymnt_chq_tr1  TYPE sy-tabix,
          pymnt_chq_cow1 TYPE sy-tabix,
          tot_chq1       TYPE sy-tabix,
          tot_pa         TYPE sy-tabix,
          tot_pa1        TYPE sy-tabix,
          tot_count      TYPE sy-tabix,
          tot_count1     TYPE sy-tabix,
        END OF ty_final_count.
DATA : it_ee_group      TYPE STANDARD TABLE OF ty_ee_group,
       gwa_ee_group     TYPE ty_ee_group,
       it_wt_gl_acc     TYPE STANDARD TABLE OF ty_wt_gl_acc,
       it_final_tab     TYPE STANDARD TABLE OF ty_final_tab,
       gwa_final_tab    TYPE ty_final_tab,
       it_py_cfg        TYPE TABLE OF zhrpy_py_cfg, "Paysheet Config table
       lv_abart         TYPE abrar,
       it_sec_details   TYPE STANDARD TABLE OF ty_sec_details,
       lwa_sec_details  TYPE ty_sec_details,
       it_final_sub_tot TYPE  STANDARD TABLE OF ty_final_sub_tot,
*       it_final_tab1    TYPE STANDARD TABLE OF ty_final_tab1,
       itab_payroll_03  LIKE itab_payroll OCCURS 0 WITH HEADER LINE.
DATA: BEGIN OF itab_final_total OCCURS 0,
        lgart      LIKE zspa_payroll_result-lgart,
        total_wage TYPE p DECIMALS 2,
        wage_desc  TYPE t512t-lgtxt,
        pernr      TYPE pernr-pernr,
      END OF itab_final_total.
DATA: BEGIN OF itab_final_total1 OCCURS 0,
        lgart      LIKE zspa_payroll_result-lgart,
        total_wage TYPE p DECIMALS 2,
        wage_desc  TYPE t512t-lgtxt,
        pernr      TYPE pernr-pernr,
      END OF itab_final_total1.

CONSTANTS : gc_25       TYPE molga VALUE '25',
            gc_ee_grp_p TYPE persg VALUE 'P', "Trainer
            gc_ee_grp_q TYPE persg VALUE 'Q'. "Clerk of Works

CONSTANTS: gc_wt_lsa_cpf_er TYPE t512t-lgart VALUE '3ZW1'.
*&---------------------------------------------------------------------*
*&      SELECTION CRITERIA
*&---------------------------------------------------------------------*
SELECTION-SCREEN BEGIN OF BLOCK frm1 WITH FRAME TITLE TEXT-022.
SELECT-OPTIONS: org_str FOR pa0001-pernr NO-DISPLAY.
SELECTION-SCREEN END OF BLOCK frm1.

*SELECTION-SCREEN BEGIN OF BLOCK cost WITH FRAME TITLE text-999.
*SELECT-OPTIONS: s_cost FOR pa0001-kostl NO INTERVALS.
*SELECTION-SCREEN END OF BLOCK cost.

* ---------------------------------------------------------------------*
*                      At Selection Screen Validation                  *
* ---------------------------------------------------------------------*
SELECT * FROM t591b APPENDING TABLE it591b WHERE molga = '25'.
SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE TEXT-056.
SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN COMMENT 1(7) TEXT-057 FOR FIELD fp_per_m.
PARAMETERS : fp_per_m TYPE pnppabrp,
             fp_per_y TYPE pnppabrj.
SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN END OF BLOCK b1.
* general parameters
SELECTION-SCREEN BEGIN OF BLOCK calc_param1
                 WITH FRAME TITLE TEXT-028.

* option to disable comparing last month payroll result.
SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN POSITION 40.
PARAMETERS: compare LIKE rpcalcx0-prt_prot.
SELECTION-SCREEN COMMENT 43(36) TEXT-038 FOR FIELD compare
        MODIF ID spe.
SELECTION-SCREEN END OF LINE.

SELECTION-SCREEN BEGIN OF LINE.

PARAMETERS: prt_prot LIKE rpcalcx0-prt_prot." offcycle indicator chk box
SELECTION-SCREEN COMMENT 3(35) TEXT-036 FOR FIELD prt_prot MODIF ID spe.
"Incl. Regular Payroll Results

SELECTION-SCREEN POSITION 40.
PARAMETERS: prt_pr LIKE rpcalcx0-prt_prot.
SELECTION-SCREEN COMMENT 43(35) TEXT-037 FOR FIELD prt_pr
          MODIF ID spe.
SELECTION-SCREEN END OF LINE.

SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN COMMENT 1(15) TEXT-026 FOR FIELD payty
                               MODIF ID spe.

* SELECTION-SCREEN POSITION pos_low.
PARAMETERS:
  payty LIKE pc261-payty MODIF ID spe,                    "pay type
  payid LIKE pc261-payid MODIF ID spe,            "pay identification
  bondt LIKE pc261-bondt MODIF ID spe.                    "bonus date

SELECTION-SCREEN COMMENT 40(16) TEXT-034 FOR FIELD pr_ty
                               MODIF ID spe.
PARAMETERS:
  pr_ty LIKE pc261-payty MODIF ID spe,
  pr_id LIKE pc261-payid MODIF ID spe,
  pr_dt LIKE pc261-bondt MODIF ID spe.

SELECTION-SCREEN END OF LINE.

SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN COMMENT 1(15) TEXT-027 FOR FIELD payty
                               MODIF ID spe.
*SELECTION-SCREEN POSITION pos_low.
PARAMETERS:
  payty_1 LIKE pc261-payty MODIF ID spe,                  "pay type
  payid_1 LIKE pc261-payid MODIF ID spe,           "pay identification
  bondt_1 LIKE pc261-bondt MODIF ID spe.                  "bonus date

SELECTION-SCREEN COMMENT 40(16) TEXT-035 FOR FIELD pr_ty1
                               MODIF ID spe.
PARAMETERS:
  pr_ty1 LIKE pc261-payty MODIF ID spe,
  pr_id1 LIKE pc261-payid MODIF ID spe,
  pr_dt1 LIKE pc261-bondt MODIF ID spe.

SELECTION-SCREEN END OF LINE.


SELECTION-SCREEN END OF BLOCK calc_param1.

INCLUDE z_hana_demo_prg_inc.
*INCLUDE z_rppy_pay_glacc_include.
*INCLUDE z_rppy_pay_04_include.

DATA: itab_temp LIKE itab_output.

***********************************************************************
*** Main Program
***********************************************************************

********************
INITIALIZATION.
********************
  PERFORM agency_sub_check."check for Agency subscription

  DATA : gt_t512          TYPE TABLE OF t512t.              " T511
  DATA : gwa_t512         TYPE t512t.                       " T511
  " Total Allowance
  CLEAR gt_t512[].
  SELECT * FROM t512t
  INTO CORRESPONDING FIELDS OF TABLE gt_t512
  WHERE ( molga = '25' OR molga = '14').
  IF sy-subrc <> 0.
    CLEAR gt_t512[] .
  ENDIF.

*==>Start of addition, Bernard, 20 Oct 2009
  CLEAR psg_pscpf. REFRESH psg_pscpf.
  SELECT t5rcpf_sch~pscpf pscpfst FROM t5rcpf_sch INNER JOIN t5rcpf_scht
                  ON  t5rcpf_sch~molga = t5rcpf_scht~molga
                  AND t5rcpf_sch~pscpf = t5rcpf_scht~pscpf
                  INTO TABLE psg_pscpf
                  WHERE t5rcpf_sch~molga = '25'
                    AND sprsl = sy-langu.
*<==End of addition, Bernard, 20 Oct 2009

********************
AT LINE-SELECTION.
********************

  PERFORM call_basic_display.

********************
AT SELECTION-SCREEN.
********************

* check if the first offcycle box empty and other filled
  IF  ( payty       IS INITIAL
  OR    bondt       IS INITIAL )
  AND ( NOT payty_1 IS INITIAL
  OR    NOT bondt_1 IS INITIAL ).
    MESSAGE e104.
  ENDIF.

  IF  ( payty = payty_1                               "Ins by MT 19/1/01
  AND   payid = payid_1                               "Ins by MT 19/1/01
  AND   bondt = bondt_1                               "Ins by MT 19/1/01
  AND   payty NE ' '                                  "Ins by MT 19/1/01
  AND   bondt NE ' ' ).                               "Ins by MT 19/1/01
    MESSAGE e107.                                     "Ins by MT 19/1/01
  ENDIF.                                              "Ins by MT 19/1/01

* if other payroll period  entered
  IF pnptimra = 'X'.
    CONCATENATE pnppabrj pnppabrp INTO period.
    WRITE period TO in_per.
  ELSE.
    CONCATENATE pnpdispj pnpdispp INTO period.
    WRITE period TO in_per.
  ENDIF.


********************
START-OF-SELECTION.
********************
* To run the previous month payroll
*  IF in_per+4(2) <> '01'.
*    fp_per = in_per - 1.
*  ELSE.
*    fp_per(4)   = in_per(4) - 1.
*    fp_per+4(2) = '12'.
*  ENDIF.
  CONCATENATE fp_per_y fp_per_m INTO fp_per.

  GET pernr.

  rp_provide_from_last p0001 space pn-begda pn-endda.
  rp_provide_from_last p0027 space pn-begda pn-endda.

  "--Start CE00007327 added 08.06.2009
*  SORT p0001 BY endda DESCENDING begda DESCENDING.

  IF (       p0001-zzol1 IN pnporgeh
          OR p0001-zzol2 IN pnporgeh
          OR p0001-zzol3 IN pnporgeh
          OR p0001-zzol4 IN pnporgeh
          OR p0001-zzol5 IN pnporgeh
          OR p0001-zzol6 IN pnporgeh )
          AND p0001-werks IN pnpwerks
          AND p0001-btrtl IN pnpbtrtl
    " ting ting commented
*          AND (
*    p0001-kostl IN pnpkostl
*    OR  p0027-kst01 IN pnpkostl )
          AND p0001-begda <= pnpdised AND p0001-endda >= pnpdisbd.


    IF ( p0001-kostl IN s_cost[]
OR  p0027-kst01 IN s_cost[] ).
    ELSE.
      REJECT.
    ENDIF.

  ELSE.
    REJECT.
  ENDIF.

*  LOOP AT p0001
*  WHERE ( zzol1 IN pnporgeh
*          OR zzol2 IN pnporgeh
*          OR zzol3 IN pnporgeh
*          OR zzol4 IN pnporgeh
*          OR zzol5 IN pnporgeh
*          OR zzol6 IN pnporgeh )
*          AND werks IN pnpwerks
*          AND btrtl IN pnpbtrtl
*          AND kostl IN pnpkostl
*          AND begda <= pnpdised AND endda >= pnpdisbd.
*    EXIT.
*  ENDLOOP .
*  IF sy-subrc <> 0.
*    REJECT.
*  ENDIF.
  "--End CE00007327 added 08.06.2009

* append personnel, payroll_area, in period to
* itab_payroll internal table.
  itab_payroll_02-pernr = pernr-pernr.

  " Ting ting added 15.06.2009 CE00007680
  SORT p0001 BY endda DESCENDING begda DESCENDING.

  LOOP AT p0001 WHERE begda <= pnpdised AND endda >= pnpdisbd AND abkrs IN pnpabkrs AND abkrs = pnpxabkr .
    itab_payroll_02-iabkrs = p0001-abkrs.
    EXIT.
  ENDLOOP.

*"CR-0000000739
  CLEAR lv_abart.
  SELECT SINGLE abart
           INTO lv_abart
           FROM t503
          WHERE persg EQ p0001-persg AND
                persk EQ p0001-persk.
  IF sy-subrc EQ 0.
    MOVE lv_abart TO gwa_ee_group-abart.
  ENDIF.
  MOVE: pernr-pernr TO gwa_ee_group-pernr,
        p0001-persg TO gwa_ee_group-persg.
  APPEND gwa_ee_group TO it_ee_group.
  CLEAR gwa_ee_group.
  MOVE-CORRESPONDING itab_payroll_02 TO itab_payroll_03."CR-0000000739

  itab_payroll_03-inper = fp_per.
  APPEND itab_payroll_03.
  CLEAR itab_payroll_03.

*  itab_payroll_02-iabkrs = p0001-abkrs.
  itab_payroll_02-inper = in_per.
  APPEND itab_payroll_02.
  CLEAR itab_payroll_02.

  run_date = sy-datum.

  rp_provide_from_last p0186 space pn-begda pn-endda.

  domname  = 'PSG_PSCPF'.
  domvalue = p0186-pscpf.
*==>Start of modification, Bernard, 29 Oct 2009
  "Table DD07T after HR support pack no longer store domain PSG_PSCPF
  "Now its using table T5RCPF_sch
*  CALL FUNCTION 'DDUT_DOMVALUE_TEXT_GET'
*    EXPORTING
*      name     = domname
*      value    = domvalue
*      langu    = sy-langu
*    IMPORTING
*      dd07v_wa = idd07v.
  READ TABLE psg_pscpf WITH KEY pscpf = p0186-pscpf.
*<==End of modification, Bernard, 29 Oct 2009

* now, get out pscpf.
  itab_cpf-pernr = pernr-pernr.
*  itab_cpf-pscpf = idd07v-ddtext. "Modified, Bernard, 29 Oct 09
  itab_cpf-pscpf = psg_pscpf-pscpfst.
  APPEND itab_cpf.
  CLEAR itab_cpf.

  IF  p0001-abkrs = '01' "payroll area
* AND p0186-cpfid = '01'            "kkl SR 00/0140
  AND p0186-pscpf = '2'  "Indicator for public sector CPF
                         "contribution - Non-pensionable contribution
  AND p0001-persg NE '1'.           "kkl SR 00/0140
    "Employee group - Perm-CPW
    itab_monthly-pernr = pernr-pernr.
    APPEND itab_monthly.
    CLEAR itab_monthly.
  ENDIF.

************************
TOP-OF-PAGE.
************************
* date operation
  PERFORM convert_date.

* for date range
  WRITE pn-begda DD/MM/YYYY TO period_from.
  WRITE pn-endda DD/MM/YYYY TO period_to.
  WRITE bondt    DD/MM/YYYY TO date_display.
  WRITE bondt_1  DD/MM/YYYY TO date2_display.

  IF NOT  payty_1 IS INITIAL
  AND NOT payty   IS INITIAL.
    CONCATENATE '[' payty '/' payid '/' date_display '&' payty_1 '/'
                payid_1 '/' date2_display ']'
           INTO display_string SEPARATED BY space.
  ELSEIF NOT payty IS INITIAL.
    CONCATENATE '[' payty '/' payid '/' date_display ']'
           INTO display_string  SEPARATED  BY space.
  ENDIF.

* AUCT-UPGRADE -  Begin of Modification by <USER> on <17.02.2017> for <EHP8>
*  SELECT SINGLE stext INTO  hrp1000-stext FROM hrp1000
*                      WHERE otype EQ 'O'
*                        AND plvar EQ '01'
*                        AND langu EQ 'E'
*                        AND objid EQ org_unit. "p0001-orgeh
  SELECT stext INTO hrp1000-stext FROM hrp1000
                        WHERE otype EQ 'O'
                          AND plvar EQ '01'
                          AND langu EQ 'E'
                          AND objid EQ org_unit "p0001-orgeh
  ORDER BY PRIMARY KEY.
    EXIT.
  ENDSELECT.
* AUCT-UPGRADE -  End of Modification by <USER> on <17.02.2017> for <EHP8>

  repid = sy-repid.

*  PERFORM display_header USING repid "CR-0000000739 - Commented
*                               sy-title
*                               period_from
*                               period_to
*                               161
*                               space
*                               payroll_area
*                               personnel_area
*                               org_unit "hrp1000-stext
*                         CHANGING sy-title sy-title sy-title.

**  FORMAT INTENSIFIED ON."CR-0000000739 - Commented
*  FORMAT COLOR COL_NORMAL ON.
**  FORMAT COLOR 13 ON.
*
*  WRITE AT 140(6) 'Page: '.
*
*  WRITE AT 146(5) sy-pagno LEFT-JUSTIFIED.
*  FORMAT COLOR OFF.
**  FORMAT INTENSIFIED OFF.

**********************
END-OF-SELECTION.
**********************
  DATA : gt_t511         TYPE TABLE OF t511.                 " CSKT
  DATA : gwa_t511        TYPE t511.                          " CSKT

  DATA : gt_t512t        TYPE TABLE OF t512t.         " Wage type
  DATA : gwa_t512t       TYPE t512t.                  " Wage type

*  DATA : gt_t52ez        TYPE TABLE OF t52ez.         " Wage type
*  DATA : gwa_t52ez       TYPE t52ez.                  " Wage type

  " Ting ting added 11 August 2009
  DATA : gt_t512w        TYPE TABLE OF t512w.         " Wage type
  DATA : gwa_t512w       TYPE t512w.                  " Wage type

  DATA : gt_t512w_1        TYPE TABLE OF t512w.         " Wage type
  DATA : gwa_t512w_1       TYPE t512w.                  " Wage type

  DATA: BEGIN OF gt_deductionex OCCURS 0.
      INCLUDE STRUCTURE wrart_ran . " ting ting commented 27.05.2009
*  INCLUDE STRUCTURE ZRHR_PAYSHEET.
  DATA: END OF gt_deductionex .

  DATA: BEGIN OF gt_allowanceex OCCURS 0.
      INCLUDE STRUCTURE wrart_ran . " ting ting commented 27.05.2009
*  INCLUDE STRUCTURE ZRHR_PAYSHEET.
  DATA: END OF gt_allowanceex .


  DATA: BEGIN OF gt_allowance OCCURS 0.
      INCLUDE STRUCTURE wrart_ran . " ting ting commented 27.05.2009
*  INCLUDE STRUCTURE ZRHR_PAYSHEET.
  DATA: END OF gt_allowance .
*
*  DATA : gt_allowance     TYPE TABLE OF t512t.        " Wage type no '/'
*  DATA : gwa_allowance    TYPE t512t.                          " Wage type no '/'


  CLEAR gt_t511[].
  SELECT * FROM t511 INTO CORRESPONDING FIELDS OF TABLE gt_t511 WHERE molga = '25'.
  SORT gt_t511 BY endda DESCENDING  begda DESCENDING.

  CLEAR gt_t512t[].
  SELECT * FROM t512t INTO CORRESPONDING FIELDS OF TABLE gt_t512t
  WHERE sprsl = sy-langu AND ( molga = '25' OR molga = '14' )
.

  CLEAR gt_t512w[].
  SELECT * FROM t512w INTO CORRESPONDING FIELDS OF TABLE gt_t512w
  WHERE ( molga = '25' OR molga = '14' )
  AND aklas LIKE '__9%'.


* org_str: select options, moving all wage types to itab_wage.


  PERFORM populate_tables.             " populate table


* check if regu cycle chbox is not checked and no value in payty and
* bondt field
* Normal payroll only
  IF  prt_prot IS INITIAL
  AND payty    IS INITIAL
  AND payty_1  IS INITIAL
  AND bondt    IS INITIAL
  AND bondt_1  IS INITIAL.
    action  = 1.

* check if regu cycle chbox is not check but values in payty and bondt
* Off-Cycle Payroll only
  ELSEIF
             prt_prot IS INITIAL.
    IF NOT ( payty    IS INITIAL
    AND      bondt    IS INITIAL )
    OR NOT ( payty_1  IS INITIAL
    AND      bondt_1  IS INITIAL ) .
      action  = 2.
    ENDIF.

* check if regu cycle chbox is checked and values in payty and bondt
* Normal & Off-Cycle Payroll together
  ELSEIF
       NOT   prt_prot IS INITIAL.
    IF NOT ( payty    IS INITIAL
    AND      bondt    IS INITIAL )
    OR NOT ( payty_1  IS INITIAL
    AND      bondt_1  IS INITIAL )  .
      action  = 3.
    ENDIF.
  ENDIF.
  CASE action.
    WHEN '1'.
      APPEND LINES OF itab_payroll_03 TO itab_payroll_02."CR-0000000739

* call payroll function here, get distinct wage types
* from output itab_payroll into itab_total.
      PERFORM get_payroll.                 " get payroll result
    WHEN '2'.
* call payroll function here, and get wage types
      PERFORM get_offcycle_payroll.        " get offcycle payroll result
    WHEN '3'.
      APPEND LINES OF itab_payroll_03 TO itab_payroll_02."CR-0000000739

* call both functions
      PERFORM get_payroll.                 " get payroll result
      DELETE itab_payroll_02 WHERE inper EQ fp_per.
      PERFORM get_offcycle_payroll.
  ENDCASE.
*"CR-0000000739
  PERFORM get_feature_ppmod.
  PERFORM get_wt_gl_acc.

*****************************************************************************************

  IF rundt4 > rundt2.
    rundtfinal = rundt4.
  ELSE.
    rundtfinal = rundt2.
  ENDIF.

*modified by ncsup on 19 april 01
*check whether rundtfinal between pn-begda and pn-endda.
  IF NOT ( rundtfinal >= pn-begda AND
           rundtfinal <= pn-endda ).
    rundtfinal = pn-endda.
  ENDIF.

* move indicator 'A' to itab_total if wage type is 9s01.
* else, move indicator 'B' to itab_total.
  PERFORM bas_ind.

* added by ytm on 03.10.02 PAY-245
* /563 claim from prev month has to be manually calculated
  PERFORM get_claim_prev_wage_amt.

* get wage type descriptions.
*  PERFORM wage_desc.                   " select desc. for wage types *"CR-0000000739


* get info from Infotypes 1,2,8,9,77,16,186.
  PERFORM select_empdetails.           " select employees details


* get cpf no based on personnel area and div status.
*  PERFORM emp_cpf.*"CR-0000000739

* get code descriptions.
  PERFORM get_post_type.
  PERFORM get_subsapp.              " select description for sub.appont.
*  PERFORM get_racedesc.                " select race description*"CR-0000000739
*  PERFORM get_divstatdesc.             " select division status*"CR-0000000739
*  PERFORM get_religiondesc.            " select religion description*"CR-0000000739
*  PERFORM get_orgunitdesc."CR-0000000739
*  PERFORM pos_desc."CR-0000000739
*  PERFORM tenure_desc."CR-0000000739
  PERFORM get_salpoint.                " determine salary point
  PERFORM write_details.               " write paysheet

************************************************************************
**Form convert_date.This routine gets the date in format req for display
***********************************************************************
FORM convert_date.

  DATA: tmpdate    TYPE string,
        tmpdate2   TYPE string,
        funcdate   TYPE sy-datum,
        tmpdate3   TYPE string,
        finaldate  TYPE d,
        finaldate1 TYPE string,
        str_date4  TYPE string,
        tmpdate4   TYPE string.

  tmpdate = in_per.
  CONCATENATE tmpdate '01' INTO tmpdate2.
  funcdate = tmpdate2.

  CALL FUNCTION 'RP_LAST_DAY_OF_MONTHS'
    EXPORTING
      day_in            = funcdate
    IMPORTING
      last_day_of_month = finaldate.
  tmpdate3 = in_per.
  finaldate1 = finaldate+6(2).

  CONCATENATE  tmpdate3 finaldate1 INTO tmpdate4.

  CALL FUNCTION 'CONVERSION_EXIT_IDATE_OUTPUT'
    EXPORTING
      input  = tmpdate4
    IMPORTING
      output = strin_period.

  str_date = strin_period+2(3).
  str_date2 = strin_period+5(4).

ENDFORM.                    "convert_date


************************************************************************
*populate tables. This form populates table with emp_no and wage types
************************************************************************
FORM populate_tables.
* Ting Ting 01.07.2009 CE00008429
  DATA : lt_allowance_ex  TYPE  TABLE OF zhrpy_pay_sheet,
         lwa_allowance_ex TYPE  zhrpy_pay_sheet.
  DATA : lt_deduction_ex  TYPE  TABLE OF zhrpy_pay_sheet,
         lwa_deduction_ex TYPE  zhrpy_pay_sheet.

  CLEAR lt_allowance_ex[].
  CLEAR lt_deduction_ex[].

  SELECT * FROM zhrpy_pay_sheet
  INTO CORRESPONDING FIELDS OF TABLE  lt_allowance_ex
  WHERE ind  = 'A' .
  IF sy-subrc <> 0.
    CLEAR lt_allowance_ex[].
  ENDIF.

  SELECT * FROM zhrpy_pay_sheet
  INTO CORRESPONDING FIELDS OF TABLE  lt_deduction_ex
  WHERE ind  = 'D' .
  IF sy-subrc <> 0.
    CLEAR lt_deduction_ex[].
  ENDIF.

  " Wage to exclude n allowance --  Ting Ting 01.07.2009 CE00008429
  CLEAR gt_allowanceex[].
  LOOP AT lt_allowance_ex INTO lwa_allowance_ex.
    gt_allowanceex-option = 'EQ'.
    gt_allowanceex-sign = 'I'.
    gt_allowanceex-low = lwa_allowance_ex-lgart.
    APPEND gt_allowanceex.
  ENDLOOP.

  " Wage to exclude n deduction --  Ting Ting 01.07.2009 CE00008429
  CLEAR gt_deductionex[].
  LOOP AT lt_deduction_ex INTO lwa_deduction_ex.
    gt_deductionex-option = 'EQ'.
    gt_deductionex-sign = 'I'.
    gt_deductionex-low = lwa_deduction_ex-lgart.
    APPEND gt_deductionex.
  ENDLOOP.

  " Monthly Salary
  CLEAR gt_allowance[].
  gt_allowance-option = 'EQ'.
  gt_allowance-sign = 'I'.
  gt_allowance-low = ' '.
  APPEND gt_allowance.

*  CLEAR gwa_t512t.
  " Ting ting commentd 27.7 2009
*  IF ( gt_allowanceex[] IS NOT INITIAL ).
*    LOOP AT gt_t512t INTO gwa_t512t WHERE lgart+0(1) <> '/' AND lgart NOT IN gt_allowanceex[].
*      gt_allowance-option = 'EQ'.
*      gt_allowance-sign = 'I'.
*      gt_allowance-low = gwa_t512t-lgart.
*      APPEND gt_allowance.
*    ENDLOOP.
*  ELSE.
*    LOOP AT gt_t512t INTO gwa_t512t WHERE lgart+0(1) <> '/'.
*      gt_allowance-option = 'EQ'.
*      gt_allowance-sign = 'I'.
*      gt_allowance-low = gwa_t512t-lgart.
*      APPEND gt_allowance.
*    ENDLOOP.
*  ENDIF.

* since org_str is needed.
  LOOP AT itab_payroll_02.
    org_str-low = itab_payroll_02-pernr.
    org_str-option = 'EQ'.
    org_str-sign = 'I'.
    APPEND org_str.
    CLEAR org_str.
  ENDLOOP.
* start CR-0000000157 by Chopper: cater for empty gt_allowanceex,gt_deductionex
*  else everything is IN, and NOT IN captures nothing
  IF gt_allowanceex[] IS INITIAL.
    MOVE: 'I' TO gt_allowanceex-sign, 'EQ' TO gt_allowanceex-option,
       space TO gt_allowanceex-low.  "Assume cannot have a wage with blank LGART!
    APPEND gt_allowanceex.
  ENDIF .
  IF gt_deductionex[] IS INITIAL.
    MOVE: 'I' TO gt_deductionex-sign, 'EQ' TO gt_deductionex-option,
       space TO gt_deductionex-low.  "Assume cannot have a wage with blank LGART!
    APPEND gt_deductionex.
  ENDIF .
* end by Chopper

  " Ting TIng comment 01.07.2009
* populate itab_wage with required wage types.
  SELECT lgart INTO itab_wage-low FROM t512w WHERE ( molga = '25' OR  molga = '14')
                 AND lgart NOT IN gt_allowanceex[] " Ting Ting added 01.07.2009
                 AND lgart NOT IN gt_deductionex[] " Ting Ting added 01.07.2009
                 AND ( lgart LIKE '9A%'
                  OR  lgart LIKE '9D%'
                  OR  ( lgart LIKE '9S%'
*( HRPS/05/040 TCTC
*                  AND lgart NE '9S90' AND lgart NE '9S91'  " ting ting commented 28.04.2009
     AND lgart NE '1S02' AND lgart NE '1S91' AND lgart NE '9B12' AND lgart NE '1S01'AND lgart NE '1S90' AND lgart NE '9B11'" ting ting added  28.04.2009
    )
*)
                  OR  lgart LIKE '9C%'
                  OR  lgart LIKE '9O%'
                  OR  lgart LIKE '9W%'
                  OR  lgart LIKE '9B%'
                  OR  lgart LIKE '9M%'
    " ting ting added 9233 01.09.2009
    OR  lgart = '9DBF'
    OR  lgart = '9DCF'

    ) "added 05.04.2004 by NYK
                  AND  begda <= pn-endda      "added 03/11/2000 by LTS
                  AND endda >= pn-begda.
    itab_wage-sign = 'I'.
    itab_wage-option = 'EQ'.
    APPEND itab_wage.
  ENDSELECT.

  " TIng ting added CE00009233 11 August 2009
*  IF ( gt_allowanceex[] IS NOT INITIAL AND gt_deductionex[] IS NOT INITIAL ).
*
*    SELECT lgart INTO itab_wage-low FROM t512w
*    WHERE ( molga = '25' OR molga = '14' )
*    AND aklas = '++9*'
*    AND  begda <= pn-endda
*    AND endda >= pn-begda
*    AND lgart NOT IN gt_allowanceex[] " Ting Ting added 01.07.2009
*    AND lgart NOT IN gt_deductionex[]. " Ting Ting added 01.07.2009
*
*      itab_wage-sign = 'I'.
*      itab_wage-option = 'EQ'.
*      APPEND itab_wage.
*    ENDSELECT.
*
*  ELSEIF ( gt_allowanceex[] IS NOT INITIAL AND gt_deductionex[] IS INITIAL ) .
*
*    SELECT lgart INTO itab_wage-low FROM t512w
*    WHERE ( molga = '25' OR molga = '14' )
*    AND aklas = '++9*'
*    AND  begda <= pn-endda
*    AND endda >= pn-begda
*    AND lgart NOT IN gt_allowanceex[]. " Ting Ting added 01.07.2009
*
*      itab_wage-sign = 'I'.
*      itab_wage-option = 'EQ'.
*      APPEND itab_wage.
*    ENDSELECT.
*
*  ELSEIF ( gt_allowanceex[] IS INITIAL AND gt_deductionex[] IS NOT INITIAL ) .
*
*    SELECT lgart INTO itab_wage-low FROM t512w
*    WHERE ( molga = '25' OR molga = '14' )
*    AND aklas = '++9*'
*    AND  begda <= pn-endda
*    AND endda >= pn-begda
*    AND lgart NOT IN gt_deductionex[]. " Ting Ting added 01.07.2009
*
*      itab_wage-sign = 'I'.
*      itab_wage-option = 'EQ'.
*      APPEND itab_wage.
*    ENDSELECT.
*  ELSE.


*
*  ENDIF.

*( HRPS/05/040 TCTC
*  itab_wage-low = '9Z91'. "ting ting commented
  itab_wage-low = '1Z01'.
  itab_wage-sign = 'I'.
  itab_wage-option = 'EQ'.
  APPEND itab_wage.

  itab_wage-low = '1Z91'." add ting ting commented
  itab_wage-sign = 'I'.
  itab_wage-option = 'EQ'.
  APPEND itab_wage.
*)
  itab_wage-low = '/305'.
  itab_wage-sign = 'I'.
  itab_wage-option = 'EQ'.
  APPEND itab_wage.

  itab_wage-low = '/307'.
  itab_wage-sign = 'I'.
  itab_wage-option = 'EQ'.
  APPEND itab_wage.

*(Error log: ncsnyk 04.07.2005
  itab_wage-low = '/308'.
  itab_wage-sign = 'I'.
  itab_wage-option = 'EQ'.
  APPEND itab_wage.
*)
*{
*{ Insert. ncslts 29.11.2004 AW CPF Ceiling shortfall
  itab_wage-low = '/314'.
  itab_wage-sign = 'I'.
  itab_wage-option = 'EQ'.
  APPEND itab_wage.

  itab_wage-low = '/316'.
  itab_wage-sign = 'I'.
  itab_wage-option = 'EQ'.
  APPEND itab_wage.
*}
  itab_wage-low = '/370'.
  itab_wage-sign = 'I'.
  itab_wage-option = 'EQ'.
  APPEND itab_wage.

  itab_wage-low = '/371'.
  itab_wage-sign = 'I'.
  itab_wage-option = 'EQ'.
  APPEND itab_wage.

  itab_wage-low = '/372'.
  itab_wage-sign = 'I'.
  itab_wage-option = 'EQ'.
  APPEND itab_wage.

  itab_wage-low = '/373'.
  itab_wage-sign = 'I'.
  itab_wage-option = 'EQ'.
  APPEND itab_wage.

  itab_wage-low = '/374'.
  itab_wage-sign = 'I'.
  itab_wage-option = 'EQ'.
  APPEND itab_wage.

  itab_wage-low = '/375'.
  itab_wage-sign = 'I'.
  itab_wage-option = 'EQ'.
  APPEND itab_wage.

  itab_wage-low = '/376'.
  itab_wage-sign = 'I'.
  itab_wage-option = 'EQ'.
  APPEND itab_wage.

  " Ting Ting added 24.06.2009 CE00008250
  itab_wage-low = '/37A'.
  itab_wage-sign = 'I'.
  itab_wage-option = 'EQ'.
  APPEND itab_wage.

  itab_wage-low = '/37B'.
  itab_wage-sign = 'I'.
  itab_wage-option = 'EQ'.
  APPEND itab_wage.

  itab_wage-low = '/37I'.
  itab_wage-sign = 'I'.
  itab_wage-option = 'EQ'.
  APPEND itab_wage.

* commented off by ytm on 04.10.2002 PAY-245
*  itab_wage-low = '/563'. "Claim from prev mth.
*  itab_wage-sign = 'I'.
*  itab_wage-option = 'EQ'.
*  APPEND itab_wage.

  itab_wage-low = '/565'.
  itab_wage-sign = 'I'.
  itab_wage-option = 'EQ'.
  APPEND itab_wage.

  itab_wage-low = '/566'.
  itab_wage-sign = 'I'.
  itab_wage-option = 'EQ'.
  APPEND itab_wage.

  itab_wage-low = '/557'.
  itab_wage-sign = 'I'.
  itab_wage-option = 'EQ'.
  APPEND itab_wage.

  itab_wage-low = '/558'.
  itab_wage-sign = 'I'.
  itab_wage-option = 'EQ'.
  APPEND itab_wage.

  itab_wage-low = '/559'.
  itab_wage-sign = 'I'.
  itab_wage-option = 'EQ'.
  APPEND itab_wage.

  itab_wage-low = '/561'.
  itab_wage-sign = 'I'.
  itab_wage-option = 'EQ'.
  APPEND itab_wage.

  itab_wage-low = '/563'. "Prev Claims
  itab_wage-sign = 'I'.
  itab_wage-option = 'EQ'.
  APPEND itab_wage.


  LOOP AT gt_t512w INTO gwa_t512w.
    READ TABLE itab_wage WITH KEY low =  gwa_t512w-lgart.
    IF sy-subrc <> 0.
      itab_wage-low = gwa_t512w-lgart.
      itab_wage-sign = 'I'.
      itab_wage-option = 'EQ'.
      APPEND itab_wage.
    ENDIF.
  ENDLOOP.


  " Ting ting commented --> 11 August 2009 CE00009233
  " ting ting added 27.05.2009 -- > Add in all the other wages
*  LOOP AT gt_t511 INTO gwa_t511.
**  WHERE lgart NOT IN gt_allowanceex[] " Ting Ting added 01.07.2009
**  AND lgart NOT IN gt_deductionex[]. " Ting Ting added 01.07.2009.
*    READ TABLE itab_wage WITH KEY low =  gwa_t511-lgart.
*    IF sy-subrc <> 0.
*      itab_wage-low = gwa_t511-lgart.
*      itab_wage-sign = 'I'.
*      itab_wage-option = 'EQ'.
*      APPEND itab_wage.
*    ENDIF.
*  ENDLOOP.

  " Ting ting commented --> 11 August 2009 CE00009233
  " CE00008773  Ting Ting added 8.7.2009
*  LOOP AT gt_t512t INTO gwa_t512t WHERE lgart+0(1) <> '/'.
**  WHERE lgart NOT IN gt_allowanceex[] " Ting Ting added 01.07.2009
**  AND lgart NOT IN gt_deductionex[]. " Ting Ting added 01.07.2009.
*    READ TABLE itab_wage WITH KEY low =  gwa_t512t-lgart.
*    IF sy-subrc <> 0.
*      itab_wage-low = gwa_t512t-lgart.
*      itab_wage-sign = 'I'.
*      itab_wage-option = 'EQ'.
*      APPEND itab_wage.
*    ENDIF.
*  ENDLOOP.


  itab_wagedec-low = '/305'. "E'yee,CPF-curr.contr./sum
  itab_wagedec-sign = 'I'.
  itab_wagedec-option = 'EQ'.
  APPEND itab_wagedec.
  itab_wagedec-low = '/370'. "E'yee, CDAC, add.fund
  itab_wagedec-sign = 'I'.
  itab_wagedec-option = 'EQ'.
  APPEND itab_wagedec.
  itab_wagedec-low = '/371'. "E'yee, SINDA,add.fund
  itab_wagedec-sign = 'I'.
  itab_wagedec-option = 'EQ'.
  APPEND itab_wagedec.
  itab_wagedec-low = '/372'. "E'yee, MBMF, add.fund
  itab_wagedec-sign = 'I'.
  itab_wagedec-option = 'EQ'.
  APPEND itab_wagedec.
  itab_wagedec-low = '/373'. "E'yee, ECF   add.fund
  itab_wagedec-sign = 'I'.
  itab_wagedec-option = 'EQ'.
  APPEND itab_wagedec.
  itab_wagedec-low = '/374'. "E'yee, COMCS add.fund
  itab_wagedec-sign = 'I'.
  itab_wagedec-option = 'EQ'.
  APPEND itab_wagedec.
  itab_wagedec-low = '/375'. "E'yee, Other fund
  itab_wagedec-sign = 'I'.
  itab_wagedec-option = 'EQ'.
  APPEND itab_wagedec.

  "CE00008309 Ting Ting
*  itab_wagedec-low = '/565' ."Carry-over for subs.month
*  itab_wagedec-sign = 'I'.
*  itab_wagedec-option = 'EQ'.
*  APPEND itab_wagedec.
*  itab_wagedec-low = '/566'. "Carry-over for prev.month
*  itab_wagedec-sign = 'I'.
*  itab_wagedec-option = 'EQ'.
*  APPEND itab_wagedec.

*{ Ammend above and insert below. ncslts 29.11.2004 AW CPF Ceiling
  itab_wagedec-low = '/314'. "E'YEE, Shortfall on AW
  itab_wagedec-sign = 'I'.
  itab_wagedec-option = 'EQ'.
  APPEND itab_wagedec.


  " Ting Ting comment 12.06.2009 CE00007621
*  itab_wagedec-low = '/303'. "
*  itab_wagedec-sign = 'I'.
*  itab_wagedec-option = 'EQ'.
*  APPEND itab_wagedec.


  itab_wagedec-low = '/563'. "Prev Claims
  itab_wagedec-sign = 'I'.
  itab_wagedec-option = 'EQ'.
  APPEND itab_wagedec.


  "Ting Ting Change CE00008309 25.06.2009

  IF (  gt_deductionex[] IS NOT INITIAL ).

    LOOP AT  gt_t511 INTO gwa_t511 WHERE opken <> '' AND lgart <> '/450' AND lgart <> '/303' AND lgart+0(1) <> '/'
    AND lgart NOT IN gt_deductionex[]. " Ting Ting added 01.07.2009..

      itab_wagesel1-low = gwa_t511-lgart.
      itab_wagesel1-sign = 'I'.
      itab_wagesel1-option = 'EQ'.
      APPEND itab_wagesel1.

*    READ TABLE itab_wagedec WITH KEY low =  gwa_t511-lgart.
*      IF sy-subrc <> 0.
*        itab_wagedec-low = gwa_t511-lgart.
*        itab_wagedec-sign = 'I'.
*        itab_wagedec-option = 'EQ'.
*        APPEND itab_wagedec.
*      ENDIF.

    ENDLOOP.
  ELSE.
    LOOP AT  gt_t511 INTO gwa_t511 WHERE opken <> '' AND lgart <> '/450' AND lgart <> '/303' AND lgart+0(1) <> '/'. " Ting Ting added 01.07.2009..

      itab_wagesel1-low = gwa_t511-lgart.
      itab_wagesel1-sign = 'I'.
      itab_wagesel1-option = 'EQ'.
      APPEND itab_wagesel1.

*      READ TABLE itab_wagedec WITH KEY low =  gwa_t511-lgart.
*      IF sy-subrc <> 0.
*        itab_wagedec-low = gwa_t511-lgart.
*        itab_wagedec-sign = 'I'.
*        itab_wagedec-option = 'EQ'.
*        APPEND itab_wagedec.
*      ENDIF.

    ENDLOOP.
  ENDIF.

  " Ting Ting 1 August 2009 CE00009233
  " Deduction
  CLEAR gwa_t512w.
  LOOP AT gt_t512w INTO gwa_t512w WHERE lgart IN itab_wagesel1[].

    READ TABLE itab_wagedec WITH KEY low =  gwa_t512w-lgart.

    IF sy-subrc <> 0.
      itab_wagedec-low = gwa_t512w-lgart.
      itab_wagedec-sign = 'I'.
      itab_wagedec-option = 'EQ'.
      APPEND itab_wagedec.
    ENDIF.

  ENDLOOP.

  " ting ting 27.7.2009
  IF ( gt_allowanceex[] IS NOT INITIAL ).
    LOOP AT  gt_t511 INTO gwa_t511 WHERE opken = '' AND lgart+0(1) <> '/' AND lgart NOT IN gt_allowanceex[].

      itab_wagesel2-low = gwa_t511-lgart.
      itab_wagesel2-sign = 'I'.
      itab_wagesel2-option = 'EQ'.
      APPEND itab_wagesel2.

*      gt_allowance-option = 'EQ'.
*      gt_allowance-sign = 'I'.
*      gt_allowance-low = gwa_t511-lgart.
*      APPEND gt_allowance.
    ENDLOOP.
  ELSE.
    LOOP AT  gt_t511 INTO gwa_t511 WHERE opken = '' AND lgart+0(1) <> '/'.
*      gt_allowance-option = 'EQ'.
*      gt_allowance-sign = 'I'.
*      gt_allowance-low = gwa_t511-lgart.
*      APPEND gt_allowance.

      itab_wagesel2-low = gwa_t511-lgart.
      itab_wagesel2-sign = 'I'.
      itab_wagesel2-option = 'EQ'.
      APPEND itab_wagesel2.

    ENDLOOP.
  ENDIF.


  " Ting Ting 1 August 2009 CE00009233
  " Allowance
  CLEAR gwa_t512w.
  LOOP AT gt_t512w INTO gwa_t512w WHERE lgart IN itab_wagesel2[].

    READ TABLE gt_allowance WITH KEY low =  gwa_t512w-lgart.

    IF sy-subrc <> 0.
      gt_allowance-low = gwa_t512w-lgart.
      gt_allowance-sign = 'I'.
      gt_allowance-option = 'EQ'.
      APPEND gt_allowance.
    ENDIF.

  ENDLOOP.

  " ting ting added CE00007471
*  READ TABLE itab_wagedec WITH KEY low = '/450'.
*  IF sy-subrc = 0.
*    DELETE itab_wagedec .
*  ENDIF.

*  itab_wagedec-low = '/450'. "
*  itab_wagedec-sign = 'I'.
*  itab_wagedec-option = 'EQ'.
*  APPEND itab_wagedec.

ENDFORM.                    "populate_tables

***********************************************************************
* fORM get_payroll data.
************************************************************************
FORM get_payroll.

  DATA: tmpwage TYPE p DECIMALS 2,
        perno   LIKE pernr-pernr,
        c       TYPE i,
        f       TYPE i,
        count   TYPE i,
        d       TYPE i.

  count  = 0.

*APPEND  LINES OF itab_payroll_02 TO itab_payroll.
  LOOP AT itab_payroll_02.
    MOVE-CORRESPONDING itab_payroll_02 TO itab_payroll_tmp.
    APPEND itab_payroll_tmp.
    CLEAR itab_payroll_tmp.

    DATA: wpbp LIKE pc205 OCCURS 0 WITH HEADER LINE.
* call function z_fmpa_payroll_result' to get payroll result.
    " ting ting commented
*    CLEAR wpbp.
*    REFRESH wpbp.
    CALL FUNCTION 'Z_FMPY_PAYROLL_RESULT'
      TABLES
        payroll   = itab_payroll_tmp
        wagetypes = itab_wage1
        wpbp_tab  = wpbp.

*==>Start of reverting back by not deleting offcycles SLA-738324
**==>Start of addition, Bernard, SIR 9953
*    delete itab_payroll_tmp where PAYTY <> ''.
*    delete itab_payroll_tmp where OCRSN <> ''.
**<==End of addition, Bernard, SIR 9953
*<==End of reverting back by not deleting offcycles SLA-738324

* check for wage types, if not found in itab_payroll_tmp delete the item
    LOOP AT itab_payroll_tmp.
      IF itab_payroll_tmp-lgart IN itab_wage.
* added by ytm. (PAY-225)
* 05.08.02
* to exclude /561 or /563 which is retro.

        " CE00008306 Ting Ting 26.06.2009 - to include retro. - 30.06.2009 Change back to exclude retro
        IF itab_payroll_tmp-lgart = '/561'
          "CE00007742  to include /563 Ting Ting added 15 06 2009
        OR itab_payroll_tmp-lgart = '/563'.
          IF itab_payroll_tmp-inper NE itab_payroll_tmp-fpper.
            DELETE itab_payroll_tmp.
          ENDIF.
        ENDIF.
        " CE00008306 Ting Ting 26.06.2009 -end - 30.06.2009 Change back to exclude retro
* end of addition (PAY-255)
      ELSE.
        DELETE itab_payroll_tmp.
      ENDIF.
    ENDLOOP.

* copy lines of itab_payroll_tmp to itab_payroll
    APPEND LINES OF itab_payroll_tmp TO itab_payroll.

* clear and refresh itab_payroll_tmp
    CLEAR itab_payroll_tmp.
    REFRESH itab_payroll_tmp.

  ENDLOOP.

*clear headerline
  CLEAR itab_payroll.
  tmpwage = 0.

* if no record exists
  DESCRIBE TABLE itab_payroll LINES count  .
  IF count = 0.
    MESSAGE i006.
    EXIT.
  ENDIF.
* Store into itab_total.
* For each pernr get distinct selected wage types, append to itab
  LOOP AT org_str.
    LOOP AT itab_wage.
*      READ TABLE itab_payroll WITH KEY   lgart  = itab_wage-low "CR-0000000739
*                                         pernr = org_str-low .
*      IF sy-subrc = 0.
      LOOP AT itab_payroll WHERE lgart  = itab_wage-low AND pernr = org_str-low.
*        READ TABLE itab_total WITH KEY pernr = org_str-low lgart = itab_wage-low. "CR-0000000739
        READ TABLE itab_total WITH KEY pernr = org_str-low lgart = itab_wage-low inper = itab_payroll-inper.
        IF sy-subrc <> 0.
          CLEAR itab_total.
          itab_total-pernr = itab_payroll-pernr.
          itab_total-lgart = itab_payroll-lgart.
          itab_total-rundt = itab_payroll-rundt.
          itab_total-ocrsn = itab_payroll-ocrsn.
          itab_total-inper = itab_payroll-inper. "CR-0000000739
          itab_total-seqnr = itab_payroll-seqnr. "CR-0000000739
          IF itab_total-ocrsn = ' '.
            itab_total-ocrsn = 'REGU'.
          ENDIF.
          APPEND itab_total.
          CLEAR itab_total.
        ENDIF.
*      ENDIF.
      ENDLOOP.
    ENDLOOP.
  ENDLOOP.

  SORT itab_payroll BY pernr lgart inper fpper.

  rundt2 = itab_payroll-rundt.

* total/deduct adjustments for each wage types
* if inper = fpper add betrg to the total adjustment

  " Ting ting commented 06August2009- remove the adjestment
  " Ting ting commented 11August2009- uncomment the adjestment
*  LOOP AT itab_total.
*
*    CLEAR tmpwage.
*    LOOP AT itab_payroll WHERE pernr = itab_total-pernr
*                           AND lgart = itab_total-lgart.
*
*      tmpwage = itab_total-total_wage.
*      tmpwage = tmpwage + itab_payroll-zzpa_adjustment.
*
*      IF itab_payroll-inper = itab_payroll-fpper.
*        tmpwage  = tmpwage + itab_payroll-betrg.
*        itab_total-total_wage = tmpwage.
*        itab_total-total_wage = tmpwage + itab_payroll-betrg.
*        MODIFY itab_total.
*      ELSEIF itab_payroll-zzpa_adjustment NE 0.             "applau
*        tmpwage = tmpwage + itab_payroll-zzpa_adjustment.
*        itab_total-total_wage =  itab_total-total_wage + tmpwage.   "kkl
*        itab_total-total_wage =  tmpwage.   "kkl
*        MODIFY itab_total.
*        CLEAR itab_total.          "kkl
*      ENDIF.
*    ENDLOOP.
*  ENDLOOP.




*  LOOP AT itab_total.
*
*    CLEAR tmpwage.
*    LOOP AT itab_payroll WHERE pernr = itab_total-pernr
*                           AND lgart = itab_total-lgart.
*
*      tmpwage = itab_total-total_wage.
**      tmpwage = tmpwage + itab_payroll-zzpa_adjustment.
*
*      IF itab_payroll-inper = itab_payroll-fpper.
**       tmpwage  = tmpwage + itab_payroll-betrg.
**       itab_total-total_wage = tmpwage.
*        itab_total-total_wage = tmpwage + itab_payroll-betrg.
*        MODIFY itab_total.
*      ELSEIF itab_payroll-zzpa_adjustment NE 0.             "applau
*        tmpwage = tmpwage.
**       itab_total-total_wage =  itab_total-total_wage + tmpwage.   "kkl
*        itab_total-total_wage =  tmpwage.   "kkl
*        MODIFY itab_total.
**        clear itab_total.          "kkl
*      ENDIF.
*    ENDLOOP.
*  ENDLOOP.



  LOOP AT itab_total.

    CLEAR tmpwage.
*    LOOP AT itab_payroll WHERE pernr = itab_total-pernr
*                           AND lgart = itab_total-lgart.
    LOOP AT itab_payroll WHERE pernr = itab_total-pernr
                           AND lgart = itab_total-lgart
                           AND inper = itab_total-inper."CR-0000000739
      tmpwage = itab_total-total_wage.
*      tmpwage = tmpwage + itab_payroll-zzpa_adjustment.

      IF itab_payroll-inper = itab_payroll-fpper.
*       tmpwage  = tmpwage + itab_payroll-betrg.
*       itab_total-total_wage = tmpwage.
        itab_total-total_wage = tmpwage + itab_payroll-betrg.
        MODIFY itab_total.
      ELSEIF itab_payroll-zzpa_adjustment NE 0.             "applau
        tmpwage = tmpwage + itab_payroll-zzpa_adjustment.
*       itab_total-total_wage =  itab_total-total_wage + tmpwage.   "kkl
        itab_total-total_wage =  tmpwage.   "kkl
        MODIFY itab_total.
*        clear itab_total.          "kkl

*         tmpwage = tmpwage.
**       itab_total-total_wage =  itab_total-total_wage + tmpwage.   "kkl
*        itab_total-total_wage =  tmpwage.   "kkl
*        MODIFY itab_total.
**        clear itab_total.

      ENDIF.
    ENDLOOP.
  ENDLOOP.



* append selected pernrs to emp_Details.
  LOOP AT org_str.
    c = 1.
    READ TABLE itab_total WITH KEY pernr = org_str-low.
    IF sy-subrc = 0.
      CLEAR emp_details.
      IF c = 1.
        emp_details-perno = itab_total-pernr.
        emp_details-ocrsn = itab_total-ocrsn.
        emp_details-rundt = itab_total-rundt.   "added 03/11/2000 by LTS
        APPEND emp_details.
        CLEAR emp_details.
        c = c + 1.
      ENDIF.
    ENDIF.
  ENDLOOP.
ENDFORM.                    "get_payroll

***********************************************************************
* fORM get_payroll data.
************************************************************************
FORM get_offcycle_payroll.

  DATA: tmpwage    TYPE p DECIMALS 2,
        perno      LIKE pernr-pernr,
        c          TYPE i,
        f          TYPE i,
*     checkflag,                            "Com by MT 18/1/01
        inputid    LIKE pc261-payid,
        inputty    LIKE pc261-payty,
        inputbondt LIKE pc261-bondt,
        call_count TYPE i,
        setcount   TYPE i,
        count      TYPE i,
        date_count TYPE i,
        scount     TYPE i,
        d          TYPE i.

  scount  = 0.
  setcount = 0.
  CLEAR call_count.
  date_count = 1..

* check whether first line of offcyle input has value
  IF NOT payty IS INITIAL.
    call_count = call_count + 1.
  ENDIF.

* check whether second line of offcycle input has value
  IF NOT payty_1 IS INITIAL.
    call_count = call_count + 1.
  ENDIF.

*clear and refresh tables
  CLEAR itab_total.

* do number of times offcycle values of input 1 or 2
  DO call_count TIMES.

    CLEAR itab_payroll_tmp.
    REFRESH itab_payroll_tmp.
    REFRESH itab_payroll.
    CLEAR itab_payroll.

* if data in first line of offcycle payroll
    IF scount = 0.
      IF NOT payty IS INITIAL.
        inputid = payid.
        inputty = payty.
        inputbondt  = bondt.
        scount  = 1.                        "Ins by MT 18/1/01
*       scount  = scount + 1.               "Com by MT 18/1/01
*     ELSE.                                 "Com by MT 18/1/01
*       checkflag = 'X'.                    "Com by MT 18/1/01
      ENDIF.

* if data in second line of offcycle payroll
    ELSE.
      IF NOT payty_1 IS INITIAL.
        inputid = payid_1.
        inputty = payty_1.
        inputbondt = bondt_1.
        scount  = 2.                        "Ins by MT 18/1/01
      ENDIF.
    ENDIF.


* loop each pernr in itab payroll and pass on per no so module.
    LOOP AT itab_payroll_02.
      MOVE-CORRESPONDING itab_payroll_02 TO itab_payroll_tmp.
      APPEND itab_payroll_tmp.
      CLEAR itab_payroll_tmp.

      DATA: wpbp LIKE pc205 OCCURS 0 WITH HEADER LINE.
* call function z_fmpa_payroll_result_01' to get payroll result.
*       Ting ting Comment
*      CALL FUNCTION 'Z_FMPY_PAYROLL_RESULT_01'
*        EXPORTING
*          inpid     = inputid
*          inpty     = inputty
*          bondt     = inputbondt
*        TABLES
*          payroll   = itab_payroll_tmp
*          wagetypes = itab_wage1.
*          wpbp_tab  = wpbp. ting ting 27.05.2009
*               wagetypes = itab_wage.          "kkl
*           wpbp_tab  = wpbp.

*    IF payty = 'B'.
*      LOOP AT itab_payroll WHERE lgart = '/305'
*      AND inper = '000000'.
*        IF sy-subrc = 0.
*          DELETE itab_payroll.
*          CLEAR itab_payroll.
*        ENDIF.
*      ENDLOOP.
*    ENDIF.

* kkl start
* instead of sending in the list of wage types to the function module,
* the wage type list is referenced when the payroll results are returned
* function module does not return correct results when passing in the
* list of wage types.
      DATA : lt_retro  TYPE zhr_retro_calc_t,
             lwa_retro TYPE zhr_retro_calc,
             lt_lgart  TYPE zhr_lgart_ty,
             lwa_lgart TYPE zhr_lgart_t.

      CALL FUNCTION 'Z_HR_RETRO_CALCULATION'
        EXPORTING
          pernr       = itab_payroll_02-pernr
          payrollarea = pnpxabkr
          offcycle    = 'X'
          wagetype    = lt_lgart
*         BEGDA       =
*         ENDDA       = lv_ENDDA
*==>Correction, Bernard, NHB-232279
*         paytype     = payty
*         paymentid   = payid
*         bondt       = bondt
          paytype     = inputty
          paymentid   = inputid
          bondt       = inputbondt
*<==Correction, Bernard, NHB-232279
*         PAYTYPE_INTERVAL = lt_payty
        IMPORTING
          ext_retro   = lt_retro.

      CLEAR lwa_retro .
*==>Start of addition, Bernard, 12 Mar 2010, NHB-232279
      DELETE lt_retro WHERE abkrs <> pnpxabkr.
*<==End of addition, Bernard, 12 Mar 2010, NHB-232279

*-- Begin NHB-345704 by AC_CHOPPER n A_JACKY:
      IF NOT lt_retro IS INITIAL. " only when staff has off-cycle result, clear /561 n /563 from regular payroll
        LOOP AT itab_total WHERE pernr = itab_payroll_02-pernr.
          MOVE 0 TO itab_total-total_wage .
          MODIFY itab_total TRANSPORTING total_wage
          WHERE ( lgart EQ '/563'
               OR  lgart EQ '/561' )
               AND pernr = itab_payroll_02-pernr. "which in fact is all of them
        ENDLOOP.
      ENDIF.
*-- End NHB-345704 by AC_CHOPPER n A_JACKY


*-- Begin NHB-345704 by AC_CHOPPER:
      SORT lt_retro BY
*        pernr
          lgart inper fpper
        paydt DESCENDING.
*itab_payroll has no paydt.  Has to be done at lt_retro.
*Can't delete ALL ADJACENT Dups, only '/561' and '/563'
      DATA: BEGIN OF lvflag,
              w561 TYPE flag,
              w563 TYPE flag,
            END OF lvflag.
      CLEAR lvflag.

*-- End NHB-345704 by AC_CHOPPER

      LOOP AT lt_retro INTO lwa_retro .
*-- Begin SR-0000009627 by AC_CHOPPER:  Update only the first (LATEST PAYDT) FOR 561, 563)
        CASE lwa_retro-lgart.
          WHEN '/561'.
            IF lvflag-w561 EQ 'X'.
              CONTINUE.
            ELSE.
              MOVE 'X' TO lvflag-w561.
            ENDIF.
          WHEN '/563'.
            IF lvflag-w563 EQ 'X'.
              CONTINUE.
            ELSE.
              MOVE 'X' TO lvflag-w563.
            ENDIF.
        ENDCASE . "lwa_retro-lgart.
*-- End SR-0000009627 by AC_CHOPPER

        MOVE-CORRESPONDING lwa_retro TO itab_payroll_tmp.
        itab_payroll_tmp-pernr = itab_payroll_02-pernr.
        APPEND itab_payroll_tmp.
      ENDLOOP.

      LOOP AT itab_payroll_tmp.
        IF itab_payroll_tmp-lgart IN itab_wage.
* added by ytm. (PAY-225)
* 05.08.02
* to exclude /561 or /563 which is retro.
          " CE00008306 Ting Ting 26.06.2009 -start 30.06.2009 to exclude retro
          IF itab_payroll_tmp-lgart = '/561'
*            SIR CE00007742 Ting Ting added 15 06 2009
          OR itab_payroll_tmp-lgart = '/563'.
            IF itab_payroll_tmp-inper NE itab_payroll_tmp-fpper.
              DELETE itab_payroll_tmp.
            ENDIF.
          ENDIF.
          " CE00008306 Ting Ting 26.06.2009 -end
* end of addition (PAY-255)
        ELSE.
          DELETE itab_payroll_tmp.
        ENDIF.
      ENDLOOP.
* kkl end

* copy lines of itab_payroll_tmp to itab_payroll
      APPEND LINES OF itab_payroll_tmp TO itab_payroll.

* clear and refresh itab_payroll_tmp for next pernr
      CLEAR itab_payroll_tmp.
      REFRESH itab_payroll_tmp.

    ENDLOOP.

    SORT itab_payroll BY pernr lgart inper fpper.

    READ TABLE itab_payroll INDEX 1.
    IF sy-subrc = 0.

* check call count and add run date
      IF date_count = 1.
        rundt3 = itab_payroll-rundt.
        date_count = date_count + 1.
      ELSE.
        rundt4 = itab_payroll-rundt.
      ENDIF.
    ENDIF.


    tmpwage = 0.

* check whether any data
    DESCRIBE TABLE itab_payroll LINES count  .
    IF count = 0.
      itab_payroll-rundt = run_date1.         "kkl
*     MESSAGE i091.                           "Com by MT 18/1/01
      IF scount = 1.                          "Ins by MT 18/1/01
        MESSAGE i105.                         "Ins by MT 18/1/01
      ELSEIF scount = 2.                      "Ins by MT 18/1/01
        MESSAGE i106.                         "Ins by MT 18/1/01
      ENDIF.                                  "Ins by MT 18/1/01
      STOP.                                   "Ins by MT 15/1/01
    ELSE.                                     "kkl
      LOOP AT itab_payroll. ENDLOOP.          "kkl
      run_date1 = itab_payroll-rundt.         "kkl
    ENDIF.


* check for any data in itab total, if initial append pernr
    IF itab_total[] IS INITIAL.
      setcount = 1.
    ELSE.
      setcount = 2.
    ENDIF.
    IF setcount = 1.
      LOOP AT org_str.
        LOOP AT itab_wage.
          READ TABLE itab_payroll WITH KEY  pernr = org_str-low
                                            lgart = itab_wage-low.
          IF sy-subrc = 0.
            READ TABLE itab_total WITH KEY pernr = org_str-low lgart = itab_wage-low.
            IF sy-subrc <> 0.
              CLEAR itab_total.
              itab_total-pernr = itab_payroll-pernr.
              itab_total-lgart = itab_payroll-lgart.
              itab_total-rundt = itab_payroll-rundt.
              itab_total-ocrsn = itab_payroll-ocrsn.
              itab_total-inper = itab_payroll-fpper. "CR-0000000739
              itab_total-seqnr = itab_payroll-seqnr. "CR-0000000739
              IF itab_total-ocrsn = ' '.
                itab_total-ocrsn = 'REGU'.
              ENDIF.
              APPEND itab_total.
              CLEAR itab_total.
            ENDIF.
          ENDIF.
        ENDLOOP.
      ENDLOOP.
    ENDIF.

    IF setcount = 2.
      CLEAR itab_total.

*     if data found, append pernr not in the regular payroll
      LOOP AT org_str.
        LOOP AT itab_wage.
          READ TABLE itab_payroll WITH KEY pernr = org_str-low
                                           lgart = itab_wage-low.
          IF sy-subrc = 0.
            CLEAR itab_total.
            READ TABLE itab_total WITH KEY pernr = itab_payroll-pernr
                                           lgart = itab_payroll-lgart.
            IF sy-subrc <> 0.
              itab_total-pernr = itab_payroll-pernr.
              itab_total-lgart = itab_payroll-lgart.
              itab_total-rundt = itab_payroll-rundt.
              itab_total-ocrsn = itab_payroll-ocrsn.
              IF itab_total-ocrsn = ' '.
                itab_total-ocrsn = 'REGU'.
              ENDIF.
              APPEND itab_total.
              CLEAR itab_total.
            ENDIF.
          ENDIF.
        ENDLOOP.
      ENDLOOP.

    ENDIF.

    SORT itab_payroll BY pernr lgart .
    CLEAR: itab_total.
* add amount of wage types to total_wages
    LOOP AT itab_payroll .
      CLEAR tmpwage.
      LOOP AT itab_total WHERE pernr = itab_payroll-pernr
                           AND lgart = itab_payroll-lgart.

        tmpwage = itab_total-total_wage.
*==>Start of modification, Bernard, 25 Jan 2010
*        IF itab_payroll-fpper = itab_payroll-inper.
*          itab_total-total_wage = tmpwage + itab_payroll-betrg.
*        ELSE.
*          itab_total-total_wage = tmpwage + itab_payroll-zzpa_adjustment.
*        ENDIF.
        itab_total-total_wage = tmpwage + itab_payroll-betrg.
*<==End of modification, Bernard, 25 Jan 2010
        MODIFY itab_total.
        CLEAR itab_total.
      ENDLOOP.
    ENDLOOP.
  ENDDO.

  IF action = 2.

* append pernr to emp_Details
    LOOP AT org_str.
      READ TABLE itab_total WITH KEY  pernr = org_str-low.
      IF sy-subrc = 0.
        emp_details-perno = itab_total-pernr.
        emp_details-ocrsn = itab_total-ocrsn.
        emp_details-rundt = itab_total-rundt.   "added 03/11/2000 by LTS
        APPEND emp_details.
        CLEAR emp_details.
      ENDIF.
    ENDLOOP.
  ELSE.

* append emp nos not in the regular payroll run
    LOOP AT itab_total.
      READ TABLE emp_details WITH KEY perno = itab_total-pernr.
      IF sy-subrc <> 0.
        emp_details-perno = itab_total-pernr.
        emp_details-ocrsn = itab_total-ocrsn.
        emp_details-rundt = itab_total-rundt.  "added 03/11/2000 by LTS
        APPEND emp_details.
      ENDIF.
    ENDLOOP.
  ENDIF.

* check the latest date
  IF rundt3 > rundt4.
    rundt4 = rundt3.
  ENDIF.

ENDFORM.                    "get_offcycle_payroll

************************************************************************
*form bas_ind. This form adds 'A' and  'B' to fields for sorting
************************************************************************
FORM bas_ind.

  LOOP AT itab_total.
*    IF itab_total-lgart = '9S01'." ting ting 28.04.2009
    IF itab_total-lgart = '0BAS'.
      itab_total-bas_ind = 'A'.
    ELSE.
      itab_total-bas_ind  = 'B'.
    ENDIF.
    MODIFY itab_total.
  ENDLOOP.
ENDFORM..                    "bas_ind


*---------------------------------------------------------------------*
*       FORM wage_desc                                                *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM wage_desc.

  LOOP AT itab_total .
    SELECT lgtxt INTO (itab_total-wage_desc)
    FROM t512t
    WHERE sprsl = 'EN'
    AND molga = '25'
    AND lgart = itab_total-lgart.
      MODIFY itab_total.
    ENDSELECT.

  ENDLOOP.
ENDFORM.                    "wage_desc


*---------------------------------------------------------------------*
*       FORM select_empdetails                                        *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM select_empdetails.

********************************************************
* commented out by kenneth on 21/9/2001
* the info of the employee should be retrieved
* based on the last day of the payroll period.
********************************************************
* select employee details from pa0001
* added ename
  DATA: period_parameter LIKE t549a-permo.

  SELECT SINGLE permo FROM t549a INTO period_parameter
  WHERE abkrs = pnpxabkr.
  IF sy-subrc <> 0.
    MESSAGE e150 WITH 'Cannot find period parameter in T549A!'.
  ENDIF.

  IF pnptimra = 'X'.
    SELECT SINGLE endda FROM t549q INTO payroll_last_day
    WHERE permo = period_parameter
    AND pabrp = pnppabrp
    AND pabrj = pnppabrj.
  ELSE.
    SELECT SINGLE endda FROM t549q INTO payroll_last_day
    WHERE permo = period_parameter
    AND pabrp = pnpdispp
    AND pabrj = pnpdispj.
  ENDIF.

  IF sy-subrc <> 0.
    MESSAGE e150 WITH 'Cannot find payroll last day in T549Q!'.
  ENDIF.

* SELECT pernr ename orgeh begda zzpa_sub_gr         "ACE 17 Feb 09
*         kostl btrtl werks plans persg             "ACE 17 Feb 09
*         zzpa_per_grp                              "ACE 17 Feb 09

  "persg added 03/11/2000 by LTS
  "added 07/09/2001 by ytm
  SELECT pernr ename orgeh begda zzsubg             "ACE 17 Feb 09
         kostl btrtl werks plans stell persk persg "<ting ting changed 22.05.2009 the position of  persk persg

  INTO  (itab_p1-perno, itab_p1-ename, itab_p1-orgunit, itab_p1-begda,
        itab_p1-subapp, itab_p1-bassal, itab_p1-divstatus,
        itab_p1-persarea, itab_p1-position, itab_p1-job,
        itab_p1-subgrp, itab_p1-zzpa_per_grp)
   FROM pa0001

   FOR ALL ENTRIES IN org_str[]
   WHERE pernr = org_str-low
*  pernr IN org_str
   AND
    begda <=  payroll_last_day
   AND endda >=  payroll_last_day.
    APPEND itab_p1.

  ENDSELECT.
  IF sy-subrc <> 0.
  ENDIF.

  DATA : lv_index TYPE i.
  DATA : lv_kst01  TYPE pa0027-kst01.

  CLEAR : lv_index, lv_kst01, gv_kstar, gv_kpr01.
  " Added in ting ting 17.07.2009 Cost Center to read from 0027 before 0001
  LOOP AT itab_p1.

    lv_index = lv_index + 1.
    SELECT kst01 kstar  kpr01 INTO (lv_kst01, gv_kstar, gv_kpr01)
    FROM pa0027
    WHERE pernr = itab_p1-perno
    AND begda <=  payroll_last_day
    AND endda >=  payroll_last_day.
    ENDSELECT.
    "    IF sy-subrc = 0.                              "Commented by Hsin Ming on 05 Oct 2009
    IF sy-subrc = 0 AND lv_kst01 IS NOT INITIAL.   "Added by Hsin Ming on 05 Oct 2009
      itab_p1-bassal = lv_kst01.
      MODIFY itab_p1 INDEX lv_index .
    ENDIF.

  ENDLOOP.


  IF sy-subrc <> 0.
  ENDIF.




* delete duplicates
  SORT itab_p1 DESCENDING BY perno begda.
  DELETE ADJACENT DUPLICATES FROM itab_p1 COMPARING perno.

* select employee details from pa0002
  SELECT pernr perid begda nachn vorna gesch  konfe
  INTO (itab_p2-perno, itab_p2-nric,itab_p2-begda, itab_p2-fname,
        itab_p2-lname, itab_p2-sex, itab_p2-religion)
  FROM pa0002
   FOR ALL ENTRIES IN org_str[]
   WHERE pernr = org_str-low
*  WHERE pernr IN org_str
*  AND begda <=  rundtfinal      "added 03/11/2000 by LTS
*  AND endda >=  rundtfinal.
   AND begda <=  payroll_last_day "changed by tmyeo
   AND endda >=  payroll_last_day.
    APPEND itab_p2.
  ENDSELECT.
  IF sy-subrc <> 0.
  ENDIF.

* delete duplicates
  SORT itab_p2 DESCENDING BY perno begda.
  DELETE ADJACENT DUPLICATES FROM itab_p2 COMPARING perno.

* select employee details from pa0008
* SELECT pernr trfgr begda zzpa_bar_level stvor trfst                 "ACE 17 feb 09
*  INTO (itab_p8-perno, itab_p8-sal_code, itab_p8-begda,              "ACE 17 feb 09
*        itab_p8-nex_salbar, itab_p8-inc_date, itab_p8-pay_scale)     "ACE 17 feb 09


  SELECT pernr trfgr begda zzebarsc1 stvor trfst                  "ACE 17 Feb 09
  INTO (itab_p8-perno, itab_p8-sal_code, itab_p8-begda,              "ACE 17 feb 09
        itab_p8-nex_salbar, itab_p8-inc_date, itab_p8-pay_scale)     "ACE 17 feb 09
  FROM pa0008
     FOR ALL ENTRIES IN org_str[]
   WHERE pernr = org_str-low
*  WHERE pernr IN org_str
  AND begda <=  payroll_last_day "changed by tmyeo
  AND endda >=  payroll_last_day
*  AND begda <=  rundtfinal      "added 03/11/2000 by LTS
*  AND endda >= rundtfinal
  AND subty = '0'.
    APPEND itab_p8.
  ENDSELECT.
  IF sy-subrc <> 0.
  ENDIF.

* delete duplicates
  SORT itab_p8 DESCENDING BY perno begda.
  DELETE ADJACENT DUPLICATES FROM itab_p8 COMPARING perno.

* select employee details from pa0009
  SELECT pernr begda bankl bankn
  INTO (itab_p9-perno,itab_p9-begda,itab_p9-bankkey, itab_p9-baccno)
  FROM pa0009
         FOR ALL ENTRIES IN org_str[]
   WHERE pernr = org_str-low
*  WHERE pernr IN org_str
*  AND begda <=  rundtfinal      "added 03/11/2000 by LTS
*  AND endda >=  rundtfinal.
  AND begda <=  payroll_last_day "changed by tmyeo
  AND endda >=  payroll_last_day.
    APPEND itab_p9.
  ENDSELECT.
  IF sy-subrc <> 0.
  ENDIF.

* delete duplicates
  SORT itab_p9 DESCENDING BY perno begda.
  DELETE ADJACENT DUPLICATES FROM itab_p9 COMPARING perno.

* Select employee details from pa0077
  SELECT pernr begda racky
  INTO (itab_p77-perno,itab_p77-begda,itab_p77-race_type)
  FROM pa0077
             FOR ALL ENTRIES IN org_str[]
   WHERE pernr = org_str-low
*  WHERE pernr IN org_str
*  AND begda <= rundtfinal      "added 03/11/2000 by LTS
*  AND endda >= rundtfinal.
  AND begda <=  payroll_last_day "changed by tmyeo
  AND endda >=  payroll_last_day.
    APPEND itab_p77.
  ENDSELECT.
  IF sy-subrc <> 0.
  ENDIF.

* delete duplicates
  SORT itab_p77 DESCENDING BY perno begda.
  DELETE ADJACENT DUPLICATES FROM itab_p77 COMPARING perno.

* select employee details from pa0016
  SELECT pernr cttyp begda
   INTO (itab_p16-perno,itab_p16-cont, itab_p16-begda)
   FROM pa0016
                 FOR ALL ENTRIES IN org_str[]
   WHERE pernr = org_str-low
*   WHERE pernr IN org_str
*   AND begda <=  rundtfinal      "added 03/11/2000 by LTS
*   AND endda >=  rundtfinal.
   AND begda <=  payroll_last_day "changed by tmyeo
   AND endda >=  payroll_last_day.
    APPEND itab_p16.
  ENDSELECT.
  IF sy-subrc <> 0.
  ENDIF.

* delete duplicates
  SORT itab_p16 DESCENDING BY perno begda.
  DELETE ADJACENT DUPLICATES FROM itab_p16 COMPARING perno.

* select employee details from pa0186
  SELECT pernr begda cpfna
    INTO (itab_p186-perno, itab_p186-begda,
          itab_p186-fundname)
    FROM pa0186
                 FOR ALL ENTRIES IN org_str[]
   WHERE pernr = org_str-low
*    WHERE pernr IN org_str
*   AND begda <=  rundtfinal      "added 03/11/2000 by LTS
*   AND endda >=  rundtfinal.
    AND begda <=  payroll_last_day "changed by tmyeo
    AND endda >=  payroll_last_day.
    APPEND itab_p186.
  ENDSELECT.
  IF sy-subrc <> 0.
  ENDIF.


* delete duplicates
  SORT itab_p186 DESCENDING BY perno begda.
  DELETE ADJACENT DUPLICATES FROM itab_p186 COMPARING perno.

* sort itabs
  SORT emp_details BY perno.
  SORT itab_p1 BY perno orgunit.
  SORT itab_p2 BY perno.
  SORT itab_p8 BY perno.
  SORT itab_p9 BY perno.
  SORT itab_p77 BY perno.

*****************************************************************
  " Employee Subgroup
  DATA : gt_t503t         TYPE TABLE OF t503t.              " t503t
  DATA : gwa_t503t        TYPE t503t.                       " t503t

  CLEAR gt_t503t[].
  SELECT * FROM t503t
  INTO CORRESPONDING FIELDS OF TABLE gt_t503t
  WHERE sprsl = sy-langu.
  IF sy-subrc <> 0.
    CLEAR gt_t503t[] .
  ENDIF.
* populate emp_details with itab_p1 fields
  LOOP AT emp_details.
    LOOP AT itab_p1 WHERE perno = emp_details-perno.

* added full name to emp_details
      emp_details-begda = itab_p8-begda. "added by ncsup 19, april 01
      emp_details-ename = itab_p1-ename.
      emp_details-subapp = itab_p1-subapp.
      emp_details-orgeh = itab_p1-orgunit.
      emp_details-bassal = itab_p1-bassal.
      emp_details-divstatus = itab_p1-divstatus.
      emp_details-persarea = itab_p1-persarea.
      emp_details-position = itab_p1-position.
      emp_details-posttyp = itab_p1-job.              "ACE 18 Feb 09
      emp_details-subgrp = itab_p1-subgrp.

      emp_details-zzpa_per_grp = itab_p1-zzpa_per_grp. "ytm 07/09/01

      " ting ting added CE00007776 16.06.2009
      CLEAR emp_details-per_grp_desc.

      CLEAR gwa_t503t.
      READ TABLE gt_t503t  INTO gwa_t503t WITH KEY persk = itab_p1-subgrp .
      IF sy-subrc = 0.
        emp_details-per_grp_desc = gwa_t503t-ptext. " Employee Subgroup text
      ELSE.
        emp_details-per_grp_desc = ''.
      ENDIF.

      " ting ting 22.05.2009 Start-
*      SELECT SINGLE zzpa_desc1 FROM ztpa_code_per_gp
*      INTO emp_details-per_grp_desc
*      WHERE zzpa_per_group  = itab_p1-zzpa_per_grp.
*      IF sy-subrc <> 0.
*        CLEAR emp_details-per_grp_desc.
*      ENDIF.
*      MODIFY emp_details.


*      SELECT SINGLE ptext FROM t501t
*      INTO emp_details-per_grp_desc
*      WHERE persg = itab_p1-zzpa_per_grp
*      AND sprsl = sy-langu .
*        IF sy-subrc <> 0.
*          CLEAR emp_details-per_grp_desc.
*        ENDIF.
*        MODIFY emp_details.

      " ting ting 22.05.2009 End-

*      SELECT SINGLE name1 FROM t500p
*      INTO emp_details-per_grp_desc
*      WHERE persa = emp_details-persarea
*      AND molga = '25'.
*      IF sy-subrc <> 0.
*        CLEAR emp_details-per_grp_desc.
*      ENDIF.
*      MODIFY emp_details.
      " ting ting 28.05.2009 End- Personnel Group

    ENDLOOP.


* populate emp_details with itab_p2 fields
    LOOP AT itab_p2 WHERE perno = emp_details-perno.
      emp_details-nric = itab_p2-nric.
      emp_details-fname = itab_p2-fname.
      emp_details-lname = itab_p2-lname.
      emp_details-sex  = itab_p2-sex.
      IF itab_p2-sex = '1'.
        emp_details-m_sex = 'M'.
      ELSE.
        emp_details-m_sex = 'F'.
      ENDIF.
      emp_details-religion = itab_p2-religion.
      MODIFY emp_details.
    ENDLOOP.


* populate emp_details with itab_p8 fields
    LOOP AT itab_p8 WHERE perno = emp_details-perno.
      emp_details-sal_code = itab_p8-sal_code.
      emp_details-nex_salbar = itab_p8-nex_salbar.
      emp_details-inc_date = itab_p8-inc_date.
      emp_details-pay_scale = itab_p8-pay_scale. "modi. ncsup 13,Feb 01
      MODIFY emp_details.
    ENDLOOP.

* populate emp_details with itab_p9 fields
    LOOP AT itab_p9 WHERE perno = emp_details-perno.
      emp_details-bankkey = itab_p9-bankkey.
      emp_details-baccno = itab_p9-baccno.
      MODIFY emp_details.
    ENDLOOP.

* populate emp_details with itab_p77 fields
    LOOP AT itab_p77 WHERE perno = emp_details-perno.
      emp_details-race_type = itab_p77-race_type.
      MODIFY emp_details.
    ENDLOOP.

* populate emp_details with itab_p16 fields
    LOOP AT itab_p16 WHERE perno = emp_details-perno.
      emp_details-tenure = itab_p16-cont.
      MODIFY emp_details.
    ENDLOOP.

* populate emp_details with itab_186 fields
    LOOP AT itab_p186 WHERE perno = emp_details-perno.
      emp_details-type_svc = itab_p186-fundname.
      MODIFY emp_details.
    ENDLOOP.
  ENDLOOP.

* check the latest date
  IF rundt3 > rundt4.
    rundt4 = rundt3.
  ENDIF.


ENDFORM.                    "select_empdetails

************************************************************************
* form emp_cpf. This form get cpf no of the employer
************************************************************************
FORM emp_cpf.

  LOOP AT emp_details.
    SELECT epcpf INTO emp_details-emp_cpfno
    FROM t5r0p
  WHERE werks = emp_details-persarea  AND btrtl = emp_details-divstatus.
    ENDSELECT.
    MODIFY emp_details.
  ENDLOOP.

ENDFORM.                    "emp_cpf

************************************************************************
* Form get_post_type. This form gets type of post
************************************************************************
FORM get_post_type.                   "ACE 17 Feb 09
*  LOOP AT emp_details.
*    SELECT zzpa_post_type
*    INTO emp_details-posttyp
*    FROM hrp9002
*    WHERE plvar = '01'
*    AND otype = 'S'
*    AND objid = emp_details-position
*    AND istat = '1'.      "added 03/11/2000 by LTS
*      MODIFY emp_details.
*    ENDSELECT.
* ENDLOOP.

ENDFORM.                    "get_post_type

***************sub-routines to get descriptions for codes **********

************************************************************************
** form get_subapp. This form gets substantive appointment descriptions
************************************************************************
FORM get_subsapp.

*  LOOP AT emp_details.                  "ACE 17 Feb 09
*    SELECT zzpa_abbr_desc
*    INTO emp_details-subappdesc
*    FROM zvpa_subst_grade
*    WHERE zzpa_subst_grade = emp_details-subapp.
*      MODIFY emp_details.
*    ENDSELECT.
*  ENDLOOP.                              "ACE 17 Feb 09

  LOOP AT emp_details.                   "ACE 17 Feb 09
    SELECT zzdescription
    INTO emp_details-subappdesc
    FROM zhr_om_subgrades
    WHERE zzsubcode = emp_details-subapp
      AND zzbtrtl = emp_details-divstatus
      AND zzpersk = emp_details-subgrp
      AND ( zzendda >= emp_details-rundt AND zzbegda <= emp_details-rundt ).
      MODIFY emp_details.
    ENDSELECT.
  ENDLOOP.                                "ACE 17 Feb 09

ENDFORM.                    "get_subsapp

************************************************************************
** form get_racedesc. This form gets race descriptions
************************************************************************
FORM get_racedesc.

  LOOP AT emp_details.
    SELECT ltext
    INTO emp_details-race_desc         " molga 25 = singapore
    FROM t505s
    WHERE sprsl = 'EN'      "added 03/11/2000 by LTS
    AND molga = '25'
    AND racky = emp_details-race_type.
      MODIFY emp_details.
    ENDSELECT.
  ENDLOOP.

ENDFORM.                    "get_racedesc
************************************************************************
** form get_divstatdesc.This form gets divsion status descriptions
************************************************************************
FORM get_divstatdesc.

  LOOP AT emp_details.
    " ting ting commented 16.06.2009 Sir CE00007776

    emp_details-divstatus_desc = emp_details-divstatus.
*    SELECT btext
*    INTO emp_details-divstatus_desc
*    FROM t001p
*    WHERE molga = '25'
*    AND werks = emp_details-persarea      "added 03/11/2000 by LTS
*    AND btrtl = emp_details-divstatus.
*      IF emp_details-persarea = '0007'.
*        emp_details-divstatus_desc = 'CEE'.
*      ENDIF.
*      IF emp_details-persarea = '0001'.
*        emp_details-divstatus_desc = 'SUP'.
*      ENDIF.
    MODIFY emp_details.
*  ENDSELECT.
  ENDLOOP.

ENDFORM.                    "get_divstatdesc
************************************************************************
** get_religiondesc. This form gets religion descriptions
************************************************************************
FORM get_religiondesc.

  LOOP AT emp_details.
    SELECT ktext
    INTO emp_details-religion_desc
    FROM t516t
    WHERE sprsl = 'EN' AND konfe = emp_details-religion.
      MODIFY emp_details.
    ENDSELECT.
  ENDLOOP.

ENDFORM.                    "get_religiondesc
************************************************************************
** get_orgunitdesc. This form gets organisation unit's description
************************************************************************
FORM get_orgunitdesc.

  LOOP AT emp_details.
    SELECT stext INTO emp_details-org_desc
    FROM hrp1000 WHERE otype = 'O'
    AND  objid = emp_details-orgeh
    AND  langu = sy-langu
*    orgtx into emp_details-org_desc
*    from t527x where sprsl = 'EN'      "modified 03/11/2000 by LTS
*    and orgeh = emp_details-orgeh
    AND ( endda >= emp_details-rundt AND begda <= emp_details-rundt ).
      MODIFY emp_details.
    ENDSELECT.
  ENDLOOP.

ENDFORM.                    "get_orgunitdesc

************************************************************************
**Form pos_Desc
************************************************************************
FORM pos_desc.                      "ACE 17 Feb 09

*  LOOP AT emp_details.
*    SELECT zzpa_abbr_desc
*     INTO emp_details-pos_desc
*     FROM ztpa_code_post      "modified 03/11/2000 by LTS
*     WHERE zzpa_post_type = emp_details-posttyp.
*      MODIFY emp_details.
*    ENDSELECT.
*  ENDLOOP.
  LOOP AT emp_details.
    SELECT short INTO emp_details-pos_desc
    FROM hrp1000 WHERE otype = 'C'
    AND  objid = emp_details-posttyp
    AND  langu = sy-langu
*    orgtx into emp_details-org_desc
*    from t527x where sprsl = 'EN'      "modified 03/11/2000 by LTS
*    and orgeh = emp_details-orgeh
    AND ( endda >= emp_details-rundt AND begda <= emp_details-rundt ).
      MODIFY emp_details.
    ENDSELECT.
  ENDLOOP.

ENDFORM.                    "pos_desc

************************************************************************
** form tenure_Desc        "modified 03/11/2000 by LTS
************************************************************************
FORM tenure_desc.

  DATA : lv_bplan TYPE pa0377-bplan,
         gt_0377  TYPE STANDARD TABLE OF pa0377,
         gwa_0377 TYPE pa0377.
  " ting ting changed 26.05.2009
*  LOOP AT emp_details.
*    SELECT ptext INTO emp_details-tenure_desc
*    FROM t501t
*    WHERE sprsl = 'EN' AND persg = emp_details-subgrp.
*    ENDSELECT.
*    MODIFY emp_details.
*  ENDLOOP.
  " Added 13062009 SIR CE00007656

                                                            "PA0377
  LOOP AT emp_details.
    CLEAR gt_0377[].
    CLEAR lv_bplan.
    SELECT * FROM pa0377 INTO CORRESPONDING FIELDS OF TABLE gt_0377
    WHERE pernr = emp_details-perno
    AND subty = 'MEDI'
    AND begda <=  payroll_last_day
    AND endda >=  payroll_last_day.
    IF sy-subrc = 0.
      SORT  gt_0377 BY endda DESCENDING begda DESCENDING.
    ENDIF.


    SELECT ptext INTO emp_details-tenure_desc
    FROM t501t
    WHERE sprsl = 'EN' AND persg = emp_details-zzpa_per_grp.
    ENDSELECT.

    CLEAR gwa_0377.
    READ TABLE gt_0377 INTO gwa_0377 WITH KEY pernr = emp_details-perno .
    CLEAR lv_bplan.
    IF sy-subrc = 0.
      lv_bplan = gwa_0377-bplan.
    ELSE.
      CLEAR lv_bplan.
    ENDIF.

    IF ( lv_bplan+0(1) = 'M').

      CONCATENATE lv_bplan   '-' emp_details-tenure_desc INTO emp_details-tenure_desc  SEPARATED BY space.
    ENDIF.

    MODIFY emp_details.
  ENDLOOP.


ENDFORM.                    "tenure_desc

************************************************************************
** form get_salpoint.
************************************************************************
FORM get_salpoint.

  DATA: tmpsal      LIKE t510-betrg,
        tmpsal2     LIKE t510-betrg,
        tmpsal3     LIKE  t510-betrg,
        count       TYPE i,
        totaltmpsal LIKE t510-betrg.

*Internal table to store wage type and amout
  DATA: BEGIN OF tmp_code OCCURS 10,
          perno     LIKE pernr-pernr,
          wage_type LIKE t510-lgart,
          amount    LIKE t510-betrg,
        END OF tmp_code.

* internal table with wage Types
  DATA: BEGIN OF tmp_wage OCCURS 10,
          wage LIKE t510-lgart,
        END OF tmp_wage.

* modified by ncsup 13,Feb 2001
  tmp_wage-wage = '0BAS'.
*  tmp_wage-wage = '9S01'. " ting ting 28.04.2009
  APPEND tmp_wage.
  CLEAR tmp_wage.

*  tmp_wage-wage = '9S02'." ting ting 28.04.2009
  tmp_wage-wage = '0MVC'.
  APPEND tmp_wage.
  CLEAR tmp_wage.

*  tmp_wage-wage = '9S03'." " ting ting 28.04.2009
  tmp_wage-wage = '0NPC'.
  APPEND tmp_wage.
  CLEAR tmp_wage.

  SORT tmp_wage BY wage.

* added by ytm on 04.10.2002 PAY-245
* select t510 table into temp_t510 to speed up process.
* rather than using select statment to read t510 for each employee.
  DATA temp_t510 LIKE t510 OCCURS 1000 WITH HEADER LINE.

  SELECT * FROM t510 INTO TABLE temp_t510
  WHERE endda >= payroll_last_day AND
        begda <= payroll_last_day AND
        molga = '25'.

  LOOP AT emp_details.
    LOOP AT tmp_wage.
      LOOP AT temp_t510
        WHERE trfgr = emp_details-sal_code
        AND   trfst = emp_details-pay_scale
        AND   lgart = tmp_wage-wage.

        tmp_code-wage_type = temp_t510-lgart.
        tmp_code-amount = temp_t510-betrg.
        tmp_code-perno = emp_details-perno.

        APPEND tmp_code.
        CLEAR tmp_code.
      ENDLOOP.
    ENDLOOP.
  ENDLOOP.

* commented out by ytm on 03.10.2002
* replaced by the code above to speed up processing.

** modified by ncsup 13,Feb 2001
*  LOOP AT emp_details.
*    LOOP AT tmp_wage.
*      SELECT lgart betrg
*      FROM  t510
*      INTO (tmp_code-wage_type, tmp_code-amount)
*      WHERE trfgr = emp_details-sal_code AND
*            trfst = emp_details-pay_scale AND
*            lgart = tmp_wage-wage AND
**modified by ncsup on 19, April 2001
**begin of modification
**           endda >= rundtfinal AND
**           begda <= rundtfinal AND
** changed by tmyeo on 21/09/01
*           endda >= payroll_last_day AND
*           begda <= payroll_last_day AND
*           molga = '25'.
*
*        tmp_code-perno = emp_details-perno.
*        APPEND tmp_code.
*        CLEAR tmp_code.
*      ENDSELECT.
*    ENDLOOP.
*  ENDLOOP.

  LOOP AT emp_details.
    LOOP AT tmp_code WHERE perno = emp_details-perno AND wage_type =
*  '9S03'.  "Bernard 22 Feb 2010
   '0NPC'.
      emp_details-npc_count = 'Y'.
      MODIFY emp_details.
    ENDLOOP.
  ENDLOOP.

  LOOP AT emp_details.
    IF emp_details-npc_count = 'Y'.
      count = 1.
      LOOP AT tmp_code WHERE perno = emp_details-perno
*                         AND wage_type = '9S01'. " ting ting 28.04.2009
                                 AND wage_type = '0BAS'.
        tmpsal = tmp_code-amount.
      ENDLOOP.

      LOOP AT tmp_code WHERE perno = emp_details-perno
*                           AND wage_type = '9S02'." ting ting 28.04.2009
        AND wage_type = '0MVC'.
        tmpsal2 = tmp_code-amount.

      ENDLOOP.

      LOOP AT tmp_code WHERE perno = emp_details-perno
*                            AND wage_type = '9S03'." ting ting 28.04.2009
        AND wage_type = '0NPC'.
        tmpsal3 = tmp_code-amount.

      ENDLOOP.

      totaltmpsal = tmpsal + tmpsal2 + tmpsal3.
      emp_details-sal_point = totaltmpsal.

      MODIFY emp_details.

    ELSE.
      LOOP AT tmp_code WHERE perno = emp_details-perno
*                            AND wage_type = '9S01'. " ting ting 28.04.2009
        AND wage_type = '0BAS'.
        emp_details-sal_point = tmp_code-amount.

        MODIFY emp_details.

      ENDLOOP.
    ENDIF.
    CLEAR: tmpsal, tmpsal2, tmpsal2.
  ENDLOOP.
ENDFORM.                    "get_salpoint

************************************************************************
**Form write_header
************************************************************************
*
FORM write_header.                                          " using f.
  DATA: month TYPE n,
        count TYPE i.

  month =  sy-datum+4(2).
  count = 1.

  FORMAT COLOR COL_GROUP.
  FORMAT COLOR  COL_GROUP.
*  WRITE:/1  text-001 LEFT-JUSTIFIED,
*         5  text-002 LEFT-JUSTIFIED,
*        15  text-003 LEFT-JUSTIFIED,
*        41  text-012 LEFT-JUSTIFIED,                        "shift up
*        51  text-004 LEFT-JUSTIFIED,
*        56  text-005 LEFT-JUSTIFIED,
*        90  text-006 LEFT-JUSTIFIED,
*        105 text-007 LEFT-JUSTIFIED,
*        117 text-008 LEFT-JUSTIFIED,
*        132 text-023 LEFT-JUSTIFIED,
*        150 ''.
*
*  WRITE:/5  text-009 LEFT-JUSTIFIED,
*         15 text-010 LEFT-JUSTIFIED,
*         35 text-011 LEFT-JUSTIFIED,
*         41 text-025 LEFT-JUSTIFIED,
*         51 text-024 LEFT-JUSTIFIED,
*         67 text-014 LEFT-JUSTIFIED,
*         77 text-015 LEFT-JUSTIFIED,
*         90 text-016 LEFT-JUSTIFIED,
*         105 text-017 LEFT-JUSTIFIED,
*         117 text-018 LEFT-JUSTIFIED,
*         132 text-019 LEFT-JUSTIFIED,
*         150 ''.
*
*  WRITE:/5  'Org Unit' LEFT-JUSTIFIED,
*         51 'Personnel Group' LEFT-JUSTIFIED,
*         150 ''.

  WRITE:/1  TEXT-001 LEFT-JUSTIFIED,
         6  TEXT-002 LEFT-JUSTIFIED,
        16  TEXT-003 LEFT-JUSTIFIED,
        42  TEXT-012 LEFT-JUSTIFIED,                        "shift up
        52  TEXT-004 LEFT-JUSTIFIED,
        57  TEXT-005 LEFT-JUSTIFIED,
        91  TEXT-006 LEFT-JUSTIFIED,
        106 TEXT-007 LEFT-JUSTIFIED,
        118 TEXT-008 LEFT-JUSTIFIED,
        133 TEXT-023 LEFT-JUSTIFIED,
        161 ''.

  WRITE:/6  TEXT-009 LEFT-JUSTIFIED,
         16 TEXT-010 LEFT-JUSTIFIED,
         36 TEXT-011 LEFT-JUSTIFIED,
         42 TEXT-025 LEFT-JUSTIFIED,
         52 TEXT-024 LEFT-JUSTIFIED,

*start of inserting by ramesh on 08.12.2010.
         79 TEXT-014 LEFT-JUSTIFIED,
         89 TEXT-015 LEFT-JUSTIFIED,
         102 TEXT-016 LEFT-JUSTIFIED,
         117 TEXT-017 LEFT-JUSTIFIED,
         129 TEXT-018 LEFT-JUSTIFIED,
         144 TEXT-019 LEFT-JUSTIFIED,
         161 ''.
* *end of inserting by ramesh on 08.12.2010.


*Start of commenting by ramesh on 08.12.2010
*         68 text-014 LEFT-JUSTIFIED,
*         78 text-015 LEFT-JUSTIFIED,
*         91 text-016 LEFT-JUSTIFIED,
*         106 text-017 LEFT-JUSTIFIED,
*         118 text-018 LEFT-JUSTIFIED,
*         133 text-019 LEFT-JUSTIFIED,
*         151 ''.
* End of commenting by ramesh on 08.12.2010
  WRITE:/6  'Org Unit' LEFT-JUSTIFIED,
         52 'Personnel Group' LEFT-JUSTIFIED,
         161 ''.

  FORMAT COLOR OFF.

ENDFORM.                    "write_header

************************************************************************
** Write details to the list
************************************************************************
FORM write_details .
  DATA: c          TYPE i,
        d          TYPE i,
        total_pay  TYPE p DECIMALS 2, "total payment
        total_ded  TYPE p DECIMALS 2, "total deduction
        x          TYPE i VALUE '10',
        y          TYPE i VALUE '5',
        count      TYPE i,
        typedesc   TYPE p DECIMALS 2,
        tmpunit    LIKE emp_details-orgeh,
        tmpdesc    LIKE emp_details-org_desc,
        tmpcpf     LIKE emp_details-emp_cpfno,
        tmpcpf2    LIKE emp_details-emp_cpfno,
        tmppersa   LIKE emp_details-persarea,
        tmppayroll LIKE emp_details-pay_r_area,
        net_pay    TYPE p DECIMALS 2.

  DATA : lwa_ee_group       TYPE ty_ee_group, "CR-0000000739
         lwa_wt_gl_acc      TYPE ty_wt_gl_acc,
         lwa_py_cfg         TYPE zhrpy_py_cfg, "Paysheet Config table
         lwa_final_tab      TYPE ty_final_tab,
         lwa_final_tab1     TYPE ty_final_tab,
         lwa_final_tab2     TYPE ty_final_tab,
         lwa_final_sub_tot  TYPE ty_final_sub_tot,
         lwa_final_sub_tot1 TYPE ty_final_sub_tot,
         lwa_final_sub_tot2 TYPE ty_final_sub_tot,
         lwa_final_sub_tot3 TYPE ty_final_sub_tot,
         lwa_final_sub_tot4 TYPE ty_final_sub_tot,
         lwa_final_sub_tot5 TYPE ty_final_sub_tot,
         lwa_final_sub_tot6 TYPE ty_final_sub_tot,
         lwa_final_sub_tot7 TYPE ty_final_sub_tot,
         lwa_final_count    TYPE ty_final_count,
         lwa_month_i        TYPE t247,
         lwa_month_f        TYPE t247,
         lv_month           TYPE month,
         lv_temp            TYPE c,
         lv_sec_temp(2)     TYPE c,
         lv_lgart           TYPE lgart,
         lv_title           TYPE string.

*  FIELD-SYMBOLS : <fs_final_tab> TYPE ty_final_tab.

  count = 1. " counter for S/NO output display

  LOOP AT emp_details.

    CLEAR monthly_sal.

    LOOP AT itab_total
    WHERE pernr = emp_details-perno
*    AND   ( lgart = '9S01'
*    OR      lgart = '9S02'
*    OR      lgart = '9S03' ).
       AND   ( lgart = '0BAS'
    OR      lgart = '0MVC'
    OR      lgart = '0NPC' ).

      monthly_sal = monthly_sal + itab_total-total_wage.

    ENDLOOP.


    IF sy-subrc = 0.
      itab_total-total_wage = monthly_sal.
      itab_total-wage_desc = 'Monthly Salary'.

      itab_total-lgart = ' '.
      APPEND itab_total.
    ENDIF.

  ENDLOOP.


  " Ting Ting added CE00007684  -> Salary Point.


  DATA: gwa_pme01  TYPE pme01,
        gv_back    TYPE string,
        gwa_0001   TYPE p0001,
        gv_cpind   TYPE p0008-cpind,
        gt_pa0001  TYPE STANDARD TABLE OF pa0001,
        gwa_pa0001 TYPE pa0001,
        gt_pa0008  TYPE STANDARD TABLE OF pa0008,
        gwa_pa0008 TYPE pa0008,
        gt_t510    TYPE TABLE OF  t510,
        gwa_t510   TYPE t510.



  LOOP AT emp_details.

    CLEAR  gt_pa0001[].

    SELECT * FROM pa0001 INTO CORRESPONDING FIELDS OF TABLE gt_pa0001
    WHERE begda <= payroll_last_day
    AND endda >= payroll_last_day
    AND pernr = emp_details-perno.

    SORT gt_pa0001 BY endda DESCENDING begda DESCENDING.

    CLEAR gwa_pa0001.
    READ TABLE gt_pa0001 INTO gwa_pa0001 WITH KEY pernr = emp_details-perno.
    IF sy-subrc = 0.
*    LOOP AT p0001 WHERE begda <= payroll_last_day  AND endda >= payroll_last_day.

      gwa_pme01-bukrs = p0001-bukrs.
      gwa_pme01-werks = p0001-werks.
      gwa_pme01-btrtl = p0001-btrtl.
      gwa_pme01-persg = p0001-persg.
      gwa_pme01-persk = p0001-persk.
      gwa_pme01-molga = '25'.
      gwa_pme01-pernr = p0001-pernr.

      CALL FUNCTION 'HR_FEATURE_BACKFIELD'
        EXPORTING
          feature                     = 'TARIF'
          struc_content               = gwa_pme01
*         KIND_OF_ERROR               =
        IMPORTING
          back                        = gv_back
*     CHANGING
*         STATUS                      =
        EXCEPTIONS
          dummy                       = 1
          error_operation             = 2
          no_backvalue                = 3
          feature_not_generated       = 4
          invalid_sign_in_funid       = 5
          field_in_report_tab_in_pe03 = 6
          OTHERS                      = 7.
      IF sy-subrc <> 0.
*         MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
      ENDIF.

      IF gv_back CA 'T'.
        gv_cpind = 'T'.

        CLEAR gt_pa0008[].
        SELECT * FROM pa0008 INTO CORRESPONDING FIELDS OF TABLE gt_pa0008
       WHERE begda <= payroll_last_day
       AND endda >= payroll_last_day
       AND pernr = emp_details-perno.

        SORT gt_pa0008 BY endda DESCENDING begda DESCENDING.

        CLEAR gwa_pa0008.
        READ TABLE gt_pa0008 INTO gwa_pa0008 WITH KEY pernr = emp_details-perno.
        IF sy-subrc = 0.

          CLEAR  gt_t510[].
          SELECT * FROM t510 INTO CORRESPONDING FIELDS OF TABLE gt_t510
          WHERE molga = '25'
          AND trfar = gwa_pa0008-trfar
          AND trfgb = gwa_pa0008-trfgb
          AND trfgr = gwa_pa0008-trfgr
          AND trfst = gwa_pa0008-trfst.
          IF sy-subrc <> 0.
          ENDIF.

          CLEAR gwa_t510.
          CLEAR emp_details-sal_point.
          LOOP AT gt_t510 INTO gwa_t510 WHERE lgart = '0BAS'
                                      OR      lgart = '0MVC'
                                      OR      lgart = '0NPC' .
            emp_details-sal_point =  emp_details-sal_point + gwa_t510-betrg.

          ENDLOOP.
          IF sy-subrc <> 0.
            emp_details-sal_point = 0.
          ENDIF.

*          CLEAR  monthly_sal.
*          LOOP AT itab_total
* WHERE pernr = emp_details-perno
**    AND   ( lgart = '9S01'
**    OR      lgart = '9S02'
**    OR      lgart = '9S03' ).
*    AND   ( lgart = '0BAS'
* OR      lgart = '0MVC'
* OR      lgart = '0NPC' ).
*
*            monthly_sal = monthly_sal + itab_total-total_wage.
*
*          ENDLOOP.

*          IF sy-subrc = 0.
*            itab_total-total_wage = monthly_sal.
*            itab_total-wage_desc = 'Monthly Salary'.
*
*            itab_total-lgart = ' '.
*            APPEND itab_total.
*          ENDIF.

          emp_details-nex_salbar = gwa_pa0008-trfst.
          MODIFY emp_details.
        ELSE.
          emp_details-nex_salbar = ''.
          MODIFY emp_details.
        ENDIF.

*        LOOP AT itab_total
*  WHERE pernr = emp_details-perno
**    AND   ( lgart = '9S01'
**    OR      lgart = '9S02'
**    OR      lgart = '9S03' ).
*     AND   ( lgart = '0BAS'
*  OR      lgart = '0MVC'
*  OR      lgart = '0NPC' ).
*
*          monthly_sal = monthly_sal + itab_total-total_wage.
*
*        ENDLOOP.
*
*        IF sy-subrc = 0.
*          itab_total-total_wage = monthly_sal.
*          itab_total-wage_desc = 'Monthly Salary'.
*
*          itab_total-lgart = ' '.
*          APPEND itab_total.
*        ENDIF.


      ELSE.

        gv_cpind = 'S'.
*        itab_total-total_wage = 0.
*        itab_total-wage_desc = 'Monthly Salary'.
*
*        itab_total-lgart = ' '.
*        APPEND itab_total.

        emp_details-sal_point = 0.
        emp_details-nex_salbar = ''.
        MODIFY emp_details.
      ENDIF.

      EXIT.
    ENDIF.

  ENDLOOP.

  LOOP AT emp_details.
    READ TABLE itab_total WITH KEY pernr = emp_details-perno.
    IF sy-subrc = 0.
      SELECT SINGLE atext
      INTO emp_details-pay_r_area
      FROM t549t
      WHERE sprsl = sy-langu
      AND abkrs = itab_payroll-iabkrs.
      MODIFY emp_details.
    ENDIF.
  ENDLOOP.

*****************************************
* The program flow is modified to include
* subtotal, summary and final summary.
* The program will perform these sub-routines
* and then stop.
  IF compare = 'X'.
    PERFORM get_previous_payroll.
  ENDIF.
  PERFORM formatting TABLES emp_details.
  PERFORM wagetype_final_total.
*  PERFORM final_total."CR-0000000739 - Commented
*  PERFORM output_payment_summary.""CR-0000000739 - Commented
*"CR-0000000739


  LOOP AT it_py_cfg INTO lwa_py_cfg.
    ON CHANGE OF lwa_py_cfg-sec OR lwa_py_cfg-sub_sec.
      MOVE-CORRESPONDING lwa_py_cfg TO lwa_sec_details.
      APPEND lwa_sec_details TO it_sec_details.
      CLEAR : lwa_py_cfg,lwa_sec_details.
    ENDON.
  ENDLOOP.

*  MOVE fp_per+4(2) TO lv_month.
*  PERFORM final_count CHANGING lwa_final_count.

*  CALL FUNCTION 'IDWT_READ_MONTH_TEXT'
*    EXPORTING
*      langu = sy-langu
*      month = lv_month
*    IMPORTING
*      t247  = lwa_month_f.
*  MOVE in_per+4(2) TO lv_month.
*  CALL FUNCTION 'IDWT_READ_MONTH_TEXT'
*    EXPORTING
*      langu = sy-langu
*      month = lv_month
*    IMPORTING
*      t247  = lwa_month_i.
  DELETE ADJACENT DUPLICATES FROM it_sec_details COMPARING ALL FIELDS.
*WRITE : / sy-vline, 10 'COMPARATIVE PAYROLL SUMMARY FOR MONTH1 AND MONTH2 YYYY PAYROLL PROCESSING '
*  CLEAR : gwa_final_tab,lv_title.
*  CONCATENATE text-053 lwa_month_f-ltx 'AND' lwa_month_i-ltx in_per+0(4) text-054 INTO lv_title SEPARATED BY space.
**  WRITE : /5 text-053,lwa_month_f-ltx,'AND',lwa_month_i-ltx,in_per+0(4),text-054.
*  WRITE : /5 lv_title.
*  FORMAT COLOR COL_GROUP .
*  WRITE / sy-uline(224).
*  WRITE : / sy-vline,74 sy-vline,105 lwa_month_i-ltx, in_per+0(4),148 sy-vline,150 sy-vline,180 lwa_month_f-ltx, fp_per+0(4),224 sy-vline.
*  WRITE : / sy-vline,74 sy-vline,107 'GL: 143100',148 sy-vline,150 sy-vline,175 'GL: 143100',224 sy-vline.
*  WRITE : / sy-vline,74 sy-vline,75 text-052,148 sy-vline,150 sy-vline,151 text-052,224 sy-vline.
*  WRITE : / sy-vline,10 'WAGE '      ,54 'WAGE' ,66 'GL'      ,74 sy-vline,98 'TRAINER', 114 'CLERK-OF-WORKS', 135 '   TOTAL' ,148 sy-vline,
*        150 sy-vline,177 'TRAINER',194 'CLERK-OF-WORKS',215 'TOTAL',224 sy-vline.
*  WRITE : / sy-vline,10 'DESCRIPTION',54 'CODE' ,64 'ACCOUNT' ,74 sy-vline, 85 'PA' ,99 ' (TR)   ',115 '   (COW)'     , 133 '(Incl TR&COW)',148 sy-vline,
*        150 sy-vline,161 'PA',179 '(TR)',196 '(COW)',211 '(Incl TR&COW)',224 sy-vline.
*  WRITE : / sy-vline,74 sy-vline,86 '$',101 '$',120 '$',139 '$',148 sy-vline,150 sy-vline,162 '$',180 '$',198 '$',217 '$',224 sy-vline.
*  WRITE / sy-uline(224).
*  FORMAT COLOR OFF.
*Final report output,if no Comparison period is entered then display only the In period data otherwise display both periods data
  IF fp_per = '000000'.
    PERFORM write_output_inper.
  ELSE.
    PERFORM write_output.
  ENDIF.
*  LOOP AT it_sec_details INTO lwa_sec_details.
*    lv_temp = 'X'.
*
*    AT NEW main.
*      FORMAT INTENSIFIED ON.
*      CASE lwa_sec_details-main.
*        WHEN 'A'.
*          WRITE :/ sy-vline,5 'A',10 'EXPENDITURE OF MAMPOWER (EOM)',74 sy-vline,148 sy-vline,150 sy-vline,224 sy-vline.
*        WHEN 'B'.
*          WRITE :/ sy-vline,5 'B',10 'EXTERNAL ALLOWANCES (Deposit Account)',74 sy-vline,148 sy-vline,150 sy-vline,224 sy-vline.
*        WHEN 'C'.
*          WRITE :/ sy-vline,5 'C',10 'OTHER OPERATING EXPENDITURE (OOE)',74 sy-vline,148 sy-vline,150 sy-vline,224 sy-vline.
*        WHEN 'D'.
*          WRITE :/ sy-vline,5 'D',10 'SALARY RECOVERABLE',74 sy-vline,148 sy-vline,150 sy-vline,224 sy-vline.
*        WHEN 'E'.
*          WRITE :/ sy-vline,5 'E',10 'DEDUCTIONS',74 sy-vline,148 sy-vline,150 sy-vline,224 sy-vline.
*        WHEN 'F'.
*          NEW-LINE.
*          CLEAR lwa_final_sub_tot2.
*          LOOP AT it_final_sub_tot INTO lwa_final_sub_tot.
*            IF lwa_final_sub_tot-sub_total = 'A4_TOTAL' OR
*               lwa_final_sub_tot-sub_total = 'B1' OR
*               lwa_final_sub_tot-sub_total = 'C_TOTAL' OR
*               lwa_final_sub_tot-sub_total = 'D1'.
*              lwa_final_sub_tot2-total_wage_pa  = lwa_final_sub_tot2-total_wage_pa  + lwa_final_sub_tot-total_wage_pa.
*              lwa_final_sub_tot2-total_wage_tr  = lwa_final_sub_tot2-total_wage_tr  + lwa_final_sub_tot-total_wage_tr.
*              lwa_final_sub_tot2-total_wage_cow = lwa_final_sub_tot2-total_wage_cow + lwa_final_sub_tot-total_wage_cow.
*              lwa_final_sub_tot2-total_wage     = lwa_final_sub_tot2-total_wage     + lwa_final_sub_tot-total_wage.
*
*              lwa_final_sub_tot2-total_wage_pa1  = lwa_final_sub_tot2-total_wage_pa1  + lwa_final_sub_tot-total_wage_pa1.
*              lwa_final_sub_tot2-total_wage_tr1  = lwa_final_sub_tot2-total_wage_tr1  + lwa_final_sub_tot-total_wage_tr1.
*              lwa_final_sub_tot2-total_wage_cow1 = lwa_final_sub_tot2-total_wage_cow1 + lwa_final_sub_tot-total_wage_cow1.
*              lwa_final_sub_tot2-total_wage1     = lwa_final_sub_tot2-total_wage1     + lwa_final_sub_tot-total_wage1.
*
*            ELSEIF lwa_final_sub_tot-sub_total = 'E1' OR
*                   lwa_final_sub_tot-sub_total = 'E2'.
*              lwa_final_sub_tot3-total_wage_pa  = lwa_final_sub_tot3-total_wage_pa  + lwa_final_sub_tot-total_wage_pa.
*              lwa_final_sub_tot3-total_wage_tr  = lwa_final_sub_tot3-total_wage_tr  + lwa_final_sub_tot-total_wage_tr.
*              lwa_final_sub_tot3-total_wage_cow = lwa_final_sub_tot3-total_wage_cow + lwa_final_sub_tot-total_wage_cow.
*              lwa_final_sub_tot3-total_wage     = lwa_final_sub_tot3-total_wage     + lwa_final_sub_tot-total_wage.
*
*              lwa_final_sub_tot3-total_wage_pa1  = lwa_final_sub_tot3-total_wage_pa1  + lwa_final_sub_tot-total_wage_pa1.
*              lwa_final_sub_tot3-total_wage_tr1  = lwa_final_sub_tot3-total_wage_tr1  + lwa_final_sub_tot-total_wage_tr1.
*              lwa_final_sub_tot3-total_wage_cow1 = lwa_final_sub_tot3-total_wage_cow1 + lwa_final_sub_tot-total_wage_cow1.
*              lwa_final_sub_tot3-total_wage1     = lwa_final_sub_tot3-total_wage1     + lwa_final_sub_tot-total_wage1.
*
*            ENDIF.
*          ENDLOOP.
**TOTAL NET PAYMENT = TOTAL PAYMENTS (A1 TO A4, B, C and D) - TOTAL DEDUCTIONS (E1 TO E2)
*          lwa_final_sub_tot4-total_wage_pa  = lwa_final_sub_tot2-total_wage_pa  - lwa_final_sub_tot3-total_wage_pa.
*          lwa_final_sub_tot4-total_wage_tr  = lwa_final_sub_tot2-total_wage_tr  - lwa_final_sub_tot3-total_wage_tr.
*          lwa_final_sub_tot4-total_wage_cow = lwa_final_sub_tot2-total_wage_cow - lwa_final_sub_tot3-total_wage_cow.
*          lwa_final_sub_tot4-total_wage     = lwa_final_sub_tot2-total_wage     - lwa_final_sub_tot3-total_wage.
*
*          lwa_final_sub_tot4-total_wage_pa1  = lwa_final_sub_tot2-total_wage_pa1  - lwa_final_sub_tot3-total_wage_pa1.
*          lwa_final_sub_tot4-total_wage_tr1  = lwa_final_sub_tot2-total_wage_tr1  - lwa_final_sub_tot3-total_wage_tr1.
*          lwa_final_sub_tot4-total_wage_cow1 = lwa_final_sub_tot2-total_wage_cow1 - lwa_final_sub_tot3-total_wage_cow1.
*          lwa_final_sub_tot4-total_wage1     = lwa_final_sub_tot2-total_wage1     - lwa_final_sub_tot3-total_wage1.
*
*          WRITE :/ sy-vline,
*                   12 'TOTAL PAYMENTS (A1 TO A4, B, C and D)',
*                   74 sy-vline,
*                   75 lwa_final_sub_tot2-total_wage_pa,
*                   93 lwa_final_sub_tot2-total_wage_tr,
*                  110 lwa_final_sub_tot2-total_wage_cow,
*                  130 lwa_final_sub_tot2-total_wage,
*                  148 sy-vline,
*                  150 sy-vline,
*                  151 lwa_final_sub_tot2-total_wage_pa1,
*                  169 lwa_final_sub_tot2-total_wage_tr1,
*                  186 lwa_final_sub_tot2-total_wage_cow1,
*                  206 lwa_final_sub_tot2-total_wage1,
*                  224 sy-vline.
*          WRITE :/ sy-vline,
*                   12 'TOTAL DEDUCTIONS (E1 TO E2)',
*                   74 sy-vline,
*                   75 lwa_final_sub_tot3-total_wage_pa,
*                   93 lwa_final_sub_tot3-total_wage_tr,
*                  110 lwa_final_sub_tot3-total_wage_cow,
*                  130 lwa_final_sub_tot3-total_wage,
*                  148 sy-vline,
*                  150 sy-vline,
*                  151 lwa_final_sub_tot3-total_wage_pa1,
*                  169 lwa_final_sub_tot3-total_wage_tr1,
*                  186 lwa_final_sub_tot3-total_wage_cow1,
*                  206 lwa_final_sub_tot3-total_wage1,
*                  224 sy-vline.
*          WRITE :/ sy-vline,
*                   12 'TOTAL NET PAYMENT',
*                   74 sy-vline,
*                   75 lwa_final_sub_tot4-total_wage_pa,
*                   93 lwa_final_sub_tot4-total_wage_tr,
*                  110 lwa_final_sub_tot4-total_wage_cow,
*                  130 lwa_final_sub_tot4-total_wage,
*                  148 sy-vline,
*                  150 sy-vline,
*                  151 lwa_final_sub_tot4-total_wage_pa1,
*                  169 lwa_final_sub_tot4-total_wage_tr1,
*                  186 lwa_final_sub_tot4-total_wage_cow1,
*                  206 lwa_final_sub_tot4-total_wage1,
*                  224 sy-vline.
*          NEW-LINE.
*          WRITE :/ sy-vline,10 'PAYMENT VIA:',74 sy-vline,148 sy-vline,150 sy-vline,224 sy-vline.
**Bank Transfer
*          CLEAR lwa_final_tab.
*          LOOP AT it_final_tab INTO lwa_final_tab WHERE lgart = '/559'.
*            lwa_final_tab1-total_wage_pa  = lwa_final_tab1-total_wage_pa  + lwa_final_tab-total_wage_pa.
*            lwa_final_tab1-total_wage_tr  = lwa_final_tab1-total_wage_tr  + lwa_final_tab-total_wage_tr.
*            lwa_final_tab1-total_wage_cow = lwa_final_tab1-total_wage_cow + lwa_final_tab-total_wage_cow.
*            lwa_final_tab1-total_wage     = lwa_final_tab1-total_wage     + lwa_final_tab-total_wage.
*
*            lwa_final_tab1-total_wage_pa1  = lwa_final_tab1-total_wage_pa1  + lwa_final_tab-total_wage_pa1.
*            lwa_final_tab1-total_wage_tr1  = lwa_final_tab1-total_wage_tr1  + lwa_final_tab-total_wage_tr1.
*            lwa_final_tab1-total_wage_cow1 = lwa_final_tab1-total_wage_cow1 + lwa_final_tab-total_wage_cow1.
*            lwa_final_tab1-total_wage1     = lwa_final_tab1-total_wage1     + lwa_final_tab-total_wage1.
*          ENDLOOP.
*          WRITE :/ sy-vline,
*                   12 'BANK',
*                   65 '145017',
*                   74 sy-vline,
*                   75 lwa_final_tab1-total_wage_pa,
*                   93 lwa_final_tab1-total_wage_tr,
*                  110 lwa_final_tab1-total_wage_cow,
*                  130 lwa_final_tab1-total_wage,
*                  148 sy-vline,"66 total_bank_transfer
*                  150 sy-vline,
*                  151 lwa_final_tab1-total_wage_pa1,
*                  169 lwa_final_tab1-total_wage_tr1,
*                  186 lwa_final_tab1-total_wage_cow1,
*                  206 lwa_final_tab1-total_wage1,
*                  224 sy-vline.
**Cash Payment
*          CLEAR lwa_final_tab.
*          LOOP AT it_final_tab INTO lwa_final_tab WHERE lgart = '/557'.
*            lwa_final_tab2-total_wage_pa  = lwa_final_tab2-total_wage_pa  + lwa_final_tab-total_wage_pa.
*            lwa_final_tab2-total_wage_tr  = lwa_final_tab2-total_wage_tr  + lwa_final_tab-total_wage_tr.
*            lwa_final_tab2-total_wage_cow = lwa_final_tab2-total_wage_cow + lwa_final_tab-total_wage_cow.
*            lwa_final_tab2-total_wage     = lwa_final_tab2-total_wage     + lwa_final_tab-total_wage.
*
*            lwa_final_tab2-total_wage_pa1  = lwa_final_tab2-total_wage_pa1  + lwa_final_tab-total_wage_pa1.
*            lwa_final_tab2-total_wage_tr1  = lwa_final_tab2-total_wage_tr1  + lwa_final_tab-total_wage_tr1.
*            lwa_final_tab2-total_wage_cow1 = lwa_final_tab2-total_wage_cow1 + lwa_final_tab-total_wage_cow1.
*            lwa_final_tab2-total_wage1     = lwa_final_tab2-total_wage1     + lwa_final_tab-total_wage1.
*          ENDLOOP.
*          WRITE :/ sy-vline,
*                   12 'CHEQUE',
*                   65 '145210',
*                   74 sy-vline,
*                   75 lwa_final_tab2-total_wage_pa,
*                   93 lwa_final_tab2-total_wage_tr,
*                  110 lwa_final_tab2-total_wage_cow,
*                  130 lwa_final_tab2-total_wage,
*                  148 sy-vline,"66 total_cash_payment,
*                  150 sy-vline,
*                  151 lwa_final_tab2-total_wage_pa1,
*                  169 lwa_final_tab2-total_wage_tr1,
*                  186 lwa_final_tab2-total_wage_cow1,
*                  206 lwa_final_tab2-total_wage1,
*                  224 sy-vline.
*
*          WRITE : / sy-uline(224).
*          WRITE : / sy-vline,5 'F',10 'TOTAL COUNT OF STAFF PAID IN THE MONTH ',224 sy-vline.
*          FORMAT INTENSIFIED OFF.
*          WRITE : / sy-vline,224 sy-vline.
*          WRITE : / sy-vline,5 '1',10 'PAYMENT TO STAFF VIA IBG', 77 lwa_month_i-ltx NO-GAP,in_per+0(4) LEFT-JUSTIFIED NO-GAP,'(In-Month)',
*                    152 lwa_month_f-ltx NO-GAP,fp_per+0(4) LEFT-JUSTIFIED NO-GAP,'(For-Month)',224 sy-vline.
*          WRITE : / sy-vline, 24 'PERMANENT',     70 lwa_final_count-pymnt_ibg_pa, 150 lwa_final_count-pymnt_ibg_pa1, 224 sy-vline.
*          WRITE : / sy-vline, 24 'CLERK-OF-WORKS',70 lwa_final_count-pymnt_ibg_cow,150 lwa_final_count-pymnt_ibg_cow1,224 sy-vline.
*          WRITE : / sy-vline, 24 'TRAINERS',      70 lwa_final_count-pymnt_ibg_tr, 150 lwa_final_count-pymnt_ibg_tr1, 224 sy-vline.
*          WRITE : / sy-vline, 77 text-055,157 text-055,224 sy-vline.
*          WRITE : / sy-vline, 70 lwa_final_count-tot_ibg,150 lwa_final_count-tot_ibg1,224 sy-vline.
*          WRITE : / sy-vline, 77 text-055,157 text-055,224 sy-vline.
*          WRITE : / sy-vline,224 sy-vline.
*          WRITE : / sy-vline, 5 '2',10 'PAYMENT TO STAFF VIA CHEQUE',224 sy-vline.
*          WRITE : / sy-vline, 24 'PERMANENT',     70 lwa_final_count-pymnt_chq_pa,  150 lwa_final_count-pymnt_chq_pa1, 224 sy-vline.
*          WRITE : / sy-vline, 24 'CLERK-OF-WORKS',70 lwa_final_count-pymnt_chq_cow, 150 lwa_final_count-pymnt_chq_cow1,224 sy-vline.
*          WRITE : / sy-vline, 77 text-055,157 text-055,224 sy-vline.
*          WRITE : / sy-vline, 70 lwa_final_count-tot_chq,150 lwa_final_count-tot_chq1,224 sy-vline.
*          WRITE : / sy-vline, 77 text-055,157 text-055,224 sy-vline.
*
*          WRITE : / sy-vline,224 sy-vline.
*          WRITE : / sy-vline,5 '3',10 'TOTAL PAYOUT COUNT FOR PERMANENT STAFF EXCLUDING COW AND TR',224 sy-vline.
*          WRITE : / sy-vline, 24 'ACTUAL PAYOUT TO ACTIVE STAFF',
*                              70 lwa_final_count-pymnt_ibg_pa,150 lwa_final_count-pymnt_ibg_pa1,224 sy-vline.
*          WRITE : / sy-vline, 24 'ADD: STAFF LEAVING IN PAYROLL MONTH (CHEQUE)',
*                              70 lwa_final_count-pymnt_chq_pa,  150 lwa_final_count-pymnt_chq_pa1,224 sy-vline.
*          WRITE : / sy-vline, 77 text-055,157 text-055,224 sy-vline.
*          WRITE : / sy-vline, 70 lwa_final_count-tot_pa,150 lwa_final_count-tot_pa1,224 sy-vline.
*          WRITE : / sy-vline, 77 text-055,157 text-055,224 sy-vline.
*
*          WRITE : / sy-vline,5 '4',10 'TOTAL PAYOUT COUNT FOR THE MONTH (F1 TO F2)',
*                           70 lwa_final_count-tot_count,150 lwa_final_count-tot_count1,224 sy-vline.
*          WRITE : / sy-vline,224 sy-vline.
*          EXIT.
*      ENDCASE.
*    ENDAT.
*
*    ON CHANGE OF lwa_sec_details-sec." or lwa_Sec_Details-sub_sec.
*      FORMAT INTENSIFIED ON.
*      CASE lwa_sec_details-main.
*        WHEN 'A'.
*          CASE lwa_sec_details-sec .
*            WHEN '01'.
*              WRITE :/ sy-vline,10 lwa_sec_details-sec,'SALARIES:',74 sy-vline,148 sy-vline,150 sy-vline,224 sy-vline.
*            WHEN '02'.
*              WRITE :/ sy-vline,10 lwa_sec_details-sec,'BONUS',74 sy-vline,148 sy-vline,150 sy-vline,224 sy-vline.
**            WHEN '03'.
**              WRITE :/ sy-vline,10 lwa_sec_details-sec,'GRATUITY',148 sy-vline.
*            WHEN '04'.
*              WRITE :/ sy-vline,10 lwa_sec_details-sec,'ALLOWANCES:',74 sy-vline,148 sy-vline,150 sy-vline,224 sy-vline.
*            WHEN '05'.
*              WRITE :/ sy-vline,10 lwa_sec_details-sec,'EMPLOYER (E','YER',') STATUTORY CONTRIBUTION',74 sy-vline,148 sy-vline,150 sy-vline,224 sy-vline.
*          ENDCASE.
*        WHEN 'C'.
*          CASE lwa_sec_details-sec .
*            WHEN '01'.
*              WRITE :/ sy-vline,10 lwa_sec_details-sec,'AWARDS',74 sy-vline,148 sy-vline,150 sy-vline,224 sy-vline.
*            WHEN '02'.
*              WRITE :/ sy-vline,10 lwa_sec_details-sec,'ESS CLAIMS',74 sy-vline,148 sy-vline,150 sy-vline,224 sy-vline.
*          ENDCASE.
*        WHEN 'E'.
*          CASE lwa_sec_details-sec .
*            WHEN '01'.
*              WRITE :/ sy-vline,10 lwa_sec_details-sec,'EMPLOYEE (E','YEE)', 'CPF',74 sy-vline,148 sy-vline,150 sy-vline,224 sy-vline.
*            WHEN '02'.
*              WRITE :/ sy-vline,10 lwa_sec_details-sec,'OTHER STAFF DEDUCTIONS',74 sy-vline,148 sy-vline,150 sy-vline,224 sy-vline.
*          ENDCASE.
*      ENDCASE.
*      FORMAT INTENSIFIED OFF.
*    ENDON.
*    CLEAR lv_sec_temp.
*    lv_sec_temp = lwa_sec_details-sec.
*    LOOP AT it_py_cfg INTO lwa_py_cfg WHERE main EQ lwa_sec_details-main AND
*                                             sec EQ lwa_sec_details-sec  AND
*                                         sub_sec EQ lwa_sec_details-sub_sec.
*      IF lv_temp EQ 'X'.
*        FORMAT INTENSIFIED ON.
*        CASE lwa_sec_details-main.
*          WHEN 'A'.
*            CASE lwa_sec_details-sub_sec.
*              WHEN '01'.
*                WRITE :/ sy-vline,10 'a) RECURRING ALLOWANCES',74 sy-vline,148 sy-vline,150 sy-vline,224 sy-vline.
*                CLEAR lv_temp.
*              WHEN '02'.
*                WRITE :/ sy-vline,10 'b)  ADDITIONAL/ONE TIME ALLOWANCE',74 sy-vline,148 sy-vline,150 sy-vline,224 sy-vline.
*                CLEAR lv_temp.
*              WHEN '03'.
*                WRITE :/ sy-vline,10 'c) OVERTIME ALLOWANCE',74 sy-vline,148 sy-vline,150 sy-vline,224 sy-vline.
*                CLEAR lv_temp.
*              WHEN '04'.
*                WRITE :/ sy-vline,10 'd) TRAINER HONARARIUM CLAIMS',74 sy-vline,148 sy-vline,150 sy-vline,224 sy-vline.
*                CLEAR lv_temp.
*              WHEN OTHERS.
*                CLEAR lv_temp.
*            ENDCASE.
*          WHEN 'C'.
*            CASE lwa_sec_details-sec.
*              WHEN '1'.
*                WRITE :/ sy-vline,10 lwa_sec_details-sec,'AWARDS',74 sy-vline,148 sy-vline,150 sy-vline,224 sy-vline.
*                CLEAR lv_temp.
*              WHEN '2'.
*                CASE lwa_sec_details-sub_sec.
*                  WHEN '01'.
*                    WRITE :/ sy-vline,10 'STAFF DEVELOPMENT AND BENEFITS (OFI1)',74 sy-vline,148 sy-vline,150 sy-vline,224 sy-vline.
*                    CLEAR lv_temp.
*                  WHEN '02'.
*                    WRITE :/ sy-vline,10 'REPAIR & MAINTENANCE (OFI2)',74 sy-vline,148 sy-vline,150 sy-vline,224 sy-vline.
*                    CLEAR lv_temp.
*                  WHEN '03'.
*                    WRITE :/ sy-vline,10 'SUPPLIES AND MATERIALS (OFI4)',74 sy-vline,148 sy-vline,150 sy-vline,224 sy-vline.
*                    CLEAR lv_temp.
*                  WHEN '04'.
*                    WRITE :/ sy-vline,10 'COMMUNICATION (OFI3)',74 sy-vline,148 sy-vline,150 sy-vline,224 sy-vline.
*                    CLEAR lv_temp.
*                  WHEN '05'.
*                    WRITE :/ sy-vline,10 'TRANSPORTATION (OTRT)',74 sy-vline,148 sy-vline,150 sy-vline,224 sy-vline.
*                    CLEAR lv_temp.
*                  WHEN '06'.
*                    WRITE :/ sy-vline,10 'OTHER EXPENSES (OFI5)',74 sy-vline,148 sy-vline,150 sy-vline,224 sy-vline.
*                    CLEAR lv_temp.
*                  WHEN '07'.
*                    WRITE :/ sy-vline,10 'ADMINISTRATIVE EXPENSES (OFI6)',74 sy-vline,148 sy-vline,150 sy-vline,224 sy-vline.
*                    CLEAR lv_temp.
*                  WHEN '08'.
*                    WRITE :/ sy-vline,10 'SUPPLIES AND MATERIALS (OFI8)',74 sy-vline,148 sy-vline,150 sy-vline,224 sy-vline.
*                    CLEAR lv_temp.
*                  WHEN '09'.
*                    WRITE :/ sy-vline,10 'ACTIVITY & PROJECTS (OFI9)',74 sy-vline,148 sy-vline,150 sy-vline,224 sy-vline.
*                    CLEAR lv_temp.
*                ENDCASE.
*            ENDCASE.
*          WHEN 'E'.
*            CASE lwa_sec_details-sec.
*              WHEN '1'.
*                WRITE :/ sy-vline,10 lwa_sec_details-sec,'EMPLOYEE (E','YEE)',' CPF',74 sy-vline,148 sy-vline,150 sy-vline,224 sy-vline.
*                CLEAR lv_temp.
*            ENDCASE.
*        ENDCASE.
*        FORMAT INTENSIFIED OFF.
*      ENDIF.
*      SORT it_final_tab BY lgart.
*      CLEAR gwa_final_tab.
*      READ TABLE it_final_tab INTO gwa_final_tab WITH KEY lgart = lwa_py_cfg-lgart ."BINARY SEARCH.
*      IF sy-subrc EQ 0.
*        LOOP AT it_final_tab INTO gwa_final_tab WHERE lgart = lwa_py_cfg-lgart .
*          IF lv_lgart EQ gwa_final_tab-lgart.
*            CLEAR gwa_final_tab-lgtxt.
*          ELSE.
*            lv_lgart = gwa_final_tab-lgart.
*            gwa_final_tab-lgtxt = lwa_py_cfg-description.
*          ENDIF.
*          lwa_final_sub_tot-total_wage_pa  = lwa_final_sub_tot-total_wage_pa  + gwa_final_tab-total_wage_pa.
*          lwa_final_sub_tot-total_wage_tr  = lwa_final_sub_tot-total_wage_tr  + gwa_final_tab-total_wage_tr.
*          lwa_final_sub_tot-total_wage_cow = lwa_final_sub_tot-total_wage_cow + gwa_final_tab-total_wage_cow.
*          lwa_final_sub_tot-total_wage     = lwa_final_sub_tot-total_wage     + gwa_final_tab-total_wage.
*
*          lwa_final_sub_tot-total_wage_pa1  = lwa_final_sub_tot-total_wage_pa1  + gwa_final_tab-total_wage_pa1.
*          lwa_final_sub_tot-total_wage_tr1  = lwa_final_sub_tot-total_wage_tr1  + gwa_final_tab-total_wage_tr1.
*          lwa_final_sub_tot-total_wage_cow1 = lwa_final_sub_tot-total_wage_cow1 + gwa_final_tab-total_wage_cow1.
*          lwa_final_sub_tot-total_wage1     = lwa_final_sub_tot-total_wage1     + gwa_final_tab-total_wage1.
*
*          IF lwa_sec_details-main EQ 'A' AND lwa_sec_details-sec EQ '03'.
*            WRITE :/ sy-vline.
*            FORMAT COLOR = 4.
*            FORMAT INTENSIFIED ON.
*            WRITE : 10  '03 GRATUITY         (A3)',
*                    55 gwa_final_tab-lgart,
*                    65 gwa_final_tab-acct,
*                    74 sy-vline,
*                    75 lwa_final_sub_tot-total_wage_pa,
*                    93 lwa_final_sub_tot-total_wage_tr,
*                   110 lwa_final_sub_tot-total_wage_cow,
*                   130 lwa_final_sub_tot-total_wage,
*                   148 sy-vline,
*                   150 sy-vline,
*                   151 lwa_final_sub_tot-total_wage_pa1,
*                   169 lwa_final_sub_tot-total_wage_tr1,
*                   189 lwa_final_sub_tot-total_wage_cow1,
*                   206 lwa_final_sub_tot-total_wage1,
*                   224 sy-vline.
*
*            FORMAT COLOR = 0.
*            FORMAT INTENSIFIED OFF.
*            CONCATENATE lwa_sec_details-main lv_sec_temp+1(1) INTO lwa_final_sub_tot-sub_total.
*            APPEND lwa_final_sub_tot TO it_final_sub_tot.
*            CLEAR lwa_final_sub_tot.
*          ELSEIF lwa_sec_details-main EQ 'C' AND lwa_sec_details-sec EQ '02'. "do nothing
*            lwa_final_sub_tot7-total_wage_pa  = lwa_final_sub_tot7-total_wage_pa  + gwa_final_tab-total_wage_pa.
*            lwa_final_sub_tot7-total_wage_tr  = lwa_final_sub_tot7-total_wage_tr  + gwa_final_tab-total_wage_tr.
*            lwa_final_sub_tot7-total_wage_cow = lwa_final_sub_tot7-total_wage_cow + gwa_final_tab-total_wage_cow.
*            lwa_final_sub_tot7-total_wage     = lwa_final_sub_tot7-total_wage     + gwa_final_tab-total_wage.
*
*            lwa_final_sub_tot7-total_wage_pa1  = lwa_final_sub_tot7-total_wage_pa1  + gwa_final_tab-total_wage_pa1.
*            lwa_final_sub_tot7-total_wage_tr1  = lwa_final_sub_tot7-total_wage_tr1  + gwa_final_tab-total_wage_tr1.
*            lwa_final_sub_tot7-total_wage_cow1 = lwa_final_sub_tot7-total_wage_cow1 + gwa_final_tab-total_wage_cow1.
*            lwa_final_sub_tot7-total_wage1     = lwa_final_sub_tot7-total_wage1     + gwa_final_tab-total_wage1.
*
**            gwa_final_tab-lgtxt = lwa_py_cfg-description.
*            PERFORM write_data USING gwa_final_tab.
*          ELSE.
**            gwa_final_tab-lgtxt = lwa_py_cfg-description.
*            PERFORM write_data USING gwa_final_tab.
*          ENDIF.
*        ENDLOOP.
*      ELSE.
*        CLEAR lwa_wt_gl_acc.
*        READ TABLE it_wt_gl_acc INTO lwa_wt_gl_acc WITH KEY lgart = lwa_py_cfg-lgart.
*        IF lwa_sec_details-main EQ 'A' AND lwa_sec_details-sec EQ '03'.
*          WRITE :/ sy-vline.
*          FORMAT COLOR = 4.
*          FORMAT INTENSIFIED ON.
*          WRITE : 10   '03 GRATUITY         (A3)',
*                  55 lwa_py_cfg-lgart,
*                  65 lwa_wt_gl_acc-acct,
*                  74 sy-vline,
*                  75 lwa_final_sub_tot-total_wage_pa,
*                  93 lwa_final_sub_tot-total_wage_tr,
*                 110 lwa_final_sub_tot-total_wage_cow,
*                 130 lwa_final_sub_tot-total_wage,
*                 148 sy-vline,
*                 150 sy-vline,
*                 151 lwa_final_sub_tot-total_wage_pa1,
*                 169 lwa_final_sub_tot-total_wage_tr1,
*                 186 lwa_final_sub_tot-total_wage_cow1,
*                 206 lwa_final_sub_tot-total_wage1,
*                 224 sy-vline.
*          FORMAT COLOR = 0.
*          FORMAT INTENSIFIED OFF.
*          CONCATENATE lwa_sec_details-main lv_sec_temp+1(1) INTO lwa_final_sub_tot-sub_total.
*          APPEND lwa_final_sub_tot TO it_final_sub_tot.
*          CLEAR lwa_final_sub_tot.
*        ELSE.
*          WRITE :/ sy-vline,
*                  12 lwa_py_cfg-description,
*                  55 lwa_py_cfg-lgart,
*                  65 lwa_wt_gl_acc-acct,
*                  74 sy-vline,
*                 148 sy-vline,
*                 150 sy-vline,
*                 224 sy-vline.
*        ENDIF.
*      ENDIF.
*    ENDLOOP.
*    CONCATENATE lwa_sec_details-main lv_sec_temp+1(1) INTO lwa_final_sub_tot-sub_total.
*    IF lwa_sec_details-main EQ 'A' AND lwa_sec_details-sec EQ '03'.
**do nothing,already A3 subtotal added
*    ELSEIF lwa_sec_details-main EQ 'A' AND lwa_sec_details-sec EQ '04' AND lwa_sec_details-sub_sec LE '04'.
*      FORMAT COLOR = 4.
*      WRITE :/ sy-vline,
*            74 sy-vline,
*            75 lwa_final_sub_tot-total_wage_pa,
*            93 lwa_final_sub_tot-total_wage_tr,
*           110 lwa_final_sub_tot-total_wage_cow,
*           130 lwa_final_sub_tot-total_wage,
*           148 sy-vline,
*           150 sy-vline,
*           151 lwa_final_sub_tot-total_wage_pa1,
*           169 lwa_final_sub_tot-total_wage_tr1,
*           186 lwa_final_sub_tot-total_wage_cow1,
*           206 lwa_final_sub_tot-total_wage1,
*           224 sy-vline.
*      FORMAT COLOR = 0.
*
*      APPEND lwa_final_sub_tot TO it_final_sub_tot.
*      CLEAR lwa_final_sub_tot.
*      IF lwa_sec_details-sub_sec EQ '04'.
*        FORMAT COLOR = 4.
*        CLEAR lwa_final_sub_tot6.
*        LOOP AT it_final_sub_tot INTO lwa_final_sub_tot.
*          IF lwa_final_sub_tot-sub_total EQ 'A4'.
*            lwa_final_sub_tot6-total_wage_pa  = lwa_final_sub_tot6-total_wage_pa  + lwa_final_sub_tot-total_wage_pa.
*            lwa_final_sub_tot6-total_wage_tr  = lwa_final_sub_tot6-total_wage_tr  + lwa_final_sub_tot-total_wage_tr.
*            lwa_final_sub_tot6-total_wage_cow = lwa_final_sub_tot6-total_wage_cow + lwa_final_sub_tot-total_wage_cow.
*            lwa_final_sub_tot6-total_wage     = lwa_final_sub_tot6-total_wage     + lwa_final_sub_tot-total_wage.
*
*            lwa_final_sub_tot6-total_wage_pa1  = lwa_final_sub_tot6-total_wage_pa1  + lwa_final_sub_tot-total_wage_pa1.
*            lwa_final_sub_tot6-total_wage_tr1  = lwa_final_sub_tot6-total_wage_tr1  + lwa_final_sub_tot-total_wage_tr1.
*            lwa_final_sub_tot6-total_wage_cow1 = lwa_final_sub_tot6-total_wage_cow1 + lwa_final_sub_tot-total_wage_cow1.
*            lwa_final_sub_tot6-total_wage1     = lwa_final_sub_tot6-total_wage1     + lwa_final_sub_tot-total_wage1.
*
*          ENDIF.
*          AT LAST.
*            SUM.
*            WRITE :/ sy-vline,
*                  30 'SUB-TOTAL(', 'A4 )',
*                  74 sy-vline,
*                  75 lwa_final_sub_tot6-total_wage_pa,
*                  93 lwa_final_sub_tot6-total_wage_tr,
*                 110 lwa_final_sub_tot6-total_wage_cow,
*                 130 lwa_final_sub_tot6-total_wage,
*                 148 sy-vline,
*                 150 sy-vline,
*                 151 lwa_final_sub_tot6-total_wage_pa1,
*                 169 lwa_final_sub_tot6-total_wage_tr1,
*                 186 lwa_final_sub_tot6-total_wage_cow1,
*                 206 lwa_final_sub_tot6-total_wage1,
*                 224 sy-vline.
*            FORMAT COLOR = 0.
*            lwa_final_sub_tot-sub_total = 'A4_TOTAL'.
*            FORMAT COLOR = 4.
*            FORMAT INTENSIFIED ON.
*            WRITE :/ sy-vline,
*                          12 'TOTAL SALARIES & WAGES ,BONUS and ALLOWANCES (A1 TO A4)',
*                          74 sy-vline,
*                          75 lwa_final_sub_tot-total_wage_pa,
*                          93 lwa_final_sub_tot-total_wage_tr,
*                         110 lwa_final_sub_tot-total_wage_cow,
*                         130 lwa_final_sub_tot-total_wage,
*                         148 sy-vline,
*                         150 sy-vline,
*                         151 lwa_final_sub_tot-total_wage_pa1,
*                         169 lwa_final_sub_tot-total_wage_tr1,
*                         186 lwa_final_sub_tot-total_wage_cow1,
*                         206 lwa_final_sub_tot-total_wage1,
*                         224 sy-vline.
*            FORMAT INTENSIFIED OFF.
*            FORMAT COLOR = 0.
*            APPEND lwa_final_sub_tot TO it_final_sub_tot.
*            CLEAR lwa_final_sub_tot.
*            EXIT.
*          ENDAT.
*        ENDLOOP.
*      ENDIF.
*    ELSEIF lwa_sec_details-main EQ 'A' AND lwa_sec_details-sec EQ '05'.
*      lwa_final_sub_tot-total_wage_pa  = lwa_final_sub_tot-total_wage_pa  + gwa_final_tab-total_wage_pa.
*      lwa_final_sub_tot-total_wage_tr  = lwa_final_sub_tot-total_wage_tr  + gwa_final_tab-total_wage_tr.
*      lwa_final_sub_tot-total_wage_cow = lwa_final_sub_tot-total_wage_cow + gwa_final_tab-total_wage_cow.
*      lwa_final_sub_tot-total_wage     = lwa_final_sub_tot-total_wage     + gwa_final_tab-total_wage.
*
*      lwa_final_sub_tot-total_wage_pa1  = lwa_final_sub_tot-total_wage_pa1  + gwa_final_tab-total_wage_pa1.
*      lwa_final_sub_tot-total_wage_tr1  = lwa_final_sub_tot-total_wage_tr1  + gwa_final_tab-total_wage_tr1.
*      lwa_final_sub_tot-total_wage_cow1 = lwa_final_sub_tot-total_wage_cow1 + gwa_final_tab-total_wage_cow1.
*      lwa_final_sub_tot-total_wage1     = lwa_final_sub_tot-total_wage1     + gwa_final_tab-total_wage1.
*
*      FORMAT COLOR = 4.
**      FORMAT INTENSIFIED ON.
*      WRITE :/ sy-vline,
*            12 text-050,"TOTAL E'YER STATUTORY CONTRIBUTION (A5)
*            74 sy-vline,
*            75 lwa_final_sub_tot-total_wage_pa,
*            93 lwa_final_sub_tot-total_wage_tr,
*           110 lwa_final_sub_tot-total_wage_cow,
*           130 lwa_final_sub_tot-total_wage,
*           148 sy-vline,
*           150 sy-vline,
*           151 lwa_final_sub_tot-total_wage_pa1,
*           169 lwa_final_sub_tot-total_wage_tr1,
*           186 lwa_final_sub_tot-total_wage_cow1,
*           206 lwa_final_sub_tot-total_wage1,
*           224 sy-vline.
**      FORMAT INTENSIFIED OFF.
*      FORMAT COLOR = 0.
*      APPEND lwa_final_sub_tot TO it_final_sub_tot.
*
*      "TOTAL EOM (A1 TO A5)
*      READ TABLE it_final_sub_tot INTO lwa_final_sub_tot1 WITH KEY sub_total = 'A4_TOTAL'.
*      IF sy-subrc EQ 0.
*      ENDIF.
*      lwa_final_sub_tot-sub_total = 'A1_A5_TOTAL'.
*      lwa_final_sub_tot-total_wage_pa  = lwa_final_sub_tot-total_wage_pa  + lwa_final_sub_tot1-total_wage_pa.
*      lwa_final_sub_tot-total_wage_tr  = lwa_final_sub_tot-total_wage_tr  + lwa_final_sub_tot1-total_wage_tr.
*      lwa_final_sub_tot-total_wage_cow = lwa_final_sub_tot-total_wage_cow + lwa_final_sub_tot1-total_wage_cow.
*      lwa_final_sub_tot-total_wage     = lwa_final_sub_tot-total_wage     + lwa_final_sub_tot1-total_wage.
*
*      lwa_final_sub_tot-total_wage_pa1  = lwa_final_sub_tot-total_wage_pa1  + lwa_final_sub_tot1-total_wage_pa1.
*      lwa_final_sub_tot-total_wage_tr1  = lwa_final_sub_tot-total_wage_tr1  + lwa_final_sub_tot1-total_wage_tr1.
*      lwa_final_sub_tot-total_wage_cow1 = lwa_final_sub_tot-total_wage_cow1 + lwa_final_sub_tot1-total_wage_cow1.
*      lwa_final_sub_tot-total_wage1     = lwa_final_sub_tot-total_wage1     + lwa_final_sub_tot1-total_wage1.
*
*      FORMAT COLOR = 4.
*      FORMAT INTENSIFIED ON.
*      WRITE :/ sy-vline,
*            12 text-051,"TOTAL EOM (A1 TO A5)
*            74 sy-vline,
*            75 lwa_final_sub_tot-total_wage_pa,
*            93 lwa_final_sub_tot-total_wage_tr,
*           110 lwa_final_sub_tot-total_wage_cow,
*           130 lwa_final_sub_tot-total_wage,
*           148 sy-vline,
*           150 sy-vline,
*           151 lwa_final_sub_tot-total_wage_pa1,
*           169 lwa_final_sub_tot-total_wage_tr1,
*           186 lwa_final_sub_tot-total_wage_cow1,
*           206 lwa_final_sub_tot-total_wage1,
*           224 sy-vline.
*      FORMAT INTENSIFIED OFF.
*      FORMAT COLOR = 0.
*      APPEND lwa_final_sub_tot TO it_final_sub_tot.
*      CLEAR lwa_final_sub_tot.
*    ELSEIF lwa_sec_details-main EQ 'B'.
*      WRITE :/ sy-vline.
*      FORMAT COLOR = 4.
*      FORMAT INTENSIFIED ON.
*      WRITE : 12 'TOTAL EXTERNAL ALLOWANCES (B)',
*              74 sy-vline,
*              75 lwa_final_sub_tot-total_wage_pa,
*              93 lwa_final_sub_tot-total_wage_tr,
*             110 lwa_final_sub_tot-total_wage_cow,
*             130 lwa_final_sub_tot-total_wage,
*             148 sy-vline,
*             150 sy-vline,
*             151 lwa_final_sub_tot-total_wage_pa1,
*             169 lwa_final_sub_tot-total_wage_tr1,
*             186 lwa_final_sub_tot-total_wage_cow1,
*             206 lwa_final_sub_tot-total_wage1,
*             224 sy-vline.
*      FORMAT INTENSIFIED OFF.
*      FORMAT COLOR = 0.
*      APPEND lwa_final_sub_tot TO it_final_sub_tot.
*      CLEAR lwa_final_sub_tot.
*    ELSEIF lwa_sec_details-main EQ 'C' AND lwa_sec_details-sec EQ '02' AND lwa_sec_details-sub_sec LE '09'.
*      WRITE :/ sy-vline.
*      FORMAT COLOR = 4.
*      WRITE : 74 sy-vline,
*              75 lwa_final_sub_tot7-total_wage_pa,
*              93 lwa_final_sub_tot7-total_wage_tr,
*             110 lwa_final_sub_tot7-total_wage_cow,
*             130 lwa_final_sub_tot7-total_wage,
*             148 sy-vline,
*             150 sy-vline,
*             151 lwa_final_sub_tot7-total_wage_pa1,
*             169 lwa_final_sub_tot7-total_wage_tr1,
*             186 lwa_final_sub_tot7-total_wage_cow1,
*             206 lwa_final_sub_tot7-total_wage1,
*             224 sy-vline.
*      CLEAR lwa_final_sub_tot7.
*      FORMAT COLOR = 0.
*
*      IF lwa_sec_details-sub_sec EQ '09'.
*        FORMAT COLOR = 4.
*        WRITE :/ sy-vline,
*              30 'SUB-TOTAL(', lwa_final_sub_tot-sub_total, ')',
*              74 sy-vline,
*              75 lwa_final_sub_tot-total_wage_pa,
*              93 lwa_final_sub_tot-total_wage_tr,
*             110 lwa_final_sub_tot-total_wage_cow,
*             130 lwa_final_sub_tot-total_wage,
*             148 sy-vline,
*             150 sy-vline,
*             151 lwa_final_sub_tot-total_wage_pa1,
*             169 lwa_final_sub_tot-total_wage_tr1,
*             186 lwa_final_sub_tot-total_wage_cow1,
*             206 lwa_final_sub_tot-total_wage1,
*             224 sy-vline.
*        FORMAT COLOR = 0.
*
*        APPEND lwa_final_sub_tot TO it_final_sub_tot.
*        CLEAR : lwa_final_sub_tot,lwa_final_sub_tot5.
*        LOOP AT it_final_sub_tot INTO lwa_final_sub_tot5 WHERE sub_total EQ 'C1' OR sub_total EQ 'C2'.
*          lwa_final_sub_tot-total_wage_pa  = lwa_final_sub_tot-total_wage_pa  + lwa_final_sub_tot5-total_wage_pa.
*          lwa_final_sub_tot-total_wage_tr  = lwa_final_sub_tot-total_wage_tr  + lwa_final_sub_tot5-total_wage_tr.
*          lwa_final_sub_tot-total_wage_cow = lwa_final_sub_tot-total_wage_cow + lwa_final_sub_tot5-total_wage_cow.
*          lwa_final_sub_tot-total_wage     = lwa_final_sub_tot-total_wage     + lwa_final_sub_tot5-total_wage.
*
*          lwa_final_sub_tot-total_wage_pa1  = lwa_final_sub_tot-total_wage_pa1  + lwa_final_sub_tot5-total_wage_pa1.
*          lwa_final_sub_tot-total_wage_tr1  = lwa_final_sub_tot-total_wage_tr1  + lwa_final_sub_tot5-total_wage_tr1.
*          lwa_final_sub_tot-total_wage_cow1 = lwa_final_sub_tot-total_wage_cow1 + lwa_final_sub_tot5-total_wage_cow1.
*          lwa_final_sub_tot-total_wage1     = lwa_final_sub_tot-total_wage1     + lwa_final_sub_tot5-total_wage1.
*
*        ENDLOOP.
*        lwa_final_sub_tot-sub_total = 'C_TOTAL'.
*        FORMAT COLOR = 4.
*        FORMAT INTENSIFIED ON.
*        WRITE :/ sy-vline,
*                      12 'TOTAL OOE (C1 TO C2)',
*                      74 sy-vline,
*                      75 lwa_final_sub_tot-total_wage_pa,
*                      93 lwa_final_sub_tot-total_wage_tr,
*                     110 lwa_final_sub_tot-total_wage_cow,
*                     130 lwa_final_sub_tot-total_wage,
*                     148 sy-vline,
*                     150 sy-vline,
*                     151 lwa_final_sub_tot-total_wage_pa1,
*                     169 lwa_final_sub_tot-total_wage_tr1,
*                     186 lwa_final_sub_tot-total_wage_cow1,
*                     206 lwa_final_sub_tot-total_wage1,
*                     224 sy-vline.
*        FORMAT INTENSIFIED OFF.
*        FORMAT COLOR = 0.
*        APPEND lwa_final_sub_tot TO it_final_sub_tot.
*        CLEAR lwa_final_sub_tot.
*      ENDIF.
*    ELSEIF lwa_sec_details-main EQ 'D'."SALARY RECOVERABLE
*      WRITE :/ sy-vline.
*      FORMAT COLOR = 4.
*      FORMAT INTENSIFIED ON.
*      WRITE : 74 sy-vline,
*              75 lwa_final_sub_tot-total_wage_pa,
*              93 lwa_final_sub_tot-total_wage_tr,
*             110 lwa_final_sub_tot-total_wage_cow,
*             130 lwa_final_sub_tot-total_wage,
*             148 sy-vline,
*             150 sy-vline,
*             151 lwa_final_sub_tot-total_wage_pa1,
*             169 lwa_final_sub_tot-total_wage_tr1,
*             186 lwa_final_sub_tot-total_wage_cow1,
*             206 lwa_final_sub_tot-total_wage1,
*             224 sy-vline.
*      FORMAT INTENSIFIED OFF.
*      FORMAT COLOR = 0.
*      APPEND lwa_final_sub_tot TO it_final_sub_tot.
*      CLEAR lwa_final_sub_tot.
*    ELSEIF lwa_sec_details-main EQ 'F'."PAYMENT VIA:
**do nothing
*    ELSE.
*      WRITE :/ sy-vline.
*      FORMAT COLOR = 4.
**      FORMAT INTENSIFIED ON.
*      WRITE : 30 'SUB-TOTAL(', lwa_final_sub_tot-sub_total, ')',
*              74 sy-vline,
*              75 lwa_final_sub_tot-total_wage_pa,
*              93 lwa_final_sub_tot-total_wage_tr,
*             110 lwa_final_sub_tot-total_wage_cow,
*             130 lwa_final_sub_tot-total_wage,
*             148 sy-vline,
*             150 sy-vline,
*             151 lwa_final_sub_tot-total_wage_pa1,
*             169 lwa_final_sub_tot-total_wage_tr1,
*             186 lwa_final_sub_tot-total_wage_cow1,
*             206 lwa_final_sub_tot-total_wage1,
*             224 sy-vline.
**      FORMAT INTENSIFIED OFF.
*      FORMAT COLOR = 0.
*      APPEND lwa_final_sub_tot TO it_final_sub_tot.
*      CLEAR lwa_final_sub_tot.
*    ENDIF.
*  ENDLOOP.
*  WRITE :/ sy-uline(224).
*  STOP.
* End of program.
*****************************************

ENDFORM.                    "write_details

************************************************************************
**Form display_header
************************************************************************
FORM display_header USING VALUE(repid) LIKE sy-repid
                          VALUE(reptitle) TYPE c
                          VALUE(begda) TYPE c
                          VALUE(endda) TYPE c
                          VALUE(width) TYPE i
                          VALUE(basic_list) TYPE c
                          VALUE(payroll_area) LIKE t549t-atext
                          VALUE(personnel_area) LIKE t500p-name1
                          VALUE(org_unit) LIKE hrp1000-stext
                    CHANGING VALUE(line1) TYPE c
                             VALUE(line2) TYPE c
                             VALUE(line3) TYPE c.

  DATA: string(100).
  DATA: lines       TYPE i,
        pos         TYPE i,
        date_c(10),
        time_c(5),
        period(110).

  WRITE sy-datum DD/MM/YYYY TO date_c.

  WRITE sy-uzeit USING EDIT MASK '__:__' TO time_c.
  IF NOT begda IS INITIAL AND NOT endda IS INITIAL.

    WRITE 'From ' TO period+0.

    WRITE begda(10) TO period+5(10).

    WRITE ' to ' TO period+15(4).

    WRITE endda(10) TO period+19.

    WRITE display_string TO period+30.
  ELSEIF endda IS INITIAL AND NOT begda IS INITIAL.

    WRITE 'As at ' TO period+0.

    WRITE begda TO period+6.

    WRITE display_string TO period+30.
  ELSEIF begda IS INITIAL AND NOT endda IS INITIAL.

    WRITE 'Until ' TO period+0.

    WRITE endda TO period+6.

    WRITE display_string TO period+30.
  ENDIF.

  IF basic_list IS INITIAL.

    FORMAT COLOR COL_NORMAL ON.
* commented out by ytm on 04.10.2002 PAY-245.
*    pos = width - 10.
*    WRITE: / 'Report ID:', repid LEFT-JUSTIFIED, AT pos(6) 'Page: '.
*    pos = pos + 6.
*    WRITE AT pos(5) sy-pagno LEFT-JUSTIFIED.

    WRITE: / reptitle(20), repid LEFT-JUSTIFIED.
    pos = width - 25.

    WRITE AT pos 'Run on '.
    pos = pos + 7.

    WRITE: AT pos(20) date_c.
    pos = pos + 10.

    WRITE: AT pos ',',
             (7) time_c.
    PRINT-CONTROL FONT 2 SIZE 50.
    WRITE: AT /(width) period.

    CLEAR string.
    IF NOT personnel_area IS INITIAL AND NOT org_unit IS INITIAL.
      CONCATENATE personnel_area '-' org_unit INTO string
      SEPARATED BY space.

    ELSEIF personnel_area IS INITIAL AND NOT org_unit IS INITIAL.
      string = org_unit.

    ELSEIF NOT personnel_area IS INITIAL AND org_unit IS INITIAL.
      string = personnel_area.
    ENDIF.

    IF NOT payroll_area IS INITIAL.
      IF NOT string IS INITIAL.
        CONCATENATE payroll_area ':' string INTO string.
      ELSE.
        string = payroll_area.
      ENDIF.
    ENDIF.

* Previously, every new page will display org unit.
* replaced with the sort sequence instead.
* by ytm 07/09/2001.
*    IF NOT string IS INITIAL.
*      WRITE: / string, AT width ''.
*    ENDIF.

    CLEAR string.
    IF NOT sort1 IS INITIAL
    OR NOT sort2 IS INITIAL
    OR NOT sort3 IS INITIAL
    OR NOT sort4 IS INITIAL.
      CONCATENATE 'Sorted by' sort1 sort2 sort3 sort4
        INTO string SEPARATED BY space.

      WRITE: / string, AT width ''.
    ENDIF.
  ELSE.

    WRITE 'Report ID: ' TO line1+0.

    WRITE repid TO line1+11.

    WRITE reptitle TO line2+0.
    pos = width - 25.

    WRITE 'Run on ' TO line2+pos.
    pos = pos + 7.

    WRITE date_c TO line2+pos.
    pos = pos + 10.

    WRITE ', ' TO line2+pos.
    pos = pos + 2.

    WRITE time_c TO line2+pos(5).

    WRITE period TO line3+0.

  ENDIF.

  FORMAT COLOR OFF.

ENDFORM.                    "display_header

*---------------------------------------------------------------------*
*       FORM formatting                                               *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
*  -->  itab_output                                                   *
*---------------------------------------------------------------------*
FORM formatting TABLES itab_input STRUCTURE emp_details.
  FORMAT INTENSIFIED OFF.

  DATA: c          TYPE i,
        d          TYPE i,
        total_pay  TYPE p DECIMALS 2, "total payment
        total_ded  TYPE p DECIMALS 2, "total deduction
        x          TYPE i VALUE '10',
        y          TYPE i VALUE '5',
        count      TYPE i VALUE 1,
        typedesc   TYPE p DECIMALS 2,
        tmpunit    LIKE emp_details-orgeh,
        tmpdesc    LIKE emp_details-org_desc,
        tmpcpf     LIKE emp_details-emp_cpfno,
        tmppersa   LIKE emp_details-persarea,
        tmppayroll LIKE emp_details-pay_r_area,
        net_pay    TYPE p DECIMALS 2.

  DATA: itab_sub1 LIKE itab_output.
  DATA: itab_sub2 LIKE itab_output.
  DATA: itab_sub3 LIKE itab_output.
  DATA: itab_sub4 LIKE itab_output.
  DATA: itab_sub5 LIKE itab_output.

  REFRESH itab_output.

  LOOP AT itab_input.

* i.e. if cost center is selected as sort field 1,
* <fs1> = ITAB_INPUT-BASSAL
    ASSIGN (sort_field1) TO <fs1>.
    ASSIGN (sort_field2) TO <fs2>.
    ASSIGN (sort_field3) TO <fs3>.
    ASSIGN (sort_field4) TO <fs4>.

* move the content of <fs1> to sort field 1.
* i.e. s1= 235171. (cost center)
    itab_output-s1 = <fs1>.
    itab_output-s2 = <fs2>.
    itab_output-s3 = <fs3>.
    itab_output-s4 = <fs4>.

    MOVE-CORRESPONDING itab_input TO itab_output.

    APPEND itab_output.
    CLEAR itab_output.

  ENDLOOP.

* modified by ytm PAY-225.
* output is sorted by last name
  SORT itab_output BY lname fname.

* Perform sorting based on user selection.
  IF NOT sort_field1 IS INITIAL
  OR NOT sort_field2 IS INITIAL
  OR NOT sort_field3 IS INITIAL
  OR NOT sort_field4 IS INITIAL.
    SORT itab_output BY s1 s2 s3 s4.
  ENDIF.

  DATA: page_break(1).

  PERFORM compare_payroll.

* perform sorting based on user selection
  IF NOT sort_field1 IS INITIAL
  OR NOT sort_field2 IS INITIAL
  OR NOT sort_field3 IS INITIAL
  OR NOT sort_field4 IS INITIAL.
    SORT itab_output BY s1 s2 s3 s4.
  ENDIF.

*<------------- Start Insertion by Reuben 13/07/2010 AVA-128188---------------------->
  temp_itab_total_1[] = itab_total[].
  temp_itab_total_2[] = itab_total[].
*<------------- End Insertion by Reuben 13/07/2010 AVA-128188---------------------->

  LOOP AT itab_output.

    CLEAR page_break.

*    RESERVE 10 LINES."CR-0000000739 - Commented

* itab_temp is used to counter the at new problem
* of '*******'
    itab_temp = itab_output.

* count is the s/no.
* i.e. s1        s2          count
*      235171    00001570    1
*      235172    00001570    2
*      235175    00001570    3
*      235172    00001571    1
*      235173    00001572    1

    IF NOT sort_field4 IS INITIAL.
      AT NEW s4.
        IF break_field1 = 'S4' OR
           break_field2 = 'S4' OR
           break_field3 = 'S4' OR
           break_field4 = 'S4' OR
           break_field5 = 'S4'.
          count = 1.
        ENDIF.
      ENDAT.
    ENDIF.
*    ELSEIF NOT sort_field3 IS INITIAL.
    IF NOT sort_field3 IS INITIAL.
      AT NEW s3.
        IF break_field1 = 'S3' OR
           break_field2 = 'S3' OR
           break_field3 = 'S3' OR
           break_field4 = 'S3' OR
           break_field5 = 'S3'.
          count = 1.
        ENDIF.
      ENDAT.
    ENDIF.

*    ELSEIF NOT sort_field2 IS INITIAL.
    IF NOT sort_field2 IS INITIAL.
      AT NEW s2.
        IF break_field1 = 'S2' OR
           break_field2 = 'S2' OR
           break_field3 = 'S2' OR
           break_field4 = 'S2' OR
           break_field5 = 'S2'.
          count = 1.
        ENDIF.
      ENDAT.
    ENDIF.

*    ELSEIF NOT sort_field1 IS INITIAL.
    IF NOT sort_field1 IS INITIAL.
      AT NEW s1.
        IF break_field1 = 'S1' OR
           break_field2 = 'S1' OR
           break_field3 = 'S1' OR
           break_field4 = 'S1' OR
           break_field5 = 'S1'.
          count = 1.
        ENDIF.
      ENDAT.
    ENDIF.

* if user did not set any page break in the selection,
* print the header only once.
    IF break_field1 IS INITIAL
    AND break_field2 IS INITIAL
    AND break_field3 IS INITIAL
    AND break_field4 IS INITIAL
    AND break_field5 IS INITIAL.
      AT FIRST.
        page_break = 'X'.
        NEW-PAGE.
*        FORMAT COLOR COL_GROUP ."CR-0000000739 - Commented
*        WRITE:1  'EMPLOYER CPF NO: ', cpfnum.
*        WRITE: 161 ''.
*        FORMAT COLOR OFF.
*        PERFORM write_header.
      ENDAT.
    ENDIF.

* if page_break = 'X', then the code will display the header.
    IF page_break IS INITIAL.
      AT NEW (break_field1).
        page_break = 'X'.
        NEW-PAGE.
*        FORMAT COLOR COL_GROUP ."CR-0000000739 - Commented
*        WRITE:1  'EMPLOYER CPF NO: ', cpfnum.
*        WRITE: 161 ''.
*        FORMAT COLOR OFF.
*        PERFORM write_header.
      ENDAT.
    ENDIF.

    IF page_break IS INITIAL.
      AT NEW (break_field2).
        page_break = 'X'.
        NEW-PAGE.
*        FORMAT COLOR COL_GROUP ."CR-0000000739 - Commented
*        WRITE:1  'EMPLOYER CPF NO: ', cpfnum.
*        WRITE: 161 ''.
*        FORMAT COLOR OFF.
*        PERFORM write_header.
      ENDAT.
    ENDIF.

    IF page_break IS INITIAL.
      AT NEW (break_field3).
        page_break = 'X'.
        NEW-PAGE.
*        FORMAT COLOR COL_GROUP ."CR-0000000739 - Commented
*        WRITE:1  'EMPLOYER CPF NO: ', cpfnum.
*        WRITE: 161 ''.
*        FORMAT COLOR OFF.
*        PERFORM write_header.
      ENDAT.
    ENDIF.

    IF page_break IS INITIAL.
      AT NEW (break_field4).
        page_break = 'X'.
        NEW-PAGE.
*        FORMAT COLOR COL_GROUP ."CR-0000000739 - Commented
*        WRITE:1  'EMPLOYER CPF NO: ', cpfnum.
*        WRITE: 161 ''.
*        FORMAT COLOR OFF.
*        PERFORM write_header.
      ENDAT.
    ENDIF.

    IF page_break IS INITIAL.
      AT NEW (break_field5).
        page_break = 'X'.
        NEW-PAGE.
*        FORMAT COLOR COL_GROUP ."CR-0000000739 - Commented
*        WRITE:1  'EMPLOYER CPF NO: ', cpfnum.
*        WRITE: 161 ''.
*        FORMAT COLOR OFF.
*        PERFORM write_header.
      ENDAT.
    ENDIF.

* this is to reset the collection.
    AT NEW s1.
      officer_bf1 = 0.
      CLEAR officer_bf_amt1.
      officer_paid_last1 = 0.
      CLEAR officer_paid_last_amt1.
      CLEAR other_adjust_amt1.
      officer_paid_this1 = 0.
      CLEAR officer_paid_this_amt1.
      officer_cf1 = 0.
      CLEAR officer_cf_amt1.
      PERFORM cal_summary1.
    ENDAT.

    AT NEW s2.
      officer_bf2 = 0.
      CLEAR officer_bf_amt2.
      officer_paid_last2 = 0.
      CLEAR officer_paid_last_amt2.
      CLEAR other_adjust_amt2.
      officer_paid_this2 = 0.
      CLEAR officer_paid_this_amt2.
      officer_cf2 = 0.
      CLEAR officer_cf_amt2.
      PERFORM cal_summary2.
    ENDAT.

    AT NEW s3.
      officer_bf3 = 0.
      CLEAR officer_bf_amt3.
      officer_paid_last3 = 0.
      CLEAR officer_paid_last_amt3.
      CLEAR other_adjust_amt3.
      officer_paid_this3 = 0.
      CLEAR officer_paid_this_amt3.
      officer_cf3 = 0.
      CLEAR officer_cf_amt3.
      PERFORM cal_summary3.
    ENDAT.

    AT NEW s4.
      officer_bf4 = 0.
      CLEAR officer_bf_amt4.
      officer_paid_last4 = 0.
      CLEAR officer_paid_last_amt4.
      CLEAR other_adjust_amt4.
      officer_paid_this4 = 0.
      CLEAR officer_paid_this_amt4.
      officer_cf4 = 0.
      CLEAR officer_cf_amt4.
      PERFORM cal_summary4.
    ENDAT.

* To perform sub total
    AT NEW (subtotal_field1).
      REFRESH itab_subtotal1.
    ENDAT.

    AT NEW (subtotal_field2).
      REFRESH itab_subtotal2.
    ENDAT.

    AT NEW (subtotal_field3).
      REFRESH itab_subtotal3.
    ENDAT.

    AT NEW (subtotal_field4).
      REFRESH itab_subtotal4.
    ENDAT.

    AT NEW (subtotal_field5).
      REFRESH itab_subtotal5.
    ENDAT.

    IF NOT itab_temp-perno IS INITIAL.

      itab_output-srno = count.

      CLEAR itab_cpf-pscpf.
      READ TABLE itab_cpf WITH KEY pernr = itab_output-perno.

      TABLES: cskt.
      IF count = 1.
*        FORMAT INTENSIFIED OFF."CR-0000000739 - Commented
*        FORMAT COLOR COL_GROUP .
        IF NOT sort1 IS INITIAL.
*          CASE sort1."CR-0000000739 - Commented
**            WHEN 'Org Unit'.
*            WHEN 'ORG UNIT'.
*              WRITE: / 'Org Unit:', itab_output-org_desc(25).
**            WHEN 'Cost Centr'.
*            WHEN 'COST CENTR'.
*              CLEAR cskt.
*              SELECT SINGLE * FROM t500p
*              WHERE persa = itab_output-persarea.
*              IF sy-subrc = 0.
*                SELECT SINGLE * FROM cskt
*                WHERE spras = sy-langu
*                AND kokrs = t500p-bukrs
*                AND kostl = itab_output-bassal.
*              ENDIF.
*              WRITE: / 'Cost Centr:', cskt-ktext, itab_output-bassal.
**         WHEN 'Wage Type'.
**           WRITE: / 'Heading'.
**            WHEN 'Name'.
*            WHEN 'NAME'.
*              WRITE: / 'Name:', itab_output-ename(30).
*            WHEN 'NRIC'.
*              WRITE: / 'NRIC:', itab_output-nric.
**            WHEN 'Per Num'.
*            WHEN 'PER NUM'.
*              WRITE: / 'Per Num:', itab_output-perno.
**            WHEN 'Per Grp'.
*            WHEN 'PER GRP'.
**              WRITE: / 'Per Grp:', itab_output-per_grp_desc(25).         "ACE 17 Feb
*              WRITE: / 'Per Grp:', itab_output-per_grp_desc(15). "ACE 17 Feb
**            WHEN 'Div Status'.
*            WHEN 'DIV STATUS'.
*              WRITE: / 'Div Status:', itab_output-divstatus_desc(15).
*          ENDCASE.
        ENDIF.

        IF NOT sort2 IS INITIAL.
          CASE sort2.
**            WHEN 'Org Unit'."CR-0000000739 - Commented
*            WHEN 'ORG UNIT'.
*              WRITE: 'Org Unit:', itab_output-org_desc(25).
**            WHEN 'Cost Centr'.
*            WHEN 'COST CENTR'.
*              CLEAR cskt.
*              SELECT SINGLE * FROM t500p
*              WHERE persa = itab_output-persarea.
*              IF sy-subrc = 0.
*                SELECT SINGLE * FROM cskt
*                WHERE spras = sy-langu
*                AND kokrs = t500p-bukrs
*                AND kostl = itab_output-bassal.
*              ENDIF.
*              WRITE: 'Cost Centr:', cskt-ktext, itab_output-bassal.
**         WHEN 'Wage Type'.
**           WRITE: 'Heading'.
**            WHEN 'Name'.
*            WHEN 'NAME'.
*              WRITE: 'Name:', itab_output-ename(30).
*            WHEN 'NRIC'.
*
*              WRITE: 'NRIC:', itab_output-nric.
**            WHEN 'Per Num'.
*            WHEN 'PER NUM'.
*              WRITE: 'Per Num:', itab_output-perno.
**            WHEN 'Per Grp'.
*            WHEN 'PER GRP'.
**             WRITE: 'Per Grp:', itab_output-per_grp_desc(25).         "ACE 17 Feb 09
*              WRITE: 'Per Grp:', itab_output-per_grp_desc(15).         "ACE 17 Feb 09
**            WHEN 'Div Status'.
*            WHEN 'DIV STATUS'.
*              WRITE: 'Div Status:', itab_output-divstatus_desc(15).
          ENDCASE.
        ENDIF.

        IF NOT sort3 IS INITIAL.
          CASE sort3.
**            WHEN 'Org Unit'."CR-0000000739 - Commented
*            WHEN 'ORG UNIT'.
*              WRITE: 'Org Unit:', itab_output-org_desc(25).
**            WHEN 'Cost Centr'.
*            WHEN 'COST CENTR'.
*              CLEAR cskt.
*              SELECT SINGLE * FROM t500p
*              WHERE persa = itab_output-persarea.
*              IF sy-subrc = 0.
*                SELECT SINGLE * FROM cskt
*                WHERE spras = sy-langu
*                AND kokrs = t500p-bukrs
*                AND kostl = itab_output-bassal.
*              ENDIF.
*              WRITE: 'Cost Centr:', cskt-ktext, itab_output-bassal.
**         WHEN 'Wage Type'.
**           WRITE: 'Heading'.
**            WHEN 'Name'.
*            WHEN 'NAME'.
*              WRITE: 'Name:', itab_output-ename(30).
*            WHEN 'NRIC'.
*              WRITE: 'NRIC:', itab_output-nric.
**            WHEN 'Per Num'.
*            WHEN 'PER NUM'.
*              WRITE: 'Per Num:', itab_output-perno.
**            WHEN 'Per Grp'.
*            WHEN 'PER GRP'.
**             WRITE: 'Per Grp:', itab_output-per_grp_desc(25).        "ACE 17 Feb 09
*              WRITE: 'Per Grp:', itab_output-per_grp_desc(15).        "ACE 17 Feb 09
**            WHEN 'Div Status'.
*            WHEN 'DIV STATUS'.
*              WRITE: 'Div Status:', itab_output-divstatus_desc(15).
          ENDCASE.
        ENDIF.

        IF NOT sort4 IS INITIAL.
          CASE sort4.
**            WHEN 'Org Unit'."CR-0000000739 - Commented
*            WHEN 'ORG UNIT'.
*              WRITE: 'Org Unit:', itab_output-org_desc(25).
**            WHEN 'Cost Centr'.
*            WHEN 'COST CENTR'.
*              CLEAR cskt.
*              SELECT SINGLE * FROM t500p
*              WHERE persa = itab_output-persarea.
*              IF sy-subrc = 0.
*                SELECT SINGLE * FROM cskt
*                WHERE spras = sy-langu
*                AND kokrs = t500p-bukrs
*                AND kostl = itab_output-bassal.
*              ENDIF.
*              WRITE: 'Cost Centr:', cskt-ktext, itab_output-bassal.
**         WHEN 'Wage Type'.
**           WRITE: 'Heading'.
**            WHEN 'Name'.
*            WHEN 'NAME'.
*              WRITE: 'Name:', itab_output-ename(30).
*            WHEN 'NRIC'.
*              WRITE: 'NRIC:', itab_output-nric.
**            WHEN 'Per Num'.
*            WHEN 'PER NUM'.
*              WRITE: 'Per Num:', itab_output-perno.
**            WHEN 'Per Grp'.
*            WHEN 'PER GRP'.
**             WRITE: 'Per Grp:', itab_output-per_grp_desc(25).        "ACE 17 Feb 09
*              WRITE: 'Per Grp:', itab_output-per_grp_desc(15).        "ACE 17 Feb 09
**            WHEN 'Div Status'.
*            WHEN 'DIV STATUS'.
*              WRITE: 'Div Status:', itab_output-divstatus_desc(15).
          ENDCASE.
        ENDIF.
*        WRITE AT 161 ' '."CR-0000000739 - Commented
*        FORMAT RESET.
      ENDIF.

*      WRITE: / itab_output-srno UNDER text-001 LEFT-JUSTIFIED NO-GROUPING,"CR-0000000739 - Commented
*              itab_output-nric UNDER text-002 LEFT-JUSTIFIED,
*              (25) itab_output-ename UNDER text-003 LEFT-JUSTIFIED,
*              itab_output-type_svc UNDER text-012 LEFT-JUSTIFIED,
*              itab_output-m_sex UNDER text-004 LEFT-JUSTIFIED,
*              itab_output-subappdesc UNDER text-005 LEFT-JUSTIFIED,
*              itab_output-bassal UNDER text-006 LEFT-JUSTIFIED,
*              itab_output-pos_desc UNDER text-007 LEFT-JUSTIFIED,
*              itab_output-race_desc UNDER text-008 LEFT-JUSTIFIED,
*              itab_output-perno UNDER text-023 LEFT-JUSTIFIED.
*
*      WRITE:/ itab_output-bankkey UNDER text-009 LEFT-JUSTIFIED,
*              itab_output-baccno  UNDER text-010 LEFT-JUSTIFIED,
*              itab_output-divstatus_desc UNDER text-011 LEFT-JUSTIFIED,
*              (7) itab_cpf-pscpf UNDER text-025 LEFT-JUSTIFIED,
*              itab_output-tenure_desc UNDER text-024 LEFT-JUSTIFIED,
*              itab_output-sal_code UNDER text-014 LEFT-JUSTIFIED,
*              itab_output-sal_point UNDER text-015 LEFT-JUSTIFIED,
*              itab_output-nex_salbar UNDER text-016 LEFT-JUSTIFIED.

      " Ting ting added Sir CE00007738 15.06.2009
      IF ( itab_output-inc_date = '00000000' OR itab_output-inc_date IS INITIAL OR itab_output-inc_date = '' ).
        itab_output-inc_date1 = ''.
      ELSE.
*        WRITE itab_output-inc_date TO itab_output-inc_date1    ."CR-0000000739 - Commented
      ENDIF.

*              itab_output-inc_date UNDER text-017 LEFT-JUSTIFIED,
*      WRITE:itab_output-inc_date1 UNDER text-017 LEFT-JUSTIFIED,"CR-0000000739 - Commented
*            itab_output-religion_desc UNDER text-018 LEFT-JUSTIFIED,
*            itab_output-ocrsn UNDER text-019 LEFT-JUSTIFIED.
*
*      WRITE:/(45) itab_output-org_desc UNDER 'Org Unit' LEFT-JUSTIFIED,
*             (45) itab_output-per_grp_desc UNDER
*                              'Personnel Group'LEFT-JUSTIFIED.

* added by ytm PAY-225.
* 05.08.02
* fill data_tab.
      LOOP AT itab_total WHERE pernr =  itab_output-perno.
        MOVE-CORRESPONDING itab_output TO data_tab.
        MOVE-CORRESPONDING itab_total TO data_tab.
        APPEND data_tab.
      ENDLOOP.

      DATA: number TYPE i VALUE 1.
* form fill_subtotal using wage desc sum ind .
      PERFORM fill_subtotal USING 'NUM'
                                  'Total Num'
                                  number
                                  'N'.

* Display allowances
      c = 1.
      x = 15.

      SORT itab_total BY lgart ASCENDING.

* add 9S.. to total payment except monthly salary (9S%%)
* 9S%% is calculated salary in this report.

* commented out by ken on 30.1.2002
* to add all 9S.. wage types except the monthly wage type(9S%%)
* this is to cater for special wage type like 9S60(Salary Arrears).

*      LOOP AT itab_total WHERE pernr =  itab_output-perno
*                         AND ( lgart = '9S01'
*                            OR lgart = '9S02'
*                            OR lgart = '9S03'
*                            OR lgart = '9S04'
*                            OR lgart = '9S05' ).


      " Ting ting 21.09.2009 - add %
*      DATA: lv_index TYPE i.
*      CLEAR lv_index.
*      LOOP AT itab_total WHERE pernr =  itab_output-perno.
*        " Ting ting 21.09.2009
*        lv_index = lv_index + 1.
*        IF gv_kpr01 IS NOT INITIAL AND gv_kpr01 <> 0.
*          itab_total-total_wage = ( itab_total-total_wage * gv_kpr01 ) / 100.
*        ENDIF.
*        MODIFY itab_total INDEX lv_index.
*      ENDLOOP.


      LOOP AT itab_total WHERE pernr =  itab_output-perno
                         AND lgart NE ' '
*                         AND lgart+0(2) = '9S'
                         AND NOT total_wage IS INITIAL
                         AND lgart NOT IN itab_wagedec[]
        " ting ting added start
                        AND lgart <> '/376'
                        AND lgart <> '/308'
                        AND lgart <> '4MSO'
                        AND lgart <> '/307'
                        AND lgart <> '/305'
                        AND lgart <> '/314'
                        AND lgart <>'/370'
                        AND lgart <> '/371'
                        AND lgart <> '/372'
                        AND lgart <> '/373'
                        AND lgart <> '/374'
                        AND lgart <>'/563'
                        AND lgart <> '/565'
                        AND lgart <>'/566'
                        AND lgart <> '/375'
                        AND lgart <> '/305'  "E'yee,CPF-curr.contr./sum
                        AND lgart <> '/370' "E'yee, CDAC, add.fund
                        AND lgart <>  '/371' "E'yee, SINDA,add.fund
                        AND lgart <>  '/372' "E'yee, MBMF, add.fund
                        AND lgart <> '/373' "E'yee, ECF   add.fund
                        AND lgart <> '/374' "E'yee, COMCS add.fund
                        AND lgart <> '/375' "E'yee, Other fund
                        AND lgart <>  '/565' "Carry-over for subs.month
                        AND lgart <>  '/566' "Carry-over for prev.month
                        AND lgart <> '/314'  "E'YEE, Shortfall on AW
                        AND lgart <>'/450'
                        AND lgart <> '/303'
                        AND lgart <> '4MSO' " SIR CE00007762 Ting Ting added 15.06.2009
                        AND lgart <> '0ERA' " SIR CE00007858 Ting Ting added 17.06.2009
                        AND lgart IN gt_allowance[].
        " ting ting added end
        .

*        total_pay = total_pay + itab_total-total_wage. " ting ting commented 03.06.2009

* form fill_subtotal using wage desc sum ind .

        PERFORM fill_subtotal USING itab_total-lgart
                                    itab_total-wage_desc
                                    itab_total-total_wage
                                    'A'.
      ENDLOOP.


* Added these 5 fill_subtotal with '9S01', '9S02'
* '9S03', '9S04', '9S05' so that subtotal
* will display them even if it is zero.
      DATA: wage_desc LIKE itab_total-wage_desc.

      CLEAR wage_desc.
      SELECT lgtxt INTO (wage_desc)
        FROM t512t
        WHERE sprsl = 'EN'
        AND molga = '25'
*        AND lgart = '9S01'. " ting ting 28.04.2009
        AND lgart = '0BAS'.
      ENDSELECT.

      PERFORM fill_subtotal USING '0BAS'
*      PERFORM fill_subtotal USING '9S01'
                                       wage_desc
                                       0
                                       'A'.
      CLEAR wage_desc.
      SELECT lgtxt INTO (wage_desc)
        FROM t512t
        WHERE sprsl = 'EN'
        AND molga = '25'
*        AND lgart = '9S02'." ting ting 28.04.2009
        AND lgart = '0MVC'.
      ENDSELECT.

      PERFORM fill_subtotal USING '0MVC'
*      PERFORM fill_subtotal USING '9S02' " ting ting 28.04.2009
                                       wage_desc
                                       0
                                       'A'.
      CLEAR wage_desc.
      SELECT lgtxt INTO (wage_desc)
        FROM t512t
        WHERE sprsl = 'EN'
        AND molga = '25'
*        AND lgart = '9S03'.
                AND lgart = '0NPC'.
      ENDSELECT.

      PERFORM fill_subtotal USING '0NPC'
*      PERFORM fill_subtotal USING '9S03' " ting ting 28.04.2009
                                   wage_desc
                                   0
                                   'A'.
      CLEAR wage_desc.
      SELECT lgtxt INTO (wage_desc)
        FROM t512t
        WHERE sprsl = 'EN'
        AND molga = '25'
*        AND lgart = '9S04'." ting ting commented
        AND lgart = '0NVN'.
      ENDSELECT.

      PERFORM fill_subtotal USING '0NVN'
*      PERFORM fill_subtotal USING '9S04' " ting ting commented
                                     wage_desc
                                     0
                                     'A'.
      CLEAR wage_desc.
      SELECT lgtxt INTO (wage_desc)
        FROM t512t
        WHERE sprsl = 'EN'
        AND molga = '25'
*        AND lgart = '9S05'. " ting ting commented
        AND lgart = '0NVS'.
      ENDSELECT.

      PERFORM fill_subtotal USING '0NVS'
*      PERFORM fill_subtotal USING '9S05'" ting ting commented
                                        wage_desc
                                        0
                                        'A'.

* print 9S first.

      READ TABLE itab_monthly WITH KEY pernr = itab_output-perno.
      IF sy-subrc = 0.

* display monthly salary.
* commented out by ken on 30.1.2002
* so that the prog will now print
* all wage types of 9S..
*        LOOP AT itab_total WHERE pernr =  itab_output-perno
*                           AND ( lgart = '9S%%'
*                            OR lgart = '9S01'
*                            OR lgart = '9S02'
*                            OR lgart = '9S03'
*                            OR lgart = '9S04'
*                            OR lgart = '9S05' )
*                           AND NOT total_wage IS INITIAL.

        " ting ting commented 22.05.2009
*        LOOP AT itab_total WHERE pernr =  itab_output-perno
*                           AND ( lgart+0(2) = '9S')
*                           AND NOT total_wage IS INITIAL.


        " ting ting commented
*        LOOP AT itab_total WHERE pernr =  itab_output-perno
*                           AND lgart IN gt_allowance[]
*                           AND NOT total_wage IS INITIAL
*                           AND lgart NOT IN itab_wagedec[]
*                           AND lgart <> '/563'
*                            .
*          CLEAR gwa_t511.
*          READ TABLE gt_t511 INTO gwa_t511 WITH KEY lgart = itab_total-lgart  opken = ''.
*          IF sy-subrc = 0.
*            .
** The salary wage type (9S**) will be written in column 1, 41, 81
** and when the column exceed 120, it will write next line at column 15.
*
** The value x is to keep track of the column
** The value c is to ensure that 'ALW:' text-020 is printed once only.
*            IF c = 1.
*              WRITE: AT /10(5) text-020 ,15(15) itab_total-wage_desc,
*                                 '  :  ' , (15) itab_total-total_wage.
*              c = c + 1.
*            ELSE.
*              IF x  >= 130.
*                NEW-LINE.
*                x = 15.
*              ENDIF.
*              WRITE: AT x(15) itab_total-wage_desc,'  :  ',(15)
*                           itab_total-total_wage.
*            ENDIF.
*            x  =  x + 40.
*          ENDIF.
*        ENDLOOP.

      ELSE.
* display salary breakdown.

* commented out by ken on 30.1.2002
* so that the prog will now print
* all wage types of 9S..
*        LOOP AT itab_total WHERE pernr =  itab_output-perno
*                           AND ( lgart = '9S%%'
*                            OR lgart = '9S01'
*                            OR lgart = '9S02'
*                            OR lgart = '9S03'
*                            OR lgart = '9S04'
*                            OR lgart = '9S05' )
*                           AND NOT total_wage IS INITIAL.

        LOOP AT itab_total WHERE pernr =  itab_output-perno
                           AND ( lgart+0(2) = '9S')
                           AND NOT total_wage IS INITIAL
                           AND lgart IN gt_allowance[].

          IF c = 1.
*            WRITE: AT /10(5) text-020 ,15(15) itab_total-wage_desc,"CR-0000000739 - Commented
*                               '  :  ' , (15) itab_total-total_wage.
            c = c + 1.
          ELSE.
            IF x  >= 130.
*              NEW-LINE."CR-0000000739 - Commented
              x = 15.
            ENDIF.
*            WRITE: AT x(15) itab_total-wage_desc,'  :  ',(15)"CR-0000000739 - Commented
*                         itab_total-total_wage.
          ENDIF.
          x  =  x + 40.
        ENDLOOP.
      ENDIF.
* end of printing '9S' wage type.

*( HRPS/05/040 Add TCTC Wage Types

      LOOP AT itab_total WHERE ( ( pernr =  itab_output-perno
*                         AND lgart = '9Z91' " ting ting comment
                         AND lgart = '1Z01'
                         AND NOT total_wage IS INITIAL
                         AND lgart IN gt_allowance[]
                         )
                         OR ( pernr =  itab_output-perno
                         AND lgart = '1Z91'
                         AND NOT total_wage IS INITIAL
                         AND lgart IN gt_allowance[]
                        ) ).
        total_pay =   total_pay + itab_total-total_wage.

        IF c = 1.
*          WRITE: AT /10(5) text-020 ,15(15) itab_total-wage_desc,"CR-0000000739 - Commented
*                             '  :  ' , (15) itab_total-total_wage.
          c = c + 1.
        ELSE.
          IF x  >= 130.
*            NEW-LINE."CR-0000000739 - Commented
            x = 15.
          ENDIF.
*          WRITE: AT x(15) itab_total-wage_desc,'  :  ',(15)"CR-0000000739 - Commented
*                       itab_total-total_wage.
        ENDIF.
        x  =  x + 40.
      ENDLOOP.

*)

*now print the others.
      LOOP AT itab_total WHERE pernr =  itab_output-perno
                         AND (  lgart+0(2) = '9A'  OR
                                lgart+0(2) = '9C'  OR
                                lgart+0(2) = '9O'  OR
                                lgart+0(2) = '9B'  OR
                                lgart+0(2) = '9W' ) "OR
*                                lgart+0(2) = '9M' )
*drop record if amount 0.
                         AND NOT total_wage IS INITIAL
                         AND lgart IN gt_allowance[].

        PERFORM fill_subtotal USING itab_total-lgart
                                    itab_total-wage_desc
                                    itab_total-total_wage
                                    'A'.

*        IF itab_total-lgart NE '9W02'. " ting ting commented
        IF itab_total-lgart NE '3W02' AND   itab_total-lgart NE '3LS2' AND   itab_total-lgart NE '3023' AND   itab_total-lgart NE '3LS3'.
          total_pay =   total_pay + itab_total-total_wage.
        ENDIF.

        IF c = 1.
*          WRITE: AT /10(5) text-020 ,15(15) itab_total-wage_desc,"CR-0000000739 - Commented
*                             '  :  ' , (15) itab_total-total_wage.
          c = c + 1.
        ELSE.
          IF x  >= 130.
*            NEW-LINE."CR-0000000739 - Commented
            x = 15.
          ENDIF.
*          WRITE: AT x(15) itab_total-wage_desc,'  :  ',(15)"CR-0000000739 - Commented
*                       itab_total-total_wage.
        ENDIF.
        x  =  x + 40.
      ENDLOOP.

      LOOP AT itab_total WHERE ( ( pernr =  itab_output-perno
                         AND lgart NOT IN itab_wagedec[]
*---Jacky IR PA-868187
                         AND (  lgart+0(2) <> '9A'  AND
                                lgart+0(2) <> '9C'  AND
                                lgart+0(2) <> '9O'  AND
                                lgart+0(2) <> '9B'  AND
                                lgart+0(2) <> '9W' )
*---Jacky IR PA-868187
                         AND NOT total_wage IS INITIAL
                         AND lgart <> '/563'
                         AND lgart <> '4MSO'  " SIR CE00007762 Ting Ting added 15.06.2009
                         AND lgart <> '0ERA' " SIR CE00007858 Ting Ting added 17.06.2009
                         AND lgart IN gt_allowance[] ) ).

        IF itab_total-lgart <> ' '." monthly salary
          total_pay =   total_pay + itab_total-total_wage.
        ENDIF.

        IF c = 1.
*          WRITE: AT /10(5) text-020 ,15(15) itab_total-wage_desc,"CR-0000000739 - Commented
*                             '  :  ' , (15) itab_total-total_wage.
          c = c + 1.
        ELSE.
          IF x  >= 130.
*            NEW-LINE."CR-0000000739 - Commented
            x = 15.
          ENDIF.
*          WRITE: AT x(15) itab_total-wage_desc,'  :  ',(15)"CR-0000000739 - Commented
*                       itab_total-total_wage.
        ENDIF.
        x  =  x + 40.
      ENDLOOP.

      d = 1.

* Display deductions
      x = 15.
      LOOP AT itab_total WHERE pernr = itab_output-perno AND
*                             (  lgart+0(2) = '9D'  OR " ting ting commented " 27 7 2009
                             (   lgart = '/305'  OR
*{ Insert ncslts 29.11.2004 AW CPF Ceiling
                                lgart = '/314'  OR
*}
                                lgart = '/370'  OR
                                lgart = '/371'  OR
                                lgart = '/372'  OR
                                lgart = '/373'  OR
                                lgart = '/374'  OR
                                lgart = '/563'  OR
                  " Start ting ting commented 01.09.2009 Sir 9233
             lgart = '9DBF'  OR
            lgart = '9DCF'  OR
            " End ting ting commented 01.09.2009
*                                lgart = '/565'  OR
*                                lgart = '/566'  OR
                                lgart = '/375'  OR
                                lgart = '/305' OR "E'yee,CPF-curr.contr./sum
                                lgart = '/370'OR "E'yee, CDAC, add.fund
                                lgart = '/371'OR "E'yee, SINDA,add.fund
                                lgart = '/372'OR "E'yee, MBMF, add.fund
                                lgart = '/373'OR "E'yee, ECF   add.fund
                                lgart = '/374'OR "E'yee, COMCS add.fund
                                lgart = '/375'OR "E'yee, Other fund
*                                lgart = '/565' OR"Carry-over for subs.month
*                                lgart = '/566'OR "Carry-over for prev.month
                                lgart = '/314' OR "E'YEE, Shortfall on AW
*                                lgart = '/450' OR " ting ting commented CE00007471
*                                lgart = '/303' OR " ting ting commented 12.06.2009 CE00007621
*                                lgart = '/307'" ting ting commented CE00007279
        lgart IN itab_wagedec[] ) AND
*drop record if amount 0.
                                NOT total_wage IS INITIAL.


*by margaret 15/11/2000: positive deductions.

*        IF  itab_total-lgart+0(2) = '9D'.                   "INS MT

        IF  itab_total-lgart IN itab_wagedec[].

          IF ( itab_total-lgart = '/305'  OR
*{ Insert ncslts 29.11.2004
                                         itab_total-lgart = '/314'  OR
*}
                                          itab_total-lgart = '/370'  OR
                                          itab_total-lgart = '/371'  OR
                                          itab_total-lgart = '/372'  OR
                                         itab_total-lgart = '/373'  OR
                                          itab_total-lgart = '/374'  OR
                                         itab_total-lgart = '/563'  OR
               " Start ting ting commented 01.09.2009 Sir 9233
             itab_total-lgart = '9DBF'  OR
            itab_total-lgart = '9DCF'  OR
            " End ting ting commented 01.09.2009
*                                         itab_total-lgart = '/565'  OR
*                                          itab_total-lgart = '/566'  OR
                                          itab_total-lgart = '/375' OR
    itab_total-lgart =  '/305' OR "E'yee,CPF-curr.contr./sum
    itab_total-lgart =  '/370'OR "E'yee, CDAC, add.fund
    itab_total-lgart =  '/371'OR "E'yee, SINDA,add.fund
   itab_total-lgart =  '/372'OR "E'yee, MBMF, add.fund
    itab_total-lgart = '/373'OR "E'yee, ECF   add.fund
    itab_total-lgart = '/374'OR "E'yee, COMCS add.fund
    itab_total-lgart = '/375'OR "E'yee, Other fund
*    itab_total-lgart =  '/565' OR"Carry-over for subs.month
*    itab_total-lgart =  '/566'OR "Carry-over for prev.month
    itab_total-lgart = '/314' "OR "E'YEE, Shortfall on AW
*            itab_total-lgart = '/450' OR
*             itab_total-lgart = '/303' " Ting ting commented 12.06.2009 CE00007621
*             OR itab_total-lgart = '/307'  " ting ting commented CE00007279
           ).
          ELSE.
            itab_total-total_wage = itab_total-total_wage * -1."INS MT
          ENDIF.                                              "INS MT
        ENDIF.

        " ting ting added 01.09.2009 Start SIR9233
        " Cal Prev mth

        IF itab_total-lgart = '9DBF'  OR       itab_total-lgart = '9DCF' OR       itab_total-lgart = '/563'.

          DATA : lv_lines TYPE i.
          DATA : lv_only9dcfand9dbfno563 TYPE char1.
          DATA : lv_flag563 TYPE char1.
          DATA : lv_flagp TYPE char1.
          DATA : lv_indexhere TYPE i.
          DATA : lv_index563 TYPE i.
          DATA : lv_index9dbf TYPE i.
          DATA : lv_index9dcf TYPE i.
          DATA:  lv_total_wage TYPE p DECIMALS 2.
          DATA:  lv_total_wage563 TYPE p DECIMALS 2.
          DATA:  lv_total_wage9dbf TYPE p DECIMALS 2.
          DATA:  lv_total_wage9dcf TYPE p DECIMALS 2.
          CLEAR lv_flag563.
          CLEAR lv_flagp.
          CLEAR lv_total_wage9dbf.
          CLEAR  lv_total_wage9dcf.

*<------------------- Start Modification Reuben 13/7/2010 AVA-128188 ----------------->
*          LOOP AT itab_total WHERE lgart = '/563'.
          LOOP AT temp_itab_total_1 WHERE lgart = '/563' AND pernr = itab_output-perno.
*<------------------- end Modification Reuben 13/7/2010 AVA-128188 ----------------->
            lv_flag563 = 'Y'.
            EXIT.
          ENDLOOP.

*<------------------- Start Modification Reuben 6/7/2010 AVA-128188 ----------------->
*          LOOP AT itab_total WHERE lgart = '9DBF' OR lgart = '9DCF'.
          LOOP AT temp_itab_total_1 WHERE pernr = itab_output-perno AND ( lgart = '9DBF' OR lgart = '9DCF' ).
*<------------------- end Modification Reuben 6/7/2010 AVA-128188 ----------------->
            lv_flagp = 'Y'.
            EXIT.
          ENDLOOP.

          IF ( lv_flag563 = 'Y' ).

            IF ( lv_flagp = 'Y').

              CLEAR itab_totaltemp[].
              CLEAR lv_indexhere.
              CLEAR lv_index563.
              CLEAR lv_total_wage563.
              CLEAR lv_total_wage9dbf.
              CLEAR  lv_total_wage9dcf.

*<------------------- Start Modification Reuben 13/7/2010 AVA-128188 ----------------->
*              LOOP AT itab_total.
              LOOP AT temp_itab_total_1.
*<------------------- End Modification Reuben 13/7/2010 AVA-128188 ----------------->
                lv_indexhere = lv_indexhere + 1.

                IF ( temp_itab_total_1-lgart = '/563' AND temp_itab_total_1-pernr = itab_output-perno ).
                  CLEAR lv_total_wage.
                  lv_total_wage = temp_itab_total_1-total_wage.
                  lv_total_wage563  = lv_total_wage + lv_total_wage563.
                ENDIF.

                IF ( ( temp_itab_total_1-lgart = '9DBF' OR temp_itab_total_1-lgart = '9DCF' ) AND temp_itab_total_1-pernr = itab_output-perno ) .

                  READ TABLE gt_t512 INTO gwa_t512 WITH KEY lgart = '/563'.
                  IF sy-subrc = 0.
                    itab_totaltemp-wage_desc = gwa_t512-lgtxt.
                  ENDIF.

                  itab_totaltemp-lgart = '/563'.
                  CLEAR  lv_total_wage.

                  lv_total_wage = temp_itab_total_1-total_wage.
                  IF ( temp_itab_total_1-lgart = '9DBF' ).
                    lv_total_wage9dbf = lv_total_wage + lv_total_wage9dbf.
                    lv_index9dbf = lv_indexhere.
                  ELSEIF ( temp_itab_total_1-lgart = '9DCF' ).
                    lv_index9dcf = lv_indexhere.
                    lv_total_wage9dcf =  lv_total_wage + lv_total_wage9dcf.
                  ENDIF.

                  DELETE temp_itab_total_1 INDEX lv_indexhere.
*                 Minus 1 is because the index row will get reduce by one.
                  lv_indexhere = lv_indexhere - 1.
                ENDIF.

              ENDLOOP.

              lv_total_wage563 = lv_total_wage9dbf - lv_total_wage9dcf +  lv_total_wage563.

*Comment : Editing the Wage Type '/563' with the formulae stated above.
              LOOP AT temp_itab_total_1 WHERE pernr = itab_output-perno AND
                                              lgart = '/563'.
                temp_itab_total_1-total_wage = lv_total_wage563.
                MODIFY temp_itab_total_1 INDEX sy-tabix.
                CLEAR temp_itab_total_1.
              ENDLOOP.

            ENDIF.
          ELSE.
            CLEAR itab_totaltemp[].
            CLEAR lv_indexhere.

            LOOP AT temp_itab_total_1.
              lv_indexhere = lv_indexhere + 1.

              IF ( temp_itab_total_1-lgart = '9DBF' AND temp_itab_total_1-pernr = itab_output-perno ).

                READ TABLE gt_t512 INTO gwa_t512 WITH KEY lgart = '/563'.
                IF sy-subrc = 0.
                  itab_totaltemp-wage_desc = gwa_t512-lgtxt.
                ENDIF.

                itab_totaltemp-lgart = '/563'.
                CLEAR  lv_total_wage.

                lv_total_wage = temp_itab_total_1-total_wage.
                lv_total_wage9dbf = lv_total_wage + lv_total_wage9dbf.

                DELETE temp_itab_total_1 INDEX lv_indexhere.
                lv_indexhere = lv_indexhere - 1.
              ENDIF.

              IF ( temp_itab_total_1-lgart = '9DCF' AND temp_itab_total_1-pernr = itab_output-perno ).

                READ TABLE gt_t512 INTO gwa_t512 WITH KEY lgart = '/563'.
                IF sy-subrc = 0.
                  itab_totaltemp-wage_desc = gwa_t512-lgtxt.
                ENDIF.

                itab_totaltemp-lgart = '/563'.
                CLEAR  lv_total_wage.

                lv_total_wage = temp_itab_total_1-total_wage.
                lv_total_wage9dcf =  lv_total_wage + lv_total_wage9dcf.

                DELETE temp_itab_total_1 INDEX lv_indexhere.
                lv_indexhere = lv_indexhere - 1.
              ENDIF.

            ENDLOOP.

            itab_totaltemp-total_wage = lv_total_wage9dbf - lv_total_wage9dcf.

*<-- Start of Change Edited by Angela Foong 16/09/10 -->
            "AVA-164196 For instances where there is no /563 but there exist 9DBF and 9DCF, append the record with the pernr
            itab_totaltemp-pernr = itab_total-pernr.
            lv_only9dcfand9dbfno563 = 'Y'.
*<-- End of Change Edited by Angela Foong 16/09/10 -->

            APPEND itab_totaltemp TO temp_itab_total_1.

          ENDIF.
          " End ting ting added 01.09.2009 SIR 9233

        ENDIF.

*Print out specially for the Claim from prev
        IF itab_total-lgart = '/563'.

          LOOP AT temp_itab_total_1 WHERE pernr = itab_output-perno AND
                                            lgart = '/563'.
            total_ded = total_ded + temp_itab_total_1-total_wage.
            PERFORM fill_subtotal USING temp_itab_total_1-lgart
                                   temp_itab_total_1-wage_desc
                                   temp_itab_total_1-total_wage
                                   'D'.
            IF d = 1.
*              WRITE:AT /10(5) text-021 ,15(15)  temp_itab_total_1-wage_desc,'  :  ',"CR-0000000739 - Commented
*                                      (15) temp_itab_total_1-total_wage.
              d = d + 1.
            ELSE.
              IF x  >= 130.
*                NEW-LINE."CR-0000000739 - Commented
                x = 15.
              ENDIF.

*              WRITE: AT x(15) temp_itab_total_1-wage_desc,'  :  ',"CR-0000000739 - Commented
*                         (15) temp_itab_total_1-total_wage.
            ENDIF.

          ENDLOOP.
        ELSEIF itab_total-lgart <> '9DBF' AND itab_total-lgart <> '9DCF'.
          total_ded = total_ded + itab_total-total_wage.
          PERFORM fill_subtotal USING itab_total-lgart
                                      itab_total-wage_desc
                                      itab_total-total_wage
                                   'D'.
          IF d = 1.
*            WRITE:AT /10(5) text-021 ,15(15) itab_total-wage_desc,'  :  ',"CR-0000000739 - Commented
*                                    (15) itab_total-total_wage.
            d = d + 1.
          ELSE.
            IF x  >= 130.
*              NEW-LINE."CR-0000000739 - Commented
              x = 15.
            ENDIF.

*            WRITE: AT x(15) itab_total-wage_desc,'  :  ',"CR-0000000739 - Commented
*                       (15) itab_total-total_wage.
          ENDIF.
*<-- Start of Change Edited by Angela Foong 16/09/10 -->
          "AVA-164196 For WT9DBF and WT9DCF
        ELSEIF itab_total-lgart = '9DBF' OR itab_total-lgart = '9DCF'.
*<-- Start modification PA-881703?  A_JACKY 16.06.2011 Getting table size logic changed to access internal tab TEMP_ITAB_TOTAL_1-->
*          DESCRIBE TABLE itab_total LINES lv_lines. "Get table size
          DESCRIBE TABLE temp_itab_total_1 LINES lv_lines. "Get table size
*<-- End modification PA-881703?  A_JACKY 16.06.2011 -->
          IF lv_lines = sy-tabix AND lv_only9dcfand9dbfno563 = 'Y'. "This is the last loop and there is no /563 record then print the /563
            CLEAR lv_only9dcfand9dbfno563.

            LOOP AT temp_itab_total_1 WHERE pernr = itab_output-perno AND lgart = '/563'. "Get the additional /563 record

              total_ded = total_ded + temp_itab_total_1-total_wage.
              PERFORM fill_subtotal USING temp_itab_total_1-lgart
                                     temp_itab_total_1-wage_desc
                                     temp_itab_total_1-total_wage
                                     'D'.
              IF d = 1.
*                WRITE:AT /10(5) text-021 ,15(15)  temp_itab_total_1-wage_desc,'  :  ',"CR-0000000739 - Commented
*                                        (15) temp_itab_total_1-total_wage.
                d = d + 1.
              ELSE.
                IF x  >= 130.
*                  NEW-LINE."CR-0000000739 - Commented
                  x = 15.
                ENDIF.

*                WRITE: AT x(15) temp_itab_total_1-wage_desc,'  :  ',"CR-0000000739 - Commented
*                           (15) temp_itab_total_1-total_wage.
              ENDIF.

            ENDLOOP.
          ELSE. "This is not the last loop
            CONTINUE. "go to next loop
          ENDIF.
*<-- End of Change Edited by Angela Foong 16/09/10 -->
        ENDIF.
*<------------------- end Modification Reuben 13/7/2010 AVA-128188 ----------------->
        x = x + 40.
*{ Insert ncslts 29.11.2004 AW CPF Ceiling
        IF itab_total-lgart = '/314'.
          ADD 1 TO num_ee_short. "count number of ee shortfall

          itab_ee_short-pernr = itab_output-perno.
          itab_ee_short-nric = itab_output-nric.
          itab_ee_short-ename = itab_output-ename.
          itab_ee_short-cost_center = itab_output-bassal.
          itab_ee_short-amount = itab_total-total_wage.

          APPEND itab_ee_short.
          CLEAR itab_ee_short.
        ENDIF.
*}
      ENDLOOP.

*by margaret 15/11/2000: net_pay = total_pay - total_ded.
      " ting ting commented SIR CE00008296 25.06.2009
*      net_pay = total_pay - total_ded.
      DATA : lv_net_pay TYPE p DECIMALS 2.
      CLEAR lv_net_pay.
      LOOP AT itab_total WHERE pernr = itab_output-perno AND ( lgart = '/557'
                                                         OR    lgart = '/558'
                                                         OR    lgart = '/559' ).
        lv_net_pay = itab_total-total_wage +  lv_net_pay.
      ENDLOOP.

      LOOP AT itab_total WHERE pernr = itab_output-perno AND lgart = '/561'.
        net_pay = lv_net_pay - itab_total-total_wage.
        EXIT.
      ENDLOOP.
      IF sy-subrc <> 0.
        net_pay =  lv_net_pay.
      ENDIF.

* Display employer cpf contribution
*      NEW-LINE."CR-0000000739 - Commented
      x = 10.

      LOOP AT itab_total WHERE pernr = itab_output-perno AND
*{ Replace ncslts 29.11.2004 AW CPF Ceiling
*                                            ( lgart = '/307' )
                           ( lgart = '/307' OR lgart = '/316')
*}
                                AND NOT total_wage IS INITIAL.
*        WRITE: AT x(15) itab_total-wage_desc,':',"CR-0000000739 - Commented
*                 (15) itab_total-total_wage.

        x = x + 40.

        PERFORM fill_subtotal USING itab_total-lgart
                                    itab_total-wage_desc
                                    itab_total-total_wage
                                    'E'.
*{ Insert ncslts 29.11.2004
        IF itab_total-lgart = '/316'.
          ADD 1 TO num_er_short. "count number of er shortfall

          itab_er_short-pernr = itab_output-perno.
          itab_er_short-nric = itab_output-nric.
          itab_er_short-ename = itab_output-ename.
          itab_er_short-cost_center = itab_output-bassal.
          itab_er_short-amount = itab_total-total_wage.

          APPEND itab_er_short.
          CLEAR itab_er_short.
        ENDIF.
*}
      ENDLOOP.
*{ Insert ncslts 29.11.2004 " ting ting commented
*      IF x > 45.
*        NEW-LINE.
*        x = 45.
*      ENDIF.
*}
* compute additional medical contribution
      typedesc = 0. " Total medical contribution

      " Ting Ting 24.06.2009 CE00008250
      LOOP AT itab_total WHERE pernr = itab_output-perno AND
                                     ( lgart = '/37I' ).       "kkl
        typedesc = itab_total-total_wage + typedesc.
      ENDLOOP.

      IF typedesc IS INITIAL.
        LOOP AT itab_total WHERE pernr = itab_output-perno AND
                                             ( lgart = '/37A'  OR
                                            lgart = '/37B' ).       "kkl
          typedesc = itab_total-total_wage + typedesc.
        ENDLOOP.
      ENDIF.




      IF NOT itab_temp-perno IS INITIAL.
        " Ting Ting 24.06.2009 CE00008250
*        WRITE: AT x(15)'TOTAL  MED CONTR:',(15) typedesc, (15)'TOTAL PAYMENT: ',
*                        (15) total_pay,  (15)'DEDUCTIONS:  ', (15) total_ded.
* Display total payment, total deduction, and net payment
*        WRITE: AT x  'TOTAL MED CONTR:',(15) typedesc, 'TOTAL PAYMENT: ',
*                        (15) total_pay,  'DEDUCTIONS:  ', (15) total_ded.
*
*                                           'NET PAYMENT:  ', (15) net_pay.


        " Ting Ting 30.06.2009 CE00008518 arrangement
        IF (  x  >= 130 ).
*          NEW-LINE."CR-0000000739 - Commented
          x = 10.
        ENDIF.

        LOOP AT itab_total WHERE pernr = itab_output-perno AND
                                             ( lgart = '/376' ).
*          WRITE: AT x(15) itab_total-wage_desc, ':',"CR-0000000739 - Commented
*                    (15) itab_total-total_wage.
*
          PERFORM fill_subtotal USING itab_total-lgart
                                      itab_total-wage_desc
                                      itab_total-total_wage
                                      ''.
          x = x + 40.
          IF itab_total-total_wage < 0.
            ADD 1 TO num_neg_sdf. "count number of neg SDF

            itab_ee_neg_sdf-pernr = itab_output-perno.
            itab_ee_neg_sdf-nric = itab_output-nric.
            itab_ee_neg_sdf-ename = itab_output-ename.
            itab_ee_neg_sdf-cost_center = itab_output-bassal.
            itab_ee_neg_sdf-amount = itab_total-total_wage.

            APPEND itab_ee_neg_sdf.
            CLEAR itab_ee_neg_sdf.
          ENDIF.

        ENDLOOP.

        IF (  x  >= 130 ).
*          NEW-LINE."CR-0000000739 - Commented
          x = 10.
        ENDIF.

* /308 FWL
        LOOP AT itab_total WHERE pernr = itab_output-perno AND
                                             ( lgart = '/308' ).
*          WRITE: AT x(15) itab_total-wage_desc, ':',"CR-0000000739 - Commented
*                    (15) itab_total-total_wage.

          PERFORM fill_subtotal USING itab_total-lgart
                                      itab_total-wage_desc
                                      itab_total-total_wage
                                      ''.
          x = x + 40.
        ENDLOOP.

        IF (  x  >= 130 ).
*          NEW-LINE."CR-0000000739 - Commented
          x = 10.
        ENDIF.


* print out the unused MSO portion
        LOOP AT itab_total WHERE pernr = itab_output-perno AND
*                                             ( lgart = '9MSO' ) " ting ting commented
          ( lgart = '4MSO' )
                                  AND NOT total_wage IS INITIAL.
*        x = x + 35.
*          WRITE: AT x(15) itab_total-wage_desc,':',"CR-0000000739 - Commented
*                   (15) itab_total-total_wage .

          PERFORM fill_subtotal USING itab_total-lgart
                                      itab_total-wage_desc
                                      itab_total-total_wage
                                      ''.
          x = x + 40.

        ENDLOOP.

        IF (  x  >= 130 ).
*          NEW-LINE."CR-0000000739 - Commented
          x = 10.
        ENDIF.

*        WRITE: AT x(15) 'TOTAL MED CONTR',':',"CR-0000000739 - Commented
*                   (15) typedesc.
        x = x + 40.

**==>Start of addition, Bernard, SIR 9953
**      LSA CPF Er Contribution
        LOOP AT itab_total WHERE pernr = itab_output-perno AND
          ( lgart = gc_wt_lsa_cpf_er ) AND NOT total_wage IS INITIAL.
          IF (  x  >= 130 ).
*            NEW-LINE."CR-0000000739 - Commented
            x = 10.
          ENDIF.

*          WRITE: AT x(15) itab_total-wage_desc,':',"CR-0000000739 - Commented
*                   (15) itab_total-total_wage .

          PERFORM fill_subtotal USING itab_total-lgart
                                      itab_total-wage_desc
                                      itab_total-total_wage
                                      ''.
          x = x + 40.

        ENDLOOP.

*        NEW-LINE."CR-0000000739 - Commented
        x = 10.
**<==End of addition, Bernard, SIR 9953

*        WRITE: AT x(15) 'TOTAL PAYMENT',':',"CR-0000000739 - Commented
*                   (15) total_pay.
        x = x + 40.
        IF (  x  >= 130 ).
*          NEW-LINE."CR-0000000739 - Commented
          x = 10.
        ENDIF.


*        WRITE: AT x(15) 'DEDUCTIONS',':',"CR-0000000739 - Commented
*                   (15) total_ded.
        x = x + 40.

        IF (  x  >= 130 ).
*          NEW-LINE."CR-0000000739 - Commented
          x = 10.
        ENDIF.
*-- Begin NHB-345704 by AC_CHOPPER: net_pay = total_pay - total_ded.
*   total_pay is neg, total_ded is positive
        COMPUTE net_pay = total_pay - total_ded.
*-- End NHB-345704 by AC_CHOPPER

*        WRITE: AT x(15) 'NET PAYMENT',':',"CR-0000000739 - Commented
*                   (15) net_pay.
        x = x + 40.

      ENDIF.
      PERFORM fill_subtotal USING 'MED'
                                  'Medical'
                                  typedesc
                                  ''.

      PERFORM fill_subtotal USING 'PAY'
                                  'Net Payment'
                                  total_pay
                                  ''.

      PERFORM fill_subtotal USING 'DED'
                                  'Deductions'
                                  total_ded
                                  ''.

      PERFORM fill_subtotal USING 'NET'
                                  'Net Payment'
                                  net_pay
                                  ''.

*    READ TABLE itab_subtotal1 WITH KEY wage = 'MED'.
*    IF sy-subrc = 0.
*      ADD typedesc TO itab_subtotal1-sum.
*      MODIFY itab_subtotal1 INDEX sy-tabix.
*    ELSE.
*      CLEAR itab_subtotal1.
*      itab_subtotal1-wage = 'MED'.
*      itab_subtotal1-desc = 'Medical'.
*      itab_subtotal1-sum = typedesc.
*      itab_subtotal1-ind = ''.
*      APPEND itab_subtotal1.
*    ENDIF.

      count = count + 1. " this is the S/NO counter for ouput display
      typedesc = 0.             "kkl

* /376 E'yer, SDF.
*      NEW-LINE. 08.06.2009
*      x = 15.
*      IF (  x  > 50 ).
*        NEW-LINE.
*        x = 10.
*      ENDIF.


*      IF (  x  >= 130 ).
*        NEW-LINE.
*        x = 10.
*      ENDIF.
*
*      LOOP AT itab_total WHERE pernr = itab_output-perno AND
*                                           ( lgart = '/376' ).
*        WRITE: AT x(15) itab_total-wage_desc, ':',
*                  (15) itab_total-total_wage.
*
*        PERFORM fill_subtotal USING itab_total-lgart
*                                    itab_total-wage_desc
*                                    itab_total-total_wage
*                                    ''.
*        x = x + 40.
*        IF itab_total-total_wage < 0.
*          ADD 1 TO num_neg_sdf. "count number of neg SDF
*
*          itab_ee_neg_sdf-pernr = itab_output-perno.
*          itab_ee_neg_sdf-nric = itab_output-nric.
*          itab_ee_neg_sdf-ename = itab_output-ename.
*          itab_ee_neg_sdf-cost_center = itab_output-bassal.
*          itab_ee_neg_sdf-amount = itab_total-total_wage.
*
*          APPEND itab_ee_neg_sdf.
*          CLEAR itab_ee_neg_sdf.
*        ENDIF.
*
*      ENDLOOP.
*
*      IF (  x  >= 130 ).
*        NEW-LINE.
*        x = 10.
*      ENDIF.
*
** /308 FWL
*      LOOP AT itab_total WHERE pernr = itab_output-perno AND
*                                           ( lgart = '/308' ).
*        WRITE: AT x(15) itab_total-wage_desc, ':',
*                  (15) itab_total-total_wage.
*
*        PERFORM fill_subtotal USING itab_total-lgart
*                                    itab_total-wage_desc
*                                    itab_total-total_wage
*                                    ''.
*        x = x + 40.
*      ENDLOOP.
*
*      IF (  x  >= 130 ).
*        NEW-LINE.
*        x = 10.
*      ENDIF.
*
*
** print out the unused MSO portion
*      LOOP AT itab_total WHERE pernr = itab_output-perno AND
**                                             ( lgart = '9MSO' ) " ting ting commented
*        ( lgart = '4MSO' )
*                                AND NOT total_wage IS INITIAL.
**        x = x + 35.
*        WRITE: AT x(15) itab_total-wage_desc,':',
*                 (15) itab_total-total_wage .
*
*        PERFORM fill_subtotal USING itab_total-lgart
*                                    itab_total-wage_desc
*                                    itab_total-total_wage
*                                    ''.
*
*      ENDLOOP.


*** This section will print out '>>' should the bank transfer amt
*** does not tally with the calculated amount.
*      LOOP AT itab_total WHERE pernr = itab_output-perno
*                         AND lgart = '/559'.
*        IF itab_total-total_wage NE net_pay.
*          WRITE:1 '>>'.
*        ENDIF.
*      ENDLOOP.
*
*      if sy-subrc ne 0.
*        WRITE:1 '>>'.
*      endif.

** To store officers who are inactive in current payroll
      TABLES pa0000.
* AUCT-UPGRADE -  Begin of Modification by <USER> on <17.02.2017> for <EHP8>
*      SELECT SINGLE * FROM pa0000
*        WHERE pernr = itab_output-perno
*        AND begda <= payroll_last_day
*        AND endda >= payroll_last_day
*        AND sprps NE 'X'
*        AND stat2 NE '3'.
      SELECT * UP TO 1 ROWS FROM pa0000
      WHERE pernr = itab_output-perno
      AND begda <= payroll_last_day
      AND endda >= payroll_last_day
      AND sprps NE 'X'
      AND stat2 NE '3'
      ORDER BY PRIMARY KEY.
      ENDSELECT.
* AUCT-UPGRADE -  End of Modification by <USER> on <17.02.2017> for <EHP8>

      IF sy-subrc = 0.
        ADD 1 TO num_ee_inactive. "count number of inactive ee
        itab_ee_inactive-pernr = itab_output-perno.
        itab_ee_inactive-nric = itab_output-nric.
        itab_ee_inactive-ename = itab_output-ename.
*          itab_ee_inactive-cost_center = itab_output-bassal.
*          itab_ee_inactive-amount = itab_total-total_wage.
        APPEND itab_ee_inactive.
        CLEAR itab_ee_inactive.
      ENDIF.

** To store officers with neg EE CPF Contrib.
      LOOP AT itab_total WHERE pernr = itab_output-perno AND
                                           ( lgart = '/305' ).

        IF itab_total-total_wage < 0.
          ADD 1 TO num_neg_ee_cpf. "count number of ee with negative
          "EE CPF contribution

          itab_ee_neg_cpf-pernr = itab_output-perno.
          itab_ee_neg_cpf-nric = itab_output-nric.
          itab_ee_neg_cpf-ename = itab_output-ename.
          itab_ee_neg_cpf-cost_center = itab_output-bassal.
          itab_ee_neg_cpf-amount = itab_total-total_wage.

          APPEND itab_ee_neg_cpf.
          CLEAR itab_ee_neg_cpf.
        ENDIF.
      ENDLOOP.

** To store officers with payment of balance.
      LOOP AT itab_total WHERE pernr = itab_output-perno AND
                                           ( lgart = '/558' ).

        ADD 1 TO num_ee_balance_pay. "count number of ee with balance

        itab_ee_balance_pay-pernr = itab_output-perno.
        itab_ee_balance_pay-nric = itab_output-nric.
        itab_ee_balance_pay-ename = itab_output-ename.
        itab_ee_balance_pay-cost_center = itab_output-bassal.
        itab_ee_balance_pay-amount = itab_total-total_wage.

        APPEND itab_ee_balance_pay.
        CLEAR itab_ee_balance_pay.
      ENDLOOP.

*<------------------- start Modification Reuben 13/7/2010 AVA-128188 ----------------->
** To store officers with wage type claim from prev mth.
      LOOP AT temp_itab_total_1 WHERE pernr = itab_output-perno AND
                                           ( lgart = '/563' ) AND
                                           ( total_wage <> 0 ).

        ADD 1 TO num_claim_prev. "count number of ee with claim from
        "prev wage type

        itab_ee_claim_prev-pernr = itab_output-perno.
        itab_ee_claim_prev-nric = itab_output-nric.
        itab_ee_claim_prev-ename = itab_output-ename.
        itab_ee_claim_prev-cost_center = itab_output-bassal.
*        itab_ee_claim_prev-amount = itab_total-total_wage.
        itab_ee_claim_prev-amount = temp_itab_total_1-total_wage.

        APPEND itab_ee_claim_prev.
        CLEAR itab_ee_claim_prev.
      ENDLOOP.
*<------------------- end Modification Reuben 13/7/2010 AVA-128188 ----------------->
** Total net payment amount
      ADD net_pay TO total_net_payment.
      ADD 1 TO num_net_payment. "count number of net payment

      IF net_pay EQ 0.
        ADD 1 TO num_zero_payment. "count number of zero payment
*<-- Start modification SR-PA-000?0011353 DE0K9A0XQP A_JACKY 22.06.2011 Zero Amount Officers’ summary added into report output-->
        gwa_zero_payment-pernr       = itab_output-perno.
        gwa_zero_payment-nric        = itab_output-nric.
        gwa_zero_payment-ename       = itab_output-ename.
        gwa_zero_payment-cost_center = itab_output-bassal.
        APPEND gwa_zero_payment TO itab_zero_payment.
        CLEAR gwa_zero_payment.
*<-- End modification SR-PA-000?0011353 DE0K9A0XQP A_JACKY 22.06.2011 Zero Amount Officers’ summary added into report output-->
      ENDIF.

** Total bank transfer amount
      LOOP AT itab_total WHERE pernr = itab_output-perno
                         AND ( lgart = '/559'
                         OR lgart = '/558' ).
        ADD itab_total-total_wage TO total_bank_transfer.
      ENDLOOP.

      IF sy-subrc = 0.
        ADD 1 TO num_bank_transfer. "count number of bank Transfer
      ENDIF.

** Total cash payment
      LOOP AT itab_total WHERE pernr = itab_output-perno
                         AND lgart = '/557'.
      ENDLOOP.

      IF sy-subrc = 0.

        ADD itab_total-total_wage TO total_cash_payment.
        ADD 1 TO num_cash_payment. "count number of cash payment

        itab_ee_cash_payment-pernr = itab_output-perno.
        itab_ee_cash_payment-nric = itab_output-nric.
        itab_ee_cash_payment-ename = itab_output-ename.
        itab_ee_cash_payment-cost_center = itab_output-bassal.
        itab_ee_cash_payment-amount = itab_total-total_wage.

        APPEND itab_ee_cash_payment.
        CLEAR itab_ee_cash_payment.

      ENDIF.

** Total negative payment
      LOOP AT itab_total WHERE pernr = itab_output-perno
                         AND lgart = '/561'.
      ENDLOOP.

      IF sy-subrc = 0.
        ADD itab_total-total_wage TO total_negative_payment.
        ADD 1 TO num_negative_payment. "count number of negative payment

        itab_ee_neg_payment-pernr = itab_output-perno.
        itab_ee_neg_payment-nric = itab_output-nric.
        itab_ee_neg_payment-ename = itab_output-ename.
        itab_ee_cash_payment-cost_center = itab_output-bassal.
        itab_ee_neg_payment-amount = itab_total-total_wage.
        APPEND itab_ee_neg_payment.
        CLEAR itab_ee_neg_payment.

      ENDIF.


      CLEAR: tmpunit, tmpdesc, tmpcpf, total_pay, total_ded, net_pay.

*      SKIP."CR-0000000739 - Commented
*      ULINE.

    ENDIF.

    AT END OF (subtotal_field1).
*      RESERVE 10 LINES."CR-0000000739 - Commented
*      FORMAT COLOR COL_TOTAL .
*      WRITE:/'Total officers per'.

*      CASE subtotal_field1.
*        WHEN 'S1'.
*          READ TABLE itab_sort INDEX 1.
*          IF sy-subrc = 0.
*            WRITE: itab_sort-desc.
*            WRITE: itab_output-s1 LEFT-JUSTIFIED NO-ZERO.
*            PERFORM display_subtotal1.
*            PERFORM display_summary1.
*          ENDIF.
*        WHEN 'S2'.
*          READ TABLE itab_sort INDEX 2.
*          IF sy-subrc = 0.
*            WRITE: itab_sort-desc.
*            WRITE: itab_output-s2 LEFT-JUSTIFIED NO-ZERO.
*            PERFORM display_subtotal1.
*            PERFORM display_summary2.
*          ENDIF.
*        WHEN 'S3'.
*          READ TABLE itab_sort INDEX 3.
*          IF sy-subrc = 0.
*            WRITE: itab_sort-desc.
*            WRITE: itab_output-s3 LEFT-JUSTIFIED NO-ZERO.
*            PERFORM display_subtotal1.
*            PERFORM display_summary3.
*          ENDIF.
*        WHEN 'S4'.
*          READ TABLE itab_sort INDEX 4.
*          IF sy-subrc = 0.
*            WRITE: itab_sort-desc.
*            WRITE: itab_output-s4 LEFT-JUSTIFIED NO-ZERO.
*            PERFORM display_subtotal1.
*            PERFORM display_summary4.
*          ENDIF.
*      ENDCASE.
*      WRITE: itab_sub1-sal_point.
*      FORMAT COLOR OFF.
    ENDAT.

    AT END OF (subtotal_field2).
*      RESERVE 10 LINES."CR-0000000739 - Commented
*      FORMAT COLOR COL_TOTAL .
*
*      WRITE:/'Total officers per'.
*      CASE subtotal_field2.
*
** eg. the subtotal field is at sort seq 1.
*        WHEN 'S1'.
*          READ TABLE itab_sort INDEX 1.
*          IF sy-subrc = 0.
*            WRITE: itab_sort-desc.
*            WRITE: itab_output-s1 LEFT-JUSTIFIED NO-ZERO.
*            PERFORM display_subtotal2.
*            PERFORM display_summary1.
*          ENDIF.
*
*        WHEN 'S2'.
*          READ TABLE itab_sort INDEX 2.
*          IF sy-subrc = 0.
*            WRITE: itab_sort-desc.
*            WRITE: itab_output-s2 LEFT-JUSTIFIED NO-ZERO.
*            PERFORM display_subtotal2.
*            PERFORM display_summary2.
*          ENDIF.
*
*        WHEN 'S3'.
*          READ TABLE itab_sort INDEX 3.
*          IF sy-subrc = 0.
*            WRITE: itab_sort-desc.
*            WRITE: itab_output-s3 LEFT-JUSTIFIED NO-ZERO.
*            PERFORM display_subtotal2.
*            PERFORM display_summary3.
*          ENDIF.
*
*        WHEN 'S4'.
*          READ TABLE itab_sort INDEX 4.
*          IF sy-subrc = 0.
*            WRITE: itab_sort-desc.
*            WRITE: itab_output-s4 LEFT-JUSTIFIED NO-ZERO.
*            PERFORM display_subtotal2.
*            PERFORM display_summary4.
*          ENDIF.
*
*      ENDCASE.
*
*      FORMAT COLOR OFF.
    ENDAT.

    AT END OF (subtotal_field3).
*      RESERVE 10 LINES."CR-0000000739 - Commented
*      FORMAT COLOR COL_TOTAL .
*      WRITE:/'Total officers per'.

*      CASE subtotal_field3.
*        WHEN 'S1'.
*          READ TABLE itab_sort INDEX 1.
*          IF sy-subrc = 0.
*            WRITE: itab_sort-desc.
*            WRITE: itab_output-s1 LEFT-JUSTIFIED NO-ZERO.
*            PERFORM display_subtotal3.
*            PERFORM display_summary1.
*          ENDIF.
*        WHEN 'S2'.
*          READ TABLE itab_sort INDEX 2.
*          IF sy-subrc = 0.
*            WRITE: itab_sort-desc.
*            WRITE: itab_output-s2 LEFT-JUSTIFIED NO-ZERO.
*            PERFORM display_subtotal3.
*            PERFORM display_summary2.
*          ENDIF.
*        WHEN 'S3'.
*          READ TABLE itab_sort INDEX 3.
*          IF sy-subrc = 0.
*            WRITE: itab_sort-desc.
*            WRITE: itab_output-s3 LEFT-JUSTIFIED NO-ZERO.
*            PERFORM display_subtotal3.
*            PERFORM display_summary3.
*          ENDIF.
*        WHEN 'S4'.
*          READ TABLE itab_sort INDEX 4.
*          IF sy-subrc = 0.
*            WRITE: itab_sort-desc.
*            WRITE: itab_output-s4 LEFT-JUSTIFIED NO-ZERO.
*            PERFORM display_subtotal3.
*            PERFORM display_summary4.
*          ENDIF.
*      ENDCASE.
*      FORMAT COLOR OFF.
    ENDAT.

    AT END OF (subtotal_field4).
*      RESERVE 10 LINES."CR-0000000739 - Commented
*      FORMAT COLOR COL_TOTAL .
*      WRITE:/'Total officers per'.

*      CASE subtotal_field4.
*        WHEN 'S1'.
*          READ TABLE itab_sort INDEX 1.
*          IF sy-subrc = 0.
*            WRITE: itab_sort-desc.
*            WRITE: itab_output-s1 LEFT-JUSTIFIED NO-ZERO.
*            PERFORM display_subtotal4.
*            PERFORM display_summary1.
*          ENDIF.
*        WHEN 'S2'.
*          READ TABLE itab_sort INDEX 2.
*          IF sy-subrc = 0.
*            WRITE: itab_sort-desc.
*            WRITE: itab_output-s2 LEFT-JUSTIFIED NO-ZERO.
*            PERFORM display_subtotal4.
*            PERFORM display_summary2.
*          ENDIF.
*        WHEN 'S3'.
*          READ TABLE itab_sort INDEX 3.
*          IF sy-subrc = 0.
*            WRITE: itab_sort-desc.
*            WRITE: itab_output-s3 LEFT-JUSTIFIED NO-ZERO.
*            PERFORM display_subtotal4.
*            PERFORM display_summary3.
*          ENDIF.
*        WHEN 'S4'.
*          READ TABLE itab_sort INDEX 4.
*          IF sy-subrc = 0.
*            WRITE: itab_sort-desc.
*            WRITE: itab_output-s4 LEFT-JUSTIFIED NO-ZERO.
*            PERFORM display_subtotal4.
*            PERFORM display_summary4.
*          ENDIF.
*      ENDCASE.
*      FORMAT COLOR OFF.
    ENDAT.

    AT END OF (subtotal_field5).
*      RESERVE 10 LINES."CR-0000000739 - Commented
*      FORMAT COLOR COL_TOTAL .
*      WRITE:/'Total officers per'.

*      CASE subtotal_field5.
*        WHEN 'S1'.
*          READ TABLE itab_sort INDEX 1.
*          IF sy-subrc = 0.
*            WRITE: itab_sort-desc.
*            WRITE: itab_output-s1 LEFT-JUSTIFIED NO-ZERO.
*            PERFORM display_subtotal5.
*            PERFORM display_summary1.
**           PERFORM display_compare.
*          ENDIF.
*        WHEN 'S2'.
*          READ TABLE itab_sort INDEX 2.
*          IF sy-subrc = 0.
*            WRITE: itab_sort-desc.
*            WRITE: itab_output-s2 LEFT-JUSTIFIED NO-ZERO.
*            PERFORM display_subtotal5.
*            PERFORM display_summary2.
**           PERFORM display_compare.
*          ENDIF.
*        WHEN 'S3'.
*          READ TABLE itab_sort INDEX 3.
*          IF sy-subrc = 0.
*            WRITE: itab_sort-desc.
*            WRITE: itab_output-s3 LEFT-JUSTIFIED NO-ZERO.
*            PERFORM display_subtotal5.
*            PERFORM display_summary3.
**           PERFORM display_compare.
*          ENDIF.
*        WHEN 'S4'.
*          READ TABLE itab_sort INDEX 4.
*          IF sy-subrc = 0.
*            WRITE: itab_sort-desc.
*            WRITE: itab_output-s4 LEFT-JUSTIFIED NO-ZERO.
*            PERFORM display_subtotal5.
*            PERFORM display_summary4.
**           PERFORM display_compare.
*          ENDIF.
*      ENDCASE.
*      FORMAT COLOR OFF.
    ENDAT.

  ENDLOOP.

ENDFORM.                    "formatting


*---------------------------------------------------------------------*
*       FORM display_subtotal1                                        *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM display_subtotal1.

  DATA: ind1 TYPE i.
  DATA: col1 TYPE i.

  ind1 = 1.
  col1 = 15.

* This is to cater for previous payroll personnel's cc
* not found in the current payroll
* this is a rare case.
  IF itab_temp-perno IS INITIAL.
    WRITE: ':' , '0' LEFT-JUSTIFIED.
    WRITE: AT 150 ' '.
    ULINE.
    EXIT.
  ENDIF.
  " ting ting added 0
  LOOP AT itab_subtotal1 WHERE ind = 'N' AND sum <> 0 AND wage <> '0725'  AND wage  <> '4MSO' AND wage <> '0ERA'. " SIR CE00007858 Ting Ting added 17.06.2009 " SIR CE00007762 Ting Ting added 15.06.2009. " < SIR CE00007391.
  ENDLOOP.
  IF sy-subrc = 0.
    WRITE: ':' , itab_subtotal1-sum DECIMALS 0 LEFT-JUSTIFIED.
    WRITE: AT 150 ' '.
  ENDIF.

  LOOP AT itab_subtotal1 WHERE ind = 'A' AND sum <> 0 AND wage <> '0725' AND wage  <> '4MSO' AND wage <> '0ERA'. " SIR CE00007858 Ting Ting added 17.06.2009 " SIR CE00007762 Ting Ting added 15.06.2009.. " < SIR CE00007391.
    IF ind1 = 1.
      WRITE: AT /10(5) TEXT-020 ,15(15) itab_subtotal1-desc,
                        '  :  ' , (15) itab_subtotal1-sum.
      WRITE: AT 150 ' '.
      ind1 = ind1 + 1.
    ELSE.
      IF col1 >= 130.
        NEW-LINE.
        col1 = 15.
      ENDIF.
      WRITE: AT col1(15) itab_subtotal1-desc,
                      '  :  ',
                 (15) itab_subtotal1-sum.
      WRITE: AT 150 ' '.
    ENDIF.
    col1  =  col1 + 40.
  ENDLOOP.

  ind1 = 1.
  col1 = 15.

  LOOP AT itab_subtotal1 WHERE ind = 'D' AND sum <> 0 AND wage <> '0725'AND wage  <> '4MSO' AND wage <> '0ERA'. " SIR CE00007858 Ting Ting added 17.06.2009 " SIR CE00007762 Ting Ting added 15.06.2009.. " < SIR CE00007391.
    IF ind1 = 1.
      WRITE: AT /10(5) TEXT-021 ,15(15) itab_subtotal1-desc,
                        '  :  ' , (15) itab_subtotal1-sum.
      WRITE: AT 150 ' '.
      ind1 = ind1 + 1.
    ELSE.
      IF col1  >= 130.
        NEW-LINE.
        col1 = 15.
      ENDIF.
      WRITE: AT col1(15) itab_subtotal1-desc,
                      '  :  ',
                 (15) itab_subtotal1-sum.
      WRITE: AT 150 ' '.
    ENDIF.
    col1  =  col1 + 40.
  ENDLOOP.

* employer CPF
  NEW-LINE.
  col1 = 10.

  LOOP AT itab_subtotal1 WHERE ind = 'E' AND sum <> 0 AND wage <> '0725' AND wage  <> '4MSO' AND wage <> '0ERA'. " SIR CE00007858 Ting Ting added 17.06.2009 " SIR CE00007762 Ting Ting added 15.06.2009.. " < SIR CE00007391.
    WRITE: AT col1(15) itab_subtotal1-desc,':',
       (15) itab_subtotal1-sum.
    WRITE: AT 150 ' '.
    col1 = col1 + 40.
  ENDLOOP.

* total
  DATA: total_pay TYPE p DECIMALS 2, "total payment
        total_ded TYPE p DECIMALS 2, "total deduction
        typedesc  TYPE p DECIMALS 2,
        net_pay   TYPE p DECIMALS 2.

  CLEAR: total_pay, total_ded, typedesc, net_pay.

  LOOP AT itab_subtotal1 WHERE ind = ''.
    IF itab_subtotal1-wage = 'MED'.
      typedesc = itab_subtotal1-sum.
    ENDIF.
    IF itab_subtotal1-wage = 'PAY'.
      total_pay = itab_subtotal1-sum.
    ENDIF.
    IF itab_subtotal1-wage = 'DED'.
      total_ded = itab_subtotal1-sum.
    ENDIF.
    IF itab_subtotal1-wage = 'NET'.
      net_pay = itab_subtotal1-sum.
    ENDIF.
  ENDLOOP.

* Display total payment, total deduction, and net payment
  " TIng Ting 24.06.2009 CE00008250
*  WRITE: AT col1 'TOTAL MED CONTR:',(15) typedesc, 'TOTAL PAYMENT: ',
*                    (15) total_pay,  'DEDUCTIONS:  ', (15) total_ded.
**                             'NET PAYMENT:  ', (15) net_pay.


  IF (  col1 >= 130 ).
    NEW-LINE.
    col1 = 10.
  ENDIF.

  LOOP AT itab_subtotal1 WHERE ind = ''
                    AND wage = '/376' .
    WRITE: AT col1(15) itab_subtotal1-desc, ':',
             (15) itab_subtotal1-sum.
*    WRITE: AT 150 ' '.
    col1 = col1 + 40.
  ENDLOOP.

*  LOOP AT itab_subtotal1 WHERE ind = ''
*                         AND wage = '/376' .
*    WRITE: /10(15) itab_subtotal1-desc, '  :  ',
*              (15) itab_subtotal1-sum.
**    WRITE: AT 150 ' '.
*  ENDLOOP.

  IF ( col1  >= 130 ).
    NEW-LINE.
    col1 = 10.
  ENDIF.
  " Ting Ting added 25.06.2009 CE00007737
  LOOP AT itab_subtotal1 WHERE ind = ''
                         AND wage = '/308' .
    WRITE: AT col1(15) itab_subtotal1-desc, ':',
              (15) itab_subtotal1-sum.
    col1 = col1 + 40.
*    WRITE: AT 150 ' '.
  ENDLOOP.

* 9MSO
  IF ( col1  >= 130 ).
    NEW-LINE.
    col1 = 10.
  ENDIF.
  LOOP AT itab_subtotal1 WHERE ind = ''
*                         AND wage = '9MSO' " ting ting commented
    AND wage = '4MSO'
                         AND NOT sum IS INITIAL.
    WRITE: AT col1(15) itab_subtotal1-desc,':',
              (15) itab_subtotal1-sum.

*    WRITE: AT 150 ' '.
    col1 = col1 + 40.
  ENDLOOP.


  IF ( col1  >= 130 ).
    NEW-LINE.
    col1 = 10.
  ENDIF.

  WRITE: AT col1(15)  'TOTAL MED CONTR',':',
      (15) typedesc.
  col1 = col1 + 40.

*==>Start of addition, Bernard, SIR 9953
  LOOP AT itab_subtotal1 WHERE ind = ''
    AND wage = gc_wt_lsa_cpf_er AND NOT sum IS INITIAL.

    IF ( col1  >= 130 ).
      NEW-LINE.
      col1 = 10.
    ENDIF.

    WRITE: AT col1(15) itab_subtotal1-desc,':',
              (15) itab_subtotal1-sum.

  ENDLOOP.
*<==End of addition, Bernard, SIR 9953

  NEW-LINE.
  col1 = 10.

  WRITE: AT col1(15)  'TOTAL PAYMENT',':',
      (15) total_pay.
  col1 = col1 + 40.


  IF ( col1  >= 130 ).
    NEW-LINE.
    col1 = 10.
  ENDIF.

  WRITE: AT col1(15)  'DEDUCTIONS',':',
      (15) total_ded.
  col1 = col1 + 40.

  IF ( col1  >= 130 ).
    NEW-LINE.
    col1 = 10.
  ENDIF.

  WRITE: AT col1(15)  'NET PAYMENT',':',
      (15) net_pay.
  col1 = col1 + 40.
*  WRITE: AT col1 'TOTAL  MED CONTR:',(15) typedesc, 'TOTAL PAYMENT: ',
*                    (15) total_pay,  'DEDUCTIONS:  ', (15) total_ded.
*                             'NET PAYMENT:  ', (15) net_pay.



*  WRITE: AT col1(15) 'NET PAYMENT', '  :  ',
*              (15) net_pay.
*  WRITE: AT 150 ' '.
*  WRITE: AT 150 ' '.
*  WRITE: /10(15) 'NET PAYMENT',':',
*            (15) net_pay.

*  NEW-LINE.
*  col1 = 10.

*  IF (  col1 >= 130 ).
*    NEW-LINE.
*    col1 = 10.
*  ENDIF.
*
*  WRITE: AT col1(15)  'NET PAYMENT',':',
*            (15) net_pay.
*  col1 = col1 + 40.
*
*  IF ( col1  >= 130 ).
*    NEW-LINE.
*    col1 = 10.
*  ENDIF.
*
*  LOOP AT itab_subtotal1 WHERE ind = ''
*                    AND wage = '/376' .
*    WRITE: AT col1(15) itab_subtotal1-desc, ':',
*             (15) itab_subtotal1-sum.
**    WRITE: AT 150 ' '.
*    col1 = col1 + 40.
*  ENDLOOP.
*
**  LOOP AT itab_subtotal1 WHERE ind = ''
**                         AND wage = '/376' .
**    WRITE: /10(15) itab_subtotal1-desc, '  :  ',
**              (15) itab_subtotal1-sum.
***    WRITE: AT 150 ' '.
**  ENDLOOP.
*
*  IF ( col1  >= 130 ).
*    NEW-LINE.
*    col1 = 10.
*  ENDIF.
*  " Ting Ting added 25.06.2009 CE00007737
*  LOOP AT itab_subtotal1 WHERE ind = ''
*                         AND wage = '/308' .
*    WRITE: AT col1(15) itab_subtotal1-desc, ':',
*              (15) itab_subtotal1-sum.
*    col1 = col1 + 40.
**    WRITE: AT 150 ' '.
*  ENDLOOP.
*
** 9MSO
*  IF ( col1  >= 130 ).
*    NEW-LINE.
*    col1 = 10.
*  ENDIF.
*  LOOP AT itab_subtotal1 WHERE ind = ''
**                         AND wage = '9MSO' " ting ting commented
*    AND wage = '4MSO'
*                         AND NOT sum IS INITIAL.
*    WRITE: AT col1(15) itab_subtotal1-desc,':',
*              (15) itab_subtotal1-sum.
*
*    WRITE: AT 150 ' '.
*  ENDLOOP.

  ULINE.

ENDFORM.                    "display_subtotal1

*---------------------------------------------------------------------*
*       FORM display_subtotal2                                        *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM display_subtotal2.

  DATA: ind1 TYPE i.
  DATA: col1 TYPE i.

  ind1 = 1.
  col1 = 15.

* This is to cater for previous payroll personnel's cc
* not found in the current payroll
* this is a rare case.
  IF itab_temp-perno IS INITIAL.
    WRITE: ':' , '0' LEFT-JUSTIFIED.
    WRITE: AT 150 ' '.
    ULINE.
    EXIT.
  ENDIF.

  LOOP AT itab_subtotal2 WHERE ind = 'N' AND sum <> 0 AND wage <> '0725' AND wage  <> '4MSO' AND wage <> '0ERA'. " SIR CE00007858 Ting Ting added 17.06.2009 " SIR CE00007762 Ting Ting added 15.06.2009.. " < SIR CE00007391.
  ENDLOOP.
  IF sy-subrc = 0.
    WRITE: ':' , itab_subtotal2-sum DECIMALS 0 LEFT-JUSTIFIED.
    WRITE: AT 150 ' '.
  ENDIF.

  LOOP AT itab_subtotal2 WHERE ind = 'A'AND sum <> 0 AND wage <> '0725' AND wage  <> '4MSO' AND wage <> '0ERA'. " SIR CE00007858 Ting Ting added 17.06.2009 " SIR CE00007762 Ting Ting added 15.06.2009.. " < SIR CE00007391.
    IF ind1 = 1.
      WRITE: AT /10(5) TEXT-020 ,15(15) itab_subtotal2-desc,
                        '  :  ' , (15) itab_subtotal2-sum.
      WRITE: AT 150 ' '.
      ind1 = ind1 + 1.
    ELSE.
      IF col1  >= 130.
        NEW-LINE.
        col1 = 15.
      ENDIF.
      WRITE: AT col1(15) itab_subtotal2-desc,
                      '  :  ',
                 (15) itab_subtotal2-sum.

      WRITE: AT 150 ' '.
    ENDIF.
    col1  =  col1 + 40.
  ENDLOOP.

  ind1 = 1.
  col1 = 15.

  LOOP AT itab_subtotal2 WHERE ind = 'D'AND sum <> 0 AND wage <> '0725' AND wage  <> '4MSO' AND wage <> '0ERA'. " SIR CE00007858 Ting Ting added 17.06.2009 " SIR CE00007762 Ting Ting added 15.06.2009.. " < SIR CE00007391.
    IF ind1 = 1.
      WRITE: AT /10(5) TEXT-021 ,15(15) itab_subtotal2-desc,
                        '  :  ' , (15) itab_subtotal2-sum.
      WRITE: AT 150 ' '.

      ind1 = ind1 + 1.
    ELSE.
      IF col1  >= 130.
        NEW-LINE.
        col1 = 15.
      ENDIF.
      WRITE: AT col1(15) itab_subtotal2-desc,
                      '  :  ',
                 (15) itab_subtotal2-sum.
      WRITE: AT 150 ' '.
    ENDIF.
    col1  =  col1 + 40.
  ENDLOOP.

* employer CPF
  NEW-LINE.
  col1 = 10.

  LOOP AT itab_subtotal2 WHERE ind = 'E' AND sum <> 0 AND wage <> '0725' AND wage  <> '4MSO' AND wage <> '0ERA'. " SIR CE00007858 Ting Ting added 17.06.2009 " SIR CE00007762 Ting Ting added 15.06.2009.. " < SIR CE00007391.
    WRITE: AT col1(15) itab_subtotal2-desc,':',
       (15) itab_subtotal2-sum.
    WRITE: AT 150 ' '.
    col1 = col1 + 40.
  ENDLOOP.

* total
  DATA: total_pay TYPE p DECIMALS 2, "total payment
        total_ded TYPE p DECIMALS 2, "total deduction
        typedesc  TYPE p DECIMALS 2,
        net_pay   TYPE p DECIMALS 2.

  CLEAR: total_pay, total_ded, typedesc, net_pay.

  LOOP AT itab_subtotal2 WHERE ind = ''.
    IF itab_subtotal2-wage = 'MED'.
      typedesc = itab_subtotal2-sum.
    ENDIF.
    IF itab_subtotal2-wage = 'PAY'.
      total_pay = itab_subtotal2-sum.
    ENDIF.
    IF itab_subtotal2-wage = 'DED'.
      total_ded = itab_subtotal2-sum.
    ENDIF.
    IF itab_subtotal2-wage = 'NET'.
      net_pay = itab_subtotal2-sum.
    ENDIF.
  ENDLOOP.

* Display total payment, total deduction, and net payment
  " TIng Ting 24.06.2009 CE00008250
*  WRITE: AT col1 'TOTAL MED CONTR:',(15) typedesc, 'TOTAL PAYMENT: ',
*                    (15) total_pay,  'DEDUCTIONS:  ', (15) total_ded.
*                             'NET PAYMENT:  ', (15) net_pay.
  IF col1  >= 130.
    NEW-LINE.
    col1 = 10.
  ENDIF.

  LOOP AT itab_subtotal2 WHERE ind = ''
                        AND wage = '/376'.
    WRITE: AT col1(15) itab_subtotal2-desc, ':',
              (15) itab_subtotal2-sum.
*    WRITE: AT 150 ' '.
    col1 = col1 + 40.
  ENDLOOP.

*  LOOP AT itab_subtotal2 WHERE ind = ''
*                         AND wage = '/376'.
*    WRITE: /10(15) itab_subtotal2-desc, '  :  ',
*              (15) itab_subtotal2-sum.
**    WRITE: AT 150 ' '.
*  ENDLOOP.

  " Ting Ting added 25.06.2009 CE00007737
  IF col1  >= 130.
    NEW-LINE.
    col1 = 10.
  ENDIF.
  LOOP AT itab_subtotal2 WHERE ind = ''
                         AND wage = '/308' .
    WRITE: AT col1(15) itab_subtotal2-desc, ':',
              (15) itab_subtotal2-sum.
    col1 = col1 + 40.
*    WRITE: AT 150 ' '.
  ENDLOOP.

* 9MSO
  IF col1  >= 130.
    NEW-LINE.
    col1 = 10.
  ENDIF.
  LOOP AT itab_subtotal2 WHERE ind = ''
*                         AND wage = '9MSO' " ting ting comment
    AND wage = '4MSO'
                         AND NOT sum IS INITIAL.
    WRITE: AT col1(15) itab_subtotal2-desc,':',
              (15) itab_subtotal2-sum.
    col1 = col1 + 40.
*    WRITE: AT 150 ' '.
  ENDLOOP.

  IF col1  >= 130.
    NEW-LINE.
    col1 = 10.
  ENDIF.

  WRITE: AT col1(15)  'TOTAL MED CONTR',':',
      (15) typedesc.
  col1 = col1 + 40.

*==>Start of addition, Bernard, SIR 9953
  LOOP AT itab_subtotal2 WHERE ind = ''
    AND wage = gc_wt_lsa_cpf_er AND NOT sum IS INITIAL.

    IF ( col1  >= 130 ).
      NEW-LINE.
      col1 = 10.
    ENDIF.

    WRITE: AT col1(15) itab_subtotal2-desc,':',
              (15) itab_subtotal2-sum.

  ENDLOOP.
*<==End of addition, Bernard, SIR 9953

  NEW-LINE.
  col1 = 10.

  WRITE: AT col1(15)  'TOTAL PAYMENT',':',
      (15) total_pay.
  col1 = col1 + 40.

  IF col1  >= 130.
    NEW-LINE.
    col1 = 10.
  ENDIF.

  WRITE: AT col1(15)  'DEDUCTIONS',':',
      (15) total_ded.
  col1 = col1 + 40.

*  WRITE: AT col1 'TOTAL  MED CONTR:',(15) typedesc, 'TOTAL PAYMENT: ',
*                    (15) total_pay,  'DEDUCTIONS:  ', (15) total_ded.
*  WRITE: AT col1(15) 'NET PAYMENT',':',
*              (15) net_pay.
*
*  WRITE: AT 150 ' '.
*  WRITE: AT 150 ' '.
*  WRITE: /10(15) 'NET PAYMENT',':',
*            (15) net_pay.

*  NEW-LINE.
*  col1 = 10.

  IF col1  >= 130.
    NEW-LINE.
    col1 = 10.
  ENDIF.

  WRITE: AT col1(15)  'NET PAYMENT',':',
            (15) net_pay.
  col1 = col1 + 40.

  IF col1  >= 130.
    NEW-LINE.
    col1 = 10.
  ENDIF.

*  LOOP AT itab_subtotal2 WHERE ind = ''
*                      AND wage = '/376'.
*    WRITE: AT col1(15) itab_subtotal2-desc, ':',
*              (15) itab_subtotal2-sum.
**    WRITE: AT 150 ' '.
*    col1 = col1 + 40.
*  ENDLOOP.
*
**  LOOP AT itab_subtotal2 WHERE ind = ''
**                         AND wage = '/376'.
**    WRITE: /10(15) itab_subtotal2-desc, '  :  ',
**              (15) itab_subtotal2-sum.
***    WRITE: AT 150 ' '.
**  ENDLOOP.
*
*  " Ting Ting added 25.06.2009 CE00007737
*  IF col1  >= 130.
*    NEW-LINE.
*    col1 = 10.
*  ENDIF.
*  LOOP AT itab_subtotal2 WHERE ind = ''
*                         AND wage = '/308' .
*    WRITE: AT col1(15) itab_subtotal1-desc, ':',
*              (15) itab_subtotal1-sum.
*    col1 = col1 + 40.
**    WRITE: AT 150 ' '.
*  ENDLOOP.
*
** 9MSO
*  IF col1  >= 130.
*    NEW-LINE.
*    col1 = 10.
*  ENDIF.
*  LOOP AT itab_subtotal2 WHERE ind = ''
**                         AND wage = '9MSO' " ting ting comment
*    AND wage = '4MSO'
*                         AND NOT sum IS INITIAL.
*    WRITE: AT col1(15) itab_subtotal2-desc,':',
*              (15) itab_subtotal2-sum.
*
*    WRITE: AT 150 ' '.
*  ENDLOOP.

  ULINE.
ENDFORM.                    "display_subtotal2

*---------------------------------------------------------------------*
*       FORM display_subtotal3                                        *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM display_subtotal3.

  DATA: ind1 TYPE i.
  DATA: col1 TYPE i.

  ind1 = 1.
  col1 = 15.

* This is to cater for previous payroll personnel's cc
* not found in the current payroll
* this is a rare case.
  IF itab_temp-perno IS INITIAL.
    WRITE: ':' , '0' LEFT-JUSTIFIED.
    WRITE: AT 150 ' '.
    ULINE.
    EXIT.
  ENDIF.

  LOOP AT itab_subtotal3 WHERE ind = 'N' AND sum <> 0 AND wage <> '0725' AND wage  <> '4MSO' AND wage <> '0ERA'. " SIR CE00007858 Ting Ting added 17.06.2009 " SIR CE00007762 Ting Ting added 15.06.2009.. " < SIR CE00007391.
  ENDLOOP.
  IF sy-subrc = 0.
    WRITE: ':' , itab_subtotal3-sum DECIMALS 0 LEFT-JUSTIFIED.
    WRITE: AT 150 ' '.
  ENDIF.

  LOOP AT itab_subtotal3 WHERE ind = 'A' AND sum <> 0 AND wage <> '0725' AND wage  <> '4MSO' AND wage <> '0ERA'. " SIR CE00007858 Ting Ting added 17.06.2009 " SIR CE00007762 Ting Ting added 15.06.2009.. " < SIR CE00007391.
    IF ind1 = 1.
      WRITE: AT /10(5) TEXT-020 ,15(15) itab_subtotal3-desc,
                        '  :  ' , (15) itab_subtotal3-sum.
      WRITE: AT 150 ' '.
      ind1 = ind1 + 1.
    ELSE.
      IF col1  >= 130.
        NEW-LINE.
        col1 = 15.
      ENDIF.
      WRITE: AT col1(15) itab_subtotal3-desc,
                      '  :  ',
                 (15) itab_subtotal3-sum.
      WRITE: AT 150 ' '.
    ENDIF.
    col1  =  col1 + 40.
  ENDLOOP.

  ind1 = 1.
  col1 = 15.

  LOOP AT itab_subtotal3 WHERE ind = 'D' AND sum <> 0 AND wage <> '0725' AND wage  <> '4MSO' AND wage <> '0ERA'. " SIR CE00007858 Ting Ting added 17.06.2009 " SIR CE00007762 Ting Ting added 15.06.2009.. " < SIR CE00007391.
    IF ind1 = 1.
      WRITE: AT /10(5) TEXT-021 ,15(15) itab_subtotal3-desc,
                        '  :  ' , (15) itab_subtotal3-sum.
      WRITE: AT 150 ' '.
      ind1 = ind1 + 1.
    ELSE.
      IF col1  >= 130.
        NEW-LINE.
        col1 = 15.
      ENDIF.
      WRITE: AT col1(15) itab_subtotal3-desc,
                      '  :  ',
                 (15) itab_subtotal3-sum.
      WRITE: AT 150 ' '.
    ENDIF.
    col1  =  col1 + 40.
  ENDLOOP.

* employer CPF
  NEW-LINE.
  col1 = 10.

  LOOP AT itab_subtotal3 WHERE ind = 'E' AND sum <> 0 AND wage <> '0725' AND wage  <> '4MSO' AND wage <> '0ERA'. " SIR CE00007858 Ting Ting added 17.06.2009 " SIR CE00007762 Ting Ting added 15.06.2009.. " < SIR CE00007391.
    WRITE: AT col1(15) itab_subtotal3-desc,':',
       (15) itab_subtotal3-sum.
    WRITE: AT 150 ' '.
    col1 = col1 + 40.
  ENDLOOP.

* total
  DATA: total_pay TYPE p DECIMALS 2, "total payment
        total_ded TYPE p DECIMALS 2, "total deduction
        typedesc  TYPE p DECIMALS 2,
        net_pay   TYPE p DECIMALS 2.

  CLEAR: total_pay, total_ded, typedesc, net_pay.

  LOOP AT itab_subtotal3 WHERE ind = ''.
    IF itab_subtotal3-wage = 'MED'.
      typedesc = itab_subtotal3-sum.
    ENDIF.
    IF itab_subtotal3-wage = 'PAY'.
      total_pay = itab_subtotal3-sum.
    ENDIF.
    IF itab_subtotal3-wage = 'DED'.
      total_ded = itab_subtotal3-sum.
    ENDIF.
    IF itab_subtotal3-wage = 'NET'.
      net_pay = itab_subtotal3-sum.
    ENDIF.
  ENDLOOP.

* Display total payment, total deduction, and net payment
  " TIng Ting 24.06.2009 CE00008250
*  WRITE: AT col1 'TOTAL MED CONTR:',(15) typedesc, 'TOTAL PAYMENT: ',
*                    (15) total_pay,  'DEDUCTIONS:  ', (15) total_ded.
**                             'NET PAYMENT:  ', (15) net_pay.

  IF col1  >= 130.
    NEW-LINE.
    col1 = 10.
  ENDIF.
  LOOP AT itab_subtotal3 WHERE ind = ''
                         AND wage = '/376'.
    WRITE: AT col1(15) itab_subtotal3-desc, ':',
              (15) itab_subtotal3-sum.
*    WRITE: AT 150 ' '.
    col1 = col1 + 40.
  ENDLOOP.

  " Ting Ting added 25.06.2009 CE00007737
  IF col1  >= 130.
    NEW-LINE.
    col1 = 10.
  ENDIF.
  LOOP AT itab_subtotal3 WHERE ind = ''
                         AND wage = '/308' .
    WRITE: AT col1(15) itab_subtotal3-desc, ':',
              (15) itab_subtotal3-sum.
    col1 = col1 + 40.
*    WRITE: AT 150 ' '.
  ENDLOOP.

* 9MSO
  IF col1  >= 130.
    NEW-LINE.
    col1 = 10.
  ENDIF.
  LOOP AT itab_subtotal3 WHERE ind = ''
*                         AND wage = '9MSO' "ting ting
    AND wage = '4MSO'
                         AND NOT sum IS INITIAL.
    WRITE: AT col1(15) itab_subtotal3-desc,':',
              (15) itab_subtotal3-sum.
    col1 = col1 + 40.
*    WRITE: AT 150 ' '.
  ENDLOOP.

  IF col1  >= 130.
    NEW-LINE.
    col1 = 10.
  ENDIF.

  WRITE: AT col1(15)  'TOTAL MED CONTR',':',
      (15) typedesc.
  col1 = col1 + 40.

*==>Start of addition, Bernard, SIR 9953
  LOOP AT itab_subtotal3 WHERE ind = ''
    AND wage = gc_wt_lsa_cpf_er AND NOT sum IS INITIAL.

    IF ( col1  >= 130 ).
      NEW-LINE.
      col1 = 10.
    ENDIF.

    WRITE: AT col1(15) itab_subtotal3-desc,':',
              (15) itab_subtotal3-sum.

  ENDLOOP.
*<==End of addition, Bernard, SIR 9953

  NEW-LINE.
  col1 = 10.

  WRITE: AT col1(15)  'TOTAL PAYMENT',':',
      (15) total_pay.
  col1 = col1 + 40.


  IF col1  >= 130.
    NEW-LINE.
    col1 = 10.
  ENDIF.
  WRITE: AT col1(15)  'DEDUCTIONS',':',
      (15) total_ded.
  col1 = col1 + 40.
*  WRITE: AT col1 'TOTAL  MED CONTR:',(15) typedesc, 'TOTAL PAYMENT: ',
*                    (15) total_pay,  'DEDUCTIONS:  ', (15) total_ded.
**                             'NET PAYMENT:  ', (15) net_pay.

*  WRITE: AT col1(15) 'NET PAYMENT',':',
*             (15) net_pay.
*
*  WRITE: AT 150 ' '.
*  WRITE: AT 150 ' '.
*  WRITE: /10(15) 'NET PAYMENT',':',
**            (15) net_pay.
*  NEW-LINE.
*  col1 = 10.
  IF (  col1  >= 130 ).
    NEW-LINE.
    col1 = 10.
  ENDIF.

  WRITE: AT col1(15)  'NET PAYMENT', ':',
            (15) net_pay.
  col1 = col1 + 40.
*  LOOP AT itab_subtotal3 WHERE ind = ''
*                         AND wage = '/376'.
*    WRITE: /10(15) itab_subtotal3-desc, '  :  ',
*              (15) itab_subtotal3-sum.
**    WRITE: AT 150 ' '.
*  ENDLOOP.
*  IF col1  >= 130.
*    NEW-LINE.
*    col1 = 10.
*  ENDIF.
*  LOOP AT itab_subtotal3 WHERE ind = ''
*                         AND wage = '/376'.
*    WRITE: AT col1(15) itab_subtotal3-desc, ':',
*              (15) itab_subtotal3-sum.
**    WRITE: AT 150 ' '.
*    col1 = col1 + 40.
*  ENDLOOP.
*
*  " Ting Ting added 25.06.2009 CE00007737
*  IF col1  >= 130.
*    NEW-LINE.
*    col1 = 10.
*  ENDIF.
*  LOOP AT itab_subtotal3 WHERE ind = ''
*                         AND wage = '/308' .
*    WRITE: AT col1(15) itab_subtotal1-desc, ':',
*              (15) itab_subtotal1-sum.
*    col1 = col1 + 40.
**    WRITE: AT 150 ' '.
*  ENDLOOP.
*
** 9MSO
*  IF col1  >= 130.
*    NEW-LINE.
*    col1 = 10.
*  ENDIF.
*  LOOP AT itab_subtotal3 WHERE ind = ''
**                         AND wage = '9MSO' "ting ting
*    AND wage = '4MSO'
*                         AND NOT sum IS INITIAL.
*    WRITE: AT col1(15) itab_subtotal3-desc,':',
*              (15) itab_subtotal3-sum.
*
*    WRITE: AT 150 ' '.
*  ENDLOOP.


  ULINE.
ENDFORM.                    "display_subtotal3

*---------------------------------------------------------------------*
*       FORM display_subtotal4                                        *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM display_subtotal4.

  DATA: ind1 TYPE i.
  DATA: col1 TYPE i.

  ind1 = 1.
  col1 = 15.

* This is to cater for previous payroll personnel's cc
* not found in the current payroll
* this is a rare case.
  IF itab_temp-perno IS INITIAL.
    WRITE: ':' , '0' LEFT-JUSTIFIED.
    WRITE: AT 150 ' '.
    ULINE.
    EXIT.
  ENDIF.

  LOOP AT itab_subtotal4 WHERE ind = 'N' AND sum <> 0 AND wage <> '0725' AND wage  <> '4MSO' AND wage <> '0ERA'. " SIR CE00007858 Ting Ting added 17.06.2009 " SIR CE00007762 Ting Ting added 15.06.2009.. " < SIR CE00007391.
  ENDLOOP.
  IF sy-subrc = 0.
    WRITE: ':' , itab_subtotal4-sum DECIMALS 0 LEFT-JUSTIFIED.
    WRITE: AT 150 ' '.
  ENDIF.

  LOOP AT itab_subtotal4 WHERE ind = 'A' AND sum <> 0 AND wage <> '0725' AND wage  <> '4MSO' AND wage <> '0ERA'. " SIR CE00007858 Ting Ting added 17.06.2009 " SIR CE00007762 Ting Ting added 15.06.2009.. " < SIR CE00007391.
    IF ind1 = 1.
      WRITE: AT /10(5) TEXT-020 ,15(15) itab_subtotal4-desc,
                        '  :  ' , (15) itab_subtotal4-sum.
      WRITE: AT 150 ' '.
      ind1 = ind1 + 1.
    ELSE.
      IF col1  >= 130.
        NEW-LINE.
        col1 = 15.
      ENDIF.
      WRITE: AT col1(15) itab_subtotal4-desc,
                      '  :  ',
                 (15) itab_subtotal4-sum.
      WRITE: AT 150 ' '.
    ENDIF.
    col1  =  col1 + 40.
  ENDLOOP.

  ind1 = 1.
  col1 = 15.

  LOOP AT itab_subtotal4 WHERE ind = 'D' AND sum <> 0 AND wage <> '0725' AND wage  <> '4MSO' AND wage <> '0ERA'. " SIR CE00007858 Ting Ting added 17.06.2009 " SIR CE00007762 Ting Ting added 15.06.2009.. " < SIR CE00007391.
    IF ind1 = 1.
      WRITE: AT /10(5) TEXT-021 ,15(15) itab_subtotal4-desc,
                        '  :  ' , (15) itab_subtotal4-sum.
      WRITE: AT 150 ' '.
      ind1 = ind1 + 1.
    ELSE.
      IF col1  >= 130.
        NEW-LINE.
        col1 = 15.
      ENDIF.
      WRITE: AT col1(15) itab_subtotal4-desc,
                      '  :  ',
                 (15) itab_subtotal4-sum.
      WRITE: AT 150 ' '.
    ENDIF.
    col1  =  col1 + 40.
  ENDLOOP.

* employer CPF
  NEW-LINE.
  col1 = 10.

  LOOP AT itab_subtotal4 WHERE ind = 'E' AND sum <> 0 AND wage <> '0725' AND wage  <> '4MSO' AND wage <> '0ERA'. " SIR CE00007858 Ting Ting added 17.06.2009 " SIR CE00007762 Ting Ting added 15.06.2009.. " < SIR CE00007391.
    WRITE: AT col1(15) itab_subtotal4-desc,':',
       (15) itab_subtotal4-sum.
    WRITE: AT 150 ' '.
    col1 = col1 + 40.
  ENDLOOP.

* total
  DATA: total_pay TYPE p DECIMALS 2, "total payment
        total_ded TYPE p DECIMALS 2, "total deduction
        typedesc  TYPE p DECIMALS 2,
        net_pay   TYPE p DECIMALS 2.

  CLEAR: total_pay, total_ded, typedesc, net_pay.

  LOOP AT itab_subtotal4 WHERE ind = ''.
    IF itab_subtotal4-wage = 'MED'.
      typedesc = itab_subtotal4-sum.
    ENDIF.
    IF itab_subtotal4-wage = 'PAY'.
      total_pay = itab_subtotal4-sum.
    ENDIF.
    IF itab_subtotal4-wage = 'DED'.
      total_ded = itab_subtotal4-sum.
    ENDIF.
    IF itab_subtotal4-wage = 'NET'.
      net_pay = itab_subtotal4-sum.
    ENDIF.
  ENDLOOP.

  IF col1  >= 130.
    NEW-LINE.
    col1 = 10.
  ENDIF.


  LOOP AT itab_subtotal4 WHERE ind = ''
                         AND wage = '/376'.
    WRITE: AT col1(15) itab_subtotal4-desc, ':',
              (15) itab_subtotal4-sum.
*    WRITE: AT 150 ' '.
    col1 = col1 + 40.
  ENDLOOP.

*  LOOP AT itab_subtotal4 WHERE ind = ''
*                         AND wage = '/376'.
*    WRITE: /10(15) itab_subtotal4-desc, '  :  ',
*              (15) itab_subtotal4-sum.
**    WRITE: AT 150 ' '.
*  ENDLOOP.

  " Ting Ting added 25.06.2009 CE00007737
  IF col1  >= 130.
    NEW-LINE.
    col1 = 10.
  ENDIF.
  LOOP AT itab_subtotal4 WHERE ind = ''
                         AND wage = '/308' .
    WRITE: AT col1(15) itab_subtotal4-desc, ':',
              (15) itab_subtotal4-sum.
    col1 = col1 + 40.
*    WRITE: AT 150 ' '.
  ENDLOOP.

* 9MSO
  IF col1  >= 130.
    NEW-LINE.
    col1 = 10.
  ENDIF.
  LOOP AT itab_subtotal4 WHERE ind = ''
*                         AND wage = '9MSO' " ting ting
    AND wage = '4MSO'
                         AND NOT sum IS INITIAL.
    WRITE: AT col1(15) itab_subtotal4-desc,':',
              (15) itab_subtotal4-sum.
    col1 = col1 + 40.
*    WRITE: AT 150 ' '.
  ENDLOOP.


  IF col1  >= 130.
    NEW-LINE.
    col1 = 10.
  ENDIF.

  WRITE: AT col1(15)  'TOTAL MED CONTR',':',
      (15) typedesc.
  col1 = col1 + 40.

*==>Start of addition, Bernard, SIR 9953
  LOOP AT itab_subtotal4 WHERE ind = ''
    AND wage = gc_wt_lsa_cpf_er AND NOT sum IS INITIAL.

    IF ( col1  >= 130 ).
      NEW-LINE.
      col1 = 10.
    ENDIF.

    WRITE: AT col1(15) itab_subtotal4-desc,':',
              (15) itab_subtotal4-sum.

  ENDLOOP.
*<==End of addition, Bernard, SIR 9953

  NEW-LINE.
  col1 = 10.

  WRITE: AT col1(15)  'TOTAL PAYMENT',':',
      (15) total_pay.
  col1 = col1 + 40.


  IF col1  >= 130.
    NEW-LINE.
    col1 = 10.
  ENDIF.

  WRITE: AT col1(15)  'DEDUCTIONS',':',
      (15) total_ded.
  col1 = col1 + 40.


* Display total payment, total deduction, and net payment
  " TIng Ting 24.06.2009 CE00008250
*  WRITE: AT col1 'TOTAL MED CONTR:',(15) typedesc, 'TOTAL PAYMENT: ',
*                    (15) total_pay,  'DEDUCTIONS:  ', (15) total_ded.
**                             'NET PAYMENT:  ', (15) net_pay.
*  WRITE: AT col1 'TOTAL  MED CONTR:',(15) typedesc, 'TOTAL PAYMENT: ',
*                    (15) total_pay,  'DEDUCTIONS:  ', (15) total_ded.
*                             'NET PAYMENT:  ', (15) net_pay.


*  WRITE: AT col1(15) 'NET PAYMENT',':',
*              (15) net_pay.
*  WRITE: AT 150 ' '.
*  WRITE: AT 150 ' '.
*  WRITE: /10(15) 'NET PAYMENT',':',
*            (15) net_pay.
*
*  NEW-LINE.
*  col1 = 10.

  IF col1  >= 130.
    NEW-LINE.
    col1 = 10.
  ENDIF.
  WRITE: AT col1(15)  'NET PAYMENT',':',
            (15) net_pay.
  col1 = col1 + 40.

*  LOOP AT itab_subtotal4 WHERE ind = ''
*                         AND wage = '/376'.
*    WRITE: AT col1(15) itab_subtotal4-desc, ':',
*              (15) itab_subtotal4-sum.
**    WRITE: AT 150 ' '.
*    col1 = col1 + 40.
*  ENDLOOP.
*
**  LOOP AT itab_subtotal4 WHERE ind = ''
**                         AND wage = '/376'.
**    WRITE: /10(15) itab_subtotal4-desc, '  :  ',
**              (15) itab_subtotal4-sum.
***    WRITE: AT 150 ' '.
**  ENDLOOP.
*
*  " Ting Ting added 25.06.2009 CE00007737
*  IF col1  >= 130.
*    NEW-LINE.
*    col1 = 10.
*  ENDIF.
*  LOOP AT itab_subtotal4 WHERE ind = ''
*                         AND wage = '/308' .
*    WRITE: AT col1(15) itab_subtotal1-desc, ':',
*              (15) itab_subtotal1-sum.
*    col1 = col1 + 40.
**    WRITE: AT 150 ' '.
*  ENDLOOP.
*
** 9MSO
*  IF col1  >= 130.
*    NEW-LINE.
*    col1 = 10.
*  ENDIF.
*  LOOP AT itab_subtotal4 WHERE ind = ''
**                         AND wage = '9MSO' " ting ting
*    AND wage = '4MSO'
*                         AND NOT sum IS INITIAL.
*    WRITE: AT col1(15) itab_subtotal4-desc,':',
*              (15) itab_subtotal4-sum.
*
*    WRITE: AT 150 ' '.
*  ENDLOOP.

  ULINE.
ENDFORM.                    "display_subtotal4

*---------------------------------------------------------------------*
*       FORM display_subtotal5                                        *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM display_subtotal5.

  DATA: ind1 TYPE i.
  DATA: col1 TYPE i.

  ind1 = 1.
  col1 = 15.

* This is to cater for previous payroll personnel's cc
* not found in the current payroll
* this is a rare case.
  IF itab_temp-perno IS INITIAL.
    WRITE: ':' , '0' LEFT-JUSTIFIED.
    WRITE: AT 150 ' '.
    ULINE.
    EXIT.
  ENDIF.

  LOOP AT itab_subtotal5 WHERE ind = 'N' AND sum <> 0 AND wage <> '0725' AND wage  <> '4MSO' AND wage <> '0ERA'. " SIR CE00007858 Ting Ting added 17.06.2009 " SIR CE00007762 Ting Ting added 15.06.2009.. " < SIR CE00007391.
  ENDLOOP.
  IF sy-subrc = 0.
    WRITE: ':' , itab_subtotal5-sum DECIMALS 0 LEFT-JUSTIFIED.
    WRITE: AT 150 ' '.
  ENDIF.

  LOOP AT itab_subtotal5 WHERE ind = 'A' AND sum <> 0 AND wage <> '0725' AND wage  <> '4MSO' AND wage <> '0ERA'. " SIR CE00007858 Ting Ting added 17.06.2009 " SIR CE00007762 Ting Ting added 15.06.2009.. " < SIR CE00007391.
    IF ind1 = 1.
      WRITE: AT /10(5) TEXT-020 ,15(15) itab_subtotal5-desc,
                        '  :  ' , (15) itab_subtotal5-sum.
      WRITE: AT 150 ' '.
      ind1 = ind1 + 1.
    ELSE.
      IF col1  >= 130.
        NEW-LINE.
        col1 = 15.
      ENDIF.
      WRITE: AT col1(15) itab_subtotal5-desc,
                      '  :  ',
                 (15) itab_subtotal5-sum.
      WRITE: AT 150 ' '.
    ENDIF.
    col1  =  col1 + 40.
  ENDLOOP.

  ind1 = 1.
  col1 = 15.

  LOOP AT itab_subtotal5 WHERE ind = 'D' AND sum <> 0 AND wage <> '0725' AND wage  <> '4MSO' AND wage <> '0ERA'. " SIR CE00007858 Ting Ting added 17.06.2009. " SIR CE00007762 Ting Ting added 15.06.2009.. " < SIR CE00007391.
    IF ind1 = 1.
      WRITE: AT /10(5) TEXT-021 ,15(15) itab_subtotal5-desc,
                        '  :  ' , (15) itab_subtotal5-sum.
      WRITE: AT 150 ' '.
      ind1 = ind1 + 1.
    ELSE.
      IF col1  >= 130.
        NEW-LINE.
        col1 = 15.
      ENDIF.
      WRITE: AT col1(15) itab_subtotal5-desc,
                      '  :  ',
                 (15) itab_subtotal5-sum.
      WRITE: AT 150 ' '.
    ENDIF.
    col1  =  col1 + 40.
  ENDLOOP.

* employer CPF
  NEW-LINE.
  col1 = 10.

  LOOP AT itab_subtotal5 WHERE ind = 'E' AND sum <> 0 AND wage <> '0725' AND wage  <> '4MSO' AND wage <> '0ERA'. " SIR CE00007858 Ting Ting added 17.06.2009" SIR CE00007762 Ting Ting added 15.06.2009.. " < SIR CE00007391.
    WRITE: AT col1(15) itab_subtotal5-desc,':',
       (15) itab_subtotal5-sum.
    WRITE: AT 150 ' '.
    col1 = col1 + 40.
  ENDLOOP.

* total
  DATA: total_pay TYPE p DECIMALS 2, "total payment
        total_ded TYPE p DECIMALS 2, "total deduction
        typedesc  TYPE p DECIMALS 2,
        net_pay   TYPE p DECIMALS 2.

  CLEAR: total_pay, total_ded, typedesc, net_pay.

  LOOP AT itab_subtotal5 WHERE ind = ''.
    IF itab_subtotal5-wage = 'MED'.
      typedesc = itab_subtotal5-sum.
    ENDIF.
    IF itab_subtotal5-wage = 'PAY'.
      total_pay = itab_subtotal5-sum.
    ENDIF.
    IF itab_subtotal5-wage = 'DED'.
      total_ded = itab_subtotal5-sum.
    ENDIF.
    IF itab_subtotal5-wage = 'NET'.
      net_pay = itab_subtotal5-sum.
    ENDIF.
  ENDLOOP.

  IF col1  >= 130.
    NEW-LINE.
    col1 = 10.
  ENDIF.

  LOOP AT itab_subtotal5 WHERE ind = ''
                         AND wage = '/376'.
    WRITE: AT col1(15) itab_subtotal5-desc, ':',
              (15) itab_subtotal5-sum.
*    WRITE: AT 150 ' '.
    col1 = col1 + 40.
  ENDLOOP.

  " Ting Ting added 25.06.2009 CE00007737
  IF col1  >= 130.
    NEW-LINE.
    col1 = 10.
  ENDIF.
  LOOP AT itab_subtotal5 WHERE ind = ''
                         AND wage = '/308' .
    WRITE: AT col1(15) itab_subtotal5-desc, ':',
              (15) itab_subtotal1-sum.
    col1 = col1 + 40.
*    WRITE: AT 150 ' '.
  ENDLOOP.

* 9MSO
  IF col1  >= 130.
    NEW-LINE.
    col1 = 10.
  ENDIF.
  LOOP AT itab_subtotal5 WHERE ind = ''
*                         AND wage = '9MSO' " ting ting commented
    AND wage = '4MSO'
                         AND NOT sum IS INITIAL.
    WRITE: AT col1(15) itab_subtotal5-desc,':',
              (15) itab_subtotal5-sum.

    col1 = col1 + 40.
*    write: at 150 ' '.
  ENDLOOP.


  IF col1  >= 130.
    NEW-LINE.
    col1 = 10.
  ENDIF.
* Display total payment, total deduction, and net payment
  " TIng Ting 24.06.2009 CE00008250
  WRITE: AT col1(15)  'TOTAL MED CONTR',':',
          (15) typedesc.
  col1 = col1 + 40.

*==>Start of addition, Bernard, SIR 9953
  LOOP AT itab_subtotal5 WHERE ind = ''
    AND wage = gc_wt_lsa_cpf_er AND NOT sum IS INITIAL.

    IF ( col1  >= 130 ).
      NEW-LINE.
      col1 = 10.
    ENDIF.

    WRITE: AT col1(15) itab_subtotal5-desc,':',
              (15) itab_subtotal5-sum.

  ENDLOOP.
*<==End of addition, Bernard, SIR 9953

  NEW-LINE.
  col1 = 10.


  WRITE: AT col1(15)  'TOTAL PAYMENT',':',
        (15) total_pay.
  col1 = col1 + 40.
  IF col1  >= 130.
    NEW-LINE.
    col1 = 10.
  ENDIF.

  WRITE: AT col1(15)  'DEDUCTIONS',':',
        (15) total_ded.
  col1 = col1 + 40.

*  WRITE: AT col1 'TOTAL MED CONTR:',(15) typedesc, 'TOTAL PAYMENT: ',
*                    (15) total_pay,  'DEDUCTIONS:  ', (15) total_ded.
**                             'NET PAYMENT:  ', (15) net_pay.
*  WRITE: AT col1 'TOTAL  MED CONTR:',(15) typedesc, 'TOTAL PAYMENT: ',
*                      (15) total_pay,  'DEDUCTIONS:  ', (15) total_ded.
*                             'NET PAYMENT:  ', (15) net_pay.


*  WRITE: AT 150 ' '.
*  WRITE: /10(15) 'NET PAYMENT',':',
*            (15) net_pay.

*  NEW-LINE.
*  col1 = 10.
  IF col1  >= 130.
    NEW-LINE.
    col1 = 10.
  ENDIF.
  WRITE: AT col1(15)  'NET PAYMENT', ':',
            (15) net_pay.
  col1 = col1 + 40.
*  WRITE: AT 150 ' '.

*  LOOP AT itab_subtotal5 WHERE ind = ''
*                         AND wage = '/376'.
*    WRITE: /10(15) itab_subtotal5-desc, '  :  ',
*              (15) itab_subtotal5-sum.
**    WRITE: AT 150 ' '.
*  ENDLOOP.

*  IF col1  >= 130.
*    NEW-LINE.
*    col1 = 10.
*  ENDIF.
*
*  LOOP AT itab_subtotal5 WHERE ind = ''
*                         AND wage = '/376'.
*    WRITE: AT col1(15) itab_subtotal5-desc, ':',
*              (15) itab_subtotal5-sum.
**    WRITE: AT 150 ' '.
*    col1 = col1 + 40.
*  ENDLOOP.
*
*  " Ting Ting added 25.06.2009 CE00007737
*  IF col1  >= 130.
*    NEW-LINE.
*    col1 = 10.
*  ENDIF.
*  LOOP AT itab_subtotal5 WHERE ind = ''
*                         AND wage = '/308' .
*    WRITE: AT col1(15) itab_subtotal1-desc, ':',
*              (15) itab_subtotal1-sum.
*    col1 = col1 + 40.
**    WRITE: AT 150 ' '.
*  ENDLOOP.
*
** 9MSO
*  IF col1  >= 130.
*    NEW-LINE.
*    col1 = 10.
*  ENDIF.
*  LOOP AT itab_subtotal5 WHERE ind = ''
**                         AND wage = '9MSO' " ting ting commented
*    AND wage = '4MSO'
*                         AND NOT sum IS INITIAL.
*    WRITE: AT col1(15) itab_subtotal5-desc,':',
*              (15) itab_subtotal5-sum.
*
*    WRITE: AT 150 ' '.
*  ENDLOOP.


  ULINE.
ENDFORM.                    "display_subtotal5

*---------------------------------------------------------------------*
*       FORM fill_subtotal                                            *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM fill_subtotal USING wage desc sum ind .

  READ TABLE itab_subtotal1 WITH KEY wage = wage.
  IF sy-subrc = 0.
    ADD sum TO itab_subtotal1-sum.
    MODIFY itab_subtotal1 INDEX sy-tabix.
  ELSE.
    CLEAR itab_subtotal1.
    itab_subtotal1-wage = wage.
    itab_subtotal1-desc = desc.
    itab_subtotal1-sum  = sum.
    itab_subtotal1-ind  = ind.
    APPEND itab_subtotal1.
  ENDIF.

  READ TABLE itab_subtotal2 WITH KEY wage = wage.
  IF sy-subrc = 0.
    ADD sum TO itab_subtotal2-sum.
    MODIFY itab_subtotal2 INDEX sy-tabix.
  ELSE.
    CLEAR itab_subtotal2.
    itab_subtotal2-wage = wage.
    itab_subtotal2-desc = desc.
    itab_subtotal2-sum  = sum.
    itab_subtotal2-ind  = ind.
    APPEND itab_subtotal2.
  ENDIF.

  READ TABLE itab_subtotal3 WITH KEY wage = wage.
  IF sy-subrc = 0.
    ADD sum TO itab_subtotal3-sum.
    MODIFY itab_subtotal3 INDEX sy-tabix.
  ELSE.
    CLEAR itab_subtotal3.
    itab_subtotal3-wage = wage.
    itab_subtotal3-desc = desc.
    itab_subtotal3-sum  = sum.
    itab_subtotal3-ind  = ind.
    APPEND itab_subtotal3.
  ENDIF.

  READ TABLE itab_subtotal4 WITH KEY wage = wage.
  IF sy-subrc = 0.
    ADD sum TO itab_subtotal4-sum.
    MODIFY itab_subtotal4 INDEX sy-tabix.
  ELSE.
    CLEAR itab_subtotal4.
    itab_subtotal4-wage = wage.
    itab_subtotal4-desc = desc.
    itab_subtotal4-sum  = sum.
    itab_subtotal4-ind  = ind.
    APPEND itab_subtotal4.
  ENDIF.

  READ TABLE itab_subtotal5 WITH KEY wage = wage.
  IF sy-subrc = 0.
    ADD sum TO itab_subtotal5-sum.
    MODIFY itab_subtotal5 INDEX sy-tabix.
  ELSE.
    CLEAR itab_subtotal5.
    itab_subtotal5-wage = wage.
    itab_subtotal5-desc = desc.
    itab_subtotal5-sum  = sum.
    itab_subtotal5-ind  = ind .
    APPEND itab_subtotal5.
  ENDIF.

ENDFORM.                    "fill_subtotal

*---------------------------------------------------------------------*
*       FORM get_previous_payroll                                     *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM get_previous_payroll.
  DATA: temp_in_per LIKE pc261-inper.

  CLEAR temp_in_per.

* To run the previous month payroll
  IF in_per+4(2) <> '01'.
    temp_in_per = in_per - 1.
  ELSE.
    temp_in_per(4) = in_per(4) - 1.
    temp_in_per+4(2) = '12'.
  ENDIF.

  FREE MEMORY ID 'Z_PAYROLL_PREV'.

* To get previous month info:
* prev month net payment which involves,
* a) /559 = bank transfer
* b) /557 = Cash payment
* b) /561 = Claim (receive from employee)

* the internal table is sorted by sort1,2,3,4
* so that we can compare the prev month net payment
* at the subtotal level.

*  SUBMIT  z_rppy_pay_04_include
*  with s_cost in s_cost.

  EXPORT s_cost FROM s_cost TO MEMORY ID 'Z_COST_PAYSHEET'.

  SUBMIT z_rppy_pay_04_last


    WITH pnpxabkr = pnpxabkr
    WITH pnptimra = 'X'
    WITH pnppabrj = temp_in_per(4)
    WITH pnppabrp = temp_in_per+4(2)
*   with pnpdispj = pnpdispj
*   with pnpdispp = pnpdispp

    WITH pnppernr IN pnppernr
    WITH pnpwerks IN pnpwerks
    WITH pnpbtrtl IN pnpbtrtl
    WITH pnpabkrs IN pnpabkrs
    WITH pnporgeh IN pnporgeh
    WITH s_cost IN s_cost

    WITH payty = pr_ty
    WITH payid = pr_id
    WITH bondt = pr_dt

    WITH payty_1 = pr_ty1
    WITH payid_1 = pr_id1
    WITH bondt_1 = pr_dt1

    WITH sort1 = sort1
    WITH sort2 = sort2
    WITH sort3 = sort3
    WITH sort4 = sort4

    WITH prt_prot = prt_pr

    WITH break1 = break1
    WITH break2 = break2
    WITH break3 = break3
    WITH break4 = break4
    WITH break5 = break5

    WITH tot1 = tot1
    WITH tot2 = tot2
    WITH tot3 = tot3
    WITH tot4 = tot4
    WITH tot5 = tot5

    AND RETURN.
ENDFORM.                    "get_previous_payroll

*---------------------------------------------------------------------*
*       FORM compare_payroll                                          *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM compare_payroll.
  DATA: sum TYPE p DECIMALS 2.

  IF compare = 'X'.
* get previous payroll result
    IMPORT payroll_prev TO payroll_prev FROM MEMORY ID 'Z_PAYROLL_PREV'.

    IF sy-subrc <> 0.
      MESSAGE i150 WITH 'Cannot import last month results!'.
      REFRESH payroll_prev.
    ENDIF.
  ELSE.
    REFRESH payroll_prev.
  ENDIF.

* get current payroll result
* /559 = bank transfer
* /557 = Cash payment
* /561 = Claim (receive from employee)

  LOOP AT itab_output.

    LOOP AT itab_total WHERE pernr =  itab_output-perno
                         AND ( lgart = '/559'
                         OR lgart = '/558'
                         OR lgart = '/557'
                         OR lgart = '/561')
                         AND NOT total_wage IS INITIAL.

      IF itab_total-lgart = '/561'.
        itab_total-total_wage = itab_total-total_wage * -1.
      ENDIF.

      sum = sum + itab_total-total_wage.

    ENDLOOP.

    IF sy-subrc = 0.
      payroll_curr-s1 = itab_output-s1.
      payroll_curr-s2 = itab_output-s2.
      payroll_curr-s3 = itab_output-s3.
      payroll_curr-s4 = itab_output-s4.
      payroll_curr-desc = 'Net Payment'.
      payroll_curr-amt = sum.
      payroll_curr-pernr = itab_total-pernr.
      APPEND payroll_curr.
    ENDIF.

    CLEAR sum.

  ENDLOOP.

* Store the EE who are paid this month but not last month into
* itab_ee_paid_this_month.
  IF compare = 'X'.
    LOOP AT payroll_curr.
      READ TABLE payroll_prev WITH KEY pernr = payroll_curr-pernr.
      IF sy-subrc NE 0.
        itab_ee_paid_this_month-pernr = payroll_curr-pernr.
        itab_ee_paid_this_month-amount = payroll_curr-amt.
        APPEND itab_ee_paid_this_month.
      ENDIF.
    ENDLOOP.

* Store the EE who are paid last month but not this month into
* itab_ee_paid_last_month.
    LOOP AT payroll_prev.

      READ TABLE payroll_curr WITH KEY pernr = payroll_prev-pernr.
      IF sy-subrc NE 0.
        " ---START SIR CE00007327 08.06.2009--
        LOOP AT itab_payroll_02 WHERE pernr =  payroll_prev-pernr.

          itab_ee_paid_last_month-pernr = payroll_prev-pernr.
          itab_ee_paid_last_month-amount = payroll_prev-amt.
          APPEND itab_ee_paid_last_month.

        ENDLOOP.
        " ---END SIR CE00007327 08.06.2009--
      ENDIF.
    ENDLOOP.
  ENDIF.

* these are the personnels that are in current payroll
* and in previous payroll.
* calculate the pay difference between previous and current for
* these personnels.
  LOOP AT payroll_curr.
    READ TABLE payroll_prev WITH KEY pernr = payroll_curr-pernr.
    IF sy-subrc = 0.
      itab_compare-desc = 'Adjustment'.
      itab_compare-amt = payroll_curr-amt - payroll_prev-amt.
      itab_compare-pernr = payroll_curr-pernr.
      APPEND itab_compare.
    ENDIF.
  ENDLOOP.

* these are the personnels that are in previous payroll
* but no longer in current payroll. Also, their cc/org unit is not found
* in the current payroll.
* this is a rare case.
* to deal with this case, we append itab_output with the cc/org unit
* and clear the pernr. Later the program will know this is a
* special record when pernr is empty.
  DATA: temp_payroll_curr LIKE payroll_curr OCCURS 0 WITH HEADER LINE.

  REFRESH temp_payroll_curr.
  temp_payroll_curr[] = payroll_curr[].

  LOOP AT payroll_prev.
*    READ TABLE payroll_curr
*      WITH KEY pernr = payroll_prev-pernr.
*    IF sy-subrc <> 0.
    READ TABLE temp_payroll_curr
      WITH KEY s1 = payroll_prev-s1
               s2 = payroll_prev-s2
               s3 = payroll_prev-s3
               s4 = payroll_prev-s4.
    IF sy-subrc <> 0.
* uncomment these to see the rare case.
*        write:/ payroll_prev-pernr.
*        write: payroll_prev-s1.
*        write: payroll_prev-s2.
*        write: payroll_prev-s3.
*        write: payroll_prev-s4.
      CLEAR itab_output. " to clear pernr.
      itab_output-s1 = payroll_prev-s1.
      itab_output-s2 = payroll_prev-s2.
      itab_output-s3 = payroll_prev-s3.
      itab_output-s4 = payroll_prev-s4.
      APPEND itab_output.
    ENDIF.
*    ENDIF.
  ENDLOOP.

ENDFORM.                    "compare_payroll

*---------------------------------------------------------------------*
*       FORM cal_summary1                                             *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM cal_summary1.

*Officer b/f from last month.
  LOOP AT payroll_prev
    WHERE s1 = itab_temp-s1.
    ADD payroll_prev-amt TO officer_bf_amt1.
    ADD 1 TO officer_bf1.
  ENDLOOP.

* Officer paid last month but not this month.
  LOOP AT payroll_prev
    WHERE s1 = itab_temp-s1.
    READ TABLE payroll_curr WITH KEY
    pernr = payroll_prev-pernr
    s1 = payroll_prev-s1.
    IF sy-subrc <> 0.
      ADD payroll_prev-amt TO officer_paid_last_amt1.
      ADD 1 TO officer_paid_last1.
    ENDIF.

* If officer paid last month and also this month,
* check if there is adjustment in pay.
    IF sy-subrc = 0.
* Other adjustments to officer's salaries.
      READ TABLE itab_compare WITH KEY pernr = payroll_prev-pernr.
      IF sy-subrc = 0.
        ADD itab_compare-amt TO other_adjust_amt1.
      ENDIF.
    ENDIF.
  ENDLOOP.

* Officers paid this month but not last month.
  LOOP AT payroll_curr
    WHERE s1 = itab_temp-s1.
    READ TABLE payroll_prev WITH KEY
    s1 = payroll_curr-s1
    pernr = payroll_curr-pernr.
    IF sy-subrc <> 0.
      ADD payroll_curr-amt TO officer_paid_this_amt1.
      ADD 1 TO officer_paid_this1.
    ENDIF.
  ENDLOOP.

* Officers c/f to next month.
  LOOP AT payroll_curr
    WHERE s1 = itab_temp-s1.
    ADD payroll_curr-amt TO officer_cf_amt1.
    ADD 1 TO officer_cf1.
  ENDLOOP.
ENDFORM.                    "cal_summary1

*---------------------------------------------------------------------*
*       FORM cal_summary2                                             *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM cal_summary2.

*Officer b/f from last month.
  LOOP AT payroll_prev
    WHERE s1 = itab_temp-s1
    AND s2 = itab_temp-s2.

    ADD payroll_prev-amt TO officer_bf_amt2.
    ADD 1 TO officer_bf2.

  ENDLOOP.

* Officer paid last month but not this month.
  LOOP AT payroll_prev
    WHERE s1 = itab_temp-s1
    AND s2 = itab_temp-s2.

    READ TABLE payroll_curr WITH KEY
    pernr = payroll_prev-pernr
    s1 = payroll_prev-s1
    s2 = payroll_prev-s2.

    IF sy-subrc <> 0.
      ADD payroll_prev-amt TO officer_paid_last_amt2.
      ADD 1 TO officer_paid_last2.
    ENDIF.

* If officer paid last month and also this month,
* check if there is adjustment in pay.
    IF sy-subrc = 0.
* Other adjustments to officer's salaries.
      READ TABLE itab_compare WITH KEY pernr = payroll_prev-pernr.
      IF sy-subrc = 0.
        ADD itab_compare-amt TO other_adjust_amt2.
      ENDIF.
    ENDIF.

  ENDLOOP.

* Officers paid this month but not last month.
  LOOP AT payroll_curr
    WHERE s1 = itab_temp-s1
    AND s2 = itab_temp-s2.

    READ TABLE payroll_prev WITH KEY
    s1 = payroll_curr-s1
    s2 = payroll_curr-s2
    pernr = payroll_curr-pernr.

    IF sy-subrc <> 0.
      ADD payroll_curr-amt TO officer_paid_this_amt2.
      ADD 1 TO officer_paid_this2.
    ENDIF.

  ENDLOOP.

* Officers c/f to next month.
  LOOP AT payroll_curr
    WHERE s1 = itab_temp-s1
    AND s2 = itab_temp-s2.

    ADD payroll_curr-amt TO officer_cf_amt2.
    ADD 1 TO officer_cf2.

  ENDLOOP.

ENDFORM.                    "cal_summary2

*---------------------------------------------------------------------*
*       FORM cal_summary3                                             *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM cal_summary3.

*Officer b/f from last month.
  LOOP AT payroll_prev
    WHERE s1 = itab_temp-s1
    AND s2 = itab_temp-s2
    AND s3 = itab_temp-s3.

    ADD payroll_prev-amt TO officer_bf_amt3.
    ADD 1 TO officer_bf3.

  ENDLOOP.

* Officer paid last month but not this month.
  LOOP AT payroll_prev
    WHERE s1 = itab_temp-s1
    AND s2 = itab_temp-s2
    AND s3 = itab_temp-s3.

    READ TABLE payroll_curr WITH KEY
    pernr = payroll_prev-pernr
    s1 = payroll_prev-s1
    s2 = payroll_prev-s2
    s3 = payroll_prev-s3.

    IF sy-subrc <> 0.
      ADD payroll_prev-amt TO officer_paid_last_amt3.
      ADD 1 TO officer_paid_last3.
    ENDIF.

* If officer paid last month and also this month,
* check if there is adjustment in pay.
    IF sy-subrc = 0.
* Other adjustments to officer's salaries.
      READ TABLE itab_compare WITH KEY pernr = payroll_prev-pernr.
      IF sy-subrc = 0.
        ADD itab_compare-amt TO other_adjust_amt3.
      ENDIF.
    ENDIF.
  ENDLOOP.

* Officers paid this month but not last month.
  LOOP AT payroll_curr
    WHERE s1 = itab_temp-s1
    AND s2 = itab_temp-s2
    AND s3 = itab_temp-s3.

    READ TABLE payroll_prev WITH KEY
    s1 = payroll_curr-s1
    s2 = payroll_curr-s2
    s3 = payroll_curr-s3
    pernr = payroll_curr-pernr.

    IF sy-subrc <> 0.
      ADD payroll_curr-amt TO officer_paid_this_amt3.
      ADD 1 TO officer_paid_this3.
    ENDIF.

  ENDLOOP.

* Officers c/f to next month.
  LOOP AT payroll_curr
    WHERE s1 = itab_temp-s1
    AND s2 = itab_temp-s2
    AND s3 = itab_temp-s3.

    ADD payroll_curr-amt TO officer_cf_amt3.
    ADD 1 TO officer_cf3.
  ENDLOOP.

ENDFORM.                    "cal_summary3

*---------------------------------------------------------------------*
*       FORM cal_summary4                                             *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM cal_summary4.

*Officer b/f from last month.
  LOOP AT payroll_prev
    WHERE s1 = itab_temp-s1
    AND s2 = itab_temp-s2
    AND s3 = itab_temp-s3
    AND s4 = itab_temp-s4.

    ADD payroll_prev-amt TO officer_bf_amt4.
    ADD 1 TO officer_bf4.

  ENDLOOP.

* Officer paid last month but not this month.
  LOOP AT payroll_prev
    WHERE s1 = itab_temp-s1
    AND s2 = itab_temp-s2
    AND s3 = itab_temp-s3
    AND s4 = itab_temp-s4.

    READ TABLE payroll_curr WITH KEY
    pernr = payroll_prev-pernr
    s1 = payroll_prev-s1
    s2 = payroll_prev-s2
    s3 = payroll_prev-s3
    s4 = payroll_prev-s4.

    IF sy-subrc <> 0.
      ADD payroll_prev-amt TO officer_paid_last_amt4.
      ADD 1 TO officer_paid_last4.
    ENDIF.

* If officer paid last month and also this month,
* check if there is adjustment in pay.
    IF sy-subrc = 0.
* Other adjustments to officer's salaries.
      READ TABLE itab_compare WITH KEY pernr = payroll_prev-pernr.
      IF sy-subrc = 0.
        ADD itab_compare-amt TO other_adjust_amt4.
      ENDIF.
    ENDIF.
  ENDLOOP.

* Officers paid this month but not last month.
  LOOP AT payroll_curr
    WHERE s1 = itab_temp-s1
    AND s2 = itab_temp-s2
    AND s3 = itab_temp-s3
    AND s4 = itab_temp-s4.

    READ TABLE payroll_prev WITH KEY
     s1 = payroll_curr-s1
     s2 = payroll_curr-s2
     s3 = payroll_curr-s3
     s4 = payroll_curr-s4
     pernr = payroll_curr-pernr.

    IF sy-subrc <> 0.
      ADD payroll_curr-amt TO officer_paid_this_amt4.
      ADD 1 TO officer_paid_this4.
    ENDIF.
  ENDLOOP.

* Officers c/f to next month.
  LOOP AT payroll_curr
    WHERE s1 = itab_temp-s1
    AND s2 = itab_temp-s2
    AND s3 = itab_temp-s3
    AND s4 = itab_temp-s4.

    ADD payroll_curr-amt TO officer_cf_amt4.
    ADD 1 TO officer_cf4.

  ENDLOOP.

ENDFORM.                    "cal_summary4

*---------------------------------------------------------------------*
*       FORM display_summary1                                         *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM display_summary1.

  DATA total(9) VALUE 0.
  DATA sum LIKE zspa_payroll_result-betrg.

  DATA temp(21).
  DATA temp_amt LIKE zspa_payroll_result-betrg.

  RESERVE 10 LINES.

  WRITE:/ 'Officer b/f from last month:'.
  WRITE: AT 150 ' '.

  WRITE:50 officer_bf1 RIGHT-JUSTIFIED.
  WRITE:60 officer_bf_amt1 RIGHT-JUSTIFIED.

* Officer paid last month but not this month.
  WRITE:/ 'Officer paid last month but not this month:'.
  WRITE: AT 150 ' '.

  DATA temp_count(9).
  CLEAR temp_count.
  temp_count = officer_paid_last1.
  SHIFT temp_count LEFT DELETING LEADING space.
  CONCATENATE '(' temp_count ')' INTO temp_count.
  WRITE:51 temp_count RIGHT-JUSTIFIED.

  CLEAR: temp,
         temp_amt.
  temp_amt = officer_paid_last_amt1.
  WRITE temp_amt LEFT-JUSTIFIED TO temp.
  CONCATENATE '(' temp ')' INTO temp.
  WRITE:60 temp RIGHT-JUSTIFIED.

* Other adjustments to officer's salaries.
  WRITE:/ 'Other adjustments to officer''s salaries:'.
  WRITE: AT 150 ' '.

  CLEAR: temp,
         temp_amt.
  IF other_adjust_amt1 < 0.
    temp_amt = other_adjust_amt1 * -1.
    WRITE temp_amt LEFT-JUSTIFIED TO temp.
    CONCATENATE '(' temp ')' INTO temp.
    WRITE:60 temp RIGHT-JUSTIFIED.
  ELSE.
    WRITE:60 other_adjust_amt1 RIGHT-JUSTIFIED.
  ENDIF.

* Sub-total
  WRITE: /53 '______________________________'.
  WRITE: AT 150 ' '.

  total = officer_bf1 - officer_paid_last1.
  sum = officer_bf_amt1 - officer_paid_last_amt1 + other_adjust_amt1.

  WRITE:/51 total.
  WRITE: AT 150 ' '.

  CLEAR: temp,
         temp_amt.
  IF sum < 0.
    temp_amt = sum * -1.
    WRITE temp_amt LEFT-JUSTIFIED TO temp.
    CONCATENATE '(' temp ')' INTO temp.
    WRITE:60 temp RIGHT-JUSTIFIED.
  ELSE.
    WRITE:60 sum RIGHT-JUSTIFIED.
  ENDIF.

* Officers paid this month but not last month.
  WRITE:/ 'Officers paid this month but not last month:'.
  WRITE: AT 150 ' '.

  WRITE:50 officer_paid_this1 RIGHT-JUSTIFIED.
  WRITE:60 officer_paid_this_amt1 RIGHT-JUSTIFIED.

  WRITE: /53 '______________________________'.
  WRITE: AT 150 ' '.

* Officers c/f to next month.
  WRITE:/ 'Officers c/f to next month:'.
  WRITE: AT 150 ' '.
  WRITE:50 officer_cf1 RIGHT-JUSTIFIED.
* WRITE:60 officer_cf_amt1 RIGHT-JUSTIFIED.
  CLEAR: temp,
         temp_amt.
  IF officer_cf_amt1 < 0.
    temp_amt = officer_cf_amt1 * -1.
    WRITE temp_amt LEFT-JUSTIFIED TO temp.
    CONCATENATE '(' temp ')' INTO temp.
    WRITE:60 temp RIGHT-JUSTIFIED.
  ELSE.
    WRITE:60 officer_cf_amt1 RIGHT-JUSTIFIED.
  ENDIF.

  WRITE: /53 '______________________________'.
  WRITE: AT 150 ' '.
  SKIP.
  ULINE.
ENDFORM.                    "display_summary1

*---------------------------------------------------------------------*
*       FORM display_summary2                                         *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM display_summary2.

  DATA total(9) VALUE 0.
  DATA sum LIKE zspa_payroll_result-betrg.

  DATA temp(21).
  DATA temp_amt LIKE zspa_payroll_result-betrg.

  RESERVE 10 LINES.

  WRITE:/ 'Officer b/f from last month:'.
  WRITE: AT 150 ' '.

  WRITE:50 officer_bf2 RIGHT-JUSTIFIED.
  WRITE:60 officer_bf_amt2 RIGHT-JUSTIFIED.

* Officer paid last month but not this month.
  WRITE:/ 'Officer paid last month but not this month:'.
  WRITE: AT 150 ' '.

  DATA temp_count(9).
  CLEAR temp_count.
  temp_count = officer_paid_last2.
  SHIFT temp_count LEFT DELETING LEADING space.
  CONCATENATE '(' temp_count ')' INTO temp_count.
  WRITE:51 temp_count RIGHT-JUSTIFIED.

  CLEAR: temp,
         temp_amt.
  temp_amt = officer_paid_last_amt2.
  WRITE temp_amt LEFT-JUSTIFIED TO temp.
  CONCATENATE '(' temp ')' INTO temp.
  WRITE:60 temp RIGHT-JUSTIFIED.

* Other adjustments to officer's salaries.
  WRITE:/ 'Other adjustments to officer''s salaries:'.
  WRITE: AT 150 ' '.

  CLEAR: temp,
         temp_amt.
  IF other_adjust_amt2 < 0.
    temp_amt = other_adjust_amt2 * -1.
    WRITE temp_amt LEFT-JUSTIFIED TO temp.
    CONCATENATE '(' temp ')' INTO temp.
    WRITE:60 temp RIGHT-JUSTIFIED.
  ELSE.
    WRITE:60 other_adjust_amt2 RIGHT-JUSTIFIED.
  ENDIF.

* Sub-total
  WRITE: /53 '______________________________'.
  WRITE: AT 150 ' '.

  total = officer_bf2 - officer_paid_last2.
  sum = officer_bf_amt2 - officer_paid_last_amt2 + other_adjust_amt2.

  WRITE:/51 total.
  WRITE: AT 150 ' '.

  CLEAR: temp,
         temp_amt.
  IF sum < 0.
    temp_amt = sum * -1.
    WRITE temp_amt LEFT-JUSTIFIED TO temp.
    CONCATENATE '(' temp ')' INTO temp.
    WRITE:60 temp RIGHT-JUSTIFIED.
  ELSE.
    WRITE:60 sum RIGHT-JUSTIFIED.
  ENDIF.

* Officers paid this month but not last month.
  WRITE:/ 'Officers paid this month but not last month:'.
  WRITE: AT 150 ' '.

  WRITE:50 officer_paid_this2 RIGHT-JUSTIFIED.
  WRITE:60 officer_paid_this_amt2 RIGHT-JUSTIFIED.

  WRITE: /53 '______________________________'.
  WRITE: AT 150 ' '.

* Officers c/f to next month.
  WRITE:/ 'Officers c/f to next month:'.
  WRITE: AT 150 ' '.
  WRITE:50 officer_cf2 RIGHT-JUSTIFIED.
* WRITE:60 officer_cf_amt2 RIGHT-JUSTIFIED.
  CLEAR: temp,
         temp_amt.
  IF officer_cf_amt2 < 0.
    temp_amt = officer_cf_amt2 * -1.
    WRITE temp_amt LEFT-JUSTIFIED TO temp.
    CONCATENATE '(' temp ')' INTO temp.
    WRITE:60 temp RIGHT-JUSTIFIED.
  ELSE.
    WRITE:60 officer_cf_amt2 RIGHT-JUSTIFIED.
  ENDIF.

  WRITE: /53 '______________________________'.
  WRITE: AT 150 ' '.
  SKIP.
  ULINE.
ENDFORM.                    "display_summary2

*---------------------------------------------------------------------*
*       FORM display_summary3                                         *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM display_summary3.

  DATA total(9) VALUE 0.
  DATA sum LIKE zspa_payroll_result-betrg.

  DATA temp(21).
  DATA temp_amt LIKE zspa_payroll_result-betrg.

  RESERVE 10 LINES.

  WRITE:/ 'Officer b/f from last month:'.
  WRITE: AT 150 ' '.

  WRITE:50 officer_bf3 RIGHT-JUSTIFIED.
  WRITE:60 officer_bf_amt3 RIGHT-JUSTIFIED.

* Officer paid last month but not this month.
  WRITE:/ 'Officer paid last month but not this month:'.
  WRITE: AT 150 ' '.

  DATA temp_count(9).
  CLEAR temp_count.
  temp_count = officer_paid_last3.
  SHIFT temp_count LEFT DELETING LEADING space.
  CONCATENATE '(' temp_count ')' INTO temp_count.
  WRITE:51 temp_count RIGHT-JUSTIFIED.

  CLEAR: temp,
         temp_amt.
  temp_amt = officer_paid_last_amt3.
  WRITE temp_amt LEFT-JUSTIFIED TO temp.
  CONCATENATE '(' temp ')' INTO temp.
  WRITE:60 temp RIGHT-JUSTIFIED.

* Other adjustments to officer's salaries.
  WRITE:/ 'Other adjustments to officer''s salaries:'.
  WRITE: AT 150 ' '.

  CLEAR: temp,
         temp_amt.
  IF other_adjust_amt3 < 0.
    temp_amt = other_adjust_amt3 * -1.
    WRITE temp_amt LEFT-JUSTIFIED TO temp.
    CONCATENATE '(' temp ')' INTO temp.
    WRITE:60 temp RIGHT-JUSTIFIED.
  ELSE.
    WRITE:60 other_adjust_amt3 RIGHT-JUSTIFIED.
  ENDIF.

* Sub-total
  WRITE: /53 '______________________________'.
  WRITE: AT 150 ' '.

  total = officer_bf3 - officer_paid_last3.
  sum = officer_bf_amt3 - officer_paid_last_amt3 + other_adjust_amt3.

  WRITE:/51 total.
  WRITE: AT 150 ' '.

  CLEAR: temp,
         temp_amt.
  IF sum < 0.
    temp_amt = sum * -1.
    WRITE temp_amt LEFT-JUSTIFIED TO temp.
    CONCATENATE '(' temp ')' INTO temp.
    WRITE:60 temp RIGHT-JUSTIFIED.
  ELSE.
    WRITE:60 sum RIGHT-JUSTIFIED.
  ENDIF.

* Officers paid this month but not last month.
  WRITE:/ 'Officers paid this month but not last month:'.
  WRITE: AT 150 ' '.

  WRITE:50 officer_paid_this3 RIGHT-JUSTIFIED.
  WRITE:60 officer_paid_this_amt3 RIGHT-JUSTIFIED.

  WRITE: /53 '______________________________'.
  WRITE: AT 150 ' '.

* Officers c/f to next month.
  WRITE:/ 'Officers c/f to next month:'.
  WRITE: AT 150 ' '.
  WRITE:50 officer_cf3 RIGHT-JUSTIFIED.
* WRITE:60 officer_cf_amt3 RIGHT-JUSTIFIED.
  CLEAR: temp,
         temp_amt.
  IF officer_cf_amt3 < 0.
    temp_amt = officer_cf_amt3 * -1.
    WRITE temp_amt LEFT-JUSTIFIED TO temp.
    CONCATENATE '(' temp ')' INTO temp.
    WRITE:60 temp RIGHT-JUSTIFIED.
  ELSE.
    WRITE:60 officer_cf_amt3 RIGHT-JUSTIFIED.
  ENDIF.
  WRITE: /53 '______________________________'.
  WRITE: AT 150 ' '.
  SKIP.
  ULINE.
ENDFORM.                    "display_summary3

*---------------------------------------------------------------------*
*       FORM display_summary4                                         *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM display_summary4.

  DATA total(9) VALUE 0.
  DATA sum LIKE zspa_payroll_result-betrg.

  DATA temp(21).
  DATA temp_amt LIKE zspa_payroll_result-betrg.

  RESERVE 10 LINES.

  WRITE:/ 'Officer b/f from last month:'.
  WRITE: AT 150 ' '.

  WRITE:50 officer_bf4 RIGHT-JUSTIFIED.
  WRITE:60 officer_bf_amt4 RIGHT-JUSTIFIED.

* Officer paid last month but not this month.
  WRITE:/ 'Officer paid last month but not this month:'.
  WRITE: AT 150 ' '.

  DATA temp_count(9).
  CLEAR temp_count.
  temp_count = officer_paid_last4.
  SHIFT temp_count LEFT DELETING LEADING space.
  CONCATENATE '(' temp_count ')' INTO temp_count.
  WRITE:51 temp_count RIGHT-JUSTIFIED.

  CLEAR: temp,
         temp_amt.
  temp_amt = officer_paid_last_amt4.
  WRITE temp_amt LEFT-JUSTIFIED TO temp.
  CONCATENATE '(' temp ')' INTO temp.
  WRITE:60 temp RIGHT-JUSTIFIED.

* Other adjustments to officer's salaries.
  WRITE:/ 'Other adjustments to officer''s salaries:'.
  WRITE: AT 150 ' '.

  CLEAR: temp,
         temp_amt.
  IF other_adjust_amt4 < 0.
    temp_amt = other_adjust_amt4 * -1.
    WRITE temp_amt LEFT-JUSTIFIED TO temp.
    CONCATENATE '(' temp ')' INTO temp.
    WRITE:60 temp RIGHT-JUSTIFIED.
  ELSE.
    WRITE:60 other_adjust_amt4 RIGHT-JUSTIFIED.
  ENDIF.

* Sub-total
  WRITE: /53 '______________________________'.
  WRITE: AT 150 ' '.

  total = officer_bf4 - officer_paid_last4.
  sum = officer_bf_amt4 - officer_paid_last_amt4 + other_adjust_amt4.

  WRITE:/51 total.
  WRITE: AT 150 ' '.

  CLEAR: temp,
         temp_amt.
  IF sum < 0.
    temp_amt = sum * -1.
    WRITE temp_amt LEFT-JUSTIFIED TO temp.
    CONCATENATE '(' temp ')' INTO temp.
    WRITE:60 temp RIGHT-JUSTIFIED.
  ELSE.
    WRITE:60 sum RIGHT-JUSTIFIED.
  ENDIF.

* Officers paid this month but not last month.
  WRITE:/ 'Officers paid this month but not last month:'.
  WRITE: AT 150 ' '.

  WRITE:50 officer_paid_this4 RIGHT-JUSTIFIED.
  WRITE:60 officer_paid_this_amt4 RIGHT-JUSTIFIED.

  WRITE: /53 '______________________________'.
  WRITE: AT 150 ' '.

* Officers c/f to next month.
  WRITE:/ 'Officers c/f to next month:'.
  WRITE: AT 150 ' '.
  WRITE:50 officer_cf4 RIGHT-JUSTIFIED.
* WRITE:60 officer_cf_amt4 RIGHT-JUSTIFIED.
  CLEAR: temp,
         temp_amt.
  IF officer_cf_amt4 < 0.
    temp_amt = officer_cf_amt4 * -1.
    WRITE temp_amt LEFT-JUSTIFIED TO temp.
    CONCATENATE '(' temp ')' INTO temp.
    WRITE:60 temp RIGHT-JUSTIFIED.
  ELSE.
    WRITE:60 officer_cf_amt4 RIGHT-JUSTIFIED.
  ENDIF.

  WRITE: /53 '______________________________'.
  WRITE: AT 150 ' '.
  SKIP.
  ULINE.
ENDFORM.                    "display_summary4


*---------------------------------------------------------------------*
*       FORM final_total                                              *
*---------------------------------------------------------------------*
*  This subroutine prints the grand head count at the bottom of the   *
*  report.                                                            *
*                                                                     *
*---------------------------------------------------------------------*
FORM final_total.

  DATA total(9) VALUE 0.
  DATA sum LIKE zspa_payroll_result-betrg.

  DATA officer_bf(9) VALUE 0.
  DATA officer_bf_amt LIKE zspa_payroll_result-betrg.

  DATA officer_paid_last(9) VALUE 0.
  DATA officer_paid_last_amt LIKE zspa_payroll_result-betrg.

  DATA other_adjust_amt LIKE zspa_payroll_result-betrg.

  DATA officer_paid_this(9) VALUE 0.
  DATA officer_paid_this_amt LIKE zspa_payroll_result-betrg.

  DATA officer_cf(9) VALUE 0.
  DATA officer_cf_amt LIKE zspa_payroll_result-betrg.

  DATA temp(21).
  DATA temp_amt LIKE zspa_payroll_result-betrg.

  RESERVE 10 LINES.

  WRITE:/ 'Officer b/f from last month:'.

  officer_bf = 0.
  CLEAR officer_bf_amt.

  LOOP AT payroll_prev.
    ADD payroll_prev-amt TO officer_bf_amt.
    ADD 1 TO officer_bf.
  ENDLOOP.

  WRITE:50 officer_bf RIGHT-JUSTIFIED.
  WRITE:60 officer_bf_amt RIGHT-JUSTIFIED.

* Officer paid last month but not this month.
  WRITE:/ 'Officer paid last month but not this month:'.

  officer_paid_last = 0.
  CLEAR officer_paid_last_amt.

  LOOP AT payroll_prev.
    READ TABLE payroll_curr WITH KEY
    pernr = payroll_prev-pernr.
    IF sy-subrc <> 0.
      ADD payroll_prev-amt TO officer_paid_last_amt.
      ADD 1 TO officer_paid_last.
    ENDIF.
  ENDLOOP.

  DATA temp_count(9).
  CLEAR temp_count.
  temp_count = officer_paid_last.
  SHIFT temp_count LEFT DELETING LEADING space.
  CONCATENATE '(' temp_count ')' INTO temp_count.
  WRITE:51 temp_count RIGHT-JUSTIFIED.

  CLEAR: temp,
         temp_amt.
  temp_amt = officer_paid_last_amt.
  WRITE temp_amt LEFT-JUSTIFIED TO temp.
  CONCATENATE '(' temp ')' INTO temp.
  WRITE:60 temp RIGHT-JUSTIFIED.

* Other adjustments to officer's salaries.
  WRITE:/ 'Other adjustments to officer''s salaries:'.

  CLEAR other_adjust_amt.

  LOOP AT itab_compare.
    ADD itab_compare-amt TO other_adjust_amt.
  ENDLOOP.

  CLEAR: temp,
         temp_amt.
  IF other_adjust_amt < 0.
    temp_amt = other_adjust_amt * -1.
    WRITE temp_amt LEFT-JUSTIFIED TO temp.
    CONCATENATE '(' temp ')' INTO temp.
    WRITE:60 temp RIGHT-JUSTIFIED.
  ELSE.
    WRITE:60 other_adjust_amt RIGHT-JUSTIFIED.
  ENDIF.

* Sub-total
  ULINE:/53(30).

  total = officer_bf - officer_paid_last.
  sum = officer_bf_amt - officer_paid_last_amt + other_adjust_amt.

  WRITE:/51 total.

  CLEAR: temp,
         temp_amt.
  IF sum < 0.
    temp_amt = sum * -1.
    WRITE temp_amt LEFT-JUSTIFIED TO temp.
    CONCATENATE '(' temp ')' INTO temp.
    WRITE:60 temp RIGHT-JUSTIFIED.
  ELSE.
    WRITE:60 sum RIGHT-JUSTIFIED.
  ENDIF.

* Officers paid this month but not last month.
  WRITE:/ 'Officers paid this month but not last month:'.

  officer_paid_this = 0.
  CLEAR officer_paid_this_amt.

  LOOP AT payroll_curr.
    READ TABLE payroll_prev WITH KEY
    pernr = payroll_curr-pernr.
    IF sy-subrc <> 0.
      ADD payroll_curr-amt TO officer_paid_this_amt.
      ADD 1 TO officer_paid_this.
    ENDIF.
  ENDLOOP.
  WRITE:50 officer_paid_this RIGHT-JUSTIFIED.
  WRITE:60 officer_paid_this_amt RIGHT-JUSTIFIED.

  ULINE:/53(30).

* Officers c/f to next month.
  WRITE:/ 'Officers c/f to next month:'.

  officer_cf = 0.
  CLEAR officer_cf_amt.

  LOOP AT payroll_curr.
    ADD payroll_curr-amt TO officer_cf_amt.
    ADD 1 TO officer_cf.
  ENDLOOP.

  WRITE:50 officer_cf RIGHT-JUSTIFIED.

* WRITE:60 officer_cf_amt RIGHT-JUSTIFIED.
  CLEAR: temp,
         temp_amt.
  IF officer_cf_amt < 0.
    temp_amt = officer_cf_amt * -1.
    WRITE temp_amt LEFT-JUSTIFIED TO temp.
    CONCATENATE '(' temp ')' INTO temp.
    WRITE:60 temp RIGHT-JUSTIFIED.
  ELSE.
    WRITE:60 officer_cf_amt RIGHT-JUSTIFIED.
  ENDIF.
  ULINE:/53(30).

  SKIP.
  ULINE.
ENDFORM.                    "final_total



*---------------------------------------------------------------------*
*       FORM wagetype_final_total                                     *
*---------------------------------------------------------------------*
*  This subroutine prints the grand total at the bottom of the report.*
*---------------------------------------------------------------------*
FORM wagetype_final_total.


  DATA: itab_wagetype_total LIKE itab_final_total OCCURS 100
        WITH HEADER LINE.
  DATA: itab_wagetype_total1 LIKE itab_final_total OCCURS 100 WITH HEADER LINE, "CR-0000000739
        lt_final_temp        TYPE STANDARD TABLE OF ty_final_tab1,
        lwa_final_temp       TYPE ty_final_tab1,
        lt_final_temp1       TYPE STANDARD TABLE OF ty_final_tab1,
        lt_final_temp2       TYPE STANDARD TABLE OF ty_final_tab1,
        lt_final_temp3       TYPE STANDARD TABLE OF ty_final_tab1,
        lwa_final_temp1      TYPE ty_final_tab1,
        lwa_final_temp3      TYPE ty_final_tab1,
        lwa_final_tab        TYPE ty_final_tab,
        lwa_final_tab1       TYPE ty_final_tab,
        lwa_final_tab2       TYPE ty_final_tab,
        lwa_ee_grp           TYPE ty_ee_group.

  DATA: lv_has563        TYPE c,
        lv_has563infinal TYPE c.
  SORT it_ee_group BY pernr."CR-0000000739
  SORT itab_total BY inper seqnr.
*  RESERVE 10 LINES.
*  NEW-PAGE.
*<------------------- Start Modification Reuben 13/7/2010 AVA-128188 ----------------->
*  LOOP AT itab_total WHERE NOT total_wage IS INITIAL.
*    MOVE-CORRESPONDING itab_total TO itab_final_total.
*    APPEND itab_final_total.
*  ENDLOOP.
  LOOP AT itab_total WHERE NOT total_wage IS INITIAL.
    IF itab_total-inper EQ in_per OR action EQ '2'.
      IF itab_total-lgart = '/563'.
        LOOP AT temp_itab_total_1 WHERE lgart = itab_total-lgart AND pernr = itab_total-pernr.
          MOVE-CORRESPONDING temp_itab_total_1 TO itab_final_total.
          APPEND itab_final_total.
        ENDLOOP.
      ELSEIF itab_total-lgart <> '9DBF' AND itab_total-lgart <> '9DCF'.
        MOVE-CORRESPONDING itab_total TO itab_final_total.
        APPEND itab_final_total.

*<-- Start of Change Edited by Angela Foong 21/09/10 -->
        " AVA-164196 Processing for 9DBF / 9DCF without /563
      ELSEIF itab_total-lgart = '9DBF' OR itab_total-lgart = '9DCF'.
        CLEAR: lv_has563, lv_has563infinal.

        "Check if this person has any /563 in itab_total.
        LOOP AT itab_total WHERE lgart = '/563' AND pernr = itab_total-pernr.
          lv_has563 = 'Y'.
          EXIT.
        ENDLOOP.
        IF lv_has563 = 'Y'. "This person has /563 records, ignore 9DBF and 9DCF
          CONTINUE.
        ELSE. "No /563 records, to read from temp_itab_total_1
          "Check that the itab_final_total does not have /563 added already
          LOOP AT itab_final_total WHERE pernr = itab_total-pernr AND lgart = '/563'. "only pernr will be filled if /563 is added due to 9dbf and 0dcf
            lv_has563infinal = 'Y'.
            EXIT.
          ENDLOOP.
          IF lv_has563infinal = 'Y'. "do not add to prevent double
            CONTINUE.
          ELSE. "get the record from temp internal table
            LOOP AT temp_itab_total_1 WHERE lgart = '/563' AND pernr = itab_total-pernr.
              MOVE-CORRESPONDING temp_itab_total_1 TO itab_final_total.
              APPEND itab_final_total.
            ENDLOOP.
          ENDIF.
        ENDIF.
*<-- End of Change Edited by Angela Foong 21/09/10 -->
      ELSE.
        IF lv_has563 = 'Y'. "This person has /563 records, ignore 9DBF and 9DCF
          CONTINUE.
        ELSE. "No /563 records, to read from temp_itab_total_1
          "Check that the itab_final_total does not have /563 added already
          LOOP AT itab_final_total WHERE pernr = itab_total-pernr AND lgart = '/563'. "only pernr will be filled if /563 is added due to 9dbf and 0dcf
            lv_has563infinal = 'Y'.
            EXIT.
          ENDLOOP.
          IF lv_has563infinal = 'Y'. "do not add to prevent double
            CONTINUE.
          ELSE. "get the record from temp internal table
            LOOP AT temp_itab_total_1 WHERE lgart = '/563' AND pernr = itab_total-pernr.
              MOVE-CORRESPONDING temp_itab_total_1 TO itab_final_total.
              APPEND itab_final_total.
            ENDLOOP.
          ENDIF.
        ENDIF.
      ENDIF.
    ELSE."IF itab_total-inper EQ fp_per.
      IF itab_total-lgart = '/563'.
        LOOP AT temp_itab_total_1 WHERE lgart = itab_total-lgart AND pernr = itab_total-pernr.
          MOVE-CORRESPONDING temp_itab_total_1 TO itab_final_total1.
          APPEND itab_final_total1.
        ENDLOOP.
      ELSEIF itab_total-lgart <> '9DBF' AND itab_total-lgart <> '9DCF'.
        MOVE-CORRESPONDING itab_total TO itab_final_total1.
        APPEND itab_final_total1.

*<-- Start of Change Edited by Angela Foong 21/09/10 -->
        " AVA-164196 Processing for 9DBF / 9DCF without /563
      ELSEIF itab_total-lgart = '9DBF' OR itab_total-lgart = '9DCF'.
        CLEAR: lv_has563, lv_has563infinal.

        "Check if this person has any /563 in itab_total.
        LOOP AT itab_total WHERE lgart = '/563' AND pernr = itab_total-pernr.
          lv_has563 = 'Y'.
          EXIT.
        ENDLOOP.
        IF lv_has563 = 'Y'. "This person has /563 records, ignore 9DBF and 9DCF
          CONTINUE.
        ELSE. "No /563 records, to read from temp_itab_total_1
          "Check that the itab_final_total does not have /563 added already
          LOOP AT itab_final_total WHERE pernr = itab_total-pernr AND lgart = '/563'. "only pernr will be filled if /563 is added due to 9dbf and 0dcf
            lv_has563infinal = 'Y'.
            EXIT.
          ENDLOOP.
          IF lv_has563infinal = 'Y'. "do not add to prevent double
            CONTINUE.
          ELSE. "get the record from temp internal table
            LOOP AT temp_itab_total_1 WHERE lgart = '/563' AND pernr = itab_total-pernr.
              MOVE-CORRESPONDING temp_itab_total_1 TO itab_final_total1.
              APPEND itab_final_total1.
            ENDLOOP.
          ENDIF.
        ENDIF.
*<-- End of Change Edited by Angela Foong 21/09/10 -->
      ELSE.
        IF lv_has563 = 'Y'. "This person has /563 records, ignore 9DBF and 9DCF
          CONTINUE.
        ELSE. "No /563 records, to read from temp_itab_total_1
          "Check that the itab_final_total does not have /563 added already
          LOOP AT itab_final_total WHERE pernr = itab_total-pernr AND lgart = '/563'. "only pernr will be filled if /563 is added due to 9dbf and 0dcf
            lv_has563infinal = 'Y'.
            EXIT.
          ENDLOOP.
          IF lv_has563infinal = 'Y'. "do not add to prevent double
            CONTINUE.
          ELSE. "get the record from temp internal table
            LOOP AT temp_itab_total_1 WHERE lgart = '/563' AND pernr = itab_total-pernr.
              MOVE-CORRESPONDING temp_itab_total_1 TO itab_final_total1.
              APPEND itab_final_total1.
            ENDLOOP.
          ENDIF.
        ENDIF.
      ENDIF.
    ENDIF.
  ENDLOOP.
*<------------------- End Modification Reuben 13/7/2010 AVA-128188 ----------------->
  SORT itab_final_total BY lgart.
  SORT itab_final_total1 BY lgart."CR-0000000739

  LOOP AT itab_final_total.
    itab_wagetype_total-wage_desc = itab_final_total-wage_desc.
    MOVE : itab_final_total-pernr TO itab_wagetype_total-pernr."CR-0000000739
    AT END OF lgart.
      SUM.
      itab_wagetype_total-lgart = itab_final_total-lgart.
      itab_wagetype_total-total_wage = itab_final_total-total_wage.
      APPEND itab_wagetype_total.
    ENDAT.
  ENDLOOP.

  LOOP AT itab_final_total1.
    itab_wagetype_total1-wage_desc = itab_final_total1-wage_desc.
    MOVE : itab_final_total1-pernr TO itab_wagetype_total-pernr."CR-0000000739
    AT END OF lgart.
      SUM.
      itab_wagetype_total1-lgart = itab_final_total1-lgart.
      itab_wagetype_total1-total_wage = itab_final_total1-total_wage.
      APPEND itab_wagetype_total1.
    ENDAT.
  ENDLOOP.
  SORT itab_final_total BY pernr lgart."CR-0000000739
  SORT itab_final_total1 BY pernr lgart."CR-0000000739

  LOOP AT itab_final_total.
    MOVE : itab_final_total-pernr TO lwa_final_temp-pernr,
           itab_final_total-lgart TO lwa_final_temp-lgart.

    AT END OF lgart.
      SUM.
      PERFORM fill_wt_amount USING itab_final_total-total_wage
                          CHANGING lwa_final_temp.
      APPEND lwa_final_temp TO lt_final_temp.
      CLEAR lwa_final_temp.
    ENDAT.
  ENDLOOP.

  LOOP AT itab_final_total1.
    MOVE : itab_final_total1-pernr TO lwa_final_temp-pernr,
           itab_final_total1-lgart TO lwa_final_temp-lgart.

    AT END OF lgart.
      SUM.
      PERFORM fill_wt_amount USING itab_final_total1-total_wage
                          CHANGING lwa_final_temp.
      APPEND lwa_final_temp TO lt_final_temp1.
      CLEAR lwa_final_temp.
    ENDAT.
  ENDLOOP.
  SORT lt_final_temp BY lgart persg pernr.
  DELETE lt_final_temp WHERE lgart IS INITIAL."CR-0000000739
  lt_final_temp2 = lt_final_temp.

  SORT lt_final_temp1 BY lgart persg pernr.
  DELETE lt_final_temp1 WHERE lgart IS INITIAL."CR-0000000739
  lt_final_temp3 = lt_final_temp1.



  LOOP AT lt_final_temp INTO lwa_final_temp.
    AT NEW lgart.
      LOOP AT lt_final_temp2 INTO lwa_final_temp1 WHERE lgart EQ lwa_final_temp-lgart.
        READ TABLE it_ee_group INTO lwa_ee_grp WITH KEY pernr = lwa_final_temp1-pernr."lwa_final_temp-pernr.
        IF sy-subrc EQ 0.
          IF lwa_ee_grp-momag EQ '1'.
            MOVE : "lwa_final_temp-pernr  TO lwa_final_tab-pernr,
                   lwa_final_temp1-lgart  TO lwa_final_tab1-lgart,
                   lwa_final_temp1-acct   TO lwa_final_tab1-acct.
            CASE lwa_final_temp1-persg.
              WHEN gc_ee_grp_p."Trainer-TR
                lwa_final_tab1-total_wage_tr  = lwa_final_tab1-total_wage_tr + lwa_final_temp1-total_wage_tr.
              WHEN gc_ee_grp_q."Clerk of Works-COW
                lwa_final_tab1-total_wage_cow = lwa_final_tab1-total_wage_cow + lwa_final_temp1-total_wage_cow.
              WHEN OTHERS."PA
                lwa_final_tab1-total_wage_pa  = lwa_final_tab1-total_wage_pa + lwa_final_temp1-total_wage_pa.
            ENDCASE.

          ELSEIF lwa_ee_grp-momag EQ '2'.
            MOVE : "lwa_final_temp-pernr  TO lwa_final_tab-pernr,
                   lwa_final_temp1-lgart  TO lwa_final_tab2-lgart,
                   lwa_final_temp1-acct  TO lwa_final_tab2-acct.
            CASE lwa_final_temp1-persg.
              WHEN gc_ee_grp_p."Trainer-TR
                lwa_final_tab2-total_wage_tr  = lwa_final_tab2-total_wage_tr + lwa_final_temp1-total_wage_tr.
              WHEN gc_ee_grp_q."Clerk of Works-COW
                lwa_final_tab2-total_wage_cow = lwa_final_tab2-total_wage_cow + lwa_final_temp1-total_wage_cow.
              WHEN OTHERS."PA
                lwa_final_tab2-total_wage_pa  = lwa_final_tab2-total_wage_pa + lwa_final_temp1-total_wage_pa.
            ENDCASE.

          ENDIF.
        ENDIF.
      ENDLOOP.
      lwa_final_tab1-total_wage =  lwa_final_tab1-total_wage_pa +
                                   lwa_final_tab1-total_wage_tr +
                                   lwa_final_tab1-total_wage_cow.

      lwa_final_tab2-total_wage =  lwa_final_tab2-total_wage_pa +
                                   lwa_final_tab2-total_wage_tr +
                                   lwa_final_tab2-total_wage_cow.

      LOOP AT lt_final_temp3 INTO lwa_final_temp3 WHERE lgart EQ lwa_final_temp-lgart.
        READ TABLE it_ee_group INTO lwa_ee_grp WITH KEY pernr = lwa_final_temp3-pernr."lwa_final_temp-pernr.
        IF sy-subrc EQ 0.
          IF lwa_ee_grp-momag EQ '1'.
            CASE lwa_final_temp3-persg.
              WHEN gc_ee_grp_p."Trainer-TR
                lwa_final_tab1-total_wage_tr1  = lwa_final_tab1-total_wage_tr1 + lwa_final_temp3-total_wage_tr.
              WHEN gc_ee_grp_q."Clerk of Works-COW
                lwa_final_tab1-total_wage_cow1 = lwa_final_tab1-total_wage_cow1 + lwa_final_temp3-total_wage_cow.
              WHEN OTHERS."PA
                lwa_final_tab1-total_wage_pa1  = lwa_final_tab1-total_wage_pa1 + lwa_final_temp3-total_wage_pa.
            ENDCASE.
          ELSEIF lwa_ee_grp-momag EQ '2'.
            CASE lwa_final_temp3-persg.
              WHEN gc_ee_grp_p."Trainer-TR
                lwa_final_tab2-total_wage_tr1 = lwa_final_tab2-total_wage_tr1 + lwa_final_temp3-total_wage_tr.
              WHEN gc_ee_grp_q."Clerk of Works-COW
                lwa_final_tab2-total_wage_cow1 = lwa_final_tab2-total_wage_cow1 + lwa_final_temp3-total_wage_cow.
              WHEN OTHERS."PA
                lwa_final_tab2-total_wage_pa1 = lwa_final_tab2-total_wage_pa1 + lwa_final_temp3-total_wage_pa.
            ENDCASE.
          ENDIF.
        ENDIF.
      ENDLOOP.
      lwa_final_tab1-total_wage1 =  lwa_final_tab1-total_wage_pa1 +
                                    lwa_final_tab1-total_wage_tr1 +
                                    lwa_final_tab1-total_wage_cow1.

      lwa_final_tab2-total_wage1 =  lwa_final_tab2-total_wage_pa1 +
                                    lwa_final_tab2-total_wage_tr1 +
                                    lwa_final_tab2-total_wage_cow1.
      IF NOT lwa_final_tab1 IS INITIAL.
        APPEND lwa_final_tab1 TO it_final_tab.
      ENDIF.
      IF NOT lwa_final_tab2 IS INITIAL.
        APPEND lwa_final_tab2 TO it_final_tab.
      ENDIF.
      CLEAR : lwa_final_tab1,lwa_final_tab2.
    ENDAT.
  ENDLOOP.
  DATA: c         TYPE i VALUE '1',
        d         TYPE i,
        x         TYPE i VALUE '15',
        y         TYPE i VALUE '5',
        typedesc  TYPE p DECIMALS 2,
        total_pay TYPE p DECIMALS 2,
        total_ded TYPE p DECIMALS 2,
        net_pay   TYPE p DECIMALS 2.

  CLEAR: total_pay, total_ded, net_pay.

* Display allowances

  SORT itab_wagetype_total BY lgart ASCENDING.

*  ULINE."CR-0000000739 - Commented

* print 9S first.
  " ting ting commented 27.05.2009
*  LOOP AT itab_wagetype_total WHERE lgart+0(2) = '9S'
*                              AND lgart NE '9S%%'.


  LOOP AT itab_wagetype_total WHERE lgart NOT IN itab_wagedec[]
                              AND lgart <> '/563'
                              AND lgart IN gt_allowance[]
                              AND lgart <> ' '
                              AND lgart <> '0725' " < SIR CE00007391
                              AND lgart <> '0ERA' " SIR CE00007858 Ting Ting added 17.06.2009
                              AND lgart <> '4MSO'. " SIR CE00007762 Ting Ting added 15.06.2009

    total_pay = total_pay + itab_wagetype_total-total_wage.

* The salary wage type (9S**) will be written in column 1, 41, 81
* and when the column exceed 120, it will write next line at column 15.

* The value x is to keep track of the column
* The value c is to ensure that 'ALW:' text-020 is printed once only.
    IF c = 1.
*      WRITE: AT /10(5) text-020 ,"CR-0000000739 - Commented
*      15(15) itab_wagetype_total-wage_desc,
*      '  :  ' ,
*      (15) itab_wagetype_total-total_wage.
      c = c + 1.
    ELSE.
      IF x  >= 130.
*        NEW-LINE."CR-0000000739 - Commented
        x = 15.
      ENDIF.
    ENDIF.
    x  =  x + 40.
  ENDLOOP.


  " ting ting commented 27.05.2009
**( HRPS/05/040 TCTC Wage Type
*
**  LOOP AT itab_wagetype_total WHERE lgart = '9Z91'. " ting ting comment
*  LOOP AT itab_wagetype_total WHERE lgart = '1Z01' OR lgart = '1Z91'.
*
*    total_pay = total_pay + itab_wagetype_total-total_wage.
*
*    IF c = 1.
*      WRITE: AT /10(5) text-020 ,
*      15(15) itab_wagetype_total-wage_desc,
*      '  :  ' ,
*      (10) itab_wagetype_total-total_wage.
*      c = c + 1.
*
*    ELSE.
*      IF x  >= 130.
*        NEW-LINE.
*        x = 15.
*      ENDIF.
*      WRITE: AT x(15) itab_wagetype_total-wage_desc,
*             '  :  ',
*             (10) itab_wagetype_total-total_wage.
*    ENDIF.
*    x  =  x + 40.
*  ENDLOOP.
**)
*
**now print the others.
*  LOOP AT itab_wagetype_total WHERE ( lgart+0(2) = '9A'  OR
*                            lgart+0(2) = '9C'  OR
*                            lgart+0(2) = '9O'  OR
*                            lgart+0(2) = '9B'  OR
*                            lgart+0(2) = '9W' ). "OR
**                            lgart+0(2) = '9M' ).
*
*    IF itab_wagetype_total-lgart NE '3W02' AND itab_wagetype_total-lgart NE '3LS2' AND itab_wagetype_total-lgart NE '3LS2'  AND itab_wagetype_total-lgart NE '3023'.
**    IF itab_wagetype_total-lgart NE '9W02'. " ting ting comment
*      total_pay =   total_pay + itab_wagetype_total-total_wage.
*    ENDIF.
*
*    IF c = 1.
*      WRITE: AT /10(5) text-020 ,
*                15(15) itab_wagetype_total-wage_desc,
*                '  :  ' ,
*                (10) itab_wagetype_total-total_wage.
*
*      c = c + 1.
*    ELSE.
*      IF x  >= 130.
*        NEW-LINE.
*        x = 15.
*      ENDIF.
*      WRITE: AT x(15) itab_wagetype_total-wage_desc,
*              '  :  ',
*              (10)itab_wagetype_total-total_wage.
*    ENDIF.
*    x  =  x + 40.
*  ENDLOOP.

  d = 1.

* Display deductions
  x = 15.
  LOOP AT itab_wagetype_total WHERE
*    lgart+0(2) = '9D'  OR  " ting ting 27.7.2009
                                      lgart = '/305'  OR
*{ Insert ncslts 29.11.2004
                                      lgart = '/314'  OR
*}
                                      lgart = '/370'  OR
                                      lgart = '/371'  OR
                                      lgart = '/372'  OR
                                      lgart = '/373'  OR
                                      lgart = '/374'  OR
                                      lgart = '/563'  OR

              " Start ting ting commented 01.09.2009 Sir 9233
             lgart = '9DBF'  OR
            lgart = '9DCF'  OR
            " End ting ting commented 01.09.2009
*                                      lgart = '/565'  OR
*                                      lgart = '/566'  OR
                                      lgart = '/375'  OR
                                      lgart =  '/305' OR "E'yee,CPF-curr.contr./sum
                                      lgart =  '/370' OR "E'yee, CDAC, add.fund
                                      lgart =  '/371' OR "E'yee, SINDA,add.fund
                                      lgart =  '/372' OR "E'yee, MBMF, add.fund
                                      lgart = '/373'  OR "E'yee, ECF   add.fund
                                      lgart = '/374'  OR "E'yee, COMCS add.fund
                                      lgart = '/375'  OR "E'yee, Other fund
*                                      lgart =  '/565' OR"Carry-over for subs.month
*                                      lgart =  '/566' OR "Carry-over for prev.month
                                      lgart = '/314'  OR "E'YEE, Shortfall on AW
*                                      lgart = '/450'  OR
*                                      lgart = '/303'  OR " ting ting commented 12.06.2009 CE00007621
*                                      lgart = '/307'  OR
                                      lgart IN itab_wagedec[].

*    IF  itab_wagetype_total-lgart+0(2) = '9D' OR lgart IN itab_wagedec[].
*    IF  itab_wagetype_total-lgart IN itab_wagedec[]. " ting commented 03.06.2009

    IF ( itab_wagetype_total-lgart = '/305'  OR
*{ Insert ncslts 29.11.2004
                                    itab_wagetype_total-lgart = '/314'  OR
*}
                                    itab_wagetype_total-lgart = '/370'  OR
                                    itab_wagetype_total-lgart = '/371'  OR
                                    itab_wagetype_total-lgart = '/372'  OR
                                    itab_wagetype_total-lgart = '/373'  OR
                                    itab_wagetype_total-lgart = '/374'  OR
                                    itab_wagetype_total-lgart = '/563'  OR
                " Start ting ting commented 01.09.2009 Sir 9233
             itab_total-lgart = '9DBF'  OR
            itab_total-lgart = '9DCF'  OR
            " End ting ting commented 01.09.2009
*                                    itab_wagetype_total-lgart = '/565'  OR
*                                    itab_wagetype_total-lgart = '/566'  OR
                                    itab_wagetype_total-lgart = '/375' OR
                                    itab_wagetype_total-lgart =  '/305' OR "E'yee,CPF-curr.contr./sum
                                    itab_wagetype_total-lgart =  '/370'OR "E'yee, CDAC, add.fund
                                    itab_wagetype_total-lgart =  '/371'OR "E'yee, SINDA,add.fund
                                    itab_wagetype_total-lgart =  '/372'OR "E'yee, MBMF, add.fund
                                    itab_wagetype_total-lgart = '/373'OR "E'yee, ECF   add.fund
                                    itab_wagetype_total-lgart = '/374'OR "E'yee, COMCS add.fund
                                    itab_wagetype_total-lgart = '/375'OR "E'yee, Other fund
*                                    itab_wagetype_total-lgart =  '/565' OR"Carry-over for subs.month
*                                    itab_wagetype_total-lgart =  '/566'OR "Carry-over for prev.month
                                    itab_wagetype_total-lgart = '/314' "OR "E'YEE, Shortfall on AW
*                                    itab_wagetype_total-lgart = '/450' OR
*                                    itab_wagetype_total-lgart = '/303' " ting ting commented 12.06.2009 CE00007621
*      OR
*                                    itab_wagetype_total-lgart = '/307'
      ).
    ELSE.
      itab_wagetype_total-total_wage =
                       itab_wagetype_total-total_wage * -1.
    ENDIF.



    " ting ting added 01.09.2009 Start SIR9233
    " Cal Prev mth
    IF itab_total-lgart = '9DBF'  OR       itab_total-lgart = '9DCF' OR  itab_total-lgart = '/563'.

      DATA : lv_flag563 TYPE char1.
      DATA : lv_flagp TYPE char1.

      DATA : lv_indexhere TYPE i.
      DATA : lv_index9dbf TYPE i.
      DATA : lv_index9dcf TYPE i.
      DATA : lv_index563 TYPE i.
      DATA:  lv_total_wage TYPE p DECIMALS 2.
      DATA:  lv_total_wage9dbf TYPE p DECIMALS 2.
      DATA:  lv_total_wage563 TYPE p DECIMALS 2.
      DATA:  lv_total_wage9dcf TYPE p DECIMALS 2.
      CLEAR lv_flag563.
      CLEAR lv_total_wage9dbf.
      CLEAR  lv_total_wage9dcf.
      LOOP AT itab_total WHERE lgart = '/563'.
        lv_flag563 = 'Y'.
        EXIT.
      ENDLOOP.

      IF ( lv_flag563 = 'Y' ).

        IF ( lv_flagp = 'Y').
          CLEAR itab_totaltemp[].
          CLEAR lv_indexhere.
          CLEAR lv_index563.
          CLEAR lv_total_wage563.
          CLEAR lv_total_wage9dbf.
          CLEAR  lv_total_wage9dcf.

          LOOP AT itab_total.
            lv_indexhere = lv_indexhere + 1.

            IF ( itab_total-lgart = '/563' ) .
              lv_index563 = lv_indexhere.
              CLEAR  lv_total_wage.

              lv_total_wage = itab_total-total_wage.
              lv_total_wage563 =  lv_total_wage +  lv_total_wage563.
            ENDIF.

            IF ( itab_total-lgart = '9DBF' ) .
              lv_index9dbf = lv_indexhere.
              DELETE itab_total INDEX lv_index9dbf.
              lv_indexhere =  lv_indexhere - 1.

              READ TABLE gt_t512 INTO gwa_t512 WITH KEY lgart = '/563'.
              IF sy-subrc = 0.
                itab_totaltemp-wage_desc = gwa_t512-lgtxt.
              ENDIF.

              itab_totaltemp-lgart = '/563'.
              CLEAR  lv_total_wage.

              lv_total_wage = itab_total-total_wage.
              lv_total_wage9dbf = lv_total_wage + lv_total_wage9dbf.
            ENDIF.

            IF ( itab_total-lgart = '9DCF' ) .
              lv_index9dcf = lv_indexhere.
              DELETE itab_total INDEX lv_index9dcf.
              lv_indexhere =  lv_indexhere - 1.

              READ TABLE gt_t512 INTO gwa_t512 WITH KEY lgart = '/563'.
              IF sy-subrc = 0.
                itab_totaltemp-wage_desc = gwa_t512-lgtxt.
              ENDIF.


              itab_totaltemp-lgart = '/563'.
              CLEAR  lv_total_wage.

              lv_total_wage = itab_total-total_wage.
              lv_total_wage9dcf =  lv_total_wage + lv_total_wage9dcf.
            ENDIF.

          ENDLOOP.

          itab_totaltemp-total_wage = lv_total_wage9dbf - lv_total_wage9dcf + +  lv_total_wage563.
*              APPEND itab_totaltemp TO itab_total.
          READ TABLE itab_total INDEX  lv_index563.
          IF sy-subrc  = 0.
            itab_total = itab_totaltemp.
            MODIFY itab_total INDEX lv_index563.
          ENDIF.

        ENDIF.

      ELSE.
        CLEAR itab_totaltemp[].
        CLEAR lv_indexhere.
        CLEAR lv_total_wage9dbf.
        CLEAR  lv_total_wage9dcf.
        LOOP AT itab_total.
          lv_indexhere = lv_indexhere + 1.

          IF ( itab_total-lgart = '9DBF' ) .
            lv_index9dbf = lv_indexhere.
            DELETE itab_total INDEX lv_index9dbf.
            lv_indexhere =  lv_indexhere - 1.

            READ TABLE gt_t512 INTO gwa_t512 WITH KEY lgart = '/563'.
            IF sy-subrc = 0.
              itab_totaltemp-wage_desc = gwa_t512-lgtxt.
            ENDIF.

            itab_totaltemp-lgart = '/563'.
            CLEAR lv_total_wage.
            lv_total_wage = itab_total-total_wage.
            lv_total_wage9dbf = lv_total_wage + lv_total_wage9dbf.
          ENDIF.

          IF ( itab_total-lgart = '9DCF' ) .
            lv_index9dcf = lv_indexhere.
            DELETE itab_total INDEX lv_index9dcf.
            lv_indexhere =  lv_indexhere - 1.

            READ TABLE gt_t512 INTO gwa_t512 WITH KEY lgart = '/563'.
            IF sy-subrc = 0.
              itab_totaltemp-wage_desc = gwa_t512-lgtxt.
            ENDIF.

            itab_totaltemp-lgart = '/563'.

            CLEAR  lv_total_wage.

            lv_total_wage = itab_total-total_wage.
            lv_total_wage9dcf =  lv_total_wage + lv_total_wage9dcf.
          ENDIF.

        ENDLOOP.

        itab_totaltemp-total_wage = lv_total_wage9dbf - lv_total_wage9dcf.

        APPEND itab_totaltemp TO itab_total.
        itab_total = itab_totaltemp.
      ENDIF.
    ENDIF.
    " End ting ting added 01.09.2009 SIR 9233



    total_ded = total_ded + itab_wagetype_total-total_wage.

    IF d = 1.
*      WRITE:AT /10(5) text-021 ,"CR-0000000739 - Commented
*                15(15) itab_wagetype_total-wage_desc,
*                '  :  ',
*                (15) itab_wagetype_total-total_wage.
      d = d + 1.
    ELSE.
      IF x  >= 130.
*        NEW-LINE."CR-0000000739 - Commented
        x = 15.
      ENDIF.
*      WRITE: AT x(15) itab_wagetype_total-wage_desc,"CR-0000000739 - Commented
*                      '  :  ',
*                 (15) itab_wagetype_total-total_wage.
    ENDIF.
    x = x + 40.
*    ENDIF. " ting commented 03.06.2009
  ENDLOOP.

* Display employer cpf contribution
*  NEW-LINE."CR-0000000739 - Commented
  x = 10.

*{ Replace ncslts 29.11.2004 AW CPF Ceiling
*  LOOP AT itab_wagetype_total WHERE lgart = '/307'.
  LOOP AT itab_wagetype_total WHERE ( lgart = '/307' OR
                                      lgart = '/316' ).
*}

*    WRITE: AT x(15) itab_wagetype_total-wage_desc,"CR-0000000739 - Commented
*                    ':',
*              (15) itab_wagetype_total-total_wage.
    x = x + 40.
  ENDLOOP.
*{ Insert ncslts
*  IF x > 55.
*    NEW-LINE.
*    x = 55.
*  ENDIF.
*}

  IF x >= 130.
*    NEW-LINE."CR-0000000739 - Commented
    x = 10.
  ENDIF.

  " ting ting commented SIR CE00008296 25.06.2009
*      net_pay = total_pay - total_ded.
  DATA : lv_net_pay TYPE p DECIMALS 2.
  CLEAR lv_net_pay.
  LOOP AT itab_wagetype_total WHERE (       lgart = '/557'
                                      OR    lgart = '/558'
                                      OR    lgart = '/559' ).
    lv_net_pay = itab_wagetype_total-total_wage +  lv_net_pay.
  ENDLOOP.

  LOOP AT itab_wagetype_total WHERE lgart = '/561'.
    net_pay = lv_net_pay - itab_wagetype_total-total_wage.
    EXIT.
  ENDLOOP.
  IF sy-subrc <> 0.
    net_pay =  lv_net_pay.
  ENDIF.


* compute additional medical contribution
  typedesc = 0. " Total medical contribution
  " Ting Ting 24.06.2009 CE00008250
  LOOP AT itab_wagetype_total WHERE lgart = '/37I'.
    typedesc = itab_wagetype_total-total_wage + typedesc.
  ENDLOOP.

  IF typedesc IS INITIAL.
    LOOP AT itab_wagetype_total WHERE lgart = '/37A'
                                OR lgart = '/37B'.
      typedesc = itab_wagetype_total-total_wage + typedesc.
    ENDLOOP.
  ENDIF.



  " Ting Ting 24.06.2009 CE00008250
* Display t*  WRITE: AT x  'TOTAL MED CONTR:',
*          (15) typedesc,
*               'TOTAL PAYMENT: ',
*          (15) total_pay,
*               'DEDUCTIONS:  ',
*          (15) total_ded.
**               'NET PAYMENT:  ',
**          (15) net_pay.otal payment, total deduction, and net payment


*  typedesc = 0. " ting ting commented

*  WRITE: AT x  'TOTAL  MED CONTR:',
*          (15) typedesc,
*               'TOTAL PAYMENT: ',
*          (15) total_pay,
*               'DEDUCTIONS:  ',
*          (15) total_ded.

*  NEW-LINE.
*  x = 10.



  IF x >= 130.
*    NEW-LINE."CR-0000000739 - Commented
    x = 10.
  ENDIF.

  LOOP AT itab_wagetype_total WHERE lgart = '/376'.
*    WRITE: AT x(15) itab_wagetype_total-wage_desc, ':',"CR-0000000739 - Commented
*              (15) itab_wagetype_total-total_wage.
*    MOVE : itab_wagetype_total-lgart      TO gwa_final_tab-lgart,"CR-0000000739
    x = x + 40.
  ENDLOOP.

* /308 = FWL.
  IF x >= 130.
*    NEW-LINE."CR-0000000739 - Commented
    x = 10.
  ENDIF.

  LOOP AT itab_wagetype_total WHERE lgart = '/308'
                        AND NOT total_wage IS INITIAL.
*    WRITE: AT  x(15) itab_wagetype_total-wage_desc,':',"CR-0000000739 - Commented
*                (15) itab_wagetype_total-total_wage.
    x = x + 40.
  ENDLOOP.

* 9MSO = Unused MSO.
*  LOOP AT itab_wagetype_total WHERE lgart = '9MSO' " ting ting comment
  IF x >= 130.
*    NEW-LINE."CR-0000000739 - Commented
    x = 10.
  ENDIF.

  LOOP AT itab_wagetype_total WHERE lgart = '4MSO'
                        AND NOT total_wage IS INITIAL.
*    WRITE: AT x(15) itab_wagetype_total-wage_desc,':',"CR-0000000739 - Commented
*                (15) itab_wagetype_total-total_wage.
    x = x + 40.
  ENDLOOP.

  IF x >= 130.
*    NEW-LINE."CR-0000000739 - Commented
    x = 10.
  ENDIF.

*  WRITE: AT x(15) 'TOTAL  MED CONTR',':',"CR-0000000739 - Commented
*             (15) typedesc.
  x = x + 40.

*==>Start of addition, Bernard, SIR 9953
  LOOP AT itab_wagetype_total WHERE lgart = gc_wt_lsa_cpf_er
                        AND NOT total_wage IS INITIAL.

    IF x >= 130.
*      NEW-LINE."CR-0000000739 - Commented
      x = 10.
    ENDIF.

*    WRITE: AT x(15) itab_wagetype_total-wage_desc,':',"CR-0000000739 - Commented
*                (15) itab_wagetype_total-total_wage.
  ENDLOOP.
*<==End of addition, Bernard, SIR 9953

*  NEW-LINE."CR-0000000739 - Commented
  x = 10.


*  WRITE: AT x(15) 'TOTAL PAYMENT',':',"CR-0000000739 - Commented
*           (15) total_pay.
  x = x + 40.
  IF x >= 130.
*    NEW-LINE."CR-0000000739 - Commented
    x = 10.
  ENDIF.
*  WRITE: AT x(15) 'DEDUCTIONS',':',"CR-0000000739 - Commented
*           (15) total_ded.
  x = x + 40.
  IF x >= 130.
*    NEW-LINE."CR-0000000739 - Commented
    x = 10.
  ENDIF.

*  WRITE: AT x(15) 'NET PAYMENT', ':',"CR-0000000739 - Commented
*             (15) net_pay.
  x = x + 40.

* /376 = E'yer, SDF.
*  IF x >= 130.
*    NEW-LINE.
*    x = 10.
*  ENDIF.
*
*  LOOP AT itab_wagetype_total WHERE lgart = '/376'.
*    WRITE: AT x(15) itab_wagetype_total-wage_desc, ':',
*              (15) itab_wagetype_total-total_wage.
*
*    x = x + 40.
*  ENDLOOP.
*
** /308 = FWL.
*  IF x >= 130.
*    NEW-LINE.
*    x = 10.
*  ENDIF.
*
*  LOOP AT itab_wagetype_total WHERE lgart = '/308'
*                        AND NOT total_wage IS INITIAL.
*    WRITE: AT  x(15) itab_wagetype_total-wage_desc,':',
*                (15) itab_wagetype_total-total_wage.
*    x = x + 40.
*  ENDLOOP.
*
** 9MSO = Unused MSO.
**  LOOP AT itab_wagetype_total WHERE lgart = '9MSO' " ting ting comment
*  IF x >= 130.
*    NEW-LINE.
*    x = 10.
*  ENDIF.
*
*  LOOP AT itab_wagetype_total WHERE lgart = '4MSO'
*                        AND NOT total_wage IS INITIAL.
*    WRITE: AT x(15) itab_wagetype_total-wage_desc,':',
*                (15) itab_wagetype_total-total_wage.
*  ENDLOOP.

*  ULINE.
ENDFORM.                    "wagetype_final_total

*---------------------------------------------------------------------*
*       FORM output_payment_summary                                   *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM output_payment_summary.
  NEW-PAGE.

  SKIP.
  WRITE: /'Officers with negative SDF Contribution'.
  WRITE: /'----------------------------------------'.

  DATA: sum_neg_sdf LIKE itab_ee_neg_sdf-amount.
  CLEAR sum_neg_sdf.

  LOOP AT itab_ee_neg_sdf.
    WRITE:/ itab_ee_neg_sdf-pernr.
    WRITE: itab_ee_neg_sdf-nric.
    WRITE:(25) itab_ee_neg_sdf-ename.
    WRITE: itab_ee_neg_sdf-cost_center.
    WRITE: itab_ee_neg_sdf-amount.
    ADD itab_ee_neg_sdf-amount TO sum_neg_sdf.
  ENDLOOP.

  IF sy-subrc NE 0.
    WRITE:/ '[Nil]'.
  ELSE.
    SKIP.
    WRITE:/ num_neg_sdf RIGHT-JUSTIFIED.
    WRITE: 'officer(s) with negative SDF totalling:'.
    WRITE:  sum_neg_sdf.
  ENDIF.

  SKIP.
  WRITE: /'Officers with negative EE CPF Contribution'.
  WRITE: /'-------------------------------------------'.

  DATA: sum_neg_cpf LIKE itab_ee_neg_cpf-amount.
  CLEAR sum_neg_cpf.

  LOOP AT itab_ee_neg_cpf.
    WRITE:/ itab_ee_neg_cpf-pernr.
    WRITE: itab_ee_neg_cpf-nric.
    WRITE:(25) itab_ee_neg_cpf-ename.
    WRITE: itab_ee_neg_cpf-cost_center.
    WRITE: itab_ee_neg_cpf-amount.
    ADD itab_ee_neg_cpf-amount TO sum_neg_cpf.
  ENDLOOP.

  IF sy-subrc NE 0.
    WRITE:/ '[Nil]'.
  ELSE.
    SKIP.
    WRITE:/ num_neg_ee_cpf RIGHT-JUSTIFIED.
    WRITE: 'officer(s) with negative CPF totalling:'.
    WRITE:  sum_neg_cpf.
  ENDIF.

  SKIP.
  WRITE: /'Officers with balance of payment'.
  WRITE: /'--------------------------------'.

  DATA: sum_balance_pay LIKE itab_ee_balance_pay-amount.
  CLEAR sum_balance_pay.

  LOOP AT itab_ee_balance_pay.
    WRITE:/ itab_ee_balance_pay-pernr.
    WRITE: itab_ee_balance_pay-nric.
    WRITE:(25) itab_ee_balance_pay-ename.
    WRITE: itab_ee_balance_pay-cost_center.
    WRITE: itab_ee_balance_pay-amount.
    ADD itab_ee_balance_pay-amount TO sum_balance_pay.
  ENDLOOP.

  IF sy-subrc NE 0.
    WRITE:/ '[Nil]'.
  ELSE.
    SKIP.
    WRITE:/ num_ee_balance_pay RIGHT-JUSTIFIED.
    WRITE: 'officer(s) with balance of payment totalling:'.
    WRITE:  sum_balance_pay.
  ENDIF.


  SKIP.
  WRITE: /'Officers with Claim from Prev Month'.
  WRITE: /'-------------------------------------------'.

  DATA: sum_claim_prev LIKE itab_ee_claim_prev-amount.
  CLEAR sum_claim_prev.

  LOOP AT itab_ee_claim_prev.
    WRITE:/ itab_ee_claim_prev-pernr.
    WRITE: itab_ee_claim_prev-nric.
    WRITE:(25) itab_ee_claim_prev-ename.
    WRITE: itab_ee_claim_prev-cost_center.
    WRITE: itab_ee_claim_prev-amount.
    ADD itab_ee_claim_prev-amount TO sum_claim_prev.
  ENDLOOP.

  IF sy-subrc NE 0.
    WRITE:/ '[Nil]'.
  ELSE.
    SKIP.
    WRITE:/ num_claim_prev RIGHT-JUSTIFIED.
    WRITE: 'officer(s) with claim from prev month totalling:'.
    WRITE:  sum_claim_prev.
  ENDIF.


  IF compare = 'X'.
    LOOP AT itab_ee_paid_this_month.
      READ TABLE itab_output
      WITH KEY perno = itab_ee_paid_this_month-pernr.
      IF sy-subrc = 0.
        itab_ee_paid_this_month-ename = itab_output-ename.
        itab_ee_paid_this_month-cost_center = itab_output-bassal.
        itab_ee_paid_this_month-nric = itab_output-nric.
        MODIFY itab_ee_paid_this_month.
      ENDIF.
    ENDLOOP.


    LOOP AT itab_ee_paid_last_month.
* AUCT-UPGRADE -  Begin of Modification by <USER> on <17.02.2017> for <EHP8>
*      SELECT SINGLE ename kostl INTO
*        (itab_ee_paid_last_month-ename,
*         itab_ee_paid_last_month-cost_center) FROM pa0001
*         WHERE pernr = itab_ee_paid_last_month-pernr
*         AND begda <=  payroll_last_day
*         AND endda >=  payroll_last_day.
      SELECT ename kostl INTO
              (itab_ee_paid_last_month-ename,
               itab_ee_paid_last_month-cost_center) FROM pa0001
               WHERE pernr = itab_ee_paid_last_month-pernr
               AND begda <=  payroll_last_day
               AND endda >=  payroll_last_day
      ORDER BY PRIMARY KEY.
        EXIT.
      ENDSELECT.
* AUCT-UPGRADE -  End of Modification by <USER> on <17.02.2017> for <EHP8>

* AUCT-UPGRADE -  Begin of Modification by <USER> on <17.02.2017> for <EHP8>
*      SELECT SINGLE perid INTO
*        (itab_ee_paid_last_month-nric) FROM pa0002
*         WHERE pernr = itab_ee_paid_last_month-pernr
*         AND begda <=  payroll_last_day
*         AND endda >=  payroll_last_day.
      SELECT perid INTO
              (itab_ee_paid_last_month-nric) FROM pa0002
               WHERE pernr = itab_ee_paid_last_month-pernr
               AND begda <=  payroll_last_day
               AND endda >=  payroll_last_day
      ORDER BY PRIMARY KEY.
        EXIT.
      ENDSELECT.
* AUCT-UPGRADE -  End of Modification by <USER> on <17.02.2017> for <EHP8>

      MODIFY itab_ee_paid_last_month.
    ENDLOOP.

    SKIP.
    WRITE: /'Officers paid last month but not this month'.
    WRITE: /'-------------------------------------------'.

    LOOP AT itab_ee_paid_last_month.
      WRITE:/ itab_ee_paid_last_month-pernr.
      WRITE: itab_ee_paid_last_month-nric.
      WRITE:(25) itab_ee_paid_last_month-ename.
      WRITE: itab_ee_paid_last_month-cost_center.
      WRITE: itab_ee_paid_last_month-amount.
    ENDLOOP.
    IF sy-subrc NE 0.
      WRITE:/ '[Nil]'.
    ENDIF.

    SKIP.
    WRITE: /'Officers paid this month but not last month'.
    WRITE: /'-------------------------------------------'.

    LOOP AT itab_ee_paid_this_month.
      WRITE:/ itab_ee_paid_this_month-pernr.
      WRITE: itab_ee_paid_this_month-nric.
      WRITE:(25) itab_ee_paid_this_month-ename.
      WRITE: itab_ee_paid_this_month-cost_center.
      WRITE: itab_ee_paid_this_month-amount.
    ENDLOOP.
    IF sy-subrc NE 0.
      WRITE:/ '[Nil]'.
    ENDIF.
  ENDIF.

  SKIP.
  WRITE: /'Officers with status inactive'.
  WRITE: /'---------------------------------'.

  LOOP AT itab_ee_inactive.
    WRITE:/ itab_ee_inactive-pernr.
    WRITE: itab_ee_inactive-nric.
    WRITE:(25) itab_ee_inactive-ename.
*    WRITE: itab_ee_inactive-cost_center.
*    WRITE: itab_ee_inactive-amount.
  ENDLOOP.
  IF sy-subrc NE 0.
    WRITE:/ '[Nil]'.
  ENDIF.

  SKIP.
  WRITE: /'Officers with cash/cheque payment'.
  WRITE: /'---------------------------------'.

  LOOP AT itab_ee_cash_payment.
    WRITE:/ itab_ee_cash_payment-pernr.
    WRITE: itab_ee_cash_payment-nric.
    WRITE:(25) itab_ee_cash_payment-ename.
    WRITE: itab_ee_cash_payment-cost_center.
    WRITE: itab_ee_cash_payment-amount.
  ENDLOOP.
  IF sy-subrc NE 0.
    WRITE:/ '[Nil]'.
  ENDIF.

  SKIP.
  WRITE: /'Officers with negative payment'.
  WRITE: /'---------------------------------'.
  LOOP AT itab_ee_neg_payment.
    WRITE:/ itab_ee_neg_payment-pernr.
    WRITE: itab_ee_neg_payment-nric.
    WRITE:(25) itab_ee_neg_payment-ename.
    WRITE: itab_ee_neg_payment-cost_center.
    WRITE: itab_ee_neg_payment-amount.
  ENDLOOP.
  IF sy-subrc NE 0.
    WRITE:/ '[Nil]'.
  ENDIF.
*<-- Start modification SR-PA-000?0011353 DE0K9A0XQP A_JACKY 22.06.2011 Zero Amount Officers’ summary added into report output-->
  SKIP.
  WRITE: /'Officers with Zero Payment'.
  WRITE: /'--------------------------'.
  LOOP AT itab_zero_payment INTO gwa_zero_payment.
    WRITE:/ gwa_zero_payment-pernr.
    WRITE: gwa_zero_payment-nric.
    WRITE:(25) gwa_zero_payment-ename.
    WRITE: gwa_zero_payment-cost_center.
  ENDLOOP.
  IF sy-subrc NE 0.
    WRITE:/ '[Nil]'.
  ENDIF.
*<-- End modification SR-PA-000?0011353 DE0K9A0XQP A_JACKY 22.06.2011 Zero Amount Officers’ summary added into report output-->
*{ Insert ncslts AW CPF Ceiling 29.11.2004
  SKIP.
  WRITE: /'Officers Shortfall on Employee''s Portion'.
  WRITE: /'----------------------------------------'.
  LOOP AT itab_ee_short.
    WRITE:/ itab_ee_short-pernr.
    WRITE: itab_ee_short-nric.
    WRITE:(25) itab_ee_short-ename.
    WRITE: itab_ee_short-cost_center.
    WRITE: itab_ee_short-amount.
  ENDLOOP.
  IF sy-subrc NE 0.
    WRITE:/ '[Nil]'.
  ENDIF.
  SKIP.
  WRITE: /'Officers Shortfall on Employer''s Portion'.
  WRITE: /'----------------------------------------'.
  LOOP AT itab_er_short.
    WRITE:/ itab_er_short-pernr.
    WRITE: itab_er_short-nric.
    WRITE:(25) itab_er_short-ename.
    WRITE: itab_er_short-cost_center.
    WRITE: itab_er_short-amount.
  ENDLOOP.
  IF sy-subrc NE 0.
    WRITE:/ '[Nil]'.
  ENDIF.
*}
  SKIP.
  WRITE: /'Payment Summary (Current Month)'.
  WRITE: /'-------------------------------'.
  WRITE: /'Total Bank Transfer      :'.
  WRITE: 30 num_bank_transfer RIGHT-JUSTIFIED.
  WRITE: 38 total_bank_transfer.

  WRITE: /'Total Cash/Cheque Payment:'.
  WRITE: 30 num_cash_payment RIGHT-JUSTIFIED.
  WRITE: 38 total_cash_payment.

  WRITE: /'Total Negative Payment   :'.
  WRITE: 30 num_negative_payment RIGHT-JUSTIFIED.
  WRITE: 36 '(',total_negative_payment,')'.

  WRITE: /'Total Zero Payment       :'.
  WRITE: 30 num_zero_payment RIGHT-JUSTIFIED.

  WRITE: /30 '--------------------------------- '.
  WRITE: /'Total Net Payment        :'.
  WRITE: 30 num_net_payment RIGHT-JUSTIFIED.
  WRITE: 38 total_net_payment.
  WRITE: /30 '--------------------------------- '.
ENDFORM.                    "output_payment_summary


*---------------------------------------------------------------------*
*       FORM call_basic_display                                       *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM call_basic_display.

  REFRESH fieldnames.
  CLEAR fieldnames.

* 01
  fieldnames-title  =  'Per Num'.
  APPEND fieldnames.
  CLEAR  fieldnames.
* 02
  fieldnames-title  =  'Nric'.
  APPEND fieldnames.
  CLEAR  fieldnames.
* 03
  fieldnames-title  =  'Name'.
  APPEND fieldnames.
  CLEAR  fieldnames.
* 04
  fieldnames-title  =  'Cost Center'.
  APPEND fieldnames.
  CLEAR  fieldnames.
* 05
  fieldnames-title  =  'Org Unit'.
  APPEND fieldnames.
  CLEAR  fieldnames.
* 06
  fieldnames-title  =  'Wage Type'.
  APPEND fieldnames.
  CLEAR  fieldnames.
* 07
  fieldnames-title  =  'Wage Type Desc'.
  APPEND fieldnames.
  CLEAR  fieldnames.
* 08
  fieldnames-title  =  'Wage Amt'.
  APPEND fieldnames.
  CLEAR  fieldnames.

  DATA: line1(130), line2(130), line3(130).

  CONCATENATE 'Payroll Period' period_from 'to' period_to
    INTO line1 SEPARATED BY space.

  DATA: date_temp(10).

  WRITE sy-datum DD/MM/YYYY TO date_temp.

  CONCATENATE 'Run date' date_temp
    INTO line2 SEPARATED BY space.

  CALL FUNCTION 'HR_DISPLAY_BASIC_LIST'
    EXPORTING
      basic_list_title    = sy-title
      file_name           = sy-repid
      head_line1          = line1
      head_line2          = line2
      head_line3          = line3
    TABLES
      data_tab            = data_tab
      fieldname_tab       = fieldnames
    EXCEPTIONS
      download_problem    = 1
      no_data_tab_entries = 2
      table_mismatch      = 3
      print_problems      = 4
      OTHERS              = 5.

ENDFORM.                    "call_basic_display


*---------------------------------------------------------------------*
*       FORM get_claim_prev_wage_amt                                  *
*---------------------------------------------------------------------*
* This subroutine calculates the difference between actual bank
* transfer/cash/claims and the calculated net_payment. The difference
* is appended to itab_total as /563 Claim from prev month.
*---------------------------------------------------------------------*
FORM get_claim_prev_wage_amt.

*  DATA temp_pernr LIKE itab_total-pernr OCCURS 0 WITH HEADER LINE.
*
*  SORT itab_total BY pernr.
*  LOOP AT itab_total.
*    AT NEW pernr.
*      temp_pernr = itab_total-pernr.
*      APPEND temp_pernr.
*    ENDAT.
*  ENDLOOP.
*
*  DATA temp_payment LIKE itab_total-total_wage.
*  DATA temp_deduction LIKE itab_total-total_wage.
*  DATA temp_net_payment LIKE itab_total-total_wage.
*  DATA temp_cash_bank LIKE itab_total-total_wage.
*
*  LOOP AT temp_pernr.
*
*    CLEAR temp_payment.
*    CLEAR temp_deduction.
*    CLEAR temp_net_payment.
*    CLEAR temp_cash_bank.

*    LOOP AT itab_total WHERE pernr = temp_pernr.

*      IF ( itab_total-lgart+0(2) = '9S'
*      AND itab_total-lgart+0(2) NE '9%' )
*      OR itab_total-lgart+0(2) = '9A'
*      OR itab_total-lgart+0(2) = '9B'
*      OR itab_total-lgart+0(2) = '9C'
*      OR itab_total-lgart+0(2) = '9O'
**      OR itab_total-lgart+0(2) = '9M'
*      OR ( itab_total-lgart+0(2) = '9W'
**      AND itab_total-lgart NE '9W02' " ting ting comment
*        AND itab_total-lgart NE '3W02'
*        AND itab_total-lgart NE '3LS2'
*        AND itab_total-lgart NE '3LS2'
*        AND itab_total-lgart NE '3023')
**( HRPS/05/040 TCTC Wage type
**      OR itab_total-lgart = '9Z91'." ting ting commented
*         OR itab_total-lgart = '1Z01'
*        OR itab_total-lgart = '1Z91'
*        OR ( itab_total-lgart NE ' '
**                         AND lgart+0(2) = '9S'
*                         AND NOT total_wage IS INITIAL
*                         AND itab_total-lgart NOT IN itab_wagedec[]
*        " ting ting added start
*                        AND itab_total-lgart <> '/376'
*                        AND itab_total-lgart <> '/308'
*                        AND itab_total-lgart <> '4MSO'
*                        AND itab_total-lgart <> '/307'
*                        AND itab_total-lgart <> '/305'
*                        AND itab_total-lgart <> '/314'
*                        AND itab_total-lgart <>'/370'
*                        AND itab_total-lgart <> '/371'
*                        AND itab_total-lgart <> '/372'
*                        AND itab_total-lgart <> '/373'
*                        AND itab_total-lgart <> '/374'
*                        AND itab_total-lgart <>'/563'
*                        AND itab_total-lgart <> '/565'
*                        AND itab_total-lgart <>'/566'
*                        AND itab_total-lgart <> '/375'
*                        AND itab_total-lgart <> '/305'  "E'yee,CPF-curr.contr./sum
*                        AND itab_total-lgart <> '/370' "E'yee, CDAC, add.fund
*                        AND itab_total-lgart <>  '/371' "E'yee, SINDA,add.fund
*                        AND itab_total-lgart <>  '/372' "E'yee, MBMF, add.fund
*                        AND itab_total-lgart <> '/373' "E'yee, ECF   add.fund
*                        AND itab_total-lgart <> '/374' "E'yee, COMCS add.fund
*                        AND itab_total-lgart <> '/375' "E'yee, Other fund
*                        AND itab_total-lgart <>  '/565' "Carry-over for subs.month
*                        AND itab_total-lgart <>  '/566' "Carry-over for prev.month
*                        AND itab_total-lgart <> '/314'  "E'YEE, Shortfall on AW
*                        AND itab_total-lgart <>'/450'
*                        AND itab_total-lgart <> '/303'
*                        AND itab_total-lgart IN gt_allowance[] ) .
**)
*        ADD itab_total-total_wage TO temp_payment.
*      ENDIF.
*
*      IF itab_total-lgart+0(2) = '9D'
**      OR itab_total-lgart = '/305' "E'yee,CPF-curr.contr./sum
**      OR itab_total-lgart = '/370' "E'yee, CDAC, add.fund
**      OR itab_total-lgart = '/371' "E'yee, SINDA,add.fund
**      OR itab_total-lgart = '/372' "E'yee, MBMF, add.fund
**      OR itab_total-lgart = '/373' "E'yee, ECF   add.fund
**      OR itab_total-lgart = '/374' "E'yee, COMCS add.fund
**      OR itab_total-lgart = '/375' "E'yee, Other fund
**      OR itab_total-lgart = '/565' "Carry-over for subs.month
**      OR itab_total-lgart = '/566' "Carry-over for prev.month
***{ Ammend above and insert below. ncslts 29.11.2004 AW CPF Ceiling
**
**   OR itab_total-lgart = '/314' OR "E'YEE, Shortfall on AW
**            itab_total-lgart = '/450' OR
**             itab_total-lgart = '/303'
**
**             tab_wagetype_total-lgart = '/314'  OR
***}
**                                      OR itab_total-lgart = '/370'  OR
**                                      itab_total-lgart = '/371'  OR
**                                      itab_total-lgart = '/372'  OR
**                                      itab_total-lgart = '/373'  OR
**                                      itab_total-lgart = '/374'  OR
**                                      itab_total-lgart = '/563'  OR
**                                      itab_total-lgart = '/565'  OR
**                                      itab_total-lgart = '/566'  OR
**                                      itab_total-lgart = '/375' OR
**                                      itab_total-lgart =  '/305' OR "E'yee,CPF-curr.contr./sum
**                                      itab_total-lgart =  '/370'OR "E'yee, CDAC, add.fund
**                                      itab_total-lgart =  '/371'OR "E'yee, SINDA,add.fund
**                                      itab_total-lgart =  '/372'OR "E'yee, MBMF, add.fund
**                                      itab_total-lgart = '/373'OR "E'yee, ECF   add.fund
**                                      itab_total-lgart = '/374'OR "E'yee, COMCS add.fund
**                                      itab_total-lgart = '/375'OR "E'yee, Other fund
**                                      itab_total-lgart =  '/565' OR"Carry-over for subs.month
**                                      itab_total-lgart =  '/566'OR "Carry-over for prev.month
**                                      itab_total-lgart = '/314' OR "E'YEE, Shortfall on AW
***                                      itab_total-lgart = '/450' OR
**                                      itab_total-lgart = '/303' OR
**                                      itab_total-lgart = '/307' OR
**        lgart IN itab_wagedec[].
*
*        OR
*                                itab_total-lgart = '/305'  OR
**{ Insert ncslts 29.11.2004 AW CPF Ceiling
*                                itab_total-lgart = '/314'  OR
**}
*                                itab_total-lgart = '/370'  OR
*                                itab_total-lgart = '/371'  OR
*                                itab_total-lgart = '/372'  OR
*                                itab_total-lgart = '/373'  OR
*                                itab_total-lgart = '/374'  OR
*                                itab_total-lgart = '/563'  OR
*                                itab_total-lgart = '/565'  OR
*                                itab_total-lgart = '/566'  OR
*                                itab_total-lgart = '/375'  OR
*                                itab_total-lgart =  '/305' OR "E'yee,CPF-curr.contr./sum
*                                itab_total-lgart =  '/370'OR "E'yee, CDAC, add.fund
*                                itab_total-lgart =  '/371'OR "E'yee, SINDA,add.fund
*                                itab_total-lgart =  '/372'OR "E'yee, MBMF, add.fund
*                                itab_total-lgart = '/373'OR "E'yee, ECF   add.fund
*                                itab_total-lgart = '/374'OR "E'yee, COMCS add.fund
*                                itab_total-lgart = '/375'OR "E'yee, Other fund
*                                itab_total-lgart =  '/565' OR"Carry-over for subs.month
*                                itab_total-lgart =  '/566'OR "Carry-over for prev.month
*                                itab_total-lgart = '/314' OR "E'YEE, Shortfall on AW
**                                lgart = '/450' OR " ting ting commented CE00007471
*                                itab_total-lgart = '/303' OR
**                                lgart = '/307'" ting ting commented CE00007279
*        itab_total-lgart IN itab_wagedec[].
*      ELSE.
*        itab_total-total_wage = itab_total-total_wage * -1.
*      ENDIF.
*
*      ADD itab_total-total_wage TO temp_deduction.
*
*
** get bank transfer amount or balance bank transfer or cash
** payment or claims.
*      IF itab_total-lgart = '/559'
*      OR itab_total-lgart = '/558'
*      OR itab_total-lgart = '/557'
*      OR itab_total-lgart = '/561'.
*
*
*        " ting ting commented 10.06.2009
**        IF itab_total-lgart = '/561'.
**          itab_total-total_wage = itab_total-total_wage * -1.
**        ENDIF.
*
**        ADD itab_total-total_wage TO temp_cash_bank.
*      ENDIF.

*    ENDLOOP.

*    temp_net_payment = temp_payment - temp_deduction.

* if there is bank transfer or cash payment this month,
* but the amount is not equal to the computed net payment
* then the difference = claim from prev mth.
*    IF temp_cash_bank NE temp_net_payment.
*      CLEAR itab_total.
*      itab_total-pernr = temp_pernr.
*      itab_total-lgart = '/563'.
*      itab_total-total_wage = temp_net_payment - temp_cash_bank.
*      APPEND itab_total.
*    ENDIF.

*  ENDLOOP.

ENDFORM.                    "get_claim_prev_wage_amt
*&---------------------------------------------------------------------*
*&      Form  GET_FEATURE_PPMOD
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM get_feature_ppmod .
  FIELD-SYMBOLS : <fs_ee_group> TYPE ty_ee_group.

  DATA : lwa_pc205  TYPE pc205,
         lv_feature TYPE t52emt-momag.

  LOOP AT it_ee_group ASSIGNING <fs_ee_group>.
    CLEAR : lwa_pc205,lv_feature.
    MOVE <fs_ee_group>-abart TO lwa_pc205-abart.

    CALL FUNCTION 'HR_FEATURE_BACKFIELD'
      EXPORTING
        feature                     = 'PPMOD'
        struc_content               = lwa_pc205
      IMPORTING
        back                        = lv_feature
      EXCEPTIONS
        dummy                       = 1
        error_operation             = 2
        no_backvalue                = 3
        feature_not_generated       = 4
        invalid_sign_in_funid       = 5
        field_in_report_tab_in_pe03 = 6
        OTHERS                      = 7.
    IF sy-subrc EQ 0.
      <fs_ee_group>-momag = lv_feature.
    ENDIF.
  ENDLOOP.
ENDFORM.                    " GET_FEATURE_PPMOD
*&---------------------------------------------------------------------*
*&      Form  GET_WT_GL_ACC
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM get_wt_gl_acc .



  DATA: BEGIN OF it_data OCCURS 0,
          data(1000) TYPE c,
        END OF it_data.
  DATA : it_list       TYPE TABLE OF abaplist,
         lwa_wt_gl_acc TYPE ty_wt_gl_acc,
         lt_lgart      TYPE STANDARD TABLE OF selopt,
         lwa_lgart     TYPE selopt,
         lwa_py_cfg    TYPE zhrpy_py_cfg.

*Read config table for list of WTs
  SELECT * FROM zhrpy_py_cfg INTO TABLE it_py_cfg.

*Populate WTs from config table and get GL ac from standard prog-PRDKON00
  LOOP AT it_py_cfg INTO lwa_py_cfg.
    MOVE : 'I'  TO lwa_lgart-sign,
           'EQ' TO lwa_lgart-option,
           lwa_py_cfg-lgart TO lwa_lgart-low.
    APPEND lwa_lgart TO lt_lgart.
    CLEAR lwa_lgart.
  ENDLOOP.
*Call the standard report to get GL ac for WTs,send to list memory and read from list memory to local internal tables
  SUBMIT rpdkon00 WITH p_molga  EQ gc_25
                  WITH p_lgart  IN lt_lgart
                  WITH p_date   EQ pn-begda "sy-datum
                  WITH p_spprci EQ 'X'
                  WITH p_spprca EQ 'X'
                  WITH list     EQ 'X' EXPORTING LIST TO MEMORY AND RETURN.
  CALL FUNCTION 'LIST_FROM_MEMORY' "import from list memory
    TABLES
      listobject = it_list
    EXCEPTIONS
      not_found  = 1
      OTHERS     = 2.
  IF sy-subrc <> 0.
    EXIT.
  ENDIF.
  CALL FUNCTION 'LIST_TO_ASCI' "convert ASCI to CHAR format
    EXPORTING
      list_index         = -1
    TABLES
      listasci           = it_data
      listobject         = it_list
    EXCEPTIONS
      empty_list         = 1
      list_index_invalid = 2
      OTHERS             = 3.
  CALL FUNCTION 'LIST_FREE_MEMORY'
    TABLES
      listobject = it_list
    EXCEPTIONS
      OTHERS     = 1.
  DELETE it_data WHERE data+1(2) NE gc_25.
  LOOP AT it_data.
    lwa_wt_gl_acc-lgart = it_data-data+33(4).
    lwa_wt_gl_acc-lgtxt = it_data-data+38(25).
    lwa_wt_gl_acc-symko = it_data-data+77(5).
    lwa_wt_gl_acc-momag = it_data-data+120(4).
    lwa_wt_gl_acc-acct = it_data-data+172(10).
    APPEND lwa_wt_gl_acc TO it_wt_gl_acc.
    CLEAR lwa_wt_gl_acc.
  ENDLOOP.
ENDFORM.                    " GET_WT_GL_ACC
*&---------------------------------------------------------------------*
*&      Form  WRITE_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_GWA_FINAL_TAB  text
*----------------------------------------------------------------------*
FORM write_data  USING p_final_tab TYPE ty_final_tab.
  WRITE :/ sy-vline,
          12 p_final_tab-lgtxt,
          55 p_final_tab-lgart,
          65 p_final_tab-acct,
          74 sy-vline,
          75 p_final_tab-total_wage_pa,
          93 p_final_tab-total_wage_tr,
         110 p_final_tab-total_wage_cow,
         130 p_final_tab-total_wage,
         148 sy-vline,
         150 sy-vline,
         151 p_final_tab-total_wage_pa1,
         169 p_final_tab-total_wage_tr1,
         186 p_final_tab-total_wage_cow1,
         206 p_final_tab-total_wage1,
         224 sy-vline.

ENDFORM.                    " WRITE_DATA
*&---------------------------------------------------------------------*
*&      Form  FILL_WT_AMOUNT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      <--P_GWA_FINAL_TAB  text
*----------------------------------------------------------------------*
FORM fill_wt_amount  USING p_total_wage
                  CHANGING p_final_tab TYPE ty_final_tab1.
  DATA : lwa_ee_grp    TYPE ty_ee_group,
         lwa_wt_gl_acc TYPE ty_wt_gl_acc.

  CLEAR lwa_ee_grp.
  READ TABLE it_ee_group INTO lwa_ee_grp WITH KEY  pernr = p_final_tab-pernr BINARY SEARCH.
  IF sy-subrc EQ 0.
    CASE lwa_ee_grp-persg.
      WHEN gc_ee_grp_p."Trainer-TR
        MOVE p_total_wage TO p_final_tab-total_wage_tr.
      WHEN gc_ee_grp_q."Clerk of Works-COW
        MOVE p_total_wage TO p_final_tab-total_wage_cow.
      WHEN OTHERS."PA
        MOVE p_total_wage TO p_final_tab-total_wage_pa.
    ENDCASE.
    p_final_tab-persg = lwa_ee_grp-persg."Emp group
    READ TABLE it_wt_gl_acc INTO lwa_wt_gl_acc WITH KEY lgart = p_final_tab-lgart
                                                        momag = lwa_ee_grp-momag.
    IF sy-subrc EQ 0.
      p_final_tab-acct = lwa_wt_gl_acc-acct."GL ac
      p_final_tab-lgtxt = lwa_wt_gl_acc-lgtxt."WT text
    ELSE.
      CLEAR lwa_wt_gl_acc.
      READ TABLE it_wt_gl_acc INTO lwa_wt_gl_acc WITH KEY lgart = p_final_tab-lgart
                                                          momag = ''.
      IF sy-subrc EQ 0.
        p_final_tab-acct  = lwa_wt_gl_acc-acct."GL ac
        p_final_tab-lgtxt = lwa_wt_gl_acc-lgtxt."WT text
      ENDIF.
    ENDIF.
  ENDIF.
ENDFORM.                    " FILL_WT_AMOUNT
*&---------------------------------------------------------------------*
*&      Form  FINAL_COUNT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      <--P_LWA_FINAL_COUNT  text
*----------------------------------------------------------------------*
FORM final_count  CHANGING p_final_count TYPE ty_final_count.

  LOOP AT emp_details.
    READ TABLE itab_final_total WITH KEY pernr = emp_details-perno lgart = '/559'."BankTransfer.
    IF sy-subrc EQ 0.
      CASE emp_details-zzpa_per_grp.
        WHEN gc_ee_grp_p."Trainer-TR
          p_final_count-pymnt_ibg_tr = p_final_count-pymnt_ibg_tr + 1.
        WHEN gc_ee_grp_q."Clerk of Works-COW
          p_final_count-pymnt_ibg_cow = p_final_count-pymnt_ibg_cow + 1.
        WHEN OTHERS."PA
          p_final_count-pymnt_ibg_pa = p_final_count-pymnt_ibg_pa + 1.
      ENDCASE.
      p_final_count-tot_ibg = p_final_count-tot_ibg + 1.
    ELSE.
      READ TABLE itab_final_total WITH KEY pernr = emp_details-perno lgart = '/557'."Cash
      IF sy-subrc EQ 0.
        CASE emp_details-zzpa_per_grp.
          WHEN gc_ee_grp_p."Trainer-TR
            p_final_count-pymnt_chq_tr = p_final_count-pymnt_chq_tr + 1.
          WHEN gc_ee_grp_q."Clerk of Works-COW
            p_final_count-pymnt_chq_cow = p_final_count-pymnt_chq_cow + 1.
          WHEN OTHERS."PA
            p_final_count-pymnt_chq_pa = p_final_count-pymnt_chq_pa + 1.
        ENDCASE.
        p_final_count-tot_chq = p_final_count-tot_chq + 1.
      ENDIF.
    ENDIF.
    READ TABLE itab_final_total1 WITH KEY pernr = emp_details-perno lgart = '/559'."BankTransfer.
    IF sy-subrc EQ 0.
      CASE emp_details-zzpa_per_grp.
        WHEN gc_ee_grp_p."Trainer-TR
          p_final_count-pymnt_ibg_tr1 = p_final_count-pymnt_ibg_tr1 + 1.
        WHEN gc_ee_grp_q."Clerk of Works-COW
          p_final_count-pymnt_ibg_cow1 = p_final_count-pymnt_ibg_cow1 + 1.
        WHEN OTHERS."PA
          p_final_count-pymnt_ibg_pa1 = p_final_count-pymnt_ibg_pa1 + 1.
      ENDCASE.
      p_final_count-tot_ibg1 = p_final_count-tot_ibg1 + 1.
    ELSE.
      READ TABLE itab_final_total1 WITH KEY pernr = emp_details-perno lgart = '/557'."Cash
      IF sy-subrc EQ 0.
        CASE emp_details-zzpa_per_grp.
          WHEN gc_ee_grp_p."Trainer-TR
            p_final_count-pymnt_chq_tr1 = p_final_count-pymnt_chq_tr1 + 1.
          WHEN gc_ee_grp_q."Clerk of Works-COW
            p_final_count-pymnt_chq_cow1 = p_final_count-pymnt_chq_cow1 + 1.
          WHEN OTHERS."PA
            p_final_count-pymnt_chq_pa1 = p_final_count-pymnt_chq_pa1 + 1.
        ENDCASE.
        p_final_count-tot_chq1 = p_final_count-tot_chq1 + 1.
      ENDIF.
    ENDIF.
  ENDLOOP.
  p_final_count-tot_pa   = p_final_count-pymnt_ibg_pa   + p_final_count-pymnt_chq_pa.
  p_final_count-tot_pa1  = p_final_count-pymnt_ibg_pa1  + p_final_count-pymnt_chq_pa1.

  p_final_count-tot_count  = p_final_count-tot_ibg  + p_final_count-tot_chq.
  p_final_count-tot_count1 = p_final_count-tot_ibg1 + p_final_count-tot_chq1.

ENDFORM.                    " FINAL_COUNT
*&---------------------------------------------------------------------*
*&      Form  AGENCY_SUB_CHECK
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM agency_sub_check .
  DATA: lv_zprogramm TYPE zprogramm,
        lv_sub       TYPE zsubscribe,
        lv_agency    TYPE zagency1,
        lv_date      TYPE sdate.

  MOVE sy-repid      TO lv_zprogramm.
  MOVE sy-mandt+1(2) TO lv_agency.
  MOVE sy-datum      TO lv_date.

  CALL FUNCTION 'ZACE_AGENCY_SUBSCRIPTION'
    EXPORTING
      program                      = lv_zprogramm
      tcode                        = sy-tcode
      currentdate                  = lv_date
      agency                       = lv_agency
    IMPORTING
      subscribe_indica             = lv_sub
    EXCEPTIONS
      no_agency_subscription_found = 1
      missing_agency_code          = 2
      missing_tcode                = 3
      OTHERS                       = 4.
  IF sy-subrc NE 0.
    MESSAGE e002(zhrpy).
    EXIT.
  ENDIF.

ENDFORM.                    " AGENCY_SUB_CHECK
*&---------------------------------------------------------------------*
*&      Form  WRITE_OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM write_output .
  DATA : lwa_ee_group       TYPE ty_ee_group, "CR-0000000739
         lwa_wt_gl_acc      TYPE ty_wt_gl_acc,
         lwa_py_cfg         TYPE zhrpy_py_cfg, "Paysheet Config table
         lwa_final_tab      TYPE ty_final_tab,
         lwa_final_tab1     TYPE ty_final_tab,
         lwa_final_tab2     TYPE ty_final_tab,
         lwa_final_sub_tot  TYPE ty_final_sub_tot,
         lwa_final_sub_tot1 TYPE ty_final_sub_tot,
         lwa_final_sub_tot2 TYPE ty_final_sub_tot,
         lwa_final_sub_tot3 TYPE ty_final_sub_tot,
         lwa_final_sub_tot4 TYPE ty_final_sub_tot,
         lwa_final_sub_tot5 TYPE ty_final_sub_tot,
         lwa_final_sub_tot6 TYPE ty_final_sub_tot,
         lwa_final_sub_tot7 TYPE ty_final_sub_tot,
         lwa_final_count    TYPE ty_final_count,
         lwa_month_i        TYPE t247,
         lwa_month_f        TYPE t247,
         lv_month           TYPE month,
         lv_temp            TYPE c,
         lv_sec_temp(2)     TYPE c,
         lv_lgart           TYPE lgart,
         lv_title           TYPE string.

  PERFORM final_count CHANGING lwa_final_count.

  MOVE fp_per+4(2) TO lv_month.
  CALL FUNCTION 'IDWT_READ_MONTH_TEXT'
    EXPORTING
      langu = sy-langu
      month = lv_month
    IMPORTING
      t247  = lwa_month_f.
  MOVE in_per+4(2) TO lv_month.
  CALL FUNCTION 'IDWT_READ_MONTH_TEXT'
    EXPORTING
      langu = sy-langu
      month = lv_month
    IMPORTING
      t247  = lwa_month_i.

  TRANSLATE : lwa_month_f-ltx TO UPPER CASE,
              lwa_month_i-ltx TO UPPER CASE.

  CLEAR : gwa_final_tab,lv_title.
  CONCATENATE TEXT-053 lwa_month_f-ltx 'AND' lwa_month_i-ltx in_per+0(4) TEXT-054 INTO lv_title SEPARATED BY space.
*  WRITE : /5 text-053,lwa_month_f-ltx,'AND',lwa_month_i-ltx,in_per+0(4),text-054.
  WRITE : /5 lv_title.
  FORMAT COLOR COL_GROUP .
  WRITE / sy-uline(224).
  WRITE : / sy-vline,74 sy-vline,105 lwa_month_i-ltx, in_per+0(4),148 sy-vline,150 sy-vline,180 lwa_month_f-ltx, fp_per+0(4),224 sy-vline.
  WRITE : / sy-vline,74 sy-vline,107 'GL: 143100',148 sy-vline,150 sy-vline,175 'GL: 143100',224 sy-vline.
  WRITE : / sy-vline,74 sy-vline,75 TEXT-052,148 sy-vline,150 sy-vline,151 TEXT-052,224 sy-vline.
  WRITE : / sy-vline,10 'WAGE '      ,54 'WAGE' ,66 'GL'      ,74 sy-vline,98 'TRAINER', 114 'CLERK-OF-WORKS', 135 '   TOTAL' ,148 sy-vline,
        150 sy-vline,177 'TRAINER',194 'CLERK-OF-WORKS',215 'TOTAL',224 sy-vline.
  WRITE : / sy-vline,10 'DESCRIPTION',54 'CODE' ,64 'ACCOUNT' ,74 sy-vline, 85 'PA' ,99 ' (TR)   ',115 '   (COW)'     , 133 '(Incl TR&COW)',148 sy-vline,
        150 sy-vline,161 'PA',179 '(TR)',196 '(COW)',211 '(Incl TR&COW)',224 sy-vline.
  WRITE : / sy-vline,74 sy-vline,86 '$',101 '$',120 '$',139 '$',148 sy-vline,150 sy-vline,162 '$',180 '$',198 '$',217 '$',224 sy-vline.
  WRITE / sy-uline(224).
  FORMAT COLOR OFF.

  LOOP AT it_sec_details INTO lwa_sec_details.
    lv_temp = 'X'.

    AT NEW main.
      FORMAT INTENSIFIED ON.
      CASE lwa_sec_details-main.
        WHEN 'A'.
          WRITE :/ sy-vline,5 'A',10 'EXPENDITURE OF MAMPOWER (EOM)',74 sy-vline,148 sy-vline,150 sy-vline,224 sy-vline.
        WHEN 'B'.
          WRITE :/ sy-vline,5 'B',10 'EXTERNAL ALLOWANCES (Deposit Account)',74 sy-vline,148 sy-vline,150 sy-vline,224 sy-vline.
        WHEN 'C'.
          WRITE :/ sy-vline,5 'C',10 'OTHER OPERATING EXPENDITURE (OOE)',74 sy-vline,148 sy-vline,150 sy-vline,224 sy-vline.
        WHEN 'D'.
          WRITE :/ sy-vline,5 'D',10 'SALARY RECOVERABLE',74 sy-vline,148 sy-vline,150 sy-vline,224 sy-vline.
        WHEN 'E'.
          WRITE :/ sy-vline,5 'E',10 'DEDUCTIONS',74 sy-vline,148 sy-vline,150 sy-vline,224 sy-vline.
        WHEN 'F'.
          NEW-LINE.
          CLEAR lwa_final_sub_tot2.
          LOOP AT it_final_sub_tot INTO lwa_final_sub_tot.
            IF lwa_final_sub_tot-sub_total = 'A4_TOTAL' OR
               lwa_final_sub_tot-sub_total = 'B1' OR
               lwa_final_sub_tot-sub_total = 'C_TOTAL' OR
               lwa_final_sub_tot-sub_total = 'D1'.
              lwa_final_sub_tot2-total_wage_pa  = lwa_final_sub_tot2-total_wage_pa  + lwa_final_sub_tot-total_wage_pa.
              lwa_final_sub_tot2-total_wage_tr  = lwa_final_sub_tot2-total_wage_tr  + lwa_final_sub_tot-total_wage_tr.
              lwa_final_sub_tot2-total_wage_cow = lwa_final_sub_tot2-total_wage_cow + lwa_final_sub_tot-total_wage_cow.
              lwa_final_sub_tot2-total_wage     = lwa_final_sub_tot2-total_wage     + lwa_final_sub_tot-total_wage.

              lwa_final_sub_tot2-total_wage_pa1  = lwa_final_sub_tot2-total_wage_pa1  + lwa_final_sub_tot-total_wage_pa1.
              lwa_final_sub_tot2-total_wage_tr1  = lwa_final_sub_tot2-total_wage_tr1  + lwa_final_sub_tot-total_wage_tr1.
              lwa_final_sub_tot2-total_wage_cow1 = lwa_final_sub_tot2-total_wage_cow1 + lwa_final_sub_tot-total_wage_cow1.
              lwa_final_sub_tot2-total_wage1     = lwa_final_sub_tot2-total_wage1     + lwa_final_sub_tot-total_wage1.

            ELSEIF lwa_final_sub_tot-sub_total = 'E1' OR
                   lwa_final_sub_tot-sub_total = 'E2'.
              lwa_final_sub_tot3-total_wage_pa  = lwa_final_sub_tot3-total_wage_pa  + lwa_final_sub_tot-total_wage_pa.
              lwa_final_sub_tot3-total_wage_tr  = lwa_final_sub_tot3-total_wage_tr  + lwa_final_sub_tot-total_wage_tr.
              lwa_final_sub_tot3-total_wage_cow = lwa_final_sub_tot3-total_wage_cow + lwa_final_sub_tot-total_wage_cow.
              lwa_final_sub_tot3-total_wage     = lwa_final_sub_tot3-total_wage     + lwa_final_sub_tot-total_wage.

              lwa_final_sub_tot3-total_wage_pa1  = lwa_final_sub_tot3-total_wage_pa1  + lwa_final_sub_tot-total_wage_pa1.
              lwa_final_sub_tot3-total_wage_tr1  = lwa_final_sub_tot3-total_wage_tr1  + lwa_final_sub_tot-total_wage_tr1.
              lwa_final_sub_tot3-total_wage_cow1 = lwa_final_sub_tot3-total_wage_cow1 + lwa_final_sub_tot-total_wage_cow1.
              lwa_final_sub_tot3-total_wage1     = lwa_final_sub_tot3-total_wage1     + lwa_final_sub_tot-total_wage1.

            ENDIF.
          ENDLOOP.
*TOTAL NET PAYMENT = TOTAL PAYMENTS (A1 TO A4, B, C and D) - TOTAL DEDUCTIONS (E1 TO E2)
          lwa_final_sub_tot4-total_wage_pa  = lwa_final_sub_tot2-total_wage_pa  - lwa_final_sub_tot3-total_wage_pa.
          lwa_final_sub_tot4-total_wage_tr  = lwa_final_sub_tot2-total_wage_tr  - lwa_final_sub_tot3-total_wage_tr.
          lwa_final_sub_tot4-total_wage_cow = lwa_final_sub_tot2-total_wage_cow - lwa_final_sub_tot3-total_wage_cow.
          lwa_final_sub_tot4-total_wage     = lwa_final_sub_tot2-total_wage     - lwa_final_sub_tot3-total_wage.

          lwa_final_sub_tot4-total_wage_pa1  = lwa_final_sub_tot2-total_wage_pa1  - lwa_final_sub_tot3-total_wage_pa1.
          lwa_final_sub_tot4-total_wage_tr1  = lwa_final_sub_tot2-total_wage_tr1  - lwa_final_sub_tot3-total_wage_tr1.
          lwa_final_sub_tot4-total_wage_cow1 = lwa_final_sub_tot2-total_wage_cow1 - lwa_final_sub_tot3-total_wage_cow1.
          lwa_final_sub_tot4-total_wage1     = lwa_final_sub_tot2-total_wage1     - lwa_final_sub_tot3-total_wage1.

          WRITE :/ sy-vline,
                   12 'TOTAL PAYMENTS (A1 TO A4, B, C and D)',
                   74 sy-vline,
                   75 lwa_final_sub_tot2-total_wage_pa,
                   93 lwa_final_sub_tot2-total_wage_tr,
                  110 lwa_final_sub_tot2-total_wage_cow,
                  130 lwa_final_sub_tot2-total_wage,
                  148 sy-vline,
                  150 sy-vline,
                  151 lwa_final_sub_tot2-total_wage_pa1,
                  169 lwa_final_sub_tot2-total_wage_tr1,
                  186 lwa_final_sub_tot2-total_wage_cow1,
                  206 lwa_final_sub_tot2-total_wage1,
                  224 sy-vline.
          WRITE :/ sy-vline,
                   12 'TOTAL DEDUCTIONS (E1 TO E2)',
                   74 sy-vline,
                   75 lwa_final_sub_tot3-total_wage_pa,
                   93 lwa_final_sub_tot3-total_wage_tr,
                  110 lwa_final_sub_tot3-total_wage_cow,
                  130 lwa_final_sub_tot3-total_wage,
                  148 sy-vline,
                  150 sy-vline,
                  151 lwa_final_sub_tot3-total_wage_pa1,
                  169 lwa_final_sub_tot3-total_wage_tr1,
                  186 lwa_final_sub_tot3-total_wage_cow1,
                  206 lwa_final_sub_tot3-total_wage1,
                  224 sy-vline.
          WRITE :/ sy-vline,
                   12 'TOTAL NET PAYMENT',
                   74 sy-vline,
                   75 lwa_final_sub_tot4-total_wage_pa,
                   93 lwa_final_sub_tot4-total_wage_tr,
                  110 lwa_final_sub_tot4-total_wage_cow,
                  130 lwa_final_sub_tot4-total_wage,
                  148 sy-vline,
                  150 sy-vline,
                  151 lwa_final_sub_tot4-total_wage_pa1,
                  169 lwa_final_sub_tot4-total_wage_tr1,
                  186 lwa_final_sub_tot4-total_wage_cow1,
                  206 lwa_final_sub_tot4-total_wage1,
                  224 sy-vline.
          NEW-LINE.
          WRITE :/ sy-vline,10 'PAYMENT VIA:',74 sy-vline,148 sy-vline,150 sy-vline,224 sy-vline.
*Bank Transfer
          CLEAR lwa_final_tab.
          LOOP AT it_final_tab INTO lwa_final_tab WHERE lgart = '/559'.
            lwa_final_tab1-total_wage_pa  = lwa_final_tab1-total_wage_pa  + lwa_final_tab-total_wage_pa.
            lwa_final_tab1-total_wage_tr  = lwa_final_tab1-total_wage_tr  + lwa_final_tab-total_wage_tr.
            lwa_final_tab1-total_wage_cow = lwa_final_tab1-total_wage_cow + lwa_final_tab-total_wage_cow.
            lwa_final_tab1-total_wage     = lwa_final_tab1-total_wage     + lwa_final_tab-total_wage.

            lwa_final_tab1-total_wage_pa1  = lwa_final_tab1-total_wage_pa1  + lwa_final_tab-total_wage_pa1.
            lwa_final_tab1-total_wage_tr1  = lwa_final_tab1-total_wage_tr1  + lwa_final_tab-total_wage_tr1.
            lwa_final_tab1-total_wage_cow1 = lwa_final_tab1-total_wage_cow1 + lwa_final_tab-total_wage_cow1.
            lwa_final_tab1-total_wage1     = lwa_final_tab1-total_wage1     + lwa_final_tab-total_wage1.
          ENDLOOP.
          WRITE :/ sy-vline,
                   12 'BANK',
                   65 '145017',
                   74 sy-vline,
                   75 lwa_final_tab1-total_wage_pa,
                   93 lwa_final_tab1-total_wage_tr,
                  110 lwa_final_tab1-total_wage_cow,
                  130 lwa_final_tab1-total_wage,
                  148 sy-vline,"66 total_bank_transfer
                  150 sy-vline,
                  151 lwa_final_tab1-total_wage_pa1,
                  169 lwa_final_tab1-total_wage_tr1,
                  186 lwa_final_tab1-total_wage_cow1,
                  206 lwa_final_tab1-total_wage1,
                  224 sy-vline.
*Cash Payment
          CLEAR lwa_final_tab.
          LOOP AT it_final_tab INTO lwa_final_tab WHERE lgart = '/557'.
            lwa_final_tab2-total_wage_pa  = lwa_final_tab2-total_wage_pa  + lwa_final_tab-total_wage_pa.
            lwa_final_tab2-total_wage_tr  = lwa_final_tab2-total_wage_tr  + lwa_final_tab-total_wage_tr.
            lwa_final_tab2-total_wage_cow = lwa_final_tab2-total_wage_cow + lwa_final_tab-total_wage_cow.
            lwa_final_tab2-total_wage     = lwa_final_tab2-total_wage     + lwa_final_tab-total_wage.

            lwa_final_tab2-total_wage_pa1  = lwa_final_tab2-total_wage_pa1  + lwa_final_tab-total_wage_pa1.
            lwa_final_tab2-total_wage_tr1  = lwa_final_tab2-total_wage_tr1  + lwa_final_tab-total_wage_tr1.
            lwa_final_tab2-total_wage_cow1 = lwa_final_tab2-total_wage_cow1 + lwa_final_tab-total_wage_cow1.
            lwa_final_tab2-total_wage1     = lwa_final_tab2-total_wage1     + lwa_final_tab-total_wage1.
          ENDLOOP.
          WRITE :/ sy-vline,
                   12 'CHEQUE',
                   65 '145210',
                   74 sy-vline,
                   75 lwa_final_tab2-total_wage_pa,
                   93 lwa_final_tab2-total_wage_tr,
                  110 lwa_final_tab2-total_wage_cow,
                  130 lwa_final_tab2-total_wage,
                  148 sy-vline,"66 total_cash_payment,
                  150 sy-vline,
                  151 lwa_final_tab2-total_wage_pa1,
                  169 lwa_final_tab2-total_wage_tr1,
                  186 lwa_final_tab2-total_wage_cow1,
                  206 lwa_final_tab2-total_wage1,
                  224 sy-vline.

          WRITE : / sy-uline(224).
          WRITE : / sy-vline,5 'F',10 'TOTAL COUNT OF STAFF PAID IN THE MONTH ',224 sy-vline.
          FORMAT INTENSIFIED OFF.
          WRITE : / sy-vline,224 sy-vline.
          WRITE : / sy-vline,5 '1',10 'PAYMENT TO STAFF VIA IBG', 77 lwa_month_i-ltx NO-GAP,in_per+0(4) LEFT-JUSTIFIED NO-GAP,'(In-Month)',
                    152 lwa_month_f-ltx NO-GAP,fp_per+0(4) LEFT-JUSTIFIED NO-GAP,'(For-Month)',224 sy-vline.
          WRITE : / sy-vline, 24 'PERMANENT',     70 lwa_final_count-pymnt_ibg_pa, 150 lwa_final_count-pymnt_ibg_pa1, 224 sy-vline.
          WRITE : / sy-vline, 24 'CLERK-OF-WORKS',70 lwa_final_count-pymnt_ibg_cow,150 lwa_final_count-pymnt_ibg_cow1,224 sy-vline.
          WRITE : / sy-vline, 24 'TRAINERS',      70 lwa_final_count-pymnt_ibg_tr, 150 lwa_final_count-pymnt_ibg_tr1, 224 sy-vline.
          WRITE : / sy-vline, 77 TEXT-055,157 TEXT-055,224 sy-vline.
          WRITE : / sy-vline, 70 lwa_final_count-tot_ibg,150 lwa_final_count-tot_ibg1,224 sy-vline.
          WRITE : / sy-vline, 77 TEXT-055,157 TEXT-055,224 sy-vline.
          WRITE : / sy-vline,224 sy-vline.
          WRITE : / sy-vline, 5 '2',10 'PAYMENT TO STAFF VIA CHEQUE',224 sy-vline.
          WRITE : / sy-vline, 24 'PERMANENT',     70 lwa_final_count-pymnt_chq_pa,  150 lwa_final_count-pymnt_chq_pa1, 224 sy-vline.
          WRITE : / sy-vline, 24 'CLERK-OF-WORKS',70 lwa_final_count-pymnt_chq_cow, 150 lwa_final_count-pymnt_chq_cow1,224 sy-vline.
          WRITE : / sy-vline, 77 TEXT-055,157 TEXT-055,224 sy-vline.
          WRITE : / sy-vline, 70 lwa_final_count-tot_chq,150 lwa_final_count-tot_chq1,224 sy-vline.
          WRITE : / sy-vline, 77 TEXT-055,157 TEXT-055,224 sy-vline.

          WRITE : / sy-vline,224 sy-vline.
          WRITE : / sy-vline,5 '3',10 'TOTAL PAYOUT COUNT FOR PERMANENT STAFF EXCLUDING COW AND TR',224 sy-vline.
          WRITE : / sy-vline, 24 'ACTUAL PAYOUT TO ACTIVE STAFF',
                              70 lwa_final_count-pymnt_ibg_pa,150 lwa_final_count-pymnt_ibg_pa1,224 sy-vline.
          WRITE : / sy-vline, 24 'ADD: STAFF LEAVING IN PAYROLL MONTH (CHEQUE)',
                              70 lwa_final_count-pymnt_chq_pa,  150 lwa_final_count-pymnt_chq_pa1,224 sy-vline.
          WRITE : / sy-vline, 77 TEXT-055,157 TEXT-055,224 sy-vline.
          WRITE : / sy-vline, 70 lwa_final_count-tot_pa,150 lwa_final_count-tot_pa1,224 sy-vline.
          WRITE : / sy-vline, 77 TEXT-055,157 TEXT-055,224 sy-vline.

          WRITE : / sy-vline,5 '4',10 'TOTAL PAYOUT COUNT FOR THE MONTH (F1 TO F2)',
                           70 lwa_final_count-tot_count,150 lwa_final_count-tot_count1,224 sy-vline.
          WRITE : / sy-vline,224 sy-vline.
          EXIT.
      ENDCASE.
    ENDAT.

    ON CHANGE OF lwa_sec_details-sec." or lwa_Sec_Details-sub_sec.
      FORMAT INTENSIFIED ON.
      CASE lwa_sec_details-main.
        WHEN 'A'.
          CASE lwa_sec_details-sec .
            WHEN '01'.
              WRITE :/ sy-vline,10 lwa_sec_details-sec,'SALARIES:',74 sy-vline,148 sy-vline,150 sy-vline,224 sy-vline.
            WHEN '02'.
              WRITE :/ sy-vline,10 lwa_sec_details-sec,'BONUS',74 sy-vline,148 sy-vline,150 sy-vline,224 sy-vline.
*            WHEN '03'.
*              WRITE :/ sy-vline,10 lwa_sec_details-sec,'GRATUITY',148 sy-vline.
            WHEN '04'.
              WRITE :/ sy-vline,10 lwa_sec_details-sec,'ALLOWANCES:',74 sy-vline,148 sy-vline,150 sy-vline,224 sy-vline.
            WHEN '05'.
              WRITE :/ sy-vline,10 lwa_sec_details-sec,'EMPLOYER (E','YER',') STATUTORY CONTRIBUTION',74 sy-vline,148 sy-vline,150 sy-vline,224 sy-vline.
          ENDCASE.
        WHEN 'C'.
          CASE lwa_sec_details-sec .
            WHEN '01'.
              WRITE :/ sy-vline,10 lwa_sec_details-sec,'AWARDS',74 sy-vline,148 sy-vline,150 sy-vline,224 sy-vline.
            WHEN '02'.
              WRITE :/ sy-vline,10 lwa_sec_details-sec,'ESS CLAIMS',74 sy-vline,148 sy-vline,150 sy-vline,224 sy-vline.
          ENDCASE.
        WHEN 'E'.
          CASE lwa_sec_details-sec .
            WHEN '01'.
              WRITE :/ sy-vline,10 lwa_sec_details-sec,'EMPLOYEE (E','YEE)', 'CPF',74 sy-vline,148 sy-vline,150 sy-vline,224 sy-vline.
            WHEN '02'.
              WRITE :/ sy-vline,10 lwa_sec_details-sec,'OTHER STAFF DEDUCTIONS',74 sy-vline,148 sy-vline,150 sy-vline,224 sy-vline.
          ENDCASE.
      ENDCASE.
      FORMAT INTENSIFIED OFF.
    ENDON.
    CLEAR lv_sec_temp.
    lv_sec_temp = lwa_sec_details-sec.
    LOOP AT it_py_cfg INTO lwa_py_cfg WHERE main EQ lwa_sec_details-main AND
                                             sec EQ lwa_sec_details-sec  AND
                                         sub_sec EQ lwa_sec_details-sub_sec.
      IF lv_temp EQ 'X'.
        FORMAT INTENSIFIED ON.
        CASE lwa_sec_details-main.
          WHEN 'A'.
            CASE lwa_sec_details-sub_sec.
              WHEN '01'.
                WRITE :/ sy-vline,10 'a) RECURRING ALLOWANCES',74 sy-vline,148 sy-vline,150 sy-vline,224 sy-vline.
                CLEAR lv_temp.
              WHEN '02'.
                WRITE :/ sy-vline,10 'b)  ADDITIONAL/ONE TIME ALLOWANCE',74 sy-vline,148 sy-vline,150 sy-vline,224 sy-vline.
                CLEAR lv_temp.
              WHEN '03'.
                WRITE :/ sy-vline,10 'c) OVERTIME ALLOWANCE',74 sy-vline,148 sy-vline,150 sy-vline,224 sy-vline.
                CLEAR lv_temp.
              WHEN '04'.
                WRITE :/ sy-vline,10 'd) TRAINER HONARARIUM CLAIMS',74 sy-vline,148 sy-vline,150 sy-vline,224 sy-vline.
                CLEAR lv_temp.
              WHEN OTHERS.
                CLEAR lv_temp.
            ENDCASE.
          WHEN 'C'.
            CASE lwa_sec_details-sec.
              WHEN '1'.
                WRITE :/ sy-vline,10 lwa_sec_details-sec,'AWARDS',74 sy-vline,148 sy-vline,150 sy-vline,224 sy-vline.
                CLEAR lv_temp.
              WHEN '2'.
                CASE lwa_sec_details-sub_sec.
                  WHEN '01'.
                    WRITE :/ sy-vline,10 'STAFF DEVELOPMENT AND BENEFITS (OFI1)',74 sy-vline,148 sy-vline,150 sy-vline,224 sy-vline.
                    CLEAR lv_temp.
                  WHEN '02'.
                    WRITE :/ sy-vline,10 'REPAIR & MAINTENANCE (OFI2)',74 sy-vline,148 sy-vline,150 sy-vline,224 sy-vline.
                    CLEAR lv_temp.
                  WHEN '03'.
                    WRITE :/ sy-vline,10 'SUPPLIES AND MATERIALS (OFI4)',74 sy-vline,148 sy-vline,150 sy-vline,224 sy-vline.
                    CLEAR lv_temp.
                  WHEN '04'.
                    WRITE :/ sy-vline,10 'COMMUNICATION (OFI3)',74 sy-vline,148 sy-vline,150 sy-vline,224 sy-vline.
                    CLEAR lv_temp.
                  WHEN '05'.
                    WRITE :/ sy-vline,10 'TRANSPORTATION (OTRT)',74 sy-vline,148 sy-vline,150 sy-vline,224 sy-vline.
                    CLEAR lv_temp.
                  WHEN '06'.
                    WRITE :/ sy-vline,10 'OTHER EXPENSES (OFI5)',74 sy-vline,148 sy-vline,150 sy-vline,224 sy-vline.
                    CLEAR lv_temp.
                  WHEN '07'.
                    WRITE :/ sy-vline,10 'ADMINISTRATIVE EXPENSES (OFI6)',74 sy-vline,148 sy-vline,150 sy-vline,224 sy-vline.
                    CLEAR lv_temp.
                  WHEN '08'.
                    WRITE :/ sy-vline,10 'SUPPLIES AND MATERIALS (OFI8)',74 sy-vline,148 sy-vline,150 sy-vline,224 sy-vline.
                    CLEAR lv_temp.
                  WHEN '09'.
                    WRITE :/ sy-vline,10 'ACTIVITY & PROJECTS (OFI9)',74 sy-vline,148 sy-vline,150 sy-vline,224 sy-vline.
                    CLEAR lv_temp.
                ENDCASE.
            ENDCASE.
          WHEN 'E'.
            CASE lwa_sec_details-sec.
              WHEN '1'.
                WRITE :/ sy-vline,10 lwa_sec_details-sec,'EMPLOYEE (E','YEE)',' CPF',74 sy-vline,148 sy-vline,150 sy-vline,224 sy-vline.
                CLEAR lv_temp.
            ENDCASE.
        ENDCASE.
        FORMAT INTENSIFIED OFF.
      ENDIF.
      SORT it_final_tab BY lgart.
      CLEAR gwa_final_tab.
      READ TABLE it_final_tab INTO gwa_final_tab WITH KEY lgart = lwa_py_cfg-lgart ."BINARY SEARCH.
      IF sy-subrc EQ 0.
        LOOP AT it_final_tab INTO gwa_final_tab WHERE lgart = lwa_py_cfg-lgart .
          IF lv_lgart EQ gwa_final_tab-lgart.
            CLEAR gwa_final_tab-lgtxt.
          ELSE.
            lv_lgart = gwa_final_tab-lgart.
            gwa_final_tab-lgtxt = lwa_py_cfg-description.
          ENDIF.
          lwa_final_sub_tot-total_wage_pa  = lwa_final_sub_tot-total_wage_pa  + gwa_final_tab-total_wage_pa.
          lwa_final_sub_tot-total_wage_tr  = lwa_final_sub_tot-total_wage_tr  + gwa_final_tab-total_wage_tr.
          lwa_final_sub_tot-total_wage_cow = lwa_final_sub_tot-total_wage_cow + gwa_final_tab-total_wage_cow.
          lwa_final_sub_tot-total_wage     = lwa_final_sub_tot-total_wage     + gwa_final_tab-total_wage.

          lwa_final_sub_tot-total_wage_pa1  = lwa_final_sub_tot-total_wage_pa1  + gwa_final_tab-total_wage_pa1.
          lwa_final_sub_tot-total_wage_tr1  = lwa_final_sub_tot-total_wage_tr1  + gwa_final_tab-total_wage_tr1.
          lwa_final_sub_tot-total_wage_cow1 = lwa_final_sub_tot-total_wage_cow1 + gwa_final_tab-total_wage_cow1.
          lwa_final_sub_tot-total_wage1     = lwa_final_sub_tot-total_wage1     + gwa_final_tab-total_wage1.

          IF lwa_sec_details-main EQ 'A' AND lwa_sec_details-sec EQ '03'.
            WRITE :/ sy-vline.
            FORMAT COLOR = 4.
            FORMAT INTENSIFIED ON.
            WRITE : 10  '03 GRATUITY         (A3)',
                    55 gwa_final_tab-lgart,
                    65 gwa_final_tab-acct,
                    74 sy-vline,
                    75 lwa_final_sub_tot-total_wage_pa,
                    93 lwa_final_sub_tot-total_wage_tr,
                   110 lwa_final_sub_tot-total_wage_cow,
                   130 lwa_final_sub_tot-total_wage,
                   148 sy-vline,
                   150 sy-vline,
                   151 lwa_final_sub_tot-total_wage_pa1,
                   169 lwa_final_sub_tot-total_wage_tr1,
                   189 lwa_final_sub_tot-total_wage_cow1,
                   206 lwa_final_sub_tot-total_wage1,
                   224 sy-vline.

            FORMAT COLOR = 0.
            FORMAT INTENSIFIED OFF.
            CONCATENATE lwa_sec_details-main lv_sec_temp+1(1) INTO lwa_final_sub_tot-sub_total.
            APPEND lwa_final_sub_tot TO it_final_sub_tot.
            CLEAR lwa_final_sub_tot.
          ELSEIF lwa_sec_details-main EQ 'C' AND lwa_sec_details-sec EQ '02'. "do nothing
            lwa_final_sub_tot7-total_wage_pa  = lwa_final_sub_tot7-total_wage_pa  + gwa_final_tab-total_wage_pa.
            lwa_final_sub_tot7-total_wage_tr  = lwa_final_sub_tot7-total_wage_tr  + gwa_final_tab-total_wage_tr.
            lwa_final_sub_tot7-total_wage_cow = lwa_final_sub_tot7-total_wage_cow + gwa_final_tab-total_wage_cow.
            lwa_final_sub_tot7-total_wage     = lwa_final_sub_tot7-total_wage     + gwa_final_tab-total_wage.

            lwa_final_sub_tot7-total_wage_pa1  = lwa_final_sub_tot7-total_wage_pa1  + gwa_final_tab-total_wage_pa1.
            lwa_final_sub_tot7-total_wage_tr1  = lwa_final_sub_tot7-total_wage_tr1  + gwa_final_tab-total_wage_tr1.
            lwa_final_sub_tot7-total_wage_cow1 = lwa_final_sub_tot7-total_wage_cow1 + gwa_final_tab-total_wage_cow1.
            lwa_final_sub_tot7-total_wage1     = lwa_final_sub_tot7-total_wage1     + gwa_final_tab-total_wage1.

*            gwa_final_tab-lgtxt = lwa_py_cfg-description.
            PERFORM write_data USING gwa_final_tab.
          ELSE.
*            gwa_final_tab-lgtxt = lwa_py_cfg-description.
            PERFORM write_data USING gwa_final_tab.
          ENDIF.
        ENDLOOP.
      ELSE.
        CLEAR lwa_wt_gl_acc.
        READ TABLE it_wt_gl_acc INTO lwa_wt_gl_acc WITH KEY lgart = lwa_py_cfg-lgart.
        IF lwa_sec_details-main EQ 'A' AND lwa_sec_details-sec EQ '03'.
          WRITE :/ sy-vline.
          FORMAT COLOR = 4.
          FORMAT INTENSIFIED ON.
          WRITE : 10   '03 GRATUITY         (A3)',
                  55 lwa_py_cfg-lgart,
                  65 lwa_wt_gl_acc-acct,
                  74 sy-vline,
                  75 lwa_final_sub_tot-total_wage_pa,
                  93 lwa_final_sub_tot-total_wage_tr,
                 110 lwa_final_sub_tot-total_wage_cow,
                 130 lwa_final_sub_tot-total_wage,
                 148 sy-vline,
                 150 sy-vline,
                 151 lwa_final_sub_tot-total_wage_pa1,
                 169 lwa_final_sub_tot-total_wage_tr1,
                 186 lwa_final_sub_tot-total_wage_cow1,
                 206 lwa_final_sub_tot-total_wage1,
                 224 sy-vline.
          FORMAT COLOR = 0.
          FORMAT INTENSIFIED OFF.
          CONCATENATE lwa_sec_details-main lv_sec_temp+1(1) INTO lwa_final_sub_tot-sub_total.
          APPEND lwa_final_sub_tot TO it_final_sub_tot.
          CLEAR lwa_final_sub_tot.
        ELSE.
          WRITE :/ sy-vline,
                  12 lwa_py_cfg-description,
                  55 lwa_py_cfg-lgart,
                  65 lwa_wt_gl_acc-acct,
                  74 sy-vline,
                 148 sy-vline,
                 150 sy-vline,
                 224 sy-vline.
        ENDIF.
      ENDIF.
    ENDLOOP.
    CONCATENATE lwa_sec_details-main lv_sec_temp+1(1) INTO lwa_final_sub_tot-sub_total.
    IF lwa_sec_details-main EQ 'A' AND lwa_sec_details-sec EQ '03'.
*do nothing,already A3 subtotal added
    ELSEIF lwa_sec_details-main EQ 'A' AND lwa_sec_details-sec EQ '04' AND lwa_sec_details-sub_sec LE '04'.
      FORMAT COLOR = 4.
      WRITE :/ sy-vline,
            74 sy-vline,
            75 lwa_final_sub_tot-total_wage_pa,
            93 lwa_final_sub_tot-total_wage_tr,
           110 lwa_final_sub_tot-total_wage_cow,
           130 lwa_final_sub_tot-total_wage,
           148 sy-vline,
           150 sy-vline,
           151 lwa_final_sub_tot-total_wage_pa1,
           169 lwa_final_sub_tot-total_wage_tr1,
           186 lwa_final_sub_tot-total_wage_cow1,
           206 lwa_final_sub_tot-total_wage1,
           224 sy-vline.
      FORMAT COLOR = 0.

      APPEND lwa_final_sub_tot TO it_final_sub_tot.
      CLEAR lwa_final_sub_tot.
      IF lwa_sec_details-sub_sec EQ '04'.
        FORMAT COLOR = 4.
        CLEAR lwa_final_sub_tot6.
        LOOP AT it_final_sub_tot INTO lwa_final_sub_tot.
          IF lwa_final_sub_tot-sub_total EQ 'A4'.
            lwa_final_sub_tot6-total_wage_pa  = lwa_final_sub_tot6-total_wage_pa  + lwa_final_sub_tot-total_wage_pa.
            lwa_final_sub_tot6-total_wage_tr  = lwa_final_sub_tot6-total_wage_tr  + lwa_final_sub_tot-total_wage_tr.
            lwa_final_sub_tot6-total_wage_cow = lwa_final_sub_tot6-total_wage_cow + lwa_final_sub_tot-total_wage_cow.
            lwa_final_sub_tot6-total_wage     = lwa_final_sub_tot6-total_wage     + lwa_final_sub_tot-total_wage.

            lwa_final_sub_tot6-total_wage_pa1  = lwa_final_sub_tot6-total_wage_pa1  + lwa_final_sub_tot-total_wage_pa1.
            lwa_final_sub_tot6-total_wage_tr1  = lwa_final_sub_tot6-total_wage_tr1  + lwa_final_sub_tot-total_wage_tr1.
            lwa_final_sub_tot6-total_wage_cow1 = lwa_final_sub_tot6-total_wage_cow1 + lwa_final_sub_tot-total_wage_cow1.
            lwa_final_sub_tot6-total_wage1     = lwa_final_sub_tot6-total_wage1     + lwa_final_sub_tot-total_wage1.

          ENDIF.
          AT LAST.
            SUM.
            WRITE :/ sy-vline,
                  30 'SUB-TOTAL(', 'A4 )',
                  74 sy-vline,
                  75 lwa_final_sub_tot6-total_wage_pa,
                  93 lwa_final_sub_tot6-total_wage_tr,
                 110 lwa_final_sub_tot6-total_wage_cow,
                 130 lwa_final_sub_tot6-total_wage,
                 148 sy-vline,
                 150 sy-vline,
                 151 lwa_final_sub_tot6-total_wage_pa1,
                 169 lwa_final_sub_tot6-total_wage_tr1,
                 186 lwa_final_sub_tot6-total_wage_cow1,
                 206 lwa_final_sub_tot6-total_wage1,
                 224 sy-vline.
            FORMAT COLOR = 0.
            lwa_final_sub_tot-sub_total = 'A4_TOTAL'.
            FORMAT COLOR = 4.
            FORMAT INTENSIFIED ON.
            WRITE :/ sy-vline,
                          12 'TOTAL SALARIES & WAGES ,BONUS and ALLOWANCES (A1 TO A4)',
                          74 sy-vline,
                          75 lwa_final_sub_tot-total_wage_pa,
                          93 lwa_final_sub_tot-total_wage_tr,
                         110 lwa_final_sub_tot-total_wage_cow,
                         130 lwa_final_sub_tot-total_wage,
                         148 sy-vline,
                         150 sy-vline,
                         151 lwa_final_sub_tot-total_wage_pa1,
                         169 lwa_final_sub_tot-total_wage_tr1,
                         186 lwa_final_sub_tot-total_wage_cow1,
                         206 lwa_final_sub_tot-total_wage1,
                         224 sy-vline.
            FORMAT INTENSIFIED OFF.
            FORMAT COLOR = 0.
            APPEND lwa_final_sub_tot TO it_final_sub_tot.
            CLEAR lwa_final_sub_tot.
            EXIT.
          ENDAT.
        ENDLOOP.
      ENDIF.
    ELSEIF lwa_sec_details-main EQ 'A' AND lwa_sec_details-sec EQ '05'.
      lwa_final_sub_tot-total_wage_pa  = lwa_final_sub_tot-total_wage_pa  + gwa_final_tab-total_wage_pa.
      lwa_final_sub_tot-total_wage_tr  = lwa_final_sub_tot-total_wage_tr  + gwa_final_tab-total_wage_tr.
      lwa_final_sub_tot-total_wage_cow = lwa_final_sub_tot-total_wage_cow + gwa_final_tab-total_wage_cow.
      lwa_final_sub_tot-total_wage     = lwa_final_sub_tot-total_wage     + gwa_final_tab-total_wage.

      lwa_final_sub_tot-total_wage_pa1  = lwa_final_sub_tot-total_wage_pa1  + gwa_final_tab-total_wage_pa1.
      lwa_final_sub_tot-total_wage_tr1  = lwa_final_sub_tot-total_wage_tr1  + gwa_final_tab-total_wage_tr1.
      lwa_final_sub_tot-total_wage_cow1 = lwa_final_sub_tot-total_wage_cow1 + gwa_final_tab-total_wage_cow1.
      lwa_final_sub_tot-total_wage1     = lwa_final_sub_tot-total_wage1     + gwa_final_tab-total_wage1.

      FORMAT COLOR = 4.
*      FORMAT INTENSIFIED ON.
      WRITE :/ sy-vline,
            12 TEXT-050,"TOTAL E'YER STATUTORY CONTRIBUTION (A5)
            74 sy-vline,
            75 lwa_final_sub_tot-total_wage_pa,
            93 lwa_final_sub_tot-total_wage_tr,
           110 lwa_final_sub_tot-total_wage_cow,
           130 lwa_final_sub_tot-total_wage,
           148 sy-vline,
           150 sy-vline,
           151 lwa_final_sub_tot-total_wage_pa1,
           169 lwa_final_sub_tot-total_wage_tr1,
           186 lwa_final_sub_tot-total_wage_cow1,
           206 lwa_final_sub_tot-total_wage1,
           224 sy-vline.
*      FORMAT INTENSIFIED OFF.
      FORMAT COLOR = 0.
      APPEND lwa_final_sub_tot TO it_final_sub_tot.

      "TOTAL EOM (A1 TO A5)
      READ TABLE it_final_sub_tot INTO lwa_final_sub_tot1 WITH KEY sub_total = 'A4_TOTAL'.
      IF sy-subrc EQ 0.
      ENDIF.
      lwa_final_sub_tot-sub_total = 'A1_A5_TOTAL'.
      lwa_final_sub_tot-total_wage_pa  = lwa_final_sub_tot-total_wage_pa  + lwa_final_sub_tot1-total_wage_pa.
      lwa_final_sub_tot-total_wage_tr  = lwa_final_sub_tot-total_wage_tr  + lwa_final_sub_tot1-total_wage_tr.
      lwa_final_sub_tot-total_wage_cow = lwa_final_sub_tot-total_wage_cow + lwa_final_sub_tot1-total_wage_cow.
      lwa_final_sub_tot-total_wage     = lwa_final_sub_tot-total_wage     + lwa_final_sub_tot1-total_wage.

      lwa_final_sub_tot-total_wage_pa1  = lwa_final_sub_tot-total_wage_pa1  + lwa_final_sub_tot1-total_wage_pa1.
      lwa_final_sub_tot-total_wage_tr1  = lwa_final_sub_tot-total_wage_tr1  + lwa_final_sub_tot1-total_wage_tr1.
      lwa_final_sub_tot-total_wage_cow1 = lwa_final_sub_tot-total_wage_cow1 + lwa_final_sub_tot1-total_wage_cow1.
      lwa_final_sub_tot-total_wage1     = lwa_final_sub_tot-total_wage1     + lwa_final_sub_tot1-total_wage1.

      FORMAT COLOR = 4.
      FORMAT INTENSIFIED ON.
      WRITE :/ sy-vline,
            12 TEXT-051,"TOTAL EOM (A1 TO A5)
            74 sy-vline,
            75 lwa_final_sub_tot-total_wage_pa,
            93 lwa_final_sub_tot-total_wage_tr,
           110 lwa_final_sub_tot-total_wage_cow,
           130 lwa_final_sub_tot-total_wage,
           148 sy-vline,
           150 sy-vline,
           151 lwa_final_sub_tot-total_wage_pa1,
           169 lwa_final_sub_tot-total_wage_tr1,
           186 lwa_final_sub_tot-total_wage_cow1,
           206 lwa_final_sub_tot-total_wage1,
           224 sy-vline.
      FORMAT INTENSIFIED OFF.
      FORMAT COLOR = 0.
      APPEND lwa_final_sub_tot TO it_final_sub_tot.
      CLEAR lwa_final_sub_tot.
    ELSEIF lwa_sec_details-main EQ 'B'.
      WRITE :/ sy-vline.
      FORMAT COLOR = 4.
      FORMAT INTENSIFIED ON.
      WRITE : 12 'TOTAL EXTERNAL ALLOWANCES (B)',
              74 sy-vline,
              75 lwa_final_sub_tot-total_wage_pa,
              93 lwa_final_sub_tot-total_wage_tr,
             110 lwa_final_sub_tot-total_wage_cow,
             130 lwa_final_sub_tot-total_wage,
             148 sy-vline,
             150 sy-vline,
             151 lwa_final_sub_tot-total_wage_pa1,
             169 lwa_final_sub_tot-total_wage_tr1,
             186 lwa_final_sub_tot-total_wage_cow1,
             206 lwa_final_sub_tot-total_wage1,
             224 sy-vline.
      FORMAT INTENSIFIED OFF.
      FORMAT COLOR = 0.
      APPEND lwa_final_sub_tot TO it_final_sub_tot.
      CLEAR lwa_final_sub_tot.
    ELSEIF lwa_sec_details-main EQ 'C' AND lwa_sec_details-sec EQ '02' AND lwa_sec_details-sub_sec LE '09'.
      WRITE :/ sy-vline.
      FORMAT COLOR = 4.
      WRITE : 74 sy-vline,
              75 lwa_final_sub_tot7-total_wage_pa,
              93 lwa_final_sub_tot7-total_wage_tr,
             110 lwa_final_sub_tot7-total_wage_cow,
             130 lwa_final_sub_tot7-total_wage,
             148 sy-vline,
             150 sy-vline,
             151 lwa_final_sub_tot7-total_wage_pa1,
             169 lwa_final_sub_tot7-total_wage_tr1,
             186 lwa_final_sub_tot7-total_wage_cow1,
             206 lwa_final_sub_tot7-total_wage1,
             224 sy-vline.
      CLEAR lwa_final_sub_tot7.
      FORMAT COLOR = 0.

      IF lwa_sec_details-sub_sec EQ '09'.
        FORMAT COLOR = 4.
        WRITE :/ sy-vline,
              30 'SUB-TOTAL(', lwa_final_sub_tot-sub_total, ')',
              74 sy-vline,
              75 lwa_final_sub_tot-total_wage_pa,
              93 lwa_final_sub_tot-total_wage_tr,
             110 lwa_final_sub_tot-total_wage_cow,
             130 lwa_final_sub_tot-total_wage,
             148 sy-vline,
             150 sy-vline,
             151 lwa_final_sub_tot-total_wage_pa1,
             169 lwa_final_sub_tot-total_wage_tr1,
             186 lwa_final_sub_tot-total_wage_cow1,
             206 lwa_final_sub_tot-total_wage1,
             224 sy-vline.
        FORMAT COLOR = 0.

        APPEND lwa_final_sub_tot TO it_final_sub_tot.
        CLEAR : lwa_final_sub_tot,lwa_final_sub_tot5.
        LOOP AT it_final_sub_tot INTO lwa_final_sub_tot5 WHERE sub_total EQ 'C1' OR sub_total EQ 'C2'.
          lwa_final_sub_tot-total_wage_pa  = lwa_final_sub_tot-total_wage_pa  + lwa_final_sub_tot5-total_wage_pa.
          lwa_final_sub_tot-total_wage_tr  = lwa_final_sub_tot-total_wage_tr  + lwa_final_sub_tot5-total_wage_tr.
          lwa_final_sub_tot-total_wage_cow = lwa_final_sub_tot-total_wage_cow + lwa_final_sub_tot5-total_wage_cow.
          lwa_final_sub_tot-total_wage     = lwa_final_sub_tot-total_wage     + lwa_final_sub_tot5-total_wage.

          lwa_final_sub_tot-total_wage_pa1  = lwa_final_sub_tot-total_wage_pa1  + lwa_final_sub_tot5-total_wage_pa1.
          lwa_final_sub_tot-total_wage_tr1  = lwa_final_sub_tot-total_wage_tr1  + lwa_final_sub_tot5-total_wage_tr1.
          lwa_final_sub_tot-total_wage_cow1 = lwa_final_sub_tot-total_wage_cow1 + lwa_final_sub_tot5-total_wage_cow1.
          lwa_final_sub_tot-total_wage1     = lwa_final_sub_tot-total_wage1     + lwa_final_sub_tot5-total_wage1.

        ENDLOOP.
        lwa_final_sub_tot-sub_total = 'C_TOTAL'.
        FORMAT COLOR = 4.
        FORMAT INTENSIFIED ON.
        WRITE :/ sy-vline,
                      12 'TOTAL OOE (C1 TO C2)',
                      74 sy-vline,
                      75 lwa_final_sub_tot-total_wage_pa,
                      93 lwa_final_sub_tot-total_wage_tr,
                     110 lwa_final_sub_tot-total_wage_cow,
                     130 lwa_final_sub_tot-total_wage,
                     148 sy-vline,
                     150 sy-vline,
                     151 lwa_final_sub_tot-total_wage_pa1,
                     169 lwa_final_sub_tot-total_wage_tr1,
                     186 lwa_final_sub_tot-total_wage_cow1,
                     206 lwa_final_sub_tot-total_wage1,
                     224 sy-vline.
        FORMAT INTENSIFIED OFF.
        FORMAT COLOR = 0.
        APPEND lwa_final_sub_tot TO it_final_sub_tot.
        CLEAR lwa_final_sub_tot.
      ENDIF.
    ELSEIF lwa_sec_details-main EQ 'D'."SALARY RECOVERABLE
      WRITE :/ sy-vline.
      FORMAT COLOR = 4.
      FORMAT INTENSIFIED ON.
      WRITE : 74 sy-vline,
              75 lwa_final_sub_tot-total_wage_pa,
              93 lwa_final_sub_tot-total_wage_tr,
             110 lwa_final_sub_tot-total_wage_cow,
             130 lwa_final_sub_tot-total_wage,
             148 sy-vline,
             150 sy-vline,
             151 lwa_final_sub_tot-total_wage_pa1,
             169 lwa_final_sub_tot-total_wage_tr1,
             186 lwa_final_sub_tot-total_wage_cow1,
             206 lwa_final_sub_tot-total_wage1,
             224 sy-vline.
      FORMAT INTENSIFIED OFF.
      FORMAT COLOR = 0.
      APPEND lwa_final_sub_tot TO it_final_sub_tot.
      CLEAR lwa_final_sub_tot.
    ELSEIF lwa_sec_details-main EQ 'F'."PAYMENT VIA:
*do nothing
    ELSE.
      WRITE :/ sy-vline.
      FORMAT COLOR = 4.
*      FORMAT INTENSIFIED ON.
      WRITE : 30 'SUB-TOTAL(', lwa_final_sub_tot-sub_total, ')',
              74 sy-vline,
              75 lwa_final_sub_tot-total_wage_pa,
              93 lwa_final_sub_tot-total_wage_tr,
             110 lwa_final_sub_tot-total_wage_cow,
             130 lwa_final_sub_tot-total_wage,
             148 sy-vline,
             150 sy-vline,
             151 lwa_final_sub_tot-total_wage_pa1,
             169 lwa_final_sub_tot-total_wage_tr1,
             186 lwa_final_sub_tot-total_wage_cow1,
             206 lwa_final_sub_tot-total_wage1,
             224 sy-vline.
*      FORMAT INTENSIFIED OFF.
      FORMAT COLOR = 0.
      APPEND lwa_final_sub_tot TO it_final_sub_tot.
      CLEAR lwa_final_sub_tot.
    ENDIF.
  ENDLOOP.
  WRITE :/ sy-uline(224).
  STOP.
ENDFORM.                    " WRITE_OUTPUT
*&---------------------------------------------------------------------*
*&      Form  WRITE_OUTPUT_INPER
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM write_output_inper .
  DATA : lwa_ee_group       TYPE ty_ee_group, "CR-0000000739
         lwa_wt_gl_acc      TYPE ty_wt_gl_acc,
         lwa_py_cfg         TYPE zhrpy_py_cfg, "Paysheet Config table
         lwa_final_tab      TYPE ty_final_tab,
         lwa_final_tab1     TYPE ty_final_tab,
         lwa_final_tab2     TYPE ty_final_tab,
         lwa_final_sub_tot  TYPE ty_final_sub_tot,
         lwa_final_sub_tot1 TYPE ty_final_sub_tot,
         lwa_final_sub_tot2 TYPE ty_final_sub_tot,
         lwa_final_sub_tot3 TYPE ty_final_sub_tot,
         lwa_final_sub_tot4 TYPE ty_final_sub_tot,
         lwa_final_sub_tot5 TYPE ty_final_sub_tot,
         lwa_final_sub_tot6 TYPE ty_final_sub_tot,
         lwa_final_sub_tot7 TYPE ty_final_sub_tot,
         lwa_final_count    TYPE ty_final_count,
         lwa_month_i        TYPE t247,
         lwa_month_f        TYPE t247,
         lv_month           TYPE month,
         lv_temp            TYPE c,
         lv_sec_temp(2)     TYPE c,
         lv_lgart           TYPE lgart,
         lv_title           TYPE string.

  PERFORM final_count CHANGING lwa_final_count.

*  CALL FUNCTION 'IDWT_READ_MONTH_TEXT'
*    EXPORTING
*      langu = sy-langu
*      month = lv_month
*    IMPORTING
*      t247  = lwa_month_f.
  MOVE in_per+4(2) TO lv_month.
  CALL FUNCTION 'IDWT_READ_MONTH_TEXT'
    EXPORTING
      langu = sy-langu
      month = lv_month
    IMPORTING
      t247  = lwa_month_i.
  TRANSLATE lwa_month_i-ltx TO UPPER CASE.
  CLEAR : gwa_final_tab,lv_title.
  CONCATENATE TEXT-053 lwa_month_i-ltx in_per+0(4) TEXT-054 INTO lv_title SEPARATED BY space.
  WRITE : /5 lv_title.
  FORMAT COLOR COL_GROUP .
  WRITE / sy-uline(148).
  WRITE : / sy-vline,74 sy-vline,105 lwa_month_i-ltx, in_per+0(4),148 sy-vline.",150 sy-vline,180 lwa_month_f-ltx, fp_per+0(4),224 sy-vline.
  WRITE : / sy-vline,74 sy-vline,107 'GL: 143100',148 sy-vline.",150 sy-vline,175 'GL: 143100',224 sy-vline.
  WRITE : / sy-vline,74 sy-vline,75 TEXT-052,148 sy-vline.",150 sy-vline,151 text-052,224 sy-vline.
*  WRITE : / sy-vline,10 'WAGE '      ,54 'WAGE' ,66 'GL'      ,74 sy-vline,98 'TRAINER', 114 'CLERK-OF-WORKS', 135 '   TOTAL' ,148 sy-vline.
  WRITE : / sy-vline,10 TEXT-087,54 'WAGE' ,66 'GL'      ,74 sy-vline,91 TEXT-062, 107 TEXT-063, 124 TEXT-064 ,148 sy-vline.
*        150 sy-vline,177 'TRAINER',194 'CLERK-OF-WORKS',215 'TOTAL',224 sy-vline.
  WRITE : / sy-vline,10 TEXT-058,54 TEXT-059,64 TEXT-060,74 sy-vline, 75 TEXT-061 ,148 sy-vline.",99 ' (TR)   ',108 '   (COW)'     , 127 '(Incl TR&COW)',148 sy-vline.
*        150 sy-vline,161 'PA',179 '(TR)',196 '(COW)',211 '(Incl TR&COW)',224 sy-vline.
  WRITE : / sy-vline,12 TEXT-065,74 sy-vline,TEXT-089 UNDER TEXT-061,TEXT-090 UNDER TEXT-062,TEXT-091 UNDER TEXT-063,TEXT-090 UNDER TEXT-064,148 sy-vline.",150 sy-vline,162 '$',180 '$',198 '$',217 '$',224 sy-vline.
  WRITE / sy-uline(148).
  FORMAT COLOR OFF.

  LOOP AT it_sec_details INTO lwa_sec_details.
    lv_temp = 'X'.

    AT NEW main.
      FORMAT INTENSIFIED ON.
      CASE lwa_sec_details-main.
*        WHEN 'A'.
**          WRITE :/ sy-vline,5 'A',10 'EXPENDITURE OF MAMPOWER (EOM)',74 sy-vline,148 sy-vline.
*          WRITE :/ sy-vline,5 'A',10 text-066,74 sy-vline,148 sy-vline.
*        WHEN 'B'.
*          WRITE :/ sy-vline,5 'B',10 'EXTERNAL ALLOWANCES (Deposit Account)',74 sy-vline,148 sy-vline.
*        WHEN 'C'.
*          WRITE :/ sy-vline,5 'C',10 'OTHER OPERATING EXPENDITURE (OOE)',74 sy-vline,148 sy-vline.
*        WHEN 'D'.
*          WRITE :/ sy-vline,5 'D',10 'SALARY RECOVERABLE',74 sy-vline,148 sy-vline.
*        WHEN 'E'.
*          WRITE :/ sy-vline,5 'E',10 'DEDUCTIONS',74 sy-vline,148 sy-vline.
*        WHEN 'F'.

        WHEN 'A'.
          WRITE :/ sy-vline,5 TEXT-072,TEXT-067,74 sy-vline,148 sy-vline. "EXPENDITURE OF MAMPOWER (EOM)
        WHEN 'B'.
          WRITE :/ sy-vline,TEXT-073 UNDER TEXT-072,TEXT-068 UNDER TEXT-067,74 sy-vline,148 sy-vline."EXTERNAL ALLOWANCES (Deposit Account)
        WHEN 'C'.
          WRITE :/ sy-vline,TEXT-074 UNDER TEXT-072,TEXT-069 UNDER TEXT-067,74 sy-vline,148 sy-vline."OTHER OPERATING EXPENDITURE (OOE)
        WHEN 'D'.
          WRITE :/ sy-vline,TEXT-075 UNDER TEXT-072,TEXT-070 UNDER TEXT-067,74 sy-vline,148 sy-vline."SALARY RECOVERABLE
        WHEN 'E'.
          WRITE :/ sy-vline,TEXT-076 UNDER TEXT-072,TEXT-071 UNDER TEXT-067,74 sy-vline,148 sy-vline."DEDUCTIONS
        WHEN 'F'.

          NEW-LINE.
          CLEAR lwa_final_sub_tot2.
          LOOP AT it_final_sub_tot INTO lwa_final_sub_tot.
            IF lwa_final_sub_tot-sub_total = 'A4_TOTAL' OR
               lwa_final_sub_tot-sub_total = 'B1' OR
               lwa_final_sub_tot-sub_total = 'C_TOTAL' OR
               lwa_final_sub_tot-sub_total = 'D1'.
              lwa_final_sub_tot2-total_wage_pa  = lwa_final_sub_tot2-total_wage_pa  + lwa_final_sub_tot-total_wage_pa.
              lwa_final_sub_tot2-total_wage_tr  = lwa_final_sub_tot2-total_wage_tr  + lwa_final_sub_tot-total_wage_tr.
              lwa_final_sub_tot2-total_wage_cow = lwa_final_sub_tot2-total_wage_cow + lwa_final_sub_tot-total_wage_cow.
              lwa_final_sub_tot2-total_wage     = lwa_final_sub_tot2-total_wage     + lwa_final_sub_tot-total_wage.

*              lwa_final_sub_tot2-total_wage_pa1  = lwa_final_sub_tot2-total_wage_pa1  + lwa_final_sub_tot-total_wage_pa1.
*              lwa_final_sub_tot2-total_wage_tr1  = lwa_final_sub_tot2-total_wage_tr1  + lwa_final_sub_tot-total_wage_tr1.
*              lwa_final_sub_tot2-total_wage_cow1 = lwa_final_sub_tot2-total_wage_cow1 + lwa_final_sub_tot-total_wage_cow1.
*              lwa_final_sub_tot2-total_wage1     = lwa_final_sub_tot2-total_wage1     + lwa_final_sub_tot-total_wage1.

            ELSEIF lwa_final_sub_tot-sub_total = 'E1' OR
                   lwa_final_sub_tot-sub_total = 'E2'.
              lwa_final_sub_tot3-total_wage_pa  = lwa_final_sub_tot3-total_wage_pa  + lwa_final_sub_tot-total_wage_pa.
              lwa_final_sub_tot3-total_wage_tr  = lwa_final_sub_tot3-total_wage_tr  + lwa_final_sub_tot-total_wage_tr.
              lwa_final_sub_tot3-total_wage_cow = lwa_final_sub_tot3-total_wage_cow + lwa_final_sub_tot-total_wage_cow.
              lwa_final_sub_tot3-total_wage     = lwa_final_sub_tot3-total_wage     + lwa_final_sub_tot-total_wage.

*              lwa_final_sub_tot3-total_wage_pa1  = lwa_final_sub_tot3-total_wage_pa1  + lwa_final_sub_tot-total_wage_pa1.
*              lwa_final_sub_tot3-total_wage_tr1  = lwa_final_sub_tot3-total_wage_tr1  + lwa_final_sub_tot-total_wage_tr1.
*              lwa_final_sub_tot3-total_wage_cow1 = lwa_final_sub_tot3-total_wage_cow1 + lwa_final_sub_tot-total_wage_cow1.
*              lwa_final_sub_tot3-total_wage1     = lwa_final_sub_tot3-total_wage1     + lwa_final_sub_tot-total_wage1.

            ENDIF.
          ENDLOOP.
*TOTAL NET PAYMENT = TOTAL PAYMENTS (A1 TO A4, B, C and D) - TOTAL DEDUCTIONS (E1 TO E2)
          lwa_final_sub_tot4-total_wage_pa  = lwa_final_sub_tot2-total_wage_pa  - lwa_final_sub_tot3-total_wage_pa.
          lwa_final_sub_tot4-total_wage_tr  = lwa_final_sub_tot2-total_wage_tr  - lwa_final_sub_tot3-total_wage_tr.
          lwa_final_sub_tot4-total_wage_cow = lwa_final_sub_tot2-total_wage_cow - lwa_final_sub_tot3-total_wage_cow.
          lwa_final_sub_tot4-total_wage     = lwa_final_sub_tot2-total_wage     - lwa_final_sub_tot3-total_wage.

*          lwa_final_sub_tot4-total_wage_pa1  = lwa_final_sub_tot2-total_wage_pa1  - lwa_final_sub_tot3-total_wage_pa1.
*          lwa_final_sub_tot4-total_wage_tr1  = lwa_final_sub_tot2-total_wage_tr1  - lwa_final_sub_tot3-total_wage_tr1.
*          lwa_final_sub_tot4-total_wage_cow1 = lwa_final_sub_tot2-total_wage_cow1 - lwa_final_sub_tot3-total_wage_cow1.
*          lwa_final_sub_tot4-total_wage1     = lwa_final_sub_tot2-total_wage1     - lwa_final_sub_tot3-total_wage1.

*          WRITE :/ sy-vline,
*                   12 'TOTAL PAYMENTS (A1 TO A4, B, C and D)',
*                   74 sy-vline,
*                   75 lwa_final_sub_tot2-total_wage_pa,
*                   93 lwa_final_sub_tot2-total_wage_tr,
*                  110 lwa_final_sub_tot2-total_wage_cow,
*                  130 lwa_final_sub_tot2-total_wage,
*                  148 sy-vline.

          WRITE :/ sy-vline,
                   12 TEXT-082,"'TOTAL PAYMENTS (A1 TO A4, B, C and D)',
                   74 sy-vline,
                      lwa_final_sub_tot2-total_wage_pa  UNDER TEXT-061 RIGHT-JUSTIFIED,
                      lwa_final_sub_tot2-total_wage_tr  UNDER TEXT-062 RIGHT-JUSTIFIED,
                      lwa_final_sub_tot2-total_wage_cow UNDER TEXT-063 RIGHT-JUSTIFIED,
                      lwa_final_sub_tot2-total_wage     UNDER TEXT-064 RIGHT-JUSTIFIED,
                  148 sy-vline.

*                  150 sy-vline,
*                  151 lwa_final_sub_tot2-total_wage_pa1,
*                  169 lwa_final_sub_tot2-total_wage_tr1,
*                  186 lwa_final_sub_tot2-total_wage_cow1,
*                  206 lwa_final_sub_tot2-total_wage1,
*                  224 sy-vline.
*          WRITE :/ sy-vline,
*                   12 'TOTAL DEDUCTIONS (E1 TO E2)',
*                   74 sy-vline,
*                   75 lwa_final_sub_tot3-total_wage_pa,
*                   93 lwa_final_sub_tot3-total_wage_tr,
*                  110 lwa_final_sub_tot3-total_wage_cow,
*                  130 lwa_final_sub_tot3-total_wage,
*                  148 sy-vline.

          WRITE :/ sy-vline,
                      TEXT-083 UNDER TEXT-082,"'TOTAL DEDUCTIONS (E1 TO E2)',
                   74 sy-vline,
                      lwa_final_sub_tot3-total_wage_pa  UNDER TEXT-061 RIGHT-JUSTIFIED,
                      lwa_final_sub_tot3-total_wage_tr  UNDER TEXT-062 RIGHT-JUSTIFIED,
                      lwa_final_sub_tot3-total_wage_cow UNDER TEXT-063 RIGHT-JUSTIFIED,
                      lwa_final_sub_tot3-total_wage     UNDER TEXT-064 RIGHT-JUSTIFIED,
                  148 sy-vline.

*                  150 sy-vline,
*                  151 lwa_final_sub_tot3-total_wage_pa1,
*                  169 lwa_final_sub_tot3-total_wage_tr1,
*                  186 lwa_final_sub_tot3-total_wage_cow1,
*                  206 lwa_final_sub_tot3-total_wage1,
*                  224 sy-vline.

*          WRITE :/ sy-vline,
*                   12 'TOTAL NET PAYMENT',
*                   74 sy-vline,
*                   75 lwa_final_sub_tot4-total_wage_pa,
*                   93 lwa_final_sub_tot4-total_wage_tr,
*                  110 lwa_final_sub_tot4-total_wage_cow,
*                  130 lwa_final_sub_tot4-total_wage,
*                  148 sy-vline.

          WRITE :/ sy-vline,
                      TEXT-084 UNDER TEXT-083,"'TOTAL NET PAYMENT',
                   74 sy-vline,
                      lwa_final_sub_tot4-total_wage_pa  UNDER TEXT-061 RIGHT-JUSTIFIED,
                      lwa_final_sub_tot4-total_wage_tr  UNDER TEXT-062 RIGHT-JUSTIFIED,
                      lwa_final_sub_tot4-total_wage_cow UNDER TEXT-063 RIGHT-JUSTIFIED,
                      lwa_final_sub_tot4-total_wage     UNDER TEXT-064 RIGHT-JUSTIFIED,
                  148 sy-vline.

*                  150 sy-vline,
*                  151 lwa_final_sub_tot4-total_wage_pa1,
*                  169 lwa_final_sub_tot4-total_wage_tr1,
*                  186 lwa_final_sub_tot4-total_wage_cow1,
*                  206 lwa_final_sub_tot4-total_wage1,
*                  224 sy-vline.
          NEW-LINE.
          WRITE :/ sy-vline,10 'PAYMENT VIA:',74 sy-vline,148 sy-vline.
*Bank Transfer
          CLEAR lwa_final_tab.
          LOOP AT it_final_tab INTO lwa_final_tab WHERE lgart = '/559'.
            lwa_final_tab1-total_wage_pa  = lwa_final_tab1-total_wage_pa  + lwa_final_tab-total_wage_pa.
            lwa_final_tab1-total_wage_tr  = lwa_final_tab1-total_wage_tr  + lwa_final_tab-total_wage_tr.
            lwa_final_tab1-total_wage_cow = lwa_final_tab1-total_wage_cow + lwa_final_tab-total_wage_cow.
            lwa_final_tab1-total_wage     = lwa_final_tab1-total_wage     + lwa_final_tab-total_wage.

*            lwa_final_tab1-total_wage_pa1  = lwa_final_tab1-total_wage_pa1  + lwa_final_tab-total_wage_pa1.
*            lwa_final_tab1-total_wage_tr1  = lwa_final_tab1-total_wage_tr1  + lwa_final_tab-total_wage_tr1.
*            lwa_final_tab1-total_wage_cow1 = lwa_final_tab1-total_wage_cow1 + lwa_final_tab-total_wage_cow1.
*            lwa_final_tab1-total_wage1     = lwa_final_tab1-total_wage1     + lwa_final_tab-total_wage1.
          ENDLOOP.
*          WRITE :/ sy-vline,
*                   12 'BANK',
*                   65 '145017',
*                   74 sy-vline,
*                   75 lwa_final_tab1-total_wage_pa,
*                   93 lwa_final_tab1-total_wage_tr,
*                  110 lwa_final_tab1-total_wage_cow,
*                  130 lwa_final_tab1-total_wage,
*                  148 sy-vline."66 total_bank_transfer

          WRITE :/ sy-vline,
                      TEXT-085 UNDER TEXT-082,"'BANK',
                   65 '145017',
                   74 sy-vline,
                      lwa_final_tab1-total_wage_pa  UNDER TEXT-061 RIGHT-JUSTIFIED,
                      lwa_final_tab1-total_wage_tr  UNDER TEXT-062 RIGHT-JUSTIFIED,
                      lwa_final_tab1-total_wage_cow UNDER TEXT-063 RIGHT-JUSTIFIED,
                      lwa_final_tab1-total_wage     UNDER TEXT-064 RIGHT-JUSTIFIED,
                  148 sy-vline."66 total_bank_transfer

*                  150 sy-vline,
*                  151 lwa_final_tab1-total_wage_pa1,
*                  169 lwa_final_tab1-total_wage_tr1,
*                  186 lwa_final_tab1-total_wage_cow1,
*                  206 lwa_final_tab1-total_wage1,
*                  224 sy-vline.
*Cash Payment
          CLEAR lwa_final_tab.
          LOOP AT it_final_tab INTO lwa_final_tab WHERE lgart = '/557'.
            lwa_final_tab2-total_wage_pa  = lwa_final_tab2-total_wage_pa  + lwa_final_tab-total_wage_pa.
            lwa_final_tab2-total_wage_tr  = lwa_final_tab2-total_wage_tr  + lwa_final_tab-total_wage_tr.
            lwa_final_tab2-total_wage_cow = lwa_final_tab2-total_wage_cow + lwa_final_tab-total_wage_cow.
            lwa_final_tab2-total_wage     = lwa_final_tab2-total_wage     + lwa_final_tab-total_wage.

*            lwa_final_tab2-total_wage_pa1  = lwa_final_tab2-total_wage_pa1  + lwa_final_tab-total_wage_pa1.
*            lwa_final_tab2-total_wage_tr1  = lwa_final_tab2-total_wage_tr1  + lwa_final_tab-total_wage_tr1.
*            lwa_final_tab2-total_wage_cow1 = lwa_final_tab2-total_wage_cow1 + lwa_final_tab-total_wage_cow1.
*            lwa_final_tab2-total_wage1     = lwa_final_tab2-total_wage1     + lwa_final_tab-total_wage1.
          ENDLOOP.
          WRITE :/ sy-vline,
                      TEXT-086 UNDER TEXT-082,"'CHEQUE',
                   65 '145210',
                   74 sy-vline,
                   75 lwa_final_tab2-total_wage_pa,
                   93 lwa_final_tab2-total_wage_tr,
                  110 lwa_final_tab2-total_wage_cow,
                  130 lwa_final_tab2-total_wage,
                  148 sy-vline."66 total_cash_payment,
*                  150 sy-vline,
*                  151 lwa_final_tab2-total_wage_pa1,
*                  169 lwa_final_tab2-total_wage_tr1,
*                  186 lwa_final_tab2-total_wage_cow1,
*                  206 lwa_final_tab2-total_wage1,
*                  224 sy-vline.

          WRITE : / sy-uline(148).
          WRITE : / sy-vline,5 'F',10 'TOTAL COUNT OF STAFF PAID IN THE MONTH ',148 sy-vline.
          FORMAT INTENSIFIED OFF.
          WRITE : / sy-vline,148 sy-vline.
          WRITE : / sy-vline,5 '1',10 'PAYMENT TO STAFF VIA IBG', 77 lwa_month_i-ltx NO-GAP,in_per+0(4) LEFT-JUSTIFIED NO-GAP,'(In-Month)',148 sy-vline.
*                    152 lwa_month_f-ltx NO-GAP,fp_per+0(4) LEFT-JUSTIFIED NO-GAP,'(For-Month)',224 sy-vline.
          WRITE : / sy-vline, 24 'PERMANENT',     70 lwa_final_count-pymnt_ibg_pa,148 sy-vline.", 150 lwa_final_count-pymnt_ibg_pa1, 224 sy-vline.
          WRITE : / sy-vline, 24 'CLERK-OF-WORKS',70 lwa_final_count-pymnt_ibg_cow,148 sy-vline.",150 lwa_final_count-pymnt_ibg_cow1,224 sy-vline.
          WRITE : / sy-vline, 24 'TRAINERS',      70 lwa_final_count-pymnt_ibg_tr,148 sy-vline.", 150 lwa_final_count-pymnt_ibg_tr1, 224 sy-vline.
          WRITE : / sy-vline, 77 TEXT-055,148 sy-vline.",157 text-055,224 sy-vline.
          WRITE : / sy-vline, 70 lwa_final_count-tot_ibg,148 sy-vline.",150 lwa_final_count-tot_ibg1,224 sy-vline.
          WRITE : / sy-vline, 77 TEXT-055,148 sy-vline.",157 text-055,224 sy-vline.
          WRITE : / sy-vline,148 sy-vline.
          WRITE : / sy-vline, 5 '2',10 'PAYMENT TO STAFF VIA CHEQUE',148 sy-vline.",224 sy-vline.
          WRITE : / sy-vline, 24 'PERMANENT',     70 lwa_final_count-pymnt_chq_pa,148 sy-vline.",  150 lwa_final_count-pymnt_chq_pa1, 224 sy-vline.
          WRITE : / sy-vline, 24 'CLERK-OF-WORKS',70 lwa_final_count-pymnt_chq_cow,148 sy-vline.", 150 lwa_final_count-pymnt_chq_cow1,224 sy-vline.
          WRITE : / sy-vline, 77 TEXT-055,148 sy-vline.",157 text-055,224 sy-vline.
          WRITE : / sy-vline, 70 lwa_final_count-tot_chq,148 sy-vline.",150 lwa_final_count-tot_chq1,224 sy-vline.
          WRITE : / sy-vline, 77 TEXT-055,148 sy-vline.",157 text-055,224 sy-vline.

          WRITE : / sy-vline,148 sy-vline.
          WRITE : / sy-vline,5 '3',10 'TOTAL PAYOUT COUNT FOR PERMANENT STAFF EXCLUDING COW AND TR',148 sy-vline.",224 sy-vline.
          WRITE : / sy-vline, 24 'ACTUAL PAYOUT TO ACTIVE STAFF',
                              70 lwa_final_count-pymnt_ibg_pa,148 sy-vline.",150 lwa_final_count-pymnt_ibg_pa1,224 sy-vline.
          WRITE : / sy-vline, 24 'ADD: STAFF LEAVING IN PAYROLL MONTH (CHEQUE)',
                              70 lwa_final_count-pymnt_chq_pa,148 sy-vline.",  150 lwa_final_count-pymnt_chq_pa1,224 sy-vline.
          WRITE : / sy-vline, 77 TEXT-055,148 sy-vline.",157 text-055,224 sy-vline.
          WRITE : / sy-vline, 70 lwa_final_count-tot_pa,148 sy-vline.",150 lwa_final_count-tot_pa1,224 sy-vline.
          WRITE : / sy-vline, 77 TEXT-055,148 sy-vline.",157 text-055,224 sy-vline.

          WRITE : / sy-vline,5 '4',10 'TOTAL PAYOUT COUNT FOR THE MONTH (F1 TO F2)',
                           70 lwa_final_count-tot_count,148 sy-vline.",150 lwa_final_count-tot_count1,224 sy-vline.
          WRITE : / sy-vline,148 sy-vline.
          EXIT.
      ENDCASE.
    ENDAT.

    ON CHANGE OF lwa_sec_details-sec." or lwa_Sec_Details-sub_sec.
      FORMAT INTENSIFIED ON.
      CASE lwa_sec_details-main.
        WHEN 'A'.
          CASE lwa_sec_details-sec .
            WHEN '01'.
*              WRITE :/ sy-vline,10 lwa_sec_details-sec,text-078,74 sy-vline,148 sy-vline.
              WRITE :/ sy-vline,lwa_sec_details-sec UNDER TEXT-087,TEXT-078,74 sy-vline,148 sy-vline.
            WHEN '02'.
*              WRITE :/ sy-vline,10 lwa_sec_details-sec,text-079 UNDER text-078,74 sy-vline,148 sy-vline.
              WRITE :/ sy-vline,lwa_sec_details-sec UNDER TEXT-087,TEXT-079 UNDER TEXT-078,74 sy-vline,148 sy-vline.
*            WHEN '03'.
*              WRITE :/ sy-vline,10 lwa_sec_details-sec,'GRATUITY',148 sy-vline.
            WHEN '04'.
*              WRITE :/ sy-vline,10 lwa_sec_details-sec,text-080 UNDER text-078,74 sy-vline,148 sy-vline."'ALLOWANCES:'
              WRITE :/ sy-vline,lwa_sec_details-sec UNDER TEXT-087,TEXT-080 UNDER TEXT-078,74 sy-vline,148 sy-vline."'ALLOWANCES:'

            WHEN '05'.
*              WRITE :/ sy-vline,10 lwa_sec_details-sec,text-081 UNDER text-078,74 sy-vline,148 sy-vline."'EMPLOYER (E','YER',') STATUTORY CONTRIBUTION'
              WRITE :/ sy-vline,lwa_sec_details-sec UNDER TEXT-087,TEXT-081 UNDER TEXT-078,74 sy-vline,148 sy-vline."'EMPLOYER (E','YER',') STATUTORY CONTRIBUTION'

          ENDCASE.
        WHEN 'C'.
          CASE lwa_sec_details-sec .
            WHEN '01'.
*              WRITE :/ sy-vline,10 lwa_sec_details-sec,'AWARDS',74 sy-vline,148 sy-vline.
              WRITE :/ sy-vline,lwa_sec_details-sec UNDER TEXT-087,'AWARDS',74 sy-vline,148 sy-vline.
            WHEN '02'.
*              WRITE :/ sy-vline,10 lwa_sec_details-sec,'ESS CLAIMS',74 sy-vline,148 sy-vline.
              WRITE :/ sy-vline,lwa_sec_details-sec UNDER TEXT-087,'ESS CLAIMS',74 sy-vline,148 sy-vline.
          ENDCASE.
        WHEN 'E'.
          CASE lwa_sec_details-sec .
            WHEN '01'.
*              WRITE :/ sy-vline,10 lwa_sec_details-sec,'EMPLOYEE (E','YEE)', 'CPF',74 sy-vline,148 sy-vline.
              WRITE :/ sy-vline,lwa_sec_details-sec UNDER TEXT-087,'EMPLOYEE (E','YEE)', 'CPF',74 sy-vline,148 sy-vline.
            WHEN '02'.
*              WRITE :/ sy-vline,10 lwa_sec_details-sec,'OTHER STAFF DEDUCTIONS',74 sy-vline,148 sy-vline.
              WRITE :/ sy-vline,lwa_sec_details-sec UNDER TEXT-087,'OTHER STAFF DEDUCTIONS',74 sy-vline,148 sy-vline.
          ENDCASE.
      ENDCASE.
      FORMAT INTENSIFIED OFF.
    ENDON.
    CLEAR lv_sec_temp.
    lv_sec_temp = lwa_sec_details-sec.
    LOOP AT it_py_cfg INTO lwa_py_cfg WHERE main EQ lwa_sec_details-main AND
                                             sec EQ lwa_sec_details-sec  AND
                                         sub_sec EQ lwa_sec_details-sub_sec.
      IF lv_temp EQ 'X'.
        FORMAT INTENSIFIED ON.
        CASE lwa_sec_details-main.
          WHEN 'A'.
            CASE lwa_sec_details-sub_sec.
              WHEN '01'.
                WRITE :/ sy-vline,10 'a) RECURRING ALLOWANCES',74 sy-vline,148 sy-vline.
                CLEAR lv_temp.
              WHEN '02'.
                WRITE :/ sy-vline,10 'b)  ADDITIONAL/ONE TIME ALLOWANCE',74 sy-vline,148 sy-vline.
                CLEAR lv_temp.
              WHEN '03'.
                WRITE :/ sy-vline,10 'c) OVERTIME ALLOWANCE',74 sy-vline,148 sy-vline.
                CLEAR lv_temp.
              WHEN '04'.
                WRITE :/ sy-vline,10 'd) TRAINER HONARARIUM CLAIMS',74 sy-vline,148 sy-vline.
                CLEAR lv_temp.
              WHEN OTHERS.
                CLEAR lv_temp.
            ENDCASE.
          WHEN 'C'.
            CASE lwa_sec_details-sec.
              WHEN '1'.
                WRITE :/ sy-vline,10 lwa_sec_details-sec,'AWARDS',74 sy-vline,148 sy-vline.
                CLEAR lv_temp.
              WHEN '2'.
                CASE lwa_sec_details-sub_sec.
                  WHEN '01'.
                    WRITE :/ sy-vline,10 'STAFF DEVELOPMENT AND BENEFITS (OFI1)',74 sy-vline,148 sy-vline.
                    CLEAR lv_temp.
                  WHEN '02'.
                    WRITE :/ sy-vline,10 'REPAIR & MAINTENANCE (OFI2)',74 sy-vline,148 sy-vline.
                    CLEAR lv_temp.
                  WHEN '03'.
                    WRITE :/ sy-vline,10 'SUPPLIES AND MATERIALS (OFI4)',74 sy-vline,148 sy-vline.
                    CLEAR lv_temp.
                  WHEN '04'.
                    WRITE :/ sy-vline,10 'COMMUNICATION (OFI3)',74 sy-vline,148 sy-vline.
                    CLEAR lv_temp.
                  WHEN '05'.
                    WRITE :/ sy-vline,10 'TRANSPORTATION (OTRT)',74 sy-vline,148 sy-vline.
                    CLEAR lv_temp.
                  WHEN '06'.
                    WRITE :/ sy-vline,10 'OTHER EXPENSES (OFI5)',74 sy-vline,148 sy-vline.
                    CLEAR lv_temp.
                  WHEN '07'.
                    WRITE :/ sy-vline,10 'ADMINISTRATIVE EXPENSES (OFI6)',74 sy-vline,148 sy-vline.
                    CLEAR lv_temp.
                  WHEN '08'.
                    WRITE :/ sy-vline,10 'SUPPLIES AND MATERIALS (OFI8)',74 sy-vline,148 sy-vline.
                    CLEAR lv_temp.
                  WHEN '09'.
                    WRITE :/ sy-vline,10 'ACTIVITY & PROJECTS (OFI9)',74 sy-vline,148 sy-vline.
                    CLEAR lv_temp.
                ENDCASE.
            ENDCASE.
          WHEN 'E'.
            CASE lwa_sec_details-sec.
              WHEN '1'.
                WRITE :/ sy-vline,10 lwa_sec_details-sec,'EMPLOYEE (E','YEE)',' CPF',74 sy-vline,148 sy-vline.
                CLEAR lv_temp.
            ENDCASE.
        ENDCASE.
        FORMAT INTENSIFIED OFF.
      ENDIF.
      SORT it_final_tab BY lgart.
      CLEAR gwa_final_tab.
      READ TABLE it_final_tab INTO gwa_final_tab WITH KEY lgart = lwa_py_cfg-lgart ."BINARY SEARCH.
      IF sy-subrc EQ 0.
        LOOP AT it_final_tab INTO gwa_final_tab WHERE lgart = lwa_py_cfg-lgart .
          IF lv_lgart EQ gwa_final_tab-lgart.
            CLEAR gwa_final_tab-lgtxt.
          ELSE.
            lv_lgart = gwa_final_tab-lgart.
            gwa_final_tab-lgtxt = lwa_py_cfg-description.
          ENDIF.
          lwa_final_sub_tot-total_wage_pa  = lwa_final_sub_tot-total_wage_pa  + gwa_final_tab-total_wage_pa.
          lwa_final_sub_tot-total_wage_tr  = lwa_final_sub_tot-total_wage_tr  + gwa_final_tab-total_wage_tr.
          lwa_final_sub_tot-total_wage_cow = lwa_final_sub_tot-total_wage_cow + gwa_final_tab-total_wage_cow.
          lwa_final_sub_tot-total_wage     = lwa_final_sub_tot-total_wage     + gwa_final_tab-total_wage.

*          lwa_final_sub_tot-total_wage_pa1  = lwa_final_sub_tot-total_wage_pa1  + gwa_final_tab-total_wage_pa1.
*          lwa_final_sub_tot-total_wage_tr1  = lwa_final_sub_tot-total_wage_tr1  + gwa_final_tab-total_wage_tr1.
*          lwa_final_sub_tot-total_wage_cow1 = lwa_final_sub_tot-total_wage_cow1 + gwa_final_tab-total_wage_cow1.
*          lwa_final_sub_tot-total_wage1     = lwa_final_sub_tot-total_wage1     + gwa_final_tab-total_wage1.

          IF lwa_sec_details-main EQ 'A' AND lwa_sec_details-sec EQ '03'.
            WRITE :/ sy-vline.
            FORMAT COLOR = 4.
            FORMAT INTENSIFIED ON.
*            WRITE : 10  '03 GRATUITY         (A3)',
*                    55 gwa_final_tab-lgart,
*                    65 gwa_final_tab-acct,
*                    74 sy-vline,
*                    75 lwa_final_sub_tot-total_wage_pa,
*                    93 lwa_final_sub_tot-total_wage_tr,
*                   110 lwa_final_sub_tot-total_wage_cow,
*                   130 lwa_final_sub_tot-total_wage,
*                   148 sy-vline.

            WRITE :    TEXT-088 UNDER TEXT-087,"'03 GRATUITY         (A3)',
                       gwa_final_tab-lgart             UNDER TEXT-059,
                       gwa_final_tab-acct              UNDER TEXT-060,
                    74 sy-vline,
                       lwa_final_sub_tot-total_wage_pa  UNDER TEXT-061 RIGHT-JUSTIFIED,
                       lwa_final_sub_tot-total_wage_tr  UNDER TEXT-062 RIGHT-JUSTIFIED,
                       lwa_final_sub_tot-total_wage_cow UNDER TEXT-063 RIGHT-JUSTIFIED,
                       lwa_final_sub_tot-total_wage     UNDER TEXT-064 RIGHT-JUSTIFIED,
                   148 sy-vline.
*                   150 sy-vline,
*                   151 lwa_final_sub_tot-total_wage_pa1,
*                   169 lwa_final_sub_tot-total_wage_tr1,
*                   189 lwa_final_sub_tot-total_wage_cow1,
*                   206 lwa_final_sub_tot-total_wage1,
*                   224 sy-vline.

            FORMAT COLOR = 0.
            FORMAT INTENSIFIED OFF.
            CONCATENATE lwa_sec_details-main lv_sec_temp+1(1) INTO lwa_final_sub_tot-sub_total.
            APPEND lwa_final_sub_tot TO it_final_sub_tot.
            CLEAR lwa_final_sub_tot.
          ELSEIF lwa_sec_details-main EQ 'C' AND lwa_sec_details-sec EQ '02'. "do nothing
            lwa_final_sub_tot7-total_wage_pa  = lwa_final_sub_tot7-total_wage_pa  + gwa_final_tab-total_wage_pa.
            lwa_final_sub_tot7-total_wage_tr  = lwa_final_sub_tot7-total_wage_tr  + gwa_final_tab-total_wage_tr.
            lwa_final_sub_tot7-total_wage_cow = lwa_final_sub_tot7-total_wage_cow + gwa_final_tab-total_wage_cow.
            lwa_final_sub_tot7-total_wage     = lwa_final_sub_tot7-total_wage     + gwa_final_tab-total_wage.

*            lwa_final_sub_tot7-total_wage_pa1  = lwa_final_sub_tot7-total_wage_pa1  + gwa_final_tab-total_wage_pa1.
*            lwa_final_sub_tot7-total_wage_tr1  = lwa_final_sub_tot7-total_wage_tr1  + gwa_final_tab-total_wage_tr1.
*            lwa_final_sub_tot7-total_wage_cow1 = lwa_final_sub_tot7-total_wage_cow1 + gwa_final_tab-total_wage_cow1.
*            lwa_final_sub_tot7-total_wage1     = lwa_final_sub_tot7-total_wage1     + gwa_final_tab-total_wage1.

*            gwa_final_tab-lgtxt = lwa_py_cfg-description.
*            PERFORM write_data USING gwa_final_tab.
            PERFORM write_data_inper USING gwa_final_tab.

          ELSE.
*            gwa_final_tab-lgtxt = lwa_py_cfg-description.
*            PERFORM write_data USING gwa_final_tab.
            PERFORM write_data_inper USING gwa_final_tab.

          ENDIF.
        ENDLOOP.
      ELSE.
        CLEAR lwa_wt_gl_acc.
        READ TABLE it_wt_gl_acc INTO lwa_wt_gl_acc WITH KEY lgart = lwa_py_cfg-lgart.
        IF lwa_sec_details-main EQ 'A' AND lwa_sec_details-sec EQ '03'.
          WRITE :/ sy-vline.
          FORMAT COLOR = 4.
          FORMAT INTENSIFIED ON.
*          WRITE : 10   '03 GRATUITY         (A3)',
*                  55 lwa_py_cfg-lgart,
*                  65 lwa_wt_gl_acc-acct,
*                  74 sy-vline,
*                  75 lwa_final_sub_tot-total_wage_pa,
*                  93 lwa_final_sub_tot-total_wage_tr,
*                 110 lwa_final_sub_tot-total_wage_cow,
*                 130 lwa_final_sub_tot-total_wage,
*                 148 sy-vline.

          WRITE : 10   '03 GRATUITY         (A3)',
                     lwa_py_cfg-lgart               UNDER TEXT-059,
                     lwa_wt_gl_acc-acct             UNDER TEXT-060,
                  74 sy-vline,
                     lwa_final_sub_tot-total_wage_pa UNDER TEXT-061 RIGHT-JUSTIFIED,
                     lwa_final_sub_tot-total_wage_tr UNDER TEXT-062 RIGHT-JUSTIFIED,
                     lwa_final_sub_tot-total_wage_cow UNDER TEXT-063 RIGHT-JUSTIFIED,
                     lwa_final_sub_tot-total_wage     UNDER TEXT-064 RIGHT-JUSTIFIED,
                 148 sy-vline.

*                 150 sy-vline,
*                 151 lwa_final_sub_tot-total_wage_pa1,
*                 169 lwa_final_sub_tot-total_wage_tr1,
*                 186 lwa_final_sub_tot-total_wage_cow1,
*                 206 lwa_final_sub_tot-total_wage1,
*                 224 sy-vline.
          FORMAT COLOR = 0.
          FORMAT INTENSIFIED OFF.
          CONCATENATE lwa_sec_details-main lv_sec_temp+1(1) INTO lwa_final_sub_tot-sub_total.
          APPEND lwa_final_sub_tot TO it_final_sub_tot.
          CLEAR lwa_final_sub_tot.
        ELSE.
*          WRITE :/ sy-vline,
*                  12 lwa_py_cfg-description ,
*                  55 lwa_py_cfg-lgart,
*                  65 lwa_wt_gl_acc-acct,
*                  74 sy-vline,
*                 148 sy-vline.

          WRITE :/ sy-vline,
                     lwa_py_cfg-description UNDER TEXT-065,
                     lwa_py_cfg-lgart       UNDER TEXT-059,
                     lwa_wt_gl_acc-acct     UNDER TEXT-060,
                  74 sy-vline,
                 148 sy-vline.

*                 150 sy-vline,
*                 224 sy-vline.
        ENDIF.
      ENDIF.
    ENDLOOP.
    CONCATENATE lwa_sec_details-main lv_sec_temp+1(1) INTO lwa_final_sub_tot-sub_total.
    IF lwa_sec_details-main EQ 'A' AND lwa_sec_details-sec EQ '03'.
*do nothing,already A3 subtotal added
    ELSEIF lwa_sec_details-main EQ 'A' AND lwa_sec_details-sec EQ '04' AND lwa_sec_details-sub_sec LE '04'.
      FORMAT COLOR = 4.
*      WRITE :/ sy-vline,
*            74 sy-vline,
*            75 lwa_final_sub_tot-total_wage_pa,
*            93 lwa_final_sub_tot-total_wage_tr,
*           110 lwa_final_sub_tot-total_wage_cow,
*           130 lwa_final_sub_tot-total_wage,
*           148 sy-vline.
      WRITE :/ sy-vline,
            74 sy-vline,
               lwa_final_sub_tot-total_wage_pa  UNDER TEXT-061 RIGHT-JUSTIFIED,
               lwa_final_sub_tot-total_wage_tr  UNDER TEXT-062 RIGHT-JUSTIFIED,
               lwa_final_sub_tot-total_wage_cow UNDER TEXT-063 RIGHT-JUSTIFIED,
               lwa_final_sub_tot-total_wage     UNDER TEXT-064 RIGHT-JUSTIFIED,
           148 sy-vline.

*           150 sy-vline,
*           151 lwa_final_sub_tot-total_wage_pa1,
*           169 lwa_final_sub_tot-total_wage_tr1,
*           186 lwa_final_sub_tot-total_wage_cow1,
*           206 lwa_final_sub_tot-total_wage1,
*           224 sy-vline.
      FORMAT COLOR = 0.

      APPEND lwa_final_sub_tot TO it_final_sub_tot.
      CLEAR lwa_final_sub_tot.
      IF lwa_sec_details-sub_sec EQ '04'.
        FORMAT COLOR = 4.
        CLEAR lwa_final_sub_tot6.
        LOOP AT it_final_sub_tot INTO lwa_final_sub_tot.
          IF lwa_final_sub_tot-sub_total EQ 'A4'.
            lwa_final_sub_tot6-total_wage_pa  = lwa_final_sub_tot6-total_wage_pa  + lwa_final_sub_tot-total_wage_pa.
            lwa_final_sub_tot6-total_wage_tr  = lwa_final_sub_tot6-total_wage_tr  + lwa_final_sub_tot-total_wage_tr.
            lwa_final_sub_tot6-total_wage_cow = lwa_final_sub_tot6-total_wage_cow + lwa_final_sub_tot-total_wage_cow.
            lwa_final_sub_tot6-total_wage     = lwa_final_sub_tot6-total_wage     + lwa_final_sub_tot-total_wage.

*            lwa_final_sub_tot6-total_wage_pa1  = lwa_final_sub_tot6-total_wage_pa1  + lwa_final_sub_tot-total_wage_pa1.
*            lwa_final_sub_tot6-total_wage_tr1  = lwa_final_sub_tot6-total_wage_tr1  + lwa_final_sub_tot-total_wage_tr1.
*            lwa_final_sub_tot6-total_wage_cow1 = lwa_final_sub_tot6-total_wage_cow1 + lwa_final_sub_tot-total_wage_cow1.
*            lwa_final_sub_tot6-total_wage1     = lwa_final_sub_tot6-total_wage1     + lwa_final_sub_tot-total_wage1.

          ENDIF.
          AT LAST.
            SUM.
*            WRITE :/ sy-vline,
*                  30 'SUB-TOTAL(', 'A4 )',
*                  74 sy-vline,
*                  75 lwa_final_sub_tot6-total_wage_pa,
*                  93 lwa_final_sub_tot6-total_wage_tr,
*                 110 lwa_final_sub_tot6-total_wage_cow,
*                 130 lwa_final_sub_tot6-total_wage,
*                 148 sy-vline.

            WRITE :/ sy-vline,
                  30 'SUB-TOTAL(', 'A4 )',
                  74 sy-vline,
                     lwa_final_sub_tot6-total_wage_pa  UNDER TEXT-061 RIGHT-JUSTIFIED,
                     lwa_final_sub_tot6-total_wage_tr  UNDER TEXT-062 RIGHT-JUSTIFIED,
                     lwa_final_sub_tot6-total_wage_cow UNDER TEXT-063 RIGHT-JUSTIFIED,
                     lwa_final_sub_tot6-total_wage     UNDER TEXT-064 RIGHT-JUSTIFIED,
                 148 sy-vline.

*                 150 sy-vline,
*                 151 lwa_final_sub_tot6-total_wage_pa1,
*                 169 lwa_final_sub_tot6-total_wage_tr1,
*                 186 lwa_final_sub_tot6-total_wage_cow1,
*                 206 lwa_final_sub_tot6-total_wage1,
*                 224 sy-vline.
            FORMAT COLOR = 0.
            lwa_final_sub_tot-sub_total = 'A4_TOTAL'.
            FORMAT COLOR = 4.
            FORMAT INTENSIFIED ON.
*            WRITE :/ sy-vline,
*                          12 'TOTAL SALARIES & WAGES ,BONUS and ALLOWANCES (A1 TO A4)',
*                          74 sy-vline,
*                          75 lwa_final_sub_tot-total_wage_pa,
*                          93 lwa_final_sub_tot-total_wage_tr,
*                         110 lwa_final_sub_tot-total_wage_cow,
*                         130 lwa_final_sub_tot-total_wage,
*                         148 sy-vline.

            WRITE :/ sy-vline,
                          12 'TOTAL SALARIES & WAGES ,BONUS and ALLOWANCES (A1 TO A4)',
                          74 sy-vline,
                             lwa_final_sub_tot-total_wage_pa  UNDER TEXT-061 RIGHT-JUSTIFIED,
                             lwa_final_sub_tot-total_wage_tr  UNDER TEXT-062 RIGHT-JUSTIFIED,
                             lwa_final_sub_tot-total_wage_cow UNDER TEXT-063 RIGHT-JUSTIFIED,
                             lwa_final_sub_tot-total_wage     UNDER TEXT-064 RIGHT-JUSTIFIED,
                         148 sy-vline.

*                         150 sy-vline,
*                         151 lwa_final_sub_tot-total_wage_pa1,
*                         169 lwa_final_sub_tot-total_wage_tr1,
*                         186 lwa_final_sub_tot-total_wage_cow1,
*                         206 lwa_final_sub_tot-total_wage1,
*                         224 sy-vline.
            FORMAT INTENSIFIED OFF.
            FORMAT COLOR = 0.
            APPEND lwa_final_sub_tot TO it_final_sub_tot.
            CLEAR lwa_final_sub_tot.
            EXIT.
          ENDAT.
        ENDLOOP.
      ENDIF.
    ELSEIF lwa_sec_details-main EQ 'A' AND lwa_sec_details-sec EQ '05'.
      lwa_final_sub_tot-total_wage_pa  = lwa_final_sub_tot-total_wage_pa  + gwa_final_tab-total_wage_pa.
      lwa_final_sub_tot-total_wage_tr  = lwa_final_sub_tot-total_wage_tr  + gwa_final_tab-total_wage_tr.
      lwa_final_sub_tot-total_wage_cow = lwa_final_sub_tot-total_wage_cow + gwa_final_tab-total_wage_cow.
      lwa_final_sub_tot-total_wage     = lwa_final_sub_tot-total_wage     + gwa_final_tab-total_wage.

*      lwa_final_sub_tot-total_wage_pa1  = lwa_final_sub_tot-total_wage_pa1  + gwa_final_tab-total_wage_pa1.
*      lwa_final_sub_tot-total_wage_tr1  = lwa_final_sub_tot-total_wage_tr1  + gwa_final_tab-total_wage_tr1.
*      lwa_final_sub_tot-total_wage_cow1 = lwa_final_sub_tot-total_wage_cow1 + gwa_final_tab-total_wage_cow1.
*      lwa_final_sub_tot-total_wage1     = lwa_final_sub_tot-total_wage1     + gwa_final_tab-total_wage1.

      FORMAT COLOR = 4.
*      FORMAT INTENSIFIED ON.
*      WRITE :/ sy-vline,
*            12 text-050,"TOTAL E'YER STATUTORY CONTRIBUTION (A5)
*            74 sy-vline,
*            75 lwa_final_sub_tot-total_wage_pa,
*            93 lwa_final_sub_tot-total_wage_tr,
*           110 lwa_final_sub_tot-total_wage_cow,
*           130 lwa_final_sub_tot-total_wage,
*           148 sy-vline.

      WRITE :/ sy-vline,
            12 TEXT-050,"TOTAL E'YER STATUTORY CONTRIBUTION (A5)
            74 sy-vline,
               lwa_final_sub_tot-total_wage_pa  UNDER TEXT-061 RIGHT-JUSTIFIED,
               lwa_final_sub_tot-total_wage_tr  UNDER TEXT-062 RIGHT-JUSTIFIED,
               lwa_final_sub_tot-total_wage_cow UNDER TEXT-063 RIGHT-JUSTIFIED,
               lwa_final_sub_tot-total_wage     UNDER TEXT-064 RIGHT-JUSTIFIED,
           148 sy-vline.

*           150 sy-vline,
*           151 lwa_final_sub_tot-total_wage_pa1,
*           169 lwa_final_sub_tot-total_wage_tr1,
*           186 lwa_final_sub_tot-total_wage_cow1,
*           206 lwa_final_sub_tot-total_wage1,
*           224 sy-vline.
*      FORMAT INTENSIFIED OFF.
      FORMAT COLOR = 0.
      APPEND lwa_final_sub_tot TO it_final_sub_tot.

      "TOTAL EOM (A1 TO A5)
      READ TABLE it_final_sub_tot INTO lwa_final_sub_tot1 WITH KEY sub_total = 'A4_TOTAL'.
      IF sy-subrc EQ 0.
      ENDIF.
      lwa_final_sub_tot-sub_total = 'A1_A5_TOTAL'.
      lwa_final_sub_tot-total_wage_pa  = lwa_final_sub_tot-total_wage_pa  + lwa_final_sub_tot1-total_wage_pa.
      lwa_final_sub_tot-total_wage_tr  = lwa_final_sub_tot-total_wage_tr  + lwa_final_sub_tot1-total_wage_tr.
      lwa_final_sub_tot-total_wage_cow = lwa_final_sub_tot-total_wage_cow + lwa_final_sub_tot1-total_wage_cow.
      lwa_final_sub_tot-total_wage     = lwa_final_sub_tot-total_wage     + lwa_final_sub_tot1-total_wage.

*      lwa_final_sub_tot-total_wage_pa1  = lwa_final_sub_tot-total_wage_pa1  + lwa_final_sub_tot1-total_wage_pa1.
*      lwa_final_sub_tot-total_wage_tr1  = lwa_final_sub_tot-total_wage_tr1  + lwa_final_sub_tot1-total_wage_tr1.
*      lwa_final_sub_tot-total_wage_cow1 = lwa_final_sub_tot-total_wage_cow1 + lwa_final_sub_tot1-total_wage_cow1.
*      lwa_final_sub_tot-total_wage1     = lwa_final_sub_tot-total_wage1     + lwa_final_sub_tot1-total_wage1.

      FORMAT COLOR = 4.
      FORMAT INTENSIFIED ON.
*      WRITE :/ sy-vline,
*            12 text-051,"TOTAL EOM (A1 TO A5)
*            74 sy-vline,
*            75 lwa_final_sub_tot-total_wage_pa,
*            93 lwa_final_sub_tot-total_wage_tr,
*           110 lwa_final_sub_tot-total_wage_cow,
*           130 lwa_final_sub_tot-total_wage,
*           148 sy-vline.

      WRITE :/ sy-vline,
            12 TEXT-051,"TOTAL EOM (A1 TO A5)
            74 sy-vline,
               lwa_final_sub_tot-total_wage_pa  UNDER TEXT-061 RIGHT-JUSTIFIED,
               lwa_final_sub_tot-total_wage_tr  UNDER TEXT-062 RIGHT-JUSTIFIED,
               lwa_final_sub_tot-total_wage_cow UNDER TEXT-063 RIGHT-JUSTIFIED,
               lwa_final_sub_tot-total_wage     UNDER TEXT-064 RIGHT-JUSTIFIED,
           148 sy-vline.

*           150 sy-vline,
*           151 lwa_final_sub_tot-total_wage_pa1,
*           169 lwa_final_sub_tot-total_wage_tr1,
*           186 lwa_final_sub_tot-total_wage_cow1,
*           206 lwa_final_sub_tot-total_wage1,
*           224 sy-vline.
      FORMAT INTENSIFIED OFF.
      FORMAT COLOR = 0.
      APPEND lwa_final_sub_tot TO it_final_sub_tot.
      CLEAR lwa_final_sub_tot.
    ELSEIF lwa_sec_details-main EQ 'B'.
      WRITE :/ sy-vline.
      FORMAT COLOR = 4.
      FORMAT INTENSIFIED ON.
*      WRITE : 12 'TOTAL EXTERNAL ALLOWANCES (B)',
*              74 sy-vline,
*              75 lwa_final_sub_tot-total_wage_pa,
*              93 lwa_final_sub_tot-total_wage_tr,
*             110 lwa_final_sub_tot-total_wage_cow,
*             130 lwa_final_sub_tot-total_wage,
*             148 sy-vline.

      WRITE : 12 'TOTAL EXTERNAL ALLOWANCES (B)',
              74 sy-vline,
                 lwa_final_sub_tot-total_wage_pa  UNDER TEXT-061 RIGHT-JUSTIFIED,
                 lwa_final_sub_tot-total_wage_tr  UNDER TEXT-062 RIGHT-JUSTIFIED,
                 lwa_final_sub_tot-total_wage_cow UNDER TEXT-063 RIGHT-JUSTIFIED,
                 lwa_final_sub_tot-total_wage     UNDER TEXT-064 RIGHT-JUSTIFIED,
             148 sy-vline.

*             150 sy-vline,
*             151 lwa_final_sub_tot-total_wage_pa1,
*             169 lwa_final_sub_tot-total_wage_tr1,
*             186 lwa_final_sub_tot-total_wage_cow1,
*             206 lwa_final_sub_tot-total_wage1,
*             224 sy-vline.
      FORMAT INTENSIFIED OFF.
      FORMAT COLOR = 0.
      APPEND lwa_final_sub_tot TO it_final_sub_tot.
      CLEAR lwa_final_sub_tot.
    ELSEIF lwa_sec_details-main EQ 'C' AND lwa_sec_details-sec EQ '02' AND lwa_sec_details-sub_sec LE '09'.
      WRITE :/ sy-vline.
      FORMAT COLOR = 4.
*      WRITE : 74 sy-vline,
*              75 lwa_final_sub_tot7-total_wage_pa,
*              93 lwa_final_sub_tot7-total_wage_tr,
*             110 lwa_final_sub_tot7-total_wage_cow,
*             130 lwa_final_sub_tot7-total_wage,
*             148 sy-vline.

      WRITE : 74 sy-vline,
                 lwa_final_sub_tot7-total_wage_pa  UNDER TEXT-061 RIGHT-JUSTIFIED,
                 lwa_final_sub_tot7-total_wage_tr  UNDER TEXT-062 RIGHT-JUSTIFIED,
                 lwa_final_sub_tot7-total_wage_cow UNDER TEXT-063 RIGHT-JUSTIFIED,
                 lwa_final_sub_tot7-total_wage     UNDER TEXT-064 RIGHT-JUSTIFIED,
             148 sy-vline.

*             150 sy-vline,
*             151 lwa_final_sub_tot7-total_wage_pa1,
*             169 lwa_final_sub_tot7-total_wage_tr1,
*             186 lwa_final_sub_tot7-total_wage_cow1,
*             206 lwa_final_sub_tot7-total_wage1,
*             224 sy-vline.
      CLEAR lwa_final_sub_tot7.
      FORMAT COLOR = 0.

      IF lwa_sec_details-sub_sec EQ '09'.
        FORMAT COLOR = 4.
*        WRITE :/ sy-vline,
*              30 'SUB-TOTAL(', lwa_final_sub_tot-sub_total, ')',
*              74 sy-vline,
*              75 lwa_final_sub_tot-total_wage_pa,
*              93 lwa_final_sub_tot-total_wage_tr,
*             110 lwa_final_sub_tot-total_wage_cow,
*             130 lwa_final_sub_tot-total_wage,
*             148 sy-vline.

        WRITE :/ sy-vline,
              30 'SUB-TOTAL(', lwa_final_sub_tot-sub_total, ')',
              74 sy-vline,
                 lwa_final_sub_tot-total_wage_pa  UNDER TEXT-061 RIGHT-JUSTIFIED,
                 lwa_final_sub_tot-total_wage_tr  UNDER TEXT-062 RIGHT-JUSTIFIED,
                 lwa_final_sub_tot-total_wage_cow UNDER TEXT-063 RIGHT-JUSTIFIED,
                 lwa_final_sub_tot-total_wage     UNDER TEXT-064 RIGHT-JUSTIFIED,
             148 sy-vline.

*             150 sy-vline,
*             151 lwa_final_sub_tot-total_wage_pa1,
*             169 lwa_final_sub_tot-total_wage_tr1,
*             186 lwa_final_sub_tot-total_wage_cow1,
*             206 lwa_final_sub_tot-total_wage1,
*             224 sy-vline.
        FORMAT COLOR = 0.

        APPEND lwa_final_sub_tot TO it_final_sub_tot.
        CLEAR : lwa_final_sub_tot,lwa_final_sub_tot5.
        LOOP AT it_final_sub_tot INTO lwa_final_sub_tot5 WHERE sub_total EQ 'C1' OR sub_total EQ 'C2'.
          lwa_final_sub_tot-total_wage_pa  = lwa_final_sub_tot-total_wage_pa  + lwa_final_sub_tot5-total_wage_pa.
          lwa_final_sub_tot-total_wage_tr  = lwa_final_sub_tot-total_wage_tr  + lwa_final_sub_tot5-total_wage_tr.
          lwa_final_sub_tot-total_wage_cow = lwa_final_sub_tot-total_wage_cow + lwa_final_sub_tot5-total_wage_cow.
          lwa_final_sub_tot-total_wage     = lwa_final_sub_tot-total_wage     + lwa_final_sub_tot5-total_wage.

*          lwa_final_sub_tot-total_wage_pa1  = lwa_final_sub_tot-total_wage_pa1  + lwa_final_sub_tot5-total_wage_pa1.
*          lwa_final_sub_tot-total_wage_tr1  = lwa_final_sub_tot-total_wage_tr1  + lwa_final_sub_tot5-total_wage_tr1.
*          lwa_final_sub_tot-total_wage_cow1 = lwa_final_sub_tot-total_wage_cow1 + lwa_final_sub_tot5-total_wage_cow1.
*          lwa_final_sub_tot-total_wage1     = lwa_final_sub_tot-total_wage1     + lwa_final_sub_tot5-total_wage1.

        ENDLOOP.
        lwa_final_sub_tot-sub_total = 'C_TOTAL'.
        FORMAT COLOR = 4.
        FORMAT INTENSIFIED ON.
*        WRITE :/ sy-vline,
*                      12 'TOTAL OOE (C1 TO C2)',
*                      74 sy-vline,
*                      75 lwa_final_sub_tot-total_wage_pa,
*                      93 lwa_final_sub_tot-total_wage_tr,
*                     110 lwa_final_sub_tot-total_wage_cow,
*                     130 lwa_final_sub_tot-total_wage,
*                     148 sy-vline.

        WRITE :/ sy-vline,
                      12 'TOTAL OOE (C1 TO C2)',
                      74 sy-vline,
                         lwa_final_sub_tot-total_wage_pa  UNDER TEXT-061 RIGHT-JUSTIFIED,
                         lwa_final_sub_tot-total_wage_tr  UNDER TEXT-062 RIGHT-JUSTIFIED,
                         lwa_final_sub_tot-total_wage_cow UNDER TEXT-063 RIGHT-JUSTIFIED,
                         lwa_final_sub_tot-total_wage     UNDER TEXT-064 RIGHT-JUSTIFIED,
                     148 sy-vline.

*                     150 sy-vline,
*                     151 lwa_final_sub_tot-total_wage_pa1,
*                     169 lwa_final_sub_tot-total_wage_tr1,
*                     186 lwa_final_sub_tot-total_wage_cow1,
*                     206 lwa_final_sub_tot-total_wage1,
*                     224 sy-vline.
        FORMAT INTENSIFIED OFF.
        FORMAT COLOR = 0.
        APPEND lwa_final_sub_tot TO it_final_sub_tot.
        CLEAR lwa_final_sub_tot.
      ENDIF.
    ELSEIF lwa_sec_details-main EQ 'D'."SALARY RECOVERABLE
      WRITE :/ sy-vline.
      FORMAT COLOR = 4.
      FORMAT INTENSIFIED ON.
*      WRITE : 74 sy-vline,
*              75 lwa_final_sub_tot-total_wage_pa,
*              93 lwa_final_sub_tot-total_wage_tr,
*             110 lwa_final_sub_tot-total_wage_cow,
*             130 lwa_final_sub_tot-total_wage,
*             148 sy-vline.

      WRITE : 74 sy-vline,
                 lwa_final_sub_tot-total_wage_pa  UNDER TEXT-061 RIGHT-JUSTIFIED,
                 lwa_final_sub_tot-total_wage_tr  UNDER TEXT-062 RIGHT-JUSTIFIED,
                 lwa_final_sub_tot-total_wage_cow UNDER TEXT-063 RIGHT-JUSTIFIED,
                 lwa_final_sub_tot-total_wage     UNDER TEXT-064 RIGHT-JUSTIFIED,
             148 sy-vline.

*             150 sy-vline,
*             151 lwa_final_sub_tot-total_wage_pa1,
*             169 lwa_final_sub_tot-total_wage_tr1,
*             186 lwa_final_sub_tot-total_wage_cow1,
*             206 lwa_final_sub_tot-total_wage1,
*             224 sy-vline.
      FORMAT INTENSIFIED OFF.
      FORMAT COLOR = 0.
      APPEND lwa_final_sub_tot TO it_final_sub_tot.
      CLEAR lwa_final_sub_tot.
    ELSEIF lwa_sec_details-main EQ 'F'."PAYMENT VIA:
*do nothing
    ELSE.
      WRITE :/ sy-vline.
      FORMAT COLOR = 4.
*      FORMAT INTENSIFIED ON.
*      WRITE : 30 'SUB-TOTAL(', lwa_final_sub_tot-sub_total, ')',
*              74 sy-vline,
*              75 lwa_final_sub_tot-total_wage_pa,
*              93 lwa_final_sub_tot-total_wage_tr,
*             110 lwa_final_sub_tot-total_wage_cow,
*             130 lwa_final_sub_tot-total_wage,
*             148 sy-vline.

      WRITE : 30 'SUB-TOTAL(', lwa_final_sub_tot-sub_total, ')',
              74 sy-vline,
                 lwa_final_sub_tot-total_wage_pa  UNDER TEXT-061 RIGHT-JUSTIFIED,
                 lwa_final_sub_tot-total_wage_tr  UNDER TEXT-062 RIGHT-JUSTIFIED,
                 lwa_final_sub_tot-total_wage_cow UNDER TEXT-063 RIGHT-JUSTIFIED,
                 lwa_final_sub_tot-total_wage     UNDER TEXT-064 RIGHT-JUSTIFIED,
             148 sy-vline.

*             150 sy-vline,
*             151 lwa_final_sub_tot-total_wage_pa1,
*             169 lwa_final_sub_tot-total_wage_tr1,
*             186 lwa_final_sub_tot-total_wage_cow1,
*             206 lwa_final_sub_tot-total_wage1,
*             224 sy-vline.
*      FORMAT INTENSIFIED OFF.
      FORMAT COLOR = 0.
      APPEND lwa_final_sub_tot TO it_final_sub_tot.
      CLEAR lwa_final_sub_tot.
    ENDIF.
  ENDLOOP.
  WRITE :/ sy-uline(148).
  STOP.
ENDFORM.                    " WRITE_OUTPUT_INPER
*&---------------------------------------------------------------------*
*&      Form  WRITE_DATA_INPER
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_GWA_FINAL_TAB  text
*----------------------------------------------------------------------*
FORM write_data_inper  USING p_final_tab TYPE ty_final_tab.
*  WRITE :/ sy-vline,
*          12 p_final_tab-lgtxt,
*          55 p_final_tab-lgart,
*          65 p_final_tab-acct,
*          74 sy-vline,
*          75 p_final_tab-total_wage_pa,
*          93 p_final_tab-total_wage_tr,
*         110 p_final_tab-total_wage_cow,
*         130 p_final_tab-total_wage,
*         148 sy-vline.

  WRITE :/ sy-vline,
                  p_final_tab-lgtxt UNDER TEXT-065,
             (10) p_final_tab-lgart UNDER TEXT-059,
             (10) p_final_tab-acct UNDER TEXT-060,
             74 sy-vline,
              p_final_tab-total_wage_pa UNDER TEXT-061 RIGHT-JUSTIFIED,
              p_final_tab-total_wage_tr UNDER TEXT-062 RIGHT-JUSTIFIED,
              p_final_tab-total_wage_cow UNDER TEXT-063 RIGHT-JUSTIFIED,
              p_final_tab-total_wage UNDER TEXT-064 RIGHT-JUSTIFIED,
         148 sy-vline.

ENDFORM.                    " WRITE_DATA_INPER
