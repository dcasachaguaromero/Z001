*&---------------------------------------------------------------------*
*&  Include           ZXAPCU05
*&---------------------------------------------------------------------*
*"       IMPORTING
*"             VALUE(I_ANTS) LIKE  ANTS STRUCTURE  ANTS
*"             VALUE(I_RLAMBU) LIKE  RLAMBU STRUCTURE  RLAMBU
*"       TABLES
*"              T_ANEPI STRUCTURE  ANEPI
*"              M_ANEPI STRUCTURE  ANEPI
*&---------------------------------------------------------------------*
  DATA: t_bseg     LIKE bseg OCCURS 10 WITH HEADER LINE,
        wa_indx    TYPE indx,
        l_anln2(4) TYPE n,
        l_bschl    TYPE bschl.

  TRY .

      IMPORT tab = t_bseg
        FROM DATABASE indx(xy)
        TO   wa_indx
        CLIENT sy-mandt
        ID 'TABLE'.

    CATCH cx_sy_import_mismatch_error.
      " Ignorar error por cambio de estructura BSEG
  ENDTRY.


  SELECT SINGLE bschl INTO l_bschl
    FROM zfiam001
    WHERE bukrs = i_ants-bukrs  AND
          bwasl = i_rlambu-bwasl.

  CHECK sy-subrc = 0.

  LOOP AT t_bseg.
    l_anln2 = t_bseg-anln2.
    IF t_bseg-bschl = l_bschl.
      LOOP AT t_anepi WHERE afabe = '05'         AND
                            anln1 = t_bseg-anln1 AND
                            anln2 = l_anln2.
        m_anepi       = t_anepi.
        IF t_bseg-shkzg = 'S'.
          m_anepi-anbtr = t_bseg-dmbtr.
        ELSE.
          m_anepi-anbtr = 0 - t_bseg-dmbtr.
        ENDIF.
        APPEND m_anepi.
      ENDLOOP.
    ENDIF.
  ENDLOOP.

**********************************************************************
* INICIO DESARROLLO                                                  *
* Desarrollado por: Crewvalue                                        *
* Observación: Esta rutina llena el area 5 del activo fijo           *
**********************************************************************
  BREAK cv_user2.
