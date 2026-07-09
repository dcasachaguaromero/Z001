*&---------------------------------------------------------------------*
*& Report: < ZEY_GDS_CORRECTION > *
*& Author: < EY_DES03 > *
*& Description: < ReSQ Correction > *
*& Date: <19-12-2019> *
*& Transport Number: < ECDK917080 > *
*&---------------------------------------------------------------------*
*-----------------------------------------------------------------------
* Programa fuente para revisi¨®n de Polizas
*-----------------------------------------------------------------------
*-----------------------------------------------------------------------
* Report  ZFGLRNLACCOUNTMAP
* Account Mapping Tool tbv SPA
*-----------------------------------------------------------------------
* Created: March 2006
* Author : H. van Tunen (CFS)
*-----------------------------------------------------------------------
* Purpose: Download of General Ledger (G/L) data to external system
*
*=======================================================================
* Change history
*-----------------------------------------------------------------------
* LOG#        DATE      AUTHOR       DER  DESCRIPTION
* 0001  01.03.2006  H van Tunen 2CR02575  Initial document.
* 0002  16.05.2006  G Veldkamp  2CR02844  -Change selection on BSEG to
*                                          improve performance.
*                                         -General layout adjustment
*                                         -Remove ZZ-fields
*                                         -Add selection on comp code.
* 003   07.07.2006  G Veldkamp  2PR07441  -Move all text fields into
*                                          source
*                                         -Add parameter for SAP
*                                          directory for output files
*                                         -make output file names
*                                          read only
* 004   08.09.2006  E Westrum             -Updated script for mySAP 2004
*                                          usage
*
*=======================================================================
*=======================================================================

REPORT  z_glaccount_pwc2 LINE-SIZE 120.

TABLES: bkpf,         "Accounting Document Header
        bseg,         "Accounting Document Segment
        t001,         "Company codes
        t003,         "Document Types
        t003t,        "Document Type Texts
        skat,         "Chart of Accounts:  Description
        skb1,         "G/L account master (company code)
        csks,         "Cost Center Master Data
        usr02,        "Logon data
        usr03.        "User address data

*-----------------------------------------------------------------------
* Selection-screen
*-----------------------------------------------------------------------
* Block1
SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE txt10.
SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN COMMENT 1(28) txt11.
SELECT-OPTIONS: s_bukrs FOR  bkpf-bukrs OBLIGATORY.   "company code
SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN COMMENT 1(31) txt12.
PARAMETERS:     p_gjahr LIKE bkpf-gjahr OBLIGATORY.   "Fiscal year
SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN COMMENT 1(31) txt13.
PARAMETERS:     p_monat LIKE bkpf-monat OBLIGATORY DEFAULT '01'.
SELECTION-SCREEN COMMENT 40(17) txt14.
PARAMETERS:     p_aantal LIKE bkpf-monat OBLIGATORY DEFAULT '12'.
SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN COMMENT 1(28) txt15.
SELECT-OPTIONS: s_blart  FOR bkpf-blart.   "Document type
SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN COMMENT 1(28) txt16.
SELECT-OPTIONS: s_budat  FOR bkpf-budat.   "Posting date
SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN COMMENT 1(28) txt17.
SELECT-OPTIONS: s_belnr  FOR bkpf-belnr.   "Document number
SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN COMMENT 1(28) txt18.
SELECT-OPTIONS: s_hkont  FOR bseg-hkont.   "G/L account
SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN COMMENT 1(28) txt19.
SELECT-OPTIONS: s_trans  FOR bkpf-tcode.   "Transactie code
SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN END OF BLOCK b1.

* Block2
SELECTION-SCREEN BEGIN OF BLOCK b2 WITH FRAME TITLE txt20.
SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN COMMENT 1(28) txt21.
SELECT-OPTIONS: s_cntrgb FOR bseg-hkont OBLIGATORY."contr.G/Lkrek.nrs
SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN END OF BLOCK b2.

* Block3
SELECTION-SCREEN BEGIN OF BLOCK b3 WITH FRAME TITLE txt30.
SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN COMMENT 1(31) txt31.
PARAMETERS:     p_dir    LIKE rlgrap-filename OBLIGATORY
                DEFAULT '/Outbound/Data/'.
SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN BEGIN OF LINE.                "bkpf
SELECTION-SCREEN COMMENT 1(20) txt32a.
SELECTION-SCREEN COMMENT 33(79) txt32b.
SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN BEGIN OF LINE.                "bseg
SELECTION-SCREEN COMMENT 1(20) txt33a.
SELECTION-SCREEN COMMENT 33(79) txt33b.
SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN BEGIN OF LINE.                             "t001
SELECTION-SCREEN COMMENT 1(20) txt34a.
SELECTION-SCREEN COMMENT 33(79) txt34b.
SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN BEGIN OF LINE.                             "t003
SELECTION-SCREEN COMMENT 1(20) txt35a.
SELECTION-SCREEN COMMENT 33(79) txt35b.
SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN BEGIN OF LINE.                             "t003t
SELECTION-SCREEN COMMENT 1(20) txt36a.
SELECTION-SCREEN COMMENT 33(79) txt36b.
SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN BEGIN OF LINE.                "skat
SELECTION-SCREEN COMMENT 1(20) txt37a.
SELECTION-SCREEN COMMENT 33(79) txt37b.
SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN BEGIN OF LINE.                             "skb1
SELECTION-SCREEN COMMENT 1(20) txt38a.
SELECTION-SCREEN COMMENT 33(79) txt38b.
SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN BEGIN OF LINE.                "csks
SELECTION-SCREEN COMMENT 1(20) txt39a.
SELECTION-SCREEN COMMENT 33(79) txt39b.
SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN BEGIN OF LINE.                             "usr02
SELECTION-SCREEN COMMENT 1(20) txt39c.
SELECTION-SCREEN COMMENT 33(79) txt39d.
SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN BEGIN OF LINE.                             "usr03
SELECTION-SCREEN COMMENT 1(20) txt39e.
SELECTION-SCREEN COMMENT 33(79) txt39f.
SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN END OF BLOCK b3.

* Block4
SELECTION-SCREEN BEGIN OF BLOCK b4 WITH FRAME TITLE txt40.
SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN COMMENT 1(31) txt41.
PARAMETERS: p_repla(01) DEFAULT '_'.
SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN COMMENT 1(31) txt42.
PARAMETERS: p_msgid     LIKE sy-msgid OBLIGATORY DEFAULT '0U'.
SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN BEGIN OF LINE.
SELECTION-SCREEN COMMENT 1(31) txt43.
PARAMETERS: p_msgno     LIKE sy-msgno OBLIGATORY DEFAULT '533'.
SELECTION-SCREEN END OF LINE.
SELECTION-SCREEN END OF BLOCK b4.

*-----------------------------------------------------------------------
* DATA
*-----------------------------------------------------------------------
DATA: p_bkpf   LIKE rlgrap-filename,
      p_bseg   LIKE rlgrap-filename,
      p_t001   LIKE rlgrap-filename,
      p_t003   LIKE rlgrap-filename,
      p_t003t  LIKE rlgrap-filename,
      p_skat   LIKE rlgrap-filename,
      p_skb1   LIKE rlgrap-filename,
      p_csks   LIKE rlgrap-filename,
      p_usr02  LIKE rlgrap-filename,
      p_usr03  LIKE rlgrap-filename.


DATA: BEGIN OF t_periode OCCURS 12,
    jaar   LIKE bkpf-gjahr,
    maand  LIKE bkpf-monat,
  END OF t_periode.

DATA: BEGIN OF t_bkpf OCCURS 0,
    mandt   LIKE bkpf-mandt,
    bukrs   LIKE bkpf-bukrs,
    belnr   LIKE bkpf-belnr,
    gjahr   LIKE bkpf-gjahr,
    blart   LIKE bkpf-blart,
    budat   LIKE bkpf-budat,
    waers   LIKE bkpf-waers,
    hwae2   LIKE bkpf-hwae2,
    hwaer   LIKE bkpf-hwaer,
    tcode   LIKE bkpf-tcode,
    stblg   LIKE bkpf-stblg,
    monat   LIKE bkpf-monat,
    cpudt   LIKE bkpf-cpudt,
    usnam   LIKE bkpf-usnam,
    bktxt   LIKE bkpf-bktxt,
    awtyp   LIKE bkpf-awtyp,
    stjah   LIKE bkpf-stjah,
    dbblg   LIKE bkpf-dbblg,
    bstat   LIKE bkpf-bstat,
    kursf   LIKE bkpf-kursf,
    wwert   LIKE bkpf-wwert,
    cputm   LIKE bkpf-cputm,       "RMG
    glvor   LIKE bkpf-glvor,       "RMG
  END OF t_bkpf.

DATA: BEGIN OF w_bkpf OCCURS 0,
    pk0(03),
    mandt   LIKE bkpf-mandt,
    pk1(03),
    bukrs   LIKE bkpf-bukrs,
    pk2(03),
    belnr   LIKE bkpf-belnr,
    pk3(03),
    gjahr   LIKE bkpf-gjahr,
    pk4(03),
    blart   LIKE bkpf-blart,
    pk5(03),
    budat   LIKE bkpf-budat,
    pk6(03),
    waers   LIKE bkpf-waers,
    pk7(03),
    hwae2   LIKE bkpf-hwae2,
    pk8(03),
    hwaer   LIKE bkpf-hwaer,
    pk9(03),
    tcode   LIKE bkpf-tcode,
    pk10(03),
    stblg   LIKE bkpf-stblg,
    pk11(03),
    monat   LIKE bkpf-monat,
    pk12(03),
    cpudt   LIKE bkpf-cpudt,
    pk13(03),
    usnam   LIKE bkpf-usnam,
    pk14(03),
    bktxt   LIKE bkpf-bktxt,
    pk15(03),
    awtyp   LIKE bkpf-awtyp,
    pk16(03),
    stjah   LIKE bkpf-stjah,
    pk17(03),
    dbblg   LIKE bkpf-dbblg,
    pk18(03),
    bstat   LIKE bkpf-bstat,
    pk19(03),
    kursf(21),
    pk20(03),
    wwert   LIKE bkpf-wwert,
    pk21(03),
    cputm   LIKE bkpf-cputm,       "RMG
    pk22(03),                      "RMG
    glvor   LIKE bkpf-glvor,       "RMG
    pk23(03),                      "RMG
 END OF w_bkpf.

*t.b.v. controle totalen
*DATA: BEGIN OF cnt_bkpf OCCURS 0,
*    mandt   LIKE bkpf-mandt,
*    bukrs   LIKE bkpf-bukrs,
*    belnr   LIKE bkpf-belnr,
*    gjahr   LIKE bkpf-gjahr,
*    blart   LIKE bkpf-blart,
*    budat   LIKE bkpf-budat,
*    waers   LIKE bkpf-waers,
*    hwae2   LIKE bkpf-hwae2,
*    hwaer   LIKE bkpf-hwaer,
*    tcode   LIKE bkpf-tcode,
*    stblg   LIKE bkpf-stblg,
*    monat   LIKE bkpf-monat,
*    cpudt   LIKE bkpf-cpudt,
*    usnam   LIKE bkpf-usnam,
*    bktxt   LIKE bkpf-bktxt,
*    awtyp   LIKE bkpf-awtyp,
*    stjah   LIKE bkpf-stjah,
*    dbblg   LIKE bkpf-dbblg,
*    bstat   LIKE bkpf-bstat,
*    kursf   LIKE bkpf-kursf,
*    wwert   LIKE bkpf-wwert,
*    cputm   LIKE bkpf-cputm,       "RMG
*    glvor   LIKE bkpf-glvor,       "RMG
*  END OF cnt_bkpf.


