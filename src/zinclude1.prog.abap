*----------------------------------------------------------------------*
* Author        : ACC11346068                                               *
* Date          : 05/31/17                                             *
* Change Marker : S7HK900166                                           *
* Description   : HANA Corrections                                     *
*----------------------------------------------------------------------*
*HANA UPGRADE- BEGIN OF MODIFY <S7HK900166>
*SELECT * FROM vbap INTO TABLE it_vbap
*           WHERE posnr = '10'.
SELECT * FROM vbap INTO TABLE it_vbap
           WHERE posnr = '10'
ORDER BY PRIMARY KEY.
*HANA UPGRADE- END OF MODIFY <S7HK900166>
IF sy-subrc EQ 0.
  READ TABLE it_vbap INTO wa_vbap WITH KEY posnr = '10' BINARY SEARCH.
  IF sy-subrc EQ 0.
  ENDIF.
ENDIF.
*HANA UPGRADE- BEGIN OF MODIFY <S7HK900166>
*SELECT bukrs belnr gjahr buzei FROM bseg INTO TABLE it_bseg WHERE belnr = '1900000089'.
SELECT bukrs belnr gjahr buzei FROM bseg INTO TABLE it_bseg WHERE belnr = '1900000089'
ORDER BY PRIMARY KEY.
*HANA UPGRADE- END OF MODIFY <S7HK900166>
IF sy-subrc = 0.
ENDIF.
