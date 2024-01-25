FUNCTION ZZALE_ROUTING_CREATE2.
*"--------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(TESTRUN) TYPE  BAPIFLAG DEFAULT SPACE
*"     VALUE(PROFILE) LIKE  BAPI1012_CONTROL_DATA-PROFILE OPTIONAL
*"     VALUE(BOMUSAGE) LIKE  BAPI1012_CONTROL_DATA-BOM_USAGE OPTIONAL
*"     VALUE(APPLICATION) LIKE  BAPI1012_CONTROL_DATA-APPLICATION
*"         OPTIONAL
*"     VALUE(OBJ_TYPE) LIKE  SERIAL-OBJ_TYPE DEFAULT 'ZCHGPOINT2'
*"     VALUE(SERIAL_ID) LIKE  SERIAL-CHNUM DEFAULT '0'
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
*"      RECEIVERS STRUCTURE  BDI_LOGSYS
*"      COMMUNICATION_DOCUMENTS STRUCTURE  SWOTOBJID OPTIONAL
*"      APPLICATION_OBJECTS STRUCTURE  SWOTOBJID OPTIONAL
*"  EXCEPTIONS
*"      ERROR_CREATING_IDOCS
*"--------------------------------------------------------------------
*----------------------------------------------------------------------*
*  this function module is generated                                   *
*          never change it manually, please!        12.04.2017         *
*----------------------------------------------------------------------*

  DATA: IDOC_CONTROL  LIKE BDICONTROL,
        IDOC_DATA     LIKE EDIDD      OCCURS 0 WITH HEADER LINE,
        IDOC_RECEIVER LIKE BDI_LOGSYS OCCURS 0 WITH HEADER LINE,
        IDOC_COMM     LIKE EDIDC      OCCURS 0 WITH HEADER LINE,
        SYST_INFO     LIKE SYST.


* create IDoc control-record                                           *
  IDOC_CONTROL-MESTYP = 'ZCHGPOINT2_CREATE'.
  IDOC_CONTROL-IDOCTP = 'ZCHGPOINT2_CREATE01'.
  IDOC_CONTROL-SERIAL = SY-DATUM.
  IDOC_CONTROL-SERIAL+8 = SY-UZEIT.

  IDOC_RECEIVER[] = RECEIVERS[].

*   call subroutine to create IDoc data-record                         *
    clear: syst_info, IDOC_DATA.
    REFRESH IDOC_DATA.
    PERFORM ZZIDOC_ROUTING_CREATE2
            TABLES
                TASK
                MATERIALTASKALLOCATION
                SEQUENCE
                OPERATION
                SUBOPERATION
                REFERENCEOPERATION
                WORKCENTERREFERENCE
                COMPONENTALLOCATION
                PRODUCTIONRESOURCE
                INSPCHARACTERISTIC
                TEXTALLOCATION
                TEXT
                IDOC_DATA
            USING
                TESTRUN
                PROFILE
                BOMUSAGE
                APPLICATION
                SYST_INFO
                .
    IF NOT SYST_INFO IS INITIAL.
      MESSAGE ID SYST_INFO-MSGID
            TYPE SYST_INFO-MSGTY
          NUMBER SYST_INFO-MSGNO
            WITH SYST_INFO-MSGV1 SYST_INFO-MSGV2
                 SYST_INFO-MSGV3 SYST_INFO-MSGV4
      RAISING ERROR_CREATING_IDOCS.
    ENDIF.

*   distribute idocs                                                   *
    CALL FUNCTION 'ALE_IDOCS_CREATE'
         EXPORTING
              IDOC_CONTROL                = IDOC_CONTROL
              OBJ_TYPE                    = OBJ_TYPE
              CHNUM                       = SERIAL_ID
         TABLES
              IDOC_DATA                   = IDOC_DATA
              RECEIVERS                   = IDOC_RECEIVER
