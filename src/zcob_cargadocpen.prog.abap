*&---------------------------------------------------------------------*
*& Report  ZCOB_CARGADOCPEN
*&
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*

REPORT  ZCOB_CARGADOCPEN.

tables : bsid.
types: begin of est_salida,
        bukrs type bsid-bukrs,  "Sociedad
        sigla(20) type c,       "Nombre Empresa
        rut   type kna1-stcd1,  "Id.Deudor o Cliente
        belnr type bsid-belnr,  "Nro.Doc.Contable
        budat type bsid-budat,  "Fecha Contabilizacion
        xblnr type bsid-xblnr,  "Referencia Documento cuando aplica
        blart type bsid-blart,  "Tipo Documento Sap
        sgtxt type bsid-sgtxt,  "Glosa
        debe  type bsid-dmbtr,  "Debe
        haber type bsid-dmbtr,  "Haber
        saldo type bsid-dmbtr,  "Saldo
        saldoabs type bsid-dmbtr, "Saldo Absoluto
       end of est_salida.

data: it_salida type standard table of est_salida with header line,
      it_bsid type standard table of bsid with header line.

data: r_bukrs type range of bsid-bukrs with header line, " Rango para Sociedades
      r_saknr type range of bsid-saknr with header line. " Rango para Cuenta

data: wa type est_salida.

selection-screen begin of block b1 with frame.
parameters: p_nocsi radiobutton group r1,
            p_nocno radiobutton group r1 default 'X'.
selection-screen end of block b1.

selection-screen begin of block b2 with frame.
  Parameter: p_fecpro type datum.
selection-screen end of block b2.

selection-screen begin of block b3 with frame.
  select-options s_gjahr for bsid-gjahr.
selection-screen end of block b3.

if p_nocsi eq 'X'.
  p_fecpro = sy-datlo.
endif.

r_bukrs-sign = 'I'.
r_bukrs-option = 'EQ'.
r_bukrs-low = 'CL12'.
append r_bukrs.

r_bukrs-sign = 'I'.
r_bukrs-option = 'EQ'.
r_bukrs-low = 'CL16'.
append r_bukrs.

r_bukrs-sign = 'I'.
r_bukrs-option = 'EQ'.
r_bukrs-low = 'CL65'.
append r_bukrs.

" Cuenta 1204
r_saknr-sign = 'I'.
r_saknr-option = 'EQ'.
r_saknr-low = '1011920021'.

* BEGIN. 07-07-2026 - ATC - ATC-03
* OLD CODE
*select *
*  from bsid
*  into corresponding fields of table it_bsid
*  where bukrs in r_bukrs
*  and saknr in r_saknr
*  and gjahr in s_gjahr.
*
* NEW CODE
SELECT *

  from bsid
  into corresponding fields of table it_bsid
  where bukrs in r_bukrs
  and saknr in r_saknr
  and gjahr in s_gjahr ORDER BY PRIMARY KEY.

* END. 07-07-2026 - ATC - ATC-03

loop at it_bsid.

  wa-bukrs = it_bsid-bukrs.  "Sociedad

  if it_bsid-bukrs eq 'CL12'.
    wa-sigla = 'OMESA'.
  elseif it_bsid-bukrs eq 'CL16'.
    wa-sigla = 'ALAMEDA'.
  elseif it_bsid-bukrs eq 'CL65'.
    wa-sigla = 'MULTIMED'.
  endif.

* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*  select single stcd1        "Rut del deudor
*    into (wa-rut)
*    from kna1
*    where kunnr eq it_bsid-kunnr.
*
* NEW CODE
  SELECT stcd1        "Rut del deudor
  UP TO 1 ROWS 
    into (wa-rut)
    from kna1
    where kunnr eq it_bsid-kunnr ORDER BY PRIMARY KEY.

  ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01

  replace all occurrences of '-' in wa-rut with ''.

  wa-belnr = it_bsid-belnr.  "Nro.Doc.Contable
  wa-budat = it_bsid-budat.  "Fecha Contabilizacion

  "Caso especial, respecto a referencia en comprobante de apertura.
  if it_bsid-bukrs eq 'CL12' and it_bsid-gjahr eq '2010' and it_bsid-belnr eq '0100004014'.
    wa-xblnr = it_bsid-zuonr. "Campo Asignacion
  else.
    wa-xblnr = it_bsid-xblnr.  "Referencia Documento cuando aplica
  endif.

  wa-blart = it_bsid-blart.  "Tipo Documento Sap
  wa-sgtxt = it_bsid-sgtxt.  "Glosa

  wa-debe = 0.
  wa-saldo = 0.
  wa-saldoabs = 0.

  if it_bsid-shkzg = 'S'. "Debe
    wa-debe = it_bsid-dmbtr * 100.
    wa-haber = 0.
    wa-saldo = it_bsid-dmbtr * 100.
    wa-saldoabs = it_bsid-dmbtr * 100.
  elseif it_bsid-shkzg = 'H'. "Haber
    wa-debe = 0.
    wa-haber = it_bsid-dmbtr * 100.
    wa-saldo = it_bsid-dmbtr * 100 * -1.
    wa-saldoabs = it_bsid-dmbtr * 100.
  endif.

  append wa to it_salida.

endloop.

exec sql.
  connect to 'GOLDEN' as 'con'
endexec.

exec sql.
  set connection 'con'
endexec.

try.
  exec sql.
    delete from cob_penpag
    where fecha_carga = to_date(:p_fecpro,'yyyymmdd')
    and empresa in ('12','16','65')
  endexec.
catch cx_sy_native_sql_error.
  message `Error al borrar tabla cob_penpag` type 'I'.
endtry.

loop at it_salida.
  exec sql.
    insert into cob_penpag      (empresa,
                                 sigla,
                                 alias_cuenta,
                                 fecha,
                                 comprobante,
                                 correlativo,
                                 secuencia,
                                 glosa,
                                 debe,
                                 haber,
                                 tipo_documento,
                                 referencia,
                                 fecha_original,
                                 correlativo_original,
                                 rut_cliente,
                                 fecha_vencimiento,
                                 origen,
                                 calce,
                                 saldo,
                                 saldo_abs,
                                 usuario_log,
                                 usuario_mod,
                                 fecha_cambio,
                                 fecha_carga)
    values (to_char(to_number(substr(:it_salida-bukrs,3,2))),
            to_char(:it_salida-sigla),
            '1204',
            to_char(:it_salida-budat),
            to_char(:it_salida-belnr),
            null,
            null,
            substr(to_char(:it_salida-sgtxt),1,30),
            to_char(:it_salida-debe),
            to_char(:it_salida-haber),
            to_char(:it_salida-blart),
            to_char(:it_salida-xblnr),
            null,
            null,
            substr(to_char(:it_salida-rut),1,10),
            null,
            'SAP',
            null,
            to_char(:it_salida-saldo),
            to_char(:it_salida-saldoabs),
            null,
            null,
            null,
            to_date(:p_fecpro,'yyyymmdd'))
  endexec.
endloop.

exec sql.
   update cob_penpag
   set tipo_documento = nvl(( select cob_tipdoc.destino
                              from cob_tipdoc
                              where cob_tipdoc.empresa = cob_penpag.empresa
                              and cob_tipdoc.origen = cob_penpag.tipo_documento),cob_penpag.tipo_documento)
   where empresa in ('12','16','65')
endexec.

exec sql.
    delete from cob_penpag
    where fecha_carga = to_date(:p_fecpro,'yyyymmdd')
    and empresa in ('12','16','65')
    and tipo_documento = 'OTROS'
endexec.

exec sql.
  set connection default
endexec.
