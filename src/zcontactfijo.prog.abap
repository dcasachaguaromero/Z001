*&---------------------------------------------------------------------*
*&  Include           ZCONTACTFIJO
*&---------------------------------------------------------------------*
TABLES: BBKPF,      "Cab.documento para documento contable (estruct. bat
        BBSEG,      "Segmento de documento contable (estruct. batch inpu
        BGR00,      "Estructura batch input para datos de juego de datos
        BWITH,
        LFBW.

DATA: BEGIN OF ARCH_PLANO OCCURS 100,
      INDDOC(1),                      "Indice documento
      BLDAT(10),                      "Fecha documento (AAAAMMDD)
      BLART(2),                       "Clase documento
      BUKRS(4),                       "Sociedad
      BUDAT(10),                      "Fecha contabil. (AAAAMMDD)
      MONAT(2),                       "Periodo
      WAERS(4),                       "Moneda
      KURSF(9),                       "Tipo Cambio Conversion
      BELNR(10),                      "Nº Documento
      WWERT(8),                       "Fecha Conversion
      XBLNR(16),                      "Referencia
      BKTXT(25),                      "Texto Cabecera de docto.
      NEWBS(2),                       "Clave contabil.
      NEWKO(17),                      "Cuenta
      NEWUM(1),                       "Indicador CME
      NEWBW(3),                       "Clase Mov.Act.Fijo
      WRBTR(13),                      "Importe moneda documento
      DMBTR(13),                      "Importe moneda Local
      ZFBDT(10),                      "Vence
      ZTERM(4),                       "Condicion de Pago
      VALUT(10),                      "Fecha Valor
      ZLSPR(1),                       "Bloqueo de pago
      ZLSCH(1),                       "Vta. de pago
      BANKL(15),                      "Clave de banco
      BANKS(2),                       "Pais Banco
      BANKN(1),                       "Cta. Corriente
      HBKID(1),                       "Banco Propio
      REGUL(1),                       "Receptor Pago Ind.
      NAME1(35),                      "Nombre rec. de pago
      NAME3(35),                      "Nombre rec. de pago para ch
      ORT01(35),                      "Ciudad
      ZUONR(18),                      "Asignacion
      SGTXT(50),                      "Texto Posicion
      KOSTL(10),                      "Centro Costo
      SKFBT(16),                      "Base de descuento
      AUFNR(12),                      "Número de Orden
      MENGE(15),                      "CANTIDAD VENDIDA (*)
      MEINS(3),                       "UNIDAD DE MEDIDA (*)



   END OF ARCH_PLANO.

DATA: NOMBRE_LOGICO LIKE V_FILENACI-FILEINTERN VALUE
                    'Z_INTERFAZ_FI',
                    JUEGO_DATOS(75),
                    ARCH_ENTRADA(75),
                    NOM_JD1(12),
                    FECHA_JD LIKE SY-DATUM,
                    REG(44),
                    NUEVO_DOCTO(1).


FIELD-SYMBOLS: <F>, <F1>         .
TABLES:
*  BGR00,                        " Mappenvorsatz
*         BBKPF,                        " Belegkopf + Tcode
*         BBSEG,                        " Belegsegment.
         BBTAX,                        " Belegsteuern.
*         BWITH,                        " Quellensteuer
         BSELK,                        " Selektionsdaten Kopf
         BSELP.                        " Selektionsdaten Position

*TABLES:  TBSL.                         " Buchungsschlüssel
TABLES:  T041A.                        " Ausgleichsvorgänge
*TABLES:  T100.                         " Nachrichten


DATA:   BEGIN OF FTPOST OCCURS 100.
        INCLUDE STRUCTURE FTPOST.
DATA:   END OF FTPOST.

DATA:   BEGIN OF FTCLEAR OCCURS 20.
        INCLUDE STRUCTURE FTCLEAR.
DATA:   END OF FTCLEAR.

DATA:   BEGIN OF FTTAX OCCURS 0.
        INCLUDE STRUCTURE FTTAX.
DATA:   END OF FTTAX.

DATA:   BEGIN OF XBLNTAB  OCCURS 2.
        INCLUDE STRUCTURE BLNTAB.
DATA:   END OF XBLNTAB.


DATA:    BEGIN OF SAVE_FTCLEAR.
        INCLUDE STRUCTURE FTCLEAR.
DATA:    END OF SAVE_FTCLEAR.

*------- Tabelle T_BBKPF enthält Belegkopf + Tcode  --------------------
DATA:    T_BBKPF LIKE BBKPF OCCURS 1.

*------- Tabelle T_BBSEG enthält Belegsegment --------------------------
DATA:    T_BBSEG LIKE BBSEG_DI OCCURS 50.

*------- Tabelle T_BBTAX enthält Steuerdaten ---------------------------
DATA:    T_BBTAX LIKE BBTAX OCCURS 50.

