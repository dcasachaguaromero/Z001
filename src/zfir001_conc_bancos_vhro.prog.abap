*&---------------------------------------------------------------------*
*& Report  ZFIR001_CONC_BANCOS
*&
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*

REPORT  ZFIR001_CONC_BANCOS
  NO STANDARD PAGE HEADING
    MESSAGE-ID ZFI.


************ DATOS Y ESTRUCTURAS **************************
TABLES: T001,    "Sociedades
        T012,    "Bancos propios
        SKA1,    "Maestro de cta.mayor (plan de cuentas)
        SKAT,    "Maestro de ctas. de mayor (plan de ctas.: denominación)
        SKB1,    "Registro maestro de cta.mayor (sociedad)
        BSIS,    "Contabilidad: Índice secundario para ctas.mayor
        BSAS,    "Contabilidad: Índice secundario para ctas.mayor (part.comp.)
        FEBKO,   "Registros de cabecera de extracto de cuenta electrónico
        FEBEP,   "Partidas individuales de extracto de cuenta electrónico
        BSEG,    "Segmento de documento de Contabilidad
        BKPF.    "Cabecera de documento para Contabilidad
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

************ DATOS Y ESTRUCTURAS **************************
DATA begin of it_skb1 occurs 1.
        include structure skb1.
DATA end   of it_skb1.
DATA begin of it_t012 occurs 1.
        include structure t012.
DATA end   of it_t012.
*---------------------------------
DATA begin of it_bsis occurs 1.
  data bukrs like bsis-bukrs.
  data belnr like bsis-belnr.
  data gjahr like bsis-gjahr.
  data buzei like bsis-buzei.
  data hkont like bsis-hkont.
  data blart like bsis-blart.
  data shkzg like bsis-shkzg.
  data wrbtr like bsis-wrbtr.
  data budat like bsis-budat.
  data dmbtr like bsis-dmbtr.
DATA    BKTXT   LIKE bkpf-BKTXT.      "Texto Cabecera
DATA    AWKEY   LIKE bkpf-AWKEY.      "Clave Referencia
DATA    USNAM   LIKE bkpf-USNAM.      "Usuario
DATA    STBLG   LIKE bkpf-STBLG.      "N° Doc. Anulacion
DATA    STJAH   LIKE bkpf-STJAH.      "Ejercicio Doc. Anulacion
DATA    STGRD   LIKE bkpf-STGRD.      "Motivo Anulacion
DATA XREF1_HD   LIKE bkpf-XREF1_HD.   "Clave Ref Cab 1
DATA XREF2_HD   LIKE bkpf-XREF2_HD.   "Clave Ref Cab 2
DATA ZZMOT_EMIS LIKE bseg-ZZMOT_EMIS. "Motivo Emision
DATA AZNUM      LIKE febko-AZNUM.     "Nº extracto
DATA TEXTS      LIKE febep-TEXTS.     "Clave texto
DATA CHECT      LIKE febep-CHECT.     "Nº cheque
DATA    HBKID   LIKE skb1-HBKID.      "Banco Propio
DATA    SISTEMA(20)  TYPE c.
DATA    USUARIO(20)  TYPE c.
DATA end   of it_bsis.
*---------------------------------
DATA begin of it_bsas occurs 1.
  data bukrs like bsas-bukrs.
  data belnr like bsas-belnr.
  data gjahr like bsas-gjahr.
  data buzei like bsas-buzei.
  data hkont like bsas-hkont.
  data blart like bsas-blart.
  data shkzg like bsas-shkzg.
  data wrbtr like bsas-wrbtr.
DATA    BKTXT   LIKE bkpf-BKTXT.      "Texto Cabecera
DATA    AWKEY   LIKE bkpf-AWKEY.      "Clave Referencia
DATA    USNAM   LIKE bkpf-USNAM.      "Usuario
DATA    STBLG   LIKE bkpf-STBLG.      "N° Doc. Anulacion
DATA    STJAH   LIKE bkpf-STJAH.      "Ejercicio Doc. Anulacion
DATA    STGRD   LIKE bkpf-STGRD.      "Motivo Anulacion
DATA XREF1_HD   LIKE bkpf-XREF1_HD.   "Clave Ref Cab 1
DATA XREF2_HD   LIKE bkpf-XREF2_HD.   "Clave Ref Cab 2
DATA ZZMOT_EMIS LIKE bseg-ZZMOT_EMIS. "Motivo Emision
DATA AZNUM      LIKE febko-AZNUM.     "Nº extracto
DATA TEXTS      LIKE febep-TEXTS.     "Clave texto
DATA CHECT      LIKE febep-CHECT.     "Nº cheque
DATA    HBKID   LIKE skb1-HBKID.      "Banco Propio
DATA    SISTEMA(20)  TYPE c.
DATA    USUARIO(20)  TYPE c.
DATA end   of it_bsas.

