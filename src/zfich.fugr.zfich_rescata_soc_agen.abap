FUNCTION ZFICH_RESCATA_SOC_AGEN.
*"----------------------------------------------------------------------
*"*"Interfase local
*"  IMPORTING
*"     REFERENCE(BUKRS) TYPE  BUKRS
*"     REFERENCE(AGENCIA) TYPE  ZZ_AGENCIA
*"  TABLES
*"      TABLA01 STRUCTURE  ZFICH001
*"----------------------------------------------------------------------
*tables: payr, regup, bseg, lfa1, bkpf.
*
* select * from  zfich001
*          where bukrs   = bukrs
*          and   AGENCIA = AGENCIA.
*
*
*     select single * from payr where ICHEC = ''
*                          and   zbukr = zfich001-BUKRS
*                          and   HBKID = zfich001-HBKID
*                          and   HKTID = zfich001-HKTID
*                          and   CHECT = zfich001-CHECT.
*
*     select single  * from  regup where laufd = payr-laufd
*                              and    laufi = payr-laufi
*                              and    xvorl = ''
*                              and    zbukr = payr-zbukr
*                              and    lifnr = payr-lifnr
*                              and    kunnr = payr-kunnr
*                              and    empfg = payr-empfg
*                              and    vblnr = payr-vblnr.
*
*     select single  * from  bseg where bukrs  = regup-bukrs
*                         and  belnr = regup-belnr
*                         and  gjahr = regup-gjahr
*                         and  buzei = regup-buzei.
*
*          consulta-zzmot_emis = bseg-zzmot_emis.
*          select single name1 stcd1  from lfa1 into (name1, stcd1) where lifnr = zfich001-lifnr.
*          move-corresponding zfich001 to consulta.
*          consulta-zaldt        = payr-zaldt.
*          consulta-rwbtr        = payr-rwbtr.
*          consulta-zzmot_emis   = zzmot_emis.
*          consulta-name1        = name1.
*          consulta-stcd1        = stcd1.
*
*          select single * from bkpf where bukrs = bukrs
*                         and   belnr = zfich001-belnr
*                         and   gjahr = zfich001-gjahr.
*
*          if sy-subrc = 0 and bkpf-stgrd is not initial.
*            consulta-observacion =   'Cambio Estado Anulado'.
*          endif.
*
*          append consulta.
*
*        endselect.
*
*
*
*
*
*
*
*
*  refresh consulta1.
*
*  sort consulta by bukrs hbkid  hktid chect  fecha_reg hora_reg.
*  clear: motivo_ant, cuenta_ant.
*  loop at consulta.
*
*    check consulta-observacion  is initial.
*
*    read table tmotivo  with key estado = consulta-estado
*                         binary search.
*
*
*    move-corresponding  consulta to consulta1.
*    consulta1-estado_d = tmotivo-descri.
*
*    consulta1-estado_d_ant = motivo_ant.
*    consulta1-hkont_ant = cuenta_ant.
*
*    motivo_ant = tmotivo-descri.
*    cuenta_ant = consulta-hkont.
*
*    if sy-subrc = 0 and tmotivo-gench = 'X'.
*      perform buscar_nuevo_cheque.
*    endif.
*    at end of chect.
*      if consulta1-chect is not initial.
*        append consulta1.
*        clear consulta1.
*      endif.
*    endat.
*  endloop.




ENDFUNCTION.