*------- Tabelle T_BWITH enthält Quellensteuerdaten --------------------
DATA:    T_BWITH LIKE BWITH_DI OCCURS 50.

*------- Tabelle FFILE enthält alle Datensätze -------------------------
DATA:    BEGIN OF TFILE OCCURS 0,
           REC(3300)  TYPE C,
         END OF TFILE.
DATA:    BEGIN OF EFILE OCCURS 100,
           REC(3300)  TYPE C,
         END OF EFILE.
DATA:    BEGIN OF ERTAB OCCURS 5,
           REC(3300)  TYPE C,
         END OF ERTAB.

*------- Feld-Informationen aus NAMETAB --------------------------------
DATA:    BEGIN OF NAMETAB OCCURS 120.
        INCLUDE STRUCTURE DNTAB.
DATA:    END OF NAMETAB.

*------- Tabelle XT001 -------------------------------------------------
DATA:    BEGIN OF XT001 OCCURS 5.
        INCLUDE STRUCTURE T001.
DATA:    END OF XT001.

*------- Tabelle XTBSL -------------------------------------------------
DATA:    BEGIN OF XTBSL OCCURS 10.
        INCLUDE STRUCTURE TBSL.
DATA:    END OF XTBSL.


*------- Tabelle XT041A ------------------------------------------------
DATA:    BEGIN OF XT041A OCCURS 5,
           AUGLV        LIKE T041A-AUGLV,
         END OF XT041A.

*eject
*---------------------------------------------------------------------*
*        Strukturen
*---------------------------------------------------------------------*
*------- Initialstrukturen --------------------------------------------
DATA:    BEGIN OF I_BBKPF.
        INCLUDE STRUCTURE BBKPF.       " Belegkopf
DATA:    END OF I_BBKPF.

DATA:    BEGIN OF I_BBSEG.
        INCLUDE STRUCTURE BBSEG.       " Belegsegment
DATA:    END OF I_BBSEG.

DATA:    BEGIN OF I_BBTAX.
        INCLUDE STRUCTURE BBTAX.       " Belegsteuern
DATA:    END OF I_BBTAX.

DATA:    BEGIN OF I_BSELK.
        INCLUDE STRUCTURE BSELK.       " Selektionsdaten Kopf
DATA:    END OF I_BSELK.

DATA:    BEGIN OF I_BSELP.
        INCLUDE STRUCTURE BSELP.       " Selektionsdaten Position
DATA:    END OF I_BSELP.

DATA:    BEGIN OF I_BWITH.
        INCLUDE STRUCTURE BWITH.       " Quellensteuer
DATA:    END OF I_BWITH.

*------- Hilfsstrukturen für Direct Input ------------------------------
DATA:    BEGIN OF WA_BBSEG_DI.
        INCLUDE STRUCTURE BBSEG_DI.
DATA:    END OF WA_BBSEG_DI.

DATA:    BEGIN OF WA_BWITH_DI.
        INCLUDE STRUCTURE BWITH_DI.
DATA:    END OF WA_BWITH_DI.

DATA:    BEGIN OF TRANS OCCURS 0,
           X     TYPE C,
           C_00  TYPE C VALUE ' ',
           SOH   TYPE C,
           C_01  TYPE C VALUE ' ',
           STX   TYPE C,
           C_02  TYPE C VALUE ' ',
           ETX   TYPE C,
           C_03  TYPE C VALUE ' ',
           EOT   TYPE C,
           C_04  TYPE C VALUE ' ',
           ENQ   TYPE C,
           C_05  TYPE C VALUE ' ',
           ACK   TYPE C,
           C_06  TYPE C VALUE ' ',
           BEL   TYPE C,
           C_07  TYPE C VALUE ' ',
           BS    TYPE C,
           C_08  TYPE C VALUE ' ',
           HT    TYPE C,
           C_09  TYPE C VALUE ' ',
           LF    TYPE C,
           C_0A  TYPE C VALUE ' ',
           VT    TYPE C,
           C_0B  TYPE C VALUE ' ',
           FF    TYPE C,
           C_0C  TYPE C VALUE ' ',
           CR    TYPE C,
           C_0D  TYPE C VALUE ' ',
           SO    TYPE C,
           C_0E  TYPE C VALUE ' ',
           SI    TYPE C,
           C_0F  TYPE C VALUE ' ',
           DLE   TYPE C,
           C_10  TYPE C VALUE ' ',
           DC1   TYPE C,
           C_11  TYPE C VALUE ' ',
           DC2   TYPE C,
           C_12  TYPE C VALUE ' ',
           DC3   TYPE C,
           C_13  TYPE C VALUE ' ',
           DC4   TYPE C,
           C_14  TYPE C VALUE ' ',
           NAK   TYPE C,
           C_15  TYPE C VALUE ' ',
           SYN   TYPE C,
           C_16  TYPE C VALUE ' ',
           ETB   TYPE C,
           C_17  TYPE C VALUE ' ',
           CAN   TYPE C,
           C_18  TYPE C VALUE ' ',
           EM    TYPE C,                                "#EC NO_M_RISC3
           C_19  TYPE C VALUE ' ',
           SUB   TYPE C,
           C_1A  TYPE C VALUE ' ',
           ESC   TYPE C,
           C_1B  TYPE C VALUE ' ',
           FS    TYPE C,
           C_1C  TYPE C VALUE ' ',
           GS    TYPE C,
           C_1D  TYPE C VALUE ' ',
           RS    TYPE C,
           C_1E  TYPE C VALUE ' ',
           US    TYPE C,
           C_1F  TYPE C VALUE ' ',
         END OF TRANS.


