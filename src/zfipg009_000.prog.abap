*&---------------------------------------------------------------------*
*&  Include           ZFIPG008_000
*&---------------------------------------------------------------------*
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
*  SELECT * FROM zfipg002_det WHERE bukrs  = bukrs
*                             AND   estado <> 'P'
*                             and   NPROCESO in  NPROCESO
*
*                             and   LAUFI    in  v_nomina
*                             and   LAUFD    in  v_fecha
*                             and   HBKID    in  v_hbkid
*                             and   XZZMOT_EMIS = 'TFONDOS'.
*
* NEW CODE
  SELECT *
 FROM zfipg002_det WHERE bukrs  = bukrs
                             AND   estado <> 'P'
                             and   NPROCESO in  NPROCESO

                             and   LAUFI    in  v_nomina
                             and   LAUFD    in  v_fecha
                             and   HBKID    in  v_hbkid
                             and   XZZMOT_EMIS = 'TFONDOS' ORDER BY PRIMARY KEY.

* END. 07-07-2026 - ATC - ATC-03



      MOVE-CORRESPONDING zfipg002_det  TO int_tabla.

* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*      SELECT SINGLE descr INTO int_tabla-descr
*                        FROM   zfipg002_cab  WHERE bukrs     =  zfipg002_det-bukrs
*                                             AND   nproceso  =  zfipg002_det-nproceso.
*
* NEW CODE
      SELECT descr
      UP TO 1 ROWS  INTO int_tabla-descr
                        FROM   zfipg002_cab  WHERE bukrs     =  zfipg002_det-bukrs
                                             AND   nproceso  =  zfipg002_det-nproceso ORDER BY PRIMARY KEY.

      ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01

       PERFORM busco_resumen.

      APPEND int_tabla.


  ENDSELECT.

  DESCRIBE TABLE int_tabla LINES fill.
  SORT int_tabla BY descr  laufd laufi.

  tabla-lines = fill.



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

* BEGIN. 07-07-2026 - ATC - ATC-03
* OLD CODE
*  SELECT * FROM  reguh   WHERE  laufd = int_tabla-laufd
*                         AND    laufi = int_tabla-laufi.
*
* NEW CODE
  SELECT *
 FROM  reguh   WHERE  laufd = int_tabla-laufd
                         AND    laufi = int_tabla-laufi ORDER BY PRIMARY KEY.

* END. 07-07-2026 - ATC - ATC-03


    IF  ( int_tabla-estado  = 'I' AND reguh-xvorl = '' )    OR  int_tabla-estado  <> 'I'.

      IF reguh-vblnr NE space.
        int_tabla-monto   = int_tabla-monto + reguh-rbetr.
        int_tabla-npagos  = int_tabla-npagos + 1.
        int_tabla-nchequ  = int_tabla-nchequ + 1.
      ENDIF.

    ENDIF.

  ENDSELECT.

  IF int_tabla-npagos = 0.
    CLEAR int_tabla-listopara.
    int_tabla-estado = 'E'.
  ENDIF.
ENDFORM.                    " BUSCO_RESUMEN