DATA: BEGIN OF t_bseg OCCURS 0,
     mandt    LIKE bseg-mandt,
     bukrs    LIKE bseg-bukrs,
     belnr    LIKE bseg-belnr,
     gjahr    LIKE bseg-gjahr,
     buzei    LIKE bseg-buzei,
     sgtxt    LIKE bseg-sgtxt,
     pswbt    LIKE bseg-pswbt,
     pswsl    LIKE bseg-pswsl,
     vbeln    LIKE bseg-vbeln,
     hkont    LIKE bseg-hkont,
     shkzg    LIKE bseg-shkzg,
     bschl    LIKE bseg-bschl,
     wrbtr    LIKE bseg-wrbtr,
     dmbtr    LIKE bseg-dmbtr,
     dmbe2    LIKE bseg-dmbe2,
     END OF t_bseg.

DATA: BEGIN OF w_bseg OCCURS 0,
    pk0(03),
    mandt    LIKE bseg-mandt,
    pk1(03),
    bukrs    LIKE bseg-bukrs,
    pk2(03),
    belnr    LIKE bseg-belnr,
    pk3(03),
    gjahr    LIKE bseg-gjahr,
    pk4(03),
    buzei    LIKE bseg-buzei,
    pk5(03),
    sgtxt    LIKE bseg-sgtxt,
    pk6(03),
    pswbt(16),
    pk7(03),
    pswsl    LIKE bseg-pswsl,
    pk8(03),
    vbeln    LIKE bseg-vbeln,
    pk9(03),
    hkont    LIKE bseg-hkont,
    pk10(03),
    shkzg    LIKE bseg-shkzg,
    pk11(03),
    bschl    LIKE bseg-bschl,
    pk12(03),
    wrbtr(16),
    pk13(03),
    dmbtr(16),
    pk14(03),
    dmbe2(16),
    pk15(03),
  END OF w_bseg.

*t.b.v. controle totalen
*DATA: BEGIN OF cnt_bseg OCCURS 0,
*    mandt    LIKE bseg-mandt,
*    bukrs    LIKE bseg-bukrs,
*    belnr    LIKE bseg-belnr,
*    gjahr    LIKE bseg-gjahr,
*    buzei    LIKE bseg-buzei,
*    sgtxt    LIKE bseg-sgtxt,
*    pswbt    LIKE bseg-pswbt,
*    pswsl    LIKE bseg-pswsl,
*    vbeln    LIKE bseg-vbeln,
*    hkont    LIKE bseg-hkont,
*    shkzg    LIKE bseg-shkzg,
*    bschl    LIKE bseg-bschl,
*    wrbtr    LIKE bseg-wrbtr,
*    dmbtr    LIKE bseg-dmbtr,
*    dmbe2    LIKE bseg-dmbe2,
*  END OF cnt_bseg.


DATA: BEGIN OF t_usr02,
    pk0(01),
    mandt      LIKE usr02-mandt,
    pk1(03),
    bname      LIKE usr02-bname,
    pk2(03),
    bcode(16),
    pk3(03),
    gltgv      LIKE usr02-gltgv,
    pk4(03),
    gltgb      LIKE usr02-gltgb,
    pk5(03),
    ustyp      LIKE usr02-ustyp,
    pk6(03),
    class      LIKE usr02-class,
    pk7(03),
    locnt(03),
    pk8(03),
    uflag(03),
    pk9(09),
    accnt      LIKE usr02-accnt,
    pk10(03),
    aname      LIKE usr02-aname,
    pk11(03),
    erdat      LIKE usr02-erdat,
    pk12(03),
    trdat      LIKE usr02-trdat,
    pk13(03),
    ltime      LIKE usr02-ltime,
    pk14(03),
    ocod1(16),
    pk15(03),
    bcda1      LIKE usr02-bcda1,
    pk16(03),
    codv1      LIKE usr02-codv1,
    pk17(03),
    ocod2(16),
    pk18(03),
    bcda2      LIKE usr02-bcda2,
    pk19(03),
    codv2      LIKE usr02-codv2,
    pk20(03),
    ocod3(16),
    pk21(03),
    bcda3      LIKE usr02-bcda3,
    pk22(03),
    codv3      LIKE usr02-codv3,
    pk23(03),
    ocod4(16),
    pk24(03),
    bcda4      LIKE usr02-bcda4,
    pk25(03),
    codv4      LIKE usr02-codv4,
    pk26(03),
    ocod5(16),
    pk27(03),
    bcda5      LIKE usr02-bcda5,
    pk28(03),
    codv5      LIKE usr02-codv5,
    pk29(03),
    versn      LIKE usr02-versn,
    pk30(03),
    codvn      LIKE usr02-codvn,
    pk31(03),
    tzone      LIKE usr02-tzone,
    pk32(03),
    zbvmaster  LIKE usr02-zbvmaster,
    pk33(03),
    passcode(40),
    pk34(03),
*    PWDCHGDATE      like usr02-pwdchgdate,
*    pwdstate(03),
*    reserved(03),
  END OF t_usr02.

DATA: BEGIN OF w_t001,
    pk0(03),
    mandt   LIKE t001-mandt,
    pk1(03),
    bukrs   LIKE t001-bukrs,
    pk2(03),
    butxt   LIKE t001-butxt,
    pk3(03),
    ort01   LIKE t001-ort01,
    pk4(03),
    land1   LIKE t001-land1,
    pk5(03),
    waers   LIKE t001-waers,
    pk6(03),
    spras   LIKE t001-spras,
    pk7(03),
    ktopl   LIKE t001-ktopl,
    pk8(03),
    waabw   LIKE t001-waabw,
    pk9(03),
    periv   LIKE t001-periv,
    pk10(03),
    kokfi   LIKE t001-kokfi,
    pk11(03),
    rcomp   LIKE t001-rcomp,
    pk12(03),
    adrnr   LIKE t001-adrnr,
    pk13(03),
    stceg   LIKE t001-stceg,
    pk14(03),
    fikrs   LIKE t001-fikrs,
    pk15(03),
    xfmco   LIKE t001-xfmco,
    pk16(03),
    xfmcb   LIKE t001-xfmcb,
    pk17(03),
    xfmca   LIKE t001-xfmca,
    pk18(03),
    txjcd   LIKE t001-txjcd,
    pk19(03),
    fmhrdate LIKE t001-fmhrdate,
    pk20(03),
    buvar    LIKE t001-buvar,
    pk21(03),
    fdbuk    LIKE t001-fdbuk,
    pk22(03),
    xfdis    LIKE t001-xfdis,
    pk23(03),
    xvalv    LIKE t001-xvalv,
    pk24(03),
    xskfn    LIKE t001-xskfn,
    pk25(03),
    kkber LIKE t001-kkber,
    pk26(03),
    xmwsn LIKE t001-xmwsn,
    pk27(03),
    mregl  LIKE t001-mregl,
    pk28(03),
    xgsbe   LIKE t001-xgsbe,
    pk29(03),
    xgjrv   LIKE t001-xgjrv,
    pk30(03),
    xkdft   LIKE t001-xkdft,
    pk31(03),
    xprod   LIKE t001-xprod,
    pk32(03),
    xeink   LIKE t001-xeink,
    pk33(03),
    xjvaa   LIKE t001-xjvaa,
    pk34(03),
    xvvwa   LIKE t001-xvvwa,
    pk35(03),
    xslta   LIKE t001-xslta,
    pk36(03),
    xfdmm   LIKE t001-xfdmm,
    pk37(03),
    xfdsd   LIKE t001-xfdsd,
    pk38(03),
    xextb   LIKE t001-xextb,
    pk39(03),
    ebukr   LIKE t001-ebukr,
    pk40(03),
    ktop2   LIKE t001-ktop2,
    pk41(03),
    umkrs   LIKE t001-umkrs,
    pk42(03),
    bukrs_glob LIKE t001-bukrs_glob,
    pk43(03),
    fstva   LIKE t001-fstva,
    pk44(03),
    opvar   LIKE t001-opvar,
    pk45(03),
    xcovr   LIKE t001-xcovr,
    pk46(03),
    txkrs   LIKE t001-txkrs,
    pk47(03),
    wfvar   LIKE t001-wfvar,
    pk48(03),
    xbbbf   LIKE t001-xbbbf,
    pk49(03),
    xbbbe   LIKE t001-xbbbe,
    pk50(03),
    xbbba   LIKE t001-xbbba,
    pk51(03),
    xbbko   LIKE t001-xbbko,
    pk52(03),
    xstdt   LIKE t001-xstdt,
    pk53(03),
    mwskv   LIKE t001-mwskv,
    pk54(03),
    mwska   LIKE t001-mwska,
    pk55(03),
    impda   LIKE t001-impda,
    pk56(03),
    xnegp   LIKE t001-xnegp,
    pk57(03),
    xkkbi   LIKE t001-xkkbi,
    pk58(03),
    wt_newwt LIKE t001-wt_newwt,
    pk59(03),
    pp_pdate LIKE t001-pp_pdate,
    pk60(03),
    infmt    LIKE t001-infmt,
    pk61(03),
    fstvare  LIKE t001-fstvare,
    pk62(03),
    kopim    LIKE t001-kopim,
    pk63(03),
    dkweg    LIKE t001-dkweg,
    pk64(03),
    offsacct LIKE t001-offsacct,
    pk65(03),
    bapovar  LIKE t001-bapovar,
    pk66(03),
    xcos     LIKE t001-xcos,
    pk67(03),
    xcession LIKE t001-xcession,
    pk68(03),
    xsplt    LIKE t001-xsplt,
    pk69(143),
  END OF w_t001.

DATA: BEGIN OF w_skat,
    pk0(03),
    mandt LIKE skat-mandt,
    pk1(03),
    spras LIKE skat-spras,
    pk2(03),
    ktopl LIKE skat-ktopl,
    pk3(03),
    saknr LIKE skat-saknr,
    pk4(03),
    txt20 LIKE skat-txt20,
    pk5(03),
    txt50 LIKE skat-txt50,
    pk6(03),
    mcod1 LIKE skat-mcod1,
    pk7(03),
  END OF w_skat.

DATA: BEGIN OF w_t003t,
    pk0(03),
    mandt  LIKE t003t-mandt,
    pk1(03),
    spras  LIKE t003t-spras,
    pk2(03),
    blart  LIKE t003t-blart,
    pk3(03),
    ltext  LIKE t003t-ltext,
    pk4(03),
  END OF w_t003t.

