class ZBBVACO_SERVICE1SOAP1 definition
  public
  inheriting from CL_PROXY_CLIENT
  create public .

*"* public components of class ZBBVACO_SERVICE1SOAP1
*"* do not include other source files here!!!
public section.

  methods CONSTRUCTOR
    importing
      !LOGICAL_PORT_NAME type PRX_LOGICAL_PORT_NAME optional
    raising
      CX_AI_SYSTEM_FAULT .
  methods WSINGRESO_NOMINA
    importing
      !INPUT type ZBBVAWSINGRESO_NOMINA_SOAP_IN1
    exporting
      !OUTPUT type ZBBVAWSINGRESO_NOMINA_SOAP_OU1
    raising
      CX_AI_SYSTEM_FAULT
      CX_AI_APPLICATION_FAULT .
protected section.
*"* protected components of class ZBBVACO_SERVICE1SOAP1
*"* do not include other source files here!!!
private section.
*"* private components of class ZBBVACO_SERVICE1SOAP1
*"* do not include other source files here!!!
ENDCLASS.



CLASS ZBBVACO_SERVICE1SOAP1 IMPLEMENTATION.


method CONSTRUCTOR.

  super->constructor(
    class_name          = 'ZBBVACO_SERVICE1SOAP1'
    logical_port_name   = logical_port_name
  ).

endmethod.


method WSINGRESO_NOMINA.

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
      method_name = 'WSINGRESO_NOMINA'
    changing
      parmbind_tab = lt_parmbind
  ).

endmethod.
ENDCLASS.
