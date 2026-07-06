*----------------------------------------------------------------------*
***INCLUDE LZBMNC_LISTABCABF01 .
*----------------------------------------------------------------------*
FORM buscar_datos.
***nombre sociedad
  IF zbmnc_listabcab-sociedad NE space.
    SELECT SINGLE butxt INTO zbmnc_listabcab-butxt
      FROM t001
      WHERE bukrs EQ zbmnc_listabcab-sociedad.
  ENDIF.

***nombre proveedor
  IF zbmnc_listabcab-lifnr NE space.
    SELECT SINGLE name1 INTO zbmnc_listabcab-name1
      FROM lfa1
*     WHERE stcd1 EQ zbmnc_listabcab-lifnr.
     WHERE lifnr EQ zbmnc_listabcab-lifnr.
  ENDIF.

****nombre ceco
**add comment ini
  IF zbmnc_listabcab-ceco NE space AND zbmnc_listabcab-sociedad NE space.
    SELECT SINGLE ort01 INTO zbmnc_listabcab-ort01
      FROM csks
      WHERE bukrs EQ zbmnc_listabcab-sociedad
        AND kostl EQ zbmnc_listabcab-ceco."#EC "#EC CI_SGLSELECT
  ENDIF.
**add comment fin
****rut proveedor
  IF zbmnc_listabcab-lifnr NE space AND zbmnc_listabcab-rut_proveedor eq space.
     SELECT SINGLE STCD1 INTO zbmnc_listabcab-rut_proveedor
      FROM lfa1
     WHERE lifnr EQ zbmnc_listabcab-lifnr.
  ENDIF.

ENDFORM.                    "buscar_datos
