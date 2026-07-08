*&---------------------------------------------------------------------*
*&  Include           ZFIBI_AS91_F01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  FILENAME_GET
*&---------------------------------------------------------------------*
FORM filename_get  CHANGING p_p_arch.
  DATA: lv_mensaje    TYPE string.

  CALL FUNCTION 'WS_FILENAME_GET'
    EXPORTING
      def_filename     = p_p_arch
      def_path         = 'C:\'
      mask             = ',*.*,*.*.'
      mode             = 'O'
      title            = 'Abrir'
    IMPORTING
      filename         = p_p_arch
    EXCEPTIONS
      inv_winsys       = 01
      no_batch         = 02
      selection_cancel = 03
      selection_error  = 04.

  IF sy-subrc NE 0.
    MESSAGE s899(mm) DISPLAY LIKE 'E' WITH text-m01.
  ENDIF.
ENDFORM.                    " FILENAME_GET
*&---------------------------------------------------------------------*
*&      Form  VALIDA_PARAMETROS
*&---------------------------------------------------------------------*
FORM valida_parametros .
  IF p_arch IS INITIAL.
    MESSAGE s899(mm) DISPLAY LIKE 'E' WITH text-m02.
    STOP.
  ENDIF.
ENDFORM.                    " VALIDA_PARAMETROS
*&---------------------------------------------------------------------*
*&      Form  CARGA_ARCHIVO
*&---------------------------------------------------------------------*
FORM carga_archivo .
  DATA: lv_filename     TYPE rlgrap-filename.
* Lectura del archivo de entrada
  REFRESH: gt_carga_excel.
  CLEAR: lv_filename, gv_lineas.
  lv_filename = p_arch.
  gv_lineas = 2.
  CALL FUNCTION 'ALSM_EXCEL_TO_INTERNAL_TABLE'
    EXPORTING
      filename                = lv_filename
      i_begin_col             = '1'
      i_begin_row             = '2'
      i_end_col               = '127'
      i_end_row               = '65536'
    TABLES
      intern                  = gt_carga_excel
    EXCEPTIONS
      inconsistent_parameters = 1
      upload_ole              = 2
      OTHERS                  = 3.

  IF sy-subrc <> 0.
    MESSAGE s899(mm) DISPLAY LIKE 'E' WITH text-m01.
    STOP.
  ENDIF.
  IF cb_actua IS NOT INITIAL.
    PERFORM mapear_archivo1.
  ELSE.
    PERFORM mapear_archivo2.
  ENDIF.
ENDFORM.                    " CARGA_ARCHIVO
*&---------------------------------------------------------------------*
*&      Form  MAPEAR_ARCHIVO1
*&---------------------------------------------------------------------*
FORM mapear_archivo1 .
*  CLEAR: gv_lineas.
*  DESCRIBE TABLE gt_carga_excel LINES gv_lineas.
  PERFORM indicador_progreso USING 1 'Cargando Archivo...'.
  LOOP AT gt_carga_excel INTO gw_carga_excel.
*    PERFORM indicador_progreso USING sy-tabix 'Cargando Archivo...'.
    CASE gw_carga_excel-col.
      WHEN 1.
        gw_data1-anlkl           =   gw_carga_excel-value.  " Clase activos fijos
      WHEN 2.
        gw_data1-bukrs           =   gw_carga_excel-value.  " Sociedad
      WHEN 3.
        gw_data1-txt50           =   gw_carga_excel-value.  " Denominación
      WHEN 4.
        gw_data1-txa50           =   gw_carga_excel-value.  " Denominación
      WHEN 5.
        gw_data1-anlhtxt         =   gw_carga_excel-value.  " Txt.núm.pral.AF
      WHEN 6.
        gw_data1-sernr           =   gw_carga_excel-value.  " Número de serie
      WHEN 7.
        gw_data1-invnr           =   gw_carga_excel-value.  " Número de inventario
      WHEN 8.
        gw_data1-menge           =   gw_carga_excel-value.  " Cantidad
      WHEN 9.
        gw_data1-meins           =   gw_carga_excel-value.  " Unidad de medida
      WHEN 10.
        gw_data1-xhist           =   gw_carga_excel-value.  " Gestion Historica
      WHEN 11.
        gw_data1-ivdat           =   gw_carga_excel-value.  " Último inventario el
      WHEN 12.
        gw_data1-inken           =   gw_carga_excel-value.  " Incluir AF en la lista de inventario
      WHEN 13.
        gw_data1-invzu           =   gw_carga_excel-value.  " Nota de inventario
      WHEN 14.
        gw_data1-aktiv           =   gw_carga_excel-value.  " Capitalizado el
      WHEN 15.
        gw_data1-gsber           =   gw_carga_excel-value.  " División
      WHEN 16.
        gw_data1-kostl           =   gw_carga_excel-value.  " Centro de coste
      WHEN 17.
        gw_data1-kostlv          =   gw_carga_excel-value.  " CeCo responsable
      WHEN 18.
        gw_data1-werks           =   gw_carga_excel-value.  " Centro
      WHEN 19.
        gw_data1-raumn           =   gw_carga_excel-value.  " Local
      WHEN 20.
        gw_data1-kfzkz           =   gw_carga_excel-value.  " Matrícula vehículo
      WHEN 21.
        gw_data1-msfak           =   gw_carga_excel-value.  " Factor turnos
      WHEN 22.
        gw_data1-fkber           =   gw_carga_excel-value.  " Área funciona
      WHEN 23.
        gw_data1-ord41           =   gw_carga_excel-value.  " Torre
      WHEN 24.
        gw_data1-ord42           =   gw_carga_excel-value.  " Zona
      WHEN 25.
        gw_data1-ord43           =   gw_carga_excel-value.  " Criterio clasif.3
      WHEN 26.
        gw_data1-ord44           =   gw_carga_excel-value.  " Leasing
      WHEN 27.
        gw_data1-izwek           =   gw_carga_excel-value.  " Destino inversión
      WHEN 28.
        gw_data1-umwkz           =   gw_carga_excel-value.  " Inv.prot.medio amb.
      WHEN 29.
        gw_data1-anlue           =   gw_carga_excel-value.  " Supranúmero de AF
      WHEN 30.
        gw_data1-invsl_1         =   gw_carga_excel-value.  " Clave para el fomento de la inversión
      WHEN 31.
        gw_data1-lifnr           =   gw_carga_excel-value.  " Acreedor
      WHEN 32.
        gw_data1-liefe           =   gw_carga_excel-value.  " Acreedor
      WHEN 33.
        gw_data1-herst           =   gw_carga_excel-value.  " Fabricante
      WHEN 34.
        gw_data1-xneu_am         =   gw_carga_excel-value.  " AF comprado nuevo
      WHEN 35.
        gw_data1-xgbr_am         =   gw_carga_excel-value.  " Comprado 2da mano
      WHEN 36.
        gw_data1-vbund           =   gw_carga_excel-value.  " Sociedad GL asociada
      WHEN 37.
        gw_data1-land1           =   gw_carga_excel-value.  " País origen
      WHEN 38.
        gw_data1-typbz           =   gw_carga_excel-value.  " Denominación de tipo
      WHEN 39.
        gw_data1-aibn1           =   gw_carga_excel-value.  " Activo fijo orig.
      WHEN 40.
        gw_data1-aibn2           =   gw_carga_excel-value.  " Activo fijo orig.
      WHEN 41.
        gw_data1-aibdt           =   gw_carga_excel-value.  " Alta el
      WHEN 42.
        gw_data1-urjhr           =   gw_carga_excel-value.  " Año adquis.orig.
      WHEN 43.
        gw_data1-urwrt           =   gw_carga_excel-value.  " Valor original
      WHEN 44.
        gw_data1-antei           =   gw_carga_excel-value.  " Parte prod.propia
      WHEN 45.
        gw_data1-vmgli           =   gw_carga_excel-value.  " Clave agrupamiento
      WHEN 46.
        gw_data1-eigkz           =   gw_carga_excel-value.  " Indicador propiedad
      WHEN 47.
        gw_data1-wrtma           =   gw_carga_excel-value.  " Val.patrim.man.
      WHEN 48.
        gw_data1-xvrmw           =   gw_carga_excel-value.  " Valor patrimonial manual
      WHEN 49.
        gw_data1-fiamt           =   gw_carga_excel-value.  " Delegación Hacienda
      WHEN 50.
        gw_data1-ehwnr           =   gw_carga_excel-value.  " N.I.F. valor unit
      WHEN 51.
        gw_data1-ehwzu           =   gw_carga_excel-value.  " Cartilla del
      WHEN 52.
        gw_data1-stadt           =   gw_carga_excel-value.  " Municipio
      WHEN 53.
        gw_data1-gruvo           =   gw_carga_excel-value.  " Reg.propiedad del
      WHEN 54.
        gw_data1-grein           =   gw_carga_excel-value.  " Inscripción del
      WHEN 55.
        gw_data1-grbnd           =   gw_carga_excel-value.  " Tomo/hoja/nº actual
      WHEN 56.
        gw_data1-grblt           =   gw_carga_excel-value.  " Tomo/hoja/nº actual
      WHEN 57.
        gw_data1-grlfd           =   gw_carga_excel-value.  " Tomo/hoja/nº actual
      WHEN 58.
        gw_data1-aufla           =   gw_carga_excel-value.  " Ces.propiedad
      WHEN 59.
        gw_data1-flurk           =   gw_carga_excel-value.  " Cartilla parcelaria
      WHEN 60.
        gw_data1-flurn           =   gw_carga_excel-value.  " Cartilla parcelaria
      WHEN 61.
        gw_data1-grufl           =   gw_carga_excel-value.  " Superficie
      WHEN 62.
        gw_data1-vsstx           =   gw_carga_excel-value.  " Nº de póliza
      WHEN 63.
        gw_data1-vsztx           =   gw_carga_excel-value.  " Comentario
      WHEN 64.
        gw_data1-vrsbg           =   gw_carga_excel-value.  " Inicio
      WHEN 65.
        gw_data1-vsind           =   gw_carga_excel-value.  " Serie de índices
      WHEN 66.
        gw_data1-vrsba           =   gw_carga_excel-value.  " Valor base
      WHEN 67.
        gw_data1-vsman           =   gw_carga_excel-value.  " Actualiz.man.
      WHEN 68.
        gw_data1-vrsma           =   gw_carga_excel-value.  " Valor manual
      WHEN 69.
        gw_data1-leafi           =   gw_carga_excel-value.  " Parte contratante
      WHEN 70.
        gw_data1-lvtnr           =   gw_carga_excel-value.  " Número de contrato
      WHEN 71.
        gw_data1-lvdat           =   gw_carga_excel-value.  " Fecha del contrato
      WHEN 72.
        gw_data1-lkdat           =   gw_carga_excel-value.  " Fecha rescis.
      WHEN 73.
        gw_data1-leabg           =   gw_carga_excel-value.  " Inicio
      WHEN 74.
        gw_data1-lejar           =   gw_carga_excel-value.  " Duración
      WHEN 75.
        gw_data1-leper           =   gw_carga_excel-value.  " Duración
      WHEN 76.
        gw_data1-leart           =   gw_carga_excel-value.  " Clase
      WHEN 77.
        gw_data1-lbasw           =   gw_carga_excel-value.  " Valor base de nuevo
      WHEN 78.
        gw_data1-lkauf           =   gw_carga_excel-value.  " Precio de compra
      WHEN 79.
        gw_data1-letxt           =   gw_carga_excel-value.  " Comentario
      WHEN 80.
        gw_data1-leanz           =   gw_carga_excel-value.  " Nº pagos leasing
      WHEN 81.
        gw_data1-lryth           =   gw_carga_excel-value.  " Forma de pago
      WHEN 82.
        gw_data1-lvors           =   gw_carga_excel-value.  " Pagos anticipados
      WHEN 83.
        gw_data1-legeb           =   gw_carga_excel-value.  " Cuota de leasing
      WHEN 84.
        gw_data1-lzins           =   gw_carga_excel-value.  " Tp.ints.anual
      WHEN 85.
        gw_data1-afasl_1         =   gw_carga_excel-value.  " Amo 1
      WHEN 86.
        gw_data1-afasl_2         =   gw_carga_excel-value.  " Amo 2
      WHEN 87.
        gw_data1-afasl_3         =   gw_carga_excel-value.  " Amo 3
      WHEN 88.
        gw_data1-afasl_4         =   gw_carga_excel-value.  " Amo 4
      WHEN 89.
        gw_data1-ndjar_1         =   gw_carga_excel-value.  " Duración
      WHEN 90.
        gw_data1-ndjar_2         =   gw_carga_excel-value.  " Duración
      WHEN 91.
        gw_data1-ndjar_3         =   gw_carga_excel-value.  " Duración
      WHEN 92.
        gw_data1-ndjar_4         =   gw_carga_excel-value.  " Duración
      WHEN 93.
        gw_data1-ndper_1         =   gw_carga_excel-value.  " Periodo
      WHEN 94.
        gw_data1-ndper_2         =   gw_carga_excel-value.  " Periodo
      WHEN 95.
        gw_data1-ndper_3         =   gw_carga_excel-value.  " Periodo
      WHEN 96.
        gw_data1-ndper_4         =   gw_carga_excel-value.  " Periodo
      WHEN 97.
        gw_data1-anbtr01_10      =   gw_carga_excel-value.  " Reval.contab.
      WHEN 98.
        gw_data1-anbtr01_11      =   gw_carga_excel-value.  " AmoN contab.
      WHEN 99.
        gw_data1-anbtr01_13      =   gw_carga_excel-value.  " AmoNP contab.
      WHEN 100.
        gw_data1-anbtr01_14      =   gw_carga_excel-value.  " Reserva contab.
      WHEN 101.
        gw_data1-anbtr01_15      =   gw_carga_excel-value.  " Rv.cont.AmoN.ac
      WHEN 102.
        gw_data1-anbtr03_10      =   gw_carga_excel-value.  " Reval.contab.
      WHEN 103.
        gw_data1-anbtr03_11      =   gw_carga_excel-value.  " AmoN contab.
      WHEN 104.
        gw_data1-anbtr03_13      =   gw_carga_excel-value.  " AmoNP contab.
      WHEN 105.
        gw_data1-anbtr03_14      =   gw_carga_excel-value.  " Reserva contab.
      WHEN 106.
        gw_data1-anbtr03_15      =   gw_carga_excel-value.  " Rv.cont.AmoN.ac
      WHEN 107.
        gw_data1-anbtr04_10      =   gw_carga_excel-value.  " Reval.contab.
      WHEN 108.
        gw_data1-anbtr04_11      =   gw_carga_excel-value.  " AmoN contab.
      WHEN 109.
        gw_data1-anbtr04_13      =   gw_carga_excel-value.  " AmoNP contab.
      WHEN 110.
        gw_data1-anbtr04_14      =   gw_carga_excel-value.  " Reserva contab.
      WHEN 111.
        gw_data1-anbtr04_15      =   gw_carga_excel-value.  " Rv.cont.AmoN.ac
      WHEN 112.
        gw_data1-anbtr06_10      =   gw_carga_excel-value.  " Reval.contab.
      WHEN 113.
        gw_data1-anbtr06_11      =   gw_carga_excel-value.  " AmoN contab.
      WHEN 114.
        gw_data1-anbtr06_13      =   gw_carga_excel-value.  " AmoNP contab.
      WHEN 115.
        gw_data1-anbtr06_14      =   gw_carga_excel-value.  " Reserva contab.
      WHEN 116.
        gw_data1-anbtr06_15      =   gw_carga_excel-value.  " Rv.cont.AmoN.ac
      WHEN 117.
        gw_data1-schrw_1         =   gw_carga_excel-value.  " Valor residual
      WHEN 118.
        gw_data1-schrw_pro_1     =   gw_carga_excel-value.  " Val.residual %
      WHEN 119.
        gw_data1-schrw_2         =   gw_carga_excel-value.  " Valor residual
      WHEN 120.
        gw_data1-schrw_pro_2     =   gw_carga_excel-value.  " Val.residual %
      WHEN 121.
        gw_data1-j_1aarvke_1     =   gw_carga_excel-value.  " Clv.revaloriz.
      WHEN 122.
        gw_data1-j_1aaltda_1     =   gw_carga_excel-value.  " Fe.últ.revalor.
      WHEN 123.
        gw_data1-schrw_3         =   gw_carga_excel-value.  " Valor residual
      WHEN 124.
        gw_data1-schrw_pro_3     =   gw_carga_excel-value.  " Val.residual %
      WHEN 125.
        gw_data1-j_1aarvke_2     =   gw_carga_excel-value.  " Clv.revaloriz.
      WHEN 126.
        gw_data1-j_1aaltda_2     =   gw_carga_excel-value.  " Fe.últ.revalor.
    ENDCASE.
    AT END OF row.
      APPEND gw_data1 TO gt_data1 .
      CLEAR gw_data1.
    ENDAT.
    CLEAR: gw_carga_excel.
  ENDLOOP.

