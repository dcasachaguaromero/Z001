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
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*  SELECT SINGLE butxt
*    INTO nomsoc
*    FROM t001
*    WHERE bukrs = p_bukrs.
*
* NEW CODE
  SELECT butxt
  UP TO 1 ROWS 
    INTO nomsoc
    FROM t001
    WHERE bukrs = p_bukrs ORDER BY PRIMARY KEY.

  ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01

*Carga datos de Sociedad.
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*  SELECT SINGLE *
*    INTO CORRESPONDING FIELDS OF ti_repleg
*    FROM zrepleg
*    WHERE sociedad = p_bukrs.
*
* NEW CODE
  SELECT *
  UP TO 1 ROWS 
    INTO CORRESPONDING FIELDS OF ti_repleg
    FROM zrepleg
    WHERE sociedad = p_bukrs ORDER BY PRIMARY KEY.

  ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01

  IF sy-subrc = 0.
    APPEND ti_repleg.
  ENDIF.



ENDFUNCTION.
