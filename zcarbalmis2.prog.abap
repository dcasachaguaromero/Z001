*&---------------------------------------------------------------------*
*& Report  ZCARBALMIS
*&
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*

REPORT  ZCARBALMIS2.
TABLES: FAGLFLEXT.
*----------------------------------------------------------------------*
INCLUDE ole2incl.
*----------------------------------------------------------------------*
types: begin of est_salida,
          linea type string,
       end of est_salida.
data: it_salida type standard table of string.

DATA: con TYPE ole2_object,
      rec TYPE ole2_object,
      SQL(1023),
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
      PERFORM EJECUTA_MIS.
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
            EXECUTE PROCEDURE  MIS_GES.SAP_INSERT_SALDOS
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

form EJECUTA_MIS.
  data: fecha_proceso type string,
        estado type string,
        strMensaje type string,
        commandline like RLGRAP-FILENAME,
        program like RLGRAP-FILENAME,
        path like RLGRAP-FILENAME.
  data: linea1 type string value 'connect mis-csm',
        linea2 type string value 'rrun consolidado.imd',
        linea2a type string,
        linea3 type string value 'close',
        linea4 type string value 'exit'.

  " Cambio Estado en tabla MIS_EJECUTA
  " Construyo Periodo a ajecutar.

  SHIFT p_rpmax LEFT DELETING LEADING '0'.

  CASE p_rpmax.
    WHEN 1.
      concatenate 'Enero ' p_ryear into fecha_proceso respecting blanks.
    WHEN 2.
      concatenate 'Febrero ' p_ryear into fecha_proceso respecting blanks.
    WHEN 3.
      concatenate 'Marzo ' p_ryear into fecha_proceso respecting blanks.
    WHEN 4.
      concatenate 'Abril ' p_ryear into fecha_proceso respecting blanks.
    WHEN 5.
      concatenate 'Mayo ' p_ryear into fecha_proceso respecting blanks.
    WHEN 6.
      concatenate 'Junio ' p_ryear into fecha_proceso respecting blanks.
    WHEN 7.
      concatenate 'Julio ' p_ryear into fecha_proceso respecting blanks.
    WHEN 8.
      concatenate 'Agosto ' p_ryear into fecha_proceso respecting blanks.
    WHEN 9.
      concatenate 'Septiembre ' p_ryear into fecha_proceso respecting blanks.
    WHEN 10.
      concatenate 'Octubre ' p_ryear into fecha_proceso respecting blanks.
    WHEN 11.
      concatenate 'Noviembre ' p_ryear into fecha_proceso respecting blanks.
    WHEN 12.
      concatenate 'Diciembre ' p_ryear into fecha_proceso respecting blanks.
  ENDCASE.

  if p_rbukrs-low eq 'CL01' or p_rbukrs-low eq 'CL24'.
********** "Creo archivo de ejecucion carga - CL01
    clear it_salida.
    clear path.
    clear linea2a.

    append linea1 to it_salida.
    concatenate linea2 ' "carga BAN" RADMIN' into linea2a respecting blanks.
    append linea2a to it_salida.
    append linea3 to it_salida.
    append linea4 to it_salida.

    path = 'c:\mis\cargaban.txt'.

    perform crea_archivo using path.

*    "Ejecuta carga MIS.
    commandline = 'C:\MIS\CARGABAN.TXT'.
    program = 'C:\MIS\RSTART.EXE'.
    perform ejecuta_carga using 'CL01' fecha_proceso path commandline program.

*    "Creo archivo de ejecucion integracion
    clear it_salida.
    clear path.
    clear linea2a.

    append linea1 to it_salida.
    concatenate linea2 ' "integra BAN" RADMIN' into linea2a respecting blanks.
    append linea2a to it_salida.
    append linea3 to it_salida.
    append linea4 to it_salida.

    path = 'c:\mis\integraban.txt'.

    perform crea_archivo using path.

  elseif p_rbukrs-low eq 'CL39' or p_rbukrs-low eq 'CL40'.
