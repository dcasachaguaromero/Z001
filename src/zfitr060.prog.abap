*&---------------------------------------------------------------------*
*& Report        ZFITR060
*&
*&---------------------------------------------------------------------*
*&  Para ingresar directo NOVEDAD a ZNOVEDADBCO
*&*&-------------------------------------------------------------------*
* Modificaciones:
* Descripción : Almacenar Logs de acciones y crear,modificar o eliminar
*               registros en la tabla ZNOVEDADBANCO.
* Autor       : Waldo Alarcón - Visionone
* Fecha       : 13-11-2020
*----------------------------------------------------------------------*
PROGRAM  zfitr060 MESSAGE-ID zfi.


TABLES: reguh, znovedadbanco.
DATA : int_tabla         TYPE znovedadbanco.
DATA : znovedadbanco_est TYPE znovedadbanco.

DATA: v_rut(10)    TYPE c,
      v_rut15(15)  TYPE c  VALUE '000000000000000',
      f_rut(10)    TYPE c,
      f_rut1(09)   TYPE c,
      f_rut2(09)   TYPE c,
      numero(9)    TYPE n,
      numero11(11) TYPE n,
      numero14(14) TYPE n,
      num_c(8)     TYPE c,
      hornul       TYPE tims,
      fecnul       TYPE dats,
      dv,
      veces(3)     TYPE n,
      v_adrnr      TYPE adrc-addrnumber,
      ti_adrc      TYPE adrc       OCCURS 0 WITH HEADER LINE.

* ini - Waldo Alarcón - Visionone - 17-11-2020
DATA : gt_log_noved    TYPE TABLE OF zlog_novedades,
       gt_znovedad     TYPE TABLE OF znovedadbanco,
       gt_itab         TYPE TABLE OF sy-ucomm,
       wa_log_noved    TYPE zlog_novedades,
       wa_znovedad_old TYPE znovedadbanco,
       gv_titulo       TYPE text50,
       gv_repid        TYPE syrepid,
       gv_mod          TYPE xflag.
* fin - Waldo Alarcón - Visionone - 17-11-2020

PARAMETER : bukrs    LIKE bkpf-bukrs             OBLIGATORY .
PARAMETER : idpago   LIKE znovedadbanco-identif  OBLIGATORY .
PARAMETER : rutben   LIKE reguh-stcd1            OBLIGATORY .
PARAMETER : fecha    LIKE sy-datum               DEFAULT sy-datum.

INITIALIZATION.
  CLEAR : bukrs, idpago, rutben.

AT SELECTION-SCREEN ON  idpago.
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*  SELECT SINGLE * FROM reguh
*            WHERE identif_pago = idpago.
*
* NEW CODE
  SELECT *
  UP TO 1 ROWS  FROM reguh
            WHERE identif_pago = idpago ORDER BY PRIMARY KEY.

  ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01

  IF sy-subrc <> 0.
    MESSAGE e004(zfi) WITH 'ID de pago no existe en Pagos'.
  ELSE.
    IF idpago+0(4) <> bukrs.
      MESSAGE e004(zfi) WITH 'ID de pago no corresponde a sociedad'.
    ENDIF.
  ENDIF.

  IF idpago+4(3) <> '037'.
    MESSAGE e004(zfi) WITH 'ID de pago no es de SANTANDER'.
  ENDIF.

  IF reguh-rzawe <> 'V'.
    MESSAGE e004(zfi) WITH 'ID de pago no corresponde a Vale Vista'.
  ENDIF.
  v_rut = reguh-stcd1.

  IF v_rut IS NOT INITIAL.
    SPLIT v_rut AT '-' INTO num_c dv.
    numero = num_c.
    CONCATENATE numero+1(8) dv INTO f_rut1.
  ENDIF.

AT SELECTION-SCREEN ON  rutben.
  v_rut = rutben.

  IF v_rut IS NOT INITIAL.
    SPLIT v_rut AT '-' INTO num_c dv.
    numero = num_c.
    CONCATENATE numero+1(8) dv INTO f_rut2.
  ENDIF.

  IF f_rut1 <> f_rut2.
    MESSAGE e004(zfi) WITH 'RUT ingresado no corresponde al pago'.
  ENDIF.

  INCLUDE zfitr060_f02.

