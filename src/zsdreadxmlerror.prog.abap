*&---------------------------------------------------------------------*
*& Report  ZSDREADXMLERROR
*&
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*

REPORT  ZSDREADXMLERROR.

DATA STR_DATA TYPE STRING.
DATA: BEGIN OF TI_STRING OCCURS 0,
       DATA TYPE STRING,
      END OF TI_STRING.
PARAMETERS P_FILE TYPE FILENAME_AL11 DEFAULT '/tmp/xml.txt' LOWER CASE.

START-OF-SELECTION.

  OPEN DATASET P_FILE FOR INPUT IN TEXT MODE ENCODING DEFAULT.
  IF SY-SUBRC = 0.
    WHILE SY-SUBRC = 0.
      READ DATASET P_FILE INTO TI_STRING-DATA.
      APPEND TI_STRING.
      CLEAR TI_STRING.
    ENDWHILE.
    CALL FUNCTION 'GUI_DOWNLOAD'
      EXPORTING
        FILENAME                        = 'C:\TEMP\TEST.XML'
*       FILETYPE                        = 'ASC'
*       APPEND                          = ' '
*       WRITE_FIELD_SEPARATOR           = ' '
*       HEADER                          = '00'
*       TRUNC_TRAILING_BLANKS           = ' '
*       WRITE_LF                        = 'X'
*       COL_SELECT                      = ' '
*       COL_SELECT_MASK                 = ' '
*       DAT_MODE                        = ' '
*       CONFIRM_OVERWRITE               = ' '
*       NO_AUTH_CHECK                   = ' '
*       CODEPAGE                        = ' '
*       IGNORE_CERR                     = ABAP_TRUE
*       REPLACEMENT                     = '#'
*       WRITE_BOM                       = ' '
*       TRUNC_TRAILING_BLANKS_EOL       = 'X'
*       WK1_N_FORMAT                    = ' '
*       WK1_N_SIZE                      = ' '
*       WK1_T_FORMAT                    = ' '
*       WK1_T_SIZE                      = ' '
*       WRITE_LF_AFTER_LAST_LINE        = ABAP_TRUE
*       SHOW_TRANSFER_STATUS            = ABAP_TRUE
*     IMPORTING
*       FILELENGTH                      =
      TABLES
        DATA_TAB                        = TI_STRING
*       FIELDNAMES                      =
*     EXCEPTIONS
*       FILE_WRITE_ERROR                = 1
*       NO_BATCH                        = 2
*       GUI_REFUSE_FILETRANSFER         = 3
*       INVALID_TYPE                    = 4
*       NO_AUTHORITY                    = 5
*       UNKNOWN_ERROR                   = 6
*       HEADER_NOT_ALLOWED              = 7
*       SEPARATOR_NOT_ALLOWED           = 8
*       FILESIZE_NOT_ALLOWED            = 9
*       HEADER_TOO_LONG                 = 10
*       DP_ERROR_CREATE                 = 11
*       DP_ERROR_SEND                   = 12
*       DP_ERROR_WRITE                  = 13
*       UNKNOWN_DP_ERROR                = 14
*       ACCESS_DENIED                   = 15
*       DP_OUT_OF_MEMORY                = 16
*       DISK_FULL                       = 17
*       DP_TIMEOUT                      = 18
*       FILE_NOT_FOUND                  = 19
*       DATAPROVIDER_EXCEPTION          = 20
*       CONTROL_FLUSH_ERROR             = 21
*       OTHERS                          = 22
              .
    IF SY-SUBRC <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
    ENDIF.

    CLOSE DATASET P_FILE.
  ENDIF.
