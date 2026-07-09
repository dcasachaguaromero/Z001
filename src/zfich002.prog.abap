*&---------------------------------------------------------------------*
*& Report: < ZEY_GDS_CORRECTION > *
*& Author: < EY_DES04 > *
*& Description: < ReSQ Correction > *
*& Date: <19-12-2019> *
*& Transport Number: < ECDK917080 > *
*&---------------------------------------------------------------------*
REPORT zfich002.


TABLES: payr,
        lfa1,
        zfich001,
        zfich002,
        reguh,
        regup,
        bseg,
        bkpf.

* Parametros para ALV
TYPE-POOLS: slis.

DATA:  sort          TYPE slis_t_sortinfo_alv WITH HEADER LINE,
       fieldcat      TYPE slis_t_fieldcat_alv WITH HEADER LINE,
       print         TYPE slis_print_alv,
       layout        TYPE slis_layout_alv.


DATA :   wa_titulo   TYPE lvc_title,
         tit01(10),
         zzmot_emis  LIKE bseg-zzmot_emis,
         name1       LIKE lfa1-name1,
         stcd1       LIKE lfa1-stcd1,
         motivo_ant  LIKE zfich002-descri,
         cuenta_ant   LIKE zfich001-hkont.

DATA : BEGIN OF tmotivo  OCCURS 1.
        INCLUDE STRUCTURE zfich002.
DATA   END OF tmotivo.

DATA: repid LIKE sy-repid.


DATA: BEGIN OF consulta OCCURS 100,
    bukrs              LIKE zfich001-bukrs,
    hbkid              LIKE zfich001-hbkid ,
    hktid              LIKE zfich001-hktid,
    chect              LIKE zfich001-chect,
    fecha_reg          LIKE zfich001-fecha_reg,
    hora_reg           LIKE zfich001-hora_reg,
    zaldt              LIKE payr-zaldt,
    lifnr              LIKE zfich001-lifnr,
    name1              LIKE lfa1-name1,
    stcd1              LIKE lfa1-stcd1,
    estado             LIKE zfich001-estado,
    belnr              LIKE zfich001-belnr,
    gjahr              LIKE zfich001-gjahr,
    hkont              LIKE zfich001-hkont,
    agencia            LIKE zfich001-agencia ,
    zzmot_emis         LIKE bseg-zzmot_emis,
    rwbtr              LIKE payr-rwbtr,
    usuario            LIKE zfich001-usuario,
    observacion(30)    TYPE c,
 END OF consulta.


DATA: BEGIN OF consulta1 OCCURS 100,
    bukrs              LIKE zfich001-bukrs,
    lifnr              LIKE zfich001-lifnr,
    hbkid              LIKE zfich001-hbkid ,
    hktid              LIKE zfich001-hktid,
    chect              LIKE zfich001-chect,
    fecha_reg          LIKE zfich001-fecha_reg,
    hora_reg           LIKE zfich001-hora_reg,
    zaldt              LIKE payr-zaldt,
    name1              LIKE lfa1-name1,
    stcd1              LIKE lfa1-stcd1,
    estado_d           LIKE zfich002-descri,
    belnr              LIKE zfich001-belnr,
    hkont              LIKE zfich001-hkont,
    estado_d_ant       LIKE zfich002-descri,
    hkont_ant          LIKE zfich001-hkont,
    agencia            LIKE zfich001-agencia ,
    zzmot_emis         LIKE bseg-zzmot_emis,
    rwbtr              LIKE payr-rwbtr,
    usuario            LIKE zfich001-usuario,
    hbkid_r            LIKE zfich001-hbkid,
    hktid_r            LIKE zfich001-hktid,
    chect_r            LIKE zfich001-chect,
    rwbtr_r            LIKE payr-rwbtr,
    observacion(30)    TYPE c,
    estado             LIKE zfich001-estado,
END OF consulta1.

DATA: BEGIN OF consulta2 OCCURS 100,
    bukrs              LIKE zfich001-bukrs,
    lifnr              LIKE zfich001-lifnr,
    hbkid              LIKE zfich001-hbkid ,
    hktid              LIKE zfich001-hktid,
    chect              LIKE zfich001-chect,
    fecha_reg          LIKE zfich001-fecha_reg,
    hora_reg           LIKE zfich001-hora_reg,
    zaldt              LIKE payr-zaldt,
    name1              LIKE lfa1-name1,
    stcd1              LIKE lfa1-stcd1,
    estado_d           LIKE zfich002-descri,
    belnr              LIKE zfich001-belnr,
    hkont              LIKE zfich001-hkont,
    estado_d_ant       LIKE zfich002-descri,
    hkont_ant          LIKE zfich001-hkont,
    agencia            LIKE zfich001-agencia ,
    zzmot_emis         LIKE bseg-zzmot_emis,
    rwbtr              LIKE payr-rwbtr,
    usuario            LIKE zfich001-usuario,
    hbkid_r            LIKE zfich001-hbkid,
    hktid_r            LIKE zfich001-hktid,
    chect_r            LIKE zfich001-chect,
    rwbtr_r            LIKE payr-rwbtr,
    observacion(30)    TYPE c,
