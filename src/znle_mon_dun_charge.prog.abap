*++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*
* CHANGE ID : HANA-001
*1.) ACC11346068
       bhardwaa                             cr0093193* 24.05.2017
* TR : S7HK900166
* DESCRIPTION: HANA CORRECTION
* TEAM : HANA-MIGRATION
*++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*
REPORT zfica_mon_dun_charge NO STANDARD PAGE HEADING
                     LINE-SIZE 150
                     LINE-COUNT 55.
************************************************************************
*PROGRAM        ZFICA_MON_DUN_CHARGE
*TITLE          ZFICA_MON_DUN_CHARGE
*AUTHOR         Jesper Marott Christensen, Marott Consult ApS
*DATE WRITTEN   2008-10-08
*RELEASE
*-----------------------------------------------------------------------
* Monitor on customer requests.
*-----------------------------------------------------------------------
*PROGRAM TYPE   REPORT
*DEV. CLASS     ZFICA
*-----------------------------------------------------------------------
*CHANGE HISTORY IN REVERSE ORDER
*
*
************************************************************************
       TYPE-POOLS: icon, bpc01.

       TABLES: dfkkop.

       TYPES: BEGIN OF z_line.
           INCLUDE STRUCTURE zfica_mon_dun_charge_scr.
       TYPES:           END OF z_line.
       CONSTANTS: c_line_structure TYPE dd02l-tabname
                                         VALUE 'ZFICA_MON_DUN_CHARGE_SCR'.

       DATA: gw_line TYPE z_line.
       DATA: gt_line TYPE TABLE OF z_line.
       FIELD-SYMBOLS: <line> TYPE z_line.

       TYPES: BEGIN OF z_data,
                opbel TYPE dfkkop-opbel,
                opupw TYPE dfkkop-opupw,
                opupk TYPE dfkkop-opupk,
                opupz TYPE dfkkop-opupz,
                bukrs TYPE dfkkop-bukrs,
                augst TYPE dfkkop-augst,
                bldat TYPE dfkkop-bldat,
                gpart TYPE dfkkop-gpart,
                vkont TYPE dfkkop-vkont,
                hvorg TYPE dfkkop-hvorg,
                tvorg TYPE dfkkop-tvorg,
                kofiz TYPE dfkkop-kofiz,
                faedn TYPE dfkkop-faedn,
                faeds TYPE dfkkop-faeds,
                betrw TYPE dfkkop-betrw,
                augdt TYPE dfkkop-augdt,
                augbl TYPE dfkkop-augbl,
                augbd TYPE dfkkop-augbd,
                augrd TYPE dfkkop-augrd,
              END OF z_data.

       DATA: gt_data TYPE STANDARD TABLE OF z_data.
       FIELD-SYMBOLS: <data> TYPE z_data.

       DATA: gt_tfk001at TYPE SORTED TABLE OF tfk001at WITH UNIQUE KEY augrd.
       FIELD-SYMBOLS: <tfk001at> TYPE tfk001at.

       TYPES: BEGIN OF z_account,
                vkont TYPE vkont_kk,
                betrw TYPE betrw_kk,
                waers TYPE waers,
              END OF z_account.

       DATA: gt_account TYPE STANDARD TABLE OF z_account,
             gw_account TYPE z_account.
       FIELD-SYMBOLS: <account> TYPE z_account.

       DATA: gw_cl_timetaker TYPE REF TO zcl_gui_timetaker.


       DATA: BEGIN OF gw_numbers,
               read  TYPE i,
               lines TYPE i,
             END OF  gw_numbers.

