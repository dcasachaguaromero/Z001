*&---------------------------------------------------------------------*
*& Report  ZMIS_OBTENERSALDOS
*&
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*

REPORT  ZMIS_OBTENERSALDOS.

tables : faglflext.

types: begin of est_salida,
        bukrs type bkpf-bukrs,  "Sociedad
        belnr type bkpf-belnr,  "Nro.Doc.Contable
        budat type bkpf-budat,  "Fecha Contabilizacion
        xblnr type bkpf-xblnr,  "Referencia Documento cuando aplica
        bldat type bkpf-bldat,  "Fecha del documento
        blart type bkpf-blart,  "Tipo Documento Sap
        hkont type bseg-hkont,  "Cuenta
        prctr type bseg-prctr,  "Centro Costo Beneficio
        sgtxt type bseg-sgtxt,  "Glosa
        zzprestac type bseg-zzprestac,    "Prestacion
        zzunid_pro type bseg-zzunid_pro,  "Codigo de Unidad o Producto
        zzdesc_est type bseg-zzdesc_est,  "Codigo de Descuento y Codigos de Estamento
        zzmot_emis type bseg-zzmot_emis,  "Motivos de emision
        zzrut_terc type lfa1-lifnr,       "Id Deudor
        zzrut_prov type lfa1-stcd1,       "Rut Deudor
        zznom_prov type lfa1-name1,       "Nombre Deudor
        zz_agencia type bseg-zz_agencia,  "Codigos de Agencia
        shkzg type bseg-shkzg,            "D/H
        dmbtr type bseg-dmbtr,            "Importe en moneda local
        hwbas type bset-hwbas,            "Neto
        hwste type bset-hwste,            "Iva
        origen  type bkpf-xref2_hd,       "Origen contable
       end of est_salida.

types: begin of est_saldo,
        rbukrs type faglflext-rbukrs,
        racct type faglflext-racct,
        saldo type faglflext-hslvt,
       end of est_saldo.

data: it_salida type standard table of est_salida with header line,
      it_saldo type standard table of est_saldo with header line,
      it_fagl like faglflext,
      feccom(10) type c,
      wa type est_salida.

selection-screen begin of block b1 with frame.
  select-options s_bukrs for faglflext-rbukrs obligatory.
  parameter p_ryear type faglflext-ryear default '2010'.
  parameter p_rldnr type faglflext-rldnr default '0L'.
selection-screen end of block b1.

concatenate p_ryear '0101' into feccom.

"Busca las cuentas de balance que tengan saldos de arrastres
select rbukrs racct sum( hslvt ) as saldo
  from faglflext
  into corresponding fields of table it_saldo
  where rbukrs in s_bukrs
  and ryear eq p_ryear
  and rldnr eq p_rldnr
  and racct ge '1000000000'
  and racct le '2999999999'
  group by rbukrs racct.

loop at it_saldo.
  if it_saldo-saldo ne 0.
    wa-bukrs = it_saldo-rbukrs.  "Sociedad
    wa-belnr = '9999999999'.    "Nro.Comprobante Ficticio
    wa-budat = feccom.          "Fecha Contabilizacion Ficticio
    wa-xblnr = ''.              "Referencia
    wa-bldat = ''.              "Fecha Documento.
    wa-blart = ''.              "Tipo Doc.
    wa-hkont = it_saldo-racct.   "Cuenta
    wa-prctr = ''.              "Centro Costo beneficio
    wa-sgtxt = 'Comprobante Ficticio - Saldo Arrastre'. "Glosa.
    wa-zzprestac = ''.          "Prestacion.
    wa-zzunid_pro = ''.         "Codigo Unidad o Producto
    wa-zzdesc_est = ''.         "Codigo de Descuento y Codigos de Estamento
    wa-zzmot_emis = ''.         "Motivo de Emision
    wa-zzrut_terc = ''.         "Id.Deudor
    wa-zzrut_prov = ''.         "Rut Deudor
    wa-zznom_prov = ''.         "Nombre Deudor
    wa-zz_agencia = ''.         "Codigo Agencia
    wa-shkzg = 'S'.             "D/H
    wa-dmbtr = it_saldo-saldo.  "Importe en moneda local
    wa-hwbas = ''.              "Valor Neto
    wa-hwste = ''.              "Valor Iva
    wa-origen = 'FICTICIO'.     "Origen

    append wa to it_salida.
  endif.
endloop.

exec sql.
  connect to 'MISGES' as 'con'
endexec.

exec sql.
  set connection 'con'
endexec.

"Elimino registros por sociedad
loop at s_bukrs.
  try.
    exec sql.
      delete from sap_balance
      where sociedad = :s_bukrs-low
      and comprobante = '9999999999'
      and fecha = :feccom
    endexec.
  catch cx_sy_native_sql_error.
    message `Error borrar tabla sap_balance` type 'I'.
  endtry.

endloop.

loop at it_salida.
  exec sql.
    insert into sap_balance (sociedad,comprobante,fecha,referencia,fecha_doc,tipo_doc,cuenta,ccosto,glosa,
                          zzprestac,zzunid_pro,zzdesc_est,zzmot_emis,zzrut_terc,zzrut_prov,zznom_prov,zz_agencia,sentido,valor,valor_neto,valor_impto,origen)
    values (:it_salida-bukrs,:it_salida-belnr,:it_salida-budat,:it_salida-xblnr,:it_salida-bldat,:it_salida-blart,:it_salida-hkont,:it_salida-prctr,:it_salida-sgtxt,
            :it_salida-zzprestac,:it_salida-zzunid_pro,:it_salida-zzdesc_est,:it_salida-zzmot_emis,:it_salida-zzrut_terc,:it_salida-zzrut_prov,:it_salida-zznom_prov,
            :it_salida-zz_agencia,:it_salida-shkzg,:it_salida-dmbtr,:it_salida-hwbas,:it_salida-hwste,:it_salida-origen)
  endexec.

endloop.

exec sql.
  set connection default
endexec.
