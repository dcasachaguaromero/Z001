*&---------------------------------------------------------------------*
*& Report: < ZEY_GDS_CORRECTION > *
*& Author: < EY_DES03 > *
*& Description: < ReSQ Correction > *
*& Date: <19-12-2019> *
*& Transport Number: < ECDK917080 > *
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&  Include           ZFITR001_CLASS
*&---------------------------------------------------------------------*
*----------------------------------------------------------------------*
*       CLASS C_CONTADOR DEFINITION
*----------------------------------------------------------------------*
CLASS MULTICASH DEFINITION.
  PUBLIC SECTION.
*declaracion de variables publicas de los metodos.
    CONSTANTS: W_PCOMA(1)  TYPE C VALUE   ';',
               W_SLASH(1)  TYPE C VALUE   '/',
               W_MAS(1)    TYPE C VALUE   '+',
               W_MENOS(1)  TYPE C VALUE   '-'.
    data: w_BANKL type  BANKL.
    DATA: IT_DATA     TYPE STANDARD TABLE OF LINE,

          WA_DATA     TYPE LINE,
          WA_D        TYPE LINE,
          WA_C        TYPE LINE,
          W_TR001(40) TYPE C.

    TYPES:
*    IT_DETALLE  TYPE STANDARD TABLE OF TY_BCID,
*           IT_HEADER1  TYPE STANDARD TABLE OF TY_BCIC,
           ITO_C       TYPE STANDARD TABLE OF LINE,
           ITO_D       TYPE STANDARD TABLE OF LINE,

*   BEGIN OF TY_CHLC,
*
*     END OF TY_CHL,

    BEGIN OF TY_STNDC,
          COD_BANK(3)  TYPE C,    "Codigo del banco clave 3
          CTBKN(12)    TYPE C,    "Numero de la cuenta BANCARIA 5
          NUM_CTLA(5)  TYPE C,    "Numero de la cartola (n ESTRACTO) 6
          FEC_CONT(8)  TYPE C,    "Fecha generacion 7 contabilizacion
          MONEDA(3)    TYPE C,    "tipo Moneda
          SAL_INI(12)  TYPE C,    "Saldo Inicial
          TOT_C(18)     TYPE C,    "Total Cargos
          TOT_A(18)     TYPE C,    "Total Abonos
          SAL_FIN(18)  TYPE C,    "Saldo Final
          IN_CTA(35)   TYPE C,    "Indicador Cuenta "bank account holder
          XP_CTA(35)   type c,    "X special account name
          NOM_MOV(18)  TYPE C,    "Numero de movimientos.
  END OF TY_STNDC,

       BEGIN OF TY_STNDD,
          COD_BANK(3)  TYPE C,    "1 Codigo del banco clave 3
          CTBKN(12)    TYPE C,    "2 Numero de la cuenta BANCARIA 5
          NUM_CTLA(5)  TYPE C,    "3 Numero de la cartola (n ESTRACTO) 6
          FEC_val(8)  TYPE C,     "4 Fecha generacion  Fecha valor 7 contabilizacion
          PRNOT_num(10) type c,   "5 primary note number
          NOT_PAY01(27) type c,   "6 note to payee 1
          bank_postext(40) type c, "7 bank posting text
          filler1(1)   type C,                              "8 no usado
          COD_OP(5)    TYPE C,    "9 Codigo operacion
          NUMCK(8)     TYPE C,    "10 numero cheque
          MONTO(17)    TYPE C,                              "11 Monto
          DESCP(40)    TYPE C,    "12  Info 1 (va la descripción de la operacion )
          FEC_CONT(8)  TYPE C,    "14 Fecha contabilizacion
          filler2(1)   type C,      "15 no usado
          filler3(1)   type C,      "16 no usado
          NOT_PAY02(40) type c,   "17  note to payee 2 "sucursal
          NOT_PAY03(40)   type c,    "18 note to payee 3
          NOT_PAY04(40)   type c,    "19 nota to payee 4
          NOT_PAY05(40)   type c,    "20 nota to payee 5
          NOT_PAY06(40)   type c,    "21 nota to payee 7
          NOT_PAY07(40)   type c,    "22 nota to payee 8
          NOT_PAY08(40)   type c,    "23 nota to payee 9
          NOT_PAY09(40)   type c,    "24 nota to payee 10
          NOT_PAY010(40)   type c,   "25 nota to payee 11
          NOT_PAY011(40)   type c,   "26 nota to payee 12
          NOT_PAY012(40)   type c,   "27 nota to payee 6