END OF consulta2.

PARAMETER: bukrs LIKE  zfich001-bukrs    OBLIGATORY MEMORY ID buk.
PARAMETER: p_fecha LIKE  payr-zaldt      OBLIGATORY.
PARAMETER: p_estad LIKE  zfich001-estado OBLIGATORY MATCHCODE OBJECT zz_estadocheque.
PARAMETER: p_motiv LIKE  bseg-zzmot_emis MATCHCODE OBJECT zz_mot_emis.
SELECT-OPTIONS: p_hbkid FOR payr-hbkid.
SELECT-OPTIONS: p_hktid FOR payr-hktid.
SELECT-OPTIONS: p_chect FOR payr-chect.
SELECT-OPTIONS: p_fecemi FOR  payr-zaldt.
SELECT-OPTIONS: p_lifnr FOR  payr-lifnr.
SELECTION-SCREEN: SKIP.
SELECT-OPTIONS: p_feceve FOR  payr-zaldt.
SELECTION-SCREEN: SKIP.

PARAMETER: p_hist AS CHECKBOX.


START-OF-SELECTION.

* BEGIN. 07-07-2026 - ATC - ATC-03
* OLD CODE
*  SELECT * FROM zfich002  INTO CORRESPONDING FIELDS OF TABLE tmotivo WHERE bukrs = bukrs.
*
* NEW CODE
  SELECT *
 FROM zfich002  INTO CORRESPONDING FIELDS OF TABLE tmotivo WHERE bukrs = bukrs ORDER BY PRIMARY KEY.

* END. 07-07-2026 - ATC - ATC-03
  SORT tmotivo BY estado.




  IF p_estad = 99.
* BEGIN. 07-07-2026 - ATC - ATC-03
* OLD CODE
*    SELECT * FROM  payr WHERE  zbukr =  bukrs
*                        AND    pridt =< p_fecha
*                        AND    xbanc = 'X'
*                        AND    bancd IN  p_feceve
*                        AND    lifnr IN  p_lifnr
*                        AND    hbkid IN  p_hbkid
*                        AND    hktid IN  p_hktid
*                        AND    chect IN  p_chect
*                        AND    zaldt IN  p_fecemi.
*
* NEW CODE
    SELECT *
 FROM  payr WHERE  zbukr =  bukrs
                        AND    pridt =< p_fecha
                        AND    xbanc = 'X'
                        AND    bancd IN  p_feceve
                        AND    lifnr IN  p_lifnr
                        AND    hbkid IN  p_hbkid
                        AND    hktid IN  p_hktid
                        AND    chect IN  p_chect
                        AND    zaldt IN  p_fecemi ORDER BY PRIMARY KEY.

* END. 07-07-2026 - ATC - ATC-03
      PERFORM busca_datos_bseg.

      IF consulta-zzmot_emis = p_motiv OR p_motiv IS INITIAL.
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*        SELECT SINGLE name1 stcd1  FROM lfa1 INTO (name1, stcd1) WHERE lifnr = payr-lifnr.
***
* NEW CODE
        SELECT name1 stcd1
        UP TO 1 ROWS   FROM lfa1 INTO (name1, stcd1) WHERE lifnr = payr-lifnr ORDER BY PRIMARY KEY.

        ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01

        consulta-bukrs        = payr-zbukr.
        consulta-lifnr        = payr-lifnr.
        consulta-hbkid        = payr-hbkid.
        consulta-hktid        = payr-hktid.
        consulta-chect        = payr-chect.
        consulta-fecha_reg    = payr-pridt.
        consulta-hora_reg     = payr-priti.
        consulta-zaldt        = payr-zaldt.
        consulta-estado       = '01'.
        consulta-rwbtr        = payr-rwbtr.
        consulta-belnr        = payr-vblnr.
        consulta-hkont        = payr-ubhkt.
        consulta-usuario      = payr-prius.
        consulta-name1        = name1.
        consulta-stcd1        = stcd1.
        APPEND consulta.

        consulta-bukrs        = payr-zbukr.
        consulta-lifnr        = payr-lifnr.
        consulta-hbkid        = payr-hbkid.
        consulta-hktid        = payr-hktid.
        consulta-chect        = payr-chect.
        consulta-fecha_reg    = payr-bancd.
        consulta-hora_reg     = '235900'.
        consulta-estado        = '99'.
        consulta-agencia =  ''.
        consulta-rwbtr   = payr-rwbtr.

        CLEAR consulta-belnr.
        CLEAR consulta-hkont.
        CLEAR consulta-usuario.
        consulta-name1        = name1.
        consulta-stcd1        = stcd1.
        APPEND consulta.

        zzmot_emis = consulta-zzmot_emis.

        CLEAR consulta.
