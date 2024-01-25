class ZHANA_BADI_CLS definition
  public
  final
  create public .

public section.

  interfaces IF_BADI_INTERFACE .
  interfaces ZHANA_INTERFACE_ODATA .
*  data: TT_CLASS type STANDARD TABLE OF TY_CLASS .
protected section.
private section.
ENDCLASS.



CLASS ZHANA_BADI_CLS IMPLEMENTATION.


  METHOD ZHANA_INTERFACE_ODATA~CHECK_EDM_TYPE.

     TYPES:
      BEGIN OF ty_gs_edm_field_desc,
        core_type       TYPE  c LENGTH 20 , "/iwbep/if_mgw_med_odata_types=>ty_e_med_edm_type, "EDM Data Type
        length          TYPE  i,  "Length (No. of Characters)
        decimals        TYPE  i,  "Number of Decimal Places
        internal_type   TYPE  inttype,
        internal_length TYPE  i,
        input_mask      TYPE string,
        conv_exit       TYPE c LENGTH 5, "/iwbep/if_mgw_med_odata_types=>ty_e_med_conv_exit,
        semantic        TYPE c LENGTH 20, "/iwbep/if_mgw_med_odata_types=>ty_e_med_semantic,
        edm_precision   TYPE  i,
        edm_scale       TYPE  i,
        uppercase       TYPE abap_bool,
        length_org      TYPE  i, " original definition length
      END OF ty_gs_edm_field_desc .

    DATA  cs_edm_type TYPE ty_gs_edm_field_desc.
    DATA iv_odata_version TYPE char2 VALUE 'V2'.
    CONSTANTS:
      BEGIN OF gcs_abap_typekind,
        decfloat   TYPE abap_typekind VALUE '/',
        decfloat16 TYPE abap_typekind VALUE 'a',
        decfloat34 TYPE abap_typekind VALUE 'e',
        int8       TYPE abap_typekind VALUE '8',
      END OF gcs_abap_typekind .


    CASE p_kind.                                        "#EC CI_INT8_OK
      WHEN cl_abap_typedescr=>typekind_string.
        cs_edm_type-core_type = 'Edm.String'."/iwbep/if_mgw_med_odata_types=>gcs_edm_data_types-string.
        IF NOT p_dfies IS INITIAL AND
           p_dfies-lowercase IS INITIAL.
          cs_edm_type-uppercase = abap_true.
        ENDIF.
        CLEAR cs_edm_type-length_org.
      WHEN cl_abap_typedescr=>typekind_char.
        CASE p_dfies-domname.
          WHEN 'BOOLE' OR
               'XFELD' OR
               'XFLAG' OR
               'FLAG' OR
               'X' OR
               'DDFLAG' OR
               'CHAR1_X'.
            cs_edm_type-core_type = 'Edm.Boolean'."/iwbep/if_mgw_med_odata_types=>gcs_edm_data_types-boolean.
          WHEN 'SYSUUID_22' OR
               'SYSUUID_C' OR
               'SYSUUID_C22'.
            cs_edm_type-core_type = 'Edm.Guid'."/iwbep/if_mgw_med_odata_types=>gcs_edm_data_types-guid.
          WHEN OTHERS.
            IF p_dfies-leng EQ 1 AND
              ( p_dfies-domname CP '*BOOL*' OR
                p_dfies-domname CP '*FLAG*' ).
              cs_edm_type-core_type = 'Edm.Boolean'."/iwbep/if_mgw_med_odata_types=>gcs_edm_data_types-boolean.
            ELSEIF p_dfies-leng EQ 32 AND
              ( p_dfies-domname CP '*UUID*' OR
                p_dfies-domname CP '*GUID*' ).
              cs_edm_type-core_type = 'Edm.Guid'."/iwbep/if_mgw_med_odata_types=>gcs_edm_data_types-guid.
            ELSE.
              cs_edm_type-core_type = 'Edm.String'."/iwbep/if_mgw_med_odata_types=>gcs_edm_data_types-string.
            ENDIF.
        ENDCASE.
        IF NOT p_dfies IS INITIAL AND
           p_dfies-lowercase IS INITIAL.
          cs_edm_type-uppercase = abap_true.
        ENDIF.

      WHEN cl_abap_typedescr=>typekind_num.
*      CASE p_dfies-domname.
*        WHEN 'TZNTSTMPLL' OR - DOES not work!
*             'TZNTSTMPSL'.
*          cs_edm_type-core_type = /iwbep/if_mgw_med_odata_types=>gcs_edm_data_types-datetime.
*        WHEN OTHERS.
        cs_edm_type-core_type = 'Edm.String'."/iwbep/if_mgw_med_odata_types=>gcs_edm_data_types-string.
        cs_edm_type-input_mask = '[0-9]*'.   "Regular expression allowing only the letters 0-9
*      ENDCASE.
      WHEN cl_abap_typedescr=>typekind_date.
        IF iv_odata_version EQ 'V2'.
          cs_edm_type-core_type = 'Edm.DateTime'."/iwbep/if_mgw_med_odata_types=>gcs_edm_data_types-datetime.     "'Edm.DateTime'. (There is no Edm.Date, fill the rest with 0s)
        ELSE.
          cs_edm_type-core_type = 'Edm.Date'."/iwbep/if_mgw_med_odata_types=>gcs_edm_data_types-date.
        ENDIF.
        CLEAR cs_edm_type-length_org.
      WHEN cl_abap_typedescr=>typekind_time.
        IF iv_odata_version EQ 'V2'.
          cs_edm_type-core_type = 'Edm.Time'."/iwbep/if_mgw_med_odata_types=>gcs_edm_data_types-time.
        ELSE.
          cs_edm_type-core_type = 'Edm.TimeOfDay'."/iwbep/if_mgw_med_odata_types=>gcs_edm_data_types-timeofday.
        ENDIF.
        CLEAR cs_edm_type-length_org.
      WHEN cl_abap_typedescr=>typekind_xstring.
        cs_edm_type-core_type = 'Edm.Binary'."/iwbep/if_mgw_med_odata_types=>gcs_edm_data_types-binary.
      WHEN cl_abap_typedescr=>typekind_hex.
        CASE p_dfies-domname.
          WHEN 'SYSUUID'.
            cs_edm_type-core_type = 'Edm.Guid'."/iwbep/if_mgw_med_odata_types=>gcs_edm_data_types-guid.
          WHEN OTHERS.
