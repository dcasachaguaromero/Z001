*&---------------------------------------------------------------------*
*& Report  ZAA_AJUST_INI_AF
*&
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*

REPORT  zaa_ajust_ini_af MESSAGE-ID zfi
                                LINE-SIZE  132
                                LINE-COUNT 65.

FIELD-SYMBOLS <f1>.

TABLES : anla, anlz, anlb ,anlc ,anep ,csks.

TABLES : baltd , baltb.

DATA xanla LIKE TABLE OF anla WITH HEADER LINE.
DATA xanlc LIKE TABLE OF anlc WITH HEADER LINE.


DATA: BEGIN OF kanlc OCCURS 10,
      bukrs LIKE anlc-bukrs,
      anln1 LIKE anlc-anln1,
      anln2 LIKE anlc-anln2,
      gjahr LIKE anlc-gjahr,
      afabe LIKE anlc-afabe,
      zujhr LIKE anlc-zujhr,
      zucod LIKE anlc-zucod,
 END OF kanlc.

DATA: tot_lei(7)  TYPE c,
      tot_baja(7) TYPE c,
      tot_nact(7) TYPE c,
      tot_nexist(7) TYPE c,
      tot_sarmod(7) TYPE c,
      tot_valifrs(7) TYPE c,
      tot_rech(7) TYPE c,
      tot_grab(7) TYPE c,
      tot_rep(7)  TYPE c,
      tot_buenos(8) TYPE c,
      tot_malos(8) TYPE c,
      total_cuadra(8) TYPE c,
      ajinidep(8) TYPE c.
*
DATA: val_neto_lei(16) TYPE c,
      val_neto_nexist(16) TYPE c,
      val_neto_tbaja(16) TYPE c,
      val_neto_sarmod(16) TYPE c,
      val_neto_tbuenos(16) TYPE c,
      val_neto_tmalos(16) TYPE c,
      tot_neto_cuadra(16) TYPE c.
*
DATA : BEGIN OF salida OCCURS 100000,
         linea(7000),
       END OF salida.

* Archivo de Entrada con Titulos
DATA: BEGIN OF archivo OCCURS 100000,
        sociedad(04),   "Sociedad
        anln1(12),      "Activo
        anln2(04),      "Subnumero
        afasl(04),      "Clave Depreciación
        vutres_mes(04), "V.Util Residual en Meses
        j_1aarvkey(04), "Clave Revalorización
        adqar05(16),    "Adquisición Area 05
        depar05(16),    "Dep.Acumulada Area 05
        neto(16),       "Valor Neto
      END OF archivo.
*
DATA: vez(06) TYPE c.

*
DATA: bukrs_bus(04) TYPE n,
      anln1_bus(12) TYPE n,
      anln2_bus(04) TYPE n.

DATA : registro(120) TYPE c.

DATA : vut_act(05) TYPE c,
       vut_trs(05) TYPE c,
       vur_act(05) TYPE c,
       nva_vut(05) TYPE c,
       vut_ndjar(03) TYPE n,
       vut_ndper(02) TYPE n,
       clave_dep LIKE anlb-afasl,
       f_in_dep_n(08) TYPE c,
       f_in_dep_e(08) TYPE c,
       f_in_func(08) TYPE c,
       a_venc LIKE anlc-ndabj,
       p_venc LIKE anlc-ndabp,
       a_dep LIKE anlb-ndjar,
       p_dep LIKE anlb-ndper,
       v_res LIKE anlb-schrw.


DATA: w_kansw LIKE anlc-kansw,
      w_kaufw LIKE anlc-kaufw,
      w_knafa LIKE anlc-knafa,
      w_kaufn LIKE anlc-kaufn,
      w_schrw LIKE anlb-schrw.

DATA: eje_ant    LIKE anlc-gjahr,
      ult_d_agno LIKE anla-aktiv.


SELECTION-SCREEN BEGIN OF BLOCK bl0 WITH FRAME TITLE text-000.
PARAMETERS : p_bukrs LIKE anla-bukrs OBLIGATORY,
             p_afabe1 LIKE t093-afaber OBLIGATORY DEFAULT '05'.
SELECTION-SCREEN END OF BLOCK bl0.
*
SELECTION-SCREEN BEGIN OF BLOCK bl1 WITH FRAME TITLE text-001.
PARAMETERS: p_gjahr LIKE anlc-gjahr OBLIGATORY DEFAULT '2017',
            p_inidep LIKE anlb-afabg  OBLIGATORY,
            p_ultcm LIKE anlb-j_1aaltdat OBLIGATORY.
