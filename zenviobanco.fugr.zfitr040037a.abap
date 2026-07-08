*&---------------------------------------------------------------------*
*& Report: < ZEY_GDS_CORRECTION > *
*& Author: < EY_DES01 > *
*& Description: < ReSQ Correction > *
*& Date: <19-12-2019> *
*& Transport Number: < ECDK917080 > *
*&---------------------------------------------------------------------*
FUNCTION zfitr040037a.
*"----------------------------------------------------------------------
*"*"Interfase local
*"  IMPORTING
*"     REFERENCE(SOC) TYPE  BUKRS
*"     REFERENCE(BANCO) TYPE  UBNKL
*"     REFERENCE(NOM) TYPE  NUM15
*"     REFERENCE(P_FECHA) TYPE  SYDATUM
*"  EXPORTING
*"     REFERENCE(MEN) TYPE  CHAR30
*"----------------------------------------------------------------------
*&---------------------------------------------------------------------*
*& ZFITR040037A
*&---------------------------------------------------------------------*
*&  Baja retorno de archivo de Novedades de Sociedad, Banco y Nomina
*&  ingresados por parámetros para banco SANTANDER (037)
*&---------------------------------------------------------------------*
  TYPE-POOLS: truxs.

  TABLES: zfimotemisan, zmot_emis.

  TYPES: BEGIN OF type_texto,
           todo(581) TYPE c,
         END OF type_texto.

  TYPES: BEGIN OF type_texto0,
           tipreg(1)  TYPE n,
           rutemp(11) TYPE n,
           dvemp(1)   TYPE c,
           nomemp(40) TYPE c,
           fecgen(8)  TYPE c,
           horgen(6)  TYPE c,
           tippag(2)  TYPE n,
         END OF type_texto0.

  TYPES: BEGIN OF type_texto1,
           tipreg(1)  TYPE n,
           numnom(3)  TYPE n,
           causal(2)  TYPE n,
           rutemp(11) TYPE n,
           dvemp(1)   TYPE c,
           nomemp(40) TYPE c,
           ctapag(18) TYPE n,
           ctarec(18) TYPE n,
           fecpag(10) TYPE c,
         END OF type_texto1.

  TYPES: BEGIN OF type_texto2,
           tipreg(1)  TYPE n,
           rutben(11) TYPE n,
           dvben(1)   TYPE c,
           nomben(40) TYPE c,
           modabo(2)  TYPE n,
           codsuc(3)  TYPE n,
           ctaabo(18) TYPE n,
           codban(4)  TYPE n,
           monpag(15) TYPE n,
           codest(3)  TYPE c,
           estado(45) TYPE c,
           codsap(40) TYPE c,
         END OF type_texto2.

  CONSTANTS: c_ext_exl   TYPE string     VALUE '*.TXT'.

  DATA: lt_filetable TYPE filetable,
        lx_filetable TYPE file_table,
        wl_sel_text  TYPE string,
        lv_rc        TYPE i.

  DATA:       it_raw   TYPE truxs_t_text_data.

  DATA:       t_exc    TYPE STANDARD TABLE OF   type_texto   WITH HEADER LINE.
  DATA:       t0_exc   TYPE STANDARD TABLE OF   type_texto0  WITH HEADER LINE.
  DATA:       t1_exc   TYPE STANDARD TABLE OF   type_texto1  WITH HEADER LINE.
  DATA:       t2_exc   TYPE STANDARD TABLE OF   type_texto2  WITH HEADER LINE.

  DATA: ruta(128),
        cia(4),
        fec           LIKE sy-datum,
        est           LIKE znovedadbanco-estado,
        cta(15)       TYPE p,
        rutcia(45),
        fecha(8),
        numero(8)     TYPE n,
        diascaduco(7) TYPE n,
        numlot(3)     TYPE n,
        num_c(8)      TYPE c,
        dv(1),
        nada(1),
        esterr(1),
        zzmot_emis    LIKE bseg-zzmot_emis,
        sumdif(5)     TYPE n,
        suma(15)      TYPE p,
        sumar(15)     TYPE p,
        nuevos(6)     TYPE p,
        idpagoe(6)    TYPE p,
        errtra(6)     TYPE p,
        errvvi(6)     TYPE p,
        estadoe(6)    TYPE p,
        estado8(6)    TYPE p,
        rechazo(6)    TYPE p,
        reg           TYPE znovedadbanco.

