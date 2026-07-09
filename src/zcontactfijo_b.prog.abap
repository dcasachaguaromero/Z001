*&---------------------------------------------------------------------*
*&  Include           ZCONTACTFIJO
*&---------------------------------------------------------------------*
TABLES: bbkpf,      "Cab.documento para documento contable (estruct. bat
        bbseg,      "Segmento de documento contable (estruct. batch inpu
        bgr00,      "Estructura batch input para datos de juego de datos
        bwith,
        lfbw.

DATA: BEGIN OF arch_plano OCCURS 100,
      inddoc(1),                      "Indice documento
      bldat(10),                      "Fecha documento (AAAAMMDD)
      blart(2),                       "Clase documento
      bukrs(4),                       "Sociedad
      budat(10),                      "Fecha contabil. (AAAAMMDD)
      monat(2),                       "Periodo
      waers(4),                       "Moneda
      kursf(9),                       "Tipo Cambio Conversion
      belnr(10),                      "Nº Documento
      wwert(8),                       "Fecha Conversion
      xblnr(16),                      "Referencia
      bktxt(25),                      "Texto Cabecera de docto.
      newbs(2),                       "Clave contabil.
      newko(17),                      "Cuenta
      newum(1),                       "Indicador CME
      newbw(3),                       "Clase Mov.Act.Fijo
      wrbtr(13),                      "Importe moneda documento
      dmbtr(13),                      "Importe moneda Local
      zfbdt(10),                      "Vence
      zterm(4),                       "Condicion de Pago
      valut(10),                      "Fecha Valor
      zlspr(1),                       "Bloqueo de pago
      zlsch(1),                       "Vta. de pago
      bankl(15),                      "Clave de banco
      banks(2),                       "Pais Banco
      bankn(1),                       "Cta. Corriente
      hbkid(1),                       "Banco Propio
      regul(1),                       "Receptor Pago Ind.
      name1(35),                      "Nombre rec. de pago
      name3(35),                      "Nombre rec. de pago para ch
      ort01(35),                      "Ciudad
      zuonr(18),                      "Asignacion
      sgtxt(50),                      "Texto Posicion
      kostl(10),                      "Centro Costo
      skfbt(16),                      "Base de descuento
      aufnr(12),                      "Número de Orden
      menge(15),                      "CANTIDAD VENDIDA (*)
      meins(3),                       "UNIDAD DE MEDIDA (*)



   END OF arch_plano.

DATA: nombre_logico LIKE v_filenaci-fileintern VALUE
                    'Z_INTERFAZ_FI',
                    juego_datos(75),
                    arch_entrada(75),
                    nom_jd1(12),
                    fecha_jd LIKE sy-datum,
                    reg(44),
                    nuevo_docto(1).


FIELD-SYMBOLS: <f>, <f1>         .
TABLES:
*  BGR00,                        " Mappenvorsatz
*         BBKPF,                        " Belegkopf + Tcode
*         BBSEG,                        " Belegsegment.
         bbtax,                        " Belegsteuern.
*         BWITH,                        " Quellensteuer
         bselk,                        " Selektionsdaten Kopf
         bselp.                        " Selektionsdaten Position

*TABLES:  TBSL.                         " Buchungsschlüssel
TABLES:  t041a.                        " Ausgleichsvorgänge
*TABLES:  T100.                         " Nachrichten


DATA:   BEGIN OF ftpost OCCURS 100.
        INCLUDE STRUCTURE ftpost.
DATA:   END OF ftpost.

DATA:   BEGIN OF ftclear OCCURS 20.
        INCLUDE STRUCTURE ftclear.
DATA:   END OF ftclear.

DATA:   BEGIN OF fttax OCCURS 0.
        INCLUDE STRUCTURE fttax.
DATA:   END OF fttax.

DATA:   BEGIN OF xblntab  OCCURS 2.
        INCLUDE STRUCTURE blntab.
DATA:   END OF xblntab.


DATA:    BEGIN OF save_ftclear.
        INCLUDE STRUCTURE ftclear.
DATA:    END OF save_ftclear.

*------- Tabelle T_BBKPF enthält Belegkopf + Tcode  --------------------
DATA:    t_bbkpf LIKE bbkpf OCCURS 1.

*------- Tabelle T_BBSEG enthält Belegsegment --------------------------
DATA:    t_bbseg LIKE bbseg_di OCCURS 50.

*------- Tabelle T_BBTAX enthält Steuerdaten ---------------------------
DATA:    t_bbtax LIKE bbtax OCCURS 50.

*------- Tabelle T_BWITH enthält Quellensteuerdaten --------------------
DATA:    t_bwith LIKE bwith_di OCCURS 50.

*------- Tabelle FFILE enthält alle Datensätze -------------------------
DATA:    BEGIN OF tfile OCCURS 0,
           rec(3300)  TYPE c,
         END OF tfile.
