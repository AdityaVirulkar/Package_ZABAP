************************************************************************
*                         Uptimizer 5.0 : ToolKit                      *
*          Copyright (C)  2008 by Intelligroup Inc. Consulting         *
************************************************************************
*    Sap  AG does not bear any responsibility for the functionality    *
*    provided by this product.                                         *
************************************************************************
*    NO PART of this program may be copied/reproduced or translated    *
*    into any other language by any form or means without the prior    *
*    written consent of Intelligroup Inc.                              *
************************************************************************
*++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*
* CHANGE ID : HANA-001
*1.) ACC11346068
       bhardwaa                             cr0093193* 24.05.2017
* TR : S7HK900166
* DESCRIPTION: HANA CORRECTION
* TEAM : HANA-MIGRATION
*++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*
REPORT  y2pdsec0
        MESSAGE-ID y2
        NO STANDARD PAGE HEADING.

*----------------------------------------------------------------------*
*   Declaration of Database Tables
*----------------------------------------------------------------------*
       TABLES: y2tseca0, tstc.

*----------------------------------------------------------------------*
*   Declaration of Data
*----------------------------------------------------------------------*

       DATA: i_tree LIKE snodetext OCCURS 0 WITH HEADER LINE.
       DATA: i_tree1 LIKE snodetext OCCURS 0 WITH HEADER LINE.
       DATA: v_hide LIKE snodetext-HIDE.
       DATA: BEGIN OF it_sec OCCURS 0,
               mandt     LIKE y2tseca0-mandt,
               ustyp     LIKE y2tseca0-ustyp,
               CLASS     LIKE y2tseca0-CLASS,
               bname     LIKE y2tseca0-bname,
               role      LIKE y2tseca0-role,
               profn     LIKE y2tseca0-profn,
               auth      LIKE y2tseca0-auth,
               objct     LIKE y2tseca0-objct,
               von       LIKE y2tust12-von,
               bis       LIKE y2tust12-bis,
               child_agr LIKE y2tseca0-child_agr,
               subprof   LIKE y2tseca0-subprof,
               P         TYPE C,
             END OF it_sec.

       DATA: BEGIN OF w_sec,
               mandt     LIKE y2tseca0-mandt,
               ustyp     LIKE y2tseca0-ustyp,
               CLASS     LIKE y2tseca0-CLASS,
               bname     LIKE y2tseca0-bname,
               role      LIKE y2tseca0-role,
               profn     LIKE y2tseca0-profn,
               auth      LIKE y2tseca0-auth,
               objct     LIKE y2tseca0-objct,
               von       LIKE y2tust12-von,
               bis       LIKE y2tust12-bis,
               child_agr LIKE y2tseca0-child_agr,
               subprof   LIKE y2tseca0-subprof,
               P         TYPE C,
             END OF w_sec.

       DATA: BEGIN OF it_sec1 OCCURS 0,
               mandt     LIKE y2tseca0-mandt,
               role      LIKE y2tseca0-role,
               profn     LIKE y2tseca0-profn,
               auth      LIKE y2tseca0-auth,
               objct     LIKE y2tseca0-objct,
               von       LIKE y2tust12-von,
               bis       LIKE y2tust12-bis,
               child_agr LIKE y2tseca0-child_agr,
               subprof   LIKE y2tseca0-subprof,
               P         TYPE C,
             END OF it_sec1.

       DATA: BEGIN OF w_sec1,
               mandt     LIKE y2tseca0-mandt,
               role      LIKE y2tseca0-role,
               profn     LIKE y2tseca0-profn,
               auth      LIKE y2tseca0-auth,
               objct     LIKE y2tseca0-objct,
               von       LIKE y2tust12-von,
               bis       LIKE y2tust12-bis,
               child_agr LIKE y2tseca0-child_agr,
               subprof   LIKE y2tseca0-subprof,
               P         TYPE C,
             END OF w_sec1.
       DATA: it_y2tcrel0 LIKE y2tcrel0 OCCURS 0 WITH HEADER LINE.
       DATA: v_comm LIKE SY-ucomm VALUE 'ROLES'.
       DATA: itab TYPE TABLE OF SY-ucomm.
       DATA: g_rep(6) TYPE C.
       DATA: BEGIN OF it_tcode OCCURS 0,
               tcd LIKE y2tusobxa-NAME,
             END OF it_tcode.
       RANGES: f FOR tstc-tcode.

       DATA: BEGIN OF it_users OCCURS 0,
               mandt LIKE y2tseca0-mandt,
               ustyp LIKE y2tseca0-ustyp,
               CLASS LIKE y2tseca0-CLASS,
               bname LIKE y2tseca0-bname,
             END OF it_users.

       DATA: w_users LIKE LINE OF it_users.

*SELECT-OPTIONS: S_TCODE FOR tstc-tcode.

       FIELD-SYMBOLS: <f>  LIKE w_sec, <f1> LIKE w_sec1.

*---------------------------------------------------------------------*
*   Start-of-selection
*---------------------------------------------------------------------*
       START-OF-SELECTION.

*---------------------------------------------------------------------*
*   Start-of-selection
*---------------------------------------------------------------------*
       END-OF-SELECTION.

         DO.

           CASE v_comm.

**Display users Tree
             WHEN 'USERS'.
               CLEAR v_comm.
               g_rep = 'USERS'.
               PERFORM get_data.
               PERFORM build_tree.
               FREE itab. APPEND 'USER' TO itab.
               APPEND 'USERS' TO itab.
               SET PF-STATUS 'TREE' EXCLUDING itab.
               PERFORM display_tree.

**Display roles Tree
             WHEN 'ROLES'.
               CLEAR v_comm.
               g_rep = 'ROLES'.
               PERFORM get_data1.
               PERFORM build_tree1.
               FREE itab. APPEND 'ROLES' TO itab.
               SET PF-STATUS 'TREE' EXCLUDING itab.
               PERFORM display_tree.

**EXIT
             WHEN OTHERS.
               EXIT.

           ENDCASE.

         ENDDO.

*&---------------------------------------------------------------------*
*&      S U B - R O U T I E N S
*&---------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*&      Form  GET_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
       FORM get_data.
         IF it_sec[] IS INITIAL.
           SELECT  y2tseca0~mandt
                   y2tseca0~ustyp
                   y2tseca0~CLASS
                   y2tseca0~bname
                   y2tseca0~role
                   y2tseca0~profn
                   y2tseca0~auth
                   y2tseca0~objct
                   y2tust12~von
                   y2tust12~bis
                   y2tseca0~child_agr
                   y2tseca0~subprof
           INTO TABLE it_sec
           FROM y2tseca0 INNER JOIN y2tust12
           ON y2tseca0~auth  = y2tust12~auth  AND
              y2tseca0~objct = y2tust12~objct AND
              y2tseca0~mandt = y2tust12~mandt CLIENT SPECIFIED.
           SORT it_sec BY mandt ustyp CLASS bname
           role profn auth von bis.
           FREE: it_sec1, i_tree.
         ENDIF.
         IF it_y2tcrel0[] IS INITIAL.
           SELECT * FROM y2tcrel0 CLIENT SPECIFIED INTO TABLE it_y2tcrel0.
         ENDIF.
       ENDFORM.                    " GET_DATA


