*---------------------------------------------------------------------*
*    program for:   TABLEFRAME_ZBMNC_LISTABDET
*---------------------------------------------------------------------*
FUNCTION TABLEFRAME_ZBMNC_LISTABDET    .

  PERFORM TABLEFRAME TABLES X_HEADER X_NAMTAB DBA_SELLIST DPL_SELLIST
                            EXCL_CUA_FUNCT
                     USING  CORR_NUMBER VIEW_ACTION VIEW_NAME.

ENDFUNCTION.
