METHOD fbra_posting_reverse.

  DATA: l_subrc  TYPE sy-subrc.
  DATA: ls_fimsg TYPE fimsg.

  DATA: ls_bkpf_key TYPE bkpf_key.
  DATA: l_stblg     TYPE stblg.

  DATA: l_text TYPE text200.

* Verifico si ya se anuló el documento
  SELECT SINGLE bukrs belnr gjahr stblg
    FROM bkpf INTO (ls_bkpf_key-bukrs, ls_bkpf_key-belnr, ls_bkpf_key-gjahr,
                    l_stblg)
    WHERE bukrs = gs_header-bukrs
      AND bstat = space             " Documento normal
      AND xblnr = gs_header-xblnr
      AND stblg = space.                                    "#EC *
  IF sy-subrc NE 0.
    " Verifico si existe el documento
    SELECT SINGLE mandt
      FROM bkpf INTO ls_bkpf_key-mandt
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

* Verifico si es un documento de compensación
  SELECT SINGLE mandt
    FROM bsad INTO ls_bkpf_key-mandt
    WHERE bukrs = ls_bkpf_key-bukrs
      AND belnr = ls_bkpf_key-belnr
      AND gjahr = ls_bkpf_key-gjahr
      AND augbl = ls_bkpf_key-belnr.                        "#EC *
  IF sy-subrc = 0.
    " Es un documento de compensación
    " Inicializo funciones POSTING
    IF g_open = abap_false.
      posting_interface_start( ).
    ENDIF.

    " Anulo la compensación
    IF g_open = abap_true.
      CLEAR: l_subrc, ls_fimsg.
      CALL FUNCTION 'ZPOSTING_INTERFACE_RESET_CLEAR'
        EXPORTING
          i_augbl   = ls_bkpf_key-belnr
          i_bukrs   = ls_bkpf_key-bukrs
          i_gjahr   = ls_bkpf_key-gjahr
          i_tcode   = e_tcode_reset_clear
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
        " Anulo el documento
        fb08_posting_reverse( ).
      ENDIF.
    ENDIF.
  ELSE.
    " No es un documento de compensación: Anulo el documento
    fb08_posting_reverse( ).
  ENDIF.

ENDMETHOD.
