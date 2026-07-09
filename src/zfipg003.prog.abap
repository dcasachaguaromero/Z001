REPORT zfipg003 NO STANDARD PAGE HEADING LINE-SIZE 255.

INCLUDE zfipg003_top.  "Declaraciones globales
INCLUDE zfipg003_sel.  "Panralla de inicio
INCLUDE zbatchinput.   "Rutinas auxiliares BDC
INCLUDE zfipg003_000.  "Rutinas generales
INCLUDE zfipg003_100.  "Rutinas dynpro 100
INCLUDE zfipg003_200.  "Rutinas dynpro 200
INCLUDE zfipg003_300.  "Rutinas dynpro 300

*--------------------------------------------------------------------*
*                START-OF-SELECTION
*--------------------------------------------------------------------*
START-OF-SELECTION.

  PERFORM proceso.

  CALL SCREEN 150.
