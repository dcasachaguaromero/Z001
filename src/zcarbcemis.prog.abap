*&---------------------------------------------------------------------*
*& Report  ZCARBALMIS
*&
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*

REPORT  ZCARBCEMIS.
TABLES: FAGLFLEXT.

types: begin of est_salida,
          linea type string,
       end of est_salida.
data: it_salida type standard table of string.


DATA:  SQL(1023),
      CONTADOR   TYPE I,
      v_debe   LIKE FAGLFLEXT-TSL01,
      v_haber  LIKE FAGLFLEXT-TSL01,
      v_saldo  LIKE FAGLFLEXT-TSL01,
      v_debeb  LIKE FAGLFLEXT-TSL01,
      v_haberb LIKE FAGLFLEXT-TSL01,
      v_deber  LIKE FAGLFLEXT-TSL01,
      v_haberr LIKE FAGLFLEXT-TSL01,
      amount_display like  wmto_s-amount,
      amount_sap like  wmto_s-amount,
      v_error TYPE REF TO cx_sy_native_sql_error.


DATA: X_SOCIEDAD(4),
      X_CUENTA(20),
      X_EJERCICIO(4),
      X_MES(4),
      X_DEBE(25),
      X_HABER(25),
      X_SALDO(25).

 DATA: BEGIN OF T_BALANCE OCCURS 0,
  RBUKRS LIKE FAGLFLEXT-RBUKRS,
  RACCT  LIKE FAGLFLEXT-RACCT,
  RYEAR  LIKE FAGLFLEXT-RYEAR,
  RPMAX  LIKE FAGLFLEXT-RPMAX,
  RTCUR  LIKE FAGLFLEXT-RTCUR,
  RDEBE  LIKE FAGLFLEXT-TSL01,
  RHABER LIKE FAGLFLEXT-TSL01,
  RSALDO LIKE FAGLFLEXT-TSL01,
 END OF T_BALANCE.

 DATA: BEGIN OF T_SALDOS OCCURS 0,
  RBUKRS LIKE FAGLFLEXT-RBUKRS,
  RACCT  LIKE FAGLFLEXT-RACCT,
  RYEAR  LIKE FAGLFLEXT-RYEAR,
  RPMAX  LIKE FAGLFLEXT-RPMAX,
  RTCUR  LIKE FAGLFLEXT-RTCUR,
  RDEBE  LIKE FAGLFLEXT-TSL01,
  RHABER LIKE FAGLFLEXT-TSL01,
  RSALDO LIKE FAGLFLEXT-TSL01,
 END OF T_SALDOS.

 types: begin of est_balance,
  RBUKRS LIKE FAGLFLEXT-RBUKRS,
  RACCT  LIKE FAGLFLEXT-RACCT,
  RYEAR  LIKE FAGLFLEXT-RYEAR,
  RPMAX  LIKE FAGLFLEXT-RPMAX,
  RTCUR  LIKE FAGLFLEXT-RTCUR,
  RDEBE  LIKE FAGLFLEXT-TSL01,
  RHABER LIKE FAGLFLEXT-TSL01,
  RSALDO LIKE FAGLFLEXT-TSL01,
 end of est_balance.

DATA: REG TYPE est_balance.

SELECTION-SCREEN BEGIN OF BLOCK DATA WITH FRAME TITLE TEXT-T01.

  SELECT-OPTIONS   p_rbukrs  FOR FAGLFLEXT-rbukrs  OBLIGATORY.
  PARAMETERS: p_rldnr TYPE FAGLFLEXT-rldnr  DEFAULT '0L' OBLIGATORY ,
              p_ryear TYPE FAGLFLEXT-ryear        OBLIGATORY,
              p_rpmax TYPE FAGLFLEXT-rpmax        OBLIGATORY.
  SELECT-OPTIONS  s_racct FOR FAGLFLEXT-racct   .
SELECTION-SCREEN END OF BLOCK DATA.

at selection-screen .
CALL FUNCTION 'BUKRS_AUTHORITY_CHECK'
        EXPORTING
          xdatabase = 'B'
        TABLES
          xbukreis  = p_rbukrs.

START-OF-SELECTION.
      PERFORM OBTENER_DATOS.
      PERFORM PROCESAR_DATOS.
      PERFORM REGISTRAR_DATOS.

END-OF-SELECTION.

FORM OBTENER_DATOS.

   SELECT  RBUKRS RACCT RYEAR RPMAX RTCUR
   INTO  T_BALANCE
   FROM  FAGLFLEXT
   WHERE rbukrs  IN p_rbukrs
   AND ryear   EQ p_ryear
   AND rldnr   EQ p_rldnr
   AND racct   IN s_racct
   GROUP BY RBUKRS RACCT RYEAR RPMAX RTCUR
   order by RBUKRS RACCT.
   APPEND T_BALANCE.
   ENDSELECT.

