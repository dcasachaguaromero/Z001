*&---------------------------------------------------------------------*
*& Report: < ZEY_GDS_CORRECTION > *
*& Author: < EY_DES02 > *
*& Description: < ReSQ Correction > *
*& Date: <23-12-2019> *
*& Transport Number: < ECDK917080 > *
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&  Include           ZFIR001_CONC_BANCOS_INCVHRO
*&---------------------------------------------------------------------*
***
*&---------------------------------------------------------------------*
*&      Form  select_items_abiertos
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM select_items_abiertos .
  REFRESH: it_bsis, it_movbanco_open, it_movconta_open.

* BEGIN. 07-07-2026 - ATC - ATC-03
* OLD CODE
*  SELECT wrbtr budat dmbtr
*         bukrs belnr gjahr buzei hkont blart shkzg
*           FROM BSIS  INTO CORRESPONDING FIELDS OF TABLE it_bsis
*           WHERE BUKRS EQ P_BUKRS
*           AND   HKONT IN S_SAKNR
*           AND   BUDAT LE P_BUDAT.
*
* NEW CODE
  SELECT wrbtr budat dmbtr
         bukrs belnr gjahr buzei hkont blart shkzg

           FROM BSIS  INTO CORRESPONDING FIELDS OF TABLE it_bsis
           WHERE BUKRS EQ P_BUKRS
           AND   HKONT IN S_SAKNR
           AND   BUDAT LE P_BUDAT ORDER BY PRIMARY KEY.

* END. 07-07-2026 - ATC - ATC-03
  SORT it_bsis     BY BUKRS BELNR GJAHR BUZEI.
  SORT it_skb1     BY BUKRS SAKNR.

  describe table it_bsis lines wa_contador.
  if wa_contador > 0.

     SELECT distinct bk~bukrs bk~belnr bk~gjahr bk~bktxt bk~awkey bk~usnam bk~stblg
            bk~stjah bk~stgrd bk~xref1_hd bk~xref2_hd bk~budat
           INTO CORRESPONDING FIELDS OF TABLE it_bkpf
          FROM bkpf as bk inner join bsis as bs
            on bk~bukrs = bs~bukrs
               and bk~belnr = bs~belnr
               and bk~gjahr = bs~gjahr
           WHERE bs~BUKRS EQ P_BUKRS
           AND   bs~HKONT IN S_SAKNR
           AND   bs~BUDAT LE P_BUDAT.
  endif.


* BEGIN. 07-07-2026 - ATC - ATC-03
* OLD CODE
*  SELECT kukey aznum FROM febko
*           INTO CORRESPONDING FIELDS OF TABLE it_febko
*           WHERE BUKRS  EQ p_BUKRS.
*
* NEW CODE
  SELECT kukey aznum
 FROM febko
           INTO CORRESPONDING FIELDS OF TABLE it_febko
           WHERE BUKRS  EQ p_BUKRS ORDER BY PRIMARY KEY.

* END. 07-07-2026 - ATC - ATC-03

  describe table it_febko lines wa_contador.
  if wa_contador > 0.
     SELECT fp~gjahr fp~budat fp~ak1bl fp~texts fp~chect fp~kukey
           INTO CORRESPONDING FIELDS OF TABLE it_FEBEP
           FROM FEBKO as fk inner join febep as fp
           on fk~KUKEY  EQ fp~KUKEY
           where fk~bukrs = p_bukrs .
  endif.

  wa_fec_proceso = p_budat.
  SORT it_bsis     BY BUKRS GJAHR BELNR BUZEI.
  SORT it_skb1     BY BUKRS SAKNR.

  loop at it_bsis.
       wa_tabix = sy-tabix.

       READ TABLE it_bkpf WITH KEY BUKRS = it_bsis-BUKRS
                                   GJAHR = it_bsis-GJAHR
                                   BELNR = it_bsis-BELNR.
       if sy-subrc = 0.
          it_bsis-BKTXT    = it_bkpf-BKTXT.     "Texto Cabecera
          it_bsis-AWKEY    = it_bkpf-AWKEY.     "Clave Referencia
          it_bsis-USNAM    = it_bkpf-USNAM.     "Usuario
          it_bsis-STBLG    = it_bkpf-STBLG.     "N° Doc. Anulacion
          it_bsis-STJAH    = it_bkpf-STJAH.     "Ejercicio Doc. Anulacion
          it_bsis-STGRD    = it_bkpf-STGRD.     "Motivo Anulacion
          it_bsis-XREF1_HD = it_bkpf-XREF1_HD.  "Clave Ref Cab 1
          it_bsis-XREF2_HD = it_bkpf-XREF2_HD.  "Clave Ref Cab 2

*ResQ Comment:Correction not required as Select Single is used 23/12/2019 EY_DES02 ECDK917080 *
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*          SELECT single zzmot_emis FROM bseg
*           INTO CORRESPONDING FIELDS OF it_bseg
*           WHERE BUKRS = it_bkpf-BUKRS
*                 and GJAHR = it_bkpf-GJAHR
*                 and BELNR = it_bkpf-BELNR
*                 and BUZEI = it_bsis-BUZEI.
*
* NEW CODE
          SELECT zzmot_emis
          UP TO 1 ROWS  FROM bseg
           INTO CORRESPONDING FIELDS OF it_bseg
           WHERE BUKRS = it_bkpf-BUKRS
                 and GJAHR = it_bkpf-GJAHR
                 and BELNR = it_bkpf-BELNR
                 and BUZEI = it_bsis-BUZEI ORDER BY PRIMARY KEY.

          ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
          IF sy-subrc eq 0.
            it_bsis-ZZMOT_EMIS = it_bseg-ZZMOT_EMIS.
          ENDIF.
       endif.

       READ TABLE it_febep WITH KEY GJAHR = it_bsis-GJAHR
                                    BUDAT = it_bkpf-BUDAT
                                    AK1BL = it_bsis-BELNR.
       if sy-subrc = 0.
             it_bsis-TEXTS = it_febep-TEXTS.
             it_bsis-CHECT = it_febep-CHECT.
             READ TABLE it_febko WITH KEY KUKEY = it_febep-KUKEY.
             if sy-subrc = 0.
                 it_bsis-AZNUM = it_febko-AZNUM.
             endif.
       endif.

       READ TABLE it_skb1 WITH KEY BUKRS = it_bsis-BUKRS
                                   SAKNR = it_bsis-HKONT.

       if sy-subrc = 0.
          it_bsis-HBKID = it_skb1-HBKID.  "Banco Propio
       endif.

       MODIFY it_bsis INDEX wa_tabix.

  endloop.



  SORT it_bsis       BY BUKRS HKONT.
  SORT it_caratula   BY BUKRS HKONT.
  SORT it_proyeccion BY BUKRS HKONT.

  loop at it_bsis.
       IF it_bsis-BLART in S_BLART.
          clear it_movbanco_open.
          MOVE-CORRESPONDING it_bsis TO it_movbanco_open.
          wa_SISTEMA               = 'SAP_BANCO'.
          it_movbanco_open-SISTEMA = wa_sistema.
          it_movbanco_open-USUARIO =  it_bsis-USNAM.
          append it_movbanco_open.
          swMovto = 'B'.
       ELSE.
          clear it_movconta_open.
          MOVE-CORRESPONDING it_bsis TO it_movconta_open.
          wa_SISTEMA               = 'SAP_CONTABILIDAD'.
          it_movconta_open-SISTEMA = wa_sistema.
          it_movconta_open-USUARIO =  it_bsis-USNAM.
          append it_movconta_open.
          swMovto = 'C'.
       ENDIF.

       READ TABLE it_caratula WITH KEY BUKRS = it_bsis-BUKRS
                                       HKONT = it_bsis-HKONT.
       IF SY-SUBRC <> 0.
         clear it_caratula.
         it_caratula-BUKRS = it_bsis-BUKRS.
         it_caratula-HKONT = it_bsis-HKONT.
         if it_bsis-SHKZG = 'H'.
            it_bsis-WRBTR = it_bsis-WRBTR * -1.
         endif.
         if swMovto = 'B'.
            it_caratula-BANCO_OPEN = it_bsis-WRBTR.
            it_caratula-CONTA_OPEN = 0.
            it_caratula-SALDO_OPEN = it_bsis-WRBTR.
         else.
            it_caratula-CONTA_OPEN = it_bsis-WRBTR.
            it_caratula-BANCO_OPEN = 0.
            it_caratula-SALDO_OPEN = it_bsis-WRBTR.
         endif.

* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*         SELECT SINGLE txt50 INTO it_caratula-txt50 FROM skat
*               WHERE ktopl = p_pcta AND SAKNR = it_bsis-HKONT AND spras = sy-langu.
*
* NEW CODE
         SELECT txt50
         UP TO 1 ROWS  INTO it_caratula-txt50 FROM skat
               WHERE ktopl = p_pcta AND SAKNR = it_bsis-HKONT AND spras = sy-langu ORDER BY PRIMARY KEY.

         ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01

         APPEND it_caratula.
       ELSE.
         if it_bsis-SHKZG = 'H'.
            it_bsis-WRBTR = it_bsis-WRBTR * -1.
         endif.
         if swMovto = 'B'.
            it_caratula-BANCO_OPEN = it_caratula-BANCO_OPEN + it_bsis-WRBTR.
            it_caratula-SALDO_OPEN = it_caratula-BANCO_OPEN + it_caratula-CONTA_OPEN.
         else.
            it_caratula-CONTA_OPEN = it_caratula-CONTA_OPEN + it_bsis-WRBTR.
            it_caratula-SALDO_OPEN = it_caratula-BANCO_OPEN + it_caratula-CONTA_OPEN.
         endif.
         MODIFY it_caratula INDEX sy-tabix.
       ENDIF.


       READ TABLE it_proyeccion WITH KEY BUKRS   = it_bsis-BUKRS
                                         HKONT   = it_bsis-HKONT
                                         SISTEMA = wa_Sistema
                                         USUARIO = it_bsis-USNAM.
       IF SY-SUBRC <> 0.
          clear it_proyeccion.
          it_proyeccion-BUKRS   = it_bsis-BUKRS.
          it_proyeccion-HKONT   = it_bsis-HKONT.
          it_proyeccion-txt50   = it_caratula-txt50.
          it_proyeccion-SISTEMA = wa_sistema.
          it_proyeccion-USUARIO = it_bsis-USNAM.

          wa_periodo = 0.
          Perform Determina_Periodo USING it_bsis-BUDAT
                                          wa_fec_proceso
                                 CHANGING wa_periodo.

          CASE wa_periodo.
              WHEN '01'.
                it_proyeccion-MONTO_01 = it_bsis-WRBTR.
              WHEN '02'.
                it_proyeccion-MONTO_02 = it_bsis-WRBTR.
              WHEN '03'.
                it_proyeccion-MONTO_03 = it_bsis-WRBTR.
              WHEN '04'.
                it_proyeccion-MONTO_04 = it_bsis-WRBTR.
              WHEN '05'.
                it_proyeccion-MONTO_05 = it_bsis-WRBTR.
              WHEN '06'.
                it_proyeccion-MONTO_06 = it_bsis-WRBTR.
              WHEN '07'.
                it_proyeccion-MONTO_07 = it_bsis-WRBTR.
              WHEN '08'.
                it_proyeccion-MONTO_08 = it_bsis-WRBTR.
              WHEN '09'.
                it_proyeccion-MONTO_09 = it_bsis-WRBTR.
              WHEN '10'.
                it_proyeccion-MONTO_10 = it_bsis-WRBTR.
              WHEN '11'.
                it_proyeccion-MONTO_11 = it_bsis-WRBTR.
              WHEN '12'.
                it_proyeccion-MONTO_12 = it_bsis-WRBTR.
              WHEN '13'.
                it_proyeccion-MONTO_13 = it_bsis-WRBTR.
              WHEN '14'.
                it_proyeccion-MONTO_14 = it_bsis-WRBTR.
              WHEN '15'.
                it_proyeccion-MONTO_15 = it_bsis-WRBTR.
              WHEN '16'.
                it_proyeccion-MONTO_16 = it_bsis-WRBTR.
              WHEN '17'.
                it_proyeccion-MONTO_17 = it_bsis-WRBTR.
              WHEN '18'.
                it_proyeccion-MONTO_18 = it_bsis-WRBTR.
              WHEN '19'.
                it_proyeccion-MONTO_19 = it_bsis-WRBTR.
              WHEN '20'.
                it_proyeccion-MONTO_20 = it_bsis-WRBTR.
              WHEN '21'.
                it_proyeccion-MONTO_21 = it_bsis-WRBTR.
              WHEN '22'.
                it_proyeccion-MONTO_22 = it_bsis-WRBTR.
              WHEN '23'.
                it_proyeccion-MONTO_23 = it_bsis-WRBTR.
              WHEN '24'.
                it_proyeccion-MONTO_24 = it_bsis-WRBTR.
              WHEN OTHERS.
                it_proyeccion-MONTO_01 = it_bsis-WRBTR.
          ENDCASE.
          APPEND it_proyeccion.

       ELSE.
          wa_periodo = 0.
          Perform Determina_Periodo USING it_bsis-BUDAT
                                          wa_fec_proceso
                                 CHANGING wa_periodo.

          CASE wa_periodo.
              WHEN '01'.
                it_proyeccion-MONTO_01 = it_proyeccion-MONTO_01 + it_bsis-WRBTR.
              WHEN '02'.
                it_proyeccion-MONTO_02 = it_proyeccion-MONTO_02 + it_bsis-WRBTR.
              WHEN '03'.
                it_proyeccion-MONTO_03 = it_proyeccion-MONTO_03 + it_bsis-WRBTR.
              WHEN '04'.
                it_proyeccion-MONTO_04 = it_proyeccion-MONTO_04 + it_bsis-WRBTR.
              WHEN '05'.
                it_proyeccion-MONTO_05 = it_proyeccion-MONTO_05 + it_bsis-WRBTR.
              WHEN '06'.
                it_proyeccion-MONTO_06 = it_proyeccion-MONTO_06 + it_bsis-WRBTR.
              WHEN '07'.
                it_proyeccion-MONTO_07 = it_proyeccion-MONTO_07 + it_bsis-WRBTR.
              WHEN '08'.
                it_proyeccion-MONTO_08 = it_proyeccion-MONTO_08 + it_bsis-WRBTR.
              WHEN '09'.
                it_proyeccion-MONTO_09 = it_proyeccion-MONTO_09 + it_bsis-WRBTR.
              WHEN '10'.
                it_proyeccion-MONTO_10 = it_proyeccion-MONTO_10 + it_bsis-WRBTR.
              WHEN '11'.
                it_proyeccion-MONTO_11 = it_proyeccion-MONTO_11 + it_bsis-WRBTR.
              WHEN '12'.
                it_proyeccion-MONTO_12 = it_proyeccion-MONTO_12 + it_bsis-WRBTR.
              WHEN '13'.
                it_proyeccion-MONTO_13 = it_proyeccion-MONTO_13 + it_bsis-WRBTR.
              WHEN '14'.
                it_proyeccion-MONTO_14 = it_proyeccion-MONTO_14 + it_bsis-WRBTR.
              WHEN '15'.
                it_proyeccion-MONTO_15 = it_proyeccion-MONTO_15 + it_bsis-WRBTR.
              WHEN '16'.
                it_proyeccion-MONTO_16 = it_proyeccion-MONTO_16 + it_bsis-WRBTR.
              WHEN '17'.
                it_proyeccion-MONTO_17 = it_proyeccion-MONTO_17 + it_bsis-WRBTR.
              WHEN '18'.
                it_proyeccion-MONTO_18 = it_proyeccion-MONTO_18 + it_bsis-WRBTR.
              WHEN '19'.
                it_proyeccion-MONTO_19 = it_proyeccion-MONTO_19 + it_bsis-WRBTR.
              WHEN '20'.
                it_proyeccion-MONTO_20 = it_proyeccion-MONTO_20 + it_bsis-WRBTR.
              WHEN '21'.
                it_proyeccion-MONTO_21 = it_proyeccion-MONTO_21 + it_bsis-WRBTR.
              WHEN '22'.
                it_proyeccion-MONTO_22 = it_proyeccion-MONTO_22 + it_bsis-WRBTR.
              WHEN '23'.
                it_proyeccion-MONTO_23 = it_proyeccion-MONTO_23 + it_bsis-WRBTR.
              WHEN '24'.
                it_proyeccion-MONTO_24 = it_proyeccion-MONTO_24 + it_bsis-WRBTR.
              WHEN OTHERS.
                it_proyeccion-MONTO_01 = it_proyeccion-MONTO_01 + it_bsis-WRBTR.
          ENDCASE.

         MODIFY it_proyeccion INDEX sy-tabix.
       ENDIF.
  endloop.

  SORT it_proyeccion BY  bukrs hkont SISTEMA USUARIO.
  LOOP AT it_proyeccion.
          it_proyeccion-SALDO_ANUAL =
                                it_proyeccion-SALDO_ANUAL +
                                it_proyeccion-MONTO_01 + it_proyeccion-MONTO_02 + it_proyeccion-MONTO_03 +
                                it_proyeccion-MONTO_04 + it_proyeccion-MONTO_05 + it_proyeccion-MONTO_06 +
                                it_proyeccion-MONTO_07 + it_proyeccion-MONTO_08 + it_proyeccion-MONTO_09 +
                                it_proyeccion-MONTO_10 + it_proyeccion-MONTO_11 + it_proyeccion-MONTO_12 +
                                it_proyeccion-MONTO_13 + it_proyeccion-MONTO_14 + it_proyeccion-MONTO_15 +
                                it_proyeccion-MONTO_16 + it_proyeccion-MONTO_17 + it_proyeccion-MONTO_18 +
                                it_proyeccion-MONTO_19 + it_proyeccion-MONTO_20 + it_proyeccion-MONTO_21 +
                                it_proyeccion-MONTO_22 + it_proyeccion-MONTO_23 + it_proyeccion-MONTO_24.

         MODIFY it_proyeccion INDEX sy-tabix.

  ENDLOOP.
