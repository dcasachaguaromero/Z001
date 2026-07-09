*&---------------------------------------------------------------------*
*&  Include           ZFIBI_AS91_TOP
*&---------------------------------------------------------------------*
TYPE-POOLS: slis.

TYPES: t_excel   TYPE  alsmex_tabline.
** Estructura AF ejercicio Actual
TYPES: BEGIN OF t_data1,
anlkl            TYPE  anla-anlkl  ," Clase activos fijos
bukrs            TYPE  anla-bukrs  ," Sociedad
txt50            TYPE  anla-txt50  ," Denominación
txa50            TYPE  anla-txa50  ," Denominación
anlhtxt          TYPE  anlh-anlhtxt  ," Txt.núm.pral.AF
sernr            TYPE  anla-sernr  ," Número de serie
invnr            TYPE  anla-invnr  ," Número de inventario
menge(13)        TYPE  c           ," Cantidad
meins            TYPE  anla-meins  ," Unidad de medida
xhist            TYPE  ra02s-xhist ," Gestion Historica
ivdat(10)        TYPE  c           ," Último inventario el
inken            TYPE  anla-inken  ," Incluir AF en la lista de inventario
invzu            TYPE  anla-invzu  ," Nota de inventario
aktiv(10)        TYPE  c           ," Capitalizado el
gsber            TYPE  anlz-gsber  ," División
kostl            TYPE  anlz-kostl  ," Centro de coste
kostlv           TYPE  anlz-kostlv ," CeCo responsable
werks            TYPE  anlz-werks  ," Centro
raumn            TYPE  anlz-raumn  ," Local
kfzkz            TYPE  anlz-kfzkz  ," Matrícula vehículo
msfak(3)         TYPE  c           ," Factor turnos
fkber            TYPE  anlz-fkber  ," Área funciona
ord41            TYPE  anla-ord41  ," Torre
ord42            TYPE  anla-ord42  ," Zona
ord43            TYPE  anla-ord43  ," Criterio clasif.3
ord44            TYPE  anla-ord44  ," Leasing
izwek            TYPE  anla-izwek  ," Destino inversión
umwkz            TYPE  anla-umwkz  ," Inv.prot.medio amb.
anlue            TYPE  anla-anlue  ," Supranúmero de AF
invsl_1          TYPE  ra02s-invsl ," Clave para el fomento de la inversión
lifnr            TYPE  anla-lifnr  ," Acreedor
liefe            TYPE  anla-liefe  ," Acreedor
herst            TYPE  anla-herst  ," Fabricante
xneu_am          TYPE  ra02s-xneu_am ," AF comprado nuevo
xgbr_am          TYPE  ra02s-xgbr_am ," Comprado 2da mano
vbund            TYPE  anla-vbund  ," Sociedad GL asociada
land1            TYPE  anla-land1  ," País origen
typbz            TYPE  anla-typbz  ," Denominación de tipo
aibn1            TYPE  anla-aibn1  ," Activo fijo orig.
aibn2            TYPE  anla-aibn2  ," Activo fijo orig.
aibdt(10)        TYPE  c           ," Alta el
urjhr            TYPE  anla-urjhr  ," Año adquis.orig.
urwrt(13)        TYPE  c           ," Valor original
antei(5)         TYPE  c           ," Parte prod.propia
vmgli            TYPE  anla-vmgli  ," Clave agrupamiento
eigkz            TYPE  anla-eigkz  ," Indicador propiedad
wrtma(13)        TYPE  c           ," Val.patrim.man.
xvrmw            TYPE  anla-xvrmw  ," Valor patrimonial manual
fiamt            TYPE  anla-fiamt  ," Delegación Hacienda
ehwnr            TYPE  anla-ehwnr  ," N.I.F. valor unit
ehwzu(10)        TYPE  c           ," Cartilla del
stadt            TYPE  anla-stadt  ," Municipio
gruvo(10)        TYPE  c           ," Reg.propiedad del
grein(10)        TYPE  c           ," Inscripción del
grbnd            TYPE  anla-grbnd  ," Tomo/hoja/nº actual
grblt            TYPE  anla-grblt  ," Tomo/hoja/nº actual
grlfd            TYPE  anla-grlfd  ," Tomo/hoja/nº actual
aufla(10)        TYPE  c           ," Ces.propiedad
flurk            TYPE  anla-flurk  ," Cartilla parcelaria
flurn            TYPE  anla-flurn  ," Cartilla parcelaria
grufl(13)        TYPE  c           ," Superficie
vsstx            TYPE  anlv-vsstx  ," Nº de póliza
vsztx            TYPE  anlv-vsztx  ," Comentario
vrsbg(10)        TYPE  c           ," Inicio
vsind            TYPE  anlv-vsind  ," Serie de índices
vrsba(13)        TYPE  c           ," Valor base
vsman            TYPE  anlv-vsman  ," Actualiz.man.
vrsma(13)        TYPE  c           ," Valor manual
leafi            TYPE  anla-leafi  ," Parte contratante
lvtnr            TYPE  anla-lvtnr  ," Número de contrato
lvdat(10)        TYPE  c           ," Fecha del contrato
lkdat(10)        TYPE  c           ," Fecha rescis.
leabg(10)        TYPE  c           ," Inicio
lejar            TYPE  anla-lejar  ," Duración
leper            TYPE  anla-leper  ," Duración
leart            TYPE  anla-leart  ," Clase
lbasw(13)        TYPE  c           ," Valor base de nuevo
lkauf(13)        TYPE  c           ," Precio de compra
letxt            TYPE  anla-letxt  ," Comentario
leanz(5)         TYPE  c           ," Nº pagos leasing
lryth(3)         TYPE  c           ," Forma de pago
lvors            TYPE  anla-lvors  ," Pagos anticipados
legeb(13)        TYPE  c           ," Cuota de leasing
lzins(7)         TYPE  c           ," Tp.ints.anual
afasl_1          TYPE  anlb-afasl  ," Amo 1
afasl_2          TYPE  anlb-afasl  ," Amo 2
afasl_3          TYPE  anlb-afasl  ," Amo 3
afasl_4          TYPE  anlb-afasl  ," Amo 4
ndjar_1          TYPE  anlb-ndjar  ," Duración
ndjar_2          TYPE  anlb-ndjar  ," Duración
ndjar_3          TYPE  anlb-ndjar  ," Duración
ndjar_4          TYPE  anlb-ndjar  ," Duración
ndper_1          TYPE  anlb-ndper  ," Periodo
ndper_2          TYPE  anlb-ndper  ," Periodo
ndper_3          TYPE  anlb-ndper  ," Periodo
ndper_4          TYPE  anlb-ndper  ," Periodo
anbtr01_10(13)   TYPE  c           ," Reval.contab.
anbtr01_11(13)   TYPE  c           ," AmoN contab.
anbtr01_13(13)   TYPE  c           ," AmoNP contab.
anbtr01_14(13)   TYPE  c           ," Reserva contab.
anbtr01_15(13)   TYPE  c           ," Rv.cont.AmoN.ac
anbtr03_10(13)   TYPE  c           ," Reval.contab.
anbtr03_11(13)   TYPE  c           ," AmoN contab.
anbtr03_13(13)   TYPE  c           ," AmoNP contab.
anbtr03_14(13)   TYPE  c           ," Reserva contab.
anbtr03_15(13)   TYPE  c           ," Rv.cont.AmoN.ac
anbtr04_10(13)   TYPE  c           ," Reval.contab.
anbtr04_11(13)   TYPE  c           ," AmoN contab.
anbtr04_13(13)   TYPE  c           ," AmoNP contab.
anbtr04_14(13)   TYPE  c           ," Reserva contab.
anbtr04_15(13)   TYPE  c           ," Rv.cont.AmoN.ac
anbtr06_10(13)   TYPE  c           ," Reval.contab.
anbtr06_11(13)   TYPE  c           ," AmoN contab.
anbtr06_13(13)   TYPE  c           ," AmoNP contab.
anbtr06_14(13)   TYPE  c           ," Reserva contab.
anbtr06_15(13)   TYPE  c           ," Rv.cont.AmoN.ac
schrw_1(13)      TYPE  c           ," Valor residual
schrw_pro_1(14)  TYPE  c           ," Val.residual %
schrw_2          TYPE  c           ," Valor residual
schrw_pro_2(14)  TYPE  c           ," Val.residual %
j_1aarvke_1      TYPE  anlb-j_1aarvkey ," Clv.revaloriz.
j_1aaltda_1(10)  TYPE  c           ," Fe.últ.revalor.
schrw_3          TYPE  c           ," Valor residual
schrw_pro_3(14)  TYPE  c           ," Val.residual %
j_1aarvke_2      TYPE  anlb-j_1aarvkey ," Clv.revaloriz.
j_1aaltda_2(10)  TYPE  c          ," Fe.últ.revalor.
  END OF t_data1.