*&---------------------------------------------------------------------*
*&      Form  BUILD_TREE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
       FORM build_tree .
         TABLES: t000, usgrpt, dd07t, agr_texts, usr11, usr13, tstct.
         DATA: i_r(2) TYPE N,
               i_p(2) TYPE N,
               i_a(2) TYPE N,
               i_v(2) TYPE N.
         DEFINE build_node.
           i_tree-TYPE = &1.
           i_tree-NAME = &2.
           i_tree-COLOR = &3.
           i_tree-TEXT = &4.
           i_tree-tlevel = &5.
           i_tree-tlength = &6.
           i_tree-tcolor = &7.
           i_tree-nlength = &8.
           i_tree-HIDE = v_hide.
           APPEND i_tree. CLEAR:  i_tree.
         END-OF-DEFINITION.
         v_hide = 1.
         build_node 'ROOT' 'Security Impacts' '3' '' '1' '60' '' '15'.
         LOOP AT it_sec ASSIGNING <f> WHERE P IS INITIAL .
           v_hide = SY-tabix.
           w_sec = <f>.
           <f>-P = 'X'.
           AT NEW mandt.
             SELECT SINGLE mtext FROM t000 INTO t000-mtext
             WHERE mandt = w_sec-mandt.
             build_node 'MANDT' w_sec-mandt '3' t000-mtext '2' '25' '' '3'.
           ENDAT.

           AT NEW ustyp.
* AUCT-UPGRADE -  Begin of Modification by <USER> on <17.02.2017> for <EHP8>
*      SELECT SINGLE DDTEXT FROM DD07T INTO DD07T-DDTEXT
*      WHERE DOMVALUE_L = W_SEC-USTYP AND DOMNAME = 'XUUSTYP'
*      AND AS4LOCAL = 'A' AND DDLANGUAGE = SY-LANGU.
             SELECT ddtext FROM dd07t INTO dd07t-ddtext
                   WHERE domvalue_l = w_sec-ustyp AND domname = 'XUUSTYP'
                   AND as4local = 'A' AND ddlanguage = SY-langu
             ORDER BY PRIMARY KEY.
               EXIT.
             ENDSELECT.
* AUCT-UPGRADE -  End of Modification by <USER> on <17.02.2017> for <EHP8>
             SPLIT dd07t-ddtext AT '(' INTO dd07t-ddtext t000-mtext.
             build_node 'USTYP' dd07t-ddtext '3' '' '3' '25' '' '20'.
           ENDAT.

           AT NEW CLASS.
             SELECT SINGLE TEXT FROM usgrpt CLIENT SPECIFIED INTO usgrpt-TEXT
             WHERE usergroup = w_sec-CLASS AND sprsl = SY-langu AND
             mandt = w_sec-mandt.
             build_node 'CLASS' w_sec-CLASS '3' usgrpt-TEXT '4' '60' '' '12'.
           ENDAT.

           AT NEW bname.
             build_node 'BNAME' w_sec-bname '3' '' '5' '25' '' '12'.
           ENDAT.

           AT NEW role.
             i_r = 6.
* AUCT-UPGRADE -  Begin of Modification by <USER> on <17.02.2017> for <EHP8>
*      SELECT SINGLE TEXT FROM AGR_TEXTS CLIENT SPECIFIED
*      INTO AGR_TEXTS-TEXT
*      WHERE MANDT = W_SEC-MANDT AND AGR_NAME = W_SEC-ROLE
*      AND SPRAS = SY-LANGU.
             SELECT TEXT FROM agr_texts CLIENT SPECIFIED
                   INTO agr_texts-TEXT
                   WHERE mandt = w_sec-mandt AND agr_name = w_sec-role
                   AND spras = SY-langu
             ORDER BY PRIMARY KEY.
               EXIT.
             ENDSELECT.
* AUCT-UPGRADE -  End of Modification by <USER> on <17.02.2017> for <EHP8>
             build_node 'ROLE' w_sec-role '9' agr_texts-TEXT i_r '60' '' '30'.
             IF w_sec-child_agr <> ' '.
               PERFORM add_roles USING i_r w_sec-role w_sec-mandt.
             ENDIF.
           ENDAT.

           AT NEW profn.
             i_p = i_r + 1.
             SELECT SINGLE ptext FROM usr11 CLIENT SPECIFIED
             INTO usr11-ptext WHERE mandt = w_sec-mandt AND
             profn = w_sec-profn AND aktps = 'A' AND
             langu = SY-langu.
             build_node 'PROF' w_sec-profn '7' usr11-ptext i_p '60' '' '30'.
             IF w_sec-subprof <> ' '.
               PERFORM add_profiles  USING i_p w_sec-profn w_sec-mandt.
             ENDIF.
           ENDAT.

           AT NEW auth.
             i_a = i_p + 1.
             SELECT SINGLE atext FROM usr13 CLIENT SPECIFIED
             INTO usr13-atext WHERE mandt = w_sec-mandt AND
             auth = w_sec-auth AND objct = w_sec-objct AND aktps = 'A' AND
             langu = SY-langu.
             build_node 'AUTH' w_sec-auth '4' usr13-atext i_a '60' '' '20'.
           ENDAT.
           i_v = i_a + 1.
           IF w_sec-bis = ' '.
             IF w_sec-von CA '*+'.
               CONCATENATE 'Range containing pattern'
               w_sec-von INTO tstct-ttext SEPARATED BY SPACE.
             ELSE.
               SELECT SINGLE ttext FROM tstct INTO tstct-ttext
               WHERE tcode  = w_sec-von AND sprsl = SY-langu.
             ENDIF.
             build_node 'VON' w_sec-von '4' tstct-ttext i_v '60' '' '20'.
           ELSE.
             CONCATENATE 'Range in between'  w_sec-von 'and' w_sec-bis
             INTO tstct-ttext SEPARATED BY SPACE.

             CONCATENATE '['  w_sec-von '] -> [' w_sec-bis ']'
             INTO usr13-atext.

             build_node 'VON' usr13-atext '4' tstct-ttext i_v '60' '' '20'.
           ENDIF.

         ENDLOOP.

       ENDFORM.                    " BUILD_TREE

