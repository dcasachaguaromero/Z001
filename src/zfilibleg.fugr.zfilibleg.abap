FUNCTION zfilibleg.
*"----------------------------------------------------------------------
*"*"Interfase local
*"  IMPORTING
*"     REFERENCE(P_BUKRS) TYPE  BUKRS
*"  EXPORTING
*"     REFERENCE(NOMSOC) TYPE  BUTXT
*"  TABLES
*"      TI_REPLEG STRUCTURE  ZREPLEG OPTIONAL
*"----------------------------------------------------------------------

  TABLES: zrepleg.

  DATA: v_rutsoc LIKE zrepleg-rutsoc,
          v_nomrep LIKE zrepleg-nomreplegal,
          v_rutrep LIKE zrepleg-rutrepleg,
          v_dir    LIKE zrepleg-direccion.


*Carga Nombre de Sociedad.
  SELECT SINGLE butxt
    INTO nomsoc
    FROM t001
    WHERE bukrs = p_bukrs.

*Carga datos de Sociedad.
  SELECT SINGLE *
    INTO CORRESPONDING FIELDS OF ti_repleg
    FROM zrepleg
    WHERE sociedad = p_bukrs.

  IF sy-subrc = 0.
    APPEND ti_repleg.
  ENDIF.



ENDFUNCTION.
