*&---------------------------------------------------------------------*
*& Report  ZIMP_CHEQUE
*&
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*

REPORT  zimp_cheque.
TABLES : zfirmadigital, zfipg003.
DATA: ti_firma TYPE STANDARD TABLE OF zfirmadigital WITH HEADER LINE,
      firma1 TYPE zfirmadigital,
      firma2 TYPE zfirmadigital,
      okcode TYPE sy-ucomm,
      pasword1 TYPE char50,
      pasword2 TYPE char50,
      estado1(10) TYPE c,
      estado2(10) TYPE c,
      source TYPE char50,
      destination TYPE char50,
      pwd TYPE char50,
      tdname_001 TYPE bdcdata-fval,
      filename_004 TYPE bdcdata-fval,
      tdname_005 TYPE bdcdata-fval,
      tdname_008 TYPE bdcdata-fval,
      messtab TYPE STANDARD TABLE OF bdcmsgcoll WITH HEADER LINE,
      rfcdest TYPE rfcdes-rfcdest.

"ar ini
data: v_clave type zclav,
        l_encoded type string,
        l_decoded type string,
        v_firma  type tdobname,
        file_p like sapb-sappfad,
        file_d like sapb-sappfad.

data: dir_des1 TYPE rlgrap-filename VALUE 'C:\Firmas\Ai_D.bmp',
      dir_des2 TYPE rlgrap-filename VALUE 'C:\Firmas\Ai_D2.bmp'.
"ar fin

DATA: iname     TYPE stxbitmaps-tdname.

SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE text-001.
PARAMETERS: bukrs TYPE zfirmadigital-bukrs.
SELECTION-SCREEN BEGIN OF BLOCK b2 WITH FRAME TITLE text-002.
PARAMETERS: nfirma1(70) TYPE c,
            dir_org1 TYPE rlgrap-filename,
*            dir_des1 TYPE rlgrap-filename,  "ar01
            pass1(25)  TYPE c. " OBLIGATORY.
SELECTION-SCREEN END OF BLOCK b2.
SELECTION-SCREEN BEGIN OF BLOCK b3 WITH FRAME TITLE text-003.
PARAMETERS: nfirma2(70) TYPE c,
            dir_org2 TYPE rlgrap-filename,
*            dir_des2 TYPE rlgrap-filename,    "ar01
            pass2(25)  TYPE c. " OBLIGATORY.
SELECTION-SCREEN END OF BLOCK b3.
PARAMETERS: p_op1 TYPE c RADIOBUTTON GROUP g1,
            p_op2 TYPE c RADIOBUTTON GROUP g1.
SELECTION-SCREEN END OF BLOCK b1.

AT SELECTION-SCREEN ON bukrs.
  SELECT SINGLE * FROM zfipg003 INTO zfipg003 WHERE bukrs EQ bukrs.
  IF sy-subrc <> 0.
    MESSAGE 'No existe la sociedad en la tabla de firmas' TYPE 'W'.
  ELSE.
    nfirma1 = zfipg003-nfirma1.
    dir_org1 = zfipg003-dir_org1.
*    dir_des1 = zfipg003-dir_des1.   "ar01
    nfirma2 = zfipg003-nfirma2.
    dir_org2 = zfipg003-dir_org2.
*    dir_des2 = zfipg003-dir_des2.   "ar01
  ENDIF.



AT SELECTION-SCREEN OUTPUT.
  LOOP AT SCREEN.
    IF screen-name EQ 'PASS1'.
      screen-invisible = '1'.
      MODIFY SCREEN.
    ENDIF.
    IF screen-name EQ 'PASS2'.
      screen-invisible = '1'.
      MODIFY SCREEN.
    ENDIF.
    IF screen-name EQ 'NFIRMA1'  OR
       screen-name EQ 'NFIRMA2'  OR
       screen-name EQ 'DIR_ORG1' OR
       screen-name EQ 'DIR_ORG2' OR
       screen-name EQ 'DIR_DES1' OR
       screen-name EQ 'DIR_DES2'.
      screen-input = 'O'.
      screen-active = 'O'.
      MODIFY SCREEN.
    ENDIF.
  ENDLOOP.

END-OF-SELECTION.

  PERFORM borrar_firmas USING nfirma1.
  PERFORM borrar_firmas USING nfirma2.


START-OF-SELECTION.
"" AR INI ********************************
*Desencripta la firma y la compara con el parmetro ingresado en la dynpro.
  select single clave from zfirma_digital into v_clave
"                   where bukrs eq soc_pago and
                    where bukrs eq bukrs and
                         ruta_sap eq dir_org1.
  if sy-subrc = 0.
*Desencriptar la firma.
    l_encoded = v_clave.
    call method cl_http_utility=>if_http_utility~decode_base64 "Method for Decryption
    exporting
    encoded = l_encoded
    receiving
    decoded = l_decoded.