START-OF-SELECTION.

  CLEAR : v_rut.
* OBTIENE INFORMACION DE LA SOCIEDAD
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*  SELECT SINGLE adrnr
*              FROM t001
*              INTO v_adrnr
*              WHERE bukrs EQ bukrs.
*
* NEW CODE
  SELECT adrnr
  UP TO 1 ROWS 
              FROM t001
              INTO v_adrnr
              WHERE bukrs EQ bukrs ORDER BY PRIMARY KEY.

  ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
  IF sy-subrc EQ 0 AND v_adrnr IS NOT INITIAL.
    CALL FUNCTION 'RTP_US_DB_ADRC_READ'
      EXPORTING
        i_address_number = v_adrnr
      IMPORTING
        e_adrc           = ti_adrc
      EXCEPTIONS
        not_found        = 1
        OTHERS           = 2.
    v_rut = ti_adrc-sort1.
  ENDIF.
* SI SE TIENE EL RUT DE LA SOCIEDAD
  IF v_rut IS NOT INITIAL.
    SPLIT v_rut AT '-' INTO num_c dv.
    numero = num_c.
    CONCATENATE numero dv INTO f_rut.
  ENDIF.
*
  CLEAR : veces, gv_mod,
          gt_znovedad[], gt_log_noved[], gt_itab[].
* ini - Waldo Alarcón - Visionone - 17-11-2020
* BEGIN. 07-07-2026 - ATC - ATC-03
* OLD CODE
*  SELECT * INTO TABLE gt_znovedad
*     FROM znovedadbanco
*           WHERE sociedad EQ bukrs
*             AND identif  EQ idpago
*             AND rutben   EQ f_rut2
*             AND ( estpag   EQ 'CHEQUE PAGADO' OR
*                   estpag   EQ 'CHEQUE DEVUELTO' )
*             AND estado   NE '9'.
*
* NEW CODE
  SELECT *
 INTO TABLE gt_znovedad
     FROM znovedadbanco
           WHERE sociedad EQ bukrs
             AND identif  EQ idpago
             AND rutben   EQ f_rut2
             AND ( estpag   EQ 'CHEQUE PAGADO' OR
                   estpag   EQ 'CHEQUE DEVUELTO' )
             AND estado   NE '9' ORDER BY PRIMARY KEY.

* END. 07-07-2026 - ATC - ATC-03
* si no encuentra
  IF gt_znovedad[] IS INITIAL.

    SELECT COUNT( * ) INTO @DATA(lv_error)
       FROM znovedadbanco
             WHERE sociedad EQ @bukrs
               AND identif  EQ @idpago
               AND rutben   EQ @f_rut2
               AND estpag   EQ 'VALE VISTA REINTEGRAD'
               AND estado   NE '0'.
*                 AND ingres   NE 'MANUAL'.
    IF lv_error GT 0.
      MESSAGE i004(zfi) WITH TEXT-e01 TEXT-e02 'VALE VISTA REINTEGRAD'.
    ENDIF.
* fin - Waldo Alarcón - Visionone - 17-11-2020
*
    IF lv_error IS INITIAL.
* VERIFICA EN LA TABLA DE NOVEDADES SI EXISTEN REGISTROS PARA LA SELECCION INGRESADA
      SELECT COUNT( * ) INTO veces
         FROM znovedadbanco
               WHERE sociedad = bukrs
                 AND identif  = idpago
                 AND rutben   = f_rut2
                 AND estado   = 0.
    ENDIF.
  ENDIF.
*
  IF veces > 0.
* ini - Waldo Alarcón - Visionone - 17-11-2020
    gv_mod = 'X'.
    APPEND 'GRABAR' TO gt_itab.
    gv_titulo = TEXT-ti1.
*
* BEGIN. 07-07-2026 - ATC - ATC-03
* OLD CODE
*    SELECT *  INTO TABLE gt_znovedad
*       FROM znovedadbanco
*             WHERE sociedad = bukrs
*               AND identif  = idpago
*               AND rutben   = f_rut2
*               AND estado   = 0.
*
* NEW CODE
    SELECT *
  INTO TABLE gt_znovedad
       FROM znovedadbanco
             WHERE sociedad = bukrs
               AND identif  = idpago
               AND rutben   = f_rut2
               AND estado   = 0 ORDER BY PRIMARY KEY.

