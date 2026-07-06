*&---------------------------------------------------------------------*
*&  Include           ZXF05U01
*&---------------------------------------------------------------------*
data a_lfa1 like lfa1.

* V1 RVY INI 17.10.2022
IF SY-TCODE NE 'FK05' AND SY-TCODE NE 'XK02'.
   select single *
     from lfa1 into a_lfa1
     where stcd1 = i_lfa1-stcd1 and
           lifnr <> i_lfa1-lifnr.

   if sy-subrc = 0.
      MESSAGE 'Rut ya ingresado' TYPE 'E'.
   endif.
endif.