*             CREATED_IDOCS               =                            *
              CREATED_IDOCS_ADDITIONAL    = IDOC_COMM
              APPLICATION_OBJECTS         = APPLICATION_OBJECTS
         EXCEPTIONS
              IDOC_INPUT_WAS_INCONSISTENT = 1
              OTHERS                      = 2
              .
    IF SY-SUBRC <> 0.
      MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
              WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4
      RAISING ERROR_CREATING_IDOCS.
    ENDIF.

    IF COMMUNICATION_DOCUMENTS IS REQUESTED.
      LOOP AT IDOC_COMM.
        CLEAR COMMUNICATION_DOCUMENTS.
        COMMUNICATION_DOCUMENTS-OBJTYPE  = 'IDOC'.
        COMMUNICATION_DOCUMENTS-OBJKEY   = IDOC_COMM-DOCNUM.
        COMMUNICATION_DOCUMENTS-LOGSYS   = IDOC_COMM-RCVPRN.
        COMMUNICATION_DOCUMENTS-DESCRIBE = SPACE.
        APPEND COMMUNICATION_DOCUMENTS.
      ENDLOOP.
    ENDIF.

* applications do commit work to trigger communications                *





ENDFUNCTION.


* subroutine creating IDoc data-record                                 *
form ZZIDOC_ROUTING_CREATE2
     tables
         TASK structure
           BAPI1012_TSK_C
         MATERIALTASKALLOCATION structure
           BAPI1012_MTK_C
         SEQUENCE structure
           BAPI1012_SEQ_C
         OPERATION structure
           BAPI1012_OPR_C
         SUBOPERATION structure
           BAPI1012_SUB_OPR_C
         REFERENCEOPERATION structure
           BAPI1012_REF_OPR_C
         WORKCENTERREFERENCE structure
           BAPI1012_WC_REF_OPR_C
         COMPONENTALLOCATION structure
           BAPI1012_COM_C
         PRODUCTIONRESOURCE structure
           BAPI1012_PRT_C
         INSPCHARACTERISTIC structure
           BAPI1012_CHA_C
         TEXTALLOCATION structure
           BAPI1012_TXT_HDR_C
         TEXT structure
           BAPI1012_TXT_C
         idoc_data structure edidd
     using
         TESTRUN like
           BAPIFLAG
         PROFILE like
           BAPI1012_CONTROL_DATA-PROFILE
         BOMUSAGE like
           BAPI1012_CONTROL_DATA-BOM_USAGE
         APPLICATION like
           BAPI1012_CONTROL_DATA-APPLICATION
         syst_info like syst
         ."#EC *

  data:  Z1ZCHGPOINT2_CREATE like Z1ZCHGPOINT2_CREATE.
  data:  E1BPFLAG like E1BPFLAG.
  data:  E1BP1012_TSK_C like E1BP1012_TSK_C.
  data:  E1BP1012_MTK_C like E1BP1012_MTK_C.
  data:  E1BP1012_SEQ_C like E1BP1012_SEQ_C.
  data:  E1BP1012_OPR_C like E1BP1012_OPR_C.
  data:  E1BP1012_SUB_OPR_C like E1BP1012_SUB_OPR_C.
  data:  E1BP1012_REF_OPR_C like E1BP1012_REF_OPR_C.
  data:  E1BP1012_WC_REF_OPR_C like E1BP1012_WC_REF_OPR_C.
  data:  E1BP1012_COM_C like E1BP1012_COM_C.
  data:  E1BP1012_PRT_C like E1BP1012_PRT_C.
  data:  E1BP1012_CHA_C like E1BP1012_CHA_C.
  data:  E1BP1012_TXT_HDR_C like E1BP1012_TXT_HDR_C.
  data:  E1BP1012_TXT_C like E1BP1012_TXT_C.

* go through all IDoc-segments                                         *

