*&---------------------------------------------------------------------*
*&  Include           ZFITR040_038_SEL
*&---------------------------------------------------------------------*

*----------------------------------------------------------------------
*                      SELECTION-SCREEN
*----------------------------------------------------------------------
SELECTION-SCREEN: BEGIN OF BLOCK b1 WITH FRAME TITLE TEXT-t01.
PARAMETERS: p_bukrs TYPE bukrs DEFAULT 'CL01',
            p_budat TYPE budat OBLIGATORY,
            p_block TYPE i DEFAULT '20'.
SELECTION-SCREEN: END OF BLOCK b1.
*
SELECTION-SCREEN: BEGIN OF BLOCK b2 WITH FRAME TITLE TEXT-t02.
PARAMETERS: p_show RADIOBUTTON GROUP r1 DEFAULT 'X',
            p_down RADIOBUTTON GROUP r1.
SELECTION-SCREEN: END OF BLOCK b2.


*----------------------------------------------------------------------
*                   AT SELECTION-SCREEN
*----------------------------------------------------------------------
AT SELECTION-SCREEN.

  SELECT SINGLE FROM ztparamftp FIELDS zruta, zruta_respaldo
      WHERE zbukr = @p_bukrs
        AND zprog = @sy-repid  "'ZFITR040_037'
    INTO @gs_ztparamftp.

  IF sy-subrc <> 0.
*   No se encuentra ruta de archivo definida en tabla &
    MESSAGE i017(z1) WITH 'ZTPARAMFTP'.
    LEAVE PROGRAM.
  ENDIF.
