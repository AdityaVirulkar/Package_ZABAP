*&---------------------------------------------------------------------*
*& Include          ZACCENTURE_TOOLS_TOP
*&---------------------------------------------------------------------*
TABLES: trnspacet, tadir, e071, v_ext_act.
*BOC by deepika for CR 813 on 01/12/2021
TYPE-POOLS: trwbo,slis.
TABLES:  sscrfields.
*EOC by deepika for CR 813 on 01/12/2021

CONSTANTS : gc_method(21) TYPE c VALUE 'DECRYPT_STRING2STRING'.
DATA: lv_code_orig TYPE string.
TYPES :
  BEGIN OF selopt,
    sign(1)   TYPE  c,
    option(2) TYPE  c,
    low(24)   TYPE  c,
    high(24)  TYPE  c,
  END OF  selopt.

TYPES:
  BEGIN OF ty_node,
    node_name(50) TYPE c,
    line_no       TYPE i,
    text(1000)    TYPE c,
  END OF ty_node.

DATA:
*  boc s/4 extensibility
  it_det              TYPE TABLE OF /acnip/zatb_ext,
  it_detect           TYPE TABLE OF /acnip/zatb_ext,
* eoc s/4 extensibility
*  gv_session_id       TYPE numc5,
*BOC by jagriti TASK 576 1/13/2021
  gv_session_id       TYPE n LENGTH 5,
*EOC by jagriti TASK 576 1/13/2021
  gt_transport        TYPE /acnip/zatt_transport, "Added by Gunjan on 9/6/2020 #Defect 269
  gs_transport        TYPE /acnip/zast_transport, "Added by Gunjan on 9/6/2020 #Defect 269
  gt_namespace        TYPE /acnip/zatt_namespace,
  gt_package          TYPE /acnip/zatt_package,
  gs_namespace        TYPE /acnip/zast_namespace,
  gs_package          TYPE /acnip/zast_package,
  it_inv_tab          TYPE TABLE OF /acnip/zast_aadt_inventory,
  it_inv_tab_bw       TYPE TABLE OF /acnip/zast_aadt_inventory,   " Added by Rahul 08/12/2020 Defect#303
  wa_inv              TYPE /acnip/zast_aadt_inventory,
  gr_obj              TYPE RANGE OF e071-obj_name,
  gs_obj              LIKE LINE OF gr_obj,
  gt_inventory        TYPE TABLE OF /acnip/zast_aadt_inventory,
  gs_inventory        TYPE /acnip/zast_aadt_inventory,
  gv_syntax_flag      TYPE flag,
  gt_syntax_check     TYPE TABLE OF /acnip/zatb_dete,
  gt_detection_result TYPE TABLE OF /acnip/zatb_dete,
  gt_det_all_objects  TYPE /acnip/zatt_det_all_object,

  gs_det_slin_objects TYPE /acnip/zast_det_all_object,
  gs_det_all_objects  TYPE /acnip/zast_det_all_object,
  gs_det_all_objects1 TYPE /acnip/zast_det_all_object,
  gv_inclname         TYPE sobj_name,
  gv_lines            TYPE string,
  gt_obj_code         TYPE TABLE OF string,
  gs_obj_code         TYPE string,
  gt_obj_code_forms   TYPE TABLE OF ty_node,
  gs_obj_code_forms   TYPE ty_node,
  gt_code_line        TYPE TABLE OF /acnip/zast_code_line,

  gs_code_line        TYPE /acnip/zast_code_line,

  gs_code             TYPE /acnip/zast_aadt_code,
  gv_code(1000)       TYPE c,
  gt_code_tab         TYPE /acnip/zatt_aadt_code,
  gv_exists           TYPE  c LENGTH 1, "char1,
  gs_grp              TYPE selopt,
  gt_grp              TYPE STANDARD TABLE OF selopt,
  gv_opcode           TYPE c LENGTH 50, "char50,
  gv_opcode1           TYPE c LENGTH 50, "char50,

  gs_include(1000)    TYPE c,
  lv_index            TYPE i,
  ls_final            TYPE /acnip/zatb_dete,
  gv_flag_decr_err(1) TYPE c,

*****boc by shikha on 20/02/2020 for FCV/LCV.
  gv_ktopl            TYPE c LENGTH 4, "char4,
  gv_kokrs            TYPE c LENGTH 4, "char4,
  gv_bukrs            TYPE c LENGTH 4, "char4,
  gv_rldnr            TYPE c LENGTH 2, "char2,
*  gv_gjahr            TYPE numc4,
*BOC by jagriti TASK 576 1/13/2021
  gv_gjahr            TYPE n LENGTH 4,
*EOC by jagriti TASK 576 1/13/2021
  gv_werks            TYPE c LENGTH 4, "char4,
  gv_ekorg            TYPE c LENGTH 4, "char4,
  gv_vkorg            TYPE c LENGTH 4, "char4,
  gv_cvit_ck          TYPE c.
*****eoc by shikha on 20/02/2020 for FCV/LCV.

DATA:o_inv           TYPE REF TO object, "zaadt_inventory,
     o_db            TYPE REF TO object, "zaadt_db_layer,
     o_log           TYPE REF TO object, "zcl_aadt_variable_logger,
     o_upg           TYPE REF TO object, "zaadt_upg_detection,
     o_hana          TYPE REF TO object, "ZCL_AADT_HANA_PRO,
     o_s4            TYPE REF TO object, "zcl_s4_detection,
     o_msg_log       TYPE REF TO object, "zaadt_msg_log.
     o_msg_log_save  TYPE REF TO object, "zaadt_msg_log.
     o_enh_fiori     TYPE REF TO object, "ZCL_ENHANCEMENT_FIORI
     o_fiat          TYPE REF TO object, "ZCL_AADT_FIAT_PRO
     o_odata_records TYPE REF TO object, "zcl_odata_records
     o_corr          TYPE REF TO object, "zcl_aadt_auto_correction.
     o_cds           TYPE REF TO object, "ZCL_AADT_CDS_CREATION
     o_ui5           TYPE REF TO object, "zcl_aadt_ui5_pro.
     o_cloud         TYPE REF TO object, "zcl_aadt_cloud_pro - added by Pooja Kalshetti
     o_bw            TYPE REF TO object, "zcl_bw_extension.
     o_dobj          TYPE REF TO object, " ZCL_AADT_CWRM_DEPENDENT_OBJ
