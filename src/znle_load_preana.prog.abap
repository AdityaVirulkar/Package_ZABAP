*&---------------------------------------------------------------------*
*& Report  ZDTE_LOAD_PREANALYSE                                        *
*&                                                                     *
*&---------------------------------------------------------------------*
*&                                                                     *
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
REPORT  zdte_load_preanalyse.
       TABLES: eideswtdoc,
               eideswtmsgdata,
               zdte_netwerk,
               zdte_levering,
               euiinstln.

       PARAMETERS:
       ch_upl AS CHECKBOX.

       SELECTION-SCREEN BEGIN OF BLOCK upload WITH FRAME TITLE text-001.

       SELECT-OPTIONS:

        p_delta   FOR eideswtdoc-erdat.

       SELECTION-SCREEN  END OF BLOCK upload.

       PARAMETERS:

         vrh_ana AS CHECKBOX,
         sw_ana  AS CHECKBOX,
         el_ana  AS CHECKBOX.

       SELECTION-SCREEN BEGIN OF BLOCK analyse WITH FRAME TITLE text-002.
       SELECT-OPTIONS:
        so_swdoc FOR eideswtdoc-switchnum,
        so_start FOR sy-datum,
        p_status FOR eideswtdoc-status.
       SELECTION-SCREEN END OF BLOCK analyse.


       INITIALIZATION.

* bepaal laatste upload
         SELECT MAX( swdoc_credat )
         FROM zdte_netwerk
         INTO p_delta-low.


         p_delta-high = sy-datum - 1.
         APPEND p_delta.
         CLEAR  p_delta.

*****data

         DATA: BEGIN OF tb_upload OCCURS 0,
                 switchnum        LIKE zdte_netwerk-switchnum,
                 swdoc_status     LIKE zdte_netwerk-swdoc_status,
                 swdoc_credat     LIKE zdte_netwerk-swdoc_credat,
                 moveindate       LIKE zdte_netwerk-verhuisdat,
                 moveoutdate      LIKE zdte_netwerk-verhuisdat,
                 switchtype       LIKE zdte_netwerk-switchtype,
                 swtview          LIKE zdte_netwerk-swtview,
                 service_prov_new LIKE zdte_netwerk-service_prov_new,
                 service_prov_old LIKE zdte_netwerk-service_prov_old,
                 startscenario    LIKE zdte_netwerk-startscenario,
                 targetscenario   LIKE zdte_netwerk-targetscenario,
                 zzsparte         LIKE zdte_netwerk-sparte,
                 pod              LIKE zdte_netwerk-int_ui,
                 distributor      LIKE zdte_levering-distributor,
               END OF tb_upload.


         DATA:
           ld_verhuisdat    TYPE dats,
           lv_partij        TYPE own_log_sys,
           ll_value         TYPE eideswtattrvalue,
           ll_vertrag       TYPE vertrag,
           ll_erdat         TYPE dats,
           ll_abrdats       TYPE dats,
           ll_vkont         TYPE vkont_kk,
           ll_verhuisdatmin TYPE dats.


         DATA:
           wa_netwerk  TYPE zdte_netwerk,
           wa_levering TYPE zdte_levering.

         DATA:
           tb_netwerk  TYPE STANDARD TABLE OF zdte_netwerk WITH HEADER LINE,
           tb_levering TYPE STANDARD TABLE OF zdte_levering WITH HEADER LINE,
           tb_anlage   TYPE STANDARD TABLE OF euiinstln WITH HEADER LINE,
           tb_msgdata  TYPE STANDARD TABLE OF eideswtmsgdata WITH HEADER LINE.


         FIELD-SYMBOLS:
           <netwerk>  LIKE LINE OF tb_netwerk,
           <levering> LIKE LINE OF tb_levering.


       START-OF-SELECTION.

         CLEAR: ld_verhuisdat,
                tb_upload,
                tb_upload[].

         IF ch_upl EQ 'X'.

******bepaal records die toegevoegd moeten worden aan zdte_levering en
******zdte_netwerk

           SELECT switchnum
                  status
                  erdat
                  moveindate
                  moveoutdate
                  switchtype
                  swtview
                  service_prov_new
                  service_prov_old
                  startscenario
                  targetscenario
                  zzsparte
                  pod
                  distributor
                  FROM eideswtdoc
                  INTO TABLE tb_upload
              WHERE erdat IN p_delta
               AND  switchtype IN ('71','72','73','76','77','78').



*****insert into corresponding tables
           LOOP AT tb_upload.
             CLEAR: ld_verhuisdat,
                    wa_netwerk,
                    wa_levering,
                    ll_value.

             IF tb_upload-switchtype EQ '71' OR
                tb_upload-switchtype EQ '72' OR
                tb_upload-switchtype EQ '77'.

               ld_verhuisdat = tb_upload-moveindate.
             ENDIF.

             IF tb_upload-switchtype EQ '73' OR
                tb_upload-switchtype EQ '76' OR
                tb_upload-switchtype EQ '78'.

               ld_verhuisdat = tb_upload-moveoutdate.

             ENDIF.


             IF ld_verhuisdat EQ space.
               ld_verhuisdat = '00000000'.
             ENDIF.

             IF tb_upload-swtview EQ '01'.
**netwerk

               wa_netwerk-switchnum        = tb_upload-switchnum.
               wa_netwerk-swdoc_status     = tb_upload-swdoc_status.
               wa_netwerk-swdoc_credat     = tb_upload-swdoc_credat.
               wa_netwerk-verhuisdat       = ld_verhuisdat.
               wa_netwerk-switchtype       = tb_upload-switchtype.
               wa_netwerk-swtview          = tb_upload-swtview.
               wa_netwerk-service_prov_new = tb_upload-service_prov_new.
               wa_netwerk-service_prov_old = tb_upload-service_prov_old.
               wa_netwerk-startscenario    = tb_upload-startscenario.
               wa_netwerk-targetscenario   = tb_upload-targetscenario.
               wa_netwerk-sparte           = tb_upload-zzsparte.
               wa_netwerk-int_ui           = tb_upload-pod.


               CLEAR tb_anlage[].
               SELECT anlage FROM euiinstln
               INTO CORRESPONDING FIELDS OF TABLE tb_anlage
               WHERE int_ui EQ tb_upload-pod.

*{cHV20051209 - product staat niet altijd gevuld in eideswtdoc
*       SELECT anlage vstelle FROM eanl
*       INTO (wa_netwerk-anlage,wa_netwerk-vstelle)
* HANA Corrections - BEGIN OF MODIFY - <HANA-001>
               IF NOT tb_anlage[] IS INITIAL.
* HANA Corrections - END OF MODIFY - <HANA-001>
                 SELECT anlage vstelle sparte FROM eanl
                 INTO (wa_netwerk-anlage,wa_netwerk-vstelle,wa_netwerk-sparte)
*}cHV20051209
                 FOR ALL ENTRIES IN tb_anlage
                 WHERE anlage EQ tb_anlage-anlage
                 AND service IN ('ENET','GNET').
                 ENDSELECT.
* HANA Corrections - BEGIN OF MODIFY - <HANA-001>
               ENDIF.
* HANA Corrections - END OF MODIFY - <HANA-001>

               SELECT ext_ui FROM euitrans
               INTO wa_netwerk-eancode
               WHERE int_ui EQ tb_upload-pod.
               ENDSELECT.


** workflow_id ophalen
               SELECT b~objectkey
                      INTO ll_value
                      FROM eideswtdocstep AS a INNER JOIN
                           eideswtdocref AS b ON
                           a~stepkey = b~stepkey
                           WHERE a~switchnum EQ tb_upload-switchnum
                            AND  a~activity  EQ '100'.
               ENDSELECT.
               IF sy-subrc EQ 0.
                 wa_netwerk-wi_id = ll_value.
               ENDIF.
               INSERT zdte_netwerk FROM wa_netwerk.

             ELSE.
**levering

               wa_levering-switchnum        = tb_upload-switchnum.
               wa_levering-swdoc_status     = tb_upload-swdoc_status.
               wa_levering-swdoc_credat     = tb_upload-swdoc_credat.
               wa_levering-verhuisdat       = ld_verhuisdat.
               wa_levering-switchtype       = tb_upload-switchtype.
               wa_levering-swtview          = tb_upload-swtview.
               wa_levering-service_prov_new = tb_upload-service_prov_new.
               wa_levering-service_prov_old = tb_upload-service_prov_old.
               wa_levering-startscenario    = tb_upload-startscenario.
               wa_levering-targetscenario   = tb_upload-targetscenario.
               wa_levering-sparte           = tb_upload-zzsparte.
               wa_levering-int_ui           = tb_upload-pod.
               wa_levering-distributor      = tb_upload-distributor.

               CLEAR tb_anlage[].
               SELECT anlage FROM euiinstln
               INTO CORRESPONDING FIELDS OF TABLE tb_anlage
               WHERE int_ui EQ tb_upload-pod.

