*&---------------------------------------------------------------------*
*& Report  ZEXT_INF_CTA_CTE_CLI_BANMED
*&
*&---------------------------------------------------------------------*
*& Objtivo: Extrae Información Cta Cte Clientes Banmedica
*& Autor  : C.Muñoz.  (Visionone)
*& Fecha  : 21.11.2011
*&**********************************************************************
*& Modificaciones:
*&
*& Objetivo: Extrae los registros de la tabla BSAD con rangos de fecha,
*&           si la fecha inicial esta en blanco, solo en esta caso borrara
*&           la tabla SAPCTACTEBSAD.
*& Autor   : VisionOne
*& Fecha   : 09.05.2014
*&
*& Objetivo: Trasapasa num-doc-core a tablas ORACLE BSID y BSAD
*& Autor   : VisionOne
*& Fecha   : 04.07.2014
*&
*& Objetivo: Agregar el siguiente campo a estructura ZSAPCTACTEBSID
*&           BSEG-NEBTR: importe del pago al final.
*& Autor   : VisionOne
*& Fecha   : 02.02.2015
*&
*& Objetivo: Se toma el día del registro del documento contable para
*&           la selección de documentos / Genera arhivo de log
*& Autor   : VisionOne CNN
*& Fecha   : 18.06.2015
*&
*& Objetivo: se actualizan campos zz, como por ejemplo
*&           BSID-ZCOD_RECHAZO
*& Autor   : VisionOne RVY
*& Fecha   : 04.01.2016

*&---------------------------------------------------------------------*
REPORT zext_inf_cta_cte_cli_banmed LINE-SIZE 1023.

INCLUDE zeicccbm_top.
INCLUDE zeicccbm_scr.
INCLUDE zeicccbm_f01.

*--------------------------------------------------------------------*
* START-OF-SELECTION
*--------------------------------------------------------------------*
START-OF-SELECTION.

  IF p_pa = true.
    PERFORM obtain_bsid TABLES tmp_bsid.
  ENDIF.
  IF p_pc = true.
    PERFORM obtain_bsad TABLES tmp_bsad.
  ENDIF.

*--------------------------------------------------------------------*
* END-OF-SELECTION
*--------------------------------------------------------------------*
END-OF-SELECTION.

  PERFORM oracle.

  IF syst-batch = 'X'.
*-> BEG INS CNN 18.06.2015
    IF p_pc = true.
      PERFORM grabar_log.
    ENDIF.
*-> END INS CNN 18.06.2015
  ELSE.
    PERFORM alv.
  ENDIF.
