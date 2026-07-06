*----------------------------------------------------------------------*
***INCLUDE LZFIRFC003F02 .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  AMPLIA_ACREEDOR
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_I_BUKRS  text
*      -->P_I_STCD1  text
*      <--P_W_STATUS_A  text
*----------------------------------------------------------------------*
FORM AMPLIA_ACREEDOR  USING    P_I_BUKRS TYPE BUKRS
                               P_I_STCD1 TYPE STCD1
                      CHANGING P_W_STATUS_A TYPE STATUSFLAG1.
  data: wa_acree type zacreedor,
        it_acree TYPE STANDARD TABLE OF zacreedor,
        RETURN TYPE STANDARD TABLE OF BAPIRET2.

  exec sql.
    connect to 'SAPCSC' as 'con'
  endexec.

  exec sql.
    set connection 'con'
  endexec.
*           execute procedure pkg_sap_cargas.sap_carga_detalle_gasto ( IN :hkont )

  try.
    EXEC SQL.
      OPEN c1 FOR
        SELECT
              LIFNR, BUKRS, KTOKK,
              TITLE, NAME1, NAME2,
              SORT1, SORT2, STREET,
              HOUSE_NUM1, HOUSE_NUM2, PO_BOX,
              ORT01, ORT02, LAND1,
              REGIO, TEL_NUMBER, TEL1_EXT,
              TELFAX, FAX_EXTENS, SMTP_ADDR,
              KUNNR, STCD1, AKONT,
              ZUAWA, FDGRV, ZTERM1,
              ZWELS, XVERR, ZAHLS,
              WITHT, WT_WITHCD, EMPFK,
              BANKS, BANKL, BANKN,
              KOINH, BKONT, TOGRU,
              ZGRUP
          FROM SAPNW_ACREEDOR
          WHERE bukrs = :P_I_BUKRS and stcd1 = :P_I_STCD1
    ENDEXEC.

    DO.
      EXEC SQL.
        FETCH NEXT c1 INTO  :WA_ACREE-LIFNR, :WA_ACREE-BUKRS, :WA_ACREE-KTOKK,
                            :WA_ACREE-TITLE, :WA_ACREE-NAME1, :WA_ACREE-NAME2,
                            :WA_ACREE-SORT1, :WA_ACREE-SORT2, :WA_ACREE-STREET,
                            :WA_ACREE-HOUSE_NUM1, :WA_ACREE-HOUSE_NUM2, :WA_ACREE-PO_BOX,
                            :WA_ACREE-ORT01, :WA_ACREE-ORT02, :WA_ACREE-LAND1,
                            :WA_ACREE-REGIO, :WA_ACREE-TEL_NUMBER, :WA_ACREE-TEL1_EXT,
                            :WA_ACREE-TELFAX, :WA_ACREE-FAX_EXTENS, :WA_ACREE-SMTP_ADDR,
                            :WA_ACREE-KUNNR, :WA_ACREE-STCD1, :WA_ACREE-AKONT,
                            :WA_ACREE-ZUAWA, :WA_ACREE-FDGRV, :WA_ACREE-ZTERM1,
                            :WA_ACREE-ZWELS, :WA_ACREE-XVERR, :WA_ACREE-ZAHLS,
                            :WA_ACREE-WITHT, :WA_ACREE-WT_WITHCD, :WA_ACREE-EMPFK,
                            :WA_ACREE-BANKS, :WA_ACREE-BANKL, :WA_ACREE-BANKN,
                            :WA_ACREE-KOINH, :WA_ACREE-BKONT, :WA_ACREE-TOGRU,
                            :WA_ACREE-ZGRUP
      ENDEXEC.
      IF sy-subrc <> 0.
        EXIT.
      ELSE.
        WA_ACREE-ACCION = '10'.
        APPEND WA_ACREE TO IT_ACREE.
      ENDIF.
    ENDDO.
    EXEC SQL.
      CLOSE c1
    ENDEXEC.
  catch cx_sy_native_sql_error.
*    status = ' '.
    message text-001 type 'I'.
*    message `Error in Native SQL.` type 'I'.
  endtry.

  exec sql.
    SET CONNECTION DEFAULT
  endexec.

  CALL FUNCTION 'ZFIRFC003'
    TABLES
      T_ACREEDOR       = IT_ACREE
      RETURN           = RETURN
            .

ENDFORM.                    " AMPLIA_ACREEDOR
