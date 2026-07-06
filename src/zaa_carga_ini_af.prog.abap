*----------------------------------------------------------------------*
* Tipo Objeto   : Reporte                                              *
* Programa      : Proceso de Carga Inicial de datos de Activos Fijos   *
*                                                                      *
* Proyecto      : Carga Inicial AF.                                    *
* Fecha         : 30-04-2017                                           *
* Empresa       : Visionone                                            *
* Funcionales   : Pablo Gilbert                                        *
* Desarrollador : Pablo Gilbert                                        *
*                                                                      *
* Descripción general del proceso:                                     *
*  Proceso de Carga Inicial de datos de Activos Fijos con BADI        *
*                                                                      *
*----------------------------------------------------------------------*
* Modificaciones:                                                      *
*                                                                      *
* Fecha        Autor                   Descripción                     *
* dd.mm.aaaa   xxxxxxxxx xxxxxxxxx     xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx *
*----------------------------------------------------------------------*
*
REPORT  zaa_carga_ini_af NO STANDARD PAGE HEADING
                         LINE-SIZE 255
                         LINE-COUNT 65
                         MESSAGE-ID mm.

***************************************************************
*                      DECLARACIONES                          *
***************************************************************
TABLES : baltd,
         baltb,
         anep ,
         anlc ,
         anlv , t093c.
*
* Tabla Interna para aceptar archivo Plano BALTD
DATA : BEGIN OF gt_tabla1 OCCURS 100,
***
* Datos Maestros
**
           bukrs(04),    "Sociedad
           anlkl(08),    "Clase de activos fijos
           anln1(12),    "Activo
           anln2(04),    "Subnumero
           aktiv(10),    "Fecha de capitalización del activo fijo
           menge(17),    "Cantidad
           meins(03),    "Unidad de medida de Cantidad
           oldn1(12),    "Act.Antiguo Dato Control
           oldn2(04),    "Sub-Nro. Antig D.Control
           bwcnt(04),    "Numero Mov. Ej.carga
           txt50(50),    "Denominación del activo fijo
           txa50(50),    "Denominación 2
           anlhtxt(50),  "Denominación 3
           sernr(18),    "Número de serie
           invnr(25),    "Número de inventario
           ivdat(10),    "Fecha del Último inventario
           kostl(10),    "Centro de coste
*           werks(04),    "Centro
           kfzkz(15),    "Matrícula de vehículo
           lifnr(10),    "Número de cuenta del proveedor o acreedor
           liefe(30),    "Nombre del acreedor del activo fijo
           ord41(04),    "Clasif. 1 : Torre
           ord42(04),    "Clasif. 2 : Zona
           ord43(04),    "Clasif. 3 : Niveles
           ord44(04),    "Clasif. 4 : Leasing
           urwrt(16),    "Valor original
**
*  valores del Area 01 Área financiera IFRS
**
           afabe01(02),    "Area
           afasl01(04),    "Cl.Dep
           ndjar01(03),    "Vida Util Años
           ndper01(03),    "Vida Util Meses
           afabg01(10),    "Fecha Inicio Dep
           kansw01(16),    "Valor Adq.
           knafa01(16),    "Dep. Acum.
           nafag01(16),    "Dep.Contab.Ejercicio a Fech.Carga
**
*  Valores del Area 05 Área fiscal.
**
           afabe02(02),    "Area
           afasl02(04),    "Cl.Dep
           ndjar02(03),    "Vida Util Años
           ndper02(03),    "Vida Util Meses
           afabg02(10),    "Fecha Inicio Dep
           kansw02(16),    "Valor Adq.
           knafa02(16),    "Dep. Acum.
           kaufw02(16),    "Cm.Adq. , Apertura
           kaufn02(16),    "Cm.Dep. , Apertura
           aufwb02(16),    "Cm.Adq., contabilizada Ej.Carga
           aufng02(16),    "Cm.Dep., contabilizada Ej.Carga
           nafag02(16),    "Dep.Contab.Ejercicio a Fech.Carga
**
*  Valores del Area 10 Área GAAP Chile.
**
           afabe03(02),    "Area
           afasl03(04),    "Cl.Dep
           ndjar03(03),    "Vida Util Años
           ndper03(03),    "Vida Util Meses
           afabg03(10),    "Fecha Inicio Dep
           kansw03(16),    "Valor Adq.
           knafa03(16),    "Dep. Acum.
           nafag03(16),    "Dep.Contab.Ejercicio a Fech.Carga
**
*  Valores del Area 20 Área Super S.
**
           afabe04(02),    "Area
           afasl04(04),    "Cl.Dep
           ndjar04(03),    "Vida Util Años
           ndper04(03),    "Vida Util Meses
           afabg04(10),    "Fecha Inicio Dep
           kansw04(16),    "Valor Adq.
           knafa04(16),    "Dep. Acum.
           nafag04(16),    "Dep.Contab.Ejercicio a Fech.Carga
**
*  valores del Area Moneda Grupo (CLP)
**
           afabe05(02),    "Area
           afasl05(04),    "Cl.Dep
           ndjar05(03),    "Vida Util Años
           ndper05(03),    "Vida Util Meses
           afabg05(10),    "Fecha Inicio Dep
           kansw05(16),    "Valor Adq.
           knafa05(16),    "Dep. Acum.
           nafag05(16),    "Dep.Contab.Ejercicio a Fech.Carga
**
*  valores del Area ME (USD)
**
           afabe06(02),    "Area
           afasl06(04),    "Cl.Dep
           ndjar06(03),    "Vida Util Años
           ndper06(03),    "Vida Util Meses
           afabg06(10),    "Fecha Inicio Dep
           kansw06(16),    "Valor Adq.
           knafa06(16),    "Dep. Acum.
           nafag06(16),    "Dep.Contab.Ejercicio a Fech.Carga

       END OF gt_tabla1.

* Tabla Interna para aceptar archivo Plano Movimientos
DATA : BEGIN OF gt_tabla2 OCCURS 10,
           bukrs(04),    "Sociedad
           anlkl(08),    "Clase de activos fijos
           oldn1(12),    "Act.Antiguo D. Control
           oldn2(04),    "Sub-Nro. Antig D. Control
           bwasl(03),    "Clase de movimiento activos fijos
           bzdat(10),    "Fecha de referencia
*
           anbtr01(15), "Valor Mov. Área Financiera IFRS
           nafal01(15), "Dep.en Baja de Ej Actual Área Financiera IFRS
           nafav01(15), "Dep.en Baja de Ejer Ant Área Financiera IFRS
*
           anbtr02(15), "Valor Mov. Área Fiscal
           nafal02(15), "Dep.en Baja de Ejercicio Actual Ar.Fiscal
           nafav02(15), "Dep.en Baja de Ejercicios Anteriores A.Fiscal
           aufwl02(15), "Cm.de Ej.Anterior en Baja
           aufwv02(15), "Cm.del Ejercicio en Baja
*
           anbtr03(15), "Valor Mov. GAAP Chile
           nafal03(15), "Dep.en Baja de Ejercicio Actual GAAP Chile
           nafav03(15), "Dep.en Baja de Ejercs. Anteriores GAAP Chile
