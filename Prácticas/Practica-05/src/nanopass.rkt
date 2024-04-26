#lang nanopass

;Definicion del lenguaje:
(define-language ejemplo
    (terminals
      (constante (c))
      (primitivo (pr))
      (tipo (t))
      (id (i)))
    (Programa (p)
        e
        meth
        (programa m meth))
    (Main (m)
        (main [e* ... e]))
    (Metodo (meth)
        (metodo i   ([i* t*] ...) t e))
    (Expr (e)
        c
        i
        pr
        (decl i t)
        (if-stn e0 e1 e2)
        (return e)
        (pr e0 e1)
        (e* ...)))



;Predicados necesarios para reconocer los terminales.
(define (id? c) (symbol? c))
(define (tipo? p) (memq p '(int bool)))
(define (primitivo? p) (memq p '(+ > = == !=)))
(define (constante? c) (or (number? c) (boolean? c)))

;Definición del parser del lenguaje ejemplo.
(define-parser parser-ejemplo ejemplo)




(define (get-symbol-table-met ir tb)
    (nanopass-case (ejemplo Metodo) ir
        [(metodo ,i   ([,i* ,t*] ...) ,t ,[get-symbol-table-exp : e tb -> *])
                                        (begin
                                            (hash-set! tb i (cons t t*))
                                            (map (lambda (id ty) (hash-set! tb id ty)) i* t*)
                                            tb)]))


(define (get-symbol-table-exp ir tb)
    (nanopass-case (ejemplo Expr) ir
        [,c tb]
        [,i tb]
        [,pr tb]
        [(decl ,i ,t) (hash-set! tb i t)]
        [(if-stn ,[e0] ,[e1] ,[e2]) tb]
        [(,[e*] ...) tb]
        [else tb]))



(define met-e (parser-ejemplo '(metodo gdc [(varu int)(vard int)] int ((if-stn (> varu vard) (+ vard varu) (decl zzz int))(return b)))))

(define yf (parser-ejemplo '(if-stn 1 (decl x int) (decl y bool))))


;Primer ejemplo del nanopass-case
(define (ejemplo1 ir)
    (nanopass-case (ejemplo Metodo) ir
        [(metodo ,i   ([,i* ,t*] ...) ,t  ,e) t*]))


#|Segundo ejemplo de un nanopass-case
  Nota como se pueden utilizar diferentes nanopass-case segun la variable|#
(define (vars-met ir)
   (nanopass-case (ejemplo Metodo) ir
        [(metodo ,i   ([,i* ,t*] ...) ,t  ,e) (let ([vars (mutable-set)])
                                                        (set-union! vars (list->mutable-set i*))
                                                        (set-union! vars (vars-exp e))
                                                        vars)]))



#|Tercer ejemplo de un nanopass-case
  Nota como se pueden utilizar diferentes nanopass-case segun la variable|#
(define (vars-exp ir)
   (nanopass-case (ejemplo Expr) ir
        [,i   (mutable-set i)]

        [(if-stn ,e0 ,e1 ,e2)  (let ([variables (mutable-set)])
                                    (set-union! variables (vars-exp e0))
                                    (set-union! variables (vars-exp e1))
                                    (set-union! variables (vars-exp e2))
                                    variables)]
        [(,pr ,e0 ,e1) (let ([variables (mutable-set)])
                                    (set-union! variables (vars-exp e0))
                                    (set-union! variables (vars-exp e1))
                                    variables)]
        [(return ,e) (vars-exp e)]
        [(,e* ... ,e) (let ([set-vars (mutable-set)])
                            (for-each (lambda (v) (set-union! set-vars v)) (map vars-exp e*))
                            (set-union! set-vars (vars-exp e))
                            set-vars)]
        [else (begin (display ir)
                     (print "caso else")
                     (mutable-set))])) ;<---- Dejar displays y prints sirve mucho
                                             ;para saber cuando esta cayendo en este caso
                                             ;o lo que esta llegando a algun caso.




;vars-exp pero con catamorfismos (Yo lo entiendo como "recursion colapsada" para nanopass)
(define (vars-exp-cat ir st)
  (nanopass-case (ejemplo Expr) ir
                 [,i                           (set-add! st i)]

                 [(if-stn ,[e0] ,[e1] ,[e2])   st]

                 [(,pr ,[e0] ,[e1])            st]

                 [(return ,[e])                st]

                 [(,[e*] ... ,[e])             st]
                 [else (begin (display ir)
                              (print "caso else")
                              (mutable-set))]))


(define inOsc (parser-ejemplo '((if-stn (> varu vard) (+ vard varu) (+ varu vard)) (return b))))

; entrada es el resultado de aplicar parsea2 a in.jly
(define entrada '(programa
                (main ((if-stn (> a b) (= j(+ 1 j)) (= i(+ 1 i))) (= i(+ 1 i)) (= j(+ 1 j))))
(metodo gdc [(varu int)(vard int)] int ((if-stn (> varu vard) (+ vard varu) (+ varu vard))(return b)))))

; entrada-p es el resultado de parsear con el lenguaje de nanopass a entrada
(define entrada-p (parser-ejemplo entrada))


;met es solo el metodo de entrada
(define met '(metodo gdc [(varu int)(vard int)] int ((if-stn (> varus vardz) (+ vard varu) (+ varu vard)) (return b))))

#|Para probar nuestra definicion hecha con nanopass-case primero parseamos con parser-ejemplo
  y despues llamamos a la funcion, en este caso se llama vars-met|#
(define variables-de-met (vars-met (parser-ejemplo met)))

;nanopass-case <-- A partir de una representacion intermedia, construir algo
;define-pass   <-- A partir de una representacion intermedia, construir otra representacion intermedia

(define c 0)

(define (nueva)
        (let* ([str-num (number->string c)]
               [str-sim (string-append "var_" str-num)]) ;var_0
               (set! c (add1 c))
               (string->symbol str-sim)))

(define (asigna vars)
        (let ([tabla (make-hash)])
             (set-for-each vars
                           (lambda (v) (hash-set! tabla v (nueva))))
             tabla))


(define-pass rename-var : ejemplo (ir) -> ejemplo ()
    (Metodo : Metodo (ir) -> Metodo ()
        [(metodo ,i   ([,i* ,t*] ...) ,t ,e) (let* ([vars  (vars-met ir)]
                                                    [tabla (asigna vars)]
                                                    [i*-n  (map (lambda (v) (Expr v tabla)) i*)]
                                                    [e-n  (Expr e tabla)])
                                                (println vars)
                                                (println tabla)
                                                (println "+++++++++")
                                                (println e)
                                                (println e-n)
                                                (println "+++++++++")
                                                `(metodo ,i   ([,i*-n ,t*] ...) ,t ,e)
                                                )])
    (Expr : Expr (ir h) -> Expr ()
        [,i `,(hash-ref h i)]
        [(return ,e) `(return ,(Expr e h))]
        [(,e* ...) `,(map (lambda (ir) (Expr ir h)) e*) ]
        [else (begin (print "caso else") ir)]))


