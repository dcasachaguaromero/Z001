FUNCTION ZOBT_FOLIO_DTE.
*"----------------------------------------------------------------------
*"*"Interfase local
*"  IMPORTING
*"     REFERENCE(I_BUKRS) LIKE  IDCN_BOMA-BUKRS
*"     REFERENCE(I_LOTNO) LIKE  IDCN_BOMA-LOTNO
*"     REFERENCE(I_BOKNO) LIKE  IDCN_BOMA-BOKNO
*"  EXPORTING
*"     REFERENCE(E_LIINV) LIKE  IDCN_BOMA-LIINV
*"----------------------------------------------------------------------
  TABLES IDCN_BOMA.
  DATA H_NIINV LIKE IDCN_BOMA-LIINV.

* Bloqueo Tabla de Folio
  CALL FUNCTION 'ENQUEUE_EBOOKNO'
    EXPORTING
      MANDT          = SY-MANDT
      BUKRS          = I_BUKRS
      LOTNO          = I_LOTNO
      BOKNO          = I_BOKNO
    EXCEPTIONS
      FOREIGN_LOCK   = 1
      SYSTEM_FAILURE = 2
      OTHERS         = 3.

  CASE SY-SUBRC.
    WHEN 0.
* Obtiene el último folio utilizado
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*      SELECT SINGLE * FROM IDCN_BOMA WHERE BUKRS = I_BUKRS
*                                       AND LOTNO = I_LOTNO
*                                       AND BOKNO = I_BOKNO.
*
* NEW CODE
      SELECT *
      UP TO 1 ROWS  FROM IDCN_BOMA WHERE BUKRS = I_BUKRS
                                       AND LOTNO = I_LOTNO
                                       AND BOKNO = I_BOKNO ORDER BY PRIMARY KEY.

      ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
      IF SY-SUBRC = 0.
        IF IDCN_BOMA-INVFR > IDCN_BOMA-LIINV.
          H_NIINV = IDCN_BOMA-INVFR.
          IDCN_BOMA-ACTSG = 'X'.
          UPDATE IDCN_BOMA.
        ELSE.
          IF IDCN_BOMA-LIINV < IDCN_BOMA-INVTO.
            H_NIINV = IDCN_BOMA-LIINV + 1.
            IF IDCN_BOMA-INVTO EQ H_NIINV.
              IDCN_BOMA-ACTSG = SPACE.
              UPDATE IDCN_BOMA.
            ENDIF.
          ELSE.
            H_NIINV = IDCN_BOMA-LIINV.
          ENDIF.
        ENDIF.

        CALL FUNCTION 'FIRST_LAST_INV_UPDATE'
          EXPORTING
            BUKRS        = I_BUKRS
            LOTNO        = I_LOTNO
            BOKNO        = I_BOKNO
            LIINV        = H_NIINV
            ISSDT        = IDCN_BOMA-FIIDT
          EXCEPTIONS
            UPDATE_ERROR = 1
            NOT_FOUND    = 2.
        IF SY-SUBRC = 0.
          E_LIINV = H_NIINV.
        ENDIF.
      ENDIF.
* Desbloqueo Tabla de Folio
      CALL FUNCTION 'DEQUEUE_EBOOKNO'
        EXPORTING
          MODE_IDCN_BOMA = 'E'
          MANDT          = SY-MANDT
          BUKRS          = I_BUKRS
          LOTNO          = I_LOTNO
          BOKNO          = I_BOKNO.
    WHEN 1.
      MESSAGE E890(ICC_CN) WITH SY-MSGV1 I_BOKNO I_LOTNO.
    WHEN OTHERS.
      MESSAGE E860(ICC_CN) WITH I_BOKNO I_LOTNO.
  ENDCASE.

ENDFUNCTION.