* BOC for S/4 extensions
     o_ext           TYPE REF TO object, "zcl_s4_detection,
     o_extend        TYPE REF TO object, "zcl_s4_detection,
     o_cds_pro       TYPE REF TO object, "zcl_aadt_cds_pro,
     o_event         TYPE REF TO object.

* EOC for S/4 extensions
***BOC By deepika for CR #813 on 06/12/2021
DATA : o_upload    TYPE REF TO object,
       o_download  TYPE REF TO object,
       o_download1 TYPE REF TO object.
***EOC By deepika for CR #813 on 06/12/2021
TYPES: BEGIN OF ty_obj_with_name,
         object   TYPE tadir-object,
         obj_name TYPE tadir-obj_name,
       END OF ty_obj_with_name.
DATA: gt_obj_with_name TYPE STANDARD TABLE OF ty_obj_with_name.
DATA: lw_opercd TYPE /acnip/zast_opcode,
      lv_flag1  TYPE c,
      lv_flag2  TYPE c,
      lv_flag3  TYPE c,
      lv_flag4  TYPE c,
      lv_flag5  TYPE c,
      lv_flag6  TYPE c,
      lv_flag7  TYPE c,
      lv_flag8  TYPE c, "Added by Nancy for green it on 16/05/2022
      lv_ehp4   TYPE flag.
*** BOC BY PARUL PURI CR 190 - ABAP QUERIES " Uncommented by Palani for CR 881 on 14/10/2021
TYPES: BEGIN OF gt_output_query,
         lv_object_type TYPE c LENGTH 4,
         lv_user_grp    TYPE c LENGTH 12,
         lv_package     TYPE c LENGTH 30,
         lv_infoset     TYPE c LENGTH 24,
         lv_query_name  TYPE c LENGTH 14,
         lv_code        TYPE c LENGTH 132,
       END OF gt_output_query .
DATA: lt_output_query TYPE TABLE OF gt_output_query.
DATA: wa_output_query TYPE gt_output_query.
DATA: lv_str TYPE string.
DATA: lv_str2 TYPE string.
DATA: lv_user_group TYPE c LENGTH 12.
DATA: lv_lines TYPE sy-tabix.
DATA: lv_scope_check TYPE flag.
*** EOC BY PARUL PURI CR 190 - ABAP QUERIES
DATA:git_ptab     TYPE abap_parmbind_tab,
     gs_ptab_line TYPE abap_parmbind.
DATA: gv_bw TYPE c."ADDED BY PARUL PURI FOR BW CLEANUP.

DATA:o_msg_log_ref TYPE REF TO data,
     o_go_ref      TYPE REF TO data,
     o_go_ref1     TYPE REF TO object, "/ACNIP/ZCL_AADT_CIPHER,
     o_log_ref     TYPE REF TO data,
     g_go_ref      TYPE REF TO object.

FIELD-SYMBOLS:<gfs_msg_log> TYPE any,
              <gfs_go_ref>  TYPE any,
              <gfs_log>     TYPE any.

DATA:gv_jobcnt     LIKE tbtcjob-jobcount,
     gv_release(1) TYPE c,
     gv_jobname    TYPE tbtcjob-jobname.

DATA:git_sel       TYPE TABLE OF  rsparams,
     it_detections TYPE TABLE OF /acnip/zatb_dete,
     gwa_sel       TYPE rsparams.
DATA gc_cl_var_logger  TYPE c LENGTH 25 VALUE 'ZCL_AADT_VAR_LOG'.

CONSTANTS:gc_cl_inventory             TYPE c LENGTH 30 VALUE 'ZCL_AADT_INVENTORY',
          gc_m_get_inventory          TYPE c LENGTH 30 VALUE 'GET_INVENTORY',
          gc_m_save_inventory         TYPE c LENGTH 30 VALUE 'SAVE_INVENTORY',
          gc_cl_msg_log               TYPE c LENGTH 30 VALUE 'ZCL_AADT_MSG_LOG',
*          gc_cl_test_scope           TYPE c LENGTH 30 VALUE 'ZCL_AADT_TESTING_SCOPE',   " ADDED BY RAVI KUMAR FOR TESTING SCOPE
          gc_cl_db                    TYPE c LENGTH 30 VALUE 'ZCL_AADT_DB_LAYER',
          gc_m_get_sap_mod_code       TYPE c LENGTH 30 VALUE 'GET_SAP_MODIFICATION_CODE',  "Added by Vikas for defect#555
          gc_m_get_det_objects        TYPE c LENGTH 30 VALUE 'GET_DET_OBJECTS',
          gc_initiate                 TYPE c LENGTH 30 VALUE 'INITIATE',
          gc_m_syntax_check           TYPE c LENGTH 30 VALUE 'SYNTAX_CHECK',
          gc_cl_upg                   TYPE c LENGTH 25 VALUE 'ZCL_AADT_UPG_PRO',
          gc_m_slin_check             TYPE c LENGTH 30 VALUE 'SLIN_CHECK',
