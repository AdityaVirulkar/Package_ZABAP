*&---------------------------------------------------------------------*
*& Include          ZACCENTURE_TOOLS_SUB
*&---------------------------------------------------------------------*
FORM sub_set_screen_texts.
  DATA:lwa_seltexts TYPE rsseltexts,
       lit_seltexts TYPE TABLE OF rsseltexts.

  lv_flag1 = abap_true.
  lv_flag2 = abap_true.
  lv_flag3 = abap_true.
  lv_flag4 = abap_true.
  lv_flag5 = abap_true.
  lv_flag6 = abap_true.
  lv_flag7 = abap_true.
  lv_flag8 = abap_true. "added by Nancy for green it on 16/05/2022

  p_line1 = '******************************************************************'.
  p_line4 = '* CHANGE ID : AUCT/HANA-001'.
  p_line5 = '* AUTHOR : '.
  p_line2 = '* DATE : '.
  p_line3 = '* TR : '.
  p_line6 = '* DESCRIPTION: AUCT/HANA CORRECTION'.
  p_line7 = '* TEAM : AUCT/HANA-UPGRADE'.
  p_line8 = '******************************************************************'.

  p_line9 = '* AUCT/HANA-UPGRADE - BEGIN OF MODIFY - <AUCT/HANA-001>'.
*  p_line10 = '* AUCT/HANA-UPGRADE - BEGIN OF MODIFY - <AUCT/HANA-002>'. " ADDED BY PARUL PURI FOR DEFECT ID - 532
  p_line11 = '* AUCT/HANA-UPGRADE - END OF MODIFY - <AUCT/HANA-001>'.
*  p_line12 = '* AUCT/HANA-UPGRADE - END OF MODIFY - <AUCT/HANA-002>'.  " ADDED BY PARUL PURI FOR DEFECT ID - 532

*  comm1 = 'Features of this tool created by U.S. Patent No.9430506 ans 10216772,'.
*  comm2 = 'and other granted non-U.S. patents and/or patent applications pending wordwide'.
  com1 = 'Execution mode'.
  com2 = 'Enter Variant ID or Object name'.
  com3 = 'Analysis'.
  com4 = 'Select Target S4 version to be checked for'.
  com5 = 'Select syntax check options'.
  com32 = 'Dependent objects collection'. " Added by Palani for CR 814 on 02/12/2021
  com_ft1 = 'Dowload Options (''.XML'' extenstion automatically appended to filename)'.
  com4_f = 'Workload Analysis Data (ST03 File)'. "Added by Gunjan on 22/2/2021 Defect#652
  com6 = 'Corrections'.
  com7 = 'Select syntax check options'.
  com8 = 'Custom ModLog and Inline comments'.
  com9 = 'Select the S4 Utility to be run'.
  com10 = 'Upload File'.
  com11 = 'Logical File Path Remediation'. " ins Dhiraj -14-01-2020
  com12 = 'OS Migration & Log. Path Remediation'. "ins Dhiraj
  com30 = 'Below Analysis Required ?'."ins Dhiraj -31-03-2020
  com40 = 'Select Source S4 version to be checked for'. " PARUL PURI FOR SOURCE VERSION
*  %_p_app_%_app_%-text = 'SAP UNIX Directory'.
*  com_ft2 = 'SAP UNIX Directory'.
*****boc by shikha on 20/02/2020 for FCV/LCV.
  com13 = 'Selection Criterion'.
  com17 = 'Selection Parameters'.
  com24 = 'Technical Functionalities'.
  com25 = 'Functional Functionalities'.
  com27 = 'Conversion Selection'.
  com28 = 'Conversion Selection'.
  com29 = 'Process Options'.
*****eoc by shikha on 20/02/2020 for FCV/LCV.
*****BOC by Jeba 11.08.2020
  com14 = 'Field Length Extension Check'.
*****EOC by Jeba 11.08.2020
* BOC FIAT Tool******************************
*  com_ft = 'Simplification Functional'.
* EOC FIAT Tool ****************************
*****BOC Fiori tool requirements**********************************
  com15 = 'FIORI/Odata'.                      " 'Is Fiori assessment in scope?'.
  com20 = 'Customer specific namespace '. "for Fiori Group/ Catalog'.
  com21 = 'Embedded Gateway'.
  com22 = 'Central Hub Gateway'.
  com23 = 'RFC Destination to SAP Gateway'.
*  com_cl = 'OS Migration'.  " Added by Pooja Kalshetti
  com_mod = 'Scan SAP Modification Objects'.  "Added by Vikas for CR#555 SAP Modifications objects Scan
  com31 = 'Enter Source and Target os'.
  com16 = 'New Correction Process'. "Added by Jeba 11.08.2020
  com18 = 'Formatting'. "Added by Jeba for #956 on 13/10/2021
*  com16 = 'RFC'.
*****EOC Fiori tool requirements**********************************
  com50 = 'RICEFW Utility Or Extensibility Recommendation'. "Extension
  button1 = 'Inventory Collection'.
  button2 = 'Detection'.
  button3 = 'Correction'.
  button4 = 'S4 Other Utilities'.
**BOC by deepika for CR 813 on 01/12/2021
  button5 = 'CWRM'.
**EOC by deepika for CR 813 on 01/12/2021
  "BOC by Nancy for Green IT on 16/05/2022
  button6 = 'Green IT'.
  "EOC by deepika for Green IT on  16/05/2022
  mytab-prog = sy-repid.
  mytab-dynnr = 100.
  mytab-activetab = 'PUSH1'.
**BOC FIAT ************************************
  CLEAR lwa_seltexts.
  lwa_seltexts-name = 'P_APP'.
  lwa_seltexts-kind = 'P'.
  lwa_seltexts-text = 'SAP UNIX Directory'.
  APPEND lwa_seltexts TO lit_seltexts.
*BOC by Gunjan on 22/2/2021 Defect#652
  CLEAR lwa_seltexts.
  lwa_seltexts-name = 'P_WLD'.
  lwa_seltexts-kind = 'P'.
  lwa_seltexts-text = 'Use External File'.
  APPEND lwa_seltexts TO lit_seltexts.

  CLEAR lwa_seltexts.
  lwa_seltexts-name = 'P_STF'.
  lwa_seltexts-kind = 'P'.
  lwa_seltexts-text = 'SAP App Server Directory'.
  APPEND lwa_seltexts TO lit_seltexts.
*EOC by Gunjan on 22/2/2021 Defect#652
**EOC FIAT ************************************
  CLEAR lwa_seltexts.
  lwa_seltexts-name = 'P_VARID1'.
  lwa_seltexts-kind = 'P'.
  lwa_seltexts-text = 'Variant ID'.
  APPEND lwa_seltexts TO lit_seltexts.

  CLEAR lwa_seltexts.
  lwa_seltexts-name = 'S_NSPACE'.
  lwa_seltexts-kind = 'S'.
  lwa_seltexts-text = 'Customer Namespace'.
  APPEND lwa_seltexts TO lit_seltexts.

  CLEAR lwa_seltexts.
  lwa_seltexts-name = 'S_PKGNAM'.
  lwa_seltexts-kind = 'S'.
  lwa_seltexts-text = 'Package'.
  APPEND lwa_seltexts TO lit_seltexts.

**  BOC By Gunjan on 6/9/2020 Defect#269
  CLEAR lwa_seltexts.
  lwa_seltexts-name = 'S_TRNAME'.
  lwa_seltexts-kind = 'S'.
  lwa_seltexts-text = 'Transport Request'.
  APPEND lwa_seltexts TO lit_seltexts.
**  EOC By Gunjan on 6/9/2020 Defect#269
*START OF CHANGE BY GUNJAN ON 06.24.2020 Defect#269
  CLEAR lwa_seltexts.
  lwa_seltexts-name = 'C_RETRO'.
  lwa_seltexts-kind = 'P'.
  lwa_seltexts-text = 'Retrofit Transports'.
  APPEND lwa_seltexts TO lit_seltexts.
*END OF CHANGE BY GUNJAN ON 06.24.2020 Defect#269

*START OF CHANGE BY GUNJAN ON 07.14.2020 Defect#214
  CLEAR lwa_seltexts.
  lwa_seltexts-name = 'C_SCOPE'.
  lwa_seltexts-kind = 'P'.
  lwa_seltexts-text = 'Select if S4 is in scope'.
  APPEND lwa_seltexts TO lit_seltexts.
*END OF CHANGE BY GUNJAN ON 07.14.2020 Defect#214
**BOC by Jeba for CR 593 on 23.04.2021
  CLEAR lwa_seltexts.
  lwa_seltexts-name = 'P_FIAT'.
  lwa_seltexts-kind = 'P'.
  lwa_seltexts-text = 'Simplification Functional'.
  APPEND lwa_seltexts TO lit_seltexts.
**EOC by Jeba for CR 593 on 23.04.2021
  CLEAR lwa_seltexts.
  lwa_seltexts-name = 'P_TR'.
  lwa_seltexts-kind = 'P'.
  lwa_seltexts-text = 'Transport Request'.
  APPEND lwa_seltexts TO lit_seltexts.

**BOC by Anurag for cr 834 on 11/02/2022
  CLEAR lwa_seltexts.
  lwa_seltexts-name = 'P_PKGNAM'.
  lwa_seltexts-kind = 'P'.
  lwa_seltexts-text = 'Package'.
  APPEND lwa_seltexts TO lit_seltexts.
**EOC by Anurag for cr 834

  CLEAR lwa_seltexts.
  lwa_seltexts-name = 'S_OPCODE'.
  lwa_seltexts-kind = 'S'.
  lwa_seltexts-text = 'Operation Codes'.
  APPEND lwa_seltexts TO lit_seltexts.

  CLEAR lwa_seltexts.
  lwa_seltexts-name = 'P_FILE'.
  lwa_seltexts-kind = 'P'.
  lwa_seltexts-text = 'Input File Path'. "CHANGED BY PARUL PURI TO AVOID CONFUSION
  APPEND lwa_seltexts TO lit_seltexts.

  CLEAR lwa_seltexts.
  lwa_seltexts-name = 'R_TAB'.
  lwa_seltexts-kind = 'P'.
  lwa_seltexts-text = 'Upload in Table'.
  APPEND lwa_seltexts TO lit_seltexts.

  CLEAR lwa_seltexts.
  lwa_seltexts-name = 'R_FILE'.
  lwa_seltexts-kind = 'P'.
  lwa_seltexts-text = 'Download in File'.
  APPEND lwa_seltexts TO lit_seltexts.

* Detection Selection screen
  CLEAR lwa_seltexts.
  lwa_seltexts-name = 'P_VARID2'.
  lwa_seltexts-kind = 'P'.
  lwa_seltexts-text = 'Variant ID'.
  APPEND lwa_seltexts TO lit_seltexts.

*BOC by Shikha for 631 on 2 Mar 2021
  CLEAR lwa_seltexts.
  lwa_seltexts-name = 'P_LIMIT'.
  lwa_seltexts-kind = 'P'.
  lwa_seltexts-text = 'Lines Limit'.
  APPEND lwa_seltexts TO lit_seltexts.
*BOC by Shikha for 631 on 2 Mar 2021

  CLEAR lwa_seltexts.
  lwa_seltexts-name = 'S_OBJ'.
  lwa_seltexts-kind = 'P'.
  lwa_seltexts-text = 'Object Name'.
  APPEND lwa_seltexts TO lit_seltexts.

  CLEAR lwa_seltexts.
  lwa_seltexts-name = 'C_UPG'.
  lwa_seltexts-kind = 'P'.
  lwa_seltexts-text = 'Upgrade'.
  APPEND lwa_seltexts TO lit_seltexts.

  CLEAR lwa_seltexts.
  lwa_seltexts-name = 'C_HANA'.
  lwa_seltexts-kind = 'P'.
  lwa_seltexts-text = 'HANA DB Migration'.
  APPEND lwa_seltexts TO lit_seltexts.

  CLEAR lwa_seltexts.
  lwa_seltexts-name = 'C_S4'.
  lwa_seltexts-kind = 'P'.
  lwa_seltexts-text = 'Simplification Technical'.
  APPEND lwa_seltexts TO lit_seltexts.

* BOC By Sonal 04/01/2021 - CDS Profiler integration Def #436
  CLEAR lwa_seltexts.
  lwa_seltexts-name = 'C_CDSPRO'.
  lwa_seltexts-kind = 'P'.
  lwa_seltexts-text = 'Scan CDS code'.
  APPEND lwa_seltexts TO lit_seltexts.
* BEC By Sonal 04/01/2021 - CDS Profiler integration Def #436

* boc s/4 extensibility
  CLEAR lwa_seltexts.
  lwa_seltexts-name = 'C_EXT'.
  lwa_seltexts-kind = 'P'.
  lwa_seltexts-text = 'Extensibility Opportunity Finder'.
  APPEND lwa_seltexts TO lit_seltexts.
* boc tejal for ricefw "after oct
  CLEAR lwa_seltexts.
  lwa_seltexts-name = 'P_EXT1'.
  lwa_seltexts-kind = 'P'.
  lwa_seltexts-text = 'RICEFW CATEGORIZATION'.
  APPEND lwa_seltexts TO lit_seltexts.

  CLEAR lwa_seltexts.
  lwa_seltexts-name = 'P_EXT2'.
  lwa_seltexts-kind = 'P'.
  lwa_seltexts-text = 'EXTENSIBILITY RECOMMENDATION'.
  APPEND lwa_seltexts TO lit_seltexts.
* eoc tejal for ricefw
* eoc s/4 extensibility
  CLEAR lwa_seltexts.
  lwa_seltexts-name = 'P_V1'.
  lwa_seltexts-kind = 'P'.
  lwa_seltexts-text = 'Release Plan 1503'.
  APPEND lwa_seltexts TO lit_seltexts.

  CLEAR lwa_seltexts.
  lwa_seltexts-name = 'P_V2'.
  lwa_seltexts-kind = 'P'.
  lwa_seltexts-text = 'Release Plan 1511'.
  APPEND lwa_seltexts TO lit_seltexts.

  CLEAR lwa_seltexts.
  lwa_seltexts-name = 'P_V3'.
  lwa_seltexts-kind = 'P'.
  lwa_seltexts-text = 'Release Plan 1610'.
  APPEND lwa_seltexts TO lit_seltexts.

  CLEAR lwa_seltexts.
  lwa_seltexts-name = 'P_V4'.
  lwa_seltexts-kind = 'P'.
  lwa_seltexts-text = 'Release Plan 1709'.
  APPEND lwa_seltexts TO lit_seltexts.

  CLEAR lwa_seltexts.
  lwa_seltexts-name = 'P_V5'.
  lwa_seltexts-kind = 'P'.
  lwa_seltexts-text = 'Release Plan 1809'.
  APPEND lwa_seltexts TO lit_seltexts.

*BOC by Rahul for 1909 button on 11/20/2020
  CLEAR lwa_seltexts.
  lwa_seltexts-name = 'P_V7'.
  lwa_seltexts-kind = 'P'.
  lwa_seltexts-text = 'Release Plan 2020'.
  APPEND lwa_seltexts TO lit_seltexts.
*EOC by Rahul for 1909 button on 11/20/2020


*BOC by Gunjan for 1909 button on 13/11/2019
  CLEAR lwa_seltexts.
  lwa_seltexts-name = 'P_V6'.
  lwa_seltexts-kind = 'P'.
  lwa_seltexts-text = 'Release Plan 1909'.
  APPEND lwa_seltexts TO lit_seltexts.
*EOC by Gunjan for 1909 button on 13/11/2019

*  BOC by Shikha on 02 Dec 2021 for CR 824
  CLEAR lwa_seltexts.
  lwa_seltexts-name = 'P_V8'.
  lwa_seltexts-kind = 'P'.
  lwa_seltexts-text = 'Release Plan 2021'.
  APPEND lwa_seltexts TO lit_seltexts.
*  EOC by Shikha on 02 Dec 2021 for CR 824

*BOC by PARUL PURI for Defect 677
  CLEAR lwa_seltexts.
  lwa_seltexts-name = 'LIST'.
  lwa_seltexts-kind = 'P'.
  lwa_seltexts-text = 'Select the source version'.
  APPEND lwa_seltexts TO lit_seltexts.
*EOC by PARUL PURI for Defect 677
*BOC by Manisha
  CLEAR lwa_seltexts.
  lwa_seltexts-name = 'P_ST03'.
  lwa_seltexts-kind = 'P'.
  lwa_seltexts-text = 'ST03 Trans Profile(.CSV):'.
  APPEND lwa_seltexts TO lit_seltexts.

  CLEAR lwa_seltexts.
  lwa_seltexts-name = 'P_RFC'.
  lwa_seltexts-kind = 'P'.
  lwa_seltexts-text = 'ST03 RFC Profile(.CSV):'.
  APPEND lwa_seltexts TO lit_seltexts.
* EOC by Manisha

  "BOC by Jeba 11.08.2020
  CLEAR lwa_seltexts.
  lwa_seltexts-name = 'C_NEWCOR'.
  lwa_seltexts-kind = 'P'.
  lwa_seltexts-text = 'New Correction Process'.
  APPEND lwa_seltexts TO lit_seltexts.

  CLEAR lwa_seltexts.
  lwa_seltexts-name = 'C_FLE'.
  lwa_seltexts-kind = 'P'.
  lwa_seltexts-text = 'Material Length Activated'.
  APPEND lwa_seltexts TO lit_seltexts.

  CLEAR lwa_seltexts.
  lwa_seltexts-name = 'C_AFLE'.
  lwa_seltexts-kind = 'P'.
  lwa_seltexts-text =  'Amount Length Activated'.
  APPEND lwa_seltexts TO lit_seltexts.
  "EOC by Jeba 11.08.2020
*BOC by Jeba on 12.08.2021 for #956
  CLEAR lwa_seltexts.
  lwa_seltexts-name = 'C_PRINT'.
  lwa_seltexts-kind = 'P'.
  lwa_seltexts-text = 'Pretty Printer'.
  APPEND lwa_seltexts TO lit_seltexts.

  CLEAR lwa_seltexts.
  lwa_seltexts-name = 'P_LINE'.
  lwa_seltexts-kind = 'P'.
  lwa_seltexts-text = 'Wrap by page width'.
  APPEND lwa_seltexts TO lit_seltexts.
*EOC by Jeba on 12.08.2021 for #956
*** BOC by Palani for CR 814 on 02/12/2021
  CLEAR lwa_seltexts.
  lwa_seltexts-name = 'C_DOBJ'.
  lwa_seltexts-kind = 'P'.
  lwa_seltexts-text = 'Collect Dependent Objects'.
  APPEND lwa_seltexts TO lit_seltexts.

  CLEAR lwa_seltexts.
  lwa_seltexts-name = 'R_DVAR'.
  lwa_seltexts-kind = 'P'.
  lwa_seltexts-text = 'Variant ID'.
  APPEND lwa_seltexts TO lit_seltexts.

  CLEAR lwa_seltexts.
  lwa_seltexts-name = 'R_DOBJ'.
  lwa_seltexts-kind = 'P'.
  lwa_seltexts-text = 'Individual Objects'.
  APPEND lwa_seltexts TO lit_seltexts.

  CLEAR lwa_seltexts.
  lwa_seltexts-name = 'R_DFIL'.
  lwa_seltexts-kind = 'P'.
  lwa_seltexts-text = 'File Input'.
  APPEND lwa_seltexts TO lit_seltexts.

  CLEAR lwa_seltexts.
  lwa_seltexts-name = 'P_DVAR'.
  lwa_seltexts-kind = 'P'.
  lwa_seltexts-text = 'Variant ID'.
  APPEND lwa_seltexts TO lit_seltexts.

  CLEAR lwa_seltexts.
  lwa_seltexts-name = 'P_OBJT'.
  lwa_seltexts-kind = 'P'.
  lwa_seltexts-text = 'Object Type'.
  APPEND lwa_seltexts TO lit_seltexts.

  CLEAR lwa_seltexts.
  lwa_seltexts-name = 'S_OBJN'.
  lwa_seltexts-kind = 'S'.
  lwa_seltexts-text = 'Object Name'.
  APPEND lwa_seltexts TO lit_seltexts.

  CLEAR lwa_seltexts.
  lwa_seltexts-name = 'P_DFILE'.
  lwa_seltexts-kind = 'P'.
  lwa_seltexts-text = 'Object Input File'.
  APPEND lwa_seltexts TO lit_seltexts.

  CLEAR lwa_seltexts.
  lwa_seltexts-name = 'P_DCHECK'.
  lwa_seltexts-kind = 'P'.
  lwa_seltexts-text = 'File has Header'.
  APPEND lwa_seltexts TO lit_seltexts.
*** EOC by Palani for CR 814 on 02/12/2021

  CLEAR lwa_seltexts.
  lwa_seltexts-name = 'P_SYNTAX'.
  lwa_seltexts-kind = 'P'.
  lwa_seltexts-text = 'Scan objects w/h syntax error'.
  APPEND lwa_seltexts TO lit_seltexts.

  CLEAR lwa_seltexts.
  lwa_seltexts-name = 'P_SYNLOG'.
  lwa_seltexts-kind = 'P'.
  lwa_seltexts-text = 'Add syntax errors in output'.
  APPEND lwa_seltexts TO lit_seltexts.

*BOC by Gunjan on 15/11/2019
  CLEAR lwa_seltexts.
  lwa_seltexts-name = 'P_THRESH'.
  lwa_seltexts-kind = 'P'.
  lwa_seltexts-text = 'Cutoff time(Hrs) BG_JOB Cancel'.
  APPEND lwa_seltexts TO lit_seltexts.
*EOC by Gunjan on 15/11/2019
*BOC by Gunjan on 23/2/2021 Defect 671
  CLEAR lwa_seltexts.
  lwa_seltexts-name = 'P_LOGDYN'.
  lwa_seltexts-kind = 'P'.
  lwa_seltexts-text = 'Log Dynamic creation/deletion'.
  APPEND lwa_seltexts TO lit_seltexts.
