*&---------------------------------------------------------------------*
*&  Include           ZMM_BAJA_CARGA_STOCK_SEL
*&---------------------------------------------------------------------*
SELECTION-SCREEN BEGIN OF BLOCK block01.
PARAMETERS     : p_opc1 RADIOBUTTON GROUP uno USER-COMMAND pro DEFAULT 'X',
                 p_opc2 RADIOBUTTON GROUP uno.
SELECTION-SCREEN SKIP.
PARAMETERS     : pt_budat TYPE budat  DEFAULT sy-datum MODIF ID baj.
SELECT-OPTIONS : st_matnr FOR wa_select-matnr          MODIF ID baj,
                 st_werks FOR wa_select-werks          MODIF ID baj,
                 st_lgort FOR wa_select-lgort          MODIF ID baj,
                 st_charg FOR wa_select-charg          MODIF ID baj.
SELECTION-SCREEN BEGIN OF BLOCK lb3 WITH FRAME TITLE TEXT-001.
*PARAMETERS     : pt_intco RADIOBUTTON GROUP stok,
*                 pt_consi RADIOBUTTON GROUP stok.
SELECT-OPTIONS : st_mtart FOR wa_select-mtart          MODIF ID baj.
SELECTION-SCREEN END OF BLOCK lb3.
* for the selection os special stocks
SELECTION-SCREEN BEGIN OF BLOCK lb2 WITH FRAME TITLE TEXT-002.
PARAMETERS : pt_sond       TYPE rmmmb-kzlso           MODIF ID baj.
SELECT-OPTIONS: st_sobkz   FOR  wa_select-sobkz       MODIF ID baj.
SELECTION-SCREEN END OF BLOCK lb2.
*
SELECTION-SCREEN BEGIN OF BLOCK lb1 WITH FRAME TITLE TEXT-003.
PARAMETERS: pt_negat  TYPE  am07m-seneg                    MODIF ID baj.
PARAMETERS: pt_xmchb  TYPE  am07m-mb52_xmchb DEFAULT   'X' MODIF ID baj.
PARAMETERS: pt_noze   TYPE  rmmmb-kznul      DEFAULT   'X' MODIF ID baj.
PARAMETERS: pt_noval  TYPE  am07m-mb52_noval DEFAULT   'X' MODIF ID baj.
PARAMETERS: pa_fbaja  TYPE localfile                       MODIF ID baj.
SELECTION-SCREEN END OF BLOCK lb1.
*
PARAMETERS: pa_file  TYPE localfile                        MODIF ID car.
PARAMETERS: pa_test  AS CHECKBOX                           MODIF ID car.
SELECTION-SCREEN END OF BLOCK block01.

INITIALIZATION.
  pa_fbaja = 'C:\TEMP\STOCK_MB52\'.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR pa_file.
  PERFORM busqueda_archivo  CHANGING pa_file.

AT SELECTION-SCREEN ON BLOCK block01.
  CHECK sy-ucomm NE 'PRO'.
  CASE gc_x.
    WHEN p_opc1.
      IF pt_budat IS INITIAL.
        MESSAGE e899(mm) WITH 'Ingrese Fecha Contable'.
      ENDIF.
    WHEN p_opc2.
      IF pa_file IS INITIAL.
        MESSAGE e899(mm) WITH 'Ingrese Archivo de carga'.
      ENDIF.
  ENDCASE.

AT SELECTION-SCREEN OUTPUT.
  LOOP AT SCREEN.
    CASE gc_x.
      WHEN p_opc1.
        CHECK screen-group1 EQ 'CAR'.
        screen-active = 0.
      WHEN p_opc2.
        CHECK screen-group1 EQ 'BAJ'.
        screen-active = 0.
    ENDCASE.
    MODIFY SCREEN.
  ENDLOOP.
