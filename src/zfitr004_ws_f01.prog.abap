*&---------------------------------------------------------------------*
*&  Include           ZFITR004_WS_F01
*&---------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*&      Form  cargo_datos
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM cargo_datos.
  REFRESH int_tabla.
  SELECT * FROM bsik WHERE bukrs  = p_bukrs
                     AND   hbkid  = v_hbkid
                     AND   zfbdt >= v_fechai
                     AND   zfbdt =< v_fechat
                     AND   zlspr = 'S'.

    IF bsik-blart = 'F7'.
      bsik-xblnr = bsik-zuonr.
    ENDIF.

    SELECT SINGLE * FROM  zfitr004
                    WHERE bukrs  = p_bukrs
                    AND   belnr  = bsik-belnr
                    AND   gjahr  = bsik-gjahr
                    AND   xblnr  = bsik-xblnr
                    AND   lifnr  = bsik-lifnr
                    AND   estado = '1'.

    IF sy-subrc <> 0.
      MOVE-CORRESPONDING bsik TO int_tabla.

      SELECT SINGLE stcd1 name1 FROM lfa1 INTO  (int_tabla-stcd1, int_tabla-name1)
                                    WHERE lifnr = int_tabla-lifnr.

      SELECT SINGLE bankl bankn FROM lfbk INTO  (int_tabla-bankl, int_tabla-bankn)
                                    WHERE lifnr = int_tabla-lifnr AND
                                          banks = 'CL'.

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

  CLEAR : archivo, archivo_s.

  IF par_tes = gc_x.
    CONCATENATE p_archiv 'TEST' p_bukrs sy-datum sy-uzeit 'EC.txt' INTO  archivo.
  ELSE.
    CONCATENATE p_bukrs sy-datum sy-uzeit 'EC.txt' INTO  archivo.
  ENDIF.
  CONDENSE archivo NO-GAPS.
*
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
      PERFORM genera_archivo_bci.
      PERFORM cargo_datos.
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
                                         WHERE bukrs = p_bukrs
                                         AND   fecha_rem = v_fecrem.



  LOOP AT int_tabla1.

    reg_stder-zbukr = p_bukrs.

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
      zfitr004-bukrs         = p_bukrs.
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
                                         WHERE bukrs     = p_bukrs
                                         AND   fecha_rem = v_fecrem.
  LOOP AT int_tabla1.

    reg_stder-zbukr = p_bukrs.

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

    IF par_tes = ' '.
      zfitr004-bukrs         = p_bukrs.
      zfitr004-fecha_rem     = v_fecrem.
      zfitr004-secuencia     = secuencia + 1.
      zfitr004-belnr         = int_tabla1-belnr.
      zfitr004-gjahr         = int_tabla1-gjahr.
      zfitr004-xblnr         = int_tabla1-xblnr.
      zfitr004-lifnr         = int_tabla1-lifnr.
      zfitr004-estado        = '1'.
      INSERT zfitr004.
    ENDIF.
  ENDLOOP.

  PERFORM listado.  "informe.
  PERFORM preparo_salida_016.
  IF par_tes EQ gc_x.
    PERFORM bajar_archivo_016.
  ELSE.
    PERFORM ws_carga_nomina       TABLES out_reg_bci_x.
  ENDIF.


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
    ENDIF.
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

    WRITE : /001 'V' ,
             003 int_tabla1-belnr  ,
             014 p_bukrs       ,
             019 int_tabla1-xblnr  ,
             037 int_tabla1-stcd1 ,
             054 int_tabla1-name1 ,
             092 int_tabla1-zfbdt,
             101 int_tabla1-wrbtr CURRENCY 'CLP'.
    HIDE: int_tabla1-belnr, p_bukrs, int_tabla1-gjahr.

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
    SET PARAMETER ID 'BUK' FIELD p_bukrs.
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
      SELECT SINGLE paval INTO rut FROM t001z WHERE bukrs = reg_stder-zbukr
                                   AND   party = 'TAXNR' .
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
    MOVE '************** ARCHIVO TEST *********' TO out_reg_bci_x.
    APPEND out_reg_bci_x.
    MOVE ' ' TO out_reg_bci_x.
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
    out_reg_bci-cod_banco    = ' '.
    out_reg_bci-cuenta_cte   = ' '.
    IF reg_stder-mod_pago    = 'T'.
      out_reg_bci-cod_banco  = reg_stder-codigo_banco.
      out_reg_bci-cuenta_cte = reg_stder-cuenta_abono.
      IF reg_stder-codigo_banco = '016'.
        out_reg_bci-forma_pago  = 'CCT'.
      ELSE.
        out_reg_bci-forma_pago  = 'OTC'.
      ENDIF.
    ELSE.
      out_reg_bci-cod_banco    = '016'.
      out_reg_bci-forma_pago   = 'VVC'.
    ENDIF.
