*&---------------------------------------------------------------------*
*&  Include           LZURLO01
*&---------------------------------------------------------------------*
*----------------------------------------------------------------------*
***INCLUDE LZURLO01 .
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
      EXPORTING
        CONTAINER_NAME = 'CUSTOM'.
    CREATE OBJECT HTML_VIEWER
      EXPORTING
        PARENT             = CONTAINER
      EXCEPTIONS
        CNTL_ERROR         = 1
        CNTL_INSTALL_ERROR = 2
        DP_INSTALL_ERROR   = 3
        DP_ERROR           = 4.
    IF SY-SUBRC NE 0.
* Fehlerbehandlung
    ENDIF.
    CALL METHOD CL_GUI_CFW=>FLUSH
      EXCEPTIONS
        CNTL_SYSTEM_ERROR = 1
        CNTL_ERROR        = 2.
    IF SY-SUBRC NE 0.
* Fehlerbehandlung
    ENDIF.

  ENDIF.

  CALL METHOD HTML_VIEWER->SHOW_URL
    EXPORTING
      URL        = URL
      FRAME      = FRAME
    EXCEPTIONS
      CNTL_ERROR = 1.

ENDMODULE.                 " STATUS_0100  OUTPUT