TYPES:
  begin of es_bseg,
    bukrs like bseg-bukrs,
    gjahr like bseg-gjahr,
    belnr like bseg-belnr,
    buzei like bseg-buzei,
    zzmot_emis like bseg-zzmot_emis,
  end   of es_bseg,
  begin of es_bkpf,
     bukrs like bkpf-bukrs,
     belnr like bkpf-belnr,
     gjahr like bkpf-gjahr,
     bktxt like bkpf-bktxt,
     awkey like bkpf-awkey,
     usnam like bkpf-usnam,
     stblg like bkpf-stblg,
     stjah like bkpf-stjah,
     stgrd like bkpf-stgrd,
     xref1_hd like bkpf-xref1_hd,
     xref2_hd like bkpf-xref2_hd,
     budat like bkpf-budat,
  end of es_bkpf.

types ty_bseg type SORTED TABLE OF es_bseg WITH UNIQUE KEY bukrs belnr gjahr buzei.
types ty_bkpf type SORTED TABLE OF es_bkpf WITH UNIQUE KEY bukrs belnr gjahr.

data it_bseg type es_bseg.
data it_bkpf type ty_bkpf WITH HEADER LINE.


*---------------------------------
types: begin of es_febko,
        kukey like febko-kukey,
        aznum like febko-aznum,
end   of es_febko.
*---------------------------------
types: begin of es_febep,
        gjahr like febep-gjahr,
        budat like febep-budat,
        ak1bl like febep-ak1bl,
        texts like febep-texts,
        chect like febep-chect,
        kukey like febep-kukey,
       end   of es_febep.

types ty_febep type SORTED TABLE OF es_febep WITH non-UNIQUE KEY gjahr budat ak1bl.
types ty_febko type SORTED TABLE OF es_febko WITH UNIQUE KEY kukey.

data it_febep type ty_febep WITH HEADER LINE.
data it_febko type ty_febko WITH HEADER LINE.
*---------------------------------
DATA begin of it_movbanco occurs 1.
        include structure it_bsas.
DATA end   of it_movbanco.
*---------------------------------
DATA begin of it_movconta occurs 1.
        include structure it_bsas.
DATA end   of it_movconta.
*---------------------------------
DATA begin of it_movbanco_open occurs 1.
        include structure it_bsis.
DATA end   of it_movbanco_open.
*---------------------------------
DATA begin of it_movconta_open occurs 1.
        include structure it_bsis.
DATA end   of it_movconta_open.
*---------------------------------
DATA begin of it_detalle occurs 1.
        include structure it_bsis.
DATA    monto   LIKE bsis-wrbtr.
DATA end   of it_detalle.
*
DATA: BEGIN OF it_caratula OCCURS 1,
      BUKRS      LIKE bsis-bukrs,
      HKONT      LIKE bseg-hkont,
      TXT50      LIKE skat-txt50,
      BANCO      LIKE bsis-wrbtr,
      CONTA      LIKE bsis-wrbtr,
      SALDO      LIKE bsis-wrbtr,
      BANCO_OPEN LIKE bsis-wrbtr,
      CONTA_OPEN LIKE bsis-wrbtr,
      SALDO_OPEN LIKE bsis-wrbtr,
END OF it_caratula.

*
DATA: BEGIN OF it_proyeccion OCCURS 1,
      BUKRS        LIKE bsis-bukrs,
      HKONT        LIKE bseg-hkont,
      TXT50        LIKE skat-txt50,
      SISTEMA(20)  TYPE c,
      USUARIO(20)  TYPE c,
      MONTO_01     LIKE bsis-wrbtr,
      MONTO_02     LIKE bsis-wrbtr,
      MONTO_03     LIKE bsis-wrbtr,
      MONTO_04     LIKE bsis-wrbtr,
      MONTO_05     LIKE bsis-wrbtr,
      MONTO_06     LIKE bsis-wrbtr,
      MONTO_07     LIKE bsis-wrbtr,
      MONTO_08     LIKE bsis-wrbtr,
      MONTO_09     LIKE bsis-wrbtr,
      MONTO_10     LIKE bsis-wrbtr,
      MONTO_11     LIKE bsis-wrbtr,
      MONTO_12     LIKE bsis-wrbtr,
      MONTO_13     LIKE bsis-wrbtr,
      MONTO_14     LIKE bsis-wrbtr,
      MONTO_15     LIKE bsis-wrbtr,
      MONTO_16     LIKE bsis-wrbtr,
      MONTO_17     LIKE bsis-wrbtr,
      MONTO_18     LIKE bsis-wrbtr,
      MONTO_19     LIKE bsis-wrbtr,
      MONTO_20     LIKE bsis-wrbtr,
      MONTO_21     LIKE bsis-wrbtr,
      MONTO_22     LIKE bsis-wrbtr,
      MONTO_23     LIKE bsis-wrbtr,
      MONTO_24     LIKE bsis-wrbtr,
      SALDO_ANUAL  LIKE bsis-wrbtr,
