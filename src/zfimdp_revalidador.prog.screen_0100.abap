
PROCESS BEFORE OUTPUT.
  MODULE inicializa.
  MODULE tc_revalida_change_tc_attr.
  LOOP AT   t_data
       WITH CONTROL tc_revalida
       CURSOR tc_revalida-current_line.
    MODULE tc_revalida_get_lines.
  ENDLOOP.

  MODULE status_0100.
  CALL SUBSCREEN: a_sub0101 INCLUDING sy-repid '0101',
                  a_sub0102 INCLUDING sy-repid '0102',
                  a_sub0103 INCLUDING sy-repid '0103',
                  a_sub0104 INCLUDING sy-repid '0104',
*                  a_sub0105 INCLUDING sy-repid '0105',
                  a_sub0106 INCLUDING sy-repid '0106'.
*
PROCESS AFTER INPUT.
  LOOP AT t_data.
    FIELD t_data-marca
     MODULE tc_pos_mark ON REQUEST.
  ENDLOOP.
  MODULE user_command_exit.
  MODULE tc_revalida_user_command.
  CALL SUBSCREEN: a_sub0101, a_sub0102,
                  a_sub0103, a_sub0104,
*                  a_sub0105, a_sub0106.
                  a_sub0106.


  MODULE user_command_0100.
  MODULE revisa_cuenta.
