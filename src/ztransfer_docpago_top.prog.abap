*&---------------------------------------------------------------------*
*&  Include           ZTRANSFER_DOCPAGO_TOP
*&---------------------------------------------------------------------*

TABLES: reguh.

TYPES: BEGIN OF t_valida,
     status TYPE zfitr_tesdocpago-status,
     usnam  TYPE zfitr_tesdocpago-usnam,
   date_act TYPE zfitr_tesdocpago-date_act,
END OF t_valida.

TYPES: BEGIN OF t_prop,
     laufd TYPE reguh-laufd,
     laufi TYPE reguh-laufi,
     zbukr TYPE reguh-zbukr,
END OF t_prop.

DATA: gv_status     TYPE flag.
DATA: gv_insmod(1)  TYPE n,  " 1 Modificar, 2 Insertar
      gv_message    TYPE string.
DATA: gt_propuesta  TYPE TABLE OF t_prop,
      gw_propuesta  TYPE t_prop,
      gw_tesdocpago TYPE zfitr_tesdocpago,
      gw_valida     TYPE t_valida.
