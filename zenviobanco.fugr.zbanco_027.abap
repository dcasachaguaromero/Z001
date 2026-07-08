*&---------------------------------------------------------------------*
*& Report: < ZEY_GDS_CORRECTION > *
*& Author: < EY_DES01 > *
*& Description: < ReSQ Correction > *
*& Date: <19-12-2019> *
*& Transport Number: < ECDK917080 > *
*&---------------------------------------------------------------------*
FUNCTION zbanco_027.
*"----------------------------------------------------------------------
*"*"Interfase local
*"  IMPORTING
*"     REFERENCE(TIPPRO) TYPE  CHAR01
*"     REFERENCE(CONTAR) TYPE  NUMC06
*"     REFERENCE(SUMPAGOS) TYPE  NUMC15
*"     REFERENCE(V_FECHA) TYPE  DATS
*"     REFERENCE(NVOANT) TYPE  CHAR01
*"  TABLES
*"      TABLA_00 STRUCTURE  REGUH
*"      FILESALIDA
*"----------------------------------------------------------------------
*& ** DEFINICION DE DATOS
*&----------------------------------------------------------------------*
  DATA: v_rut(10)     TYPE c,
        f_rut(11)     TYPE c,
        numero(10)    TYPE n,
        num05(5)      TYPE c,
        linea(5)      TYPE n,
        monto_z(15),
        num_c(8)      TYPE c,
        folio_aux(15),
        f_adrnr       TYPE adrc-addrnumber,
        v_adrnr       TYPE adrc-addrnumber,
        dv,
        v_mail        TYPE adr6-smtp_addr,
        v_cta         TYPE zfitr005-zctacte,
        v_vta         TYPE zfitr005-zctavta,
        v_cla         TYPE zfitr005-zclavemis,
        v_ct(20)      TYPE c,
        v_doc(20)     TYPE c,
        tipdoc(4)     TYPE c,
        contar10(10)  TYPE c,
        sumapagos(15) TYPE c,
        v_flag.

  DATA : BEGIN OF file OCCURS 0,
          linea(640) TYPE c.
  DATA : END OF file.

  DATA: ti_adrc TYPE adrc OCCURS 0 WITH HEADER LINE,
        tiposdoc   TYPE ztd_pagobanco OCCURS 0 WITH HEADER LINE.

  REFRESH: file.

*"----------------------------------------------------------------------
*& ** INICIO DE PROCESO
*&---------------------------------------------------------------------*

*Begin of change: ReSQ Correction INDEX READ on an unsorted Internal TABLE 19/12/2019 EY_DES01 ECDK917080 *
SORT TABLA_00 .
*End of change: ReSQ Correction for INDEX READ on an unsorted Internal TABLE 19/12/2019 EY_DES01 ECDK917080 *
  READ TABLE tabla_00 INDEX 1.

*  Carga Clases de Documento, según sociedad y banco
* BEGIN. 07-07-2026 - ATC - ATC-03
* OLD CODE
*  SELECT *
*          FROM ztd_pagobanco
*          INTO CORRESPONDING FIELDS OF TABLE  tiposdoc
*          WHERE banco = tabla_00-ubnkl.
*
* NEW CODE
  SELECT *

          FROM ztd_pagobanco
          INTO CORRESPONDING FIELDS OF TABLE  tiposdoc
          WHERE banco = tabla_00-ubnkl ORDER BY PRIMARY KEY.

* END. 07-07-2026 - ATC - ATC-03

* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*  SELECT SINGLE adrnr
*          FROM t001
*          INTO v_adrnr
*          WHERE bukrs EQ tabla_00-zbukr.
*
* NEW CODE
  SELECT adrnr
  UP TO 1 ROWS 
          FROM t001
          INTO v_adrnr
          WHERE bukrs EQ tabla_00-zbukr ORDER BY PRIMARY KEY.

  ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01

  f_adrnr = v_adrnr.

  IF f_adrnr IS NOT INITIAL.

    CALL FUNCTION 'RTP_US_DB_ADRC_READ'
      EXPORTING
        i_address_number = f_adrnr
      IMPORTING
        e_adrc           = ti_adrc
      EXCEPTIONS
        not_found        = 1
        OTHERS           = 2.
  ENDIF.

  v_rut = ti_adrc-sort1.

  IF v_rut IS NOT INITIAL.
    SPLIT v_rut AT '-' INTO num_c dv.
    numero = num_c.
    CONCATENATE numero dv INTO f_rut.
  ENDIF.