DATA:    BEGIN OF efile OCCURS 100,
           rec(3300)  TYPE c,
         END OF efile.
DATA:    BEGIN OF ertab OCCURS 5,
           rec(3300)  TYPE c,
         END OF ertab.

*------- Feld-Informationen aus NAMETAB --------------------------------
DATA:    BEGIN OF nametab OCCURS 120.
        INCLUDE STRUCTURE dntab.
DATA:    END OF nametab.

*------- Tabelle XT001 -------------------------------------------------
DATA:    BEGIN OF xt001 OCCURS 5.
        INCLUDE STRUCTURE t001.
DATA:    END OF xt001.

*------- Tabelle XTBSL -------------------------------------------------
DATA:    BEGIN OF xtbsl OCCURS 10.
        INCLUDE STRUCTURE tbsl.
DATA:    END OF xtbsl.


*------- Tabelle XT041A ------------------------------------------------
DATA:    BEGIN OF xt041a OCCURS 5,
           auglv        LIKE t041a-auglv,
         END OF xt041a.

*eject
*---------------------------------------------------------------------*
*        Strukturen
*---------------------------------------------------------------------*
*------- Initialstrukturen --------------------------------------------
DATA:    BEGIN OF i_bbkpf.
        INCLUDE STRUCTURE bbkpf.       " Belegkopf
DATA:    END OF i_bbkpf.

DATA:    BEGIN OF i_bbseg.
        INCLUDE STRUCTURE bbseg.       " Belegsegment
DATA:    END OF i_bbseg.

DATA:    BEGIN OF i_bbtax.
        INCLUDE STRUCTURE bbtax.       " Belegsteuern
DATA:    END OF i_bbtax.

DATA:    BEGIN OF i_bselk.
        INCLUDE STRUCTURE bselk.       " Selektionsdaten Kopf
DATA:    END OF i_bselk.

DATA:    BEGIN OF i_bselp.
        INCLUDE STRUCTURE bselp.       " Selektionsdaten Position
DATA:    END OF i_bselp.

DATA:    BEGIN OF i_bwith.
        INCLUDE STRUCTURE bwith.       " Quellensteuer
DATA:    END OF i_bwith.

*------- Hilfsstrukturen für Direct Input ------------------------------
DATA:    BEGIN OF wa_bbseg_di.
        INCLUDE STRUCTURE bbseg_di.
DATA:    END OF wa_bbseg_di.

DATA:    BEGIN OF wa_bwith_di.
        INCLUDE STRUCTURE bwith_di.
DATA:    END OF wa_bwith_di.

DATA:    BEGIN OF trans OCCURS 0,
           x     TYPE c,
           c_00  TYPE c VALUE ' ',
           soh   TYPE c,
           c_01  TYPE c VALUE ' ',
           stx   TYPE c,
           c_02  TYPE c VALUE ' ',
           etx   TYPE c,
           c_03  TYPE c VALUE ' ',
           eot   TYPE c,
           c_04  TYPE c VALUE ' ',
           enq   TYPE c,
           c_05  TYPE c VALUE ' ',
           ack   TYPE c,
           c_06  TYPE c VALUE ' ',
           bel   TYPE c,
           c_07  TYPE c VALUE ' ',
           bs    TYPE c,
           c_08  TYPE c VALUE ' ',
           ht    TYPE c,
           c_09  TYPE c VALUE ' ',
           lf    TYPE c,
           c_0a  TYPE c VALUE ' ',
           vt    TYPE c,
           c_0b  TYPE c VALUE ' ',
           ff    TYPE c,
           c_0c  TYPE c VALUE ' ',
           cr    TYPE c,
           c_0d  TYPE c VALUE ' ',
           so    TYPE c,
           c_0e  TYPE c VALUE ' ',
           si    TYPE c,
           c_0f  TYPE c VALUE ' ',
           dle   TYPE c,
           c_10  TYPE c VALUE ' ',
           dc1   TYPE c,
           c_11  TYPE c VALUE ' ',
           dc2   TYPE c,
           c_12  TYPE c VALUE ' ',
           dc3   TYPE c,
           c_13  TYPE c VALUE ' ',
           dc4   TYPE c,
           c_14  TYPE c VALUE ' ',
           nak   TYPE c,
           c_15  TYPE c VALUE ' ',
           syn   TYPE c,
           c_16  TYPE c VALUE ' ',
           etb   TYPE c,
           c_17  TYPE c VALUE ' ',
           can   TYPE c,
           c_18  TYPE c VALUE ' ',
           em    TYPE c,                                "#EC NO_M_RISC3
           c_19  TYPE c VALUE ' ',
           sub   TYPE c,
           c_1a  TYPE c VALUE ' ',
           esc   TYPE c,
           c_1b  TYPE c VALUE ' ',
           fs    TYPE c,
           c_1c  TYPE c VALUE ' ',
           gs    TYPE c,
           c_1d  TYPE c VALUE ' ',
           rs    TYPE c,
           c_1e  TYPE c VALUE ' ',
           us    TYPE c,
           c_1f  TYPE c VALUE ' ',
         END OF trans.


