*&---------------------------------------------------------------------*
*& Report  ZMIS_OBTENERCCOSTO
*&
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*

REPORT  ZMIS_OBTENERCCOSTO.

types: begin of est_salida,
        kostl type cskt-kostl,
        ktext type cskt-ktext,
        ltext type cskt-ltext,
       end of est_salida.

data: it_salida type standard table of est_salida with header line,
      w_archivo(100) type c.

* BEGIN. 07-07-2026 - ATC - ATC-03
* OLD CODE
*select *
*  from cskt into CORRESPONDING FIELDS OF TABLE it_salida
*  where kokrs eq 'BMSA'.
*
* NEW CODE
SELECT *

  from cskt into CORRESPONDING FIELDS OF TABLE it_salida
  where kokrs eq 'BMSA' ORDER BY PRIMARY KEY.

* END. 07-07-2026 - ATC - ATC-03

exec sql.
  connect to 'MISGES' as 'con'
endexec.

exec sql.
  set connection 'con'
endexec.

exec sql.
  delete from sap_ccosto
endexec.

loop at it_salida.
  exec sql.
    insert into sap_ccosto (codigo,desc20,desc40)
    values (:it_salida-kostl,:it_salida-ktext,:it_salida-ltext)
  endexec.
endloop.

exec sql.
  set connection default
endexec.
