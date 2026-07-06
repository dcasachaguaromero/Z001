*&---------------------------------------------------------------------*
*& Report  ZMOD_BSEG
*&
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*

REPORT  ZMOD_REGUH_IDPROC.
TABLES: reguh.
PARAMETERS: P_LAUFD type  LAUFD,
            P_LAUFI type  LAUFI,
            P_XVORL type  XVORL,
            P_IPAGO type CHAR15,
            P_MIPAG TYPE CHAR15,
            P_USER TYPE UNAME.

START-OF-SELECTION.

SELECT single * from reguh CLIENT SPECIFIED
  where
      MANDT	= sy-mandt
      and LAUFD = P_LAUFD
      and LAUFI	= P_LAUFI
      and XVORL =	P_XVORL
      and IDENTIF_PAGO = P_IPAGO.
  IF sy-subrc eq 0.
    REGUH-IDENTIF_PAGO = P_MIPAG.
    REGUH-USUARIO_ENVIO = P_USER.
    MODIFY REGUH.
    IF SY-SUBRC EQ 0.
      MESSAGE 'Se han aplicado los cambios correctamente' type 'I'.
    ELSE.
      MESSAGE 'Error' type 'E'.
    ENDIF.
  ENDIF.