*------- Workarea zum Lesen der BI-Sätze -------------------------------
*------- wa, ertab, tfile und efile muessen mindestens so lang sein
*------- wie die laengste Batchinput-Struktur BBSEG + kundeneigene
*------- Felder im Include CI_COBL_BI.
*------- Laenge der BBSEG ohne CI_COBL_BI (Stand 3.0F) 1861 Bytes
DATA:    BEGIN OF wa,
           char1(3300)  TYPE c,
         END OF wa.

*eject
*---------------------------------------------------------------------*
*        Einzelfelder
*---------------------------------------------------------------------*
DATA:    beleg_count(6) TYPE c,        " Anz. Belege je Mappe
         beleg_break(6) TYPE c,        " Anz. Belege je Mappe
         bukrs          LIKE bbseg-newbk,   " Buchungskreis
         bbkpf_ok(1)    TYPE c,        " Belegkopf übergeben
         bbseg_count(3) TYPE n,        " Anz. BSEGS pro Beleg
         bbseg_tax(1)   TYPE c.        " Steuer über BBSEG eingegeb

DATA:    char(40)       TYPE c,        " Char. Hilfsfeld
         char1(1)       TYPE c,        " Char. Hilfsfeld
         char2(40)      TYPE c,        " Char. Hilfsfeld
         tfile_fill(1)  TYPE c,        " X=TFILE schon gefüllt
         tfsave_fill(1)  TYPE c,       " X=TFSAVE schon gefüllt
         commit_count(4) TYPE n,       " Zähler für Commit
         all_commit LIKE tbist-aktnum. " Anzahl der Belege bis zum
" letzten COMMIT

DATA:    dyn_name(12)   TYPE c.        " Dynproname

DATA:    error_run(1)   TYPE c.        " X = error processing

DATA:    fcode(5)       TYPE c,        " Funktionscode
         function       LIKE  rfipi-funct.  " B= BDC, C= Call Trans
" D-DIRECT INPUT
DATA:    group_count(6) TYPE c,        " Anzahl Mappen
         group_open(1)  TYPE c.        " X=Mappe schon geöffnet

DATA:    ln_bbseg(8)    TYPE p,        " Länge des BBSEG
         ln_bbkpf(8)    TYPE p,        " Länge des BBKPF
         ln_bselk(8)    TYPE p,        " Länge des BSELK
         ln_bselp(8)    TYPE p.        " Länge des BSELP

DATA:    mode           LIKE  rfpdo-allgazmd.
DATA:    msgvn          LIKE sy-msgv1, " Hilfsfeld Message-Variable
         msgid          LIKE sy-msgid,
         msgty          LIKE sy-msgty,
         msgno          LIKE sy-msgno,
         msgv1          LIKE sy-msgv1,
         msgv2          LIKE sy-msgv2,
         msgv3          LIKE sy-msgv3,
         msgv4          LIKE sy-msgv4.

DATA:    n(2)           TYPE n,        " Hilfsfeld num.
         nodata(1)      TYPE c,        " Keine BI-Daten für Feld
         nodata_old     LIKE nodata.   " NODATA gemerkt

DATA:    prefix_p       LIKE tcurp-prefix_p, "price-based rate prefix
         prefix_m       LIKE tcurp-prefix_p. "quantity-based rate prefix

DATA:    refe1(8)       TYPE p.        " Hilfsfeld gepackt

DATA:    satz2_count(6) TYPE c,        " Anz. Sätze(Typ2) je Trans.
         satz2_cnt_akt  LIKE satz2_count,   " Anz. Sätze(Typ2) - 1
         save_tbnam     LIKE bbseg-tbnam,   " gemerkter Tabellenname
         save_bgr00     LIKE bgr00,    " gemerkter BGR00
         subrc          LIKE sy-subrc, " Subrc
         count          TYPE i.        " Anz. Belege

DATA:    tabix(2)       TYPE n,        " Tabelleninex
         tbist_aktiv(1) TYPE c,        " Restart aktiv?
         text(200)      TYPE c,        " Messagetext
*           TEXT1(40)      TYPE C,        " Messagetext
         text2(40)      TYPE c,        " Messagetext
         text3(40)      TYPE c,        " Messagetext
         tfill_ftpost   TYPE i,        " Anz. Einträge in FTPOST
         tfill_t_bbseg  TYPE i,        " Anz. Einträge in T_BBSEG
         tfill_t_bwith  TYPE i,        " Anz. Einträge in T_BWITH
         tfill_tfile    TYPE i,        " Anz. Einträge in TFILE
         tfill_ertab    TYPE i,        " Anz. Einträge in ERTAB
         tfill_ftc(3)   TYPE n,        " Anz. Einträge in FTC
         tfill_ftk(3)   TYPE n,        " Anz. Einträge in FTK
         tfill_ftz(3)   TYPE n,        " Anz. Einträge in FTZ
         tfill_041a(1)  TYPE n.        " Anz. Einträge in XT041A