* for segment 'Z1ZCHGPOINT2_CREATE'                                    *
    clear: Z1ZCHGPOINT2_CREATE,
           idoc_data.
    move PROFILE
      to Z1ZCHGPOINT2_CREATE-PROFILE.
    move BOMUSAGE
      to Z1ZCHGPOINT2_CREATE-BOMUSAGE.
    move APPLICATION
      to Z1ZCHGPOINT2_CREATE-APPLICATION.
    idoc_data-sdata  = Z1ZCHGPOINT2_CREATE.
    idoc_data-segnam = 'Z1ZCHGPOINT2_CREATE'.
    append idoc_data.


*   for segment 'E1BPFLAG'                                             *
    clear: E1BPFLAG,
           idoc_data.
    move-corresponding TESTRUN
        to E1BPFLAG."#EC ENHOK
    if not E1BPFLAG is initial.
    idoc_data-sdata = E1BPFLAG.
    idoc_data-segnam = 'E1BPFLAG'.
    append idoc_data.
    endif.

*   for segment 'E1BP1012_TSK_C'                                       *
  loop at TASK
               .
    clear: E1BP1012_TSK_C,
           idoc_data.
    move-corresponding TASK
        to E1BP1012_TSK_C."#EC ENHOK
condense E1BP1012_TSK_C-LOT_SIZE_FROM.
condense E1BP1012_TSK_C-LOT_SIZE_TO.
    idoc_data-sdata = E1BP1012_TSK_C.
    idoc_data-segnam = 'E1BP1012_TSK_C'.
    append idoc_data.
  endloop.


*   for segment 'E1BP1012_MTK_C'                                       *
  loop at MATERIALTASKALLOCATION
               .
    clear: E1BP1012_MTK_C,
           idoc_data.
    move-corresponding MATERIALTASKALLOCATION
        to E1BP1012_MTK_C."#EC ENHOK
    idoc_data-sdata = E1BP1012_MTK_C.
    idoc_data-segnam = 'E1BP1012_MTK_C'.
    append idoc_data.
  endloop.


*   for segment 'E1BP1012_SEQ_C'                                       *
  loop at SEQUENCE
               .
    clear: E1BP1012_SEQ_C,
           idoc_data.
    move-corresponding SEQUENCE
        to E1BP1012_SEQ_C."#EC ENHOK
condense E1BP1012_SEQ_C-LOT_SZ_MIN.
condense E1BP1012_SEQ_C-LOT_SZ_MAX.
    idoc_data-sdata = E1BP1012_SEQ_C.
    idoc_data-segnam = 'E1BP1012_SEQ_C'.
    append idoc_data.
  endloop.


*   for segment 'E1BP1012_OPR_C'                                       *
  loop at OPERATION
               .
    clear: E1BP1012_OPR_C,
           idoc_data.
    move-corresponding OPERATION
        to E1BP1012_OPR_C."#EC ENHOK
condense E1BP1012_OPR_C-DENOMINATOR.
condense E1BP1012_OPR_C-NOMINATOR.
condense E1BP1012_OPR_C-BASE_QUANTITY.
condense E1BP1012_OPR_C-BREAK_TIME.
condense E1BP1012_OPR_C-STD_VALUE_01.
condense E1BP1012_OPR_C-STD_VALUE_02.
condense E1BP1012_OPR_C-STD_VALUE_03.
condense E1BP1012_OPR_C-STD_VALUE_04.
condense E1BP1012_OPR_C-STD_VALUE_05.
condense E1BP1012_OPR_C-STD_VALUE_06.
condense E1BP1012_OPR_C-NO_OF_TIME_TICKETS.
condense E1BP1012_OPR_C-NO_OF_EMPLOYEE.
condense E1BP1012_OPR_C-SCRAP_FACTOR.
condense E1BP1012_OPR_C-MIN_OVERLAP_TIME.
condense E1BP1012_OPR_C-MIN_SEND_AHEAD_QTY.
condense E1BP1012_OPR_C-MAX_NO_OF_SPLITS.
condense E1BP1012_OPR_C-MIN_PROCESSING_TIME.
condense E1BP1012_OPR_C-MAX_WAIT_TIME.
condense E1BP1012_OPR_C-REQUIRED_WAIT_TIME.
condense E1BP1012_OPR_C-STANDARD_QUEUE_TIME.
condense E1BP1012_OPR_C-MIN_QUEUE_TIME.
condense E1BP1012_OPR_C-STANDARD_MOVE_TIME.
condense E1BP1012_OPR_C-MIN_MOVE_TIME.
condense E1BP1012_OPR_C-PLND_DELRY.
condense E1BP1012_OPR_C-INFO_REC_NET_PRICE.
condense E1BP1012_OPR_C-PRICE_UNIT.
condense E1BP1012_OPR_C-USERFIELD_QUAN_04.
condense E1BP1012_OPR_C-USERFIELD_QUAN_05.
condense E1BP1012_OPR_C-USERFIELD_CURR_06.
condense E1BP1012_OPR_C-USERFIELD_CURR_07.
condense E1BP1012_OPR_C-TIME_FACTOR.
condense E1BP1012_OPR_C-QTY_BTW_TWO_INSPECTIONS.
    idoc_data-sdata = E1BP1012_OPR_C.
    idoc_data-segnam = 'E1BP1012_OPR_C'.
    append idoc_data.
  endloop.