*
    out_reg_bci-cod_sucursal = ' '.
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

    out_reg_bci-nro_docto     = reg_stder-num_docto.
    out_reg_bci-nro_docto_rel = 0.
    out_reg_bci-valor_info    = reg_stder-monto_docto.
    out_reg_bci-valor_pago    = reg_stder-monto_docto.
    out_reg_bci-estado_pago   = 'OK'.

    CONCATENATE reg_stder-fecha_vcto+6(2) reg_stder-fecha_vcto+4(2) reg_stder-fecha_vcto+0(4)
                INTO out_reg_bci-fecha_pago.

    out_reg_bci-glosa         = ''.

    largo = strlen( reg_stder-rut_prov ).

    out_reg_bci-rut_ret1       = 0.
    out_reg_bci-rut_ret1_dvr   = ' '.
    out_reg_bci-paterno1       = '               '.
    out_reg_bci-materno1       = '               '.
    out_reg_bci-nombre1        = '               '.

    out_reg_bci-rut_ret2       = 0.
    out_reg_bci-rut_ret2_dvr   = ' '.
    out_reg_bci-paterno2       = '               '.
    out_reg_bci-materno2       = '               '.
    out_reg_bci-nombre2        = '               '.

    out_reg_bci_x              = out_reg_bci.

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
*FORM lee_ruta_server  CHANGING p_server p_dirpc.
*  DATA: prgname(40) TYPE c VALUE 'ZFITR004',
*        lv_dirpc    TYPE string.
**
*  CLEAR p_server.
*  SELECT zruta zruta_respaldo INTO (p_server, lv_dirpc)
*    FROM ztparamftp  WHERE zbukr = p_bukrs
*                       AND zprog = prgname.
*  ENDSELECT.
*
*  IF par_di EQ 'X' AND p_bankl EQ '016'.
*    IF p_server IS INITIAL AND p_bukrs IS NOT INITIAL.
*      MESSAGE e899(fi) WITH 'Falta directorio del Servidor'
*                            ',configurar en trx. ZPARFTP'.
*    ENDIF.
*  ELSE.
*    CLEAR p_server.
*  ENDIF.
*  IF p_dirpc IS INITIAL.
*    p_dirpc = lv_dirpc.
*  ENDIF.
*ENDFORM.
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
*&---------------------------------------------------------------------*
*&      Form  VALIDACION_ACCESOS
*&---------------------------------------------------------------------*
FORM validacion_accesos USING p_lv_bukrs.
*
  SELECT SINGLE puerto INTO @DATA(lv_puerto)
         FROM zws_puerto WHERE sociedad EQ @p_lv_bukrs
                           AND programa EQ 'ZFITR016'
                           AND estado   EQ 'H'.
  IF sy-subrc <> 0.
    MESSAGE i899(fi) WITH 'No existe puerto ws habilitado '
                          ' para este programa y Sociedad : '
                          sy-repid p_lv_bukrs.
    LEAVE PROGRAM.
  ELSE.
    SELECT SINGLE bukrs INTO @DATA(lv_bukrs)
           FROM zfitr016 WHERE bukrs EQ @p_lv_bukrs.
    IF sy-subrc EQ 0.
      wa_sociedad-puerto = lv_puerto.
      SELECT SINGLE bukrs paval INTO (wa_sociedad-bukrs, wa_sociedad-stcd1 )
             FROM t001z WHERE bukrs EQ p_lv_bukrs
                          AND party EQ 'TAXNR'.
    ELSE.
      MESSAGE i899(fi) WITH 'No existen datos fijos para el WS '
                            ' verificar tabla ZFITR016  '.
      LEAVE PROGRAM.
    ENDIF.
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  CARGA_DATOS
*&---------------------------------------------------------------------*
FORM carga_datos .
  DATA : lw_vrm_value TYPE vrm_value.
