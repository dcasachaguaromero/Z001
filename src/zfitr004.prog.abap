*&---------------------------------------------------------------------*
*& Report: ZFITR004                                                    *
*& Author:  J.Palma                                                    *
*& Description: < ReSQ Correction >                                    *
*& Date: <20-12-2019>                                                  *
*& Transport Number: < ECDK917080 >                                    *
*&---------------------------------------------------------------------*
*& Modificacion: se agrega el formato para el BCI                      *                                              *
*& Author: Ramón Vasquez, VisionOne                                    *               *
*& Description: Generar archivo de pagos para el Banco BCI.            *
*& Date: 20-01-2022.                                                    *
*& Transport Number: < ECDKXXXXX >                                     *
*&---------------------------------------------------------------------*
REPORT zfitr004 NO STANDARD PAGE HEADING
                                   LINE-COUNT 60
                                   LINE-SIZE 132 .

INCLUDE zfitr004_top.
DATA :p_bankl TYPE t012-bankl.
DATA : archivo_s(130)   TYPE c.
*----------------------------------------------------------------------*
* Parametros
*----------------------------------------------------------------------*
SELECTION-SCREEN BEGIN OF BLOCK marco1 WITH FRAME TITLE TEXT-001.
PARAMETERS : bukrs    LIKE bkpf-bukrs    OBLIGATORY VALUE CHECK,
             v_hbkid  LIKE bseg-hbkid    OBLIGATORY,
             v_fechai LIKE bkpf-budat    OBLIGATORY,
             v_fechat LIKE bkpf-budat    OBLIGATORY,
             v_fecrem LIKE bkpf-budat    OBLIGATORY.

* INI - WALDO ALARCON - VISIONONE  - 10-02-2022
*PARAMETER  : archivo     LIKE rlgrap-filename DEFAULT 'C:\TRANSFER\'.
SELECTION-SCREEN SKIP 1.
PARAMETERS  : p_server      TYPE string MODIF ID sv.
PARAMETERS  : p_archiv      TYPE string.
SELECTION-SCREEN SKIP 1.

PARAMETERS : par_tes RADIOBUTTON GROUP test       " Ejecución en Test
                     DEFAULT 'X' USER-COMMAND pro,
             par_di  RADIOBUTTON GROUP test.
SELECTION-SCREEN END OF BLOCK marco1 .

INITIALIZATION.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_archiv.
  CALL METHOD cl_gui_frontend_services=>directory_browse
    EXPORTING
      window_title    = 'Carpeta de Almacenamiento'
      initial_folder  = 'C:\'
    CHANGING
      selected_folder = p_archiv.

AT SELECTION-SCREEN OUTPUT.
  PERFORM invisible.

AT SELECTION-SCREEN ON BLOCK marco1.
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*  SELECT SINGLE bankl
*         FROM  t012
*         INTO  p_bankl
*        WHERE  bukrs EQ bukrs
*          AND  hbkid EQ v_hbkid.
*
* NEW CODE
  SELECT bankl
  UP TO 1 ROWS 
         FROM  t012
         INTO  p_bankl
        WHERE  bukrs EQ bukrs
          AND  hbkid EQ v_hbkid ORDER BY PRIMARY KEY.

  ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01

  AUTHORITY-CHECK OBJECT 'F_BKPF_BUK' ID 'BUKRS' FIELD bukrs ID 'ACTVT' FIELD '03'.
    IF sy-subrc <> 0.
       MESSAGE e004(zfi) WITH 'Sin autorización para Sociedad.' bukrs.
    ENDIF.

  PERFORM lee_ruta_server CHANGING p_server p_archiv.

  IF p_archiv IS INITIAL.
    MESSAGE e899(v1) WITH 'No ingreso el PATH para registro de archivo banco'.
    EXIT.
  ENDIF.
* FIN - WALDO ALARCON - VISIONONE - 10-02-2022

AT SELECTION-SCREEN ON bukrs.

  AUTHORITY-CHECK OBJECT 'F_BKPF_BUK'
     ID 'BUKRS' FIELD bukrs.
  IF sy-subrc <> 0.
*--------'No authorization for company code &'------------------------
    MESSAGE e526(icc_tr) WITH bukrs.
  ENDIF.
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*  SELECT SINGLE * FROM t001 WHERE bukrs = bukrs.
*
* NEW CODE
  SELECT *
  UP TO 1 ROWS  FROM t001 WHERE bukrs = bukrs ORDER BY PRIMARY KEY.

  ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01


START-OF-SELECTION.
**
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*  SELECT SINGLE bankl
*         FROM  t012
*         INTO  p_bankl
*        WHERE  bukrs EQ bukrs
*          AND  hbkid EQ v_hbkid.
*
* NEW CODE
  SELECT bankl
  UP TO 1 ROWS 
         FROM  t012
         INTO  p_bankl
        WHERE  bukrs EQ bukrs
          AND  hbkid EQ v_hbkid ORDER BY PRIMARY KEY.

  ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
  IF p_bankl = '016' OR
     p_bankl = '037'.
    PERFORM cargo_datos.
  ELSE.
    MESSAGE e004(zfi) WITH 'Solo Formato Banco BCI y SANTANSER'.
  ENDIF.

  CALL SCREEN 100.

END-OF-SELECTION.