ENDFORM.                    " MAPEAR_ARCHIVO1

*&---------------------------------------------------------------------*
*&      Form  MAPEAR_ARCHIVO2
*&---------------------------------------------------------------------*
FORM mapear_archivo2 .
*  CLEAR: gv_lineas.
*  DESCRIBE TABLE gt_carga_excel LINES gv_lineas.
  PERFORM indicador_progreso USING 1 'Cargando Archivo...'.
  LOOP AT gt_carga_excel INTO gw_carga_excel.
*    PERFORM indicador_progreso USING sy-tabix 'Cargando Archivo...'.
    CASE gw_carga_excel-col.
      WHEN 1.
        gw_data-anlkl           =   gw_carga_excel-value.  " Clase activos fijos
      WHEN 2.
        gw_data-bukrs           =   gw_carga_excel-value.  " Sociedad
      WHEN 3.
        gw_data-txt50           =   gw_carga_excel-value.  " Denominación
      WHEN 4.
        gw_data-txa50           =   gw_carga_excel-value.  " Denominación
      WHEN 5.
        gw_data-anlhtxt         =   gw_carga_excel-value.  " Txt.núm.pral.AF
      WHEN 6.
        gw_data-sernr           =   gw_carga_excel-value.  " Número de serie
      WHEN 7.
        gw_data-invnr           =   gw_carga_excel-value.  " Número de inventario
      WHEN 8.
        gw_data-menge           =   gw_carga_excel-value.  " Cantidad
      WHEN 9.
        gw_data-meins           =   gw_carga_excel-value.  " Unidad de medida
      WHEN 10.
        gw_data-xhist           =   gw_carga_excel-value.	" Gestion Historica                     (Flag)
      WHEN 11.
        gw_data-ivdat           = gw_carga_excel-value.   " Último inventario el
      WHEN 12.
        gw_data-inken           =   gw_carga_excel-value.	" Incluir AF en la lista de inventario  (Flag)
      WHEN 13.
        gw_data-invzu           =   gw_carga_excel-value.	" Nota de inventario
      WHEN 14.
        gw_data-aktiv           = gw_carga_excel-value.  " Capitalizado el
      WHEN 15.
        gw_data-gsber           =   gw_carga_excel-value.	" División
      WHEN 16.
        gw_data-kostl           =   gw_carga_excel-value.	" Centro de coste
      WHEN 17.
        gw_data-kostlv          =   gw_carga_excel-value.	" CeCo responsable
      WHEN 18.
        gw_data-werks           =   gw_carga_excel-value.	" Centro
      WHEN 19.
        gw_data-raumn           =   gw_carga_excel-value.	" Local
      WHEN 20.
        gw_data-kfzkz           =   gw_carga_excel-value.	" Matrícula vehículo
      WHEN 21.
        gw_data-msfak           =   gw_carga_excel-value.	" Factor turnos
      WHEN 22.
        gw_data-fkber           =   gw_carga_excel-value.	" Área funciona
      WHEN 23.
        gw_data-ord41           =   gw_carga_excel-value.	" Torre
      WHEN 24.
        gw_data-ord42           =   gw_carga_excel-value.	" Zona
      WHEN 25.
        gw_data-ord43           =   gw_carga_excel-value.	" Criterio clasif.3
      WHEN 26.
        gw_data-ord44           =   gw_carga_excel-value.	" Leasing
      WHEN 27.
        gw_data-izwek           =   gw_carga_excel-value.	" Destino inversión
      WHEN 28.
        gw_data-umwkz           =   gw_carga_excel-value.	" Inv.prot.medio amb.
      WHEN 29.
        gw_data-anlue           =   gw_carga_excel-value.	" Supranúmero de AF
      WHEN 30.
        gw_data-invsl_1         =   gw_carga_excel-value.	" Clave para el fomento de la inversión
      WHEN 31.
        gw_data-lifnr           =   gw_carga_excel-value.	" Acreedor
      WHEN 32.
        gw_data-liefe           =   gw_carga_excel-value.	" Acreedor
      WHEN 33.
        gw_data-herst           =   gw_carga_excel-value.	" Fabricante
      WHEN 34.
        gw_data-xneu_am         =   gw_carga_excel-value.	" AF comprado nuevo             (FLAG)
      WHEN 35.
        gw_data-xgbr_am         =   gw_carga_excel-value.	" Comprado 2da mano             (FLAG)
      WHEN 36.
        gw_data-land1           =   gw_carga_excel-value.	" País origen
      WHEN 37.
        gw_data-typbz           =   gw_carga_excel-value.	" Denominación de tipo
      WHEN 38.
        gw_data-aibn1           =   gw_carga_excel-value.	" Activo fijo orig.
      WHEN 39.
        gw_data-aibn2           =   gw_carga_excel-value.	" Activo fijo orig.
      WHEN 40.
        gw_data-urjhr           =   gw_carga_excel-value.	" Año adquis.orig.
      WHEN 41.
        gw_data-urwrt           =   gw_carga_excel-value.	" Valor original
      WHEN 42.
        gw_data-antei           =   gw_carga_excel-value.	" Parte prod.propia
      WHEN 43.
        gw_data-vmgli           =   gw_carga_excel-value.	" Clave agrupamiento
      WHEN 44.
        gw_data-eigkz           =   gw_carga_excel-value.	" Indicador propiedad
      WHEN 45.
        gw_data-wrtma           =   gw_carga_excel-value.	" Val.patrim.man.
      WHEN 46.
        gw_data-xvrmw           =   gw_carga_excel-value.	" Valor patrimonial manual       (FLAG)
      WHEN 47.
        gw_data-fiamt           =   gw_carga_excel-value.	" Delegación Hacienda
      WHEN 48.
        gw_data-ehwnr           =   gw_carga_excel-value.	" N.I.F. valor unit
      WHEN 49.
        gw_data-ehwzu           =   gw_carga_excel-value.	" Cartilla del
      WHEN 50.
        gw_data-stadt           =   gw_carga_excel-value.	" Municipio
      WHEN 51.
        gw_data-gruvo           =   gw_carga_excel-value.	" Reg.propiedad del
      WHEN 52.
        gw_data-grein           =   gw_carga_excel-value.	" Inscripción del
      WHEN 53.
        gw_data-grbnd           =   gw_carga_excel-value.	" Tomo/hoja/nº actual
      WHEN 54.
        gw_data-grblt           =   gw_carga_excel-value.	" Tomo/hoja/nº actual
      WHEN 55.
        gw_data-grlfd           =   gw_carga_excel-value.	" Tomo/hoja/nº actual
      WHEN 56.
        gw_data-aufla           =   gw_carga_excel-value.	" Ces.propiedad
      WHEN 57.
        gw_data-flurk           =   gw_carga_excel-value.	" Cartilla parcelaria
      WHEN 58.
        gw_data-flurn           =   gw_carga_excel-value.	" Cartilla parcelaria
      WHEN 59.
        gw_data-grufl           =   gw_carga_excel-value.	" Superficie
      WHEN 60.
        gw_data-vsstx           =   gw_carga_excel-value.	" Nº de póliza
      WHEN 61.
        gw_data-vsztx           =   gw_carga_excel-value.	" Comentario
      WHEN 62.
        gw_data-vrsbg           =   gw_carga_excel-value.	" Inicio
      WHEN 63.
        gw_data-vsind           =   gw_carga_excel-value.	" Serie de índices
      WHEN 64.
        gw_data-vrsba           =   gw_carga_excel-value.	" Valor base
      WHEN 65.
        gw_data-vsman           =   gw_carga_excel-value.	" Actualiz.man.                   (FLAG)
      WHEN 66.
        gw_data-vrsma           =   gw_carga_excel-value.	" Valor manual
      WHEN 67.
        gw_data-leafi           =   gw_carga_excel-value.	" Parte contratante
      WHEN 68.
        gw_data-lvtnr           =   gw_carga_excel-value.	" Número de contrato
      WHEN 69.
        gw_data-lvdat           =   gw_carga_excel-value.	" Fecha del contrato
      WHEN 70.
        gw_data-lkdat           =   gw_carga_excel-value.	" Fecha rescis.
      WHEN 71.
        gw_data-leabg           =   gw_carga_excel-value.	" Inicio
      WHEN 72.
        gw_data-leart           =   gw_carga_excel-value.	" Clase
      WHEN 73.
        gw_data-lbasw           =   gw_carga_excel-value.	" Valor base de nuevo
      WHEN 74.
        gw_data-lkauf           =   gw_carga_excel-value.	" Precio de compra
      WHEN 75.
        gw_data-letxt           =   gw_carga_excel-value.	" Comentario
      WHEN 76.
        gw_data-leanz           =   gw_carga_excel-value.	" Nº pagos leasing
      WHEN 77.
        gw_data-lryth           =   gw_carga_excel-value.	" Forma de pago
      WHEN 78.
        gw_data-lvors           =   gw_carga_excel-value.	" Pagos anticipados               (FLAG)
      WHEN 79.
        gw_data-legeb           =   gw_carga_excel-value.	" Cuota de leasing
      WHEN 80.
        gw_data-lzins           =   gw_carga_excel-value.	" Tp.ints.anual
      WHEN 81.
        gw_data-afasl_1         =   gw_carga_excel-value.	  " Amo 1
      WHEN 82.
        gw_data-afasl_2         =   gw_carga_excel-value.	  " Amo 2
      WHEN 83.
        gw_data-afasl_3         =   gw_carga_excel-value.	  " Amo 3
      WHEN 84.
        gw_data-afasl_4         =   gw_carga_excel-value.	  " Amo 4
      WHEN 85.
        gw_data-ndjar_1         =   gw_carga_excel-value.	" Duración 1
      WHEN 86.
        gw_data-ndjar_2         =   gw_carga_excel-value.	" Duración 2
      WHEN 87.
        gw_data-ndjar_3         =   gw_carga_excel-value.	" Duración 3
      WHEN 88.
        gw_data-ndjar_4         =   gw_carga_excel-value.	" Duración 4
      WHEN 89.
        gw_data-ndper_1         =   gw_carga_excel-value.	  " Periodo 1
      WHEN 90.
        gw_data-ndper_2         =   gw_carga_excel-value.	  " Periodo 2
      WHEN 91.
        gw_data-ndper_3         =   gw_carga_excel-value.	  " Periodo 3
      WHEN 92.
        gw_data-ndper_4         =   gw_carga_excel-value.	  " Periodo 4
      WHEN 93.
        gw_data-afabg_5         =   gw_carga_excel-value.	  " Inicio Amo Normal
      WHEN 94.
        gw_data-schrw           =   gw_carga_excel-value.	" Valor residual
      WHEN 95.
        gw_data-schrw_pro       =   gw_carga_excel-value.	" Val.residual %
      WHEN 96.
        gw_data-j_1aarvke_1     =   gw_carga_excel-value.	" Clv.revaloriz.
      WHEN 97.
        gw_data-j_1aarvke_2     =   gw_carga_excel-value.	" Clv.revaloriz.
      WHEN 98.
        gw_data-anbtr01_1       =   gw_carga_excel-value.	" Val.adq.acum.
      WHEN 99.
        gw_data-anbtr01_3       =   gw_carga_excel-value.	" Reval.acum.VR
      WHEN 100.
        gw_data-anbtr01_4       =   gw_carga_excel-value.  " Subvenc.acum.
      WHEN 101.
        gw_data-anbtr01_6       =   gw_carga_excel-value.  " AmoN acum.
      WHEN 102.
        gw_data-anbtr01_8       =   gw_carga_excel-value.  " AmoNP acum.
      WHEN 103.
        gw_data-anbtr01_9       =   gw_carga_excel-value.  " Reserva acum.
      WHEN 104.
        gw_data-anbtr01_10      =   gw_carga_excel-value.  " Rev.acum.AmoN
      WHEN 105.
        gw_data-anbtr03_1       =   gw_carga_excel-value.  " Val.adq.acum.
      WHEN 106.
        gw_data-anbtr03_3       =   gw_carga_excel-value.  " Reval.acum.VR
      WHEN 107.
        gw_data-anbtr03_4       =   gw_carga_excel-value.  " Subvenc.acum.
      WHEN 108.
        gw_data-anbtr03_6       =   gw_carga_excel-value.  " AmoN acum.
      WHEN 109.
        gw_data-anbtr03_8       =   gw_carga_excel-value.  " AmoNP acum.
      WHEN 110.
        gw_data-anbtr03_9       =   gw_carga_excel-value.  " Reserva acum.
      WHEN 111.
        gw_data-anbtr03_10      =   gw_carga_excel-value.  " Rev.acum.AmoN
      WHEN 112.
        gw_data-anbtr04_1       =   gw_carga_excel-value.  " Val.adq.acum.
      WHEN 113.
        gw_data-anbtr04_3       =   gw_carga_excel-value.  " Reval.acum.VR
      WHEN 114.
        gw_data-anbtr04_4       =   gw_carga_excel-value.  " Subvenc.acum.
      WHEN 115.
        gw_data-anbtr04_6       =   gw_carga_excel-value.  " AmoN acum.
      WHEN 116.
        gw_data-anbtr04_8       =   gw_carga_excel-value.  " AmoNP acum.
      WHEN 117.
        gw_data-anbtr04_9       =   gw_carga_excel-value.  " Reserva acum.
      WHEN 118.
        gw_data-anbtr04_10      =   gw_carga_excel-value.  " Rev.acum.AmoN
      WHEN 119.
        gw_data-anbtr06_1       =   gw_carga_excel-value.  " Val.adq.acum.
      WHEN 120.
        gw_data-anbtr06_3       =   gw_carga_excel-value.  " Reval.acum.VR
      WHEN 121.
        gw_data-anbtr06_4       =   gw_carga_excel-value.  " Subvenc.acum.
      WHEN 122.
        gw_data-anbtr06_6       =   gw_carga_excel-value.  " AmoN acum.
      WHEN 123.
        gw_data-anbtr06_8       =   gw_carga_excel-value.  " AmoNP acum.
      WHEN 124.
        gw_data-anbtr06_9       =   gw_carga_excel-value.  " Reserva acum.
      WHEN 125.
        gw_data-anbtr06_10      =   gw_carga_excel-value.  " Rev.acum.AmoN
    ENDCASE.
    AT END OF row.
      APPEND gw_data TO gt_data .
      CLEAR gw_data.
    ENDAT.
    CLEAR: gw_carga_excel.
  ENDLOOP.
