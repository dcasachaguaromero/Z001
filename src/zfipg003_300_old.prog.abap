*&---------------------------------------------------------------------*
*&  Include           ZFIPG003_300
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  STATUS_0300  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE status_0300 OUTPUT.

  REFRESH tab.
  MOVE 'REFR' TO tab-fcode.
  APPEND tab.
  MOVE 'ORD1' TO tab-fcode.
  APPEND tab.
  MOVE 'ORD2' TO tab-fcode.
  APPEND tab.

  SET  PF-STATUS 'ZFIPG003' EXCLUDING tab.
  SET  TITLEBAR 'T01'.

  CLEAR: pass1, pass2.

  LOOP AT SCREEN.
    IF screen-name EQ 'PASS1'.
      screen-invisible = '1'.
      MODIFY SCREEN.
    ENDIF.
    IF screen-name EQ 'PASS2'.
      screen-invisible = '1'.
      MODIFY SCREEN.
    ENDIF.
  ENDLOOP.
*  Modificacion Hermaan
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*    select single * from zfirmadigital where bukrs eq bukrs.
*
* NEW CODE
    SELECT *
    UP TO 1 ROWS  from zfirmadigital where bukrs eq bukrs ORDER BY PRIMARY KEY.

    ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
      IF sy-subrc ne 0.
        PERFORM genero_firma.
        LEAVE TO SCREEN 0.
      ENDIF.

*  end modificacion
ENDMODULE.                 " STATUS_0300  OUTPUT


*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0300_EXIT  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_0300_exit INPUT.
  CASE sy-ucomm.
    WHEN 'CANCL' .
      LEAVE TO SCREEN 0.
  ENDCASE.

ENDMODULE.                 " USER_COMMAND_0300_EXIT  INPUT

*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0300  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_0300 INPUT.
  CASE sy-ucomm.
    WHEN 'IMPR' .
      PERFORM genero_firma.
      LEAVE TO SCREEN 0.
  ENDCASE.

  CLEAR sy-ucomm.

ENDMODULE.                 " USER_COMMAND_0300  INPUT

*&---------------------------------------------------------------------*
*&      Module  VALUE_ORG1  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE value_org1 INPUT.
  CALL FUNCTION 'WS_FILENAME_GET'
    EXPORTING
      def_filename     = dir_org1
      mask             = ',*.bmp.'
      mode             = 'O'
      title            = 'Upload File'(078)
    IMPORTING
      filename         = dir_org1
    EXCEPTIONS
      inv_winsys       = 1
      no_batch         = 2
      selection_cancel = 3
      selection_error  = 4
      OTHERS           = 5.

ENDMODULE.                 " VALUE_ORG1  INPUT
*&---------------------------------------------------------------------*
*&      Module  VALUE_DES1  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE value_des1 INPUT.
  CALL FUNCTION 'WS_FILENAME_GET'
    EXPORTING
      def_filename     = dir_des1
      mask             = ',*.bmp.'
      mode             = 'O'
      title            = 'Upload File'(078)
    IMPORTING
      filename         = dir_des1
    EXCEPTIONS
      inv_winsys       = 1
      no_batch         = 2
      selection_cancel = 3
      selection_error  = 4
      OTHERS           = 5.

ENDMODULE.                 " VALUE_DES1  INPUT
*&---------------------------------------------------------------------*
*&      Module  VALUE_ORG2  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE value_org2 INPUT.
  CALL FUNCTION 'WS_FILENAME_GET'
    EXPORTING
      def_filename     = dir_org2
      mask             = ',*.bmp.'
      mode             = 'O'
      title            = 'Upload File'(078)
    IMPORTING
      filename         = dir_org2
    EXCEPTIONS
      inv_winsys       = 1
      no_batch         = 2
      selection_cancel = 3
      selection_error  = 4
      OTHERS           = 5.