DATA:    wert(60)       TYPE c,        " Hilfsfeld Feldinhalt
         wt_count       TYPE i.        " Zähler Quellensteuer

DATA:    xbdcc          LIKE rfipi-xbdcc,   " X=BDC bei Error in CallTra
         xeof(1)        TYPE c,        " X=End of File erreicht
         xmess_bbkpf_sende(1) TYPE c,  " Message gesendet für BBKPF
         xmess_bbseg_sende(1) TYPE c,  " Message gesendet für BBSEG
         xmess_bbtax_sende(1) TYPE c,  " Message gesendet für BBTAX
*        XMWST          LIKE BKPF-XMWST,    " Steuer rechnen
         xnewg(1)       TYPE c,        " X=Neue Mappe
         xftclear(1).                  " Append FTCLEAR durchfuehren?

* DATAs wichtig für Wiederaufsetzbarkeit
DATA: aktnum LIKE tbist-aktnum.   " Zähler für aktuell bearbeiteter Satz
DATA: startnum LIKE tbist-aktnum.      " erster zu bearbeitender Satz
*ata: is_error.                   " übergebene Satznummer war fehlerhaft
DATA: numerror LIKE tbist-numerror.    " Anzahl Fehler in diesem Schritt
DATA: olderror LIKE tbist-numerror.    " Anzahl Fehler aus dem
" vorherigen Job.
DATA: lasterrnum LIKE tbist-lastnum.   "Letzte Fehlernummer
DATA: nostart LIKE tbist-nostarting VALUE 'X'. " Start-Infos schreiben ?
DATA: jobid LIKE tbtco-jobname.
DATA: jobid_ext LIKE tbtco-jobname.
CONSTANTS:   pack_size TYPE i VALUE '250',
             c_msgid   LIKE sy-msgid VALUE 'FB'.

TABLES: terrd,
        tfsave.

*-----------------------------------------------------------------------
*        Konstanten und Field-Symbols
*-----------------------------------------------------------------------
DATA:    c_nodata(1)    TYPE c VALUE '/',   " Default für NODATA
         xon                   VALUE 'X'.   " Flag eingeschaltet

DATA:    fmf1ges(1)     TYPE x VALUE '20'.  " Beide Flags aus: Input.
DATA:    fmb1num(1)     TYPE x VALUE '10'.  "       "

DATA:    max_commit(4)  TYPE n.        " Max. Belege je Commit

DATA:    rep_name_a(8)  TYPE c VALUE 'SAPMF05A'. " Mpool SAPMF05A
DATA:    rep_name_c(8)  TYPE c VALUE 'SAPLFCPD'. " Mpool SAPLFCPD
DATA:    rep_name_k(8)  TYPE c VALUE 'SAPLKACB'. " Mpool SAPLKACB

*  FIELD-SYMBOLS: <F1>.
*------- Feldinformationen aus NAMETAB ---------------------------------
*DATA:    BEGIN OF NAMETAB OCCURS 120.
*           INCLUDE STRUCTURE DNTAB.
*DATA:    END OF NAMETAB.

*------- Initialstrukturen ---------------------------------------------
DATA:    BEGIN OF i_bgr00.
        INCLUDE STRUCTURE bgr00.    " Mappenvorsatz
DATA:    END OF i_bgr00.

*DATA:    BEGIN OF I_BBKPF.
*           INCLUDE STRUCTURE BBKPF.    " Belegkopf
*DATA:    END OF I_BBKPF.
*
*DATA:    BEGIN OF I_BBSEG.
*           INCLUDE STRUCTURE BBSEG.    " Belegsegment
*DATA:    END OF I_BBSEG.
*
*DATA:    BEGIN OF I_BBTAX.
*           INCLUDE STRUCTURE BBTAX.    " Belegsteuern
*DATA:    END OF I_BBTAX.
*
*DATA:    BEGIN OF I_BSELK.
*           INCLUDE STRUCTURE BSELK.    " Selektionskopfdaten
*DATA:    END OF I_BSELK.
*
*DATA:    BEGIN OF I_BSELP.
*           INCLUDE STRUCTURE BSELP.    " Selektionspositionen
*DATA:    END OF I_BSELP.
*
*DATA:    BEGIN OF I_BWITH.
*           INCLUDE STRUCTURE BWITH.    " Quellensteuer
*DATA:    END OF I_BWITH.

*------- Einzelfelder, Konstanten, Fieldsymbols ------------------------
*DATA:    CHAR(61)  TYPE C.             " Hilfsfeld

