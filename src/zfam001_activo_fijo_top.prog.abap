*&---------------------------------------------------------------------*
*&  Include           ZFAM001_ACTIVO_FIJO_TOP
*&---------------------------------------------------------------------*

************ DATOS Y ESTRUCTURAS **************************
TABLES: anlz,    "Asignaciones de activos fijos con fecha valor
        anla,    "Segm.reg.maestro inmov.
        anlc,    "Campos de valor de activos fijos
        anlp,    "Valores periódicos de activos fijos
        anlb,    "Parámetros de amortización
        anlh,    "Número principal de activo fijo
        ANKT,    "Clases de activos fijos: descripción
        ANEK,    "Cabecera de documento de contabilización AF
        LFA1,    "Maestro de proveedores (parte general)
        cskt,
        bkpf,
        bseg,
        t095,    "KTOPL KTOGR AFABE(01) KTANSW
        t095b.   "Cuentas de amortización

TABLES: tabw, tabwg, tabwt, TABA, t001.
*
* Parametros para ALV
TYPE-POOLS: slis.
DATA:  sort          TYPE slis_t_sortinfo_alv WITH HEADER LINE,
       fieldcat      TYPE slis_t_fieldcat_alv WITH HEADER LINE,
       print         TYPE slis_print_alv,
       layout        TYPE slis_layout_alv,
       repid          LIKE sy-repid,
       g_user_command TYPE slis_formname VALUE 'USER_COMMAND',
       g_callback_html_top_of_page  type slis_formname value 'HTML_TOP_OF_PAGE'.

DATA:
  swMovto(1)  TYPE c,
  swF4(1)     TYPE c,
  wa_titulo   TYPE lvc_title,
  wa_TXT50       LIKE skat-txt50,
  wa_BUKRS       LIKE bsis-BUKRS,
  wa_BELNR       LIKE bsis-BELNR,
  wa_GJAHR       LIKE bsis-GJAHR,
  wa_HKONT       LIKE bsis-HKONT,
  wa_HBKID       LIKE t012-HBKID,
  wa_ANLN1       LIKE anlc-ANLN1,
  wa_AFABER      LIKE T093T-AFABER,
  wa_AFBTXT      LIKE T093T-AFBTXT,
  wa_fecha_proc  TYPE SY-DATUM,
  wa_DAYS        TYPE i,
  wa_MONTHS      TYPE i,
  wa_YEARS       TYPE i,
  wa_pag(1)      TYPE n,
  wa_lineas(6)   TYPE n,
  wa_cont        TYPE i,
  wa_existe(1)   TYPE n,
  wa_flag(1)     TYPE c,
  wa_tabix       TYPE sy-tabix,
  wa_mes_cierre  LIKE TABA-AFBLPE,
  WA_AWKEY       LIKE BKPF-AWKEY,
  wa_distinto_mes   TYPE c,
  wa_periodo(6)     TYPE n,
  wa_belnr_numc(10) TYPE n.

*---Constantes
CONSTANTS :  c_x TYPE c VALUE 'X',
c_r TYPE c VALUE 'L',
c_c TYPE c VALUE 'C',
c_m TYPE c VALUE 'M'.

************ DATOS Y ESTRUCTURAS **************************
DATA begin of it_anlz occurs 1.
        include structure anlz.
DATA end   of it_anlz.
DATA begin of it_anla occurs 1.
        include structure anla.
DATA end   of it_anla.
DATA begin of it_anlp occurs 1.
        include structure anlp.
DATA end   of it_anlp.
DATA begin of it_anlc occurs 1.
        include structure anlc.
DATA end   of it_anlc.
DATA begin of it_anek occurs 1.
        include structure anek.