*
           anbtr04(15), "Valor Mov. Área Super S.
           nafal04(15), "Dep.en Baja de Ej. Actual Cont. Área Super S.
           nafav04(15), "Dep.en Baja de Ej. Ant. Cont. Área Super S.
*
           anbtr05(15), "Valor Mov. Contable Moneda Grupo (CLP)
           nafal05(15), "Dep.en Baja de Ejer. Actual Cont. Mon.Grupo
           nafav05(15), "Dep.en Baja de Ej. Ant. Cont. Mon.Grupo
*
           anbtr06(15), "Valor Mov. Contable Moneda Extr.(USD)
           nafal06(15), "Dep.en Baja de Ejercicio Actual Cont. Mon.Ext
           nafav06(15), "Dep.en Baja de Ej. Ant. Cont. Mon.Ext.
*
       END OF gt_tabla2.

DATA : BEGIN OF gt_a_salida OCCURS 20,
         linea(7000),
       END OF gt_a_salida.

* Tabla Interna para ALMACENAR los ERRORES
DATA : BEGIN OF errores OCCURS 10,
        bukrs(04)  TYPE c,
        anlkl(08)  TYPE c,
        oldn1(12)  TYPE c,
        oldn2(04)  TYPE c,
       END OF errores.
*
DATA : gd_return  LIKE  bapiret2.
*
*******************************************************
* Tablas para usar en BADI
*******************************************************
*       Datos Maestros y Valores Acumulados
DATA : BEGIN OF gt_a_baltd OCCURS 10.
        INCLUDE STRUCTURE baltd.
DATA : END OF gt_a_baltd.
*
*      Datos de Movimientos
DATA : BEGIN OF gt_a_baltb OCCURS 10.
        INCLUDE STRUCTURE baltb.
*  Campos de Arch.Mov.que no estan en BALTB
DATA :  nafal01(15),  "Dep.en Baja de Ej. Act Área Financiera IFRS
        nafav01(15),  "Dep.en Baja de Ej. Ant Área Financiera IFRS
*
        nafal02(15),  "Dep.en Baja de Ejercicio Área Fiscal
        nafav02(15),  "Dep.en Baja de Ejercicios Ant. Área Fiscal
        aufwl02(15),  "Cm.de Ej.Anterior en Baja
        aufwv02(15),  "Cm.del Ejercicio en Baja
*
        nafal03(15),  "Dep.en Baja de Ejercicio Área GAAP Chile
        nafav03(15),  "Dep.en Baja de Ejercicios Ant. Ár. GAAP Chile
*
        nafal04(15),  "Dep.en Baja de Ejercicio Actual Área Super S.
        nafav04(15),  "Dep.en Baja de Ejercicios Ant. Área Super S.
*
        nafal05(15),  "Dep.en Baja de Ej. Actual Ár. Mon Grupo (CLP)
        nafav05(15),  "Dep.en Baja de Ejers Ant. Ár. Mon Grupo (CLP)
*
        nafal06(15),  "Dep.en Baja de Ej. Actual Ár. Mon Ext.(USD)
        nafav06(15).  "Dep.en Baja de Ejers. Ant. Ár. Mon. Ext.(USD)
*
DATA : END OF gt_a_baltb.
************************************************************************
************************************************************************
* Variables de Trabajo

DATA : ej_car(04) TYPE c,
      f_carga TYPE t093c-datum,
      f_car_e(10) TYPE c,
      ord(12) TYPE n,
      anln1(12) TYPE n,
      anln2(04) TYPE n,
      err_ord(01) TYPE c.

FIELD-SYMBOLS <f1>.
******************************************************
*        FIN DECLARACIONES                           *
******************************************************
SELECTION-SCREEN BEGIN OF BLOCK z5 WITH FRAME TITLE text-000.
SELECTION-SCREEN BEGIN OF BLOCK z1 WITH FRAME TITLE text-002.


PARAMETERS : pa_bukrs  LIKE t001-bukrs OBLIGATORY,
             p_gjahr   LIKE anlc-gjahr OBLIGATORY DEFAULT '2018'.
SELECTION-SCREEN SKIP 1.

PARAMETERS : p_apert TYPE c RADIOBUTTON GROUP 66 DEFAULT 'X',
             p_inter TYPE c RADIOBUTTON GROUP 66 ." MODIF ID bl2.
SELECTION-SCREEN SKIP 1.

* Archivo Entrada Mastro
PARAMETERS : pa_path1 LIKE rlgrap-filename DEFAULT
                        'C:\BALTD.txt' OBLIGATORY LOWER CASE.

* Archivo Entrada Movimientos
PARAMETERS : pa_path2 LIKE rlgrap-filename DEFAULT
                        'C:\BALTB.txt' OBLIGATORY LOWER CASE.
SELECTION-SCREEN SKIP 1.
PARAMETERS : pa_test AS CHECKBOX DEFAULT 'X'.
SELECTION-SCREEN END OF BLOCK z1.
*
SELECTION-SCREEN BEGIN OF BLOCK z2
                 WITH FRAME TITLE text-003.

* Trayectoria Bajada a SAP
PARAMETERS : path_f  LIKE rlgrap-filename DEFAULT
             '/usr/sap/<ECD....>/DVEBMGS00/work/carga_AF.txt'
             OBLIGATORY LOWER CASE.

SELECTION-SCREEN END OF BLOCK z2.
SELECTION-SCREEN END OF BLOCK z5.

*AT SELECTION-SCREEN OUTPUT.
*  LOOP AT SCREEN.
*    IF screen-group1 = 'BL2'.
*      screen-active = '0'.
*    ENDIF.
*    MODIFY SCREEN.
*  ENDLOOP.


AT SELECTION-SCREEN ON pa_bukrs.
*
  AUTHORITY-CHECK OBJECT 'F_BKPF_BUK'
      ID 'BUKRS' FIELD pa_bukrs
      ID 'ACTVT' FIELD '03'.
  IF sy-subrc NE 0.
    MESSAGE e899(mm)
        WITH 'No posee autorización para Sociedad'
             pa_bukrs .
  ENDIF.

*AT SELECTION-SCREEN ON p_apert.
AT SELECTION-SCREEN ON RADIOBUTTON GROUP 66.
*
  SELECT SINGLE * FROM t093c WHERE bukrs = pa_bukrs.
  WRITE t093c-datum TO f_car_e.
  IF NOT p_apert IS INITIAL.
    ej_car = p_gjahr - 1.
    CONCATENATE ej_car '12' '31' INTO f_carga.
    IF f_carga NE t093c-datum.
      MESSAGE e899(mm)
          WITH 'Ejercicio de Carga' p_gjahr
           'NO Consistente con fecha de Carga Inicial AF.' f_car_e.
    ENDIF.
  ELSE.
    ej_car = t093c-datum(04).
    IF ej_car NE p_gjahr.
      MESSAGE e899(mm)
          WITH 'Ejercicio de Carga' p_gjahr
           'NO Consistente con fecha de Carga Inicial AF.' f_car_e.
    ENDIF.

  ENDIF.