*          gc_cl_var_logger           TYPE c LENGTH 25 VALUE 'ZCL_AADT_VAR_LOG',
          gc_cl_aadt_fiat_pro         TYPE c LENGTH 30 VALUE 'ZCL_AADT_FIAT_PRO',
          gc_m_get_statment           TYPE c LENGTH 30 VALUE 'GET_STATEMENT',
          gc_m_log_line               TYPE c LENGTH 30 VALUE 'LOG_LINE',
          gc_m_read_form_code         TYPE c LENGTH 25 VALUE 'READ_FORM_CODE',
          gc_m_read_interface_code    TYPE c LENGTH 25 VALUE 'READ_INTERFACE_CODE',
          gc_cl_hana_pro              TYPE c LENGTH 25 VALUE 'ZCL_AADT_HANA_PRO',
          gc_msg_log                  TYPE c LENGTH 25 VALUE 'ZCL_AADT_MSG_LOG',
          gc_m_upgrade_profiler       TYPE c LENGTH 25 VALUE 'UPGRADE_PROFILER',
          gc_m_save_detections        TYPE c LENGTH 25 VALUE 'SAVE_DETECTIONS',
          gc_m_hana_profiler          TYPE c LENGTH 30 VALUE 'HANA_PROFILER',
          gc_get_query                TYPE c LENGTH 30 VALUE 'GET_ABAP_QUERY',

          gc_m_in_loop_methods        TYPE c LENGTH 30 VALUE 'IN_LOOP_METHODS',
          gc_cloud_detection          TYPE c LENGTH 30 VALUE 'CLOUD_DETECTION',  " Added by Pooja kalshetti
*Start ins dhiraj 31/03/2020
          gc_cloud_log_path           TYPE c LENGTH 30 VALUE 'SEARCH_LOGICAL_FILE_PATH',
          gc_cloud_log_cmd            TYPE c LENGTH 30 VALUE 'SEARCH_LOGICAL_COMMAND',
*end ins dhiraj 31/03/2020
          gc_m_log_detections         TYPE c LENGTH 30 VALUE 'LOG_DETECTIONS', "Added by Vikas for Defect#408
          gc_m_out_of_loop_methods    TYPE c LENGTH 25 VALUE 'OUT_OF_LOOP_METHODS',
          gc_cl_corr_pro              TYPE c LENGTH 30 VALUE 'ZCL_AADT_AUTO_CORRECTION',"'ZCL_AADT_AUTO_CORR_NEW_COPY',""
          gc_cl_aadt_hana_correction  TYPE c LENGTH 30 VALUE 'ZCL_AADT_HANA_CORRECTION',
          gc_cl_aadt_s4_correction    TYPE c LENGTH 30 VALUE 'ZCL_AADT_S4_CORRECTIONS',
          gc_cl_aadt_os_correction    TYPE c LENGTH 30 VALUE 'ZCL_AADT_CLOUD_CORRECTION',
          gc_cl_aadt_upg_correction   TYPE c LENGTH 30 VALUE 'ZCL_AADT_UPG_CORRECTION',
          gc_get_data                 TYPE c LENGTH 20 VALUE 'GET_DATA',
          gc_zcl_enhancement_fiori    TYPE c LENGTH 30 VALUE 'ZCL_ENHANCEMENT_FIORI', "
          gc_zcl_std_functionality    TYPE c LENGTH 30 VALUE 'ZCL_STD_FUNCTIONALITY',
          gc_zcl_extension_standard   TYPE c LENGTH 30 VALUE 'ZCL_EXTENSION_STANDARD',
          gc_zcl_custom_services      TYPE c LENGTH 30 VALUE 'ZCL_CUSTOM_SERVICES',
          gc_extract_odata_records    TYPE c LENGTH 30 VALUE 'EXTRACT_ODATA_RECORDS',
          gc_check_odata_tables       TYPE c LENGTH 30 VALUE 'CHECK_ODATA_TABLES',
          gc_zcl_odata_records        TYPE c LENGTH 30 VALUE 'ZCL_ODATA_RECORDS',
          gc_m_update_table_types     TYPE c LENGTH 30 VALUE 'UPDATE_TABLE_TYPES',
*          gc_cds_create type c LENGTH 30 VALUE 'ZCL_AADT_CDS_DETECTION',
          gc_cds_check                TYPE c LENGTH 30 VALUE 'CDS_CHECK',
          gc_collect_params           TYPE c LENGTH 30 VALUE 'COLLECT_PARAMS',
          gc_cl_ui5                   TYPE c LENGTH 30 VALUE 'ZCL_AADT_UI5_PRO',
          gc_ui5_extractor            TYPE c LENGTH 30 VALUE 'UI5_EXTRACTOR',
* boc s/4 extensibility
          gc_cl_extend                TYPE c LENGTH 30 VALUE 'ZCL_AADT_S4_EXTEND',
          gc_get_cmod                 TYPE c LENGTH 30 VALUE 'GET_CMOD_OBJECTS',
          gc_inventory                TYPE c LENGTH 30 VALUE 'INVENTORY',
          gc_pre_metadata             TYPE c LENGTH 30 VALUE 'PREPARE_METADATA',
          gc_m_save_det_ext           TYPE c LENGTH 25 VALUE 'SAVE_DET_EXT',
          gc_m_save_det_ext_cmod      TYPE c LENGTH 25 VALUE 'SAVE_DET_EXT_CMOD',
          gc_m_del_ext_clas           TYPE c LENGTH 25 VALUE 'DELETE_EXT_META',
          gc_m_update_types_ext       TYPE c LENGTH 30 VALUE 'UPDATE_TYPES_EXT',
          gc_m_log_ext                TYPE c LENGTH 30 VALUE 'LOG_LINE_EXT',
          gc_pre_metadata_ricef       TYPE c LENGTH 30 VALUE 'PREPARE_METADATA_RICEF', "after oct for ricefw
          gc_get_cmod_ricef           TYPE c LENGTH 30 VALUE 'GET_CMOD_RICEF', "after oct for ricefw
          gc_m_log_ext_ricef          TYPE c LENGTH 30 VALUE 'LOG_LINE_EXT_RICEF', "after oct for ricefw

