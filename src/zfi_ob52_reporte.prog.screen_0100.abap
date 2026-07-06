PROCESS BEFORE OUTPUT.
  MODULE status_0100.
*
  MODULE tc_t001b_change_tc_attr.
  LOOP AT   gt_t001b
       INTO wa_t001b
       WITH CONTROL tc_t001b
       CURSOR tc_t001b-current_line.
    MODULE tc_t001b_change_field_attr.
  ENDLOOP.
*
  MODULE tc_zt001b_change_tc_attr.
  LOOP AT   gt_zt001b
       INTO wa_zt001b
       WITH CONTROL tc_zt001b
       CURSOR tc_zt001b-current_line.
    MODULE tc_zt001b_change_field_attr.
  ENDLOOP.
*
PROCESS AFTER INPUT.

  LOOP AT gt_t001b.
    CHAIN.
      FIELD wa_t001b-mkoar.
      FIELD wa_t001b-bkont.
      FIELD wa_t001b-vkont.
      FIELD wa_t001b-frye1.
      FIELD wa_t001b-frpe1.
      FIELD wa_t001b-toye1.
      FIELD wa_t001b-tope1.
      FIELD wa_t001b-frye2.
      FIELD wa_t001b-frpe2.
      FIELD wa_t001b-toye2.
      FIELD wa_t001b-tope2.
      FIELD wa_t001b-brgru.
    ENDCHAIN.
  ENDLOOP.
*
  LOOP AT gt_zt001b.
    CHAIN.
      FIELD wa_zt001b-mkoar.
      FIELD wa_zt001b-frye1.
      FIELD wa_zt001b-frpe1.
      FIELD wa_zt001b-frye2.
      FIELD wa_zt001b-frpe2.
*      FIELD WA_ZT001B-BRGRU.
    ENDCHAIN.
  ENDLOOP.
*
  MODULE user_command_0100.
