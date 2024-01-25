*& RDCK909544  | Estanislao    | 23.11.2009 | Cobros en cero           *
*&               search key: *Begin(INS) @001
*&---------------------------------------------------------------------*
METHOD fill_cleared_items.

  TYPES: BEGIN OF lty_bseg,
**** Inicio modificación - MAGASB00C - 23/03/2010
         belnr TYPE bseg-belnr,   "LN
         gjahr TYPE bseg-gjahr,   "LN
**** Fin modificación - MAGASB00C - 23/03/2010
         buzei TYPE bseg-buzei,
         umskz TYPE bseg-umskz,
         kunnr TYPE bseg-kunnr,
         wrbtr TYPE bseg-wrbtr,
         END OF lty_bseg.

  DATA: ls_bkpf_key TYPE bkpf_key.
  DATA: ls_doc      TYPE gty_doc.

  DATA: lt_bseg  TYPE TABLE OF lty_bseg,
        ls_bseg  TYPE lty_bseg.

  DATA: ls_clear_amounts TYPE zfi_clearing_amounts.

* Inicio Modificación Jorge Robla

* Variables
  DATA: l_rebzg TYPE rebzg,
        l_flag  TYPE i VALUE 0,
        l_bukrs TYPE bukrs.

* Fin Modificación Jorge Robla

* Obtengo partidas a compensar
  LOOP AT gt_doc INTO ls_doc.

    SELECT SINGLE mandt bukrs belnr gjahr
      FROM bkpf INTO ls_bkpf_key
      WHERE bukrs = gs_header-bukrs
        AND bstat = space           "Documento normal
        AND xblnr = ls_doc-xblnr
        AND stblg = space.          "No anulado
                                                            "#EC *

    IF sy-subrc = 0.
      SELECT
**** Inicio modificación - MAGASB00C - 23/03/2010
*        buzei umskz kunnr wrbtr      "LB
         belnr gjahr buzei umskz kunnr wrbtr      "LN
**** Fin modificación - MAGASB00C - 23/03/2010
        FROM bseg INTO TABLE lt_bseg
        WHERE bukrs = ls_bkpf_key-bukrs
          AND belnr = ls_bkpf_key-belnr
          AND gjahr = ls_bkpf_key-gjahr
          AND augbl = space  " No compensado
          AND umskz = ls_doc-umskz
          AND koart  = 'D'.  " Deudor
    ENDIF.

    IF sy-subrc NE 0.
      " No se encontraron todas las partidas a compensar.
      add_message( i_msgty = 'E'
                   i_text  = text-021 ).
      RAISE EXCEPTION TYPE cx_rs_error.

**** Inicio modificación - MAGASB00C - 23/03/2010
    ELSE.

*** Inicio modificación - MAGASB00C - 04/05/2010 - WO#PRUEBA
*      IF NOT gs_header-xfeld IS INITIAL. "LB
      IF gs_header-xfeld EQ 'N'.
*** Fin modificación - MAGASB00C - 04/05/2010 - WO#PRUEBA
*       Busca pagos parciales anteriores
        SELECT  belnr gjahr buzei umskz kunnr wrbtr
          FROM bseg
          APPENDING TABLE lt_bseg
          WHERE bukrs = ls_bkpf_key-bukrs
            AND rebzg = ls_bkpf_key-belnr
            AND rebzj = ls_bkpf_key-gjahr
            AND augbl = space  " No compensado
            AND umskz = ls_doc-umskz
            AND koart  = 'D'.  " Deudor
      ENDIF.
**** Fin modificación - MAGASB00C - 23/03/2010
    ENDIF.

    LOOP AT lt_bseg INTO ls_bseg.
      CLEAR gs_ftclear.
      gs_ftclear-agkoa = 'D'.
      gs_ftclear-agkon = ls_bseg-kunnr.
      gs_ftclear-agbuk = ls_bkpf_key-bukrs.
      gs_ftclear-xnops = abap_true.
      IF ls_bseg-umskz IS NOT INITIAL.
        gs_ftclear-agums = ls_bseg-umskz.
      ENDIF.
      gs_ftclear-selfd = 'BELNR'.
**** Inicio modificación - MAGASB00C - 23/03/2010
*      CONCATENATE ls_bkpf_key-belnr    "LB
*                  ls_bkpf_key-gjahr    "LB
*                  ls_bseg-buzei INTO gs_ftclear-selvon.    "LB

      CONCATENATE ls_bseg-belnr   "LN
                  ls_bseg-gjahr   "LN
                  ls_bseg-buzei INTO gs_ftclear-selvon.   "LN
**** Fin modificación - MAGASB00C - 23/03/2010
      INSERT gs_ftclear INTO TABLE gt_ftclear.

*Begin(INS) @001 {
*** Inicio modificación - MAGASB00C - 04/05/2010 - WO#PRUEBA
*      IF gs_header-xfeld IS INITIAL. "LB
      IF ( gs_header-xfeld IS INITIAL ) OR ( gs_header-xfeld EQ 'X' ).
*** Fin modificación - MAGASB00C - 04/05/2010 - WO#PRUEBA
* End (INS) @001 }
        IF ls_doc-wrbtr NE ls_bseg-wrbtr.
          CLEAR ls_clear_amounts.
          ls_clear_amounts-belnr = ls_bkpf_key-belnr.
          ls_clear_amounts-gjahr = ls_bkpf_key-gjahr.
          ls_clear_amounts-buzei = ls_bseg-buzei.
          ls_clear_amounts-wrbtr = ls_doc-wrbtr.
          INSERT ls_clear_amounts INTO TABLE gt_clear_amounts.
*Begin of change - ESPINOSAG00C - WO#1559514
*To can take the value and resolve the comparation
        ELSE.
          EXPORT ls_doc-wrbtr = ls_doc-wrbtr TO MEMORY ID 'WO#1559514'.
*End of change - ESPINOSAG00C - WO#1559514
        ENDIF.

* Inicio Modificación Jorge Robla

        IF gs_header-xfeld EQ 'X'
              AND l_flag EQ 0.

          CLEAR: l_rebzg,
                 l_bukrs.

          SELECT SINGLE rebzg
            FROM bseg
            INTO l_rebzg
           WHERE bukrs EQ gs_header-bukrs
             AND belnr EQ ls_bseg-belnr
             AND gjahr EQ ls_bseg-gjahr
             AND buzei EQ ls_bseg-buzei.

          IF sy-subrc IS INITIAL.

              IF l_rebzg IS INITIAL.

                MOVE 1 TO l_flag.

                EXPORT l_flag  FROM l_flag          TO MEMORY ID 'WO#1682963'.

                EXPORT l_bukrs FROM gs_header-bukrs TO MEMORY ID 'WO#1682963-1'.

              ENDIF.

          ENDIF.

        ENDIF.

* Fin Modificación Jorge Robla

*Begin(INS) @001 {
      ENDIF.
* End (INS) @001 }

    ENDLOOP.
  ENDLOOP.

ENDMETHOD.