*&---------------------------------------------------------------------*
*&      Form  ADD_ROLES
*&---------------------------------------------------------------------*
       FORM add_roles USING LEVEL role mandt.
         DATA: v_role  LIKE w_sec-role,
               v_mandt LIKE w_sec-mandt.
         v_role = role.
         v_mandt = mandt.
         LOOP AT it_y2tcrel0 WHERE name1 = v_role
                               AND mandt = v_mandt
                               AND TYPE  = 'R'.
           LEVEL = LEVEL + 1.
           CLEAR agr_texts-TEXT.
* AUCT-UPGRADE -  Begin of Modification by <USER> on <17.02.2017> for <EHP8>
*    SELECT SINGLE TEXT FROM AGR_TEXTS CLIENT SPECIFIED
*    INTO AGR_TEXTS-TEXT
*    WHERE MANDT = IT_Y2TCREL0-MANDT AND AGR_NAME = IT_Y2TCREL0-NAME0
*    AND SPRAS = SY-LANGU.
           SELECT TEXT FROM agr_texts CLIENT SPECIFIED
               INTO agr_texts-TEXT
               WHERE mandt = it_y2tcrel0-mandt AND agr_name = it_y2tcrel0-name0
               AND spras = SY-langu
           ORDER BY PRIMARY KEY.
             EXIT.
           ENDSELECT.
* AUCT-UPGRADE -  End of Modification by <USER> on <17.02.2017> for <EHP8>
           build_node 'ROLE' it_y2tcrel0-name0 '9'
           agr_texts-TEXT LEVEL '60' '' '30'.
           v_role = it_y2tcrel0-name0.
         ENDLOOP.
       ENDFORM.                    " ADD_ROLES

*&---------------------------------------------------------------------*
*&      Form  ADD_PROFILES
*&---------------------------------------------------------------------*
       FORM add_profiles USING LEVEL profn mandt.
         DATA: v_profile LIKE w_sec-profn,
               v_mandt   LIKE w_sec-mandt.
         v_profile = profn.
         v_mandt = mandt.
         LOOP AT it_y2tcrel0 WHERE name1 = v_profile
                               AND mandt = v_mandt
                               AND TYPE  = 'P'.
           LEVEL = LEVEL + 1.
           CLEAR usr11-ptext.
           SELECT SINGLE ptext FROM usr11 CLIENT SPECIFIED
           INTO usr11-ptext WHERE mandt = it_y2tcrel0-mandt AND
           profn = it_y2tcrel0-name0 AND aktps = 'A' AND
           langu = SY-langu.
           build_node 'PROF' it_y2tcrel0-name0 '7'
           usr11-ptext LEVEL '60' '' '30'.
           v_profile = it_y2tcrel0-name0.
         ENDLOOP.
       ENDFORM.                    " ADD_PROFILES

*&---------------------------------------------------------------------*
*&      Form  DISPLAY_TREE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
       FORM display_tree .
         DATA: v_repid TYPE SY-repid.
         v_repid = SY-repid.
         CALL FUNCTION 'RS_TREE_CONSTRUCT'
           TABLES
             nodetab            = i_tree
           EXCEPTIONS
             tree_failure       = 1
             id_not_found       = 2
             wrong_relationship = 3
             OTHERS             = 4.

         CALL FUNCTION 'RS_TREE_LIST_DISPLAY'
           EXPORTING
             callback_program      = v_repid
             callback_gui_status   = 'TREE'
             callback_user_command = 'USER_COMMAND'
           EXCEPTIONS
             OTHERS                = 1.
         FREE i_tree.
       ENDFORM.                    " DISPLAY_TREE
*&--------------------------------------------------------------------*
*&      Form  USER_COMMAND
*&--------------------------------------------------------------------*
       FORM user_command TABLES   NODE STRUCTURE seucomm
                                   USING     COMMAND
                                  CHANGING EXIT
                                           list_refresh.
         DATA: v_tabix LIKE SY-tabix.
         CASE COMMAND.
           WHEN 'USER'.
             CONDENSE: NODE-HIDE, NODE-TYPE.
             v_tabix = NODE-HIDE.
             CLEAR: list_refresh.

             FREE itab. APPEND 'ROLES' TO itab.
             APPEND 'USERS' TO itab.
             APPEND 'RIMP' TO itab.
             APPEND 'USER' TO itab.
             SET PF-STATUS 'TREE' EXCLUDING itab.
             PERFORM display_users USING NODE-NAME v_tabix NODE-TYPE.

           WHEN 'RIMP'.
             CONDENSE: NODE-HIDE, NODE-TYPE.
             v_tabix = NODE-HIDE.
             CLEAR: list_refresh.

             FREE itab. APPEND 'ROLES' TO itab.
             APPEND 'USERS' TO itab.
             APPEND 'RIMP' TO itab.
             APPEND 'USER' TO itab.
             SET PF-STATUS 'TREE' EXCLUDING itab.
             PERFORM display_impacts USING v_tabix NODE-TYPE.

           WHEN 'ROLES'.
             v_comm = 'ROLES'.
             EXIT = 'X'.

           WHEN 'USERS'.
             v_comm = 'USERS'.
             EXIT = 'X'.

         ENDCASE.
       ENDFORM.                    "USER_COMMAND
