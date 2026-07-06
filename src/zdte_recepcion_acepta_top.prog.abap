*&---------------------------------------------------------------------*
*&  Include           ZDTE_RECEPCION_ACEPTA_TOP
*&---------------------------------------------------------------------*
DATA: lc_key            TYPE i VALUE 26101957,
      lc_rfc_dest       LIKE rfcdes-rfcdest.          "RFC Destination
DATA: p_user(30)        TYPE c .
DATA: p_pwd(30)         TYPE c .
DATA: p_ip(64)          TYPE c .
DATA: cont_ref_ult TYPE c.
DATA: c_error TYPE c.
DATA: lv_pwd_len              TYPE i,
      lv_handle               TYPE i.

DATA: li_data                 TYPE TABLE OF char80 WITH HEADER LINE,
      li_result               TYPE TABLE OF char80 WITH HEADER LINE.

******Data para procesar XML
****************************
DATA:   request               TYPE REF TO if_http_request,
        request_xdata         TYPE xstring,
        request_xdata_xml     TYPE xstring,
        response_xdata        TYPE xstring,
        request_data          TYPE string,
        response_data         TYPE string,
        response              TYPE REF TO if_http_response.

DATA:   lo_xml                TYPE REF TO cl_xml_document,
        lo_node               TYPE REF TO if_ixml_node.

DATA:   lo_xml_dte            TYPE REF TO cl_xml_document,
        lo_node_dte           TYPE REF TO if_ixml_node.

*Cabecera XML
DATA:   l_estado              TYPE string,
        l_rut_receptor        TYPE string,
        l_rut_emisor          TYPE string,
        l_tipo_dte            TYPE string,
        l_folio               TYPE string,
        l_fecha_recep         TYPE string,
        l_fecha_recep_sii     TYPE string,
        l_fecha_envio         TYPE string,
        l_monto_total         TYPE string,
        l_fecha_emision       TYPE string.

*Cuerpo XML
DATA:   l_rznsoc              TYPE string.
DATA:   l_iva                 TYPE string.
DATA:   l_mntexe              TYPE string.
DATA:   l_mnttotal            TYPE string.
DATA:   l_tasaiva             TYPE string.
DATA:   l_mntneto             TYPE string.
DATA:   l_nrolinref           TYPE string.
DATA:   l_tpodocref           TYPE string.
DATA:   l_folioref            TYPE string.
DATA:   l_fchref              TYPE string.
DATA:   l_codref              TYPE string.
DATA:   l_rutotr              TYPE string.
DATA:   l_razonref            TYPE string.
DATA:   l_rznsocrecep         TYPE string.
DATA:   l_girorecep           TYPE string.
DATA:   l_dirrecep            TYPE string.



DATA:   l_xml_dte             TYPE string.
DATA:   l_decode_str          TYPE string.

CONSTANTS: c_waers            TYPE waers VALUE 'CLP'.

