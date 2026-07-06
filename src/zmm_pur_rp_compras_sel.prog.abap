*&---------------------------------------------------------------------*
*&  Include           ZMM_PUR_RP_COMPRAS_SEL
*&---------------------------------------------------------------------*

*--------------------------------------------------------------------*
*    SELECTION-SCREEN
*--------------------------------------------------------------------*
SELECTION-SCREEN: BEGIN OF BLOCK b1 WITH FRAME TITLE TEXT-t01.
SELECT-OPTIONS: s_bedat FOR ekko-bedat OBLIGATORY,
                s_ebeln FOR ekko-ebeln,
                s_bsart FOR ekko-bsart,
                s_bukrs FOR ekko-bukrs NO INTERVALS,
                s_lifnr FOR ekko-lifnr,
                s_werks FOR ekpo-werks,
                s_matnr FOR ekpo-matnr.
SELECTION-SCREEN: END OF BLOCK b1.
*
SELECTION-SCREEN BEGIN OF BLOCK b2 WITH FRAME TITLE TEXT-t02.
PARAMETERS: p_vari TYPE slis_vari,
            p_opti AS CHECKBOX.
SELECTION-SCREEN END OF BLOCK b2.


*--------------------------------------------------------------------*
*    INITIALIZATION
*--------------------------------------------------------------------*
INITIALIZATION.

* Verifica permiso de acceso a la transacción
  PERFORM verificar_acceso.
  PERFORM campos_por_defecto.

  gv_repid = sy-repid.
* Set Options: save variants userspecific or general
  gv_save = 'A'.
* Initialization variant
  CLEAR gs_variant.
  gs_variant-report = gv_repid.
* Get default variant
  gx_variant = gs_variant.
  CALL FUNCTION 'REUSE_ALV_VARIANT_DEFAULT_GET'
    EXPORTING
      i_save     = gv_save
    CHANGING
      cs_variant = gx_variant
    EXCEPTIONS
      not_found  = 2.

  IF sy-subrc = 0.
    p_vari = gx_variant-variant.
  ENDIF.


*&---------------------------------------------------------------------*
*  AT SELECTION-SCREEN.
*&---------------------------------------------------------------------*
AT SELECTION-SCREEN.

  SELECT FROM t001        AS t
         INNER JOIN t001z AS z
         ON t~bukrs = z~bukrs
    FIELDS t~bukrs,
           t~butxt,
           z~paval
    WHERE t~bukrs IN @s_bukrs[]  AND
          z~party = 'TAXNR'
    INTO TABLE @gt_t001.

  LOOP AT gt_t001 INTO DATA(ls_t001).
    AUTHORITY-CHECK OBJECT 'F_BKPF_BUK'
           ID 'BUKRS' FIELD ls_t001-bukrs
           ID 'ACTVT' FIELD '03'.    "Visualizar

    IF sy-subrc <> 0.
*     Ud. carece de autorización para la sociedad &.
      MESSAGE e460(f5) WITH ls_t001-bukrs.
      LEAVE PROGRAM.
    ENDIF.
  ENDLOOP.

  IF NOT p_vari IS INITIAL.
    MOVE gs_variant TO gx_variant.
    MOVE p_vari TO gx_variant-variant.
    CALL FUNCTION 'REUSE_ALV_VARIANT_EXISTENCE'
      EXPORTING
        i_save     = gv_save
      CHANGING
        cs_variant = gx_variant.
    gs_variant = gx_variant.
  ELSE.
    CLEAR gs_variant.
    gs_variant-report = gv_repid.
  ENDIF.


* Process on value request
AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_vari.
  PERFORM f4_for_variant.
