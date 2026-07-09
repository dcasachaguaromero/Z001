** This piece of code can change the percentage
** value KOMVD-KBETR to the right format
** Example: customer discount "4 percent"
** in the database table, it is stored as 40.00-,
** The following code can get the right format
** 4,000-%

IF NOT <ko>-kbetr IS INITIAL.
WRITE <ko>-kbetr CURRENCY <ko>-koei1 TO gv_kbetr .
ELSE.
CLEAR gv_kbetr.
ENDIF.























