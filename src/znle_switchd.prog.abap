*****           Implementation of object type ZISUSWTDOC           *****
*++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*
* CHANGE ID : HANA-001
*1.) ACC11346068
*       BHARDWAA                             CR0093193* 24.05.2017
* TR : S7HK900166
* DESCRIPTION: HANA CORRECTION
* TEAM : HANA-MIGRATION
*++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*
INCLUDE <object>.
begin_data object. " Do not change.. DATA is generated
* only private members may be inserted into structure private
DATA:
  " begin of private,
  "   to declare private attributes remove comments and
  "   insert private attributes here ...
  " end of private,
  BEGIN OF key,
    switchnum LIKE eideswtdoc-switchnum,
  END OF key,
  switch_log_message TYPE t52spce-eventpara.
end_data object. " Do not change.. DATA is generated

begin_method zmtrreaddocupload changing container.
DATA: ext_ui  LIKE eideswtmsgdata-ext_ui,
      service LIKE eservprov-service,
      reason  TYPE  ablesgr,
      keydate LIKE syst-datum,
      msgdata LIKE eideswtmsgdata.

z_utility=>breakpoint_wf( 'ZMTRREADDOC_UPLOAD' ).

swc_get_element container 'EXT_UI' ext_ui.
swc_get_element container 'SERVICE' service.
swc_get_element container 'REASON' reason.
swc_get_element container 'MSGDATA' msgdata.
swc_get_element container 'KEYDATE' keydate.

CALL FUNCTION 'ZMTRREADDOC_UPLOAD'
  EXPORTING
    x_ext_ui          = ext_ui
    x_date            = keydate
    x_service         = service
    x_reason          = reason
    x_msgdata         = msgdata
    x_switchnum       = object-key-switchnum
  EXCEPTIONS
    no_meter_found    = 01
    inconsistent_data = 02
    mr_upload_error   = 03
    device_mismatch   = 04
    OTHERS            = 05.
CASE sy-subrc.
  WHEN 0.            " OK
  WHEN 01.    " to be implemented
    exit_return 1001 space space space space.
  WHEN 02.    " to be implemented
    exit_return 1002 space space space space.
  WHEN 03.    " to be implemented
    exit_return 1003 space space space space.
  WHEN 04.
    exit_return 1004 msgdata-zzmeterno space space space.
  WHEN OTHERS.       " to be implemented
ENDCASE.
end_method.

begin_method bapitransactioncommit changing container.
DATA:
  wait   TYPE bapita-wait,
  return LIKE bapiret2.
*  SWC_GET_ELEMENT CONTAINER 'Wait' WAIT.
CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
  EXPORTING
    wait   = 'X'
  IMPORTING
    return = return
  EXCEPTIONS
    OTHERS = 01.
CASE sy-subrc.
  WHEN 0.            " OK
  WHEN OTHERS.       " to be implemented
ENDCASE.
*  SWC_SET_ELEMENT CONTAINER 'Return' RETURN.
end_method.

begin_method zisuproc150 changing container.
DATA: ext_ui       TYPE ext_ui,
      service      TYPE sercode,
      msgdata      TYPE eideswtmsgdata,
      tariftype    TYPE tariftyp,
      x_tid1       TYPE zeau_timeframe_id,
      x_eau_usage1 TYPE zestimated_annual_usage,
      x_tid2       TYPE zeau_timeframe_id,
      x_eau_usage2 TYPE zestimated_annual_usage.

swc_get_element container 'EXT_UI' ext_ui.
swc_get_element container 'SERVICE' service.
swc_get_element container 'MSG_ZECH150' msgdata.
swc_get_element container 'ZZEAU_TIMEFRM_ID' x_tid1.
swc_get_element container 'ZZESTMT_ANL_USE' x_eau_usage1.
swc_get_element container 'ZZEAU_TIMFRM_ID2' x_tid2.
swc_get_element container 'ZZESTMT_ANL_USE2' x_eau_usage2.
swc_get_element container 'ZZTARIFFTYPE' tariftype.

IF tariftype IS INITIAL.
  SELECT zztarifftype FROM eideswtdoc AS e INTO tariftype
  WHERE e~switchnum EQ object-key-switchnum.
  ENDSELECT.

  IF sy-subrc <> 0.
* to be implemented -> use tariftype of distributor
  ENDIF.
ENDIF.
IF msgdata IS INITIAL.
* AUCT-UPGRADE -  Begin of Modification by <USER> on <17.02.2017> for <EHP8>
*  SELECT SINGLE * FROM eideswtmsgdata INTO msgdata
*     WHERE switchnum EQ object-key-switchnum
*       AND category  EQ 'Z05'.
  SELECT * UP TO 1 ROWS FROM eideswtmsgdata INTO msgdata
  WHERE switchnum EQ object-key-switchnum
  AND category EQ 'Z05'
  ORDER BY PRIMARY KEY.
  ENDSELECT.
* AUCT-UPGRADE -  End of Modification by <USER> on <17.02.2017> for <EHP8>
ENDIF.

CALL FUNCTION 'ZISU_PROC_150'
  EXPORTING
    x_ext_ui     = ext_ui
    x_service    = service
    x_msgdata    = msgdata
    x_tariftyp   = tariftype
    x_tid1       = x_tid1
    x_eau_usage1 = x_eau_usage1
    x_tid2       = x_tid2
    x_eau_usage2 = x_eau_usage2
  EXCEPTIONS
    input_error  = 01.
CASE sy-subrc.
  WHEN 0.            " OK
  WHEN 01.    " to be implemented
    exit_return 1001 'INPUT_ERROR' space space space.
  WHEN OTHERS.       " to be implemented
    exit_return 1001 'OTHERS' space space space.
ENDCASE.
end_method.

begin_method zisudatevalid changing container.
DATA:
  keydate       TYPE eideswtdoc-moveindate,
  checktype(20) VALUE 'FIRST',
  valid(1).
swc_get_element container 'KeyDate' keydate.
swc_get_element container 'CheckType' checktype.

IF checktype = 'FIRST'.
*   Determine if the date if the first of the month
  IF keydate+6(2) = '01'.
    valid = 'X'.
  ENDIF.
ENDIF.

swc_set_element container 'Valid' valid.
end_method.

begin_method zisusetstrucvalue changing container.
DATA:
  valuein(255),
  valueout(255).
swc_get_element container 'ValueIn' valuein.
valueout = valuein.
swc_set_element container 'ValueOut' valueout.
end_method.

begin_method zisumsggetmrdata200 changing container.

DATA:

  x_connect_ean LIKE euitrans-ext_ui,
  x_indication  LIKE eideswtmsgdata-zzindicat_mtr_r,
  x_sparte      LIKE eideswtdoc-zzsparte,
  x_startdate   LIKE syst-datum,
  x_enddate     LIKE syst-datum,
*X_SWITCHNUM   like EIDESWTDOC-SWITCHNUM,
  xy_medtd3     TYPE TABLE OF zech200medtd3.


swc_get_element container 'X_CONNECT_EAN' x_connect_ean.
swc_get_element container 'X_INDICATION'  x_indication.
swc_get_element container 'X_SPARTE'      x_sparte.
swc_get_element container 'X_STARTDATE'   x_startdate.
swc_get_element container 'X_ENDDATE'     x_enddate.
*SWC_GET_ELEMENT CONTAINER 'X_SWITCHNUM'   X_SWITCHNUM.

CALL FUNCTION 'ZISU_MSG_GET_MR_DATA_200'
  EXPORTING
    x_connect_ean        = x_connect_ean
    x_indication         = x_indication
    x_sparte             = x_sparte
    x_startdate          = x_startdate
    x_enddate            = x_enddate
    x_switchnum          = object-key-switchnum
  TABLES
    xy_medtd3            = xy_medtd3
  EXCEPTIONS
    anlage_not_found     = 01
    date_param_missing   = 02
    estimate_failure     = 03
    no_last_mtrread      = 04
    no_mtrread_in_period = 05
    OTHERS               = 06.
CASE sy-subrc.
  WHEN 0.            " OK
  WHEN 01.    " to be implemented
    exit_return 1001 'INPUT_ERROR' space space space.
  WHEN 02.    " to be implemented
    exit_return 1002 'INPUT_ERROR' space space space.
  WHEN 03.    " to be implemented
    exit_return 1003 'INPUT_ERROR' space space space.
  WHEN 04.    " to be implemented
    exit_return 1004 'Geen stand gevonden' space space space.
  WHEN 05.    " to be implemented
    exit_return 1005 'Geen standen in periode' space space space.
  WHEN OTHERS.       " to be implemented
ENDCASE.
swc_set_table container  'XY_MEDTD3' xy_medtd3.
end_method.

begin_method endtimedetermine changing container.
DATA:
  duration(255),
  unit            TYPE t006-msehi,
  factorycalendar TYPE scal-fcalid,
  start_date      TYPE sy-datum,
  end_date        TYPE sy-datum.

swc_get_element container 'Duration' duration.
IF sy-subrc <> 0.
  MOVE 0 TO duration.
ENDIF.
swc_get_element container 'Unit' unit.
swc_get_element container 'START_DATE' start_date.
swc_get_element container 'FactoryCalendar' factorycalendar.

CALL FUNCTION 'END_TIME_DETERMINE'
  EXPORTING
    duration                   = duration
    unit                       = unit
    factory_calendar           = factorycalendar
  IMPORTING
    end_date                   = end_date
*   END_TIME                   =
  CHANGING
    start_date                 = start_date
    start_time                 = sy-uzeit
  EXCEPTIONS
    factory_calendar_not_found = 01
    date_out_of_calendar_range = 02
    date_not_valid             = 03
    unit_conversion_error      = 04
    si_unit_missing            = 05
    parameters_no_valid        = 06
    OTHERS                     = 07.
CASE sy-subrc.
  WHEN 0.            " OK
  WHEN 01.    " to be implemented
    exit_return 1001 'Calender not found ' ' ' ' ' ' '.
  WHEN 02.    " to be implemented
    exit_return 1002 'Date out of range' ' ' ' ' ' '.
  WHEN 03.    " to be implemented
    exit_return 1003 'Date not valid' ' ' ' ' ' '.
  WHEN 04.    " to be implemented
    exit_return 1004 'Conversion error' ' ' ' ' ' '.
  WHEN 05.    " to be implemented
    exit_return 1005 'Unit missing' ' ' ' ' ' '.
  WHEN 06.    " to be implemented
    exit_return 1006 'Not valid' ' ' ' ' ' '.
  WHEN OTHERS.       " to be implemented
    exit_return 1007 'Others' ' ' ' ' ' '.
ENDCASE.
swc_set_element container 'END_DATE' end_date.
end_method.

begin_method zcreatecrname changing container.
DATA:
  ca_name          TYPE fkkvk-vkbez,
  switchmoveindate TYPE eideswtdoc-moveindate,
  zzconct_houseno  TYPE eideswtmsgdata-zzcnct_houseno,
  postcode1        TYPE adrc-post_code1.
swc_get_element container 'SwitchMoveInDate' switchmoveindate.
swc_get_element container 'ZZCONCT_HOUSENO' zzconct_houseno.
swc_get_element container 'Postcode1' postcode1.

CONCATENATE postcode1 ', ' zzconct_houseno ', ' switchmoveindate INTO
ca_name.



swc_set_element container 'CA_NAME' ca_name.
end_method.

begin_method zbepaaltarieftype changing container.

DATA: x_klanttype    TYPE zklanttype_key,
      x_producttype  TYPE zproducttype_key,
      x_sparte       TYPE sparte,
      x_profile      TYPE zprofile_id,
      x_product_char TYPE zproduct_characteristic,
      x_tariff_code  TYPE ztariff_code,
      y_aklasse      TYPE aklasse,
      y_tariftyp     TYPE tariftyp.

swc_get_element container 'KLANTTYPE' x_klanttype.
swc_get_element container 'PRODUCTTYPE' x_producttype.
swc_get_element container 'SPARTE' x_sparte.
swc_get_element container 'PROFILE' x_profile.
swc_get_element container 'PRODUCT_CHAR' x_product_char.
swc_get_element container 'TARIFF_CODE' x_tariff_code.

CALL FUNCTION 'ZBEPAAL_TARIEFTYPE'
  EXPORTING
    x_klanttype    = x_klanttype
    x_producttype  = x_producttype
    x_sparte       = x_sparte
    x_profile      = x_profile
    x_product_char = x_product_char
    x_tariff_code  = x_tariff_code
    x_date         = sy-datum
  IMPORTING
    y_aklasse      = y_aklasse
    y_tariftyp     = y_tariftyp
  EXCEPTIONS
    not_found      = 01
    OTHERS         = 02.
CASE sy-subrc.
  WHEN 0.            " OK
  WHEN 01.    " to be implemented
    exit_return 1001 space space space space.
  WHEN OTHERS.       " to be implemented
ENDCASE.

swc_set_element container 'AKLASSE' y_aklasse.
swc_set_element container 'TARIFTYP' y_tariftyp.
end_method.

begin_method zgetrelatedprocess changing container.
DATA:
  x_partner     TYPE eideswtdoc-partner,
  x_switchview  TYPE eideswtdoc-swtview,
  x_pod         TYPE eideswtdoc-pod,
  x_switchtype  TYPE eideswtdoc-switchtype,
  x_account     TYPE eideswtdoc-zzvkont,
  y_teideswtdoc TYPE TABLE OF eideswtdoc.

swc_get_element container 'X_PARTNER' x_partner.
swc_get_element container 'X_SWITCHVIEW' x_switchview.
swc_get_element container 'X_POD' x_pod.
swc_get_element container 'X_SWITCHTYPE' x_switchtype.
swc_get_element container 'X_ACCOUNT' x_account.
swc_get_table container 'Y_TEIDESWTDOC' y_teideswtdoc.

CALL FUNCTION 'Z_IDE_DB_EIDESWTDOC_RELATED'
  EXPORTING
    x_partner        = x_partner
    x_switchview     = x_switchview
    x_switchtype     = x_switchtype
    x_account        = x_account
    x_pod            = x_pod
  TABLES
    y_teideswtdoc    = y_teideswtdoc
  EXCEPTIONS
    no_result        = 1001
    too_many_results = 1002
    OTHERS           = 01.
CASE sy-subrc.
  WHEN 0.            " OK
  WHEN 1001.         " NO_RESULT
    exit_return 1001 sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  WHEN 1002.         " TOO_MANY_RESULTS
    exit_return 1002 sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  WHEN OTHERS.       " to be implemented
ENDCASE.

swc_set_table container 'Y_TEIDESWTDOC' y_teideswtdoc.
end_method.

begin_method zisuideswitchdocchange changing container.
DATA:
  ihead LIKE eideswtdoc,
  ehead LIKE eideswtdoc.
