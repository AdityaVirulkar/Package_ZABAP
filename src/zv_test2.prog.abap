METHOD zcp_fi_ii_corp_citi_payment_ac~corp_citi_payment_accept_rejec.
*** **** INSERT IMPLEMENTATION HERE **** ***

  DATA: t_payments TYPE zcp_fi_citi_payment_accept_tab,
        x_payments TYPE zcp_fi_citi_payment_accept_rej,
        x_payment  TYPE ztca_payments_st,
        wl_doc_year TYPE gjahr.

  DATA:   xl_payments_st TYPE ztca_payments_st,
* Begin of Modification - BULIANE00C - 05.03.2009
          l_tabix     TYPE sy-tabix,
          l_length    TYPE i,
          l_alias     TYPE salertdalias,
          wl_status   TYPE c.
* End of Modification   - BULIANE00C - 05.03.2009

*Data declaration for Sending alert PARHADB00C
  DATA:
        gt_receivers TYPE TABLE OF somlreci1 ,
        gst_receivers TYPE somlreci1,
        gt_distlist  TYPE TABLE OF sodlienti1,
        gst_distlist  TYPE sodlienti1,
        i_partable TYPE TABLE OF z00_xx_name_value,
        w_partable TYPE  z00_xx_name_value,
        w_intab TYPE ztca_payments_st.

  DATA:
          l_bukrs TYPE bukrs,
          l_hr(2)  TYPE c,
          l_sc(2)  TYPE c,
          l_mn(2)  TYPE c,

          l_reciv_system TYPE zzreceiv_syst,
          l_sender_system TYPE edi_sndpor,
          l_distlist TYPE soobjinfi1-obj_name,
          l_status   TYPE edi_status,
          l_time(8)     TYPE   c, "sy-uzeit,
          l_date(10)    TYPE  c, "zxifides_out_payment2p_payment-document_date,
          l_tdname  TYPE  rssce-tdname ,   "value,  " 'ZCP_TECH_ERRSUCS',
          l_tdid    TYPE  rssce-tdid VALUE 'ST',
          l_tdspras TYPE  rssce-tdspras VALUE 'E',
          l_obj_descr TYPE  so_obj_des,
          l_reason TYPE string,
          l_tdobject TYPE   rssce-tdobject VALUE 'TEXT',
          l_receiver TYPE soextreci1-receiver,
          l_payid   TYPE ztca_payments_st-edi3002_uid,
          l_idocnm TYPE ztca_payments_st-idoc_number,
          l_usrnam      TYPE ztca_payments_st-usnam.
  DATA:   wl_notupdate TYPE char1.
*End Data declaration for Sending alert  PARHADB00C


  t_payments = input-corp_citi_payment_accept_rejec-payments.
  TRY.
      LOOP AT t_payments INTO x_payments.
        CLEAR : l_obj_descr, l_distlist, l_tdname, l_reason.
        CLEAR w_partable.
        REFRESH i_partable.
        x_payment-doc_num = x_payments-doc_num.
*    x_payment-comp_code = x_payments-comp_code.
        IF  x_payments-comp_code IS NOT INITIAL.

          x_payment-comp_code = x_payments-comp_code.
          l_bukrs = x_payments-comp_code.

        ELSE.
          x_payment-comp_code = 'USAC'.
          l_bukrs = 'USAC'.
        ENDIF.
        x_payment-pay_date = x_payments-date.
        x_payment-status = x_payments-status(1).
        x_payment-doc_year = x_payment-pay_date(4).
        x_payment-company_name = x_payments-company_name.
        x_payment-description = x_payments-description.
        x_payment-file_name_ack = x_payments-file_name.
        x_payment-file_time_ack = x_payments-file_time.

        IF ( x_payments-status(1) EQ 'A' ).

* x_payment-status = 'A' Means that the payment was accepted.

          x_payment-status = 'A'.
          x_payment-description = x_payments-description.
          l_obj_descr = text-t01.
          l_distlist = 'ZCP_PAYMACRJ'.
          l_tdname  =  'ZCP_PYM_TECO'.
          l_reason  = x_payments-description.
        ELSE.
