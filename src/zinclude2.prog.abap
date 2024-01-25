*----------------------------------------------------------------------*
* Author        : ACC11346068                                               *
* Date          : 05/31/17                                             *
* Change Marker : S7HK900166                                           *
* Description   : HANA Corrections                                     *
*----------------------------------------------------------------------*
DATA: lt_vbap1 TYPE STANDARD TABLE OF vbap,
      ls_vbap1 TYPE vbap,
      lt_likp  TYPE TABLE OF likp,
      ls_likp  TYPE likp,
      lt_lips  TYPE TABLE OF lips,
      ls_lips  TYPE lips,
      lt_vbrk  TYPE STANDARD TABLE OF vbrk,
      ls_vbrk  TYPE vbrk.
*HANA UPGRADE- BEGIN OF MODIFY <S7HK900166>
*SELECT * FROM vbap INTO TABLE lt_vbap1 UP TO 10 ROWS WHERE vbeln = '0000000031'
*  AND posnr = '20' .
SELECT * FROM vbap INTO TABLE lt_vbap1 UP TO 10 ROWS WHERE vbeln = '0000000031'
  AND posnr = '20'
ORDER BY PRIMARY KEY.
*HANA UPGRADE- END OF MODIFY <S7HK900166>
LOOP AT lt_vbap1 INTO ls_vbap1.
  ls_vbap1-matnr = 'S4FG7002'.
  MODIFY lt_vbap1 FROM ls_vbap1 INDEX sy-tabix TRANSPORTING matnr.
ENDLOOP.

SELECT * FROM likp INTO TABLE lt_likp.
IF sy-subrc IS INITIAL .
  SELECT *  FROM lips  INTO TABLE lt_lips.
ENDIF.
IF sy-subrc IS INITIAL.
  SELECT * FROM vbrk INTO TABLE lt_vbrk.
ENDIF.
LOOP AT lt_likp INTO ls_likp.
  LOOP AT lt_lips INTO ls_lips WHERE vbeln EQ ls_likp-vbeln.
    LOOP AT lt_vbrk INTO ls_vbrk WHERE vbeln EQ ls_lips-vbeln.
    ENDLOOP.
  ENDLOOP.
ENDLOOP.