*          IF io_abap_typedescr->length EQ 16 AND
*             ( p_dfies-domname CP '*UUID*' OR
*               p_dfies-domname CP '*GUID*' OR
*               p_dfies-rollname = 'GUID' ).
*            cs_edm_type-core_type = /iwbep/if_mgw_med_odata_types=>gcs_edm_data_types-guid.
*          ELSE.
*            cs_edm_type-core_type = /iwbep/if_mgw_med_odata_types=>gcs_edm_data_types-binary.
*          ENDIF.
        ENDCASE.
      WHEN cl_abap_typedescr=>typekind_packed.
        CASE p_dfies-domname.
          WHEN 'TZNTSTMPS' OR
               'TZNTSTMPL'.
            cs_edm_type-core_type = 'Edm.DateTimeOffset'."/iwbep/if_mgw_med_odata_types=>gcs_edm_data_types-datetimeoffset.
          WHEN OTHERS.
            cs_edm_type-core_type = 'Edm.Decimal'."/iwbep/if_mgw_med_odata_types=>gcs_edm_data_types-decimal.
        ENDCASE.
        CLEAR cs_edm_type-length_org.
      WHEN cl_abap_typedescr=>typekind_int1.
        cs_edm_type-core_type = 'Edm.Byte'."/iwbep/if_mgw_med_odata_types=>gcs_edm_data_types-byte.
        CLEAR cs_edm_type-length_org.
      WHEN cl_abap_typedescr=>typekind_int2.
        cs_edm_type-core_type = 'Edm.Int16'."/iwbep/if_mgw_med_odata_types=>gcs_edm_data_types-int16.
        CLEAR cs_edm_type-length_org.
      WHEN cl_abap_typedescr=>typekind_int.
        cs_edm_type-core_type = 'Edm.Int32'."/iwbep/if_mgw_med_odata_types=>gcs_edm_data_types-int32.
        CLEAR cs_edm_type-length_org.
      WHEN cl_abap_typedescr=>typekind_float.
        cs_edm_type-core_type = 'Edm.Double'."/iwbep/if_mgw_med_odata_types=>gcs_edm_data_types-double.
        CLEAR cs_edm_type-length_org.

*   In 7.00 the following types do not exist, but they do exist in 7.02 or 7.50
*   (see for reference method GET_ABAP_TYPE_FROM_EDM_TYPE)
      WHEN gcs_abap_typekind-decfloat.
        cs_edm_type-core_type = 'Edm.Decimal'."/iwbep/if_mgw_med_odata_types=>gcs_edm_data_types-decimal.
        CLEAR cs_edm_type-length_org.
      WHEN gcs_abap_typekind-decfloat16.
        cs_edm_type-core_type = 'Edm.Decimal'."/iwbep/if_mgw_med_odata_types=>gcs_edm_data_types-decimal.
        CLEAR cs_edm_type-length_org.
      WHEN gcs_abap_typekind-decfloat34.
        cs_edm_type-core_type = 'Edm.Decimal'."/iwbep/if_mgw_med_odata_types=>gcs_edm_data_types-decimal.
        CLEAR cs_edm_type-length_org.
      WHEN gcs_abap_typekind-int8.                      "#EC CI_INT8_OK
        cs_edm_type-core_type = 'Edm.Int64'."/iwbep/if_mgw_med_odata_types=>gcs_edm_data_types-int64.
        CLEAR cs_edm_type-length_org.
      WHEN OTHERS.
        cs_edm_type-core_type = 'NA'.
*        ASSERT 1 = 0. "unsupported type
    ENDCASE.
    e_edm_typ = cs_edm_type-core_type.


  ENDMETHOD.


  METHOD zhana_interface_odata~get_odata_opcodes.

    TYPES : BEGIN OF lty_table,
              parameter TYPE char50,
              value     TYPE char50,
            END OF lty_table,

            BEGIN OF ty_final,
              obj_name    TYPE sobj_name,
              objtyp      TYPE trobjtype,
              prog        TYPE progname,
              sub_type    TYPE seocpdname,
              read_prog   TYPE progname,
              line        TYPE sy-tabix,
              drill       TYPE i,
              oper(120)   TYPE c,
              opercd      TYPE i,
              act_st      TYPE string,
              table       TYPE string,
              join        TYPE char3,
*         type          type char20,
              type        TYPE string,
              fields      TYPE string,
              filters     TYPE string,
              itabs       TYPE string,
              wa          TYPE string,
              loop        TYPE string,
              code        TYPE char1024,
              check       TYPE char255,
              critical    TYPE char6,
              filtrnew    TYPE string,
              codenew     TYPE string,
              clas        TYPE char30,
              method      TYPE char50,
              corr        TYPE char1,
              where_con   TYPE string,
              keys        TYPE string,
              delflg      TYPE char1,
* Begin of change by Twara 12/02/2016 to get line number of SELECT
              select_line TYPE string,
* End of change by Twara 12/02/2016 to get line number of SELECT
              "begin of code change for Odata_def_24
              odata       TYPE char1,
              sub_program TYPE char40,
              "end of code change for Odata_def_24
            END OF ty_final,

*         * Begin of changes by Akshay for OData_Def_24
            BEGIN OF ty_mgdeam,
              service_id   TYPE char40, "/iwfnd/med_mdl_srg_identifier,
              user_role    TYPE char30, "/iwfnd/defi_role_name,
              host_name    TYPE char120, "/iwfnd/mgw_inma_host_name,
              system_alias TYPE char16, "/iwfnd/defi_system_alias,
              is_default   TYPE char1,  "/iwfnd/mgw_inma_default_alias,
            END OF ty_mgdeam .
