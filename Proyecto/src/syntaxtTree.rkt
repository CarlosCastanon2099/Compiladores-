#lang nanopass
(provide (all-defined-out))

(require "parser.rkt" "lexer.rkt")

(define (syntax-tree prog)
    (match prog
        [(tipo 'int) (symbol->string 'int)]
        [(tipo 'bool) (symbol->string 'bool)]
        [(tipo 'string) (symbol->string 'string)]
        [(tipo 'intarr) (symbol->string 'intarr)]
        [(tipo 'boolarr) (symbol->string 'boolarr)]
        [(tipo 'stringarr) (symbol->string 'stringarr)]
        ;[(cadena c) (string-append "\"" c "\"")]
        [(cadena c) c]
        [(booleano b) (if b "true" "false")]
        ;[(numero n) (number->string n)]
        [(numero n) n]
        [(arreglopos nombre posicion) (string-append "(arr-pos " (syntax-tree nombre) (syntax-tree posicion) ")")]
        [(iden i) i]
        ; ifpequej revisar
        [(ifpequej condicion expresionthen expresionelse) (string-append "(if-expr (" (syntax-tree condicion) ") " (syntax-tree expresionthen) " " (syntax-tree expresionelse) ")")]
        [(usoprocedimiento nombre parametros) (string-append "(" (syntax-tree nombre) " (" (syntax-tree parametros) "))")]
        [(longitud expresion) (string-append "(len " (syntax-tree expresion) ")")]
        [(operacionbinaria '+= expresion1 expresion2) (string-append "(= " (syntax-tree expresion1) " (+ " (syntax-tree expresion1) " " (syntax-tree expresion2) "))")]
        [(operacionbinaria '-= expresion1 expresion2) (string-append "(= " (syntax-tree expresion1) " (- " (syntax-tree expresion1) " " (syntax-tree expresion2) "))")]
        [(operacionbinaria operador expresion1 expresion2) (string-append "(" (symbol->string operador) " " (syntax-tree expresion1) " " (syntax-tree expresion2) ")")]
        [(operacionunaria '++ expresion) (string-append "(= " (syntax-tree expresion) " (+ " (syntax-tree expresion) " 1))")]
        [(operacionunaria '-- expresion) (string-append "(= " (syntax-tree expresion) " (- " (syntax-tree expresion) " 1))")]
        [(operacionunaria operador expresion) (string-append "(" (symbol->string operador) " " (syntax-tree expresion) ")")]
        ; asignacion multiple revisar
        [(asignacionmultiple nombres valor) (string-append "(= [" (syntax-tree nombres) "] " (syntax-tree valor) ")")]
        [(arreglo elementos) (string-append "(arr {" (syntax-tree elementos) "})")]
        [(asignaciontipo nombre tipo valor) (string-append "(= (" (syntax-tree nombre) " " (syntax-tree tipo) ") " (syntax-tree valor) ")")]
        [(asignacion nombre valor) (string-append "(= " (syntax-tree nombre) " " (syntax-tree valor) ")")]
        ; declaracion multiple revisar
        [(declaracionmultiple tipo nombres) (string-append "([" (syntax-tree nombres) "] " (syntax-tree tipo) ")")]
        [(declaracion nombre tipo) (string-append "(" (syntax-tree nombre) " " (syntax-tree tipo) ")")]
        [(ifj condicion lineasthen lineaselse) (string-append "(if " (syntax-tree condicion) " " (syntax-tree lineasthen) " " (syntax-tree lineaselse) ")")]
        [(while condicion lineas) (string-append "(while " (syntax-tree condicion) " {" (syntax-tree lineas) "})")]
        [(metodo nombre parametros tipo lineas regreso) (string-append "(" (syntax-tree nombre) " [" (syntax-tree parametros) "] " (syntax-tree tipo) " {" (syntax-tree lineas) " (return " (syntax-tree regreso) ")})")]
        [(funcion nombre parametros lineas) (string-append "(" (syntax-tree nombre) " [" (syntax-tree parametros) "] {" (syntax-tree lineas) "})")]
        [(main lineas) (string-append "(main {" (syntax-tree lineas) "})")]
        [(varglob variablesglobales) (syntax-tree variablesglobales)]
        [(programa varglob main procedimentos) (string-append "([" (syntax-tree varglob) "] " (syntax-tree main) " (" (syntax-tree procedimentos) "))")]
        ['() ""]
        [(cons a b) (string-append (syntax-tree a) " " (syntax-tree b))]))
        ;[else (error "No se puede convertir a string" prog)]))

(define (arbol in)
    (syntax-tree (parsea in)))

(define (arbolarch file)
    (syntax-tree (parseaarch file)))

(display "version normal\n")
(parseaarch "ejemplos/a.jly")
(display "\n")
(display "version nueva\n")
(arbolarch "ejemplos/a.jly")
