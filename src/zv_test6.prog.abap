METHOD fb08_posting_reverse.

  DATA: lt_blntab TYPE TABLE OF blntab.

  DATA: ls_bkpf_key TYPE bkpf_key.
  DATA: l_budat     TYPE budat.
  DATA: l_stblg     TYPE stblg.
  DATA: l_stgrd     TYPE stgrd.
  DATA: l_mandt     TYPE mandt.                             "#EC NEEDED

  DATA: l_subrc  TYPE sy-subrc.
  DATA: ls_fimsg TYPE fimsg.

  DATA: l_doc_sap TYPE string.
  DATA: l_text TYPE text200.

* Verifico si ya se anulo el documento
  SELECT SINGLE bukrs belnr gjahr budat stblg
    FROM bkpf INTO (ls_bkpf_key-bukrs, ls_bkpf_key-belnr, ls_bkpf_key-gjahr,
                    l_budat,
                    l_stblg)
    WHERE bukrs = gs_header-bukrs
      AND bstat = space             " Documento normal
      AND xblnr = gs_header-xblnr
      AND stblg = space.                                    "#EC *
  IF sy-subrc NE 0.
    SELECT SINGLE mandt
      FROM bkpf INTO l_mandt
      WHERE bukrs = gs_header-bukrs
        AND bstat = space             " Documento normal
        AND xblnr = gs_header-xblnr.                        "#EC *
    IF sy-subrc NE 0.
      " El documento no existe.
      add_message( i_msgty = 'E'
                   i_text  = text-017 ).
    ELSE.
      " El documento ya se encuentra anulado.
      add_message( i_msgty = 'S'
                   i_text  = text-018 ).
    ENDIF.
    EXIT.
  ENDIF.

  IF l_budat(4) = sy-datum(4).
    l_stgrd = e_stgrd_per_actual.
  ELSE.
    l_stgrd = e_stgrd_fe_docto.
  ENDIF.

  IF g_open = abap_false.
    posting_interface_start( ).
  ENDIF.

  IF g_open = abap_true.
    CLEAR: l_subrc, ls_fimsg.
    CALL FUNCTION 'ZPOSTING_INTERFACE_REVERSE_DOC'
      EXPORTING
        i_belns   = ls_bkpf_key-belnr
        i_budat   = gs_header-budat
        i_bukrs   = ls_bkpf_key-bukrs
        i_gjahs   = ls_bkpf_key-gjahr
        i_tcode   = e_tcode_reverse
        i_stgrd   = l_stgrd
        i_no_auth = abap_true
      IMPORTING
        e_msgid   = ls_fimsg-msgid
        e_msgno   = ls_fimsg-msgno
        e_msgty   = ls_fimsg-msgty
        e_msgv1   = ls_fimsg-msgv1
        e_msgv2   = ls_fimsg-msgv2
        e_msgv3   = ls_fimsg-msgv3
        e_msgv4   = ls_fimsg-msgv4
        e_subrc   = l_subrc
      TABLES
        t_blntab  = lt_blntab
      EXCEPTIONS
        OTHERS    = 1.

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
      CONCATENATE ls_bkpf_key-bukrs ls_bkpf_key-belnr ls_bkpf_key-gjahr
             INTO l_doc_sap SEPARATED BY space.
      " Se anuló el documento (&).
      l_text = text-019.
      REPLACE '&' IN l_text WITH l_doc_sap IN CHARACTER MODE.
      add_message( i_msgty = 'S'
                   i_text  = l_text ).
    ENDIF.
  ENDIF.

ENDMETHOD.