*&---------------------------------------------------------------------*
*&      Form  cargo_datos
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM cargo_datos.
  REFRESH int_tabla.
* BEGIN. 07-07-2026 - ATC - ATC-03
* OLD CODE
*  SELECT * FROM bsik WHERE bukrs  = bukrs
*                     AND   hbkid  = v_hbkid
*                     AND   zfbdt >= v_fechai
*                     AND   zfbdt =< v_fechat
*                     AND   zlspr = 'S'.
*
* NEW CODE
  SELECT *
 FROM bsik WHERE bukrs  = bukrs
                     AND   hbkid  = v_hbkid
                     AND   zfbdt >= v_fechai
                     AND   zfbdt =< v_fechat
                     AND   zlspr = 'S' ORDER BY PRIMARY KEY.

* END. 07-07-2026 - ATC - ATC-03

    IF bsik-blart = 'F7'.
      bsik-xblnr = bsik-zuonr.
    ENDIF.

* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*    SELECT SINGLE * FROM  zfitr004
*                    WHERE bukrs  = bukrs
*                    AND   belnr  = bsik-belnr
*                    AND   gjahr  = bsik-gjahr
*                    AND   xblnr  = bsik-xblnr
*                    AND   lifnr  = bsik-lifnr
*                    AND   estado = '1'.
*
* NEW CODE
    SELECT *
    UP TO 1 ROWS  FROM  zfitr004
                    WHERE bukrs  = bukrs
                    AND   belnr  = bsik-belnr
                    AND   gjahr  = bsik-gjahr
                    AND   xblnr  = bsik-xblnr
                    AND   lifnr  = bsik-lifnr
                    AND   estado = '1' ORDER BY PRIMARY KEY.

    ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01

    IF sy-subrc <> 0.
      MOVE-CORRESPONDING bsik TO int_tabla.

* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*      SELECT SINGLE stcd1 name1 FROM lfa1 INTO  (int_tabla-stcd1, int_tabla-name1)
*                                    WHERE lifnr = int_tabla-lifnr.
*
* NEW CODE
      SELECT stcd1 name1
      UP TO 1 ROWS  FROM lfa1 INTO  (int_tabla-stcd1, int_tabla-name1)
                                    WHERE lifnr = int_tabla-lifnr ORDER BY PRIMARY KEY.

      ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01

* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*      SELECT SINGLE bankl bankn FROM lfbk INTO  (int_tabla-bankl, int_tabla-bankn)
*                                    WHERE lifnr = int_tabla-lifnr AND
*                                          banks = 'CL'.
*
* NEW CODE
      SELECT bankl bankn
      UP TO 1 ROWS  FROM lfbk INTO  (int_tabla-bankl, int_tabla-bankn)
                                    WHERE lifnr = int_tabla-lifnr AND
                                          banks = 'CL' ORDER BY PRIMARY KEY.

      ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01

      IF int_tabla-shkzg = 'S'.
        int_tabla-wrbtr = int_tabla-wrbtr * -1.
      ENDIF.

      int_tabla-sel = ''.
      APPEND int_tabla.
    ENDIF.
  ENDSELECT.

  DESCRIBE TABLE int_tabla LINES fill.
  SORT int_tabla BY name1.
  tabla-lines = fill.

ENDFORM.                    "cargo_datos
*&---------------------------------------------------------------------*
*&      Module  STATUS_0100  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE status_0100 OUTPUT.
  REFRESH tab.
  MOVE 'PICK' TO tab-fcode.
  APPEND tab.

  MOVE 'GENERA' TO tab-fcode.
  APPEND tab.
  SET PF-STATUS 'ZFITR004' EXCLUDING tab.
  SET TITLEBAR 'T01'.

ENDMODULE.                             " STATUS_0100  OUTPUT

*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0100  INPUT
*&---------------------------------------------------------------------*
MODULE user_command_0100 INPUT.

* INI - WALDO ALARCON - VISIONONE - 10-02-2022
*  archivo = 'C:\TRANSFER\'.
  CLEAR : archivo, archivo_s.
  IF p_bankl = '016'.
** INI V1 RVY 24-05-2022
    if par_tes = ' '.
**     CONCATENATE p_archiv bukrs '_BBCI_eConf' '_' sy-datum '_' sy-uzeit '.txt'
       CONCATENATE p_archiv bukrs sy-datum sy-uzeit 'EC.txt' INTO  archivo.
    else.
**      CONCATENATE p_archiv 'TEST' bukrs '_BBCI_eConf' '_' sy-datum '_'
       CONCATENATE p_archiv 'TEST' bukrs sy-datum sy-uzeit 'EC.txt' INTO  archivo.
    endif.
** INI V1 RVY 24-05-2022
  ELSE.
    CONCATENATE p_archiv bukrs '_BSANT_eConf' '_' sy-datum '_' sy-uzeit '.txt'
                INTO  archivo.
  ENDIF.
  CONDENSE archivo NO-GAPS.
*
  IF p_server IS NOT INITIAL.
    IF p_bankl = '016'.
      CONCATENATE p_server bukrs '_BBCI_eConf' '_' sy-datum '_' sy-uzeit '.txt'
                  INTO  archivo_s.
    ELSE.
      CONCATENATE p_server bukrs '_BSANT_eConf' '_' sy-datum '_' sy-uzeit '.txt'
                  INTO  archivo_s.
    ENDIF.
    CONDENSE archivo_s NO-GAPS.
  ENDIF.
