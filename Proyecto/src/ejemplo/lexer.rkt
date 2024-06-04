#lang nanopass
(require parser-tools/lex
        (prefix-in : parser-tools/lex-sre))
(provide (all-defined-out))

; 2+3
(define-tokens contenedores (NUM)) ; Tokens con atributo <NUM, 24>
(define-empty-tokens vacios (ADD EOF MUL)) ; Tokens vacios <ADD>

(define hola-lexer
        (lexer
            ;[trigger(expresion regular)   action(reportar error, reportar token, ignorar ...)]
            [(:+ (char-range #\0 #\9))  (token-NUM (string->number lexeme))]
            [(eof)      (token-EOF)]
            [whitespace (hola-lexer input-port)]
            [(:: #\+)   (token-ADD)]
            [(:: #\*)   (token-MUL)]))



#|  Un lexema es una secuencia de caracteres del codigo fuente que coincide con el
    patron de un token
    Ejemplo de clase :
        2+3
        Entrada : +3 <EOF> $
        Pila : 2
        Tokens : <NUM, 24> <ADD>
        Lexema 2
        Token  NUM
        <NUM,24> <ADD> <NUM,3>
|#