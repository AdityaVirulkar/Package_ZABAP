parameters: objname like vrsd-objname, " Name des Reports
            objnam2 like vrsd-objname default ' ',
            objtyp1 like vrsd-objtype, " REPO oder REPS
            objtyp2 like vrsd-objtype, " REPO oder REPS
            versno1 like vrsd-versno,  " Versionsnr. des neueren Rep.
            versno2 like vrsd-versno,  " Versionsnr. des älteren Rep.
                                       " auch: Versionsnr. im RemoteS
            infoln1a like vrsinfolna,
            infoln1b like vrsinfolnb,
            infoln2a like vrsinfolna,
            infoln2b like vrsinfolnb,
            log_dst1 like rfcdes-rfcdest default space,
            log_dest like rfcdes-rfcdest default ' ',
            rem_sys1 like tadir-srcsystem default space,
            rem_syst like tadir-srcsystem default ' '.

include rsvcutct.                      "Utilities: Constants and Types
include rsvcvdct.
include rsvcrect.                      "Reports: Constants and Types
include rsvcretd.                      "Reports: Tables and Buffers
include rsvctdud.      "Tables and constants for saving user defaults
* Anschlüße an Transportwesen:
include rsvctrct.                      "Constants and types
include rsvctrtd.                      "Tables and buffers
include rsvctrfo.                      "Form routines
*
include rsvcrsud.                      "Forms for saving user defaults
*
tables: vrsdynpro.
*
data: e07t_entry like e07t.

data: begin of fcode_tab occurs 5,
        fcode like sy-ucomm,
      end of fcode_tab.

data: version_rgt like vrsd-versno,
      version_lft like vrsd-versno,
      objname_rgt like vrsd-objname,
      objname_lft like vrsd-objname,
      objtype_rgt like vrsd-objtype,
      objtype_lft like vrsd-objtype,
      korrnum_rgt like vrsd-korrnum,
      korrnum_lft like vrsd-korrnum,
      korrtxt_rgt like e07t-as4text,
      korrtxt_lft like e07t-as4text,
      korrinf_rgt like infoln1b,
      korrinf_lft like infoln1b,
      remsyst_lft like tadir-srcsystem,
      remsyst_rgt like tadir-srcsystem,
      logdest_lft like rfcdes-rfcdest,
      logdest_rgt like rfcdes-rfcdest,
      fcode like sy-ucomm,
      local_system like tadir-srcsystem.

field-symbols: <refname_lft>,
               <refname_rgt>.
data: namlen type i.

data: which_text   like use_text,
      cursor_ok    like bool,
      delta_only   like bool,
      one_column   like bool,
      split_edi    like bool,                       "VJR
      shorten_same like bool,
      with_korrnum like bool,
      remote_comp  like bool,
      double_remote_comp like bool,
      left_flag    like bool,
      sort_vers    like bool,
      no_delta     like bool,
      with_linenumbers like bool,
      gv_ignore_case_differences like bool value 'X',
      gv_offs_hscroll type i.

data: gv_initialize_dynpro like bool,
      new_delta like bool,
      new_list like bool,
      keep_pos like bool.

data: scr_line  like sy-staro.

data: act_line1 like line_nr,
      act_line2 like line_nr.

* meine vjr VariablenDefinitionen -------------------------------------
type-pools: smodi.
data: gv_transport_key type trkey,
      gt_smodilog_lft  type table of smodilog,
      gt_smodilog_rgt  type table of smodilog,
      gt_MOD_TAB_LFT   TYPE  SMODI_MOD_TAB,
      gt_MOD_TAB_rgt   TYPE  SMODI_MOD_TAB.

data: object_lft       type progdir-name,
      object_rgt       type progdir-name.
data: gt_SOURCE_Lft    TYPE  RSWSOURCET,
      gt_SOURCE_rgt    TYPE  RSWSOURCET.

data: gv_new_splitscreen type boolean.
data: gv_answer          type sy-input.
* Ende vjr Variablen
include rsvcrslt. "Constants for positioning on the list
include rsvcrsls.                      "Report Comparing: List Handling
include rsvcrsst.     "Report Comparing: Status Handling
include rsvcrcio.                      "Report Comparing: I/O Modules
include rsvcrsps.     "Report Comparing: Positioning and Extraction
include rsvcrcrp.     "Report Comparing: Report Representation
include rsvcrsfc.     "Report Comparing: F-Code Handling

