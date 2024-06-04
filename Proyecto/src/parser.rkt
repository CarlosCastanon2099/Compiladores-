#lang nanopass
(provide (all-defined-out))

(require "lexer.rkt"
         parser-tools/yacc)

(define-struct programa (varglob main procedimentos) #:transparent)
(define-struct varglob (variablesglobales) #:transparent)
(define-struct main (lineas) #:transparent)
(define-struct funcion (nombre parametros lineas) #:transparent)
(define-struct metodo (nombre parametros tipo lineas regreso) #:transparent)
(define-struct while (condicion lineas) #:transparent)
(define-struct ifj (condicion lineasthen lineaselse) #:transparent)
(define-struct declaracion (nombre tipo) #:transparent)
(define-struct declaracionmultiple (tipo nombres) #:transparent)
(define-struct asignacion (nombre valor) #:transparent)
(define-struct asignaciontipo (nombre tipo valor) #:transparent)
(define-struct arreglo (elementos) #:transparent)
(define-struct asignacionmultiple (nombres valor) #:transparent)
(define-struct operacionunaria (operador expresion) #:transparent)
(define-struct operacionbinaria (operador expresion1 expresion2) #:transparent)
(define-struct longitud (expresion) #:transparent)
(define-struct usoprocedimiento (nombre parametros) #:transparent)
(define-struct ifpequej (condicion expresionthen expresionelse) #:transparent)
(define-struct iden (i) #:transparent)
(define-struct arreglopos (nombre posicion) #:transparent)
(define-struct numero (n) #:transparent)
(define-struct booleano (b) #:transparent)
(define-struct cadena (c) #:transparent)
(define-struct tipo (t) #:transparent)

; version con 3 conflictos
(define jelly-parser
    (parser
        [start programa]
        [end EOF]
        [tokens contenedores vacios]
        [error (lambda (valido? nombre valor) (raise-syntax-error 'error "Hubo un error de parseo con el token: " (if valor valor nombre)))]
        [precs
            (nonassoc NOT OPENP CLOSEP OPENB CLOSEB)
            (left AUTOINC AUTODEC)
            (left QUESM DDOT)
            (left OR)
            (left AND)
            (left EQ NEQ)
            (left GTEQ GT LTEQ LT)
            (left SUBS) ; cabmio: arreglo a la precedencia aritmetica
            (left ADD)
            (left MULTI DIV MOD)
            (right ASG)
            (left ADDASG SUBSASG)]
        [grammar
            [programa
                [(funcionmain) (programa empty $1 empty)]
                [(funcionmain procedimientos) (programa empty $1 $2)]
                [(varglob funcionmain) (programa $1 $2 empty)]
                [(varglob funcionmain procedimientos) (programa $1 $2 $3)]]
            [varglob
                [(asignaciones) (varglob $1)]]
            [asignaciones
                [(asignacionespecial) (list $1)]
                ;[(declaracionnormal) (list $1)] ; cambio: arreglo para solo asignaciones en var glob
                [(asignacionespecial asignaciones) (list* $1 $2)]
                ;[(declaracionnormal asignaciones) (list* $1 $2)] ; cambio: arreglo para solo asignaciones en var glob
                ]
            [funcionmain
                ;[(MAIN OPENB CLOSEB) (main empty)] ; cambio: quitar cosas con bloqueas vacios
                [(MAIN OPENB lineas CLOSEB) (main $3)]]
            [procedimientos
                [(metodo) (list $1)]
                [(funcion) (list $1)]
                [(metodo procedimientos) (list* $1 $2)]
                [(funcion procedimientos) (list* $1 $2)]]
            [funcion
                ;[(identificador OPENP CLOSEP OPENB CLOSEB) (funcion $1 empty empty)] ; cambio: quitar cosas con bloqueas vacios
                [(identificador OPENP CLOSEP OPENB lineas CLOSEB) (funcion $1 empty $5)]
                ;[(identificador OPENP parametros CLOSEP OPENB CLOSEB) (funcion $1 $3 empty)] ; cambio: quitar cosas con bloqueas vacios
                [(identificador OPENP parametros CLOSEP OPENB lineas CLOSEB) (funcion $1 $3 $6)]]
            [metodo
                [(identificador OPENP CLOSEP DDOT tipo OPENB RETURN expresion CLOSEB) (metodo $1 empty $5 empty $8)]
                [(identificador OPENP CLOSEP DDOT tipo OPENB lineas RETURN expresion CLOSEB) (metodo $1 empty $5 $7 $9)]
                [(identificador OPENP parametros CLOSEP DDOT tipo OPENB RETURN expresion CLOSEB) (metodo $1 $3 $6 empty $9)]
                [(identificador OPENP parametros CLOSEP DDOT tipo OPENB lineas RETURN expresion CLOSEB) (metodo $1 $3 $6 $8 $10)]]
            [parametros
                [(declaracionnormal) (list $1)]
                [(declaracionnormal COMA parametros) (list* $1 $3)]]
            [ifj
                ;[(IF expresion OPENB CLOSEB) (ifj $2 empty empty)] ; cambio: quitar cosas con bloqueas vacios
                [(IF expresion OPENB lineas CLOSEB) (ifj $2 $4 empty)]
                ;[(IF OPENP expresion CLOSEP linea ELSE linea) (ifj $3 $5 $7)] ; cambio: original para arreglo de aceptar ( ) ???
                [(IF expresion linea ELSE linea) (ifj $2 $3 $5)] ; cambio: modificacion para arreglo de aceptar ( ) ???
                ;[(IF OPENP expresion CLOSEP OPENB CLOSEB ELSE OPENB CLOSEB) (ifj $3 empty empty)] ; cambio: quitar cosas con bloqueas vacios
                ;[(IF OPENP expresion CLOSEP OPENB CLOSEB ELSE OPENB lineas CLOSEB) (ifj $3 empty $9)] ; cambio: quitar cosas con bloqueas vacios
                ;[(IF OPENP expresion CLOSEP OPENB lineas CLOSEB ELSE OPENB CLOSEB) (ifj $3 $6 empty)] ; cambio: quitar cosas con bloqueas vacios
                ;[(IF OPENP expresion CLOSEP OPENB lineas CLOSEB ELSE OPENB lineas CLOSEB) (ifj $3 $6 $10)] ; cambio: original para arreglo de aceptar ( ) ???
                [(IF expresion OPENB lineas CLOSEB ELSE OPENB lineas CLOSEB) (ifj $2 $4 $8)] ; cambio: modificacion para arreglo de aceptar ( ) ???
                ]
            [while
                ;[(WHILE expresion OPENB CLOSEB) (while $2 empty)] ; cambio: quitar cosas con bloqueas vacios
                [(WHILE expresion OPENB lineas CLOSEB) (while $2 $4)]
                #| cambio: modificacion para arreglo de aceptar ( ) ???
                [(WHILE OPENP expresion CLOSEP OPENB CLOSEB) (while $3 empty)]
                [(WHILE OPENP expresion CLOSEP OPENB lineas CLOSEB) (while $3 $6)]
                |#
                ]
            [lineas
                [(linea) (list $1)]
                [(linea lineas) (list* $1 $2)]]
            [linea
                [(while) $1]
                [(ifj) $1]
                [(declaracion) $1]
                [(asignacion) $1]
                ; conflictos lo de abajo (si se quita OPENB expresion CLOSEB, se quitan los conflictos)
                [(expresion) $1]]
                ; conflictos lo de arriba
            [declaracion
                [(declaracionnormal) $1]
                [(declaracionmultiple) $1]]
            [declaracionnormal
                [(identificador DDOT tipo) (declaracion $1 $3)]]
            [declaracionmultiple
                [(tipo identificadores) (declaracionmultiple $1 $2)]]
            [asignacion
                [(asignacionnormal) $1]
                [(asignacionespecial) $1]
                [(asignacionmultiple) $1]]
            [asignacionnormal
                [(identificador ASG expresion) (asignacion $1 $3)]
                [(arrpos ASG expresion) (asignacion $1 $3)]]
            [asignacionespecial
                [(asignaciontipo) $1]
                [(asignacionarr) $1]]
            [asignaciontipo
                [(identificador DDOT tipo ASG expresion) (asignaciontipo $1 $3 $5)]]
            [asignacionarr
                [(identificador DDOT tipo ASG OPENB CLOSEB) (asignaciontipo $1 $3 (arreglo empty))]
                [(identificador DDOT tipo ASG OPENB expresiones CLOSEB) (asignaciontipo $1 $3 (arreglo $6))]]
            [asignacionmultiple
                [(asignacionvarias ASG expresion) (asignacionmultiple $1 $3)]]
            [asignacionvarias
                [(identificador ASG identificador) (list $1 $3)]
                [(identificador ASG asignacionvarias) (list* $1 $3)]]
            [expresiones
                [(expresion) (list $1)]
                [(expresion COMA expresiones) (list* $1 $3)]]
            [expresion
                ; causa conflictos lo de abajo
                [(OPENP expresion CLOSEP) $2]
                ; causa conflictos lo de arriba
                [(longitud) $1]
                [(identificador) $1]
                [(arrpos) $1]
                [(numero) $1]
                [(booleano) $1]
                [(cadena) $1]
                [(usoproc) $1]
                [(expresion QUESM expresion DDOT expresion) (ifpequej $1 $3 $5)]
                [(NOT expresion) (operacionunaria '! $2)]
                [(expresion AUTOINC) (operacionunaria '++ $1)]
                [(expresion AUTODEC) (operacionunaria '-- $1)]
                [(expresion EQ expresion) (operacionbinaria '== $1 $3)]
                [(expresion NEQ expresion) (operacionbinaria '!= $1 $3)]
                [(expresion GTEQ expresion) (operacionbinaria '>= $1 $3)]
                [(expresion GT expresion) (operacionbinaria '> $1 $3)]
                [(expresion LTEQ expresion) (operacionbinaria '<= $1 $3)]
                [(expresion LT expresion) (operacionbinaria '< $1 $3)]
                [(expresion OR expresion) (operacionbinaria 'or $1 $3)]
                [(expresion AND expresion) (operacionbinaria 'and $1 $3)]
                [(expresion ADDASG expresion) (operacionbinaria '+= $1 $3)]
                [(expresion SUBSASG expresion) (operacionbinaria '-= $1 $3)]
                [(expresion ADD expresion) (operacionbinaria '+ $1 $3)]
                [(expresion SUBS expresion) (operacionbinaria '- $1 $3)]
                [(expresion MULTI expresion) (operacionbinaria '* $1 $3)]
                [(expresion DIV expresion) (operacionbinaria '/ $1 $3)]
                [(expresion MOD expresion) (operacionbinaria '% $1 $3)]]
            [longitud
                [(LENGTH OPENP OPENB CLOSEB CLOSEP) (longitud (arreglo empty))]
                [(LENGTH OPENP identificador CLOSEP) (longitud $3)]
                [(LENGTH OPENP OPENB expresiones CLOSEB CLOSEP) (longitud (arreglo $4))]]
            [usoproc
                [(identificador OPENP CLOSEP) (usoprocedimiento $1 empty)]
                [(identificador OPENP expresiones CLOSEP) (usoprocedimiento $1 $3)]]
            [identificadores
                [(identificador) (list $1)]
                [(identificador COMA identificadores) (list* $1 $3)]]
            [identificador
                [(IDEN) (iden $1)]]
            [arrpos
                [(identificador OPENRP expresion CLOSERP) (arreglopos $1 $3)]]
            [tipo
                [(TINT) (tipo 'int)]
                [(TBOOL) (tipo 'bool)]
                [(TSTRING) (tipo 'string)]
                [(TAINT) (tipo 'intarr)]
                [(TABOOL) (tipo 'boolarr)]
                [(TASTRING) (tipo 'stringarr)]]
            [numero
                [(NUM) (numero $1)]]
            [booleano
                [(BOOL) (booleano $1)]]
            [cadena
                [(STRING) (cadena $1)]]]))

(define (lex-this lexer input) (lambda () (lexer input)))

(define (parsea in)
    (let ([in-s (open-input-string in)])
    (jelly-parser (lex-this jelly-lex in-s))))

(define (parseaarch file)
    (let ([in-s (open-input-file file)])
    (jelly-parser (lex-this jelly-lex in-s))))

;(parseaarch "ejemplos/string.jly")
;(parseaarch "ejemplos/in.jly")
;(parsea "main{i:int = 2 + 4 * 5zzzz += 1r:int = gdc(i,zzz)}")
;(parseaarch "ejemplos/op.jly")