*{cHV20051209 - product staat niet altijd gevuld in eideswtdoc
*       SELECT anlage vstelle FROM eanl
*       INTO (wa_levering-anlage,wa_levering-vstelle)
* HANA Corrections - BEGIN OF MODIFY - <HANA-001>
               IF NOT tb_anlage[] IS INITIAL.
* HANA Corrections - END OF MODIFY - <HANA-001>
                 SELECT anlage vstelle sparte FROM eanl
                 INTO (wa_levering-anlage,wa_levering-vstelle,wa_levering-sparte)
*}cHV20051209
                 FOR ALL ENTRIES IN tb_anlage
                 WHERE anlage EQ tb_anlage-anlage
                 AND service IN ('ELEV','GLEV').
                 ENDSELECT.
* HANA Corrections - BEGIN OF MODIFY - <HANA-001>
               ENDIF.
* HANA Corrections - END OF MODIFY - <HANA-001>

               SELECT ext_ui FROM euitrans
               INTO wa_levering-eancode
               WHERE int_ui EQ tb_upload-pod.
               ENDSELECT.


** workflow_id ophalen
               SELECT b~objectkey
                      INTO ll_value
                      FROM eideswtdocstep AS a INNER JOIN
                           eideswtdocref AS b ON
                           a~stepkey = b~stepkey
                           WHERE a~switchnum EQ tb_upload-switchnum
                            AND  a~activity  EQ '100'.
               ENDSELECT.
               IF sy-subrc EQ 0.
                 wa_levering-wi_id = ll_value.
               ENDIF.

               INSERT zdte_levering FROM wa_levering.

             ENDIF.
           ENDLOOP.

           COMMIT WORK AND WAIT.
         ENDIF.




***************************extra basis informatie ophalen onafhankelijk
         CLEAR:tb_netwerk[],
               tb_levering[],
               ll_abrdats.
         DATA: tmp_date1    TYPE eideswtdoc-moveindate,
               tmp_realdate TYPE eideswtdoc-moveindate.


         SELECT * FROM zdte_netwerk
         INTO TABLE tb_netwerk
         WHERE   switchnum  IN so_swdoc
         AND    start_dat  IN so_start
         AND    loevm      EQ space.

* Status switchdoc en workflow updaten
         LOOP AT tb_netwerk ASSIGNING <netwerk>.
           SELECT status targetscenario
         FROM eideswtdoc
         INTO (<netwerk>-swdoc_status, <netwerk>-targetscenario)
         WHERE switchnum EQ <netwerk>-switchnum.
           ENDSELECT.

* status workflow updaten
           IF <netwerk>-wi_stat NE 'COMPLETED'.
             SELECT wi_stat FROM swwwihead AS a INTO <netwerk>-wi_stat
             WHERE a~wi_id EQ <netwerk>-wi_id.
             ENDSELECT.
           ENDIF.

* gewijzigde datum?
           CLEAR: tmp_date1, tmp_realdate.

           IF <netwerk>-switchtype EQ '72' OR
              <netwerk>-switchtype EQ '77'.
             SELECT moveindate realmoveindate
             FROM eideswtdoc
             INTO (tmp_date1, tmp_realdate)
                 WHERE switchnum EQ <netwerk>-switchnum.
             ENDSELECT.
           ELSEIF <netwerk>-switchtype EQ '73' OR
                  <netwerk>-switchtype EQ '76' OR
                  <netwerk>-switchtype EQ '78' .
             SELECT moveoutdate realmoveoutdate
             FROM eideswtdoc
             INTO (tmp_date1, tmp_realdate)
                 WHERE switchnum EQ <netwerk>-switchnum.
             ENDSELECT.
           ENDIF.
           IF tmp_date1 NE tmp_realdate.
             <netwerk>-verhuisdat = tmp_date1.
           ENDIF.

         ENDLOOP.

         LOOP AT tb_netwerk ASSIGNING <netwerk>
         WHERE partner EQ space
         OR vkont EQ space.

           CLEAR:ll_abrdats.

* bij uithuizen ophalen huidige ZP en CR
           IF <netwerk>-switchtype EQ '76' OR
              <netwerk>-switchtype EQ '78'.

*{cHV 20051130
*      SELECT SINGLE vkonto FROM ever INTO <netwerk>-vkont
*      WHERE anlage EQ <netwerk>-anlage
*      AND einzdat LE <netwerk>-verhuisdat
*      AND auszdat GE <netwerk>-verhuisdat.
* AUCT-UPGRADE -  Begin of Modification by <USER> on <17.02.2017> for <EHP8>
*      SELECT SINGLE vkonto vertrag sparte
*        FROM ever
*        INTO (<netwerk>-vkont, <netwerk>-contract, <netwerk>-sparte)
*        WHERE anlage  EQ <netwerk>-anlage
*          AND einzdat LE <netwerk>-verhuisdat
*          AND auszdat GE <netwerk>-verhuisdat.
             SELECT vkonto vertrag sparte
                     FROM ever
                     INTO (<netwerk>-vkont, <netwerk>-contract, <netwerk>-sparte)
                     WHERE anlage  EQ <netwerk>-anlage
                       AND einzdat LE <netwerk>-verhuisdat
                       AND auszdat GE <netwerk>-verhuisdat
             ORDER BY PRIMARY KEY.
               EXIT.
             ENDSELECT.
* AUCT-UPGRADE -  End of Modification by <USER> on <17.02.2017> for <EHP8>
*}cHV 20051130

* AUCT-UPGRADE -  Begin of Modification by <USER> on <17.02.2017> for <EHP8>
*      SELECT SINGLE gpart FROM fkkvkp INTO <netwerk>-partner
*      WHERE vkont EQ <netwerk>-vkont.
             SELECT gpart FROM fkkvkp INTO <netwerk>-partner
                   WHERE vkont EQ <netwerk>-vkont
             ORDER BY PRIMARY KEY.
               EXIT.
             ENDSELECT.
* AUCT-UPGRADE -  End of Modification by <USER> on <17.02.2017> for <EHP8>

           ELSE.
* ophalen ZP en CR van switchdoc
             SELECT partner zzvkont
             FROM eideswtdoc
             INTO (<netwerk>-partner,<netwerk>-vkont)
             WHERE switchnum EQ <netwerk>-switchnum.
             ENDSELECT.
           ENDIF.

           IF <netwerk>-jaarnota_dat IS INITIAL.

             SELECT c~abrdats
                       INTO ll_abrdats
                       FROM eanlh AS a INNER JOIN
                            te422 AS b ON
                            a~ableinh = b~termschl
                                       INNER JOIN
                            te420 AS c ON
                            b~portion = c~termschl
                     WHERE a~anlage EQ <netwerk>-anlage
                      AND  a~bis    GE sy-datum.
             ENDSELECT.
             IF sy-subrc EQ 0.
               ll_abrdats+0(4) = sy-datum+0(4).
               IF ll_abrdats LT sy-datum.
                 ADD 1 TO ll_abrdats+3(1).
                 <netwerk>-jaarnota_dat = ll_abrdats.
               ELSE.
                 <netwerk>-jaarnota_dat = ll_abrdats.
               ENDIF.
             ENDIF.
           ENDIF.
         ENDLOOP.

         UPDATE zdte_netwerk FROM TABLE tb_netwerk.


         SELECT * FROM zdte_levering
         INTO TABLE tb_levering
         WHERE   switchnum  IN so_swdoc
         AND    start_dat  IN so_start
         AND    loevm      EQ space.

* Status switchdoc en workflow updaten
         LOOP AT tb_levering ASSIGNING <levering>.

           SELECT status targetscenario
           FROM eideswtdoc
           INTO (<levering>-swdoc_status, <levering>-targetscenario)
           WHERE switchnum EQ <levering>-switchnum.
           ENDSELECT.

* status workflow updaten
           IF <levering>-wi_stat NE 'COMPLETED'.
             SELECT wi_stat FROM swwwihead AS a INTO <levering>-wi_stat
             WHERE a~wi_id EQ <levering>-wi_id.
             ENDSELECT.
           ENDIF.

