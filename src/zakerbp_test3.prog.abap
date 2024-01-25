    Report ZAKERBP_TEST3.
      SELECT kostl            "Cost Center
         bukrs            "Company code
    FROM csks
    INTO TABLE i_csks
  FOR ALL ENTRIES IN i_fb01l
   WHERE kokrs EQ c_aes0
    AND  kostl EQ i_fb01l-kostl.

  IF sy-subrc EQ 0.
    SORT i_csks.
    endif.
    READ TABLE i_csks INTO wa_csks WITH KEY kostl = wa_fb01l-kostl
                                            bukrs = wa_fb01l-bukrs
                                                     BINARY SEARCH.
