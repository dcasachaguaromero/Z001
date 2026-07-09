*&---------------------------------------------------------------------*
*& Report  ZIFACE_JOB_CONTA_DVGDA
*&
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*

REPORT  ZIFACE_JOB_CONTA_DVGDA.

TABLES: T001.

PARAMETER: PAIS     LIKE T001-LAND1 NO-DISPLAY,
           SOCIEDAD LIKE T001-BUKRS VALUE CHECK,
           FEC_INI  LIKE SY-DATUM VALUE CHECK,
           FEC_FIN  LIKE SY-DATUM VALUE CHECK.

data dbtype type dbcon_dbms.
data dbs type dbcon-con_name.
DATA: SFEC_INI(12) TYPE C, SFEC_FIN(12) TYPE C.

START-OF-SELECTION.
WRITE 'Proceso Iniciado'.
CONCATENATE FEC_INI(4) FEC_INI+4(2) FEC_INI+6(2) INTO SFEC_INI.
CONCATENATE FEC_FIN(4) FEC_FIN+4(2) FEC_FIN+6(2) INTO SFEC_FIN.


*Configuramos la conexion
dbs = 'SAPCSC'.
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*select single dbms
*       from dbcon
*       into dbtype
*       where con_name = dbs.
*
* NEW CODE
SELECT dbms
UP TO 1 ROWS 
       from dbcon
       into dbtype
       where con_name = dbs ORDER BY PRIMARY KEY.

ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01

*Abrimos la conexion
try.
  EXEC SQL.
    CONNECT TO :dbs
  ENDEXEC.
  if sy-subrc <> 0.
    raise exception type cx_sy_native_sql_error.
  endif.

  EXEC SQL.
    EXECUTE PROCEDURE CSC_IFACE_SAPJOBS_PUB_PKG.JOB_CONTABILIZA_DEVENGADA ( IN :SOCIEDAD, IN :SFEC_INI, IN :SFEC_FIN )
  ENDEXEC.

*  EXEC SQL.
*    CLOSE dbcur
*  ENDEXEC.
*  EXEC SQL.
*    DISCONNECT :dbs
*  ENDEXEC.

catch cx_sy_native_sql_error.
  message `Error in Native SQL.` type 'I'.
endtry.

WRITE 'Proceso Finalizado'.