* x_payment-status = 'R' Means that the payment was rejected.


          x_payment-status = 'R'.
          x_payment-description = x_payments-description.
          l_obj_descr = text-t02.
          l_distlist = 'ZCP_PAYMACRJ'.
          l_tdname  =  'ZCP_PYM_TECO'.
          l_reason  =  x_payments-description.
* x_payment-status1 contains the reason for why a given payment is rejected.

        ENDIF.

        x_payment-receiver_system = 'CITIBANK'.

        wl_status = x_payments-status(1).
        wl_doc_year = x_payment-pay_date(4).


        UPDATE
            ztca_payments_st
        SET
            status = x_payment-status
            file_name_ack = x_payment-file_name_ack
            file_time_ack  = x_payment-file_time_ack
            description = x_payment-description
            pay_date = x_payment-pay_date
            receiver_system = x_payment-receiver_system
        WHERE doc_num = x_payments-doc_num
          AND comp_code = l_bukrs
          AND doc_year = wl_doc_year.
        IF ( sy-subrc NE 0 ).

          INSERT ztca_payments_st FROM x_payment.
*      commit work.

          IF sy-subrc NE '0'.
            l_obj_descr = text-t03.
            wl_notupdate = 'T'.
            l_distlist = 'ZCP_PAYERSU'.
            l_tdname  =  'ZCP_TECH_ERROR'.
            l_reason  =  text-t03.
          ENDIF.
        ENDIF.

        SELECT SINGLE *
                    INTO w_intab
                    FROM ztca_payments_st
                    WHERE doc_num = x_payments-doc_num
                      AND comp_code = l_bukrs
                      AND doc_year = wl_doc_year.

        l_receiver = sy-uname.

*    Read the Distribution List

        CALL FUNCTION 'SO_DLI_READ_API1'
          EXPORTING
            dli_name                   = l_distlist
            shared_dli                 = 'X'                " GV00++
          TABLES
            dli_entries                = gt_distlist
          EXCEPTIONS
            dli_not_exist              = 1
            operation_no_authorization = 2
            parameter_error            = 3
            x_error                    = 4
            OTHERS                     = 5.
        IF sy-subrc <> 0.
          MESSAGE ID sy-msgid
                TYPE sy-msgty
              NUMBER sy-msgno
                WITH sy-msgv1
                     sy-msgv2
                     sy-msgv3
                     sy-msgv4.
        ENDIF.


        LOOP AT gt_distlist INTO gst_distlist.

          gst_receivers-receiver =  gst_distlist-member_adr.
          gst_receivers-rec_type =  'U'.  "gst_distlist-member_typ.

          APPEND gst_receivers TO gt_receivers.
          CLEAR gst_receivers.

        ENDLOOP.

        w_partable-fname = '&L_DOCUMENT&'.
        w_partable-value = x_payments-doc_num.
        APPEND w_partable TO i_partable.
        CLEAR w_partable.

        w_partable-fname = '&L_BUKRS&'.
        w_partable-value = 'USAC'.
        APPEND w_partable TO i_partable.
        CLEAR w_partable.

        w_partable-fname = '&L_RECIV_SYSTEM&'.
        w_partable-value = 'CITIBANK' . " ''w_intab-receiver_system.

        APPEND w_partable TO i_partable.
        CLEAR w_partable.

        w_partable-fname = '&L_SYSTEM&'.
        w_partable-value = sy-sysid.
        APPEND w_partable TO i_partable.
        CLEAR w_partable.

        w_partable-fname = '&L_SENDER_SYSTEM&'.
        w_partable-value = l_sender_system.
        APPEND w_partable TO i_partable.
        CLEAR w_partable.

        w_partable-fname = '&L_IDOCNM&'.
        IF w_intab-idoc_number IS NOT INITIAL.
          w_partable-value = w_intab-idoc_number.
        ELSE.
          w_partable-value = 'No information Avaliable'.
        ENDIF.
        APPEND w_partable TO i_partable.
        CLEAR w_partable.


        w_partable-fname = '&L_REASON&'.
        w_partable-value =  l_reason.
        APPEND w_partable TO i_partable.
        CLEAR w_partable.

        w_partable-fname = '&L_PAYID&'.

        IF w_intab-edi3002_uid IS INITIAL.
          w_partable-value = 'No information Avaliable'.
        ELSE.
          w_partable-value =  w_intab-edi3002_uid.
        ENDIF.

        APPEND w_partable TO i_partable.
        CLEAR w_partable.

        w_partable-fname = '&L_USRNAM&'.
        IF w_intab-usnam IS INITIAL.
          w_partable-value = 'No information Avaliable'.
        ELSE.
          w_partable-value = w_intab-usnam.
        ENDIF.

        APPEND w_partable TO i_partable.
        CLEAR w_partable.

        w_partable-fname = '&L_DATE&'.

        WRITE sy-datum TO l_date DD/MM/YYYY.

        w_partable-value = l_date.
        APPEND w_partable TO i_partable.
        CLEAR w_partable.

        w_partable-fname = '&L_CLIENT&'.
        w_partable-value = sy-mandt.

        APPEND w_partable TO i_partable.
        CLEAR w_partable.

        w_partable-fname = '&L_TIME&'.

        l_hr = sy-uzeit(2).
        l_mn = sy-uzeit+2(2).
        l_sc = sy-uzeit+4(2).

        CONCATENATE l_hr ':' l_mn  ':' l_sc INTO l_time.
        w_partable-value = l_time.

        APPEND w_partable TO i_partable.
        CLEAR w_partable.

        CALL FUNCTION 'Y00_SEND_EMAIL_VIA_TEMPLAT'
        EXPORTING
          tdname                 = l_tdname   "'ZCP_IDOC_RELEASE'
          tdid                   = l_tdid     "'ST'
          tdspras                = l_tdspras  "'E'
          obj_descr              = l_obj_descr "'IDOC Release Notification'