*Comparamos la firma con la firma ingresada.
    if l_decoded = pass1.
      file_p = 'C:\Firmas\Ai_D.bmp'.
      file_d = dir_org1.
*Comparamos la firma con la firma ingresada.
    if l_decoded = pass1.
      file_p = 'C:\Firmas\Ai_D.bmp'.
      file_d = dir_org1.
*Buscar archivo en el servidor   de sap y lo descarga en C:\Firmas\Ai_D.bmp
      call function 'ARCHIVFILE_SERVER_TO_CLIENT'
        exporting
          path       = file_d
          targetpath = file_p
        exceptions
          error_file = 1
          others     = 2.
      if sy-subrc <> 0.
                message id sy-msgid type sy-msgty number sy-msgno
                with sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
      endif.
      if sy-subrc = 0.

*Busca el nombre del la imagen a cargar en la se78.
        select single nfirma1 from zfipg003
          into nfirma1
           where bukrs    = bukrs and
                 dir_org1 = dir_org1.
        perform borrar_firmas using nfirma1."Borra firma previo a su carga
        tdname_001   = nfirma1.
        filename_004 = file_p.
        tdname_005 = nfirma1.
        tdname_008 = nfirma1.
        destination = filename_004.
*Cargar imagen en sap
        call function 'ZSUBEFIRMA'
          exporting
            tdname_001     = tdname_001
            filename_004   = filename_004
            tdname_005     = tdname_005
            autoheight_007 = ''
            tdname_008     = tdname_008
          tables
            messtab        = messtab.
        loop at messtab.
          if messtab-msgtyp eq 'E'.
            call function 'Z_DEL_FIRMA'
              exporting
                destination = destination.

            message 'No se puede desencriptar firma 1' type 'W' display like 'E'..
          endif.
        endloop.
        call function 'Z_DEL_FIRMA'
          exporting
            destination = destination.
      endif.
    else.
      message  'Contraseña firma 1 incorrecta' type 'W' display like 'E'.
    endif.
  else.
    message 'Directorio de entrada no existe en directorio SAP' type 'W' display like 'E'.
  endif.
  clear messtab.
  refresh messtab.
********************************************************************
*Firma 2 ***********************************************************
*Desencripta la firma y la compara con el parmetro ingresado en la dynpro.
  select single clave from zfirma_digital into v_clave
                   where bukrs eq bukrs and
                         ruta_sap eq dir_org2.
  if sy-subrc = 0.
*Desencriptar la firma.
    l_encoded = v_clave.
    call method cl_http_utility=>if_http_utility~decode_base64 "Method for Decryption
    exporting
    encoded = l_encoded
    receiving
    decoded = l_decoded.
*    IF sy-subrc = 0.
*Comparamos la firma con la firma ingresada.
    if l_decoded = pass2.
      file_p = 'C:\Firmas\Ai_D2.bmp'.
      file_d = dir_org2.
*Buscar archivo en el servidor   de sap y lo descarga en C:\Firmas\Ai_D.bmp
      call function 'ARCHIVFILE_SERVER_TO_CLIENT'
        exporting
          path       = file_d
          targetpath = file_p
        exceptions
          error_file = 1
          others     = 2.
      if sy-subrc <> 0.
        message id sy-msgid type sy-msgty number sy-msgno
                with sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
      endif.
      if sy-subrc = 0.

*Busca el nombre del la imagen a cargar en la se78.
        select single nfirma2 from zfipg003
          into nfirma2
           where bukrs    = bukrs and
                 dir_org1 = dir_org2.
        perform borrar_firmas using nfirma2."Borra firma previo a su carga
        tdname_001   = nfirma2.
        filename_004 = file_p.
        tdname_005 = nfirma2.
        tdname_008 = nfirma2.
        destination = filename_004.
        call function 'ZSUBEFIRMA'
          exporting
            tdname_001     = tdname_001
            filename_004   = filename_004
            tdname_005     = tdname_005
            autoheight_007 = ''
            tdname_008     = tdname_008
          tables
            messtab        = messtab.
        loop at messtab.
          if messtab-msgtyp eq 'E'.
            call function 'Z_DEL_FIRMA'
              exporting
                destination = destination.

            message 'No se puede desencriptar firma 1' type 'W' display like 'E'.
          endif.
        endloop.

        call function 'Z_DEL_FIRMA'
          exporting
            destination = destination.
      endif.
    else.
      message  'Contraseña firma 2 incorrecta' type 'W' display like 'E'.
    endif.
    else.
    message 'Directorio de entrada no existe en directorio SAP' type 'W' display like 'E'.
  endif.
  clear messtab.
  refresh messtab.
  endif.

