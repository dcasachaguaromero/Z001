*&---------------------------------------------------------------------*
*& Report  ZCHECKNUMCORE
*&---------------------------------------------------------------------*
*& Autor : Julio Sosa
*& Empresa : Visionone
*& Transacción : ZCHECKNUMCORE
*& Fecha : 05.11.2014
*& Descripcion: Actualiza campo ZNUM_cod_core de tabla VBRK a partir de
*&              la tabla zcabpedext.
*&
*&---------------------------------------------------------------------*
*& Historial de Modificaciones :
*&
*& Autor :
*& Empresa :
*& Fecha :
*& Descripcion:
*&---------------------------------------------------------------------*

REPORT zchecknumcore.
*
TABLES vbrk.
*
TABLES zcabpedext.
*
DATA wk_Reg_lei TYPE i.
DATA wk_Reg_act TYPE i.
*
*DATA: BEGIN OF tab_zcabpedext OCCURS 0,
*       factura       LIKE zcabpedext-factura,
*       znum_doc_core LIKE zcabpedext-znum_doc_core,
*      END OF tab_zcabpedext.
DATA STR_AWKEY TYPE STRING.
TYPES BEGIN OF TY.
        INCLUDE STRUCTURE ZSTR_MON_FAC.
TYPES END OF TY.
DATA tab_zCABPEDEXT TYPE STANDARD TABLE OF TY WITH HEADER LINE.
*
*
START-OF-SELECTION.
* BEGIN. 07-07-2026 - ATC - ATC-03
* OLD CODE
*   SELECT * FROM ZCABPEDEXT
*          WHERE  FACTURA  NE SPACE.
*
* NEW CODE
   SELECT *
 FROM ZCABPEDEXT
          WHERE  FACTURA  NE SPACE ORDER BY PRIMARY KEY.

* END. 07-07-2026 - ATC - ATC-03
    MOVE-CORRESPONDING ZCABPEDEXT TO tab_zCABPEDEXT.
    APPEND tab_zCABPEDEXT.
  ENDSELECT.
*
*
   LOOP AT tab_ZCABPEDEXT.
*
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*      SELECT SINGLE * FROM VBRK
*             WHERE vbeln EQ zcabpedext-factura.
*
* NEW CODE
      SELECT *
      UP TO 1 ROWS  FROM VBRK
             WHERE vbeln EQ zcabpedext-factura ORDER BY PRIMARY KEY.

      ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
      IF sy-subrc = 0.
        add 1 to wk_reg_lei.
        if vbrk-znum_doc_core is initial.
           vbrk-znum_doc_core = zcabpedext-znum_doc_core.
           write: 'factura: ', vbrk-vbeln, ' actualizada'.
           update vbrk.
           add 1 to wk_reg_act.
        endif.
      endif.
   endloop.
   write: ' '.
   write: 'Registros leidos:      ', wk_Reg_lei.
   write: 'Registros modificados: ', wk_reg_act.
*