swc_get_element container 'IHead' ihead.
CALL FUNCTION 'ZISU_IDE_SWITCHDOC_CHANGE'
  EXPORTING
    i_head = ihead
  IMPORTING
    e_head = ehead
  EXCEPTIONS
    OTHERS = 01.
CASE sy-subrc.
  WHEN 0.            " OK
  WHEN OTHERS.       " to be implemented
    exit_return 1001 'FOUT' space space space.
ENDCASE.
swc_set_element container 'EHead' ehead.
end_method.

begin_method zisuupdatemru changing container.
DATA:
  msgdata  TYPE eideswtmsgdata,
  service  TYPE sercode,
  mru      TYPE ableinh,
  tariftyp TYPE tariftyp.

swc_get_element container 'XMsgdata' msgdata.
swc_get_element container 'XSercode' service.
swc_get_element container 'XMRU' mru.
swc_get_element container 'XRateCategory' tariftyp.

CALL FUNCTION 'Z_ISU_UPDATE_MRU'
  EXPORTING
    x_msgdata         = msgdata
    x_service         = service
    x_mru             = mru
    x_rate_category   = tariftyp
  EXCEPTIONS
    input_error       = 1
    portion_error     = 2
    portions_ca_error = 3
    OTHERS            = 4.

CASE sy-subrc.
  WHEN 0.            " OK
  WHEN 2.
    exit_return 1002 space space space space.
  WHEN 3.
    exit_return 1003 space space space space.
  WHEN OTHERS.       " to be implemented
    exit_return 1001 space space space space.
ENDCASE.
end_method.

begin_method zisub2bbbpcheck changing container.

DATA:
  x_date   TYPE datum,
  x_vkont  TYPE vkont_kk,
  x_action TYPE e_mode,
  y_result TYPE kennzx.

swc_get_element container 'X_DATE' x_date.
swc_get_element container 'X_VKONT' x_vkont.
swc_get_element container 'X_ACTION' x_action.

CALL FUNCTION 'ZISU_B2B_BBP_CHECK'
  EXPORTING
    x_date   = x_date
    x_vkont  = x_vkont
    x_action = x_action
  IMPORTING
    y_result = y_result
  EXCEPTIONS
    OTHERS   = 01.
CASE sy-subrc.
  WHEN 0.            " OK
  WHEN OTHERS.       " to be implemented
    exit_return 1001 space space space space.
ENDCASE.

swc_set_element container 'Y_RESULT' y_result.

end_method.

begin_method zisuproc150b2b changing container.
DATA: ext_ui       TYPE ext_ui,
      service      TYPE sercode,
      msgdata      TYPE eideswtmsgdata,
      tariftype    TYPE tariftyp,
      x_tid1       TYPE zeau_timeframe_id,
      x_eau_usage1 TYPE zestimated_annual_usage,
      x_tid2       TYPE zeau_timeframe_id,
      x_eau_usage2 TYPE zestimated_annual_usage,
      x_ableinh    TYPE ableinh,
      x_met_method TYPE zisu_metering_method.

swc_get_element container 'EXT_UI' ext_ui.
swc_get_element container 'SERVICE' service.
swc_get_element container 'MSG_ZECH150' msgdata.
swc_get_element container 'ZZEAU_TIMEFRM_ID' x_tid1.
swc_get_element container 'ZZESTMT_ANL_USE' x_eau_usage1.
swc_get_element container 'ZZEAU_TIMFRM_ID2' x_tid2.
swc_get_element container 'ZZESTMT_ANL_USE2' x_eau_usage2.
swc_get_element container 'ZZTARIFFTYPE' tariftype.
swc_get_element container 'MRU' x_ableinh.
swc_get_element container 'ZZMET_METHOD' x_met_method.

IF tariftype IS INITIAL.
  SELECT zztarifftype FROM eideswtdoc AS e INTO tariftype
  WHERE e~switchnum EQ object-key-switchnum.
  ENDSELECT.

  IF sy-subrc <> 0.
* to be implemented -> use tariftype of distributor
  ENDIF.
ENDIF.

CALL FUNCTION 'ZISU_PROC_150_B2B'
  EXPORTING
    x_ext_ui     = ext_ui
    x_service    = service
    x_msgdata    = msgdata
    x_tariftyp   = tariftype
    x_tid1       = x_tid1
    x_eau_usage1 = x_eau_usage1
    x_tid2       = x_tid2
    x_eau_usage2 = x_eau_usage2
    x_ableinh    = x_ableinh
    x_met_method = x_met_method
  EXCEPTIONS
    input_error  = 01.
CASE sy-subrc.
  WHEN 0.            " OK
  WHEN 01.    " to be implemented
    exit_return 1001 'INPUT_ERROR' space space space.
  WHEN OTHERS.       " to be implemented
    exit_return 1001 'OTHERS' space space space.
ENDCASE.
end_method.

begin_method zisuchangeswitchtomove changing container.
DATA:
  iswtdoc  LIKE eideswtdoc,
  imsgdata LIKE eideswtmsgdata,
  eswtdoc  LIKE eideswtdoc,
  emsgdata LIKE eideswtmsgdata.
swc_get_element container 'ISwtdoc' iswtdoc.
swc_get_element container 'IMsgdata' imsgdata.
CALL FUNCTION 'Z_ISU_CHANGE_SWITCH_TO_MOVE'
  EXPORTING
    i_swtdoc  = iswtdoc
    i_msgdata = imsgdata
  IMPORTING
    e_swtdoc  = eswtdoc
    e_msgdata = emsgdata
  EXCEPTIONS
    OTHERS    = 01.
CASE sy-subrc.
  WHEN 0.            " OK
  WHEN OTHERS.       " to be implemented
ENDCASE.
swc_set_element container 'ESwtdoc' eswtdoc.
swc_set_element container 'EMsgdata' emsgdata.
end_method.

begin_method changemsgdatadialog changing container.
DATA:
  msgdatanum TYPE eideswtmsgdata-msgdatanum,
  msgdata    LIKE eideswtmsgdata.
DATA:
  lw_swdocnum TYPE eideswtnum.

swc_get_element container 'MsgDataNum' msgdatanum.
swc_get_element container 'MsgData' msgdata.
swc_get_object_key self lw_swdocnum.
CALL FUNCTION 'Z_ISU_IDE_SWTDC_MSGDATA_CHANGE'
  EXPORTING
    x_eideswtdoc     = lw_swdocnum
    x_msgdatanum     = msgdatanum
  IMPORTING
    y_msgdatanum     = msgdatanum
  CHANGING
    xy_msgdata       = msgdata
  EXCEPTIONS
    ex_not_possible  = 1001
    ex_not_found     = 1002
    ex_general_fault = 1003
    ex_foreign_lock  = 1004
    ex_userabort     = 1005
    OTHERS           = 1006.
CASE sy-subrc.
  WHEN 1001.
    exit_return 1001 space space space space.
  WHEN 1002.
    exit_return 1002 space space space space.
  WHEN 1003.
    exit_return 1003 space space space space.
  WHEN 1004.
    exit_return 1004 space space space space.
  WHEN 1005.
    exit_cancelled.
  WHEN 1006.
    exit_return 1006 space space space space.
  WHEN OTHERS.
* OK
ENDCASE.
swc_set_element container 'MsgDataNum' msgdatanum.
swc_set_element container 'MsgData' msgdata.
end_method.

begin_method updatedefaultshipper changing container.
DATA:
  msgnum  TYPE eideswtmdnum,
  msgdata LIKE eideswtmsgdata.
DATA:
  lw_swdocnum TYPE eideswtnum,
  lw_msgnum   TYPE eideswtmdnum.

swc_get_object_key self lw_swdocnum.
swc_get_element container 'MsgNum' msgnum.
CLEAR msgdata.
CALL FUNCTION 'Z_EIDE_SWTDC_SHIPPER_UPDATE'
  EXPORTING
    x_swtdoc      = lw_swdocnum
    x_msgnum      = msgnum
  IMPORTING
    y_msgnum      = lw_msgnum
    y_msgdata     = msgdata
  EXCEPTIONS
    ex_internal   = 1001
    ex_swtmsgdata = 1002
    OTHERS        = 1003.
CASE sy-subrc.
  WHEN 1001.
    exit_return 1001 space space space space.
  WHEN 1002.
    exit_return 1002 'zisuswitchd-updatedefaultshipper'
                     space space space.
  WHEN 1003.
    exit_return 1003 'zisuswitchd-updatedefaultshipper'
                     space space space.
  WHEN OTHERS.
    msgnum = lw_msgnum.
ENDCASE.
swc_set_element container 'MsgNum' msgnum.
swc_set_element container 'MsgData' msgdata.
end_method.

begin_method ispartnerlocked changing container.
DATA:
  partnerlocked TYPE ewxgen-kennzx,
  lt_messages   TYPE TABLE OF balm,
  ls_message    TYPE balm,
  lw_extnr      LIKE  balhdr-extnumber,
  lf_date_from  TYPE balhdr-aldate,
  lf_time_from  TYPE balhdr-altime,
  lf_minutes    TYPE minutes,
  lf_seconds    TYPE int4.
CLEAR partnerlocked.
lw_extnr = object-key-switchnum.
swc_get_element container 'ReadLastMinutes' lf_minutes.

* Calculate start date and time to read only last n minutes of log
IF lf_minutes IS NOT INITIAL.
  lf_seconds = lf_minutes * 60.
  lf_date_from = sy-datum.
  lf_time_from = sy-uzeit - lf_seconds.
* When necessary, change date_from to yesterday
  IF lf_time_from > sy-uzeit.
    lf_date_from = lf_date_from - 1.
  ENDIF.
ELSE.
* Keep existing logic, read whole app log for switch
  lf_date_from = '19000101'.
  lf_time_from = '000000'.
ENDIF.

CALL FUNCTION 'APPL_LOG_READ_DB'
  EXPORTING
    object          = 'IUDRGSCENGEN'
    subobject       = '*'
    external_number = lw_extnr
    date_from       = lf_date_from
    time_from       = lf_time_from
    date_to         = sy-datum
    time_to         = sy-uzeit
  TABLES
    messages        = lt_messages.
* Check if the message contain BP is currently locked
* MSGID = '>3' and MSGNO = '554' or  " BP lock
* MSGID = '>3' and MSGNO = '031' or  " CA lock
* MSGID = 'R1' and MSGNO = '084' or  " BP lock
* MSGID = 'E9' and MSGNO = '029' or  " message is general about lock
* MSGID = 'R1' and MSGNO = '086'     " BP lock
LOOP AT lt_messages
  INTO ls_message
  WHERE ( msgid EQ '>3'  AND
          msgno EQ '554' ) OR
        ( msgid EQ '>3'  AND
          msgno EQ '031' ) OR
       (  msgid EQ 'R1'  AND
          msgno EQ '084' ) OR
       (  msgid EQ 'E9'  AND
          msgno EQ '029') OR
       (  msgid EQ 'R1' AND   " 27.08.2013, TOMAJ
          msgno EQ '086' ).   " 27.08.2013, TOMAJ
  partnerlocked = 'X'.
  EXIT.
ENDLOOP.
swc_set_element container 'PartnerLocked' partnerlocked.
end_method.

begin_method partnerblockedlogadd changing container.
DATA:
  lw_partner TYPE but000-partner,
  lw_swtdc   TYPE eideswtnum.
swc_get_property self 'BusinessPartner' lw_partner.
swc_get_object_key self lw_swtdc.
CALL FUNCTION 'ZISU_DB_SWTDC_BPBLK_LOG_UPDATE'
  EXPORTING
    i_partner   = lw_partner
    i_swtdc     = lw_swtdc
  EXCEPTIONS
    ex_internal = 1
    OTHERS      = 2.
end_method.

begin_method partnerblockedlogdel changing container.
DATA:
  lw_partner TYPE but000-partner,
  lw_swtdc   TYPE eideswtnum,
  lv_message TYPE c LENGTH 220.
swc_get_property self 'BusinessPartner' lw_partner.
swc_get_object_key self lw_swtdc.
CALL FUNCTION 'ZISU_DB_SWTDC_BPBLK_LOG_DELETE'
  EXPORTING
    i_partner   = lw_partner
    i_swtdc     = lw_swtdc
  EXCEPTIONS
    ex_internal = 1
    OTHERS      = 2.
IF sy-subrc NE 0.
  MESSAGE ID     sy-msgid
          TYPE   'E'
          NUMBER sy-msgno
          WITH   sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4
          INTO   lv_message.
  CONDENSE lv_message.
  exit_return '1001' lv_message '' '' ''.
ENDIF.
end_method.

begin_method checkerrorswitch changing container.
DATA:
  lw_switchnum TYPE  eideswtnum,
  lw_datefr    TYPE  dats,
  lw_timefr    TYPE  tims,
  lw_lag_date  TYPE  char03,
  lw_lag_time  TYPE  char04.
lw_switchnum = object-key-switchnum.
lw_lag_date = '000'.
lw_lag_time = '3600'.
lw_datefr = sy-datum.
lw_timefr = sy-uzeit.
CALL FUNCTION 'ZISU_CHECK_SWITCH_LOG'
  EXPORTING
    x_switchnum = lw_switchnum
    x_date      = lw_datefr
    x_time      = lw_timefr
    x_lag_date  = lw_lag_date
    x_lag_time  = lw_lag_time
  EXCEPTIONS
    error       = 1
    no_date_lag = 2
    no_time_lag = 3
    OTHERS      = 4.
IF sy-subrc NE 0.
  CALL METHOD cl_isu_switchdoc=>s_set_activity_status
    EXPORTING
      x_switchnum = lw_switchnum
      x_activity  = 'Z40'
      x_status    = '02'.
ENDIF.
end_method.

begin_method z_check_mess_mt_automatic changing container.
DATA:
  automatic_processing_scenario LIKE boole,
  xy_msgdata                    TYPE TABLE OF eideswtmsgdata,
  wa_msgdata                    TYPE eideswtmsgdata,
  lv_switchdoc                  TYPE eideswtnum,
  lv_bis                        TYPE sy-datum,
  lt_euiinstln                  TYPE TABLE OF euiinstln,
  wl_euitrans                   TYPE euitrans.
* AUTOMATIC_PROCESSING_SCENARIO is set to Y when automatic processing
* scenario applies.
* AUTOMATIC_PROCESSING_SCENARIO is set to X when the non-automated
* scenario applies.
* When neither apply is it left empty.
lv_switchdoc = object-key.
CLEAR automatic_processing_scenario.
CALL FUNCTION 'Z_ISU_IDE_SWTDC_MSGDATA_GET'
  EXPORTING
    x_eideswtdoc     = lv_switchdoc