*------- Workarea zum Lesen der BI-Sätze -------------------------------
*------- wa, ertab, tfile und efile muessen mindestens so lang sein
*------- wie die laengste Batchinput-Struktur BBSEG + kundeneigene
*------- Felder im Include CI_COBL_BI.
*------- Laenge der BBSEG ohne CI_COBL_BI (Stand 3.0F) 1861 Bytes
DATA:    BEGIN OF WA,
           CHAR1(3300)  TYPE C,
         END OF WA.

*eject
*---------------------------------------------------------------------*
*        Einzelfelder
*---------------------------------------------------------------------*
DATA:    BELEG_COUNT(6) TYPE C,        " Anz. Belege je Mappe
         BELEG_BREAK(6) TYPE C,        " Anz. Belege je Mappe
         BUKRS          LIKE BBSEG-NEWBK,   " Buchungskreis
         BBKPF_OK(1)    TYPE C,        " Belegkopf übergeben
         BBSEG_COUNT(3) TYPE N,        " Anz. BSEGS pro Beleg
         BBSEG_TAX(1)   TYPE C.        " Steuer über BBSEG eingegeb

DATA:    CHAR(40)       TYPE C,        " Char. Hilfsfeld
         CHAR1(1)       TYPE C,        " Char. Hilfsfeld
         CHAR2(40)      TYPE C,        " Char. Hilfsfeld
         TFILE_FILL(1)  TYPE C,        " X=TFILE schon gefüllt
         TFSAVE_FILL(1)  TYPE C,       " X=TFSAVE schon gefüllt
         COMMIT_COUNT(4) TYPE N,       " Zähler für Commit
         ALL_COMMIT LIKE TBIST-AKTNUM. " Anzahl der Belege bis zum
" letzten COMMIT

DATA:    DYN_NAME(12)   TYPE C.        " Dynproname

DATA:    ERROR_RUN(1)   TYPE C.        " X = error processing

DATA:    FCODE(5)       TYPE C,        " Funktionscode
         FUNCTION       LIKE  RFIPI-FUNCT.  " B= BDC, C= Call Trans
" D-DIRECT INPUT
DATA:    GROUP_COUNT(6) TYPE C,        " Anzahl Mappen
         GROUP_OPEN(1)  TYPE C.        " X=Mappe schon geöffnet

DATA:    LN_BBSEG(8)    TYPE P,        " Länge des BBSEG
         LN_BBKPF(8)    TYPE P,        " Länge des BBKPF
         LN_BSELK(8)    TYPE P,        " Länge des BSELK
         LN_BSELP(8)    TYPE P.        " Länge des BSELP

DATA:    MODE           LIKE  RFPDO-ALLGAZMD.
DATA:    MSGVN          LIKE SY-MSGV1, " Hilfsfeld Message-Variable
         MSGID          LIKE SY-MSGID,
         MSGTY          LIKE SY-MSGTY,
         MSGNO          LIKE SY-MSGNO,
         MSGV1          LIKE SY-MSGV1,
         MSGV2          LIKE SY-MSGV2,
         MSGV3          LIKE SY-MSGV3,
         MSGV4          LIKE SY-MSGV4.

DATA:    N(2)           TYPE N,        " Hilfsfeld num.
         NODATA(1)      TYPE C,        " Keine BI-Daten für Feld
         NODATA_OLD     LIKE NODATA.   " NODATA gemerkt

DATA:    PREFIX_P       LIKE TCURP-PREFIX_P, "price-based rate prefix
         PREFIX_M       LIKE TCURP-PREFIX_P. "quantity-based rate prefix

DATA:    REFE1(8)       TYPE P.        " Hilfsfeld gepackt

