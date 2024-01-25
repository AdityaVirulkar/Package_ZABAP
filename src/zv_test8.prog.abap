 Report zv_test8.
   SELECT banfn                           "Purchase Requistion No
           bnfpo
           statu
           ekgrp
           txz01
           matnr
           werks
           menge
           preis
           peinh
           knttp
           lifnr
           ekorg
           waers
           banpr
           FROM eban
           INTO TABLE i_pr_no
           WHERE banfn IN r_banfn.
 i_pr_no_total_value[] = i_pr_no[].
LOOP AT i_pr_no_total_value INTO wa_pr_no_total_value
              WHERE banfn = pr_no_line-banfn.
        AT END OF banfn.
          g_total_value = l_total_value.
          CONDENSE g_total_value.
        ENDAT.
      ENDLOOP.