DATA:   BELNR2  LIKE BKPF-BELNR,
        BUDAT2  LIKE BKPF-BUDAT,
        BLDAT2  LIKE BKPF-BLDAT,
        GJAHR2  LIKE BKPF-GJAHR,
        XBLNR2  LIKE BKPF-XBLNR,
        ANBWA2  LIKE BSEG-ANBWA,
        DMBTR2  LIKE BSEG-DMBTR,
        SHKZG2  LIKE BSEG-SHKZG.
DATA end   of it_anek.

DATA begin of it_bseg occurs 1.
        include structure bseg.
DATA end   of it_bseg.

DATA begin of IT_DOCUMENTS occurs 1.
        include structure ACC_DOC.
DATA end   of IT_DOCUMENTS.

DATA: BEGIN OF TABLA OCCURS 0,
            lin(6)   TYPE n,

* ANLA
            bukrs  LIKE anla-bukrs,  "Sociedad
            anln1  LIKE anla-anln1,  "N° AF
            anln2  LIKE anla-anln2,  "SubN° AF
            txt50  LIKE anla-txt50,  "Descripcion AF
            TXA50  LIKE ANLA-TXA50,
            aktiv  LIKE anla-aktiv,  "Fecha de capitalización
            ktogr  LIKE anla-ktogr,  "CtaContable
            ANLKL  LIKE anla-ANLKL,  "Clase
            TXK50  LIKE ankt-TXK50,  "Descripcion Clase
            LIFNR  LIKE ANLA-LIFNR,  "Proveedor
            LIEFE  LIKE ANLA-LIEFE,  "Nombre Proveedor
            STCD1  LIKE LFA1-STCD1,  "RUT Proveedor
            URWRT  LIKE anla-URWRT,  "Valor de adquisición original
            ORD41  LIKE ANLA-ORD41,  "Torre
            ORD42  LIKE ANLA-ORD42,  "Zona
            ORD44  LIKE ANLA-ORD44,  "Leasing
            SERNR  LIKE ANLA-SERNR,  "N° Serie
            INVNR  LIKE ANLA-INVNR,  "N° Inventario
* ANLH
            ANLHTXT LIKE ANLH-ANLHTXT,
* ANEK
            BELNR  LIKE ANEK-BELNR,  "Doc.Contable
            BUDAT  LIKE ANEK-BUDAT,  "Fecha Contab.
            BLDAT  LIKE ANEK-BLDAT,  "Fecha Doc.
            GJAHR  LIKE ANEK-GJAHR,  "Ejercicio
            XBLNR  LIKE ANEK-XBLNR,  "Referencia

* ANLZ
            kostl  LIKE anlz-kostl,
            ktext  LIKE cskt-ktext,
            werks  LIKE anlz-werks,
* ANLC
            AFABE  LIKE anlc-afabe,   "Área de valoración
            AFBTXT LIKE T093T-AFBTXT, "Descripcion Area Valoracion
            reavi  LIKE anlc-knafa,   "Reavaluo Inicial
            reavp  LIKE anlc-knafa,   "Reavaluo Periodo
            DETEI  LIKE anlc-knafa,   "Deteriodo de Inicio
            DETEP  LIKE anlc-knafa,   "Deteriodo del Periodo
            DEPAI  LIKE anlc-knafa,   "Depreciacion Acumulada Inicio
            ALTAS  LIKE anlc-knafa,   "Depreciacion Acumulada Inicio
            BAJAS  LIKE anlc-knafa,   "Depreciacion Acumulada Inicio
            TRASL  LIKE anlc-knafa,   "Depreciacion Acumulada Inicio
            INVER  LIKE anlc-knafa,   "Depreciacion Acumulada Inicio
            bruto              LIKE anlc-knafa,
            neto               LIKE anlc-knafa,
            monto_adq          LIKE anlc-knafa,
            valor_ini          LIKE anlc-knafa,
            cm_inic_eje        LIKE anlc-knafa,
            cm_acum_eje        LIKE anlc-knafa,
            cm_mes_eje         LIKE anlc-knafa,

            dep_inic_eje       LIKE anlc-knafa,
            dep_acum_eje       LIKE anlc-knafa,
            dep_mes_eje        LIKE anlc-knafa,

            rev_amor_inic_eje  LIKE anlc-knafa,
            rev_amor_acum_eje  LIKE anlc-knafa,
            rev_amor_mes_eje   LIKE anlc-knafa,

            knafa  LIKE anlc-knafa,   "Amort. normales acumuladas
