*&---------------------------------------------------------------------*
*& Report  ZOBT_INF_ACRE
*&
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*

REPORT  ZOBT_INF_ACRE.

types: begin of est_salida,
  bukrs type lfb1-bukrs,  "Sociedad
  lifnr type lfa1-lifnr,  "Id de Acreedor
  stcd1 type lfa1-stcd1,  "Rut
  name1 type lfa1-name1,  "Nombre 1
  name2 type lfa1-name2,  "Nombre 2
  ort02 type lfa1-ort02,  "Distrito
  pstlz type lfa1-pstlz,  "Codigo Postal
  banks type lfbk-banks,  "Pais
  bankl type lfbk-bankl,  "Clave banco
  bankn type lfbk-bankn,  "Cuenta Bancaria
  koinh type lfbk-koinh,  "Titular
  regio type lfa1-regio,  "Region
end of est_salida.

data: it_salida type standard table of est_salida with header line,
      it_lfb1 type standard table of lfb1 with header line,
      it_lfbk type standard table of lfbk with header line,
      wa_lfa1 type lfa1,
      wa_salida type est_salida.

selection-screen begin of block b1 with frame.
  select-options s_bukrs for it_lfb1-bukrs obligatory.
  select-options s_lifnr for it_lfb1-lifnr obligatory.
selection-screen end of block b1.

select *
  from lfb1
  into corresponding fields of table it_lfb1
  where bukrs in s_bukrs
  and lifnr in s_lifnr.

loop at it_lfb1.
  "Datos del Acreedor
  select single *
    from lfa1
    into corresponding fields of wa_lfa1
    where lifnr eq it_lfb1-lifnr.

  "Puede tener mas de una cuenta corriente
  select *
    from lfbk
    into corresponding fields of table it_lfbk
    where lifnr eq it_lfb1-lifnr.

  if ( sy-subrc = 0 ).
    loop at it_lfbk.
      wa_salida-bukrs = it_lfb1-bukrs.  "Empresa
      wa_salida-lifnr = it_lfb1-lifnr.  "Id.Acreedor
      wa_salida-stcd1 = wa_lfa1-stcd1.  "Rut
      wa_salida-name1 = wa_lfa1-name1.  "Nombre 1
      wa_salida-name2 = wa_lfa1-name2.  "Nombre 2
      wa_salida-ort02 = wa_lfa1-ort02.  "Distrito
      wa_salida-pstlz = wa_lfa1-pstlz.  "Codigo Postal
      wa_salida-banks = it_lfbk-banks.  "Pais
      wa_salida-bankl = it_lfbk-bankl.  "Clave banco
      wa_salida-bankn = it_lfbk-bankn.  "Cuenta Bancaria
      wa_salida-koinh = it_lfbk-koinh.  "Titular
      wa_salida-regio = wa_lfa1-regio.  "Region

      append wa_salida to it_salida.
    endloop.
  else.
      wa_salida-bukrs = it_lfb1-bukrs.  "Empresa
      wa_salida-lifnr = it_lfb1-lifnr.  "Id.Acreedor
      wa_salida-stcd1 = wa_lfa1-stcd1.  "Rut
      wa_salida-name1 = wa_lfa1-name1.  "Nombre 1
      wa_salida-name2 = wa_lfa1-name2.  "Nombre 2
      wa_salida-ort02 = wa_lfa1-ort02.  "Distrito
      wa_salida-pstlz = wa_lfa1-pstlz.  "Codigo Postal
      wa_salida-banks = ''.             "Pais
      wa_salida-bankl = ''.             "Clave banco
      wa_salida-bankn = ''.             "Cuenta Bancaria
      wa_salida-koinh = ''.             "Titular
      wa_salida-regio = wa_lfa1-regio.  "Region

      append wa_salida to it_salida.
  endif.
endloop.

exec sql.
  connect to 'MISGES' as 'con'
endexec.

exec sql.
  set connection 'con'
endexec.

loop at it_salida.
  exec sql.
    insert into mis_ges.sap_acreedores (sociedad,id,rut,nombre1,nombre2,distrito,cod_postal,pais,clave_banco,cta_bancaria,titular,region)
    values (:it_salida-bukrs,:it_salida-lifnr,:it_salida-stcd1,:it_salida-name1,:it_salida-name2,:it_salida-ort02,:it_salida-pstlz,:it_salida-banks,:it_salida-bankl,:it_salida-bankn,:it_salida-koinh,:it_salida-regio)

  endexec.
endloop.

exec sql.
  set connection default
endexec.
