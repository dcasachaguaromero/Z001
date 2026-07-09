class ZCL_IM_FAGL_ITEMS_CH_DATA definition
  public
  final
  create public .

*"* public components of class ZCL_IM_FAGL_ITEMS_CH_DATA
*"* do not include other source files here!!!
public section.

  interfaces IF_EX_FAGL_ITEMS_CH_DATA .
protected section.
*"* protected components of class ZCL_IM_FAGL_ITEMS_CH_DATA
*"* do not include other source files here!!!
private section.
*"* private components of class ZCL_IM_FAGL_ITEMS_CH_DATA
*"* do not include other source files here!!!
ENDCLASS.



CLASS ZCL_IM_FAGL_ITEMS_CH_DATA IMPLEMENTATION.


method IF_EX_FAGL_ITEMS_CH_DATA~CHANGE_ITEMS.
  data: wa_FAGL_SEGMT type FAGL_SEGMT.
  data: ta_FAGL_SEGMT type TABLE OF FAGL_SEGMT initial size 0.
  data: wa_FAGL_t001 type T001.
  data: ta_FAGL_t001 type TABLE OF t001 initial size 0.
  data: wa_FAGL_skat type skat.
  data: ta_FAGL_skat type TABLE OF skat initial size 0.
  data: wa_t012t type t012t.
  data: wa_hbkid type t012t-hbkid.
  data: wa_hktid type t012t-hktid.
  data: wa_itab type string.
  data: wa_t012k type t012k.
  DATA: str1 TYPE string,
     str2 TYPE string,
     str3 TYPE string,
     itab TYPE TABLE OF string,
     text TYPE string.
  data: wa_clave type bkpf-bktxt.
  data: wa_febep type febep.
  data: wa_aznum type febko-aznum.
  data:  wa_ct_items type  FAGLPOSX.
  data: zhkont TYPE bseg-hkont.
* ziclos 23 Febrero variables necesarias para los añadir campos de cheques.
  types: begin of ty_payr,
          lifnr type payr-lifnr,
          stcd1 type lfa1-stcd1,
          name1 type lfa1-name1,
* ziclos mayo 2011 solicitan cambiar PRIDT por ZALDT
*          PRIDT type payr-PRIDT,
          ZALDT type payr-ZALDT,
          vblnr type payr-vblnr,
          chect type payr-chect,  " no lo  han pedido . "21.03.11
         end of ty_payr.
  data: wa_payr type ty_payr.

* ziclos fin inserción  23 Febrero
*ziclos este código estaba antes del cambio
  DATA WA_ITEMS LIKE LINE OF CT_ITEMS.
*  BREAK-POINT.
  LOOP AT CT_ITEMS INTO WA_ITEMS.
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*    SELECT SINGLE TXT50
*      INTO WA_ITEMS-TXT50
*      FROM SKAT
*      WHERE SPRAS = SY-LANGU AND
*            KTOPL = 'B100'   AND
*            SAKNR = WA_ITEMS-KONTO.
*
* NEW CODE
    SELECT TXT50
    UP TO 1 ROWS 
      INTO WA_ITEMS-TXT50
      FROM SKAT
      WHERE SPRAS = SY-LANGU AND
            KTOPL = 'B100'   AND
            SAKNR = WA_ITEMS-KONTO ORDER BY PRIMARY KEY.

    ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
*ziclos incluimos la busqueda de XREF1 en la tabla BSEG
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*    SELECT SINGLE XREF1 into WA_ITEMS-XREF1 from  bseg
*                      where BUKRS  = WA_ITEMS-bukrs and
*                            BELNR  = WA_ITEMS-belnr and
*                            GJAHR  = WA_ITEMS-gjahr and
*                            BUZEI  = WA_ITEMS-buzei.
*
* NEW CODE
    SELECT XREF1
    UP TO 1 ROWS  into WA_ITEMS-XREF1 from  bseg
                      where BUKRS  = WA_ITEMS-bukrs and
                            BELNR  = WA_ITEMS-belnr and
                            GJAHR  = WA_ITEMS-gjahr and
                            BUZEI  = WA_ITEMS-buzei ORDER BY PRIMARY KEY.

    ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
    MODIFY CT_ITEMS FROM WA_ITEMS.
  ENDLOOP.
