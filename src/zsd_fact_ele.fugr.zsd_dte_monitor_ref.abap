FUNCTION ZSD_DTE_MONITOR_REF.
*"----------------------------------------------------------------------
*"*"Interfase local
*"  IMPORTING
*"     REFERENCE(IM_RUTEMISOR) TYPE  ZDTE_DOC_REC_REF-RUTEMISOR
*"     REFERENCE(IM_FOLIO) TYPE  ZDTE_DOC_REC_REF-FOLIO
*"     REFERENCE(IM_TIPODTE) TYPE  ZDTE_DOC_REC_REF-TIPODTE
*"----------------------------------------------------------------------
clear gt_ref[].

* BEGIN. 07-07-2026 - ATC - ATC-03
* OLD CODE
*select * into TABLE gt_ref from ZDTE_DOC_REC_REF
*                                   WHERE tipodte = im_tipodte AND
*                                         rutemisor = im_rutemisor and
*                                         folio = im_folio.
*
* NEW CODE
SELECT *
 into TABLE gt_ref from ZDTE_DOC_REC_REF
                                   WHERE tipodte = im_tipodte AND
                                         rutemisor = im_rutemisor and
                                         folio = im_folio ORDER BY PRIMARY KEY.

* END. 07-07-2026 - ATC - ATC-03

call SCREEN 0050 STARTING AT 1 5 ENDING AT 125 20.
ENDFUNCTION.
