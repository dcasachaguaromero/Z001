*---------------------------------------------------------------------*
*    program for:   TABLEFRAME_ZDTE_CIERRE_CONT
*---------------------------------------------------------------------*
FUNCTION TABLEFRAME_ZDTE_CIERRE_CONT   .

  PERFORM TABLEFRAME TABLES X_HEADER X_NAMTAB DBA_SELLIST DPL_SELLIST
                            EXCL_CUA_FUNCT
                     USING  CORR_NUMBER VIEW_ACTION VIEW_NAME.

ENDFUNCTION.
