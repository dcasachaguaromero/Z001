*&---------------------------------------------------------------------*
*& Report  ZFICH007
*&
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*

REPORT  zfich008.

TABLES: zfich001,
        zfich002,
        bkpf,
        payr,
        zagencia.

DATA subrc LIKE sy-subrc.

DATA:                                  "Aufbereitung Messagetext
  BEGIN OF datos  OCCURS 100,
    bukrs(4),
    hbkid(5),
    hktid(5),
    chect(13),
    fecha_reg(8),
    hora_reg(8),
    belnr(10),
    gjahr(4),
    hkont(10),
    agencia(10),
    usuario(12),
    estado(2),
 END OF datos.





CALL FUNCTION 'UPLOAD'
  TABLES
    data_tab = datos.


LOOP AT datos.
  subrc = 0.

* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*  SELECT SINGLE * FROM  payr WHERE zbukr = datos-bukrs
*                      AND   hbkid = datos-hbkid
*                      AND   hktid = datos-hktid
*                      AND   chect = datos-chect.
*
* NEW CODE
  SELECT *
  UP TO 1 ROWS  FROM  payr WHERE zbukr = datos-bukrs
                      AND   hbkid = datos-hbkid
                      AND   hktid = datos-hktid
                      AND   chect = datos-chect ORDER BY PRIMARY KEY.

  ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
  IF sy-subrc <> 0.
    subrc = sy-subrc.
    WRITE:/ datos-bukrs,
            datos-hbkid,
            datos-hktid,
            datos-chect,
            'Cheque no existe en PAYR',
            'Linea :',
            sy-tabix.
  ENDIF.

* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*  SELECT SINGLE * FROM  bkpf  WHERE bukrs = datos-bukrs
*                              AND   belnr = datos-belnr
*                              AND   gjahr = datos-gjahr.
*
* NEW CODE
  SELECT *
  UP TO 1 ROWS  FROM  bkpf  WHERE bukrs = datos-bukrs
                              AND   belnr = datos-belnr
                              AND   gjahr = datos-gjahr ORDER BY PRIMARY KEY.

  ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
  IF sy-subrc <> 0.
    subrc = sy-subrc.
    WRITE:/ datos-bukrs,
            datos-hbkid,
            datos-hktid,
            datos-chect,
            datos-belnr,
            datos-gjahr,
            'Documento Contable no Existe',
            'Linea :',
            sy-tabix.
  ENDIF.
  IF NOT datos-agencia  IS INITIAL.
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*    SELECT SINGLE * FROM  zagencia  WHERE bukrs = datos-bukrs
*                                    AND   zzcod_unidad = datos-agencia.
*
* NEW CODE
    SELECT *
    UP TO 1 ROWS  FROM  zagencia  WHERE bukrs = datos-bukrs
                                    AND   zzcod_unidad = datos-agencia ORDER BY PRIMARY KEY.

    ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01

    IF sy-subrc <> 0.
      subrc = sy-subrc.
      WRITE:/ datos-bukrs,
              datos-hbkid,
              datos-hktid,
              datos-chect,
              datos-agencia,
              'Agencia no Existe',
              'Linea :',
              sy-tabix.
    ENDIF.
  ENDIF.

* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*  SELECT SINGLE * FROM  zfich002  WHERE bukrs = datos-bukrs
*                                  AND   estado = datos-estado.
*
* NEW CODE
  SELECT *
  UP TO 1 ROWS  FROM  zfich002  WHERE bukrs = datos-bukrs
                                  AND   estado = datos-estado ORDER BY PRIMARY KEY.

  ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01

  IF sy-subrc <> 0.
    subrc = sy-subrc.
    WRITE:/ datos-bukrs,
            datos-hbkid,
            datos-hktid,
            datos-chect,
            datos-estado,
            'Estado no Existe',
            'Linea :',
            sy-tabix.
  ENDIF.
  IF subrc = 0.
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*    SELECT SINGLE * FROM  zfich001 WHERE bukrs = datos-bukrs
*                                   AND   lifnr = payr-lifnr
*                                   AND   hbkid = datos-hbkid
*                                   AND   hktid    =  datos-hktid
*                                   AND   chect    = datos-chect
*                                   AND   fecha_reg = datos-fecha_reg
*                                   AND   hora_reg = datos-hora_reg.
*
* NEW CODE
    SELECT *
    UP TO 1 ROWS  FROM  zfich001 WHERE bukrs = datos-bukrs
                                   AND   lifnr = payr-lifnr
                                   AND   hbkid = datos-hbkid
                                   AND   hktid    =  datos-hktid
                                   AND   chect    = datos-chect
                                   AND   fecha_reg = datos-fecha_reg
                                   AND   hora_reg = datos-hora_reg ORDER BY PRIMARY KEY.

    ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
    IF sy-subrc = 0.

      WRITE:/ datos-bukrs,
              datos-hbkid,
              datos-hktid,
              datos-chect,
              datos-fecha_reg,
              datos-hora_reg,
              'Cheque+ fecha y hora ya existe en historico',
              'Linea :',
              sy-tabix.
    ELSE.

      CLEAR zfich001.
      MOVE-CORRESPONDING datos TO zfich001.
      zfich001-lifnr = payr-lifnr.
      INSERT zfich001.
    ENDIF.
  ENDIF.

ENDLOOP .
