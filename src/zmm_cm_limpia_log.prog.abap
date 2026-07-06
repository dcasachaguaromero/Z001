*&---------------------------------------------------------------------*
*&----------------------------------------------------------------------&*
*& Cliente            : vida integra                                   &*
*& Consultora         : PYV Limitada                                   &*
*& Desarrollador ABAP : Guillermo Soto                                 &*
*& Funcional          : José Palma                                     &*
*& Fecha              : 19/07/2016                                     &*
*& Transporte         :                                                &*
*& Objetivo           : Limpiar LOG de Carga masiva salida mercancías  &*
*&----------------------------------------------------------------------&*
*&
REPORT  zmm_cm_limpia_log.

TABLES: zmm_log_carga.

*--------------------------------------------------------------------*
* DATA
*--------------------------------------------------------------------*
DATA: fecha TYPE dats.

DATA: cuental TYPE index,
      cuentad TYPE index.

DATA: w_correl_carga    LIKE   zmm_log_carga-correl_carga,
      w_evento_carga    LIKE   zmm_log_carga-evento_carga,
      w_fecha_carga     LIKE   zmm_log_carga-fecha_carga,
      w_hora_carga      LIKE   zmm_log_carga-hora_carga,
      w_linea_carga     LIKE   zmm_log_carga-linea_carga.

fecha = sy-datum - 30.
SELECT * FROM zmm_log_carga.
  cuental = cuental + 1.
  IF sy-subrc = 0.
    IF zmm_log_carga-fecha_carga < fecha.
      w_correl_carga    =   zmm_log_carga-correl_carga.
      w_evento_carga    =   zmm_log_carga-evento_carga.
      w_fecha_carga     =   zmm_log_carga-fecha_carga.
      w_hora_carga      =   zmm_log_carga-hora_carga.
      w_linea_carga     =   zmm_log_carga-linea_carga.
      DELETE FROM zmm_log_carga
            WHERE correl_carga   = w_correl_carga  AND
                  evento_carga   = w_evento_carga  AND
                  fecha_carga    = w_fecha_carga   AND
                  hora_carga     = w_hora_carga    AND
                  linea_carga    = w_linea_carga.
      IF sy-subrc = 0.
        cuentad = cuentad + 1.
      ENDIF.
    ENDIF.
  ENDIF.
ENDSELECT.

WRITE: / '--------------------------------------------------------------'.
WRITE: / 'RESUMEN PROCESO DEPURACION LOG CARGA MASIVA DE CONSUMOS   '.
WRITE: / '--------------------------------------------------------------'.
WRITE: / 'Fecha de Proceso    : ', sy-datum.
WRITE: / 'Fecha menos 30 días : ', fecha.
WRITE: / '--------------------------------------------------------------'.
WRITE: / 'Registros leídos    : ', cuental.
WRITE: / 'Registros borrados  : ', cuentad.
WRITE: / ' *** FIN DE PROCESO ***'.
WRITE: / '--------------------------------------------------------------'.
EXIT.