********** "Creo archivo de ejecucion - CL39
    clear it_salida.
    clear path.
    clear linea2a.

    append linea1 to it_salida.
    concatenate linea2 ' "carga BIO" RADMIN' into linea2a respecting blanks.
    append linea2a to it_salida.
    append linea3 to it_salida.

    append linea4 to it_salida.

    path = 'c:\mis\cargabio.txt'.

    perform crea_archivo using path.

*    "Ejecuta carga MIS.
    commandline = 'C:\MIS\CARGABIO.TXT'.
    program = 'C:\MIS\RSTART.EXE'.
    perform ejecuta_carga using 'CL39' fecha_proceso path commandline program.

*    "Creo archivo de ejecucion integracion
    clear it_salida.
    clear path.
    clear linea2a.

    append linea1 to it_salida.
    concatenate linea2 ' "integra BIO" RADMIN' into linea2a respecting blanks.
    append linea2a to it_salida.
    append linea3 to it_salida.
    append linea4 to it_salida.

    path = 'c:\mis\integrabio.txt'.

    perform crea_archivo using path.

  elseif p_rbukrs-low eq 'CL05'.
********** "Creo archivo de ejecucion - CL05
    clear it_salida.
    clear path.
    clear linea2a.

    append linea1 to it_salida.
    concatenate linea2 ' "carga BSA" RADMIN' into linea2a respecting blanks.
    append linea2a to it_salida.
    append linea3 to it_salida.
    append linea4 to it_salida.

    path = 'c:\mis\cargabsa.txt'.

    perform crea_archivo using path.

*    "Ejecuta carga MIS.
    commandline = 'C:\MIS\CARGABSA.TXT'.
    program = 'C:\MIS\RSTART.EXE'.
    perform ejecuta_carga using 'CL05' fecha_proceso path commandline program.

    "Creo archivo de ejecucion Integracion
    clear it_salida.
    clear path.
    clear linea2a.

    append linea1 to it_salida.
    concatenate linea2 ' "integra BSA" RADMIN' into linea2a respecting blanks.
    append linea2a to it_salida.
    append linea3 to it_salida.
    append linea4 to it_salida.

    path = 'c:\mis\integrabsa.txt'.

    perform crea_archivo using path.

  elseif p_rbukrs-low eq 'CL29' or p_rbukrs-low eq 'CL30'.
********** "Creo archivo de ejecucion - CL29
    clear it_salida.
    clear path.
    clear linea2a.

    append linea1 to it_salida.
    concatenate linea2 ' "carga CDM" RADMIN' into linea2a respecting blanks.
    append linea2a to it_salida.
    append linea3 to it_salida.
    append linea4 to it_salida.

    path = 'c:\mis\cargacdm.txt'.

    perform crea_archivo using path.

*    Ejecuta carga MIS.
    commandline = 'C:\MIS\CARGACDM.TXT'.
    program = 'C:\MIS\RSTART.EXE'.
    perform ejecuta_carga using 'CL29' fecha_proceso path commandline program.

*   Creo archivo de ejecucion
    clear it_salida.
    clear path.
    clear linea2a.

    append linea1 to it_salida.
    concatenate linea2 ' "integra CDM" RADMIN' into linea2a respecting blanks.
    append linea2a to it_salida.
    append linea3 to it_salida.
    append linea4 to it_salida.

    path = 'c:\mis\integracdm.txt'.

    perform crea_archivo using path.

  elseif p_rbukrs-low eq 'CL35' or p_rbukrs-low eq 'CL36'.
********** "Creo archivo de ejecucion - CL35
    clear it_salida.
    clear path.
    clear linea2a.

    append linea1 to it_salida.
    concatenate linea2 ' "carga CSM" RADMIN' into linea2a respecting blanks..
    append linea2a to it_salida.
    append linea3 to it_salida.
    append linea4 to it_salida.

    path = 'c:\mis\cargacsm.txt'.

    perform crea_archivo using path.

*    "Ejecuta carga MIS.
    commandline = 'C:\MIS\CARGACSM.TXT'.
    program = 'C:\MIS\RSTART.EXE'.
    perform ejecuta_carga using 'CL35' fecha_proceso path commandline program.

