#lang nanopass
(provide (all-defined-out))

(require parser-tools/lex
         (prefix-in : parser-tools/lex-sre))

(define-tokens contenedores (IDEN     ; identificador
                             NUM      ; numero
                             BOOL     ; booleano
                             STRING)) ; cadena
(define-empty-tokens vacios (
                             TINT     ; tipo entero
                             TBOOL    ; tipo booleano
                             TSTRING  ; tipo cadena
                             TAINT    ; tipo arreglo de enteros
                             TABOOL   ; tipo arreglo de booleanos
                             TASTRING ; tipo arreglo de cadenas
                             MAIN     ; palabra reservada main
                             IF       ; palabra reservada if
                             ELSE     ; palabra reservada else
                             WHILE    ; palabra reservada while
                             RETURN   ; palabra reservada return
                             PRINT    ; palabra reservada print
                             LENGTH   ; palabra reservada length
                             ADD      ; simbolo suma
                             SUBS     ; simbolo resta
                             MULTI    ; simbolo multiplicacion
                             DIV      ; simbolo division
                             MOD      ; simbolo modulo
                             EQ       ; simbolo igual
                             NEQ      ; simbolo diferente
                             GT       ; simbolo mayor que
                             GTEQ     ; simbolo mayor o igual que
                             LT       ; simbolo menor que
                             LTEQ     ; simbolo menor o igual que
                             OR       ; simbolo or
                             AND      ; simbolo and
                             NOT      ; simbolo not
                             AUTOINC  ; simbolo autoincremento
                             AUTODEC  ; simbolo autodecremento
                             ADDASG   ; simbolo asignacion suma
                             SUBSASG  ; simbolo asignacion resta
                             OPENP    ; simbolo parentesis abierto
                             CLOSEP   ; simbolo parentesis cerrado
                             OPENB    ; simbolo corchete abierto
                             CLOSEB   ; simbolo corchete cerrado
                             OPENRP   ; simbolo parentesis rectangular abierto
                             CLOSERP  ; simbolo parentesis rectangular cerrado
                             QUESM    ; simbolo interrogacion
                             DDOT     ; simbolo dos puntos
                             COMA     ; simbolo coma
                             ASG      ; simbolo asignacion
                             EOF))    ; fin de archivo

