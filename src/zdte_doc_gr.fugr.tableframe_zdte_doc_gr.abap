*---------------------------------------------------------------------*
*    program for:   TABLEFRAME_ZDTE_DOC_GR
*---------------------------------------------------------------------*
FUNCTION TABLEFRAME_ZDTE_DOC_GR        .

  PERFORM TABLEFRAME TABLES X_HEADER X_NAMTAB DBA_SELLIST DPL_SELLIST
                            EXCL_CUA_FUNCT
                     USING  CORR_NUMBER VIEW_ACTION VIEW_NAME.

ENDFUNCTION.
