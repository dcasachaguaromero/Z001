*&---------------------------------------------------------------------*
*& Report ZFI_CRE_ABONOS_TBK
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Compañía   : HELP
*& Autor      : Vision One # CNN
*& Fecha      : 10.10.2024
*& Objetivo   : Creación comprobantes de compensación abonos Transbank
*&              Transacción ZFI_CCCAT
*&---------------------------------------------------------------------
*&                       MODIFICACIONES
*&---------------------------------------------------------------------
*& Modificó   :
*& Fecha      :
*& Solicitó   :
*& Transporte :
*& Objetivo   :
*&---------------------------------------------------------------------
REPORT zfi_cre_abonos_tbk MESSAGE-ID zfi NO STANDARD PAGE HEADING.

INCLUDE zfi_cre_abonos_tbk_top.  "Declaraciones globales
INCLUDE zfi_cre_abonos_tbk_sel.  "Pantalla de inicio
INCLUDE zfi_cre_abonos_tbk_cla.  "Clases
INCLUDE zfi_cre_abonos_tbk_f01.  "Rutinas locales

*--------------------------------------------------------------------*
*                     BEGIN
*--------------------------------------------------------------------*
START-OF-SELECTION.

  DATA(go_app) = NEW lcl_app( ).

* Busca partidas abiertas de cuentas de mayor a fecha de corte
  go_app->get_data( ).

  IF go_app->gt_bsis IS INITIAL.
*   No se han seleccionado registros a procesar
    MESSAGE i034.
    EXIT.
  ENDIF.

* Determina asientos con textos repetidos
  go_app->det_repe( ).

  IF go_app->gt_data IS INITIAL.
*   No se encontraron documentos con textos repetidos
*   MESSAGE i025.
    EXIT.
  ENDIF.

* Contabiliza documentos repetidos
  go_app->do_conta( ).

* Log de ejecución
  go_app->show_log( ).
