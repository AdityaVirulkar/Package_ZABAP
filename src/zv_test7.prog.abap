rEPORT ZV_TEST7.
DATA: RESULTS TYPE DDDDLSRC-SOURCE.
SELECT SINGLE SOURCE FROM DDDDLSRC BYPASSING BUFFER
       INTO results
       WHERE DDLNAME = 'Z_CHECK'. "FIELD1VALUES-LOW'
       IF SY-SUBRC EQ 0.
*         WRITE: RESULTS.
         CL_DEMO_OUTPUT=>DISPLAY( RESULTS ).
         ENDIF.