*    "Creo archivo de ejecucion integracion
    clear it_salida.
    clear path.
    clear linea2a.

    append linea1 to it_salida.
    concatenate linea2 ' "integra CSM" RADMIN' into linea2a respecting blanks..
    append linea2a to it_salida.
    append linea3 to it_salida.
    append linea4 to it_salida.

    path = 'c:\mis\integracsm.txt'.

    perform crea_archivo using path.

  elseif p_rbukrs-low eq 'CL17' or p_rbukrs-low eq 'CL13' or p_rbukrs-low eq 'CL15'.
******** "Creo archivo de ejecucion - CL17
    clear it_salida.
    clear path.
    clear linea2a.

    append linea1 to it_salida.
    concatenate linea2 ' "carga DAV" RADMIN' into linea2a respecting blanks.
    append linea2a to it_salida.
    append linea3 to it_salida.
    append linea4 to it_salida.

    path = 'c:\mis\cargadav.txt'.

    perform crea_archivo using path.

*    "Ejecuta carga MIS.
    commandline = 'C:\MIS\CARGADAV.TXT'.
    program = 'C:\MIS\RSTART.EXE'.
    perform ejecuta_carga using 'CL17' fecha_proceso path commandline program.

*    "Creo archivo de ejecucion
    clear it_salida.
    clear path.
    clear linea2a.

    append linea1 to it_salida.
    concatenate linea2 ' "integra DAV" RADMIN' into linea2a respecting blanks.
    append linea2a to it_salida.
    append linea3 to it_salida.
    append linea4 to it_salida.

    path = 'c:\mis\integradav.txt'.

    perform crea_archivo using path.

  elseif p_rbukrs-low eq 'CL06' or p_rbukrs-low eq 'CL51' or p_rbukrs-low eq 'CL57'.
********** "Creo archivo de ejecucion - CL06
    clear it_salida.
    clear path.
    clear linea2a.

    append linea1 to it_salida.
    concatenate linea2 ' "carga HEL" RADMIN' into linea2a respecting blanks.
    append linea2a to it_salida.
    append linea3 to it_salida.
    append linea4 to it_salida.

    path = 'c:\mis\cargahel.txt'.

    perform crea_archivo using path.

*    "Ejecuta carga MIS.
    commandline = 'C:\MIS\CARGAHEL.TXT'.
    program = 'C:\MIS\RSTART.EXE'.
    perform ejecuta_carga using 'CL51' fecha_proceso path commandline program.

*    "Creo archivo de ejecucion integracion
    clear it_salida.
    clear path.
    clear linea2a.

    append linea1 to it_salida.
    concatenate linea2 ' "integra HEL" RADMIN' into linea2a respecting blanks.
    append linea2a to it_salida.
    append linea3 to it_salida.
    append linea4 to it_salida.

    path = 'c:\mis\integrahel.txt'.

    perform crea_archivo using path.

  elseif p_rbukrs-low eq 'CL02'.
********** "Creo archivo de ejecucion - CL02
    clear it_salida.
    clear path.
    clear linea2a.

    append linea1 to it_salida.
    concatenate linea2 ' "carga HOM" RADMIN' into linea2a respecting blanks.
    append linea2a to it_salida.
    append linea3 to it_salida.
    append linea4 to it_salida.

    path = 'c:\mis\cargahom.txt'.

    perform crea_archivo using path.

*    "Ejecuta carga MIS.
    commandline = 'C:\MIS\CARGAHOM.TXT'.
    program = 'C:\MIS\RSTART.EXE'.
    perform ejecuta_carga using 'CL02' fecha_proceso path commandline program.

*    "Creo archivo de ejecucion
    clear it_salida.
    clear path.
    clear linea2a.

    append linea1 to it_salida.
    concatenate linea2 ' "integra HOM" RADMIN' into linea2a respecting blanks.
    append linea2a to it_salida.
    append linea3 to it_salida.
    append linea4 to it_salida.

    path = 'c:\mis\integrahom.txt'.

    perform crea_archivo using path.

  elseif p_rbukrs-low eq 'CL07' or p_rbukrs-low eq 'CL08' or p_rbukrs-low eq 'CL14' or p_rbukrs-low eq 'CL32' or p_rbukrs-low eq 'CL33'.