DATA: BEGIN OF w_skb1,
    pk0(03),
    mandt LIKE skb1-mandt,
    pk1(03),
    bukrs LIKE skb1-bukrs,
    pk2(03),
    saknr LIKE skb1-saknr,
    pk3(03),
    begru LIKE skb1-begru,
    pk4(03),
    busab LIKE skb1-busab,
    pk5(03),
    datlz LIKE skb1-datlz,
    pk6(03),
    erdat LIKE skb1-erdat,
    pk7(03),
    ernam LIKE skb1-ernam,
    pk8(03),
    fdgrv LIKE skb1-fdgrv,
    pk9(03),
    fdlev LIKE skb1-fdlev,
    pk10(03),
    fipls LIKE skb1-fipls,
    pk11(03),
    fstag LIKE skb1-fstag,
    pk12(03),
    hbkid LIKE skb1-hbkid,
    pk13(03),
    hktid LIKE skb1-hktid,
    pk14(03),
    kdfsl  LIKE skb1-kdfsl,
    pk15(03),
    mitkz  LIKE skb1-mitkz,
    pk16(03),
    mwskz  LIKE skb1-mwskz,
    pk17(03),
    stext  LIKE skb1-stext,
    pk18(03),
    vzskz  LIKE skb1-vzskz,
    pk19(03),
    waers  LIKE skb1-waers,
    pk20(03),
    wmeth  LIKE skb1-wmeth,
    pk21(03),
    xgkon  LIKE skb1-xgkon,
    pk22(03),
    xintb  LIKE skb1-xintb,
    pk23(03),
    xkres  LIKE skb1-xkres,
    pk24(03),
    xloeb  LIKE skb1-xloeb,
    pk25(03),
    xnkon  LIKE skb1-xnkon,
    pk26(03),
    xopvw  LIKE skb1-xopvw,
    pk27(03),
    xspeb  LIKE skb1-xspeb,
    pk28(03),
    zindt  LIKE skb1-zindt,
    pk29(03),
    zinrt  LIKE skb1-zinrt,
    pk30(03),
    zuawa  LIKE skb1-zuawa,
    pk31(03),
    altkt  LIKE skb1-altkt,
    pk32(03),
    xmitk  LIKE skb1-xmitk,
    pk33(03),
    recid  LIKE skb1-recid,
    pk34(03),
    fipos  LIKE skb1-fipos,
    pk35(03),
    xmwno  LIKE skb1-xmwno,
    pk36(03),
    xsalh  LIKE skb1-xsalh,
    pk37(03),
    bewgp  LIKE skb1-bewgp,
    pk38(03),
    infky  LIKE skb1-infky,
    pk39(03),
    togru  LIKE skb1-togru,
    pk40(103),
  END OF w_skb1.

DATA: BEGIN OF w_t003,
    pk0(03),
    mandt LIKE t003-mandt,
    pk1(03),
    blart LIKE t003-blart,
    pk2(03),
    numkr  LIKE t003-numkr,
    pk3(03),
    koars  LIKE t003-koars,
    pk4(03),
    stbla  LIKE t003-stbla,
    pk5(03),
    xnetb  LIKE t003-xnetb,
    pk6(03),
    xrvup  LIKE t003-xrvup,
    pk7(03),
    xsybl  LIKE t003-xsybl,
    pk8(03),
    xvork  LIKE t003-xvork,
    pk9(03),
    xkkpr  LIKE t003-xkkpr,
    pk10(03),
    xgsub  LIKE t003-xgsub,
    pk11(03),
    xmges  LIKE t003-xmges,
    pk12(03),
    brgru  LIKE t003-brgru,
    pk13(03),
    recid LIKE t003-recid,
    pk14(03),
    recic LIKE t003-recic,
    pk15(03),
    xmtxt  LIKE t003-xmtxt,
    pk16(03),
    xmref  LIKE t003-xmref,
    pk17(03),
    xngbk  LIKE t003-xngbk,
    pk18(03),
    kurst  LIKE t003-kurst,
    pk19(03),
    xnegp  LIKE t003-xnegp,
    pk20(03),
    xkoaa  LIKE t003-xkoaa,
    pk21(03),
    xkoad  LIKE t003-xkoad,
    pk22(03),
    xkoak  LIKE t003-xkoak,
    pk23(03),
    xkoam  LIKE t003-xkoam,
    pk24(03),
    xkoas  LIKE t003-xkoas,
    pk25(03),
    xnmrl  LIKE t003-xnmrl,
    pk26(03),
    xausg  LIKE t003-xausg,
    pk27(03),
    xdtch LIKE t003-xdtch,
    pk28(03),
    blkls LIKE t003-blkls,
    pk29(03),
    xrollup LIKE t003-xrollup,
    pk30(03),
    xplan  LIKE t003-xplan,
    pk31(03),
    xallocact LIKE t003-xallocact,
    pk32(03),
    xallocplan LIKE t003-xallocplan,
    pk33(03),
    x_pp_process LIKE t003-x_pp_process,
    pk34(143),
  END OF w_t003.

DATA: BEGIN OF w_usr03,
    pk0(03),
    mandt  LIKE usr03-mandt,
    pk1(03),
    bname  LIKE usr03-bname,
    pk2(03),
    name1  LIKE usr03-name1,
    pk3(03),
    name2  LIKE usr03-name2,
    pk4(03),
    name3  LIKE usr03-name3,
    pk5(03),
    name4  LIKE usr03-name4,
    pk6(03),
    salut  LIKE usr03-salut,
    pk7(03),
    abtlg  LIKE usr03-abtlg,
    pk8(03),
    kostl  LIKE usr03-kostl,
    pk9(03),
    buinr  LIKE usr03-buinr,
    pk10(03),
    roonr  LIKE usr03-roonr,
    pk11(03),
    stras  LIKE usr03-stras,
    pk12(03),
    pfach  LIKE usr03-pfach,
    pk13(03),
    postlz  LIKE usr03-pstlz,
    pk14(03),
    ort01  LIKE usr03-ort01,
    pk15(03),
    regio  LIKE usr03-regio,
    pk16(03),
    land1  LIKE usr03-land1,
    pk17(03),
    spras  LIKE usr03-spras,
    pk18(03),
    telpr  LIKE usr03-telpr,
    pk19(03),
    telnr  LIKE usr03-telnr,
    pk20(03),
    tel01  LIKE usr03-tel01,
    pk21(03),
    tel02  LIKE usr03-tel02,
    pk22(03),
    telx1  LIKE usr03-telx1,
    pk23(03),
    telfx  LIKE usr03-telfx,
    pk24(03),
    teltx  LIKE usr03-teltx,
    pk25(03),
    ort02  LIKE usr03-ort02,
    pk26(03),
    pstl2  LIKE usr03-pstl2,
    pk27(03),
    tzone  LIKE usr03-tzone,
    pk28(03),
  END OF w_usr03.

DATA: BEGIN OF w_csks,
    pk0(03),
    mandt LIKE csks-mandt,
    pk1(03),
    kokrs  LIKE csks-kokrs,
    pk2(03),
    kostl  LIKE csks-kostl,
    pk3(03),
    datbi  LIKE csks-datbi,
    pk4(03),
    datab  LIKE csks-datab,
    pk5(03),
    bkzkp  LIKE csks-bkzkp,
    pk6(03),
    pkzkp  LIKE csks-pkzkp,
    pk7(03),
    bukrs  LIKE csks-bukrs,
    pk8(03),
    gsber  LIKE csks-gsber,
    pk9(03),
    kosar  LIKE csks-kosar,
    pk10(03),
    verak  LIKE csks-verak,
    pk11(03),
    waers  LIKE csks-waers,
    pk12(03),
    kalsm  LIKE csks-kalsm,
    pk13(03),
    txjcd  LIKE csks-txjcd,
    pk14(03),
    prctr  LIKE csks-prctr,
    pk15(03),
    werks  LIKE csks-werks,
    pk16(03),
    logsystem LIKE csks-logsystem,
    pk17(03),
    ersda  LIKE csks-ersda,
    pk18(03),
    usnam  LIKE csks-usnam,
    pk19(03),
    bkzks  LIKE csks-bkzks,
    pk20(03),
    bkzer  LIKE csks-bkzer,
    pk21(03),
    bkzob  LIKE csks-bkzob,
    pk22(03),
    pkzks  LIKE csks-pkzks,
    pk23(03),
    pkzer  LIKE csks-pkzer,
    pk24(03),
    vmeth  LIKE csks-vmeth,
    pk25(03),
    mgefl  LIKE csks-mgefl,
    pk26(03),
    abtei  LIKE csks-abtei,
    pk27(03),
    nkost  LIKE csks-nkost,
    pk28(03),
    kvewe  LIKE csks-kvewe,
    pk29(03),
    kappl  LIKE csks-kappl,
    pk30(03),
    koszschl LIKE csks-koszschl,
    pk31(03),
    land1  LIKE csks-land1,
    pk32(03),
    anred  LIKE csks-anred,
    pk33(03),
    name1  LIKE csks-name1,
    pk34(03),
    name2  LIKE csks-name2,
    pk35(03),
    name3  LIKE csks-name3,
    pk36(03),
    name4  LIKE csks-name4,
    pk37(03),
    ort01  LIKE csks-ort01,
    pk38(03),
    ort02  LIKE csks-ort02,
    pk39(03),
    stras  LIKE csks-stras,
    pk40(03),
    pfach  LIKE csks-pfach,
    pk41(03),
    pstlz  LIKE csks-pstlz,
    pk42(03),
    pstl2  LIKE csks-pstl2,
    pk43(03),
    regio  LIKE csks-regio,
    pk44(03),
    spras  LIKE csks-spras,
    pk45(03),
    telbx  LIKE csks-telbx,
    pk46(03),
    telf1  LIKE csks-telf1,
    pk47(03),
    telf2  LIKE csks-telf2,
    pk48(03),
    telfx  LIKE csks-telfx,
    pk49(03),
    teltx  LIKE csks-teltx,
    pk50(03),
    telx1  LIKE csks-telx1,
    pk51(03),
    datlt  LIKE csks-datlt,
    pk52(03),
    drnam  LIKE csks-drnam,
    pk53(03),
    khinr  LIKE csks-khinr,
    pk54(03),
    cckey  LIKE csks-cckey,
    pk55(03),
    kompl  LIKE csks-kompl,
    pk56(03),
    stakz  LIKE csks-stakz,
    pk57(03),
    objnr  LIKE csks-objnr,
    pk58(03),
    funkt  LIKE csks-funkt,
    pk59(03),
    afunk  LIKE csks-afunk,
    pk60(03),
    cpi_templ LIKE csks-cpi_templ,
    pk61(03),
    cpd_templ LIKE csks-cpd_templ,
    pk62(03),
    func_area LIKE csks-func_area,
    pk63(03),
    sci_templ LIKE csks-sci_templ,
    pk64(03),
    scd_templ LIKE csks-scd_templ,
    pk65(03),
    vname  LIKE csks-vname,
    pk79(03),
    recid  LIKE csks-recid,
    pk80(03),
    etype LIKE csks-etype,
    pk81(03),
    jv_otype  LIKE csks-jv_otype,
    pk82(03),
    jv_jibcl  LIKE csks-jv_jibcl,
    pk83(03),
    jv_jibsa  LIKE csks-jv_jibsa,
    pk84(03),
  END OF w_csks.


* internal tabel with companies
DATA: BEGIN OF t_compcode OCCURS 0,
    bukrs LIKE t001-bukrs,
  END OF t_compcode.

* tabel for printing of control totals
*DATA: BEGIN OF tbtot     OCCURS 0,
*    bukrs    LIKE bkpf-bukrs,  " Company code
*    hkont    LIKE bseg-hkont,  " Account
*    blart    LIKE bkpf-blart,  " Document type
*    belnr    LIKE bkpf-belnr,  " Document number
*    shkzg    LIKE bseg-shkzg,  " Debit/Credit Indicator
*    count      TYPE i,     " Counter of records
**   wrbtr    LIKE bseg-wrbtr,    " Document currency amount RMG
*    wrbtr(16) TYPE p DECIMALS 2, " Document currency amount RMG
*    waers    LIKE bkpf-waers, " Document currency key
**   dmbtr    LIKE bseg-dmbtr,    " Local currency amount RMG
*    dmbtr(16) TYPE p DECIMALS 2, " Local currency amount RMG
*    locwa    LIKE t001-waers, " Local currency key
**   dmbe2    LIKE bseg-dmbe2, " Group currency amount    RMG
*    dmbe2(16) TYPE p, " Group currency amount RMG
*    hwae2    LIKE bkpf-hwae2, " Group currency key
*    tcode    LIKE bkpf-tcode, " transaction code
*  END OF tbtot.