* 2.- selecciono historial  de cheques seleccionado en punto 1
* BEGIN. 07-07-2026 - ATC - ATC-03
* OLD CODE
*        SELECT * FROM  zfich001
*                 WHERE bukrs = bukrs
*                 AND   lifnr = payr-lifnr
*                 AND   hbkid = payr-hbkid
*                 AND   hktid = payr-hktid
*                 AND   chect = payr-chect
*                 AND   fecha_reg <= p_fecha.
*
* NEW CODE
        SELECT *
 FROM  zfich001
                 WHERE bukrs = bukrs
                 AND   lifnr = payr-lifnr
                 AND   hbkid = payr-hbkid
                 AND   hktid = payr-hktid
                 AND   chect = payr-chect
                 AND   fecha_reg <= p_fecha ORDER BY PRIMARY KEY.

* END. 07-07-2026 - ATC - ATC-03

          MOVE-CORRESPONDING   zfich001 TO consulta.
          consulta-zaldt        = payr-zaldt.
          consulta-rwbtr        = payr-rwbtr.
          consulta-zzmot_emis   = zzmot_emis.
          consulta-name1        = name1.
          consulta-stcd1        = stcd1.

* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*          SELECT SINGLE * FROM bkpf WHERE bukrs = bukrs
*                          AND   belnr = zfich001-belnr
*                          AND   gjahr = zfich001-gjahr.
*
* NEW CODE
          SELECT *
          UP TO 1 ROWS  FROM bkpf WHERE bukrs = bukrs
                          AND   belnr = zfich001-belnr
                          AND   gjahr = zfich001-gjahr ORDER BY PRIMARY KEY.

          ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
          IF sy-subrc = 0 AND bkpf-stgrd IS NOT INITIAL.
            consulta-observacion =   'Cambio Estado Anulado'.
          ENDIF.


          APPEND consulta.

        ENDSELECT.

      ENDIF.


    ENDSELECT.


  ENDIF.

  IF p_estad <> 99.
* Busco Cheques pendientes de cobros  a la fecha indicada


* 1.- selecciono los cheques  ya cobradaso pero cuya fecha de cobro es mayor o igual a fecha indicada

* BEGIN. 07-07-2026 - ATC - ATC-03
* OLD CODE
*    SELECT * FROM  payr WHERE  zbukr =  bukrs
**                      AND    zaldt =< p_fecha
*                        AND    pridt =< p_fecha
*                        AND    xbanc = 'X'
*                        AND    bancd >= p_fecha
*                        AND    lifnr IN p_lifnr
*                        AND    hbkid IN p_hbkid
*                        AND    hktid IN p_hktid
*                        AND    chect IN p_chect
*                        AND    zaldt IN p_fecemi.
*
* NEW CODE
    SELECT *
 FROM  payr WHERE  zbukr =  bukrs
*                      AND    zaldt =< p_fecha
                        AND    pridt =< p_fecha
                        AND    xbanc = 'X'
                        AND    bancd >= p_fecha
                        AND    lifnr IN p_lifnr
                        AND    hbkid IN p_hbkid
                        AND    hktid IN p_hktid
                        AND    chect IN p_chect
                        AND    zaldt IN p_fecemi ORDER BY PRIMARY KEY.