*----------- afv kontrol --------------------------------------------
       DATA: ok_code            LIKE sy-ucomm,
             g_container        TYPE scrfname VALUE 'MAIN_TABLE',
             grid1              TYPE REF TO cl_gui_alv_grid,
             g_variant          TYPE disvariant,
             g_custom_container TYPE REF TO cl_gui_custom_container,
             g_lvc_t_fcat       TYPE lvc_t_fcat,   " felter
             g_lvc_s_layo       TYPE lvc_s_layo.   " layout generel

       SELECTION-SCREEN BEGIN OF BLOCK scr1 WITH FRAME TITLE text-s01.
       SELECTION-SCREEN BEGIN OF BLOCK scr2 WITH FRAME TITLE text-s02.
       SELECT-OPTIONS: s_bldat FOR dfkkop-bldat OBLIGATORY.
       SELECT-OPTIONS: s_gpart FOR dfkkop-gpart.
       SELECT-OPTIONS: s_vkont FOR dfkkop-vkont.
       SELECT-OPTIONS: s_kofiz FOR dfkkop-kofiz.
       SELECT-OPTIONS: s_augrd FOR dfkkop-augrd.
       SELECT-OPTIONS: s_hvorg FOR dfkkop-hvorg DEFAULT '0010' .
       SELECT-OPTIONS: s_tvorg FOR dfkkop-tvorg DEFAULT '0020'.
       SELECT-OPTIONS: s_bukrs FOR dfkkop-bukrs DEFAULT '4040' .


       SELECTION-SCREEN:   SKIP.
       PARAMETERS: p_clear AS CHECKBOX DEFAULT 'X'.
       PARAMETERS: p_open  AS CHECKBOX DEFAULT 'X'.
       SELECTION-SCREEN END OF BLOCK scr2.

       SELECTION-SCREEN BEGIN OF BLOCK subbl04 WITH FRAME TITLE text-s14.
       PARAMETERS:        p_var    TYPE slis_vari.
       SELECTION-SCREEN END OF BLOCK subbl04.


*PARAMETERS: P_used AS CHECKBOX DEFAULT ' '.
*PARAMETERS: P_noused AS CHECKBOX DEFAULT 'X'.
       SELECTION-SCREEN BEGIN OF BLOCK scr3 WITH FRAME TITLE text-s03.
       SELECTION-SCREEN COMMENT /01(75) text-b01.
       SELECTION-SCREEN COMMENT /01(75) text-b02.
       SELECTION-SCREEN COMMENT /01(75) text-b03.
       SELECTION-SCREEN COMMENT /01(75) text-b04.
       SELECTION-SCREEN COMMENT /01(75) text-b05.
       SELECTION-SCREEN COMMENT /01(75) text-b06.
       SELECTION-SCREEN END OF BLOCK scr3.

       SELECTION-SCREEN END OF BLOCK scr1.

       .
*--At Selection-screen-------------------------------------------------*
       AT SELECTION-SCREEN.

       AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_var.

         DATA: lv_repid TYPE sy-repid.

         lv_repid = sy-repid.

         CALL FUNCTION 'Z_FICA_DC_F4_GET_LAYOUT'
           EXPORTING
             i_report = lv_repid
           IMPORTING
             e_layout = p_var.
         .


*--Initialization------------------------------------------------------*
       INITIALIZATION.


*--Start-Of-Selection--------------------------------------------------*
       START-OF-SELECTION.



         PERFORM main_proc.


*--End-Of-Selection----------------------------------------------------*
       END-OF-SELECTION.

         CALL SCREEN 100.

*--Top-Of-Page---------------------------------------------------------
       TOP-OF-PAGE.

*--At line-selection---------------------------------------------------*
       AT LINE-SELECTION.

*---------------------------------------------------------------------*
*       FORM MAIN_PROC                                                *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
       FORM main_proc.

         PERFORM init.

         PERFORM find_data.

         PERFORM behandl_data.
       ENDFORM.                    "MAIN_PROC

*---------------------------------------------------------------------*
*       FORM init                                                     *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
       FORM init.

         CLEAR: gt_line[], gt_data[], gw_numbers.

       ENDFORM.                    "INIT

*---------------------------------------------------------------------*
*       FORM find_EXT_pod                                             *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
       FORM find_data.

         CALL FUNCTION 'SAPGUI_PROGRESS_INDICATOR'
           EXPORTING
             text = text-002.

         PERFORM find_data_dfkkop. " USING '9'.

*  IF NOT p_open IS INITIAL.
*    PERFORM find_data_dfkkop USING ' '.
*  ENDIF.

         SELECT * FROM tfk001at INTO TABLE gt_tfk001at
         WHERE spras = sy-langu.


       ENDFORM.                    "find_data