*ResQ Comment:Correction not required as Select Single is used 19/12/2019 EY_DES01 ECDK917080 *
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*SELECT single  * FROM  regup
*                       WHERE   laufd = tabla_00-laufd
*                       AND     laufi = tabla_00-laufi
*                       AND     xvorl = tabla_00-xvorl
*                       AND     lifnr = tabla_00-lifnr
*                       AND     kunnr = tabla_00-kunnr
*                       AND     empfg = tabla_00-empfg
*                       AND     vblnr = tabla_00-vblnr
*                       AND     zbukr = tabla_00-zbukr.
*
* NEW CODE
SELECT *
UP TO 1 ROWS  FROM  regup
                       WHERE   laufd = tabla_00-laufd
                       AND     laufi = tabla_00-laufi
                       AND     xvorl = tabla_00-xvorl
                       AND     lifnr = tabla_00-lifnr
                       AND     kunnr = tabla_00-kunnr
                       AND     empfg = tabla_00-empfg
                       AND     vblnr = tabla_00-vblnr
                       AND     zbukr = tabla_00-zbukr ORDER BY PRIMARY KEY.

ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01



* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*  SELECT SINGLE *  FROM bsak
*                   WHERE bukrs EQ regup-bukrs
*                   AND   lifnr EQ regup-lifnr
*                   AND   GJAHR EQ regup-GJAHR
*                   AND   BELNR EQ regup-BELNR
*                   AND   BUZEI EQ regup-BUZEI.
*
* NEW CODE
  SELECT *
  UP TO 1 ROWS   FROM bsak
                   WHERE bukrs EQ regup-bukrs
                   AND   lifnr EQ regup-lifnr
                   AND   GJAHR EQ regup-GJAHR
                   AND   BELNR EQ regup-BELNR
                   AND   BUZEI EQ regup-BUZEI ORDER BY PRIMARY KEY.

  ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01

* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*  SELECT SINGLE * FROM zfitr005 WHERE bukrs  = tabla_00-zbukr
*                                  AND hbkid  = tabla_00-hbkid
*                                  AND zmotiv = bsak-zzmot_emis.
*
* NEW CODE
  SELECT *
  UP TO 1 ROWS  FROM zfitr005 WHERE bukrs  = tabla_00-zbukr
                                  AND hbkid  = tabla_00-hbkid
                                  AND zmotiv = bsak-zzmot_emis ORDER BY PRIMARY KEY.

  ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01

  MOVE: zfitr005-zctacte   TO v_cta,
        zfitr005-zctavta   TO v_vta,
        zfitr005-zclavemis TO v_cla.
*-----------------------------------------------------------------------------
*  REGISTRO DE IDENTIFICACION DE PROCESO EN MODALIDAD DE PRUEBA
*-----------------------------------------------------------------------------
  IF tippro <> 'X'.
    file-linea+0(225)      = '*****ARCHIVO DE TEST*****'.
    APPEND file.
    CLEAR  file.
  ENDIF.

*-----------------------------------------------------------------------------
*  PREPARACION DE REGISTRO DE CABECERA
*-----------------------------------------------------------------------------
  MOVE contar   TO contar10.
  MOVE sumpagos TO sumapagos.
*  file-linea+0(11)     = f_rut.
*  file-linea+11(10)    = contar10.
*  file-linea+21(15)    = sumpagos.
*  file-linea+36(10)    = '1350040000'.
*  file-linea+46(30)    = 'CAT_CSH_CONTRACT_ACCOUNT'.
*  file-linea+76(18)     = v_cta.
*  file-linea+94(40)     = '   '.

  SHIFT sumapagos LEFT DELETING LEADING '0'.
  SHIFT contar10  LEFT DELETING LEADING '0'.
  SHIFT f_rut     LEFT DELETING LEADING '0'.
  SHIFT v_cta     LEFT DELETING LEADING '0'.

  CONCATENATE f_rut ',' contar10 ',' sumpagos ',' '1350040000' ',' 'CAT_CSH_CONTRACT_ACCOUNT' ',' v_cta ',' zfitr005-zdesc  INTO file-linea.

  APPEND file.
  CLEAR  file.