ENDFORM.                    " select_items_abiertos

*&---------------------------------------------------------------------*
*&      Form  SELECT_ITEMS_COMPENSADAS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM SELECT_ITEMS_COMPENSADAS .
  REFRESH: it_bsas, it_movbanco, it_movconta.

* BEGIN. 07-07-2026 - ATC - ATC-03
* OLD CODE
*  SELECT bukrs belnr gjahr buzei hkont blart shkzg wrbtr
*          FROM bsas  INTO CORRESPONDING FIELDS OF TABLE it_bsas
*           WHERE BUKRS EQ P_BUKRS
*           AND   HKONT IN S_SAKNR
*           AND   BUDAT LE P_BUDAT.
*
* NEW CODE
  SELECT bukrs belnr gjahr buzei hkont blart shkzg wrbtr

          FROM bsas  INTO CORRESPONDING FIELDS OF TABLE it_bsas
           WHERE BUKRS EQ P_BUKRS
           AND   HKONT IN S_SAKNR
           AND   BUDAT LE P_BUDAT ORDER BY PRIMARY KEY.

* END. 07-07-2026 - ATC - ATC-03

  describe table it_bsas lines wa_contador.
  if wa_contador > 0.

     select distinct bk~bukrs bk~belnr bk~gjahr bk~bktxt bk~awkey bk~usnam bk~stblg
            bk~stjah bk~stgrd bk~xref1_hd bk~xref2_hd bk~budat
           into corresponding fields of table it_bkpf
          from bkpf as bk inner join bsas as bs
            on bk~bukrs = bs~bukrs
               and bk~belnr = bs~belnr
               and bk~gjahr = bs~gjahr
           where bs~bukrs eq p_bukrs
           and   bs~hkont in s_saknr
           and   bs~budat le p_budat.

  endif.

* BEGIN. 07-07-2026 - ATC - ATC-03
* OLD CODE
*  SELECT kukey aznum FROM febko
*           INTO CORRESPONDING FIELDS OF TABLE it_febko
*           WHERE BUKRS  EQ p_BUKRS.
*
* NEW CODE
  SELECT kukey aznum
 FROM febko
           INTO CORRESPONDING FIELDS OF TABLE it_febko
           WHERE BUKRS  EQ p_BUKRS ORDER BY PRIMARY KEY.

* END. 07-07-2026 - ATC - ATC-03

  describe table it_febko lines wa_contador.
  if wa_contador > 0.
     select fp~gjahr fp~budat fp~ak1bl fp~texts fp~chect fp~kukey
           into corresponding fields of table it_febep
           from febko as fk inner join febep as fp
           on fk~kukey  eq fp~kukey
           where fk~bukrs = p_bukrs .
  endif.

  wa_fec_proceso = p_budat.
  SORT it_bsas     BY BUKRS GJAHR BELNR BUZEI.
  SORT it_skb1     BY BUKRS SAKNR.

  loop at it_bsas.
       wa_tabix = sy-tabix.

       READ TABLE it_bkpf WITH KEY BUKRS = it_bsas-BUKRS
                                   GJAHR = it_bsas-GJAHR
                                   BELNR = it_bsas-BELNR.
       if sy-subrc = 0.
          it_bsas-BKTXT    = it_bkpf-BKTXT.     "Texto Cabecera
          it_bsas-AWKEY    = it_bkpf-AWKEY.     "Clave Referencia
          it_bsas-USNAM    = it_bkpf-USNAM.     "Usuario
          it_bsas-STBLG    = it_bkpf-STBLG.     "N° Doc. Anulacion
          it_bsas-STJAH    = it_bkpf-STJAH.     "Ejercicio Doc. Anulacion
          it_bsas-STGRD    = it_bkpf-STGRD.     "Motivo Anulacion
          it_bsas-XREF1_HD = it_bkpf-XREF1_HD.  "Clave Ref Cab 1
          it_bsas-XREF2_HD = it_bkpf-XREF2_HD.  "Clave Ref Cab 2