* FIN - WALDO ALARCON - VISIONONE - 10-02-2022

  CASE sy-ucomm.
    WHEN 'BACK'.
      LEAVE TO SCREEN 0.
    WHEN '%EX' OR 'RW'.
      LEAVE PROGRAM.
    WHEN 'MARCA'.
      PERFORM marcar_todo.
    WHEN 'DEMAR'.
      PERFORM desmarcar_todo.
    WHEN 'CONT'.
      REFRESH int_tabla1.
      CLEAR total.
      LOOP AT int_tabla WHERE sel = 'X'.
        MOVE-CORRESPONDING int_tabla TO int_tabla1.
        total = total + int_tabla-wrbtr.
        APPEND int_tabla1.
      ENDLOOP.
      DESCRIBE TABLE int_tabla1 LINES fill.
      IF fill > 0.
        SORT int_tabla1 BY name1.
        tabla1-lines = fill.
*        CONCATENATE archivo bukrs '_BSANT_eConf' '_' sy-datum '_' sy-uzeit '.txt' INTO
*        archivo.
*        CONDENSE archivo NO-GAPS.
        CALL SCREEN 200.
      ELSE.
        MESSAGE i004(zfi) WITH 'Debe Seleccionar a lo menos un registro'.
      ENDIF.
  ENDCASE.

  CLEAR sy-ucomm.

ENDMODULE.                             " USER_COMMAND_0100  INPUT


**&---------------------------------------------------------------------
**&      Module  FILL_TABLE_CONTROL  OUTPUT
**&---------------------------------------------------------------------
**   Lleno grilla con valores desde tabla
**----------------------------------------------------------------------

MODULE fill_table_control OUTPUT.

  READ TABLE int_tabla INTO zfitr004_est INDEX tabla-current_line.

ENDMODULE.                             " FILL_TABLE_CONTROL  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  VALIDA-GRILLA  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE valida-grilla INPUT.

  MODIFY int_tabla FROM zfitr004_est INDEX tabla-current_line
     TRANSPORTING sel.

ENDMODULE.                    "VALIDA-GRILLA INPUT

*&---------------------------------------------------------------------*
*&      Form  marca
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM marcar_todo.
  LOOP AT int_tabla.
    int_tabla-sel = 'X'.
    MODIFY int_tabla.
  ENDLOOP.
ENDFORM.                    "marca

*&---------------------------------------------------------------------*
*&      Form  desmarcar_todo
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM desmarcar_todo.
  LOOP AT int_tabla.
    int_tabla-sel = ''.
    MODIFY int_tabla.
  ENDLOOP.
ENDFORM.                    "marca

*----------------------------------------------------------------------*
*  MODULE STATUS_0200 OUTPUT
*----------------------------------------------------------------------*
*
*----------------------------------------------------------------------*
MODULE status_0200 OUTPUT.

  REFRESH tab.
  MOVE 'PICK' TO tab-fcode.
  APPEND tab.

  MOVE 'CONT' TO tab-fcode.
  APPEND tab.
  SET PF-STATUS 'ZFITR004' EXCLUDING tab.
  SET TITLEBAR 'T02'.

ENDMODULE.                             " STATUS_0100  OUTPUT

*----------------------------------------------------------------------*
*  MODULE USER_COMMAND_0200 INPUT
*----------------------------------------------------------------------*
*
*----------------------------------------------------------------------*
MODULE user_command_0200 INPUT.

  CASE sy-ucomm.
    WHEN 'BACK'.
      LEAVE TO SCREEN 0.
    WHEN '%EX' OR 'RW'.
      LEAVE PROGRAM.
    WHEN 'GENERA'.
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*      SELECT SINGLE bankl
*         FROM  t012
*         INTO  p_bankl
*        WHERE  bukrs EQ bukrs
*          AND  hbkid EQ v_hbkid.
*
* NEW CODE
      SELECT bankl
      UP TO 1 ROWS 
         FROM  t012
         INTO  p_bankl
        WHERE  bukrs EQ bukrs
          AND  hbkid EQ v_hbkid ORDER BY PRIMARY KEY.

      ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01

      IF p_bankl = '037'.
        PERFORM genera_archivo_santander.
        PERFORM cargo_datos.
      ELSE.
        IF p_bankl = '016'.
          PERFORM genera_archivo_bci.
          PERFORM cargo_datos.
        ELSE.
          MESSAGE e004(zfi) WITH 'Solo Formato Banco BCI y SANTANSER'.
        ENDIF.
      ENDIF.

  ENDCASE.

  CLEAR sy-ucomm.

ENDMODULE.                             " USER_COMMAND_0100  INPUT

*----------------------------------------------------------------------*
*  MODULE FILL_TABLE_CONTROL_200 OUTPUT
*----------------------------------------------------------------------*
*
*----------------------------------------------------------------------*
MODULE fill_table_control_200 OUTPUT.

  READ TABLE int_tabla1 INTO zfitr004_est INDEX tabla1-current_line.

ENDMODULE.                             " FILL_TABLE_CONTROL  OUTPUT