SELECTION-SCREEN END OF BLOCK bl1.
*
SELECTION-SCREEN BEGIN OF BLOCK bl2 WITH FRAME TITLE text-002.
PARAMETERS : excel TYPE c RADIOBUTTON GROUP 33.
PARAMETERS : p_file LIKE rlgrap-filename DEFAULT 'C:/'.
SELECTION-SCREEN SKIP.
PARAMETERS : servi TYPE c RADIOBUTTON GROUP 33.
PARAMETERS : path1 LIKE rlgrap-filename DEFAULT
             '/usr/sap/<ECD....>/DVEBMGS00/work/AJ_AFIJO.txt'.

SELECTION-SCREEN END OF BLOCK bl2.
*
SELECTION-SCREEN BEGIN OF BLOCK bl3 WITH FRAME TITLE text-003.
PARAMETERS : p_option AS CHECKBOX DEFAULT 'X'.
SELECTION-SCREEN END OF BLOCK bl3.


AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_file.
  CALL FUNCTION 'WS_FILENAME_GET'
    EXPORTING
      def_filename     = ''
      def_path         = 'C:\'
      mask             = ',*.*,*.*.'
      mode             = 'O'
      title            = 'Abrir Archivo de Fuente de Datos'
    IMPORTING
      filename         = p_file
    EXCEPTIONS
      inv_winsys       = 1
      no_batch         = 2
      selection_cancel = 3
      selection_error  = 4
      OTHERS           = 5.

*
START-OF-SELECTION.
*
  IF excel IS INITIAL.
    FREE: archivo.
    CLEAR: archivo.
    PERFORM leer_archivo USING path1.
  ELSE.
    PERFORM leer_planilla TABLES archivo USING p_file 'DAT'.
  ENDIF.
*

  LOOP AT archivo.
*   Archivo con titulos
    IF sy-tabix > 1 AND archivo-sociedad IS NOT INITIAL.

      tot_lei = tot_lei + 1.
      val_neto_lei = val_neto_lei + archivo-neto.

      MOVE archivo-anln1 TO anln1_bus.
      MOVE archivo-anln2 TO anln2_bus.
*
*   UBICA REGISTRO EN ANLA.
      SELECT SINGLE * FROM anla WHERE bukrs = p_bukrs
                                AND   anln1 = anln1_bus
                                AND   anln2 = anln2_bus.
*
      IF sy-subrc EQ 0.
* Verifica que este vigente
        IF anla-deakt IS INITIAL.
*   Verifica que tenga Parametros Dep Area trib.
          SELECT SINGLE * FROM anlb WHERE bukrs = p_bukrs
                                AND   anln1 = anln1_bus
                                AND   anln2 = anln2_bus
                                AND   afabe = p_afabe1
                                AND   bdatu = '99991231'.
          IF sy-subrc NE 0.
            WRITE :/ 'ANLB NO TIENE AREA TRIB.', p_afabe1 ,
             archivo-sociedad, archivo-anln1, archivo-anln2 .
            tot_sarmod = tot_sarmod + 1.
            val_neto_sarmod = val_neto_sarmod + archivo-neto.
          ELSE.
*   Verifica si existe registro ANLC Area Trib a cargar en Ejercicio
            SELECT SINGLE * FROM anlc WHERE bukrs = p_bukrs
                                    AND   anln1 = anln1_bus
                                    AND   anln2 = anln2_bus
                                    AND   gjahr = p_gjahr
                                    AND   afabe = p_afabe1.
            IF sy-subrc NE 0.
              WRITE :/ 'ANLC NO TIENE AREA TRIB.', p_afabe1 , p_gjahr,
                       archivo-sociedad,
                        archivo-anln1, archivo-anln2 .
              tot_sarmod = tot_sarmod + 1.
              val_neto_sarmod = val_neto_sarmod + archivo-neto.
            ELSE.
              tot_buenos = tot_buenos + 1.
              val_neto_tbuenos = val_neto_tbuenos + archivo-neto.
              PERFORM ajusta.
            ENDIF.
          ENDIF.
        ELSE. "No vigente
          WRITE :/ 'ACTIVO C/BAJA' , archivo-sociedad, archivo-anln1,
          archivo-anln2 .
          tot_baja = tot_baja + 1.
          val_neto_tbaja = val_neto_tbaja + archivo-neto.
        ENDIF.
      ELSE. "No existe
        WRITE :/ 'ACTIVO N/E' , archivo-sociedad, archivo-anln1,
        archivo-anln2 .
        tot_nexist = tot_nexist + 1.
        val_neto_nexist = val_neto_nexist + archivo-neto.
      ENDIF.
    ENDIF.
  ENDLOOP.
