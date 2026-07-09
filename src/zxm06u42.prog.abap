*&---------------------------------------------------------------------*
*&  Include           ZXM06U42
*&---------------------------------------------------------------------*

*-------- ini - Waldo Alarcón - Visionone - 27-10-2021 -
* Verifica cambio en la dirección para reversar la estrategia de liberación
*
DATA : lw_addr1_val TYPE   addr1_val,
       lw_adrc      TYPE   addr1_val,
       lv_address   TYPE   addr1_sel,
       lv_adrnr     TYPE   adrnr.
*
IF sy-tcode EQ 'ME22' OR sy-tcode EQ 'ME22N' OR
   ( sy-tcode EQ 'ME23N' AND i_aktyp EQ 'V' ).

  lv_address-addrnumber = i_ekpo-adrnr.
  IF i_ekpo-adrnr IS INITIAL.
    lv_address-addrhandle = 'SADR 00001'.
  ENDIF.
  lv_address-date       = '00000000'.
* LEE EL VALOR INGRESADO.
  CALL FUNCTION 'ADDR_GET'
    EXPORTING
      address_selection = lv_address
    IMPORTING
      address_value     = lw_addr1_val
*     address_additional_info = ad1_flags
*     address_text      = addr1_text
*     TABLES
*     address_groups    = address_groups
    EXCEPTIONS
      parameter_error   = 01
      address_not_exist = 02
      version_not_exist = 03
      internal_error    = 04
      OTHERS            = 99.
*
  IF sy-subrc EQ 0 AND lw_addr1_val IS NOT INITIAL.
    IF i_ekpo_old-adrnr IS INITIAL.
* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*      SELECT SINGLE adrnr INTO lv_adrnr
*             FROM t001w WHERE werks EQ i_ekpo_old-werks.
*
* NEW CODE
      SELECT adrnr
      UP TO 1 ROWS  INTO lv_adrnr
             FROM t001w WHERE werks EQ i_ekpo_old-werks ORDER BY PRIMARY KEY.

      ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
    ELSE.
      lv_adrnr =  i_ekpo_old-adrnr.
    ENDIF.

* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
*    SELECT SINGLE * INTO CORRESPONDING FIELDS OF lw_adrc
*           FROM adrc WHERE addrnumber EQ lv_adrnr.
*
* NEW CODE
    SELECT *
    UP TO 1 ROWS  INTO CORRESPONDING FIELDS OF lw_adrc
           FROM adrc WHERE addrnumber EQ lv_adrnr ORDER BY PRIMARY KEY.

    ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
*
    IF lw_adrc-house_num1 NE lw_addr1_val-house_num1 OR "Número
       lw_adrc-street     NE lw_addr1_val-street     OR "calle Número
       lw_adrc-post_code1 NE lw_addr1_val-post_code1 OR "Codifo Postal
       lw_adrc-country    NE lw_addr1_val-country    OR "pais
       lw_adrc-region     NE lw_addr1_val-region     OR "región
       lw_adrc-city1      NE lw_addr1_val-city1      OR "Población
       lw_adrc-city2      NE lw_addr1_val-city2.        "Distrito
      PERFORM set_release_state IN PROGRAM saplmepo USING i_ekko-frggr
                                                          i_ekko-frgsx
                                                          '1' "i_ekko-frgke
                                                          ' ' "I_EKKO-frgzu
                                                          'X'. "i_ekko-frgrl.
      MESSAGE i685(06).
      mmpur_message 'I' '06  ' '685' '' '' '' ''.
    ENDIF.
  ENDIF.
ENDIF.
*-------- fin - Waldo Alarcón - Visionone - 27-10-2021 -
