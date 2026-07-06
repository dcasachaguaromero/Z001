*&---------------------------------------------------------------------*
*& Report  ZFITR020_T0
*&---------------------------------------------------------------------
*&  Compañía   : Banmedica
*&  Autor      : Crystalis Consulting Chile - Pablo Cabezas Melendez
*&  Funcional  : Crystalis Consulting Chile - Oscar Agudelo Prado
*&  Fecha      : 30.08.2013
*&  Objetivo   : Solución integral de pagos
*&--------------------------------------------------------------------
* Proceso      : Programa repositorio de procesos
*--------------------------------------------------------------------*
REPORT  ZFITR020_T0.

SELECTION-SCREEN BEGIN OF BLOCK one WITH FRAME TITLE text-064.
SELECTION-SCREEN BEGIN OF BLOCK b01 WITH FRAME TITLE text-004.
*--------------------------------------------------------------------*
SELECTION-SCREEN : SKIP 2.
SELECTION-SCREEN COMMENT 4(20) text-103 MODIF ID mg1.
SELECTION-SCREEN ULINE.
PARAMETERS:
*               p_op2 RADIOBUTTON GROUP gp1  " comentado 30.04.2015 FGT
*              ,p_op3 RADIOBUTTON GROUP gp1
*              ,p_op4 RADIOBUTTON GROUP gp1
*              ,p_op5 RADIOBUTTON GROUP gp1
*              ,p_op6 RADIOBUTTON GROUP gp1
*               p_op20 RADIOBUTTON GROUP gp1
               p_op21 RADIOBUTTON GROUP gp1
              ,p_op16 RADIOBUTTON GROUP gp1.
*--------------------------------------------------------------------*
SELECTION-SCREEN : SKIP 2.
SELECTION-SCREEN COMMENT 4(20) text-104 MODIF ID mg1.
SELECTION-SCREEN ULINE.
PARAMETERS:   p_op7 RADIOBUTTON GROUP gp1 ,
              p_op8 RADIOBUTTON GROUP gp1 ,
              p_op15 RADIOBUTTON GROUP gp1 ,

*              p_op9 RADIOBUTTON GROUP gp1 ,
              p_op10 RADIOBUTTON GROUP gp1,
              p_op11 RADIOBUTTON GROUP gp1,
              p_op12 RADIOBUTTON GROUP gp1,
              p_op13 RADIOBUTTON GROUP gp1,
              p_op14 RADIOBUTTON GROUP gp1.
*--------------------------------------------------------------------*
SELECTION-SCREEN : SKIP 2.
* SELECTION-SCREEN COMMENT 4(35) text-102 MODIF ID mg1.
* SELECTION-SCREEN ULINE.
*PARAMETERS:   p_op1 RADIOBUTTON GROUP gp1.
SELECTION-SCREEN END OF BLOCK b01.
*--------------------------------------------------------------------*
SELECTION-SCREEN BEGIN OF block b02.
SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN PUSHBUTTON (20) button1 USER-COMMAND BUT1.
SELECTION-SCREEN PUSHBUTTON (20) button2 USER-COMMAND BUT2.
SELECTION-SCREEN PUSHBUTTON (20) button3 USER-COMMAND BUT3.
SELECTION-SCREEN PUSHBUTTON (20) button4 USER-COMMAND BUT4.
SELECTION-SCREEN PUSHBUTTON (20) button5 USER-COMMAND BUT5.
SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN PUSHBUTTON (20) button6 USER-COMMAND BUT6.
SELECTION-SCREEN PUSHBUTTON (20) button7 USER-COMMAND BUT7.
SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN END OF block b02.
SELECTION-SCREEN END OF BLOCK one.

AT SELECTION-SCREEN OUTPUT.
  LOOP AT SCREEN.
    IF screen-group1 = 'MG1'.
      screen-intensified = '1'.
      MODIFY SCREEN.
    ENDIF.
  ENDLOOP.