*   X_MSGDATANUM     =
    x_direction      = '1'
*   X_CATEGORY       =
  CHANGING
    xy_msgdata       = xy_msgdata
  EXCEPTIONS
    ex_not_possible  = 1
    ex_not_found     = 2
    ex_general_fault = 3
    ex_foreign_lock  = 4
    ex_userabort     = 5
    OTHERS           = 6.

LOOP AT xy_msgdata INTO wa_msgdata WHERE category EQ 'Z04' AND
*( transreason EQ 'E24' OR transreason EQ 'E25' ).
transreason EQ 'MUD'.
  automatic_processing_scenario = 'X'.
ENDLOOP.
IF automatic_processing_scenario IS INITIAL.
  LOOP AT xy_msgdata INTO wa_msgdata WHERE category EQ 'Z05' AND
  transreason EQ '002'.
* START XALGA 26102012 SOW MESSAGING
*Check if process should go through meter change or profile change
* If meters are the same -> profile change
*check if meter exist, if yes, profile change
* Convert ext_ui to int_ui
    CALL FUNCTION 'ISU_DB_EUITRANS_EXT_SINGLE'
      EXPORTING
        x_ext_ui     = wa_msgdata-ext_ui
        x_keydate    = sy-datum
      IMPORTING
        y_euitrans   = wl_euitrans
      EXCEPTIONS
        not_found    = 1
        system_error = 2
        OTHERS       = 3.
    IF sy-subrc = 0.

      SELECT * FROM euiinstln INTO TABLE lt_euiinstln
*             up to 1 rows
            WHERE int_ui    = wl_euitrans-int_ui
            AND   dateto   = '99991231'.
      IF sy-subrc EQ 0.

* HANA Corrections - BEGIN OF MODIFY - <HANA-001>
        IF NOT lt_euiinstln[] IS INITIAL.
* HANA Corrections - END OF MODIFY - <HANA-001>
          SELECT a~bis INTO lv_bis
           FROM eastl  AS a
           INNER JOIN egerr AS b ON a~logiknr = b~logiknr
           FOR ALL ENTRIES IN lt_euiinstln
           WHERE b~egerr_info = wa_msgdata-zzmeterno AND
            a~bis = '99991231' AND
            a~anlage = lt_euiinstln-anlage.

          ENDSELECT.
* HANA Corrections - BEGIN OF MODIFY - <HANA-001>
        ENDIF.
* HANA Corrections - END OF MODIFY - <HANA-001>

        IF sy-subrc = 0.
          automatic_processing_scenario = 'Z'.
        ELSE.
          automatic_processing_scenario = 'X'.
        ENDIF.
      ENDIF.
    ENDIF.
    EXIT.
  ENDLOOP.
ENDIF.
*if AUTOMATIC_PROCESSING_SCENARIO is initial.
LOOP AT xy_msgdata INTO wa_msgdata WHERE category EQ 'Z05' AND
( transreason EQ 'E03' OR transreason EQ 'E70' ).
  automatic_processing_scenario = 'Y'.
ENDLOOP.
*endif.
* test to force into auto meterchange
*AUTOMATIC_PROCESSING_SCENARIO = 'Y'.
swc_set_element container 'Automatic_processing_scenario'
     automatic_processing_scenario.
end_method.

begin_method moveout_exists changing container.
DATA:
  validity_start_date   TYPE syst-datum,
  moveout_exists_result TYPE boole-boole,
  pod                   TYPE eideswtdoc-pod,
  wa_eideswtdoc         TYPE eideswtdoc,
  lo_pod                TYPE swc_object.
swc_get_element container 'Validity_start_date' validity_start_date.
swc_get_property self 'PointOfDelivery' lo_pod.
swc_get_property lo_pod 'PointOfDelivery' pod.
CLEAR moveout_exists_result.
validity_start_date = validity_start_date - 1.
SELECT * FROM eideswtdoc INTO wa_eideswtdoc WHERE
         pod         EQ pod      AND
         moveoutdate EQ validity_start_date.
  moveout_exists_result = 'X'. EXIT.
ENDSELECT.
swc_set_element container 'MoveOut_exists_result'
     moveout_exists_result.
end_method.

begin_method get_210_message changing container.
DATA: message210                    LIKE eideswtmsgdata,
      automatic_processing_scenario LIKE boole,
      xy_msgdata                    TYPE TABLE OF eideswtmsgdata,
      wa_msgdata                    TYPE eideswtmsgdata,
      lv_switchdoc                  TYPE eideswtnum.
lv_switchdoc = object-key. CLEAR automatic_processing_scenario.

CALL FUNCTION 'Z_ISU_IDE_SWTDC_MSGDATA_GET'
  EXPORTING
    x_eideswtdoc     = lv_switchdoc
    x_direction      = '1'
  CHANGING
    xy_msgdata       = xy_msgdata
  EXCEPTIONS
    ex_not_possible  = 1
    ex_not_found     = 2
    ex_general_fault = 3
    ex_foreign_lock  = 4
    ex_userabort     = 5
    OTHERS           = 6.
SORT xy_msgdata BY msgdate msgtime DESCENDING.
LOOP AT xy_msgdata INTO wa_msgdata WHERE category EQ 'Z04'.
  message210 = wa_msgdata. EXIT.
ENDLOOP.
swc_set_element container 'Message210' message210.
end_method.

begin_method get_brb_profile_instal_fact changing container.
DATA:
  result_structure LIKE zisu_rate_cat_det_profile,
  switchdoc        TYPE REF TO cl_isu_ide_switchdoc,
  message150       TYPE eideswtmsgdata,
  headdata         TYPE eideswtdoc.
CLEAR result_structure.
* get 150 message (from container)
swc_get_element container 'message150' message150.
* get keuzetarief from switchdoc
swc_get_element container 'headdata' headdata.
* run logic and set variables
IF headdata-zzchoice_id_h IS INITIAL.    "no keuzetarief
  result_structure-zchoice_id = headdata-zzchoice_id_h.
  result_structure-profile = message150-zzprofile_id.
  result_structure-17_lebrb = 'Y'.    "DON'T CREATE INSTALL.FACT
  result_structure-09_levep_add = ' '.
ELSE.
  CASE message150-zzprofile_id.
    WHEN '1A'.
      IF headdata-zzchoice_id_h EQ 'SINGLE'.
        result_structure-zchoice_id = headdata-zzchoice_id_h.
        result_structure-profile = '1A'.
        result_structure-17_lebrb = ' '.
        result_structure-09_levep_add = ' '.
      ENDIF.
      IF headdata-zzchoice_id_h EQ 'DOUBLE'.
        result_structure-zchoice_id = headdata-zzchoice_id_h.
        result_structure-profile = message150-zzprofile_id.
        result_structure-17_lebrb = ' '.
        result_structure-09_levep_add = ' '.
      ENDIF.
      IF headdata-zzchoice_id_h EQ 'BESTRATE'.
        result_structure-zchoice_id = headdata-zzchoice_id_h.
        result_structure-profile = message150-zzprofile_id.
        result_structure-17_lebrb = 'X'.
        result_structure-09_levep_add = ' '.
      ENDIF.
    WHEN '1B'.
      IF headdata-zzchoice_id_h EQ 'SINGLE'.
        result_structure-zchoice_id = headdata-zzchoice_id_h.
        result_structure-profile = '1A'.
        result_structure-17_lebrb = ' '.
        result_structure-09_levep_add = ' '.
      ENDIF.
      IF headdata-zzchoice_id_h EQ 'DOUBLE'.
        result_structure-zchoice_id = headdata-zzchoice_id_h.
        result_structure-profile = message150-zzprofile_id.
        result_structure-17_lebrb = ' '.
        result_structure-09_levep_add = ' '.
      ENDIF.
      IF headdata-zzchoice_id_h EQ 'BESTRATE'.
        result_structure-zchoice_id = headdata-zzchoice_id_h.
        result_structure-profile = message150-zzprofile_id.
        result_structure-17_lebrb = 'X'.
        result_structure-09_levep_add = 'X'.
      ENDIF.
    WHEN '1C'.
      IF headdata-zzchoice_id_h EQ 'SINGLE'.
        result_structure-zchoice_id = headdata-zzchoice_id_h.
        result_structure-profile = '1A'.
        result_structure-17_lebrb = ' '.
        result_structure-09_levep_add = ' '.
      ENDIF.
      IF headdata-zzchoice_id_h EQ 'DOUBLE'.
        result_structure-zchoice_id = headdata-zzchoice_id_h.
        result_structure-profile = message150-zzprofile_id.
        result_structure-17_lebrb = ' '.
        result_structure-09_levep_add = ' '.
      ENDIF.
      IF headdata-zzchoice_id_h EQ 'BESTRATE'.
        result_structure-zchoice_id = headdata-zzchoice_id_h.
        result_structure-profile = message150-zzprofile_id.
        result_structure-17_lebrb = 'X'.
        result_structure-09_levep_add = 'X'.
      ENDIF.
    WHEN '2A'.
      IF headdata-zzchoice_id_h EQ 'SINGLE'.
        result_structure-zchoice_id = headdata-zzchoice_id_h.
        result_structure-profile = '2A'.
        result_structure-17_lebrb = ' '.
        result_structure-09_levep_add = ' '.
      ENDIF.
      IF headdata-zzchoice_id_h EQ 'DOUBLE'.
        result_structure-zchoice_id = headdata-zzchoice_id_h.
        result_structure-profile = message150-zzprofile_id.
        result_structure-17_lebrb = ' '.
        result_structure-09_levep_add = ' '.
      ENDIF.
      IF headdata-zzchoice_id_h EQ 'BESTRATE'.
        result_structure-zchoice_id = headdata-zzchoice_id_h.
        result_structure-profile = message150-zzprofile_id.
        result_structure-17_lebrb = 'X'.
        result_structure-09_levep_add = ' '.
      ENDIF.
    WHEN '2B'.
      IF headdata-zzchoice_id_h EQ 'SINGLE'.
        result_structure-zchoice_id = headdata-zzchoice_id_h.
        result_structure-profile = '2A'.
        result_structure-17_lebrb = ' '.
        result_structure-09_levep_add = ' '.
      ENDIF.
      IF headdata-zzchoice_id_h EQ 'DOUBLE'.
        result_structure-zchoice_id = headdata-zzchoice_id_h.
        result_structure-profile = message150-zzprofile_id.
        result_structure-17_lebrb = ' '.
        result_structure-09_levep_add = ' '.
      ENDIF.
      IF headdata-zzchoice_id_h EQ 'BESTRATE'.
        result_structure-zchoice_id = headdata-zzchoice_id_h.
        result_structure-profile = message150-zzprofile_id.
        result_structure-17_lebrb = 'X'.
        result_structure-09_levep_add = 'X'.
      ENDIF.
    WHEN OTHERS.  "Different profile
* do nothing
  ENDCASE.
ENDIF. "no keuzeprofiel

swc_set_element container 'result_structure' result_structure.
end_method.

************************************************************************
begin_method zpti_request_mr changing container.

DATA:
  register_boundaries TYPE zst_boundaries,
  ls_swtdoc           TYPE eideswtdoc.
SELECT SINGLE *
  FROM eideswtdoc
  INTO ls_swtdoc
  WHERE switchnum EQ object-key.
IF sy-subrc EQ 0.
  swc_get_element container 'Register_Boundaries' register_boundaries.
  CALL FUNCTION 'Z_PTI_METER_READ'
    EXPORTING
      i_pti_meter_read = ls_swtdoc
      i_boundary       = register_boundaries.
ELSE.
  exit_return 9001 space space space space.
ENDIF.

end_method.
************************************************************************
begin_method get_210_message_using_reasonid changing container.
DATA:
  reasonid                      TYPE eideswtmsgdata-transreason,
  message210                    LIKE eideswtmsgdata,
  automatic_processing_scenario LIKE boole,
  xy_msgdata                    TYPE TABLE OF eideswtmsgdata,
  wa_msgdata                    TYPE eideswtmsgdata,
  wa_150                        TYPE eideswtmsgdata,
  lv_switchdoc                  TYPE eideswtnum,
  lv_reasonid                   TYPE eideswtmsgdata-transreason,
  lv_device                     TYPE gernr,
  lv_150_processed,
  lv_new,
  lv_bis                        TYPE sy-datum.

lv_switchdoc = object-key. CLEAR automatic_processing_scenario.
swc_get_element container 'ReasonID' reasonid.

CALL FUNCTION 'Z_ISU_IDE_SWTDC_MSGDATA_GET'
  EXPORTING
    x_eideswtdoc     = lv_switchdoc
    x_direction      = '1'
  CHANGING
    xy_msgdata       = xy_msgdata
  EXCEPTIONS
    ex_not_possible  = 1
    ex_not_found     = 2
    ex_general_fault = 3
    ex_foreign_lock  = 4
    ex_userabort     = 5
    OTHERS           = 6.
SORT xy_msgdata BY msgdate msgtime DESCENDING.
IF reasonid = 'E24' OR reasonid = 'E25'.
  lv_reasonid = 'MUD'.
  READ TABLE xy_msgdata INTO wa_150 WITH KEY category = 'Z05'
                                             transreason = '002'.
* If 150 is received and metering method is filled
  IF sy-subrc EQ 0 OR wa_150-zzproduct_char IS NOT INITIAL.
    lv_150_processed = 'X'.
  ENDIF.

ELSE.
  lv_reasonid = reasonid.
ENDIF.

LOOP AT xy_msgdata INTO wa_msgdata WHERE category EQ 'Z04' AND
transreason EQ lv_reasonid.
  IF lv_reasonid = 'MUD'.

    IF lv_150_processed = 'X'.
* if processed, check if 210 meter is the one in the system, if  yes,E25
      IF wa_150-zzmeterno = wa_msgdata-zzmeterno.
        lv_new = abap_true.
      ELSE.
        CLEAR lv_new.
      ENDIF.

*If not processed, then check the meter number
    ELSE.
