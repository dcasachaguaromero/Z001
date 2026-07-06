FUNCTION z_mm_pur_stock_a_fecha.
*"----------------------------------------------------------------------
*"*"Interfase local
*"  IMPORTING
*"     REFERENCE(I_BUKRS) TYPE  BUKRS
*"     REFERENCE(I_BEDAT) TYPE  BEDAT
*"     REFERENCE(I_MATNR) TYPE  MATNR
*"     REFERENCE(I_WERKS) TYPE  EWERK
*"  EXPORTING
*"     REFERENCE(O_MENGE) TYPE  BSTMG
*"----------------------------------------------------------------------

  TYPES : BEGIN OF ty_list,
            text(256) TYPE c,
          END OF ty_list.

  DATA : is_rspar TYPE rsparams,
         it_rspar TYPE TABLE OF rsparams,
         it_list  TYPE STANDARD TABLE OF abaplist,
         it_list1 TYPE STANDARD TABLE OF ty_list.

  DATA: lv_menge  TYPE c LENGTH 20.

  CLEAR : is_rspar.

* Fecha de selección
  is_rspar-selname = 'DATUM'.
  is_rspar-kind    = 'S'.
  is_rspar-low     = i_bedat.
  is_rspar-high    = i_bedat.
  is_rspar-sign    = 'I'.
  is_rspar-option  = 'BT'.
  APPEND is_rspar TO it_rspar.

* Número de material
  is_rspar-selname = 'MATNR'.
  is_rspar-kind    = 'S'.
  is_rspar-low     = i_matnr.
  is_rspar-high    = i_matnr.
  is_rspar-sign    = 'I'.
  is_rspar-option  = 'BT'.
  APPEND is_rspar TO it_rspar.

* Sociedad
  is_rspar-selname = 'BUKRS'.
  is_rspar-kind    = 'S'.
  is_rspar-low     = i_bukrs.
  is_rspar-high    = i_bukrs.
  is_rspar-sign    = 'I'.
  is_rspar-option  = 'BT'.
  APPEND is_rspar TO it_rspar.

* Centro
  is_rspar-selname = 'WERKS'.
  is_rspar-kind    = 'S'.
  is_rspar-low     = i_werks.
  is_rspar-high    = i_werks.
  is_rspar-sign    = 'I'.
  is_rspar-option  = 'BT'.
  APPEND is_rspar TO it_rspar.

* Tipo de stock
  is_rspar-selname = 'LGBST'.
  is_rspar-kind    = 'P'.
  is_rspar-low     = 'X'.
  is_rspar-sign    = 'I'.
  is_rspar-option  = 'EQ'.
  APPEND is_rspar TO it_rspar.

  is_rspar-selname = 'BWBST'.
  is_rspar-kind    = 'P'.
  is_rspar-low     = ' '.
  is_rspar-sign    = 'I'.
  is_rspar-option  = 'EQ'.
  APPEND is_rspar TO it_rspar.

  is_rspar-selname = 'SBBST'.
  is_rspar-kind    = 'P'.
  is_rspar-low     = ' '.
  is_rspar-sign    = 'I'.
  is_rspar-option  = 'EQ'.
  APPEND is_rspar TO it_rspar.

* Opciones
  is_rspar-selname = 'PA_SUMFL'.
  is_rspar-kind    = 'P'.
  is_rspar-low     = 'X'.
  is_rspar-sign    = 'I'.
  is_rspar-option  = 'EQ'.
  APPEND is_rspar TO it_rspar.

  is_rspar-selname = 'XSUM'.
  is_rspar-kind    = 'P'.
  is_rspar-low     = ' '.
  is_rspar-sign    = 'I'.
  is_rspar-option  = 'EQ'.
  APPEND is_rspar TO it_rspar.

  is_rspar-selname = 'XCHAR'.
  is_rspar-kind    = 'P'.
  is_rspar-low     = ' '.
  is_rspar-sign    = 'I'.
  is_rspar-option  = 'EQ'.
  APPEND is_rspar TO it_rspar.

  is_rspar-selname = 'NOSTO'.
  is_rspar-kind    = 'P'.
  is_rspar-low     = ' '.
  is_rspar-sign    = 'I'.
  is_rspar-option  = 'EQ'.
  APPEND is_rspar TO it_rspar.


  SUBMIT rm07mlbd WITH SELECTION-TABLE it_rspar EXPORTING LIST TO MEMORY AND RETURN.

  CALL FUNCTION 'LIST_FROM_MEMORY'
    TABLES
      listobject = it_list
    EXCEPTIONS
      not_found  = 1
      OTHERS     = 2.

  IF it_list[] IS INITIAL.
    CLEAR: o_menge.
    RETURN.
  ENDIF.

  CALL FUNCTION 'LIST_TO_ASCI'
    TABLES
      listasci   = it_list1
      listobject = it_list.

  READ TABLE it_list1 INTO DATA(ls_list1) INDEX 4.
  IF sy-subrc = 0.
    lv_menge = ls_list1-text+134(18).
    TRANSLATE lv_menge USING '. '.
    CONDENSE lv_menge NO-GAPS.
    TRANSLATE lv_menge USING ',.'.

    o_menge = lv_menge.
  ELSE.
    CLEAR: o_menge.
  ENDIF.

ENDFUNCTION.