TYPES: BEGIN OF ty_data,
          dummy(1),
          tipodte(100),
          folio(10),
          rutemisor(10),
          rznsoc(100),
          fchemis(10),

          rutrecep(10),
          rznrecep(100),
          girorecep(100),
          dirrecep(100),

          iva(18),
          mntexe(18),
          mntneto(18),
          mnttotal(18),
          tasaiva(5),
          fchrec(20),


          nrolinref_01(2),
          tpodocref_01(3),
          folioref_01(10),
          fchref_01(10),
          codref_01(1),
          razonref_01(100),
          indglobal_01(1),
          rutotr_01(10),

          nrolinref_02(2),
          tpodocref_02(3),
          folioref_02(10),
          fchref_02(10),
          codref_02(1),
          razonref_02(100),
          indglobal_02(1),
          rutotr_02(10),

          nrolinref_03(2),
          tpodocref_03(3),
          folioref_03(10),
          fchref_03(10),
          codref_03(1),
          razonref_03(100),
          indglobal_03(1),
          rutotr_03(10),

          nrolinref_04(2),
          tpodocref_04(3),
          folioref_04(10),
          fchref_04(10),
          codref_04(1),
          razonref_04(100),
          indglobal_04(1),
          rutotr_04(10),

          nrolinref_05(2),
          tpodocref_05(3),
          folioref_05(10),
          fchref_05(10),
          codref_05(1),
          razonref_05(100),
          indglobal_05(1),
          rutotr_05(10),

          nrolinref_06(2),
          tpodocref_06(3),
          folioref_06(10),
          fchref_06(10),
          codref_06(1),
          razonref_06(100),
          indglobal_06(1),
          rutotr_06(10),

          nrolinref_07(2),
          tpodocref_07(3),
          folioref_07(10),
          fchref_07(10),
          codref_07(1),
          razonref_07(100),
          indglobal_07(1),
          rutotr_07(10),

          nrolinref_08(2),
          tpodocref_08(3),
          folioref_08(10),
          fchref_08(10),
          codref_08(1),
          razonref_08(100),
          indglobal_08(1),
          rutotr_08(10),

          nrolinref_09(2),
          tpodocref_09(3),
          folioref_09(10),
          fchref_09(10),
          codref_09(1),
          razonref_09(100),
          indglobal_09(1),
          rutotr_09(10),

          nrolinref_10(2),
          tpodocref_10(3),
          folioref_10(10),
          fchref_10(10),
          codref_10(1),
          razonref_10(100),
          indglobal_10(1),
          rutotr_10(10),

          nrolinref_11(2),
          tpodocref_11(3),
          folioref_11(10),
          fchref_11(10),
          codref_11(1),
          razonref_11(100),
          indglobal_11(1),
          rutotr_11(10),

          nrolinref_12(2),
          tpodocref_12(3),
          folioref_12(10),
          fchref_12(10),
          codref_12(1),
          razonref_12(100),
          indglobal_12(1),
          rutotr_12(10),

          nrolinref_13(2),
          tpodocref_13(3),
          folioref_13(10),
          fchref_13(10),
          codref_13(1),
          razonref_13(100),
          indglobal_13(1),
          rutotr_13(10),

          nrolinref_14(2),
          tpodocref_14(3),
          folioref_14(10),
          fchref_14(10),
          codref_14(1),
          razonref_14(100),
          indglobal_14(1),
          rutotr_14(10),

          nrolinref_15(2),
          tpodocref_15(3),
          folioref_15(10),
          fchref_15(10),
          codref_15(1),
          razonref_15(100),
          indglobal_15(1),
          rutotr_15(10),

          nrolinref_16(2),
          tpodocref_16(3),
          folioref_16(10),
          fchref_16(10),
          codref_16(1),
          razonref_16(100),
          indglobal_16(1),
          rutotr_16(10),

          nrolinref_17(2),
          tpodocref_17(3),
          folioref_17(10),
          fchref_17(10),
          codref_17(1),
          razonref_17(100),
          indglobal_17(1),
          rutotr_17(10),

END OF ty_data.

DATA gt_data                TYPE STANDARD TABLE OF zemm156.
DATA wa_data                LIKE LINE OF gt_data.

DATA: v_cmd_01(80)          TYPE c.
DATA: v_cmd_02(80)          TYPE c.
DATA: v_cmd_03(80)          TYPE c.
DATA: v_cmd_04(80)          TYPE c.
DATA: v_cmd_05(80)          TYPE c.
DATA: v_path_01             LIKE sxpgcolist-parameters VALUE '/DTE_RECIBIDOS2'.      "Recibidos
DATA: v_path_02             LIKE sxpgcolist-parameters VALUE '/DTE/DTE_PROCESADOS'.  "Procesados
DATA: v_path_03             LIKE sxpgcolist-parameters VALUE '/DTE/DTE_ERROR'.       "Erroneos
DATA: v_path_04             LIKE sxpgcolist-parameters VALUE '/DTE/DTE_RESPUESTA'.   "Rechazados

DATA: BEGIN OF gt_dte OCCURS 0,
      fecha(8)    TYPE c,
      sep1(2)     TYPE c,
      hora(7)     TYPE c,
      sep2(2)     TYPE c,
      tamano(19)  TYPE c,
      sep3(1)     TYPE c,
      nombre(41)  TYPE c,
END OF gt_dte.

DATA: gcl_xml               TYPE REF TO cl_xml_document.
DATA: gv_subrc              TYPE sy-subrc.
DATA: gv_xml_string         TYPE xstring.
DATA: gv_size               TYPE sytabix.
DATA: gt_xml_data           TYPE TABLE OF smum_xmltb.
DATA: gwa_xml_data          TYPE smum_xmltb.
DATA: gt_return             TYPE TABLE OF bapiret2.
DATA: wa_return             TYPE bapiret2.
DATA: gv_tabix              TYPE sytabix.

DATA: wa_doc_rec            TYPE zdte_doc_rec,
      wa_doc_rec_ref        TYPE zdte_doc_rec_ref,
      wa_doc_rec_ref_ant    TYPE zdte_doc_rec_ref.

DATA: w_ftp                 TYPE zdte_ftp.

DATA: t_set TYPE TABLE OF setleaf WITH HEADER LINE.
RANGES: s_tipodte FOR zdte_doc_rec-tipodte.
RANGES: s_tipodte_ref FOR zdte_doc_rec_ref-tipodte.