*check if meter exist, if yes, E24

      SELECT SINGLE e~bis INTO lv_bis
          FROM euitrans           AS a
       INNER JOIN euiinstln AS b
        ON a~int_ui = b~int_ui
      INNER JOIN eanl       AS c
        ON b~anlage = c~anlage
      INNER JOIN eanlh      AS d
        ON c~anlage = d~anlage
      INNER JOIN eastl  AS e
        ON d~anlage = e~anlage
      INNER JOIN egerr AS f
        ON e~logiknr = f~logiknr
      WHERE a~ext_ui  = wa_msgdata-ext_ui AND
            f~egerr_info = wa_msgdata-zzmeterno AND
            e~bis = '99991231'.

      IF sy-subrc EQ 0.
        CLEAR lv_new.
      ELSE.
        lv_new = 'X'.
      ENDIF.

      IF wa_msgdata-zzmeterno IS INITIAL.
        lv_new = 'X'.
      ENDIF.
    ENDIF.
    IF reasonid = 'E24' AND lv_new = 'X'.
      CONTINUE. " requested msg is old but current is new, keep looking
    ELSEIF reasonid = 'E24' AND lv_new = ' '.
      message210 = wa_msgdata. EXIT. "Old meter found
    ELSEIF reasonid = 'E25' AND lv_new = 'X'.
      message210 = wa_msgdata. EXIT. " New meter found
    ELSEIF reasonid = 'E25' AND lv_new = ' '.
      CONTINUE. " requested msg is new but current is old, keep looking
    ENDIF.
  ELSE.
    message210 = wa_msgdata. EXIT.
  ENDIF.
ENDLOOP.
swc_set_element container 'Message_210' message210.
end_method.

begin_method zisufillunjustifiedswbwpentry1 changing container.
DATA:
  x_msg_data_210 TYPE eideswtmsgdata,
  y_bwp_entry1   LIKE zwf_unjustified_sw_bwp_entry1,
  ls_swtdoc      TYPE eideswtdoc,
  lv_vstelle     TYPE vstelle,
  lv_connobj     TYPE haus,
  lv_anlage      TYPE anlage,
  lt_inst_facts  TYPE isu_iettifn,
  ls_inst_facts  TYPE ettifn.

CONSTANTS: co_e_op_invm TYPE e_operand     VALUE '21-LECONID',
           co_g_op_invm TYPE e_operand     VALUE '21-LGCONID',
           co_high      TYPE ztimeframe_id VALUE 'E11',
           co_low       TYPE ztimeframe_id VALUE 'E10'.


swc_get_element container 'X_MSG_DATA_210' x_msg_data_210.

SELECT SINGLE * FROM eideswtdoc INTO ls_swtdoc
             WHERE switchnum EQ object-key.

* Swtdoc fields
IF sy-subrc EQ 0.
  MOVE-CORRESPONDING ls_swtdoc TO y_bwp_entry1.
ENDIF.

* Scenario text
SELECT SINGLE swttypetxt
  INTO y_bwp_entry1-swttypetxt
  FROM eideswttypest
 WHERE swttype EQ ls_swtdoc-switchtype
   AND spras EQ sy-langu.

* Customer name
SELECT SINGLE name_first name_last
  INTO (y_bwp_entry1-name_first, y_bwp_entry1-name_last)
  FROM but000
 WHERE partner EQ ls_swtdoc-partner.
* when initial, use name1 field (used for SME small)
IF y_bwp_entry1-name_last IS INITIAL.
  SELECT SINGLE name_org1 INTO y_bwp_entry1-name_last FROM but000 WHERE
  partner EQ ls_swtdoc-partner.
ENDIF.

* EAN Code
* AUCT-UPGRADE -  Begin of Modification by <USER> on <17.02.2017> for <EHP8>
*SELECT SINGLE ext_ui
*  INTO y_bwp_entry1-eancode
*  FROM euitrans
* WHERE int_ui EQ ls_swtdoc-pod.
SELECT ext_ui
  INTO y_bwp_entry1-eancode
  FROM euitrans
 WHERE int_ui EQ ls_swtdoc-pod
ORDER BY PRIMARY KEY.
  EXIT.
ENDSELECT.
* AUCT-UPGRADE -  End of Modification by <USER> on <17.02.2017> for <EHP8>

* Meterreading data
* Electra
IF y_bwp_entry1-zzsparte EQ 'E '.
  IF NOT x_msg_data_210-zzqnty IS INITIAL.
*   High
    IF x_msg_data_210-zztimeframe_id EQ co_high.
      y_bwp_entry1-meterread_h     := x_msg_data_210-zzqnty.
      y_bwp_entry1-meterread_h_uom := x_msg_data_210-zzmeasu_unit_id.
*   Low
    ELSEIF x_msg_data_210-zztimeframe_id EQ co_low.
      y_bwp_entry1-meterread_l     := x_msg_data_210-zzqnty.
      y_bwp_entry1-meterread_l_uom := x_msg_data_210-zzmeasu_unit_id.
    ENDIF.
  ENDIF.

  IF NOT x_msg_data_210-zzqnty2 IS INITIAL.
*   High
    IF x_msg_data_210-zztimeframe_id2 EQ co_high.
      y_bwp_entry1-meterread_h     := x_msg_data_210-zzqnty2.
      y_bwp_entry1-meterread_h_uom := x_msg_data_210-zzmeasu_unit_id2.
*   Low
    ELSEIF x_msg_data_210-zztimeframe_id2 EQ co_low.
      y_bwp_entry1-meterread_l     := x_msg_data_210-zzqnty2.
      y_bwp_entry1-meterread_l_uom := x_msg_data_210-zzmeasu_unit_id2.
    ENDIF.
  ENDIF.
* Gas
ELSEIF y_bwp_entry1-zzsparte EQ 'G '.
  y_bwp_entry1-meterread_h     := x_msg_data_210-zzqnty.
  y_bwp_entry1-meterread_h_uom := x_msg_data_210-zzmeasu_unit_id.
ENDIF.

*- Connection object
* First get the premise:
SELECT SINGLE l~vstelle INTO lv_vstelle
  FROM eanl AS l
 INNER JOIN euiinstln AS u ON u~anlage = l~anlage
  INNER JOIN euitrans AS s ON s~int_ui = u~int_ui
  WHERE s~ext_ui = y_bwp_entry1-eancode.

* Select connection object:
SELECT SINGLE haus
  INTO lv_connobj
  FROM evbs
 WHERE vstelle EQ lv_vstelle.

* Address data connection object:
SELECT SINGLE a~street a~house_num1 a~house_num2 a~post_code1 a~city1
INTO (y_bwp_entry1-con_street,
      y_bwp_entry1-con_house,
      y_bwp_entry1-con_house_suppl,
      y_bwp_entry1-con_pc,
      y_bwp_entry1-con_city1)
      FROM v_ehau AS v  INNER JOIN adrc AS a
        ON v~addrnumber = a~addrnumber
            WHERE v~haus = lv_connobj.

*- Invoicemodel
* Haal installatie op:
* AUCT-UPGRADE -  Begin of Modification by <USER> on <17.02.2017> for <EHP8>
*SELECT SINGLE anlage INTO lv_anlage
*  FROM euiinstln
* WHERE int_ui EQ ls_swtdoc-pod.
SELECT anlage INTO lv_anlage
  FROM euiinstln
 WHERE int_ui EQ ls_swtdoc-pod
ORDER BY PRIMARY KEY.
  EXIT.
ENDSELECT.
* AUCT-UPGRADE -  End of Modification by <USER> on <17.02.2017> for <EHP8>

* Haal installation facts op
CALL FUNCTION 'ISU_INST_FACTS_READ'
  EXPORTING
    x_anlage      = lv_anlage
*   X_USE_IETTIFN =
*   X_USE_IETTIFB =
  CHANGING
    xy_iettifn    = lt_inst_facts
*   XY_IETTIFB    =
  EXCEPTIONS
    general_fault = 1
    OTHERS        = 2.
IF sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
ENDIF.

IF NOT lt_inst_facts IS INITIAL.
  SORT lt_inst_facts.
* Electra:
  IF y_bwp_entry1-zzsparte EQ 'E '.
    LOOP AT lt_inst_facts INTO ls_inst_facts
                          WHERE operand EQ co_e_op_invm
                            AND ab  LE sy-datum
                            AND bis GE sy-datum.
      EXIT.
    ENDLOOP.
* Gas
  ELSEIF  y_bwp_entry1-zzsparte EQ 'G '.
    LOOP AT lt_inst_facts INTO ls_inst_facts
                          WHERE operand EQ co_g_op_invm
                            AND ab  LE sy-datum
                            AND bis GE sy-datum.
      EXIT.
    ENDLOOP.
  ENDIF.
  IF sy-subrc EQ 0.
    y_bwp_entry1-inv_model := ls_inst_facts-string1.
  ENDIF.
ENDIF.

* Fill correct Supplier Text:
SELECT SINGLE sp_name
  INTO y_bwp_entry1-zzcorrsuppl_txt
  FROM eservprovt
* WHERE spras EQ sy-langu  "del def.1664: some are in EN, others in NL
  WHERE serviceid EQ y_bwp_entry1-zzcorrsuppl.

* Fill outstanding balance:
SELECT SUM( betrh ) INTO y_bwp_entry1-betrh
 FROM dfkkop
WHERE augst EQ space
  AND gpart EQ ls_swtdoc-partner
  AND augbl EQ space.

swc_set_element container 'y_bwp_entry1' y_bwp_entry1.

end_method.

get_property switch_log_message changing container.
DATA: lv_switchnum TYPE eideswtnum.
lv_switchnum = object-key.
CALL FUNCTION 'ZISU_CHECK_SWITCH_LOG'
  EXPORTING
    x_switchnum = lv_switchnum
*   X_DATE      =
*   X_TIME      =
*   X_LAG_DATE  =
*   X_LAG_TIME  =
  IMPORTING
*   Y_MSG       =
    y_msgtext   = object-switch_log_message
*   Y_LOG_ERR   =
  EXCEPTIONS
    error       = 1
    no_date_lag = 2
    no_time_lag = 3
    OTHERS      = 4.

swc_set_element container 'Switch_log_message'
     object-switch_log_message.
end_property.

begin_method new_contract changing container.
DATA:
  contract_new   TYPE ever-vertrag,
  lo_pod         TYPE swc_object,
  lv_int_ui      TYPE euihead-int_ui,
  lv_movein_date TYPE eideswtdoc-moveindate,
  lt_euiinstln   TYPE TABLE OF euiinstln,
  lw_euiinstln   LIKE euiinstln.

swc_get_property self 'PointOfDelivery' lo_pod.
swc_get_property lo_pod 'PointOfDelivery' lv_int_ui.
swc_get_property self 'MoveInDate' lv_movein_date.

* Get installations
SELECT * FROM euiinstln INTO TABLE lt_euiinstln
                WHERE int_ui    EQ lv_int_ui
                  AND dateto    GE lv_movein_date
                  AND datefrom  LE lv_movein_date.
LOOP AT lt_euiinstln INTO lw_euiinstln.  "only 1 installation
* to be implemented
ENDLOOP.







swc_set_element container 'Contract_New' contract_new.
end_method.

begin_method newer_switchdocs changing container.
DATA: newer_switchdocs_present TYPE boole-boole,
      wa_eideswtdoc            TYPE eideswtdoc,
      lv_pod                   TYPE eideswtdoc-pod,
      lv_creation_date         TYPE eideswtdoc-erdat.
* check for newer switchdocs (move in or switch in)
swc_get_property self 'PoD' lv_pod.
swc_get_property self 'Creation_date' lv_creation_date.
SELECT * FROM eideswtdoc INTO wa_eideswtdoc
  WHERE pod EQ lv_pod AND erdat GT lv_creation_date AND
 ( switchtype EQ '72' OR switchtype EQ '77' ).
  newer_switchdocs_present = 'X'.
  EXIT.
ENDSELECT.
swc_set_element container 'Newer_switchdocs_present'
     newer_switchdocs_present.
end_method.

************************************************************************
begin_method zmrreg_mass changing container.
DATA: va_bs_mr.
SET PARAMETER ID 'ZSWITCHNUM' FIELD object-key-switchnum.
SET PARAMETER ID 'datum' FIELD ''.
swc_get_element container 'BS_MR' va_bs_mr.
SET PARAMETER ID 'ZBS_MR' FIELD va_bs_mr.

"CALL TRANSACTION 'ZMRREG_MASS' AND SKIP FIRST SCREEN.
SUBMIT zisu_process_meterreadings                        "#EC CI_SUBMIT
         WITH p_date = ''
         WITH s_swtnum = object-key-switchnum
         WITH p_bs_mr = va_bs_mr
         AND RETURN.
end_method.
************************************************************************

begin_method zgetmovedocsfromswdoc changing container.

DATA: lf_keydate TYPE sy-datum,
      lf_movein  TYPE swu_flag-flag,
      lf_moveout TYPE swu_flag-flag,
      ls_ever    TYPE ever,
      ls_eein    TYPE eein,
      ls_eeinv   TYPE eeinv,
      ls_eaus    TYPE eaus,
      ls_eausv   TYPE eausv,
      ls_return  TYPE bapiret2.

* Read import...
swc_get_element container 'KeyDate'        lf_keydate.
swc_get_element container 'ReadMoveInDoc'  lf_movein.
swc_get_element container 'ReadMoveOutDoc' lf_moveout.

IF lf_keydate IS INITIAL.
  lf_keydate = sy-datum.
ENDIF.

* Get contract info and related Move-In / Move-Out docs via
* switch document
CALL FUNCTION 'ZISU_MOVEDOC_FROM_SWDOC_WF'
  EXPORTING
    xf_switchnum = object-key-switchnum
    xf_keydate   = lf_keydate
    xf_movein    = lf_movein
    xf_moveout   = lf_moveout
  IMPORTING
    ys_ever      = ls_ever
    ys_eein      = ls_eein
    ys_eeinv     = ls_eeinv
    ys_eaus      = ls_eaus
    ys_eausv     = ls_eausv
    ys_return    = ls_return
  EXCEPTIONS
    OTHERS       = 01.

* Save export...
swc_set_element container 'YS_EVER'  ls_ever.
swc_set_element container 'YS_EEIN'  ls_eein.
swc_set_element container 'YS_EEINV' ls_eeinv.
swc_set_element container 'YS_EAUS'  ls_eaus.
swc_set_element container 'YS_EAUSV' ls_eausv.
swc_set_element container 'Return'   ls_return.

end_method.

begin_method zprintswitchbackletter changing container.

DATA: lf_rdi       TYPE efgpd-rdi,
      lf_immed     TYPE itcpo-tdimmed,
      lf_delete    TYPE itcpo-tddelete,
      ls_rdiresult TYPE rdiresult,
      ls_return    TYPE bapiret2.

* Read import...
swc_get_element container 'RDI'               lf_rdi.
swc_get_element container 'PrintImmediately'  lf_immed.
swc_get_element container 'DeleteAfterOutput' lf_delete.

CALL FUNCTION 'ZISU_SWDOC_PRNT_SWBACKLETTER'
  EXPORTING
    xf_switchnum = object-key-switchnum
    xf_rdi       = lf_rdi
    xf_immed     = lf_immed
    xf_delete    = lf_delete
  IMPORTING
    ys_rdiresult = ls_rdiresult
    ys_return    = ls_return
  EXCEPTIONS
    OTHERS       = 01.