* gewijzigde datum?
           CLEAR: tmp_date1, tmp_realdate.

           IF <levering>-switchtype EQ '72' OR
              <levering>-switchtype EQ '77'.
             SELECT moveindate realmoveindate
             FROM eideswtdoc
             INTO (tmp_date1, tmp_realdate)
                 WHERE switchnum EQ <levering>-switchnum.
             ENDSELECT.
           ELSEIF <levering>-switchtype EQ '73' OR
                  <levering>-switchtype EQ '76' OR
                  <levering>-switchtype EQ '78' .
             SELECT moveoutdate realmoveoutdate
             FROM eideswtdoc
             INTO (tmp_date1, tmp_realdate)
                 WHERE switchnum EQ <levering>-switchnum.
             ENDSELECT.
           ENDIF.
           IF tmp_date1 NE tmp_realdate.
             <levering>-verhuisdat = tmp_date1.
           ENDIF.

         ENDLOOP.

         LOOP AT tb_levering ASSIGNING <levering>
         WHERE partner EQ space
         OR vkont EQ space.

           CLEAR:ll_abrdats.

* bij uithuizen ophalen huidige ZP en CR
           IF <levering>-switchtype EQ '73' OR
              <levering>-switchtype EQ '76' OR
              <levering>-switchtype EQ '78'.

*{cHV 20051130
*      SELECT SINGLE VKONTO from EVER INTO <levering>-VKONT
*      where ANLAGE EQ <levering>-anlage
*      and EINZDAT LE <levering>-VERHUISDAT
*      and AUSZDAT GE <levering>-VERHUISDAT.
* AUCT-UPGRADE -  Begin of Modification by <USER> on <17.02.2017> for <EHP8>
*      SELECT SINGLE vkonto vertrag sparte
*        FROM ever
*        INTO (<levering>-vkont, <levering>-contract, <levering>-sparte)
*        WHERE anlage  EQ <levering>-anlage
*          AND einzdat LE <levering>-verhuisdat
*          AND auszdat GE <levering>-verhuisdat.
             SELECT vkonto vertrag sparte
                     FROM ever
                     INTO (<levering>-vkont, <levering>-contract, <levering>-sparte)
                     WHERE anlage  EQ <levering>-anlage
                       AND einzdat LE <levering>-verhuisdat
                       AND auszdat GE <levering>-verhuisdat
             ORDER BY PRIMARY KEY.
               EXIT.
             ENDSELECT.
* AUCT-UPGRADE -  End of Modification by <USER> on <17.02.2017> for <EHP8>
*}cHV 20051130

* AUCT-UPGRADE -  Begin of Modification by <USER> on <17.02.2017> for <EHP8>
*      SELECT SINGLE gpart FROM fkkvkp INTO <levering>-partner
*      WHERE vkont EQ <levering>-vkont.
             SELECT gpart FROM fkkvkp INTO <levering>-partner
                   WHERE vkont EQ <levering>-vkont
             ORDER BY PRIMARY KEY.
               EXIT.
             ENDSELECT.
* AUCT-UPGRADE -  End of Modification by <USER> on <17.02.2017> for <EHP8>

           ELSE.

             SELECT partner zzvkont
             FROM eideswtdoc
             INTO (<levering>-partner,<levering>-vkont)
             WHERE switchnum EQ <levering>-switchnum.
             ENDSELECT.
           ENDIF.

           IF <levering>-jaarnota_dat IS INITIAL.

             SELECT c~abrdats
                          INTO ll_abrdats
                          FROM eanlh AS a INNER JOIN
                               te422 AS b ON
                               a~ableinh = b~termschl
                                          INNER JOIN
                               te420 AS c ON
                               b~portion = c~termschl
                        WHERE a~anlage EQ <levering>-anlage
                         AND  a~bis    GE sy-datum.
             ENDSELECT.
             IF sy-subrc EQ 0.
               ll_abrdats+0(4) = sy-datum+0(4).
               IF ll_abrdats LT sy-datum.
                 ADD 1 TO ll_abrdats+3(1).
                 <levering>-jaarnota_dat = ll_abrdats.
               ELSE.
                 <levering>-jaarnota_dat = ll_abrdats.
               ENDIF.
             ENDIF.
           ENDIF.

         ENDLOOP.

         UPDATE zdte_levering FROM TABLE tb_levering.

         COMMIT WORK AND WAIT.


***Analyse verhuizingen

         IF vrh_ana EQ 'X'.

           CLEAR tb_netwerk[].
           CLEAR tb_levering[].

           SELECT * FROM zdte_netwerk
           INTO TABLE tb_netwerk
           WHERE  switchtype IN ('76','77')
           AND    switchnum  IN so_swdoc
           AND    start_dat  IN so_start
           AND    loevm      EQ space.


** inhuizingen
           LOOP AT tb_netwerk ASSIGNING <netwerk>
           WHERE switchtype EQ '77'.

             CLEAR: tb_msgdata[],
                    lv_partij.

             SELECT * FROM eideswtmsgdata
             INTO TABLE tb_msgdata
             WHERE switchnum EQ <netwerk>-switchnum.

*berichtendata toevoegen
             LOOP AT tb_msgdata.
               CASE tb_msgdata-category.
                 WHEN 'Z07'.
                   <netwerk>-ber27_dat = tb_msgdata-erdat.
                 WHEN 'Z09'.
                   <netwerk>-ber30_dat = tb_msgdata-erdat.
                   <netwerk>-ber30_taskid = tb_msgdata-dextaskid.
                 WHEN 'Z08'.
                   <netwerk>-ber40_dat = tb_msgdata-erdat.
                   <netwerk>-rejectreason = tb_msgdata-zzrjct_reasn_id.
                   <netwerk>-ber40_taskid = tb_msgdata-dextaskid.
                 WHEN 'Z01'.
                   IF tb_msgdata-direction EQ '1'.
                     <netwerk>-ber67_dat = tb_msgdata-erdat.
                   ELSE.
                     <netwerk>-ber75_dat = tb_msgdata-erdat.
                     <netwerk>-ber75_taskid = tb_msgdata-dextaskid.

                   ENDIF.
                 WHEN 'Z05'.
                   <netwerk>-ber140_dat = tb_msgdata-erdat.
                   <netwerk>-ber140_taskid = tb_msgdata-dextaskid.

                   IF NOT <netwerk>-ber75_dat EQ '00000000'.
                     <netwerk>-all_bericht_udat = tb_msgdata-erdat.
                   ENDIF.

                 WHEN 'Z04'.
                   IF tb_msgdata-direction EQ '1'.
                     <netwerk>-ber310_dat = tb_msgdata-erdat.
                   ELSE.
                     <netwerk>-ber200_dat = tb_msgdata-erdat.
                     <netwerk>-ber200_taskid = tb_msgdata-dextaskid.
                   ENDIF.
                 WHEN OTHERS.

               ENDCASE.

             ENDLOOP.



****het oude contract plus facturatie
**** alleen indien het een directe overname betreft
             SELECT *
                    FROM zdte_netwerk
                    WHERE eancode     EQ <netwerk>-eancode
                     AND  swtview     EQ '01'
                     AND  verhuisdat  LT <netwerk>-verhuisdat
                     AND  switchtype  EQ '76'.
             ENDSELECT.
             IF sy-subrc NE 0.

               CLEAR:ll_vertrag,
                     ll_erdat,
                     ll_vkont,
                     ll_verhuisdatmin.

               ll_verhuisdatmin = <netwerk>-verhuisdat - 1.
* AUCT-UPGRADE -  Begin of Modification by <USER> on <17.02.2017> for <EHP8>
*        SELECT SINGLE vkonto FROM ever INTO ll_vkont
*        WHERE anlage EQ <netwerk>-anlage
*        AND einzdat LE ll_verhuisdatmin
*        AND auszdat EQ ll_verhuisdatmin.
               SELECT vkonto FROM ever INTO ll_vkont
                       WHERE anlage EQ <netwerk>-anlage
                       AND einzdat LE ll_verhuisdatmin
                       AND auszdat EQ ll_verhuisdatmin
               ORDER BY PRIMARY KEY.
                 EXIT.
               ENDSELECT.
* AUCT-UPGRADE -  End of Modification by <USER> on <17.02.2017> for <EHP8>

               SELECT  a~vertrag a~erdat
                       INTO (ll_vertrag,ll_erdat)
                              FROM eausv AS a INNER JOIN
                                   eaus  AS b ON
                                   a~auszbeleg = b~auszbeleg
                                   WHERE a~anlage   EQ <netwerk>-anlage
                                    AND  a~auszdat  EQ
                                    ( SELECT MAX( auszdat )
                                             FROM ever
                                          WHERE anlage EQ <netwerk>-anlage
                                            AND  vkont  EQ ll_vkont
                                    AND  auszdat LE <netwerk>-verhuisdat )
                                    AND  a~storausz NE 'X'
                                    AND  b~vkont    EQ ll_vkont.
               ENDSELECT.