*BOC by Vikas for defect#408
*          gc_hana                    TYPE char4 VALUE 'HANA',
*          gc_s4                      TYPE char4 VALUE 'S4',
*          gc_os                      TYPE char4 VALUE 'OS',
*          gc_upg                     TYPE char4 VALUE 'UPG',
*BOC by jagriti TASK 576 1/13/2021
          gc_hana                     TYPE c LENGTH 4 VALUE 'HANA',
          gc_s4                       TYPE c LENGTH 4 VALUE 'S4',
          gc_os                       TYPE c LENGTH 4 VALUE 'OS',
          gc_upg                      TYPE c LENGTH 4 VALUE 'UPG',
*EOC by jagriti TASK 576 1/13/2021
*EOC by Vikas for defect#408
*BOC By Sonal for CDS Profiler Defect #436
          gc_cl_cds_pro               TYPE c LENGTH 30 VALUE 'ZCL_AADT_CDS_PRO',
          gc_update_cds_inventory     TYPE c LENGTH 30 VALUE 'UPDATE_CDS_INVENTORY',
          client_passed_in_amdp       TYPE c LENGTH 30 VALUE 'CLIENT_PASSED_IN_AMDP',
          gc_hash_in_annotation       TYPE c LENGTH 30 VALUE 'HASH_IN_ANNOTATION',
          gc_out_of_loop_methods      TYPE c LENGTH 30 VALUE 'OUT_OF_LOOP_METHODS',
*EOC By Sonal for CDS Profiler Defect #436
* eoc s/4 extensibility
*start ins Dhiraj 21/01/2020.
          gc_cl_aadt_log_file         TYPE c LENGTH 30 VALUE 'ZCL_AADT_CLOUD_LOGFILE',
*end ins Dhiraj 21/01/2020.
**BOC BY MANYA FOR BW INTEGRATION ON 06.03.2020
          gc_zcl_bw_execution         TYPE c LENGTH 30 VALUE 'ZCL_BW_EXTENSION',
          gc_get_routines             TYPE c LENGTH 30 VALUE 'GET_ROUTINES',
          gc_get_rules                TYPE c LENGTH 30 VALUE 'GET_RULES',
          gc_get_info_obj_inv         TYPE c LENGTH 30 VALUE 'GET_INFO_OBJ_INV',
          gc_get_info_obj_det         TYPE c LENGTH 30 VALUE 'GET_INFO_OBJ_DET',
          gc_get_final_abap_code      TYPE c LENGTH 30 VALUE 'GET_FINAL_ABAP_CODE',
          gc_e                        TYPE c LENGTH 1  VALUE 'E',                                 " Constant for Error
          gc_i                        TYPE c LENGTH 1  VALUE 'I',                                 " Constant for Information
          gc_s                        TYPE c LENGTH 1  VALUE 'S',                                 " Constant for Success
**EOC BY MANYA FOR BW INTEGRATION ON 06.03.2020
          gc_event_handle             TYPE c LENGTH 30 VALUE 'ZCL_AADT_HANDLE_EVENTS', " Added by Parul Puri for DEFECT ID - 537 on 03.01.2021

          gc_sub_scr_val              TYPE c LENGTH 30 VALUE 'SUB_SCREEN_VALIDATION', "added by deepika on 17/11/2021 for CR 813
          gc_sub_val                  TYPE c LENGTH 30 VALUE 'SUB_VALIDATION', "added by deepika on 17/11/2021 for CR 813
          gc_get_d                    TYPE c LENGTH 30 VALUE 'GET_DATA', "added by deepika on 17/11/2021 for CR 813
          gc_process_data             TYPE c LENGTH 30 VALUE 'PROCESS_DATA', "added by deepika on 17/11/2021 for CR 813
          gc_process_drill            TYPE c LENGTH 30 VALUE 'PROCESS_DRILLDOWN', "added by deepika on 17/11/2021 for CR 813
          gc_create_nugg              TYPE c LENGTH 30 VALUE 'CREATE_NUGG_FILE', "added by deepika on 17/11/2021 for CR 813
          gc_add_obj                  TYPE c LENGTH 30 VALUE 'ADD_OBJECTS', "added by deepika on 17/11/2021 for CR 813
          gc_dis_alv                  TYPE c LENGTH 30 VALUE 'DISPLAY_ALV', "added by deepika on 17/11/2021 for CR 813
          gc_fill_bdc                 TYPE c LENGTH 30 VALUE 'FILL_BDC_DATA', "added by deepika on 17/11/2021 for CR 813
          gc_d_obj_file               TYPE c LENGTH 30 VALUE 'DOWNLOAD_OBJ_FILE', "added by deepika on 17/11/2021 for CR 813
          gc_import_on                TYPE c LENGTH 30 VALUE 'IMPORT_ON', "added by deepika on 06/12/2021 for CR 813
          gc_display_on               TYPE c LENGTH 30 VALUE 'DISPLAY_ON', "added by deepika on 06/12/2021 for CR 813
          gc_cl_depe_obj              TYPE c LENGTH 30 VALUE 'ZCL_AADT_CWRM_DEPENDENT_OBJ', " Added by Palani for CR 814 on 06/12/2021
          gc_liftshift_upload         TYPE c LENGTH 30 VALUE 'ZCL_AADT_CWRM_UPLOAD', "added by deepika on 17/11/2021 for CR 813
          gc_liftshift_download       TYPE c LENGTH 30 VALUE 'ZCL_AADT_CWRM_DOWNLOAD', "added by deepika on 17/11/2021 for CR 813
          gc_fill_bdc_data            TYPE c LENGTH 30 VALUE 'FILL_BDC_DATA', "added by deepika on 06/12/2021 for CR 813