*&---------------------------------------------------------------------*
*&      Form  GET_DATA1
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
       FORM get_data1 .

         IF it_sec1[] IS INITIAL.
           IF it_sec[] IS INITIAL.
             SELECT  y2tseca0~mandt
                     y2tseca0~role
                     y2tseca0~profn
                     y2tseca0~auth
                     y2tseca0~objct
                     y2tust12~von
                     y2tust12~bis
                     y2tseca0~child_agr
                     y2tseca0~subprof
             INTO TABLE it_sec1
             FROM y2tseca0 INNER JOIN y2tust12
             ON y2tseca0~auth  = y2tust12~auth  AND
                y2tseca0~objct = y2tust12~objct AND
                y2tseca0~mandt = y2tust12~mandt CLIENT SPECIFIED.
             SORT it_sec1 BY mandt role profn auth von bis.
             DELETE ADJACENT DUPLICATES FROM it_sec1 COMPARING mandt
             role profn auth von bis child_agr subprof.

             LOOP AT it_sec1 ASSIGNING <f1>.
               IF <f1>-role IS INITIAL.
                 IF <f1>-subprof <> ' '.
                   <f1>-profn = <f1>-subprof.
                   <f1>-subprof = ' '.
                 ENDIF.
               ELSE.
                 IF <f1>-child_agr <> ' '.
                   <f1>-role = <f1>-child_agr.
                   <f1>-child_agr = ' '.
                 ENDIF.
               ENDIF.
             ENDLOOP.

           ELSE.

             SORT it_sec BY mandt role profn auth von bis.
             DELETE ADJACENT DUPLICATES FROM it_sec COMPARING mandt
             role profn auth von bis child_agr subprof.

             LOOP AT it_sec.
               CLEAR it_sec1.
               it_sec1-mandt = it_sec-mandt.
               it_sec1-auth = it_sec-auth.
               it_sec1-objct = it_sec-objct.
               it_sec1-von = it_sec-von.
               it_sec1-bis = it_sec-bis.
               IF it_sec-role IS INITIAL.
                 IF it_sec-subprof <> ' '.
                   it_sec1-profn = it_sec-subprof.
                   it_sec1-subprof = ' '.
                 ELSE.
                   it_sec1-profn = it_sec-profn.
                   it_sec1-subprof = it_sec-subprof.
                 ENDIF.
                 it_sec1-role = it_sec-role.
                 it_sec1-child_agr = it_sec-child_agr.
               ELSE.
                 IF it_sec-child_agr <> ' '.
                   it_sec1-role = it_sec-child_agr.
                   it_sec1-child_agr = ' '.
                 ELSE.
                   it_sec1-role = it_sec-role.
                   it_sec1-child_agr = it_sec-child_agr.
                 ENDIF.
                 it_sec1-profn = it_sec-profn.
                 it_sec1-subprof = it_sec-subprof.
               ENDIF.
               APPEND it_sec1.
             ENDLOOP.
           ENDIF.

           IF it_y2tcrel0[] IS INITIAL.
             SELECT * FROM y2tcrel0 CLIENT SPECIFIED INTO TABLE it_y2tcrel0.
           ENDIF.

           SORT it_sec1 BY mandt role profn auth von bis.
           DELETE ADJACENT DUPLICATES FROM it_sec1 COMPARING mandt
           role profn auth von bis.
           FREE: it_sec, i_tree.
         ENDIF.

       ENDFORM.                                                    " GET_DATA1
*&---------------------------------------------------------------------*
*&      Form  BUILD_TREE1
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
       FORM build_tree1 .
*  TABLES: T000, USGRPT, DD07T, AGR_TEXTS, USR11, USR13, TSTCT.
         DATA: i_r(2) TYPE N,
               i_p(2) TYPE N,
               i_a(2) TYPE N,
               i_v(2) TYPE N.
         DATA: w_sec LIKE w_sec1.
         FIELD-SYMBOLS <f> LIKE w_sec1.

         DEFINE build_node.
           i_tree-TYPE = &1.
           i_tree-NAME = &2.
           i_tree-COLOR = &3.
           i_tree-TEXT = &4.
           i_tree-tlevel = &5.
           i_tree-tlength = &6.
           i_tree-tcolor = &7.
           i_tree-nlength = &8.
           i_tree-HIDE = v_hide.
           APPEND i_tree. CLEAR:  i_tree.
         END-OF-DEFINITION.

         CHECK i_tree[] IS INITIAL.
         v_hide = 1.
         build_node 'ROOT' 'Security Impacts' '3' '' '1' '60' '' '15'.
         LOOP AT it_sec1 ASSIGNING <f> WHERE P IS INITIAL .
           v_hide = SY-tabix.
           w_sec = <f>.
           <f>-P = 'X'.
           AT NEW mandt.
             SELECT SINGLE mtext FROM t000 INTO t000-mtext
             WHERE mandt = w_sec-mandt.
             build_node 'MANDT' w_sec-mandt '3' t000-mtext '2' '25' '' '3'.
           ENDAT.

           AT NEW role.
             i_r = 3.
* AUCT-UPGRADE -  Begin of Modification by <USER> on <17.02.2017> for <EHP8>
*      SELECT SINGLE TEXT FROM AGR_TEXTS CLIENT SPECIFIED
*      INTO AGR_TEXTS-TEXT
*      WHERE MANDT = W_SEC-MANDT AND AGR_NAME = W_SEC-ROLE
*      AND SPRAS = SY-LANGU.
             SELECT TEXT FROM agr_texts CLIENT SPECIFIED
                   INTO agr_texts-TEXT
                   WHERE mandt = w_sec-mandt AND agr_name = w_sec-role
                   AND spras = SY-langu
             ORDER BY PRIMARY KEY.
               EXIT.
             ENDSELECT.
* AUCT-UPGRADE -  End of Modification by <USER> on <17.02.2017> for <EHP8>
             build_node 'ROLE' w_sec-role '9' agr_texts-TEXT i_r '60' '' '30'.
             IF w_sec-child_agr <> ' '.
               PERFORM add_roles USING i_r w_sec-role w_sec-mandt.
             ENDIF.
           ENDAT.

           AT NEW profn.
             i_p = i_r + 1.
             SELECT SINGLE ptext FROM usr11 CLIENT SPECIFIED
             INTO usr11-ptext WHERE mandt = w_sec-mandt AND
             profn = w_sec-profn AND aktps = 'A' AND
             langu = SY-langu.
             build_node 'PROF' w_sec-profn '7' usr11-ptext i_p '60' '' '30'.
             IF w_sec-subprof <> ' '.
               PERFORM add_profiles  USING i_p w_sec-profn w_sec-mandt.
             ENDIF.
           ENDAT.

           AT NEW auth.
             i_a = i_p + 1.
             SELECT SINGLE atext FROM usr13 CLIENT SPECIFIED
             INTO usr13-atext WHERE mandt = w_sec-mandt AND
             auth = w_sec-auth AND objct = w_sec-objct AND aktps = 'A' AND
             langu = SY-langu.
             build_node 'AUTH' w_sec-auth '4' usr13-atext i_a '60' '' '20'.
           ENDAT.
           i_v = i_a + 1.
           IF w_sec-bis = ' '.
             IF w_sec-von CA '*+'.
               CONCATENATE 'Range containing pattern'
               w_sec-von INTO tstct-ttext SEPARATED BY SPACE.
             ELSE.
               SELECT SINGLE ttext FROM tstct INTO tstct-ttext
               WHERE tcode  = w_sec-von AND sprsl = SY-langu.
             ENDIF.
             build_node 'VON' w_sec-von '4' tstct-ttext i_v '60' '' '35'.
           ELSE.
             CONCATENATE 'Range in between'  w_sec-von 'and' w_sec-bis
             INTO tstct-ttext SEPARATED BY SPACE.

             CONCATENATE '['  w_sec-von '] -> [' w_sec-bis ']'
             INTO usr13-atext.

             build_node 'VON' usr13-atext '4' tstct-ttext i_v '60' '' '35'.
           ENDIF.

         ENDLOOP.
       ENDFORM.                    " BUILD_TREE1