* END. 07-07-2026 - ATC - ATC-03
      PERFORM busca_datos_bseg.

      IF consulta-zzmot_emis = p_motiv OR p_motiv IS INITIAL.
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*        SELECT SINGLE name1 stcd1  FROM lfa1 INTO (name1, stcd1) WHERE lifnr = payr-lifnr.
***
* NEW CODE
        SELECT name1 stcd1
        UP TO 1 ROWS   FROM lfa1 INTO (name1, stcd1) WHERE lifnr = payr-lifnr ORDER BY PRIMARY KEY.

        ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01

        consulta-bukrs        = payr-zbukr.
        consulta-lifnr        = payr-lifnr.
        consulta-hbkid        = payr-hbkid.
        consulta-hktid        = payr-hktid.
        consulta-chect        = payr-chect.
        consulta-fecha_reg    = payr-pridt.
        consulta-hora_reg     = payr-priti.
        consulta-zaldt        = payr-zaldt.
        consulta-estado       = '01'.
        consulta-rwbtr        = payr-rwbtr.
        consulta-belnr        = payr-vblnr.
        consulta-hkont        = payr-ubhkt.
        consulta-usuario      = payr-prius.
        consulta-name1        = name1.
        consulta-stcd1        = stcd1.
        APPEND consulta.

        consulta-bukrs        = payr-zbukr.
        consulta-lifnr        = payr-lifnr.
        consulta-hbkid        = payr-hbkid.
        consulta-hktid        = payr-hktid.
        consulta-chect        = payr-chect.
        consulta-fecha_reg    = payr-bancd.
        CLEAR consulta-hora_reg.
        consulta-estado        = '99'.
        consulta-agencia =  ''.
        consulta-rwbtr   = payr-rwbtr.

        CLEAR consulta-belnr.
        CLEAR consulta-hkont.
        CLEAR consulta-usuario.
        consulta-name1        = name1.
        consulta-stcd1        = stcd1.
        APPEND consulta.

        zzmot_emis = consulta-zzmot_emis.

        CLEAR consulta.
* 2.- selecciono historial  de cheques seleccionado en punto 1
* BEGIN. 07-07-2026 - ATC - ATC-03
* OLD CODE
*        SELECT * FROM  zfich001
*                 WHERE bukrs = bukrs
*                 AND   lifnr = payr-lifnr
*                 AND   hbkid = payr-hbkid
*                 AND   hktid = payr-hktid
*                 AND   chect = payr-chect
*                 AND   fecha_reg <= p_fecha.
*
* NEW CODE
        SELECT *
 FROM  zfich001
                 WHERE bukrs = bukrs
                 AND   lifnr = payr-lifnr
                 AND   hbkid = payr-hbkid
                 AND   hktid = payr-hktid
                 AND   chect = payr-chect
                 AND   fecha_reg <= p_fecha ORDER BY PRIMARY KEY.

* END. 07-07-2026 - ATC - ATC-03

          MOVE-CORRESPONDING   zfich001 TO consulta.
          consulta-zaldt        = payr-zaldt.
          consulta-rwbtr        = payr-rwbtr.
          consulta-zzmot_emis   = zzmot_emis.
          consulta-name1        = name1.
          consulta-stcd1        = stcd1.

* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*          SELECT SINGLE * FROM bkpf WHERE bukrs = bukrs
*                          AND   belnr = zfich001-belnr
*                          AND   gjahr = zfich001-gjahr.
*
* NEW CODE
          SELECT *
          UP TO 1 ROWS  FROM bkpf WHERE bukrs = bukrs
                          AND   belnr = zfich001-belnr
                          AND   gjahr = zfich001-gjahr ORDER BY PRIMARY KEY.

          ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
          IF sy-subrc = 0 AND bkpf-stgrd IS NOT INITIAL.
            consulta-observacion =   'Cambio Estado Anulado'.
          ENDIF.


          APPEND consulta.

        ENDSELECT.

      ENDIF.


    ENDSELECT.
* 3.- selecciono los cheques  pendiente de  cobro

* BEGIN. 07-07-2026 - ATC - ATC-03
* OLD CODE
*    SELECT * FROM  payr WHERE    zbukr =  bukrs
*                          AND    pridt =< p_fecha
*                          AND    xbanc = ''
*                          AND    bancd = 00000000
*                          AND    lifnr IN p_lifnr
*                          AND    hbkid IN p_hbkid
*                          AND    hktid IN p_hktid
*                          AND    chect IN p_chect
*                          AND    zaldt IN p_fecemi.
*
* NEW CODE
    SELECT *
 FROM  payr WHERE    zbukr =  bukrs
                          AND    pridt =< p_fecha
                          AND    xbanc = ''
                          AND    bancd = 00000000
                          AND    lifnr IN p_lifnr
                          AND    hbkid IN p_hbkid
                          AND    hktid IN p_hktid
                          AND    chect IN p_chect
                          AND    zaldt IN p_fecemi ORDER BY PRIMARY KEY.