** Estructura AF ejercicio Anterior
TYPES: BEGIN OF t_data,
anlkl            TYPE  anla-anlkl              ," Clase activos fijos
bukrs            TYPE  anla-bukrs              ," Sociedad
txt50            TYPE  anla-txt50              ," Denominación
txa50            TYPE  anla-txa50              ," Denominación
anlhtxt          TYPE  anlh-anlhtxt            ," Txt.núm.pral.AF
sernr            TYPE  anla-sernr              ," Número de serie
invnr            TYPE  anla-invnr              ," Número de inventario
menge(13)        TYPE  c                       ," Cantidad
meins            TYPE  anla-meins              ," Unidad de medida
xhist            TYPE  ra02s-xhist             ," Gestion Historica                     (Flag)
ivdat(10)        TYPE  c                       ," Último inventario el
inken            TYPE  anla-inken              ," Incluir AF en la lista de inventario  (Flag)
invzu            TYPE  anla-invzu              ," Nota de inventario
aktiv(10)        TYPE  c                       ," Capitalizado el
gsber            TYPE  anlz-gsber              ," División
kostl            TYPE  anlz-kostl              ," Centro de coste
kostlv           TYPE  anlz-kostlv             ," CeCo responsable
werks            TYPE  anlz-werks              ," Centro
raumn            TYPE  anlz-raumn              ," Local
kfzkz            TYPE  anlz-kfzkz              ," Matrícula vehículo
msfak(3)         TYPE  c                       ," Factor turnos
fkber            TYPE  anlz-fkber              ," Área funciona
ord41            TYPE  anla-ord41              ," Torre
ord42            TYPE  anla-ord42              ," Zona
ord43            TYPE  anla-ord43              ," Criterio clasif.3
ord44            TYPE  anla-ord44              ," Leasing
izwek            TYPE  anla-izwek              ," Destino inversión
umwkz            TYPE  anla-umwkz              ," Inv.prot.medio amb.
anlue            TYPE  anla-anlue              ," Supranúmero de AF
invsl_1          TYPE  ra02s-invsl             ," Clave para el fomento de la inversión
lifnr            TYPE  anla-lifnr              ," Acreedor
liefe            TYPE  anla-liefe              ," Acreedor
herst            TYPE  anla-herst              ," Fabricante
xneu_am          TYPE  ra02s-xneu_am           ," AF comprado nuevo             (FLAG)
xgbr_am          TYPE  ra02s-xgbr_am           ," Comprado 2da mano             (FLAG)
land1            TYPE  anla-land1              ," País origen
typbz            TYPE  anla-typbz              ," Denominación de tipo
aibn1            TYPE  anla-aibn1              ," Activo fijo orig.
aibn2            TYPE  anla-aibn2              ," Activo fijo orig.
urjhr            TYPE  anla-urjhr              ," Año adquis.orig.
urwrt(13)        TYPE  c                       ," Valor original
antei(5)         TYPE  c                       ," Parte prod.propia
vmgli            TYPE  anla-vmgli              ," Clave agrupamiento
eigkz            TYPE  anla-eigkz              ," Indicador propiedad
wrtma(13)        TYPE  c                       ," Val.patrim.man.
xvrmw            TYPE  anla-xvrmw              ," Valor patrimonial manual       (FLAG)
fiamt            TYPE  anla-fiamt              ," Delegación Hacienda
ehwnr            TYPE  anla-ehwnr              ," N.I.F. valor unit
ehwzu(10)        TYPE  c                       ," Cartilla del
stadt            TYPE  anla-stadt              ," Municipio
gruvo(10)        TYPE  c                       ," Reg.propiedad del
grein(10)        TYPE  c                       ," Inscripción del
grbnd            TYPE  anla-grbnd              ," Tomo/hoja/nº actual
grblt            TYPE  anla-grblt              ," Tomo/hoja/nº actual
grlfd            TYPE  anla-grlfd              ," Tomo/hoja/nº actual
aufla(10)        TYPE  c                       ," Ces.propiedad
flurk            TYPE  anla-flurk              ," Cartilla parcelaria
flurn            TYPE  anla-flurn              ," Cartilla parcelaria
grufl(13)        TYPE  c                       ," Superficie
vsstx            TYPE  anlv-vsstx              ," Nº de póliza
vsztx            TYPE  anlv-vsztx              ," Comentario
vrsbg(10)        TYPE  c                       ," Inicio
vsind            TYPE  anlv-vsind              ," Serie de índices
vrsba(13)        TYPE  c                       ," Valor base
vsman            TYPE  anlv-vsman              ," Actualiz.man.                   (FLAG)
vrsma(13)        TYPE  c                       ," Valor manual
leafi            TYPE  anla-leafi              ," Parte contratante
lvtnr            TYPE  anla-lvtnr              ," Número de contrato
lvdat(10)        TYPE  c                       ," Fecha del contrato
lkdat(10)        TYPE  c                       ," Fecha rescis.
leabg(10)        TYPE  c                       ," Inicio
leart            TYPE  anla-leart              ," Clase
lbasw(13)        TYPE  c                       ," Valor base de nuevo
lkauf(13)        TYPE  c                       ," Precio de compra
letxt            TYPE  anla-letxt              ," Comentario
leanz(5)         TYPE  c                       ," Nº pagos leasing
lryth(3)         TYPE  c                       ," Forma de pago
lvors            TYPE  anla-lvors              ," Pagos anticipados               (FLAG)
legeb(13)        TYPE  c                       ," Cuota de leasing
lzins(7)         TYPE  c                       ," Tp.ints.anual
afasl_1          TYPE  anlb-afasl              ,            " Amo 1
afasl_2          TYPE  anlb-afasl              ,            " Amo 2
afasl_3          TYPE  anlb-afasl              ,            " Amo 3
afasl_4          TYPE  anlb-afasl              ,            " Amo 4
ndjar_1          TYPE  anlb-ndjar              ," Duración 1
ndjar_2          TYPE  anlb-ndjar              ," Duración 2
ndjar_3          TYPE  anlb-ndjar              ," Duración 3
ndjar_4          TYPE  anlb-ndjar              ," Duración 4
ndper_1          TYPE  anlb-ndper              ,            " Periodo 1
ndper_2          TYPE  anlb-ndper              ,            " Periodo 2
ndper_3          TYPE  anlb-ndper              ,            " Periodo 3
ndper_4          TYPE  anlb-ndper              ,            " Periodo 4
afabg_5(10)      TYPE  c                       ," Inicio Amo Normal
*afasl_5          TYPE  anlb-afasl              ," Clave amortización
*ndjar_5          TYPE  anlb-ndjar              ," Vida útil
*ndper_5          TYPE  anlb-ndper              ," Vida útil
*afabg_6          TYPE  anlb-afabg              ," Amortización norma
schrw(13)        TYPE  c                       ," Valor residual
schrw_pro(14)    TYPE  c                       ," Val.residual %
j_1aarvke_1      TYPE  anlb-j_1aarvkey         ," Clv.revaloriz.
*afasl_7          TYPE  anlb-afasl              ," Clave amortización
*ndjar_7          TYPE  anlb-ndjar              ," Vida útil
*ndper_7          TYPE  anlb-ndper              ," Vida útil
*afabg_7          TYPE  anlb-afabg              ," Amortización norma
j_1aarvke_2      TYPE  anlb-j_1aarvkey         ," Clv.revaloriz.
anbtr01_1(13)        TYPE  c                       ," Val.adq.acum.
anbtr01_3(13)        TYPE  c                       ," Reval.acum.VR
anbtr01_4(13)        TYPE  c                       ," Subvenc.acum.
anbtr01_6(13)        TYPE  c                       ," AmoN acum.
anbtr01_8(13)        TYPE  c                       ," AmoNP acum.
anbtr01_9(13)        TYPE  c                       ," Reserva acum.
anbtr01_10(13)       TYPE  c                       ," Rev.acum.AmoN
anbtr03_1(13)        TYPE  c                       ," Val.adq.acum.
anbtr03_3(13)        TYPE  c                       ," Reval.acum.VR
anbtr03_4(13)        TYPE  c                       ," Subvenc.acum.
anbtr03_6(13)        TYPE  c                       ," AmoN acum.
anbtr03_8(13)        TYPE  c                       ," AmoNP acum.
anbtr03_9(13)        TYPE  c                       ," Reserva acum.
anbtr03_10(13)       TYPE  c                       ," Rev.acum.AmoN
anbtr04_1(13)        TYPE  c                       ," Val.adq.acum.
anbtr04_3(13)        TYPE  c                       ," Reval.acum.VR
anbtr04_4(13)        TYPE  c                       ," Subvenc.acum.
anbtr04_6(13)        TYPE  c                       ," AmoN acum.
anbtr04_8(13)        TYPE  c                       ," AmoNP acum.
anbtr04_9(13)        TYPE  c                       ," Reserva acum.
anbtr04_10(13)       TYPE  c                       ," Rev.acum.AmoN
anbtr06_1(13)        TYPE  c                       ," Val.adq.acum.
anbtr06_3(13)        TYPE  c                       ," Reval.acum.VR
anbtr06_4(13)        TYPE  c                       ," Subvenc.acum.
anbtr06_6(13)        TYPE  c                       ," AmoN acum.
anbtr06_8(13)        TYPE  c                       ," AmoNP acum.
anbtr06_9(13)        TYPE  c                       ," Reserva acum.
anbtr06_10(13)       TYPE  c                       ," Rev.acum.AmoN
 END OF t_data.