*ResQ Comment:Correction not required as Select Single is used 23/12/2019 EY_DES02 ECDK917080 *
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*          SELECT single zzmot_emis FROM bseg
*          INTO CORRESPONDING FIELDS OF it_bseg
*          WHERE BUKRS = it_bkpf-BUKRS
*                and GJAHR = it_bkpf-GJAHR
*                and BELNR = it_bkpf-BELNR
*                and BUZEI = it_bsas-BUZEI.
*
* NEW CODE
          SELECT zzmot_emis
          UP TO 1 ROWS  FROM bseg
          INTO CORRESPONDING FIELDS OF it_bseg
          WHERE BUKRS = it_bkpf-BUKRS
                and GJAHR = it_bkpf-GJAHR
                and BELNR = it_bkpf-BELNR
                and BUZEI = it_bsas-BUZEI ORDER BY PRIMARY KEY.

          ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01

         if sy-subrc = 0.
            it_bsas-ZZMOT_EMIS = it_bseg-ZZMOT_EMIS.
         endif.

       endif.


       READ TABLE it_febep WITH KEY GJAHR = it_bsas-GJAHR
                                    BUDAT = it_bkpf-BUDAT
                                    AK1BL = it_bsas-BELNR.
       if sy-subrc = 0.
             it_bsas-TEXTS = it_febep-TEXTS.
             it_bsas-CHECT = it_febep-CHECT.
             READ TABLE it_febko WITH KEY KUKEY = it_febep-KUKEY.
             if sy-subrc = 0.
                 it_bsas-AZNUM = it_febko-AZNUM.
             endif.
       endif.

       READ TABLE it_skb1 WITH KEY BUKRS = it_bsas-BUKRS
                                   SAKNR = it_bsas-HKONT.
       if sy-subrc = 0.
          it_bsas-HBKID = it_skb1-HBKID.  "Banco Propio
       endif.

       MODIFY it_bsas INDEX wa_tabix.
  endloop.

  SORT it_bsis BY BUKRS HKONT.
  loop at it_bsis.
       MOVE-CORRESPONDING it_bsis TO it_bsas.
       APPEND it_bsas.
  endloop.

  SORT it_bsas       BY BUKRS HKONT.
  SORT it_caratula   BY BUKRS HKONT.
  SORT it_proyeccion BY BUKRS HKONT.

  loop at it_bsas.
       IF it_bsas-BLART in S_BLART.
          clear it_movbanco.
          MOVE-CORRESPONDING it_bsas TO it_movbanco.
          wa_SISTEMA               = 'SAP_BANCO'.
          it_movbanco-SISTEMA = wa_sistema.
          it_movbanco-USUARIO =  it_bsas-USNAM.
          append it_movbanco.
          swMovto = 'B'.
       ELSE.
          clear it_movconta.
          MOVE-CORRESPONDING it_bsas TO it_movconta.
          wa_SISTEMA               = 'SAP_CONTABILIDAD'.
          it_movconta-SISTEMA = wa_sistema.
          it_movconta-USUARIO =  it_bsas-USNAM.
          append it_movconta.
          swMovto = 'C'.
       ENDIF.

       READ TABLE it_caratula WITH KEY BUKRS = it_bsas-BUKRS
                                       HKONT = it_bsas-HKONT.
       IF SY-SUBRC <> 0.
         clear it_caratula.
         it_caratula-BUKRS = it_bsas-BUKRS.
         it_caratula-HKONT = it_bsas-HKONT.
         if it_bsas-SHKZG = 'H'.
            it_bsas-WRBTR = it_bsas-WRBTR * -1.
         endif.
         if swMovto = 'B'.
            it_caratula-BANCO = it_bsas-WRBTR.
            it_caratula-CONTA = 0.
            it_caratula-SALDO = it_bsas-WRBTR.
         else.
            it_caratula-CONTA = it_bsas-WRBTR.
            it_caratula-BANCO = 0.
            it_caratula-SALDO = it_bsas-WRBTR.
         endif.

* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*         SELECT SINGLE txt50 INTO it_caratula-txt50 FROM skat
*               WHERE ktopl = p_pcta AND SAKNR = it_bsas-HKONT AND spras = sy-langu.
*
* NEW CODE
         SELECT txt50
         UP TO 1 ROWS  INTO it_caratula-txt50 FROM skat
               WHERE ktopl = p_pcta AND SAKNR = it_bsas-HKONT AND spras = sy-langu ORDER BY PRIMARY KEY.

         ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01

         APPEND it_caratula.
       ELSE.
         if it_bsas-SHKZG = 'H'.
            it_bsas-WRBTR = it_bsas-WRBTR * -1.
         endif.
         if swMovto = 'B'.
            it_caratula-BANCO = it_caratula-BANCO + it_bsas-WRBTR.
            it_caratula-SALDO = it_caratula-BANCO + it_caratula-CONTA.
         else.
            it_caratula-CONTA = it_caratula-CONTA + it_bsas-WRBTR.
            it_caratula-SALDO = it_caratula-BANCO + it_caratula-CONTA.
         endif.
         MODIFY it_caratula INDEX sy-tabix.
       ENDIF.

  ENDLOOP.

ENDFORM.                    " SELECT_ITEMS_COMPENSADAS
*&---------------------------------------------------------------------*
*&      Form  LISTA_ALV
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM LISTA_ALV .

  REFRESH: fieldcat.
  CLEAR: fieldcat, layout, print.

* ALV
* Definicion de parametros de layout
  layout-no_keyfix = ' '.
  layout-zebra = 'X'.
  layout-f2code = 'VER'.
  layout-colwidth_optimize = 'X'.


   wa_titulo = 'Resumen Conciliación Bancaria'.


  PERFORM f_asigna_fieldcat USING:
    'BUKRS'       'IT_CARATULA' ' ' ' '  '01' ' ' ' ' 'Sociedad' ' ' ' ' ' ' '10',
    'HKONT'       'IT_CARATULA' ' ' ' '  '02' ' ' ' ' 'Cuenta'  ' ' ' ' ' ' '20',
    'TXT50'       'IT_CARATULA' ' ' ' '  '03' ' ' ' ' 'Descripción_Cuenta'   ' ' ' ' ' ' '50',
    'BANCO'       'IT_CARATULA' ' ' ' '  '04' ' ' ' ' 'SAP_Bancos'      ' ' ' ' ' ' '35',
    'CONTA'       'IT_CARATULA' ' ' ' '  '05' ' ' ' ' 'SAP_Contabilidad'      ' ' ' ' ' ' '35',
    'SALDO'       'IT_CARATULA' ' ' ' '  '06' ' ' ' ' 'Total_General'      ' ' ' ' ' ' '35',
    'BANCO_OPEN'  'IT_CARATULA' ' ' ' '  '07' ' ' ' ' 'SAP_Bancos'      ' ' ' ' ' ' '35',
    'CONTA_OPEN'  'IT_CARATULA' ' ' ' '  '08' ' ' ' ' 'SAP_Contabilidad'      ' ' ' ' ' ' '35',
    'SALDO_OPEN'  'IT_CARATULA' ' ' ' '  '09' ' ' ' ' 'Total_General'      ' ' ' ' ' ' '35'.

  print-no_print_listinfos = 'X'.
  print-no_print_selinfos  = 'X'.

  repid = sy-repid.
  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
         EXPORTING
              i_callback_program       = repid
              i_callback_user_command  = g_user_command
              i_callback_html_top_of_page = g_callback_html_top_of_page
              i_structure_name         = 'IT_CARATULA'
              i_grid_title             =  wa_titulo
              is_layout                = layout
              it_fieldcat              = fieldcat[]
*             it_sort                  = sort[]
*             i_default                = 'X'
*             i_save                   = 'A'
*             is_variant               = variante
              is_print                 = print
         TABLES
              t_outtab                 = IT_CARATULA
         EXCEPTIONS
              program_error            = 1
              OTHERS                   = 2.

  IF sy-subrc <> 0.
*    MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*            WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.

ENDFORM.                    " LISTA_ALV


*----------------------------------------------------------------------*
FORM LISTA_ALV_2 .
*----------------------------------------------------------------------*

  REFRESH: fieldcat.
  CLEAR: fieldcat, layout, print.

