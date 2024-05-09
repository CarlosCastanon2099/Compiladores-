#lang nanopass
(provide (all-defined-out))

(require "symbolTable-renameVar.rkt" "syntaxtTree.rkt")

; Metodos para verificar los tipos de un programa usando catamorfismos

; Metodo para verificar el tipo de un programa
(define (type-check-programa ir st)
    (nanopass-case (jelly Programa) ir
        [((,[type-check-asesp : ase* st -> t1] ...) ,[type-check-main : m st -> t2] (,[type-check-proc : pc* st -> t3] ...)) 'UNIT]
        [else (error "Error en type-check-programa")]))

; Metodo para verificar el tipo de un main
(define (type-check-main ir st)
    (nanopass-case (jelly Main) ir
        [(main (,[type-check-linea : ln* st -> t] ...)) 'UNIT]
        [else (error "Error en type-check-main")]))

; Metodo para verificar el tipo de un procedimiento
(define (type-check-proc ir st)
    (nanopass-case (jelly Proc) ir
        [,fnc (type-check-funcion fnc st)]
        [,mtd (type-check-metodo mtd st)]
        [else (error "Error en type-check-proc")]))

; Metodo para verificar el tipo de una funcion
(define (type-check-funcion ir st)
    (nanopass-case (jelly Funcion) ir
        [(funcion ,i (,[type-check-declaracion : dec* st -> t1] ...) (,[type-check-linea : ln* st -> t2] ...)) 'UNIT]
        [else (error "Error en type-check-funcion")]))

; Metodo para verificar el tipo de un metodo
(define (type-check-metodo ir st)
    (nanopass-case (jelly Metodo) ir
        [(metodo ,i (,[type-check-declaracion : dec* st -> t1] ...) ,t (,[type-check-linea : ln* st -> t2] ...) ,[type-check-return : rtn st -> t3])
            (if (equal? t t3) 'UNIT (error "Error en type-check-metodo con " t " y " t3))]
        [else (error "Error en type-check-metodo")]))

; Metodo para verificar el tipo de un return
(define (type-check-return ir st)
    (nanopass-case (jelly Return) ir
        [(return ,[type-check-expr : e st -> t1]) t1]
        [else (error "Error en type-check-return")]))

; Metodo para verificar el tipo de una linea
(define (type-check-linea ir st)
    (nanopass-case (jelly Linea) ir
        [(whilejly ,[type-check-expr : e st -> t1] (,[type-check-linea : ln* st -> t2] ...))
            (if (equal? t1 'bool) 'UNIT (error "Error en type-check-linea-while con " t1 " y bool"))]
        [(ifjly ,[type-check-expr : e st -> t1] (,[type-check-linea : ln1* st -> t2] ...) (,[type-check-linea : ln2* st -> t3] ...))
            (if (equal? t1 'bool) 'UNIT (error "Error en type-check-linea-if con " t1 " y bool"))]
        [,dec (type-check-declaracion dec st)]
        [,as (type-check-asignacion as st)]
        [,e (type-check-expr e st)]
        [else (error "Error en type-check-linea")]))

; Metodo para verificar el tipo de una declaracion
(define (type-check-declaracion ir st)
    (nanopass-case (jelly Declaracion) ir
        [(: ,i ,t) 'UNIT]
        [else (error "Error en type-check-declaracion")]))

; Metodo para verificar el tipo de una asignacion
(define (type-check-asignacion ir st)
    (nanopass-case (jelly Asignacion) ir
        [(= ,[type-check-expr : e1 st -> t1] ,[type-check-expr : e2 st -> t2])
            (if (equal? t1 t2) t1 (error "Error en type-check-asignacion con " t1 " y " t2))]
        [,ase (type-check-asesp ase st)]
        [else (error "Error en type-check-asignacion")]))

; Metodo para verificar el tipo de una asignacion especial
(define (type-check-asesp ir st)
    (nanopass-case (jelly AsigEspecial) ir
        [(= ,i ,t ,[type-check-expr : e st -> t1])
            (if (equal? t t1) t (error "Error en type-check-asesp con " t " y " t1))]
        [else (error "Error en type-check-asesp con " ir)]))

; Metodo para verificar el tipo de una expresion
(define (type-check-expr ir st)
    (nanopass-case (jelly Expr) ir
        [,c (type-check-const c)]
        [,i (type-check-id i st)]
        [(arr-pos ,[type-check-expr : i st -> t1] ,[type-check-expr : e st -> t2])
            (let ([tipo_iden (if (equal? t1 'intarr) 'int (if (equal? t1 'boolarr) 'bool (if (equal? t1 'stringarr) 'string (error "Error en type-check-expr-arr-pos con " t1))))])
                (if (equal? t2 'int) tipo_iden (error "Error en type-check-expr-arr-pos-expr")))]
        ; revisar si sirve
        [(usop ,[type-check-expr : i st -> t1] (,[type-check-expr : e* st -> t2*] ...))
            (let* ([argumentos (if (list? t1) t1 (car t1))])
                (if (andmap equal? argumentos t2*)
                    (if (list? t1) 'UNIT (cdr t1))
                    (error "Error en type-check-expr-usop")))]
        ; revisar lo de arriba
        [(if-expr ,[type-check-expr : e1 st -> t1] ,[type-check-expr : e2 st -> t2] ,[type-check-expr : e3 st -> t3])
            (if (equal? t1 'bool)
                (if (equal? t2 t3) t2 (error "Error en type-check-expr-if-expr con " t2 " y " t3))
                (error "Error en type-check-expr-if-expr"))]
        [,as (type-check-asignacion as st)]
        [(len ,[type-check-expr : e st -> t1])
            (if (equal? t1 'intarr) 'int (if (equal? t1 'boolarr) 'int (if (equal? t1 'stringarr) 'int (error "Error en type-check-expr-len con " t1))))]
        [(arr (,[type-check-expr : e* st -> t1*] ...))
            (if (checar-lista-igual t1*)
                (if (equal? (first t1*) 'int) 
                'intarr
                (if (equal? (first t1*) 'bool) 
                'boolarr
                (if (equal? (first t1*) 'string) 
                'stringarr 
                (error "Error en type-check-expr-arr con checar-lista-igual"))))
            (error "Error en type-check-expr-arr"))]
        [(,op ,[type-check-expr : e1 st -> t1])
            (match op
                ['! (if (equal? t1 'bool) 'bool (error "Error en type-check-expr-!"))])]
        [(,op ,[type-check-expr : e1 st -> t1] ,[type-check-expr : e2 st -> t2])
            (match op
                ['+ (if (equal? t1 'int) (if (equal? t2 'int) 'int (error "Error en type-check-expr-+")) (error "Error en type-check-expr-+"))]
                ['- (if (equal? t1 'int) (if (equal? t2 'int) 'int (error "Error en type-check-expr--")) (error "Error en type-check-expr--"))]
                ['* (if (equal? t1 'int) (if (equal? t2 'int) 'int (error "Error en type-check-expr-*")) (error "Error en type-check-expr-*"))]
                ['/ (if (equal? t1 'int) (if (equal? t2 'int) 'int (error "Error en type-check-expr-/")) (error "Error en type-check-expr-/"))]
                ['% (if (equal? t1 'int) (if (equal? t2 'int) 'int (error "Error en type-check-expr-%")) (error "Error en type-check-expr-%"))]
                ['< (if (equal? t1 'int) (if (equal? t2 'int) 'bool (error "Error en type-check-expr-<")) (error "Error en type-check-expr-<"))]
                ['> (if (equal? t1 'int) (if (equal? t2 'int) 'bool (error "Error en type-check-expr->")) (error "Error en type-check-expr->"))]
                ['<= (if (equal? t1 'int) (if (equal? t2 'int) 'bool (error "Error en type-check-expr-<=")) (error "Error en type-check-expr-<="))]
                ['>= (if (equal? t1 'int) (if (equal? t2 'int) 'bool (error "Error en type-check-expr->=")) (error "Error en type-check-expr->="))]
                ['== (if (equal? t1 'int) (if (equal? t2 'int) 'bool (error "Error en type-check-expr-==")) (error "Error en type-check-expr-=="))]
                ['!= (if (equal? t1 'int) (if (equal? t2 'int) 'bool (error "Error en type-check-expr-!=")) (error "Error en type-check-expr-!="))]
                ['or (if (equal? t1 'bool) (if (equal? t2 'bool) 'bool (error "Error en type-check-expr-&&")) (error "Error en type-check-expr-&&"))]
                ['and (if (equal? t1 'bool) (if (equal? t2 'bool) 'bool (error "Error en type-check-expr-||")) (error "Error en type-check-expr-||"))])]
        [else (error "Error en type-check-expr")]))

; Metodo para checar el tipo de una constante
(define (type-check-const c)
    (if (number? c) 'int
        (if (booleano? c) 'bool
            (if (string? c) 'string
                (error "Error en type-check-const")))))

; Metodo para checar el tipo de un identificador
(define (type-check-id i st)
    (hash-ref st i))

; Metodo para verificar si una lista es igual
(define (checar-lista-igual l)
    (if (or (null? l) (equal? (length l) 1))
        #t
        (foldr (lambda (x y) (and y (equal? x (first l)))) #t (rest l))))

; Metodo para verificar si un programa tiene tipos correctos
(define (type-check ir st)
    (if (equal? (type-check-programa ir st) 'UNIT)
        #t 
        #f))

#| 
; Pruebas
;(define archivo "ejemplos/op.jly") ; funciona
;(define archivo "ejemplos/string.jly") ; funciona
;(define archivo "ejemplos/a.jly") ; funciona
(define archivo "ejemplos/in.jly") ; funciona
;(define archivo "ejemplos/dos.jly") ; funciona
(define prueba (ranme-var-archivo archivo))
(newline)
(display prueba)
(newline)
(newline)
(define prueba2 (symbol-table-sin prueba))
(display prueba2)
(newline)
(newline)
(define prueba3 (type-check prueba prueba2))
(display prueba3)
(newline)
|#

; Funcion que hace todo lo anterior
(define (type-check-archivo archivo)
    (define prueba (ranme-var-archivo archivo))
    (display prueba)
    (newline)
    (newline)
    (define prueba2 (symbol-table-sin prueba))
    (display prueba2)
    (newline)
    (newline)
    (define prueba3 (type-check prueba prueba2))
    (display prueba3)
    (newline)
    (newline))

;(type-check-archivo "ejemplos/in.jly") 