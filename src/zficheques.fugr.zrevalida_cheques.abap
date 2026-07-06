FUNCTION ZREVALIDA_CHEQUES.
*"----------------------------------------------------------------------
*"*"Interfase local
*"  IMPORTING
*"     REFERENCE(VEMPRESA) TYPE  DZBUKR
*"     REFERENCE(VTIPO) TYPE  DZLSCH
*"     REFERENCE(VNUMERO) TYPE  CHECT
*"     REFERENCE(VCTACTE_SAP) TYPE  SAKNR
*"     REFERENCE(VROL_BENEFICIARIO) TYPE  STCD1
*"     REFERENCE(VFEC_EMISION2) TYPE  DZALDT
*"     REFERENCE(VCHEDA_NTRASP_REVALIDA) TYPE  BELNR
*"     REFERENCE(VCHEDA_FTRASP_REVALIDA2) TYPE  BUDAT
*"     REFERENCE(VCHEDA_LTRASP_REVALIDA) TYPE  BUZEI
*"     REFERENCE(VCHEDA_FREVALIDA2) TYPE  BUDAT
*"     REFERENCE(VCHEDA_CAGENCIA_REVALIDA) TYPE  DZNME1
*"     REFERENCE(VMOTIVO) TYPE  CHAR10
*"     REFERENCE(VFEC_VENCIMIENTO2) TYPE  BUDAT
*"     REFERENCE(VFOLIO_CAD) TYPE  CHAR10
*"     REFERENCE(VLUGAR_PAGO) TYPE  DZNME1
*"  EXPORTING
*"     REFERENCE(STATUS) TYPE  STATUS1
*"----------------------------------------------------------------------

exec sql.
  connect to 'SAPCSC' as 'con'
endexec.

exec sql.
  set connection 'con'
endexec.
*         execute procedure pkg_sap_cargas.sap_carga_detalle_gasto ( IN :hkont )
try.
    EXEC SQL.
      EXECUTE PROCEDURE csc_sap_cheques.sp_revalida_tes_docpago_sap(
                                                                    IN :vEMPRESA  ,
                                                                    IN :vNUMERO   ,
                                                                    IN :vTipo             ,
                                                                    IN :vCTACTE_SAP,
                                                                    IN :vROL_BENEFICIARIO ,
                                                                    IN :vFEC_EMISION2 ,
                                                                    IN :vCHEDA_NTRASP_REVALIDA,
                                                                    IN :vCHEDA_FTRASP_REVALIDA2,
                                                                    IN :vCHEDA_LTRASP_REVALIDA,
                                                                    IN :vCHEDA_FREVALIDA2,
                                                                    IN :vCHEDA_CAGENCIA_REVALIDA,
                                                                    IN :vMotivo,
                                                                    IN :vFEC_VENCIMIENTO2,
                                                                    IN :vFOLIO_CAD,
                                                                    IN :vlugar_pago
                                                                    )

    ENDEXEC.
    STATUS = 'X'.
catch cx_sy_native_sql_error.
*  message text-001 type 'I'.
*  message `Error in Native SQL.` type 'I'.
  STATUS = ''.
endtry.

exec sql.
  SET CONNECTION DEFAULT
endexec.


ENDFUNCTION.