DATA: w_len TYPE i.
DATA: w_count      TYPE p.
*      teller_bkpf  TYPE p,
*      teller_bseg  TYPE p,
*      teller_t001  TYPE p,
*      teller_skat  TYPE p,
*      teller_t003t TYPE p,
*      teller_skb1  TYPE p,
*      teller_t003  TYPE p,
*      teller_csks  TYPE p,
*      teller_usr02 TYPE p,
*      teller_usr03 TYPE p.
DATA: h_veld(07).

*DATA: w_packed_dmbe2        TYPE p DECIMALS 2,
*      w_total_packed_debit  LIKE w_packed_dmbe2,
*      w_total_packed_credit LIKE w_packed_dmbe2,
*      w_char_dmbe2(17)      TYPE c.

* Carriage return
*DATA: BEGIN OF cr_lf,
*    cr01 TYPE x VALUE '0D',
*    lf(01) TYPE x VALUE '0A',
*  END OF cr_lf.

*-----------------------------------------------------------------------
* CONSTANTS
*-----------------------------------------------------------------------
CONSTANTS: c_colon(03) VALUE '";"'.
* file headers
CONSTANTS: c_bkpf0(16) VALUE '"MANDT";"BUKRS";',
           c_bkpf1(55) VALUE
 '"BELNR";"GJAHR";"BLART";"BUDAT";"WAERS";"HWAE2";"HWAER',
           c_bkpf2(67) VALUE
 '";"TCODE";"STBLG";"MONAT";"CPUDT";"USNAM";"BKTXT";"AWTYP";"STJAH";"',
           c_bkpf3(47) VALUE
 'DBBLG";"BSTAT";"KURSF";"WWERT";"CPUTM";"GLVOR"'.
*RMG Agregar encabezado a BKPF cputm y glvor c_bkpf3(31) a 47
CONSTANTS: c_bseg0(16) VALUE '"MANDT";"BUKRS"',
           c_bseg1(66) VALUE
 ';"BELNR";"GJAHR";"BUZEI";"SGTXT";"PSWBT";"PSWSL";"VBELN',
           c_bseg2(50) VALUE
  '";"HKONT";"SHKZG";"BSCHL";"WRBTR";"DMBTR";"DMBE2"'.

CONSTANTS: c_t003t(31) VALUE '"MANDT";"SPRAS";"BLART";"LTEXT"'.

CONSTANTS: c_skat(55) VALUE
  '"MANDT";"SPRAS";"KTOPL";"SAKNR";"TXT20";"TXT50";"MCOD1"'.

CONSTANTS: c_usr03_1(55) VALUE
  '"MANDT";"BNAME";"NAME1";"NAME2";"NAME3";"NAME4";"SALUT"',
           c_usr03_2(56) VALUE
  ';"ABTLG";"KOSTL";"BUINR";"ROONR";"STRAS";"PFACH";"PSTLZ"',
           c_usr03_3(56) VALUE
  ';"ORT01";"REGIO";"LAND1";"SPRAS";"TELPR";"TELNR";"TEL01"',
           c_usr03_4(56) VALUE
  ';"TEL02";"TELX1";"TELFX";"TELTX";"ORT02";"PSTL2";"TZONE"'.

CONSTANTS: c_usr02_1(55) VALUE
  '"MANDT";"BNAME";"BCODE";"GLTGV";"GLTGB";"USTYP";"CLASS"',
           c_usr02_2(56) VALUE
  ';"LOCNT";"UFLAG";"ACCNT";"ANAME";"ERDAT";"TRDAT";"LTIME"',
           c_usr02_3(56) VALUE
  ';"OCOD1";"BCDA1";"CODV1";"OCOD2";"BCDA2";"CODV2";"OCOD3"',
           c_usr02_4(56) VALUE
  ';"BCDA3";"CODV3";"OCOD4";"BCDA4";"CODV4";"OCOD5";"BCDA5"',
           c_usr02_5(44) VALUE
  ';"CODV5";"VERSN";"CODVN";"TZONE";"ZBVMASTER"'.

CONSTANTS: c_t001_1(55) VALUE
  '"MANDT";"BUKRS";"BUTXT";"ORT01";"LAND1";"WAERS";"SPRAS"',
           c_t001_2(56) VALUE
  ';"KTOPL";"WAABW";"PERIV";"KOKFI";"RCOMP";"ADRNR";"STCEG"',
           c_t001_3(59) VALUE
  ';"FIKRS";"XFMCO";"XFMCB";"XFMCA";"TXJCD";"FMHRDATE";"BUVAR"',
           c_t001_4(56) VALUE
  ';"FDBUK";"XFDIS";"XVALV";"XSKFN";"KKBER";"XMWSN";"MREGL"',
           c_t001_5(56) VALUE
  ';"XGSBE";"XGJRV";"XKDFT";"XPROD";"XEINK";"XJVAA";"XVVWA"',
           c_t001_6(56) VALUE
  ';"XSLTA";"XFDMM";"XFDSD";"XEXTB";"EBUKR";"KTOP2";"UMKRS"',
           c_t001_7(61) VALUE
  ';"BUKRS_GLOB";"FSTVA";"OPVAR";"XCOVR";"TXKRS";"WFVAR";"XBBBF"',
           c_t001_8(56) VALUE
  ';"XBBBE";"XBBBA";"XBBKO";"XSTDT";"MWSKV";"MWSKA";"IMPDA"',
           c_t001_9(56) VALUE
  ';"XNEGP";"XKKBI";"WT_NEWWT";"PP_PDATE";"INFMT";"FSTVARE"',
           c_t001_10(63) VALUE
  ';"KOPIM";"DKWEG";"OFFSACCT";"BAPOVAR";"XCOS";"XCESSION";"XSPLT"'.

CONSTANTS: c_t003_1(63) VALUE
  '"MANDT";"BLART";"NUMKR";"KOARS";"STBLA";"XNETB";"XRVUP";"XSYBL"' ,
           c_t003_2(64) VALUE
  ';"XVORK";"XKKPR";"XGSUB";"XMGES";"BRGRU";"RECID";"RECIC";"XMTXT"',
           c_t003_3(64) VALUE
  ';"XMREF";"XNGBK";"KURST";"XNEGP";"XKOAA";"XKOAD";"XKOAK";"XKOAM"',
           c_t003_4(60) VALUE
  ';"XKOAS";"XNMRL";"XAUSG";"XDTCH";"BLKLS";"XROLLUP";"XPLAN"',
           c_t003_5(40) VALUE
  ';"XALLOCACT";"XALLOCPLAN";"X_PP_PROCESS"'.

CONSTANTS: c_skb1_1(63) VALUE
  '"MANDT";"BUKRS";"SAKNR";"BEGRU";"BUSAB";"DATLZ";"ERDAT";"ERNAM"',
            c_skb1_2(64) VALUE
  ';"FDGRV";"FDLEV";"FIPLS";"FSTAG";"HBKID";"HKTID";"KDFSL";"MITKZ"',
            c_skb1_3(64) VALUE
  ';"MWSKZ";"STEXT";"VZSKZ";"WAERS";"WMETH";"XGKON";"XINTB";"XKRES"',
            c_skb1_4(64) VALUE
  ';"XLOEB";"XNKON";"XOPVW";"XSPEB";"ZINDT";"ZINRT";"ZUAWA";"ALTKT"',
            c_skb1_5(64) VALUE
  ';"XMITK";"RECID";"FIPOS";"XMWNO";"XSALH";"BEWGP";"INFKY";"TOGRU"'.

CONSTANTS: c_csks_1(64) VALUE
  '"MANDT";"KOKRS";"KOSTL";"DATBI";"DATAB";"BKZKP";"PKZKP";"BUKRS"',
            c_csks_2(64) VALUE
  ';"GSBER";"KOSAR";"VERAK";"WAERS";"KALSM";"TXJCD";"PRCTR";"WERKS"',
            c_csks_3(68) VALUE
 ';"LOGSYSTEM";"ERSDA";"USNAM";"BKZKS";"BKZER";"BKZOB";"PKZKS";"PKZER"',
            c_csks_4(68) VALUE
  ';"VMETH";"MGEFL";"ABTEI";"NKOST";"KVEWE";"KAPPL";"KOSZSCHL";"LAND1"',
            c_csks_5(68) VALUE
  ';"ANRED";"NAME1";"NAME2";"NAME3";"NAME4";"ORT01";"ORT02";"STRAS"',
            c_csks_6(68) VALUE
  ';"PFACH";"PSTLZ";"PSTL2";"REGIO";"SPRAS";"TELBX";"TELF1";"TELF2"',
            c_csks_7(68) VALUE
  ';"TELFX";"TELTX";"TELX1";"DATLT";"DRNAM";"KHINR";"CCKEY";"KOMPL"',
            c_csks_8(68) VALUE
 ';"STAKZ";"OBJNR";"FUNKT";"AFUNK";"CPI_TEMPL";"CPD_TEMPL";"FUNC_AREA"',
             c_csks_9(68) VALUE
 ';"SCI_TEMPL";"SCD_TEMPL";"VNAME";"RECID";"ETYPE"',
             c_csks_10(68) VALUE
 ';"JV_OTYPE";"JV_JIBCL";"JV_JIBSA"'.

*eject
*-----------------------------------------------------------------------
INITIALIZATION.
*-----------------------------------------------------------------------
* fill the selection screen text variables
  txt10 = 'Selection'.
  txt11 = 'Company code'.
  txt12 = 'Fiscal year'.
  txt13 = 'From fiscal period'.
  txt14 = 'Number of periods'.
  txt15 = 'Document type'.
  txt16 = 'Posting date'.
  txt17 = 'Document number'.
  txt18 = 'G/L account'.
  txt19 = 'Transaction code'.

  txt20 = 'Checking G/L Accounts'.
  txt21 = 'G/L account for checking'.

  txt30 = 'Output files'.
  txt31 = 'SAP directory'.

  CONCATENATE p_dir 'BKPF_bukrs-jaarmaand_jjjjmmdd.TXT' INTO p_bkpf.
  CONCATENATE p_dir 'BSEG_bukrs-jaarmaand_jjjjmmdd.TXT' INTO p_bseg.
  CONCATENATE p_dir 'T001_jjjjmmdd.TXT'  INTO p_t001.
  CONCATENATE p_dir 'T003_jjjjmmdd.TXT'  INTO p_t003.
  CONCATENATE p_dir 'T003T_jjjjmmdd.TXT' INTO p_t003t.
  CONCATENATE p_dir 'SKAT_jjjjmmdd.TXT'  INTO p_skat.
  CONCATENATE p_dir 'SKB1_jjjjmmdd.TXT'  INTO p_skb1.
  CONCATENATE p_dir 'CSKS_jjjjmmdd.TXT'  INTO p_csks.
  CONCATENATE p_dir 'USR02_jjjjmmdd.TXT' INTO p_usr02.
  CONCATENATE p_dir 'USR03_jjjjmmdd.TXT' INTO p_usr03.

  txt32a = 'Filename BKPF data'.
  txt32b = p_bkpf.
  txt33a = 'Filename BSEG data'.
  txt33b = p_bseg.
  txt34a = 'Filename T001 data'.
  txt34b = p_t001.
  txt35a = 'Filename T003 data'.
  txt35b = p_t003.
  txt36a = 'Filename T003T data'.
  txt36b = p_t003t.
  txt37a = 'Filename SKAT data'.
  txt37b = p_skat.
  txt38a = 'Filename SKB1 data'.
  txt38b = p_skb1.
  txt39a = 'Filename CSKS data'.
  txt39b = p_csks.
  txt39c = 'Filename USR02 data'.
  txt39d = p_usr02.
  txt39e = 'Filename USR02 data'.
  txt39f = p_usr03.

  txt40 = 'Replacement character and Message Id/number'.
  txt41 = 'Replacement character'.
  txt42 = 'Message Id'.
  txt43 = 'Message number'.