*EOC by Gunjan on 23/2/2021 Defect 671
  CLEAR lwa_seltexts.
  lwa_seltexts-name = 'S_PROG'.
  lwa_seltexts-kind = 'P'.
  lwa_seltexts-text = 'Object Name'.
  APPEND lwa_seltexts TO lit_seltexts.

  lwa_seltexts-name = 'P_SID'.
  lwa_seltexts-kind = 'P'.
  lwa_seltexts-text = 'Session ID'.
  APPEND lwa_seltexts TO lit_seltexts.

  CLEAR lwa_seltexts.
  lwa_seltexts-name = 'C_UPG2'.
  lwa_seltexts-kind = 'P'.
  lwa_seltexts-text = 'Upgrade'.
  APPEND lwa_seltexts TO lit_seltexts.

  CLEAR lwa_seltexts.
  lwa_seltexts-name = 'C_HANA2'.
  lwa_seltexts-kind = 'P'.
  lwa_seltexts-text = 'HANA DB Migration'.
  APPEND lwa_seltexts TO lit_seltexts.

  CLEAR lwa_seltexts.
  lwa_seltexts-name = 'C_CDS'.
  lwa_seltexts-kind = 'P'.
  lwa_seltexts-text = 'CDS_Creation'.
  APPEND lwa_seltexts TO lit_seltexts.

** Added by Pooja kalshetti
  CLEAR lwa_seltexts.
  lwa_seltexts-name = 'C_CLD2'.
  lwa_seltexts-kind = 'P'.
  lwa_seltexts-text = 'OS Migration'.
  APPEND lwa_seltexts TO lit_seltexts.

*  start ins dhiraj -14-01-2020
  CLEAR lwa_seltexts.
  lwa_seltexts-name = 'C_OCLD2'.
  lwa_seltexts-kind = 'P'.
  lwa_seltexts-text = 'OS Migration & Log. Path Remed.'.
  APPEND lwa_seltexts TO lit_seltexts.

  CLEAR lwa_seltexts.
  lwa_seltexts-name = 'C_LFR'.
  lwa_seltexts-kind = 'P'.
  lwa_seltexts-text = 'Logical File Remediation'.
  APPEND lwa_seltexts TO lit_seltexts.

  CLEAR lwa_seltexts.
  lwa_seltexts-name = 'P_LTR'.
  lwa_seltexts-kind = 'P'.
  lwa_seltexts-text = 'Transport Request'.
  APPEND lwa_seltexts TO lit_seltexts.

** BOC by Manisha for defect#518 on 05/01/2021
  CLEAR lwa_seltexts.
  lwa_seltexts-name = 'C_CLD_O'.
  lwa_seltexts-kind = 'P'.
  lwa_seltexts-text = 'Open Data Set Remediation'.
  APPEND lwa_seltexts TO lit_seltexts.
** EOC by Manisha for defect#518 on 05/01/2021

  CLEAR lwa_seltexts.
  lwa_seltexts-name = 'P_LFG'.
  lwa_seltexts-kind = 'P'.
  lwa_seltexts-text = 'Execute In Foreground'.
  APPEND lwa_seltexts TO lit_seltexts.

  CLEAR lwa_seltexts.
  lwa_seltexts-name = 'P_LBG'.
  lwa_seltexts-kind = 'P'.
  lwa_seltexts-text = 'Execute In Background'.
  APPEND lwa_seltexts TO lit_seltexts.

  CLEAR lwa_seltexts.
  lwa_seltexts-name = 'P_LFILE1'.
  lwa_seltexts-kind = 'P'.
  lwa_seltexts-text = 'File Path'.
  APPEND lwa_seltexts TO lit_seltexts.

  CLEAR lwa_seltexts.
  lwa_seltexts-name = 'P_LFILE2'.
  lwa_seltexts-kind = 'P'.
  lwa_seltexts-text = 'AL11 File Path'.
  APPEND lwa_seltexts TO lit_seltexts.

*  end ins Dhiraj -14-01-2020

****boc by shikha on 20/02/2020 for FCV/LCV.
  CLEAR lwa_seltexts.
  lwa_seltexts-name = 'FCV_A'.
  lwa_seltexts-kind = 'P'.
  lwa_seltexts-text = 'FCV Analysis'.
  APPEND lwa_seltexts TO lit_seltexts.

  CLEAR lwa_seltexts.
  lwa_seltexts-name = 'LCV_A'.
  lwa_seltexts-kind = 'P'.
  lwa_seltexts-text = 'LCV Analysis'.
  APPEND lwa_seltexts TO lit_seltexts.

  CLEAR lwa_seltexts.
  lwa_seltexts-name = 'P_RAD'.
  lwa_seltexts-kind = 'P'.
  lwa_seltexts-text = 'Pre-Conversion'.
  APPEND lwa_seltexts TO lit_seltexts.

  CLEAR lwa_seltexts.
  lwa_seltexts-name = 'P_RAD1'.
  lwa_seltexts-kind = 'P'.
  lwa_seltexts-text = 'Post-Conversion'.
  APPEND lwa_seltexts TO lit_seltexts.

  CLEAR lwa_seltexts.
  lwa_seltexts-name = 'P_RAD2'.
  lwa_seltexts-kind = 'P'.
  lwa_seltexts-text = 'Pre-Conversion'.
  APPEND lwa_seltexts TO lit_seltexts.

  CLEAR lwa_seltexts.
  lwa_seltexts-name = 'P_RAD3'.
  lwa_seltexts-kind = 'P'.
  lwa_seltexts-text = 'Post-Conversion'.
  APPEND lwa_seltexts TO lit_seltexts.

  CLEAR lwa_seltexts.
  lwa_seltexts-name = 'SO_KTOPL'.
  lwa_seltexts-kind = 'P'.
  lwa_seltexts-text = 'Chart of Accounts'.
  APPEND lwa_seltexts TO lit_seltexts.

  CLEAR lwa_seltexts.
  lwa_seltexts-name = 'SO_KOKRS'.
  lwa_seltexts-kind = 'P'.
  lwa_seltexts-text = 'Controlling Area'.
  APPEND lwa_seltexts TO lit_seltexts.

  CLEAR lwa_seltexts.
  lwa_seltexts-name = 'SO_BUKRS'.
  lwa_seltexts-kind = 'P'.
  lwa_seltexts-text = 'Company Code'.
  APPEND lwa_seltexts TO lit_seltexts.

  CLEAR lwa_seltexts.
  lwa_seltexts-name = 'SO_RLDNR'.
  lwa_seltexts-kind = 'P'.
  lwa_seltexts-text = 'Ledger'.
  APPEND lwa_seltexts TO lit_seltexts.

  CLEAR lwa_seltexts.
  lwa_seltexts-name = 'SO_GJAHR'.
  lwa_seltexts-kind = 'P'.
  lwa_seltexts-text = 'Fiscal Year'.
  APPEND lwa_seltexts TO lit_seltexts.

  CLEAR lwa_seltexts.
  lwa_seltexts-name = 'P_FROM'.
  lwa_seltexts-kind = 'P'.
  lwa_seltexts-text = 'From Period'.
  APPEND lwa_seltexts TO lit_seltexts.

  CLEAR lwa_seltexts.
  lwa_seltexts-name = 'P_TO'.
  lwa_seltexts-kind = 'P'.
  lwa_seltexts-text = 'To Period'.
  APPEND lwa_seltexts TO lit_seltexts.

  CLEAR lwa_seltexts.
  lwa_seltexts-name = 'S_RAD'.
  lwa_seltexts-kind = 'P'.
  lwa_seltexts-text = 'Clear Data'.
  APPEND lwa_seltexts TO lit_seltexts.

  CLEAR lwa_seltexts.
  lwa_seltexts-name = 'S_RAD1'.
  lwa_seltexts-kind = 'P'.
  lwa_seltexts-text = 'Clear Data'.
  APPEND lwa_seltexts TO lit_seltexts.

  CLEAR lwa_seltexts.
  lwa_seltexts-name = 'S_BUKRS'.
  lwa_seltexts-kind = 'P'.
  lwa_seltexts-text = 'Company Code'.
  APPEND lwa_seltexts TO lit_seltexts.

  CLEAR lwa_seltexts.
  lwa_seltexts-name = 'S_WERKS'.
  lwa_seltexts-kind = 'P'.
  lwa_seltexts-text = 'Plant'.
  APPEND lwa_seltexts TO lit_seltexts.

  CLEAR lwa_seltexts.
  lwa_seltexts-name = 'S_EKORG'.
  lwa_seltexts-kind = 'P'.
  lwa_seltexts-text = 'Purchasing Organization'.
  APPEND lwa_seltexts TO lit_seltexts.

  CLEAR lwa_seltexts.
  lwa_seltexts-name = 'S_VKORG'.
  lwa_seltexts-kind = 'P'.
  lwa_seltexts-text = 'Sales Organization'.
  APPEND lwa_seltexts TO lit_seltexts.

  CLEAR lwa_seltexts.
  lwa_seltexts-name = 'FCV_I'.
  lwa_seltexts-kind = 'P'.
  lwa_seltexts-text = 'Process Immediately'.
  APPEND lwa_seltexts TO lit_seltexts.

  CLEAR lwa_seltexts.
  lwa_seltexts-name = 'FCV_B'.
  lwa_seltexts-kind = 'P'.
  lwa_seltexts-text = 'Process in Background'.
  APPEND lwa_seltexts TO lit_seltexts.

****eoc by shikha on 20/02/2020 for FCV/LCV.

  CLEAR lwa_seltexts.
  lwa_seltexts-name = 'C_S42'.
  lwa_seltexts-kind = 'P'.
  lwa_seltexts-text = 'Simplification Technical'.
  APPEND lwa_seltexts TO lit_seltexts.

  CLEAR lwa_seltexts.
  lwa_seltexts-name = 'C_BG_JOB'.
  lwa_seltexts-kind = 'P'.
  lwa_seltexts-text = 'Schedule in background'.
  APPEND lwa_seltexts TO lit_seltexts.

  CLEAR lwa_seltexts.
  lwa_seltexts-name = 'C_SYNTAX'.
  lwa_seltexts-kind = 'P'.
  lwa_seltexts-text = 'Correct objcts w/h syntax errs'.
  APPEND lwa_seltexts TO lit_seltexts.

  CLEAR lwa_seltexts.
  lwa_seltexts-name = 'C_MODLOG'.
  lwa_seltexts-kind = 'P'.
  lwa_seltexts-text = 'Use custom'.
  APPEND lwa_seltexts TO lit_seltexts.

  CLEAR lwa_seltexts.
  lwa_seltexts-name = 'P_LINE1'.
  lwa_seltexts-kind = 'P'.
  lwa_seltexts-text = 'Line 1'.
  APPEND lwa_seltexts TO lit_seltexts.

  CLEAR lwa_seltexts.
  lwa_seltexts-name = 'P_LINE2'.
  lwa_seltexts-kind = 'P'.
  lwa_seltexts-text = 'Line 2'.
  APPEND lwa_seltexts TO lit_seltexts.

  CLEAR lwa_seltexts.
  lwa_seltexts-name = 'P_LINE3'.
  lwa_seltexts-kind = 'P'.
  lwa_seltexts-text = 'Line 3'.
  APPEND lwa_seltexts TO lit_seltexts.

  CLEAR lwa_seltexts.
  lwa_seltexts-name = 'P_LINE4'.
  lwa_seltexts-kind = 'P'.
  lwa_seltexts-text = 'Line 4'.
  APPEND lwa_seltexts TO lit_seltexts.

  CLEAR lwa_seltexts.
  lwa_seltexts-name = 'P_LINE5'.
  lwa_seltexts-kind = 'P'.
  lwa_seltexts-text = 'Line 5'.
  APPEND lwa_seltexts TO lit_seltexts.

  CLEAR lwa_seltexts.
  lwa_seltexts-name = 'P_LINE6'.
  lwa_seltexts-kind = 'P'.
  lwa_seltexts-text = 'Line 6'.
  APPEND lwa_seltexts TO lit_seltexts.

  CLEAR lwa_seltexts.
  lwa_seltexts-name = 'P_LINE7'.
  lwa_seltexts-kind = 'P'.
  lwa_seltexts-text = 'Line 7'.
  APPEND lwa_seltexts TO lit_seltexts.

  CLEAR lwa_seltexts.
  lwa_seltexts-name = 'P_LINE8'.
  lwa_seltexts-kind = 'P'.
  lwa_seltexts-text = 'Line 8'.
  APPEND lwa_seltexts TO lit_seltexts.

  CLEAR lwa_seltexts.
  lwa_seltexts-name = 'P_LINE9'.
  lwa_seltexts-kind = 'P'.
  lwa_seltexts-text = 'Inline Start1'.
  APPEND lwa_seltexts TO lit_seltexts.
*****  BOC BY PARUL PURI FOR DEFECT ID - 532
  CLEAR lwa_seltexts.
  lwa_seltexts-name = 'P_LINE10'.
  lwa_seltexts-kind = 'P'.
  lwa_seltexts-text = 'Inline Start2'.
  APPEND lwa_seltexts TO lit_seltexts.
*****  EOC BY PARUL PURI FOR DEFECT ID - 532
  CLEAR lwa_seltexts.
  lwa_seltexts-name = 'P_LINE11'.
  lwa_seltexts-kind = 'P'.
  lwa_seltexts-text = 'Inline End1'.
  APPEND lwa_seltexts TO lit_seltexts.
*****  BOC BY PARUL PURI FOR DEFECT ID - 532
  CLEAR lwa_seltexts.
  lwa_seltexts-name = 'P_LINE12'.
  lwa_seltexts-kind = 'P'.
  lwa_seltexts-text = 'Inline End2'.
  APPEND lwa_seltexts TO lit_seltexts.
*****  EOC BY PARUL PURI FOR DEFECT ID - 532
  CLEAR lwa_seltexts.
  lwa_seltexts-name = 'P_XT1'.
  lwa_seltexts-kind = 'P'.
  lwa_seltexts-text = 'Impacted Search Helps'.
  APPEND lwa_seltexts TO lit_seltexts.

  CLEAR lwa_seltexts.
  lwa_seltexts-name = 'P_XT2'.
  lwa_seltexts-kind = 'P'.
  lwa_seltexts-text = 'Usage Analysis'.
  APPEND lwa_seltexts TO lit_seltexts.

  CLEAR lwa_seltexts.
  lwa_seltexts-name = 'P_XT3'.
  lwa_seltexts-kind = 'P'.
  lwa_seltexts-text = 'Clone Analysis'.
  APPEND lwa_seltexts TO lit_seltexts.

  CLEAR lwa_seltexts.
  lwa_seltexts-name = 'P_XT4'.
  lwa_seltexts-kind = 'P'.
  lwa_seltexts-text = 'Impacted IDocs'.
  APPEND lwa_seltexts TO lit_seltexts.

  CLEAR lwa_seltexts.
  lwa_seltexts-name = 'P_XT5'.
  lwa_seltexts-kind = 'P'.
  lwa_seltexts-text = 'Impacted Tables'.
  APPEND lwa_seltexts TO lit_seltexts.

  CLEAR lwa_seltexts.
  lwa_seltexts-name = 'P_XT6'.
  lwa_seltexts-kind = 'P'.
  lwa_seltexts-text = 'Impacted BADIs'.
  APPEND lwa_seltexts TO lit_seltexts.

  CLEAR lwa_seltexts.
  lwa_seltexts-name = 'P_XT7'.
  lwa_seltexts-kind = 'P'.
  lwa_seltexts-text = 'Find Enhancements'.
  APPEND lwa_seltexts TO lit_seltexts.

  CLEAR lwa_seltexts.
  lwa_seltexts-name = 'P_XT8'.
  lwa_seltexts-kind = 'P'.
  lwa_seltexts-text = 'CHDOC'.
  APPEND lwa_seltexts TO lit_seltexts.

  CLEAR lwa_seltexts.
  lwa_seltexts-name = 'P_XT9'.
  lwa_seltexts-kind = 'P'.
  lwa_seltexts-text = 'SMODILOG'.
  APPEND lwa_seltexts TO lit_seltexts.

  "BOC by PSR on 22nd Jan 2020 for inconsistent FM

  CLEAR lwa_seltexts.
  lwa_seltexts-name = 'P_XT11'.
  lwa_seltexts-kind = 'P'.
  lwa_seltexts-text = 'Inconsistent FUGR'.
  APPEND lwa_seltexts TO lit_seltexts.

  "EOC by PSR for inconsistent FM

  "BOC by PSR on 18th Feb 2020 for Clone Analysis

  CLEAR lwa_seltexts.
  lwa_seltexts-name = 'P_XT12'.
  lwa_seltexts-kind = 'P'.
  lwa_seltexts-text = 'Clone Analysis'.
  APPEND lwa_seltexts TO lit_seltexts.

  "EOC by PSR for new clone analysis

  "BOC by PSR on 18th Mar 2020 for CVIT

  CLEAR lwa_seltexts.
  lwa_seltexts-name = 'P_XT13'.
  lwa_seltexts-kind = 'P'.
  lwa_seltexts-text = 'CVIT Report'.
  APPEND lwa_seltexts TO lit_seltexts.

  CLEAR lwa_seltexts.
  lwa_seltexts-name = 'P_XT14'.
  lwa_seltexts-kind = 'P'.
  lwa_seltexts-text = 'Number Range Report'.
  APPEND lwa_seltexts TO lit_seltexts.
  "EOC by PSR for new CVIT

* BOC Added by Rahul Defect#285
  CLEAR lwa_seltexts.
  lwa_seltexts-name = 'P_XT15'.
  lwa_seltexts-kind = 'P'.
  lwa_seltexts-text = 'Testing Scope'.
  APPEND lwa_seltexts TO lit_seltexts.
  "EOC by PSR for new CVIT
  CLEAR lwa_seltexts.
  lwa_seltexts-name = 'R_CUST'.
  lwa_seltexts-kind = 'P'.
  lwa_seltexts-text = 'Custom Object'.
  APPEND lwa_seltexts TO lit_seltexts.

  CLEAR lwa_seltexts.
  lwa_seltexts-name = 'R_STD'.
  lwa_seltexts-kind = 'P'.
  lwa_seltexts-text = 'Standard Object'.
  APPEND lwa_seltexts TO lit_seltexts.

*  BOC Added by Rahul Defect#320 07/21/2020
  CLEAR lwa_seltexts.
  lwa_seltexts-name = 'R_MAN'.
  lwa_seltexts-kind = 'P'.
  lwa_seltexts-text = 'TSCOPE (Manual)'.
  APPEND lwa_seltexts TO lit_seltexts.

  CLEAR lwa_seltexts.
  lwa_seltexts-name = 'FILE_INV'.
  lwa_seltexts-kind = 'P'.
*  lwa_seltexts-text = 'Detection File'." Commented by Priyansh Srivastava. Wrong text. Should be Inventory File
  lwa_seltexts-text = 'Inventory File'." Added by Priyansh Srivastava
  APPEND lwa_seltexts TO lit_seltexts.
***** BOC PARUL PURI FOR DEFECT ID - 556
  CLEAR lwa_seltexts.
  lwa_seltexts-name = 'R_INVE'.
  lwa_seltexts-kind = 'P'.
*  lwa_seltexts-text = 'Detection Objects'." Commented by Priyansh Srivastava. Wrong text. Should be Inventory Objects
  lwa_seltexts-text = 'Inventory Objects'."Added by Priyansh Srivastava
  APPEND lwa_seltexts TO lit_seltexts.

  CLEAR lwa_seltexts.
  lwa_seltexts-name = 'R_SMOD'.
  lwa_seltexts-kind = 'P'.
  lwa_seltexts-text = 'SMODILOG Objects'.
  APPEND lwa_seltexts TO lit_seltexts.
***** EOC PARUL PURI FOR DEFECT ID - 556
*  CLEAR lwa_seltexts.
*  lwa_seltexts-name = 'P_MANF'.
*  lwa_seltexts-kind = 'P'.
*  lwa_seltexts-text = 'Output File (.TXT File only)'.
*  APPEND lwa_seltexts TO lit_seltexts.

*  EOC by Rahul Defect#320 07/21/2020

* BOC by Shivani, BW cleanup, 24.08.2020
  CLEAR lwa_seltexts.
  lwa_seltexts-name = 'P_XT16'.
  lwa_seltexts-kind = 'P'.
  lwa_seltexts-text = 'BW Usage Analysis Report'.
  APPEND lwa_seltexts TO lit_seltexts.

  CLEAR lwa_seltexts.
  lwa_seltexts-name = 'P_INA'.
  lwa_seltexts-kind = 'P'.
  lwa_seltexts-text = 'Inactive Objects'.
  APPEND lwa_seltexts TO lit_seltexts.

  CLEAR lwa_seltexts.
  lwa_seltexts-name = 'P_USG'.
  lwa_seltexts-kind = 'P'.
  lwa_seltexts-text = 'Usage Analysis'.
  APPEND lwa_seltexts TO lit_seltexts.

  CLEAR lwa_seltexts.
  lwa_seltexts-name = 'P_BEX'.
  lwa_seltexts-kind = 'P'.
  lwa_seltexts-text = 'BEx Query'.
  APPEND lwa_seltexts TO lit_seltexts.

  CLEAR lwa_seltexts.
  lwa_seltexts-name = 'P_DTP'.
  lwa_seltexts-kind = 'P'.
  lwa_seltexts-text = 'DTP'.
  APPEND lwa_seltexts TO lit_seltexts.

  CLEAR lwa_seltexts.
  lwa_seltexts-name = 'P_TRAN'.
  lwa_seltexts-kind = 'P'.
  lwa_seltexts-text = 'Transformations'.
  APPEND lwa_seltexts TO lit_seltexts.

  CLEAR lwa_seltexts.
  lwa_seltexts-name = 'P_PROC'.
  lwa_seltexts-kind = 'P'.
  lwa_seltexts-text = 'Process Chain'.
  APPEND lwa_seltexts TO lit_seltexts.

  CLEAR lwa_seltexts.
  lwa_seltexts-name = 'P_APD'.
  lwa_seltexts-kind = 'P'.
  lwa_seltexts-text = 'APD'.
  APPEND lwa_seltexts TO lit_seltexts.

  CLEAR lwa_seltexts.
  lwa_seltexts-name = 'P_OHD'.
  lwa_seltexts-kind = 'P'.
  lwa_seltexts-text = 'Open Hub Destination'.
  APPEND lwa_seltexts TO lit_seltexts.

  CLEAR lwa_seltexts.
  lwa_seltexts-name = 'P_DSO'.
  lwa_seltexts-kind = 'P'.
  lwa_seltexts-text = 'DSO/ICUBE'.
  APPEND lwa_seltexts TO lit_seltexts.

  CLEAR lwa_seltexts.
  lwa_seltexts-name = 'P_WBK'.
  lwa_seltexts-kind = 'P'.
  lwa_seltexts-text = 'Workbook'.
  APPEND lwa_seltexts TO lit_seltexts.

  CLEAR lwa_seltexts.
  lwa_seltexts-name = 'P_WBT'.
  lwa_seltexts-kind = 'P'.
  lwa_seltexts-text = 'Web Template'.
  APPEND lwa_seltexts TO lit_seltexts.

  CLEAR lwa_seltexts.
  lwa_seltexts-name = 'P_ALL'.
  lwa_seltexts-kind = 'P'.
  lwa_seltexts-text = 'All Objects'.
  APPEND lwa_seltexts TO lit_seltexts.

  CLEAR lwa_seltexts.
  lwa_seltexts-name = 'P_FL_BW'.
  lwa_seltexts-kind = 'P'.
  lwa_seltexts-text = 'Output File (.txt format only)'.
  APPEND lwa_seltexts TO lit_seltexts.