*&---------------------------------------------------------------------*
*&      Form  genera_archivo
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM genera_archivo_santander.

  SELECT MAX( secuencia ) INTO secuencia FROM  zfitr004
                                         WHERE bukrs = bukrs
                                         AND   fecha_rem = v_fecrem.



  LOOP AT int_tabla1.

    reg_stder-zbukr = bukrs.

    TRANSLATE int_tabla1-stcd1 USING '- ' .
    CONDENSE  int_tabla1-stcd1 NO-GAPS.

** Se ajusta Rut a la Izquierda.
    WRITE int_tabla1-stcd1 TO reg_stder-rut_prov LEFT-JUSTIFIED.
*
    reg_stder-nombre           =  int_tabla1-name1 .
    reg_stder-cod_prov         =  int_tabla1-lifnr.
    reg_stder-codigo_banco     =  ''.
    reg_stder-cuenta_abono     =  ''.
    reg_stder-docto_sap1       =  int_tabla1-belnr.
    reg_stder-mod_pago         =  'V'.
    CONDENSE int_tabla1-xblnr NO-GAPS.
    num_doc = int_tabla1-xblnr.
    reg_stder-num_docto      = num_doc.
    IF int_tabla1-shkzg = 'S'.
      reg_stder-signo_docto   = '-'.
    ELSE.
      reg_stder-signo_docto  = '+'.
    ENDIF.
    reg_stder-monto_docto   = int_tabla1-wrbtr * 100.
    reg_stder-fecha_emision = int_tabla1-bldat.
    reg_stder-fecha_vcto    = int_tabla1-zfbdt.
    reg_stder-codigo_banco  = int_tabla1-bankl.
    reg_stder-cuenta_abono  = int_tabla1-bankn.

    APPEND reg_stder.
** INI V1 RVY 24-05-2022
    IF par_tes = ' '.
       zfitr004-bukrs         = bukrs.
       zfitr004-fecha_rem     = v_fecrem.
       zfitr004-secuencia     = secuencia + 1.
       zfitr004-belnr         = int_tabla1-belnr.
       zfitr004-gjahr         = int_tabla1-gjahr.
       zfitr004-xblnr         = int_tabla1-xblnr.
       zfitr004-lifnr         = int_tabla1-lifnr.
       zfitr004-estado        = '1'.
       INSERT zfitr004.
    ENDIF.
** FIN V1 RVY 24-05-2022
  ENDLOOP.

  PERFORM listado.  "informe.
  PERFORM preparo_salida_037.
  PERFORM bajar_archivo_037.

* INI - WALDO ALARCON - VISIONONE - 10-02-2022
*  IF p_server IS NOT INITIAL.
*    PERFORM bajar_archivo_server TABLES out_reg_stder.
*  ENDIF.
* FIN - WALDO ALARCON - VISIONONE - 10-02-2022

ENDFORM.                    "genera_archivo_Santander

*&---------------------------------------------------------------------*
*&      Form  genera_archivo
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM genera_archivo_bci.

  SELECT MAX( secuencia ) INTO secuencia FROM  zfitr004
                                         WHERE bukrs = bukrs
                                         AND   fecha_rem = v_fecrem.
  LOOP AT int_tabla1.

    reg_stder-zbukr = bukrs.

    TRANSLATE int_tabla1-stcd1 USING '- ' .
    CONDENSE  int_tabla1-stcd1 NO-GAPS.

** Se ajusta Rut a la Izquierda.
    WRITE int_tabla1-stcd1 TO reg_stder-rut_prov LEFT-JUSTIFIED.
*
    reg_stder-nombre           =  int_tabla1-name1 .
    TRANSLATE reg_stder-nombre USING 'ÁAÉEÍIÓOÚUáaéeíióoúuÑNñn; : \ ~ ¨ , / % $S| ° #N& '.

    reg_stder-cod_prov         =  int_tabla1-lifnr.
    reg_stder-codigo_banco     =  int_tabla1-bankl.
    reg_stder-cuenta_abono     =  int_tabla1-bankn.
    reg_stder-docto_sap1       =  int_tabla1-belnr.
** V1 RVY
*   reg_stder-mod_pago         =  'V'.
    reg_stder-mod_pago         =  int_tabla1-zlsch.
    reg_stder-blart            =  int_tabla1-blart.
    CONDENSE int_tabla1-xblnr NO-GAPS.
    num_doc = int_tabla1-xblnr.
    reg_stder-num_docto      = num_doc.
    IF int_tabla1-shkzg = 'S'.
      reg_stder-signo_docto   = '-'.
    ELSE.
      reg_stder-signo_docto  = '+'.
    ENDIF.
    reg_stder-monto_docto   = int_tabla1-wrbtr * 100.
    reg_stder-fecha_emision   =  int_tabla1-bldat.
    reg_stder-fecha_vcto   =  int_tabla1-zfbdt.
    APPEND reg_stder.

** INI V1 RVY 24-05-2022
    IF par_tes = ' '.
       zfitr004-bukrs         = bukrs.
       zfitr004-fecha_rem     = v_fecrem.
       zfitr004-secuencia     = secuencia + 1.
       zfitr004-belnr         = int_tabla1-belnr.
       zfitr004-gjahr         = int_tabla1-gjahr.
       zfitr004-xblnr         = int_tabla1-xblnr.
       zfitr004-lifnr         = int_tabla1-lifnr.
       zfitr004-estado        = '1'.
       INSERT zfitr004.
    ENDIF.
