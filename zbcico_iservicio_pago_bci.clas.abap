class ZBCICO_ISERVICIO_PAGO_BCI definition
  public
  inheriting from CL_PROXY_CLIENT
  create public .

public section.

  methods CARGAR_NOMINA
    importing
      !INPUT type ZBCIISERVICIO_PAGO_BCI_CARGAR1
    exporting
      !OUTPUT type ZBCIISERVICIO_PAGO_BCI_CARGAR
    raising
      CX_AI_SYSTEM_FAULT .
  methods CONSTRUCTOR
    importing
      !LOGICAL_PORT_NAME type PRX_LOGICAL_PORT_NAME optional
    raising
      CX_AI_SYSTEM_FAULT .
  methods OBTENER_NOMINA
    importing
      !INPUT type ZBCIISERVICIO_PAGO_BCI_OBTENE1
    exporting
      !OUTPUT type ZBCIISERVICIO_PAGO_BCI_OBTENER
    raising
      CX_AI_SYSTEM_FAULT .
protected section.
private section.
ENDCLASS.



CLASS ZBCICO_ISERVICIO_PAGO_BCI IMPLEMENTATION.


  method CARGAR_NOMINA.

  data:
    ls_parmbind type abap_parmbind,
    lt_parmbind type abap_parmbind_tab.

  ls_parmbind-name = 'INPUT'.
  ls_parmbind-kind = cl_abap_objectdescr=>importing.
  get reference of INPUT into ls_parmbind-value.
  insert ls_parmbind into table lt_parmbind.

  ls_parmbind-name = 'OUTPUT'.
  ls_parmbind-kind = cl_abap_objectdescr=>exporting.
  get reference of OUTPUT into ls_parmbind-value.
  insert ls_parmbind into table lt_parmbind.

  if_proxy_client~execute(
    exporting
      method_name = 'CARGAR_NOMINA'
    changing
      parmbind_tab = lt_parmbind
  ).

  endmethod.


  method CONSTRUCTOR.

  super->constructor(
    class_name          = 'ZBCICO_ISERVICIO_PAGO_BCI'
    logical_port_name   = logical_port_name
  ).

  endmethod.


  method OBTENER_NOMINA.

  data:
    ls_parmbind type abap_parmbind,
    lt_parmbind type abap_parmbind_tab.

  ls_parmbind-name = 'INPUT'.
  ls_parmbind-kind = cl_abap_objectdescr=>importing.
  get reference of INPUT into ls_parmbind-value.
  insert ls_parmbind into table lt_parmbind.

  ls_parmbind-name = 'OUTPUT'.
  ls_parmbind-kind = cl_abap_objectdescr=>exporting.
  get reference of OUTPUT into ls_parmbind-value.
  insert ls_parmbind into table lt_parmbind.

  if_proxy_client~execute(
    exporting
      method_name = 'OBTENER_NOMINA'
    changing
      parmbind_tab = lt_parmbind
  ).

  endmethod.
ENDCLASS.