* END. 07-07-2026 - ATC - ATC-03
    IF veces GT 1.
      PERFORM muestra_datos.
    ELSE.
      wa_znovedad_old = znovedadbanco_est = gt_znovedad[ 1 ].
      CALL SCREEN 200 STARTING AT 20 05 ENDING AT 130 25.
    ENDIF.
* fin - Waldo Alarcón - Visionone - 17-11-2020
  ELSEIF lv_error IS INITIAL.
*
* ini - Waldo Alarcón - Visionone - 17-11-2020
* si existen datos leidos prepara un log con la informacion del documento de origen
* y le cambia es estado a "9".
    IF gt_znovedad[] IS NOT INITIAL.
      LOOP AT gt_znovedad ASSIGNING FIELD-SYMBOL(<lw_znovedad>).
* prepara datos para el LOG de lamodificacion
        MOVE-CORRESPONDING <lw_znovedad> TO wa_log_noved.
        MOVE: sy-datum                   TO wa_log_noved-fecha_mod,
              sy-uzeit                   TO wa_log_noved-hora_mod,
              sy-uname                   TO wa_log_noved-usuario_mod,
              'U'                        TO wa_log_noved-clase_mod.
        APPEND wa_log_noved TO gt_log_noved.
* modifica el estado el dpcumento que se esta actualizando
        <lw_znovedad>-estado = '9'.
        WAIT UP TO 1 SECONDS.
      ENDLOOP.
*
      gv_titulo = TEXT-ti2.
      APPEND 'MODIFICAR' TO gt_itab.
      APPEND 'BORRAR'    TO gt_itab.
* fin - Waldo Alarcón - Visionone - 17-11-2020

      znovedadbanco_est-sociedad = bukrs.
      znovedadbanco_est-banco    = '037'.
*    CONCATENATE '0' sy-datum+0(4) sy-datum+4(2) sy-datum+6(2) sy-uzeit+0(2) sy-uzeit+2(2) sy-uzeit+4(2) INTO znovedadbanco_est-nomina.
      znovedadbanco_est-nomina   = '0' && sy-datum && sy-uzeit.
      znovedadbanco_est-fecha    = fecha.
      znovedadbanco_est-hora     = sy-uzeit.
      znovedadbanco_est-identif  = idpago.
      znovedadbanco_est-numemp   = f_rut.
      znovedadbanco_est-rutemi   = f_rut+1(9).
      znovedadbanco_est-cuenta   = <lw_znovedad>-cuenta. "reguh-ubknt. Waldo Alarcón - Visionone - 17-11-2020
      znovedadbanco_est-fecpro   = sy-datum.
      znovedadbanco_est-nomben   = reguh-name1.
      znovedadbanco_est-rutben   = f_rut1.
      znovedadbanco_est-montow   = reguh-rbetr * -100.
      znovedadbanco_est-numche   = '000000000'.
      znovedadbanco_est-estpag   = 'VALE VISTA REINTEGRAD'.
      znovedadbanco_est-cenpag   = 0.
      znovedadbanco_est-fecrec   = sy-datum.
      znovedadbanco_est-numlot   = <lw_znovedad>-numlot. "0. Waldo Alarcón - Visionone - 17-11-2020
      znovedadbanco_est-fecpro   = sy-datum.
      znovedadbanco_est-fecpag   = <lw_znovedad>-fecpag. " reguh-laufd.  Waldo Alarcón - Visionone - 17-11-2020
      znovedadbanco_est-fecest   = sy-datum.
      znovedadbanco_est-estado   = 0.
      znovedadbanco_est-moteli   = ''.
      znovedadbanco_est-feceli   = fecnul.
      znovedadbanco_est-horeli   = hornul.
      znovedadbanco_est-usreli   = ''.
      znovedadbanco_est-ingres   = 'MANUAL'.
      CALL SCREEN 200 STARTING AT 20 05 ENDING AT 130 25.
    ELSE.
      MESSAGE i004(zfi) WITH TEXT-e03 .
    ENDIF.
  ENDIF.

END-OF-SELECTION.
  FREE MEMORY.
  CLEAR : bukrs, idpago, rutben.