ENDFORM.                    " MAPEAR_ARCHIVO
*&---------------------------------------------------------------------*
*&      Form  CREA_AF
*&---------------------------------------------------------------------*
FORM crea_af .
  DATA: lv_totalpos(6) TYPE N,
        lv_totalc(6) TYPE C,
        lv_msj  TYPE STRING.
  CLEAR: gv_pos, lv_totalpos,lv_totalc,lv_msj .
  ADD 1 to gv_pos. "linea de la cabecera del excel.
  IF cb_actua IS NOT INITIAL.
   DESCRIBE TABLE gt_data1 LINES lv_totalpos.
    IF lv_totalpos EQ 0.
      MESSAGE s899(mm) DISPLAY LIKE 'E' WITH text-m03.
      STOP.
    ELSE.
      CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
        EXPORTING
          INPUT         = lv_totalpos
       IMPORTING
         OUTPUT        = lv_totalpos.
      WRITE lv_totalpos  TO lv_totalc .
      CONCATENATE 'Creando ' lv_totalc ' AF.' INTO lv_msj SEPARATED BY space.
      PERFORM indicador_progreso USING 2 lv_msj.
      LOOP AT gt_data1 INTO gw_data1.
        ADD 1 to gv_pos.
*        PERFORM indicador_progreso USING sy-tabix 'Creando AF...'.
        PERFORM call_transaction1. " Crea AF con TX AS91 Actual
        PERFORM message_alv.      " Rescata Log de Mensaje TX AS91
      ENDLOOP.
    ENDIF.
  ELSE. " Años Anteriores
    DESCRIBE TABLE gt_data LINES lv_totalpos.
    IF lv_totalpos EQ 0.
      MESSAGE s899(mm) DISPLAY LIKE 'E' WITH text-m03.
      STOP.
    ELSE.
      CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
        EXPORTING
          INPUT         = lv_totalpos
       IMPORTING
         OUTPUT        = lv_totalpos.
      WRITE lv_totalpos  TO lv_totalc .
      CONCATENATE 'Creando ' lv_totalc ' AF.' INTO lv_msj.
      PERFORM indicador_progreso USING 2 'Creando AF...'.
      LOOP AT gt_data INTO gw_data.
        ADD 1 to gv_pos.
*        PERFORM indicador_progreso USING sy-tabix 'Creando AF...'.
        PERFORM call_transaction2. " Crea AF con TX AS91 Anterior
        PERFORM message_alv.      " Rescata Log de Mensaje TX AS91
      ENDLOOP.
    ENDIF.
  ENDIF.

ENDFORM.                    " CREA_AF
*&---------------------------------------------------------------------*
*&      Form  CALL_TRANSACTION1
*&---------------------------------------------------------------------*
FORM call_transaction1 .
  CLEAR:gtmsj, bdcdata.
  REFRESH: gtmsj, bdcdata.
  PERFORM bdc_dynpro      USING 'SAPLAIST' '0105'.
  PERFORM bdc_field       USING 'BDC_CURSOR'
                                'ANLA-BUKRS'.
  PERFORM bdc_field       USING 'BDC_OKCODE'
                                '/00'.
  PERFORM bdc_field       USING 'ANLA-ANLKL'
                                GW_DATA1-ANLKL.
  PERFORM bdc_field       USING 'ANLA-BUKRS'
                                GW_DATA1-BUKRS.
  PERFORM bdc_dynpro      USING 'SAPLAIST' '1000'.
  PERFORM bdc_field       USING 'BDC_OKCODE'
                                '=TAB02'.
  PERFORM bdc_field       USING 'BDC_CURSOR'
                                'RA02S-XHIST'.
  PERFORM bdc_field       USING 'ANLA-TXT50'
                                GW_DATA1-TXT50.
  PERFORM bdc_field       USING 'ANLA-TXA50'
                                GW_DATA1-TXA50.
  PERFORM bdc_field       USING 'ANLH-ANLHTXT'
                                GW_DATA1-ANLHTXT.
  PERFORM bdc_field       USING 'ANLA-SERNR'
                                GW_DATA1-SERNR.
  PERFORM bdc_field       USING 'ANLA-INVNR'
                                GW_DATA1-INVNR.
  PERFORM bdc_field       USING 'ANLA-MENGE'
                                GW_DATA1-MENGE.
  PERFORM bdc_field       USING 'ANLA-MEINS'
                                GW_DATA1-MEINS.
  PERFORM bdc_field       USING 'RA02S-XHIST'
                                GW_DATA1-XHIST.
  PERFORM bdc_field       USING 'ANLA-IVDAT'
                                GW_DATA1-IVDAT.
  PERFORM bdc_field       USING 'ANLA-INKEN'
                                GW_DATA1-INKEN.
  PERFORM bdc_field       USING 'ANLA-INVZU'
                                GW_DATA1-INVZU.
  PERFORM bdc_field       USING 'ANLA-AKTIV'
                                GW_DATA1-AKTIV.
  PERFORM bdc_dynpro      USING 'SAPLAIST' '1000'.
  PERFORM bdc_field       USING 'BDC_OKCODE'
                                '=TAB03'.
  PERFORM bdc_field       USING 'BDC_CURSOR'
                                'ANLZ-FKBER'.
  PERFORM bdc_field       USING 'ANLZ-GSBER'
                                GW_DATA1-GSBER.
  PERFORM bdc_field       USING 'ANLZ-KOSTL'
                                GW_DATA1-KOSTL.
  PERFORM bdc_field       USING 'ANLZ-KOSTLV'
                                GW_DATA1-KOSTLV.
  PERFORM bdc_field       USING 'ANLZ-WERKS'
                                GW_DATA1-WERKS.
  PERFORM bdc_field       USING 'ANLZ-RAUMN'
                                GW_DATA1-RAUMN.
  PERFORM bdc_field       USING 'ANLZ-KFZKZ'
                                GW_DATA1-KFZKZ.
  PERFORM bdc_field       USING 'ANLZ-MSFAK'
                                GW_DATA1-MSFAK.
  PERFORM bdc_field       USING 'ANLZ-FKBER'
                                GW_DATA1-FKBER.
  PERFORM bdc_dynpro      USING 'SAPLAIST' '1000'.
  PERFORM bdc_field       USING 'BDC_OKCODE'
                                '=TAB04'.
  PERFORM bdc_field       USING 'ANLA-ORD41'
                                GW_DATA1-ORD41.
  PERFORM bdc_field       USING 'ANLA-ORD42'
                                GW_DATA1-ORD42.
  PERFORM bdc_field       USING 'ANLA-ORD43'
                                GW_DATA1-ORD43.
  PERFORM bdc_field       USING 'ANLA-ORD44'
                                GW_DATA1-ORD44.
  PERFORM bdc_field       USING 'ANLA-GDLGRP'
                                ''.
  PERFORM bdc_field       USING 'ANLA-IZWEK'
                                GW_DATA1-IZWEK.
  PERFORM bdc_field       USING 'ANLA-UMWKZ'
                                GW_DATA1-UMWKZ.
  PERFORM bdc_field       USING 'ANLA-ANLUE'
                                GW_DATA1-ANLUE.
  PERFORM bdc_field       USING 'BDC_CURSOR'
                                'RA02S-INVSL(02)'.
  PERFORM bdc_field       USING 'RA02S-INVSL(01)'
                                GW_DATA1-INVSL_1.
  PERFORM bdc_field       USING 'RA02S-EQANZ'
                                '1'.
  PERFORM bdc_dynpro      USING 'SAPLAIST' '1000'.
  PERFORM bdc_field       USING 'BDC_OKCODE'
                                '=TAB05'.
  PERFORM bdc_field       USING 'BDC_CURSOR'
                                'ANLA-AIBDT'.
  PERFORM bdc_field       USING 'ANLA-LIFNR'
                                GW_DATA1-LIFNR.
  PERFORM bdc_field       USING 'ANLA-LIEFE'
                                GW_DATA1-LIEFE.
  PERFORM bdc_field       USING 'ANLA-HERST'
                                GW_DATA1-HERST.
  PERFORM bdc_field       USING 'RA02S-XNEU_AM'
                                GW_DATA1-XNEU_AM.
  PERFORM bdc_field       USING 'GW_DATA1-XGBR_AM'
                                GW_DATA1-XGBR_AM.
  PERFORM bdc_field       USING 'ANLA-VBUND'
                                GW_DATA1-VBUND.
  PERFORM bdc_field       USING 'ANLA-LAND1'
                                GW_DATA1-LAND1.
  PERFORM bdc_field       USING 'ANLA-TYPBZ'
                                GW_DATA1-TYPBZ.
  PERFORM bdc_field       USING 'ANLA-AIBN1'
                                GW_DATA1-AIBN1.
  PERFORM bdc_field       USING 'ANLA-AIBN2'
                                GW_DATA1-AIBN2.
  PERFORM bdc_field       USING 'ANLA-AIBDT'
                                GW_DATA1-AIBDT.
  PERFORM bdc_field       USING 'ANLA-URJHR'
                                GW_DATA1-URJHR.
  PERFORM bdc_field       USING 'ANLA-URWRT'
                                GW_DATA1-URWRT.
  PERFORM bdc_field       USING 'ANLA-ANTEI'
                                GW_DATA1-ANTEI.
  PERFORM bdc_dynpro      USING 'SAPLAIST' '1000'.
  PERFORM bdc_field       USING 'BDC_OKCODE'
                                '=TAB06'.
  PERFORM bdc_field       USING 'ANLA-VMGLI'
                                GW_DATA1-VMGLI.
  PERFORM bdc_field       USING 'ANLA-EIGKZ'
                                GW_DATA1-EIGKZ.
  PERFORM bdc_field       USING 'ANLA-GRUND'
                                ''.
  PERFORM bdc_field       USING 'ANLA-WRTMA'
                                GW_DATA1-WRTMA.
  PERFORM bdc_field       USING 'ANLA-XVRMW'
                                GW_DATA1-XVRMW.
  PERFORM bdc_field       USING 'BDC_CURSOR'
                                'ANLA-GRUFL'.
  PERFORM bdc_field       USING 'ANLA-FIAMT'
                                GW_DATA1-FIAMT.
  PERFORM bdc_field       USING 'ANLA-EHWNR'
                                GW_DATA1-EHWNR.
  PERFORM bdc_field       USING 'ANLA-EHWZU'
                                GW_DATA1-EHWZU.
  PERFORM bdc_field       USING 'ANLA-STADT'
                                GW_DATA1-STADT.
  PERFORM bdc_field       USING 'ANLA-GRUVO'
                                GW_DATA1-GRUVO.
  PERFORM bdc_field       USING 'ANLA-GREIN'
                                GW_DATA1-GREIN.
  PERFORM bdc_field       USING 'ANLA-GRBND'
                                GW_DATA1-GRBND.
  PERFORM bdc_field       USING 'ANLA-GRBLT'
                                GW_DATA1-GRBLT.
  PERFORM bdc_field       USING 'ANLA-GRLFD'
                                GW_DATA1-GRLFD.
  PERFORM bdc_field       USING 'ANLA-AUFLA'
                                GW_DATA1-AUFLA.
  PERFORM bdc_field       USING 'ANLA-FLURK'
                                GW_DATA1-FLURK.
  PERFORM bdc_field       USING 'ANLA-FLURN'
                                GW_DATA1-FLURN.
  PERFORM bdc_field       USING 'ANLA-GRUFL'
                                GW_DATA1-GRUFL.
  PERFORM bdc_dynpro      USING 'SAPLAIST' '1000'.
  PERFORM bdc_field       USING 'BDC_OKCODE'
                                '=TAB07'.
  PERFORM bdc_field       USING 'BDC_CURSOR'
                                'ANLV-VRSMA'.
  PERFORM bdc_field       USING 'ANLV-VSART'
                                ''.
  PERFORM bdc_field       USING 'ANLV-VSGES'
                                ''.
  PERFORM bdc_field       USING 'ANLV-VSSTX'
                                GW_DATA1-VSSTX.
  PERFORM bdc_field       USING 'ANLV-VSZTX'
                                GW_DATA1-VSZTX.
  PERFORM bdc_field       USING 'ANLV-VRSBG'
                                GW_DATA1-VRSBG.
  PERFORM bdc_field       USING 'ANLV-VSTAR'
                                ''.
  PERFORM bdc_field       USING 'ANLV-VSIND'
                                GW_DATA1-VSIND.
  PERFORM bdc_field       USING 'ANLV-VRSBA'
                                GW_DATA1-VRSBA.
  PERFORM bdc_field       USING 'GW_DATA1-VSMAN'
                                GW_DATA1-VSMAN.
  PERFORM bdc_field       USING 'ANLV-VRSMA'
                                GW_DATA1-VRSMA.
  PERFORM bdc_dynpro      USING 'SAPLAIST' '1000'.
  PERFORM bdc_field       USING 'BDC_OKCODE'
                                '=TAB07'.
  PERFORM bdc_field       USING 'BDC_CURSOR'
                                'ANLV-VSART'.
  PERFORM bdc_field       USING 'ANLV-VSSTX'
                                GW_DATA1-VSSTX.
  PERFORM bdc_field       USING 'ANLV-VSZTX'
                                GW_DATA1-VSZTX.
  PERFORM bdc_field       USING 'ANLV-VRSBG'
                                GW_DATA1-VRSBG.
  PERFORM bdc_field       USING 'ANLV-VSIND'
                                GW_DATA1-VSIND.
  PERFORM bdc_field       USING 'ANLV-VRSBA'
                                GW_DATA1-VRSBA.
  PERFORM bdc_field       USING 'GW_DATA1-VSMAN'
                                GW_DATA1-VSMAN.
  PERFORM bdc_field       USING 'ANLV-VRSMA'
                                GW_DATA1-VRSMA.
  PERFORM bdc_dynpro      USING 'SAPLAIST' '1000'.
  PERFORM bdc_field       USING 'BDC_OKCODE'
                                '=TAB08'.
  PERFORM bdc_field       USING 'BDC_CURSOR'
                                'ANLA-LVORS'.
  PERFORM bdc_field       USING 'ANLA-LEAFI'
                                GW_DATA1-LEAFI.
  PERFORM bdc_field       USING 'ANLA-LVTNR'
                                GW_DATA1-LVTNR.
  PERFORM bdc_field       USING 'ANLA-LVDAT'
                                GW_DATA1-LVDAT.
  PERFORM bdc_field       USING 'ANLA-LKDAT'
                                GW_DATA1-LKDAT.
  PERFORM bdc_field       USING 'ANLA-LEABG'
                                GW_DATA1-LEABG.
  PERFORM bdc_field       USING 'ANLA-LEJAR'
                                GW_DATA1-LEJAR.
  PERFORM bdc_field       USING 'ANLA-LEPER'
                                GW_DATA1-LEPER.
  PERFORM bdc_field       USING 'ANLA-LEART'
                                GW_DATA1-LEART.
  PERFORM bdc_field       USING 'ANLA-LBASW'
                                GW_DATA1-LBASW.
  PERFORM bdc_field       USING 'ANLA-LKAUF'
                                GW_DATA1-LKAUF.
  PERFORM bdc_field       USING 'ANLA-LETXT'
                                GW_DATA1-LETXT.
  PERFORM bdc_field       USING 'ANLA-LEANZ'
                                GW_DATA1-LEANZ.
  PERFORM bdc_field       USING 'ANLA-LRYTH'
                                GW_DATA1-LRYTH.
  PERFORM bdc_field       USING 'ANLA-LVORS'
                                GW_DATA1-LVORS.
  PERFORM bdc_field       USING 'ANLA-LEGEB'
                                GW_DATA1-LEGEB.
  PERFORM bdc_field       USING 'ANLA-LZINS'
                                GW_DATA1-LZINS.
  PERFORM bdc_dynpro      USING 'SAPLAIST' '1000'.
  PERFORM bdc_field       USING 'BDC_OKCODE'
                                '/00'.
  PERFORM bdc_field       USING 'BDC_CURSOR'
                                'ANLB-AFABG(04)'.
  PERFORM bdc_field       USING 'ANLB-AFASL(01)'
                                GW_DATA1-AFASL_1.
  PERFORM bdc_field       USING 'ANLB-AFASL(02)'
                                GW_DATA1-AFASL_2.
  PERFORM bdc_field       USING 'ANLB-AFASL(03)'
                                GW_DATA1-AFASL_3.
  PERFORM bdc_field       USING 'ANLB-AFASL(04)'
                                GW_DATA1-AFASL_4.
  PERFORM bdc_field       USING 'ANLB-NDJAR(01)'
                                GW_DATA1-NDJAR_1.
  PERFORM bdc_field       USING 'ANLB-NDJAR(02)'
                                GW_DATA1-NDJAR_2.
  PERFORM bdc_field       USING 'ANLB-NDJAR(03)'
                                GW_DATA1-NDJAR_3.
  PERFORM bdc_field       USING 'ANLB-NDJAR(04)'
                                GW_DATA1-NDJAR_4.
  PERFORM bdc_field       USING 'ANLB-NDPER(01)'
                                GW_DATA1-NDPER_1.
  PERFORM bdc_field       USING 'ANLB-NDPER(02)'
                                GW_DATA1-NDPER_2.
  PERFORM bdc_field       USING 'ANLB-NDPER(03)'
                                GW_DATA1-NDPER_3.
  PERFORM bdc_field       USING 'ANLB-NDPER(04)'
                                GW_DATA1-NDPER_4.
  PERFORM bdc_dynpro      USING 'SAPLAIST' '1000'.
  PERFORM bdc_field       USING 'BDC_OKCODE'
                                '/00'.
  PERFORM bdc_field       USING 'BDC_CURSOR'
                                'ANLB-AFASL(04)'.
  PERFORM bdc_field       USING 'ANLB-AFASL(04)'
                                'ZCL'.
  PERFORM bdc_dynpro      USING 'SAPLAIST' '1000'.
  PERFORM bdc_field       USING 'BDC_OKCODE'
                                '=ALTD'.
  PERFORM bdc_field       USING 'BDC_CURSOR'
                                'ANLB-AFASL(04)'.