* END. 07-07-2026 - ATC - ATC-03
      PERFORM busca_datos_bseg.
      IF consulta-zzmot_emis = p_motiv OR p_motiv IS INITIAL.
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*        SELECT SINGLE name1 stcd1  FROM lfa1 INTO (name1, stcd1) WHERE lifnr = payr-lifnr.
***
* NEW CODE
        SELECT name1 stcd1
        UP TO 1 ROWS   FROM lfa1 INTO (name1, stcd1) WHERE lifnr = payr-lifnr ORDER BY PRIMARY KEY.

        ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01

        consulta-bukrs        = payr-zbukr.
        consulta-lifnr        = payr-lifnr.
        consulta-hbkid        = payr-hbkid.
        consulta-hktid        = payr-hktid.
        consulta-chect        = payr-chect.
        consulta-fecha_reg    = payr-pridt.
        consulta-hora_reg     = payr-priti.
        consulta-zaldt        = payr-zaldt.
        consulta-estado       = '01'.
        consulta-rwbtr        = payr-rwbtr.
        consulta-belnr        = payr-vblnr.
        consulta-hkont        = payr-ubhkt.
        consulta-usuario      = payr-prius.
        consulta-name1        = name1.
        consulta-stcd1        = stcd1.
        APPEND consulta.
        zzmot_emis = consulta-zzmot_emis.
        CLEAR consulta.
* 4.- selecciono historial  de cheques seleccionado en punto 3

* BEGIN. 07-07-2026 - ATC - ATC-03
* OLD CODE
*        SELECT * FROM  zfich001
*                 WHERE bukrs = bukrs
*                 AND   lifnr = payr-lifnr
*                 AND   hbkid = payr-hbkid
*                 AND   hktid = payr-hktid
*                 AND   chect = payr-chect
*                 AND   fecha_reg <= p_fecha.
*
* NEW CODE
        SELECT *
 FROM  zfich001
                 WHERE bukrs = bukrs
                 AND   lifnr = payr-lifnr
                 AND   hbkid = payr-hbkid
                 AND   hktid = payr-hktid
                 AND   chect = payr-chect
                 AND   fecha_reg <= p_fecha ORDER BY PRIMARY KEY.

* END. 07-07-2026 - ATC - ATC-03


          MOVE-CORRESPONDING zfich001 TO consulta.
          consulta-zaldt        = payr-zaldt.
          consulta-rwbtr        = payr-rwbtr.
          consulta-zzmot_emis   = zzmot_emis.
          consulta-name1        = name1.
          consulta-stcd1        = stcd1.

* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*          SELECT SINGLE * FROM bkpf WHERE bukrs = bukrs
*                         AND   belnr = zfich001-belnr
*                         AND   gjahr = zfich001-gjahr.
*
* NEW CODE
          SELECT *
          UP TO 1 ROWS  FROM bkpf WHERE bukrs = bukrs
                         AND   belnr = zfich001-belnr
                         AND   gjahr = zfich001-gjahr ORDER BY PRIMARY KEY.

          ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
          IF sy-subrc = 0 AND bkpf-stgrd IS NOT INITIAL.
            consulta-observacion =   'Cambio Estado Anulado'.
          ENDIF.

          APPEND consulta.

        ENDSELECT.


        IF payr-voidr IS NOT INITIAL.

          READ TABLE consulta   WITH KEY
             bukrs      = payr-zbukr
             lifnr      = payr-lifnr
             hbkid      = payr-hbkid
             hktid      = payr-hktid
             chect      = payr-chect
             fecha_reg  = payr-voidd
             estado     = '12'.
          IF sy-subrc <> 0.
            consulta-bukrs        = payr-zbukr.
            consulta-lifnr        = payr-lifnr.
            consulta-hbkid        = payr-hbkid.
            consulta-hktid        = payr-hktid.
            consulta-chect        = payr-chect.
            consulta-fecha_reg    = payr-voidd.
            CLEAR consulta-hora_reg.
            consulta-zaldt        = payr-zaldt.
            consulta-estado       = '12'.
            consulta-rwbtr        = payr-rwbtr.
            consulta-belnr        = payr-vblnr.
            consulta-hkont        = payr-ubhkt.
            consulta-usuario      = payr-voidu.
            consulta-name1        = name1.
            consulta-stcd1        = stcd1.
            consulta-zzmot_emis   = zzmot_emis.
            consulta-agencia = bseg-zz_agencia.
            APPEND consulta.
          ENDIF.
        ENDIF.
      ENDIF.

    ENDSELECT.
  ENDIF.


  REFRESH consulta1.

  SORT consulta BY bukrs hbkid  hktid chect  fecha_reg hora_reg.
  CLEAR: motivo_ant, cuenta_ant.
  LOOP AT consulta.

    CHECK consulta-observacion  IS INITIAL.

    READ TABLE tmotivo  WITH KEY estado = consulta-estado
                         BINARY SEARCH.


    MOVE-CORRESPONDING  consulta TO consulta1.
    consulta1-estado_d = tmotivo-descri.

    consulta1-estado_d_ant = motivo_ant.
    consulta1-hkont_ant = cuenta_ant.

    motivo_ant = tmotivo-descri.
    cuenta_ant = consulta-hkont.

    IF sy-subrc = 0 AND tmotivo-gench = 'X'.
      PERFORM buscar_nuevo_cheque.
    ENDIF.
    AT END OF chect.
      IF consulta1-chect IS NOT INITIAL.
        APPEND consulta1.
        CLEAR consulta1.
      ENDIF.
    ENDAT.
  ENDLOOP.

  IF p_estad IS NOT INITIAL.
    DELETE consulta1 WHERE estado <> p_estad..
  ENDIF.

  REFRESH consulta2.

  IF p_hist = 'X'.

    LOOP AT consulta1.

      MOVE-CORRESPONDING  consulta1 TO consulta2.
      APPEND consulta2.
      CLEAR  consulta2.
      LOOP AT consulta WHERE bukrs   =  consulta1-bukrs
                       AND   hbkid   =  consulta1-hbkid
                       AND   hktid   =  consulta1-hktid
                       AND   chect   =  consulta1-chect
                       AND   fecha_reg  <= consulta1-fecha_reg.

        IF consulta-fecha_reg  = consulta1-fecha_reg .
          IF consulta-hora_reg < consulta1-hora_reg.
            MOVE-CORRESPONDING  consulta TO consulta2.
            READ TABLE tmotivo  WITH KEY estado = consulta-estado
                        BINARY SEARCH.
            consulta2-estado_d = tmotivo-descri.
            APPEND consulta2.
            CLEAR  consulta2.
          ENDIF.
        ELSE.
          MOVE-CORRESPONDING  consulta TO consulta2.
          READ TABLE tmotivo  WITH KEY estado = consulta-estado
                        BINARY SEARCH.
          consulta2-estado_d = tmotivo-descri.
          APPEND consulta2.
          CLEAR  consulta2.
        ENDIF.
      ENDLOOP.
    ENDLOOP.

  ELSE.
    consulta2[] = consulta1[].
  ENDIF.

  SORT consulta2 BY  bukrs  lifnr hbkid   hktid   chect  fecha_reg  hora_reg.


  PERFORM lista.