"" AR FIN ********************************

*  SELECT SINGLE * FROM zfirmadigital WHERE bukrs EQ bukrs.   "ori inicio **************
  IF sy-subrc EQ 0.
*    rfcdest = zfirmadigital-rfcdest.
*    source = dir_org1.
*    destination = dir_des1.   "ar01
*    pwd = pass1.
*    CALL FUNCTION 'S_DES_FIRMA'
*      EXPORTING
*        SOURCE      = SOURCE
*        destination = destination
*        pwd         = pwd
*        rfcdest     = rfcdest.
*    IF sy-subrc EQ 0.
*      PERFORM borrar_firmas USING nfirma1."Borra firma previo a su carga
*      tdname_001 = nfirma1.
*      filename_004 = dir_des1. "ar01
*      tdname_005 = nfirma1.
*      tdname_008 = nfirma1.
*      CALL FUNCTION 'ZSUBEFIRMA'
*       EXPORTING
**     CTU                       = 'X'
**     MODE                      = 'N'
**     UPDATE                    = 'L'
**     GROUP                     =
**     USER                      =
**     KEEP                      =
**     HOLDDATE                  =
**     NODATA                    = '/'
*         tdname_001                = tdname_001
**     BTYPE_BMON_002            = ''
**     BTYPE_BCOL_003            = 'X'
*         filename_004              = filename_004
*         tdname_005                = tdname_005
**     RB_GRAPHIC_BCOL_006       = 'X'
*         autoheight_007            = ''
*         tdname_008                = tdname_008
**     BTYPE_BCOL_009            = 'X'
**   IMPORTING
**     SUBRC                     =
*       TABLES
*         messtab                   = messtab
*                .
*      LOOP AT messtab.
*        IF messtab-msgtyp EQ 'E'.
*          CALL FUNCTION 'Z_DEL_FIRMA'
*            EXPORTING
*              destination       = destination
**         IMPORTING
**           RESP              =
*                    .
*
*          MESSAGE 'No se puede desencriptar firma 1' TYPE 'E'.
*        ENDIF.
*      ENDLOOP.
*      CALL FUNCTION 'Z_DEL_FIRMA'
*            EXPORTING
*              destination       = destination
**         IMPORTING
**           RESP              =
*                    .
*    ENDIF.
**************************
*****Firma2***************
*    rfcdest = zfirmadigital-rfcdest.
*   source = dir_org2.
*    destination = dir_des2.   "ar01
*    pwd = pass2.
*    CALL FUNCTION 'S_DES_FIRMA'
*      EXPORTING
*        SOURCE      = SOURCE
*        destination = destination
*        pwd         = pwd
*        rfcdest     = rfcdest.
*    IF sy-subrc EQ 0.
*      PERFORM borrar_firmas USING nfirma2."Borra firma previo a su carga
*      tdname_001 = nfirma2.
*      filename_004 = dir_des2.   "ar01
*      tdname_005 = nfirma2.
*      tdname_008 = nfirma2.
*      CALL FUNCTION 'ZSUBEFIRMA'
*       EXPORTING
**     CTU                       = 'X'
**     MODE                      = 'N'
**     UPDATE                    = 'L'
**     GROUP                     =
**     USER                      =
**     KEEP                      =
**     HOLDDATE                  =
**     NODATA                    = '/'
*         tdname_001                = tdname_001
**     BTYPE_BMON_002            = ''
**     BTYPE_BCOL_003            = 'X'
*         filename_004              = filename_004
*         tdname_005                = tdname_005
**     RB_GRAPHIC_BCOL_006       = 'X'
*         autoheight_007            = ''
*         tdname_008                = tdname_008
**     BTYPE_BCOL_009            = 'X'
**   IMPORTING
**     SUBRC                     =
*       TABLES
*         messtab                   = messtab
*                .
*      LOOP AT messtab.
*        IF messtab-msgtyp EQ 'E'.
*          CALL FUNCTION 'Z_DEL_FIRMA'
*            EXPORTING
*              destination       = destination
**         IMPORTING
**           RESP              =
*                    .
*
*          MESSAGE 'No se puede desencriptar firma 2' TYPE 'E'.
*        ENDIF.
*      ENDLOOP.
*      CALL FUNCTION 'Z_DEL_FIRMA'
*            EXPORTING
*              destination       = destination
**         IMPORTING
**           RESP              =
*                    .
*    ENDIF.                                   "ori fin  **************


*LLAMA A TRANSACCION**************************
    IF p_op1 EQ 'X'.
      CALL TRANSACTION 'F-58'.
    ELSE.
      CALL TRANSACTION 'F110'.
    ENDIF.
**********************************************

  ENDIF.
**********************************************
  INCLUDE zimp_cheque_f01.
