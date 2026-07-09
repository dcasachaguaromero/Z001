*&---------------------------------------------------------------------*
*& Report: < ZEY_GDS_CORRECTION > *
*& Author: < EY_DES04 > *
*& Description: < ReSQ Correction > *
*& Date: <24-12-2019> *
*& Transport Number: < ECDK917080 > *
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Report  ZMIS_OBTENERMOVTO_BALANCE
*&
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*

REPORT  ZMIS_OBTENERMOVTO_BALANCE.

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

data: it_salida type standard table of est_salida with header line,
      it_bkpf type standard table of bkpf with header line,
      it_bseg type standard table of bseg with header line,
      it_paso type standard table of bseg with header line,
      it_bset type standard table of bset with header line,
      it_lfa1 type standard table of lfa1 with header line,
      total_neto type bset-hwbas,
      total_impto type bset-hwste,
      mensaje(100) type c,
      fecha_inicio(10) type c,
      fecha_fin(10) type c,
      f_inicio type bkpf-budat,
      f_fin type bkpf-budat,
      wa type est_salida,
      w_iter type i.

data: r_bukrs type range of bkpf-bukrs with header line,
      r_hkont type range of bseg-hkont with header line,
      r_belnr type range of bseg-belnr with header line.

selection-screen begin of block b1 with frame.
  select-options s_bukrs for it_bkpf-bukrs obligatory.
selection-screen end of block b1.

selection-screen begin of block b2 with frame.
  Parameter: p_fecini type datum,
             p_fecfin type datum.
selection-screen end of block b2.

* BEGIN. 07-07-2026 - ATC - ATC-03
* OLD CODE
*select *
*  from bkpf
*  into corresponding fields of table it_bkpf
*  where bukrs in s_bukrs
*  and budat ge p_fecini
*  and budat lt p_fecfin
*  and gjahr eq '2010'.
*
* NEW CODE
SELECT *

  from bkpf
  into corresponding fields of table it_bkpf
  where bukrs in s_bukrs
  and budat ge p_fecini
  and budat lt p_fecfin
  and gjahr eq '2010' ORDER BY PRIMARY KEY.

* END. 07-07-2026 - ATC - ATC-03

sort it_bkpf.
delete adjacent duplicates from it_bkpf.

"Filtro cuentas de EERR
r_hkont-sign = 'I'.
r_hkont-option = 'BT'.
r_hkont-low = '1000000000'.
r_hkont-high = '2999999999'.
append r_hkont.

loop at it_bkpf.
select *
from bseg
into table it_paso
where bukrs eq it_bkpf-bukrs
and belnr eq it_bkpf-belnr
and hkont in r_hkont
*Begin of change: ReSQ Correction for Addition ORDER BY PRIMARY KEY 24/12/2019 EY_DES04 ECDK917080 *
*and gjahr eq '2010'.
AND GJAHR EQ '2010' ORDER BY PRIMARY KEY.
*End of change: ReSQ Correction for Addition ORDER BY PRIMARY KEY 24/12/2019 EY_DES04 ECDK917080 *

    if sy-subrc eq 0.
      loop at it_paso.
        append it_paso to it_bseg.
      endloop.
    endif.
endloop.

loop at it_bkpf.
  loop at it_bseg where bukrs = it_bkpf-bukrs and belnr = it_bkpf-belnr.

      wa-bukrs = it_bkpf-bukrs.
      wa-belnr = it_bkpf-belnr.
      wa-budat = it_bkpf-budat.
      wa-xblnr = it_bkpf-xblnr.
      wa-bldat = it_bkpf-bldat.
      wa-blart = it_bkpf-blart.
      wa-hkont = it_bseg-hkont.
      wa-prctr = it_bseg-prctr.
      wa-sgtxt = it_bseg-sgtxt.
      wa-zzprestac = it_bseg-zzprestac.
      wa-zzunid_pro = it_bseg-zzunid_pro.
      wa-zzdesc_est = it_bseg-zzdesc_est.
      wa-zzmot_emis = it_bseg-zzmot_emis.
      wa-zzrut_terc = it_bseg-lifnr.

      if it_bseg-lifnr ne ''.
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*        select single *
*          into corresponding fields of it_lfa1
*          from lfa1
*          where lifnr eq it_bseg-lifnr.
*
* NEW CODE
        SELECT *
        UP TO 1 ROWS 
          into corresponding fields of it_lfa1
          from lfa1
          where lifnr eq it_bseg-lifnr ORDER BY PRIMARY KEY.

        ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01

        wa-zznom_prov = it_lfa1-name1.
        wa-zzrut_prov = it_lfa1-stcd1.
      else.
        wa-zznom_prov = ''.
        wa-zzrut_prov = ''.
      endif.

      wa-zz_agencia = it_bseg-zz_agencia.
      wa-shkzg = it_bseg-shkzg.
      wa-dmbtr = it_bseg-dmbtr.
      wa-hwbas = 0.
      wa-hwste = 0.
      wa-origen = it_bkpf-xref2_hd.

      append wa to it_salida.

    endloop.
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
      where to_date(fecha,'yyyymmdd') >= to_date(:p_fecini,'yyyymmdd')
      and   to_date(fecha,'yyyymmdd') <  to_date(:p_fecfin,'yyyymmdd')
      and   sociedad = :s_bukrs-low
      and   comprobante <> '9999999999'
    endexec.
  catch cx_sy_native_sql_error.
    message `Error borrar tabla sap_balance` type 'I'.
  endtry.

endloop.

try.
    exec sql.
      commit
    endexec.
    exec sql.
      set connection default
    endexec.
    exec sql.
        set connection 'con'
    endexec.

    w_iter = 0.
    loop at it_salida.
      add 1 to w_iter.
      if w_iter > 1000.
        w_iter = 0.
        exec sql.
            commit
        endexec.
        exec sql.
          set connection default
        endexec.
        exec sql.
            set connection 'con'
        endexec.
      endif.

      exec sql.
        insert into sap_balance (sociedad,comprobante,fecha,referencia,fecha_doc,tipo_doc,cuenta,ccosto,glosa,
                              zzprestac,zzunid_pro,zzdesc_est,zzmot_emis,zzrut_terc,zzrut_prov,zznom_prov,zz_agencia,sentido,valor,valor_neto,valor_impto,origen)
        values (:it_salida-bukrs,:it_salida-belnr,:it_salida-budat,:it_salida-xblnr,:it_salida-bldat,:it_salida-blart,:it_salida-hkont,:it_salida-prctr,:it_salida-sgtxt,
                :it_salida-zzprestac,:it_salida-zzunid_pro,:it_salida-zzdesc_est,:it_salida-zzmot_emis,:it_salida-zzrut_terc,:it_salida-zzrut_prov,:it_salida-zznom_prov,
                :it_salida-zz_agencia,:it_salida-shkzg,:it_salida-dmbtr,:it_salida-hwbas,:it_salida-hwste,:it_salida-origen)
      endexec.
    endloop.
catch cx_sy_native_sql_error.
    message `Error insert tabla sap_balance` type 'I'.
endtry.


exec sql.
  set connection default
endexec.