* ziclos fin del codigo inicial


**********************************************************************************
* Búsqueda de la descripción de la cuenta
**********************************************************************************
* BEGIN. 07-07-2026 - ATC - ATC-03
* OLD CODE
*  select * from  SKAT into table ta_fagl_skat
*                            where spras = sy-langu and
*                                  ktopl = 'B100'.
*
* NEW CODE
  SELECT *
 from  SKAT into table ta_fagl_skat
                            where spras = sy-langu and
                                  ktopl = 'B100' ORDER BY PRIMARY KEY.

* END. 07-07-2026 - ATC - ATC-03

  loop at ct_items into wa_ct_items where
                         hkont+0(4) = '1011'.
    read table ta_FAGL_skat into wa_FAGL_skat with key saknr = wa_CT_ITEMS-hkont.
    if sy-subrc = 0.
      move wa_FAGL_SKAT-txt50 to wa_CT_ITEMS-ZZDESC_CTA.
      modify ct_items from wa_CT_ITEMS.
    endif.
  endloop.
**********************************************************************************
* Búsqueda de la descripción de la cuenta
**********************************************************************************
*necesito los datos del campo REFERENCIA ( XBLNR )

  loop at ct_items into wa_ct_items where
                         hkont+0(4) = '1011'.





    CONCATENATE wa_ct_items-HKONT(9) '0' INTO ZHKONT.
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*    SELECT SINGLE hbkid hktid INTO (wa_hbkid, wa_hktid)
*      FROM T012K
*      WHERE BUKRS EQ wa_ct_items-bukrs
*      AND   HKONT EQ ZHKONT.
*
* NEW CODE
    SELECT hbkid hktid
    UP TO 1 ROWS  INTO (wa_hbkid, wa_hktid)
      FROM T012K
      WHERE BUKRS EQ wa_ct_items-bukrs
      AND   HKONT EQ ZHKONT ORDER BY PRIMARY KEY.

    ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
*lo dejamos por si solicitan la descripción del banco propio
*    select single * from t012t into wa_t012t where
*                SPRAS  = sy-langu and
*                BUKRS  = wa_ct_items-bukrs and
*                HBKID  = wa_hbkid and
*                HKTID = wa_hktid.
*
*    move wa_t012t-TEXT1  to  wa_CT_ITEMS-ZZBANK_TEXT.
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*    select single * from t012k into wa_t012k where
*                  BUKRS  = wa_ct_items-bukrs and
*                  HBKID  = wa_hbkid and
*                  HKTID = wa_hktid.
*
* NEW CODE
    SELECT *
    UP TO 1 ROWS  from t012k into wa_t012k where
                  BUKRS  = wa_ct_items-bukrs and
                  HBKID  = wa_hbkid and
                  HKTID = wa_hktid ORDER BY PRIMARY KEY.

    ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
    move wa_t012k-bankn  to  wa_CT_ITEMS-ZZBANKN.

*    move wa_hbkid        to   wa_ct_items-u_hbkid.
    move wa_hbkid        to   wa_ct_items-zzhbkid.
    modify ct_items from wa_CT_ITEMS.

    CLEAR:  wa_hbkid,
            wa_hktid.

  endloop.
**********************************************************************************
* Búsqueda del campo FEBEP-TEXTS
**********************************************************************************

**********************************************************************************
* Búsqueda del extracto de cuenta y campo FEBEP_TEXTS
*********************************************************************************
*necesito los datos del campo texto cabecera
  data: v_bukrs type bsas-bukrs,
        v_belnr type bsas-belnr,
        v_gjahr type bsas-gjahr,
        v_blart type bsas-blart.
* ziclos mayo 2011 añadimos una tabla para relacionar el documento de pago con todos sus cambios de status ( ZA)
data: g_belnr type bsas-belnr.
data: r_belnr type range of bsas-belnr initial size 0.
data: BEGIN OF wa_belnr,
         sign   TYPE c LENGTH 1,
         option TYPE c LENGTH 2,
         low    type bsas-belnr,
         high   type bsas-belnr,
       END OF wa_belnr.


data: v_sizp.

data: v_hkont(10) value '10111%'.
*   types : begin of ty_docpago ,
*                   belnr type bkpf-belnr,  "documento
*                   docpago type bkpf-belnr, " documento ZP
*           end of ty_docpago.
*   data: ta_docpago type  table of ty_docpago initial size 0.