*-----------------------------------------------------------------------------
*  BLOQUEO DE REGISTRO SOCIEDAD BANCO EN ARCHIVO DE FOLIOS
*-----------------------------------------------------------------------------
  CALL FUNCTION 'ENQUEUE_EZ_ZFOLIO_PAGBCO'
    EXPORTING
      mode_zfolio_pagobanco = 'E'
      mandt                 = sy-mandt
      bukrs                 = tabla_00-zbukr
      ubnkl                 = tabla_00-ubnkl
      codigo                = '001'.

  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
       WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.

* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*  SELECT SINGLE *  FROM zfolio_pagobanco  WHERE bukrs  = tabla_00-zbukr
*                                            AND ubnkl  = tabla_00-ubnkl
*                                            AND codigo = '001'.
*
* NEW CODE
  SELECT *
  UP TO 1 ROWS   FROM zfolio_pagobanco  WHERE bukrs  = tabla_00-zbukr
                                            AND ubnkl  = tabla_00-ubnkl
                                            AND codigo = '001' ORDER BY PRIMARY KEY.

  ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
  IF sy-subrc <> 0.
    zfolio_pagobanco-bukrs = tabla_00-zbukr.
    zfolio_pagobanco-codigo ='001'.
    zfolio_pagobanco-folio = 0.
  ENDIF.
*-----------------------------------------------------------------------------
*  INICIO DE PREPARACION DE REGISTROS DE PAGOS
*-----------------------------------------------------------------------------
  LOOP AT tabla_00.
*   Header Proveedor

    v_rut = tabla_00-stcd1.

    IF v_rut IS NOT INITIAL.
      SPLIT v_rut AT '-' INTO num_c dv.
      numero = num_c.
      CONCATENATE numero dv INTO f_rut.
    ENDIF.

    zfolio_pagobanco-folio =  zfolio_pagobanco-folio + 1.
    IF tippro = 'X'.
      MODIFY  zfolio_pagobanco.
    ENDIF.

* Si no está procesado, genera nuevo folio
    IF tabla_00-identif_pago IS INITIAL.
* CBD
      CONCATENATE tabla_00-zbukr  tabla_00-ubnkl zfolio_pagobanco-folio+3(8) INTO folio_aux .
    ELSE.
* Si ya existe un folio anterior, deja el folio existente
      CLEAR folio_aux.
* CBD
* CBD      MOVE tabla_00-identif_pago TO folio_aux.
      MOVE tabla_00-identif_pago TO folio_aux.
* CBD
    ENDIF.

    CALL FUNCTION 'SCP_REPLACE_STRANGE_CHARS'
      EXPORTING
        intext  = tabla_00-name1
      IMPORTING
        outtext = tabla_00-name1.

    CLEAR:  f_adrnr, v_adrnr, v_mail.

* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*    SELECT SINGLE adrnd
*           INTO v_adrnr
*           FROM knvk
*           WHERE lifnr EQ tabla_00-lifnr.
*
* NEW CODE
    SELECT adrnd
    UP TO 1 ROWS 
           INTO v_adrnr
           FROM knvk
           WHERE lifnr EQ tabla_00-lifnr ORDER BY PRIMARY KEY.

    ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01

* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*    SELECT SINGLE smtp_addr
*           INTO v_mail
*           FROM adr6
*           WHERE addrnumber EQ tabla_00-adrnr.
*
* NEW CODE
    SELECT smtp_addr
    UP TO 1 ROWS 
           INTO v_mail
           FROM adr6
           WHERE addrnumber EQ tabla_00-adrnr ORDER BY PRIMARY KEY.

    ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01

    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
      EXPORTING
        input  = tabla_00-ubknt
      IMPORTING
        output = v_ct.

    monto_z = tabla_00-rbetr * -100.

    REPLACE '.0000' WITH '' INTO monto_z.
    CONDENSE monto_z NO-GAPS.

    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
      EXPORTING
        input  = monto_z
      IMPORTING
        output = monto_z.
    MOVE tabla_00-rpost TO num05.
