*&---------------------------------------------------------------------*
*& Report ZHANA_DETECTION_V77_08052016
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ztest_am1.


Select * FROM bseg INto TABLE @DATA(i_beg) UP TO 5 ROWS.
Select * FROM FCLM_BSEG_BASIC INto TABLE @DATA(i_besg) UP TO 5 ROWS.
  IF  sy-subrc = 0.
   WRITE 'jeba'.
  ENDIF.
*" Constant to maintain version of the HANA Detection tool
*{ Begin of change by Rohit - 28/12/2016
CONSTANTS: gc_version(5) TYPE c VALUE '7.9'.
*} End of change by Rohit - 28/12/2016
*&---------------------------------------------------------------------*
*& Report  ZDB_ANALYSIS_V74_MS
*&
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*

*REPORT ZDB_ANALYSIS_V74_ms.
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Report  ZAK_PRO_AXA
*& Corrected issues:
*& 1. Error code: 99 - table size: should be removed before delivering
* report to client
*& 2. REPLACE SORT by ORDERBY : error now falls in degradation rather
* than mandatory
*& 3. Error @ FAE where trans|cluster was detected incorrectly is now
* resolved
*& 4. Error @ undetected pool cluster resolved for field with fields
*& 5. Generated program(s) removed from detection logic
*& 6. Incorrect include name now corrected
*& 7. resolved issue when loop and endloop/endo/endwhile appear in
*same line.@ angry bird issue
*& 8. Logic for SORT removed - i.e. replace SORT with ORDER BY
*statement removed completely
*&    as we believe this is not SAP recommendation
*& 9. DELETE ADJUSTANT DUPLICATES + READ TABLE with BINARY w/o SORT
* statement filtered based on
*&    whether internal table is SORTED before.
*& 10. TYPE SORTED TABLE OF now included in gt_SORT
*&---------------------------------------------------------------------*
*& corrected SORT issue -- though logic should be changed in next delta
* release
*&  get_sel_star changed from CHANGING TO TABLE
*&   % usage of field should be revisited as in few cases percentage
*goes beyond 100..
*& currently such cases are commented
*&---------------------------------------------------------------------*


*-----------------------------------------------------------------
*TOP INCLUDE
*-----------------------------------------------------------------
*include zupg_hpc_top_merged06oct_mod.
**include zupg_hpc_top_merged06oct. " for namespace changes merger -
*default
*&---------------------------------------------------------------------*
*&  Include           ZUPG_HPC_TOP_MERGED06OCT
*&---------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*&  Include           ZUPG_HPC_TOP
*&---------------------------------------------------------------------*


*----------------------------------------------------------
*  TYPE POOLS
*----------------------------------------------------------
TYPE-POOLS: slis , seop.
TABLES dd02l. " added by rohit-12/10/2015
TABLES : dd02d,
         vers_dest."begin of changes for Odata_def_24.
*----------------------------------------------------------
*  TYPES DECLEARTION
*----------------------------------------------------------
TYPES: BEGIN OF ty_code,
         text(1000) TYPE c,
       END OF ty_code,

       BEGIN OF ty_tab,
         progname TYPE sobj_name,
         table    TYPE tabname,
         count    TYPE i,
         line     TYPE i,
         join(6)  TYPE c,
       END OF ty_tab,

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
         corr        TYPE c,
         where_con   TYPE string,
         keys        TYPE string,
         delflg      TYPE c,
* Begin of change by Twara 12/02/2016 to get line number of SELECT
         select_line TYPE string,
* End of change by Twara 12/02/2016 to get line number of SELECT
         "begin of code change for Odata_def_24
         odata       TYPE c,
         sub_program TYPE char40,
         "end of code change for Odata_def_24
       END OF ty_final,

       BEGIN OF ty_intab,
         progname       TYPE sobj_name,
         table          TYPE tabname,
         intab          TYPE sobj_name,
         line           TYPE char6, " ashish 24 OCT chnaged from char4
         fieldcount(10) TYPE c,
       END OF ty_intab,

       BEGIN OF ty_final1,
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
         type        TYPE char20,
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
         corr        TYPE c,
         where_con   TYPE string,
         keys        TYPE string,
         delflg      TYPE c,
* Begin of change by Twara 12/02/2016 to get line number of SELECT
         select_line TYPE string,
         odata       TYPE c, "begin of change for Odata_def_24
* End of change by Twara 12/02/2016 to get line number of SELECT
       END OF ty_final1,

       BEGIN OF ty_wa,
         progname TYPE sobj_name,
         intab    TYPE sobj_name,
         wa       TYPE string,
       END OF ty_wa,

       BEGIN OF ty_wa_row,
         progname       TYPE sobj_name,
         intab          TYPE sobj_name,
         wa             TYPE string,
         fieldname      TYPE fieldname,
         fieldcount(10) TYPE c,
       END OF ty_wa_row,

       BEGIN OF ty_sourcetab,
         line(400) TYPE c,
       END OF ty_sourcetab,

       BEGIN OF ty_keywords,
         word(30) TYPE c,
       END OF ty_keywords,

       BEGIN OF ty_tadir,
         object   TYPE trobjtype,
         obj_name TYPE sobj_name,
       END OF ty_tadir,

       BEGIN OF ty_objname,
         objname TYPE sobj_name,
       END OF ty_objname,

       BEGIN OF ty_tables,
         objtyp   TYPE trobjtype,
         progname TYPE progname,
         mainprog TYPE progname,
         include  TYPE seocpdname,
         odata    TYPE char1, " begin of change for Odata_def_24
       END OF ty_tables,

       BEGIN OF ty_ldb,
         progname TYPE progname,
         ldbname  TYPE trdir-ldbname,
       END OF ty_ldb,

       BEGIN OF ty_select,
         line  TYPE i,
         drill TYPE i,
       END OF ty_select,

       BEGIN OF ty_form,
         obj_name   TYPE sobj_name,
         form(1000) TYPE c,
         line       TYPE sy-tabix,
         done       TYPE c,
         text(1000) TYPE c,
       END OF ty_form,

       BEGIN OF ty_formlvl,
         obj_name TYPE sobj_name,
         form     TYPE string,
         level    TYPE sy-tabix,
       END OF ty_formlvl,

       BEGIN OF ty_include,
         obj_name TYPE sobj_name,
         incl     TYPE sobj_name,
         line     TYPE sy-tabix,
       END OF ty_include.

TYPES: BEGIN OF type_check,
         otype   TYPE char2,
         name    TYPE tabname,
         include TYPE char40,
       END OF type_check,

       BEGIN OF table_check,
         tabname TYPE char30,
       END OF table_check,

       BEGIN OF main_prog,
         progname TYPE progname,
       END OF main_prog.

TYPES: BEGIN OF ty_checks,
         opercd      TYPE i,
         operation   TYPE string,
         check       TYPE string,
         act_st      TYPE string,
         subcategory TYPE string,
         critical    TYPE string,
       END OF ty_checks.

TYPES: BEGIN OF ty_fields,
         tabname   TYPE tabname,
         fieldname TYPE fieldname,
       END OF ty_fields.

TYPES: BEGIN OF ty_scan,
         p_name  TYPE c LENGTH 60,
         line_no TYPE n LENGTH 8, "  LENGTH 8,
         code    TYPE c LENGTH 1000,
       END OF ty_scan.

TYPES: BEGIN OF ty_dd02l_pc,
         sqltab   TYPE dd02l-sqltab,
         tabclass TYPE dd02l-tabclass,
       END OF ty_dd02l_pc.

TYPES: BEGIN OF ty_dd02l,
         tabname  TYPE dd02l-tabname,
         tabclass TYPE dd02l-tabclass,
       END OF ty_dd02l,

* Begin of changes by Akshay for OData_Def_24
       BEGIN OF ty_mgdeam,
         service_id   TYPE /iwfnd/med_mdl_srg_identifier,
         user_role    TYPE /iwfnd/defi_role_name,
         host_name    TYPE /iwfnd/mgw_inma_host_name,
         system_alias TYPE /iwfnd/defi_system_alias,
         is_default   TYPE /iwfnd/mgw_inma_default_alias,
       END OF ty_mgdeam .
* End of changes by Akshay for OData_Def_24

*----------------------------------------------------------
*  CONSTANTS
*----------------------------------------------------------
CONSTANTS:
  gc_select              TYPE char6     VALUE 'SELECT',
  gc_select_str(8)       TYPE c         VALUE 'SELECT *',
  gc_select_sing(13)     TYPE c         VALUE 'SELECT SINGLE',
  gc_select_sing_str(15) TYPE c         VALUE 'SELECT SINGLE *',
  gc_sel_sing_updt(26)   TYPE c         VALUE
                           'SELECT SINGLE FOR UPDATE *',
  gc_del_adj_dup(26)     TYPE c         VALUE
                           'DELETE ADJACENT DUPLICATES',
  gc_join_spc(6)         TYPE c         VALUE ' JOIN ',
  gc_join(4)             TYPE c         VALUE 'JOIN',
  gc_inner(5)            TYPE c         VALUE 'INNER',
  gc_left(4)             TYPE c         VALUE 'LEFT',
  gc_right(5)            TYPE c         VALUE 'RIGHT',
  gc_outer(5)            TYPE c         VALUE 'OUTER',
  gc_rig_out_join(16)    TYPE c         VALUE 'RIGHT OUTER JOIN',
  gc_lef_out_join(15)    TYPE c         VALUE 'LEFT OUTER JOIN',
  gc_out_join(10)        TYPE c         VALUE 'OUTER JOIN',
  gc_in_join(10)         TYPE c         VALUE 'INNER JOIN',
  gc_op_cursor(11)       TYPE c         VALUE 'OPEN CURSOR',
  gc_cursor(6)           TYPE c         VALUE 'CURSOR',
  gc_mandt               TYPE fieldname VALUE 'MANDT',
  gc_loop                TYPE char4     VALUE 'LOOP',
  gc_endloop             TYPE char7     VALUE 'ENDLOOP',
  gc_form(4)             TYPE c         VALUE 'FORM',
  gc_form_spc(5)         TYPE c         VALUE 'FORM ',
  gc_endform(7)          TYPE c         VALUE 'ENDFORM',
  gc_using(5)            TYPE c         VALUE 'USING',
  gc_changing(8)         TYPE c         VALUE 'CHANGING',
  gc_endselect           TYPE char9     VALUE 'ENDSELECT',
  gc_do                  TYPE char2     VALUE 'DO',
  gc_do_dot(3)           TYPE c         VALUE 'DO.',
  gc_ne(2)               TYPE c         VALUE 'NE',
  gc_ne_spc(3)           TYPE c         VALUE ' NE',
  gc_not_eq(2)           TYPE c         VALUE '<>',
  gc_not_spc(4)          TYPE c         VALUE ' NOT',
  gc_enddo               TYPE char5     VALUE 'ENDDO',
  gc_while(5)            TYPE c         VALUE 'WHILE',
  gc_endwhile(8)         TYPE c         VALUE 'ENDWHILE',
  gc_insert              TYPE char6     VALUE 'INSERT',
  gc_delete              TYPE char6     VALUE 'DELETE',
  gc_update              TYPE char6     VALUE 'UPDATE',
  gc_sort                TYPE char4     VALUE 'SORT',
  gc_move(4)             TYPE c         VALUE 'MOVE',
  gc_include             TYPE char7     VALUE 'INCLUDE',
  gc_include_typ(12)     TYPE c         VALUE 'INCLUDE TYPE',
  gc_iclude_struc(17)    TYPE c         VALUE 'INCLUDE STRUCTURE',
  gc_perform             TYPE char7     VALUE 'PERFORM',
  gc_error(255)          TYPE c         VALUE
                           'There is some issue in code.Please check!!!',
  gc_two(2)              TYPE c         VALUE '2',
  gc_x1x1(4)             TYPE c         VALUE 'X1X1',
  gc_curr(8)             TYPE c         VALUE 'CURRENCY',
  gc_collect(7)          TYPE c         VALUE 'COLLECT',
  gc_define(6)           TYPE c         VALUE 'DEFINE',
  gc_distinct(8)         TYPE c         VALUE 'DISTINCT',
  gc_table(5)            TYPE c         VALUE 'TABLE',
  gc_tables(6)           TYPE c         VALUE 'TABLES',
  gc_end_of_def(17)      TYPE c         VALUE 'END-OF-DEFINITION',
  gc_modify_line(11)     TYPE c         VALUE 'MODIFY LINE',
  gc_modify_screen(13)   TYPE c         VALUE 'MODIFY SCREEN',
  gc_high(4)             TYPE c         VALUE 'HIGH',
  gc_medium(6)           TYPE c         VALUE 'MEDIUM',
  gc_low(3)              TYPE c         VALUE 'LOW',
  gc_check(5)            TYPE c         VALUE 'CHECK',
  gc_exit(4)             TYPE c         VALUE 'EXIT',
  gc_bapi(4)             TYPE c         VALUE 'BAPI',
  gc_at_new(6)           TYPE c         VALUE 'AT NEW',
  gc_at_first(8)         TYPE c         VALUE 'AT FIRST',
  gc_at_endof(9)         TYPE c         VALUE 'AT END OF',
  gc_at_last(7)          TYPE c         VALUE 'AT LAST',
  gc_on_changeof(12)     TYPE c         VALUE 'ON CHANGE OF',
  gc_d$s(3)              TYPE c         VALUE 'D$S',
  gc_where(5)            TYPE c         VALUE 'WHERE',
  gc_where_spc(7)        TYPE c         VALUE ' WHERE ',
  gc_and(3)              TYPE c         VALUE 'AND',
  gc_or(2)               TYPE c         VALUE 'OR',
  gc_not(3)              TYPE c         VALUE 'NOT',
  gc_between(7)          TYPE c         VALUE 'BETWEEN',
  gc_values(6)           TYPE c         VALUE 'VALUES',
  gc_seperator           TYPE c         VALUE '|',
  gc_pool(4)             TYPE c         VALUE 'POOL',
  gc_cluster(7)          TYPE c         VALUE 'CLUSTER',
  gc_pool_sep(5)         TYPE c         VALUE '|POOL',
  gc_clus_sep(8)         TYPE c         VALUE '|CLUSTER',
  gc_transp(6)           TYPE c         VALUE 'TRANSP',
  gc_view(4)             TYPE c         VALUE 'VIEW',
  gc_delete_spc(7)       TYPE c         VALUE 'DELETE ',
  gc_update_spc(7)       TYPE c         VALUE 'UPDATE ',
  gc_insert_spc(7)       TYPE c         VALUE 'INSERT ',
  gc_insert_into_spc(12) TYPE c         VALUE 'INSERT INTO ',
  gc_modify_spc(7)       TYPE c         VALUE 'MODIFY ',
  gc_modify(6)           TYPE c         VALUE 'MODIFY',
  gc_select_spc(7)       TYPE c         VALUE 'SELECT ',
  gc_from_spc(6)         TYPE c         VALUE ' FROM ',
  gc_from(4)             TYPE c         VALUE 'FROM',
  gc_into(4)             TYPE c         VALUE 'INTO',
  gc_into_spc(6)         TYPE c         VALUE ' INTO ',
  gc_into_sp(5)          TYPE c         VALUE ' INTO',
  gc_into_tab_spc(12)    TYPE c         VALUE ' INTO TABLE ',
  gc_into_tab(10)        TYPE c         VALUE 'INTO TABLE',
  gc_app(9)              TYPE c         VALUE 'APPENDING',
  gc_app_spc(11)         TYPE c         VALUE ' APPENDING ',
  gc_app_tab_spc(17)     TYPE c         VALUE ' APPENDING TABLE ',
  gc_app_tab(15)         TYPE c         VALUE 'APPENDING TABLE',
  gc_del_from_spc(12)    TYPE c         VALUE 'DELETE FROM ',
  gc_from_tab_spc(12)    TYPE c         VALUE ' FROM TABLE ',
  gc_corr_field_of(28)   TYPE c         VALUE
                           'INTO CORRESPONDING FIELDS OF',
  gc_into_corr_spc(36)   TYPE c         VALUE
                           ' INTO CORRESPONDING FIELDS OF TABLE ',
  gc_into_corr(34)       TYPE c         VALUE
                           'INTO CORRESPONDING FIELDS OF TABLE',
  gc_app_corr_spc(41)    TYPE c         VALUE
                           ' APPENDING CORRESPONDING FIELDS OF TABLE ',
  gc_app_corr(39)        TYPE c         VALUE
                           'APPENDING CORRESPONDING FIELDS OF TABLE',
  gc_type_std_tab(22)    TYPE c         VALUE 'TYPE STANDARD TABLE OF',
  gc_like_std_tab(22)    TYPE c         VALUE 'LIKE STANDARD TABLE OF',
  gc_type_sort_tab(20)   TYPE c         VALUE 'TYPE SORTED TABLE OF',
  gc_like_sort_tab(20)   TYPE c         VALUE 'LIKE SORTED TABLE OF',
  gc_type_tab(13)        TYPE c         VALUE 'TYPE TABLE OF',
  gc_like_tab(13)        TYPE c         VALUE 'LIKE TABLE OF',
  gc_per_hint(7)         TYPE c         VALUE '%_HINTS',
  gc_pkg_size(12)        TYPE c         VALUE 'PACKAGE SIZE',
  gc_bypas_buff(16)      TYPE c         VALUE 'BYPASSING BUFFER',
  gc_for_all_ent(15)     TYPE c         VALUE 'FOR ALL ENTRIES',
  gc_for_all_ent_sp(16)  TYPE c         VALUE ' FOR ALL ENTRIES',
  gc_for_all_ent_spc(17) TYPE c         VALUE ' FOR ALL ENTRIES ',
  gc_for_all_ent_in(18)  TYPE c         VALUE 'FOR ALL ENTRIES IN',
  gc_grp_by(8)           TYPE c         VALUE 'GROUP BY',
  gc_ord_by(8)           TYPE c         VALUE 'ORDER BY',
  gc_ord_by_spc(9)       TYPE c         VALUE ' ORDER BY',
  gc_sort_spc(5)         TYPE c         VALUE 'SORT ',
  gc_read(4)             TYPE c         VALUE 'READ',
  gc_read_tab(10)        TYPE c         VALUE 'READ TABLE',
  gc_read_tab_spc(11)    TYPE c         VALUE 'READ TABLE ',
  gc_bin_search(13)      TYPE c         VALUE 'BINARY SEARCH',
  gc_index_spc(7)        TYPE c         VALUE ' INDEX ',
  gc_to_spc(4)           TYPE c         VALUE ' TO ',
  gc_loop_at_spc(8)      TYPE c         VALUE 'LOOP AT ',
  gc_loop_at(7)          TYPE c         VALUE 'LOOP AT',
  gc_type_ref_spc(13)    TYPE c         VALUE ' TYPE REF TO ',
  gc_type_ref(11)        TYPE c         VALUE 'TYPE REF TO',
  gc_create_obj_spc(14)  TYPE c         VALUE 'CREATE OBJECT ',
  gc_call_meth(11)       TYPE c         VALUE 'CALL METHOD',
  gc_adbc_cls1_spc(18)   TYPE c         VALUE ' CL_SQL_CONNECTION',
  gc_adbc_cls1(17)       TYPE c         VALUE 'CL_SQL_CONNECTION',
  gc_adbc_cls2_spc(17)   TYPE c         VALUE ' CL_SQL_STATEMENT',
  gc_adbc_cls2(16)       TYPE c         VALUE 'CL_SQL_STATEMENT',
  gc_adbc_cls3_spc(26)   TYPE c         VALUE
                           ' CL_SQL_PREPARED_STATEMENT',
  gc_adbc_cls3(25)       TYPE c         VALUE
                           'CL_SQL_PREPARED_STATEMENT',
  gc_adbc_cls4_spc(18)   TYPE c         VALUE ' CL_SQL_RESULT_SET',
  gc_adbc_cls4(17)       TYPE c         VALUE 'CL_SQL_RESULT_SET',
  gc_exec_sql(8)         TYPE c         VALUE 'EXEC SQL',
  gc_call_func(13)       TYPE c         VALUE 'CALL FUNCTION',
  gc_db_exist_ind(15)    TYPE c         VALUE 'DB_EXISTS_INDEX',
  gc_dd_ind_name(13)     TYPE c         VALUE 'DD_INDEX_NAME',
  gc_corr(13)            TYPE c         VALUE 'CORRESPONDING',
  gc_single(6)           TYPE c         VALUE 'SINGLE',
  gc_yes(3)              TYPE c         VALUE 'YES',
  gc_rad(3)              TYPE c         VALUE 'RAD',
  gc_max(3)              TYPE c         VALUE 'MAX',
  gc_min(3)              TYPE c         VALUE 'MIN',
  gc_avg(3)              TYPE c         VALUE 'AVG',
  gc_sum(3)              TYPE c         VALUE 'SUM',
  gc_count(5)            TYPE c         VALUE 'COUNT',
  gc_r3tr(4)             TYPE c         VALUE 'R3TR',
  gc_clas(4)             TYPE c         VALUE 'CLAS',
  gc_prog(4)             TYPE c         VALUE 'PROG',
  gc_fugr(4)             TYPE c         VALUE 'FUGR',
  gc_sapl(4)             TYPE c         VALUE 'SAPL',
  gc_saplz(5)            TYPE c         VALUE 'SAPLZ',
  gc_saply(5)            TYPE c         VALUE 'SAPLY',
  gc_sapmz(5)            TYPE c         VALUE 'SAPMZ',
  gc_sapmy(5)            TYPE c         VALUE 'SAPMY',
  gc_lz(2)               TYPE c         VALUE 'LZ',
  gc_ly(2)               TYPE c         VALUE 'LY',
  gc_mz(2)               TYPE c         VALUE 'MZ',
  gc_my(2)               TYPE c         VALUE 'MY',
  gc_mp9(3)              TYPE c         VALUE 'MP9',
  gc_z                   TYPE c         VALUE 'Z',
  gc_y                   TYPE c         VALUE 'Y',
  gc_x                   TYPE c         VALUE 'X',
  gc_a                   TYPE c         VALUE 'A',
  gc_f                   TYPE c         VALUE 'F',
  gc_r                   TYPE c         VALUE 'R',
  gc_i                   TYPE c         VALUE 'I',
  gc_zero                TYPE c         VALUE '0',
  gc_cp(2)               TYPE c         VALUE 'CP',
  gc_of(2)               TYPE c         VALUE 'OF',
  gc_on(2)               TYPE c         VALUE 'ON',
  gc_as(2)               TYPE c         VALUE 'AS',
  gc_to(2)               TYPE c         VALUE 'TO',
  gc_by(2)               TYPE c         VALUE 'BY',
  gc_open_bracket        TYPE c         VALUE '(',
  gc_close_bracket       TYPE c         VALUE ')',
  gc_op_bracket          TYPE c         VALUE '[',
  gc_dot                 TYPE c         VALUE '.',
  gc_comma               TYPE c         VALUE ',',
  gc_colon               TYPE c         VALUE ':',
  gc_star                TYPE c         VALUE '*',
  gc_for_slash           TYPE c         VALUE '/',
  gc_tilde               TYPE c         VALUE '~',
  gc_doub_quote          TYPE c         VALUE '"',
  gc_bracket(2)          TYPE c         VALUE '[]'.



CONSTANTS: gc_11(2) TYPE c     VALUE '11',
           gc_12(2) TYPE c     VALUE '12',
           gc_13(2) TYPE c     VALUE '13',
           gc_14(2) TYPE c     VALUE '14',
           gc_15(2) TYPE c     VALUE '15',
           gc_16(2) TYPE c     VALUE '16',
           gc_17(2) TYPE c     VALUE '17',
           gc_18(2) TYPE c     VALUE '18',
           gc_19(2) TYPE c     VALUE '19',
           gc_20(2) TYPE c     VALUE '20',
           gc_29(2) TYPE c     VALUE '29',
           gc_30(2) TYPE c     VALUE '30',
           gc_31(2) TYPE c     VALUE '31',
           gc_32(2) TYPE c     VALUE '32',
           gc_33(2) TYPE c     VALUE '33',
           gc_34(2) TYPE c     VALUE '34',
           gc_35(2) TYPE c     VALUE '35',
           gc_36(2) TYPE c     VALUE '36',
           gc_37(2) TYPE c     VALUE '37',
           gc_38(2) TYPE c     VALUE '38',
           gc_39(2) TYPE c     VALUE '39',
           gc_40(2) TYPE c     VALUE '40',
           gc_41(2) TYPE c     VALUE '41',
           gc_42(2) TYPE c     VALUE '42',
           gc_43(2) TYPE c     VALUE '43',
           gc_44(2) TYPE c     VALUE '44',
           gc_45(2) TYPE c     VALUE '45',
           gc_46(2) TYPE c     VALUE '46',
           gc_47(2) TYPE c     VALUE '47',
           gc_48(2) TYPE c     VALUE '48',
           gc_49(2) TYPE c     VALUE '49',
           gc_50(2) TYPE c     VALUE '50',
           gc_51(2) TYPE c     VALUE '51',
           gc_52(2) TYPE c     VALUE '52',
           gc_53(2) TYPE c     VALUE '53',
           gc_54(2) TYPE c     VALUE '54',
           gc_56(2) TYPE c     VALUE '56',
           gc_57(2) TYPE c     VALUE '57',
           gc_58(2) TYPE c     VALUE '58',
           "Begin of changes for Odata_def_25.
           gc_75(2) TYPE c VALUE '75',
           gc_76(2) TYPE c VALUE '76',
           "End of changes for Odata_def_25.
***********BOC Shreeda 1/05/2017************
           gc_77(2) TYPE c     VALUE '77',
           gc_78(2) TYPE c     VALUE '78',
           gc_79(2) TYPE c     VALUE '79',
***********EOC Shreeda 2/05/2017************
           gc_99(2) TYPE c     VALUE '99'.

*----------------------------------------------------------
*  RANGES
*----------------------------------------------------------
DATA: gr_where              TYPE RANGE OF master .
DATA: gr_nspace             TYPE RANGE OF char15. "namespace. Twara-12/02/2016  " 29OCT

*----------------------------------------------------------
*  INTERNAL TABLES
*----------------------------------------------------------
DATA: gt_ldb                TYPE TABLE OF ty_ldb,
      gt_code               TYPE TABLE OF ty_code,
      gt_incode             TYPE TABLE OF ty_code,
      gt_final              TYPE TABLE OF ty_final,
      gt_final99            TYPE TABLE OF ty_final,
      gt_finaln             TYPE TABLE OF ty_final1,
      gt_include            TYPE TABLE OF ty_tables,
      gt_include_cls        TYPE TABLE OF ty_tables,
      "begin of code change for Odata_def_24
      gt_include_odata      TYPE TABLE OF ty_tables,
      gs_include_odata      TYPE ty_tables,
      gs_include_cls        TYPE  ty_tables,
      lt_512                TYPE STANDARD TABLE OF icfservloc,
*      lt_mgdeam             TYPE STANDARD TABLE OF /iwfnd/c_mgdeam,
      lt_mgdeam             TYPE STANDARD TABLE OF ty_mgdeam,
*      ls_mgdeam             TYPE /iwfnd/c_mgdeam,
      ls_mgdeam             TYPE ty_mgdeam,
      lt_passwd             TYPE STANDARD TABLE OF icfsecpasswd,
      ls_passwd             TYPE icfsecpasswd,
      "end of code change for Odata_def_24
      gt_table              TYPE TABLE OF ty_tab,
      gt_intab              TYPE TABLE OF ty_intab,
      gt_select             TYPE TABLE OF ty_select,
      gt_fieldlist          TYPE TABLE OF rfieldlist,
      gt_incl_processed     TYPE TABLE OF ty_include,
      gt_form_processed     TYPE TABLE OF ty_form,
      gt_form_lvl_processed TYPE TABLE OF ty_formlvl,
      gt_f_code             TYPE TABLE OF ty_scan,
*      gt_f_code             type table of zcodetab,
      gt_dd02l              TYPE TABLE OF table_check,
      gt_progname           TYPE TABLE OF main_prog,
      gt_progname1          TYPE TABLE OF main_prog,
      gt_checks             TYPE SORTED TABLE OF ty_checks
                            WITH UNIQUE KEY opercd,
      gt_fieldcatalog       TYPE slis_t_fieldcat_alv,
      gt_dd02l_pc           TYPE TABLE OF ty_dd02l_pc.

*----------------------------------------------------------
*  WORK AREA
*----------------------------------------------------------
DATA: gs_progname           TYPE main_prog,
      gs_progname1          TYPE main_prog,
      gs_form_processed     TYPE ty_form,
      gs_incl_processed     TYPE ty_include,
      gs_form_lvl_processed TYPE ty_formlvl,
      gs_ldb                TYPE ty_ldb,
      gs_include            TYPE ty_tables,
      gs_gt_final           TYPE ty_final,
      gs_final              TYPE ty_final,
      gs_finaln             TYPE ty_final1,
      gs_checks             TYPE ty_checks.

*----------------------------------------------------------
*  VARAIBLES
*----------------------------------------------------------
DATA: gv_prog       TYPE progname,
      gv_drill      TYPE i,
      gv_flag       TYPE flag,
      gv_drill_max  TYPE i,
      gf_endselect  TYPE i,
      gv_line       TYPE sy-tabix,
      gv_loop_line  TYPE sy-tabix,
      gv_flag_d     TYPE flag,
      gv_flag_e     TYPE flag,
      gv_exit       TYPE flag,
      gv_org_code   TYPE ty_code,
      gv_perform    TYPE char1,
      gv_per_rec    TYPE string,
      gv_per_rec1   TYPE string,
      gv_per_rec2   TYPE string,
      gv_per_rec3   TYPE string,
      gv_codenew    TYPE string,
*      gv_session_id    TYPE ekpo-kblpos, "ZDB_ANALYSIS_V74-session_id,
      gv_session_id TYPE numc3, "ZDB_ANALYSIS_V74-session_id,
      gv_nt_found   TYPE c,
***********BOC Shreeda 4/05/2017************
      gv_stab       TYPE string,
***********EOC Shreeda 4/05/2017************
      gv_check_flag TYPE c.

*TABLES: trnspace.  " ashish OCT27
DATA: gv_lines TYPE sy-tabix.
DATA: gd_percent TYPE i.
DATA: gt_fields TYPE STANDARD TABLE OF ty_fields.
DATA gv_join_fae TYPE flag.
DATA gv_fields TYPE string.
*DATA: gv_prog99  TYPE progname.
DATA : i_generated TYPE TABLE OF main_prog."itb to check generated prog
DATA : wa_generated TYPE main_prog."work area to check generated prog
DATA : i_gen TYPE STANDARD TABLE OF zdb_analysis_v75.
TYPES: BEGIN OF t_tab_sort,
         table    TYPE string,
         line     TYPE sy-tabix,
         prog     TYPE char40,
         obj_name TYPE char40,
         drill    TYPE zdb_analysis_v75-levels,
       END OF t_tab_sort.
* Begin of change by Twara 12/01/2016 to replace FM with subroutine
*to get includes of classes
DATA: lt_methods  TYPE seop_methods_w_include,
      lwa_methods TYPE seop_method_w_include.
* End of change by Twara 12/01/2016 to replace FM with subroutine
*to get includes of classes
*{ Begin of change by Rohit - 16/12/2015
TYPES: BEGIN OF t_sort,
         table    TYPE string,
* Begin of change by Twara 12/02/2016
         line     TYPE sy-tabix,
         select   TYPE string,
         dbtable  TYPE string,
         tab_type TYPE string,
         prog     TYPE string,
         sub_prog TYPE string,
* End of change by Twara 12/02/2016
       END OF t_sort.
TYPES: BEGIN OF t_sort1,
         table   TYPE string,
         routine TYPE string,
       END OF t_sort1.
DATA: gt_sort_t   TYPE STANDARD TABLE OF t_sort,
      gt_sort_f   TYPE STANDARD TABLE OF t_sort1,
      gt_form_tab TYPE STANDARD TABLE OF t_sort1,
      gt_sort_m   TYPE STANDARD TABLE OF t_sort1,
      gt_meth_tab TYPE STANDARD TABLE OF t_sort1,
      gt_sel_t    TYPE STANDARD TABLE OF t_sort.

*} End of change by Rohit - 16/12/2015
DATA: gt_sort_tab TYPE STANDARD TABLE OF t_tab_sort.
DATA: gt_sort TYPE STANDARD TABLE OF t_tab_sort.
*{ Begin of changes by rohit 12/10/2015
TYPES: BEGIN OF gty_pool_clus,
         tabname  TYPE dd02l-tabname,
         tabclass TYPE dd02l-tabclass,
       END OF gty_pool_clus.
DATA: gt_pool_clus   TYPE STANDARD TABLE OF gty_pool_clus,
      gwa_pool_clus  TYPE gty_pool_clus,
      gwa_pool_clus1 TYPE gty_pool_clus.
DATA: lwa_file TYPE string.
DATA : lv_tabix TYPE i."Odata_def_24
RANGES: gr_tbclass FOR dd02l-tabclass.
*} End of changes by rohit 12/10/2015
* Start of addition by Manoj on 30/12/2015
TYPES: BEGIN OF ty_adbc_tab,
         obj_name TYPE string,
       END OF ty_adbc_tab.

DATA: gt_adbc_tab TYPE TABLE OF ty_adbc_tab.
* End of addition by Manoj on 30/12/2015
"begin of changes for def_20
CLASS lcl_data DEFINITION FINAL.
  "defination
  PUBLIC SECTION.
    METHODS : is_std_object
      IMPORTING
        i_tadir_pgmid  TYPE tadir-pgmid  DEFAULT  'R3TR'
        i_tadir_object TYPE tadir-object
        i_obj_name     TYPE tadir-obj_name
      EXPORTING
        e_std_obj      TYPE wdy_boolean.
ENDCLASS.

"begin of code addition for identification of Odata_def_24 classes.
CLASS lcl_o_data DEFINITION FINAL.
  "defination of class
  "Public section & methods definition
  PUBLIC SECTION.
    TYPES : BEGIN OF ty_mpc_table,
              parent_method TYPE string,
              sub_method    TYPE string,
              line_no       TYPE i,
              instance      TYPE string,
              structure     TYPE dntab-tabname,
              fieldname     TYPE dfies-lfieldname,
              edm_field     TYPE dfies-lfieldname,
              code          TYPE ty_code,
              error         TYPE string,
              done          TYPE char1,
            END OF ty_mpc_table.

    TYPES : BEGIN OF ty_class,
              class_name      TYPE /iwbep/med_runtime_service,
              external_name   TYPE /iwbep/med_grp_external_name,
              service_name    TYPE /iwbep/med_grp_technical_name,
              group_version   TYPE /iwbep/med_grp_version,   "Added by Akshay_Def_24
              service_version TYPE /iwbep/med_grp_version,   "Added by Akshay_Def_24
              dpc_class       TYPE /iwbep/med_runtime_service,
              dpc_ext_class   TYPE /iwbep/med_runtime_service,
              mpc_class       TYPE /iwbep/med_runtime_service,
              mpc_ext_class   TYPE /iwbep/med_runtime_service,
              odata           TYPE wdy_boolean,
            END OF ty_class.

    DATA :lt_mpc           TYPE STANDARD TABLE OF ty_mpc_table,
          ls_mpc           TYPE ty_mpc_table,
          gv_parent_method TYPE string,
          gv_field_name    TYPE dfies-lfieldname,
          lt_class         TYPE STANDARD TABLE OF ty_class,
          ls_class         TYPE ty_class,
          gv_count_prop    TYPE i,
          gv_count_label   TYPE i,
          gv_create_check  TYPE wdy_boolean,
          gv_check_prop    TYPE wdy_boolean.


    METHODS : is_valid_odata_class
      IMPORTING
        i_dest_name TYPE rfcdes-rfcdest,
*        i_class_name TYPE seoclsname
*      EXPORTING
*        e_valid      TYPE char1
*        e_activ      TYPE /iwfnd/med_mdl_active_flag,

      read_rfc_table
        IMPORTING
          i_tab_name  TYPE seoclsname DEFAULT 'SEOMETAREL'
          i_dest_name TYPE rfcdes-rfcdest
        EXPORTING
          e_check     TYPE abap_bool,

      get_odata_opcodes
        IMPORTING
          i_class_name TYPE progname
          i_dest_name  TYPE rfcdes-rfcdest
        EXPORTING
          i_opcode     TYPE char3,
*        .
      check_odata_opcodes
        IMPORTING
          i_code     TYPE ty_code
          i_case     TYPE c
        EXPORTING
          "IT_FILTER_SELECT_OPTIONS or IV_FILTER_STRING or IO_TECH_REQUEST_CONTEXT->GET_FILTER() is used or not,
          "If NOT used, we have to detect it and create an entry for each of these parameters.
          e_opcode62 TYPE abap_bool
          e_opcode63 TYPE abap_bool
          e_opcode64 TYPE abap_bool
          e_opcode65 TYPE abap_bool
          e_opcode66 TYPE abap_bool,
*        .
      get_case
        IMPORTING
          i_code TYPE ty_code
        EXPORTING
          e_case TYPE c,

      check_camel_case
        IMPORTING
          i_field TYPE dfies-lfieldname
        EXPORTING
          e_error TYPE abap_bool,

      is_class_found
        IMPORTING
          i_class     TYPE progname
        EXPORTING
          e_ok        TYPE abap_bool
          e_serv_name TYPE /iwbep/med_grp_technical_name
          e_mpc       TYPE abap_bool
          e_mpc_ext   TYPE abap_bool
          e_odata     TYPE c         "Added by Akshay_Def_35
        ,

      check_edm_type
        IMPORTING
          p_kind    TYPE char1
          p_dfies   TYPE dfies OPTIONAL
        EXPORTING
          e_edm_typ TYPE char20 ,

      get_mpc_logic
        IMPORTING
          i_code  TYPE ty_code
          i_index TYPE i
*        EXPORTING
*          e_tab   LIKE lt_mpc
        ,

* Begin of changes by Akshay for OData_Def_24
      get_value_odata
        IMPORTING
          i_class TYPE progname
        EXPORTING
          e_odata TYPE abap_bool.

* End of changes by Akshay for OData



    " creating public attribute
    TYPES : BEGIN OF ty_sgh,
*              serv_ver   TYPE /iwbep/med_grp_version,
              tech_name  TYPE /iwbep/med_grp_technical_name,
              vers       TYPE /iwbep/med_grp_version,
              class_name TYPE /iwbep/med_runtime_service,
              ext_name   TYPE  /iwbep/med_grp_external_name,
            END OF ty_sgh.
    TYPES : BEGIN OF ty_med,
              srv_identifier  TYPE /iwfnd/med_mdl_srg_identifier,
              is_active       TYPE /iwfnd/med_mdl_active_flag,
              namespace       TYPE /iwfnd/med_mdl_namespace,
              object_name     TYPE /iwfnd/med_mdl_srg_name,
              service_name    TYPE /iwfnd/med_mdl_service_grp_id,
              service_version TYPE /iwfnd/med_mdl_version,
            END OF ty_med.
    TYPES : BEGIN OF ty_seo,
              clsname    TYPE  seoclsname,
              refclsname TYPE seoclsname,
              reltype    TYPE seoreltype,
            END OF ty_seo.

    "create table to fetch service group header table. it will be global for a instance.
    DATA : lt_sgh TYPE STANDARD TABLE OF ty_sgh,
           ls_sgh TYPE ty_sgh,
           lt_med TYPE STANDARD TABLE OF ty_med,
           ls_med TYPE ty_med,
           lt_seo TYPE STANDARD TABLE OF ty_seo,
           ls_seo TYPE ty_seo,
           lt_db  TYPE STANDARD TABLE OF ty_seo.
*           lt_mpc TYPE STANDARD TABLE OF ty_mpc_table.

ENDCLASS.
DATA : lo_cl_odata TYPE REF TO lcl_o_data.
"end of code changes for Odata_def_24

DATA : lo_cl_data TYPE REF TO lcl_data.
"end of changes for def_20
*----------------------------------------------------------

*  SELECTION-SCREEN
*----------------------------------------------------------
SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE TEXT-001.

SELECT-OPTIONS: s_obj FOR gv_prog NO INTERVALS." obligatory.
PARAMETERS: s_rfc  TYPE vers_dest-rfcdest DEFAULT 'NONE'."change for Odata_def_24
*{ Begin of changes by rohit 12/10/2015
PARAMETERS: p_pl_cls AS CHECKBOX USER-COMMAND com.
SELECT-OPTIONS : s_table FOR dd02d-dbtabname NO INTERVALS MODIF ID rad.
*} End of changes by rohit 12/10/2015
*{ Begin of change by Rohit - 28/12/2016
PARAMETERS: p_sc_gp AS CHECKBOX.
*} End of change by Rohit - 28/12/2016
SELECTION-SCREEN END OF BLOCK b1.
*{ Begin of change by rohit 12/10/2015
AT SELECTION-SCREEN.
  IF s_rfc IS INITIAL.
    MESSAGE  : 'If there is no RFC Connection . Enter NONE.' TYPE 'E'.
  ENDIF.
  "end of change for Odata_def_24.

AT SELECTION-SCREEN OUTPUT.
  IF NOT p_pl_cls IS INITIAL.
    LOOP AT SCREEN.
      IF screen-group1 EQ gc_rad.
        screen-active = 1.
        screen-invisible = 0.
        MODIFY SCREEN.
      ENDIF.
    ENDLOOP.
  ENDIF.
  IF p_pl_cls IS INITIAL.
    LOOP AT SCREEN.
      IF screen-group1 EQ gc_rad.
        screen-active = 0.
        screen-invisible = 1.
        MODIFY SCREEN.
      ENDIF.
    ENDLOOP.
  ENDIF.
*} End of changes by rohit 12/10/2015
***********BOC Shreeda 1/05/2017************
INITIALIZATION.
  "form that fills all the pools and cluster table in select option s_table created.
  PERFORM fill_pool_cluster.
***********EOC Shreeda 1/05/2017************
*-----------------------------------------------------------------
*SUBROUTINES INCLUDE
*-----------------------------------------------------------------
*include zupg_hpc_f01_merge06oct.
*&---------------------------------------------------------------------*
*&  Include           ZUPG_HPC_F01_MERGE06OCT
*&---------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*&  Include           ZUPG_HPC_F01
*&---------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*&      Form  GET_PROG
*&---------------------------------------------------------------------*
*       Get the Program names as per selection criteria
*----------------------------------------------------------------------*
FORM get_prog .

*Catch system exceptions
  CATCH SYSTEM-EXCEPTIONS arithmetic_errors             = 1
                          create_data_errors            = 2
                          conversion_errors             = 3
                          create_object_errors          = 4
                          data_access_errors            = 5
                          assign_casting_illegal_cast   = 6
                          assign_casting_unknown_type   = 7
                          assign_field_not_in_range     = 8
                          data_offset_too_large         = 9
                          dyn_call_meth_not_implemented = 10
                          export_buffer_no_memory       = 11
                          generate_subpool_dir_full     = 12
                          move_cast_error               = 13
                          perform_program_name_too_long = 14
                          replace_infinite_loop         = 15
                          remote_call_errors            = 16
                          localization_errors           = 17
                          import_mismatch_errors        = 18
                          dynamic_call_method_errors    = 19
                          file_access_errors            = 20
                          OTHERS                        = 99.
*Catch system exceptions

    DATA: lt_tadir     TYPE TABLE OF ty_tadir,
          lwa_tadir    TYPE          ty_tadir,
          lwa_mainprog TYPE          d010inc,
          lt_include   TYPE TABLE OF ty_objname,
          lwa_objname  TYPE          ty_objname,
          lwa_tables   TYPE          ty_tables,
          lt_mainprog  TYPE TABLE OF d010inc.

    DATA: lwa_class   TYPE seoclskey.
* Begin of change by Twara 12/01/2016 to replace FM with subroutine
*to get includes of classes
*          lt_methods  TYPE seop_methods_w_include, "commented
*          lwa_methods TYPE seop_method_w_include.
* End of change by Twara 12/01/2016 to replace FM with subroutine
*to get includes of classes
    TYPES : BEGIN OF ty_reposrc,
              progname TYPE progname,
            END OF ty_reposrc.
    DATA : wa_reposrc TYPE ty_reposrc,
           lt_reposrc TYPE STANDARD TABLE OF ty_reposrc.
* start of change by ashish on 27OCT -- added advanced selection screen
    DATA: lv_str1 TYPE string. " 29OCT  ashish
    DATA: lv_str2 TYPE string. " 29OCT ashish
*********Create range for Namespace: start ashish 29OCT
    DATA : lwr_nspace  LIKE LINE OF gr_nspace.
    DATA: lv_namespace TYPE namespace,
          lv_activ     TYPE /iwfnd/med_mdl_active_flag. "Odata_def_24 Changes.
    lwr_nspace-sign = gc_i.
    lwr_nspace-option = gc_cp.
******** end ashish 29OCT
* Changes removed for screen changes
*    IF p_r1 = 'X'.
*      " no change needed
*    ENDIF.
*    IF p_r2 = 'X'.
*
*      REFRESH s_prog[].
*      IF p_cz = 'X'.
*        s_prog-sign = 'I'.
*        s_prog-option = 'CP'.
*        s_prog-low = 'Z*'.
*        APPEND s_prog TO s_prog.
*      ENDIF.
*
*      IF p_cy = 'X'.
*        s_prog-sign = 'I'.
*        s_prog-option = 'CP'.
*        s_prog-low = 'Y*'.
*        APPEND s_prog TO s_prog.
*      ENDIF.
*
*      LOOP AT s_name INTO s_name.
*        s_prog-sign = 'I'.
*        s_prog-option = 'CP'.
*        CONCATENATE s_name-low '*' INTO s_prog-low.
*        APPEND s_prog TO s_prog.
*      ENDLOOP.
*
*    ENDIF.
** end of change by ashish on 27OCT -- added advanced selection screen.

    SELECT object obj_name FROM tadir
        INTO TABLE lt_tadir
        WHERE pgmid = gc_r3tr AND
              object IN (gc_prog, gc_clas , gc_fugr )
        AND   obj_name IN s_obj.
    IF NOT lt_tadir[] IS INITIAL.
      SORT lt_tadir BY object obj_name.
      " begin of code change for Odata_def_24.
      CREATE OBJECT lo_cl_odata.
      CALL METHOD lo_cl_odata->is_valid_odata_class
        EXPORTING
          i_dest_name = s_rfc.
      "end of code changes for Odata_def_24.
      LOOP AT lt_tadir INTO lwa_tadir.

* Just to make sure not to miss any main program in scanning.
        CLEAR lwa_tables.
        lwa_tables-objtyp   = lwa_tadir-object.
        lwa_tables-progname = lwa_tadir-obj_name.
        lwa_tables-include = lwa_tadir-obj_name.
        APPEND lwa_tables TO gt_include.
        CLEAR lwa_tables.
*
        CASE lwa_tadir-object.

***FOR FUGR
          WHEN gc_fugr.

* start of change by ashish on 29OCT -- namespace logic
            CONDENSE: lwa_tadir-obj_name.
            IF lwa_tadir-obj_name+0(1) = gc_for_slash .
              REPLACE FIRST OCCURRENCE OF gc_for_slash IN
              lwa_tadir-obj_name
              WITH ''.
              CONDENSE lwa_tadir-obj_name.
              CLEAR: lv_str1, lv_str2.
              SPLIT lwa_tadir-obj_name AT gc_for_slash INTO lv_str1
              lv_str2.
              CHECK lv_str2 IS NOT INITIAL.
              CLEAR: lwa_tadir-obj_name.
              CONCATENATE gc_for_slash lv_str1 gc_for_slash gc_sapl
              lv_str2 INTO
              lwa_tadir-obj_name.
*            CONCATENATE '/' lv_str1 '/' '*' INTO lv_str1.
              CONCATENATE gc_for_slash lv_str1 gc_for_slash INTO lv_str1
              .
              lwr_nspace-low = lv_str1.
              IF lwr_nspace-low IN gr_nspace[] AND
                 NOT gr_nspace[] IS INITIAL.
                "$$
                " nothing to do.
              ELSE.
                SELECT SINGLE namespace INTO lv_namespace
                  FROM trnspacet
                   WHERE namespace = lwr_nspace-low.
                IF sy-subrc = 0.
                  CONCATENATE  lv_str1 gc_star INTO lv_str1.
                  lwr_nspace-low = lv_str1.
                  APPEND lwr_nspace TO gr_nspace.
                ELSE.
                  CONTINUE.
                ENDIF.
              ENDIF.
              CLEAR: lv_str1, lv_str2.
            ELSE.
              CONCATENATE gc_sapl lwa_tadir-obj_name INTO
              lwa_tadir-obj_name.
            ENDIF.
* end of change by ashish on 29OCT -- namespace logic
*          IF sy-subrc = 0. 28OCT commented ashish
            lwa_tables-objtyp = lwa_tadir-object.
            lwa_tables-progname = lwa_tadir-obj_name.
*Begin changes Shekhar 18 Aug14
*Get all the includes used in program
            CALL FUNCTION 'RS_GET_ALL_INCLUDES'
              EXPORTING
                program      = lwa_tadir-obj_name
              TABLES
                includetab   = lt_include
              EXCEPTIONS
                not_existent = 1
                no_program   = 2
                OTHERS       = 3.
            IF sy-subrc = 0 AND lt_include IS NOT INITIAL.
              LOOP AT lt_include INTO lwa_objname.
                lwa_tables-include = lwa_objname.
                APPEND lwa_tables TO gt_include.
              ENDLOOP.
            ELSE.
*End changes Shekhar 18 Aug14
              APPEND lwa_tables TO gt_include.
            ENDIF. "Shekhar 18 Aug14
*          ENDIF.  " 28 OCT commented -ashish
            CLEAR: lwa_tables.

          WHEN gc_prog.
* start of change by ashish on 29OCT -- namespace logic
            CONDENSE: lwa_tadir-obj_name.
            IF lwa_tadir-obj_name+0(1) = gc_for_slash .
              REPLACE FIRST OCCURRENCE OF gc_for_slash IN
              lwa_tadir-obj_name
              WITH ''.
              CONDENSE lwa_tadir-obj_name.
              CLEAR: lv_str1, lv_str2.
              SPLIT lwa_tadir-obj_name AT gc_for_slash INTO lv_str1
              lv_str2.
              CHECK lv_str2 IS NOT INITIAL.
              CLEAR: lwa_tadir-obj_name.
              CONCATENATE gc_for_slash lv_str1 gc_for_slash lv_str2
               INTO lwa_tadir-obj_name.
*            CONCATENATE '/' lv_str1 '/' '*' INTO lv_str1.
              CONCATENATE gc_for_slash lv_str1 gc_for_slash INTO lv_str1
              .
              lwr_nspace-low = lv_str1.
              IF lwr_nspace-low IN gr_nspace[] AND
                NOT gr_nspace[] IS INITIAL.
                " nothing to do.
              ELSE.
                SELECT SINGLE namespace INTO lv_namespace
                                        FROM trnspacet
                                        WHERE namespace = lwr_nspace-low
                                        .
                IF sy-subrc = 0.
                  CONCATENATE lv_str1  gc_star INTO lv_str1.
                  lwr_nspace-low = lv_str1.
                  APPEND lwr_nspace TO gr_nspace.
                ELSE.
                  CONTINUE.
                ENDIF.
              ENDIF.

*            APPEND lwr_nspace TO gr_nspace.
              CLEAR: lv_str1, lv_str2.
            ENDIF.
* end of change by ashish on 29OCT -- namespace logic

*  get main program
            CALL FUNCTION 'RS_GET_MAINPROGRAMS'
              EXPORTING
                name         = lwa_tadir-obj_name
              TABLES
                mainprograms = lt_mainprog.
            LOOP AT lt_mainprog INTO lwa_mainprog.
              CLEAR:  lt_include.

              lwa_tables-objtyp = lwa_tadir-object.
              lwa_tables-progname = lwa_mainprog-master.

              IF lwa_mainprog-master CS gc_saplz OR
                 lwa_mainprog-master CS gc_saply OR
                 lwa_mainprog-master CS gc_sapmz OR
                 lwa_mainprog-master CS gc_sapmy OR
                 lwa_mainprog-master+0(1) = gc_z OR
                 lwa_mainprog-master+0(1) = gc_y OR
* Begin of change by Rahul 08072015
                 lwa_mainprog-master+0(3) = gc_mp9 OR
* End of change by Rahul 08072015
                 ( lwa_mainprog-master  IN  gr_nspace[] AND NOT
                 gr_nspace[] IS INITIAL ). " 29OCT - ashish
*Get all the includes used in program
                CALL FUNCTION 'RS_GET_ALL_INCLUDES'
                  EXPORTING
                    program      = lwa_mainprog-master
                  TABLES
                    includetab   = lt_include
                  EXCEPTIONS
                    not_existent = 1
                    no_program   = 2
                    OTHERS       = 3.
                IF sy-subrc = 0 AND lt_include IS NOT INITIAL.
                  LOOP AT lt_include INTO lwa_objname.
                    lwa_tables-include = lwa_objname.
                    APPEND lwa_tables TO gt_include.
                  ENDLOOP.
                ELSE.
                  APPEND lwa_tables TO gt_include.
                ENDIF.
              ELSE.
                lwa_tables-objtyp   = lwa_tadir-object.
                lwa_tables-progname = lwa_tadir-obj_name.
                lwa_tables-include = lwa_tadir-obj_name.
                APPEND lwa_tables TO gt_include.
              ENDIF.
              CLEAR: lwa_objname, lwa_tables.
            ENDLOOP.
            IF sy-subrc NE 0.
              lwa_tables-objtyp   = lwa_tadir-object.
              lwa_tables-progname = lwa_tadir-obj_name.
              lwa_tables-include = lwa_tadir-obj_name.
              APPEND lwa_tables TO gt_include.
            ENDIF.

          WHEN gc_clas.
* start of change by ashish on 29OCT -- namespace logic
            CONDENSE: lwa_tadir-obj_name.
            IF lwa_tadir-obj_name+0(1) = gc_for_slash .
              REPLACE FIRST OCCURRENCE OF gc_for_slash IN
              lwa_tadir-obj_name
              WITH ''.
              CONDENSE lwa_tadir-obj_name.
              CLEAR: lv_str1, lv_str2.
              SPLIT lwa_tadir-obj_name AT gc_for_slash INTO lv_str1
              lv_str2.
              CHECK lv_str2 IS NOT INITIAL.
              CLEAR: lwa_tadir-obj_name.
              CONCATENATE gc_for_slash lv_str1 gc_for_slash lv_str2
              INTO lwa_tadir-obj_name.
*            CONCATENATE '/' lv_str1 '/' '*' INTO lv_str1.
              CONCATENATE gc_for_slash lv_str1 gc_for_slash INTO lv_str1
              .
              lwr_nspace-low = lv_str1.
              IF lwr_nspace-low IN gr_nspace[]  AND NOT
                                                gr_nspace[] IS INITIAL.
                " nothing to do.
              ELSE.
                SELECT SINGLE namespace INTO lv_namespace
                                        FROM trnspacet
                                        WHERE namespace = lwr_nspace-low
                                        .
                IF sy-subrc = 0.
                  CONCATENATE lv_str1 gc_star INTO lv_str1.
                  lwr_nspace-low = lv_str1.
                  APPEND lwr_nspace TO gr_nspace.
                ELSE.
                  CONTINUE.
                ENDIF.
              ENDIF.
*            APPEND lwr_nspace TO gr_nspace.
              CLEAR: lv_str1, lv_str2.
            ENDIF.
* end of change by ashish on 29OCT -- namespace logic

            CLEAR: lt_methods[], lwa_class.
            lwa_class-clsname = lwa_tadir-obj_name.
            lwa_tables-objtyp = lwa_tadir-object.

* Begin of change by Twara 12/01/2016 to replace FM with subroutine
*to get includes of classes
*              CALL FUNCTION 'SEO_CLASS_GET_METHOD_INCLUDES'
*                EXPORTING
*                  clskey                       = lwa_class
*                IMPORTING
*                  includes                     = lt_methods
*                EXCEPTIONS
*                  _internal_class_not_existing = 1
*                  OTHERS                       = 2.

            PERFORM get_method_includes USING lwa_class.

            IF NOT lt_methods IS INITIAL.
* End of change by Twara 12/01/2016 to replace FM with subroutine
*to get includes of classes

              LOOP AT lt_methods INTO lwa_methods.
                lwa_tables-mainprog = lwa_methods-incname.
                lwa_tables-progname = lwa_methods-incname.
                APPEND lwa_tables TO gt_include.
                lwa_tables-mainprog = lwa_methods-cpdkey-clsname.
                lwa_tables-include = lwa_methods-cpdkey-cpdname.
                "begin of code changes for Odata_def_24

*                READ TABLE lo_cl_odata->lt_class INTO lo_cl_odata->ls_class WITH KEY dpc_class = lwa_tables-mainprog.
*                IF sy-subrc NE 0.
*                  READ TABLE lo_cl_odata->lt_class INTO lo_cl_odata->ls_class WITH KEY mpc_class = lwa_tables-mainprog.
*                  IF sy-subrc NE 0.
*                    READ TABLE lo_cl_odata->lt_class INTO lo_cl_odata->ls_class WITH KEY mpc_ext_class = lwa_tables-mainprog.
*                    IF sy-subrc NE 0.
*                      READ TABLE lo_cl_odata->lt_class INTO lo_cl_odata->ls_class WITH KEY dpc_ext_class = lwa_tables-mainprog.
*                      IF sy-subrc NE 0.
*                      ELSE.
*                        lwa_tables-odata  = lo_cl_odata->ls_class-odata.
*                      ENDIF.
*                    ELSE.
*                      lwa_tables-odata  = lo_cl_odata->ls_class-odata.
*                    ENDIF.
*                  ELSE.
*                    lwa_tables-odata  = lo_cl_odata->ls_class-odata.
*                  ENDIF.
*                ELSE.
*                  lwa_tables-odata  = lo_cl_odata->ls_class-odata.
*                ENDIF.

                CALL METHOD lo_cl_odata->get_value_odata
                  EXPORTING
                    i_class = lwa_tables-mainprog
                  IMPORTING
                    e_odata = lwa_tables-odata.
*   * End of changes by Akshay for OData_Def_24

*                lwa_tables-mainprog = lwa_methods-cpdkey-clsname.
*                lwa_tables-include = lwa_methods-cpdkey-cpdname.
                APPEND lwa_tables TO gt_include_cls.
*
                CLEAR: lwa_tables-include, lwa_tables-mainprog,lv_activ."changes for Odata_def_24.
              ENDLOOP.
*   Begin of changes by Akshay for OData_Def_24
            ELSE.
              CLEAR lwa_tables.
              lwa_tables-objtyp   = lwa_tadir-object.
              lwa_tables-progname = lwa_tadir-obj_name.
              lwa_tables-include = lwa_tadir-obj_name.
              lwa_tables-mainprog = lwa_tadir-obj_name.

              CALL METHOD lo_cl_odata->get_value_odata
                EXPORTING
                  i_class = lwa_tables-progname
                IMPORTING
                  e_odata = lwa_tables-odata.


              APPEND lwa_tables TO gt_include_cls.
              CLEAR : lwa_tables.
*   End of changes by Akshay for OData_Def_24
            ENDIF.
        ENDCASE.
      ENDLOOP.

      " start of change by ashish on 14th NOV -- remove standard objects
      "from  gt_include
      LOOP AT gt_include INTO  lwa_tables.
        IF lwa_tables-include IS NOT INITIAL.
          IF lwa_tables-include CS gc_saplz OR
                        lwa_tables-include CS gc_saply OR
                        lwa_tables-include CS gc_sapmz OR
                        lwa_tables-include CS gc_sapmy OR
                        lwa_tables-include+0(2) = gc_lz OR
                        lwa_tables-include+0(2) = gc_ly OR
                        lwa_tables-include+0(2) = gc_mz OR
                        lwa_tables-include+0(2) = gc_my OR
                        lwa_tables-include+0(1) = gc_z OR
                        lwa_tables-include+0(1) = gc_y OR
* Begin of change by Rahul 08072015
                        lwa_tables-include+0(3) = gc_mp9 OR
* End of change by Rahul 08072015
                       ( lwa_tables-include IN gr_nspace[]
                        AND NOT gr_nspace[] IS INITIAL ).
            " 14th Nov ashish

            " keep entry
          ELSE.
            DELETE gt_include INDEX sy-tabix.
          ENDIF.
        ENDIF.
      ENDLOOP.
      " end of change by ashish 14th NOV - remove standard objects from
      "gt_include
      " start 29 OCT ashish
      SORT gr_nspace[] BY low.
      DELETE gr_nspace WHERE low = ''.
      DELETE ADJACENT DUPLICATES FROM gr_nspace COMPARING low.
      " end 29 OCT ashish
    ENDIF.

*Catch system exceptions
  ENDCATCH.
  IF sy-subrc <> 0.
    WRITE:/ gc_error ,'Error code:', sy-subrc , '=>Perform GET_PROG'.
  ENDIF.
*Catch system exceptions
ENDFORM.                    " GET_PROG
*&---------------------------------------------------------------------*
*&      Form  F_READ_REPORT
*&---------------------------------------------------------------------*
*       Read the source code of the program
*----------------------------------------------------------------------*
*      -->P_PROG   Name of Program
*----------------------------------------------------------------------*
FORM f_read_report  USING   p_prog.
  "begin of change for Odata_def_24
  DATA : lv_opcode     TYPE char3,
         lv_class_name TYPE progname,
         lv_odata      TYPE c.
  "end of change for Odata_def_24
*Catch system exceptions
  CATCH SYSTEM-EXCEPTIONS arithmetic_errors             = 1
                          create_data_errors            = 2
                          conversion_errors             = 3
                          create_object_errors          = 4
                          data_access_errors            = 5
                          assign_casting_illegal_cast   = 6
                          assign_casting_unknown_type   = 7
                          assign_field_not_in_range     = 8
                          data_offset_too_large         = 9
                          dyn_call_meth_not_implemented = 10
                          export_buffer_no_memory       = 11
                          generate_subpool_dir_full     = 12
                          move_cast_error               = 13
                          perform_program_name_too_long = 14
                          replace_infinite_loop         = 15
                          remote_call_errors            = 16
                          localization_errors           = 17
                          import_mismatch_errors        = 18
                          dynamic_call_method_errors    = 19
                          file_access_errors            = 20
                          OTHERS                        = 99.
*Catch system exceptions

    "begin of code change for Odata_def_24.
    IF gt_include_odata IS INITIAL.
      gt_include_odata = gt_include_cls.
      DELETE ADJACENT DUPLICATES FROM gt_include_odata COMPARING mainprog.
    ENDIF.
    IF gt_include_odata IS NOT INITIAL.
      SORT gt_include_odata BY odata.
      READ TABLE gt_include_odata INTO gs_include_odata WITH KEY mainprog  = p_prog
                                                                  .
      IF sy-subrc EQ 0 AND gs_include_odata-odata IS NOT INITIAL.
        CLEAR lv_class_name.
        lv_class_name = p_prog.
        CALL METHOD lo_cl_odata->get_odata_opcodes
          EXPORTING
            i_class_name = lv_class_name
            i_dest_name  = s_rfc
          IMPORTING
            i_opcode     = lv_opcode.

      ENDIF.
    ENDIF.
    "end of code change for Odata_def_24

    CLEAR: gt_code.
    READ REPORT p_prog INTO gt_code.
    CHECK sy-subrc = 0.
    gv_prog = p_prog.

*Scan the source code for errors
    PERFORM read_report USING gt_code.

* start of new logic for SORT
    PERFORM sort_result.

* end of new logic for SORT
*Catch system exceptions
  ENDCATCH.
  IF sy-subrc <> 0.
    WRITE:/ gc_error ,'Error code:', sy-subrc ,'=>Perform F_READ_REPORT'
    .
  ENDIF.
*Catch system exceptions
ENDFORM.                    " F_READ_REPORT
*&---------------------------------------------------------------------*
*&      Form  READ_REPORT
*&---------------------------------------------------------------------*
*      Scanning of teh source code of the program
*----------------------------------------------------------------------*
*      -->P_CODE   Source code of the program
*----------------------------------------------------------------------*
FORM read_report  USING p_code LIKE gt_code.

*Catch system exceptions
  CATCH SYSTEM-EXCEPTIONS arithmetic_errors             = 1
                          create_data_errors            = 2
                          conversion_errors             = 3
                          create_object_errors          = 4
                          data_access_errors            = 5
                          assign_casting_illegal_cast   = 6
                          assign_casting_unknown_type   = 7
                          assign_field_not_in_range     = 8
                          data_offset_too_large         = 9
                          dyn_call_meth_not_implemented = 10
                          export_buffer_no_memory       = 11
                          generate_subpool_dir_full     = 12
                          move_cast_error               = 13
                          perform_program_name_too_long = 14
                          replace_infinite_loop         = 15
                          remote_call_errors            = 16
                          localization_errors           = 17
                          import_mismatch_errors        = 18
                          dynamic_call_method_errors    = 19
                          file_access_errors            = 20
                          OTHERS                        = 99.
*Catch system exceptions

    TYPES: BEGIN OF ty_codecs,
             text(40) TYPE c,
           END OF ty_codecs.

    CONSTANTS :c_endform(7)  TYPE c VALUE gc_endform.

    DATA : lt_includecs  TYPE TABLE OF ty_codecs,
           lwa_includecs TYPE  ty_codecs.

    DATA: lt_code TYPE TABLE OF ty_code.
    DATA: lt_code_split TYPE TABLE OF ty_code,
          ls_code_split TYPE          ty_code,
          lv_line_split TYPE          sy-tabix,
          lv_flag_quote TYPE          c.

    DATA: lwa_code   TYPE                   ty_code,
          pva_code   TYPE STANDARD TABLE OF ty_code,
          lxa_code   TYPE                   ty_code,
          lva_code   TYPE                   ty_code,
          lwa_slct   TYPE                   ty_code,
          lwa_table  TYPE                   ty_tab,
          lwa_table1 TYPE                   ty_tab,
          lwa_final  TYPE                   ty_final.
    DATA: lv_index   TYPE sy-tabix,
          lv_row     TYPE i,
          lv_str1    TYPE string,
          lv_str2    TYPE string,
          lv_col     TYPE i,
          lv_flag1   TYPE c,
          lv_include TYPE progname.
    DATA: lf_include TYPE c,
          lf_form    TYPE c,
          lv_flagcs  TYPE c,
          lv_inc     TYPE string,
          lv1_read   TYPE string,
          lv2_read   TYPE string,
          lv_line    TYPE sy-tabix.

    DATA: ldb_name     TYPE          trdir-ldbname,
          ldb_code     TYPE TABLE OF ty_code,
          lwa_code_ldb TYPE          ty_code,
          lv_ldb1      TYPE          string,
          lv_ldb2      TYPE          string,
          lv_ldb3      TYPE          string,
          lwa_ldb      TYPE          ty_final,
          ldb_index    TYPE          sy-tabix,
          l_tabclass   TYPE          dd02l-tabclass,
          lv_table     TYPE          char30,
          lw_read_code TYPE          ty_code,
          lv_index1    TYPE          sy-tabix,
          lv_row1      TYPE          i,
          lv_strr      TYPE          string,
          start_line   TYPE          i.
* Start of change by Manoj on 5/1/2016
    DATA: lv_line_code   TYPE ty_code.
* End of change by Manoj on 5/1/2016
    DATA:  lt_drill   TYPE TABLE OF ty_code.
    DATA: lv_eloop_flag TYPE flag.
    CLEAR: lv_eloop_flag.
    DATA: gv_prog99 TYPE progname.
    DATA: lv_str99 TYPE string.
    DATA: lt_tab99  TYPE TABLE OF ty_code,
          lwa_tab99 TYPE ty_code.
    DATA: lv_sort TYPE sy-tabix.
    DATA:  lwa_sort_tab TYPE t_tab_sort.
    CLEAR: l_tabclass, lv_table.
    DATA: ls_form_processed     LIKE LINE OF gt_form_processed.
    DATA: lv_subroutine TYPE          string.

    "begin of code change for Odata_def_24
    DATA : lv_opcode62 TYPE wdy_boolean,
           lv_opcode63 TYPE wdy_boolean,
           lv_opcode64 TYPE wdy_boolean,
           lv_opcode65 TYPE wdy_boolean,
           lv_opcode66 TYPE wdy_boolean,
           lv_case     TYPE c,

           lv_mpc      TYPE wdy_boolean,
           lv_mpc_ext  TYPE wdy_boolean,
           lv_count    TYPE i,
           lv_edm      TYPE string,
           lv_edm_typ  TYPE char20,
           lv_error    TYPE wdy_boolean,
           lv_error1   TYPE string,
           lv_error2   TYPE string,
           "Var's to get edm types
           lv_string1  TYPE string,
           lv_string2  TYPE string,
           lv_string3  TYPE string,
           lv_string4  TYPE string,

           ls_include  TYPE ty_tables,
           lt_temp     TYPE STANDARD TABLE OF lo_cl_odata->ty_mpc_table,
           ls_temp     TYPE lo_cl_odata->ty_mpc_table,
           lt_new      TYPE STANDARD TABLE OF lo_cl_odata->ty_mpc_table,
           lt_tab      TYPE STANDARD TABLE OF dntab,
           lwa_dfies   TYPE dfies,
           lv_odata    TYPE c.
*           lwa_final   TYPE  ty_final
    .


    CONSTANTS : lc_62         TYPE char2  VALUE '62',
                lc_63         TYPE char2  VALUE '63',
                lc_64         TYPE char2  VALUE '64',
                lc_65         TYPE char2  VALUE '65',
                lc_66         TYPE char2  VALUE '66',
                lc_71         TYPE char2  VALUE '71',
                lc_72         TYPE char2  VALUE '72',
                lc_73         TYPE char2  VALUE '73',
                lc_74         TYPE char2  VALUE '74',
                lc_1          TYPE c      VALUE '1',
                lc_2          TYPE c      VALUE '2',
                lc_prop       TYPE char15 VALUE 'CREATE_PROPERTY',
                lc_edm        TYPE char12 VALUE 'SET_TYPE_EDM',
                lc_bind_struc TYPE char14 VALUE 'BIND_STRUCTURE',
                lc_inst       TYPE char2 VALUE '=>',
                lc_colon      TYPE c VALUE '''',
                lc_us         TYPE c VALUE '_'.

    .


    CLEAR :lv_odata,lv_case,lo_cl_odata->gv_field_name,lv_string1,lv_string2,lv_string3,lv_string4
            .
    READ TABLE gt_include_cls INTO ls_include WITH KEY progname  = gs_progname-progname.
    IF sy-subrc EQ 0.
      IF ls_include-odata IS NOT INITIAL.
        lv_odata  = 'X'.
      ENDIF.
    ENDIF.
    "end of code change for Odata_def_24
    start_line = 0.
    LOOP AT p_code INTO lwa_code.
      TRANSLATE lwa_code-text TO UPPER CASE.
*==========================
*DO not scan the source code if it is commented
*or statement inside single quotes
*==========================
      CONDENSE lwa_code-text.
      IF lwa_code-text = '' OR lwa_code-text+0(1) = gc_star OR
      lwa_code-text+0(1) = gc_doub_quote.
        CONTINUE.
      ENDIF.

*==========================
*Source code is already scanned till end of statement by using
*PERFORM get_line ,so do not scan again
*==========================
      lv_index = sy-tabix.
      IF lv_index LE lv_row.
        CONTINUE.
      ENDIF.

*==========================
*Do not process code inside form as we have already scanning
* the source code inside it for PERFORM statement
*==========================
      IF lf_form = gc_x.
        CONDENSE lwa_code.
        IF lwa_code+0(7) = c_endform.
          CLEAR lf_form.
          CONTINUE.
        ELSE.
          CONTINUE.
        ENDIF.
      ENDIF.

*==========================
* Translate the source code to upper case
*==========================
      CONDENSE lwa_code.
      TRANSLATE lwa_code TO UPPER CASE.

*==========================
*Concatenate full statement in a line
*==========================
      PERFORM get_line  USING p_code
                              lv_index
                        CHANGING lv_str1
                                 lv_row.
      lwa_code = lv_str1.
*{ Begin of change by Rohit - 16/12/2015
      lv_line_code = lwa_code.
      CONDENSE lv_line_code.
*} End of change by Rohit - 16/12/2015
*==========================
*putting whole source code to global variable
*==========================
      CLEAR: gv_org_code.
      gv_org_code = lwa_code.

*==========================
*DO not scan the source code if it is commented or statement
*inside single quotes
*==========================
      CONDENSE lwa_code.
      CLEAR lv_str1.

      IF lwa_code CS gc_doub_quote.

        CLEAR gv_check_flag.
        PERFORM get_offset_key_single_quote USING
               lwa_code '"'
               CHANGING gv_check_flag.
        IF gv_check_flag IS INITIAL.
          SPLIT lwa_code AT gc_doub_quote INTO lwa_code lv_str1.
        ENDIF.
        CLEAR gv_check_flag.
        CLEAR lv_str1.
      ENDIF.
      IF lwa_code+0(1) EQ gc_doub_quote OR  lwa_code+0(1) = gc_star
        OR lwa_code+0(1) EQ '''' .
        CONTINUE.
      ENDIF.

*=================================
* Logic to find TYPE SORTED TABLE
*=====================================
      REFRESH lt_tab99[].
      CLEAR: lv_str99.
      lv_str99 = lwa_code.
      CONDENSE lv_str99.
      IF lv_str99 CS gc_type_sort_tab.
        REPLACE ALL OCCURRENCES OF gc_type_sort_tab
        IN lv_str99 WITH gc_x1x1.
        SPLIT lv_str99 AT '' INTO TABLE lt_tab99.
        LOOP AT lt_tab99 INTO lwa_tab99.
          IF lwa_tab99 = gc_x1x1.
            lv_str99 = sy-tabix - 1.
            CHECK  lv_str99 > 0.
            READ TABLE lt_tab99 INTO lwa_tab99 INDEX lv_str99.
            IF sy-subrc = 0.
              lwa_sort_tab-table = lwa_tab99.
              REPLACE ALL OCCURRENCES OF gc_bracket
              IN lwa_sort_tab-table WITH ''.
              CONDENSE lwa_sort_tab-table.
              APPEND lwa_sort_tab TO gt_sort.
            ENDIF.
          ENDIF.
        ENDLOOP.
      ENDIF.
*{ Begin of change by Rohit - 16/12/2015
*===============================================
* Logic to find all the sorted tables in the program
*===============================================
      PERFORM f_find_sorted_table USING lv_line_code
                                        lv_index.

*} End of change by Rohit - 16/12/2015

*{ Begin of change by Rohit - 16/12/2015
*===============================================
* Logic to detect unsorted internal table with index
*===============================================
      PERFORM f_detect_itab_index_main USING lv_line_code
                                        lv_index.

*} End of change by Rohit - 16/12/2015

* Begin of change by Twara 04/01/2016 to process CLASS
*===============================================
* Logic to process Classes
*===============================================
      PERFORM f_process_class USING lv_line_code
                                    lv_index.
* End of change by Twara 04/01/2016 to process CLASS

*==========================
*Check that keyword written inside single quotes
*==========================
      CLEAR gv_check_flag.
      PERFORM get_offset_key_single_quote USING
               lwa_code 'READ TABLE'
               CHANGING gv_check_flag.

*==========================
*Check if statement having READ with BINARY SEARCH but sorting
*is not done on internal table
*==========================
      CLEAR : lv1_read , lv2_read .
      IF lwa_code-text CS gc_read_tab AND
         lwa_code-text CS gc_bin_search
         AND  gv_check_flag IS INITIAL .
        lwa_final-line = sy-tabix.
        SPLIT lwa_code-text AT gc_read_tab INTO lv1_read lv2_read.
        CONDENSE lv2_read.
        SPLIT lv2_read AT space INTO lv1_read lv2_read.
        CONDENSE lv1_read.
        lwa_final-itabs = lv1_read.

        CLEAR: gt_f_code, gv_nt_found.
* start replace FM with FORM
*        CALL FUNCTION 'ZAUCT_FIND_STR'
*          EXPORTING
*            p_name       = gv_prog
*            code_string  = lwa_final-itabs
*            line_no      = lwa_final-line
*            p_type       = gc_r
*          IMPORTING
*            lv_not_found = gv_nt_found
*          TABLES
*            it_fcode     = gt_f_code.

        PERFORM get_scan TABLES gt_f_code
                         USING gv_prog lwa_final-itabs gc_zero
                               lwa_final-line gc_r '' "Added for scan
                         CHANGING gv_nt_found.

* end replace FM with FORM
* Begin of change by Twara 12/02/2016
        DATA: lwa_sel_t  TYPE t_sort,
              lwa_sel_t1 TYPE t_sort.
* End of change by Twara 12/02/2016

        IF gt_f_code IS INITIAL.
* Begin of change by Twara 12/02/2016
          IF NOT lv1_read IS INITIAL.
            " find if internal is used in select statements
            READ TABLE gt_sel_t INTO lwa_sel_t WITH KEY table = lv1_read
            BINARY SEARCH.
            IF sy-subrc = 0.
*****BOC Def_36 by shreeda 26/5/2017 ----remove opcode 77, 78, 79
************BOC Shreeda 2/05/2017************
*              CLEAR: gv_stab.
*              gv_stab = lwa_sel_t-dbtable.
************EOC Shreeda 2/05/2017************
*****EOC Def_36 by shreeda 26/5/2017 ----remove opcode 77, 78, 79
              " find internal is unsorted
              READ TABLE gt_sort_t WITH KEY table = lv1_read
              TRANSPORTING NO FIELDS
              BINARY SEARCH.
              IF sy-subrc <> 0.
*****BOC Def_36 by shreeda 26/5/2017 ----remove opcode 77, 78, 79
************BOC Shreeda 2/05/2017************
*                READ TABLE s_table WITH KEY low = gv_stab TRANSPORTING NO FIELDS.
*                IF sy-subrc EQ 0.
*                  lwa_final-code   = gv_org_code.
*                  lwa_final-prog   = gv_prog.
*                  lwa_final-obj_name = gs_progname-progname.
*                  lwa_final-line = lv_index.
*                  lwa_final-opercd = gc_78.
*                  lwa_final-drill = gv_drill.
*                ELSE.
************EOC Shreeda 2/05/2017************
*****EOC Def_36 by shreeda 26/5/2017 ----remove opcode 77, 78, 79
* End of change by Twara 12/02/2016
                lwa_final-code   = gv_org_code.
                lwa_final-prog   = gv_prog.
                lwa_final-obj_name = gs_progname-progname.
                lwa_final-line = lv_index.
                lwa_final-opercd = gc_45.
                lwa_final-drill = gv_drill.
* Begin of change by Twara 12/02/2016
                READ TABLE gt_sel_t
                  INTO lwa_sel_t1
                  WITH KEY
                   table = lv1_read
                           prog  = gv_prog
                           sub_prog = gs_progname-progname.
                IF sy-subrc EQ 0.
                  lwa_final-select_line = lwa_sel_t1-line.
                  PERFORM append_opcode21 USING lwa_sel_t-dbtable
                                                lwa_sel_t-table
                                                lwa_sel_t-tab_type
                                                lwa_sel_t-prog
                                                lwa_sel_t-sub_prog
                                                lwa_sel_t-line
                                                lwa_sel_t-select.
                ENDIF.
*****BOC Def_36 by shreeda 26/5/2017 ----remove opcode 77, 78, 79
************BOC Shreeda 2/05/2017************
*                ENDIF.
************EOC Shreeda 2/05/2017************
*****EOC Def_36 by shreeda 26/5/2017 ----remove opcode 77, 78, 79
* End of change by Twara 12/02/2016
                PERFORM append_final USING lwa_final.
* Begin of change by Twara 12/02/2016
                CLEAR: lwa_final.
* End of change by Twara 12/02/2016
              ENDIF.
              CLEAR : gv_nt_found.
* Begin of change by Twara 12/02/2016
            ENDIF.
          ENDIF.
        ENDIF.
* End of change by Twara 12/02/2016
        FREE : gt_f_code.
      ENDIF.

*Begin of change by Twara 04/01/2016 to process class directly
*==========================
*Check method -> class
*==========================
*      IF lwa_code+0(11) CS 'CALL METHOD'.  "commented
*        PERFORM read_method USING lwa_code
*                                  lv_index.
** Start of addition by manoj on 21/12/2015
*        REFRESH: gt_meth_tab,
*                  gt_sort_m.
** End of addition by manoj on 21/12/2015
*      ENDIF.
*End of change by Twara 04/01/2016 to process class directly

*==========================
*Check if statement used for Aggregation LIKE COLLECT
*==========================
      IF ( lwa_code-text+0(7) = gc_collect ).
        CLEAR lwa_final.
        lwa_final-code      = gv_org_code.
        lwa_final-prog      = gv_prog.
        lwa_final-obj_name  = gs_progname-progname.
        lwa_final-line      = lv_index.
        lwa_final-opercd    = gc_47.
        lwa_final-drill = gv_drill.
        PERFORM append_final USING lwa_final.
        CLEAR lwa_final.
      ENDIF.

*==========================
*  If MACRO - then ignore  the all code inside that
*==========================
      IF lwa_code+0(17) = gc_end_of_def.
        CLEAR lv_flagcs.
      ELSEIF lwa_code+0(6) = gc_define OR lv_flagcs IS NOT INITIAL.
*     begin of code change for Odata_def_24
        IF lwa_code+0(7) NS '_'.
*     end of code change for Odata_def_24
          lv_flagcs = gc_x.
          CONTINUE.
        ENDIF."Odata_def_24
      ENDIF.

*==========================
*  Check for use of OPEN SQL in source code
*==========================
      IF lwa_code+0(8) = gc_exec_sql.
        CLEAR lwa_final.
        lwa_final-code      = gv_org_code.
        lwa_final-prog      = gv_prog.
        lwa_final-obj_name  = gs_progname-progname.
        lwa_final-line      = lv_index.
        lwa_final-opercd    = gc_11.
        lwa_final-drill     = gv_drill.
        PERFORM append_final USING lwa_final.
        CLEAR lwa_final.
      ENDIF.

*==========================
*Check that keyword written inside single quotes
*==========================
      CLEAR gv_check_flag.
      PERFORM get_offset_key_single_quote USING
               lwa_code 'CALL FUNCTION'
               CHANGING gv_check_flag.

*==========================
*Check for FM "DB_EXISTS_INDEX" and "DD_INDEX_NAME" call in source
*==========================
      IF ( lwa_code CS gc_call_func AND
         ( lwa_code CS gc_db_exist_ind OR
         lwa_code CS gc_dd_ind_name )
        AND  gv_check_flag IS INITIAL ) .
        CLEAR : lwa_final.
        lwa_final-code  = gv_org_code.
        lwa_final-prog   = gv_prog.
        lwa_final-obj_name = gs_progname-progname.
        lwa_final-line = lv_index.
        lwa_final-opercd = gc_12.
        lwa_final-drill = gv_drill.
        PERFORM append_final USING lwa_final.
        CLEAR lwa_final.
      ENDIF.

*===============================
* If source code not written inside subroutine then scan source code
*================================
      IF lwa_code+0(4) NE gc_form.
        IF lwa_code+0(7) = gc_endform.
          CLEAR lf_form.
        ENDIF.

*===============================
* Check for Nesting of LOOPS/DO/WHILE
*===============================
        IF gv_drill <= 0.
          CLEAR: gv_drill_max, gv_drill.
        ENDIF.
        CLEAR: lv_str1, lv_str2.
        SPLIT lwa_code AT space INTO lv_str1 lv_str2.

*===============================
* IF LOOPS/DO/WHILE start increase the nesting counter
*===============================
        " start of change: loop and endloop in same line.
        " in this case gv_drill should not increase.
        IF ( lv_str1 = gc_loop OR lv_str1 = gc_do OR  lv_str1 =
        gc_do_dot ).
          REFRESH: lt_drill[].
          CONDENSE lwa_code.
          TRANSLATE lwa_code TO UPPER CASE.
          SPLIT lwa_code AT space INTO TABLE lt_drill.
          REPLACE ALL OCCURRENCES OF gc_dot IN TABLE lt_drill WITH ' '.
          REPLACE ALL OCCURRENCES OF gc_comma IN TABLE lt_drill WITH ' '
          .
          DELETE lt_drill WHERE text = ''.
          CLEAR: lv_eloop_flag.
          READ TABLE lt_drill WITH KEY text = gc_enddo
          TRANSPORTING NO FIELDS.
          IF sy-subrc = 0.
            lv_eloop_flag = gc_x.
          ENDIF.
          READ TABLE lt_drill WITH KEY text = gc_endwhile
          TRANSPORTING NO FIELDS.
          IF sy-subrc = 0.
            lv_eloop_flag = gc_x.
          ENDIF.
          READ TABLE lt_drill WITH KEY text = gc_endloop
           TRANSPORTING NO FIELDS.
          IF sy-subrc = 0.
            lv_eloop_flag = gc_x.
          ENDIF.
        ENDIF.
        " end of change: loop and endloop in same line.

        " start of change: loop and endloop in same line.
*        IF lv_str1 = 'LOOP' OR lv_str1 = 'DO' OR  lv_str1 = 'DO.'
*          OR lv_str1 = 'WHILE'.
        IF ( lv_str1 = gc_loop OR lv_str1 = gc_do OR  lv_str1 =
        gc_do_dot
                  OR lv_str1 = gc_while ) AND lv_eloop_flag = ''.
          " end of change: loop and endloop in same line.

          IF gv_drill = 0 OR gv_loop_line IS INITIAL.
            gv_loop_line = lv_index.
          ENDIF.
          gv_flag = gc_x.
          gv_drill = gv_drill + 1.
          IF gv_drill > gv_drill_max.
            gv_drill_max = gv_drill_max + 1.
          ENDIF.
*===============================
* IF LOOPS/DO/WHILE ends decrease the nesting counter
*===============================
        ELSEIF lv_str1 CS gc_endloop OR lv_str1 CS gc_enddo OR
               lv_str1 CS gc_endwhile.
          gv_drill = gv_drill - 1.
        ENDIF.
        CLEAR: lv_str1, lv_str2.

*===============================
* IF ENDSELECT is used then decrease the nesting counter
*===============================
        IF lwa_code CS gc_endselect.

*Check for the KEYWORD used insdie single quotes
          CLEAR lv_flag_quote.
          PERFORM get_quote_keyword USING lwa_code 'ENDSELECT'
                                    CHANGING lv_flag_quote.
          IF lv_flag_quote = gc_x.
            CONTINUE.
          ENDIF.
          IF gv_drill > 0.
            gv_drill = gv_drill - 1.
          ENDIF.
          CLEAR : lwa_final.
          lwa_final-code  = gv_org_code.
          CLEAR lwa_final.
          CLEAR: gv_exit.
          CLEAR: gv_flag_e.
          CLEAR: lv_flag1.
        ENDIF.

*===============================
* IF Nesting is present then update the detection table
*===============================
        IF gv_drill = 0  AND gv_drill_max > 1.
          CLEAR: lwa_table.
          CLEAR: lwa_final.
          lwa_final-line = gv_loop_line.
          lwa_final-prog = gv_prog.
          lwa_final-obj_name = gs_progname-progname.
          lwa_final-opercd = gc_32.
          lwa_final-drill = gv_drill_max - 1.
          PERFORM get_crit CHANGING lwa_final.
          PERFORM append_final USING  lwa_final.
          CLEAR: lwa_final.
          CLEAR: gv_drill_max, gv_flag, gv_loop_line.
        ENDIF.

*==========================
*Check that keyword written inside single quotes
*==========================
        CLEAR gv_check_flag.
        PERFORM get_offset_key_single_quote USING
                 lwa_code 'INCLUDE'
                 CHANGING gv_check_flag.

*===============================
*IF INCLUDE is used in the source code then scna that include
*==============================
        IF ( lwa_code+0(7) CS gc_include  AND
          gv_check_flag IS INITIAL )  AND
          NOT ( lwa_code CS gc_include_typ OR
                lwa_code CS gc_iclude_struc ).
          FIND gc_dot IN lwa_code MATCH OFFSET lv_col.
          IF sy-subrc = 0.
            lwa_code = lwa_code(lv_col).
            SPLIT lwa_code AT space INTO lv_str1 lv_str2.
            CLEAR lv_str1.

* IF multiple includes are written in the source code and seperated by
* single quotes
            IF lv_str2 CS gc_comma.
              CLEAR lt_includecs.
              SPLIT lv_str2 AT gc_comma INTO TABLE lt_includecs.
              LOOP AT lt_includecs INTO lwa_includecs.
                CONDENSE lwa_includecs-text.
                TRANSLATE  lwa_includecs-text TO UPPER CASE.

*Check added to process only custom program/includes
                IF lwa_includecs-text CS gc_saplz OR  "SAPLZ
                lwa_includecs-text CS gc_saply OR     "SAPLY
                lwa_includecs-text CS gc_sapmz OR     "SAPMZ
                lwa_includecs-text CS gc_sapmy OR     "SAPMY
                lwa_includecs-text+0(2) = gc_lz OR    "LZ
                lwa_includecs-text+0(2) = gc_ly OR    "LY
                lwa_includecs-text+0(2) = gc_mz OR    "MZ
                lwa_includecs-text+0(2) = gc_my OR    "MY
                lwa_includecs-text+0(1) = gc_z OR     "Z
                lwa_includecs-text+0(1) = gc_y OR     "Y
* Begin of change by Rahul 08072015
                lwa_includecs-text+0(3) = gc_mp9 OR
* End of change by Rahul 08072015
               ( lwa_includecs-text IN gr_nspace[]  AND NOT gr_nspace[]
               IS INITIAL ) .  " 29OCT ashish

                  CHECK lwa_includecs-text IS NOT INITIAL.
                  REFRESH lt_code[].
                  lv_include = lwa_includecs-text.
                  CLEAR lv_str2.

*Build global internal table to check include is already processed
                  CLEAR gs_incl_processed.
                  "begin of code change for def_33
*                  READ TABLE gt_incl_processed TRANSPORTING NO FIELDS
*                                      WITH KEY obj_name =
*                                      gs_progname-progname
*                                                   incl = lv_include
*                                                   line = lv_index.
                  READ TABLE gt_incl_processed TRANSPORTING NO FIELDS
                                                  WITH KEY incl = lv_include
                                                  .
*                                                           line = lv_index.
                  "end of code change for def_33
                  IF sy-subrc = 0.
                    CONTINUE.
                  ELSE.
                    gs_incl_processed-obj_name = gs_progname-progname.
                    gs_incl_processed-incl  = lv_include.
                    gs_incl_processed-line = lv_index.
                    APPEND gs_incl_processed TO gt_incl_processed.
                  ENDIF.

*Read the source code of the include
                  READ REPORT lv_include INTO lt_code.
                  IF sy-subrc = 0.
*Handle drill levels in case of different includes
                    CLEAR: gv_drill, gv_drill_max.
                    lf_include = gc_x.
                    CLEAR lv_row.
                    lv_inc = gv_prog.
                    gv_prog = lv_include.
*Scanning the source code of the include

                    PERFORM read_report USING lt_code.
                    CLEAR lv_row.
                    IF lv_inc IS NOT INITIAL AND lv_inc =
                    gs_include-progname.
                      gv_prog = gs_include-progname.
                    ELSEIF lf_include = gc_x.
                      gv_prog = lv_inc.
                    ENDIF.
                  ENDIF.
                ENDIF.
              ENDLOOP.

            ELSE.
*if single include is present in the statement
              REFRESH lt_code[].
              lv_include = lv_str2.
              CLEAR lv_str2.

*Check added to process only custom program/includes
              IF lv_include CS gc_saplz OR
              lv_include CS gc_saply OR
              lv_include CS gc_sapmz OR
              lv_include CS gc_sapmy OR
              lv_include+0(2) = gc_lz OR
              lv_include+0(2) = gc_ly OR
              lv_include+0(2) = gc_mz OR
              lv_include+0(2) = gc_my OR
              lv_include+0(1) = gc_z OR
              lv_include+0(1) = gc_y OR
* Begin of change by Rahul 08072015
              lv_include+0(3) = gc_mp9 OR
* End of change by Rahul 08072015
              ( lv_include IN gr_nspace[] AND
                NOT gr_nspace[] IS INITIAL ) . " 29OCT ashish

*Build global internal table to check include is already processed
                CLEAR gs_incl_processed.
                "begin of code change for def_33
*                READ TABLE gt_incl_processed TRANSPORTING NO FIELDS
*                                    WITH KEY obj_name =
*                                    gs_progname-progname
*                                                 incl = lv_include
*                                                 line = lv_index.
                READ TABLE gt_incl_processed TRANSPORTING NO FIELDS
                                                WITH KEY incl = lv_include.
*                                               line = lv_index.
                "end of code change for def_33
                IF sy-subrc = 0.
                  CONTINUE.
                ELSE.
                  gs_incl_processed-obj_name = gs_progname-progname.
                  gs_incl_processed-incl  = lv_include.
                  gs_incl_processed-line = lv_index.
                  APPEND gs_incl_processed TO gt_incl_processed.
                ENDIF.

*Read the source code of the include
                READ REPORT lv_include INTO lt_code.
                IF sy-subrc = 0.
*Handle drill levels in case of different includes
                  CLEAR: gv_drill, gv_drill_max.
                  lf_include = gc_x.
                  CLEAR lv_row.
                  lv_inc = gv_prog.
                  gv_prog = lv_include.
                  PERFORM read_report USING lt_code.
                  CLEAR lv_row.
                  IF lv_inc IS NOT INITIAL AND lv_inc =
                  gs_include-progname.
                    gv_prog = gs_include-progname.
                  ELSEIF lf_include = gc_x.
                    gv_prog = lv_inc.
                  ENDIF.
                ENDIF.
              ENDIF.
            ENDIF.
          ENDIF.
        ENDIF.

*==========================
*Rearrange the SELECT statament if it contains JOINS
*==========================
        IF ( lwa_code+0(6) = gc_select OR lwa_code+0(8) = gc_select_str
        )
          AND lwa_code CS gc_join_spc.
          CLEAR gv_codenew.
          PERFORM check_into USING lwa_code
                             CHANGING lwa_slct
                                      gv_codenew .
          lwa_code = lwa_slct.
        ENDIF.

*=================================
*Process the SELECT statement and update detection table
*==================================
        IF lwa_code+0(7) = gc_select_spc OR
           lwa_code+0(11)  = gc_op_cursor.
* start of new logic for SORT
*      perform get_sel_sort using p_code
*                                 lwa_code
*                                 lv_index.
* end of new logic for SORT
*start of change by ashish on 15Oct -- add selection by statement ---
*SELECT SINGLE FOR UPDATE
*        IF lwa_code CS 'SELECT *' OR lwa_code CS 'SELECT SINGLE *' .
          IF lwa_code CS gc_select_str OR lwa_code CS gc_select_sing_str
*Start of changes Def_18 in 2/09/2017
*             OR lwa_code CS gc_sel_sing_updt . " Navneet
             OR lwa_code CS gc_sel_sing_updt OR lwa_code CS 'SELECT SINGLE'.
*End of changes Def_18 in 2/09/2017

*end of change by ashish on 15Oct -- add selection by statement ---
*SELECT SINGLE FOR UPDATE
            PERFORM get_sel_star USING p_code
                                      lwa_code
                                      lv_index
                                 CHANGING gt_intab.
          ENDIF.

          PERFORM get_db_hits USING lwa_code
                                    lv_index
                              CHANGING gt_table
                                lv_flag1.

        ENDIF.

*==========================================
*Check for SORT KEYWORD used in statement
*==========================================
        IF lwa_code+0(4) CS gc_sort.
* start of new logic for SORT
*    PERFORM check_sort USING lwa_code
*                                   lv_index.

          PERFORM find_sort USING lwa_code
                                         lv_index.
* end of new logic for SORT
        ENDIF.

*==========================================
*Check for Use of CURRENCY conversion and DELETE ADJACENT DUPLICATES
* without sorting
*==========================================
        IF lwa_code CS gc_del_adj_dup
        OR ( lwa_code CS gc_call_func AND lwa_code CS gc_curr ).
          PERFORM f_statement USING p_code
                                    lwa_code
                                    lv_index
                                    start_line.

        ENDIF.

        IF ( gv_drill > 0 ) .
*==========================================
*To Trace the UPDATE/DELETE/INSERT/CHECK/EXIT Statement inside loop
*==========================================
          IF (  lwa_code-text+0(7) EQ gc_update_spc
            OR ( lwa_code-text+0(7) EQ gc_modify_spc AND
            NOT ( lwa_code-text CS gc_modify_line OR
                  lwa_code-text CS gc_modify_screen ) )
            OR lwa_code-text+0(7)  EQ gc_insert_spc
            OR lwa_code-text+0(7)  EQ gc_delete_spc
            OR lwa_code-text+0(5)  EQ gc_check
            OR lwa_code-text+0(4)  EQ gc_exit
            ).
            PERFORM f_scan_statement USING lwa_code
                                           lv_index.

*==========================================
*To Trace the BAPI, FM  Used inside the various Loops
*==========================================
          ELSEIF ( lwa_code+0(13) CS gc_call_func
              OR ( lwa_code+0(13) CS gc_call_func AND
                   lwa_code CS gc_bapi ) ).
            PERFORM f_scan_bapi USING lwa_code
                                      lv_index.

*==========================================
*To trace the Control Statements use inside the various Loops
*==========================================
          ELSEIF ( lwa_code CS gc_at_new ) OR
                 ( lwa_code CS gc_at_first )
              OR ( lwa_code CS gc_at_endof ) OR
                 ( lwa_code CS gc_at_last )
              OR ( lwa_code CS gc_on_changeof ).
            PERFORM f_scan_control  USING lwa_code
                                      lv_index.
* Start of addition by Manoj on 23/12/2015
            " - control statements in unsorted internal tables
            PERFORM f_ctrl_in_unsorted_itabs_main USING p_code
                                                    lv_line_code
                                                    lv_index.
* End of addition by Manoj on 23/12/2015
            " - control statements in unsorted internal tables
          ENDIF.
        ENDIF.

*==============================
*Process the subroutine source code
*==============================
        IF lwa_code+0(7) = gc_perform.
*          start of change def_21 on 16-02-2016
          IF lwa_code CS '(' AND lwa_code CS ')' .
          ELSE.
*          end of change def_21 on 16-02-2016
            SPLIT lwa_code AT space INTO gv_per_rec1
            gv_per_rec2 gv_per_rec3 .
            CONCATENATE gc_form gv_per_rec2 INTO
             gv_per_rec2 SEPARATED BY space.
            REPLACE ALL OCCURRENCES OF gc_dot IN gv_per_rec2 WITH space.
            CONDENSE gv_per_rec2.
            CLEAR : gv_per_rec ,gv_per_rec1 ,gv_per_rec2 ,gv_per_rec3.
            gv_perform = gc_x.
            gv_prog99 = gv_prog.
            PERFORM f_process_perform USING p_code
                                            lwa_code lv_index.
*{ Begin of change by Rohit - 16/12/2015
            REFRESH: gt_sort_f,
                     gt_form_tab.
*} End of change by Rohit - 16/12/2015
            gv_prog = gv_prog99.
          ENDIF.
*Start of change DEF_21 on 16/02/2017
        ENDIF.
*End of change for def_21 on 16/02/2017
*======================================================
* Detection for DELETE/UPDATE/INSERT/MODIFY for Table POOL/CLUSTER
*======================================================
***Begin of changes by Manoj on 15/12/2015
*   for DB operations on POOL/CLUSTER tables
        PERFORM f_detect_pool_cluster_db_ops
                    USING lv_line_code lv_index.
***End of changes by Manoj on 15/12/2015
*  for DB operations on POOL/CLUSTER tables
*======================================================
* Detection for ADBC
*======================================================
***Begin of changes by Manoj on 30/12/2015
        PERFORM f_detect_adbc
                    USING lv_line_code lv_index.
***End of changes by Manoj on 30/12/2015

      ELSE.
        lf_form = gc_x.
* Store the form into memory, so that we can trace back the forms
*which are not called from the program

*        lv_subroutine = lwa_code+3.
        CLEAR: lv_str1, lv_subroutine, lv_str2.
        SPLIT lwa_code AT space INTO lv_str1 lv_subroutine lv_str2 .
        CONCATENATE lv_str1 lv_subroutine INTO lv_subroutine
        SEPARATED BY space.
        CONDENSE lv_subroutine.
        IF sy-subrc = 0 .
          ls_form_processed-obj_name = gs_progname-progname.
          ls_form_processed-form  = lv_subroutine.
          ls_form_processed-line = lv_index.
          ls_form_processed-done = ''. " to mark as not done yet.
          CONCATENATE 'PER' lwa_code INTO  ls_form_processed-text.
          APPEND ls_form_processed TO gt_form_processed.
        ENDIF.

      ENDIF.
      CLEAR: lv_str1, lv_subroutine, lv_str2.
      "begin of code change for Odata_def_24.
      IF lv_odata EQ 'X'.
        IF lo_cl_odata IS NOT INITIAL.
*          IF lv_line_code CS 'GET_ENTITYSET'.
*            lv_case = lc_1.
*          ELSEIF lv_line_code CS 'ENTITYSET'.
*            lv_case = lc_2.
*          ENDIF.
          CALL METHOD lo_cl_odata->get_case
            EXPORTING
              i_code = lv_line_code
            IMPORTING
              e_case = lv_case.

          CALL METHOD lo_cl_odata->check_odata_opcodes
            EXPORTING
              i_code     = lv_line_code
              i_case     = lv_case
            IMPORTING
              e_opcode62 = lv_opcode62
              e_opcode63 = lv_opcode63
              e_opcode64 = lv_opcode64
              e_opcode65 = lv_opcode65
              e_opcode66 = lv_opcode66.

          IF lv_mpc IS INITIAL OR lv_mpc_ext IS INITIAL.
            CALL METHOD lo_cl_odata->is_class_found
              EXPORTING
                i_class   = ls_include-mainprog
              IMPORTING
                e_mpc     = lv_mpc
                e_mpc_ext = lv_mpc_ext.
          ENDIF.

          IF lv_mpc IS NOT INITIAL OR lv_mpc_ext IS NOT INITIAL.
            CALL METHOD lo_cl_odata->get_mpc_logic
              EXPORTING
                i_code  = lv_line_code
                i_index = lv_index
*             IMPORTING
*               e_tab   = lt_tab.
              .
          ENDIF.
        ENDIF.
      ENDIF.
      "End of code change for Odata_def_24.
    ENDLOOP.

    "begin of code change for Odata_def_24
    IF lv_odata EQ 'X' AND ( lv_case EQ '1' OR lv_case EQ '2').
      CLEAR lwa_final.
      IF lv_opcode62  IS INITIAL.
        lwa_final-opercd  = lc_62.
        lwa_final-prog    = gs_progname-progname.
        PERFORM append_final USING  lwa_final.
        CLEAR lwa_final.
      ENDIF.

      IF lv_opcode63  IS INITIAL AND lv_opcode64 IS INITIAL.
        lwa_final-opercd  = lc_63.
        lwa_final-prog    = gs_progname-progname.
        PERFORM append_final USING  lwa_final.
        CLEAR lwa_final.
      ENDIF.

      IF lv_opcode64  IS INITIAL AND lv_opcode63 IS INITIAL.
        lwa_final-opercd  = lc_64.
        lwa_final-prog    = gs_progname-progname.
        PERFORM append_final USING  lwa_final.
        CLEAR lwa_final.
      ENDIF.

      IF lv_opcode65  IS INITIAL.
        lwa_final-opercd  = lc_65.
        lwa_final-prog    = gs_progname-progname.
        PERFORM append_final USING  lwa_final.
        CLEAR lwa_final.
      ENDIF.

      IF lv_opcode66  IS INITIAL AND lv_case EQ '2'.
        lwa_final-opercd  = lc_66.
        lwa_final-prog    = gs_progname-progname.
        PERFORM append_final USING  lwa_final.
        CLEAR lwa_final.
      ENDIF.
      CLEAR lwa_final.
    ELSEIF lv_odata EQ 'X' AND lv_case EQ '3'.
      IF lv_opcode66  IS INITIAL.
        lwa_final-opercd  = lc_66.
        lwa_final-prog    = gs_progname-progname.
        PERFORM append_final USING  lwa_final.
      ENDIF.
      CLEAR lwa_final.
    ENDIF.

    IF lv_mpc IS NOT INITIAL OR lv_mpc_ext IS NOT INITIAL.
      CLEAR   : lv_error,lv_count,ls_temp.
      REFRESH : lt_temp.
      IF lo_cl_odata->lt_mpc IS NOT INITIAL.
        lt_temp = lo_cl_odata->lt_mpc.
      ENDIF.
      "check for number of times create property statement is called.
      LOOP AT lo_cl_odata->lt_mpc INTO lo_cl_odata->ls_mpc WHERE done IS INITIAL.
        "  AND done IS INITIAL.
        SPLIT lo_cl_odata->ls_mpc-error AT '|' INTO lv_error1 lv_error2.
        IF lv_error2 EQ 'COUNT'.
          lwa_final-opercd  = lc_71.
          lwa_final-prog    = ls_include-progname.
          lwa_final-line    = lo_cl_odata->ls_mpc-line_no.
          lwa_final-code    = lo_cl_odata->ls_mpc-code.
*          lwa_final-select_line    = lo_cl_odata->ls_mpc-edm_field. "Added by Akshay_Def_24
          lo_cl_odata->ls_mpc-done = abap_true.
          MODIFY lo_cl_odata->lt_mpc FROM lo_cl_odata->ls_mpc INDEX sy-tabix.
          PERFORM append_final USING  lwa_final.
          CLEAR lwa_final.
        ENDIF.
        IF lv_error1 EQ 'SET_LABEL'.
          lwa_final-opercd  = lc_72.
          lwa_final-prog    = ls_include-progname.
*          lwa_final-line    = lo_cl_odata->ls_mpc-line_no.
*          lwa_final-code    = lo_cl_odata->ls_mpc-code.
*          lwa_final-select_line    = lo_cl_odata->ls_mpc-edm_field. "Added by Akshay_Def_24
          lo_cl_odata->ls_mpc-done = abap_true.
          MODIFY lo_cl_odata->lt_mpc FROM lo_cl_odata->ls_mpc INDEX sy-tabix.
          PERFORM append_final USING  lwa_final.
          CLEAR lwa_final.
        ENDIF.
        "Check for camel case
        IF lo_cl_odata->ls_mpc-fieldname IS NOT INITIAL AND lo_cl_odata->ls_mpc-done IS INITIAL.
          CLEAR : lv_error,lv_count.
          CALL METHOD lo_cl_odata->check_camel_case
            EXPORTING
              i_field = lo_cl_odata->ls_mpc-fieldname
            IMPORTING
              e_error = lv_error.
          lo_cl_odata->ls_mpc-done = abap_true.
          MODIFY lo_cl_odata->lt_mpc FROM lo_cl_odata->ls_mpc INDEX sy-tabix.
          IF lv_error IS NOT INITIAL.
            lwa_final-opercd  = lc_73.
            lwa_final-prog    = ls_include-progname.
            lwa_final-code    = lo_cl_odata->ls_mpc-code.
             lwa_final-select_line    = lo_cl_odata->ls_mpc-fieldname. "Added by Akshay_Def_24
            PERFORM append_final USING  lwa_final.
            CLEAR lwa_final.
          ENDIF.
        ENDIF.

        "check for EDM Type's
        IF lo_cl_odata->ls_mpc-sub_method CS lc_edm.
          READ TABLE lt_temp INTO ls_temp WITH KEY parent_method  = lo_cl_odata->ls_mpc-parent_method
                                                    sub_method    = lc_bind_struc.
          IF sy-subrc EQ 0.
            IF ls_temp-structure CS lc_inst. " if it contains '=>' , no need to scan as it denotes a local structure.
              lo_cl_odata->ls_mpc-done = abap_true.
              MODIFY lo_cl_odata->lt_mpc FROM lo_cl_odata->ls_mpc INDEX sy-tabix.
              CONTINUE.
            ELSE.
              "replace colons from structure name
              REPLACE ALL OCCURRENCES OF lc_colon IN ls_temp-structure WITH space.
              CONDENSE ls_temp-structure.
              "replace colons from field name
*              REPLACE ALL OCCURRENCES OF lc_colon IN lo_cl_odata->ls_mpc-fieldname WITH space.
*              CONDENSE lo_cl_odata->ls_mpc-fieldname.
              CALL FUNCTION 'DDIF_FIELDINFO_GET'
                EXPORTING
                  tabname        = ls_temp-structure
*                 FIELDNAME      = ' '
                  langu          = sy-langu
                  lfieldname     = lo_cl_odata->ls_mpc-edm_field
                IMPORTING
                  dfies_wa       = lwa_dfies
                EXCEPTIONS
                  not_found      = 1
                  internal_error = 2
                  OTHERS         = 3.
              IF sy-subrc <> 0.
* Implement suitable error handling here
              ELSE.
                CALL METHOD lo_cl_odata->check_edm_type
                  EXPORTING
                    p_kind    = lwa_dfies-inttype
                    p_dfies   = lwa_dfies
                  IMPORTING
                    e_edm_typ = lv_edm_typ.
                IF lv_edm_typ IS NOT INITIAL.
                  TRANSLATE lv_edm_typ TO UPPER CASE.
                  SPLIT lo_cl_odata->ls_mpc-sub_method AT lc_us INTO lv_string1 lv_string2 lv_string3 lv_string4.
                  CONCATENATE lv_string3 '.' lv_string4 INTO lv_edm.
                  IF lv_edm_typ NE lv_edm .
                    lo_cl_odata->ls_mpc-done = abap_true.
                    MODIFY lo_cl_odata->lt_mpc FROM lo_cl_odata->ls_mpc INDEX sy-tabix.
                    lwa_final-opercd  = lc_74.
                    lwa_final-prog    = ls_include-progname.
                    lwa_final-code    = lo_cl_odata->ls_mpc-code.
                    lwa_final-select_line    = lo_cl_odata->ls_mpc-edm_field. "Added by Akshay_Def_24
                    PERFORM append_final USING  lwa_final.
                    CLEAR lwa_final.
                  ELSE.
                    lo_cl_odata->ls_mpc-done = abap_true.
                    MODIFY lo_cl_odata->lt_mpc FROM lo_cl_odata->ls_mpc INDEX sy-tabix.
                  ENDIF.
                ELSE.
                  lo_cl_odata->ls_mpc-done = abap_true.
                  MODIFY lo_cl_odata->lt_mpc FROM lo_cl_odata->ls_mpc INDEX sy-tabix.
                ENDIF.
              ENDIF.
            ENDIF.
          ENDIF.
        ENDIF.
      ENDLOOP.
      REFRESH : lo_cl_odata->lt_mpc.
    ENDIF.
    "end of code change for Odata_def_24

*  MS++ 24-Sept
* Process stand alone Forms..
*
    LOOP AT gt_form_processed INTO ls_form_processed
      WHERE done IS INITIAL.

*          SPLIT lwa_code AT space INTO gv_per_rec1
*          gv_per_rec2 gv_per_rec3 .
*          CONCATENATE 'FORM' ls_form_processed-form  INTO
*           gv_per_rec2 SEPARATED BY space.
*          REPLACE ALL OCCURRENCES OF '.' IN gv_per_rec2 WITH space.
*          CONDENSE gv_per_rec2.
      CLEAR : gv_per_rec ,gv_per_rec1 ,gv_per_rec2 ,gv_per_rec3.
      gv_perform = gc_x.
      gv_prog99 = gv_prog.
      CLEAR lf_form .
      PERFORM f_process_perform USING p_code
                                      ls_form_processed-text
                                      ls_form_processed-line.
*{ Begin of change by Rohit - 16/12/2015
      REFRESH: gt_sort_f,
               gt_form_tab.
*} End of change by Rohit - 16/12/2015
      gv_prog = gv_prog99.

      ls_form_processed-done = gc_x.
      MODIFY gt_form_processed FROM ls_form_processed TRANSPORTING done.
    ENDLOOP.

*  MS--   24-Sept

*==============================
*???????????????????????
*==============================

    CLEAR lv_col.
    CLEAR lv_row.
*    IF gt_table IS NOT INITIAL.
*
*      LOOP AT gt_table INTO lwa_table.
*        TRANSLATE:  lwa_table-progname TO UPPER CASE.
*        TRANSLATE lwa_table-table TO UPPER CASE.
*        TRANSLATE lwa_table-join TO UPPER CASE.
*
*        IF lwa_table-line = lv_row.
*          IF lv_str1 IS INITIAL.
*            lv_col = sy-tabix - 1.
*            READ TABLE gt_table INTO lwa_table1 INDEX lv_col.
*            IF sy-subrc = 0 AND lwa_table-join IS NOT INITIAL.
*              CONCATENATE lwa_table-join 'JOIN on tables'
*              lwa_table-table '&' lwa_table1-table
*              INTO lv_str1 SEPARATED BY space.
*            ENDIF.
*          ELSE.
*            CONCATENATE lv_str1 '&' lwa_table-table
*            INTO lv_str1 SEPARATED
*            BY space.
*            lv_line = lv_line + 1.
*          ENDIF.
*
*        ELSE.
*          IF lv_str1 IS NOT INITIAL.
*            CLEAR lwa_final.
*            lwa_final-prog = gv_prog.
*            lwa_final-opercd = gc_39.
*            lwa_final-table = lwa_table-table.
*            lwa_final-drill = gv_drill.
** find table type : transparent, pool or cluster
*            lv_table = lwa_table-table .
*            SELECT  SINGLE tabclass FROM dd02l INTO l_tabclass WHERE
*            tabname = lv_table  AND as4local = 'A' .
*            IF sy-subrc = 0.
*              lwa_final-type = l_tabclass.
*              CLEAR: l_tabclass.
*            ENDIF.
*            lwa_final-check = lv_str1.
*            lwa_final-line = lv_row.
*            IF lv_line GT 1.
*              lwa_final-critical = 'HIGH'.
*            ELSE.
*              lwa_final-critical = 'MEDIUM'.
*            ENDIF.
*            lwa_final-obj_name = gs_progname-progname.
*            PERFORM append_final USING  lwa_final.
*            CLEAR: lwa_final.
*          ENDIF.
*          lv_row = lwa_table-line.
*          CLEAR lv_str1.
*        ENDIF.
*      ENDLOOP.
*
*      SORT gt_table BY table.
*    ENDIF.

*==============================
*Check for repetative hits of table on database
*==============================
    LOOP AT gt_table INTO lwa_table.
      TRANSLATE:  lwa_table-progname TO UPPER CASE.
      TRANSLATE lwa_table-table TO UPPER CASE.
      TRANSLATE lwa_table-join TO UPPER CASE.

      IF lwa_table-table = lv_str1.
        IF sy-tabix GE 1.
          lv_col = sy-tabix - 1.
          DELETE gt_table INDEX sy-tabix.
          READ TABLE gt_table INTO lwa_table INDEX lv_col.
          lwa_table-count = lwa_table-count + 1.
        ENDIF.
      ELSE.
        lwa_table-count = 1.
        lv_str1 = lwa_table-table.
      ENDIF.
      CHECK sy-tabix > 0.
      MODIFY gt_table FROM lwa_table INDEX sy-tabix TRANSPORTING count.
    ENDLOOP.



    DATA: lt_dd02l_table  TYPE STANDARD TABLE OF ty_tab,
          ls_dd02l_table  TYPE ty_tab,
          lt_dd02l_db_hit TYPE STANDARD TABLE OF ty_dd02l,
          ls_dd02l_db_hit TYPE ty_dd02l.

    lt_dd02l_table = gt_table.
    SORT lt_dd02l_table BY table.
    DELETE ADJACENT DUPLICATES FROM lt_dd02l_table COMPARING table.
    IF lt_dd02l_table IS NOT INITIAL.
      SELECT tabname tabclass INTO TABLE lt_dd02l_db_hit
                              FROM dd02l
                              FOR ALL ENTRIES IN lt_dd02l_table
                              WHERE tabname = lt_dd02l_table-table AND
                                    as4local = gc_a.
      IF sy-subrc = 0.
        SORT lt_dd02l_db_hit BY tabname.
      ENDIF.
    ENDIF.

    LOOP AT gt_table INTO lwa_table WHERE count GT 1.
      TRANSLATE:  lwa_table-progname TO UPPER CASE.
      TRANSLATE lwa_table-table TO UPPER CASE.
      TRANSLATE lwa_table-join TO UPPER CASE.
      IF  lwa_table-progname = gv_prog OR gv_perform = gc_x.
        CLEAR: lwa_final.

        lv_str2 = lwa_table-count.
        CONCATENATE 'Database hit' lv_str2 'times on table'
        lwa_table-table INTO lv_str1 SEPARATED BY space.
        IF gv_perform = gc_x.
          lwa_final-prog = lwa_table-progname.
        ELSE.
          lwa_final-prog = gv_prog.
        ENDIF.
        lwa_final-opercd = gc_38.
        lwa_final-table = lwa_table-table.
* find table type : transparent, pool or cluster
        lv_table = lwa_table-table .
*        SELECT  SINGLE tabclass FROM dd02l INTO l_tabclass
*          WHERE tabname = lv_table  AND as4local = gc_a .
        READ TABLE lt_dd02l_db_hit INTO ls_dd02l_db_hit
                                   WITH KEY tabname = lwa_table-table
                                   BINARY SEARCH.
        IF sy-subrc = 0.
*          lwa_final-type = l_tabclass.
          lwa_final-type = ls_dd02l_db_hit-tabclass.
          CLEAR: l_tabclass.
        ENDIF.
        lwa_final-check = lv_str1.
        lwa_final-line = lwa_table-line.
        IF lwa_table-count = 2.
          lwa_final-critical = gc_low.
        ELSEIF lwa_table-count = 3.
          lwa_final-critical = gc_medium.
        ELSEIF lwa_table-count GT 3.
          lwa_final-critical = gc_high.
        ENDIF.
        lwa_final-drill = gc_zero. " drill level at db hit
        lwa_final-obj_name = gs_progname-progname.
*start of change by ashish 24sep - code field should be empty in case -
*added on 06th OCT to keep append_final simple
*of database hit
        IF lwa_final-check CS 'database hit'.
          CLEAR: lwa_final-code.
        ENDIF.
*end of change by ashish 24sep - code field should be empty in case of
*database hit
        PERFORM append_final USING  lwa_final.
        CLEAR: lwa_final.
        CLEAR: lv_str2, lwa_table, lwa_final, gv_codenew.
      ENDIF.
    ENDLOOP.
    IF sy-subrc = 0.
      CLEAR : gv_perform.
    ENDIF.

*==============================
*Check for use of LDB in the program
*==============================
    CLEAR : gs_ldb, lv_ldb2.
    REPLACE ALL OCCURRENCES OF gc_d$s IN TABLE gt_ldb WITH ' '
    IN CHARACTER MODE.
    DELETE gt_ldb WHERE  ldbname = ''.

    LOOP AT gt_ldb INTO gs_ldb.

      CONCATENATE 'LDB NAME IS' gs_ldb-ldbname
      INTO lv_ldb2 SEPARATED BY space.

      CLEAR lwa_final.
      lwa_final-prog     = gs_ldb-progname.
      lwa_final-obj_name = gs_progname-progname.
      lwa_final-check    = lv_ldb2.
      lwa_final-opercd   = gc_54.
      lwa_final-drill    = ''.
      lwa_final-obj_name = gs_progname-progname.
      PERFORM append_final USING lwa_final.
      CLEAR: lwa_final, lv_ldb2.
    ENDLOOP.
    CLEAR: gt_ldb.

*Catch system exceptions
  ENDCATCH.
  IF sy-subrc <> 0.
    WRITE:/ gc_error ,'Error code:', sy-subrc , '=>Perform READ_REPORT'.
  ENDIF.
*Catch system exceptions

ENDFORM.                    " READ_REPORT

*&---------------------------------------------------------------------*
*&      Form  GET_LINE
*&---------------------------------------------------------------------*
*       Build the Whole Statement if break into multiple lines
*----------------------------------------------------------------------*
*      -->P_CODE1  Current line source code
*      -->P_INDEX  Current line
*      <--P_STR1   Whole statement source code
*      <--P_ROW    Last line index during building of whole statement
*----------------------------------------------------------------------*
FORM get_line  USING  p_code1 LIKE gt_code
                      p_index
               CHANGING p_str1
                        p_row.

*Catch system exceptions
  CATCH SYSTEM-EXCEPTIONS arithmetic_errors             = 1
                          create_data_errors            = 2
                          conversion_errors             = 3
                          create_object_errors          = 4
                          data_access_errors            = 5
                          assign_casting_illegal_cast   = 6
                          assign_casting_unknown_type   = 7
                          assign_field_not_in_range     = 8
                          data_offset_too_large         = 9
                          dyn_call_meth_not_implemented = 10
                          export_buffer_no_memory       = 11
                          generate_subpool_dir_full     = 12
                          move_cast_error               = 13
                          perform_program_name_too_long = 14
                          replace_infinite_loop         = 15
                          remote_call_errors            = 16
                          localization_errors           = 17
                          import_mismatch_errors        = 18
                          dynamic_call_method_errors    = 19
                          file_access_errors            = 20
                          OTHERS                        = 99.
*Catch system exceptions

    DATA: lwa_code TYPE ty_code,
          lv_str   TYPE string.
    DATA: lv_sq TYPE string VALUE ''''.
    DATA: lv_dq TYPE string VALUE gc_doub_quote.
    DATA: var_count  TYPE i,
          var_count2 TYPE i.
*{ Begin of change by Rohit - 02/06/2016
    DATA: lv_f1 TYPE sy-tabix,
          lv_f2 TYPE sy-tabix,
          lv_f3 TYPE sy-tabix,
          lv_f4 TYPE sy-tabix,
          lv_f5 TYPE sy-tabix.
*} End of change by Rohit - 02/06/2016
    CONCATENATE lv_sq lv_dq INTO lv_sq.
    CONDENSE lv_sq.

    LOOP AT p_code1 INTO lwa_code FROM p_index.
      p_row = sy-tabix.

*Translate to upper case
      TRANSLATE lwa_code TO UPPER CASE.
*Remove the commented code
      IF lwa_code CS gc_doub_quote AND lwa_code NS lv_sq.
*==========================
*Check that keyword written inside single quotes
*==========================
        CLEAR gv_check_flag.
*{ Begin of change by Rohit - 02/06/2016
*        PERFORM get_offset_key_single_quote USING
*                 lwa_code '"'
*                 CHANGING gv_check_flag.
        "/ Will remove double code comments from statement
        "/ Example: where belnr = 'asd"' " ''''
        "/          SELECT * FROM bseg "test
        CLEAR: lv_f1, lv_f2, lv_f3, lv_f4.
        FIND FIRST OCCURRENCE OF '"' IN lwa_code
             MATCH OFFSET lv_f1 .
        FIND FIRST OCCURRENCE OF '''' IN lwa_code
        MATCH OFFSET lv_f2 .
        IF NOT lv_f2 IS INITIAL.
          lv_f3 = lv_f2 + 1.
          FIND '''' IN SECTION OFFSET lv_f3 OF
          lwa_code
          MATCH OFFSET lv_f4.
        ENDIF.
        IF  lv_f1 > lv_f2 AND lv_f1 < lv_f4
        AND NOT lv_f2 IS INITIAL
        AND NOT lv_f4 IS INITIAL
        AND NOT lv_f3 IS INITIAL.
          CLEAR lv_f3.
          lv_f3 = lv_f1 + 1.
          FIND '"' IN SECTION OFFSET lv_f3 OF
          lwa_code
          MATCH OFFSET lv_f5.
          IF NOT lv_f5 IS INITIAL.
            IF lv_f5 > lv_f4.
              SPLIT lwa_code AT lwa_code+lv_f5(3)
              INTO  lwa_code lv_str.
            ENDIF.
          ELSE.
          ENDIF.
        ELSE.
*        IF gv_check_flag IS INITIAL.
          SPLIT lwa_code AT gc_doub_quote INTO lwa_code lv_str.
          CLEAR lv_str.
*        ENDIF.
        ENDIF.
*} End of change by Rohit - 02/06/2016
        CLEAR gv_check_flag.
      ENDIF.
*Ignore the line which start with * or double quotes
      IF lwa_code+0(1) EQ gc_doub_quote OR  lwa_code+0(1) = gc_star
        OR lwa_code IS INITIAL.
        CONTINUE.
      ENDIF.

      CONCATENATE p_str1 lwa_code INTO p_str1 SEPARATED BY space.

      var_count = strlen( lwa_code-text ).
      var_count2 = var_count - 1.
      IF lwa_code-text+var_count2(var_count) = gc_dot.
        EXIT.
      ENDIF.
    ENDLOOP.

    CONDENSE p_str1.

*Catch system exceptions
  ENDCATCH.
  IF sy-subrc <> 0.
    WRITE:/ gc_error ,'Error code:', sy-subrc , '=>Perform GET_LINE'.
  ENDIF.
*Catch system exceptions
ENDFORM.                    " GET_LINE

**Begin of change by priyanka Def_5
FORM descr_table_stat USING p_wa_code     LIKE LINE OF gt_code
                      CHANGING p_descr.

  TYPES: BEGIN OF lty_descr,
           descr_tab TYPE string,
           int_tab   TYPE string,
           var       TYPE string,
         END OF lty_descr,

         BEGIN OF lty_temp,
           text(1000),
         END OF lty_temp.

*        ty_tt_descr TYPE STANDARD TABLE OF lty_descr.

  DATA: lwa_code   TYPE ty_code,
        lt_temp1   TYPE STANDARD TABLE OF lty_temp,
        lwa_temp   TYPE lty_temp,
        lt_descr   TYPE STANDARD TABLE OF lty_descr,
        lwa_descr  TYPE lty_descr,
        lv_int_tab TYPE string,
        lv_var     TYPE string.

  lwa_code = p_wa_code.
  lt_descr =  p_descr.
*  LOOP AT p_code2 INTO lwa_code.
*    TRANSLATE lwa_code TO UPPER CASE.

*      CONDENSE lwa_code.
*      IF lwa_code = '' OR lwa_code+0(1) = gc_star OR
*      lwa_code+0(1) = gc_doub_quote.
*        CONTINUE.
*      ENDIF.

  IF lwa_code CS 'DESCRIBE TABLE'.
    SPLIT lwa_code AT space INTO TABLE lt_temp1.
    DELETE lt_temp1 WHERE text IS INITIAL.
    READ TABLE lt_temp1 INTO lwa_temp INDEX 3.
    IF sy-subrc EQ 0.
      lv_int_tab = lwa_temp-text.
      REPLACE ALL OCCURRENCES OF '.' IN lv_int_tab WITH space.
      CONDENSE lv_int_tab.
    ENDIF.

    READ TABLE lt_temp1 INTO lwa_temp INDEX 5.
    IF sy-subrc EQ 0.
      lv_var = lwa_temp-text.
      REPLACE ALL OCCURRENCES OF '.' IN lv_var WITH space.
      CONDENSE lv_var.
    ENDIF.
    lwa_descr-descr_tab = 'DESCRIBE TABLE'.
    lwa_descr-int_tab   = lv_int_tab.
    lwa_descr-var       = lv_var.
    APPEND lwa_descr TO lt_descr.
    CLEAR: lwa_descr,
           lv_int_tab,
           lv_var.
  ENDIF.

*  ENDLOOP.
  p_descr = lt_descr.
ENDFORM.                    "descr_table_stat
**End of change by Priyanka Def_5

*&---------------------------------------------------------------------*
*&      Form  GET_DB_HITS
*&---------------------------------------------------------------------*
* Process various checks for the SELECT statement
*----------------------------------------------------------------------*
*      -->P_CODE    Whole select statement
*      -->P_INDEX   Current line number
*      <--PT_TABLE  Fill global table for further processing
*      <--LU_FLAG   Flag
*----------------------------------------------------------------------*
FORM get_db_hits  USING  VALUE(pwa_code)
                           p_index
                  CHANGING pt_table LIKE gt_table
                            lu_flag.


*Catch system exceptions
  CATCH SYSTEM-EXCEPTIONS arithmetic_errors             = 1
                          create_data_errors            = 2
                          conversion_errors             = 3
                          create_object_errors          = 4
                          data_access_errors            = 5
                          assign_casting_illegal_cast   = 6
                          assign_casting_unknown_type   = 7
                          assign_field_not_in_range     = 8
                          data_offset_too_large         = 9
                          dyn_call_meth_not_implemented = 10
                          export_buffer_no_memory       = 11
                          generate_subpool_dir_full     = 12
                          move_cast_error               = 13
                          perform_program_name_too_long = 14
                          replace_infinite_loop         = 15
                          remote_call_errors            = 16
                          localization_errors           = 17
                          import_mismatch_errors        = 18
                          dynamic_call_method_errors    = 19
                          file_access_errors            = 20
                          OTHERS                        = 99.
*Catch system exceptions

    TYPES: BEGIN OF tt_tabkey,
             fieldname TYPE dd03l-fieldname,
             position  TYPE dd03l-position,
           END OF tt_tabkey,

           BEGIN OF ty_tabsiz,
             table     TYPE ddobjname,
             tabkat(2) TYPE c,
           END OF ty_tabsiz.

    DATA: lv_str1   TYPE          string,
          lv_str2   TYPE          string,
          lv_str3   TYPE          string,
          lwa_tab3  TYPE          ty_tab,
          lv_row1   TYPE          i,
          lwa_code1 TYPE          ty_code,
          lv_countc TYPE          i,
          lv_chkflg TYPE          c,
          lv_index  TYPE          sy-tabix,
          lwa_tab2  TYPE          ty_code,
          lwa_table TYPE          ty_tab,
          lwa_tab4  TYPE          ty_code,
          lwa_tabj  TYPE          ty_code,
          lv_flag   TYPE          flag,
          lt_tab1   TYPE TABLE OF ty_code,
          lt_tab    TYPE TABLE OF ty_code,
          lt_tab2   TYPE TABLE OF ty_code,
          lt_tab3   TYPE TABLE OF ty_code,
          lt_tab4   TYPE TABLE OF ty_code,
          lt_tabj   TYPE TABLE OF ty_code,
          "added by atul 07oct2014 to get all the
          lt_tabsz  TYPE TABLE OF ty_tabsiz,
          lt_tabsz1 TYPE TABLE OF ty_tabsiz,
          lt_tabcs  TYPE TABLE OF ty_code.

    "tables in join statements
    DATA: lv_loop   TYPE string,
          lv_code   TYPE string,
          lwa_final TYPE ty_final,
          lwa_tabsz TYPE ty_tabsiz,
          lwa_tabcs TYPE ty_code,
          lv_table  TYPE ddobjname.

    DATA: lt_flag_st TYPE char1.
    DATA:  lv_wsel TYPE flag.

*    DATA: lt_fields  TYPE STANDARD TABLE OF dfies,
*          lwa_fields TYPE                   dfies.
    DATA: lt_fields  TYPE STANDARD TABLE OF ty_fields,
          lwa_fields TYPE                   ty_fields.


    DATA: lv_fields  TYPE string,
          lv_index1  TYPE sy-index,
          lv_filters TYPE string,
          lv_itabs   TYPE string,
          lv_wa      TYPE string.
    DATA: lv_part1     TYPE string,
          lv_part2     TYPE string,
          lv_neg_where TYPE c,
          lv_cat       TYPE dd09l-tabkat,
          lv_tbsiz     TYPE string.

    DATA: l_tabclass  TYPE dd02l-tabclass.
    DATA: lv_leng     TYPE i.
    DATA: lv_str2_tmp TYPE string.
    DATA: lv_key      TYPE string.
    DATA: lwa_tabkey  TYPE tt_tabkey.
    DATA: lp_nest_ind TYPE c.
    DATA: lt_tabkey   TYPE TABLE OF tt_tabkey.
    DATA: lv_cmc TYPE i,
          lv_sub TYPE i,
          lv_wac TYPE i.
    DATA : lv_line TYPE sy-tabix,
           lv_len  TYPE i.
    DATA: lv_original TYPE string.
    DATA: lv_where TYPE string.
    DATA: lvj_str1 TYPE string,
          lvj_str2 TYPE string.
    DATA : lv_sytabix TYPE sy-tabix.
    DATA: lv_xwhere TYPE string.
    DATA: lv_tablef TYPE string.
    DATA: lv_str_tmp TYPE string.
    DATA: lv_fielda TYPE string.
    DATA: lv_fieldb TYPE string.
    DATA: lv_no TYPE flag.
    TYPES: BEGIN OF ty_join,
*             table TYPE string,
             table TYPE tabname, "string,  "MS+ 15-Jan-16
             alias TYPE string,
             join  TYPE string,
           END OF ty_join.
    DATA: lt_join  TYPE STANDARD TABLE OF ty_join,
          lwa_join TYPE ty_join.
    DATA: lv_join TYPE flag.


*   Start of change by MS 15-Jan-2016 to avoid select in Loops.
    TYPES: BEGIN OF ty_tab_field,
             tabname   TYPE dd03l-tabname,
             fieldname TYPE dd03l-fieldname,
             position  TYPE dd03l-position,
             keyflag   TYPE dd03l-keyflag,
           END OF ty_tab_field.
    DATA: lt_tab_field TYPE TABLE OF ty_tab_field,
          ls_tab_field TYPE ty_tab_field.
*  End of change by MS 15-Jan-2016 to avoid select in Loops.

    CLEAR: lv_join.
    CLEAR:  lv_str_tmp.
    CLEAR: lv_xwhere.
    CLEAR: lv_original, lv_tablef.
    CLEAR: lv_wsel.
    lv_original = pwa_code.
    REPLACE ALL OCCURRENCES OF gc_open_bracket IN pwa_code WITH ''.
    REPLACE ALL OCCURRENCES OF gc_close_bracket IN pwa_code WITH ''.
    CONDENSE pwa_code.

    REFRESH lt_tab3[].
    CLEAR: gv_flag_d , l_tabclass.
    CLEAR: lv_fields, lv_filters, lv_itabs, lv_wa, lv_flag, lv_loop.
*start of change by ashish on 09 Oct  -- INTO Workarea added in case it
*is not present in original statement
    REFRESH lt_tab4[].
    CLEAR: lv_leng, lv_line.
    SPLIT pwa_code  AT space INTO TABLE lt_tab4.
    CLEAR: lv_code.
    DELETE lt_tab4 WHERE text = ''.
    LOOP AT lt_tab4 INTO lwa_tab4 .
      TRANSLATE lwa_tab4 TO UPPER CASE.
      IF lwa_tab4-text = gc_into OR lwa_tab4-text = gc_app.
        lv_leng  = 1.
      ENDIF.
      IF lwa_tab4-text = gc_from.
        lv_line = sy-tabix.
      ENDIF.
    ENDLOOP.
    IF lv_leng = 0.
      CLEAR: pwa_code.
      DATA : lv_stbix TYPE i.
      LOOP AT lt_tab4 INTO lwa_tab4 .
        TRANSLATE lwa_tab4-text TO UPPER CASE.
        lv_stbix = lv_line + 1.
        IF sy-tabix = lv_stbix.
          lv_code  = lwa_tab4-text.
        ENDIF.
        CLEAR : lv_stbix.
        lv_stbix = lv_line + 2.
        IF  sy-tabix = lv_stbix.
          CONCATENATE pwa_code gc_into  lv_code INTO pwa_code SEPARATED
          BY space.
          CONCATENATE pwa_code lwa_tab4-text INTO pwa_code SEPARATED BY
          space.
        ELSE.
          CONCATENATE pwa_code lwa_tab4-text INTO pwa_code SEPARATED BY
          space.
        ENDIF.
        CLEAR : lv_stbix.
      ENDLOOP.
      CONDENSE pwa_code.
    ENDIF.
    CLEAR: lv_code, lv_line, lv_leng.
    REFRESH   lt_tab4[].
*end of change by ashish on 09 Oct  -- INTO Workarea added in case it is
*not present in original statement
    lv_code = pwa_code.

*start of change by ashish sep30 --- need to break into internal table
*and then SPLIT at from
*  SPLIT pwa_code AT 'FROM' INTO lv_str1 lv_str2.
    SPLIT pwa_code AT space INTO TABLE lt_tab.
    DELETE lt_tab WHERE text = ''.
    DELETE lt_tab WHERE text CS gc_open_bracket .
    DELETE lt_tab WHERE text CS gc_close_bracket .
    CLEAR: lwa_code1.
    LOOP AT lt_tab INTO  lwa_code1.
      TRANSLATE lwa_code1-text TO UPPER CASE.
      IF lwa_code1-text = gc_from.
        lv_line = sy-tabix.
      ENDIF.
      IF lv_line IS INITIAL.
        CONCATENATE lv_str1 lwa_code1 INTO lv_str1 SEPARATED BY space.
      ELSE.
        CONCATENATE lv_str2 lwa_code1 INTO lv_str2 SEPARATED BY space.
      ENDIF.
    ENDLOOP.
    REPLACE FIRST OCCURRENCE OF gc_from IN lv_str2 WITH ''.
    CLEAR: lv_line.
*end of change by ashish sep30 --- need to break into internal table and
*then SPLIT at from
    CONDENSE lv_str2.
    REFRESH lt_tab[]. "22nov
    SPLIT lv_str2 AT space INTO TABLE lt_tab.


    DESCRIBE TABLE lt_tab LINES lv_line.
    IF lv_line EQ 1.
      READ TABLE lt_tab INTO lwa_code1  INDEX 1.
      lv_len = strlen( lwa_code1-text  ).
      lv_len = lv_len - 1.
      CHECK lv_len > 0.
      IF lwa_code1-text+lv_len(1) EQ gc_dot.
        lwa_code1-text  = lwa_code1-text+0(lv_len).
        MODIFY lt_tab FROM lwa_code1 INDEX 1.
      ENDIF.
    ENDIF.

    DELETE lt_tab WHERE text CS gc_open_bracket .
    DELETE lt_tab WHERE text CS gc_close_bracket .
    READ TABLE lt_tab INTO lwa_code1 INDEX 1.

    IF lwa_code1+0(1) NE gc_open_bracket.
*{ Begin of changes - rohit 12/10/2015
      CLEAR gwa_pool_clus.
      IF NOT gt_pool_clus  IS INITIAL.
        READ TABLE gt_pool_clus
          INTO gwa_pool_clus
          WITH KEY tabname = lwa_code1.
        IF sy-subrc EQ 0.
        ENDIF.
      ENDIF.
*} End of changes - rohit 12/10/2015
      " Dynamic table name given. Table type can't be determined.
      SELECT tabname
      FROM dd02l
      INTO TABLE gt_dd02l
      WHERE tabname = lwa_code1
      AND tabclass IN (gc_transp , gc_pool , gc_cluster , gc_view ).
      IF sy-subrc NE 0.
        EXIT.

      ELSE.
        REPLACE ALL OCCURRENCES OF  gc_open_bracket IN pwa_code WITH ''.
        REPLACE ALL OCCURRENCES OF  gc_close_bracket IN pwa_code WITH ''
        .

        SPLIT pwa_code AT space INTO TABLE lt_tab2.
        DELETE lt_tab2 WHERE text = ''.
*Check for NEGATIVE CONDITION in WHERE Clause
        CLEAR : lv_neg_where , lv_part1 , lv_part2.
        READ TABLE lt_tab2 TRANSPORTING NO FIELDS WITH KEY text =
        gc_where .  "WHERE
        IF sy-subrc IS INITIAL.
          SPLIT pwa_code AT gc_where_spc INTO  lv_part1  lv_part2.
          REPLACE ALL OCCURRENCES OF gc_close_bracket IN lv_part2 WITH
          space.
          REPLACE ALL OCCURRENCES OF gc_open_bracket IN lv_part2 WITH
          space.
          CONDENSE lv_part2.
          IF lv_part2 CS gc_ne_spc OR  lv_part2 CS gc_not_eq
              OR  lv_part2 CS '><' OR  lv_part2 CS gc_not_spc.
            lv_neg_where = gc_x.
          ENDIF.
        ENDIF.

        READ TABLE lt_tab2 INTO lv_str3 WITH KEY text = gc_where. "WHERE
        IF sy-subrc NE 0.
          READ TABLE lt_tab2 INTO lv_str3 WITH KEY text = gc_star.
          IF sy-subrc EQ 0.
            CLEAR: lwa_final.
            SELECT  SINGLE tabclass FROM dd02l INTO l_tabclass
            WHERE tabname = lwa_code1  AND as4local = gc_a .
            IF sy-subrc = 0.
              lwa_final-type      = l_tabclass.
*{ Begin of changes - rohit 12/10/2015
              IF  NOT gwa_pool_clus IS INITIAL.
                l_tabclass = gwa_pool_clus-tabclass.
                lwa_final-type = l_tabclass.
              ENDIF.
*} End of changes - rohit 12/10/2015
            ENDIF.
            lwa_final-opercd    = gc_31.
            lwa_final-prog      = gv_prog.
            lwa_final-obj_name  = gs_progname-progname.
            lwa_final-line      = p_index.
            lwa_final-table     = lwa_code1.
            lwa_final-type      = l_tabclass.
            lwa_final-drill     = gv_drill.
            CONCATENATE gc_select_str l_tabclass
                        INTO lwa_final-check
                        SEPARATED BY space.
            PERFORM append_final USING lwa_final.
            CLEAR: lwa_final.
          ENDIF.

        ENDIF.
        REFRESH : lt_tab2.
      ENDIF.

*special consideration for JOIN conditions. up to three joins are
*considered
*----------------------START --------------------------***********
*********** new logic for JOIN < any no. of join
*allowed***********************************
      REFRESH: lt_tab4[].
      SPLIT pwa_code AT space INTO TABLE lt_tab4.
      DELETE lt_tab4 WHERE text = ''.
      DELETE lt_tab4 WHERE text CS gc_open_bracket .
      DELETE lt_tab4 WHERE text CS gc_close_bracket .
      CLEAR: lwa_code1.
      CLEAR: lv_line.
      CLEAR: lwa_final-where_con.
      CLEAR: lv_str1, lv_str3. " mutiple select issue in error code 58
      LOOP AT lt_tab4 INTO  lwa_code1.
        TRANSLATE lwa_code1-text TO UPPER CASE.
        IF lwa_code1-text = gc_where.  "WHERE
          lv_line = sy-tabix.
        ENDIF.
        IF lv_line IS INITIAL.
          CONCATENATE lv_str1 lwa_code1 INTO lv_str1 SEPARATED BY space.
        ELSE.
          CONCATENATE lv_str3 lwa_code1 INTO lv_str3 SEPARATED BY space.
        ENDIF.
      ENDLOOP.
      REPLACE FIRST OCCURRENCE OF gc_where IN lv_str3 WITH ''. "WHERE
      CLEAR: lv_line.
      REFRESH: lt_tab4[].
      CONDENSE: lv_str1, lv_str3.
      CLEAR  lv_wsel.
      IF lv_str3 CS gc_select AND lv_str3 CS gc_from.
        lwa_final-where_con  = 'Select Statement in WHERE Clause'.
        lv_wsel = gc_x.
      ELSE.
        CLEAR  lv_wsel.
        " start of where clause
        lvj_str2 = lv_str3.
        IF lvj_str2 IS NOT INITIAL.
          CLEAR: lv_str2_tmp.
          CLEAR: lv_leng.
          lv_leng = strlen( lvj_str2 ).
          lv_leng = lv_leng - 1.
          IF lvj_str2+lv_leng(1) = gc_dot.
            lv_str2_tmp = lvj_str2+0(lv_leng).
          ELSE.
            lv_str2_tmp = lvj_str2.
          ENDIF.
          SPLIT lv_str2_tmp AT '' INTO TABLE lt_tab4.
          DELETE lt_tab4[] WHERE text = ''.
          DELETE lt_tab4[] WHERE text = gc_and.  "AND
          DELETE lt_tab4[] WHERE text = gc_or.   "OR
          DELETE lt_tab4[] WHERE text = gc_close_bracket.
          DELETE lt_tab4[] WHERE text = gc_open_bracket.
          DELETE lt_tab4[] WHERE text = gc_not.  "NOT
          CLEAR: lwa_tab4.
          REFRESH: lt_tab3[] .
          CLEAR: lv_sytabix.
          LOOP AT lt_tab4 INTO lwa_tab4.
            IF lwa_tab4-text IN gr_where[].
              IF lwa_tab4-text = gc_between.  "BETWEEN
                lv_sytabix = 1.
              ENDIF.

              IF lv_sytabix = 1 AND  lwa_tab4-text = gc_and.  "AND
                CLEAR lv_sytabix.
                CONTINUE.
              ENDIF.
              CLEAR lwa_tab4.
              lv_stbix =  sy-tabix - 1.
              IF lv_stbix GE 1.
                READ TABLE lt_tab4 INTO lwa_tab4 INDEX lv_stbix.
                IF sy-subrc IS INITIAL.
                  APPEND lwa_tab4 TO lt_tab3.
                ENDIF.
              ENDIF.
              CLEAR : lv_stbix.
            ENDIF.
          ENDLOOP.

          DELETE ADJACENT DUPLICATES FROM lt_tab3 COMPARING text.
          CLEAR: lv_where.
          LOOP AT lt_tab3 INTO lwa_tab4.
            CONCATENATE  lwa_final-where_con lwa_tab4-text INTO
            lwa_final-where_con SEPARATED BY gc_seperator.
          ENDLOOP.
        ENDIF.
        REFRESH: lt_tab3[].
        " end of where clause
      ENDIF.
      " check if JOIN exist
      " lv_str1 has everything other than WHERE clause.
      lv_xwhere = lv_str1. CLEAR lv_join.
      SPLIT lv_str1 AT '' INTO TABLE lt_tab4[].
      READ TABLE lt_tab4 WITH KEY text = gc_join TRANSPORTING NO FIELDS.
      IF sy-subrc = 0.
        lv_join = gc_x.
        IF lv_str1 CS gc_select_str.
          " get value of fields from get_sel_star FORM
          IF gv_join_fae = gc_x.
            lwa_final-fields  = gv_fields.
            CLEAR: gv_fields.
          ENDIF.
          REFRESH lt_tab4[].
        ELSE.
          REFRESH lt_tab4[].
          CONDENSE lv_code.
          SPLIT lv_str1 AT gc_into_sp INTO lvj_str1 lvj_str2.

          IF lvj_str1  CS gc_from_spc.
            SPLIT lvj_str1  AT gc_from_spc INTO lvj_str1 lvj_str2.
          ENDIF.

          IF lvj_str1 CS gc_select.
            REPLACE FIRST OCCURRENCE OF gc_select_sing IN lvj_str1 WITH
            ''.
            REPLACE FIRST OCCURRENCE OF gc_select_spc IN lvj_str1 WITH
            ''.
            CONDENSE lvj_str1.

            SPLIT lvj_str1  AT space INTO TABLE lt_tab4.
            DELETE lt_tab4 WHERE text CS gc_open_bracket .
            DELETE lt_tab4 WHERE text CS gc_close_bracket .

*Get the Filed used in SELECT statement
            CLEAR lv_index1.
            READ TABLE lt_tab4 TRANSPORTING NO FIELDS
            WITH KEY text = gc_app.
            IF sy-subrc IS INITIAL.
              lv_index1 = sy-tabix.
            ENDIF.

            LOOP AT lt_tab4 INTO lwa_tab4.
              TRANSLATE lwa_tab4-text TO UPPER CASE.
              IF  ( lwa_tab4-text = gc_distinct OR
                ( sy-tabix GE lv_index1 AND lv_index1 GT 0 ) ).
                CONTINUE.
              ENDIF.
              CONCATENATE lv_str_tmp gc_seperator lwa_tab4-text
              INTO lv_str_tmp.
            ENDLOOP.
            lwa_final-fields  = lv_str_tmp.
            CLEAR lv_index1.
          ENDIF.
        ENDIF.

        lwa_final-join = gc_yes.
        lwa_final-code  = lv_original.
        lwa_final-prog = gv_prog.
        lwa_final-line = p_index.
        " find work area and internal table
        REFRESH lt_tab4[].
        CLEAR: lv_str_tmp.
        SPLIT lv_xwhere AT space INTO TABLE lt_tab4.
*        CLEAR: lv_str1, lv_str3.
        DELETE lt_tab4 WHERE text = ''.
        READ TABLE lt_tab4 WITH  KEY text = gc_table TRANSPORTING NO
        FIELDS.
        IF sy-subrc = 0.
          "
          REFRESH lt_tab4[].
          CLEAR: lv_str1, lv_str3.
          SPLIT lv_xwhere AT space INTO TABLE lt_tab4.
          DELETE lt_tab4 WHERE text = ''.
          DELETE lt_tab4 WHERE text CS gc_open_bracket .
          DELETE lt_tab4 WHERE text CS gc_close_bracket .
          CLEAR: lwa_tab4.
          CLEAR: lv_line.
          LOOP AT lt_tab4 INTO  lwa_tab4.
            TRANSLATE lwa_tab4-text TO UPPER CASE.
            IF lwa_tab4-text = gc_table.
              lv_line = sy-tabix.
            ENDIF.
            IF lv_line IS INITIAL.
              CONCATENATE lv_str1 lwa_tab4 INTO lv_str1
              SEPARATED BY space.
            ELSE.
              CONCATENATE lv_str3 lwa_tab4 INTO lv_str3
              SEPARATED BY space.
            ENDIF.
          ENDLOOP.
          REPLACE FIRST OCCURRENCE OF gc_table IN lv_str3 WITH ''.
          CLEAR: lv_line.
          REFRESH: lt_tab4[].
        ELSE.
          lv_str3 = ''.

*          SPLIT  lv_code AT 'TABLE' INTO lv_str1 lv_str3.
        ENDIF.
        REFRESH lt_tab4[].
        IF lv_str3 = ''.
          lv_flag = gc_x.
          "
          SPLIT lv_xwhere AT space INTO TABLE lt_tab4.
          DELETE lt_tab4 WHERE text = ''.
          DELETE lt_tab4 WHERE text CS gc_open_bracket .
          DELETE lt_tab4 WHERE text CS gc_close_bracket .
          CLEAR: lwa_tab4.
          CLEAR: lv_line.
          LOOP AT lt_tab4 INTO  lwa_tab4.
            TRANSLATE lwa_tab4-text TO UPPER CASE.
            IF lwa_tab4-text = gc_into.
              lv_line = sy-tabix.
            ENDIF.
            IF lv_line IS INITIAL.
              CONCATENATE lv_str1 lwa_tab4 INTO lv_str1
              SEPARATED BY space.
            ELSE.
              CONCATENATE lv_str3 lwa_tab4 INTO lv_str3
              SEPARATED BY space.
            ENDIF.
          ENDLOOP.
          REPLACE FIRST OCCURRENCE OF gc_into IN lv_str3 WITH ''.
          CLEAR: lv_line.
          REFRESH: lt_tab4[].

*          SPLIT  lv_code AT 'INTO' INTO lv_str1 lv_str3.
        ENDIF.
        REPLACE FIRST OCCURRENCE OF gc_dot IN lv_str3 WITH ''.
        CONDENSE lv_str3.
        CLEAR: lv_str1. ", lv_str3.
        SPLIT lv_str3 AT space INTO lv_str1 lv_str3.
        IF lv_flag = gc_x.
          IF lv_str1 CS gc_corr.
            CONDENSE lv_str3.
            SPLIT  lv_str3 AT gc_of INTO lv_str3 lv_str1.
            CONDENSE lv_str1.
            SPLIT  lv_str1 AT '' INTO lv_str1 lv_str3.
          ELSE.
            IF lv_str3 IS NOT INITIAL OR lv_str1 CS gc_comma.
              CONDENSE lv_str3.
              CLEAR: lv_wac, lv_cmc.
              lv_wac = 1. " work area count
              IF lv_str1 CS gc_comma.
                lv_cmc = 1.  " comma count
              ELSE.
                CLEAR lv_cmc.
              ENDIF.
              REFRESH lt_tab4[].
              SPLIT lv_str3 AT '' INTO TABLE lt_tab4[].
              DELETE lt_tab4[] WHERE text = ''.
              LOOP AT lt_tab4 INTO lwa_tab4.
                IF lwa_tab4 CS gc_comma.
                  lv_cmc = lv_cmc + 1.
                ENDIF.
                IF strlen( lwa_tab4 ) > 1.
                  lv_wac = lv_wac + 1.
                ENDIF.
                CLEAR: lv_sub.
                lv_sub = lv_wac - lv_cmc.
*          if lv_wac - lv_cmc > 1.
                IF lv_sub > 1.
                  EXIT.
                ELSE.
                  CONCATENATE lv_str1 lwa_tab4 INTO lv_str1
                  SEPARATED BY ''.

                ENDIF.
              ENDLOOP.
            ENDIF.
          ENDIF.
          lwa_final-wa = lv_wa = lv_str1.
        ELSE.
          lwa_final-itabs = lv_itabs = lv_str1.
        ENDIF.
        " end of internal table and work area
        " start of filter clause
        REFRESH lt_tab4[].
        SPLIT lv_xwhere AT '' INTO TABLE lt_tab4[].
        DELETE lt_tab4 WHERE text = ''.
        DELETE lt_tab4 WHERE text CS gc_open_bracket .
        DELETE lt_tab4 WHERE text CS gc_close_bracket .
        CLEAR: lwa_tab4.
        CLEAR: lv_line.
        CLEAR: lv_str1, lv_str3.
        LOOP AT lt_tab4 INTO  lwa_tab4.
          TRANSLATE lwa_tab4-text TO UPPER CASE.
          IF lwa_tab4-text = gc_from.
            lv_line = sy-tabix.
          ENDIF.
          IF lv_line IS INITIAL.
            CONCATENATE lv_str1 lwa_tab4 INTO lv_str1
            SEPARATED BY space.
          ELSE.
            CONCATENATE lv_str3 lwa_tab4 INTO lv_str3
            SEPARATED BY space.
          ENDIF.
        ENDLOOP.
*    REPLACE FIRST OCCURRENCE OF 'FROM' IN lv_str3 WITH ''.
        CLEAR: lv_line.
        REFRESH: lt_tab4[].
        SPLIT lv_str3 AT '' INTO TABLE lt_tab4[].
        DELETE lt_tab4[] WHERE text = ''.
        DATA: lv_pos TYPE sy-tabix.
        lv_pos = 1.
        CLEAR: lwa_final-filters.
        LOOP AT lt_tab4 INTO lwa_tab4 FROM lv_pos.
          IF sy-tabix LT lv_pos.
            CONTINUE.
          ENDIF.
          " table
          IF lwa_tab4-text = gc_from.
            lv_pos = lv_pos + 1.
            READ TABLE lt_tab4 INTO lwa_tab4 INDEX lv_pos.
            lwa_join-table = lwa_tab4-text.
            " alias
            lv_pos = lv_pos + 1.
            READ TABLE lt_tab4 INTO lwa_tab4 INDEX lv_pos.
            IF lwa_tab4-text = gc_as.
              lv_pos = lv_pos + 1.
              READ TABLE lt_tab4 INTO lwa_tab4 INDEX lv_pos.
              lwa_join-alias = lwa_tab4-text.
              lv_pos = lv_pos + 1.
              APPEND lwa_join TO lt_join.
            ELSE.
              APPEND lwa_join TO lt_join.
            ENDIF.

          ELSE.
            CLEAR: lwa_join.
            READ TABLE lt_tab4 INTO lwa_tab4 INDEX lv_pos.
            IF lwa_tab4-text = gc_join.
              lv_pos = lv_pos - 1.
              READ TABLE lt_tab4 INTO lwa_tab4 INDEX lv_pos.
              IF lwa_tab4-text = gc_inner OR lwa_tab4-text = gc_left OR
              lwa_tab4-text = gc_right OR lwa_tab4-text = gc_outer.
                lwa_join-join = lwa_tab4-text.
              ELSE.
                lwa_join-join = gc_inner.
              ENDIF.
              lv_pos = lv_pos + 2.
              READ TABLE lt_tab4 INTO lwa_tab4 INDEX lv_pos.
              lwa_join-table = lwa_tab4-text.
              " alias
              lv_pos = lv_pos + 1.
              READ TABLE lt_tab4 INTO lwa_tab4 INDEX lv_pos.
              IF lwa_tab4-text = gc_as.
                lv_pos = lv_pos + 1.
                READ TABLE lt_tab4 INTO lwa_tab4 INDEX lv_pos.
                lwa_join-alias = lwa_tab4-text.
                lv_pos = lv_pos + 1.
                APPEND lwa_join TO lt_join.
              ELSE.
                APPEND lwa_join TO lt_join.
              ENDIF.
*      endif.
            ELSEIF lwa_tab4-text = gc_on OR lwa_tab4-text = gc_and OR
            lwa_tab4-text = gc_or.   "OR
              lv_pos = lv_pos + 1.
              READ TABLE lt_tab4 INTO lwa_tab4 INDEX lv_pos.
              CONCATENATE lwa_final-filters lwa_tab4
              INTO lwa_final-filters
              SEPARATED BY space.

              lv_pos = lv_pos + 1.
              READ TABLE lt_tab4 INTO lwa_tab4 INDEX lv_pos.
              CONCATENATE lwa_final-filters lwa_tab4
              INTO lwa_final-filters
              SEPARATED BY space.

              lv_pos = lv_pos + 1.
              READ TABLE lt_tab4 INTO lwa_tab4 INDEX lv_pos.
              CONCATENATE lwa_final-filters lwa_tab4 gc_seperator
              INTO lwa_final-filters
              SEPARATED BY space.
            ELSE.
              lv_pos = lv_pos + 1.
            ENDIF.
          ENDIF.
        ENDLOOP.
        " end of filter clause
        CLEAR: lv_fielda.
        REFRESH lt_tab4[].
        CONDENSE lwa_final-fields.
        CLEAR: lv_no.
        SPLIT lwa_final-fields AT gc_seperator INTO TABLE lt_tab4.
        DELETE lt_tab4[] WHERE text = ''.
        LOOP AT lt_tab4 INTO lwa_tab4.
          IF lwa_tab4-text CS gc_tilde.
            CONTINUE.
          ELSE.
            lv_no  = gc_x.
          ENDIF.
        ENDLOOP.
        REFRESH lt_tab4[].
        IF  lv_no = gc_x.
          SPLIT lwa_final-fields AT gc_seperator INTO TABLE lt_tab4.
          DELETE lt_tab4[] WHERE text = ''.
          CLEAR: lwa_final-fields.
          DELETE lt_tab4 WHERE text = ''.
          LOOP AT lt_tab4 INTO lwa_tab4.
            IF lwa_tab4-text CS gc_tilde.
              CONCATENATE  lwa_final-fields lwa_tab4-text INTO
              lwa_final-fields  SEPARATED BY gc_seperator.
            ELSE.
              CONCATENATE lv_fielda lwa_tab4-text INTO lv_fielda
              SEPARATED BY gc_seperator.
            ENDIF.
          ENDLOOP.
        ENDIF.

        REFRESH lt_tab4[].
        CONDENSE lv_fielda.
        SPLIT lv_fielda AT gc_seperator INTO TABLE lt_tab4.
        DELETE lt_tab4 WHERE text = ''.

        " replace where conditions with table name
        CLEAR: lv_fieldb.
        REFRESH lt_tab3[].
        CONDENSE lwa_final-where_con.
        CLEAR: lv_no.
        SPLIT lwa_final-where_con AT gc_seperator INTO TABLE lt_tab3.
        DELETE lt_tab3[] WHERE text = ''.
        LOOP AT lt_tab3 INTO lwa_tab4.
          IF lwa_tab4-text CS gc_tilde.
            CONTINUE.
          ELSE.
            lv_no  = gc_x.
          ENDIF.
        ENDLOOP.
        REFRESH lt_tab3[].
        IF  lv_no = gc_x.
          SPLIT lwa_final-where_con AT gc_seperator INTO TABLE lt_tab3.
          DELETE lt_tab3[] WHERE text = ''.
          CLEAR: lwa_final-where_con.
          DELETE lt_tab3 WHERE text = ''.
          LOOP AT lt_tab3 INTO lwa_tab4.
            IF lwa_tab4-text CS gc_tilde.
              CONCATENATE  lwa_final-where_con lwa_tab4-text INTO
              lwa_final-where_con  SEPARATED BY gc_seperator.
            ELSE.
              CONCATENATE lv_fieldb lwa_tab4-text INTO lv_fieldb
              SEPARATED BY gc_seperator.
            ENDIF.
          ENDLOOP.
        ENDIF.

        REFRESH lt_tab3[].
        CONDENSE lv_fieldb.
        SPLIT lv_fieldb AT gc_seperator INTO TABLE lt_tab3.
        DELETE lt_tab3 WHERE text = ''.

        CLEAR: l_tabclass,lwa_final-type,lv_str2_tmp .
*        Start of change by MS 15-Jan-2016 to avoid select in Loops.
        IF lt_join IS NOT INITIAL.
          SELECT tabname fieldname position keyflag
            FROM dd03l
            INTO TABLE lt_tab_field
            FOR ALL ENTRIES IN lt_join
            WHERE tabname = lt_join-table AND
                  as4local = gc_a.
          IF sy-subrc = 0.
            SORT lt_tab_field BY tabname position. "fieldname
          ENDIF.
        ENDIF.
*        End of change by MS 15-Jan-2016 to avoid select in Loops.

        LOOP AT lt_join INTO lwa_join.
* get tables
          IF lwa_join-table IS NOT INITIAL.
            CONCATENATE lwa_final-table lwa_join-table
            INTO lwa_final-table
            SEPARATED BY gc_seperator.
          ENDIF.

          CLEAR: l_tabclass.
          REFRESH lt_tabkey[].
* find table type : transparent, pool or cluster
          lv_table = lwa_join-table .
          SELECT  SINGLE tabclass FROM dd02l INTO l_tabclass
            WHERE tabname = lv_table  AND as4local = gc_a .
*{ Begin of changes - rohit 12/10/2015
          CLEAR gwa_pool_clus.
          IF NOT gt_pool_clus  IS INITIAL.
            READ TABLE gt_pool_clus
              INTO gwa_pool_clus1
              WITH KEY tabname = lv_table.
            IF sy-subrc EQ 0.
              l_tabclass =  gwa_pool_clus1-tabclass.
            ENDIF.
          ENDIF.
*} End of changes - rohit 12/10/2015
          IF sy-subrc = 0.
            CONCATENATE lwa_final-type  l_tabclass INTO
            lwa_final-type SEPARATED BY gc_seperator.
            CLEAR: l_tabclass.
          ENDIF.

* find primary key fields
          lv_table =  lwa_join-table.
*  Start of change by MS 15-Jan-2016 to avoid select in Loops.
*          SELECT  fieldname position FROM dd03l INTO TABLE lt_tabkey
*          WHERE tabname = lv_table  AND keyflag = gc_x .
*          IF sy-subrc = 0.
*            CLEAR: lv_key.
*            SORT lt_tabkey BY position.
*            LOOP AT lt_tabkey INTO lwa_tabkey.
*              IF lwa_tabkey-fieldname+0(1) = gc_dot.
*                CONTINUE.
*              ENDIF.
*              CONCATENATE lv_table gc_tilde lwa_tabkey-fieldname INTO
*              lv_key.
*              CONCATENATE  lv_str2_tmp lv_key INTO
*              lv_str2_tmp SEPARATED BY gc_seperator .
*              CLEAR:  lv_key.
*            ENDLOOP.
*          ENDIF.

*        DATA: lv_fieldname TYPE dd03l-fieldname.
*          IF lv_fielda IS NOT INITIAL.
*            " add table name with tidle sign when table reference
*            " is not present - fields
*            REFRESH lt_tabkey[].
*
*            LOOP AT lt_tab4 INTO lwa_tab4.
*              lv_fieldname  = lwa_tab4-text.
*              SELECT SINGLE fieldname position FROM dd03l
*              INTO lwa_tabkey
*              WHERE tabname = lv_table AND fieldname = lv_fieldname .
*              IF sy-subrc = 0.
*                CONCATENATE  lwa_join-table  gc_tilde
*                lwa_tabkey-fieldname
*                INTO lwa_tab4-text.
*                MODIFY lt_tab4 FROM lwa_tab4 INDEX sy-tabix.
*              ENDIF.
*            ENDLOOP.
*          ENDIF.

*    IF lv_fieldb IS NOT INITIAL.
*            " add table name with tidle sign when table reference
*            " is not present --where
*            REFRESH lt_tabkey[].
*
*            LOOP AT lt_tab3 INTO lwa_tab4.
*              lv_fieldname  = lwa_tab4-text.
*              SELECT SINGLE fieldname position FROM dd03l
*                INTO  lwa_tabkey
*              WHERE tabname = lv_table AND fieldname = lv_fieldname .
*              IF sy-subrc = 0.
*                CONCATENATE  lwa_join-table  gc_tilde
*                lwa_tabkey-fieldname
*                INTO lwa_tab4-text.
*                MODIFY lt_tab3 FROM lwa_tab4 INDEX sy-tabix.
*              ENDIF.
*            ENDLOOP.
*          ENDIF.


          CLEAR: lv_key.
          LOOP AT lt_tab_field INTO ls_tab_field
                               WHERE tabname = lwa_join-table AND
                                     keyflag = gc_x.
            IF ls_tab_field-fieldname+0(1) = gc_dot.
              CONTINUE.
            ENDIF.
            CONCATENATE lv_table gc_tilde ls_tab_field-fieldname INTO
            lv_key.
            CONCATENATE  lv_str2_tmp lv_key INTO
            lv_str2_tmp SEPARATED BY gc_seperator .
            CLEAR: lv_key.
          ENDLOOP.

          DATA: lv_fieldname TYPE dd03l-fieldname.
          IF lv_fielda IS NOT INITIAL.
            " add table name with tidle sign when table reference
            " is not present - fields
            SORT lt_tab_field BY tabname fieldname.
            LOOP AT lt_tab4 INTO lwa_tab4.
              lv_fieldname  = lwa_tab4-text.
              READ TABLE lt_tab_field INTO ls_tab_field
                                      WITH KEY tabname = lwa_join-table
                                               fieldname = lv_fieldname
                                               BINARY SEARCH.
              IF sy-subrc = 0.
                CONCATENATE  lwa_join-table  gc_tilde
                             ls_tab_field-fieldname
                INTO lwa_tab4-text.
                MODIFY lt_tab4 FROM lwa_tab4 INDEX sy-tabix.
              ENDIF.
            ENDLOOP.
          ENDIF.

          IF lv_fieldb IS NOT INITIAL.
            " add table name with tidle sign when table reference
            " is not present --where
            LOOP AT lt_tab3 INTO lwa_tab4.
              lv_fieldname  = lwa_tab4-text.
              READ TABLE lt_tab_field INTO ls_tab_field
                                      WITH KEY tabname   =
                                      lwa_join-table
                                               fieldname = lv_fieldname
                                               BINARY SEARCH.
              IF sy-subrc = 0.
                CONCATENATE  lwa_join-table gc_tilde
                             ls_tab_field-fieldname
                             INTO lwa_tab4-text.
                MODIFY lt_tab3 FROM lwa_tab4 INDEX sy-tabix.
              ENDIF.
            ENDLOOP.
          ENDIF.
*  End of change by MS 15-Jan-2016 to avoid select in Loops.


          IF lwa_join-join IS NOT INITIAL.
            CONCATENATE lwa_final-codenew lwa_join-join
            INTO lwa_final-codenew SEPARATED BY gc_seperator.
          ENDIF.
          IF lwa_join-alias IS NOT INITIAL.
            CONCATENATE lwa_join-alias gc_tilde INTO lwa_join-alias.
            CONCATENATE lwa_join-table gc_tilde INTO lwa_join-table.
            REPLACE ALL OCCURRENCES OF lwa_join-alias
            IN lwa_final-filters WITH lwa_join-table .
            REPLACE ALL OCCURRENCES OF lwa_join-alias
            IN lwa_final-fields WITH lwa_join-table .
            REPLACE ALL OCCURRENCES OF lwa_join-alias
            IN lwa_final-where_con WITH lwa_join-table .
          ENDIF.
        ENDLOOP.
        IF lt_tab4[] IS NOT INITIAL.
          LOOP AT lt_tab4 INTO lwa_tab4.
            " if removed filled added again with table name
            CONCATENATE lwa_final-fields lwa_tab4-text
            INTO lwa_final-fields SEPARATED BY gc_seperator.
          ENDLOOP.
        ENDIF.

        IF lt_tab3[] IS NOT INITIAL.
          LOOP AT lt_tab3 INTO lwa_tab4.
            " if removed filled added again with table name
            CONCATENATE lwa_final-where_con lwa_tab4-text INTO
            lwa_final-where_con SEPARATED BY gc_seperator.
          ENDLOOP.
        ENDIF.

        lwa_final-keys = lv_str2_tmp .

*** get the table size of table used in JOIN
        REFRESH : lt_tabsz1[] , lt_tabsz[] , lt_tabcs[].
        SPLIT lwa_final-table  AT gc_seperator INTO TABLE lt_tabcs[].
        LOOP AT lt_tabcs INTO lwa_tabcs.
          lwa_tabsz-table = lwa_tabcs-text.
          APPEND lwa_tabsz TO lt_tabsz1.
          CLEAR : lwa_tabsz , lwa_tabcs.
        ENDLOOP.

        DELETE ADJACENT DUPLICATES FROM lt_tabsz1 COMPARING table.
        IF NOT lt_tabsz1[] IS INITIAL.
          SELECT tabname tabkat INTO TABLE lt_tabsz
          FROM dd09l
          FOR ALL ENTRIES IN lt_tabsz1
          WHERE tabname = lt_tabsz1-table
          AND as4local = gc_a.
          IF sy-subrc = 0.
            SORT lt_tabsz BY table .
            CLEAR : lv_cat , lv_tbsiz .
            LOOP AT lt_tabsz INTO lwa_tabsz.
              IF lwa_tabsz-tabkat GE gc_two.
                lv_cat = lwa_tabsz-tabkat.
                CONCATENATE lv_tbsiz gc_seperator 'Table:'
                lwa_tabsz-table 'Size:'
                lv_cat INTO lv_tbsiz SEPARATED BY space.
              ENDIF.
              CLEAR lwa_tabsz.
            ENDLOOP.
          ENDIF.
        ENDIF.

        lwa_final-opercd = gc_39.
        lwa_final-obj_name = gs_progname-progname.
        lwa_final-line     = p_index.
        lwa_final-drill    = gv_drill.
        lwa_final-prog     = gv_prog.
        lwa_final-code  = lv_original.
        lwa_final-itabs = lv_itabs.
        lwa_final-wa = lv_wa.
        lwa_final-drill = gv_drill.
        lwa_final-loop = lv_loop.
        PERFORM append_final USING lwa_final.
        CLEAR: lwa_final-check, lwa_final-critical.

*   endif.
*----------------------END --------------------------***********
*********** commented after generic join
************************************

*      READ TABLE lt_tab WITH KEY text = 'JOIN' TRANSPORTING NO FIELDS.
*      IF sy-subrc = 0.
*        DATA: "lvj_str1 TYPE string,
*              "lvj_str2 TYPE string,
*              lv_as11  TYPE string,
*              lv_as21  TYPE string,
*              lv_as31  TYPE string,
*              lv_as12  TYPE string,
*              lv_as22  TYPE string,
*              lv_as32  TYPE string,
*              lv_varj TYPE i.
*
**        DATA: lv_str_tmp TYPE string.
*
*        CLEAR: lv_as11, lv_as21, lv_as31, lv_as12, lv_as22, lv_as32,
*        lvj_str1, lv_str2,lt_tab4.
*        REFRESH lt_tab4[].
*        CONDENSE lv_code.
*        SPLIT lv_code AT ' INTO' INTO lvj_str1 lvj_str2.
*
*        IF lvj_str1  CS ' FROM '.
*          SPLIT lvj_str1  AT ' FROM ' INTO lvj_str1 lvj_str2.
*        ENDIF.
*
*        IF lvj_str1 CS 'SELECT'.
*          REPLACE FIRST OCCURRENCE OF 'SELECT SINGLE' IN lvj_str1 WITH
*          ''.
*          REPLACE FIRST OCCURRENCE OF 'SELECT ' IN lvj_str1 WITH ''.
*          CONDENSE lvj_str1.
*
*          SPLIT lvj_str1  AT space INTO TABLE lt_tab4.
*          DELETE lt_tab4 WHERE text CS '(' .
*          DELETE lt_tab4 WHERE text CS ')' .
*
**Get the Filed used in SELECT statement
*          CLEAR lv_index1.
*          READ TABLE lt_tab4 TRANSPORTING NO FIELDS
*          WITH KEY text = 'APPENDING'.
*          IF sy-subrc IS INITIAL.
*            lv_index1 = sy-tabix.
*          ENDIF.
*
*          LOOP AT lt_tab4 INTO lwa_tab4.
*            TRANSLATE lwa_tab4-text TO UPPER CASE.
*            IF  ( lwa_tab4-text = 'DISTINCT' OR
*              ( sy-tabix GE lv_index1 AND lv_index1 GT 0 ) ).
*              CONTINUE.
*            ENDIF.
*
*            CONCATENATE lv_str_tmp '|' lwa_tab4-text  INTO lv_str_tmp.
*          ENDLOOP.
*
*          lwa_final-fields  = lv_str_tmp.
*          CLEAR lv_index1.
*        ENDIF.
*        lwa_final-join = 'YES'.
*        lwa_final-code  = gv_org_code.
*        lwa_final-prog = gv_prog.
*        lwa_final-line = p_index.
*
*
*        SPLIT lv_code AT 'TABLE' INTO lvj_str1 lvj_str2.
*        REPLACE ALL OCCURRENCES OF '(' IN lvj_str1 WITH space.
*        REPLACE ALL OCCURRENCES OF '(' IN lvj_str2 WITH space.
*        REPLACE ALL OCCURRENCES OF ')' IN lvj_str1 WITH space.
*        REPLACE ALL OCCURRENCES OF ')' IN lvj_str2 WITH space.
*        CONDENSE lvj_str2.
*        IF lvj_str2 IS INITIAL.
*          SPLIT lvj_str1 AT 'FROM' INTO lvj_str1 lvj_str2.
*          REPLACE ALL OCCURRENCES OF '.' IN lvj_str1 WITH ''.
*          " ashish 06Oct
*          CONDENSE lvj_str1.
*          lwa_final-itabs = lvj_str1. " internal table
*        ELSE.
*          SPLIT lvj_str2 AT space INTO lvj_str1 lvj_str2.
*          REPLACE ALL OCCURRENCES OF '.' IN lvj_str1 WITH ''.
*          " ashish 06Oct
*          lwa_final-itabs = lvj_str1. " internal table
*          SPLIT lvj_str2 AT 'FROM' INTO lvj_str1 lvj_str2.
*        ENDIF.
*        CONDENSE lvj_str2.
*        SPLIT lvj_str2 AT space INTO lvj_str1 lvj_str2.
*        lwa_final-table = lvj_str1. " db table
*        lv_as11 = lvj_str1.
*        CONDENSE lvj_str2.
*        SPLIT lvj_str2 AT space INTO lvj_str1 lvj_str2.
*        IF lvj_str1 = 'AS'.
*          CONDENSE lvj_str2.
*          SPLIT lvj_str2 AT space INTO lvj_str1 lvj_str2.
*          lv_as12 = lvj_str1.
*        ENDIF.
*        CONDENSE lvj_str2.
** Begin of changes by Atul Gandhi on 7 Oct 2014 for join conditions
*        "added dec lt_tab5 for join conditions by atul
**      split lvj_str2 at 'JOIN ' into lvj_str1 lvj_str2.
**      condense lvj_str2.
**      split lvj_str2 at '' into lvj_str1 lvj_str2.
**      condense lvj_str2.
*        SPLIT lvj_str2 AT space INTO TABLE lt_tabj.
*        LOOP AT lt_tabj INTO lwa_tabj.
*          CONDENSE lwa_tabj.
*          TRANSLATE lwa_tabj TO UPPER CASE.
*          IF  lwa_tabj = 'JOIN'.
*            lv_varj = sy-tabix + 1.
*            READ TABLE lt_tabj INTO lvj_str1 INDEX lv_varj.
*            CONCATENATE  lwa_final-table lvj_str1 INTO lwa_final-table
*            SEPARATED BY '|'.
*            CONDENSE lwa_final-table.
*          ENDIF.
*          CLEAR : lwa_tabj.
*        ENDLOOP.
*
*        IF lv_varj IS NOT INITIAL.
*          lv_varj = lv_varj - 1.
*          DO lv_varj TIMES.
*            DELETE lt_tabj INDEX 1.
*          ENDDO.
*CONCATENATE LINES OF lt_tabj INTO lvj_str2 SEPARATED BY space.
*        ENDIF.
*
** End of changes by Atul Gandhi on 7 Oct 2014 for join conditions
*
*        lv_as21 = lvj_str1.
*        CONDENSE lvj_str2.
*        SPLIT lvj_str2 AT space INTO lvj_str1 lvj_str2.
*        CLEAR: lv_leng.
*        lv_leng = STRLEN( lvj_str2 ).
*        CHECK lv_leng GE 2.
*        CLEAR: lv_leng.
*        IF lvj_str2+0(2) EQ 'AS'.
*          SPLIT lvj_str2 AT space INTO lvj_str1 lvj_str2.
*" added on 08 OCT - ashish in order to get right position of AS
*        ENDIF.
*        IF lvj_str1 = 'AS'.
*          CONDENSE lvj_str2.
*          SPLIT lvj_str2 AT space INTO lvj_str1 lvj_str2.
*          lv_as22 = lvj_str1.
*        ENDIF.
*
*        CONDENSE lvj_str2.
*        SPLIT lvj_str2 AT 'ON' INTO lvj_str1 lvj_str2.
*        IF lvj_str2 = ''.
*          lvj_str2 = lvj_str1.
*        ENDIF.
*        CONDENSE lvj_str2.
*
*        REFRESH lt_tab4[].
*        IF lvj_str2 CS 'WHERE'.
*          SPLIT lvj_str2 AT 'WHERE' INTO lvj_str1 lvj_str2.
*          CONDENSE: lvj_str1, lvj_str2.
** finds fields used in WHERE clause of JOIN statement
*          IF lvj_str2 IS NOT INITIAL.
*            CLEAR: lv_str2_tmp.
*            CLEAR: lv_leng.
*            lv_leng = STRLEN( lvj_str2 ).
*            lv_leng = lv_leng - 1.
*            CHECK lv_leng > 0.
*            IF lvj_str2+lv_leng(1) = '.'.
*              lv_str2_tmp = lvj_str2+0(lv_leng).
*            ENDIF.
*            SPLIT lv_str2_tmp AT '' INTO TABLE lt_tab4.
*            DELETE lt_tab4[] WHERE text NS '~'.
*            DELETE lt_tab4[] WHERE text = ''.
*          ENDIF.
*          lvj_str2 = lvj_str1.
*          CLEAR : lvj_str1.
*        ENDIF.
*        SPLIT lvj_str2 AT 'JOIN ' INTO  lvj_str1 lvj_str2.
*
*
*        IF lvj_str2 = ''.
*          REPLACE ALL OCCURRENCES OF  '(' IN lvj_str1 WITH space.
*          REPLACE ALL OCCURRENCES OF  ')' IN lvj_str1 WITH space.
*          REPLACE ALL OCCURRENCES OF  'LEFT' IN lvj_str1 WITH space.
*          REPLACE ALL OCCURRENCES OF  'RIGHT' IN lvj_str1 WITH space.
*          REPLACE ALL OCCURRENCES OF  'FULL' IN lvj_str1 WITH space.
*          REPLACE ALL OCCURRENCES OF  'OUTER' IN lvj_str1 WITH space.
*          REPLACE ALL OCCURRENCES OF  'WHERE' IN lvj_str1 WITH space.
*          REPLACE ALL OCCURRENCES OF  'INNER' IN lvj_str1 WITH space.
*          CONDENSE lvj_str1.
*          lwa_final-filters = lvj_str1.
*        ELSE.
*          REPLACE ALL OCCURRENCES OF  '(' IN lvj_str1 WITH space.
*          REPLACE ALL OCCURRENCES OF  ')' IN lvj_str1 WITH space.
*          REPLACE ALL OCCURRENCES OF  'LEFT' IN lvj_str1 WITH space.
*          REPLACE ALL OCCURRENCES OF  'RIGHT' IN lvj_str1 WITH space.
*          REPLACE ALL OCCURRENCES OF  'FULL' IN lvj_str1 WITH space.
*          REPLACE ALL OCCURRENCES OF  'OUTER' IN lvj_str1 WITH space.
*          REPLACE ALL OCCURRENCES OF  'WHERE' IN lvj_str1 WITH space.
*          REPLACE ALL OCCURRENCES OF  'INNER' IN lvj_str1 WITH space.
*          CONDENSE lvj_str1.
*          lwa_final-filters = lvj_str1.
*          CONDENSE lvj_str2.
*          SPLIT lvj_str2 AT '' INTO lvj_str1 lvj_str2.
*          CONDENSE lvj_str2.
*
*          CONCATENATE  lwa_final-table lvj_str1 INTO lwa_final-table
*          SEPARATED BY '|'.
*          CONDENSE lwa_final-table.
*
*          lv_as31 = lvj_str1.
*          CONDENSE lvj_str2.
*          SPLIT lvj_str2 AT space INTO lvj_str1 lvj_str2.
*          IF lvj_str1 = 'AS'.
*            CONDENSE lvj_str2.
*            SPLIT lvj_str2 AT space INTO lvj_str1 lvj_str2.
*            lv_as32 = lvj_str1.
*          ENDIF.
*
*          CONDENSE lvj_str2.
*          SPLIT lvj_str2 AT 'ON' INTO lvj_str1 lvj_str2.
*          IF lvj_str2 = ''.
*            lvj_str2 = lvj_str1.
*          ENDIF.
*          CONDENSE lvj_str2.
*
*
*          REPLACE ALL OCCURRENCES OF  '(' IN lvj_str2 WITH space.
*          REPLACE ALL OCCURRENCES OF  ')' IN lvj_str2 WITH space.
*          REPLACE ALL OCCURRENCES OF  'LEFT' IN lvj_str2 WITH space.
*          REPLACE ALL OCCURRENCES OF  'RIGHT' IN lvj_str2 WITH space.
*          REPLACE ALL OCCURRENCES OF  'FULL' IN lvj_str2 WITH space.
*          REPLACE ALL OCCURRENCES OF  'OUTER' IN lvj_str2 WITH space.
*          REPLACE ALL OCCURRENCES OF  'WHERE' IN lvj_str2 WITH space.
*          REPLACE ALL OCCURRENCES OF  'INNER' IN lvj_str2 WITH space.
*          CONDENSE lvj_str2.
*          CONCATENATE  lwa_final-filters lvj_str2 INTO
*          lwa_final-filters SEPARATED BY ''.
*          CONDENSE lwa_final-filters.
*
*        ENDIF.
*
*        CONCATENATE lv_as12 '~' INTO lv_as12 .
*        CONCATENATE lv_as11 '~' INTO lv_as11 .
*        CONCATENATE lv_as21 '~' INTO lv_as21 .
*        CONCATENATE lv_as22 '~' INTO lv_as22 .
*        CONCATENATE lv_as31 '~' INTO lv_as31 .
*        CONCATENATE lv_as32 '~' INTO lv_as32 .
*
*        IF lv_as12+0(1) NE '~'.
*          REPLACE ALL OCCURRENCES OF lv_as12 IN
*          lwa_final-filters WITH lv_as11.
*          REPLACE ALL OCCURRENCES OF lv_as12 IN
*          lwa_final-fields WITH lv_as11.
*        ENDIF.
*        IF lv_as22+0(1) NE '~'.
*          REPLACE ALL OCCURRENCES OF lv_as22 IN
*          lwa_final-filters WITH lv_as21.
*          REPLACE ALL OCCURRENCES OF lv_as22 IN
*          lwa_final-fields WITH lv_as21.
*        ENDIF.
*
*        IF lv_as32+0(1) NE '~'.
*          REPLACE ALL OCCURRENCES OF lv_as32 IN
*          lwa_final-filters WITH lv_as31.
*          REPLACE ALL OCCURRENCES OF lv_as32 IN
*          lwa_final-fields WITH lv_as31.
*        ENDIF.
*
** code will replace alias with table name for where_condition
*        IF lt_tab4[] IS NOT INITIAL.
*          CLEAR: lvj_str1, lvj_str2.
*
*          LOOP AT lt_tab4 INTO lwa_tab4.
*            TRANSLATE lwa_tab4 TO UPPER CASE.
*            CONCATENATE lvj_str1 lwa_tab4-text INTO
*            lvj_str1 SEPARATED BY '|'.
*          ENDLOOP.
*          CLEAR: lv_leng.
*          lv_leng = STRLEN( lv_as12 ).
*          IF lv_leng GE 2.
*REPLACE ALL OCCURRENCES OF lv_as12 IN lvj_str1 WITH lv_as11.
*          ENDIF.
*          CLEAR: lv_leng.
*          lv_leng = STRLEN( lv_as22 ).
*          IF lv_leng GE 2.
*REPLACE ALL OCCURRENCES OF lv_as22 IN lvj_str1 WITH lv_as21.
*          ENDIF.
*          CLEAR: lv_leng.
*          lv_leng = STRLEN( lv_as32 ).
*          IF lv_leng GE 2.
*REPLACE ALL OCCURRENCES OF lv_as32 IN lvj_str1 WITH lv_as31.
*          ENDIF.
*
*          CONDENSE lvj_str1.
*          lwa_final-where_con = lvj_str1.
*        ENDIF.
*
*        lwa_final-loop = lv_loop.
*
*        CLEAR: lv_str2_tmp.
*        CLEAR: lvj_str1, lvj_str2.
*        CONDENSE lwa_final-table.
*        SPLIT lwa_final-table AT '|' INTO lvj_str1 lvj_str2.
** find table type : transparent, pool or cluster
*        lv_table = lvj_str1 .
*        SELECT  SINGLE tabclass FROM dd02l INTO l_tabclass
*          WHERE tabname = lv_table  AND as4local = 'A' .
*        IF sy-subrc = 0.
*          lwa_final-type = l_tabclass.
*          CLEAR: l_tabclass.
*        ENDIF.
** find primary key fields
*        lv_table = lvj_str1 .
*        SELECT  fieldname position FROM dd03l INTO TABLE
*              lt_tabkey WHERE tabname = lv_table  AND keyflag = 'X' .
*        IF sy-subrc = 0.
*          CLEAR: lv_key.
*          SORT lt_tabkey BY position.
*          LOOP AT lt_tabkey INTO lwa_tabkey.
*            IF lwa_tabkey-fieldname+0(1) = '.'.
*              CONTINUE.
*            ENDIF.
*            CONCATENATE lv_table '~' lwa_tabkey-fieldname INTO lv_key.
*            CONCATENATE  lv_str2_tmp lv_key INTO
*            lv_str2_tmp SEPARATED BY '|' .
*            CLEAR:  lv_key.
*          ENDLOOP.
*        ENDIF.
*
*        CONDENSE lvj_str2.
*        SPLIT lvj_str2 AT '|' INTO lvj_str1 lvj_str2.
** find table type : transparent, pool or cluster
*        lv_table = lvj_str1 .
*        SELECT  SINGLE tabclass FROM dd02l INTO l_tabclass
*          WHERE tabname = lv_table  AND as4local = 'A' .
*        IF sy-subrc = 0.
*          CONCATENATE lwa_final-type  l_tabclass
*          INTO lwa_final-type SEPARATED BY '|'.
*          CLEAR: l_tabclass.
*        ENDIF.
*
** find primary key fields
*        SELECT  fieldname position FROM dd03l INTO TABLE lt_tabkey
*          WHERE tabname = lv_table  AND keyflag = 'X' .
*        IF sy-subrc = 0.
*          CLEAR: lv_key.
*          SORT lt_tabkey BY position.
*          LOOP AT lt_tabkey INTO lwa_tabkey.
*            IF lwa_tabkey-fieldname+0(1) = '.'.
*              CONTINUE.
*            ENDIF.
*            CONCATENATE lv_table '~' lwa_tabkey-fieldname INTO lv_key.
*            CONCATENATE  lv_str2_tmp lv_key INTO
*            lv_str2_tmp SEPARATED BY '|' .
*            CLEAR:  lv_key.
*          ENDLOOP.
*        ENDIF.
*
*
*        CONDENSE lvj_str2.
*        SPLIT lvj_str2 AT '|' INTO lvj_str1 lvj_str2.
** find table type : transparent, pool or cluster
*        lv_table = lvj_str1 .
*        SELECT  SINGLE tabclass FROM dd02l INTO l_tabclass
*          WHERE tabname = lv_table  AND as4local = 'A' .
*        IF sy-subrc = 0.
*          CONCATENATE lwa_final-type  l_tabclass INTO
*          lwa_final-type SEPARATED BY '|'.
*          CLEAR: l_tabclass.
*        ENDIF.
*
** find primary key fields
*        lv_table = lvj_str1 .
*        SELECT  fieldname position FROM dd03l INTO TABLE lt_tabkey
*        WHERE tabname = lv_table  AND keyflag = 'X' .
*        IF sy-subrc = 0.
*          CLEAR: lv_key.
*          SORT lt_tabkey BY position.
*          LOOP AT lt_tabkey INTO lwa_tabkey.
*            IF lwa_tabkey-fieldname+0(1) = '.'.
*              CONTINUE.
*            ENDIF.
*            CONCATENATE lv_table '~' lwa_tabkey-fieldname INTO lv_key.
*            CONCATENATE  lv_str2_tmp lv_key INTO
*            lv_str2_tmp SEPARATED BY '|' .
*            CLEAR:  lv_key.
*          ENDLOOP.
*        ENDIF.
*
***
*        REFRESH: lt_tab4[].
*        SPLIT lv_str2_tmp AT '|' INTO TABLE lt_tab4[].
*        DELETE lt_tab4 WHERE text = ''.
*        DATA: lwa_tab5 LIKE lwa_tab4.
*        DATA: lv_temp1 TYPE string.
*        DATA: lv_temp2 TYPE string.
*        DATA: lv_tabix1 TYPE sy-tabix.
*        CLEAR: lv_temp1, lv_temp2.
*
*        CLEAR: lv_str2_tmp.
*        LOOP AT lt_tab4 INTO lwa_tab4.
*          TRANSLATE lwa_tab4-text TO UPPER CASE.
*          CONCATENATE lv_str2_tmp lwa_tab4-text INTO
*          lv_str2_tmp SEPARATED BY '|'.
*        ENDLOOP.
*        lwa_final-keys = lv_str2_tmp.
*
*        CONDENSE lwa_final-type.
*        CLEAR: lv_countc , lv_chkflg.
*        lv_str2 = lv_code.
*        DO .
*          REFRESH lt_tab4[].
*          SPLIT lv_str2 AT '' INTO TABLE lt_tab4[].
*          READ TABLE lt_tab4 INTO lwa_tab4 WITH KEY text = 'JOIN'.
*          if sy-subrc = 0.
**          IF lv_str2 CS ' JOIN '.
*            lv_countc = lv_countc + 1.
*            PERFORM get_join_tab USING lv_str2
*                                       p_index
*                                 CHANGING pt_table.
*
*          ELSE.
*            EXIT.
*          ENDIF.
*        ENDDO.
*
*        CLEAR lv_str2.
*        DATA : lwa_table1 LIKE LINE OF gt_table.
*        READ TABLE gt_table INTO lwa_table1 WITH KEY line = p_index.
*        IF sy-subrc IS INITIAL.
*          lwa_final-codenew = lwa_table1-join.
*        ENDIF.
*
**** get the table size of table used in JOIN
*        refresh : lt_tabsz1 , lt_tabsz , lt_tabcs.
*      split lwa_final-table  at '|' into table lt_tabcs[].
*      loop at lt_tabcs into lwa_tabcs.
*       lwa_tabsz-table = lwa_tabcs-text.
*       append lwa_tabsz to lt_tabsz1.
*       clear : lwa_tabsz , lwa_tabcs.
*      endloop.
*
*      delete ADJACENT DUPLICATES FROM lt_tabsz1 COMPARING table.
*      if not lt_tabsz1[] is INITIAL.
*      select tabname tabkat into table lt_tabsz
*      from dd09l
*      for all entries in lt_tabsz1
*      where tabname = lt_tabsz1-table
*      and as4local = 'A'.
*      if sy-subrc = 0.
*      sort lt_tabsz by table .
*      clear : lv_cat , lv_tbsiz .
*      LOOP AT lt_tabsz INTO lwa_tabsz.
*        IF lwa_tabsz-tabkat GE gc_two.
*          lv_cat = lwa_tabsz-tabkat.
*          CONCATENATE lv_tbsiz '|' 'Table:'
*          lwa_tabsz-table 'Size:'
*          lv_cat INTO lv_tbsiz SEPARATED BY space.
*        ENDIF.
*        CLEAR lwa_tabsz.
*      ENDLOOP.
*      endif.
*      endif.
**************************************commented after generic join
********
      ELSE.

        CLEAR pwa_code.
        READ TABLE lt_tab INTO pwa_code INDEX 1.
        TRANSLATE pwa_code TO UPPER CASE.
        lwa_final-table = lv_table = pwa_code.
        IF lv_str1 CS gc_star.   " logic to find all the fields selected
          " START-exception shouldn't stop program :
          "dump due to inactive field-
          " ashish 17th NOV
          PERFORM get_fields TABLES gt_fields
                             USING lv_table .

          lt_fields[] = gt_fields[].
          REFRESH: gt_fields[].
**
*          CALL FUNCTION 'DDIF_FIELDINFO_GET'
*            EXPORTING
*              tabname        = lv_table
*            TABLES
*              dfies_tab      = lt_fields
*            EXCEPTIONS
*              not_found      = 1
*              internal_error = 2
*              OTHERS         = 3.
*          IF sy-subrc <> 0.
*          ENDIF.
          IF lt_fields[] IS NOT INITIAL.
            LOOP AT lt_fields INTO  lwa_fields.
              DATA: lv_local TYPE string.
              CLEAR: lv_local.
              CONCATENATE  lv_table gc_tilde lwa_fields-fieldname
              INTO lv_local.
              CONCATENATE lv_local lv_fields INTO
              lv_fields SEPARATED BY gc_seperator  .
            ENDLOOP.
          ENDIF.
          " END-exception shouldn't stop program :
          " dump due to inactive field-
          " ashish 17th NOV
        ELSE.
          IF gv_join_fae = gc_x.
            lwa_final-fields  = gv_fields.
            CLEAR: gv_fields.
            REFRESH lt_tab4[].
            SPLIT lwa_final-fields AT gc_seperator INTO TABLE lt_tab4[].
            DELETE lt_tab4 WHERE text = ''.
            CLEAR:lwa_final-fields.
            LOOP AT lt_tab4 INTO lwa_tab4.
              CONCATENATE  lwa_final-fields  gc_tilde
              lwa_tab4-text gc_seperator INTO lwa_final-fields.
            ENDLOOP.
            REFRESH lt_tab4[].
          ELSE.

            " selective fields used
            REFRESH lt_tab2[].
            SPLIT lv_str1 AT space INTO TABLE lt_tab2.
            DELETE lt_tab2 WHERE text = ''.
            DELETE lt_tab2 WHERE text = gc_select.
            IF sy-subrc = 0.
              lv_index1 = sy-tabix - 1.
              IF lv_index1 GE 1.
                DELETE lt_tab2 INDEX lv_index1.
              ENDIF.
            ENDIF.

            LOOP AT lt_tab2 INTO  lwa_tab2.
              TRANSLATE lwa_tab2-text TO UPPER CASE.
              IF lwa_tab2-text = gc_from OR lwa_tab2-text = gc_into.
                EXIT.
              ENDIF.
              CLEAR: lv_local.
              CONCATENATE  lv_table gc_tilde lwa_tab2-text INTO lv_local
              .
              CONCATENATE  lv_fields lv_local INTO
              lv_fields SEPARATED BY gc_seperator.
            ENDLOOP.
            lwa_final-fields = lv_fields.
          ENDIF.
        ENDIF.
        " filter value and internal table
        REFRESH lt_tab2[].
        CLEAR: lv_str1, lv_str3.

        pwa_code = lv_code.
        REFRESH lt_tab4[].
*    SPLIT pwa_code AT space INTO TABLE lt_tab4.
*    DELETE lt_tab4 WHERE text = ''.
*    DELETE lt_tab4 WHERE text CS '(' .
*    DELETE lt_tab4 WHERE text CS ')' .
*    CLEAR: lwa_code1.
*    CLEAR: lv_line.
*    LOOP AT lt_tab4 INTO  lwa_code1.
*      TRANSLATE lwa_code1-text TO UPPER CASE.
*      IF lwa_code1-text = 'WHERE'.
*        lv_line = sy-tabix.
*      ENDIF.
*      IF lv_line IS INITIAL.
*        CONCATENATE lv_str1 lwa_code1 INTO lv_str1 SEPARATED BY space.
*      ELSE.
*        CONCATENATE lv_str3 lwa_code1 INTO lv_str3 SEPARATED BY space.
*      ENDIF.
*    ENDLOOP.
*    REPLACE FIRST OCCURRENCE OF 'WHERE' IN lv_str3 WITH ''.
*    CLEAR: lv_line.
*    REFRESH: lt_tab4[].
**           SPLIT  lv_code AT 'WHERE' INTO lv_str1 lv_str3.
*
*        CLEAR: lvj_str1, lvj_str2.
*        TRANSLATE lv_str3 TO UPPER CASE.
*        CONDENSE lv_str3.
*        lvj_str2 = lv_str3.
** finds fields used in WHERE clause of JOIN statement
*        REFRESH lt_tab4[].
*        IF lvj_str2 IS NOT INITIAL.
*          CLEAR: lv_str2_tmp.
*          CLEAR: lv_leng.
*          lv_leng = STRLEN( lvj_str2 ).
*          lv_leng = lv_leng - 1.
*          CHECK lv_leng > 0.
*          IF lvj_str2+lv_leng(1) = '.'.
*            lv_str2_tmp = lvj_str2+0(lv_leng).
*          ELSE.
*            lv_str2_tmp = lvj_str2.
*          ENDIF.
*          SPLIT lv_str2_tmp AT '' INTO TABLE lt_tab4.
*          DELETE lt_tab4[] WHERE text = ''.
*          DELETE lt_tab4[] WHERE text = 'AND'.
*          DELETE lt_tab4[] WHERE text = 'OR'.
*          DELETE lt_tab4[] WHERE text = ')'.
*          DELETE lt_tab4[] WHERE text = '('.
*          DELETE lt_tab4[] WHERE text = 'NOT'.
*" added by ashish on 09Oct -- need to remove NOT from SELECT before
*anal
*"ysis
*          CLEAR: lwa_tab4.
*          REFRESH: lt_tab3[] .
*          DATA : ch TYPE n.
*          CLEAR : lv_sytabix.
*          LOOP AT lt_tab4 INTO lwa_tab4.
*            TRANSLATE lwa_tab4-text TO UPPER CASE.
*            IF lwa_tab4-text IN gr_where[].
*              IF lwa_tab4-text = 'BETWEEN'.
*                lv_sytabix = 1.
*              ENDIF.
*
*              IF lv_sytabix = 1 AND  lwa_tab4-text = 'AND'.
*                CLEAR lv_sytabix.
*                CONTINUE.
*              ENDIF.
*              CLEAR lwa_tab4.
*              lv_stbix = sy-tabix - 1.
*              READ TABLE lt_tab4 INTO lwa_tab4 INDEX lv_stbix .
*              IF sy-subrc IS INITIAL.
*                APPEND lwa_tab4 TO lt_tab3.
*              ENDIF.
*              CLEAR : lv_stbix.
*            ENDIF.
*          ENDLOOP.
*
*          DELETE ADJACENT DUPLICATES FROM lt_tab3 COMPARING text.
*          LOOP AT lt_tab3 INTO lwa_tab4.
*            TRANSLATE lwa_tab4 TO UPPER CASE.
*            CLEAR: lv_local.
*            CONCATENATE  lv_table '~' lwa_tab4-text INTO lv_local.
*CONCATENATE lvj_str1 lv_local INTO lvj_str1 SEPARATED BY '|'
*            .
*          ENDLOOP.
*        ENDIF.
*        lwa_final-where_con = lvj_str1.

        CLEAR: lv_str1, lv_str3.
        REFRESH lt_tab4[].
        CLEAR: lv_str_tmp.
        SPLIT  lv_xwhere  AT space INTO TABLE lt_tab4.
        DELETE lt_tab4 WHERE text = ''.
        READ TABLE lt_tab4 INTO lwa_tab2 WITH  KEY text = gc_table.
        IF sy-subrc = 0.
          SPLIT  lv_code AT gc_table INTO lv_str1 lv_str3.
        ENDIF.
        REFRESH lt_tab4[].
        IF lv_str3 = ''.
          lv_flag = gc_x.
          SPLIT  lv_code AT gc_into INTO lv_str1 lv_str3.
        ENDIF.
        REPLACE FIRST OCCURRENCE OF gc_dot IN lv_str3 WITH ''.
        CONDENSE lv_str3.
        SPLIT lv_str3 AT space INTO lv_str1 lv_str3.
        IF lv_flag = gc_x.
          IF lv_str1 CS gc_corr.
            CONDENSE lv_str3.
            SPLIT  lv_str3 AT gc_of INTO lv_str3 lv_str1.
            CONDENSE lv_str1.
            SPLIT  lv_str1 AT '' INTO lv_str1 lv_str3.
          ELSE.
            IF lv_str3 IS NOT INITIAL OR lv_str1 CS gc_comma.
              CONDENSE lv_str3.
              CLEAR: lv_wac, lv_cmc.
              lv_wac = 1. " work area count
              IF lv_str1 CS gc_comma.
                lv_cmc = 1.  " comma count
              ELSE.
                CLEAR lv_cmc.
              ENDIF.
              REFRESH lt_tab4[].
              SPLIT lv_str3 AT '' INTO TABLE lt_tab4[].
              DELETE lt_tab4[] WHERE text = ''.
              LOOP AT lt_tab4 INTO lwa_tab4.
                IF lwa_tab4 CS gc_comma.
                  lv_cmc = lv_cmc + 1.
                ENDIF.
                IF strlen( lwa_tab4 ) > 1.
                  lv_wac = lv_wac + 1.
                ENDIF.
                CLEAR: lv_sub.
                lv_sub =  lv_wac - lv_cmc.
*          if lv_wac - lv_cmc > 1.
                IF lv_sub > 1.
                  EXIT.
                ELSE.
                  CONCATENATE lv_str1 lwa_tab4 INTO lv_str1
                  SEPARATED BY ''.
                ENDIF.
              ENDLOOP.
            ENDIF.
          ENDIF.
          lwa_final-wa = lv_wa = lv_str1.
        ELSE.
          lwa_final-itabs =  lv_itabs = lv_str1.
        ENDIF.
        CLEAR pwa_code.
        CLEAR lv_str1.
        DELETE lt_tab WHERE text CS gc_open_bracket .
        DELETE lt_tab WHERE text CS gc_close_bracket .
        READ TABLE lt_tab INTO pwa_code INDEX 1.
        lwa_table-progname = gv_prog.
        lwa_table-table = pwa_code.
* find table type : transparent, pool or cluster
        SELECT  SINGLE tabclass FROM dd02l INTO l_tabclass
        WHERE tabname = lwa_table-table  AND as4local = gc_a .
        IF sy-subrc = 0.
          lwa_final-type = l_tabclass.
*{ Begin of changes - rohit 12/10/2015
          IF  NOT gwa_pool_clus IS INITIAL.
            l_tabclass = gwa_pool_clus-tabclass.
            lwa_final-type = l_tabclass.
          ENDIF.
*} End of changes - rohit 12/10/2015
          CLEAR: l_tabclass.
        ENDIF.

* find table size
        CLEAR : lv_cat , lv_tbsiz.
        SELECT SINGLE tabkat FROM dd09l INTO lv_cat
        WHERE tabname = lwa_table-table  AND as4local = gc_a .
        IF sy-subrc = 0.
          CONCATENATE 'Table:' lwa_table-table
           'Size:' lv_cat INTO lv_tbsiz SEPARATED BY space.
        ENDIF.
* find primary key fields
        lv_table = lwa_table-table .
        SELECT  fieldname position FROM dd03l INTO TABLE lt_tabkey
        WHERE tabname = lv_table  AND keyflag = gc_x .
        IF sy-subrc = 0.
          CLEAR: lv_key,lv_str2_tmp.
          SORT lt_tabkey BY position.
          LOOP AT lt_tabkey INTO lwa_tabkey.
            CLEAR: lv_local.
            IF lwa_tabkey-fieldname+0(1) = gc_dot.
              CONTINUE.
            ENDIF.
            CONCATENATE  lwa_table-table gc_tilde lwa_tabkey-fieldname
             INTO lv_local.
            CONCATENATE  lv_str2_tmp lv_local INTO
            lv_str2_tmp SEPARATED BY gc_seperator .
            CLEAR:  lv_key.
          ENDLOOP.
        ENDIF.
        CONDENSE lv_str2_tmp.
        lwa_final-keys = lv_str2_tmp.

        lwa_table-line = p_index.
        APPEND lwa_table TO pt_table.

        CLEAR: lv_countc , lv_chkflg.
*        DO .
*           REFRESH lt_tab4[].
*          SPLIT lv_str2 AT '' INTO TABLE lt_tab4[].
*          READ TABLE lt_tab4 INTO lwa_tab4 WITH KEY text = 'JOIN'.
*          if sy-subrc = 0.
**          IF lv_str2 CS ' JOIN '.
*            lv_countc = lv_countc + 1.
*            PERFORM get_join_tab USING lv_str2
*                                       p_index
*                                 CHANGING pt_table.
*
*          ELSE.
*            EXIT.
*          ENDIF.
*        ENDDO.

        CLEAR lv_str2.

*        REFRESH lt_tab2[].
*        CONDENSE lv_filters.
*        SPLIT lv_filters AT space INTO TABLE lt_tab2.
*        DELETE lt_tab2 WHERE text = ''.
*        DELETE lt_tab2 WHERE text NS '-'.
*        LOOP AT lt_tab2 INTO lwa_tab2.
*          IF lwa_tab2 CS '-'.
*            SPLIT lwa_tab2 AT '-' INTO lv_str1 lv_str2.
*            lwa_tab2 = lv_str1.
*            REPLACE FIRST OCCURRENCE OF '.' IN lwa_tab2 WITH ''.
*            CONDENSE lwa_tab2.
*            if sy-tabix GE 1.
*            MODIFY lt_tab2 FROM lwa_tab2 INDEX sy-tabix.
*            endif.
*          ENDIF.
*        ENDLOOP.
*        SORT lt_tab2 BY text.
*        DELETE ADJACENT DUPLICATES FROM lt_tab2 COMPARING ALL FIELDS.
*
*        LOOP AT lt_tab2 INTO lwa_tab2.
*          CONCATENATE lwa_tab2 lv_loop INTO lv_loop SEPARATED BY '|'.
*        ENDLOOP.

        lwa_final-code  = lv_original.
        lwa_final-table = pwa_code.
        lwa_final-prog   = gv_prog.
        lwa_final-line = p_index.
*        lwa_final-fields = lv_fields.
        lwa_final-itabs = lv_itabs.
        lwa_final-wa = lv_wa.
        lwa_final-drill = gv_drill.
        lwa_final-filters = lv_filters.
        lwa_final-loop = lv_loop.
*         PERFORM append_final USING lwa_final.
*      CLEAR: lwa_final-check, lwa_final-critical.
      ENDIF.
    ENDIF.

*    lwa_final-code = lv_code.
    lwa_final-code = lv_original.
    CLEAR gv_codenew.

*==========================
*Check for DB HINTS uses in SELECT statement
*==========================
    IF lwa_final-code  CS gc_per_hint.
      lwa_final-opercd = gc_13.
      lwa_final-obj_name = gs_progname-progname.
      lwa_final-prog    = gv_prog.
      lwa_final-line    = p_index.
      lwa_final-drill   = gv_drill.
      PERFORM append_final USING lwa_final.
      CLEAR: lwa_final-check, lwa_final-critical.
    ENDIF.

*==========================
*Check for BYPASS TABLE BUFFER uses in SELECT statement
*==========================
*    IF lwa_final-code  CS 'MAX' OR
*       lwa_final-code  CS 'BYPASSING DISTINCT' OR
*       lwa_final-code  CS 'MIN' OR lwa_final-code  CS 'AVG' OR
*       lwa_final-code  CS 'SUM' OR lwa_final-code  CS 'COUNT' OR
*       lwa_final-code  CS 'BUFFER' OR lwa_final-code  CS 'GROUP BY' . "
*    IF lv_xwhere  CS 'MAX' OR  lv_xwhere  CS 'FOR UPDATE' OR
*lv_wsel =
*    'X' OR
*       lv_xwhere  CS 'BYPASSING DISTINCT' OR
*       lv_xwhere  CS 'MIN' OR lv_xwhere  CS 'AVG' OR
*       lv_xwhere  CS 'SUM' OR lv_xwhere  CS 'COUNT' OR
*       lv_xwhere  CS 'BUFFER' OR  lv_xwhere  CS 'DISTINCT'
*    OR lwa_final-code  CS 'ORDER BY' OR lwa_final-code  CS 'GROUP BY' .
    IF    lv_xwhere  CS gc_bypas_buff.
      "

      lwa_final-opercd = gc_37.
      lwa_final-obj_name = gs_progname-progname.
      lwa_final-line     = p_index.
      lwa_final-drill    = gv_drill.
      lwa_final-prog     = gv_prog.
      PERFORM append_final USING lwa_final.
      CLEAR: lwa_final-check, lwa_final-critical.
    ENDIF.

*==========================
*Check for JOIN uses in SELECT statement
*==========================
*    IF lwa_final-code  CS ' JOIN '.
*      lwa_final-opercd = gc_39.
*      lwa_final-obj_name = gs_progname-progname.
*      lwa_final-line     = p_index.
*      lwa_final-drill    = gv_drill.
*      lwa_final-prog     = gv_prog.
*      PERFORM append_final USING lwa_final.
*      CLEAR: lwa_final-check, lwa_final-critical.
*    ENDIF.

*==========================
*Check for NEGATIVE OPERTAION in WHERE clause of SELECT statement
*==========================
    IF lv_neg_where  EQ gc_x .
      lwa_final-opercd = gc_56.
      lwa_final-obj_name = gs_progname-progname.
      lwa_final-line     = p_index.
      lwa_final-drill    = gv_drill.
      lwa_final-prog     = gv_prog.
      PERFORM append_final USING lwa_final.
      CLEAR: lwa_final-check, lwa_final-critical.
    ENDIF.

*==========================
*Check for table size GE 2 of tables used in SELECT statement
*==========================
    IF lv_cat  GE gc_two .
      lwa_final-opercd = gc_99.
      lwa_final-obj_name = gs_progname-progname.
      lwa_final-line     = p_index.
      lwa_final-drill    = gv_drill.
      lwa_final-prog     = gv_prog.
      lwa_final-check    = lv_tbsiz.
      PERFORM append_final USING lwa_final.
      CLEAR: lwa_final-check, lwa_final-critical.
    ENDIF.

    IF lv_code NS gc_for_all_ent.


***    IF lv_code CS 'INTO TABLE'.
***      CHECK  lv_code NS 'SELECT *'.
***      CHECK lv_code NS 'SELECT SINGLE'.
***      lwa_final-opercd = '36'.
***      lwa_final-drill     = gv_drill.
***      lwa_final-obj_name  = gs_progname-progname.
***      lwa_final-line      = p_index.
***      lwa_final-prog      = gv_prog.
***      PERFORM get_crit CHANGING lwa_final.
***      PERFORM append_final USING lwa_final.
***      CLEAR: lwa_final-check, lwa_final-critical.
***    ENDIF.

*==========================
*Check for select with fields in SELECT statement
*==========================
*      IF lv_code CS 'INTO CORRESPONDING FIELDS OF'
*         OR lv_code CS 'APPENDING CORRESPONDING FIELDS OF TABLE' OR
*         lv_code CS 'APPENDING TABLE' .
*         " 27oct ashish - added appending table clause
*        CHECK  lv_code NS 'SELECT *'.
*        CHECK lv_code NS 'SELECT SINGLE *'.
      IF lv_xwhere CS gc_corr_field_of
         OR lv_xwhere CS gc_app_corr OR
         lv_xwhere CS gc_app_tab .
        " 27oct ashish - added appending table clause
        CHECK  lv_xwhere NS gc_select_str.
        CHECK lv_xwhere NS gc_select_sing_str.
        lwa_final-opercd   = gc_36.
        lwa_final-drill    = gv_drill.
        lwa_final-obj_name = gs_progname-progname.
        lwa_final-line     = p_index.
        lwa_final-prog     = gv_prog.
        PERFORM get_crit CHANGING lwa_final.
        PERFORM append_final USING lwa_final.
        CLEAR: lwa_final-check, lwa_final-critical.
      ENDIF.  "10OCTSHEKHAR
****    ELSE.  "10OCTSHEKHAR

*==========================
*Check for ENDSELECT in SELECT statement
*==========================
      lp_nest_ind = gc_x.
*      IF ( lv_code CS 'INTO TABLE'                             OR
*           lv_code CS 'INTO CORRESPONDING FIELDS OF TABLE'     OR
*           lv_code CS 'APPENDING TABLE'                        OR
*           lv_code CS 'APPENDING CORRESPONDING FIELDS OF TABLE' )  AND
*           lv_code NS 'PACKAGE SIZE'.
      IF ( lv_xwhere CS gc_into_tab                             OR
           lv_xwhere CS gc_into_corr     OR
           lv_xwhere CS gc_app_tab                        OR
           lv_xwhere CS gc_app_corr )  AND
          lv_code NS gc_pkg_size.
        lp_nest_ind = space.
      ENDIF.
*      IF lv_code CS 'SELECT SINGLE'.
      IF lv_xwhere CS gc_select_sing.
        lp_nest_ind = space.
      ENDIF.

*      IF  ( lv_code  CS 'MAX' OR
*            lv_code  CS 'MIN' OR lv_code  CS 'AVG' OR
*            lv_code  CS 'SUM' OR lv_code  CS 'COUNT' )
*           AND  lv_code  NS 'GROUP BY' .
      IF  ( lv_xwhere  CS gc_max OR
                lv_xwhere  CS gc_min OR lv_xwhere  CS gc_avg OR
                lv_xwhere  CS gc_sum OR lv_xwhere  CS gc_count )
               AND  lv_code   NS gc_grp_by .
        lp_nest_ind = space.
      ENDIF.

      IF lp_nest_ind = gc_x.

        CLEAR : lwa_final-code.
        lwa_final-code  = lv_code.
        lwa_final-prog   = gv_prog.
        lwa_final-obj_name = gs_progname-progname.
        lwa_final-line = p_index.
        lwa_final-check = 'SELECT-ENDSELECT'.
        lwa_final-opercd = gc_33.
        lwa_final-drill = gv_drill .
        lwa_final-corr = gc_x.
        IF lwa_final-drill LT 1.
          lwa_final-critical = gc_medium.
        ELSE.
          lwa_final-critical = gc_high.
        ENDIF.
        PERFORM append_final USING lwa_final.

*endselect is assumed, so its kind of LOOP, need to save the starting
*line and increase the nesting counter.
        IF gv_drill = 0 OR gv_loop_line IS INITIAL.
          gv_loop_line = p_index.
        ENDIF.
        gv_drill = gv_drill + 1.
        IF gv_drill > gv_drill_max.
          gv_drill_max = gv_drill_max + 1.
        ENDIF.

***pool /cluster table
*      IF gs_final-type CS 'POOL' OR gs_final-type CS 'CLUSTER'.
        IF ( lwa_final-type CS gc_pool OR lwa_final-type CS gc_cluster )
          AND ( lwa_final-code NS gc_ord_by ) .
          lwa_final-opercd   = gc_16.
          lwa_final-drill    = gv_drill.
          lwa_final-obj_name = gs_progname-progname.
          lwa_final-line     = p_index.
          lwa_final-prog     = gv_prog.
          PERFORM get_crit CHANGING lwa_final.
          PERFORM append_final USING lwa_final.
        ENDIF.
*        clear: lwa_final-check, lwa_final-critical.
****?????????????????????*****
        gv_flag_e = gc_x.
        lwa_final-check = 'SELECT-ENDSELECT WITHIN LOOP'.
        lwa_final-drill = gv_drill.
        lwa_final-corr = gc_x.
        PERFORM get_crit CHANGING lwa_final.

        DATA : new_f TYPE string.
        CONCATENATE 'NESTING ON SELECT STATEMENTS TABLE TYPE -'
        lwa_final-type INTO new_f SEPARATED BY space.
        lwa_final-oper = new_f.
        lwa_final-opercd = '7'.
        lwa_final-act_st = 'Recommended DB level HANA optimizations '.
        CLEAR : new_f.
        IF lwa_final-check IS NOT INITIAL AND gv_drill GT 0.
          CLEAR: lwa_final.
        ENDIF.
*****************

        lu_flag     = gc_x.
        IF lv_code NS 'UP TO'.
          gv_flag_d = gc_x.
          gv_flag_e = gc_x.
        ENDIF.
      ENDIF.
*    ENDIF. "10OCTSHEKHAR
    ENDIF.

*==========================
*In Case of FAE in statement convert that to JOIN for updating in
*Detection table
*==========================
    "for all entries (FAE) - ASSUMPTIONS: 1. internal table is already
    "filled up 2. Scan based on MODIFY/UPDATE/INSERT/DELETE commands on
    "internal table
    "3. Assignment of internal table to other table not taken care of 4.
    "convert into INNER JOIN
    IF lv_code CS gc_for_all_ent_spc.
      CLEAR: lv_str1, lv_str2.
      CLEAR: lv_str3.
      lv_code = lv_xwhere.
      TRANSLATE lv_code TO UPPER CASE.

*SPLIT lwa_final-code AT 'FOR ALL ENTRIES IN' INTO lv_str1 lv_str2.
      SPLIT lv_code AT gc_for_all_ent_in INTO lv_str1 lv_str2.
      CONDENSE lv_str2.
      SPLIT lv_str2 AT '' INTO lv_str2 lv_str1.

      lv_str3 = lv_str2.
      CLEAR: gs_gt_final.
      SORT gt_final BY prog ASCENDING type ASCENDING  line DESCENDING.
      READ TABLE gt_final INTO gs_gt_final
      WITH KEY obj_name = gs_progname-progname
                   prog =  lwa_final-prog
*type = lwa_final-type  " commented by ashish 08 oct --type is not
*required
                   itabs =  lv_str2 .
      " find where right table of FAE is being filled up!
      IF sy-subrc = 0.

        lwa_final-code  = gv_org_code.
        CLEAR: lv_str1, lv_str2.
        DATA: lv_len1 TYPE i.
        DATA: lv_len2 TYPE i.
        CLEAR: lv_len1, lv_len2.
        lv_len1 = strlen( lwa_final-table ).
        lv_len2 = strlen( gs_gt_final-table ).

        IF lwa_final-table IS NOT INITIAL.
          IF lwa_final-table+0(1) = gc_seperator.
            lv_len1 = lv_len1 - 1.
            lwa_final-table = lwa_final-table+1(lv_len1).
          ENDIF.
          lv_len1 = lv_len1 - 1.
          IF lv_len1 >= 0.
            IF lwa_final-table+lv_len1(1) = gc_seperator.
              lwa_final-table = lwa_final-table+0(lv_len1).
            ENDIF.
          ENDIF.
        ENDIF.

        IF gs_gt_final-table IS NOT INITIAL.
          IF gs_gt_final-table+0(1) = gc_seperator.
            lv_len2 = lv_len2 - 1.
            gs_gt_final-table = gs_gt_final-table+1(lv_len2).
          ENDIF.
          lv_len2 = lv_len2 - 1.
          IF lv_len2 >= 0.
            IF gs_gt_final-table+lv_len2(1) = gc_seperator.
              gs_gt_final-table = gs_gt_final-table+0(lv_len2).
            ENDIF.
          ENDIF.
        ENDIF.

        DATA: lv_tab TYPE dd03l-tabname.
        CLEAR: lv_tab.
        lv_tab = lwa_final-table.
        CONCATENATE   lwa_final-table  gs_gt_final-table INTO
        lwa_final-table SEPARATED BY gc_seperator.

        CLEAR: lv_len1, lv_len2.
        lv_len1 = strlen( lwa_final-type ).
        lv_len2 = strlen( gs_gt_final-type ).

        IF lwa_final-type IS NOT INITIAL.
          IF lwa_final-type+0(1) = gc_seperator.
            lv_len1 = lv_len1 - 1.
            lwa_final-type = lwa_final-type+1(lv_len1).
          ENDIF.
          lv_len1 = lv_len1 - 1.
          IF lwa_final-type+lv_len1(1) = gc_seperator.
            lwa_final-type = lwa_final-type+0(lv_len1).
          ENDIF.
        ENDIF.

        IF gs_gt_final-type IS NOT INITIAL.
          IF gs_gt_final-type+0(1) = gc_seperator.
            lv_len2 = lv_len2 - 1.
            gs_gt_final-type = gs_gt_final-type+1(lv_len2).
          ENDIF.
          lv_len2 = lv_len2 - 1.
          IF gs_gt_final-type+lv_len2(1) = gc_seperator.
            gs_gt_final-type = gs_gt_final-type+0(lv_len2).
          ENDIF.
        ENDIF.

        CONCATENATE   lwa_final-type  gs_gt_final-type
        INTO lwa_final-type SEPARATED BY gc_seperator.

        CLEAR: lv_len1, lv_len2.
        lv_len1 = strlen( lwa_final-join ).
        lv_len2 = strlen( gs_gt_final-join ).

        IF lwa_final-join IS NOT INITIAL.
          IF lwa_final-join+0(1) = gc_seperator.
            lv_len1 = lv_len1 - 1.
            lwa_final-join = lwa_final-join+1(lv_len1).
          ENDIF.
          lv_len1 = lv_len1 - 1.
          IF lwa_final-join+lv_len1(1) = gc_seperator.
            lwa_final-join = lwa_final-join+0(lv_len1).
          ENDIF.
        ENDIF.

        lwa_final-join = gc_yes.

        CLEAR: lv_len1, lv_len2.
        lv_len1 = strlen( lwa_final-keys ).
        lv_len2 = strlen( gs_gt_final-keys ).

        IF lwa_final-keys IS NOT INITIAL.
          IF lwa_final-keys+0(1) = gc_seperator.
            lv_len1 = lv_len1 - 1.
            lwa_final-keys = lwa_final-keys+1(lv_len1).
          ENDIF.
          lv_len1 = lv_len1 - 1.
          IF lv_len1 >= 0.
            IF lwa_final-keys+lv_len1(1) = gc_seperator.
              lwa_final-keys = lwa_final-keys+0(lv_len1).
            ENDIF.
          ENDIF.
        ENDIF.

        IF gs_gt_final-keys IS NOT INITIAL.
          IF gs_gt_final-keys+0(1) = gc_seperator.
            lv_len2 = lv_len2 - 1.
            gs_gt_final-keys = gs_gt_final-keys+1(lv_len2).
          ENDIF.

          lv_len2 = lv_len2 - 1.
          IF lv_len2 >= 0.
            IF gs_gt_final-keys+lv_len2(1) = gc_seperator.
              gs_gt_final-keys = gs_gt_final-keys+0(lv_len2).
            ENDIF.
          ENDIF.
        ENDIF.

        CONCATENATE   lwa_final-keys  gs_gt_final-keys
        INTO lwa_final-keys SEPARATED BY gc_seperator.
        CONDENSE lwa_final-keys.
        REFRESH lt_tab2[].
        SPLIT lwa_final-keys AT gc_seperator INTO TABLE lt_tab2.
        DELETE lt_tab2 WHERE text = ''.
        SORT lt_tab2 BY text.
        DELETE ADJACENT DUPLICATES FROM lt_tab2 COMPARING text.

        CLEAR: lwa_final-keys.
        LOOP AT lt_tab2 INTO lwa_tab2.
          CLEAR: lv_str1, lv_str2.
          SPLIT lwa_tab2-text AT gc_tilde INTO lv_str1 lv_str2.
          IF lwa_final-keys CS lv_str2.
            CONTINUE.
          ENDIF.
          CONCATENATE lwa_tab2 lwa_final-keys INTO lwa_final-keys
          SEPARATED BY gc_seperator.
        ENDLOOP.

        REFRESH lt_tab2[].

        CLEAR: lv_len1, lv_len2.
        lv_len1 = strlen( lwa_final-where_con ).
        lv_len2 = strlen( gs_gt_final-where_con ).

        IF lwa_final-where_con IS NOT INITIAL.
          IF lwa_final-where_con+0(1) = gc_seperator.
            lv_len1 = lv_len1 - 1.
            lwa_final-where_con = lwa_final-where_con+1(lv_len1).
          ENDIF.
          lv_len1 = lv_len1 - 1.
          IF lv_len1 >= 0.
            IF lwa_final-where_con+lv_len1(1) = gc_seperator.
              lwa_final-where_con = lwa_final-where_con+0(lv_len1).
            ENDIF.
          ENDIF.
        ENDIF.

        IF gs_gt_final-where_con IS NOT INITIAL.
          IF gs_gt_final-where_con+0(1) = gc_seperator.
            lv_len2 = lv_len2 - 1.
            gs_gt_final-where_con = gs_gt_final-where_con+1(lv_len2).
          ENDIF.
          lv_len2 = lv_len2 - 1.
          IF lv_len2 >= 0.
            IF gs_gt_final-where_con+lv_len2(1) = gc_seperator.
              gs_gt_final-where_con = gs_gt_final-where_con+0(lv_len2).
            ENDIF.
          ENDIF.
        ENDIF.

        CLEAR: lv_len2.
        lv_len2 = strlen( gs_gt_final-fields ).

        IF gs_gt_final-fields IS NOT INITIAL.
          IF gs_gt_final-fields+0(1) = gc_seperator.
            lv_len2 = lv_len2 - 1.
            gs_gt_final-fields = gs_gt_final-fields+1(lv_len2).
          ENDIF.
          lv_len2 = lv_len2 - 1.
          IF lv_len2 >= 0.
            IF gs_gt_final-fields+lv_len2(1) = gc_seperator.
              gs_gt_final-fields = gs_gt_final-fields+0(lv_len2).
            ENDIF.
          ENDIF.
        ENDIF.

        CONCATENATE   lwa_final-where_con  gs_gt_final-where_con
*gs_gt_final-fields INTO lwa_final-where_con SEPARATED BY '|'."changes
*on 300092014 for unwanted fields
         INTO lwa_final-where_con SEPARATED BY gc_seperator.
        " by atul gandhi
        CONDENSE lwa_final-where_con.
        REFRESH lt_tab2[].
        SPLIT lwa_final-where_con AT gc_seperator INTO TABLE lt_tab2.
        DELETE lt_tab2 WHERE text = ''.
        SORT lt_tab2 BY text.
        DELETE ADJACENT DUPLICATES FROM lt_tab2 COMPARING text.

        CLEAR: lwa_final-where_con.
        LOOP AT lt_tab2 INTO lwa_tab2.
          CLEAR: lv_str1, lv_str2.
          SPLIT lwa_tab2-text AT gc_tilde INTO lv_str1 lv_str2.
          IF lwa_final-where_con CS lv_str2.
            CONTINUE.
          ENDIF.
          CONCATENATE lwa_tab2 lwa_final-where_con INTO
          lwa_final-where_con SEPARATED BY gc_seperator.
        ENDLOOP.

        CLEAR: lv_len1, lv_len2.
        lv_len2 = strlen( gs_gt_final-codenew ).

        IF gs_gt_final-codenew IS NOT INITIAL.
          IF gs_gt_final-codenew+0(1) = gc_seperator.
            lv_len2 = lv_len2 - 1.
            gs_gt_final-codenew = gs_gt_final-codenew+1(lv_len2).
          ENDIF.
          lv_len2 = lv_len2 - 1.
          IF lv_len2 >= 0.
            IF gs_gt_final-codenew+lv_len2(1) = gc_seperator.
              gs_gt_final-codenew = gs_gt_final-codenew+0(lv_len2).
            ENDIF.
          ENDIF.
        ENDIF.
        CONCATENATE   gc_inner  gs_gt_final-codenew INTO
        lwa_final-codenew SEPARATED BY gc_seperator.

        SELECT  fieldname  FROM dd03l
                           INTO TABLE lt_tabkey
                           WHERE tabname = lv_tab
                           AND keyflag = gc_x .
        IF sy-subrc = 0.
          REFRESH lt_tab2[].
          CLEAR: lv_key,lv_str2_tmp.
          LOOP AT lt_tabkey INTO lwa_tabkey.
            IF lwa_tabkey-fieldname+0(1) = gc_dot.
              CONTINUE.
            ENDIF.
            CONCATENATE  lv_tab gc_tilde lwa_tabkey-fieldname INTO
            lwa_tab2.
            APPEND lwa_tab2 TO lt_tab2.
          ENDLOOP.
        ENDIF.

        CLEAR lv_len2.
        lv_len2 = strlen( gs_gt_final-table ).
        IF gs_gt_final-table IS NOT INITIAL.
          IF gs_gt_final-table+0(1) = gc_seperator.
            lv_len2 = lv_len2 - 1.
            gs_gt_final-table = gs_gt_final-table+1(lv_len2).
          ENDIF.
          lv_len2 = lv_len2 - 1.
          IF lv_len2 >= 0.
            IF gs_gt_final-table+lv_len2(1) = gc_seperator.
              gs_gt_final-table = gs_gt_final-table+0(lv_len2).
            ENDIF.
          ENDIF.
        ENDIF.

        CONDENSE gs_gt_final-table.
        SPLIT gs_gt_final-table AT gc_seperator INTO lv_str1 lv_str2.
        CLEAR: lv_table.
        lv_table = lv_str1.

        SELECT  fieldname
                FROM dd03l
                INTO TABLE lt_tabkey
                WHERE tabname = lv_table
                AND   keyflag = gc_x .
        IF sy-subrc = 0.
          REFRESH lt_tab3[].
          CLEAR: lv_key,lwa_tab2.
          DATA: lv_str5 TYPE char30.
          DATA: lwa_tab9 LIKE lwa_tab2.
          LOOP AT lt_tab2 INTO lwa_tab9.
            CLEAR: lv_str1, lv_str5.
            CONDENSE lwa_tab9.
            SPLIT lwa_tab9 AT gc_tilde INTO lv_str1 lv_str5.
            LOOP AT lt_tabkey INTO lwa_tabkey WHERE fieldname = lv_str5.
              IF lwa_tabkey-fieldname+0(1) = gc_dot.
                CONTINUE.
              ENDIF.
              CONCATENATE lv_table gc_tilde lwa_tabkey INTO lv_str1.
              CONCATENATE   lwa_tab9  '=' lv_str1
              INTO lwa_tab2 SEPARATED BY ''.
              APPEND lwa_tab2 TO lt_tab3.
            ENDLOOP.
          ENDLOOP.
        ENDIF.

*start of change by ashish - 08 oct -- incorrect filter field was passed
*before
*      loop at lt_tab3 into lwa_tab2.
*        concatenate lwa_final-filtrnew lwa_tab2-text into
*        lwa_final-filtrnew separated by ''.
*      endloop.
*
*      clear lv_len2.
*      if gs_gt_final-filtrnew is not initial.
*        lv_len2 = strlen( gs_gt_final-filtrnew ).
*        if gs_gt_final-filtrnew+0(1) = '|'.
*          lv_len2 = lv_len2 - 1.
*          gs_gt_final-filtrnew = gs_gt_final-filtrnew+1(lv_len2).
*        endif.
*        lv_len2 = lv_len2 - 1.
*        if lv_len2 >= 0.
*          if gs_gt_final-filtrnew+lv_len2(1) = '|'.
*            gs_gt_final-filtrnew = gs_gt_final-filtrnew+0(lv_len2).
*          endif.
*        endif.
*      endif.
*      concatenate lwa_final-filtrnew  gs_gt_final-filtrnew into
*      lwa_final-filters separated by ''.
*      replace all occurrences of '|' in lwa_final-filters with ''.
*      condense lwa_final-filters.
*    endif.
        LOOP AT lt_tab3 INTO lwa_tab2.
          CONCATENATE lwa_final-filters lwa_tab2-text INTO
          lwa_final-filters SEPARATED BY ''.
        ENDLOOP.

        CLEAR lv_len2.
        IF gs_gt_final-filters IS NOT INITIAL.
          lv_len2 = strlen( gs_gt_final-filters ).
          IF gs_gt_final-filters+0(1) = gc_seperator.
            lv_len2 = lv_len2 - 1.
            gs_gt_final-filters = gs_gt_final-filters+1(lv_len2).
          ENDIF.
          lv_len2 = lv_len2 - 1.
          IF lv_len2 >= 0.
            IF gs_gt_final-filters+lv_len2(1) = gc_seperator.
              gs_gt_final-filters = gs_gt_final-filters+0(lv_len2).
            ENDIF.
          ENDIF.
        ENDIF.
        CONCATENATE lwa_final-filters  gs_gt_final-filters INTO
        lwa_final-filters SEPARATED BY ''.
        REPLACE ALL OCCURRENCES OF gc_seperator IN lwa_final-filters
        WITH ''.
        CONDENSE lwa_final-filters.
      ENDIF.
*end of change by ashish - 08 oct -- incorrect filter field was passed
*before

*check if internal table has been changed between selection and FAE
      DATA: lt_local LIKE gt_code.
      DATA: lwa_local TYPE ty_code.
      REFRESH lt_local[].
      READ REPORT gv_prog INTO lt_local.
      CHECK sy-subrc = 0.

      DATA : wa_new  TYPE n,
             lwa_new TYPE n.
      wa_new = gs_gt_final-line + 1.
      lwa_new = lwa_final-line - 1.

      LOOP AT lt_local INTO lwa_local FROM wa_new  TO lwa_new.
        CONDENSE lwa_local-text.
        TRANSLATE  lwa_local-text TO UPPER CASE.
        IF lwa_local-text = '' OR lwa_local-text+0(1) = gc_star OR
        lwa_local-text+0(1) = gc_doub_quote.
          CONTINUE.
        ENDIF.
        IF ( lwa_local-text CS lv_str3 AND lwa_local-text CS gc_modify )
        OR ( lwa_local-text CS lv_str3 AND lwa_local-text CS gc_update )
        OR ( lwa_local-text CS lv_str3 AND lwa_local-text CS gc_insert )
        OR ( lwa_local-text CS lv_str3 AND lwa_local-text CS gc_delete )
        .
          lwa_final-corr = ''.
        ELSE.
          lwa_final-corr = gc_x.
        ENDIF.
      ENDLOOP.

*==========================
*Check for FOR ALL ENTRIES uses in SELECT statement
*==========================
      CLEAR : wa_new , lwa_new.
      lwa_final-code  = lv_code.
      lwa_final-obj_name = gs_progname-progname.
      lwa_final-opercd = gc_40.
      lwa_final-drill = gv_drill.
      lwa_final-prog = gv_prog.
      lwa_final-line = p_index.
      PERFORM append_final USING lwa_final.

*==========================
*JOIN and FAE together
*==========================

      IF lv_join = gc_x.
        lwa_final-code  = lv_code.
        lwa_final-obj_name = gs_progname-progname.
        lwa_final-opercd = gc_58.
        lwa_final-drill = gv_drill.
        lwa_final-prog = gv_prog.
        lwa_final-line = p_index.
        PERFORM append_final USING lwa_final.
      ENDIF.

*==========================
*Check for FOR ALL ENTRIES used in SELECT statement but INITIAL check
* on FAE internal table is missing
*==========================
      CLEAR gt_f_code.
* start replace FM with Form

*      CALL FUNCTION 'ZAUCT_FIND_STR'
*        EXPORTING
*          p_name       = gv_prog
*          code_string  = lv_str3
*          line_no      = lwa_final-line
*          p_type       = 'F'
*        IMPORTING
*          lv_not_found = gv_nt_found
*        TABLES
*          it_fcode     = gt_f_code.

***pool /cluster table
*      IF gs_final-type CS 'POOL' OR gs_final-type CS 'CLUSTER'.
      IF ( lwa_final-type CS gc_pool OR lwa_final-type CS gc_cluster )
      AND
         ( lwa_final-code NS gc_ord_by )  .
        CHECK lwa_final-type NS gc_pool_sep
        AND lwa_final-type NS gc_clus_sep.
        lwa_final-opercd   = gc_16.
        lwa_final-drill    = gv_drill.
        lwa_final-obj_name = gs_progname-progname.
        lwa_final-line     = p_index.
        lwa_final-prog     = gv_prog.
        PERFORM get_crit CHANGING lwa_final.
        PERFORM append_final USING lwa_final.
        CLEAR: lwa_final-check, lwa_final-critical.
      ENDIF.

      PERFORM get_scan TABLES gt_f_code
                       USING gv_prog lv_str3 gc_zero lwa_final-line gc_f
                       ''
                       CHANGING gv_nt_found.
* end replace FM with FORM

      IF gt_f_code IS INITIAL.
        CLEAR lwa_final.
        lwa_final-code  = lv_code.
        lwa_final-prog  = gv_prog.
        lwa_final-line  = p_index.
        lwa_final-obj_name = gs_progname-progname.
        lwa_final-opercd = gc_41.
        lwa_final-drill = gv_drill.
        PERFORM append_final USING lwa_final.
      ENDIF.
      CLEAR : gv_nt_found.
      FREE : gt_f_code.
    ENDIF.

***pool /cluster table
*      IF gs_final-type CS 'POOL' OR gs_final-type CS 'CLUSTER'.
    IF ( lwa_final-type CS gc_pool OR lwa_final-type CS gc_cluster ) AND
       ( lwa_final-code NS gc_ord_by )  .
*Start of change DEF_18
      IF ( lwa_final-code CS 'SELECT SINGLE' ) .
*End of change DEF_18
      ELSE.
        lwa_final-opercd   = gc_16.
        lwa_final-drill    = gv_drill.
        lwa_final-obj_name = gs_progname-progname.
        lwa_final-line     = p_index.
        lwa_final-prog     = gv_prog.
        PERFORM get_crit CHANGING lwa_final.
        PERFORM append_final USING lwa_final.
        CLEAR: lwa_final-check, lwa_final-critical.
*Start of change DEF_18
      ENDIF.
*End of change DEF_18
    ENDIF.
    CLEAR: lwa_final.

*Catch system exceptions
  ENDCATCH.
  IF sy-subrc <> 0.
    WRITE:/ gc_error ,'Error code:', sy-subrc , '=>Perform GET_DB_HITS'.
  ENDIF.
*Catch system exceptions

ENDFORM.                    " GET_DB_HITS

*&---------------------------------------------------------------------*
*&      Form  F_PROCESS_PERFORM
*&---------------------------------------------------------------------*
*Process the subroutine
*----------------------------------------------------------------------*
*      -->P_CODE1  Source code of the program
*      -->PWA_CODE Current line code
*      -->P_INDEX  Current line number
*----------------------------------------------------------------------*
FORM f_process_perform  USING    p_code1 LIKE gt_code
                                 pwa_code
                                 p_index TYPE sy-tabix.

  DATA: gv_prog98 TYPE progname.
*Catch system exceptions
  CATCH SYSTEM-EXCEPTIONS arithmetic_errors             = 1
                          create_data_errors            = 2
                          conversion_errors             = 3
                          create_object_errors          = 4
                          data_access_errors            = 5
                          assign_casting_illegal_cast   = 6
                          assign_casting_unknown_type   = 7
                          assign_field_not_in_range     = 8
                          data_offset_too_large         = 9
                          dyn_call_meth_not_implemented = 10
                          export_buffer_no_memory       = 11
                          generate_subpool_dir_full     = 12
                          move_cast_error               = 13
                          perform_program_name_too_long = 14
                          replace_infinite_loop         = 15
                          remote_call_errors            = 16
                          localization_errors           = 17
                          import_mismatch_errors        = 18
                          dynamic_call_method_errors    = 19
                          file_access_errors            = 20
                          OTHERS                        = 99.
*Catch system exceptions

    DATA: lv_subroutine TYPE          string,
          lv_str1       TYPE          char100,
          lv_col        TYPE          i,
          lt_code       TYPE TABLE OF ty_code,
          lf_form       TYPE          c,
          lwa_include   TYPE          ty_tables.


    lv_subroutine = pwa_code+3.
    SPLIT lv_subroutine AT gc_using INTO lv_subroutine lv_str1.
    SPLIT lv_subroutine AT gc_changing INTO lv_subroutine lv_str1.
    SPLIT lv_subroutine AT gc_tables INTO lv_subroutine lv_str1.
    FIND gc_dot IN lv_subroutine MATCH OFFSET lv_col.
    IF lv_col IS NOT INITIAL.
      lv_subroutine = lv_subroutine(lv_col).
    ENDIF.

    CLEAR: lv_col, lv_str1.
    FIND gc_open_bracket IN lv_subroutine.
    IF sy-subrc = 0 .
*    check dynamic calls of routine
      SPLIT lv_subroutine AT gc_open_bracket INTO lv_subroutine lv_str1.
      FIND gc_close_bracket IN lv_str1 MATCH OFFSET lv_col.
      IF lv_col IS NOT INITIAL.
        lv_str1 = lv_str1(lv_col).
      ENDIF.
    ENDIF.
    gv_per_rec = lv_subroutine.

*Fill global internal table to subroutine to process 2 times if its
*already processed
    CLEAR gs_form_processed.
    DATA: ls_form_processed     LIKE LINE OF gt_form_processed,
          ls_form_lvl_processed LIKE LINE OF gt_form_lvl_processed.
    CLEAR: gs_form_processed, gs_form_lvl_processed.
    READ TABLE gt_form_processed INTO gs_form_processed
                        WITH KEY obj_name = gs_progname-progname
                                     form = lv_subroutine
                                     line = p_index.
    IF sy-subrc NE 0 .
      ls_form_processed-obj_name = gs_progname-progname.
      ls_form_processed-form  = lv_subroutine.
      ls_form_processed-line = p_index.
      ls_form_processed-done = gc_x.
      APPEND ls_form_processed TO gt_form_processed.
    ELSE.
      IF gs_form_processed-done IS INITIAL.
        gs_form_processed-done = gc_x.
        MODIFY gt_form_processed FROM gs_form_processed
        TRANSPORTING done.
        CLEAR gs_form_processed.
      ENDIF.
    ENDIF.
    READ TABLE gt_form_lvl_processed INTO gs_form_lvl_processed
                        WITH KEY obj_name = gs_progname-progname
                                     form = lv_subroutine
                                     level = gv_drill.
    IF sy-subrc NE 0.
      ls_form_lvl_processed-obj_name = gs_progname-progname.
      ls_form_lvl_processed-form  = lv_subroutine.
      ls_form_lvl_processed-level = gv_drill.
      APPEND ls_form_lvl_processed TO gt_form_lvl_processed.
    ENDIF.

    IF gs_form_processed IS NOT INITIAL OR
       gs_form_lvl_processed IS NOT INITIAL.
      RETURN.
    ENDIF.

*Avoid processing of subroutined exists in the standard programs
    IF lv_str1 IS NOT INITIAL.
      CONDENSE lv_str1.
      TRANSLATE lv_str1 TO UPPER CASE.
      IF lv_str1 CS gc_saplz OR
         lv_str1 CS gc_saply OR
         lv_str1 CS gc_sapmz OR
         lv_str1 CS gc_sapmy OR
         lv_str1+0(2) EQ gc_lz OR
         lv_str1+0(2) EQ gc_ly OR
         lv_str1+0(2) EQ gc_mz OR
         lv_str1+0(2) EQ gc_my OR
         lv_str1+0(1) EQ gc_z OR
         lv_str1+0(1) EQ gc_y OR
* Begin of change by Rahul 08072015
         lv_str1+0(3) EQ gc_mp9 OR
* End of change by Rahul 08072015
         ( lv_str1 IN gr_nspace[] AND NOT gr_nspace[] IS INITIAL ).
        " 29OCT ashish
        READ REPORT lv_str1 INTO lt_code.
        IF sy-subrc = 0.
*Scan the source inside the subroutine of program
          PERFORM get_form USING lt_code
                                 lv_subroutine
                           CHANGING lf_form.
        ENDIF.
      ENDIF.
    ELSE. "if call is not dynamic check with in the program
*Scan the source inside the subroutine of program
      PERFORM get_form USING p_code1
                             lv_subroutine
                       CHANGING lf_form.
      IF lf_form IS INITIAL.
*Scan the source inside the subroutine of program if that exist
*in any include of the program
*LOOP AT gt_include INTO lwa_include WHERE progname = gv_prog.
*"10OCTSHEKHAR
        LOOP AT gt_include INTO lwa_include
          WHERE progname = gs_progname-progname. "10OCTSHEKHAR
          REFRESH lt_code.
          CHECK lwa_include-include IS NOT INITIAL.
          READ REPORT lwa_include-include INTO lt_code.
          IF sy-subrc = 0.
            gv_prog = lwa_include-include.
            PERFORM get_form USING lt_code
                                   lv_subroutine
                             CHANGING lf_form.
            IF lf_form = gc_x.
              gv_prog = lwa_include-progname.
              EXIT.
            ENDIF.
          ENDIF.
        ENDLOOP.

      ENDIF.
    ENDIF.
*Catch system exceptions
  ENDCATCH.
  IF sy-subrc <> 0.
    WRITE:/ gc_error ,'Error code:', sy-subrc ,
    '=>Perform F_PROCESS_PERFORM'.
  ENDIF.
*Catch system exceptions
ENDFORM.                    " F_PROCESS_PERFORM

*&---------------------------------------------------------------------*
*&      Form  GET_DYNAMIC_FORM
*&---------------------------------------------------------------------*
* Scan the source code of subroutine
*----------------------------------------------------------------------*
*      -->P_CODE        Source code of the program/include
*      -->P_SUBROUTINE  Name of Subroutine
*      <--PF_FORM       Flag for indication that scan is done
*----------------------------------------------------------------------*
FORM get_form  USING    p_code LIKE gt_code
                        p_subroutine
               CHANGING pf_form.

*Catch system exceptions
  CATCH SYSTEM-EXCEPTIONS arithmetic_errors             = 1
                          create_data_errors            = 2
                          conversion_errors             = 3
                          create_object_errors          = 4
                          data_access_errors            = 5
                          assign_casting_illegal_cast   = 6
                          assign_casting_unknown_type   = 7
                          assign_field_not_in_range     = 8
                          data_offset_too_large         = 9
                          dyn_call_meth_not_implemented = 10
                          export_buffer_no_memory       = 11
                          generate_subpool_dir_full     = 12
                          move_cast_error               = 13
                          perform_program_name_too_long = 14
                          replace_infinite_loop         = 15
                          remote_call_errors            = 16
                          localization_errors           = 17
                          import_mismatch_errors        = 18
                          dynamic_call_method_errors    = 19
                          file_access_errors            = 20
                          OTHERS                        = 99.
*Catch system exceptions


    DATA : wa_new            TYPE i,
           lwa_new           TYPE i,
           wa_for_check      TYPE i,
           lw_form_read_code TYPE ty_code,
           lv_index1         TYPE sy-tabix,
           lv_row1           TYPE sy-tabix,
           lv_strr           TYPE string,
           lv_dat1           TYPE string,
           lv_dat2           TYPE string,
           lv_dat3           TYPE string.

    DATA: lwa_code TYPE ty_code,
          lwa_slct TYPE ty_code,
          lv_col   TYPE i,
          lv_tabix TYPE sy-tabix,
          lv_index TYPE i,
          lv_str1  TYPE string,
          lv_row   TYPE i.
    DATA: lv_str2       TYPE string,
          lwa_table     TYPE ty_tab,
          lwa_final     TYPE ty_final,
          lv_line       TYPE sy-tabix,
          lv_flagcs     TYPE c,
          lv_flag_quote TYPE c,
          lv_flag1      TYPE c,
          lv1_read      TYPE string,
          lv2_read      TYPE string.
* Start of change by Manoj on 5/1/2016
    DATA: lv_line_code   TYPE ty_code.
* End of change by Manoj on 5/1/2016
    DATA: gv_prog99 TYPE progname.
    DATA:  lt_drill   TYPE TABLE OF ty_code.
    DATA: lv_eloop_flag TYPE flag.
    DATA: lv_str99 TYPE string.
    DATA: lt_tab99  TYPE TABLE OF ty_code,
          lwa_tab99 TYPE ty_code.
    DATA: lv_sort TYPE sy-tabix.
    DATA:  lwa_sort_tab TYPE t_tab_sort.

    CLEAR: lv_eloop_flag.
    CLEAR: lv_str1, lv_str2.

    LOOP AT p_code INTO lwa_code WHERE text+0(5) CS gc_form_spc.
      CONDENSE lwa_code.
      TRANSLATE lwa_code TO UPPER CASE.
      SPLIT lwa_code AT gc_using INTO lwa_code lv_str1.
      SPLIT lwa_code AT gc_changing INTO lwa_code lv_str1.
      SPLIT lwa_code AT gc_tables INTO lwa_code lv_str1.

      CLEAR: lv_col, lv_str1.
      FIND gc_dot IN lwa_code MATCH OFFSET lv_col.
      IF lv_col IS NOT INITIAL.
        lwa_code = lwa_code(lv_col).
      ENDIF.

      lv_str1 = lwa_code.
      CONDENSE: lv_str1, p_subroutine.

      IF lv_str1 NE p_subroutine.
        CONTINUE.
      ELSEIF lwa_code+0(5) = gc_form_spc.

        lv_tabix = sy-tabix.
        CLEAR: lwa_code, lv_str1.
        LOOP AT p_code INTO lwa_code FROM lv_tabix.
          CONDENSE lwa_code-text.

          TRANSLATE lwa_code-text TO UPPER CASE.
*==========================
*DO not scan the source code if it is commented
*or statement inside single quotes
*==========================
          IF lwa_code-text = '' OR lwa_code-text+0(1) = gc_star OR
          lwa_code-text+0(1) = gc_doub_quote.
            CONTINUE.
          ENDIF.

*==========================
*Source code is already scanned till end of statement by using
*PERFORM get_line ,so do not scan again
*==========================
          lv_index = sy-tabix.
          IF lv_index LE lv_row.
            CONTINUE.
          ENDIF.

          CONDENSE lwa_code.
          TRANSLATE lwa_code TO UPPER CASE.

*==========================
*Check added to process only custom program/includes
*==========================
          CONDENSE gv_prog.
          TRANSLATE gv_prog TO UPPER CASE.
          IF            gv_prog CS gc_saplz OR
                        gv_prog CS gc_saply OR
                        gv_prog CS gc_sapmz OR
                        gv_prog CS gc_sapmy OR
                        gv_prog+0(2) = gc_lz OR
                        gv_prog+0(2) = gc_ly OR
                        gv_prog+0(2) = gc_mz OR
                        gv_prog+0(2) = gc_my OR
                        gv_prog+0(1) = gc_z OR
                        gv_prog+0(1) = gc_y OR
* Begin of change by Rahul 08072015
                        gv_prog+0(3) = gc_mp9 OR
* End of change by Rahul 08072015
                        ( gv_prog IN gr_nspace[] AND
                          NOT gr_nspace[] IS INITIAL ) .
* nothing to do.
          ELSE.
            CLEAR lwa_code-text.
            lwa_code-text = gc_endform.
          ENDIF.

          IF lwa_code NS gc_endform.

*==========================
*Concatenate full statement in a line
*==========================
            PERFORM get_line  USING p_code
                                    lv_index
                              CHANGING lv_str1
                                       lv_row.
            lwa_code = lv_str1.
            CLEAR lv_str1.
*{ Begin of change by Rohit - 16/12/2015
            lv_line_code = lwa_code.
*} End of change by Rohit - 16/12/2015
*=================================
* Logic to find TYPE SORTED TABLE
*=====================================
            REFRESH lt_tab99[].
            CLEAR: lv_str99.
            lv_str99 = lwa_code.
            CONDENSE lv_str99.
            IF lv_str99 CS gc_type_sort_tab.
              REPLACE ALL OCCURRENCES OF gc_type_sort_tab
              IN lv_str99 WITH gc_x1x1.
              SPLIT lv_str99 AT '' INTO TABLE lt_tab99.
              LOOP AT lt_tab99 INTO lwa_tab99.
                IF lwa_tab99 = gc_x1x1.
                  lv_str99 = sy-tabix - 1.
                  CHECK  lv_str99 > 0.
                  READ TABLE lt_tab99 INTO lwa_tab99 INDEX lv_str99.
                  IF sy-subrc = 0.
                    lwa_sort_tab-table = lwa_tab99.
                    REPLACE ALL OCCURRENCES OF gc_bracket
                    IN lwa_sort_tab-table WITH ''.
                    CONDENSE lwa_sort_tab-table.
                    APPEND lwa_sort_tab TO gt_sort.
                  ENDIF.

                ENDIF.
              ENDLOOP.
            ENDIF.
*==========================
*putting whole source code to global variable
*==========================
            CLEAR: gv_org_code.
            gv_org_code = lwa_code.
*{ Begin of change by Rohit - 16/12/2015
*===============================================
* Logic to find all the sorted tables in the program
*===============================================
            PERFORM f_find_sort_tab_form USING lv_line_code
                                               p_subroutine
                                               lv_index.

*} End of change by Rohit - 16/12/2015
*{ Begin of change by Rohit - 16/12/2015
*===============================================
* Logic to detect unsorted internal table with index
*===============================================
            PERFORM f_detect_itab_index_forms USING lv_line_code
                                                    p_subroutine
                                              lv_index.

*} End of change by Rohit - 16/12/2015

* Begin of changes by Twara 04/01/2016 to process CLASS
*===============================================
* Logic to process Class
*===============================================
            PERFORM f_process_class USING lv_line_code
                                          lv_index.
* End of changes by Twara 04/01/2016 to process CLASS
*==========================
*DO not scan the source code if it is commented or statement
*inside single quotes
*==========================
            CONDENSE lwa_code.
            CLEAR lv_str1.
            IF lwa_code CS gc_doub_quote.
              CLEAR gv_check_flag.
              PERFORM get_offset_key_single_quote USING
                      lwa_code '"'
                      CHANGING gv_check_flag.
              IF gv_check_flag IS INITIAL.
                SPLIT lwa_code AT gc_doub_quote INTO lwa_code lv_str1.
              ENDIF.
              CLEAR gv_check_flag.
              CLEAR lv_str1.
            ENDIF.
            IF lwa_code+0(1) EQ gc_doub_quote OR  lwa_code+0(1) =
            gc_star
              OR lwa_code+0(1) EQ '''' .
              CONTINUE.
            ENDIF.


*==========================
*  If MACRO - then ignore  the all code inside that
*==========================
            IF lwa_code+0(17) = gc_end_of_def.
              CLEAR lv_flagcs.
            ELSEIF lwa_code+0(6) = gc_define OR lv_flagcs IS NOT INITIAL
            .
              lv_flagcs = gc_x.
              CONTINUE.
            ENDIF.


*===============================
* Check for Nesting of LOOPS/DO/WHILE
*===============================
            IF gv_drill <= 0.
              CLEAR: gv_drill_max, gv_drill.
            ENDIF.
            CLEAR: lv_str1, lv_str2.
            SPLIT lwa_code AT space INTO lv_str1 lv_str2.

*===============================
* IF LOOPS/DO/WHILE start increase the nesting counter
*===============================

            " start of change: loop and endloop in same line.
            " in this case gv_drill should not increase.
            IF ( lv_str1 = gc_loop OR lv_str1 = gc_do OR lv_str1 =
            gc_do_dot ).
              REFRESH: lt_drill[].
              CONDENSE lwa_code.
              TRANSLATE lwa_code TO UPPER CASE.
              SPLIT lwa_code AT space INTO TABLE lt_drill.
              REPLACE ALL OCCURRENCES OF gc_dot IN TABLE lt_drill WITH
              ' '.
              REPLACE ALL OCCURRENCES OF gc_comma IN TABLE lt_drill WITH
              ' '.
              DELETE lt_drill WHERE text = ''.
              CLEAR: lv_eloop_flag.
              READ TABLE lt_drill WITH KEY text = gc_enddo
              TRANSPORTING NO FIELDS.
              IF sy-subrc = 0.
                lv_eloop_flag = gc_x.
              ENDIF.
              READ TABLE lt_drill WITH KEY text = gc_endwhile
              TRANSPORTING NO FIELDS.
              IF sy-subrc = 0.
                lv_eloop_flag = gc_x.
              ENDIF.
              READ TABLE lt_drill WITH KEY text = gc_endloop
              TRANSPORTING NO FIELDS.
              IF sy-subrc = 0.
                lv_eloop_flag = gc_x.
              ENDIF.
            ENDIF.
            " end of change: loop and endloop in same line.
            " start of change: loop and endloop in same line.
*        IF lv_str1 = 'LOOP' OR lv_str1 = 'DO' OR  lv_str1 = 'DO.'
*          OR lv_str1 = 'WHILE'.
            IF ( lv_str1 = gc_loop OR lv_str1 = gc_do OR  lv_str1 =
            gc_do_dot
                      OR lv_str1 = gc_while ) AND lv_eloop_flag = ''.
              " end of change: loop and endloop in same line.

              IF gv_drill = 0  OR gv_loop_line IS INITIAL.
                gv_loop_line = lv_index.
              ENDIF.
              gv_flag = gc_x.
              gv_drill = gv_drill + 1.
              IF gv_drill > gv_drill_max.
                gv_drill_max = gv_drill_max + 1.
              ENDIF.
*===============================
* IF LOOPS/DO/WHILE ends decrease the nesting counter
*===============================
            ELSEIF lv_str1 CS gc_endloop OR lv_str1 CS gc_enddo
             OR lv_str1 CS gc_endwhile.
              gv_drill = gv_drill - 1.
            ENDIF.
            CLEAR: lv_str1, lv_str2.

*===============================
* IF ENDSELECT is used then decrease the nesting counter
*===============================
            IF lwa_code CS gc_endselect.
*Check for the KEYWORD used insdie single quotes
              CLEAR lv_flag_quote.
              PERFORM get_quote_keyword USING lwa_code 'ENDSELECT'
              CHANGING lv_flag_quote.
              IF lv_flag_quote = gc_x.
                CONTINUE.
              ENDIF.

              IF gv_drill > 0.
                gv_drill = gv_drill - 1.
              ENDIF.

              CLEAR: lwa_final.
              CLEAR: gv_exit.
              CLEAR: gv_flag_e.
              CLEAR :lv_flag1 .
            ENDIF.

*===============================
* IF Nesting is present then update the detection table
*===============================
            IF gv_drill = 0  AND gv_drill_max > 1.
              CLEAR: lwa_table.
              lwa_final-line = gv_loop_line.
              lwa_final-prog = gv_prog.
              lwa_final-obj_name = gs_progname-progname.
              lwa_final-opercd = gc_32.
              lwa_final-drill = gv_drill_max - 1.
              PERFORM get_crit CHANGING lwa_final.
              PERFORM append_final USING lwa_final.
              CLEAR: lwa_final.
              CLEAR: gv_drill_max, gv_loop_line.
              CLEAR: gv_flag.
            ENDIF.

*==========================
*Check that keyword written inside single quotes
*==========================
            PERFORM get_offset_key_single_quote USING
                     lwa_code 'READ TABLE'
                     CHANGING gv_check_flag.

*==========================
*Check if statement having READ with BINARY SEARCH but sorting
*is not done on internal table
*==========================
            CLEAR :  lv1_read , lv2_read .
            IF ( lwa_code-text CS gc_read_tab
               AND lwa_code-text CS gc_bin_search )
              AND gv_check_flag IS INITIAL .
              lwa_final-line = sy-tabix.
              SPLIT lwa_code-text AT gc_read_tab INTO lv1_read lv2_read
              .
              CONDENSE lv2_read.
              SPLIT lv2_read AT space INTO lv1_read lv2_read.
              CONDENSE lv1_read.
              lwa_final-itabs = lv1_read.

              CLEAR: gt_f_code, gv_nt_found.
              " start ; replace FM with Form
*              CALL FUNCTION 'ZAUCT_FIND_STR'
*                EXPORTING
*                  p_name       = gv_prog
*                  code_string  = lwa_final-itabs
*                  start_line   = lv_tabix
*                  line_no      = lwa_final-line
*                  p_type       = 'R'
*                IMPORTING
*                  lv_not_found = gv_nt_found
*                TABLES
*                  it_fcode     = gt_f_code.
*
              PERFORM get_scan TABLES gt_f_code
                 USING gv_prog
                       lwa_final-itabs
                       lv_tabix
                       lwa_final-line gc_r ''
                    CHANGING gv_nt_found.
* end : replace FM with Form
* Begin of change by Twara 12/02/2016
              DATA: lwa_sel_t  TYPE t_sort,
                    lwa_sel_t1 TYPE t_sort.
* End of change by Twara 12/02/2016
              IF gt_f_code IS INITIAL.
* Begin of change by Twara 12/02/2016
                IF NOT lv1_read IS INITIAL.
                  " find if internal is used in select statements
                  READ TABLE gt_sel_t INTO lwa_sel_t WITH KEY table =
                  lv1_read
                  BINARY SEARCH.
                  IF sy-subrc = 0.
                    " find internal is unsorted
                    READ TABLE gt_sort_t WITH KEY table = lv1_read
                    TRANSPORTING NO FIELDS
                    BINARY SEARCH.
                    IF sy-subrc <> 0.
                      READ TABLE gt_sort_f WITH KEY table = lv1_read
                                        routine = p_subroutine
                  TRANSPORTING NO FIELDS.
                      IF sy-subrc <> 0.
* End of change by Twara 12/02/2016
                        lwa_final-code  = lwa_code-text.
                        lwa_final-prog   = gv_prog.
                        lwa_final-obj_name = gs_progname-progname.
                        lwa_final-line = lv_index.
                        lwa_final-opercd = gc_45.
                        lwa_final-drill = gv_drill.
* Begin of change by Twara 12/02/2016
                        READ TABLE gt_sel_t
                          INTO lwa_sel_t1
                          WITH KEY table = lv1_read
                                   prog  = gv_prog
                                   sub_prog = gs_progname-progname.
                        IF sy-subrc EQ 0.
                          lwa_final-select_line = lwa_sel_t1-line.
                          PERFORM append_opcode21 USING
                          lwa_sel_t-dbtable
                          lwa_sel_t-table
                          lwa_sel_t-tab_type
                          lwa_sel_t-prog
                          lwa_sel_t-sub_prog
                          lwa_sel_t-line
                          lwa_sel_t-select.
                        ENDIF.
* End of change by Twara 12/02/2016
                        PERFORM append_final USING lwa_final.
* Begin of change by Twara 12/02/2016
                        CLEAR: lwa_final.
* End of change by Twara 12/02/2016
                      ENDIF.
                      CLEAR : gv_nt_found.
* Begin of change by Twara 12/02/2016
                    ENDIF.
                  ENDIF.
                ENDIF.
              ENDIF.
* End of change by Twara 12/02/2016
              FREE : gt_f_code.
            ENDIF.
*Begin of change by Twara 04/01/2016 to process class directly
**==========================
**Check method -> class
**==========================
*            IF lwa_code+0(11) CS 'CALL METHOD'.  "commented
*              PERFORM read_method USING lwa_code
*                                        lv_index.
*            ENDIF.
*End of change by Twara 04/01/2016 to process class directly
*==========================
*Check if statement used for Aggregation LIKE COLLECT
*==========================
            IF ( lwa_code-text+0(7) = gc_collect ).
              lwa_final-code  = gv_org_code.
              lwa_final-prog   = gv_prog.
              lwa_final-obj_name = gs_progname-progname.
              lwa_final-line = lv_index.
              lwa_final-opercd = gc_47.
              lwa_final-drill = gv_drill.
              PERFORM append_final USING lwa_final.
            ENDIF.
*==========================
*  Check for use of OPEN SQL in source code
*==========================
            IF lwa_code+0(8) = gc_exec_sql.
              CLEAR : lwa_final-code.
              lwa_final-code  = lwa_code.
              lwa_final-prog   = gv_prog.
              lwa_final-obj_name = gs_progname-progname.
              lwa_final-line = lv_index.
              lwa_final-opercd = gc_11.
              lwa_final-drill = gv_drill.
              lwa_final-corr = gc_x.
              PERFORM append_final USING lwa_final.
            ENDIF.
*==========================
*Check that keyword written inside single quotes
*==========================
            PERFORM get_offset_key_single_quote USING
                     lwa_code 'CALL FUNCTION'
                     CHANGING gv_check_flag.
*==========================
*Check for FM "DB_EXISTS_INDEX" and "DD_INDEX_NAME" call in source
*==========================
            IF ( lwa_code CS gc_call_func AND
               ( lwa_code CS gc_db_exist_ind OR
               lwa_code CS gc_dd_ind_name )
              AND  gv_check_flag IS INITIAL ) .
              CLEAR : lwa_final-code.
              lwa_final-code  = lwa_code.
              lwa_final-prog   = gv_prog.
              lwa_final-obj_name = gs_progname-progname.
              lwa_final-line = lv_index.
              lwa_final-opercd = gc_12.
              lwa_final-drill = gv_drill.
              PERFORM append_final USING lwa_final.
            ENDIF.
*==============================
*Process the subroutine source code
*==============================
            IF lwa_code+0(7) = gc_perform.
*Start of change DEF_21 on 16/02/2017
              IF lwa_code CS '(' AND lwa_code CS ')'  .
              ELSE.
*End of change DEF_21 on 16/02/2017
                SPLIT lwa_code AT space INTO gv_per_rec1 gv_per_rec2
                gv_per_rec3.
                CONCATENATE gc_form gv_per_rec2 INTO gv_per_rec2
                SEPARATED BY space.
                REPLACE ALL OCCURRENCES OF gc_dot IN gv_per_rec2 WITH ''.
                CONDENSE gv_per_rec2.
                CONDENSE gv_per_rec.
                CLEAR : gv_per_rec ,gv_per_rec1 ,
                        gv_per_rec2 ,gv_per_rec3.
                gv_prog99 = gv_prog.
                PERFORM f_process_perform USING p_code
                                                lwa_code lv_index.
                gv_prog = gv_prog99.
              ENDIF.
*Start of change DEF_21 on 16/02/2017
            ENDIF.
*End of change DEF_21 on 16/02/2017
*==========================
*Rearrange the SELECT statament if it contains JOINS
*==========================
            IF ( lwa_code+0(6) = gc_select OR lwa_code+0(8) =
            gc_select_str
            )
            AND lwa_code CS gc_join_spc.
              PERFORM check_into USING lwa_code CHANGING lwa_slct
              gv_codenew.
              lwa_code = lwa_slct.
            ENDIF.
*=================================
*Process the SELECT statement and update detection table
*==================================
            IF lwa_code+0(7) = gc_select_spc OR
               lwa_code+0(11)  = gc_op_cursor.
* start of new logic for SORT
*      perform get_sel_sort using p_code
*                                 lwa_code
*                                 lv_index.
* end of new logic for SORT
*start of change by ashish on 15Oct -- add selection by statement ---
*SELECT SINGLE FOR UPDATE
*        IF lwa_code CS 'SELECT *' OR lwa_code CS 'SELECT SINGLE *' .
              IF lwa_code CS gc_select_str OR lwa_code CS
              gc_select_sing_str
              OR lwa_code CS gc_sel_sing_updt .
*end of change by ashish on 15Oct -- add selection by statement ---
*SELECT SINGLE FOR UPDATE
                PERFORM get_sel_star USING p_code
                                          lwa_code
                                          lv_index
                                    CHANGING gt_intab.
              ENDIF.
              PERFORM get_db_hits USING lwa_code
                                        lv_index
                                  CHANGING gt_table
                                          lv_flag1.
            ENDIF.
*==========================================
*Check for SORT KEYWORD used in statement
*==========================================
            IF lwa_code+0(4) CS gc_sort.
* start of new logic for SORT
*              PERFORM check_sort USING lwa_code
*                                       lv_index.
              PERFORM find_sort USING lwa_code
                                             lv_index.
* end of new logic for SORT
            ENDIF.
*==========================================
*Check for Use of CURRENCY conversion and DELETE ADJACENT DUPLICATES
*without sorting
*==========================================
            IF lwa_code CS gc_del_adj_dup OR
               lwa_code CS gc_cursor
              OR ( lwa_code CS gc_call_func AND
                   lwa_code CS gc_curr ).

              PERFORM f_statement USING p_code
                                        lwa_code
                                        lv_index
                                        lv_tabix.
            ENDIF.
            IF ( gv_drill > 0 ) .
*==========================================
*To Trace the UPDATE/DELETE/INSERT/CHECK/EXIT Statement inside loop
*==========================================
              IF (  lwa_code-text+0(7) EQ gc_update_spc
                OR ( lwa_code-text+0(7) EQ gc_modify_spc AND NOT (
                lwa_code-text CS gc_modify_line OR lwa_code-text CS
                gc_modify_screen ) )
               OR lwa_code-text+0(7)  EQ gc_insert_spc
               OR lwa_code-text+0(7)  EQ gc_delete_spc
               OR lwa_code-text+0(5)  EQ gc_check
                 OR lwa_code-text+0(4)  EQ gc_exit ).
                PERFORM f_scan_statement USING lwa_code
                                               lv_index.

*==========================================
*To Trace the BAPI, FM  Used inside the various Loops
*==========================================
              ELSEIF ( lwa_code+0(13) CS gc_call_func
                OR ( lwa_code+0(13) CS gc_call_func AND
                     lwa_code CS gc_bapi ) ).
                PERFORM f_scan_bapi USING lwa_code
                                          lv_index.

*==========================================
*To trace the Control Statements use inside the various Loops
*==========================================
              ELSEIF ( lwa_code CS gc_at_new ) OR
                     ( lwa_code CS gc_at_first )
                  OR ( lwa_code CS gc_at_endof )
                  OR ( lwa_code CS gc_at_last )
                  OR ( lwa_code CS gc_on_changeof ).
                PERFORM f_scan_control  USING lwa_code
                                          lv_index.
* Start of addition by Manoj on 23/12/2015
                " - control statements in unsorted internal tables
                PERFORM f_ctrl_in_unsorted_itabs_form USING p_code
                                                       lv_line_code
                                                       p_subroutine
                                                       lv_index.
* End of addition by Manoj on 23/12/2015
                " - control statements in unsorted internal tables
              ENDIF.
            ENDIF.

*======================================================
* Detection for DELETE/UPDATE/INSERT/MODIFY for POOL/CLUSTER tables
*======================================================
***Begin of changes by Manoj on 15/12/2015
*   for DB operations on POOL/CLUSTER tables
            PERFORM f_detect_pool_cluster_db_ops
                    USING lv_line_code lv_index.
***End of changes by Manoj on 15/12/2015
*    for DB operations on POOL/CLUSTER tables
*======================================================
* Detection for ADBC
*======================================================
***Begin of changes by Manoj on 30/12/2015
            PERFORM f_detect_adbc
                        USING lv_line_code lv_index.
***End of changes by Manoj on 30/12/2015
          ELSE.
            pf_form = gc_x.
            EXIT.
          ENDIF.

        ENDLOOP.
      ENDIF.
      IF pf_form = gc_x.
        EXIT.
      ENDIF.
    ENDLOOP.
*Catch system exceptions
  ENDCATCH.
  IF sy-subrc <> 0.
    WRITE:/ gc_error ,'Error code:', sy-subrc ,
    '=>Perform GET_DYNAMIC_FORM'.
  ENDIF.
*Catch system exceptions
ENDFORM.                    " GET_DYNAMIC_FORM
*&---------------------------------------------------------------------*
*&      Form  F_SCAN_STATEMENT
*&---------------------------------------------------------------------*
* Scan the Statement
*----------------------------------------------------------------------*
*      -->PWA_CODE      Source code of the statement
*      -->LU_INDEX      Current line number
*----------------------------------------------------------------------*
FORM f_scan_statement USING pwa_code
                            lu_index.

*Catch system exceptions
  CATCH SYSTEM-EXCEPTIONS arithmetic_errors             = 1
                          create_data_errors            = 2
                          conversion_errors             = 3
                          create_object_errors          = 4
                          data_access_errors            = 5
                          assign_casting_illegal_cast   = 6
                          assign_casting_unknown_type   = 7
                          assign_field_not_in_range     = 8
                          data_offset_too_large         = 9
                          dyn_call_meth_not_implemented = 10
                          export_buffer_no_memory       = 11
                          generate_subpool_dir_full     = 12
                          move_cast_error               = 13
                          perform_program_name_too_long = 14
                          replace_infinite_loop         = 15
                          remote_call_errors            = 16
                          localization_errors           = 17
                          import_mismatch_errors        = 18
                          dynamic_call_method_errors    = 19
                          file_access_errors            = 20
                          OTHERS                        = 99.
*Catch system exceptions

    DATA : lt_type   TYPE TABLE OF ty_sourcetab,
           lwa_type  TYPE          ty_sourcetab,
           lwa_final TYPE          ty_final,
           lv_index  TYPE          sy-tabix.
    DATA: lv_tabname TYPE dd02l-tabname.
    DATA: lv_str1 TYPE string,
          lv_str2 TYPE string.

    CLEAR: lv_str1, lv_str2.

    SPLIT pwa_code AT space INTO TABLE lt_type.
    CLEAR : lv_index.

*==========================================
*To check operation UPDATE within a loop
*==========================================
    IF pwa_code CS gc_update.
      READ TABLE lt_type INTO lwa_type WITH KEY line = gc_update.
      IF sy-subrc IS INITIAL .

*begin of code changes for def_6 & 7 ( Vipul - 05/01/2017 )
        CONDENSE pwa_code.
        SPLIT pwa_code AT gc_update  INTO lv_str1 lv_str2.
        CONDENSE lv_str2.
        SPLIT lv_str2 AT '' INTO lv_str1 lv_str2.
        REPLACE ALL OCCURRENCES OF gc_dot IN lv_str1 WITH space.
        CONDENSE lv_str1.
        SELECT SINGLE tabname  FROM dd02l INTO lv_tabname
        WHERE tabname = lv_str1.

        IF sy-subrc = 0.
          lwa_final-table = lv_str1.
          lwa_final-code = pwa_code.
          lwa_final-opercd = gc_49.
          lwa_final-prog  = gv_prog.
          lwa_final-obj_name = gs_progname-progname.
          lwa_final-line  = lu_index.
          lwa_final-drill = gv_drill.
          PERFORM get_crit CHANGING lwa_final.
          PERFORM append_final USING lwa_final.
          CLEAR lwa_final.
        ENDIF.
*End of code change for def_6 & 7 ( Vipul - 05/01/2017 )

        lv_index = sy-tabix + 2.
        READ TABLE lt_type INTO lwa_type INDEX lv_index.
        IF lwa_type+0(4) = gc_from.
          CLEAR : lv_index.
          lv_index = sy-tabix - 1.
          READ TABLE lt_type INTO lwa_type INDEX lv_index.
          IF sy-subrc IS INITIAL.
            lwa_final-table = lwa_type.
            CONCATENATE gc_update
            lwa_final-table
            'table in LOOP should be avoided,'
            'instead update table using array operation'
            INTO lwa_final-check SEPARATED BY space.
            lwa_final-opercd = gc_49.
            lwa_final-prog  = gv_prog.
            lwa_final-code = pwa_code.
            lwa_final-line  = lu_index.
            lwa_final-drill = gv_drill.
            lwa_final-obj_name = gs_progname-progname.
            PERFORM append_final USING lwa_final.
            CLEAR lwa_final.
          ENDIF.
        ENDIF.
      ENDIF.
*==========================================
*To check operation INSERT within a loop
*==========================================
    ELSEIF pwa_code CS gc_insert.
      READ TABLE lt_type INTO lwa_type WITH KEY line = gc_insert.
      IF sy-subrc IS INITIAL.

*begin of code changes for def_6 & 7  ( Vipul- 05/01/2017 )
        CONDENSE pwa_code.
        SPLIT pwa_code AT gc_insert  INTO lv_str1 lv_str2.
        CONDENSE lv_str2.
        SPLIT lv_str2 AT '' INTO lv_str1 lv_str2.
        REPLACE ALL OCCURRENCES OF gc_dot IN lv_str1 WITH space.
        CONDENSE lv_str1.
        SELECT SINGLE tabname  FROM dd02l INTO lv_tabname
        WHERE tabname = lv_str1.

        IF sy-subrc = 0.
          lwa_final-table = lv_str1.
          lwa_final-code = pwa_code.
          lwa_final-opercd = gc_50.
          lwa_final-prog  = gv_prog.
          lwa_final-obj_name = gs_progname-progname.
          lwa_final-line  = lu_index.
          lwa_final-drill = gv_drill.
          PERFORM get_crit CHANGING lwa_final.
          PERFORM append_final USING lwa_final.
          CLEAR lwa_final.
        ENDIF.
*End of code change for def_6 & 7 ( Vipul - 05/01/2017 )

        lv_index = sy-tabix + 3.
        READ TABLE lt_type INTO lwa_type INDEX lv_index.
        IF sy-subrc IS INITIAL AND lwa_type = gc_values.
          lv_index = sy-tabix - 1.
          READ TABLE lt_type INTO lwa_type INDEX lv_index.
          IF sy-subrc IS INITIAL.
            lwa_final-table = lwa_type.
            CONCATENATE gc_insert lwa_final-table
            'table in LOOP should be avoided,'
            'instead insert table using array operation'
            INTO lwa_final-check SEPARATED BY space.
            lwa_final-opercd = gc_50.
            lwa_final-prog  = gv_prog.
            lwa_final-code = pwa_code.
            lwa_final-obj_name = gs_progname-progname.
            lwa_final-line  = lu_index.
            lwa_final-drill = gv_drill.
            PERFORM get_crit CHANGING lwa_final.
            PERFORM append_final USING lwa_final.
            CLEAR lwa_final.
          ENDIF.
        ENDIF.
      ENDIF.

*==========================================
*To check operation MODIFY within a loop
*==========================================
    ELSEIF pwa_code CS gc_modify AND
        NOT ( pwa_code CS gc_modify_screen OR pwa_code CS gc_modify_line
        )
        .
      CONDENSE pwa_code.
      SPLIT pwa_code AT gc_modify  INTO lv_str1 lv_str2.
      CONDENSE lv_str2.
      SPLIT lv_str2 AT '' INTO lv_str1 lv_str2.

*begin of code changes for def_6 & 7 ( Vipul - 03/01/2017 )
      REPLACE ALL OCCURRENCES OF gc_dot IN lv_str1 WITH space.
      CONDENSE lv_str1.
*End of code change for def_6 & 7  ( Vipul - 03/01/2017 )

      SELECT SINGLE tabname  FROM dd02l INTO lv_tabname
      WHERE tabname = lv_str1.
      IF sy-subrc = 0.
        lwa_final-table = lv_str1.
        lwa_final-code = pwa_code.
        lwa_final-opercd = gc_51.
        lwa_final-prog  = gv_prog.
        lwa_final-obj_name = gs_progname-progname.
        lwa_final-line  = lu_index.
        lwa_final-drill = gv_drill.
        PERFORM get_crit CHANGING lwa_final.
        PERFORM append_final USING lwa_final.
        CLEAR lwa_final.
      ENDIF.

*==========================================
*To check operation DELETE within a loop
*==========================================
    ELSEIF pwa_code CS gc_delete.
      READ TABLE lt_type INTO lwa_type WITH KEY line = gc_delete.
      IF sy-subrc IS INITIAL.
        lv_index = sy-tabix + 1.
        READ TABLE lt_type INTO lwa_type INDEX lv_index.
        IF lwa_type = gc_from.
          lv_index = sy-tabix + 1.
          READ TABLE lt_type INTO lwa_type INDEX lv_index.
          IF sy-subrc IS INITIAL.
            lv_tabname = lwa_type.
          ENDIF.
        ELSE.
          SELECT SINGLE tabname  FROM dd02l INTO lv_tabname
            WHERE tabname = lwa_type.
          IF sy-subrc NE 0.
            CLEAR lv_tabname.
          ENDIF.
        ENDIF.
        IF lv_tabname IS NOT INITIAL.
          lwa_final-table = lv_tabname.
          CONCATENATE gc_delete lwa_final-table
            'table in LOOP should be avoided,'
            'instead delete table using array operation'
          INTO lwa_final-check SEPARATED BY space.
          lwa_final-opercd = gc_52.
          lwa_final-code = pwa_code.
          lwa_final-prog  = gv_prog.
          lwa_final-obj_name = gs_progname-progname.
          lwa_final-line  = lu_index.
          lwa_final-drill = gv_drill.
          PERFORM get_crit CHANGING lwa_final.
          PERFORM append_final USING lwa_final.
          CLEAR lwa_final.
        ENDIF.
      ENDIF.

*==========================================
*To check CHECK/EXIT within a loop
*==========================================
*****BOC Def_36 by shreeda 26/5/2017 ---Check and exit should not be detected***
*    ELSEIF pwa_code+0(6) EQ gc_check OR
*            pwa_code+0(4) EQ gc_exit.
*
*      IF pwa_code+0(6) EQ gc_check.
*        lwa_final-opercd = gc_53.
*        lwa_final-check =  'CHECK statement in LOOP should be avoided'.
*      ELSEIF pwa_code+0(4) EQ gc_exit.
*        lwa_final-oper  = 'CHECK/EXIT IN LOOP'.
*        lwa_final-opercd = gc_53.
*        lwa_final-check =  'EXIT statement in LOOP should be avoided'.
*      ENDIF.
*      lwa_final-prog  = gv_prog.
*      lwa_final-code = pwa_code.
*      lwa_final-line  = lu_index.
*      lwa_final-obj_name = gs_progname-progname.
*      lwa_final-drill = gv_drill.
*      PERFORM get_crit CHANGING lwa_final.
*      PERFORM append_final USING lwa_final.
*****EOC Def_36 by shreeda 26/5/2017 ---Check and exit should not be detected***
    ENDIF.
    CLEAR :  lwa_final, lwa_type.
    REFRESH lt_type.
*Catch system exceptions
  ENDCATCH.
  IF sy-subrc <> 0.
    WRITE:/ gc_error , 'Error code:', sy-subrc ,
    '=>Perform F_SCAN_STATEMENT'.
  ENDIF.
*Catch system exceptions
ENDFORM.                    " F_SCAN_STATEMENT

*&---------------------------------------------------------------------*
*&      Form  GET_SEL_STAR
*&---------------------------------------------------------------------*
*Process SELECT */ SELECT SINGLE * statement
*----------------------------------------------------------------------*
*      -->P_CODE1     Source code of teh program
*      -->PWA_CODE    Current statement source code
*      -->P_INDEX     Current line number
*      <--LT_INTAB    Build internal table
*----------------------------------------------------------------------*
FORM get_sel_star  USING   p_code1 LIKE gt_code
                           pwa_code
                           p_index
                   CHANGING lt_intab1 LIKE gt_intab.

*Catch system exceptions
  CATCH SYSTEM-EXCEPTIONS arithmetic_errors             = 1
                          create_data_errors            = 2
                          conversion_errors             = 3
                          create_object_errors          = 4
                          data_access_errors            = 5
                          assign_casting_illegal_cast   = 6
                          assign_casting_unknown_type   = 7
                          assign_field_not_in_range     = 8
                          data_offset_too_large         = 9
                          dyn_call_meth_not_implemented = 10
                          export_buffer_no_memory       = 11
                          generate_subpool_dir_full     = 12
                          move_cast_error               = 13
                          perform_program_name_too_long = 14
                          replace_infinite_loop         = 15
                          remote_call_errors            = 16
                          localization_errors           = 17
                          import_mismatch_errors        = 18
                          dynamic_call_method_errors    = 19
                          file_access_errors            = 20
                          OTHERS                        = 99.
*Catch system exceptions
    DATA: lt_intab              TYPE TABLE OF ty_intab.

    DATA:lwa_intab     TYPE          ty_intab,
         lwa_intab2    TYPE         ty_intab, "19sep ashish
         lwa_intab1    TYPE         ty_intab,
         lt_wa         TYPE TABLE OF ty_wa,
         lwa_wa        TYPE          ty_wa,
         lv_wa         TYPE          string,
         lv_intab      TYPE          string,
         lt_wa_row     TYPE TABLE OF ty_wa_row,
         lwa_wa_row    TYPE          ty_wa_row,
         lt_dfies      TYPE TABLE OF dfies,
         lv_line(10)   TYPE          c,
         lv_line1(10)  TYPE          c,
         lv_per(10)    TYPE          c,
*******BOC Shreeda  /1/05/2017 ***************
         lwa_tab3      TYPE          ty_code,
***********EOC Shreeda 1/05/2017************
         lv_fieldnames TYPE          string,
         lv_final1     TYPE          string,
         lv_final2     TYPE          string,
         lt_tab3       TYPE TABLE OF ty_code.

    DATA: lv_leng TYPE i.
    DATA: lv_str2_tmp TYPE string.
    DATA: lv_key TYPE string.

    DATA: lv_str1      TYPE          string,
** Begin of changes for DEF_18  - 11/2/2017
          lv_str1_2    TYPE          string,
** End of changes for DEF_18  - 11/2/2017
          lv_str2      TYPE          string,
          lv_str3      TYPE          string,
          lt_tab       TYPE TABLE OF ty_code,
          lt_tab_form  TYPE TABLE OF ty_code,
          lwa_tab_form TYPE          ty_code,
          lwa_tab      TYPE          ty_code,
          lt_tab1      TYPE TABLE OF ty_code,
          lwa_tab1     TYPE          ty_code.
*        lwa_table TYPE ty_tab.
    DATA: lv_code TYPE string.
    DATA: lwa_final TYPE ty_final,
          lwa_code  TYPE ty_code.
    DATA: lv_flag TYPE flag.

    DATA: lv_table TYPE ddobjname.
*    DATA: lt_fields  TYPE STANDARD TABLE OF dfies,
*          lwa_fields TYPE                   dfies.
    DATA: lt_fields  TYPE STANDARD TABLE OF ty_fields,
          lwa_fields TYPE                   ty_fields.
    DATA: lv_fields TYPE string.
    DATA: lv_index1 TYPE sy-index.
    DATA: lv_filters TYPE          string,
          lv_itabs   TYPE          string,
          lt_tab2    TYPE TABLE OF ty_code.
    DATA: lwa_tab2 TYPE ty_code.
    DATA: lv_loop TYPE string.
    DATA: l_tabclass TYPE dd02l-tabclass.
    CLEAR: l_tabclass.
    TYPES: BEGIN OF tt_tabkey,
             fieldname TYPE dd03l-fieldname,
             position  TYPE dd03l-position, "SHEKHAR19SEP2014
           END OF tt_tabkey.
    DATA: lt_tabkey TYPE TABLE OF tt_tabkey.

*Start of change Def_18
    DATA: lt_tabkey_count TYPE TABLE OF tt_tabkey,
          lw_tabkey_count TYPE tt_tabkey,
          lw_tab3_count   TYPE ty_code,
          lt_tab3_count   TYPE TABLE OF ty_code.
*End of Sahil change Def_18

    DATA: lwa_tabkey TYPE tt_tabkey.
    DATA: lt_tab4    TYPE TABLE OF ty_code,
          lwa_tab4   TYPE          ty_code,
          lv_str_tmp TYPE          string.
* Begin of changes for % calculation of fields by Atul 05_09_2014
    DATA : lv_init TYPE char1.
    DATA : lv_init_cn TYPE string.
    DATA : lv_init_per TYPE string.
    DATA : lv_init_cn1 TYPE string.
    DATA : lt_ini_tab LIKE lt_intab.
    DATA : lt_ini_tab2 LIKE lt_intab. "ashish sep19
    DATA : p_code2 LIKE gt_code.
    DATA : p_code3 LIKE gt_code.
    DATA : lv_per1 TYPE string.
    DATA : lv_per2 TYPE string.
    DATA : lv_per3 TYPE string.
    DATA : var_line TYPE i.
    DATA : var_line1 TYPE i.
    DATA : wa_progname TYPE main_prog.
* End of changes for % calculation of fields by Atul 05_09_2014

* begin of changes for finding method/call function by ashish 17sept
    DATA: lwa_code2 TYPE ty_code,
          lv_str33  TYPE string.
    DATA: lv_index2 TYPE sy-tabix.
    DATA: lv_sq TYPE string VALUE ''''.
    DATA: lv_dq TYPE string VALUE gc_doub_quote.
    DATA: var_count  TYPE i,
          var_count2 TYPE i.
    DATA: lv_cc TYPE string.
*  DATA p_code2 LIKE gt_code.
    DATA lv_insuff TYPE flag.
    DATA: lv_str34 TYPE string.
    DATA: lv_str35 TYPE string.
    DATA: lv_tabix2 TYPE sy-tabix.
* end of changes for finding method/call function by ashish 17sept
    DATA: lv_char1 TYPE c.
    DATA: lwa_code1 LIKE lwa_code.

    DATA: lv_table1 TYPE char30.
    DATA: lv_original TYPE string.
    DATA: lv_wac TYPE i,
          lv_sub TYPE i,
          lv_cmc TYPE i.
    DATA: lv_index22 TYPE sy-tabix.
    CLEAR: lv_cmc, lv_wac.
* DATA: lv_wa TYPE string.
    CLEAR: lv_fields, lv_filters, lv_itabs, lv_wa.
*    DATA: lv_original.
    CLEAR: lv_original.
    CLEAR: lv_str1, lv_str2, lv_str3, lv_flag, lv_loop.
*  " endselect: need to nullify condition placed in select
*  IF gv_flag_d = 'X'.
*    gv_drill = gv_drill - 1.  " endselect assumed
*    gv_drill_max = gv_drill_max - 1.
*" endselect drill should increase post statement: need to so in order
*to take care of select * in next iteration.
*  ENDIF.
*  " endselect

    lv_original = pwa_code.
    REPLACE ALL OCCURRENCES OF gc_open_bracket IN pwa_code WITH ''.
    REPLACE ALL OCCURRENCES OF gc_close_bracket IN pwa_code WITH ''.
    CONDENSE pwa_code.
*start of change by ashish on 09 Oct  -- INTO Workarea added in case it
*is not present in original statement
    REFRESH lt_tab4[].
    CLEAR: lv_leng, lv_line.
    SPLIT pwa_code  AT space INTO TABLE lt_tab4.
    CLEAR: lv_code.
    DELETE lt_tab4 WHERE text = ''.
    LOOP AT lt_tab4 INTO lwa_tab4 .
      IF lwa_tab4-text = gc_into OR lwa_tab4-text = gc_app.
        lv_leng  = 1.
      ENDIF.
      IF lwa_tab4-text = gc_from.
        lv_line = sy-tabix.
      ENDIF.
    ENDLOOP.
    IF lv_leng = 0.
      CLEAR: pwa_code.
      DATA : lv_stbix TYPE i. " At12102014
      LOOP AT lt_tab4 INTO lwa_tab4 .
        lv_stbix = lv_line + 1." At12102014
        IF sy-tabix =  lv_stbix.
          lv_code  = lwa_tab4-text.
        ENDIF.
        CLEAR : lv_stbix. " At12102014
        lv_stbix = lv_line + 2.
        IF  sy-tabix = lv_stbix.
          CONCATENATE pwa_code gc_into  lv_code INTO pwa_code SEPARATED
          BY space.
          CONCATENATE pwa_code lwa_tab4-text INTO pwa_code SEPARATED BY
          space.
        ELSE.
          CONCATENATE pwa_code lwa_tab4-text INTO pwa_code SEPARATED BY
          space.
        ENDIF.
        CLEAR : lv_stbix.
      ENDLOOP.
      CONDENSE pwa_code.
    ENDIF.
    CLEAR: lv_code, lv_line, lv_leng.
    REFRESH   lt_tab4[].
*end of change by ashish on 09 Oct  -- INTO Workarea added in case it is
*not present in original statement

    lv_code = pwa_code.

*    SPLIT pwa_code AT 'FROM' INTO lv_str1 lv_str2.
*start of change by ashish--- need to break into internal table
*and then SPLIT at from
*  SPLIT pwa_code AT 'FROM' INTO lv_str1 lv_str2.
    SPLIT pwa_code AT space INTO TABLE lt_tab.
    DELETE lt_tab WHERE text = ''.
    DELETE lt_tab WHERE text CS gc_open_bracket .
    DELETE lt_tab WHERE text CS gc_close_bracket .
    CLEAR: lwa_code1.
    CLEAR: lv_line.
    LOOP AT lt_tab INTO  lwa_code1.
      TRANSLATE lwa_code1-text TO UPPER CASE.
      IF lwa_code1-text = gc_from.
        lv_line = sy-tabix.
      ENDIF.
      IF lv_line IS INITIAL.
        CONCATENATE lv_str1 lwa_code1 INTO lv_str1 SEPARATED BY space.
      ELSE.
        CONCATENATE lv_str2 lwa_code1 INTO lv_str2 SEPARATED BY space.
      ENDIF.
    ENDLOOP.
    REPLACE FIRST OCCURRENCE OF gc_from IN lv_str2 WITH ''.
    CLEAR: lv_line.
*end of change by ashish --- need to break into internal table and
*then SPLIT at from
    CONDENSE lv_str2.
    SPLIT lv_str2 AT space INTO TABLE lt_tab.
    CLEAR pwa_code.
    DELETE lt_tab WHERE text CS gc_open_bracket ."changesAt10102014
    DELETE lt_tab WHERE text CS gc_close_bracket ."changesAt10102014
    READ TABLE lt_tab INTO pwa_code INDEX 1.
    REPLACE ALL OCCURRENCES OF gc_dot IN pwa_code
     WITH ''. " added by rohit - 12/10/2015
    lv_table = pwa_code.
***  End of Changes by Atul on 23.04.2014.
*{ Begin of changes - rohit 12/10/2015
    CLEAR gwa_pool_clus.
    IF NOT gt_pool_clus IS INITIAL.
      READ TABLE gt_pool_clus
        INTO gwa_pool_clus
        WITH KEY tabname = pwa_code.
      IF sy-subrc EQ 0.
      ENDIF.
    ENDIF.
*} End of changes - rohit 12/10/2015
    SELECT tabname
           FROM dd02l
           INTO TABLE gt_dd02l
           WHERE tabname = pwa_code AND
                 tabclass IN (gc_transp , gc_pool ,
                              gc_cluster , gc_view).
    " view added by ashish sep24
    IF sy-subrc NE 0.
      pwa_code = lv_code.
      EXIT.
    ENDIF.
***  End of Changes by Atul on 23.04.2014.


**SHEKHAR08SEP2014
    " endselect: need to nullify condition placed in select
**  IF gv_flag_d = 'X'.
**    gv_drill = gv_drill - 1.  " endselect assumed
**    gv_drill_max = gv_drill_max - 1.
**    "endselect drill should increase post statement: need to so in
*order to
**    "take care of select * in next iteration.
**  ENDIF.
    " endselect
**SHEKHAR08SEP2014

    " keys
* find primary key fields
*    lv_table = lwa_table-table .
    SELECT  fieldname  position
            FROM dd03l
            INTO TABLE lt_tabkey
            WHERE tabname = lv_table  AND
                  keyflag = gc_x .
    IF sy-subrc = 0.
      CLEAR: lv_key,lv_str2_tmp.
      SORT lt_tabkey BY position.  "SHEKHAR19SEP2014
      LOOP AT lt_tabkey INTO lwa_tabkey.
        DATA: lv_local TYPE string.
        CLEAR: lv_local.
        CONCATENATE  lv_table gc_tilde lwa_tabkey-fieldname INTO
        lv_local.
        "SHEKHAR24SEP2014 + Atul07oct2014
        IF lwa_tabkey-fieldname+0(1) = gc_dot.
          CONTINUE.
        ENDIF.
        "SHEKHAR24SEP2014
        CONCATENATE  lv_str2_tmp lv_local INTO
        lv_str2_tmp SEPARATED BY gc_seperator .
        CLEAR:  lv_key.
      ENDLOOP.
    ENDIF.
    CONDENSE lv_str2_tmp.
    lwa_final-keys = lv_str2_tmp.
    " end key


* find table type : transparent, pool or cluster
    lv_table1 = pwa_code.
    SELECT  SINGLE tabclass FROM dd02l INTO l_tabclass
    WHERE tabname = lv_table1  AND as4local = gc_a .
    IF sy-subrc = 0.
      lwa_final-type = l_tabclass.
    ENDIF.
*{ Begin of changes - rohit 12/10/2015
    IF  NOT gwa_pool_clus IS INITIAL.
      lwa_final-type = gwa_pool_clus-tabclass.
    ENDIF.
*} End of changes - rohit 12/10/2015
    IF lv_str1 CS gc_star.   " logic to find all the fields selected
      " if Select * is used
      " START-exception shouldn't stop program :
      " dump due to inactive field-
      " ashish 17th NOV
      PERFORM get_fields TABLES gt_fields
                         USING lv_table .

      lt_fields[] = gt_fields[].
      REFRESH: gt_fields[].
*
*      CALL FUNCTION 'DDIF_FIELDINFO_GET'
*        EXPORTING
*          tabname        = lv_table
**       FIELDNAME      = ' '
**       LANGU          = EN
**       LFIELDNAME     = ' '
**       ALL_TYPES      = ' '
**       GROUP_NAMES    = ' '
**       UCLEN          =
**       DO_NOT_WRITE   = ' '
**     IMPORTING
**       X030L_WA       =
**       DDOBJTYPE      =
**       DFIES_WA       =
**       LINES_DESCR    =
*        TABLES
*          dfies_tab      = lt_fields
**       FIXED_VALUES   =
*** Begin of Changes by Kapil on 03.04.2014
*        EXCEPTIONS
*          not_found      = 1
*          internal_error = 2
*          OTHERS         = 3
*** End of Changes by Kapil on 03.04.2014
*        .
*      IF sy-subrc <> 0.
*** Begin of Changes by Kapil on 03.04.2014
*        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
*                WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
*** End of Changes by Kapil on 03.04.2014
*      ENDIF.
      " END exception shouldn't stop program :
      " dump due to inactive field  -
      " ashish 17th NOV
      LOOP AT lt_fields INTO  lwa_fields.
        CLEAR: lv_local.
        "SHEKHAR24SEP2014
        IF lwa_fields-fieldname+0(1) = gc_dot.
          CONTINUE.
        ENDIF.
        "SHEKHAR24SEP2014
        CONCATENATE  lv_table gc_tilde lwa_fields-fieldname INTO
        lv_local.
        CONCATENATE lv_local lv_fields INTO lv_fields SEPARATED BY
        gc_seperator.
      ENDLOOP.
    ELSE.
      " selective fields used
      REFRESH lt_tab2[].
*Start of change DEF_18
      IF lv_str1 CS 'SINGLE' .
        SPLIT lv_str1 AT 'INTO' INTO lv_str1 lv_str1_2.
        REPLACE ALL OCCURRENCES OF 'SINGLE' IN lv_str1 WITH ' '.
      ENDIF.
*End of change DEF_18
      SPLIT lv_str1 AT space INTO TABLE lt_tab2.
      DELETE lt_tab2 WHERE text = ''.
      DELETE lt_tab2 WHERE text = gc_select.
      DELETE lt_tab2 WHERE text = gc_into.
      IF sy-subrc = 0.
        lv_index1 = sy-tabix - 1.
        IF lv_index1 GE 1.
          DELETE lt_tab2 INDEX lv_index1.
        ENDIF.
      ENDIF.

      LOOP AT lt_tab2 INTO  lwa_tab2.
        CLEAR: lv_local.
*Start of change DEF_18
*        CONCATENATE  lv_table gc_tilde lwa_tab2-text INTO lv_local.
*        CONCATENATE lv_local lv_fields INTO lv_fields
*        SEPARATED BY gc_seperator.
        CONCATENATE '|' lv_table gc_tilde lwa_tab2-text INTO lv_local.
        CONCATENATE lv_local lv_fields INTO lv_fields.
*End of change DEF_18

      ENDLOOP.
    ENDIF.
    " filter value and internal table
    REFRESH lt_tab2[].
    CLEAR: lv_str1, lv_str3.
    " start: split at EQ not mere SPLIT
*    SPLIT  lv_code AT 'WHERE' INTO lv_str1 lv_str3.
    pwa_code = lv_code.
    REFRESH lt_tab[].
    SPLIT pwa_code AT space INTO TABLE lt_tab.
    DELETE lt_tab WHERE text = ''.
    DELETE lt_tab WHERE text CS gc_open_bracket .
    DELETE lt_tab WHERE text CS gc_close_bracket .
    CLEAR: lwa_code1.
    CLEAR: lv_line.
    CLEAR: gv_join_fae. " 22NOV
    LOOP AT lt_tab INTO  lwa_code1.
      TRANSLATE lwa_code1-text TO UPPER CASE.
      IF lwa_code1-text = gc_where.  "WHERE
        lv_line = sy-tabix.
      ENDIF.
      IF lv_line IS INITIAL.
        CONCATENATE lv_str1 lwa_code1 INTO lv_str1 SEPARATED BY space.
        " start >FAE and JOIN % utilization logic 22NOV
        CONDENSE lv_str1.
        IF lv_str1 = gc_join.
          gv_join_fae = gc_x.
        ENDIF.
        " end >FAE and JOIN % utilization logic  22NOV
      ELSE.
        CONCATENATE lv_str3 lwa_code1 INTO lv_str3 SEPARATED BY space.
      ENDIF.
    ENDLOOP.
    REPLACE FIRST OCCURRENCE OF gc_where IN lv_str3 WITH ''.  "WHERE
    CLEAR: lv_line.
    REFRESH: lt_tab[].
*end of change by ashish --- need to break into internal table and
*then SPLIT at from
    CONDENSE lv_str3.
    " end: Split at EQ not mere SPLIT
    " start >FAE and JOIN % utilization logic 22NOV
    CONDENSE lv_str1.
    IF lv_str1 CS gc_for_all_ent_sp.
      gv_join_fae = gc_x.
    ENDIF.
    " end >FAE and JOIN % utilization logic  22NOV

    " start of where clause
    DATA: lvj_str1 TYPE string, lvj_str2 TYPE string.
    CLEAR: lvj_str1, lvj_str2.
    TRANSLATE lv_str3 TO UPPER CASE.
    CONDENSE lv_str3.

    lvj_str2 = lv_str3.
* finds fields used in WHERE clause of JOIN statement
    REFRESH lt_tab4[].
    IF lvj_str2 IS NOT INITIAL.
      CLEAR: lv_str2_tmp.
      CLEAR: lv_leng.
      lv_leng = strlen( lvj_str2 ).
      lv_leng = lv_leng - 1.
      IF lvj_str2+lv_leng(1) = gc_dot.
        lv_str2_tmp = lvj_str2+0(lv_leng).
      ELSE.
        lv_str2_tmp = lvj_str2.
      ENDIF.
      SPLIT lv_str2_tmp AT '' INTO TABLE lt_tab4.
      DELETE lt_tab4[] WHERE text = ''.
      DELETE lt_tab4[] WHERE text = gc_and. "AND
      DELETE lt_tab4[] WHERE text = gc_or.  "OR
      DELETE lt_tab4[] WHERE text = gc_close_bracket.
      DELETE lt_tab4[] WHERE text = gc_open_bracket.
      DELETE lt_tab4[] WHERE text = gc_not.  "NOT

      " added by ashish on 09Oct -- need to remove NOT from SELECT
      "before analysis

      CLEAR: lwa_tab4.
      REFRESH: lt_tab3[] .

**BEgin changes "Shekhar19SEp2014
      DATA : lv_sytabix TYPE sy-tabix.
      LOOP AT lt_tab4 INTO lwa_tab4.
        IF lwa_tab4-text IN gr_where[].
          IF lwa_tab4-text = gc_between.
            lv_sytabix = 1.
          ENDIF.
          IF lv_sytabix = 1 AND  lwa_tab4-text = gc_and. "AND
            CLEAR lv_sytabix.
            CONTINUE.
          ENDIF.
          CLEAR lwa_tab4.
          lv_stbix =  sy-tabix - 1.
          IF lv_stbix GE 1.
            READ TABLE lt_tab4 INTO lwa_tab4 INDEX lv_stbix.
            IF sy-subrc IS INITIAL.
              APPEND lwa_tab4 TO lt_tab3.
            ENDIF.
          ENDIF.
          CLEAR : lv_stbix.
        ENDIF.
      ENDLOOP.
****    LOOP AT lt_tab4 INTO lwa_tab4.
****      sy-tabix = sy-tabix - 1.
****      DATA : ch1 TYPE n.
****      ch1 =  sy-tabix  MOD  3.
****      IF ch1  = 0.
****        APPEND lwa_tab4 TO lt_tab3.
****      ENDIF.
****      CLEAR : ch1.
****    ENDLOOP.
**End changes "Shekhar19SEp2014

*    SORT lt_tab3 BY text. "SHEKHAR23SEP2014
      DELETE ADJACENT DUPLICATES FROM lt_tab3 COMPARING text.
      LOOP AT lt_tab3 INTO lwa_tab4.
        CLEAR: lv_local.
        CONCATENATE  lv_table gc_tilde lwa_tab4-text INTO lv_local.
        CONCATENATE lvj_str1 lv_local INTO lvj_str1 SEPARATED BY
        gc_seperator.
      ENDLOOP.
    ENDIF.
    IF lv_str3 CS gc_select AND lv_str3 CS gc_from.
      lwa_final-where_con  = 'Select Statement in WHERE Clause'.
    ELSE.
      lwa_final-where_con = lvj_str1.
    ENDIF.
    " end of where clause
    REPLACE FIRST OCCURRENCE OF gc_dot IN lv_str3 WITH ''.
    CONDENSE lv_str3.
    REFRESH lt_tab4[].
    CLEAR: lv_str_tmp,lv_str3.
    CLEAR: lv_str1.
    " remove '( '  ')' from lv_code
    pwa_code = lv_code.
    CLEAR: lv_str1, lv_str3.
    SPLIT pwa_code AT space INTO TABLE lt_tab.
    DELETE lt_tab WHERE text = ''.
    DELETE lt_tab WHERE text CS gc_open_bracket .
    DELETE lt_tab WHERE text CS gc_close_bracket .
    CLEAR: lwa_code1.
    CLEAR: lv_line.
    LOOP AT lt_tab INTO  lwa_code1.
      TRANSLATE lwa_code1-text TO UPPER CASE.
      IF lwa_code1-text = gc_table.
        lv_line = sy-tabix.
      ENDIF.
      IF lv_line IS INITIAL.
        CONCATENATE lv_str1 lwa_code1 INTO lv_str1 SEPARATED BY space.
      ELSE.
        CONCATENATE lv_str3 lwa_code1 INTO lv_str3 SEPARATED BY space.
      ENDIF.
    ENDLOOP.
    REPLACE FIRST OCCURRENCE OF gc_table IN lv_str3 WITH ''.
    CLEAR: lv_line.
    REFRESH: lt_tab[].

*    READ TABLE lt_tab4 INTO lwa_tab2 WITH  KEY text = 'TABLE'.
*    IF sy-subrc = 0.
*      SPLIT  lv_code AT 'TABLE' INTO lv_str1 lv_str3.
*    ENDIF.
*    REFRESH lt_tab4[].
    IF lv_str3 = ''.
      lv_flag = gc_x.
      CLEAR: lv_str1, lv_str3.
      pwa_code = lv_code.
      REFRESH: lt_tab[].
      SPLIT pwa_code AT space INTO TABLE lt_tab.
      DELETE lt_tab WHERE text = ''.
      DELETE lt_tab WHERE text CS gc_open_bracket .
      DELETE lt_tab WHERE text CS gc_close_bracket .
      CLEAR: lwa_code1.
      CLEAR: lv_line.
      LOOP AT lt_tab INTO  lwa_code1.
        TRANSLATE lwa_code1-text TO UPPER CASE.
        IF lwa_code1-text = gc_into.
          lv_line = sy-tabix.
        ENDIF.
        IF lv_line IS INITIAL.
          CONCATENATE lv_str1 lwa_code1 INTO lv_str1 SEPARATED BY space.
        ELSE.
          CONCATENATE lv_str3 lwa_code1 INTO lv_str3 SEPARATED BY space.
        ENDIF.
      ENDLOOP.
      REPLACE FIRST OCCURRENCE OF gc_into IN lv_str3 WITH ''.
      CLEAR: lv_line.
      REFRESH: lt_tab[].

*      SPLIT  lv_code AT 'INTO' INTO lv_str1 lv_str3.
    ENDIF.
    REPLACE FIRST OCCURRENCE OF gc_dot IN lv_str3 WITH ''.
    CONDENSE lv_str3. CLEAR: lv_str1.
    SPLIT lv_str3 AT space INTO lv_str1 lv_str3.
    IF lv_flag = gc_x.
      IF lv_str1 CS gc_corr.
        CONDENSE lv_str3.
        SPLIT  lv_str3 AT gc_of INTO lv_str3 lv_str1.
        CONDENSE lv_str1.
        SPLIT  lv_str1 AT '' INTO lv_str1 lv_str3.
      ELSE.
        IF lv_str3 IS NOT INITIAL OR lv_str1 CS gc_comma.
          CONDENSE lv_str3.
          CLEAR: lv_wac, lv_cmc.
          lv_wac = 1. " work area count
          IF lv_str1 CS gc_comma.
            lv_cmc = 1.  " comma count
          ELSE.
            CLEAR lv_cmc.
          ENDIF.
          REFRESH lt_tab[].
          SPLIT lv_str3 AT '' INTO TABLE lt_tab[].
          DELETE lt_tab[] WHERE text = ''.
          LOOP AT lt_tab INTO lwa_tab.
            IF lwa_tab CS gc_comma.
              lv_cmc = lv_cmc + 1.
            ENDIF.
            IF strlen( lwa_tab ) > 1.
              lv_wac = lv_wac + 1.
            ENDIF.

            CLEAR: lv_sub.
            lv_sub =  lv_wac - lv_cmc.
*          if lv_wac - lv_cmc > 1.
            IF lv_sub > 1.
              EXIT.
            ELSE.
              CONCATENATE lv_str1 lwa_tab INTO lv_str1 SEPARATED BY ''.

            ENDIF.
          ENDLOOP.
          REFRESH lt_tab[].
        ENDIF.
      ENDIF.
      lv_wa = lv_str1.
    ELSE.
      lv_itabs = lv_str1.
    ENDIF.

    CLEAR: lv_str1, lv_str2.
    REFRESH lt_tab2[].
    CONDENSE lv_filters.
    SPLIT lv_filters AT space INTO TABLE lt_tab2.
    DELETE lt_tab2 WHERE text = ''.
    DELETE lt_tab2 WHERE text NS '-'.
    LOOP AT lt_tab2 INTO lwa_tab2.
      IF lwa_tab2 CS '-'.
        SPLIT lwa_tab2 AT '-' INTO lv_str1 lv_str2.
        lwa_tab2 = lv_str1.
        REPLACE FIRST OCCURRENCE OF gc_dot IN lwa_tab2 WITH ''.
        CONDENSE lwa_tab2.
        IF sy-tabix GE 1.
          MODIFY lt_tab2 FROM lwa_tab2 INDEX sy-tabix.
        ENDIF.
      ENDIF.
    ENDLOOP.
    SORT lt_tab2 BY text.
    DELETE ADJACENT DUPLICATES FROM lt_tab2 COMPARING ALL FIELDS.

    LOOP AT lt_tab2 INTO lwa_tab2.
      CONCATENATE lwa_tab2 lv_loop INTO lv_loop SEPARATED BY
      gc_seperator.
    ENDLOOP.
    lwa_final-drill = gv_drill.  " added for drill test -- CAUTION!!!
    lwa_final-loop = lv_loop.
*    lwa_final-code = lv_code.
    lwa_final-code = lv_original.
    lwa_final-fields = lv_fields.
    lwa_final-itabs = lv_itabs.
    lwa_final-wa = lv_wa.
    lwa_final-filters = lv_filters.

    CLEAR: lv_str1,lv_str2.

    pwa_code = lv_code.
*    SPLIT pwa_code AT 'FROM' INTO lv_str1 lv_str2.
    REFRESH lt_tab[].
    CLEAR: lv_str1, lv_str2.
    SPLIT pwa_code AT space INTO TABLE lt_tab.
    DELETE lt_tab WHERE text = ''.
    DELETE lt_tab WHERE text CS gc_open_bracket .
    DELETE lt_tab WHERE text CS gc_close_bracket .
    CLEAR: lwa_code1.
    CLEAR: lv_line.
    LOOP AT lt_tab INTO  lwa_code1.
      TRANSLATE lwa_code1-text TO UPPER CASE.
      IF lwa_code1-text = gc_from.
        lv_line = sy-tabix.
      ENDIF.
      IF lv_line IS INITIAL.
        CONCATENATE lv_str1 lwa_code1 INTO lv_str1 SEPARATED BY space.
      ELSE.
        CONCATENATE lv_str2 lwa_code1 INTO lv_str2 SEPARATED BY space.
      ENDIF.
    ENDLOOP.
    REPLACE FIRST OCCURRENCE OF gc_from IN lv_str2 WITH ''.
    CLEAR: lv_line.
    CONDENSE lv_str2.
    CONDENSE lv_str1.

    IF lv_str1 CS gc_select_sing.
      REPLACE FIRST OCCURRENCE OF gc_select_sing IN lv_str1 WITH
               gc_select.
      CONDENSE lv_str1.
    ENDIF.

    IF lv_str2 CS gc_select_sing.
      REPLACE FIRST OCCURRENCE OF gc_select_sing IN lv_str2 WITH
               gc_select.
      CONDENSE lv_str2.
    ENDIF.

    "start of change by ashish 23sep : INTO corresponding
    "clause need to be removed.
    IF lv_str1 CS gc_corr_field_of.
      REPLACE FIRST OCCURRENCE OF gc_corr_field_of IN
      lv_str1
      WITH gc_into.
      CONDENSE lv_str1.
    ENDIF.
    IF lv_str2 CS gc_corr_field_of.
      REPLACE FIRST OCCURRENCE OF gc_corr_field_of IN
      lv_str2
      WITH gc_into.
      CONDENSE lv_str2.
    ENDIF.

    "end of change by ashish 23sep : INTO corresponding
    "clause need to be removed.

    IF ( lv_str1 CS gc_into_tab OR lv_str1 CS gc_app_tab ) .
      "14th NOV ashish.
      CLEAR: lwa_intab, lt_tab, lt_intab, lt_wa.
      CONDENSE lv_str1.
      SPLIT lv_str1 AT space INTO TABLE lt_tab.
      READ TABLE lt_tab INTO pwa_code INDEX 5.
      IF sy-subrc IS INITIAL.
        CLEAR lwa_intab.
        lwa_intab-progname = gv_prog.
        lwa_intab-intab = pwa_code.
        CLEAR lt_tab.
        CONDENSE lv_str2.
        SPLIT lv_str2 AT space INTO TABLE lt_tab.
        DELETE lt_tab WHERE text CS gc_open_bracket ."changesAt10102014
        DELETE lt_tab WHERE text CS gc_close_bracket ."changesAt10102014
        READ TABLE lt_tab INTO pwa_code INDEX 1.
        IF sy-subrc IS INITIAL.
          lwa_intab-table = pwa_code.
          CLEAR lt_dfies.
          " START-exception shouldn't stop program :
          "dump due to inactive field-
          " ashish 17th NOV
          PERFORM get_fields TABLES gt_fields
                             USING lwa_intab-table .

          lt_fields[] = gt_fields[].
          REFRESH: gt_fields[].
*          CALL FUNCTION 'DDIF_FIELDINFO_GET'
*            EXPORTING
*              tabname        = lwa_intab-table
*              langu          = sy-langu
*            TABLES
*              dfies_tab      = lt_dfies
*            EXCEPTIONS
*              not_found      = 1
*              internal_error = 2
*              OTHERS         = 3.
*          IF sy-subrc <> 0.
*            MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
*                    WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
*          ENDIF.
          IF lt_fields[] IS NOT INITIAL.
*          DESCRIBE TABLE lt_dfies LINES lv_line.
            DESCRIBE TABLE  lt_fields LINES lv_line.
            " END-exception shouldn't stop program :
            "dump due to inactive field-
            " ashish 17th NOV
            CONDENSE lv_line.
            lwa_intab-line = p_index.
            lwa_intab-fieldcount = lv_line.
            APPEND lwa_intab TO lt_intab.
          ENDIF.
        ENDIF.
      ENDIF.
    ELSEIF ( lv_str2 CS gc_into_tab OR lv_str2 CS gc_app_tab )
. " 14th NOV ashish) .
      CLEAR: lwa_intab, lt_tab, lt_intab.
      CLEAR lv_str1.
      CONDENSE lv_str2.
      SPLIT lv_str2 AT space INTO TABLE lt_tab.
      CLEAR lv_str2.
      CLEAR pwa_code.
      DELETE lt_tab WHERE text CS gc_open_bracket ."changesAt10102014
      DELETE lt_tab WHERE text CS gc_close_bracket ."changesAt10102014
      READ TABLE lt_tab INTO pwa_code INDEX 1.
      IF sy-subrc IS INITIAL.
        lwa_intab-progname = gv_prog.
        lwa_intab-table = pwa_code.
        CLEAR lt_dfies.
        " START-exception shouldn't stop program :
        " dump due to inactive field-
        " ashish 17th NOV
        PERFORM get_fields TABLES gt_fields
                           USING lwa_intab-table .

        lt_fields[] = gt_fields[].
        REFRESH: gt_fields[].
**
*        CALL FUNCTION 'DDIF_FIELDINFO_GET'
*          EXPORTING
*            tabname        = lwa_intab-table
*            langu          = sy-langu
*          TABLES
*            dfies_tab      = lt_dfies
*          EXCEPTIONS
*            not_found      = 1
*            internal_error = 2
*            OTHERS         = 3.
*        IF sy-subrc <> 0.
*          MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
*                  WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
*        ENDIF.
        IF lt_fields[] IS NOT INITIAL.
*          DESCRIBE TABLE lt_dfies LINES lv_line.
          DESCRIBE TABLE  lt_fields LINES lv_line.
          " END-exception shouldn't stop program :
          " dump due to inactive field-
          " ashish 17th NOV

          CONDENSE lv_line.
          READ TABLE lt_tab INTO pwa_code INDEX 4.
          IF sy-subrc IS INITIAL.
            lwa_intab-intab = pwa_code.
            lwa_intab-line = p_index.
            lwa_intab-fieldcount = lv_line.
            APPEND lwa_intab TO lt_intab.
          ENDIF.
        ENDIF.
      ENDIF.
    ENDIF.

    IF ( lv_str1 CS gc_into ).
*      CLEAR: lwa_intab, lt_tab, lt_intab, lt_wa. " 14th NOV
      CLEAR: lwa_intab, lt_tab, lt_wa. " 14th NOV
      CONDENSE lv_str1.
      SPLIT lv_str1 AT space INTO TABLE lt_tab.
      READ TABLE lt_tab INTO pwa_code INDEX 4.
      IF sy-subrc IS INITIAL AND pwa_code <> gc_table.
        CLEAR lwa_intab.
        lwa_intab-progname = gv_prog.
        lwa_intab-intab = pwa_code.
        CLEAR lt_tab.
        CONDENSE lv_str2.
        SPLIT lv_str2 AT space INTO TABLE lt_tab.
        DELETE lt_tab WHERE text CS gc_open_bracket ."changesAt10102014
        DELETE lt_tab WHERE text CS gc_close_bracket ."changesAt10102014
        READ TABLE lt_tab INTO pwa_code INDEX 1.
        IF sy-subrc IS INITIAL.
          lwa_intab-table = pwa_code.
          CLEAR lt_dfies.
          " START-exception shouldn't stop program :
          " dump due to inactive field-
          " ashish 17th NOV
          PERFORM get_fields TABLES gt_fields
                             USING lwa_intab-table .

          lt_fields[] = gt_fields[].
          REFRESH: gt_fields[].
**
*          CALL FUNCTION 'DDIF_FIELDINFO_GET'
*            EXPORTING
*              tabname        = lwa_intab-table
*              langu          = sy-langu
*            TABLES
*              dfies_tab      = lt_dfies
*            EXCEPTIONS
*              not_found      = 1
*              internal_error = 2
*              OTHERS         = 3.
*          IF sy-subrc <> 0.
*            MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
*                    WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
*          ENDIF.

          IF lt_fields[] IS NOT INITIAL.
*          DESCRIBE TABLE lt_dfies LINES lv_line.
            DESCRIBE TABLE  lt_fields LINES lv_line.
            " END-exception shouldn't stop program :
            " dump due to inactive field-
            " ashish 17th NOV
            CONDENSE lv_line.
            lwa_intab-line = p_index.
            lwa_intab-fieldcount = lv_line.
            APPEND lwa_intab TO lt_intab.
          ENDIF.
        ENDIF.
      ENDIF.
    ELSEIF ( lv_str2 CS gc_into ) .
      CLEAR: lwa_intab, lt_tab ."lt_intab. " 14th nov
      CLEAR lv_str1.
      CONDENSE lv_str2.
      SPLIT lv_str2 AT space INTO TABLE lt_tab.
      CLEAR lv_str2.
      CLEAR pwa_code.
      READ TABLE lt_tab INTO pwa_code INDEX 3.
      IF sy-subrc IS INITIAL AND pwa_code <> gc_table.
        lwa_intab-intab = pwa_code.
        lwa_intab-line = p_index.
        DELETE lt_tab WHERE text CS gc_open_bracket ."changesAt10102014
        DELETE lt_tab WHERE text CS gc_close_bracket ."changesAt10102014
        READ TABLE lt_tab INTO pwa_code INDEX 1.
        IF sy-subrc IS INITIAL.
          lwa_intab-progname = gv_prog.
          lwa_intab-table = pwa_code.
          CLEAR lt_dfies.
          " START-exception shouldn't stop program :
          " dump due to inactive field-
          " ashish 17th NOV
          PERFORM get_fields TABLES gt_fields
                             USING lwa_intab-table .

          lt_fields[] = gt_fields[].
          REFRESH: gt_fields[].
**
*          CALL FUNCTION 'DDIF_FIELDINFO_GET'
*            EXPORTING
*              tabname        = lwa_intab-table
*              langu          = sy-langu
*            TABLES
*              dfies_tab      = lt_dfies
*            EXCEPTIONS
*              not_found      = 1
*              internal_error = 2
*              OTHERS         = 3.
*          IF sy-subrc <> 0.
*            MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
*                    WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
*          ENDIF.

          IF lt_fields[] IS NOT INITIAL.
*          DESCRIBE TABLE lt_dfies LINES lv_line.
            DESCRIBE TABLE  lt_fields LINES lv_line.
            " END-exception shouldn't stop program :
            " dump due to inactive field-
            " ashish 17th NOV
            CONDENSE lv_line.
            lwa_intab-fieldcount = lv_line.
            APPEND lwa_intab TO lt_intab.
          ENDIF.
        ENDIF.
      ENDIF.
    ENDIF.

    READ TABLE lt_intab INTO lwa_intab INDEX 1.

    CONDENSE lwa_code.
    REFRESH: lt_ini_tab2[] . " ashish sep19
    LOOP AT lt_intab INTO lwa_intab.
*     lv_pform = sy-tabix.
* Begin of changes for % calculation of fields by Atul 05_09_2014
      CONDENSE lwa_intab-line.
      CONDENSE lwa_intab-fieldcount.
      CONDENSE lwa_intab-intab.
      REPLACE ALL OCCURRENCES OF gc_dot IN lwa_intab-intab WITH ''.
      IF sy-tabix GE 1.
        MODIFY lt_intab INDEX sy-tabix FROM lwa_intab.
      ENDIF.
      CLEAR : lv_init_cn, lv_init_cn1.
      lv_init_cn = lwa_intab-intab.
      CONCATENATE '=' lv_init_cn INTO lv_init_cn1 SEPARATED BY space.
      CONDENSE  lv_init_cn1 .
      CONDENSE  lv_init_cn.
      CLEAR: lv_insuff." ashish18sep
**If condition to reduce the extra processing of FMs**
      CHECK gv_prog IS NOT INITIAL.
      IF gv_prog+0(2) = gc_lz OR gv_prog+0(2) = gc_ly.
        CLEAR lv_tabix2.
        wa_progname-progname = gv_prog.
        READ REPORT wa_progname-progname INTO p_code2.
        CHECK sy-subrc = 0.
        LOOP AT p_code2 INTO lwa_code WHERE text CS  lv_init_cn1 AND
        text NS
        gc_where.    " = assignment between internal tables
          "start of change by ashish 22OCT --
          "Contain string pattern should be validated with equal
          lv_tabix2 = sy-tabix.
          CONDENSE lwa_code-text.
          TRANSLATE lwa_code-text TO UPPER CASE.
          REFRESH lt_tab4[].
          SPLIT lwa_code-text AT space INTO TABLE lt_tab4[].
          " start by ashish: itab[] shoudn't be skiped.17th NOV
          LOOP AT lt_tab4 INTO lwa_tab4.
            IF lwa_tab4-text CS gc_bracket.
              REPLACE FIRST OCCURRENCE OF gc_bracket IN lwa_tab4-text
              WITH ''.
              CONDENSE lwa_tab4-text.
            ENDIF.
            IF lwa_tab4-text CS gc_dot.
              REPLACE FIRST OCCURRENCE OF gc_dot IN lwa_tab4-text WITH
              ''.
              CONDENSE lwa_tab4-text.
            ENDIF.
            MODIFY lt_tab4 FROM lwa_tab4 INDEX sy-tabix.

          ENDLOOP.
          " End by ashish: itab[] shoudn't be skiped. 17th NOV
          READ TABLE lt_tab4 INTO lwa_tab4 WITH KEY text =
          lwa_intab-intab.
          CHECK sy-subrc = 0.
          REFRESH lt_tab4[].
          "End of change by ashish 22OCT --
          "Contain string pattern should be validated with equal
          "start: ashish17sep code to segregate method and
          " CALL function from internal table assigment
          IF lwa_code-text = '' OR lwa_code-text+0(1) = gc_star OR
          lwa_code-text+0(1) = gc_doub_quote OR lwa_code-text CS '->' OR
          lwa_code-text CS '=>'.
            IF lwa_code-text CS '->' OR  lwa_code-text CS '=>'.
              lv_insuff = gc_x.
            ENDIF.
            "ashish17sep code to segregate method and CALL function
            " from internal table assigment
            CONTINUE.
            "End: ashish17sep code to segregate method and CALL function
            " from internal table assigment
          ENDIF.
*Concatenate full statement in a line
          sy-tabix = lv_tabix2.
          PERFORM get_line  USING p_code2
                                  sy-tabix
                            CHANGING lv_per1
                                     var_line.
          lwa_code = lv_per1.
          TRANSLATE lwa_code TO UPPER CASE.
          CLEAR : lv_per1 , var_line.
          CONDENSE lwa_code-text.
          CHECK lwa_code-text CS lv_init_cn1.
          "Begin :ashish17sep code to segregate method and CALL function
          " from internal table assigment
          "start of change by ashish 09 OCT  --- should check EQ not CS
          CLEAR: lv_str33, lv_str2.
          SPLIT lwa_code-text AT lv_init_cn1 INTO lv_str33 lv_str2.
          REPLACE FIRST OCCURRENCE OF gc_bracket IN lv_str2 WITH ''.
          CLEAR:   lv_char1.
          lv_char1 = lv_str2.
          IF  lv_char1+0(1) = ''  OR lv_char1+0(1) = gc_dot
             OR lv_char1+0(1) = '-'.
            "end of change by ashish 09 OCT  --- should check EQ not CS

            CLEAR: lv_cc.
            CLEAR: lv_str33, var_count2 ,var_count, lwa_code2 ,lv_str2,
            lv_index2.
            CONCATENATE lv_sq lv_dq INTO lv_cc.
            CONDENSE lv_cc.

            lv_str33 = lwa_code-text.
            lv_index2 = sy-tabix.
            CLEAR: lv_index22.
            lv_index22 = lv_index2.
            WHILE ( 1 = 1 ) .
              READ TABLE p_code2 INTO lwa_code2 INDEX lv_index2.
*            lv_index2 = lv_index2 - 1.
              TRANSLATE lwa_code2 TO UPPER CASE.
              IF lwa_code2 CS gc_doub_quote AND lwa_code2 NS lv_cc.
                SPLIT lwa_code2 AT gc_doub_quote INTO lwa_code2 lv_str33
                .
                CLEAR lv_str33.
              ENDIF.

              IF lwa_code2+0(1) EQ gc_doub_quote OR  lwa_code2+0(1) =
              gc_star
                OR lwa_code2 IS INITIAL.
                lv_index2 = lv_index2 - 1.
                CONTINUE.
              ENDIF.

              var_count = strlen( lwa_code2-text ).
              var_count2 = var_count - 1.
              IF lv_index22 > lv_index2.
                IF lwa_code2-text+var_count2(var_count) = gc_dot
                  OR lv_index2 < 0.
                  EXIT.
                ENDIF.
                CONCATENATE lwa_code2  lv_str33 INTO lv_str33
                SEPARATED BY space.
              ENDIF.

              lv_index2 = lv_index2 - 1.
            ENDWHILE.
            CONDENSE lv_str33.
            " neglect select from assignment
            CLEAR: lv_str34, lv_str35.
            SPLIT lv_str33 AT space INTO lv_str34 lv_str35.
            CONDENSE lv_str34.
            CHECK lv_str34 NS gc_select.

*          if lv_str33 cs 'CALL FUNCTION' or lv_str33 cs 'CALL METHOD'..
*            lv_insuff = gc_x.
*          endif.
            IF lv_str33 CS gc_call_func
              OR lv_str33 CS gc_call_meth
              OR lv_str33 CS '=>'.
              lv_insuff = gc_x.
            ENDIF.
*
*          check lv_str33 ns 'CALL FUNCTION' and lv_str33 ns
*          'CALL METHOD'.
*
            CHECK lv_str33 NS gc_call_func AND lv_str33 NS
         gc_call_meth AND lv_str33 NS '=>'.


            CLEAR: lv_str33, var_count2 , var_count, lwa_code2 ,lv_str2,
            lv_index2.
            "End: ashish17sep code to segregate method and CALL function
            "from internal table assigment
            SPLIT lwa_code AT space INTO TABLE lt_tab.
            CHECK lt_tab IS NOT INITIAL.
            READ TABLE lt_tab INTO lwa_intab1-intab INDEX 1.
            REPLACE ALL OCCURRENCES OF gc_dot IN lwa_intab1-intab WITH
            ''.
            REPLACE ALL OCCURRENCES OF gc_bracket IN lwa_intab1-intab
            WITH ''.
*      DESCRIBE TABLE lwa_intab-intab lines lv_line.
            lwa_intab1-progname = gv_prog.
            lwa_intab1-fieldcount = lv_line.
            lwa_intab1-table  =  lwa_intab-table.
            lwa_intab1-intab = lwa_intab1-intab.
            lwa_intab1-line = lwa_intab-line.
            lwa_intab1-fieldcount = lwa_intab-fieldcount.
            APPEND lwa_intab1 TO lt_ini_tab.
            CLEAR : lt_tab, lwa_intab1. " lwa_intab.
          ENDIF.
        ENDLOOP.
*    ENDLOOP.
        CLEAR: lwa_code. "ashish18sep
* For All Enteries % calc
        LOOP AT p_code2 INTO lwa_code WHERE text CS lwa_intab-intab AND
        text
        CS 'FOR ALL ENTERIES'.   " for all entries
          lv_init = gc_x.
        ENDLOOP.
        CLEAR: lwa_code. "ashish18sep
*to check move for % calc
        LOOP AT p_code2 INTO lwa_code WHERE text CS lwa_intab-intab AND
        text
        CS gc_move.
          lv_tabix2 = sy-tabix.
          "start of change by ashish 22OCT --
          "Contain string pattern should be validated with equal
          CONDENSE lwa_code-text.
          TRANSLATE lwa_code-text TO UPPER CASE.
          REFRESH lt_tab4[].
          SPLIT lwa_code-text AT space INTO TABLE lt_tab4[].
          " start by ashish: itab[] shoudn't be skiped.17th NOV
          LOOP AT lt_tab4 INTO lwa_tab4.
            IF lwa_tab4-text CS gc_bracket.
              REPLACE FIRST OCCURRENCE OF gc_bracket IN lwa_tab4-text
              WITH ''.
              CONDENSE lwa_tab4-text.
            ENDIF.
            IF lwa_tab4-text CS gc_dot.
              REPLACE FIRST OCCURRENCE OF gc_dot IN lwa_tab4-text WITH
              ''.
              CONDENSE lwa_tab4-text.
            ENDIF.
            MODIFY lt_tab4 FROM lwa_tab4 INDEX sy-tabix.

          ENDLOOP.
          " End by ashish: itab[] shoudn't be skiped. 17th NOV
          READ TABLE lt_tab4 INTO lwa_tab4 WITH KEY text =
          lwa_intab-intab.
          CHECK sy-subrc = 0.
          REFRESH lt_tab4[].
          IF lwa_code-text = '' OR lwa_code-text+0(1) = gc_star OR
        lwa_code-text+0(1) = gc_doub_quote.
            CONTINUE.
          ENDIF.
          "End of change by ashish 22OCT --
          "Contain string pattern should be validated with equal

*Concatenate full statement in a line
          sy-tabix = lv_tabix2.
          PERFORM get_line  USING p_code2
                              sy-tabix
                        CHANGING lv_per1
                                 var_line.
          lwa_code-text = lv_per1.
          CLEAR : var_line , lt_tab.
          TRANSLATE lwa_code-text TO  UPPER CASE.
          REPLACE ALL OCCURRENCES OF gc_colon IN lwa_code-text WITH
          space.
          REPLACE ALL OCCURRENCES OF gc_comma IN lwa_code-text WITH
          space.
          CONDENSE lwa_code-text.
          SPLIT lwa_code-text AT space INTO TABLE lt_tab.
          DELETE lt_tab WHERE text = ''.
          DELETE lt_tab WHERE text = gc_dot.
          LOOP AT lt_tab INTO lwa_tab WHERE text = gc_to.
            TRANSLATE lwa_tab-text TO UPPER CASE.
            var_line = sy-tabix - 1.
            var_line1 = sy-tabix + 1.
            READ TABLE lt_tab INTO lwa_intab1-intab INDEX var_line1.
            IF lwa_intab1-intab+0(1) = ''''.
              CLEAR : lwa_intab1-intab.
            ENDIF.
            SPLIT lwa_intab1-intab AT '-' INTO lwa_intab1-intab lv_per1.
            CONDENSE lwa_intab1-intab.
            CLEAR : lv_per1.
            REPLACE ALL OCCURRENCES OF gc_dot IN lwa_intab1-intab WITH
            ''.
            REPLACE ALL OCCURRENCES OF gc_bracket IN lwa_intab1 WITH ''.
            IF lwa_intab1-intab IS NOT INITIAL.
              lwa_intab1-progname = gv_prog.
              lwa_intab1-fieldcount = lv_line.
              lwa_intab1-table  =  lwa_intab-table.
              lwa_intab1-intab = lwa_intab1-intab.
              lwa_intab1-line = lwa_intab-line.
              lwa_intab1-fieldcount = lwa_intab-fieldcount.
              APPEND lwa_intab1 TO lt_ini_tab.
              CLEAR : lwa_intab1.
              CLEAR : var_line , var_line1 .
            ENDIF.
            " start - not needed - repeated
*          READ TABLE lt_tab INTO lwa_intab1-intab INDEX var_line1.
*          IF lwa_intab1-intab+0(1) = ''''.
*            CLEAR : lwa_intab1-intab.
*          ENDIF.
**          SPLIT lwa_intab1-intab AT '-' INTO lwa_intab1-intab lv_per1.
*          CONDENSE lwa_intab1-intab.
*          CLEAR : lv_per1.
*          REPLACE ALL OCCURRENCES OF '.' IN lwa_intab1 WITH ''.
*          REPLACE ALL OCCURRENCES OF '[]' IN lwa_intab1 WITH ''.
*          CONDENSE lwa_intab1-intab.
*          CHECK lwa_intab1-intab IS NOT INITIAL.
*          lwa_intab1-progname = gv_prog.
*          lwa_intab1-fieldcount = lv_line.
*          lwa_intab1-table  =  lwa_intab-table.
*          lwa_intab1-intab = lwa_intab1-intab.
*          lwa_intab1-line = lwa_intab-line.
*          lwa_intab1-fieldcount = lwa_intab-fieldcount.
*          APPEND lwa_intab1 TO lt_ini_tab.
*          CLEAR : lt_tab, lwa_intab1 . " lwa_intab.
*          CLEAR : var_line , var_line1 .
            " end : not needed - repeated
          ENDLOOP.

        ENDLOOP.
        CLEAR: lwa_code. "ashish18sep

*** code fr read Logic***
        LOOP AT p_code2 INTO lwa_code WHERE text CS lwa_intab-intab AND
        text CS
        gc_read. " READ
          lv_tabix2 =  sy-tabix.
          "start of change by ashish 22OCT --
          "Contain string pattern should be validated with equal
          CONDENSE lwa_code-text.
          TRANSLATE lwa_code-text TO UPPER CASE.
          REFRESH lt_tab4[].
          SPLIT lwa_code-text AT space INTO TABLE lt_tab4[].
          " start by ashish: itab[] shoudn't be skiped.17th NOV
          LOOP AT lt_tab4 INTO lwa_tab4.
            IF lwa_tab4-text CS gc_bracket.
              REPLACE FIRST OCCURRENCE OF gc_bracket IN lwa_tab4-text
              WITH ''.
              CONDENSE lwa_tab4-text.
            ENDIF.
            IF lwa_tab4-text CS gc_dot.
              REPLACE FIRST OCCURRENCE OF gc_dot IN lwa_tab4-text WITH
              ''.
              CONDENSE lwa_tab4-text.
            ENDIF.
            MODIFY lt_tab4 FROM lwa_tab4 INDEX sy-tabix.

          ENDLOOP.
          " End by ashish: itab[] shoudn't be skiped. 17th NOV
          READ TABLE lt_tab4 INTO lwa_tab4 WITH KEY text =
          lwa_intab-intab.
          CHECK sy-subrc = 0.
          REFRESH lt_tab4[].
          "End of change by ashish 22OCT --
          "Contain string pattern should be validated with equal

          CONDENSE lwa_code-text.
          IF lwa_code-text = '' OR lwa_code-text+0(1) = gc_star OR
          lwa_code-text+0(1)
          = gc_doub_quote.
            CONTINUE.
          ENDIF.

*Concatenate full statement in a line
          sy-tabix = lv_tabix2 .
          PERFORM get_line USING p_code2
          sy-tabix
          CHANGING lv_per1
          var_line.
          lwa_code = lv_per1.
          CONDENSE: lwa_code-text.
          CLEAR: lv_str34, lv_str35, lwa_tab1.
          SPLIT lwa_code-text AT space INTO lv_str34 lv_str35.
          IF lv_str34 CS gc_read AND lv_str34 CS gc_into.
            " added by ashish on 09 OCT
            SPLIT lv_str35 AT space INTO lv_str34 lv_str35.
            IF lv_str34 CS gc_table.
              REFRESH lt_tab[].
              SPLIT lwa_code AT ' ' INTO TABLE lt_tab.
              DELETE lt_tab WHERE text = ''.
              READ TABLE lt_tab INTO lwa_tab1 INDEX 5.
              REPLACE FIRST OCCURRENCE OF gc_dot IN lwa_tab1 WITH space.
              REPLACE FIRST OCCURRENCE OF gc_comma IN lwa_tab1 WITH
              space.
              CONDENSE lwa_tab1.
              lwa_intab1-progname = gv_prog.
              lwa_intab1-intab = lwa_tab1.
* lwa_intab1-wa = pwa_code.
              lwa_intab1-table = lwa_intab-table.
              lwa_intab1-line = lwa_intab-line.
              lwa_intab1-fieldcount = lv_line.
*APPEND lwa_wa TO lt_wa.
              APPEND lwa_intab1 TO lt_ini_tab.
              CLEAR : lt_tab, lwa_intab1 .
            ENDIF.
          ENDIF.
        ENDLOOP .

        CLEAR: lwa_code.
****end code for read ogic***
********Logic for sort statement*******By Atul 07oct2014

        LOOP AT p_code2 INTO lwa_code WHERE text CS lwa_intab-intab AND
        text
           CS gc_sort.
          lv_tabix2 = sy-tabix.
          "start of change by ashish 22OCT --
          "Contain string pattern should be validated with equal
          CONDENSE lwa_code-text.
          TRANSLATE lwa_code-text TO UPPER CASE.
          REFRESH lt_tab4[].
          SPLIT lwa_code-text AT space INTO TABLE lt_tab4[].
          " start by ashish: itab[] shoudn't be skiped.17th NOV
          LOOP AT lt_tab4 INTO lwa_tab4.
            IF lwa_tab4-text CS gc_bracket.
              REPLACE FIRST OCCURRENCE OF gc_bracket IN lwa_tab4-text
              WITH ''.
              CONDENSE lwa_tab4-text.
            ENDIF.
            IF lwa_tab4-text CS gc_dot.
              REPLACE FIRST OCCURRENCE OF gc_dot IN lwa_tab4-text WITH
              ''.
              CONDENSE lwa_tab4-text.
            ENDIF.
            MODIFY lt_tab4 FROM lwa_tab4 INDEX sy-tabix.

          ENDLOOP.
          " End by ashish: itab[] shoudn't be skiped. 17th NOV
          READ TABLE lt_tab4 INTO lwa_tab4 WITH KEY text =
          lwa_intab-intab.
          CHECK sy-subrc = 0.
          REFRESH lt_tab4[].
          "End of change by ashish 22OCT --
          "Contain string pattern should be validated with equal

          IF lwa_code-text = '' OR lwa_code-text+0(1) = gc_star OR
          lwa_code-text+0(1) = gc_doub_quote.
            CONTINUE.
          ENDIF.
*Concatenate full statement in a line
          sy-tabix = lv_tabix2.
          PERFORM get_line  USING p_code2
                                  sy-tabix
                            CHANGING lv_per1
                                     var_line.
          lwa_code = lv_per1.
          TRANSLATE lwa_code TO UPPER CASE.
          CLEAR : lv_per1 , var_line , var_line1 , var_line1.
          CONDENSE lwa_code.
          SPLIT lwa_code AT space INTO TABLE lt_tab.
          REPLACE ALL OCCURRENCES OF gc_dot IN TABLE lt_tab WITH ''.
          REPLACE ALL OCCURRENCES OF gc_open_bracket IN TABLE lt_tab
          WITH ''.
          REPLACE ALL OCCURRENCES OF gc_close_bracket IN TABLE lt_tab
          WITH ''.
          DELETE lt_tab WHERE text = ''.
          READ TABLE lt_tab INTO lv_per1 WITH KEY text = gc_by.
          var_line1 = sy-tabix + 1.
          DESCRIBE TABLE lt_tab LINES var_line.
          LOOP AT  lt_tab INTO lwa_tab1 FROM var_line1 TO var_line.
            lwa_wa_row-progname = gv_prog.
            lwa_wa_row-intab = lwa_intab-intab.
            lwa_wa_row-wa = lwa_intab-intab.
            lwa_wa_row-fieldname = lwa_tab1.
            APPEND lwa_wa_row TO lt_wa_row.
            CLEAR : lwa_tab1 , lwa_wa_row.
          ENDLOOP.
          CLEAR : lv_per1 , var_line , var_line1 .
        ENDLOOP.

********End of logic sort statement****By Atul 07oct2014

        CLEAR: lwa_code. "ashish18sep

* to check Perform statement for % calc
        READ TABLE lt_ini_tab2 INTO lwa_intab2 WITH KEY intab =
        lwa_intab-intab.
        IF lwa_intab2 IS INITIAL.
          LOOP AT p_code2 INTO lwa_code WHERE text CS lwa_intab-intab
          AND text
          CS gc_perform.
            "start of change by ashish 22OCT --
            "Contain string pattern should be validated with equal
            lv_tabix2 = sy-tabix.
            CONDENSE lwa_code-text.
            TRANSLATE lwa_code-text TO UPPER CASE.
            REFRESH lt_tab4[].
            SPLIT lwa_code-text AT space INTO TABLE lt_tab4[].
            " start by ashish: itab[] shoudn't be skiped.17th NOV
            LOOP AT lt_tab4 INTO lwa_tab4.
              IF lwa_tab4-text CS gc_bracket.
                REPLACE FIRST OCCURRENCE OF gc_bracket IN lwa_tab4-text
                WITH ''.
                CONDENSE lwa_tab4-text.
              ENDIF.
              IF lwa_tab4-text CS gc_dot.
                REPLACE FIRST OCCURRENCE OF gc_dot IN lwa_tab4-text
                WITH ''.
                CONDENSE lwa_tab4-text.
              ENDIF.
              MODIFY lt_tab4 FROM lwa_tab4 INDEX sy-tabix.

            ENDLOOP.
            " End by ashish: itab[] shoudn't be skiped. 17th NOV

            READ TABLE lt_tab4 INTO lwa_tab4 WITH KEY text =
            lwa_intab-intab.
            CHECK sy-subrc = 0.
            REFRESH lt_tab4[].
            "End of change by ashish 22OCT --
            "Contain string pattern should be validated with equal
            IF lwa_code-text = '' OR lwa_code-text+0(1) = gc_star OR
            lwa_code-text+0(1) = gc_doub_quote.
              CONTINUE.
            ENDIF.
*Concatenate full statement in a line
            sy-tabix = lv_tabix2.
            PERFORM get_line  USING p_code2
                                    sy-tabix
                              CHANGING lv_per1
                                       var_line.
            lwa_code = lv_per1.
            TRANSLATE lwa_code TO UPPER CASE.
            CLEAR : lv_per1 , var_line , var_line1.
            CONDENSE lwa_code.
            SPLIT lwa_code AT space INTO TABLE lt_tab.
            REPLACE ALL OCCURRENCES OF gc_dot IN TABLE lt_tab WITH ''.
            REPLACE ALL OCCURRENCES OF gc_open_bracket IN TABLE lt_tab
            WITH ''.
            REPLACE ALL OCCURRENCES OF gc_close_bracket IN TABLE lt_tab
            WITH ''.
            DELETE lt_tab WHERE text = ''.
            "   -- delete blank spaces from internal table ashish18sep
            READ TABLE lt_tab INTO lv_per1 WITH KEY text =
            lwa_intab-intab.
            CHECK lv_per1 IS NOT INITIAL.
            var_line1 = sy-tabix.
            CLEAR: lv_per1.
            READ TABLE lt_tab INTO lv_init_per INDEX 2.
            CONCATENATE gc_form lv_init_per INTO lv_init_per SEPARATED
            BY
            space.
            REPLACE ALL OCCURRENCES OF gc_dot IN lv_init_per WITH ''.
            CONDENSE lv_init_per.
            wa_progname = gv_prog.
            READ REPORT wa_progname INTO p_code3.
            LOOP AT p_code3 INTO lwa_code WHERE text CS lv_init_per.
              IF lwa_code-text = '' OR lwa_code-text+0(1) = gc_star OR
              lwa_code-text+0(1) = gc_doub_quote. "ashish18sep
                CONTINUE. "ashish18sep
              ENDIF. "ashish18sep
              PERFORM get_line  USING p_code3
                          sy-tabix
                    CHANGING lv_per1
                             var_line.
              lwa_code = lv_per1.
              CLEAR : lv_per1 , var_line.
              TRANSLATE lwa_code TO UPPER CASE.
              CONDENSE lwa_code-text."ashish18sep
              CHECK lwa_code-text+0(4) = gc_form.
              SPLIT lwa_code AT space INTO TABLE lt_tab_form.
              REPLACE ALL OCCURRENCES OF gc_dot IN TABLE lt_tab_form
              WITH
              ''.
              REPLACE ALL OCCURRENCES OF gc_open_bracket IN TABLE
              lt_tab_form WITH
              ''.
              REPLACE ALL OCCURRENCES OF gc_close_bracket IN TABLE
              lt_tab_form WITH
              ''.
              DELETE lt_tab_form WHERE text = ''.
              "   -- delete blank spaces from internal table ashish18sep
              LOOP AT lt_tab_form INTO lwa_tab_form WHERE text = 'LIKE'
              OR text =
              'TYPE' OR text = 'STRUCTURE'.
                CLEAR : var_line.
                var_line = sy-tabix + 1.
                IF var_line GE 1.
                  DELETE lt_tab_form INDEX var_line.
                ENDIF.
                IF sy-tabix GE 1.
                  DELETE lt_tab_form INDEX sy-tabix.
                ENDIF.
                CLEAR : var_line.
              ENDLOOP.
              READ TABLE lt_tab_form INTO lv_per2 INDEX var_line1.
              "start of changes by ashish: issue infinite loop in perform
              MOVE lwa_intab TO lwa_intab2.
              lwa_intab-progname = gv_prog.
              lwa_intab-fieldcount = lv_line.
              lwa_intab-intab = lv_per2.
              APPEND lwa_intab TO lt_ini_tab.
              lwa_intab2-progname = gv_prog.
              lwa_intab2-fieldcount = lv_line.
              lwa_intab2-intab = lv_per2.
              APPEND lwa_intab2 TO lt_ini_tab2.
              CLEAR:  lwa_intab2.
              " end of changes by ashish: issue infinite loop in perform
              CLEAR : lv_per1 , lv_per2.", lwa_intab.
            ENDLOOP.
          ENDLOOP.
        ENDIF.
      ELSE." ELSE FOR fm AND PROG CHECK rEALLY IMPORTANT
* to check computation and table assignment for % calc
*LOOP AT gt_progname INTO wa_progname.
        LOOP AT gt_progname1 INTO wa_progname.
          "changed by atul fr prog enteries
          READ REPORT wa_progname-progname INTO p_code2.
          CHECK sy-subrc = 0.
          CLEAR lv_tabix2.
          LOOP AT p_code2 INTO lwa_code WHERE text CS  lv_init_cn1 AND
          text NS
          gc_where.    " = assignment between internal tables
            "start of change by ashish 22OCT --
            "Contain string pattern should be validated with equal
            lv_tabix2 = sy-tabix.
            CONDENSE lwa_code-text.
            TRANSLATE lwa_code-text TO UPPER CASE.
            REFRESH lt_tab4[].
            SPLIT lwa_code-text AT space INTO TABLE lt_tab4[].
            " start by ashish: itab[] shoudn't be skiped.17th NOV
            " start by ashish: itab[] shoudn't be skiped.17th NOV
            LOOP AT lt_tab4 INTO lwa_tab4.
              IF lwa_tab4-text CS gc_bracket.
                REPLACE FIRST OCCURRENCE OF gc_bracket IN lwa_tab4-text
                WITH ''.
                CONDENSE lwa_tab4-text.
              ENDIF.
              IF lwa_tab4-text CS gc_dot.
                REPLACE FIRST OCCURRENCE OF gc_dot IN lwa_tab4-text
                WITH ''.
                CONDENSE lwa_tab4-text.
              ENDIF.
              MODIFY lt_tab4 FROM lwa_tab4 INDEX sy-tabix.

            ENDLOOP.
            " End by ashish: itab[] shoudn't be skiped. 17th NOV

            READ TABLE lt_tab4 INTO lwa_tab4 WITH KEY text =
            lwa_intab-intab.
            CHECK sy-subrc = 0.
            REFRESH lt_tab4[].
            "End of change by ashish 22OCT --
            "Contain string pattern should be validated with equal
            "start: ashish17sep code to segregate method and
            "CALL function from internal table assigment
            IF lwa_code-text = '' OR lwa_code-text+0(1) = gc_star OR
            lwa_code-text+0(1) = gc_doub_quote OR lwa_code-text CS '->'
            OR
            lwa_code-text CS '=>'..
              IF lwa_code-text CS '->' OR  lwa_code-text CS '=>'.
                lv_insuff = gc_x.
              ENDIF.
              "ashish17sep code to segregate method and
              "CALL function from internal table assigment
              CONTINUE.
              "End: ashish17sep code to segregate method and
              "CALL function from internal table assigment
            ENDIF.
*Concatenate full statement in a line
            sy-tabix = lv_tabix2.
            PERFORM get_line  USING p_code2
                                    sy-tabix
                              CHANGING lv_per1
                                       var_line.
            lwa_code = lv_per1.
            TRANSLATE lwa_code TO UPPER CASE.
            CLEAR : lv_per1 , var_line.
            CONDENSE lwa_code-text.
            CHECK lwa_code-text CS lv_init_cn1.
            "start of change by ashish 09 OCT  --- should check EQ not CS
            CLEAR: lv_str33, lv_str2.
            SPLIT lwa_code-text AT lv_init_cn1 INTO lv_str33 lv_str2.
            REPLACE FIRST OCCURRENCE OF gc_bracket IN lv_str2 WITH ''.
            CLEAR:   lv_char1.
            lv_char1 = lv_str2.
            IF  lv_char1+0(1) = ''  OR lv_char1+0(1) = gc_dot
               OR lv_char1+0(1) = '-'.
              "end of change by ashish 09 OCT  --- should check EQ not CS
              "Begin : ashish17sep code to segregate method and
              "CALL function from internal table assigment
              CLEAR: lv_cc.
              CLEAR: lv_str33,  var_count2 ,  var_count, lwa_code2 ,
              lv_str2,
              lv_index2.
              CONCATENATE lv_sq lv_dq INTO lv_cc.
              CONDENSE lv_cc.

              lv_str33 = lwa_code-text.
              lv_index2 = sy-tabix.
              CLEAR: lv_index22.
              lv_index22 = lv_index2.
              WHILE ( 1 = 1 ) .
                READ TABLE p_code2 INTO lwa_code2 INDEX lv_index2.
*                lv_index2 = lv_index2 - 1.
                CONDENSE lwa_code2-text.
                TRANSLATE lwa_code2 TO UPPER CASE.
                IF lwa_code2 CS gc_doub_quote AND lwa_code2 NS lv_cc.
                  SPLIT lwa_code2 AT gc_doub_quote INTO lwa_code2
                  lv_str33.
                  CLEAR lv_str33.
                ENDIF.

                IF lwa_code2+0(1) EQ gc_doub_quote OR  lwa_code2+0(1) =
                gc_star
                  OR lwa_code2 IS INITIAL.
                  lv_index2 = lv_index2 - 1.
                  CONTINUE.
                ENDIF.

                var_count = strlen( lwa_code2-text ).
                var_count2 = var_count - 1.

                IF lv_index22 > lv_index2.
                  IF lwa_code2-text+var_count2(var_count) = gc_dot OR
                  lv_index2 < 0.

                    EXIT.
                  ENDIF.

                  CONCATENATE lwa_code2  lv_str33
                                  INTO lv_str33 SEPARATED BY space.
                ENDIF.
                lv_index2 = lv_index2 - 1.
              ENDWHILE.
              CONDENSE lv_str33.
              " neglect select from assignment
              CLEAR: lv_str34, lv_str35.
              SPLIT lv_str33 AT space INTO lv_str34 lv_str35.
              CONDENSE lv_str34.
              CHECK lv_str34 NS gc_select.


              IF lv_str33 CS gc_call_func OR
                 lv_str33 CS gc_call_meth OR lv_str33 CS '=>'.
                lv_insuff = gc_x.
              ENDIF.


              CHECK lv_str33 NS gc_call_func AND
                    lv_str33 NS gc_call_meth AND
                    lv_str33 NS '=>'.
              CLEAR: lv_str33,  var_count2 ,  var_count, lwa_code2 ,
              lv_str2,
              lv_index2.
              "End: ashish17sep code to segregate method and CALL function from
              "internal table assigment
              SPLIT lwa_code AT space INTO TABLE lt_tab.
              CHECK lt_tab IS NOT INITIAL.
              CLEAR: lwa_intab1.
              READ TABLE lt_tab INTO lwa_intab1-intab INDEX 1.
              "start of change by ashish on 09 OCT :replace field not structure
*          replace all occurrences of '.' in lwa_intab1 with ''.
*          replace all occurrences of '[]' in lwa_intab1 with ''.

              REPLACE ALL OCCURRENCES OF gc_dot IN lwa_intab1-intab
              WITH '' .
              REPLACE ALL OCCURRENCES OF gc_bracket IN lwa_intab1-intab
              WITH ''.

              "end of change by ashish on 09 OCT :replace field not structure
*      DESCRIBE TABLE lwa_intab-intab lines lv_line.
              lwa_intab1-progname = gv_prog.
              lwa_intab1-fieldcount = lv_line.
              lwa_intab1-table  =  lwa_intab-table.
              lwa_intab1-intab = lwa_intab1-intab.
              lwa_intab1-line = lwa_intab-line.
              lwa_intab1-fieldcount = lwa_intab-fieldcount.
              APPEND lwa_intab1 TO lt_ini_tab.
              CLEAR : lt_tab, lwa_intab1. " lwa_intab.
            ENDIF."   oct 18 ashish
          ENDLOOP.
*    ENDLOOP.
          CLEAR: lwa_code. "ashish18sep
********Logic for sort statement*******By Atul 07oct2014
          LOOP AT p_code2 INTO lwa_code
             WHERE text CS lwa_intab-intab
               AND text CS gc_sort.
            lv_tabix2 = sy-tabix.
            "start of change by ashish 22OCT -- Contain string pattern should be
            "validated with equal
            CONDENSE lwa_code-text.
            TRANSLATE lwa_code-text TO UPPER CASE.
            REFRESH lt_tab4[].
            SPLIT lwa_code-text AT space INTO TABLE lt_tab4[].
            " start by ashish: itab[] shoudn't be skiped.17th NOV
            LOOP AT lt_tab4 INTO lwa_tab4.
              IF lwa_tab4-text CS gc_bracket.
                REPLACE FIRST OCCURRENCE OF gc_bracket IN lwa_tab4-text
                WITH
                ''.
                CONDENSE lwa_tab4-text.
              ENDIF.
              IF lwa_tab4-text CS gc_dot.
                REPLACE FIRST OCCURRENCE OF gc_dot IN lwa_tab4-text WITH
                ''
                .
                CONDENSE lwa_tab4-text.
              ENDIF.
              MODIFY lt_tab4 FROM lwa_tab4 INDEX sy-tabix.

            ENDLOOP.
            " End by ashish: itab[] shoudn't be skiped. 17th NOV
            READ TABLE lt_tab4 INTO lwa_tab4 WITH KEY text =
            lwa_intab-intab.
            CHECK sy-subrc = 0.
            REFRESH lt_tab4[].
            "End of change by ashish 22OCT -- Contain string pattern should be
            "validated with equal
            IF lwa_code-text = '' OR lwa_code-text+0(1) = gc_star OR
            lwa_code-text+0(1) = gc_doub_quote.
              CONTINUE.
            ENDIF.
*Concatenate full statement in a line
            sy-tabix = lv_tabix2.
            PERFORM get_line  USING p_code2
                                    sy-tabix
                              CHANGING lv_per1
                                       var_line.
            lwa_code = lv_per1.
            TRANSLATE lwa_code TO UPPER CASE.
            CLEAR : lv_per1 , var_line , var_line1 , var_line1.
            CONDENSE lwa_code.
            SPLIT lwa_code AT space INTO TABLE lt_tab.
            REPLACE ALL OCCURRENCES OF gc_dot IN TABLE lt_tab WITH ''.
            REPLACE ALL OCCURRENCES OF gc_open_bracket IN TABLE lt_tab
            WITH ''.
            REPLACE ALL OCCURRENCES OF gc_close_bracket IN TABLE lt_tab
            WITH ''.
            DELETE lt_tab WHERE text = ''.
            READ TABLE lt_tab INTO lv_per1 WITH KEY text = gc_by.
            var_line1 = sy-tabix + 1.
            DESCRIBE TABLE lt_tab LINES var_line.
            LOOP AT  lt_tab INTO lwa_tab1 FROM var_line1 TO var_line.
              lwa_wa_row-progname = gv_prog.
              lwa_wa_row-intab = lwa_intab-intab.
              lwa_wa_row-wa = lwa_intab-intab.
              lwa_wa_row-fieldname = lwa_tab1.
              APPEND lwa_wa_row TO lt_wa_row.
              CLEAR : lwa_tab1 , lwa_wa_row.
            ENDLOOP.
            CLEAR : lv_per1 , var_line , var_line1 .
          ENDLOOP.
********End of logic sort statement****By Atul 07oct2014
          CLEAR: lwa_code. "ashish18sep

* For All Enteries % calc
          LOOP AT p_code2 INTO lwa_code
              WHERE text CS lwa_intab-intab
                AND text CS 'FOR ALL ENTERIES'.   " for all entries
            lv_init = gc_x.
          ENDLOOP.
          CLEAR: lwa_code. "ashish18sep
*to check move for % calc
          LOOP AT p_code2 INTO lwa_code
                WHERE text CS lwa_intab-intab
                  AND text CS gc_move.
            "start of change by ashish 22OCT -- Contain string pattern should be
            "validated with equal
            lv_tabix2 = sy-tabix.
            CONDENSE lwa_code-text.
            TRANSLATE lwa_code-text TO UPPER CASE.
            REFRESH lt_tab4[].
            SPLIT lwa_code-text AT space INTO TABLE lt_tab4[].
            " start by ashish: itab[] shoudn't be skiped.17th NOV
            LOOP AT lt_tab4 INTO lwa_tab4.
              IF lwa_tab4-text CS gc_bracket.
                REPLACE FIRST OCCURRENCE OF gc_bracket IN lwa_tab4-text
                WITH
                ''.
                CONDENSE lwa_tab4-text.
              ENDIF.
              IF lwa_tab4-text CS gc_dot.
                REPLACE FIRST OCCURRENCE OF gc_dot IN lwa_tab4-text WITH
                ''
                .
                CONDENSE lwa_tab4-text.
              ENDIF.
              MODIFY lt_tab4 FROM lwa_tab4 INDEX sy-tabix.

            ENDLOOP.
            " End by ashish: itab[] shoudn't be skiped. 17th NOV
            READ TABLE lt_tab4 INTO lwa_tab4 WITH KEY text =
            lwa_intab-intab.
            CHECK sy-subrc = 0.
            REFRESH lt_tab4[].
            IF lwa_code-text = '' OR lwa_code-text+0(1) = gc_star OR
             lwa_code-text+0(1) = gc_doub_quote.
              CONTINUE.
            ENDIF.
            "End of change by ashish 22OCT -- Contain string pattern should be
            "validated with equal
*Concatenate full statement in a line
            sy-tabix =  lv_tabix2.
            PERFORM get_line  USING p_code2
                                sy-tabix
                          CHANGING lv_per1
                                   var_line.
            lwa_code-text = lv_per1.
            CLEAR : var_line , lt_tab.
            TRANSLATE lwa_code-text TO  UPPER CASE.
            REPLACE ALL OCCURRENCES OF gc_colon IN lwa_code-text WITH
            space.
            REPLACE ALL OCCURRENCES OF gc_comma IN lwa_code-text WITH
            space.
            CONDENSE lwa_code-text.
            SPLIT lwa_code-text AT space INTO TABLE lt_tab.
            DELETE lt_tab WHERE text = ''.
            DELETE lt_tab WHERE text = gc_dot.
            LOOP AT lt_tab INTO lwa_tab WHERE text = gc_to.
              var_line = sy-tabix - 1.
              var_line1 = sy-tabix + 1.
              READ TABLE lt_tab INTO lwa_intab1-intab INDEX var_line1.
              IF lwa_intab1-intab+0(1) = ''''.
                CLEAR : lwa_intab1-intab.
              ENDIF.
              SPLIT lwa_intab1-intab AT '-' INTO lwa_intab1-intab
              lv_per1.  " split at - needed
              CONDENSE lwa_intab1-intab.
              CLEAR : lv_per1.
              REPLACE ALL OCCURRENCES OF gc_dot IN lwa_intab1-intab WITH
              ''
              .
              REPLACE ALL OCCURRENCES OF gc_bracket IN lwa_intab1-intab
              WITH
              ''.
              CONDENSE lwa_intab1-intab.
              IF lwa_intab1-intab IS NOT INITIAL.
                lwa_intab1-progname = gv_prog.
                lwa_intab1-fieldcount = lv_line.
                lwa_intab1-table  =  lwa_intab-table.
                lwa_intab1-intab = lwa_intab1-intab.
                lwa_intab1-line = lwa_intab-line.
                lwa_intab1-fieldcount = lwa_intab-fieldcount.
                APPEND lwa_intab1 TO lt_ini_tab.
                CLEAR : lwa_intab1.
                CLEAR : var_line , var_line1 .
              ENDIF.
              " start - not needed -repeated - ashish 10 OCT
*            READ TABLE lt_tab INTO lwa_intab1-intab INDEX var_line1.
*            IF lwa_intab1-intab+0(1) = ''''.
*              CLEAR : lwa_intab1-intab.
*            ENDIF.
*SPLIT lwa_intab1-intab AT '-' INTO lwa_intab1-intab lv_per1.
*            CONDENSE lwa_intab1-intab.
*            CLEAR : lv_per1.
*            REPLACE ALL OCCURRENCES OF '.' IN lwa_intab1 WITH ''.
*            REPLACE ALL OCCURRENCES OF '[]' IN lwa_intab1 WITH ''.
*            CONDENSE lwa_intab1-intab.
*            CHECK lwa_intab1-intab IS NOT INITIAL.
*            lwa_intab1-progname = gv_prog.
*            lwa_intab1-fieldcount = lv_line.
*            lwa_intab1-table  =  lwa_intab-table.
*            lwa_intab1-intab = lwa_intab1-intab.
*            lwa_intab1-line = lwa_intab-line.
*            lwa_intab1-fieldcount = lwa_intab-fieldcount.
*            APPEND lwa_intab1 TO lt_ini_tab.
*            CLEAR : lt_tab, lwa_intab1 . " lwa_intab.
*            CLEAR : var_line , var_line1 .
              " end - not needed - ashish
            ENDLOOP.
          ENDLOOP.

          CLEAR: lwa_code. "ashish18sep

*** code fr read Logic***
*
          LOOP AT p_code2 INTO lwa_code
              WHERE text CS lwa_intab-intab
                AND text CS gc_read. " READ
            "start of change by ashish 22OCT -- Contain string pattern should be
            "validated with equal
            lv_tabix2 =  sy-tabix.
            CONDENSE lwa_code-text.
            TRANSLATE lwa_code-text TO UPPER CASE.
            REFRESH lt_tab4[].
            SPLIT lwa_code-text AT space INTO TABLE lt_tab4[].
            " start by ashish: itab[] shoudn't be skiped.17th NOV
            LOOP AT lt_tab4 INTO lwa_tab4.
              IF lwa_tab4-text CS gc_bracket.
                REPLACE FIRST OCCURRENCE OF gc_bracket IN lwa_tab4-text
                WITH
                ''.
                CONDENSE lwa_tab4-text.
              ENDIF.
              IF lwa_tab4-text CS gc_dot.
                REPLACE FIRST OCCURRENCE OF gc_dot IN lwa_tab4-text WITH
                ''
                .
                CONDENSE lwa_tab4-text.
              ENDIF.
              MODIFY lt_tab4 FROM lwa_tab4 INDEX sy-tabix.

            ENDLOOP.
            " End by ashish: itab[] shoudn't be skiped. 17th NOV
            READ TABLE lt_tab4 INTO lwa_tab4 WITH KEY text =
            lwa_intab-intab.
            CHECK sy-subrc = 0.
            REFRESH lt_tab4[].
            "End of change by ashish 22OCT -- Contain string pattern should be
            "validated with equal

            CONDENSE lwa_code-text.
            IF lwa_code-text = '' OR lwa_code-text+0(1) = gc_star OR
            lwa_code-text+0(1) = gc_doub_quote.
              CONTINUE.
            ENDIF.

*Concatenate full statement in a line
            sy-tabix =  lv_tabix2.
            PERFORM get_line USING p_code2
            sy-tabix
            CHANGING lv_per1
            var_line.
            lwa_code = lv_per1.
            CONDENSE: lwa_code-text.
            CLEAR: lv_str34, lv_str35, lwa_tab1.
            SPLIT lwa_code-text AT space INTO lv_str34 lv_str35.
            IF lv_str34 CS gc_read AND lv_str34 CS gc_into.
              " added by ashish on 09 Oct
              SPLIT lv_str35 AT space INTO lv_str34 lv_str35.
              IF lv_str34 CS gc_table.
                REFRESH lt_tab[].
                SPLIT lwa_code AT ' ' INTO TABLE lt_tab.
                DELETE lt_tab WHERE text = ''.
                DELETE lt_tab WHERE text = gc_dot.
                READ TABLE lt_tab INTO lwa_tab1 INDEX 5.
                REPLACE FIRST OCCURRENCE OF gc_dot IN lwa_tab1 WITH
                space.
                REPLACE FIRST OCCURRENCE OF gc_comma IN lwa_tab1 WITH
                space.
                CONDENSE lwa_tab1.
                lwa_intab1-progname = gv_prog.
                lwa_intab1-intab = lwa_tab1.
* lwa_intab1-wa = pwa_code.
                lwa_intab1-table = lwa_intab-table.
                lwa_intab1-fieldcount = lv_line.
                lwa_intab1-line = lwa_intab-line.
*APPEND lwa_wa TO lt_wa.
                APPEND lwa_intab1 TO lt_ini_tab.
                CLEAR : lt_tab, lwa_intab1 .
              ENDIF.
            ENDIF.
          ENDLOOP .

          CLEAR: lwa_code.
****end code for read ogic***


*start of changes by ashish 24sep - commented write and unpack till
*further discussion
** To check write statement for % calc
*LOOP AT p_code2 INTO lwa_code WHERE text CS lwa_intab-intab AND text CS
*'WRITE'.
**Concatenate full statement in a line
*    PERFORM get_line  USING p_code2
*                            sy-tabix
*                      CHANGING lv_per1
*                               var_line.
*       lwa_code = lv_per1.
*       TRANSLATE lwa_code to UPPER CASE.
*       CLEAR : lv_per1 , var_line.
*       CONDENSE lwa_code.
*      SPLIT lwa_code AT 'TO' INTO TABLE lt_tab.
*      READ TABLE lt_tab INTO lwa_intab-intab INDEX 4.
*      REPLACE ALL OCCURRENCES OF '.' IN lwa_intab WITH ''.
**      DESCRIBE TABLE lwa_intab-intab lines lv_line.
*      lwa_intab-progname = gv_prog.
*      lwa_intab-fieldcount = lv_line.
*      REPLACE ALL OCCURRENCES OF '.' IN lwa_intab WITH ''.
*      CONDENSE lwa_intab1-intab.
*      APPEND lwa_intab TO lt_ini_tab.
*      CLEAR : lt_tab. " lwa_intab.
*    ENDLOOP.
*    clear: lwa_code. "ashish18sep
** to check unpack statement for % calc
*LOOP AT p_code2 INTO lwa_code WHERE text CS lwa_intab-intab AND text CS
*'UNPACK'.
**Concatenate full statement in a line
*    PERFORM get_line  USING p_code2
*                            sy-tabix
*                      CHANGING lv_per1
*                               var_line.
*       lwa_code = lv_per1.
*       TRANSLATE lwa_code to UPPER CASE.
*       CLEAR : lv_per1 , var_line.
*       CONDENSE lwa_code.
*      SPLIT lwa_code AT 'TO' INTO TABLE lt_tab.
*      READ TABLE lt_tab INTO lwa_intab INDEX 4.
*      REPLACE ALL OCCURRENCES OF '.' IN lwa_intab-intab WITH ''.
**        DESCRIBE TABLE lwa_intab-intab lines lv_line.
*      CONDENSE lwa_intab1-intab.
*      lwa_intab-progname = gv_prog.
*      lwa_intab-fieldcount = lv_line.
*      APPEND lwa_intab TO lt_ini_tab.
*      CLEAR : lt_tab .", lwa_intab.
*    ENDLOOP.
*end of changes by ashish 24sep - commented write and unpack till
*further discussion
          CLEAR: lwa_code. "ashish18sep

* to check Perform statement for % calc
          READ TABLE lt_ini_tab2 INTO lwa_intab2
                  WITH KEY intab = lwa_intab-intab.
          IF lwa_intab2 IS INITIAL.

            LOOP AT p_code2 INTO lwa_code
                      WHERE text CS lwa_intab-intab
                        AND text CS gc_perform.
              lv_tabix2 = sy-tabix.
              TRANSLATE  lwa_code-text TO UPPER CASE.
              "start of change by ashish 22OCT -- Contain string pattern should be
              "validated with equal
              CONDENSE lwa_code-text.
              REFRESH lt_tab4[].
              SPLIT lwa_code-text AT space INTO TABLE lt_tab4[].
              " start by ashish: itab[] shoudn't be skiped.17th NOV
              LOOP AT lt_tab4 INTO lwa_tab4.
                IF lwa_tab4-text CS gc_bracket.
                  REPLACE FIRST OCCURRENCE OF gc_bracket IN
                  lwa_tab4-text WITH
                  ''.
                  CONDENSE lwa_tab4-text.
                ENDIF.
                IF lwa_tab4-text CS gc_dot.
                  REPLACE FIRST OCCURRENCE OF gc_dot IN lwa_tab4-text
                  WITH
                  ''.
                  CONDENSE lwa_tab4-text.
                ENDIF.
                MODIFY lt_tab4 FROM lwa_tab4 INDEX sy-tabix.

              ENDLOOP.
              " End by ashish: itab[] shoudn't be skiped. 17th NOV

              READ TABLE lt_tab4 INTO lwa_tab4
                        WITH KEY text = lwa_intab-intab.
              CHECK sy-subrc = 0.
              REFRESH lt_tab4[].
              "End of change by ashish 22OCT -- Contain string pattern should be
              "validated with equal
              IF lwa_code-text = '' OR lwa_code-text+0(1) = gc_star OR
              lwa_code-text+0(1) = gc_doub_quote.
                CONTINUE.
              ENDIF.
*Concatenate full statement in a line
              sy-tabix = lv_tabix2.
              PERFORM get_line  USING p_code2
                                      sy-tabix
                                CHANGING lv_per1
                                         var_line.
              lwa_code = lv_per1.
              TRANSLATE lwa_code TO UPPER CASE.
              CLEAR : lv_per1 , var_line , var_line1.
              CONDENSE lwa_code.
              SPLIT lwa_code AT space INTO TABLE lt_tab.
              REPLACE ALL OCCURRENCES OF gc_dot IN TABLE lt_tab WITH ''.
              REPLACE ALL OCCURRENCES OF gc_open_bracket IN TABLE lt_tab
              WITH ''.
              REPLACE ALL OCCURRENCES OF gc_close_bracket IN TABLE
              lt_tab WITH ''.
              DELETE lt_tab WHERE text = ''.
              "   -- delete blank spaces from internal table ashish18sep
              READ TABLE lt_tab INTO lv_per1
                          WITH KEY text = lwa_intab-intab.
              CHECK lv_per1 IS NOT INITIAL.
              var_line1 = sy-tabix.
              CLEAR: lv_per1.
              READ TABLE lt_tab INTO lv_init_per INDEX 2.
              CONCATENATE gc_form lv_init_per
               INTO lv_init_per SEPARATED BY space.
              REPLACE ALL OCCURRENCES OF gc_dot IN lv_init_per WITH ''.
              CONDENSE lv_init_per.
              LOOP AT gt_progname1 INTO wa_progname.
                READ REPORT wa_progname INTO p_code3.
                LOOP AT p_code3 INTO lwa_code WHERE text CS lv_init_per.
                  IF lwa_code-text = '' OR lwa_code-text+0(1) = gc_star
                  OR
                  lwa_code-text+0(1) = gc_doub_quote. "ashish18sep
                    CONTINUE. "ashish18sep
                  ENDIF. "ashish18sep
                  PERFORM get_line  USING p_code3
                              sy-tabix
                        CHANGING lv_per1
                                 var_line.
                  lwa_code = lv_per1.
                  CLEAR : lv_per1 , var_line.
                  TRANSLATE lwa_code TO UPPER CASE.
                  CONDENSE lwa_code-text."ashish18sep
                  CHECK lwa_code-text+0(4) = gc_form.
                  SPLIT lwa_code AT space INTO TABLE lt_tab_form.
                  REPLACE ALL OCCURRENCES OF gc_dot IN TABLE lt_tab_form
                  WITH ''.
                  REPLACE ALL OCCURRENCES OF gc_open_bracket IN TABLE
                  lt_tab_form
                  WITH ''.
                  REPLACE ALL OCCURRENCES OF gc_close_bracket IN TABLE
                  lt_tab_form
                  WITH ''.
                  DELETE lt_tab_form WHERE text = ''.
                  "-- delete blank spaces from internal table ashish18sep
                  LOOP AT lt_tab_form INTO lwa_tab_form
                    WHERE text = 'LIKE' OR text = 'TYPE'
                     OR text = 'STRUCTURE'.
                    CLEAR : var_line.
                    var_line = sy-tabix + 1.
                    IF var_line GE 1.
                      DELETE lt_tab_form INDEX var_line.
                    ENDIF.
                    IF sy-tabix GE 1.
                      DELETE lt_tab_form INDEX sy-tabix.
                    ENDIF.
                    CLEAR : var_line.
                  ENDLOOP.
                  READ TABLE lt_tab_form INTO lv_per2 INDEX var_line1.
                  "start of changes by ashish: issue infinite loop in perform
                  MOVE lwa_intab TO lwa_intab2.
                  lwa_intab-progname = gv_prog.
                  lwa_intab-fieldcount = lv_line.
                  lwa_intab-intab = lv_per2.
                  APPEND lwa_intab TO lt_ini_tab.
                  lwa_intab2-progname = gv_prog.
                  lwa_intab2-fieldcount = lv_line.
                  lwa_intab2-intab = lv_per2.
                  APPEND lwa_intab2 TO lt_ini_tab2.
                  CLEAR:  lwa_intab2.
                  "end of changes by ashish: issue infinite loop in perform
                  CLEAR : lv_per1 , lv_per2.", lwa_intab.
                ENDLOOP.
              ENDLOOP.
            ENDLOOP.
          ENDIF.

        ENDLOOP.
      ENDIF."for Function modules
*to insert newly found internal tables linked to initial found internal
*found table
      IF lt_ini_tab IS NOT INITIAL.
        " start of changes by ashish: infinite loop 19sep
*INSERT LINES OF lt_ini_tab INTO TABLE lt_intab." ACCEPTING DUPLICATE
*KEYS.
*      SORT lt_intab.  " need to be decommented.-ashish sep19
*      DELETE ADJACENT DUPLICATES FROM lt_intab COMPARING ALL FIELDS.
*      CLEAR : lt_ini_tab.
*      REFRESH lt_ini_tab[]. "ashish sep19
*
        SORT lt_ini_tab BY progname table intab line.
        DELETE ADJACENT DUPLICATES FROM lt_ini_tab  COMPARING progname
        table intab line.
        DELETE lt_ini_tab WHERE intab CS '<'.  " on 11 Oct - ashish

        LOOP AT lt_ini_tab INTO lwa_intab1.
          CLEAR: lwa_intab2.
          READ TABLE lt_intab INTO lwa_intab2
            WITH KEY intab = lwa_intab1-intab.
          IF lwa_intab2 IS INITIAL.
            APPEND lwa_intab1 TO  lt_intab .
          ENDIF.
        ENDLOOP.
*             CLEAR : lt_ini_tab.
        REFRESH lt_ini_tab[]. "ashish sep19
        " end of changes by ashish: infinite loop 19sep
      ENDIF.
      CLEAR: lt_tab, pwa_code.

      LOOP AT p_code2 INTO lwa_code WHERE text CS lwa_intab-intab.
        IF lwa_code-text = '' OR lwa_code-text+0(1) = gc_star OR
        lwa_code-text+0(1) = gc_doub_quote.
          CONTINUE.
        ENDIF.

* to find wrokarea attached to found internal tables for % calc
        CONDENSE lwa_code.
        TRANSLATE lwa_code TO UPPER CASE.
        IF lwa_code-text CS gc_loop_at.
          SPLIT lwa_code-text AT ' ' INTO TABLE lt_tab.
          READ TABLE lt_tab INTO pwa_code INDEX 5.
          IF sy-subrc IS INITIAL.
            REPLACE FIRST OCCURRENCE OF gc_dot IN pwa_code WITH ' '.
            CONDENSE pwa_code.
            lwa_wa-progname = gv_prog.
            lwa_wa-intab = lwa_intab-intab.
            lwa_wa-wa  = pwa_code.
            APPEND lwa_wa TO lt_wa.
          ENDIF.
        ENDIF.
        CLEAR: lwa_wa.
      ENDLOOP.
    ENDLOOP.
    CLEAR : wa_progname.
    REFRESH : p_code2.

    IF lt_wa IS NOT  INITIAL.
      SORT lt_wa BY progname intab wa.
      DELETE ADJACENT DUPLICATES FROM lt_wa COMPARING ALL FIELDS.
    ENDIF.
*begin of changes by atul
    DATA : lwa_str_fm TYPE STANDARD TABLE OF ty_scan.
    DATA : lwa_str_fm_f TYPE STANDARD TABLE OF ty_scan.
    DATA : wa_str_fm_f TYPE ty_scan.

*start of change by ashish on 10 OCT -- in case of FUGR  include being
*scanned should be in the gt_progname1
    IF gv_prog+0(2) = gc_lz OR gv_prog+0(2) = gc_ly.
      wa_progname-progname = gv_prog.
      APPEND wa_progname TO gt_progname1.
    ENDIF.
    CLEAR: wa_progname-progname.
*end of change by ashish on 10 OCT -- in case of FUGR  include being
*scanned should be in the gt_progname1

    LOOP AT lt_wa INTO lwa_wa.
      LOOP AT gt_progname1 INTO wa_progname.
        " start: replace FM with Form
*        CALL FUNCTION 'ZAUCT_FIND_STR'
*          EXPORTING
**    p_name             = gv_prog
*            p_name             = wa_progname-progname
*            code_string        = lwa_wa-wa
**    start_line         =
*            line_no            = p_index
*            p_type             = 'A'
** IMPORTING
**   LV_NOT_FOUND       =
*          TABLES
*            it_fcode           =  lwa_str_fm
        gv_nt_found = ''.
        PERFORM get_scan TABLES lwa_str_fm
                         USING wa_progname-progname
                                lwa_wa-wa gc_zero p_index gc_a ''
                         CHANGING gv_nt_found.

* end Fm with form                  .
*insert lines of lwa_str_fm into lwa_str_fm_f.
        APPEND LINES OF  lwa_str_fm TO lwa_str_fm_f.
        CLEAR : wa_progname.
      ENDLOOP.
      CLEAR : lwa_wa.
      CLEAR : lwa_str_fm.
    ENDLOOP.
*end of changes by atul

    LOOP AT lt_wa INTO lwa_wa.
      CLEAR lt_tab.
      CONDENSE lwa_wa-wa.
      CONCATENATE lwa_wa-wa '-' INTO lv_wa.
      LOOP AT lwa_str_fm_f INTO wa_str_fm_f WHERE code CS lv_wa.
        "chaged by atul for % calc
        CONDENSE  wa_str_fm_f-code.
        REPLACE ALL  OCCURRENCES OF gc_comma IN wa_str_fm_f-code WITH
        space.
        "ashish sep24 - inorder to take care of statement which are only seprat
        "ed by ,
        SPLIT wa_str_fm_f-code AT space INTO TABLE lt_tab.
        "chaged by atul for % calc
        "ashish sep24 - inorder to take care of statement which are only seprat
        "ed by ,
        DELETE lt_tab WHERE text = ''.
        LOOP AT lt_tab INTO lwa_tab.
          IF lwa_tab CS lv_wa.
            CONDENSE lwa_tab.
            SPLIT lwa_tab AT '-' INTO TABLE lt_tab1.
            READ TABLE lt_tab1 INTO lwa_tab1 INDEX 1.
            IF sy-subrc IS INITIAL.
              lwa_wa_row-progname = gv_prog.
              lwa_wa_row-intab = lwa_wa-intab.
              lwa_wa_row-wa = lwa_tab1.
              CONDENSE: lwa_tab1, lwa_wa-wa.
              TRANSLATE lwa_tab1 TO UPPER CASE.
              TRANSLATE lwa_wa-wa TO UPPER CASE.
              CHECK lwa_tab1 = lwa_wa-wa.
              READ TABLE lt_tab1 INTO lwa_tab1 INDEX 2.
              IF sy-subrc IS INITIAL.
                REPLACE FIRST OCCURRENCE OF gc_dot IN lwa_tab1 WITH
                space.
                REPLACE FIRST OCCURRENCE OF gc_comma IN lwa_tab1 WITH
                space.
                "start of change by ashish 09 oct -- field coming with garbage
                "suffix/prefix
                REPLACE FIRST OCCURRENCE OF gc_close_bracket IN lwa_tab1
                WITH space.
                REPLACE FIRST OCCURRENCE OF gc_open_bracket IN lwa_tab1
                WITH space.
                REPLACE FIRST OCCURRENCE OF gc_bracket IN lwa_tab1 WITH
                space.
                "start of change by ashish 09 oct -- field coming with garbage
                "suffix/prefix
                CONDENSE lwa_tab1.
                lwa_wa_row-fieldname = lwa_tab1.
                CHECK lwa_wa_row-fieldname NS '<'.
                CHECK lwa_wa_row-fieldname NS '>'.
                APPEND lwa_wa_row TO lt_wa_row.
              ENDIF.
            ENDIF.
          ENDIF.
          CLEAR: wa_str_fm_f , lwa_wa_row."chaged by atul for % calc
        ENDLOOP.
      ENDLOOP.
    ENDLOOP.
*begin of changes by atul 25092014
    DATA : lt_str_fm TYPE STANDARD TABLE OF ty_scan.
    DATA : lt_str_fm_f TYPE STANDARD TABLE OF ty_scan.
    DATA : wa_str_fm_f_tb TYPE ty_scan.
    DATA : lv_code_string TYPE string.
    LOOP AT lt_intab INTO lwa_intab.
      lv_code_string = lwa_intab-intab.
      LOOP AT gt_progname1 INTO wa_progname.
*start: replace fm with form
*        CALL FUNCTION 'ZAUCT_FIND_STR'
*          EXPORTING
**    p_name             = gv_prog
*            p_name             = wa_progname-progname
*            code_string        = lv_code_string
**    start_line         =
*            line_no            = p_index
*            p_type             = 'A'
** IMPORTING
**   LV_NOT_FOUND       =
*          TABLES
*            it_fcode           =  lt_str_fm
        gv_nt_found = ''.
        PERFORM get_scan TABLES lt_str_fm
                      USING wa_progname-progname
                             lv_code_string gc_zero p_index gc_a ''
                      CHANGING gv_nt_found.

* end : Replace FM with form                  .
*insert lines of lt_str_fm into lt_str_fm_f.
        APPEND LINES OF lt_str_fm TO lt_str_fm_f.
        CLEAR : lt_str_fm .",lv_code_string.
      ENDLOOP.
      CLEAR : lv_code_string.
    ENDLOOP.
*end of changes by atul

    LOOP AT lt_intab INTO lwa_intab.
      CLEAR: lt_tab, lt_tab1.
      CONDENSE lwa_intab-intab.
      CONCATENATE lwa_intab-intab '-' INTO lv_intab.
      LOOP AT lt_str_fm_f INTO wa_str_fm_f_tb WHERE code CS lv_intab.
        "chaged by atul for % calc
        CONDENSE wa_str_fm_f_tb-code.
        REPLACE ALL  OCCURRENCES OF gc_comma IN  wa_str_fm_f_tb-code
        WITH
        space.
        "ashish sep24 - inorder to take care of statement which are only seprat
        "ed by , - missed
        SPLIT wa_str_fm_f_tb-code AT ' ' INTO TABLE lt_tab.
        "chaged by atul for % calc   --- missed
        DELETE lt_tab WHERE text = ''.
        LOOP AT lt_tab INTO lwa_tab.
          IF lwa_tab CS lv_intab.
            CONDENSE lwa_tab.
            SPLIT lwa_tab AT '-' INTO TABLE lt_tab1.
            READ TABLE lt_tab1 INTO lwa_tab1 INDEX 1.
            IF sy-subrc IS INITIAL.
              lwa_wa_row-progname = gv_prog.
              lwa_wa_row-intab = lwa_intab-intab.
              lwa_wa_row-wa = lwa_tab1.
              CONDENSE: lwa_tab1, lwa_intab-intab.
              TRANSLATE lwa_tab1 TO UPPER CASE.
              TRANSLATE lwa_intab-intab TO UPPER CASE.
              CHECK lwa_tab1 = lwa_intab-intab.

              READ TABLE lt_tab1 INTO lwa_tab1 INDEX 2.
              IF sy-subrc IS INITIAL.
                REPLACE FIRST OCCURRENCE OF gc_dot IN lwa_tab1 WITH
                space.
                REPLACE FIRST OCCURRENCE OF gc_comma IN lwa_tab1 WITH
                space.
                "start of change by ashish 09 oct -- field coming with garbage
                "suffix/prefix
                REPLACE FIRST OCCURRENCE OF gc_close_bracket IN lwa_tab1
                WITH space.
                REPLACE FIRST OCCURRENCE OF gc_open_bracket IN lwa_tab1
                WITH space.
                REPLACE FIRST OCCURRENCE OF gc_bracket IN lwa_tab1 WITH
                space.
                "start of change by ashish 09 oct -- field coming with garbage
                "suffix/prefix
                CONDENSE lwa_tab1.
                lwa_wa_row-fieldname = lwa_tab1.
                CHECK  lwa_wa_row-fieldname NS '<'.
                CHECK  lwa_wa_row-fieldname NS '>'.
                APPEND lwa_wa_row TO lt_wa_row.
              ENDIF.
            ENDIF.
          ENDIF.
          CLEAR : wa_str_fm_f_tb , lwa_wa_row.
          "changed by atul for % calc
        ENDLOOP.
      ENDLOOP.
    ENDLOOP.

*start of change by ashish on 10 OCT -- in case of FUGR  include being
*scanned should be in the gt_progname1
    IF gv_prog+0(2) = gc_lz OR gv_prog+0(2) = gc_ly.
      DELETE gt_progname1 WHERE  progname = gv_prog.
    ENDIF.
*end of change by ashish on 10 OCT -- in case of FUGR  include being
*scanned should be in the gt_progname1

*Begin of Atul by 09102014..
    IF lt_wa_row IS NOT INITIAL.
      LOOP AT lt_wa_row INTO lwa_wa_row.
        REPLACE ALL OCCURRENCES OF gc_dot IN lwa_wa_row-fieldname WITH
        space.
        REPLACE ALL OCCURRENCES OF '''' IN lwa_wa_row-fieldname WITH
        space.
        REPLACE ALL OCCURRENCES OF gc_comma IN lwa_wa_row-fieldname WITH
        space.
        REPLACE ALL OCCURRENCES OF gc_colon IN lwa_wa_row-fieldname WITH
        space.
        REPLACE ALL OCCURRENCES OF gc_close_bracket IN
        lwa_wa_row-fieldname WITH
        space.
        REPLACE ALL OCCURRENCES OF gc_open_bracket IN
        lwa_wa_row-fieldname WITH
        space.
        IF lwa_wa_row-fieldname CS '+'.
          lv_per1 = lwa_wa_row-fieldname.
          SPLIT lv_per1 AT '+' INTO lv_per2 lv_per3.
          CONDENSE lv_per2.
          lwa_wa_row-fieldname = lv_per2.
          CLEAR : lv_per1 , lv_per2, lv_per3.
        ENDIF.
        MODIFY lt_wa_row FROM lwa_wa_row.
      ENDLOOP.
*End of Atul by 09102014.
      SORT lt_wa_row BY fieldname.
      DELETE ADJACENT DUPLICATES FROM lt_wa_row COMPARING fieldname.
      DESCRIBE TABLE lt_wa_row LINES lv_line1.
      CONDENSE lv_line1.
    ENDIF.

    LOOP AT lt_wa_row INTO lwa_wa_row.
      lwa_wa_row-fieldcount = lv_line1.
      IF sy-tabix GE 1.
        MODIFY lt_wa_row FROM lwa_wa_row INDEX sy-tabix TRANSPORTING
        fieldcount.
      ENDIF.
    ENDLOOP.

    CLEAR: lv_per.
    LOOP AT lt_wa_row INTO lwa_wa_row.
      READ TABLE lt_intab INTO lwa_intab WITH KEY
                       progname = lwa_wa_row-progname
                          intab = lwa_wa_row-intab.
      IF sy-subrc IS INITIAL.
        CONDENSE lwa_wa_row-fieldcount.
        CONDENSE lwa_intab-fieldcount.
        IF  ( lwa_wa_row-fieldcount <> gc_zero ) AND
            ( lwa_wa_row-fieldcount <> ' ' ).
          IF ( lwa_intab-fieldcount <> gc_zero ) AND
             ( lwa_intab-fieldcount <> ' ' ).
            lv_per = ( ( lwa_wa_row-fieldcount ) / (
            lwa_intab-fieldcount
            ) ) * 100.
            CONDENSE lv_per.
          ENDIF.
        ELSE.
          lv_per = gc_zero.
          CONDENSE lv_per.
        ENDIF.
      ENDIF.
    ENDLOOP.

    CLEAR: lv_fieldnames.
    CLEAR: gv_fields.
    LOOP AT lt_wa_row INTO lwa_wa_row.
      TRANSLATE lwa_intab-table TO UPPER CASE.
      READ TABLE lt_intab INTO lwa_intab WITH KEY
                           progname = lwa_wa_row-progname
                              intab = lwa_wa_row-intab.
      lwa_final-table = lwa_intab-table.

      CLEAR: lv_local.
      CONCATENATE  lwa_intab-table gc_tilde lwa_wa_row-fieldname INTO
      lv_local.
      IF gv_join_fae = gc_x. "22NOV
        CONCATENATE gv_fields lwa_wa_row-fieldname INTO gv_fields
         SEPARATED BY gc_seperator.
      ENDIF.   " 22NOV
      CONCATENATE lv_fieldnames lv_local
      INTO lv_fieldnames SEPARATED BY gc_seperator.
*CONCATENATE lv_fieldnames lwa_wa_row-fieldname INTO lv_fieldnames
*SEPARATED BY '|'.
      lwa_final-prog = lwa_wa_row-progname.
      DATA : new_f1 TYPE string.                            "new fr ED1
      CONDENSE lwa_final-code.
      IF lwa_final-code CS gc_select_sing_str.
        CONCATENATE 'Select Single *  ' lwa_final-type INTO
        new_f1 SEPARATED BY space.
        lwa_final-oper = new_f1.
*        lwa_final-opercd = '45'.
        lwa_final-opercd = gc_34.
        lwa_final-act_st = 'Recommended to avoid degradation in HANA'.
        CLEAR :new_f1.
      ELSE.
        CONCATENATE 'Select *  ' lwa_final-type INTO
        new_f1 SEPARATED BY space.
        lwa_final-oper = new_f1.
*        lwa_final-opercd = '15'.
        lwa_final-opercd = gc_35.
        lwa_final-act_st = 'Recommended to avoid degradation in HANA'.
        CLEAR :new_f1.
      ENDIF.
*    lwa_final-opercd = '15'.
      lwa_final-corr = gc_x.

*    " select * upto row shouldnt be catched
*    CONDENSE lwa_final-code.
*    IF lwa_final-code CS 'UP TO'.
*      continue.
*    endif.
    ENDLOOP.

*    check gv_join_fae ne 'X'.  "22NOV AXA

    PERFORM get_crit_per USING lv_per
                         CHANGING lwa_final.
    IF lv_per > 100.
      lv_per = ''.
    ENDIF.
    lwa_final-line = p_index. " 14th NOV
*Start of Change def_18
*    IF lv_per <> gc_zero AND lt_wa_row IS NOT INITIAL.
    IF lv_per <> gc_zero AND lt_wa_row IS NOT INITIAL AND lwa_final-code NS 'SELECT SINGLE'.
*End of Change def_18
      CONCATENATE lv_per+0(5) '%' INTO lv_final1.
      CONDENSE lv_fieldnames.
      CONCATENATE lv_final1 'of columns used.' 'Select only'
      lv_fieldnames 'from table' lwa_intab-table INTO lv_final2
      SEPARATED BY space.
      IF lv_insuff = gc_x.
        CONCATENATE 'Insufficient Evaluation:' lv_final2 INTO lv_final2
        SEPARATED BY space.
      ENDIF.
      lwa_final-check = lv_final2.
      lwa_final-fields = lv_fieldnames.
*      lwa_final-line = lwa_intab-line.
      lwa_final-line = p_index. " 14th NOV
      lwa_final-obj_name = gs_progname-progname.
      lwa_final-drill = gv_drill.
      lwa_final-prog   = gv_prog.
*      APPEND lwa_final TO gt_final.
      PERFORM get_crit CHANGING lwa_final.
      PERFORM append_final USING lwa_final.
*    ELSEIF ( lt_wa_row IS NOT INITIAL ) .
*Start of Change def_18
    ELSEIF ( lt_wa_row IS NOT INITIAL ) AND lwa_final-code NS 'SELECT SINGLE'.
*End of Change def_18
      CONCATENATE lv_per '%'  INTO lv_final1.
      CONCATENATE lv_final1 'of columns used.'
      'No field is selected from table' lwa_intab-table
      INTO lv_final2 SEPARATED BY space.
      lwa_final-check = lv_final2.
      lwa_final-fields = lv_fieldnames.
*      lwa_final-line = lwa_intab-line. " 14th NOV - ashish --
      "incorrect line no.
      lwa_final-line = p_index. " 14th Nov*
      lwa_final-obj_name = gs_progname-progname.
      lwa_final-drill = gv_drill.
      lwa_final-prog   = gv_prog.
*      APPEND lwa_final TO gt_final.
      PERFORM get_crit CHANGING lwa_final.
      PERFORM append_final USING lwa_final.
    ELSE.
      lwa_final-prog = gv_prog.
      CONDENSE lwa_final-code.
      DATA : new_f2 TYPE string.

*Start of Change def_18
*      IF lwa_final-code CS gc_select_sing_str.
*******BOC by Shreeda Def_37 26/5/2017 ---Max and min in select are not read by this IF--
*      IF lwa_final-code CS gc_select_sing_str
*           OR lwa_final-code CS 'SELECT * UP TO'
*           OR ( lwa_final-code CS gc_select_sing
*           AND ( lwa_final-code NS 'MAX'
*           OR lwa_final-code NS 'MIN'
*           OR lwa_final-code NS 'SUM'
*           OR lwa_final-code NS 'ORDER BY') ) .

      IF lwa_final-code CS gc_select_sing_str
       OR lwa_final-code CS 'SELECT * UP TO'
       OR lwa_final-code CS gc_select_sing
        AND ( lwa_final-code NS 'MAX'
        AND lwa_final-code NS 'MIN'
        AND lwa_final-code NS 'SUM'
        AND lwa_final-code NS 'ORDER BY' ).
        IF lwa_final-type NE 'VIEW'.
*******EOC by Shreeda Def_37 26/5/2017 ---Max and min in select are not read by this IF-----
          "begin of change for def_18 by vimal
*          DATA : lv_count1 TYPE i,
*                 lv_count2 TYPE i,
*          CLEAR lt_tabkey_count.
*          lt_tabkey_count[] = lt_tabkey[].
*          SORT : lt_tabkey_count[] , lt_tab3[].
*          DELETE lt_tabkey_count WHERE fieldname = 'MANDT' OR fieldname = 'MANDANT' OR fieldname = '.INCLUDE' .
*
*          DESCRIBE TABLE   lt_tabkey_count LINES lv_count2.
          DATA          : lt_dd03 TYPE STANDARD TABLE OF dd03p,
                          lv_keys TYPE wdy_boolean.
          FIELD-SYMBOLS : <fs_dd03>  TYPE dd03p.
          REFRESH: lt_dd03.
          CONSTANTS : lc_mandt   TYPE char5 VALUE 'MANDT',
                      lc_mandant TYPE char7  VALUE 'MANDANT',
                      lc_include TYPE char8  VALUE '.INCLUDE'.
          "FM to get fields
          CALL FUNCTION 'BDL_DDIF_TABL_GET'
            EXPORTING
              name          = lv_table
              state         = 'A'
              langu         = sy-langu
            TABLES
              dd03p_tab     = lt_dd03
            EXCEPTIONS
              illegal_input = 1
              OTHERS        = 2.
          IF sy-subrc <> 0.
*            * Implement suitable error handling here
          ELSE.
            "confirm key fields
** BOC Navneet Def_26
            IF lv_table NE 'T000'.
** EOC
              LOOP AT lt_dd03 ASSIGNING <fs_dd03> WHERE keyflag = abap_true
                                                 AND  fieldname NE lc_mandt
                                                  AND fieldname NE lc_mandant
                                                  AND fieldname NE lc_include .
                READ TABLE lt_tab3 WITH KEY text = <fs_dd03>-fieldname TRANSPORTING NO FIELDS.
                IF sy-subrc NE 0.
                  lv_keys = abap_false.
                ELSE.
                  lv_keys = abap_true.
                ENDIF.
              ENDLOOP.
              REFRESH: lt_dd03.
** BOC Navneet Def_26
** Even though full primary available in ‘Select Single *  where’ condition, still tool is
** changing it to Select-End select.
            ELSE.
              LOOP AT lt_dd03 ASSIGNING <fs_dd03> WHERE keyflag = abap_true
                                                 AND fieldname NE lc_include .
******   BOC Shreeda 1/05/2017
                DATA: lv_new1 TYPE string,
                      lv_new2 TYPE string.
                READ TABLE lt_tab3 INTO lwa_tab3 INDEX 1.
                IF sy-subrc EQ 0.
                  IF lwa_tab3-text CS gc_tilde.
                    SPLIT lwa_tab3-text AT gc_tilde INTO lv_new1 lv_new2.
                    CONDENSE lv_new2.
                    lwa_tab3-text = lv_new2.
                    MODIFY lt_tab3 FROM lwa_tab3 INDEX 1.
                  ENDIF.
                ENDIF.
******   EOC Shreeda 1/05/2017
                READ TABLE lt_tab3 WITH KEY text = <fs_dd03>-fieldname TRANSPORTING NO FIELDS.
                IF sy-subrc NE 0.
                  lv_keys = abap_false.
                ELSE.
                  lv_keys = abap_true.
                ENDIF.
              ENDLOOP.
** EOC Navneet Def_26
            ENDIF.
            "check and update
            IF lv_keys EQ abap_false.
****BOC NLE Def_34 issue 2 by Shreeda --------------------*******************
              IF lwa_final-code NS gc_join.
****EOC NLE Def_34 issue 2 by Shreeda --------------------*******************
                IF lwa_final-code CS gc_select_sing_str.
                  CONCATENATE 'Select Single *  ' lwa_final-type
                 INTO new_f2 SEPARATED BY space.
                ELSEIF lwa_final-code CS gc_select_sing.
                  CONCATENATE 'Select Single Field' lwa_final-type
               INTO new_f2 SEPARATED BY space.
                ELSEIF lwa_final-code CS 'SELECT * UP TO'
                  "begin of change for def_18 by Navneet
                  AND lwa_final-code NS 'ORDER BY'.
                  "end of change for def_18 by Navneet
                  .
                  CONCATENATE 'Select Up to N rows' lwa_final-type
               INTO new_f2 SEPARATED BY space.
                ENDIF.
****BOC NLE Def_34 issue 2 by Shreeda --------------------*******************
              ENDIF.
****EOC NLE Def_34 issue 2 by Shreeda --------------------*******************
              "begin of change for def_18 by Navneet
              IF new_f2 IS NOT INITIAL.
                "end of change for def_18 by Navneet
                lwa_final-oper = new_f2.
                lwa_final-table = lv_table.
                lwa_final-opercd = '57'.
                lwa_final-act_st = 'MANDATORY'.
                lwa_final-drill    = gv_drill.
                lwa_final-obj_name = gs_progname-progname.
                lwa_final-line     = p_index.
                lwa_final-prog     = gv_prog.
                PERFORM get_crit CHANGING lwa_final.
                PERFORM append_final USING lwa_final.
                CLEAR: lwa_final-check, lwa_final-critical.
                "begin of change for def_18 by Navneet
              ENDIF.
              "end of change for def_18 by Navneet
            ENDIF.
          ENDIF.

*          SELECT  fieldname
*            FROM dd03l
*            INTO TABLE lt_tab3_count
*            FOR ALL ENTRIES IN lt_tab3
*            WHERE fieldname = lt_tab3-text+0(30)  AND
*                  tabname   = lv_table AND
*                  keyflag = gc_x .

*          DESCRIBE TABLE lt_tab3_count LINES lv_count1.

*          IF lv_count1 <> lv_count2.
*          IF lwa_final-code CS gc_select_sing_str.
*            CONCATENATE 'Select Single *  ' lwa_final-type
*           INTO new_f2 SEPARATED BY space.
*          ELSEIF lwa_final-code CS gc_select_sing.
*            CONCATENATE 'Select Single Field' lwa_final-type
*         INTO new_f2 SEPARATED BY space.
*          ENDIF.
*
*          lwa_final-oper = new_f2.
*          lwa_final-table = lv_table.
*          lwa_final-opercd = '57'.
*          lwa_final-act_st = 'MANDATORY'.
*          lwa_final-drill    = gv_drill.
*          lwa_final-obj_name = gs_progname-progname.
*          lwa_final-line     = p_index.
*          lwa_final-prog     = gv_prog.
*          PERFORM get_crit CHANGING lwa_final.
*          PERFORM append_final USING lwa_final.
*          CLEAR: lwa_final-check, lwa_final-critical.
*          ENDIF.
          "end of change for def_18 by vimal
        ENDIF.
        IF lwa_final-code CS gc_select_sing_str .
*End of Change def_18

          CONCATENATE 'Select Single *  ' lwa_final-type
          INTO new_f2 SEPARATED BY space.
          lwa_final-oper = new_f2.
*        lwa_final-opercd = '45'.
          lwa_final-opercd = gc_34.
          lwa_final-act_st = 'Recommended to avoid degradation in HANA'.
          CLEAR : new_f2.
*Start of change def_18
        ENDIF.

      ELSE.
        CONCATENATE 'Select *  ' lwa_final-type INTO
        new_f2 SEPARATED BY space.
        lwa_final-oper = new_f2.
*        lwa_final-opercd = '15'.
        lwa_final-opercd = gc_35.
        lwa_final-act_st = 'Recommended to avoid degradation in HANA'.
        CLEAR : new_f2.

      ENDIF.
*End of Change def_18

      IF lwa_final-code CS gc_select_str .

        lwa_final-obj_name = gs_progname-progname.
        lwa_final-corr = gc_x.
        lwa_final-table = lv_table.
        lwa_final-line = p_index.
        lwa_final-drill = gv_drill.
        lwa_final-prog   = gv_prog.
        lwa_final-check =
        'Manual intervention required - Could be potential candidate'.
        " no field usage message in ALV  - ashish12sept
        CLEAR: lwa_final-fields.
        " field cleared due to no field selection -ashish12sept
        CLEAR: lwa_final-fields.
        " field cleared due to no field selection -ashish17sept
        IF lv_insuff = gc_x.
          "comment addded in case Internal table is passed to a method or FM - as
          "hish18sep
          CONCATENATE 'Incomplete Evaluation.' lwa_final-check INTO
          lwa_final-check SEPARATED BY space.
          "comment addded in case Internal table is passed to a method or FM - as
          "hish18sep
        ENDIF.

        " select * upto row shouldnt be catched
        CONDENSE lwa_final-code.
        IF lwa_final-code NS 'UP TO 1 ROWS'.
*        APPEND lwa_final TO gt_final.
          PERFORM get_crit CHANGING lwa_final.
          PERFORM append_final USING lwa_final.
        ENDIF.
      ENDIF.

*Start of changes Def_18 in 2/09/2017
*      CONDENSE lwa_final-code.
*      IF lwa_final-code CS 'SELECT * UP TO' AND lwa_final-code NS 'ORDER BY'.
*
*        CLEAR lt_tabkey_count.
*        lt_tabkey_count[] = lt_tabkey[].
*
*        DELETE lt_tabkey_count WHERE fieldname = 'MANDT'  OR fieldname = 'MANDANT' OR fieldname = '.INCLUDE' .
*
*        DESCRIBE TABLE   lt_tabkey_count LINES lv_count2.
*        IF lwa_final-type NE 'VIEW'.
*
*          DESCRIBE TABLE   lt_tabkey_count LINES lv_count2.
**Change on 21st
*          SELECT  fieldname
*            FROM dd03l
*            INTO TABLE lt_tab3_count
*            FOR ALL ENTRIES IN lt_tab3
*            WHERE fieldname = lt_tab3-text+0(30)  AND
*                  tabname   = lv_table AND
*                  keyflag = gc_x .
*
*          DESCRIBE TABLE lt_tab3_count LINES lv_count1.
*          IF lv_count1 <> lv_count2.
*            CONCATENATE 'Select Up to n rows  ' lwa_final-type
*             INTO new_f2 SEPARATED BY space.
*            lwa_final-oper = new_f2.
*            lwa_final-table = lv_table.
*            lwa_final-opercd = '57'.
*            lwa_final-act_st = 'MANDATORY'.
*            lwa_final-drill    = gv_drill.
*            lwa_final-obj_name = gs_progname-progname.
*            lwa_final-line     = p_index.
*            lwa_final-prog     = gv_prog.
*            PERFORM get_crit CHANGING lwa_final.
*            PERFORM append_final USING lwa_final.
*            CLEAR: lwa_final-check, lwa_final-critical.
*          ENDIF.
*        ENDIF."end of code comment for def_18
*END of changes Def_18 in 2/09/2017
*      clear lwa_final.
*      ENDIF.
    ENDIF.
***pool /cluster table
*      IF gs_final-type CS 'POOL' OR gs_final-type CS 'CLUSTER'.
    IF ( lwa_final-type CS gc_pool OR lwa_final-type CS gc_cluster ) AND
       ( lwa_final-code NS gc_ord_by )  .
*Start of change DEF_18
      IF ( lwa_final-code CS 'SELECT SINGLE' ) .
      ELSE.
*End of change DEF_18
        lwa_final-opercd   = gc_16.
        lwa_final-drill    = gv_drill.
        lwa_final-obj_name = gs_progname-progname.
        lwa_final-line     = p_index.
        lwa_final-prog     = gv_prog.
        PERFORM get_crit CHANGING lwa_final.
        PERFORM append_final USING lwa_final.
        CLEAR: lwa_final-check, lwa_final-critical.
      ENDIF.
    ENDIF.
    CLEAR lwa_final.
    pwa_code =  lv_original .
*    pwa_code = lv_code.  "Shekhar08SEP14 " ashish AXA test
**SHEKHAR08SEP2014
**  IF gv_flag_d = 'X'.
**    gv_drill = gv_drill + 1.  " endselect assumed
**    gv_drill_max = gv_drill_max + 1.
**    "endselect drill should increase post statement: need to so in
*order to
**    "take care of select * in next iteration.
**  ENDIF.
**SHEKHAR08SEP2014
*gt_intab[] = lt_intab[].   " AXA
*refresh: lt_intab[], lt_wa_row[].
    APPEND LINES OF lt_intab[] TO gt_intab[].
    SORT gt_intab[] BY progname
             table
             intab
             line
             fieldcount.
    DELETE ADJACENT DUPLICATES FROM gt_intab[] COMPARING progname
             table
             intab
             line
             fieldcount.

    REFRESH: lt_intab[], lt_wa_row[].
*Catch system exceptions
  ENDCATCH.
  IF sy-subrc <> 0.
    WRITE:/ gc_error , 'Error code:', sy-subrc ,'=>Perform GET_SEL_STAR'
    .
  ENDIF.
*Catch system exceptions
ENDFORM.                    " GET_SEL_STAR

*&---------------------------------------------------------------------*
*&      Form  F_SCAN_BAPI
*&---------------------------------------------------------------------*
*TO Trace BAPI inside the LOOP
*----------------------------------------------------------------------*
*      -->PWA_CODE    Current statement source code
*      -->LU_INDEX    Current line number
*----------------------------------------------------------------------*
FORM f_scan_bapi  USING  pwa_code
                         lu_index.

*Catch system exceptions
  CATCH SYSTEM-EXCEPTIONS arithmetic_errors             = 1
                          create_data_errors            = 2
                          conversion_errors             = 3
                          create_object_errors          = 4
                          data_access_errors            = 5
                          assign_casting_illegal_cast   = 6
                          assign_casting_unknown_type   = 7
                          assign_field_not_in_range     = 8
                          data_offset_too_large         = 9
                          dyn_call_meth_not_implemented = 10
                          export_buffer_no_memory       = 11
                          generate_subpool_dir_full     = 12
                          move_cast_error               = 13
                          perform_program_name_too_long = 14
                          replace_infinite_loop         = 15
                          remote_call_errors            = 16
                          localization_errors           = 17
                          import_mismatch_errors        = 18
                          dynamic_call_method_errors    = 19
                          file_access_errors            = 20
                          OTHERS                        = 99.
*Catch system exceptions

    DATA : lv_line   TYPE          string,
           lwa_final TYPE          ty_final,
           lv_code   TYPE          string,
           lt_type   TYPE TABLE OF ty_sourcetab,
           lwa_type  TYPE          ty_sourcetab.

    SPLIT pwa_code AT space INTO TABLE lt_type.
    READ TABLE lt_type INTO lwa_type INDEX 3.
    IF lwa_type CS gc_bapi.
      CONCATENATE gc_bapi lwa_type 'is called inside loop'
      INTO lwa_final-check SEPARATED BY space.
      lwa_final-opercd = gc_42.
    ELSE.
      CONCATENATE 'FM'  lwa_type 'is called inside loop'
      INTO lwa_final-check SEPARATED BY space.
      lwa_final-opercd = gc_43. "FM
    ENDIF.
    lwa_final-prog = gv_prog.
    lwa_final-line = lu_index.
    lwa_final-drill = gv_drill.
    lwa_final-obj_name = gs_progname-progname.
    PERFORM get_crit CHANGING lwa_final.
    PERFORM append_final USING lwa_final.

    CLEAR : lv_line, lv_code, lwa_final.

*Catch system exceptions
  ENDCATCH.
  IF sy-subrc <> 0.
    WRITE:/ gc_error , 'Error code:', sy-subrc ,'=>Perform F_SCAN_BAPI'.
  ENDIF.
*Catch system exceptions
ENDFORM.                    " F_SCAN_BAPI

*&---------------------------------------------------------------------*
*&      Form  F_SCAN_CONTROL
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*

FORM f_scan_control USING pwa_code
                           lu_index .

*Catch system exceptions
  CATCH SYSTEM-EXCEPTIONS arithmetic_errors             = 1
                          create_data_errors            = 2
                          conversion_errors             = 3
                          create_object_errors          = 4
                          data_access_errors            = 5
                          assign_casting_illegal_cast   = 6
                          assign_casting_unknown_type   = 7
                          assign_field_not_in_range     = 8
                          data_offset_too_large         = 9
                          dyn_call_meth_not_implemented = 10
                          export_buffer_no_memory       = 11
                          generate_subpool_dir_full     = 12
                          move_cast_error               = 13
                          perform_program_name_too_long = 14
                          replace_infinite_loop         = 15
                          remote_call_errors            = 16
                          localization_errors           = 17
                          import_mismatch_errors        = 18
                          dynamic_call_method_errors    = 19
                          file_access_errors            = 20
                          OTHERS                        = 99.
*Catch system exceptions

    DATA : lwa_final TYPE ty_final,
           lv_line   TYPE string.

    lv_line = pwa_code.
    REPLACE FIRST OCCURRENCE OF gc_dot IN lv_line WITH space.
    CONDENSE lv_line.
    CONCATENATE lv_line 'is inside the loop' INTO lwa_final-check
    SEPARATED BY space.
    lwa_final-oper = lv_line.
    lwa_final-opercd = gc_48.
    lwa_final-prog = gv_prog.
    lwa_final-obj_name = gs_progname-progname.
    lwa_final-line = lu_index.
    lwa_final-drill = gv_drill.
    PERFORM get_crit CHANGING lwa_final.
    PERFORM append_final USING lwa_final.
    CLEAR :  lwa_final.

*Catch system exceptions
  ENDCATCH.
  IF sy-subrc <> 0.
    WRITE:/ gc_error , 'Error code:', sy-subrc ,
    '=>Perform F_SCAN_CONTROL'.
  ENDIF.
*Catch system exceptions
ENDFORM.                    " F_SCAN_CONTROL

*&---------------------------------------------------------------------*
*&      Form  GET_JOIN_TAB
*&---------------------------------------------------------------------*
* Get JOIN table
*----------------------------------------------------------------------*
*      -->P_STR2     Source code of line
*      -->P_INDEX1   Current line number
*      <--PT_TABLE1  Update global table
*----------------------------------------------------------------------*
FORM get_join_tab  USING    p_str2
                            p_index1
                   CHANGING pt_table1 LIKE gt_table.

*Catch system exceptions
  CATCH SYSTEM-EXCEPTIONS arithmetic_errors             = 1
                          create_data_errors            = 2
                          conversion_errors             = 3
                          create_object_errors          = 4
                          data_access_errors            = 5
                          assign_casting_illegal_cast   = 6
                          assign_casting_unknown_type   = 7
                          assign_field_not_in_range     = 8
                          data_offset_too_large         = 9
                          dyn_call_meth_not_implemented = 10
                          export_buffer_no_memory       = 11
                          generate_subpool_dir_full     = 12
                          move_cast_error               = 13
                          perform_program_name_too_long = 14
                          replace_infinite_loop         = 15
                          remote_call_errors            = 16
                          localization_errors           = 17
                          import_mismatch_errors        = 18
                          dynamic_call_method_errors    = 19
                          file_access_errors            = 20
                          OTHERS                        = 99.
*Catch system exceptions

    DATA: lv_str1   TYPE          string,
          lv_str2   TYPE          string,
          lt_tab    TYPE TABLE OF ty_code,
          lt_tab1   TYPE TABLE OF ty_code,
          lwa_code  TYPE          ty_code,
          lwa_table TYPE          ty_tab,
          lv_lines  TYPE          i.
    DATA: l_tabclass TYPE dd02l-tabclass.
    CLEAR: l_tabclass.
    DATA: lv_table TYPE char30.
    SPLIT p_str2 AT gc_join_spc INTO lv_str1 p_str2.
    CONDENSE: p_str2, lv_str1.
    SPLIT p_str2 AT space INTO TABLE lt_tab.
    SPLIT lv_str1 AT space INTO TABLE lt_tab1.
    DESCRIBE TABLE lt_tab1 LINES lv_lines.
    CONDENSE lv_str2.
    CLEAR lwa_code.
    READ TABLE lt_tab INTO lwa_code INDEX 1.
    IF sy-subrc = 0.
      lwa_table-table = lwa_code.
      lwa_table-line = p_index1.
      CLEAR lwa_code.
      READ TABLE lt_tab1 INTO lwa_code INDEX lv_lines.
      IF sy-subrc = 0.
        IF lwa_code CS gc_outer OR lwa_code CS gc_inner.
          lwa_table-join = lwa_code.
        ENDIF.
      ENDIF.

      APPEND lwa_table TO pt_table1.
    ENDIF.
    CLEAR: lv_str1, lv_str2.

*Catch system exceptions
  ENDCATCH.
  IF sy-subrc <> 0.
    WRITE:/ gc_error , 'Error code:', sy-subrc ,'=>Perform GET_JOIN_TAB'
    .
  ENDIF.
*Catch system exceptions
ENDFORM.                    " GET_JOIN_TAB

*&---------------------------------------------------------------------*
*&      Form  CHECK_SORT
*&---------------------------------------------------------------------*
* Check SORT keyword in statement
*----------------------------------------------------------------------*
*      -->PWA_CODE   Source code of current line
*      -->P_INDEX    Current line number
*----------------------------------------------------------------------*
FORM check_sort  USING VALUE(pwa_code)
                             p_index.

*Catch system exceptions
  CATCH SYSTEM-EXCEPTIONS arithmetic_errors             = 1
                          create_data_errors            = 2
                          conversion_errors             = 3
                          create_object_errors          = 4
                          data_access_errors            = 5
                          assign_casting_illegal_cast   = 6
                          assign_casting_unknown_type   = 7
                          assign_field_not_in_range     = 8
                          data_offset_too_large         = 9
                          dyn_call_meth_not_implemented = 10
                          export_buffer_no_memory       = 11
                          generate_subpool_dir_full     = 12
                          move_cast_error               = 13
                          perform_program_name_too_long = 14
                          replace_infinite_loop         = 15
                          remote_call_errors            = 16
                          localization_errors           = 17
                          import_mismatch_errors        = 18
                          dynamic_call_method_errors    = 19
                          file_access_errors            = 20
                          OTHERS                        = 99.
*Catch system exceptions

    DATA: lt_tab    TYPE TABLE OF ty_code,
          lwa_intab TYPE          ty_intab,
          lwa_final TYPE          ty_final.

    SPLIT pwa_code AT space INTO TABLE lt_tab.
    CLEAR pwa_code.
    READ TABLE lt_tab INTO pwa_code INDEX 2.
    CONDENSE pwa_code.
    IF sy-subrc = 0.
      READ TABLE gt_intab INTO lwa_intab WITH KEY intab = pwa_code.
      IF sy-subrc = 0.
        lwa_final-opercd = gc_14.
        lwa_final-prog = gv_prog.
        lwa_final-obj_name = gs_progname-progname.
        lwa_final-line = p_index.
        lwa_final-drill = gv_drill.
        CONCATENATE 'Instead using SORT on table'
        lwa_intab-table ', use ORDER BY'
        INTO lwa_final-check SEPARATED BY space.
        PERFORM append_final USING lwa_final.
        CLEAR :  lwa_final.
      ENDIF.
    ENDIF.

*Catch system exceptions
  ENDCATCH.
  IF sy-subrc <> 0.
    WRITE:/ gc_error , 'Error code:', sy-subrc ,'=>Perform CHECK_SORT'.
  ENDIF.
*Catch system exceptions
ENDFORM.                    " CHECK_SORT

*&---------------------------------------------------------------------*
*&      Form  F_STATEMENT
*&---------------------------------------------------------------------*
* To Trace the Delete adjacent Duplicates and CURSOR statements
*----------------------------------------------------------------------*
*      -->LV_P_CODE   Source code of current line
*      -->P_INDEX    Current line number
*----------------------------------------------------------------------*
FORM f_statement  USING    lv_p_code LIKE gt_code
                           pwa_code
                           lu_index
                           sline.

*Catch system exceptions
  CATCH SYSTEM-EXCEPTIONS arithmetic_errors             = 1
                          create_data_errors            = 2
                          conversion_errors             = 3
                          create_object_errors          = 4
                          data_access_errors            = 5
                          assign_casting_illegal_cast   = 6
                          assign_casting_unknown_type   = 7
                          assign_field_not_in_range     = 8
                          data_offset_too_large         = 9
                          dyn_call_meth_not_implemented = 10
                          export_buffer_no_memory       = 11
                          generate_subpool_dir_full     = 12
                          move_cast_error               = 13
                          perform_program_name_too_long = 14
                          replace_infinite_loop         = 15
                          remote_call_errors            = 16
                          localization_errors           = 17
                          import_mismatch_errors        = 18
                          dynamic_call_method_errors    = 19
                          file_access_errors            = 20
                          OTHERS                        = 99.
*Catch system exceptions

    DATA : lwa_final TYPE          ty_final,
***********BOC Shreeda 1/05/2017************
           lw_sel_t  TYPE          t_sort,
***********EOC Shreeda 1/05/2017************
           lv_1      TYPE          string,
           lv_2      TYPE          string,
           lt_type   TYPE TABLE OF ty_sourcetab,
           lwa_type  TYPE          string,
           lv_blank  TYPE          string,
           lv_tab    TYPE          string,
           lv_fm     TYPE          string.

    REPLACE FIRST OCCURRENCE OF gc_dot IN pwa_code WITH space.
    CONDENSE pwa_code.

    TRANSLATE pwa_code TO UPPER CASE.

*==========================
*Check that keyword written inside single quotes
*==========================
    PERFORM get_offset_key_single_quote USING
             pwa_code 'DELETE ADJACENT DUPLICATES'
             CHANGING gv_check_flag.

*==========================
*Check if statement having DELETE ADJACENT DUPLICATES but
*sorting is not done on internal table
*==========================
    IF pwa_code CS gc_del_adj_dup
        AND gv_check_flag IS INITIAL.

      SPLIT pwa_code AT 'DELETE ADJACENT DUPLICATES FROM'
      INTO lv_blank lv_tab.
      CLEAR lv_blank.
      CONDENSE lv_tab.
      SPLIT lv_tab AT space INTO lv_tab lv_blank.
      CONDENSE lv_tab.
      IF sy-subrc IS INITIAL.

        CLEAR: gt_f_code, gv_nt_found.
        " start: replace FM with Form
*        CALL FUNCTION 'ZAUCT_FIND_STR'
*          EXPORTING
*            p_name       = gv_prog
*            code_string  = lv_tab
*            start_line   = sline
*            line_no      = lu_index
*            p_type       = 'D'
*          IMPORTING
*            lv_not_found = gv_nt_found
*          TABLES
*            it_fcode     = gt_f_code.

        PERFORM get_scan TABLES gt_f_code
                    USING gv_prog lv_tab sline lu_index 'D' ''
                    CHANGING gv_nt_found.

* end: replace FM with form
        IF gt_f_code IS INITIAL.
*          lwa_final-code = pwa_code.
*          lwa_final-itabs = lv_tab.
*          lwa_final-check = 'Delete adjacent Duplicates is used' .
*          lwa_final-opercd = gc_46.
*          lwa_final-prog = gv_prog.
*          lwa_final-obj_name = gs_progname-progname.
*          lwa_final-line = lu_index.
*          lwa_final-critical = gc_medium.
*          lwa_final-drill = gv_drill.
*          PERFORM append_final USING lwa_final.

** Begin of changes by Sahil for DEF_17  - 5/2/2017

          DATA:  lwa_sort_tab TYPE t_tab_sort.
          READ TABLE gt_sort INTO lwa_sort_tab WITH KEY table = lv_tab .
          READ TABLE gt_sel_t INTO lw_sel_t WITH KEY table = lv_tab.
          IF sy-subrc EQ 0.
            IF  sy-subrc <> 0 .
*****BOC Def_36 by shreeda 26/5/2017 ----remove opcode 77, 78, 79
************BOC Shreeda 1/05/2017************
*              CLEAR: gv_stab.
*              gv_stab = lw_sel_t-dbtable.
*              READ TABLE s_table WITH KEY low = gv_stab TRANSPORTING NO FIELDS.
*              IF sy-subrc EQ 0.
*                lwa_final-code = pwa_code.
*                lwa_final-itabs = lv_tab.
*                lwa_final-check = 'Delete adjacent Duplicates is used' .
*                lwa_final-opercd = gc_79.
*                lwa_final-prog = gv_prog.
*                lwa_final-obj_name = gs_progname-progname.
*                lwa_final-line = lu_index.
*                lwa_final-critical = gc_medium.
*                lwa_final-drill = gv_drill.
*              ELSE.
************EOC Shreeda 1/05/2017************
*****EOC Def_36 by shreeda 26/5/2017 ----remove opcode 77, 78, 79
              lwa_final-code = pwa_code.
              lwa_final-itabs = lv_tab.
              lwa_final-check = 'Delete adjacent Duplicates is used' .
              lwa_final-opercd = gc_46.
              lwa_final-prog = gv_prog.
              lwa_final-obj_name = gs_progname-progname.
              lwa_final-line = lu_index.
              lwa_final-critical = gc_medium.
              lwa_final-drill = gv_drill.
*****BOC Def_36 by shreeda 26/5/2017 ----remove opcode 77, 78, 79
***********BOC Shreeda 1/05/2017************
*              ENDIF.
***********EOC Shreeda 1/05/2017************
*****EOC Def_36 by shreeda 26/5/2017 ----remove opcode 77, 78, 79
              PERFORM append_final USING lwa_final.

            ENDIF.
            CLEAR lwa_sort_tab.
          ENDIF.
** End of changes by Sahil for DEF_17  - 5/2/2017
        ENDIF.
      ENDIF.
*==========================
*Check for FM call used for currency conversion in source
*==========================
    ELSEIF ( pwa_code CS gc_call_func ).
      SPLIT pwa_code AT gc_call_func INTO lv_blank lv_fm.
      CLEAR lv_blank.
      CONDENSE lv_fm.
      SPLIT lv_fm AT space INTO lv_fm lv_blank.
      CONDENSE lv_fm.
      IF sy-subrc IS INITIAL.
        CONCATENATE 'FM' lv_fm 'is used for CURRENCY Conversion'
        INTO lwa_final-check SEPARATED BY space.
        lwa_final-opercd = gc_44.
        lwa_final-prog = gv_prog.
        lwa_final-obj_name = gs_progname-progname.
        lwa_final-line = lu_index.
        lwa_final-critical = gc_high.
        lwa_final-drill = gv_drill.
        PERFORM append_final USING lwa_final.
        CLEAR :  lwa_final.
      ENDIF.
    ENDIF.

*Catch system exceptions
  ENDCATCH.
  IF sy-subrc <> 0.
    WRITE:/ gc_error , 'Error code:', sy-subrc ,'=>Perform F_STATEMENT'.
  ENDIF.
*Catch system exceptions
ENDFORM.                    " F_STATEMENT

*&---------------------------------------------------------------------*
*&      Form  GET_CRIT
*&---------------------------------------------------------------------*
* Get Critical Status
*----------------------------------------------------------------------*
*      <--P_LWA_FINAL   Work area for the final table
*----------------------------------------------------------------------*
FORM get_crit  CHANGING p_lwa_final LIKE LINE OF gt_final.
*Catch system exceptions
  CATCH SYSTEM-EXCEPTIONS arithmetic_errors             = 1
                          create_data_errors            = 2
                          conversion_errors             = 3
                          create_object_errors          = 4
                          data_access_errors            = 5
                          assign_casting_illegal_cast   = 6
                          assign_casting_unknown_type   = 7
                          assign_field_not_in_range     = 8
                          data_offset_too_large         = 9
                          dyn_call_meth_not_implemented = 10
                          export_buffer_no_memory       = 11
                          generate_subpool_dir_full     = 12
                          move_cast_error               = 13
                          perform_program_name_too_long = 14
                          replace_infinite_loop         = 15
                          remote_call_errors            = 16
                          localization_errors           = 17
                          import_mismatch_errors        = 18
                          dynamic_call_method_errors    = 19
                          file_access_errors            = 20
                          OTHERS                        = 99.
*Catch system exceptions

    IF p_lwa_final-drill = 1.
      p_lwa_final-critical = gc_low.
    ELSEIF p_lwa_final-drill = 2.
      p_lwa_final-critical = gc_medium.
    ELSEIF p_lwa_final-drill GT 2.
      p_lwa_final-critical = gc_high.
    ENDIF.

    CLEAR p_lwa_final-critical.
*Catch system exceptions
  ENDCATCH.
  IF sy-subrc <> 0.
    WRITE:/ gc_error , 'Error code:', sy-subrc ,'=>Perform GET_CRIT'.
  ENDIF.
*Catch system exceptions
ENDFORM.                    " GET_CRIT

*&---------------------------------------------------------------------*
*&      Form  GET_CRIT_PER
*&---------------------------------------------------------------------*
* Get Critical percentage
*----------------------------------------------------------------------*
*      -->P_LV_PER    Percentage
*      <--P_LWA_FINAL Work area for the final table
*----------------------------------------------------------------------*
FORM get_crit_per  USING    p_lv_per
                   CHANGING p_lwa_final LIKE LINE OF gt_final.

*Catch system exceptions
  CATCH SYSTEM-EXCEPTIONS arithmetic_errors             = 1
                          create_data_errors            = 2
                          conversion_errors             = 3
                          create_object_errors          = 4
                          data_access_errors            = 5
                          assign_casting_illegal_cast   = 6
                          assign_casting_unknown_type   = 7
                          assign_field_not_in_range     = 8
                          data_offset_too_large         = 9
                          dyn_call_meth_not_implemented = 10
                          export_buffer_no_memory       = 11
                          generate_subpool_dir_full     = 12
                          move_cast_error               = 13
                          perform_program_name_too_long = 14
                          replace_infinite_loop         = 15
                          remote_call_errors            = 16
                          localization_errors           = 17
                          import_mismatch_errors        = 18
                          dynamic_call_method_errors    = 19
                          file_access_errors            = 20
                          OTHERS                        = 99.
*Catch system exceptions

    IF p_lv_per LT 50.
      p_lwa_final-critical = gc_high.
    ELSEIF p_lv_per GE 50 OR p_lv_per LE 70.
      p_lwa_final-critical = gc_medium.
    ELSEIF p_lv_per GT 70.
      p_lwa_final-critical = gc_low.
    ENDIF.

    CLEAR p_lwa_final-critical.
*Catch system exceptions
  ENDCATCH.
  IF sy-subrc <> 0.
    WRITE:/ gc_error , 'Error code:', sy-subrc ,'=>Perform GET_CRIT_PER'
    .
  ENDIF.
*Catch system exceptions
ENDFORM.                    " GET_CRIT_PER

*&---------------------------------------------------------------------*
*&      Form  READ_METHOD
*&---------------------------------------------------------------------*
*read code for custom methods
*----------------------------------------------------------------------*
*      -->PLWA_CODE   Source code of the current line
*      -->PLV_INDEX   Line number
*----------------------------------------------------------------------*
FORM read_method  USING    pwa_code
                           plv_index.

*Catch system exceptions
  CATCH SYSTEM-EXCEPTIONS arithmetic_errors             = 1
                          create_data_errors            = 2
                          conversion_errors             = 3
                          create_object_errors          = 4
                          data_access_errors            = 5
                          assign_casting_illegal_cast   = 6
                          assign_casting_unknown_type   = 7
                          assign_field_not_in_range     = 8
                          data_offset_too_large         = 9
                          dyn_call_meth_not_implemented = 10
                          export_buffer_no_memory       = 11
                          generate_subpool_dir_full     = 12
                          move_cast_error               = 13
                          perform_program_name_too_long = 14
                          replace_infinite_loop         = 15
                          remote_call_errors            = 16
                          localization_errors           = 17
                          import_mismatch_errors        = 18
                          dynamic_call_method_errors    = 19
                          file_access_errors            = 20
                          OTHERS                        = 99.
*Catch system exceptions


    DATA: lt_tab        TYPE TABLE OF ty_code,
          lwa_tab       TYPE          ty_code,
          lv_str1       TYPE          string,
          lv_str2       TYPE          string,
*{ Begin of change by Rohit - 29/12/2016
          lv_str3       TYPE          string,
          lv_flag       TYPE          flag,
*} End of change by Rohit - 29/12/2016
          lwa_fieldlist TYPE          rfieldlist,
          lv_clas       TYPE          char30,
          lv_clskey     TYPE          seoclskey,
* Begin of change by Twara 12/01/2016 to replace FM with subroutine
*to get includes of classes
*lt_methods    TYPE          seop_methods_w_include, "commented
*          lwa_methods   TYPE          seop_method_w_include,
* End of change by Twara 12/01/2016 to replace FM with subroutine
*to get includes of classes
          lt_code       TYPE TABLE OF ty_code,
          lv_prog       TYPE char40.
    CLEAR: lv_prog.
*{ Begin of change by Rohit - 29/12/2016
    CLEAR: lv_str1,
           lv_str2,
           lv_str3,
           lv_flag.
*} End of change by Rohit - 29/12/2016
    SPLIT pwa_code AT space INTO TABLE lt_tab.
    READ TABLE lt_tab INTO lwa_tab INDEX 3.
    IF sy-subrc = 0.
      SPLIT lwa_tab AT '->' INTO lv_str1 lv_str2.
*{ Begin of change by Rohit - 29/12/2016
      "/ Static Methods
      IF lv_str2 IS INITIAL.
        SPLIT lwa_tab AT '=>' INTO lv_str1 lv_str2.
        IF lv_str2 IS INITIAL.
          CLEAR: lv_str1, lv_str2.
        ENDIF.
      ENDIF.
      SPLIT lv_str2 AT gc_open_bracket INTO lv_str2 lv_str3.
      SPLIT lv_str2 AT gc_dot INTO lv_str2 lv_str3.
      CONDENSE lv_str2.
      CLEAR lwa_fieldlist.
*} End of change by Rohit - 29/12/2016
      READ TABLE gt_fieldlist INTO lwa_fieldlist WITH KEY name = lv_str1
      .
*{ Begin of change by Rohit - 29/12/2016
      "/ To include Static Methods : classes
      IF sy-subrc <> 0.
        IF NOT lv_str1 IS INITIAL.
          lwa_fieldlist-reftypenam = lv_str1.
          lwa_fieldlist-reftypeloc = gc_clas.
          lv_flag = gc_x.
        ENDIF.
      ENDIF.
*      IF sy-subrc = 0 AND lwa_fieldlist-reftypeloc = 'CLAS'.
      IF ( sy-subrc = 0 AND lwa_fieldlist-reftypeloc = gc_clas )
      OR ( lv_flag EQ gc_x ).
*} End of change by Rohit - 16/12/2016
        CLEAR lv_str1.
        lv_clskey-clsname = lwa_fieldlist-reftypenam.
        lv_str1 = lwa_fieldlist-reftypenam.
        IF lv_str1+0(1) = gc_z OR lv_str1+0(1) = gc_y
        OR ( lv_str1 IN gr_nspace[] AND NOT gr_nspace[] IS INITIAL ).
          "29OCT
          lv_prog = gv_prog.

* Begin of change by Twara 12/01/2016 to replace FM with subroutine
*to get includes of classes
*          CALL FUNCTION 'SEO_CLASS_GET_METHOD_INCLUDES'
*            EXPORTING
*              clskey                       = lv_clskey
*            IMPORTING
*              includes                     = lt_include
*            EXCEPTIONS
*              _internal_class_not_existing = 1
*              OTHERS                       = 2.

          PERFORM get_method_includes USING lv_clskey.

          IF lt_methods IS NOT INITIAL.

*            READ TABLE lt_include INTO lwa_include
*            WITH KEY cpdkey-cpdname = lv_str2.
            READ TABLE lt_methods INTO lwa_methods
            WITH KEY cpdkey-cpdname = lv_str2.
            IF sy-subrc = 0.
*              READ REPORT lwa_include-incname INTO lt_code.
              READ REPORT lwa_methods-incname INTO lt_code.
              IF sy-subrc = 0.
*                gv_prog =  lwa_include-incname .
                gv_prog =  lwa_methods-incname .
* End of change by Twara 12/01/2016 to replace FM with subroutine
*to get includes of classes

                PERFORM get_method USING lt_code
                                         lv_str2
                                         lv_str1.
              ENDIF.
            ENDIF.
          ENDIF.
          gv_prog = lv_prog.
        ENDIF.
*       gv_prog = lv_prog.
      ENDIF.
    ENDIF.

*Catch system exceptions
  ENDCATCH.
  IF sy-subrc <> 0.
    WRITE:/ gc_error , 'Error code:', sy-subrc ,'=>Perform READ_METHOD'.
  ENDIF.
*Catch system exceptions
ENDFORM.                    " READ_METHOD

*&---------------------------------------------------------------------*
*&      Form  GET_METHOD
*&---------------------------------------------------------------------*
* Scan the source code of the method
*----------------------------------------------------------------------*
*      -->P_CODE     Source code of method
*      -->PV_STR2    Method Name
*      -->PV_STR1    Class Name
*----------------------------------------------------------------------*
FORM get_method  USING    p_code LIKE gt_code
                          pv_str2
                          pv_str1.
  DATA: gv_prog99 TYPE progname.
*Catch system exceptions
  CATCH SYSTEM-EXCEPTIONS arithmetic_errors             = 1
                          create_data_errors            = 2
                          conversion_errors             = 3
                          create_object_errors          = 4
                          data_access_errors            = 5
                          assign_casting_illegal_cast   = 6
                          assign_casting_unknown_type   = 7
                          assign_field_not_in_range     = 8
                          data_offset_too_large         = 9
                          dyn_call_meth_not_implemented = 10
                          export_buffer_no_memory       = 11
                          generate_subpool_dir_full     = 12
                          move_cast_error               = 13
                          perform_program_name_too_long = 14
                          replace_infinite_loop         = 15
                          remote_call_errors            = 16
                          localization_errors           = 17
                          import_mismatch_errors        = 18
                          dynamic_call_method_errors    = 19
                          file_access_errors            = 20
                          OTHERS                        = 99.
*Catch system exceptions

    DATA: lt_code  TYPE TABLE OF ty_code,
          lwa_code TYPE          ty_code,
          lwa_slct TYPE          ty_code.
    DATA:lwa_table  TYPE ty_tab,
         lwa_table1 TYPE ty_tab,
         lwa_final  TYPE ty_final.
    DATA: lv_index   TYPE sy-tabix,
          lv_row     TYPE i,
          lv_str1    TYPE string,
          lv_str2    TYPE string,
          lv_col     TYPE i,
          lv_flag1   TYPE c,
          lv_include TYPE progname.
    DATA: lf_include TYPE c,
          lf_form    TYPE c.
    DATA: lv_line TYPE sy-tabix.

    DATA : ldb_name      TYPE          trdir-ldbname,
           ldb_code      TYPE TABLE OF ty_code,
           lwa_code_ldb  TYPE          ty_code,
           lv_ldb1       TYPE          string,
           lv_ldb2       TYPE          string,
           lv_ldb3       TYPE          string,
           lwa_ldb       TYPE          ty_final,
           ldb_index     TYPE          sy-tabix,
           lv_flagcs     TYPE          c,
           lv_flag_quote TYPE          c,
           start_line    TYPE          i.
* Start of change by Manoj on 5/1/2016
    DATA: lv_line_code   TYPE ty_code.
* End of change by Manoj on 5/1/2016
    DATA:  lt_drill   TYPE TABLE OF ty_code.
    DATA: lv_eloop_flag TYPE flag.
    DATA: lv_str99 TYPE string.
    DATA: lt_tab99  TYPE TABLE OF ty_code,
          lwa_tab99 TYPE ty_code.
    DATA: lv_sort TYPE sy-tabix.
    DATA:  lwa_sort_tab TYPE t_tab_sort.
    CLEAR: lv_eloop_flag.
    start_line = 0.

    LOOP AT p_code INTO lwa_code.

      TRANSLATE lwa_code-text TO UPPER CASE.
*==========================
*DO not scan the source code if it is commented
*or statement inside single quotes
*==========================
      CONDENSE lwa_code.
      IF lwa_code-text = '' OR lwa_code-text+0(1) = gc_star OR
      lwa_code-text+0(1) = gc_doub_quote.
        CONTINUE.
      ENDIF.

*==========================
*Source code is already scanned till end of statement by using
*PERFORM get_line ,so do not scan again
*==========================
      lv_index = sy-tabix.
      IF lv_index LE lv_row.
        CONTINUE.
      ENDIF.

*==========================
* Translate the source code to upper case
*==========================
      CONDENSE lwa_code.
      TRANSLATE lwa_code TO UPPER CASE.

*==========================
*Concatenate full statement in a line
*==========================
      PERFORM get_line  USING p_code
                              lv_index
                        CHANGING lv_str1
                                 lv_row.
      lwa_code = lv_str1.
      CONDENSE lwa_code.
*{ Begin of change by Rohit - 16/12/2015
      lv_line_code = lwa_code.
*} End of change by Rohit - 16/12/2015
*=================================
* Logic to find TYPE SORTED TABLE
*=====================================
      REFRESH lt_tab99[].
      CLEAR: lv_str99.
      lv_str99 = lwa_code.
      CONDENSE lv_str99.
      IF lv_str99 CS gc_type_sort_tab.
        REPLACE ALL OCCURRENCES OF gc_type_sort_tab IN lv_str99
        WITH gc_x1x1.
        SPLIT lv_str99 AT '' INTO TABLE lt_tab99.
        LOOP AT lt_tab99 INTO lwa_tab99.
          IF lwa_tab99 = gc_x1x1.
            lv_str99 = sy-tabix - 1.
            CHECK  lv_str99 > 0.
            READ TABLE lt_tab99 INTO lwa_tab99 INDEX lv_str99.
            IF sy-subrc = 0.
              lwa_sort_tab-table = lwa_tab99.
              REPLACE ALL OCCURRENCES OF gc_bracket IN
              lwa_sort_tab-table WITH
              ''.
              CONDENSE lwa_sort_tab-table.
              APPEND lwa_sort_tab TO gt_sort.
            ENDIF.

          ENDIF.
        ENDLOOP.
      ENDIF.
*==========================
*putting whole source code to global variable
*==========================
      CLEAR: gv_org_code.
      gv_org_code = lwa_code.
*{ Begin of change by Manoj - 21/12/2015
*===============================================
* Logic to find all the sorted tables in the program
*===============================================
      PERFORM f_find_sort_tab_meth USING lv_line_code
                                         pv_str2
                                         lv_index.

*} End of change by Manoj - 21/12/2015
*{ Begin of change by Manoj - 21/12/2015
*===============================================
* Logic to detect unsorted internal table with index
*===============================================
      PERFORM f_detect_itab_index_meth USING lv_line_code
                                              pv_str2
                                        lv_index.

*} End of change by Manoj - 21/12/2015
*==========================
*DO not scan the source code if it is commented or statement
*inside single quotes
*==========================
      CLEAR lv_str1.
      IF lwa_code CS gc_doub_quote.
        CLEAR gv_check_flag.
        PERFORM get_offset_key_single_quote USING
                lwa_code '"'
                CHANGING gv_check_flag.
        IF gv_check_flag IS INITIAL.
          SPLIT lwa_code AT gc_doub_quote INTO lwa_code lv_str1.
        ENDIF.
        CLEAR gv_check_flag.
        CLEAR lv_str1.
      ENDIF.
      IF lwa_code+0(1) EQ gc_doub_quote OR  lwa_code+0(1) = gc_star
      OR lwa_code+0(1) EQ '''' .
        CONTINUE.
      ENDIF.


*==========================
*Check that keyword written inside single quotes
*==========================
      CLEAR gv_check_flag.
      PERFORM get_offset_key_single_quote USING
               lwa_code 'READ TABLE'
               CHANGING gv_check_flag.

*==========================
*Check if statement having READ with BINARY SEARCH but sorting
*is not done on internal table
*==========================
      CLEAR : lv_str1 , lv_str2 .
      IF lwa_code-text CS gc_read_tab AND
         lwa_code-text CS gc_bin_search
         AND  gv_check_flag IS INITIAL .
        lwa_final-line = sy-tabix.
        SPLIT lwa_code-text AT gc_read_tab INTO lv_str1 lv_str2.
        CONDENSE lv_str2.
        SPLIT lv_str2 AT space INTO lv_str1 lv_str2.
        CONDENSE lv_str1.
        lwa_final-itabs = lv_str1.


        CLEAR: gt_f_code, gv_nt_found.
        " start of change : FM to form
*        CALL FUNCTION 'ZAUCT_FIND_STR'
*          EXPORTING
*            p_name       = gv_prog
*            code_string  = lwa_final-itabs
*            line_no      = lwa_final-line
*            p_type       = 'R'
*          IMPORTING
*            lv_not_found = gv_nt_found
*          TABLES
*            it_fcode     = gt_f_code.
*
        PERFORM get_scan TABLES gt_f_code
                        USING gv_prog lwa_final-itabs gc_zero
                        lwa_final-line
                        gc_r ''
                        CHANGING gv_nt_found.

        " End of change : FM to form
* Begin of change by Twara 12/02/2016
        DATA: lwa_sel_t  TYPE t_sort,
              lwa_sel_t1 TYPE t_sort.
* End of change by Twara 12/02/2016
        IF gt_f_code IS INITIAL.
* Begin of change by Twara 12/02/2016
          IF NOT lv_str1 IS INITIAL.
            " find if internal is used in select statements
            READ TABLE gt_sel_t INTO lwa_sel_t WITH KEY table = lv_str1
            BINARY SEARCH.
            IF sy-subrc = 0.
              " find internal is unsorted
              READ TABLE gt_sort_t WITH KEY table = lv_str1
              TRANSPORTING NO FIELDS
              BINARY SEARCH.
              IF sy-subrc <> 0.
* End of change by Twara 12/02/2016
                lwa_final-code  = gv_org_code.
                lwa_final-prog   = gv_prog.
                lwa_final-obj_name = gs_progname-progname.
                lwa_final-opercd = gc_45.
                lwa_final-drill = gv_drill.
* Begin of change by Twara 12/02/2016
                READ TABLE gt_sel_t
                  INTO lwa_sel_t1
                  WITH KEY table = lv_str1
                           prog  = gv_prog
                           sub_prog = gs_progname-progname.
                IF sy-subrc EQ 0.
                  lwa_final-select_line = lwa_sel_t1-line.
                  PERFORM append_opcode21 USING lwa_sel_t-dbtable
                                                lwa_sel_t-table
                                                lwa_sel_t-tab_type
                                                lwa_sel_t-prog
                                                lwa_sel_t-sub_prog
                                                lwa_sel_t-line
                                                lwa_sel_t-select.
                ENDIF.
* End of change by Twara 12/02/2016
                PERFORM append_final USING lwa_final.
* Begin of change by Twara 12/02/2016
                CLEAR: lwa_final.
* End of change by Twara 12/02/2016
              ENDIF.
              CLEAR : gv_nt_found.
* Begin of change by Twara 12/02/2016
            ENDIF.
          ENDIF.
        ENDIF.
* End of change by Twara 12/02/2016
        FREE : gt_f_code.
      ENDIF.

*==========================
*    *Check method -> class
*==========================
      IF lwa_code+0(11) CS gc_call_meth.
        PERFORM read_method USING lwa_code
                                  lv_index.
      ENDIF.

*==========================
*Check if statement used for Aggregation LIKE COLLECT
*==========================
      IF ( lwa_code-text+0(7) = gc_collect ).
        CLEAR lwa_final.
        lwa_final-code      = gv_org_code.
        lwa_final-prog      = gv_prog.
        lwa_final-obj_name  = gs_progname-progname.
        lwa_final-line      = lv_index.
        lwa_final-opercd    = gc_47.
        lwa_final-drill = gv_drill.
        PERFORM append_final USING lwa_final.
        CLEAR lwa_final.
      ENDIF.

*==========================
*  If MACRO - then ignore  the all code inside that
*==========================
      IF lwa_code+0(17) = gc_end_of_def.
        CLEAR lv_flagcs.
      ELSEIF lwa_code+0(6) = gc_define OR lv_flagcs IS NOT INITIAL.
        lv_flagcs = gc_x.
        CONTINUE.
      ENDIF.

*===============================
* Check for Nesting of LOOPS/DO/WHILE
*===============================
      IF gv_drill <= 0.
        CLEAR: gv_drill_max, gv_drill.
      ENDIF.
      CLEAR: lv_str1, lv_str2.
      SPLIT lwa_code AT space INTO lv_str1 lv_str2.
*===============================
* IF LOOPS/DO/WHILE start increase the nesting counter
*===============================

      " start of change: loop and endloop in same line.
      " in this case gv_drill should not increase.
      IF ( lv_str1 = gc_loop OR lv_str1 = gc_do OR  lv_str1 = gc_do_dot
      ).
        REFRESH: lt_drill[].
        CONDENSE lwa_code.
        TRANSLATE lwa_code TO UPPER CASE.
        SPLIT lwa_code AT space INTO TABLE lt_drill.
        REPLACE ALL OCCURRENCES OF gc_dot IN TABLE lt_drill WITH ' '.
        REPLACE ALL OCCURRENCES OF gc_comma IN TABLE lt_drill WITH ' '.
        DELETE lt_drill WHERE text = ''.
        CLEAR: lv_eloop_flag.
        READ TABLE lt_drill WITH KEY text = gc_enddo TRANSPORTING NO
        FIELDS.
        IF sy-subrc = 0.
          lv_eloop_flag = gc_x.
        ENDIF.
        READ TABLE lt_drill WITH KEY text = gc_endwhile TRANSPORTING NO
        FIELDS.
        IF sy-subrc = 0.
          lv_eloop_flag = gc_x.
        ENDIF.
        READ TABLE lt_drill WITH KEY text = gc_endloop TRANSPORTING NO
        FIELDS.
        IF sy-subrc = 0.
          lv_eloop_flag = gc_x.
        ENDIF.
      ENDIF.
      " end of change: loop and endloop in same line.
      " start of change: loop and endloop in same line.
*        IF lv_str1 = 'LOOP' OR lv_str1 = 'DO' OR  lv_str1 = 'DO.'
*          OR lv_str1 = 'WHILE'.
      IF ( lv_str1 = gc_loop OR lv_str1 = gc_do OR  lv_str1 = gc_do_dot
                OR lv_str1 = gc_while ) AND lv_eloop_flag = ''.
        " end of change: loop and endloop in same line.

        IF gv_drill = 0 OR gv_loop_line IS INITIAL.
          gv_loop_line = lv_index.
        ENDIF.
        gv_flag = gc_x.
        gv_drill = gv_drill + 1.
        IF gv_drill > gv_drill_max.
          gv_drill_max = gv_drill_max + 1.
        ENDIF.
*===============================
* IF LOOPS/DO/WHILE ends decrease the nesting counter
*===============================
      ELSEIF lv_str1 CS gc_endloop OR lv_str1 CS gc_enddo
        OR lv_str1 CS gc_endwhile.
        gv_drill = gv_drill - 1.
      ENDIF.
      CLEAR: lv_str1, lv_str2.

*===============================
* IF ENDSELECT is used then decrease the nesting counter
*===============================
      IF lwa_code CS gc_endselect.
        CLEAR lv_flag_quote.
        PERFORM get_quote_keyword USING lwa_code 'ENDSELECT'
                                 CHANGING lv_flag_quote.
        IF lv_flag_quote = gc_x.
          CONTINUE.
        ENDIF.

        IF gv_drill > 0.
          gv_drill = gv_drill - 1.
        ENDIF.

        CLEAR: lwa_final.
        CLEAR: gv_exit.
        CLEAR: gv_flag_e.
        CLEAR : lv_flag1.
      ENDIF.

*===============================
* IF Nesting is present then update the detection table
*===============================
      IF gv_drill = 0  AND gv_drill_max > 1.
        CLEAR: lwa_table.
        lwa_final-line = gv_loop_line.
        lwa_final-prog = gv_prog.
        lwa_final-opercd = gc_32.
        lwa_final-drill = gv_drill_max - 1.
        lwa_final-clas = lv_str1.
        lwa_final-method = lv_str2.
        PERFORM get_crit CHANGING lwa_final.
        lwa_final-obj_name = gs_progname-progname.
        PERFORM append_final USING lwa_final.
        CLEAR: gv_drill_max.
        CLEAR: gv_flag.
        CLEAR: gv_loop_line.
      ENDIF.

*==========================
*  Check for use of OPEN SQL in source code
*==========================
      IF lwa_code+0(8) = gc_exec_sql.
        CLEAR : lwa_final-code.
        lwa_final-code  = lwa_code.
        lwa_final-prog   = gv_prog.
        lwa_final-line = lv_index.
        lwa_final-opercd = gc_11.
        lwa_final-drill = gv_drill.
        lwa_final-obj_name = gs_progname-progname.
        lwa_final-corr = gc_x.
        PERFORM append_final USING lwa_final.
      ENDIF.

*==========================
*Check that keyword written inside single quotes
*==========================
      PERFORM get_offset_key_single_quote USING
               lwa_code 'CALL FUNCTION'
               CHANGING gv_check_flag.

*==========================
*Check for FM "DB_EXISTS_INDEX" and "DD_INDEX_NAME" call in source
*==========================
      IF ( lwa_code CS gc_call_func AND
         ( lwa_code CS gc_db_exist_ind OR
         lwa_code CS gc_dd_ind_name )
        AND  gv_check_flag IS INITIAL ) .
        CLEAR : lwa_final-code.
        lwa_final-code  = lwa_code.
        lwa_final-prog   = gv_prog.
        lwa_final-obj_name = gs_progname-progname.
        lwa_final-line = lv_index.
        lwa_final-opercd = gc_12.
        lwa_final-drill = gv_drill.
        lwa_final-corr = gc_x.
        PERFORM append_final USING lwa_final.
      ENDIF.

*==========================
*Check that keyword written inside single quotes
*==========================
      CLEAR gv_check_flag.
      PERFORM get_offset_key_single_quote USING
               lwa_code 'INCLUDE'
               CHANGING gv_check_flag.

*===============================
*IF INCLUDE is used in the source code then scna that include
*==============================
      IF ( lwa_code+0(7) CS gc_include  AND
        gv_check_flag IS INITIAL )  AND
        NOT ( lwa_code CS gc_include_typ OR
              lwa_code CS gc_iclude_struc ).
        FIND gc_dot IN lwa_code MATCH OFFSET lv_col.
        IF sy-subrc = 0.
          lwa_code = lwa_code(lv_col).
          SPLIT lwa_code AT space INTO lv_str1 lv_str2.
          CLEAR lv_str1.
          REFRESH lt_code[].
          lv_include = lv_str2.
          CLEAR lv_str2.
          IF lv_include+0(1) = gc_z
             OR lv_include+0(1) = gc_y OR
            ( lv_include IN gr_nspace[] AND NOT gr_nspace[] IS INITIAL )
            .                      " 29OCT
            READ REPORT lv_include INTO lt_code.
            IF sy-subrc = 0.
              CLEAR: gv_drill, gv_drill_max.
              lf_include = gc_x.
              CLEAR lv_row.
              PERFORM read_report USING lt_code.

              CLEAR lv_row.
            ENDIF.
          ENDIF.
        ENDIF.
      ENDIF.

*==============================
*Check for use of LDB in the program
*==============================
      IF lwa_code CS 'LDB_PROCESS'.
        SPLIT lwa_code AT space INTO TABLE ldb_code.
        READ TABLE ldb_code INTO lwa_code_ldb
        WITH TABLE KEY text = 'LDBNAME'.
        ldb_index = sy-tabix + 2.
        CLEAR lwa_code_ldb.
        READ TABLE ldb_code INTO lwa_code_ldb INDEX ldb_index.
        SPLIT lwa_code_ldb AT '''' INTO lv_ldb1 lv_ldb2 lv_ldb3.
        gs_ldb-progname = gv_prog.
        gs_ldb-ldbname = lv_ldb2.
        APPEND gs_ldb TO gt_ldb.
        CLEAR :  lwa_code_ldb , lwa_ldb.
        CLEAR : lv_ldb1 , lv_ldb2 , lv_ldb3.
        CLEAR : ldb_index , ldb_code.
      ENDIF.

*==========================
*Rearrange the SELECT statament if it contains JOINS
*==========================
      IF ( lwa_code+0(6) = gc_select OR lwa_code+0(8) = gc_select_str )
        AND lwa_code CS gc_join_spc.
        CLEAR gv_codenew.
        PERFORM check_into USING lwa_code CHANGING lwa_slct gv_codenew.
        lwa_code = lwa_slct.
      ENDIF.

*=================================
*Process the SELECT statement and update detection table
*==================================
      IF lwa_code+0(7) = gc_select_spc OR
         lwa_code+0(11)  = gc_op_cursor.
* start of new logic for SORT
*      perform get_sel_sort using p_code
*                                 lwa_code
*                                 lv_index.
* end of new logic for SORT
*start of change by ashish on 15Oct -- add selection by statement ---
*SELECT SINGLE FOR UPDATE
*        IF lwa_code CS 'SELECT *' OR lwa_code CS 'SELECT SINGLE *' .
        IF lwa_code CS gc_select_str OR lwa_code CS gc_select_sing_str
        OR
        lwa_code CS gc_sel_sing_updt .
*end of change by ashish on 15Oct -- add selection by statement ---
*SELECT SINGLE FOR UPDATE
          PERFORM get_sel_star USING p_code
                              lwa_code
                              lv_index
                         CHANGING gt_intab.


        ENDIF.

        PERFORM get_db_hits USING lwa_code
                                  lv_index
                            CHANGING gt_table
                              lv_flag1.

      ENDIF.

*==========================================
*Check for SORT KEYWORD used in statement
*==========================================
      IF lwa_code+0(4) CS gc_sort.
* start of new logic for SORT
*        PERFORM check_sort USING lwa_code
*                                 lv_index.
        PERFORM find_sort USING lwa_code
                                       lv_index.
* end of new logic for SORT
      ENDIF.

*==========================================
*Check for Use of CURRENCY conversion and DELETE ADJACENT DUPLICATES
* without sorting
*==========================================
      IF lwa_code CS gc_del_adj_dup
      OR ( lwa_code CS gc_call_func AND lwa_code CS gc_curr ).

        PERFORM f_statement USING p_code
                                  lwa_code
                                  lv_index
                                  start_line.

      ENDIF.


      IF ( gv_drill > 0 ) .
*==========================================
*To Trace the UPDATE/DELETE/INSERT/CHECK/EXIT Statement inside loop
*==========================================
        IF (  lwa_code-text+0(7) EQ gc_update_spc
          OR ( lwa_code-text+0(7) EQ gc_modify_spc AND
          NOT ( lwa_code-text CS gc_modify_line OR
          lwa_code-text CS gc_modify_screen ) )
          OR lwa_code-text+0(7)  EQ gc_insert_spc
          OR lwa_code-text+0(7)  EQ gc_delete_spc
          OR lwa_code-text+0(5)  EQ gc_check
          OR lwa_code-text+0(4)  EQ gc_exit ).
          PERFORM f_scan_statement USING lwa_code
                                         lv_index.
*==========================================
*To Trace the BAPI, FM  Used inside the various Loops
*==========================================
        ELSEIF ( lwa_code+0(13) CS gc_call_func
            OR ( lwa_code+0(13) CS gc_call_func AND
                lwa_code CS gc_bapi ) ).
          PERFORM f_scan_bapi USING lwa_code
                                    lv_index.

*==========================================
*To trace the Control Statements use inside the various Loops
*==========================================
        ELSEIF ( lwa_code CS gc_at_new ) OR ( lwa_code CS gc_at_first )
            OR ( lwa_code CS gc_at_endof ) OR ( lwa_code CS gc_at_last )
            OR ( lwa_code CS gc_on_changeof ).
          PERFORM f_scan_control  USING lwa_code
                                    lv_index.
* Start of addition by Manoj on 23/12/2015
          " - control statements in unsorted internal tables
          PERFORM f_ctrl_in_unsorted_itabs_meth USING p_code
                                                      lv_line_code
                                                       pv_str2
                                                         lv_index.
* End of addition by Manoj on 23/12/2015
          " - control statements in unsorted internal tables
        ENDIF.
      ENDIF.

*==============================
*Process the subroutine source code
*==============================
      IF lwa_code+0(7) = gc_perform.
        gv_prog99 = gv_prog.
        PERFORM f_process_perform USING p_code
                                        lwa_code
                                        lv_index.
        gv_prog = gv_prog99.
      ENDIF.
*======================================================
* Detection for DELETE/UPDATE/INSERT/MODIFY for POOL/CLUSTER tables
*======================================================
***Begin of changes by Manoj on 15/12/2015
*      for DB operations on POOL/CLUSTER tables
      PERFORM f_detect_pool_cluster_db_ops
                  USING lv_line_code lv_index.
***End of changes by Manoj on 15/12/2015
*      for DB operations on POOL/CLUSTER tables
*======================================================
* Detection for ADBC
*======================================================
***Begin of changes by Manoj on 30/12/2015
      PERFORM f_detect_adbc
                  USING lv_line_code lv_index.
***End of changes by Manoj on 30/12/2015
    ENDLOOP.

*Catch system exceptions
  ENDCATCH.
  IF sy-subrc <> 0.
    WRITE:/ gc_error , 'Error code:', sy-subrc ,'=>Perform GET_METHOD'.
  ENDIF.
*Catch system exceptions
ENDFORM.                    " GET_METHOD

*&---------------------------------------------------------------------*
*&      Form  ADD_NEW_FIELD
*&---------------------------------------------------------------------*
*      Add Fields
*----------------------------------------------------------------------*
FORM add_new_field.

*Catch system exceptions
  CATCH SYSTEM-EXCEPTIONS arithmetic_errors             = 1
                          create_data_errors            = 2
                          conversion_errors             = 3
                          create_object_errors          = 4
                          data_access_errors            = 5
                          assign_casting_illegal_cast   = 6
                          assign_casting_unknown_type   = 7
                          assign_field_not_in_range     = 8
                          data_offset_too_large         = 9
                          dyn_call_meth_not_implemented = 10
                          export_buffer_no_memory       = 11
                          generate_subpool_dir_full     = 12
                          move_cast_error               = 13
                          perform_program_name_too_long = 14
                          replace_infinite_loop         = 15
                          remote_call_errors            = 16
                          localization_errors           = 17
                          import_mismatch_errors        = 18
                          dynamic_call_method_errors    = 19
                          file_access_errors            = 20
                          OTHERS                        = 99.
*Catch system exceptions

    DATA: var_val_1 TYPE char2,
          var_val2  TYPE i,
          var_val3  TYPE string.


    TYPES: BEGIN OF str1,
             var_val1 TYPE char128,
           END OF str1.

    DATA: lt_split  TYPE STANDARD TABLE OF str1,
          lt_split2 TYPE STANDARD TABLE OF str1,
          lt_split3 TYPE STANDARD TABLE OF str1,
          lt_cmp    TYPE STANDARD TABLE OF str1,
          lt_cmp1   TYPE STANDARD TABLE OF str1,
          wa_split  TYPE                   str1,
          wa_split2 TYPE                   str1,
          wa_split3 TYPE                   str1,
          wa_cmp    TYPE                   str1,
          var_val4  TYPE                   string,
          var_val5  TYPE                   i,
          var_val6  TYPE                   string,
          var_val7  TYPE                   string,
          var_val8  TYPE                   i,
          var_val9  TYPE                   i,
          var_val10 TYPE                   string,
          flag      TYPE                   char1.

    RANGES: r_test FOR tadir-obj_name.
    r_test-sign = gc_i.
    r_test-option = 'EQ'.
    r_test-low = '='.
    APPEND r_test.
    r_test-low = '>'.
    APPEND r_test.
    r_test-low = '<'.
    APPEND r_test.
    r_test-low = '>='.
    APPEND r_test.
    r_test-low = '<='.
    APPEND r_test.
    r_test-low = gc_not_eq.
    APPEND r_test.
    r_test-low = 'EQ'.
    APPEND r_test.
    r_test-low = 'GT'.
    APPEND r_test.
    r_test-low = 'LT'.
    APPEND r_test.
    r_test-low = 'GE'.
    APPEND r_test.
    r_test-low = 'LE'.
    APPEND r_test.
    r_test-low = gc_ne.
    APPEND r_test.

    CLEAR: gt_finaln.

    LOOP AT gt_final99 INTO gs_final.

      SPLIT gs_final-filters AT space INTO TABLE lt_split.

      REFRESH : lt_cmp1 , lt_cmp.

      CLEAR : var_val4 , var_val5, var_val6, wa_cmp,
              wa_split, var_val7.
      DATA: lt_tab4  TYPE TABLE OF ty_code,
            lwa_tab4 TYPE ty_code.
      REFRESH: lt_tab4[].
      SPLIT gs_final-filters AT space INTO TABLE lt_tab4[].
      DELETE lt_tab4 WHERE text = ''.
      READ TABLE lt_tab4 WITH KEY text = gc_or TRANSPORTING NO FIELDS.
      IF sy-subrc = 0.
*      IF gs_final-filters CS 'OR'.  " always use EQ never CS
        LOOP AT lt_split INTO wa_split WHERE var_val1 EQ '='.
          var_val2 = sy-tabix - 1.
          READ TABLE lt_split INTO var_val3 INDEX var_val2.
          wa_cmp-var_val1 = var_val3.
          APPEND wa_cmp TO lt_cmp.
        ENDLOOP.
        DELETE ADJACENT DUPLICATES FROM lt_cmp.
        IF sy-subrc = 0.
          LOOP AT lt_split INTO wa_split WHERE var_val1 EQ '='.
            var_val2 = sy-tabix + 1.
            READ TABLE lt_split INTO var_val3 INDEX var_val2.

            REPLACE ALL OCCURRENCES OF REGEX '''' IN  var_val3
            WITH gc_doub_quote RESPECTING CASE.
            APPEND var_val3 TO lt_cmp.
            IF var_val2 GE 1.
              MODIFY lt_split FROM var_val3 INDEX var_val2.
            ENDIF.
          ENDLOOP.
        ENDIF.
        DESCRIBE TABLE lt_cmp LINES var_val5.
        READ TABLE lt_cmp INTO wa_cmp INDEX 1.
        CONCATENATE gc_seperator wa_cmp gc_colon gc_open_bracket INTO
        var_val4.
        LOOP AT  lt_cmp INTO wa_cmp.
          IF sy-tabix GE 2 AND sy-tabix LE var_val5.
            CONCATENATE wa_cmp gc_or INTO var_val6 SEPARATED BY space.
            APPEND var_val6 TO lt_cmp1.
            CLEAR var_val6.
          ENDIF.
        ENDLOOP.
        CLEAR : var_val5.
        IF lt_cmp1 IS NOT INITIAL.
          DESCRIBE TABLE lt_cmp1 LINES var_val5.
          READ TABLE lt_cmp1 INTO var_val6 INDEX var_val5.
          REPLACE ALL OCCURRENCES OF REGEX gc_or IN  var_val6
          WITH '' RESPECTING CASE.
          IF var_val5 GE 1.
            MODIFY lt_cmp1 FROM var_val6 INDEX var_val5.
          ENDIF.
          CONCATENATE LINES OF lt_cmp1 INTO var_val7 SEPARATED BY space.
          CONCATENATE var_val4 var_val7 gc_close_bracket gc_seperator
          INTO wa_split-var_val1
          SEPARATED BY space.

          gs_final-filtrnew =  wa_split-var_val1.
          REPLACE ALL OCCURRENCES OF REGEX '=' IN
          gs_final-filtrnew WITH 'EQ'  RESPECTING CASE.
          REPLACE ALL OCCURRENCES OF REGEX '>' IN
          gs_final-filtrnew WITH 'GT'  IN CHARACTER MODE.
          REPLACE ALL OCCURRENCES OF REGEX '<' IN
          gs_final-filtrnew WITH 'LT'  IN CHARACTER MODE.
          REPLACE ALL OCCURRENCES OF REGEX '<=' IN
          gs_final-filtrnew WITH 'LE' IN CHARACTER MODE.
          REPLACE ALL OCCURRENCES OF REGEX '>=' IN
          gs_final-filtrnew WITH 'GE' IN CHARACTER MODE.
          REPLACE ALL OCCURRENCES OF REGEX gc_not_eq IN
          gs_final-filtrnew WITH gc_ne IN CHARACTER MODE.
        ENDIF.
      ELSE.
        LOOP AT lt_split INTO wa_split WHERE var_val1 IN r_test.
          IF flag IS INITIAL.
            var_val2 = sy-tabix - 1.
            READ TABLE lt_split INTO var_val3 INDEX var_val2.
            CONCATENATE gc_seperator  var_val3 INTO var_val3.
            IF var_val2 GE 1.
              MODIFY lt_split FROM var_val3 INDEX var_val2.
            ENDIF.
            var_val2 = sy-tabix + 2.
            "why are we placing | in aready |demlimited file--- atul need to answer
            "- commented for test run
*            READ TABLE lt_split INTO var_val3 INDEX var_val2.
*            CONCATENATE  var_val3 '|'  INTO var_val3.
*            if var_val2 GE 1.
*            MODIFY lt_split FROM var_val3 INDEX var_val2.
*            endif.
            flag = gc_x.
          ELSE.
            var_val2 = sy-tabix + 1.
            READ TABLE lt_split INTO var_val3 INDEX var_val2.
            CONCATENATE  var_val3 gc_seperator  INTO var_val3.
            IF var_val2 GE 1.
              MODIFY lt_split FROM var_val3 INDEX var_val2.
            ENDIF.
          ENDIF.
        ENDLOOP.
        CONCATENATE LINES OF lt_split INTO
        wa_split-var_val1 SEPARATED BY space.
        gs_final-filtrnew =  wa_split-var_val1.
        REPLACE ALL OCCURRENCES OF SUBSTRING '=' IN
        gs_final-filtrnew WITH 'EQ'  RESPECTING CASE.
        REPLACE ALL OCCURRENCES OF SUBSTRING '>' IN
        gs_final-filtrnew WITH 'GT'  IN CHARACTER MODE.
        REPLACE ALL OCCURRENCES OF SUBSTRING '<' IN
        gs_final-filtrnew WITH 'LT'  IN CHARACTER MODE.
        REPLACE ALL OCCURRENCES OF SUBSTRING '<=' IN
        gs_final-filtrnew WITH 'LE' IN CHARACTER MODE.
        REPLACE ALL OCCURRENCES OF SUBSTRING '>=' IN
        gs_final-filtrnew WITH 'GE' IN CHARACTER MODE.
        REPLACE ALL OCCURRENCES OF SUBSTRING gc_not_eq IN
        gs_final-filtrnew WITH gc_ne IN CHARACTER MODE.
        REPLACE ALL OCCURRENCES OF SUBSTRING ' AND ' IN
        gs_final-filtrnew WITH '' IN CHARACTER MODE.
        REPLACE ALL OCCURRENCES OF SUBSTRING gc_dot IN
        gs_final-filtrnew WITH  '' IN CHARACTER MODE.
      ENDIF.

      MOVE-CORRESPONDING gs_final TO gs_finaln.
      APPEND gs_finaln TO gt_finaln.

*==========================
*Check for the CLUSTER/POOL table use
*==========================
*      IF gs_final-type CS 'POOL' OR gs_final-type CS 'CLUSTER'.
*      if ( gs_final-type cs 'POOL' or gs_final-type cs 'CLUSTER') and
*         ( gs_final-code ns 'ORDER BY')  .
*        clear : gs_checks .
*        read table gt_checks into gs_checks with key opercd = gc_16.
*        if sy-subrc is initial.
*          gs_final-oper = gs_checks-operation.
*          gs_final-opercd = gs_checks-opercd.
*          gs_final-act_st = gs_checks-act_st.
*          gs_final-critical = gs_checks-critical.
*          move-corresponding gs_final to gs_finaln.
*          append gs_finaln to gt_finaln.
*        endif.
*      endif.

      CLEAR : gs_final, gs_finaln, wa_split, var_val_1, gv_codenew ,
              var_val3, var_val2, flag, lt_split3, wa_split2.
    ENDLOOP.
    CLEAR : flag.

*Catch system exceptions
  ENDCATCH.
  IF sy-subrc <> 0.
    WRITE:/ gc_error , 'Error code:', sy-subrc ,
    '=>Perform ADD_NEW_FIELD'.
  ENDIF.
*Catch system exceptions
ENDFORM.                    " ADD_NEW_FIELD
*&---------------------------------------------------------------------*
*&      Form  CHECK_INTO
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_LWA_CODE  text
*      <--P_LWA_SLCT  text
*----------------------------------------------------------------------*
FORM check_into  USING    p_lwa_code
                 CHANGING p_lwa_slct
                          p_codenew.

*Catch system exceptions
  CATCH SYSTEM-EXCEPTIONS arithmetic_errors             = 1
                          create_data_errors            = 2
                          conversion_errors             = 3
                          create_object_errors          = 4
                          data_access_errors            = 5
                          assign_casting_illegal_cast   = 6
                          assign_casting_unknown_type   = 7
                          assign_field_not_in_range     = 8
                          data_offset_too_large         = 9
                          dyn_call_meth_not_implemented = 10
                          export_buffer_no_memory       = 11
                          generate_subpool_dir_full     = 12
                          move_cast_error               = 13
                          perform_program_name_too_long = 14
                          replace_infinite_loop         = 15
                          remote_call_errors            = 16
                          localization_errors           = 17
                          import_mismatch_errors        = 18
                          dynamic_call_method_errors    = 19
                          file_access_errors            = 20
                          OTHERS                        = 99.
*Catch system exceptions

    TYPES : BEGIN OF slt,
              text(1000) TYPE c,
            END OF slt.

    DATA : lt_slt  TYPE STANDARD TABLE OF slt,
           lt_slt1 TYPE STANDARD TABLE OF slt,
           wa_slt  TYPE                   slt.
    DATA : var_val1 TYPE i,
           var_val2 TYPE i,
           var_val3 TYPE i,
           var_val4 TYPE i.
    DATA : lv_cod TYPE string.
    DATA : lv_cod1 TYPE STANDARD TABLE OF slt.



    SPLIT p_lwa_code AT space INTO TABLE lt_slt.

    READ TABLE lt_slt INTO wa_slt WITH KEY text = gc_into.
    var_val1 = sy-tabix.
    CLEAR : wa_slt.

    READ TABLE lt_slt INTO wa_slt WITH KEY text = gc_join.
    var_val2 = sy-tabix.
    CLEAR : wa_slt.

    IF var_val1 GT var_val2.
      READ TABLE lt_slt INTO wa_slt INDEX 2.
      IF wa_slt-text = gc_single.
        READ TABLE lt_slt TRANSPORTING NO FIELDS
        WITH KEY text = gc_corr.
        IF sy-subrc = 0.
          var_val3 = var_val1 + 4.
        ELSE.
          var_val3 = var_val1 + 1.
        ENDIF.
      ELSE.
        READ TABLE lt_slt TRANSPORTING NO FIELDS
        WITH KEY text = gc_corr.
        IF sy-subrc = 0.
          var_val3 = var_val1 + 5.
        ELSE.
          var_val3 = var_val1 + 2.
        ENDIF.
      ENDIF.
      LOOP AT lt_slt INTO wa_slt FROM var_val1 TO var_val3.
        APPEND wa_slt TO lt_slt1.
        wa_slt = ''.
        MODIFY lt_slt FROM wa_slt.
      ENDLOOP.
      DELETE lt_slt WHERE text = ''.


      var_val3 = var_val2 - 1.
      READ TABLE lt_slt INTO wa_slt WITH KEY text = gc_from.
* Start of change by Manoj on 29/12/2015 - adding check for subrc
      IF sy-subrc = 0.
        var_val4 = sy-tabix.
        INSERT LINES OF lt_slt1 INTO lt_slt INDEX var_val4.
      ENDIF.
* End of change by Manoj on 29/12/2015 - adding check for subrc
      LOOP AT lt_slt INTO wa_slt.
        CONCATENATE lv_cod wa_slt INTO lv_cod SEPARATED BY space.
        CLEAR : wa_slt.
      ENDLOOP.

      CONDENSE lv_cod.

      p_lwa_slct = lv_cod.

    ELSE.
      p_lwa_slct = p_lwa_code.
    ENDIF.

* check join type...
    CLEAR p_codenew.
    LOOP AT lt_slt INTO wa_slt WHERE text = gc_join.
      var_val2 = sy-tabix - 1.
      READ TABLE lt_slt INTO wa_slt INDEX var_val2.
      IF sy-subrc = 0.
        IF wa_slt = gc_outer.
          var_val2 = var_val2 - 1.

          READ TABLE lt_slt INTO wa_slt INDEX var_val2.
          IF sy-subrc = 0 .
            IF wa_slt-text = gc_right.
              IF p_codenew IS INITIAL.
                p_codenew = gc_rig_out_join.
              ELSE.
                CONCATENATE p_codenew gc_rig_out_join INTO
                p_codenew SEPARATED BY gc_seperator.
              ENDIF.
            ELSEIF wa_slt-text = gc_left.
              IF p_codenew IS INITIAL.
                p_codenew =  gc_lef_out_join.
              ELSE.
                CONCATENATE p_codenew gc_lef_out_join INTO
                p_codenew SEPARATED BY gc_seperator.
              ENDIF.

            ENDIF.

          ELSE.
            IF p_codenew IS INITIAL.
              p_codenew = gc_out_join.
            ELSE.
              CONCATENATE p_codenew gc_out_join INTO
              p_codenew SEPARATED BY gc_seperator.
            ENDIF.
          ENDIF.
        ELSE.
          IF p_codenew IS INITIAL.
            p_codenew = gc_in_join.
          ELSE.
            CONCATENATE p_codenew gc_in_join INTO
            p_codenew SEPARATED BY gc_seperator.
          ENDIF.
        ENDIF.
      ENDIF.
    ENDLOOP.
    CLEAR : var_val1 , var_val2, var_val3, var_val4, wa_slt , lv_cod.
    REFRESH : lt_slt1 , lt_slt.

*Catch system exceptions
  ENDCATCH.
  IF sy-subrc <> 0.
    WRITE:/ gc_error , 'Error code:', sy-subrc ,'=>Perform CHECK_INTO'.
  ENDIF.
*Catch system exceptions
ENDFORM.                    " CHECK_INTO

*&---------------------------------------------------------------------*
*&      Form  F_DISPLAY
*&---------------------------------------------------------------------*
*
*----------------------------------------------------------------------*
FORM f_display .

*Catch system exceptions
  CATCH SYSTEM-EXCEPTIONS arithmetic_errors             = 1
                          create_data_errors            = 2
                          conversion_errors             = 3
                          create_object_errors          = 4
                          data_access_errors            = 5
                          assign_casting_illegal_cast   = 6
                          assign_casting_unknown_type   = 7
                          assign_field_not_in_range     = 8
                          data_offset_too_large         = 9
                          dyn_call_meth_not_implemented = 10
                          export_buffer_no_memory       = 11
                          generate_subpool_dir_full     = 12
                          move_cast_error               = 13
                          perform_program_name_too_long = 14
                          replace_infinite_loop         = 15
                          remote_call_errors            = 16
                          localization_errors           = 17
                          import_mismatch_errors        = 18
                          dynamic_call_method_errors    = 19
                          file_access_errors            = 20
                          OTHERS                        = 99.
*Catch system exceptions

    FIELD-SYMBOLS <lwa_final> TYPE ty_final.
    LOOP AT gt_final99 ASSIGNING <lwa_final>.
      CLEAR gs_include.
      READ TABLE gt_include_cls INTO gs_include WITH KEY progname =
      <lwa_final>-prog.
      IF sy-subrc = 0
         AND <lwa_final>-objtyp <> 'IWSV'.  "Added by Akshay for OData_Def_24
        <lwa_final>-objtyp = gs_include-objtyp.
        <lwa_final>-prog  = gs_include-mainprog.
        <lwa_final>-sub_type = gs_include-include.
        "begin of code change for Odata_def_24
        <lwa_final>-odata = gs_include-odata.
        "end of code change for Odata_def_24
      ELSE.
        READ TABLE gt_include_cls INTO gs_include WITH KEY mainprog = <lwa_final>-prog
                                                            odata   = 'A'.
        IF sy-subrc EQ 0 AND <lwa_final>-objtyp <> 'IWSV'.  "Added by Akshay for OData_Def_35.
        ELSE.
          IF <lwa_final>-objtyp <> 'IWSV'.  "Added by Akshay for OData_Def_24
            <lwa_final>-objtyp = gc_prog.
            <lwa_final>-sub_type = 'N/A'.
          ENDIF.
        ENDIF.
      ENDIF.
    ENDLOOP.
    PERFORM add_new_field.
    PERFORM f_save_db.

*free memory as program goes to dump because of memory issues many
*times.
    FREE: gt_final, gt_finaln.

*Catch system exceptions
  ENDCATCH.
  IF sy-subrc <> 0.
    WRITE:/ gc_error , 'Error code:', sy-subrc ,'=>Perform F_DISPLAY'.
  ENDIF.
*Catch system exceptions

ENDFORM.                    " F_DISPLAY

*&---------------------------------------------------------------------*
*&      Form  F_SAVE_DB
*&---------------------------------------------------------------------*
*Update the ZDB_ANALYSIS_V75 table
*----------------------------------------------------------------------*

FORM f_save_db .

  DATA: i_detection TYPE STANDARD TABLE OF zdb_analysis_v75.
  DATA: wa_detection TYPE zdb_analysis_v75.
  DATA:  lwa_tables TYPE ty_tables.
  CLEAR: gv_session_id .
  IF gv_session_id IS INITIAL.
    SELECT MAX( session_id ) FROM zdb_analysis_v75 INTO gv_session_id.
    IF sy-subrc = 0.
      ADD 1 TO gv_session_id.
    ELSE.
      gv_session_id = 1.
    ENDIF.
*{ Begin of change by Rohit - 28/12/2016
*    WRITE: 'Session id saved  : '.
*    WRITE: gv_session_id.
*} End of change by Rohit - 28/12/2016
  ENDIF.

  LOOP AT gt_finaln INTO gs_finaln.
    wa_detection-session_id = gv_session_id.
    wa_detection-obj_name = gs_finaln-obj_name.
    wa_detection-sub_type = gs_finaln-sub_type .
    wa_detection-type = gs_finaln-objtyp.
    wa_detection-sub_program = gs_finaln-prog.
    IF gs_finaln-objtyp = gc_clas.
      CLEAR lwa_tables.
      READ TABLE gt_include_cls INTO lwa_tables
      WITH KEY mainprog = gs_finaln-prog
               include = gs_finaln-sub_type.
      IF sy-subrc = 0.
        wa_detection-read_prog   = lwa_tables-progname.
      ENDIF.
    ELSE.
      wa_detection-read_prog   = gs_finaln-prog.
    ENDIF.
    wa_detection-line_no = gs_finaln-line.
*    wa_detection-operation = gs_finaln-oper.
    wa_detection-opercd = gs_finaln-opercd.
    wa_detection-levels = gs_finaln-drill.
    wa_detection-tables = gs_finaln-table.
    wa_detection-joins = gs_finaln-join.
    wa_detection-table_type = gs_finaln-type.
    wa_detection-fields = gs_finaln-fields.
    wa_detection-filters = gs_finaln-filtrnew.
    wa_detection-join_type = gs_finaln-codenew.
    wa_detection-itab = gs_finaln-itabs.
*    wa_detection-act_st = gs_finaln-act_st.
    wa_detection-wa = gs_finaln-wa.
    wa_detection-loops = gs_finaln-loop.
    wa_detection-keys = gs_finaln-keys.
    wa_detection-code = gs_finaln-code.
    wa_detection-info = gs_finaln-check.
    wa_detection-impact = gs_finaln-critical.
*    wa_detection-correction_scope = gs_finaln-corr.
    wa_detection-where_con = gs_finaln-where_con.
*{ Begin of change by Rohit - 16/12/2016
    "/ Additional field changes to table
    wa_detection-exec_date = sy-datum.
    wa_detection-exec_time = sy-uzeit.
    wa_detection-exec_by = sy-uname.
    wa_detection-tool_version = gc_version.
    "begin of code changes for Odata_def_24.
    wa_detection-odata  = gs_finaln-odata.
    "end of code changes for Odata_def_24
*Begin of change by Twara 12/02/2016
    wa_detection-select_line = gs_finaln-select_line.
*End of change by Twara 12/02/2016
*} End of change by Rohit - 16/12/2016
    APPEND wa_detection TO i_detection.
  ENDLOOP.
  SORT i_detection BY
    session_id
    type
    obj_name
    sub_program
    sub_type
    read_prog
    line_no
    opercd DESCENDING.
  DELETE ADJACENT DUPLICATES FROM i_detection
  COMPARING session_id
            type
            obj_name
            sub_program
            sub_type
            read_prog
            line_no
            opercd.

  TRY.
*{ Begin of change by Rohit - 28/12/2016
*To check generated code and delete from detection table.
      IF p_sc_gp IS INITIAL.
*} End of change by Rohit - 28/12/2016
        PERFORM chck_generated USING i_detection CHANGING
          i_generated.
        LOOP AT i_generated INTO wa_generated.
          DELETE i_detection WHERE read_prog = wa_generated-progname.
        ENDLOOP.
*{ Begin of change by Rohit - 28/12/2016
      ENDIF.
*} End of change by Rohit - 28/12/2016
* To Check sort in complete code rather then few lines
* need to check up with Atul
*loop at i_detection into wa_detection where ( opercd eq 45 or opercd eq
*46 ).
*        perform get_scan tables gt_f_code
*using wa_detection-sub_program wa_detection-itab '0'
*wa_detection-line_no 'R' 'X'
*                 changing gv_nt_found.
*        endloop.

      DATA : lr_sql_excep_1 TYPE REF TO cx_sql_exception.
      DATA : lr_sql_excep_2 TYPE REF TO cx_sy_open_sql_db .
      INSERT zdb_analysis_v75 FROM TABLE i_detection.
*{ Begin of change by Rohit - 28/12/2016
*      COMMIT WORK.
      IF sy-subrc EQ 0.
        COMMIT WORK.
        WRITE: 'Session id saved  : '.
        WRITE: gv_session_id.
      ENDIF.
*} End of change by Rohit - 28/12/2016
    CATCH cx_sql_exception INTO lr_sql_excep_1.
      ROLLBACK WORK.
    CATCH cx_sy_open_sql_db INTO lr_sql_excep_2.
      ROLLBACK WORK.
  ENDTRY.

ENDFORM.                    " F_SAVE_DB

*&---------------------------------------------------------------------*
*&      Form  get_quote_keyword
*&---------------------------------------------------------------------*
* Check KEYWORD written inside single quote
*----------------------------------------------------------------------*
*      -->PV_CODE        Current line source code
*      -->PV_KEYWORD     Keyword
*      <--PV_FLAG_QUOTE  Flag
*----------------------------------------------------------------------*
FORM get_quote_keyword USING pv_code TYPE ty_code
                             pv_keyword TYPE string
                       CHANGING pv_flag_quote TYPE c.

*Catch system exceptions
  CATCH SYSTEM-EXCEPTIONS arithmetic_errors             = 1
                          create_data_errors            = 2
                          conversion_errors             = 3
                          create_object_errors          = 4
                          data_access_errors            = 5
                          assign_casting_illegal_cast   = 6
                          assign_casting_unknown_type   = 7
                          assign_field_not_in_range     = 8
                          data_offset_too_large         = 9
                          dyn_call_meth_not_implemented = 10
                          export_buffer_no_memory       = 11
                          generate_subpool_dir_full     = 12
                          move_cast_error               = 13
                          perform_program_name_too_long = 14
                          replace_infinite_loop         = 15
                          remote_call_errors            = 16
                          localization_errors           = 17
                          import_mismatch_errors        = 18
                          dynamic_call_method_errors    = 19
                          file_access_errors            = 20
                          OTHERS                        = 99.
*Catch system exceptions

    DATA: lt_split TYPE TABLE OF ty_code,
          ls_split TYPE          ty_code.

    pv_flag_quote = gc_x.
    SPLIT pv_code AT space INTO TABLE lt_split.
    READ TABLE lt_split INTO ls_split INDEX 1.
    IF sy-subrc = 0.
      IF ls_split-text+0(1) = ''''.
        pv_flag_quote = gc_x.
      ELSEIF ls_split-text CS pv_keyword.
        CLEAR pv_flag_quote.
      ENDIF.
    ENDIF.

*Catch system exceptions
  ENDCATCH.
  IF sy-subrc <> 0.
    WRITE:/ gc_error , 'Error code:', sy-subrc ,
    '=>Perform GET_QUOTE_KEYWORD'.
  ENDIF.
*Catch system exceptions

ENDFORM.                    " F_SAVE_DB

*&---------------------------------------------------------------------*
*&      Form  INIT_LOAD
*&---------------------------------------------------------------------*
* Initialize some global internal tables
*----------------------------------------------------------------------*
FORM init_load .

*Catch system exceptions
  CATCH SYSTEM-EXCEPTIONS arithmetic_errors             = 1
                          create_data_errors            = 2
                          conversion_errors             = 3
                          create_object_errors          = 4
                          data_access_errors            = 5
                          assign_casting_illegal_cast   = 6
                          assign_casting_unknown_type   = 7
                          assign_field_not_in_range     = 8
                          data_offset_too_large         = 9
                          dyn_call_meth_not_implemented = 10
                          export_buffer_no_memory       = 11
                          generate_subpool_dir_full     = 12
                          move_cast_error               = 13
                          perform_program_name_too_long = 14
                          replace_infinite_loop         = 15
                          remote_call_errors            = 16
                          localization_errors           = 17
                          import_mismatch_errors        = 18
                          dynamic_call_method_errors    = 19
                          file_access_errors            = 20
                          OTHERS                        = 99.
*Catch system exceptions

    CLEAR: gt_checks, gs_checks, gt_dd02l_pc.

    SELECT sqltab tabclass FROM dd02l
           INTO TABLE gt_dd02l_pc
       WHERE as4local = gc_a  AND
            tabclass IN (gc_pool, gc_cluster ).
    IF sy-subrc = 0.
      SORT gt_dd02l_pc BY sqltab tabclass.
      DELETE ADJACENT DUPLICATES FROM gt_dd02l_pc
                                 COMPARING sqltab tabclass.
    ENDIF.


    gs_checks-opercd      =  '11'.
    gs_checks-operation   =  'NATIVE SQL CALL'.
    gs_checks-check       =  'NATIVE SQL'.
    gs_checks-act_st      =  'MANDATORY'.
    gs_checks-subcategory =  'MANDATORY'.
    gs_checks-critical    =  'VERY HIGH'.
    APPEND gs_checks TO gt_checks.

    gs_checks-opercd      =  '12'.
    gs_checks-operation   =  'DDIC FUNCTION MODULE CALL'.
    gs_checks-check       =  'DDIC FUNCTION'.
    gs_checks-act_st      =  'MANDATORY'.
    gs_checks-subcategory =  'MANDATORY'.
    gs_checks-critical    =  gc_medium.
    APPEND gs_checks TO gt_checks.

    gs_checks-opercd      =  '13'.
    gs_checks-operation   =  'DB HINTS USED'.
    gs_checks-check       =  'DB HINTS'.
    gs_checks-act_st      =  'MANDATORY'.
    gs_checks-subcategory =  'MANDATORY'.
    gs_checks-critical    =  gc_medium.
    APPEND gs_checks TO gt_checks.

    gs_checks-opercd      =  '14'.
    gs_checks-operation   =  'USAGE OF SORT - REPLACE BY "ORDER BY "'.
    gs_checks-check       =  'INSTEAD USING SORT ON TABLE USE ORDER BY'.
    gs_checks-act_st      =  'RECOMMENDED TO AVOID DEGRADATION IN HANA'.
    gs_checks-subcategory =  'KEEP UNNECESSARY LOAD AWAY FROM DATABASE'.
    gs_checks-critical    =  gc_high.
    APPEND gs_checks TO gt_checks.

    gs_checks-opercd      =  gc_15.
    gs_checks-operation   =  'ADBC USAGE'.
    gs_checks-check       =  'ADBC CALL'.
    gs_checks-act_st      =  'MANDATORY'.
    gs_checks-subcategory =  'MANDATORY'.
    gs_checks-critical    =  gc_low.
    APPEND gs_checks TO gt_checks.

    gs_checks-opercd      =  '16'.
    gs_checks-operation   =  'POOL/CLUSTER TABLE'.
    gs_checks-check       =  'POOL/CLUSTER TABLE USED'.
    gs_checks-act_st      =  'MANDATORY'.
    gs_checks-subcategory =  'MANDATORY'.
    gs_checks-critical    =  'VERY HIGH'.
    APPEND gs_checks TO gt_checks.

***Begin of changes 15/12/2015 for DB operations on POOL/CLUSTER tables
    gs_checks-opercd      =  gc_17.  "17
    gs_checks-operation   =  'DB operation on TABLE POOL/TABLE CLUSTER'.
    gs_checks-check       =  'SELECT/INSERT/UPDATE/DELETE/MODIFY'.
    gs_checks-act_st      =  'MANDATORY'.
    gs_checks-subcategory =  'MANDATORY'.
    gs_checks-critical    =  'VERY HIGH'.
    INSERT gs_checks INTO TABLE gt_checks.
***End of changes 15/12/2015 for DB operations on POOL/CLUSTER tables

***Begin of changes 22/12/2015 for Unsorted internal table access with
*INDEX
    gs_checks-opercd      =  gc_18.   "18
    gs_checks-operation   =
    'Unsorted internal table is accessed with INDEX'.
    gs_checks-check       =  'READ TABLE/LOOP/DELETE/MODIFY'.
    gs_checks-act_st      =  'RECOMMENDED CORRECTIONS'.
    gs_checks-subcategory =
    'VALIDATING GUARANTEED SORT ON INTERNAL TABLE'.
    gs_checks-critical    =  gc_high.
    INSERT gs_checks INTO TABLE gt_checks.
***End of changes 22/12/2015 for Unsorted internal table access with
*INDEX

***Begin of changes 23/12/2015 for control statements inside loop of
*Unsorted internal table
    gs_checks-opercd      =  gc_19.    "19
    gs_checks-operation   =
    'Control statements used inside loop of Unsorted internal table'.
    gs_checks-check       =
    'AT NEW/AT FIRST/AT END OF/AT LAST/ON CHANGE OF'.
    gs_checks-act_st      =  'RECOMMENDED CORRECTIONS'.
    gs_checks-subcategory =
    'VALIDATING GUARANTEED SORT ON INTERNAL TABLE'.
    gs_checks-critical    =  gc_high.
    INSERT gs_checks INTO TABLE gt_checks.
***End of changes 23/12/2015 for control statements inside loop of
*Unsorted internal table

***Begin of changes by Twara 04/01/2016 for temporary OPCODE
    gs_checks-opercd      =  gc_20.   "20
    gs_checks-operation   =
    'TEMPORARY OPERATION CODE'.
    gs_checks-check       =
    'TEMPORARY OPERATION CODE TO PROCESS CLASS'.
    INSERT gs_checks INTO TABLE gt_checks.
***End of changes by Twara 04/01/2016 for temporary OPCODE

***Begin of changes by Twara 12/02/2016 for SELECT statement
    gs_checks-opercd      =  '21'.   "20
    gs_checks-operation   =
    'SELECT statement for Unsorted Internal Table'.
    gs_checks-check       =
    'SELECT statement for Unsorted Internal Table'.
    INSERT gs_checks INTO TABLE gt_checks.
***End of changes by Twara 12/02/2016 for SELECT statement

    gs_checks-opercd      =  '31'.
    gs_checks-operation   =  'SELECT WITHOUT WHERE CLAUSE'.
    gs_checks-check       =  'NO WHERE CONDITION'.
    gs_checks-act_st      =  'RECOMMENDED ABAP LEVEL HANA OPTIMIZATIONS'
    .
    gs_checks-subcategory =  'KEEP THE RESULT SET SMALL'.
    gs_checks-critical    =  gc_high.
    APPEND gs_checks TO gt_checks.

    gs_checks-opercd      =  '32'.
    gs_checks-operation   =  'NESTED LOOPS'.
    gs_checks-check       =  'LOOP INSIDE LOOP'.
    gs_checks-act_st      =  'DB LEVEL HANA OPTIMIZATION'.
    gs_checks-subcategory =  'MINIMIZE THE AMOUNT OF TRANSFERRED DATA'.
*CHECK GV_DRILL VALUE "IF LEVEL = 1, LOW; IF LEVEL = 2 -  MEDIUM ; IF
*LEVEL >2 - HIGH
    gs_checks-critical    =  'HIGH'.
    APPEND gs_checks TO gt_checks.

    gs_checks-opercd      =  '33'.
    gs_checks-operation   =  'SELECT-ENDSELECT USED'.
    gs_checks-check       =  'SELECT-ENDSELECT'.
    gs_checks-act_st      =  'APPLICATION LEVEL HANA OPTIMIZATION'.
    gs_checks-subcategory =  'MINIMIZE THE AMOUNT OF TRANSFERRED DATA'.
    gs_checks-critical    =  gc_high.
    APPEND gs_checks TO gt_checks.

    gs_checks-opercd      =  '34'.
    gs_checks-operation   =  gc_select_sing_str.
    gs_checks-check       =  gc_select_sing_str.
    gs_checks-act_st      =  'APPLICATION LEVEL HANA OPTIMIZATION'.
    gs_checks-subcategory =  'MINIMIZE THE AMOUNT OF TRANSFERRED DATA'.
    gs_checks-critical    =  gc_high.
    APPEND gs_checks TO gt_checks.

    gs_checks-opercd      =  '35'.
    gs_checks-operation   =  gc_select_str.
    gs_checks-check       =  gc_select_str.
    gs_checks-act_st      =  'APPLICATION LEVEL HANA OPTIMIZATION'.
    gs_checks-subcategory =  'MINIMIZE THE AMOUNT OF TRANSFERRED DATA'.
    gs_checks-critical    =  'VERY HIGH'.
    APPEND gs_checks TO gt_checks.

    gs_checks-opercd      =  '36'.
    gs_checks-operation   =  'SELECT WITH FIELD(S)'.
    gs_checks-check       =  gc_select.
    gs_checks-act_st      =  'APPLICATION LEVEL HANA OPTIMIZATION'.
    gs_checks-subcategory =  'MINIMIZE THE SEARCH OVERHEAD'.
    gs_checks-critical    =  'VERY HIGH'.
    APPEND gs_checks TO gt_checks.

    gs_checks-opercd      =  '37'.
    gs_checks-operation   =  'BYPASS TABLE BUFFER'.
    gs_checks-check       =  'BYPASS TABLE BUFFER'.
    gs_checks-act_st      =  'MANDATORY'.
    gs_checks-subcategory =
    'KEEP UNNECESSARY LOAD AWAY FROM DATABASE'.
    gs_checks-critical    =  gc_medium.
    APPEND gs_checks TO gt_checks.

    gs_checks-opercd      =  '38'.
    gs_checks-operation   =  'REPEATED DATABASE HITS ON TABLE'.
    gs_checks-check       =  'REPEATED DB HITS'.
    gs_checks-act_st      =  'DB LEVEL HANA OPTIMIZATION'.
    gs_checks-subcategory =  'MINIMIZE THE AMOUNT OF TRANSFERRED DATA'.
    gs_checks-critical    =  gc_medium.
    APPEND gs_checks TO gt_checks.

    gs_checks-opercd      =  '39'.
    gs_checks-operation   =  'JOINS ON TABLES IN SELECT STATEMENTS'.
    gs_checks-check       =  gc_join.
    gs_checks-act_st      =  'DB LEVEL HANA OPTIMIZATION'.
    gs_checks-subcategory =  'MINIMIZE THE AMOUNT OF TRANSFERRED DATA'.
*  CHECK JOIN COUNT  VALUE "IF JOIN = 3, MEDIUM; IF JOIN > 3 - HIGH
    gs_checks-critical    =  gc_medium.
    APPEND gs_checks TO gt_checks.

    gs_checks-opercd      =  '40'.
    gs_checks-operation   =  'FOR ALL ENTRIES USED'.
    gs_checks-check       =  'FOR ALL ENTRIES USED'.
    gs_checks-act_st      =  'DB LEVEL HANA OPTIMIZATION'.
    gs_checks-subcategory =  'MINIMIZE THE AMOUNT OF TRANSFERRED DATA'.
    gs_checks-critical    =  gc_medium.
    APPEND gs_checks TO gt_checks.

    gs_checks-opercd      =  '41'.
    gs_checks-operation   =  'NO INITIAL CHECK - FOR ALL ENTRIES'.
    gs_checks-check       =  'NO INITIAL CHECK - FOR ALL ENTRIES'.
    gs_checks-act_st      =  'RECOMMENDED CORRECTIONS'.
    gs_checks-subcategory =  'MINIMIZE THE AMOUNT OF TRANSFERRED DATA'.
    gs_checks-critical    =  'VERY HIGH'.
    APPEND gs_checks TO gt_checks.

    gs_checks-opercd      =  '42'.
    gs_checks-operation   =  'BAPI IN LOOP'.
    gs_checks-check       =  ''.
    gs_checks-act_st      =  'APPLICATION LEVEL HANA OPTIMIZATION'.
    gs_checks-subcategory =  'MINIMIZE THE AMOUNT OF TRANSFERRED DATA'.
* CHECK GV_DRILL VALUE "IF LEVEL = 1 - MEDIUM ; IF LEVEL >1 - HIGH
    gs_checks-critical    =  gc_medium.
    APPEND gs_checks TO gt_checks.

    gs_checks-opercd      =  '43'.
    gs_checks-operation   =  'FM IN LOOP'.
    gs_checks-check       =  ''.
    gs_checks-act_st      =  'APPLICATION LEVEL HANA OPTIMIZATION'.
    gs_checks-subcategory =  'MINIMIZE THE AMOUNT OF TRANSFERRED DATA'.
* CHECK GV_DRILL VALUE "IF LEVEL = 1 - MEDIUM ; IF LEVEL >1 - HIGH
    gs_checks-critical    =  gc_medium.
    APPEND gs_checks TO gt_checks.

    gs_checks-opercd      =  '44'.
    gs_checks-operation   =  'FM USED FOR CURRENCY CONVERSION'.
    gs_checks-check       =  ''.
    gs_checks-act_st      =  'DB LEVEL HANA OPTIMIZATION'.
    gs_checks-subcategory =  'MINIMIZE THE AMOUNT OF TRANSFERRED DATA'.
    gs_checks-critical    =  gc_high.
    APPEND gs_checks TO gt_checks.

    gs_checks-opercd      =  '45'.
    gs_checks-operation   =
    'READ STATEMENT WITH BINARY AND WITHOUT SORTING'.
    gs_checks-check       =  'READ STATEMENT'.
    gs_checks-act_st      =  'MANDATORY'.
    gs_checks-subcategory =  'MINIMIZE THE AMOUNT OF TRANSFERRED DATA'.
    gs_checks-critical    =  gc_high.
    APPEND gs_checks TO gt_checks.

    gs_checks-opercd      =  '46'.
    gs_checks-operation   =
    'DELETE ADJACENT DUPLICATES IS USED WITHOUT SORTING'.
    gs_checks-check       =  ''.
    gs_checks-act_st      =  'RECOMMENDED CORRECTIONS'.
    gs_checks-subcategory =  'MINIMIZE THE AMOUNT OF TRANSFERRED DATA'.
    gs_checks-critical    =  gc_high.
    APPEND gs_checks TO gt_checks.

    gs_checks-opercd      =  '47'.
    gs_checks-operation   =  'AGGREGATION STATEMENT COLLECT'.
    gs_checks-check       =  'COLLECT KEYWORD'.
    gs_checks-act_st      =  'DB LEVEL HANA OPTIMIZATION'.
    gs_checks-subcategory =  'MINIMIZE THE AMOUNT OF TRANSFERRED DATA'.
    gs_checks-critical    =  gc_high.
    APPEND gs_checks TO gt_checks.

    gs_checks-opercd      =  '48'.
    gs_checks-operation   =  'CONTROL STATEMENT INSIDE LOOP'.
    gs_checks-check       =  ''.
    gs_checks-act_st      =  'APPLICATION LEVEL HANA OPTIMIZATION'.
    gs_checks-subcategory =  'MINIMIZE THE AMOUNT OF TRANSFERRED DATA'.
    gs_checks-critical    =  gc_medium.
    APPEND gs_checks TO gt_checks.

    gs_checks-opercd      =  '49'.
    gs_checks-operation   =  'ARRAY OPERATION UPDATE WITHIN A LOOP'.
    gs_checks-check       =  ''.
    gs_checks-act_st      =  'APPLICATION LEVEL HANA OPTIMIZATION'.
    gs_checks-subcategory =  'MINIMIZE THE AMOUNT OF TRANSFERRED DATA'.
    gs_checks-critical    =  gc_high.
    APPEND gs_checks TO gt_checks.

    gs_checks-opercd      =  '50'.
    gs_checks-operation   =  'ARRAY OPERATION INSERT WITHIN A LOOP'.
    gs_checks-check       =  ''.
    gs_checks-act_st      =  'APPLICATION LEVEL HANA OPTIMIZATION'.
    gs_checks-subcategory =  'MINIMIZE THE AMOUNT OF TRANSFERRED DATA'.
    gs_checks-critical    =  gc_high.
    APPEND gs_checks TO gt_checks.

    gs_checks-opercd      =  '51'.
    gs_checks-operation   =  'ARRAY OPERATION MODIFY WITHIN A LOOP'.
    gs_checks-check       =  ''.
    gs_checks-act_st      =  'APPLICATION LEVEL HANA OPTIMIZATION'.
    gs_checks-subcategory =  'MINIMIZE THE AMOUNT OF TRANSFERRED DATA'.
    gs_checks-critical    =  gc_high.
    APPEND gs_checks TO gt_checks.

    gs_checks-opercd      =  '52'.
    gs_checks-operation   =  'ARRAY OPERATION DELETE WITHIN A LOOP'.
    gs_checks-check       =  ''.
    gs_checks-act_st      =  'APPLICATION LEVEL HANA OPTIMIZATION'.
    gs_checks-subcategory =  'MINIMIZE THE AMOUNT OF TRANSFERRED DATA'.
    gs_checks-critical    =  gc_high.
    APPEND gs_checks TO gt_checks.

    gs_checks-opercd      =  '53'.
    gs_checks-operation   =  'CHECK/EXIT IN LOOP'.
    gs_checks-check       =  ''.
    gs_checks-act_st      =  'APPLICATION LEVEL HANA OPTIMIZATION'.
    gs_checks-subcategory =  'KEEP THE RESULT SET SMALL'.
    gs_checks-critical    =  gc_high.
    APPEND gs_checks TO gt_checks.

    gs_checks-opercd      =  '54'.
    gs_checks-operation   =  'LOGICAL DATABASE USED IN AN OBJECT'.
    gs_checks-check       =  'LDB'.
    gs_checks-act_st      =  'APPLICATION LEVEL HANA OPTIMIZATION'.
    gs_checks-subcategory =  'KEEP UNNECESSARY LOAD AWAY FROM DATABASE'.
    gs_checks-critical    =  gc_low.
    APPEND gs_checks TO gt_checks.

    gs_checks-opercd      =  '56'.
    gs_checks-operation   =  'NEGATIVE OPERATION IN WHERE CLAUSE'.
    gs_checks-check       =  'NEGATIVE OPERATION IN WHERE'.
    gs_checks-act_st      =  'APPLICATION LEVEL HANA OPTIMIZATION'.
    gs_checks-subcategory =  'KEEP UNNECESSARY LOAD AWAY FROM DATABASE'.
    gs_checks-critical    =  gc_high.
    APPEND gs_checks TO gt_checks.

    gs_checks-opercd      =  '58'.
    gs_checks-operation   =  'FAE & JOIN'.
    gs_checks-check       =  'FAE & JOIN USED'.
    gs_checks-act_st      =  'DB LEVEL HANA OPTIMIZATION'.
    gs_checks-subcategory =  'MINIMIZE THE AMOUNT OF TRANSFERRED DATA'.
    gs_checks-critical    =  gc_high.
    APPEND gs_checks TO gt_checks.

    "begin of code change for Odata_def_24
    gs_checks-opercd      =  '59'.
    gs_checks-operation   =  'Odata Service Compatability'.
    gs_checks-check       =  'Error in service configurations'.
    gs_checks-act_st      =  'Error in service configurations'.
    gs_checks-subcategory =  'Opportunity for Improvement.'.
    gs_checks-critical    =  gc_high.
    APPEND gs_checks TO gt_checks.

    gs_checks-opercd      =  '60'.
    gs_checks-operation   =  'Odata Service Compatability'.
    gs_checks-check       =  'Error in service configurations'.
    gs_checks-act_st      =  'Error in service configurations.'.
    gs_checks-subcategory =  'Opportunity for Improvement.'.
    gs_checks-critical    =  gc_high.
    APPEND gs_checks TO gt_checks.

    gs_checks-opercd      =  '61'.
    gs_checks-operation   =  'Odata Service Compatability'.
    gs_checks-check       =  'Error in service configurations'.
    gs_checks-act_st      =  'Error in service configurations'.
    gs_checks-subcategory =  'Opportunity for Improvement.'.
    gs_checks-critical    =  gc_high.
    APPEND gs_checks TO gt_checks.

    gs_checks-opercd      =  '71'.
    gs_checks-operation   =  'Odata Service Compatability'.
    gs_checks-check       =  'Error in service configurations'.
    gs_checks-act_st      =  'Error in service configurations'.
    gs_checks-subcategory =  'Opportunity for Improvement.'.
    gs_checks-critical    =  gc_high.
    APPEND gs_checks TO gt_checks.

    gs_checks-opercd      =  '72'.
    gs_checks-operation   =  'Odata Service Compatability'.
    gs_checks-check       =  'SET LABEL MISSING'.
    gs_checks-act_st      =  'Error in service configurations'.
    gs_checks-subcategory =  'Opportunity for Improvement.'.
    gs_checks-critical    =  gc_high.
    APPEND gs_checks TO gt_checks.

    gs_checks-opercd      =  '73'.
    gs_checks-operation   =  'Odata Service Compatability'.
    gs_checks-check       =  'CAMEL CASE'.
    gs_checks-act_st      =  'Error in service configurations'.
    gs_checks-subcategory =  'Opportunity for Improvement.'.
    gs_checks-critical    =  gc_high.
    APPEND gs_checks TO gt_checks.

    gs_checks-opercd      =  '74'.
    gs_checks-operation   =  'Odata Service Compatability'.
    gs_checks-check       =  'DATA TYPE MISMATCH'.
    gs_checks-act_st      =  'Error in service configurations'.
    gs_checks-subcategory =  'Opportunity for Improvement.'.
    gs_checks-critical    =  gc_high.
    APPEND gs_checks TO gt_checks.

* Begin of changes for OData by Akshay_Def_25
    gs_checks-opercd      =  gc_75.
    gs_checks-operation   =  'Odata Service Compatability'.
    gs_checks-check       =  'Error in service configurations'.
    gs_checks-act_st      =  'Error in service configurations'.
    gs_checks-subcategory =  'Opportunity for Improvement.'.
    gs_checks-critical    =  gc_high.
    APPEND gs_checks TO gt_checks.

    gs_checks-opercd      =  gc_76.
    gs_checks-operation   =  'Odata Service Compatability'.
    gs_checks-check       =  'Error in service configurations'.
    gs_checks-act_st      =  'Error in service configurations'.
    gs_checks-subcategory =  'Opportunity for Improvement.'.
    gs_checks-critical    =  gc_high.
    APPEND gs_checks TO gt_checks.
* End of changes for OData by Akshay_Def_25

    gs_checks-opercd      =  '99'.
    gs_checks-operation   =  'TABLE SIZE CATEGORY'.
    gs_checks-check       =  'TABLE SIZE'.
    gs_checks-act_st      =  'SECONDARY DATABASE PERSPECTIVE'.
    gs_checks-subcategory =  'SECONDARY DATABASE PERSPECTIVE'.
    gs_checks-critical    =  gc_low.

    APPEND gs_checks TO gt_checks.
    "end of code change for Odata_def_24
*********Cretae range for the where clause operators
    DATA : lwr_where  LIKE LINE OF gr_where.

    lwr_where-sign = gc_i.
    lwr_where-option = 'EQ'.
    lwr_where-low = 'EQ'.
    APPEND lwr_where TO gr_where.

    lwr_where-low = '='.
    APPEND lwr_where TO gr_where.

    lwr_where-low = 'IN'.
    APPEND lwr_where TO gr_where.

    lwr_where-low = gc_ne.
    APPEND lwr_where TO gr_where.

    lwr_where-low = gc_not_eq.
    APPEND lwr_where TO gr_where.

    lwr_where-low = '><'.
    APPEND lwr_where TO gr_where.

    lwr_where-low = 'GT'.
    APPEND lwr_where TO gr_where.

    lwr_where-low = '>'.
    APPEND lwr_where TO gr_where.

    lwr_where-low = 'GE'.
    APPEND lwr_where TO gr_where.

    lwr_where-low = '>='.
    APPEND lwr_where TO gr_where.

    lwr_where-low = 'LT'.
    APPEND lwr_where TO gr_where.

    lwr_where-low = '<'.
    APPEND lwr_where TO gr_where.

    lwr_where-low = 'LE'.
    APPEND lwr_where TO gr_where.

    lwr_where-low = '<='.
    APPEND lwr_where TO gr_where.

    lwr_where-low = 'LIKE'.
    APPEND lwr_where TO gr_where.

    lwr_where-low = gc_not.  "NOT
    APPEND lwr_where TO gr_where.

    lwr_where-low = gc_between.
    APPEND lwr_where TO gr_where.

*Catch system exceptions
  ENDCATCH.
  IF sy-subrc <> 0.
    WRITE:/ gc_error , 'Error code:', sy-subrc ,'=>Perform INIT_LOAD'.
  ENDIF.
*Catch system exceptions
ENDFORM.                    " INIT_LOAD

*&---------------------------------------------------------------------*
*&      Form  GET_OFFSET_KEY_SINGLE_QUOTE
*&---------------------------------------------------------------------*
* Get offset of single quote
*----------------------------------------------------------------------*
*      -->P_LWA_CODE   Current line source code
*      -->P_KEYWORD    Keyword
*      <--P_CHECK_FLAG Flag
*----------------------------------------------------------------------*
FORM get_offset_key_single_quote  USING    p_lwa_code TYPE ty_code
                                           p_keyword TYPE string
                                  CHANGING p_check_flag TYPE c.

*Catch system exceptions
  CATCH SYSTEM-EXCEPTIONS arithmetic_errors             = 1
                          create_data_errors            = 2
                          conversion_errors             = 3
                          create_object_errors          = 4
                          data_access_errors            = 5
                          assign_casting_illegal_cast   = 6
                          assign_casting_unknown_type   = 7
                          assign_field_not_in_range     = 8
                          data_offset_too_large         = 9
                          dyn_call_meth_not_implemented = 10
                          export_buffer_no_memory       = 11
                          generate_subpool_dir_full     = 12
                          move_cast_error               = 13
                          perform_program_name_too_long = 14
                          replace_infinite_loop         = 15
                          remote_call_errors            = 16
                          localization_errors           = 17
                          import_mismatch_errors        = 18
                          dynamic_call_method_errors    = 19
                          file_access_errors            = 20
                          OTHERS                        = 99.
*Catch system exceptions

    DATA : lv_key_offset   TYPE sy-tabix,
           lv_single_quote TYPE sy-tabix.

    CLEAR : lv_key_offset , lv_single_quote ,
            p_check_flag.
    FIND FIRST OCCURRENCE OF p_keyword IN p_lwa_code
    MATCH OFFSET lv_key_offset .

    FIND FIRST OCCURRENCE OF '''' IN p_lwa_code
    MATCH OFFSET lv_single_quote .

    IF lv_key_offset GT lv_single_quote.
      p_check_flag = gc_x.
    ENDIF.

*Catch system exceptions
  ENDCATCH.
  IF sy-subrc <> 0.
    WRITE:/ gc_error , 'Error code:', sy-subrc ,
           '=>Perform GET_OFFSET_KEY_SINGLE_QUOTE'.
  ENDIF.
*Catch system exceptions
ENDFORM.                    " GET_OFFSET_KEY_SINGLE_QUOTE

*&---------------------------------------------------------------------*
*&      Form  APPEND_FINAL
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_0798   text
*      -->P_LV_INDEX  text
*      -->P_LWA_FINAL_CHECK  text
*----------------------------------------------------------------------*
FORM append_final  USING ps_final.

*Catch system exceptions
  CATCH SYSTEM-EXCEPTIONS arithmetic_errors             = 1
                          create_data_errors            = 2
                          conversion_errors             = 3
                          create_object_errors          = 4
                          data_access_errors            = 5
                          assign_casting_illegal_cast   = 6
                          assign_casting_unknown_type   = 7
                          assign_field_not_in_range     = 8
                          data_offset_too_large         = 9
                          dyn_call_meth_not_implemented = 10
                          export_buffer_no_memory       = 11
                          generate_subpool_dir_full     = 12
                          move_cast_error               = 13
                          perform_program_name_too_long = 14
                          replace_infinite_loop         = 15
                          remote_call_errors            = 16
                          localization_errors           = 17
                          import_mismatch_errors        = 18
                          dynamic_call_method_errors    = 19
                          file_access_errors            = 20
                          OTHERS                        = 99.
*Catch system exceptions

    DATA: ls_check TYPE ty_checks,
          ls_final TYPE ty_final.

    ls_final = ps_final.

    IF ls_final-code IS INITIAL.
      ls_final-code     = gv_org_code.
    ENDIF.
**start of change by ashish 24sep - code field should be empty in case
*- deleted 06oct - ashish  - to keep form simple- now cleared Work area
*at db hit
**of database hit
*  if ls_final-check cs 'database hit'.
*    clear: ls_final-code.
*  endif.
**end of change by ashish 24sep - code field should be empty in case  of
**database hit  - - deleted 06oct - ashish

    IF ls_final-prog IS INITIAL.
      ls_final-prog     = gv_prog.
    ENDIF.

    IF ls_final-obj_name IS INITIAL.
      ls_final-obj_name = gs_progname-progname.
    ENDIF.

    READ TABLE gt_checks INTO ls_check
            WITH KEY opercd = ls_final-opercd
                     BINARY SEARCH.
    IF sy-subrc = 0.
      ls_final-oper     = ls_check-operation.
      ls_final-opercd   = ls_check-opercd.
      ls_final-act_st   = ls_check-act_st.
*    ls_final-subcategory = ls_check-subcategory.
      IF ls_final-critical IS INITIAL.
        ls_final-critical = ls_check-critical.
      ENDIF.

      CLEAR ls_final-critical.

      IF ls_final-check IS INITIAL.
        ls_final-check  = ls_check-check.
      ENDIF.
******def_34 BOC shreeda*******************
    ENDIF.
******def_34 EOC shreeda*******************
    REPLACE ALL OCCURRENCES OF gc_bracket IN ls_final-itabs WITH ''.
    CONDENSE ls_final-itabs.
    APPEND ls_final TO gt_final.
******def_34 BOC shreeda*******************
*ENDIF.
******def_34 EOC shreeda*******************
*Catch system exceptions
  ENDCATCH.
  IF sy-subrc <> 0.
    WRITE:/ gc_error , 'Error code:', sy-subrc ,'=>Perform APPEND_FINAL'
    .
  ENDIF.
*Catch system exceptions
ENDFORM.                    " APPEND_FINAL

*&---------------------------------------------------------------------*
*&      Form  MAIN_PROG
*&---------------------------------------------------------------------*
* Get main programs
*----------------------------------------------------------------------*
FORM main_prog.

*Catch system exceptions
  CATCH SYSTEM-EXCEPTIONS arithmetic_errors             = 1
                          create_data_errors            = 2
                          conversion_errors             = 3
                          create_object_errors          = 4
                          data_access_errors            = 5
                          assign_casting_illegal_cast   = 6
                          assign_casting_unknown_type   = 7
                          assign_field_not_in_range     = 8
                          data_offset_too_large         = 9
                          dyn_call_meth_not_implemented = 10
                          export_buffer_no_memory       = 11
                          generate_subpool_dir_full     = 12
                          move_cast_error               = 13
                          perform_program_name_too_long = 14
                          replace_infinite_loop         = 15
                          remote_call_errors            = 16
                          localization_errors           = 17
                          import_mismatch_errors        = 18
                          dynamic_call_method_errors    = 19
                          file_access_errors            = 20
                          OTHERS                        = 99.
*Catch system exceptions

    LOOP AT gt_include INTO gs_include.
      gs_progname-progname = gs_include-progname.
      APPEND gs_progname TO gt_progname.
    ENDLOOP.
    SORT gt_progname BY progname.
    DELETE ADJACENT DUPLICATES FROM gt_progname COMPARING progname.

*Catch system exceptions
  ENDCATCH.
  IF sy-subrc <> 0.
    WRITE:/ gc_error , 'Error code:', sy-subrc ,'=>Perform MAIN_PROG'.
  ENDIF.
*Catch system exceptions
ENDFORM.                    " MAIN_PROG

*&---------------------------------------------------------------------*
*&      Form  MAIN_PROG_SEL
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*

FORM main_prog_sel .
*Catch system exceptions
  CATCH SYSTEM-EXCEPTIONS arithmetic_errors             = 1
                          create_data_errors            = 2
                          conversion_errors             = 3
                          create_object_errors          = 4
                          data_access_errors            = 5
                          assign_casting_illegal_cast   = 6
                          assign_casting_unknown_type   = 7
                          assign_field_not_in_range     = 8
                          data_offset_too_large         = 9
                          dyn_call_meth_not_implemented = 10
                          export_buffer_no_memory       = 11
                          generate_subpool_dir_full     = 12
                          move_cast_error               = 13
                          perform_program_name_too_long = 14
                          replace_infinite_loop         = 15
                          remote_call_errors            = 16
                          localization_errors           = 17
                          import_mismatch_errors        = 18
                          dynamic_call_method_errors    = 19
                          file_access_errors            = 20
                          OTHERS                        = 99.
*Catch system exceptions

    LOOP AT gt_include INTO gs_include
                WHERE progname = gs_progname-progname
                   OR include = gs_progname-progname.
      gs_progname1-progname = gs_include-progname.
      APPEND gs_progname1 TO gt_progname1.
      CLEAR : gs_progname1.
      gs_progname1-progname = gs_include-include.
      APPEND gs_progname1 TO gt_progname1.
      CLEAR : gs_progname1.
    ENDLOOP.
    CLEAR : gs_progname1.
    SORT gt_progname1 BY progname.
    DELETE ADJACENT DUPLICATES FROM gt_progname1
    COMPARING progname.
    DELETE TABLE gt_progname1 WITH TABLE KEY progname = space.

*Catch system exceptions
  ENDCATCH.
  IF sy-subrc <> 0.
    WRITE:/ gc_error , 'Error code:', sy-subrc ,
    '=>Perform MAIN_PROG_SEL'.
  ENDIF.
*Catch system exceptions
ENDFORM.                    " MAIN_PROG_SEL

*&---------------------------------------------------------------------*
*&      Form  PROGRESS_BAR
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_0038   text
*      -->P_SY_TABIX  text
*      -->P_GV_LINES  text
*----------------------------------------------------------------------*
FORM progress_bar  USING    VALUE(p_0038)
                            p_sy_tabix
                            p_gv_lines.

  DATA: w_text(40),
        w_percentage      TYPE p,
        w_percent_char(5).

  w_percentage = ( p_sy_tabix / p_gv_lines ) * 100.
  w_percent_char = w_percentage.
  SHIFT w_percent_char LEFT DELETING LEADING ' '.
  CONCATENATE p_0038 w_percent_char '% Complete'(002)  INTO w_text.
  IF w_percentage GT gd_percent . "or p_sy_tabix GE 1.
    CALL FUNCTION 'SAPGUI_PROGRESS_INDICATOR'
      EXPORTING
        percentage = w_percentage
        text       = w_text.
    gd_percent = w_percentage.
  ENDIF.

ENDFORM.                    " PROGRESS_BAR
*&---------------------------------------------------------------------*
*&      Form  GET_FIELDS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_LT_FIELDS  text
*      -->P_LV_TABLE  text
*----------------------------------------------------------------------*
FORM get_fields  TABLES   p_lt_fields LIKE gt_fields
                 USING    p_lv_table.

  DATA: lwa_fields TYPE ty_fields.
  SELECT tabname fieldname FROM dd03l INTO TABLE p_lt_fields
    WHERE tabname =  p_lv_table.

ENDFORM.                    " GET_FIELDS
*&---------------------------------------------------------------------*
*&      Form  GET_SCAN
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_GT_T_FOUND  text
*      -->P_GV_PROG  text
*      -->P_LWA_FINAL_ITAB  text
*      -->P_LWA_FINAL_LINE  text
*      -->P_1376   text
*      <--P_GV_NT_FOUND  text
*----------------------------------------------------------------------*
FORM get_scan  TABLES   it_fcode LIKE gt_f_code
               USING    p_name
                        code_string
                        start_line
                        line_no
                        VALUE(p_type)
                        VALUE(s_flag)
               CHANGING lv_nt_found.

*"--------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     REFERENCE(P_NAME) TYPE  PROGNAME
*"     REFERENCE(CODE_STRING) TYPE  STRING
*"     VALUE(START_LINE) TYPE  SY-TABIX OPTIONAL
*"     REFERENCE(LINE_NO) TYPE  SY-TABIX
*"     REFERENCE(P_TYPE) TYPE  C
*"  EXPORTING
*"     REFERENCE(LV_NOT_FOUND) TYPE  C
*"  TABLES
*"      IT_FCODE STRUCTURE  ZCODETAB
*"--------------------------------------------------------------------
*DATA: START_LINE TYPE  SY-TABIX. " OPTIONAL
  DATA : lv_initial TYPE i.
  DATA : lv_end TYPE i.
  DATA : lv_index TYPE sy-tabix,
         lv_row   TYPE i,
         lv_str   TYPE string,
         lv_col   TYPE i,
         wa_fcode TYPE ty_scan.

  TYPES : BEGIN OF t_code,
            text(1000) TYPE c,
          END OF t_code.
  DATA : lv_code TYPE STANDARD TABLE OF t_code,
         wa_code TYPE t_code.
  DATA : code_string_n TYPE string.
  CLEAR: lv_initial, lv_index, lv_row, lv_str, lv_col, wa_fcode, lv_code
  ,
         wa_code.
  DATA : wa_split_str1 TYPE t_code,
         wa_split_str2 TYPE t_code.

**Begin of DEF_5 by Priyanka <24-01-2017>
  TYPES: BEGIN OF lty_descr,
           descr_tab TYPE string,
           int_tab   TYPE string,
           var       TYPE string,
         END OF lty_descr.
  DATA: lt_descr  TYPE STANDARD TABLE OF lty_descr,
        lwa_descr TYPE lty_descr.
**End of DEF_5 by Priyanka <24-01-2017>

  lv_end = line_no - 1.

  READ REPORT p_name INTO lv_code.
  IF start_line = 0 AND s_flag = ''.
    LOOP AT lv_code INTO wa_code FROM start_line TO lv_end.
      IF lv_initial LE lv_end.
        CONDENSE wa_code-text.
        IF wa_code-text = '' OR wa_code-text+0(1) = gc_star OR
wa_code-text+0(1) = gc_doub_quote.
          CONTINUE.
        ENDIF.
        lv_index = sy-tabix.
        IF lv_index LE lv_row.
          CONTINUE.
        ENDIF.
        CONDENSE wa_code.
        TRANSLATE wa_code TO UPPER CASE.
*Concatenate full statement in a line
        CLEAR lv_str.
        PERFORM get_line  USING lv_code
                                lv_index
                          CHANGING lv_str
                                   lv_row.
        wa_code = lv_str.

**Begin of DEF_5 by Priyanka <24-01-2017>
**all the decribe table statments from the program
        PERFORM descr_table_stat USING    wa_code"lv_code
                                 CHANGING lt_descr.
**End of DEF_5 by Priyanka <24-01-2017>


        IF p_type = gc_f.  " F stands for "For all entries"
          IF ( ( wa_code-text CS code_string AND
                 wa_code-text CS 'IF' AND
                 wa_code-text CS 'INITIAL' AND
                 wa_code-text CS 'NOT') ).
            wa_fcode-p_name = p_name.
            wa_fcode-line_no = sy-tabix.
            wa_fcode-code = wa_code-text.
            APPEND wa_fcode TO it_fcode.
          ENDIF.

**Begin of DEF_5 by Priyanka
          READ TABLE lt_descr INTO lwa_descr
                              WITH KEY int_tab = code_string.
          IF sy-subrc EQ 0.
            IF ( wa_code-text CS 'SY-TFILL' ) AND
               ( wa_code-text CS 'IF') AND
               ( wa_code-text CS 'INITIAL') AND
               ( wa_code-text CS 'NOT').
              wa_fcode-p_name = p_name.
              wa_fcode-line_no = sy-tabix.
              wa_fcode-code = wa_code-text.
              APPEND wa_fcode TO it_fcode.
              CLEAR wa_fcode.

            ELSEIF ( wa_code-text CS lwa_descr-var ) AND
                   ( wa_code-text CS 'IF') AND
                   ( wa_code-text CS 'INITIAL') AND
                   ( wa_code-text CS 'NOT').
              wa_fcode-p_name = p_name.
              wa_fcode-line_no = sy-tabix.
              wa_fcode-code = wa_code-text.
              APPEND wa_fcode TO it_fcode.
              CLEAR wa_fcode.

            ELSEIF ( wa_code-text CS lwa_descr-var ) AND
                   ( wa_code-text CS 'IF') AND
                   ( wa_code-text CS '>') AND
                   ( wa_code-text CS '0').
              wa_fcode-p_name = p_name.
              wa_fcode-line_no = sy-tabix.
              wa_fcode-code = wa_code-text.
              APPEND wa_fcode TO it_fcode.
              CLEAR wa_fcode.

            ENDIF.
          ENDIF.
**End of DEF_5 by Priyanka <24-01-2017>

          lv_initial = lv_initial + 1.
        ENDIF.


* New by Atul

        IF p_type = gc_a.  " A stands for searching string for % calc
          CONCATENATE code_string '-' INTO code_string_n.
          CONDENSE code_string_n.
          IF ( wa_code-text CS code_string_n ).
            wa_fcode-p_name = p_name.
            wa_fcode-line_no = sy-tabix.
            wa_fcode-code = wa_code-text.
            APPEND wa_fcode TO it_fcode.
          ENDIF.
          lv_initial = lv_initial + 1.
        ENDIF.
*        End by Atul

        IF p_type = gc_r.  " R stands for "Read Table check"
          IF ( wa_code-text CS code_string AND wa_code-text CS gc_sort )
          .
            wa_fcode-p_name = p_name.
            wa_fcode-line_no = sy-tabix.
            wa_fcode-code = wa_code-text.
            APPEND wa_fcode TO it_fcode.
          ENDIF.
          lv_initial = lv_initial + 1.
        ENDIF.

        IF p_type = 'D'.
          " D stands for "Delete Adjacent duplicates check"
          IF ( wa_code-text CS code_string AND wa_code-text CS gc_sort )
          .
            wa_fcode-p_name = p_name.
            wa_fcode-line_no = sy-tabix.
            wa_fcode-code = wa_code-text.
            APPEND wa_fcode TO it_fcode.
          ENDIF.
          lv_initial = lv_initial + 1.
        ENDIF.
      ELSE.
        EXIT.
      ENDIF.
    ENDLOOP.

  ELSEIF start_line IS NOT INITIAL AND s_flag = ''.

    LOOP AT lv_code INTO wa_code FROM start_line." TO lv_end.
      IF lv_initial LE lv_end.
        CONDENSE wa_code-text.
        IF wa_code-text = '' OR wa_code-text+0(1) = gc_star OR
wa_code-text+0(1) = gc_doub_quote.
          CONTINUE.
        ENDIF.
        lv_index = sy-tabix.
        IF lv_index LE lv_row.
          CONTINUE.
        ENDIF.
        CONDENSE wa_code.
        TRANSLATE wa_code TO UPPER CASE.
*Concatenate full statement in a line
        CLEAR lv_str.
        PERFORM get_line  USING lv_code
                                lv_index
                          CHANGING lv_str
                                   lv_row.
        wa_code = lv_str.

        IF p_type = gc_f.  " F stands for "For all entries"
          IF ( ( wa_code-text CS code_string AND
                 wa_code-text CS 'IF' AND
                 wa_code-text CS 'INITIAL' AND
                 wa_code-text CS 'NOT') ).
            wa_fcode-p_name = p_name.
            wa_fcode-line_no = sy-tabix.
            wa_fcode-code = wa_code-text.
            APPEND wa_fcode TO it_fcode.
          ENDIF.
          lv_initial = lv_initial + 1.
        ENDIF.

        IF p_type = gc_r.  " R stands for "Read Table check"
          IF ( wa_code-text CS code_string AND wa_code-text CS gc_sort )
          .
            wa_fcode-p_name = p_name.
            wa_fcode-line_no = sy-tabix.
            wa_fcode-code = wa_code-text.
            APPEND wa_fcode TO it_fcode.
          ENDIF.
          lv_initial = lv_initial + 1.
        ENDIF.

        IF p_type = 'D'.
          " D stands for "Delete Adjacent duplicates check"
          IF ( wa_code-text CS code_string AND wa_code-text CS gc_sort )
          .
            wa_fcode-p_name = p_name.
            wa_fcode-line_no = sy-tabix.
            wa_fcode-code = wa_code-text.
            APPEND wa_fcode TO it_fcode.
          ENDIF.
          lv_initial = lv_initial + 1.
        ENDIF.

      ELSEIF s_flag = gc_x.

        IF code_string IS NOT INITIAL AND code_string CS gc_seperator.
          SPLIT code_string AT gc_seperator INTO wa_split_str1
          wa_split_str2.
          CONCATENATE gc_sort wa_split_str2 INTO wa_split_str2
          RESPECTING
          BLANKS.
          CONDENSE wa_split_str2.
          TRANSLATE wa_split_str2 TO UPPER CASE.
        ELSE.
          CONCATENATE gc_sort wa_split_str2 INTO wa_split_str2
          RESPECTING
          BLANKS.
          CONDENSE wa_split_str2.
          TRANSLATE wa_split_str2 TO UPPER CASE.
        ENDIF.
        LOOP AT lv_code INTO wa_code." FROM lv_start TO lv_end.
          CONDENSE wa_code-text.
          IF wa_code-text = '' OR wa_code-text+0(1) = gc_star OR
  wa_code-text+0(1) = gc_doub_quote.
            CONTINUE.
          ENDIF.
          lv_index = sy-tabix.
          CONDENSE wa_code.
          TRANSLATE wa_code TO UPPER CASE.
*Concatenate full statement in a line
          CLEAR lv_str.
          PERFORM get_line  USING lv_code
                                  lv_index
                            CHANGING lv_str
                                     lv_row.
          wa_code = lv_str.
          IF wa_code CS wa_split_str2.
            lv_nt_found = gc_x.
          ENDIF.
        ENDLOOP.
      ELSE.
        EXIT.
      ENDIF.
    ENDLOOP.
  ENDIF.
  CLEAR : lv_initial, lv_end.
ENDFORM.                    " GET_SCAN

*-----------------------------------------------------------------
*START-OF-SELECTION Event
*-----------------------------------------------------------------
START-OF-SELECTION.

* changes removed with screen
*if p_r1 = 'X' AND s_prog is INITIAL.
*  MESSAGE 'No Object Selected!' TYPE 'E'.
*endif.
*
*if p_r2 = 'X' AND ( S_name IS INITIAL AND p_cz = '' AND p_cy = '' ).
*  MESSAGE 'No Object Selected!' TYPE 'E'.
*endif.
* changes removed with screen

  CLEAR: gv_exit.
*{ Begin of change by rohit-12/10/2015

  IF  NOT p_pl_cls IS INITIAL
  AND NOT s_table IS INITIAL .
    LOOP AT s_table.
      gwa_pool_clus-tabname = s_table-low.
      gwa_pool_clus-tabclass = gc_pool.
      APPEND gwa_pool_clus TO gt_pool_clus.
    ENDLOOP.
  ENDIF.
  gr_tbclass-sign = 'E'.
  gr_tbclass-option = 'EQ'.
  gr_tbclass-low = gc_pool.
  gr_tbclass-high = ''.
  APPEND gr_tbclass.
  gr_tbclass-sign = 'E'.
  gr_tbclass-option = 'EQ'.
  gr_tbclass-low = gc_cluster.
  gr_tbclass-high = ''.
  APPEND gr_tbclass.
  DELETE gt_pool_clus WHERE tabclass IN gr_tbclass.
*} End of change by rohit-12/10/2015
*Build the Operation Code table and Range or WHERE Clause operators
  PERFORM init_load.

*Get the Programs/Function group/Classes
  PERFORM get_prog.

*Prepare the final table with Main Program names to process
  PERFORM main_prog.

  DESCRIBE TABLE gt_progname LINES gv_lines.
  " ashish 30OCT - progress bar

* Begin of change 13/01/2016 for info in job log
  DATA: lv_messase TYPE string,
        lv_counter TYPE char20,
        lv_count   TYPE sy-tabix.
* End of change 13/01/2016 for info in job log

  LOOP AT gt_progname INTO gs_progname.

* Begin of change 13/01/2016 for info in job log
    CLEAR: lv_messase, lv_counter.
    lv_counter = sy-tabix.
    IF sy-batch IS INITIAL.
* End of change 13/01/2016 for info in job log


      " start of change by ashish 30OCT - progress bar
      PERFORM progress_bar USING 'Executing Record..'(001)
                                 sy-tabix
                                 gv_lines.
      " end of change by ashish 30OCT - progress bar

* Begin of change 13/01/2016 for info in job log
    ELSEIF sy-batch = gc_x.
      CONCATENATE 'Object being scanned is'
                   gs_progname-progname
                  'and counter is'
                  lv_counter
                  INTO lv_messase SEPARATED BY space.
      MESSAGE lv_messase TYPE 'S'.

*  Logic to show progress in SM37.
      "Without this message are not shown in log while job is active.

      lv_count = sy-tabix MOD 300.
      IF lv_count = 0.
        COMMIT WORK.
      ENDIF.
    ENDIF.
* End of change 13/01/2016 for info in job log

    PERFORM main_prog_sel.

*Logic to insert 5 processed program output to detetction table
*    DATA: lv_count TYPE sy-tabix.
*    need to discuss with atul
*    lv_count = sy-tabix mod 5.
*    if lv_count = 0.
*      perform f_display.
*    endif.
*********************************************
    CLEAR:  gt_table, gt_code, gt_intab.

    CALL FUNCTION 'GET_GLOBAL_SYMBOLS'
      EXPORTING
        program   = gs_progname-progname
      TABLES
        fieldlist = gt_fieldlist.

* reda the source code of the object for detetion
    PERFORM f_read_report USING gs_progname-progname.

*clear global structures
    CLEAR: gs_include, gs_progname,gs_incl_processed,
           gs_form_processed, gs_form_lvl_processed.

*clear global variables
    CLEAR: gv_perform, gv_nt_found,
           gv_per_rec , gv_per_rec1 , gv_per_rec2 ,
           gv_per_rec3,gv_prog, gv_drill, gv_flag, gv_flag_d,
           gv_flag_e,gv_codenew,  gv_drill_max.

*clear global internal tables
    CLEAR: gt_fieldlist, gt_table, gt_code, gt_intab,
           gt_form_processed, gt_form_lvl_processed.
    "gt_incl_processed ."code change for def_33

*Free  global internal tables
    FREE:  gt_fieldlist, gt_table, gt_code, gt_intab,
           gt_progname1 ,gt_form_processed,
           gt_form_lvl_processed.
    " gt_incl_processed."code change for def_33

    APPEND LINES OF  gt_final TO gt_final99.
    REFRESH: gt_final[].
*{ Begin of change by Rohit - 16/12/2015
    CLEAR: gt_sort_t,
            gt_sel_t,
            gt_adbc_tab." added by Manoj on 30/12/2015
*} End of change by Rohit - 16/12/2015
  ENDLOOP.

  FREE : gt_incl_processed."code change for def_33

  IF gt_final99 IS NOT INITIAL.
    PERFORM f_display.
  ELSE.
    WRITE:/ 'No records detected'.
  ENDIF.
*-----------------------------------------------------------------
*END-OF-SELECTION Event
*-----------------------------------------------------------------
END-OF-SELECTION.
*&---------------------------------------------------------------------*
*&      Form  CHCK_GENERATED
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_I_DETECTION  text
*      <--P_I_GENERATED  text
*----------------------------------------------------------------------*
FORM chck_generated  USING    p_i_detection LIKE i_gen
                     CHANGING p_i_generated LIKE i_generated.
  DATA: wa_generted TYPE zdb_analysis_v75.

  TYPES: BEGIN OF t_text,
           text(1000),
         END OF t_text.

  DATA: i_text TYPE STANDARD TABLE OF t_text.
  DATA: wa_text TYPE t_text.
  DATA : pl_i_detection TYPE STANDARD TABLE OF zdb_analysis_v75.

  TYPES: BEGIN OF t_prog,
           name TYPE trdir-name,
         END OF t_prog.

  DATA: i_prog  TYPE STANDARD TABLE OF t_prog,
        wa_prog TYPE t_prog,
        lg_flag TYPE flag.

  pl_i_detection[] = p_i_detection[].

  SORT pl_i_detection BY read_prog. " to del additional values
  DELETE ADJACENT DUPLICATES FROM pl_i_detection COMPARING read_prog.
  " to del additional values
  LOOP AT pl_i_detection INTO wa_generted
      WHERE odata = ' '.  "Added by Akshay_def_25
    REFRESH: i_text[].
*read report wa_generted-sub_program into i_text.
    READ REPORT wa_generted-read_prog INTO i_text.
    CLEAR: wa_prog-name.
    CLEAR: lg_flag. " added
    LOOP AT i_text INTO wa_text.
      IF sy-tabix < 7.
        TRANSLATE wa_text TO UPPER CASE.
        CONDENSE wa_text.
        IF wa_text+0(1) = gc_star AND ( wa_text CS 'GENERATED' OR
        wa_text CS
        'generator' OR wa_text CS 'generation' ) .
          lg_flag = gc_x.
        ENDIF.
      ELSE.
        EXIT.
      ENDIF.
    ENDLOOP.
    IF lg_flag = gc_x.
      wa_prog-name  = wa_generted-sub_program.
      APPEND wa_prog  TO i_prog.
    ENDIF.
  ENDLOOP.
  SORT i_prog BY name.
  DELETE ADJACENT DUPLICATES FROM i_prog.
  CLEAR : lg_flag.

  p_i_generated[] = i_prog[].

ENDFORM.                    " CHCK_GENERATED
*&---------------------------------------------------------------------*
*&      Form  GET_SEL_SORT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_P_CODE  text
*      -->P_LWA_CODE  text
*      -->P_LV_INDEX  text
*----------------------------------------------------------------------*
FORM get_sel_sort  USING    p_p_code
                            p_lwa_code
                            p_lv_index.

*Catch system exceptions
  CATCH SYSTEM-EXCEPTIONS arithmetic_errors             = 1
                          create_data_errors            = 2
                          conversion_errors             = 3
                          create_object_errors          = 4
                          data_access_errors            = 5
                          assign_casting_illegal_cast   = 6
                          assign_casting_unknown_type   = 7
                          assign_field_not_in_range     = 8
                          data_offset_too_large         = 9
                          dyn_call_meth_not_implemented = 10
                          export_buffer_no_memory       = 11
                          generate_subpool_dir_full     = 12
                          move_cast_error               = 13
                          perform_program_name_too_long = 14
                          replace_infinite_loop         = 15
                          remote_call_errors            = 16
                          localization_errors           = 17
                          import_mismatch_errors        = 18
                          dynamic_call_method_errors    = 19
                          file_access_errors            = 20
                          OTHERS                        = 99.
*Catch system exceptions


    DATA:      lwa_sort_tab TYPE t_tab_sort.
    DATA: lt_table TYPE TABLE OF ty_code.
    DATA: lv_index TYPE sy-tabix.
    DATA: lwa_table TYPE ty_code.
    REPLACE ALL OCCURRENCES OF gc_open_bracket IN p_lwa_code WITH ''.
    REPLACE ALL OCCURRENCES OF gc_close_bracket IN p_lwa_code WITH ''.
    CONDENSE p_lwa_code.
    TRANSLATE p_lwa_code TO UPPER CASE.

    IF p_lwa_code CS gc_ord_by.

      SPLIT p_lwa_code AT space INTO TABLE lt_table.
      REPLACE ALL OCCURRENCES OF gc_dot IN TABLE lt_table WITH ''.
      REPLACE ALL OCCURRENCES OF gc_comma IN TABLE lt_table WITH ''.
      DELETE lt_table WHERE text = ''.
      READ TABLE lt_table WITH KEY text = gc_table TRANSPORTING NO
      FIELDS
      .
      IF sy-subrc = 0.
        lv_index = sy-index - 1.
        READ TABLE lt_table INTO lwa_table INDEX lv_index.
        lwa_sort_tab-table = lwa_table-text.
        REPLACE ALL OCCURRENCES OF gc_bracket IN lwa_sort_tab-table WITH
        ''.
        CONDENSE lwa_sort_tab-table.
        lwa_sort_tab-line = p_lv_index.
        lwa_sort_tab-prog = gv_prog.
        lwa_sort_tab-obj_name = gs_progname-progname.
        lwa_sort_tab-line =      p_lv_index.
        lwa_sort_tab-drill = gv_drill.
        APPEND lwa_sort_tab TO gt_sort_tab.
      ENDIF.
    ENDIF.

*Catch system exceptions
  ENDCATCH.
  IF sy-subrc <> 0.
    WRITE:/ gc_error , 'Error code:', sy-subrc ,'=>Perform GET_SEL_SORT'
    .
  ENDIF.
*Catch system exceptions
ENDFORM.                    " GET_SEL_SORT
*&---------------------------------------------------------------------*
*&      Form  FIND_SORT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_LWA_CODE  text
*      -->P_LV_INDEX  text
*----------------------------------------------------------------------*
FORM find_sort  USING    p_lwa_code
                         p_lv_index.

*Catch system exceptions
  CATCH SYSTEM-EXCEPTIONS arithmetic_errors             = 1
                          create_data_errors            = 2
                          conversion_errors             = 3
                          create_object_errors          = 4
                          data_access_errors            = 5
                          assign_casting_illegal_cast   = 6
                          assign_casting_unknown_type   = 7
                          assign_field_not_in_range     = 8
                          data_offset_too_large         = 9
                          dyn_call_meth_not_implemented = 10
                          export_buffer_no_memory       = 11
                          generate_subpool_dir_full     = 12
                          move_cast_error               = 13
                          perform_program_name_too_long = 14
                          replace_infinite_loop         = 15
                          remote_call_errors            = 16
                          localization_errors           = 17
                          import_mismatch_errors        = 18
                          dynamic_call_method_errors    = 19
                          file_access_errors            = 20
                          OTHERS                        = 99.
*Catch system exceptions
    DATA:      lwa_sort_tab TYPE t_tab_sort.
    DATA: lt_tab    TYPE TABLE OF ty_code,
          lwa_intab TYPE          ty_intab,
          lwa_final TYPE          ty_final.

    SPLIT p_lwa_code AT space INTO TABLE lt_tab.
    CLEAR p_lwa_code.
    READ TABLE lt_tab INTO p_lwa_code INDEX 2.
    CONDENSE p_lwa_code.
    IF sy-subrc = 0.
      CLEAR: lwa_sort_tab.
      lwa_sort_tab-table = p_lwa_code.
      REPLACE ALL OCCURRENCES OF gc_bracket IN lwa_sort_tab-table WITH
      ''.
      CONDENSE lwa_sort_tab-table.
      lwa_sort_tab-line = p_lv_index.
      lwa_sort_tab-prog = gv_prog.
      lwa_sort_tab-obj_name = gs_progname-progname.
      lwa_sort_tab-line =      p_lv_index.
      lwa_sort_tab-drill = gv_drill.
      APPEND lwa_sort_tab TO gt_sort.
    ENDIF.

*Catch system exceptions
  ENDCATCH.
  IF sy-subrc <> 0.
    WRITE:/ gc_error , 'Error code:', sy-subrc ,'=>Perform FIND_SORT'.
  ENDIF.
*Catch system exceptions
ENDFORM.                    " FIND_SORT
*&---------------------------------------------------------------------*
*&      Form  SORT_RESULT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM sort_result .
*Catch system exceptions
  CATCH SYSTEM-EXCEPTIONS arithmetic_errors             = 1
                          create_data_errors            = 2
                          conversion_errors             = 3
                          create_object_errors          = 4
                          data_access_errors            = 5
                          assign_casting_illegal_cast   = 6
                          assign_casting_unknown_type   = 7
                          assign_field_not_in_range     = 8
                          data_offset_too_large         = 9
                          dyn_call_meth_not_implemented = 10
                          export_buffer_no_memory       = 11
                          generate_subpool_dir_full     = 12
                          move_cast_error               = 13
                          perform_program_name_too_long = 14
                          replace_infinite_loop         = 15
                          remote_call_errors            = 16
                          localization_errors           = 17
                          import_mismatch_errors        = 18
                          dynamic_call_method_errors    = 19
                          file_access_errors            = 20
                          OTHERS                        = 99.
*Catch system exceptions

    DATA:      lwa_sort_tab TYPE t_tab_sort.
    DATA:      lwa_sort_tab1 TYPE t_tab_sort.
    DATA: lwa_final  TYPE                   ty_final.
    DATA: lv_index99 TYPE sy-index.
    SORT gt_sort BY table.
    DELETE ADJACENT DUPLICATES FROM gt_sort COMPARING table.
    IF gt_sort[] IS NOT INITIAL.
      LOOP AT gt_final INTO lwa_final WHERE opercd = 45 OR  opercd = 46
      .
        lv_index99 = sy-tabix.
        TRANSLATE lwa_final-prog TO UPPER CASE.
        TRANSLATE lwa_final-obj_name TO UPPER CASE.
        TRANSLATE lwa_final-itabs TO UPPER CASE.
        REPLACE ALL OCCURRENCES OF gc_bracket IN lwa_final-itabs WITH
        space.
        CONDENSE lwa_final-itabs.
        READ TABLE gt_sort WITH KEY table = lwa_final-itabs TRANSPORTING
        NO FIELDS.
        IF sy-subrc = 0.
        ELSE.
          lwa_final-loop = 'required'.
          MODIFY gt_final FROM lwa_final INDEX lv_index99 .
        ENDIF.

      ENDLOOP.
    ENDIF.

* Start: refresh internal table:-> this is done before new interation.
    REFRESH: gt_sort_tab[], gt_sort[].
* End: refresh internal table:-> this is done before new interation.

*Catch system exceptions
  ENDCATCH.
  IF sy-subrc <> 0.
    WRITE:/ gc_error , 'Error code:', sy-subrc ,'=>Perform SORT_RESULT'.
  ENDIF.
*Catch system exceptions
ENDFORM.                    " SORT_RESULT
*&---------------------------------------------------------------------*
*&      Form  F_DETECT_POOL_CLUSTER_DB_OPS
*&---------------------------------------------------------------------*
*       Detection for POOL/CLUSTER DB operations
*----------------------------------------------------------------------*
*      -->P_LWA_CODE  statement
*      -->P_LV_INDEX  line number
*----------------------------------------------------------------------*
FORM f_detect_pool_cluster_db_ops  USING    p_lwa_code
                                            p_lv_index.
*Catch system exceptions
  CATCH SYSTEM-EXCEPTIONS arithmetic_errors             = 1
                          create_data_errors            = 2
                          conversion_errors             = 3
                          create_object_errors          = 4
                          data_access_errors            = 5
                          assign_casting_illegal_cast   = 6
                          assign_casting_unknown_type   = 7
                          assign_field_not_in_range     = 8
                          data_offset_too_large         = 9
                          dyn_call_meth_not_implemented = 10
                          export_buffer_no_memory       = 11
                          generate_subpool_dir_full     = 12
                          move_cast_error               = 13
                          perform_program_name_too_long = 14
                          replace_infinite_loop         = 15
                          remote_call_errors            = 16
                          localization_errors           = 17
                          import_mismatch_errors        = 18
                          dynamic_call_method_errors    = 19
                          file_access_errors            = 20
                          OTHERS                        = 99.
    DATA: lt_break    TYPE TABLE OF ty_code,
          lwa_break   TYPE ty_code,
          l_str1      TYPE string,
          l_str2      TYPE string,
          l_sql_tab   TYPE char30,
          lwa_final   TYPE ty_final,
          ls_check    TYPE ty_checks,
          l_idx       TYPE i,
* Begin of change by Twara 06/01/2016 to populate TYPE field
          wa_dd02l    TYPE dd02l,
          ls_dd02l_pc TYPE ty_dd02l_pc.
* End of change by Twara 06/01/2016 to populate TYPE field
* Begin of change by Twara 06/01/2015 to populate WHERE field
    DATA: lt_break1   TYPE TABLE OF ty_code,
          lt_break2   TYPE TABLE OF ty_code,
          lwa_break1  TYPE ty_code,
          l_str3      TYPE string,
          lvj_str1    TYPE string,
          lvj_str2    TYPE string,
          lv_leng     TYPE i,
          lv_str2_tmp TYPE string,
          lv_local    TYPE string,
          lv_table    TYPE string,
          lv_stbix    TYPE i.
* End of change by Twara 06/01/2015 to populate WHERE field
* Begin of change by Twara 07/01/2016 to populate FIELDS field
    DATA: lv_from   TYPE i,
          lv_into   TYPE i,
          lv_append TYPE i,
          lv_fields TYPE string.
* End of change by Twara 07/01/2016 to populate FIELDS field

    IF p_lwa_code+0(7) CS gc_delete_spc OR p_lwa_code+0(7) CS
    gc_update_spc
     OR p_lwa_code+0(7) CS gc_insert_spc OR p_lwa_code+0(7) CS
     gc_modify_spc
    OR ( p_lwa_code+0(7) CS gc_select_spc AND p_lwa_code CS gc_from_spc
    ).

      SPLIT p_lwa_code AT space INTO l_str1 l_str2.

***Begin of changes by Twara 18/12/2015
      SPLIT p_lwa_code AT space INTO TABLE lt_break[].
      DELETE lt_break WHERE text IS INITIAL.
      CASE l_str1.
        WHEN gc_select.
          READ TABLE lt_break WITH KEY text = gc_from
          TRANSPORTING NO FIELDS.
          IF sy-subrc = 0.
            l_idx = sy-tabix.
            l_idx = l_idx + 1.
          ENDIF.
          READ TABLE lt_break INTO lwa_break INDEX l_idx.
          l_sql_tab = lwa_break-text.
          lv_table = l_sql_tab.
          READ TABLE lt_break WITH KEY text = gc_into
          TRANSPORTING NO FIELDS.
          IF sy-subrc = 0.
            l_idx = sy-tabix.
          ENDIF.
          CLEAR lwa_break.
          IF p_lwa_code CS gc_into_corr_spc.
            l_idx = l_idx + 5.
            READ TABLE lt_break INTO lwa_break INDEX l_idx.
            IF sy-subrc = 0 AND lwa_final-itabs IS INITIAL.
              REPLACE ALL OCCURRENCES OF gc_dot
                                      IN lwa_break-text WITH space.
              CONDENSE lwa_break-text.
              lwa_final-itabs = lwa_break-text.
            ENDIF.
          ELSEIF p_lwa_code CS gc_into_tab_spc.
            l_idx = l_idx + 2.
            READ TABLE lt_break INTO lwa_break INDEX l_idx.
            IF sy-subrc = 0 AND lwa_final-itabs IS INITIAL.
              REPLACE ALL OCCURRENCES OF gc_dot
                                      IN lwa_break-text WITH space.
              CONDENSE lwa_break-text.
              lwa_final-itabs = lwa_break-text.
            ENDIF.
          ELSEIF p_lwa_code CS gc_into_spc.
            l_idx = l_idx + 1.
            READ TABLE lt_break INTO lwa_break INDEX l_idx.
            IF sy-subrc = 0 AND lwa_final-wa IS INITIAL.
              REPLACE ALL OCCURRENCES OF gc_dot
                                      IN lwa_break-text WITH space.
              CONDENSE lwa_break-text.
              lwa_final-wa = lwa_break-text.
            ENDIF.
          ENDIF.

          READ TABLE lt_break WITH KEY text = gc_app
          TRANSPORTING NO FIELDS.
          IF sy-subrc = 0.
            l_idx = sy-tabix.
          ENDIF.
          CLEAR lwa_break.
          IF p_lwa_code CS gc_app_corr_spc.
            l_idx = l_idx + 5.
            READ TABLE lt_break INTO lwa_break INDEX l_idx.
            IF sy-subrc = 0 AND lwa_final-itabs IS INITIAL.
              REPLACE ALL OCCURRENCES OF gc_dot
                                      IN lwa_break-text WITH space.
              CONDENSE lwa_break-text.
              lwa_final-itabs = lwa_break-text.
            ENDIF.
          ELSEIF p_lwa_code CS gc_app_tab_spc.
            l_idx = l_idx + 2.
            READ TABLE lt_break INTO lwa_break INDEX l_idx.
            IF sy-subrc = 0 AND lwa_final-itabs IS INITIAL.
              REPLACE ALL OCCURRENCES OF gc_dot
                                      IN lwa_break-text WITH space.
              CONDENSE lwa_break-text.
              lwa_final-itabs = lwa_break-text.
            ENDIF.
          ENDIF.

* Begin of change by Twara 07/01/2016 to populate FIELDS field
          IF p_lwa_code CS gc_select_spc AND p_lwa_code CS gc_into_spc.
            FIND FIRST OCCURRENCE OF gc_from IN p_lwa_code
            MATCH OFFSET lv_from.
            FIND FIRST OCCURRENCE OF gc_into IN p_lwa_code
            MATCH OFFSET lv_into.
            IF lv_into LT lv_from AND lv_into GT 0.
              LOOP AT lt_break INTO lwa_break.
                IF lwa_break-text EQ gc_select
                  OR lwa_break-text EQ gc_star
*Start of change DEF_18
                  OR lwa_break-text EQ 'SINGLE'.
*End of change DEF_18
                  CONTINUE.
                ELSEIF lwa_break-text EQ gc_into.
                  EXIT.
                ELSE.
                  CLEAR: lv_local.
                  CONCATENATE lv_table gc_tilde lwa_break-text
                  INTO lv_local.
                  CONCATENATE gc_seperator lv_local lv_fields
                  INTO lv_fields.
                ENDIF.
                CLEAR lv_local.
              ENDLOOP.
              CONDENSE lv_fields.
              lwa_final-fields = lv_fields.
            ELSE.
              LOOP AT lt_break INTO lwa_break.
                IF lwa_break-text EQ gc_select
                  OR lwa_break-text EQ gc_star.
                  CONTINUE.
                ELSEIF lwa_break-text EQ gc_from.
                  EXIT.
                ELSE.
                  CLEAR: lv_local.
                  CONCATENATE lv_table gc_tilde lwa_break-text
                  INTO lv_local.
                  CONCATENATE gc_seperator lv_local lv_fields INTO
                  lv_fields.
                ENDIF.
                CLEAR lv_local.
              ENDLOOP.
              CONDENSE lv_fields.
              lwa_final-fields = lv_fields.
            ENDIF.

          ELSEIF p_lwa_code CS gc_select_spc
            AND p_lwa_code CS gc_app_spc.
            FIND FIRST OCCURRENCE OF gc_from IN p_lwa_code
            MATCH OFFSET lv_from.
            FIND FIRST OCCURRENCE OF gc_app IN p_lwa_code
            MATCH OFFSET lv_append.
            IF lv_append LT lv_from AND lv_append GT 0.
              LOOP AT lt_break INTO lwa_break.
                IF lwa_break-text EQ gc_select
                  OR lwa_break-text EQ gc_star.
                  CONTINUE.
                ELSEIF lwa_break-text EQ gc_app.
                  EXIT.
                ELSE.
                  CLEAR: lv_local.
                  CONCATENATE lv_table gc_tilde lwa_break-text
                  INTO lv_local.
                  CONCATENATE gc_seperator lv_local lv_fields INTO
                  lv_fields.
                ENDIF.
                CLEAR lv_local.
              ENDLOOP.
              CONDENSE lv_fields.
              lwa_final-fields = lv_fields.
            ELSE.
              LOOP AT lt_break INTO lwa_break.
                IF lwa_break-text EQ gc_select
                  OR lwa_break-text EQ gc_star.
                  CONTINUE.
                ELSEIF lwa_break-text EQ gc_from.
                  EXIT.
                ELSE.
                  CLEAR: lv_local.
                  CONCATENATE lv_table gc_tilde lwa_break-text
                  INTO lv_local.
                  CONCATENATE gc_seperator lv_local lv_fields INTO
                  lv_fields.
                ENDIF.
                CLEAR lv_local.
              ENDLOOP.
              CONDENSE lv_fields.
              lwa_final-fields = lv_fields.
            ENDIF.
            CLEAR: lv_fields, lv_from, lv_into, lv_append.
          ENDIF.
* End of change by Twara 07/01/2016 to populate FIELDS field

        WHEN gc_delete.
          IF p_lwa_code CS gc_del_from_spc.
            READ TABLE lt_break INTO lwa_break INDEX 3.
            REPLACE ALL OCCURRENCES OF gc_open_bracket
                                    IN lwa_break-text WITH space.
            REPLACE ALL OCCURRENCES OF gc_close_bracket
                                    IN lwa_break-text WITH space.
            CONDENSE lwa_break-text.
            l_str1 = lwa_break-text.
            l_sql_tab = l_str1.
          ELSE.
            READ TABLE lt_break INTO lwa_break INDEX 2.
            REPLACE ALL OCCURRENCES OF gc_open_bracket
                                    IN lwa_break-text WITH space.
            REPLACE ALL OCCURRENCES OF gc_close_bracket
                                    IN lwa_break-text WITH space.
            REPLACE ALL OCCURRENCES OF gc_star
                                    IN lwa_break-text WITH space.
            CONDENSE lwa_break-text.
            l_str1 = lwa_break-text.
            l_sql_tab = l_str1.
          ENDIF.

        WHEN gc_insert.
          IF p_lwa_code CS gc_insert_into_spc.
            READ TABLE lt_break INTO lwa_break INDEX 3.
            REPLACE ALL OCCURRENCES OF gc_open_bracket
                                    IN lwa_break-text WITH space.
            REPLACE ALL OCCURRENCES OF gc_close_bracket
                                    IN lwa_break-text WITH space.
            CONDENSE lwa_break-text.
            l_str1 = lwa_break-text.
            l_sql_tab = l_str1.
          ELSE.
            READ TABLE lt_break INTO lwa_break INDEX 2.
            REPLACE ALL OCCURRENCES OF gc_open_bracket
                                    IN lwa_break-text WITH space.
            REPLACE ALL OCCURRENCES OF gc_close_bracket
                                    IN lwa_break-text WITH space.
            REPLACE ALL OCCURRENCES OF gc_star
                                    IN lwa_break-text WITH space.
            CONDENSE lwa_break-text.
            l_str1 = lwa_break-text.
            l_sql_tab = l_str1.
          ENDIF.

        WHEN gc_update.
          READ TABLE lt_break INTO lwa_break INDEX 2.
          REPLACE ALL OCCURRENCES OF gc_open_bracket
                                  IN lwa_break-text WITH space.
          REPLACE ALL OCCURRENCES OF gc_close_bracket
                                  IN lwa_break-text WITH space.
          REPLACE ALL OCCURRENCES OF gc_star
                                  IN lwa_break-text WITH space.
          CONDENSE lwa_break-text.
          l_str1 = lwa_break-text.
          l_sql_tab = l_str1.

        WHEN gc_modify.
          READ TABLE lt_break INTO lwa_break INDEX 2.
          REPLACE ALL OCCURRENCES OF gc_open_bracket
                                  IN lwa_break-text WITH space.
          REPLACE ALL OCCURRENCES OF gc_close_bracket
                                  IN lwa_break-text WITH space.
          REPLACE ALL OCCURRENCES OF gc_star
                                  IN lwa_break-text WITH space.
          CONDENSE lwa_break-text.
          l_str1 = lwa_break-text.
          l_sql_tab = l_str1.
      ENDCASE.
***End of changes by Twara 18/12/2015

* Begin of change by Twara 06/01/2015 to populate WHERE field
      lv_table = l_sql_tab.
      LOOP AT lt_break INTO lwa_break.
        TRANSLATE lwa_break-text TO UPPER CASE.
        IF lwa_break-text = gc_where.  "WHERE
          l_idx = sy-tabix.
        ENDIF.
        IF NOT l_idx IS INITIAL.
          CONCATENATE l_str3 lwa_break INTO l_str3
          SEPARATED BY space.
        ENDIF.
      ENDLOOP.
      REPLACE FIRST OCCURRENCE OF gc_where IN l_str3 WITH ''.
      CLEAR: l_idx.
      CONDENSE l_str3.

      CLEAR: lvj_str1, lvj_str2.
      TRANSLATE l_str3 TO UPPER CASE.
      CONDENSE l_str3.

      lvj_str2 = l_str3.

      REFRESH lt_break1[].
      IF lvj_str2 IS NOT INITIAL.
        CLEAR: lv_str2_tmp.
        CLEAR: lv_leng.
        lv_leng = strlen( lvj_str2 ).
        lv_leng = lv_leng - 1.
        IF lvj_str2+lv_leng(1) = gc_dot.
          lv_str2_tmp = lvj_str2+0(lv_leng).
        ELSE.
          lv_str2_tmp = lvj_str2.
        ENDIF.
        SPLIT lv_str2_tmp AT '' INTO TABLE lt_break1.
        DELETE lt_break1[] WHERE text = ''.
        DELETE lt_break1[] WHERE text = gc_and.  "AND
        DELETE lt_break1[] WHERE text = gc_or.   "OR
        DELETE lt_break1[] WHERE text = gc_close_bracket.
        DELETE lt_break1[] WHERE text = gc_open_bracket.
        DELETE lt_break1[] WHERE text = gc_not.  "NOT

        CLEAR: lwa_break1.
        REFRESH: lt_break2[] .

        DATA : lv_sytabix TYPE sy-tabix.
        LOOP AT lt_break1 INTO lwa_break1.
          IF lwa_break1-text IN gr_where[].
            IF lwa_break1-text = gc_between.
              lv_sytabix = 1.
            ENDIF.
            IF lv_sytabix = 1 AND  lwa_break1-text = gc_and.  "AND
              CLEAR lv_sytabix.
              CONTINUE.
            ENDIF.
            CLEAR lwa_break1.
            lv_stbix =  sy-tabix - 1.
            IF lv_stbix GE 1.
              READ TABLE lt_break1 INTO lwa_break1 INDEX lv_stbix.
              IF sy-subrc IS INITIAL.
                APPEND lwa_break1 TO lt_break2.
              ENDIF.
            ENDIF.
            CLEAR : lv_stbix.
          ENDIF.
        ENDLOOP.
        DELETE ADJACENT DUPLICATES FROM lt_break2 COMPARING text.
        LOOP AT lt_break2 INTO lwa_break1.
          CLEAR: lv_local.
          CONCATENATE  lv_table gc_tilde lwa_break1-text INTO lv_local.
          CONCATENATE lvj_str1 lv_local INTO lvj_str1 SEPARATED BY
          gc_seperator.
        ENDLOOP.
      ENDIF.
      lwa_final-where_con = lvj_str1.

* End of change by Twara 06/01/2015 to populate WHERE field

* Begin of change by Twara 06/01/2016 to populate TABLE,TYPE field
*      SELECT COUNT(*)
*      FROM dd02l
*      WHERE sqltab = l_sql_tab
*      AND tabclass IN ( 'POOL' , 'CLUSTER' )
*      AND as4local = 'A'.

* Since the count will be less, the select moved to global to
      "      avoid multiple db hits

*      SELECT SINGLE *
*      FROM dd02l INTO wa_dd02l
*      WHERE sqltab = l_sql_tab
*      AND tabclass IN (gc_pool , gc_cluster)
*      AND as4local = gc_a.
      READ TABLE gt_dd02l_pc INTO ls_dd02l_pc
                             WITH KEY sqltab = l_sql_tab
                             BINARY SEARCH.
      IF sy-subrc = 0.
        lwa_final-type = ls_dd02l_pc-tabclass.
        lwa_final-table = l_sql_tab.
* End of change by Twara 06/01/2016 to populate TABLE,TYPE field
        CLEAR l_idx.
        READ TABLE lt_break WITH KEY text = gc_from
        TRANSPORTING NO FIELDS.
        IF sy-subrc = 0.
          l_idx = sy-tabix.
        ENDIF.
        CLEAR lwa_break.
        IF p_lwa_code CS gc_from_tab_spc AND
          ( p_lwa_code NS gc_select_spc ).
          l_idx = l_idx + 2.
          READ TABLE lt_break INTO lwa_break INDEX l_idx.
          IF sy-subrc = 0 AND lwa_final-itabs IS INITIAL.
            REPLACE ALL OCCURRENCES OF gc_dot
                                IN lwa_break-text WITH space.
            CONDENSE lwa_break-text.
            lwa_final-itabs = lwa_break-text.
          ENDIF.
        ELSEIF p_lwa_code CS gc_from_spc AND
          ( p_lwa_code NS gc_select_spc ).
          l_idx = l_idx + 1.
          READ TABLE lt_break INTO lwa_break INDEX l_idx.
          IF sy-subrc = 0 AND lwa_final-wa IS INITIAL.
            REPLACE ALL OCCURRENCES OF gc_dot
                                IN lwa_break-text WITH space.
            CONDENSE lwa_break-text.
            IF lwa_break-text NE l_sql_tab.
              lwa_final-wa = lwa_break-text.
            ENDIF.
          ENDIF.
        ENDIF.
        READ TABLE lt_break WITH KEY text = gc_values
        TRANSPORTING NO FIELDS.
        IF sy-subrc = 0.
          l_idx = sy-tabix.
          IF p_lwa_code CS gc_insert_into_spc.
            l_idx = l_idx + 1.
            READ TABLE lt_break INTO lwa_break INDEX l_idx.
            IF sy-subrc = 0 AND lwa_final-wa IS INITIAL.
              REPLACE ALL OCCURRENCES OF gc_dot
                                  IN lwa_break-text WITH space.
              CONDENSE lwa_break-text.
              lwa_final-wa = lwa_break-text.
            ENDIF.
          ENDIF.
        ENDIF.
        lwa_final-code = p_lwa_code.
*lwa_final-check = 'DB operation is used in TABLE POOL/TABLE CLUSTER'.
        lwa_final-prog = gv_prog.
        lwa_final-obj_name = gs_progname-progname.
        lwa_final-line = p_lv_index.
        lwa_final-opercd   = gc_17.        "Operation code
        lwa_final-drill = gv_drill.

        PERFORM append_final USING lwa_final.
        CLEAR: lwa_final.
      ENDIF.
    ENDIF.

*Catch system exceptions
  ENDCATCH.
  IF sy-subrc <> 0.
    WRITE:/ gc_error , 'Error code:',
    sy-subrc ,'=>Perform F_DETECT_POOL_CLUSTER_DB_OPS'.
  ENDIF.

ENDFORM.                    " F_DETECT_POOL_CLUSTER_DB_OPS
*&---------------------------------------------------------------------*
*&      Form  F_FIND_SORTED_TABLE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_LWA_CODE  text
*      -->P_LV_INDEX  text
*----------------------------------------------------------------------*
FORM f_find_sorted_table  USING    lwa_code
                                   lv_index.
*Catch system exceptions
  CATCH SYSTEM-EXCEPTIONS arithmetic_errors             = 1
                          create_data_errors            = 2
                          conversion_errors             = 3
                          create_object_errors          = 4
                          data_access_errors            = 5
                          assign_casting_illegal_cast   = 6
                          assign_casting_unknown_type   = 7
                          assign_field_not_in_range     = 8
                          data_offset_too_large         = 9
                          dyn_call_meth_not_implemented = 10
                          export_buffer_no_memory       = 11
                          generate_subpool_dir_full     = 12
                          move_cast_error               = 13
                          perform_program_name_too_long = 14
                          replace_infinite_loop         = 15
                          remote_call_errors            = 16
                          localization_errors           = 17
                          import_mismatch_errors        = 18
                          dynamic_call_method_errors    = 19
                          file_access_errors            = 20
                          OTHERS                        = 99.
*Catch system exceptions
    " Find Type Sorted OF/ Like SORTED OF
    DATA: lwa_sort_tab TYPE t_sort.
    DATA: lv_str99 TYPE string,
          lv_str   TYPE string.
    DATA: lt_tab99  TYPE TABLE OF ty_code,
          lwa_tab99 TYPE ty_code.
    DATA : lv_check TYPE c.
    REFRESH lt_tab99[].
    CLEAR: lv_str99.
    lv_str99 = lwa_code.
    CONDENSE lv_str99.

    IF lv_str99 CS gc_type_sort_tab
    OR lv_str99 CS gc_like_sort_tab.
      REPLACE ALL OCCURRENCES OF gc_type_sort_tab
                              IN lv_str99 WITH gc_x1x1.
      REPLACE ALL OCCURRENCES OF gc_like_sort_tab
                              IN lv_str99 WITH gc_x1x1.
      SPLIT lv_str99 AT '' INTO TABLE lt_tab99.
      DELETE lt_tab99 WHERE text IS INITIAL.
      LOOP AT lt_tab99 INTO lwa_tab99.
        IF lwa_tab99 = gc_x1x1.
          lv_str99 = sy-tabix - 1.
          CHECK  lv_str99 > 0.
          READ TABLE lt_tab99 INTO lwa_tab99 INDEX lv_str99.
          IF sy-subrc = 0.
            lwa_sort_tab-table = lwa_tab99.
            REPLACE ALL OCCURRENCES OF gc_bracket
                                    IN lwa_sort_tab-table WITH ''.
            CONDENSE lwa_sort_tab-table.
            APPEND lwa_sort_tab TO gt_sort_t.
          ENDIF.
        ENDIF.
      ENDLOOP.
    ENDIF.

    " Find Order By Clause in SELECT
    IF lwa_code+0(7) EQ gc_select_spc
    AND lwa_code CS gc_from_spc
    AND lwa_code CS gc_ord_by_spc.
      lv_str99 = lwa_code.

* Begin of change by Twara 11/01/2016
      CLEAR lv_check.
      IF lv_str99 CS gc_into_tab_spc.
        lv_check = gc_x.
        SPLIT lv_str99 AT gc_into_tab_spc INTO lv_str99 lv_str.
      ELSEIF lv_str99 CS gc_into_corr.
        lv_check = gc_x.
        SPLIT lv_str99 AT gc_into_corr
                      INTO lv_str99 lv_str.
      ELSEIF lv_str99 CS gc_app_tab.
        lv_check = gc_x.
        SPLIT lv_str99 AT gc_app_tab INTO lv_str99 lv_str.
      ELSEIF lv_str99 CS gc_app_corr.
        lv_check = gc_x.
        SPLIT lv_str99 AT gc_app_corr
                      INTO lv_str99 lv_str.
      ENDIF.
      IF NOT lv_check IS INITIAL.
        CONDENSE lv_str.
        SPLIT lv_str AT space INTO lv_str99 lv_str.
        lwa_sort_tab-table = lv_str99.
        SPLIT lwa_sort_tab-table AT gc_op_bracket
                                INTO lwa_sort_tab-table lv_str99.
        CONDENSE lwa_sort_tab-table.
        APPEND lwa_sort_tab TO gt_sort_t.
      ENDIF.
    ENDIF.
* End of change by Twara 11/01/2016

    " Find Sort statement on internal table
    IF lwa_code+0(4) EQ gc_sort.
      lv_str99 = lwa_code.
      SPLIT lv_str99 AT space INTO lv_str99 lv_str.
      CONDENSE lv_str.
      SPLIT lv_str AT space INTO lv_str99 lv_str.
      lwa_sort_tab-table = lv_str99.
      SPLIT lwa_sort_tab-table AT gc_op_bracket
                              INTO lwa_sort_tab-table lv_str99.
      CONDENSE lwa_sort_tab-table.
      APPEND lwa_sort_tab TO gt_sort_t.
    ENDIF.
    SORT gt_sort_t
      BY table.
    DELETE ADJACENT DUPLICATES FROM gt_sort_t.
*Catch system exceptions
  ENDCATCH.
  IF sy-subrc <> 0.
    WRITE:/ gc_error , 'Error code:', sy-subrc ,
    '=>Perform F_FIND_SORTED_TABLE'.
  ENDIF.
*Catch system exceptions
ENDFORM.                    " F_FIND_SORTED_TABLE
*&---------------------------------------------------------------------*
*&      Form  F_FIND_SORT_TAB_FORM
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->lwa_code  text
*      -->p_subroutine  text
*      -->LV_INDEX  text
*----------------------------------------------------------------------*
FORM f_find_sort_tab_form  USING    lwa_code
                                    p_subroutine
                                    lv_index.
*Catch system exceptions
  CATCH SYSTEM-EXCEPTIONS arithmetic_errors             = 1
                          create_data_errors            = 2
                          conversion_errors             = 3
                          create_object_errors          = 4
                          data_access_errors            = 5
                          assign_casting_illegal_cast   = 6
                          assign_casting_unknown_type   = 7
                          assign_field_not_in_range     = 8
                          data_offset_too_large         = 9
                          dyn_call_meth_not_implemented = 10
                          export_buffer_no_memory       = 11
                          generate_subpool_dir_full     = 12
                          move_cast_error               = 13
                          perform_program_name_too_long = 14
                          replace_infinite_loop         = 15
                          remote_call_errors            = 16
                          localization_errors           = 17
                          import_mismatch_errors        = 18
                          dynamic_call_method_errors    = 19
                          file_access_errors            = 20
                          OTHERS                        = 99.
*Catch system exceptions
    " Find Type Sorted OF/ Like SORTED OF
    DATA: lwa_sort_tab TYPE t_sort1,
          lwa_sort_t   TYPE t_sort.
    DATA: lv_str99 TYPE string,
          lv_str   TYPE string.
    DATA: lt_tab99  TYPE TABLE OF ty_code,
          lwa_tab99 TYPE ty_code.
    DATA: lv_check TYPE c.
    REFRESH lt_tab99[].
    CLEAR: lv_str99.
    lv_str99 = lwa_code.
    CONDENSE lv_str99.
    IF lv_str99 CS gc_type_sort_tab
    OR lv_str99 CS gc_like_sort_tab.
      REPLACE ALL OCCURRENCES OF gc_type_sort_tab
                              IN lv_str99 WITH gc_x1x1.
      REPLACE ALL OCCURRENCES OF gc_like_sort_tab
                              IN lv_str99 WITH gc_x1x1.
      SPLIT lv_str99 AT '' INTO TABLE lt_tab99.
      DELETE lt_tab99 WHERE text IS INITIAL.
      LOOP AT lt_tab99 INTO lwa_tab99.
        IF lwa_tab99 = gc_x1x1.
          lv_str99 = sy-tabix - 1.
          CHECK  lv_str99 > 0.
          READ TABLE lt_tab99 INTO lwa_tab99 INDEX lv_str99.
          IF sy-subrc = 0.
            lwa_sort_tab-table = lwa_tab99.
            lwa_sort_tab-routine = p_subroutine.
            REPLACE ALL OCCURRENCES OF gc_bracket
                                    IN lwa_sort_tab-table WITH ''.
            CONDENSE lwa_sort_tab-table.

            APPEND lwa_sort_tab TO gt_sort_f.
          ENDIF.
        ENDIF.
      ENDLOOP.
    ELSEIF lv_str99 CS gc_type_tab
    OR lv_str99 CS gc_type_std_tab
    OR lv_str99 CS gc_like_std_tab
    OR lv_str99 CS gc_like_tab.
      "/ Getting table declarations in form
      REPLACE ALL OCCURRENCES OF gc_type_tab
                              IN lv_str99 WITH gc_x1x1.
      REPLACE ALL OCCURRENCES OF gc_type_std_tab
                              IN lv_str99 WITH gc_x1x1.
      REPLACE ALL OCCURRENCES OF gc_like_std_tab
                              IN lv_str99 WITH gc_x1x1.
      REPLACE ALL OCCURRENCES OF gc_like_tab
                              IN lv_str99 WITH gc_x1x1.
      SPLIT lv_str99 AT '' INTO TABLE lt_tab99.
      DELETE lt_tab99 WHERE text IS INITIAL.
      LOOP AT lt_tab99 INTO lwa_tab99.
        IF lwa_tab99 = gc_x1x1.
          lv_str99 = sy-tabix - 1.
          CHECK  lv_str99 > 0.
          READ TABLE lt_tab99 INTO lwa_tab99 INDEX lv_str99.
          IF sy-subrc = 0.
            lwa_sort_tab-table = lwa_tab99.
            lwa_sort_tab-routine = p_subroutine.
            REPLACE ALL OCCURRENCES OF gc_bracket
                                    IN lwa_sort_tab-table WITH ''.
            CONDENSE lwa_sort_tab-table.
            APPEND lwa_sort_tab TO gt_form_tab.
          ENDIF.
        ENDIF.
      ENDLOOP.
    ENDIF.

    " Find Order By Clause in SELECT
    IF lwa_code+0(7) EQ gc_select_spc
    AND lwa_code CS gc_from_spc
    AND lwa_code CS gc_ord_by_spc.
      lv_str99 = lwa_code.

* Begin of change by Twara 11/01/2016
      CLEAR lv_check.
      IF lv_str99 CS gc_into_tab_spc.
        lv_check = gc_x.
        SPLIT lv_str99 AT gc_into_tab_spc INTO lv_str99 lv_str.
      ELSEIF lv_str99 CS gc_into_corr.
        lv_check = gc_x.
        SPLIT lv_str99 AT gc_into_corr
                      INTO lv_str99 lv_str.
      ELSEIF lv_str99 CS gc_app_tab.
        lv_check = gc_x.
        SPLIT lv_str99 AT gc_app_tab INTO lv_str99 lv_str.
      ELSEIF lv_str99 CS gc_app_corr.
        lv_check = gc_x.
        SPLIT lv_str99 AT gc_app_corr
                      INTO lv_str99 lv_str.
      ENDIF.
      IF NOT lv_check IS INITIAL.
        CONDENSE lv_str.
        SPLIT lv_str AT space INTO lv_str99 lv_str.
        lwa_sort_tab-table = lv_str99.
        SPLIT lwa_sort_tab-table AT gc_op_bracket
                                INTO lwa_sort_tab-table lv_str99.
        CONDENSE lwa_sort_tab-table.
        READ TABLE gt_form_tab
          TRANSPORTING NO FIELDS
          WITH KEY table = lwa_sort_tab-table
                   routine = p_subroutine.
        IF sy-subrc EQ 0.
          lwa_sort_tab-routine = p_subroutine.
          APPEND lwa_sort_tab TO gt_sort_f.
        ELSE.
          lwa_sort_t-table = lwa_sort_tab-table.
          APPEND lwa_sort_t TO gt_sort_t.
        ENDIF.
      ENDIF.
    ENDIF.
* End of change by Twara 11/01/2016

    " Find Sort statement on internal table
    IF lwa_code+0(5) EQ gc_sort_spc.
      lv_str99 = lwa_code.
      SPLIT lv_str99 AT space INTO lv_str99 lv_str.
      CONDENSE lv_str.
      SPLIT lv_str AT space INTO lv_str99 lv_str.
      lwa_sort_tab-table = lv_str99.
      SPLIT lwa_sort_tab-table AT gc_op_bracket
                               INTO lwa_sort_tab-table lv_str99.
      CONDENSE lwa_sort_tab-table.
      READ TABLE gt_form_tab
          TRANSPORTING NO FIELDS
          WITH KEY table = lwa_sort_tab-table
                   routine = p_subroutine.
      IF sy-subrc EQ 0.
        lwa_sort_tab-routine = p_subroutine.
        APPEND lwa_sort_tab TO gt_sort_f.
      ELSE.
        lwa_sort_t-table = lwa_sort_tab-table.
        APPEND lwa_sort_t TO gt_sort_t.
      ENDIF.
    ENDIF.
    SORT gt_sort_t
      BY table.
    DELETE ADJACENT DUPLICATES FROM gt_sort_t.
    SORT gt_sort_f
      BY table
         routine.
    DELETE ADJACENT DUPLICATES FROM gt_sort_f.
*Catch system exceptions
  ENDCATCH.
  IF sy-subrc <> 0.
    WRITE:/ gc_error , 'Error code:', sy-subrc ,
    '=>Perform F_FIND_SORT_TAB_FORM'.
  ENDIF.
*Catch system exceptions
ENDFORM.                    " F_FIND_SORT_TAB_FORM
*&---------------------------------------------------------------------*
*&      Form  F_FIND_SORT_TAB_METH
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_lv_line_code  text
*      -->P_P_METHOD  text
*      -->P_LV_INDEX  text
*----------------------------------------------------------------------*
FORM f_find_sort_tab_meth  USING    lwa_code
                                    p_method
                                    lv_index.
*Catch system exceptions
  CATCH SYSTEM-EXCEPTIONS arithmetic_errors             = 1
                          create_data_errors            = 2
                          conversion_errors             = 3
                          create_object_errors          = 4
                          data_access_errors            = 5
                          assign_casting_illegal_cast   = 6
                          assign_casting_unknown_type   = 7
                          assign_field_not_in_range     = 8
                          data_offset_too_large         = 9
                          dyn_call_meth_not_implemented = 10
                          export_buffer_no_memory       = 11
                          generate_subpool_dir_full     = 12
                          move_cast_error               = 13
                          perform_program_name_too_long = 14
                          replace_infinite_loop         = 15
                          remote_call_errors            = 16
                          localization_errors           = 17
                          import_mismatch_errors        = 18
                          dynamic_call_method_errors    = 19
                          file_access_errors            = 20
                          OTHERS                        = 99.
*Catch system exceptions
    " Find Type Sorted OF/ Like SORTED OF
    DATA: lwa_sort_tab TYPE t_sort1,
          lwa_sort_t   TYPE t_sort.
    DATA: lv_str99 TYPE string,
          lv_str   TYPE string.
    DATA: lt_tab99  TYPE TABLE OF ty_code,
          lwa_tab99 TYPE ty_code.
    DATA: lv_check TYPE c.
    REFRESH lt_tab99[].
    CLEAR: lv_str99.
    lv_str99 = lwa_code.
    CONDENSE lv_str99.
    CONDENSE p_method.

    IF lv_str99 CS gc_type_sort_tab
    OR lv_str99 CS gc_like_sort_tab.
      REPLACE ALL OCCURRENCES OF gc_type_sort_tab
                              IN lv_str99 WITH gc_x1x1.
      REPLACE ALL OCCURRENCES OF gc_like_sort_tab
                              IN lv_str99 WITH gc_x1x1.
      SPLIT lv_str99 AT '' INTO TABLE lt_tab99.
      DELETE lt_tab99 WHERE text IS INITIAL.
      LOOP AT lt_tab99 INTO lwa_tab99.
        IF lwa_tab99 = gc_x1x1.
          lv_str99 = sy-tabix - 1.
          CHECK  lv_str99 > 0.
          READ TABLE lt_tab99 INTO lwa_tab99 INDEX lv_str99.
          IF sy-subrc = 0.
            lwa_sort_tab-table = lwa_tab99.
            lwa_sort_tab-routine = p_method.
            REPLACE ALL OCCURRENCES OF gc_bracket
                                    IN lwa_sort_tab-table WITH ''.
            CONDENSE lwa_sort_tab-table.
            APPEND lwa_sort_tab TO gt_sort_m.
          ENDIF.
        ENDIF.
      ENDLOOP.
    ELSEIF lv_str99 CS gc_type_tab
    OR lv_str99 CS gc_type_std_tab
    OR lv_str99 CS gc_like_std_tab
    OR lv_str99 CS gc_like_tab.
      "/ Getting table declarations in form
      REPLACE ALL OCCURRENCES OF gc_type_tab
                              IN lv_str99 WITH gc_x1x1.
      REPLACE ALL OCCURRENCES OF gc_type_std_tab
                              IN lv_str99 WITH gc_x1x1.
      REPLACE ALL OCCURRENCES OF gc_like_std_tab
                              IN lv_str99 WITH gc_x1x1.
      REPLACE ALL OCCURRENCES OF gc_like_tab
                              IN lv_str99 WITH gc_x1x1.
      SPLIT lv_str99 AT '' INTO TABLE lt_tab99.
      DELETE lt_tab99 WHERE text IS INITIAL.
      LOOP AT lt_tab99 INTO lwa_tab99.
        IF lwa_tab99 = gc_x1x1.
          lv_str99 = sy-tabix - 1.
          CHECK  lv_str99 > 0.
          READ TABLE lt_tab99 INTO lwa_tab99 INDEX lv_str99.
          IF sy-subrc = 0.
            lwa_sort_tab-table = lwa_tab99.
            lwa_sort_tab-routine = p_method.
            REPLACE ALL OCCURRENCES OF gc_bracket
                      IN lwa_sort_tab-table WITH ''.
            CONDENSE lwa_sort_tab-table.
            APPEND lwa_sort_tab TO gt_meth_tab.
          ENDIF.
        ENDIF.
      ENDLOOP.
    ENDIF.

    " Find Order By Clause in SELECT
    IF lwa_code+0(7) EQ gc_select_spc
    AND lwa_code CS gc_from_spc
    AND lwa_code CS gc_ord_by_spc.
      lv_str99 = lwa_code.

* Begin of change by Twara 11/01/2016
      CLEAR lv_check.
      IF lv_str99 CS gc_into_tab_spc.
        lv_check = gc_x.
        SPLIT lv_str99 AT gc_into_tab_spc INTO lv_str99 lv_str.
      ELSEIF lv_str99 CS gc_into_corr.
        lv_check = gc_x.
        SPLIT lv_str99 AT gc_into_corr
                      INTO lv_str99 lv_str.
      ELSEIF lv_str99 CS gc_app_tab.
        lv_check = gc_x.
        SPLIT lv_str99 AT gc_app_tab INTO lv_str99 lv_str.
      ELSEIF lv_str99 CS gc_app_corr.
        lv_check = gc_x.
        SPLIT lv_str99 AT gc_app_corr
                      INTO lv_str99 lv_str.
      ENDIF.
      IF NOT lv_check IS INITIAL.
        CONDENSE lv_str.
        SPLIT lv_str AT space INTO lv_str99 lv_str.
        lwa_sort_tab-table = lv_str99.
        SPLIT lwa_sort_tab-table AT gc_op_bracket
                              INTO lwa_sort_tab-table lv_str99.
        CONDENSE lwa_sort_tab-table.
        READ TABLE gt_meth_tab
          TRANSPORTING NO FIELDS
          WITH KEY table = lwa_sort_tab-table
                   routine = p_method.
        IF sy-subrc EQ 0.
          lwa_sort_tab-routine = p_method.
          APPEND lwa_sort_tab TO gt_sort_m.
        ELSE.
          lwa_sort_t-table = lwa_sort_tab-table.
          APPEND lwa_sort_t TO gt_sort_t.
        ENDIF.
      ENDIF.
    ENDIF.
* End of change by Twara 11/01/2016

    " Find Sort statement on internal table
    IF lwa_code+0(5) EQ gc_sort_spc.
      lv_str99 = lwa_code.
      SPLIT lv_str99 AT space INTO lv_str99 lv_str.
      CONDENSE lv_str.
      SPLIT lv_str AT space INTO lv_str99 lv_str.
      lwa_sort_tab-table = lv_str99.
      SPLIT lwa_sort_tab-table AT gc_op_bracket
                          INTO lwa_sort_tab-table lv_str99.
      CONDENSE lwa_sort_tab-table.
      READ TABLE gt_meth_tab
          TRANSPORTING NO FIELDS
          WITH KEY table = lwa_sort_tab-table
                   routine = p_method.
      IF sy-subrc EQ 0.
        lwa_sort_tab-routine = p_method.
        APPEND lwa_sort_tab TO gt_sort_m.
      ELSE.
        lwa_sort_t-table = lwa_sort_tab-table.
        APPEND lwa_sort_t TO gt_sort_t.
      ENDIF.
    ENDIF.
    SORT gt_sort_t
      BY table.
    DELETE ADJACENT DUPLICATES FROM gt_sort_t.
    SORT gt_sort_m
      BY table
         routine.
    DELETE ADJACENT DUPLICATES FROM gt_sort_m.
*Catch system exceptions
  ENDCATCH.
  IF sy-subrc <> 0.
    WRITE:/ gc_error , 'Error code:', sy-subrc ,
    '=>Perform F_FIND_SORT_TAB_METH'.
  ENDIF.
*Catch system exceptions
ENDFORM.                    " F_FIND_SORT_TAB_METH
*&---------------------------------------------------------------------*
*&      Form  F_DETECT_ITAB_INDEX_MAIN
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_lv_line_code  text
*      -->P_LV_INDEX  text
*----------------------------------------------------------------------*
FORM f_detect_itab_index_main  USING    lwa_code
                                   lv_index.
*Catch system exceptions
  CATCH SYSTEM-EXCEPTIONS arithmetic_errors             = 1
                          create_data_errors            = 2
                          conversion_errors             = 3
                          create_object_errors          = 4
                          data_access_errors            = 5
                          assign_casting_illegal_cast   = 6
                          assign_casting_unknown_type   = 7
                          assign_field_not_in_range     = 8
                          data_offset_too_large         = 9
                          dyn_call_meth_not_implemented = 10
                          export_buffer_no_memory       = 11
                          generate_subpool_dir_full     = 12
                          move_cast_error               = 13
                          perform_program_name_too_long = 14
                          replace_infinite_loop         = 15
                          remote_call_errors            = 16
                          localization_errors           = 17
                          import_mismatch_errors        = 18
                          dynamic_call_method_errors    = 19
                          file_access_errors            = 20
                          OTHERS                        = 99.
*Catch system exceptions
    DATA: lv_str99  TYPE string,
          lv_str    TYPE string,
          lt_break  TYPE TABLE OF ty_code,
          lwa_break TYPE ty_code,
          lwa_final TYPE ty_final,
          ls_check  TYPE ty_checks.
*Begin of change by Twara 12/02/2016
    DATA: lwa_sel_t  TYPE t_sort,
          lwa_sel_t1 TYPE t_sort.
*End of change by Twara 12/02/2016

    " Build internal table having all internal table names
    " used in SELECT statements
* Begin of change by Twara 12/02/2016
*    PERFORM f_itabs_in_select USING lwa_code.  "commented
    PERFORM f_itabs_in_select USING lwa_code
                                    lv_index.
* End of change by Twara 12/02/2016

    " Detect cases where unsorted internal table is used with index
    lv_str99 = lwa_code.
    REPLACE ALL OCCURRENCES OF gc_bracket IN lv_str99 WITH space.
    CONDENSE lv_str99.
    SPLIT lv_str99 AT space INTO TABLE lt_break.
    DELETE lt_break WHERE text IS INITIAL.

*{ Begin of change by Twara - 12/02/2016
*    IF lwa_code+0(11) EQ gc_read_tab_spc AND
*      lwa_code CS gc_index_spc.
    IF lwa_code+0(11) EQ gc_read_tab_spc AND
      lwa_code CS gc_index_spc AND
      lwa_code NS ' TRANSPORTING NO FIELDS'.
*} End of change by Twara - 12/02/2016
      READ TABLE lt_break INTO lwa_break INDEX 3.
      lv_str = lwa_break-text.

    ELSEIF lwa_code+0(7) EQ gc_modify_spc AND
      lwa_code CS gc_index_spc .
      READ TABLE lt_break INTO lwa_break INDEX 2.
      lv_str = lwa_break-text.

    ELSEIF lwa_code+0(7) EQ gc_delete_spc AND
     ( lwa_code CS gc_index_spc OR
          ( lwa_code CS gc_from_spc AND lwa_code CS gc_to_spc ) ).
      READ TABLE lt_break INTO lwa_break INDEX 2.
      lv_str = lwa_break-text.

    ELSEIF lwa_code+0(8) EQ gc_loop_at_spc
      AND lwa_code CS gc_from_spc.
      READ TABLE lt_break INTO lwa_break INDEX 3.
      lv_str = lwa_break-text.
    ENDIF.

    IF NOT lv_str IS INITIAL.
      " find if internal is used in select statements
*Begin of change by Twara 12/02/2016
*      READ TABLE gt_sel_t WITH KEY table = lv_str
*      TRANSPORTING NO FIELDS
*      BINARY SEARCH.
      READ TABLE gt_sel_t INTO lwa_sel_t WITH KEY table = lv_str
      BINARY SEARCH.
*End of change by Twara 12/02/2016
      IF sy-subrc = 0.
*****BOC Def_36 by shreeda 26/5/2017 ----remove opcode 77, 78, 79
************BOC Shreeda 2/05/2017************
*        CLEAR: gv_stab.
*        gv_stab = lwa_sel_t-dbtable.
************EOC Shreeda 2/05/2017************
*****BOC Def_36 by shreeda 26/5/2017 ----remove opcode 77, 78, 79
        " find internal is unsorted
        READ TABLE gt_sort_t WITH KEY table = lv_str
        TRANSPORTING NO FIELDS
        BINARY SEARCH.
        IF sy-subrc <> 0.
*****BOC Def_36 by shreeda 26/5/2017 ----remove opcode 77, 78, 79
***********BOC Shreeda 2/05/2017************
*          READ TABLE s_table WITH KEY low = gv_stab.
*          IF sy-subrc EQ 0.
*            lwa_final-code = lwa_code.
*            lwa_final-prog = gv_prog.
*            lwa_final-obj_name = gs_progname-progname.
*            lwa_final-line = lv_index.
*            lwa_final-drill = gv_drill.
*            lwa_final-opercd   = gc_77.        "Operation code
*            lwa_final-itabs = lv_str.
*          ELSE.
***********EOC Shreeda 2/05/2017************
*****EOC Def_36 by shreeda 26/5/2017 ----remove opcode 77, 78, 79
          lwa_final-code = lwa_code.
          lwa_final-prog = gv_prog.
          lwa_final-obj_name = gs_progname-progname.
          lwa_final-line = lv_index.
          lwa_final-drill = gv_drill.
          lwa_final-opercd   = gc_18.        "Operation code
          lwa_final-itabs = lv_str.
* Begin of change by Twara 12/02/2016
          READ TABLE gt_sel_t
            INTO lwa_sel_t1
            WITH KEY table = lv_str
                     prog  = gv_prog
                     sub_prog = gs_progname-progname.
          IF sy-subrc EQ 0.
            lwa_final-select_line = lwa_sel_t1-line.
            PERFORM append_opcode21 USING lwa_sel_t-dbtable
                                          lwa_sel_t-table
                                          lwa_sel_t-tab_type
                                          lwa_sel_t-prog
                                          lwa_sel_t-sub_prog
                                          lwa_sel_t-line
                                          lwa_sel_t-select.
          ENDIF.
*****BOC Def_36 by shreeda 26/5/2017 ----remove opcode 77, 78, 79
* End of change by Twara 12/02/2016
**********BOC Shreeda 2/05/2017************
*          ENDIF.
***********EOC Shreeda 2/05/2017************
*****EOC Def_36 by shreeda 26/5/2017 ----remove opcode 77, 78, 79
          PERFORM append_final USING lwa_final.
          CLEAR: lwa_final.
        ENDIF.
      ENDIF.
    ENDIF.
*Catch system exceptions
  ENDCATCH.
  IF sy-subrc <> 0.
    WRITE:/ gc_error , 'Error code:', sy-subrc ,
    '=>Perform F_DETECT_ITAB_INDEX_MAIN'.
  ENDIF.
*Catch system exceptions

ENDFORM.                    " F_DETECT_ITAB_INDEX_MAIN
*&---------------------------------------------------------------------*
*&      Form  F_ITABS_IN_SELECT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_LWA_CODE  text
*----------------------------------------------------------------------*
FORM f_itabs_in_select  USING    p_lwa_code
* Begin of change by Twara 12/02/2016
                                 lv_index.
* End of change by Twara 12/02/2016
*Catch system exceptions
  CATCH SYSTEM-EXCEPTIONS arithmetic_errors             = 1
                          create_data_errors            = 2
                          conversion_errors             = 3
                          create_object_errors          = 4
                          data_access_errors            = 5
                          assign_casting_illegal_cast   = 6
                          assign_casting_unknown_type   = 7
                          assign_field_not_in_range     = 8
                          data_offset_too_large         = 9
                          dyn_call_meth_not_implemented = 10
                          export_buffer_no_memory       = 11
                          generate_subpool_dir_full     = 12
                          move_cast_error               = 13
                          perform_program_name_too_long = 14
                          replace_infinite_loop         = 15
                          remote_call_errors            = 16
                          localization_errors           = 17
                          import_mismatch_errors        = 18
                          dynamic_call_method_errors    = 19
                          file_access_errors            = 20
                          OTHERS                        = 99.
*Catch system exceptions
    DATA: lv_str99  TYPE string,
          lv_str    TYPE string,
          lv_str1   TYPE string,
          lwa_sel_t TYPE t_sort.
    DATA: lv_check  TYPE c.
* Begin of change by Twara 12/02/2016 to get db table, select,table type
    DATA: lv_tab_type TYPE dd02l-tabclass,
          lwa_final   TYPE ty_final.
* End of change by Twara 12/02/2016 to get db table, select,table type

    IF p_lwa_code+0(7) EQ gc_select_spc
    AND p_lwa_code CS gc_from_spc.
      lv_str99 = p_lwa_code.
      CONDENSE lv_str99.

* Begin of change by Twara 11/01/2016
      CLEAR lv_check.
      IF lv_str99 CS gc_into_tab_spc.
        lv_check = gc_x.
        SPLIT lv_str99 AT gc_into_tab_spc INTO lv_str99 lv_str.
      ELSEIF lv_str99 CS gc_into_corr.
        lv_check = gc_x.
        SPLIT lv_str99 AT gc_into_corr
                       INTO lv_str99 lv_str.
      ELSEIF lv_str99 CS gc_app_tab.
        lv_check = gc_x.
        SPLIT lv_str99 AT gc_app_tab INTO lv_str99 lv_str.
      ELSEIF lv_str99 CS gc_app_corr.
        lv_check = gc_x.
        SPLIT lv_str99 AT gc_app_corr
                      INTO lv_str99 lv_str.
      ENDIF.

      IF NOT lv_check IS INITIAL.
        SPLIT lv_str AT gc_op_bracket INTO lv_str lv_str99.
        CONDENSE lv_str.
        SPLIT lv_str AT space INTO lv_str lv_str99.
        lwa_sel_t-table = lv_str.
* Begin of change by Twara 12/02/2016 to get db table, select,table type
        REPLACE ALL OCCURRENCES OF '.' IN lwa_sel_t-table WITH space.
        CONDENSE lwa_sel_t-table.
        SPLIT p_lwa_code AT 'FROM' INTO lv_str lv_str1.
        CONDENSE lv_str1.
        SPLIT lv_str1 AT space INTO lv_str lv_str1.
        CONDENSE lv_str.
        lwa_sel_t-dbtable = lv_str.
        lwa_sel_t-select  = p_lwa_code.
        lwa_sel_t-line    = lv_index.
        SELECT SINGLE tabclass FROM dd02l INTO lv_tab_type WHERE tabname
        = lv_str.
        lwa_sel_t-tab_type = lv_tab_type.
        lwa_sel_t-prog = gv_prog.
        lwa_sel_t-sub_prog = gs_progname-progname.
* End of change by Twara 12/02/2016 to get db table, select,table type
        APPEND lwa_sel_t TO gt_sel_t.
      ENDIF.
* End of change by Twara 11/01/2016

      SORT gt_sel_t BY table.
      DELETE ADJACENT DUPLICATES FROM gt_sel_t COMPARING table.
    ENDIF.

* Begin of change by Twara 12/02/2016 to eliminate '=' in WHERE clause
    IF p_lwa_code NS 'SELECT '
      AND p_lwa_code NS 'READ TABLE'
      AND p_lwa_code NS 'DELETE '.
* End of change by Twara 12/02/2016 to eliminate '=' in WHERE clause

* Begin of change by Twara 11/01/2016 to handle ASSIGNMENT/MOVE case
      IF p_lwa_code CS ' = ' OR
        ( p_lwa_code CS gc_move AND  p_lwa_code NS gc_into ).
        lv_str99 = p_lwa_code.
        REPLACE ALL OCCURRENCES OF '[' IN lv_str99 WITH space.
        REPLACE ALL OCCURRENCES OF ']' IN lv_str99 WITH space.
        REPLACE ALL OCCURRENCES OF '.' IN lv_str99 WITH space.
        CONDENSE lv_str99.
        CLEAR : lv_str, lv_str1.
        IF lv_str99 CS ' = '.
          SPLIT lv_str99 AT '=' INTO lv_str lv_str1.
          CONDENSE lv_str.
          CONDENSE lv_str1.
* Begin of change by Twara 12/02/2016
*          READ TABLE gt_sel_t WITH KEY table = lv_str1
*          TRANSPORTING NO FIELDS.
          READ TABLE gt_sel_t INTO lwa_sel_t WITH KEY table = lv_str1.
* End of change by Twara 12/02/2016
          IF sy-subrc IS INITIAL.
            lwa_sel_t-table = lv_str.
            APPEND lwa_sel_t TO gt_sel_t.
          ENDIF.
        ELSEIF lv_str99 CS gc_move.
          SPLIT lv_str99 AT gc_move INTO lv_str lv_str1.
          SPLIT lv_str1 AT gc_to INTO lv_str lv_str1.
          CONDENSE lv_str.
          CONDENSE lv_str1.
* Begin of change by Twara 12/02/2016
*          READ TABLE gt_sel_t WITH KEY table = lv_str
*          TRANSPORTING NO FIELDS.
          READ TABLE gt_sel_t INTO lwa_sel_t WITH KEY table = lv_str.
* End of change by Twara 12/02/2016
          IF sy-subrc IS INITIAL.
            lwa_sel_t-table = lv_str1.
            APPEND lwa_sel_t TO gt_sel_t.
          ENDIF.
        ENDIF.
      ENDIF.
* End of change by Twara 11/01/2016 to handle ASSIGNMENT/MOVE case
* Begin of change by Twara 12/02/2016
    ENDIF.
* End of change by Twara 12/02/2016


*Catch system exceptions
  ENDCATCH.
  IF sy-subrc <> 0.
    WRITE:/ gc_error , 'Error code:', sy-subrc ,
    '=>Perform F_ITABS_IN_SELECT'.
  ENDIF.
*Catch system exceptions
ENDFORM.                    " F_ITABS_IN_SELECT
*&---------------------------------------------------------------------*
*&      Form  F_DETECT_ITAB_INDEX_FORMS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_lv_line_code  text
*      -->P_P_SUBROUTINE  text
*      -->P_LV_INDEX  text
*----------------------------------------------------------------------*
FORM f_detect_itab_index_forms  USING    lwa_code
                                         p_subroutine
                                         lv_index.
*Catch system exceptions
  CATCH SYSTEM-EXCEPTIONS arithmetic_errors             = 1
                          create_data_errors            = 2
                          conversion_errors             = 3
                          create_object_errors          = 4
                          data_access_errors            = 5
                          assign_casting_illegal_cast   = 6
                          assign_casting_unknown_type   = 7
                          assign_field_not_in_range     = 8
                          data_offset_too_large         = 9
                          dyn_call_meth_not_implemented = 10
                          export_buffer_no_memory       = 11
                          generate_subpool_dir_full     = 12
                          move_cast_error               = 13
                          perform_program_name_too_long = 14
                          replace_infinite_loop         = 15
                          remote_call_errors            = 16
                          localization_errors           = 17
                          import_mismatch_errors        = 18
                          dynamic_call_method_errors    = 19
                          file_access_errors            = 20
                          OTHERS                        = 99.
*Catch system exceptions
    DATA: lv_str99   TYPE string,
          lv_str     TYPE string,
          lwa_sel_t  TYPE t_sort,
*{ Begin of change by Twara - 12/02/2016
          lwa_sel_t1 TYPE t_sort,
*} End of change by Twara - 12/02/2016
          lt_break   TYPE TABLE OF ty_code,
          lwa_break  TYPE ty_code,
          lwa_final  TYPE ty_final,
          ls_check   TYPE ty_checks.
    " Build internal table having all internal table names
    " used in SELECT statements
* Begin of change by Twara 12/02/2016
*    PERFORM f_itabs_in_select USING lwa_code.
    PERFORM f_itabs_in_select USING lwa_code
                                    lv_index.
* End of change by Twara 12/02/2016

    " Detect cases where unsorted internal table is used with index
    lv_str99 = lwa_code.
    REPLACE ALL OCCURRENCES OF gc_bracket IN lv_str99 WITH space.
    CONDENSE lv_str99.
    SPLIT lv_str99 AT space INTO TABLE lt_break.
    DELETE lt_break WHERE text IS INITIAL.

*{ Begin of change by Twara - 12/02/2016
*    IF lwa_code+0(11) EQ gc_read_tab_spc AND
*      lwa_code CS gc_index_spc.
    IF lwa_code+0(11) EQ gc_read_tab_spc AND
      lwa_code CS gc_index_spc AND
      lwa_code NS ' TRANSPORTING NO FIELDS'.
*} End of change by Twara - 12/02/2016
      READ TABLE lt_break INTO lwa_break INDEX 3.
      lv_str = lwa_break-text.

    ELSEIF lwa_code+0(7) EQ gc_modify_spc AND
      lwa_code CS gc_index_spc .
      READ TABLE lt_break INTO lwa_break INDEX 2.
      lv_str = lwa_break-text.

    ELSEIF lwa_code+0(7) EQ gc_delete_spc AND
     ( lwa_code CS gc_index_spc OR
          ( lwa_code CS gc_from_spc AND lwa_code CS gc_to_spc ) ).
      READ TABLE lt_break INTO lwa_break INDEX 2.
      lv_str = lwa_break-text.

    ELSEIF lwa_code+0(8) EQ gc_loop_at_spc
      AND lwa_code CS gc_from_spc.
      READ TABLE lt_break INTO lwa_break INDEX 3.
      lv_str = lwa_break-text.
    ENDIF.

    IF NOT lv_str IS INITIAL.
      " find if internal is used in select statements
*Begin of change by Twara 12/02/2016
*      READ TABLE gt_sel_t WITH KEY table = lv_str
*      TRANSPORTING NO FIELDS
*      BINARY SEARCH.
      READ TABLE gt_sel_t INTO lwa_sel_t WITH KEY table = lv_str
      BINARY SEARCH.
*End of change by Twara 12/02/2016
      IF sy-subrc = 0.
        " find internal is unsorted
        READ TABLE gt_sort_t WITH KEY table = lv_str
        TRANSPORTING NO FIELDS
        BINARY SEARCH.
        IF sy-subrc <> 0.
          READ TABLE gt_sort_f WITH KEY table = lv_str
                                routine = p_subroutine
          TRANSPORTING NO FIELDS.
          IF sy-subrc <> 0.
            lwa_final-code = lwa_code.
*lwa_final-check = 'Unsorted internal table is accessed with INDEX'.
            lwa_final-prog = gv_prog.
            lwa_final-obj_name = gs_progname-progname.
            lwa_final-line = lv_index.
            lwa_final-drill = gv_drill.
            lwa_final-opercd   = gc_18.        "Operation code
            lwa_final-itabs = lv_str.
* Begin of change by Twara 12/02/2016
            READ TABLE gt_sel_t
              INTO lwa_sel_t1
              WITH KEY table = lv_str
                       prog  = gv_prog
                       sub_prog = gs_progname-progname.
            IF sy-subrc EQ 0.
              lwa_final-select_line = lwa_sel_t1-line.
              PERFORM append_opcode21 USING lwa_sel_t-dbtable
                                            lwa_sel_t-table
                                            lwa_sel_t-tab_type
                                            lwa_sel_t-prog
                                            lwa_sel_t-sub_prog
                                            lwa_sel_t-line
                                            lwa_sel_t-select.
            ENDIF.
* End of change by Twara 12/02/2016
            PERFORM append_final USING lwa_final.
            CLEAR: lwa_final.
          ENDIF.
        ENDIF.
      ENDIF.
    ENDIF.
*Catch system exceptions
  ENDCATCH.
  IF sy-subrc <> 0.
    WRITE:/ gc_error , 'Error code:', sy-subrc ,
    '=>Perform F_DETECT_ITAB_INDEX_FORMS'.
  ENDIF.
*Catch system exceptions
ENDFORM.                    " F_DETECT_ITAB_INDEX_FORMS
*&---------------------------------------------------------------------*
*&      Form  F_DETECT_ITAB_INDEX_METH
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_lv_line_code  text
*      -->P_PV_STR2  text
*      -->P_LV_INDEX  text
*----------------------------------------------------------------------*
FORM f_detect_itab_index_meth  USING    lwa_code
                                        p_method
                                        lv_index.
*Catch system exceptions
  CATCH SYSTEM-EXCEPTIONS arithmetic_errors             = 1
                          create_data_errors            = 2
                          conversion_errors             = 3
                          create_object_errors          = 4
                          data_access_errors            = 5
                          assign_casting_illegal_cast   = 6
                          assign_casting_unknown_type   = 7
                          assign_field_not_in_range     = 8
                          data_offset_too_large         = 9
                          dyn_call_meth_not_implemented = 10
                          export_buffer_no_memory       = 11
                          generate_subpool_dir_full     = 12
                          move_cast_error               = 13
                          perform_program_name_too_long = 14
                          replace_infinite_loop         = 15
                          remote_call_errors            = 16
                          localization_errors           = 17
                          import_mismatch_errors        = 18
                          dynamic_call_method_errors    = 19
                          file_access_errors            = 20
                          OTHERS                        = 99.
*Catch system exceptions

    DATA: lv_str99  TYPE string,
          lv_str    TYPE string,
          lwa_sel_t TYPE t_sort,
          lt_break  TYPE TABLE OF ty_code,
          lwa_break TYPE ty_code,
          lwa_final TYPE ty_final,
          ls_check  TYPE ty_checks.
    " Build internal table having all internal table names
    " used in SELECT statements
* Begin of change by Twara 12/02/2016
*    PERFORM f_itabs_in_select USING lwa_code.
    PERFORM f_itabs_in_select USING lwa_code
                                    lv_index.
* End of change by Twara 12/02/2016

    " Detect cases where unsorted internal table is used with index
    lv_str99 = lwa_code.
    REPLACE ALL OCCURRENCES OF gc_bracket IN lv_str99 WITH space.
    CONDENSE lv_str99.
    SPLIT lv_str99 AT space INTO TABLE lt_break.
    DELETE lt_break WHERE text IS INITIAL.

    IF lwa_code+0(11) EQ gc_read_tab_spc AND
      lwa_code CS gc_index_spc .
      READ TABLE lt_break INTO lwa_break INDEX 3.
      lv_str = lwa_break-text.

    ELSEIF lwa_code+0(7) EQ gc_modify_spc AND
      lwa_code CS gc_index_spc .
      READ TABLE lt_break INTO lwa_break INDEX 2.
      lv_str = lwa_break-text.

    ELSEIF lwa_code+0(7) EQ gc_delete_spc AND
     ( lwa_code CS gc_index_spc OR
          ( lwa_code CS gc_from_spc AND lwa_code CS gc_to_spc ) ).
      READ TABLE lt_break INTO lwa_break INDEX 2.
      lv_str = lwa_break-text.

    ELSEIF lwa_code+0(8) EQ gc_loop_at_spc
      AND lwa_code CS gc_from_spc.
      READ TABLE lt_break INTO lwa_break INDEX 3.
      lv_str = lwa_break-text.
    ENDIF.

    IF NOT lv_str IS INITIAL.
      " find if internal is used in select statements
      READ TABLE gt_sel_t WITH KEY table = lv_str
      TRANSPORTING NO FIELDS
      BINARY SEARCH.
      IF sy-subrc = 0.
        " find internal is unsorted
        READ TABLE gt_sort_t WITH KEY table = lv_str
        TRANSPORTING NO FIELDS
        BINARY SEARCH.
        IF sy-subrc <> 0.
          READ TABLE gt_sort_m WITH KEY table = lv_str
                                  routine = p_method
          TRANSPORTING NO FIELDS.
          IF sy-subrc <> 0.
            lwa_final-code = lwa_code.
*lwa_final-check = 'Unsorted internal table is accessed with INDEX'.
            lwa_final-prog = gv_prog.
            lwa_final-obj_name = gs_progname-progname.
            lwa_final-line = lv_index.
            lwa_final-drill = gv_drill.
            lwa_final-opercd   = gc_18.        "Operation code
            lwa_final-itabs = lv_str.

            PERFORM append_final USING lwa_final.
            CLEAR: lwa_final.
          ENDIF.
        ENDIF.
      ENDIF.
    ENDIF.
*Catch system exceptions
  ENDCATCH.
  IF sy-subrc <> 0.
    WRITE:/ gc_error , 'Error code:', sy-subrc ,
    '=>Perform F_DETECT_ITAB_INDEX_METH'.
  ENDIF.
*Catch system exceptions
ENDFORM.                    " F_DETECT_ITAB_INDEX_METH
*&---------------------------------------------------------------------*
*&      Form  F_CTRL_IN_UNSORTED_ITABS_MAIN
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_P_CODE  text
*      -->P_LV_INDEX  text
*----------------------------------------------------------------------*
FORM f_ctrl_in_unsorted_itabs_main  USING    p_code LIKE gt_code
                                             p_lwa_code
                                             lv_index.
*Catch system exceptions
  CATCH SYSTEM-EXCEPTIONS arithmetic_errors             = 1
                          create_data_errors            = 2
                          conversion_errors             = 3
                          create_object_errors          = 4
                          data_access_errors            = 5
                          assign_casting_illegal_cast   = 6
                          assign_casting_unknown_type   = 7
                          assign_field_not_in_range     = 8
                          data_offset_too_large         = 9
                          dyn_call_meth_not_implemented = 10
                          export_buffer_no_memory       = 11
                          generate_subpool_dir_full     = 12
                          move_cast_error               = 13
                          perform_program_name_too_long = 14
                          replace_infinite_loop         = 15
                          remote_call_errors            = 16
                          localization_errors           = 17
                          import_mismatch_errors        = 18
                          dynamic_call_method_errors    = 19
                          file_access_errors            = 20
                          OTHERS                        = 99.
*Catch system exceptions
    DATA: lv_str99  TYPE string,
          lv_str    TYPE string,
          lv_str1   TYPE string,
          lt_break  TYPE TABLE OF ty_code,
          lwa_break TYPE ty_code,
          lwa_code  TYPE ty_code,
          lwa_final TYPE ty_final,
          ls_check  TYPE ty_checks,
          lv_idx    TYPE i,
          lv_count  TYPE i.
* Begin of change by Twara 12/02/2016
    DATA: lwa_sel_t  TYPE t_sort,
          lwa_sel_t1 TYPE t_sort.
* End of change by Twara 12/02/2016

    CLEAR: lv_str,
           lv_str1,
           lv_str99,
           lv_idx.
    lv_idx = lv_index.
    lv_str99 = p_lwa_code.

    " Reset counter for checking endloops
    lv_count = 0.

    " Find internal table name
    WHILE lv_idx GT 0.
      lv_idx = lv_idx - 1.
      CLEAR lwa_code.
      READ TABLE p_code INTO lwa_code INDEX lv_idx.
      CONDENSE lwa_code-text.
      TRANSLATE lwa_code-text TO UPPER CASE.
      IF NOT ( lwa_code-text+0(1) EQ gc_star OR
                    lwa_code-text+0(1) EQ gc_doub_quote ).
        IF lwa_code-text+0(7) EQ gc_endloop.
          lv_count = lv_count + 1.
        ELSEIF lwa_code-text+0(7) EQ gc_loop_at AND lv_count GT 0.
          lv_count = lv_count - 1.
          CONTINUE.
        ENDIF.
        IF lwa_code-text+0(7) EQ gc_loop_at AND lv_count = 0.
          SPLIT lwa_code-text AT space INTO TABLE lt_break.
          DELETE lt_break WHERE text IS INITIAL.
          READ TABLE lt_break INTO lwa_break INDEX 3.
          IF sy-subrc = 0.
            lv_str = lwa_break-text.
            SPLIT lv_str AT gc_op_bracket INTO lv_str lv_str1.
            SPLIT lv_str AT gc_dot INTO lv_str lv_str1.
            CONDENSE lv_str.
            EXIT.
          ENDIF.
        ENDIF.
      ENDIF.
    ENDWHILE.

    IF NOT lv_str IS INITIAL.
      " find if internal is used in select statements
*Begin of change by Twara 12/02/2016
*      READ TABLE gt_sel_t WITH KEY table = lv_str
*      TRANSPORTING NO FIELDS
*      BINARY SEARCH.
      READ TABLE gt_sel_t INTO lwa_sel_t WITH KEY table = lv_str
      BINARY SEARCH.
*End of change by Twara 12/02/2016
      IF sy-subrc = 0.
        " find internal is unsorted
        READ TABLE gt_sort_t WITH KEY table = lv_str
        TRANSPORTING NO FIELDS
        BINARY SEARCH.
        IF sy-subrc <> 0.
          lwa_final-code = lv_str99.
*lwa_final-check = 'Control statements used inside loop of unsorted
*internal table'.
          lwa_final-prog = gv_prog.
          lwa_final-obj_name = gs_progname-progname.
          lwa_final-line = lv_index.
          lwa_final-drill = gv_drill.
          lwa_final-opercd   = gc_19.        "Operation code
          lwa_final-itabs = lv_str.
* Begin of change by Twara 12/02/2016
          READ TABLE gt_sel_t
            INTO lwa_sel_t1
            WITH KEY table = lv_str
                     prog  = gv_prog
                     sub_prog = gs_progname-progname.
          IF sy-subrc EQ 0.
            lwa_final-select_line = lwa_sel_t1-line.
            PERFORM append_opcode21 USING lwa_sel_t-dbtable
                                          lwa_sel_t-table
                                          lwa_sel_t-tab_type
                                          lwa_sel_t-prog
                                          lwa_sel_t-sub_prog
                                          lwa_sel_t-line
                                          lwa_sel_t-select.
          ENDIF.
* End of change by Twara 12/02/2016
          PERFORM append_final USING lwa_final.
          CLEAR: lwa_final.
        ENDIF.
      ENDIF.
    ENDIF.

*Catch system exceptions
  ENDCATCH.
  IF sy-subrc <> 0.
    WRITE:/ gc_error , 'Error code:', sy-subrc ,
    '=>Perform F_CTRL_IN_UNSORTED_ITABS_MAIN'.
  ENDIF.
*Catch system exceptions
ENDFORM.                    " F_CTRL_IN_UNSORTED_ITABS_MAIN
*&---------------------------------------------------------------------*
*&      Form  F_CTRL_IN_UNSORTED_ITABS_FORM
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_P_CODE  text
*      -->P_P_SUBROUTINE  text
*      -->P_LV_INDEX  text
*----------------------------------------------------------------------*
FORM f_ctrl_in_unsorted_itabs_form  USING    p_code LIKE gt_code
                                             p_lwa_code
                                             p_subroutine
                                             lv_index.
*Catch system exceptions
  CATCH SYSTEM-EXCEPTIONS arithmetic_errors             = 1
                          create_data_errors            = 2
                          conversion_errors             = 3
                          create_object_errors          = 4
                          data_access_errors            = 5
                          assign_casting_illegal_cast   = 6
                          assign_casting_unknown_type   = 7
                          assign_field_not_in_range     = 8
                          data_offset_too_large         = 9
                          dyn_call_meth_not_implemented = 10
                          export_buffer_no_memory       = 11
                          generate_subpool_dir_full     = 12
                          move_cast_error               = 13
                          perform_program_name_too_long = 14
                          replace_infinite_loop         = 15
                          remote_call_errors            = 16
                          localization_errors           = 17
                          import_mismatch_errors        = 18
                          dynamic_call_method_errors    = 19
                          file_access_errors            = 20
                          OTHERS                        = 99.
*Catch system exceptions
    DATA: lv_str99  TYPE string,
          lv_str    TYPE string,
          lv_str1   TYPE string,
          lt_break  TYPE TABLE OF ty_code,
          lwa_break TYPE ty_code,
          lwa_code  TYPE ty_code,
          lwa_final TYPE ty_final,
          ls_check  TYPE ty_checks,
          lv_idx    TYPE i,
          lv_count  TYPE i.
* Begin of change by Twara 12/02/2016
    DATA: lwa_sel_t  TYPE t_sort,
          lwa_sel_t1 TYPE t_sort.
* End of change by Twara 12/02/2016

    CLEAR: lv_str,
           lv_str1,
           lv_str99,
           lv_idx.
    lv_idx = lv_index.
    lv_str99 = p_lwa_code.
    " Reset counter for checking endloops
    lv_count = 0.

    " Find internal table name
    WHILE lv_idx GT 0.
      lv_idx = lv_idx - 1.
      CLEAR lwa_code.
      READ TABLE p_code INTO lwa_code INDEX lv_idx.
      CONDENSE lwa_code-text.
      TRANSLATE lwa_code-text TO UPPER CASE.
      IF NOT ( lwa_code-text+0(1) EQ gc_star OR
                    lwa_code-text+0(1) EQ gc_doub_quote ).
        IF lwa_code-text+0(7) EQ gc_endloop.
          lv_count = lv_count + 1.
        ELSEIF lwa_code-text+0(7) EQ gc_loop_at AND lv_count GT 0.
          lv_count = lv_count - 1.
          CONTINUE.
        ENDIF.
        IF lwa_code-text+0(7) EQ gc_loop_at AND lv_count = 0.
          SPLIT lwa_code-text AT space INTO TABLE lt_break.
          DELETE lt_break WHERE text IS INITIAL.
          READ TABLE lt_break INTO lwa_break INDEX 3.
          IF sy-subrc = 0.
            lv_str = lwa_break-text.
            SPLIT lv_str AT gc_op_bracket INTO lv_str lv_str1.
            SPLIT lv_str AT gc_dot INTO lv_str lv_str1.
            CONDENSE lv_str.
            EXIT.
          ENDIF.
        ENDIF.
      ENDIF.
    ENDWHILE.

    IF NOT lv_str IS INITIAL.
      " find if internal is used in select statements
*Begin of change by Twara 12/02/2016
*      READ TABLE gt_sel_t WITH KEY table = lv_str
*      TRANSPORTING NO FIELDS
*      BINARY SEARCH.
      READ TABLE gt_sel_t INTO lwa_sel_t WITH KEY table = lv_str
      BINARY SEARCH.
*End of change by Twara 12/02/2016
      IF sy-subrc = 0.
        " find internal is unsorted
        READ TABLE gt_sort_t WITH KEY table = lv_str
        TRANSPORTING NO FIELDS
        BINARY SEARCH.
        IF sy-subrc <> 0.
          READ TABLE gt_sort_f WITH KEY table = lv_str
                                routine = p_subroutine
          TRANSPORTING NO FIELDS.
          IF sy-subrc <> 0.
            lwa_final-code = lv_str99.
*lwa_final-check = 'Control statements used inside loop of unsorted
*internal table'.
            lwa_final-prog = gv_prog.
            lwa_final-obj_name = gs_progname-progname.
            lwa_final-line = lv_index.
            lwa_final-drill = gv_drill.
            lwa_final-opercd   = gc_19.        "Operation code
            lwa_final-itabs = lv_str.
* Begin of change by Twara 12/02/2016
            READ TABLE gt_sel_t
              INTO lwa_sel_t1
              WITH KEY table = lv_str
                       prog  = gv_prog
                       sub_prog = gs_progname-progname.
            IF sy-subrc EQ 0.
              lwa_final-select_line = lwa_sel_t1-line.
              PERFORM append_opcode21 USING lwa_sel_t-dbtable
                                            lwa_sel_t-table
                                            lwa_sel_t-tab_type
                                            lwa_sel_t-prog
                                            lwa_sel_t-sub_prog
                                            lwa_sel_t-line
                                            lwa_sel_t-select.
            ENDIF.
* End of change by Twara 12/02/2016
            PERFORM append_final USING lwa_final.
            CLEAR: lwa_final.
          ENDIF.
        ENDIF.
      ENDIF.
    ENDIF.
*Catch system exceptions
  ENDCATCH.
  IF sy-subrc <> 0.
    WRITE:/ gc_error , 'Error code:', sy-subrc ,
    '=>Perform F_CTRL_IN_UNSORTED_ITABS_FORM'.
  ENDIF.
*Catch system exceptions
ENDFORM.                    " F_CTRL_IN_UNSORTED_ITABS_FORM
*&---------------------------------------------------------------------*
*&      Form  F_CTRL_IN_UNSORTED_ITABS_METH
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_P_CODE  text
*      -->P_P_METHOD  text
*      -->P_LV_INDEX  text
*----------------------------------------------------------------------*
FORM f_ctrl_in_unsorted_itabs_meth  USING    p_code LIKE gt_code
                                             p_lwa_code
                                             p_method
                                             lv_index.
*Catch system exceptions
  CATCH SYSTEM-EXCEPTIONS arithmetic_errors             = 1
                          create_data_errors            = 2
                          conversion_errors             = 3
                          create_object_errors          = 4
                          data_access_errors            = 5
                          assign_casting_illegal_cast   = 6
                          assign_casting_unknown_type   = 7
                          assign_field_not_in_range     = 8
                          data_offset_too_large         = 9
                          dyn_call_meth_not_implemented = 10
                          export_buffer_no_memory       = 11
                          generate_subpool_dir_full     = 12
                          move_cast_error               = 13
                          perform_program_name_too_long = 14
                          replace_infinite_loop         = 15
                          remote_call_errors            = 16
                          localization_errors           = 17
                          import_mismatch_errors        = 18
                          dynamic_call_method_errors    = 19
                          file_access_errors            = 20
                          OTHERS                        = 99.
*Catch system exceptions
    DATA: lv_str99  TYPE string,
          lv_str    TYPE string,
          lv_str1   TYPE string,
          lt_break  TYPE TABLE OF ty_code,
          lwa_break TYPE ty_code,
          lwa_code  TYPE ty_code,
          lwa_final TYPE ty_final,
          ls_check  TYPE ty_checks,
          lv_idx    TYPE i,
          lv_count  TYPE i.

    CLEAR: lv_str,
           lv_str1,
           lv_str99,
           lv_idx.
    lv_idx = lv_index.
    lv_str99 = p_lwa_code.
    " Reset counter for checking endloops
    lv_count = 0.

    " Find internal table name
    WHILE lv_idx GT 0.
      lv_idx = lv_idx - 1.
      CLEAR lwa_code.
      READ TABLE p_code INTO lwa_code INDEX lv_idx.
      CONDENSE lwa_code-text.
      TRANSLATE lwa_code-text TO UPPER CASE.
      IF NOT ( lwa_code-text+0(1) EQ gc_star OR
                    lwa_code-text+0(1) EQ gc_doub_quote ).
        IF lwa_code-text+0(7) EQ gc_endloop.
          lv_count = lv_count + 1.
        ELSEIF lwa_code-text+0(7) EQ gc_loop_at AND lv_count GT 0.
          lv_count = lv_count - 1.
          CONTINUE.
        ENDIF.
        IF lwa_code-text+0(7) EQ gc_loop_at AND lv_count = 0.
          SPLIT lwa_code-text AT space INTO TABLE lt_break.
          DELETE lt_break WHERE text IS INITIAL.
          READ TABLE lt_break INTO lwa_break INDEX 3.
          IF sy-subrc = 0.
            lv_str = lwa_break-text.
            SPLIT lv_str AT gc_op_bracket INTO lv_str lv_str1.
            SPLIT lv_str AT gc_dot INTO lv_str lv_str1.
            CONDENSE lv_str.
            EXIT.
          ENDIF.
        ENDIF.
      ENDIF.
    ENDWHILE.

    IF NOT lv_str IS INITIAL.
      " find if internal is used in select statements
      READ TABLE gt_sel_t WITH KEY table = lv_str
      TRANSPORTING NO FIELDS
      BINARY SEARCH.
      IF sy-subrc = 0.
        " find internal is unsorted
        READ TABLE gt_sort_t WITH KEY table = lv_str
        TRANSPORTING NO FIELDS
        BINARY SEARCH.
        IF sy-subrc <> 0.
          READ TABLE gt_sort_m WITH KEY table = lv_str
                                routine = p_method
          TRANSPORTING NO FIELDS.
          IF sy-subrc <> 0.
            lwa_final-code = lv_str99.
*lwa_final-check = 'Control statements used inside loop of unsorted
*internal table'.
            lwa_final-prog = gv_prog.
            lwa_final-obj_name = gs_progname-progname.
            lwa_final-line = lv_index.
            lwa_final-drill = gv_drill.
            lwa_final-opercd   = gc_19.        "Operation code
            lwa_final-itabs = lv_str.

            PERFORM append_final USING lwa_final.
            CLEAR: lwa_final.
          ENDIF.

        ENDIF.
      ENDIF.
    ENDIF.
*Catch system exceptions
  ENDCATCH.
  IF sy-subrc <> 0.
    WRITE:/ gc_error , 'Error code:', sy-subrc ,
    '=>Perform F_CTRL_IN_UNSORTED_ITABS_METH'.
  ENDIF.
*Catch system exceptions
ENDFORM.                    " F_CTRL_IN_UNSORTED_ITABS_METH
*&---------------------------------------------------------------------*
*&      Form  F_DETECT_ADBC
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_lv_line_code  text
*      -->P_LV_INDEX  text
*----------------------------------------------------------------------*
FORM f_detect_adbc  USING    p_lv_line_code
                             p_lv_index.
*Catch system exceptions
  CATCH SYSTEM-EXCEPTIONS arithmetic_errors             = 1
                          create_data_errors            = 2
                          conversion_errors             = 3
                          create_object_errors          = 4
                          data_access_errors            = 5
                          assign_casting_illegal_cast   = 6
                          assign_casting_unknown_type   = 7
                          assign_field_not_in_range     = 8
                          data_offset_too_large         = 9
                          dyn_call_meth_not_implemented = 10
                          export_buffer_no_memory       = 11
                          generate_subpool_dir_full     = 12
                          move_cast_error               = 13
                          perform_program_name_too_long = 14
                          replace_infinite_loop         = 15
                          remote_call_errors            = 16
                          localization_errors           = 17
                          import_mismatch_errors        = 18
                          dynamic_call_method_errors    = 19
                          file_access_errors            = 20
                          OTHERS                        = 99.
*Catch system exceptions

    DATA: lv_str1      TYPE string,
          lv_str2      TYPE string,
          lv_str99     TYPE string,
          lv_index     TYPE i,
          lt_tab99     TYPE TABLE OF ty_code,
          lwa_tab99    TYPE ty_code,
          lwa_adbc_tab TYPE ty_adbc_tab,
          lwa_final    TYPE ty_final.

    CLEAR: lv_str1,
           lv_str2,
           lv_str99,
           lt_tab99.

    lv_str99 = p_lv_line_code.

    IF p_lv_line_code CS gc_type_ref_spc
      AND ( p_lv_line_code CS gc_adbc_cls1_spc OR
            p_lv_line_code CS gc_adbc_cls2_spc OR
            p_lv_line_code CS gc_adbc_cls3_spc OR
            p_lv_line_code CS gc_adbc_cls4_spc ).

      REPLACE ALL OCCURRENCES OF gc_type_ref
                              IN lv_str99 WITH gc_x1x1.
      SPLIT lv_str99 AT '' INTO TABLE lt_tab99.
      DELETE lt_tab99 WHERE text IS INITIAL.
      LOOP AT lt_tab99 INTO lwa_tab99.
        IF lwa_tab99 = gc_x1x1.

          lv_index = sy-tabix.
          lv_index = lv_index + 1.
*          CHECK  lv_index > 0.
          READ TABLE lt_tab99 INTO lwa_tab99 INDEX lv_index.
          IF sy-subrc IS INITIAL AND
            ( lwa_tab99-text CS gc_adbc_cls1 OR
            lwa_tab99-text CS gc_adbc_cls2 OR
            lwa_tab99-text CS gc_adbc_cls3 OR
            lwa_tab99-text CS gc_adbc_cls4 ).
            lv_index = lv_index - 2.
            CHECK  lv_index > 0.
            READ TABLE lt_tab99 INTO lwa_tab99 INDEX lv_index.
            IF sy-subrc = 0.
              lwa_adbc_tab-obj_name = lwa_tab99.
              CONDENSE lwa_adbc_tab-obj_name.
              APPEND lwa_adbc_tab TO gt_adbc_tab.
            ENDIF.
          ENDIF.
        ENDIF.
        CLEAR lwa_tab99.
      ENDLOOP.
    ENDIF.

    IF p_lv_line_code+0(14) EQ gc_create_obj_spc.
      SPLIT p_lv_line_code AT gc_create_obj_spc INTO lv_str1 lv_str2.
      SPLIT lv_str2 AT gc_dot INTO lv_str2 lv_str1.
      CONDENSE lv_str2.
      READ TABLE gt_adbc_tab WITH KEY obj_name = lv_str2
      TRANSPORTING NO FIELDS.
      IF sy-subrc IS INITIAL.
        lwa_final-code = p_lv_line_code.
        lwa_final-prog = gv_prog.
        lwa_final-obj_name = gs_progname-progname.
        lwa_final-line = p_lv_index.
        lwa_final-drill = gv_drill.
        lwa_final-opercd   = gc_15.        "Operation code
        PERFORM append_final USING lwa_final.
        CLEAR: lwa_final.
      ENDIF.
    ENDIF.
*Catch system exceptions
  ENDCATCH.
  IF sy-subrc <> 0.
    WRITE:/ gc_error , 'Error code:', sy-subrc ,
    '=>Perform F_DETECT_ADBC'.
  ENDIF.
*Catch system exceptions
ENDFORM.                    " F_DETECT_ADBC
*&---------------------------------------------------------------------*
*&      Form  F_PROCESS_CLASS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_lv_line_code  text
*      -->P_LV_INDEX  text
*----------------------------------------------------------------------*
FORM f_process_class  USING    p_lv_line_code
                               p_lv_index.
*Catch system exceptions
  CATCH SYSTEM-EXCEPTIONS arithmetic_errors             = 1
                          create_data_errors            = 2
                          conversion_errors             = 3
                          create_object_errors          = 4
                          data_access_errors            = 5
                          assign_casting_illegal_cast   = 6
                          assign_casting_unknown_type   = 7
                          assign_field_not_in_range     = 8
                          data_offset_too_large         = 9
                          dyn_call_meth_not_implemented = 10
                          export_buffer_no_memory       = 11
                          generate_subpool_dir_full     = 12
                          move_cast_error               = 13
                          perform_program_name_too_long = 14
                          replace_infinite_loop         = 15
                          remote_call_errors            = 16
                          localization_errors           = 17
                          import_mismatch_errors        = 18
                          dynamic_call_method_errors    = 19
                          file_access_errors            = 20
                          OTHERS                        = 99.
*Catch system exceptions
    DATA: lv_str1      TYPE string,
          lv_str2      TYPE string,
          lv_str99     TYPE string,
          lt_tab99     TYPE TABLE OF ty_code,
          lt_include   TYPE TABLE OF ty_tables,
          ls_progname  TYPE main_prog,
          lwa_tab99    TYPE ty_code,
          lwa_final    TYPE ty_final,
          lwr_nspace   LIKE LINE OF gr_nspace,
          lv_namespace TYPE namespace,
          lwa_class    TYPE seoclskey,
* Begin of change by Twara 12/01/2016 to replace FM with subroutine
*to get includes of classes
*          lt_methods   TYPE seop_methods_w_include, "commented
*          lwa_methods  TYPE seop_method_w_include,
* End of change by Twara 12/01/2016 to replace FM with subroutine
*to get includes of classes
          lt_tables    TYPE ty_tables,
          lwa_tables   TYPE ty_tables,
          lv_index     TYPE i,
          "begin of code changes for def_20
          lv_check     TYPE wdy_boolean.
    "end of code changes for def_20

    lwr_nspace-sign = gc_i.
    lwr_nspace-option = gc_cp.

    CLEAR: lv_str1,
           lv_str2,
           lv_str99,
           lt_tab99,
           ls_progname.
    REFRESH : lt_include.

    lv_str99 = p_lv_line_code.

    IF p_lv_line_code CS gc_type_ref_spc.
      REPLACE ALL OCCURRENCES OF gc_type_ref
                        IN lv_str99 WITH gc_x1x1.
      SPLIT lv_str99 AT '' INTO TABLE lt_tab99.
      DELETE lt_tab99 WHERE text IS INITIAL.
      "begin of code change for def_20
      CREATE OBJECT lo_cl_data.
      "end of code change for def_20

      LOOP AT lt_tab99 INTO lwa_tab99.
        IF lwa_tab99 = gc_x1x1.
          lv_index = sy-tabix + 1.
          CHECK  lv_index  > 0.
          READ TABLE lt_tab99 INTO lwa_tab99 INDEX lv_index.
          IF sy-subrc = 0.
            ls_progname-progname = lwa_tab99.
            REPLACE ALL OCCURRENCES OF gc_comma IN ls_progname-progname
            WITH space.
            REPLACE ALL OCCURRENCES OF gc_dot IN ls_progname-progname
            WITH space.
            CONDENSE ls_progname-progname.
            READ TABLE gt_progname
            WITH KEY progname = ls_progname-progname
            TRANSPORTING NO FIELDS.

            IF NOT sy-subrc IS INITIAL.
              IF ls_progname-progname CS gc_saplz OR
              ls_progname-progname CS gc_saply OR
              ls_progname-progname CS gc_sapmz OR
              ls_progname-progname CS gc_sapmy OR
              ls_progname-progname+0(2) = gc_lz OR
              ls_progname-progname+0(2) = gc_ly OR
              ls_progname-progname+0(2) = gc_mz OR
              ls_progname-progname+0(2) = gc_my OR
              ls_progname-progname+0(1) = gc_z OR
              ls_progname-progname+0(1) = gc_y OR
              ls_progname-progname+0(3) = gc_mp9 OR
             ( ls_progname-progname IN gr_nspace[]
              AND NOT gr_nspace[] IS INITIAL ).

                APPEND ls_progname TO gt_progname.
              ENDIF.

              IF ls_progname-progname+0(1) = gc_for_slash .
                REPLACE FIRST OCCURRENCE OF gc_for_slash IN
                ls_progname-progname
                WITH ''.
                CONDENSE ls_progname-progname.
                CLEAR: lv_str1, lv_str2.
                SPLIT ls_progname-progname AT gc_for_slash INTO lv_str1
                lv_str2.
                CHECK lv_str2 IS NOT INITIAL.
                CLEAR: ls_progname-progname.
                CONCATENATE gc_for_slash lv_str1 gc_for_slash lv_str2
                INTO ls_progname-progname.
                CONCATENATE gc_for_slash lv_str1 gc_for_slash INTO
                lv_str1.
                lwr_nspace-low = lv_str1.
                IF lwr_nspace-low IN gr_nspace[] AND NOT
                                                 gr_nspace[] IS INITIAL.
                  " nothing to do.
                ELSE.
                  SELECT SINGLE namespace INTO lv_namespace
                                          FROM trnspacet
                                          WHERE
                                          namespace = lwr_nspace-low.

                  IF sy-subrc = 0.
                    CONCATENATE lv_str1 gc_star INTO lv_str1.
                    lwr_nspace-low = lv_str1.
                    APPEND lwr_nspace TO gr_nspace.
                  ELSE.
                    EXIT.
                  ENDIF.
                ENDIF.
                CLEAR: lv_str1, lv_str2.
              ENDIF.

              CLEAR: lt_methods[], lwa_class.
              lwa_class-clsname = ls_progname-progname.
              lwa_tables-objtyp = gc_clas.

* Begin of change by Twara 12/01/2016 to replace FM with subroutine
*to get includes of classes
*              CALL FUNCTION 'SEO_CLASS_GET_METHOD_INCLUDES'
*                EXPORTING
*                  clskey                       = lwa_class
*                IMPORTING
*                  includes                     = lt_methods
*                EXCEPTIONS
*                  _internal_class_not_existing = 1
*                  OTHERS                       = 2.
              "begin of code changes for def_20
              CALL METHOD lo_cl_data->is_std_object
                EXPORTING
*                    i_tadir_pgmid
                  i_tadir_object = 'CLAS'
                  i_obj_name     = ls_progname-progname
                IMPORTING
                  e_std_obj      = lv_check.
              IF lv_check IS NOT INITIAL.
                CONTINUE.
              ENDIF.
              "end of code changes for def_20
              PERFORM get_method_includes USING lwa_class.

              IF NOT lt_methods IS INITIAL.
* End of change by Twara 12/01/2016 to replace FM with subroutine
*to get includes of classes

                LOOP AT lt_methods INTO lwa_methods.
                  lwa_tables-mainprog = lwa_methods-incname.
                  lwa_tables-progname = lwa_methods-incname.
                  APPEND lwa_tables TO lt_include.

                  lwa_tables-mainprog = lwa_methods-cpdkey-clsname.
                  lwa_tables-include = lwa_methods-cpdkey-cpdname.
                  APPEND lwa_tables TO gt_include_cls.
                  CLEAR: lwa_tables-include, lwa_tables-mainprog.
                ENDLOOP.
              ENDIF.

              LOOP AT lt_include INTO  lwa_tables.
                IF lwa_tables-progname IS NOT INITIAL.
                  IF lwa_tables-progname CS gc_saplz OR
                                lwa_tables-progname CS gc_saply OR
                                lwa_tables-progname CS gc_sapmz OR
                                lwa_tables-progname CS gc_sapmy OR
                                lwa_tables-progname+0(2) = gc_lz OR
                                lwa_tables-progname+0(2) = gc_ly OR
                                lwa_tables-progname+0(2) = gc_mz OR
                                lwa_tables-progname+0(2) = gc_my OR
                                lwa_tables-progname+0(1) = gc_z OR
                                lwa_tables-progname+0(1) = gc_y OR
                                lwa_tables-progname+0(3) = gc_mp9 OR
                               ( lwa_tables-progname IN gr_nspace[]
                                AND NOT gr_nspace[] IS INITIAL ).
                    APPEND lwa_tables-progname TO gt_progname.
                  ENDIF.
                ENDIF.
              ENDLOOP.
              lwa_final-code = p_lv_line_code.
              lwa_final-prog = gv_prog.
              lwa_final-obj_name = gs_progname-progname.
              lwa_final-line = p_lv_index.
              lwa_final-drill = gv_drill.
              lwa_final-opercd   = gc_20.        "Operation code
              PERFORM append_final USING lwa_final.
              CLEAR: lwa_final.
            ENDIF.
          ENDIF.
        ENDIF.
        CLEAR lwa_tab99.
      ENDLOOP.
    ENDIF.

*Catch system exceptions
  ENDCATCH.
  IF sy-subrc <> 0.
    WRITE:/ gc_error , 'Error code:', sy-subrc ,
    '=>Perform F_PROCESS_CLASS'.
  ENDIF.
*Catch system exceptions
ENDFORM.                    " F_PROCESS_CLASS
*&---------------------------------------------------------------------*
*&      Form  GET_METHOD_INCLUDES
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_LWA_CLASS  text
*      <--P_LT_METHODS  text
*----------------------------------------------------------------------*
FORM get_method_includes  USING p_lwa_class.

  FREE lt_methods.
  CLASS cl_oo_include_naming DEFINITION LOAD.
  DATA: lo_oref   TYPE REF TO if_oo_clif_incl_naming,
        lo_c_oref TYPE REF TO if_oo_class_incl_naming.

  CALL METHOD cl_oo_include_naming=>get_instance_by_cifkey
    EXPORTING
      cifkey         = p_lwa_class
    RECEIVING
      cifref         = lo_oref
    EXCEPTIONS
      no_objecttype  = 1
      internal_error = 2
      OTHERS         = 3.
  IF sy-subrc <> 0.
    CLEAR lt_methods.
  ELSE.
    IF lo_oref IS BOUND.
      lo_c_oref ?= lo_oref.
      CALL METHOD lo_c_oref->get_all_method_includes
        RECEIVING
          methods_w_include           = lt_methods
        EXCEPTIONS
          internal_class_not_existing = 1
          OTHERS                      = 2.
      IF sy-subrc <> 0.
        CLEAR lt_methods.
      ENDIF.
    ENDIF.
  ENDIF.
ENDFORM.                    " GET_METHOD_INCLUDES
*&---------------------------------------------------------------------*
*&      Form  APPEND_OPCODE21
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_LWA_SEL_T  text
*----------------------------------------------------------------------*
FORM append_opcode21 USING  lwa_sel_t-dbtable
                            lwa_sel_t-table
                            lwa_sel_t-tab_type
                            lwa_sel_t-prog
                            lwa_sel_t-sub_prog
                            lwa_sel_t-line
                            lwa_sel_t-select.
  DATA: lwa_final TYPE ty_final.
  "Get key fields
  TYPES: BEGIN OF tt_tabkey,
           fieldname TYPE dd03l-fieldname,
           position  TYPE dd03l-position,
         END OF tt_tabkey.
  DATA: lv_table    TYPE char30,
        lt_tabkey   TYPE TABLE OF tt_tabkey,
        lwa_tabkey  TYPE tt_tabkey,
        lv_local    TYPE string,
        lv_str2_tmp TYPE string,
        lv_key      TYPE string.

  "Fill the FIELDS field
  DATA: lt_tab2   TYPE TABLE OF ty_code,
        lwa_tab2  TYPE ty_code,
        lv_str    TYPE string,
        lv_index1 TYPE sy-tabix,
        lv_fields TYPE string.


  " To check if SELECT already detected for POOL/CLUSTER
  READ TABLE gt_final INTO lwa_final WITH KEY line     = lwa_sel_t-line
                                              opercd   = '16'
                                              code     =
                                              lwa_sel_t-select
                                              obj_name =
                                              lwa_sel_t-sub_prog
                                              prog     = lwa_sel_t-prog.

  IF NOT sy-subrc IS INITIAL.

    "To get key fields
    lv_table = lwa_sel_t-dbtable.
    SELECT  fieldname position FROM dd03l INTO TABLE lt_tabkey
    WHERE tabname = lv_table  AND keyflag = gc_x .
    IF sy-subrc IS INITIAL.
      CLEAR: lv_key,lv_str2_tmp.
      SORT lt_tabkey BY position.
      LOOP AT lt_tabkey INTO lwa_tabkey.
        CLEAR: lv_local.
        IF lwa_tabkey-fieldname+0(1) = gc_dot.
          CONTINUE.
        ENDIF.
        CONCATENATE  lv_table gc_tilde lwa_tabkey-fieldname
         INTO lv_local.
        CONCATENATE  lv_str2_tmp lv_local INTO
        lv_str2_tmp SEPARATED BY gc_seperator.
        CLEAR:  lv_key,lv_local.
      ENDLOOP.
    ENDIF.
    CONDENSE lv_str2_tmp.

    "To fill the FIELDS field
    lv_str = lwa_sel_t-select.
    REFRESH lt_tab2[].
    SPLIT lv_str AT space INTO TABLE lt_tab2.
    DELETE lt_tab2 WHERE text = ''.
    DELETE lt_tab2 WHERE text = gc_select.
    IF sy-subrc IS INITIAL.
      lv_index1 = sy-tabix - 1.
      IF lv_index1 GE 1.
        DELETE lt_tab2 INDEX lv_index1.
      ENDIF.
    ENDIF.

    LOOP AT lt_tab2 INTO  lwa_tab2.
      TRANSLATE lwa_tab2-text TO UPPER CASE.
      IF lwa_tab2-text = gc_from OR lwa_tab2-text = gc_into
        OR lwa_tab2-text = '*'.
        EXIT.
      ELSE.
        CLEAR: lv_local.
        CONCATENATE  lv_table gc_tilde lwa_tab2-text INTO lv_local
        .
        CONCATENATE  lv_fields lv_local INTO
        lv_fields SEPARATED BY gc_seperator.
      ENDIF.
      CLEAR lwa_tab2.
    ENDLOOP.
    "Begin of Defect DEF_4
    "IF TABLE type is view then it should not be detected
    DATA : lv_tab_type TYPE tabclass.
    CLEAR : lv_tab_type.

    SELECT SINGLE tabclass FROM dd02l INTO lv_tab_type WHERE tabname =  lwa_sel_t-dbtable.
    IF lv_tab_type <> 'VIEW'AND lv_tab_type IS NOT INITIAL.
      "End of Defect DEF_4
      "Append Final table
      lwa_final-code     = lwa_sel_t-select.
      lwa_final-prog     = gv_prog.
      lwa_final-obj_name = gs_progname-progname.
      lwa_final-line     = lwa_sel_t-line.
      lwa_final-drill    = gv_drill.
      lwa_final-opercd   = '21'.   "Operation Code
      lwa_final-itabs    = lwa_sel_t-table.
      lwa_final-table    = lwa_sel_t-dbtable.
      lwa_final-type     = lwa_sel_t-tab_type.
      lwa_final-keys     = lv_str2_tmp.
      lwa_final-fields   = lv_fields.
      PERFORM append_final USING lwa_final.
      CLEAR lwa_final.
    ENDIF.
  ENDIF.
ENDFORM.                    " APPEND_OPCODE21

CLASS lcl_data IMPLEMENTATION.
  "defination
  METHOD is_std_object.
    DATA : ls_tadir   TYPE tadir.
    CONSTANTS  : lc_sap  TYPE char3 VALUE 'SAP'.
    IF i_tadir_pgmid IS NOT INITIAL AND i_tadir_object IS NOT INITIAL AND i_obj_name IS NOT INITIAL.
      CALL FUNCTION 'TR_TADIR_INTERFACE'
        EXPORTING
*         WI_TEST_MODUS                  = 'X'
          wi_tadir_pgmid                 = i_tadir_pgmid
          wi_tadir_object                = i_tadir_object
          wi_tadir_obj_name              = i_obj_name
        IMPORTING
*         NEW_GTADIR_ENTRY               =
          new_tadir_entry                = ls_tadir
        EXCEPTIONS
          tadir_entry_not_existing       = 1
          tadir_entry_ill_type           = 2
          no_systemname                  = 3
          no_systemtype                  = 4
          original_system_conflict       = 5
          object_reserved_for_devclass   = 6
          object_exists_global           = 7
          object_exists_local            = 8
          object_is_distributed          = 9
          obj_specification_not_unique   = 10
          no_authorization_to_delete     = 11
          devclass_not_existing          = 12
          simultanious_set_remove_repair = 13
          order_missing                  = 14
          no_modification_of_head_syst   = 15
          pgmid_object_not_allowed       = 16
          masterlanguage_not_specified   = 17
          devclass_not_specified         = 18
          specify_owner_unique           = 19
          loc_priv_objs_no_repair        = 20
          gtadir_not_reached             = 21
          object_locked_for_order        = 22
          change_of_class_not_allowed    = 23
          no_change_from_sap_to_tmp      = 24
          OTHERS                         = 25.
      IF sy-subrc <> 0.
* Implement suitable error handling here
      ELSE.
        IF ls_tadir-author EQ lc_sap.
          e_std_obj  = abap_true.
        ELSE.
          e_std_obj  = abap_false.
        ENDIF.
      ENDIF.
    ENDIF.
  ENDMETHOD.
ENDCLASS.

CLASS lcl_o_data IMPLEMENTATION.

  METHOD is_valid_odata_class.
*begin of code comment due to change in logic
*    DATA : ls_seo_meta  TYPE seometarel.
*
*    CLEAR : ls_seo_meta.
*
*    IF i_class_name IS NOT INITIAL.
*      "If global table is initial . fetch all entries.
*      IF lt_sgh IS INITIAL.
*        SELECT  technical_name
*                version
*                class_name
*                external_name
*        FROM /iwbep/i_mgw_srh INTO TABLE lt_sgh.
*        IF sy-subrc EQ 0.
*          SELECT  srv_identifier
*                  is_active
*                  namespace
*                  object_name
*                  service_name
*                  service_version
*            FROM /iwfnd/i_med_srh
*          INTO TABLE lt_med FOR ALL ENTRIES IN lt_sgh WHERE service_name  = lt_sgh-ext_name.
*          IF sy-subrc EQ 0.
*            READ TABLE lt_sgh INTO ls_sgh WITH KEY class_name = i_class_name.
*            IF sy-subrc EQ 0.
*              e_valid = abap_true.
*              READ TABLE lt_med INTO ls_med WITH KEY service_name = ls_sgh-ext_name.
*              IF sy-subrc EQ 0.
*                READ TABLE lo_cl_odata->lt_db INTO ls_seo WITH KEY clsname  = i_class_name
*                                                                   reltype  = '2' .
**                SELECT SINGLE * FROM seometarel INTO CORRESPONDING FIELDS OF ls_seo WHERE clsname  = i_class_name
**                                                                                           AND reltype  = '2' .
*                IF sy-subrc EQ 0.
*                  APPEND ls_seo TO lt_seo.
*                ENDIF.
*                e_activ = ls_med-is_active.
*              ENDIF.
*            ELSE.
**              READ TABLE lo_cl_odata->lt_db INTO ls_seo WITH KEY clsname  = i_class_name
**                                                                 reltype  = '2' .
***              SELECT SINGLE * FROM seometarel INTO ls_seo_meta WHERE clsname  = i_class_name
***                                                                 AND reltype  = '2' .
**              IF sy-subrc EQ 0.
**                e_valid = abap_true.
**              ENDIF.
*            ENDIF.
*          ELSE.
*            READ TABLE lt_sgh INTO ls_sgh WITH KEY class_name = i_class_name.
*            IF sy-subrc EQ 0.
*              e_valid = abap_true.
*            ELSE.
**              READ TABLE lo_cl_odata->lt_db INTO ls_seo WITH KEY clsname  = i_class_name
**                                                                  reltype  = '2' .
***              SELECT SINGLE * FROM seometarel INTO ls_seo_meta WHERE clsname  = i_class_name
***                                                                 AND reltype  = '2' .
**              IF sy-subrc EQ 0.
**                e_valid = abap_true.
**              ENDIF.
*            ENDIF.
*          ENDIF.
*        ELSE.
*          e_valid = abap_false.
*        ENDIF.
*      ELSE.
*        READ TABLE lt_sgh INTO ls_sgh WITH KEY class_name = i_class_name.
*        IF sy-subrc EQ 0.
*          e_valid = abap_true.
*          READ TABLE lt_med INTO ls_med WITH KEY service_name = ls_sgh-ext_name.
*          IF sy-subrc EQ 0.
*            READ TABLE lo_cl_odata->lt_db INTO ls_seo WITH KEY clsname  = i_class_name
*                                                               reltype  = '2' .
**            SELECT SINGLE * FROM seometarel INTO CORRESPONDING FIELDS OF ls_seo WHERE clsname  = i_class_name
**                                                                                       AND reltype  = '2' .
*            IF sy-subrc EQ 0.
*              APPEND ls_seo TO lt_seo.
*            ENDIF.
*            e_activ = ls_med-is_active.
*          ENDIF.
*        ELSE.
**          READ TABLE lo_cl_odata->lt_db INTO ls_seo WITH KEY clsname  = i_class_name
**                                                             reltype  = '2' .
***          SELECT SINGLE * FROM seometarel INTO ls_seo_meta WHERE clsname  = i_class_name
***                                                   AND reltype  = '2' .
**          IF sy-subrc EQ 0.
**            e_valid = abap_true.
**          ENDIF.
*        ENDIF.
*      ENDIF.
*    ELSE.
*      e_valid = abap_false.
*    ENDIF.
*    CLEAR : ls_sgh,ls_med,ls_seo.
    TYPES : BEGIN OF ty_l_srh,
              technical_name TYPE /iwbep/med_grp_technical_name,
              version        TYPE /iwbep/med_grp_version,
              class_name     TYPE /iwbep/med_runtime_service,
            END OF ty_l_srh.
    TYPES : BEGIN OF ty_l_srg,
              group_tech_name TYPE /iwbep/med_grp_technical_name,
              group_version   TYPE /iwbep/med_grp_version,
              model_tech_name TYPE /iwbep/med_mdl_technical_name,
              model_version   TYPE /iwbep/med_mdl_version,
            END OF ty_l_srg.
    TYPES : BEGIN OF ty_ohd,
              technical_name TYPE /iwbep/med_mdl_technical_name,
              version        TYPE /iwbep/med_mdl_version,
              class_name     TYPE /iwbep/med_mdl_version,
            END OF ty_ohd.

    TYPES : BEGIN OF ty_sin,
              srv_identifier TYPE /iwfnd/med_mdl_srg_identifier,
              name           TYPE /iwfnd/med_mdl_info_name,
              value          TYPE /iwfnd/med_mdl_info_value,
            END OF ty_sin.

    DATA : lt_srh     TYPE STANDARD TABLE OF ty_l_srh,
           ls_srh     TYPE ty_l_srh,
           lt_srg     TYPE STANDARD TABLE OF ty_l_srg,
           ls_srg     TYPE ty_l_srg,
           lt_ohd     TYPE STANDARD TABLE OF ty_ohd,
           ls_ohd     TYPE ty_ohd,
           lt_mpc_ext TYPE STANDARD TABLE OF ty_l_srh,
           ls_mpc_ext TYPE ty_l_srh
           .

    DATA : lt_rfc_db_fld TYPE STANDARD TABLE OF rfc_db_fld,
           ls_rfc_db_fld TYPE rfc_db_fld,
           lt_sin        TYPE STANDARD TABLE OF ty_sin,
           ls_sin        TYPE ty_sin,
           lt_data       TYPE STANDARD TABLE OF tab512,
           ls_data       TYPE tab512,
           lt_all        TYPE STANDARD TABLE OF ty_l_srh,
           lt_opt        TYPE STANDARD TABLE OF rfc_db_opt.

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
    "end of code change due change in logic

  ENDMETHOD.

  METHOD read_rfc_table.
    "This method is used for reading data from a specific table only.
    "There is an opportunity of improvement by creating this method as generic one
    "and it should have field name and table name parameters as dynamic in nature
    " so that we can send any fields from any table.

    DATA : lt_rfc_db_fld TYPE STANDARD TABLE OF rfc_db_fld,
           ls_rfc_db_fld TYPE rfc_db_fld.


    REFRESH lt_rfc_db_fld.

    ls_rfc_db_fld-fieldname = 'CLSNAME'.
    APPEND ls_rfc_db_fld TO lt_rfc_db_fld.

    ls_rfc_db_fld-fieldname = 'REFCLSNAME'.
    APPEND ls_rfc_db_fld TO lt_rfc_db_fld.

    ls_rfc_db_fld-fieldname = 'RELTYPE'.
    APPEND ls_rfc_db_fld TO lt_rfc_db_fld.

    CALL FUNCTION 'RFC_READ_TABLE' DESTINATION i_dest_name
      EXPORTING
        query_table          = i_tab_name
*       DELIMITER            = ' '
*       NO_DATA              = ' '
*       ROWSKIPS             = 0
*       ROWCOUNT             = 0
      TABLES
*       options              =
        fields               = lt_rfc_db_fld
        data                 = lo_cl_odata->lt_db
      EXCEPTIONS
        table_not_available  = 1
        table_without_data   = 2
        option_not_valid     = 3
        field_not_valid      = 4
        not_authorized       = 5
        data_buffer_exceeded = 6
*       OTHERS               = 7
      .
    IF sy-subrc <> 0.
* Implement suitable error handling here
    ENDIF.


  ENDMETHOD.
  METHOD get_odata_opcodes.
    "This method check for OPCODES on the basis of diffrent parameters.
    "Improvement - Create one generic method to read data from FM RFC_READ_TABLE and use it here.
    DATA : lt_rfc_db_fld TYPE STANDARD TABLE OF rfc_db_fld,
           ls_rfc_db_fld TYPE rfc_db_fld,
           ls_512        TYPE icfservloc.
    DATA: lwa_final TYPE ty_final,
          lv_ok     TYPE wdy_boolean,
          lv_serv   TYPE /iwbep/med_grp_technical_name.

* Begin of changes for OData by Akshay_def_25
    TYPES : BEGIN OF lty_table,
              parameter TYPE char50,
              value     TYPE char50,
            END OF lty_table.

    DATA : lv_sost_1           TYPE flag,
           lv_sost_2           TYPE flag,
           lv_mpc              TYPE wdy_boolean,
           lv_mpc_ext          TYPE wdy_boolean,
           lv_interface(50)    TYPE c,
           lv_method(50)       TYPE c,
           lv_serv_version(40) TYPE c.


    CONSTANTS : lc_sost_start(46) TYPE c VALUE '/IWBEP/IF_MGW_SOST_SRV_RUNTIME~OPERATION_START',
                lc_sost_end(44)   TYPE c   VALUE '/IWBEP/IF_MGW_SOST_SRV_RUNTIME~OPERATION_END'.



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
          lv_icf_name      TYPE icfname,
          lv_odata         TYPE c. "Added by Akshay_Def_35

    CONSTANTS: lc_icfservice_action_unpack TYPE i VALUE 2,
               lc_csrf_token(20)           TYPE c VALUE '~CHECK_CSRF_TOKEN'.
* End of changes for OData by Akshay_def_25



    CLEAR : lo_cl_odata->ls_sgh,
            lo_cl_odata->ls_med,
            ls_512,
            lwa_final,
            lv_ok,
            lv_serv,
            lv_odata,
* Begin of changes for OData by Akshay_def_25
            lv_interface,
            lv_icf_name,
            lv_serv_version.
* End of changes for OData by Akshay_def_25
    "Get service names
*    READ TABLE lo_cl_odata->lt_sgh INTO lo_cl_odata->ls_sgh WITH KEY class_name = i_class_name.
*    IF sy-subrc EQ 0.
*      READ TABLE lo_cl_odata->lt_med INTO lo_cl_odata->ls_med WITH KEY service_name  = ls_sgh-ext_name.
*      IF sy-subrc EQ 0.
    CALL METHOD is_class_found
      EXPORTING
        i_class     = i_class_name
      IMPORTING
        e_ok        = lv_ok
        e_serv_name = lv_serv
*  Begin of changes for OData by Akshay_Def_25
        e_mpc       = lv_mpc
        e_mpc_ext   = lv_mpc_ext
        e_odata     = lv_odata.    "Added by Akshay_Def_35

    SELECT SINGLE icf_name
    FROM icfservice
    INTO lv_icf_name
    WHERE icfaltnme = lv_serv.

*   Check whether the standard interface methods for SOST are implemented in  DPC & DPC_EXT classes.
*         a.  /IWBEP/IF_MGW_SOST_SRV_RUNTIME~OPERATION_START
*         b.  /IWBEP/IF_MGW_SOST_SRV_RUNTIME~OPERATION_END
*  If both the methods are found, then report

    IF lv_ok IS NOT INITIAL.
*      AND lv_mpc IS INITIAL AND lv_mpc_ext IS INITIAL.

      CLEAR : lv_sost_1 , lv_sost_2 , gs_include_cls.
      LOOP AT gt_include_cls INTO gs_include_cls
                              WHERE mainprog = gs_include_odata-mainprog.
        CONDENSE gs_include_cls-include.
        IF gs_include_cls-include = lc_sost_start.
          lv_sost_1 = abap_true.
        ENDIF.

        IF gs_include_cls-include = lc_sost_end.
          lv_sost_2 = abap_true.
        ENDIF.
        CLEAR : gs_include_cls.
      ENDLOOP.


      IF lv_sost_1 = abap_true AND lv_sost_2 = abap_true.

        SPLIT lc_sost_start AT '~' INTO lv_interface lv_method.

        CONDENSE lv_interface.

        "Append Final table
        lwa_final-obj_name = lv_serv.
        lwa_final-sub_program = i_class_name.
        lwa_final-prog     =  i_class_name.
        lwa_final-drill    = gv_drill.
        lwa_final-opercd   = gc_75.   "Operation Code
        lwa_final-objtyp  = 'IWSV'.
*  Begin of changes by Akshay for Def_35
*        lwa_final-odata   = 'A'.
        lwa_final-odata   = lv_odata.
*  End of changes by Akshay for Def_35
        lwa_final-sub_type = lv_interface.
        PERFORM append_final USING lwa_final.
        CLEAR: lwa_final, lv_interface.
      ENDIF.
    ENDIF.

* To check CSRF configuration parameter
* if value = 0, then report

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

                "Append Final table
                lwa_final-obj_name = lv_serv.
                lwa_final-sub_program = i_class_name.
                lwa_final-prog     =  i_class_name.
                lwa_final-drill    = gv_drill.
                lwa_final-opercd   = gc_76.   "Operation Code
                lwa_final-objtyp  = 'IWSV'.
*  Begin of changes by Akshay for Def_35
*                lwa_final-odata   = 'A'.
                lwa_final-odata   = lv_odata.
*  End of changes by Akshay for Def_35
                PERFORM append_final USING lwa_final.
                CLEAR lwa_final.

              ENDIF.
            ENDIF.

          ENDIF.
        ENDIF.
      ENDIF.
    ENDIF.

*  End of changes for OData by Akshay_Def_25

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

*        READ TABLE lt_512 INTO ls_512 WITH KEY icf_name = lv_serv.
        READ TABLE lt_512 INTO ls_512 WITH KEY icf_name = lv_icf_name.

        IF sy-subrc EQ 0.
          IF ls_512-icfactive IS INITIAL.
            "Append Final table
            lwa_final-obj_name = lv_serv.
            lwa_final-sub_program = i_class_name.
            lwa_final-prog     =  i_class_name.
            lwa_final-drill    = gv_drill.
            lwa_final-opercd   = '59'.   "Operation Code
            lwa_final-objtyp  = 'IWSV'.
*  Begin of changes by Akshay for Def_35
*                lwa_final-odata   = 'A'.
            lwa_final-odata   = lv_odata.
*  End of changes by Akshay for Def_35
            PERFORM append_final USING lwa_final.
            CLEAR lwa_final.
          ENDIF.
        ELSE.
          lwa_final-obj_name = lv_serv.
          lwa_final-sub_program = i_class_name.
          lwa_final-prog     =  i_class_name.
          lwa_final-drill    = gv_drill.
          lwa_final-opercd   = '59'.   "Operation Code
          lwa_final-objtyp  = 'IWSV'.
*  Begin of changes by Akshay for Def_35
*                lwa_final-odata   = 'A'.
          lwa_final-odata   = lv_odata.
*  End of changes by Akshay for Def_35
          PERFORM append_final USING lwa_final.
          CLEAR lwa_final.
        ENDIF.
      ENDIF.
    ELSE.
      "Read from buffer

*      READ TABLE lt_512 INTO ls_512 WITH KEY icf_name = lv_serv.
      READ TABLE lt_512 INTO ls_512 WITH KEY icf_name = lv_icf_name.

      IF sy-subrc EQ 0.
        IF ls_512-icfactive IS INITIAL.
          "Append Final table
          lwa_final-obj_name = lv_serv.
          lwa_final-sub_program = i_class_name.
          lwa_final-prog     =  i_class_name.
*              lwa_final-line     = lwa_sel_t-line.
          lwa_final-drill    = gv_drill.
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
          PERFORM append_final USING lwa_final.
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

         SORT lo_cl_odata->lt_class BY service_name group_version.

*        CLEAR : lv_serv_version.
*        READ TABLE lo_cl_odata->lt_class INTO lo_cl_odata->ls_class WITH KEY
*                                                 service_name = lv_serv.
*        IF sy-subrc = 0.
*          CONCATENATE lv_serv lo_cl_odata->ls_class-group_version INTO lv_serv_version
*           SEPARATED BY '_'.
*        ENDIF.

        LOOP AT lo_cl_odata->lt_class INTO lo_cl_odata->ls_class WHERE
                                                 service_name = lv_serv.
          CLEAR : lv_serv_version.

          CONCATENATE lv_serv lo_cl_odata->ls_class-group_version INTO lv_serv_version
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
            lwa_final-sub_program = i_class_name.
            lwa_final-prog     =  i_class_name.
            lwa_final-drill    = gv_drill.
            lwa_final-opercd   = '60'.   "Operation Code
            lwa_final-objtyp  = 'IWSV'.
*  Begin of changes by Akshay for Def_35
*                lwa_final-odata   = 'A'.
            lwa_final-odata   = lv_odata.
*  End of changes by Akshay for Def_35
            PERFORM append_final USING lwa_final.
            CLEAR lwa_final.
          ENDIF.
        ELSE.
          "Append Final table
          lwa_final-obj_name = lv_serv_version.
          lwa_final-sub_program = i_class_name.
          lwa_final-prog     =  i_class_name.
          lwa_final-drill    = gv_drill.
          lwa_final-opercd   = '60'.   "Operation Code
          lwa_final-objtyp  = 'IWSV'.
*  Begin of changes by Akshay for Def_35
*                lwa_final-odata   = 'A'.
          lwa_final-odata   = lv_odata.
*  End of changes by Akshay for Def_35
          PERFORM append_final USING lwa_final.
          CLEAR lwa_final.
        ENDIF.
      ENdloop.
    ELSE.
      "read buffer for opcode60

        SORT lo_cl_odata->lt_class BY service_name group_version.

LOOP AT lo_cl_odata->lt_class INTO lo_cl_odata->ls_class WHERE
                                                      service_name = lv_serv.
          CLEAR : lv_serv_version.

          CONCATENATE lv_serv lo_cl_odata->ls_class-group_version INTO lv_serv_version
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
              lwa_final-sub_program = i_class_name.
              lwa_final-prog     =  i_class_name.
              lwa_final-drill    = gv_drill.
              lwa_final-opercd   = '60'.   "Operation Code
              lwa_final-objtyp  = 'IWSV'.
*  Begin of changes by Akshay for Def_35
*                lwa_final-odata   = 'A'.
              lwa_final-odata   = lv_odata.
*  End of changes by Akshay for Def_35
              PERFORM append_final USING lwa_final.
              CLEAR lwa_final.
            ENDIF.
          ELSE.
            "Append Final table
            lwa_final-obj_name = lv_serv_version.
            lwa_final-sub_program = i_class_name.
            lwa_final-prog     =  i_class_name.
            lwa_final-drill    = gv_drill.
            lwa_final-opercd   = '60'.   "Operation Code
            lwa_final-objtyp  = 'IWSV'.
*  Begin of changes by Akshay for Def_35
*                lwa_final-odata   = 'A'.
            lwa_final-odata   = lv_odata.
*  End of changes by Akshay for Def_35
            PERFORM append_final USING lwa_final.
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
*              IF ls_passwd-icf_passwd IS INITIAL.
          "Append Final table
          lwa_final-obj_name = lv_serv.
          lwa_final-sub_program = i_class_name.
          lwa_final-prog     =  i_class_name.
          lwa_final-drill    = gv_drill.
          lwa_final-opercd   = '61'.   "Operation Code
          lwa_final-objtyp  = 'IWSV'.
*  Begin of changes by Akshay for Def_35
*                lwa_final-odata   = 'A'.
          lwa_final-odata   = lv_odata.
*  End of changes by Akshay for Def_35
          PERFORM append_final USING lwa_final.
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
        "Append Final table
        lwa_final-obj_name = lv_serv.
        lwa_final-sub_program = i_class_name.
        lwa_final-prog     =  i_class_name.
        lwa_final-drill    = gv_drill.
        lwa_final-opercd   = '61'.   "Operation Code
        lwa_final-objtyp  = 'IWSV'.
*  Begin of changes by Akshay for Def_35
*                lwa_final-odata   = 'A'.
        lwa_final-odata   = lv_odata.
*  End of changes by Akshay for Def_35
        PERFORM append_final USING lwa_final.
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
*      ENDIF.
*    ENDIF.
*  ENDIF.
  ENDMETHOD.
  METHOD check_odata_opcodes.
    DATA : lv_code TYPE ty_code.

    CLEAR lv_code.
    lv_code = i_code.
    "Checks for Get Entity set.
    IF lv_code IS NOT INITIAL AND ( i_case EQ '1' OR i_case EQ '2') .
*      Case 1. IT_FILTER_SELECT_OPTIONS or IV_FILTER_STRING or IO_TECH_REQUEST_CONTEXT->GET_FILTER() is
      "not used, we have to detect it and create an entry for each of these parameters.
      IF e_opcode62 IS INITIAL.
        IF lv_code CS 'IT_FILTER_SELECT_OPTIONS' OR
           lv_code CS 'IV_FILTER_STRING' OR
           lv_code CS 'IO_TECH_REQUEST_CONTEXT->GET_FILTER' .
          e_opcode62 = abap_true.
        ELSE.
          e_opcode62 = abap_false.
        ENDIF.
      ENDIF.
*      Case 2. Check in <EntitySetName>_GET_ENTITYSET method whether parameter IS_PAGING is used or not.
      "If NOT used, we should detect it and create an entry for each of these parameters.
      IF e_opcode63 IS INITIAL.
        IF lv_code CS 'IS_PAGING'.
          e_opcode63 = abap_true.
        ELSE.
          e_opcode63 = abap_false.
        ENDIF.
      ENDIF.
*      Case 3.  Check in <EntitySetName>_GET_ENTITYSET method whether parameter ES_RESPONSE_CONTEXT-SKIPTOKEN is used or not.
      "If NOT used, we should detect it and create an entry for each of these parameters.
      IF e_opcode64 IS INITIAL.
        IF lv_code CS 'ES_RESPONSE_CONTEXT-SKIPTOKEN'.
          e_opcode64 = abap_true.
        ELSE.
          e_opcode64 = abap_false.
        ENDIF.
      ENDIF.
*      Case 4.  Check in <EntitySetName>_GET_ENTITYSET method whether parameter ES_RESPONSE_CONTEXT-INLINECOUNT is used when step 2/3 is true. –
*       If anything is found in 2 or 3rd point then we have check this.
      IF e_opcode65 IS INITIAL.
        IF e_opcode63 IS INITIAL OR e_opcode64 IS INITIAL.
          IF lv_code CS 'ES_RESPONSE_CONTEXT-INLINECOUNT'.
            e_opcode65 = abap_true.
          ELSE.
            e_opcode65 = abap_false.
          ENDIF.
        ENDIF.
      ENDIF.
*      Case 6. For case 2 , we need to check for ET_EXPANDED_TECH_CLAUSES
      IF  i_case EQ '2' .
        IF e_opcode66 IS INITIAL.
          IF lv_code CS 'ET_EXPANDED_TECH_CLAUSES'.
            e_opcode66 = abap_true.
          ELSE.
            e_opcode66 = abap_false.
          ENDIF.
        ENDIF.
      ENDIF.
      CLEAR lv_code.
*      Case 5. Check for EXPANDED_ENTITYSET
    ELSEIF lv_code IS NOT INITIAL AND i_case EQ '3'.
      IF e_opcode66 IS INITIAL.
        IF lv_code CS 'ET_EXPANDED_TECH_CLAUSES'.
          e_opcode66 = abap_true.
        ELSE.
          e_opcode66 = abap_false.
        ENDIF.
      ENDIF.
    ENDIF.
  ENDMETHOD.

  METHOD get_case.
    DATA : lv_string TYPE string,
           lv_start  TYPE i,
           lv_end    TYPE i,
           lv_offset TYPE i,
           lv_str1   TYPE string.

    CONSTANTS : lc_1       TYPE c VALUE '1',
                lc_2       TYPE c VALUE '2',
                lc_3       TYPE c VALUE '3',
                lc_get     TYPE char3 VALUE 'GET',
                lc_set     TYPE char13 VALUE 'GET_ENTITYSET',
                lc_ex_set  TYPE char25 VALUE 'GET_EXPANDED_ENTITYSET',
                lc_ex_enty TYPE char25 VALUE 'GET_EXPANDED_ENTITY'.

    IF i_code IS NOT INITIAL.
      lv_string = i_code.
    ELSE.
      EXIT.
    ENDIF.

    CONDENSE lv_string.

    TRANSLATE lv_string TO UPPER CASE.
    lv_end = strlen( lv_string ).

    IF lv_string CS lc_get.
      lv_start = sy-fdpos.
*  SPLIT lv_string AT 'GET' INTO lv_str1 lv_str2.
      lv_offset = lv_end - lv_start.
      lv_str1 = lv_string+lv_start(lv_offset).
      REPLACE ALL OCCURRENCES OF '.' IN lv_str1 WITH ''.

      IF lv_str1 EQ lc_set.
        e_case = lc_1.
      ELSEIF lv_str1 EQ lc_ex_set .
        e_case = lc_2.
      ELSEIF lv_str1 EQ lc_ex_enty.
        e_case = lc_3.
      ENDIF.
    ENDIF.
  ENDMETHOD.

  METHOD get_mpc_logic.

    DATA:BEGIN OF itab ,
           field(15),
         END OF itab.

    DATA : ls_mpc     TYPE ty_mpc_table,
           lv_start   TYPE i,
           lv_code    TYPE ty_code,
           lv_field   TYPE string,
           lv_struc   TYPE string,
           lv_string1 TYPE string,
           lv_string2 TYPE string,
           lv_string3 TYPE string,
           lv_string4 TYPE string,
           lv_index   TYPE i,
           lt_itab    TYPE STANDARD TABLE OF itab,
           ls_itab    TYPE  itab.

    CONSTANTS : lc_init_bc         TYPE c VALUE  '(',
                lc_end_bc          TYPE c VALUE ')',
                lc_method          TYPE char6 VALUE 'METHOD',
                lc_dot             TYPE c VALUE '.',
                lc_arrow           TYPE char2 VALUE '->',
                lc_eq              TYPE c VALUE '=',
                lc_create_property TYPE char15 VALUE 'CREATE_PROPERTY',
                lc_field           TYPE char17 VALUE 'IV_ABAP_FIELDNAME',
                lc_struc           TYPE char17 VALUE 'IV_STRUCTURE_NAME',
                lc_bind_struc      TYPE char14 VALUE 'BIND_STRUCTURE',
                lc_create_set      TYPE char17 VALUE 'CREATE_ENTITY_SET',
                lc_create_type     TYPE char18  VALUE 'CREATE_ENTITY_TYPE',
                lc_set_label       TYPE char27  VALUE 'SET_LABEL_FROM_TEXT_ELEMENT',
                lc_entity_name     TYPE char19  VALUE 'IV_ENTITY_TYPE_NAME',
                lc_create_ass      TYPE char18  VALUE 'CREATE_ASSOCIATION',
                lc_assoc_name      TYPE char19  VALUE 'IV_ASSOCIATION_NAME',
                lc_assoc_set       TYPE char22  VALUE 'CREATE_ASSOCIATION_SET',
                lc_assoc_set_iv    TYPE char23  VALUE 'IV_ASSOCIATION_SET_NAME',
                lc_cr_nav_prop     TYPE char26  VALUE 'CREATE_NAVIGATION_PROPERTY',
                lc_prop_name       TYPE char16   VALUE 'IV_PROPERTY_NAME',
                lc_action_name     TYPE char14     VALUE 'IV_ACTION_NAME',
                lc_create_action   TYPE char13     VALUE 'CREATE_ACTION',
                lc_cr_complex      TYPE char19     VALUE 'CREATE_COMPLEX_TYPE',
                lc_cr_typ_nam      TYPE char17     VALUE 'IV_CPLX_TYPE_NAME',
                lc_edm_typ         TYPE char19   VALUE 'SET_TYPE_EDM_STRING'
                .

    CLEAR : ls_mpc,lv_start,lv_code,lv_string1,lv_string2,lv_string3,lv_string4,lv_field,lv_struc.

    IF i_code IS NOT INITIAL.
      lv_code = i_code.
      "begin of logic to get the method name
      IF lv_code CS lc_method.
        REPLACE ALL OCCURRENCES OF lc_method IN lv_code WITH space.
        REPLACE ALL OCCURRENCES OF lc_dot IN lv_code WITH space.
        CONDENSE lv_code.
        gv_parent_method  = lv_code.
        ls_mpc-parent_method = gv_parent_method.
        APPEND ls_mpc TO lt_mpc.
      ELSEIF lv_code CS lc_init_bc AND lv_code CS lc_end_bc.
        IF lv_code CS lc_arrow.
          SPLIT lv_code AT lc_arrow INTO lv_string1 lv_string2.
          IF lv_string2 CS lc_init_bc.
            CLEAR lv_start.
            lv_start  = sy-fdpos.
            ls_mpc-sub_method  = lv_string2+0(lv_start).
            ls_mpc-parent_method  = gv_parent_method.
            ls_mpc-line_no  = i_index.
            ls_mpc-code = i_code.
            IF lv_string1 CS lc_eq."check for '='
              SPLIT lv_string1 AT lc_eq INTO lv_string3 lv_string4.
              ls_mpc-instance = lv_string3.
            ELSE.
              ls_mpc-instance = lv_string1.
            ENDIF.
            "find field name from parameter IV_ABAP_FIELDNAME
            IF ls_mpc-sub_method EQ lc_create_property.
              IF lv_string2 CS lc_field.
                SPLIT i_code AT space INTO TABLE lt_itab.
                READ TABLE lt_itab TRANSPORTING NO FIELDS WITH KEY keypart = lc_field.
                IF sy-subrc EQ 0.
                  lv_start  = sy-tabix + 2.
                  READ TABLE lt_itab INTO lv_field INDEX lv_start.
                  IF sy-subrc EQ 0.
                    REPLACE ALL OCCURRENCES OF '''' IN lv_field WITH space.
                    CONDENSE lv_field.
                    ls_mpc-fieldname  = lv_field.
                    gv_field_name     = lv_field. " This global variable is reset for every method and keeps track of field
                    IF gv_create_check EQ abap_true.
                      gv_count_prop = gv_count_prop + 1. " to count number of create property staements
                    ENDIF.
                  ENDIF.
                ENDIF.
              ENDIF.

            ENDIF.
            "find structure name
            IF ls_mpc-sub_method EQ lc_bind_struc.
              IF lv_string2 CS lc_struc.
                SPLIT i_code AT space INTO TABLE lt_itab.
                READ TABLE lt_itab TRANSPORTING NO FIELDS WITH KEY keypart = lc_struc.
                IF sy-subrc EQ 0.
                  lv_start  = sy-tabix + 2.
                  READ TABLE lt_itab INTO lv_struc INDEX lv_start.
                  IF sy-subrc EQ 0.
                    ls_mpc-structure  = lv_struc.
                  ENDIF.
                ENDIF.
              ENDIF.
            ENDIF.
            "Chekck property set_label_from_text_element
            IF gv_check_prop IS NOT INITIAL .
              IF ls_mpc-sub_method EQ lc_set_label.
                CLEAR : gv_check_prop.
              ELSE.
*                ls_mpc-error  = 'SET_LABEL'  .
              ENDIF.
            ENDIF.
            REFRESH : lt_itab.
            CLEAR   : lv_string1, lv_string2.
            IF ls_mpc-sub_method EQ lc_create_set.

              IF gv_count_prop > 30 .
                IF gv_check_prop IS INITIAL.
                  ls_mpc-error = '|COUNT'.
                ELSEIF gv_check_prop IS NOT INITIAL.
                  CONCATENATE 'SET_LABEL' '|' 'COUNT' INTO ls_mpc-error.
                ENDIF.
              ELSEIF gv_check_prop IS NOT INITIAL.
                ls_mpc-error = 'SET_LABEL|'.
              ENDIF.
              "logic to get fieldname for create entity set.
              SPLIT lv_code AT lc_arrow INTO TABLE lt_itab.
              READ TABLE lt_itab INTO ls_itab INDEX 2.
              IF sy-subrc EQ 0.
                SPLIT ls_itab AT '(' INTO lv_string1 lv_string2.
                REPLACE ALL OCCURRENCES OF ')' IN lv_string2 WITH space.
                REPLACE ALL OCCURRENCES OF '.' IN lv_string2 WITH space.

                CONDENSE lv_string2.
                ls_mpc-fieldname  = lv_string2.
                CLEAR : lv_string1,lv_string2,ls_itab.
                REFRESH: lt_itab.
              ENDIF.

              CLEAR : gv_count_prop,gv_create_check,gv_check_prop.
            ENDIF.
            "Get the fieldname of 'CREATE_ENTITY_TYPE'
            IF ls_mpc-sub_method EQ lc_create_type.
              CLEAR : ls_itab.
              SPLIT lv_code AT space INTO TABLE lt_itab.
              READ TABLE lt_itab TRANSPORTING NO FIELDS WITH KEY  keypart = lc_entity_name.
              IF sy-subrc EQ  0.
                lv_index  = sy-tabix.
                lv_index  = lv_index  + 2.
                READ TABLE lt_itab INTO ls_itab INDEX lv_index.
                IF sy-subrc EQ 0.
                  ls_mpc-fieldname  = ls_itab-keypart.
                ENDIF.
              ENDIF.
            ENDIF.
            "Get association field name
            IF ls_mpc-sub_method EQ lc_create_ass.
              CLEAR : ls_itab.
              SPLIT lv_code AT space INTO TABLE lt_itab.
              READ TABLE lt_itab TRANSPORTING NO FIELDS WITH KEY  keypart = lc_assoc_name.
              IF sy-subrc EQ  0.
                lv_index  = sy-tabix.
                lv_index  = lv_index  + 2.
                READ TABLE lt_itab INTO ls_itab INDEX lv_index.
                IF sy-subrc EQ 0.
                  ls_mpc-fieldname  = ls_itab-keypart.
                ENDIF.
              ENDIF.
            ENDIF.
            "Get association set field
            IF ls_mpc-sub_method EQ lc_assoc_set.
              CLEAR : ls_itab.
              SPLIT lv_code AT space INTO TABLE lt_itab.
              READ TABLE lt_itab TRANSPORTING NO FIELDS WITH KEY  keypart = lc_assoc_set_iv.
              IF sy-subrc EQ  0.
                lv_index  = sy-tabix.
                lv_index  = lv_index  + 2.
                READ TABLE lt_itab INTO ls_itab INDEX lv_index.
                IF sy-subrc EQ 0.
                  ls_mpc-fieldname  = ls_itab-keypart.
                ENDIF.
              ENDIF.
            ENDIF.
            "Get navigation property
            IF ls_mpc-sub_method EQ lc_cr_nav_prop.
              CLEAR : ls_itab.
              SPLIT lv_code AT space INTO TABLE lt_itab.
              READ TABLE lt_itab TRANSPORTING NO FIELDS WITH KEY  keypart = lc_prop_name.
              IF sy-subrc EQ  0.
                lv_index  = sy-tabix.
                lv_index  = lv_index  + 2.
                READ TABLE lt_itab INTO ls_itab INDEX lv_index.
                IF sy-subrc EQ 0.
                  ls_mpc-fieldname  = ls_itab-keypart.
                ENDIF.
              ENDIF.
            ENDIF.
            "create action
            IF ls_mpc-sub_method EQ lc_create_action.
              CLEAR : ls_itab.
              REFRESH: lt_itab.
              SPLIT lv_code AT space INTO TABLE lt_itab.
              READ TABLE lt_itab TRANSPORTING NO FIELDS WITH KEY  keypart = lc_action_name.
              IF sy-subrc EQ  0.
                lv_index  = sy-tabix.
                lv_index  = lv_index  + 2.
                READ TABLE lt_itab INTO ls_itab INDEX lv_index.
                IF sy-subrc EQ 0.
                  ls_mpc-fieldname  = ls_itab-keypart.
                ENDIF.
              ELSE.
                READ TABLE lt_itab INTO ls_itab INDEX 4.
                IF sy-subrc EQ 0.
                  SPLIT ls_itab AT '(' INTO lv_string1 lv_string2.
                  REPLACE ALL OCCURRENCES OF ')' IN lv_string2 WITH space.
                  REPLACE ALL OCCURRENCES OF '.' IN lv_string2 WITH space.
                  CONDENSE ls_itab-keypart.
                  ls_mpc-fieldname  = ls_itab-keypart.
                ENDIF.
              ENDIF.
            ENDIF.
            "create complex type
            IF ls_mpc-sub_method EQ lc_cr_complex.
              CLEAR : ls_itab.
              REFRESH: lt_itab.

              SPLIT lv_code AT space INTO TABLE lt_itab.
              READ TABLE lt_itab TRANSPORTING NO FIELDS WITH KEY  keypart = lc_cr_typ_nam.
              IF sy-subrc EQ  0.
                lv_index  = sy-tabix.
                lv_index  = lv_index  + 2.
                READ TABLE lt_itab INTO ls_itab INDEX lv_index.
                IF sy-subrc EQ 0.
                  ls_mpc-fieldname  = ls_itab-keypart.
                ENDIF.
              ELSE.
                READ TABLE lt_itab INTO ls_itab INDEX 4.
                IF sy-subrc EQ 0.
                  SPLIT ls_itab AT '(' INTO lv_string1 lv_string2.
                  REPLACE ALL OCCURRENCES OF ')' IN lv_string2 WITH space.
                  REPLACE ALL OCCURRENCES OF '.' IN lv_string2 WITH space.
                  CONDENSE ls_itab-keypart.
                  ls_mpc-fieldname  = ls_itab-keypart.
                ENDIF.
              ENDIF.
            ENDIF.
            "add edm type field name
            IF ls_mpc-sub_method EQ lc_edm_typ.
              ls_mpc-edm_field  = gv_field_name.
            ENDIF.

            APPEND ls_mpc TO lt_mpc.
*            CLEAR ls_mpc.
          ELSE.
*            <do nothing>
          ENDIF.
        ELSE.
          CLEAR lv_start.
          IF lv_code CS lc_init_bc.
            lv_start  = sy-fdpos.
            ls_mpc-sub_method  = lv_code+0(lv_start).
            ls_mpc-parent_method  = gv_parent_method.
            ls_mpc-line_no  = i_index.
            ls_mpc-code = lv_code.
            IF lv_string1 CS lc_eq."check for '='
              SPLIT lv_string1 AT lc_eq INTO lv_string3 lv_string4.
              ls_mpc-instance = lv_string3.
            ELSE.
              ls_mpc-instance = lv_string1.
            ENDIF.
            APPEND ls_mpc TO lt_mpc.
          ENDIF.
        ENDIF.
      ENDIF.
      "end of logic to get the method name
      "variables to check the properties
      IF ls_mpc-sub_method EQ lc_create_type  .
        gv_create_check = abap_true.
        gv_check_prop   = abap_true."to check label
        "get the importing parameter

      ENDIF.
      CLEAR ls_mpc.
    ENDIF.
  ENDMETHOD.

  METHOD is_class_found.

    IF i_class IS NOT INITIAL.
      READ TABLE lo_cl_odata->lt_class INTO lo_cl_odata->ls_class WITH KEY dpc_class = i_class.
      IF sy-subrc NE 0.
        READ TABLE lo_cl_odata->lt_class INTO lo_cl_odata->ls_class WITH KEY dpc_ext_class = i_class.
        IF sy-subrc NE 0.
          READ TABLE lo_cl_odata->lt_class INTO lo_cl_odata->ls_class WITH KEY mpc_ext_class = i_class.
          IF sy-subrc NE 0.
            READ TABLE lo_cl_odata->lt_class INTO lo_cl_odata->ls_class WITH KEY mpc_class = i_class.
            IF sy-subrc NE 0.
            ELSE.
              e_ok  = abap_true.
              e_serv_name  = lo_cl_odata->ls_class-service_name.
              e_mpc = abap_true.
              e_odata = lo_cl_odata->ls_class-odata. "Added by Akshay_Def_35
            ENDIF.
          ELSE.
            e_ok  = abap_true.
            e_serv_name  = lo_cl_odata->ls_class-service_name.
            e_mpc_ext    =  abap_true.
            e_odata = lo_cl_odata->ls_class-odata. "Added by Akshay_Def_35
          ENDIF.
        ELSE.
          e_ok  = abap_true.
          e_serv_name  = lo_cl_odata->ls_class-service_name.
          e_odata = lo_cl_odata->ls_class-odata. "Added by Akshay_Def_35
        ENDIF.
      ELSE.
        e_ok  = abap_true.
        e_serv_name  = lo_cl_odata->ls_class-service_name.
        e_odata = lo_cl_odata->ls_class-odata. "Added by Akshay_Def_35
      ENDIF.
    ENDIF.

  ENDMETHOD.

* Begin of changes by Akshay for OData_Def_25

  METHOD get_value_odata.

    IF i_class IS  NOT INITIAL.


      READ TABLE lo_cl_odata->lt_class INTO lo_cl_odata->ls_class WITH KEY dpc_class = i_class.
      IF sy-subrc NE 0.
        READ TABLE lo_cl_odata->lt_class INTO lo_cl_odata->ls_class WITH KEY mpc_class = i_class.
        IF sy-subrc NE 0.
          READ TABLE lo_cl_odata->lt_class INTO lo_cl_odata->ls_class WITH KEY mpc_ext_class = i_class.
          IF sy-subrc NE 0.
            READ TABLE lo_cl_odata->lt_class INTO lo_cl_odata->ls_class WITH KEY dpc_ext_class = i_class.
            IF sy-subrc NE 0.
            ELSE.
              e_odata  = lo_cl_odata->ls_class-odata.
            ENDIF.
          ELSE.
            e_odata  = lo_cl_odata->ls_class-odata.
          ENDIF.
        ELSE.
          e_odata  = lo_cl_odata->ls_class-odata.
        ENDIF.
      ELSE.
        e_odata  = lo_cl_odata->ls_class-odata.
      ENDIF.

    ENDIF.

  ENDMETHOD.

* End of changes by Akshay for OData_Def_25


  METHOD check_camel_case.

    DATA : lv_count  TYPE i,
           lv_loop   TYPE i,
           lv_word   TYPE char1,
           lv_string TYPE string.

    IF i_field IS NOT INITIAL.
      lv_string = i_field.
    ENDIF.

    lv_count  = strlen( lv_string ).

    DO lv_count TIMES  .
      lv_loop   = lv_loop + 1.
      IF lv_loop EQ 1.
        lv_word = lv_string+0(1) .
        IF lv_word CA 'ABCDEFGHIJKLMNOPQRSTUVWXYZ'.
          CONTINUE.
        ELSE.
          e_error = abap_true.
          EXIT.
        ENDIF.
      ELSE.
        IF lv_string+0(lv_loop) CA 'abcdefghijklmnopqrstuvwxyz'.
          CONTINUE.
        ELSE.
          e_error = abap_true.
          EXIT.
        ENDIF.
      ENDIF.
    ENDDO.
  ENDMETHOD .

  METHOD check_edm_type.

    TYPES:
      BEGIN OF ty_gs_edm_field_desc,
        core_type       TYPE  /iwbep/if_mgw_med_odata_types=>ty_e_med_edm_type, "EDM Data Type
        length          TYPE  i,  "Length (No. of Characters)
        decimals        TYPE  i,  "Number of Decimal Places
        internal_type   TYPE  inttype,
        internal_length TYPE  i,
        input_mask      TYPE string,
        conv_exit       TYPE /iwbep/if_mgw_med_odata_types=>ty_e_med_conv_exit,
        semantic        TYPE /iwbep/if_mgw_med_odata_types=>ty_e_med_semantic,
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
        cs_edm_type-core_type = /iwbep/if_mgw_med_odata_types=>gcs_edm_data_types-string.
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
            cs_edm_type-core_type = /iwbep/if_mgw_med_odata_types=>gcs_edm_data_types-boolean.
          WHEN 'SYSUUID_22' OR
               'SYSUUID_C' OR
               'SYSUUID_C22'.
            cs_edm_type-core_type = /iwbep/if_mgw_med_odata_types=>gcs_edm_data_types-guid.
          WHEN OTHERS.
            IF p_dfies-leng EQ 1 AND
              ( p_dfies-domname CP '*BOOL*' OR
                p_dfies-domname CP '*FLAG*' ).
              cs_edm_type-core_type = /iwbep/if_mgw_med_odata_types=>gcs_edm_data_types-boolean.
            ELSEIF p_dfies-leng EQ 32 AND
              ( p_dfies-domname CP '*UUID*' OR
                p_dfies-domname CP '*GUID*' ).
              cs_edm_type-core_type = /iwbep/if_mgw_med_odata_types=>gcs_edm_data_types-guid.
            ELSE.
              cs_edm_type-core_type = /iwbep/if_mgw_med_odata_types=>gcs_edm_data_types-string.
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
        cs_edm_type-core_type = /iwbep/if_mgw_med_odata_types=>gcs_edm_data_types-string.
        cs_edm_type-input_mask = '[0-9]*'.   "Regular expression allowing only the letters 0-9
*      ENDCASE.
      WHEN cl_abap_typedescr=>typekind_date.
        IF iv_odata_version EQ 'V2'.
          cs_edm_type-core_type = /iwbep/if_mgw_med_odata_types=>gcs_edm_data_types-datetime.     "'Edm.DateTime'. (There is no Edm.Date, fill the rest with 0s)
        ELSE.
          cs_edm_type-core_type = /iwbep/if_mgw_med_odata_types=>gcs_edm_data_types-date.
        ENDIF.
        CLEAR cs_edm_type-length_org.
      WHEN cl_abap_typedescr=>typekind_time.
        IF iv_odata_version EQ 'V2'.
          cs_edm_type-core_type = /iwbep/if_mgw_med_odata_types=>gcs_edm_data_types-time.
        ELSE.
          cs_edm_type-core_type = /iwbep/if_mgw_med_odata_types=>gcs_edm_data_types-timeofday.
        ENDIF.
        CLEAR cs_edm_type-length_org.
      WHEN cl_abap_typedescr=>typekind_xstring.
        cs_edm_type-core_type = /iwbep/if_mgw_med_odata_types=>gcs_edm_data_types-binary.
      WHEN cl_abap_typedescr=>typekind_hex.
        CASE p_dfies-domname.
          WHEN 'SYSUUID'.
            cs_edm_type-core_type = /iwbep/if_mgw_med_odata_types=>gcs_edm_data_types-guid.
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
            cs_edm_type-core_type = /iwbep/if_mgw_med_odata_types=>gcs_edm_data_types-datetimeoffset.
          WHEN OTHERS.
            cs_edm_type-core_type = /iwbep/if_mgw_med_odata_types=>gcs_edm_data_types-decimal.
        ENDCASE.
        CLEAR cs_edm_type-length_org.
      WHEN cl_abap_typedescr=>typekind_int1.
        cs_edm_type-core_type = /iwbep/if_mgw_med_odata_types=>gcs_edm_data_types-byte.
        CLEAR cs_edm_type-length_org.
      WHEN cl_abap_typedescr=>typekind_int2.
        cs_edm_type-core_type = /iwbep/if_mgw_med_odata_types=>gcs_edm_data_types-int16.
        CLEAR cs_edm_type-length_org.
      WHEN cl_abap_typedescr=>typekind_int.
        cs_edm_type-core_type = /iwbep/if_mgw_med_odata_types=>gcs_edm_data_types-int32.
        CLEAR cs_edm_type-length_org.
      WHEN cl_abap_typedescr=>typekind_float.
        cs_edm_type-core_type = /iwbep/if_mgw_med_odata_types=>gcs_edm_data_types-double.
        CLEAR cs_edm_type-length_org.

*   In 7.00 the following types do not exist, but they do exist in 7.02 or 7.50
*   (see for reference method GET_ABAP_TYPE_FROM_EDM_TYPE)
      WHEN gcs_abap_typekind-decfloat.
        cs_edm_type-core_type = /iwbep/if_mgw_med_odata_types=>gcs_edm_data_types-decimal.
        CLEAR cs_edm_type-length_org.
      WHEN gcs_abap_typekind-decfloat16.
        cs_edm_type-core_type = /iwbep/if_mgw_med_odata_types=>gcs_edm_data_types-decimal.
        CLEAR cs_edm_type-length_org.
      WHEN gcs_abap_typekind-decfloat34.
        cs_edm_type-core_type = /iwbep/if_mgw_med_odata_types=>gcs_edm_data_types-decimal.
        CLEAR cs_edm_type-length_org.
      WHEN gcs_abap_typekind-int8.                      "#EC CI_INT8_OK
        cs_edm_type-core_type = /iwbep/if_mgw_med_odata_types=>gcs_edm_data_types-int64.
        CLEAR cs_edm_type-length_org.
      WHEN OTHERS.
        cs_edm_type-core_type = 'NA'.
*        ASSERT 1 = 0. "unsupported type
    ENDCASE.
    e_edm_typ = cs_edm_type-core_type.
  ENDMETHOD.
ENDCLASS.
*&---------------------------------------------------------------------*
*& Form FILL_POOL_CLUSTER
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM fill_pool_cluster .
  TYPES:
    BEGIN OF ty_tabclass,
      tabname  TYPE dd02l-tabname,
      tabclass TYPE dd02l-tabclass,
    END   OF ty_tabclass .

  DATA :gt_tabclass TYPE TABLE OF  ty_tabclass,
        l_wa        TYPE ty_tabclass.

  "Cluster tables
  l_wa-tabclass = 'CLUSTER'.
  l_wa-tabname = 'AUAA'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'AUAB'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'AUAO'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'AUAS'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'AUAT'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'AUAV'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'AUAW'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'AUAY'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'BSEC'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'BSED'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'BSES'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'BSET'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'CDPOS'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'CVEP11'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'CVEP12'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'CVEP13'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'CVEP14'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'CVEP21'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'CVEP22'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'CVEP23'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'CVEP24'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'CVER11'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'CVER12'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'CVER13'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'CVER14'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'CVER15'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'CVER21'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'CVER22'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'CVER23'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'CVER24'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'CVER25'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'CVER31'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'CVER32'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'CVER33'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'CVER50'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'CVER51'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'CVT1'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'CVT2'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'CVT3'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'DOKTL'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'DSYGH'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'DSYGI'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'DSYGL'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'DSYOL'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'DSYOT'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'EDID2'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'EDID4'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'EDIDD_OLD'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'GLIDXB'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'GLIDXC'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'GLS2IDX'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'J_CLUSTR01'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'KONV'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'MHND'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'MMIM_PRED'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'PCDPOS'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'REGUP'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T512U'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'CVERI_CLNT'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'SFHOT'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TAB1'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TAB2'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TACOPAC'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TACOPA'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TACOPAB'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TACOPAD'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TACOPB'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TACOPBA'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TACOPC'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TACOPCA'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TERMC1'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TERMC2'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TERMC3'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'UMG_TEST_B'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'UMG_TEST_D'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'UMG_TEST_G'.
*   insert L_WA into table GT_TABCLASS. L_WA-TABNAME = 'VBFA'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'BCC_S11CDA'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'BCC_S11CDC'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'BCC_S11CIG'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'BCC_S11CDE'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'BCC_S11CDG'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'BCC_S11CDS'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'BCC_S11CDW'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'BCC_S11CIC'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'BCC_S11CIE'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'BCC_T11CIE'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'BCC_S11CIS'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'BCC_S11CIW'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'BCC_T11CDA'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'BCC_T11CDC'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'BCC_T11CDE'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'BCC_T11CDG'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'BCC_T11CDS'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'BCC_T11CDW'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'BCC_T11CIC'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'BCC_V11CDE'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'BCC_T11CIG'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'BCC_T11CIS'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'BCC_T11CIW'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'BCC_T12CDA'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'BCC_T12CDC'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'BCC_T12CDE'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'BCC_T12CDG'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'BCC_T12CDS'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'BCC_T12CDW'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'BCC_T12CIC'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'BCC_T12CIE'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'BCC_T12CIG'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'BCC_T12CIS'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'BCC_T12CIW'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'BCC_V11CDA'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'BCC_V11CDC'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'BCC_V11CDG'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'BCC_V11CDS'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'BCC_V11CDW'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'BCC_V11CIC'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'BCC_V11CIE'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'BCC_V11CIG'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'BCC_V11CIS'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'BCC_V11CIW'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'BCC_S12CDA'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'BCC_S12CDC'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'BCC_S12CDE'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'BCC_S12CDG'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'BCC_S12CDS'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'BCC_S12CDW'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'BCC_S12CIC'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'BCC_V12CDA'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'BCC_V12CDC'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'BCC_V12CDE'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'BCC_V12CDG'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'BCC_V12CDS'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'BCC_V12CDW'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'BCC_V12CIC'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'BCC_V12CIE'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'BCC_V12CIG'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'BCC_V12CIS'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'BCC_V12CIW'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'BCC_S12CIE'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'BCC_S12CIG'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'BCC_S12CIS'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'BCC_S12CIW'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'BCC_V11CIA'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'BCC_S11CIA'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'BCC_T11CIA'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'BCC_S12CIA'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'BCC_V12CIA'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'BCC_T12CIA'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'VER29017CD'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'BSEG'.
  INSERT l_wa INTO TABLE gt_tabclass.

  "Pool tables

  l_wa-tabclass = 'POOL'.
  l_wa-tabname = 'A001'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'A004'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'A005'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'A006'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'A007'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'A009'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'A010'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'A012'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'A018'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'A015'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'A017'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'A016'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'A019'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'A021'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'A022'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'A026'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'A023'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'A025'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'A024'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'A028'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'A032'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'A030'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'A044'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'A047'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'A046'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'A045'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'A049'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'A051'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'A052'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'A054'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'A053'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'A058'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'A060'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'A059'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'A061'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'A062'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'A063'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'B006'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'B030'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'B061'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'B065'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'B062'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'B064'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'B055'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'B063'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'B066'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'AT14'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'AT181'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'AT181T'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'AT30'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'AT40'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'AT40T'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'AT53'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T52CX'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'BC325V00'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'BC325V10'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'BC325X00'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'BC325X01'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'BC325X02'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'BC325X03'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'BC325X04'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'BC325X05'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'BC325X06'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'BC325X07'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'BC325X08'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'BC325X09'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'BC325X10'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'BC325X11'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'BC325X12'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'BC325X13'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'BC325X14'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'BC325X15'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'BC325X16'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'BC325X17'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'BC325X18'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'BC325X19'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'BC325X20'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'BC325X21'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'BC325X22'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'BC325X23'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'BC325X24'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'BC325X25'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'BC325X26'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'BC325X27'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'BC325X28'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'BC325X29'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'BC325X30'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'BC325X31'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'BC325X32'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'BC325X33'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'BC325X34'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'BC325X35'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'BC325X36'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'BC325X37'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'BC325X38'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'BC325X39'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'BC325X40'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T535Q'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T535W'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T510Y'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T512H'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T512I'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'CF002'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'CF004'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'CHK_DECIDE'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T512V'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T161V'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T513D'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T513K'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T513L'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T513M'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T513N'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T513O'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T513Q'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T5C1S'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T5C1T'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T521T'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T5A3T'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T5C1W'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T5A4B'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T5A4C'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'DDPAMSCTRL'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'DDSYN'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T5A4F'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T5A4G'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T5A4I'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T5A4T'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T5A4U'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T5A4V'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'DICS_T150'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'DICS_T150F'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'DICS_T156B'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'DICS_T156C'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'DICS_T156F'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'DICS_T156M'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'DICS_T156V'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'DICS_T157B'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'DICS_T157H'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T527'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'DVK00'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'DVKTX'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T5F2C'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T5F2P'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T5BP1'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T5BP2'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T588F'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T5BP3'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T5D5A'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T589A'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T5G21'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T5G23'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T5M13'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T5M1T'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T5M2D'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T5M2P'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T5M2T'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T5M3O'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T5M4F'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T5M4S'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T770C'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T705S'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'FB03'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'FINK'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'FINP'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'FINT'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'FKKCLEDRI'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'FKKCLEGP'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'FKKCLEGPI'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'FKKCLEVK'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'FKKCLEVKI'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'FKKCLEZW2I'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'FKKCLEZWFI'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'FKKNUMKR'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T752A'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'FKKVKOPA'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T522F'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T510N'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T541N'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T541T'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'FMVALID'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T5D1W'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T5D3D'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T703A'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T704M'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T5B9G'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'GB91T'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'GLP1'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'GLP2'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'GLPPC'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'GLS1'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'GLS2'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'GLSPC'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'GLT1'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'GLT2'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TFKB_015W'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TJP_ESSPDC'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TJP_ESSPDF'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TJP_ESSPFC'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TKEB3'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TW52T'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'AT60'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'ICLUSCNTXT'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'INDEXDT'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'ISUERDK'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'ISUNUMKR'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T546'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T555S'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T5D14'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'FKKNRRANGE'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T703N'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'JSDTPAER'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'JVS1'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'J_POOL01'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'J_POOL_F01'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'J_POOL_G01'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'J_POOL_S01'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'K9001'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'MCLIK'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'MCLIL'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'MCLIM'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'AT02T'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'MWCURM'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'M_MTVMA'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'M_MTVMB'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'M_MTVMC'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'M_MTVMD'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'M_MTVME'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'M_MTVNF'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'M_MTVNG'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'M_MTVNH'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'M_MTVNI'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'M_MTVNJ'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'M_MTVNK'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'M_MTVNL'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'M_MTVOA'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'M_MTVOB'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'M_MTVOC'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'M_MTVOE'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'M_MVERA'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'M_MVERB'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'M_MVERC'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'M_MVERD'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TNDR2'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'PVERI_CLNT'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'POTAB'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'PTEST2'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'PUVT1'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'PUVT2'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'PVEG1'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'PVEU11'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'PVEU12'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'PVEU13'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'PVEU14'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'PYONUMKR'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'RFCTA'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'RFCTYPE'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T506T'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T510V'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T510O'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T5D5K'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T5A4P'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T5A5T'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T5D6G'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T527A'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T527O'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T513P'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T5A2S'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T5A2T'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T5A3A'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T5A4'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T5G20'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T5A4H'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T535R'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T536A'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T5B6B'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T548S'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T5C13'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T5C14'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T5C15'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T5C1K'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T5C1P'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T5C1Q'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T5F03'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T564T'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T578A'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T5F3A'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T582B'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T585A'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T585B'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T585C'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T588C'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T588J'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T5D1B'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T5D1D'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T5D1I'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T596F'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T5D1O'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T596U'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T5A2C'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T5A2E'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T5D4A'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T5K0Q'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'RSDCX'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'RSNTR'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'ARCH_NUM'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'RVTXOBJ'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T5M2S'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T5W2F'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'SFIA'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'SFIAT'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'SFICD'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'SFICL'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'SFICT'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'SFINO'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'SFITH'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T703'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'STXXFILTER'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T001T'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T000C'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T001E'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T001F'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T001I'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T001J'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T001R'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T001S'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T001X'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T001Z'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T003A'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T003M'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T003T'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T004F'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T004G'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T004R'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T004S'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T004T'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T004V'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T004W'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T005Q'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T005R'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T005X'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T007B'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T007G'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T007H'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T007S'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T008'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T008T'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T009'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T009B'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T009C'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T009T'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T009Y'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T010O'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T010P'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T011P'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T011Q'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T011Z'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T012E'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T014N'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T015L'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T015M'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T015W'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T015Z'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T016'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T016T'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T017'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T018C'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T018D'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T018P'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T019'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T019W'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T020'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T021'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T021A'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T021B'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T021C'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T021D'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T021F'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T021G'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T021J'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T021N'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T021P'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T021Q'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T021R'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T021T'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T021V'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T021Z'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T036Q'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T027C'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T027D'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T028A'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T028B'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T028D'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T028E'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T030'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T030A'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T030B'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T030C'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T030D'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T030E'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T030F'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T030G'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T030H'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T030HB'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T030I'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T030K'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T030Q'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T030R'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T030S'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T030V'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T030W'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T030X'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T030Y'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T031'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T031S'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T031T'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T033A'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T033B'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T033D'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T033E'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T033F'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T033G'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T033I'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T033J'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T033O'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T033P'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T033U'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T035V'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T036O'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T036P'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T036S'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T037'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T037A'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T037R'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T037S'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T037T'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T038V'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T040'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T040A'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T040S'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T040T'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T041A'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T041T'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T042'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T042A'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T042D'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T042F'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T042G'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T042H'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T042I'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T042J'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T042K'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T042L'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T042M'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T042N'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T042P'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T042S'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T042V'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T043'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T043G'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T043K'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T043S'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T043T'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T044A'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T044B'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T056A'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T044E'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T044Z'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T045B'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T045D'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T045E'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T045G'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T045L'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T046'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T046T'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T047'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T047A'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T047B'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T047C'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T047D'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T047E'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T047F'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T047H'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T047M'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T047N'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T047R'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T047S'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T047T'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T048'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T048B'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T048I'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T048K'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T048L'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T048T'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T049C'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T049E'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T049F'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T049L'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T050T'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T052A'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T052R'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T052S'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T052T'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T053'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T053E'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T053V'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T053W'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T054'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T054A'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T054T'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T055G'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T055T'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T056'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T074'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T056B'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T056D'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T056F'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T056L'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T056S'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T056T'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T056U'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T056X'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T056Y'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T057'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T057T'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T059A'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T059B'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T059F'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T059L'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T059M'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T059T'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T060'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T060A'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T060B'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T060O'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T060S'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T060T'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T060U'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T063'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T063C'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T063F'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T063O'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T063T'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T064F'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T064S'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T064T'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T066'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T066K'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T068A'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T068B'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T069'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T069Q'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T069T'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T070'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T071'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T074A'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T074T'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T077S'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T077T'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T077X'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T077Y'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T077Z'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T078S'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T078W'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T082A'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T082E'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T082S'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T083L'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T083S'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T083T'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T084A'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T086A'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T086T'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T087I'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T087J'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T088'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T089T'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T090I'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T090W'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T090X'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T090Y'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T092'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T092T'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T093D'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T093F'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T093N'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T093S'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T093U'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T093Y'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T094'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T094C'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T097'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T097T'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T098'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T098T'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T099B'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T099V'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T147E'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T100C'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T100S'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T130C'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T130D'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T130G'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T130M'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T130O'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T130P'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T130S'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T130Z'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T131A'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T131T'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T131V'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T131X'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T134W'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T135A'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T136'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T136V'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T138A'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T138B'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T138C'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T138M'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T138V'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T139A'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T139B'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T147'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T147A'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T147C'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T147H'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T147K'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T147L'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T147M'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T147N'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T147O'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T148A'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T148B'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T148G'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T148M'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T150'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T150F'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T156B'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T156C'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T156H'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T156K'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T156N'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T156V'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T157B'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T157D'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T157E'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T157F'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T157H'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T157N'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T157O'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T157P'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T157Q'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T157R'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T157T'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T158'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T158B'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T158I'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T158N'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T158T'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T158V'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T158W'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T159B'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T159E'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T159G'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T159H'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T159M'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T159N'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T159O'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T159P'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T159Q'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T159R'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T159S'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T159T'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T164C'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T160'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T160B'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T160C'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T160D'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T160E'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T160I'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T160J'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T160L'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T160O'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T160P'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T160Q'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T160R'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T160S'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T160T'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T160V'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T160W'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T160X'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T160Y'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T161A'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T161B'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T161E'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T161F'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T161G'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T161H'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T161I'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T161N'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T161R'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T161S'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T161U'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T161Z'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T162K'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T162T'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T162X'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T162Y'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T163A'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T164A'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T164O'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T164U'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T164Y'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T165K'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T165P'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T166T'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T166U'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T167'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T167T'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T168'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T168F'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T168T'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T169'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T169A'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T169B'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T169E'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T169F'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T169G'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T169K'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T169O'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T169P'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T169S'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T169T'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T169V'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T169W'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T169X'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T180T'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T180U'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T180V'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T181F'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T181S'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T181T'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T184'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T184L'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T237'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T2410'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T2411'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T241E'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T241H'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T241S'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T241Z'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T2421'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T242E'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T242H'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T242I'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T242N'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T242S'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T242T'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T242Z'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T243A'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T243B'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T243C'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T243D'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T2512'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T2513'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T2514'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T2538'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T258A'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T258E'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T258F'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T258I'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T258K'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T258W'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T25B2'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T25B3'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T25B4'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T25D8'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T340'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T341'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T342'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T350W'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T354S'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T365'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T365A'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T370'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T370A'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T370Z'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T371A'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T371A_T'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T371D'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T390'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T390D'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T390_O'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T390_T'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T392'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T399J'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T399P'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T399W'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T401M'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T401Z'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T409'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T440G'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T437D'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T437T'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T437V'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T437W'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T437Z'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T439F'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T439I'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T439J'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T440B'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T440F'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T459C'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T440L'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T440X'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T440Z'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T441M'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T444K'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T444M'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T445S'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T449U'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T450'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T450A'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T450F'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T450P'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T457A'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T457G'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T457I'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T457J'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T457K'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T457L'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T457S'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T459R'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T460B'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T460D'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T460Q'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T488T'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T490'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T496B'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T496F'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T496K'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T496N'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T496R'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T496T'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T498'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T498T'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T5S3A'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T5S3B'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T5S3I'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T5S4A'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T5S5A'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T5S3J'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T5S3L'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T526'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T5S3Q'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T578Y'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T5D1U'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T605Z'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T616Z'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T630L'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T630R'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T672'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T681U'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T681X'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T681Z'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T682V'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T684G'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T684S'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T687'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T687T'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T688'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T688K'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T688T'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T691A'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T691B'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T691C'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T691I'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T691J'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T691T'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T6B2F'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T6WL1'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T6WP5'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T5C1E'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T5C1J'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T5C1Z'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T5C1F'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T5C1G'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TZST1'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T731'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T731N'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T731O'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T731P'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T731T'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T5DCK'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T800V'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T800W'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T800X'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T801A'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T801C'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T801N'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T801P'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T801R'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T801U'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T801V'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T802A'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T803A'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T803B'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T803C'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T803D'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T803E'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T803I'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T803Z'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T804D'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T80U'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T80UT'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T810A'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T820F'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T821V'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T868'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T884B'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T884C'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T887'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T887C'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T889A'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T889B'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T889C'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T889T'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T891B'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T891C'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T892B'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T892C'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T895'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T895C'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T9COM'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T9DEV'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T9PRO'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TABS1_VER'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TABS2_VER'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TABWB'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TABWI'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TABWK'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TABWN'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TABWV'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TACO1'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TALLG'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TAM0T'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TAPGPCB'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TAPLP'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TAPLT'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TAPOL'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TAPOPA'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TAPOPB'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TAPOPBA'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TAPOPCB'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TAPOPM'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TAPPL'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TAPPPA'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TAPPPB'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TAPPPBA'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TAPPPCB'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TAPVPA'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TAPVPB'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TAPVPBA'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TAPVPCB'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TAUUM'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TBACN'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TBEKR'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TBER'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TBERG'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TBERX'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TBKOW'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TBLP_MODF'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TBLP_MODG'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TBLP_MODO'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TBLP_MODP'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TBP1A'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TBP1B'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TBPFC'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TBSL'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TBSLT'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TBSP1'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TBVZ'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TBVZT'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TC03'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TC28A'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TC29'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TC29F'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TC29L'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TC29R'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TC29S'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TC29T'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TC29V'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TC30C'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TC34'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TC35A'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TC62'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TCA01'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TCA01A'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TCA01B'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TCA02'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TCA03'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TCA04'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TCA05'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TCA09'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TCA09T'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TCA10'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TCA11'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TCA12'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TCA13'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TCA14'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TCA15'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TCA17'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TCA18'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TCA19'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TCA21'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TCA22'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TCA31'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TCA33'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TCA34'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TCA35'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TCA42'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TCA43'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TCA44'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TCA60'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TCA61'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TCA64'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TCA65'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TCA9T'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TCALA'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TCAM1'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TCAM2'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TCAM3'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TCAPR'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TCAPS'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TCDOBT'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TCER1'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TCETV'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TCEVC'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TCEVV'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TCEVVT'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TCF06'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TCF07'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TCF08'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TCIC'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TCIM'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TCIQ'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TCIR'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TCJO2'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TCK21'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TCKHA'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TCKM1'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TCKM2'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TCKMT'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TCLC'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TCLD'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TCMV'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TCN05'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TCO09'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TCNRT'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TCO01'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TCO03'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TCO04'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TCO10'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TCO11'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TCO41'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TCO60'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TCO61'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TCO63'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TCOBD'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TCOBF'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TCOBK'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TCOBL'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TCOBM'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TCOKO'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TCORV'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TCORW'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TCP02'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TCP03'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TCP04'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TCP05'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TCP06'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TCPIC'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TCPS'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TCRH0'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TCS01'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TCS05'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TCS07'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TCS11'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TCS13'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TCS19'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TCS22'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TCS31'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TCS32'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TCS33'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TCS34'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TCURB'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TCURD'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TCURL'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TCURM'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TCUSCUST'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TCUSX'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TCVAL'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TCY42'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TCX01'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TCX02'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TCX03'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TCY01'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TCY02'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TCY05'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TCY06'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TCY09'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TCY10'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TCY11'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TCY12'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TCY13'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TCY14'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TCY15'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TCY16'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TCY17'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TCY18'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TCY19'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TCY20'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TCY21'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TCY22'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TCY23'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TCY36'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TCY40'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TCY40K'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TCY40T'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TCY41'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TCY41T'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TCY42T'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TCY43'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TCY43T'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TD03A'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TD05'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TD05T'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TD06'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TD06F'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TD06G'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TD06T'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TD06U'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TD11'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TD11T'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TD12'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TD12T'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TD13'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TD13T'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TD14'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TD14T'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TD15'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TD15T'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TD20'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TD20T'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TD21T'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TD22'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TD22T'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TDA10'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TDA11'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TDB1'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TDBL'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TDBLT'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TDCLD'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TDCLT'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TDHIERKRIT'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TDKZ'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TDL1'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TDL1T'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TDL2'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TDL21'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TDL21T'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TDL2T'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TDLOANFUNC'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TDP1T'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TDM12'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TDM19'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TDM20'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TDM25'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TDM26'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TDM99'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TDMFC'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TDO1'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TDO1T'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TDO2'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TDO2T'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TDO3'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TDO3T'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TDO4'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TDO4T'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TDO5'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TDO5T'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TDO6'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TDO6T'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TDO7'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TDO7T'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TDOCU'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TDOKU'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TDP0T'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TDP1'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TDSOB'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TDP2T'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TDP3'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TDP4'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TDPZB'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TDR01'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TDSGH'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TDSGL'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TDSIU'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TDSOF'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TDSOT'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TDSYH'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TDSYI'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TDSYL'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TDSYT'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TDVK'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TDl_waI'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TDWC'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TDWF'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TDXBL'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TDZW'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TDZWT'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TE001R'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TEBO'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TEBOT'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TEDEF'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TEDCT'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TEDE3'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TER14'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TER17'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TERM1'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TERMB'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TERMP'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TERMU'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TEUDB'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TF123'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TFAV'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TFAVT'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TFAVW'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TFAVZ'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TFB03T'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TFB05'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TFB06'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TFBUF'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TFCS'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TFE01'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TFE02'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TFE05'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TFE18'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TFE19'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TFIA'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TFIAT'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TFIC'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TFICT'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TFIT'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TFITH'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TFITT'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TFK001R'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TFK007E'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TFK015W'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TFK036S'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TFK036V'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TFKT'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TFKY3'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TFKY4'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TFM01'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TFM02'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TFM03'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TFM05'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TFM06'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TFM07'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TFM08'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TFM09'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TFM10'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TFM11'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TFM12'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TFM13'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TFM16'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TFMC'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TFO01'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TFO02'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TFO03'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TFO04'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TFO05'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TFO06'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TFREP'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TFRM'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TFRMT'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TFTMV'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TGFT'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TGFTT'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TGSBL'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TGSU0'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TGTB'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'THIOZ'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'THIZU'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'THLPC'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'THLPV'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TIA1T'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TIG20'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TIH01'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TIK0B'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TIMG4'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TIMG3'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TINGU'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TINPA'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TIPAZ'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TIS01'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TIS02'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TIV02'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TIV09'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TIV0A'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TIV0C'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TIV0G'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TIV0H'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TIV0I'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TIV10'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TIV12'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TIV14'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TIV15'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TIV16'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TIV17'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TIV19'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TIV1A'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TIV1B'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TIV1C'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TIV1D'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TIV20'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TIV21'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TIV22'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TIV23'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TIV24'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TIV25'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TIV79'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TIV28'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TIV2T'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TIV30'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TIV31'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TIV32'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TIV34'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TIV35'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TIV36'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TIV38'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TIV39'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TIV3A'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TIV3B'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TIV3C'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TIV3D'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TIV3F'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TIV3H'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TIV3I'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TIV41'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TIV43'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TIV44'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TIV45'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TIV4A'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TIV4C'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TIV4D'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TIV4E'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TIV56'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TIV57'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TIV58'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TIV59'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TIV5A'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TIV5B'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TIV5D'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TIV5E'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TIV5F'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TIV5G'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TIV5H'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TIV5I'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TIV5T'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TIV60'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TIV61'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TIV62'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TIV64'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TIV65'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TIV6A'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TIV6B'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TIV6C'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TIV6T'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TIV70'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TIV71'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TIV72'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TIV73'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TIV77'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TIV78'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TIV7A'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TIV7B'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TIV7C'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TIV7D'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TIV80'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TIV81'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TIV89'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TIVZW'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TJ016U'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TK11'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TK180'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TKA04'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TKA11'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TKA20'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TKA3A'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TKA3C'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TKA3P'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TKA4'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TKA4E'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TKABE'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TKAUM'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TKAVT'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TKAZ'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TKAZE'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TKAZT'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TKB08'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TKB2C'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TKB3'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TKB7B'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TKB7C'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TKB8A'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TKB8B'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TKCC'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TKCKC'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TKCKO'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TKCKU'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TKCTO'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TKCTU'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TKEA1'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TKEA2'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TKEBB'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TKEBF'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TKEDP'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TKEGC'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TKEIG'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TKENR'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TKEOE'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TKEPD'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TKEPT'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TKEVS'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TKEWP'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TKKEA'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TKKEP'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TKKPA'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TKKR1'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TKMGB'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TKO01'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TKOFA'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TKSA0'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TKSB0'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TKSBB'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TKSBC'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TKSBL'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TKSBR'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TKSBS'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TKSBT'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TKSBV'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TKSBZ'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TKSF0'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TKSKA'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TKSP1'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TKUPA'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TKV02'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TKV04'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TKV06'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TKV08'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TKV10'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TKV14'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TLMGB'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TLSY2'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TMAM'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TMAMT'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TMBCO'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TMCB'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TMCDF'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TMCOG'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TMCOL'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TMCSB'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TMCST'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TMCZT'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TMETA'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TMQ2'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TMFT'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TMFTT'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TMKG'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TMKGT'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TMKL'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TMKLT'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TMKR'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TMKSU'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TMKT'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TMLVW'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TMODF'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TMODG'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TMODO'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TMODP'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TMQ1'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TMVFP'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TMVFU'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TNAD1'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TNAD2'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TNAD3'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TNAD4'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TNAD5'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TNAD7'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TNAD8'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TNADR'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TNAPN'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TNATI'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TNIW3'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TNIW4'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TNIW5'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TNIW6'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TNIW8'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TNRGT'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TNRSO'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TNRT2'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TNRT2T'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TNRT2X'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TNRT2XT'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TNRT3'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TNRT3T'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TNRT5'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TNRT5T'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TNRT6'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TNRT6T'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TNRT7'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TNRT7T'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TNRT8'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TNRT8OT'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TNRT8T'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TOABA'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TOACL'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TOACM'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TOACU'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TOADY'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TOAP1'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TOASU'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TOBC'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TOBCT'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TOBJC'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TODOK'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TPAER'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TPAKD'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TPAUM'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TPERF'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TPF03'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TPGP'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TPGPT'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TPIND'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TPOTB'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TPRG'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TPTAB'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TPTDA'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TPTMZ'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TPTSP'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TQ03'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TQ27'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TQ27T'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TQ32'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TQ33'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TQ55'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TQ57'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TQ70'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TQ70E'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TQ70F'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TQBT'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TQBTT'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TQLOG'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TQLOT'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TQOP'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TQOPT'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TR01'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TR01T'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TRAS'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TRAST'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TRK10'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TRK1E'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TRK1S'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TRMAC'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TRSLT'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TRWCA'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TRWCI'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TRWPR'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TSADC'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TSADT'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TSADX'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TSAKR'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TSALQ'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TSARQ'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TSDDC'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TSDDD'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TSDDT'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TSDOC'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TSDUM'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TSE00'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TSE01'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TSE02'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TSE03'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TSE04'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TSE05'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TSE06'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TSE061N'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TSE07'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TSE08'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TSFGH'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TSFGL'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TSFST'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TSH01'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TSHCL'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TSKT2'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TSKTX'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TSL2D'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TSL2T'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TSL3D'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TSL3T'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TSM01'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TSOEX'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TSP07'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TSP08'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TSP09'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TSP0A'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TSP0F'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TSP0G'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TSP1D'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TSP1T'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TSP2D'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TSP2T'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TSP3T'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TSP4D'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TSP4T'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TSP5D'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TSP5T'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TSP6D'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TSP6T'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TSP7T'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TSPOL'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TSRCG'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TSST2'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TST05'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TSTE'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TSTGC'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TSTL'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TSTMT'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TSTOR'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TTAB'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TTABS'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TTBD'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TTBDT'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TTCGR'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TTDTG'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TTRCD'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TTXD'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TTXDT'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TTXER'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TTXF1'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TTXJT'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TTXS'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TTXVR'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TTXZI'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TTXZT'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TVARA'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TVARK'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TVARN'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TVARR'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TVASP'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TVBZ'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TVC7'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TVCPK'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TVCPL'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TVCPT'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TVEPZ'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TVFO'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TVFSP'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TVGAI'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TVGAP'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TVGAR'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TVGMS'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TVGVI'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TVGZU'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TVIND'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TVIP4'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TVIT4'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TVKB'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TVLSP'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TVMP4'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TVMT4'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TVOID'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TVOIT'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TVROA'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TVROB'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TVSFK'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TVSFP'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TVSG'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TVSRO'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TVZ01'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TVZ02'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TVZ03'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TVZ04'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TVZ05'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TVZ06'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TVZ0A'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TVZ0B'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TW01'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TW01T'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TW02'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TW02T'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TW03'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TW03T'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TW04'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TW04T'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TW05'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TW05T'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TW06'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TW06T'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TW07'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TW07T'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TW08'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TW08T'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TW09'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TW09B'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TW09T'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TW10'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TW10B'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TW10T'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TW11'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TW11T'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TW12'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TW12B'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TW12T'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TW14'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TW14T'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TW15'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TW16'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TW50'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TW50T'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TW52'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TW53'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TW53T'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TW54'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TW54T'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TW55'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TW55T'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TW56'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TW56T'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TWB08'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TWBBB'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TWFTT'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TWFAT'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TWFFP'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TWFNS'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TWFPC'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TWFPT'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TWFQU'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TWFRL'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TWFRT'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TWFSA'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TWFSY'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TWFTX'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TWH01'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TWL2'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TWL1'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TWL1T'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TWL2S'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TWL3'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TWL3T'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TWL4'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TWL5'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TWL5T'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TWL6'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TWRF'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TWRFR'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TWWTK'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TWZ03'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TWZ10'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TXBUF'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TXSTA'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TXV01'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TXV02'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TXV03'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TXV10'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TXV11'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T5C1H'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TZ22'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TZ01'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TZ01T'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TZ02'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TZ02T'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TZ10'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TZ10T'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TZ11'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TZ11T'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TZ12'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TZ12T'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TZ13'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TZ13T'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TZ14'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TZ14T'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TZ15'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TZ15T'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TZ16'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TZ16T'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TZ17'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TZ17T'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TZ18'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TZ18T'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TZ19'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TZ19T'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TZ21'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TZB06'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TZB07'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TZB0C'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TZB0G'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TZB0H'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TZB0R'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TZB0T'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TZB11'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TZBA'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TZBAT'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TZBBB'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TZBK'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TZC3N'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TZD0A'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TZD0B'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TZD1'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TZD1T'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TZD37'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TZE01'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TZE02'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TZE03'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TZE04'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TZE0B'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TZFBT'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TZFOH'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TZFOT'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TZFS'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TZFST'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TZGR'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TZGRT'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TZK04'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TZK05'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TZK06'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TZK0A'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TZK0D'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TZK0F'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TZK0G'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TZKM1'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TZM37'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TZN01'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TZN02'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TZN03'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TZN04'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TZPZE'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TZPZZ'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TZR3'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TZRCL'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TZRET'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TZRG'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TZRGT'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TZRI'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TZRIT'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TZRPR'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TZRR1'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TZRRT'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TZS12'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TZS13'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TZSBW'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TZST'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TZT01'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TZT15'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TZTXTS01'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TZUN'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TZUNI'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TZUNT'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TZUSAT'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TZV01'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TZV02'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TZV03'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TZV04'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TZV06'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TZV09'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TZV0D'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TZV0F'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TZV10'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TZV13'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TZV15'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TZV37'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TZV50'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TZV51'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TZVORG'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TZW01T'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TZW02'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'AT100'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'AT60T'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'UBEKL'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'AT01'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T5C1I'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'UMD01'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'UMG_TEST_T'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'UMG_TEST_A'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'UMG_TEST_Q'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'UMG_TEST_R'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'UMG_TEST_U'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'USRMM'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'VTIUL'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T457T'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T457TBLP'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T5A4W'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T457H'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TN18C'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TN1LST'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TN1LSTT'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TN18D'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T704O'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'A400'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'A401'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TSHM0'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TSPRF'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TSTAM'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TCDOB'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'BCP_S11CIW'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'BCP_T11CDA'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'BCP_T11CDC'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'BCP_T11CDE'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'BCP_T11CDG'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'BCP_T11CDS'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'BCP_T11CDW'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'BCP_T11CIC'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'BCP_T11CIE'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'BCP_T11CIG'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'BCP_S11CDA'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'BCP_S11CDC'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'BCP_S11CDE'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'BCP_S11CDG'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'BCP_S11CDS'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'BCP_S11CDW'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'BCP_S11CIC'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'BCP_S11CIE'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'BCP_S11CIG'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'BCP_S11CIS'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'BCP_T12CDS'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'BCP_T12CDW'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'BCP_T11CIS'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'BCP_T11CIW'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'BCP_T12CDA'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'BCP_T12CDC'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'BCP_T12CDE'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'BCP_T12CDG'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'BCP_V11CDS'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'BCP_T12CIC'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'BCP_T12CIE'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'BCP_T12CIG'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'BCP_T12CIS'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'BCP_T12CIW'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'BCP_V11CDA'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'BCP_V11CDC'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'BCP_V11CDE'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'BCP_V11CDG'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'BCP_V11CDW'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'BCP_V11CIC'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'BCP_V11CIE'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'BCP_V11CIG'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'BCP_V11CIS'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'BCP_V11CIW'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T5D0C'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TSEXC'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TAME0'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TCOLL'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TDDAT'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'BCP_S12CDS'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'BCP_V12CIC'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'BCP_S12CDW'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'BCP_S12CIC'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'BCP_S12CIE'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'BCP_S12CIG'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'BCP_S12CIS'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'BCP_S12CIW'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'BCP_V12CDA'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'BCP_V12CDC'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'BCP_V12CDE'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'BCP_V12CDG'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'BCP_V12CDS'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'BCP_V12CDW'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'BCP_V12CIE'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'BCP_V12CIG'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'BCP_V12CIS'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'BCP_V12CIW'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'BCP_S12CDA'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'BCP_S12CDC'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'BCP_S12CDE'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'BCP_S12CDG'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TNRT8A'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'TNRT8AT'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'BCP_T11CIA'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'BCP_T12CIA'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'BCP_S12CIA'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'BCP_V12CIA'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'BCP_V11CIA'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'BCP_S11CIA'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T5A4O'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T517A'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T517Z'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T5B0C'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T5B0D'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T5B0E'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T5B0G'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T5C1R'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T5C1Y'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T5B1B'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T5B1D'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T538Z'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T5B62'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T5B7B'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T5F2M'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T5B7C'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T5B7A'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T535T'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T536T'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T538B'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T538C'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T569W'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T5D2N'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T588A'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T5D4B'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T5D4G'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T5D4J'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T5D1C'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T5D5T'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T5D1E'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T5D5F'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T5D6E'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T5D1N'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T5D1F'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T5D6D'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T5D1Q'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T5D2E'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T5D2G'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T5D1T'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T5D2C'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T5D2H'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T588B'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T5A2D'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T5M03'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T5G1T'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T5G22'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T5M1P'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T5G24'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T5M3U'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T5K13'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T5S3C'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T5S3D'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T5S3E'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T5S3M'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T5S4B'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T8JAC'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'AT01T'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T510E'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T5B0A'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T5B0B'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T5B0F'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T510L'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T5B0I'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T5B1A'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T5B1C'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T511M'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T5B63'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T512C'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T518E'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T541A'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T520M'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T520S'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T549Q'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T5C0P'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T521C'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T549S'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T522N'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T5C16'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T588I'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T5A1B'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T5A1C'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T5A1X'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T5D13'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T5A2M'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T5A4A'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T5D1G'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T5A5U'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T5D1L'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T5D1R'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T5D1V'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T5D1X'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T5D2F'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T5D2S'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T5D3C'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T5G2F'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T5D4H'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T5D5L'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'T703Z'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'VER29017PD'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'VER29017PF'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'VER29017PP'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'VER29017PS'.
  INSERT l_wa INTO TABLE gt_tabclass. l_wa-tabname = 'AT02'.
  INSERT l_wa INTO TABLE gt_tabclass.

  IF gt_tabclass IS NOT INITIAL.
    LOOP AT gt_tabclass INTO l_wa.
      s_table-option = 'EQ'.
      s_table-sign = 'I'.
      s_table-low = l_wa-tabname.
      APPEND s_table.
    ENDLOOP.
  ENDIF.
********************EOP Shreeda ***********
ENDFORM.
