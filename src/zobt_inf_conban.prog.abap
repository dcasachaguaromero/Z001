*&---------------------------------------------------------------------*
*& Report  ZOBT_INF_CONBAN
*&
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*

REPORT  ZOBT_INF_CONBAN.

types: begin of est_salida,
  bukrs type bsis-bukrs,  "Sociedad
  hkont type bsis-hkont,  "Cuenta
  augdt type bsis-augdt,  "Compensa
  augbl type bsis-augbl,  "Doc.Commpensa
  zuonr type bsis-zuonr,  "Asignacion
  gjahr type bsis-gjahr,  "Anio
  belnr type bsis-belnr,  "Nro.Documento
  buzei type bsis-buzei,  "Posicion
  budat type bsis-budat,  "Fecha Contabilizacion
  bldat type bsis-bldat,  "Fecha Documento
  waers type bsis-waers,  "Moneda
  xblnr type bsis-xblnr,  "Referencia
  blart type bsis-blart,  "Clase Documento
  monat type bsis-monat,  "Periodo Contable
  bschl type bsis-bschl,  "CT
  shkzg type bsis-shkzg,  "Debe/Haber
  fkont type bsis-fkont,  "PIT
  dmbtr type bsis-dmbtr,  "Importe Moneda Local
  wrbtr type bsis-wrbtr,  "Importe
  sgtxt type bsis-sgtxt,  "Texto
  zfbdt type bsis-zfbdt,  "Fecha Base
  valut type bsis-valut,  "Fecha Valor
  pswsl type bsis-pswsl,  "Importe Actualizacion en el libro Mayor
  dmbe2 type bsis-dmbe2,  "Importe Moneda Local 2
  dmbe3 type bsis-dmbe3,  "Importe Moneda Local 3
  xragl type bsis-xragl,  "Anular Compensacion
  pswbt type bsis-pswbt,  "Importe Libro Mayor
end of est_salida.

data: it_salida type standard table of est_salida with header line,
      it_bsis type standard table of bsis with header line,
      it_bsas type standard table of bsas with header line,
      wa like line of it_bsis,
      fecpro type datum.

data: r_hkont type range of bsis-hkont with header line. " Rango para Cuenta

selection-screen begin of block b1 with frame.
  select-options s_bukrs for it_bsis-bukrs obligatory.
  selection-screen end of block b1.

r_hkont-sign = 'I'.
r_hkont-option = 'BT'.
r_hkont-low = '1011120010'.
r_hkont-high = '1011129009'.

append r_hkont.

* BEGIN. 07-07-2026 - ATC - ATC-03
* OLD CODE
*select *
*  from bsis
*  into corresponding fields of table it_bsis
*  where bukrs in s_bukrs
*  and hkont in r_hkont.
*
* NEW CODE
SELECT *

  from bsis
  into corresponding fields of table it_bsis
  where bukrs in s_bukrs
  and hkont in r_hkont ORDER BY PRIMARY KEY.

* END. 07-07-2026 - ATC - ATC-03

* BEGIN. 07-07-2026 - ATC - ATC-03
* OLD CODE
*select *
*  from bsas
*  into corresponding fields of table it_bsas
*  where bukrs in s_bukrs
*  and hkont in r_hkont.
*
* NEW CODE
SELECT *

  from bsas
  into corresponding fields of table it_bsas
  where bukrs in s_bukrs
  and hkont in r_hkont ORDER BY PRIMARY KEY.

* END. 07-07-2026 - ATC - ATC-03

exec sql.
  connect to 'SAPQAS' as 'con'
endexec.

exec sql.
  set connection 'con'
endexec.

"Dia Actual
fecpro = sy-datlo.

"Elimino registros por sociedad
loop at s_bukrs.
  try.
    exec sql.
      delete from sap_conban
      where fechacarga = to_date(:fecpro,'yyyymmdd')
      and   sociedad = :s_bukrs-low
    endexec.
  catch cx_sy_native_sql_error.
    message `Error borrar tabla sap_conban` type 'I'.
  endtry.
endloop.

loop at it_bsis into wa.
  exec sql.
    insert into sap_qas.sap_conban (sociedad,cuenta,feccompensa,doccompensa,nroasigna,ejercicio,
                                    nrocompro,posicion,feccompro,fecdocum,moneda,referencia,
                                    clasedoc,mescontable,claveconta,sentido,pit,impmonloc,
                                    impmondoc,texto,fecbasvenc,fecvalor,monactlibmay,impmonloc2,
                                    impmonloc3, anucompensa, implibmay,compensado,fechacarga)
    values(:wa-bukrs,:wa-hkont,:wa-augdt,:wa-augbl,:wa-zuonr,:wa-gjahr,
           :wa-belnr,:wa-buzei,:wa-budat,:wa-bldat,:wa-waers,:wa-xblnr,
           :wa-blart,:wa-monat,:wa-bschl,:wa-shkzg,:wa-fkont,to_number(:wa-dmbtr)*100,
           to_number(:wa-wrbtr)*100,:wa-sgtxt,:wa-zfbdt,:wa-valut,:wa-pswsl,to_number(:wa-dmbe2)*100,
           to_number(:wa-dmbe3)*100,:wa-xragl,to_number(:wa-pswbt)*100,'NO',to_date(:fecpro,'yyyymmdd'))
  endexec.
endloop.

loop at it_bsas into wa.
  exec sql.
    insert into sap_qas.sap_conban (sociedad,cuenta,feccompensa,doccompensa,nroasigna,ejercicio,
                                    nrocompro,posicion,feccompro,fecdocum,moneda,referencia,
                                    clasedoc,mescontable,claveconta,sentido,pit,impmonloc,
                                    impmondoc,texto,fecbasvenc,fecvalor,monactlibmay,impmonloc2,
                                    impmonloc3, anucompensa, implibmay,compensado,fechacarga)
    values(:wa-bukrs,:wa-hkont,:wa-augdt,:wa-augbl,:wa-zuonr,:wa-gjahr,
           :wa-belnr,:wa-buzei,:wa-budat,:wa-bldat,:wa-waers,:wa-xblnr,
           :wa-blart,:wa-monat,:wa-bschl,:wa-shkzg,:wa-fkont,to_number(:wa-dmbtr)*100,
           to_number(:wa-wrbtr)*100,:wa-sgtxt,:wa-zfbdt,:wa-valut,:wa-pswsl,to_number(:wa-dmbe2)*100,
           to_number(:wa-dmbe3)*100,:wa-xragl,to_number(:wa-pswbt)*100,'SI',to_date(:fecpro,'yyyymmdd'))
  endexec.
endloop.

exec sql.
  set connection default
endexec.
