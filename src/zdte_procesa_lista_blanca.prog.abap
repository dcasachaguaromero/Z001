*&---------------------------------------------------------------------*
*& Report: < ZEY_GDS_CORRECTION > *
*& Author: < EY_DES04 > *
*& Description: < ReSQ Correction > *
*& Date: <24-12-2019> *
*& Transport Number: < ECDK917080 > *
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Report       :ZDTE_PROCESA_LISTA_BLANCA
*& Autor        : Carlos López - SCL
*& Fecha       	: 19.03.2018 20:31:03
*& Descripción 	: Reporte Lista Blanca
*&---------------------------------------------------------------------*

REPORT  zdte_procesa_lista_blanca
        NO STANDARD PAGE HEADING
        LINE-SIZE 255.

*-----------------------------------------------------------------------
* DESCRIPTION  : Reporte Lista Blanca
*
*
*
************************************************************************
* Historial de Modificaciones:
* ----------------------------------------------------------------------
* DATE      User ID    |TS Ver  | Transport Request  | Description
* ----------------------------------------------------------------------
*
*
*
************************************************************************

***************************************************
*Tablas
***************************************************
TABLES: zdte_doc_rec, zdte_doc_rec_ref , t001z , lfb1 , t000.

***************************************************
*Type pools
***************************************************
*type-pools:

***************************************************
*Constantes
***************************************************
*constants:

***************************************************
*Variables globales
***************************************************
*data:

***************************************************
*Estructuras
***************************************************

***************************************************
*Declaración tablas internas
***************************************************
DATA: lt_dte_doc_rec            TYPE TABLE OF zdte_doc_rec     WITH HEADER LINE,
      lt_dte_doc_rec_ref        TYPE TABLE OF zdte_doc_rec_ref WITH HEADER LINE,
      wa_doc_rec                TYPE          zdte_doc_rec                     ,
      wa_doc_rec_ref            TYPE          zdte_doc_rec_ref                 ,
      wa_listabcab              TYPE          zbmnc_listabcab.

DATA: BEGIN OF t_salida OCCURS 0,
        folio(10),
        rut(10),
        belnr(10),
        message(240).
DATA: END OF t_salida.

***************************************************
*SELECTION-SCREEN
***************************************************
SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE text-001.
SELECT-OPTIONS: p_fecha FOR zdte_doc_rec-fchrec.
SELECTION-SCREEN END OF BLOCK b1.