*          TP_OP(1)     TYPE C, "Tipo de operación.
*          sucursal(27) type c, "sucursal
       END OF TY_STNDD,


    BEGIN OF TY_BCIC,
               COD_BANK(3)  TYPE C, "Clave de Banco
               CTBKN(10)    TYPE C, "Cuenta Bancaria
               FOL_CAR(4)   TYPE C, "Número de Extracto
               FEC_CONT(8)  TYPE C, "Fecha de Contabilización
               MONE(4)      TYPE C, "Moneda
               SALDO_I(14)  TYPE C, ""Saldo Inicial
               TO_CARG(18)  TYPE C, "Total Cargos
               TO_ABON(18)  TYPE C, "Total Abonos
               SALDO_F(14)  TYPE C, ""Saldo Final
    END OF TY_BCIC,

    BEGIN OF TY_BCID,
               COD_BANK(3)  TYPE C, "Clave de Banco.
               CTBKN(10)    TYPE C, "Cuenta Bancaria.
               FOL_CAR(4)   TYPE C, "Número de Extracto.
               NOPRA(5)     TYPE C, "Número de operacion.
               DESCP(50)    TYPE C, "Descripción.
               TP_OP(1)     TYPE C, "Tipo de operación.
               NUMCK(10)    TYPE C, "Número de Cheque.
               MONTO(14)    TYPE C, "Monto
               FEC_OP(8)    TYPE C, "Fecha de operación.
      END OF TY_BCID.


****************Definición de Metodos*******************************************
    METHODS: M_GET_DATA      IMPORTING VALUE(WI_FILE)      TYPE FILENAME
                                       VALUE(WI_TIPO)      TYPE P,

             M_PROCESA_BCI   IMPORTING VALUE(WI_BNCO)      TYPE TY_BANCO
                             EXPORTING VALUE(ITO_C)        TYPE ITO_C
                                       VALUE(ITO_D)        TYPE ITO_D,

             M_PROCESA_STNDR IMPORTING VALUE(WI_BNCO)      TYPE TY_BANCO
                             EXPORTING VALUE(ITO_C)        TYPE ITO_C
                                       VALUE(ITO_D)        TYPE ITO_D,

*             M_PROCESA_CHL   IMPORTING VALUE(WI_BNCO)      TYPE TY_BANCO
*                             EXPORTING VALUE(ITO_C)        TYPE ITO_C
*                                       VALUE(ITO_D)        TYPE ITO_D,

             M_DWN_FILE      IMPORTING VALUE(ITI_C)        TYPE ITO_C
                                       VALUE(ITI_D)        TYPE ITO_D
                             EXPORTING VALUE(W_FLAG1)      TYPE C,
             M_FIND_FILE     EXPORTING VALUE(P_FILE1)      TYPE FILENAME,

             M_VALIDA_BCO    EXPORTING VALUE(WI_BNCO)      TYPE TY_BANCO.

********************************************************************************

  PRIVATE SECTION.
    DATA CONT TYPE I.



ENDCLASS.                    "C_CONTADOR DEFINITION
*----------------------------------------------------------------------*
*       CLASS Multicash
*----------------------------------------------------------------------*
CLASS MULTICASH IMPLEMENTATION.
  METHOD M_GET_DATA.

    DATA: L_FILENAME TYPE STRING.
    L_FILENAME  = P_FILE.

    CALL METHOD CL_GUI_FRONTEND_SERVICES=>GUI_UPLOAD
       EXPORTING
         FILENAME                =  L_FILENAME
         FILETYPE                = 'ASC'
*        has_field_separator     =
*        header_length           = 0
*        read_by_line            = 'x'
*        dat_mode                = space
*        codepage                = space
*        ignore_cerr             = abap_true
*        replacement             = '#'
*        virus_scan_profile      =
*      IMPORTING
*        filelength              =
*        header                  =
       CHANGING
         DATA_TAB                = IT_DATA
       EXCEPTIONS
         FILE_OPEN_ERROR         = 1
         FILE_READ_ERROR         = 2
         NO_BATCH                = 3
         GUI_REFUSE_FILETRANSFER = 4
         INVALID_TYPE            = 5
         NO_AUTHORITY            = 6
         UNKNOWN_ERROR           = 7
         BAD_DATA_FORMAT         = 8
         HEADER_NOT_ALLOWED      = 9
         SEPARATOR_NOT_ALLOWED   = 10
         HEADER_TOO_LONG         = 11
         UNKNOWN_DP_ERROR        = 12
         ACCESS_DENIED           = 13
         DP_OUT_OF_MEMORY        = 14
         DISK_FULL               = 15
         DP_TIMEOUT              = 16
         NOT_SUPPORTED_BY_GUI    = 17
         ERROR_NO_GUI            = 18
         OTHERS                  = 19.
    IF SY-SUBRC <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*            WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
    ENDIF.

