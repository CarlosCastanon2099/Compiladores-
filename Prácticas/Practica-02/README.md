
<div align="center">
  

# **Práctica 2**

# **Analizador Lexico**


---

# ⌚ **Equipo Azul** 📎

</div>


<div align="center">

<b> Carlos Emilio Castañón Maldonado ~ Bonilla Reyes Dafne ~ Garcia Ponce José Camilo ~ Diego Alfredo Villalpando

</div>




<div align="center">

[![](https://media.giphy.com/media/v1.Y2lkPTc5MGI3NjExN3N5YTY2am9sNWQ3bWVqZWQ4aDdwdGNhamRzam9mM2MwZnh1N3dwMSZlcD12MV9pbnRlcm5hbF9naWZfYnlfaWQmY3Q9Zw/5xtDarBFszThqQF1o6A/giphy.gif)](https://www.youtube.com/watch?v=dQw4w9WgXcQ)

</div>

-------------

## **En esta practica implementamos:**

➣ Un lexer que se llame jelly-lex que reconoce todos los posibles lexemas de Jelly
y genera el token correcto para cada lexema del lenguaje.

Este se encuentra en:

```Julia
lexer.rkt
```

➣ La definicion de la expresion regular y accion adecuada para un lexema no reconocido.

Este se encuentra en:

```Julia
lexer.rkt
```

➣ La definicion de la expresion regular y acción adecuada para los comentarios.

Este se encuentra en:

```Julia
lexer.rkt
```

➣ Una función que toma un archivo con código de jelly y regrese una lista con todos
sus tokens de izquierda a derecha, siempre y cuando no exista un lexema no reconocido.

Este se encuentra en:

```Julia
lexer.rkt
```

Ademas de que los ejemplos de jelly se encuentran en:

```Python
         _nnnn_                      
        dGGGGMMb     ,"""""""""""""""""""""""""""""""""""""""""".
       @p~qp~~qMb    |  src/ejemplos/ |
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


Para hacer uso de esta funcion:
- Compilar desde `src/`:

```Kotlin
\src> racket --repl --eval '(enter! (file \"lexer.rkt\"))'
```

- Ejecutar desde `src/lexer.rkt`:

```Python
Welcome to Racket v8.11.1 [cs].
"lexer.rkt"> (archivo-tokens "Ruta-Archivo")
```

- Ejemplo de uso con:

```Python
\ejemplos\gcd
```

En donde el contenido de gcd es:

```Julia
gdc(var1:int, var2:int) : int {
    while (var1 != 0){
        if (var1 < var2) var2 = var2 - var1
        else var1 = var1 - var2
    }
}
```

```Python
\src> racket --repl --eval '(enter! (file \"lexer.rkt\"))'
Welcome to Racket v8.11.1 [cs].
"lexer.rkt"> (archivo-tokens "ejemplos/gcd.jly")
(list
 (token 'IDEN "gdc")
 'OPENP
 (token 'IDEN "var1")
 'DDOT
 'TINT
 'COMA
 (token 'IDEN "var2")
 'DDOT
 'TINT
 'CLOSEP
 'DDOT
 'TINT
 'OPENB
 'WHILE
 'OPENP
 (token 'IDEN "var1")
 'NEQ
 (token 'NUM "0")
 'CLOSEP
 'OPENB
 'IF
 'OPENP
 (token 'IDEN "var1")
 'LT
 (token 'IDEN "var2")
 'CLOSEP
 (token 'IDEN "var2")
 'ASG
 (token 'IDEN "var2")
 'SUBS
 (token 'IDEN "var1")
 'ELSE
 (token 'IDEN "var1")
 'ASG
 (token 'IDEN "var1")
 'SUBS
 (token 'IDEN "var2")
 'CLOSEB
 'CLOSEB
 'EOF)
```









