FUNCTION ZBAPI_ROUTING_CREATE2.
*"--------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(TESTRUN) TYPE  BAPIFLAG DEFAULT SPACE
*"     VALUE(PROFILE) LIKE  BAPI1012_CONTROL_DATA-PROFILE OPTIONAL
*"     VALUE(BOMUSAGE) LIKE  BAPI1012_CONTROL_DATA-BOM_USAGE OPTIONAL
*"     VALUE(APPLICATION) LIKE  BAPI1012_CONTROL_DATA-APPLICATION
*"         OPTIONAL
*"  EXPORTING
*"     VALUE(GROUP) TYPE  BAPI1012_TSK_C-TASK_LIST_GROUP
*"     VALUE(GROUPCOUNTER) TYPE  BAPI1012_TSK_C-GROUP_COUNTER
*"  TABLES
*"      TASK STRUCTURE  BAPI1012_TSK_C
*"      MATERIALTASKALLOCATION STRUCTURE  BAPI1012_MTK_C OPTIONAL
*"      SEQUENCE STRUCTURE  BAPI1012_SEQ_C OPTIONAL
*"      OPERATION STRUCTURE  BAPI1012_OPR_C OPTIONAL
*"      SUBOPERATION STRUCTURE  BAPI1012_SUB_OPR_C OPTIONAL
*"      REFERENCEOPERATION STRUCTURE  BAPI1012_REF_OPR_C OPTIONAL
*"      WORKCENTERREFERENCE STRUCTURE  BAPI1012_WC_REF_OPR_C OPTIONAL
*"      COMPONENTALLOCATION STRUCTURE  BAPI1012_COM_C OPTIONAL
*"      PRODUCTIONRESOURCE STRUCTURE  BAPI1012_PRT_C OPTIONAL
*"      INSPCHARACTERISTIC STRUCTURE  BAPI1012_CHA_C OPTIONAL
*"      TEXTALLOCATION STRUCTURE  BAPI1012_TXT_HDR_C OPTIONAL
*"      TEXT STRUCTURE  BAPI1012_TXT_C OPTIONAL
*"      RETURN STRUCTURE  BAPIRET2 OPTIONAL
*"      TASK_SEGMENT STRUCTURE  BAPI1012_TSK_SEGMENT OPTIONAL
*"      ZSEG STRUCTURE  ZSTR
*"--------------------------------------------------------------------
*ENHANCEMENT-POINT bapi_routing_create_g8 SPOTS es_saplcpcc_bus1012 STATIC.

*ENHANCEMENT-POINT bapi_routing_create_g6 SPOTS es_saplcpcc_bus1012.

