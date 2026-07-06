*$*$********************************************************************
*$*$                                                                   *
*$*$ PROGRAMAM  : ZZFIMOD_EMIS4                                        *
*$*$ DESCRIPCION: Programa que modifica Campo BSEG-ZZMOT_EMIS          *
*$*$              En los pagos masivos con Via de Pago V o T, el campo *
*$*$              T_BSEG-ZZMOT_EMIS no se llena en el Documento¨de     *
*$*$              pago, para lo cual este programa busca la Factura y  *
*$*$              saca el contenido de este campo y lo traslada al pago*
*$*$              COPIA DEL PROGRAMA ZFIMOD_EMIS1                      *
*$*$                                                                   *
*$*$ AUTOR      : Waldo Alarcón - VisioOne.                            *
*$*$                                                                   *
*$*$ DATA    : 29/06/2020.                                             *
*$*$                                                                   *
*$*$********************************************************************
*$*$                   HISTORIAL DE MODIFICACIONES                     *
*$*$-------------------------------------------------------------------*
*$*$ DATA     | AUTOR          | DESCRIPCION                           *
*$*$-------------------------------------------------------------------*
*$*$          |                |                                       *
*$*$          |                |                                       *
*$*$-------------------------------------------------------------------*
*$*$********************************************************************
REPORT  zfimod_emis4 MESSAGE-ID fs
                     NO STANDARD PAGE HEADING LINE-SIZE 132.


INCLUDE zfimod_emis4_top.   "Declaraciones globales
INCLUDE zfimod_emis4_sel.   "Pantalla de selección
INCLUDE zfimod_emis4_f01.   "Rutinas locales
INCLUDE zfimod_emis4_cla.   "Clases locales
INCLUDE ff05lcdc.           "Contiene el form cd_call_beleg


*----------------------------------------------------------------------*
*                          BEGIN
*----------------------------------------------------------------------*
START-OF-SELECTION.

  DATA(go_motor) = NEW lcl_motor( ).

* Obtiene los documentos de la clase seleccionada sin motivo de emisión
  go_motor->get_docs( IMPORTING et_bkpf = gt_bkpf
                                et_bseg = gt_bseg
  ).

  IF gt_bkpf[] IS INITIAL.
*   No se encontraron documentos a tratar.
    MESSAGE i008(Z001).
    EXIT.
  ENDIF.

* Proceso de actualización de los documentos
  go_motor->process_docs( EXPORTING it_bkpf = gt_bkpf
                                    it_bseg = gt_bseg
  ).

* Mostrar log
  go_motor->show_log( ).
