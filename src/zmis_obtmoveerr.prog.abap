*&---------------------------------------------------------------------*
*& Report: < ZEY_GDS_CORRECTION > *
*& Author: < EY_DES04 > *
*& Description: < ReSQ Correction > *
*& Date: <24-12-2019> *
*& Transport Number: < ECDK917080 > *
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Report  ZMIS_OBTMOVEERR
*&
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*

REPORT  ZMIS_OBTMOVEERR.

tables: bkpf,bseg,lfa1.

data:   ibukrs type bkpf-bukrs,  "Sociedad
        ibelnr type bkpf-belnr,  "Nro.Doc.Contable
        ibudat type bkpf-budat,  "Fecha Contabilizacion
        ixblnr type bkpf-xblnr,  "Referencia Documento cuando aplica
        ibldat type bkpf-bldat,  "Fecha del documento
        iblart type bkpf-blart,  "Tipo Documento Sap
        ihkont type bseg-hkont,  "Cuenta
        iprctr type bseg-prctr,  "Centro Costo Beneficio
        isgtxt type bseg-sgtxt,  "Glosa
        izzprestac type bseg-zzprestac,    "Prestacion
        izzunid_pro type bseg-zzunid_pro,  "Codigo de Unidad o Producto
        izzdesc_est type bseg-zzdesc_est,  "Codigo de Descuento y Codigos de Estamento
        izzmot_emis type bseg-zzmot_emis,  "Motivos de emision
        izzrut_terc type bseg-zzrut_terc,  "Id Deudor
        ilifnr type bseg-lifnr,            "Id Deudor
        izzrut_prov type lfa1-stcd1,       "Rut Deudor
        izznom_prov type lfa1-name1,       "Nombre Deudor
        izz_agencia type bseg-zz_agencia,  "Codigos de Agencia
        ishkzg type bseg-shkzg,            "D/H
        idmbtr type bseg-dmbtr,            "Importe en moneda local
        ihwbas type bset-hwbas,            "Neto
        ihwste type bset-hwste,            "Iva
        iorigen type bkpf-xref2_hd,       "Origen contable
        ildgrp type bkpf-ldgrp.            "Ledger
data : it_bkpf type standard table of bkpf with header line,
       it_lfa1 type standard table of lfa1 with header line.

selection-screen begin of block b1 with frame.
  select-options s_bukrs for bkpf-bukrs obligatory.
selection-screen end of block b1.

selection-screen begin of block b2 with frame.
  Parameter: p_fecini type datum,
             p_fecfin type datum,
             p_gjahr type bkpf-gjahr default 2010.
selection-screen end of block b2.

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
      execute procedure csc_sap_mis.sp_elimina_sap_eerr(
                        in :s_bukrs-low,
                        in :p_fecini,
                        in :p_fecfin)
    endexec.
  catch cx_sy_native_sql_error.
    message `Error borrar tabla sap_eerr` type 'I'.
  endtry.

endloop.

exec sql.
  commit
endexec.

* BEGIN. 07-07-2026 - ATC - ATC-03
* OLD CODE
*select *
*  from bkpf
*  into corresponding fields of table it_bkpf
*  where bukrs in s_bukrs
*  and budat ge p_fecini
*  and budat lt p_fecfin
*  and gjahr eq p_gjahr.
*
* NEW CODE
SELECT *

  from bkpf
  into corresponding fields of table it_bkpf
  where bukrs in s_bukrs
  and budat ge p_fecini
  and budat lt p_fecfin
  and gjahr eq p_gjahr ORDER BY PRIMARY KEY.

* END. 07-07-2026 - ATC - ATC-03

loop at it_bkpf.
    clear: ihkont,iprctr,isgtxt,ilifnr,izzprestac,izzunid_pro,izzdesc_est,izzmot_emis,izzrut_terc,izz_agencia,ishkzg,idmbtr.
