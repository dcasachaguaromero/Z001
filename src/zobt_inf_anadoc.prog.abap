*&---------------------------------------------------------------------*
*& Report: < ZEY_GDS_CORRECTION > *
*& Author: < EY_DES04 > *
*& Description: < ReSQ Correction > *
*& Date: <24-12-2019> *
*& Transport Number: < ECDK917080 > *
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Report  ZOBT_INF_ANADOC
*&
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*

REPORT  ZOBT_INF_ANADOC.

tables: bkpf,bseg,lfa1.

data:   ibukrs type bkpf-bukrs,  "Sociedad
        ibelnr type bkpf-belnr,  "Nro.Doc.Contable
        ibudat type bkpf-budat,  "Fecha Contabilizacion
        ixblnr type bkpf-xblnr,  "Referencia Documento cuando aplica
        izuonr type bseg-zuonr,  "Asignacion
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
        izzrut_prov type lfa1-stcd1,       "Rut Deudor
        izznom_prov type lfa1-name1,       "Nombre Deudor
        izz_agencia type bseg-zz_agencia,  "Codigos de Agencia
        ishkzg type bseg-shkzg,            "D/H
        idmbtr type bseg-dmbtr,            "Importe en moneda local
        ivalor type bseg-dmbtr,            "Importe * 100
        iorigen type bkpf-xref2_hd,        "Origen contable
        irldnr type bkpf-rldnr,            "Ledger
        iusnam type bkpf-usnam.            "Usuario
data : it_bkpf type standard table of bkpf with header line,
       it_lfa1 type standard table of lfa1 with header line.

selection-screen begin of block b1 with frame.
  select-options s_bukrs for bkpf-bukrs obligatory.
  select-options s_hkont for bseg-hkont obligatory.
selection-screen end of block b1.

selection-screen begin of block b2 with frame.
  Parameter: p_fecini type datum,
             p_fecfin type datum,
             p_gjahr type bkpf-gjahr default 2010.
selection-screen end of block b2.

exec sql.
  connect to 'GOLDEN' as 'con'
endexec.

exec sql.
  set connection 'con'
endexec.

"Elimino registros por sociedad
loop at s_bukrs.
  loop at s_hkont.
    if s_hkont-option eq 'EQ'. "Seleccion individual de cuentas
      try.
        exec sql.
          execute procedure csc_sap.sp_elimina_sap_anadoc_cuenta(
                            in :s_bukrs-low,
                            in :s_hkont-low,
                            in :p_fecini,
                            in :p_fecfin)
        endexec.
      catch cx_sy_native_sql_error.
        message `Error borrar tabla sap_anadoc` type 'I'.
      endtry.
    elseif s_hkont-option eq 'BT'. "Seleccion de rango de cuentas
      try.
        exec sql.
          execute procedure csc_sap.sp_elimina_sap_anadoc_cuentas(
                            in :s_bukrs-low,
                            in :s_hkont-low,
                            in :s_hkont-high,
                            in :p_fecini,
                            in :p_fecfin)
        endexec.
      catch cx_sy_native_sql_error.
        message `Error borrar tabla sap_anadoc` type 'I'.
      endtry.
    endif.
  endloop.
endloop.

exec sql.
  commit
endexec.

select *
  from bkpf
  into corresponding fields of table it_bkpf
  where bukrs in s_bukrs
  and budat ge p_fecini
  and budat lt p_fecfin
  and gjahr eq p_gjahr.

loop at it_bkpf.
    clear: izuonr,ihkont,iprctr,isgtxt,izzprestac,izzunid_pro,izzdesc_est,izzmot_emis,izzrut_terc,izz_agencia,ishkzg,idmbtr.
select zuonr "Asignacion
hkont "Cuenta
prctr "Centro Costo Beneficio
sgtxt "Glosa
zzprestac "Prestacion
zzunid_pro "Codigo de Unidad o Producto
zzdesc_est "Codigo de Descuento y Codigos de Estamento
zzmot_emis "Motivos de emision
zzrut_terc "Id Deudor
zz_agencia "Codigos de Agencia
shkzg "D/H
dmbtr "Importe en moneda local
into (izuonr,ihkont,iprctr,isgtxt,izzprestac,izzunid_pro,izzdesc_est,izzmot_emis,izzrut_terc,izz_agencia,ishkzg,idmbtr)
from bseg
where bukrs eq it_bkpf-bukrs
and belnr eq it_bkpf-belnr
and hkont in s_hkont
*Begin of change: ReSQ Correction for Addition ORDER BY PRIMARY KEY 24/12/2019 EY_DES04 ECDK917080 *
*and gjahr eq p_gjahr.
AND GJAHR EQ P_GJAHR ORDER BY PRIMARY KEY .
*End of change: ReSQ Correction for Addition ORDER BY PRIMARY KEY 24/12/2019 EY_DES04 ECDK917080 *

      clear: izznom_prov,izzrut_prov.

      if izzrut_terc ne ''.
        select single *
          into corresponding fields of it_lfa1
          from lfa1
          where lifnr eq izzrut_terc.

        izznom_prov = it_lfa1-name1.
        izzrut_prov = it_lfa1-stcd1.
      else.
        izznom_prov = ''.
        izzrut_prov = ''.
      endif.

      ivalor = idmbtr * 100.

      try.
        exec sql.
          execute procedure csc_sap.sp_insert_sap_anadoc(
                            in :it_bkpf-bukrs,
                            in :it_bkpf-belnr,
                            in :it_bkpf-budat,
                            in :it_bkpf-xblnr,
                            in :izuonr,
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
                            in :ivalor,
                            in :it_bkpf-xref2_hd,
                            in :it_bkpf-rldnr,
                            in :it_bkpf-usnam)
        endexec.
      catch cx_sy_native_sql_error.
        message `Error insert tabla sap_anadoc` type 'I'.
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