* ALV
* Definicion de parametros de layout
  layout-no_keyfix = ' '.
  layout-zebra = 'X'.
  layout-f2code = 'VER'.
  layout-colwidth_optimize = 'X'.



  PERFORM f_asigna_fieldcat USING:
    'BUKRS'      'IT_DETALLE' ' ' ' '  '01' ' ' ' ' 'Sociedad' ' ' ' ' ' ' '10',
    'HKONT'      'IT_DETALLE' ' ' ' '  '02' ' ' ' ' 'Cuenta'  ' ' ' ' ' ' '10',
    'HBKID'      'IT_DETALLE' ' ' ' '  '03' ' ' ' ' 'Bco_Propio'  ' ' ' ' ' ' '10',
    'GJAHR'      'IT_DETALLE' ' ' ' '  '04' ' ' ' ' 'Ejerc'   ' ' ' ' ' ' '5',
    'BELNR'      'IT_DETALLE' ' ' ' '  '05' ' ' ' ' 'Comprobante'      ' ' ' ' ' ' '15',
    'BUZEI'      'IT_DETALLE' ' ' ' '  '06' ' ' ' ' 'Posic'      ' ' ' ' ' ' '5',
    'BUDAT'      'IT_DETALLE' ' ' ' '  '07' ' ' ' ' 'Fecha_Contab'      ' ' ' ' ' ' '10',
    'WAERS'      'IT_DETALLE' ' ' ' '  '08' ' ' ' ' 'Moneda'      ' ' ' ' ' ' '5',
    'XBLNR'      'IT_DETALLE' ' ' ' '  '09' ' ' ' ' 'Referencia'      ' ' ' ' ' ' '40',
    'BLART'      'IT_DETALLE' ' ' ' '  '10' ' ' ' ' 'Clase'      ' ' ' ' ' ' '5',
    'BSCHL'      'IT_DETALLE' ' ' ' '  '11' ' ' ' ' 'Clave'      ' ' ' ' ' ' '5',
    'MONTO'      'IT_DETALLE' ' ' ' '  '12' ' ' ' ' 'Monto'      ' ' ' ' ' ' '35',
    'SGTXT'      'IT_DETALLE' ' ' ' '  '13' ' ' ' ' 'Texto_Explicativo'      ' ' ' ' ' ' '40',
    'ZUONR'      'IT_DETALLE' ' ' ' '  '14' ' ' ' ' 'Asignacion'      ' ' ' ' ' ' '30',
    'AWKEY'      'IT_DETALLE' ' ' ' '  '15' ' ' ' ' 'Clave_Referencia'      ' ' ' ' ' ' '20',
    'USNAM'      'IT_DETALLE' ' ' ' '  '16' ' ' ' ' 'Usuario'      ' ' ' ' ' ' '20',
    'AUGDT'      'IT_DETALLE' ' ' ' '  '17' ' ' ' ' 'Fecha_Compens'      ' ' ' ' ' ' '10',
    'AUGBL'      'IT_DETALLE' ' ' ' '  '18' ' ' ' ' 'Doc_Compens'      ' ' ' ' ' ' '20',
    'STBLG'      'IT_DETALLE' ' ' ' '  '19' ' ' ' ' 'Nro_Doc_Anul'      ' ' ' ' ' ' '20',
    'STJAH'      'IT_DETALLE' ' ' ' '  '20' ' ' ' ' 'Ejerc_Doc_Anul'      ' ' ' ' ' ' '10',
    'STGRD'      'IT_DETALLE' ' ' ' '  '21' ' ' ' ' 'Motivo_Anul'      ' ' ' ' ' ' '10',
    'XREF1_HD'   'IT_DETALLE' ' ' ' '  '22' ' ' ' ' 'Clave_Ref_Cabecera_1'      ' ' ' ' ' ' '30',
    'XREF2_HD'   'IT_DETALLE' ' ' ' '  '23' ' ' ' ' 'Clave_Ref_Cabecera_2'      ' ' ' ' ' ' '30',
    'AZNUM'      'IT_DETALLE' ' ' ' '  '24' ' ' ' ' 'N° Extracto'      ' ' ' ' ' ' '30',
    'TEXTS'      'IT_DETALLE' ' ' ' '  '25' ' ' ' ' 'Clave de Texto'      ' ' ' ' ' ' '30',
    'CHECT'      'IT_DETALLE' ' ' ' '  '26' ' ' ' ' 'N° Cheque'      ' ' ' ' ' ' '30',
    'ZZMOT_EMIS' 'IT_DETALLE' ' ' ' '  '27' ' ' ' ' 'Motivo_Emision'      ' ' ' ' ' ' '30'.


  print-no_print_listinfos = 'X'.
  print-no_print_selinfos  = 'X'.

  repid = sy-repid.
  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
         EXPORTING
              i_callback_program       = repid
              i_callback_user_command  = 'USER_COMMAND2'
              i_callback_html_top_of_page = g_callback_html_top_of_page
              i_structure_name         = 'IT_DETALLE'
              i_grid_title             =  wa_titulo
              is_layout                = layout
              it_fieldcat              = fieldcat[]
*             it_sort                  = sort[]
*             i_default                = 'X'
*             i_save                   = 'A'
*             is_variant               = variante
              is_print                 = print
         TABLES
              t_outtab                 = IT_DETALLE
         EXCEPTIONS
              program_error            = 1
              OTHERS                   = 2.

  IF sy-subrc <> 0.
*    MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*            WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.

ENDFORM.                    " LISTA_ALV_2

*----------------------------------------------------------------------*
FORM LISTA_ALV_PROYECCION .
*----------------------------------------------------------------------*

  REFRESH: fieldcat.
  CLEAR: fieldcat, layout, print.