** FIN V1 RVY 24-05-2022
  ENDLOOP.

  PERFORM listado.  "informe.
  PERFORM preparo_salida_016.
  PERFORM bajar_archivo_016.

* INI - WALDO ALARCON - VISIONONE - 10-02-2022
  IF p_server IS NOT INITIAL.
    PERFORM bajar_archivo_server TABLES out_reg_bci_x.
  ENDIF.
* FIN - WALDO ALARCON - VISIONONE - 10-02-2022
ENDFORM.                    "genera_archivo_BCI

**&---------------------------------------------------------------------*
**&      Form  bajar_archivo_037
**&---------------------------------------------------------------------*
**       text
**----------------------------------------------------------------------*
FORM bajar_archivo_037.
*---------------------*
  DATA : nombre_a  TYPE string.
*
  nombre_a = archivo.
  CALL FUNCTION 'GUI_DOWNLOAD'
    EXPORTING
      filename                  = nombre_a
      filetype                  = 'ASC'
      confirm_overwrite         = 'X'
      trunc_trailing_blanks_eol = ''
    TABLES
      data_tab                  = out_reg_stder
    EXCEPTIONS
      file_write_error          = 1
      no_batch                  = 2
      gui_refuse_filetransfer   = 3
      invalid_type              = 4
      no_authority              = 5
      unknown_error             = 6
      header_not_allowed        = 7
      separator_not_allowed     = 8
      filesize_not_allowed      = 9
      header_too_long           = 10
      dp_error_create           = 11
      dp_error_send             = 12
      dp_error_write            = 13
      unknown_dp_error          = 14
      access_denied             = 15
      dp_out_of_memory          = 16
      disk_full                 = 17
      dp_timeout                = 18
      file_not_found            = 19
      dataprovider_exception    = 20
      control_flush_error       = 21
      OTHERS                    = 22.

  IF sy-subrc <> 0.
    WRITE :/ 'error archivo PC!!!!'  ,
           /  sy-msgv1 ,
           /  sy-msgv2 ,
           /  sy-msgv3 ,
           /  sy-msgv4 .

  ELSE.
    SKIP 2 .
    FORMAT COLOR 3 ON.
    WRITE : / 'Se genero archivo PC :', archivo.
    FORMAT COLOR 3 OFF.
  ENDIF.
*----------------------------------------------
ENDFORM.                    "bajar_archivo_037
*
**&---------------------------------------------------------------------*
**&      Form  bajar_archivo_016
**&---------------------------------------------------------------------*
FORM bajar_archivo_016.
*---------------------*
  DATA : nombre_a  TYPE string.
  nombre_a = archivo.

  CALL FUNCTION 'GUI_DOWNLOAD'
    EXPORTING
      filename                  = nombre_a
      filetype                  = 'ASC'
      confirm_overwrite         = 'X'
      trunc_trailing_blanks_eol = ''
    TABLES
      data_tab                  = out_reg_bci_x
    EXCEPTIONS
      file_write_error          = 1
      no_batch                  = 2
      gui_refuse_filetransfer   = 3
      invalid_type              = 4
      no_authority              = 5
      unknown_error             = 6
      header_not_allowed        = 7
      separator_not_allowed     = 8
      filesize_not_allowed      = 9
      header_too_long           = 10
      dp_error_create           = 11
      dp_error_send             = 12
      dp_error_write            = 13
      unknown_dp_error          = 14
      access_denied             = 15
      dp_out_of_memory          = 16
      disk_full                 = 17
      dp_timeout                = 18
      file_not_found            = 19
      dataprovider_exception    = 20
      control_flush_error       = 21
      OTHERS                    = 22.

  IF sy-subrc <> 0.
    WRITE :/ 'error!!!!'  ,
           /  sy-msgv1 ,
           /  sy-msgv2 ,
           /  sy-msgv3 ,
           /  sy-msgv4 .

  ELSE.
    SKIP 2 .
    IF par_tes = 'X'.
      FORMAT COLOR 3 ON.
      WRITE : / 'PROCESO DE TEST'.
      WRITE : / 'Se genero archivo :', archivo.
      FORMAT COLOR 3 OFF.
    ELSE.
      FORMAT COLOR 3 ON.
      WRITE : / 'Se genero archivo :', archivo.
      FORMAT COLOR 3 OFF.
    endif.
  ENDIF.
*----------------------------------------------
ENDFORM.                    "bajar_archivo_016
**
**&---------------------------------------------------------------------*
**&      Form  listado
**&---------------------------------------------------------------------*
**       text
**----------------------------------------------------------------------*
FORM listado.
*-----------*
  LEAVE TO LIST-PROCESSING AND RETURN TO SCREEN 0.


  REFRESH tab.
  MOVE 'CONT' TO tab-fcode.
  APPEND tab.

  MOVE 'GENERA' TO tab-fcode.
  APPEND tab.
  SET PF-STATUS 'ZFITR004' EXCLUDING tab.
  SET TITLEBAR 'T03'.

  monto_p = 0.
  t_monto = 0.

  SORT int_tabla1 BY stcd1.

  LOOP AT int_tabla1.

    IF aux_prov <> int_tabla1-stcd1.
      aux_prov = int_tabla1-stcd1.
      IF monto_p <> 0.
        WRITE 118 monto_p CURRENCY 'CLP'.
      ENDIF.
      monto_p = 0.
    ENDIF.

