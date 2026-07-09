*&---------------------------------------------------------------------*
*& Report: < ZEY_GDS_CORRECTION > *
*& Author: < EY_DES02 > *
*& Description: < ReSQ Correction > *
*& Date: <20-12-2019> *
*& Transport Number: < ECDK917080 > *
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Report  ZSDR_FILE_BOL
*&
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*

REPORT zsdr_file_bol.

TABLES adrc.
TABLES bkpf.
TABLES bseg.
TABLES bsid.
TABLES kna1.
TABLES vbrk.

TYPE-POOLS truxs.
DATA num_lin TYPE i.
DATA: it_tabla TYPE truxs_t_text_data.
* Variables y constantes
TYPES: BEGIN OF str_file,
         customer_trx_id  TYPE c LENGTH   15, " código cliente SAP
         num_ctr          TYPE c LENGTH   10, " número de contrato
         num_boleta       TYPE c LENGTH   10, " código boleta SAP
         fecha_emision    TYPE c LENGTH   10, " fecha emisión boleta
         fecha_venc       TYPE c LENGTH   10, " fecha vencimiento boleta
         monto            TYPE c LENGTH   19, " monto
         cliente          TYPE c LENGTH  140, " nombre cliente
         direccion        TYPE c LENGTH 1000, " dirección cliente
         comuna           TYPE c LENGTH   30, " comuna cliente
         glosa            TYPE c LENGTH  400, " servicio de atención movil de urgencia
         num_boleta_final TYPE c LENGTH   15, " número legal de boleta
       END OF str_file.

DATA: BEGIN OF it_tabla2 OCCURS 0,
       line(4096) TYPE c,
      END OF it_tabla2.

TYPES: BEGIN OF t_datatab ,
        data TYPE string,
       END OF t_datatab.
DATA it_datatab TYPE STANDARD TABLE OF t_datatab WITH HEADER LINE.
DATA ti_file TYPE STANDARD TABLE OF str_file WITH HEADER LINE.
DATA it_raw TYPE truxs_t_text_data.
DATA srch_str TYPE c LENGTH 20.
DATA per TYPE string.
DATA str_file TYPE string.
CONSTANTS: true TYPE c VALUE 'X',
           gv_vbrk TYPE bkpf-awtyp VALUE 'VBRK'.

* Parámetros
PARAMETERS p_bukrs LIKE vbrk-bukrs OBLIGATORY DEFAULT 'CL51'.
SELECT-OPTIONS so_fkdat FOR vbrk-fkdat OBLIGATORY.
PARAMETERS p_blart LIKE bkpf-blart DEFAULT 'O1'.
SELECTION-SCREEN SKIP.
SELECTION-SCREEN BEGIN OF BLOCK b_tpo WITH FRAME TITLE text-p03.
PARAMETERS p_file LIKE rlgrap-filename.
PARAMETERS download RADIOBUTTON GROUP rad2 MODIF ID f96.
PARAMETERS upload RADIOBUTTON GROUP rad2 MODIF ID f96.
SELECTION-SCREEN END OF BLOCK b_tpo.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_file.
  DATA lv_subrc LIKE sy-subrc.
  DATA lt_it_tab TYPE filetable.
  DATA p_pa_file TYPE file_table.

  CALL FUNCTION 'WS_FILENAME_GET'
    EXPORTING
      def_filename     = '*.xls'
      def_path         = 'C:\'
      mask             = ',*.txt.'
      mode             = 'O'
      title            = text-c12
    IMPORTING
      filename         = p_file
    EXCEPTIONS
      inv_winsys       = 01
      no_batch         = 02
      selection_cancel = 03
      selection_error  = 04.

START-OF-SELECTION.
  FREE  ti_file.
  CLEAR ti_file.
  str_file = p_file.
  CASE true .
    WHEN download.
* BEGIN. 07-07-2026 - ATC - ATC-03
* OLD CODE
*      SELECT * FROM vbrk WHERE bukrs EQ p_bukrs
*                           AND fkdat IN so_fkdat
*                           and fkart EQ 'ZBOL'
*                           AND fksto NE 'X'
*                           AND rfbsk EQ 'C'.
*
* NEW CODE
      SELECT *
 FROM vbrk WHERE bukrs EQ p_bukrs
                           AND fkdat IN so_fkdat
                           and fkart EQ 'ZBOL'
                           AND fksto NE 'X'
                           AND rfbsk EQ 'C' ORDER BY PRIMARY KEY.