* ahora se transforma la linea de texto plana a el formato
* del banco BCI


  ENDMETHOD.    "RESCATA DATOS DEL ARCHIVO PLANO.
*  METHOD M_PROCESA_CHL.
*
*
*    ENDMETHOD.
  METHOD M_VALIDA_BCO.

    DATA: W_HBKID TYPE  HBKID.
    data: w_bankl_ant type t012-bankl.
*Begin of change: ReSQ Correction INDEX READ on an unsorted Internal TABLE 19/12/2019 EY_DES03 ECDK917080 *
SORT IT_DATA .
*End of change: ReSQ Correction for INDEX READ on an unsorted Internal TABLE 19/12/2019 EY_DES03 ECDK917080 *
    READ TABLE IT_DATA INDEX 1 INTO WA_DATA.


* BEGIN. 07-07-2026 - ATC - ATC-03
* OLD CODE
*    SELECT  BANKL
*    INTO   w_BANKL
*     FROM T012
*       WHERE
*       bukrs = p_bukrs and
*       HBKID in s_HBKID .  
*
* NEW CODE
    SELECT BANKL

    INTO   w_BANKL
     FROM T012
       WHERE
       bukrs = p_bukrs and
       HBKID in s_HBKID  ORDER BY PRIMARY KEY.  

* END. 07-07-2026 - ATC - ATC-03" Banmedica WA_DATA+52(3).
      if not w_bankl_ant is initial and w_bankl_ant ne w_bankl.

        MESSAGE I398(00) with text-003.
        LEAVE to TRANSACTION 'ZCBAN'.
      endif.
      move w_bankl to w_bankl_ant.
    endselect.
    if sy-subrc ne 0.
      MESSAGE I398(00) with text-004.
      LEAVE to TRANSACTION 'ZCBAN'.
    else.
      move w_bankl to WI_BNCO.

    endif.






  ENDMETHOD.                    "M_VALIDA_BCO
  METHOD M_PROCESA_STNDR.
    types: begin of s_bankn ,
           w_bankn type t012k-bankn,
           end of s_bankn.
    data: w_bankn type s_bankn-w_bankn.
    data: t_bankn type table of s_bankn.
    DATA: WA_DET         TYPE TY_STNDD.
    DATA: WA_HEADER      TYPE TY_STNDC,
          W_LINES(6)     TYPE  C,   "Banmedica se cambio de 2 a 5
          W_CARG(18)     TYPE C,"Total Cargos
          W_ABON(18)     TYPE C,"Total Abonos
          AUX1(18)       TYPE C,
          AUX2(18)       TYPE C,
          W_SALDOF(18)   TYPE C,
          W_CTBKN(12)    TYPE C,
          W_COD_BANK(3)  TYPE C,
          W_NUM_CTLA(5)  TYPE C,
          W_AGNO(4)      TYPE C,
          W_WAERS(5)     TYPE C ,
          w_incta(35)    type c.  " nombre de la cuenta corriente



* BEGIN. 07-07-2026 - ATC - ATC-03
* OLD CODE
*    select bankn into table t_bankn from t012k
*           where BUKRS = p_bukrs and
*                 HBKID in s_hbkid and
*                 HKTID in s_hktid.
*
* NEW CODE
    SELECT bankn
 into table t_bankn from t012k
           where BUKRS = p_bukrs and
                 HBKID in s_hbkid and
                 HKTID in s_hktid ORDER BY PRIMARY KEY.

* END. 07-07-2026 - ATC - ATC-03
    loop at it_data INTO WA_DATA.
      read table t_bankn with  key w_bankn+0(12) = WA_DATA+2(12) into  w_bankn.
      if sy-subrc ne 0.
        delete it_data . " to wa_data .
      endif.
    endloop.



    CLEAR WA_DATA.
