*&---------------------------------------------------------------------*
*& Include YINCIMPETIQREM
*&---------------------------------------------------------------------*
*----- Transfere Tabela Interna para Arquivo de Impressão -----*

*++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*
* Modification history                                               *
*1.) 11.04.2017        BHARDWAA                             CR0093193*
*   EHP8 Upgrade: Custom Objects Correction                          *
*++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*
FORM GRAVA_TXT USING NAMEARQ.
* AUCT-UPGRADE - Begin of Modification by <BHARDWAA> on <17.02.2017> for <EHP8>
*CALL FUNCTION 'WS_DOWNLOAD'
*EXPORTING
*FILENAME = NAMEARQ
*TABLES
*DATA_TAB = ARQUIVO
*EXCEPTIONS
*FILE_OPEN_ERROR = 1
*OTHERS          = 2.
DATA: w_upg1_p_file1_1 type string.
DATA: v_upg1_p_file_1 type char10.
w_upg1_p_file1_1 = NAMEARQ.
CALL FUNCTION 'GUI_DOWNLOAD'
EXPORTING
FILENAME = w_upg1_p_file1_1
TABLES
DATA_TAB = ARQUIVO
EXCEPTIONS
FILE_WRITE_ERROR = 1
NO_BATCH = 2
GUI_REFUSE_FILETRANSFER = 3
INVALID_TYPE = 4
NO_AUTHORITY = 5
UNKNOWN_ERROR = 6
HEADER_NOT_ALLOWED = 7
SEPARATOR_NOT_ALLOWED = 8
FILESIZE_NOT_ALLOWED = 9
HEADER_TOO_LONG = 10
DP_ERROR_CREATE = 11
DP_ERROR_SEND = 12
DP_ERROR_WRITE = 13
UNKNOWN_DP_ERROR = 14
ACCESS_DENIED = 15
DP_OUT_OF_MEMORY = 16
DISK_FULL = 17
DP_TIMEOUT = 18
FILE_NOT_FOUND = 19
DATAPROVIDER_EXCEPTION = 20
CONTROL_FLUSH_ERROR = 21
OTHERS = 22.
* AUCT-UPGRADE -  End of Modification by <BHARDWAA> on <17.02.2017> for <EHP8>
   CASE SY-SUBRC.
      WHEN 1.
         WRITE 'Erro na Abertura do Arquivo.'.
         EXIT.
      WHEN 2.
         WRITE 'Erro durante a transferência de Dados.'.
         EXIT.
   ENDCASE.
ENDFORM.
