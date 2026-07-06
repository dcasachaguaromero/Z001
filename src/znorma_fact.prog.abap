*&---------------------------------------------------------------------*
*& Report  ZNORMA_FACT
*&
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*
REPORT ZNORMA_FACT.

TABLES ZCABPEDEXT.
TABLES ZTDEA.

SELECT-OPTIONS: SO_NCORE FOR ZCABPEDEXT-ZNUM_DOC_CORE,
                SO_BLART FOR ZCABPEDEXT-ZBLART.

START-OF-SELECTION.

  SELECT * FROM ZCABPEDEXT WHERE ZNUM_DOC_CORE IN SO_NCORE
                             AND ZBLART        IN SO_BLART.
    SELECT SINGLE * FROM ZTDEA WHERE BLART EQ ZCABPEDEXT-ZBLART
                                 AND DEA   EQ 'X'.
    IF SY-SUBRC = 0.
*      ZCABPEDEXT-ERROR_E   = GT_CABPEDEXT-ERROR_E.
*      ZCABPEDEXT-LOG_ERROR = GT_CABPEDEXT-LOG_ERROR.
    ELSE.
      ZCABPEDEXT-ERROR_E   = SPACE.
      ZCABPEDEXT-LOG_ERROR = 'Este tipo de documentos no se envía a Acepta. Ver transacción ZTDEA'.
      MODIFY ZCABPEDEXT.
    ENDIF.
  ENDSELECT.