* ziclos fin mayo 2011
  loop at ct_items into wa_ct_items where
                         hkont+0(4) = '1011'.

* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*    select single bktxt from bkpf into wa_clave where
*                           bukrs = wa_ct_items-bukrs and
*                           belnr = wa_ct_items-belnr and
*                           gjahr = wa_ct_items-gjahr.
*
* NEW CODE
    SELECT bktxt
    UP TO 1 ROWS  from bkpf into wa_clave where
                           bukrs = wa_ct_items-bukrs and
                           belnr = wa_ct_items-belnr and
                           gjahr = wa_ct_items-gjahr ORDER BY PRIMARY KEY.

    ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01


* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*    select single * from febep into wa_febep where
*                             kukey = wa_clave+0(8) and
*                             esnum = wa_clave+8(5).
*
* NEW CODE
    SELECT *
    UP TO 1 ROWS  from febep into wa_febep where
                             kukey = wa_clave+0(8) and
                             esnum = wa_clave+8(5) ORDER BY PRIMARY KEY.

    ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*    select single aznum from febko into wa_aznum where
*                            kukey = wa_clave+0(8).
*
* NEW CODE
    SELECT aznum
    UP TO 1 ROWS  from febko into wa_aznum where
                            kukey = wa_clave+0(8) ORDER BY PRIMARY KEY.

    ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01

    move wa_aznum to wa_ct_items-ZZAZNUM.
*    if not wa_febep-vgext is initial.
*      move wa_febep-vgext to wa_ct_items-ZZvgext.  "electrónica
*    else.
*      move wa_febep-VGMAN to wa_ct_items-ZZvgext.  "manual
*    endif.
    move wa_febep-texts to wa_ct_items-ZZtexts.
    modify ct_items from wa_CT_ITEMS.

  endloop.
**********************************************************************************
* Búsqueda de campos del cheque.
*********************************************************************************
  loop at ct_items into wa_ct_items where
                         blart = 'ZP' or blart = 'ZA'.
    if wa_ct_items-blart = 'ZP'.
* mayo 2011 se cambia PRIDT por ZALDT
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*      select  single lifnr ZALDT vblnr chect from payr into corresponding fields of wa_payr where
*                                                        ZBUKR  = wa_ct_items-bukrs and
*                                                        VBLNR  = wa_ct_items-belnr and
*                                                        GJAHR  = wa_ct_items-gjahr.
*
* NEW CODE
      SELECT lifnr ZALDT vblnr chect
      UP TO 1 ROWS  from payr into corresponding fields of wa_payr where
                                                        ZBUKR  = wa_ct_items-bukrs and
                                                        VBLNR  = wa_ct_items-belnr and
                                                        GJAHR  = wa_ct_items-gjahr ORDER BY PRIMARY KEY.

      ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
      if sy-subrc eq 0.
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*        select single name1 stcd1 from lfa1 into corresponding fields of wa_payr where
*                                                     lifnr  = wa_payr-lifnr.  .
*
* NEW CODE
        SELECT name1 stcd1
        UP TO 1 ROWS  from lfa1 into corresponding fields of wa_payr where
                                                     lifnr  = wa_payr-lifnr ORDER BY PRIMARY KEY.  .

        ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01

        move:  wa_payr-lifnr to  wa_ct_items-ZZLIFNR,
               wa_payr-stcd1 to  wa_ct_items-zzstcd1_recep,
               wa_payr-name1 to wa_ct_items-zzname_recep,
* mayo 2011 se cambia PRIDT por ZALDT
*               wa_payr-pridt to wa_ct_items-zzpridt,
               wa_payr-zaldt to wa_ct_items-zzpridt,
               wa_payr-vblnr to wa_ct_items-zzvblnr,
               wa_payr-chect to wa_ct_items-u_checf. "no lo han pedido "21.03.11

        modify ct_items from wa_CT_ITEMS.

      endif.
    else.
      clear: v_bukrs,v_belnr,v_gjahr,v_blart.
      clear v_sizp.
      refresh: r_belnr.
      clear wa_belnr.
      clear g_belnr.
                     move '1'   to wa_belnr-low.
                     move 'I'     to wa_belnr-sign.
                     move 'EQ'    to wa_belnr-option.
                     append wa_belnr to r_belnr.

                   while v_sizp ne 'X'.