* End of changes by Akshay for OData_Def_24

    TYPES : BEGIN OF ty_class,
              class_name         TYPE char30, "/iwbep/med_runtime_service,
              external_name      TYPE char40, "/iwbep/med_grp_external_name,
              service_name       TYPE char35, "/iwbep/med_grp_technical_name,
              group_version(4)   TYPE  n, "/iwbep/med_grp_version,   "Added by Akshay_Def_24
              service_version(4) TYPE n, "/iwbep/med_grp_version,   "Added by Akshay_Def_24
              dpc_class          TYPE char30, "/iwbep/med_runtime_service,
              dpc_ext_class      TYPE char30, "/iwbep/med_runtime_service,
              mpc_class          TYPE char30, "/iwbep/med_runtime_service,
              mpc_ext_class      TYPE char30, "/iwbep/med_runtime_service,
              odata              TYPE wdy_boolean,
            END OF ty_class.

    DATA :
      ls_class  TYPE ty_class,
      lt_class1 TYPE STANDARD TABLE OF ty_class.


    DATA : lv_icf_name         TYPE icfname,
           lwa_final           TYPE ty_final,
           lv_serv_version(40) TYPE c.

    DATA: icf_extensions   TYPE STANDARD TABLE OF
                          ihttp_icfservice_extension WITH KEY kind,
          wa_extensions    TYPE ihttp_icfservice_extension,
          cust_string      TYPE string,
          cust_xstring     TYPE xstring,
          lv_content(1000) TYPE c,
          lt_itab          TYPE STANDARD TABLE OF itab,
          ls_itab          TYPE  itab,
          lt_table         TYPE STANDARD TABLE OF lty_table,
          ls_table         TYPE lty_table,
          lt_512           TYPE STANDARD TABLE OF icfservloc,
          lt_mgdeam        TYPE STANDARD TABLE OF ty_mgdeam,
*      ls_mgdeam             TYPE /iwfnd/c_mgdeam,
          ls_mgdeam        TYPE ty_mgdeam,
          lt_passwd        TYPE STANDARD TABLE OF icfsecpasswd,
          ls_passwd        TYPE icfsecpasswd.

    DATA : lt_rfc_db_fld TYPE STANDARD TABLE OF rfc_db_fld,
           ls_rfc_db_fld TYPE rfc_db_fld,
           ls_512        TYPE icfservloc.


    CONSTANTS: lc_icfservice_action_unpack TYPE i VALUE 2,
               lc_csrf_token(20)           TYPE c VALUE '~CHECK_CSRF_TOKEN'.

    lt_class1[] = lt_class[].

    SELECT SINGLE icf_name
      FROM icfservice
      INTO lv_icf_name
      WHERE icfaltnme = lv_serv.

    IF lv_ok IS NOT INITIAL
           AND lv_icf_name IS NOT INITIAL.
      SELECT SINGLE icf_custstr
      FROM icfapplcust
       INTO cust_xstring
      WHERE icf_name = lv_icf_name.
      IF cust_xstring IS NOT INITIAL.
        CALL FUNCTION 'ICF_SERVICE_EXTENSION'
          EXPORTING
            action                        = lc_icfservice_action_unpack
          IMPORTING
            to_extensions                 = icf_extensions
          CHANGING
            icfservice_container          = cust_xstring
          EXCEPTIONS
            icf_action_not_supported      = 1
            icf_incomplete_information    = 3
            icf_invalid_service_container = 4
            OTHERS                        = 5.
        IF sy-subrc = 0.
          READ TABLE icf_extensions INTO wa_extensions INDEX 1.
          IF sy-subrc = 0.
            lv_content = wa_extensions-content.

            SPLIT lv_content AT  cl_abap_char_utilities=>cr_lf  INTO TABLE lt_itab IN CHARACTER MODE.


            LOOP AT lt_itab INTO ls_itab.
              SPLIT ls_itab AT space INTO ls_table-parameter ls_table-value.
              APPEND ls_table TO lt_table.
              CLEAR : ls_itab, ls_table.
            ENDLOOP.

            SORT lt_table BY parameter.

            READ TABLE lt_table INTO ls_table
                                WITH KEY parameter = lc_csrf_token
                                BINARY SEARCH.
            IF sy-subrc = 0.
              IF ls_table-value = '0'.

                SORT lt_class1 BY service_name group_version.

                CLEAR : lv_serv_version.
                READ TABLE lt_class1 INTO ls_class WITH KEY
                                                         service_name = lv_serv..
                IF sy-subrc = 0.
                  CONCATENATE lv_serv ls_class-group_version INTO lv_serv_version
                   SEPARATED BY '_'.
                ENDIF.

                "Append Final table
*                lwa_final-obj_name = lv_serv.
                lwa_final-obj_name = lv_serv_version.
                lwa_final-sub_program = lv_class.
                lwa_final-prog     =  lv_class.
*                    lwa_final-drill    = gv_drill.
                lwa_final-opercd   = '76'.   "Operation Code
                lwa_final-objtyp  = 'IWSV'.
*  Begin of changes by Akshay for Def_35
*                lwa_final-odata   = 'A'.
                lwa_final-odata   = lv_odata.

                APPEND lwa_final TO lt_final1.
              ENDIF.
            ENDIF.
          ENDIF.
        ENDIF.
      ENDIF.
    ENDIF.
    CLEAR : lwa_final.

    IF lt_512 IS INITIAL AND lv_ok IS NOT INITIAL.
      REFRESH lt_rfc_db_fld.

      ls_rfc_db_fld-fieldname = 'ICF_NAME'.
      APPEND ls_rfc_db_fld TO lt_rfc_db_fld.

      ls_rfc_db_fld-fieldname = 'ICFPARGUID'.
      APPEND ls_rfc_db_fld TO lt_rfc_db_fld.

      ls_rfc_db_fld-fieldname = 'ICFACTIVE'.
      APPEND ls_rfc_db_fld TO lt_rfc_db_fld.

      ls_rfc_db_fld-fieldname = 'ICFSRVGRP'.
      APPEND ls_rfc_db_fld TO lt_rfc_db_fld.

      CALL FUNCTION 'RFC_READ_TABLE' DESTINATION i_dest_name
        EXPORTING
          query_table          = 'ICFSERVLOC'