***BOC by deepika for cr #813 on 09/12/2021
*          gc_cx_cwrm                  TYPE c LENGTH 30 VALUE 'ZCX_AADT_CWRM',"commented by deepika on 16/2/2022 for defect #1118
          gc_cx_cwrm                  TYPE c LENGTH 30 VALUE '/ACNIP/ZCX_AADT_CWRM',"added by deepika on 16/2/2022 for defect #1118
          gc_cl_cwrm                  TYPE c LENGTH 30 VALUE 'ZCL_AADT_CWRM',
          gc_cl_cwrm_bsp              TYPE c LENGTH 30 VALUE 'ZCL_AADT_CWRM_BSP',
          gc_cl_cwrm_checkpoint_group TYPE c LENGTH 30 VALUE 'ZCL_AADT_CWRM_CHECKPOINT_GROUP',
          gc_cl_cwrm_class            TYPE c LENGTH 30 VALUE 'ZCL_AADT_CWRM_CLASS',
          gc_cl_cwrm_data_elements    TYPE c LENGTH 30 VALUE 'ZCL_AADT_CWRM_DATA_ELEMENTS',
          gc_cl_cwrm_documentation    TYPE c LENGTH 30 VALUE 'ZCL_AADT_CWRM_DOCUMENTATION',
          gc_cl_cwrm_domains          TYPE c LENGTH 30 VALUE 'ZCL_AADT_CWRM_DOMAINS',
          gc_cl_cwrm_enh_implement    TYPE c LENGTH 30 VALUE 'ZCL_AADT_CWRM_ENH_IMPLEMENT',
          gc_cl_cwrm_enh_spot         TYPE c LENGTH 30 VALUE 'ZCL_AADT_CWRM_ENH_SPOT',
          gc_cl_cwrm_functiongroup    TYPE c LENGTH 30 VALUE 'ZCL_AADT_CWRM_FUNCTIONGROUP',
          gc_cl_cwrm_index            TYPE c LENGTH 30 VALUE 'ZCL_AADT_CWRM_INDEX',
          gc_cl_cwrm_interface        TYPE c LENGTH 30 VALUE 'ZCL_AADT_CWRM_INTERFACE',
          gc_cl_cwrm_lock_objects     TYPE c LENGTH 30 VALUE 'ZCL_AADT_CWRM_LOCK_OBJECTS',
          gc_cl_cwrm_message_class    TYPE c LENGTH 30 VALUE 'ZCL_AADT_CWRM_MESSAGE_CLASS',
          gc_cl_cwrm_mime             TYPE c LENGTH 30 VALUE 'ZCL_AADT_CWRM_MIME',
          gc_cl_cwrm_nugget           TYPE c LENGTH 30 VALUE 'ZCL_AADT_CWRM_NUGGET',
          gc_cl_cwrm_oo               TYPE c LENGTH 30 VALUE 'ZCL_AADT_CWRM_OO',
          gc_cl_cwrm_pdf_forms        TYPE c LENGTH 30 VALUE 'ZCL_AADT_CWRM_PDF_FORMS',
          gc_cl_cwrm_program          TYPE c LENGTH 30 VALUE 'ZCL_AADT_CWRM_PROGRAM',
          gc_cl_cwrm_search_helps     TYPE c LENGTH 30 VALUE 'ZCL_AADT_CWRM_SEARCH_HELPS',
          gc_cl_cwrm_sicf             TYPE c LENGTH 30 VALUE 'ZCL_AADT_CWRM_SICF',
          gc_cl_cwrm_smartform        TYPE c LENGTH 30 VALUE 'ZCL_AADT_CWRM_SMARTFORM',
          gc_cl_cwrm_tables           TYPE c LENGTH 30 VALUE 'ZCL_AADT_CWRM_TABLES',
          gc_cl_cwrm_tables_contents  TYPE c LENGTH 30 VALUE 'ZCL_AADT_CWRM_TABLE_CONTENTS',
          gc_cl_cwrm_tabletechsetting TYPE c LENGTH 30 VALUE 'ZCL_AADT_CWRM_TABLETECHSETTING',
          gc_cl_cwrm_table_types      TYPE c LENGTH 30 VALUE 'ZCL_AADT_CWRM_TABLE_TYPES',
          gc_cl_cwrm_transactions     TYPE c LENGTH 30 VALUE 'ZCL_AADT_CWRM_TRANSACTIONS',
          gc_cl_cwrm_transformation   TYPE c LENGTH 30 VALUE 'ZCL_AADT_CWRM_TRANSFORMATION',
          gc_cl_cwrm_user_parameter   TYPE c LENGTH 30 VALUE 'ZCL_AADT_CWRM_USER_PARAMETER',
          gc_cl_cwrm_views            TYPE c LENGTH 30 VALUE 'ZCL_AADT_CWRM_VIEWS',
          gc_cl_cwrm_view_cluster     TYPE c LENGTH 30 VALUE 'ZCL_AADT_CWRM_VIEW_CLUSTER',
          gc_cl_cwrm_view_techsetting TYPE c LENGTH 30 VALUE 'ZCL_AADT_CWRM_VIEW_TECHSETTING',
          gc_cl_cwrm_wd_application   TYPE c LENGTH 30 VALUE 'ZCL_AADT_CWRM_WD_APPLICATION',
          gc_cl_cwrm_wd_component     TYPE c LENGTH 30 VALUE 'ZCL_AADT_CWRM_WD_COMPONENT',
          gc_cl_cwrm_wd_config_appl   TYPE c LENGTH 30 VALUE 'ZCL_AADT_CWRM_WD_CONFIG_APPL',
          gc_cl_cwrm_wd_config_comp   TYPE c LENGTH 30 VALUE 'ZCL_AADT_CWRM_WD_CONFIG_COMP',
          gc_cl_cwrm_wtag             TYPE c LENGTH 30 VALUE 'ZCL_AADT_CWRM_WTAG',
          gc_cl_cwrm_pdf_interfaces   TYPE c LENGTH 30 VALUE 'ZCL_AADT_CWRM_PDF_INTERFACES'.