*** ANTES COMENTADO*****

*  PERFORM bdc_dynpro      USING 'SAPLALTD' '1100'.
*  PERFORM bdc_field       USING 'BDC_OKCODE'
*                                '/00'.
*  PERFORM bdc_field       USING 'BDC_CURSOR'
*                                'RALT_DYNP_STRUC-ANBTR01(15)'.
*  PERFORM bdc_dynpro      USING 'SAPLALTD' '1100'.
*  PERFORM bdc_field       USING 'BDC_OKCODE'
*                                '/00'.
*  PERFORM bdc_field       USING 'BDC_CURSOR'
*                                'RALT_DYNP_STRUC-ANBTR01(15)'.
*  PERFORM bdc_dynpro      USING 'SAPLALTD' '1100'.
*  PERFORM bdc_field       USING 'BDC_OKCODE'
*                                '/00'.
*  PERFORM bdc_field       USING 'BDC_CURSOR'
*                                'RALT_DYNP_STRUC-ANBTR01(01)'.
*  PERFORM bdc_dynpro      USING 'SAPLALTD' '1100'.
*  PERFORM bdc_field       USING 'BDC_OKCODE'
*                                '/00'.
*  PERFORM bdc_field       USING 'BDC_CURSOR'
*                                'RALT_DYNP_STRUC-ANBTR01(14)'.
*  PERFORM bdc_dynpro      USING 'SAPLALTD' '1100'.
*  PERFORM bdc_field       USING 'BDC_OKCODE'
*                                '/00'.
*  PERFORM bdc_field       USING 'BDC_CURSOR'
*                                'RALT_DYNP_STRUC-ANBTR01(01)'.
*  PERFORM bdc_dynpro      USING 'SAPLALTD' '1100'.
*  PERFORM bdc_field       USING 'BDC_OKCODE'
*                                 '/00'.
*  PERFORM bdc_field       USING 'BDC_CURSOR'
*                                'RALT_DYNP_STRUC-ANBTR01(14)'.
*  PERFORM bdc_dynpro      USING 'SAPLALTD' '1100'.
*  PERFORM bdc_field       USING 'BDC_OKCODE'
*                                 '/00'.
*  PERFORM bdc_field       USING 'BDC_CURSOR'
*                                'RALT_DYNP_STRUC-ANBTR01(14)'.
*  PERFORM bdc_dynpro      USING 'SAPLALTD' '1100'.
*  PERFORM bdc_field       USING 'BDC_OKCODE'
*                                '/00'.
*  PERFORM bdc_field       USING 'BDC_CURSOR'
*                                'RALT_DYNP_STRUC-ANBTR06(15)'.
*  PERFORM bdc_field       USING 'RALT_DYNP_STRUC-ANBTR01(10)'
*                                GW_DATA1-ANBTR01_10.
*  PERFORM bdc_field       USING 'RALT_DYNP_STRUC-ANBTR01(11)'
*                                GW_DATA1-ANBTR01_11.
*  PERFORM bdc_field       USING 'RALT_DYNP_STRUC-ANBTR01(13)'
*                                GW_DATA1-ANBTR01_13.
*  PERFORM bdc_field       USING 'RALT_DYNP_STRUC-ANBTR01(14)'
*                                GW_DATA1-ANBTR01_14.
*  PERFORM bdc_field       USING 'RALT_DYNP_STRUC-ANBTR01(15)'
*                                GW_DATA1-ANBTR01_15.
*  PERFORM bdc_field       USING 'RALT_DYNP_STRUC-ANBTR03(10)'
*                                GW_DATA1-ANBTR03_10.
*  PERFORM bdc_field       USING 'RALT_DYNP_STRUC-ANBTR03(11)'
*                                GW_DATA1-ANBTR03_11.
*  PERFORM bdc_field       USING 'RALT_DYNP_STRUC-ANBTR03(13)'
*                                GW_DATA1-ANBTR03_13.
*  PERFORM bdc_field       USING 'RALT_DYNP_STRUC-ANBTR03(14)'
*                                GW_DATA1-ANBTR03_14.
*  PERFORM bdc_field       USING 'RALT_DYNP_STRUC-ANBTR03(15)'
*                                GW_DATA1-ANBTR03_15.
*  PERFORM bdc_field       USING 'RALT_DYNP_STRUC-ANBTR04(10)'
*                                GW_DATA1-ANBTR04_10.
*  PERFORM bdc_field       USING 'RALT_DYNP_STRUC-ANBTR04(11)'
*                                GW_DATA1-ANBTR04_11.
*  PERFORM bdc_field       USING 'RALT_DYNP_STRUC-ANBTR04(13)'
*                                GW_DATA1-ANBTR04_13.
*  PERFORM bdc_field       USING 'RALT_DYNP_STRUC-ANBTR04(14)'
*                                GW_DATA1-ANBTR04_14.
*  PERFORM bdc_field       USING 'RALT_DYNP_STRUC-ANBTR04(15)'
*                                GW_DATA1-ANBTR04_15.
*  PERFORM bdc_field       USING 'RALT_DYNP_STRUC-ANBTR06(10)'
*                                GW_DATA1-ANBTR06_10.
*  PERFORM bdc_field       USING 'RALT_DYNP_STRUC-ANBTR06(11)'
*                                GW_DATA1-ANBTR06_11.
*  PERFORM bdc_field       USING 'RALT_DYNP_STRUC-ANBTR06(13)'
*                                GW_DATA1-ANBTR06_13.
*  PERFORM bdc_field       USING 'RALT_DYNP_STRUC-ANBTR06(14)'
*                                GW_DATA1-ANBTR06_14.
*  PERFORM bdc_field       USING 'RALT_DYNP_STRUC-ANBTR06(15)'
*                                GW_DATA1-ANBTR06_15.
*********** ANTES COMENTADO*****************
*********** LOG NUEVA *****************
*  perform bdc_field       using 'BDC_CURSOR'
*                              'ANLB-NDPER(01)'.
*perform bdc_dynpro      using 'SAPLALTD' '1101'."'1100'.
*perform bdc_field       using 'BDC_OKCODE'
*                              '/00'.
*perform bdc_field       using 'BDC_CURSOR'
*                              'RALT_DYNP_STRUC-ANBTR06(16)'.
*perform bdc_field       using 'RALT_DYNP_STRUC-ANBTR01(15)'     "pos|Col
*                              GW_DATA1-ANBTR01_10." '              11'. col 1 pos 1
*perform bdc_field       using 'RALT_DYNP_STRUC-ANBTR01(16)'
*                              GW_DATA1-ANBTR03_10." '              21'. col 1 pos 2
*perform bdc_field       using 'RALT_DYNP_STRUC-ANBTR03(15)'
*                              GW_DATA1-ANBTR03_10. "'              12'. col 2 pos 1
*perform bdc_field       using 'RALT_DYNP_STRUC-ANBTR03(16)'
*                              GW_DATA1-ANBTR03_11. "'              22'. col 2 pos 2
*perform bdc_field       using 'RALT_DYNP_STRUC-ANBTR04(15)'
*                              GW_DATA1-ANBTR04_10. "'              13'. col 3 pos 1
*perform bdc_field       using 'RALT_DYNP_STRUC-ANBTR04(16)'
*                              GW_DATA1-ANBTR04_11. "'              23'. col 3 pos 2
*perform bdc_field       using 'RALT_DYNP_STRUC-ANBTR06(15)'
*                              GW_DATA1-ANBTR06_10. "'              14'. col 4 pos 1
*perform bdc_field       using 'RALT_DYNP_STRUC-ANBTR06(16)'
*                              GW_DATA1-ANBTR06_11. "'              24'. col 4 pos 2
*perform bdc_dynpro      using 'SAPLALTD' '1100'.
*perform bdc_field       using 'BDC_OKCODE'
*                              '=P+'.
*perform bdc_field       using 'BDC_CURSOR'
*                              'RALT_DYNP_STRUC-ANBTR06(04)'.
*perform bdc_field       using 'RALT_DYNP_STRUC-ANBTR01(02)'
*                              GW_DATA1-ANBTR01_13."'              31'. col 1 pos 3
*perform bdc_field       using 'RALT_DYNP_STRUC-ANBTR01(03)'
*                              GW_DATA1-ANBTR01_14."'              41'. col 1 pos 4
*perform bdc_field       using 'RALT_DYNP_STRUC-ANBTR01(04)'
*                              GW_DATA1-ANBTR01_15."'              51'. col 1 pos 5
*perform bdc_field       using 'RALT_DYNP_STRUC-ANBTR03(02)'
*                              GW_DATA1-ANBTR03_13."'              32'. col 2 pos 3
*perform bdc_field       using 'RALT_DYNP_STRUC-ANBTR03(03)'
*                              GW_DATA1-ANBTR03_14."'              42'. col 2 pos 4
*perform bdc_field       using 'RALT_DYNP_STRUC-ANBTR03(04)'
*                              GW_DATA1-ANBTR03_15."'              52'. col 2 pos 5
*perform bdc_field       using 'RALT_DYNP_STRUC-ANBTR04(02)'
*                              GW_DATA1-ANBTR04_13."'              33'. col 3 pos 3
*perform bdc_field       using 'RALT_DYNP_STRUC-ANBTR04(03)'
*                              GW_DATA1-ANBTR04_14."'              43'. col 3 pos 4
*perform bdc_field       using 'RALT_DYNP_STRUC-ANBTR04(04)'
*                              GW_DATA1-ANBTR04_15."'              53'. col 3 pos 5
*perform bdc_field       using 'RALT_DYNP_STRUC-ANBTR06(02)'
*                              GW_DATA1-ANBTR06_13."'              34'. col 4 pos 3
*perform bdc_field       using 'RALT_DYNP_STRUC-ANBTR06(03)'
*                              GW_DATA1-ANBTR06_14."'              44'. col 4 pos 4
*perform bdc_field       using 'RALT_DYNP_STRUC-ANBTR06(04)'
*                              GW_DATA1-ANBTR06_15."'              54'. col 4 pos 5
*perform bdc_dynpro      using 'SAPLALTD' '1100'.
*perform bdc_field       using 'BDC_OKCODE'
*                              '=BUCH'.
*perform bdc_field       using 'BDC_CURSOR'
*                              'RALT_DYNP_STRUC-ANBTR06(04)'.
******************************************
perform bdc_dynpro      using 'SAPLALTD' '1100'.
perform bdc_field       using 'BDC_OKCODE'
                              '=BOT'.
