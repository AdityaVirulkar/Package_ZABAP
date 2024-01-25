interface ZIF_BCI001L_ALV_INCLUDE_OBJECT
  public .


  class-methods SET_ACTUAL_ALV
    importing
      !IP_NUMBER type I .
  class-methods INITIALIZE_ALV .
  class-methods SET_CELL_COLOR
    importing
      !IP_CELLS type C
      !IP_COLOR type C
      !IP_TARGET type C
      !IP_BOLD type XFELD
      !IP_COLOR_FIELD type C
    changing
      !TP_INTTAB type LVC_T_SCOL .
  class-methods SET_LINE_COLOR
    importing
      !IP_COLOR type C
      !IP_TARGET type C
      !IP_BOLD type XFELD
      !IP_COLOR_FIELD type C
    changing
      !TP_INTTAB type C .
  class-methods SET_COLUMN_COLOR
    importing
      !IP_COLOR type C
      !IP_TARGET type C
      !IP_BOLD type XFELD
      !IP_COLUMN type LVC_FNAME .
  class-methods ADD_ALV_HEADER
    importing
      !IP_TYPE type SLIS_LISTHEADER-TYP
      !IP_KEY type ANY
      !IP_INFO type ANY .
  class-methods SET_ALV_LEN
    importing
      !IP_COLSIZE type STRING .
  class-methods SET_ALV_SORT
    importing
      !IP_POS type LVC_S_SORT-SPOS
      !IP_FIELD type LVC_S_SORT-FIELDNAME
      !IP_UP type LVC_S_SORT-UP
      !IP_SUBTOT type LVC_S_SORT-SUBTOT .
  class-methods SET_SAVE_MODE
    importing
      !IP_SAVEMODE type CHAR1 .
  class-methods GET_CURR_FCAT
    changing
      !TP_FCAT type LVC_T_FCAT .
  class-methods SET_USER_CONTAINER
    importing
      !IP_NUMBER type I
      !IP_CONTAINER type STRING .
  class-methods SET_ALV_LAYOUT
    importing
      !IP_ZEBRA type LVC_S_LAYO-ZEBRA
      !IP_KEYHOT type LVC_S_LAYO-KEYHOT
      !IP_NO_MERGING type LVC_S_LAYO-NO_MERGING
      !IP_CWIDTH_OPT type LVC_S_LAYO-CWIDTH_OPT
      !IP_NO_TOOLBAR type LVC_S_LAYO-NO_TOOLBAR
      !IP_NO_HEADERS type LVC_S_LAYO-NO_HEADERS
      !IP_NO_HGRIDLN type LVC_S_LAYO-NO_HGRIDLN
      !IP_NO_VGRIDLN type LVC_S_LAYO-NO_VGRIDLN
      !IP_TITLE type LVC_S_LAYO-GRID_TITLE .
  class-methods SET_STABLE_ROW_COLUMN
    importing
      !IP_ROW type LVC_S_STBL-ROW
      !IP_COL type LVC_S_STBL-COL .
  class-methods ADD_FIELDCAT
    importing
      !IP_FIELD type LVC_S_FCAT-FIELDNAME
      !IP_TYPE type LVC_S_FCAT-REF_FIELD
      !IP_SIZE type LVC_S_FCAT-INTLEN
      !IP_ALIGN type LVC_S_FCAT-JUST
      !IP_SHOW type C
      !IP_TITLE type LVC_S_FCAT-COLTEXT .
  class-methods GET_CURR_CELL
    changing
      !CP_ROW type SY-TABIX
      !CP_COL type STRING .
  class-methods UPDATE_ALV_PBO_MODULE
    importing
      !IP_NUMBER type I
      !IP_REPID type SY-REPID
      !IP_DYNNR type SY-DYNNR
      !IP_VARIANT type DISVARIANT-VARIANT
    changing
      !TP_TABLE type ANY
      !IP_HDSIZE type I .
  class-methods SET_READ_INPUT .
  class-methods SET_CURR_FCAT
    changing
      !TP_FCAT type LVC_T_FCAT .
  class-methods CHANGE_FIELDCAT
    importing
      !IP_ACTION type C
      !IP_REFER type LVC_S_FCAT-FIELDNAME
      !IP_FIELD type LVC_S_FCAT-FIELDNAME
      !IP_TYPE type LVC_S_FCAT-REF_FIELD
      !IP_SIZE type ANY
      !IP_ALIGN type LVC_S_FCAT-JUST
      !IP_SHOW type C
      !IP_TITLE type LVC_S_FCAT-COLTEXT
    changing
      !TP_FCAT type LVC_T_FCAT .
  class-methods UPDATE_ITABLE_EDITMODE .
  class-methods CHANGE_FIELDCAT_PARAMETER
    importing
      !IP_REFER type ANY
      !IP_PARAM type ANY
      !IP_VALUE type ANY .
  class-methods SET_COLOR_CODE
    importing
      !IP_COLOR type C
      !IP_TARGET type C
      !IP_BOLD type XFELD .
endinterface.
