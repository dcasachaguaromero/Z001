*----------------------------------------------------------------------*
***INCLUDE LZDTE_DOC_GRF01 .
*----------------------------------------------------------------------*

FORM buscar_datos.
  IF zdte_tabla_doc-bukrs NE space.
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*    SELECT SINGLE butxt INTO zdte_tabla_doc-butxt
*      FROM t001
*      WHERE bukrs EQ zdte_tabla_doc-bukrs.
*
* NEW CODE
    SELECT butxt
    UP TO 1 ROWS  INTO zdte_tabla_doc-butxt
      FROM t001
      WHERE bukrs EQ zdte_tabla_doc-bukrs ORDER BY PRIMARY KEY.

    ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
  ENDIF.

  IF zdte_tabla_doc-rutemisor NE space.
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*    SELECT SINGLE name1 INTO zdte_tabla_doc-name1
*      FROM lfa1
*      WHERE stcd1 EQ zdte_tabla_doc-rutemisor.
*
* NEW CODE
    SELECT name1
    UP TO 1 ROWS  INTO zdte_tabla_doc-name1
      FROM lfa1
      WHERE stcd1 EQ zdte_tabla_doc-rutemisor ORDER BY PRIMARY KEY.

    ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
  ENDIF.


ENDFORM.                    "buscar_datos