perform bdc_field       using 'BDC_CURSOR'
                              'RALT_DYNP_STRUC-ANBTR06(16)'.
perform bdc_field       using 'RALT_DYNP_STRUC-ANBTR01(15)'
                              GW_DATA1-ANBTR01_10."'              11'.
perform bdc_field       using 'RALT_DYNP_STRUC-ANBTR01(16)'
                              GW_DATA1-ANBTR01_11."'              21'.
perform bdc_field       using 'RALT_DYNP_STRUC-ANBTR01(18)'
                              GW_DATA1-ANBTR01_13."'              31'.
perform bdc_field       using 'RALT_DYNP_STRUC-ANBTR03(15)'
                              GW_DATA1-ANBTR03_10."'              12'.
perform bdc_field       using 'RALT_DYNP_STRUC-ANBTR03(16)'
                              GW_DATA1-ANBTR03_11."'              22'.
perform bdc_field       using 'RALT_DYNP_STRUC-ANBTR03(18)'
                              GW_DATA1-ANBTR03_13."'              32'.
perform bdc_field       using 'RALT_DYNP_STRUC-ANBTR04(15)'
                              GW_DATA1-ANBTR04_10."'              13'.
perform bdc_field       using 'RALT_DYNP_STRUC-ANBTR04(16)'
                              GW_DATA1-ANBTR04_11."'              23'.
perform bdc_field       using 'RALT_DYNP_STRUC-ANBTR04(18)'
                              GW_DATA1-ANBTR04_13."'              33'.
perform bdc_field       using 'RALT_DYNP_STRUC-ANBTR06(15)'
                              GW_DATA1-ANBTR06_10."'              14'.
perform bdc_field       using 'RALT_DYNP_STRUC-ANBTR06(16)'
                              GW_DATA1-ANBTR06_11."'              24'.
perform bdc_field       using 'RALT_DYNP_STRUC-ANBTR06(18)'
                              GW_DATA1-ANBTR06_13."'              34'.
perform bdc_dynpro      using 'SAPLALTD' '1100'.
perform bdc_field       using 'BDC_OKCODE'
                              '/00'.
perform bdc_field       using 'BDC_CURSOR'
                              'RALT_DYNP_STRUC-ANBTR06(14)'.
perform bdc_field       using 'RALT_DYNP_STRUC-ANBTR01(16)'
                              GW_DATA1-ANBTR01_14."'              41'.
perform bdc_field       using 'RALT_DYNP_STRUC-ANBTR01(17)'
                              GW_DATA1-ANBTR01_15."'              51'.
perform bdc_field       using 'RALT_DYNP_STRUC-ANBTR03(16)'
                              GW_DATA1-ANBTR03_14."'              42'.
perform bdc_field       using 'RALT_DYNP_STRUC-ANBTR03(17)'
                              GW_DATA1-ANBTR03_15."'              52'.
perform bdc_field       using 'RALT_DYNP_STRUC-ANBTR04(16)'
                              GW_DATA1-ANBTR04_14."'              43'.
perform bdc_field       using 'RALT_DYNP_STRUC-ANBTR04(17)'
                              GW_DATA1-ANBTR04_15."'              53'.
perform bdc_field       using 'RALT_DYNP_STRUC-ANBTR06(16)'
                              GW_DATA1-ANBTR06_14."'              44'.
perform bdc_field       using 'RALT_DYNP_STRUC-ANBTR06(17)'
                              GW_DATA1-ANBTR06_15."'              54'.
*********** FIN LOG NUEVA*****************
  PERFORM bdc_dynpro      USING 'SAPLALTD' '1100'.
  PERFORM bdc_field       USING 'BDC_OKCODE'
                                '=MAST'.
  PERFORM bdc_field       USING 'BDC_CURSOR'
                                'RALT_DYNP_STRUC-ANBTR06(15)'.
  PERFORM bdc_dynpro      USING 'SAPLAIST' '1000'.
  PERFORM bdc_field       USING 'BDC_OKCODE'
                                '=SELZ'.
  PERFORM bdc_field       USING 'BDC_CURSOR'
                                'T093T-AFBKTX(01)'.
  PERFORM bdc_dynpro      USING 'SAPLAIST' '0195'.
  PERFORM bdc_field       USING 'BDC_OKCODE'
                                '/00'.
  PERFORM bdc_field       USING 'BDC_CURSOR'
                                'ANLB-SCHRW_PROZ'.
  PERFORM bdc_field       USING 'ANLB-AFASL'
                                GW_DATA1-AFASL_1.  " Clave amortizacion - Afin. IFRS
  PERFORM bdc_field       USING 'ANLB-NDJAR'
                                GW_DATA1-NDJAR_1.  " Vida util - Afin. IFRS
  PERFORM bdc_field       USING 'ANLB-NDPER'
                                GW_DATA1-NDPER_1.  " Vida util - Afin. IFRS
*  PERFORM bdc_field       USING 'ANLB-AFABG'       Fecha de amortizacion normal
*                                '01.02.2013'.
  PERFORM bdc_field       USING 'ANLB-SCHRW'
                                GW_DATA1-SCHRW_1.     " Valor residual - Afin. IFRS
  PERFORM bdc_field       USING 'ANLB-SCHRW_PROZ'
                                GW_DATA1-SCHRW_PRO_1. " Valor residual % - Afin. IFRS
  PERFORM bdc_dynpro      USING 'SAPLAIST' '0195'.
  PERFORM bdc_field       USING 'BDC_OKCODE'
                                '=J1A1'.
  PERFORM bdc_field       USING 'BDC_CURSOR'
                                'ANLB-AFASL'.
  PERFORM bdc_field       USING 'ANLB-AFASL'
                                GW_DATA1-AFASL_1.   " Clave amortizacion - Afin. IFRS
  PERFORM bdc_field       USING 'ANLB-NDJAR'
                                GW_DATA1-NDJAR_1.   " Vida util - Afin. IFRS
  PERFORM bdc_field       USING 'ANLB-NDPER'
                                GW_DATA1-NDPER_1.   " Vida util - Afin. IFRS
*  PERFORM bdc_field       USING 'ANLB-AFABG'         Fecha de amortizacion normal
*                                '01.02.2013'.
  PERFORM bdc_field       USING 'ANLB-SCHRW'
                                 GW_DATA1-SCHRW_1.     " Valor residual - Afin. IFRS
  PERFORM bdc_field       USING 'ANLB-SCHRW_PROZ'
                                 GW_DATA1-SCHRW_PRO_1. " Valor residual % - Afin. IFRS
  PERFORM bdc_dynpro      USING 'SAPLAIST' '0195'.
  PERFORM bdc_field       USING 'BDC_OKCODE'
                                '=NAFA'.
  PERFORM bdc_field       USING 'BDC_CURSOR'
                                'ANLB-AFASL'.
  PERFORM bdc_field       USING 'ANLB-AFASL'
                                GW_DATA1-AFASL_1.  " Clave amortizacion - Afin. IFRS
  PERFORM bdc_field       USING 'ANLB-NDJAR'
                                GW_DATA1-NDJAR_1.  " Vida util - Afin. IFRS
  PERFORM bdc_field       USING 'ANLB-NDPER'
                                GW_DATA1-NDPER_1.  " Vida util - Afin. IFRS
*  PERFORM bdc_field       USING 'ANLB-AFABG'        Fecha de amortizacion normal
*                                '01.02.2013'.
  PERFORM bdc_field       USING 'ANLB-SCHRW'
                                GW_DATA1-SCHRW_1.     " Valor residual - Afin. IFRS
  PERFORM bdc_field       USING 'ANLB-SCHRW_PROZ'
                                GW_DATA1-SCHRW_PRO_1. " Valor residual % - Afin. IFRS
  PERFORM bdc_dynpro      USING 'SAPLAIST' '0195'.
  PERFORM bdc_field       USING 'BDC_OKCODE'
                                '=J1A1'.
  PERFORM bdc_field       USING 'BDC_CURSOR'
                                'ANLB-SCHRW_PROZ'.
  PERFORM bdc_field       USING 'ANLB-AFASL'
                                 GW_DATA1-AFASL_2.  " Clave amortizacion - Area Fiscal
  PERFORM bdc_field       USING 'ANLB-NDJAR'
                                 GW_DATA1-NDJAR_2.  " Vida util - Area Fiscal
  PERFORM bdc_field       USING 'ANLB-NDPER'
                                 GW_DATA1-NDPER_2.  " Vida util - Area Fiscal
*  PERFORM bdc_field       USING 'ANLB-AFABG'        Fecha de amortizacion normal
*                                '01.02.2013'.
  PERFORM bdc_field       USING 'ANLB-SCHRW'
                                GW_DATA1-SCHRW_2.     " Valor residual - Area Fiscal
  PERFORM bdc_field       USING 'ANLB-SCHRW_PROZ'
                                GW_DATA1-SCHRW_PRO_2. " Valor residual % - Area Fiscal
  PERFORM bdc_dynpro      USING 'SAPLJ1AB' '0100'.
  PERFORM bdc_field       USING 'BDC_CURSOR'
                                'ANLB-J_1AALTDAT'.
  PERFORM bdc_field       USING 'BDC_OKCODE'
                                '=CONT'.
  PERFORM bdc_field       USING 'ANLB-J_1AARVKEY'
                                GW_DATA1-J_1AARVKE_1.  " Clv.revaloriz. - Area Fiscal
  PERFORM bdc_field       USING 'ANLB-J_1AALTDAT'
                                GW_DATA1-J_1AALTDA_1.  " Fe.últ.revalor.- Area Fiscal
  PERFORM bdc_dynpro      USING 'SAPLAIST' '0195'.
  PERFORM bdc_field       USING 'BDC_OKCODE'
                                '=NAFA'.
  PERFORM bdc_field       USING 'BDC_CURSOR'
                                'ANLB-AFASL'.
  PERFORM bdc_field       USING 'ANLB-AFASL'
                                GW_DATA1-AFASL_2.  " Clave amortizacion - Area Fiscal
  PERFORM bdc_field       USING 'ANLB-NDJAR'
                                GW_DATA1-NDJAR_2.  " Vida util - Area Fiscal
  PERFORM bdc_field       USING 'ANLB-NDPER'
                                 GW_DATA1-NDPER_2.  " Vida util - Area Fiscal
