*&---------------------------------------------------------------------*
*& REPORT  Z_cir239_pago_valevista
*&
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*

REPORT  Z_cir239_pago_valevista.

type-pools: slis.
tables :  reguh,
          bsak,
          payr.

*Tipos
types: begin of sp_insert,
      FECHA_PROCESO like sy-datum,
      ZBUKR type string,
      LIFNR type string,
      VBLNR type string,
      STCD1 type string,
      NAME1 type string,
      ZALDT like sy-datum,
      RZAWE type string,
      HBKID type string,
      WRBTR type p,
      FECHA_PAGO  like sy-datum,
      BLART type string,
      HKONT type string,
      BELNR type string,
      BUZEI type string,
      BUDAT like sy-datum,
      BLDAT like sy-datum,
      ZUONR type string,
      XBLNR type string,
      ZFBDT like sy-datum,
      NUMERO_DOCUMENTO  type string,
      CAMPO1  type string,
      CAMPO2  type string,
      FECHA_RECHAZO like sy-datum,
      MOTIVO_RECHAZO  type string,
      MOTIVO_EMISION  type string,
      GJAHR2  type string,
      ZALDT2  type string,
      VBLNR2  type string,
      AUGBL2  type string,
      AUGDT2  type string,
      FECHA_PROCESO_ISAPRE  like sy-datum,
      INFORMADO type string,
      FECHA_EMI_ANTERIOR  like sy-datum,
       end of sp_insert.
data: it_spins type sp_insert,
      t_spins type STANDARD TABLE OF sp_insert.
data: wa_reguh type reguh,
      str type string,
      w_monto like payr-rwbtr,
      status type statusflag1.
data: amount_display like wmto_s-amount,
      amount_sap like wmto_s-amount.
data: it_reguh type standard table of reguh,
      w_iter type i.

selection-screen begin of block b1.
parameters: p_zbukr like reguh-ZBUKR obligatory.
SELECT-OPTIONS: p_fecpag for reguh-fecha_pago,
                p_hkont for bsak-hkont.

selection-screen end of block b1.

parameters: p_fproc like sy-datum.
parameters: p_rzawe like reguh-rzawe obligatory.


START-OF-SELECTION.
  IF status = 'X'.
    exit.
  ENDIF.

if p_rzawe = 'V'.

      write: /, 'comienza extracto de vale vista' .

      SELECT *
      from reguh
      where  	zbukr = p_zbukr
        and fecha_pago in p_fecpag
        and xvorl <> 'X'
             and rzawe ='V'.
*     asigna los valores correspondientes a reguh
        clear it_spins.
        it_spins-fecha_proceso = p_fproc.
            it_spins-ZBUKR           = reguh-ZBUKR.
            it_spins-LIFNR           = reguh-lifnr.
            it_spins-VBLNR           = reguh-vblnr.
            it_spins-STCD1           = reguh-stcd1.
            it_spins-NAME1           = reguh-NAME1.
            it_spins-ZALDT           = reguh-ZALDT.
            it_spins-RZAWE           = reguh-RZAWE.
            it_spins-HBKID           = reguh-HBKID.
            it_spins-FECHA_PAGO      = reguh-FECHA_PAGO.
            it_spins-NUMERO_DOCUMENTO = reguh-identif_pago.
            it_spins-FECHA_RECHAZO   = reguh-fecha_rechazo.
            it_spins-MOTIVO_RECHAZO   = reguh-motivo_rechazo.

        amount_sap = reguh-rwbtr.
        CALL FUNCTION 'CURRENCY_AMOUNT_SAP_TO_DISPLAY'
        EXPORTING
              CURRENCY              = reguh-waers
              AMOUNT_INTERNAL       = amount_sap
        IMPORTING
              AMOUNT_DISPLAY        = amount_display.
        it_spins-wrbtr = amount_display.

            select single blart hkont belnr buzei budat bldat zuonr xblnr zfbdt ZZMOT_EMIS
                        into (it_spins-blart, it_spins-hkont, it_spins-belnr, it_spins-buzei, it_spins-budat, it_spins-bldat, it_spins-zuonr, it_spins-xblnr, it_spins-zfbdt, it_spins-motivo_emision)
            from bsak
            where bukrs = reguh-ZBUKR
              and lifnr = reguh-lifnr
              and augbl = reguh-vblnr
              and hkont in p_hkont
                         and augdt = reguh-zaldt
              and shkzg = 'H'.
