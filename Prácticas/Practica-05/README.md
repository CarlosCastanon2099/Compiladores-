[![Review Assignment Due Date](https://classroom.github.com/assets/deadline-readme-button-24ddc0f5d75046c5622901739e7c5dd533143b0c8e959d652212380cedb1ea36.svg)](https://classroom.github.com/a/QZV_C9WU)

<div align="center">
  

# **Práctica 5**

# **Tabla de Símbolos.**


---

# 🖥️ **Equipo Azul** 🛡️

</div>


<div align="center">

<b> Carlos Emilio Castañón Maldonado ~ Dafne Bonilla Reyes ~ José Camilo Garcia Ponce  ~ Jorge Velasco García

</div>




<div align="center">

[![](https://media1.tenor.com/m/ZAMoMuQgf9UAAAAd/mapache-pedro.gif)](https://www.youtube.com/watch?v=y4CxfgMdGNE)

</div>

-------------

## **En esta practica implementamos:**

➣ Un proceso ranme-var que renombre las variables de un programa.

➣ Un proceso para generar la tabla de símbolos de un programa symbol-table (este proceso se aplica después de rename-var).

-------------

Los ejemplos de jelly se encuentran en:

```Python
         _nnnn_                      
        dGGGGMMb     ,"""""""""""""""""""""""""""""""""""""""""".
       @p~qp~~qMb    |         Practica-05/src/ejemplos/        |
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
\src> racket --repl --eval '(enter! (file \"symbolTable-renameVar.rkt\"))'
```

- Ejecutar desde `src/symbolTable-renameVar.rkt`:

```Python
Welcome to Racket v8.11.1 [cs].
4 shift/reduce conflicts
"symboltable-renamevar.rkt"> (ranme-var-archivo "Ruta-Archivo")
```

Seguido de:
```Kotlin
"symboltable-renamevar.rkt"> (symbol-table-archivo "Ruta-Archivo")
```

- Ejemplo de uso con:

```Python
\ejemplos\in.jly
```

En donde el contenido de in es:

```Java
//Comentario 1

main{
    1+1
    i:int = zzzz++
    zzzz += 1
    r:int = gdc(i,zzz)
}

{- Comentario 2
   Comentario 2 -}

gdc(var1:int, var2:int): int{
    while var1 != 0 {
        if (var1 < var2) var2 = var2 - var1
        else var1 = var1 - var2
    }
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
\src> racket --repl --eval '(enter! (file \"symbolTable-renameVar.rkt\"))'
Welcome to Racket v8.11.1 [cs].
4 shift/reduce conflicts
"symboltable-renamevar.rkt"> (ranme-var-archivo "ejemplos/in.jly")
(language:jelly
 '(()
   (main
    ((+ 1 1)
     (= variable_bonita_7 int (= variable_bonita_8 (+ variable_bonita_8 1)))
     (= variable_bonita_8 (+ variable_bonita_8 1))
     (=
      variable_bonita_9
      int
      (usop gdc (variable_bonita_7 variable_bonita_1)))))
   ((metodo
     gdc
     ((: variable_bonita_5 int) (: variable_bonita_4 int))
     int
     ((whilejly
       (!= variable_bonita_5 0)
       ((ifjly
         (< variable_bonita_5 variable_bonita_4)
         ((= variable_bonita_4 (- variable_bonita_4 variable_bonita_5)))
         ((= variable_bonita_5 (- variable_bonita_5 variable_bonita_4)))))))
     (return variable_bonita_10))
    (funcion
     sort
     ((: variable_bonita_2 intarr))
     ((= variable_bonita_7 int 0)
      (= variable_bonita_0 int (len variable_bonita_2))
      (whilejly
       (< variable_bonita_7 variable_bonita_0)
       ((= variable_bonita_3 int variable_bonita_7)
        (whilejly
         (> variable_bonita_3 0)
         ((ifjly
           (>
            (arr-pos variable_bonita_2 (- variable_bonita_3 1))
            (arr-pos variable_bonita_2 variable_bonita_3))
           ((=
             variable_bonita_6
             int
             (arr-pos variable_bonita_2 variable_bonita_3))
            (=
             (arr-pos variable_bonita_2 variable_bonita_3)
             (arr-pos variable_bonita_2 (- variable_bonita_3 1)))
            (=
             (arr-pos variable_bonita_2 (- variable_bonita_3 1))
             variable_bonita_6))
           ())
          (= variable_bonita_3 (- variable_bonita_3 1))))
        (= variable_bonita_7 (+ variable_bonita_7 1)))))))))
"symboltable-renamevar.rkt"> (symbol-table-archivo "ejemplos/in.jly")
'#hash((variable_bonita_11 . int)
       (variable_bonita_13 . intarr)
       (variable_bonita_14 . int)
       (variable_bonita_15 . int)
       (variable_bonita_16 . int)
       (variable_bonita_17 . int)
       (variable_bonita_18 . int)
       (variable_bonita_20 . int))
```