***EOC by deepika for cr #813 on 09/12/2021




CONSTANTS:gc_class_table TYPE  e071-obj_name VALUE '/ACNIP/ZAADT_UPL'.

DATA:gv_det TYPE string.
DATA :gv_db           TYPE c LENGTH 10, "char10 , "VALUE sy-dbsys,
      gv_ehp          TYPE host   , "VALUE sy-host,
      gv_inst         TYPE c  LENGTH 10,
      gc_cl_s4_pro    TYPE c LENGTH 30 VALUE 'ZCL_AADT_S4_PRO',
      gc_cl_cloud_pro TYPE c LENGTH 30 VALUE 'ZCL_AADT_CLOUD_PRO',
*      gc_cl_s4_pro1 TYPE c LENGTH 30 VALUE 'ZCL_AADT_S4_PRO_COPY',
      gv_dclnt        TYPE mandt.  "VALUE sy-mandt.
* BOC by Gunjan on 4/5/2021 Defect 802
TYPES: BEGIN OF ty_dete,
         object   TYPE /acnip/zatb_dete-object,
         obj_name TYPE /acnip/zatb_dete-obj_name,
         zpackage TYPE /acnip/zatb_dete-obj_package,
       END OF ty_dete.
* EOC by Gunjan on 4/5/2021 Defect 802

DATA: gt_modlog   TYPE STANDARD TABLE OF string,
      lv_extn(50) TYPE c,                                   " FILE Extenstion Variable
      lv_dir      TYPE string,                              " Folder Path Variable
*      gv_manfile  TYPE string,                              " Folder Path Variable COMMENTED BY PARUL
      gt_inv      TYPE TABLE OF /acnip/zatb_inve,          " Inventory  Internal Table
      gw_inv      TYPE  /acnip/zatb_inve,          " Inventory  work area
      gt_detect   TYPE TABLE OF ty_dete.         "Added by Gunjan on 4/5/2021 Defect 802

TYPES:BEGIN OF ty_class_det,
        cname TYPE c LENGTH 40, "char40,
        cstat TYPE c LENGTH 1,  "char1,
      END OF ty_class_det.
DATA:git_cnames TYPE TABLE OF ty_class_det.
DATA:gwa_cnames TYPE  ty_class_det.

*UI5 Extractor********************
DATA : appname TYPE o2applname.

**BOC BY MANYA FOR BW INTEGRATION ON 06.03.2020
TYPES: BEGIN OF lty_rsaabap,
         codeid     TYPE c LENGTH 30, "char30,
         line_no(6) TYPE n,
         line(72)   TYPE c,
       END OF lty_rsaabap .

TYPES:
  BEGIN OF lty_gt_codeid,
    tranid(32)  TYPE c,
    codeid(32)  TYPE c,
    objty       TYPE c LENGTH 4, "char4,
    subtype(32) TYPE c,
  END OF lty_gt_codeid .


DATA: it_rsaabap     TYPE STANDARD TABLE OF lty_rsaabap,
      wa_rsaabap     TYPE lty_rsaabap,
      it_code_id     TYPE STANDARD TABLE OF lty_gt_codeid,
      wa_code_id(32) TYPE c,
      lv_subtype     TYPE string.

FIELD-SYMBOLS: <fs_rsaabap> TYPE lty_rsaabap,
               <fs_code_id> TYPE lty_gt_codeid.
**EOC BY MANYA FOR BW INTEGRATION ON 06.03.2020
** Begin of Change by Manisha for defect#544 on 17/12/2020
TYPES: BEGIN OF ty_s_st03,
         low   TYPE c LENGTH 200,
         count TYPE c LENGTH 100,
       END OF ty_s_st03.
DATA :  s_st03         TYPE STANDARD TABLE OF ty_s_st03.
** End of Change By Manisha for defect#544 on 17/12/2020


*BOC by Vikas for Defect#408
DATA: lv_objname TYPE c LENGTH 40,
      lv_objtype TYPE c LENGTH 4,
      lv_scope   TYPE c LENGTH 4.
*      lv_include TYPE c LENGTH 40.
*EOC by Vikas for Defect#408


* BOC by Sonal for 04/01/2021 for CDS Profiler Defect #436
DATA: gv_ddls TYPE sobj_name.
* EOC by Sonal for 04/01/2021 for CDS Profiler Defect #436
***** BOC PARUL PURI FOR DEFECT ID - 537 on 03.01.2021
TYPES:
  BEGIN OF ty_output,
    s_no            TYPE i,
    correction(4)   TYPE c,
    object_type(4)  TYPE c,
    object_name(50) TYPE c,
    include(50)     TYPE c,
    tr              TYPE e071-trkorr,
    new_line        TYPE i,
    prb_statement   TYPE string,
    status(20)      TYPE c,
    comments        TYPE char255,
    color           TYPE lvc_t_scol,
  END OF ty_output .
DATA: gt_output TYPE TABLE OF ty_output.
***** EOC PARUL PURI FOR DEFECT ID - 537 on 03.01.2021

