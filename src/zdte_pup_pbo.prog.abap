*&---------------------------------------------------------------------*
*&  Include           ZDTE_PUP_PBO
*&---------------------------------------------------------------------*
*----------------------------------------------------------------------*
*   INCLUDE ZDTE_PUP_PBO                                               *
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  STATUS_0100  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE STATUS_0100 OUTPUT.

  SET PF-STATUS 'STATUS'.
  IF INIT IS INITIAL.
    INIT = 'X'.
    CREATE OBJECT CONTAINER
            EXPORTING CONTAINER_NAME = 'CUSTOM'.
    CREATE OBJECT HTML_VIEWER
            EXPORTING  PARENT              = CONTAINER
            EXCEPTIONS CNTL_ERROR         = 1
                       CNTL_INSTALL_ERROR = 2
                       DP_INSTALL_ERROR   = 3
                       DP_ERROR           = 4.
    IF SY-SUBRC NE 0.
* Fehlerbehandlung
    ENDIF.
    CALL METHOD CL_GUI_CFW=>FLUSH
         EXCEPTIONS CNTL_SYSTEM_ERROR = 1
                    CNTL_ERROR        = 2.
    IF SY-SUBRC NE 0.
* Fehlerbehandlung
    ENDIF.

  ENDIF.

  URL = 'http://pruebashelp1112.acepta.com/v01/D6FC70005B3D91657C138E70E825F07BCA8B3290?k=114989517aca97daa2485181eb31c07d'.

  CALL METHOD HTML_VIEWER->SHOW_URL
            EXPORTING URL   = URL
                      FRAME = FRAME
            EXCEPTIONS CNTL_ERROR = 1.

ENDMODULE.                             " STATUS_0100  OUTPUT