(define jelly-lex
    (lexer
        ;;;;;;;;;;;;;;;;;;;;;;;
        ;; Tipos
        ;;;;;;;;;;;;;;;;;;;;;;;
        ["int"     (token-TINT)] ; Tipo entero
        ["bool"    (token-TBOOL)] ; Tipo booleano
        ["string"  (token-TSTRING)] ; Tipo cadena
        ["int[]"   (token-TAINT)] ; Tipo arreglo de enteros
        ["bool[]"  (token-TABOOL)] ; Tipo arreglo de booleanos
        ["string[]" (token-TASTRING)] ; Tipo arreglo de cadenas
        ;;;;;;;;;;;;;;;;;;;;;;;
        ;; Palabras reservadas
        ;;;;;;;;;;;;;;;;;;;;;;;
        ["main"    (token-MAIN)] ; Funcion principal
        ["if"      (token-IF)] ; Condicional if
        ["else"    (token-ELSE)] ; Condicional else
        ["while"   (token-WHILE)] ; Ciclo while
        ["return"  (token-RETURN)] ; Retorno
        ["println"   (token-PRINT)] ; Impresion
        ["len"  (token-LENGTH)] ; Longitud de un arreglo
        ;;;;;;;;;;;;;;;;;;;;;;;
        ;; Simbolos operadores
        ;;;;;;;;;;;;;;;;;;;;;;;
        ["=="       (token-EQ)] ; Simbolo igual
        ["!="       (token-NEQ)] ; Simbolo diferente
        [">="       (token-GTEQ)] ; Simbolo mayor o igual que
        [">"        (token-GT)] ; Simbolo mayor que
        ["<="       (token-LTEQ)] ; Simbolo menor o igual que
        ["<"        (token-LT)] ; Simbolo menor que
        ["|"        (token-OR)] ; Simbolo or
        ["&"        (token-AND)] ; Simbolo and
        ["!"        (token-NOT)] ; Simbolo not
        ["++"       (token-AUTOINC)] ; Simbolo autoincremento
        ["--"       (token-AUTODEC)] ; Simbolo autodecremento
        ["+="       (token-ADDASG)] ; Simbolo asignacion suma
        ["-="       (token-SUBSASG)] ; Simbolo asignacion resta
        ["+"        (token-ADD)] ; Simbolo suma
        ["-"        (token-SUBS)] ; Simbolo resta
        ["*"        (token-MULTI)] ; Simbolo multiplicacion
        ["/"        (token-DIV)] ; Simbolo division
        ["%"        (token-MOD)] ; Simbolo modulo
        ;;;;;;;;;;;;;;;;;;;;;;;
        ;; Simbolos generales
        ;;;;;;;;;;;;;;;;;;;;;;;
        ["("        (token-OPENP)] ; Simbolo parentesis abierto
        [")"        (token-CLOSEP)] ; Simbolo parentesis cerrado
        ["{"        (token-OPENB)] ; Simbolo corchete abierto
        ["}"        (token-CLOSEB)] ; Simbolo corchete cerrado
        ["["        (token-OPENRP)] ; Simbolo parentesis rectangular abierto
        ["]"        (token-CLOSERP)] ; Simbolo parentesis rectangular cerrado
        ["?"        (token-QUESM)] ; Simbolo interrogacion
        [":"        (token-DDOT)] ; Simbolo dos puntos
        [","        (token-COMA)] ; Simbolo coma
        ["="        (token-ASG)] ; Simbolo asignacion
        ;;;;;;;;;;;;;;;;;;;;;;;
        ;; Tokens Contenedores
        ;;;;;;;;;;;;;;;;;;;;;;;
        [(:: (char-range #\a #\z) (:* (:or alphabetic numeric #\_))) (token-IDEN lexeme)] ; Identificadores
        [(:+ (char-range #\0 #\9)) (token-NUM lexeme)] ; Numeros
        [(:or "True" "False") (token-BOOL lexeme)] ; Booleanos
        [(:: #\" (complement (:: any-string #\" any-string)) #\") (token-STRING lexeme)] ; Cadenas
        ; [(:: "'" (complement (:: any-string "'" any-string)) "'") (token-STRING lexeme)] ; Cadenas
        ;;;;;;;;;;;;;;;;;;;;;;;
        ;; Comentarios, espacio en blanco y final de archivo
        ;;;;;;;;;;;;;;;;;;;;;;;
        [whitespace (jelly-lex input-port)] ; Ignorar espacios en blanco 
        [(:: "//" (complement (:: any-string "\n" any-string)) "\n") (jelly-lex input-port)] ; Comentario de una línea
        [(:: "{-" (complement (:: any-string "-}" any-string)) "-}") (jelly-lex input-port)] ; Comentario de varias líneas
        [(eof) (token-EOF)] ; Fin de archivo
        ;;;;;;;;;;;;;;;;;;;;;;;
        ;; Errores
        ;;;;;;;;;;;;;;;;;;;;;;;
        [(:or any-char) (error "Caracter no reconocido " lexeme)])) ; Caracter no reconocido
        ;[(:or any-char) (error "Caracter no reconocido")])) ; Caracter no reconocido

; Prueba
;(jelly-lex (open-input-string " // comentario \n @ 3 + 123"))
;(jelly-lex (open-input-string " {- wowi -} aZu_l:int = 3 + 123"))


#|
Función que toma un archivo con código de jelly y regrese una lista con todos
sus tokens de izquierda a derecha, siempre y cuando no exista un lexema no reconocido
|#
(define (archivo-tokens archivo)
    (define input-port (open-input-file archivo))
    (define lista-tokens '())
    (define loop
        (lambda ()
            (define token (jelly-lex input-port))
            (if (eq? token (token-EOF))
                (begin
                    (set! lista-tokens (cons token lista-tokens ) )
                    (close-input-port input-port)
                    (reverse lista-tokens))
                (begin
                    (set! lista-tokens (cons token lista-tokens))
                    (loop)))))
    (loop))

; Pruebas
;(newline)
;(display "Tokens de gcd.jly\n")
;(define tokens1 (archivo-tokens "ejemplos/gcd.jly"))
;(display tokens1)
;(newline)
;(display (length tokens1))
;(newline)
;(newline)
;(display "Tokens de in.jly\n")
;(define tokens2 (archivo-tokens "ejemplos/in.jly"))
;(display tokens2)
;(newline)
;(display (length tokens2))
;(newline)
;(newline)
;(display "Tokens de sort.jly\n")
;(define tokens3 (archivo-tokens "ejemplos/sort.jly"))
;(display tokens3)
;(newline)
;(display (length tokens3))
;(newline)
;(newline)
;(define tokens4 (archivo-tokens "ejemplos/string.jly"))
;(display "Tokens de string.jly\n")
;(display tokens4)
;(newline)
;(display (length tokens4))
;(newline)
;(newline)