*  PERFORM bdc_field       USING 'ANLB-AFABG'        Fecha de amortizacion normal
*                                '01.02.2013'.
  PERFORM bdc_field       USING 'ANLB-SCHRW'
                                GW_DATA1-SCHRW_2.     " Valor residual - Area Fiscal
  PERFORM bdc_field       USING 'ANLB-SCHRW_PROZ'
                                GW_DATA1-SCHRW_PRO_2. " Valor residual % - Area Fiscal
  PERFORM bdc_dynpro      USING 'SAPLAIST' '0195'.
  PERFORM bdc_field       USING 'BDC_OKCODE'
                                '/00'.
  PERFORM bdc_field       USING 'BDC_CURSOR'
                                'ANLB-SCHRW_PROZ'.
  PERFORM bdc_field       USING 'ANLB-AFASL'
                                GW_DATA1-AFASL_3.  " Clave amortizacion - GAAP CHILE
  PERFORM bdc_field       USING 'ANLB-NDJAR'
                                GW_DATA1-NDJAR_3.  " Vida util - GAAP CHILE
  PERFORM bdc_field       USING 'ANLB-NDPER'
                                GW_DATA1-NDPER_3.   " Vida util - GAAP CHILE
*  PERFORM bdc_field       USING 'ANLB-AFABG'        Fecha de amortizacion normal
*                                '01.02.2013'.
  PERFORM bdc_field       USING 'ANLB-SCHRW'
                                GW_DATA1-SCHRW_3.   " Valor residual - GAAP CHILE
  PERFORM bdc_field       USING 'ANLB-SCHRW_PROZ'
                                GW_DATA1-SCHRW_PRO_3. " Valor residual % - GAAP CHILE
  PERFORM bdc_dynpro      USING 'SAPLAIST' '0195'.
  PERFORM bdc_field       USING 'BDC_OKCODE'
                                '=J1A1'.
  PERFORM bdc_field       USING 'BDC_CURSOR'
                                'ANLB-AFASL'.
  PERFORM bdc_field       USING 'ANLB-AFASL'
                                 GW_DATA1-AFASL_3.  " Clave amortizacion - GAAP CHILE
  PERFORM bdc_field       USING 'ANLB-NDJAR'
                                GW_DATA1-NDJAR_3.  " Vida util - GAAP CHILE
  PERFORM bdc_field       USING 'ANLB-NDPER'
                                GW_DATA1-NDPER_3.   " Vida util - GAAP CHILE
*  PERFORM bdc_field       USING 'ANLB-AFABG'        Fecha de amortizacion normal
*                                '01.02.2013'.
  PERFORM bdc_field       USING 'ANLB-SCHRW'
                                GW_DATA1-SCHRW_3.   " Valor residual - GAAP CHILE
  PERFORM bdc_field       USING 'ANLB-SCHRW_PROZ'
                                GW_DATA1-SCHRW_PRO_3. " Valor residual % - GAAP CHILE
  PERFORM bdc_dynpro      USING 'SAPLJ1AB' '0100'.
  PERFORM bdc_field       USING 'BDC_CURSOR'
                                'ANLB-J_1AALTIDX'.
  PERFORM bdc_field       USING 'BDC_OKCODE'
                                '=CONT'.
  PERFORM bdc_field       USING 'ANLB-J_1AARVKEY'
                                GW_DATA1-J_1AARVKE_2. " Clv.revaloriz.  - GAAP CHILE
  PERFORM bdc_field       USING 'ANLB-J_1AALTDAT'
                                GW_DATA1-J_1AALTDA_2. " Fe.últ.revalor. - GAAP CHILE
  PERFORM bdc_dynpro      USING 'SAPLAIST' '0195'.
  PERFORM bdc_field       USING 'BDC_OKCODE'
                                '=NAFA'.
  PERFORM bdc_field       USING 'BDC_CURSOR'
                                'ANLB-AFASL'.
  PERFORM bdc_field       USING 'ANLB-AFASL'
                                 GW_DATA1-AFASL_3.  " Clave amortizacion - GAAP CHILE
  PERFORM bdc_field       USING 'ANLB-NDJAR'
                                GW_DATA1-NDJAR_3.  " Vida util - GAAP CHILE
  PERFORM bdc_field       USING 'ANLB-NDPER'
                                GW_DATA1-NDPER_3.   " Vida util - GAAP CHILE
*  PERFORM bdc_field       USING 'ANLB-AFABG'        Fecha de amortizacion normal
*                                '01.02.2013'.
  PERFORM bdc_field       USING 'ANLB-SCHRW'
                                GW_DATA1-SCHRW_3.   " Valor residual - GAAP CHILE
  PERFORM bdc_field       USING 'ANLB-SCHRW_PROZ'
                                GW_DATA1-SCHRW_PRO_3. " Valor residual % - GAAP CHILE
  PERFORM bdc_dynpro      USING 'SAPLAIST' '0195'.
  PERFORM bdc_field       USING 'BDC_OKCODE'
                                '=NAFA'.
  PERFORM bdc_field       USING 'BDC_CURSOR'
                                'ANLA-ANLN1'.
  PERFORM bdc_dynpro      USING 'SAPLAIST' '0195'.
  PERFORM bdc_field       USING 'BDC_OKCODE'
                                '=NAFA'.
  PERFORM bdc_field       USING 'BDC_CURSOR'
                                'ANLA-ANLN1'.
  PERFORM bdc_dynpro      USING 'SAPLAIST' '0195'.
  PERFORM bdc_field       USING 'BDC_OKCODE'
                                '=ALTD'.
  PERFORM bdc_field       USING 'BDC_CURSOR'
                                'ANLB-SCHRW'.
  PERFORM bdc_dynpro      USING 'SAPLALTD' '1100'.
  PERFORM bdc_field       USING 'BDC_OKCODE'
                                '=BUCH'.
  PERFORM bdc_field       USING 'BDC_CURSOR'
                                'RALT_DYNP_STRUC-ANBTR04(10)'.
  CALL TRANSACTION 'AS91' USING bdcdata MODE gv_mode MESSAGES INTO gtmsj.
