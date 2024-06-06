#lang nanopass
(provide (all-defined-out))

(require "types.rkt" "symbolTable-renameVar.rkt" racket/cmdline)


; Metodos para cosas de variables

; Quita el corchete y todo lo que sigue de una variable
(define (quitar-pos var)
  (define (buscar-corchete str index)
    (cond
      [(>= index (string-length str)) (string-length str)] ; No se encontro '['
      [(char=? (string-ref str index) #\[) index] ; Se encontro '['
      [else (buscar-corchete str (+ index 1))])) ; Seguir buscando en la siguiente posicion
  (let ([pos (buscar-corchete var 0)])
    (substring var 0 pos))) ; Obtener la subcadena desde el inicio hasta la posición encontrada

; Hash table para guardar las variables ya declaradas
(define declaradas (make-hash))

; Metodo para ver si una variable ya fue declarada, en caso de que si, regresa el tipo de la variable, en caso contrario regresa #f
(define (declarada? var)
    (hash-ref declaradas (quitar-pos var) #f))

; Metodo para declarar una variable
(define (declarar var tipo)
    (hash-set! declaradas var tipo))

; Metodo para ver si un tipo es un arreglo
(define (es-arreglo? tipo)
    (or (equal? tipo "int[]") (equal? tipo "bool[]") (equal? tipo "string[]")))


; Metodo para traducir un programa

; Obtener la version de un programa en Java
(define (traducir-programa ir clase)
    (nanopass-case (jelly Programa) ir
        [((,[traducir-asesp : ase* -> ase1] ...) ,[traducir-main : m -> m1] (,[traducir-proc : pc* -> pc1] ...)) 
            (string-append "public class " clase " {\n\n" (lista-str-prefijo-todo ase1 ";\n" "public static ") "\n" m1 "\n\n" (lista-str-todo pc1 "\n\n") "}")]
        [else (error 'traducir-programa "No se puede traducir el programa")]))

; Obtener la version de un main en Java
(define (traducir-main ir)
    (nanopass-case (jelly Main) ir
        [(main (,[traducir-linea : ln -> ln1] ...)) 
            (string-append "public static void main(String[] args) {\n" (lista-str-todo ln1 ";\n") "}")]
        [else (error 'traducir-main "No se puede traducir el main")]))

; Obtener la version de un procedimiento en Java
(define (traducir-proc ir)
    (nanopass-case (jelly Proc) ir
        [,fnc (traducir-funcion fnc)]
        [,mtd (traducir-metodo mtd)]
        [else (error 'traducir-proc "No se puede traducir el procedimiento")]))

; Obtener la version de una funcion en Java
(define (traducir-funcion ir)
    (nanopass-case (jelly Funcion) ir
        [(funcion ,i (,[traducir-declaracion : dec* -> d1] ...) (,[traducir-linea : ln* -> l1] ...)) 
            (string-append "public static void " (symbol->string i) "(" (lista-str d1 ", ") ") {\n" (lista-str-todo l1 ";\n") "}")]
        [else (error 'traducir-funcion "No se puede traducir la funcion")]))

; Obtener la version de un metodo en Java
(define (traducir-metodo ir)
    (nanopass-case (jelly Metodo) ir
        [(metodo ,i (,[traducir-declaracion : dec* -> d1] ...) ,t (,[traducir-linea : ln* -> l1] ...) ,[traducir-return : rtn -> r1])
            (string-append "public static " (traducir-tipo t) " " (symbol->string i) "(" (lista-str d1 ", ") ") {\n" (lista-str-todo l1 ";\n") r1 ";\n}")]
        [else (error 'traducir-metodo "No se puede traducir el metodo")]))

; Obtener la version de un return en Java
(define (traducir-return ir)
    (nanopass-case (jelly Return) ir
        [(return ,[traducir-expr : e -> e1]) (string-append "return " e1)]
        [else (error 'traducir-return "No se puede traducir el return")]))

; Obtener la version de una linea en Java
(define (traducir-linea ir)
    (nanopass-case (jelly Linea) ir
        [(whilejly ,[traducir-expr : e -> e1] (,[traducir-linea : ln* -> l1] ...))
            (string-append "while (" e1 ") {\n" (lista-str-todo l1 ";\n") "}")]
        [(ifjly ,[traducir-expr : e -> e1] (,[traducir-linea : ln1* -> l3] ...) (,[traducir-linea : ln2* -> l4] ...))
            (string-append "if (" e1 ") {\n" (lista-str-todo l3 ";\n") "} else {\n" (lista-str-todo l4 ";\n") "}")]
        [(printjly ,[traducir-expr : e -> e1])
            (string-append "System.out.println(" e1 ")")]
        [,dec (traducir-declaracion dec)]
        [,as (traducir-asignacion as)]
        [,e (traducir-expr e)]
        [else (error 'traducir-linea "No se puede traducir la linea")]))

; Obtener la version de una declaracion en Java
(define (traducir-declaracion ir)
    (nanopass-case (jelly Declaracion) ir
        [(: ,i ,t)
            (let* ([tipo (traducir-tipo t)]
                [identificador (symbol->string i)])
                (if (declarada? identificador)
                    (error 'traducir-declaracion "Variable ya declarada")
                    (begin
                        (declarar identificador tipo)
                        (string-append tipo " " (symbol->string i)))))]
        [else (error 'traducir-declaracion "No se puede traducir la declaracion")]))

; Obtener la version de una asignacion en Java
(define (traducir-asignacion ir)
    (nanopass-case (jelly Asignacion) ir
        [(= ,[traducir-expr : e1 -> e3] ,[traducir-expr : e2 -> e4])
            (if (declarada? e3)
                (string-append e3 " = " e4)
                (error 'traducir-asignacion (string-append "Variable no declarada: " e3)))]
        [,ase (traducir-asesp ase)]
        [else (error 'traducir-asignacion "No se puede traducir la asignacion")]))

; Obtener la version de una asignacion especial en Java
(define (traducir-asesp ir)
    (nanopass-case (jelly AsigEspecial) ir
        [(= ,i ,t ,[traducir-expr : e -> e1])
            (let* ([tipo (traducir-tipo t)]
                [identificador (symbol->string i)])
                (if (declarada? identificador)
                    (if (es-arreglo? tipo)
                        (string-append (symbol->string i) " = new " tipo e1)
                        (string-append (symbol->string i) " = " e1))
                    (begin
                        (declarar identificador tipo)
                        (if (es-arreglo? tipo)
                            (string-append tipo " " (symbol->string i) " = " e1)
                            (string-append tipo " " (symbol->string i) " = " e1)))))]
        [else (error 'traducir-asesp "No se puede traducir la asignacion especial")]))

; Obtener la version de una expresion en Java
(define (traducir-expr ir)
    (nanopass-case (jelly Expr) ir
        [,c (traducir-const c)]
        [,i (symbol->string i)]
        ; TODO: Agregar los demas casos
        [(arr-pos ,[traducir-expr : i -> i1] ,[traducir-expr : e -> e1])
            (string-append i1 "[" e1 "]")]
        [(usop ,[traducir-expr : i -> i1] (,[traducir-expr : e* -> e2] ...))
            (string-append i1 "(" (lista-str e2 ", ") ")")]
        [(if-expr ,[traducir-expr : e1 -> e4] ,[traducir-expr : e2 -> e5] ,[traducir-expr : e3 -> e6])
            (string-append e4 " ? " e5 " : " e6)]
        [,as (traducir-asignacion as)]
        [(len ,[traducir-expr : e -> e1])
            (string-append e1 ".length")]
        [(arr (,[traducir-expr : e* -> e1] ...))
            (string-append "{" (lista-str e1 ", ") "}")]
        [(,op ,[traducir-expr : e1 -> e2])
            (match op
                ['! (string-append "!" e2)])]
        [(,op ,[traducir-expr : e1 -> e3] ,[traducir-expr : e2 -> e4])
            (match op
                ['+ (string-append e3 " + " e4)]
                ['- (string-append e3 " - " e4)]
                ['* (string-append e3 " * " e4)]
                ['/ (string-append e3 " / " e4)]
                ['% (string-append e3 " % " e4)]
                ['< (string-append e3 " < " e4)]
                ['> (string-append e3 " > " e4)]
                ['<= (string-append e3 " <= " e4)]
                ['>= (string-append e3 " >= " e4)]
                ['== (string-append e3 " == " e4)]
                ['!= (string-append e3 " != " e4)]
                ['or (string-append e3 " || " e4)]
                ['and (string-append e3 " && " e4)])]
        [else (error 'traducir-expr "No se puede traducir la expresion")]))

; Obtener la version de una constante en Java
(define (traducir-const c)
    (if (number? c)
        (number->string c)
        (if (booleano? c)
            (if c
                "true"
                "false")
            (if (string? c)
                (string-append "\"" c "\"")
                (error 'traducir-const "No se puede traducir la constante")))))

; Metodos para cosas de texto

; Obtiene en texto una lista de strings separados por un separador
(define (lista-str lista separador)
  (if (empty? lista)
      ""
      (if (null? (cdr lista))
          (car lista)
          (let* ([invertida (reverse lista)]
                [first (car invertida)]
                [rest (cdr invertida)]
                [resultado (foldl (lambda (x y)
                    (string-append x separador y))
                        first
                        rest)])
            (string-append resultado)))))

; Obtiene en texto una lista de strings separados por un separador (aplicando el separador a todos los elementos)
(define (lista-str-todo lista separador)
    (if (empty? lista)
        ""
        (let* ([invertida (reverse lista)]
                [first (car invertida)]
                [rest (cdr invertida)]
                [resultado (foldl (lambda (x y)
                    (string-append x separador y))
                        first
                        rest)])
            (string-append resultado separador))))

; Obtiene en texto una lista de strings separados por un separador y un prefijo
(define (lista-str-prefijo lista separador prefijo)
    (if (empty? lista)
        ""
        (if (null? (cdr lista))
            (string-append prefijo (car lista))
            (let* ([invertida (reverse lista)]
                    [elementos-prefijo (map (lambda (x) (string-append prefijo x)) invertida)]
                    [resultado (foldl (lambda (x y)
                        (string-append x separador y))
                            (car elementos-prefijo)
                            (cdr elementos-prefijo))])
                (string-append resultado)))))

; Obtiene en texto una lista de strings separados por un separador y un prefijo (aplicando el prefijo a todos los elementos)
(define (lista-str-prefijo-todo lista separador prefijo)
    (if (empty? lista)
        ""
        (let* ([invertida (reverse lista)]
                [elementos-prefijo (map (lambda (x) (string-append prefijo x)) invertida)]
                [resultado (foldl (lambda (x y)
                    (string-append x separador y))
                        (car elementos-prefijo)
                        (cdr elementos-prefijo))])
            (string-append resultado separador))))

; Obtiene en texto un tipo
(define (traducir-tipo t)
    (match t
        ['int "int"]
        ['bool "boolean"]
        ['string "String"]
        ['intarr "int[]"]
        ['boolarr "boolean[]"]
        ['stringarr "String[]"]
        [else (error 'traducir-tipo "No se puede traducir el tipo")]))

#|
; Pruebas
;(define archivo "ejemplos/op.jly") ; funciona
;(define archivo "ejemplos/string1.jly") ; funciona 
;(define archivo "ejemplos/a.jly") ; funciona
(define archivo "ejemplos/b.jly") ; funciona
;(define archivo "ejemplos/in.jly") ; funciona
;(define archivo "ejemplos/dos.jly") ; funciona
(define nombre "Programa")
(define prueba (ranme-var-archivo archivo))
;(newline)
;(display prueba)
;(newline)
;(newline)
(define prueba2 (symbol-table-sin prueba))
(define prueba3 (type-check prueba prueba2))
(define prueba4 (traducir-programa prueba nombre))
;(display prueba4)
; guardar en archivo de salida, si el archivo no existe lo crea y si ya existe lo borra y crea uno nuevo
(call-with-output-file (string-append nombre ".java")
    (lambda (out)
        (display prueba4 out))
    #:exists 'replace)
|#

; Compilar archivo
(define (compilar-archivo nombre)
    (validar-archivo nombre)
    (define nuevo-nombre (quitar-terminacion (primera-letra-mayuscula (quitar-antes-diagonal nombre))))
    (define prueba (ranme-var-archivo nombre))
    (define prueba2 (symbol-table-sin prueba))
    (define prueba3 (type-check prueba prueba2))
    (define prueba4 (traducir-programa prueba nuevo-nombre))
    (call-with-output-file (string-append nuevo-nombre ".java")
        (lambda (out)
            (display prueba4 out))
        #:exists 'replace)
    (display "Archivo generado: ")
    (display (string-append nuevo-nombre ".java"))
    (newline))

; Metodo para poner la primera letra de una cadena en mayuscula
(define (primera-letra-mayuscula str)
    (string-append (string-upcase (substring str 0 1)) (substring str 1 (string-length str))))

; Metodo para quitar la terminacion .jly de una cadena
(define (quitar-terminacion str)
    (substring str 0 (- (string-length str) 4)))

; Metodo para quitar todo lo que esta antes de la ultima diagonal de una cadena
(define (quitar-antes-diagonal str)
    (define (buscar-ultima-diagonal str index last-pos)
        (if (>= index (string-length str))
            last-pos
        (if (char=? (string-ref str index) #\/)
            (buscar-ultima-diagonal str (+ index 1) index)
            (buscar-ultima-diagonal str (+ index 1) last-pos))))
    (let ([pos (buscar-ultima-diagonal str 0 -1)])
        (if (= pos -1)
            str
            (substring str (+ pos 1)))))

; Metodo para revisar si la extension del archivo es .jly
(define (validar-archivo nombre)
    (if (string=? (substring nombre (- (string-length nombre) 4)) ".jly")
        #t
        (error 'validar-archivo "El archivo no tiene la extension .jly")))

; Pruebas 2
;(compilar-archivo "ejemplos/dos.jly")

(command-line
    #:program "transform.rkt"
    #:args (nombre-archivo)
    "Compilar archivo especificado"
    (compilar-archivo nombre-archivo))