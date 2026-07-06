*&---------------------------------------------------------------------*
*& Report: < ZEY_GDS_CORRECTION > *
*& Author: < EY_DES02 > *
*& Description: < ReSQ Correction > *
*& Date: <20-12-2019> *
*& Transport Number: < ECDK917080 > *
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&  Include           ZXF48U01
*&---------------------------------------------------------------------*
*{   INSERT         ECPK900217                                        2
*&---------------------------------------------------------------------*
*&  Include           ZXF48U01
*&---------------------------------------------------------------------
*&  Compañía   : Banmedica
*&  Autor      : Crystalis Consulting Chile - Pablo Cabezas Melendez
*&  Funcional  : Crystalis Consulting Chile - Oscar Agudelo Prado
*&  Fecha      : 30.08.2013
*&  Objetivo   : Solución integral de pagos
*&--------------------------------------------------------------------
* Proceso: Inserta los documentos generados en la tabla ZFITR020_T01
*--------------------------------------------------------------------*
TABLES: ZFITR020_T01.
*
TYPES: BEGIN OF TY_ZFITR020_T03,
         ID_PROCESO     like ZFITR020_T03-ID_PROCESO   ,
         CLASE_DOC      like ZFITR020_T03-CLASE_DOC    ,
         CAMBIO_ESTADO  like ZFITR020_T03-CAMBIO_ESTADO,
       END OF TY_ZFITR020_T03.

DATA: TI_ZFITR020_T03 TYPE TABLE OF TY_ZFITR020_T03 WITH HEADER LINE.

data: wa_doc_head_tab like line of doc_head_tab.
data: wa_doc_item_tab1 like line of doc_item_Tab.
data: wa_doc_item_tab2 like line of doc_item_Tab.

data: lv_date like ZFITR020_T01-BUDAT.
data: lv_var  like ZFITR020_T04-VALOR.

clear wa_doc_head_tab.
clear wa_doc_item_tab1.
clear wa_doc_item_tab2.

*Begin of change: ReSQ Correction INDEX READ on an unsorted Internal TABLE 20/12/2019 EY_DES02 ECDK917080 *
SORT DOC_HEAD_TAB .
*End of change: ReSQ Correction for INDEX READ on an unsorted Internal TABLE 20/12/2019 EY_DES02 ECDK917080 *
  read table doc_head_tab into wa_doc_head_tab index 1.

*Begin of change: ReSQ Correction INDEX READ on an unsorted Internal TABLE 20/12/2019 EY_DES02 ECDK917080 *
SORT DOC_ITEM_TAB .
*End of change: ReSQ Correction for INDEX READ on an unsorted Internal TABLE 20/12/2019 EY_DES02 ECDK917080 *
  READ TABLE doc_item_Tab into wa_doc_item_tab1 INDEX 1.
*ReSQ: No Need Of Change Internal Table DOC_ITEM_TAB Already Sorted
  READ TABLE doc_item_Tab into wa_doc_item_tab2 INDEX 2.

"la idea de esto es evitar el llenado de documentos
"inecesarios puesto por que no van a ser ocupados.
select single valor into lv_var
  from ZFITR020_T04
  where NOMBRE = 'FECHA_T01'.

lv_date = lv_var.

"en la tabla de configuracion se excluyen los documentos
"con fecha de contabilizacion menores a fecha_t01
if wa_doc_head_tab-bldat > lv_date.
  SELECT ID_PROCESO CLASE_DOC CAMBIO_ESTADO into table TI_ZFITR020_T03
    from ZFITR020_T03.

  READ TABLE TI_ZFITR020_T03 with key CLASE_DOC = wa_doc_head_tab-blart.

  if sy-subrc eq 0.

    ZFITR020_T01-BUKRS  =  wa_doc_head_tab-BUKRS.
    ZFITR020_T01-bldat  =  wa_doc_head_tab-bldat.
    ZFITR020_T01-BLART  =  wa_doc_head_tab-BLART.
    ZFITR020_T01-BELNR  =  wa_doc_head_tab-BELNR.
    ZFITR020_T01-BUDAT  =  wa_doc_head_tab-BUDAT.
    ZFITR020_T01-GJAHR  =  wa_doc_head_tab-GJAHR.
    ZFITR020_T01-BVORG  =  wa_doc_head_tab-BVORG.

    ZFITR020_T01-WRBTR  =  wa_doc_item_tab1-WRBTR.
    ZFITR020_T01-WAERS  =  wa_doc_item_tab1-PSWSL.

    ZFITR020_T01-BKTXT  =  wa_doc_head_tab-BKTXT.
    ZFITR020_T01-XBLNR  =  wa_doc_head_tab-XBLNR.
    ZFITR020_T01-USNAM  =  wa_doc_head_tab-USNAM.

    if wa_doc_item_tab1-LIFNR is not INITIAL.
      ZFITR020_T01-LIFNR  =  wa_doc_item_tab1-LIFNR.
      ZFITR020_T01-EMPFB  =  wa_doc_item_tab1-EMPFB.

    ELSEIF wa_doc_item_tab2-LIFNR is not  INITIAL.
      ZFITR020_T01-LIFNR  =  wa_doc_item_tab2-LIFNR.
      ZFITR020_T01-EMPFB  =  wa_doc_item_tab2-EMPFB.
    endif.

    if wa_doc_item_tab1-shkzg eq 'S' or wa_doc_item_tab2-shkzg eq 'S'.
      if wa_doc_item_tab1-shkzg eq 'S'.
        ZFITR020_T01-HKONTD =  wa_doc_item_tab1-HKONT.
      ELSEif wa_doc_item_tab2-shkzg eq 'S'..
        ZFITR020_T01-HKONTD =  wa_doc_item_tab2-HKONT.
      endif.
    endif.

    if wa_doc_item_tab1-shkzg eq 'H' or wa_doc_item_tab2-shkzg eq 'H'.
      if wa_doc_item_tab1-shkzg eq 'H'.
        ZFITR020_T01-HKONTH =  wa_doc_item_tab1-HKONT.
      ELSEif wa_doc_item_tab2-shkzg eq 'H'..
        ZFITR020_T01-HKONTH =  wa_doc_item_tab2-HKONT.
      endif.
    endif.

    ZFITR020_T01-FECHA_INGRESO = sy-datum.
    INSERT ZFITR020_T01.

  endif.
endif.





*}   INSERT