* Save export...
swc_set_element container 'RDIResult' ls_rdiresult.
swc_set_element container 'Return'    ls_return.

* Raise exception in case of error message
CHECK ls_return-type = 'E'  OR
      ls_return-type = 'A'.

* Ignore 'user cancelled' error...
IF ls_return-id     = 'TD'  AND
   ls_return-number = '419'.
* Only possible in dialog, user pressed cancel in print dialog...
ELSE.
* 'Real' error --> raise exception...
  exit_return '1001' 'ISUSWITCHD' 'ZPrintSwitchBackLetter' '' ''.
ENDIF.

end_method.

begin_method zisufillunjustswitchsbbwpentry changing container.
DATA:
  y_entry_bwp LIKE zwf_unjustified_sw_sb_bwp,
  ls_swtdoc   TYPE eideswtdoc,
*      ls_line         TYPE zeideswt_swiback,
  lv_domval   TYPE domvalue_l,
  lv_domtxt   TYPE ddtext.

SELECT SINGLE * FROM eideswtdoc INTO ls_swtdoc
WHERE switchnum EQ object-key.

* Swtdoc fields
IF sy-subrc EQ 0.
  MOVE-CORRESPONDING ls_swtdoc TO y_entry_bwp.
ENDIF.

* Scenario text
SELECT SINGLE swttypetxt
  INTO y_entry_bwp-swttypetxt
  FROM eideswttypest
 WHERE swttype EQ ls_swtdoc-switchtype
   AND spras EQ sy-langu.

* EAN Code
* AUCT-UPGRADE -  Begin of Modification by <USER> on <17.02.2017> for <EHP8>
*SELECT SINGLE ext_ui
*  INTO y_entry_bwp-eancode
*  FROM euitrans
* WHERE int_ui EQ ls_swtdoc-pod.
SELECT ext_ui
  INTO y_entry_bwp-eancode
  FROM euitrans
 WHERE int_ui EQ ls_swtdoc-pod
ORDER BY PRIMARY KEY.
  EXIT.
ENDSELECT.
* AUCT-UPGRADE -  End of Modification by <USER> on <17.02.2017> for <EHP8>

* Division (if not allready filled)
IF y_entry_bwp-zzsparte IS INITIAL.
  SELECT SINGLE l~sparte INTO y_entry_bwp-zzsparte
  FROM eanl AS l
   INNER JOIN euiinstln AS e
   ON e~anlage = l~anlage
   WHERE e~int_ui EQ ls_swtdoc-pod.
ENDIF.

* SB velden
y_entry_bwp-husclass2 := ls_swtdoc-zzhusclass2.
lv_domval: = y_entry_bwp-husclass2.
CALL FUNCTION 'DOMAIN_VALUE_GET'
  EXPORTING
    i_domname  = 'ZHUSCLASS2'
    i_domvalue = lv_domval
  IMPORTING
    e_ddtext   = lv_domtxt
  EXCEPTIONS
    not_exist  = 1
    OTHERS     = 2.

IF sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
ELSE.
  y_entry_bwp-husclass2text := lv_domtxt.
ENDIF.

swc_set_element container 'y_entry_bwp' y_entry_bwp.
end_method.

begin_method moveindate_minus_1 changing container.
DATA:
  move_in_date_minus_1 TYPE syst-datum,
  lv_move_in_date      TYPE syst-datum.
swc_get_property self 'MoveInDate' lv_move_in_date.
move_in_date_minus_1 = lv_move_in_date - 1.
swc_set_element container 'move_in_date_minus_1' move_in_date_minus_1.
end_method.

begin_method zsbcreateccp3015file changing container.

DATA: ls_return TYPE bapiret2.

* Create CCP 3015 entry in table for later file generation...
CALL FUNCTION 'ZISU_SWDOC_CREATE_CCP3015_FILE'
  EXPORTING
    xf_switchnum = object-key-switchnum
  IMPORTING
    ys_return    = ls_return
  EXCEPTIONS
    OTHERS       = 01.

* Save export...
swc_set_element container 'Return' ls_return.

* Raise exception in case of error message
CHECK ls_return-type = 'E'  OR
      ls_return-type = 'A'.

* Error --> raise exception...
exit_return '1001' 'ISUSWITCHD' 'ZSBCreateCCP3015File' '' ''.

end_method.

************************************************************************
begin_method z_create_swdoc_for_correction changing container.
* Create new switchdocument to correct wrong switchout/fmo
DATA: ls_eideswtdoc    TYPE eideswtdoc,
      ls_msgdata       TYPE eideswtmsgdata,
      lv_new_switchnum TYPE eideswtnum,
      lo_new_swdoc     TYPE swc_object,
      lv_message       TYPE string,
      lv_date          TYPE dats.
CLEAR: ls_eideswtdoc, ls_msgdata.

swc_get_element container 'SB_MoveIN_Date' lv_date.

* Get current swdoc as base
SELECT SINGLE * FROM eideswtdoc INTO ls_eideswtdoc
       WHERE switchnum EQ object-key.
IF sy-subrc NE 0.
  exit_return '9057' object-key '' '' ''.
ENDIF.
CLEAR: ls_eideswtdoc-switchnum.
* If current process is switch-out, new one has to be switch-in
CASE ls_eideswtdoc-switchtype.
  WHEN '73'. ls_eideswtdoc-switchtype = '72'.
  WHEN '76'. ls_eideswtdoc-switchtype = '77'.
  WHEN OTHERS.  exit_return '9027' ls_eideswtdoc-switchtype '' '' ''.
ENDCASE.
IF ls_eideswtdoc-zzsparte IS INITIAL.
* get mandatory sparte
  SELECT SINGLE division INTO ls_eideswtdoc-zzsparte FROM eservprov
     JOIN tecde ON tecde~service EQ eservprov~service
     WHERE serviceid EQ ls_eideswtdoc-distributor.
ENDIF.
IF ls_eideswtdoc-zzvkont IS INITIAL.
* get mandatory zzvkont
*  IF ls_eideswtdoc-zzcontractnow IS INITIAL.
*    CALL FUNCTION 'ISU_INT_UI_DETERMINE'
*      EXPORTING
*        x_int_pod  = ls_eideswtdoc-pod
*        x_keydate  = ls_eideswtdoc-moveoutdate
*      IMPORTING
*        y_contract = ls_eideswtdoc-zzcontractnow
*      EXCEPTIONS
*        OTHERS     = 4.
*  ENDIF.
*  IF ls_eideswtdoc-zzcontractnow IS NOT INITIAL.
*    SELECT SINGLE vkonto FROM ever INTO ls_eideswtdoc-zzvkont
*      WHERE vertrag EQ ls_eideswtdoc-zzcontractnow.
*  ENDIF.
  swc_get_element container 'ContractAccount' ls_eideswtdoc-zzvkont.

ENDIF.

* Create new swdoc
CALL FUNCTION 'Z_ISU_CREATE_SWITCH_DOC'
  EXPORTING
    i_eideswtdoc = ls_eideswtdoc
    i_msgdata    = ls_msgdata
    i_online     = 'X'
    i_switchtype = ls_eideswtdoc-switchtype
    i_category   = 'Z07'
    i_date       = lv_date
    i_scenario   = 'OA'   "specially for Unjustified switch
  IMPORTING
    e_switchnum  = lv_new_switchnum
  EXCEPTIONS
    error        = 1
    OTHERS       = 2.
IF sy-subrc <> 0.
  MESSAGE ID sy-msgid TYPE 'E' NUMBER sy-msgno WITH
     sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 INTO lv_message.
  exit_return '9001' lv_message '' '' ''.
ENDIF.

* Return parameters
*swc_set_element container 'SB_MoveIN_Date' lv_date.
swc_create_object lo_new_swdoc 'ISUSWITCHD' lv_new_switchnum.
swc_set_element container 'new_switchdocument' lo_new_swdoc.

* Create reference to new swdoc on old swdoc
swc_container lt_container.
swc_set_element lt_container 'Activity' 'ZC1'.
swc_set_element lt_container 'Status' '07'.
swc_set_element lt_container 'RefObjectType' 'ISUSWITCHD'.
swc_set_element lt_container 'RefObjectKey'  lv_new_switchnum.
swc_call_method self 'SetStatusActivity' lt_container.

* Create reference to old swdoc on new swdoc
swc_clear_container lt_container.
swc_set_element lt_container 'Activity' 'ZC2'.
swc_set_element lt_container 'Status' '07'.
swc_set_element lt_container 'RefObjectType' 'ISUSWITCHD'.
swc_set_element lt_container 'RefObjectKey'  object-key.
swc_call_method lo_new_swdoc 'SetStatusActivity' lt_container.

end_method.

************************************************************************


begin_method update_contract changing container.
* first of all get the contract.
DATA:
  ean_code            TYPE ext_ui, validity_start_date TYPE datum,
  headdata            TYPE eideswtdoc,
  contract_data       LIKE zisu_contract_data_find,
  lt_contracts        TYPE TABLE OF zisu_contract_data_find,
  lt_return           TYPE TABLE OF bapireturn1,
  e_lines             TYPE i, ls_zisu_everh TYPE zisu_everh.
swc_get_element container 'ext_ui' ean_code.
swc_get_element container 'validity_start_date' validity_start_date.
swc_get_element container 'headdata' headdata.

CALL FUNCTION 'Z_ISU_FIND_CONTRACT_VIA_ADDR'
  EXPORTING
    i_ean        = ean_code
    i_langu      = sy-langu
  TABLES
    pt_contracts = lt_contracts
    pt_return    = lt_return.
DESCRIBE TABLE lt_contracts LINES e_lines.
IF e_lines EQ 1. "it should only return 1 active contract
  READ TABLE lt_contracts INTO contract_data INDEX 1.
ELSE.
  exit_return 9001 'not 1 entry found' space space space.
ENDIF.
* update ZISU_EVERH table with 4 fields from switch document.
* AUCT-UPGRADE -  Begin of Modification by <USER> on <17.02.2017> for <EHP8>
*SELECT SINGLE * FROM zisu_everh INTO ls_zisu_everh WHERE
*   vertrag EQ contract_data-vertrag AND
*   startdat LE validity_start_date AND
*   enddat GE validity_start_date.
SELECT * UP TO 1 ROWS FROM zisu_everh INTO ls_zisu_everh WHERE
vertrag EQ contract_data-vertrag AND
startdat LE validity_start_date AND
enddat GE validity_start_date
ORDER BY PRIMARY KEY.
ENDSELECT.
* AUCT-UPGRADE -  End of Modification by <USER> on <17.02.2017> for <EHP8>
IF NOT ls_zisu_everh IS INITIAL.
  ls_zisu_everh-penalty = headdata-zzpenalty.
  ls_zisu_everh-cashback = headdata-zzcashback.
  ls_zisu_everh-refund_nle = headdata-zzrefund_nle.
  ls_zisu_everh-refund_oth = headdata-zzrefund_oth.
  MODIFY zisu_everh FROM ls_zisu_everh.
ENDIF.
end_method.

begin_method zsetsbdata changing container.

*DATA:
*      x_wi_id      TYPE swp_header-wf_id,
*      x_sb_mi_date TYPE zeideswt_swiback-sb_mi_date,
*      lv_sw_num    TYPE eideswtnum,
*      ls_line      TYPE zeideswt_swiback,
*     lv_subrc     TYPE sysubrc.

*swc_get_element container 'x_wi_id' x_wi_id.
*swc_get_element container 'x_sb_mi_date' x_sb_mi_date.

* SB velden
*lv_sw_num := object-key.
*CALL METHOD zcl_eideswt_swiback=>get
*  EXPORTING
*    eideswtnum = lv_sw_num
*  RECEIVING
*    line       = ls_line.

*ls_line-wi_id := x_wi_id.
*ls_line-sb_mi_date := x_sb_mi_date.

* Set SB Data
*CALL METHOD zcl_eideswt_swiback=>set
*  EXPORTING
*    line  = ls_line
*  RECEIVING
*    subrc = lv_subrc.

end_method.

begin_method zsetoadata changing container.
*DATA:
*      x_wi_id TYPE swp_header-wf_id,
*     lv_sw_num    TYPE eideswtnum,
*      ls_line      TYPE zeideswt_unjuswt,
*      lv_subrc     TYPE sysubrc.
*
*swc_get_element container 'x_wi_id' x_wi_id.
*
** SB velden
*lv_sw_num := object-key.
*CALL METHOD zcl_eideswt_unjuswt=>get
*  EXPORTING
*    eideswtnum = lv_sw_num
*  RECEIVING
*    line       = ls_line.
*
*ls_line-wi_id := x_wi_id.
*
* Set SB Data
*CALL METHOD zcl_eideswt_unjuswt=>set
*  EXPORTING
*    line  = ls_line
*  RECEIVING
*    subrc = lv_subrc.
*
end_method.

************************************************************************

begin_method zclearoadata changing container.

DATA: headdata      TYPE eideswtdoc,
      lr_switchdoc  TYPE REF TO cl_isu_ide_switchdoc,
      l_msg         LIKE sy-msgv1,
      messtext(125) TYPE c.

CALL METHOD cl_isu_switchdoc=>select
  EXPORTING
    x_switchnum = object-key-switchnum
    x_wmode     = cl_isu_wmode=>co_change
  RECEIVING
    y_switchdoc = lr_switchdoc
  EXCEPTIONS
    OTHERS      = 7.
IF sy-subrc <> 0.
  EXIT.
ENDIF.
* Clear the OA fields
lr_switchdoc->set_property( x_property = 'ZZHUSCLASS' x_value = '' ).
lr_switchdoc->set_property( x_property = 'ZZDESPOBOX' x_value = '' ).
lr_switchdoc->set_property( x_property = 'ZZCORRSUPPL' x_value = '' ).
lr_switchdoc->save( x_no_commit = '' ).
lr_switchdoc->close( ).

end_method.

************************************************************************

begin_method zcreate1300withzeroreading changing container.

* Method creates a 1300 message with a zero meterreading
* This is necessary for G2C profiles, see FD IC069

DATA: y_return       TYPE bapireturn1,
      ls_switchdoc   TYPE eideswtdoc,
      ls_msgdata1150 TYPE eideswtmsgdata,
      ls_msgdata1300 TYPE eideswtmsgdata.
