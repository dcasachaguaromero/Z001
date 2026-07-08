*----------------------------------------------------------------------*
***INCLUDE LZCBANF01 .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  SEPARAR_CAMPOS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM SEPARAR_CAMPOS tables e_numbers
                    using i_note_to_payee .
*"----------------------------------------------------------------------
*"*"Lokale Schnittstelle:
*"  IMPORTING
*"     REFERENCE(I_NOTE_TO_PAYEE) TYPE  STRING
*"  TABLES
*"      E_NUMBERS
*"----------------------------------------------------------------------
*Data for Transfer of interpretation algorithms            hw597428

data: convert1(52)  type c value
             'A B C D E F G H I J K L M N O P Q R S T U V W X Y Z ',
      convert4(52)  type c value                            "note 398160
*             '. , < > & " % ! ( ) = ? : # * + / $ # _ ',    "note 398160
              ', < > & " % ! ( ) = ? : # * + / $ # _ ',    "note 398160

      convert2(52)  type c value
             '. , < > & " % ! ( ) = ? : - # * + / $ # _ ; ',"hw498406
      convert3(02)  type c value
             ' ;'.

  data:
        l_note_to_payee type char4000,
        l_head(70)        type c,
        l_maxlen          type i,                            "n937334
        l_diff            type i,                            "n937334
        l_length          type i.                            "n937334

  describe field e_numbers length l_maxlen in character mode."n937334

  l_note_to_payee = i_note_to_payee.

* 0) replace strange characters
  call function 'SCP_REPLACE_STRANGE_CHARS'
    EXPORTING
      intext  = l_note_to_payee
    IMPORTING
      outtext = l_note_to_payee
    EXCEPTIONS
      others  = 01.
* 1) delete all letters
  translate l_note_to_payee to upper case.                "#EC SYNTCHAR
*  translate l_note_to_payee using convert1.
* 2) replace special characters
  translate l_note_to_payee using convert2.
* 3) separate the numbers by semicolons
  condense l_note_to_payee.
  translate l_note_to_payee using convert3.

* fill the export table
  do.
    call function 'STRING_SPLIT'
      EXPORTING
        delimiter = ';'
        string    = l_note_to_payee
      IMPORTING
        head      = l_head
        tail      = l_note_to_payee
      EXCEPTIONS
        others    = 01.
    if l_head = space or sy-subrc ne 0.
      exit.
    endif.

        append l_head to e_numbers.

  enddo.
  sort e_numbers.
  delete adjacent duplicates from e_numbers.

ENDFORM.                    " SEPARAR_CAMPOS