********************facturatie
               SELECT  SINGLE abrsperr gemfakt
                       FROM ever
                       INTO (<netwerk>-contract_blok,<netwerk>-gemfakt)
                       WHERE vertrag  EQ ll_vertrag.


**   billingdoc
               SELECT belnr erdat
                      INTO (<netwerk>-afr_doc,<netwerk>-afr_doc_dat)
                      FROM erch
                      WHERE vertrag   EQ ll_vertrag "<netwerk>-contract
                       AND  abrvorg   EQ '03'
                       AND  stornodat EQ '00000000'
                       AND  erdat     EQ
                              ( SELECT MAX( erdat )
                                      FROM erch
                                    WHERE vertrag EQ ll_vertrag
                                      AND abrvorg EQ '03'
                                      AND  erdat  GE ll_erdat ).

               ENDSELECT.
               IF sy-subrc EQ 0.
**invoice
                 SELECT opbel
                        INTO <netwerk>-slotnota
                        FROM erchc
                        WHERE belnr EQ <netwerk>-afr_doc
                        AND   simulated EQ space
                        AND   lfdnr     EQ
                        ( SELECT MAX( lfdnr )
                                FROM erchc
                               WHERE belnr     EQ <netwerk>-afr_doc
                                 AND simulated EQ space ).
                 ENDSELECT.
                 IF sy-subrc EQ 0.
**afdrukdocument
                   SELECT SINGLE erdat
                          INTO <netwerk>-dat_sltn
                          FROM erdk
                          WHERE opbel EQ <netwerk>-slotnota.
                 ENDIF.
               ENDIF.
             ENDIF.

***************************einde oude contract plus facturatie

*contract- en inhuisdocument gegevens toevoegen
             IF <netwerk>-contract EQ space
             AND <netwerk>-vkont NE space
             AND <netwerk>-anlage NE space.

               SELECT vertrag erdat abszyk
               FROM ever
               INTO
          (<netwerk>-contract,<netwerk>-contract_dat,<netwerk>-vsp_cyclus)
               WHERE anlage EQ <netwerk>-anlage
               AND   vkonto EQ <netwerk>-vkont
               AND  einzdat EQ <netwerk>-verhuisdat.
               ENDSELECT.

               SELECT einzbeleg
               FROM eeinv
               INTO <netwerk>-huisd
               WHERE vertrag EQ <netwerk>-contract.
               ENDSELECT.

             ENDIF.

**bepaal intern ? of externe ? partij (non-billable service)
             IF <netwerk>-targetscenario CA '456'.
               SELECT vertrag
                      INTO <netwerk>-service_contract
                      FROM eservice
                      WHERE int_ui        EQ <netwerk>-int_ui
                       AND  service_start EQ <netwerk>-verhuisdat
                       AND  serviceid     EQ <netwerk>-service_prov_new.
               ENDSELECT.
             ENDIF.



********************facturatie

**voorschotmethode
             SELECT SINGLE kzabsver
                    FROM fkkvkp
                    INTO <netwerk>-vsp_methode
                    WHERE vkont EQ <netwerk>-vkont
                     AND  gpart EQ <netwerk>-partner.

**voorschotplan
             IF <netwerk>-vsp_methode NE '0'.
               SELECT opbel erdat
                      FROM eabp
                      INTO (<netwerk>-voorschotplan,<netwerk>-dat_vsp)
                      WHERE vertrag  EQ <netwerk>-contract
*               AND   deaktiv  EQ space
                      AND   erdat    EQ
                                 ( SELECT MIN( erdat )
                                         FROM eabp
                                   WHERE vertrag  EQ <netwerk>-contract ).
*                              AND deaktiv  EQ space ).

               ENDSELECT.
             ENDIF.

           ENDLOOP.


** uithuizingen
           LOOP AT tb_netwerk ASSIGNING <netwerk>
           WHERE switchtype EQ '76'.

             CLEAR tb_msgdata[].
             SELECT * FROM eideswtmsgdata
             INTO TABLE tb_msgdata
             WHERE switchnum EQ <netwerk>-switchnum.

*berichtendata toevoegen
             LOOP AT tb_msgdata.
               CASE tb_msgdata-category.
                 WHEN 'Z07'.
                   <netwerk>-ber26_dat = tb_msgdata-erdat.
                 WHEN 'Z09'.
                   <netwerk>-ber30_dat = tb_msgdata-erdat.
                 WHEN 'Z08'.
                   <netwerk>-ber40_dat = tb_msgdata-erdat.
                   <netwerk>-rejectreason = tb_msgdata-zzrjct_reasn_id.
                   <netwerk>-ber40_taskid = tb_msgdata-dextaskid.
                 WHEN 'Z02'.
                   IF tb_msgdata-direction EQ '1'.
                     <netwerk>-ber66_dat = tb_msgdata-erdat.
                   ELSE.
                     <netwerk>-ber75_dat = tb_msgdata-erdat.
                     <netwerk>-ber75_taskid = tb_msgdata-dextaskid.
                     <netwerk>-all_bericht_udat = tb_msgdata-erdat.
                   ENDIF.
                 WHEN 'Z05'.
                   <netwerk>-ber140_dat = tb_msgdata-erdat.
                   <netwerk>-ber140_taskid = tb_msgdata-dextaskid.
                 WHEN 'Z04'.
                   IF tb_msgdata-direction EQ '1'.
                     <netwerk>-ber310_dat = tb_msgdata-erdat.
                   ELSE.
                     <netwerk>-ber200_dat = tb_msgdata-erdat.
                     <netwerk>-ber200_taskid = tb_msgdata-dextaskid.
                   ENDIF.
                 WHEN OTHERS.
               ENDCASE.
             ENDLOOP.

*contract- en uithuisdocument gegevens toevoegen
*{cHV 20051130
*      IF <netwerk>-contract EQ space
*      AND <netwerk>-vkont NE space
*      AND <netwerk>-anlage NE space.
             IF <netwerk>-huisd IS INITIAL.
*}cHV 20051130
               SELECT a~auszbeleg a~vertrag a~erdat
          INTO (<netwerk>-huisd,<netwerk>-contract,<netwerk>-contract_dat)
                      FROM eausv AS a INNER JOIN
                           eaus  AS b ON
                           a~auszbeleg = b~auszbeleg
                           WHERE a~anlage   EQ <netwerk>-anlage
                            AND  a~auszdat  GE <netwerk>-verhuisdat "GE ipv GT
                            AND  a~storausz NE 'X'
                            AND  b~vkont    EQ <netwerk>-vkont.
               ENDSELECT.


             ENDIF.

**bepaal intern ? of externe ? partij (non-billable service)

             IF <netwerk>-startscenario CA '456'.
               SELECT vertrag
                      INTO <netwerk>-service_contract
                      FROM eservice
                      WHERE int_ui        EQ <netwerk>-int_ui
                       AND  service_end   EQ <netwerk>-verhuisdat
                       AND  serviceid     EQ <netwerk>-service_prov_old.
               ENDSELECT.
             ENDIF.


********************facturatie
             SELECT  SINGLE abrsperr gemfakt
                     FROM ever
                     INTO (<netwerk>-contract_blok,<netwerk>-gemfakt)
                     WHERE vertrag  EQ <netwerk>-contract.


**   billingdoc
             SELECT belnr erdat
                    INTO (<netwerk>-afr_doc,<netwerk>-afr_doc_dat)
                    FROM erch
                    WHERE vertrag   EQ <netwerk>-contract
                     AND  abrvorg   EQ '03'
                     AND  stornodat EQ '00000000'
                     AND  erdat     EQ
                            ( SELECT MAX( erdat )
                                    FROM erch
                                  WHERE vertrag EQ <netwerk>-contract
                                    AND abrvorg EQ '03'
                                  AND  erdat   GE <netwerk>-contract_dat ).

             ENDSELECT.
             IF sy-subrc EQ 0.
**invoice
               SELECT opbel
                      INTO <netwerk>-slotnota
                      FROM erchc
                      WHERE belnr EQ <netwerk>-afr_doc
                      AND   simulated EQ space
                      AND   lfdnr     EQ
                      ( SELECT MAX( lfdnr )
                              FROM erchc
                             WHERE belnr     EQ <netwerk>-afr_doc
                               AND simulated EQ space ).
               ENDSELECT.
               IF sy-subrc EQ 0.
**afdrukdocument
                 SELECT SINGLE erdat
                        INTO <netwerk>-dat_sltn
                        FROM erdk
                        WHERE opbel EQ <netwerk>-slotnota.
               ENDIF.
             ENDIF.

           ENDLOOP.


           UPDATE zdte_netwerk FROM TABLE tb_netwerk.

