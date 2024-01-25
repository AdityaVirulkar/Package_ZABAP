*++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*
* CHANGE ID : HANA-001
* USER: ACC11346068
* DATE: 05.06.2017
* TR : S7HK900166
* DESCRIPTION: HANA CORRECTION
* TEAM : HANA-MIGRATION
*++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*
FUNCTION z_prev_approver_fi_post.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     REFERENCE(BUKRS) TYPE  BUKRS
*"     REFERENCE(BELNR) TYPE  BELNR_D
*"     REFERENCE(GJAHR) TYPE  GJAHR
*"  CHANGING
*"     VALUE(PREVIOUSAPPROVERS) TYPE  ZPREVIOUSAPPROVERS OPTIONAL
*"----------------------------------------------------------------------

  DATA: BEGIN OF wiid OCCURS 0,
          wi_id      LIKE swivobject-wi_id,
          wi_rh_task LIKE swivobject-wi_rh_task,
        END OF wiid.
  DATA: tswiv LIKE swivobject OCCURS 0 WITH HEADER LINE.
  DATA: prevapprovers LIKE zapimsg30 OCCURS 0 WITH HEADER LINE.

  DATA: cnt TYPE i.
  DATA: wi_chckwi LIKE swivobject-wi_chckwi.
  DATA: wi_id   LIKE swivobject-wi_id.
  DATA: prev_wi_id   LIKE swivobject-wi_id.
  DATA: wi_rh_task LIKE swivobject-wi_rh_task.
  DATA: objid LIKE swhactor-objid.
  DATA: aagent LIKE swivobject-wi_aagent.
  DATA: tabix LIKE sy-tabix.
  DATA: key(18) TYPE c.

*sy-subrc = 4.
*while sy-subrc <> 0.
*sy-subrc = 4.
*endwhile.

  CONCATENATE bukrs belnr gjahr INTO key.

  CLEAR: wi_id, wi_rh_task, wiid, tswiv, previousapprovers.
  REFRESH: wiid, tswiv, previousapprovers.

  SELECT wi_id wi_rh_task
           FROM swivobject
            INTO (wi_id, wi_rh_task)
           WHERE objkey = key
            AND  wi_rh_task = 'WS91000033'
             AND element    = 'BKPF'
             AND objtype    = 'BKPF'.
    IF wi_id > wiid-wi_id.
      wiid-wi_id = wi_id.
      wiid-wi_rh_task = wi_rh_task.
    ENDIF.
  ENDSELECT.
  IF sy-subrc = 0.
    APPEND wiid.
  ENDIF.
*put work item back into temporary field.
  LOOP AT wiid.
    wi_id = wiid-wi_id.
    wi_rh_task = wiid-wi_rh_task.
  ENDLOOP.
  DESCRIBE TABLE wiid LINES cnt.
  IF cnt = 0.
    RETURN.
  ENDIF.
* now select all work items for that Superordinate Work Item
  SELECT wi_id APPENDING CORRESPONDING FIELDS OF TABLE wiid
           FROM swivobject
           FOR ALL ENTRIES IN wiid
           WHERE wi_chckwi = wiid-wi_id.

  SORT wiid.
  DELETE ADJACENT DUPLICATES FROM wiid.

  DESCRIBE TABLE wiid LINES cnt.
  IF cnt = 0.
    RETURN.
  ENDIF.

* Select again, this time by all work items
* HANA Corrections - BEGIN OF MODIFY - <HANA-001>
*  SELECT * FROM swivobject INTO TABLE tswiv
*          FOR ALL ENTRIES IN wiid
*           WHERE wi_id = wiid-wi_id.
  SELECT * FROM swivobject INTO TABLE tswiv
          FOR ALL ENTRIES IN wiid
           WHERE wi_id = wiid-wi_id
ORDER BY PRIMARY KEY.
* HANA Corrections - END OF MODIFY - <HANA-001>

* Who made the decision?
  PERFORM get_approvers TABLES tswiv
                           wiid
                           previousapprovers.

*Find Agents who approved
*  LOOP AT tswiv WHERE
*      ( wi_rh_task = 'TS91000104' OR wi_rh_task =  'TS95000020' )
*      AND        objtype = 'USR01DOHR'.
*
*    IF tswiv-wi_cruser = 'WF-BATCH' AND NOT tswiv-element = 'AGENTOBJECT'.
*      CONCATENATE  aagent  ' - Escalated'
*                                    INTO prevapprovers.     "-zmsg30.
*      APPEND prevapprovers.
**      BREAK-POINT.
*    ENDIF.
*  ENDLOOP.

  LOOP AT prevapprovers.
    APPEND prevapprovers TO previousapprovers.
  ENDLOOP.
