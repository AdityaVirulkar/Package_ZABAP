*&---------------------------------------------------------------------*
*& Include ZTEST_CONSO_DUMP
*&---------------------------------------------------------------------*

*++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*
* CHANGE ID : HANA-001
* USER: ACC11364892
* DATE: 30.06.2017
* TR : S7HK900444
* DESCRIPTION: HANA CORRECTION
* TEAM : HANA-MIGRATION
*++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*
DATA: it_bseg TYPE STANDARD TABLE OF bseg,
      wa_bseg TYPE bseg.

SELECT * FROM bseg
INTO CORRESPONDING FIELDS OF TABLE it_bseg.