********      Levering gedeelte verhuizingen


           CLEAR tb_netwerk[].
           CLEAR tb_levering[].

           SELECT * FROM zdte_levering
           INTO TABLE tb_levering
           WHERE  switchtype IN ('76','77')
           AND    switchnum  IN so_swdoc
           AND    start_dat  IN so_start
           AND    loevm      EQ space.


** inhuizingen
           LOOP AT tb_levering ASSIGNING <levering>
           WHERE switchtype EQ '77'.

             CLEAR tb_msgdata[].
             SELECT * FROM eideswtmsgdata
             INTO TABLE tb_msgdata
             WHERE switchnum EQ <levering>-switchnum.

*berichtendata toevoegen
             LOOP AT tb_msgdata.
               CASE tb_msgdata-category.
                 WHEN 'Z07'.
                   <levering>-ber15_dat = tb_msgdata-erdat.
                   <levering>-ber15_taskid = tb_msgdata-dextaskid.
                 WHEN 'Z06'.
                   <levering>-ber44_dat = tb_msgdata-erdat.
                   <levering>-rejectreason = tb_msgdata-zzrjct_reasn_id.
                 WHEN 'Z01' .
                   <levering>-ber85_dat = tb_msgdata-erdat.
*            "gedwongen inhuizing zonder stamdata
*            if <levering>-ber15_dat eq '00000000'.
*              <levering>-all_bericht_odat = tb_msgdata-erdat.
*            endif.
                 WHEN 'Z05'.
                   <levering>-ber150_dat = tb_msgdata-erdat.
*            "inhuizing met aanvraag
                   IF NOT <levering>-ber85_dat EQ '00000000'.
*            and NOT <levering>-ber15_dat eq '00000000'.
                     <levering>-all_bericht_odat = tb_msgdata-erdat.
                   ENDIF.
                 WHEN 'Z04'.
                   IF tb_msgdata-direction EQ '1'.
                     <levering>-ber210i_dat = tb_msgdata-erdat.
                   ELSE.
                     <levering>-ber300_dat = tb_msgdata-erdat.
                     <levering>-ber300_taskid = tb_msgdata-dextaskid.
                   ENDIF.

                 WHEN OTHERS.

               ENDCASE.

             ENDLOOP.

*contract- en inhuisdocument gegevens toevoegen
             IF <levering>-contract EQ space
             AND <levering>-vkont NE space
             AND <levering>-anlage NE space.

               SELECT vertrag erdat abszyk
               FROM ever
               INTO
       (<levering>-contract,<levering>-contract_dat,<levering>-vsp_cyclus)
               WHERE anlage EQ <levering>-anlage
               AND   vkonto EQ <levering>-vkont
               AND  einzdat EQ <levering>-verhuisdat.
               ENDSELECT.

               SELECT einzbeleg
               FROM eeinv
               INTO <levering>-huisd
               WHERE vertrag EQ <levering>-contract.
               ENDSELECT.

             ENDIF.

**bepaal intern ? of externe ? partij (non-billable service)

             IF <levering>-targetscenario CA '78'.
               SELECT vertrag
                      INTO <levering>-service_contract
                      FROM eservice
                      WHERE int_ui        EQ <levering>-int_ui
                       AND  service_start EQ <levering>-verhuisdat
                       AND  serviceid     EQ <levering>-service_prov_new.
               ENDSELECT.
             ELSEIF <levering>-targetscenario CA '9'.
               SELECT a~vertrag
                 FROM ever AS a INNER JOIN
                      eanl AS b ON
                      a~anlage = b~anlage
                 INTO <levering>-service_contract
                 WHERE  a~vkonto  EQ <levering>-vkont
                 AND    a~einzdat EQ <levering>-verhuisdat
                 AND    b~service IN ('ENET','GNET')..
               ENDSELECT.
             ENDIF.

********************facturatie

**voorschotmethode
             SELECT SINGLE kzabsver
                    FROM fkkvkp
                    INTO <levering>-vsp_methode
                    WHERE vkont EQ <levering>-vkont
                     AND  gpart EQ <levering>-partner.

**voorschotplan
             IF <levering>-vsp_methode NE '0'.
               SELECT opbel erdat
                      FROM eabp
                      INTO (<levering>-voorschotplan,<levering>-dat_vsp)
                      WHERE vertrag  EQ <levering>-contract
*               AND   deaktiv  EQ space
                      AND   erdat    EQ
                                 ( SELECT MIN( erdat )
                                         FROM eabp
                                   WHERE vertrag  EQ <levering>-contract ).
*                              AND deaktiv  EQ space ).

               ENDSELECT.
             ENDIF.
           ENDLOOP.


** uithuizingen
           LOOP AT tb_levering ASSIGNING <levering>
           WHERE switchtype EQ '76'.

             CLEAR tb_msgdata[].
             SELECT * FROM eideswtmsgdata
             INTO TABLE tb_msgdata
             WHERE switchnum EQ <levering>-switchnum.

*berichtendata toevoegen
             LOOP AT tb_msgdata.
               CASE tb_msgdata-category.
                 WHEN 'Z07'.
                   <levering>-ber15_dat = tb_msgdata-erdat.
                   <levering>-ber15_taskid = tb_msgdata-dextaskid.
                 WHEN 'Z06'.
                   <levering>-ber44_dat = tb_msgdata-erdat.
                   <levering>-rejectreason = tb_msgdata-zzrjct_reasn_id.
                 WHEN 'Z02'.
                   <levering>-ber95_dat = tb_msgdata-erdat.
                   <levering>-all_bericht_odat = tb_msgdata-erdat.
                 WHEN 'Z04'.
                   IF tb_msgdata-direction EQ '1'.
                     <levering>-ber210u_dat = tb_msgdata-erdat.
                   ELSE.
                     <levering>-ber300_dat = tb_msgdata-erdat.
                     <levering>-ber300_taskid = tb_msgdata-dextaskid.
                   ENDIF.
                 WHEN OTHERS.
               ENDCASE.
             ENDLOOP.

*contract- en uithuisdocument gegevens toevoegen
*{cHV 20051130
*      IF <levering>-contract EQ space
*      AND <levering>-vkont NE space
*      AND <levering>-anlage NE space.
             IF <levering>-huisd IS INITIAL.
*}cHV 20051130

               SELECT a~auszbeleg a~vertrag a~erdat
               INTO (<levering>-huisd,<levering>-contract,
                     <levering>-contract_dat)
                      FROM eausv AS a INNER JOIN
                           eaus  AS b ON
                           a~auszbeleg = b~auszbeleg
                           WHERE a~anlage   EQ <levering>-anlage
                            AND  a~auszdat  GE <levering>-verhuisdat "GE ipv GT
                            AND  a~storausz NE 'X'
                            AND  b~vkont    EQ <levering>-vkont.
               ENDSELECT.
             ENDIF.

**bepaal intern ? of externe ? partij (non-billable service)

             IF <levering>-startscenario CA '78'.
               SELECT vertrag
                      INTO <levering>-service_contract
                      FROM eservice
                      WHERE int_ui        EQ <levering>-int_ui
                       AND  service_end   EQ <levering>-verhuisdat
                       AND  serviceid     EQ <levering>-service_prov_old.
               ENDSELECT.
             ELSEIF <levering>-startscenario CA '9'.

               SELECT a~vertrag
                 FROM ever AS a INNER JOIN
                      eanl AS b ON
                      a~anlage = b~anlage
                 INTO <levering>-service_contract
                 WHERE  a~vkonto  EQ <levering>-vkont
                 AND    a~auszdat EQ <levering>-verhuisdat
                 AND    b~service IN ('ENET','GNET')..
               ENDSELECT.

             ENDIF.

********************facturatie
             SELECT  SINGLE abrsperr gemfakt
                     FROM ever
                     INTO (<levering>-contract_blok,<levering>-gemfakt)
                     WHERE vertrag  EQ <levering>-contract.


**   billingdoc
             SELECT belnr erdat
                    INTO (<levering>-afr_doc,<levering>-afr_doc_dat)
                    FROM erch
                    WHERE vertrag   EQ <levering>-contract
                     AND  abrvorg   EQ '03'
                     AND  stornodat EQ '00000000'
                     AND  erdat     EQ
                            ( SELECT MAX( erdat )
                                    FROM erch
                                  WHERE vertrag EQ <levering>-contract
                                    AND abrvorg EQ '03'
                                 AND  erdat   GE <levering>-contract_dat ).

             ENDSELECT.
             IF sy-subrc EQ 0.
