FUNCTION z_fi_payment_block_update.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(BUKRS) LIKE  BKPF-BUKRS
*"     VALUE(BELNR) LIKE  BKPF-BELNR
*"     VALUE(GJAHR) LIKE  BKPF-GJAHR
*"     VALUE(ZLSPR) LIKE  BSEG-ZLSPR OPTIONAL
*"     VALUE(BLART) LIKE  BKPF-BLART OPTIONAL
*"     VALUE(ZUONR) LIKE  BSEG-ZUONR OPTIONAL
*"     VALUE(TCODE) LIKE  BKPF-TCODE
*"----------------------------------------------------------------------
*-----------------------------------------------------------------------
* Date     | Mod #      | Person        | Description
*-----------------------------------------------------------------------
*"06/18/2009|MD1K979206| MGGOMEZ       |Added FBD1, and FBD2 to WF
*"----------------------------------------------------------------------
*12/17/2009|MD1K983481 |erassampally  | added tcode FBA7 to WF
*                      |srinivasulu   |
*"------------------------------------------------------------------------
* DATA : c_fba6 type sy-tcode.                         "MD1K983481

* get parameter id 'ZID' field  c_fba6.
  CONSTANTS: c_blk_appr TYPE bseg-zlspr VALUE 'W'.

* Check whether document is locked or not
  PERFORM sub_check_if_locked USING bukrs
                                    belnr
                                    gjahr.

  CLEAR    t_bdcdata.
  REFRESH  t_bdcdata.

  PERFORM sub_bdc_dynpro      USING 'SAPMF05L' '0100'.
  PERFORM sub_bdc_field       USING 'BDC_CURSOR'
                                    'RF05L-BELNR'.
  PERFORM sub_bdc_field       USING 'BDC_OKCODE'
                                    '/00'.

  PERFORM sub_bdc_field       USING 'RF05L-BELNR'
                                    belnr.
  PERFORM sub_bdc_field       USING 'RF05L-BUKRS'
                                    bukrs.
  PERFORM sub_bdc_field       USING 'RF05L-GJAHR'
                                    gjahr.

* Begin of MA 7/22 - MD1K942359
  DATA: BEGIN OF t_doc_lines OCCURS 0,
          buzei LIKE bseg-buzei,
        END OF t_doc_lines.

  DATA: l_doc_line(40) TYPE c,
        l_tabix(3)     TYPE n.

  SELECT buzei
         FROM  bseg
         INTO TABLE t_doc_lines
         WHERE belnr = belnr
         AND   bukrs = bukrs
         AND   gjahr = gjahr
         AND   koart = 'K'
         AND   zlspr = c_blk_appr.   " W Required for Gj05 others to find correct line.
* End of MA 7/22

  LOOP AT t_doc_lines.
    l_tabix = t_doc_lines-buzei.
    CONCATENATE 'RF05L-ANZDT(' l_tabix ')' INTO l_doc_line.
    PERFORM sub_bdc_dynpro      USING 'SAPMF05L' '0700'.
    PERFORM sub_bdc_field       USING 'BDC_CURSOR'
                                       l_doc_line.
    PERFORM sub_bdc_field       USING 'BDC_OKCODE'
                                      '=PK'.

    IF blart = 'KA'.
      PERFORM sub_bdc_dynpro      USING 'SAPMF05L' '0304'.
     ELSEIF blart = 'KX' AND tcode = 'FBA6'.                    "MD1K983481
      PERFORM sub_bdc_dynpro      USING 'SAPMF05L' '0304'.      "MD1K983481
      ELSE.
      PERFORM sub_bdc_dynpro      USING 'SAPMF05L' '0302'.
    ENDIF.

    PERFORM sub_bdc_field       USING 'BDC_CURSOR'
                                      'BSEG-ZLSPR'.
*    PERFORM sub_bdc_field      USING 'BDC_OKCODE'  "MD1K942359
*                                     '=AE'.        "MD1K942359

    PERFORM sub_bdc_field       USING 'BSEG-ZLSPR'
                                       zlspr.

    PERFORM sub_bdc_field       USING 'BSEG-ZUONR'
                                       zuonr.

    PERFORM sub_bdc_field       USING 'BDC_OKCODE'          "MD1K942359
                                      '=RW'.                "MD1K942359
  ENDLOOP.

  PERFORM sub_bdc_field         USING 'BDC_OKCODE'          "MD1K942359
                                      '=AE'.                "MD1K942359

  IF blart = 'KS' OR blart = 'KT'.
    CALL TRANSACTION 'FBD2' USING t_bdcdata MODE 'N' UPDATE 'S'.
  ELSE.
    CALL TRANSACTION 'FB02' USING t_bdcdata MODE 'N' UPDATE 'S'.
  ENDIF.
ENDFUNCTION.

*&---------------------------------------------------------------------*
*&      Form  SUB_BDC_DYNPRO
*&---------------------------------------------------------------------*
*       Start new screen
*----------------------------------------------------------------------*
*      -->  L_PROGRAM Program Name
*      -->  L_DYNPRO  Screen Name
*----------------------------------------------------------------------*
FORM sub_bdc_dynpro USING    l_program
                             l_dynpro.
  CLEAR t_bdcdata.
  t_bdcdata-program  = l_program.
  t_bdcdata-dynpro   = l_dynpro.
  t_bdcdata-dynbegin = 'X'.
  APPEND t_bdcdata.

ENDFORM.                    " SUB_BDC_DYNPRO

*&---------------------------------------------------------------------*
*&      Form  SUB_BDC_FIELD
*&---------------------------------------------------------------------*
*       Insert Field
*----------------------------------------------------------------------*
*      -->  L_FNAM   Field Name
*      -->  L_FVAL   Field Value
*----------------------------------------------------------------------*
FORM sub_bdc_field USING    l_fnam
                            l_fval.

  CLEAR t_bdcdata.
  t_bdcdata-fnam = l_fnam.
  t_bdcdata-fval = l_fval.
  APPEND t_bdcdata.

ENDFORM.                    " SUB_BDC_FIELD

*&---------------------------------------------------------------------*
*&      Form  sub_check_if_locked
*&---------------------------------------------------------------------*
*       Check if document is already locked by another user
*----------------------------------------------------------------------*
FORM sub_check_if_locked USING bukrs
                               belnr
                               gjahr.

  DATA: l_index TYPE i VALUE 1.

  WHILE l_index LE 720.

    CALL FUNCTION 'ENQUEUE_EFBKPF'
      EXPORTING
        mode_bkpf      = 'E'
        mandt          = sy-mandt
        bukrs          = bukrs
        belnr          = belnr
        gjahr          = gjahr
      EXCEPTIONS
        foreign_lock   = 1
        system_failure = 2
        OTHERS         = 3.

    IF sy-subrc <> 0.

      WAIT UP TO 60 SECONDS.
      l_index = l_index + 1.

    ELSE.
      CALL FUNCTION 'DEQUEUE_EFBKPF'
        EXPORTING
          mode_bkpf = 'E'
          mandt     = sy-mandt
          bukrs     = bukrs
          belnr     = belnr
          gjahr     = gjahr.

      EXIT.
    ENDIF.

  ENDWHILE.

ENDFORM.                    " sub_check_if_locked