*----------------------------------------------------------------------
AT SELECTION-SCREEN ON BLOCK b3.
*----------------------------------------------------------------------
* refresh after user entry of directory
  CONCATENATE p_dir 'BKPF_bukrs-jaarmaand_jjjjmmdd.TXT' INTO p_bkpf.
  CONCATENATE p_dir 'BSEG_bukrs-jaarmaand_jjjjmmdd.TXT' INTO p_bseg.
  CONCATENATE p_dir 'T001_jjjjmmdd.TXT'  INTO p_t001.
  CONCATENATE p_dir 'T003_jjjjmmdd.TXT'  INTO p_t003.
  CONCATENATE p_dir 'T003T_jjjjmmdd.TXT' INTO p_t003t.
  CONCATENATE p_dir 'SKAT_jjjjmmdd.TXT'  INTO p_skat.
  CONCATENATE p_dir 'SKB1_jjjjmmdd.TXT'  INTO p_skb1.
  CONCATENATE p_dir 'CSKS_jjjjmmdd.TXT'  INTO p_csks.
  CONCATENATE p_dir 'USR02_jjjjmmdd.TXT' INTO p_usr02.
  CONCATENATE p_dir 'USR03_jjjjmmdd.TXT' INTO p_usr03.

  txt32b = p_bkpf.
  txt33b = p_bseg.
  txt34b = p_t001.
  txt35b = p_t003.
  txt36b = p_t003t.
  txt37b = p_skat.
  txt38b = p_skb1.
  txt39b = p_csks.
  txt39d = p_usr02.
  txt39f = p_usr03.


* check SAP directory exists
  OPEN DATASET p_bkpf IN TEXT MODE ENCODING DEFAULT FOR OUTPUT .
  IF sy-subrc = 0.
    CLOSE DATASET p_bkpf.
  ELSE.
    MESSAGE ID p_msgid TYPE 'I' NUMBER p_msgno
    WITH 'SAP directory ' p_dir ' not found, check transaction AL11'.
  ENDIF.

*-----------------------------------------------------------------------
* START-OF-SELECTION.
*-----------------------------------------------------------------------
START-OF-SELECTION.

*systemdate to filenames
  REPLACE 'jjjjmmdd' WITH sy-datum INTO p_bkpf.
  REPLACE 'jjjjmmdd' WITH sy-datum INTO p_bseg.
  REPLACE 'jjjjmmdd' WITH sy-datum INTO p_t001.
  REPLACE 'jjjjmmdd' WITH sy-datum INTO p_t003.
  REPLACE 'jjjjmmdd' WITH sy-datum INTO p_t003t.
  REPLACE 'jjjjmmdd' WITH sy-datum INTO p_skat.
  REPLACE 'jjjjmmdd' WITH sy-datum INTO p_skb1.
  REPLACE 'jjjjmmdd' WITH sy-datum INTO p_csks.
  REPLACE 'jjjjmmdd' WITH sy-datum INTO p_usr02.
  REPLACE 'jjjjmmdd' WITH sy-datum INTO p_usr03.


* create internal file with Fiscal years/periods for which
* BKPF en BSEG files have to be created
  t_periode-jaar = p_gjahr.
  t_periode-maand = p_monat.
  APPEND t_periode.

  p_aantal = p_aantal - 1.

  DO p_aantal TIMES.
    t_periode-maand = t_periode-maand + 1.
    APPEND t_periode.
  ENDDO.

* fill T_COMPCODE with companycodes
* BEGIN. 07-07-2026 - ATC - ATC-03
* OLD CODE
*  SELECT bukrs FROM t001
*        INTO CORRESPONDING FIELDS OF TABLE t_compcode
*          WHERE bukrs IN s_bukrs.
*
* NEW CODE
  SELECT bukrs
 FROM t001
        INTO CORRESPONDING FIELDS OF TABLE t_compcode
          WHERE bukrs IN s_bukrs ORDER BY PRIMARY KEY.

* END. 07-07-2026 - ATC - ATC-03


* select BKPF and BSEG per company code
  LOOP AT t_compcode.
    REPLACE 'bukrs' WITH t_compcode-bukrs INTO p_bkpf.
    REPLACE 'bukrs' WITH t_compcode-bukrs INTO p_bseg.
    PERFORM select_bkpf_bseg.
    REPLACE t_compcode-bukrs WITH 'bukrs' INTO p_bkpf.
    REPLACE t_compcode-bukrs WITH 'bukrs' INTO p_bseg.
  ENDLOOP.

* select other tabels
  PERFORM other_tabels.

* Control totals
*  PERFORM controle_totalen_afdrukken.

*---------------------------------------------------------------------*
*       FORM select_bkpf_bseg
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
FORM select_bkpf_bseg.

* select BKPF and BSEG per fiscal period
  LOOP AT t_periode.
    CLEAR t_bkpf.
    REFRESH t_bkpf.

    PERFORM select_bkpf.
    IF NOT t_bkpf[] IS INITIAL.
      CLEAR t_bseg.
      REFRESH t_bseg.
      PERFORM select_bseg.
      PERFORM write_file.
*      PERFORM controle_totalen.
    ENDIF.
  ENDLOOP.

ENDFORM.                    " select_bkpf_bseg

*&---------------------------------------------------------------------*
*&      Form  select_bkpf
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM select_bkpf.

*  SELECT mandt bukrs gjahr blart budat belnr waers hwae2 hwaer
*         tcode stblg monat cpudt usnam bktxt awtyp stjah dbblg
*         bstat kursf wwert cputm glvor
*
*    FROM bkpf
*    INTO CORRESPONDING FIELDS OF TABLE t_bkpf
*    WHERE bukrs = t_compcode-bukrs
*      AND belnr IN s_belnr
*      AND gjahr = t_periode-jaar
*      AND blart IN s_blart
*      AND budat IN s_budat
*      AND monat = t_periode-maand
*      AND tcode IN s_trans.

* BEGIN. 07-07-2026 - ATC - ATC-03
* OLD CODE
*  SELECT mandt bukrs gjahr blart budat belnr waers hwae2 hwaer
*         tcode stblg monat cpudt usnam bktxt awtyp stjah dbblg
*         bstat kursf wwert cputm glvor
*
*    FROM bkpf
*    INTO CORRESPONDING FIELDS OF TABLE t_bkpf
*    WHERE bukrs = t_compcode-bukrs
**      AND belnr IN s_belnr
*      AND gjahr = t_periode-jaar
**      AND blart IN s_blart
**      AND budat IN s_budat
*      AND monat = t_periode-maand.
*
* NEW CODE
  SELECT mandt bukrs gjahr blart budat belnr waers hwae2 hwaer
         tcode stblg monat cpudt usnam bktxt awtyp stjah dbblg
         bstat kursf wwert cputm glvor


    FROM bkpf
    INTO CORRESPONDING FIELDS OF TABLE t_bkpf
    WHERE bukrs = t_compcode-bukrs
*      AND belnr IN s_belnr
      AND gjahr = t_periode-jaar
*      AND blart IN s_blart
*      AND budat IN s_budat
      AND monat = t_periode-maand ORDER BY PRIMARY KEY.

* END. 07-07-2026 - ATC - ATC-03
*      AND tcode IN s_trans.
  IF NOT s_belnr[] IS INITIAL.
    DELETE t_bkpf
      WHERE NOT belnr IN s_belnr.
  ENDIF.
  IF NOT s_blart[] IS INITIAL.
    DELETE t_bkpf
      WHERE NOT blart IN s_blart.
  ENDIF.
  IF NOT s_budat[] IS INITIAL.
    DELETE t_bkpf
      WHERE NOT budat IN s_budat.
  ENDIF.
  IF NOT s_trans[] IS INITIAL.
    DELETE t_bkpf
      WHERE NOT tcode IN s_trans.
  ENDIF.


*DEVK9A0AG7
ENDFORM.                    " select_bkpf

*&---------------------------------------------------------------------*
*&      Form  select_bseg
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM select_bseg.

*  LOOP AT t_bkpf.
*    SELECT mandt bukrs belnr gjahr buzei sgtxt pswbt pswsl
*           vbeln hkont shkzg bschl wrbtr dmbtr dmbe2
*      FROM bseg
*      APPENDING CORRESPONDING FIELDS OF TABLE t_bseg
*      WHERE bukrs = t_bkpf-bukrs
*        AND belnr = t_bkpf-belnr
*        AND gjahr = t_bkpf-gjahr
*        AND hkont IN s_hkont.
*  ENDLOOP.

SELECT mandt bukrs belnr gjahr buzei
pswbt pswsl
vbeln hkont shkzg bschl wrbtr dmbtr dmbe2
FROM bseg
INTO CORRESPONDING FIELDS OF TABLE t_bseg
FOR ALL ENTRIES IN t_bkpf
WHERE bukrs = t_bkpf-bukrs
AND belnr = t_bkpf-belnr
*Begin of change: ReSQ Correction for Addition ORDER BY PRIMARY KEY 19/12/2019 EY_DES03 ECDK917080 *
*AND gjahr = t_bkpf-gjahr.
AND GJAHR = T_BKPF-GJAHR ORDER BY PRIMARY KEY .
*End of change: ReSQ Correction for Addition ORDER BY PRIMARY KEY 19/12/2019 EY_DES03 ECDK917080 *
*      AND hkont IN s_hkont.
  IF NOT s_hkont[] IS INITIAL.
    DELETE t_bseg
      WHERE NOT hkont IN s_hkont.
  ENDIF.

* No leer el campo  sgtxt a solictud de usuario ya que por contener
* el caracter ## ocasionaba saldo de linea en su aplicacion

** build control totals
*  LOOP AT t_bseg.
*    IF t_bseg-shkzg = 'S'.
*
*      MOVE t_bseg-dmbtr TO w_char_dmbe2.
*      PACK  w_char_dmbe2 TO w_packed_dmbe2.
*      w_total_packed_debit = w_packed_dmbe2 + w_total_packed_debit.
*
*      CLEAR w_char_dmbe2.
*
*    ELSE.
*
*      MOVE t_bseg-dmbtr TO w_char_dmbe2.
*      PACK  w_char_dmbe2 TO w_packed_dmbe2.
*      w_total_packed_credit = w_packed_dmbe2 + w_total_packed_credit.
**         w_total_debit = bseg-dmbe2 + w_total_debit.
*
*      CLEAR w_char_dmbe2.
*
*    ENDIF.
*
*  ENDLOOP.

ENDFORM.                    " select_bseg

*&---------------------------------------------------------------------*
*&      Form  write_file
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM write_file.

  SORT t_bkpf.
  SORT t_bseg.
