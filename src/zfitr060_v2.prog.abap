*&---------------------------------------------------------------------*
*& Report: ZFITR060_V2
*&---------------------------------------------------------------------*
*& Para ingresar directo NOVEDAD a ZNOVEDADBCO
*&*&-------------------------------------------------------------------*
* Modificaciones:
* Descripción : Almacenar Logs de acciones y crear, modificar o eliminar
*               registros en la tabla ZNOVEDADBANCO.
* Autor       : Waldo Alarcón - Visionone
* Fecha       : 13-11-2020
*----------------------------------------------------------------------*
*& Es copia del ZFITR060
* Autor       : V1-CNN
* Fecha       : 10-05-2024
* Autor       : V1-RVY
* Fecha       : 01-04-2025
*----------------------------------------------------------------------*
REPORT zfitr060_v2 MESSAGE-ID zfi.

TABLES: znovedadbanco.

TYPES: gty_rut TYPE c LENGTH 10.

TYPES: BEGIN OF gty_reguh,
         identif_pago TYPE ze_identif_pago,
         laufd        TYPE laufd,
         laufi        TYPE laufi,
         zbukr        TYPE dzbukr,
         name1        TYPE name1_gp,
         rbetr        TYPE rbetr,
         waers        TYPE waers,
         glosa_redepo TYPE ze_glosa_redepo,
         ind_custodia TYPE ze_ind_custodia,
         ind_pago     TYPE ze_ind_pago,
         belnr_dev    TYPE ze_belnr_dev,
         stcd1        TYPE stcd1,
       END OF gty_reguh.

TYPES: gtt_reguh TYPE STANDARD TABLE OF gty_reguh.

DATA: gs_znovedad_old      TYPE znovedadbanco,
      gs_znovedadbanco_est TYPE znovedadbanco,
      gs_log_noved         TYPE zlog_novedades.

DATA: gt_reguh     TYPE gtt_reguh,
      gt_znovedad  TYPE TABLE OF znovedadbanco,
      gt_itab      TYPE TABLE OF sy-ucomm,
      gt_log_noved TYPE TABLE OF zlog_novedades.

DATA: gv_subrc  TYPE sy-subrc,
      gv_rut    TYPE gty_rut,
      gv_mod    TYPE xflag,
      gv_titulo TYPE text50,
      gv_repid  TYPE syrepid,
      gv_lines  TYPE sytabix,
      gv_tot    TYPE rbetr.


INCLUDE zfitr060_v2_sel.   "Pantalla de selección
INCLUDE zfitr060_v2_f01.   "Rutinas de programa


*--------------------------------------------------------------------*
*          START-OF-SELECTION
*--------------------------------------------------------------------*
START-OF-SELECTION.

* Obtiene información de la sociedad
  PERFORM get_rut_soc USING p_bukrs
                            gv_rut.

* Obtener datos de los pagos
  PERFORM get_reguh TABLES gt_reguh.

  IF sy-subrc = 0.
    CLEAR: gv_lines, gv_tot.
    PERFORM proceso TABLES gt_reguh.
  ELSE.
*   No se encontraron registros para los identificadores ingresados
    MESSAGE e021(zfi).
  ENDIF.


*&---------------------------------------------------------------------*
*&      Form  PROCESO
*&---------------------------------------------------------------------*
FORM proceso  TABLES it_reguh TYPE gtt_reguh.

  DATA: lv_rut    TYPE c LENGTH 9,
        lv_num    TYPE c LENGTH 8,
        lv_num_n  TYPE n LENGTH 9,
        lv_dv     TYPE c LENGTH 1,
        lv_veces  TYPE i,
        lv_hornul TYPE tims,
        lv_fecnul TYPE dats,
        lv_lote   TYPE n LENGTH 3,
        lv_lin_t  TYPE c LENGTH 3,
        lv_tot_t  TYPE c LENGTH 15.

* Obtener primer número de lote
  SELECT SINGLE FROM zfolio_soc02 FIELDS folsoc02
    WHERE bukrs = @p_bukrs
      AND fecha = @sy-datum
    INTO @lv_lote.
  IF sy-subrc <> 0.
    lv_lote = 0.
  ENDIF.

* V1 RVY 01-04-2025
  lv_lote = lv_lote + 1.
*
***
  LOOP AT it_reguh ASSIGNING FIELD-SYMBOL(<fs_reguh>).

    CLEAR: gs_znovedad_old, gs_znovedadbanco_est,
           gt_znovedad[], gt_itab[], gt_log_noved[],
           lv_num, lv_dv, lv_veces, gv_mod, gv_titulo.

    SPLIT <fs_reguh>-stcd1 AT '-' INTO lv_num lv_dv.
    lv_num_n = lv_num.
    lv_rut = |{ lv_num_n+1(8) }{ lv_dv }|.

    SELECT FROM znovedadbanco FIELDS *
      WHERE sociedad  = @p_bukrs
        AND identif   = @<fs_reguh>-identif_pago
        AND rutben    = @lv_rut
        AND ( estpag  = 'CHEQUE PAGADO' OR estpag   EQ 'CHEQUE DEVUELTO' )
        AND estado   <> '9'
      INTO TABLE @gt_znovedad.

