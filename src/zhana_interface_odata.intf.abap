interface ZHANA_INTERFACE_ODATA
  public .


  interfaces IF_BADI_INTERFACE .

  types:
    BEGIN OF ty_class,
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
    END OF ty_class .
  types:
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
    END OF ty_final .
  types:
    tt_class_tab TYPE STANDARD TABLE OF ty_class .
  types:
    tt_final_tab TYPE STANDARD TABLE OF ty_final .

  methods CHECK_EDM_TYPE
    importing
      !P_KIND type CHAR1
      !P_DFIES type DFIES optional
    exporting
      !E_EDM_TYP type CHAR20 .
  methods IS_VALID_ODATA_CLASS
    importing
      !I_DEST_NAME type RFCDES-RFCDEST
    exporting
      !LT_CLASS type TT_CLASS_TAB .
  methods GET_ODATA_OPCODES
    importing
      !LV_OK type WDY_BOOLEAN
      !LV_SERV type CHAR35
      !LV_CLASS type PROGNAME
      !LV_ODATA type CHAR1
      !LV_MPC type WDY_BOOLEAN
      !LV_MPC_EXT type WDY_BOOLEAN
      !I_DEST_NAME type RFCDES-RFCDEST
      !LT_CLASS type TT_CLASS_TAB
    exporting
      !LT_FINAL1 type TT_FINAL_TAB .
endinterface.