*
AT SELECTION-SCREEN ON VALUE-REQUEST FOR pa_path1.
  PERFORM value_req_file USING pa_path1.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR pa_path2.
  PERFORM value_req_file USING pa_path2.


START-OF-SELECTION.

* Carga Archivo plano en tabla Interna GT_tabla1
* La cual contiene la parte de Baltd
  PERFORM leer_planilla TABLES gt_tabla1 USING pa_path1 .
  DELETE gt_tabla1 WHERE bukrs NE pa_bukrs.
* Carga Archivo plano en tabla Interna GT_tabla2
* La cual contiene  Baltb
  PERFORM leer_planilla TABLES gt_tabla2 USING pa_path2 .
  DELETE gt_tabla2 WHERE bukrs NE pa_bukrs.
*
  IF gt_tabla1[] IS NOT INITIAL.
    PERFORM procesa_datos.
*
    PERFORM baja_datos.
  ELSE.
    MESSAGE e899(fi) WITH 'No hay datos para procesar de'
                         'la Sociedad' pa_bukrs.
  ENDIF.
*
END-OF-SELECTION.

*&---------------------------------------------------------------------*
*&      Form  PROCESA_DATOS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM procesa_datos.
* Estructura BALTD Interfase Carga Inicial de datos AF.
  DATA : BEGIN OF lt_baltd OCCURS 10.
          INCLUDE STRUCTURE baltd.
  DATA : END OF lt_baltd.
* Estructura BALTB Interfase Carga Inicial de Mov. AF
  DATA : BEGIN OF lt_baltb OCCURS 10.
          INCLUDE STRUCTURE baltb.
  DATA : END OF lt_baltb.

** Variables Auxiliares
  DATA : lv_anlkl(08)  TYPE c,
         lv_kostl(10)  TYPE n,
         lv_mov(03)    TYPE c,
         lv_acumu      TYPE i,
         lv_tabix      TYPE sytabix.

  FIELD-SYMBOLS : <f1>, <f>.

* Ordenar Tabla 1 Por
  SORT gt_tabla1 BY anlkl oldn1 oldn2.
*  bukrs anlkl oldn1 oldn2.

*  bukrs anlkl oldn1 oldn2 bzdat.
*
  LOOP AT gt_tabla1 WHERE bukrs EQ pa_bukrs.
*
    MOVE gt_tabla1-anlkl  TO lv_anlkl.
    MOVE lv_anlkl         TO gt_tabla1-anlkl.
*
    MOVE-CORRESPONDING gt_tabla1 TO lt_baltd.
*
*   Pasa codigo Antiguo
    MOVE gt_tabla1-oldn1 TO lt_baltd-aibn1.
    MOVE gt_tabla1-oldn2 TO lt_baltd-aibn2.
*
* Ajusta Fecha formato aaaammdd
    PERFORM formatea_fecha USING gt_tabla1-aktiv
                           CHANGING lt_baltd-aktiv.
*
    PERFORM formatea_fecha USING gt_tabla1-ivdat
                           CHANGING lt_baltd-ivdat.
*
* Inicio Depreciación

    PERFORM formatea_fecha USING gt_tabla1-afabg01
                           CHANGING lt_baltd-afabg01.

    PERFORM formatea_fecha USING gt_tabla1-afabg02
                           CHANGING lt_baltd-afabg02.

    PERFORM formatea_fecha USING gt_tabla1-afabg03
                           CHANGING lt_baltd-afabg03.

    PERFORM formatea_fecha USING gt_tabla1-afabg04
                           CHANGING lt_baltd-afabg04.

    PERFORM formatea_fecha USING gt_tabla1-afabg05
                           CHANGING lt_baltd-afabg05.

    PERFORM formatea_fecha USING gt_tabla1-afabg06
                           CHANGING lt_baltd-afabg06.

* Descomento para que tome segun Clave Dep. y Fech. Cap.
* Comento para Mantener dato Cargado.
*    clear : lt_baltd-afabg01, lt_baltd-afabg02,
*            lt_baltd-afabg03, lt_baltd-afabg04,
*            lt_baltd-afabg05, lt_baltd-afabg06.


* Clave de tipo de registro para BALTD
* Clase de registro para la carga inicial de datos BALTD=A,BALTB=B
    lt_baltd-rctyp = 'A'.
* Si trae subnumero, se cambia transacción
*Código de transacción seleccionado (batch input)
*AS91,AS92,AS94(Subnumero)
*    IF gt_tabla1-oldn2 EQ 0.
    lt_baltd-tcode = 'AS91'.
*    ELSE.
*      lt_baltd-tcode = 'AS94'.
*    ENDIF.
*
    MOVE sy-mandt  TO lt_baltd-mandt.

*  Cuenta cuantos registros tienen el activo en tabla de movimientos
    LOOP AT gt_tabla2 WHERE oldn1 = gt_tabla1-oldn1
                       AND  oldn2 = gt_tabla1-oldn2.
      lv_mov = lv_mov + 1.
    ENDLOOP.

    lt_baltd-bwcnt = lv_mov.
    CLEAR lv_mov.
    CLEAR : lt_baltd-grufl.
    APPEND lt_baltd.

**  Pasa Datos para BADI
*   Datos Mae y Saldos
    MOVE-CORRESPONDING lt_baltd TO gt_a_baltd.
    CLEAR gt_a_baltd-anln2.
    APPEND gt_a_baltd.
    CLEAR: gt_a_baltd , lt_baltd.
*
  ENDLOOP.
*

* Ajusta Movimientos
  LOOP AT gt_tabla2.
    MOVE sy-tabix TO lv_tabix .
    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
      EXPORTING
        input  = gt_tabla2-anlkl
      IMPORTING
        output = gt_tabla2-anlkl.
    MODIFY gt_tabla2 INDEX lv_tabix .
  ENDLOOP.
*
** AQUI LLENO ESTRUCTURA DE TABLA A_salida..a LA ANTIGUA
  LOOP AT gt_tabla2.
    MOVE-CORRESPONDING gt_tabla2 TO lt_baltb.
    lt_baltb-rctyp = 'B'.
    MOVE sy-mandt  TO lt_baltb-mandt.
    MOVE 'AS91' TO lt_baltb-tcode.
    PERFORM formatea_fecha USING gt_tabla2-bzdat
                           CHANGING lt_baltb-bzdat.
    APPEND lt_baltb.
**  Pasa Datos para BADI
*   Movimientos
    MOVE-CORRESPONDING gt_tabla2 TO gt_a_baltb.
    MOVE-CORRESPONDING lt_baltb TO gt_a_baltb.
    APPEND gt_a_baltb.
    CLEAR: gt_a_baltb , lt_baltb.
**********
  ENDLOOP.
*
* Ordena Archivos.
  SORT lt_baltd BY oldn1 oldn2.
  SORT lt_baltb BY oldn1 oldn2 bzdat.
  SORT gt_a_baltd BY oldn1 oldn2.
  SORT gt_a_baltb BY oldn1 oldn2 bzdat.