*
  CLEAR: gr_fac[], gr_ncr[].

  SELECT valsign valoption valfrom valto  INTO TABLE gr_fac
         FROM setleaf   WHERE setname = 'ZFITR001'.
  IF gr_fac[] IS INITIAL.
    MESSAGE e899(v1) WITH 'Revisar Set de Datos Cl. Doctos Factura'.
  ENDIF.
*
  SELECT valsign valoption valfrom valto  INTO TABLE gr_ncr
         FROM setleaf   WHERE setname = 'ZFITR002'.
  IF gr_ncr[] IS INITIAL.
    MESSAGE e899(v1) WITH 'Revisar Set de Datos Cl. Doctos N.Crédito'.
  ENDIF.
*
  CLEAR gt_list[].
  lw_vrm_value-key  =  '1'.
  lw_vrm_value-text =  'CARGAR_NOMINA'.
  APPEND lw_vrm_value TO gt_list.

  lw_vrm_value-key  =  '2'.
  lw_vrm_value-text =  'RENDICION_NOMINA'.
  APPEND lw_vrm_value TO gt_list.

  lw_vrm_value-key  =  '3'.
  lw_vrm_value-text =  'CARGA_MANUAL'.
  APPEND lw_vrm_value TO gt_list.
*
  CALL FUNCTION 'VRM_SET_VALUES'
    EXPORTING
      id              = 'P_PROCES'
      values          = gt_list
    EXCEPTIONS
      id_illegal_name = 0
      OTHERS          = 0.
*
  CLEAR gt_convenio[].
  SELECT DISTINCT bukrs, convenio INTO TABLE @DATA(lt_convenio)
        FROM zfitr016 WHERE bukrs    NE @space
                       AND  convenio NE @space.
  LOOP AT lt_convenio INTO DATA(wa_convenio).
    lw_vrm_value-key  =  |{ wa_convenio-convenio ALPHA = OUT }|.
    lw_vrm_value-text =  wa_convenio-bukrs.
    APPEND lw_vrm_value TO gt_convenio.
  ENDLOOP.
*
  CALL FUNCTION 'VRM_SET_VALUES'
    EXPORTING
      id              = 'P_CONVEN'
      values          = gt_convenio
    EXCEPTIONS
      id_illegal_name = 0
      OTHERS          = 0.
*
  CLEAR gt_tipo_pago[].
  SELECT bukrs, convenio, tipo_pago INTO TABLE @DATA(lt_tipo_pago)
        FROM zfitr016 WHERE bukrs     NE @space
                       AND  convenio  NE @space
                       AND  tipo_pago NE @space
                       ORDER BY bukrs.
  LOOP AT lt_tipo_pago INTO DATA(wa_tipo_pago).
    lw_vrm_value-key  =  |{ wa_tipo_pago-convenio }_{ wa_tipo_pago-tipo_pago }|.
    lw_vrm_value-text =  wa_tipo_pago-bukrs.
    APPEND lw_vrm_value TO gt_tipo_pago.
  ENDLOOP.
*
  CALL FUNCTION 'VRM_SET_VALUES'
    EXPORTING
      id              = 'P_TIPOPA'
      values          = gt_tipo_pago
    EXCEPTIONS
      id_illegal_name = 0
      OTHERS          = 0.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  WS_CARGA_NOMINA