*&---------------------------------------------------------------------*
*&      Form  DISPLAY_IMPACTS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
       FORM display_impacts  USING HIDE TYPE.
         RANGES: r_mandt FOR it_sec-mandt,
                 r_ustyp FOR it_sec-ustyp,
                 r_class FOR it_sec-CLASS,
                 r_bname FOR it_sec-bname,
                 r_role FOR it_sec-role,
                 r_profn FOR it_sec-profn,
                 r_auth FOR it_sec-auth.

         DEFINE rp.
           CLEAR r_&2.
           r_&2-OPTION = 'EQ'.
           r_&2-SIGN = 'I'.
           r_&2-LOW = &1-&2.
           APPEND r_&2.
         END-OF-DEFINITION.
         DEFINE w.
           CASE TYPE.
             WHEN 'ROOT'.
             WHEN 'MANDT'.
               rp &1: mandt.
             WHEN 'USTYP'.
               rp &1: mandt, ustyp.
             WHEN 'CLASS'.
               rp &1: mandt, ustyp, CLASS.
             WHEN 'BNAME'.
               rp &1: mandt, ustyp, CLASS, bname.
             WHEN 'ROLE'.
               rp &1: mandt, role.
             WHEN 'PROF'.
               rp &1: mandt, profn.
             WHEN 'AUTH'.
               rp &1: mandt, auth.
           ENDCASE.
         END-OF-DEFINITION.

         FREE: f, it_tcode.
         IF g_rep = 'ROLES'.
           CLEAR: w_sec1, w_sec.
           READ TABLE it_sec1 INDEX HIDE INTO w_sec1.
           IF SY-subrc = 0.
             IF TYPE = 'VON'.
               it_tcode-tcd = w_sec1-von.
               APPEND it_tcode.
             ELSE.
               MOVE-CORRESPONDING w_sec1 TO w_sec.
               w w_sec.
               LOOP AT it_sec1 WHERE mandt IN r_mandt AND
                                     role  IN r_role  AND
                                     profn IN r_profn AND
                                     auth  IN r_auth.
                 IF it_sec1-von CA '*+' OR it_sec1-bis <> ' '.
                   CLEAR f.
                   IF it_sec1-bis <> ' '.
                     f-OPTION = 'BT'.
                   ELSE.
                     f-OPTION = 'CP'.
                   ENDIF.
                   f-SIGN = 'I'.
                   f-LOW = it_sec1-von.
                   f-HIGH = it_sec1-bis.
                   APPEND f.
                 ELSE.
                   it_tcode-tcd = it_sec1-von.
                   APPEND it_tcode.
                 ENDIF.
               ENDLOOP.
             ENDIF.
           ENDIF.
         ELSE.
           CLEAR w_sec.
           READ TABLE it_sec INDEX HIDE INTO w_sec.
           IF SY-subrc = 0.
             IF TYPE = 'VON'.
               it_tcode-tcd = it_sec-von.
               APPEND it_tcode.
             ELSE.
               w w_sec.
               LOOP AT it_sec WHERE mandt IN r_mandt AND
                                     ustyp IN r_ustyp AND
                                     CLASS IN r_class AND
                                     bname IN r_bname AND
                                     role  IN r_role  AND
                                     profn IN r_profn AND
                                     auth  IN r_auth.
                 IF it_sec-von CA '*+' OR it_sec-bis <> ' '.
                   CLEAR f.
                   IF it_sec-bis <> ' '.
                     f-OPTION = 'BT'.
                   ELSE.
                     f-OPTION = 'CP'.
                   ENDIF.
                   f-SIGN = 'I'.
                   f-LOW = it_sec-von.
                   f-HIGH = it_sec-bis.
                   APPEND f.
                 ELSE.
                   it_tcode-tcd = it_sec-von.
                   APPEND it_tcode.
                 ENDIF.
               ENDLOOP.
             ENDIF.
           ENDIF.
         ENDIF.

         PERFORM display_tcd_impact.

       ENDFORM.                    " DISPLAY_IMPACTS
*&---------------------------------------------------------------------*
*&      Form  DISPLAY_TCD_IMPACT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
       FORM display_tcd_impact .
         TABLES: prgn_corr2.
         DATA: it_y2tusobxa LIKE y2tusobxa OCCURS 0 WITH HEADER LINE.
         DATA: it_y2tusobta LIKE y2tusobta OCCURS 0 WITH HEADER LINE.
         DATA: N(20)    TYPE C VALUE 'No Check',
               X(20)    TYPE C VALUE 'Check',
               u(20)    TYPE C VALUE 'Not Mainained',
               y(20)    TYPE C VALUE 'Check&Maintain',
               Z(20)    TYPE C,
               v_chg    TYPE C,
               v_t      TYPE C,
               v_o      TYPE C,
               v_f      TYPE C,
               subc     TYPE C,
               v_mod    TYPE C,
               LINE     LIKE SY-linno,
               v_field  LIKE y2tusobt-FIELD,
               v_object LIKE y2tusobt-OBJECT.

         DEFINE C.
           CLEAR Z.
           CASE &1.
             WHEN 'N'. Z = N.
             WHEN 'X'. Z = X.
             WHEN 'U'. Z = u.
             WHEN 'Y'. Z = y.
           ENDCASE.
         END-OF-DEFINITION.
         INCLUDE <LINE>.

         DEFINE a-LINE.
           IF v_t IS INITIAL.
             v_t = 'X'.
             WRITE:/1(1) line_top_middle_corner AS LINE,
                  104(1) line_top_middle_corner AS LINE.
           ELSE.
             WRITE:/1(1) line_left_middle_corner AS LINE,
                  104(1) line_right_middle_corner AS LINE.
           ENDIF.
           ULINE AT 2(102).
         END-OF-DEFINITION.

         DEFINE a-CLOSE.
           WRITE:/1(1) line_bottom_left_corner AS LINE,
                104(1) line_bottom_right_corner AS LINE.
           ULINE AT 2(102).
         END-OF-DEFINITION.

         DEFINE b-LINE.
           IF v_o IS INITIAL.
             v_o = 'X'.
             WRITE:/1(1)'|', 2(1) line_top_middle_corner AS LINE,
                  103(1)  line_top_middle_corner AS LINE, 104(1)'|'.
           ELSE.
             WRITE:/1(1)'|', 2(1) line_left_middle_corner AS LINE,
                  103(1)  line_right_middle_corner AS LINE, 104(1)'|'.
           ENDIF.
           ULINE AT 3(100).
         END-OF-DEFINITION.

         DEFINE b-CLOSE.
           WRITE:/1(1)'|', 2(1) line_bottom_left_corner AS LINE,
                103(1)  line_bottom_right_corner AS LINE, 104(1)'|'.
           ULINE AT 3(100).
         END-OF-DEFINITION.


         DEFINE C-LINE.
           IF v_f IS INITIAL.
             v_f = 'X'.
             WRITE:/1(1)'|', 2(1)'|', 3(1) line_top_middle_corner AS LINE,
             102(1) line_top_middle_corner AS LINE, 103(1)'|', 104(1)'|'.
           ELSE.
             WRITE:/1(1)'|', 2(1)'|', 3(1) line_left_middle_corner AS LINE,
             102(1) line_right_middle_corner AS LINE, 103(1)'|', 104(1)'|'.
           ENDIF.
           ULINE AT 4(98).
         END-OF-DEFINITION.

         DEFINE C-CLOSE.
           WRITE:/1(1)'|', 2(1)'|', 3(1) line_bottom_left_corner AS LINE,
           102(1) line_bottom_right_corner AS LINE, 103(1)'|', 104(1)'|'.
           ULINE AT 4(98).
         END-OF-DEFINITION.

         SORT: it_tcode BY tcd, f BY SIGN OPTION LOW HIGH.
         DELETE ADJACENT DUPLICATES FROM : it_tcode COMPARING tcd,
         f COMPARING SIGN OPTION LOW HIGH.

