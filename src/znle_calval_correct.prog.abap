*&---------------------------------------------------------------------*
*& Report  ZISU_CALVAL_CORRECT                                     *
*&---------------------------------------------------------------------*
*& DESCRIPTION:                                                        *
*&              Finds nonbilled meterreadings where consumption and    *
*&              consumption for billing are alike.                     *
*&              The meterreadings are then corrected                   *
*&                                                                     *
*&---------------------------------------------------------------------*
*&                                                                     *
*& Programmer : Helene Bløcher, DONG Energy                            *
*&              HELBL                                                  *
*&----------------------------Corrections------------------------------*
*& Date        Userid Description                                      *
*& 14.05.2009  helbl  Created                                          *
*&---------------------------------------------------------------------*
*&                                                                     *
*&---------------------------------------------------------------------*
*++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*
* CHANGE ID : HANA-001
*1.) ACC11346068
       bhardwaa                             cr0093193* 24.05.2017
* TR : S7HK900166
* DESCRIPTION: HANA CORRECTION
* TEAM : HANA-MIGRATION
*++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*
REPORT  zisu_calval_correct  NO STANDARD PAGE HEADING
                     LINE-SIZE 150
                     LINE-COUNT 55.
       .

       Tables: eablg, eanlh.

       TYPES: begin of z_eabldat,
                anlage          type eablg-anlage,
                ablesgr         type eablg-ablesgr,
                equnr           type eabl-equnr,
                zwnummer        type eabl-zwnummer,
                ablbelnr        type eabl-ablbelnr,
                adatsoll        type eabl-adatsoll,
                adat            type eabl-adat,
                atim            type eabl-atim,
                v_zwstand       type eabl-v_zwstand,
                v_zwstndab      type eabl-v_zwstndab,
                n_zwstndab      type eabl-n_zwstndab,
                ablstat         type eabl-ablstat,
                adatreal        type eabl-adatreal,
                atimreal        type eabl-atimreal,
                bp              type eabl-bp,
                tariftyp        type eanlh-tariftyp,
                ext_ui          type euitrans-ext_ui,
                calor_area      type etdz-calor_area,
                brennwte        type te449-brennwte,
                prev_adat       type eabl-adat,
                prev_atim       type eabl-atim,
                prev_v_zwstand  type eabl-v_zwstndab,
                prev_n_zwstand  type eabl-n_zwstndab,
                prev_ablesgr    type eablg-ablesgr,
                consumption     type eablh-i_zwsterw,
                new_consumption type i,
              end of z_eabldat.

       DATA: lt_eabldat type table of z_eabldat.

       FIELD-SYMBOLS: <fs_eabldat> type z_eabldat.

       DATA: lv_mr_date_from type d,
             lv_mr_date_to   type d.

       DATA: lv_datmoja  type te449-datmoja.

       DATA: lv_tt type vvisrzk-rzday.

       DATA: lt_bapieablu type table of bapieablu.
       DATA: lt_return type table of bapireturn1.

       DATA:   BEGIN OF bdcdata OCCURS 0.
           INCLUDE STRUCTURE bdcdata.
       DATA:   END OF bdcdata.

       DATA:   BEGIN OF opt.
           INCLUDE STRUCTURE ctu_params.
       DATA:   END OF opt.

       DATA:   BEGIN OF lt_messtab OCCURS 0.
           INCLUDE STRUCTURE bdcmsgcoll.
       DATA:   END OF lt_messtab.

       DATA: l_text TYPE t100-text.

       DATA: lv_conv_date(8) type c.

       DATA: lv_cons(16) type c.

       DATA: lt_eablg type table of eablg.

       DATA: lv_prev_no_good(1) type c.

       DATA: la_calval_m3 type zisu_calval_m3.

       DATA: lv_total_period type i.

       DATA: lv_startdate type d.

       DATA: lv_year(4)  type n,
             lv_month(2) type n.

       DATA: lv_brennwte       type te449-brennwte,
             lv_total_brennwte type dec_16_06_s.

       DATA: lv_thgver type eadz-thgver.

       selection-screen begin of block block1 with frame title TEXT-s01.

       selection-screen skip 1.


       parameters: p_month(2) type n obligatory.
       parameters: p_year(4) type n obligatory.

       select-options: s_anlage for eablg-anlage.
       select-options: s_tarif for eanlh-tariftyp obligatory.

       selection-screen skip 1.

       selection-screen end of block block1.

       selection-screen begin of block block2 with frame title TEXT-s02.
       selection-screen end of block block2.


       selection-screen begin of block scr3 with frame title TEXT-s03.
       selection-screen comment /01(75) TEXT-b01.
       selection-screen comment /01(75) TEXT-b02.
       selection-screen comment /01(75) TEXT-b03.
       selection-screen comment /01(75) TEXT-b04.
       selection-screen comment /01(75) TEXT-b05.
       selection-screen end of block scr3.