TYPES: BEGIN OF t_alv,
     pos          TYPE sytabix,      " Numero de posicion del excel
     activo       TYPE anln1,        " N° Activo Fijo.
     bukrs        TYPE bukrs,        " Sociedad
     mensaje(300) TYPE c,            " Mensaje.
     color_l(4)   TYPE c,            " Color Line.
     color_c      TYPE lvc_t_scol,   " Color Celda.
END OF t_alv.

DATA: gt_carga_excel    TYPE TABLE OF t_excel,
      gw_carga_excel    TYPE          t_excel,
      gt_data1          TYPE TABLE OF t_data1,
      gw_data1          TYPE          t_data1,
      gt_data           TYPE TABLE OF t_data,
      gw_data           TYPE          t_data,
      gt_alv            TYPE TABLE OF t_alv,
      gw_alv            TYPE          t_alv.

DATA: c_x TYPE c VALUE 'X',
      gv_lineas  TYPE sytabix,    " Contador Total
      gv_pos     TYPE sytabix,    " posicion del excel
      gv_mode(3) TYPE c VALUE 'N'." Modo para BI

*----------------------------------------------------------------------*
*   DECLARACION DE VARIABLES BACH AS91
*----------------------------------------------------------------------*
*       Batchinputdata of single transaction
DATA:     bdcdata LIKE bdcdata    OCCURS 0 WITH HEADER LINE.
DATA:     gtmsj   TYPE TABLE OF bdcmsgcoll WITH HEADER LINE .