CLEAR: y_return.
* Prerequisite: Profile ID must exists and must be 'G2C'
* AUCT-UPGRADE -  Begin of Modification by <USER> on <17.02.2017> for <EHP8>
*SELECT SINGLE * FROM eideswtmsgdata INTO ls_msgdata1150
*     WHERE switchnum EQ object-key-switchnum
*       AND category  EQ zcl_switchdoc=>co_msgcat_md.
SELECT * UP TO 1 ROWS FROM eideswtmsgdata INTO ls_msgdata1150
WHERE switchnum EQ object-key-switchnum
AND category EQ zcl_switchdoc=>co_msgcat_md
ORDER BY PRIMARY KEY.
ENDSELECT.
* AUCT-UPGRADE -  End of Modification by <USER> on <17.02.2017> for <EHP8>
IF sy-subrc NE 0 OR ls_msgdata1150-zzprofile_id NE 'G2C'.
  y_return-type = 'S'.
  y_return-id = 'ZISU_VM'.
  y_return-number = '037'.
  MESSAGE s037(zisu_vm) INTO y_return-message.
ENDIF.

* Prerequisite: 1300 (or 1210) cannot be present on swdoc
IF y_return IS INITIAL.
* AUCT-UPGRADE -  Begin of Modification by <USER> on <17.02.2017> for <EHP8>
*  SELECT SINGLE * FROM eideswtmsgdata INTO ls_msgdata1300
*     WHERE switchnum EQ object-key-switchnum
*       AND category  EQ zcl_switchdoc=>co_msgcat_mtr.
  SELECT * UP TO 1 ROWS FROM eideswtmsgdata INTO ls_msgdata1300
  WHERE switchnum EQ object-key-switchnum
  AND category EQ zcl_switchdoc=>co_msgcat_mtr
  ORDER BY PRIMARY KEY.
  ENDSELECT.
* AUCT-UPGRADE -  End of Modification by <USER> on <17.02.2017> for <EHP8>
  IF sy-subrc EQ 0.
    y_return-type = 'S'.
    y_return-id = 'ZISU_VM'.
    y_return-number = '036'.
    MESSAGE s036(zisu_vm) INTO y_return-message.
  ENDIF.
ENDIF.

* Create 1300 message and attach it to this switchdocument
IF y_return IS INITIAL.
  SELECT SINGLE * FROM eideswtdoc INTO ls_switchdoc
    WHERE switchnum EQ object-key-switchnum.
  IF sy-subrc NE 0.
  ENDIF.

* 1. Set msgdata
  CLEAR: ls_msgdata1300.
  MOVE-CORRESPONDING ls_switchdoc TO ls_msgdata1300.
  ls_msgdata1300-category  = zcl_switchdoc=>co_msgcat_mtr.
  ls_msgdata1300-direction = zcl_switchdoc=>co_direction_out.
  ls_msgdata1300-ext_ui    = ls_msgdata1150-ext_ui.
  ls_msgdata1300-zzqnty           = '0'.
  ls_msgdata1300-zzqualification  = '22'.
  ls_msgdata1300-zzmove_reason_id = ls_msgdata1150-zzmove_reason_id.
  ls_msgdata1300-zzqnty_type_id   = '220'.
  ls_msgdata1300-zzqnty_date_typ  = '386'.
  ls_msgdata1300-zzmeasu_unit_id  = 'MTQ'.
  IF ls_switchdoc-moveindate IS NOT INITIAL.
    ls_msgdata1300-zzqnty_date = ls_switchdoc-moveindate.
  ELSE.
    ls_msgdata1300-zzqnty_date = ls_switchdoc-moveoutdate.
  ENDIF.

* 2. Call function to create 1300 message and attach it to this switchdo
  CALL FUNCTION 'Z_ISU_CREATE_SWITCH_DOC'
    EXPORTING
      i_eideswtdoc = ls_switchdoc
      i_msgdata    = ls_msgdata1300
      i_switchtype = ls_switchdoc-switchtype
      i_category   = ls_msgdata1300-category
      i_date       = ls_msgdata1300-zzqnty_date
      i_online     = 'X'                 " call in background
    IMPORTING
      e_switchnum  = ls_switchdoc-switchnum
    EXCEPTIONS
      error        = 1
      OTHERS       = 2.
* 3. Return message
  IF sy-subrc EQ 0.
    IF object-key-switchnum EQ ls_switchdoc-switchnum.
      y_return-type = 'S'.
      y_return-id = 'ZISU_AUTO'.
      y_return-number = '034'.
      MESSAGE s034(zisu_auto) WITH ls_switchdoc-switchnum
                              INTO y_return-message.
    ELSE.
      y_return-type = 'W'.
      y_return-id = 'ZISU_AUTO'.
      y_return-number = '035'.
      MESSAGE w035(zisu_auto) WITH ls_switchdoc-switchnum
                              INTO y_return-message.
    ENDIF.
  ELSE.
    y_return-type = 'E'.
    y_return-id = 'ZISU_VM'.
    y_return-number = '029'.
    MESSAGE e029(zisu_vm) INTO y_return-message.
  ENDIF.

ENDIF.

swc_set_element container 'y_return' y_return.

end_method.

************************************************************************

begin_method zclearsbdata changing container.

DATA: headdata      TYPE eideswtdoc,
      lr_switchdoc  TYPE REF TO cl_isu_ide_switchdoc,
      l_msg         LIKE sy-msgv1,
      messtext(125) TYPE c.

CALL METHOD cl_isu_switchdoc=>select
  EXPORTING
    x_switchnum = object-key-switchnum
    x_wmode     = cl_isu_wmode=>co_change
  RECEIVING
    y_switchdoc = lr_switchdoc
  EXCEPTIONS
    OTHERS      = 7.
IF sy-subrc <> 0.
  EXIT.
ENDIF.
* Clear the SB fields
lr_switchdoc->set_property( x_property = 'ZZHUSCLASS2' x_value = '' ).
lr_switchdoc->save( x_no_commit = '' ).
lr_switchdoc->close( ).

end_method.

************************************************************************

begin_method getcontractdata changing container.
DATA:
  installation    TYPE eanl-anlage,
  switchnum       TYPE eideswtdoc-switchnum,
  int_ui          TYPE euiinstln-int_ui,
  ls_ever         TYPE ever,
  lt_ever         TYPE TABLE OF ever,
  vkonto          TYPE ever-vkonto,
  vbeginn         TYPE ever-vbeginn,
  x_headdata      LIKE eideswtdoc,
  x_best_rate     LIKE zisu_rate_cat_det_profile,
  x_profile       TYPE zisu_get_contract_data_out-profile,
  i_data          TYPE zisu_get_contract_data_in,
  e_data          TYPE zisu_get_contract_data_out,
  zchoice_id      TYPE zisu_ever_choise-zchoice_id,
  partner         TYPE fkkvkp-gpart,
  e_duration      TYPE zz_duration,
  e_tariftyp      TYPE tariftyp_anl,
  e_campaign      TYPE zz_crm_markt_campaign,
  e_product       TYPE comt_product_id_co,
  e_startdat      TYPE datum,
  e_enddat_camp   TYPE datum,
  lv_moveindate   TYPE sy-datum,
  lv_switchtype   TYPE eideswttype,
  zzregister_date TYPE eideswtdoc-zzregister_date,
  timestamp       TYPE eideswtdoc-timestamp,
  anlart          TYPE eanl-anlart,
  sparte          TYPE eanl-sparte,
  snum(20)        TYPE n.

z_utility=>breakpoint_wf( 'GET_CONTRACT_DATA' ).

swc_get_element container 'INSTALLATION' installation.
swc_get_element container 'SwitchNum'    switchnum.

* AUCT-UPGRADE -  Begin of Modification by <USER> on <17.02.2017> for <EHP8>
*SELECT SINGLE int_ui INTO int_ui FROM euiinstln
*  WHERE anlage    = installation
*  AND   dateto   >= sy-datum
*  AND   datefrom <= sy-datum.
SELECT int_ui INTO int_ui FROM euiinstln
  WHERE anlage    = installation
  AND   dateto   >= sy-datum
  AND   datefrom <= sy-datum
ORDER BY PRIMARY KEY.
  EXIT.
ENDSELECT.
* AUCT-UPGRADE -  End of Modification by <USER> on <17.02.2017> for <EHP8>
CHECK sy-subrc = 0.

* AUCT-UPGRADE -  Begin of Modification by <USER> on <17.02.2017> for <EHP8>
*SELECT SINGLE ext_ui INTO i_data-ext_ui FROM  euitrans
*  WHERE  int_ui = int_ui.
SELECT ext_ui INTO i_data-ext_ui FROM euitrans
  WHERE  int_ui = int_ui
ORDER BY PRIMARY KEY.
  EXIT.
ENDSELECT.
* AUCT-UPGRADE -  End of Modification by <USER> on <17.02.2017> for <EHP8>
CHECK sy-subrc = 0.
* Now get the most recent contract.
SELECT *
       INTO TABLE lt_ever
       FROM ever
      WHERE anlage = installation
        AND vbeginn <= sy-datum
        AND vende   >= sy-datum.
SORT lt_ever BY auszdat DESCENDING.
READ TABLE lt_ever INTO ls_ever INDEX 1.
CHECK sy-subrc = 0.
i_data-vertrag = ls_ever-vertrag.
vbeginn        = ls_ever-vbeginn.
vkonto         = ls_ever-vkonto.
CHECK sy-subrc = 0.

i_data-anlage = installation.
CALL FUNCTION 'Z_ISU_GET_CONTRACT_DATA'
  EXPORTING
    i_data = i_data
  IMPORTING
    e_data = e_data.

CLEAR zchoice_id.
* AUCT-UPGRADE -  Begin of Modification by <USER> on <17.02.2017> for <EHP8>
*SELECT SINGLE zchoice_id INTO zchoice_id FROM zisu_ever_choise
*  WHERE contract = i_data-vertrag
*  AND dat0045   <= sy-datum.
SELECT zchoice_id INTO zchoice_id FROM zisu_ever_choise
  WHERE contract = i_data-vertrag
  AND dat0045   <= sy-datum
ORDER BY PRIMARY KEY.
  EXIT.
ENDSELECT.
* AUCT-UPGRADE -  End of Modification by <USER> on <17.02.2017> for <EHP8>

CALL FUNCTION 'Z_MD_LOOKUP_RATE_VIA_CONTRACT'
  EXPORTING
    i_contract_old  = i_data-vertrag
    i_keydate       = sy-datum
    i_profile       = e_data-profile
    i_tariff_code   = e_data-tariff_code
    i_kkp           = zchoice_id
  IMPORTING
    e_duration      = e_duration
    e_tariftyp      = e_tariftyp
    e_campaign      = e_campaign
    e_product       = e_product
    e_startdat      = e_startdat
    e_enddat        = e_enddat_camp
  EXCEPTIONS
    everh_not_found = 1
    error_data      = 2
    OTHERS          = 3.

snum = switchnum.   "Create leading zeros
switchnum = snum.
SELECT SINGLE zzregister_date timestamp moveindate switchtype
       INTO (zzregister_date, timestamp, lv_moveindate, lv_switchtype)
       FROM eideswtdoc
      WHERE switchnum = switchnum.
IF zzregister_date IS INITIAL.
  CONVERT TIME STAMP   timestamp
          TIME ZONE    'UTC   '
          INTO DATE    zzregister_date.
ENDIF.
SELECT SINGLE anlart sparte INTO (anlart, sparte) FROM eanl
  WHERE  anlage = installation.
IF sy-subrc = 0.
  IF sparte = 'E'.
    x_profile = e_data-profile+1(2).
  ELSE.
    x_profile = e_data-profile.
  ENDIF.

* -------------------------------------------------------------------
* >> 17.04.2014, Process profile change, keep single rate if necessary
* -------------------------------------------------------------------
  DATA: lv_zzvalidity_s_dat TYPE zvalidity_start_date.
  DATA: lv_enddat           TYPE datum.
  DATA: lv_current_profile  TYPE zprofile_id.
  DATA: lv_previous_profile TYPE zprofile_id.

  IF sparte = 'E'.
* AUCT-UPGRADE -  Begin of Modification by <USER> on <17.02.2017> for <EHP8>
*    SELECT SINGLE zzvalidity_s_dat INTO lv_zzvalidity_s_dat FROM eideswtmsgdata
*     WHERE switchnum = switchnum
*     AND   category  = 'Z05'.
    SELECT zzvalidity_s_dat INTO lv_zzvalidity_s_dat FROM eideswtmsgdata
         WHERE switchnum = switchnum
         AND   category  = 'Z05'
    ORDER BY PRIMARY KEY.
      EXIT.
    ENDSELECT.
* AUCT-UPGRADE -  End of Modification by <USER> on <17.02.2017> for <EHP8>
    IF sy-subrc = 0.
* AUCT-UPGRADE -  Begin of Modification by <USER> on <17.02.2017> for <EHP8>
*      SELECT SINGLE profile INTO lv_current_profile FROM zinst_verbprof
*        WHERE anlage = installation
*        AND   enddat = '99991231'.
      SELECT profile INTO lv_current_profile FROM zinst_verbprof
              WHERE anlage = installation
              AND   enddat = '99991231'
      ORDER BY PRIMARY KEY.
        EXIT.
      ENDSELECT.
* AUCT-UPGRADE -  End of Modification by <USER> on <17.02.2017> for <EHP8>

      IF sy-subrc = 0.
        lv_enddat = lv_zzvalidity_s_dat - 1.
* AUCT-UPGRADE -  Begin of Modification by <USER> on <17.02.2017> for <EHP8>
*        SELECT SINGLE profile INTO lv_previous_profile FROM zinst_verbprof
*          WHERE anlage = installation
*          AND   enddat = lv_enddat.
        SELECT profile INTO lv_previous_profile FROM zinst_verbprof
                  WHERE anlage = installation
                  AND   enddat = lv_enddat
        ORDER BY PRIMARY KEY.
          EXIT.
        ENDSELECT.
* AUCT-UPGRADE -  End of Modification by <USER> on <17.02.2017> for <EHP8>
      ENDIF.
    ENDIF.

    IF ( lv_previous_profile = 'E1A' OR lv_previous_profile = 'E2A' ) AND
       ( lv_current_profile <> 'E1A' AND  lv_current_profile <> 'E2A' ).
      IF zchoice_id <> 'CPD'.
        x_profile+1(1) = 'A'.
      ENDIF.
    ENDIF.
  ENDIF.
* << 17.04.2014, Process profile change, keep single rate if necessary


  CALL FUNCTION 'Z_MD_DETERMINE_RATE_CATEGORY'
    EXPORTING
      x_crm_product        = e_product
      x_crm_campaign       = e_campaign
      x_duration           = e_duration
      x_reg_date           = zzregister_date
      x_movein_date        = e_startdat   "vbeginn
      x_profile            = x_profile
      x_tariff_code        = anlart
      x_kkp                = zchoice_id
    IMPORTING
      y_rate_cat           = x_headdata-zztarifftype
      y_price_code_norm    = x_headdata-zzprice_normal
      y_price_code_high    = x_headdata-zzprice_high
      y_price_code_low     = x_headdata-zzprice_low
      y_once_fixed         = x_headdata-zzdisc_fixed
      y_percentage         = x_headdata-zzdisc_perc
      y_month_fixed        = x_headdata-zzdisc_month_ind
      y_cap_price_norm     = x_headdata-zzcap_price_norm
      y_cap_price_high     = x_headdata-zzcap_price_high
      y_cap_price_low      = x_headdata-zzcap_price_low
      y_end_date           = x_headdata-zzend_date
      y_cap_date           = x_headdata-zzcap_date
      y_fixed_charge       = x_headdata-zzfixed_charge
    EXCEPTIONS
      ex_missing_parameter = 1
      ex_no_value_found    = 2
      OTHERS               = 3.