* EOC by Shivani, BW cleanup, 24.08.2020

  CLEAR lwa_seltexts.
  lwa_seltexts-name = 'S_ONAME'.
  lwa_seltexts-kind = 'S'.
  lwa_seltexts-text = 'Object Name'.
  APPEND lwa_seltexts TO lit_seltexts.


  CLEAR lwa_seltexts.
  lwa_seltexts-name = 'R_DET'.
  lwa_seltexts-kind = 'P'.
  lwa_seltexts-text = 'Object From Detection'.
  APPEND lwa_seltexts TO lit_seltexts.

  CLEAR lwa_seltexts.
  lwa_seltexts-name = 'R_OBJ'.
  lwa_seltexts-kind = 'P'.
  lwa_seltexts-text = 'Custom Object'.
  APPEND lwa_seltexts TO lit_seltexts.
* EOC Added by Rahul Defect#285

  CLEAR lwa_seltexts.
  lwa_seltexts-name = 'SHLP'.
  lwa_seltexts-kind = 'P'.
  lwa_seltexts-text = 'Search Helps'.
  APPEND lwa_seltexts TO lit_seltexts.

  CLEAR lwa_seltexts.
  lwa_seltexts-name = 'S_OBNAME'.
  lwa_seltexts-kind = 'P'.
  lwa_seltexts-text = 'Object Name(s)'.
  APPEND lwa_seltexts TO lit_seltexts.

  CLEAR lwa_seltexts.
  lwa_seltexts-name = 'S_ST03'.
  lwa_seltexts-kind = 'P'.
  lwa_seltexts-text = 'ST03 Data'.
  APPEND lwa_seltexts TO lit_seltexts.

* BOC by Vani on 13/04/2020
  CLEAR lwa_seltexts.
  lwa_seltexts-name = 'P_SCMON'.
  lwa_seltexts-kind = 'P'.
  lwa_seltexts-text = 'SCMON Data'.
  APPEND lwa_seltexts TO lit_seltexts.
* EOC by Vani on 13/04/2020

* BOC by Shivani on 04.08.2020
  CLEAR lwa_seltexts.
  lwa_seltexts-name = 'P_FILE_O'.
  lwa_seltexts-kind = 'P'.
  lwa_seltexts-text = 'ST03 Output File'.
  APPEND lwa_seltexts TO lit_seltexts.
* EOC by Shivani on 04.08.2020

  CLEAR lwa_seltexts.
  lwa_seltexts-name = 'N_SPACE'.
  lwa_seltexts-kind = 'P'.
  lwa_seltexts-text = 'Customer Namespace(s)'.
  APPEND lwa_seltexts TO lit_seltexts.

  CLEAR lwa_seltexts.
  lwa_seltexts-name = 'P_FILE'.
  lwa_seltexts-kind = 'P'.
  lwa_seltexts-text = 'Path to output file'.
  APPEND lwa_seltexts TO lit_seltexts.

  CLEAR lwa_seltexts.
  lwa_seltexts-name = 'P_FILE2'.
  lwa_seltexts-kind = 'P'.
  lwa_seltexts-text = 'Path to input file'.
  APPEND lwa_seltexts TO lit_seltexts.

*Added by Gunjan for impacted tables output File on 13/2/2020
*   CLEAR lwa_seltexts.
*  lwa_seltexts-name = 'LV_FILE'.
*  lwa_seltexts-kind = 'P'.
*  lwa_seltexts-text = 'Output File (ApplServ)'.
*  APPEND lwa_seltexts TO lit_seltexts.

  CLEAR lwa_seltexts.
  lwa_seltexts-name = 'S_DEF'.
  lwa_seltexts-kind = 'P'.
  lwa_seltexts-text = 'BADI Definition(s)'.
  APPEND lwa_seltexts TO lit_seltexts.

  CLEAR lwa_seltexts.
  lwa_seltexts-name = 'S_IMP'.
  lwa_seltexts-kind = 'P'.
  lwa_seltexts-text = 'BADI Implementation(s)'.
  APPEND lwa_seltexts TO lit_seltexts.

  CLEAR lwa_seltexts.
  lwa_seltexts-name = 'C_UI5'.
  lwa_seltexts-kind = 'P'.
  lwa_seltexts-text = 'UI5 Extractor'.
  APPEND lwa_seltexts TO lit_seltexts.

  CLEAR lwa_seltexts.
  lwa_seltexts-name = 'P_RFC2'.
  lwa_seltexts-kind = 'P'.
  lwa_seltexts-text = 'RFC Name'.
  APPEND lwa_seltexts TO lit_seltexts.

  CLEAR lwa_seltexts.
  lwa_seltexts-name = 'S_UI5NS'.
  lwa_seltexts-kind = 'S'.
  lwa_seltexts-text = 'Name Space(s)'.
  APPEND lwa_seltexts TO lit_seltexts.

  CLEAR lwa_seltexts.
  lwa_seltexts-name = 'S_APPN'.
  lwa_seltexts-kind = 'S'.
  lwa_seltexts-text = 'UI5 Application name'.
  APPEND lwa_seltexts TO lit_seltexts.

*START OF CHANGE BY MANYA DADARYA ON 10.01.2019
  CLEAR lwa_seltexts.
  lwa_seltexts-name = 'C_SE95'.
  lwa_seltexts-kind = 'P'.
  lwa_seltexts-text = 'SE95 for Standard'.
  APPEND lwa_seltexts TO lit_seltexts.
*END OF CHANGE BY MANYA DADARYA ON 10.01.2019

*START OF CHANGE BY MANYA DADARYA ON 06.03.2020
  CLEAR lwa_seltexts.
  lwa_seltexts-name = 'C_BW_RUN'.
  lwa_seltexts-kind = 'P'.
  lwa_seltexts-text = 'To Include BW Objects'.
  APPEND lwa_seltexts TO lit_seltexts.
*END OF CHANGE BY MANYA DADARYA ON 06.03.2020

*START OF CHANGE BY POOJA KALSHETTI ON 11.02.2019
  CLEAR lwa_seltexts.
  lwa_seltexts-name = 'C_CLOUD'.
  lwa_seltexts-kind = 'P'.
  lwa_seltexts-text = 'OS Migration'.
  APPEND lwa_seltexts TO lit_seltexts.

*  start ins dhiraj 31/03/2020
  CLEAR lwa_seltexts.
  lwa_seltexts-name = 'C_LOGPAT'.
  lwa_seltexts-kind = 'P'.
  lwa_seltexts-text = 'Logical File path'.
  APPEND lwa_seltexts TO lit_seltexts.

  CLEAR lwa_seltexts.
  lwa_seltexts-name = 'C_LOGCMD'.
  lwa_seltexts-kind = 'P'.
  lwa_seltexts-text = 'Logical Command'.
  APPEND lwa_seltexts TO lit_seltexts.
* end ins Dhiraj 31/03/2020
  CLEAR lwa_seltexts.
  lwa_seltexts-name = 'P_SRC1'.
  lwa_seltexts-kind = 'P'.
  lwa_seltexts-text = 'Source OS'.
  APPEND lwa_seltexts TO lit_seltexts.
  CLEAR lwa_seltexts.
  lwa_seltexts-name = 'P_TRG1'.
  lwa_seltexts-kind = 'P'.
  lwa_seltexts-text = 'Target OS'.
  APPEND lwa_seltexts TO lit_seltexts.

  CLEAR lwa_seltexts.
  lwa_seltexts-name = 'P_FILE1'.
  lwa_seltexts-kind = 'P'.
  lwa_seltexts-text = 'File Path'.
  APPEND lwa_seltexts TO lit_seltexts.
  " S4 other utilities
*  CLEAR lwa_seltexts.
  lwa_seltexts-name = 'P_XT10'.
  lwa_seltexts-kind = 'P'.
  lwa_seltexts-text = 'Impacted Batchjobs'.
  APPEND lwa_seltexts TO lit_seltexts.

*  CLEAR lwa_seltexts. " COMMENTED BY PARUL ON 03/02/2020.
*  lwa_seltexts-name = 'P_DATE'.
*  lwa_seltexts-kind = 'S'.
*  lwa_seltexts-text = 'Date'.
*  APPEND lwa_seltexts TO lit_seltexts.

  CLEAR lwa_seltexts.
  lwa_seltexts-name = 'S_ID'.
  lwa_seltexts-kind = 'P'.
  lwa_seltexts-text = 'Session Id'.
  APPEND lwa_seltexts TO lit_seltexts.

*  BOC By Gunjan on 02/01/2020
  CLEAR lwa_seltexts.
  lwa_seltexts-name = 'P_TBTCP'.
  lwa_seltexts-kind = 'P'.
  lwa_seltexts-text = 'TBTCP filepath(.csv)'.
  APPEND lwa_seltexts TO lit_seltexts.

  CLEAR lwa_seltexts.
  lwa_seltexts-name = 'P_TBTCO'.
  lwa_seltexts-kind = 'P'.
  lwa_seltexts-text = 'TBTCO filepath(.csv)'.
  APPEND lwa_seltexts TO lit_seltexts.
*  EOC By Gunjan on 02/01/2020

  CLEAR lwa_seltexts.
  lwa_seltexts-name = 'P_FL_XT8'.
  lwa_seltexts-kind = 'P'.
  lwa_seltexts-text = 'Filepath(Output(.txt))'.
  APPEND lwa_seltexts TO lit_seltexts.

  CLEAR lwa_seltexts.
  lwa_seltexts-name = 'N_SP_XT9'.
  lwa_seltexts-kind = 'P'.
  lwa_seltexts-text = 'Namespace'.
  APPEND lwa_seltexts TO lit_seltexts.

  CLEAR lwa_seltexts.
  lwa_seltexts-name = 'P_SMOD'.
  lwa_seltexts-kind = 'P'.
  lwa_seltexts-text = 'Filepath(Output(.xls))'.
  APPEND lwa_seltexts TO lit_seltexts.

*BOC By Gunjan for Variant Utility on 12/10/2020 CR 433
  CLEAR lwa_seltexts.
  lwa_seltexts-name = 'P_XT17'.
  lwa_seltexts-kind = 'P'.
  lwa_seltexts-text = 'Search Variant'.
  APPEND lwa_seltexts TO lit_seltexts.

  CLEAR lwa_seltexts.
  lwa_seltexts-name = 'P_GET'.
  lwa_seltexts-kind = 'P'.
  lwa_seltexts-text = 'Get variant'.
  APPEND lwa_seltexts TO lit_seltexts.

  CLEAR lwa_seltexts.
  lwa_seltexts-name = 'P_UPD'.
  lwa_seltexts-kind = 'P'.
  lwa_seltexts-text = 'Update variant'.
  APPEND lwa_seltexts TO lit_seltexts.


  CLEAR lwa_seltexts.
  lwa_seltexts-name = 'P_SMP'.
  lwa_seltexts-kind = 'P'.
  lwa_seltexts-text = 'Download Sample file'.
  APPEND lwa_seltexts TO lit_seltexts.

  CLEAR lwa_seltexts.
  lwa_seltexts-name = 'P_INS'.
  lwa_seltexts-kind = 'P'.
  lwa_seltexts-text = 'Insert Variant'.
  APPEND lwa_seltexts TO lit_seltexts.

  CLEAR lwa_seltexts.
  lwa_seltexts-name = 'P_UPLD'.
  lwa_seltexts-kind = 'P'.
  lwa_seltexts-text = 'Update Variant'.
  APPEND lwa_seltexts TO lit_seltexts.

  CLEAR lwa_seltexts.
  lwa_seltexts-name = 'P_DEL'.
  lwa_seltexts-kind = 'P'.
  lwa_seltexts-text = 'Delete Variant'.
  APPEND lwa_seltexts TO lit_seltexts.

  CLEAR lwa_seltexts.
  lwa_seltexts-name = 'P_STR'.
  lwa_seltexts-kind = 'P'.
  lwa_seltexts-text = 'Search For String'.
  APPEND lwa_seltexts TO lit_seltexts.

  CLEAR lwa_seltexts.
  lwa_seltexts-name = 'P_PRO'.
  lwa_seltexts-kind = 'P'.
  lwa_seltexts-text = 'Enter Program name'.
  APPEND lwa_seltexts TO lit_seltexts.

  CLEAR lwa_seltexts.
  lwa_seltexts-name = 'P_UPL'.
  lwa_seltexts-kind = 'P'.
  lwa_seltexts-text = 'Upload Excel File'.
  APPEND lwa_seltexts TO lit_seltexts.

  CLEAR lwa_seltexts.
  lwa_seltexts-name = 'S_PROGV'.
  lwa_seltexts-kind = 'S'.
  lwa_seltexts-text = 'Program Name'.
  APPEND lwa_seltexts TO lit_seltexts.

  CLEAR lwa_seltexts.
  lwa_seltexts-name = 'P_FILEUP'.
  lwa_seltexts-kind = 'P'.
  lwa_seltexts-text = 'File Path (Upload)'.
  APPEND lwa_seltexts TO lit_seltexts.

  CLEAR lwa_seltexts.
  lwa_seltexts-name = 'P_ALV'.
  lwa_seltexts-kind = 'P'.
  lwa_seltexts-text =  'ALV'.
  APPEND lwa_seltexts TO lit_seltexts.

  CLEAR lwa_seltexts.
  lwa_seltexts-name = 'P_EXCEL'.
  lwa_seltexts-kind = 'P'.
  lwa_seltexts-text = 'Download File'.
  APPEND lwa_seltexts TO lit_seltexts.

  CLEAR lwa_seltexts.
  lwa_seltexts-name = 'P_FG'.
  lwa_seltexts-kind = 'P'.
  lwa_seltexts-text =  'Presentation Server'.
  APPEND lwa_seltexts TO lit_seltexts.

  CLEAR lwa_seltexts.
  lwa_seltexts-name = 'P_BG'.
  lwa_seltexts-kind = 'P'.
  lwa_seltexts-text = 'Application Server'.
  APPEND lwa_seltexts TO lit_seltexts.

  CLEAR lwa_seltexts.
  lwa_seltexts-name = 'V_FILE'.
  lwa_seltexts-kind = 'P'.
  lwa_seltexts-text = 'File Path (Download)'.
  APPEND lwa_seltexts TO lit_seltexts.
*EOC By Gunjan for Variant Utility on 12/10/2020 CR 433
*   CLEAR lwa_seltexts.
*  lwa_seltexts-name = 'P_F2_X1'.
*  lwa_seltexts-kind = 'P'.
*  lwa_seltexts-text = 'TBTCO File path'.
*  APPEND lwa_seltexts TO lit_seltexts.


  APPEND lwa_seltexts TO lit_seltexts.

*END OF CHANGE BY POOJA KALSHETTI ON 11.02.2019
*BOC By Rahul Variant Utility on 11/25/2020 CR 140
  CLEAR lwa_seltexts.
  lwa_seltexts-name = 'P_XT18'.
  lwa_seltexts-kind = 'P'.
  lwa_seltexts-text = 'Impacted Variant'.
  APPEND lwa_seltexts TO lit_seltexts.


  CLEAR lwa_seltexts.
  lwa_seltexts-name = 'N_SP_18'.
  lwa_seltexts-kind = 'P'.
  lwa_seltexts-text = 'Namespace'.
  APPEND lwa_seltexts TO lit_seltexts.
*EOC By Rahul Variant Utility on 11/25/2020 CR 140

*BOC by Jeba DrilLDown Report on 15.12.2020 CR 131
  CLEAR lwa_seltexts.
  lwa_seltexts-name = 'P_XT19'.
  lwa_seltexts-kind = 'P'.
  lwa_seltexts-text = 'Impacted DrillDown Report'.
  APPEND lwa_seltexts TO lit_seltexts.
*EOC by Jeba DrilLDown Report on 15.12.2020 CR 131

  " Version comp - Start here
  CLEAR lwa_seltexts.
  lwa_seltexts-name = 'P_XT20'.
  lwa_seltexts-kind = 'P'.
  lwa_seltexts-text = 'Version comparision'.
  APPEND lwa_seltexts TO lit_seltexts.

  CLEAR lwa_seltexts.
  lwa_seltexts-name = 'S_NAM2'.
  lwa_seltexts-kind = 'S'.
  lwa_seltexts-text = 'Object Name'.
  APPEND lwa_seltexts TO lit_seltexts.

  CLEAR lwa_seltexts.
  lwa_seltexts-name = 'P_VAR_ID'.
  lwa_seltexts-kind = 'S'.
  lwa_seltexts-text = 'Variant id input'.
  APPEND lwa_seltexts TO lit_seltexts.

  CLEAR lwa_seltexts.
  lwa_seltexts-name = 'P_VAR'.
  lwa_seltexts-kind = 'S'.
  lwa_seltexts-text = 'Variant ID'.
  APPEND lwa_seltexts TO lit_seltexts.
  "BOC by nancy for version comp 950 version number with variable Id checkbox


  CLEAR lwa_seltexts.
  lwa_seltexts-name = 'P_OBJ'.
  lwa_seltexts-kind = 'S'.
  lwa_seltexts-text = 'Objectwise input'.
  APPEND lwa_seltexts TO lit_seltexts.

  CLEAR lwa_seltexts.
  lwa_seltexts-name = 'S_OBJ2'.
  lwa_seltexts-kind = 'S'.
  lwa_seltexts-text = 'Object Type'.
  APPEND lwa_seltexts TO lit_seltexts.

  CLEAR lwa_seltexts.
  lwa_seltexts-name = 'S_RFC2'.
  lwa_seltexts-kind = 'S'.
  lwa_seltexts-text = 'RFC destination'.
  APPEND lwa_seltexts TO lit_seltexts.

  CLEAR lwa_seltexts.
  lwa_seltexts-name = 'P_VNUM'.
  lwa_seltexts-kind = 'S'.
  lwa_seltexts-text = 'Version Number'.
  APPEND lwa_seltexts TO lit_seltexts.

  CLEAR lwa_seltexts.
  lwa_seltexts-name = 'P_SERV1'.
  lwa_seltexts-kind = 'S'.
  lwa_seltexts-text = 'Server'.
  APPEND lwa_seltexts TO lit_seltexts.

  lwa_seltexts-name = 'P_SERV2'.
  lwa_seltexts-kind = 'S'.
  lwa_seltexts-text = 'Server to be excluded'.
  APPEND lwa_seltexts TO lit_seltexts.


  "BOC by nancy for version comp version nuber with object checkbox
  CLEAR lwa_seltexts.
  lwa_seltexts-name = 'P_VERNUM'.
  lwa_seltexts-kind = 'S'.
  lwa_seltexts-text = 'Version Number'.
  APPEND lwa_seltexts TO lit_seltexts.

* BOC BY SONAL FOR DEFECT #614
  CLEAR lwa_seltexts.
  lwa_seltexts-name = 'P_HCODE'.
  lwa_seltexts-kind = 'P'.
  lwa_seltexts-text = 'Hardcoded Values and System ID'.
  APPEND lwa_seltexts TO lit_seltexts.
* BOC BY SONAL FOR DEFECT #614

  " Version comp - END here
*****  BOC BY PARUL PURI DEFECT ID - 627
  CLEAR lwa_seltexts.
  lwa_seltexts-name = 'P_XT21'.
  lwa_seltexts-kind = 'P'.
  lwa_seltexts-text = 'Tables -> VIEW or CDS'.
  APPEND lwa_seltexts TO lit_seltexts.

  CLEAR lwa_seltexts.
  lwa_seltexts-name = 'P_FILE10'.
  lwa_seltexts-kind = 'P'.
  lwa_seltexts-text = 'Please upload Input File(.txt)'.
  APPEND lwa_seltexts TO lit_seltexts.
*****  EOC BY PARUL PURI DEFECT ID - 627

**** BOC by vaishnavi for cr 830
  CLEAR lwa_seltexts.
  lwa_seltexts-name = 'P_GEN'.
  lwa_seltexts-kind = 'P'.
  lwa_seltexts-text = 'Infoset Regeneration'.
  APPEND lwa_seltexts TO lit_seltexts.
**** EOC by vaishnavi for cr 830


*** BOC by Palani for CR 881 on 14/10/2021
  CLEAR lwa_seltexts.
  lwa_seltexts-name = 'P_QUERY'.
  lwa_seltexts-kind = 'P'.
  lwa_seltexts-text = 'ABAP Query'.
  APPEND lwa_seltexts TO lit_seltexts.

  CLEAR lwa_seltexts.
  lwa_seltexts-name = 'P_QINV'.
  lwa_seltexts-kind = 'P'.
  lwa_seltexts-text = 'Inventory Collection'.
  APPEND lwa_seltexts TO lit_seltexts.

  CLEAR lwa_seltexts.
  lwa_seltexts-name = 'P_QDET'.
  lwa_seltexts-kind = 'P'.
  lwa_seltexts-text = 'Detection'.
  APPEND lwa_seltexts TO lit_seltexts.

  CLEAR lwa_seltexts.
  lwa_seltexts-name = 'P_QVAR1'.
  lwa_seltexts-kind = 'P'.
  lwa_seltexts-text = 'Variant ID'.
  APPEND lwa_seltexts TO lit_seltexts.

  CLEAR lwa_seltexts.
  lwa_seltexts-name = 'P_QVAR2'.
  lwa_seltexts-kind = 'P'.
  lwa_seltexts-text = 'Variant ID'.
  APPEND lwa_seltexts TO lit_seltexts.

  CLEAR lwa_seltexts.
  lwa_seltexts-name = 'P_QHANA'.
  lwa_seltexts-kind = 'P'.
  lwa_seltexts-text = 'HANA DB Migration'.
  APPEND lwa_seltexts TO lit_seltexts.

  CLEAR lwa_seltexts.
  lwa_seltexts-name = 'P_QS4'.
  lwa_seltexts-kind = 'P'.
  lwa_seltexts-text = 'Simplification Technical'.
  APPEND lwa_seltexts TO lit_seltexts.