* Construye estructura para archivo de salida
* Para validaciones tradicionales usando
* programa RALTD01, o RALTD11
*
* Llena campos nulos
  LOOP AT lt_baltd.
    DO.
      ASSIGN COMPONENT sy-index OF STRUCTURE lt_baltd TO <f1>.
      IF sy-subrc <> 0.
        EXIT.
      ENDIF.
      SHIFT <f1> LEFT DELETING LEADING space.
      IF <f1> IS INITIAL.   ""or <F1> eq '0'."
        MOVE '/' TO <f1>.
        MODIFY lt_baltd.
      ENDIF.
    ENDDO.
  ENDLOOP.
*
* Tabla de Movimientos.
  LOOP AT lt_baltb.
    DO.
      ASSIGN COMPONENT sy-index OF STRUCTURE lt_baltb TO <f1>.
      IF sy-subrc <> 0.
        EXIT.
      ENDIF.
      SHIFT <f1> LEFT DELETING LEADING space.
      IF <f1> IS INITIAL. ""or <F1> eq '0'."
        MOVE '/' TO <f1>.
        MODIFY lt_baltb.
      ENDIF.
    ENDDO.
  ENDLOOP.
*
* Llena archivo de Salida a la Antigua
  LOOP AT lt_baltd.
    CLEAR gt_a_salida.
    gt_a_salida = lt_baltd.
    APPEND gt_a_salida.
*   Movimientos
    LOOP AT lt_baltb WHERE bukrs = lt_baltd-bukrs
                     AND   oldn1 = lt_baltd-oldn1
                     AND   oldn2 = lt_baltd-oldn2.
      CLEAR gt_a_salida.
      gt_a_salida = lt_baltb.
      APPEND gt_a_salida.
    ENDLOOP.
*   ***
  ENDLOOP.
*
  PERFORM guardar_planilla TABLES gt_a_salida
                           USING path_f 'DAT'.

ENDFORM.                    "procesa_datos

*&---------------------------------------------------------------------*
*&      Form  BAJA_DATOS
*&---------------------------------------------------------------------*
FORM baja_datos.
  TYPES: BEGIN OF tty_sap_iso_waers,
                 currency     LIKE tcurc-waers,
                 currency_iso LIKE tcurc-isocd.
  TYPES: END   OF tty_sap_iso_waers.
  DATA: ls_t093b      LIKE t093b,
        ls_bapi_anla  LIKE bapiacam06_de,
        ls_bapi_anlz  LIKE bapiacam04_de,
        ls_bapi_anlv  LIKE bapiacam07_de,
        ls_bapi_anlb  LIKE bapiacam08_de,
        ls_anlh       LIKE anlh,
        ld_vswrt      TYPE vswrt,
        ls_bapi_anlu  LIKE bapi_te_anlu,
        ls_iabra      LIKE iabra,
        ls_t001       LIKE t001,
        ls_afabe      TYPE afabe_d,
        ls_campo      TYPE char50,
        ls_num        TYPE numc2,
        ls_area       TYPE numc2,
        ls_pos        TYPE numc2,
        lv_curr       TYPE bf_lnran,
        ls_t001_waers TYPE tty_sap_iso_waers,
        v_berdatum    LIKE  bapi1022_5-eval_date.
* change parameters with maximum number of X's
  DATA: ls_con_generaldatax         LIKE  bapi1022_feglg001x
                                      VALUE ' XX XXXXXX',
        ls_con_inventoryx           LIKE  bapi1022_feglg011x
                                      VALUE 'XXX',
        ls_con_postinginformationx  LIKE  bapi1022_feglg002x
                                      VALUE 'XX   XXX',
        ls_con_timedependentdatax   LIKE  bapi1022_feglg003x
                                      VALUE '  XXXXXXXXXXXXX',
        ls_con_investacctassignmntx LIKE  bapi1022_feglg010x
                                      VALUE 'X X',
        ls_con_networthvaluationx   LIKE  bapi1022_feglg006x
                                      VALUE 'XXXX  X',
        ls_con_allocationsx         LIKE  bapi1022_feglg004x
                                      VALUE 'XXXXXXXX',
        ls_con_originx              LIKE  bapi1022_feglg009x
                                      VALUE 'XXXXXXXXXXXX  X',
        ls_con_realestatex          LIKE  bapi1022_feglg007x
                                      VALUE 'XXXXXXXXXXXXXXX',
        ls_con_insurancex           LIKE  bapi1022_feglg008x
                                      VALUE 'XXXXXXXX  XXX  ',
        ls_con_leasingx             LIKE  bapi1022_feglg005x
                                      VALUE 'XXXXXXXXX  XXXXXXX ',
        ls_con_depreciationareasx   LIKE  bapi1022_dep_areasx
                                 VALUE '00 XXXX    XXX XXXXXXXX  XXXXX'.
  DATA: ut_gendata LIKE bapi1022_feglg001_pid  OCCURS 0 WITH HEADER LINE
  ,
        ut_invent  LIKE bapi1022_feglg011_pid  OCCURS 0 WITH HEADER LINE
        ,
        ut_postinf LIKE bapi1022_feglg002_pid  OCCURS 0 WITH HEADER LINE
        ,
        ut_timedata LIKE bapi1022_feglg003_pid OCCURS 0 WITH HEADER LINE
        ,
        ut_allocat LIKE bapi1022_feglg004_pid  OCCURS 0 WITH HEADER LINE
        ,
        ut_origin  LIKE bapi1022_feglg009_pid  OCCURS 0 WITH HEADER LINE
        ,
        ut_invest  LIKE bapi1022_feglg010_pid  OCCURS 0 WITH HEADER LINE
        ,
        ut_netval  LIKE bapi1022_feglg006_pid  OCCURS 0 WITH HEADER LINE
        ,
      ut_realestate LIKE bapi1022_feglg007_pid OCCURS 0 WITH HEADER LINE
      ,
      ut_insurance LIKE bapi1022_feglg008_pid  OCCURS 0 WITH HEADER LINE
      ,
      ut_leasing LIKE bapi1022_feglg005_pid  OCCURS 0 WITH HEADER LINE,
      ut_deprareas LIKE bapi1022_dep_areas_pid OCCURS 0 WITH HEADER LINE
      ,
        ut_deprvals   LIKE  bapi1022_values OCCURS 0 WITH HEADER LINE,
        wa_key         LIKE  bapi1022_key,
        wa_gendata     LIKE  bapi1022_feglg001,
        wa_gendatax    LIKE  bapi1022_feglg001x,
        wa_invent      LIKE  bapi1022_feglg011,
        wa_inventx     LIKE  bapi1022_feglg011x,
        wa_postinf     LIKE  bapi1022_feglg002,
        wa_postinfx    LIKE  bapi1022_feglg002x,
        wa_timedata    LIKE  bapi1022_feglg003,
        wa_timedatax   LIKE  bapi1022_feglg003x,
        wa_allocat     LIKE  bapi1022_feglg004,
        wa_allocatx    LIKE  bapi1022_feglg004x,
        wa_origin      LIKE  bapi1022_feglg009,
        wa_originx     LIKE  bapi1022_feglg009x,
        wa_invest      LIKE  bapi1022_feglg010,
        wa_investx     LIKE  bapi1022_feglg010x,
        wa_netval      LIKE  bapi1022_feglg006,
        wa_netvalx     LIKE  bapi1022_feglg006x,
        wa_realestate  LIKE  bapi1022_feglg007,
        wa_realestatex LIKE  bapi1022_feglg007x,
        wa_insurance   LIKE  bapi1022_feglg008,
        wa_insurancex  LIKE  bapi1022_feglg008x,
        wa_leasing     LIKE  bapi1022_feglg005,
        wa_leasingx    LIKE  bapi1022_feglg005x ,
