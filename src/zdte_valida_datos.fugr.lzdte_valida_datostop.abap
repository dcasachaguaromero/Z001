FUNCTION-POOL zdte_valida_datos.            "MESSAGE-ID ..

TABLES : ekko, ekpo, lfa1, lfb1, ekbe.

DATA: lv_bukrs      TYPE bukrs.
DATA: lv_bukrs2     TYPE bukrs.
DATA: lv_butxt      TYPE t001-butxt.
DATA: lv_adrnr      TYPE t001-adrnr.
DATA: lv_party      TYPE t001z-party.
DATA: lv_city1      TYPE adrc-city1,
      lv_street     TYPE adrc-street,
      lv_house_num1 TYPE adrc-house_num1,
      lv_dir(100)   TYPE c,
      lv_error      TYPE c.

DATA: wa_data  TYPE zdte_doc_rec.
DATA: ti_ref   TYPE STANDARD TABLE OF zdte_doc_rec_ref WITH HEADER LINE.
DATA: wa_ref   TYPE zdte_doc_rec_ref.

DATA: lv_null  TYPE c,
      lv_tipo  TYPE c,
      lv_exist TYPE c,
      lv_corr  TYPE c,
      lv_null2 TYPE c,
      lv_hes   TYPE c.