*** EOC by Palani for CR 881 on 14/10/2021
*BOC by Jeba for CR 811 on 01/12/2021
  CLEAR lwa_seltexts.
  lwa_seltexts-name = 'S_CSPACE'.
  lwa_seltexts-kind = 'S'.
  lwa_seltexts-text = 'Customer Namespace'.
  APPEND lwa_seltexts TO lit_seltexts.
*EOC by Jeba for CR 811 on 01/12/2021
***BOC by deepika for CR 813 on 01/12/2021
  CLEAR lwa_seltexts.
  lwa_seltexts-name = 'P_UPLOAD'.
  lwa_seltexts-kind = 'P'.
  lwa_seltexts-text = 'Upload Objects'.
  APPEND lwa_seltexts TO lit_seltexts.

  CLEAR lwa_seltexts.
  lwa_seltexts-name = 'P_DOWN'.
  lwa_seltexts-kind = 'P'.
  lwa_seltexts-text = 'Download Objects'.
  APPEND lwa_seltexts TO lit_seltexts.

  CLEAR lwa_seltexts.
  lwa_seltexts-name = 'R_IND'.
  lwa_seltexts-kind = 'P'.
  lwa_seltexts-text = 'Download Individual Objects'.
  APPEND lwa_seltexts TO lit_seltexts.

  CLEAR lwa_seltexts.
  lwa_seltexts-name = 'R_TR'.
  lwa_seltexts-kind = 'P'.
  lwa_seltexts-text = 'Download by TR'.
  APPEND lwa_seltexts TO lit_seltexts.

  CLEAR lwa_seltexts.
  lwa_seltexts-name = 'R_PACK'.
  lwa_seltexts-kind = 'P'.
  lwa_seltexts-text = 'Download by Package'.
  APPEND lwa_seltexts TO lit_seltexts.

  CLEAR lwa_seltexts.
  lwa_seltexts-name = 'R_FILE1'.
  lwa_seltexts-kind = 'P'.
  lwa_seltexts-text = 'Download by File Input'.
  APPEND lwa_seltexts TO lit_seltexts.

  CLEAR lwa_seltexts.
  lwa_seltexts-name = 'S_PROGG'.
  lwa_seltexts-kind = 'P'.
  lwa_seltexts-text = 'Program Name'.
  APPEND lwa_seltexts TO lit_seltexts.

  CLEAR lwa_seltexts.
  lwa_seltexts-name = 'S_FG'.
  lwa_seltexts-kind = 'P'.
  lwa_seltexts-text = 'Function Group Name'.
  APPEND lwa_seltexts TO lit_seltexts.

  CLEAR lwa_seltexts.
  lwa_seltexts-name = 'S_CLASS'.
  lwa_seltexts-kind = 'P'.
  lwa_seltexts-text = 'Class Name'.
  APPEND lwa_seltexts TO lit_seltexts.

  CLEAR lwa_seltexts.
  lwa_seltexts-name = 'S_TRREQ'.
  lwa_seltexts-kind = 'P'.
  lwa_seltexts-text = 'Transport Number'.
  APPEND lwa_seltexts TO lit_seltexts.

  CLEAR lwa_seltexts.
  lwa_seltexts-name = 'S_PACK'.
  lwa_seltexts-kind = 'P'.
  lwa_seltexts-text = 'Package Name'.
  APPEND lwa_seltexts TO lit_seltexts.

  CLEAR lwa_seltexts.
  lwa_seltexts-name = 'P_INFILE'.
  lwa_seltexts-kind = 'P'.
  lwa_seltexts-text = 'Object Input File'.
  APPEND lwa_seltexts TO lit_seltexts.

  CLEAR lwa_seltexts.
  lwa_seltexts-name = 'P_CHECK'.
  lwa_seltexts-kind = 'P'.
  lwa_seltexts-text = 'File has Header'.
  APPEND lwa_seltexts TO lit_seltexts.

  CLEAR lwa_seltexts.
  lwa_seltexts-name = 'S_CUST'.
  lwa_seltexts-kind = 'P'.
  lwa_seltexts-text = 'Customer Namespace'.
  APPEND lwa_seltexts TO lit_seltexts.

  CLEAR lwa_seltexts.
  lwa_seltexts-name = 'P_TEST'.
  lwa_seltexts-kind = 'P'.
  lwa_seltexts-text = 'Display Dependent Objects Only'.
  APPEND lwa_seltexts TO lit_seltexts.

  CLEAR lwa_seltexts.
  lwa_seltexts-name = 'DISP'.
  lwa_seltexts-kind = 'P'.
  lwa_seltexts-text = 'Display Objects'.
  APPEND lwa_seltexts TO lit_seltexts.

  CLEAR lwa_seltexts.
  lwa_seltexts-name = 'IMPO'.
  lwa_seltexts-kind = 'P'.
  lwa_seltexts-text = 'Import Objects'.
  APPEND lwa_seltexts TO lit_seltexts.

  CLEAR lwa_seltexts.
  lwa_seltexts-name = 'PACKAGE1'.
  lwa_seltexts-kind = 'P'.
  lwa_seltexts-text = 'Package Name'.
  APPEND lwa_seltexts TO lit_seltexts.

  CLEAR lwa_seltexts.
  lwa_seltexts-name = 'NUGFILE'.
  lwa_seltexts-kind = 'P'.
  lwa_seltexts-text = 'Input File Name'.
  APPEND lwa_seltexts TO lit_seltexts.

  CLEAR lwa_seltexts.
  lwa_seltexts-name = 'NOVRWR'.
  lwa_seltexts-kind = 'P'.
  lwa_seltexts-text = 'Overwrite Originals'.
  APPEND lwa_seltexts TO lit_seltexts.

  CLEAR lwa_seltexts.
  lwa_seltexts-name = 'DEPFILE'.
  lwa_seltexts-kind = 'P'.
  lwa_seltexts-text = 'Dependency File (Optional)'.
  APPEND lwa_seltexts TO lit_seltexts.
***EOC by deepika for CR 813 on 01/12/2021

** BOC by shikha bansal for CR 822 on 08/12/2021
  CLEAR lwa_seltexts.
  lwa_seltexts-name = 'P_XT22'.
  lwa_seltexts-kind = 'P'.
  lwa_seltexts-text = 'Check Segmentation & Scale'.
  APPEND lwa_seltexts TO lit_seltexts.
** EOC by shikha bansal for CR 822 on 08/12/2021
* BOC by Anurag for cr 832 on 04/01/2022
  CLEAR lwa_seltexts.
  lwa_seltexts-name = 'P_XT23'.
  lwa_seltexts-kind = 'P'.
  lwa_seltexts-text = 'BW Extractor'.
  APPEND lwa_seltexts TO lit_seltexts.

  CLEAR lwa_seltexts.
  lwa_seltexts-name = 'P_DWNLD'.
  lwa_seltexts-kind = 'P'.
  lwa_seltexts-text = 'Download Path'.
  APPEND lwa_seltexts TO lit_seltexts.
*EOC by Anurag for cr 832 on 04/01/2022

  "BOC by Nancy for Green It on 16/05/2022

  CLEAR lwa_seltexts.
  lwa_seltexts-name = 'P_ST03G'.
  lwa_seltexts-kind = 'P'.
  lwa_seltexts-text = 'ST03 Trans Profile(.CSV):'.
  APPEND lwa_seltexts TO lit_seltexts.

   CLEAR lwa_seltexts.
  lwa_seltexts-name = 'P_RFCG'.
  lwa_seltexts-kind = 'P'.
  lwa_seltexts-text = 'ST03 RFC Profile(.CSV):'.
  APPEND lwa_seltexts TO lit_seltexts.

   CLEAR lwa_seltexts.
  lwa_seltexts-name = 'P_SCMN'.
  lwa_seltexts-kind = 'P'.
  lwa_seltexts-text = 'SCMON Data'.
  APPEND lwa_seltexts TO lit_seltexts.

 CLEAR lwa_seltexts.
  lwa_seltexts-name = 'S_OBNM'.
  lwa_seltexts-kind = 'P'.
  lwa_seltexts-text = 'Object name(s)'.
  APPEND lwa_seltexts TO lit_seltexts.


  CLEAR lwa_seltexts.
  lwa_seltexts-name = 'S_CUST1'.
  lwa_seltexts-kind = 'P'.
  lwa_seltexts-text = 'Customer Namespace'.
  APPEND lwa_seltexts TO lit_seltexts.

  CLEAR lwa_seltexts.
  lwa_seltexts-name = 'S_OP_GI1'.
  lwa_seltexts-kind = 'P'.
  lwa_seltexts-text = 'Operation Codes'.
  APPEND lwa_seltexts TO lit_seltexts.

  CLEAR lwa_seltexts.
  lwa_seltexts-name = 'S_OP_GI2'.
  lwa_seltexts-kind = 'P'.
  lwa_seltexts-text = 'Operation Codes'.
  APPEND lwa_seltexts TO lit_seltexts.

  CLEAR lwa_seltexts.
  lwa_seltexts-name = 'S_OP_GI3'.
  lwa_seltexts-kind = 'P'.
  lwa_seltexts-text = 'Operation Codes'.
  APPEND lwa_seltexts TO lit_seltexts.

  CLEAR lwa_seltexts.
  lwa_seltexts-name = 'S_OP_GI4'.
  lwa_seltexts-kind = 'P'.
  lwa_seltexts-text = 'Operation Codes'.
  APPEND lwa_seltexts TO lit_seltexts.

  CLEAR lwa_seltexts.
  lwa_seltexts-name = 'S_OP_GI5'.
  lwa_seltexts-kind = 'P'.
  lwa_seltexts-text = 'Operation Codes'.
  APPEND lwa_seltexts TO lit_seltexts.

  CLEAR lwa_seltexts.
  lwa_seltexts-name = 'S_OP_GI6'.
  lwa_seltexts-kind = 'P'.
  lwa_seltexts-text = 'Operation Codes'.
  APPEND lwa_seltexts TO lit_seltexts.

  CLEAR lwa_seltexts.
  lwa_seltexts-name = 'C_MAIN'.
  lwa_seltexts-kind = 'P'.
  lwa_seltexts-text = 'Maintainability'.
  APPEND lwa_seltexts TO lit_seltexts.

  CLEAR lwa_seltexts.
  lwa_seltexts-name = 'C_QUAL'.
  lwa_seltexts-kind = 'P'.
  lwa_seltexts-text = 'Quality'.
  APPEND lwa_seltexts TO lit_seltexts.


  CLEAR lwa_seltexts.
  lwa_seltexts-name = 'C_PER'.
  lwa_seltexts-kind = 'P'.
  lwa_seltexts-text = 'Performance'.
  APPEND lwa_seltexts TO lit_seltexts.


  CLEAR lwa_seltexts.
  lwa_seltexts-name = 'C_AUTO'.
  lwa_seltexts-kind = 'P'.
  lwa_seltexts-text = 'Automation'.
  APPEND lwa_seltexts TO lit_seltexts.


  CLEAR lwa_seltexts.
  lwa_seltexts-name = 'C_DB'.
  lwa_seltexts-kind = 'P'.
  lwa_seltexts-text = 'Database Management'.
  APPEND lwa_seltexts TO lit_seltexts.


  CLEAR lwa_seltexts.
  lwa_seltexts-name = 'C_SEC'.
  lwa_seltexts-kind = 'P'.
  lwa_seltexts-text = 'Security'.
  APPEND lwa_seltexts TO lit_seltexts.

  "EOC by Nancy for Green It on 16/05/2022

*BOC by jagriti TASK 576 1/13/2021
  SELECT SINGLE funcname FROM tfdir INTO lv_cg_check_tfdir WHERE funcname = 'SELECTION_TEXTS_MODIFY'.
  IF sy-subrc EQ 0.
    CALL FUNCTION lv_cg_check_tfdir
      EXPORTING
        program                     = sy-cprog
      TABLES
        seltexts                    = lit_seltexts
      EXCEPTIONS
        program_not_found           = 1
        program_cannot_be_generated = 2
        OTHERS                      = 3.
  ELSEIF sy-subrc NE 0.
    MESSAGE 'SELECTION_TEXTS_MODIFY does not exist in this system' TYPE 'E'.
  ENDIF.
  CLEAR lv_cg_check_tfdir.
*EOC by jagriti TASK 576 1/13/2021

ENDFORM.
FORM sub_clear_tab.
  CASE sy-ucomm.
    WHEN 'PUSH1'.
      mytab-prog = sy-repid.
      mytab-dynnr = 100.
      mytab-activetab = 'PUSH1'.
      CLEAR:p_varid2,s_obj,c_upg,c_hana,c_s4.
      REFRESH:s_obj.
      p_syntax = abap_true.
      p_synlog = abap_true.
      c_upg = abap_true.
*      c_upg2 = abap_true.
* BOC SONAL DEFECT #614 - Scan hardcode/sysid once 02/02/21
*      CLEAR:p_sid,s_prog,c_upg,c_hana,c_s4,c_bg_job.
      CLEAR:p_sid,s_prog,c_upg,c_hana,c_s4,c_bg_job,p_hcode.
* EOC SONAL DEFECT #614 - Scan hardcode/sysid once 02/02/21
      REFRESH:s_prog.
* BOC DEEPIKA DEFECT #916 - Screen parameters not getting refreshed while switching b/w tabs 30/08/21
      CLEAR:p_tr,fcv_a,lcv_a.
      REFRESH: p_sid,s_prog.
* EOC DEEPIKA DEFECT #916 - Screen parameters not getting refreshed while switching b/w tabs 30/08/21

    WHEN 'PUSH2'.

      WRITE : 'PUSH2'.
      c_bg_job = abap_true.
      mytab-prog = sy-repid.
      mytab-dynnr = 200.
      mytab-activetab = 'PUSH2'.
      CLEAR:s_nspace,s_pkgnam,s_cspace. "p_file.
      REFRESH:s_nspace,s_pkgnam.
      CLEAR:p_sid,s_prog,c_upg,c_hana,c_s4,c_cloud. " added by Pooja Kalshetti
      REFRESH:s_prog.
*      c_upg2 = abap_true.
*      CONCATENATE sy-uname sy-datum+4(4) sy-uzeit INTO p_varid1.
* BOC DEEPIKA DEFECT #916 - Screen parameters not getting refreshed while switching b/w tabs 30/08/21
      CLEAR:p_tr,fcv_a,lcv_a.
      REFRESH: p_sid,s_prog.
* EOC DEEPIKA DEFECT #916 - Screen parameters not getting refreshed while switching b/w tabs 30/08/21
    WHEN 'PUSH3'.
      mytab-prog = sy-repid.
      mytab-dynnr = 300.
      mytab-activetab = 'PUSH3'.
      CLEAR:s_nspace,s_pkgnam,s_cspace."p_file.
      REFRESH:s_nspace,s_pkgnam.
* EOC SONAL DEFECT #614 - Scan hardcode/sysid once 02/02/21
*      CLEAR:p_varid2,s_obj,c_upg,c_hana,c_s4,c_bg_job.
      CLEAR:p_varid2,s_obj,c_upg,c_hana,c_s4,c_bg_job, p_hcode.
* EOC SONAL DEFECT #614 - Scan hardcode/sysid once 02/02/21
      REFRESH:s_obj.
      p_syntax = abap_true.
      p_synlog = abap_true.
      c_upg = abap_true.
*      CONCATENATE sy-uname sy-datum+4(4) sy-uzeit INTO p_varid1.


* BOC DEEPIKA DEFECT #916 - Screen parameters not getting refreshed while switching b/w tabs 30/08/21
    WHEN 'PUSH4'.
      mytab-prog = sy-repid.
      mytab-dynnr = 400.
      mytab-activetab = 'PUSH4'.
      REFRESH:s_obj,s_prog,p_sid.
      CLEAR:p_varid2,c_upg,c_hana,c_s4,fcv_a, lcv_a,p_tr.
* EOC DEEPIKA DEFECT #916 - Screen parameters not getting refreshed while switching b/w tabs 30/08/21
**BOC by deepika for CR 813 on 01/12/2021
    WHEN 'PUSH5'.
      mytab-prog = sy-repid.
      mytab-dynnr = 500.
      mytab-activetab = 'PUSH5'.
      REFRESH:s_obj,s_prog,p_sid.
      CLEAR:p_varid2,c_upg,c_hana,c_s4,fcv_a, lcv_a,p_tr.
**EOC by deepika for CR 813 on 01/12/2021

      "BOC by Nancy for Green IT on 16/05/2022
    WHEN 'PUSH6'.
      mytab-prog = sy-repid.
      mytab-dynnr = 600.
      mytab-activetab = 'PUSH6'.
      REFRESH:s_obj,s_prog,p_sid.
      CLEAR:p_varid2,c_upg,c_hana,c_s4,fcv_a, lcv_a,p_tr.
      "EOC by Nancy for Green IT on 16/05/2022
    WHEN OTHERS.

*      PERFORM Validation. "CR 433

  ENDCASE.
ENDFORM.
FORM sub_set_fields.

  LOOP AT SCREEN.
    "BOC by Jeba for CR 695 on 18.03.2021 Hide the utilites
    READ TABLE gt_scope INTO gw_scope WITH KEY scope = screen-group1.
    IF sy-subrc = 0.
      screen-active = 0.
      MODIFY SCREEN.
    ENDIF.
    IF ( screen-group1 EQ 'S4' OR screen-group1 EQ 'SOH' ) AND screen-name EQ 'P_XT10'.
      screen-active = 1.
      MODIFY SCREEN.
    ENDIF.
    "EOC by Jeba for CR 695 on 18.03.2021
*    if screen
    IF screen-group1 EQ 'VI1'.
      screen-input = 0.
    ENDIF.
*    IF NOT r_tab IS INITIAL.
*      IF screen-group1 EQ 'FIL'.
*        screen-active = 0.
*        screen-invisible = 1.
*      ENDIF.
*    ENDIF.
*    IF NOT r_file IS INITIAL.
*      IF screen-group1 EQ 'FIL'.
*        screen-active = 1.
*        screen-invisible = 0.
*      ENDIF.
*    ENDIF.

* BOC Custom modlog
    IF c_modlog IS NOT INITIAL.
      IF screen-group1 EQ 'LIN'.
        screen-active = 1.
        screen-invisible = 0.
      ENDIF.
    ENDIF.

    IF c_modlog IS INITIAL.
      IF screen-group1 EQ 'LIN'.
        screen-active = 0.
        screen-invisible = 1.
      ENDIF.
    ENDIF.
* BOC FIAT tool*********************
    IF p_fiat IS NOT INITIAL.
      IF screen-group1 EQ 'APP'.
        screen-active = 1.
      ENDIF.
      IF screen-group1 EQ 'VI2'.
        screen-active = 0.
      ENDIF.
*    BOC by Gunjan 22/2/2021  Defect#652
      IF screen-group1 = 'STF'.
        IF p_wld = ''.
          screen-active = 0.
          gv_st03f = ''.
        ELSE.
          screen-active = 1.
          gv_st03f = 'X'.
        ENDIF.
        MODIFY SCREEN.
      ENDIF.
*    EOC by Gunjan 22/2/2021 Defect#652
    ELSE.
      IF screen-group1 EQ 'APP'.
        screen-active = 0.
      ENDIF.
      IF screen-group1 = 'STF'. "Added by Gunjan 22/2/2021 Defect#652
        screen-active = 0.
      ENDIF.
    ENDIF.
* EOC FIAT tool*********************
    IF c_s4 IS INITIAL.
      IF screen-group1 EQ 'MOD'.
        screen-active = 0.
        screen-invisible = 1.
      ENDIF.
***      BOC PARUL PURI ON 04.26.2021 for Defect ID - 677
      IF screen-group1 EQ 'M40'.
        screen-active = 0.
        screen-invisible = 1.
      ENDIF.
***      EOC PARUL PURI ON 04.26.2021 for Defect ID - 677
    ENDIF.
    IF mytab-activetab = 'PUSH2'.
*****BOC Fiori tool requirements***********************************************************************
      DATA: lv_odata_chk TYPE flag .
      CLEAR gv_exists.
      PERFORM sub_check_class USING gc_zcl_odata_records CHANGING gv_exists.
      IF gv_exists <> 'X'.
        CREATE OBJECT o_odata_records TYPE (gc_zcl_odata_records).

        REFRESH git_ptab.
        CLEAR gs_ptab_line.

        lv_odata_chk = abap_false.
        gs_ptab_line-name = 'E_FLAG'.
        gs_ptab_line-kind = cl_abap_objectdescr=>importing.
        GET REFERENCE OF lv_odata_chk INTO  gs_ptab_line-value .
        INSERT gs_ptab_line INTO TABLE git_ptab.
        CALL METHOD o_odata_records->(gc_check_odata_tables) PARAMETER-TABLE git_ptab.
      ENDIF.
      IF lv_odata_chk NE 'X'.
        IF screen-name EQ 'P_ODATA'.
          screen-active = 0."  For Not showing
          IF screen-name EQ 'S_GROUP'.
            screen-active = 0."  For Not showing
          ENDIF.
        ENDIF.
      ENDIF.
      IF p_odata NE 'X'.
        p_g1 = 'X'.
        p_g2 = ''.
        IF screen-group1 EQ 'SG' OR screen-group1 EQ 'G1' OR screen-group1 = 'G3'.
          screen-active = 0.
          screen-input = 0.
          screen-invisible = 1.
        ENDIF.
      ENDIF.

      IF p_g2 NE 'X' . "AND p_odata ne 'X'.
        IF screen-group1 EQ 'G3' .
          screen-active = 0.
          screen-invisible = 1.
        ENDIF.
      ELSEIF p_g2 EQ 'X'.
        IF screen-group1 EQ 'G3'.
          screen-active = 1.
          screen-input = 1.
          screen-invisible = 0.
        ENDIF.
      ENDIF.

*      gs_grp-sign = 'I'.
*      gs_grp-option = 'CP'.
*      gs_grp-low = 'Z*'.
*      APPEND gs_grp TO s_group.
*      gs_grp-sign = 'I'.
*      gs_grp-option = 'CP'.
*      gs_grp-low = 'Y*'.
*      APPEND gs_grp TO s_group.
*start ins dhiraj 31-03-2020
      IF c_cloud NE 'X'.
        IF screen-name EQ 'C_LOGCMD'.
          screen-active = 0.
          screen-invisible = 1.
        ENDIF.
        IF screen-name EQ 'C_LOGPAT'.
          screen-active = 0.
          screen-invisible = 1.
        ELSEIF screen-name NE 'C_LOGPAT'.
          IF screen-group1 EQ 'M21'.
            screen-active = 0.
            screen-invisible = 1.
          ENDIF.
        ENDIF.
        IF screen-group1 EQ 'LG9'.
          screen-active = 0.
          screen-invisible = 1.
        ENDIF.
        IF screen-group1 EQ 'M21'.
          screen-active = 0.
          screen-invisible = 1.
        ENDIF.
        c_logcmd = ''.
        c_logpat = ''.
      ELSEIF c_cloud EQ 'X'.
        IF c_logpat NE 'X'.
          IF screen-group1 EQ 'M21'.
            screen-active = 0.
            screen-invisible = 1.
          ENDIF.
        ENDIF.
      ENDIF.
