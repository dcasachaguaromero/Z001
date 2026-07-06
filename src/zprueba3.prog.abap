*&---------------------------------------------------------------------*
*& Report  YPRUEBA2
*&         Prueba Impresion Timbre de Revalidacion
*&         Imagen : Revalidacion cargada con la SM78
*&         Parametro entrada: fchreval (formato ddmmyyyy)
*&         Parametro de Salida : fechaRevalidacion (formato dd.mm.yyyy)
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*

REPORT  yprueba3.

*----------------------------------------------------------------------*
* Tables                                                               *
*----------------------------------------------------------------------*
TABLES:
  addr1_sel,                           "interface to ADDR_GET
  addr1_val,                           "interface to ADDR_GET
  adrs,                                "address into printform
  arc_params,                          "archive parameters
  autha,                               "HR authority check
  bhdgd,                               "for batch-heading
  bkpf,                                "for payment document valdation
  bnka,                                "bank master record
  fimsg,                               "FI messages
  finaa,                               "message type (print or fax)
  fsabe,                               "Accounting clerk
 *fsabe,                               "Accounting clerk (local)
  itcfx,                               "addresses for fax
  itcpo,                               "spool print parameters SAPscript
  itcpp,                               "result of print SAPscript
  hrxblnr,                             "structure for special HR data
  kna1,                                "customers
  lfa1,                                "vendors
  payr,                                "check register
 *payr,                                "info about reprinted checks
  pcec,                                "check numbers
 *pcec,                                "local memory for PCEC-data
  pyordh,                              "payment order (no payment doc.)
  regud,                               "form print transfer data
  regut,                               "internal data for TemSe-access
 *regut,                               "local memory for regut-data
  reguta,                              "paying company codes of a REGUT
                                       "  entry for authority check
  reguv,                               "control records of paymnt progr.
  rfdt,                                "indx-table for posting data
  sadr,                                "interface to ADDR_GET   "SADR40A
  spell,                               "digits and numbers in words
  sscrfields,                          "for modifying UCOMM
  t000,                                "logical system of client
  t001,                                "company code information
 *t001,                                "company code information
  t001s,                               "accounting clerks
 *t001s,                               "accounting clerks
  t005,                                "countries
  t005u,                               "region names
  t005t,                               "country names
  t012,                                "house banks
  t012k,                               "house bank accounts
  t012d,                               "parameters DME and Z1
  t015l,                               "SCB-(LZB-)ratios Germany
  t015m,                               "names of months
  t015w,                               "instruction keys DME Germany
  t015z,                               "numbers in words (function unit)
  t021m,                               "sort
  t042b,                               "name of remittance advice form
  t042e,                               "payment method / company code
  t042l,                               "names of bank transaction codes
  t042m,                               "user numbers with the bank
  t042n,                               "bank transaction codes
  t042t,                               "text modules for payment forms
  t042v,
  t042z,                               "payment method / country
  t045t,                               "DME- user-identification
  tbslt,                               "posting key names
  tcurc,                               "currency codes (ISO)
  tcurx,                               "decimal places in currencies
  toa_dara,                            "archive index
  tlsep,                               "control table for list sep.
  tsp03,                               "printers
  tvoid,                               "void reason codes
  tvoit.                               "void reason codes, text


DATA: fecharevalidacion TYPE d.

PARAMETER: fchreval TYPE d OBLIGATORY.
fecharevalidacion = fchreval.

CALL FUNCTION 'OPEN_FORM'
  EXPORTING
    device   = 'PRINTER'
    form     = 'ZFO_REVALIDADOR'
    language = t001-spras
    OPTIONS  = itcpo
    dialog   = 'X'
  IMPORTING
    RESULT   = itcpp
  EXCEPTIONS
    form     = 1.

CALL FUNCTION 'WRITE_FORM'
  EXPORTING
    window  = 'CHECK'
  EXCEPTIONS
    window  = 1
    element = 2.

CALL FUNCTION 'CLOSE_FORM'.
