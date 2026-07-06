*----------------------------------------------------------------------*
*   INCLUDE LFHL2O00                                                   *
*----------------------------------------------------------------------*

*eject
*----------------------------------------------------------------------*
*        MODULE  D0100_STATUS                                          *
*----------------------------------------------------------------------*
*        Status und Titel auf Dynpro 100 setzen                        *
*----------------------------------------------------------------------*
MODULE D0010_STATUS OUTPUT.

  SET PF-STATUS 'POP'.
  SET TITLEBAR  'MLD'.

ENDMODULE.

*eject
*----------------------------------------------------------------------*
*        MODULE  D0100_STATUS                                          *
*----------------------------------------------------------------------*
*        Status und Titel auf Dynpro 100 setzen                        *
*----------------------------------------------------------------------*
MODULE D0100_STATUS OUTPUT.

  IF I_MODUS = 'W'.
    SET PF-STATUS '100W' EXCLUDING EXCLTAB.
  ELSE.
    SET PF-STATUS '100A' EXCLUDING EXCLTAB.
  ENDIF.
  SET TITLEBAR 'FLD'.
  SUPPRESS DIALOG.

ENDMODULE.

*eject
*----------------------------------------------------------------------*
*        MODULE  D0200_STATUS                                          *
*----------------------------------------------------------------------*
*        Status und Titel auf Dynpro 200 setzen                        *
*----------------------------------------------------------------------*
MODULE D0200_STATUS OUTPUT.

  IF I_XSHOW = SPACE.
    SET PF-STATUS 'STDLISW'.
  ELSE.
    SET PF-STATUS 'STDLISA'.
  ENDIF.
  SET TITLEBAR 'ZBD'.
  SUPPRESS DIALOG.

ENDMODULE.

*eject
*----------------------------------------------------------------------*
*        MODULE  DYNPRO_MODIF_1000                                     *
*----------------------------------------------------------------------*
*        Feld 'Feldname' auf Dynpro 1000 ausblenden, falls in der      *
*        Liste keine technischen NAmen angezeigt werden                *
*----------------------------------------------------------------------*
MODULE DYNPRO_MODIF_1000 OUTPUT.

  CHECK I_XTECH = SPACE.
  LOOP AT SCREEN.
    CHECK SCREEN-NAME = 'RFCU3-FNAME'.
    SCREEN-INPUT     = 0.
    SCREEN-OUTPUT    = 0.
    SCREEN-INVISIBLE = 1.
    MODIFY SCREEN.
    EXIT.
  ENDLOOP.

ENDMODULE.

*eject
*----------------------------------------------------------------------*
*        MODULE  EXCLTAB_FUELLEN                                       *
*----------------------------------------------------------------------*
*        EXCLTAB füllen                                                *
*----------------------------------------------------------------------*
MODULE EXCLTAB_FUELLEN OUTPUT.

  REFRESH EXCLTAB.
  CHECK I_XTECH = SPACE.
  EXCLTAB-OKCOD = 'SORF'.
  APPEND EXCLTAB.

ENDMODULE.

*eject
*----------------------------------------------------------------------*
*        MODULE  STATUS_POP                                            *
*----------------------------------------------------------------------*
*        Status und Titel auf Popup setzen                             *
*----------------------------------------------------------------------*
MODULE STATUS_POP OUTPUT.

  SET PF-STATUS 'POP'.
  SET TITLEBAR 'FSU'.

ENDMODULE.