*    IF int_tabla1-shkzg = 'S'.
*      int_tabla1-WRBTR = int_tabla1-WRBTR * -1.
*    ENDIF.

    WRITE : /001 'V' ,
             003 int_tabla1-belnr  ,
             014 bukrs       ,
             019 int_tabla1-xblnr  ,
             037 int_tabla1-stcd1 ,
             054 int_tabla1-name1 ,
             092 int_tabla1-zfbdt,
             101 int_tabla1-wrbtr CURRENCY 'CLP'.
    HIDE: int_tabla1-belnr,bukrs, int_tabla1-gjahr.

    t_monto  = t_monto  + int_tabla1-wrbtr.
    monto_p  = monto_p  + int_tabla1-wrbtr.

  ENDLOOP.

  CLEAR int_tabla1-belnr .

* Imprimimos total Parcial
  WRITE 118 monto_p CURRENCY 'CLP'.

* Imprimimos total Final
  WRITE : /,/111 'Total' ,
             118  t_monto  CURRENCY 'CLP'.

  SKIP 4.

  WRITE :/25 '___________________',   "Subrayado CAJA
          50 '___________________',   "Subrayado APODERADO
          75 '___________________'.   "Subrayado APODERADO
  SKIP .
  WRITE :/28 'Tesoreria' ,              "para firma de caja
          54 'Apoderado' ,            "para firma apoderado
          79 'Apoderado' .            "para firma apoderado

ENDFORM.                    "listado


TOP-OF-PAGE.

  IF p_bankl = '016'.
    WRITE : /1  t001-butxt,
          43   'NOMINA DE PAGO PROVEEDORES CUENTA BANCO BCI eConfirming      ' ,
          120 sy-datum,

         /120 sy-uzeit ,
         /27 'Identificación De Propuesta de Pago : ',
             'Fecha Vcto.Inicio: ',v_fechai, ' Termino:' ,  v_fechat ,
         120 sy-pagno,
         / .
  ELSE.
    WRITE : /1  t001-butxt,
          43   'NOMINA DE PAGO PROVEEDORES CUENTA BANCO SANTANDER eConfirming' ,
          120 sy-datum,

         /120 sy-uzeit ,
         /27 'Identificación De Propuesta de Pago : ',
             'Fecha Vcto.Inicio: ',v_fechai, ' Termino:' ,  v_fechat ,
         120 sy-pagno,
         / .
  ENDIF.

  WRITE sy-uline(136).

  WRITE : /01  'Mp'               ,   " 01   " mdiopago
           04  'Doc.Egreso'       ,   " 10
           15  'Soc'              ,   " 04
           22  'Referencia'       ,   " 25   " bkpf-xblnr 16
           41  'Proveedor'        ,   " 16
           60  'Nombre Proveedor' ,   " 35

           92  'Fecha Vcto',
           111 'Monto'            ,   " 15
           127 'Total'            .

  WRITE : / sy-uline(136).



AT LINE-SELECTION.
  IF NOT int_tabla1-belnr IS INITIAL.
    SET PARAMETER ID 'BLN' FIELD int_tabla1-belnr.
    SET PARAMETER ID 'BUK' FIELD bukrs.
    SET PARAMETER ID 'GJR' FIELD int_tabla1-gjahr.
    CALL TRANSACTION 'FB03' AND SKIP FIRST SCREEN.
  ENDIF.

  CLEAR int_tabla1-belnr .

**&---------------------------------------------------------------------*
**&      Form  PREPARO_SALIDA_037
**&---------------------------------------------------------------------*
**       text
**----------------------------------------------------------------------*
**  -->  p1        text
**  <--  p2        text
**----------------------------------------------------------------------*
FORM preparo_salida_037.

  DATA: rut(11)  TYPE c.
  DATA: largo(3) TYPE n.
  DATA: numero(10) TYPE n.

  REFRESH out_reg_stder.
  SORT reg_stder  BY zbukr rut_prov .

  DESCRIBE TABLE reg_stder LINES reg01-ndocto.


  LOOP AT reg_stder.
    AT NEW  zbukr .
*ResQ Comment:Correction not required as Select Single is used 20/12/2019 EY_DES01 ECDK917080 *
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*      SELECT SINGLE paval INTO rut FROM t001z WHERE bukrs = reg_stder-zbukr
*                                   AND   party = 'TAXNR' .
*
* NEW CODE
      SELECT paval
      UP TO 1 ROWS  INTO rut FROM t001z WHERE bukrs = reg_stder-zbukr
                                   AND   party = 'TAXNR'  ORDER BY PRIMARY KEY.

      ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
    ENDAT.
    AT LAST.
      SUM.
      reg01-cod_reg = '1'.
      reg01-operacion = '1020001'.
      reg01-rut_emp = rut+0(8).
      reg01-dig_emp = rut+9(1).
      reg01-nombre_emp  = t001-butxt.
      CONCATENATE  v_fecrem+6(2) v_fecrem+4(2)   v_fecrem+0(4) INTO   reg01-fecha_remes.
      reg01-total    =  reg_stder-monto_docto.
      MOVE reg01  TO  out_reg_stder.
      APPEND out_reg_stder.
    ENDAT.
  ENDLOOP.

  LOOP AT reg_stder.
    reg02-cod_reg = '2'.
    largo = strlen( reg_stder-rut_prov ).
    largo =  largo - 1.
    reg02-dig_prv = reg_stder-rut_prov+largo(1).
    reg02-rut_prv = reg_stder-rut_prov+0(largo).
    reg02-cod_prv = reg_stder-rut_prov+0(largo).
    reg02-nombre_prv = reg_stder-nombre.
    reg02-pais = 0097.
