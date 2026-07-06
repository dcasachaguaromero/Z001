FUNCTION obtiene_clase_documento.
*"----------------------------------------------------------------------
*"*"Interfase local
*"  IMPORTING
*"     VALUE(FOLIO_REF) TYPE  EBELN
*"     VALUE(TIPO_DTE) TYPE  ZDTE_TIPO
*"     VALUE(SOCIEDAD) TYPE  BUKRS
*"  CHANGING
*"     VALUE(CLASE_DOC) TYPE  BLART
*"----------------------------------------------------------------------

  DATA  wa_ekpo TYPE ekpo.
  CLEAR wa_ekpo.
  CLEAR clase_doc.

  SELECT SINGLE * INTO wa_ekpo
  FROM ekpo
  WHERE ebeln EQ folio_ref
    AND loekz EQ space.
  IF sy-subrc EQ 0.

    vg_mwskz = wa_ekpo-mwskz.

    CASE tipo_dte.
      WHEN '33'.
        CASE wa_ekpo-mwskz.
          WHEN 'C1'.
            IF wa_ekpo-knttp NE 'A' AND wa_ekpo-pstyp NE '9'.
              clase_doc = 'F3'.
            ELSEIF wa_ekpo-knttp EQ 'K' AND wa_ekpo-pstyp EQ '9'.
              clase_doc = 'F3'.
            ENDIF.
          WHEN 'C9'.
            IF wa_ekpo-pstyp EQ '9'.
              clase_doc = 'F3'.
            ENDIF.
          WHEN 'C6'.
            IF sociedad EQ 'CL65'.
              IF wa_ekpo-pstyp EQ '9'.
                clase_doc = 'F3'.
              ENDIF.
            ELSE.
              IF wa_ekpo-knttp EQ 'A'.
                clase_doc = 'F4'.
              ENDIF.
            ENDIF.
        ENDCASE.
      WHEN '34'.
        CASE wa_ekpo-mwskz.
          WHEN 'C0'.
            IF wa_ekpo-knttp NE 'A' AND wa_ekpo-pstyp NE '9'.
              clase_doc = 'FA'.
            ELSEIF wa_ekpo-pstyp EQ '9'.
              clase_doc = 'FA'.
            ELSEIF wa_ekpo-knttp EQ 'A'.
              clase_doc = 'FC'.
            ENDIF.
          WHEN OTHERS.
        ENDCASE.
      WHEN '61'.
        CASE wa_ekpo-mwskz.
          WHEN 'C0'.
            clase_doc = 'NA'.
          WHEN 'C1'.
            clase_doc = 'N3'.
          WHEN 'C9'.
            clase_doc = 'N3'.
          WHEN 'C6'.
          WHEN OTHERS.
        ENDCASE.
    ENDCASE.
  ENDIF.



ENDFUNCTION.
