METHOD fb05_posting_clearing.

  DATA: lt_fttax  TYPE TABLE OF fttax.
  DATA: lt_blntab TYPE TABLE OF blntab,
        ls_blntab TYPE blntab.

  DATA: l_lines  TYPE i.
  DATA: ls_bkpf_key TYPE bkpf_key.
  DATA: l_doc_sap TYPE string.
  DATA: l_text TYPE text200.

  DATA: l_subrc  TYPE sy-subrc.
  DATA: ls_fimsg TYPE fimsg.

* Verifico cantidad de documentos a compensar
  l_lines = LINES( gt_doc ).
  IF l_lines EQ 0.
    " Faltan referencias a documentos cobrados.
    add_message( i_msgty = 'E'
                 i_text  = text-020 ).
    EXIT.
  ENDIF.

** Verifico cantidad de items
*  l_lines = LINES( gt_item ).
*  IF l_lines LT 1.
*    " Falta el detalle del documento.
*    add_message( i_msgty = 'E'
*                 i_text  = text-014 ).
*    EXIT.
*  ENDIF.

* Verifico si ya se creo el documento
  SELECT SINGLE mandt bukrs belnr gjahr
    FROM bkpf INTO ls_bkpf_key
    WHERE bukrs = gs_header-bukrs
      AND bstat = space             " Documento normal
      AND xblnr = gs_header-xblnr                           "#EC *
      AND stblg = space.
  IF sy-subrc = 0.

    " El documento ya se encuentra contabilizado (&).
    l_text = text-015.
    CONCATENATE ls_bkpf_key-bukrs ls_bkpf_key-belnr ls_bkpf_key-gjahr INTO l_doc_sap SEPARATED BY space.
    REPLACE '&' IN l_text WITH l_doc_sap IN CHARACTER MODE.
    add_message( i_msgty = 'S'
                 i_text  = l_text ).
    EXIT.
  ENDIF.

  IF g_open = abap_false.
    posting_interface_start( ).
  ENDIF.

  IF g_open = abap_true.
    CLEAR gs_ftpost.
    REFRESH: gt_ftpost, gt_ftclear, gt_clear_amounts.

    " Cabecera
    fill_header( ).

    " Items
    TRY.
        fill_items( ).
      CATCH cx_rs_error .
        EXIT.
    ENDTRY.

    " Partidas a compensar
    TRY.
        fill_cleared_items( ).
      CATCH cx_rs_error .
        EXIT.
    ENDTRY.

    CLEAR: l_subrc, ls_fimsg.
    CALL FUNCTION 'ZPOSTING_INTERFACE_CLEARING'
      EXPORTING
        i_auglv         = e_auglv_entrada_pago
        i_tcode         = e_tcode_clear
        i_no_auth       = abap_true
      IMPORTING
        e_msgid         = ls_fimsg-msgid
        e_msgno         = ls_fimsg-msgno
        e_msgty         = ls_fimsg-msgty
        e_msgv1         = ls_fimsg-msgv1
        e_msgv2         = ls_fimsg-msgv2
        e_msgv3         = ls_fimsg-msgv3
        e_msgv4         = ls_fimsg-msgv4
        e_subrc         = l_subrc
      TABLES
        t_blntab        = lt_blntab
        t_ftclear       = gt_ftclear
        t_ftpost        = gt_ftpost
        t_fttax         = lt_fttax
        t_clear_amounts = gt_clear_amounts
      EXCEPTIONS
        OTHERS          = 1.

    IF sy-subrc NE 0.
      " Mensaje de error
      MESSAGE ID sy-msgid TYPE 'E' NUMBER sy-msgno
         WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4
         INTO l_text.
      add_message( i_msgty = 'E'
                   i_text  = l_text ).
    ELSEIF l_subrc NE 0.
*      " Mensaje de error
      MESSAGE ID ls_fimsg-msgid TYPE 'E' NUMBER ls_fimsg-msgno
         WITH ls_fimsg-msgv1 ls_fimsg-msgv2 ls_fimsg-msgv3 ls_fimsg-msgv4
         INTO l_text.
      add_message( i_msgty = 'E'
                   i_text  = l_text ).
    ELSE.
      CLEAR l_doc_sap.
      READ TABLE lt_blntab INTO ls_blntab INDEX 1.
      IF sy-subrc = 0.
        CONCATENATE ls_blntab-bukrs ls_blntab-belnr ls_blntab-gjahr INTO l_doc_sap SEPARATED BY space.
      ENDIF.
      " Se contabilizó el documento (&).
      l_text = text-016.
      REPLACE '&' IN l_text WITH l_doc_sap IN CHARACTER MODE.
      add_message( i_msgty = 'S'
                   i_text  = l_text ).
    ENDIF.
  ENDIF.

ENDMETHOD.