*End ins dhiraj 31-03-2020
*      boc s/4 extension
      IF c_ext NE 'X'.
        IF screen-group1 EQ 'EXT'.
          screen-active = 0.
          screen-invisible = 1.
        ENDIF.

      ENDIF.
* eoc s/4 extension
    ENDIF.

*****EOC Fiori tool requirements***********************************************************************
*   CHANGESONAL
    IF mytab-activetab = 'PUSH3'.
*      IF screen-group1 EQ 'CHK' .  "Commented by Jeba for #765 on 22.04.2021
*        screen-active = 0.
*        screen-invisible = 1.
*      ENDIF.
* *  start ins Dhiraj-14-01-2020
      IF c_ocld2 IS INITIAL.
        c_cld2 = ''.
        c_lfr = ''.
        IF screen-group1 EQ 'OS2'.
          screen-active = 0.
          screen-invisible = 1.
        ENDIF.
      ELSE.
        IF c_cld2 IS INITIAL AND  c_lfr IS INITIAL.
          c_cld2 = 'X'.
        ENDIF.
      ENDIF.
* *  end ins Dhiraj-14-01-2020
*** Begin Of Change By Manisha for defect#518 on 05/01/2021

      IF c_cld_o IS NOT INITIAL.
        CLEAR :  c_cld2, c_lfr.
        IF screen-group1 EQ 'M21'.
          screen-active = 1.
        ENDIF.
      ENDIF.
*** End of Change By Manisha for defect#518 on 05/01/2021
**** start of change by Pooja Kalshetti
      IF c_cld2 IS INITIAL.
        IF screen-group1 EQ 'RG1'.
          screen-active = 0.
          screen-invisible = 1.
        ENDIF.
      ENDIF.
*  start ins Dhiraj-14-01-2020
      IF c_cld2 IS NOT INITIAL.
        IF screen-group1 EQ 'RG1'.
          screen-active = 1.
          screen-invisible = 0.
          MODIFY SCREEN.
        ENDIF.
      ENDIF.

      IF c_lfr IS INITIAL.
        IF screen-group1 EQ 'LF1'.
          screen-active = 0.
          screen-invisible = 1.
        ENDIF.
      ELSE.
        IF p_lfg NE 'X'.
          IF screen-name CS 'P_lFILE1'.
            screen-active = 0.
            MODIFY SCREEN.
          ENDIF.
        ELSEIF  p_lfg EQ 'X'.
          IF screen-name CS 'P_lFILE2'.
            screen-active = 0.
            MODIFY SCREEN.
          ENDIF.
        ENDIF.
      ENDIF.
*  end ins Dhiraj -14-01-2020
      "BOC by Nancy for green it on 16.05.22
*      If c_main  EQ 'X'.
*        if lv_flag8 = 'X'.
*        Refresh s_op_gi1.
*        lw_opercd-sign = 'I'.
*          lw_opercd-option = 'EQ'.
*          lw_opercd-low = 'Identify Unused Custom Inventory'.
*           APPEND lw_opercd TO S_OP_GI1.
*           clear lw_opercd-low.
*          lw_opercd-low = 'Identify clone objects'. "changed by shikha for CR 839 on 03 March 2022
*          APPEND lw_opercd TO s_op_gi1.
*          endif.
*
*        endif.
      "EOC by Nancy for green it on 16.05.22
**** End of change by Pooja Kalshetti
      IF c_hana2 EQ 'X' AND c_upg2 EQ 'X' AND c_s42 EQ 'X'.
        IF lv_flag1 EQ 'X'.
          REFRESH s_opcode.
          lw_opercd-sign = 'I'.
          lw_opercd-option = 'EQ'.
          lw_opercd-low = '12-DDIC FUNCTION'. "changed by shikha for CR 839 on 03 March 2022
          APPEND lw_opercd TO s_opcode.

          lw_opercd-low = '16-SELECT ON POOL/CLUSTER TABLE'. "changed by shikha for CR 839 on 03 March 2022
          APPEND lw_opercd TO s_opcode.

          lw_opercd-low = '57-SELECT SINGLE NOT UNIQUE'. "changed by shikha for CR 839 on 03 March 2022
          APPEND lw_opercd TO s_opcode.

          lw_opercd-low = '45-WITH KEY CLAUSE & READ WITH BINARY WITHOUT SORT'. "changed by shikha for CR 839 on 03 March 2022
          APPEND lw_opercd TO s_opcode.

          lw_opercd-low = '46-DELETE ADJACENT DUPLICATES WITHOUT SORT'. "changed by shikha for CR 839 on 03 March 2022
          APPEND lw_opercd TO s_opcode.

          lw_opercd-low = '18-READ TABLE/LOOP/DELETE/MODIFY'. "changed by shikha for CR 839 on 03 March 2022
          APPEND lw_opercd TO s_opcode.

          lw_opercd-low = '19-AT NEW/AT FIRST/AT END OF/AT LAST/ON CHANGE OF'. "changed by shikha for CR 839 on 03 March 2022
          APPEND lw_opercd TO s_opcode.

          lw_opercd-low = '53-EXIT,LEAVE LIST-PROCESSING,CHECK,RETURN in LOOP'. "changed by shikha for CR 839 on 03 March 2022
          APPEND lw_opercd TO s_opcode.

          lw_opercd-low = '21-SELECT STATEMENT FOR UNSORTED INTERNAL TABLE'. "changed by shikha for CR 839 on 03 March 2022
          APPEND lw_opercd TO s_opcode.

          lw_opercd-sign = 'I'.
          lw_opercd-option = 'EQ'.
          lw_opercd-low = '69-CALLING FM VRM_SET_VALUES'. "changed by shikha for CR 839 on 03 March 2022
          APPEND lw_opercd TO s_opcode.

          lw_opercd-sign = 'I'.
          lw_opercd-option = 'EQ'.
          lw_opercd-low = '70-CALLING FM FOR F4_INTERNAL_TABLE_HELP'. "changed by shikha for CR 839 on 03 March 2022
          APPEND lw_opercd TO s_opcode.
          " BOC CDS
*          lw_opercd-low = '39'.
*          APPEND lw_opercd TO s_opcode.
          " EOC CDS
*          lw_opercd-low = '129'.
*          APPEND lw_opercd TO s_opcode.

          lw_opercd-low = 'REDUNDANT SELECT'.
          APPEND lw_opercd TO s_opcode.

          lw_opercd-low = 'DATA DECLARATION'.
          APPEND lw_opercd TO s_opcode.

          lw_opercd-low = 'SELECT LIST'.
          APPEND lw_opercd TO s_opcode.

*          lw_opercd-low = 'SELECT WHERE COND'.
          lw_opercd-low = 'WHERE COND IN FOR ALL ENTRIES'.
          APPEND lw_opercd TO s_opcode.

          lw_opercd-low = 'WRITE'.
          APPEND lw_opercd TO s_opcode.

          lw_opercd-low = 'FUNCTION MODULE'.
          APPEND lw_opercd TO s_opcode.
          "BOC by Jeba 17.08.2020
          lw_opercd-low = 'ASSIGNMENT'.
          APPEND lw_opercd TO s_opcode.

          lw_opercd-low = 'SELECT WHERE COND'.
          APPEND lw_opercd TO s_opcode.

          lw_opercd-low = 'MESSAGE CLASS'.
          APPEND lw_opercd TO s_opcode.

          lw_opercd-low = 'INCOMPATIBLE FM PARAMETERS'.
          APPEND lw_opercd TO s_opcode.

          lw_opercd-low = 'MAT_LEN_EXT'.
          APPEND lw_opercd TO s_opcode.

          lw_opercd-low = 'BAPI'.
          APPEND lw_opercd TO s_opcode.

          lw_opercd-low = 'REPLACE'.
          APPEND lw_opercd TO s_opcode.

          lw_opercd-low = 'CONCATENATE'.
          APPEND lw_opercd TO s_opcode.

          lw_opercd-low = 'READ WITH COND'. "Added on 22.10.2020
          APPEND lw_opercd TO s_opcode.

          lw_opercd-low = 'LOOP WHERE COND'. "Added on 22.10.2020
          APPEND lw_opercd TO s_opcode.

          lw_opercd-low = 'INCOMPATIBLE CLASS PARAMETERS'. "Added on 12.2.2020
          APPEND lw_opercd TO s_opcode.

          lw_opercd-low = 'EXPONENTIAL OPERATOR'. "Added on 12.2.2020 #Defect 374
          APPEND lw_opercd TO s_opcode.

          lw_opercd-low = 'SELECT STATEMENT'. "Added by Jeba on 30.12.2020 #CR560 & CR#561
          APPEND lw_opercd TO s_opcode.

          lw_opercd-low = 'UPDATE/DELETE'. "Added by Jeba on 30.12.2020 #CR560 & CR#561
          APPEND lw_opercd TO s_opcode.
          "EOC by Jeba 17.08.2020
*          BOC By Sakshi 11/11/2020
*          TYPE X error  commented by Sakshi for enable autocorrection
*          lw_opercd-sign = 'E'.
*          lw_opercd-option = 'EQ'.
*          lw_opercd-low = '133'. "'128'.
*          APPEND lw_opercd TO s_opcode.
*          CLEAR lw_opercd.
*          EOC By Sakshi 11/11/2020

          lw_opercd-sign = 'E'.
          lw_opercd-option = 'EQ'.
          lw_opercd-low = '130'.
          APPEND lw_opercd TO s_opcode.

          CLEAR lw_opercd.

          lw_opercd-sign = 'I'.
          lw_opercd-option = 'BT'.
          lw_opercd-low = '100'.
*          lw_opercd-high = '127'.
          lw_opercd-high = '131'. "Changed By Manya on 11.06.2019 to include CRM Function Modules
          APPEND lw_opercd TO s_opcode.
          CLEAR : lv_flag1, lw_opercd.

        ENDIF.

      ELSEIF c_hana2 EQ 'X' AND c_upg2 EQ 'X'.
        IF lv_flag2 EQ 'X'.
          REFRESH s_opcode.
          lw_opercd-sign = 'I'.
          lw_opercd-option = 'EQ'.
          lw_opercd-low = '12-DDIC FUNCTION'. "changed by shikha for CR 839 on 03 March 2022
          APPEND lw_opercd TO s_opcode.

          lw_opercd-low = '16-SELECT ON POOL/CLUSTER TABLE'. "changed by shikha for CR 839 on 03 March 2022
          APPEND lw_opercd TO s_opcode.

          lw_opercd-low = '57-SELECT SINGLE NOT UNIQUE'. "changed by shikha for CR 839 on 03 March 2022
          APPEND lw_opercd TO s_opcode.

          lw_opercd-low = '45-WITH KEY CLAUSE & READ WITH BINARY WITHOUT SORT'. "changed by shikha for CR 839 on 03 March 2022
          APPEND lw_opercd TO s_opcode.

          lw_opercd-low = '46-DELETE ADJACENT DUPLICATES WITHOUT SORT'. "changed by shikha for CR 839 on 03 March 2022
          APPEND lw_opercd TO s_opcode.

          lw_opercd-low = '18-READ TABLE/LOOP/DELETE/MODIFY'. "changed by shikha for CR 839 on 03 March 2022
          APPEND lw_opercd TO s_opcode.

          lw_opercd-low = '19-AT NEW/AT FIRST/AT END OF/AT LAST/ON CHANGE OF'. "changed by shikha for CR 839 on 03 March 2022
          APPEND lw_opercd TO s_opcode.

          lw_opercd-low = '53-EXIT,LEAVE LIST-PROCESSING,CHECK,RETURN in LOOP'. "changed by shikha for CR 839 on 03 March 2022
          APPEND lw_opercd TO s_opcode.

          lw_opercd-low = '21-SELECT STATEMENT FOR UNSORTED INTERNAL TABLE'. "changed by shikha for CR 839 on 03 March 2022
          APPEND lw_opercd TO s_opcode.
          lw_opercd-sign = 'I'.
          lw_opercd-option = 'EQ'.
          lw_opercd-low = '69-CALLING FM VRM_SET_VALUES'. "changed by shikha for CR 839 on 03 March 2022
          APPEND lw_opercd TO s_opcode.
          lw_opercd-sign = 'I'.
          lw_opercd-option = 'EQ'.
          lw_opercd-low = '70-CALLING FM FOR F4_INTERNAL_TABLE_HELP'. "changed by shikha for CR 839 on 03 March 2022
          APPEND lw_opercd TO s_opcode.
*Commented for TYPE X Autocorrection
*          lw_opercd-sign = 'E'.
*          lw_opercd-option = 'EQ'.
*          lw_opercd-low = '133' . "'128'.
*          APPEND lw_opercd TO s_opcode.

          lw_opercd-sign = 'E'.
          lw_opercd-option = 'EQ'.
          lw_opercd-low = '130'.
          APPEND lw_opercd TO s_opcode.

          CLEAR lw_opercd.

          lw_opercd-sign = 'I'.
          lw_opercd-option = 'BT'.
          lw_opercd-low = '100'.
*          lw_opercd-high = '127'.
          lw_opercd-high = '131'. "Changed By Manya on 11.06.2019 to include CRM Function Modules
          APPEND lw_opercd TO s_opcode.
          CLEAR : lv_flag2, lw_opercd.

        ENDIF.

      ELSEIF c_hana2 EQ 'X' AND c_s42 EQ 'X'.
        IF lv_flag3 EQ 'X'.
          REFRESH s_opcode.
          lw_opercd-sign = 'I'.
          lw_opercd-option = 'EQ'.
          lw_opercd-low = '12-DDIC FUNCTION'. "changed by shikha for CR 839 on 03 March 2022
          APPEND lw_opercd TO s_opcode.

          lw_opercd-low = '16-SELECT ON POOL/CLUSTER TABLE'. "changed by shikha for CR 839 on 03 March 2022
          APPEND lw_opercd TO s_opcode.

          lw_opercd-low = '57-SELECT SINGLE NOT UNIQUE'. "changed by shikha for CR 839 on 03 March 2022
          APPEND lw_opercd TO s_opcode.

          lw_opercd-low = '45-WITH KEY CLAUSE & READ WITH BINARY WITHOUT SORT'. "changed by shikha for CR 839 on 03 March 2022
          APPEND lw_opercd TO s_opcode.

          lw_opercd-low = '46-DELETE ADJACENT DUPLICATES WITHOUT SORT'. "changed by shikha for CR 839 on 03 March 2022
          APPEND lw_opercd TO s_opcode.

          lw_opercd-low = '18-READ TABLE/LOOP/DELETE/MODIFY'. "changed by shikha for CR 839 on 03 March 2022
          APPEND lw_opercd TO s_opcode.

          lw_opercd-low = '19-AT NEW/AT FIRST/AT END OF/AT LAST/ON CHANGE OF'. "changed by shikha for CR 839 on 03 March 2022
          APPEND lw_opercd TO s_opcode.

          lw_opercd-low = '53-EXIT,LEAVE LIST-PROCESSING,CHECK,RETURN in LOOP'. "changed by shikha for CR 839 on 03 March 2022
          APPEND lw_opercd TO s_opcode.

          lw_opercd-low = '21-SELECT STATEMENT FOR UNSORTED INTERNAL TABLE'. "changed by shikha for CR 839 on 03 March 2022
          APPEND lw_opercd TO s_opcode.
          lw_opercd-sign = 'I'.
          lw_opercd-option = 'EQ'.
          lw_opercd-low = '69-CALLING FM VRM_SET_VALUES'. "changed by shikha for CR 839 on 03 March 2022
          APPEND lw_opercd TO s_opcode.
          lw_opercd-sign = 'I'.
          lw_opercd-option = 'EQ'.
          lw_opercd-low = '70-CALLING FM FOR F4_INTERNAL_TABLE_HELP'. "changed by shikha for CR 839 on 03 March 2022
          APPEND lw_opercd TO s_opcode.

          lw_opercd-low = 'REDUNDANT SELECT'.
          APPEND lw_opercd TO s_opcode.

          lw_opercd-low = 'DATA DECLARATION'.
          APPEND lw_opercd TO s_opcode.

          lw_opercd-low = 'SELECT LIST'.
          APPEND lw_opercd TO s_opcode.

*          lw_opercd-low = 'SELECT WHERE COND'.
          lw_opercd-low = 'WHERE COND IN FOR ALL ENTRIES'.
          APPEND lw_opercd TO s_opcode.

          lw_opercd-low = 'WRITE'.
          APPEND lw_opercd TO s_opcode.

          lw_opercd-low = 'FUNCTION MODULE'.
          APPEND lw_opercd TO s_opcode.
          "BOC by Jeba 17.08.2020
          lw_opercd-low = 'ASSIGNMENT'.
          APPEND lw_opercd TO s_opcode.

          lw_opercd-low = 'SELECT WHERE COND'.
          APPEND lw_opercd TO s_opcode.

          lw_opercd-low = 'MESSAGE CLASS'.
          APPEND lw_opercd TO s_opcode.

          lw_opercd-low = 'INCOMPATIBLE FM PARAMETERS'.
          APPEND lw_opercd TO s_opcode.

          lw_opercd-low = 'MAT_LEN_EXT'.
          APPEND lw_opercd TO s_opcode.

          lw_opercd-low = 'BAPI'.
          APPEND lw_opercd TO s_opcode.

          lw_opercd-low = 'REPLACE'.
          APPEND lw_opercd TO s_opcode.

          lw_opercd-low = 'CONCATENATE'.
          APPEND lw_opercd TO s_opcode.

          lw_opercd-low = 'READ WITH COND'. "Added on 22.10.2020
          APPEND lw_opercd TO s_opcode.

          lw_opercd-low = 'LOOP WHERE COND'. "Added on 22.10.2020
          APPEND lw_opercd TO s_opcode.

          lw_opercd-low = 'INCOMPATIBLE CLASS PARAMETERS'. "Added on 12.2.2020
          APPEND lw_opercd TO s_opcode.

          lw_opercd-low = 'EXPONENTIAL OPERATOR'. "Added on 12.2.2020 #Defect 374
          APPEND lw_opercd TO s_opcode.

          lw_opercd-low = 'SELECT STATEMENT'. "Added by Jeba on 30.12.2020 #CR560 & CR#561
          APPEND lw_opercd TO s_opcode.

          lw_opercd-low = 'UPDATE/DELETE'. "Added by Jeba on 30.12.2020 #CR560 & CR#561
          APPEND lw_opercd TO s_opcode.

          "EOC by Jeba 17.08.2020
          CLEAR : lv_flag3, lw_opercd.
        ENDIF.

      ELSEIF c_upg2 EQ 'X' AND c_s42 EQ 'X'.
        IF lv_flag4 = 'X'.
          REFRESH s_opcode.

*Commented for TYPE X Autocorrection
*          lw_opercd-sign = 'E'.
*          lw_opercd-option = 'EQ'.
*          lw_opercd-low = '133'. "'128'.
*          APPEND lw_opercd TO s_opcode.

          lw_opercd-sign = 'E'.
          lw_opercd-option = 'EQ'.
          lw_opercd-low = '130'.
          APPEND lw_opercd TO s_opcode.

          lw_opercd-sign = 'I'.
          lw_opercd-low = 'REDUNDANT SELECT'.
          APPEND lw_opercd TO s_opcode.

          lw_opercd-low = 'DATA DECLARATION'.
          APPEND lw_opercd TO s_opcode.

          lw_opercd-low = 'SELECT LIST'.
          APPEND lw_opercd TO s_opcode.

*          lw_opercd-low = 'SELECT WHERE COND'.
          lw_opercd-low = 'WHERE COND IN FOR ALL ENTRIES'.
          APPEND lw_opercd TO s_opcode.

          lw_opercd-low = 'WRITE'.
          APPEND lw_opercd TO s_opcode.

          lw_opercd-low = 'FUNCTION MODULE'.
          APPEND lw_opercd TO s_opcode.
          "BOC by Jeba 17.08.2020
          lw_opercd-low = 'ASSIGNMENT'.
          APPEND lw_opercd TO s_opcode.

          lw_opercd-low = 'SELECT WHERE COND'.
          APPEND lw_opercd TO s_opcode.

          lw_opercd-low = 'MESSAGE CLASS'.
          APPEND lw_opercd TO s_opcode.

          lw_opercd-low = 'INCOMPATIBLE FM PARAMETERS'.
          APPEND lw_opercd TO s_opcode.

          lw_opercd-low = 'MAT_LEN_EXT'.
          APPEND lw_opercd TO s_opcode.

          lw_opercd-low = 'BAPI'.
          APPEND lw_opercd TO s_opcode.

          lw_opercd-low = 'REPLACE'.
          APPEND lw_opercd TO s_opcode.

          lw_opercd-low = 'CONCATENATE'.
          APPEND lw_opercd TO s_opcode.

          lw_opercd-low = 'READ WITH COND'. "Added on 22.10.2020
          APPEND lw_opercd TO s_opcode.

          lw_opercd-low = 'LOOP WHERE COND'. "Added on 22.10.2020
          APPEND lw_opercd TO s_opcode.

          lw_opercd-low = 'INCOMPATIBLE CLASS PARAMETERS'. "Added on 12.2.2020
          APPEND lw_opercd TO s_opcode.

          lw_opercd-low = 'EXPONENTIAL OPERATOR'. "Added on 12.2.2020 #Defect 374
          APPEND lw_opercd TO s_opcode.

          lw_opercd-low = 'SELECT STATEMENT'. "Added by Jeba on 30.12.2020 #CR560 & CR#561
          APPEND lw_opercd TO s_opcode.

          lw_opercd-low = 'UPDATE/DELETE'. "Added by Jeba on 30.12.2020 #CR560 & CR#561
          APPEND lw_opercd TO s_opcode.
          "EOC by Jeba 17.08.2020
          CLEAR lw_opercd.

          lw_opercd-sign = 'I'.
          lw_opercd-option = 'BT'.
          lw_opercd-low = '100'.