* Set the from and to dates

       concatenate p_year p_month '01' into lv_mr_date_from.

       CALL FUNCTION 'RE_LAST_DAY_OF_MONTH'
         EXPORTING
           i_datum = lv_mr_date_from
         IMPORTING
*          E_KZ_ULT       =
           e_tt    = lv_tt.
       concatenate p_year p_month lv_tt into lv_mr_date_to.

* Find the meterreadings which should be corrected

       select  eablg~anlage
               eablg~ablesgr
               eabl~equnr
               eabl~zwnummer
               eabl~ablbelnr
               eabl~adatsoll
               eabl~adat
               eabl~atim
               eabl~v_zwstand
               eabl~v_zwstndab
               eabl~n_zwstndab
               eabl~ablstat
               eabl~adatreal
               eabl~atimreal
               eabl~bp
               eanlh~tariftyp
*        etdz~calor_area
       into   table lt_eabldat
       from   eabl
       inner  join eablg
       on     eablg~ablbelnr = eabl~ablbelnr
       inner  join eanl
       on     eanl~anlage = eablg~anlage
       inner  join eanlh
       on     eanlh~anlage = eanl~anlage
*inner  join etdz
*on     etdz~equnr = eabl~equnr
*and    etdz~zwnummer = eabl~zwnummer
       where  eablg~anlage in s_anlage
       and    eabl~v_zwstand = eabl~v_zwstndab
*and    eabl~ablstat ne '7'                     " not billed
       and    eabl~adat >= lv_mr_date_from
       and    eabl~adat <= lv_mr_date_to
       and    eanl~sparte = 'G'
       and    eanlh~tariftyp in s_tarif
       and    eanlh~ab <=  eabl~adat
       and    eanlh~bis >= eabl~adat.

       sort lt_eabldat by ablbelnr.
       delete adjacent duplicates from lt_eabldat comparing ablbelnr.

* Run through the meterreadings.
* Calculate the corrected consumption and

       loop at lt_eabldat assigning <fs_eabldat> where ablesgr <> '06'.

* Check if the gasprocedure has been changed to G_AC_GP5

         select single eadz~thgver
         into   lv_thgver
         from   easts
         inner  join eadz
         on     eadz~logikzw = easts~logikzw
         where  easts~anlage = <fs_eabldat>-anlage
         and    eadz~ab      <= <fs_eabldat>-adat
         and    eadz~bis     >= <fs_eabldat>-adat.

         if lv_thgver = 'G_AC_GP5'.
* no correction needed.
           continue.
         endif.



* check if the meterreading is billed
         select *
         into table lt_eablg
         from eablg
         where ablbelnr = <fs_eabldat>-ablbelnr.


         CALL FUNCTION 'ISU_READING_STATUS_DETERMINE'
           EXPORTING
             x_equnr    = <fs_eabldat>-equnr
             x_zwnummer = <fs_eabldat>-zwnummer
             x_adat     = <fs_eabldat>-adat
             x_atim     = <fs_eabldat>-atim