DATA:    SATZ2_COUNT(6) TYPE C,        " Anz. Sätze(Typ2) je Trans.
         SATZ2_CNT_AKT  LIKE SATZ2_COUNT,   " Anz. Sätze(Typ2) - 1
         SAVE_TBNAM     LIKE BBSEG-TBNAM,   " gemerkter Tabellenname
         SAVE_BGR00     LIKE BGR00,    " gemerkter BGR00
         SUBRC          LIKE SY-SUBRC, " Subrc
         COUNT          TYPE I.        " Anz. Belege

DATA:    TABIX(2)       TYPE N,        " Tabelleninex
         TBIST_AKTIV(1) TYPE C,        " Restart aktiv?
         TEXT(200)      TYPE C,        " Messagetext
*           TEXT1(40)      TYPE C,        " Messagetext
         TEXT2(40)      TYPE C,        " Messagetext
         TEXT3(40)      TYPE C,        " Messagetext
         TFILL_FTPOST   TYPE I,        " Anz. Einträge in FTPOST
         TFILL_T_BBSEG  TYPE I,        " Anz. Einträge in T_BBSEG
         TFILL_T_BWITH  TYPE I,        " Anz. Einträge in T_BWITH
         TFILL_TFILE    TYPE I,        " Anz. Einträge in TFILE
         TFILL_ERTAB    TYPE I,        " Anz. Einträge in ERTAB
         TFILL_FTC(3)   TYPE N,        " Anz. Einträge in FTC
         TFILL_FTK(3)   TYPE N,        " Anz. Einträge in FTK
         TFILL_FTZ(3)   TYPE N,        " Anz. Einträge in FTZ
         TFILL_041A(1)  TYPE N.        " Anz. Einträge in XT041A


DATA:    WERT(60)       TYPE C,        " Hilfsfeld Feldinhalt
         WT_COUNT       TYPE I.        " Zähler Quellensteuer

DATA:    XBDCC          LIKE RFIPI-XBDCC,   " X=BDC bei Error in CallTra
         XEOF(1)        TYPE C,        " X=End of File erreicht
         XMESS_BBKPF_SENDE(1) TYPE C,  " Message gesendet für BBKPF
         XMESS_BBSEG_SENDE(1) TYPE C,  " Message gesendet für BBSEG
         XMESS_BBTAX_SENDE(1) TYPE C,  " Message gesendet für BBTAX
*        XMWST          LIKE BKPF-XMWST,    " Steuer rechnen
         XNEWG(1)       TYPE C,        " X=Neue Mappe
         XFTCLEAR(1).                  " Append FTCLEAR durchfuehren?

* DATAs wichtig für Wiederaufsetzbarkeit
DATA: AKTNUM LIKE TBIST-AKTNUM.   " Zähler für aktuell bearbeiteter Satz
DATA: STARTNUM LIKE TBIST-AKTNUM.      " erster zu bearbeitender Satz
*ata: is_error.                   " übergebene Satznummer war fehlerhaft
DATA: NUMERROR LIKE TBIST-NUMERROR.    " Anzahl Fehler in diesem Schritt
DATA: OLDERROR LIKE TBIST-NUMERROR.    " Anzahl Fehler aus dem
" vorherigen Job.
DATA: LASTERRNUM LIKE TBIST-LASTNUM.   "Letzte Fehlernummer
DATA: NOSTART LIKE TBIST-NOSTARTING VALUE 'X'. " Start-Infos schreiben ?
DATA: JOBID LIKE TBTCO-JOBNAME.
DATA: JOBID_EXT LIKE TBTCO-JOBNAME.
CONSTANTS:   PACK_SIZE TYPE I VALUE '250',
             C_MSGID   LIKE SY-MSGID VALUE 'FB'.

TABLES: TERRD,
        TFSAVE.

*-----------------------------------------------------------------------
*        Konstanten und Field-Symbols
*-----------------------------------------------------------------------
DATA:    C_NODATA(1)    TYPE C VALUE '/',   " Default für NODATA
         XON                   VALUE 'X'.   " Flag eingeschaltet

DATA:    FMF1GES(1)     TYPE X VALUE '20'.  " Beide Flags aus: Input.
DATA:    FMB1NUM(1)     TYPE X VALUE '10'.  "       "

DATA:    MAX_COMMIT(4)  TYPE N.        " Max. Belege je Commit

DATA:    REP_NAME_A(8)  TYPE C VALUE 'SAPMF05A'. " Mpool SAPMF05A
DATA:    REP_NAME_C(8)  TYPE C VALUE 'SAPLFCPD'. " Mpool SAPLFCPD
DATA:    REP_NAME_K(8)  TYPE C VALUE 'SAPLKACB'. " Mpool SAPLKACB

*  FIELD-SYMBOLS: <F1>.
*------- Feldinformationen aus NAMETAB ---------------------------------
*DATA:    BEGIN OF NAMETAB OCCURS 120.
*           INCLUDE STRUCTURE DNTAB.
*DATA:    END OF NAMETAB.

