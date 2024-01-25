*----------------------------------------------------------------------*
* Author        : ACC11364892                                               *
* Date          : 05/02/17                                             *
* Change Marker : S7HK900293                                           *
* Description   : HANA Corrections                                     *
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Report ZTEST_AM54
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ztest_am54.

*TYPES: BEGIN OF ty_bkpf,
*         bukrs TYPE  bukrs,
*         belnr TYPE belnr_d,
*         blart TYPE blart,
*       END OF ty_bkpf,
*
*       BEGIN OF ty_bseg,
*         bukrs TYPE  bukrs,
*         belnr TYPE belnr_d,
*         gjahr TYPE gjahr,
*       END OF ty_bseg.
*
*DATA: it_bkpf TYPE STANDARD TABLE OF ty_bkpf .
*DATA: it_bseg TYPE SORTED TABLE OF ty_bseg WITH UNIQUE KEY belnr .
*
*SELECT bukrs
*       belnr
*       blart
*  FROM bkpf
*  INTO TABLE it_bkpf.
*
*
*
*IF it_bkpf IS NOT INITIAL .
*  SELECT bukrs belnr
*         gjahr
*    FROM bseg
*    INTO TABLE it_bseg
*    FOR ALL ENTRIES IN it_bkpf
*    WHERE bukrs = it_bkpf-bukrs
*        AND belnr = it_bkpf-belnr.
*  IF sy-subrc = 0.
*
*  ENDIF.
*ENDIF.

SELECT A~ANLAGE INTO LS_EASTS-ANLAGE
  FROM EASTS AS A
  INNER JOIN ETDZ AS B ON A~LOGIKZW = B~LOGIKZW
  WHERE
*  A~ANLAGE = <FS_EABL_INST>-ANLAGE
*  AND A~AB LE <FS_EABL_INST>-ADAT
*  AND A~BIS GE <FS_EABL_INST>-ADAT
*  AND B~AB LE <FS_EABL_INST>-ADAT
*  AND B~BIS GE <FS_EABL_INST>-ADAT
*  AND B~ZWNUMMER EQ <FS_EABL_INST>-ZWNUMMER
    B~NABLESEN EQ 'X'
ORDER BY PRIMARY KEY.
EXIT.
ENDSELECT.