*         DELIMITER            = ' '
*         NO_DATA              = ' '
*         ROWSKIPS             = 0
*         ROWCOUNT             = 0
        TABLES
*         options              =
          fields               = lt_rfc_db_fld
          data                 = lt_512
        EXCEPTIONS
          table_not_available  = 1
          table_without_data   = 2
          option_not_valid     = 3
          field_not_valid      = 4
          not_authorized       = 5
          data_buffer_exceeded = 6
*         OTHERS               = 7
        .
      IF sy-subrc <> 0.
* Implement suitable error handling here
*          ENDIF.
      ELSE.

        READ TABLE lt_512 INTO ls_512 WITH KEY icf_name = lv_icf_name.

        IF sy-subrc EQ 0.
          IF ls_512-icfactive IS INITIAL.

            SORT lt_class1 BY service_name group_version.

            CLEAR : lv_serv_version.
            READ TABLE lt_class1 INTO ls_class WITH KEY
                                                     service_name = lv_serv..
            IF sy-subrc = 0.
              CONCATENATE lv_serv ls_class-group_version INTO lv_serv_version
               SEPARATED BY '_'.
            ENDIF.
            "Append Final table
*            lwa_final-obj_name = lv_serv.
            lwa_final-obj_name = lv_serv_version.
            lwa_final-sub_program = lv_class.
            lwa_final-prog     =  lv_class.
*                lwa_final-drill    = gv_drill.
            lwa_final-opercd   = '59'.   "Operation Code
            lwa_final-objtyp  = 'IWSV'.
*  Begin of changes by Akshay for Def_35
*                lwa_final-odata   = 'A'.
            lwa_final-odata   = lv_odata.

            APPEND lwa_final TO lt_final1.
            CLEAR lwa_final.
          ENDIF.
        ELSE.

          SORT lt_class1 BY service_name group_version.

          CLEAR : lv_serv_version.
          READ TABLE lt_class1 INTO ls_class WITH KEY
                                                   service_name = lv_serv..
          IF sy-subrc = 0.
            CONCATENATE lv_serv ls_class-group_version INTO lv_serv_version
             SEPARATED BY '_'.
          ENDIF.

*          lwa_final-obj_name = lv_serv.
          lwa_final-obj_name = lv_serv_version.
          lwa_final-sub_program = lv_class.
          lwa_final-prog     =  lv_class.
*              lwa_final-drill    = gv_drill.
          lwa_final-opercd   = '59'.   "Operation Code
          lwa_final-objtyp  = 'IWSV'.
*  Begin of changes by Akshay for Def_35
*                lwa_final-odata   = 'A'.
          lwa_final-odata   = lv_odata.
*  End of changes by Akshay for Def_35
          APPEND lwa_final TO lt_final1.
          CLEAR lwa_final.
        ENDIF.
      ENDIF.
    ELSE.
      READ TABLE lt_512 INTO ls_512 WITH KEY icf_name = lv_icf_name.

      IF sy-subrc EQ 0.
        IF ls_512-icfactive IS INITIAL.

          SORT lt_class1 BY service_name group_version.

          CLEAR : lv_serv_version.
          READ TABLE lt_class1 INTO ls_class WITH KEY
                                                   service_name = lv_serv..
          IF sy-subrc = 0.
            CONCATENATE lv_serv ls_class-group_version INTO lv_serv_version
             SEPARATED BY '_'.
          ENDIF.

          "Append Final table
*          lwa_final-obj_name = lv_serv.
          lwa_final-obj_name = lv_serv_version.
          lwa_final-sub_program = lv_class.
          lwa_final-prog     =  lv_class.
*              lwa_final-line     = lwa_sel_t-line.
*              lwa_final-drill    = gv_drill.
          lwa_final-opercd   = '59'.   "Operation Code
*              lwa_final-itabs    = lwa_sel_t-table.
*              lwa_final-table    = lwa_sel_t-dbtable.
          lwa_final-objtyp  = 'IWSV'.
*  Begin of changes by Akshay for Def_35
*                lwa_final-odata   = 'A'.
          lwa_final-odata   = lv_odata.
*  End of changes by Akshay for Def_35
*              lwa_final-keys     = lv_str2_tmp.
*              lwa_final-fields   = lv_fields.
          APPEND lwa_final TO lt_final1.
          CLEAR lwa_final.
        ENDIF.
      ENDIF.
    ENDIF.

    "Opcode60
    IF lt_mgdeam IS INITIAL.
      REFRESH lt_rfc_db_fld.

      ls_rfc_db_fld-fieldname = 'SERVICE_ID'.
      APPEND ls_rfc_db_fld TO lt_rfc_db_fld.

      ls_rfc_db_fld-fieldname = 'USER_ROLE'.
      APPEND ls_rfc_db_fld TO lt_rfc_db_fld.

      ls_rfc_db_fld-fieldname = 'HOST_NAME'.
      APPEND ls_rfc_db_fld TO lt_rfc_db_fld.

      ls_rfc_db_fld-fieldname = 'SYSTEM_ALIAS'.
      APPEND ls_rfc_db_fld TO lt_rfc_db_fld.

      ls_rfc_db_fld-fieldname = 'IS_DEFAULT'.
      APPEND ls_rfc_db_fld TO lt_rfc_db_fld.

      CALL FUNCTION 'RFC_READ_TABLE' DESTINATION i_dest_name
        EXPORTING
          query_table          = '/IWFND/C_MGDEAM'