ENDIF.

x_headdata-switchnum        = switchnum.
x_headdata-zzcrm_product    = e_product.
x_headdata-zzmarketcampaign = e_campaign.
x_headdata-zzcontract_lngth = e_duration.
x_headdata-zzregister_date  = zzregister_date.
IF ( lv_switchtype = '79' ).
  x_headdata-moveindate = lv_moveindate.
  x_headdata-zzend_date  = e_enddat_camp.
ELSE.
  x_headdata-moveindate = vbeginn.
ENDIF.
x_headdata-zzsparte         = sparte.
x_best_rate-zchoice_id      = zchoice_id.
x_profile                   = x_profile.

swc_set_element container 'X_HEADDATA'  x_headdata.
swc_set_element container 'X_BEST_RATE' x_best_rate.
swc_set_element container 'X_PROFILE'   x_profile.
end_method.

begin_method modifymessage changing container.
DATA:
  message_210  LIKE eideswtmsgdata,
  installation TYPE eanl-anlage,
  datetype     TYPE eideswtmsgdata-zzqnty_date_typ.
swc_get_element container 'Message_210' message_210.
swc_get_element container 'Installation' installation.
swc_get_element container 'DateType' datetype.

message_210-zzmove_rqst_id   = installation. "Dummy field
message_210-zzqnty_date_typ  = datetype.
message_210-zzqnty_date_typ2 = datetype.

swc_set_element container 'Message_210' message_210.
end_method.

begin_method zcheck_letter_printed changing container.
DATA: switchdocumentno TYPE eideswtdoc-switchnum,
      lv_dummy         TYPE char50,
      lv_print_date    TYPE zprint_datum.

swc_get_element container 'SwitchDocumentNo' switchdocumentno.

CALL METHOD zcl_wf_clarification_case=>case_check_letter_printed
  EXPORTING
    ip_switchnum = switchdocumentno
  EXCEPTIONS
    not_created  = 1
    OTHERS       = 2.

IF sy-subrc <> 0.
  exit_return 1005 switchdocumentno space space space.
ENDIF.

end_method.

begin_method zfindcaseandclose changing container.
DATA: ls_case            TYPE emma_case,
      ls_ret             TYPE bapiret2,
      lt_ret             TYPE bapiret2_t,
      clarifcasecategory TYPE emmac_ccat_hdr-ccat,
      primaryobjecttype  TYPE emma_bpc-objtype.

swc_get_element container 'PrimaryObjectType' primaryobjecttype.
swc_get_element container 'ClarifCaseCategory' clarifcasecategory.

* select via index -Check for Existence of Identical Cases
* AUCT-UPGRADE -  Begin of Modification by <USER> on <17.02.2017> for <EHP8>
*SELECT SINGLE casenr status FROM emma_case
*INTO CORRESPONDING FIELDS OF ls_case
*WHERE ccat        EQ clarifcasecategory
*  AND mainobjtype EQ primaryobjecttype
*  AND mainobjkey  EQ object-key-switchnum.
SELECT casenr status FROM emma_case
INTO CORRESPONDING FIELDS OF ls_case
WHERE ccat        EQ clarifcasecategory
  AND mainobjtype EQ primaryobjecttype
  AND mainobjkey  EQ object-key-switchnum
ORDER BY PRIMARY KEY.
  EXIT.
ENDSELECT.
* AUCT-UPGRADE -  End of Modification by <USER> on <17.02.2017> for <EHP8>
CHECK sy-subrc IS INITIAL.
* only continue if a case was created
CHECK ls_case-status  EQ 1 "New
   OR ls_case-status  EQ 2. "In Process
* only continue if a case has status New or In Process
CALL FUNCTION 'BAPI_EMMA_CASE_COMPLETE'
  EXPORTING
    case      = ls_case-casenr
    processor = sy-uname
  TABLES
    return    = lt_ret.

READ TABLE lt_ret TRANSPORTING NO FIELDS
WITH KEY type = 'E'.
IF sy-subrc IS INITIAL.
  exit_return 1006 cl_emma_case=>co_bor_object ls_case-casenr
                   space space.
  RETURN.
ENDIF.

CLEAR: lt_ret.
CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
  EXPORTING
    wait   = abap_true
  IMPORTING
    return = ls_ret.

IF ls_ret-type = 'E'.
  exit_return 1006 cl_emma_case=>co_bor_object ls_case-casenr
                   space space.
ENDIF.

end_method.

begin_method showswitchdocforpod changing container.
DATA:
  pointofdeliveryid TYPE euitrans-ext_ui,
  lv_int_ui         TYPE int_ui,
  lv_switchnum      TYPE eideswtdoc-switchnum,
  lv_messtext       TYPE bapi_msg.


swc_get_element container 'PointOfDeliveryID' pointofdeliveryid.

* AUCT-UPGRADE -  Begin of Modification by <USER> on <17.02.2017> for <EHP8>
*SELECT SINGLE int_ui
*       INTO lv_int_ui
*       FROM euitrans
*      WHERE ext_ui    = pointofdeliveryid
*        AND dateto   >= sy-datum
*        AND datefrom <= sy-datum.
SELECT int_ui
       INTO lv_int_ui
       FROM euitrans
      WHERE ext_ui    = pointofdeliveryid
        AND dateto   >= sy-datum
        AND datefrom <= sy-datum
ORDER BY PRIMARY KEY.
  EXIT.
ENDSELECT.
* AUCT-UPGRADE -  End of Modification by <USER> on <17.02.2017> for <EHP8>
* popup to select switchdoc
CALL METHOD cl_isu_ide_switchdoc=>s_popup_get_switchnum
  EXPORTING
    x_pod           = lv_int_ui
  IMPORTING
    y_switchnum     = lv_switchnum
  EXCEPTIONS
    not_found       = 1
    general_fault   = 2
    parameter_error = 3
    OTHERS          = 4.

IF sy-subrc = 1.
*   real error message returned in parameter error
  exit_return '1058' pointofdeliveryid sy-datum space space.
ELSEIF sy-subrc <> 0.
*   real error message returned in parameter error
  exit_return '1001' 'SHOWSWITCHDOC' space space space.
ENDIF.

IF ( lv_switchnum IS NOT INITIAL ).
  CALL METHOD cl_isu_ide_switchdoc=>s_display
    EXPORTING
      x_switchnum    = lv_switchnum
    EXCEPTIONS
      not_found      = 1
      general_fault  = 2
      not_authorized = 3
      OTHERS         = 4.
  IF sy-subrc = 3.
    CONCATENATE TEXT-s00 lv_switchnum
           INTO lv_messtext
           SEPARATED BY space.
    exit_return 1000 lv_messtext TEXT-n00 space space.
  ELSEIF sy-subrc <> 0.
*     real error message returned in parameter error
    exit_return '1001' 'SHOWSWITCHDOCFORPOD' space space space.
  ENDIF.
ENDIF.

end_method.

begin_method b2b_is_active changing container.
DATA:
  y_b2b_is_active TYPE abap_bool.

"Get current B2B active status
y_b2b_is_active = zcl_apf_super=>b2b_is_active.

"Return the value
swc_set_element container 'Y_B2B_IS_ACTIVE' y_b2b_is_active.
end_method.

begin_method gettimes changing container.
DATA:
  processingdate  LIKE eide_swtdate-swtdate,
  keydate         LIKE eide_swtdate-swtdate,
  swtdates        LIKE eideswttimedate,
  moveindelay     LIKE eideswtdoc-moveindate,
  moveindelaytime TYPE eideswtmdprocstatustime,
  l_loopcounter   LIKE mgv_lamascrlayo1-counter,
  l_switchtype    LIKE eideswtdoc-switchtype,
  l_extrasignal   LIKE tfkenh-activ,
  l_result        TYPE sysubrc,
  lr_ca_obj       TYPE REF TO zcl_cash_advance,
  lr_cx_root      TYPE REF TO cx_root.

swc_get_element container 'ProcessingDate' processingdate.
swc_get_element container 'KeyDate' keydate.
swc_get_element container 'ExtraSignal' l_extrasignal.
swc_get_element container 'ShiftLoopCounter' l_loopcounter.

swc_get_property self 'SwitchType' l_switchtype.

* Debug capabillity
z_utility=>breakpoint_wf( 'ZISUSWITCHD-GETTIMES' ).

IF processingdate IS INITIAL.
  processingdate = sy-datum.
ENDIF.

* Add 1 day when Switch out, Move out or End of Supply
IF l_switchtype = '73' OR l_switchtype = '76' OR l_switchtype = '78'.
  IF keydate IS INITIAL.
    swc_get_property self 'MoveOutDate' keydate.
  ENDIF.
  keydate = keydate + 1.
ELSEIF l_switchtype EQ '72' OR l_switchtype EQ '77'.
  IF keydate IS INITIAL.
    swc_get_property self 'MoveInDate' keydate.
  ENDIF.
ENDIF.

* We call our own static method because the
* time framework gets locked and will fail consequently.
zcl_switchdoc=>get_times_static(
  EXPORTING
    x_keydate          = keydate
    x_procdate         = processingdate
    x_swttype          = l_switchtype
  CHANGING
    xy_eideswttimedate = swtdates
    xy_result          = l_result
).

IF l_result EQ 1
OR swtdates IS INITIAL.
* Fristenart &1 zur Wechselart &2 kann nicht ermittelt werden
  exit_return '1002' sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
ELSEIF l_result EQ 2.
* Das angeforderte Objekt ist momentan gesperrt durch User &
  exit_return '1010' sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
ELSE.
  "Export the dates
  swc_set_element container 'SWTDates' swtdates.

  "Check if this is the second or higher loop and if it is
  "then set the move in delay date (our new check date).
  "Otherwise use the time period date
  IF l_loopcounter LE 1.
    "This is the current check date
    moveindelay = swtdates-zverstindien.
  ELSE.
    IF l_switchtype EQ '77'.
      "When shifting the move in moveindate it is not
      "a calenderday behind the check date. Therefore
      "we add a calendar day here.
      moveindelay = swtdates-zverstindien + 1.
    ELSE.
      moveindelay = swtdates-zverstindien.
    ENDIF.
    "Has the moveindate changed?
    IF l_extrasignal EQ 'X'.
      "This date may not be today
      IF moveindelay LE sy-datum.
        moveindelay = moveindelay + 1.
      ENDIF.
    ENDIF.
  ENDIF.

  "Now we MUST be sure that the check date (move in delay date) will
  "be a trading day according to EDSN calendar. This calendar has
  "been incorporated into the NL calendar.
  TRY.
      lr_ca_obj      ?= zcl_apf_super=>get_instance( if_class_name = 'ZCL_CASH_ADVANCE' ).
      moveindelay     = lr_ca_obj->get_next_workday( x_date = moveindelay x_workdays_to_add = 0 ).
      moveindelaytime = lr_ca_obj->prv_move_in_delay_t.
    CATCH cx_root INTO lr_cx_root ##catch_all ##no_handler.
  ENDTRY.
  IF lr_ca_obj IS BOUND.
    zcl_apf_super=>delete_instance( lr_ca_obj ).
    FREE lr_ca_obj.
  ENDIF.

  "We force the time to be 16:00 hours (if not found)
  "and if we are NOT the first time we pass this in the loop
  IF l_loopcounter LE 1.
    "Overwrite standard time with current time
    GET TIME.
    moveindelaytime = sy-uzeit.
  ELSEIF moveindelaytime IS INITIAL.
    moveindelaytime = '160000'.
  ENDIF.

  "Return the move in delay date and time result
  swc_set_element container 'MoveInDelayDate' moveindelay.
  swc_set_element container 'MoveInDelayTime' moveindelaytime.
ENDIF.
end_method.

begin_method check_idoc_sent changing container.
DATA:
  dataexchangetask TYPE edextask-dextaskid,
  createdon        TYPE edidc-credat,
  sent             TYPE edextaskidoc-sent.

swc_get_element container 'DataExchangeTask' dataexchangetask.


SELECT SINGLE b~sent c~credat INTO (sent, createdon)
       FROM edextask AS a
    INNER JOIN edextaskidoc AS b
     ON a~dextaskid = b~dextaskid
   INNER JOIN edidc       AS c
     ON b~docnum = c~docnum
   WHERE a~dextaskid  = dataexchangetask AND
         ( b~sent = '2' OR
           b~sent = '4' ).


swc_set_element container 'CreatedOn' createdon.
swc_set_element container 'Sent' sent.
end_method.

begin_method wait5min changing container.

WAIT UP TO 300 SECONDS.

end_method.

begin_method adddaystodate changing container.
DATA:
  date   TYPE eabl-adatsoll,
  days   TYPE per_days-day_per,
  result TYPE eabl-adatsoll.
swc_get_element container 'Date' date.
swc_get_element container 'Days' days.

result = date + days.

swc_set_element container 'Result' result.

end_method.

begin_method releasecontractlock changing container.
DATA:
  lo_datum   TYPE datum,
  lo_isu_obj TYPE REF TO zcl_isu_objects.

"Test
z_utility=>breakpoint_wf( 'RELEASECONTRACTLOCK' ).

"Keydate
lo_datum = zcl_switchdoc=>get_keydate( if_switchnum = object-key-switchnum ).

"Contract lock remove (if any)
lo_isu_obj ?= zcl_apf_super=>get_instance( 'ZCL_ISU_OBJECTS' ).
lo_isu_obj->handle_contract_lock(
  EXPORTING
    x_switch_doc = object-key-switchnum
    x_date       = lo_datum
    x_lock       = space "No lock
).

"Release
zcl_apf_super=>delete_instance( lo_isu_obj ).
FREE lo_isu_obj.

end_method.

begin_method zwait4unlock changing container.
DATA:
  isunlocked TYPE syst-subrc,
  lo_isu_obj TYPE REF TO zcl_isu_objects.

"Helper
lo_isu_obj ?= zcl_apf_super=>get_instance( 'ZCL_ISU_OBJECTS' ).

"Lock check (maximum for 10 minutes)
isunlocked = lo_isu_obj->is_swtdoc_locked( object-key-switchnum ).