*          lw_opercd-high = '127'.
          lw_opercd-high = '131'. "Changed By Manya on 11.06.2019 to include CRM Function Modules
          APPEND lw_opercd TO s_opcode.
          CLEAR : lv_flag4, lw_opercd.
        ENDIF.

      ELSEIF c_hana2 EQ 'X'.
        IF lv_flag5 EQ 'X'.
          REFRESH s_opcode.
          lw_opercd-sign = 'I'.
          lw_opercd-option = 'EQ'.
          lw_opercd-low = '12-DDIC FUNCTION'. "changed by shikha for CR 839 on 03 March 2022
          APPEND lw_opercd TO s_opcode.

          lw_opercd-low = '16-SELECT ON POOL/CLUSTER TABLE'. "changed by shikha for CR 839 on 03 March 2022
          APPEND lw_opercd TO s_opcode.

          lw_opercd-low = '57-SELECT SINGLE NOT UNIQUE'. "changed by shikha for CR 839 on 03 March 2022
          APPEND lw_opercd TO s_opcode.

          lw_opercd-low = '45-WITH KEY CLAUSE & READ WITH BINARY WITHOUT SORT'. "changed by shikha for CR 839 on 03 March 2022
          APPEND lw_opercd TO s_opcode.

          lw_opercd-low = '46-DELETE ADJACENT DUPLICATES WITHOUT SORT'. "changed by shikha for CR 839 on 03 March 2022
          APPEND lw_opercd TO s_opcode.

          lw_opercd-low = '18-READ TABLE/LOOP/DELETE/MODIFY'. "changed by shikha for CR 839 on 03 March 2022
          APPEND lw_opercd TO s_opcode.

          lw_opercd-low = '19-AT NEW/AT FIRST/AT END OF/AT LAST/ON CHANGE OF'. "changed by shikha for CR 839 on 03 March 2022
          APPEND lw_opercd TO s_opcode.

          lw_opercd-low = '53-EXIT,LEAVE LIST-PROCESSING,CHECK,RETURN in LOOP'. "changed by shikha for CR 839 on 03 March 2022
          APPEND lw_opercd TO s_opcode.

          lw_opercd-low = '21-SELECT STATEMENT FOR UNSORTED INTERNAL TABLE'. "changed by shikha for CR 839 on 03 March 2022
          APPEND lw_opercd TO s_opcode.
          CLEAR : lv_flag5, lw_opercd.
          lw_opercd-sign = 'I'.
          lw_opercd-option = 'EQ'.
          lw_opercd-low = '69-CALLING FM VRM_SET_VALUES'. "changed by shikha for CR 839 on 03 March 2022
          APPEND lw_opercd TO s_opcode.
          CLEAR : lv_flag5, lw_opercd.
          lw_opercd-sign = 'I'.
          lw_opercd-option = 'EQ'.
          lw_opercd-low = '70-CALLING FM FOR F4_INTERNAL_TABLE_HELP'. "changed by shikha for CR 839 on 03 March 2022
          APPEND lw_opercd TO s_opcode.
          CLEAR : lv_flag5, lw_opercd.
        ENDIF.

      ELSEIF c_upg2 = 'X'.
        IF lv_flag6 = 'X'.
          REFRESH s_opcode.
          lw_opercd-sign = 'I'.
          lw_opercd-option = 'BT'.
          lw_opercd-low = '100'.
*          lw_opercd-high = '127'.
          lw_opercd-high = '131'. "Changed By Manya on 11.06.2019 to include CRM Function Modules
          APPEND lw_opercd TO s_opcode.

          CLEAR lw_opercd.
*Commented for TYPE X Autocorrection
*          lw_opercd-sign = 'E'.
*          lw_opercd-option = 'EQ'.
*          lw_opercd-low = '133'. "128
*          APPEND lw_opercd TO s_opcode.

          lw_opercd-sign = 'E'.
          lw_opercd-option = 'EQ'.
          lw_opercd-low = '130'.
          APPEND lw_opercd TO s_opcode.

          CLEAR : lv_flag6, lw_opercd.
        ENDIF.

      ELSEIF c_s42 = 'X'.
        IF lv_flag7 = 'X'.
          REFRESH s_opcode.
          lw_opercd-sign = 'I'.
          lw_opercd-option = 'EQ'.
          lw_opercd-low = 'REDUNDANT SELECT'.
          APPEND lw_opercd TO s_opcode.

          lw_opercd-low = 'DATA DECLARATION'.
          APPEND lw_opercd TO s_opcode.

          lw_opercd-low = 'SELECT LIST'.
          APPEND lw_opercd TO s_opcode.

          lw_opercd-low = 'WHERE COND IN FOR ALL ENTRIES'.
          APPEND lw_opercd TO s_opcode.

          lw_opercd-low = 'WRITE'.
          APPEND lw_opercd TO s_opcode.

          lw_opercd-low = 'FUNCTION MODULE'.
          APPEND lw_opercd TO s_opcode.
          "BOC by Jeba 17.08.2020
          lw_opercd-low = 'ASSIGNMENT'.
          APPEND lw_opercd TO s_opcode.

          lw_opercd-low = 'SELECT WHERE COND'.
          APPEND lw_opercd TO s_opcode.

          lw_opercd-low = 'MESSAGE CLASS'.
          APPEND lw_opercd TO s_opcode.

          lw_opercd-low = 'INCOMPATIBLE FM PARAMETERS'.
          APPEND lw_opercd TO s_opcode.

          lw_opercd-low = 'MAT_LEN_EXT'.
          APPEND lw_opercd TO s_opcode.

          lw_opercd-low = 'BAPI'.
          APPEND lw_opercd TO s_opcode.

          lw_opercd-low = 'REPLACE'.
          APPEND lw_opercd TO s_opcode.

          lw_opercd-low = 'CONCATENATE'.
          APPEND lw_opercd TO s_opcode.

          lw_opercd-low = 'READ WITH COND'. "Added on 22.10.2020
          APPEND lw_opercd TO s_opcode.

          lw_opercd-low = 'LOOP WHERE COND'. "Added on 22.10.2020
          APPEND lw_opercd TO s_opcode.

          lw_opercd-low = 'INCOMPATIBLE CLASS PARAMETERS'. "Added on 12.2.2020
          APPEND lw_opercd TO s_opcode.

          lw_opercd-low = 'EXPONENTIAL OPERATOR'. "Added on 12.2.2020 #Defect 374
          APPEND lw_opercd TO s_opcode.

          lw_opercd-low = 'SELECT STATEMENT'. "Added by Jeba on 30.12.2020 #CR560 & CR#561
          APPEND lw_opercd TO s_opcode.

          lw_opercd-low = 'UPDATE/DELETE'. "Added by Jeba on 30.12.2020 #CR560 & CR#561
          APPEND lw_opercd TO s_opcode.
          "EOC by Jeba 17.08.2020
          CLEAR : lv_flag7, lw_opercd.
        ENDIF.
      ENDIF.
    ENDIF.
*Begin of changes by Sakshi Green IT 17/05/2022
    IF mytab-activetab = 'PUSH6'.
      IF c_main  EQ 'X'.
        REFRESH s_op_gi1.
        lw_opercd-sign = 'I'.
        lw_opercd-option = 'EQ'.
        lw_opercd-low = 'Identify Unused Custom Inventory'.
        APPEND lw_opercd TO s_op_gi1.
        CLEAR lw_opercd-low.
        lw_opercd-low = 'Identify clone objects'. "changed by shikha for CR 839 on 03 March 2022
        APPEND lw_opercd TO s_op_gi1.
        ELSE."added by nancy if checkbox is not selected
          REFRESH s_op_gi1.
      ENDIF.

      IF c_qual  EQ 'X'.
        REFRESH s_op_gi2.
        lw_opercd-sign = 'I'.
        lw_opercd-option = 'EQ'.
        lw_opercd-low = 'Identify Existing Errors in the Custom code'.
        APPEND lw_opercd TO s_op_gi2.
        ELSE. "added by nancy if checkbox is not selected
          REFRESH s_op_gi2.
      ENDIF.

      IF c_per EQ 'X'.
        REFRESH s_op_gi3.
        lw_opercd-sign = 'I'.
        lw_opercd-option = 'EQ'.
        lw_opercd-low = 'Avoid - SELECT * for the unwanted table fields '.
        APPEND lw_opercd TO s_op_gi3.
        CLEAR lw_opercd-low.

        lw_opercd-low = 'Avoid SELECT statements Without WHERE clause'. "changed by shikha for CR 839 on 03 March 2022
        APPEND lw_opercd TO s_op_gi3.

        lw_opercd-low = 'Tenuous USE OF FOR ALL ENTRIES'. "changed by shikha for CR 839 on 03 March 2022
        APPEND lw_opercd TO s_op_gi3.
        ELSE."added by nancy if checkbox is not selected
          REFRESH s_op_gi3.

      ENDIF.

    ENDIF.
*   *End of changes by Sakshi Green IT 17/05/2022
*S4 Extra Utilities
    IF p_xt1 NE 'X'.
      IF screen-group1 EQ 'XT1'.
        screen-active = 0.
        screen-input = 0.
        screen-invisible = 1.
      ENDIF.
    ENDIF.

    IF p_xt2 NE 'X'.
      IF screen-group1 EQ 'XT2'.
        screen-active = 0.
        screen-input = 0.
        screen-invisible = 1.
      ENDIF.
    ENDIF.
    IF screen-name = 'P_XT3'. "ADDED BY PARUL PURI TO HIDE OLD CLONE RADIO BUTTON
      screen-input = 0.
      screen-invisible = 1.
      MODIFY SCREEN.
    ENDIF.

    IF p_xt3 NE 'X'.
      IF screen-group1 EQ 'XT3'.
        screen-active = 0.
        screen-input = 0.
        screen-invisible = 1.
      ENDIF.
    ENDIF.

    IF p_xt4 NE 'X'.
      IF screen-group1 EQ 'XT4'.
        screen-active = 0.
        screen-input = 0.
        screen-invisible = 1.
      ENDIF.
    ENDIF.

    IF p_xt5 NE 'X'.
      IF screen-group1 EQ 'XT5'.
        screen-active = 0.
        screen-input = 0.
        screen-invisible = 1.
      ENDIF.
    ENDIF.

    IF p_xt6 NE 'X'.
      IF screen-group1 EQ 'XT6'.
        screen-active = 0.
        screen-input = 0.
        screen-invisible = 1.
      ENDIF.
    ENDIF.

    IF p_xt7 NE 'X'.
      IF screen-group1 EQ 'XT7'.
        screen-active = 0.
        screen-input = 0.
        screen-invisible = 1.
      ENDIF.
    ENDIF.

    IF p_xt8 NE 'X'.
      IF screen-group1 EQ 'XT8'.
        screen-active = 0.
        screen-input = 0.
        screen-invisible = 1.
      ENDIF.
    ENDIF.
    IF screen-name = 'P_XT8'. "ADDED BY PARUL PURI TO HIDE CHDOC RADIO BUTTON
      screen-input = 0.
      screen-invisible = 1.
      MODIFY SCREEN.
    ENDIF.
    IF p_xt9 NE 'X'.
      IF screen-group1 EQ 'XT9'.
        screen-active = 0.
        screen-input = 0.
        screen-invisible = 1.
      ENDIF.
    ENDIF.

    " Impacted Batchjob
    IF p_xt10 NE 'X'.
      IF screen-group1 EQ 'X12'.
        screen-active = 0.
        screen-input = 0.
        screen-invisible = 1.
      ENDIF.
    ENDIF.
    "Start of change by PSR on 22nd Jan 2020
    "Inconsistent FUGR
    IF p_xt11 NE 'X'.
      IF screen-group1 EQ 'XT11'.
        screen-active = 0.
        screen-input = 0.
        screen-invisible = 1.
      ENDIF.
    ENDIF.
    "End of change by PSR

    "Start of change by PSR on 18th Feb 2020
    "New Clone analysis
    IF p_xt12 NE 'X'.
      IF screen-group1 EQ 'XT12'.
        screen-active = 0.
        screen-input = 0.
        screen-invisible = 1.
      ENDIF.
    ENDIF.

    " Version comp - Start here - Sunil
    IF p_xt20 NE 'X'  .
      IF screen-group1 EQ 'VCP'.
        screen-active = 0.
        screen-input = 0.
        screen-invisible = 1.
      ENDIF.

      IF screen-group1 EQ 'VCK'.
        screen-active = 0.
        screen-input = 0.
        screen-invisible = 1.
      ENDIF.
      IF screen-group1 EQ 'VCG'.
        screen-active = 0.
        screen-input = 0.
        screen-invisible = 1.
      ENDIF.

      IF p_obj NE 'X'  .
        IF screen-group1 EQ 'VCK'.
          screen-active = 0.
          screen-input = 0.
          screen-invisible = 1.
        ENDIF.
*        IF screen-name EQ 'S_NAM2'
*          OR screen-name EQ 'S_OBJ2'.
**          OR screen-name EQ 'S_RFC2'.
*          screen-active = 0.
*          screen-input = 0.
*          screen-invisible = 1.
*        ENDIF."
      ENDIF.
      IF p_var_id NE 'X'  .
        IF screen-group1 EQ 'VCG'.
          screen-active = 0.
          screen-input = 0.
          screen-invisible = 1.
        ENDIF.
      ENDIF.
    ELSEIF p_xt20 IS NOT INITIAL. "Hinding the sub fields
      IF p_var_id EQ 'X'.
        IF screen-group1 EQ 'VCK'.
          screen-active = 0.
          screen-input = 0.
          screen-invisible = 1.
        ENDIF.
      ELSEIF p_obj EQ 'X'.
        IF screen-group1 EQ 'VCG'.
          screen-active = 0.
          screen-input = 0.
          screen-invisible = 1.
        ENDIF.
      ENDIF.
    ENDIF.
    " Version comp - Sunil- END here

*    Added by Rahul to hide this field
*    IF gv_cvit_ck IS INITIAL.
*    IF p_xt13 NE 'X'.
*      IF screen-name EQ 'P_XT13'.
*        screen-active = 0.
*        screen-input = 0.
*        screen-invisible = 1.
*      ENDIF.
*
*      IF screen-name EQ 'P_XT14'.
*        screen-active = 0.
*        screen-input = 0.
*        screen-invisible = 1.
*      ENDIF.
***    ENDIF.
*    ENDIF.
    "End of change by PSR

**   BOC Added by Rahul Defect#285
    IF p_xt15 NE 'X'." OR r_cust NE 'X' OR r_obj NE 'X'.
      IF screen-group1 EQ 'X15' OR screen-group1 EQ 'X16' OR screen-group1 EQ 'X17' OR screen-group1 EQ 'X18' OR screen-group1 EQ 'X50'.
        screen-active = 0.
        screen-input = 0.
        screen-invisible = 1.
      ENDIF.
    ELSEIF p_xt15 EQ 'X'.
      IF r_cust NE 'X'.
        IF screen-group1 EQ 'X16' OR screen-group1 EQ 'X17'.
          screen-active = 0.
          screen-input = 0.
          screen-invisible = 1.
        ENDIF.
      ELSEIF r_cust EQ 'X'.
        IF screen-group1 EQ 'X16'.
          screen-active = 1.
          screen-input = 1.
          screen-invisible = 0.
        ENDIF.
        IF r_obj EQ 'X'.
          IF screen-group1 EQ 'X17'.
            screen-active = 1.
            screen-input = 1.
            screen-invisible = 0.
          ENDIF.
        ENDIF.
        IF r_obj NE 'X'.
          IF screen-group1 EQ 'X17'.
            screen-active = 0.
            screen-input = 0.
            screen-invisible = 1.
          ENDIF.
        ENDIF.
      ENDIF.
****** BOC BY PARUL PURI FOR DEFECT ID - 556.
      IF r_man NE 'X'.
        IF screen-group1 EQ 'X18' OR screen-group1 EQ 'X50'.
          screen-active = 0.
          screen-input = 0.
          screen-invisible = 1.
        ENDIF.
      ENDIF.
      IF r_man EQ 'X'.
        IF screen-group1 EQ 'X18'.
          screen-active = 1.
          screen-input = 1.
          screen-invisible = 0.
        ENDIF.
      ENDIF.
****** EOC BY PARUL PURI FOR DEFECT ID - 556.
    ENDIF.
**   EOC Added by Rahul Defect#285

*    IF gv_bw IS INITIAL. "ADDED BY PARUL PURI FOR BW CLEANUP
*      IF screen-name EQ 'P_XT16'.
*        screen-active = 0.
*        screen-input = 0.
*        screen-invisible = 1.
*      ENDIF.
*    ENDIF.
    IF p_xt16 NE 'X'." OR r_cust NE 'X' OR r_obj NE 'X'.
      IF screen-group1 EQ 'X20'.
        screen-active = 0.
        screen-input = 0.
        screen-invisible = 1.
      ENDIF.
      IF screen-group1 EQ 'X21'.
        screen-active = 0.
        screen-input = 0.
        screen-invisible = 1.
      ENDIF.
    ELSEIF p_xt16 EQ 'X'.
      IF p_usg NE 'X'.
        IF screen-group1 EQ 'X21'.
          screen-active = 0.
          screen-input = 0.
          screen-invisible = 1.
        ENDIF.
      ENDIF.
    ENDIF.
** EOC by Shivani, BW cleanup, 24.08.2020
*BOC by Jeba for CR 811 on 01/12/2021 Clone
    IF p_xt12 NE 'X'.
      IF screen-group1 EQ 'CLO'.
        screen-active = 0.
        MODIFY SCREEN.
      ENDIF.
    ELSEIF p_xt12 EQ 'X'.
      IF screen-group1 EQ 'CLO'.
        screen-active = 1.
        MODIFY SCREEN.
      ENDIF.
    ENDIF.
*EOC by Jeba for CR 811 on 01/12/2021
*    IF p_xt21 NE 'X'.
*     IF screen-group1 EQ 'P50'.
*        screen-active = 0.
*        screen-input = 0.
*        screen-invisible = 1.
*     ENDIF.
*    ENDIF.
*  BOC Added by Rahul Defect#140 11/25/2020
    IF p_xt18 NE 'X'.
*      IF screen-name EQ 'P_XT18'.
      IF screen-group1 EQ 'T18'.
        screen-active = 0.
        screen-input = 0.
        screen-invisible = 1.
      ENDIF.
    ELSE.
      IF screen-group1 EQ 'T18'.
        screen-active = 1.
        screen-input = 1.
        screen-invisible = 0.
      ENDIF.
*      ENDIF.
    ENDIF.
*  BOC Added by Rahul Defect#140 11/25/2020
*BOC by Gunjan on 13/10/2020 For Variant utility CR 433
    "Search variant Utility
    IF p_xt17 NE 'X'.
      IF screen-group1 EQ 'P1' OR screen-group1 EQ 'DEL' OR screen-group1 EQ 'RV1' OR screen-group1 EQ 'RV2'
        OR screen-group1 EQ 'G1' OR screen-group1 EQ 'G2'
*        screen-group1 EQ 'G3'
        OR screen-group1 EQ 'G8'
        OR screen-group1 EQ 'RGP'.
        screen-active = 0.
        screen-input = 0.
        screen-invisible = 1.
      ENDIF.
    ELSEIF  p_xt17 EQ 'X'.
*      IF screen-group1 EQ 'P1' OR screen-group1 EQ 'DEL' OR screen-group1 EQ 'RG2' OR screen-group1 EQ 'RG1'
*        OR screen-group1 EQ 'G1' OR screen-group1 EQ 'G2' OR screen-group1 EQ 'G3' OR screen-group1 EQ 'G8'
*        OR screen-group1 EQ 'RGP'.
*        screen-active = 1.
*        screen-input = 1.
*        screen-invisible = 0.
*      ENDIF.
      IF p_smp = 'X'.
        IF screen-group1 = 'G3' .
          screen-active = 0.
          MODIFY SCREEN.
        ENDIF.
        IF screen-group1 = 'G2' .
          screen-active = 1.
          MODIFY SCREEN.
        ENDIF.
        IF screen-group1 = 'RV1' .
          screen-active = 1.
          MODIFY SCREEN.
        ENDIF.
        IF screen-group1 = 'G1'.
          screen-active = 0.
          MODIFY SCREEN.
        ENDIF.
        IF screen-group1 = 'RV2' .
          screen-active = 0.
          MODIFY SCREEN.
        ENDIF.


        IF screen-group1 = 'RV1' .
          screen-active = 0.
          MODIFY SCREEN.
        ENDIF.
        IF screen-group1 = 'RV1' .
          screen-active = 0.
          MODIFY SCREEN.
        ENDIF.
        IF screen-group1 = 'G8' .
          screen-active = 0.
          MODIFY SCREEN.
        ENDIF.
        IF screen-group1 = 'DEL' .
          screen-active = 0.
          MODIFY SCREEN.
        ENDIF.

      ELSEIF p_upd = 'X'.
        IF screen-group1 = 'G1'.
          screen-active = 0.
          MODIFY SCREEN.
        ENDIF.

        IF screen-group1 = 'G3' .
          screen-active = 1.
          MODIFY SCREEN.
        ENDIF.

        IF screen-group1 = 'G2' .
          screen-active = 0.
          MODIFY SCREEN.
        ENDIF.

        IF screen-group1 = 'RV2' .
          screen-active = 0.
          MODIFY SCREEN.
        ENDIF.
        IF p_excel = 'X'  .
          IF screen-group1 = 'RV1 ' .
            screen-active = 1.
            MODIFY SCREEN.
          ENDIF.
        ELSE.
*        IF p_excel ne 'X'.
          IF screen-group1 = 'RV1' .
            screen-active = 0.
            MODIFY SCREEN.
          ENDIF.
          IF screen-group1 = 'RGP' .
            screen-active = 0.
            MODIFY SCREEN.
          ENDIF.
*        ENDIF.
        ENDIF.
      ELSE.
        IF p_excel = 'X'  .
          IF screen-group1 = 'RV1' .
            screen-active = 1.
            MODIFY SCREEN.
          ENDIF.
        ELSE.
*        IF p_alv = 'X'.
          IF screen-group1 = 'RV1' .
            screen-active = 0.
            MODIFY SCREEN.
          ENDIF.
          IF screen-group1 = 'RGP' .
            screen-active = 0.
            MODIFY SCREEN.
          ENDIF.
