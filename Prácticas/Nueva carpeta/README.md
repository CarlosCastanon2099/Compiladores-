<div align="center">

#  **Practica 6** 

# **Sistema de Tipos**

# 🖥️ **Equipo Azul** 🛡️

**Carlos Emilio Castañón Maldonado** ~ **Dafne Bonilla Reyes** ~ **José Camilo Garcia Ponce**  ~ **Jorge Velasco García**

</div>


<div align="center">

[![](https://media.tenor.com/nCmws_LoEG8AAAAi/pokemon-eeveelution.gif)](https://www.youtube.com/watch?v=EU0LljxpHIk)

</div>

---

## **En esta practica implementamos:**

${\color{red}➣}$ Un proceso llamado type-check que se encargue de que
dado un programa parseado y su respectiva tabla de símbolos, verifique que tipos de las expresiones y
las sentencias sean correctos.

-------------

Los ejemplos de jelly se encuentran en:

```Python
         _nnnn_                      
        dGGGGMMb     ,"""""""""""""""""""""""""""""""""""""""""".
       @p~qp~~qMb    |               src/ejemplos/              |
       M|@||@) M|   _;..........................................'
       @,----.JM| -'
      JS^\__/  qKL
     dZP        qKRb
    dZP          qKKb
   fZP            SMMb
   HZM            MMMM
   FqM            MMMM
 __| ".        |\dS"cecm
 |    `.       | `' \Zq
_)      \.___.,|     .'
\____   )MMMMMM|   .'
     `-'       `--' dbr
```

<!---
ASCII recuperado de https://www.asciiart.eu/computers/linux
-->

--------

## **Uso:**

Para hacer uso de lo implementado en la practica:
- Compilar desde `src/`:

```Kotlin
\src> racket --repl --eval '(enter! (file \"tipos.rkt\"))'
```

- Ejecutar desde `src/tipos.rkt`:

```Python
Welcome to Racket v8.11.1 [cs].
4 shift/reduce conflicts
"tipos.rkt"> (type-check-archivo "ruta-archivo")
```

- Ejemplo de uso con:

```Python
\ejemplos\in.jly
```

En donde el contenido de in es:

```Java
//Comentario 1

main{
    zzzz:int = 0
    1+1
    i:int = zzzz++
    zzzz += 1
    zzz:int = 1
    r:int = gdc(i,zzz)
}

{- Comentario 2
   Comentario 2 -}

gdc(var1:int, var2:int): int{
    while var1 != 0 {
        if (var1 < var2) var2 = var2 - var1
        else var1 = var1 - var2
    }
    b:int = 10
    return b
}
sort(a:int[]){
    i:int = 0
    n:int = len(a)
    
    while i < n {
        j:int = i
        while j > 0 {
            if a[j-1] > a[j] {
                swap:int = a[j]
                a[j] = a[j-1]
                a[j-1] = swap
            }
            j--
        }
        i++
    }
}
```

```Python
src> racket --repl --eval '(enter! (file \"tipos.rkt\"))'
Welcome to Racket v8.11.1 [cs].
4 shift/reduce conflicts
"tipos.rkt"> (type-check-archivo "ejemplos/in.jly")
#<language:jelly: (() (main ((= variable_bonita_2 int 0) (+ 1 1) (= variable_bonita_1 int (= variable_bonita_2 (+ variable_bonita_2 1))) (= variable_bonita_2 (+ variable_bonita_2 1)) (= variable_bonita_0 int 1) (= variable_bonita_3 int (usop gdc (variable_bonita_1 variable_bonita_0))))) ((metodo gdc ((: variable_bonita_4 int) (: variable_bonita_6 int)) int ((whilejly (!= variable_bonita_4 0) ((ifjly (< variable_bonita_4 variable_bonita_6) ((= variable_bonita_6 (- variable_bonita_6 variable_bonita_4))) ((= variable_bonita_4 (- variable_bonita_4 variable_bonita_6)))))) (= variable_bonita_5 int 10)) (return variable_bonita_5)) (funcion sort ((: variable_bonita_10 intarr)) ((= variable_bonita_9 int 0) (= variable_bonita_7 int (len variable_bonita_10)) (whilejly (< variable_bonita_9 variable_bonita_7) ((= variable_bonita_11 int variable_bonita_9) (whilejly (> variable_bonita_11 0) ((ifjly (> (arr-pos variable_bonita_10 (- variable_bonita_11 1)) (arr-pos variable_bonita_10 variable_bonita_11)) ((= variable_bonita_8 int (arr-pos variable_bonita_10 variable_bonita_11)) (= (arr-pos variable_bonita_10 variable_bonita_11) (arr-pos variable_bonita_10 (- variable_bonita_11 1))) (= (arr-pos variable_bonita_10 (- variable_bonita_11 1)) variable_bonita_8)) ()) (= variable_bonita_11 (- variable_bonita_11 1)))) (= variable_bonita_9 (+ variable_bonita_9 1))))))))>

#hash((gdc . ((int int) . int)) (sort . (intarr)) (variable_bonita_0 . int) (variable_bonita_1 . int) (variable_bonita_10 . intarr) (variable_bonita_11 . int) (variable_bonita_2 . int) (variable_bonita_3 . int) (variable_bonita_4 . int) (variable_bonita_5 . int) (variable_bonita_6 . int) (variable_bonita_7 . int) (variable_bonita_8 . int) (variable_bonita_9 . int))

#t
```

Como podemos observar en el ejemplo anterior hemos tenido como resultado final `#t` lo cual nos indica que llego con exito a `UNIT`.

Nota, aquellos archivos que no tengan `main`  no deberían poder compilar. 
