* HANA Corrections - BEGIN OF MODIFY - <HANA-001>
*SELECT bukrs belnr gjahr buzei FROM bseg INTO TABLE it_bseg WHERE belnr = '1900000089'.
*++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*
* CHANGE ID : HANA-001
*1.) ACC11346068
*       BHARDWAA                             CR0093193* 31.05.2017
* TR : S7HK900166
* DESCRIPTION: HANA CORRECTION
* TEAM : HANA-MIGRATION
*++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*
SELECT bukrs belnr gjahr buzei FROM bseg INTO TABLE it_bseg WHERE belnr = '1900000089'
ORDER BY PRIMARY KEY.
* HANA Corrections - END OF MODIFY - <HANA-001>
IF sy-subrc = 0.
ENDIF.
