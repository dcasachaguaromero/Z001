*&---------------------------------------------------------------------*
*& Report  Z_AJUSTA_BAJAS_TOTALES
*&
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*

REPORT  Z_AJUSTA_BAJAS_TOTALES
        no standard page heading line-size 255.
tables : anla,
         anlb.

* Tabla Interna datos separados por TAB.
* Recibe archivo
data: begin of tabla occurs 0,
        bukrs LIKE ANLA-BUKRS, "Sociedad
        anln1 LIKE ANLA-ANLN1, "Activo
        anln2 LIKE ANLA-ANLN2, "Subnumero
        deakt(10) type c     , "Fecha Baja
      end of tabla.
*

SELECTION-SCREEN BEGIN OF BLOCK bl1 WITH FRAME TITLE text-001.
SELECTION-SCREEN SKIP.
*
*select-options : s_bukrs for anla-bukrs obligatory .
parameters: p_bukrs like anla-bukrs obligatory,
            fil_nam1 like rlgrap-filename obligatory
            default 'C:/Banmedica/'.
*            P_ANLN1 LIKE ANLA-ANLN1.
*
SELECTION-SCREEN SKIP.
parameters: BORRA TYPE C RADIOBUTTON GROUP 33 default 'X',
            MARCA TYPE C RADIOBUTTON GROUP 33.
*
SELECTION-SCREEN END OF BLOCK bl1.

include bdcrecx1.


at selection-screen on value-request for fil_nam1.
  perform value_req_file using fil_nam1.


start-of-selection.
*
  perform load_file.
  perform procesa_bi.

*&---------------------------------------------------------------------*
*&      Form  PROCESA_BI
*&---------------------------------------------------------------------*
FORM PROCESA_BI.

  perform open_group.

  loop at tabla.
    perform bdc_dynpro      using 'SAPLAIST' '0100'.
    perform bdc_field       using 'BDC_CURSOR'
                                  'ANLA-ANLN1'.
    perform bdc_field       using 'BDC_OKCODE'
                                  '/00'.
    perform bdc_field       using 'ANLA-ANLN1'
                                  tabla-anln1.
    perform bdc_field       using 'ANLA-ANLN2'
                                  tabla-anln2.
    perform bdc_field       using 'ANLA-BUKRS'
                                  tabla-bukrs.

    perform bdc_dynpro      using 'SAPLAIST' '1000'.
    perform bdc_field       using 'BDC_OKCODE'
                                  '=BUCH'.

*    perform bdc_field       using 'ANLA-TXT50'
*                                  'COMPUTADORES P7'.
*    perform bdc_field       using 'ANLA-INVNR'
*                                  '18'.

    perform bdc_field       using 'BDC_CURSOR'
                                  'ANLA-DEAKT'.

*    perform bdc_field       using 'ANLA-AKTIV'
*                                  '01.06.1999'.

    if not borra is initial.
      perform bdc_field       using 'ANLA-DEAKT'
                                    ''.
    else.
      REPLACE ALL OCCURRENCES OF '-' IN tabla-deakt WITH '.'.
      perform bdc_field       using 'ANLA-DEAKT'
                                tabla-deakt.
    endif.

    perform bdc_transaction using 'AS02'.
  endloop.

  perform close_group.
ENDFORM.                    "PROCESA_BI

*&---------------------------------------------------------------------*
*&      Form  VALUE_REQ_FILE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_PATH_S  text
*----------------------------------------------------------------------*
form value_req_file using filename like rlgrap-filename.
  data wk_file like rlgrap-filename.

  call function 'WS_FILENAME_GET'
       exporting
          DEF_FILENAME     = ''
          DEF_PATH         = 'C:\Banmedica\'
          MASK             = ',*.*,*.*.'
          MODE             = 'O'
          TITLE            = 'Abrir Archivo desde PC'
       importing  " VALUE_REQ_FILE
          filename         = wk_file
       exceptions
            others.

  if sy-subrc = 0.
    filename = wk_file.
  endif.

endform.                               " VALUE_REQ_FILE
*&---------------------------------------------------------------------*
*&      Form  LOAD_FILE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form load_file.

  call function 'WS_UPLOAD'
    EXPORTING
      filename        = fil_nam1
      filetype        = 'DAT'
    TABLES
      data_tab        = tabla
    EXCEPTIONS
      file_open_error = 1
      file_read_error = 2.

  case sy-subrc.
    when 0.
      write: 'File open successful for file', fil_nam1.
    when 1.
      write: 'Could not open', fil_nam1.
      stop.
    when 2 or 3 or 4.
      write: 'File open error for file', fil_nam1.
      stop.
  endcase.

endform.                               " LOAD_FILE