* ALV
* Definicion de parametros de layout
  layout-no_keyfix = ' '.
  layout-zebra = 'X'.
  layout-f2code = 'VER'.
  layout-colwidth_optimize = 'X'.


   wa_titulo = 'Proyeccion Anual Conciliación Bancaria'.


  PERFORM f_asigna_fieldcat USING:
    'BUKRS'         'IT_PROYECCION' ' ' ' '  '01' ' ' ' ' 'Sociedad' ' ' ' ' ' ' '10',
    'HKONT'         'IT_PROYECCION' ' ' ' '  '02' ' ' ' ' 'Cuenta'  ' ' ' ' ' ' '20',
    'TXT50'         'IT_PROYECCION' ' ' ' '  '03' ' ' ' ' 'Descripción_Cuenta'   ' ' ' ' ' ' '50',
    'SISTEMA'       'IT_PROYECCION' ' ' ' '  '04' ' ' ' ' 'Sistema'      ' ' ' ' ' ' '20',
    'USUARIO'       'IT_PROYECCION' ' ' ' '  '05' ' ' ' ' 'Usuario'      ' ' ' ' ' ' '20',
    'MONTO_01'      'IT_PROYECCION' ' ' ' '  '06' ' ' ' ' 'Mes_01'       ' ' ' ' ' ' '30',
    'MONTO_02'      'IT_PROYECCION' ' ' ' '  '07' ' ' ' ' 'Mes_02'       ' ' ' ' ' ' '30',
    'MONTO_03'      'IT_PROYECCION' ' ' ' '  '08' ' ' ' ' 'Mes_03'       ' ' ' ' ' ' '30',
    'MONTO_04'      'IT_PROYECCION' ' ' ' '  '09' ' ' ' ' 'Mes_04'       ' ' ' ' ' ' '30',
    'MONTO_05'      'IT_PROYECCION' ' ' ' '  '10' ' ' ' ' 'Mes_05'       ' ' ' ' ' ' '30',
    'MONTO_06'      'IT_PROYECCION' ' ' ' '  '11' ' ' ' ' 'Mes_06'       ' ' ' ' ' ' '30',
    'MONTO_07'      'IT_PROYECCION' ' ' ' '  '12' ' ' ' ' 'Mes_07'       ' ' ' ' ' ' '30',
    'MONTO_08'      'IT_PROYECCION' ' ' ' '  '13' ' ' ' ' 'Mes_08'       ' ' ' ' ' ' '30',
    'MONTO_09'      'IT_PROYECCION' ' ' ' '  '14' ' ' ' ' 'Mes_09'       ' ' ' ' ' ' '30',
    'MONTO_10'      'IT_PROYECCION' ' ' ' '  '15' ' ' ' ' 'Mes_10'       ' ' ' ' ' ' '30',
    'MONTO_11'      'IT_PROYECCION' ' ' ' '  '16' ' ' ' ' 'Mes_11'       ' ' ' ' ' ' '30',
    'MONTO_12'      'IT_PROYECCION' ' ' ' '  '17' ' ' ' ' 'Mes_12'       ' ' ' ' ' ' '30',
    'MONTO_13'      'IT_PROYECCION' ' ' ' '  '18' ' ' ' ' 'Mes_13'       ' ' ' ' ' ' '30',
    'MONTO_14'      'IT_PROYECCION' ' ' ' '  '19' ' ' ' ' 'Mes_14'       ' ' ' ' ' ' '30',
    'MONTO_15'      'IT_PROYECCION' ' ' ' '  '20' ' ' ' ' 'Mes_15'       ' ' ' ' ' ' '30',
    'MONTO_16'      'IT_PROYECCION' ' ' ' '  '21' ' ' ' ' 'Mes_16'       ' ' ' ' ' ' '30',
    'MONTO_17'      'IT_PROYECCION' ' ' ' '  '22' ' ' ' ' 'Mes_17'       ' ' ' ' ' ' '30',
    'MONTO_18'      'IT_PROYECCION' ' ' ' '  '23' ' ' ' ' 'Mes_18'       ' ' ' ' ' ' '30',
    'MONTO_19'      'IT_PROYECCION' ' ' ' '  '24' ' ' ' ' 'Mes_19'       ' ' ' ' ' ' '30',
    'MONTO_20'      'IT_PROYECCION' ' ' ' '  '25' ' ' ' ' 'Mes_20'       ' ' ' ' ' ' '30',
    'MONTO_21'      'IT_PROYECCION' ' ' ' '  '26' ' ' ' ' 'Mes_21'       ' ' ' ' ' ' '30',
    'MONTO_22'      'IT_PROYECCION' ' ' ' '  '27' ' ' ' ' 'Mes_22'       ' ' ' ' ' ' '30',
    'MONTO_23'      'IT_PROYECCION' ' ' ' '  '28' ' ' ' ' 'Mes_23'       ' ' ' ' ' ' '30',
    'MONTO_24'      'IT_PROYECCION' ' ' ' '  '29' ' ' ' ' 'Mes_24'       ' ' ' ' ' ' '30',
    'SALDO_ANUAL'   'IT_PROYECCION' ' ' ' '  '30' ' ' ' ' 'Total_General'       ' ' ' ' ' ' '30'.


  print-no_print_listinfos = 'X'.
  print-no_print_selinfos  = 'X'.

  repid = sy-repid.
  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
         EXPORTING
              i_callback_program       = repid
              i_callback_user_command  = 'USER_COMMAND3'
              i_callback_html_top_of_page = g_callback_html_top_of_page
              i_structure_name         = 'IT_PROYECCION'
              i_grid_title             =  wa_titulo
              is_layout                = layout
              it_fieldcat              = fieldcat[]
*             it_sort                  = sort[]
*             i_default                = 'X'
*             i_save                   = 'A'
*             is_variant               = variante
              is_print                 = print
         TABLES
              t_outtab                 = IT_PROYECCION
         EXCEPTIONS
              program_error            = 1
              OTHERS                   = 2.

  IF sy-subrc <> 0.
*    MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*            WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.

ENDFORM.                    " LISTA_ALV


*&---------------------------------------------------------------------*
*&      Form  F_ASIGNA_FIELDCAT
*&---------------------------------------------------------------------*
FORM F_ASIGNA_FIELDCAT USING x_field
                             x_tab
                             x_ref
                             x_ref_f
                             x_col_pos
                             x_hotspot
                             x_checkbox
                             x_seltext_l
                             x_key
                             x_no_out
                             x_do_sum
                             x_largo.

DATA: v_yy_ant(4)   TYPE n.
DATA: v_mm_ant(2)   TYPE n.

  fieldcat-fieldname     = x_field.
  fieldcat-tabname       = x_tab.
  fieldcat-ref_tabname   = x_ref.
  fieldcat-ref_fieldname = x_ref_f.
  fieldcat-col_pos       = x_col_pos.
  fieldcat-hotspot       = x_hotspot.
  fieldcat-checkbox      = x_checkbox.
  fieldcat-seltext_l     = x_seltext_l.
  fieldcat-key           = x_key.
  fieldcat-no_out        = x_no_out.
  fieldcat-do_sum        = x_do_sum.
  fieldcat-outputlen     = x_largo.

  IF x_field = 'BANCO'      OR x_field = 'CONTA'      OR x_field = 'SALDO'      OR
     x_field = 'BANCO_OPEN' OR x_field = 'CONTA_OPEN' OR x_field = 'SALDO_OPEN' OR
     x_field = 'DMBTR'      OR x_field = 'WRBTR'      OR x_field = 'MONTO'      OR
     x_field = 'MONTO_01'   OR x_field = 'MONTO_02'   OR x_field = 'MONTO_03'   OR
     x_field = 'MONTO_04'   OR x_field = 'MONTO_05'   OR x_field = 'MONTO_06'   OR
     x_field = 'MONTO_07'   OR x_field = 'MONTO_08'   OR x_field = 'MONTO_09'   OR
     x_field = 'MONTO_10'   OR x_field = 'MONTO_11'   OR x_field = 'MONTO_12'   OR
     x_field = 'MONTO_13'   OR x_field = 'MONTO_14'   OR x_field = 'MONTO_15'   OR
     x_field = 'MONTO_16'   OR x_field = 'MONTO_17'   OR x_field = 'MONTO_18'   OR
     x_field = 'MONTO_19'   OR x_field = 'MONTO_20'   OR x_field = 'MONTO_21'   OR
     x_field = 'MONTO_22'   OR x_field = 'MONTO_23'   OR x_field = 'MONTO_24'   OR
     x_field = 'SALDO_ANUAL'.

     fieldcat-currency      = 'CLP'.
     fieldcat-do_sum = c_x.

     IF  x_field = 'MONTO_01'   OR x_field = 'MONTO_02'   OR x_field = 'MONTO_03'   OR
         x_field = 'MONTO_04'   OR x_field = 'MONTO_05'   OR x_field = 'MONTO_06'   OR
         x_field = 'MONTO_07'   OR x_field = 'MONTO_08'   OR x_field = 'MONTO_09'   OR
         x_field = 'MONTO_10'   OR x_field = 'MONTO_11'   OR x_field = 'MONTO_12'   OR
         x_field = 'MONTO_13'   OR x_field = 'MONTO_14'   OR x_field = 'MONTO_15'   OR
         x_field = 'MONTO_16'   OR x_field = 'MONTO_17'   OR x_field = 'MONTO_18'   OR
         x_field = 'MONTO_19'   OR x_field = 'MONTO_20'   OR x_field = 'MONTO_21'   OR
         x_field = 'MONTO_22'   OR x_field = 'MONTO_23'   OR x_field = 'MONTO_24'.

         CASE x_field+6(2).
             WHEN '01' OR '02' OR '03' OR '04' OR '05' OR '06' OR
                  '07' OR '08' OR '09' OR '10' OR '11' OR '12'.

                v_yy_ant = p_budat+0(4) - 1.
                CONCATENATE v_yy_ant x_field+6(2) INTO fieldcat-seltext_l SEPARATED BY '/'.

             WHEN '13' OR '14' OR '15' OR '16' OR '17' OR '18' OR
                  '19' OR '20' OR '21' OR '22' OR '23' OR '24'.

                v_mm_ant = x_field+6(2).
                v_mm_ant = v_mm_ant - 12.
                CONCATENATE p_budat+0(4) v_mm_ant INTO fieldcat-seltext_l SEPARATED BY '/'.

         ENDCASE.
    ENDIF.

  ENDIF.

  IF x_field = 'BUKRS' OR x_field = 'HKONT' OR x_field = 'HBKID'.
     fieldcat-key    = c_x.
  ENDIF.

  IF x_field = 'BELNR'.
     fieldcat-hotspot    = c_x.
  ENDIF.

  APPEND fieldcat.
  CLEAR fieldcat.