*---------------------------------------------------------------------*
*      Form  lista tabla
*---------------------------------------------------------------------*
FORM lista.

  REFRESH: fieldcat.
  CLEAR: fieldcat, layout, print.

* ALV
* Definicion de parametros de layout
  layout-no_keyfix = ' '.
  layout-zebra = 'X'.
  layout-colwidth_optimize = 'X'.


  wa_titulo = 'Reporte Historial de Cheques'.


*  IF CLIENTE <> 'X'.
*
*    SORT-FIELDNAME = 'NAME_RSM'.
*    SORT-GROUP     = 'X'.
*    SORT-UP        = 'X'.
*    SORT-SUBTOT    = 'X'.
*    APPEND SORT.
*
*    SORT-FIELDNAME = 'NAME_ASM'.
*    SORT-GROUP     = 'X'.
*    SORT-UP        = 'X'.
*    SORT-SUBTOT    = 'X'.
*    APPEND SORT.
*
*    SORT-FIELDNAME = 'NAME_TERR'.
*    SORT-GROUP     = 'X'.
*    SORT-UP        = 'X'.
*    SORT-SUBTOT    = 'X'.
*    APPEND SORT.
*
*
*    SORT-FIELDNAME = 'VENDEDOR'.
*    SORT-GROUP     = 'X'.
*    SORT-UP        = 'X'.
*    SORT-SUBTOT    = 'X'.
*    APPEND SORT.
*
*  endif.

  tit01 = 'SOCI'.




  PERFORM f_monta_fieldcat USING:
    'BUKRS'      'CONSULTA2' ' ' ' '  '01' ' ' ' ' 'Sociedad' ' ' ' ' ' ' '04',
    'LIFNR'      'CONSULTA2' ' ' ' '  '02' ' ' ' ' 'Cliente'  ' ' ' ' ' ' '10',
    'NAME1'      'CONSULTA2' ' ' ' '  '03' ' ' ' ' 'Nombre'   ' ' ' ' ' ' '35',
    'STCD1'      'CONSULTA2' ' ' ' '  '04' ' ' ' ' 'Rut'      ' ' ' ' ' ' '35',
    'HBKID'      'CONSULTA2' ' ' ' '  '05' ' ' ' ' 'Banco'    ' ' ' ' ' ' '35',
    'HKTID'      'CONSULTA2' ' ' ' '  '06' ' ' ' ' 'Cuenta'   ' ' ' ' ' ' '35',
    'CHECT'      'CONSULTA2' ' ' ' '  '07' ' ' ' ' 'Nro.Cheque' ' ' ' ' ' ' '35',
    'FECHA_REG'  'CONSULTA2' ' ' ' '  '08' ' ' ' ' 'Fecha Registro' ' ' ' ' ' ' '35',
    'HORA_REG'   'CONSULTA2' ' ' ' '  '09' ' ' ' ' 'Hora Registro' ' ' ' ' ' ' '35',
    'ZALDT'      'CONSULTA2' ' ' ' '  '09' ' ' ' ' 'Fecha Emision' ' ' ' ' ' ' '35',
    'ESTADO_D'   'CONSULTA2' ' ' ' '  '10' ' ' ' ' 'Estado' ' ' ' ' ' ' '35',
    'BELNR'      'CONSULTA2' ' ' ' '  '11' ' ' ' ' 'Doc. Contable' ' ' ' ' ' ' '35',
    'HKONT'      'CONSULTA2' ' ' ' '  '12' ' ' ' ' 'Cta Contable' ' ' ' ' ' ' '35',
    'ESTADO_D_ANT'   'CONSULTA2' ' ' ' '  '13' ' ' ' ' 'Est. Ant.' ' ' ' ' ' ' '35',
    'HKONT_ANT'      'CONSULTA2' ' ' ' '  '14' ' ' ' ' 'Cta. Cont. Ant.' ' ' ' ' ' ' '35',

    'AGENCIA'    'CONSULTA2' ' ' ' '  '15' ' ' ' ' 'Agencia' ' ' ' ' ' ' '35',
    'ZZMOT_EMIS' 'CONSULTA2' ' ' ' '  '16' ' ' ' ' 'Motivo Emision' ' ' ' ' ' ' '35',
    'RWBTR'      'CONSULTA2' ' ' ' '  '17' ' ' ' ' 'Monto Cheque' ' ' ' ' ' ' '35',
    'HBKID_R'    'CONSULTA2' ' ' ' '  '18' ' ' ' ' 'Banco Nuevo'    ' ' ' ' ' ' '35',
    'HKTID_R'    'CONSULTA2' ' ' ' '  '19' ' ' ' ' 'Cuenta Nueva'   ' ' ' ' ' ' '35',
    'CHECT_R'    'CONSULTA2' ' ' ' '  '20' ' ' ' ' 'Nro.Cheque Nuevo' ' ' ' ' ' ' '35',
    'RWBTR_R'    'CONSULTA2' ' ' ' '  '21' ' ' ' ' 'Valor Nuevo' ' ' ' ' ' ' '35'.



  print-no_print_listinfos = 'X'.
  print-no_print_selinfos  = 'X'.

  repid = sy-repid.
  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
         EXPORTING
              i_callback_program       = repid
              i_structure_name         = 'CONSULTA2'
              i_grid_title             =  wa_titulo
              is_layout                = layout
              it_fieldcat              = fieldcat[]
