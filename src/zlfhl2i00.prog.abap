*----------------------------------------------------------------------*
*   INCLUDE LFHL2I00                                                   *
*----------------------------------------------------------------------*

*eject
*----------------------------------------------------------------------*
*        MODULE  WEITER                                                *
*----------------------------------------------------------------------*
*        Uebernahme der Landeseingrenzung                              *
*----------------------------------------------------------------------*
MODULE WEITER.

  IF SY-UCOMM = 'CNCL'.
    CLEAR T007A-LSTML.
  ENDIF.

  SET SCREEN 0.
  LEAVE SCREEN.

ENDMODULE.

*eject
*----------------------------------------------------------------------*
*        MODULE  FELDLISTE                                             *
*----------------------------------------------------------------------*
*        Anzeige der Feldnamen                                         *
*----------------------------------------------------------------------*
MODULE FELDLISTE.

  LEAVE TO LIST-PROCESSING.
  PERFORM FELDLISTE_AUSGEBEN.

ENDMODULE.

*eject
*----------------------------------------------------------------------*
*        MODULE  OKCODE_1000                                           *
*----------------------------------------------------------------------*
*        Verarbeiten des OK-Codes auf Dynpro 1000                      *
*----------------------------------------------------------------------*
MODULE OKCODE_1000.

  IF OK_CODE = 'CNCL'.
    CLEAR: RFCU3-FNAME, RFCU1-FELDT.
  ENDIF.
  CLEAR OK_CODE.
  SET SCREEN 0.
  LEAVE SCREEN.

ENDMODULE.

*eject
*----------------------------------------------------------------------*
*        MODULE  ZAHLUNGSBEDINGUNGEN                                   *
*----------------------------------------------------------------------*
*        Anzeige der Zahlungsbedingungen                               *
*----------------------------------------------------------------------*
MODULE ZAHLUNGSBEDINGUNGEN.

  LEAVE TO LIST-PROCESSING.
  PERFORM ZTERM_LISTE.

ENDMODULE.