*   for segment 'E1BP1012_SUB_OPR_C'                                   *
  loop at SUBOPERATION
               .
    clear: E1BP1012_SUB_OPR_C,
           idoc_data.
    move-corresponding SUBOPERATION
        to E1BP1012_SUB_OPR_C."#EC ENHOK
condense E1BP1012_SUB_OPR_C-DENOMINATOR.
condense E1BP1012_SUB_OPR_C-NOMINATOR.
condense E1BP1012_SUB_OPR_C-BASE_QUANTITY.
condense E1BP1012_SUB_OPR_C-BREAK_TIME.
condense E1BP1012_SUB_OPR_C-STD_VALUE_01.
condense E1BP1012_SUB_OPR_C-STD_VALUE_02.
condense E1BP1012_SUB_OPR_C-STD_VALUE_03.
condense E1BP1012_SUB_OPR_C-STD_VALUE_04.
condense E1BP1012_SUB_OPR_C-STD_VALUE_05.
condense E1BP1012_SUB_OPR_C-STD_VALUE_06.
condense E1BP1012_SUB_OPR_C-NO_OF_TIME_TICKETS.
condense E1BP1012_SUB_OPR_C-NO_OF_EMPLOYEE.
condense E1BP1012_SUB_OPR_C-SCRAP_FACTOR.
condense E1BP1012_SUB_OPR_C-OFFSET_START.
condense E1BP1012_SUB_OPR_C-OFFSET_END.
condense E1BP1012_SUB_OPR_C-PLND_DELRY.
condense E1BP1012_SUB_OPR_C-INFO_REC_NET_PRICE.
condense E1BP1012_SUB_OPR_C-PRICE_UNIT.
condense E1BP1012_SUB_OPR_C-USERFIELD_QUAN_04.
condense E1BP1012_SUB_OPR_C-USERFIELD_QUAN_05.
condense E1BP1012_SUB_OPR_C-USERFIELD_CURR_06.
condense E1BP1012_SUB_OPR_C-USERFIELD_CURR_07.
    idoc_data-sdata = E1BP1012_SUB_OPR_C.
    idoc_data-segnam = 'E1BP1012_SUB_OPR_C'.
    append idoc_data.
  endloop.


*   for segment 'E1BP1012_REF_OPR_C'                                   *
  loop at REFERENCEOPERATION
               .
    clear: E1BP1012_REF_OPR_C,
           idoc_data.
    move-corresponding REFERENCEOPERATION
        to E1BP1012_REF_OPR_C."#EC ENHOK
condense E1BP1012_REF_OPR_C-REFERENCED_ACTIVITY_INCREMENT.
    idoc_data-sdata = E1BP1012_REF_OPR_C.
    idoc_data-segnam = 'E1BP1012_REF_OPR_C'.
    append idoc_data.
  endloop.