ENDFORM.                    " CALL_TRANSACTION1
*&---------------------------------------------------------------------*
*&      Form  CALL_TRANSACTION2
*&---------------------------------------------------------------------*
FORM call_transaction2 .
  CLEAR:gtmsj, bdcdata.
  REFRESH: gtmsj, bdcdata.

  PERFORM bdc_dynpro      USING 'SAPLAIST' '0105'.
  PERFORM bdc_field       USING 'BDC_CURSOR'
                                'ANLA-BUKRS'.
  PERFORM bdc_field       USING 'BDC_OKCODE'
                                '/00'.
  PERFORM bdc_field       USING 'ANLA-ANLKL'
                                gw_data-anlkl.
  PERFORM bdc_field       USING 'ANLA-BUKRS'
                                gw_data-bukrs.
  PERFORM bdc_dynpro      USING 'SAPLAIST' '1000'.
  PERFORM bdc_field       USING 'BDC_OKCODE'
                                '=TAB02'.
  PERFORM bdc_field       USING 'ANLA-TXT50'
                                gw_data-txt50.
  PERFORM bdc_field       USING 'ANLA-TXA50'
                                gw_data-txa50.
  PERFORM bdc_field       USING 'ANLH-ANLHTXT'
                                gw_data-anlhtxt.
  PERFORM bdc_field       USING 'ANLA-SERNR'
                                gw_data-sernr.
  PERFORM bdc_field       USING 'ANLA-INVNR'
                                gw_data-invnr.
  PERFORM bdc_field       USING 'ANLA-MENGE'
                                gw_data-menge.
  PERFORM bdc_field       USING 'ANLA-MEINS'
                                gw_data-meins.
  PERFORM bdc_field       USING 'RA02S-XHIST'            " FLAG
                                gw_data-xhist.           " Gestion Historica
  PERFORM bdc_field       USING 'ANLA-IVDAT'
                                gw_data-ivdat.
  PERFORM bdc_field       USING 'ANLA-INKEN'            " FLAG
                                gw_data-inken.          "  Incluir AF en la lista de inventario
  PERFORM bdc_field       USING 'ANLA-INVZU'
                                gw_data-invzu.
  PERFORM bdc_field       USING 'BDC_CURSOR'
                                'ANLA-AKTIV'.
  PERFORM bdc_field       USING 'ANLA-AKTIV'
                                gw_data-aktiv.
  PERFORM bdc_dynpro      USING 'SAPLAIST' '1000'.
  PERFORM bdc_field       USING 'BDC_OKCODE'
                                '=TAB03'.
  PERFORM bdc_field       USING 'BDC_CURSOR'
                                'ANLZ-FKBER'.
  PERFORM bdc_field       USING 'ANLZ-GSBER'
                                gw_data-gsber.
  PERFORM bdc_field       USING 'ANLZ-KOSTL'
                                gw_data-kostl.
  PERFORM bdc_field       USING 'ANLZ-KOSTLV'
                                gw_data-kostlv.
  PERFORM bdc_field       USING 'ANLZ-LSTAR'
                                ''.
  PERFORM bdc_field       USING 'ANLZ-CAUFN'
                                ''.
  PERFORM bdc_field       USING 'ANLZ-WERKS'
                                gw_data-werks.
  PERFORM bdc_field       USING 'ANLZ-STORT'
                                ''.
  PERFORM bdc_field       USING 'ANLZ-RAUMN'
                                gw_data-raumn.
  PERFORM bdc_field       USING 'ANLZ-KFZKZ'
                                gw_data-kfzkz.
  PERFORM bdc_field       USING 'ANLZ-PERNR'
                                ''.
  PERFORM bdc_field       USING 'ANLZ-MSFAK'
                                gw_data-msfak.
  PERFORM bdc_field       USING 'ANLZ-FKBER'
                                gw_data-fkber.
  PERFORM bdc_dynpro      USING 'SAPLAIST' '1000'.
  PERFORM bdc_field       USING 'BDC_OKCODE'
                                '=TAB04'.
  PERFORM bdc_field       USING 'ANLA-ORD41'
                                gw_data-ord41.
  PERFORM bdc_field       USING 'ANLA-ORD42'
                                gw_data-ord42.
  PERFORM bdc_field       USING 'ANLA-ORD43'
                                gw_data-ord43.
  PERFORM bdc_field       USING 'ANLA-ORD44'
                                gw_data-ord44.
  PERFORM bdc_field       USING 'ANLA-IZWEK'
                                gw_data-izwek.
  PERFORM bdc_field       USING 'ANLA-UMWKZ'
                                gw_data-umwkz.
  PERFORM bdc_field       USING 'ANLA-ANLUE'
                                gw_data-anlue.
  PERFORM bdc_field       USING 'BDC_CURSOR'
                                'RA02S-INVSL(02)'.
  PERFORM bdc_field       USING 'RA02S-INVSL(01)'
                                gw_data-invsl_1.
  PERFORM bdc_field       USING 'RA02S-EQANZ'
                                '1'.
  PERFORM bdc_dynpro      USING 'SAPLAIST' '1000'.
  PERFORM bdc_field       USING 'BDC_OKCODE'
                                '=TAB05'.
  PERFORM bdc_field       USING 'BDC_CURSOR'
                                'ANLA-ANTEI'.
  PERFORM bdc_field       USING 'ANLA-LIFNR'
                                 gw_data-lifnr.
  PERFORM bdc_field       USING 'ANLA-LIEFE'
                                gw_data-liefe.
  PERFORM bdc_field       USING 'ANLA-HERST'
                                gw_data-herst.
  PERFORM bdc_field       USING 'RA02S-XNEU_AM'            " FLAG
                                gw_data-xneu_am.           " AF Comprado Nuevo
  PERFORM bdc_field       USING 'ANLA-LAND1'
                                gw_data-land1.
  PERFORM bdc_field       USING 'ANLA-TYPBZ'
                                gw_data-typbz.
  PERFORM bdc_field       USING 'ANLA-AIBN1'
                                gw_data-aibn1.
  PERFORM bdc_field       USING 'ANLA-AIBN2'
                                gw_data-aibn2.
  PERFORM bdc_field       USING 'ANLA-URJHR'
                                gw_data-urjhr.
  PERFORM bdc_field       USING 'ANLA-URWRT'
                                gw_data-urwrt.
  PERFORM bdc_field       USING 'ANLA-ANTEI'
                                gw_data-antei.
  PERFORM bdc_dynpro      USING 'SAPLAIST' '1000'.
  PERFORM bdc_field       USING 'BDC_OKCODE'
                                '=TAB06'.
  PERFORM bdc_field       USING 'ANLA-VMGLI'
                                gw_data-vmgli.
  PERFORM bdc_field       USING 'ANLA-EIGKZ'
                                gw_data-eigkz.
  PERFORM bdc_field       USING 'ANLA-WRTMA'
                                gw_data-wrtma.
  PERFORM bdc_field       USING 'ANLA-XVRMW'            " FLAG
                                gw_data-xvrmw.          " Valor Patrimonial Manual
  PERFORM bdc_field       USING 'BDC_CURSOR'
                                'ANLA-GRUVO'.
  PERFORM bdc_field       USING 'ANLA-FIAMT'
                                gw_data-fiamt.
  PERFORM bdc_field       USING 'ANLA-EHWNR'
                                gw_data-ehwnr.
  PERFORM bdc_field       USING 'ANLA-EHWZU'
                                gw_data-ehwzu.
  PERFORM bdc_field       USING 'ANLA-STADT'
                                gw_data-stadt.
  PERFORM bdc_field       USING 'ANLA-GRUVO'
                                gw_data-gruvo.
  PERFORM bdc_field       USING 'ANLA-GREIN'
                                gw_data-grein.
  PERFORM bdc_field       USING 'ANLA-GRBND'
                                gw_data-grbnd.
  PERFORM bdc_field       USING 'ANLA-GRBLT'
                                gw_data-grblt.
  PERFORM bdc_field       USING 'ANLA-GRLFD'
                                gw_data-grlfd.
  PERFORM bdc_field       USING 'ANLA-AUFLA'
                                gw_data-aufla.
  PERFORM bdc_field       USING 'ANLA-FLURK'
                                gw_data-flurk.
  PERFORM bdc_field       USING 'ANLA-FLURN'
                                gw_data-flurn.
  PERFORM bdc_field       USING 'ANLA-GRUFL'
                                gw_data-grufl.
  PERFORM bdc_dynpro      USING 'SAPLAIST' '1000'.
  PERFORM bdc_field       USING 'BDC_OKCODE'
                                '/00'.
  PERFORM bdc_field       USING 'BDC_CURSOR'
                                'ANLV-VRSMA'.
  PERFORM bdc_field       USING 'ANLV-VSSTX'
                                gw_data-vsstx.
  PERFORM bdc_field       USING 'ANLV-VSZTX'
                                gw_data-vsztx.
  PERFORM bdc_field       USING 'ANLV-VRSBG'
                                gw_data-vrsbg.
  PERFORM bdc_field       USING 'ANLV-VSTAR'
                                ''.
  PERFORM bdc_field       USING 'ANLV-VSIND'
                                gw_data-vsind.
  PERFORM bdc_field       USING 'ANLV-VRSBA'
                                gw_data-vrsba.
  PERFORM bdc_field       USING 'ANLV-VSMAN'        " Flag Agregado
                                gw_data-vsman.      " Actualiz.man.
  PERFORM bdc_field       USING 'ANLV-VRSMA'
                                gw_data-vrsma.
  PERFORM bdc_dynpro      USING 'SAPLAIST' '1000'.
  PERFORM bdc_field       USING 'BDC_OKCODE'
                                '=TAB07'.
  PERFORM bdc_field       USING 'BDC_CURSOR'
                                'ANLV-VSART'.
  PERFORM bdc_field       USING 'ANLV-VSSTX'
                                gw_data-vsstx.
  PERFORM bdc_field       USING 'ANLV-VSZTX'
                                gw_data-vsztx.
  PERFORM bdc_field       USING 'ANLV-VRSBG'
                                gw_data-vrsbg.
  PERFORM bdc_field       USING 'ANLV-VSIND'
                                gw_data-vsind.
  PERFORM bdc_field       USING 'ANLV-VRSBA'
                                gw_data-vrsba.
  PERFORM bdc_field       USING 'ANLV-VRSMA'
                                gw_data-vrsma.
  PERFORM bdc_dynpro      USING 'SAPLAIST' '1000'.
  PERFORM bdc_field       USING 'BDC_OKCODE'
                                '=TAB08'.
  PERFORM bdc_field       USING 'BDC_CURSOR'
                                'RA02S-LBARW'.
  PERFORM bdc_field       USING 'ANLA-LEAFI'
                                gw_data-leafi.
  PERFORM bdc_field       USING 'ANLA-LVTNR'
                                gw_data-lvtnr.
  PERFORM bdc_field       USING 'ANLA-LVDAT'
                                gw_data-lvdat.
  PERFORM bdc_field       USING 'ANLA-LKDAT'
                                gw_data-lkdat.
  PERFORM bdc_field       USING 'ANLA-LEABG'
                                gw_data-leabg.
  PERFORM bdc_field       USING 'ANLA-LEART'
                                gw_data-leart.
  PERFORM bdc_field       USING 'ANLA-LBASW'
                                gw_data-lbasw.
  PERFORM bdc_field       USING 'ANLA-LKAUF'
                                gw_data-lkauf.
  PERFORM bdc_field       USING 'ANLA-LETXT'
                                gw_data-letxt.
  PERFORM bdc_field       USING 'ANLA-LEANZ'
                                gw_data-leanz.
  PERFORM bdc_field       USING 'ANLA-LRYTH'
                                gw_data-lryth.
  PERFORM bdc_field       USING 'ANLA-LVORS'          " Flag Agregado
                                gw_data-lvors.        " Pagos anticipados
  PERFORM bdc_field       USING 'ANLA-LEGEB'
                                gw_data-legeb.
  PERFORM bdc_field       USING 'ANLA-LZINS'
                                gw_data-lzins.
  PERFORM bdc_dynpro      USING 'SAPLAIST' '1000'.
  PERFORM bdc_field       USING 'BDC_OKCODE'
                                '/00'.
  PERFORM bdc_field       USING 'BDC_CURSOR'
                                'ANLB-AFABG(04)'.
  PERFORM bdc_field       USING 'ANLB-AFASL(01)'
                                gw_data-afasl_1.
  PERFORM bdc_field       USING 'ANLB-AFASL(02)'
                                gw_data-afasl_2.
  PERFORM bdc_field       USING 'ANLB-AFASL(03)'
                                gw_data-afasl_3.
  PERFORM bdc_field       USING 'ANLB-AFASL(04)'
                                gw_data-afasl_4.
  PERFORM bdc_field       USING 'ANLB-NDJAR(01)'
                                gw_data-ndjar_1.
  PERFORM bdc_field       USING 'ANLB-NDJAR(02)'
                                gw_data-ndjar_2.
  PERFORM bdc_field       USING 'ANLB-NDJAR(03)'
                                gw_data-ndjar_3.
  PERFORM bdc_field       USING 'ANLB-NDJAR(04)'
                                gw_data-ndjar_4.
  PERFORM bdc_field       USING 'ANLB-NDPER(01)'
                                gw_data-ndper_1.
  PERFORM bdc_field       USING 'ANLB-NDPER(02)'
                                gw_data-ndper_2.
  PERFORM bdc_field       USING 'ANLB-NDPER(03)'
                                gw_data-ndper_3.
  PERFORM bdc_field       USING 'ANLB-NDPER(04)'
                                gw_data-ndper_4.
  PERFORM bdc_field       USING 'ANLB-AFABG(02)'
                                gw_data-afabg_5.
  PERFORM bdc_dynpro      USING 'SAPLAIST' '1000'.
  PERFORM bdc_field       USING 'BDC_OKCODE'
                                '/00'.
  PERFORM bdc_field       USING 'BDC_CURSOR'
                                'ANLB-AFASL(02)'.
  PERFORM bdc_dynpro      USING 'SAPLAIST' '1000'.
  PERFORM bdc_field       USING 'BDC_OKCODE'
                                'TAB08'.
  PERFORM bdc_field       USING 'BDC_CURSOR'
                                'ANLB-AFABG(02)'.
  PERFORM bdc_field       USING 'ANLB-AFABG(02)'
                                gw_data-afabg_5.   " Vuelve a ingresar la misma fecha!
  PERFORM bdc_field       USING 'ANLC-NDABJ(02)'
                                ''.
  PERFORM bdc_dynpro      USING 'SAPLAIST' '1000'.
  PERFORM bdc_field       USING 'BDC_OKCODE'
                                '=SELZ'.
  PERFORM bdc_field       USING 'BDC_CURSOR'
                                'T093T-AFBKTX(01)'. " modificar Calve de amortizacion a 01 ANT(02) - AFIN.IFRS 19.06.2013
  PERFORM bdc_dynpro      USING 'SAPLAIST' '0195'.
  PERFORM bdc_field       USING 'BDC_OKCODE'
                                '/00'.
  PERFORM bdc_field       USING 'BDC_CURSOR'
                                'ANLB-SCHRW_PROZ'.
  PERFORM bdc_field       USING 'ANLB-AFASL'
                                gw_data-afasl_1.    "mod x 01 " 2da linea(Area Fiscal)-Clave de amortizacion
  PERFORM bdc_field       USING 'ANLB-NDJAR'
                                gw_data-ndjar_1.    "mod x 01 " 2da linea(Area Fiscal)-Vida Util
  PERFORM bdc_field       USING 'ANLB-NDPER'
                                gw_data-ndper_1.    "mod x 01 " 2da linea(Area Fiscal)-Vida Util
  PERFORM bdc_field       USING 'ANLB-AFABG'
                                gw_data-afabg_5.    "mod x 01 " 2da linea(Area Fiscal)-Amortizacion normal
  PERFORM bdc_field       USING 'ANLB-SCHRW'
                                gw_data-schrw.       " Excel(Area Fiscal)-Valor residual
  PERFORM bdc_field       USING 'ANLB-SCHRW_PROZ'
                                gw_data-schrw_pro.   " Excel(Area Fiscal)-Valor residual %
  PERFORM bdc_dynpro      USING 'SAPLAIST' '0195'.
  PERFORM bdc_field       USING 'BDC_OKCODE'
                                '=J1A1'.
  PERFORM bdc_field       USING 'BDC_CURSOR'
                                'ANLB-AFASL'.
  PERFORM bdc_field       USING 'ANLB-AFASL'
                                gw_data-afasl_1.    "mod x 01  " 2da linea(Area Fiscal)-Clave de amortizacion
  PERFORM bdc_field       USING 'ANLB-NDJAR'
                                 gw_data-ndjar_1.   "mod x 01   " 2da linea(Area Fiscal)-Vida Util
  PERFORM bdc_field       USING 'ANLB-NDPER'
                                gw_data-ndper_1.    "mod x 01  " 2da linea(Area Fiscal)-Vida Util
  PERFORM bdc_field       USING 'ANLB-AFABG'
                                gw_data-afabg_5.     " 2da linea(Area Fiscal)-Amortizacion normal
  PERFORM bdc_field       USING 'ANLB-SCHRW'
                                gw_data-schrw.       " Excel(Area Fiscal)-Valor residual
  PERFORM bdc_field       USING 'ANLB-SCHRW_PROZ'
                                 gw_data-schrw_pro.  " Excel(Area Fiscal)-Valor residual %
*  PERFORM bdc_dynpro      USING 'SAPLJ1AB' '0100'. "comentado para pruebas
*  PERFORM bdc_field       USING 'BDC_CURSOR'
*                                'ANLB-J_1AARVKEY'.
*  PERFORM bdc_field       USING 'BDC_OKCODE'
*                                '=CONT'.
*  PERFORM bdc_field       USING 'ANLB-J_1AARVKEY'
*                               gw_data-j_1aarvke_1.  " Excel(Area Fiscal)-Clave de revalorizacion "comentado para pruebas
  PERFORM bdc_dynpro      USING 'SAPLAIST' '0195'.
  PERFORM bdc_field       USING 'BDC_OKCODE'
                                '=NAFA'.
  PERFORM bdc_field       USING 'BDC_CURSOR'
                                'ANLB-AFASL'.
  PERFORM bdc_field       USING 'ANLB-AFASL'
                                gw_data-afasl_1.     "mod x 01 " 2da linea(Area Fiscal)-Clave de amortizacion
  PERFORM bdc_field       USING 'ANLB-NDJAR'
                                 gw_data-ndjar_1.     "mod x 01 " 2da linea(Area Fiscal)-Vida Util
  PERFORM bdc_field       USING 'ANLB-NDPER'
                                gw_data-ndper_1.     "mod x 01 " 2da linea(Area Fiscal)-Vida Util
  PERFORM bdc_field       USING 'ANLB-AFABG'
                                gw_data-afabg_5.     " 2da linea(Area Fiscal)-Amortizacion normal
  PERFORM bdc_field       USING 'ANLB-SCHRW'
                                gw_data-schrw.       " Excel(Area Fiscal)-Valor residual
  PERFORM bdc_field       USING 'ANLB-SCHRW_PROZ'
                                gw_data-schrw_pro.  " Excel(Area Fiscal)-Valor residual %
  PERFORM bdc_dynpro      USING 'SAPLAIST' '0195'.
  PERFORM bdc_field       USING 'BDC_OKCODE'
                                '=J1A1'.
  PERFORM bdc_field       USING 'BDC_CURSOR'
                                'ANLB-AFASL'.
  PERFORM bdc_field       USING 'ANLB-AFASL'
                                gw_data-afasl_2.     "mod x 02 " 3ra linea(GAAP Chile)-Clave de amortizacion
  PERFORM bdc_field       USING 'ANLB-NDJAR'
                                 gw_data-ndjar_2.    "mod x 02 " 3ra linea(GAAP Chile)-Vida Util
  PERFORM bdc_field       USING 'ANLB-NDPER'
                                gw_data-ndper_2.     "mod x 02 " 3ra linea(GAAP Chile)-Vida Util
  PERFORM bdc_field       USING 'ANLB-AFABG'
                                gw_data-afabg_5.     " 2da linea(GAAP Chile)-Amortizacion normal
  PERFORM bdc_dynpro      USING 'SAPLJ1AB' '0100'.
  PERFORM bdc_field       USING 'BDC_CURSOR'
                                'ANLB-J_1AARVKEY'.
  PERFORM bdc_field       USING 'BDC_OKCODE'
                                '=CONT'.
  PERFORM bdc_field       USING 'ANLB-J_1AARVKEY'
                                gw_data-j_1aarvke_1. " Mod a 1 de 2" Excel(GAAP Chile)-Clave de revalorizacion
  PERFORM bdc_dynpro      USING 'SAPLAIST' '0195'.
  PERFORM bdc_field       USING 'BDC_OKCODE'
                                '=NAFA'."'=ALTD'.
  PERFORM bdc_field       USING 'BDC_CURSOR'
                                'ANLB-AFASL'.
  PERFORM bdc_field       USING 'ANLB-AFASL'
                                gw_data-afasl_2.    "mod x 02 " 3ra linea(GAAP Chile)-Clave de amortizacion
  PERFORM bdc_field       USING 'ANLB-NDJAR'
                                gw_data-ndjar_2.    "mod x 02 " 3ra linea(GAAP Chile)-Vida Util
  PERFORM bdc_field       USING 'ANLB-NDPER'
                                gw_data-ndper_2.    "mod x 02 " 3ra linea(GAAP Chile)-Vida Util
  PERFORM bdc_field       USING 'ANLB-AFABG'
                                gw_data-afabg_5.     " 2da linea(GAAP Chile)-Amortizacion normal