*  DELETE FROM znovedadbanco.
* INI - WALDO ALARCON - VISIONONE - 15-07-2022
  DATA lw_reguh TYPE reguh.
* INI - WALDO ALARCON - VISIONONE - 15-07-2022
*&---------------------------------------------------------------------*
* Buscar archivo a procesar
*----------------------------------------------------------------------*
  CLEAR ruta.
  wl_sel_text = TEXT-s01.
  CALL METHOD cl_gui_frontend_services=>file_open_dialog
    EXPORTING
      window_title            = wl_sel_text
      default_extension       = c_ext_exl
    CHANGING
      file_table              = lt_filetable
      rc                      = lv_rc
    EXCEPTIONS
      file_open_dialog_failed = 1
      cntl_error              = 2
      error_no_gui            = 3
      not_supported_by_gui    = 4
      OTHERS                  = 5.

  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
      WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ELSE.
*Begin of change: ReSQ Correction INDEX READ on an unsorted Internal TABLE 19/12/2019 EY_DES01 ECDK917080 *
    SORT lt_filetable .
*End of change: ReSQ Correction for INDEX READ on an unsorted Internal TABLE 19/12/2019 EY_DES01 ECDK917080 *
    READ TABLE lt_filetable INTO lx_filetable INDEX 1.
    CHECK sy-subrc EQ 0.
    ruta = lx_filetable-filename.
  ENDIF.
*&---------------------------------------------------------------------*
*&     Carga archivo seleccionado
*&---------------------------------------------------------------------*
*& Subir un archivo texto a una tabla interna
*&---------------------------------------------------------------------

  REFRESH: t_exc, t0_exc, t1_exc, t2_exc.

  CALL FUNCTION 'WS_UPLOAD'
    EXPORTING
      filename            = ruta
      filetype            = 'DAT'
    TABLES
      data_tab            = t_exc
    EXCEPTIONS
      conversion_error    = 1
      file_open_error     = 2
      file_read_error     = 3
      invalid_table_width = 4
      invalid_type        = 5
      no_batch            = 6
      unknown_error       = 7
      OTHERS              = 8.

  IF ( sy-subrc <> 0 ).
    MESSAGE TEXT-e02  TYPE 'I' DISPLAY LIKE 'E'.
  ELSE.
    LOOP AT t_exc.
      IF t_exc+0(1) = '0'.
        t0_exc = t_exc.
        APPEND t0_exc.
      ELSE.
        IF t_exc+0(1) = '1'.
          t1_exc = t_exc.
          APPEND t0_exc.
        ELSE.
          IF t_exc+0(1) = '2'.
            t2_exc = t_exc.
            APPEND  t2_exc.
          ENDIF.
        ENDIF.
      ENDIF.
    ENDLOOP.

    CLEAR rutcia.

    cia =  soc.

*Begin of change: ReSQ Correction INDEX READ on an unsorted Internal TABLE 19/12/2019 EY_DES01 ECDK917080 *
    SORT t0_exc .
*End of change: ReSQ Correction for INDEX READ on an unsorted Internal TABLE 19/12/2019 EY_DES01 ECDK917080 *
    READ TABLE t0_exc INDEX 1.
    CONCATENATE t0_exc-fecgen+0(4) t0_exc-fecgen+4(2) t0_exc-fecgen+6(2) INTO fecha.

* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*    SELECT SINGLE * FROM t001
*           WHERE bukrs = soc.
*
* NEW CODE
    SELECT *
    UP TO 1 ROWS  FROM t001
           WHERE bukrs = soc ORDER BY PRIMARY KEY.

    ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
    IF sy-subrc = 0.
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*      SELECT SINGLE * FROM adrc
*         WHERE addrnumber = t001-adrnr.
*
* NEW CODE
      SELECT *
      UP TO 1 ROWS  FROM adrc
         WHERE addrnumber = t001-adrnr ORDER BY PRIMARY KEY.

      ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
    ENDIF.
  ENDIF.
  IF adrc-sort1 IS NOT INITIAL.
    SPLIT adrc-sort1 AT '-' INTO num_c dv.
    numero = num_c.
    CONCATENATE numero dv INTO rutcia.
  ENDIF.
*&---------------------------------------------------------------------*
*&  Formatea archivo procesado
*&---------------------------------------------------------------------*
*Begin of change: ReSQ Correction INDEX READ on an unsorted Internal TABLE 19/12/2019 EY_DES01 ECDK917080 *
  SORT t2_exc .
*End of change: ReSQ Correction for INDEX READ on an unsorted Internal TABLE 19/12/2019 EY_DES01 ECDK917080 *
  READ TABLE t2_exc INDEX 1.

  IF ( sy-subrc = 0 ).
    IF t2_exc-codsap+4(3) <> banco.
      CONCATENATE 'Banco = ' nada  t2_exc-codsap+4(3) INTO men.
    ELSE.
      IF t2_exc-codsap+0(4) <> soc.
        CONCATENATE 'Sociedad = ' nada  t2_exc-codsap+0(4) INTO men.
      ENDIF.
    ENDIF.
  ENDIF.

  IF men = ' '.

*&-------------------------------------------------------------------*
*& ** BLOQUEO Y RECUPERACION DE FOLIO DE PROPUESTA POR SOCIEDAD-DIA
*&-------------------------------------------------------------------*
    CALL FUNCTION 'ENQUEUE_EZ_FOLIO_SOC02'
      EXPORTING
        mode_zfolio_soc02 = 'E'
        mandt             = sy-mandt
        bukrs             = soc
        fecha             = sy-datum
        _scope            = 1
      EXCEPTIONS
        foreign_lock      = 1
        system_failure    = 2
        OTHERS            = 3.

    WHILE sy-subrc <> 0.
      CALL FUNCTION 'ENQUEUE_EZ_FOLIO_SOC02' " se cambia ENQUEUE_EZ_FOLIO_SOC01 HCD 01-09-2020
        EXPORTING
          mode_zfolio_soc02 = 'E'
          mandt             = sy-mandt
          bukrs             = soc
          fecha             = sy-datum
          _scope            = 1
        EXCEPTIONS
          foreign_lock      = 1
          system_failure    = 2
          OTHERS            = 3.
    ENDWHILE.

*&----------------------------------------------------------------------------------------------------------------*

* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*    SELECT SINGLE *  FROM zfolio_soc02  WHERE bukrs  = soc
*                                          AND fecha  = sy-datum.
*
* NEW CODE
    SELECT *
    UP TO 1 ROWS   FROM zfolio_soc02  WHERE bukrs  = soc
                                          AND fecha  = sy-datum ORDER BY PRIMARY KEY.

    ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01

    IF sy-subrc <> 0.
      zfolio_soc02-bukrs = soc.
      zfolio_soc02-fecha = sy-datum.
      zfolio_soc02-folsoc02 = 0.
    ENDIF.

* USO E INCREMENTO
    zfolio_soc02-folsoc02 =  zfolio_soc02-folsoc02 + 1.
    MODIFY  zfolio_soc02.
    numlot = zfolio_soc02-folsoc02.