ENDFORM.                    " F_ASIGNA_FIELDCAT

*---------------------------------------------------------------------*
FORM user_command USING r_ucomm LIKE sy-ucomm
                        rs_selfield TYPE slis_selfield.
*---------------------------------------------------------------------*

* Nos aseguramos que no haya pinchado sobre una linea sin nada
  CHECK NOT rs_selfield-tabname IS INITIAL.

  CASE r_ucomm.
    WHEN 'VER'.
      READ TABLE it_caratula INDEX rs_selfield-tabindex.
      wa_BUKRS = it_caratula-BUKRS.
      wa_HKONT = it_caratula-HKONT.


      IF it_caratula-hkont IS INITIAL or wa_HKONT is initial.
        MESSAGE S004(zfi) WITH 'Cuenta no definida'.

      ELSEIF rs_selfield-FIELDNAME <> 'SALDO' AND rs_selfield-FIELDNAME <> 'SALDO_OPEN'.
        MESSAGE S004(zfi) WITH 'Debe seleccionar columnas Total_General'.

      ELSE.
        if rs_selfield-FIELDNAME = 'SALDO'.
           PERFORM busca_detalle.
        elseif rs_selfield-FIELDNAME = 'SALDO_OPEN'.
           PERFORM busca_detalle_open.
        endif.

      ENDIF.

    WHEN 'BACK'.
      refresh it_detalle.
      SET SCREEN 0.
      LEAVE SCREEN.

    WHEN OTHERS.
      refresh it_detalle.
      SET SCREEN 0.
      LEAVE SCREEN.

  ENDCASE.

ENDFORM.

*---------------------------------------------------------------------*
*       FORM USER_COMMAND2                            *
*---------------------------------------------------------------------*
* Definir rutina que responderá a los eventos en listado              *
*---------------------------------------------------------------------*
FORM user_command2 USING r_ucomm LIKE sy-ucomm
                        rs_selfield TYPE slis_selfield.

* Nos aseguramos que no haya pinchado sobre una linea sin nada
  CHECK NOT rs_selfield-tabname IS INITIAL.

  CASE r_ucomm.
    WHEN 'VER'.
      READ TABLE it_detalle INDEX rs_selfield-tabindex.
      wa_BUKRS = it_detalle-BUKRS.
      wa_BELNR = it_detalle-BELNR.
      wa_GJAHR = it_detalle-GJAHR.

      IF wa_BUKRS IS INITIAL or wa_BELNR is initial or wa_GJAHR is initial.
        MESSAGE e004(zfi) WITH 'Debe seleccionar un Comprobante'.
      ELSE.
        PERFORM ver_comprobante.
      ENDIF.

    WHEN 'BACK'.
      SET SCREEN 0.
*      CLEAR ok_code.
      LEAVE SCREEN.

    WHEN OTHERS.
      SET SCREEN 0.
*      CLEAR ok_code.
      LEAVE SCREEN.

  ENDCASE.

ENDFORM.

*---------------------------------------------------------------------*
FORM user_command3  USING r_ucomm LIKE sy-ucomm
                          rs_selfield TYPE slis_selfield.
*---------------------------------------------------------------------*
* Nos aseguramos que no haya pinchado sobre una linea sin nada
  CHECK NOT rs_selfield-tabname IS INITIAL.

  CASE r_ucomm.
    WHEN 'VER'.
      READ TABLE it_proyeccion INDEX rs_selfield-tabindex.
      wa_BUKRS = it_proyeccion-BUKRS.
      wa_HKONT = it_proyeccion-HKONT.
      wa_SISTE = it_proyeccion-SISTEMA.
      wa_USUAR = it_proyeccion-USUARIO.

      IF it_proyeccion-hkont   IS INITIAL or wa_HKONT is initial
      OR it_proyeccion-sistema IS INITIAL or wa_SISTE is initial
      OR it_proyeccion-usuario IS INITIAL or wa_USUAR is initial.
        MESSAGE S004(zfi) WITH 'Cuenta no definida'.

      ELSE.
        IF rs_selfield-FIELDNAME <> 'SALDO_ANUAL'.
          MESSAGE S004(zfi) WITH 'Debe seleccionar columnas Total_General'.
        ELSE.
          if rs_selfield-FIELDNAME = 'SALDO_ANUAL'.
           PERFORM busca_detalle_open_anual.
          endif.
        ENDIF.
      ENDIF.

    WHEN 'BACK'.
      refresh it_detalle.
      SET SCREEN 0.
      LEAVE SCREEN.

    WHEN OTHERS.
      refresh it_detalle.
      SET SCREEN 0.
      LEAVE SCREEN.

  ENDCASE.


ENDFORM.



*&---------------------------------------------------------------------*
*&      Form  BUSCA_DETALLE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM BUSCA_DETALLE .
  refresh it_detalle.

  LOOP AT it_movbanco WHERE BUKRS = wa_BUKRS AND HKONT = wa_HKONT.
    clear it_detalle.
    MOVE-CORRESPONDING it_movbanco TO it_detalle.
    if it_detalle-SHKZG = 'H'.
       it_detalle-MONTO = it_detalle-DMBTR * -1.
    else.
       it_detalle-MONTO = it_detalle-DMBTR.
    endif.
    APPEND it_Detalle.
  ENDLOOP.
  LOOP AT it_movconta WHERE BUKRS = wa_BUKRS AND HKONT = wa_HKONT.
    clear it_detalle.
    MOVE-CORRESPONDING it_movconta TO it_detalle.
    if it_detalle-SHKZG = 'H'.
       it_detalle-MONTO = it_detalle-DMBTR * -1.
    else.
       it_detalle-MONTO = it_detalle-DMBTR.
    endif.
    APPEND it_Detalle.
  ENDLOOP.

  wa_titulo = 'Detalle Conciliación Bancaria (todas)'.
  PERFORM lista_alv_2.

ENDFORM.                    " BUSCA_DETALLE

