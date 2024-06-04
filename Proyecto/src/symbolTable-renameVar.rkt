#lang nanopass
(provide (all-defined-out))

(require "syntaxtTree.rkt" "parser.rkt" "lexer.rkt")

(define (identificador? i)
    (symbol? i))

(define (tipo? t)
    (memq t '(int bool string intarr boolarr stringarr)))

(define (operador? op)
    (memq op '(== != >= > <= < or and + - * / % !)))

(define (booleano? b)
    (memq b '(True False)))

(define (constante? c)
    (or (number? c) (string? c) (booleano? c)))


; la gramatica no estan estricta como la de parser.rkt (esta es mas relajada)
(define-language jelly
    (terminals
        (constante (c)) ; constante (numero, string, boolean)
        (operador (op)) ; operador
        (tipo (t)) ; tipo
        (identificador (i)) ; identificador
    )
    (Programa (p)
        ((ase* ...) m (pc* ...)) ; (asignacion especial* ...) main (procedimiento* ...)
    )
    (Main (m)
        (main (ln* ...)) ; main (linea* ...)
    )
    (Proc (pc)
        fnc ; funcion
        mtd ; metodo
    )
    (Funcion (fnc)
        (funcion i (dec* ...) (ln* ...)) ; identificador (declaracion* ...) (linea* ...)
        ;(i ((i* t*) ...) (ln* ... ln)) ; identificador (identificador* tipo*) (linea* ... linea)
    )
    (Metodo (mtd)
        (metodo i (dec* ...) t (ln* ...) rtn) ; identificador (declaracion* ...) (linea* ...) return
        ;(i ((i* t*) ...) t (ln* ...) rtn) ; identificador (identificador* tipo*) tipo (linea* ...) return
    )
    (Return (rtn)
        (return e) ; return expresion
    )
    (Linea (ln)
        (whilejly e (ln* ...)) ; while expresion (linea* ...)
        (ifjly e (ln1* ...) (ln2* ...)) ; if expresion (linea* ...) (linea* ...)
        dec ; declaracion
        e ; expresion
    )
    (Declaracion (dec)
        ;(: (i* ... ) t) ; (identificador* ...) tipo
        (: i t) ; identificador tipo
    )
    (Asignacion (as)
        (= e1 e2) ; expresion expresion
        ;(= (i1* ...) e) ; (identificador* ...) expresion
        ase ; asignacion especial
    )
    (AsigEspecial (ase)
        (= i t e) ; identificador tipo expresion
    )
    (Expr (e)
        c ; numero, boolean, cadena
        i ; identificador
        (arr-pos i e) ; arreglo posicion identificador expresion
        (usop i (e* ...)) ; uso procedimiento
        (if-expr e1 e2 e3) ; if-expresion expresion expresion expresion
        as ; asignacion Error memf: not a proper list: '#s((nonterminal-alt #(0) alt 3) #<syntax:nuevo.rkt:72:8 as> #f #f #<syntax:nuevo.rkt:58:5 Asignacion>)
        (len e) ; longitud
        (arr (e* ...)) ; arreglo (expresion* ...)
        (op e1 e2) ; operador expresion expresion
        (op e) ; operador expresion
    )
)

; Definicion del parser
(define-parser parser-jelly-n jelly)


; Metodos para obtener las variables de un programa usando catamorfismos

; Metodo para obtener las variables de un programa
(define (vars-programa ir vs)
    (nanopass-case (jelly Programa) ir
        [((,[vars-asesp : ase* vs -> vs1] ...) ,[vars-main : m vs -> vs2]  (,[vars-proc : pc* vs -> pc1] ...)) vs]
        [else vs]))

; Metodo para obtener las variables de un main
(define (vars-main ir vs)
    (nanopass-case (jelly Main) ir
        [(main (,[vars-linea : ln* vs -> ln1] ...)) vs]
        [else vs]))

; Metodo para obtener las variables de un procedimiento
(define (vars-proc ir vs)
    (nanopass-case (jelly Proc) ir
        [,fnc (vars-funcion fnc vs)]
        [,mtd (vars-metodo mtd vs)]
        [else vs]))

; Metodo para obtener las variables de una funcion
(define (vars-funcion ir vs)
    (nanopass-case (jelly Funcion) ir
        [(funcion ,i (,[vars-declaracion : dec* vs -> dec1] ...) (,[vars-linea : ln* vs -> ln1] ...)) vs]
        [else vs]))

; Metodo para obtener las variables de un metodo
(define (vars-metodo ir vs)
    (nanopass-case (jelly Metodo) ir
        [(metodo ,i (,[vars-declaracion : dec* vs -> dec1] ...) ,t (,[vars-linea : ln* vs -> ln1] ...) ,[vars-return : rtn vs -> rtn1]) vs]
        [else vs]))

; Metodo para obtener las variables de un return
(define (vars-return ir vs)
    (nanopass-case (jelly Return) ir
        [(return ,[vars-expr : e vs -> e1]) vs]
        [else vs]))

; Metodo para obtener las variables de una linea
(define (vars-linea ir vs)
    (nanopass-case (jelly Linea) ir
        [(whilejly ,[vars-expr : e vs -> e1] (,[vars-linea : ln* vs -> ln1] ...)) vs]
        [(ifjly ,[vars-expr : e vs -> e1] (,[vars-linea : ln1* vs -> ln3] ...) (,[vars-linea : ln2* vs -> ln4] ...)) vs]
        [,dec (vars-declaracion dec vs)]
        [,as (vars-asignacion as vs)]
        [,e (vars-expr e vs)]
        [else vs]))

; Metodo para obtener las variables de una declaracion
(define (vars-declaracion ir vs)
    (nanopass-case (jelly Declaracion) ir
        [(: ,i ,t) (set-add! vs i)]
        ;[(: (,i* ...) ,t) (map (lambda (x) (set-add! vs x)) i*)]
        [else vs]))

; Metodo para obtener las variables de una asignacion
(define (vars-asignacion ir vs)
    (nanopass-case (jelly Asignacion) ir
        [(= ,[vars-expr : e1 vs -> e3] ,[vars-expr : e2 vs -> e4]) vs]
        ;[(= (,i1* ...) ,e) (map (lambda (x) (set-add! vs x)) i1*)] ; Error ?: invalid pattern or template
        [,ase (vars-asesp ase vs)]
        [else vs]))

; Metodo para obtener las variables de una asignacion especial
(define (vars-asesp ir vs)
    (nanopass-case (jelly AsigEspecial) ir
        [(= ,i ,t ,[vars-expr : e vs -> e1]) (set-add! vs i)]
        [else vs]))

; Metodo para obtener las variables de una expresion
(define (vars-expr ir vs)
    (nanopass-case (jelly Expr) ir
        [,c vs]
        [,i (set-add! vs i)]
        [(arr-pos ,i ,[vars-expr : e vs -> e1]) (set-add! vs i)]
        [(usop ,i (,[vars-expr : e* vs -> e1] ...)) vs]
        [(if-expr ,[vars-expr : e1 vs -> e4] ,[vars-expr : e2 vs -> e5] ,[vars-expr : e3 vs -> e6]) vs]
        [,as vs]
        [(len ,[vars-expr : e vs -> e1]) vs]
        [(arr (,[vars-expr : e* vs -> e1] ...)) vs]
        [(,op ,[vars-expr : e vs -> e1]) vs]
        [(,op ,[vars-expr : e1 vs -> e3] ,[vars-expr : e2 vs -> e4]) vs]
        [else vs]))

; Metodo para obtener las variables de un programa parseado
(define (vars-parseado ir)
    (let ([variables (mutable-set)])
        (vars-programa ir variables)
        variables))


; Metodos para renombrar las variables de un programa

; Definir una variable global para el contador de variables
(define c 0)

; Obtiene un nuevo nombre para una variable
(define (nueva)
        (let* ([str-num (number->string c)]
            [str-sim (string-append "variable_bonita_" str-num)]) ;var_bonita_0
            (set! c (add1 c))
            (string->symbol str-sim)))

; Asignar un nuevo nombre a las variables de un programa en un hash
(define (asigna vars)
        (let ([tabla (make-hash)])
            (set-for-each vars (lambda (v) (hash-set! tabla v (nueva)))) ; version sin prints
            #| version con prints
            (set-for-each vars (lambda (v) (let ([varnueva (nueva)])
                (begin
                    (print v)
                    (print " -> ")
                    (print varnueva)
                    (newline)
                    (hash-set! tabla v varnueva)))))
            |#
            tabla))

; Metodo para renombrar las variables de un programa
(define-pass ranme-var : jelly (ir) -> jelly ()
    (Programa : Programa (ir) -> Programa ()
        [((,ase* ...) ,m (,pc* ...))
            (let* ([vars (vars-programa ir (mutable-set))]
                [tabla (asigna vars)]
                [ase*-1 (map (lambda (x) (AsigEspecial x tabla)) ase*)]
                [m-1 (Main m tabla)]
                [pc*-1 (map (lambda (x) (Proc x tabla)) pc*)])
                `((,ase*-1 ...) ,m-1 (,pc*-1 ...)))]
        [else (begin (print "caso else de ranme-var programa") ir)])
    (Main : Main (ir h) -> Main ()
        [(main (,ln* ...))
            (let ([ln*-1 (map (lambda (x) (Linea x h)) ln*)])
                `(main (,ln*-1 ...)))]
        [else (begin (print "caso else de ranme-var main") ir)])
    (Proc : Proc (ir h) -> Proc ()
        [,fnc (Funcion fnc h)]
        [,mtd (Metodo mtd h)]
        [else (begin (print "caso else de ranme-var proc") ir)])
    (Funcion : Funcion (ir h) -> Funcion ()
        [(funcion ,i (,dec* ...) (,ln* ...))
            (let ([dec*-1 (map (lambda (x) (Declaracion x h)) dec*)]
                [ln*-1 (map (lambda (x) (Linea x h)) ln*)])
                `(funcion ,i (,dec*-1 ...) (,ln*-1 ...)))]
        [else (begin (print "caso else de ranme-var funcion") ir)])
    (Metodo : Metodo (ir h) -> Metodo ()
        [(metodo ,i (,dec* ...) ,t (,ln* ...) ,rtn)
            (let ([dec*-1 (map (lambda (x) (Declaracion x h)) dec*)]
                [ln*-1 (map (lambda (x) (Linea x h)) ln*)]
                [rtn-1 (Return rtn h)])
                `(metodo ,i (,dec*-1 ...) ,t (,ln*-1 ...) ,rtn-1))]
        [else (begin (print "caso else de ranme-var metodo") ir)])
    (Return : Return (ir h) -> Return ()
        [(return ,e)
            (let ([e-1 (Expr e h)])
                `(return ,e-1))]
        [else (begin (print "caso else de ranme-var return") ir)])
    (Linea : Linea (ir h) -> Linea ()
        [(whilejly ,e (,ln* ...))
            (let ([ln*-1 (map (lambda (x) (Linea x h)) ln*)]
                [e-1 (Expr e h)])
                `(whilejly ,e-1 (,ln*-1 ...)))]
        [(ifjly ,e (,ln1* ...) (,ln2* ...))
            (let ([ln1*-1 (map (lambda (x) (Linea x h)) ln1*)]
                [ln2*-1 (map (lambda (x) (Linea x h)) ln2*)]
                [e-1 (Expr e h)])
                `(ifjly ,e-1 (,ln1*-1 ...) (,ln2*-1 ...)))]
        [,dec (Declaracion dec h)]
        [,as (Asignacion as h)]
        [,e (Expr e h)]
        [else (begin (print "caso else de ranme-var linea") ir)])
    (Declaracion : Declaracion (ir h) -> Declaracion ()
        [(: ,i ,t)
            (let ([i-1 (hash-ref h i i)])
                `(: ,i-1 ,t))]
        [else (begin (print "caso else de ranme-var declaracion") ir)])
    (Asignacion : Asignacion (ir h) -> Asignacion ()
        [(= ,e1 ,e2)
            (let ([e1-1 (Expr e1 h)]
                 [e2-1 (Expr e2 h)])
                `(= ,e1-1 ,e2-1))]
        [,ase (AsigEspecial ase h)]
        [else (begin (print "caso else de ranme-var asignacion") ir)])
    (AsigEspecial : AsigEspecial (ir h) -> AsigEspecial ()
        [(= ,i ,t ,e)
            (let ([i-1 (hash-ref h i i)]
                 [e-1 (Expr e h)])
                `(= ,i-1 ,t ,e-1))]
        [else (begin (print "caso else de ranme-var asignacion especial") ir)])
    (Expr : Expr (ir h) -> Expr ()
        [,c `,c]
        [,i 
            (let ([i-1 (hash-ref h i i)])
                `,i-1)]
        [(arr-pos ,i ,e)
            (let ([i-1 (hash-ref h i i)]
                 [e-1 (Expr e h)])
                `(arr-pos ,i-1 ,e-1))]
        [(usop ,i (,e* ...))
            (let ([e*-1 (map (lambda (x) (Expr x h)) e*)])
                `(usop ,i (,e*-1 ...)))]
        [(if-expr ,e1 ,e2 ,e3)
            (let ([e1-1 (Expr e1 h)]
                 [e2-1 (Expr e2 h)]
                 [e3-1 (Expr e3 h)])
                `(if-expr ,e1-1 ,e2-1 ,e3-1))]
        [,as (Asignacion as h)]
        [(len ,e)
            (let ([e-1 (Expr e h)])
                `(len ,e-1))]
        [(arr (,e* ...))
            (let ([e*-1 (map (lambda (x) (Expr x h)) e*)])
                `(arr (,e*-1 ...)))]
        [(,op ,e)
            (let ([e-1 (Expr e h)])
                `(,op ,e-1))]
        [(,op ,e1 ,e2)
            (let ([e1-1 (Expr e1 h)]
                 [e2-1 (Expr e2 h)])
                `(,op ,e1-1 ,e2-1))]
        [else (begin (print "caso else de ranme-var expr") ir)]))

; Metodo para renombrar las variables de un programa archivo
(define (ranme-var-archivo archivo)
    (let* ([arbol (arbolarch archivo)]
        [arbol-parseado (parser-jelly-n (read (open-input-string arbol)))])
        (ranme-var arbol-parseado)))


; Metodos para tabla de simbolos usando catamorfismos

; Metodo para obtener la tabla de simbolos de un programa
(define (symbol-table-programa ir st)
    (nanopass-case (jelly Programa) ir
        [((,[symbol-table-asesp : ase* st -> ase1] ...) ,[symbol-table-main : m st -> st2]  (,[symbol-table-proc : pc* st -> pc1] ...)) st]
        [else st]))

; Metodo para obtener la tabla de simbolos de un main
(define (symbol-table-main ir st)
    (nanopass-case (jelly Main) ir
        [(main (,[symbol-table-linea : ln* st -> ln1] ...)) st]
        [else st]))

; Metodo para obtener la tabla de simbolos de un procedimiento
(define (symbol-table-proc ir st)
    (nanopass-case (jelly Proc) ir
        [,fnc (symbol-table-funcion fnc st)]
        [,mtd (symbol-table-metodo mtd st)]
        [else st]))

; Metodo para obtener la tabla de simbolos de una funcion
(define (symbol-table-funcion ir st)
    (nanopass-case (jelly Funcion) ir
        [(funcion ,i (,[symbol-table-declaracion : dec* st -> dec1] ...) (,[symbol-table-linea : ln* st -> ln1] ...)) st]
        [else st]))

; Metodo para obtener la tabla de simbolos de un metodo
(define (symbol-table-metodo ir st)
    (nanopass-case (jelly Metodo) ir
        [(metodo ,i (,[symbol-table-declaracion : dec* st -> dec1] ...) ,t (,[symbol-table-linea : ln* st -> ln1] ...) ,[symbol-table-return : rtn st -> rtn1]) st]
        [else st]))

; Metodo para obtener la tabla de simbolos de un return
(define (symbol-table-return ir st)
    (nanopass-case (jelly Return) ir
        [(return ,[symbol-table-expr : e st -> e1]) st]
        [else st]))

; Metodo para obtener la tabla de simbolos de una linea
(define (symbol-table-linea ir st)
    (nanopass-case (jelly Linea) ir
        [(whilejly ,[symbol-table-expr : e st -> e1] (,[symbol-table-linea : ln* st -> ln1] ...)) st]
        [(ifjly ,[symbol-table-expr : e st -> e1] (,[symbol-table-linea : ln1* st -> ln3] ...) (,[symbol-table-linea : ln2* st -> ln4] ...)) st]
        [,dec (symbol-table-declaracion dec st)]
        [,as (symbol-table-asignacion as st)]
        [,e (symbol-table-expr e st)]
        [else st]))

; Metodo para obtener la tabla de simbolos de una declaracion
(define (symbol-table-declaracion ir st)
    (nanopass-case (jelly Declaracion) ir
        [(: ,i ,t) (hash-set! st i t)]
        ;[(: (,i* ...) ,t) (map (lambda (x) (hash-set! st x t)) i*)]
        [else st]))

; Metodo para obtener la tabla de simbolos de una asignacion
(define (symbol-table-asignacion ir st)
    (nanopass-case (jelly Asignacion) ir
        [(= ,[symbol-table-expr : e1 st -> e3] ,[symbol-table-expr : e2 st -> e4]) st]
        ;[(= (,i1* ...) ,e) st] ; Error ?: invalid pattern or template
        [,ase (symbol-table-asesp ase st)]
        [else st]))

; Metodo para obtener la tabla de simbolos de una asignacion especial
(define (symbol-table-asesp ir st)
    (nanopass-case (jelly AsigEspecial) ir
        [(= ,i ,t ,[symbol-table-expr : e st -> e1]) (hash-set! st i t)]
        [else st]))

; Metodo para obtener la tabla de simbolos de una expresion
(define (symbol-table-expr ir st)
    (nanopass-case (jelly Expr) ir
        [,c st]
        [,i st]
        [(arr-pos ,i ,[symbol-table-expr : e st -> e1]) st]
        [(usop ,i (,[symbol-table-expr : e* st -> e1] ...)) st]
        [(if-expr ,[symbol-table-expr : e1 st -> e4] ,[symbol-table-expr : e2 st -> e5] ,[symbol-table-expr : e3 st -> e6]) st]
        [,as st]
        [(len ,[symbol-table-expr : e st -> e1]) st]
        [(arr (,[symbol-table-expr : e* st -> e1] ...)) st]
        [(,op ,[symbol-table-expr : e st -> e1]) st]
        [(,op ,[symbol-table-expr : e1 st -> e3] ,[symbol-table-expr : e2 st -> e4]) st]
        [else st]))

; Metodo para obtener la tabla de simbolos de un programa, luego de renombrar las variables
(define (symbol-table ir)
    (let ([tabla (make-hash)])
        (symbol-table-programa (ranme-var ir) tabla)
        tabla))

; Metodo para obtener la tabla de simbolos de un programa, sin renombrar las variables
(define (symbol-table-sin ir)
    (let ([tabla (make-hash)])
        (symbol-table-programa ir tabla)
        tabla))

; Metodo para obtener la tabla de simbolos de un programa archivo, luego de renombrar las variables
(define (symbol-table-archivo archivo)
    (let* ([arbol (arbolarch archivo)]
        [arbol-parseado (parser-jelly-n (read (open-input-string arbol)))])
        (symbol-table arbol-parseado)))

; Metodo para obtener la tabla de simbolos de un programa archivo, sin renombrar las variables
(define (symbol-table-archivo-sin archivo)
    (let* ([arbol (arbolarch archivo)]
        [arbol-parseado (parser-jelly-n (read (open-input-string arbol)))])
        (symbol-table-sin arbol-parseado)))


#|
; Pruebas
(display "\nArchivo de entrada\n")
;(define archivo "ejemplos/op.jly")
;(define archivo "ejemplos/string.jly")
;(define archivo "ejemplos/a.jly")
(define archivo "ejemplos/in.jly")
(display archivo)
(display "\n\n")
(display "Abol sintactico\n")
(define ejemplo (arbolarch archivo))
(display ejemplo)
(display "\n\n")
(display "Parser de Nanopass\n")
(define ejemplo2 (parser-jelly-n (read (open-input-string ejemplo))))
(display ejemplo2)
(display "\n\n")
(display "Tabla de simbolos\n")
(define ejemplo3 (symbol-table-sin ejemplo2))
(display ejemplo3)
(display "\n\n")
(display "Variables\n")
(define variablesp (vars-parseado ejemplo2))
(display variablesp)
(display "\n\n")
(display "Renombrar variables\n")
(define ejemplo2ren (ranme-var ejemplo2))
(display ejemplo2ren)
(display "\n\n")
(display "Tabla de simbolos renombrada\n")
(define ejemplo3ren (symbol-table ejemplo2))
(display ejemplo3ren)
(display "\n\n")
|#

#|
; Pruebas 2.0
(display "\n")
(define prueba (ranme-var-archivo "ejemplos/in.jly"))
(display prueba)
(display "\n\n")
(define prueba2 (symbol-table-archivo "ejemplos/in.jly"))
(display prueba2)
(display "\n\n")
|#