ENDFORM.

FORM PROCESAR_DATOS.

  CLEAR T_SALDOS.
  REFRESH T_SALDOS.

  LOOP AT  T_BALANCE.
*   El SY-TABIX es una variable del sistema que nos indica el número
*   de vueltas que ha dado un LOOP.
    CONTADOR = SY-TABIX.

    v_debeb  =  0.
    v_deber  =  0.
    v_haberb =  0.
    v_haberr =  0.
    v_debe   =  0.
    v_haber  =  0.
    CASE p_rpmax.
        WHEN 1.
            SELECT    SUM( TSL01 )
             INTO     v_debe
               FROM  FAGLFLEXT
               WHERE rbukrs   EQ T_BALANCE-rbukrs
                 AND ryear    EQ T_BALANCE-ryear
                 AND racct    EQ T_BALANCE-racct
                 AND rldnr    EQ p_rldnr
                 AND DRCRK    EQ 'S'.

             SELECT    SUM( TSL01 )
             INTO      v_haber
               FROM  FAGLFLEXT
               WHERE rbukrs   EQ T_BALANCE-rbukrs
                 AND ryear    EQ T_BALANCE-ryear
                 AND racct    EQ T_BALANCE-racct
                 AND rldnr    EQ p_rldnr
                 AND DRCRK    EQ 'H'.
        WHEN 2.
             SELECT   SUM( TSL02 )
             INTO     v_debe
               FROM  FAGLFLEXT
               WHERE rbukrs   EQ T_BALANCE-rbukrs
                 AND ryear    EQ T_BALANCE-ryear
                 AND racct    EQ T_BALANCE-racct
                 AND rldnr    EQ p_rldnr
                 AND DRCRK    EQ 'S'.

             SELECT   SUM( TSL02 )
             INTO     v_haber
               FROM  FAGLFLEXT
               WHERE rbukrs   EQ T_BALANCE-rbukrs
                 AND ryear    EQ T_BALANCE-ryear
                 AND racct    EQ T_BALANCE-racct
                 AND rldnr   EQ p_rldnr
                 AND DRCRK    EQ 'H'.
        WHEN 3.
            SELECT   SUM( TSL03 )
             INTO    v_debe
               FROM  FAGLFLEXT
               WHERE rbukrs   EQ T_BALANCE-rbukrs
                 AND ryear    EQ T_BALANCE-ryear
                 AND racct    EQ T_BALANCE-racct
                 AND rldnr   EQ p_rldnr
                 AND DRCRK    EQ 'S'.

             SELECT  SUM( TSL03 )
             INTO    v_haber
               FROM  FAGLFLEXT
               WHERE rbukrs   EQ T_BALANCE-rbukrs
                 AND ryear    EQ T_BALANCE-ryear
                 AND racct    EQ T_BALANCE-racct
                 AND rldnr   EQ p_rldnr
                 AND DRCRK    EQ 'H'.
        WHEN 4.
             SELECT   SUM( TSL04 )
             INTO     v_debe
               FROM  FAGLFLEXT
               WHERE rbukrs   EQ T_BALANCE-rbukrs
                 AND ryear    EQ T_BALANCE-ryear
                 AND racct    EQ T_BALANCE-racct
                 AND rldnr   EQ p_rldnr
                 AND DRCRK    EQ 'S'.

             SELECT   SUM( TSL04 )
             INTO     v_haber
               FROM  FAGLFLEXT
               WHERE rbukrs   EQ T_BALANCE-rbukrs
                 AND ryear    EQ T_BALANCE-ryear
                 AND racct    EQ T_BALANCE-racct
                 AND rldnr   EQ p_rldnr
                 AND DRCRK    EQ 'H'.
        WHEN 5.
              SELECT   SUM( TSL05 )
             INTO      v_debe
               FROM  FAGLFLEXT
               WHERE rbukrs   EQ T_BALANCE-rbukrs
                 AND ryear    EQ T_BALANCE-ryear
                 AND racct    EQ T_BALANCE-racct
                 AND rldnr   EQ p_rldnr
                 AND DRCRK    EQ 'S'.

             SELECT   SUM( TSL05 )
             INTO     v_haber
               FROM  FAGLFLEXT
               WHERE rbukrs   EQ T_BALANCE-rbukrs
                 AND ryear    EQ T_BALANCE-ryear
                 AND racct    EQ T_BALANCE-racct
                 AND rldnr   EQ p_rldnr
                 AND DRCRK    EQ 'H'.
        WHEN 6.
             SELECT   SUM( TSL06 )
             INTO     v_debe
               FROM  FAGLFLEXT
               WHERE rbukrs   EQ T_BALANCE-rbukrs
                 AND ryear    EQ T_BALANCE-ryear
                 AND racct    EQ T_BALANCE-racct
                 AND rldnr   EQ p_rldnr
                 AND DRCRK    EQ 'S'.

             SELECT   SUM( TSL06 )
             INTO     v_haber
               FROM  FAGLFLEXT
               WHERE rbukrs   EQ T_BALANCE-rbukrs
                 AND ryear    EQ T_BALANCE-ryear
                 AND racct    EQ T_BALANCE-racct
                 AND rldnr   EQ p_rldnr
                 AND DRCRK    EQ 'H'.
        WHEN 7.
             SELECT   SUM( TSL07 )
             INTO     v_debe
               FROM  FAGLFLEXT
               WHERE rbukrs   EQ T_BALANCE-rbukrs
                 AND ryear    EQ T_BALANCE-ryear
                 AND racct    EQ T_BALANCE-racct
                 AND rldnr   EQ p_rldnr
                 AND DRCRK    EQ 'S'.

             SELECT   SUM( TSL07 )
             INTO     v_haber
               FROM  FAGLFLEXT
               WHERE rbukrs   EQ T_BALANCE-rbukrs
                 AND ryear    EQ T_BALANCE-ryear
                 AND racct    EQ T_BALANCE-racct
                 AND rldnr   EQ p_rldnr
                 AND DRCRK    EQ 'H'.
        WHEN 8.
             SELECT   SUM( TSL08 )
             INTO     v_debe
               FROM  FAGLFLEXT
               WHERE rbukrs   EQ T_BALANCE-rbukrs
                 AND ryear    EQ T_BALANCE-ryear
                 AND racct    EQ T_BALANCE-racct
                 AND rldnr    EQ p_rldnr
                 AND DRCRK    EQ 'S'.

             SELECT   SUM( TSL08 )
             INTO     v_haber
               FROM  FAGLFLEXT
               WHERE rbukrs   EQ T_BALANCE-rbukrs
                 AND ryear    EQ T_BALANCE-ryear
                 AND racct    EQ T_BALANCE-racct
                 AND rldnr    EQ p_rldnr
                 AND DRCRK    EQ 'H'.
        WHEN 9.
             SELECT   SUM( TSL09 )
             INTO     v_debe
               FROM  FAGLFLEXT
               WHERE rbukrs   EQ T_BALANCE-rbukrs
                 AND ryear    EQ T_BALANCE-ryear
                 AND racct    EQ T_BALANCE-racct
                 AND rldnr    EQ p_rldnr
                 AND DRCRK    EQ 'S'.

             SELECT   SUM( TSL09 )
             INTO     v_haber
               FROM  FAGLFLEXT
               WHERE rbukrs   EQ T_BALANCE-rbukrs
                 AND ryear    EQ T_BALANCE-ryear
                 AND racct    EQ T_BALANCE-racct
                 AND rldnr    EQ p_rldnr
                 AND DRCRK    EQ 'H'.
        WHEN 10.
             SELECT   SUM( TSL10 )
             INTO     v_debe
               FROM  FAGLFLEXT
               WHERE rbukrs   EQ T_BALANCE-rbukrs
                 AND ryear    EQ T_BALANCE-ryear
                 AND racct    EQ T_BALANCE-racct
                 AND rldnr    EQ p_rldnr
                 AND DRCRK    EQ 'S'.

             SELECT   SUM( TSL10 )
             INTO     v_haber
               FROM  FAGLFLEXT
               WHERE rbukrs   EQ T_BALANCE-rbukrs
                 AND ryear    EQ T_BALANCE-ryear
                 AND racct    EQ T_BALANCE-racct
                 AND rldnr    EQ p_rldnr
                 AND DRCRK    EQ 'H'.
        WHEN 11.
             SELECT   SUM( TSL11 )
             INTO     v_debe
               FROM  FAGLFLEXT
               WHERE rbukrs   EQ T_BALANCE-rbukrs
                 AND ryear    EQ T_BALANCE-ryear
                 AND racct    EQ T_BALANCE-racct
                 AND rldnr    EQ p_rldnr
                 AND DRCRK    EQ 'S'.

             SELECT   SUM( TSL11 )
             INTO     v_haber
               FROM  FAGLFLEXT
               WHERE rbukrs   EQ T_BALANCE-rbukrs
                 AND ryear    EQ T_BALANCE-ryear
                 AND racct    EQ T_BALANCE-racct
                 AND rldnr    EQ p_rldnr
                 AND DRCRK    EQ 'H'.
        WHEN 12.
             SELECT   SUM( TSL12 )
             INTO    v_debe
               FROM  FAGLFLEXT
               WHERE rbukrs   EQ T_BALANCE-rbukrs
                 AND ryear    EQ T_BALANCE-ryear
                 AND racct    EQ T_BALANCE-racct
                 AND rldnr    EQ p_rldnr
                 AND DRCRK    EQ 'S'.

             SELECT   SUM( TSL12 )
             INTO     v_haber
               FROM  FAGLFLEXT
               WHERE rbukrs   EQ T_BALANCE-rbukrs
                 AND ryear    EQ T_BALANCE-ryear
                 AND racct    EQ T_BALANCE-racct
                 AND rldnr    EQ p_rldnr
                 AND DRCRK    EQ 'H'.
        WHEN OTHERS.
    ENDCASE.

    T_BALANCE-RDEBE = v_debe   * 100.
    T_BALANCE-RHABER = v_haber * 100.

    if ( T_BALANCE-racct+0(1) = '1' or T_BALANCE-racct+0(1) = '2' ).
      v_saldo =  v_debe - v_haber.
    endif.
    if ( T_BALANCE-racct+0(1) = '3' or T_BALANCE-racct+0(1) = '4' or T_BALANCE-racct+0(1) = '5' ).
      v_saldo =   v_haber - v_debe.
    endif.

    T_BALANCE-RSALDO = v_saldo * 100.
    T_BALANCE-RPMAX = p_rpmax.

    "El MODIFY modifica la tabla interna, para agregar el valor
    "que hemos obtenido en el query anterior, utilizando como
    "indice, el número de vuelta del LOOP

    MODIFY T_BALANCE INDEX CONTADOR.

    v_debe   =  0.
    v_haber  =  0.

    SELECT SUM( TSLVT )
    INTO  v_debe
    FROM  FAGLFLEXT
    WHERE rbukrs   EQ T_BALANCE-rbukrs
    AND ryear    EQ T_BALANCE-ryear
    AND racct    EQ T_BALANCE-racct
    AND rldnr    EQ p_rldnr
    AND DRCRK    EQ 'S'.

    SELECT SUM( TSLVT )
    INTO   v_haber
    FROM  FAGLFLEXT
    WHERE rbukrs   EQ T_BALANCE-rbukrs
    AND ryear    EQ T_BALANCE-ryear
    AND racct    EQ T_BALANCE-racct
    AND rldnr    EQ p_rldnr
    AND DRCRK    EQ 'H'.

    REG-RBUKRS = T_BALANCE-rbukrs.
    REG-RACCT  = T_BALANCE-racct.
    REG-RYEAR  = T_BALANCE-ryear.
    REG-RPMAX  = 0.
    REG-RTCUR  = T_BALANCE-rtcur.
    REG-RDEBE  = v_debe  * 100.
    REG-RHABER = v_haber * 100.

    if ( T_BALANCE-racct+0(1) = '1' or T_BALANCE-racct+0(1) = '2' ).
      v_saldo =  v_debe - v_haber.
    endif.
    if ( T_BALANCE-racct+0(1) = '3' or T_BALANCE-racct+0(1) = '4' or T_BALANCE-racct+0(1) = '5' ).
      v_saldo =   v_haber - v_debe.
    endif.

    REG-RSALDO = v_saldo * 100.

    APPEND REG TO T_SALDOS.

  ENDLOOP.

  APPEND LINES OF T_SALDOS TO T_BALANCE.