* HANA Corrections - BEGIN OF MODIFY - <HANA-001>
         IF NOT it_tcode[] IS INITIAL.
* HANA Corrections - END OF MODIFY - <HANA-001>
           SELECT * FROM y2tusobxa INTO TABLE it_y2tusobxa
           FOR ALL ENTRIES IN it_tcode
           WHERE NAME = it_tcode-tcd OR NAME IN f.
* HANA Corrections - BEGIN OF MODIFY - <HANA-001>
         ENDIF.
* HANA Corrections - END OF MODIFY - <HANA-001>
         SORT it_y2tusobxa BY NAME OBJECT msg.

* HANA Corrections - BEGIN OF MODIFY - <HANA-001>
         IF NOT it_tcode[] IS INITIAL.
* HANA Corrections - END OF MODIFY - <HANA-001>
           SELECT * FROM y2tusobta INTO TABLE it_y2tusobta
           FOR ALL ENTRIES IN it_tcode
           WHERE NAME = it_tcode-tcd OR NAME IN f.
* HANA Corrections - BEGIN OF MODIFY - <HANA-001>
         ENDIF.
* HANA Corrections - END OF MODIFY - <HANA-001>
         SORT it_y2tusobta BY NAME OBJECT FIELD msg.
         CLEAR: v_t, v_o, v_f.
         LOOP AT it_tcode.

*TCODE
           FORMAT COLOR COL_BACKGROUND.
           a-LINE.
           CLEAR: tstct, prgn_corr2.
           SELECT SINGLE ttext FROM tstct INTO tstct-ttext
           WHERE tcode  = it_tcode-tcd AND sprsl = SY-langu.
           IF SY-subrc = 0.
             CONCATENATE it_tcode-tcd '-' tstct-ttext
             INTO tstct-ttext SEPARATED BY SPACE.
           ELSE.
             tstct-ttext = it_tcode-tcd.
           ENDIF.
           CONDENSE tstct-ttext.

* AUCT-UPGRADE -  Begin of Modification by <USER> on <17.02.2017> for <EHP8>
*    SELECT SINGLE * FROM PRGN_CORR2
*    INTO PRGN_CORR2 WHERE S_TCODE = IT_TCODE-TCD.
           SELECT * UP TO 1 ROWS FROM prgn_corr2
           INTO prgn_corr2 WHERE s_tcode = it_tcode-tcd
           ORDER BY PRIMARY KEY.
           ENDSELECT.
* AUCT-UPGRADE -  End of Modification by <USER> on <17.02.2017> for <EHP8>
           IF SY-subrc = 0.
             WRITE: /1(1)'|', 2(60) tstct-ttext
             COLOR COL_NEGATIVE INTENSIFIED ON,
                    62(1)'|', 63(10) 'Redisigned'
                    COLOR COL_NEGATIVE INTENSIFIED ON,
                    73(1)'|', 74(30) prgn_corr2-t_tcode
                    COLOR COL_POSITIVE INTENSIFIED ON,
                    104(1)'|'.
           ELSE.
             WRITE: /1(1)'|', 2(102) tstct-ttext COLOR COL_GROUP INTENSIFIED ON,
                    104(1)'|'.
           ENDIF.
