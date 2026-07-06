FUNCTION ZPRESCRIBE_CHEQUES.
*"----------------------------------------------------------------------
*"*"Interfase local
*"  IMPORTING
*"     REFERENCE(VEMPRESA) TYPE  DZBUKR
*"     REFERENCE(VTIPO) TYPE  DZLSCH
*"     REFERENCE(VNUMERO) TYPE  CHECT
*"     REFERENCE(VCTACTE_SAP) TYPE  SAKNR
*"     REFERENCE(VROL_BENEFICIARIO) TYPE  STCD1
*"     REFERENCE(VFEC_EMISION2) TYPE  DZALDT
*"     REFERENCE(VMOTIVO) TYPE  CHAR10
*"     REFERENCE(VFOLIO_CAD) TYPE  CHAR10
*"     REFERENCE(VFEC_RESULTADO2) TYPE  BUDAT
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
      EXECUTE PROCEDURE csc_sap_cheques.sp_prescribe_tes_docpago_sap(
                                                                    IN :vEMPRESA  ,
                                                                    IN :vNUMERO   ,
                                                                    IN :vTipo             ,
                                                                    IN :vCTACTE_SAP,
                                                                    IN :vROL_BENEFICIARIO ,
                                                                    IN :vFEC_EMISION2 ,
                                                                    IN :vFEC_RESULTADO2,
                                                                    IN :VMOTIVO,
                                                                    IN :VFOLIO_CAD
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