* BEGIN. 07-07-2026 - ATC - ATC-03
* OLD CODE
*                    select  bukrs belnr gjahr blart from bsas into (v_bukrs,v_belnr,v_gjahr, v_blart ) where
*                                                                                 BUKRS = wa_ct_items-bukrs and
**                                                                                 HKONT like v_hkont  and  "= wa_ct_items-hkont and
**                                                                                AUGDT = wa_ct_items-AUGDT and
*                                                                                 AUGBL = wa_ct_items-belnr and
*                                                                                 ZUONR = wa_ct_items-zuonr  and
*                                                                                 GJAHR = wa_ct_items-gjahr.
*
* NEW CODE
                    SELECT bukrs belnr gjahr blart
 from bsas into (v_bukrs,v_belnr,v_gjahr, v_blart ) where
                                                                                 BUKRS = wa_ct_items-bukrs and
*                                                                                 HKONT like v_hkont  and  "= wa_ct_items-hkont and
*                                                                                AUGDT = wa_ct_items-AUGDT and
                                                                                 AUGBL = wa_ct_items-belnr and
                                                                                 ZUONR = wa_ct_items-zuonr  and
                                                                                 GJAHR = wa_ct_items-gjahr ORDER BY PRIMARY KEY.

* END. 07-07-2026 - ATC - ATC-03
                      if  wa_ct_items-belnr ne v_belnr.
                         move v_belnr to g_belnr.
                      endif.
                      if  v_blart eq 'ZP'.
                      move 'X' to v_SIZP.    " si tiene documento ZP
                      exit.
                      else.

                      endif.
                    endselect.
                    if sy-subrc ne 0 or v_sizp eq 'X'.
                      exit.
                    endif.
                     if  g_belnr in r_belnr.
                       exit.
                     endif.
                     if not g_belnr is initial.

                     move g_belnr to wa_ct_items-belnr.
                     move g_belnr to wa_belnr-low.
                     move 'I'     to wa_belnr-sign.
                     move 'EQ'    to wa_belnr-option.
                     append wa_belnr to r_belnr.
                     else.
                       clear g_belnr.
                       exit.
                     endif.
                     clear g_belnr.
                  endwhile.

      if v_sizp eq 'X'.
* mayo 2011 se cambia PRIDT por ZALDT
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*        select  single lifnr zaldt vblnr chect  from payr into corresponding fields of wa_payr where
*                                                    ZBUKR  = v_bukrs and
*                                                    VBLNR  = v_belnr and
*                                                    GJAHR  = v_gjahr.
*
* NEW CODE
        SELECT lifnr zaldt vblnr chect
        UP TO 1 ROWS   from payr into corresponding fields of wa_payr where
                                                    ZBUKR  = v_bukrs and
                                                    VBLNR  = v_belnr and
                                                    GJAHR  = v_gjahr ORDER BY PRIMARY KEY.

        ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
        if sy-subrc eq 0.
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*          select single name1 stcd1 from lfa1 into corresponding fields of wa_payr where
*                                                       lifnr  = wa_payr-lifnr.  .
*
* NEW CODE
          SELECT name1 stcd1
          UP TO 1 ROWS  from lfa1 into corresponding fields of wa_payr where
                                                       lifnr  = wa_payr-lifnr ORDER BY PRIMARY KEY.  .

          ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01

          move:  wa_payr-lifnr to  wa_ct_items-ZZLIFNR,
                 wa_payr-stcd1 to  wa_ct_items-zzstcd1_recep,
                 wa_payr-name1 to wa_ct_items-zzname_recep,
* se solicita cambiar la fecha de imnpresion por ZALDT
*                 wa_payr-pridt to wa_ct_items-zzpridt,
                 wa_payr-ZALDT to wa_ct_items-zzpridt,
* fin del cambio
                 wa_payr-vblnr to wa_ct_items-zzvblnr,
                 wa_payr-chect to wa_ct_items-u_checf. "no lo han pedido "21.03.11

          modify ct_items from wa_CT_ITEMS.
*


        endif.
      endif.
    endif.

  endloop.
*************************************************************************************
endmethod.
ENDCLASS.