ENDFORM.

FORM REGISTRAR_DATOS.

  perform openconnection.
  TRY.
     LOOP AT  T_BALANCE.
        X_SOCIEDAD  = T_BALANCE-RBUKRS.
        X_CUENTA    = T_BALANCE-RACCT.
        X_EJERCICIO = T_BALANCE-RYEAR.
        X_MES       = T_BALANCE-RPMAX.
        X_DEBE      = T_BALANCE-RDEBE.
        X_HABER     = T_BALANCE-RHABER.
        X_SALDO     = T_BALANCE-RSALDO.

        IF ( X_DEBE NE 0 or X_HABER NE 0 or X_SALDO NE 0 ).
          EXEC SQL.
            EXECUTE PROCEDURE  MIS_GES.SAP_INSERT_SALDOS_BCE
                   (
                   IN :X_SOCIEDAD,
                   IN :X_CUENTA,
                   IN :X_EJERCICIO,
                   IN :X_MES,
                   IN :X_DEBE,
                   IN :X_HABER,
                   IN :X_SALDO
                   )
          ENDEXEC.
        ENDIF.
     ENDLOOP.
  CATCH cx_sy_native_sql_error INTO v_error.
    WRITE: / 'ERROR:', v_error->kernel_errid.

  ENDTRY.
  message 'Termino la extracción de datos' type 'S'.
  perform closeconnection.
ENDFORM.

form openconnection.
    exec sql.
          connect to 'MISGES' as 'CON'
       endexec.
      exec sql.
          set connection 'CON'
      endexec.
endform.

form closeconnection.
    exec sql.
      SET CONNECTION DEFAULT
    endexec.
endform.