*              it_sort                  = sort[]
*              i_default                = 'X'
*               i_save                   = 'A'
*           is_variant               = variante
              is_print                 = print
         TABLES
              t_outtab                 = consulta2
         EXCEPTIONS
              program_error            = 1
              OTHERS                   = 2.

  IF sy-subrc <> 0.
*    MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*            WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.
ENDFORM.                    "lista
*---------------------------------------------------
* Monta el Fieldcat
*---------------------------------------------------
FORM f_monta_fieldcat USING  x_field
                             x_tab
                             x_ref
                             x_ref_f
                             x_col_pos
                             x_hotspot
                             x_checkbox
                             x_seltext_l
                             x_key
                             x_no_out
                             x_do_sum
                             x_largo.

  fieldcat-fieldname     = x_field.
  fieldcat-tabname       = x_tab.
  fieldcat-ref_tabname   = x_ref.
  fieldcat-ref_fieldname = x_ref_f.
  fieldcat-col_pos       = x_col_pos.
  fieldcat-hotspot       = x_hotspot.
  fieldcat-checkbox      = x_checkbox.
  fieldcat-seltext_l     = x_seltext_l.
  fieldcat-key           = x_key.
  fieldcat-no_out        = x_no_out.
  fieldcat-do_sum        = x_do_sum.
  fieldcat-outputlen     = x_largo.
  IF x_field = 'RWBTR' OR x_field = 'RWBTR_R'.
    fieldcat-currency      = 'CLP'.
  ENDIF.
  APPEND fieldcat.
  CLEAR fieldcat.

ENDFORM.                    " Total_NAME_RSM