*            X_ACTUAL   =
             x_adatreal = <fs_eabldat>-adatreal
             x_atimreal = <fs_eabldat>-atimreal
             x_bp       = <fs_eabldat>-bp
           TABLES
             tx_eablg   = lt_eablg
           CHANGING
             xy_ablstat = <fs_eabldat>-ablstat
* EXCEPTIONS
*            INTERNAL_ERROR       = 1
*            OTHERS     = 2
           .
         IF SY-subrc <> 0.
           Write: /'Error - status could not be determined. Installation:',
                  <fs_eabldat>-anlage.
           continue.
         ENDIF.

         if <fs_eabldat>-ablstat = '*'.
           write:/ 'Error the meterreading is partially billed. Installation:',
                   <fs_eabldat>-anlage.
         elseif <fs_eabldat>-ablstat = '1' or <fs_eabldat>-ablstat = '4'.

* Find the calorific area

           select single zgos_list~ean
           into   <fs_eabldat>-ext_ui
           from   zinst_gos
           inner  join zgos_list
           on     zgos_list~mp = zinst_gos~mp
           where  zinst_gos~anlage = <fs_eabldat>-anlage
           and    zgos_list~datefrom <= lv_mr_date_from
           and    zgos_list~dateto   >= lv_mr_date_from.
*    and    zgos_list~jaar = p_year.

           if sy-subrc ne '0'.
             write:/ 'Error: No EAN found in the tables',
                     'ZGOS_LIST/ZINST_GOS. Installation:', <fs_eabldat>-anlage.
             continue.
           endif.


           <fs_eabldat>-calor_area = <fs_eabldat>-ext_ui+11(7).



* find the previous meterreading

* first look for a meterreading on the same day.

           if lv_prev_no_good = 'X'.
             clear lv_prev_no_good.
             continue.
           endif.

           select single
                  eabl~v_zwstand
                  eabl~n_zwstand
                  eabl~adat
                  eabl~atim
                  eablg~ablesgr
           into  (<fs_eabldat>-prev_v_zwstand,
                  <fs_eabldat>-prev_n_zwstand,
                  <fs_eabldat>-prev_adat,
                  <fs_eabldat>-prev_atim,
                  <fs_eabldat>-prev_ablesgr)
           from   eabl
           inner  join eablg
           on     eablg~ablbelnr = eabl~ablbelnr
           where  eabl~equnr    = <fs_eabldat>-equnr
           and    eabl~zwnummer = <fs_eabldat>-zwnummer
           and    eabl~adat = <fs_eabldat>-adat
           and    eabl~atim     < <fs_eabldat>-atim.

           if sy-subrc ne '0'.

* AUCT-UPGRADE -  Begin of Modification by <USER> on <17.02.2017> for <EHP8>
*      select single
*             eabl1~v_zwstand
*             eabl1~n_zwstand
*             eabl1~adat
*             eabl1~atim
*      into  (<fs_eabldat>-prev_v_zwstand,
*             <fs_eabldat>-prev_n_zwstand,
*             <fs_eabldat>-prev_adat,
*             <fs_eabldat>-prev_atim)
*      from   eabl as eabl1
*      where  eabl1~equnr    = <fs_eabldat>-equnr
*      and    eabl1~zwnummer = <fs_eabldat>-zwnummer
*      and    eabl1~adat =
*              ( select max( eabl2~adat ) from eabl as eabl2
*               where  eabl2~equnr    = <fs_eabldat>-equnr
*               and    eabl2~zwnummer = <fs_eabldat>-zwnummer
*               and    eabl2~adat < <fs_eabldat>-adat
*               and    eabl2~atim     =
*                     ( select max( eabl3~atim ) from eabl as eabl3
*                       where  eabl3~equnr    = <fs_eabldat>-equnr
*                       and    eabl3~zwnummer = <fs_eabldat>-zwnummer
*                       and    eabl3~adat = eabl2~adat ) ).
             SELECT
                          eabl1~v_zwstand
                          eabl1~n_zwstand
                          eabl1~adat
                          eabl1~atim
                   INTO  (<fs_eabldat>-prev_v_zwstand,
                          <fs_eabldat>-prev_n_zwstand,
                          <fs_eabldat>-prev_adat,
                          <fs_eabldat>-prev_atim)
                   FROM   eabl AS eabl1
                   WHERE  eabl1~equnr    = <fs_eabldat>-equnr
                   AND    eabl1~zwnummer = <fs_eabldat>-zwnummer
                   AND    eabl1~adat =
                           ( SELECT MAX( eabl2~adat ) FROM eabl AS eabl2
                            WHERE  eabl2~equnr    = <fs_eabldat>-equnr
                            AND    eabl2~zwnummer = <fs_eabldat>-zwnummer
                            AND    eabl2~adat < <fs_eabldat>-adat
                            AND    eabl2~atim     =
                                  ( SELECT MAX( eabl3~atim ) FROM eabl AS eabl3
                                    WHERE  eabl3~equnr    = <fs_eabldat>-equnr
                                    AND    eabl3~zwnummer = <fs_eabldat>-zwnummer
                                    AND    eabl3~adat = eabl2~adat ) )
             ORDER BY PRIMARY KEY.
               EXIT.
             ENDSELECT.