*
        lt_deprareas LIKE bapi1022_dep_areas OCCURS 0 WITH HEADER LINE,
        lt_deprareasx LIKE bapi1022_dep_areasx OCCURS 0 WITH HEADER LINE
        ,
         lt_deprvals LIKE bapi1022_values OCCURS 0 WITH HEADER LINE,
         lt_return   LIKE  bapiret2 OCCURS 0 WITH HEADER LINE,
         lt_cumval   LIKE bapi1022_cumval OCCURS 0 WITH HEADER LINE,
         lt_postval  LIKE  bapi1022_postval OCCURS 0 WITH HEADER LINE,
         lt_trtype   LIKE  bapi1022_trtype OCCURS 0 WITH HEADER LINE,
         lt_propval  LIKE  bapi1022_propval OCCURS 0 WITH HEADER LINE.
*
  DATA: lv_companycode LIKE  bapi1022_1-comp_code,
        lv_asset       LIKE  bapi1022_1-assetmaino,
        lv_subnumber   LIKE  bapi1022_1-assetsubno,
        lv_assetcreated  LIKE  bapi1022_reference,
        lv_acum1       TYPE i,
        lv_acum2       TYPE i,
        lv_bf_lnran    TYPE bf_lnran.
*
  FIELD-SYMBOLS : <f>, <g>.

* lee datos de la tabla1
  LOOP AT gt_a_baltd.

    REFRESH : ut_gendata,
              ut_invent  ,
              ut_postinf ,
              ut_timedata ,
              ut_allocat  ,
              ut_origin   ,
              ut_invest   ,
              ut_netval    ,
              ut_realestate,
              ut_insurance ,
              ut_leasing   ,
              ut_deprareas ,
              ut_deprvals  ,
              lt_deprareas ,
              lt_deprareasx,
              lt_cumval    ,
              lt_postval   ,
              lt_trtype    ,
              lt_propval   ,
              lt_return    .
*
    CLEAR : wa_key         ,
            wa_gendata     ,
            wa_gendatax    ,
            wa_invent      ,
            wa_inventx     ,
            wa_postinf     ,
            wa_postinfx    ,
            wa_timedata    ,
            wa_timedatax   ,
            wa_allocat     ,
            wa_allocatx    ,
            wa_origin      ,
            wa_originx     ,
            wa_invest      ,
            wa_investx     ,
            wa_netval      ,
            wa_netvalx     ,
            wa_realestate  ,
            wa_realestatex ,
            wa_insurance   ,
            wa_insurancex  ,
            wa_leasing     ,
            wa_leasingx    ,
            lt_deprareas   ,
            lt_deprareasx  ,
            lt_cumval      ,
            lt_postval     ,
            lt_return.

*
    v_berdatum    = sy-datlo.
    ls_t001-bukrs = gt_a_baltd-bukrs.
    CALL FUNCTION 'AM_T001_READ'
      EXPORTING
        f_t001 = ls_t001
      IMPORTING
        f_t001 = ls_t001
      EXCEPTIONS
        OTHERS = 8.
    IF sy-subrc <> 0.
      PERFORM symessage USING 'COMPANYCODE' 0 space.
      EXIT.
    ENDIF.
    ls_t001_waers-currency = ls_t001-waers.
*
    CALL FUNCTION 'DATE_TO_PERIOD_CONVERT'
      EXPORTING
        i_date  = v_berdatum
        i_periv = ls_t001-periv
      IMPORTING
        e_gjahr = ls_iabra-agjahr
      EXCEPTIONS
        OTHERS  = 8.
    IF sy-subrc <> 0.
      PERFORM symessage USING 'EVALUATIONDATE' 0 space.
      EXIT.
    ENDIF.
*
    MOVE-CORRESPONDING gt_a_baltd TO ls_bapi_anla.
    MOVE-CORRESPONDING gt_a_baltd TO ls_bapi_anlz.
    MOVE-CORRESPONDING gt_a_baltd TO ls_bapi_anlv.
*
* Mueve Sociedad
    MOVE ls_bapi_anla-bukrs              TO wa_key-companycode.
* Si informo numero activo, lo pasa para crear con = codigo.
    IF NOT ls_bapi_anla-anln1 IS INITIAL.
      MOVE ls_bapi_anla-anln1              TO wa_key-asset.
      MOVE ls_bapi_anla-anln2              TO wa_key-subnumber.
    ENDIF.

* Mueve datos GENERALDATA Y GENERALDATAX
    PERFORM append_gendata(sapl1022)  TABLES ut_gendata
                                      USING ls_bapi_anla.
    IF ut_gendata IS INITIAL.
      DESCRIBE TABLE ut_gendata LINES sy-tabix.
      DELETE ut_gendata INDEX sy-tabix.
    ELSE.
      MOVE-CORRESPONDING ut_gendata TO wa_gendata.
      MOVE wa_gendata-descript      TO wa_gendata-main_descript.
      MOVE ls_con_generaldatax      TO wa_gendatax.
    ENDIF.
* Mueve datos INVENATORY Y INVENTORYX
    PERFORM append_invent(sapl1022)   TABLES ut_invent
                                      USING ls_bapi_anla.
    IF ut_invent IS INITIAL.
      DESCRIBE TABLE ut_invent LINES sy-tabix.
      DELETE ut_invent INDEX sy-tabix.
    ELSE.
      MOVE-CORRESPONDING ut_invent TO wa_invent.
      MOVE ls_con_inventoryx       TO wa_inventx.
    ENDIF.
* Mueve datos POSTINGINFORMATION Y POSTINGINFORMATIONX
    PERFORM append_postinf(sapl1022)  TABLES ut_postinf
                                      USING ls_bapi_anla.
    IF ut_postinf IS INITIAL.
      DESCRIBE TABLE ut_postinf LINES sy-tabix.
      DELETE ut_postinf INDEX sy-tabix.
    ELSE.
      MOVE-CORRESPONDING ut_postinf     TO wa_postinf.
      MOVE ls_con_postinginformationx   TO wa_postinfx.
    ENDIF.
* Mueve datos TIMEDEPENDENTDATA Y TIMEDEPENDENTDATAX
    PERFORM append_timedata(sapl1022) TABLES ut_timedata
                                      USING ls_bapi_anlz.
    IF ut_timedata IS INITIAL.
      DESCRIBE TABLE ut_timedata LINES sy-tabix.
      DELETE ut_timedata INDEX sy-tabix.
    ELSE.
      MOVE-CORRESPONDING ut_timedata     TO wa_timedata.
      MOVE '19000101'                    TO wa_timedata-from_date.
      MOVE '99991231'                    TO wa_timedata-to_date.
      MOVE ls_con_timedependentdatax     TO wa_timedatax.
    ENDIF.