INITIALIZATION.
  AUTHORITY-CHECK OBJECT 'S_TCODE'
     ID 'TCD' FIELD sy-tcode.
  IF sy-subrc NE 0.
    MESSAGE e077(s#) WITH sy-tcode.
  ENDIF.

***************************************************
***START-OF-SELECTION
***************************************************
START-OF-SELECTION.
  DATA: w_cierre_cont TYPE zdte_cierre_cont.
  DATA: lv_index TYPE sy-tabix.

  PERFORM rutina.

***************************************************
***SUBRUTINAS
***************************************************

FORM rutina .
*
  DATA:
        vl_resultado  TYPE  subrc,
        vl_factura    TYPE  belnr_d,
        vl_ejercicio  TYPE  gjahr,
        vl_estado     TYPE  zdte_estado,
        vl_mensaje    TYPE  bapi_msg.
  DATA: lv_bukrs          TYPE bukrs.
  DATA: lv_LIFNR      TYPE LFA1-LIFNR.

  DATA: it_mensajes_1  LIKE bdcmsgcoll OCCURS 0 WITH HEADER LINE,
        it_mensajes_2  LIKE bdcmsgcoll OCCURS 0 WITH HEADER LINE.
  DATA: w_t001z TYPE t001z.

  RANGES r_estado FOR zdte_doc_rec-estado.

  CLEAR   t_salida.
  REFRESH: t_salida , r_estado.

  r_estado-sign   = 'I'.
  r_estado-option = 'EQ'.
  r_estado-low    = 'LB'.APPEND r_estado.
*  r_estado-low    = 'FM'.APPEND r_estado.

  "Buscamos Registros
  SELECT *
    INTO CORRESPONDING FIELDS OF TABLE lt_dte_doc_rec
    FROM zdte_doc_rec
   WHERE estado IN r_estado.


*********************************************************************
****VALIDA FECHA PARA CONTABILIZAR***********************************
  LOOP AT lt_dte_doc_rec INTO wa_doc_rec.
    CLEAR w_t001z.
    lv_index = sy-tabix.
*ResQ Comment:Correction not required as Select Single is used 24/12/2019 EY_DES04 ECDK917080 *
    SELECT SINGLE * INTO w_t001z
      FROM t001z
     WHERE paval EQ wa_doc_rec-rutrecep.

    SELECT SINGLE * INTO w_cierre_cont
      FROM zdte_cierre_cont
     WHERE bukrs EQ w_t001z-bukrs
       AND gjahr EQ sy-datum(4)
       AND monat EQ sy-datum+4(2).
*         AND budat_ini GE sy-datum
*         AND budat_fin LE sy-datum.

    IF w_cierre_cont-budat_ini <= sy-datum AND w_cierre_cont-budat_fin >= sy-datum.
      WRITE: / 'Cierre Contable Sociedad:' , w_t001z-bukrs ,  sy-datum(4) , sy-datum+4(2) , sy-datum.
      wa_doc_rec-borrar = 'X'.
      MODIFY lt_dte_doc_rec FROM wa_doc_rec INDEX lv_index.
      CONTINUE.
    ENDIF.
  ENDLOOP.

  DELETE lt_dte_doc_rec WHERE borrar EQ 'X'.

*********************************************************************
  IF lt_dte_doc_rec[] IS NOT INITIAL.
    LOOP AT lt_dte_doc_rec INTO wa_doc_rec.

      CLEAR   it_mensajes_1.
      REFRESH it_mensajes_1.

      SELECT SINGLE *
      INTO wa_listabcab
      FROM zbmnc_listabcab
      WHERE rut_proveedor EQ wa_doc_rec-rutemisor.
      IF sy-subrc EQ 0 .
        IF wa_doc_rec-tipodte EQ '33'."AFECTO
*          CALL FUNCTION 'ZDTE_CONT_LISTAS_BLANCAS_2'
*            EXPORTING
*              i_folio          = wa_doc_rec-folio
*              i_rutemisor      = wa_doc_rec-rutemisor
*              i_numero_cliente = wa_listabcab-numero_cliente
*              i_rutreceptor    = wa_doc_rec-rutrecep
*              i_monto_neto     = wa_doc_rec-mntneto
*              i_ctumode        = 'N'
*            IMPORTING
*              resultado        = vl_resultado
*              factura          = vl_factura
*              ejercicio        = vl_ejercicio
*              estado           = vl_estado
*              mensaje          = vl_mensaje
*            TABLES
*              mensaje_salida   = it_mensajes_1.
*
*          LOOP AT it_mensajes_1.
*            MOVE-CORRESPONDING it_mensajes_1 TO it_mensajes_2.
*            APPEND it_mensajes_2.
*          ENDLOOP.

          PERFORM zdte_fb60_33 USING wa_doc_rec-folio wa_doc_rec-fchemis wa_doc_rec-rutemisor wa_listabcab-numero_cliente
                wa_doc_rec-rutrecep wa_doc_rec-mnttotal wa_doc_rec-iva CHANGING vl_factura vl_resultado lv_bukrs lv_lifnr.

          IF vl_resultado EQ 0.
            wa_doc_rec-estado   = 'CO'.
            wa_doc_rec-belnr    = vl_factura.
            wa_doc_rec-tcode    = 'ZFITR006B'.
            wa_doc_rec-gjahr    = sy-datum(4).
            wa_doc_rec-message  = 'LB Afecta - Contabilización ok'.
            "Actualizamos Tabla DB
            MODIFY zdte_doc_rec FROM wa_doc_rec.
            IF sy-subrc EQ 0.
              COMMIT WORK AND WAIT.
            ENDIF.
            PERFORM update_doc_fi USING lv_bukrs wa_doc_rec-belnr wa_doc_rec-gjahr lv_lifnr.
            COMMIT WORK AND WAIT.
          ENDIF.

        ELSEIF wa_doc_rec-tipodte EQ '34'."Excento

          PERFORM zdte_fb60 USING wa_doc_rec-folio wa_doc_rec-fchemis wa_doc_rec-rutemisor wa_listabcab-numero_cliente
                wa_doc_rec-rutrecep wa_doc_rec-mntneto CHANGING vl_factura vl_resultado lv_bukrs lv_lifnr.

          IF vl_resultado EQ 0.
            wa_doc_rec-estado   = 'CO'.
            wa_doc_rec-belnr    = vl_factura.
            wa_doc_rec-tcode    = 'FB60'.
            wa_doc_rec-gjahr    = sy-datum(4).
            wa_doc_rec-message  = 'LB Exenta - Contabilización ok'.
            "Actualizamos Tabla DB
            MODIFY zdte_doc_rec FROM wa_doc_rec.

            IF sy-subrc EQ 0.
              COMMIT WORK AND WAIT.
            ENDIF.

            PERFORM update_doc_fi USING lv_bukrs wa_doc_rec-belnr wa_doc_rec-gjahr lv_lifnr .
            COMMIT WORK AND WAIT.
          ENDIF.
        ENDIF.


      ELSE.
        MESSAGE i666(01) WITH 'Proveedor no ingresado en Tabla Lista Blanca.'.
      ENDIF.

    ENDLOOP.

    LOOP AT it_mensajes_2." WHERE msgtyp = 'E'.
      CALL FUNCTION 'MESSAGE_TEXT_BUILD'
        EXPORTING
          msgid               = it_mensajes_2-msgid
          msgnr               = it_mensajes_2-msgnr
          msgv1               = it_mensajes_2-msgv1
          msgv2               = it_mensajes_2-msgv2
          msgv3               = it_mensajes_2-msgv3
          msgv4               = it_mensajes_2-msgv4
        IMPORTING
          message_text_output = t_salida-message.

      t_salida-folio = wa_doc_rec-folio.
      t_salida-rut   = wa_doc_rec-rutemisor.
      APPEND t_salida.
    ENDLOOP.

* Errores durante creacion de proveedores.

    FORMAT COLOR OFF INVERSE OFF.
    NEW-PAGE.
    WRITE : / 'Listado de Mensajes y Errores Internos'.
    ULINE.
    FORMAT COLOR 1.
    WRITE : / 'Usuario : ' , sy-uname, ' Fecha de carga :',
    sy-datum,' Programa :', sy-cprog.
    FORMAT COLOR OFF.
    ULINE.

    LOOP AT t_salida.
      WRITE: /   t_salida-folio,
              15 t_salida-rut,
              30 t_salida-message.
    ENDLOOP.

  ELSE.
    MESSAGE e666(01) WITH 'No hay datos para la consulta.'.
  ENDIF.

ENDFORM.                    " rutina
*&---------------------------------------------------------------------*
*&      Form  zdte_fb60
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM zdte_fb60 USING i_folio_ext i_fechaemi i_rutemisor i_numero_cliente i_rutreceptor i_monto_neto CHANGING i_factura i_resultado lv_bukrs i_lifnr.

  DATA: doc_header LIKE bapiache09,
        doc_item   LIKE bapiacgl09 OCCURS 0 WITH HEADER LINE,
        doc_values LIKE bapiaccr09 OCCURS 0 WITH HEADER LINE,
        doc_pay    LIKE bapiacap09 OCCURS 0 WITH HEADER LINE,
        return     LIKE bapiret2 OCCURS 0 WITH HEADER LINE,
        obj_type   LIKE bapiache08-obj_type,
        obj_key    LIKE bapiache02-obj_key,
        obj_sys    LIKE bapiache02-obj_sys,
        docnum     LIKE bkpf-belnr.
*
  DATA: ti_cab            TYPE STANDARD TABLE OF zbmnc_listabcab WITH HEADER LINE.
  DATA: ti_det            TYPE STANDARD TABLE OF zbmnc_listabdet WITH HEADER LINE.
  DATA  wa_cab            TYPE zbmnc_listabcab.
  DATA: lv_dat8(8)        TYPE c.
  DATA: lv_dat10(10)      TYPE c.
  DATA: lv_campo(40)      TYPE c.
  DATA: lv_pos            TYPE posnr_acc.
  DATA: lv_monto_cab      TYPE int4.
  DATA: lv_monto_cab_txt(15).
  DATA: lv_monto_det      TYPE int4,
        lv_monto_acu      TYPE int4,
        lv_diferencia     TYPE int4.
  DATA: lv_monto_det_txt(15).
  DATA  lv_asignacion     TYPE dzuonr.
  DATA  lv_lifnr          TYPE lfa1-lifnr.
  DATA w_bsik TYPE bsik.
  DATA: lv_obj_type LIKE  bapiache09-obj_type,
        lv_obj_key  LIKE  bapiache09-obj_key,
        lv_obj_sys  LIKE  bapiache09-obj_sys.
  DATA: lv_amount_internal TYPE c LENGTH 20.
  DATA: i_folio TYPE zdte_folio.
  DATA: lv_lfa1 TYPE lfa1.
  REFRESH : doc_item   , doc_values , DOC_PAY .
  CLEAR :   doc_header , lv_pos.
  i_resultado = 4.

  CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
    EXPORTING
      input  = i_folio_ext
    IMPORTING
      output = i_folio.

  SELECT SINGLE *
         FROM   t001z
         WHERE  paval EQ i_rutreceptor
         AND    party EQ 'TAXNR'.
  IF sy-subrc EQ 0.
    CASE t001z-bukrs.
      WHEN 'CL12' OR 'CL16' OR 'CL65'.
        lv_bukrs = t001z-bukrs.
    ENDCASE.
  ELSE.
    "Error
  ENDIF.

  doc_header-bus_act    = 'RFBU'.
  doc_header-username   = sy-uname.
  doc_header-comp_code  = lv_bukrs.
  doc_header-doc_date   = sy-datum.
  doc_header-pstng_date = sy-datlo.
  doc_header-header_txt = 'Listas Blancas Exento'.
  doc_header-doc_type   = 'F1'.
  doc_header-fisc_year  = sy-datum(4).
  doc_header-ref_doc_no = i_folio.
*  doc_header-ac_doc_no = docnum.

*Lee cabecera listas blancas
  SELECT  * INTO CORRESPONDING FIELDS OF TABLE ti_cab
    FROM zbmnc_listabcab
   WHERE sociedad        = lv_bukrs
     AND rut_proveedor   = i_rutemisor
     AND numero_cliente  = i_numero_cliente.

  IF sy-subrc EQ 0.
    SELECT * INTO CORRESPONDING FIELDS OF TABLE ti_det
      FROM zbmnc_listabdet
       FOR ALL ENTRIES IN ti_cab
     WHERE sociedad  = ti_cab-sociedad
       AND lifnr     = ti_cab-lifnr.
*       AND ceco      = ti_cab-ceco.

    IF sy-subrc EQ 0.

      LOOP AT ti_cab.
        CLEAR: lv_monto_cab, lv_monto_acu, lv_diferencia.

        SELECT SINGLE * INTO lv_lfa1
          FROM lfa1
         WHERE lifnr EQ ti_cab-lifnr.

        lv_monto_cab      = ( ti_cab-porcentaje * i_monto_neto ) / 100.
        lv_monto_cab      = ( ti_cab-porcentaje * i_monto_neto ) ."para monto clp
*        lv_monto_cab      =  lv_monto_cab / 100.

        lv_monto_cab_txt  = lv_monto_cab.
        CONDENSE lv_monto_cab_txt NO-GAPS.

        DATA:  vl_lineas  TYPE i,
               vl_indice1 TYPE i,
               vl_indice2 TYPE i.
        CLEAR: vl_lineas,
               vl_indice1,
               vl_indice2.
        SORT ti_det BY porcentaje DESCENDING.
        DESCRIBE TABLE ti_det LINES vl_lineas.

        SELECT SINGLE *
          FROM lfb1
         WHERE lifnr EQ ti_cab-lifnr
           AND bukrs EQ lv_bukrs.


        ADD 1 TO lv_pos.
*         Linea del Acreedor
        CLEAR doc_pay.
        doc_pay-itemno_acc = lv_pos.
        doc_pay-vendor_no  = ti_cab-lifnr.
        doc_pay-GL_ACCOUNT = lfb1-akont.
        doc_pay-pmnttrms   = 'ZC01'.
        doc_pay-pymt_meth  = 'V'.
        doc_pay-bline_date = i_fechaemi.
        doc_pay-item_text  = lv_lfa1-name1.
        doc_pay-tax_code   = 'C9'.
        APPEND doc_pay.

*       Fill Line 1 of Document Value.
        CLEAR doc_values.
        doc_values-itemno_acc = lv_pos.
        doc_values-currency_iso = 'CLP'.
        doc_values-amt_base   = lv_monto_cab * -1.
        doc_values-amt_doccur = lv_monto_cab * -1.
        APPEND doc_values.

        LOOP AT ti_det.
          ADD 1 TO vl_indice1.
          ADD 1 TO vl_indice2.
          ADD 1 TO lv_pos.

          CLEAR lv_monto_det.
          IF ti_det-porcentaje EQ 0.
            lv_monto_det      = ( ti_det-porcentaje * lv_monto_cab ) / 100.
          ELSE.
            lv_monto_det      = ( ti_det-porcentaje * lv_monto_cab ) / 100.
          ENDIF.

          lv_monto_acu = lv_monto_acu + lv_monto_det.

          "lv_monto_cab
          IF vl_indice2 EQ vl_lineas."para el ultimo registro.
            lv_diferencia = lv_monto_acu - lv_monto_cab.
*            lv_monto_det = lv_monto_det + lv_diferencia.
            lv_monto_det = lv_monto_det - lv_diferencia.
          ENDIF.

          CLEAR doc_item.
          doc_item-itemno_acc = lv_pos.
          doc_item-gl_account = ti_det-cta_contable.
          doc_item-acct_type  = 'S'.
          doc_item-pstng_date = sy-datlo.
          doc_item-item_text  = lv_lfa1-name1.
          doc_item-costcenter = ti_det-ceco.
          doc_item-tax_code = 'C9'.
*          doc_item-orderid = ''.
          APPEND doc_item.


*         Fill Line 1 of Document Value.
          CLEAR doc_values.
          doc_values-itemno_acc   = lv_pos.
          doc_values-currency_iso = 'CLP'.
          doc_values-amt_base     = lv_monto_det.
          doc_values-amt_doccur   = lv_monto_det.
          APPEND doc_values.


**         Fill Tax code
*          CLEAR doc_tax.
*          doc_tax-itemno_acc  = lv_pos.
**          doc_tax-gl_account  = ti_det-cta_contable.
**          doc_tax-COND_KEY   = ''.
*          doc_tax-acct_key    = 'VST'.
*          doc_tax-tax_code    = 'C9'.
*          APPEND doc_tax.


        ENDLOOP.
        EXIT.
      ENDLOOP.
    ENDIF.

  ENDIF.

  I_lifnr = ti_cab-lifnr.
* All tables filled - now call BAPI.
  CALL FUNCTION 'BAPI_ACC_DOCUMENT_POST'
    EXPORTING
      documentheader  = doc_header
  IMPORTING
        obj_type      = lv_obj_type
        obj_key       = lv_obj_key
        obj_sys       = lv_obj_sys
    TABLES
      accountgl       = doc_item
      currencyamount  = doc_values
      accountpayable  = doc_pay
*      accounttax      = doc_tax
      return          = return
*   EXTENSION1        =
            .
  LOOP AT return WHERE type = 'E'.
    EXIT.
  ENDLOOP.

  IF sy-subrc EQ 0.
    WRITE: / 'Error de contabilización.'.
  ELSE.
    READ TABLE return WITH KEY type = 'S'.
    IF sy-subrc EQ 0.
      i_factura    = lv_obj_key(10).
      i_resultado  = 0.
    ENDIF.

    CLEAR return.
    REFRESH return.
    CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
      EXPORTING
        wait   = 'X'
      IMPORTING
        return = return.

  ENDIF.

ENDFORM.                                                    "zdte_fb60

*&---------------------------------------------------------------------*
*&      Form  zdte_fb60_33
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM zdte_fb60_33 USING i_folio_ext i_fechaemi i_rutemisor i_numero_cliente i_rutreceptor i_monto i_monto_iva CHANGING i_factura i_resultado lv_bukrs I_lifnr.

  DATA: doc_header LIKE bapiache09,
        doc_item   LIKE bapiacgl09 OCCURS 0 WITH HEADER LINE,
        doc_values LIKE bapiaccr09 OCCURS 0 WITH HEADER LINE,
        doc_pay    LIKE bapiacap09 OCCURS 0 WITH HEADER LINE,
        doc_tax    LIKE bapiactx09 OCCURS 0 WITH HEADER LINE,
        return     LIKE bapiret2 OCCURS 0 WITH HEADER LINE,
        obj_type   LIKE bapiache08-obj_type,
        obj_key    LIKE bapiache02-obj_key,
        obj_sys    LIKE bapiache02-obj_sys,
        docnum     LIKE bkpf-belnr.

  DATA: ti_cab            TYPE STANDARD TABLE OF zbmnc_listabcab WITH HEADER LINE.
  DATA: ti_det            TYPE STANDARD TABLE OF zbmnc_listabdet WITH HEADER LINE.
  DATA  wa_cab            TYPE zbmnc_listabcab.
  DATA: lv_dat8(8)        TYPE c.
  DATA: lv_dat10(10)      TYPE c.
  DATA: lv_campo(40)      TYPE c.
  DATA: lv_pos            TYPE posnr_acc.
  DATA: lv_monto_cab      TYPE int4.
  DATA: lv_monto_cab_txt(15).
  DATA: lv_monto_det      TYPE int4,
        lv_monto_acu      TYPE int4,
        lv_diferencia     TYPE int4,
        lv_monto_det_prop TYPE int4,
        lv_monto_iva_prop LIKE doc_values-amt_base .
  DATA: lv_monto_det_txt(15).
  DATA  lv_asignacion     TYPE dzuonr.
  DATA  lv_lifnr          TYPE lfa1-lifnr.
  DATA w_bsik TYPE bsik.
  DATA: lv_obj_type LIKE  bapiache09-obj_type,
        lv_obj_key  LIKE  bapiache09-obj_key,
        lv_obj_sys  LIKE  bapiache09-obj_sys.
  DATA: lv_amount_internal TYPE c LENGTH 20.
  DATA: i_folio TYPE zdte_folio.
  DATA:  vl_lineas  TYPE i,
         vl_indice1 TYPE i,
         vl_indice2 TYPE i.

  DATA: lv_lfa1 TYPE lfa1,
          iva_prop LIKE zacgl_item-wrbtr.
***Limpiar tablas
  REFRESH : doc_item   , doc_values , doc_tax , doc_pay.
  CLEAR : lv_pos ,doc_header , doc_item   , doc_values , doc_tax , doc_pay.
  i_resultado = 4.

  CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
    EXPORTING
      input  = i_folio_ext
    IMPORTING
      output = i_folio.

  SELECT SINGLE *
         FROM   t001z
         WHERE  paval EQ i_rutreceptor
         AND    party EQ 'TAXNR'.
  IF sy-subrc EQ 0.
    CASE t001z-bukrs.
      WHEN 'CL12' OR 'CL16' OR 'CL65'.
        lv_bukrs = t001z-bukrs.
    ENDCASE.
  ELSE.
    "Error
  ENDIF.

  doc_header-bus_act    = 'RFBU'.
  doc_header-username   = sy-uname.
  doc_header-comp_code  = lv_bukrs.
  doc_header-doc_date   = sy-datum.
  doc_header-pstng_date = sy-datlo.
  doc_header-header_txt = 'Listas Blancas Afecta'.
  doc_header-doc_type   = 'F3'."Afecto
  doc_header-fisc_year  = sy-datum(4).
  doc_header-ref_doc_no = i_folio.
*  doc_header-ac_doc_no = docnum.

*Lee cabecera listas blancas
  SELECT * INTO CORRESPONDING FIELDS OF TABLE ti_cab
    FROM zbmnc_listabcab
   WHERE sociedad        = lv_bukrs
     AND rut_proveedor   = i_rutemisor
     AND numero_cliente  = i_numero_cliente.

  IF sy-subrc EQ 0.
    SELECT * INTO CORRESPONDING FIELDS OF TABLE ti_det
      FROM zbmnc_listabdet
       FOR ALL ENTRIES IN ti_cab
     WHERE sociedad  = ti_cab-sociedad
       AND lifnr     = ti_cab-lifnr.
*       AND ceco      = ti_cab-ceco.

    IF sy-subrc EQ 0.

      LOOP AT ti_cab.
        CLEAR: lv_monto_cab, lv_monto_acu, lv_diferencia.

        SELECT SINGLE * INTO lv_lfa1
          FROM lfa1
         WHERE lifnr EQ ti_cab-lifnr.

        lv_monto_cab      = ( ti_cab-porcentaje * i_monto ) / 100.
        lv_monto_cab      = ( ti_cab-porcentaje * i_monto ) ."para monto clp
*        lv_monto_cab      =  lv_monto_cab / 100.
        lv_monto_cab_txt  = lv_monto_cab.
        CONDENSE lv_monto_cab_txt NO-GAPS.

        CLEAR: vl_lineas,
               vl_indice1,
               vl_indice2.
        SORT ti_det BY porcentaje DESCENDING.
        DESCRIBE TABLE ti_det LINES vl_lineas.

        SELECT SINGLE *
          FROM lfb1
         WHERE lifnr EQ ti_cab-lifnr
           AND bukrs EQ lv_bukrs.

        ADD 1 TO lv_pos.
*         Linea del Acreedor
        CLEAR doc_pay.
        doc_pay-itemno_acc = lv_pos.
        doc_pay-vendor_no  = ti_cab-lifnr.
        doc_pay-gl_account = lfb1-akont.
        doc_pay-pmnttrms   = 'ZC01'.
        doc_pay-pymt_meth  = 'V'.
        doc_pay-bline_date = i_fechaemi.
        doc_pay-item_text  = lv_lfa1-name1.
        doc_pay-tax_code   = 'C9'.
        APPEND doc_pay.

        CLEAR doc_item.
*         Linea del Acreedor
*        doc_item-itemno_acc = lv_pos.
*        doc_item-gl_account = lfb1-akont."cuenta asociada
*        doc_item-vendor_no  = ti_cab-lifnr.
*        doc_item-acct_type  = 'K'.
*        doc_item-pstng_date = sy-datlo.
**        doc_item-item_text  = 'Lista Blanca - Proveedor'.
*        doc_item-item_text  = lv_lfa1-name1.
*        doc_item-costcenter = ''.
*        doc_item-tax_code   = 'C9'.
**          doc_item-orderid = ''.
*        APPEND doc_item.

*       Fill Line 1 of Document Value.
        CLEAR doc_values.
        doc_values-itemno_acc = lv_pos.
        doc_values-currency_iso = 'CLP'.
        doc_values-amt_base   = lv_monto_cab * -1.
        doc_values-amt_doccur = lv_monto_cab * -1.
        APPEND doc_values.

******IMPUESTO 1
        SELECT SINGLE iva_prop INTO  iva_prop
            FROM zfiivaprp
          WHERE  bukrs EQ lv_bukrs
          AND    fec_inico <= sy-datum
          AND    fec_fin  >= sy-datum.
        IF sy-subrc NE 0.
          iva_prop = 100.
        ENDIF.

        ADD 1 TO lv_pos.
        CLEAR doc_item.
        doc_item-itemno_acc = lv_pos.
        doc_item-gl_account = '1013310004'.
        doc_item-acct_type  = 'S'.
        doc_item-pstng_date = sy-datlo.
        doc_item-item_text  = 'CANC PAGOS'.
        doc_item-tax_code   = 'C9'.
*        doc_item-orderid = ''.
        APPEND doc_item.
*       Fill Line 1 of Document Value.
        CLEAR doc_values.
        doc_values-itemno_acc   = lv_pos.
        doc_values-currency_iso = 'CLP'.
        doc_values-amt_base     = i_monto_iva / iva_prop * 100.
        doc_values-amt_doccur   = i_monto_iva / iva_prop * 100.
        APPEND doc_values.

        lv_monto_iva_prop = doc_values-amt_base - i_monto_iva.
***         Fill Tax code
*        CLEAR doc_tax.
*        doc_tax-itemno_acc  = lv_pos.
*        doc_tax-gl_account  = doc_item-gl_account.
*        doc_tax-cond_key    = ''.
*        doc_tax-acct_key    = 'VST'.
*        doc_tax-tax_code    = 'C9'.
*        APPEND doc_tax.

*******IMPUESTO 2
        ADD 1 TO lv_pos.
        CLEAR doc_item.
        doc_item-itemno_acc = lv_pos.
        doc_item-gl_account = '1013310005'.
        doc_item-acct_type  = 'S'.
        doc_item-pstng_date = sy-datlo.
        doc_item-item_text  = lv_lfa1-name1.
        doc_item-tax_code   = 'C9'.
*        doc_item-orderid = ''.
        APPEND doc_item.
*       Fill Line 1 of Document Value.
        CLEAR doc_values.
        doc_values-itemno_acc   = lv_pos.
        doc_values-currency_iso = 'CLP'.
        doc_values-amt_base     = i_monto_iva * -1.
        doc_values-amt_doccur   = i_monto_iva * -1.
        APPEND doc_values.

****DETALLE DE CUENTAS
        LOOP AT ti_det.
          ADD 1 TO vl_indice1.
          ADD 1 TO vl_indice2.
          ADD 1 TO lv_pos.

********* DISTRIBUIR MONTO
          CLEAR lv_monto_det.
          IF ti_det-porcentaje NE 0.
            lv_monto_det      = ( ti_det-porcentaje * lv_monto_cab ) / 100.
          ENDIF.

********* DISTRIBUIR IVA PROPORCIONAL
          IF lv_monto_iva_prop NE 0.
            lv_monto_det_prop = ( ti_det-porcentaje * lv_monto_iva_prop ) / 100.
*            ADD lv_monto_det_prop TO lv_monto_det.
          ENDIF.

          lv_monto_acu = lv_monto_acu + lv_monto_det.

          "lv_monto_cab
          IF vl_indice2 EQ vl_lineas."para el ultimo registro.
*            lv_diferencia = lv_monto_acu - lv_monto_cab.
            lv_diferencia =  ( lv_monto_cab + lv_monto_iva_prop ) - lv_monto_acu .
*            lv_monto_det = lv_monto_det + lv_diferencia.
            lv_monto_det = lv_monto_det - lv_diferencia.
          ENDIF.

          CLEAR doc_item.
          doc_item-itemno_acc = lv_pos.
          doc_item-gl_account = ti_det-cta_contable.
          doc_item-acct_type   = 'S'.
          doc_item-pstng_date = sy-datlo.
*          doc_item-item_text = 'Lista Blanca ITEM'.
          doc_item-item_text = lv_lfa1-name1.
          doc_item-costcenter = ti_det-ceco.
          doc_item-tax_code = 'C9'.
*          doc_item-orderid = ''.
          APPEND doc_item.


*         Fill Line 1 of Document Value.
          CLEAR doc_values.
          doc_values-itemno_acc   = lv_pos.
          doc_values-currency_iso = 'CLP'.
          doc_values-amt_base     = lv_monto_det.
          doc_values-amt_doccur   = lv_monto_det.
          APPEND doc_values.

        ENDLOOP.


        EXIT.
      ENDLOOP.
    ENDIF.

  ENDIF.
  i_lifnr = ti_cab-lifnr.
* All tables filled - now call BAPI.
  CALL FUNCTION 'BAPI_ACC_DOCUMENT_POST'
    EXPORTING
      documentheader  = doc_header
  IMPORTING
        obj_type      = lv_obj_type
        obj_key       = lv_obj_key
        obj_sys       = lv_obj_sys
    TABLES
      accountgl       = doc_item
      currencyamount  = doc_values
      accountpayable  = doc_pay
*      accounttax      = doc_tax
      return          = return
*   EXTENSION1        =
            .
  LOOP AT return WHERE type = 'E'.
    EXIT.
  ENDLOOP.

  IF sy-subrc EQ 0.
    WRITE: / 'Error de contabilización.'.
  ELSE.
    READ TABLE return WITH KEY type = 'S'.
    IF sy-subrc EQ 0.
      i_factura    = lv_obj_key(10).
      i_resultado  = 0.
    ENDIF.

    CLEAR return.
    REFRESH return.
    CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
      EXPORTING
        wait   = 'X'
      IMPORTING
        return = return.

  ENDIF.

ENDFORM.                                                    "zdte_fb60_33
*&---------------------------------------------------------------------*
*&      Form  zdte_fb60_33
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM zdte_fb60_fm USING i_folio_ext i_rutemisor i_numero_cliente i_rutreceptor
                        i_monto_neto i_monto_exento i_monto_iva CHANGING i_factura i_resultado.

  DATA: doc_header LIKE bapiache09,
        doc_item   LIKE bapiacgl09 OCCURS 0 WITH HEADER LINE,
        doc_values LIKE bapiaccr09 OCCURS 0 WITH HEADER LINE,
        doc_pay    LIKE bapiacap09 OCCURS 0 WITH HEADER LINE,
        doc_tax    LIKE bapiactx09 OCCURS 0 WITH HEADER LINE,
        return     LIKE bapiret2 OCCURS 0 WITH HEADER LINE,
        obj_type   LIKE bapiache08-obj_type,
        obj_key    LIKE bapiache02-obj_key,
        obj_sys    LIKE bapiache02-obj_sys,
        docnum     LIKE bkpf-belnr.
  DATA: lv_bukrs          TYPE bukrs.
  DATA: ti_cab            TYPE STANDARD TABLE OF zbmnc_listabcab WITH HEADER LINE.
  DATA: ti_det            TYPE STANDARD TABLE OF zbmnc_listabdet WITH HEADER LINE.
  DATA  wa_cab            TYPE zbmnc_listabcab.
  DATA: lv_dat8(8)        TYPE c.
  DATA: lv_dat10(10)      TYPE c.
  DATA: lv_campo(40)      TYPE c.
  DATA: lv_pos            TYPE posnr_acc.
  DATA: lv_monto_cab      TYPE int4.
  DATA: lv_monto_cab_txt(15).
  DATA: lv_monto_det      TYPE int4,
        lv_monto_acu      TYPE int4,
        lv_diferencia     TYPE int4.
  DATA: lv_monto_det_txt(15).
  DATA  lv_asignacion     TYPE dzuonr.
  DATA  lv_lifnr          TYPE lfa1-lifnr.
  DATA w_bsik TYPE bsik.
  DATA: lv_obj_type LIKE  bapiache09-obj_type,
        lv_obj_key  LIKE  bapiache09-obj_key,
        lv_obj_sys  LIKE  bapiache09-obj_sys.
  DATA: lv_amount_internal TYPE c LENGTH 20.
  DATA: i_folio TYPE zdte_folio.
  DATA:  vl_lineas  TYPE i,
         vl_indice1 TYPE i,
         vl_indice2 TYPE i.

***Limpiar tablas
  REFRESH : doc_item   , doc_values , doc_tax .
  CLEAR : lv_pos ,doc_header , doc_item   , doc_values , doc_tax .
  i_resultado = 4.

  CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
    EXPORTING
      input  = i_folio_ext
    IMPORTING
      output = i_folio.

  SELECT SINGLE *
         FROM   t001z
         WHERE  paval EQ i_rutreceptor
         AND    party EQ 'TAXNR'.
  IF sy-subrc EQ 0.
    CASE t001z-bukrs.
      WHEN 'CL12' OR 'CL16' OR 'CL65'.
        lv_bukrs = t001z-bukrs.
    ENDCASE.
  ELSE.
    "Error
  ENDIF.


  doc_header-bus_act    = 'RFBU'.
  doc_header-username   = sy-uname.
  doc_header-comp_code  = lv_bukrs.
  doc_header-doc_date   = sy-datum.
  doc_header-pstng_date = sy-datlo.
  doc_header-header_txt = 'Listas Blancas Mixta'.
  doc_header-doc_type   = 'F3'."Afecto
  doc_header-fisc_year  = sy-datum(4).
  doc_header-ref_doc_no = i_folio.
*  doc_header-ac_doc_no = docnum.


*Lee cabecera listas blancas
  SELECT  * INTO CORRESPONDING FIELDS OF TABLE ti_cab
    FROM zbmnc_listabcab
   WHERE sociedad        = lv_bukrs
     AND rut_proveedor   = i_rutemisor
     AND numero_cliente  = i_numero_cliente.

  IF sy-subrc EQ 0.
    SELECT * INTO CORRESPONDING FIELDS OF TABLE ti_det
      FROM zbmnc_listabdet
       FOR ALL ENTRIES IN ti_cab
     WHERE sociedad  = ti_cab-sociedad
       AND lifnr     = ti_cab-lifnr.
*       AND ceco      = ti_cab-ceco.

    IF sy-subrc EQ 0.

      LOOP AT ti_cab.
        CLEAR: lv_monto_cab, lv_monto_acu, lv_diferencia.

        lv_monto_cab      = ( ti_cab-porcentaje * i_monto_neto ) / 100.
        lv_monto_cab      = ( ti_cab-porcentaje * i_monto_neto ) ."para monto clp
*        lv_monto_cab      =  lv_monto_cab / 100.

        lv_monto_cab_txt  = lv_monto_cab.
        CONDENSE lv_monto_cab_txt NO-GAPS.

        CLEAR: vl_lineas,
               vl_indice1,
               vl_indice2.
        SORT ti_det BY porcentaje DESCENDING.
        DESCRIBE TABLE ti_det LINES vl_lineas.

        SELECT SINGLE *
          FROM lfb1
         WHERE lifnr EQ ti_cab-lifnr
           AND bukrs EQ lv_bukrs.

        ADD 1 TO lv_pos.
        CLEAR doc_item.
*         Linea del Acreedor
        doc_item-itemno_acc = lv_pos.
        doc_item-gl_account = lfb1-akont."cuenta asociada
        doc_item-vendor_no  = ti_cab-lifnr.
        doc_item-acct_type  = 'K'.
        doc_item-pstng_date = sy-datlo.
        doc_item-item_text  = 'Lista Blanca - Proveedor'.
        doc_item-costcenter = ''.
        doc_item-tax_code   = 'C9'.
*          doc_item-orderid = ''.
        APPEND doc_item.

*       Fill Line 1 of Document Value.
        CLEAR doc_values.
        doc_values-itemno_acc = lv_pos.
        doc_values-currency_iso = 'CLP'.
        doc_values-amt_base   = lv_monto_cab * -1.
        doc_values-amt_doccur = lv_monto_cab * -1.
        APPEND doc_values.

        CLEAR doc_pay.
*         Linea del Acreedor
        doc_pay-itemno_acc = lv_pos.
        doc_pay-vendor_no  = ti_cab-lifnr.
        doc_pay-pmnttrms = 'ZC01'.
        doc_pay-pymt_meth = 'V'.
*          doc_item-orderid = ''.
        APPEND doc_pay.

****DETALLE DE CUENTAS
        LOOP AT ti_det.
          ADD 1 TO vl_indice1.
          ADD 1 TO vl_indice2.
          ADD 1 TO lv_pos.

          CLEAR lv_monto_det.
          IF ti_det-porcentaje EQ 0.
            lv_monto_det      = ( ti_det-porcentaje * lv_monto_cab ) / 100.
          ELSE.
            lv_monto_det      = ( ti_det-porcentaje * lv_monto_cab ) / 100.
          ENDIF.

          lv_monto_acu = lv_monto_acu + lv_monto_det.

          "lv_monto_cab
          IF vl_indice2 EQ vl_lineas."para el ultimo registro.
            lv_diferencia = lv_monto_acu - lv_monto_cab.
*            lv_monto_det = lv_monto_det + lv_diferencia.
            lv_monto_det = lv_monto_det - lv_diferencia.
          ENDIF.

          CLEAR doc_item.
          doc_item-itemno_acc = lv_pos.
          doc_item-gl_account = ti_det-cta_contable.
          doc_item-acct_type   = 'S'.
          doc_item-pstng_date = sy-datlo.
          doc_item-item_text = 'Lista Blanca ITEM'.
          doc_item-costcenter = ti_det-ceco.
          doc_item-tax_code = 'C9'.
*          doc_item-orderid = ''.
          APPEND doc_item.


*         Fill Line 1 of Document Value.
          CLEAR doc_values.
          doc_values-itemno_acc   = lv_pos.
          doc_values-currency_iso = 'CLP'.
          doc_values-amt_base     = lv_monto_det.
          doc_values-amt_doccur   = lv_monto_det.
          APPEND doc_values.

        ENDLOOP.
        EXIT.
      ENDLOOP.
*******MONTO EXENTO
      IF i_monto_exento > 0.

        LOOP AT ti_cab.
          CLEAR: lv_monto_cab, lv_monto_acu, lv_diferencia.

          lv_monto_cab      = ( ti_cab-porcentaje * i_monto_exento ) / 100.
          lv_monto_cab      = ( ti_cab-porcentaje * i_monto_exento ) ."para monto clp
*        lv_monto_cab      =  lv_monto_cab / 100.

          lv_monto_cab_txt  = lv_monto_cab.
          CONDENSE lv_monto_cab_txt NO-GAPS.

          CLEAR: vl_lineas,
                 vl_indice1,
                 vl_indice2.
          SORT ti_det BY porcentaje DESCENDING.
          DESCRIBE TABLE ti_det LINES vl_lineas.

          SELECT SINGLE *
            FROM lfb1
           WHERE lifnr EQ ti_cab-lifnr
             AND bukrs EQ lv_bukrs.

          ADD 1 TO lv_pos.
          CLEAR doc_item.
*         Linea del Acreedor
          doc_item-itemno_acc = lv_pos.
          doc_item-gl_account = lfb1-akont."cuenta asociada
          doc_item-vendor_no  = ti_cab-lifnr.
          doc_item-acct_type  = 'K'.
          doc_item-pstng_date = sy-datlo.
          doc_item-item_text  = 'Lista Blanca - Mixta Proveedor'.
          doc_item-costcenter = ''.
          doc_item-tax_code   = 'C0'.
*          doc_item-orderid = ''.
          APPEND doc_item.

*       Fill Line 1 of Document Value.
          CLEAR doc_values.
          doc_values-itemno_acc = lv_pos.
          doc_values-currency_iso = 'CLP'.
          doc_values-amt_base   = lv_monto_cab * -1.
          doc_values-amt_doccur = lv_monto_cab * -1.
          APPEND doc_values.

          CLEAR doc_pay.
*         Linea del Acreedor
          doc_pay-itemno_acc = lv_pos.
          doc_pay-vendor_no  = ti_cab-lifnr.
          doc_pay-pmnttrms = 'ZC01'.
          doc_pay-pymt_meth = 'V'.
*          doc_item-orderid = ''.
          APPEND doc_pay.

****DETALLE DE CUENTAS
          LOOP AT ti_det.
            ADD 1 TO vl_indice1.
            ADD 1 TO vl_indice2.
            ADD 1 TO lv_pos.

            CLEAR lv_monto_det.
            IF ti_det-porcentaje EQ 0.
              lv_monto_det      = ( ti_det-porcentaje * lv_monto_cab ) / 100.
            ELSE.
              lv_monto_det      = ( ti_det-porcentaje * lv_monto_cab ) / 100.
            ENDIF.

            lv_monto_acu = lv_monto_acu + lv_monto_det.

            "lv_monto_cab
            IF vl_indice2 EQ vl_lineas."para el ultimo registro.
              lv_diferencia = lv_monto_acu - lv_monto_cab.
*            lv_monto_det = lv_monto_det + lv_diferencia.
              lv_monto_det = lv_monto_det - lv_diferencia.
            ENDIF.

            CLEAR doc_item.
            doc_item-itemno_acc = lv_pos.
            doc_item-gl_account = ti_det-cta_contable.
            doc_item-acct_type   = 'S'.
            doc_item-pstng_date = sy-datlo.
            doc_item-item_text = 'Lista Blanca Mixta ITEM'.
            doc_item-costcenter = ti_det-ceco.
            doc_item-tax_code = 'C0'.
*          doc_item-orderid = ''.
            APPEND doc_item.


*         Fill Line 1 of Document Value.
            CLEAR doc_values.
            doc_values-itemno_acc   = lv_pos.
            doc_values-currency_iso = 'CLP'.
            doc_values-amt_base     = lv_monto_det.
            doc_values-amt_doccur   = lv_monto_det.
            APPEND doc_values.

          ENDLOOP.
          EXIT.
        ENDLOOP.
      ENDIF.


******IMPUESTOS
      IF  doc_item[] IS NOT INITIAL.
        ADD 1 TO lv_pos.
        CLEAR doc_item.
        doc_item-itemno_acc = lv_pos.
        doc_item-acct_key   = '40'.
        doc_item-gl_account = '1013310004'.
        doc_item-acct_type  = 'S'.
        doc_item-pstng_date = sy-datlo.
        doc_item-item_text  = 'IVA CREDITO FISCAL'.
        doc_item-tax_code = 'C0'.
*          doc_item-orderid = ''.
        APPEND doc_item.

*         Fill Line 1 of Document Value.
        CLEAR doc_values.
        doc_values-itemno_acc   = lv_pos.
        doc_values-currency_iso = 'CLP'.
        doc_values-amt_base     = i_monto_iva.
        doc_values-amt_doccur   = i_monto_iva.
        APPEND doc_values.

        ADD 1 TO lv_pos.
        CLEAR doc_item.
        doc_item-itemno_acc = lv_pos.
        doc_item-acct_key   = '40'.
        doc_item-gl_account = '1013310005'.
        doc_item-acct_type  = 'S'.
        doc_item-pstng_date = sy-datlo.
        doc_item-item_text  = 'IVA CREDITO FISCAL P'.
        doc_item-tax_code   = 'C0'.
*          doc_item-orderid = ''.
        APPEND doc_item.

*         Fill Line 1 of Document Value.
        CLEAR doc_values.
        doc_values-itemno_acc   = lv_pos.
        doc_values-currency_iso = 'CLP'.
        doc_values-amt_base     = i_monto_iva - i_monto_exento.
        doc_values-amt_doccur   = i_monto_iva - i_monto_exento.
        APPEND doc_values.
      ENDIF.

    ENDIF.

  ENDIF.

* All tables filled - now call BAPI.
  CALL FUNCTION 'BAPI_ACC_DOCUMENT_POST'
    EXPORTING
      documentheader  = doc_header
  IMPORTING
        obj_type      = lv_obj_type
        obj_key       = lv_obj_key
        obj_sys       = lv_obj_sys
    TABLES
      accountgl       = doc_item
      currencyamount  = doc_values
      accounttax      = doc_tax
      return          = return
*   EXTENSION1        =
            .
  LOOP AT return WHERE type = 'E'.
    EXIT.
  ENDLOOP.

  IF sy-subrc EQ 0.
    WRITE: / 'Error de contabilización.'.
  ELSE.
    READ TABLE return WITH KEY type = 'S'.
    IF sy-subrc EQ 0.
      i_factura    = lv_obj_key(10).
      i_resultado  = 0.
    ENDIF.

    CLEAR return.
    REFRESH return.
    CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
      EXPORTING
        wait   = 'X'
      IMPORTING
        return = return.

  ENDIF.

ENDFORM.                                                    "zdte_fb60_fm
*&---------------------------------------------------------------------*
*&      Form  UPDATE_DOC_FI
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM update_doc_fi USING l_bukrs l_belnr l_gjahr l_lifnr .

  DATA: w_bkpf TYPE bkpf.

  SELECT SINGLE * INTO w_bkpf
   FROM bkpf
   WHERE bukrs EQ l_bukrs
     AND belnr EQ l_belnr
     AND gjahr EQ l_gjahr.

  IF sy-subrc EQ 0.
    UPDATE bseg SET zzrut_terc = l_lifnr
     WHERE bukrs EQ w_bkpf-bukrs
       AND belnr EQ w_bkpf-belnr
       AND gjahr EQ w_bkpf-gjahr
       AND ( bschl EQ '40' ).

  ENDIF.

ENDFORM.                    " UPDATE_DOC_FI