*&---------------------------------------------------------------------*
*&      Form  busca_datos_bseg
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM busca_datos_bseg.

*ResQ Comment:Correction not required as Select Single is used 19/12/2019 EY_DES04 ECDK917080 *
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*  SELECT SINGLE  * FROM  regup WHERE laufd = payr-laufd
*                              AND    laufi = payr-laufi
*                              AND    xvorl = ''
*                              AND    zbukr = payr-zbukr
*                              AND    lifnr = payr-lifnr
*                              AND    kunnr = payr-kunnr
*                              AND    empfg = payr-empfg
*                              AND    vblnr = payr-vblnr.
*
* NEW CODE
  SELECT *
  UP TO 1 ROWS  FROM  regup WHERE laufd = payr-laufd
                              AND    laufi = payr-laufi
                              AND    xvorl = ''
                              AND    zbukr = payr-zbukr
                              AND    lifnr = payr-lifnr
                              AND    kunnr = payr-kunnr
                              AND    empfg = payr-empfg
                              AND    vblnr = payr-vblnr ORDER BY PRIMARY KEY.

  ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
*ResQ Comment:Correction not required as Select Single is used 19/12/2019 EY_DES04 ECDK917080 *
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*  SELECT SINGLE  * FROM  bseg WHERE bukrs  = regup-bukrs
*                         AND  belnr = regup-belnr
*                         AND  gjahr = regup-gjahr
*                         AND  buzei = regup-buzei.
*
* NEW CODE
  SELECT *
  UP TO 1 ROWS  FROM  bseg WHERE bukrs  = regup-bukrs
                         AND  belnr = regup-belnr
                         AND  gjahr = regup-gjahr
                         AND  buzei = regup-buzei ORDER BY PRIMARY KEY.

  ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01




  consulta-agencia = bseg-zz_agencia.
  consulta-zzmot_emis = bseg-zzmot_emis.
ENDFORM.                    "busca_datos_bseg
*&---------------------------------------------------------------------*
*&      Form  BUSCAR_NUEVO_CHEQUE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM buscar_nuevo_cheque .
*ResQ Comment:Correction not required as Select Single is used 19/12/2019 EY_DES04 ECDK917080 *
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*  SELECT SINGLE  * FROM bseg WHERE bukrs =  consulta-bukrs
*                             AND   belnr =  consulta-belnr
*                             AND   gjahr =  consulta-gjahr
*                             AND   shkzg =  tmotivo-shkzg.
*
* NEW CODE
  SELECT *
  UP TO 1 ROWS  FROM bseg WHERE bukrs =  consulta-bukrs
                             AND   belnr =  consulta-belnr
                             AND   gjahr =  consulta-gjahr
                             AND   shkzg =  tmotivo-shkzg ORDER BY PRIMARY KEY.

  ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
  IF sy-subrc = 0.


    IF sy-subrc = 0.
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*      SELECT SINGLE  * FROM    reguh
*                       WHERE   zbukr =  bseg-bukrs
*                       AND     lifnr =  bseg-lifnr
*                       AND     kunnr =  bseg-kunnr
*                       AND     vblnr =  bseg-augbl
*                       AND     zaldt =  bseg-augdt
*                       AND     xvorl =  ''.
*
* NEW CODE
      SELECT *
      UP TO 1 ROWS  FROM    reguh
                       WHERE   zbukr =  bseg-bukrs
                       AND     lifnr =  bseg-lifnr
                       AND     kunnr =  bseg-kunnr
                       AND     vblnr =  bseg-augbl
                       AND     zaldt =  bseg-augdt
                       AND     xvorl =  '' ORDER BY PRIMARY KEY.

      ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
      IF sy-subrc = 0.
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*        SELECT SINGLE * FROM  payr WHERE zbukr   = reguh-zbukr
*                                    AND   vblnr  = reguh-vblnr
*                                    AND   gjahr  = reguh-zaldt+0(4).
*
* NEW CODE
        SELECT *
        UP TO 1 ROWS  FROM  payr WHERE zbukr   = reguh-zbukr
                                    AND   vblnr  = reguh-vblnr
                                    AND   gjahr  = reguh-zaldt+0(4) ORDER BY PRIMARY KEY.

        ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01

        IF sy-subrc = 0.
          consulta1-hbkid_r =    payr-hbkid.
          consulta1-hktid_r =    payr-hktid.
          consulta1-chect_r =    payr-chect.
          consulta1-rwbtr_r =    payr-rwbtr.
        ENDIF.

      ENDIF.

    ENDIF.

  ENDIF.

ENDFORM.                    " BUSCAR_NUEVO_CHEQUE