*&--------------------------------------------------------------------*
*&      Form  find_data_dfkkop
*&--------------------------------------------------------------------*
*       text
*---------------------------------------------------------------------*
*      -->P_AUGST    text
*---------------------------------------------------------------------*
       FORM find_data_dfkkop. " USING p_augst.
         ranges: r_bldat for dfkkop-bldat.
         data: lv_date type d.


* Convert so data ranges, will be selection on each date in the range.
* It is to get the orackel optimizer to user index Z06!
         Loop at s_bldat.
           if  s_bldat-option = 'BT'
           AND s_bldat-sign   = 'I'.
             lv_date = s_bldat-low.
             do.
               r_bldat-sign   = 'I'.
               r_bldat-option = 'EQ'.
               r_bldat-low    = lv_date.
               r_bldat-high = ' '.
               append r_bldat.

               add 1 to lv_date.
               If lv_date > s_bldat-high.
                 exit.
               endif.
             enddo.

           else.
             append s_bldat to r_bldat.
           endif.


         endloop.



         SELECT           opbel
                          opupw
                          opupk
                          opupz
                          bukrs
                          augst
                          bldat
                          gpart
                          vkont
                          hvorg
                          tvorg
                          kofiz
                          faedn
                          faeds
                          betrw
                          augdt
                          augbl
                          augbd
                          augrd
        APPENDING TABLE gt_data
        FROM dfkkop
        WHERE bldat IN r_bldat
        AND   gpart IN s_gpart
        AND   vkont IN s_vkont
        AND   kofiz IN s_kofiz
        AND   augrd IN s_augrd
        AND   hvorg IN s_hvorg
        AND   tvorg IN s_tvorg
        AND   bukrs IN s_bukrs.
* AND augst = p_augst
* %_HINTS ORACLE 'index(dfkkop"Z01")'.

         ADD sy-dbcnt TO gw_numbers-read.


         if p_clear IS INITIAL.
           dELETE gt_data WHERE augst = '9'.
         ENDIF.
         if p_open IS INITIAL.
           dELETE gt_data WHERE augst = ' '.
         ENDIF.




       ENDFORM.                    "FIND_DATA


*---------------------------------------------------------------------*
*       FORM behandl_data                                             *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
       FORM behandl_data.
         DATA: lw_dfkkop TYPE dfkkop.

         CALL FUNCTION 'SAPGUI_PROGRESS_INDICATOR'
           EXPORTING
             text = text-004.


         CREATE OBJECT gw_cl_timetaker
           EXPORTING
             p_max      = gw_numbers-read
             p_interval = 500.

         LOOP AT gt_data ASSIGNING <data>.
           CLEAR: gw_line.

           CALL METHOD gw_cl_timetaker->sapgui_process_with_time
             EXPORTING
               p_text   = text-101
               p_number = sy-tabix.


           MOVE-CORRESPONDING <data> TO gw_line.


*   if account maintain, then use clearing docs clearing info.
           IF gw_line-augrd = '03'.
             DO 100 TIMES.
* AUCT-UPGRADE -  Begin of Modification by <USER> on <17.02.2017> for <EHP8>
*        SELECT SINGLE * FROM dfkkop INTO lw_dfkkop
*        WHERE opbel =  gw_line-augbl
*        AND hvorg = '0250'
*        AND augst = ' '.
               SELECT * UP TO 1 ROWS FROM dfkkop INTO lw_dfkkop
               WHERE opbel = gw_line-augbl
               AND hvorg = '0250'
               AND augst = ' '
               ORDER BY PRIMARY KEY.
               ENDSELECT.
* AUCT-UPGRADE -  End of Modification by <USER> on <17.02.2017> for <EHP8>
               IF sy-subrc = 0.
                 CLEAR: gw_line-augrd,
                        gw_line-augdt.
                 exit.
               ELSE.
* AUCT-UPGRADE -  Begin of Modification by <USER> on <17.02.2017> for <EHP8>
*          SELECT SINGLE * FROM dfkkop INTO lw_dfkkop
*          WHERE opbel =  gw_line-augbl
*          AND hvorg = '0250'
*          AND augst = '9'.
                 SELECT * UP TO 1 ROWS FROM dfkkop INTO lw_dfkkop
                 WHERE opbel = gw_line-augbl
                 AND hvorg = '0250'
                 AND augst = '9'
                 ORDER BY PRIMARY KEY.
                 ENDSELECT.
