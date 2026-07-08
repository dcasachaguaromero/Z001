*---------------------------------------------------------------------*
*    program for:   TABLEFRAME_ZBMNC_LISTABCAB
*---------------------------------------------------------------------*
FUNCTION TABLEFRAME_ZBMNC_LISTABCAB    .

  PERFORM TABLEFRAME TABLES X_HEADER X_NAMTAB DBA_SELLIST DPL_SELLIST
                            EXCL_CUA_FUNCT
                     USING  CORR_NUMBER VIEW_ACTION VIEW_NAME.

ENDFUNCTION.