* write bkpf
  REPLACE 'jaar' WITH t_periode-jaar INTO p_bkpf.
  REPLACE 'maand' WITH t_periode-maand INTO p_bkpf.
  OPEN DATASET p_bkpf FOR OUTPUT IN TEXT MODE ENCODING DEFAULT.
  CONCATENATE c_bkpf0 c_bkpf1 c_bkpf2 c_bkpf3 INTO w_bkpf.
  CONDENSE w_bkpf.
  w_len = STRLEN( w_bkpf ).
  TRANSFER w_bkpf TO p_bkpf LENGTH w_len.

  w_count = 0.
  LOOP AT t_bkpf.

    CLEAR w_bkpf.
    MOVE-CORRESPONDING t_bkpf TO w_bkpf.
    DO.
      IF w_bkpf CA    '"'.
        REPLACE '"' WITH p_repla INTO w_bkpf.
      ELSE.
        EXIT.
      ENDIF.
    ENDDO.

    WRITE t_bkpf-kursf TO w_bkpf-kursf.

    MOVE '"' TO w_bkpf-pk0.
    MOVE: c_colon TO w_bkpf-pk1,
          c_colon TO w_bkpf-pk2,
          '";' TO w_bkpf-pk3,
          ';"' TO w_bkpf-pk4,
          c_colon TO w_bkpf-pk5,
          c_colon TO w_bkpf-pk6,
          c_colon TO w_bkpf-pk7,
          c_colon TO w_bkpf-pk8,
          c_colon TO w_bkpf-pk9,
          c_colon TO w_bkpf-pk10,
          '";' TO w_bkpf-pk11,
          ';"' TO w_bkpf-pk12,
          c_colon TO w_bkpf-pk13,
          c_colon TO w_bkpf-pk14,
          c_colon TO w_bkpf-pk15,
          c_colon TO w_bkpf-pk16,
          c_colon TO w_bkpf-pk17,
          c_colon TO w_bkpf-pk18,
          '";' TO w_bkpf-pk19,
          ';"' TO w_bkpf-pk20,
          c_colon TO w_bkpf-pk21,
          c_colon TO w_bkpf-pk22,
          '"' TO w_bkpf-pk23.


    CONDENSE w_bkpf.
    w_len = STRLEN( w_bkpf ).
    TRANSFER w_bkpf TO p_bkpf LENGTH w_len.
    w_count = w_count + 1.
    DELETE t_bkpf.
  ENDLOOP.

  CLOSE DATASET p_bkpf.
  IF sy-batch = 'X'.
    MESSAGE ID p_msgid TYPE 'I' NUMBER p_msgno
    WITH p_bkpf ' number of records' w_count.
  ELSE.
    WRITE: / p_bkpf, 55 ' number of records', w_count.
  ENDIF.
  FREE: t_bkpf.
*write bseg
  REPLACE 'jaar' WITH t_periode-jaar INTO p_bseg.
  REPLACE 'maand' WITH t_periode-maand INTO p_bseg.
  OPEN DATASET p_bseg IN TEXT MODE ENCODING DEFAULT FOR OUTPUT.
  CONCATENATE c_bseg0 c_bseg1 c_bseg2 INTO w_bseg.
  CONDENSE w_bseg.
  w_len = STRLEN( w_bseg ).
  TRANSFER w_bseg TO p_bseg LENGTH w_len.

  w_count = 0.
  LOOP AT t_bseg.

    CLEAR w_bseg.
    MOVE-CORRESPONDING t_bseg TO w_bseg.
    DO.
      IF w_bseg CA '"'.
        REPLACE '"' WITH p_repla INTO w_bseg.
      ELSE.
        EXIT.
      ENDIF.
    ENDDO.

    WRITE t_bseg-pswbt TO w_bseg-pswbt.
    WRITE t_bseg-wrbtr TO w_bseg-wrbtr.
    WRITE t_bseg-dmbtr TO w_bseg-dmbtr.
    WRITE t_bseg-dmbe2 TO w_bseg-dmbe2.

    MOVE '"' TO w_bseg-pk0.
    MOVE: c_colon TO w_bseg-pk1,
         c_colon TO w_bseg-pk2,
         c_colon TO w_bseg-pk3,
         c_colon TO w_bseg-pk4,
         c_colon TO w_bseg-pk5,
         '";' TO w_bseg-pk6,
         ';"' TO w_bseg-pk7,
         c_colon TO w_bseg-pk8,
         c_colon TO w_bseg-pk9,
         c_colon TO w_bseg-pk10,
         c_colon TO w_bseg-pk11,
         '";' TO w_bseg-pk12,
         ';' TO w_bseg-pk13,
         ';' TO w_bseg-pk14,
         ';' TO w_bseg-pk15.

    CONDENSE w_bseg.
    w_len = STRLEN( w_bseg ).
    TRANSFER w_bseg TO p_bseg LENGTH w_len.
    w_count = w_count + 1.
    DELETE t_bseg.
  ENDLOOP.

  CLOSE DATASET p_bseg.
  IF sy-batch = 'X'.
    MESSAGE ID p_msgid TYPE 'I' NUMBER p_msgno
    WITH p_bseg ' number of records' w_count.
  ELSE.
    WRITE: / p_bseg, 55 ' number of records', w_count.
  ENDIF.
  FREE: t_bseg.
  h_veld = '-'.
  h_veld+1(04) = t_periode-jaar.
  h_veld+5(02) = t_periode-maand.
  REPLACE h_veld WITH '-jaarmaand' INTO p_bkpf.
  REPLACE h_veld WITH '-jaarmaand' INTO p_bseg.

ENDFORM.                    " write_file

*&---------------------------------------------------------------------*
*&      Form  other_tabels
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM other_tabels.

  PERFORM table_t001.
  PERFORM table_t003.
  PERFORM table_t003t.
  PERFORM table_skat.
  PERFORM table_skb1.
  PERFORM table_csks.
  PERFORM table_usr02.
  PERFORM table_usr03.

ENDFORM.                    " other_tabels

*&---------------------------------------------------------------------*
*&      Form  controle_totalen
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
*FORM controle_totalen.
*
**BSEG
*  LOOP AT t_bseg WHERE hkont IN s_cntrgb.
*    APPEND t_bseg TO cnt_bseg.
*  ENDLOOP.
**BKPF
*  SORT cnt_bseg.
*  LOOP AT cnt_bseg.
*    READ TABLE t_bkpf WITH KEY belnr = cnt_bseg-belnr.
*    APPEND t_bkpf TO cnt_bkpf.
*  ENDLOOP.
*
*ENDFORM.                    " controle_totalen

*&---------------------------------------------------------------------*
*&      Form  controle_totalen_afdrukken
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
*FORM controle_totalen_afdrukken.
*
*  SORT cnt_bkpf.
*  SORT cnt_bseg.
*  DELETE ADJACENT DUPLICATES FROM cnt_bkpf.
*
*  LOOP AT cnt_bkpf.
*    LOOP AT cnt_bseg WHERE belnr = cnt_bkpf-belnr.
*      MOVE cnt_bkpf-bukrs TO tbtot-bukrs.
*      MOVE cnt_bseg-hkont TO tbtot-hkont.
*      MOVE cnt_bkpf-blart TO tbtot-blart.
**      MOVE cnt_bkpf-tcode TO tbtot-tcode.
*      IF cnt_bseg-shkzg = 'S'.
*        MOVE 'D' TO tbtot-shkzg.
*      ELSE.
*        MOVE 'C' TO tbtot-shkzg.
*        cnt_bseg-wrbtr = cnt_bseg-wrbtr * -1.
*        cnt_bseg-dmbtr = cnt_bseg-dmbtr * -1.
*        cnt_bseg-dmbe2 = cnt_bseg-dmbe2 * -1.
*      ENDIF.
*
*      MOVE cnt_bseg-wrbtr TO tbtot-wrbtr.
*      MOVE cnt_bkpf-waers TO tbtot-waers.
*      MOVE cnt_bseg-dmbtr TO tbtot-dmbtr.
*      MOVE cnt_bseg-dmbe2 TO tbtot-dmbe2.
*      MOVE +1 TO tbtot-count.
*
*      COLLECT tbtot.
*    ENDLOOP.
*  ENDLOOP.
*
*  SORT tbtot BY bukrs hkont blart tcode belnr shkzg waers.
*  LOOP AT tbtot.
*
*    AT NEW bukrs.
*      SKIP 3.
*      WRITE: / 'Controle totalen', tbtot-bukrs.
*      SKIP.
*    ENDAT.
*
*    WRITE : / tbtot-bukrs,
*              tbtot-hkont,
*              tbtot-blart,
*              tbtot-shkzg,
*              tbtot-count,
*              tbtot-wrbtr,
*              tbtot-waers,
*              tbtot-dmbtr,
*              tbtot-locwa,
*              tbtot-dmbe2,
*              tbtot-hwae2.
*    AT END OF hkont.
*      SUM.
*      WRITE: /49 'Balance', tbtot-dmbtr.
*      SKIP.
*    ENDAT.
*  ENDLOOP.
*  w_total_packed_credit = w_total_packed_credit * -1.
*  ULINE.
*  WRITE: /30 'Total Debit ', w_total_packed_debit.
*  WRITE: /30 'Total Credit', w_total_packed_credit.
*  ULINE.
*
*ENDFORM.                    " controle_totalen_afdrukken

*&---------------------------------------------------------------------*
*&      Form  table_t001
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM table_t001.

  OPEN DATASET p_t001 IN TEXT MODE ENCODING DEFAULT FOR OUTPUT.
  w_count = 0.

  CONCATENATE c_t001_1 c_t001_2 c_t001_3 c_t001_4 c_t001_5
              c_t001_6 c_t001_7 c_t001_8 c_t001_9 c_t001_10
              INTO w_t001.
  CONDENSE w_t001.
  w_len = STRLEN( w_t001 ).
  TRANSFER w_t001 TO p_t001 LENGTH w_len.

* BEGIN. 07-07-2026 - ATC - ATC-03
* OLD CODE
*  SELECT * FROM t001
*    WHERE bukrs IN s_bukrs.
*
* NEW CODE
  SELECT *
 FROM t001
    WHERE bukrs IN s_bukrs ORDER BY PRIMARY KEY.