*------- Initialstrukturen ---------------------------------------------
DATA:    BEGIN OF I_BGR00.
        INCLUDE STRUCTURE BGR00.    " Mappenvorsatz
DATA:    END OF I_BGR00.

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
FORM CREAR_JUEGO_DATOS TABLES T_BKPF_CONTA STRUCTURE BKPF
                               T_BSEG_CONTA STRUCTURE BSEG.
  DATA: ZLIFNR LIKE LFA1-LIFNR.
*     Cabecera de la transacción con el juego de datos
  PERFORM CREA_CABECERA_JD USING JUEGO_DATOS.

  PERFORM CREA_CABECERA_BBKPF  TABLES T_BKPF_CONTA
                                USING  JUEGO_DATOS.

  PERFORM CREA_CABECERA_BBSEG TABLES T_BSEG_CONTA
                                     T_BKPF_CONTA
                               USING JUEGO_DATOS
                                     ZLIFNR .
ENDFORM.                               " F_CARGA_CUENTA

*&---------------------------------------------------------------------*
*&      Form  CREA_CABECERA_JD
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->FICHERO    text
*----------------------------------------------------------------------*
FORM CREA_CABECERA_JD USING FICHERO.

  MOVE: '0'            TO BGR00-STYPE,
        FICHERO        TO BGR00-GROUP,
        SY-MANDT       TO BGR00-MANDT,
        SY-UNAME       TO BGR00-USNAM,
        ' '            TO BGR00-XKEEP,
        '/'            TO BGR00-NODATA.
  TRANSFER BGR00 TO FICHERO.

ENDFORM.                               "F_BATCH_DOCU

*&---------------------------------------------------------------------*
*&      Form  CREA_CABECERA_BBKPF
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->FICHERO    text
*----------------------------------------------------------------------*
FORM CREA_CABECERA_BBKPF TABLES T_BKPF_CONTA STRUCTURE BKPF
                         USING FICHERO.
  LOOP AT T_BKPF_CONTA.
    MOVE: '1'                   TO BBKPF-STYPE,
          'FB01'                TO BBKPF-TCODE,    "Cod. transaccion
          T_BKPF_CONTA-BLART      TO BBKPF-BLART,    "Clase documento
          T_BKPF_CONTA-BUKRS      TO BBKPF-BUKRS,    "Sociedad
          T_BKPF_CONTA-MONAT      TO BBKPF-MONAT,    "Mes contable
          T_BKPF_CONTA-WAERS      TO BBKPF-WAERS,    "Moneda
          T_BKPF_CONTA-BKTXT      TO BBKPF-BKTXT.    "Texto Cab.Docto

    CONCATENATE T_BKPF_CONTA-BLDAT+6(2)
                T_BKPF_CONTA-BLDAT+4(2)
                T_BKPF_CONTA-BLDAT+0(4) INTO BBKPF-BLDAT.

    CONCATENATE T_BKPF_CONTA-BUDAT+6(2)
                T_BKPF_CONTA-BUDAT+4(2)
                T_BKPF_CONTA-BUDAT+0(4) INTO BBKPF-BUDAT.

    IF T_BKPF_CONTA-KURSF NE SPACE.
      MOVE T_BKPF_CONTA-KURSF    TO BBKPF-KURSF.
    ENDIF.
    IF T_BKPF_CONTA-BELNR NE SPACE.
      MOVE T_BKPF_CONTA-BELNR    TO BBKPF-BELNR.
    ENDIF.
*    IF T_BKPF_CONTA-WWERT NE SPACE.
*      MOVE T_BKPF_CONTA-WWERT    TO BBKPF-WWERT.
*    ENDIF.
    IF T_BKPF_CONTA-XBLNR NE SPACE.
      MOVE T_BKPF_CONTA-XBLNR    TO BBKPF-XBLNR.
    ENDIF.
    TRANSFER BBKPF TO FICHERO.
    PERFORM INICIALIZA_JD USING BBKPF.
  ENDLOOP.
ENDFORM.                               "F_CREA_CABECERA_BBKPF

