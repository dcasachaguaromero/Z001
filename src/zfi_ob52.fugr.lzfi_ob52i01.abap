*----------------------------------------------------------------------*
***INCLUDE LZFI_OB52I01.
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  ACTUALIZA_CAMPOS  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE actualiza_campos INPUT.

  CASE sy-dynnr.
    WHEN '0010'.
      MOVE : sy-uname TO zvfi_ob52-uname ,
             sy-datum TO zvfi_ob52-datum ,
             sy-uzeit TO zvfi_ob52-uzeit .
    WHEN '0020'.
      MOVE : sy-uname TO zvfi_ob52_user-uname ,
             sy-datum TO zvfi_ob52_user-datum ,
             sy-uzeit TO zvfi_ob52_user-uzeit .
    WHEN '0030'.
      MOVE : sy-uname TO zvfi_ob52_mail-uname ,
             sy-datum TO zvfi_ob52_mail-datum ,
             sy-uzeit TO zvfi_ob52_mail-uzeit .
  ENDCASE.
ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  VERIFICA_APROB  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE verifica_aprob INPUT.

  CHECK zvfi_ob52_user-modificar IS NOT INITIAL AND
        zvfi_ob52_user-aprobar   IS NOT INITIAL.
  MESSAGE e899(fi) WITH 'Sólo puede tener una opción activa'.
ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  FAGL_EXIT_T001BB  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE fagl_exit_t001bb INPUT.
  CLEAR t001b.                                              "2244957
*   Move-corresponding V_T001bb to T001B.
  MOVE-CORRESPONDING zvfi_ob52_t001b TO t001b.
  PERFORM exit_t001b USING '2' CHANGING t001b.
ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  F4_MKOAR_B  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE f4_mkoar_b INPUT.
*   Perform F4_mkoar using 'V_T001B_COFI-MKOAR'.
  PERFORM f4_mkoar IN PROGRAM sapl0f00
             USING 'ZVFI_OB52_T001B_COFI-MKOAR'.
ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  VALIDA_USER  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE valida_user INPUT.

  IF zvfi_ob52_user-uname IS INITIAL.
    MESSAGE e899(fi) WITH 'Igresar usuario Aprobador'.
  ELSEIF zvfi_ob52_user-bname EQ zvfi_ob52_user-uname.
    IF zvfi_ob52_user-uname NE 'V1_FUN'.
      MESSAGE e899(fi) WITH 'Usario Aprobador no puede ser igual'
                            'al usuario Solicitante'.
    ENDIF.
  ENDIF.

ENDMODULE.