*AUTHOBJ
           CLEAR v_o.
           LOOP AT it_y2tusobxa WHERE NAME = it_tcode-tcd.
             b-LINE.
             WRITE: /1(1)'|', 2(1)'|',
                     3(10) it_y2tusobxa-OBJECT
                     COLOR COL_POSITIVE INTENSIFIED OFF,
                     13(1)'|'.
             CASE it_y2tusobxa-msg.
               WHEN '1'.
                 WRITE: 14(89)'Object has been removed.'
                        COLOR COL_NORMAL INTENSIFIED OFF INVERSE ON.
               WHEN '2'.
                 WRITE: 14(57)'Adjust check status'
                 COLOR COL_HEADING INTENSIFIED OFF.
                 C it_y2tusobxa-okflag1.
                 WRITE: 71(1)'|', 72(14) Z
                 COLOR COL_NORMAL INTENSIFIED OFF, 86(1)'|'.
                 C it_y2tusobxa-okflag.
                 WRITE: 87(17) Z COLOR COL_NORMAL INTENSIFIED OFF.
               WHEN '3'.
                 WRITE: 14(57)'Validate standerd values'
                 COLOR COL_HEADING INTENSIFIED OFF.
                 C it_y2tusobxa-okflag1.
                 WRITE: 71(1)'|', 72(14) Z
                 COLOR COL_NORMAL INTENSIFIED OFF, 86(1)'|'.
                 C it_y2tusobxa-okflag.
                 WRITE: 87(17) Z COLOR COL_NORMAL INTENSIFIED OFF.
               WHEN '4'.
                 WRITE: 14(57)'Adjust AuthCheck + valid values'
                 COLOR COL_TOTAL INTENSIFIED OFF.
                 C it_y2tusobxa-okflag1.
                 WRITE: 71(1)'|', 72(14) Z
                 COLOR COL_TOTAL INTENSIFIED ON, 86(1)'|'.
                 C it_y2tusobxa-okflag.
                 WRITE: 87(17) Z COLOR COL_TOTAL INTENSIFIED ON.
               WHEN '5'.
                 WRITE: 14(57)'Adjust AuthCheck + Add values'
                 COLOR COL_NEGATIVE INTENSIFIED OFF.
                 C it_y2tusobxa-okflag1.
                 WRITE: 71(1)'|', 72(14) Z
                 COLOR COL_NEGATIVE INTENSIFIED ON, 86(1)'|'.
                 C it_y2tusobxa-okflag.
                 WRITE: 87(17) Z COLOR COL_NEGATIVE INTENSIFIED ON.
               WHEN '6'.
                 WRITE: 14(57)'Add object + Adjust AuthCheck'
                 COLOR COL_HEADING INTENSIFIED OFF.
                 C it_y2tusobxa-okflag1.
                 WRITE: 71(1)'|', 72(14) Z
                 COLOR COL_NORMAL INTENSIFIED OFF, 86(1)'|'.
                 C it_y2tusobxa-okflag.
                 WRITE: 87(17) Z COLOR COL_NORMAL INTENSIFIED OFF.
               WHEN '7'.
                 WRITE: 14(57)'Add object + Adjust AuthCheck + valid values'
                 COLOR COL_TOTAL INTENSIFIED OFF.
                 C it_y2tusobxa-okflag1.
                 WRITE: 71(1)'|', 72(14) Z
                 COLOR COL_TOTAL INTENSIFIED OFF, 86(1)'|'.
                 C it_y2tusobxa-okflag.
                 WRITE: 87(17) Z COLOR COL_TOTAL INTENSIFIED OFF.
               WHEN '8'.
                 WRITE: 14(57)'Add object + Adjust AuthCheck + Add values'
                 COLOR COL_NEGATIVE INTENSIFIED OFF.
                 C it_y2tusobxa-okflag1.
                 WRITE: 71(1)'|', 72(14) Z
                 COLOR COL_NEGATIVE INTENSIFIED ON, 86(1)'|'.
                 C it_y2tusobxa-okflag.
                 WRITE: 87(17) Z COLOR COL_NEGATIVE INTENSIFIED ON.
             ENDCASE.
             WRITE: 103(1)'|', 104(1)'|'.
             CLEAR: v_field, v_f.
             LOOP AT it_y2tusobta WHERE NAME = it_y2tusobta-NAME AND
                                        OBJECT = it_y2tusobta-OBJECT.
               IF NOT it_y2tusobta-HIGH IS INITIAL.
                 CONCATENATE it_y2tusobta-LOW '->' it_y2tusobta-HIGH
                 INTO it_y2tusobta-LOW.
               ENDIF.
               CONDENSE it_y2tusobta-LOW.
               IF v_field <> it_y2tusobta-FIELD.
                 v_field = it_y2tusobta-FIELD.
                 C-LINE.
                 WRITE:/1(1)'|', 2(1)'|', 3(1)'|',
                 4(10) it_y2tusobta-FIELD
                 COLOR COL_KEY INTENSIFIED ON, 14(1)'|'.
               ELSE.
                 WRITE:/1(1)'|', 2(1)'|', 3(1)'|', 14(1)'|'.
               ENDIF.
               IF it_y2tusobta-msg = '2'.
                 WRITE: 15(43) it_y2tusobta-LOW
                 COLOR COL_NORMAL INTENSIFIED OFF, 58(1)'|'.
                 WRITE: 59(43) 'VALUE DELETED' COLOR COL_NORMAL INTENSIFIED ON,
                 102(1)'|', 103(1)'|', 104(1)'|'.
               ELSEIF it_y2tusobta-msg = '3'.
                 WRITE: 15(43) 'NEW VALUE' COLOR COL_NORMAL INTENSIFIED ON,
                 58(1)'|'.
                 WRITE: 59(43) it_y2tusobta-LOW COLOR COL_NORMAL INTENSIFIED OFF,
                 102(1)'|', 103(1)'|', 104(1)'|'.
               ENDIF.
               DELETE it_y2tusobta.
             ENDLOOP.
             IF SY-subrc = 0.
               C-CLOSE.
             ENDIF.
           ENDLOOP.
           IF SY-subrc = 0.
             subc = 'X'.
           ENDIF.

           CLEAR: v_object, v_field.
           LOOP AT it_y2tusobta WHERE NAME = it_tcode-tcd.
             IF v_object <> it_y2tusobta-OBJECT.
               IF NOT v_object IS INITIAL.
                 C-CLOSE.
               ENDIF.
               v_object = it_y2tusobta-OBJECT.
               v_chg = 'X'.
               CLEAR v_f.
               b-LINE.
               WRITE: /1(1)'|', 2(1)'|', 3(10) it_y2tusobta-OBJECT
               COLOR COL_POSITIVE INTENSIFIED OFF, 13(1)'|'.
               WRITE: 14(89)'Validate values' COLOR COL_HEADING INTENSIFIED OFF,
                 103(1)'|', 104(1)'|'.
               b-CLOSE. LINE = SY-linno . SKIP TO LINE LINE.
             ENDIF.
             IF NOT it_y2tusobta-HIGH IS INITIAL.
               CONCATENATE it_y2tusobta-LOW '->' it_y2tusobta-HIGH
               INTO it_y2tusobta-LOW.
             ENDIF.
             CONDENSE it_y2tusobta-LOW.
             IF v_field <> it_y2tusobta-FIELD OR v_chg = 'X'.
               v_field = it_y2tusobta-FIELD. CLEAR v_chg.
               C-LINE.
               WRITE:/1(1)'|', 2(1)'|', 3(1)'|',
               4(10) it_y2tusobta-FIELD COLOR COL_KEY INTENSIFIED ON,
               14(1)'|'.
             ELSE.
               WRITE:/1(1)'|', 2(1)'|', 3(1)'|', 14(1)'|'.
             ENDIF.
             IF it_y2tusobta-msg = '2'.
               WRITE: 15(43) it_y2tusobta-LOW
               COLOR COL_NORMAL INTENSIFIED OFF, 58(1)'|'.
               WRITE: 59(43) 'VALUE DELETED' COLOR COL_NORMAL INTENSIFIED ON,
               102(1)'|', 103(1)'|', 104(1)'|'.
             ELSEIF it_y2tusobta-msg = '3'.
               WRITE: 15(43) 'NEW VALUE' COLOR COL_NORMAL INTENSIFIED ON,
               58(1)'|'.
               WRITE: 59(43) it_y2tusobta-LOW COLOR COL_NORMAL INTENSIFIED OFF,
               102(1)'|', 103(1)'|', 104(1)'|'.
             ENDIF.
             DELETE it_y2tusobta.
           ENDLOOP.
           IF SY-subrc = 0.
             C-CLOSE.
             b-CLOSE.
           ELSEIF subc = 'X'.
             CLEAR subc.
             b-CLOSE.
           ENDIF.
         ENDLOOP.
         a-CLOSE.
       ENDFORM.                    " DISPLAY_TCD_IMPACT
