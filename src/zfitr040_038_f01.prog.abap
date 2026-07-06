*&---------------------------------------------------------------------*
*&  Include           ZFITR040_038_F01
*&---------------------------------------------------------------------*
*--------------------------------------------------------------------*
*&   Form  PF_STATUS
*--------------------------------------------------------------------*
FORM pf_status USING ce_func_exclude TYPE slis_t_extab.

  DATA: lt_code_attrib_tab  TYPE TABLE OF smp_dyntxt.
  DATA: ls_code_attrib_tab  TYPE smp_dyntxt.
  DATA: ls_exlude           TYPE slis_extab.

*  DEFINE exclude.
*    clear: ls_exlude.
*    ls_exlude-fcode = &1.
*    append ls_exlude to ce_func_exclude.
*  END-OF-DEFINITION.

  SET PF-STATUS 'ALVLIST'  EXCLUDING ce_func_exclude.
*
ENDFORM.  " FIN PF_STATUS