* Mueve datos ALLOCATIONS Y ALLOCATIONSX
    PERFORM append_allocat(sapl1022)  TABLES ut_allocat
                                      USING ls_bapi_anla.
    IF ut_allocat IS INITIAL.
      DESCRIBE TABLE ut_allocat LINES sy-tabix.
      DELETE ut_allocat INDEX sy-tabix.
    ELSE.
      lv_acum1 = 0.
      MOVE-CORRESPONDING ut_allocat     TO wa_allocat.
      MOVE ls_con_allocationsx          TO wa_allocatx.
    ENDIF.
* Mueve datos ORIGIN Y ORIGINX
    PERFORM append_origin(sapl1022)     TABLES ut_origin
                                        USING  ls_bapi_anla
                                               ls_t001_waers.
    IF ut_origin IS INITIAL.
      DESCRIBE TABLE ut_origin LINES sy-tabix.
      DELETE ut_origin INDEX sy-tabix.
    ELSE.
      MOVE-CORRESPONDING : ut_origin     TO wa_origin.
      wa_originx = ls_con_originx.
    ENDIF.
* Mueve datos INVESTACCTASSIGNMNT Y INVESTACCTASSIGNMNTX
    PERFORM append_invest(sapl1022)  TABLES ut_invest
                                     USING  ls_bapi_anla.
    IF ut_invest IS INITIAL.
      DESCRIBE TABLE ut_invest LINES sy-tabix.
      DELETE ut_invest INDEX sy-tabix.
    ELSE.
      lv_acum1 = 0.
      MOVE-CORRESPONDING ut_invest      TO wa_invest.
      MOVE ls_con_investacctassignmntx  TO wa_investx.
    ENDIF.
**
* Mueve datos NETWORTHVALUATION Y NETWORTHVALUATIONX
    PERFORM append_netval(sapl1022)  TABLES ut_netval
                                     USING ls_bapi_anla
                                           ls_t001_waers.
    IF ut_netval IS INITIAL.
      DESCRIBE TABLE ut_netval LINES sy-tabix.
      DELETE ut_netval INDEX sy-tabix.
    ELSE.
      lv_acum1 = 0.
      MOVE-CORRESPONDING ut_netval     TO wa_netval.
      MOVE ls_con_networthvaluationx   TO wa_netvalx.
    ENDIF.
* Mueve datos REALESTATE Y REALESTATEX
    PERFORM append_realestate(sapl1022) TABLES ut_realestate
                                        USING  ls_bapi_anla.
    IF ut_realestate IS INITIAL.
      DESCRIBE TABLE ut_realestate LINES sy-tabix.
      DELETE ut_realestate INDEX sy-tabix.
    ELSE.
      MOVE-CORRESPONDING ut_realestate     TO wa_realestate.
      MOVE ls_con_realestatex              TO wa_realestatex.
    ENDIF.
* Mueve datos INSURANCE Y INSURANCEX
    PERFORM append_insurance(sapl1022) TABLES ut_insurance
                                       USING ls_bapi_anlv
                                             ls_t001_waers.
    IF ut_insurance IS INITIAL.
      DESCRIBE TABLE ut_insurance LINES sy-tabix.
      DELETE ut_insurance INDEX sy-tabix.
    ELSE.
      MOVE-CORRESPONDING ut_insurance      TO wa_insurance.
      MOVE ls_con_insurancex               TO wa_insurancex.
    ENDIF.
* Mueve datos LEASING Y LEASINGX
    PERFORM append_leasing(sapl1022)  TABLES ut_leasing
                                      USING ls_bapi_anla
                                            ls_t001_waers
                                            ls_iabra-agjahr.
    IF ut_leasing IS INITIAL.
      DESCRIBE TABLE ut_leasing LINES sy-tabix.
      DELETE ut_leasing INDEX sy-tabix.
    ELSE.
      MOVE-CORRESPONDING ut_postinf     TO wa_leasing.
      MOVE ls_con_leasingx              TO wa_leasingx.
    ENDIF.
*
    REFRESH : ut_deprareas, lt_deprareas, lt_deprareasx.
    ls_num = 0.
*
    DO 6 TIMES. "N° Segun Areas Cargadas
      ADD 1 TO ls_num.

*     Tabla Áreas de valoración (todos los grupos de campo lógicos)
      CONCATENATE 'GT_A_BALTD-AFABE' ls_num INTO ls_campo.
      ASSIGN (ls_campo) TO <f>.

      CHECK <f> IS NOT INITIAL.
      MOVE <f> TO ls_bapi_anlb-gafaber.
      MOVE <f> TO ls_afabe.
*
      CONCATENATE 'GT_A_BALTD-AFABG' ls_num INTO ls_campo.
      ASSIGN (ls_campo) TO <f>.
      MOVE <f> TO ls_bapi_anlb-afabg.
*
      CONCATENATE 'GT_A_BALTD-AFASL' ls_num INTO ls_campo.
      ASSIGN (ls_campo) TO <f>.
      MOVE <f> TO ls_bapi_anlb-afasl.
*
      CONCATENATE 'GT_A_BALTD-NDJAR' ls_num INTO ls_campo.
      ASSIGN (ls_campo) TO <f>.
      MOVE <f> TO ls_bapi_anlb-ndjar.
*
      CONCATENATE 'GT_A_BALTD-NDPER' ls_num INTO ls_campo.
      ASSIGN (ls_campo) TO <f>.
      MOVE <f> TO ls_bapi_anlb-ndper.
*
      CONCATENATE 'GT_A_BALTD-SCHRW' ls_num INTO ls_campo.
      ASSIGN (ls_campo) TO <f>.
      TRANSLATE <f> USING '. '.
      TRANSLATE <f> USING ',.'.
      CONDENSE <f> NO-GAPS.
      MOVE <f> TO ls_bapi_anlb-schrw.
*
*     Asigna valores de Areas de Valoración.
      PERFORM append_deprareas(sapl1022) TABLES ut_deprareas
                                         USING  ls_bapi_anlb
                                                ls_afabe
                                                ls_t001_waers.

* Valores de Apertura de Ejercicio
*     Tabla Grupo de campos lógico CUMVAL: Valor transferencia acumulado
      lt_cumval-fisc_year = p_gjahr. "Ejercicio de carga
      CONCATENATE 'GT_A_BALTD-AFABE' ls_num INTO ls_campo.
      ASSIGN (ls_campo) TO <f>.
      lt_cumval-area      = <f>.
*
*     Valor Adq. Apertura Ejercicio
      CONCATENATE 'GT_A_BALTD-KANSW' ls_num INTO ls_campo.
      ASSIGN (ls_campo) TO <f>.
      TRANSLATE <f> USING '. '.
      TRANSLATE <f> USING ',.'.
      CONDENSE <f> NO-GAPS.
      lt_cumval-acq_value = <f>.
*
*     Valor Cm.Adq. Apertura Ejercicio
      CONCATENATE 'GT_A_BALTD-KAUFW' ls_num INTO ls_campo.
      ASSIGN (ls_campo) TO <f>.
      TRANSLATE <f> USING '. '.
      TRANSLATE <f> USING ',.'.
      CONDENSE <f> NO-GAPS.
      lt_cumval-rev_repl = <f>.