* el formato del banco SANTANDER se compone de tres tipos de registros
* formato de cabecera(tipo 1 ) , detalle ( tipo 2 )  y resumen ( tipo 3 ) .

    loop at it_data INTO WA_DATA.
      if WA_DATA+0(1) = '1'.  "Registro de cabecera


        W_CTBKN    = WA_DATA+2(12). "cuenta corriente
        W_COD_BANK = w_BANKL+0(3). "banmedicaWA_DATA+52(3).
        W_NUM_CTLA = WA_DATA+72(5). "numero de cartola
        W_AGNO     = WA_DATA+68(4). "año de emisión de la cartola
        w_incta    = wa_data+24(35). "nombre de la cuenta corriente
*para el registro de cabecera , tengo en el registro 1 el saldo inicial ( o anterior )
        WA_HEADER-FEC_CONT  = WA_DATA+64(8).   "Fecha de Contabilización

        CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
          EXPORTING
            INPUT  = WA_DATA+86(16)
          IMPORTING
            OUTPUT = WA_DATA+86(16).

        CONCATENATE WA_DATA+85(1) WA_DATA+86(16) INTO WA_HEADER-SAL_INI. "Saldo Inicial
        CONDENSE WA_HEADER-SAL_INI NO-GAPS.
      endif.


* LEEMOS EL DETALLE REGISTRO 2
      if WA_DATA+0(1) = '2'.  "Registro de detalle
        CLEAR WA_DET.
        WA_DET-COD_BANK   = W_COD_BANK.   "Clave de Banco.
        WA_DET-CTBKN      = W_CTBKN.      "Cuenta Bancaria.
        WA_DET-NUM_CTLA   = W_NUM_CTLA.   "Número de Extracto.
        wa_det-bank_postext = WA_DATA+127(5) ."codigo de la operacion.
        clear  WA_DET-COD_OP.              "= WA_DATA+127(5). "Número de operacion.

        CLEAR W_TR001.
        move WA_DATA+56(40)  to W_TR001.    "descripcion del movimeinto contable
        clear: wa_det-not_pay01,wa_det-not_pay02,wa_det-not_pay03.

        WA_DET-not_pay03    = W_TR001.       "Descripción. leer de la tabla xxx



        IF WA_DATA+32(8) = 0.   "Número de Cheque o deposito u otro tipo de documento.
          WA_DET-NUMCK = W_SLASH.
        ELSE.
          WA_DET-NUMCK    = WA_DATA+32(8). "Número de Cheque o deposito u otro tipo de documento.
          wa_det-NOT_PAY01 = WA_DATA+32(8). "Número de Cheque o deposito u otro tipo de documento
        ENDIF.

        IF WA_DATA+40(1) = '+'.  "abono

          CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
            EXPORTING
              INPUT  = WA_DATA+41(15)
            IMPORTING
              OUTPUT = WA_DATA+41(15).
          CONCATENATE W_MAS WA_DATA+41(15) INTO WA_DET-MONTO. "ABONO


        ELSEIF WA_DATA+40(1) = '-'.  "cargo

          CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
            EXPORTING
              INPUT  = WA_DATA+41(15)
            IMPORTING
              OUTPUT = WA_DATA+41(15).
          CONCATENATE W_MENOS WA_DATA+41(15) INTO WA_DET-MONTO. "Monto CARGO


        ENDIF.
* movemos el campo sucursal
        move WA_DATA+124(3) to wa_det-NOT_PAY02.  "sucursal

        WA_DET-FEC_CONT = WA_DATA+24(4). "Fecha de operación.
        CONCATENATE WA_DET-FEC_CONT+0(2) '.'
                    WA_DET-FEC_CONT+2(2) '.'
                    W_AGNO+2(2)
            INTO    WA_DET-FEC_CONT.
        move WA_DET-FEC_CONT to WA_DET-FEC_val.





        CONCATENATE WA_DET-COD_BANK
                    WA_DET-CTBKN
                    WA_DET-NUM_CTLA
                    WA_DET-FEC_val
                    wa_det-PRNOT_num  "va vacio
                    wa_det-NOT_PAY01  "sucursal
                    wa_det-bank_postext " codigo de la operacion
                    wa_det-filler1      " no usado
*                    W_PCOMA
                    WA_DET-COD_OP
*                    WA_DET-TP_OP
                    WA_DET-NUMCK
                    WA_DET-MONTO
                    WA_DET-filler1    "no se usa
                    wa_det-filler2    "no se usa
                    WA_DET-FEC_CONT
                    wa_det-filler2
                    wa_det-filler3
                    wa_det-NOT_PAY02  "cheque
                    wa_det-not_pay03  "fecha del movimiento
*                   WA_DET-COD_OP
*                   wa_det-sucursal
            INTO WA_D
        SEPARATED BY ';'.
        APPEND WA_D TO ITO_D.

      ENDIF.

