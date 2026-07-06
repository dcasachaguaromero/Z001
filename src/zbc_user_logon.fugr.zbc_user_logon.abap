FUNCTION zbc_user_logon.
*"----------------------------------------------------------------------
*"*"Interfase local
*"  IMPORTING
*"     VALUE(USUARIO) TYPE  RSYST-BNAME
*"     VALUE(PASWORD) TYPE  RSYST-BCODE
*"  EXPORTING
*"     VALUE(MENSAJE) TYPE  CHAR40
*"----------------------------------------------------------------------


  CALL FUNCTION 'SUSR_LOGIN_CHECK_RFC'
    EXPORTING
      bname                     = usuario
      password                  = pasword
    EXCEPTIONS
      wait                      = 1
      user_locked               = 2
      user_not_active           = 3
      password_expired          = 4
      wrong_password            = 5
      no_check_for_this_user    = 6
      password_attempts_limited = 7
      internal_error            = 8
      OTHERS                    = 9.
  IF sy-subrc <> 0.
* Implement suitable error handling here
    mensaje = 'ERROR USUARIO O CLAVE INCORRECTA'.
  ELSE.
    mensaje = 'VALIDO'.
  ENDIF.




ENDFUNCTION.
