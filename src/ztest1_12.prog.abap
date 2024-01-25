*&---------------------------------------------------------------------*
*& Report ZTEST1_12
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
*++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*
* CHANGE ID : HANA-001
* USER: ACC11346068
* DATE: 01.06.2017
* TR : S7HK900166
* DESCRIPTION: HANA CORRECTION
* TEAM : HANA-MIGRATION
*++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*
REPORT ztest1_12.
DATA: i_atflv TYPE atflv.

* AUCT-UPGRADE -  Begin of Modification by <USER> on <17.02.2017> for <EHP8>
* SELECT single atflv  FROM  ausp into i_atflv
*         WHERE  objek  = i_objek
*         AND    atinn  = '0000014356'  " From CABN PO_ORDER_VALUE_USD'
*         "AND    atzhl  = ___
*         AND    mafid  = 'O'
*         AND    klart  = '032'.
SELECT atflv FROM ausp INTO i_atflv
         WHERE  objek  = i_objek
         AND    atinn  = '0000014356'  " From CABN PO_ORDER_VALUE_USD'
         "AND    atzhl  = ___
         AND    mafid  = 'O'
         AND    klart  = '032'
ORDER BY PRIMARY KEY.
  EXIT.
ENDSELECT.
* AUCT-UPGRADE -  End of Modification by <USER> on <17.02.2017> for <EHP8>