*CABECERA
      if WA_DATA+0(1) = '3'.  " Completar registro de cabecera



        WA_HEADER-COD_BANK  = W_COD_BANK. "banmedicaWA_DATA+52(3)..    "Clave de Banco
        WA_HEADER-CTBKN     = W_CTBKN .   "Cuenta Bancaria
        WA_HEADER-NUM_CTLA  = W_NUM_CTLA.   "Número de Extracto
        wa_header-IN_CTA    = w_incta.  "nombre de cuenta corriente
        CONCATENATE WA_HEADER-FEC_CONT+0(2) '.'
                    WA_HEADER-FEC_CONT+2(2) '.'
                    WA_HEADER-FEC_CONT+6(2)
              INTO  WA_HEADER-FEC_CONT.

* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*        SELECT SINGLE WAERS
*          INTO W_WAERS
*          FROM T012K
*          WHERE BANKN = WA_HEADER-CTBKN.
*
* NEW CODE
        SELECT WAERS
        UP TO 1 ROWS 
          INTO W_WAERS
          FROM T012K
          WHERE BANKN = WA_HEADER-CTBKN ORDER BY PRIMARY KEY.

        ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
        WA_HEADER-MONEDA = W_WAERS.

        move wa_data+115(15) to w_carg.
        CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
          EXPORTING
            INPUT  = W_CARG+0(17)
          IMPORTING
            OUTPUT = W_CARG+0(17).

        CONCATENATE W_MENOS W_CARG+0(17) INTO WA_HEADER-TOT_C.
        CONDENSE WA_HEADER-TOT_C NO-GAPS.
        move wa_data+100(15) to w_abon.
        CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
          EXPORTING
            INPUT  = W_ABON
          IMPORTING
            OUTPUT = W_ABON.

        CONCATENATE W_MAS W_ABON   INTO WA_HEADER-TOT_A.
        CONDENSE WA_HEADER-TOT_A NO-GAPS.


        w_saldof = wa_data+25(15).
        if wa_data+24(1) = '+'.


          CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
            EXPORTING
              INPUT  = W_SALDOF
            IMPORTING
              OUTPUT = W_SALDOF.

          CONCATENATE W_MAS W_SALDOF INTO WA_HEADER-SAL_FIN.
          CONDENSE WA_HEADER-SAL_FIN NO-GAPS.

        ELSE.
          CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
            EXPORTING
              INPUT  = W_SALDOF
            IMPORTING
              OUTPUT = W_SALDOF.

          CONCATENATE W_MENOS W_SALDOF INTO WA_HEADER-SAL_FIN.
          CONDENSE WA_HEADER-SAL_FIN NO-GAPS.

        ENDIF.
* total movimientos

        move wa_data+130(6) to  w_lines.

        CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
          EXPORTING
            INPUT  = W_LINES
          IMPORTING
            OUTPUT = W_LINES.
        CONCATENATE WA_HEADER-COD_BANK
                    WA_HEADER-CTBKN
                    WA_HEADER-NUM_CTLA
                    WA_HEADER-FEC_CONT
                    WA_HEADER-MONEDA
                    WA_HEADER-SAL_INI
                    WA_HEADER-TOT_C
                    WA_HEADER-TOT_A
                    WA_HEADER-SAL_FIN
                    WA_HEADER-IN_CTA
                    WA_HEADER-XP_CTA
                    W_PCOMA
                    W_PCOMA
                    W_PCOMA
*                    W_PCOMA
*                    W_PCOMA
                    W_LINES
               INTO WA_C
               SEPARATED BY ';'.
        APPEND WA_C TO ITO_C.
        CLEAR WA_HEADER. "limpiamos .
      endif.
    endloop. "porque hay varias cuentas corrientes.
  ENDMETHOD.                    "M_PROCESA_STNDR
  METHOD M_PROCESA_BCI.
    DATA: WA_DET       TYPE TY_BCID.
    DATA: WA_HEADER    TYPE TY_BCIC,
          W_LINES(2)   TYPE  C,
          W_CARG(14)   TYPE C,"Total Cargos
          W_ABON(14)   TYPE C,"Total Abonos
          AUX1(14)     TYPE C,
          AUX2(14)     TYPE C,
          W_SALDOF(14) TYPE C.

    DESCRIBE TABLE IT_DATA LINES W_LINES.

    W_LINES = W_LINES - 1.

    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
      EXPORTING
        INPUT  = W_LINES
      IMPORTING
        OUTPUT = W_LINES.

    LOOP AT IT_DATA INTO WA_DATA.
