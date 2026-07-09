*&---------------------------------------------------------------------*
*&  Include           ZXRWAU02
*&---------------------------------------------------------------------*
 DATA : lw_cosp TYPE cosp.
*
 CASE i_report_group.
* SOLO SE VALIDAN LOS SIGUIENTES REPORTES
   WHEN 'ZVK1' OR 'ZVK2' OR 'ZVK3'.
     MOVE-CORRESPONDING i_s_record TO lw_cosp.
     AUTHORITY-CHECK OBJECT 'F_BKPF_BUK'
              ID 'BUKRS' FIELD lw_cosp-bukrs
              ID 'ACTVT' FIELD '03'.
     IF sy-subrc <> 0.
       e_skip_standard_exit = 'X'.
       RAISE no_authority .
     ENDIF.
 ENDCASE.