*-----------------------------------------------------------------------------
*  GENERA REGISTROS DE PAGOS
*-----------------------------------------------------------------------------
*    file-linea+0(11)      = f_rut.
*    file-linea+11(45)     = tabla_00-name1.
*    file-linea+56(200)    = v_mail.

*    IF tabla_00-rzawe = 'V'.
*      file-linea+256(30)     = 'CAT_CSH_VIRTUAL_OFFICE_CHECK'.
*      file-linea+286(3)     = '027'.
*      file-linea+289(15)     = '             '.
*      file-linea+304(18)    = '000000000000000000'.
*      file-linea+395(3)     = '001'.
*    ELSE.
*      file-linea+256(30)     = 'CAT_CSH_TRANSFER'.
*      file-linea+286(3)      = tabla_00-zbnkl.
*      file-linea+289(15)     = 'CAT_CSH_CCTE'.
*      file-linea+304(18)     = tabla_00-zbnkn.
*      file-linea+395(3)     = '   '.
*    ENDIF.
*    CONCATENATE v_fecha+06(2) '/' v_fecha+04(2) '/' v_fecha+0(4) INTO file-linea+321(10).
*    file-linea+332(2)     = '  '.
*    file-linea+334(15)     = monto_z.
*    file-linea+349(30)    = 'V CAT_CSH_CONTRACT_ACCOUNT'.
*    file-linea+379(18)   = v_cta.
*    file-linea+397(100)     = folio_aux.
*    IF tabla_00-xavis = '4'.
*      file-linea+497(2)  = 'SI'.
*    ELSE.
*      file-linea+497(2)  = 'NO'.
*    ENDIF.
*    file-linea+499(1)  = '2'.
*    file-linea+500(3)     = num05+2(3).

    SHIFT v_cta                   LEFT DELETING LEADING '0'.
    SHIFT num05                   LEFT DELETING LEADING ' '.
    SHIFT f_rut                   LEFT DELETING LEADING '0'.
    SHIFT monto_z                 LEFT DELETING LEADING '0'.

    CONCATENATE   f_rut ',' tabla_00-name1 ',' v_mail ',' INTO file-linea.
    IF tabla_00-rzawe = 'V'.
      CONCATENATE file-linea 'CAT_CSH_VIRTUAL_OFFICE_CHECK' ','  '027' ',' ','  ','   INTO file-linea.
    ELSE.
      CONCATENATE file-linea 'CAT_CSH_TRANSFER' ','  tabla_00-zbnkl ',' 'CAT_CSH_CCTE' ',' tabla_00-zbnkn ','  INTO file-linea.
    ENDIF.
    CONCATENATE  file-linea  tabla_00-zaldt+06(2) '/' tabla_00-zaldt+04(2) '/' tabla_00-zaldt+0(4) ',' ',,' monto_z ',' 'CAT_CSH_CCTE' ','
    v_cta ','  INTO file-linea.

    IF tabla_00-rzawe = 'V'.
      CONCATENATE file-linea '1' ',' folio_aux ',' INTO file-linea.
    ELSE.
      CONCATENATE file-linea ',,' folio_aux ',' INTO file-linea.
    ENDIF.

    IF tabla_00-xavis = '4'.
      CONCATENATE file-linea 'SI' ',' INTO file-linea.
    ELSE.
      CONCATENATE file-linea 'NO' ',' INTO file-linea.
    ENDIF.
    CONCATENATE file-linea  '2' ',' num05 INTO file-linea.

    APPEND file.
    CLEAR  file.

* --------------------------------------------------------------------------
*  PREPARACION DE REGISTROS DE DOCUMENTOS DE CADA PAGO SI FORMATO DETALLE
*-----------------------------------------------------------------------------
    IF nvoant = '2'.

