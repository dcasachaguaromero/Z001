
gv_name = is_mseg-matnr.

CALL FUNCTION 'READ_TEXT'
EXPORTING
*   CLIENT                        = SY-MANDT
id                            = 'PRUE'
language                      = gv_language
name                          = gv_name
object                        = 'MATERIAL'
*   ARCHIVE_HANDLE                = 0
*   LOCAL_CAT                     = ' '
* IMPORTING
*   HEADER                        =
TABLES
lines                         = lt_lines
EXCEPTIONS
id                            = 1
language                      = 2
name                          = 3
not_found                     = 4
object                        = 5
reference_check               = 6
wrong_access_to_archive       = 7
OTHERS                        = 8
.

IF sy-subrc <> 0.
*engl.
CALL FUNCTION 'READ_TEXT'
EXPORTING
*   CLIENT                        = SY-MANDT
id                            = 'PRUE'
language                      = 'E'
name                          = gv_name
object                        = 'MATERIAL'
TABLES
lines                         = lt_lines
EXCEPTIONS
id                            = 1
language                      = 2
name                          = 3
not_found                     = 4
object                        = 5
reference_check               = 6
wrong_access_to_archive       = 7
OTHERS                        = 8
.

IF sy-subrc <> 0.
*no Text exist (language: gv_langu or engl.)
gv_flag = 'x'.
ENDIF.
ENDIF.
