AT SELECTION-SCREEN.
  IF sy-ucomm EQ 'BUT1'.
    CALL FUNCTION 'VIEW_MAINTENANCE_CALL'
      EXPORTING
        action    = 'U'
        view_name = 'ZFITR020_T04'.
  elseIF sy-ucomm EQ 'BUT2'.
    CALL FUNCTION 'VIEW_MAINTENANCE_CALL'
      EXPORTING
        action    = 'U'
        view_name = 'ZFITR020_T03'.
  elseIF sy-ucomm EQ 'BUT3'.
    CALL FUNCTION 'VIEW_MAINTENANCE_CALL'
      EXPORTING
        action    = 'U'
        view_name = 'ZFITR020_T05'.
  elseIF sy-ucomm EQ 'BUT4'.
    CALL FUNCTION 'VIEW_MAINTENANCE_CALL'
      EXPORTING
        action    = 'U'
        view_name = 'ZMOT_EMIS'.
  elseIF sy-ucomm EQ 'BUT5'.
    CALL FUNCTION 'VIEW_MAINTENANCE_CALL'
      EXPORTING
        action    = 'U'
        view_name = 'ZRANGOS_PRESCRI'.
  elseIF sy-ucomm EQ 'BUT6'.
    CALL FUNCTION 'VIEW_MAINTENANCE_CALL'
      EXPORTING
        action    = 'U'
        view_name = 'ZFITR020_T02'.

  ELSEIF sy-ucomm EQ 'BUT7'.
    CALL FUNCTION 'VIEW_MAINTENANCE_CALL'
      EXPORTING
        action    = 'U'
        view_name = 'ZFITR020_T06'.
  ENDIF.


INITIALIZATION.
* Add displayed text string to buttons
  button1 = 'Configuración'.
  button2 = 'Procesos'.
  button3 = 'Tabla bancos'.
  button4 = 'Tabla Mot. Emi'.
  button5 = 'Rango prescip.'.
  button6 = 'Tabla Soc-Cebe'.
  button7 = 'Conversiones'.


START-OF-SELECTION.

*  if p_op1 eq 'X'.
*    CALL TRANSACTION 'ZFITR020V1'."ZFITR020_T01 Actualiza tabla mantenedora de documentos
*  elseif p_op2 eq 'X'.
*    CALL TRANSACTION 'ZFITR020C1'."ZFITR0020_21 CONSULTA POR CHEQUE
*  elseif p_op3 eq 'X'.
*    CALL TRANSACTION 'ZFITR020C2'."ZFITR0020_22 CONSULTA POR ACREEDOR Y FOLIOS DE PAGO
*  elseif p_op4 eq 'X'.
*    CALL TRANSACTION 'ZFITR020C3'."ZFITR0020_23 CONSULTA POR COMPROBANTE DE PAGOS
*  elseif p_op5 eq 'X'.
*    CALL TRANSACTION 'ZFITR020C4'."ZFITR0020_24 CONSULTA POR COMPROBANTE DE PAGO MASIVO
*  elseif p_op6 eq 'X'.
*    CALL TRANSACTION 'ZFITR020C5'."ZFITR0020_25 CONSULTA POR SUCESO - LICENCIAS MATERNALES
  if p_op7 eq 'X'.
    CALL TRANSACTION 'ZFITR020V2'."ZFITR0020    CADUCA ELECTRONICO
  elseif p_op8 eq 'X'.
    CALL TRANSACTION 'ZFITR020V3'."ZFITR0030    CADUCA FISICO maternales
*  elseif p_op9 eq 'X'.
*    CALL TRANSACTION 'ZFITR020V4'."ZFITR0040    REVALIDA CHEQUE
  elseif p_op10 eq 'X'.
    CALL TRANSACTION 'ZFITR020V5'."ZFITR0050    CAMBIO - NUEVO PAGO - MATERNAL
  elseif p_op11 eq 'X'.
    CALL TRANSACTION 'ZFITR020V6_2'."ZFITR0060    PRESCRIPCION
  elseif p_op12 eq 'X'.
    CALL TRANSACTION 'ZFITR020V7'."ZFITR0070    ANULACION
  elseif p_op13 eq 'X'.
    CALL TRANSACTION 'ZFITR014'.  "Ingreso Rechazo Pago
  elseif p_op14 eq 'X'.
    CALL TRANSACTION 'ZFITR012_NEW'. "Proceso  Archivo Pago enviado x BBVA
  elseif p_op15 eq 'X'.
    CALL TRANSACTION 'ZFITR020V3_2'."ZFITR0031    CADUCA FISICO otros
  elseif p_op16 eq 'X'.
    CALL TRANSACTION 'ZFITR020C6'."ZFI_PAGO_SIN_COBRO   CONSULTA DEUDA POR RUT
*  elseif p_op20 eq 'X'.
*    CALL TRANSACTION 'ZFITR020N01'."  TRAZA POR CHEQUE
  elseif p_op21 eq 'X'.
    CALL TRANSACTION 'ZFITR020N02'. " TRAZA PAGOS CHEQUE-VVISTA
  endif.
