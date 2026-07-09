*&---------------------------------------------------------------------*
*&  Include           ZFIPG002_000
*&---------------------------------------------------------------------*

START-OF-SELECTION.

  PERFORM proceso.

  CALL SCREEN 100.


END-OF-SELECTION.

*---------------------------------------------------------------------*
*       FORM PROCESO                                                  *
*---------------------------------------------------------------------*
FORM proceso.

  DATA: v_txt(100) TYPE c.

  REFRESH int_tabla.
  CLEAR  int_tabla.

* BEGIN. 07-07-2026 - ATC - ATC-03
* OLD CODE
*  SELECT * FROM zfipg200_det WHERE bukrs  = bukrs
*                             AND   estado <> 'P'
*                              AND   zlsch = zlsch .
*
* NEW CODE
  SELECT *
 FROM zfipg200_det WHERE bukrs  = bukrs
                             AND   estado <> 'P'
                              AND   zlsch = zlsch  ORDER BY PRIMARY KEY.

* END. 07-07-2026 - ATC - ATC-03



* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*    SELECT SINGLE * FROM reguv WHERE laufd = zfipg200_det-laufd
*                               AND   laufi = zfipg200_det-laufi.
*
* NEW CODE
    SELECT *
    UP TO 1 ROWS  FROM reguv WHERE laufd = zfipg200_det-laufd
                               AND   laufi = zfipg200_det-laufi ORDER BY PRIMARY KEY.

    ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01

    IF sy-subrc = 0 AND   reguv-xvore = 'X' and reguv-XECHT is initial.

      MOVE-CORRESPONDING zfipg200_det  TO int_tabla.

* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*      SELECT SINGLE descr INTO int_tabla-descr
*                        FROM   zfipg200_cab  WHERE bukrs     =  zfipg200_det-bukrs
*                                             AND   nproceso  =  zfipg200_det-nproceso.
*
* NEW CODE
      SELECT descr
      UP TO 1 ROWS  INTO int_tabla-descr
                        FROM   zfipg200_cab  WHERE bukrs     =  zfipg200_det-bukrs
                                             AND   nproceso  =  zfipg200_det-nproceso ORDER BY PRIMARY KEY.

      ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01

      IF int_tabla-estado  = ''.
        CONCATENATE '@JL\Q' 'Listo Para Confirmar Pago' '@' INTO int_tabla-listopara.
      ELSE.
        IF int_tabla-estado  = 'I'.
          CONCATENATE '@0X\Q' 'Listo Para Impresion' '@' INTO int_tabla-listopara.
        ENDIF.
      ENDIF.



      PERFORM busco_resumen.

      int_tabla-nhojas =  ( ( int_tabla-nchequ - int_tabla-nchequ_s ) / 4 ).
      resto  =  ( ( int_tabla-nchequ - int_tabla-nchequ_s ) MOD 4 ).
      IF resto = 1 .
        int_tabla-nhojas = int_tabla-nhojas + 1.
      ENDIF.

* Chidalgo quintec 29.04.10
* Agrego el campo de ultima remesa
      IF int_tabla-nchequ EQ 0.
        int_tabla-tot_remesa = 0.
        int_tabla-ult_remesa = 0.
      ELSE.

* BEGIN. 07-07-2026 - ATC - ATC-03
* OLD CODE
*        SELECT stapl fstap chect checl FROM pcec INTO CORRESPONDING FIELDS OF TABLE ti_pcec
*           WHERE zbukr = soc_pago
*                 AND hbkid = int_tabla-hbkid
*                 AND xchch NE 'X'.
*
* NEW CODE
        SELECT stapl fstap chect checl
 FROM pcec INTO CORRESPONDING FIELDS OF TABLE ti_pcec
           WHERE zbukr = soc_pago
                 AND hbkid = int_tabla-hbkid
                 AND xchch NE 'X' ORDER BY PRIMARY KEY.

* END. 07-07-2026 - ATC - ATC-03
*               and hktid = reguh-hktid.
        LOOP AT ti_pcec.
          int_tabla-chect = ti_pcec-chect.
          IF ti_pcec-checl < ti_pcec-chect.
            int_tabla-ult_remesa = ti_pcec-checl + 1.
            int_tabla-fstap = ti_pcec-fstap.
            EXIT.
          ENDIF.
        ENDLOOP.

        int_tabla-tot_remesa = ( int_tabla-ult_remesa + int_tabla-nchequ ) - 1.

        IF int_tabla-tot_remesa > int_tabla-chect.
          CLEAR band.
          LOOP AT ti_pcec.
            IF ti_pcec-stapl = int_tabla-fstap AND ti_pcec-chect >= int_tabla-tot_remesa.
              band = 1.
              int_tabla-chect = ti_pcec-chect.
              EXIT.
            ENDIF.
          ENDLOOP.

          IF band IS INITIAL.
            int_tabla-tot_remesa = int_tabla-chect.
          ENDIF.

        ENDIF.

      ENDIF.

      IF int_tabla-estado  = 'I' AND ( zlsch = 'T' OR zlsch = 'V' ).
        CONTINUE.
      ENDIF.
