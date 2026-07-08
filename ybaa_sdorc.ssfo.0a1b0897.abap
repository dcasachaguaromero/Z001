** This piece of code can change the percentage
** value KOMVD-KBETR to the right format
** Example: customer discount "4 percent"
** in the database table, it is stored as 40.00-,
** The following code can get the right format
** 4,000-%


IF NOT <KO>-KBETR IS INITIAL.
WRITE <KO>-KBETR CURRENCY <KO>-KOEI1 TO GV_KBETR .
ELSE.
CLEAR GV_KBETR.
ENDIF.























