*---------------------------------------------------------------------*
*    program for:   TABLEFRAME_ZV_T042
*---------------------------------------------------------------------*
FUNCTION TABLEFRAME_ZV_T042            .

  PERFORM TABLEFRAME TABLES X_HEADER X_NAMTAB DBA_SELLIST DPL_SELLIST
                            EXCL_CUA_FUNCT
                     USING  CORR_NUMBER VIEW_ACTION VIEW_NAME.

ENDFUNCTION.