***********************************************************************
* Name     : LCPCC_BUS1012U01                                         *
* Issue    : 11/30/99 - Claus, K. - SAP AG                            *
*                                                                     *
* Purpose  : create a routing and required subobjects                 *
*                                                                     *
*                                                                     *
* Changes  :                                                          *
* [ Date ] - [ Name    ] - [ Action                    ]              *
*   /  /   -             -                                            *
***********************************************************************
**
**  DATA:
**    transaction_header            TYPE transfer_header_interface,
**    tsk_data_interface_tab        TYPE cpcdt_tsk_interf_tab_type,
**    mtk_data_interface_tab        TYPE cpcdt_mtk_interf_tab_type,
**    seq_data_interface_tab        TYPE cpcdt_seq_interf_tab_type,
**    opr_data_interface_tab        TYPE cpcdt_opr_interf_tab_type,
**    sub_opr_data_interface_tab    TYPE cpcdt_sub_opr_interf_tab_type,
**    opr_ref_data_interface_tab    TYPE cpcdt_opr_ref_interf_tab_type,
**    opr_wc_ref_data_interface_tab TYPE cpcdt_opr_wc_ref_interf_tab_tp,
**    prt_data_interface_tab        TYPE cpcdt_prt_interf_tab_type,
**    com_data_interface_tab        TYPE cpcdt_com_interf_tab_type,
**    cha_data_interface_tab        TYPE cpcdt_cha_interf_tab_type,
**    txt_hdr_data_interface_tab    TYPE cpcdt_txt_hdr_interf_tab_type,
**    txt_data_interface_tab        TYPE cpcdt_txt_interf_tab_type.
**
**  DATA:
**    return_tmp      TYPE STANDARD TABLE OF bapiret2,
**    return_tmp_conv TYPE STANDARD TABLE OF bapiret2,
**    wa_return_tmp   TYPE                   bapiret2,
**    tsk_ident       TYPE                   cpcl_tsk_tab_type,
**    wa_tsk_ident    TYPE LINE OF           cpcl_tsk_tab_type,
**    abortion_error  TYPE                   c,
**    object_key(13)  TYPE                   c.
**
**  FIELD-SYMBOLS: <return_tmp> TYPE bapiret2.
**
**
*** FLE MATNR BAPI Changes
**  DATA: ls_fnames              TYPE cl_matnr_chk_mapper=>ts_matnr_bapi_fnames,
**        lt_fnames              TYPE cl_matnr_chk_mapper=>tt_matnr_bapi_fname,
**        lt_fnames_prt          TYPE cl_matnr_chk_mapper=>tt_matnr_bapi_fname,
**        lt_data_line_relevance TYPE cl_matnr_chk_mapper=>tt_data_line_relevance,
**        ls_data_line_relevance LIKE LINE OF lt_data_line_relevance.
**
**  FIELD-SYMBOLS: <lfs_productionresource> TYPE bapi1012_prt_c.
**
**  ls_fnames-int  = 'PRT_NUMBER'.
**  ls_fnames-long = 'PRT_NUMBER_LONG'.
**  INSERT ls_fnames INTO TABLE lt_fnames_prt.
**
**  LOOP AT productionresource ASSIGNING <lfs_productionresource>.
**    IF <lfs_productionresource>-prt_category = 'M'.                 " PRT is a material
**      ls_data_line_relevance-line_to_be_converted = abap_true.      " line is relevant for converting
**    ELSE.
**      IF <lfs_productionresource>-prt_number IS INITIAL AND
**         <lfs_productionresource>-prt_number_long IS NOT INITIAL.
**        <lfs_productionresource>-prt_number = <lfs_productionresource>-prt_number_long.
**      ELSEIF <lfs_productionresource>-prt_number IS NOT INITIAL AND
**             <lfs_productionresource>-prt_number_long IS INITIAL.
**        <lfs_productionresource>-prt_number_long = <lfs_productionresource>-prt_number.
**      ENDIF.
**      ls_data_line_relevance-line_to_be_converted = abap_false.     " line is NOT relevant for converting
**    ENDIF.
**    APPEND ls_data_line_relevance TO lt_data_line_relevance.
**  ENDLOOP.
**
**  CALL METHOD cl_matnr_chk_mapper=>bapi_tables_conv_tab
**    EXPORTING
**      iv_int_to_external     = ' '
**      it_fnames              = lt_fnames_prt
**      it_data_line_relevance = lt_data_line_relevance
**    CHANGING
**      ct_matnr               = productionresource[].
**
**  CLEAR: lt_data_line_relevance.
**
**  ls_fnames-int  = 'MATERIAL'.
**  ls_fnames-ext  = 'MATERIAL_EXTERNAL'.
**  ls_fnames-vers = 'MATERIAL_VERSION'.
**  ls_fnames-guid = 'MATERIAL_GUID'.
**  ls_fnames-long = 'MATERIAL_LONG'.
**  INSERT ls_fnames INTO TABLE lt_fnames.
**
**  CALL METHOD cl_matnr_chk_mapper=>bapi_tables_conv_tab
**    EXPORTING
**      iv_int_to_external = ' '
***SDIMP change start I069729
**      it_fnames          = lt_fnames
**    CHANGING
**      ct_matnr           = componentallocation[].
**
**  CALL METHOD cl_matnr_chk_mapper=>bapi_tables_conv_tab
**    EXPORTING
**      iv_int_to_external = ' '
**      it_fnames          = lt_fnames
**    CHANGING
**      ct_matnr           = materialtaskallocation[].
**
**  CALL METHOD cl_matnr_chk_mapper=>bapi_tables_conv_tab
**    EXPORTING
**      iv_int_to_external = ' '
**      it_fnames          = lt_fnames
**    CHANGING
**      ct_matnr           = productionresource[].
***SDIMP change end I069729
**
**
**  REFRESH return.
**
**  CLEAR:   group,
**           groupcounter,
**           return.
**
*** check whether there is any data to process
**  IF task[]                   IS INITIAL AND
**     materialtaskallocation[] IS INITIAL AND
**     sequence[]               IS INITIAL AND
**     operation[]              IS INITIAL AND
**     suboperation[]           IS INITIAL AND
**     referenceoperation[]     IS INITIAL AND
**     workcenterreference[]    IS INITIAL AND
**     componentallocation[]    IS INITIAL AND
**     productionresource[]     IS INITIAL AND
**     inspcharacteristic[]     IS INITIAL AND
**     textallocation[]         IS INITIAL AND
**     text[]                   IS INITIAL.
***   no data provided
**    MOVE: message_type-error TO wa_return_tmp-type,
**          'BAPI'             TO wa_return_tmp-id,
**          '001'              TO wa_return_tmp-number,
**          'Routing'          TO wa_return_tmp-message_v1.   "#EC NOTEXT
**
***   get system id
**    CALL FUNCTION 'OWN_LOGICAL_SYSTEM_GET'
**      IMPORTING
**        own_logical_system             = wa_return_tmp-system
**      EXCEPTIONS
**        own_logical_system_not_defined = 1.
**
**    APPEND wa_return_tmp TO return.
**
**    CALL FUNCTION 'BALW_BAPIRETURN_GET2'
**      EXPORTING
**        type   = message_type-abort
**        cl     = 'CPCC_DT'
**        number = '007'
**      IMPORTING
**        return = wa_return_tmp.
**
**    APPEND wa_return_tmp TO return.
**
**  ENDIF.                     " if task[] ....
**
*** subscribe refresh module for COMMIT / ROLLBACK WORK
**  CALL FUNCTION 'BUFFER_SUBSCRIBE_FOR_REFRESH'
**    EXPORTING
**      name_of_deletefunc = 'ROUTING_CLEARBUFFER'.
**
*** convert data to internal format
**  PERFORM convert_external_tsk TABLES   task
**                                        return_tmp_conv
**                               CHANGING tsk_data_interface_tab.
***ENHANCEMENT-POINT lcpcc_bus1012u01_01 SPOTS es_saplcpcc_bus1012 .
**
**  PERFORM convert_external_mtk TABLES   materialtaskallocation
**                               CHANGING mtk_data_interface_tab.
**
**  PERFORM convert_external_seq TABLES   sequence
**                                        return_tmp_conv
**                               CHANGING seq_data_interface_tab.
**
**  PERFORM convert_external_opr TABLES   operation
**                                        return_tmp_conv
**                               CHANGING opr_data_interface_tab.
**
**  PERFORM convert_external_sub_opr TABLES
**                                     suboperation
**                                     return_tmp_conv
**                                   CHANGING
**                                     sub_opr_data_interface_tab.
**
**  PERFORM convert_external_ref_opr TABLES
**                                     referenceoperation
**                                   CHANGING
**                                     opr_ref_data_interface_tab.
**
**  PERFORM convert_external_wc_ref_opr TABLES
**                                        workcenterreference
**                                      CHANGING
**                                        opr_wc_ref_data_interface_tab.
**
**  PERFORM convert_external_com TABLES   componentallocation
**                                        return_tmp_conv
**                               CHANGING com_data_interface_tab.
**
**  PERFORM convert_external_prt TABLES   productionresource
**                                        return_tmp_conv
**                               CHANGING prt_data_interface_tab.
**
**  PERFORM convert_external_cha TABLES   inspcharacteristic
**                                        return_tmp_conv
**                               CHANGING cha_data_interface_tab.
**
**  PERFORM convert_external_txt_hdr TABLES
**                                     textallocation
**                                     return_tmp_conv
**                                   CHANGING
**                                     txt_hdr_data_interface_tab.
**
**  PERFORM convert_external_txt TABLES   text
**                               CHANGING txt_data_interface_tab.
**
*** create transcation header
**  PERFORM setup_transaction_header USING    profile
**                                            bomusage
**                                            application
**                                   CHANGING transaction_header.
**
***ENHANCEMENT-POINT bapi_routing_create_01 SPOTS es_saplcpcc_bus1012.
*** Aufruf cp_cc_s_import_data
**  CALL FUNCTION 'CP_CC_S_IMPORT_DATA'
**    EXPORTING
**      i_check_only                 = testrun
**      i_transaction_header_interf  = transaction_header
**      i_tsk_data_interf_tab        = tsk_data_interface_tab
**      i_mtk_data_interf_tab        = mtk_data_interface_tab
**      i_seq_data_interf_tab        = seq_data_interface_tab
**      i_opr_data_interf_tab        = opr_data_interface_tab
**      i_sub_opr_data_interf_tab    = sub_opr_data_interface_tab
**      i_opr_ref_data_interf_tab    = opr_ref_data_interface_tab
**      i_opr_wc_ref_data_interf_tab = opr_wc_ref_data_interface_tab
**      i_prt_data_interf_tab        = prt_data_interface_tab
**      i_com_data_interf_tab        = com_data_interface_tab
**      i_cha_data_interf_tab        = cha_data_interface_tab
***     I_CHV_DATA_INTERF_TAB        =
**      i_txt_hdr_data_interf_tab    = txt_hdr_data_interface_tab
**      i_txt_data_interf_tab        = txt_data_interface_tab
**    IMPORTING
**      e_plnnr                      = group
**      e_plnal                      = groupcounter
**    TABLES
**      return                       = return_tmp.
**
**  APPEND LINES OF return_tmp_conv TO return_tmp.
**
*** check errors if there is an 'abort' - message
**  LOOP AT return_tmp ASSIGNING <return_tmp>.
**    IF <return_tmp>-type = message_type-abort OR
**       <return_tmp>-type = message_type-error.
***     import will be stopped
**      abortion_error = const-flg_yes.
**      EXIT.
**    ENDIF.                   " if <return_tmp>....
**
**  ENDLOOP.                   " loop at return_tmp ....
**
**  IF NOT abortion_error = const-flg_yes.
***   no abortion errors found -> save data
**    IF testrun IS INITIAL.
***     in test mode data will not be saved
**      CALL FUNCTION 'CP_CC_S_SAVE'.
**
***     add information message used with DX-Workbench
**      CONCATENATE cp_const-plnty_nor group groupcounter
**                  INTO object_key
**                  SEPARATED BY '/'.
**
**      MOVE: message_type-success TO wa_return_tmp-type,
**            'BAPI'               TO wa_return_tmp-id,
**            '000'                TO wa_return_tmp-number,
**            'Routing'            TO wa_return_tmp-message_v1,
**            object_key           TO wa_return_tmp-message_v2.
**
***     get system id
**      CALL FUNCTION 'OWN_LOGICAL_SYSTEM_GET'
**        IMPORTING
**          own_logical_system             = wa_return_tmp-system
**        EXCEPTIONS
**          own_logical_system_not_defined = 1.
**
**      APPEND wa_return_tmp TO return.
**    ELSE.                                                   "n_1377598
**      CALL FUNCTION 'CC_DATA_INIT'. "n_1377598
**    ENDIF.                   " if testrun is initial....
**
**  ELSE.
***   data is inconsistent -> do not save any data!!
**    MOVE: message_type-error TO wa_return_tmp-type,
**          'BAPI'             TO wa_return_tmp-id,
**          '001'              TO wa_return_tmp-number,
**          'Routing'          TO wa_return_tmp-message_v1.
**
***   get system id
**    CALL FUNCTION 'OWN_LOGICAL_SYSTEM_GET'
**      IMPORTING
**        own_logical_system             = wa_return_tmp-system
**      EXCEPTIONS
**        own_logical_system_not_defined = 1.
**
**    APPEND wa_return_tmp TO return.
**
**    IF NOT group IS INITIAL.
***     task was already created -> remove objects from memory!
**      wa_tsk_ident-mandt = sy-mandt.
**      wa_tsk_ident-plnty = cp_const-plnty_nor.
**      wa_tsk_ident-plnnr = group.
**      wa_tsk_ident-plnal = groupcounter.
**
**      APPEND wa_tsk_ident TO tsk_ident.
**
**      CALL FUNCTION 'CP_CC_S_UNLOAD_BY_TSK'
**        EXPORTING
**          i_tsk_ident = tsk_ident.
**
**    ENDIF.                   " if not group ....
**
**  ENDIF.                     " if not abortion_error....
**
*** return messages collected during import
**  APPEND LINES OF return_tmp TO return.
**
*** FLE MATNR BAPI Changes
**  LOOP AT productionresource ASSIGNING <lfs_productionresource>.
**    IF <lfs_productionresource>-prt_category = 'M'.                 " PRT is a material
**      ls_data_line_relevance-line_to_be_converted = abap_true.      " line is relevant for converting
**    ELSE.
**      IF <lfs_productionresource>-prt_number IS INITIAL AND
**         <lfs_productionresource>-prt_number_long IS NOT INITIAL.
**        <lfs_productionresource>-prt_number = <lfs_productionresource>-prt_number_long.
**      ELSEIF <lfs_productionresource>-prt_number IS NOT INITIAL AND
**             <lfs_productionresource>-prt_number_long IS INITIAL.
**        <lfs_productionresource>-prt_number_long = <lfs_productionresource>-prt_number.
**      ENDIF.
**      ls_data_line_relevance-line_to_be_converted = abap_false.     " line is NOT relevant for converting
**    ENDIF.
**    APPEND ls_data_line_relevance TO lt_data_line_relevance.
**  ENDLOOP.
**
**  CALL METHOD cl_matnr_chk_mapper=>bapi_tables_conv_tab
**    EXPORTING
**      iv_int_to_external     = 'X'
**      it_fnames              = lt_fnames_prt
**      it_data_line_relevance = lt_data_line_relevance
**    CHANGING
**      ct_matnr               = productionresource[].
**
**  CALL METHOD cl_matnr_chk_mapper=>bapi_tables_conv_tab
**    EXPORTING
**      iv_int_to_external = 'X'
***SDIMP change start I069729
**      it_fnames          = lt_fnames
**    CHANGING
***     CT_FNAMES          = LT_FNAMES
**      ct_matnr           = componentallocation[].
**
**  CALL METHOD cl_matnr_chk_mapper=>bapi_tables_conv_tab
**    EXPORTING
**      iv_int_to_external = 'X'
**      it_fnames          = lt_fnames
**    CHANGING
***     CT_FNAMES          = LT_FNAMES
**      ct_matnr           = materialtaskallocation[].
**
**  CALL METHOD cl_matnr_chk_mapper=>bapi_tables_conv_tab
**    EXPORTING
**      iv_int_to_external = 'X'
**      it_fnames          = lt_fnames
**    CHANGING
***     CT_FNAMES          = LT_FNAMES
**      ct_matnr           = productionresource[].
***SDIMP change end I069729
***ENHANCEMENT-POINT bapi_routing_create_g7 SPOTS es_saplcpcc_bus1012.
ENDFUNCTION.
