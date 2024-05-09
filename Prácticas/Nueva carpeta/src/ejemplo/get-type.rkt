#lang nanopass

(define-language ejemplo
    (terminals
      (constante (c))
      (primitivo (pr))
      (tipo (t))
      (var (x)))
    (Expr (e)
        c
        x
        pr
        (if-stn e0 e1 e2)
        (return e)
        (pr e0 e1)
        (e* ...)))

(define (var? c) (symbol? c))
(define (tipo? p) (memq p '(int bool)))
(define (primitivo? p) (memq p '(+ > =)))
(define (constante? c) (number? c))

(define-parser parser-ejemplo ejemplo)
(define st (make-hash '((var1 . bool) (var2 . unit) (var3 . unit))))
(define e0 (parser-ejemplo 54))
(define e1 (parser-ejemplo 'var1))
(define e2 (parser-ejemplo '(return var1)) )
(define e3 (parser-ejemplo '(if-stn var1 var2 var3)))

(define (get-type ir t)
  (nanopass-case (ejemplo Expr) ir
        [,c (if (integer? c) 'int
                (if (boolean? c) 'bool (error "No existe tipo para esta expr")))]
        [,x (hash-ref t x)]
        [(return ,e) (get-type e t)]
        [(if-stn ,e0 ,e1 ,e2) (let ([tg  (get-type e0 t)]
                                    [te1 (get-type e1 t)]
                                    [te2 (get-type e2 t)])
                                (if (and (eq? tg 'bool)
                                         (eq? te1 'unit)
                                         (eq? te2 'unit))
                                    'unit
                                    (error "error")))]
        [else (begin (display ir) 'unit)]))

; Para probar:
    ; (get-type e0 st)
    ; (get-type e1 st)
    ; (get-type e2 st)
    ; (get-type e3 st)