*&---------------------------------------------------------------------*
*&      Form  CREA_CABECERA_BBSEG
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->FICHERO    text
*----------------------------------------------------------------------*
FORM CREA_CABECERA_BBSEG    TABLES T_BSEG_CONTA STRUCTURE BSEG
                                   T_BKPF_CONTA STRUCTURE BKPF
                            USING FICHERO
                                  ZLIFNR .



  LOOP AT T_BSEG_CONTA.

    DATA :  G_WRBTR(10),
              G_WRBTRI TYPE P DECIMALS 0.


    IF T_BSEG_CONTA-WRBTR < 0.
      T_BSEG_CONTA-WRBTR  =  T_BSEG_CONTA-WRBTR  * -1.
    ENDIF.

    G_WRBTR =  T_BSEG_CONTA-WRBTR.

    DO 10 TIMES.
      REPLACE '.'  WITH ' ' INTO  G_WRBTR.
    ENDDO.
    CONDENSE G_WRBTR NO-GAPS.

    MOVE: '2'                   TO BBSEG-STYPE,
          'BBSEG'               TO BBSEG-TBNAM,
          T_BSEG_CONTA-BSCHL    TO BBSEG-NEWBS.    "Clave contabil.

    IF T_BSEG_CONTA-BSCHL EQ 31.
      MOVE:
              T_BSEG_CONTA-LIFNR      TO BBSEG-NEWKO,    "Cuenta
              T_BSEG_CONTA-LIFNR      TO ZLIFNR,
              G_WRBTR                 TO BBSEG-WRBTR.    "Importe mon doc
              SELECT SINGLE *
                FROM LFBW
              WHERE LIFNR EQ ZLIFNR
              AND   BUKRS EQ T_BKPF_CONTA-BUKRS.
              IF SY-SUBRC EQ 0 AND LFBW-WT_SUBJCT EQ 'X'.
                MOVE: '2'                   TO BWITH-STYPE,
                'BWITH'               TO BWITH-TBNAM.
                BWITH-WITHT = 'X'.
                BWITH-WT_WITHCD = SPACE.
                TRANSFER BWITH TO JUEGO_DATOS.
                PERFORM INICIALIZA_JD USING BWITH.
              ENDIF.
    ELSE.
      IF T_BSEG_CONTA-BSCHL >= 70.
        MOVE:
                T_BSEG_CONTA-ANLN1      TO BBSEG-NEWKO,    "Cuenta
                G_WRBTR      TO BBSEG-WRBTR.    "Importe mon doc
        BBSEG-ANBWA = T_BSEG_CONTA-ANBWA.
      ELSE.
        IF T_BSEG_CONTA-BSCHL >= 40 AND T_BSEG_CONTA-BSCHL <= 50.
          MOVE:
                    T_BSEG_CONTA-HKONT      TO BBSEG-NEWKO,    "Cuenta
                    G_WRBTR      TO BBSEG-WRBTR.    "Importe mon doc

          IF T_BSEG_CONTA-KONTT = 'X'.
            DATA: AMT_DOCCUR LIKE BBSEG-WRBTR.
            DATA: V_HKONT  LIKE BSEG-HKONT,
                  V_KSCHL  TYPE KSCHL.

            READ TABLE T_BKPF_CONTA INDEX 1.

            PERFORM STEUERBASIS_FW_RECHNEN  USING  T_BSEG_CONTA-WRBTR
                                                   T_BKPF_CONTA-BUKRS
                                                   T_BKPF_CONTA-BUDAT
                                                   T_BKPF_CONTA-WAERS
                                                   T_BSEG_CONTA-BUZEI
                                                   T_BSEG_CONTA-MWSKZ
                                             CHANGING AMT_DOCCUR
                                                     V_HKONT
                                                      V_KSCHL.

            DATA :  G_WRBTR2(16).
            G_WRBTR2    = AMT_DOCCUR.
            DO 10 TIMES.
              REPLACE '.'  WITH ' ' INTO  G_WRBTR2.
            ENDDO.
            CONDENSE G_WRBTR2 NO-GAPS.
            BBSEG-FWBAS = G_WRBTR2.
            BBSEG-MWSKZ = T_BSEG_CONTA-MWSKZ.
          ENDIF.
        ENDIF.
      ENDIF.
    ENDIF.


    IF T_BSEG_CONTA-ZUONR NE SPACE.
      MOVE T_BSEG_CONTA-ZUONR    TO BBSEG-ZUONR.
    ENDIF.
    IF T_BSEG_CONTA-SGTXT NE SPACE.
      MOVE T_BSEG_CONTA-SGTXT    TO BBSEG-SGTXT.
    ENDIF.
    IF T_BSEG_CONTA-HBKID NE SPACE.
      MOVE T_BSEG_CONTA-HBKID TO BBSEG-HBKID.
    ENDIF.
    IF T_BSEG_CONTA-HKTID NE SPACE.
      MOVE T_BSEG_CONTA-HKTID TO BBSEG-HKTID.
    ENDIF.
    IF T_BSEG_CONTA-ZZPRESTAC NE SPACE.
      MOVE T_BSEG_CONTA-ZZPRESTAC TO BBSEG-ZZPRESTAC.
    ENDIF.
    IF T_BSEG_CONTA-ZZUNID_PRO NE SPACE.
      MOVE T_BSEG_CONTA-ZZUNID_PRO TO BBSEG-ZZUNID_PRO.
    ENDIF.
    IF T_BSEG_CONTA-ZZDESC_EST NE SPACE.
      MOVE T_BSEG_CONTA-ZZDESC_EST TO BBSEG-ZZDESC_EST.
    ENDIF.
    IF T_BSEG_CONTA-ZZMOT_EMIS NE SPACE.
      MOVE T_BSEG_CONTA-ZZMOT_EMIS TO BBSEG-ZZMOT_EMIS.
    ENDIF.
    IF T_BSEG_CONTA-ZZRUT_TERC NE SPACE.
      MOVE T_BSEG_CONTA-ZZRUT_TERC TO BBSEG-ZZRUT_TERC.
    ENDIF.
    IF T_BSEG_CONTA-ZZ_AGENCIA NE SPACE.
      MOVE T_BSEG_CONTA-ZZ_AGENCIA TO BBSEG-ZZ_AGENCIA.
    ENDIF.
    IF T_BSEG_CONTA-FDLEV      NE SPACE.
      MOVE T_BSEG_CONTA-FDLEV TO BBSEG-FDLEV.
    ENDIF.
    IF T_BSEG_CONTA-EMPFB      NE SPACE.
      MOVE T_BSEG_CONTA-EMPFB TO BBSEG-EMPFB.
    ENDIF.
    IF T_BSEG_CONTA-XREF1 NE SPACE.
      MOVE T_BSEG_CONTA-XREF1 TO BBSEG-XREF1.
    ENDIF.
    IF T_BSEG_CONTA-XREF2 NE SPACE.
      MOVE T_BSEG_CONTA-XREF2 TO BBSEG-XREF2.
    ENDIF.
    IF T_BSEG_CONTA-XREF3 NE SPACE.
      MOVE T_BSEG_CONTA-XREF3 TO BBSEG-XREF3.
    ENDIF.
    IF T_BSEG_CONTA-KOSTL NE SPACE.
      MOVE T_BSEG_CONTA-KOSTL TO BBSEG-KOSTL.
    ENDIF.
    IF T_BSEG_CONTA-PRCTR  NE SPACE.
      MOVE T_BSEG_CONTA-PRCTR TO BBSEG-PRCTR.
    ENDIF.
    IF T_BSEG_CONTA-ZTERM  NE SPACE.
      MOVE T_BSEG_CONTA-ZTERM TO BBSEG-ZTERM.
    ENDIF.
    IF T_BSEG_CONTA-ZFBDT  NE '00000000'.
      MOVE T_BSEG_CONTA-ZFBDT TO BBSEG-ZFBDT.
    ENDIF.
    IF T_BSEG_CONTA-ZLSCH  NE SPACE.
      MOVE T_BSEG_CONTA-ZLSCH TO BBSEG-ZLSCH.
    ENDIF.
    IF T_BSEG_CONTA-ZLSPR NE SPACE.
      MOVE T_BSEG_CONTA-ZLSPR TO BBSEG-ZLSPR.
    ENDIF.





    TRANSFER BBSEG TO FICHERO.
    PERFORM INICIALIZA_JD USING BBSEG.
  ENDLOOP.
