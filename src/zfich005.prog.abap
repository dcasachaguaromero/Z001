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
  SELECT * FROM zfich001  WHERE   ( traspasado is null ).

    PERFORM  busca_resultado.

  ENDSELECT.



END-OF-SELECTION.

*&---------------------------------------------------------------------*
*&      Form  busca_resultado
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM busca_resultado.

  SELECT SINGLE * FROM payr WHERE zbukr = zfich001-bukrs
                                AND   hbkid = zfich001-hbkid
                                AND   hktid = zfich001-hktid
                                AND   rzawe = 'C'
                                AND   chect = zfich001-chect.

  IF sy-subrc <> 0.
    SELECT SINGLE * FROM payr WHERE zbukr = zfich001-bukrs
                            AND   hbkid = zfich001-hbkid
                            AND   hktid = zfich001-hktid
                            AND   rzawe = ''
                            AND   chect = zfich001-chect.
  ENDIF.

   SELECT SINGLE * FROM bkpf WHERE bukrs = zfich001-bukrs
                        AND   belnr = zfich001-belnr
                        AND   gjahr = zfich001-gjahr.
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
 SELECT SINGLE  stcd1  FROM lfa1 INTO (stcd1) WHERE lifnr = zfich001-lifnr.

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