*DETALLE
      IF SY-TABIX = 1.
        CONTINUE.
      ELSE.
        CLEAR WA_DET.
        WA_DET-COD_BANK = WA_DATA+0(3).  "Clave de Banco.
        WA_DET-CTBKN    = WA_DATA+3(10). "Cuenta Bancaria.
        WA_DET-FOL_CAR  = WA_DATA+21(4). "Número de Extracto.
        WA_DET-NOPRA    = WA_DATA+40(5). "Número de operacion.

        CLEAR W_TR001.
        move 'Banco de credito e Inversiones' to w_tr001.


        WA_DET-DESCP    = W_TR001.       "Descripción. leer de la tabla xxx
*      WA_DET-TP_OP    = WA_DATA+45(1). "Tipo de operación.
        WA_DET-TP_OP    = W_PCOMA. "Tipo de operación.

        IF WA_DATA+25(7) = 0.
          WA_DET-NUMCK = W_SLASH.
        ELSE.
          WA_DET-NUMCK    = WA_DATA+25(7). "Número de Cheque.
        ENDIF.
        IF WA_DATA+46(14) = 0.

          CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
            EXPORTING
              INPUT  = WA_DATA+60(14)
            IMPORTING
              OUTPUT = WA_DATA+60(14).
          CONCATENATE W_MAS WA_DATA+60(14) INTO WA_DET-MONTO. "ABONO
        ELSE.

          CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
            EXPORTING
              INPUT  = WA_DATA+46(14)
            IMPORTING
              OUTPUT = WA_DATA+46(14).
          CONCATENATE W_MENOS WA_DATA+46(14) INTO WA_DET-MONTO. "Monto CARGO
        ENDIF.
        WA_DET-FEC_OP     = WA_DATA+32(8). "Fecha de operación.
        CONCATENATE WA_DET-FEC_OP+6(2) '.'
                    WA_DET-FEC_OP+4(2) '.'
                    WA_DET-FEC_OP+2(2)
            INTO    WA_DET-FEC_OP.


        CONCATENATE WA_DET-COD_BANK
                    WA_DET-CTBKN
                    WA_DET-FOL_CAR
                    WA_DET-FEC_OP
                    W_PCOMA
                    WA_DET-NOPRA
                    WA_DET-TP_OP
                    WA_DET-NUMCK
                    WA_DET-MONTO
                    W_PCOMA
                    WA_DET-FEC_OP
                    WA_DET-DESCP
                    WA_DET-NOPRA
            INTO WA_D
        SEPARATED BY ';'.
        APPEND WA_D TO ITO_D.

        AUX1 = WA_DATA+46(14).
        AUX2 = WA_DATA+60(14).
        CONDENSE AUX1 NO-GAPS.
        CONDENSE AUX2 NO-GAPS.
        W_CARG = W_CARG + AUX1.
        W_ABON = W_ABON + AUX2.
      ENDIF.
    ENDLOOP.
*CABECERA
    CLEAR WA_HEADER.
*ReSQ: No Need Of Change Internal Table IT_DATA Already Sorted
    READ TABLE IT_DATA INDEX 1 INTO WA_DATA.

    WA_HEADER-COD_BANK = WA_DATA+0(3).    "Clave de Banco
    WA_HEADER-CTBKN    = WA_DATA+3(10).   "Cuenta Bancaria
    WA_HEADER-FOL_CAR  = WA_DATA+21(4).   "Número de Extracto
    WA_HEADER-FEC_CONT = WA_DATA+32(8).   "Fecha de Contabilización
    CONCATENATE WA_HEADER-FEC_CONT+6(2) '.'
                WA_HEADER-FEC_CONT+4(2) '.'
                WA_HEADER-FEC_CONT+2(2)
          INTO  WA_HEADER-FEC_CONT.
    WA_HEADER-MONE = 'CLP'.
