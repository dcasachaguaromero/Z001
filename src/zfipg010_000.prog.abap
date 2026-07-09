*&---------------------------------------------------------------------*
*&  Include           ZFIPG010_000
*&---------------------------------------------------------------------*

START-OF-SELECTION.

  PERFORM proceso.

  CALL SCREEN 100.

END-OF-SELECTION.

*---------------------------------------------------------------------*
*       FORM PROCESO                                                  *
*---------------------------------------------------------------------*
FORM proceso.

  DATA: BEGIN OF p_blart OCCURS 10,
          sign   TYPE c LENGTH 1,
          option TYPE c LENGTH 2,
          low    LIKE bsik-blart,
          high   LIKE bsik-blart,
        END OF p_blart.

  DATA: BEGIN OF p_budat OCCURS 10,
          sign   TYPE c LENGTH 1,
          option TYPE c LENGTH 2,
          low    LIKE bsik-budat,
          high   LIKE bsik-budat,
        END OF p_budat.

  DATA: BEGIN OF p_zlsch OCCURS 10,
         sign   TYPE c LENGTH 1,
         option TYPE c LENGTH 2,
         low    LIKE bsik-zlsch,
         high   LIKE bsik-zlsch,
       END OF p_zlsch.

  IF NOT  budat IS INITIAL.
    p_budat-sign   = 'I'.
    p_budat-option = 'LE'.
    p_budat-low    = budat.
    CLEAR p_budat-high.
    APPEND p_budat.
  ENDIF.

  IF NOT  zlsch IS INITIAL.
    p_zlsch-sign   = 'I'.
    p_zlsch-option = 'EQ'.
    p_zlsch-low    = zlsch.
    CLEAR p_zlsch-high.
    APPEND p_zlsch.
  ENDIF.

  REFRESH tpago.
  CLEAR tpago.

* BEGIN. 07-07-2026 - ATC - ATC-03
* OLD CODE
*  SELECT * FROM bsik WHERE bukrs = bukrs
*                     AND   budat IN p_budat
*                     AND   zfbdt IN p_zfbdt
*                     AND   zlsch IN p_zlsch
*                     AND   zlspr = 'Z'.
*
* NEW CODE
  SELECT *
 FROM bsik WHERE bukrs = bukrs
                     AND   budat IN p_budat
                     AND   zfbdt IN p_zfbdt
                     AND   zlsch IN p_zlsch
                     AND   zlspr = 'Z' ORDER BY PRIMARY KEY.

* END. 07-07-2026 - ATC - ATC-03
    CLEAR tpago.
    MOVE-CORRESPONDING bsik TO tpago.
    APPEND tpago.
  ENDSELECT.

  REFRESH int_tabla.
  CLEAR  int_tabla.

  SORT tpago BY lifnr zlsch zfbdt.

  LOOP AT tpago.

    IF tpago-shkzg = 'H'.
      int_tabla-docto_fac  = int_tabla-docto_fac + 1.
      int_tabla-monto_fac  = int_tabla-monto_fac + tpago-wrbtr.
    ELSE.
      int_tabla-docto_nc   = int_tabla-docto_nc + 1.
      int_tabla-monto_nc   = int_tabla-monto_nc + tpago-wrbtr.
    ENDIF.

    AT END OF zlsch.
      CLEAR int_tabla-name1.
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*      SELECT single name1 INTO int_tabla-name1 FROM lfa1 WHERE lifnr = tpago-lifnr.
*
* NEW CODE
      SELECT name1
      UP TO 1 ROWS  INTO int_tabla-name1 FROM lfa1 WHERE lifnr = tpago-lifnr ORDER BY PRIMARY KEY.

      ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
        int_tabla-lifnr    = tpago-lifnr.
        int_tabla-zlsch    = tpago-zlsch.
        APPEND int_tabla.
        CLEAR int_tabla.
      ENDAT.

    ENDLOOP.

    DESCRIBE TABLE int_tabla LINES fill.
    SORT int_tabla BY lifnr zlsch.
    tabla-lines = fill.
    tabla-top_line = 1.

  ENDFORM.                    "PROCESO
