class ZCL_AKS_TEST2 definition
  public
  create public .

public section.
protected section.
private section.

  methods HANA_PROFILER_CLASS_METHOD_TAG .
ENDCLASS.



CLASS ZCL_AKS_TEST2 IMPLEMENTATION.


  METHOD hana_profiler_class_method_tag.

*++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*
* CHANGE ID : HANA-001
* USER: ACC11364892
* DATE: 14.06.2017
* TR : S7HK900397
* DESCRIPTION: HANA CORRECTION
* TEAM : HANA-MIGRATION
*++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*

    DATA : lt_bseg TYPE STANDARD TABLE OF bseg,
           ls_bseg TYPE bseg.

* AUCT-UPGRADE -  Begin of Modification by <USER> on <17.02.2017> for <EHP8>
*    SELECT SINGLE * FROM bseg INTO ls_bseg.
    SELECT * UP TO 1 ROWS FROM bseg INTO ls_bseg
    ORDER BY PRIMARY KEY.
    ENDSELECT.
* AUCT-UPGRADE -  End of Modification by <USER> on <17.02.2017> for <EHP8>



  ENDMETHOD.
ENDCLASS.
