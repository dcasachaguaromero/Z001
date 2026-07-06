FUNCTION-POOL ZSTATUSCOMPO MESSAGE-ID ft NO STANDARD PAGE HEADING.
TABLES: t001,
        t004w,
        t019,
        lf006,
        d020s,
        kna1,
        lfa1,
        ska1,
        skat,
        skb1,
        tmodf,
        tmodg,
        tmodo,
        tmodp,
        tmodu.

* Für "SHOW_USE_.."
TABLES:
    tcobf,
    t004f,
    t077d,
    t077k,
    t077s,
    t078d,
    t078k,
    t078s,
    t079d,
    t079k,
    tbsl.


*---------------------------------------------------------------------*
*        DATA                                                         *
*---------------------------------------------------------------------*

DATA:    dy-linno     LIKE sy-stepl,
         dy-linn2     LIKE sy-stepl,
         dy-field(30) TYPE c,
         ok-code(5)   TYPE c,          " OK-CODE
         last_ok      LIKE ok-code,    " letzter Ok-code
         pos(3)       TYPE n,
         aeflg        TYPE c,          " Änderungsflag D400
         aeflg2       TYPE c,          " Glob.Var XCHANGE(E)
         chflg        TYPE c,          " Glob.Var für XCHANGE
         disflg       TYPE c,          " Glob.Var für XDISP
         c500(500)    TYPE c,
         fleng(4)     TYPE n,
         xhell,                        " Gruppe helleuchtend
         xhide,                        " Zeile auswählbar
         modgrup      LIKE tmodo-modif,
         loopc        LIKE sy-loopc,
         refe         TYPE p,
         tabix        LIKE sy-tabix,
         gtabix       LIKE sy-tabix,
         tabname      LIKE help_info-tabname,
         fieldname    LIKE help_info-fieldname,
         st_fauna     TYPE i,
         st_ggrup     TYPE i,
         st_modif     TYPE i,
         st_koart     TYPE i,
         st_feld      TYPE i,
         last_ggrup   LIKE tmodo-ggrup,
         last_modif   LIKE tmodo-modif,
         last_koart,
         text_koart(30),
         txt40(40),
         utext(40),
         crosseb.

DATA:
    u02_kontenplan        LIKE t004-ktopl,
    u02_feldstatusgruppe  LIKE t077s-ktoks,
    u02_feldstatustext    LIKE t077z-txt30,
    u02_language          LIKE sy-langu.

DATA:
    u03_fstvariante       LIKE t004v-fstva,
    u03_fstvariantentext  LIKE t004w-fstxt,
    u03_fstgruppe         LIKE t004f-fstag,
    u03_fstgruppentext    LIKE t004g-fsttx,
    u03_found.


DATA: LV_NEWGL_ACTIVE TYPE FAGL_GLFLEX_ACTIVE.

*$*$-End:   EHP603_LF006TOP_1-------------------------------------------------------------------$*$*

*---------------------------------------------------------------------*
*        Strukturen                                                   *
*---------------------------------------------------------------------*
*        DYNSEC                                                       *
*        Hier sind alle Programme und Dynpros einzutragen, die        *
*        nach Modifs zu durchsuchen sind. Die Struktur wird zur       *
*        PBO-Zeit in die interne Tabelle DYNTAB gestellt.             *
*---------------------------------------------------------------------*
DATA:
    BEGIN OF dynsec,
        a1(59) VALUE
          'SKB1-FAUS1 SAPMF05A                                03000399',
        a2(59) VALUE
          'SKB1-FAUS1 SAPMF05A                                23002399',
        a3(59) VALUE
          'SKB1-FAUS1 SAPMF05A                                33003399',
        a4(59) VALUE
          'SKB1-FAUS1 SAPMF05A                                06200621',
        b1(59) VALUE
          'T077S-FAUSSSAPLGL_ACCOUNT_MASTER_MAINTAIN          22012219',
        c1(59) VALUE
          'T077D-FAUSASAPMF02D                                01100190',
        c2(59) VALUE
          'T077D-FAUSASAPMJ1AC                                06000600',
        d1(59) VALUE
          'T077D-FAUSFSAPMF02D                                02000290',
        d2(59) VALUE
          'T077D-FAUSFSAPMFWTC                                06100610',
        e1(59) VALUE
          'T077D-FAUSVSAPMF02D                                03000390',
        f1(59) VALUE
          'T077K-FAUSASAPMF02K                                01100190',
        f2(59) VALUE
          'T077K-FAUSASAPMJ1AV                                06000600',
        g1(59) VALUE
          'T077K-FAUSFSAPMF02K                                02000290',
        g2(59) VALUE
          'T077K-FAUSFSAPMFWTV                                06100610',
        h1(59) VALUE
          'T077K-FAUSMSAPMF02K                                03000390',
        zz(59) VALUE '$',
    END OF dynsec.