CONSTANTS: gc_m_check_hardcoding TYPE c LENGTH 30 VALUE 'CHECK_HARDCODING'.
""BOC by Jeba for CR 695 on 18.03.2021 Hide the utilites
DATA : gv_scope     TYPE /acnip/zjunk_col,
       gt_scope_tmp TYPE TABLE OF string,
       gw_scope_tmp TYPE string.
TYPES : BEGIN OF lty_scope,
          scope(5) TYPE c,
        END OF lty_scope.
DATA : gt_scope TYPE TABLE OF lty_scope,
       gw_scope TYPE lty_scope.
TYPES : BEGIN OF lty_dete,
          object      TYPE /acnip/zatb_dete-object,
          obj_name    TYPE /acnip/zatb_dete-obj_name,
          opercd      TYPE /acnip/zatb_dete-opercd,
          obj_package TYPE /acnip/zatb_dete-obj_package,
        END OF lty_dete.
DATA :  i_dete      TYPE TABLE OF lty_dete,
        gw_dete      TYPE  lty_dete.
"EOC by Jeba for CR 695 on 18.03.2021
* DATA zgc_cl_corr_pro1 TYPE c LENGTH 40 VALUE 'ZCL_AADT_AUTO_CORR_TEST'. "testing for corrections



***BOC by deepika for CR 813 on 01/12/2021


TYPES: BEGIN OF t_result,
         obj_type   TYPE trobjtype,   " Anand - Obj Type changes
         obj_name   TYPE sobj_name,
         include    TYPE sobj_name,
         fm_name    TYPE rs38l_fnam , "sobj_name,
         tcode_name TYPE sobj_name,
         submit     TYPE sobj_name,
*         tables     TYPE sobj_name,
         message    TYPE sobj_name,
         lock       TYPE sobj_name,
       END OF t_result,

       BEGIN OF t_tmoutput,
         obj_type   TYPE trobjtype,  " Anand - Obj Type changes
         obj_name   TYPE sobj_name,
         include    TYPE char40,
         fm_name    TYPE rs38l_fnam , "sobj_name,
         tcode_name TYPE tcodel,
         submit     TYPE char40,
*         message    TYPE ops_se_message_id,
         message    TYPE char40, "crm compatibility 22/02/2022
         lock       TYPE enqname,
*         tables     TYPE aut_tabname , "tabname16,
         tables     TYPE char30, "crm compatibility 22/02/2022
         view       TYPE viewname16,
         dtel       TYPE typename,
         doma       TYPE domname_sg,
         shlp       TYPE shlpname,
         class      TYPE char30,
       END OF t_tmoutput,


       BEGIN OF t_progname,
         obj_type TYPE trobjtype,  "  Anand - Obj Type changes
         obj_name TYPE char40,
       END OF t_progname,


       BEGIN OF t_progname1,
         object   TYPE trobjtype, " Tanvir 03.04.2021
         obj_name TYPE char40,
       END OF t_progname1,

       BEGIN OF t_objecttable,
         classname TYPE string,
         object    TYPE ko100-object,
         text      TYPE ko100-text,
       END OF t_objecttable.


DATA: lt_tmoutput TYPE TABLE OF t_tmoutput,
      ls_tmoutput TYPE t_tmoutput.

DATA: gt_progname      TYPE TABLE OF t_progname1,
      gv_namespace     TYPE namespace,
      gt_result        TYPE TABLE OF t_result.

TYPES: BEGIN OF t_fg_names,
         funcname TYPE rs38l_fnam,
         pname    TYPE pname,
         flag     TYPE char1,
       END OF t_fg_names.

DATA: lt_result    TYPE TABLE OF t_result,
      lt_result_1  TYPE TABLE OF t_result,
      ls_result    TYPE t_result,
      lt_fg_names  TYPE TABLE OF t_fg_names,
      ls_fg_names  TYPE t_fg_names.
*      zt_result    TYPE TABLE OF t_result,
*      zs_result    TYPE t_result.

TYPES: BEGIN OF t_output,
         obj_type TYPE trobjtype,   " Anand - Obj Type changes
         progname TYPE sobj_name,
         tables   TYPE char30,
         view     TYPE char30,
         dtel     TYPE char30,
         doma     TYPE char30,
         shlp     TYPE shlpname,
         class    TYPE seoclsname,
       END OF t_output.

DATA: lt_output   TYPE TABLE OF t_output,
      ls_output   TYPE t_output,
      gt_progname2    TYPE TABLE OF t_progname1,
      wa_progname2    TYPE t_progname1,
*      gv_nug_file     TYPE char300,
      gv_nug_file     TYPE string, "crm compatibility 22/02/2022
      gt_plugins      TYPE TABLE OF t_objecttable,
        v_flgchar   TYPE          char20.
*BOC by Jeba on 22/02/22 for crm compatibility
TYPES : BEGIN OF ty_alsmex_tabline,
        ROW TYPE KCD_EX_ROW_N,
        COL TYPE KCD_EX_COL_N,
        VALUE TYPE CHAR50,
       END OF ty_alsmex_tabline.
*EOC by Jeba on 22/02/22 for crm compatibility
DATA: gt_filetab      TYPE filetable,
      gv_ret          TYPE i,
      gv_cnt          TYPE i,
      gt_usraction    TYPE i,
      gv_infile       TYPE rlgrap-filename,
*      gt_objects      TYPE TABLE OF alsmex_tabline,
      gt_objects      TYPE TABLE OF ty_alsmex_tabline, "Added by Jeba on 22/02/22 for crm compatibility
*      gs_objects      TYPE alsmex_tabline.
      gs_objects      TYPE ty_alsmex_tabline. ""Added by Jeba on 22/02/22 for crm compatibility