*&---------------------------------------------------------------------*
FORM ws_carga_nomina  TABLES ti_gt_file.
  DATA: output            TYPE zbciiservicio_pago_bci_cargar,
        input             TYPE zbciiservicio_pago_bci_cargar1,
        lw_request        TYPE zbcicargar_nomina_request,
        lw_atributos      TYPE zbciatributos_to,
        lw_nomina_result  TYPE zbcicargar_nomina_response,
        lw_error          TYPE zbcierror_to,
        proxy             TYPE REF TO zbcico_iservicio_pago_bci,
        lo_sys_exception1 TYPE REF TO cx_ai_system_fault,
        lo_sys_exception2 TYPE REF TO cx_ai_application_fault,
        lw_zfi_log_ws     TYPE zfi_log_ws,
        l_exception_msg   TYPE string,
        lv_archivo        TYPE string,
        lv_cuerpo         TYPE xstring,
        lv_cuerp64        TYPE string,
        lv_rut            TYPE stcd1,
        lv_dv             TYPE char01,
        lv_codigocca      TYPE char10,
        lv_convenio       TYPE char10,
        lv_plantilla      TYPE char20,
        lv_gjahr          TYPE bkpf-gjahr,
        lv_belnr          TYPE bkpf-belnr,
        lv_error          TYPE c.
* ZFITR010_WS_NOVEDADES_F01  , RSTT_TEST

  lv_archivo = archivo.
  SPLIT wa_sociedad-stcd1 AT '-' INTO lv_rut
                                      lv_dv.

  REPLACE ALL OCCURRENCES OF '.' IN lv_rut WITH ''.
  CONDENSE lv_rut NO-GAPS.
*  lv_cuerp64 = obj->if_http_utility~encode_base64( ti_gt_file ) .

  CALL FUNCTION 'SCMS_TEXT_TO_XSTRING'
    IMPORTING
      buffer   = lv_cuerpo
    TABLES
      text_tab = ti_gt_file
    EXCEPTIONS
      failed   = 1
      OTHERS   = 2.
  IF sy-subrc <> 0.
* Implement suitable error handling here
  ENDIF.
  CALL FUNCTION 'SCMS_BASE64_ENCODE_STR'
    EXPORTING
      input  = lv_cuerpo
    IMPORTING
      output = lv_cuerp64.
*
  TRY.
      CREATE OBJECT proxy
        EXPORTING
          logical_port_name = wa_sociedad-puerto.

    CATCH cx_ai_system_fault      INTO lo_sys_exception1.
      l_exception_msg = lo_sys_exception1->get_text( ).
  ENDTRY.
*
  IF l_exception_msg IS INITIAL.
    TRY.

* INFORMACION ESTRUCTURA DD ATRIBUTOS
        lv_codigocca                   = |{ wa_zfitr016-codigo_cca ALPHA = OUT }|.
        lv_convenio                    = |{ wa_zfitr016-convenio   ALPHA = OUT }|.
        lw_request-convenio            = condense( lv_convenio ).
        lw_atributos-codigo_cca        = condense( lv_codigocca ).
        lw_atributos-modo_servicio     = 'F'. "CONFIRMING wa_zfitr016-modo_servicio.
        lw_atributos-contenido_nomina  = wa_zfitr016-contenido_nomina.
        lw_request-atributos           = lw_atributos.
* INFORMACION DEL DETALLE
*        IF v_fecrem IS NOT INITIAL.
*          lw_request-fecha_pago        =  |{ v_fecrem DATE = USER }|.
*          TRANSLATE lw_request-fecha_pago USING './'.
*        ENDIF.
        lv_plantilla                 = |{ wa_zfitr016-plantilla_archivo ALPHA = OUT }|.
        lw_request-rut_empresa       = lv_rut.
        lw_request-dv_empresa        = lv_dv.
        lw_request-rut_usuario       = lv_rut.
        lw_request-dv_usuario        = lv_dv.
        lw_request-nombre_archivo    = lv_archivo.
        lw_request-tipo_pago         = wa_zfitr016-tipo_pago.
        lw_request-plantilla_archivo = condense( lv_plantilla ).
        lw_request-cuerpo_archivo    = lv_cuerp64.
        input-request                = lw_request.