* END. 07-07-2026 - ATC - ATC-03

    CLEAR w_t001.
    MOVE-CORRESPONDING t001 TO w_t001.

    DO.
      IF w_t001 CA '"'.
        REPLACE '"' WITH p_repla INTO w_t001.
      ELSE.
        EXIT.
      ENDIF.
    ENDDO.

    MOVE '"' TO w_t001-pk0.
    MOVE: c_colon TO w_t001-pk1,
         c_colon TO w_t001-pk2,
         c_colon TO w_t001-pk3,
         c_colon TO w_t001-pk4,
         c_colon TO w_t001-pk5,
         c_colon TO w_t001-pk6,
         c_colon TO w_t001-pk7,
         c_colon TO w_t001-pk8,
         c_colon TO w_t001-pk9,
         c_colon TO w_t001-pk10,
         c_colon TO w_t001-pk11,
         c_colon TO w_t001-pk12,
         c_colon TO w_t001-pk13,
         c_colon TO w_t001-pk14,
         c_colon TO w_t001-pk15,
         c_colon TO w_t001-pk16,
         c_colon TO w_t001-pk17,
         c_colon TO w_t001-pk18,
         c_colon TO w_t001-pk19,
         c_colon TO w_t001-pk20,
         c_colon TO w_t001-pk21,
         c_colon TO w_t001-pk22,
         c_colon TO w_t001-pk23,
         c_colon TO w_t001-pk24,
         c_colon TO w_t001-pk25,
         c_colon TO w_t001-pk26,
         c_colon TO w_t001-pk27,
         c_colon TO w_t001-pk28,
         c_colon TO w_t001-pk29,
         c_colon TO w_t001-pk30,
         c_colon TO w_t001-pk31,
         c_colon TO w_t001-pk32,
         c_colon TO w_t001-pk33,
         c_colon TO w_t001-pk34,
         c_colon TO w_t001-pk35,
         c_colon TO w_t001-pk36,
         c_colon TO w_t001-pk37,
         c_colon TO w_t001-pk38,
         c_colon TO w_t001-pk39,
         c_colon TO w_t001-pk40,
         c_colon TO w_t001-pk41,
         c_colon TO w_t001-pk42,
         c_colon TO w_t001-pk43,
         c_colon TO w_t001-pk44,
         c_colon TO w_t001-pk45,
         c_colon TO w_t001-pk46,
         c_colon TO w_t001-pk47,
         c_colon TO w_t001-pk48,
         c_colon TO w_t001-pk49,
         c_colon TO w_t001-pk50,
         c_colon TO w_t001-pk51,
         c_colon TO w_t001-pk52,
         c_colon TO w_t001-pk53,
         c_colon TO w_t001-pk54,
         c_colon TO w_t001-pk55,
         c_colon TO w_t001-pk56,
         c_colon TO w_t001-pk57,
         c_colon TO w_t001-pk58,
         c_colon TO w_t001-pk59,
         c_colon TO w_t001-pk60,
         c_colon TO w_t001-pk61,
         c_colon TO w_t001-pk62,
         c_colon TO w_t001-pk63,
         c_colon TO w_t001-pk64,
         c_colon TO w_t001-pk65,
         c_colon TO w_t001-pk66,
         c_colon TO w_t001-pk67,
         c_colon TO w_t001-pk68,
         '"' TO w_t001-pk69.

    CONDENSE w_t001.
    w_len = STRLEN( w_t001 ).
    TRANSFER w_t001 TO p_t001 LENGTH w_len.
    w_count = w_count + 1.
  ENDSELECT.

  CLOSE DATASET p_t001.
  IF sy-batch = 'X'.
    MESSAGE ID p_msgid TYPE 'I' NUMBER p_msgno
    WITH p_t001 ' number of records' w_count.
  ELSE.
    WRITE: / p_t001, 55 ' number of records', w_count.
  ENDIF.

ENDFORM.                    " table_t001

*&---------------------------------------------------------------------*
*&      Form  table_skat
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM table_skat.

  OPEN DATASET p_skat IN TEXT MODE ENCODING DEFAULT FOR OUTPUT.
  w_count = 0.

* Updated to this in order to enable script for mySAP 2004 usage. The
* line contained a "CR_LF" but this is now incorporated in open dataset
* line.
  CONCATENATE c_skat ' ' INTO w_skat.
  CONDENSE w_skat.
  w_len = STRLEN( w_skat ).
  TRANSFER w_skat TO p_skat LENGTH w_len.

  SELECT * FROM skat.
    CLEAR w_skat.
    MOVE-CORRESPONDING skat TO w_skat.

    DO.
      IF w_skat CA '"'.
        REPLACE '"' WITH p_repla INTO w_skat.
      ELSE.
        EXIT.
      ENDIF.
    ENDDO.

    MOVE '"' TO w_skat-pk0.
    MOVE: c_colon TO w_skat-pk1,
          c_colon TO w_skat-pk2,
          c_colon TO w_skat-pk3,
          c_colon TO w_skat-pk4,
          c_colon TO w_skat-pk5,
          c_colon TO w_skat-pk6,
          '"' TO w_skat-pk7.

    CONDENSE w_skat.
    w_len = STRLEN( w_skat ).
    TRANSFER w_skat TO p_skat LENGTH w_len.
    w_count = w_count + 1.
  ENDSELECT.

  CLOSE DATASET p_skat.
  IF sy-batch = 'X'.
    MESSAGE ID p_msgid TYPE 'I' NUMBER p_msgno
      WITH p_skat ' number of records' w_count.
  ELSE.
    WRITE: / p_skat, 55 ' number of records', w_count.
  ENDIF.

ENDFORM.                    " table_skat

*&---------------------------------------------------------------------*
*&      Form  table_t003t
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM table_t003t.

  OPEN DATASET p_t003t IN TEXT MODE ENCODING DEFAULT FOR OUTPUT.
  w_count = 0.

  CONCATENATE c_t003t '' INTO w_t003t.
  CONDENSE w_t003t.
  w_len = STRLEN( w_t003t ).
  TRANSFER w_t003t TO p_t003t LENGTH w_len.

  SELECT * FROM t003t.
    CLEAR w_t003t.

    MOVE-CORRESPONDING t003t TO w_t003t.

    DO.
      IF w_t003t CA '"'.
        REPLACE '"' WITH p_repla INTO w_t003t.
      ELSE.
        EXIT.
      ENDIF.
    ENDDO.

    MOVE '"' TO w_t003t-pk0.
    MOVE: c_colon TO w_t003t-pk1,
          c_colon TO w_t003t-pk2,
          c_colon TO w_t003t-pk3,
          '"' TO w_t003t-pk4.

    CONDENSE w_t003t.
    w_len = STRLEN( w_t003t ).
    TRANSFER w_t003t TO p_t003t LENGTH w_len.
    w_count = w_count + 1.
  ENDSELECT.

  CLOSE DATASET p_t003t.
  IF sy-batch = 'X'.
    MESSAGE ID p_msgid TYPE 'I' NUMBER p_msgno
     WITH p_t003t ' number of records' w_count.
  ELSE.
    WRITE: / p_t003t, 55 ' number of records', w_count.
  ENDIF.

ENDFORM.                    " table_t003t

*&---------------------------------------------------------------------*
*&      Form  table_skb1
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM table_skb1.

  OPEN DATASET p_skb1 IN TEXT MODE ENCODING DEFAULT FOR OUTPUT.
  w_count = 0.

  CONCATENATE c_skb1_1 c_skb1_2 c_skb1_3 c_skb1_4 c_skb1_5
             INTO w_skb1.
  CONDENSE w_skb1.
  w_len = STRLEN( w_skb1 ).
  TRANSFER w_skb1 TO p_skb1 LENGTH w_len.

* BEGIN. 07-07-2026 - ATC - ATC-03
* OLD CODE
*  SELECT * FROM skb1
*    WHERE bukrs IN s_bukrs.
*
* NEW CODE
  SELECT *
 FROM skb1
    WHERE bukrs IN s_bukrs ORDER BY PRIMARY KEY.

* END. 07-07-2026 - ATC - ATC-03

    CLEAR w_skb1.
    MOVE-CORRESPONDING skb1 TO w_skb1.

    DO.
      IF w_skb1 CA '"'.
        REPLACE '"' WITH p_repla INTO w_skb1.
      ELSE.
        EXIT.
      ENDIF.
    ENDDO.

    MOVE '"' TO w_skb1-pk0.
    MOVE: c_colon TO w_skb1-pk1,
         c_colon TO w_skb1-pk2,
         c_colon TO w_skb1-pk3,
         c_colon TO w_skb1-pk4,
         c_colon TO w_skb1-pk5,
         c_colon TO w_skb1-pk6,
         c_colon TO w_skb1-pk7,
         c_colon TO w_skb1-pk8,
         c_colon TO w_skb1-pk9,
         c_colon TO w_skb1-pk10,
         c_colon TO w_skb1-pk11,
         c_colon TO w_skb1-pk12,
         c_colon TO w_skb1-pk13,
         c_colon TO w_skb1-pk14,
         c_colon TO w_skb1-pk15,
         c_colon TO w_skb1-pk16,
         c_colon TO w_skb1-pk17,
         c_colon TO w_skb1-pk18,
         c_colon TO w_skb1-pk19,
         c_colon TO w_skb1-pk20,
         c_colon TO w_skb1-pk21,
         c_colon TO w_skb1-pk22,
         c_colon TO w_skb1-pk23,
         c_colon TO w_skb1-pk24,
         c_colon TO w_skb1-pk25,
         c_colon TO w_skb1-pk26,
         c_colon TO w_skb1-pk27,
         c_colon TO w_skb1-pk28,
         c_colon TO w_skb1-pk29,
         c_colon TO w_skb1-pk30,
         c_colon TO w_skb1-pk31,
         c_colon TO w_skb1-pk32,
         c_colon TO w_skb1-pk33,
         c_colon TO w_skb1-pk34,
         c_colon TO w_skb1-pk35,
         c_colon TO w_skb1-pk36,
         c_colon TO w_skb1-pk37,
         c_colon TO w_skb1-pk38,
         c_colon TO w_skb1-pk39,
         '"' TO w_skb1-pk40.

    CONDENSE w_skb1.
    w_len = STRLEN( w_skb1 ).
    TRANSFER w_skb1 TO p_skb1 LENGTH w_len.
    w_count = w_count + 1.
  ENDSELECT.

  CLOSE DATASET p_skb1.
  IF sy-batch = 'X'.
    MESSAGE ID p_msgid TYPE 'I' NUMBER p_msgno
    WITH p_skb1 ' number of records' w_count.
  ELSE.
    WRITE: / p_skb1, 55 ' number of records', w_count.
  ENDIF.

ENDFORM.                    " table_skb1

*&---------------------------------------------------------------------*
*&      Form  table_t003
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM table_t003.

  OPEN DATASET p_t003 IN TEXT MODE ENCODING DEFAULT FOR OUTPUT.
  w_count = 0.

  CONCATENATE c_t003_1 c_t003_2 c_t003_3 c_t003_4
              c_t003_5 INTO w_t003.
  CONDENSE w_t003.
  w_len = STRLEN( w_t003 ).
  TRANSFER w_t003 TO p_t003 LENGTH w_len.

  SELECT * FROM t003.

    CLEAR w_t003.
    MOVE-CORRESPONDING t003 TO w_t003.

    DO.
      IF w_t003 CA '"'.
        REPLACE '"' WITH p_repla INTO w_t003.
      ELSE.
        EXIT.
      ENDIF.
    ENDDO.

    MOVE '"' TO w_t003-pk0.
    MOVE: c_colon TO w_t003-pk1,
          c_colon TO w_t003-pk2,
          c_colon TO w_t003-pk3,
          c_colon TO w_t003-pk4,
          c_colon TO w_t003-pk5,
          c_colon TO w_t003-pk6,
          c_colon TO w_t003-pk7,
          c_colon TO w_t003-pk8,
          c_colon TO w_t003-pk9,
          c_colon TO w_t003-pk10,
          c_colon TO w_t003-pk11,
          c_colon TO w_t003-pk12,
          c_colon TO w_t003-pk13,
          c_colon TO w_t003-pk14,
          c_colon TO w_t003-pk15,
          c_colon TO w_t003-pk16,
          c_colon TO w_t003-pk17,
          c_colon TO w_t003-pk18,
          c_colon TO w_t003-pk19,
          c_colon TO w_t003-pk20,
          c_colon TO w_t003-pk21,
          c_colon TO w_t003-pk22,
          c_colon TO w_t003-pk23,
          c_colon TO w_t003-pk24,
          c_colon TO w_t003-pk25,
          c_colon TO w_t003-pk26,
          c_colon TO w_t003-pk27,
          c_colon TO w_t003-pk28,
          c_colon TO w_t003-pk29,
          c_colon TO w_t003-pk30,
          c_colon TO w_t003-pk31,
          c_colon TO w_t003-pk32,
          c_colon TO w_t003-pk33,
          '"' TO w_t003-pk34.

    CONDENSE w_t003.
    w_len = STRLEN( w_t003 ).
    TRANSFER w_t003 TO p_t003 LENGTH w_len.
    w_count = w_count + 1.
  ENDSELECT.

  CLOSE DATASET p_t003.
  IF sy-batch = 'X'.
    MESSAGE ID p_msgid TYPE 'I' NUMBER p_msgno
    WITH p_t003 ' number of records' w_count.
  ELSE.
    WRITE: / p_t003, 55 ' number of records', w_count.
  ENDIF.

