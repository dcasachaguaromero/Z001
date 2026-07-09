*&---------------------------------------------------------------------*
*&  Include           ZXJ1IU04
*&---------------------------------------------------------------------*
DATA: CON_BEZWKZ_ZA LIKE T090P-BEZWKZ VALUE 'ZA',
      I_BEZWKZ LIKE J_1AAA2-J_1AABZWKZ.

* BEGIN. 07-07-2026 - ATC - ATC-01
* OLD CODE
* SELECT SINGLE J_1AABZWKZ INTO I_BEZWKZ FROM J_1AAA2
*                          WHERE BUKRS      = I_ANLB-BUKRS
*                          AND   J_1AARVKEY = I_ANLB-J_1AARVKEY .
*
* NEW CODE
 SELECT J_1AABZWKZ
 UP TO 1 ROWS  INTO I_BEZWKZ FROM J_1AAA2
                          WHERE BUKRS      = I_ANLB-BUKRS
                          AND   J_1AARVKEY = I_ANLB-J_1AARVKEY  ORDER BY PRIMARY KEY.

 ENDSELECT.
* END. 07-07-2026 - ATC - ATC-01
 IF SY-SUBRC <> 0.
    EXIT.
 ENDIF.

 CASE I_BEZWKZ.
  WHEN CON_BEZWKZ_ZA.
    E_KANSW =  I_ANLC-KANSW + I_ANLC-ANSWL +
               I_ANLC-KMAFA + I_ANLC-MAFAV + I_ANLC-ZUSMA +
               I_ANLC-MAFAM + I_ANLC-MAFAL +
               I_ANLC-KAUFW + I_ANLC-AUFWV .
  WHEN OTHERS.
 ENDCASE.