*
        CALL METHOD proxy->cargar_nomina
          EXPORTING
            input  = input
          IMPORTING
            output = output.

        PERFORM graba_log USING lv_rut lv_dv
                                input
                                output
                                l_exception_msg
                                'CARGAR_NOMINA'
                          CHANGING lw_zfi_log_ws.
*
        lw_zfi_log_ws-proceso     = 'E_CONFIRMING'.
        lw_nomina_result          = output-cargar_nomina_result.
        lw_error                  = lw_nomina_result-error.
*
*        lw_zfi_log_ws-fecha_pago  = .
        lw_zfi_log_ws-icono_pdf   = icon_pdf.
        lw_zfi_log_ws-file_pdf    = lv_cuerpo.
        lw_zfi_log_ws-codigo_ret  = lw_error-codigo.
        TRANSLATE lw_zfi_log_ws-codigo_ret TO UPPER CASE.
        lw_zfi_log_ws-descripcion = lw_error-descripcion.
        lw_zfi_log_ws-estado      = lw_nomina_result-estado.
        lw_zfi_log_ws-archivo     = lw_nomina_result-nombre_archivo.
        lw_zfi_log_ws-num_folio   = lw_nomina_result-numero_folio.
*
        MODIFY zfi_log_ws FROM  lw_zfi_log_ws.
*
      CATCH cx_ai_system_fault      INTO lo_sys_exception1.
        l_exception_msg = lo_sys_exception1->get_text( ).
      CATCH cx_ai_application_fault INTO lo_sys_exception2.
        l_exception_msg = lo_sys_exception2->get_text( ).
    ENDTRY.
  ELSE.
    PERFORM graba_log USING lv_rut lv_dv
                            input
                            output
                            l_exception_msg
                            'E_CONFIRMING'
                      CHANGING lw_zfi_log_ws.
*
    MODIFY zfi_log_ws FROM  lw_zfi_log_ws.
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  GRABA_LOG
*&---------------------------------------------------------------------*
FORM graba_log  USING    p_lv_rut
                         p_lv_dv
                         p_input
                         p_output
                         p_exception_msg
                         p_proceso
               CHANGING lw_zfi_log_ws TYPE zfi_log_ws.
*
  CLEAR lw_zfi_log_ws.
  lw_zfi_log_ws-bukrs           = p_bukrs.
  lw_zfi_log_ws-datum           = sy-datum.
  lw_zfi_log_ws-uzeit           = sy-uzeit.
  lw_zfi_log_ws-uname           = sy-uname.
  lw_zfi_log_ws-rut_empresa     = p_lv_rut  && '-' && p_lv_dv.
  lw_zfi_log_ws-proceso         = p_proceso.
  lw_zfi_log_ws-ubnkl           = gc_banco.
*  lw_zfi_log_ws-laufd           = p_fecha.
*  lw_zfi_log_ws-laufi           = p_nomina.
*
  PERFORM lee_xml USING p_input
                       'ZBCICO_ISERVICIO_PAGO_BCI'
                       p_proceso
                       'I'
                  CHANGING lw_zfi_log_ws-xml_envio
                           lw_zfi_log_ws-icono_envio.

  PERFORM lee_xml USING p_output
                       'ZBCICO_ISERVICIO_PAGO_BCI'
                       p_proceso
                       'R'
                  CHANGING lw_zfi_log_ws-xml_respuesta
                           lw_zfi_log_ws-icono_respuesta.
*
  IF lw_zfi_log_ws-xml_envio     IS INITIAL AND
     lw_zfi_log_ws-xml_respuesta IS INITIAL.
    lw_zfi_log_ws-xml_envio = p_exception_msg.
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  LEE_XML
*&---------------------------------------------------------------------*
FORM lee_xml  USING    p_wa_in
                       p_obj_name
                       p_method
                       p_tipo_envio
              CHANGING p_xml_myid
                       p_icono.
  DATA: xsalida  TYPE string,
        l_name   TYPE sychar20,
        l_transf TYPE sychar50.