* AUCT-UPGRADE -  End of Modification by <USER> on <17.02.2017> for <EHP8>

             if sy-subrc ne '0'.
*       Write:/ 'Error - no previous meterreading found! Installation: '
*,
*       <fs_eabldat>-anlage.
               continue.
             endif.

           else.

             if <fs_eabldat>-ablesgr = <fs_eabldat>-prev_ablesgr.
               Write:/ 'Error - 2 readings on same date',<fs_eabldat>-adat,
                       'with same reason',<fs_eabldat>-ablesgr,'Installation',
                       <fs_eabldat>-anlage, '- change manually!!'.
               lv_prev_no_good = 'X'.
               continue.
             endif.

           endif.

* Find the consumption on the current meterreading

           CALL FUNCTION 'ISU_CONSUMPTION_DETERMINE'
             EXPORTING
*              X_GERAET          =
               x_equnr           = <fs_eabldat>-equnr
               x_zwnummer        = <fs_eabldat>-zwnummer
               x_adat            = <fs_eabldat>-adat
               x_atim            = <fs_eabldat>-atim
*              X_I_ZWSTNDAB      =
               x_v_zwstndab      = <fs_eabldat>-v_zwstndab
               x_n_zwstndab      = <fs_eabldat>-n_zwstndab
               x_adatvor         = <fs_eabldat>-prev_adat
               x_atimvor         = <fs_eabldat>-prev_atim
*              X_I_ZWSTVOR       =
               x_v_zwstvor       = <fs_eabldat>-prev_v_zwstand
               x_n_zwstvor       = <fs_eabldat>-prev_n_zwstand
*              X_WABLT           =
*              X_WTHG            =
*              X_NO_INSTSTRU_READ = ' '
*              X_NORUND          =
*              X_GUSE            = 'MR'
*              X_READ_GASFAKTOR  = ' '
*              X_INST_FOR_BILLING =
*              X_ROUND_EXEC      = ' '
             IMPORTING
               y_i_abrmenge      = <fs_eabldat>-consumption
*              Y_V_ABRMENGE      = f_verb1
*              Y_N_ABRMENGE      = f_verb2
             EXCEPTIONS
               general_fault     = 1
               zwstandab_missing = 2
               zwstand_missing   = 3
               parameter_missing = 4
               no_inst_structure = 5
               no_ratetyp        = 6
               no_gas_proc       = 7
               OTHERS            = 8.



           IF sy-subrc <> 0.

             write:/ 'Error: consumption could not be found on',
                    <fs_eabldat>-anlage.
             continue.
           ELSE.

* Find the periods for the consumption to be weighted

* Total period:

             lv_total_period = <fs_eabldat>-adat - <fs_eabldat>-prev_adat.

             lv_startdate = <fs_eabldat>-prev_adat.

             lv_total_brennwte = 0.

             lv_brennwte = 0.

             do.

               lv_startdate = lv_startdate + 1.

               lv_year      = lv_startdate(4).

               lv_month     = lv_startdate+4(2).

