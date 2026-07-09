*&---------------------------------------------------------------------*
*& Report  ZFITR014
*&
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*

REPORT  zfitr014.

TABLES: reguh.

DATA : BEGIN OF datos  OCCURS 0,
          bukrs          LIKE  zagencia-bukrs,
          identif_pago LIKE reguh-identif_pago,
          lineas LIKE sy-tabix,
END OF datos.
SELECTION-SCREEN BEGIN OF BLOCK marco1 WITH FRAME TITLE text-001.

PARAMETER : bukrs    LIKE bkpf-bukrs     VALUE CHECK  OBLIGATORY .


SELECT-OPTIONS : v_fecha  FOR reguh-valut OBLIGATORY.

SELECTION-SCREEN END OF BLOCK marco1.



START-OF-SELECTION.
  DATA lineas LIKE sy-tabix.
  DATA xidentif_pago LIKE reguh-identif_pago.
  REFRESH datos.
  SELECT   identif_pago COUNT( * ) INTO (xidentif_pago, lineas ) FROM reguh
                                 WHERE valut IN v_fecha
                                 AND   zbukr =  bukrs
                                 AND identif_pago <>  ''
                                  GROUP BY identif_pago.


    IF lineas > 1.
      datos-bukrs = bukrs.
      datos-identif_pago = xidentif_pago.
      datos-lineas = lineas .
      APPEND datos.
    ENDIF.



  ENDSELECT.

  LOOP AT datos.

      write: / datos-bukrs, datos-identif_pago, datos-lineas.

* BEGIN. 07-07-2026 - ATC - ATC-03
* OLD CODE
*      select  * from reguh where identif_pago = datos-identif_pago
*                           and zbukr =  bukrs.
*
* NEW CODE
      SELECT *
 from reguh where identif_pago = datos-identif_pago
                           and zbukr =  bukrs ORDER BY PRIMARY KEY.

* END. 07-07-2026 - ATC - ATC-03
              write: / reguh-zbukr, reguh-LAUFD, reguh-LAUFI, reguh-LIFNR, reguh-NAME1, reguh-RWBTR currency 'CLP'.

      endselect.

  endloop.

END-OF-SELECTION.