ENDMODULE.                 " VALUE_ORG2  INPUT
*&---------------------------------------------------------------------*
*&      Module  VALUE_DES2  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE value_des2 INPUT.
  CALL FUNCTION 'WS_FILENAME_GET'
    EXPORTING
      def_filename     = dir_des2
      mask             = ',*.bmp.'
      mode             = 'O'
      title            = 'Upload File'(078)
    IMPORTING
      filename         = dir_des2
    EXCEPTIONS
      inv_winsys       = 1
      no_batch         = 2
      selection_cancel = 3
      selection_error  = 4
      OTHERS           = 5.

ENDMODULE.                 " VALUE_DES2  INPUT

*&---------------------------------------------------------------------*
*&      Module  VALIDA_0300  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE valida_0300 INPUT.
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*  SELECT SINGLE * FROM zfirmadigital WHERE bukrs EQ bukrs.
*
* NEW CODE
  SELECT *
  UP TO 1 ROWS  FROM zfirmadigital WHERE bukrs EQ bukrs ORDER BY PRIMARY KEY.

  ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01

  IF sy-subrc <> 0.
*    MESSAGE 'No existe rfc' TYPE 'E'.
  ELSE.
    CLEAR messtab.
    REFRESH messtab.

    rfcdest = zfirmadigital-rfcdest.
    source = dir_org1.
    destination = dir_des1.
    pwd = pass1.
    CALL FUNCTION 'S_DES_FIRMA'
      EXPORTING
        SOURCE      = SOURCE
        destination = destination
        pwd         = pwd
        rfcdest     = rfcdest.
    IF sy-subrc EQ 0.
      "Se borra la misma firma antes de subir la nueva
      "INICIO CII - 20100810
      PERFORM borrar_firmas USING nfirma1."Borra firma previo a su carga
      "FIN CII
      tdname_001 = nfirma1.
      filename_004 = dir_des1.
      tdname_005 = nfirma1.
      tdname_008 = nfirma1.
      CALL FUNCTION 'ZSUBEFIRMA'
        EXPORTING
          tdname_001     = tdname_001
          filename_004   = filename_004
          tdname_005     = tdname_005
          autoheight_007 = ''
          tdname_008     = tdname_008
        TABLES
          messtab        = messtab.
      LOOP AT messtab.
        IF messtab-msgtyp EQ 'E'.
          CALL FUNCTION 'Z_DEL_FIRMA'
            EXPORTING
              destination = destination.

          MESSAGE 'No se puede desencriptar firma 1' TYPE 'E'.
        ENDIF.
      ENDLOOP.
      CALL FUNCTION 'Z_DEL_FIRMA'
        EXPORTING
          destination = destination.
    ENDIF.

****Firma2***************

    CLEAR messtab.
    REFRESH messtab.

    source = dir_org2.
    destination = dir_des2.
    pwd = pass2.
    CALL FUNCTION 'S_DES_FIRMA'
      EXPORTING
        SOURCE      = SOURCE
        destination = destination
        pwd         = pwd
        rfcdest     = rfcdest.
    IF sy-subrc EQ 0.
      "Se borra la misma firma antes de subir la nueva
      "INICIO JFY - 20100830
      PERFORM borrar_firmas USING nfirma2. "Borra firma previo a su carga
      "FIN JFY

      tdname_001 = nfirma2.
      filename_004 = dir_des2.
      tdname_005 = nfirma2.
      tdname_008 = nfirma2.
      CALL FUNCTION 'ZSUBEFIRMA'
        EXPORTING
          tdname_001     = tdname_001
          filename_004   = filename_004
          tdname_005     = tdname_005
          autoheight_007 = ''
          tdname_008     = tdname_008
        TABLES
          messtab        = messtab.
      LOOP AT messtab.
        IF messtab-msgtyp EQ 'E'.
          CALL FUNCTION 'Z_DEL_FIRMA'
            EXPORTING
              destination = destination.

          MESSAGE 'No se puede desencriptar firma 2' TYPE 'E'.
        ENDIF.
      ENDLOOP.
      CALL FUNCTION 'Z_DEL_FIRMA'
        EXPORTING
          destination = destination.
    ENDIF.

  ENDIF.