*         DELIMITER            = ' '
*         NO_DATA              = ' '
*         ROWSKIPS             = 0
*         ROWCOUNT             = 0
        TABLES
*         options              =
          fields               = lt_rfc_db_fld
          data                 = lt_mgdeam
        EXCEPTIONS
          table_not_available  = 1
          table_without_data   = 2
          option_not_valid     = 3
          field_not_valid      = 4
          not_authorized       = 5
          data_buffer_exceeded = 6
*         OTHERS               = 7
        .
      IF lt_mgdeam IS NOT INITIAL.
*               SORT lo_cl_odata->lt_class BY service_name group_version.
        SORT lt_class1 BY service_name group_version.

*        CLEAR : lv_serv_version.
*        READ TABLE lo_cl_odata->lt_class INTO lo_cl_odata->ls_class WITH KEY
*                                                 service_name = lv_serv.
*        IF sy-subrc = 0.
*          CONCATENATE lv_serv lo_cl_odata->ls_class-group_version INTO lv_serv_version
*           SEPARATED BY '_'.
*        ENDIF.

        LOOP AT lt_class1 INTO ls_class WHERE
                                                 service_name = lv_serv.
          CLEAR : lv_serv_version.

          CONCATENATE lv_serv ls_class-group_version INTO lv_serv_version
           SEPARATED BY '_'.

*        READ TABLE lt_mgdeam INTO ls_mgdeam WITH KEY service_id = lv_serv.
*        READ TABLE lt_mgdeam INTO ls_mgdeam WITH KEY service_id = lv_serv_version.
*
*        IF sy-subrc EQ 0.
*          IF ls_mgdeam-is_default IS INITIAL OR ls_mgdeam-system_alias IS INITIAL.
*            "Append Final table
*            lwa_final-obj_name = lv_serv.
*            lwa_final-sub_program = i_class_name.
*            lwa_final-prog     =  i_class_name.
*            lwa_final-drill    = gv_drill.
*            lwa_final-opercd   = '60'.   "Operation Code
*            lwa_final-objtyp  = 'IWSV'.
**  Begin of changes by Akshay for Def_35
**                lwa_final-odata   = 'A'.
*            lwa_final-odata   = lv_odata.
**  End of changes by Akshay for Def_35
*            PERFORM append_final USING lwa_final.
*            CLEAR lwa_final.
*          ENDIF.
*        ELSE.
*          "Append Final table
*          lwa_final-obj_name = lv_serv.
*          lwa_final-sub_program = i_class_name.
*          lwa_final-prog     =  i_class_name.
*          lwa_final-drill    = gv_drill.
*          lwa_final-opercd   = '60'.   "Operation Code
*          lwa_final-objtyp  = 'IWSV'.
**  Begin of changes by Akshay for Def_35
**                lwa_final-odata   = 'A'.
*          lwa_final-odata   = lv_odata.
**  End of changes by Akshay for Def_35
*          PERFORM append_final USING lwa_final.
*          CLEAR lwa_final.
*        ENDIF.
*      ENDIF.

          READ TABLE lt_mgdeam INTO ls_mgdeam WITH KEY service_id = lv_serv_version.
          IF sy-subrc EQ 0.
            IF ls_mgdeam-is_default IS INITIAL OR ls_mgdeam-system_alias IS INITIAL.
              "Append Final table
              lwa_final-obj_name = lv_serv_version.
              lwa_final-sub_program = lv_class.
              lwa_final-prog     =  lv_class.
*                  lwa_final-drill    = gv_drill.
              lwa_final-opercd   = '60'.   "Operation Code
              lwa_final-objtyp  = 'IWSV'.
*  Begin of changes by Akshay for Def_35
*                lwa_final-odata   = 'A'.
              lwa_final-odata   = lv_odata.
*  End of changes by Akshay for Def_35
*                  PERFORM append_final USING lwa_final.
              APPEND lwa_final TO lt_final1.
              CLEAR lwa_final.
            ENDIF.
          ELSE.
            "Append Final table
            lwa_final-obj_name = lv_serv_version.
            lwa_final-sub_program = lv_class.
            lwa_final-prog     =  lv_class.
*                lwa_final-drill    = gv_drill.
            lwa_final-opercd   = '60'.   "Operation Code
            lwa_final-objtyp  = 'IWSV'.
*  Begin of changes by Akshay for Def_35
*                lwa_final-odata   = 'A'.
            lwa_final-odata   = lv_odata.
*  End of changes by Akshay for Def_35
            APPEND lwa_final TO lt_final1.
*                PERFORM append_final USING lwa_final.
            CLEAR lwa_final.
          ENDIF.
        ENDLOOP.
      ELSE.
        "read buffer for opcode60

        SORT lt_class1 BY service_name group_version.

        LOOP AT lt_class1 INTO ls_class WHERE
                                                              service_name = lv_serv.
          CLEAR : lv_serv_version.

          CONCATENATE lv_serv ls_class-group_version INTO lv_serv_version
           SEPARATED BY '_'.

*      CLEAR : lv_serv_version.
*      READ TABLE lo_cl_odata->lt_class INTO lo_cl_odata->ls_class WITH KEY
*                                               service_name = lv_serv.
*      IF sy-subrc = 0.
*        CONCATENATE lv_serv lo_cl_odata->ls_class-group_version INTO lv_serv_version
*         SEPARATED BY '_'.
*      ENDIF.


