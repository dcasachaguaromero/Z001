*&---------------------------------------------------------------------*
*& Report  ZAUX_ADDCARTOLAS
*&
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*

REPORT  ZAUX_ADDCARTOLAS.
TABLES: FEBEP, FEBKO.

PARAMETERS: S_DEL TYPE statusflag1,
            P_BUKRS LIKE FEBKO-BUKRS
            .

SELECT-OPTIONS: S_HBKID FOR FEBKO-HBKID.


DATA: w_pempresa         like febko-bukrs,
      w_pfecha           like febep-budat,
      w_pcuenta          like febko-hkont,
      w_pcartola         like febko-aznum,
      w_psecuencia       like febep-esnum,
      w_preferencia      like febep-chect,
      w_valor            like febep-KWBTR,
      w_pglosa           like febep-butxt,
      w_pdebe            type string,
      w_phaber           type string,
      w_pcalce_banco     like febep-belnr,
      w_ptipo_documento  like febep-vgint,
      w_signo            like febep-EPVOZ,
      w_moneda like febep-KWAER,
      w_pfec_carga       type sy-datum.
data: amount_display like wmto_s-amount,
      amount_sap like wmto_s-amount,
      l_oref type ref to cx_root,
      status type statusflag1,
      w_iter type i.

START-OF-SELECTION.
  exec sql.
    connect to 'SAPCSC' as 'con'
  endexec.

  exec sql.
    set connection 'con'
  endexec.

IF s_del = 'X'.
  EXEC SQL.
    EXECUTE PROCEDURE csc_sap_auxiliares.sp_delete_con_movcar( IN :status )
  ENDEXEC.
ENDIF.

  CLEAR w_iter.
  status = 'X'.

  select a~bukrs b~budat a~hkont a~aznum b~esnum b~chect b~butxt b~kwbtr b~belnr b~vgint b~epvoz b~KWAER
    into (w_pempresa  ,w_pfecha  ,w_pcuenta ,w_pcartola  ,w_psecuencia  ,w_preferencia ,w_pglosa  ,w_valor ,
          w_pcalce_banco  ,w_ptipo_documento, w_signo, w_moneda)
    from febep as b inner join febko as a
                on b~kukey eq a~kukey
    where a~bukrs = p_bukrs
          and a~hbkid in s_hbkid.

      amount_sap = w_valor.
      call function 'CURRENCY_AMOUNT_SAP_TO_DISPLAY'
        exporting
          currency              = w_moneda
          amount_internal       = amount_sap
       importing
         amount_display        = amount_display
*       EXCEPTIONS
*         INTERNAL_ERROR        = 1
*         OTHERS                = 2
                .
      IF w_signo = 'H'.
        w_phaber = amount_display.
        w_pdebe = '0'.
      ELSE.
        w_pdebe = amount_display.
        w_phaber = '0'.
      ENDIF.

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
            EXECUTE PROCEDURE csc_sap_auxiliares.sp_insert_cartolas(
                                                                        IN :w_pempresa         ,
                                                                        IN :w_pfecha           ,
                                                                        IN :w_pcuenta          ,
                                                                        IN :w_pcartola         ,
                                                                        IN :w_psecuencia       ,
                                                                        IN :w_preferencia      ,
                                                                        IN :w_pglosa           ,
                                                                        IN :w_pdebe            ,
                                                                        IN :w_phaber           ,
                                                                        IN :w_pcalce_banco     ,
                                                                        IN :w_ptipo_documento  ,
                                                                        IN :w_pfec_carga
                                                                        )

          ENDEXEC.
        catch cx_sy_native_sql_error into l_oref.
          status = ' '.
          write 'problema al insertar el cheque'.
          write:    /,
                    w_pempresa         ,
                    w_pfecha           ,
                    w_pcuenta          ,
                    w_pcartola         ,
                    w_psecuencia       ,
                    w_preferencia      ,
                    w_pglosa           ,
                    w_pdebe            ,
                    w_phaber           ,
                    w_pcalce_banco     ,
                    w_ptipo_documento  ,
                    w_pfec_carga       ,
                    /.
*          message text-001 type 'I'.
*          message `Error in Native SQL.` type 'I'.
        endtry.

  ENDSELECT.

  exec sql.
    SET CONNECTION DEFAULT
  endexec.

  if status = 'X'.
      write: /,
            'El proceso ha terminado correctamente y sin errores'.
  endif.
