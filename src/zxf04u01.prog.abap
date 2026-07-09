*&---------------------------------------------------------------------*
*&  Include           ZXF04U01
*&---------------------------------------------------------------------*
data a_kna1 like kna1.

*Se agrego para no controlar contratos.
If I_KNA1-KTOKD NE 'Z002' and I_KNA1-KTOKD NE 'ZCPD'.
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*  select single *
*  from kna1 into a_kna1
*  where stcd1 = i_kna1-stcd1  and
*        kunnr <> i_kna1-kunnr.
*
* NEW CODE
  SELECT *
  UP TO 1 ROWS 
  from kna1 into a_kna1
  where stcd1 = i_kna1-stcd1  and
        kunnr <> i_kna1-kunnr ORDER BY PRIMARY KEY.

  ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01


  if sy-subrc = 0.
    MESSAGE 'Rut ya ingresado' TYPE 'E'.
  endif.

endif.