*
  CHECK p_wa_in IS NOT INITIAL.
  SELECT SINGLE name INTO l_name
          FROM sproxxsl WHERE class  EQ p_obj_name AND
                              method EQ p_method.
  IF sy-subrc EQ 0.
    CASE p_tipo_envio.
      WHEN 'I'.
        CONCATENATE '/1SAI/TAS' l_name INTO l_transf.
        CALL TRANSFORMATION (l_transf)
             SOURCE input = p_wa_in
             RESULT XML xsalida.
      WHEN 'R'.
        CONCATENATE '/1SAI/TXS' l_name INTO l_transf.
        CALL TRANSFORMATION (l_transf)
          SOURCE output = p_wa_in
          RESULT XML xsalida.
    ENDCASE.

    p_xml_myid = cl_abap_codepage=>convert_to( xsalida ).
  ELSE.
    xsalida        = 'LECTURA DE XML NO FUE POSIBLE'.
    p_xml_myid = cl_abap_codepage=>convert_to( xsalida ).
  ENDIF.
*
  CASE p_tipo_envio.
    WHEN 'I'. p_icono = icon_xml_doc.
    WHEN 'R'. p_icono = icon_output_request.
  ENDCASE.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  LEE_DATOS
*&---------------------------------------------------------------------*
FORM lee_datos .
  DATA : lr_proce TYPE RANGE OF zfi_log_ws-proceso,
         lr_fecha TYPE RANGE OF zfi_log_ws-laufd,
         lr_pago  TYPE RANGE OF zfi_log_ws-fecha_pago.
*
  SELECT * INTO TABLE gt_salida
         FROM zfi_log_ws WHERE bukrs       EQ p_bukrs
                         AND   datum       IN s_datum
                         AND   uname       IN s_uname
                         AND   proceso     EQ 'E_CONFIRMING'.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  MUESTRA_DATOS
*&---------------------------------------------------------------------*
FORM muestra_datos .
  DATA: lt_sort       TYPE lvc_t_sort,
        lt_fieldcat   TYPE lvc_t_fcat,
        lv_grid_title TYPE lvc_title VALUE 'Reporte Envios BCI',
        wa_layout     TYPE lvc_s_layo.
*
  MOVE sy-repid           TO gv_repid.
  PERFORM layout_init     USING wa_layout.
  PERFORM fieldcat_init   USING lt_fieldcat[].
  PERFORM sort            USING lt_sort[].

*
  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY_LVC'
    EXPORTING
      i_callback_program       = gv_repid
      i_callback_pf_status_set = 'PF_STATUS'
      i_callback_user_command  = 'USER_COMMAND'
      i_grid_title             = lv_grid_title
      is_layout_lvc            = wa_layout
      it_fieldcat_lvc          = lt_fieldcat[]
      it_sort_lvc              = lt_sort
      i_save                   = 'A'
    TABLES
      t_outtab                 = gt_salida
    EXCEPTIONS
      program_error            = 1
      OTHERS                   = 2.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  user_command
*&---------------------------------------------------------------------*
FORM user_command USING r_ucomm    LIKE sy-ucomm            "#EC NEEDED
                        rs_selfield TYPE slis_selfield.     "#EC CALLED
  DATA lw_salida TYPE zfi_log_ws.
*
  CASE rs_selfield-fieldname.
    WHEN 'ICONO_ENVIO'.
      READ TABLE gt_salida INTO lw_salida INDEX rs_selfield-tabindex.
      IF sy-subrc EQ 0.
        PERFORM muestra_xml USING lw_salida-xml_envio.
      ENDIF.
    WHEN 'ICONO_RESPUESTA'.
      READ TABLE gt_salida INTO lw_salida INDEX rs_selfield-tabindex.
      IF sy-subrc EQ 0.
        PERFORM muestra_xml USING lw_salida-xml_respuesta.
      ENDIF.
    WHEN 'ICONO_PDF'.
      READ TABLE gt_salida INTO lw_salida INDEX rs_selfield-tabindex.
      IF sy-subrc EQ 0.
        PERFORM muestra_pdf USING lw_salida.
      ENDIF.
  ENDCASE.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  PF_STATUS
