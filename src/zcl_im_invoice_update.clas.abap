class ZCL_IM_INVOICE_UPDATE definition
  public
  final
  create public .

*"* public components of class ZCL_IM_INVOICE_UPDATE
*"* do not include other source files here!!!
public section.

  interfaces IF_BADI_INTERFACE .
  interfaces IF_EX_INVOICE_UPDATE .
protected section.
*"* protected components of class ZCL_IM_INVOICE_UPDATE
*"* do not include other source files here!!!
private section.
*"* private components of class ZCL_IM_INVOICE_UPDATE
*"* do not include other source files here!!!
ENDCLASS.



CLASS ZCL_IM_INVOICE_UPDATE IMPLEMENTATION.


METHOD if_ex_invoice_update~change_at_save.

  TYPES: BEGIN OF ty_info,
           gjahr TYPE gjahr,  " año
           buzei TYPE rblgp, " posicion

           ebeln TYPE ebeln,  " Pedido
           ebelp TYPE ebelp,  " Posición de pedido.

           anln1 TYPE anln1, " Código Activo
           anln2 TYPE anln2,

           wrbtr TYPE wrbtr,  " monto (Neto).
           mwskz TYPE mwskz,  " Indicador de Impuesto.
         END OF ty_info.

  DATA: it_info TYPE TABLE OF ty_info.
  DATA: wa_info TYPE ty_info.

  DATA: wa_rseg_new TYPE mrmrseg.
  DATA: wa_rbco_new TYPE mrmrbco.

**Se deshabilita obligatoriedad de campo agencia
*  IF s_rbkp_new-zz_agencia IS INITIAL.
*    MESSAGE e398(00) WITH TEXT-e01 space space space
*    RAISING error_with_message.
*  ENDIF.

  LOOP AT ti_rseg_new INTO wa_rseg_new.
    MOVE-CORRESPONDING wa_rseg_new TO wa_info.
* ini Waldo Alarcón - Visioone - 12-04-2021
*    READ TABLE ti_rbco_new INTO wa_rbco_new WITH KEY gjahr = wa_info-gjahr  buzei = wa_info-buzei.
*    IF sy-subrc = 0.
*      wa_info-anln1 = wa_rbco_new-anln1.
*      wa_info-anln2 = wa_rbco_new-anln2.
*    ENDIF.
*    APPEND wa_info TO it_info.
    LOOP AT ti_rbco_new INTO wa_rbco_new WHERE gjahr = wa_info-gjahr
                                          AND  buzei = wa_info-buzei.
      wa_info-anln1 = wa_rbco_new-anln1.
      wa_info-anln2 = wa_rbco_new-anln2.
      wa_info-wrbtr = wa_rbco_new-wrbtr.

      APPEND wa_info TO it_info.
    ENDLOOP.
* fin  Waldo Alarcón - Visioone - 12-04-2021

  ENDLOOP.

  EXPORT it_info = it_info TO MEMORY ID 'CREWVALUE'.
ENDMETHOD.


method IF_EX_INVOICE_UPDATE~CHANGE_BEFORE_UPDATE.

endmethod.


method IF_EX_INVOICE_UPDATE~CHANGE_IN_UPDATE.

endmethod.
ENDCLASS.