*
*     Dep. Acum. Apertura Ejercicio
      CONCATENATE 'GT_A_BALTD-KNAFA' ls_num INTO ls_campo.
      ASSIGN (ls_campo) TO <f>.
      TRANSLATE <f> USING '. '.
      TRANSLATE <f> USING ',.'.
      CONDENSE <f> NO-GAPS.
      lt_cumval-ord_dep   = <f>.
*
*     Cm. Dep. Acum. Apertura Ejercicio
      CONCATENATE 'GT_A_BALTD-KAUFN' ls_num INTO ls_campo.
      ASSIGN (ls_campo) TO <f>.
      TRANSLATE <f> USING '. '.
      TRANSLATE <f> USING ',.'.
      CONDENSE <f> NO-GAPS.
      lt_cumval-rev_ord_dep   = <f>.
*
      APPEND lt_cumval.

* Solo si es carga Inter-Anual Lleva Valores
      IF NOT p_inter IS INITIAL.
* Valores Contabilizados en ejercicio de Carga
* Tabla Grupo campos lógico POSTVAL: Valor transferencia contabiliz.
        lt_postval-fisc_year = p_gjahr. "Ejercicio de carga
        CONCATENATE 'GT_A_BALTD-AFABE' ls_num INTO ls_campo.
        ASSIGN (ls_campo) TO <f>.
        lt_postval-area      = <f>.
*
*     Depreciación Normal Contabilizada
        CONCATENATE 'GT_A_BALTD-NAFAG' ls_num INTO ls_campo.
        ASSIGN (ls_campo) TO <f>.
        TRANSLATE <f> USING '. '.
        TRANSLATE <f> USING ',.'.
        CONDENSE <f> NO-GAPS.
        lt_postval-ord_dep   = <f>.
*
*     Cm. Adq. Contabilizada
        CONCATENATE 'GT_A_BALTD-AUFWB' ls_num INTO ls_campo.
        ASSIGN (ls_campo) TO <f>.
        TRANSLATE <f> USING '. '.
        TRANSLATE <f> USING ',.'.
        CONDENSE <f> NO-GAPS.
        lt_postval-rev_repl   = <f>.
*
*     Cm. Dep.Contabilizada
        CONCATENATE 'GT_A_BALTD-AUFNG' ls_num INTO ls_campo.
        ASSIGN (ls_campo) TO <f>.
        TRANSLATE <f> USING '. '.
        TRANSLATE <f> USING ',.'.
        CONDENSE <f> NO-GAPS.
        lt_postval-rev_cum_ord_dep   = <f>.
*
        APPEND lt_postval.
*
      ENDIF.
*
    ENDDO.
*
*

* Carga Movimientos
* Solo si es carga Inter-Anual Lleva Valores
    IF NOT p_inter IS INITIAL.
*     Verifica si existen movimientos en ejercicio de carga
      IF gt_a_baltd-bwcnt NE 0. "IS NOT INITIAL.
*     Tabla Movimientos AF antiguo en transferencia interanual
        lv_bf_lnran = 0.

        LOOP AT gt_a_baltb WHERE oldn1 EQ gt_a_baltd-oldn1 AND
                                 oldn2 EQ gt_a_baltd-oldn2.

          ADD 1 TO lv_bf_lnran.
          CLEAR ls_pos.
          DO 6 TIMES. "N° Segun Areas Cargadas

            ADD 1 TO ls_pos.

            CASE ls_pos.
              WHEN '1'.   ls_area = '01'.
              WHEN '2'.   ls_area = '05'.
              WHEN '3'.   ls_area = '10'.
              WHEN '4'.   ls_area = '20'.
              WHEN '5'.   ls_area = '30'.
              WHEN '6'.   ls_area = '50'.
              WHEN OTHERS.
                ls_area = '99'.
            ENDCASE.
*
            lt_trtype-fisc_year   = p_gjahr. "Ejercicio de carga
            lt_trtype-current_no  = lv_bf_lnran.
*         Fecha y Cod. movimiento
            lt_trtype-valuedate   = gt_a_baltb-bzdat.
            lt_trtype-assettrtyp  = gt_a_baltb-bwasl.
            lt_trtype-area      = ls_area.
*
*         Valor del Movimiento
            CONCATENATE 'GT_A_BALTB-ANBTR' ls_pos INTO ls_campo.
            ASSIGN (ls_campo) TO <f>.
            TRANSLATE <f> USING '. '.
            TRANSLATE <f> USING ',.'.
            CONDENSE <f> NO-GAPS.
            lt_trtype-amount      = <f>.
*
            APPEND lt_trtype.
***

*
*    Valores Prop. de activo fijo determinados en la baja
            lt_propval-fisc_year  = p_gjahr. "Ejercicio de carga
            lt_propval-current_no = lv_bf_lnran.
            lt_propval-area      = ls_area.
*
*         Valor de Depreciación Normal del ejercicio
            CONCATENATE 'GT_A_BALTB-NAFAL' ls_pos INTO ls_campo.
            ASSIGN (ls_campo) TO <f>.
            TRANSLATE <f> USING '. '.
            TRANSLATE <f> USING ',.'.
            CONDENSE <f> NO-GAPS.
            lt_propval-ord_dep_cy = <f>.
*
*         Valor de Depreciación Normal de ejercicio anterior
            CONCATENATE 'GT_A_BALTB-NAFAV' ls_pos INTO ls_campo.
            ASSIGN (ls_campo) TO <f>.
            TRANSLATE <f> USING '. '.
            TRANSLATE <f> USING ',.'.
            CONDENSE <f> NO-GAPS.
            lt_propval-ord_dep_cu = <f>.
*
*         Valor de Cm. de ejercicio anterior
            CONCATENATE 'GT_A_BALTB-AUFWL' ls_pos INTO ls_campo.
            ASSIGN (ls_campo) TO <f>.
            TRANSLATE <f> USING '. '.
            TRANSLATE <f> USING ',.'.
            CONDENSE <f> NO-GAPS.
            lt_propval-rev_repl_cu = <f>.
*
*         Valor de Cm. de ejercicio actual
            CONCATENATE 'GT_A_BALTB-AUFWV' ls_pos INTO ls_campo.
            ASSIGN (ls_campo) TO <f>.
            TRANSLATE <f> USING '. '.
            TRANSLATE <f> USING ',.'.
            CONDENSE <f> NO-GAPS.
            lt_propval-rev_repl_cy = <f>.
*
            APPEND lt_propval.
*
          ENDDO.
        ENDLOOP.
*
      ENDIF.
*
    ENDIF.
*
*   Carga Parametros de Areas de Valoración
    LOOP AT ut_deprareas.
      MOVE-CORRESPONDING ut_deprareas TO lt_deprareas.
      APPEND lt_deprareas.

      MOVE ls_con_depreciationareasx TO lt_deprareasx.
      MOVE ut_deprareas-area         TO lt_deprareasx-area.
      APPEND lt_deprareasx.
    ENDLOOP.
