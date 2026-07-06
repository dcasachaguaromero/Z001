FUNCTION-POOL ZHELP.                        "MESSAGE-ID ..

DATA:    max_rec             LIKE DDSHF4CTRL-MAXRECORDS,
         sel_char(6)         TYPE C.         " Selektion Zahllauf-Id.

DATA:    ok-code             LIKE sy-ucomm.

tables: REGUV,
        reguh,
        F110V.
