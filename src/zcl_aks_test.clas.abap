class ZCL_AKS_TEST definition
  public
  create public .

public section.
protected section.
private section.

  methods HANA_PROFILER_CLASS_METHOD_TAG .
ENDCLASS.



CLASS ZCL_AKS_TEST IMPLEMENTATION.


  method HANA_PROFILER_CLASS_METHOD_TAG.
     DATA : lt_bseg TYPE STANDARD TABLE OF bseg,
           ls_bseg TYPE bseg.

    SELECT SINGLE * FROM bseg INTO ls_bseg.
   data : it_mara TYPE STANDARD TABLE OF zaks_cds_para,
         p_matnr TYPE matnr.
    SELECT *  from Z0066( p_matnr = @p_matnr )
 INto TABLE @it_mara.

  endmethod.
ENDCLASS.