**invoice
               SELECT opbel
                      INTO <levering>-slotnota
                      FROM erchc
                      WHERE belnr EQ <levering>-afr_doc
                      AND   simulated EQ space
                      AND   lfdnr     EQ
                      ( SELECT MAX( lfdnr )
                              FROM erchc
                             WHERE belnr     EQ <levering>-afr_doc
                               AND simulated EQ space ).
               ENDSELECT.
               IF sy-subrc EQ 0.
**afdrukdocument
                 SELECT SINGLE erdat
                        INTO <levering>-dat_sltn
                        FROM erdk
                        WHERE opbel EQ <levering>-slotnota.
               ENDIF.
             ENDIF.


           ENDLOOP.
           UPDATE zdte_levering FROM TABLE tb_levering.
         ENDIF.



*************************************************** analyse van switches

         IF sw_ana EQ 'X'.


           CLEAR tb_netwerk[].
           CLEAR tb_levering[].

           SELECT * FROM zdte_netwerk
           INTO TABLE tb_netwerk
           WHERE  switchtype  EQ '71'
           AND    switchnum  IN so_swdoc
           AND    start_dat  IN so_start
           AND    loevm      EQ space.



           LOOP AT tb_netwerk ASSIGNING <netwerk>
           WHERE switchtype EQ '71'.

             CLEAR: tb_msgdata[],
                    lv_partij.

             SELECT * FROM eideswtmsgdata
             INTO TABLE tb_msgdata
             WHERE switchnum EQ <netwerk>-switchnum.

*berichtendata toevoegen
             LOOP AT tb_msgdata.
               CASE tb_msgdata-category.
                 WHEN 'Z07'.
                   <netwerk>-ber20_dat = tb_msgdata-erdat.
                 WHEN 'Z09'.
                   <netwerk>-ber30_dat = tb_msgdata-erdat.
                   <netwerk>-ber30_taskid = tb_msgdata-dextaskid.
                 WHEN 'Z08'.
                   <netwerk>-ber40_dat = tb_msgdata-erdat.
                   <netwerk>-rejectreason = tb_msgdata-zzrjct_reasn_id.
                   <netwerk>-ber40_taskid = tb_msgdata-dextaskid.
                 WHEN 'Z03'.
                   IF tb_msgdata-direction EQ '1'.
                     <netwerk>-ber60_dat = tb_msgdata-erdat.
                   ELSE.
                     <netwerk>-ber70_dat = tb_msgdata-erdat.
                     <netwerk>-ber70_taskid = tb_msgdata-dextaskid.

                   ENDIF.
                 WHEN 'Z05'.
                   <netwerk>-ber140_dat = tb_msgdata-erdat.
                   <netwerk>-ber140_taskid = tb_msgdata-dextaskid.

                   IF NOT <netwerk>-ber70_dat EQ '00000000'.
                     <netwerk>-all_bericht_udat = tb_msgdata-erdat.
                   ENDIF.

                 WHEN 'Z04'.
                   IF tb_msgdata-direction EQ '1'.
                     <netwerk>-ber310_dat = tb_msgdata-erdat.
                   ELSE.
                     <netwerk>-ber200_dat = tb_msgdata-erdat.
                     <netwerk>-ber200_taskid = tb_msgdata-dextaskid.
                   ENDIF.
                 WHEN OTHERS.

               ENDCASE.

             ENDLOOP.


****het oude contract plus facturatie
             CLEAR:ll_vertrag,
                   ll_erdat,
                     ll_vkont,
                     ll_verhuisdatmin.

             ll_verhuisdatmin = <netwerk>-verhuisdat - 1.
* AUCT-UPGRADE -  Begin of Modification by <USER> on <17.02.2017> for <EHP8>
*      SELECT SINGLE vkonto FROM ever INTO ll_vkont
*      WHERE anlage EQ <netwerk>-anlage
*      AND einzdat LE ll_verhuisdatmin
*      AND auszdat EQ ll_verhuisdatmin.
             SELECT vkonto FROM ever INTO ll_vkont
                   WHERE anlage EQ <netwerk>-anlage
                   AND einzdat LE ll_verhuisdatmin
                   AND auszdat EQ ll_verhuisdatmin
             ORDER BY PRIMARY KEY.
               EXIT.
             ENDSELECT.
* AUCT-UPGRADE -  End of Modification by <USER> on <17.02.2017> for <EHP8>

             SELECT  a~vertrag a~erdat
                     INTO (ll_vertrag,ll_erdat)
                            FROM eausv AS a INNER JOIN
                                 eaus  AS b ON
                                 a~auszbeleg = b~auszbeleg
                                 WHERE a~anlage   EQ <netwerk>-anlage
                                  AND  a~auszdat  EQ
                                  ( SELECT MAX( auszdat )
                                           FROM ever
                                          WHERE anlage EQ <netwerk>-anlage
                                            AND  vkont  EQ ll_vkont
*<netwerk>-vkont
                                    AND  auszdat LE <netwerk>-verhuisdat )
                                  AND  a~storausz NE 'X'
                                  AND  b~vkont    EQ ll_vkont."<netwerk>-vkont.
             ENDSELECT.



********************facturatie
             SELECT  SINGLE abrsperr gemfakt
                     FROM ever
                     INTO (<netwerk>-contract_blok,<netwerk>-gemfakt)
                     WHERE vertrag  EQ ll_vertrag.


**   billingdoc
             SELECT belnr erdat
                    INTO (<netwerk>-afr_doc,<netwerk>-afr_doc_dat)
                    FROM erch
                    WHERE vertrag   EQ ll_vertrag "<netwerk>-contract
                     AND  abrvorg   EQ '03'
                     AND  stornodat EQ '00000000'
                     AND  erdat     EQ
                            ( SELECT MAX( erdat )
                                    FROM erch
                                  WHERE vertrag EQ ll_vertrag
                                    AND abrvorg EQ '03'
                                    AND  erdat  GE ll_erdat ).

             ENDSELECT.
             IF sy-subrc EQ 0.
**invoice
               SELECT opbel
                      INTO <netwerk>-slotnota
                      FROM erchc
                      WHERE belnr EQ <netwerk>-afr_doc
                      AND   simulated EQ space
                      AND   lfdnr     EQ
                      ( SELECT MAX( lfdnr )
                              FROM erchc
                             WHERE belnr     EQ <netwerk>-afr_doc
                               AND simulated EQ space ).
               ENDSELECT.
               IF sy-subrc EQ 0.
**afdrukdocument
                 SELECT SINGLE erdat
                        INTO <netwerk>-dat_sltn
                        FROM erdk
                        WHERE opbel EQ <netwerk>-slotnota.
               ENDIF.
             ENDIF.



*********************einde oude contract plus facturatie



*contract- en inhuisdocument gegevens toevoegen
             IF <netwerk>-contract EQ space
             AND <netwerk>-vkont NE space
             AND <netwerk>-anlage NE space.

               SELECT vertrag erdat abszyk
               FROM ever
               INTO
          (<netwerk>-contract,<netwerk>-contract_dat,<netwerk>-vsp_cyclus)
               WHERE anlage EQ <netwerk>-anlage
               AND   vkonto EQ <netwerk>-vkont
               AND  einzdat EQ <netwerk>-verhuisdat.
               ENDSELECT.


               SELECT einzbeleg
               FROM eeinv
               INTO <netwerk>-huisd
               WHERE vertrag EQ <netwerk>-contract.
               ENDSELECT.

             ENDIF.
**bepaal intern ? of externe ? partij (non-billable service)

             IF <netwerk>-startscenario CA '456'.
               SELECT vertrag
                      INTO <netwerk>-service_contract
                      FROM eservice
                      WHERE int_ui        EQ <netwerk>-int_ui
                       AND  service_end   EQ <netwerk>-verhuisdat
                       AND  serviceid     EQ <netwerk>-service_prov_old.
               ENDSELECT.
             ENDIF.

             IF <netwerk>-targetscenario CA '456'.
               SELECT vertrag
                      INTO <netwerk>-service_contract
                      FROM eservice
                      WHERE int_ui        EQ <netwerk>-int_ui
                       AND  service_start EQ <netwerk>-verhuisdat
                       AND  serviceid     EQ <netwerk>-service_prov_new.
               ENDSELECT.
             ENDIF.

********************facturatie

**voorschotmethode
             SELECT SINGLE kzabsver
                    FROM fkkvkp
                    INTO <netwerk>-vsp_methode
                    WHERE vkont EQ <netwerk>-vkont
                     AND  gpart EQ <netwerk>-partner.

**voorschotplan
             IF <netwerk>-vsp_methode NE '0'.
               SELECT opbel erdat
                      FROM eabp
                      INTO (<netwerk>-voorschotplan,<netwerk>-dat_vsp)
                      WHERE vertrag  EQ <netwerk>-contract