* fin chidalgo
      int_tabla-monto_dif = ( int_tabla-monto * -1 ) - int_tabla-montop.
      int_tabla-ndocu_dif =  int_tabla-npagos  - int_tabla-ndocu_ban.
     append int_tabla.

    ENDIF.

  ENDSELECT.

  DESCRIBE TABLE int_tabla LINES fill.
  SORT int_tabla BY descr  laufd laufi.

  tabla-lines = fill.

  IF zlsch = 'C'.
    tabla-line_sel_mode = 1.
*    LOOP AT tabla-cols INTO cols WHERE index = 12 .
*      cols-invisible = '1'.
*      MODIFY tabla-cols FROM cols INDEX sy-tabix.
*    ENDLOOP.
    LOOP AT tabla-cols INTO cols WHERE index > 14.
      cols-invisible = '0'.
      MODIFY tabla-cols FROM cols INDEX sy-tabix.
    ENDLOOP.

  ELSE.
    tabla-line_sel_mode = 1.
    LOOP AT tabla-cols INTO cols WHERE index > 14 .
      cols-invisible = '1'.
      MODIFY tabla-cols FROM cols INDEX sy-tabix.
    ENDLOOP.

*    LOOP AT tabla-cols INTO cols WHERE index = 12.
*      cols-invisible = '0'.
*      MODIFY tabla-cols FROM cols INDEX sy-tabix.
*    ENDLOOP.

  ENDIF.

ENDFORM.                    "PROCESO
*&---------------------------------------------------------------------*
*&      Form  BUSCO_RESUMEN
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM busco_resumen .

  CLEAR: int_tabla-monto,int_tabla-npagos,int_tabla-semaforo, int_tabla-nchequ.

  CONCATENATE '@5B\Q' 'Pago' '@' INTO int_tabla-semaforo.
** Modificado por L_FOUBERT 05.07.2013 Consulta y Log Tabla REGUH
************************** Se comenta Logica Anterior ***************************
*  SELECT * FROM  reguh   WHERE  laufd = int_tabla-laufd
*                         AND    laufi = int_tabla-laufi.
*
*
*    IF  ( int_tabla-estado  = 'I' AND reguh-xvorl = '' )    OR  int_tabla-estado  <> 'I'.
*
*      IF reguh-vblnr NE space.
*        int_tabla-monto   = int_tabla-monto + reguh-rbetr.
*        int_tabla-npagos  = int_tabla-npagos + 1.
*        int_tabla-nchequ  = int_tabla-nchequ + 1.
*      ELSE.
*        CONCATENATE '@5C\Q' 'Excepción' '@' INTO int_tabla-semaforo.
*
*      ENDIF.
*
*    ENDIF.
*
*  ENDSELECT.
********************* END comenta Logica Anterior *******************************
*********************** Comienzo Nueva Logica   *********************************
* BEGIN. 07-07-2026 - ATC - ATC-03
* OLD CODE
*  SELECT xvorl vblnr rbetr zbukr FROM  reguh INTO gw_reguh WHERE  laufd = int_tabla-laufd
*                                                     AND    laufi = int_tabla-laufi.
*
* NEW CODE
  SELECT xvorl vblnr rbetr zbukr
 FROM  reguh INTO gw_reguh WHERE  laufd = int_tabla-laufd
                                                     AND    laufi = int_tabla-laufi ORDER BY PRIMARY KEY.

* END. 07-07-2026 - ATC - ATC-03

    soc_pago = gw_reguh-zbukr.
    IF NOT ( int_tabla-estado EQ 'I' AND gw_reguh-xvorl NE space ).
      IF gw_reguh-vblnr NE space.
        int_tabla-monto   = int_tabla-monto + gw_reguh-rbetr.
        ADD 1 TO int_tabla-npagos.
      ELSE.
        CONCATENATE '@5C\Q' 'Excepción' '@' INTO int_tabla-semaforo.
      ENDIF.
    ENDIF.
  ENDSELECT.
  int_tabla-nchequ = int_tabla-npagos.
************************ END Nueva Logica ***************************************
** END Modificación L_FOUBERT 05.07.2013 Consulta y Log Tabla REGUH

  IF int_tabla-npagos = 0.
    CLEAR int_tabla-listopara.
    int_tabla-estado = 'E'.
  ENDIF.
ENDFORM.                    " BUSCO_RESUMEN