*----------------------------------------------------------------------*
FORM BUSCA_DETALLE_OPEN .
*----------------------------------------------------------------------*
  refresh it_detalle.
  LOOP AT it_movbanco_open WHERE BUKRS = wa_BUKRS AND HKONT = wa_HKONT.
    clear it_detalle.
    MOVE-CORRESPONDING it_movbanco_open TO it_detalle.
    if it_detalle-SHKZG = 'H'.
       it_detalle-MONTO = it_detalle-DMBTR * -1.
    else.
       it_detalle-MONTO = it_detalle-DMBTR.
    endif.
    APPEND it_Detalle.
  ENDLOOP.
  LOOP AT it_movconta_open WHERE BUKRS = wa_BUKRS AND HKONT = wa_HKONT.
    clear it_detalle.
    MOVE-CORRESPONDING it_movconta_open TO it_detalle.
    if it_detalle-SHKZG = 'H'.
       it_detalle-MONTO = it_detalle-DMBTR * -1.
    else.
       it_detalle-MONTO = it_detalle-DMBTR.
    endif.
    APPEND it_Detalle.
  ENDLOOP.

  wa_titulo = 'Detalle Conciliación Bancaria (partidas abiertas)'.
  PERFORM lista_alv_2.

ENDFORM.


*----------------------------------------------------------------------*
FORM BUSCA_DETALLE_OPEN_ANUAL .
*----------------------------------------------------------------------*
  refresh it_detalle.

  SORT it_movbanco_open BY BUKRS HKONT SISTEMA USUARIO.

  LOOP AT it_movbanco_open WHERE BUKRS = wa_BUKRS   AND HKONT   = wa_HKONT
                             AND SISTEMA = wa_SISTE AND USUARIO = wa_usuar.
    clear it_detalle.
    MOVE-CORRESPONDING it_movbanco_open TO it_detalle.
    if it_detalle-SHKZG = 'H'.
       it_detalle-MONTO = it_detalle-DMBTR * -1.
    else.
       it_detalle-MONTO = it_detalle-DMBTR.
    endif.
    APPEND it_Detalle.
  ENDLOOP.

  SORT it_movconta_open BY BUKRS HKONT SISTEMA USUARIO.
  LOOP AT it_movconta_open WHERE BUKRS = wa_BUKRS AND HKONT = wa_HKONT.
    clear it_detalle.
    MOVE-CORRESPONDING it_movconta_open TO it_detalle.
    if it_detalle-SHKZG = 'H'.
       it_detalle-MONTO = it_detalle-DMBTR * -1.
    else.
       it_detalle-MONTO = it_detalle-DMBTR.
    endif.
    APPEND it_Detalle.
  ENDLOOP.

  wa_titulo = 'Detalle Conciliación Bancaria (partidas abiertas)'.
  PERFORM lista_alv_2.

ENDFORM.

*---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  html_top_of_page
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->DOCUMENT   text
*----------------------------------------------------------------------*
form html_top_of_page using document
                            type ref to cl_dd_document.     "#EC CALLED

  data: l_title      type sdydo_text_element,
          l_text       type sdydo_text_element,
          l_font       type sdydo_attribute value '1',
          ls_zfigiro   type zfigiro,
          l_month      type fcltx.
*L1
  l_text = 'Sociedad:'.
  call method document->new_line.
  call method document->add_text
    exporting
      text         = l_text
      sap_emphasis = 'Strong'.

  call method document->add_gap
    exporting
      width = 8.

* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*  select single * from t001 where BUKRS = p_bukrs.
*
* NEW CODE
  SELECT *
  UP TO 1 ROWS  from t001 where BUKRS = p_bukrs ORDER BY PRIMARY KEY.

  ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
  concatenate t001-BUTXT ' '
    into l_text separated by space.
  call method document->add_text
    exporting
      text         = l_text
      sap_emphasis = 'Strong'.
*L2
  l_text = 'Banco Propio:'.
  call method document->new_line.
  call method document->add_text
    exporting
      text         = l_text
      sap_emphasis = 'Strong'.

  call method document->add_gap
    exporting
      width = 8.

  if wa_HBKID = '0'.
     concatenate S_HBKID-low '' into l_text.
  else.
     concatenate '' '' into l_text.
  endif.
  call method document->add_text
    exporting
      text         = l_text
      sap_fontsize = l_font.

*L3
  l_text = 'Fecha Contabilización Al:'.
  call method document->new_line.
  call method document->add_text
    exporting
      text         = l_text
      sap_emphasis = 'Strong'.

  call method document->add_gap
    exporting
      width = 8.

  concatenate p_budat+6 p_budat+4(2) p_budat(4) into l_text separated by '/'.
  call method document->add_text
    exporting
      text         = l_text
      sap_fontsize = l_font.

endform.                    "html_top_of_page
*&---------------------------------------------------------------------*
*&      Form  SELECT_PARAM
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM SELECT_PARAM .

  REFRESH: it_caratula, it_proyeccion.
  CLEAR:   it_caratula, it_proyeccion.


  wa_HBKID = '0'.
  DESCRIBE TABLE S_HBKID lines wa_contador.

  IF S_HBKID IS INITIAL AND wa_contador = 0.
     wa_HBKID = '1'.
* BEGIN. 07-07-2026 - ATC - ATC-03
* OLD CODE
*     SELECT * FROM T012  INTO TABLE it_T012 WHERE BUKRS EQ P_BUKRS.
*
* NEW CODE
     SELECT *
 FROM T012  INTO TABLE it_T012 WHERE BUKRS EQ P_BUKRS ORDER BY PRIMARY KEY.

* END. 07-07-2026 - ATC - ATC-03
     REFRESH S_HBKID.
     loop at it_t012.
           CLEAR S_HBKID.
           S_HBKID-sign   = 'I'.
           S_HBKID-option = 'EQ'.
           S_HBKID-low    = it_t012-HBKID.
           APPEND S_HBKID.
     endloop.
  ENDIF.

* BEGIN. 07-07-2026 - ATC - ATC-03
* OLD CODE
*  SELECT * FROM SKB1  INTO TABLE it_skb1 WHERE BUKRS EQ P_BUKRS AND HBKID IN S_HBKID.
*
* NEW CODE
  SELECT *
 FROM SKB1  INTO TABLE it_skb1 WHERE BUKRS EQ P_BUKRS AND HBKID IN S_HBKID ORDER BY PRIMARY KEY.

* END. 07-07-2026 - ATC - ATC-03
  REFRESH S_SAKNR.
  loop at it_skb1.
       CLEAR S_SAKNR.
       S_SAKNR-sign   = 'I'.
       S_SAKNR-option = 'EQ'.
       S_SAKNR-low    = it_skb1-SAKNR.
       APPEND S_SAKNR.
  endloop.

  describe table it_skb1 lines wa_contador.
  if wa_contador = 0.
       CLEAR S_SAKNR.
       S_SAKNR-sign   = 'I'.
       S_SAKNR-option = 'EQ'.
       S_SAKNR-low    = 'XXXX'.
       APPEND S_SAKNR.
  endif.

ENDFORM.                    " SELECT_PARAM
*&---------------------------------------------------------------------*
*&      Form  VER_COMPROBANTE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM VER_COMPROBANTE .
  SET PARAMETER ID: 'GJR' FIELD wa_GJAHR,
                    'BLN' FIELD wa_BELNR,
                    'BUK' FIELD wa_BUKRS.

  CALL TRANSACTION 'FB03' AND SKIP FIRST SCREEN.

ENDFORM.                    " VER_COMPROBANTE
*&---------------------------------------------------------------------*
*&      Form  DETERMINA_PERIODO
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_IT_BSIS_BUDAT  text
*----------------------------------------------------------------------*
FORM DETERMINA_PERIODO  USING P_BUDAT
                              P_PROYE
                     CHANGING P_PERIO.

    IF p_budat+0(4) = p_proye+0(4).
       P_PERIO = p_budat+4(2) + 12.
    ELSEIF p_budat+0(4) < p_proye+0(4).
       P_PERIO = p_budat+4(2).
    ENDIF.

ENDFORM.                    " DETERMINA_PERIODO
