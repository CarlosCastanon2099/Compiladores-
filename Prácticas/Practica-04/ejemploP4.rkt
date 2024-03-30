#lang nanopass
(require "lexer.rkt"
         parser-tools/yacc)

(define-struct num (v) #:transparent)
(define-struct id (nombre) #:transparent)
(define-struct if-completo (guardia ten elze) #:transparent)
(define-struct if-chiquito (guardia ten) #:transparent)
(define-struct auto-incremento (nombre) #:transparent)
(define-struct auto-decremento (nombre) #:transparent)
(define-struct bin-op (op arg1 arg2) #:transparent)

(define jelly-parser
    (parser
        [start expr]
        [end EOF]
        [tokens contenedores vacios]
        [error (lambda (tok-ok? tok-name tok-value)
           (raise-syntax-error 'error
                               "no fue posible procesar un token"
                               (if tok-value tok-value tok-name)))]
        ;[expected-SR-conflicts 5]
        [precs  (nonassoc LP RP LK RK)
                ;(left >) El error de los 5 shift/reduce es que teníamos en la
                    ;precedencia el token >, en vez de <. Así ya no hay conflictos
                (left <)
                (left +)
                (left *)]

        [grammar
            [const
                [(NUM) (num $1)]]

            [identificador
                [(ID) (id $1)]]

            [if
                [(IF LP expr RP bloque ELSE bloque ) (if-completo $3 $5 $7)]
                [(IF LP expr RP bloque) (if-chiquito $3 $5)]
                ]

            [stmt
                [(if) $1]
                [(identificador ++) (auto-incremento $1)]
                [(identificador --) (auto-decremento $1)]
                [(bloque) $1]]

            [bloque  ;Bloque: {a++ b++ r--}
                [(LK lineas RK) $2]]

            [lineas
                [(stmt lineas) (list* $1 $2)]
                [(stmt) (list $1)]]

            ; [expr
            ;     [(expr + expr) (bin-op '+ $1 $3)]
            ;     [(expr * expr) (bin-op '* $1 $3)]
            ;     [(expr < expr) (bin-op '< $1 $3)]
            ;     [(identificador) $1]
            ;     [(const) $1]]
            [expr
                [(expr + expr) (bin-op '+ $1 $3)]
                [(expr * expr) (bin-op '* $1 $3)]
                [(expr < expr) (bin-op '> $1 $3)]
                [(identificador)        $1]
                [(const)        $1]]]))

; const := num
; identificador = id
; expr := expr < expr | const | identificador
; stmt := IF LP expr RP LK  stmt RK ELSE LK stmt RK |
;         IF LP expr RP LK  stmt RK |
;         identificador ++ |
;         identificador -- |

(define if-in "if(1){
                    a++
                    n++}
                else{
                    b++
                    r++}")


(define (lex-this lexer input) (lambda () (lexer input)))

(define (parsea in)
        (let ([in-s (open-input-string in)])
        (syntax-tree (jelly-parser (lex-this jelly-lexer in-s)))))

; LALR(1)
;     2 acciones principales
;         SHIFT: Avanzar el look ahead un token
;         REDUCE: Aplicar una regla de produccion de manera inversa

; expr := num
; stmt := IF expr THEN smtm ELSE stmt | IF expr THEN stmt | id ++ | id --


; IF 1 THEN a++ •ELSE b++

;(if-completo (bin-op '< (num 1) (id 'a)) (auto-incremento (id 'a)) '())

(define (syntax-tree expr)
  (match expr
    [(num v) (number->string v)]             ;<---- Numbero
    [(id nombre) (symbol->string nombre)]    ;<---- Simbolo
    [(auto-incremento nombre)
        (string-append  "(= " (syntax-tree nombre) "(+ "
                        (syntax-tree nombre) " 1))")]
    [(bin-op op arg1 arg2)
            (string-append "(" (symbol->string op) " "
                                (syntax-tree arg1) " "
                                (syntax-tree arg2)
                                ")" )]
    ['() ""]
    [(list h t) (string-append (syntax-tree h)
                               (syntax-tree t))]
    ))