*      READ TABLE lt_mgdeam INTO ls_mgdeam WITH KEY service_id = lv_serv.
*      READ TABLE lt_mgdeam INTO ls_mgdeam WITH KEY service_id = lv_serv_version.
*
*      IF sy-subrc EQ 0.
*        IF ls_mgdeam-is_default IS INITIAL OR ls_mgdeam-system_alias IS INITIAL.
*          "Append Final table
*          lwa_final-obj_name = lv_serv.
*          lwa_final-sub_program = i_class_name.
*          lwa_final-prog     =  i_class_name.
*          lwa_final-drill    = gv_drill.
*          lwa_final-opercd   = '60'.   "Operation Code
*          lwa_final-objtyp  = 'IWSV'.
**  Begin of changes by Akshay for Def_35
**                lwa_final-odata   = 'A'.
*          lwa_final-odata   = lv_odata.
**  End of changes by Akshay for Def_35
*          PERFORM append_final USING lwa_final.
*          CLEAR lwa_final.
*        ENDIF.
*      ELSE.
*        "Append Final table
*        lwa_final-obj_name = lv_serv.
*        lwa_final-sub_program = i_class_name.
*        lwa_final-prog     =  i_class_name.
*        lwa_final-drill    = gv_drill.
*        lwa_final-opercd   = '60'.   "Operation Code
*        lwa_final-objtyp  = 'IWSV'.
**  Begin of changes by Akshay for Def_35
**                lwa_final-odata   = 'A'.
*        lwa_final-odata   = lv_odata.
**  End of changes by Akshay for Def_35
*        PERFORM append_final USING lwa_final.
*        CLEAR lwa_final.

          READ TABLE lt_mgdeam INTO ls_mgdeam WITH KEY service_id = lv_serv_version.

          IF sy-subrc EQ 0.
            IF ls_mgdeam-is_default IS INITIAL OR ls_mgdeam-system_alias IS INITIAL.
              "Append Final table
              lwa_final-obj_name = lv_serv_version.
              lwa_final-sub_program = lv_class.
              lwa_final-prog     =  lv_class.
*                  lwa_final-drill    = gv_drill.
              lwa_final-opercd   = '60'.   "Operation Code
              lwa_final-objtyp  = 'IWSV'.
*  Begin of changes by Akshay for Def_35
*                lwa_final-odata   = 'A'.
              lwa_final-odata   = lv_odata.
*  End of changes by Akshay for Def_35
              APPEND lwa_final TO lt_final1.
*                  PERFORM append_final USING lwa_final.
              CLEAR lwa_final.
            ENDIF.
          ELSE.
            "Append Final table
            lwa_final-obj_name = lv_serv_version.
            lwa_final-sub_program = lv_class.
            lwa_final-prog     =  lv_class.
*                lwa_final-drill    = gv_drill.
            lwa_final-opercd   = '60'.   "Operation Code
            lwa_final-objtyp  = 'IWSV'.
*  Begin of changes by Akshay for Def_35
*                lwa_final-odata   = 'A'.
            lwa_final-odata   = lv_odata.
*  End of changes by Akshay for Def_35
            APPEND lwa_final TO lt_final1.
*                PERFORM append_final USING lwa_final.
            CLEAR lwa_final.
          ENDIF.

        ENDLOOP.

      ENDIF.
    ENDIF.




    "Opcode61
    IF lt_passwd IS INITIAL.
      REFRESH lt_rfc_db_fld.

      ls_rfc_db_fld-fieldname = 'ICF_NAME'.
      APPEND ls_rfc_db_fld TO lt_rfc_db_fld.

      ls_rfc_db_fld-fieldname = 'ICFPARGUID'.
      APPEND ls_rfc_db_fld TO lt_rfc_db_fld.

      ls_rfc_db_fld-fieldname = 'ICFNODGUID'.
      APPEND ls_rfc_db_fld TO lt_rfc_db_fld.

      ls_rfc_db_fld-fieldname = 'ICF_USER'.
      APPEND ls_rfc_db_fld TO lt_rfc_db_fld.

      ls_rfc_db_fld-fieldname = 'ICF_PASSWD'.
      APPEND ls_rfc_db_fld TO lt_rfc_db_fld.

      CALL FUNCTION 'RFC_READ_TABLE' DESTINATION i_dest_name
        EXPORTING
          query_table          = 'ICFSECPASSWD'
*         DELIMITER            = ' '
*         NO_DATA              = ' '
*         ROWSKIPS             = 0
*         ROWCOUNT             = 0
        TABLES
*         options              =
          fields               = lt_rfc_db_fld
          data                 = lt_passwd
        EXCEPTIONS
          table_not_available  = 1
          table_without_data   = 2
          option_not_valid     = 3
          field_not_valid      = 4
          not_authorized       = 5
          data_buffer_exceeded = 6
*         OTHERS               = 7
        .
      IF lt_passwd IS NOT INITIAL.

*        READ TABLE lt_passwd INTO ls_passwd WITH KEY icf_name = lo_cl_odata->ls_med-service_name.
        READ TABLE lt_passwd INTO ls_passwd WITH KEY icf_name = lv_icf_name.
        IF sy-subrc EQ 0.

          SORT lt_class1 BY service_name group_version.

          CLEAR : lv_serv_version.
          READ TABLE lt_class1 INTO ls_class WITH KEY
                                                   service_name = lv_serv..
          IF sy-subrc = 0.
            CONCATENATE lv_serv ls_class-group_version INTO lv_serv_version
             SEPARATED BY '_'.
          ENDIF.

*              IF ls_passwd-icf_passwd IS INITIAL.
          "Append Final table
*          lwa_final-obj_name = lv_serv.
          lwa_final-obj_name = lv_serv_version.
          lwa_final-sub_program = lv_class.
          lwa_final-prog     =  lv_class.
*              lwa_final-drill    = gv_drill.
          lwa_final-opercd   = '61'.   "Operation Code
          lwa_final-objtyp  = 'IWSV'.
*  Begin of changes by Akshay for Def_35
*                lwa_final-odata   = 'A'.
          lwa_final-odata   = lv_odata.
*  End of changes by Akshay for Def_35
*              PERFORM append_final USING lwa_final.
          APPEND lwa_final TO lt_final1.
          CLEAR lwa_final.
*              ENDIF.
        ELSE.
          "Append Final table