** Codigo nuevo agregado para pruebas
PERFORM bdc_dynpro      USING 'SAPLAIST' '0195'.
  PERFORM bdc_field       USING 'BDC_OKCODE'
                                '=J1A1'.
  PERFORM bdc_field       USING 'BDC_CURSOR'
                                'ANLB-AFASL'.
  PERFORM bdc_field       USING 'ANLB-AFASL'
                                gw_data-afasl_3.     "mod x 02 " 3ra linea(GAAP Chile)-Clave de amortizacion
  PERFORM bdc_field       USING 'ANLB-NDJAR'
                                 gw_data-ndjar_3.    "mod x 02 " 3ra linea(GAAP Chile)-Vida Util
  PERFORM bdc_field       USING 'ANLB-NDPER'
                                gw_data-ndper_3.     "mod x 02 " 3ra linea(GAAP Chile)-Vida Util
  PERFORM bdc_field       USING 'ANLB-AFABG'
                                gw_data-afabg_5.     " 2da linea(GAAP Chile)-Amortizacion normal
  PERFORM bdc_dynpro      USING 'SAPLJ1AB' '0100'.
  PERFORM bdc_field       USING 'BDC_CURSOR'
                                'ANLB-J_1AARVKEY'.
  PERFORM bdc_field       USING 'BDC_OKCODE'
                                '=CONT'.
  PERFORM bdc_field       USING 'ANLB-J_1AARVKEY'
                                gw_data-j_1aarvke_2. " Mod a 1 de 2" Excel(GAAP Chile)-Clave de revalorizacion
  PERFORM bdc_dynpro      USING 'SAPLAIST' '0195'.
  PERFORM bdc_field       USING 'BDC_OKCODE'
                                '=ALTD'.
  PERFORM bdc_field       USING 'BDC_CURSOR'
                                'ANLB-AFASL'.
  PERFORM bdc_field       USING 'ANLB-AFASL'
                                gw_data-afasl_3.    "mod x 02 " 3ra linea(GAAP Chile)-Clave de amortizacion
  PERFORM bdc_field       USING 'ANLB-NDJAR'
                                gw_data-ndjar_3.    "mod x 02 " 3ra linea(GAAP Chile)-Vida Util
  PERFORM bdc_field       USING 'ANLB-NDPER'
                                gw_data-ndper_3.    "mod x 02 " 3ra linea(GAAP Chile)-Vida Util
  PERFORM bdc_field       USING 'ANLB-AFABG'
                                gw_data-afabg_5.     " 2da linea(GAAP Chile)-Amortizacion normal
** Fin Codigo para pruebas
  PERFORM bdc_dynpro      USING 'SAPLALTD' '1100'.
  PERFORM bdc_field       USING 'BDC_OKCODE'
                                '/00'.
  PERFORM bdc_field       USING 'BDC_CURSOR'
                                'RALT_DYNP_STRUC-ANBTR06(10)'.
***           Columna: 01 Afin.IFRS CLP
  PERFORM bdc_field       USING 'RALT_DYNP_STRUC-ANBTR01(01)'
                                gw_data-anbtr01_1.  " Val.adq.acum.
  PERFORM bdc_field       USING 'RALT_DYNP_STRUC-ANBTR01(03)'
                                gw_data-anbtr01_3.  " Reval.acum.VR
  PERFORM bdc_field       USING 'RALT_DYNP_STRUC-ANBTR01(04)'
                                gw_data-anbtr01_4.  " Subvenc.acum.
  PERFORM bdc_field       USING 'RALT_DYNP_STRUC-ANBTR01(06)'
                                gw_data-anbtr01_6.  " AmoN acum.
  PERFORM bdc_field       USING 'RALT_DYNP_STRUC-ANBTR01(08)'
                                gw_data-anbtr01_8.  " AmoNP acum.
  PERFORM bdc_field       USING 'RALT_DYNP_STRUC-ANBTR01(09)'
                                gw_data-anbtr01_9.  " Reserva acum.
  PERFORM bdc_field       USING 'RALT_DYNP_STRUC-ANBTR01(10)'
                                gw_data-anbtr01_10. " Rev.acum.AmoN
***          Columna: 05 Area Fiscal CLP
  PERFORM bdc_field       USING 'RALT_DYNP_STRUC-ANBTR03(01)'
                                gw_data-anbtr03_1.  " Val.adq.acum.
  PERFORM bdc_field       USING 'RALT_DYNP_STRUC-ANBTR03(03)'
                                gw_data-anbtr03_3.  " Reval.acum.VR
  PERFORM bdc_field       USING 'RALT_DYNP_STRUC-ANBTR03(04)'
                                gw_data-anbtr03_4.  " Subvenc.acum.
  PERFORM bdc_field       USING 'RALT_DYNP_STRUC-ANBTR03(06)'
                                gw_data-anbtr03_6.  " AmoN acum.
  PERFORM bdc_field       USING 'RALT_DYNP_STRUC-ANBTR03(08)'
                                gw_data-anbtr03_8.  " AmoNP acum.
  PERFORM bdc_field       USING 'RALT_DYNP_STRUC-ANBTR03(09)'
                                gw_data-anbtr03_9.  " Reserva acum.
  PERFORM bdc_field       USING 'RALT_DYNP_STRUC-ANBTR03(10)'
                                gw_data-anbtr03_10. " Rev.acum.AmoN
***            Columna: 10 GAAP CHILE CLP
  PERFORM bdc_field       USING 'RALT_DYNP_STRUC-ANBTR04(01)'
                                gw_data-anbtr04_1.  " Val.adq.acum.
  PERFORM bdc_field       USING 'RALT_DYNP_STRUC-ANBTR04(03)'
                                gw_data-anbtr04_3.  " Reval.acum.VR
  PERFORM bdc_field       USING 'RALT_DYNP_STRUC-ANBTR04(04)'
                                gw_data-anbtr04_4.  " Subvenc.acum.
  PERFORM bdc_field       USING 'RALT_DYNP_STRUC-ANBTR04(06)'
                                gw_data-anbtr04_6.  " AmoN acum.
  PERFORM bdc_field       USING 'RALT_DYNP_STRUC-ANBTR04(08)'
                                gw_data-anbtr04_8.  " AmoNP acum.
  PERFORM bdc_field       USING 'RALT_DYNP_STRUC-ANBTR04(09)'
                                gw_data-anbtr04_9.  " Reserva acum.
  PERFORM bdc_field       USING 'RALT_DYNP_STRUC-ANBTR04(10)'
                                gw_data-anbtr04_10. " Rev.acum.AmoN
***          Columna: 50 Area ME USD USD
  PERFORM bdc_field       USING 'RALT_DYNP_STRUC-ANBTR06(01)'
                                gw_data-anbtr06_1.  " Val.adq.acum.
  PERFORM bdc_field       USING 'RALT_DYNP_STRUC-ANBTR06(03)'
                                gw_data-anbtr06_3.  " Reval.acum.VR
  PERFORM bdc_field       USING 'RALT_DYNP_STRUC-ANBTR06(04)'
                                gw_data-anbtr06_4.  " Subvenc.acum.
  PERFORM bdc_field       USING 'RALT_DYNP_STRUC-ANBTR06(06)'
                                gw_data-anbtr06_6.  " AmoN acum.
  PERFORM bdc_field       USING 'RALT_DYNP_STRUC-ANBTR06(08)'
                                gw_data-anbtr06_8.  " AmoNP acum.
  PERFORM bdc_field       USING 'RALT_DYNP_STRUC-ANBTR06(09)'
                                gw_data-anbtr06_9.  " Reserva acum.
  PERFORM bdc_field       USING 'RALT_DYNP_STRUC-ANBTR06(10)'
                                gw_data-anbtr06_10. " Rev.acum.AmoN
  PERFORM bdc_dynpro      USING 'SAPLALTD' '1100'.
  PERFORM bdc_field       USING 'BDC_OKCODE'
                                '=MAST'.
  PERFORM bdc_field       USING 'BDC_CURSOR'
                                'RALT_DYNP_STRUC-ANBTR06(10)'.
  PERFORM bdc_dynpro      USING 'SAPLAIST' '1000'.
  PERFORM bdc_field       USING 'BDC_OKCODE'
                                '=BUCH'.
  PERFORM bdc_field       USING 'BDC_CURSOR'
                                'ANLB-AFASL(01)'.
  CALL TRANSACTION 'AS91' USING bdcdata MODE gv_mode MESSAGES INTO gtmsj.

ENDFORM.                    " CALL_TRANSACTION
*&---------------------------------------------------------------------*
*&      Form  BDC_DYNPRO
*&---------------------------------------------------------------------*
FORM bdc_dynpro USING program dynpro.
  CLEAR bdcdata.
  bdcdata-program  = program.
  bdcdata-dynpro   = dynpro.
  bdcdata-dynbegin = c_x.
  APPEND bdcdata.
ENDFORM.                    "BDC_DYNPRO
*&---------------------------------------------------------------------*
*&      Form  BDC_FIELD
*&---------------------------------------------------------------------*
FORM bdc_field USING fnam fval.
  IF fval IS NOT INITIAL.
    CLEAR bdcdata.
    bdcdata-fnam = fnam.
    bdcdata-fval = fval.
    APPEND bdcdata.
  ELSEIF ( fnam EQ 'RA02S-XHIST' )   OR ( fnam EQ 'ANLA-INKEN' ) OR ( fnam EQ 'RA02S-XNEU_AM' )
      OR ( fnam EQ 'RA02S-XGBR_AM' ) OR ( fnam EQ 'ANLA-XVRMW' ) OR ( fnam EQ 'ANLV-VSMAN' )
      OR ( fnam EQ 'ANLA-LVORS' ).
    bdcdata-fnam = fnam.
    bdcdata-fval = fval.
    APPEND bdcdata.
  ENDIF.
ENDFORM.                    "BDC_FIELD
*&---------------------------------------------------------------------*
*&      Form  MESSAGE_ALV
*&---------------------------------------------------------------------*
FORM message_alv .
  DATA:  lv_textout LIKE t100-text,
         lv_concat(300)  TYPE c,
         lv_index   TYPE sytabix.
  CLEAR: gw_alv, lv_textout, lv_concat, lv_index.

  READ TABLE gtmsj  WITH KEY msgtyp = 'S' msgnr = 228. " Busca si esta creado el AF

** Determina el resultado del mensaje
  IF sy-subrc EQ 0. " SI SE CREO

    MESSAGE ID gtmsj-msgid
     TYPE gtmsj-msgtyp
     NUMBER gtmsj-msgnr
     WITH gtmsj-msgv1 gtmsj-msgv2 gtmsj-msgv3 gtmsj-msgv4 INTO lv_textout.

    gw_alv-pos     = gv_pos.     " linea del excel
    gw_alv-activo  = gtmsj-msgv1." N° Activo Fijo.
    gw_alv-mensaje = lv_textout. " Mensaje.
    gw_alv-color_l = 'C500'.     " Color Line.

** Se agrega la sociedad para llamar a la transaccion AS92 segun el tipo de AF.
     IF cb_actua IS NOT INITIAL. " Año Actual
      gw_alv-bukrs  = gw_data1-bukrs.
       ELSE.                     " Años Anteriores
      gw_alv-bukrs  = gw_data-bukrs.
    ENDIF.
    APPEND gw_alv TO gt_alv.
  ELSE.        " NO SE CREO
    LOOP AT gtmsj where msgtyp NE 'W'.
      lv_index = sy-tabix.
      CLEAR: lv_textout.
      MESSAGE ID gtmsj-msgid
        TYPE gtmsj-msgtyp
        NUMBER gtmsj-msgnr
        WITH gtmsj-msgv1 gtmsj-msgv2 gtmsj-msgv3 gtmsj-msgv4 INTO lv_textout.

      IF lv_index EQ 1.
        lv_concat = lv_textout.
      ELSE.
        CONCATENATE lv_concat ' | ' lv_textout INTO lv_concat.
      ENDIF.
    ENDLOOP.
    IF lv_concat IS NOT INITIAL.
      gw_alv-pos = gv_pos.       " linea del excel
      gw_alv-color_l = 'C600'.   " Color Line.
      gw_alv-mensaje = lv_concat." Mensaje Error.
      APPEND gw_alv TO gt_alv.
    ENDIF.
  ENDIF.
  CLEAR: gw_data1.

ENDFORM.                    " MESSAGE_ALV
*&---------------------------------------------------------------------*
*&      Form  indicador_progreso
*&---------------------------------------------------------------------*
FORM indicador_progreso  USING lv_lineas
                               lv_mensaje.
  " Declaración variables locales para msj informativo pant. selec.
  DATA: lv_calc       TYPE p DECIMALS 2,
        lv_info(100)  TYPE c,
        lv_calc_t     TYPE string,
        lv_total_t    TYPE string,
        lv_linea_t    TYPE string.
  IF gv_lineas > 0.
    lv_calc = ( lv_lineas * 100 ) / gv_lineas.
    lv_calc_t = lv_calc.
    lv_total_t = gv_lineas.
    lv_linea_t = lv_lineas.

    CONCATENATE lv_mensaje '' lv_calc_t '% ...  -  ' lv_linea_t ' de '  lv_total_t
    INTO lv_info
    SEPARATED BY space RESPECTING BLANKS.

    CALL FUNCTION 'SAPGUI_PROGRESS_INDICATOR'
      EXPORTING
        percentage = lv_calc
        text       = lv_info.

  ENDIF.
ENDFORM.                    " indicador_progreso