*&---------------------------------------------------------------------*
*&      Form  CREAR_JUEGO_DATOS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->T_BKPF_CONTA  text
*      -->T_BSEG_CONTA  text
*----------------------------------------------------------------------*
FORM crear_juego_datos TABLES t_bkpf_conta STRUCTURE bkpf
                               t_bseg_conta STRUCTURE bseg.
  DATA: zlifnr LIKE lfa1-lifnr.
*     Cabecera de la transacción con el juego de datos
  PERFORM crea_cabecera_jd USING juego_datos.

  PERFORM crea_cabecera_bbkpf  TABLES t_bkpf_conta
                                USING  juego_datos.

  PERFORM crea_cabecera_bbseg TABLES t_bseg_conta
                                     t_bkpf_conta
                               USING juego_datos
                                     zlifnr .
ENDFORM.                               " F_CARGA_CUENTA

*&---------------------------------------------------------------------*
*&      Form  CREA_CABECERA_JD
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->FICHERO    text
*----------------------------------------------------------------------*
FORM crea_cabecera_jd USING fichero.

  MOVE: '0'            TO bgr00-stype,
        fichero        TO bgr00-group,
        sy-mandt       TO bgr00-mandt,
        sy-uname       TO bgr00-usnam,
        ' '            TO bgr00-xkeep,
        '/'            TO bgr00-nodata.
  TRANSFER bgr00 TO fichero.

ENDFORM.                               "F_BATCH_DOCU

*&---------------------------------------------------------------------*
*&      Form  CREA_CABECERA_BBKPF
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->FICHERO    text
*----------------------------------------------------------------------*
FORM crea_cabecera_bbkpf TABLES t_bkpf_conta STRUCTURE bkpf
                         USING fichero.
  LOOP AT t_bkpf_conta.
    MOVE: '1'                   TO bbkpf-stype,
          'FB01'                TO bbkpf-tcode,    "Cod. transaccion
          t_bkpf_conta-blart      TO bbkpf-blart,    "Clase documento
          t_bkpf_conta-bukrs      TO bbkpf-bukrs,    "Sociedad
          t_bkpf_conta-monat      TO bbkpf-monat,    "Mes contable
          t_bkpf_conta-waers      TO bbkpf-waers,    "Moneda
          t_bkpf_conta-bktxt      TO bbkpf-bktxt.    "Texto Cab.Docto

    CONCATENATE t_bkpf_conta-bldat+6(2)
                t_bkpf_conta-bldat+4(2)
                t_bkpf_conta-bldat+0(4) INTO bbkpf-bldat.

    CONCATENATE t_bkpf_conta-budat+6(2)
                t_bkpf_conta-budat+4(2)
                t_bkpf_conta-budat+0(4) INTO bbkpf-budat.

    IF t_bkpf_conta-kursf NE space.
      MOVE t_bkpf_conta-kursf    TO bbkpf-kursf.
    ENDIF.
    IF t_bkpf_conta-belnr NE space.
      MOVE t_bkpf_conta-belnr    TO bbkpf-belnr.
    ENDIF.
*    IF T_BKPF_CONTA-WWERT NE SPACE.
*      MOVE T_BKPF_CONTA-WWERT    TO BBKPF-WWERT.
*    ENDIF.
    IF t_bkpf_conta-xblnr NE space.
      MOVE t_bkpf_conta-xblnr    TO bbkpf-xblnr.
    ENDIF.
    TRANSFER bbkpf TO fichero.
    PERFORM inicializa_jd USING bbkpf.
  ENDLOOP.
ENDFORM.                               "F_CREA_CABECERA_BBKPF

*&---------------------------------------------------------------------*
*&      Form  CREA_CABECERA_BBSEG
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->FICHERO    text
*----------------------------------------------------------------------*
FORM crea_cabecera_bbseg    TABLES t_bseg_conta STRUCTURE bseg
                                   t_bkpf_conta STRUCTURE bkpf
                            USING fichero
                                  zlifnr .



  LOOP AT t_bseg_conta.
* HCD cambia de g_wrbtr(10) a g_wrbtr(13) 04-01-2017
    DATA :  g_wrbtr(13),
              g_wrbtri TYPE p DECIMALS 0.


    IF t_bseg_conta-wrbtr < 0.
      t_bseg_conta-wrbtr  =  t_bseg_conta-wrbtr  * -1.
    ENDIF.

    g_wrbtr =  t_bseg_conta-wrbtr.
* HCD cambia de DO 10 TIMES. a DO 13 TIMES. 04-01-2017
    DO 13 TIMES.
      REPLACE '.'  WITH ' ' INTO  g_wrbtr.
    ENDDO.
    CONDENSE g_wrbtr NO-GAPS.

    MOVE: '2'                   TO bbseg-stype,
          'BBSEG'               TO bbseg-tbnam,
          t_bseg_conta-bschl    TO bbseg-newbs.    "Clave contabil.

    IF t_bseg_conta-bschl EQ 31 OR t_bseg_conta-bschl EQ 21.
      MOVE:
              t_bseg_conta-lifnr      TO bbseg-newko,    "Cuenta
              t_bseg_conta-lifnr      TO zlifnr,
              g_wrbtr                 TO bbseg-wrbtr.    "Importe mon doc