*              lwa_final-obj_name = lo_cl_odata->ls_med-service_name.
*              lwa_final-sub_program = i_class_name.
*              lwa_final-prog     =  i_class_name.
*              lwa_final-drill    = gv_drill.
*              lwa_final-opercd   = '61'.   "Operation Code
*              lwa_final-objtyp  = 'IWSV'.
*              PERFORM append_final USING lwa_final.
*              CLEAR lwa_final.
        ENDIF.
      ENDIF.
*        ENDIF.
    ELSEIF lt_passwd IS NOT INITIAL.

*      READ TABLE lt_passwd INTO ls_passwd WITH KEY icf_name = lo_cl_odata->ls_med-service_name.
      READ TABLE lt_passwd INTO ls_passwd WITH KEY icf_name = lv_icf_name.

      IF sy-subrc EQ 0.

        SORT lt_class1 BY service_name group_version.

        CLEAR : lv_serv_version.
        READ TABLE lt_class1 INTO ls_class WITH KEY
                                                 service_name = lv_serv..
        IF sy-subrc = 0.
          CONCATENATE lv_serv ls_class-group_version INTO lv_serv_version
           SEPARATED BY '_'.
        ENDIF.

        "Append Final table
*        lwa_final-obj_name = lv_serv.
        lwa_final-obj_name = lv_serv_version.
        lwa_final-sub_program = lv_class.
        lwa_final-prog     =  lv_class.
*            lwa_final-drill    = gv_drill.
        lwa_final-opercd   = '61'.   "Operation Code
        lwa_final-objtyp  = 'IWSV'.
*  Begin of changes by Akshay for Def_35
*                lwa_final-odata   = 'A'.
        lwa_final-odata   = lv_odata.
*  End of changes by Akshay for Def_35
        APPEND lwa_final TO lt_final1.
*            PERFORM append_final USING lwa_final.
        CLEAR lwa_final.
      ELSE.
        "Append Final table
*          lwa_final-obj_name = lo_cl_odata->ls_med-service_name.
*          lwa_final-sub_program = i_class_name.
*          lwa_final-prog     =  i_class_name.
*          lwa_final-drill    = gv_drill.
*          lwa_final-opercd   = '61'.   "Operation Code
*          lwa_final-objtyp  = 'IWSV'.
*          PERFORM append_final USING lwa_final.
*          CLEAR lwa_final.
*        ENDIF.
      ENDIF.
    ENDIF.

    IF lt_final1 IS NOT INITIAL.
      SORT lt_final1 BY obj_name opercd.

      DELETE ADJACENT DUPLICATES FROM lt_final1 COMPARING obj_name opercd.
    ENDIF.



  ENDMETHOD.


  METHOD zhana_interface_odata~is_valid_odata_class.

    TYPES : BEGIN OF ty_l_srh,
              technical_name TYPE char35, "/iwbep/med_grp_technical_name,
              version(4)     TYPE n, "/iwbep/med_grp_version,
              class_name     TYPE char30, "/iwbep/med_runtime_service,
            END OF ty_l_srh.
    TYPES : BEGIN OF ty_l_srg,
              group_tech_name  TYPE char35, "/iwbep/med_grp_technical_name,
              group_version(4) TYPE n, "/iwbep/med_grp_version,
              model_tech_name  TYPE char32, "/iwbep/med_mdl_technical_name,
              model_version(4) TYPE n, "/iwbep/med_mdl_version,
            END OF ty_l_srg.
    TYPES : BEGIN OF ty_ohd,
              technical_name TYPE char32, "/iwbep/med_mdl_technical_name,
              version(4)     TYPE n, "/iwbep/med_mdl_version,
              class_name     TYPE char4, "/iwbep/med_mdl_version,
            END OF ty_ohd.

    TYPES : BEGIN OF ty_sin,
              srv_identifier TYPE char40, "/iwfnd/med_mdl_srg_identifier,
              name           TYPE char30, "/iwfnd/med_mdl_info_name,
              value          TYPE char120, "/iwfnd/med_mdl_info_value,
            END OF ty_sin.

    TYPES : BEGIN OF ty_seo,
              clsname    TYPE  seoclsname,
              refclsname TYPE seoclsname,
              reltype    TYPE seoreltype,
            END OF ty_seo.

    TYPES : BEGIN OF ty_class,
              class_name         TYPE char30, "/iwbep/med_runtime_service,
              external_name      TYPE char40, "/iwbep/med_grp_external_name,
              service_name       TYPE char35, "/iwbep/med_grp_technical_name,
              group_version(4)   TYPE  n, "/iwbep/med_grp_version,   "Added by Akshay_Def_24
              service_version(4) TYPE n, "/iwbep/med_grp_version,   "Added by Akshay_Def_24
              dpc_class          TYPE char30, "/iwbep/med_runtime_service,
              dpc_ext_class      TYPE char30, "/iwbep/med_runtime_service,
              mpc_class          TYPE char30, "/iwbep/med_runtime_service,
              mpc_ext_class      TYPE char30, "/iwbep/med_runtime_service,
              odata              TYPE wdy_boolean,
            END OF ty_class.

    DATA : lt_srh     TYPE STANDARD TABLE OF ty_l_srh,
           ls_srh     TYPE ty_l_srh,
           lt_srg     TYPE STANDARD TABLE OF ty_l_srg,
           ls_srg     TYPE ty_l_srg,
           lt_ohd     TYPE STANDARD TABLE OF ty_ohd,
           ls_ohd     TYPE ty_ohd,
           lt_mpc_ext TYPE STANDARD TABLE OF ty_l_srh,
           ls_mpc_ext TYPE ty_l_srh,
