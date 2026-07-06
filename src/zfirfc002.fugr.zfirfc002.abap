FUNCTION ZFIRFC002.
*"----------------------------------------------------------------------
*"*"Interfase local
*"  TABLES
*"      T_DEUDOR STRUCTURE  ZDEUDOR
*"      RETURN STRUCTURE  BAPIRET2
*"----------------------------------------------------------------------
REFRESH:TI_ERROR_DED, TI_CONT_DED, RETURN, TI_BAPI_DED.

  LOOP AT T_DEUDOR.
    CLEAR: T_ERROR.
* el campo accion nos indica que tipo de proceso es  10 corresponde a un ingreso
    IF T_DEUDOR-ACCION EQ '10'.
* Valida los datos del duedor
      PERFORM VALIDA_DEUDOR TABLES RETURN
                            USING  T_DEUDOR
                         CHANGING  T_ERROR.
      IF  T_ERROR NE  0.
* Genera tabla de errore de validación.
        MOVE-CORRESPONDING T_DEUDOR TO TI_ERROR_DED.
      ELSE.
* Ejecuta función Standar para crear un Deudor.
        PERFORM CREA_DEUDORES  TABLES RETURN
                               USING  T_DEUDOR.
      ENDIF.
    ELSE.
* el campo accion nos indica que tipo de proceso es  20 corresponde a un Update
      IF T_DEUDOR-ACCION EQ '20'.
* Busca la Información del deudor a Actualizar Utilizando funciones Standar.
        PERFORM BUSCA_DEUDOR TABLES RETURN
                             USING  T_DEUDOR
                          CHANGING  T_ERROR.
* Valida la Información a Modificar.
        PERFORM VALIDA_UPDATE_DEUDOR  TABLES RETURN
                               USING  T_DEUDOR
                            CHANGING  T_ERROR.
        IF  T_ERROR EQ 0.
* Genera Datos a Actualizar.
          MOVE-CORRESPONDING T_DEUDOR  TO TI_BAPI_DED.
          APPEND TI_BAPI_DED.
        ENDIF.
      ENDIF.
    ENDIF.
  ENDLOOP.

* La siguientes Rutinas solo se utilizan apara el Update del Deudor.
  DATA: CONT_REG TYPE I.
  DESCRIBE TABLE TI_BAPI_DED LINES  CONT_REG.

  IF CONT_REG > 0.
* esta rutina procesa la informacion a actulizar data nueva V/S Data ya grabada por Deudor.
    PERFORM PROCESO_DATA  TABLES TI_BAPI_DED
                                 TI_CONT_DED.
* Ejecuta Funcion Standar de  update Deudor.
    LOOP AT TI_CONT_DED WHERE PROC EQ 'X'.
      PERFORM UPDATE_DEUDORES   TABLES RETURN
                                USING  TI_CONT_DED.
    ENDLOOP.
  ENDIF.
ENDFUNCTION.