*    case reg_stder-BLART.
*      when 'F1' or 'F2' or 'F3' or 'F4' or 'F5' or 'F6'.
*        REG02-tipo_docto = '1'.
*      when 'N1' or 'N2' or 'N3' or 'N4'.
*        REG02-tipo_docto = '2'.
*endcase.
    IF reg_stder-monto_docto < 0.
      reg_stder-monto_docto = reg_stder-monto_docto * -1.
      reg02-tipo_docto = '2'.
    ELSE.
      reg02-tipo_docto = '1'.
    ENDIF.

    reg02-nro_docto      =  reg_stder-num_docto.
    reg02-moneda_docto   = '999'.
    reg02-valor_pago     =  reg_stder-monto_docto.
    reg02-forma_pago     =  '1'.
    CONCATENATE  reg_stder-fecha_emision+6(2) reg_stder-fecha_emision+4(2)   reg_stder-fecha_emision+0(4) INTO reg02-fecha_emision .
    CONCATENATE reg_stder-fecha_vcto+6(2) reg_stder-fecha_vcto+4(2)   reg_stder-fecha_vcto+0(4) INTO reg02-fecha_vcto .
    MOVE reg02  TO  out_reg_stder.
    APPEND out_reg_stder.
  ENDLOOP.

ENDFORM.                    " PREPARO_SALIDA
**
**&---------------------------------------------------------------------*
**&      Form  PREPARO_SALIDA_016
**&---------------------------------------------------------------------*
FORM preparo_salida_016.
  DATA: rut(11)  TYPE c.
  DATA: largo(3) TYPE n.
  DATA: numero(10) TYPE n.
*
  REFRESH out_reg_bci_x.
  SORT reg_stder  BY zbukr rut_prov .

  DESCRIBE TABLE reg_stder LINES reg01-ndocto.

  IF par_tes = 'X'.
     move '************** ARCHIVO TEST *********' to out_reg_bci_x.
     APPEND out_reg_bci_x.
     move ' ' to out_reg_bci_x.
  ENDIF.

  LOOP AT reg_stder.
    out_reg_bci-mod_servico  = 'F'.
    largo                    = strlen( reg_stder-rut_prov ).
    largo                    = largo - 1.
    out_reg_bci-rut_prv_dvr  = reg_stder-rut_prov+largo(1).
    out_reg_bci-rut_prv      = reg_stder-rut_prov+0(largo).
    out_reg_bci-unidad       = ''.
    out_reg_bci-nombre_prv   = reg_stder-nombre.
    out_reg_bci-medio_aviso  = 'E'.
    out_reg_bci-direc_aviso  = ' '.
    out_reg_bci-comuna_aviso = 0.
** V1 RVY
**  out_reg_bci-forma_pago   = 'VVC'.
    out_reg_bci-cod_banco  = ' '.
    out_reg_bci-cuenta_cte = ' '.
    IF reg_stder-mod_pago = 'T'.
      out_reg_bci-cod_banco  = reg_stder-codigo_banco.
      out_reg_bci-cuenta_cte = reg_stder-cuenta_abono.
      IF reg_stder-codigo_banco = '016'.
        out_reg_bci-forma_pago   = 'CCT'.
      ELSE.
        out_reg_bci-forma_pago   = 'OTC'.
      ENDIF.
    ELSE.
** INI V1 RVY 24-05-2022
      out_reg_bci-cod_banco    = '016'.
** FIN V1 RVY 24-05-2022
      out_reg_bci-forma_pago   = 'VVC'.
    ENDIF.
*
    out_reg_bci-cod_sucursal = ' '.
** INI RVY 26-04-2022
*    IF reg_stder-monto_docto < 0.
*      reg_stder-monto_docto = reg_stder-monto_docto * -1.
*    ENDIF.
*
    CASE reg_stder-blart.
      WHEN 'F1' OR 'F2' OR 'F3' OR 'F4' OR 'F5' OR 'F6' OR
           'F0' OR 'F8' OR 'F9' OR 'FA' OR 'FB' OR
           'FC' OR 'FR'.
        out_reg_bci-tipo_docto = 'FAC'.
      WHEN 'N1' OR 'N2' OR 'N3' OR 'N4' OR
           'N0' OR 'NA' OR 'NB' OR 'NC' OR 'NR'.
        out_reg_bci-tipo_docto = 'NCR'.
      WHEN 'D1' OR 'D2' OR 'D3' OR 'D4' OR
           'DA' OR 'DG' OR 'DP' OR 'DR' OR 'DY' OR 'DZ'.
        out_reg_bci-tipo_docto = 'NDB'.
      WHEN 'SA' OR 'F7'.
        IF reg_stder-monto_docto < 0.
          out_reg_bci-tipo_docto = 'DES'.
        ELSE.
          out_reg_bci-tipo_docto = 'ABO'.
        ENDIF.
      WHEN 'B1' OR 'B2' OR 'B3' OR 'B4' OR 'B5' OR 'B6'.
        out_reg_bci-tipo_docto = 'ABO'.
      WHEN 'AB'.
        out_reg_bci-tipo_docto = 'FAC'.
    ENDCASE.

    IF reg_stder-monto_docto < 0.
      reg_stder-monto_docto = reg_stder-monto_docto * -1.
    ENDIF.