*        WA_HEADER-SALDO_I  = WA_DATA+74(14).  "Saldo Inicial

    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
      EXPORTING
        INPUT  = WA_DATA+74(13)
      IMPORTING
        OUTPUT = WA_DATA+74(13).

    CONCATENATE WA_DATA+87(1) WA_DATA+74(13) INTO WA_HEADER-SALDO_I. "Saldo Inicial
    CONDENSE WA_HEADER-SALDO_I NO-GAPS.

    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
      EXPORTING
        INPUT  = W_CARG
      IMPORTING
        OUTPUT = W_CARG.

    CONCATENATE W_MENOS W_CARG INTO WA_HEADER-TO_CARG.
    CONDENSE WA_HEADER-TO_CARG NO-GAPS.

    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
      EXPORTING
        INPUT  = W_ABON
      IMPORTING
        OUTPUT = W_ABON.

    CONCATENATE W_MAS W_ABON   INTO WA_HEADER-TO_ABON.
    CONDENSE WA_HEADER-TO_ABON NO-GAPS.

    W_SALDOF = WA_HEADER-TO_CARG + WA_HEADER-TO_ABON + WA_HEADER-SALDO_I.  "Saldo Final

    IF W_SALDOF GE 1.
      CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
        EXPORTING
          INPUT  = W_SALDOF
        IMPORTING
          OUTPUT = W_SALDOF.

      CONCATENATE W_MAS W_SALDOF INTO WA_HEADER-SALDO_F.
      CONDENSE WA_HEADER-SALDO_F NO-GAPS.

    ELSE.
      CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
        EXPORTING
          INPUT  = W_SALDOF
        IMPORTING
          OUTPUT = W_SALDOF.

      CONCATENATE W_MENOS W_SALDOF INTO WA_HEADER-SALDO_F.
      CONDENSE WA_HEADER-SALDO_F NO-GAPS.

    ENDIF.

    CONCATENATE WA_HEADER-COD_BANK
                WA_HEADER-CTBKN
                WA_HEADER-FOL_CAR
                WA_HEADER-FEC_CONT
                WA_HEADER-MONE
                WA_HEADER-SALDO_I
                WA_HEADER-TO_CARG
                WA_HEADER-TO_ABON
                WA_HEADER-SALDO_F
                W_PCOMA
                W_LINES
           INTO WA_C
           SEPARATED BY ';'.
    APPEND WA_C TO ITO_C.



  ENDMETHOD.                    "incrementar_contador
  METHOD M_DWN_FILE.
    DATA V_FILENAME TYPE STRING.

    CLEAR V_FILENAME.
    V_FILENAME = P_FILE2.

    CALL METHOD CL_GUI_FRONTEND_SERVICES=>GUI_DOWNLOAD
      EXPORTING
*     bin_filesize              =
        FILENAME                  = V_FILENAME
        FILETYPE                  = 'ASC'
*     append                    = space
     WRITE_FIELD_SEPARATOR     = ';'
*     header                    = '00'
*        TRUNC_TRAILING_BLANKS     = 'X'
*     write_lf                  = 'x'
*     col_select                = space
*     col_select_mask           = space
*     dat_mode                  = space
*     confirm_overwrite         = space
      no_auth_check             = 'X'      " space
*     codepage                  = space
      ignore_cerr               = abap_true
*     replacement               = '#'
*     write_bom                 = space
*     trunc_trailing_blanks_eol = 'x'
*     wk1_n_format              = space
*     wk1_n_size                = space
*     wk1_t_format              = space
*     wk1_t_size                = space
*   IMPORTING
*     filelength                =
      CHANGING
        DATA_TAB                  = ITI_C
      EXCEPTIONS
        FILE_WRITE_ERROR          = 1
        NO_BATCH                  = 2
        GUI_REFUSE_FILETRANSFER   = 3
        INVALID_TYPE              = 4
        NO_AUTHORITY              = 5
        UNKNOWN_ERROR             = 6
        HEADER_NOT_ALLOWED        = 7
        SEPARATOR_NOT_ALLOWED     = 8
        FILESIZE_NOT_ALLOWED      = 9
        HEADER_TOO_LONG           = 10
        DP_ERROR_CREATE           = 11
        DP_ERROR_SEND             = 12
        DP_ERROR_WRITE            = 13
        UNKNOWN_DP_ERROR          = 14
        ACCESS_DENIED             = 15
        DP_OUT_OF_MEMORY          = 16
        DISK_FULL                 = 17
        DP_TIMEOUT                = 18
        FILE_NOT_FOUND            = 19
        DATAPROVIDER_EXCEPTION    = 20
        CONTROL_FLUSH_ERROR       = 21
        NOT_SUPPORTED_BY_GUI      = 22
        ERROR_NO_GUI              = 23
        OTHERS                    = 24.
    IF SY-SUBRC <> 0.
       MESSAGE ID '00' TYPE 'I' NUMBER '398' WITH TEXT-M02.
      leave to CURRENT transaction.
    ENDIF.