*               AND   deaktiv  EQ space
                      AND   erdat    EQ
                                 ( SELECT MIN( erdat )
                                         FROM eabp
                                   WHERE vertrag  EQ <netwerk>-contract ).
*                              AND deaktiv  EQ space ).

               ENDSELECT.
             ENDIF.

           ENDLOOP.

           UPDATE zdte_netwerk FROM TABLE tb_netwerk.

********      Levering gedeelte switches


           CLEAR tb_netwerk[].
           CLEAR tb_levering[].

           SELECT * FROM zdte_levering
           INTO TABLE tb_levering
           WHERE  switchtype IN ('72','73')
           AND    switchnum  IN so_swdoc
           AND    start_dat  IN so_start
           AND    loevm      EQ space.


**  nieuwe leverancier
           LOOP AT tb_levering ASSIGNING <levering>
           WHERE switchtype EQ '72'.

             CLEAR tb_msgdata[].
             SELECT * FROM eideswtmsgdata
             INTO TABLE tb_msgdata
             WHERE switchnum EQ <levering>-switchnum.

*berichtendata toevoegen
             LOOP AT tb_msgdata.
               CASE tb_msgdata-category.
                 WHEN 'Z07'.
                   <levering>-ber10_dat = tb_msgdata-erdat.
                   <levering>-ber10_taskid = tb_msgdata-dextaskid.
                 WHEN 'Z06'.
                   <levering>-ber45_dat = tb_msgdata-erdat.
                   <levering>-rejectreason = tb_msgdata-zzrjct_reasn_id.
                 WHEN 'Z01' .
                   <levering>-ber80_dat = tb_msgdata-erdat.
                 WHEN 'Z05'.
                   <levering>-ber150_dat = tb_msgdata-erdat.
                   IF NOT <levering>-ber80_dat EQ '00000000'.
                     <levering>-all_bericht_odat = tb_msgdata-erdat.
                   ENDIF.
                 WHEN 'Z04'.
                   IF tb_msgdata-direction EQ '1'.
                     <levering>-ber210i_dat = tb_msgdata-erdat.
                   ELSE.
                     <levering>-ber300_dat = tb_msgdata-erdat.
                     <levering>-ber300_taskid = tb_msgdata-dextaskid.
                   ENDIF.

                 WHEN OTHERS.

               ENDCASE.

             ENDLOOP.

*contract- en inhuisdocument gegevens toevoegen
             IF <levering>-contract EQ space
             AND <levering>-vkont NE space
             AND <levering>-anlage NE space.

               SELECT vertrag erdat abszyk
               FROM ever
               INTO
       (<levering>-contract,<levering>-contract_dat,<levering>-vsp_cyclus)
               WHERE anlage EQ <levering>-anlage
               AND   vkonto EQ <levering>-vkont
               AND  einzdat EQ <levering>-verhuisdat.
               ENDSELECT.

               SELECT einzbeleg
               FROM eeinv
               INTO <levering>-huisd
               WHERE vertrag EQ <levering>-contract.
               ENDSELECT.

             ENDIF.

             IF <levering>-targetscenario CA '78'.
               SELECT vertrag
                      INTO <levering>-service_contract
                      FROM eservice
                      WHERE int_ui        EQ <levering>-int_ui
                       AND  service_start EQ <levering>-verhuisdat
                       AND  serviceid     EQ <levering>-service_prov_new.
               ENDSELECT.
             ELSEIF <levering>-targetscenario CA '9'.
               SELECT a~vertrag
                 FROM ever AS a INNER JOIN
                      eanl AS b ON
                      a~anlage = b~anlage
                 INTO <levering>-service_contract
                 WHERE  a~vkonto  EQ <levering>-vkont
                 AND    a~einzdat EQ <levering>-verhuisdat
                 AND    b~service IN ('ENET','GNET')..
               ENDSELECT.
             ENDIF.


********************facturatie

**voorschotmethode
             SELECT SINGLE kzabsver
                    FROM fkkvkp
                    INTO <levering>-vsp_methode
                    WHERE vkont EQ <levering>-vkont
                     AND  gpart EQ <levering>-partner.

**voorschotplan
             IF <levering>-vsp_methode NE '0'.
               SELECT opbel erdat
                      FROM eabp
                      INTO (<levering>-voorschotplan,<levering>-dat_vsp)
                      WHERE vertrag  EQ <levering>-contract
*               AND   deaktiv  EQ space
                      AND   erdat    EQ
                                 ( SELECT MIN( erdat )
                                         FROM eabp
                                   WHERE vertrag  EQ <levering>-contract ).
*                              AND deaktiv  EQ space ).

               ENDSELECT.
             ENDIF.


           ENDLOOP.


**  oude leverancier
           LOOP AT tb_levering ASSIGNING <levering>
           WHERE switchtype EQ '73'.

             CLEAR tb_msgdata[].
             SELECT * FROM eideswtmsgdata
             INTO TABLE tb_msgdata
             WHERE switchnum EQ <levering>-switchnum.

*berichtendata toevoegen
             LOOP AT tb_msgdata.
               CASE tb_msgdata-category.
                 WHEN 'Z02'.
                   <levering>-ber90_dat = tb_msgdata-erdat.
                   <levering>-all_bericht_odat = tb_msgdata-erdat.
                 WHEN 'Z04'.
                   IF tb_msgdata-direction EQ '1'.
                     <levering>-ber210u_dat = tb_msgdata-erdat.
                   ENDIF.
                 WHEN OTHERS.
               ENDCASE.
             ENDLOOP.

*contract- en uithuisdocument gegevens toevoegen
             IF <levering>-contract EQ space
             AND <levering>-vkont NE space
             AND <levering>-anlage NE space.


               SELECT a~auszbeleg a~vertrag a~erdat
               INTO (<levering>-huisd,<levering>-contract,
                     <levering>-contract_dat)
                      FROM eausv AS a INNER JOIN
                           eaus  AS b ON
                           a~auszbeleg = b~auszbeleg
                           WHERE a~anlage   EQ <levering>-anlage
                            AND  a~auszdat  GE <levering>-verhuisdat "GE ipv GT
                            AND  a~storausz NE 'X'
                            AND  b~vkont    EQ <levering>-vkont.
               ENDSELECT.
             ENDIF.
*    endloop.


             IF <levering>-startscenario CA '78'.
               SELECT vertrag
                      INTO <levering>-service_contract
                      FROM eservice
                      WHERE int_ui        EQ <levering>-int_ui
                       AND  service_end   EQ <levering>-verhuisdat
                       AND  serviceid     EQ <levering>-service_prov_old.
               ENDSELECT.
             ELSEIF <levering>-startscenario CA '9'.

               SELECT a~vertrag
                 FROM ever AS a INNER JOIN
                      eanl AS b ON
                      a~anlage = b~anlage
                 INTO <levering>-service_contract
                 WHERE  a~vkonto  EQ <levering>-vkont
                 AND    a~auszdat EQ <levering>-verhuisdat
                 AND    b~service IN ('ENET','GNET')..
               ENDSELECT.

             ENDIF.
*//////////////////////////////////////
********************facturatie
             SELECT  SINGLE abrsperr gemfakt
                     FROM ever
                     INTO (<levering>-contract_blok,<levering>-gemfakt)
                     WHERE vertrag  EQ <levering>-contract.


**   billingdoc
             SELECT belnr erdat
                    INTO (<levering>-afr_doc,<levering>-afr_doc_dat)
                    FROM erch
                    WHERE vertrag   EQ <levering>-contract
                     AND  abrvorg   EQ '03'
                     AND  stornodat EQ '00000000'
                     AND  erdat     EQ
                            ( SELECT MAX( erdat )
                                    FROM erch
                                  WHERE vertrag EQ <levering>-contract
                                    AND abrvorg EQ '03'
                                 AND  erdat   GE <levering>-contract_dat ).

             ENDSELECT.
             IF sy-subrc EQ 0.
**invoice
               SELECT opbel
                      INTO <levering>-slotnota
                      FROM erchc
                      WHERE belnr EQ <levering>-afr_doc
                      AND   simulated EQ space
                      AND   lfdnr     EQ
                      ( SELECT MAX( lfdnr )
                              FROM erchc
                             WHERE belnr     EQ <levering>-afr_doc
                               AND simulated EQ space ).
               ENDSELECT.
               IF sy-subrc EQ 0.
**afdrukdocument
                 SELECT SINGLE erdat
                        INTO <levering>-dat_sltn
                        FROM erdk
                        WHERE opbel EQ <levering>-slotnota.
               ENDIF.
             ENDIF.


           ENDLOOP.
           UPDATE zdte_levering FROM TABLE tb_levering.
         ENDIF.


