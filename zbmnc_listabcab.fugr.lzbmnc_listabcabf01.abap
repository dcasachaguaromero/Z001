*----------------------------------------------------------------------*
***INCLUDE LZBMNC_LISTABCABF01 .
*----------------------------------------------------------------------*
FORM buscar_datos.
***nombre sociedad
  IF zbmnc_listabcab-sociedad NE space.
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*    SELECT SINGLE butxt INTO zbmnc_listabcab-butxt
*      FROM t001
*      WHERE bukrs EQ zbmnc_listabcab-sociedad.
*
* NEW CODE
    SELECT butxt
    UP TO 1 ROWS  INTO zbmnc_listabcab-butxt
      FROM t001
      WHERE bukrs EQ zbmnc_listabcab-sociedad ORDER BY PRIMARY KEY.

    ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
  ENDIF.

***nombre proveedor
  IF zbmnc_listabcab-lifnr NE space.
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*    SELECT SINGLE name1 INTO zbmnc_listabcab-name1
*      FROM lfa1
**     WHERE stcd1 EQ zbmnc_listabcab-lifnr.
*     WHERE lifnr EQ zbmnc_listabcab-lifnr.
*
* NEW CODE
    SELECT name1
    UP TO 1 ROWS  INTO zbmnc_listabcab-name1
      FROM lfa1
*     WHERE stcd1 EQ zbmnc_listabcab-lifnr.
     WHERE lifnr EQ zbmnc_listabcab-lifnr ORDER BY PRIMARY KEY.

    ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
  ENDIF.

****nombre ceco
**add comment ini
  IF zbmnc_listabcab-ceco NE space AND zbmnc_listabcab-sociedad NE space.
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*    SELECT SINGLE ort01 INTO zbmnc_listabcab-ort01
*      FROM csks
*      WHERE bukrs EQ zbmnc_listabcab-sociedad
*        AND kostl EQ zbmnc_listabcab-ceco.
*
* NEW CODE
    SELECT ort01
    UP TO 1 ROWS  INTO zbmnc_listabcab-ort01
      FROM csks
      WHERE bukrs EQ zbmnc_listabcab-sociedad
        AND kostl EQ zbmnc_listabcab-ceco ORDER BY PRIMARY KEY.

    ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01"#EC "#EC CI_SGLSELECT
  ENDIF.
**add comment fin
****rut proveedor
  IF zbmnc_listabcab-lifnr NE space AND zbmnc_listabcab-rut_proveedor eq space.
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*     SELECT SINGLE STCD1 INTO zbmnc_listabcab-rut_proveedor
*      FROM lfa1
*     WHERE lifnr EQ zbmnc_listabcab-lifnr.
*
* NEW CODE
     SELECT STCD1
     UP TO 1 ROWS  INTO zbmnc_listabcab-rut_proveedor
      FROM lfa1
     WHERE lifnr EQ zbmnc_listabcab-lifnr ORDER BY PRIMARY KEY.

     ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
  ENDIF.

ENDFORM.                    "buscar_datos