*   Si no encuentra
    IF gt_znovedad[] IS INITIAL.                           "(1)
      SELECT COUNT( * ) INTO @DATA(lv_error)
        FROM znovedadbanco
        WHERE sociedad  = @p_bukrs
          AND identif   = @<fs_reguh>-identif_pago
          AND rutben    = @lv_rut
          AND estpag    = 'VALE VISTA REINTEGRAD'
          AND estado   <> '0'.

      IF lv_error > 0.
        MESSAGE i004(zfi) WITH TEXT-e01 TEXT-e02 'VALE VISTA REINTEGRAD'.
      ENDIF.

      IF lv_error IS INITIAL.
*       Verifica en la tabla de novedades si existen registros para la selección indicada
        SELECT COUNT( * ) INTO @lv_veces
          FROM znovedadbanco
          WHERE sociedad = @p_bukrs
            AND identif  = @<fs_reguh>-identif_pago
            AND rutben   = @lv_rut
            AND estado   = 0.
      ENDIF.
    ENDIF.                                                 "(1)
*
    IF lv_veces > 0.                                       "(2)
      gv_mod = 'X'.
      APPEND 'GRABAR' TO gt_itab.
      gv_titulo = TEXT-ti1.
*
      SELECT FROM znovedadbanco FIELDS *
        WHERE sociedad = @p_bukrs
          AND identif  = @<fs_reguh>-identif_pago
          AND rutben   = @lv_rut
          AND estado   = 0
        INTO TABLE @gt_znovedad.

      IF lv_veces > 1.
        PERFORM muestra_datos.
      ELSE.
        gs_znovedad_old = gs_znovedadbanco_est = gt_znovedad[ 1 ].
        CALL SCREEN 200 STARTING AT 20 05 ENDING AT 130 25.
      ENDIF.

    ELSEIF lv_error IS INITIAL.                             "(2)
*     Si existen datos leidos prepara un log con la informacion del documento de origen
*     y le cambia es estado a "9".
      IF NOT gt_znovedad[] IS INITIAL.                      "(3)
        LOOP AT gt_znovedad ASSIGNING FIELD-SYMBOL(<lw_znovedad>).
*         Prepara datos para el LOG de la modificación
          MOVE-CORRESPONDING <lw_znovedad> TO gs_log_noved.
          MOVE: sy-datum                   TO gs_log_noved-fecha_mod,
                sy-uzeit                   TO gs_log_noved-hora_mod,
                sy-uname                   TO gs_log_noved-usuario_mod,
                'U'                        TO gs_log_noved-clase_mod.
          APPEND gs_log_noved TO gt_log_noved.
*         Modifica el estado el dpcumento que se esta actualizando
          <lw_znovedad>-estado = '9'.
          WAIT UP TO 1 SECONDS.
        ENDLOOP.

        gv_titulo = TEXT-ti2.
        APPEND 'MODIFICAR' TO gt_itab.
        APPEND 'BORRAR'    TO gt_itab.

        gs_znovedadbanco_est-sociedad = p_bukrs.
        gs_znovedadbanco_est-banco    = '037'.
        gs_znovedadbanco_est-nomina   = '0' && sy-datum && sy-uzeit.
        gs_znovedadbanco_est-fecha    = p_fecha.
        gs_znovedadbanco_est-hora     = sy-uzeit.
        gs_znovedadbanco_est-identif  = <fs_reguh>-identif_pago.
        gs_znovedadbanco_est-numemp   = gv_rut.
        gs_znovedadbanco_est-rutemi   = gv_rut+1(9).
        gs_znovedadbanco_est-cuenta   = <lw_znovedad>-cuenta.
        gs_znovedadbanco_est-fecpro   = sy-datum.
        gs_znovedadbanco_est-nomben   = <fs_reguh>-name1.
        gs_znovedadbanco_est-rutben   = lv_rut.
        gs_znovedadbanco_est-montow   = <fs_reguh>-rbetr * -100.
        gs_znovedadbanco_est-numche   = '000000000'.
        "gs_znovedadbanco_est-estpag   = 'VALE VISTA REINTEGRAD'.  16.10.2025
        gs_znovedadbanco_est-estpag   = 'CHEQUE DEVUELTO'.         "16.10.2025
        gs_znovedadbanco_est-cenpag   = 0.
        gs_znovedadbanco_est-fecrec   = sy-datum.
* V1 RVY 01-04-2025
*        lv_lote = lv_lote + 1.
        gs_znovedadbanco_est-numlot   = lv_lote.
        gs_znovedadbanco_est-fecpro   = sy-datum.
        gs_znovedadbanco_est-fecpag   = <lw_znovedad>-fecpag.
        gs_znovedadbanco_est-fecest   = sy-datum.
        gs_znovedadbanco_est-estado   = 0.
        gs_znovedadbanco_est-moteli   = ''.
        gs_znovedadbanco_est-feceli   = lv_fecnul.
        gs_znovedadbanco_est-horeli   = lv_hornul.
        gs_znovedadbanco_est-usreli   = ''.
        gs_znovedadbanco_est-ingres   = 'MANUAL'.

        CALL SCREEN 200 STARTING AT 20 05 ENDING AT 130 25.
      ELSE.                                                "(3)
        MESSAGE i004(zfi) WITH TEXT-e03 .
      ENDIF.                                               "(3)
    ENDIF.                                                 "(2)
  ENDLOOP.
***

* Mostrar resumen
  WRITE gv_lines TO lv_lin_t NO-SIGN LEFT-JUSTIFIED.
  WRITE: gv_tot TO lv_tot_t NO-SIGN RIGHT-JUSTIFIED DECIMALS 0.

  WRITE: /01 'Total de registros procesados: ', lv_lin_t,
         /01 'Monto total: ', lv_tot_t.

ENDFORM.