* END. 07-07-2026 - ATC - ATC-03
* Código cliente SAP
        CLEAR ti_file.
        MOVE vbrk-kunrg TO ti_file-customer_trx_id.
        IF NOT ti_file-customer_trx_id IS INITIAL.
          WHILE ti_file-customer_trx_id(1) = '0'.
            SHIFT ti_file-customer_trx_id LEFT.
          ENDWHILE.
        ENDIF.
* Número de contrato
        CLEAR bkpf.
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*        SELECT SINGLE * FROM bkpf WHERE bukrs EQ vbrk-bukrs
*                                    AND blart EQ p_blart
*                                    AND awtyp EQ gv_vbrk
*                                    AND awkey EQ vbrk-vbeln.
*
* NEW CODE
        SELECT *
        UP TO 1 ROWS  FROM bkpf WHERE bukrs EQ vbrk-bukrs
                                    AND blart EQ p_blart
                                    AND awtyp EQ gv_vbrk
                                    AND awkey EQ vbrk-vbeln ORDER BY PRIMARY KEY.

        ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
        CHECK sy-subrc = 0.
        CLEAR bseg.

*ResQ Comment:Correction not required as Select Single is used 20/12/2019 EY_DES02 ECDK917080 *
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*        SELECT SINGLE * FROM bseg WHERE bukrs EQ bkpf-bukrs
*                                    AND belnr EQ bkpf-belnr
*                                    AND gjahr EQ bkpf-gjahr
*                                    AND koart EQ 'D'.
*
* NEW CODE
        SELECT *
        UP TO 1 ROWS  FROM bseg WHERE bukrs EQ bkpf-bukrs
                                    AND belnr EQ bkpf-belnr
                                    AND gjahr EQ bkpf-gjahr
                                    AND koart EQ 'D' ORDER BY PRIMARY KEY.

        ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
        IF NOT bseg-vertn IS INITIAL.
          WHILE bseg-vertn(1) = '0'.
            SHIFT bseg-vertn LEFT.
          ENDWHILE.
        ENDIF.
        MOVE bseg-vertn TO ti_file-num_ctr.
* Número de boleta
        MOVE vbrk-vbeln TO ti_file-num_boleta.
        IF NOT ti_file-num_boleta IS INITIAL.
          WHILE ti_file-num_boleta(1) = '0'.
            SHIFT ti_file-num_boleta LEFT.
          ENDWHILE.
        ENDIF.

* Fecha emisión boleta
        CONCATENATE vbrk-fkdat+6(2)
                    vbrk-fkdat+4(2)
                    vbrk-fkdat+0(4)
                    INTO ti_file-fecha_emision SEPARATED BY '.'.
* Fecha vencimiento boleta
        CONCATENATE bseg-fdtag+6(2) bseg-fdtag+4(2) bseg-fdtag+0(4) INTO ti_file-fecha_venc SEPARATED BY '.'.
* Monto
        vbrk-netwr = vbrk-netwr + vbrk-mwsbk.
        MOVE vbrk-netwr TO ti_file-monto.
        REPLACE '.' WITH space INTO ti_file-monto.
        CONDENSE ti_file-monto NO-GAPS.
* Nombre cliente
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*        SELECT SINGLE name1 adrnr INTO (ti_file-cliente, kna1-adrnr) FROM kna1 WHERE kunnr EQ vbrk-kunrg.
*
* NEW CODE
        SELECT name1 adrnr
        UP TO 1 ROWS  INTO (ti_file-cliente, kna1-adrnr) FROM kna1 WHERE kunnr EQ vbrk-kunrg ORDER BY PRIMARY KEY.

        ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
* Dirección cliente
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*        SELECT SINGLE * FROM adrc WHERE addrnumber EQ kna1-adrnr.
*
* NEW CODE
        SELECT *
        UP TO 1 ROWS  FROM adrc WHERE addrnumber EQ kna1-adrnr ORDER BY PRIMARY KEY.

        ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
        CONCATENATE adrc-street adrc-house_num1 INTO ti_file-direccion.
