FUNCTION-POOL zdte_contabiliza.             "MESSAGE-ID ..
*       Batchinputdata of single transaction
DATA:   bdcdata LIKE bdcdata    OCCURS 0 WITH HEADER LINE.
*       messages of call transaction
DATA:   messtab LIKE bdcmsgcoll OCCURS 0 WITH HEADER LINE.
*       error session opened (' ' or 'X')

TABLES: zdte_doc_rec    ,
        zdte_doc_rec_ref,
        ekko            ,
        ekpo            ,
        lfa1.

DATA:
  lt_dte_doc_rec     TYPE TABLE OF zdte_doc_rec     WITH HEADER LINE,
  lt_dte_doc_rec_ref TYPE TABLE OF zdte_doc_rec_ref WITH HEADER LINE,
  wa_dte_doc_rec     TYPE          zdte_doc_rec,
  wa_dte_doc_rec_ref TYPE          zdte_doc_rec_ref.

DATA:
  ld_ebeln    TYPE bapimepoheader-po_number,
  ld_bukrs    TYPE t001z-bukrs,
  ld_folio    TYPE bapi_incinv_create_header-ref_doc_no,
  ld_tipodte  TYPE zdte_doc_rec-tipodte,
  ld_folioref TYPE zdte_doc_rec_ref-folioref.

* crea factura desde datos de OC
DATA ltab_return          TYPE TABLE OF bapiret2                  .
DATA lstr_return          TYPE bapiret2                           .
DATA lt_poitem            TYPE TABLE OF bapimepoitem              .

DATA lt_itemdata          TYPE TABLE OF bapi_incinv_create_item   .
DATA ls_poheader          TYPE bapimepoheader                     .
DATA ls_poitem            TYPE bapimepoitem                       .
DATA ls_headerdata        TYPE bapi_incinv_create_header          .
DATA lstr_headerdata      TYPE bapi_incinv_create_header          .
DATA ls_itemdata          TYPE bapi_incinv_create_item            .
DATA lt_taxdata           TYPE TABLE OF bapi_incinv_create_tax WITH HEADER LINE.
DATA lt_poaccount         TYPE TABLE OF bapimepoaccount           .
DATA ls_poaccount         TYPE          bapimepoaccount           .
DATA lt_accountingdata    TYPE TABLE OF bapi_incinv_create_account.
DATA ls_accountingdata    TYPE          bapi_incinv_create_account.
DATA lt_pohistory         TYPE TABLE OF bapiekbe                  .
DATA lt_pohistory_anul    TYPE TABLE OF bapiekbe                  .
DATA ls_pohistory         TYPE          bapiekbe                  .
DATA ls_pohistory_aux     TYPE          bapiekbe                  .
DATA lt_pohistory_totals  TYPE TABLE OF bapiekbes                 .
DATA ls_pohistory_totals  TYPE          bapiekbes                 .

DATA vl_continue(1).
DATA vl_mat_doc           TYPE bapiekbe-mat_doc                   .
DATA vl_mat_year          TYPE bapiekbe-doc_year                  .
DATA vl_matdoc_itm        TYPE bapiekbe-matdoc_itm                .
DATA vl_invoice_doc_item  TYPE bapi_incinv_create_item-invoice_doc_item.
DATA ld_gross_amount      TYPE bapi_incinv_create_header-gross_amount.

DATA: BEGIN OF t_salida OCCURS 0,
        folio(10),
        rut(10),
        belnr(10),
        message(240).
DATA: END OF t_salida.

DATA: BEGIN OF t_item_montos OCCURS 0,
        po_number    TYPE bstnr,
        po_item      TYPE ebelp,
        quantity     TYPE bstmg,
        po_unit      TYPE bstme,
        net_price    TYPE bapicurext,
        price_unit   TYPE epein,
        item_amount  TYPE bapiwrbtr,
        tax_code     TYPE mwskz_mrm,
        taxjurcode   TYPE txjcd,
        val_loccur   TYPE val_loccurr,
        val_forcur   TYPE val_forcurr,
        currency     TYPE waers,
        loc_curr_iso TYPE waers.
DATA: END OF t_item_montos.

DATA: BEGIN OF t_tolerancia OCCURS 0,
        base     TYPE zdte_doc_rec-mntneto, "calculo base de diferencia de moneda
        calc     TYPE zdte_doc_rec-mntneto, "calculo
        dist     TYPE zdte_doc_rec-mntneto, "distribucion
        diff     TYPE zdte_doc_rec-mntneto, "diferencia entre monto factura y posiciones
        currency TYPE waers.
DATA: END OF t_tolerancia.

DATA: vg_monto_total_l  TYPE zdte_doc_rec-mntneto,
      vg_monto_total_d  TYPE zdte_doc_rec-mntneto,
      vg_monto_quantity TYPE bstmg.

DATA vg_mwskz       TYPE ekpo-mwskz.
DATA vg_proveedor   TYPE lfa1-name1.
DATA vg_monto_neto  TYPE zdte_doc_rec-mntneto.

DATA v_line_amount TYPE bapimepoitem-net_price.
DATA vl_currency   TYPE ekko-waers.