* AUCT-UPGRADE -  End of Modification by <USER> on <17.02.2017> for <EHP8>
                 IF sy-subrc = 0.
                   gw_line-augrd = lw_dfkkop-augrd.
                   gw_line-augbl = lw_dfkkop-augbl.
                   gw_line-augdt = lw_dfkkop-augdt.
                   IF gw_line-augrd NE '03'.
                     exit.
                   ENDIF.
                 else.
                   exit.
                 ENDIF.

               ENDIF.
             ENDDO.
           ENDIF.


           IF gw_line-augrd IS INITIAL.
             CHECK NOT p_open IS INITIAL.
           ELSE.
             CHECK NOT p_clear IS INITIAL.
           ENDIF.


           READ TABLE gt_tfk001at ASSIGNING <tfk001at>
           WITH KEY augrd = gw_line-augrd.
           IF sy-subrc = 0.
             gw_line-augrd_text = <tfk001at>-txt50.
           ENDIF.





           APPEND gw_line TO gt_line.
         ENDLOOP.

         FREE gt_data.

       ENDFORM.                    "BEHANDL_DATA



*---------------------------------------------------------------------*
*       FORM set_layout                                               *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
       FORM set_layout.
         DATA: l_lvc_s_fcat TYPE lvc_s_fcat.
         DATA: l_antal      TYPE i,
               lv_text1(30) TYPE c,
               lv_text2(30) TYPE c,
               lv_text3(30) TYPE c.
         FIELD-SYMBOLS: <fieldcat> TYPE lvc_s_fcat.


         CALL FUNCTION 'LVC_FIELDCATALOG_MERGE'
           EXPORTING
*            I_BUFFER_ACTIVE        =
             i_structure_name       = c_line_structure
*            I_CLIENT_NEVER_DISPLAY = 'X'
             i_bypassing_buffer     = 'X'
           CHANGING
             ct_fieldcat            = g_lvc_t_fcat
           EXCEPTIONS
             inconsistent_interface = 1
             program_error          = 2
             OTHERS                 = 3.
         IF sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
         ENDIF.

         LOOP AT g_lvc_t_fcat ASSIGNING <fieldcat>.
*    CASE <fieldcat>-fieldname.
*      WHEN 'PRODUCT_GUID'.
*        <fieldcat>-no_out = 'X'.
*    ENDCASE.
         ENDLOOP.



*  CLEAR L_LVC_S_FCAT.
*  L_LVC_S_FCAT-FIELDNAME = 'VKONT'.
*  L_LVC_S_FCAT-REPTEXT   = 'Aftalekonto'.
*  L_LVC_S_FCAT-COL_POS    = '102'.
*  APPEND L_LVC_S_FCAT  TO G_LVC_T_FCAT.


         DESCRIBE TABLE gt_line LINES gw_numbers-lines.
         WRITE gw_numbers-lines TO lv_text1.
         CONDENSE lv_text1.

         READ TABLE s_bldat INDEX 1.
         IF s_bldat-sign = 'I'
         AND s_bldat-option = 'BT'.
           WRITE s_bldat-low TO lv_text2.
           WRITE s_bldat-high TO lv_text3.
           CONCATENATE lv_text2 '-' lv_text3
           INTO lv_text2
           SEPARATED BY space.
         ENDIF.




         CONCATENATE text-200
                      lv_text1
                      text-201
                      lv_text2
                     INTO g_lvc_s_layo-grid_title
                     SEPARATED BY space.
*
         g_lvc_s_layo-cwidth_opt = 'X'.       " optimize
         g_lvc_s_layo-zebra = 'X'.
         g_lvc_s_layo-sel_mode = 'D'.
         g_lvc_s_layo-info_fname = 'LINECOLOUR'.


       ENDFORM.                    "SET_LAYOUT

***** GRID
**** callback kontrol
       CLASS lcl_event_receiver DEFINITION.
         PUBLIC SECTION.
           CLASS-METHODS:
             handle_double_click
                           FOR EVENT double_click OF cl_gui_alv_grid
               IMPORTING e_row e_column.
         PRIVATE SECTION.
       ENDCLASS.                    "LCL_EVENT_RECEIVER DEFINITION

