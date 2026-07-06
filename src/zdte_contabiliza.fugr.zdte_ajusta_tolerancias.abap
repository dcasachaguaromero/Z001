FUNCTION zdte_ajusta_tolerancias.
*"----------------------------------------------------------------------
*"*"Interfase local
*"  IMPORTING
*"     VALUE(IT_ITEMS) TYPE  BAPI_INCINV_CREATE_ITEM_T
*"     VALUE(IT_MONTO_ITEMS) TYPE  ZDTE_ITEM_MONTOS_T
*"     VALUE(IV_MNT_NETO) TYPE  ZMNT_NETO
*"  EXPORTING
*"     REFERENCE(OT_ITEMS) TYPE  BAPI_INCINV_CREATE_ITEM_T
*"     REFERENCE(OV_SUPERA) TYPE  BOOLEAN
*"  EXCEPTIONS
*"      NO_ITEMS
*"----------------------------------------------------------------------
  DATA: BEGIN OF ls_tole,
          waerk TYPE waers,      "Moneda del pedido
          base  TYPE zmnt_neto,  "Tolerancia en moneda local
          waers TYPE waers,      "Moneda local
          calc  TYPE zmnt_neto,  "calculo
          dist  TYPE zmnt_neto,  "distribucion
          diff  TYPE zmnt_neto,  "difer
        END OF ls_tole.

  DATA: ls_monto_items TYPE zdte_item_montos,
        ls_items       TYPE bapi_incinv_create_item.

  DATA: lt_tole LIKE TABLE OF ls_tole.

  DATA: lv_low            TYPE rvari_val_255,
        lv_monto_total_l  TYPE zmnt_neto,
        lv_monto_total_d  TYPE zmnt_neto,
        lv_monto_quantity TYPE bstmg,
        lv_line_amount    TYPE bapimepoitem-net_price,
        lv_mnt_neto_ext   TYPE bapicurr-bapicurr.

  DATA: lv_aux1 TYPE i.
  DATA: lv_aux2 TYPE p DECIMALS 2.
  DATA: lv_aux3 TYPE p DECIMALS 2.


* Ajustar montos porque viene mal
*  LOOP AT it_items INTO ls_items.
*    ls_items-item_amount = ls_items-item_amount / 100.
*    MODIFY it_items FROM ls_items TRANSPORTING item_amount.
*  ENDLOOP.
*
*  LOOP AT it_monto_items INTO ls_monto_items.
*    ls_monto_items-item_amount = ls_monto_items-item_amount / 100.
*    MODIFY it_monto_items FROM ls_monto_items TRANSPORTING item_amount.
*  ENDLOOP.

  ot_items[] = it_items[].

  READ TABLE it_monto_items INTO ls_monto_items INDEX 1.
  IF sy-subrc <> 0.
    RAISE no_items.
  ENDIF.

* Convertir el monto neto a formato externo
  CALL FUNCTION 'BAPI_CURRENCY_CONV_TO_EXTERNAL'
    EXPORTING
      currency        = ls_monto_items-loc_curr_iso
      amount_internal = iv_mnt_neto
    IMPORTING
      amount_external = lv_mnt_neto_ext.

  iv_mnt_neto = lv_mnt_neto_ext.

* Determinar tolerancias configuradas en transacción STVARV
* UF = IV_TOLE_UF
  CLEAR: lv_low.
  SELECT SINGLE low INTO lv_low FROM tvarvc
    WHERE name = 'IV_TOLE_UF' AND
          type = 'P'          AND
          numb = '0000'.
  IF sy-subrc = 0.
    CLEAR: ls_tole.
    ls_tole-waerk = 'UF'.
    ls_tole-base  = lv_low.
    APPEND ls_tole TO lt_tole.
  ENDIF.

* USD = IV_TOLE_USD
  CLEAR: lv_low.
  SELECT SINGLE low INTO lv_low FROM tvarvc
    WHERE name = 'IV_TOLE_USD' AND
          type = 'P'           AND
          numb = '0000'.

  IF sy-subrc = 0.
    CLEAR: ls_tole.
    ls_tole-waerk = 'USD'.
    ls_tole-base  = lv_low.
    APPEND ls_tole TO lt_tole.
  ENDIF.

  CLEAR: lv_monto_total_l , lv_monto_total_d , lv_monto_quantity.

  LOOP AT it_monto_items INTO ls_monto_items.
    lv_monto_total_l  = lv_monto_total_l + ls_monto_items-item_amount.
    lv_monto_total_d  = lv_monto_total_d + ls_monto_items-val_forcur.
    lv_monto_quantity = lv_monto_quantity + ls_monto_items-quantity.
  ENDLOOP.

  READ TABLE lt_tole INTO ls_tole WITH KEY waerk = ls_monto_items-currency.

  ls_tole-diff = iv_mnt_neto - lv_monto_total_l.
  ls_tole-calc = ls_tole-base * lv_monto_total_d.

  IF abs( ls_tole-diff ) <= ls_tole-calc.    "Tolerancia permitida
*   Distribuir diferencias
    LOOP AT ot_items INTO ls_items.
*     Porcentaje
      IF lv_monto_quantity IS INITIAL.
        lv_monto_quantity = 1.
      ENDIF.

      IF NOT ls_items-quantity IS INITIAL.
        lv_aux1 = ( ls_items-quantity * 100 ) /  lv_monto_quantity.
      ELSE.
        lv_aux1 = 100 / lv_monto_quantity.
      ENDIF.

*     Valor a sumar/restar
      lv_aux2 = ( lv_aux1 * ls_tole-diff ) / 100.

      AT LAST.
*       Para el último asignar la diferencia
        lv_aux2 = ls_tole-diff - lv_aux3.
      ENDAT.

      ls_items-item_amount = ls_items-item_amount + lv_aux2.
      lv_line_amount       = ls_items-item_amount.

      MODIFY ot_items FROM ls_items TRANSPORTING item_amount.
      ADD lv_aux2 TO lv_aux3. "Acumula diferencias.
    ENDLOOP.
  ELSE.
    ov_supera = abap_true.
  ENDIF.

ENDFUNCTION.