*{   INSERT         ECPK900254                                        1

  TYPES: BEGIN OF ty_info,
           gjahr TYPE gjahr,  " año
           buzei TYPE rblgp, " posicion

           ebeln TYPE ebeln,  " Pedido
           ebelp TYPE ebelp,  " Posición de pedido.

           anln1 TYPE anln1, " Código Activo
           anln2 TYPE anln2,

           wrbtr TYPE wrbtr,  " monto (Neto).
           mwskz TYPE mwskz,  " Indicador de Impuesto.
         END OF ty_info.

  DATA: it_info TYPE TABLE OF ty_info.
  DATA: wa_info TYPE ty_info.
*  DATA: it_info2 TYPE TABLE OF ty_info.
*  DATA: wa_info2 TYPE ty_info.
  DATA: it_bseg  LIKE bseg OCCURS 10 WITH HEADER LINE.

*  IMPORT it_info2 = it_info2 FROM MEMORY ID 'CREWVALUE2'.
  IMPORT it_info = it_info FROM MEMORY ID 'CREWVALUE'.
  IMPORT it_bseg = it_bseg FROM MEMORY ID 'CREWVALUEBSEG'.
* Sólo trx permitidas.

* Transacciones de FI
  IF i_rlambu-tcode = 'FBR2' OR i_rlambu-tcode = 'FB01' OR i_rlambu-tcode = 'F-90' OR
     sy-tcode = 'FBR2' OR sy-tcode = 'FB01' OR sy-tcode = 'F-90'.
    DATA: lit_set_lines_basic TYPE TABLE OF rgsbv,
          lwa_set_lines_basic TYPE rgsbv.

    READ TABLE it_bseg WITH KEY anln1 = i_rlambu-anln1. " Buscamos material Activo
    IF sy-subrc EQ 0.  " Es el material

      READ TABLE it_bseg WITH KEY bschl = '70'
                                  mwskz = 'C6'.
      IF sy-subrc = 0.
        READ TABLE t_anepi WITH KEY afabe = '05'.
        IF sy-subrc EQ 0.
          MOVE-CORRESPONDING t_anepi TO m_anepi.
          m_anepi-anbtr = it_bseg-wrbtr.
          APPEND m_anepi.
        ENDIF.
      ENDIF.
    ENDIF.

* Transacción de Verificación Factura Logistica
  ELSEIF i_rlambu-tcode = 'MIRO' OR sy-tcode = 'MIRO'.

* Verifica que sociedad este en el SET AF_BUKRS
    CALL FUNCTION 'G_SET_FETCH'
      EXPORTING
        setnr           = '0000AF_BUKRS'
      TABLES
        set_lines_basic = lit_set_lines_basic
      EXCEPTIONS
        no_authority    = 1
        set_is_broken   = 2
        set_not_found   = 3
        OTHERS          = 4.

    IF sy-subrc EQ 0.
      READ TABLE lit_set_lines_basic INTO lwa_set_lines_basic WITH KEY to = i_rlambu-bukrs.

      IF sy-subrc EQ 0.
* Lee registro rescatado desde flujo logistico con export/import
* IMPORT it_info = it_info FROM MEMORY ID 'CREWVALUE'.
* Contiene datos de la posición del pedido
        READ TABLE it_info INTO wa_info WITH KEY anln1 = i_rlambu-anln1
                                                 anln2 = i_rlambu-anln2
                                                 ebeln = i_rlambu-ebeln "Se lee por OC
                                                 ebelp = i_rlambu-ebelp."Se lee por posicion de la OC
        IF sy-subrc = 0.

* V1 PGR: 30-10-2025.
* Agrega logica permite C9 en MIRO de Activos Fijos.
* Dejara todos los valores segun su configuración del TAXCL
* Área Financiera y Área Tributaria con Valor Neto de factura
* No generara mensaje de error
          IF wa_info-mwskz NE 'C9'.

* ini - Waldo Alarcón - Visionone - 29-07-2021
            IF i_rlambu-bukrs EQ 'CL12' AND i_rlambu-blart EQ 'B4' AND wa_info-mwskz EQ 'C0'.
* ----------------------- no envia mensaje.
            ELSE.
* fin - Waldo Alarcón - Visionone - 29-07-2021
*
              IF wa_info-mwskz = 'C6'
* ini - Waldo Alarcón - Visionone - 25-05-2020
                OR ( i_rlambu-blart EQ 'FC' AND wa_info-mwskz EQ 'C0' ).
* fin - Waldo Alarcón - Visionone - 25-05-2020
                " modificar el m_anepi área 05 Tributaria.
                READ TABLE t_anepi WITH KEY anln1 = i_rlambu-anln1
                                      anln2 = i_rlambu-anln2
                                      afabe = '05'.
                IF sy-subrc = 0.
                  MOVE-CORRESPONDING t_anepi TO m_anepi.
                  "PASA VALOR DE POSICIÓN DE PEDIDO = VALOR NETO
                  m_anepi-anbtr = wa_info-wrbtr.
                  APPEND m_anepi.
                ENDIF.

              ELSE.
                MESSAGE e001(zcrewvalue).
              ENDIF. "" VALIDA SI ES C6
*
            ENDIF. "VALIDA SOC 'CL12' Y DOC EQ 'B4' Y IVA EQ 'C0', SALTA

          ENDIF. " VALIDA SI ES C9 Y SALTA TODO

        ENDIF. "READ TABLE it_info

      ENDIF. " READ TABLE lit_set_lines_basic

    ENDIF. " SOCIEDAD EN SET AF_BUKRS

  ENDIF.  "VALIDA QUE TRANSACCIONES UTILIZA

*\**********************************************************************
*\* FIN DESARROLLO                                                     *
*\* Desarrollado por: Crewvalue                                        *
*\* Observación: Esta rutina llena el area 5 del activo fijo           *
*\**********************************************************************
** Borrar area de memoria
*DELETE FROM DATABASE indx(xy)
*  CLIENT sy-mandt
*  ID 'TABLE'.