********** "Creo archivo de ejecucion - CL07
    clear it_salida.
    clear path.
    clear linea2a.

    append linea1 to it_salida.
    concatenate linea2 '"carga INM" RADMIN' into linea2a respecting blanks.
    append linea2a to it_salida.
    append linea3 to it_salida.
    append linea4 to it_salida.

    path = 'c:\mis\cargainm.txt'.

    perform crea_archivo using path.

*    "Ejecuta carga MIS.
    commandline = 'C:\MIS\CARGAINM.TXT'.
    program = 'C:\MIS\RSTART.EXE'.
    perform ejecuta_carga using 'CL07' fecha_proceso path commandline program.

*    "Creo archivo de ejecucion integracion
    clear it_salida.
    clear path.
    clear linea2a.

    append linea1 to it_salida.
    concatenate linea2 ' "integra INM" RADMIN' into linea2a respecting blanks.
    append linea2a to it_salida.
    append linea3 to it_salida.
    append linea4 to it_salida.

    path = 'c:\mis\integrainm.txt'.

    perform crea_archivo using path.

  elseif p_rbukrs-low eq 'CL34'.
********** "Creo archivo de ejecucion - CL34
    clear it_salida.
    clear path.
    clear linea2a.

    append linea1 to it_salida.
    concatenate linea2 ' "carga V3I" RADMIN' into linea2a respecting blanks.
    append linea2a to it_salida.
    append linea3 to it_salida.
    append linea4 to it_salida.

    path = 'c:\mis\cargav3i.txt'.

    perform crea_archivo using path.

*    "Ejecuta carga MIS.
    commandline = 'C:\MIS\CARGAV3I.TXT'.
    program = 'C:\MIS\RSTART.EXE'.
    perform ejecuta_carga using 'CL34' fecha_proceso path commandline program.

*    "Creo archivo de ejecucion
    clear it_salida.
    clear path.
    clear linea2a.

    append linea1 to it_salida.
    concatenate linea2 ' "integra V3I" RADMIN' into linea2a respecting blanks.
    append linea2a to it_salida.
    append linea3 to it_salida.
    append linea4 to it_salida.

    path = 'c:\mis\integrav3i.txt'.

    perform crea_archivo using path.

  elseif p_rbukrs-low eq 'CL27' or p_rbukrs-low eq 'CL28'.
********** "Creo archivo de ejecucion - CL27
    clear it_salida.
    clear path.
    clear linea2a.

    append linea1 to it_salida.
    concatenate linea2 ' "carga VES" RADMIN' into linea2a respecting blanks.
    append linea2a to it_salida.
    append linea3 to it_salida.
    append linea4 to it_salida.

    path = 'c:\mis\cargaves.txt'.

    perform crea_archivo using path.

*    "Ejecuta carga MIS.
    commandline = 'C:\MIS\CARGAVES.TXT'.
    program = 'C:\MIS\RSTART.EXE'.
    perform ejecuta_carga using 'CL27' fecha_proceso path commandline program.

*    "Creo archivo de ejecucion
    clear it_salida.
    clear path.
    clear linea2a.

    append linea1 to it_salida.
    concatenate linea2 ' "integra VES" RADMIN' into linea2a respecting blanks.
    append linea2a to it_salida.
    append linea3 to it_salida.
    append linea4 to it_salida.

    path = 'c:\mis\integraves.txt'.

    perform crea_archivo using path.

  elseif p_rbukrs-low eq 'CL12' or p_rbukrs-low eq 'CL16' or p_rbukrs-low eq 'CL52' or p_rbukrs-low eq 'CL65'.
********** "Creo archivo de ejecucion - CL12
    clear it_salida.
    clear path.
    clear linea2a.

    append linea1 to it_salida.
    concatenate linea2 ' "carga VIN" RADMIN' into linea2a respecting blanks.
    append linea2a to it_salida.
    append linea3 to it_salida.
    append linea4 to it_salida.

    path = 'c:\mis\cargavin.txt'.

    perform crea_archivo using path.

*    "Ejecuta carga MIS.
    commandline = 'C:\MIS\CARGAVIN.TXT'.
    program = 'C:\MIS\RSTART.EXE'.
    perform ejecuta_carga using 'CL52' fecha_proceso path commandline program.