* FIN RVY 26-04-2022

    out_reg_bci-nro_docto     = reg_stder-num_docto.
    out_reg_bci-nro_docto_rel = 0.
    out_reg_bci-valor_info    = reg_stder-monto_docto.
    out_reg_bci-valor_pago    = reg_stder-monto_docto.
    out_reg_bci-estado_pago   = 'OK'.
*    CONCATENATE v_fecrem+6(2) v_fecrem+4(2) v_fecrem+0(4) INTO  out_reg_bci-fecha_pago.

    CONCATENATE reg_stder-fecha_vcto+6(2) reg_stder-fecha_vcto+4(2) reg_stder-fecha_vcto+0(4)
                INTO out_reg_bci-fecha_pago.

    out_reg_bci-glosa         = ''.

    largo = strlen( reg_stder-rut_prov ).

    out_reg_bci-rut_ret1 = 0.
    out_reg_bci-rut_ret1_dvr = ' '.
    out_reg_bci-paterno1 = '               '.
    out_reg_bci-materno1 = '               '.
    out_reg_bci-nombre1  = '               '.

    out_reg_bci-rut_ret2   = 0.
    out_reg_bci-rut_ret2_dvr = ' '.
    out_reg_bci-paterno2   = '               '.
    out_reg_bci-materno2   = '               '.
    out_reg_bci-nombre2    = '               '.

    out_reg_bci_x = out_reg_bci.

    APPEND out_reg_bci_x.
  ENDLOOP.

ENDFORM.                    " PREPARO_SALIDA_016
*&---------------------------------------------------------------------*
*&      Form  INVISIBLE
*&---------------------------------------------------------------------*
FORM invisible .
*
  LOOP AT SCREEN.
    CASE screen-group1.
      WHEN 'SV'.
        screen-input  = 0. " Campo no editable/grisado
      WHEN 'DEL'.
        screen-active = 0.
    ENDCASE.
    MODIFY SCREEN.
  ENDLOOP.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  LEE_RUTA_SERVER
*&---------------------------------------------------------------------*
FORM lee_ruta_server  CHANGING p_server p_dirpc.
  DATA: prgname(40) TYPE c VALUE 'ZFITR004',
        lv_dirpc    TYPE string.
*
  CLEAR p_server.
* BEGIN. 07-07-2026 - ATC - ATC-03
* OLD CODE
*  SELECT zruta zruta_respaldo INTO (p_server, lv_dirpc)
*    FROM ztparamftp  WHERE zbukr = bukrs
*                       AND zprog = prgname.
*
* NEW CODE
  SELECT zruta zruta_respaldo
 INTO (p_server, lv_dirpc)
    FROM ztparamftp  WHERE zbukr = bukrs
                       AND zprog = prgname ORDER BY PRIMARY KEY.

* END. 07-07-2026 - ATC - ATC-03
  ENDSELECT.

  IF par_di EQ 'X' AND p_bankl EQ '016'.
    IF p_server IS INITIAL AND bukrs IS NOT INITIAL.
      MESSAGE e899(fi) WITH 'Falta directorio del Servidor'
                            ',configurar en trx. ZPARFTP'.
    ENDIF.
  ELSE.
    CLEAR p_server.
  ENDIF.
  IF p_dirpc IS INITIAL.
    p_dirpc = lv_dirpc.
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  BAJAR_ARCHIVO_SERVER
*&---------------------------------------------------------------------*
FORM bajar_archivo_server  TABLES   ti_salida.
  DATA : nombre_a  TYPE string.
*
  nombre_a = archivo_s.

  CALL FUNCTION 'GUI_DOWNLOAD'
    EXPORTING
      filename                = nombre_a
      filetype                = 'ASC'
      confirm_overwrite       = 'X'
    TABLES
      data_tab                = ti_salida
    EXCEPTIONS
      file_write_error        = 1
      no_batch                = 2
      gui_refuse_filetransfer = 3
      invalid_type            = 4
      no_authority            = 5
      unknown_error           = 6
      header_not_allowed      = 7
      separator_not_allowed   = 8
      filesize_not_allowed    = 9
      header_too_long         = 10
      dp_error_create         = 11
      dp_error_send           = 12
      dp_error_write          = 13
      unknown_dp_error        = 14
      access_denied           = 15
      dp_out_of_memory        = 16
      disk_full               = 17
      dp_timeout              = 18
      file_not_found          = 19
      dataprovider_exception  = 20
      control_flush_error     = 21
      OTHERS                  = 22.

  IF sy-subrc <> 0.
    WRITE :/ 'error archivo SERVER!!!!'  ,
           /  sy-msgv1 ,
           /  sy-msgv2 ,
           /  sy-msgv3 ,
           /  sy-msgv4 .
  ELSE.
    SKIP 2 .
    FORMAT COLOR 3 ON.
    WRITE : / 'Se genero archivo SERVER:', archivo_s.
    FORMAT COLOR 3 OFF.
  ENDIF.
ENDFORM.