ENDMODULE.                 " VALIDA_0300  INPUT

*&---------------------------------------------------------------------*
*&      Form  genero_firma
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM genero_firma.
  zfipg003-bukrs = bukrs.
  zfipg003-nfirma1 = nfirma1.
  zfipg003-dir_org1 = dir_org1.
  zfipg003-dir_des1 = dir_des1.
  zfipg003-nfirma2 = nfirma2.
  zfipg003-dir_org2 = dir_org2.
  zfipg003-dir_des2 = dir_des2.

  MODIFY zfipg003.

  PERFORM imprimir.

*  PERFORM borra_firma.


ENDFORM.                    "genero_firma

*&---------------------------------------------------------------------*
*&      Form  borra_firma
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM borra_firma USING value(nfirma1)
                       value(nfirma2)
                       value(dir_des1)
                       value(dir_des2).

*Borra firmas*********************************
  IF NOT nfirma1 IS INITIAL.
    tdname_001 = nfirma1.
    CALL FUNCTION 'ZBORRAFIRMA'
      EXPORTING
        tdname_001 = tdname_001
        tdname_004 = tdname_001
        tdname_006 = tdname_001.
  ENDIF.



  IF NOT dir_des1 IS INITIAL.
    destination = dir_des1.
    CALL FUNCTION 'Z_DEL_FIRMA'
      EXPORTING
        destination = destination.
  ENDIF.



  IF NOT nfirma2 IS INITIAL.
    tdname_001 = nfirma2.
    CALL FUNCTION 'ZBORRAFIRMA'
      EXPORTING
        tdname_001 = tdname_001
        tdname_004 = tdname_001
        tdname_006 = tdname_001.
  ENDIF.



  IF NOT dir_des2 IS INITIAL.
    destination = dir_des2.
    CALL FUNCTION 'Z_DEL_FIRMA'
      EXPORTING
        destination = destination.
  ENDIF.


ENDFORM .                   "value_des2 INPUT


*&---------------------------------------------------------------------*
*&      Form  imprimir
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM imprimir.

  DATA: fecha1(8),
        fecha2(8),
        job(32),
        veces(4) TYPE n,
        tcheques(5) TYPE n.

  fecha1+0(2) = sy-datum+6(2).
  fecha1+2(2) = sy-datum+4(2).
  fecha1+4(4) = sy-datum+0(4).


  fecha2+0(2) = int_tabla-laufd+6(2).
  fecha2+2(2) = int_tabla-laufd+4(2).
  fecha2+4(4) = int_tabla-laufd+0(4).

  UPDATE zfipg002_det
      SET    nchequ_s = int_tabla-nchequ_s
      WHERE  bukrs = bukrs
      AND    nproceso = int_tabla-nproceso
      AND    laufi    = int_tabla-laufi
      AND    laufd    = int_tabla-laufd .

  REFRESH bdcdata.

  PERFORM bdc_dynpro      USING 'SAPF110V' '0200'.
  PERFORM bdc_field       USING 'BDC_CURSOR'
                            'F110V-LAUFI'.
  PERFORM bdc_field       USING 'BDC_OKCODE'
                                '=ENTER'.
  PERFORM bdc_field       USING 'F110V-LAUFD'
                                fecha2.
  PERFORM bdc_field       USING 'F110V-LAUFI'
                                int_tabla-laufi.

  PERFORM bdc_dynpro      USING 'SAPF110V' '0200'.
  PERFORM bdc_field       USING 'BDC_CURSOR'
                            'F110V-LAUFI'.
  PERFORM bdc_field       USING 'BDC_OKCODE'
                                '=ZADR'.

  PERFORM bdc_dynpro      USING 'SAPF110V' '1116'.
  PERFORM bdc_field       USING 'BDC_CURSOR'
                                'F110V-XSTRF'.
  PERFORM bdc_field       USING 'BDC_OKCODE'
                                '=EP'.
  PERFORM bdc_field       USING 'F110V-STRDT'
                                 fecha1.
  PERFORM bdc_field       USING 'F110V-XSTRF'
                                'X'.
  CONCATENATE 'F-' int_tabla-laufd '-' int_tabla-laufi '-' int_tabla-hbkid '-'
  int_tabla-zfbdt INTO job.

  PERFORM bdc_field       USING 'TBTCO-JOBNAME'
                                job.
  CALL TRANSACTION 'F110' USING bdcdata
                            MODE 'E'
                            UPDATE 'S'
                            MESSAGES INTO itab.




  UPDATE zfipg002_det
      SET    estado = 'P'
             impr_usuario = sy-uname
             impr_fecha   = sy-datum
             impr_hora    = sy-uzeit

      WHERE  bukrs = bukrs
      AND    nproceso = int_tabla-nproceso
      AND    laufi    = int_tabla-laufi
      AND    laufd    = int_tabla-laufd .

  sy-subrc =  1.
  veces    = 0.

