*----------------------------------------------------------------------*
***INCLUDE LZSD_FACT_ELEF01 .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  USER_COMMAND_0010
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form USER_COMMAND_0010 .
  DATA l_ok_code TYPE sy-ucomm.

  l_ok_code = ok_code.
  CLEAR ok_code.

  CASE l_ok_code.
    WHEN 'EXIT' OR 'BACK' OR 'CNCL' OR 'DET'.
      IF gr_table IS BOUND .
        FREE gr_table.
*       FREE event_receiver.
        CALL METHOD g_custom_container->free
          EXCEPTIONS
            cntl_error        = 1
            cntl_system_error = 2
            OTHERS            = 3.
        IF sy-subrc <> 0.
          MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
          WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
        ENDIF.
        FREE g_custom_container.
      ENDIF.

      IF l_ok_code = 'DET'.
        f_detalle = 'X'.
      ENDIF.

      SET SCREEN 0.
      LEAVE SCREEN.
  ENDCASE.
endform.                    " USER_COMMAND_0010