*           lt_class   TYPE STANDARD TABLE OF ty_class,
           ls_class   TYPE ty_class
           .

    DATA : lt_rfc_db_fld TYPE STANDARD TABLE OF rfc_db_fld,
           ls_rfc_db_fld TYPE rfc_db_fld,
           lt_sin        TYPE STANDARD TABLE OF ty_sin,
           ls_sin        TYPE ty_sin,
           lt_data       TYPE STANDARD TABLE OF tab512,
           ls_data       TYPE tab512,
           lt_all        TYPE STANDARD TABLE OF ty_l_srh,
           lt_opt        TYPE STANDARD TABLE OF rfc_db_opt,
           lt_seo        TYPE STANDARD TABLE OF ty_seo,
           ls_seo        TYPE ty_seo.

    CONSTANTS : lv_tab_name  TYPE seoclsname VALUE '/IWFND/I_MED_SIN'.

    CLEAR : ls_srh,ls_srg,ls_ohd.
    REFRESH : lt_srh,lt_srg,lt_ohd,lt_mpc_ext.

    SELECT technical_name "Service name "Get DPC ext classes
           version
               class_name
    FROM /iwbep/i_mgw_srh INTO TABLE lt_srh WHERE class_name LIKE 'Z%' OR class_name LIKE 'Y%'.
    IF sy-subrc EQ 0.
      SELECT group_tech_name " Get Model name
               group_version
             model_tech_name
              model_version
        FROM /iwbep/i_mgw_srg INTO TABLE lt_srg FOR ALL ENTRIES IN lt_srh WHERE group_tech_name = lt_srh-technical_name
                                                                            AND group_version = lt_srh-version.
      IF sy-subrc EQ 0.
        SELECT technical_name "Get associated MPC Ext. class
             version
               class_name
          FROM /iwbep/i_mgw_ohd INTO TABLE lt_mpc_ext FOR ALL ENTRIES IN lt_srg WHERE technical_name  =  lt_srg-model_tech_name
                                                                                  AND version = lt_srg-model_version.
        IF sy-subrc EQ 0.
          "create one table for DPC ext. and MPC ext.
          APPEND LINES OF lt_srh TO lt_all.
          APPEND LINES OF lt_mpc_ext  TO lt_all.

          SELECT  clsname " get DPC and MPC classes
                  refclsname
            FROM seometarel INTO TABLE lt_seo FOR ALL ENTRIES IN lt_all WHERE clsname = lt_all-class_name
                                                                          AND reltype  = '2'
                                                                          AND refclsname LIKE 'Z%' OR refclsname LIKE 'Y%'.
          IF sy-subrc EQ 0.

            REFRESH lt_rfc_db_fld.

            ls_rfc_db_fld-fieldname = 'SRV_IDENTIFIER'.
            APPEND ls_rfc_db_fld TO lt_rfc_db_fld.

            ls_rfc_db_fld-fieldname = 'NAME'.
            APPEND ls_rfc_db_fld TO lt_rfc_db_fld.

            ls_rfc_db_fld-fieldname = 'VALUE'.
            APPEND ls_rfc_db_fld TO lt_rfc_db_fld.

            CALL FUNCTION 'RFC_READ_TABLE' DESTINATION i_dest_name
              EXPORTING
                query_table          = lv_tab_name
                delimiter            = ';'
*               NO_DATA              = ' '
*               ROWSKIPS             = 0
*               ROWCOUNT             = 0
              TABLES
                options              = lt_opt
                fields               = lt_rfc_db_fld
                data                 = lt_data
              EXCEPTIONS
                table_not_available  = 1
                table_without_data   = 2
                option_not_valid     = 3
                field_not_valid      = 4
                not_authorized       = 5
                data_buffer_exceeded = 6
                OTHERS               = 7.
            IF sy-subrc <> 0.
* Implement suitable error handling here
            ELSE.
              "Split and append records
              LOOP AT lt_data INTO ls_data.
                SPLIT ls_data AT ';' INTO ls_sin-name ls_sin-srv_identifier ls_sin-value.
                APPEND ls_sin TO lt_sin.
              ENDLOOP.
              "
              LOOP AT lt_srh INTO ls_srh. " service header
                READ TABLE lt_srg INTO ls_srg WITH KEY group_tech_name  = ls_srh-technical_name " get model name
                                                        group_version = ls_srh-version.
                IF sy-subrc EQ 0.
                  READ TABLE lt_mpc_ext INTO ls_mpc_ext WITH KEY technical_name = ls_srg-model_tech_name
                                                                    version = ls_srg-model_version .
                  IF sy-subrc EQ 0.
*                    READ TABLE lt_seo INTO ls_seo WITH KEY clsname  = ls_srh-class_name.
*                    IF sy-subrc EQ 0.
                    ls_class-dpc_ext_class  = ls_srh-class_name.
                    ls_class-mpc_ext_class  = ls_mpc_ext-class_name.
                    ls_class-service_name   = ls_srh-technical_name.
                    ls_class-service_version   = ls_srh-version.
                    ls_class-group_version = ls_srg-group_version.


                    READ TABLE lt_seo INTO ls_seo WITH KEY clsname  = ls_class-dpc_ext_class.
                    IF sy-subrc EQ 0.
                      ls_class-dpc_class      =  ls_seo-refclsname.
                    ENDIF.

                    READ TABLE lt_seo INTO ls_seo WITH KEY clsname  = ls_class-mpc_ext_class.
                    IF sy-subrc EQ 0.
                      ls_class-mpc_class      =  ls_seo-refclsname.
                    ENDIF.

                    READ TABLE lt_sin INTO ls_sin WITH KEY  srv_identifier = 'BEP_SVC_EXT_SERVICE_NAME' " DPC & mpc ext classes
                                                            value = ls_srh-technical_name.
                    IF sy-subrc EQ 0.
                      ls_class-odata  = 'A'.
                    ELSE.
                      ls_class-odata  = 'I'.
                    ENDIF.
                    APPEND ls_class TO lt_class.
*                    ENDIF.
                  ENDIF.
                ENDIF.
              ENDLOOP.
            ENDIF.
          ENDIF.
        ENDIF.
      ENDIF.
    ENDIF.

  ENDMETHOD.
ENDCLASS.