* If the date is before 2008, there is no calor value
* therefor we uses january 2008, to find the calor value

               if lv_year < 2008.
                 lv_year = 2008.
                 lv_month = 01.
               endif.

* find the calorific value

               concatenate lv_year lv_month into lv_datmoja.

* AUCT-UPGRADE -  Begin of Modification by <USER> on <17.02.2017> for <EHP8>
*        select single te449~brennwte
*        into   lv_brennwte
*        from   te449
*        where  te449~calor_area = <fs_eabldat>-calor_area
*        and    te449~datmoja    = lv_datmoja.
               SELECT te449~brennwte
                       INTO   lv_brennwte
                       FROM   te449
                       WHERE  te449~calor_area = <fs_eabldat>-calor_area
                       AND    te449~datmoja    = lv_datmoja
               ORDER BY PRIMARY KEY.
                 EXIT.
               ENDSELECT.
* AUCT-UPGRADE -  End of Modification by <USER> on <17.02.2017> for <EHP8>

               if sy-subrc <> 0.
                 write:/ 'Error: no calorific value found for',
                 <fs_eabldat>-calor_area,'in',lv_year,lv_month, 'installation',
                 <fs_eabldat>-anlage.
                 exit.
               endif.

               lv_total_brennwte = lv_total_brennwte + lv_brennwte.

               if lv_startdate >= <fs_eabldat>-adat.
                 exit.
               endif.

             enddo.

* calculate the average calorific value
             try.
                 <fs_eabldat>-brennwte = lv_total_brennwte / lv_total_period.
               CATCH cx_root.
                 <fs_eabldat>-brennwte = lv_total_brennwte.
             endtry.



             if sy-subrc ne '0'.
               write:/ 'ERROR: Calorific area: ', <fs_eabldat>-calor_area,
              ' has no calorific values in the period. Installation ',
              <fs_eabldat>-anlage,
              'Ean', <fs_eabldat>-ext_ui.
               continue.
             endif.


* calculate the new corrected consumption:
             try.
                 <fs_eabldat>-new_consumption =
                     <fs_eabldat>-consumption * <fs_eabldat>-brennwte.
               CATCH cx_root.
                 write:/ 'Error. Installation:',<fs_eabldat>-anlage,
                 'New consumption could not be calculated. Old consumption:',
                 <fs_eabldat>-consumption, 'Calorific value:',
                 <fs_eabldat>-brennwte.
                 continue.
             endtry.

             if <fs_eabldat>-consumption = <fs_eabldat>-new_consumption.
               continue.
             endif.

* Convert the date

             concatenate <fs_eabldat>-adat+6(2)
                         <fs_eabldat>-adat+4(2)
                         <fs_eabldat>-adat+0(4)
                     into lv_conv_date.

* convert the consumption

             lv_cons = <fs_eabldat>-new_consumption.

* update the meterreadings.
             refresh bdcdata.

             perform bdc_dynpro      using 'SAPLEL01' '0120'.
*    perform bdc_field       using 'BDC_CURSOR'
*                                  'REL28D-ABLESGR'.
             perform bdc_field       using 'BDC_OKCODE'
                                           '/00'.
*    perform bdc_field       using 'RELX1-PARTNER_DY'
*                                  record-PARTNER_DY_001.
             perform bdc_field       using 'RELX1-ANLAGE_T'
                                           'X'.
             perform bdc_field       using 'REL28D-ANLAGE'
                                           <fs_eabldat>-anlage.
             perform bdc_field       using 'REL28D-ADAT'
                                           lv_conv_date.
             perform bdc_field       using 'REL28D-ABLESGR'
                                           <fs_eabldat>-ablesgr.
             perform bdc_dynpro      using 'SAPLEL01' '0240'.
