*----------------------------------------------------------------------*
***INCLUDE LZDTE_DOC_GRF01 .
*----------------------------------------------------------------------*

FORM buscar_datos.
  IF zdte_tabla_doc-bukrs NE space.
    SELECT SINGLE butxt INTO zdte_tabla_doc-butxt
      FROM t001
      WHERE bukrs EQ zdte_tabla_doc-bukrs.
  ENDIF.

  IF zdte_tabla_doc-rutemisor NE space.
    SELECT SINGLE name1 INTO zdte_tabla_doc-name1
      FROM lfa1
      WHERE stcd1 EQ zdte_tabla_doc-rutemisor.
  ENDIF.


ENDFORM.                    "buscar_datos