*&---------------------------------------------------------------------*
FORM pf_status USING ce_func_exclude TYPE slis_t_extab.     "#EC CALLED
  DATA: fcode_attrib_tab LIKE smp_dyntxt OCCURS 4 WITH HEADER LINE,
        l_procesado      TYPE char50.
*
  CLEAR: fcode_attrib_tab, fcode_attrib_tab[].
*
  PERFORM dynamic_report_fcodes(rhteiln0) TABLES fcode_attrib_tab
                                          USING  ce_func_exclude
                                                 ' ' ' '.
  SET PF-STATUS 'ALVLIST' EXCLUDING ce_func_exclude
                                              OF PROGRAM 'RHTEILN0'.
ENDFORM.                    "PF_STATUS
*&---------------------------------------------------------------------*
*&      Form  LAYOUT_INIT
*&---------------------------------------------------------------------*
FORM layout_init USING rs_layout TYPE lvc_s_layo.
  CLEAR rs_layout.
*  rs_layout-f2code               = 'DISPLAY'.
  rs_layout-zebra                = gc_x.
  rs_layout-detailinit           = gc_x.
  rs_layout-cwidth_opt           = gc_x.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  FIELDCAT_INIT
*&---------------------------------------------------------------------*
FORM fieldcat_init  USING p_gt_fieldcat TYPE  lvc_t_fcat.
*
  CALL FUNCTION 'LVC_FIELDCATALOG_MERGE'
    EXPORTING
      i_structure_name       = gc_tabla
    CHANGING
      ct_fieldcat            = p_gt_fieldcat
    EXCEPTIONS
      inconsistent_interface = 1
      program_error          = 2
      OTHERS                 = 3.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.
*
  LOOP AT p_gt_fieldcat ASSIGNING FIELD-SYMBOL(<datos>).
*
    CASE <datos>-fieldname.
      WHEN 'BUKRS'.
        <datos>-key       = gc_x.
      WHEN 'DATUM'.
        <datos>-scrtext_m = 'Fecha Envio'.
        <datos>-key       = gc_x.
      WHEN 'UZEIT'.
        <datos>-scrtext_m = 'Hora Envio'.
        <datos>-key       = gc_x.
      WHEN 'RUT_EMPRESA'.
        <datos>-scrtext_m = 'RUT Empresa'.
        <datos>-key       = gc_x.
      WHEN 'RUT_USUARIO'.
        <datos>-scrtext_m = 'RUT Proveedor'.
        <datos>-key       = gc_x.
        <datos>-tech      = gc_x.
      WHEN 'PROCESO'.
        <datos>-scrtext_m = 'Proceso XML'.
        <datos>-key       = gc_x.
      WHEN 'LAUFD'.
        <datos>-scrtext_m = 'Fecha de propuesta'.
      WHEN 'XML_ENVIO' OR 'XML_RESPUESTA' OR 'FILE_PDF'.
        <datos>-tech      = gc_x.
      WHEN 'ICONO_ENVIO'.
        <datos>-scrtext_m = 'XML Envio'.
        <datos>-icon      = gc_x.
        <datos>-hotspot   = gc_x.
      WHEN 'ICONO_RESPUESTA'.
        <datos>-scrtext_m = 'XML Respuesta'.
        <datos>-icon      = gc_x.
        <datos>-hotspot   = gc_x.
      WHEN 'ICONO_PDF'.
        <datos>-scrtext_m = 'Archivo'.
        <datos>-icon      = gc_x.
        <datos>-hotspot   = gc_x.
      WHEN 'ESTADO'.
        <datos>-scrtext_m = 'Estado'.
        <datos>-emphasize = 'C210'.
      WHEN 'CODIGO_RET'.
        <datos>-scrtext_m = 'Código Retorno'.
        <datos>-emphasize = 'C210'.
      WHEN 'DESCRIPCION'.
        <datos>-scrtext_m = 'Descripción'.
        <datos>-emphasize = 'C210'.
      WHEN 'ARCHIVO'.
        <datos>-scrtext_m = 'Nombre Archivo'.
        <datos>-emphasize = 'C210'.
      WHEN 'NUM_FOLIO'.
        <datos>-scrtext_m = 'Folio Retorno'.
        <datos>-emphasize = 'C210'.
      WHEN 'RENDICION_NOM'.
        <datos>-scrtext_m = 'Con Rendición'.
      WHEN 'ENVIOS_ERRONEOS'.
        <datos>-tech      = gc_x.
    ENDCASE.
    <datos>-colddictxt = 'M'.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  SORT