*   OBJ_PRIO               =
*   PRIORITY               =
         tdobject               = l_tdobject  "'TEXT'
         sender_address         = l_receiver
        TABLES
          receivers              = gt_receivers
*   ITEMS_TABLE            =
          param_table            = i_partable
*   SHORT_TABLE            =
       EXCEPTIONS
         invalid_template       = 1
         send_error             = 2
         OTHERS                 = 3
                .
        IF sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
        ENDIF.

**BOC@ chandrats00c WO 2521500 Payment  Monitor

        CLEAR : l_obj_descr, l_distlist, l_tdname, l_reason.
        CLEAR w_partable.
        REFRESH: i_partable, gt_receivers.

* x_payment-status = 'R' Means that the payment was rejected.


        IF   x_payment-status = 'R' and x_payment-comp_code = 'USAC'.

          x_payment-description = x_payments-description.
          l_obj_descr = text-t02.
          l_distlist = 'ZCP_FIDES_R'.
          l_tdname  =  'ZCP_PYM_ACK'.
          l_reason  =  x_payments-description.

          l_receiver = sy-uname.

*    Read the Distribution List

          CALL FUNCTION 'SO_DLI_READ_API1'
            EXPORTING
              dli_name                   = l_distlist
              shared_dli                 = 'X'              " GV00++
            TABLES
              dli_entries                = gt_distlist
            EXCEPTIONS
              dli_not_exist              = 1
              operation_no_authorization = 2
              parameter_error            = 3
              x_error                    = 4
              OTHERS                     = 5.
          IF sy-subrc <> 0.
            MESSAGE ID sy-msgid
                  TYPE sy-msgty
                NUMBER sy-msgno
                  WITH sy-msgv1
                       sy-msgv2
                       sy-msgv3
                       sy-msgv4.
          ENDIF.


          LOOP AT gt_distlist INTO gst_distlist.

            gst_receivers-receiver =  gst_distlist-member_adr.
            gst_receivers-rec_type =  'U'.  "gst_distlist-member_typ.

            APPEND gst_receivers TO gt_receivers.
            CLEAR gst_receivers.

          ENDLOOP.

          w_partable-fname = '&L_DOCUMENT&'.
          w_partable-value = x_payments-doc_num.
          APPEND w_partable TO i_partable.
          CLEAR w_partable.

          w_partable-fname = '&L_BUKRS&'.
          w_partable-value = 'USAC'.
          APPEND w_partable TO i_partable.
          CLEAR w_partable.

          w_partable-fname = '&L_RECIV_SYSTEM&'.
          w_partable-value = 'CITIBANK' . " ''w_intab-receiver_system.

          APPEND w_partable TO i_partable.
          CLEAR w_partable.

          w_partable-fname = '&L_SYSTEM&'.
          w_partable-value = sy-sysid.
          APPEND w_partable TO i_partable.
          CLEAR w_partable.

          w_partable-fname = '&L_SENDER_SYSTEM&'.
          w_partable-value = l_sender_system.
          APPEND w_partable TO i_partable.
          CLEAR w_partable.

          w_partable-fname = '&L_IDOCNM&'.
          IF w_intab-idoc_number IS NOT INITIAL.
            w_partable-value = w_intab-idoc_number.
          ELSE.
            w_partable-value = 'No information Avaliable'.
          ENDIF.
          APPEND w_partable TO i_partable.
          CLEAR w_partable.


          w_partable-fname = '&L_REASON&'.
          w_partable-value =  l_reason.
          APPEND w_partable TO i_partable.
          CLEAR w_partable.

          w_partable-fname = '&L_PAYID&'.

          IF w_intab-edi3002_uid IS INITIAL.
            w_partable-value = 'No information Avaliable'.
          ELSE.
            w_partable-value =  w_intab-edi3002_uid.
          ENDIF.

          APPEND w_partable TO i_partable.
          CLEAR w_partable.

          w_partable-fname = '&L_USRNAM&'.
          IF w_intab-usnam IS INITIAL.
            w_partable-value = 'No information Avaliable'.
          ELSE.
            w_partable-value = w_intab-usnam.
          ENDIF.

          APPEND w_partable TO i_partable.
          CLEAR w_partable.

          w_partable-fname = '&L_DATE&'.

          WRITE sy-datum TO l_date DD/MM/YYYY.

          w_partable-value = l_date.
          APPEND w_partable TO i_partable.
          CLEAR w_partable.

          w_partable-fname = '&L_CLIENT&'.
          w_partable-value = sy-mandt.

          APPEND w_partable TO i_partable.
          CLEAR w_partable.

          w_partable-fname = '&L_TIME&'.

          l_hr = sy-uzeit(2).
          l_mn = sy-uzeit+2(2).
          l_sc = sy-uzeit+4(2).

          CONCATENATE l_hr ':' l_mn  ':' l_sc INTO l_time.
          w_partable-value = l_time.

          APPEND w_partable TO i_partable.
          CLEAR w_partable.

          CALL FUNCTION 'Y00_SEND_EMAIL_VIA_TEMPLAT_NEW'
          EXPORTING
            tdname                 = l_tdname   "'ZCP_IDOC_RELEASE'
            tdid                   = l_tdid     "'ST'
            tdspras                = l_tdspras  "'E'
            obj_descr              = l_obj_descr "'IDOC Release Notification'
*   OBJ_PRIO               =
*   PRIORITY               =
           tdobject               = l_tdobject  "'TEXT'
           sender_address         = l_receiver
          TABLES
            receivers              = gt_receivers
*   ITEMS_TABLE            =
            param_table            = i_partable
*   SHORT_TABLE            =
         EXCEPTIONS
           invalid_template       = 1
           send_error             = 2
           OTHERS                 = 3
                  .
          IF sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
          ENDIF.
        ENDIF.

        CLEAR : l_obj_descr, l_distlist, l_tdname, l_reason.
        CLEAR w_partable.
        REFRESH i_partable.

**EOC@ chandrats00c WO 2521500 Payment  Monitor
      ENDLOOP.


      IF wl_notupdate = 'T'.

        exchange_fault_data-fault_text = 'Error during update statement execution'.

        RAISE EXCEPTION TYPE zxicx_fides_out_payment2p_faul
                      EXPORTING standard = exchange_fault_data.

      ENDIF.

    CATCH cx_ai_application_fault.

      RAISE EXCEPTION TYPE zxicx_fides_out_payment2p_faul
                    EXPORTING standard = exchange_fault_data.

  ENDTRY.

ENDMETHOD.
