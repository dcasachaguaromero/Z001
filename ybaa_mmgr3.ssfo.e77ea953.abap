
*Wertebereich der domaine nachlesen

CALL FUNCTION 'DD_DOMVALUES_GET'
EXPORTING
domname              = 'MB_INSMK'
text                 = 'X'
langu                = is_nast-spras
*   BYPASS_BUFFER        = ' '
* IMPORTING
*   RC                   =
TABLES
dd07v_tab            = lt_insmk
EXCEPTIONS
wrong_textflag       = 1
OTHERS               = 2
.
IF sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
CLEAR gv_insmk.
ELSE.

LOOP AT lt_insmk INTO ls_insmk
WHERE domvalue_l = <traptab>-insmk.
gv_insmk        = ls_insmk-ddtext.
ENDLOOP.
ENDIF.






































