ENDFORM.                    "CREA_CABECERA_BBSEG

*&---------------------------------------------------------------------*
*&      Form  INICIALIZA_JD
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->TABLA      text
*----------------------------------------------------------------------*
FORM   INICIALIZA_JD USING TABLA.
  DATA: L_ACUMU TYPE I.
  DO.
    ADD 1 TO L_ACUMU.
    ASSIGN COMPONENT L_ACUMU OF STRUCTURE TABLA TO <F>.
    IF SY-SUBRC NE 0. EXIT. ENDIF.
    MOVE '/' TO <F>.
  ENDDO.

ENDFORM.                    "INICIALIZA_JD


*---------------------------------------------------------------------*
*       RUTINA                                                        *
*---------------------------------------------------------------------*
*        Rechnen Steuerbasisbetrag mit MWSKZ, T007A.                  *
*---------------------------------------------------------------------*
FORM STEUERBASIS_FW_RECHNEN USING  T_BSEG_CONTA-WRBTR
                                                   T_BKPF_CONTA-BUKRS
                                                   T_BKPF_CONTA-BUDAT
                                                   T_BKPF_CONTA-WAERS
                                                   T_BSEG_CONTA-BUZEI
                                                   T_BSEG_CONTA-MWSKZ
                                             CHANGING AMT_BASE
                                                     V_HKONT
                                                     V_KSCHL.
  DATA: TAXCOM LIKE TAXCOM.
  DATA:   HFWNAF       LIKE BSEZ-FWNAF,
          REFE1(16)    TYPE P,
          REFE2(16)    TYPE P,
          XFWNAF       LIKE BSEZ-FWNAF,
          XHWBAS       LIKE BSET-HWBAS,
          XDMBTR       LIKE BSEG-DMBTR,
          XMWSTS       LIKE BSEG-MWSTS,
          XANZ(1)      TYPE C,
          XKURS        LIKE BKPF-KURSF,
          XKZINC(1)    TYPE C,
          XMWST(1)     TYPE C,
          XPRUEF(1)    TYPE C,
          XWWERT       LIKE BKPF-WWERT.
  DATA:   TKURS        LIKE BKPF-TXKRS.
  DATA: V_FWNAF LIKE BSEZ-FWNAF.
  DATA: T_MWDAT LIKE RTAX1U15 OCCURS 0  WITH HEADER LINE.
  TAXCOM-BUKRS = T_BKPF_CONTA-BUKRS.
  TAXCOM-BUDAT = T_BKPF_CONTA-BUDAT.
  TAXCOM-WAERS = T_BKPF_CONTA-WAERS.
  TAXCOM-KPOSN = T_BSEG_CONTA-BUZEI.
  TAXCOM-MWSKZ = T_BSEG_CONTA-MWSKZ .

  TAXCOM-KOART = 'S'.
  IF T_BSEG_CONTA-WRBTR > 0.
    TAXCOM-SHKZG = 'S'.
  ELSE.
    TAXCOM-SHKZG = 'H'.
  ENDIF.
  TAXCOM-WRBTR = 9000000000.    " MMT   one Zero deleted
  TAXCOM-WMWST = 0.
  TAXCOM-WSKTO = 0.
  TAXCOM-SKFBT = 0.
  TAXCOM-ZBD1P = 0.
  TAXCOM-XMWST = 'X'.
  XPRUEF = SPACE.
  DATA: V_FWBAS LIKE BSEG-FWBAS.

  CALL FUNCTION 'CALCULATE_TAX_ITEM'
    EXPORTING
      DIALOG              = SPACE
      INKLUSIVE           = 'X'
      I_TAXCOM            = TAXCOM
      PRUEFEN             = XPRUEF
      RESET               = SPACE
    IMPORTING
      E_TAXCOM            = TAXCOM
      NAV_ANTEIL          = V_FWNAF
    EXCEPTIONS
      MWSKZ_NOT_FOUND     = 04
      MWSKZ_NOT_DEFINED   = 04
      STEUERBETRAG_FALSCH = 08.
  CASE SY-SUBRC.
    WHEN 04.
