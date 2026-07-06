*&---------------------------------------------------------------------*
*& Report  ZGENTRANFER
*&
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*

REPORT  ZGENTRANFER.
DATA: XSTATUS type flag.
TABLES: REGUH.
PARAMETERS:   XZBUKR           type   REGUH-ZBUKR,
              XFECHA           type   REGUH-LAUFD,
              XNOMINA           type   REGUH-LAUFI.
START-OF-SELECTION.

CALL FUNCTION 'ZINSERTA_TRANSFER'
     EXPORTING
          BUKRS             =  XZBUKR
          V_FECHA           =  XFECHA
          V_NOMINA          =  XNOMINA
     IMPORTING
          STATUS            = XSTATUS
    .


Message S000(IH) with 'Terminado'.