*---------------------------------------------------------------------------
* AGREGO PARA QUE SEA COMPATIBLE CON CAMBIO DE CUENTAS HCD 2012-05-15
*---------------------------------------------------------------------------
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*        SELECT SINGLE *
*        FROM  lfb1
*        WHERE lifnr EQ zlifnr
*        AND   bukrs EQ t_bkpf_conta-bukrs.
*
* NEW CODE
        SELECT *
        UP TO 1 ROWS 
        FROM  lfb1
        WHERE lifnr EQ zlifnr
        AND   bukrs EQ t_bkpf_conta-bukrs ORDER BY PRIMARY KEY.

        ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01

       IF     t_bseg_conta-SAKNR NE lfb1-akont .
               bbseg-hkont = t_bseg_conta-HKONT.
       ENDIF.
*---------------------------------------------------------------------------
* AGREGO PARA QUE SEA COMPATIBLE CON CAMBIO DE CUENTAS HCD 2012-05-15
*---------------------------------------------------------------------------

* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*      SELECT SINGLE *
*        FROM lfbw
*      WHERE lifnr EQ zlifnr
*      AND   bukrs EQ t_bkpf_conta-bukrs.
*
* NEW CODE
      SELECT *
      UP TO 1 ROWS 
        FROM lfbw
      WHERE lifnr EQ zlifnr
      AND   bukrs EQ t_bkpf_conta-bukrs ORDER BY PRIMARY KEY.

      ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
      IF sy-subrc EQ 0 AND lfbw-wt_subjct EQ 'X'.
        MOVE: '2'                   TO bwith-stype,
        'BWITH'               TO bwith-tbnam.
        bwith-witht = 'X'.
        bwith-wt_withcd = space.
        TRANSFER bwith TO juego_datos.
        PERFORM inicializa_jd USING bwith.
      ENDIF.
    ELSE.
      IF t_bseg_conta-bschl >= 70.
** Modificado por L_FOUBERT 03.07.2013 Se agrega Subnumero a AF.
      CONCATENATE t_bseg_conta-anln1 '-' t_bseg_conta-anln2 INTO bbseg-newko.
        MOVE:
*                t_bseg_conta-anln1      TO bbseg-newko,    "Cuenta " Log Anterior
** END Modificación L_FOUBERT 03.07.2013 Se agrega Subnumero a AF.
                g_wrbtr      TO bbseg-wrbtr.    "Importe mon doc

        bbseg-anbwa = t_bseg_conta-anbwa.
      ELSE.
        IF t_bseg_conta-bschl >= 40 AND t_bseg_conta-bschl <= 50.
          MOVE:
                    t_bseg_conta-hkont      TO bbseg-newko,    "Cuenta
                    g_wrbtr      TO bbseg-wrbtr.    "Importe mon doc

          IF t_bseg_conta-kontt = 'X'.
            DATA: amt_doccur LIKE bbseg-wrbtr.
            DATA: v_hkont  LIKE bseg-hkont,
                  v_kschl  TYPE kschl.

            READ TABLE t_bkpf_conta INDEX 1.

* Comentado por LSC 17.10.2011 - Prime Group
*            PERFORM steuerbasis_fw_rechnen  USING  t_bseg_conta-wrbtr
*                                                   t_bkpf_conta-bukrs
*                                                   t_bkpf_conta-budat
*                                                   t_bkpf_conta-waers
*                                                   t_bseg_conta-buzei
*                                                   t_bseg_conta-mwskz
*                                             CHANGING amt_doccur
*                                                     v_hkont
*                                                      v_kschl.
*
            DATA :  g_wrbtr2(16).
*            g_wrbtr2    = amt_doccur.
*            DO 10 TIMES.
*              REPLACE '.'  WITH ' ' INTO  g_wrbtr2.
*            ENDDO.
* Fin comentado

*           Inicio
*           LSC - 17.10.2011 - Ajuste para el calculo del neto en el registro de IVA
            DATA: vl_reg_det LIKE bseg,
                  p_amt_base LIKE bseg-wrbtr.

            p_amt_base = 0.
* agrego    AND MWSKZ NE 'C0' en la query de loop para que no sume exento en base iva 10 abril 2012 HCD
            LOOP AT t_bseg_conta INTO vl_reg_det WHERE koart NE 'K' AND kontt NE 'X' AND MWSKZ NE 'C0' .
              p_amt_base = p_amt_base + vl_reg_det-wrbtr.
            ENDLOOP.
            IF p_amt_base < 0. "Para el caso de notas de credito
              p_amt_base = p_amt_base * -1.
            ENDIF.

            g_wrbtr2 = p_amt_base.
            TRANSLATE g_wrbtr2 USING '. '.