*   for segment 'E1BP1012_WC_REF_OPR_C'                                *
  loop at WORKCENTERREFERENCE
               .
    clear: E1BP1012_WC_REF_OPR_C,
           idoc_data.
    move-corresponding WORKCENTERREFERENCE
        to E1BP1012_WC_REF_OPR_C."#EC ENHOK
condense E1BP1012_WC_REF_OPR_C-REFERENCED_ACTIVITY_INCREMENT.
    idoc_data-sdata = E1BP1012_WC_REF_OPR_C.
    idoc_data-segnam = 'E1BP1012_WC_REF_OPR_C'.
    append idoc_data.
  endloop.


*   for segment 'E1BP1012_COM_C'                                       *
  loop at COMPONENTALLOCATION
               .
    clear: E1BP1012_COM_C,
           idoc_data.
    move-corresponding COMPONENTALLOCATION
        to E1BP1012_COM_C."#EC ENHOK
condense E1BP1012_COM_C-CUTTING_MEASURE_1.
condense E1BP1012_COM_C-CUTTING_MEASURE_2.
condense E1BP1012_COM_C-CUTTING_MEASURE_3.
condense E1BP1012_COM_C-COMP_QTY.
    idoc_data-sdata = E1BP1012_COM_C.
    idoc_data-segnam = 'E1BP1012_COM_C'.
    append idoc_data.
  endloop.


*   for segment 'E1BP1012_PRT_C'                                       *
  loop at PRODUCTIONRESOURCE
               .
    clear: E1BP1012_PRT_C,
           idoc_data.
    move-corresponding PRODUCTIONRESOURCE
        to E1BP1012_PRT_C."#EC ENHOK
condense E1BP1012_PRT_C-START_OFFSET.
condense E1BP1012_PRT_C-END_OFFSET.
condense E1BP1012_PRT_C-STD_VALUE_FOR_PRT_QTY.
condense E1BP1012_PRT_C-STD_USAGE_VALUE_FOR_PRT.
    idoc_data-sdata = E1BP1012_PRT_C.
    idoc_data-segnam = 'E1BP1012_PRT_C'.
    append idoc_data.
  endloop.


*   for segment 'E1BP1012_CHA_C'                                       *
  loop at INSPCHARACTERISTIC
               .
    clear: E1BP1012_CHA_C,
           idoc_data.
    move-corresponding INSPCHARACTERISTIC
        to E1BP1012_CHA_C."#EC ENHOK
condense E1BP1012_CHA_C-DEC_PLACES.
condense E1BP1012_CHA_C-NO_OF_VALUE_CLASSES.
condense E1BP1012_CHA_C-SMPL_QUANT.
    idoc_data-sdata = E1BP1012_CHA_C.
    idoc_data-segnam = 'E1BP1012_CHA_C'.
    append idoc_data.
  endloop.


*   for segment 'E1BP1012_TXT_HDR_C'                                   *
  loop at TEXTALLOCATION
               .
    clear: E1BP1012_TXT_HDR_C,
           idoc_data.
    move-corresponding TEXTALLOCATION
        to E1BP1012_TXT_HDR_C."#EC ENHOK
    idoc_data-sdata = E1BP1012_TXT_HDR_C.
    idoc_data-segnam = 'E1BP1012_TXT_HDR_C'.
    append idoc_data.
  endloop.


*   for segment 'E1BP1012_TXT_C'                                       *
  loop at TEXT
               .
    clear: E1BP1012_TXT_C,
           idoc_data.
    move-corresponding TEXT
        to E1BP1012_TXT_C."#EC ENHOK
    idoc_data-sdata = E1BP1012_TXT_C.
    idoc_data-segnam = 'E1BP1012_TXT_C'.
    append idoc_data.
  endloop.


* end of through all IDoc-segments                                     *

endform.                               " ZZIDOC_ROUTING_CREATE2
