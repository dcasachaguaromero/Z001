FUNCTION ZGETSUCUR001.
*"----------------------------------------------------------------------
*"*"Interfase local
*"  IMPORTING
*"     REFERENCE(ZZCOD_UNIDAD) TYPE  ZZ_AGENCIA
*"     REFERENCE(ZDESC) TYPE  CHAR_40
*"     REFERENCE(BANKN) TYPE  BANKN
*"     REFERENCE(BANKK) TYPE  BANKK
*"  EXPORTING
*"     REFERENCE(ZZREFSUC) TYPE  ZREFSUC
*"----------------------------------------------------------------------

  CASE BANKK.
    WHEN '012'.
      select single S~ZZREFSUC
    into (ZZREFSUC)
    from T012K AS K
          INNER JOIN T012 AS T
            ON  T~BUKRS EQ K~BUKRS
             AND T~HBKID EQ K~HBKID
              INNER JOIN ZTSUCUR AS S
                 ON S~BUKRS EQ T~BUKRS
                     AND S~ZZREFEST EQ ZDESC
      where K~BANKN EQ BANKN
            AND T~BANKL EQ BANKK
          .
    WHEN OTHERS.
  ENDCASE.

ENDFUNCTION.