*        ENDIF.
        ENDIF.

        IF p_pro = 'X'.
          IF screen-group1 = 'G3' .
            screen-active = 0.
            MODIFY SCREEN.
          ENDIF.
          IF screen-group1 = 'G2' .
            screen-active = 1.
            MODIFY SCREEN.
          ENDIF.
        ELSEIF p_upl = 'X'.
          IF screen-group1 = 'G3' .
            screen-active = 1.
            MODIFY SCREEN.
          ENDIF.
          IF screen-group1 = 'G2' .
            screen-active = 0.
            MODIFY SCREEN.
          ENDIF.
        ENDIF.

        IF screen-group1 = 'DEL' .
          screen-active = 0.
          MODIFY SCREEN.
        ENDIF.
      ENDIF.
    ENDIF.
*EOC by Gunjan on 13/10/2020 For Variant utility CR 433
*BOC by Anurag for cr 832 on 04/01/2022
    IF p_xt23 NE 'X'.
      IF screen-group1 EQ 'BWE'.
        screen-active = 0.
        screen-input = 0.
        screen-invisible = 1.
        MODIFY SCREEN.
      ENDIF.
    ELSEIF p_xt23 EQ 'X'.
      IF screen-group1 EQ 'BWE'.
        screen-active = 1.
        screen-input = 1.
        screen-invisible = 0.
        MODIFY SCREEN.
      ENDIF.
    ENDIF.
*EOC by Anurag for cr 832 on 04/01/2022

    IF mytab-activetab = 'PUSH4'.
      IF screen-group1 EQ 'CHK' .
        screen-active = 0.
        screen-invisible = 1.
      ENDIF.
    ENDIF.

*   CHANGESONAL
*   UI5
    IF c_ui5 NE 'X'.
      IF screen-group1 EQ 'UI5'.
        screen-active = 0.
        screen-invisible = 1.
      ENDIF.
    ENDIF.
    IF screen-group1 = 'UI5' AND screen-name = 'P_RFC2'.
      screen-input = 0.
    ENDIF.
*   UI5
    MODIFY SCREEN.
    IF screen-group1 = 'G3' AND screen-name = 'S_RFC'.
      screen-input = 0.
      MODIFY SCREEN.
    ENDIF.

*   BOC SONAL FOR FIORI OBJ_NAME AUTO FILL
    IF p_odata EQ 'X' AND s_obj IS INITIAL.
      s_obj-sign = 'I'.
      s_obj-option = 'CP'.
      s_obj-low = 'Z*'.
      APPEND s_obj.
      s_obj-low = 'Y*'.
      APPEND s_obj.
    ENDIF.
*   EOC SONAL FOR FIORI OBJ_NAME AUTO FILL

****boc by shikha on 20/02/2020 for FCV/LCV.
    IF fcv_a = 'X'.
*      IF screen-group1 = 'LC1'
*        OR screen-group1 = 'LC2'
*        OR screen-group1 = 'LC3'
*        OR screen-group1 = 'LC4'
*        OR screen-group1 = 'LC5'
*        OR screen-group1 = 'LC6'
*        OR screen-group1 = 'LC7'
*        OR screen-group1 = 'LC8'
*        OR screen-group1 = 'LC9'.
*        screen-active = 0.
      IF screen-group1 = 'FC1' OR screen-group1 = 'FC3'. "Added by Jeba for #683 on 16.04.2021
        screen-active = 1.
        MODIFY SCREEN.
      ENDIF.
      IF s_rad IS NOT INITIAL AND screen-group1 = 'FC4'.
        screen-active = 0.
        MODIFY SCREEN.
      ENDIF.
    ELSE.
      IF screen-group1 = 'FC1' OR screen-group1 = 'FC3' OR screen-group1 = 'FC4'.
        screen-active = 0.
        MODIFY SCREEN.
      ENDIF.
    ENDIF.

    IF lcv_a = 'X'.
*      IF screen-group1 = 'FC1'
*     OR screen-group1 = 'FC2'
*     OR screen-group1 = 'FC3'
*     OR screen-group1 = 'FC4'
*     OR screen-group1 = 'FC5'
*     OR screen-group1 = 'FC6'
*     OR screen-group1 = 'FC7'
*     OR screen-group1 = 'FC8'
*     OR screen-group1 = 'FC9'
*     OR screen-group1 = 'FC0'
*     OR screen-group1 = 'F11'
*     OR screen-group1 = 'F12' .
*        screen-active = 0.
      IF screen-group1 = 'LC1' OR screen-group1 = 'LC3'. "Added by Jeba for #683 on 16.04.2021
        screen-active = 1.
        MODIFY SCREEN.
      ENDIF.
      IF s_rad1 IS NOT INITIAL AND screen-group1 = 'LC4'.
        screen-active = 0.
        MODIFY SCREEN.
      ENDIF.
    ELSE.
      IF screen-group1 = 'LC1' OR screen-group1 = 'LC3' OR screen-group1 = 'LC4'.
        screen-active = 0.
        MODIFY SCREEN.
      ENDIF.
    ENDIF.
****eoc by shikha on 20/02/2020 for FCV/LCV.
    "BOC by Jeba 11.08.2020
    IF c_s42 IS NOT INITIAL.
      IF  screen-group1 = 'L19'.
        screen-active = 1.
        MODIFY SCREEN.
      ENDIF.
    ELSE.
      IF  screen-group1 = 'L19'.
        screen-active = 0.
        MODIFY SCREEN.
      ENDIF.
    ENDIF.
    "EOC by Jeba 11.08.2020
*  BOC Added by Rahul Defect#425 08/31/2020
    IF screen-group1 = 'CDS'.
      screen-active = 0.
      MODIFY SCREEN.
    ENDIF.
*  EOC Added by Rahul Defect#425 08/31/2020
*  BOC by Jeba for #956 on 12/10/2021
    IF c_print IS NOT INITIAL.
      IF screen-name CS 'P_LINE'.
        screen-active = 1.
        MODIFY SCREEN.
      ENDIF.
    ELSEIF c_print IS INITIAL.
      IF screen-name CS 'P_LINE'.
        screen-active = 0.
        MODIFY SCREEN.
      ENDIF.
    ENDIF.
*  EOC by Jeba #956 on 12/10/2021
*** BOC by Palani for CR 881 on 14/10/2021
    IF p_query NE 'X'.
      IF screen-group1 = 'QUE' OR screen-group1 = 'QV1' OR screen-group1 = 'QV2'.
        screen-active = 0.
        screen-input = 0.
        screen-invisible = 1.
      ENDIF.
    ELSEIF p_query EQ 'X'.
      IF screen-group1 = 'QUE'.
        screen-active = 1.
        screen-input = 1.
        screen-invisible = 0.
      ELSEIF screen-group1 = 'QV1'.
        IF p_qinv EQ 'X'.
          screen-active = 1.
          screen-input = 0.
          screen-invisible = 0.
        ELSEIF p_qdet EQ 'X'.
          screen-active = 0.
          screen-input = 0.
          screen-invisible = 1.
        ENDIF.
      ELSEIF screen-group1 = 'QV2'.
        IF p_qinv EQ 'X'.
          screen-active = 0.
          screen-input = 0.
          screen-invisible = 1.
        ELSEIF p_qdet EQ 'X'.
          screen-active = 1.
          screen-input = 1.
          screen-invisible = 0.
        ENDIF.
      ENDIF.
    ENDIF.
    MODIFY SCREEN.
*** EOC by Palani for CR 881 on 14/10/2021
*** BOC by Palani for CR 814 on 02/12/2021
    IF c_dobj = 'X'.
      IF screen-group1 EQ 'APP'.
        screen-active = 0.
      ENDIF.
      IF screen-group1 EQ 'VI2'.
        screen-active = 0.
      ENDIF.

      IF r_dvar IS NOT INITIAL.
        IF screen-group1 = 'DOB' OR screen-group1 = 'DFI'.
          screen-active = 0.
        ENDIF.
      ELSEIF r_dobj IS NOT INITIAL.
        IF screen-group1 = 'DVA' OR screen-group1 = 'DFI'.
          screen-active = 0.
        ENDIF.
      ELSEIF r_dfil IS NOT INITIAL.
        IF screen-group1 = 'DVA' OR screen-group1 = 'DOB'.
          screen-active = 0.
        ENDIF.
      ENDIF.

      MODIFY SCREEN.
    ELSE.
      IF screen-group1 = 'OBJ' OR screen-group1 = 'DVA'
        OR screen-group1 = 'DOB' OR screen-group1 = 'DFI'.
        screen-active = 0.
      ENDIF.
      MODIFY SCREEN.
    ENDIF.
*** EOC by Palani for CR 814 on 02/12/2021
  ENDLOOP.
***BOC by deepika for CR 813 on 01/12/2021

  LOOP AT SCREEN.
    IF p_upload NE 'X'.
      IF screen-group1 = 'LFT' OR screen-group1 = 'IMP' OR screen-group1 = 'PER'.
        screen-active = 0.
        screen-invisible = 1.

      ENDIF.
      MODIFY SCREEN.
    ENDIF.
    IF p_down NE 'X'.
      IF screen-group1 = 'L01' OR screen-group1 = 'IND' OR screen-group1 = 'TR' OR
         screen-group1 = 'PAC' OR screen-group1 = 'FIL' OR screen-group1 = 'L02' OR screen-group1 = 'L03'.
        screen-active = 0.
        screen-invisible = 1.

      ENDIF.
      MODIFY SCREEN.
    ENDIF.
    IF impo NE 'X'.
      IF screen-group1 = 'IMP'.

        screen-active = 0.
        screen-invisible = 1.

      ENDIF.
      MODIFY SCREEN.
    ENDIF.

    IF r_ind NE 'X'.
      IF screen-group1 = 'IND'.

        screen-active = 0.
        screen-invisible = 1.

      ENDIF.
      MODIFY SCREEN.
    ENDIF.

    IF r_tr NE 'X'.
      IF screen-group1 = 'TR'.

        screen-active = 0.
        screen-invisible = 1.

      ENDIF.
      MODIFY SCREEN.
    ENDIF.

    IF r_pack NE 'X'.
      IF screen-group1 = 'PAC'.

        screen-active = 0.
        screen-invisible = 1.

      ENDIF.
      MODIFY SCREEN.
    ENDIF.

    IF r_file1 NE 'X'.
      IF screen-group1 = 'FIL'.

        screen-active = 0.
        screen-invisible = 1.

      ENDIF.
      MODIFY SCREEN.
    ENDIF.
  ENDLOOP.
***EOC by deepika for CR 813 on 01/12/2021
  IF s_group[] IS  INITIAL.
    gs_grp-sign = 'I'.
    gs_grp-option = 'CP'.
    gs_grp-low = 'Z*'.
    APPEND gs_grp TO s_group.
    gs_grp-sign = 'I'.
    gs_grp-option = 'CP'.
    gs_grp-low = 'Y*'.
    APPEND gs_grp TO s_group.
  ENDIF.
*  data :it_tab TYPE TABLE OF screen,
*        wa type screen.
* loop at screen.
*   wa = screen.
*   append wa to it_tab.
*   endloop.
ENDFORM.
FORM sub_validation.
*** BOC by Palani for CR 835 on 24/09/2021
  DATA: lv_flg TYPE i.
  DATA: lv_ans(1) TYPE c,
        "  BOC by Nancy for Defect Id 1071 on 29th dec.
        lv_plen   TYPE i.
  "EOC by Nancy for Defect Id 1071 on 29th dec.
*** EOC by Palani for CR 835 on 24/09/2021
  IF  mytab-activetab = 'PUSH2' OR  mytab-activetab = 'PUSH3'.
    IF ( c_upg IS INITIAL AND c_hana IS INITIAL AND c_s4 IS INITIAL AND p_odata IS INITIAL
*         AND p_fiat IS INITIAL AND c_ui5 IS INITIAL AND c_cloud IS INITIAL AND c_ext IS INITIAL AND fcv_a IS INITIAL AND lcv_a IS INITIAL ) . " Added by Pooja Kalshetti " Changed by Manya on 24.03.2020
         AND p_fiat IS INITIAL AND c_ui5 IS INITIAL AND c_cloud IS INITIAL AND c_ext IS INITIAL AND fcv_a IS INITIAL AND lcv_a IS INITIAL AND p_hcode IS INITIAL " Changed by Sonal Defect#614
         AND c_dobj IS INITIAL ). " Added by Palani for CR 814 on 02/12/2021
      MESSAGE i208(00) WITH 'Please select atleast one functionality.' DISPLAY LIKE 'S'.
      STOP.
    ENDIF.
*    IF p_g1 IS INITIAL AND p_g2 IS INITIAL .
*      MESSAGE 'Choose atleast one gateway' TYPE 'S' DISPLAY LIKE 'E'.
*      LEAVE LIST-PROCESSING.
*    ENDIF.
*    IF   ( c_upg2 IS INITIAL AND c_hana2 IS INITIAL AND c_s42 IS INITIAL ).
*      MESSAGE e208(00) WITH 'Please select atleast one functionality.' DISPLAY LIKE 'E'.
*    ENDIF.
  ENDIF.
*** BOC by Palani for CR 814 on 02/12/2021
  IF mytab-activetab = 'PUSH2'.
    IF c_dobj IS NOT INITIAL AND ( c_upg IS NOT INITIAL OR c_hana IS NOT INITIAL OR c_s4 IS NOT INITIAL
                                   OR p_odata IS NOT INITIAL OR p_fiat IS NOT INITIAL OR c_ui5 IS NOT INITIAL
                                   OR c_cloud IS NOT INITIAL ).
      MESSAGE 'Please select either one of the scopes or Dependent objects collection' TYPE 'S' DISPLAY LIKE 'E'.
      LEAVE LIST-PROCESSING.
    ENDIF.
*** BOC by Palani for CR 823 on 07/12/2021
    IF c_dobj IS NOT INITIAL.
      IF c_bg_job IS NOT INITIAL.
        MESSAGE 'Please execute in foreground' TYPE 'S' DISPLAY LIKE 'E'.
        LEAVE LIST-PROCESSING.
      ENDIF.
      IF r_dobj IS NOT INITIAL.
        IF p_objt IS INITIAL.
          MESSAGE 'Please enter Object type' TYPE 'S' DISPLAY LIKE 'E'.
          LEAVE LIST-PROCESSING.
        ELSE.
          READ TABLE lt_objt INTO ls_objt WITH KEY objt = p_objt.
          IF sy-subrc <> 0.
            MESSAGE 'Object type not supported' TYPE 'S' DISPLAY LIKE 'E'.
            LEAVE LIST-PROCESSING.
          ENDIF.
        ENDIF.
        IF s_objn IS INITIAL.
          MESSAGE 'Please enter Object name' TYPE 'S' DISPLAY LIKE 'E'.
          LEAVE LIST-PROCESSING.
        ENDIF.
      ELSEIF r_dvar IS NOT INITIAL.
        IF p_dvar IS INITIAL.
          MESSAGE 'Please enter Variant ID' TYPE 'S' DISPLAY LIKE 'E'.
          LEAVE LIST-PROCESSING.
        ENDIF.
      ELSEIF r_dfil IS NOT INITIAL.
        IF p_dfile IS INITIAL.
          MESSAGE 'Please select the input file' TYPE 'S' DISPLAY LIKE 'E'.
          LEAVE LIST-PROCESSING.
        ENDIF.
      ENDIF.
    ENDIF.
*** EOC by Palani for CR 823 on 07/12/2021
  ENDIF.
*** EOC by Palani for CR 814 on 02/12/2021
*BOC by Archana for Defect 909
  IF mytab-activetab = 'PUSH2'.
    IF p_varid2 IS INITIAL AND s_obj[] IS INITIAL AND p_fiat IS INITIAL "Added by Jeba on 22/10/2021 for #998 - Not Aplicable for Fiat
      AND c_dobj IS INITIAL.  " Added by Palani for CR 814 - Not applicable for Dependent objects collection
      MESSAGE 'Please select atleast one between Variant ID and Object Name' TYPE 'I'.
      STOP.
    ENDIF.
  ENDIF.
*EOC by Archana for Defect 909
*** BOC by Palani for CR 835 on 24/09/2021
  IF mytab-activetab = 'PUSH2'.
    IF p_varid2 IS NOT INITIAL.
      CLEAR lv_flg.
      IF p_hcode IS NOT INITIAL.
        lv_flg = lv_flg + 1.
      ENDIF.
      IF c_upg IS NOT INITIAL.
        lv_flg = lv_flg + 1.
      ENDIF.
      IF c_hana IS NOT INITIAL.
        lv_flg = lv_flg + 1.
      ENDIF.
      IF c_s4 IS NOT INITIAL.
        lv_flg = lv_flg + 1.
      ENDIF.
      IF p_fiat IS NOT INITIAL.
        lv_flg = lv_flg + 1.
      ENDIF.
      IF c_cloud IS NOT INITIAL.
        lv_flg = lv_flg + 1.
      ENDIF.
      IF c_ext IS NOT INITIAL.
        lv_flg = lv_flg + 1.
      ENDIF.
      IF c_ui5 IS NOT INITIAL.
        lv_flg = lv_flg + 1.
      ENDIF.
      IF p_odata IS NOT INITIAL.
        lv_flg = lv_flg + 1.
      ENDIF.

      IF lv_flg GT 1.
        CALL FUNCTION 'POPUP_TO_CONFIRM'
          EXPORTING
            titlebar              = 'Please use different Variant IDs for each Scope'
            text_question         = 'Proceed with multiple scopes?'
            display_cancel_button = ' '
          IMPORTING
            answer                = lv_ans
          EXCEPTIONS
            text_not_found        = 1
            OTHERS                = 2.
        IF sy-subrc = 0.
          IF lv_ans = '2'.
            STOP.
          ENDIF.
        ENDIF.
      ENDIF.
    ENDIF.
  ENDIF.
*** EOC by Palani for CR 835 on 24/09/2021
  IF mytab-activetab = 'PUSH3'.
    " BOC commented by Ruchir for defect 1010 on 18.11.2021
*    IF p_sid IS INITIAL AND c_cld2 IS INITIAL AND fcv_a IS INITIAL AND lcv_a IS INITIAL. "Changed by Manya for FCV/LCV on 24.03.2020
*      MESSAGE 'Session ID should not be blank' TYPE 'S'
*        DISPLAY LIKE 'E'.
*      LEAVE LIST-PROCESSING.
*    ENDIF.
*
*    IF s_prog IS INITIAL AND c_cld2 IS INITIAL AND fcv_a IS INITIAL AND lcv_a IS INITIAL. "Changed by Manya for FCV/LCV on 24.03.2020.
*      MESSAGE 'Program Name should not be blank' TYPE 'S'
*        DISPLAY LIKE 'E'.
*      LEAVE LIST-PROCESSING.
*    ENDIF.
*
*    IF p_tr IS INITIAL AND c_cld2 IS INITIAL AND fcv_a IS INITIAL AND lcv_a IS INITIAL. "Changed by Manya for FCV/LCV on 24.03.2020.
*      MESSAGE 'Transport should not be blank' TYPE 'S'
*       DISPLAY LIKE 'E'.
*      LEAVE LIST-PROCESSING.
*    ENDIF.
    " EOC by Ruchir for defect 1010 on 18.11.2021

*BOC by Jeba for #956 on 12/10/2021
    IF p_line IS NOT INITIAL AND p_line > 255.
      MESSAGE 'Exceeded maximum word wrap for page width (255)' TYPE 'S' DISPLAY LIKE 'E'.
      LEAVE LIST-PROCESSING.
    ELSEIF p_line IS INITIAL AND c_print IS NOT INITIAL.
      MESSAGE 'Word Wrap for page width should not be blank' TYPE 'S'
        DISPLAY LIKE 'E'.
      LEAVE LIST-PROCESSING.
    ENDIF.
*EOC by Jeba for #956 on 12/10/2021
  ENDIF.
  IF mytab-activetab = 'PUSH2'.
    IF c_cloud IS NOT INITIAL AND c_logpat IS NOT INITIAL AND p_src1 IS INITIAL."Defect#321 Added by Parul on 29/7/2020
      MESSAGE 'Please fill source os.' TYPE 'S'
      DISPLAY LIKE 'E'.
      LEAVE LIST-PROCESSING.
    ENDIF.
  ENDIF.
*  IF r_file IS NOT INITIAL AND p_file IS INITIAL.
*    MESSAGE s208(00) WITH 'Please select file path' DISPLAY LIKE 'E'.
*  ENDIF.



  IF mytab-activetab = 'PUSH4'.
*BOC by Nancy for ID:910 on 8th sep 2021
    IF ( p_xt2 IS NOT INITIAL ).
      IF ( p_scmon IS INITIAL AND p_st03 IS INITIAL AND p_rfc IS INITIAL ).
        MESSAGE 'Please provide the file names.' TYPE 'I'  DISPLAY LIKE 'E'.
        LEAVE LIST-PROCESSING.
      ENDIF.
    ENDIF.


*EOC by Nancy for ID:910 on 8th sep 2021
*BOC by deepika pathak for defect#911 on 08 sep 2021.
    IF p_xt10 = 'X'.
      IF ( p_tbtcp IS INITIAL AND p_tbtco IS INITIAL  ).
        MESSAGE 'Please provide filenames.'TYPE 'I' DISPLAY LIKE 'E'.
        LEAVE LIST-PROCESSING.
      ENDIF.
    ENDIF.
*** BOC by Palani for CR 881 on 14/10/2021
    IF p_query = 'X' AND p_qdet = 'X'.
      IF p_qvar2 IS INITIAL.
        MESSAGE 'Please provide Variant ID' TYPE 'I' DISPLAY LIKE 'E'.
        LEAVE LIST-PROCESSING.
        "      BOC by Nancy for Defect Id 1071 on 29th dec.
      ELSE.
        "DATA: lv_plen TYPE i.
        lv_plen = strlen( p_qvar2 ) - 3.
        IF  p_qvar2+lv_plen(3) NE '_AQ'.
          MESSAGE 'Invalid Variant ID' TYPE 'I' DISPLAY LIKE 'E'.
          LEAVE LIST-PROCESSING.
        ENDIF.
        "      EOC by Nancy for Defect Id 1071 on 29th dec.
      ENDIF.
      IF p_qhana IS INITIAL AND p_qs4 IS INITIAL.
        MESSAGE 'Please select atleast one scope' TYPE 'I' DISPLAY LIKE 'E'.
        LEAVE LIST-PROCESSING.
      ENDIF.
    ENDIF.
*** EOC by Palani for CR 881 on 14/10/2021
  ENDIF.
*EOC by deepika pathak for defect#911 on 08 sep 2021.