*    "Creo archivo de ejecucion
    clear it_salida.
    clear path.
    clear linea2a.

    append linea1 to it_salida.
    concatenate linea2 ' "integra VIN" RADMIN' into linea2a respecting blanks.
    append linea2a to it_salida.
    append linea3 to it_salida.
    append linea4 to it_salida.

    path = 'c:\mis\integravin.txt'.

    perform crea_archivo using path.

  elseif p_rbukrs-low eq 'CL43'.
********** "Creo archivo de ejecucion - CL43
    clear it_salida.
    clear path.
    clear linea2a.

    append linea1 to it_salida.
    concatenate linea2 ' "carga ICL" RADMIN' into linea2a respecting blanks.
    append linea2a to it_salida.
    append linea3 to it_salida.
    append linea4 to it_salida.

    path = 'c:\mis\cargaicl.txt'.

    perform crea_archivo using path.

*    "Ejecuta carga MIS.
    commandline = 'C:\MIS\CARGAICL.TXT'.
    program = 'C:\MIS\RSTART.EXE'.
    perform ejecuta_carga using 'CL43' fecha_proceso path commandline program.

*    "Creo archivo de ejecucion
    clear it_salida.
    clear path.
    clear linea2a.

    append linea1 to it_salida.
    concatenate linea2 ' "integra ICL" RADMIN' into linea2a respecting blanks.
    append linea2a to it_salida.
    append linea3 to it_salida.
    append linea4 to it_salida.

    path = 'c:\mis\integraicl.txt'.

    perform crea_archivo using path.

  else.
      concatenate 'La sociedad ' p_rbukrs-low ' no esta configurada para actualizar MIS.' into strMensaje respecting blanks.
      message strMensaje type 'I'.
  endif.

"   message 'Termino la Carga MIS' type 'S'.

endform.

form crea_archivo using path like RLGRAP-FILENAME.
  CALL FUNCTION 'WS_DOWNLOAD'
     EXPORTING
          FILENAME                = path
          FILETYPE                = 'ASC'
      TABLES
           DATA_TAB                = it_salida
      EXCEPTIONS
     INTERNAL_ERROR        = 1
     OTHERS                = 2.

  CASE sy-subrc.
    WHEN 1.
      WRITE 'Validar Ruta y nombre de archivo'.
    WHEN 2.
      WRITE 'Validar Ruta y nombre de archivo'.
  ENDCASE.
endform.

form ejecuta_carga using sociedad type string
                         fecha_proceso type string
                         path like RLGRAP-FILENAME
                         commandline like RLGRAP-FILENAME
                         program like RLGRAP-FILENAME.
data: estado type string,
      strMensaje type string.

 perform openconnection.
 try.
   exec sql.
        execute procedure mis_ges.sap_update_mis_ejecuta(
                          in :sociedad,
                          in :fecha_proceso,
                          out :estado)
      endexec.
 catch cx_sy_native_sql_error.
   message 'Error no se pudo actualizar mis_ejecuta' type 'I'.
 endtry.

 if estado cs 'CORRIENDO'.
      concatenate sociedad ' para ' fecha_proceso ' ya se esta actualizando' into strMensaje respecting blanks.
      MESSAGE strMensaje TYPE 'I'.
 else.
      CALL FUNCTION 'WS_EXECUTE'
      EXPORTING
*        CD            = 'c:\mis' - CBD
         PROGRAM       = program
         COMMANDLINE   = commandline
      EXCEPTIONS
         FRONTEND_ERROR           = 1
         NO_BATCH                 = 2
         PROG_NOT_FOUND           = 3
         ILLEGAL_OPTION           = 4
         GUI_REFUSE_EXECUTE       = 5
         OTHERS                   = 6.

      CASE SY-SUBRC.
         WHEN 1.
           WRITE: / 'FRONTEND ERROR'.
         WHEN 2.
           WRITE: / 'NO BATCH'.
         WHEN 3.
           WRITE: / 'PROGRAM NOT FOUND'.
         WHEN 4.
           WRITE: / 'ILLEGA OPTION'.
         WHEN 5.
           WRITE: / 'GUI REFUSE EXECUTE'.
         WHEN 6.
           WRITE: / 'OTHERS'.
      ENDCASE.
 endif.

 perform closeconnection.

endform.