END OF it_proyeccion.


*---Constantes
CONSTANTS :  c_x TYPE c VALUE 'X',
c_r TYPE c VALUE 'L',
c_c TYPE c VALUE 'C',
c_m TYPE c VALUE 'M'.


DATA:
  swMovto(1)  TYPE c,
  wa_titulo   TYPE lvc_title,
  wa_TXT50     LIKE skat-txt50,
  wa_BUKRS     LIKE bsis-BUKRS,
  wa_BELNR     LIKE bsis-BELNR,
  wa_GJAHR     LIKE bsis-GJAHR,
  wa_HKONT     LIKE bsis-HKONT,
  wa_HBKID     LIKE t012-HBKID,
  wa_SISTE(20) TYPE c,
  wa_USUAR(20) TYPE c,
  wa_pag(1)    TYPE n,
  wa_contador  TYPE i,
  wa_sistema(20) TYPE c,
  wa_fec_proceso TYPE SY-DATUM,
  wa_periodo(2)  TYPE n,
  wa_tabix       TYPE sy-tabix.


*********** PARAMETROS ************************************************
SELECTION-SCREEN BEGIN OF BLOCK blk1 WITH FRAME TITLE text-001.
  PARAMETERS:     P_BUKRS LIKE T001-BUKRS OBLIGATORY.
  SELECT-OPTIONS: S_HBKID FOR  T012-HBKID NO INTERVALS,
                  S_SAKNR FOR  SKB1-SAKNR NO INTERVALS NO-DISPLAY,
                  S_BLART FOR  BSIS-BLART NO INTERVALS
                               DEFAULT 'ZR' NO-DISPLAY.
  PARAMETERS:
                  P_BUDAT LIKE SY-DATUM OBLIGATORY,
                  P_ACC   AS CHECKBOX,
                  P_OPEN  AS CHECKBOX,
                  P_PCTA  LIKE SKAT-ktopl      DEFAULT 'B100' NO-DISPLAY,
                  P_LEDGE TYPE FAGLFLEXT-RLDNR DEFAULT '0L'   NO-DISPLAY.
SELECTION-SCREEN END OF BLOCK blk1.


*********** AUTORIZACIONES ************************************************
AT SELECTION-SCREEN ON p_bukrs.
  AUTHORITY-CHECK OBJECT 'F_BKPF_BUK'
           ID 'BUKRS' FIELD p_bukrs.
  IF sy-subrc NE 0.
    MESSAGE e004(zfi) WITH 'Sin autorización para Sociedad.' p_bukrs.
  ENDIF.


*********** INICIALIZACION ************************************************
INITIALIZATION.
  CALL FUNCTION 'LAST_DAY_OF_MONTHS'
    EXPORTING
      DAY_IN                  = sy-datum
   IMPORTING
     LAST_DAY_OF_MONTH       = P_BUDAT
*   EXCEPTIONS
*     DAY_IN_NO_DATE          = 1
*     OTHERS                  = 2
            .
  IF SY-SUBRC <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.


***********   PROCESO     ************************************************
START-OF-SELECTION.
  PERFORM select_param.
  IF P_OPEN = 'X' OR P_ACC = 'X'.
     PERFORM select_items_abiertos.
  ELSE.
     PERFORM select_items_abiertos.
     PERFORM select_items_compensadas.
  ENDIF.

END-OF-SELECTION.
 IF P_ACC = 'X'.
    SORT it_proyeccion BY  bukrs hkont SISTEMA USUARIO.
    PERFORM lista_alv_proyeccion.
 ELSE.
    SORT it_caratula BY  bukrs hkont .
    PERFORM lista_alv.
 ENDIF.

*
INCLUDE ZFIR001_CONC_BANCOS_INCVHRO.
*