* DESBLOQUEO
    CALL FUNCTION 'DEQUEUE_EZ_FOLIO_SOC02'
      EXPORTING
        mode_zfolio_soc02 = 'E'
        mandt             = sy-mandt.

    LOOP AT t2_exc.
      znovedadbanco-sociedad  = soc.
      znovedadbanco-banco     = banco.
      znovedadbanco-identif   = t2_exc-codsap.
      znovedadbanco-fecha     = sy-datum.
      znovedadbanco-hora      = sy-uzeit.
      znovedadbanco-nomina    = nom.
      CONCATENATE t0_exc-rutemp+2(9) t0_exc-dvemp INTO znovedadbanco-numemp.
      CONCATENATE t0_exc-rutemp+3(8) t0_exc-dvemp INTO znovedadbanco-rutemi.
      znovedadbanco-cuenta    = t1_exc-ctapag+8(10).
      znovedadbanco-nomben    = t2_exc-nomben.
      CONCATENATE t2_exc-rutben+3(8) t2_exc-dvben INTO znovedadbanco-rutben.
      znovedadbanco-montow    = t2_exc-monpag / 100.
      znovedadbanco-numche    = '000000000'.

      TRANSLATE t2_exc-estado TO UPPER CASE.
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*      SELECT SINGLE * FROM zestadosbanco
*                     WHERE banco  = banco
*                       AND codban = t2_exc-codest.
*
* NEW CODE
      SELECT *
      UP TO 1 ROWS  FROM zestadosbanco
                     WHERE banco  = banco
                       AND codban = t2_exc-codest ORDER BY PRIMARY KEY.

      ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01

      IF sy-subrc = 0.
        znovedadbanco-estpag   = zestadosbanco-codint.
      ELSE.
        znovedadbanco-estpag   = t2_exc-estado.
      ENDIF.

      CLEAR esterr.
      CLEAR lw_reguh.

* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*      SELECT SINGLE * FROM reguh
*             WHERE identif_pago = t2_exc-codsap.
*
* NEW CODE
      SELECT *
      UP TO 1 ROWS  FROM reguh
             WHERE identif_pago = t2_exc-codsap ORDER BY PRIMARY KEY.

      ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
      IF sy-subrc  = 0.
* INI - WALDO ALARCON - VISIONONE - 15-07-2022
        lw_reguh = reguh.
* INI RVY 30.07.2025
        IF reguh-glosa_redepo EQ 'RETIRO POR UN 3ERO'.
           IF T2_EXC-ESTADO = 'ENTREGADO'.
              znovedadbanco-estpag   = 'ENTREGADO'.
           endif.
        endif.
* FIN RVY 30.07.2025
* INI - WALDO ALARCON - VISIONONE - 15-07-2022
*ResQ Comment:Correction not required as Select Single is used 19/12/2019 EY_DES01 ECDK917080 *
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*        SELECT SINGLE  * FROM  regup WHERE laufd = reguh-laufd
*                                       AND laufi = reguh-laufi
*                                       AND xvorl = reguh-xvorl
*                                       AND zbukr = reguh-zbukr
*                                       AND lifnr = reguh-lifnr
*                                       AND kunnr = reguh-kunnr
*                                       AND empfg = reguh-empfg
*                                       AND vblnr = reguh-vblnr.
*
* NEW CODE
        SELECT *
        UP TO 1 ROWS  FROM  regup WHERE laufd = reguh-laufd
                                       AND laufi = reguh-laufi
                                       AND xvorl = reguh-xvorl
                                       AND zbukr = reguh-zbukr
                                       AND lifnr = reguh-lifnr
                                       AND kunnr = reguh-kunnr
                                       AND empfg = reguh-empfg
                                       AND vblnr = reguh-vblnr ORDER BY PRIMARY KEY.

        ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01

* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*        SELECT SINGLE  * FROM  bseg  WHERE bukrs = regup-bukrs
*                                       AND belnr = regup-belnr
*                                       AND gjahr = regup-gjahr
*                                       AND buzei = regup-buzei.
*
* NEW CODE
        SELECT *
        UP TO 1 ROWS  FROM  bseg  WHERE bukrs = regup-bukrs
                                       AND belnr = regup-belnr
                                       AND gjahr = regup-gjahr
                                       AND buzei = regup-buzei ORDER BY PRIMARY KEY.

        ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01

        IF sy-subrc = 0.
          zzmot_emis = bseg-zzmot_emis.
        ENDIF.

* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*        SELECT SINGLE * FROM zmot_emis
*                       WHERE zzmot_emis = zzmot_emis.
*
* NEW CODE
        SELECT *
        UP TO 1 ROWS  FROM zmot_emis
                       WHERE zzmot_emis = zzmot_emis ORDER BY PRIMARY KEY.

        ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01

        IF reguh-rzawe = 'T'.
          IF t2_exc-codest = '002' OR t2_exc-codest = '004' OR t2_exc-codest = '117' OR t2_exc-codest = '117' OR t2_exc-codest = '118' OR t2_exc-codest = '119'
              OR t2_exc-codest = '120' OR t2_exc-codest = '121'.
            IF t2_exc-codest = '117'  OR t2_exc-codest = '118' OR t2_exc-codest = '119'
              OR t2_exc-codest = '120' OR t2_exc-codest = '121'.
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*              SELECT SINGLE * FROM zfimotemisan
*                    WHERE bukrs = soc
*                     AND zmotiv = zzmot_emis.
*
* NEW CODE
              SELECT *
              UP TO 1 ROWS  FROM zfimotemisan
                    WHERE bukrs = soc
                     AND zmotiv = zzmot_emis ORDER BY PRIMARY KEY.

              ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
              IF sy-subrc = 0.
                IF zfimotemisan-zaccion = 'P'.
                  znovedadbanco-estpag   = 'REDEPOSITO'.
                ELSE.
                  znovedadbanco-estpag   = 'VALE VISTA REINTEGRAD'.
                ENDIF.
              ENDIF.
            ENDIF.
          ELSE.
            esterr = 'X'.
            errtra = errtra + 1.
          ENDIF.
        ELSE.
          IF reguh-rzawe = 'V'.
            IF t2_exc-codest = '002' OR t2_exc-codest = '003' OR t2_exc-codest = '004' OR t2_exc-codest = '005'
               OR t2_exc-codest = '006' OR t2_exc-codest = '007'.
            ELSE.
              esterr = 'X'.
              errtra = errvvi + 1.
            ENDIF.
          ELSE.
            esterr = 'X'.
          ENDIF.
        ENDIF.
      ELSE.
        idpagoe = idpagoe + 1.
        esterr = 'X'.
      ENDIF.

      IF t2_exc-codest = '007' AND zmot_emis-maternal = 'X' AND reguh-rzawe = 'V'.
        znovedadbanco-vvmcad    = 'X'.
      ELSE.
        znovedadbanco-vvmcad    = ' '.
      ENDIF.

      znovedadbanco-cenpag    = '0000'.
      CONCATENATE t0_exc-fecgen+0(4) t0_exc-fecgen+4(2) t0_exc-fecgen+6(2) INTO znovedadbanco-fecrec.
      znovedadbanco-numlot    = numlot.
      znovedadbanco-fecpro    = sy-datum.
      CONCATENATE t1_exc-fecpag+0(4) t1_exc-fecpag+4(2) t1_exc-fecpag+6(2) INTO znovedadbanco-fecpag.
      znovedadbanco-fecest   = sy-datum.
      znovedadbanco-estado    = 0.

* ini Waldo Alarcón - Visionone - 05-10-2020
      IF p_fecha IS NOT INITIAL.
        znovedadbanco-fecest = p_fecha.
      ENDIF.
* fin Waldo Alarcón - Visionone - 05-10-2020

      reg = znovedadbanco.
      CLEAR fec.
      CLEAR est.


