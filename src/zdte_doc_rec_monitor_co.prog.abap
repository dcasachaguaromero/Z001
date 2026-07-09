*&---------------------------------------------------------------------*
*&  Include           ZDTE_DOC_REC_MONITOR_CO
*&---------------------------------------------------------------------*
TYPE-POOLS: slis.
CONSTANTS: c_contabilizado(2)       VALUE 'CO',
           c_no_contabilizado(2)    VALUE 'NC',
           c_nuevo_xx(2)            VALUE 'XX',
           c_rechazado(2)           VALUE 'RE',
           c_dte_rechazado(1)       VALUE '2',
           c_nuevo(2)               VALUE 'NU'.

ranges r_status_mod FOR ZDTE_DOC_REC-estado.

  DATA: BEGIN OF t_aux1 OCCURS 0,
    param TYPE c LENGTH 100.
  DATA: END OF t_aux1.