ENDFORM.                    " table_t003

*&---------------------------------------------------------------------*
*&      Form  table_csks
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM table_csks.

  OPEN DATASET p_csks IN TEXT MODE ENCODING DEFAULT FOR OUTPUT.
  w_count = 0.

  CONCATENATE c_csks_1 c_csks_2 c_csks_3 c_csks_4 c_csks_5
              c_csks_6 c_csks_7 c_csks_8 c_csks_9 c_csks_10
             INTO w_csks.
  CONDENSE w_csks.
  w_len = STRLEN( w_csks ).
  TRANSFER w_csks TO p_csks LENGTH w_len.

* BEGIN. 07-07-2026 - ATC - ATC-03
* OLD CODE
*  SELECT * FROM csks
*    WHERE bukrs IN s_bukrs.
*
* NEW CODE
  SELECT *
 FROM csks
    WHERE bukrs IN s_bukrs ORDER BY PRIMARY KEY.

* END. 07-07-2026 - ATC - ATC-03

    CLEAR w_csks.
    MOVE-CORRESPONDING csks TO w_csks.

    DO.
      IF w_csks CA '"'.
        REPLACE '"' WITH p_repla INTO w_csks.
      ELSE.
        EXIT.
      ENDIF.
    ENDDO.

    MOVE '"' TO w_csks-pk0.
    MOVE: c_colon TO w_csks-pk1,
          c_colon TO w_csks-pk2,
          c_colon TO w_csks-pk3,
          c_colon TO w_csks-pk4,
          c_colon TO w_csks-pk5,
          c_colon TO w_csks-pk6,
          c_colon TO w_csks-pk7,
          c_colon TO w_csks-pk8,
          c_colon TO w_csks-pk9,
          c_colon TO w_csks-pk10,
          c_colon TO w_csks-pk11,
          c_colon TO w_csks-pk12,
          c_colon TO w_csks-pk13,
          c_colon TO w_csks-pk14,
          c_colon TO w_csks-pk15,
          c_colon TO w_csks-pk16,
          c_colon TO w_csks-pk17,
          c_colon TO w_csks-pk18,
          c_colon TO w_csks-pk19,
          c_colon TO w_csks-pk20,
          c_colon TO w_csks-pk21,
          c_colon TO w_csks-pk22,
          c_colon TO w_csks-pk23,
          c_colon TO w_csks-pk24,
          c_colon TO w_csks-pk25,
          c_colon TO w_csks-pk26,
          c_colon TO w_csks-pk27,
          c_colon TO w_csks-pk28,
          c_colon TO w_csks-pk29,
          c_colon TO w_csks-pk30,
          c_colon TO w_csks-pk31,
          c_colon TO w_csks-pk32,
          c_colon TO w_csks-pk33,
          c_colon TO w_csks-pk34,
          c_colon TO w_csks-pk35,
          c_colon TO w_csks-pk36,
          c_colon TO w_csks-pk37,
          c_colon TO w_csks-pk38,
          c_colon TO w_csks-pk39,
          c_colon TO w_csks-pk40,
          c_colon TO w_csks-pk41,
          c_colon TO w_csks-pk42,
          c_colon TO w_csks-pk43,
          c_colon TO w_csks-pk44,
          c_colon TO w_csks-pk45,
          c_colon TO w_csks-pk46,
          c_colon TO w_csks-pk47,
          c_colon TO w_csks-pk48,
          c_colon TO w_csks-pk49,
          c_colon TO w_csks-pk50,
          c_colon TO w_csks-pk51,
          c_colon TO w_csks-pk52,
          c_colon TO w_csks-pk53,
          c_colon TO w_csks-pk54,
          c_colon TO w_csks-pk55,
          c_colon TO w_csks-pk56,
          c_colon TO w_csks-pk57,
          c_colon TO w_csks-pk58,
          c_colon TO w_csks-pk59,
          c_colon TO w_csks-pk60,
          c_colon TO w_csks-pk61,
          c_colon TO w_csks-pk62,
          c_colon TO w_csks-pk63,
          c_colon TO w_csks-pk64,
          c_colon TO w_csks-pk65,
          c_colon TO w_csks-pk79,
          c_colon TO w_csks-pk80,
          c_colon TO w_csks-pk81,
          c_colon TO w_csks-pk82,
          c_colon TO w_csks-pk83,
          '"'  TO w_csks-pk84.

    CONDENSE w_csks.
    w_len = STRLEN( w_csks ).
    TRANSFER w_csks TO p_csks LENGTH w_len.
    w_count = w_count + 1.
  ENDSELECT.

  CLOSE DATASET p_csks.
  IF sy-batch = 'X'.
    MESSAGE ID p_msgid TYPE 'I' NUMBER p_msgno
    WITH p_csks ' number of records' w_count.
  ELSE.
    WRITE: / p_csks, 55 ' number of records', w_count.
  ENDIF.

ENDFORM.                    " table_csks

*&---------------------------------------------------------------------*
*&      Form  table_usr02
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM table_usr02.

  OPEN DATASET p_usr02 IN TEXT MODE ENCODING DEFAULT FOR OUTPUT.
  w_count = 0.

  CONCATENATE c_usr02_1 c_usr02_2 c_usr02_3 c_usr02_4
              c_usr02_5 INTO t_usr02.
  CONDENSE t_usr02.
  w_len = STRLEN( t_usr02 ).
  TRANSFER t_usr02 TO p_usr02 LENGTH w_len.

  SELECT * FROM usr02.
    CLEAR t_usr02.
    MOVE-CORRESPONDING usr02 TO t_usr02.

    DO.
      IF t_usr02 CA '"'.
        REPLACE '"' WITH p_repla INTO t_usr02.
      ELSE.
        EXIT.
      ENDIF.
    ENDDO.

    WRITE usr02-bcode TO t_usr02-bcode.
    WRITE usr02-locnt TO t_usr02-locnt.
    WRITE usr02-uflag TO t_usr02-uflag.
    WRITE usr02-ocod1 TO t_usr02-ocod1.
    WRITE usr02-ocod2 TO t_usr02-ocod2.
    WRITE usr02-ocod3 TO t_usr02-ocod3.
    WRITE usr02-ocod4 TO t_usr02-ocod4.
    WRITE usr02-ocod5 TO t_usr02-ocod5.
*    write usr02-passcode to t_usr02-passcode.
*    write usr02-pwdstate to t_usr02-pwdstate.
*    write usr02-reserved to t_usr02-reserved.

    MOVE '"' TO t_usr02-pk0.
    MOVE: c_colon TO t_usr02-pk1,
          c_colon TO t_usr02-pk2,
          c_colon TO t_usr02-pk3,
          c_colon TO t_usr02-pk4,
          c_colon TO t_usr02-pk5,
          c_colon TO t_usr02-pk6,
          c_colon TO t_usr02-pk7,
          c_colon TO t_usr02-pk8,
          c_colon TO t_usr02-pk9,
          c_colon TO t_usr02-pk10,
          c_colon TO t_usr02-pk11,
          c_colon TO t_usr02-pk12,
          c_colon TO t_usr02-pk13,
          c_colon TO t_usr02-pk14,
          c_colon TO t_usr02-pk15,
          c_colon TO t_usr02-pk16,
          c_colon TO t_usr02-pk17,
          c_colon TO t_usr02-pk18,
          c_colon TO t_usr02-pk19,
          c_colon TO t_usr02-pk20,
          c_colon TO t_usr02-pk21,
          c_colon TO t_usr02-pk22,
          c_colon TO t_usr02-pk23,
          c_colon TO t_usr02-pk24,
          c_colon TO t_usr02-pk25,
          c_colon TO t_usr02-pk26,
          c_colon TO t_usr02-pk27,
          c_colon TO t_usr02-pk28,
          c_colon TO t_usr02-pk29,
          c_colon TO t_usr02-pk30,
          c_colon TO t_usr02-pk31,
          c_colon TO t_usr02-pk32,
          c_colon TO t_usr02-pk33,
          '"' TO t_usr02-pk34.

    CONDENSE t_usr02.
    w_len = STRLEN( t_usr02 ).
    TRANSFER t_usr02 TO p_usr02 LENGTH w_len.
    w_count = w_count + 1.
  ENDSELECT.

  CLOSE DATASET p_usr02.
  IF sy-batch = 'X'.
    MESSAGE ID p_msgid TYPE 'I' NUMBER p_msgno
    WITH p_usr02 ' number of records' w_count.
  ELSE.
    WRITE: / p_usr02, 55 ' number of records', w_count.
  ENDIF.

ENDFORM.                    " table_usr02

*&---------------------------------------------------------------------*
*&      Form  table_usr03
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM table_usr03.

  OPEN DATASET p_usr03 IN TEXT MODE ENCODING UTF-8 FOR OUTPUT.
  w_count = 0.

  CONCATENATE c_usr03_1 c_usr03_2 c_usr03_3 c_usr03_4 INTO w_usr03.
  CONDENSE w_usr03.
  w_len = STRLEN( w_usr03 ).
  TRANSFER w_usr03 TO p_usr03 LENGTH w_len.

  SELECT * FROM usr03.
    CLEAR w_usr03.
    MOVE-CORRESPONDING usr03 TO w_usr03.

    DO.
      IF w_usr03 CA '"'.
        REPLACE '"' WITH p_repla INTO w_usr03.
      ELSE.
        EXIT.
      ENDIF.
    ENDDO.

    MOVE '"' TO w_usr03-pk0.
    MOVE: c_colon TO w_usr03-pk1,
          c_colon TO w_usr03-pk2,
          c_colon TO w_usr03-pk3,
          c_colon TO w_usr03-pk4,
          c_colon TO w_usr03-pk5,
          c_colon TO w_usr03-pk6,
          c_colon TO w_usr03-pk7,
          c_colon TO w_usr03-pk8,
          c_colon TO w_usr03-pk9,
          c_colon TO w_usr03-pk10,
          c_colon TO w_usr03-pk11,
          c_colon TO w_usr03-pk12,
          c_colon TO w_usr03-pk13,
          c_colon TO w_usr03-pk14,
          c_colon TO w_usr03-pk15,
          c_colon TO w_usr03-pk16,
          c_colon TO w_usr03-pk17,
          c_colon TO w_usr03-pk18,
          c_colon TO w_usr03-pk19,
          c_colon TO w_usr03-pk20,
          c_colon TO w_usr03-pk21,
          c_colon TO w_usr03-pk22,
          c_colon TO w_usr03-pk23,
          c_colon TO w_usr03-pk24,
          c_colon TO w_usr03-pk25,
          c_colon TO w_usr03-pk26,
          c_colon TO w_usr03-pk27,
          '"'  TO w_usr03-pk28.

    CONDENSE w_usr03.
    w_len = STRLEN( w_usr03 ).
    TRANSFER w_usr03 TO p_usr03 LENGTH w_len.
    w_count = w_count + 1.
  ENDSELECT.

  CLOSE DATASET p_usr03.
  IF sy-batch = 'X'.
    MESSAGE ID p_msgid TYPE 'I' NUMBER p_msgno
    WITH p_usr03 ' number of records' w_count.
  ELSE.
    WRITE: / p_usr03, 55 ' number of records', w_count.
  ENDIF.

ENDFORM.                    " table_usr03

*eof
