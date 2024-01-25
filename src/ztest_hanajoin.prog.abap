REPORT ZTEST_HANAJOIN.
data: x_class TYPE REF TO ZCL_NIKS_HANA_PROFILER_TEST.
TYPES: BEGIN OF ty_levering,
          int_ui         TYPE int_ui,
          anlage         TYPE anlage,
          service        TYPE sercode,
          ableinh        TYPE ableinheit,
       END OF ty_levering.
TYPES: tsty_levering TYPE SORTED TABLE OF ty_levering
                          WITH NON-UNIQUE KEY anlage.
perform get_leveringen_grid.
FORM get_leveringen_grid
     USING    ip_serviceid TYPE service_prov
     CHANGING ct_levering  TYPE tsty_levering.
 DELETE ADJACENT DUPLICATES FROM ct_levering COMPARING anlage.
 endform.