*
* Pasa datos a función de creación de activos.
*
    CALL FUNCTION 'BAPI_FIXEDASSET_OVRTAKE_CREATE'
      EXPORTING
        key                  = wa_key
        testrun              = pa_test
        generaldata          = wa_gendata
        generaldatax         = wa_gendatax
        inventory            = wa_invent
        inventoryx           = wa_inventx
        postinginformation   = wa_postinf
        postinginformationx  = wa_postinfx
        timedependentdata    = wa_timedata
        timedependentdatax   = wa_timedatax
        allocations          = wa_allocat
        allocationsx         = wa_allocatx
        origin               = wa_origin
        originx              = wa_originx
        investacctassignmnt  = wa_invest
        investacctassignmntx = wa_investx
        networthvaluation    = wa_netval
        networthvaluationx   = wa_netvalx
        realestate           = wa_realestate
        realestatex          = wa_realestatex
        insurance            = wa_insurance
        insurancex           = wa_insurancex
        leasing              = wa_leasing
        leasingx             = wa_leasingx
      IMPORTING
        companycode          = lv_companycode
        asset                = lv_asset
        subnumber            = lv_subnumber
        assetcreated         = lv_assetcreated
      TABLES
        depreciationareas    = lt_deprareas
        depreciationareasx   = lt_deprareasx
*       INVESTMENT_SUPPORT   =
*       EXTENSIONIN          =
        cumulatedvalues      = lt_cumval
        postedvalues         = lt_postval
        transactions         = lt_trtype
        proportionalvalues   = lt_propval
        return               = lt_return.

    READ TABLE lt_return WITH KEY type = 'E'.
    IF sy-subrc EQ 0.
      LOOP AT lt_return WHERE type = 'E'.
        WRITE:/ gt_a_baltd-bukrs, gt_a_baltd-oldn1,
                gt_a_baltd-oldn2, lt_return-message(100).
      ENDLOOP.
    ELSE.
      CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'.
      LOOP AT lt_return.
        WRITE:/ gt_a_baltd-bukrs, gt_a_baltd-oldn1,
                gt_a_baltd-oldn2, lt_return-message(100).
      ENDLOOP.
    ENDIF.
*
  ENDLOOP.
*
ENDFORM.                    "PROCESA_DATOS
*
*&---------------------------------------------------------------------*
*&      Form  symessage
*&---------------------------------------------------------------------*
FORM symessage  USING  value(par)  value(row)  value(fld).
  CALL FUNCTION 'BALW_BAPIRETURN_GET2'
    EXPORTING
      type      = sy-msgty
      cl        = sy-msgid
      number    = sy-msgno
      par1      = sy-msgv1
      par2      = sy-msgv2
      par3      = sy-msgv3
      par4      = sy-msgv4
      parameter = par
      row       = row
      field     = fld
    IMPORTING
      return    = gd_return.
ENDFORM.                    " SYMESSAGE
*&---------------------------------------------------------------------*
*&      Form  VALUE_REQ_FILE
*&---------------------------------------------------------------------*
FORM value_req_file USING filename LIKE rlgrap-filename.
  DATA wk_file LIKE rlgrap-filename.

  CALL FUNCTION 'WS_FILENAME_GET'
    EXPORTING
      def_filename = text-f01
      def_path     = 'C:\'
      mask         = ',*.*,*.*,*.csv,*.csv.'
      mode         = 'L'
      title        = 'Abre Archivo'
    IMPORTING                       " VALUE_REQ_FILE
      filename     = wk_file
    EXCEPTIONS
      OTHERS.

  IF sy-subrc = 0.
    filename = wk_file.
  ENDIF.
ENDFORM.                               " VALUE_REQ_FILE
*
*---------------------------------------------------------------------*
*  Genera Archivo Plano
*---------------------------------------------------------------------*
FORM guardar_planilla TABLES nom_tab
                      USING nom_arch nom_tip.
  STATICS contar_download.
* Variables Locales
  DATA : lv_narch LIKE rlgrap-filename,
         lv_ntipo TYPE  char10,
         lv_file  TYPE string.
* Asignacion de variables
  lv_narch = nom_arch.
  lv_ntipo = nom_tip(3).
  lv_file  = nom_arch.
*
  IF lv_narch(1) = '/'.

    IF lv_ntipo = 'BIN'.
      OPEN DATASET lv_narch FOR OUTPUT IN BINARY MODE.
    ELSE.
      OPEN DATASET lv_narch FOR OUTPUT IN TEXT MODE ENCODING DEFAULT.
    ENDIF.
    IF sy-subrc = 0.
      LOOP AT nom_tab.
        TRANSFER nom_tab TO lv_narch.
        IF sy-subrc NE 0. EXIT.ENDIF.
      ENDLOOP.
    ELSE.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
              WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF.
  ELSE.
    CALL FUNCTION 'GUI_DOWNLOAD'
      EXPORTING
        filename                = lv_file
        filetype                = lv_ntipo
*       WRITE_FIELD_SEPARATOR   = ' '
      TABLES
        data_tab                = nom_tab
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
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
              WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF.
  ENDIF.
ENDFORM.                    "GUARDAR_PLANILLA
*
*&---------------------------------------------------------------------*
*&      Form  LEER_PLANILLA
*&---------------------------------------------------------------------*
FORM leer_planilla  TABLES   p_tabla
                    USING    p_path.
  DATA lv_file TYPE string.
*
  lv_file = p_path.

  CALL FUNCTION 'GUI_UPLOAD'
    EXPORTING
      filename                = lv_file
*     FILETYPE                = 'ASC'
      has_field_separator     = 'X'
    TABLES
      data_tab                = p_tabla
    EXCEPTIONS
      file_open_error         = 1
      file_read_error         = 2
      no_batch                = 3
      gui_refuse_filetransfer = 4
      invalid_type            = 5
      no_authority            = 6
      unknown_error           = 7
      bad_data_format         = 8
      header_not_allowed      = 9
      separator_not_allowed   = 10
      header_too_long         = 11
      unknown_dp_error        = 12
      access_denied           = 13
      dp_out_of_memory        = 14
      disk_full               = 15
      dp_timeout              = 16
      OTHERS                  = 17.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            INTO sy-msgv1.
    MESSAGE e003 WITH sy-msgv1 lv_file.
  ENDIF.

ENDFORM.                    " LEER_PLANILLA
*&---------------------------------------------------------------------*
*&      Form  FORMATEA_FECHA
*&---------------------------------------------------------------------*
FORM formatea_fecha  USING    p_fecha_ent
                     CHANGING p_fecha_sal.
  DATA lv_fecha TYPE char10.
*
  CLEAR p_fecha_sal.
  MOVE p_fecha_ent(10) TO lv_fecha.
  TRANSLATE lv_fecha USING '-.'.
*
  CALL FUNCTION 'CONVERT_DATE_TO_INTERNAL'
    EXPORTING
      date_external            = lv_fecha
    IMPORTING
      date_internal            = p_fecha_sal
    EXCEPTIONS
      date_external_is_invalid = 1
      OTHERS                   = 2.
  IF sy-subrc <> 0.
* Implement suitable error handling here
  ENDIF.
ENDFORM.                    " FORMATEA_FECHA