* ini Waldo Alarcón - Visionone - 06-01-2022
* Si la novedad no ha sido procesada, se encuentra en estado "cero"
* cambia a un estatus para dejar fuera del proceso, se marcara con “8”.
      SELECT * INTO TABLE @DATA(lt_novedad)
           FROM znovedadbanco WHERE sociedad = @reg-sociedad
                                AND banco    = @reg-banco
                                AND identif  = @reg-identif
                                AND estado   = '0'
                              ORDER BY  fecha DESCENDING,
                                        hora  DESCENDING.
      IF sy-subrc EQ 0.
        LOOP AT lt_novedad INTO DATA(lw_novedad).
          UPDATE znovedadbanco SET estado = '8'
                              WHERE sociedad = lw_novedad-sociedad
                                AND banco    = lw_novedad-banco
                                AND identif  = lw_novedad-identif
                                AND fecha    = lw_novedad-fecha
                                AND hora     = lw_novedad-hora.
        ENDLOOP.
        COMMIT WORK AND WAIT.
      ENDIF.
* fin Waldo Alarcón - Visionone - 06-01-2022

*      IF fec IS INITIAL.
      IF esterr <> 'X'.
        nuevos        = nuevos + 1.
        znovedadbanco = reg.
        INSERT znovedadbanco.
        suma          = suma +  znovedadbanco-montow.
      ELSE.
        estadoe = estadoe + 1.
        sumar   = sumar +  znovedadbanco-montow.
      ENDIF.

* INI - WALDO ALARCON - VISIONONE - 15-07-2022
      IF lw_reguh IS NOT INITIAL.
*V1 RVY 30-11-2024
         IF lw_reguh-glosa_redepo EQ 'RETIRO POR UN 3ERO'.
            IF znovedadbanco-estpag EQ 'PAGADO' OR
               znovedadbanco-estpag EQ 'CHEQUE PAGADO'.
               lw_reguh-ind_pago   = 'X'.
               lw_reguh-fecha_pago = znovedadbanco-fecpag.
               MODIFY reguh FROM lw_reguh.
            ELSE.
               IF znovedadbanco-estpag  EQ 'ENTREGADO'.
                  lw_reguh-ind_entregado = 'X'.
                  lw_reguh-fecha_entregado = znovedadbanco-fecpag.
                  MODIFY reguh FROM lw_reguh.
               endif.
            endif.
         ELSE.
            IF znovedadbanco-estpag  EQ 'PAGADO' OR
               znovedadbanco-estpag  EQ 'CHEQUE PAGADO' OR
               znovedadbanco-estpag  EQ 'ENTREGADO'.
               lw_reguh-ind_pago   = 'X'.
               lw_reguh-fecha_pago = znovedadbanco-fecpag.
               MODIFY reguh FROM lw_reguh.
            endif.
         ENDIF.
*V1 RVY 30.11-2024.
      ENDIF.
* INI - WALDO ALARCON - VISIONONE - 15-07-2022
*      ELSE.
*        IF est = 8.
*          estado8 = estado8 + 1.
*          znovedadbanco = reg.
*          INSERT znovedadbanco.
*          suma = suma +  znovedadbanco-montow.
*        ELSE.
*          rechazo = rechazo +  1.
*          sumar = sumar +  znovedadbanco-montow.
*        ENDIF.
*      ENDIF.
      cta = cta + 1.
    ENDLOOP.
*&---------------------------------------------------------------------*
*&  Despliega totales del resultado del proceso realizado -------------*
*&---------------------------------------------------------------------*
    WRITE:/ 'Sociedad                   ',  soc.
    WRITE:/ 'Banco                      ',  znovedadbanco-banco.
    WRITE:/ 'Nomina                     ',  znovedadbanco-nomina.
    WRITE:/ 'Registros procesados       ',  cta      DECIMALS 0.
    WRITE:/ 'Registros nuevos           ',  nuevos   DECIMALS 0.
    WRITE:/ 'Registros nulos antes      ',  estado8  DECIMALS 0.
    WRITE:/ 'Registros ID pago erroneo  ',  idpagoe  DECIMALS 0.
    WRITE:/ 'Estado erroneo  Transfers  ',  errtra   DECIMALS 0.
    WRITE:/ 'Estado erroneo  Vale Vista ',  errvvi   DECIMALS 0.
    WRITE:/ 'Suma de Montos grabados    ',  suma     DECIMALS 0.
  ENDIF.

ENDFUNCTION.