*---------------------------------------------------------------------*
*       CLASS lcl_event_receiver IMPLEMENTATION
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
       CLASS lcl_event_receiver IMPLEMENTATION.
         METHOD handle_double_click.

           DATA: l_row       TYPE i,
                 l_value(30) TYPE c,
                 l_col       TYPE i.
           DATA: lv_tcode TYPE  sy-tcode,
                 lv_opbel TYPE  fkkko-opbel.


*  Vi får kontrol også ved selection af variant felter.
*  Vi bruger en høker metode til at undgå click-through.
           IF e_column-fieldname = 'SELTEXT'.
             EXIT.
           ENDIF.

           CALL METHOD grid1->get_current_cell
             IMPORTING
               e_row     = l_row
               e_value   = l_value
               e_col     = l_col
               es_row_id = e_row
               es_col_id = e_column.

           IF e_column-fieldname = 'GPART'.
             SET PARAMETER ID 'BPA' FIELD l_value.
             SET PARAMETER ID 'KTO' FIELD ' '.
             SET PARAMETER ID '8LT' FIELD 'ALL OPEN'.
             CALL TRANSACTION 'FPL9'.
           ENDIF.

           IF e_column-fieldname = 'VKONT'.
             SET PARAMETER ID 'BPA' FIELD ' '.
             SET PARAMETER ID 'KTO' FIELD l_value.
             SET PARAMETER ID '8LT' FIELD 'ALL OPEN'.


             CALL TRANSACTION 'FPL9' AND SKIP FIRST SCREEN.
           ENDIF.

           IF e_column-fieldname = 'OPBEL'
           OR e_column-fieldname = 'AUGBL'.



             CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
               EXPORTING
                 input  = l_value
               IMPORTING
                 output = lv_opbel.

             lv_tcode = 'FPE3'.

             CALL FUNCTION 'FKK_FPE0_START_TRANSACTION'
               EXPORTING
                 tcode              = lv_tcode
                 opbel              = lv_opbel
               EXCEPTIONS
                 document_not_found = 1
                 OTHERS             = 2.
             IF sy-subrc <> 0.
               MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                  WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
             ENDIF.

           ENDIF.


         ENDMETHOD.                    "HANDLE_DOUBLE_CLICK
       ENDCLASS.                    "LCL_EVENT_RECEIVER IMPLEMENTATION

*---------------------------------------------------------------------*
*       MODULE PBO OUTPUT                                             *
*---------------------------------------------------------------------*
       MODULE pbo_0100 OUTPUT.
         SET PF-STATUS 'MAIN100'.
         IF g_custom_container IS INITIAL.
           CALL FUNCTION 'SAPGUI_PROGRESS_INDICATOR'
             EXPORTING
               text = text-001.




           PERFORM set_layout.

           g_variant-report = sy-repid.
           g_variant-variant = p_var.


           CREATE OBJECT g_custom_container
             EXPORTING
               container_name = g_container.
           CREATE OBJECT grid1
             EXPORTING
               i_parent = g_custom_container.


           CALL METHOD grid1->set_table_for_first_display
             EXPORTING
               is_variant      = g_variant
               i_save          = 'A'
               i_default       = 'X'
*              I_STRUCTURE_NAME = 'ZCUST_RQ'
             CHANGING
               it_outtab       = gt_line
               it_fieldcatalog = g_lvc_t_fcat.

*CALL METHOD GRID1->GET_FRONTEND_FIELDCATALOG
*  importing
*    ET_FIELDCATALOG = G_LVC_T_FCAT.
*    .
*
*        perform modify_fieldcat.
*
*    CALL METHOD GRID1->SET_FRONTEND_FIELDCATALOG
*      EXPORTING
*        IT_FIELDCATALOG = G_LVC_T_FCAT.
*    .



           CALL METHOD grid1->set_frontend_layout
             EXPORTING
               is_layout = g_lvc_s_layo.

           CALL METHOD grid1->refresh_table_display.

           SET HANDLER lcl_event_receiver=>handle_double_click
                       FOR ALL INSTANCES.

         ENDIF.
       ENDMODULE.                    "PBO OUTPUT