*
* Genera Archivo de Error.

*

  WRITE:/.
  WRITE:/.
  WRITE:/ 'RESUMEN DE VALIDACIÓN CARGA '.
  WRITE:/ '============================'.
  WRITE:/.
  WRITE:/.
  WRITE:/.
  WRITE:/ 'TOTAL LEIDOS          :' , tot_lei , val_neto_lei .
  WRITE:/.
  WRITE:/ 'TOTAL SIN AR TRIBUT.  :' , tot_sarmod, val_neto_sarmod.
  WRITE:/ 'TOTAL ACT. NO EXISTE  :' , tot_nexist, val_neto_nexist.
  WRITE:/ 'TOTAL ACT. C/BAJA     :' , tot_baja  , val_neto_tbaja.

*
  tot_malos = tot_sarmod + tot_nexist + tot_baja.
  val_neto_tmalos = val_neto_sarmod + val_neto_nexist + val_neto_tbaja.

*
  WRITE:/.
  WRITE:/ 'TOTAL MALOS        :' , tot_malos, val_neto_tmalos.
  WRITE:/ 'TOTAL BUENOS       :' , tot_buenos, val_neto_tbuenos.
*
  total_cuadra = tot_malos + tot_buenos.
*
  tot_neto_cuadra = val_neto_tmalos + val_neto_tbuenos.
*
  WRITE:/ 'TOTAL CUADRATURA   :' , total_cuadra, tot_neto_cuadra.
  WRITE:/.
  WRITE:/ 'PROCESO FINALIZADO' .


END-OF-SELECTION.


*---------------------------------------------------------------------*
*  Genera Archivo Plano
*---------------------------------------------------------------------*
*  -->  NOM_TAB   tabla interna
*  -->  NOM_ARCH  Ruta de acceso archivo a generar
*  -->  NOM_Tipo  Tipo de archivo para funcion Download
*---------------------------------------------------------------------*
FORM guardar_planilla TABLES nom_tab USING nom_arch nom_tip.
  STATICS contar_download.

* Variables Locales
  DATA : narch LIKE rlgrap-filename,
         ntipo LIKE rlgrap-filetype.
* Asignacion de variables
  narch = nom_arch.
  ntipo = nom_tip(3).

  IF narch(1) = '/'.

    IF nom_tip = 'BIN'.
      OPEN DATASET nom_arch FOR OUTPUT IN BINARY MODE.
    ELSE.
      OPEN DATASET nom_arch FOR OUTPUT IN TEXT MODE ENCODING DEFAULT.
    ENDIF.

    IF sy-subrc = 0.
      LOOP AT nom_tab.
        TRANSFER nom_tab TO nom_arch.
        IF sy-subrc NE 0. EXIT.ENDIF.
      ENDLOOP.
    ELSE.
      MESSAGE i006(zbc) WITH nom_arch.
      STOP.
    ENDIF.
  ELSE.
    IF narch IS INITIAL.
      IF contar_download IS INITIAL.
        contar_download = 'X'.
        CALL FUNCTION 'DOWNLOAD'
          EXPORTING
            filename = narch
            filetype = ntipo
          TABLES
            data_tab = nom_tab
          EXCEPTIONS
            OTHERS   = 9.
      ELSE.
        MESSAGE i007(zbc).
        STOP.
      ENDIF.
    ELSE.
      CALL FUNCTION 'WS_DOWNLOAD'
        EXPORTING
          filename = narch
          filetype = ntipo
        TABLES
          data_tab = nom_tab
        EXCEPTIONS
          OTHERS   = 9.
    ENDIF.

    IF sy-subrc NE 0.
      MESSAGE i008(zbc).
      STOP.
    ENDIF.
  ENDIF.
ENDFORM.                    "GUARDAR_PLANILLA
*&---------------------------------------------------------------------*
*&      Form  SELECCIONA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM ajusta.
*
  vez = vez + 1.

  IF vez > 10000.
    COMMIT WORK AND WAIT.
    vez = 1.
  ENDIF.

*  AJUSTE DIRECTO A TABLAS
*
* Busca parametros de depreciación de area 01
  SELECT SINGLE * FROM anlb WHERE bukrs = p_bukrs
                        AND   anln1 = anln1_bus
                        AND   anln2 = anln2_bus
                        AND   afabe = '01'
                        AND   bdatu = '99991231'.
* Fecha de Inicio Funcionamiento es Igual
  MOVE anlb-inbda TO f_in_func.

* Ubico registro ANLB Area tributaria a cargar.
  SELECT SINGLE * FROM anlb WHERE bukrs = p_bukrs
                        AND   anln1 = anln1_bus
                        AND   anln2 = anln2_bus
                        AND   afabe = p_afabe1
                        AND   bdatu = '99991231'.