***********************************************************************
*  Programmanfang
***********************************************************************

*start-of-selection.

    gv_new_splitscreen = true.

  call function 'SVRS_CHECK_READ_PERMISSION'
       exporting
            objtype            = objtyp1
            objname            = objname
       importing                                                 "VJR
            transport_key      = gv_transport_key                "VJR
       exceptions
            no_read_permission = 1
            others             = 2.

  if sy-subrc <> 0.
    message id sy-msgid type 'E' number sy-msgno
            with sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  endif.

* Variablen initialisieren.
  perform get_user_defaults changing  one_column
                                      disp_mode
                                      with_linenumbers
                                      comp_mode
                                      delta_only
                                      shorten_same
                                      ls_left_col
                                      ls_right_col
                                      split_edi.
* only one compare mode is supported for XSLT sources
  if objtyp1 = 'XSLT' or objtyp2 = 'XSLT'.
    comp_mode = 1.
    gv_ignore_case_differences = false.
    clear split_edi."splitscreen does not support XSLT - only old view is supported
  endif.

  with_korrnum = false.
  keep_pos     = false.
  remote_comp  = false.
  left_flag    = true.

  if objnam2 = ' '.
    objnam2 = objname.
  endif.

* Check, if REMOTE-Mode.
  if log_dest <> space and log_dst1 <> space.
    double_remote_comp = true.
    remote_comp = false.
  elseif log_dest <> space or log_dst1 <> space.
    double_remote_comp = false.
    remote_comp = true.
*   Hole den Namen des lokalen Systems.
    perform check_system_params.
    local_system = systemname.
  else.
    double_remote_comp = false.
    remote_comp = false.
  endif.

* Blende Funktionen aus.
  perform set_disabled_fcode.

* Sortiere Versionsnummern und zugehörige Info
* Die Versionen werden so angeordnet:
* links neue Version        rechts alte Version
* links lokale Version      rechts remote Version
  if remote_comp = true.
    if log_dest <> space.
      sort_vers = true.
    else.
      sort_vers = false.
    endif.

  elseif double_remote_comp = true and log_dst1 <> log_dest.
    sort_vers = true.

  elseif    versno1 > versno2
         or ( versno1 = 0 and versno2 <> '99999' ).
    sort_vers = true.
  else.
    sort_vers = false.
  endif.

  if sort_vers = false.
    version_lft  = versno2.
    version_rgt  = versno1.
    objtype_lft  = objtyp2.
    objtype_rgt  = objtyp1.
    objname_lft  = objnam2.
    objname_rgt  = objname.
    korrnum_lft  = infoln2b-korrnum.
    korrnum_rgt  = infoln1b-korrnum.
    korrinf_lft  = infoln2b.
    korrinf_rgt  = infoln1b.
    logdest_lft  = log_dest.
    logdest_rgt  = log_dst1.
    remsyst_lft  = rem_syst.
    remsyst_rgt  = rem_sys1.
  else.
    version_lft  = versno1.
    version_rgt  = versno2.
    objtype_lft  = objtyp1.
    objtype_rgt  = objtyp2.
    objname_lft  = objname.
    objname_rgt  = objnam2.
    korrnum_lft  = infoln1b-korrnum.
    korrnum_rgt  = infoln2b-korrnum.
    korrinf_lft  = infoln1b.
    korrinf_rgt  = infoln2b.
    logdest_lft  = log_dst1.
    logdest_rgt  = log_dest.
    remsyst_lft  = rem_sys1.
    remsyst_rgt  = rem_syst.
  endif.

  if objtyp1 = 'METH'.
    namlen = cp_meth.
  else.
    namlen = cp_prog.
  endif.
  assign objname_lft(namlen) to <refname_lft>.
  assign objname_rgt(namlen) to <refname_rgt>.

* Vergleiche die Versionen.
  perform st_get_korrtexts.
  perform get_versions.
  if no_delta = true.
    message i107.
    exit.
  endif.
* Anschluß Splitscreeneditor                                        "VJR
  object_lft = objname_lft.
  object_rgt = objname_rgt.
  gt_SOURCE_Lft[] =  abaptext_sec[].
  gt_SOURCE_rgt[] =  abaptext_pri[].
