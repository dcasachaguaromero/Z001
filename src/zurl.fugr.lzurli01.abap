*&---------------------------------------------------------------------*
*& Report: < ZEY_GDS_CORRECTION > *
*& Author: < EY_DES01 > *
*& Description: < ReSQ Correction > *
*& Date: <19-12-2019> *
*& Transport Number: < ECDK917080 > *
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&  Include           LZURLI01
*&---------------------------------------------------------------------*
*----------------------------------------------------------------------*
***INCLUDE LZURLI01 .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0100  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE USER_COMMAND_0100 INPUT.

  SAVE_OK = OK_CODE.

  CLEAR OK_CODE.
  CASE SAVE_OK.
    WHEN 'SHOW_URL'.
      CALL METHOD HTML_VIEWER->SHOW_URL
        EXPORTING
          URL        = URL
          FRAME      = FRAME
        EXCEPTIONS
          CNTL_ERROR = 1.
    WHEN 'STOP'.
      CALL METHOD HTML_VIEWER->STOP
        EXCEPTIONS
          CNTL_ERROR = 1.
    WHEN 'GO_BACK'.
      CALL METHOD HTML_VIEWER->GO_BACK
        EXCEPTIONS
          CNTL_ERROR = 1.
    WHEN 'GO_FORWARD'.
      CALL METHOD HTML_VIEWER->GO_FORWARD
        EXCEPTIONS
          CNTL_ERROR = 1.
    WHEN 'GO_HOME'.
      CALL METHOD HTML_VIEWER->GO_HOME
        EXCEPTIONS
          CNTL_ERROR = 1.
    WHEN 'DO_REFRESH'.
      CALL METHOD HTML_VIEWER->DO_REFRESH
        EXCEPTIONS
          CNTL_ERROR = 1.
    WHEN 'GET_CURRENT_URL'.
      CALL METHOD HTML_VIEWER->GET_CURRENT_URL
        IMPORTING
          URL        = URL
        EXCEPTIONS
          CNTL_ERROR = 1.
    WHEN 'LOAD_DATABASE'.
      CALL METHOD HTML_VIEWER->LOAD_HTML_DOCUMENT
           EXPORTING DOCUMENT_ID       = 'HTMLCNTL_TESTHTM2_FRAME1'
*                    document_textpool = document_textpool
                     DOCUMENT_URL      = 'HTMLFrame1.htm'
*          IMPORTING assigned_url      = assigned_url
*          CHANGING  merge_table       = merge_table
           EXCEPTIONS DOCUMENT_NOT_FOUND   = 1
                      DP_ERROR_GENERAL     = 2
                      DP_INVALID_PARAMETER = 3.
      CALL METHOD HTML_VIEWER->LOAD_HTML_DOCUMENT
           EXPORTING DOCUMENT_ID       = 'HTMLCNTL_TESTEVNT_HOME'
*                    document_textpool = document_textpool
                     DOCUMENT_URL      = 'HTMLFrame2.htm'
*          IMPORTING assigned_url      = assigned_url
*          CHANGING  merge_table       = merge_table
           EXCEPTIONS DOCUMENT_NOT_FOUND   = 1
                      DP_ERROR_GENERAL     = 2
                      DP_INVALID_PARAMETER = 3.
      CALL METHOD HTML_VIEWER->LOAD_HTML_DOCUMENT
           EXPORTING DOCUMENT_ID       = 'HTMLCNTL_TESTHTM2_FRAMESET'
*                    document_textpool = document_textpool
*                    document_url      = document_url
           IMPORTING ASSIGNED_URL      = ASSIGNED_URL
*          CHANGING  merge_table       = merge_table
           EXCEPTIONS DOCUMENT_NOT_FOUND   = 1
                      DP_ERROR_GENERAL     = 2
                      DP_INVALID_PARAMETER = 3.
      CALL METHOD HTML_VIEWER->LOAD_MIME_OBJECT
         EXPORTING
              OBJECT_ID  = 'HTMLCNTL_TESTHTM2_SAPLOGO'
              OBJECT_URL = 'SAPLOGO.GIF'
*           IMPORTING assigned_url = assigned_url
                EXCEPTIONS OBJECT_NOT_FOUND     = 1
                           DP_ERROR_GENERAL     = 2
                           DP_INVALID_PARAMETER = 3.
      CALL METHOD HTML_VIEWER->LOAD_MIME_OBJECT
           EXPORTING
                OBJECT_ID  = 'HTMLCNTL_TESTHTM2_SAP_AG'
                OBJECT_URL = 'SAP_AG.GIF'
*           IMPORTING assigned_url = assigned_url
                EXCEPTIONS OBJECT_NOT_FOUND     = 1
                           DP_ERROR_GENERAL     = 2
                           DP_INVALID_PARAMETER = 3.
      CALL METHOD HTML_VIEWER->LOAD_MIME_OBJECT
           EXPORTING
                OBJECT_ID  = 'HTMLCNTL_TESTHTM2_BACKGROUND'
                OBJECT_URL = 'HOME_BACKGROUND.GIF'
*           IMPORTING assigned_url = assigned_url
                EXCEPTIONS OBJECT_NOT_FOUND     = 1
                           DP_ERROR_GENERAL     = 2
                           DP_INVALID_PARAMETER = 3.

      CALL METHOD HTML_VIEWER->SHOW_DATA
           EXPORTING URL   = ASSIGNED_URL
*                    frame = frame
           EXCEPTIONS CNTL_ERROR = 1.

  ENDCASE.

ENDMODULE.                             " USER_COMMAND_0100  INPUT

*&---------------------------------------------------------------------*
*&      Module  EXIT  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE EXIT INPUT.

*  CALL METHOD HTML_VIEWER->FREE.
*  CALL METHOD CONTAINER->FREE.
*  FREE HTML_VIEWER.
*  FREE CONTAINER.
  LEAVE TO SCREEN 0.

ENDMODULE.                             " EXIT  INPUT
*&---------------------------------------------------------------------*
*&      Module  ASIG_VALUE_TXT  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE ASIG_VALUE_TXT INPUT.
*ResQ Comment:Correction not required as Select Single is used 19/12/2019 EY_DES01 ECDK917080 *
  SELECT SINGLE LTEXT INTO ZTDEA-LTEXT FROM T003T WHERE SPRAS EQ SY-LANGU
                                                    AND BLART EQ ZTDEA-BLART.

ENDMODULE.                 " ASIG_VALUE_TXT  INPUT