*&---------------------------------------------------------------------*
FORM sort  USING    p_lt_sort TYPE lvc_t_sort.
  DATA lw_sort TYPE lvc_s_sort.
*
  CLEAR p_lt_sort[].
  lw_sort-fieldname = 'BUKRS'.
  lw_sort-up        = gc_x.
  APPEND lw_sort TO p_lt_sort.
*
  lw_sort-fieldname = 'PROCESO'.
  lw_sort-up        = gc_x.
  APPEND lw_sort TO p_lt_sort.
*
  lw_sort-fieldname = 'DATUM'.
  lw_sort-up        = gc_x.
  APPEND lw_sort TO p_lt_sort.
*
  lw_sort-fieldname = 'UZEIT'.
  lw_sort-up        = gc_x.
  APPEND lw_sort TO p_lt_sort.
*
  lw_sort-fieldname = 'RUT_EMPRESA'.
  lw_sort-up        = gc_x.
  APPEND lw_sort TO p_lt_sort.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  MUESTRA_XML
*&---------------------------------------------------------------------*
FORM muestra_xml  USING  p_lw_salida.

  CALL FUNCTION 'DISPLAY_XML_STRING'
    EXPORTING
      xml_string      = p_lw_salida
*     TITLE           =
*     STARTING_X      = 5
*     STARTING_Y      = 5
    EXCEPTIONS
      no_xml_document = 1
      OTHERS          = 2.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  MUESTRA_PDF
*&---------------------------------------------------------------------*
FORM muestra_pdf  USING p_zfi_log_ws TYPE zfi_log_ws.
  " binary itab definations
  TYPES: BEGIN OF ty_itab,
           line TYPE x LENGTH 255,
         END OF ty_itab.
  "Global Data Definations
  DATA: go_pdf_object  TYPE REF TO cl_gui_html_viewer,
        go_pdf_dialog  TYPE REF TO cl_gui_dialogbox_container,
        go_pdf_handler TYPE REF TO lcl_evt_handler.
  DATA: lt_itab  TYPE STANDARD TABLE OF x255, "ty_itab,
        lv_url   TYPE char255,
        lv_type  TYPE char20,
        ls_str   TYPE string,
        lt_str   TYPE TABLE OF string,
        lt_data  TYPE STANDARD TABLE OF x255,
        lv_title TYPE char255,
        lv_name  TYPE string,
        lv_size  TYPE i VALUE 0.

*
  lv_type =  'text'.
  CALL METHOD cl_abap_conv_in_ce=>create
    EXPORTING
      input = p_zfi_log_ws-file_pdf
    RECEIVING
      conv  = DATA(lr_conv).

  CALL METHOD lr_conv->read
    IMPORTING
      data = ls_str.

  lv_title = 'Archivo enviado : ' && | | && p_zfi_log_ws-archivo.
  cl_abap_browser=>show_html(
      EXPORTING
          html_string = ls_str
          title       = lv_title ).
ENDFORM.

CLASS lcl_evt_handler IMPLEMENTATION.
  METHOD event_close.
    CALL METHOD sender->set_visible
      EXPORTING
        visible = space.
    CALL METHOD sender->free( ).
  ENDMETHOD.
ENDCLASS.