SELECT * FROM regup WHERE laufd = tabla_00-laufd
AND laufi = tabla_00-laufi
AND xvorl = tabla_00-xvorl
AND lifnr = tabla_00-lifnr
AND kunnr = tabla_00-kunnr
AND empfg = tabla_00-empfg
AND vblnr = tabla_00-vblnr
*Begin of change: ReSQ Correction for Addition ORDER BY PRIMARY KEY 19/12/2019 EY_DES01 ECDK917080 *
*AND zbukr = tabla_00-zbukr.
AND ZBUKR = TABLA_00-ZBUKR ORDER BY PRIMARY KEY.
*End of change: ReSQ Correction for Addition ORDER BY PRIMARY KEY 19/12/2019 EY_DES01 ECDK917080 *

        monto_z = regup-dmbtr * 100.

        REPLACE '.0000' WITH '' INTO monto_z.
        CONDENSE monto_z NO-GAPS.

        CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
          EXPORTING
            input  = monto_z
          IMPORTING
            output = monto_z.

        CLEAR tipdoc.

        READ TABLE tiposdoc WITH KEY
        banco = tabla_00-ubnkl  codigo = regup-blart.
        IF sy-subrc = 0.
          move tiposdoc-codban to tipdoc.
        ELSE.
          tipdoc = '9999'.
        ENDIF.

        CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
          EXPORTING
            input  = regup-xblnr
          IMPORTING
            output = v_doc.

        SHIFT monto_z LEFT DELETING LEADING '0'.

*-----------------------------------------------------------------------------
*  PREPARACION DE REGISTROS DETALLE DE DOCUMENTOS PAGADOS
*-----------------------------------------------------------------------------
*        file-linea+0(04)     = tipdoc.
*        file-linea+04(20)    = v_doc.
*        file-linea+24(11)    = f_rut.
*        file-linea+35(15)    = monto_z.
*        CONCATENATE regup-bldat+06(2) '/' regup-bldat+04(2) '/' regup-bldat+0(4) INTO file-linea+50(10).
*        CONCATENATE v_fecha+06(2) '/' v_fecha+04(2) '/' v_fecha+0(4) INTO file-linea+60(10).
*        file-linea+70(04)     = '0000'.
*        file-linea+74(20)     = '00000000000000000000'.

        SHIFT v_doc                   LEFT DELETING LEADING '0'.
        SHIFT f_rut                   LEFT DELETING LEADING '0'.
        SHIFT monto_z                 LEFT DELETING LEADING '0'.

        CONCATENATE tipdoc ',' v_doc ',' f_rut ',' monto_z ','  regup-bldat+06(2) '/' regup-bldat+04(2) '/' regup-bldat+0(4)
        ',' regup-zfbdt+06(2) '/' regup-zfbdt+04(2) '/' regup-zfbdt+0(4) ',,' INTO file-linea+0.

        APPEND file.
        CLEAR  file.
      ENDSELECT.                                      " regup
    ENDIF.

    IF tippro = 'X'.
      UPDATE reguh
         SET identif_pago   = folio_aux
             fecha_envio    = sy-datum
             usuario_envio  = sy-uname
       WHERE laufd          = tabla_00-laufd
         AND laufi          = tabla_00-laufi
         AND xvorl          = tabla_00-xvorl
         AND zbukr          = tabla_00-zbukr
         AND lifnr          = tabla_00-lifnr
         AND kunnr          = tabla_00-kunnr
         AND empfg          = tabla_00-empfg
         AND vblnr          = tabla_00-vblnr.
    ENDIF.

  ENDLOOP.                                                  " tabla_00
*-----------------------------------------------------------------------------
*  DESBLOQUEO DE REGISTRO SOCIEDAD BANCO EN ARCHIVO DE FOLIOS
*-----------------------------------------------------------------------------
  CALL FUNCTION 'DEQUEUE_EZ_ZFOLIO_PAGBCO'
    EXPORTING
      mode_zfolio_pagobanco = 'E'
      mandt                 = sy-mandt
      bukrs                 = tabla_00-zbukr
      ubnkl                 = tabla_00-ubnkl
      codigo                = '001'.
*-----------------------------------------------------------------------------
* ASIGNA ARCHIVO DE RESULTADOS AL INDICADO EN PARAMETRO
*-----------------------------------------------------------------------------
  filesalida[] = file[].
ENDFUNCTION.