* Cambio Time Out Mascara
*  WHILE sy-subrc <> 0 AND veces < 181 .
  WHILE sy-subrc <> 0 .
* Fin Cambio Time Out Mascara
    WAIT UP TO 02 SECONDS.
    veces = veces + 1.
    SELECT COUNT(*) INTO tcheques  FROM payr
                    WHERE zbukr   = bukrs
                    AND   laufd   = int_tabla-laufd
                    AND   laufi   = int_tabla-laufi.

    IF int_tabla-nchequ = tcheques.
      sy-subrc = 0.
    ELSE.
      sy-subrc = 1.
    ENDIF.

  ENDWHILE.



  IF sy-subrc <> 0 AND veces > 180.
*    PERFORM borra_firma.
    MESSAGE e004(zfi) WITH 'Se supero tiempo de espera (6 min).' 'No Se Genera Lista de Cheques.'.
  ELSE.
    PERFORM imprimir_listado.
  ENDIF.


  PERFORM proceso.
ENDFORM.                    "imprimir



*&---------------------------------------------------------------------*
*&      Form  Imprimir_Listado
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM imprimir_listado.

  DATA: print_parameters TYPE pri_params,
        archi_parameters TYPE arc_params,
        valid_flag(1) TYPE c.



  PERFORM set_list_print_param USING bukrs print_parameters.

  CONCATENATE 'Lista Cheque' int_tabla-hbkid int_tabla-descr
                INTO print_parameters-prtxt SEPARATED BY space.


  SUBMIT zfipg004 USING SELECTION-SCREEN '1000'
                 WITH v_fecha EQ int_tabla-laufd
                 WITH v_nomina EQ int_tabla-laufi
                 TO SAP-SPOOL
                 SPOOL PARAMETERS print_parameters
                 ARCHIVE PARAMETERS archi_parameters
                 WITHOUT SPOOL DYNPRO
                 AND RETURN.

  SUBMIT zfipg005 USING SELECTION-SCREEN '1000'
                 WITH v_fecha EQ int_tabla-laufd
                 WITH v_nomina EQ int_tabla-laufi
                 TO SAP-SPOOL
                 SPOOL PARAMETERS print_parameters
                 ARCHIVE PARAMETERS archi_parameters
                 WITHOUT SPOOL DYNPRO
                 AND RETURN.

  CLEAR v_bankl.

* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*  SELECT SINGLE bankl FROM t012 INTO v_bankl
*    WHERE bukrs EQ bukrs AND hbkid EQ int_tabla-hbkid.
*
* NEW CODE
  SELECT bankl
  UP TO 1 ROWS  FROM t012 INTO v_bankl
    WHERE bukrs EQ bukrs AND hbkid EQ int_tabla-hbkid ORDER BY PRIMARY KEY.

  ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01

  IF v_bankl EQ '027' AND zlsch EQ 'C'.
    CONCATENATE 'C:\TRANSFER\' bukrs '_BCORPBANCA' '_' int_tabla-laufi '_' sy-datum '_' sy-uzeit '.txt'
    INTO v_archivo.
    SET PARAMETER ID: 'SOC' FIELD bukrs,
                      'FEC' FIELD int_tabla-laufd,
                      'NOM' FIELD int_tabla-laufi,
                      'ARC' FIELD v_archivo.
    CALL TRANSACTION 'ZCHEQUESEGURO'.

  ENDIF.