* Comuna cliente
        MOVE adrc-city1 TO ti_file-comuna.
* Servicio de atención movil de urgencia
        MOVE text-001 TO ti_file-glosa.
        CONCATENATE vbrk-fkdat+4(2) vbrk-fkdat+0(4) INTO per SEPARATED BY '-'.
        REPLACE 'NUM_CTR' WITH ti_file-num_ctr INTO ti_file-glosa.
        REPLACE 'FKDAT' WITH per INTO ti_file-glosa.
        APPEND ti_file.
      ENDSELECT.

*Begin of change: ReSQ Correction INDEX READ on an unsorted Internal TABLE 20/12/2019 EY_DES02 ECDK917080 *
SORT TI_FILE .
*End of change: ReSQ Correction for INDEX READ on an unsorted Internal TABLE 20/12/2019 EY_DES02 ECDK917080 *
      READ TABLE ti_file INDEX 1.
      IF sy-subrc = 0.
        CALL FUNCTION 'EXCEL_OLE_STANDARD_DAT'
          EXPORTING
            file_name                 = p_file
          TABLES
            data_tab                  = ti_file
          EXCEPTIONS
            file_not_exist            = 1
            filename_expected         = 2
            communication_error       = 3
            ole_object_method_error   = 4
            ole_object_property_error = 5
            invalid_pivot_fields      = 6
            download_problem          = 7
            OTHERS                    = 8.
        IF sy-subrc <> 0.
        ENDIF.
      ELSE.
        MESSAGE i899(fi) WITH text-004.
      ENDIF.
    WHEN upload.
      CALL FUNCTION 'TEXT_CONVERT_XLS_TO_SAP'
        EXPORTING
          i_tab_raw_data       = it_raw
          i_filename           = p_file
        TABLES
          i_tab_converted_data = ti_file[]
        EXCEPTIONS
          conversion_failed    = 1
          OTHERS               = 2.

      LOOP AT ti_file.
        CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
          EXPORTING
            input  = ti_file-num_boleta
          IMPORTING
            output = vbrk-vbeln.

* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*        SELECT SINGLE * FROM vbrk WHERE vbeln EQ vbrk-vbeln.
*
* NEW CODE
        SELECT *
        UP TO 1 ROWS  FROM vbrk WHERE vbeln EQ vbrk-vbeln ORDER BY PRIMARY KEY.

        ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
        IF sy-subrc = 0.
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*          SELECT SINGLE * FROM bkpf WHERE bukrs EQ vbrk-bukrs
*                                      AND awtyp EQ gv_vbrk
*                                      AND awkey EQ vbrk-vbeln.
*
* NEW CODE
          SELECT *
          UP TO 1 ROWS  FROM bkpf WHERE bukrs EQ vbrk-bukrs
                                      AND awtyp EQ gv_vbrk
                                      AND awkey EQ vbrk-vbeln ORDER BY PRIMARY KEY.

          ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
          IF sy-subrc = 0.
            vbrk-xblnr = ti_file-num_boleta_final.
            bkpf-xblnr = ti_file-num_boleta_final.
            UPDATE: vbrk, bkpf.
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*            SELECT SINGLE * FROM bsid WHERE bukrs EQ bkpf-bukrs
*                                        AND gjahr EQ bkpf-gjahr
*                                        AND belnr EQ bkpf-belnr.
*
* NEW CODE
            SELECT *
            UP TO 1 ROWS  FROM bsid WHERE bukrs EQ bkpf-bukrs
                                        AND gjahr EQ bkpf-gjahr
                                        AND belnr EQ bkpf-belnr ORDER BY PRIMARY KEY.

            ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
            IF sy-subrc = 0.
              bsid-xblnr = ti_file-num_boleta_final.
              MODIFY bsid.
            ENDIF.
          ENDIF.
        ENDIF.
      ENDLOOP.

      COMMIT WORK.
      IF sy-subrc = 0.
        CLEAR num_lin.
        DESCRIBE TABLE ti_file LINES num_lin.
        MESSAGE i899(fi) WITH text-002 num_lin text-003.
      ENDIF.
  ENDCASE.

END-OF-SELECTION.
