class ZCL_AKS_TEST1 definition
  public
  create public .

public section.
protected section.
private section.

  methods HANA_PROFILER_CLASS_METHOD_TAG .
ENDCLASS.



CLASS ZCL_AKS_TEST1 IMPLEMENTATION.


  METHOD hana_profiler_class_method_tag.

    DATA : lt_bseg TYPE STANDARD TABLE OF bseg,
           ls_bseg TYPE bseg.

    SELECT SINGLE * FROM bseg INTO ls_bseg.

  ENDMETHOD.
ENDCLASS.
