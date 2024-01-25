*++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*
* CHANGE ID : HANA-001
* USER: ACC11364892
* DATE: 01.08.2017
* TR : S7HK900392
* DESCRIPTION: HANA CORRECTION
* TEAM : HANA-MIGRATION
*++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*
REPORT ztest_view.
*DATA:  vl_name_text TYPE  name_text.
*    SELECT SINGLE name_text INTO vl_name_text FROM user_addrp
*     WHERE bname = sy-uname.
SELECT ktopl
       ktplt
       INTO TABLE t_t004t_1403
       FROM t004t
       FOR ALL ENTRIES IN t_t004_1403
       WHERE spras = 'EN'                     "SNooka
       AND ktopl = t_t004_1403-ktopl.
* HANA Corrections - BEGIN OF MODIFY - <HANA-001>
SORT t_t004t_1403 BY ktopl .
* HANA Corrections - END OF MODIFY - <HANA-001>
IF sy-subrc EQ 0.
  READ TABLE t_t004t_1403 INTO w_t004t_1403
      WITH KEY ktopl = w_t004_1403-ktopl BINARY SEARCH. "SNooka