ENDFORM.
*BOC Gunjan 26/10/2020 " variant Utility CR 433
FORM validation.
  IF mytab-activetab = 'PUSH4' AND p_xt17 IS NOT INITIAL..
*  IF p_xt17 IS NOT INITIAL.
    IF p_get IS NOT INITIAL.

      IF p_str IS INITIAL.
        MESSAGE 'Enter the Srting to search' TYPE 'E' DISPLAY LIKE 'I'.
        LEAVE TO LIST-PROCESSING.
      ENDIF.

      IF p_pro IS NOT INITIAL.
        IF s_prog IS INITIAL.
          MESSAGE 'Enter the program name ' TYPE 'E' DISPLAY LIKE 'I'.
          LEAVE TO LIST-PROCESSING.
        ENDIF.
      ENDIF.
      IF p_upl IS NOT INITIAL.
        IF p_fileup IS INITIAL.
          MESSAGE 'Enter the File name to upload ' TYPE 'E' DISPLAY LIKE 'I'.
          LEAVE TO LIST-PROCESSING.
        ENDIF.
      ENDIF.
      IF p_excel IS NOT INITIAL.
        IF v_file IS INITIAL.
          MESSAGE 'Enter the File name to download ' TYPE 'E' DISPLAY LIKE 'I'.
          LEAVE TO LIST-PROCESSING.
        ENDIF.
      ENDIF.

    ELSEIF p_upd = 'X'.

      IF p_fileup IS INITIAL.
        MESSAGE 'Enter the File name to upload ' TYPE 'E' DISPLAY LIKE 'I'.
        LEAVE TO LIST-PROCESSING.
      ENDIF.

      IF p_excel IS NOT INITIAL.
        IF v_file IS INITIAL.
          MESSAGE 'Enter the File name to download ' TYPE 'E' DISPLAY LIKE 'I'.
          LEAVE TO LIST-PROCESSING.
        ENDIF.
      ENDIF.

    ELSEIF p_smp = 'X'.

      IF s_prog IS INITIAL.
        MESSAGE 'Enter the program name ' TYPE 'E' DISPLAY LIKE 'I'.
        LEAVE TO LIST-PROCESSING.
      ENDIF.
      IF v_file IS INITIAL.
        MESSAGE 'Enter the File name to upload ' TYPE 'E' DISPLAY LIKE 'I'.
        LEAVE TO LIST-PROCESSING.
      ENDIF.

    ENDIF.
    IF p_bg IS NOT INITIAL.
      CLEAR : v_file.
    ELSEIF p_fg IS NOT INITIAL.
      CLEAR : v_file.
    ENDIF.
  ENDIF.
ENDFORM.
*EOC Gunjan 26/10/2020 " variant Utility CR433
*FORM sub_f4_help_file.
*  DATA: lv_title TYPE string.
*  lv_title = 'Select File path for saving inventory file :'.
*  CALL METHOD cl_gui_frontend_services=>directory_browse
*    EXPORTING
*      window_title         = lv_title
*    CHANGING
*      selected_folder      = p_file
*    EXCEPTIONS
*      cntl_error           = 1
*      error_no_gui         = 2
*      not_supported_by_gui = 3
*      OTHERS               = 4.
*ENDFORM.
FORM sub_check_class USING p_cls_name
                        CHANGING lv_na TYPE char1.
  DATA:  clskey TYPE  seoclskey.
  clskey = p_cls_name.
*BOC by jagriti TASK 576 1/13/2021
  SELECT SINGLE funcname FROM tfdir INTO lv_cg_check_tfdir WHERE funcname = 'SEO_CLASS_EXISTENCE_CHECK'.
  IF sy-subrc EQ 0.
    CALL FUNCTION lv_cg_check_tfdir
      EXPORTING
        clskey        = clskey
      IMPORTING
        not_active    = lv_na
      EXCEPTIONS
        not_specified = 1
        not_existing  = 2
        is_interface  = 3
        no_text       = 4
        inconsistent  = 5
        OTHERS        = 6.
    IF sy-subrc = 0.
      lv_na = abap_false.
    ELSE.
      lv_na = abap_true.
    ENDIF.
  ELSEIF sy-subrc NE 0.
    MESSAGE 'SEO_CLASS_EXISTENCE_CHECK does not exist in this system' TYPE 'E'.
  ENDIF.
  CLEAR lv_cg_check_tfdir.
*EOC by jagriti TASK 576 1/13/2021
ENDFORM.

FORM f4_help USING field TYPE dynpread-fieldname CHANGING filename TYPE rlgrap-filename.
*BOC by jagriti TASK 576 1/13/2021
  SELECT SINGLE funcname FROM tfdir INTO lv_cg_check_tfdir WHERE funcname = 'F4_FILENAME'.
  IF sy-subrc EQ 0.
    CALL FUNCTION lv_cg_check_tfdir
      EXPORTING
        field_name = field
      IMPORTING
        file_name  = filename.
  ELSEIF sy-subrc NE 0.
    MESSAGE 'F4_FILENAME does not exist in this system' TYPE 'E'.
  ENDIF.
  CLEAR lv_cg_check_tfdir.
*EOC by jagriti TASK 576 1/13/2021
ENDFORM.

*&---------------------------------------------------------------------*
*& Form F4HELP_RFC
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*

FORM f4help_rfc CHANGING param.
  TYPES: BEGIN OF ty_rfc,
           rfcdest TYPE rfcdest,
         END OF ty_rfc.

  DATA: it_rfc TYPE STANDARD TABLE OF ty_rfc.
*BOC by jagriti TASK 576 1/14/2021
  SELECT SINGLE tabname FROM dd03l INTO lv_cg_check_dd03l WHERE tabname = 'RFCDES'.
  IF sy-subrc = 0.
    CLEAR lv_cg_check_dd03l.
    SELECT rfcdest FROM rfcdes INTO TABLE it_rfc.
  ELSEIF sy-subrc NE 0.
    MESSAGE 'rfcdes does not exist in DD03L' TYPE 'E'.
  ENDIF.

  SELECT SINGLE funcname FROM tfdir INTO lv_cg_check_tfdir WHERE funcname = 'F4IF_INT_TABLE_VALUE_REQUEST'.
  IF sy-subrc EQ 0.
    CALL FUNCTION lv_cg_check_tfdir
      EXPORTING
        retfield        = 'RFCDEST'
        dynpnr          = sy-dynnr
        dynpprog        = sy-repid
        dynprofield     = param
        value_org       = 'S'
        display         = 'F'
      TABLES
        value_tab       = it_rfc
*       FIELD_TAB       =
*       RETURN_TAB      = rfc
*       DYNPFLD_MAPPING =
      EXCEPTIONS
        parameter_error = 1
        no_values_found = 2
        OTHERS          = 3.
    IF sy-subrc <> 0.
    ENDIF.
  ELSEIF sy-subrc NE 0.
    MESSAGE 'F4IF_INT_TABLE_VALUE_REQUEST does not exist in this system' TYPE 'E'.
  ENDIF.
  CLEAR lv_cg_check_tfdir.
*EOC by jagriti TASK 576 1/13/2021
ENDFORM.

*BOC by Gunjan on 09/10/2019
*F4 help for application server filepath
FORM f4_help_appserver CHANGING filepath TYPE rlgrap-filename.
*BOC by jagriti TASK 576 1/13/2021
  SELECT SINGLE funcname FROM tfdir INTO lv_cg_check_tfdir WHERE funcname = '/SAPDMC/LSM_F4_SERVER_FILE'.
  IF sy-subrc EQ 0.
    CALL FUNCTION lv_cg_check_tfdir
      EXPORTING
        directory        = filepath
*       filemask         = '?'
      IMPORTING
        serverfile       = filepath
      EXCEPTIONS
        canceled_by_user = 1
        OTHERS           = 2.
    IF sy-subrc <> 0.
      MESSAGE e009(zz) WITH filepath.
    ENDIF.
  ELSEIF sy-subrc NE 0.
    MESSAGE '/SAPDMC/LSM_F4_SERVER_FILE does not exist in this system' TYPE 'E'.
  ENDIF.
  CLEAR lv_cg_check_tfdir.
*EOC by jagriti TASK 576 1/13/2021
ENDFORM.
*EOC by Gunjan on 09/10/2019
*&---------------------------------------------------------------------*
*& Form F4_HELP_TSC
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_
*&      <-- P_MANF
*&---------------------------------------------------------------------*
FORM f4_help_tsc USING field TYPE dynpread-fieldname CHANGING filename TYPE any." rlgrap-filename.

  CALL METHOD cl_gui_frontend_services=>directory_browse
    EXPORTING
      window_title         = 'Output File'
*     initial_folder       =
    CHANGING
      selected_folder      = lv_dir
    EXCEPTIONS
      cntl_error           = 1
      error_no_gui         = 2
      not_supported_by_gui = 3
      OTHERS               = 4.
  IF sy-subrc <> 0.
    MESSAGE 'Unable to read File path' TYPE gc_e DISPLAY LIKE gc_i.
  ELSE.

    filename = lv_dir.
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form F4_HELP_OPEN
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_
*&      <-- FILE_INV
*&---------------------------------------------------------------------*
FORM f4_help_open   USING  dynpread-fieldname CHANGING filename TYPE any.

  DATA: it_tab   TYPE filetable,
        ls_tab   TYPE file_table,
        lv_subrc TYPE i.
  CALL METHOD cl_gui_frontend_services=>file_open_dialog
    EXPORTING
      window_title     = 'Select File'
      default_filename = '*.txt'
    CHANGING
      file_table       = it_tab
      rc               = lv_subrc.

  READ TABLE it_tab INTO ls_tab INDEX 1.
  IF sy-subrc EQ 0.
    filename = ls_tab.
  ENDIF.
ENDFORM.
*BOC By Gunjan for search variant Utility CR 433
FORM help.
  DATA : l_pathname LIKE /sapdmc/lsscreen-pathname.
* F4 Help for file path
  IF p_fg IS NOT INITIAL.
*BOC by jagriti TASK 576 1/13/2021
    SELECT SINGLE funcname FROM tfdir INTO lv_cg_check_tfdir WHERE funcname = '/SAPDMC/LSM_F4_FRONTEND_FILE'.
    IF sy-subrc EQ 0.
      CALL FUNCTION lv_cg_check_tfdir
* EXPORTING
*   PATHNAME               =
        CHANGING
          pathfile         = l_pathname
        EXCEPTIONS
          canceled_by_user = 1
          system_error     = 2
          OTHERS           = 3.
      IF sy-subrc <> 0.
* Implement suitable error handling here
      ENDIF.
    ELSEIF sy-subrc NE 0.
      MESSAGE '/SAPDMC/LSM_F4_FRONTEND_FILE does not exist in this system' TYPE 'E'.
    ENDIF.
    CLEAR lv_cg_check_tfdir.
*EOC by jagriti TASK 576 1/13/2021
    v_file = l_pathname.

  ELSEIF p_bg IS NOT INITIAL.
    "f4 help for application server
*BOC by jagriti TASK 576 1/13/2021
    SELECT SINGLE funcname FROM tfdir INTO lv_cg_check_tfdir WHERE funcname = '/SAPDMC/LSM_F4_SERVER_FILE'.
    IF sy-subrc EQ 0.
      CALL FUNCTION lv_cg_check_tfdir
*   EXPORTING
*     DIRECTORY              = ' '
*     FILEMASK               = ' '
        IMPORTING
          serverfile       = v_file
        EXCEPTIONS
          canceled_by_user = 1
          OTHERS           = 2.
      IF sy-subrc <> 0.
* Implement suitable error handling here
      ENDIF.
    ELSEIF sy-subrc NE 0.
      MESSAGE '/SAPDMC/LSM_F4_SERVER_FILE does not exist in this system' TYPE 'E'.
    ENDIF.
    CLEAR lv_cg_check_tfdir.
*EOC by jagriti TASK 576 1/13/2021
  ENDIF.
  CONCATENATE v_file '.XLS' INTO v_file.
ENDFORM.

FORM upload.
  DATA : l_pathname LIKE /sapdmc/lsscreen-pathname.
*BOC by jagriti TASK 576 1/13/2021
  SELECT SINGLE funcname FROM tfdir INTO lv_cg_check_tfdir WHERE funcname = '/SAPDMC/LSM_F4_FRONTEND_FILE'.
  IF sy-subrc EQ 0.
    CALL FUNCTION lv_cg_check_tfdir
* EXPORTING
*   PATHNAME               =
      CHANGING
        pathfile         = l_pathname
      EXCEPTIONS
        canceled_by_user = 1
        system_error     = 2
        OTHERS           = 3.
    IF sy-subrc <> 0.
* Implement suitable error handling here
    ENDIF.
  ELSEIF sy-subrc NE 0.
    MESSAGE '/SAPDMC/LSM_F4_FRONTEND_FILE does not exist in this system' TYPE 'E'.
  ENDIF.
  CLEAR lv_cg_check_tfdir.
*EOC by jagriti TASK 576 1/13/2021
  p_fileup = l_pathname.

ENDFORM.
*EOC By Gunjan for search variant Utility CR433
*&---------------------------------------------------------------------*
*& Form f4_help_filepath
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      <-- P_ST03
*&---------------------------------------------------------------------*
*FORM f4_help_filepath  CHANGING p_p_st03.
*
*CALL FUNCTION 'F4_FILENAME'
* EXPORTING
*   PROGRAM_NAME        = SYST-CPROG
*   DYNPRO_NUMBER       = SYST-DYNNR
*   FIELD_NAME          = ' '
* IMPORTING
*   FILE_NAME           = p_p_st03
*          .
*
*
*ENDFORM.
*** BOC by Palani for CR 823 on 02/12/2021
*&---------------------------------------------------------------------*
*& Form cwrm_object_types
*&---------------------------------------------------------------------*
FORM cwrm_object_types.
  REFRESH lt_objt.
  ls_objt-objt = 'ACID'.
  ls_objt-text = 'Checkpoint Group'.
  APPEND ls_objt TO lt_objt.
  ls_objt-objt = 'CLAS'.
  ls_objt-text = 'Class (ABAP Objects)'.
  APPEND ls_objt TO lt_objt.
  ls_objt-objt = 'DOCV'.
  ls_objt-text = 'Documentation (Independent)'.
  APPEND ls_objt TO lt_objt.
  ls_objt-objt = 'DOMA'.
  ls_objt-text = 'Domain'.
  APPEND ls_objt TO lt_objt.
  ls_objt-objt = 'DTEL'.
  ls_objt-text = 'Data Element'.
  APPEND ls_objt TO lt_objt.
  ls_objt-objt = 'ENHO'.
  ls_objt-text = 'Enhancement Implementation'.
  APPEND ls_objt TO lt_objt.
  ls_objt-objt = 'ENHS'.
  ls_objt-text = 'Enhancement Spot'.
  APPEND ls_objt TO lt_objt.
  ls_objt-objt = 'ENQU'.
  ls_objt-text = 'Lock Object'.
  APPEND ls_objt TO lt_objt.
  ls_objt-objt = 'FUGR'.
  ls_objt-text = 'Function Group'.
  APPEND ls_objt TO lt_objt.
  ls_objt-objt = 'INDX'.
  ls_objt-text = 'Table Index'.
  APPEND ls_objt TO lt_objt.
  ls_objt-objt = 'INTF'.
  ls_objt-text = 'Interface (ABAP Objects)'.
  APPEND ls_objt TO lt_objt.
  ls_objt-objt = 'MSAG'.
  ls_objt-text = 'Message Class'.
  APPEND ls_objt TO lt_objt.
  ls_objt-objt = 'PARA'.
  ls_objt-text = 'SPA/GPA Parameters'.
  APPEND ls_objt TO lt_objt.
  ls_objt-objt = 'PROG'.
  ls_objt-text = 'Program'.
  APPEND ls_objt TO lt_objt.
  ls_objt-objt = 'SFPF'.
  ls_objt-text = 'Form Object: Form'.
  APPEND ls_objt TO lt_objt.
  ls_objt-objt = 'SFPI'.
  ls_objt-text = 'Form Object: Interface'.
  APPEND ls_objt TO lt_objt.
  ls_objt-objt = 'SHLP'.
  ls_objt-text = 'Search Help'.
  APPEND ls_objt TO lt_objt.
  ls_objt-objt = 'SICF'.
  ls_objt-text = 'ICF Service'.
  APPEND ls_objt TO lt_objt.
  ls_objt-objt = 'SMIM'.
  ls_objt-text = 'Info Object from the MIME Repository'.
  APPEND ls_objt TO lt_objt.
  ls_objt-objt = 'SSFO'.
  ls_objt-text = 'SAP Smart Form'.
  APPEND ls_objt TO lt_objt.
  ls_objt-objt = 'TABL'.
  ls_objt-text = 'Table'.
  APPEND ls_objt TO lt_objt.
  ls_objt-objt = 'TABT'.
  ls_objt-text = 'Technical Attributes of a Table'.
  APPEND ls_objt TO lt_objt.
  ls_objt-objt = 'TABU'.
  ls_objt-text = 'Table Contents'.
  APPEND ls_objt TO lt_objt.
  ls_objt-objt = 'TRAN'.
  ls_objt-text = 'Transaction'.
  APPEND ls_objt TO lt_objt.
  ls_objt-objt = 'VCLS'.
  ls_objt-text = 'View cluster'.
  APPEND ls_objt TO lt_objt.
  ls_objt-objt = 'VIET'.
  ls_objt-text = 'Technical Attributes of a View'.
  APPEND ls_objt TO lt_objt.
  ls_objt-objt = 'VIEW'.
  ls_objt-text = 'View'.
  APPEND ls_objt TO lt_objt.
  ls_objt-objt = 'WAPA'.
  ls_objt-text = 'BSP (Business Server Pages) Application'.
  APPEND ls_objt TO lt_objt.
  ls_objt-objt = 'WDCA'.
  ls_objt-text = 'Web Dynpro Application Configuration'.
  APPEND ls_objt TO lt_objt.
  ls_objt-objt = 'WDCC'.
  ls_objt-text = 'Web Dynpro Component Configuration'.
  APPEND ls_objt TO lt_objt.
  ls_objt-objt = 'WDYA'.
  ls_objt-text = 'Web Dynpro Application'.
  APPEND ls_objt TO lt_objt.
  ls_objt-objt = 'WDYN'.
  ls_objt-text = 'Web Dynpro Component'.
  APPEND ls_objt TO lt_objt.
  ls_objt-objt = 'WTAG'.
  ls_objt-text = 'BSP Extension'.
  APPEND ls_objt TO lt_objt.
  ls_objt-objt = 'XSLT'.
  ls_objt-text = 'Transformation'.
  APPEND ls_objt TO lt_objt.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form f4_cwrm_obj
*&---------------------------------------------------------------------*
FORM f4_cwrm_obj  USING field.
  SELECT SINGLE funcname FROM tfdir INTO lv_cg_check_tfdir WHERE funcname = 'F4IF_INT_TABLE_VALUE_REQUEST'.
  IF sy-subrc EQ 0.
    CALL FUNCTION lv_cg_check_tfdir
      EXPORTING
        retfield        = 'OBJT'
        dynpnr          = sy-dynnr
        dynpprog        = sy-repid
        dynprofield     = field
        value_org       = 'S'
        display         = 'F'
      TABLES
        value_tab       = lt_objt
*       FIELD_TAB       =
*       RETURN_TAB      = rfc
*       DYNPFLD_MAPPING =
      EXCEPTIONS
        parameter_error = 1
        no_values_found = 2
        OTHERS          = 3.
    IF sy-subrc <> 0.
    ENDIF.
  ELSEIF sy-subrc NE 0.
    MESSAGE 'F4IF_INT_TABLE_VALUE_REQUEST does not exist in this system' TYPE 'E'.
  ENDIF.
  CLEAR lv_cg_check_tfdir.
ENDFORM.
*** EOC by Palani for CR 823 on 02/12/2021
*** BOC by Palani for CR 814 on 06/12/2021
*&---------------------------------------------------------------------*
*& Form f4_cwrm_file
*&---------------------------------------------------------------------*
FORM f4_cwrm_file  USING field.
  DATA: lt_filetab TYPE filetable,
        lv_subrc   TYPE i.

  CLEAR lt_filetab.
  CALL METHOD cl_gui_frontend_services=>file_open_dialog
    EXPORTING
      multiselection    = abap_false
      default_extension = 'XLS'
    CHANGING
      file_table        = lt_filetab
      rc                = lv_subrc.

  IF lt_filetab IS NOT INITIAL.
    READ TABLE lt_filetab INTO p_dfile INDEX 1.
  ENDIF.
ENDFORM.
*** EOC by Palani for CR 814 on 06/12/2021

**BOC by Deepika for CR #813 on 07/12/2021
FORM f4_cwrm_nugfile  USING field.
  CALL METHOD cl_gui_frontend_services=>file_open_dialog
    EXPORTING
      multiselection    = abap_false
      file_filter       = 'Nugget files (*.nugg)|*.nugg|'
      default_extension = 'nugg'
    CHANGING
      file_table        = retfiletable
      rc                = retrc
      user_action       = retuseraction.
  READ TABLE retfiletable INTO nugfile INDEX 1.
ENDFORM.


*&---------------------------------------------------------------------*
*& Form f4_cwrm_depfile
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_
*&---------------------------------------------------------------------*
FORM f4_cwrm_depfile  USING field.
  CLEAR lt_file.
  CALL METHOD cl_gui_frontend_services=>file_open_dialog
    CHANGING
      file_table              = lt_file
      rc                      = lv_rc
    EXCEPTIONS
      file_open_dialog_failed = 1
      cntl_error              = 2
      error_no_gui            = 3
      not_supported_by_gui    = 4
      OTHERS                  = 5.
  IF sy-subrc EQ 0.

    READ TABLE lt_file INTO depfile INDEX 1.
    IF sy-subrc EQ 0.
      lv_file = depfile.
    ENDIF.
  ENDIF.
ENDFORM.

*&---------------------------------------------------------------------*
*& Form f4_cwrm_infile
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_
*&---------------------------------------------------------------------*
FORM f4_cwrm_infile  USING field.
  CLEAR gt_filetab.
  CALL METHOD cl_gui_frontend_services=>file_open_dialog
    EXPORTING
      multiselection    = abap_false
      default_extension = 'xls'
    CHANGING
      file_table        = gt_filetab
      rc                = gv_ret
      user_action       = gt_usraction.

  IF gt_filetab IS NOT INITIAL.
    READ TABLE gt_filetab INTO p_infile INDEX 1.
  ENDIF.
ENDFORM.
***EOC by Deepika for CR #813 on 07/12/2021