*---------------------------------------------------------------------*
*       MODULE PAI INPUT                                              *
*---------------------------------------------------------------------*
       MODULE pai_0100 INPUT.

         PERFORM pai_form.

       ENDMODULE.                    "PAI INPUT


*&--------------------------------------------------------------------*
*&      Form  PAI_FORM
*&--------------------------------------------------------------------*
*       text
*---------------------------------------------------------------------*
       FORM pai_form.
         DATA: lt_rows TYPE lvc_t_row.
         DATA: l_rows TYPE lvc_s_row.
         DATA: l_antal TYPE i.
         DATA: l_is_stable TYPE lvc_s_stbl.
         DATA: l_return TYPE bapireturn1.
         DATA: l_activity TYPE bcont-activity.
*

*   to react on oi_custom_events:
         CALL METHOD cl_gui_cfw=>dispatch.
         CASE ok_code.
           WHEN 'EXIT' OR  'BACK' OR 'CANCEL'.
             PERFORM exit_program.
           WHEN 'REFRESH'.

             PERFORM main_proc.

             CALL METHOD grid1->refresh_table_display
               EXPORTING
                 is_stable      = l_is_stable
                 i_soft_refresh = 'X'.

           WHEN 'WRITEOFF'.

             CLEAR: l_antal,  lt_rows.

             CALL METHOD grid1->get_selected_rows
               IMPORTING
                 et_index_rows = lt_rows.

             IF lt_rows IS INITIAL.
*       First pick the request to process.
               MESSAGE e040(zfica_dong).
               EXIT.
             ENDIF.

             LOOP AT lt_rows INTO l_rows.
*        READ TABLE gt_line ASSIGNING <line> INDEX l_rows-index.
*
*        SET PARAMETER ID 'BPA' FIELD <line>-gpart.
*        SET PARAMETER ID 'KTO' FIELD <line>-vkont.
*        SET PARAMETER ID 'FWS' FIELD <line>-waers.
*        CALL TRANSACTION 'FP04' .


             ENDLOOP.
**     refresh
*      PERFORM main_proc.
*
             CALL METHOD grid1->refresh_table_display.

*      CALL METHOD grid1->refresh_table_display
*        EXPORTING
*          is_stable      = l_is_stable
*          i_soft_refresh = 'X'.

           WHEN 'MARK_0002'
             OR 'MARK_0003'.
             CLEAR: l_antal,  lt_rows.

             CALL METHOD grid1->get_selected_rows
               IMPORTING
                 et_index_rows = lt_rows.

             IF lt_rows IS INITIAL.
*       First pick the request to process.
               MESSAGE e040(zfica_dong).
               EXIT.
             ENDIF.

             LOOP AT lt_rows INTO l_rows.
               READ TABLE gt_line ASSIGNING <line> INDEX l_rows-index.

*        SET PARAMETER ID 'BPA' FIELD <line>-partner.



             ENDLOOP.
**     refresh
*      PERFORM main_proc.
*
             CALL METHOD grid1->refresh_table_display.


           WHEN OTHERS.



*     do nothing
         ENDCASE.
         CLEAR ok_code.
       ENDFORM.                    "PAI_FORM

*&---------------------------------------------------------------------*
*&      Form  modify_fieldcat
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
*FORM modify_fieldcat.
*field-symbols: <fieldcat> TYPE LVC_S_FCAT.
*
*loop at G_LVC_T_FCAT assigning <fieldcat>.
*   case <fieldcat>-fieldname.
*   when 'ART'.
*      <fieldcat>-edit = 'X'.
*      <fieldcat>-MARK = 'X'.
*   endcase.
*endloop.
*
*ENDFORM.                    " modify_fieldcat


*---------------------------------------------------------------------*
*       FORM EXIT_PROGRAM                                             *
*---------------------------------------------------------------------*
       FORM exit_program.
         CALL METHOD g_custom_container->free.
         CALL METHOD cl_gui_cfw=>flush.
*  leave program.
         LEAVE TO SCREEN 0.
       ENDFORM.                    "EXIT_PROGRAM