*     append solo si encuentra registros en bsak
        IF sy-subrc = 0.
          APPEND IT_spins to t_spins.
        endif.
      ENDSELECT.

      clear it_spins.
endif.

*&----------------------------------------------------------------------------------------------------------------
*&
*&----------------------------------------------------------------------------------------------------------------

* extrae registros de transferencia
if p_rzawe = 'T'.
      write: /, 'comienza extracto de transferencias '.

      SELECT *
*      ZBUKR lifnr vblnr stcd1 NAME1 ZALDT RZAWE HBKID identif_pago fecha_rechazo motivo_rechazo rwbtr waers
      from reguh
      where  	zbukr = p_zbukr
        and zaldt in p_fecpag
        and xvorl <> 'X'
       and rzawe ='T'.
*     asigna los valores correspondientes a reguh
        clear it_spins.
        it_spins-fecha_proceso = p_fproc.
            it_spins-ZBUKR           = reguh-ZBUKR.
            it_spins-LIFNR           = reguh-lifnr.
            it_spins-VBLNR           = reguh-vblnr.
            it_spins-STCD1           = reguh-stcd1.
            it_spins-NAME1           = reguh-NAME1.
            it_spins-ZALDT           = reguh-ZALDT.
            it_spins-RZAWE           = reguh-RZAWE.
            it_spins-HBKID           = reguh-HBKID.
            it_spins-FECHA_PAGO      = reguh-zaldt.
            it_spins-NUMERO_DOCUMENTO = reguh-identif_pago.
            it_spins-FECHA_RECHAZO   = reguh-fecha_rechazo.
            it_spins-MOTIVO_RECHAZO   = reguh-motivo_rechazo.

        amount_sap = reguh-rwbtr.
        CALL FUNCTION 'CURRENCY_AMOUNT_SAP_TO_DISPLAY'
        EXPORTING
              CURRENCY              = reguh-waers
              AMOUNT_INTERNAL       = amount_sap
        IMPORTING
              AMOUNT_DISPLAY        = amount_display.
        it_spins-wrbtr = amount_display.

            select single blart hkont belnr buzei budat bldat zuonr xblnr zfbdt ZZMOT_EMIS
                        into (it_spins-blart, it_spins-hkont, it_spins-belnr, it_spins-buzei, it_spins-budat, it_spins-bldat, it_spins-zuonr, it_spins-xblnr, it_spins-zfbdt, it_spins-motivo_emision)
            from bsak
            where bukrs = reguh-ZBUKR
              and lifnr = reguh-lifnr
              and augbl = reguh-vblnr
* and augdt = reguh-zaldt
              and hkont in p_hkont
              and shkzg = 'H'.
*     append solo si encuentra registros en bsak
        IF sy-subrc = 0.
          APPEND IT_spins to t_spins.
        else.
            select single blart hkont belnr buzei budat bldat zuonr xblnr zfbdt ZZMOT_EMIS
                        into (it_spins-blart, it_spins-hkont, it_spins-belnr, it_spins-buzei, it_spins-budat, it_spins-bldat, it_spins-zuonr, it_spins-xblnr, it_spins-zfbdt, it_spins-motivo_emision)
            from bsak
            where bukrs = reguh-ZBUKR
              and lifnr = reguh-lifnr
              and augbl = reguh-vblnr
              and zfbdt = reguh-zaldt
* esto es para el caso en que no coincide la fecha de compensacion
              and hkont in p_hkont
              and shkzg = 'H'.
              if sy-subrc = 0.
                APPEND IT_spins to t_spins.
              ENDIF.
        endif.
      ENDSELECT.
endif.


if p_rzawe = 'C'.
      write: /, 'comienza extracto de cheques '.

      SELECT *
      from payr
      where    zbukr = p_zbukr
        and bancd in p_fecpag
        and xbanc = 'X'
           and rzawe ='C'.