ENDFORM.                    "Imprimir_Listado


*&---------------------------------------------------------------------*
*&      Form  SET_LIST_PRINT_PARAM
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->I_ZBUKR       text
*      -->ES_PRIPARAMS  text
*----------------------------------------------------------------------*
FORM set_list_print_param  USING    i_zbukr      LIKE reguh-zbukr
                           CHANGING es_priparams TYPE pri_params.

  DATA:
    ls_priparams        TYPE pri_params,
    ls_tlsep            TYPE tlsep,
    l_print_mode        TYPE sycallr    VALUE   'CURRENT',
    l_char_unknown      TYPE c          VALUE '_'.

* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*  SELECT SINGLE * FROM  tlsep INTO ls_tlsep
*         WHERE  domai       = 'BUKRS'
*         AND    werte       = i_zbukr.
*
* NEW CODE
  SELECT *
  UP TO 1 ROWS  FROM  tlsep INTO ls_tlsep
         WHERE  domai       = 'BUKRS'
         AND    werte       = i_zbukr ORDER BY PRIMARY KEY.

  ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01

  IF sy-subrc = 0.
    ls_priparams-paart = ls_tlsep-layot.
  ELSE.
    ls_priparams-paart = 'X_65_200'.
  ENDIF.

  IF NOT ls_tlsep IS INITIAL.
*--- company default print parameters
    ls_priparams-paart = ls_tlsep-layot.
    ls_priparams-prnew = ls_tlsep-nllid.
    ls_priparams-prsap = ls_tlsep-cpage.
    IF ls_tlsep-keeps EQ 'X'.
      ls_priparams-prrel = ' '.
    ELSE.
      ls_priparams-prrel = 'X'.
    ENDIF.
  ELSE.
    ls_priparams-paart = 'X_65_200'.
    ls_priparams-prnew = 'X'.
    ls_priparams-prsap = 'D'.
    ls_priparams-prrel = ' '.
  ENDIF.

  ls_priparams-pdest = 'LOCL'.
  ls_priparams-prcop = 1.                 "print one copy
  ls_priparams-ptype = 'TEXT'.
  ls_priparams-armod = 1.                 "print

  IF ls_priparams-pdest IS INITIAL.
    ls_priparams-pdest = l_char_unknown.
  ENDIF.

  CALL FUNCTION 'GET_PRINT_PARAMETERS'
    EXPORTING
      archive_mode           = ls_priparams-armod
      copies                 = ls_priparams-prcop
      destination            = ls_priparams-pdest
      immediately            = ls_priparams-primm
      layout                 = ls_priparams-paart
      list_text              = ls_priparams-prtxt
      mode                   = l_print_mode
      new_list_id            = ls_priparams-prnew
      no_dialog              = 'X'
      release                = ls_priparams-prrel
      sap_cover_page         = ls_priparams-prsap
      type                   = ls_priparams-ptype
    IMPORTING
      out_parameters         = es_priparams
    EXCEPTIONS
      archive_info_not_found = 1
      invalid_print_params   = 2
      invalid_archive_params = 3
      OTHERS                 = 4.

  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.


ENDFORM.                    " set_list_print_param

FORM borrar_firmas  USING    value(firma).
DATA: iname     TYPE stxbitmaps-tdname.

  iname = firma.
  CALL FUNCTION 'SAPSCRIPT_DELETE_GRAPHIC_BDS'
    EXPORTING
      i_object       = 'GRAPHICS'
      i_name         = iname
      i_id           = 'BMAP'
      i_btype        = 'BCOL'
      dialog         = ''
    EXCEPTIONS
      enqueue_failed = 1
      delete_failed  = 2
      not_found      = 3
      canceled       = 4
      OTHERS         = 5.
  IF sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.
ENDFORM.                    " BORRAR_FIRMAS
