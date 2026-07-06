FUNCTION ZINSERTA_ACREEDOR.
*"----------------------------------------------------------------------
*"*"Interfase local
*"  IMPORTING
*"     REFERENCE(STATUS) TYPE  STATUSFLAG1
*"     REFERENCE(BUKRS) TYPE  BUKRS
*"----------------------------------------------------------------------
DATA: W_NAME(60) TYPE C,
      W_NAME1(35) TYPE C,
      W_NAME2(35) TYPE C,
      W_LIFNR(10) TYPE C,
      W_BUKRS(4) TYPE C,
      W_STCD1(11) TYPE C.

IF STATUS = 'X'.
  exec sql.
    connect to 'SAPCSC' as 'con'
  endexec.

  exec sql.
    set connection 'con'
  endexec.
  SELECT A~NAME1 A~NAME2 A~STCD1 B~BUKRS A~LIFNR
    INTO (W_NAME1, W_NAME2, W_STCD1, W_BUKRS, W_LIFNR)
    FROM LFB1 AS B INNER JOIN LFA1 AS A
                ON B~LIFNR EQ A~LIFNR
    WHERE B~BUKRS = BUKRS .
    CONCATENATE W_NAME1 W_NAME2+0(25) INTO W_NAME.
    EXEC SQL.
        EXECUTE PROCEDURE csc_sap_auxiliares.sp_insert_sap_acreedor(
                        IN :W_STCD1,
                        IN :W_NAME,
                        IN :W_BUKRS,
                        IN :W_LIFNR
        )
    ENDEXEC.
  ENDSELECT.
  exec sql.
    SET CONNECTION DEFAULT
  endexec.
ENDIF.



ENDFUNCTION.