*{   REPLACE        ECPK900217                                        1
*\
*\*  Carlos Hidalgo - Quintec 30.04.210
*\*  Validacion de periodo tributable para Contab. IVA
*\
*\TABLES: bsik.
*\
*\DATA v_err(5) TYPE c.
*\DATA  det_bkpf LIKE bkpf.
*\DATA lt_ebseg TYPE TABLE OF f180a_doc_item.
*\DATA  det_bseg LIKE bseg.
*\DATA: nc_bloqueadas LIKE bsik-dmbtr.
*\DATA: fa_bloqueadas LIKE bsik-dmbtr.
*\DATA: saldo LIKE bsik-dmbtr.
*\DATA:  zfbdt-aux LIKE  bsik-zfbdt.
*\
*\
*\GET PARAMETER ID 'E01' FIELD v_err.
*\
*\IF v_err = 'ERROR'.
*\  MESSAGE 'Documento fuera de periodo tributario' TYPE 'E'.
*\ENDIF.
*\
*\
*\
*\FIELD-SYMBOLS <fs1> TYPE ANY.
*\
*\READ TABLE doc_head_tab INTO det_bkpf INDEX 1.
*\
*\IF det_bkpf-blart = 'F0' OR
*\   det_bkpf-blart = 'F1'  OR
*\   det_bkpf-blart = 'F2'  OR
*\   det_bkpf-blart = 'F3'  OR
*\   det_bkpf-blart = 'F4'  OR
*\   det_bkpf-blart = 'F5'  OR
*\   det_bkpf-blart = 'F6'  OR
*\   det_bkpf-blart = 'F8'  OR
*\   det_bkpf-blart = 'F9'  OR
*\   det_bkpf-blart = 'FA'  OR
*\   det_bkpf-blart = 'FB'  OR
*\   det_bkpf-blart = 'FC'.
*\
*\
*\  ASSIGN ('(SAPMF05A)XBSEG[]') TO <fs1>.
*\
*\
*\  IF sy-subrc = 0.
*\    lt_ebseg[] = <fs1>.
*\
*\    LOOP AT lt_ebseg INTO det_bseg.
*\      IF det_bseg-bschl = '31'.
*\        SELECT SINGLE * FROM bsik WHERE bukrs = det_bkpf-bukrs
*\                                  AND   lifnr = det_bseg-lifnr
*\                                  AND   bschl = '21'
*\                                  AND   zlspr = 'Z'
*\                                  AND   zfbdt <= det_bseg-zfbdt.
*\        IF sy-subrc = 0.
*\          SELECT  * FROM bsik     WHERE bukrs = det_bkpf-bukrs
*\                                  AND   lifnr = det_bseg-lifnr
*\                                  AND   bschl = '21'
*\                                  AND   zfbdt <= det_bseg-zfbdt
*\                                  AND   zlspr = 'Z'.
*\
*\            nc_bloqueadas = nc_bloqueadas + bsik-dmbtr.
*\
*\            IF zfbdt-aux IS INITIAL OR bsik-zfbdt < zfbdt-aux.
*\              zfbdt-aux = bsik-zfbdt.
*\            ENDIF.
*\          ENDSELECT.
*\          SELECT  * FROM bsik     WHERE bukrs = det_bkpf-bukrs
*\                                  AND   lifnr = det_bseg-lifnr
*\                                  AND   bschl = '31'
*\                                  AND   zfbdt >= zfbdt-aux
*\                                  AND   zlspr = 'Z'.
*\            fa_bloqueadas = fa_bloqueadas + bsik-dmbtr.
*\          ENDSELECT.
*\
*\          saldo = fa_bloqueadas - nc_bloqueadas.
*\
*\          IF saldo < '0.00'.
*\            det_bseg-zlspr = 'Z'.
*\            MODIFY lt_ebseg FROM det_bseg.
*\          ENDIF.
*\        ENDIF.
*\      ENDIF.
*\
*\      MODIFY lt_ebseg FROM det_bseg.
*\    ENDLOOP.
*\
*\    <fs1> = lt_ebseg.
*\
*\    UNASSIGN <fs1>.
*\
*\  ENDIF.
*\
*\
*\ENDIF.
*\
*\** Fin Insert.

*  Carlos Hidalgo - Quintec 30.04.210
*  Validacion de periodo tributable para Contab. IVA

TABLES: bsik.

DATA v_err(5) TYPE c.
DATA  det_bkpf LIKE bkpf.
DATA lt_ebseg TYPE TABLE OF f180a_doc_item.
DATA  det_bseg LIKE bseg.
DATA: nc_bloqueadas LIKE bsik-dmbtr.
DATA: fa_bloqueadas LIKE bsik-dmbtr.
DATA: saldo LIKE bsik-dmbtr.
DATA:  zfbdt-aux LIKE  bsik-zfbdt.


GET PARAMETER ID 'E01' FIELD v_err.

IF v_err = 'ERROR'.
  MESSAGE 'Documento fuera de periodo tributario' TYPE 'E'.
ENDIF.



FIELD-SYMBOLS <fs1> TYPE ANY.

*ReSQ: No Need Of Change Internal Table DOC_HEAD_TAB Already Sorted
READ TABLE doc_head_tab INTO det_bkpf INDEX 1.

IF det_bkpf-blart = 'F0' OR
   det_bkpf-blart = 'F1'  OR
   det_bkpf-blart = 'F2'  OR
   det_bkpf-blart = 'F3'  OR
   det_bkpf-blart = 'F4'  OR
   det_bkpf-blart = 'F5'  OR
   det_bkpf-blart = 'F6'  OR
   det_bkpf-blart = 'F8'  OR
   det_bkpf-blart = 'F9'  OR
   det_bkpf-blart = 'FA'  OR
   det_bkpf-blart = 'FB'  OR
   det_bkpf-blart = 'FC'.


  ASSIGN ('(SAPMF05A)XBSEG[]') TO <fs1>.


  IF sy-subrc = 0.
    lt_ebseg[] = <fs1>.

    LOOP AT lt_ebseg INTO det_bseg.
      IF det_bseg-bschl = '31'.
        SELECT SINGLE * FROM bsik WHERE bukrs = det_bkpf-bukrs
                                  AND   lifnr = det_bseg-lifnr
                                  AND   bschl = '21'
                                  AND   zlspr = 'Z'
                                  AND   zfbdt <= det_bseg-zfbdt.
        IF sy-subrc = 0.
          SELECT  * FROM bsik     WHERE bukrs = det_bkpf-bukrs
                                  AND   lifnr = det_bseg-lifnr
                                  AND   bschl = '21'
                                  AND   zfbdt <= det_bseg-zfbdt
                                  AND   zlspr = 'Z'.

            nc_bloqueadas = nc_bloqueadas + bsik-dmbtr.

            IF zfbdt-aux IS INITIAL OR bsik-zfbdt < zfbdt-aux.
              zfbdt-aux = bsik-zfbdt.
            ENDIF.
          ENDSELECT.
          SELECT  * FROM bsik     WHERE bukrs = det_bkpf-bukrs
                                  AND   lifnr = det_bseg-lifnr
                                  AND   bschl = '31'
                                  AND   zfbdt >= zfbdt-aux
                                  AND   zlspr = 'Z'.
            fa_bloqueadas = fa_bloqueadas + bsik-dmbtr.
          ENDSELECT.

          saldo = fa_bloqueadas - nc_bloqueadas.

          IF saldo < '0.00'.
            det_bseg-zlspr = 'Z'.
            MODIFY lt_ebseg FROM det_bseg.
          ENDIF.
        ENDIF.
      ENDIF.

      MODIFY lt_ebseg FROM det_bseg.
    ENDLOOP.

    <fs1> = lt_ebseg.

    UNASSIGN <fs1>.

  ENDIF.


ENDIF.

** Fin Insert.
*}   REPLACE