*--------------------------------------------

DATA: gv_tr    TYPE trkorr,
      gv_prog  TYPE programm,
      gv_fg    TYPE rs38l_fnam,
      gv_pack  TYPE devclass,
      gv_class TYPE seoclsname.

*----------------boc-for upload program data declaration------

TYPES: BEGIN OF tt_tmoutput," t_tmoutput is changed to tt_tmoutput on 05/11/2021 by deepika for integration
         obj_type   TYPE trobjtype,  " Anand - Obj Type changes
         obj_name   TYPE sobj_name,
         include    TYPE char40,
         fm_name    TYPE rs38l_fnam , "sobj_name,
         tcode_name TYPE tcodel,
         submit     TYPE char40,
*         message    TYPE ops_se_message_id,
         message    TYPE char40, "crm compatibility 22/02/2022
         lock       TYPE enqname,
*         tables     TYPE aut_tabname , "tabname16,
         tables     TYPE char30, "crm compatibility 22/02/2022
         view       TYPE viewname16,
         dtel       TYPE typename,
         doma       TYPE domname_sg,
         shlp       TYPE shlpname,
         class      TYPE char30,
       END OF tt_tmoutput.

DATA :retfiletable    TYPE filetable,
       retrc           TYPE sysubrc,
       retuseraction   TYPE i.

DATA: lv_file      TYPE string,
      llt_tmoutput TYPE TABLE OF tt_tmoutput, " lt_tmoutput is changed to llt_tmoutput on 05/11/2021 by deepika for integration
      lt_file      TYPE filetable,
      lv_rc        TYPE i.
TYPES:
  BEGIN OF t_progg,
    sign(1) TYPE c,
    option  TYPE char2,
    low     TYPE programm,
    high    TYPE programm,
  END OF t_progg .

TYPES:
  BEGIN OF t_fg,
    sign(1) TYPE c,
    option  TYPE char2,
    low     TYPE rs38l_fnam,
    high    TYPE rs38l_fnam,
  END OF t_fg .

TYPES:
  BEGIN OF t_class,
    sign(1) TYPE c,
    option  TYPE char2,
    low     TYPE seoclsname,
    high    TYPE seoclsname,
  END OF t_class .

TYPES:
  BEGIN OF t_cust,
    sign(1) TYPE c,
    option  TYPE char2,
    low     TYPE namespace,
    high    TYPE namespace,
  END OF t_cust .

TYPES:
  BEGIN OF t_trreq,
    sign(1) TYPE c,
    option  TYPE char2,
    low     TYPE trkorr,
    high    TYPE trkorr,
  END OF t_trreq .

TYPES:
  BEGIN OF t_pack,
    sign(1) TYPE c,
    option  TYPE char2,
    low     TYPE devclass,
    high    TYPE devclass,
  END OF t_pack .

DATA: lt_sprogg TYPE STANDARD TABLE OF  t_progg,
      ls_sprogg LIKE LINE OF lt_sprogg,
      lt_sfg    TYPE STANDARD TABLE OF t_fg,
      ls_sfg    LIKE LINE OF lt_sfg,
      lt_sclass TYPE STANDARD TABLE OF  t_class,
      ls_sclass LIKE LINE OF lt_sclass,
      lt_strreq TYPE STANDARD TABLE OF t_trreq,
      ls_strreq LIKE LINE OF lt_strreq,
      lt_spack  TYPE STANDARD TABLE OF t_pack,
      ls_spack  LIKE LINE OF lt_spack,
      lt_scust  TYPE STANDARD TABLE OF t_cust,
      ls_scust  LIKE LINE OF lt_scust.
***EOC by deepika for CR 813 on 01/12/2021
*** BOC by Palani for CR 814 on 02/12/2021
DATA: gv_obj_typ TYPE trobjtype,
      gv_obj_nam TYPE sobj_name.
DATA: lt_dobj     TYPE STANDARD TABLE OF /acnip/zcwrm_dob,
      ls_dobj     TYPE /acnip/zcwrm_dob,
      lv_counter1 TYPE n LENGTH 10,
      lv_prev_obj TYPE char40.

FIELD-SYMBOLS <ls_dobj> TYPE /acnip/zcwrm_dob.

TYPES: BEGIN OF ty_obj,
         object   TYPE trobjtype,
         obj_name TYPE sobj_name,
       END OF ty_obj.

DATA: lt_object     TYPE STANDARD TABLE OF ty_obj,
      ls_object     TYPE ty_obj,
      lt_dresult    TYPE STANDARD TABLE OF t_result,
      lt_doutput    TYPE STANDARD TABLE OF t_output,
      lt_dprogname  TYPE STANDARD TABLE OF ty_obj,
      lt_dprogname2 TYPE STANDARD TABLE OF ty_obj.
*** EOC by Palani for CR 814 on 02/12/2021

*** BOC by Palani for CR 823 on 07/12/2021
TYPES: BEGIN OF ty_objt,
         objt TYPE trobjtype,
         text TYPE ddtext,
       END OF ty_objt.

DATA: lt_objt TYPE STANDARD TABLE OF ty_objt,
      ls_objt TYPE ty_objt.
*** EOC by Palani for CR 823 on 07/12/2021
*** BOC by Palani on 20/10/2021
DATA: lv_str1 TYPE string,
      lv_str3 TYPE string.
*** EOC by Palani on 20/10/2021

*** BOC by Palani on 12/11/2021
DATA: lt_tadir TYPE STANDARD TABLE OF tadir,
      ls_tadir TYPE tadir,
      lv_exist TYPE c,
      lv_tabix TYPE sy-tabix.
*** EOC by Palani on 12/11/2021
