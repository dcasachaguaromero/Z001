FUNCTION zfirfc003.
*"----------------------------------------------------------------------
*"*"Interfase local
*"  TABLES
*"      T_ACREEDOR STRUCTURE  ZACREEDOR
*"      RETURN STRUCTURE  BAPIRET2
*"----------------------------------------------------------------------

* Acción 10 crea acreedor.

  REFRESH: messtab, bdcdata, return, ti_error_acre, ti_bapi_acre.
  DATA: v_bankl TYPE bankl.

  LOOP AT t_acreedor.
    CLEAR: t_error, t_ampli.
    IF t_acreedor-accion EQ '10'.
      PERFORM valida_acreedor TABLES return
                            USING  t_acreedor
                         CHANGING  t_error
                                   t_ampli.
      IF  t_error NE  0.
        MOVE-CORRESPONDING t_acreedor TO ti_error_acre.
        APPEND ti_error_acre.
      ELSE.
        PERFORM crea_acreedor TABLES return
                              USING  t_acreedor.
      ENDIF.
    ELSE.
      IF t_acreedor-accion EQ '20' OR t_acreedor-accion EQ '30'.
        PERFORM busca_acreedor TABLES return
                               USING t_acreedor
                               CHANGING t_error.
        IF t_error EQ 0.
          PERFORM valida_update_acreedor  TABLES return
                                 USING  t_acreedor
                              CHANGING  t_error.
          IF  t_error EQ 0.
            MOVE-CORRESPONDING t_acreedor  TO ti_bapi_acre.
            APPEND ti_bapi_acre.
          ELSE.
            MOVE-CORRESPONDING t_acreedor TO ti_error_acre.
            APPEND ti_error_acre.
          ENDIF.
        ENDIF.
      ENDIF.
    ENDIF.
  ENDLOOP.

  DATA: cont_reg TYPE i.
  DESCRIBE TABLE ti_bapi_acre LINES  cont_reg.
* Solo para update.
  IF cont_reg > 0.
* Ejecuta update de Acreedor.
    LOOP AT ti_bapi_acre.
*     ini. mod. cuentas bancarias en acreedores
*      para registro historico 15.11.2013 SEIDOR CRYSTALIS

*      PERFORM UPDATE_ACREEDOR   TABLES RETURN
*                                USING  TI_BAPI_ACRE.
* INICIO HCD 02-06-2014 valido que datos de banco y ciudad no sean nulos
      IF ( ti_bapi_acre-bankl IS NOT INITIAL AND ti_bapi_acre-banks IS NOT INITIAL ) AND
      ( ti_bapi_acre-bankl NE '0'  AND ti_bapi_acre-banks NE '0' ).
* HCD 02-06-2014 valido que banco exista

        CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
          EXPORTING
            input  = ti_bapi_acre-bankl
          IMPORTING
            output = ti_bapi_acre-bankl.

        ti_bapi_acre-bankl := ti_bapi_acre-bankl+12.
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*        SELECT SINGLE bankl FROM bnka INTO v_bankl
*          WHERE bankl  EQ ti_bapi_acre-bankl
*            AND banks EQ ti_bapi_acre-banks.
*
* NEW CODE
        SELECT bankl
        UP TO 1 ROWS  FROM bnka INTO v_bankl
          WHERE bankl  EQ ti_bapi_acre-bankl
            AND banks EQ ti_bapi_acre-banks ORDER BY PRIMARY KEY.

        ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01

        IF sy-subrc EQ 0 AND ( ti_bapi_acre-banks IS NOT INITIAL  AND ti_bapi_acre-banks NE '0' ) AND
                             ( ti_bapi_acre-bankl IS NOT INITIAL  AND ti_bapi_acre-bankl NE '0'  ).

          IF t_acreedor-accion NE '30'." se agrega 30 03082022
            PERFORM update_acreedor_v2   TABLES return
                                         USING  ti_bapi_acre.
          ENDIF.
        ENDIF.
* En caso de modificar la fecha ademas de agregar la cuenta HCD 20211018

        IF ti_bapi_acre-smtp_addr IS NOT INITIAL OR t_acreedor-accion EQ '30'." se agrega 30 03082022

          PERFORM update_acreedor TABLES return
                                  USING  ti_bapi_acre.

        ENDIF.

      ELSE.
        PERFORM update_acreedor TABLES return
                                USING ti_bapi_acre.
      ENDIF.
* INICIO HCD 02-06-2014 valido que datos de banco y ciudad no sean nulos
*   fin mod 15.11.2013
    ENDLOOP.
  ENDIF.

ENDFUNCTION.