*    perform bdc_field       using 'BDC_CURSOR'
*                                  'RVALDAT-CONSMPT_MRENT(01)'.
             perform bdc_field       using 'BDC_OKCODE'
                                           '/00'.
             perform bdc_field       using 'RVALDAT-CONSMPT_MRENT(01)'
                                           lv_cons.
             perform bdc_dynpro      using 'SAPLEL01' '0240'.
*    perform bdc_field       using 'BDC_CURSOR'
*                                  'REABLD-ZWSTAND(01)'.
             perform bdc_field       using 'BDC_OKCODE'
                                           '=SAVE'.
             CLEAR opt.
             opt-dismode = 'N'.          " N=Background processing, A=ALL, E=Err
             opt-updmode = 'S'.          " S=Syncronous

             refresh lt_messtab.

             CALL TRANSACTION 'EL29'
                       USING    bdcdata
                       OPTIONS  FROM opt
                       MESSAGES INTO lt_messtab.




             LOOP AT lt_messtab.

               MESSAGE ID lt_messtab-msgid TYPE lt_messtab-msgtyp
                       NUMBER lt_messtab-msgnr WITH lt_messtab-msgv1
                              lt_messtab-msgv2 lt_messtab-msgv3
                              lt_messtab-msgv4 INTO l_text.
               if lt_messtab-msgid is initial or
                  ( lt_messtab-msgid = 'EL' and lt_messtab-msgnr = '850' ).
                 write: / 'Installation',<fs_eabldat>-anlage, 'corrected',
                    <fs_eabldat>-adat,
                    <fs_eabldat>-ablesgr, 'Old:', <fs_eabldat>-consumption,
                         'New:',<fs_eabldat>-new_consumption, 'Calarea:',
                   <fs_eabldat>-calor_area,'Calval:',<fs_eabldat>-brennwte.

                 clear la_calval_m3.

                 la_calval_m3-rundate = sy-datum.
                 la_calval_m3-runuser = sy-uname.
                 la_calval_m3-rate_category = <fs_eabldat>-tariftyp.
                 la_calval_m3-readmonth = p_month.
                 la_calval_m3-readyear = p_year.
                 la_calval_m3-anlage = <fs_eabldat>-anlage.
                 la_calval_m3-adat = <fs_eabldat>-adat.
                 la_calval_m3-ablesgr = <fs_eabldat>-ablesgr.
                 la_calval_m3-old_consumption = <fs_eabldat>-consumption.
                 la_calval_m3-new_consumption = <fs_eabldat>-new_consumption.


                 delete from zisu_calval_m3
                 where  rundate = la_calval_m3-rundate
                 and    anlage  = la_calval_m3-anlage
                 and    adat = la_calval_m3-adat
                 and    ablesgr  = la_calval_m3-ablesgr.

                 insert zisu_calval_m3 from la_calval_m3.

                 commit work.

               elseif
               lt_messtab-msgid = 'EE_MR_KPI' and lt_messtab-msgnr = '006'.
* Write nothing since this message always comes along with EL - 850.
               else.

                 WRITE: / 'Error, Installation:', <fs_eabldat>-anlage,
                         lt_messtab-msgtyp,
                         lt_messtab-msgid,
                         lt_messtab-msgnr,
                         l_text.
               endif.
             endloop.
           endif.
         endif.
       endloop.

*---------------------------------------------------------------------*
*       FORM bdc_field                                                *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
*  -->  fnam                                                          *
*  -->  fval                                                          *
*---------------------------------------------------------------------*
       FORM bdc_field USING fnam fval.
         CLEAR bdcdata.
         bdcdata-fnam = fnam.
         bdcdata-fval = fval.
         APPEND bdcdata.
       ENDFORM.                    "bdc_field

*&---------------------------------------------------------------------*
*&      Form  BDC_DYNPRO
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
       FORM bdc_dynpro USING program dynpro.
         CLEAR bdcdata.
         bdcdata-program  = program.
         bdcdata-dynpro   = dynpro.
         bdcdata-dynbegin = 'X'.
         APPEND bdcdata.
       ENDFORM.                    "bdc_dynpro