*VIDA UTIL
            vu_trans_yy(4)     TYPE n,
            vu_trans_mm(4)     TYPE n,
            ndabj  LIKE anlc-ndabj,   "Vida transcurrida
            ndabp  LIKE anlc-ndabp,
* ANLB
            afabg  LIKE anlb-afabg,   "Fecha inicio cálculo amortización
            ndjar  LIKE anlb-ndjar,   "Vida útil prevista en años
            VUMES  LIKE anlb-ndjar,   "Vida util prevista en meses
            VUCON  LIKE anlb-ndjar,   "Vida util consumida en Meses
            VURES  LIKE anlb-ndjar,   "Vida util Residual  en Meses
            ndper  LIKE anlb-ndper,   "Vida Útil
            SCHRW  LIKE anlb-SCHRW,       "Valor residual
            SCHRW_PROZ  LIKE anlb-SCHRW_PROZ,  "valor residual %
* ANLP
            nafaz  LIKE anlp-nafaz,
* T095
            ktansw LIKE t095-ktansw,
* T095B
            ktnafb LIKE t095b-ktnafb,
       END OF TABLA.


DATA: BEGIN OF RESUMEN OCCURS 0,
* ANLA
            bukrs  LIKE anla-bukrs,   "Sociedad
            ktansw LIKE t095-ktansw,  "CtaContable
            ANLKL  LIKE anla-ANLKL,   "Clase
            TXK50  LIKE ankt-TXK50,   "Descripcion Clase
            AFABE  LIKE anlc-afabe,   "Área de valoración
            AFBTXT LIKE T093T-AFBTXT, "Descripcion Area Valoracion
* ANLC
            URWRT  LIKE anla-URWRT,   "Valor de adquisición original
            reavi  LIKE anlc-knafa,   "Reavaluo Inicial
            reavp  LIKE anlc-knafa,   "Reavaluo Periodo
            DETEI  LIKE anlc-knafa,   "Deteriodo de Inicio
            DETEP  LIKE anlc-knafa,   "Deteriodo del Periodo
            DEPAI  LIKE anlc-knafa,   "Depreciacion Acumulada Inicio
            ALTAS  LIKE anlc-knafa,   "Depreciacion Acumulada Inicio
            BAJAS  LIKE anlc-knafa,   "Depreciacion Acumulada Inicio
            TRASL  LIKE anlc-knafa,   "Depreciacion Acumulada Inicio
            INVER  LIKE anlc-knafa,   "Depreciacion Acumulada Inicio
            bruto              LIKE anlc-knafa,
            neto               LIKE anlc-knafa,
            monto_adq          LIKE anlc-knafa,
            valor_ini          LIKE anlc-knafa,
            cm_inic_eje        LIKE anlc-knafa,
            cm_acum_eje        LIKE anlc-knafa,
            cm_mes_eje         LIKE anlc-knafa,
            dep_inic_eje       LIKE anlc-knafa,
            dep_acum_eje       LIKE anlc-knafa,
            dep_mes_eje        LIKE anlc-knafa,
            rev_amor_inic_eje  LIKE anlc-knafa,
            rev_amor_acum_eje  LIKE anlc-knafa,
            rev_amor_mes_eje   LIKE anlc-knafa,
            SCHRW  LIKE anlb-SCHRW,       "Valor residual
            SCHRW_PROZ  LIKE anlb-SCHRW_PROZ,  "valor residual %
       END OF RESUMEN.