*           Fin Inicio LSC

            CONDENSE g_wrbtr2 NO-GAPS.
            bbseg-fwbas = g_wrbtr2.
            bbseg-mwskz = t_bseg_conta-mwskz.
          ENDIF.
        ENDIF.
      ENDIF.
    ENDIF.



    IF t_bseg_conta-zuonr NE space.
      MOVE t_bseg_conta-zuonr    TO bbseg-zuonr.
    ENDIF.
    IF t_bseg_conta-sgtxt NE space.
      MOVE t_bseg_conta-sgtxt    TO bbseg-sgtxt.
    ENDIF.
    IF t_bseg_conta-hbkid NE space.
      MOVE t_bseg_conta-hbkid TO bbseg-hbkid.
    ENDIF.
    IF t_bseg_conta-hktid NE space.
      MOVE t_bseg_conta-hktid TO bbseg-hktid.
    ENDIF.
    IF t_bseg_conta-zzprestac NE space.
      MOVE t_bseg_conta-zzprestac TO bbseg-zzprestac.
    ENDIF.
    IF t_bseg_conta-zzunid_pro NE space.
      MOVE t_bseg_conta-zzunid_pro TO bbseg-zzunid_pro.
    ENDIF.
    IF t_bseg_conta-zzdesc_est NE space.
      MOVE t_bseg_conta-zzdesc_est TO bbseg-zzdesc_est.
    ENDIF.
    IF t_bseg_conta-zzmot_emis NE space.
      MOVE t_bseg_conta-zzmot_emis TO bbseg-zzmot_emis.
    ENDIF.
    IF t_bseg_conta-zzrut_terc NE space.
      MOVE t_bseg_conta-zzrut_terc TO bbseg-zzrut_terc.
    ENDIF.
    IF t_bseg_conta-zz_agencia NE space.
      MOVE t_bseg_conta-zz_agencia TO bbseg-zz_agencia.
    ENDIF.
    IF t_bseg_conta-fdlev      NE space.
      MOVE t_bseg_conta-fdlev TO bbseg-fdlev.
    ENDIF.
    IF t_bseg_conta-empfb      NE space.
      MOVE t_bseg_conta-empfb TO bbseg-empfb.
    ENDIF.
    IF t_bseg_conta-xref1 NE space.
      MOVE t_bseg_conta-xref1 TO bbseg-xref1.
    ENDIF.
    IF t_bseg_conta-xref2 NE space.
      MOVE t_bseg_conta-xref2 TO bbseg-xref2.
    ENDIF.
    IF t_bseg_conta-xref3 NE space.
      MOVE t_bseg_conta-xref3 TO bbseg-xref3.
    ENDIF.
    IF t_bseg_conta-kostl NE space.
      MOVE t_bseg_conta-kostl TO bbseg-kostl.
    ENDIF.
    IF t_bseg_conta-prctr  NE space.
      MOVE t_bseg_conta-prctr TO bbseg-prctr.
    ENDIF.
    IF t_bseg_conta-zterm  NE space.
      MOVE t_bseg_conta-zterm TO bbseg-zterm.
    ENDIF.
    IF t_bseg_conta-zfbdt  NE '00000000'.
* LSC - 14.10.2011 Se corrige formato para ingreso mediante Batch Input
      CONCATENATE t_bseg_conta-zfbdt+6(2) t_bseg_conta-zfbdt+4(2)
                  t_bseg_conta-zfbdt(4) INTO bbseg-zfbdt.
*      MOVE t_bseg_conta-zfbdt TO bbseg-zfbdt.
    ENDIF.
    IF t_bseg_conta-zlsch  NE space.
      MOVE t_bseg_conta-zlsch TO bbseg-zlsch.
    ENDIF.
    IF t_bseg_conta-zlspr NE space.
      MOVE t_bseg_conta-zlspr TO bbseg-zlspr.
    ENDIF.





    TRANSFER bbseg TO fichero.
    PERFORM inicializa_jd USING bbseg.
  ENDLOOP.
ENDFORM.                    "CREA_CABECERA_BBSEG

*&---------------------------------------------------------------------*
*&      Form  INICIALIZA_JD
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->TABLA      text
*----------------------------------------------------------------------*
FORM   inicializa_jd USING tabla.
  DATA: l_acumu TYPE i.
  DO.
    ADD 1 TO l_acumu.
    ASSIGN COMPONENT l_acumu OF STRUCTURE tabla TO <f>.
    IF sy-subrc NE 0. EXIT. ENDIF.
    MOVE '/' TO <f>.
  ENDDO.

ENDFORM.                    "INICIALIZA_JD