*  Clave Dep de archivo Transfiere
  MOVE archivo-afasl  TO clave_dep.

* Pasa Vida Util de Archivo
* ESTA RUTINA CALCULA VIDA UTIL AÑOS Y PERIDOS,
* SEGUN LA VIDA RESIDUAL ENTREGADA EN MESES
  nva_vut = archivo-vutres_mes.
  vut_ndjar = nva_vut DIV 12.
  vut_ndper = ( ( nva_vut / 12 ) - vut_ndjar ) * 12.
  MOVE vut_ndjar TO a_dep.
  MOVE vut_ndper TO p_dep.


* Si Vut cero y Clave dep <> 0000, asume VUT = 1 mes
  IF clave_dep NE '0000'.
    IF a_dep IS INITIAL AND
       p_dep IS INITIAL.
      p_dep = 1.
    ENDIF.
  ENDIF.

* Pasa Inicio Depreciación
  MOVE p_inidep TO f_in_dep_n.

* Pasa Parametros a Area Trib.
  MOVE clave_dep TO anlb-afasl.
  MOVE a_dep TO anlb-ndjar.
  MOVE p_dep TO anlb-ndper.
  MOVE f_in_dep_n TO anlb-afabg.
  MOVE f_in_func  TO anlb-inbda. "Igual que Area 01

** Se notifica CLAVE DE REVALORIZACIÓN de Archivo
  MOVE archivo-j_1aarvkey TO anlb-j_1aarvkey.
*
* Fecha Ultimo Proceso CM
  MOVE p_ultcm TO anlb-j_1aaltdat.
*
  IF p_option IS INITIAL.
    MODIFY anlb.
  ENDIF.

  FREE : kanlc , xanlc.
* Ubico registro ANLC Area Trib a cargar y cargo llave
  SELECT * FROM anlc
     APPENDING CORRESPONDING FIELDS OF TABLE kanlc
                              WHERE bukrs = p_bukrs
                              AND   anln1 = anln1_bus
                              AND   anln2 = anln2_bus
                              AND   gjahr = p_gjahr
                              AND   afabe = p_afabe1.

* Paso llave a tabla XANLC
  READ TABLE kanlc INDEX 1.
  MOVE-CORRESPONDING kanlc TO xanlc.

* Asigna Valores segun Valores de Archivo.
  IF NOT archivo-adqar05 IS INITIAL.
    w_kansw = archivo-adqar05 / 100 .
    MOVE w_kansw   TO xanlc-kansw.
  ENDIF.
  IF NOT archivo-depar05 IS INITIAL.
    w_knafa = archivo-depar05 / 100 .
    MOVE w_knafa  TO xanlc-knafa.
  ENDIF.

  APPEND xanlc.

  IF p_option IS INITIAL.
    MODIFY anlc FROM xanlc.
  ENDIF.
*
ENDFORM.                    " AJUSTA
*&---------------------------------------------------------------------*
*&      Form  LEER_ARCHIVO
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_PATH1  text
*----------------------------------------------------------------------*
FORM leer_archivo  USING    file.
  CLEAR registro.
  OPEN DATASET file FOR INPUT IN TEXT MODE ENCODING DEFAULT.
*                                     WITH WINDOWS LINEFEED.

  DO.
    READ DATASET file INTO registro.
    IF sy-subrc <> 0.
      EXIT.
    ELSE.
      SPLIT registro AT ';'  INTO
              archivo-sociedad
              archivo-anln1
              archivo-anln2
              archivo-afasl
              archivo-vutres_mes
              archivo-j_1aarvkey
              archivo-adqar05
              archivo-depar05
              archivo-neto.
      APPEND archivo.
    ENDIF.
  ENDDO.
  CLOSE DATASET file.
ENDFORM.                    " LEER_ARCHIVO
*&---------------------------------------------------------------------*
*&      Form  LEER_PLANILLA
*&---------------------------------------------------------------------*
FORM leer_planilla TABLES nom_tab
                   USING  nom_arch nom_tip.
* VARIABLES leer planilla
  DATA : fr LIKE rlgrap-filename,
         tipo  LIKE rlgrap-filetype.
* Asignacion de variables
  fr   = nom_arch.
  tipo = nom_tip(3).

  CALL FUNCTION 'WS_UPLOAD'
    EXPORTING
      filename = fr
      filetype = tipo
    TABLES
      data_tab = nom_tab
    EXCEPTIONS
      OTHERS   = 9.
*
ENDFORM.                    " leer_planilla
