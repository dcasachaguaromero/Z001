*&---------------------------------------------------------------------*
*& Report  ZMIS_OBTENERCUENTAS
*&
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*

REPORT  ZMIS_OBTENERCUENTAS.

types: begin of est_salida,
        bukrs type skb1-bukrs,
        saknr type skb1-saknr,
        txt20 type skat-txt20,
        txt50 type skat-txt50,
       end of est_salida.

data: it_salida type standard table of est_salida with header line,
      it_skb1 type standard table of skb1 with header line,
      it_skat type standard table of skat with header line,
      w_archivo(100) type c.

data: r_saknr type range of skat-saknr with header line,
      r_bukrs type range of bkpf-bukrs with header line,
      wa_saknr like line of r_saknr.

selection-screen begin of block b1 with frame.
  select-options s_bukrs for it_skb1-bukrs obligatory.
selection-screen end of block b1.

* BEGIN. 07-07-2026 - ATC - ATC-03
* OLD CODE
*select *
*  from skb1 into table it_skb1
*  where bukrs in s_bukrs.
*
* NEW CODE
SELECT *

  from skb1 into table it_skb1
  where bukrs in s_bukrs ORDER BY PRIMARY KEY.

* END. 07-07-2026 - ATC - ATC-03

*Obtener  los codigos de cuentas y agrego a rango
loop at it_skb1.
  r_saknr-sign = 'I'.
  r_saknr-option = 'EQ'.
  r_saknr-low = it_skb1-saknr.
  append r_saknr.
endloop.

sort r_saknr.
delete ADJACENT DUPLICATES FROM r_saknr.

* Solo se sacan las descripciones de las cuentas que existen en la tabla interna.
* BEGIN. 07-07-2026 - ATC - ATC-03
* OLD CODE
*select *
*  from skat into table it_skat
*  where saknr in r_saknr
*  and ktopl eq 'B100'.
*
* NEW CODE
SELECT *

  from skat into table it_skat
  where saknr in r_saknr
  and ktopl eq 'B100' ORDER BY PRIMARY KEY.

* END. 07-07-2026 - ATC - ATC-03

* Llena la tabla de salida
loop at it_skb1.
  move-corresponding it_skb1 to it_salida.
  read table it_skat with key saknr = it_skb1-saknr.
  if sy-subrc eq 0.
    move-corresponding it_skat to it_salida.
  endif.
  collect it_salida.
  clear it_salida.
 endloop.

 exec sql.
  connect to 'MISGES' as 'con'
endexec.

exec sql.
  set connection 'con'
endexec.

loop at s_bukrs.
  try.
    exec sql.
      delete from sap_cuentas
      where empresa = :s_bukrs-low
    endexec.
  catch cx_sy_native_sql_error.
    message `Error borrar tabla sap_cuentas` type 'I'.
  endtry.

endloop.

loop at it_salida.
  exec sql.
    insert into sap_cuentas (empresa,cuenta,desc20,desc50)
    values (:it_salida-bukrs,:it_salida-saknr,:it_salida-txt20,:it_salida-txt50)
  endexec.
endloop.

exec sql.
  set connection default
endexec.