*
    CLEAR V_FILENAME.
    V_FILENAME = P_FILE3.
*
    CALL METHOD CL_GUI_FRONTEND_SERVICES=>GUI_DOWNLOAD
      EXPORTING
*     bin_filesize              =
        FILENAME                  = V_FILENAME
        FILETYPE                  = 'ASC'
*        APPEND                    = ';'
        WRITE_FIELD_SEPARATOR     = ';'
*     header                    = '00'
*     trunc_trailing_blanks     = space
*     write_lf                  = 'x'
*     col_select                = space
     COL_SELECT_MASK           = ';'
*     dat_mode                  = space
*     confirm_overwrite         = space
*     no_auth_check             = space
*     codepage                  = space
*     ignore_cerr               = abap_true
*     replacement               = '#'
*     write_bom                 = space
*     trunc_trailing_blanks_eol = 'x'
*     wk1_n_format              = space
*     wk1_n_size                = space
*     wk1_t_format              = space
*     wk1_t_size                = space
*   IMPORTING
*     filelength                =
      CHANGING
        DATA_TAB                  = ITI_D
      EXCEPTIONS
        FILE_WRITE_ERROR          = 1
        NO_BATCH                  = 2
        GUI_REFUSE_FILETRANSFER   = 3
        INVALID_TYPE              = 4
        NO_AUTHORITY              = 5
        UNKNOWN_ERROR             = 6
        HEADER_NOT_ALLOWED        = 7
        SEPARATOR_NOT_ALLOWED     = 8
        FILESIZE_NOT_ALLOWED      = 9
        HEADER_TOO_LONG           = 10
        DP_ERROR_CREATE           = 11
        DP_ERROR_SEND             = 12
        DP_ERROR_WRITE            = 13
        UNKNOWN_DP_ERROR          = 14
        ACCESS_DENIED             = 15
        DP_OUT_OF_MEMORY          = 16
        DISK_FULL                 = 17
        DP_TIMEOUT                = 18
        FILE_NOT_FOUND            = 19
        DATAPROVIDER_EXCEPTION    = 20
        CONTROL_FLUSH_ERROR       = 21
        NOT_SUPPORTED_BY_GUI      = 22
        ERROR_NO_GUI              = 23
        OTHERS                    = 24.
    IF SY-SUBRC <> 0.
      MESSAGE ID '00' TYPE 'I' NUMBER '398' WITH TEXT-M02.
      leave to CURRENT transaction.
    ELSE.
      MESSAGE ID '00' TYPE 'S' NUMBER '398' WITH TEXT-M01.
    ENDIF.

  ENDMETHOD.                    "M_DWN_FILE
  METHOD M_FIND_FILE.
* * variables auxiliares
    DATA V_RC TYPE I.
    DATA ITAB_FILES TYPE TABLE OF FILE_TABLE.
    DATA WA_FILES TYPE FILE_TABLE.
    DATA V_TITLE TYPE STRING.

    CLEAR V_TITLE.
    V_TITLE = TEXT-T01.

    CALL METHOD CL_GUI_FRONTEND_SERVICES=>FILE_OPEN_DIALOG
      EXPORTING
        WINDOW_TITLE          = V_TITLE
     DEFAULT_EXTENSION        = 'TXT'
     DEFAULT_FILENAME         = '.txt'
*     file_filter             =
*     with_encoding           =
     INITIAL_DIRECTORY        = 'C:\'
*     multiselection          =
      CHANGING
        FILE_TABLE            = ITAB_FILES
        RC                    = V_RC
*     user_action             =
*     file_encoding           =
      EXCEPTIONS
        FILE_OPEN_DIALOG_FAILED = 1
        CNTL_ERROR              = 2
        ERROR_NO_GUI            = 3
        NOT_SUPPORTED_BY_GUI    = 4
        OTHERS                  = 5.
    IF SY-SUBRC <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*            WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
    ELSE.
*Begin of change: ReSQ Correction INDEX READ on an unsorted Internal TABLE 19/12/2019 EY_DES03 ECDK917080 *
SORT ITAB_FILES .
*End of change: ReSQ Correction for INDEX READ on an unsorted Internal TABLE 19/12/2019 EY_DES03 ECDK917080 *
      READ TABLE ITAB_FILES INTO WA_FILES INDEX 1.
      P_FILE1 = WA_FILES.
*      P_FILE2 = P_FILE1.
    ENDIF.
  ENDMETHOD.                    "M_find_file

ENDCLASS.                    "c_contador IMPLEMENTATION