*&---------------------------------------------------------------------*
*&      Form  DISPLAY_USERS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
       FORM display_users  USING NAME HIDE TYPE .
         RANGES: r_mandt FOR it_sec-mandt,
                 r_ustyp FOR it_sec-ustyp,
                 r_class FOR it_sec-CLASS,
                 r_bname FOR it_sec-bname,
                 r_role FOR it_sec-role,
                 r_profn FOR it_sec-profn,
                 r_auth FOR it_sec-auth.

         DATA: v_profile LIKE w_sec-profn,
               v_role    LIKE w_sec-role,
               v_mandt   LIKE w_sec-mandt.

         DEFINE rp.
           CLEAR r_&2.
           r_&2-OPTION = 'EQ'.
           r_&2-SIGN = 'I'.
           r_&2-LOW = &1-&2.
           APPEND r_&2.
         END-OF-DEFINITION.
         DEFINE w.
           CASE TYPE.
             WHEN 'ROOT'.
             WHEN 'MANDT'.
               rp &1: mandt.
             WHEN 'ROLE'.
               rp &1: mandt.
               w_sec1-role = v_role.
               rp w_sec1: role.
               LOOP AT it_y2tcrel0 WHERE name0 = v_role
                                     AND mandt = v_mandt
                                     AND TYPE  = 'R'.
                 v_role = w_sec1-role = it_y2tcrel0-name1.
                 rp w_sec1: role.
               ENDLOOP.
             WHEN 'PROF'.
               rp &1: mandt.
               w_sec1-profn = v_profile.
               rp w_sec1: profn.
               LOOP AT it_y2tcrel0 WHERE name0 = v_profile
                                     AND mandt = v_mandt
                                     AND TYPE  = 'R'.
                 w_sec1-profn = v_profile.
                 rp w_sec1: profn.
               ENDLOOP.
             WHEN 'AUTH'.
               rp &1: mandt, auth.
             WHEN 'VON'.
               rp &1: mandt.
               LOOP AT it_sec1 WHERE von = NAME.
                 w_sec1-auth = it_sec1-auth.
                 rp w_sec1: auth.
               ENDLOOP.

           ENDCASE.
         END-OF-DEFINITION.
         FREE: it_users.
         IF g_rep = 'ROLES'.
           CLEAR: w_sec1, w_sec.
           READ TABLE it_sec1 INDEX HIDE INTO w_sec1.
           IF SY-subrc = 0.
             MOVE-CORRESPONDING w_sec1 TO w_sec.
             v_profile = NAME.
             v_role = NAME.
             v_mandt = w_sec-mandt.
             w w_sec.
             SELECT mandt ustyp CLASS bname FROM y2tseca0 CLIENT SPECIFIED
             INTO TABLE it_users WHERE mandt IN r_mandt AND
                                       role  IN r_role  AND
                                       profn IN r_profn AND
                                       auth  IN r_auth.
             SORT it_users BY mandt ustyp CLASS bname.
             DELETE ADJACENT DUPLICATES FROM it_users
             COMPARING mandt ustyp CLASS bname.
           ENDIF.
         ENDIF.

         PERFORM build_tree2 USING NAME.
         PERFORM display_tree2.

       ENDFORM.                    " DISPLAY_USERS
*&---------------------------------------------------------------------*
*&      Form  BUILD_TREE2
*&---------------------------------------------------------------------*
       FORM build_tree2 USING NAME.
         DEFINE build_node.
           i_tree1-TYPE = &1.
           i_tree1-NAME = &2.
           i_tree1-COLOR = &3.
           i_tree1-TEXT = &4.
           i_tree1-tlevel = &5.
           i_tree1-tlength = &6.
           i_tree1-tcolor = &7.
           i_tree1-nlength = &8.
           i_tree1-HIDE = v_hide.
           APPEND i_tree1. CLEAR:  i_tree1.
         END-OF-DEFINITION.
         FREE i_tree1.
         build_node 'ROOT' NAME '3' '' '1' '60' '' '15'.
         LOOP AT it_users.
           w_users = it_users.
           AT NEW mandt.
             SELECT SINGLE mtext FROM t000 INTO t000-mtext
             WHERE mandt = w_users-mandt.
             build_node 'MANDT' w_users-mandt '3' t000-mtext '2' '25' '' '3'.
           ENDAT.

           AT NEW ustyp.
* AUCT-UPGRADE -  Begin of Modification by <USER> on <17.02.2017> for <EHP8>
*      SELECT SINGLE DDTEXT FROM DD07T INTO DD07T-DDTEXT
*      WHERE DOMVALUE_L = W_USERS-USTYP AND DOMNAME = 'XUUSTYP'
*      AND AS4LOCAL = 'A' AND DDLANGUAGE = SY-LANGU.
             SELECT ddtext FROM dd07t INTO dd07t-ddtext
                   WHERE domvalue_l = w_users-ustyp AND domname = 'XUUSTYP'
                   AND as4local = 'A' AND ddlanguage = SY-langu
             ORDER BY PRIMARY KEY.
               EXIT.
             ENDSELECT.
* AUCT-UPGRADE -  End of Modification by <USER> on <17.02.2017> for <EHP8>
             SPLIT dd07t-ddtext AT '(' INTO dd07t-ddtext t000-mtext.
             build_node 'USTYP' dd07t-ddtext '3' '' '3' '25' '' '20'.
           ENDAT.

           AT NEW CLASS.
             SELECT SINGLE TEXT FROM usgrpt CLIENT SPECIFIED INTO usgrpt-TEXT
             WHERE usergroup = w_users-CLASS AND sprsl = SY-langu AND
             mandt = w_users-mandt.
             build_node 'CLASS' w_users-CLASS '3' usgrpt-TEXT '4' '60' '' '12'.
           ENDAT.

           AT NEW bname.
             build_node 'BNAME' w_users-bname '3' '' '5' '25' '' '12'.
           ENDAT.
         ENDLOOP.
         FREE it_users.

       ENDFORM.                    " BUILD_TREE2
*&---------------------------------------------------------------------*
*&      Form  DISPLAY_TREE2
*&---------------------------------------------------------------------*
       FORM display_tree2 .
         DATA: v_repid TYPE SY-repid.
         v_repid = SY-repid.
         CALL FUNCTION 'RS_TREE_CONSTRUCT'
           TABLES
             nodetab            = i_tree1
           EXCEPTIONS
             tree_failure       = 1
             id_not_found       = 2
             wrong_relationship = 3
             OTHERS             = 4.

         CALL FUNCTION 'RS_TREE_LIST_DISPLAY'
           EXPORTING
             callback_program      = v_repid
             callback_gui_status   = 'TREE'
             callback_user_command = 'USER_COMMAND'
           EXCEPTIONS
             OTHERS                = 1.
         FREE i_tree1.
       ENDFORM.                    " DISPLAY_TREE2