*
ENDFUNCTION.
*
*&---------------------------------------------------------------------*
*&      Form  get_approvers
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM get_approvers TABLES ptswiv "like swivobject with header line
                      wiid
                      previousapprovers.

  DATA: wa-swwloghist TYPE swwloghist.
  DATA: tswiv LIKE swivobject OCCURS 0 WITH HEADER LINE.
  DATA: tdeadline LIKE swwloghist OCCURS 0 WITH HEADER LINE.
  DATA: BEGIN OF twiid OCCURS 0,
          wi_id      LIKE swivobject-wi_id,
          wi_rh_task LIKE swivobject-wi_rh_task,
        END OF twiid.
  DATA: wi_id   LIKE swivobject-wi_id.
  DATA: aagent LIKE swivobject-wi_aagent.
  DATA: task(14).
  DATA: tabix LIKE sy-tabix.
  DATA: r_wi_id TYPE RANGE OF swivobject-wi_id WITH HEADER LINE. "MD1K980819

  tswiv[] = ptswiv[].
  twiid[] = wiid[].

* Range for valid work items to avoid error in Forwarding only consider from this range. MD1K980819
  LOOP AT twiid.
    r_wi_id-sign = 'I'.
    r_wi_id-option = 'EQ'.
    r_wi_id-low = twiid-wi_id.
    APPEND r_wi_id.
  ENDLOOP.

  SELECT * FROM swwloghist INTO TABLE tdeadline
*                WHERE wi_id = tswiv-wi_id
                 FOR ALL ENTRIES IN twiid
                 WHERE wi_id = twiid-wi_id
                  AND method = 'RSWWDHEX'.

* Look for decision task
  LOOP AT tswiv  WHERE
                 element = 'BKPF' AND
                 objtype  = 'BKPF'       AND
                 ( wi_rh_task = 'TS91000104' OR wi_rh_task = 'TS95000020' ).
    wi_id = tswiv-wi_id.
    tabix = sy-tabix.
    aagent = tswiv-wi_aagent.
* if tswiv-wi_aagent is blank then work item is pending in somebodys inbox
    CHECK NOT tswiv-wi_aagent IS INITIAL.
    SELECT SINGLE wi_id FROM swwwihead INTO wi_id WHERE
                   wi_id IN r_wi_id AND                     "MD1K980819
                   wi_aagent = tswiv-wi_aagent AND
                   wi_stat = 'COMPLETED'   AND
                   wi_rh_task = 'TS30200146'.
    IF sy-subrc = 0.

      READ TABLE  tswiv WITH KEY wi_id = wi_id.
      IF sy-subrc = 0.
* Item was Forwarded
        "aagent = tswiv-objkey.
        aagent = tswiv-wi_aagent.
        CONCATENATE aagent ' -Forwarded'
                               INTO previousapprovers.      "-zmsg30.
        APPEND previousapprovers.
        DELETE tswiv INDEX tabix.
        CONTINUE.                                           "MD1K980765
      ENDIF.
    ENDIF.                                                  "MD1K980765

*      IF TSWIV-WI_AAGENT = 'WF-BATCH'.
*if WF-BATCH initiated then it is Deadline
    READ TABLE tdeadline WITH KEY wi_id = tswiv-wi_id
              method = 'RSWWDHEX'.

    IF sy-subrc = 0.
* find out who missed deadline and workitem escalated.
      LOOP AT    tswiv WHERE
           " element = 'AGENTOBJECT'    AND "'AGENTOBJECT'
            objtype = 'USR01DOHR'      AND
            wi_id    >  wi_id.
        tabix = sy-tabix.
        EXIT.
      ENDLOOP.
      IF sy-subrc = 0.
        aagent = tswiv-objkey.
        CONCATENATE aagent ' -Escalated'
                                     INTO previousapprovers. "-zmsg30.
        APPEND previousapprovers.
        DELETE tswiv INDEX tabix.
      ENDIF.
      " subrc =0.
    ELSE.            "tswiv-wi_aagent = 'WF-BATCH'.

* Missed deadline?
* AUCT-UPGRADE -  Begin of Modification by <USER> on <17.02.2017> for <EHP8>
*      SELECT SINGLE * FROM swwloghist INTO wa-swwloghist
*      WHERE wi_id = tswiv-wi_id
*       AND method = 'RSWWDHEX'.
      SELECT * UP TO 1 ROWS FROM swwloghist INTO wa-swwloghist
      WHERE wi_id = tswiv-wi_id
      AND method = 'RSWWDHEX'
      ORDER BY PRIMARY KEY.
      ENDSELECT.
* AUCT-UPGRADE -  End of Modification by <USER> on <17.02.2017> for <EHP8>
      IF sy-subrc = 0.
        CONCATENATE aagent ' -Escalated'
                                     INTO previousapprovers. "-zmsg30.
        APPEND previousapprovers.
      ELSE.
*end swag
* Approved
* if status is not COMPLETED then do not add
        CHECK tswiv-wi_stat = 'COMPLETED'.
        IF tswiv-wi_rh_task =  'TS95000020'.
          CONCATENATE aagent ' -Reviewed'
                                        INTO previousapprovers. "-zmsg3
          APPEND previousapprovers.
          DELETE tswiv INDEX tabix.
        ELSE.
          CONCATENATE aagent ' -Approved'
                                        INTO previousapprovers. "-zmsg3
          APPEND previousapprovers.
          "      DELETE tswiv INDEX tabix.
        ENDIF.
      ENDIF.

    ENDIF.
*    ENDIF.                       "MD1K980765
  ENDLOOP.

ENDFORM.                    "get_approvers