*     asigna los valores correspondientes a payr
        clear it_spins.
        it_spins-fecha_proceso = p_fproc.
            it_spins-ZBUKR           = payr-ZBUKR.
            it_spins-LIFNR           = payr-lifnr.
            it_spins-VBLNR           = payr-vblnr.
            it_spins-ZALDT           = payr-ZALDT.
            it_spins-RZAWE           = payr-RZAWE.
            it_spins-FECHA_PAGO      = payr-bancd.
            it_spins-NUMERO_DOCUMENTO = payr-chect.

        amount_sap = payr-rwbtr.
        CALL FUNCTION 'CURRENCY_AMOUNT_SAP_TO_DISPLAY'
        EXPORTING
              CURRENCY              = payr-waers
              AMOUNT_INTERNAL       = amount_sap
        IMPORTING
              AMOUNT_DISPLAY        = amount_display.
        it_spins-wrbtr = amount_display.

        select single stcd1 name1
          into (it_spins-stcd1, it_spins-name1)
        from lfa1
        where lifnr = payr-lifnr.

            select single hbkid blart hkont belnr buzei budat bldat zuonr xblnr zfbdt ZZMOT_EMIS
                        into (it_spins-hbkid, it_spins-blart, it_spins-hkont, it_spins-belnr, it_spins-buzei, it_spins-budat, it_spins-bldat, it_spins-zuonr, it_spins-xblnr, it_spins-zfbdt, it_spins-motivo_emision)
            from bsak
            where bukrs = payr-ZBUKR
              and lifnr = payr-lifnr
              and augbl = payr-vblnr
              and hkont in p_hkont
*                         and augdt = payr-zaldt
              and shkzg = 'H'.
*     append solo si encuentra registros en bsak
        IF sy-subrc = 0.
          APPEND IT_spins to t_spins.
        endif.
      ENDSELECT.
endif.

  exec sql.
    connect to 'SAPCSC' as 'con'
  endexec.

  exec sql.
    set connection 'con'
  endexec.

  exec sql.
    execute procedure Pkg_Circular239.prc_delete_pago ( IN :p_fproc, IN :p_zbukr  )
  endexec.

  w_iter = 0.
  status = 'X'.
  loop at t_spins INTO it_spins.
    try.
        add 1 to w_iter.
        if w_iter > 1000.
          w_iter = 0.
          exec sql.
            SET CONNECTION DEFAULT
          endexec.
          exec sql.
            set connection 'con'
          endexec.
        endif.
        EXEC SQL.
          EXECUTE PROCEDURE Pkg_Circular239.prc_insert_pago(
                                                                IN :it_spins-FECHA_PROCESO ,
                                                                IN :it_spins-ZBUKR ,
                                                                IN :it_spins-LIFNR ,
                                                                IN :it_spins-VBLNR ,
                                                                IN :it_spins-STCD1 ,
                                                                IN :it_spins-NAME1 ,
                                                                IN :it_spins-ZALDT ,
                                                                IN :it_spins-RZAWE ,
                                                                IN :it_spins-HBKID ,
                                                                IN :it_spins-WRBTR ,
                                                                IN :it_spins-FECHA_PAGO ,
                                                                IN :it_spins-BLART ,
                                                                IN :it_spins-HKONT ,
                                                                IN :it_spins-BELNR ,
                                                                IN :it_spins-BUZEI ,
                                                                IN :it_spins-BUDAT ,
                                                                IN :it_spins-BLDAT ,
                                                                IN :it_spins-ZUONR ,
                                                                IN :it_spins-XBLNR ,
                                                                IN :it_spins-ZFBDT ,
                                                                IN :it_spins-NUMERO_DOCUMENTO ,
                                                                IN :it_spins-CAMPO1 ,
                                                                IN :it_spins-CAMPO2 ,
                                                                IN :it_spins-FECHA_RECHAZO ,
                                                                IN :it_spins-MOTIVO_RECHAZO ,
                                                                IN :it_spins-MOTIVO_EMISION ,
                                                                IN :it_spins-GJAHR2 ,
                                                                IN :it_spins-ZALDT2 ,
                                                                IN :it_spins-VBLNR2 ,
                                                                IN :it_spins-AUGBL2 ,
                                                                IN :it_spins-AUGDT2 ,
                                                                IN :it_spins-FECHA_PROCESO_ISAPRE ,
                                                                IN :it_spins-INFORMADO ,
                                                                IN :it_spins-FECHA_EMI_ANTERIOR
                                                           )

        ENDEXEC.

      catch cx_sy_native_sql_error.
        status = ' '.
        write 'problema al insertar registro '.
        write:    /,
                  it_spins-LIFNR ,
                  it_spins-VBLNR ,
                  it_spins-STCD1 ,
                  it_spins-NAME1 ,
                  /.
    endtry.
*    status = 'X'.
  endloop.
  write: /,'FILAS PROCESADAS ',sy-dbcnt.

  exec sql.
    SET CONNECTION DEFAULT
  endexec.

  if status = 'X'.
    write: /,
          'El proceso ha terminado correctamente y sin errores'.
  endif.