*---------------------------------------------------------------------*
*        interne Tabellen                                             *
*---------------------------------------------------------------------*
DATA:
    excltab  LIKE sy-tcode OCCURS 4.

DATA:    BEGIN OF dyntab OCCURS 10,
           fauna(11) TYPE c,
           progr(40) TYPE c,
           dynmn(4)  TYPE n,
           dynmx(4)  TYPE n,
         END OF dyntab.

DATA:    BEGIN OF doktab OCCURS 50,
           modi(3),
           tab(10),
           feld(10),
           koart,
           umsks,
           xrele,
         END OF doktab.

DATA   BEGIN OF last_doktab.           "???
        INCLUDE STRUCTURE doktab.
DATA   END OF last_doktab.

DATA:  BEGIN OF lasttab OCCURS 10,
             modif(3)  TYPE n,
             koart,
       END OF lasttab.

DATA:  BEGIN OF splittab OCCURS 0,
             prog      LIKE d020s-prog,
             dnum      LIKE d020s-dnum,
             koart(1),
             umsks(1),
       END OF splittab.

DATA:    BEGIN OF crosstab OCCURS 0,
           ggrup(5),
           modi(3)  TYPE n,
           koart,
           tab(5),
           feld(10),
           text(60),
         END OF crosstab.


DATA: BEGIN OF bildtab OCCURS 0,
        grupp(3) TYPE n,
        FELDN	   type FIELDNAME,
        ggrup    LIKE tmodo-ggrup,
        ftext    LIKE tmodp-ftext,
        xoblg    LIKE lf006-xoblg,
        xoptn    LIKE lf006-xoptn,
        xdisp    LIKE lf006-xdisp,
      END OF bildtab.

DATA: BEGIN OF faustab OCCURS 50,
        grupp(3) TYPE n,
        ggrup    LIKE tmodo-ggrup,
        ftext    LIKE tmodp-ftext,
        xoblg    LIKE lf006-xoblg,
        xoptn    LIKE lf006-xoptn,
        xdisp    LIKE lf006-xdisp,
      END OF faustab.

DATA: BEGIN OF gruptab OCCURS 0,
        ggrup   LIKE tmodo-ggrup,
        ftext   LIKE tmodp-ftext,
        xhell   TYPE c,
      END OF gruptab.

DATA:
    dynpfields  TYPE rpy_dyfatc OCCURS 0 WITH HEADER LINE.

DATA:
    BEGIN OF scr OCCURS 0,
        prog   LIKE d020s-prog,
        dnum   LIKE d020s-dnum,
    END OF scr.

* Für "SHOW_USE_.."
DATA:
    use_fauna      LIKE tmodu-fauna,
    use_offset     TYPE i,
    use_button(2),
    use_found.

DATA:
    BEGIN OF use_strings,
        faus1(50),
        faus2(50),
        fausa(40),
        fausf(40),
        fausm(40),
        fauss(40),
        fausv(40),
        fausw(128),
    END OF use_strings.


* Konstanten
DATA:
    xon       VALUE 'X'.
