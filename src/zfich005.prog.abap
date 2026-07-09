REPORT zfich005.


TABLES: zfich001,
        payr,
        zfich002,
        bkpf.



DATA :   stcd1       LIKE lfa1-stcd1,
         status      like zfich001-TRASPASADO,
         observacion like zfich001-OBSERVACION.


DATA : BEGIN OF tmotivo  OCCURS 1.
        INCLUDE STRUCTURE zfich002.
DATA   END OF tmotivo.



START-OF-SELECTION.

*comment ini
*SELECT * FROM zfich002  INTO CORRESPONDING FIELDS OF TABLE tmotivo.
*
*  SORT tmotivo BY bukrs  estado.
*comment fin
* BEGIN. 07-07-2026 - ATC - ATC-03
* OLD CODE
*  SELECT * FROM zfich001  WHERE   ( traspasado is null ).
*
* NEW CODE
  SELECT *
 FROM zfich001  WHERE   ( traspasado is null ) ORDER BY PRIMARY KEY.

* END. 07-07-2026 - ATC - ATC-03

    PERFORM  busca_resultado.

  ENDSELECT.



END-OF-SELECTION.

*&---------------------------------------------------------------------*
*&      Form  busca_resultado
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM busca_resultado.

* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*  SELECT SINGLE * FROM payr WHERE zbukr = zfich001-bukrs
*                                AND   hbkid = zfich001-hbkid
*                                AND   hktid = zfich001-hktid
*                                AND   rzawe = 'C'
*                                AND   chect = zfich001-chect.
*
* NEW CODE
  SELECT *
  UP TO 1 ROWS  FROM payr WHERE zbukr = zfich001-bukrs
                                AND   hbkid = zfich001-hbkid
                                AND   hktid = zfich001-hktid
                                AND   rzawe = 'C'
                                AND   chect = zfich001-chect ORDER BY PRIMARY KEY.

  ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01

  IF sy-subrc <> 0.
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*    SELECT SINGLE * FROM payr WHERE zbukr = zfich001-bukrs
*                            AND   hbkid = zfich001-hbkid
*                            AND   hktid = zfich001-hktid
*                            AND   rzawe = ''
*                            AND   chect = zfich001-chect.
*
* NEW CODE
    SELECT *
    UP TO 1 ROWS  FROM payr WHERE zbukr = zfich001-bukrs
                            AND   hbkid = zfich001-hbkid
                            AND   hktid = zfich001-hktid
                            AND   rzawe = ''
                            AND   chect = zfich001-chect ORDER BY PRIMARY KEY.

    ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
  ENDIF.

* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*   SELECT SINGLE * FROM bkpf WHERE bukrs = zfich001-bukrs
*                        AND   belnr = zfich001-belnr
*                        AND   gjahr = zfich001-gjahr.
*
* NEW CODE
   SELECT *
   UP TO 1 ROWS  FROM bkpf WHERE bukrs = zfich001-bukrs
                        AND   belnr = zfich001-belnr
                        AND   gjahr = zfich001-gjahr ORDER BY PRIMARY KEY.

   ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
**add ini
SELECT BUKRS, ESTADO, DESCRI, TIPO_EST, SHKZG, GENCH
  FROM zfich002  INTO CORRESPONDING FIELDS OF TABLE @tmotivo
  where bukrs = @zfich001-bukrs and estado = @zfich001-estado.

  SORT tmotivo BY bukrs  estado.
*comment
* READ TABLE tmotivo  WITH KEY bukrs = zfich001-bukrs
*                              estado = zfich001-estado
*                         BINARY SEARCH.
**add fin
if sy-subrc = 0.
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
* SELECT SINGLE  stcd1  FROM lfa1 INTO (stcd1) WHERE lifnr = zfich001-lifnr.
*
* NEW CODE
 SELECT stcd1
 UP TO 1 ROWS   FROM lfa1 INTO (stcd1) WHERE lifnr = zfich001-lifnr ORDER BY PRIMARY KEY.

 ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01

CALL FUNCTION 'ZEXPORT_ESTADOS'
  EXPORTING
    bukrs             = zfich001-bukrs
    belnr             = zfich001-belnr
    rut               = stcd1
    hkont             = zfich001-hkont
    chect             = zfich001-chect
    fec_cont          = bkpf-BUDAT
    gjahr             = zfich001-gjahr
    estado            = zfich001-estado
    desc_est          = tmotivo-descri
    agencia           = zfich001-AGENCIA
    monto             = payr-rwbtr
  IMPORTING
   STATUS             =  STATUS
   OBSERVACION        =  observacion.

   zfich001-traspasado =  STATUS.
   zfich001-OBSERVACION =  OBSERVACION.

endif.
 modify zfich001.






ENDFORM.                    "busca_resultado