"Return signal
swc_set_element container 'IsUnlocked' isunlocked.

"Release
zcl_apf_super=>delete_instance( lo_isu_obj ).
FREE lo_isu_obj.

end_method.

begin_method nooperation changing container.
end_method.

begin_method zcreate_profile changing container.

DATA:
  lc_prof TYPE REF TO zcl_isu_edm_create_profile,
  ls_data TYPE zisu_profile.

z_utility=>breakpoint_wf( 'ZISUSWITCHD-ZCREATE_PROFILE' ).

"Only for B2B
IF zcl_apf_super=>b2b_is_active EQ abap_true.
  lc_prof ?= zcl_apf_super=>get_instance( 'ZCL_ISU_EDM_CREATE_PROFILE' ).

  swc_get_element container 'INSTALLATION' ls_data-anlage.

  CALL METHOD lc_prof->initialize
    EXPORTING
      if_program = sy-repid.

  TRY.
      CALL METHOD lc_prof->set_data
        CHANGING
          cf_data = ls_data.
    CATCH zcx_apf_set_data_failed .
  ENDTRY.

  CALL METHOD lc_prof->start( ).

  TRY.
      CALL METHOD lc_prof->get_data
        CHANGING
          cf_data = ls_data.
    CATCH zcx_apf_get_data_failed .
  ENDTRY.

  swc_set_element container 'ASSIGNED' ls_data-assigned.
  swc_set_element container 'PROFILE'  ls_data-profile.
ENDIF.
end_method.

begin_method zmtrreaddocuploadb2b changing container.
DATA: ext_ui  LIKE eideswtmsgdata-ext_ui,
      service LIKE eservprov-service,
      reason  TYPE  ablesgr,
      keydate LIKE syst-datum,
      msgdata LIKE eideswtmsgdata.

z_utility=>breakpoint_wf( 'ZMTRREADDOC_UPLOAD' ).

"Only for B2B
IF zcl_apf_super=>b2b_is_active EQ abap_true.
  swc_get_element container 'EXT_UI' ext_ui.
  swc_get_element container 'SERVICE' service.
  swc_get_element container 'REASON' reason.
  swc_get_element container 'MSGDATA' msgdata.
  swc_get_element container 'KEYDATE' keydate.

  CALL FUNCTION 'ZMTRREADDOC_UPLOAD_B2B_EVENT'
    EXPORTING
      x_ext_ui          = ext_ui
      x_date            = keydate
      x_service         = service
      x_reason          = reason
      x_msgdata         = msgdata
      x_switchnum       = object-key-switchnum
    EXCEPTIONS
      no_meter_found    = 01
      inconsistent_data = 02
      mr_upload_error   = 03
      device_mismatch   = 04
      OTHERS            = 05.
  CASE sy-subrc.
    WHEN 0.            " OK
    WHEN 01.    " to be implemented
      exit_return 1001 space space space space.
    WHEN 02.    " to be implemented
      exit_return 1002 space space space space.
    WHEN 03.    " to be implemented
      exit_return 1003 space space space space.
    WHEN 04.
      exit_return 1004 msgdata-zzmeterno space space space.
    WHEN OTHERS.       " to be implemented
  ENDCASE.
ENDIF.
end_method.

begin_method addworkdaytomoveindate changing container.
DATA:
  keydate        LIKE eide_swtdate-swtdate,
  keydatenew     LIKE eide_swtdate-swtdate,
  keydatechanged LIKE tfkenh-activ VALUE IS INITIAL,
  l_switchtype   LIKE eideswtdoc-switchtype,
  lr_switchdoc   TYPE REF TO zcl_switchdoc.

"Get details
swc_get_element container 'KeyDate' keydate.
swc_get_property self 'SwitchType' l_switchtype.

* Debug capabillity
z_utility=>breakpoint_wf( 'ZISUSWITCHD-ADDWORKDAYTOMOVEINDATE' ).

"Process only allowed for In switch and Move in
IF l_switchtype NE '72' AND l_switchtype NE '77'.
  "Return non changed details
  swc_set_element container 'KeyDateNew' keydate.
  swc_set_element container 'KeyDateChanged' keydatechanged.
ELSE.
  "Open switchdocument (workflow version)
  zcl_switchdoc=>createinstance(
    EXPORTING
      x_switchnum = object-key-switchnum
    IMPORTING
      y_switchdoc = lr_switchdoc
  ).
  "Set and get the new move in date (on switch document)
  "This will modify the move in date for the entire switchdocument
  lr_switchdoc->shift_move_in_date(
    EXPORTING
      x_switchnum  = object-key-switchnum
      x_moveindate = keydate
    IMPORTING
      y_moveindate = keydatenew
  ).
  FREE lr_switchdoc.

  "Changed?
  IF keydate NE keydatenew.
    keydatechanged = abap_true.
  ELSE.
    CLEAR keydatechanged.
  ENDIF.

  "Set new values
  swc_set_element container 'KeyDateNew' keydatenew.
  swc_set_element container 'KeyDateChanged' keydatechanged.

ENDIF.
end_method.

begin_method syncmoveindates changing container.
DATA:
  keydate        LIKE eide_swtdate-swtdate,
  keydatenew     LIKE eide_swtdate-swtdate,
  keydatechanged LIKE tfkenh-activ,
  l_loopcounter  LIKE mgv_lamascrlayo1-counter,
  l_switchtype   LIKE eideswtdoc-switchtype,
  lr_handle      TYPE REF TO cl_isu_ide_switch_times.

"Import container details
swc_get_element container 'KeyDate' keydate.
swc_get_element container 'KeyDateNew' keydatenew.
swc_get_element container 'KeyDateChanged' keydatechanged.
swc_get_element container 'ShiftLoopCounter' l_loopcounter.

* Debug capabillity
z_utility=>breakpoint_wf( 'ZISUSWITCHD-SYNCMOVEINDATES' ).

"Import object specific details
swc_get_property self 'SwitchType' l_switchtype.

"If keydate is not filled use direct value
IF keydate IS INITIAL.
  swc_get_property self 'MoveInDate' keydate.
ENDIF.

"Set the new key date if it was not set
"The new key date is set in method AddWorkdayToMoveInDate
"what only happens within the loop (1st time empty).
IF keydatenew IS INITIAL.
  keydatenew  = keydate.
  CLEAR keydatechanged.
ENDIF.

"Set next loop (required for correct wait processing)
ADD 1 TO l_loopcounter.

"Process only allowed for In switch and Move in
IF l_switchtype EQ '72' OR l_switchtype EQ '77'.
  "Onlky set new values if something has changed
  IF keydatechanged IS INITIAL.
    "Set old values
    swc_set_element container 'KeyDate' keydate.
    swc_set_element container 'KeyDateNew' keydate.
    swc_set_element container 'KeyDateChanged' keydatechanged.
    swc_set_element container 'ShiftLoopCounter' l_loopcounter.
  ELSE.
    "Set new values
    swc_set_element container 'KeyDate' keydatenew.
    swc_set_element container 'KeyDateNew' keydatenew.
    swc_set_element container 'KeyDateChanged' keydatechanged.
    swc_set_element container 'ShiftLoopCounter' l_loopcounter.
  ENDIF.
*Process only required if keydate has changed
ELSE.
  "Set old values
  CLEAR keydatechanged.
  swc_set_element container 'KeyDate' keydate.
  swc_set_element container 'KeyDateNew' keydate.
  swc_set_element container 'KeyDateChanged' keydatechanged.
  swc_set_element container 'ShiftLoopCounter' l_loopcounter.
ENDIF.

end_method.


begin_method queuelogstart changing container.

* processing
z_utility=>breakpoint_wf( 'ZISUSWITCHD-PROCES_QUEUE_LOG' ).

* local data declaration
DATA: ls_queuelog LIKE zwf_queue_log.
DATA: lr_queue    TYPE REF TO zcl_queue_log.

"Only for B2B
IF zcl_apf_super=>b2b_is_active EQ abap_true.
* get data from wf container
  swc_get_element container 'X_VKONT'     ls_queuelog-vkont.
  swc_get_element container 'X_SWITCHNUM' ls_queuelog-switchnum.
  swc_get_element container 'X_ABWVK'     ls_queuelog-abwvk.
  swc_get_element container 'X_STARTED'   ls_queuelog-started.

* Process via queue
  lr_queue ?= zcl_apf_super=>get_instance( 'ZCL_QUEUE_LOG' ).

  CALL METHOD lr_queue->initialize
    EXPORTING
      if_program = sy-repid.

  TRY.
      CALL METHOD lr_queue->set_data
        CHANGING
          cf_data = ls_queuelog.
    CATCH zcx_apf_set_data_failed .
  ENDTRY.

  CALL METHOD lr_queue->start( ).

  TRY.
      CALL METHOD lr_queue->get_data
        CHANGING
          cf_data = ls_queuelog.
    CATCH zcx_apf_get_data_failed .
  ENDTRY.
ENDIF.
end_method.

begin_method queuelogend changing container.

z_utility=>breakpoint_wf( 'ZISUSWITCHD-PROCES_QUEUE_LOG' ).

DATA: ls_queuelog LIKE zwf_queue_log.
DATA: lr_queue    TYPE REF TO zcl_queue_log_v01.
DATA: lv_updated  TYPE boolean.

"Only for B2B
IF zcl_apf_super=>b2b_is_active EQ abap_true.
* get data from wf container
  swc_get_element container 'X_ABWVK'     ls_queuelog-abwvk.
  swc_get_element container 'X_VKONT'     ls_queuelog-vkont.
  swc_get_element container 'X_SWITCHNUM' ls_queuelog-switchnum.
  swc_get_element container 'X_STARTED'   ls_queuelog-started.
  swc_get_element container 'X_STOPPED'   ls_queuelog-stopped.

  IF lr_queue IS INITIAL.
    CREATE OBJECT lr_queue.
  ENDIF.

  CALL METHOD lr_queue->set_process_status
    IMPORTING
      y_updated    = lv_updated
    CHANGING
      xy_queue_log = ls_queuelog.
ENDIF.
end_method.

begin_method queuestartwait changing container.
DATA:
  x_abwvk     TYPE zwf_queue_log-abwvk,
  x_vkont     TYPE zwf_queue_log-vkont,
  x_switchnum TYPE zwf_queue_log-switchnum,
  x_started   TYPE zwf_queue_log-started,
  x_stopped   TYPE zwf_queue_log-stopped,
  y_started   TYPE zwf_queue_log-started.

"Only for B2B
IF zcl_apf_super=>b2b_is_active EQ abap_true.
  swc_get_element container 'X_ABWVK' x_abwvk.
  swc_get_element container 'X_VKONT' x_vkont.
  swc_get_element container 'X_SWITCHNUM' x_switchnum.
  swc_get_element container 'X_STARTED' x_started.
  swc_get_element container 'X_STOPPED' x_stopped.

  z_utility=>breakpoint_wf( 'ZISUSWITCHD-PROCES_QUEUE_WAIT' ).

*  processing via abap step
  CALL FUNCTION 'ZFM_WS_B2B_PROCES_START'
    EXPORTING
      x_vkont     = x_vkont
      x_abwvk     = x_abwvk
      x_switchnum = x_switchnum
      x_started   = x_started
      x_stopped   = x_stopped
    EXCEPTIONS
      OTHERS      = 01.
  CASE sy-subrc.
    WHEN 0.            " OK
      y_started = abap_true.
    WHEN OTHERS.       " to be implemented
  ENDCASE.
ENDIF.
end_method.

begin_method check_rate_category changing container.
DATA:
  x_switchnum        TYPE eideswtnum,
  x_crm_product      TYPE zmd_tariff_int-crm_product,
  x_crm_campaign     TYPE zmd_tariff_int-crm_campaign,
  x_duration         TYPE zmd_tariff_int-duration,
  x_reg_date_from    TYPE zmd_tariff_int-reg_date_from,
  x_reg_date_to      TYPE zmd_tariff_int-reg_date_to,
  x_movein_date_from TYPE zmd_tariff_int-movein_date_from,
  x_movein_date_to   TYPE zmd_tariff_int-movein_date_to,
  y_rate_cat         TYPE zmd_tariff_int-rate_cat,
  lv_zzcontract      TYPE zreallocvert.

swc_get_element container 'X_SWITCHNUM'         x_switchnum.
swc_get_element container 'X_CRM_PRODUCT'       x_crm_product.
swc_get_element container 'X_CRM_CAMPAIGN'      x_crm_campaign.
swc_get_element container 'X_DURATION'          x_duration.
swc_get_element container 'X_REG_DATE_FROM'     x_reg_date_from.
swc_get_element container 'X_REG_DATE_TO'       x_reg_date_to.
swc_get_element container 'X_MOVEIN_DATE_FROM'  x_movein_date_from.
swc_get_element container 'X_MOVEIN_DATE_TO'    x_movein_date_to.

z_utility=>breakpoint_wf( 'ZISUSWITCHD-CHECK_RATE_CATEGORY' ).

IF x_switchnum IS INITIAL.
  x_switchnum = object-key-switchnum.
ENDIF.

* check if re-allocated contract is filled on swdoc (ZZCONTRACT)
* if so: end of check
* if not: continue
SELECT SINGLE zzcontract
  FROM eideswtdoc
  INTO lv_zzcontract
 WHERE switchnum EQ x_switchnum.
IF lv_zzcontract IS NOT INITIAL.
* No check needed
  EXIT.
ENDIF.

* Get complete product data
IF x_crm_product   IS INITIAL
OR x_crm_campaign  IS INITIAL
OR x_duration      IS INITIAL.
  "From switchdocument
  SELECT SINGLE zzcrm_product zzmarketcampaign moveindate zzcontract_lngth
    FROM eideswtdoc
    INTO (x_crm_product, x_crm_campaign, x_movein_date_from, x_duration )
    WHERE switchnum EQ x_switchnum.
  "Sync dates
  x_movein_date_to = x_movein_date_from.
ENDIF.

SELECT rate_cat
  FROM zmd_tariff_int
  INTO y_rate_cat UP TO 1 ROWS
  WHERE crm_product      EQ x_crm_product
  AND   crm_campaign     EQ x_crm_campaign
  AND   duration         EQ x_duration
  AND   movein_date_from LE x_movein_date_from
  AND   movein_date_to   GE x_movein_date_to.
  EXIT.
ENDSELECT.
IF sy-subrc EQ 0.
  swc_set_element container 'Y_RATE_CAT' y_rate_cat.
ELSE.
  IF sy-langu EQ 'N'.
    exit_return 1001 'niet gevonden' space space space.
  ELSE.
    exit_return 1001 'not found' space space space.
  ENDIF.
ENDIF.
end_method.