*---------------------------------------------------------------------*
*       RUTINA                                                        *
*---------------------------------------------------------------------*
*        Rechnen Steuerbasisbetrag mit MWSKZ, T007A.                  *
*---------------------------------------------------------------------*
FORM steuerbasis_fw_rechnen USING  t_bseg_conta-wrbtr
                                                   t_bkpf_conta-bukrs
                                                   t_bkpf_conta-budat
                                                   t_bkpf_conta-waers
                                                   t_bseg_conta-buzei
                                                   t_bseg_conta-mwskz
                                             CHANGING amt_base
                                                     v_hkont
                                                     v_kschl.
  DATA: taxcom LIKE taxcom.
  DATA:   hfwnaf       LIKE bsez-fwnaf,
          refe1(16)    TYPE p,
          refe2(16)    TYPE p,
          xfwnaf       LIKE bsez-fwnaf,
          xhwbas       LIKE bset-hwbas,
          xdmbtr       LIKE bseg-dmbtr,
          xmwsts       LIKE bseg-mwsts,
          xanz(1)      TYPE c,
          xkurs        LIKE bkpf-kursf,
          xkzinc(1)    TYPE c,
          xmwst(1)     TYPE c,
          xpruef(1)    TYPE c,
          xwwert       LIKE bkpf-wwert.
  DATA:   tkurs        LIKE bkpf-txkrs.
  DATA: v_fwnaf LIKE bsez-fwnaf.
  DATA: t_mwdat LIKE rtax1u15 OCCURS 0  WITH HEADER LINE.
  taxcom-bukrs = t_bkpf_conta-bukrs.
  taxcom-budat = t_bkpf_conta-budat.
  taxcom-waers = t_bkpf_conta-waers.
  taxcom-kposn = t_bseg_conta-buzei.
  taxcom-mwskz = t_bseg_conta-mwskz .

  taxcom-koart = 'S'.
  IF t_bseg_conta-wrbtr > 0.
    taxcom-shkzg = 'S'.
  ELSE.
    taxcom-shkzg = 'H'.
  ENDIF.
  taxcom-wrbtr = 9000000000.    " MMT   one Zero deleted
  taxcom-wmwst = 0.
  taxcom-wskto = 0.
  taxcom-skfbt = 0.
  taxcom-zbd1p = 0.
  taxcom-xmwst = 'X'.
  xpruef = space.
  DATA: v_fwbas LIKE bseg-fwbas.

  CALL FUNCTION 'CALCULATE_TAX_ITEM'
    EXPORTING
      dialog              = space
      inklusive           = 'X'
      i_taxcom            = taxcom
      pruefen             = xpruef
      reset               = space
    IMPORTING
      e_taxcom            = taxcom
      nav_anteil          = v_fwnaf
    EXCEPTIONS
      mwskz_not_found     = 04
      mwskz_not_defined   = 04
      steuerbetrag_falsch = 08.
  CASE sy-subrc.
    WHEN 04.
*      MESSAGE E201 WITH BSEG-MWSKZ T001-LAND1.
    WHEN 08.
  ENDCASE.

  taxcom-wrbtr = taxcom-wrbtr - taxcom-wmwst.
  refe1 = t_bseg_conta-wrbtr * taxcom-wrbtr.
  v_fwbas = refe1 / taxcom-wmwst.

  amt_base =  v_fwbas.
* Busca KONV
  CALL FUNCTION 'CALCULATE_TAX_ITEM'
    EXPORTING
      dialog     = space
      inklusive  = 'X'
      i_taxcom   = taxcom
      pruefen    = xpruef
      reset      = 'X'
    IMPORTING
      e_taxcom   = taxcom
      nav_anteil = v_fwnaf.

  DATA: v_i_wrbtr  LIKE bseg-wrbtr.
  v_i_wrbtr = amt_base.

  CALL FUNCTION 'CALCULATE_TAX_FROM_NET_AMOUNT'
    EXPORTING
      i_bukrs           = t_bkpf_conta-bukrs
      i_mwskz           = t_bseg_conta-mwskz
      i_waers           = t_bkpf_conta-waers
      i_wrbtr           = v_i_wrbtr
    TABLES
      t_mwdat           = t_mwdat
    EXCEPTIONS
      bukrs_not_found   = 1
      country_not_found = 2
      mwskz_not_defined = 3
      mwskz_not_valid   = 4
      ktosl_not_found   = 5
      kalsm_not_found   = 6
      parameter_error   = 7
      knumh_not_found   = 8
      kschl_not_found   = 9
      unknown_error     = 10
      account_not_found = 11
      txjcd_not_valid   = 12
      OTHERS            = 13.
  IF sy-subrc = 0.
    READ TABLE t_mwdat INDEX 1.
    IF sy-subrc EQ 0.
      v_hkont =   t_mwdat-hkont.
      v_kschl =  t_mwdat-kschl.
    ENDIF.
  ENDIF.
ENDFORM.                    "STEUERBASIS_FW_RECHNEN