select hkont "Cuenta
prctr "Centro Costo Beneficio
sgtxt "Glosa
lifnr "Id Deudor
zzprestac "Prestacion
zzunid_pro "Codigo de Unidad o Producto
zzdesc_est "Codigo de Descuento y Codigos de Estamento
zzmot_emis "Motivos de emision
zzrut_terc "Id Deudor
zz_agencia "Codigos de Agencia
shkzg "D/H
dmbtr "Importe en moneda local
into (ihkont,iprctr,isgtxt,ilifnr,izzprestac,izzunid_pro,izzdesc_est,izzmot_emis,izzrut_terc,izz_agencia,ishkzg,idmbtr)
from bseg
where bukrs eq it_bkpf-bukrs
and belnr eq it_bkpf-belnr
and gjahr eq p_gjahr
*Begin of change: ReSQ Correction for Addition ORDER BY PRIMARY KEY 24/12/2019 EY_DES04 ECDK917080 *
*and ( ( hkont ge '4100000000' and hkont le '5511110000' ) OR ( hkont ge '9000000000' and hkont le '9000001000' ) ).
AND ( ( HKONT GE '4100000000' AND HKONT LE '5511110000' ) OR ( HKONT GE '9000000000' AND HKONT LE '9000001000' ) ) ORDER BY PRIMARY KEY .
*End of change: ReSQ Correction for Addition ORDER BY PRIMARY KEY 24/12/2019 EY_DES04 ECDK917080 *

      clear: izznom_prov,izzrut_prov.
      clear: it_lfa1[].

      refresh: it_lfa1.

      if ilifnr ne '' and izzrut_terc eq ''.
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*        select single *
*          into corresponding fields of it_lfa1
*          from lfa1
*          where lifnr eq ilifnr.
*
* NEW CODE
        SELECT *
        UP TO 1 ROWS 
          into corresponding fields of it_lfa1
          from lfa1
          where lifnr eq ilifnr ORDER BY PRIMARY KEY.

        ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01

        if sy-subrc = 0.
          izzrut_terc = ilifnr.
          izznom_prov = it_lfa1-name1.
          izzrut_prov = it_lfa1-stcd1.
        else.
          izzrut_terc = ilifnr.
          izznom_prov = ''.
          izzrut_prov = ''.
        endif.

      elseif ilifnr eq '' and izzrut_terc ne ''.
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*        select single *
*          into corresponding fields of it_lfa1
*          from lfa1
*          where lifnr eq izzrut_terc.
*
* NEW CODE
        SELECT *
        UP TO 1 ROWS 
          into corresponding fields of it_lfa1
          from lfa1
          where lifnr eq izzrut_terc ORDER BY PRIMARY KEY.

        ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01

        if sy-subrc = 0.
          izznom_prov = it_lfa1-name1.
          izzrut_prov = it_lfa1-stcd1.
        else.
          izzrut_terc = izzrut_terc.
          izznom_prov = ''.
          izzrut_prov = ''.
        endif.

      elseif ilifnr ne '' and izzrut_terc ne ''.
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*        select single *
*          into corresponding fields of it_lfa1
*          from lfa1
*          where lifnr eq izzrut_terc.
*
* NEW CODE
        SELECT *
        UP TO 1 ROWS 
          into corresponding fields of it_lfa1
          from lfa1
          where lifnr eq izzrut_terc ORDER BY PRIMARY KEY.

        ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01

        if sy-subrc = 0.
          izznom_prov = it_lfa1-name1.
          izzrut_prov = it_lfa1-stcd1.
        else.
          izzrut_terc = izzrut_terc.
          izznom_prov = ''.
          izzrut_prov = ''.
        endif.

      else.
        izznom_prov = ''.
        izzrut_prov = ''.
      endif.

      ihwbas = 0.            "Neto
      ihwste = 0.            "Iva

      try.
        exec sql.
          execute procedure csc_sap_mis.sp_insert_sap_eerr(
                            in :it_bkpf-bukrs,
                            in :it_bkpf-belnr,
                            in :it_bkpf-budat,
                            in :it_bkpf-xblnr,
                            in :it_bkpf-bldat,
                            in :it_bkpf-blart,
                            in :ihkont,
                            in :iprctr,
                            in :isgtxt,
                            in :izzprestac,
                            in :izzunid_pro,
                            in :izzdesc_est,
                            in :izzmot_emis,
                            in :izzrut_terc,
                            in :izzrut_prov,
                            in :izznom_prov,
                            in :izz_agencia,
                            in :ishkzg,
                            in :idmbtr,
                            in :ihwbas,
                            in :ihwste,
                            in :it_bkpf-xref2_hd,
                            in :it_bkpf-ldgrp)
        endexec.
      catch cx_sy_native_sql_error.
        message `Error insert tabla sap_eerr` type 'I'.
      endtry.

    endselect.

    exec sql.
        set connection default
    endexec.

    exec sql.
        set connection 'con'
    endexec.

endloop.

exec sql.
  set connection default
endexec.
