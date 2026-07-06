FUNCTION ZEXPORT_ESTADOS.
*"----------------------------------------------------------------------
*"*"Interfase local
*"  IMPORTING
*"     REFERENCE(BUKRS) TYPE  BUKRS
*"     REFERENCE(BELNR) TYPE  BELNR_D
*"     REFERENCE(RUT) TYPE  STCD1
*"     REFERENCE(HKONT) TYPE  HKONT
*"     REFERENCE(CHECT) TYPE  CHECT
*"     REFERENCE(FEC_CONT) TYPE  BUDAT
*"     REFERENCE(GJAHR) TYPE  GJAHR
*"     REFERENCE(ESTADO) TYPE  ZZ_ESTADO
*"     REFERENCE(DESC_EST) TYPE  ZZ_DESCRI
*"     REFERENCE(AGENCIA) TYPE  ZZ_AGENCIA
*"     REFERENCE(MONTO) TYPE  RWBTR
*"  EXPORTING
*"     REFERENCE(STATUS) TYPE  STATUSFLAG1
*"     REFERENCE(OBSERVACION) TYPE  CHAR80
*"----------------------------------------------------------------------

data: ok_code(1) type c.
data: obs(80) type c.
data OREF type ref to CX_ROOT.

exec sql.
  connect to 'SAPCSC' as 'con'
endexec.

exec sql.
  set connection 'con'
endexec.

try.
      exec sql.
          set connection 'con'
      endexec.

      EXEC SQL.
        EXECUTE PROCEDURE CSC_SAP_ESTADOS.insert_auxt_sap_estados (
                                                                    IN :BUKRS,
                                                                    IN :BELNR,
                                                                    IN :RUT,
                                                                    IN :HKONT,
                                                                    IN :CHECT,
                                                                    IN :FEC_CONT,
                                                                    IN :GJAHR,
                                                                    IN :ESTADO,
                                                                    IN :DESC_EST,
                                                                    IN :AGENCIA,
                                                                    IN :MONTO,
                                                                    OUT :ok_code,
                                                                    OUT :obs
                                                                  )

      ENDEXEC.
      move ok_code to status.
      move obs to observacion.
    catch cx_sy_native_sql_error INTO OREF.
      observacion = OREF->GET_TEXT( ).
      CLEAR status.
    endtry.
*    status = 'X'.

exec sql.
  SET CONNECTION DEFAULT
endexec.

ENDFUNCTION.