*      MESSAGE E201 WITH BSEG-MWSKZ T001-LAND1.
    WHEN 08.
  ENDCASE.

  TAXCOM-WRBTR = TAXCOM-WRBTR - TAXCOM-WMWST.
  REFE1 = T_BSEG_CONTA-WRBTR * TAXCOM-WRBTR.
  V_FWBAS = REFE1 / TAXCOM-WMWST.

  AMT_BASE =  V_FWBAS.
* Busca KONV
  CALL FUNCTION 'CALCULATE_TAX_ITEM'
    EXPORTING
      DIALOG     = SPACE
      INKLUSIVE  = 'X'
      I_TAXCOM   = TAXCOM
      PRUEFEN    = XPRUEF
      RESET      = 'X'
    IMPORTING
      E_TAXCOM   = TAXCOM
      NAV_ANTEIL = V_FWNAF.

  DATA: V_I_WRBTR  LIKE BSEG-WRBTR.
  V_I_WRBTR = AMT_BASE.

  CALL FUNCTION 'CALCULATE_TAX_FROM_NET_AMOUNT'
    EXPORTING
      I_BUKRS           = T_BKPF_CONTA-BUKRS
      I_MWSKZ           = T_BSEG_CONTA-MWSKZ
      I_WAERS           = T_BKPF_CONTA-WAERS
      I_WRBTR           = V_I_WRBTR
    TABLES
      T_MWDAT           = T_MWDAT
    EXCEPTIONS
      BUKRS_NOT_FOUND   = 1
      COUNTRY_NOT_FOUND = 2
      MWSKZ_NOT_DEFINED = 3
      MWSKZ_NOT_VALID   = 4
      KTOSL_NOT_FOUND   = 5
      KALSM_NOT_FOUND   = 6
      PARAMETER_ERROR   = 7
      KNUMH_NOT_FOUND   = 8
      KSCHL_NOT_FOUND   = 9
      UNKNOWN_ERROR     = 10
      ACCOUNT_NOT_FOUND = 11
      TXJCD_NOT_VALID   = 12
      OTHERS            = 13.
  IF SY-SUBRC = 0.
    READ TABLE T_MWDAT INDEX 1.
    IF SY-SUBRC EQ 0.
      V_HKONT =   T_MWDAT-HKONT.
      V_KSCHL =  T_MWDAT-KSCHL.
    ENDIF.
  ENDIF.
ENDFORM.                    "STEUERBASIS_FW_RECHNEN
