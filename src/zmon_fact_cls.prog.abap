*&---------------------------------------------------------------------*
*& Report: < ZEY_GDS_CORRECTION > *
*& Author: < EY_DES04 > *
*& Description: < ReSQ Correction > *
*& Date: <19-12-2019> *
*& Transport Number: < ECDK917080 > *
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&  Include           ZMON_FACT_CLS
*&---------------------------------------------------------------------*
CLASS CL_GUI_COLUMN_TREE DEFINITION LOAD.
CLASS CL_GUI_CFW DEFINITION LOAD.

*----------------------------------------------------------------------*
*       CLASS LCL_TREE_EVENT_RECEIVER DEFINITION
*----------------------------------------------------------------------*
*
*----------------------------------------------------------------------*
CLASS LCL_TREE_EVENT_RECEIVER DEFINITION.

  PUBLIC SECTION.
    METHODS ON_ADD_HIERARCHY_NODE FOR EVENT ON_ADD_HIERARCHY_NODE OF CL_GUI_ALV_TREE_SIMPLE
                                  IMPORTING GROUPLEVEL INDEX_OUTTAB.

    CLASS-METHODS: ON_ITEM_DOUBLE_CLICK FOR EVENT ITEM_DOUBLE_CLICK OF
          CL_GUI_ALV_TREE_SIMPLE
              IMPORTING INDEX_OUTTAB FIELDNAME GROUPLEVEL.

ENDCLASS.                    "LCL_TREE_EVENT_RECEIVER DEFINITION

*----------------------------------------------------------------------*
*       CLASS LCL_TREE_EVENT_RECEIVER IMPLEMENTATION
*----------------------------------------------------------------------*
*
*----------------------------------------------------------------------*
CLASS LCL_TREE_EVENT_RECEIVER IMPLEMENTATION.

  METHOD ON_ADD_HIERARCHY_NODE.
    DATA LS_OUTTAB_LINE TYPE ZCABPEDEXT.
    LS_OUTTAB_LINE-ZBLART = 'Note'.                         "#EC NOTEXT
    CALL METHOD TREE1->SET_HIERARCHY_DATA
      EXPORTING
        IS_OUTTAB_LINE = LS_OUTTAB_LINE.
  ENDMETHOD.                    "ON_ADD_HIERARCHY_NODE

  METHOD ON_ITEM_DOUBLE_CLICK.
*Begin of change: ReSQ Correction INDEX READ on an unsorted Internal TABLE 19/12/2019 EY_DES04 ECDK917080 *
SORT GT_CABPEDEXT .
*End of change: ReSQ Correction for INDEX READ on an unsorted Internal TABLE 19/12/2019 EY_DES04 ECDK917080 *
    READ TABLE GT_CABPEDEXT INTO LS_CABPEDEXT INDEX INDEX_OUTTAB.
    IF SY-SUBRC = 0.
      CASE FIELDNAME.
        WHEN 'FACTURA'.
          SET PARAMETER ID 'VF' FIELD LS_CABPEDEXT-FACTURA.
          CALL TRANSACTION 'VF03' AND SKIP FIRST SCREEN.
        WHEN 'PEDIDO'.
          SET PARAMETER ID 'AUN' FIELD LS_CABPEDEXT-PEDIDO.
          CALL TRANSACTION 'VA03' AND SKIP FIRST SCREEN.
        WHEN OTHERS.
          MESSAGE I000(0K) WITH 'log:' LS_CABPEDEXT-LOG_ERROR.
      ENDCASE.
    ENDIF.
  ENDMETHOD.                    "ON_ITEM_DOUBLE_CLICK

ENDCLASS.                    "LCL_TREE_EVENT_RECEIVER IMPLEMENTATION