*\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
*    update zdte_levering from table tb_levering.

*  endif.

**************************************************einde levering

         IF el_ana EQ 'X'.

           CLEAR tb_netwerk[].
           CLEAR tb_levering[].

           SELECT * FROM zdte_netwerk
           INTO TABLE tb_netwerk
           WHERE  switchtype EQ '78'
           AND    switchnum  IN so_swdoc
           AND    start_dat  IN so_start
           AND    loevm      EQ space.


** einde levering
           LOOP AT tb_netwerk ASSIGNING <netwerk>
           WHERE switchtype EQ '78'.

             CLEAR tb_msgdata[].
             SELECT * FROM eideswtmsgdata
             INTO TABLE tb_msgdata
             WHERE switchnum EQ <netwerk>-switchnum.

*berichtendata toevoegen
             LOOP AT tb_msgdata.
               CASE tb_msgdata-category.
                 WHEN 'Z07'.
                   <netwerk>-ber28_dat = tb_msgdata-erdat.
                 WHEN 'Z09'.
                   <netwerk>-ber30_dat = tb_msgdata-erdat.
                 WHEN 'Z08'.
                   <netwerk>-ber40_dat = tb_msgdata-erdat.
                   <netwerk>-rejectreason = tb_msgdata-zzrjct_reasn_id.
                   <netwerk>-ber40_taskid = tb_msgdata-dextaskid.
                 WHEN 'Z02'.
                   IF tb_msgdata-direction EQ '1'.
                     <netwerk>-ber68_dat = tb_msgdata-erdat.
                   ELSE.
                     <netwerk>-ber78_dat = tb_msgdata-erdat.
                     <netwerk>-ber78_taskid = tb_msgdata-dextaskid.
                     <netwerk>-all_bericht_udat = tb_msgdata-erdat.
                   ENDIF.
                 WHEN 'Z05'.
                   <netwerk>-ber140_dat = tb_msgdata-erdat.
                   <netwerk>-ber140_taskid = tb_msgdata-dextaskid.
                 WHEN 'Z04'.
                   IF tb_msgdata-direction EQ '1'.
                     <netwerk>-ber310_dat = tb_msgdata-erdat.
                   ELSE.
                     <netwerk>-ber200_dat = tb_msgdata-erdat.
                     <netwerk>-ber200_taskid = tb_msgdata-dextaskid.
                   ENDIF.
                 WHEN OTHERS.
               ENDCASE.
             ENDLOOP.

*contract- en uithuisdocument gegevens toevoegen
             IF <netwerk>-contract EQ space
             AND <netwerk>-vkont NE space
             AND <netwerk>-anlage NE space.


               SELECT a~auszbeleg a~vertrag a~erdat
          INTO (<netwerk>-huisd,<netwerk>-contract,<netwerk>-contract_dat)
                      FROM eausv AS a INNER JOIN
                           eaus  AS b ON
                           a~auszbeleg = b~auszbeleg
                           WHERE a~anlage   EQ <netwerk>-anlage
                            AND  a~auszdat  GE <netwerk>-verhuisdat "GE ipv GT
                            AND  a~storausz NE 'X'
                            AND  b~vkont    EQ <netwerk>-vkont.
               ENDSELECT.


             ENDIF.

**bepaal intern ? of externe ? partij (non-billable service)



             IF <netwerk>-startscenario CA '456'.
               SELECT vertrag
                      INTO <netwerk>-service_contract
                      FROM eservice
                      WHERE int_ui        EQ <netwerk>-int_ui
                       AND  service_end   EQ <netwerk>-verhuisdat
                       AND  serviceid     EQ <netwerk>-service_prov_old.
               ENDSELECT.
             ENDIF.

           ENDLOOP.


           UPDATE zdte_netwerk FROM TABLE tb_netwerk.

********      Levering gedeelte einde levering


           CLEAR tb_netwerk[].
           CLEAR tb_levering[].

           SELECT * FROM zdte_levering
           INTO TABLE tb_levering
           WHERE  switchtype EQ '78'
           AND    switchnum  IN so_swdoc
           AND    start_dat  IN so_start
           AND    loevm      EQ space.




** einde levering
           LOOP AT tb_levering ASSIGNING <levering>
           WHERE switchtype EQ '78'.

             CLEAR tb_msgdata[].
             SELECT * FROM eideswtmsgdata
             INTO TABLE tb_msgdata
             WHERE switchnum EQ <levering>-switchnum.

*berichtendata toevoegen
             LOOP AT tb_msgdata.
               CASE tb_msgdata-category.
                 WHEN 'Z07'.
                   <levering>-ber18_dat = tb_msgdata-erdat.
                   <levering>-ber18_taskid = tb_msgdata-dextaskid.
                 WHEN 'Z06'.
                   <levering>-ber44_dat = tb_msgdata-erdat.
                   <levering>-rejectreason = tb_msgdata-zzrjct_reasn_id.
                 WHEN 'Z02'.
                   <levering>-ber98_dat = tb_msgdata-erdat.
                   <levering>-all_bericht_odat = tb_msgdata-erdat.
                 WHEN 'Z04'.
                   IF tb_msgdata-direction EQ '1'.
                     <levering>-ber210u_dat = tb_msgdata-erdat.
                   ELSE.
                     <levering>-ber300_dat = tb_msgdata-erdat.
                     <levering>-ber300_taskid = tb_msgdata-dextaskid.
                   ENDIF.
                 WHEN OTHERS.
               ENDCASE.
             ENDLOOP.

*contract- en uithuisdocument gegevens toevoegen
             IF <levering>-contract EQ space
             AND <levering>-vkont NE space
             AND <levering>-anlage NE space.


               SELECT a~auszbeleg a~vertrag a~erdat
               INTO (<levering>-huisd,<levering>-contract,
                     <levering>-contract_dat)
                      FROM eausv AS a INNER JOIN
                           eaus  AS b ON
                           a~auszbeleg = b~auszbeleg
                           WHERE a~anlage   EQ <levering>-anlage
                            AND  a~auszdat  GE <levering>-verhuisdat "GE ipv GT
                            AND  a~storausz NE 'X'
                            AND  b~vkont    EQ <levering>-vkont.
               ENDSELECT.
             ENDIF.

**bepaal intern ? of externe ? partij (non-billable service)

             IF <levering>-startscenario CA '78'.
               SELECT vertrag
                      INTO <levering>-service_contract
                      FROM eservice
                      WHERE int_ui        EQ <levering>-int_ui
                       AND  service_end   EQ <levering>-verhuisdat
                       AND  serviceid     EQ <levering>-service_prov_old.
               ENDSELECT.
             ELSEIF <levering>-startscenario CA '9'.

               SELECT a~vertrag
                 FROM ever AS a INNER JOIN
                      eanl AS b ON
                      a~anlage = b~anlage
                 INTO <levering>-service_contract
                 WHERE  a~vkonto  EQ <levering>-vkont
                 AND    a~auszdat EQ <levering>-verhuisdat
                 AND    b~service IN ('ENET','GNET')..
               ENDSELECT.

             ENDIF.
********************facturatie
             SELECT  SINGLE abrsperr gemfakt
                     FROM ever
                     INTO (<levering>-contract_blok,<levering>-gemfakt)
                     WHERE vertrag  EQ <levering>-contract.


**   billingdoc
             SELECT belnr erdat
                    INTO (<levering>-afr_doc,<levering>-afr_doc_dat)
                    FROM erch
                    WHERE vertrag   EQ <levering>-contract
                     AND  abrvorg   EQ '03'
                     AND  stornodat EQ '00000000'
                     AND  erdat     EQ
                            ( SELECT MAX( erdat )
                                    FROM erch
                                  WHERE vertrag EQ <levering>-contract
                                    AND abrvorg EQ '03'
                                 AND  erdat   GE <levering>-contract_dat ).

             ENDSELECT.
             IF sy-subrc EQ 0.
**invoice
               SELECT opbel
                      INTO <levering>-slotnota
                      FROM erchc
                      WHERE belnr EQ <levering>-afr_doc
                      AND   simulated EQ space
                      AND   lfdnr     EQ
                      ( SELECT MAX( lfdnr )
                              FROM erchc
                             WHERE belnr     EQ <levering>-afr_doc
                               AND simulated EQ space ).
               ENDSELECT.
               IF sy-subrc EQ 0.
**afdrukdocument
                 SELECT SINGLE erdat
                        INTO <levering>-dat_sltn
                        FROM erdk
                        WHERE opbel EQ <levering>-slotnota.
               ENDIF.
             ENDIF.

           ENDLOOP.
           UPDATE zdte_levering FROM TABLE tb_levering.
         ENDIF.
