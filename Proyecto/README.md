<div align="center">

# 🔥🤖 **Proyecto Final : Compilador Jelly ​** 🧲⚙️

----
# 🖥️ **Equipo Azul** 🛡️

### <br> <img src="https://media.tenor.com/m6cM9lV-doYAAAAi/batman-batman-beyond.gif" width="50"> **Carlos Emilio Castañon Maldonado** ~ **Dafne Bonilla Reyes** <img src="https://media.tenor.com/EAAxkwW71WcAAAAi/pokemon-pokemon-black-and-white.gif" width="50"> <br> 

### <br> <img src="https://media.tenor.com/0hEQxK9tC7UAAAAi/club-penguin-dance.gif" width="50"> **José Camilo García Ponce** ~ **Jorge Daniel Velasco García** <img src="https://media.tenor.com/rI_0O_9AJ5sAAAAi/nyan-cat-poptart-cat.gif" width="50"> <br> 


[![](https://www.fightersgeneration.com/characters4/warmachine-win1.gif)](https://www.youtube.com/watch?v=pAgnJDJN4VA)

</div>

----

[Compilador-Jelly.webm](https://github.com/CarlosCastanon2099/Compiladores-/assets/108638686/23f7cce5-c003-4aac-a164-477cf111df8a)


----

## **En el presente proyecto implementamos:**

${\color{red}➣}$ Un proceso que traduce un árbol de sintaxis abstracta a código Java. 
El código que produce dicho árbol se obtiene de un archivo arbitrario example.jly con código en Jelly para y el resultado se escribe en un archivo example.java

${\color{red}➣}$ Un script para el compilador de jelly desde la línea de comandos.

${\color{red}➣}$ La extensión de el lenguaje desde la gramática para que nuestro lenguaje implemente cadenas, asi
mismo permite al lenguaje imprimir con println(e).

${\color{red}➣}$ La definición y uso de variables globales.

-------------

Los ejemplos de jelly se encuentran en:

```Python
         _nnnn_                      
        dGGGGMMb     ,"""""""""""""""""""""""""""""""""""""""""".
       @p~qp~~qMb    |                src/ejemplos/             |
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

Para hacer uso de lo implementado en el proyecto:
- Ejecutamos desde `src/` los siguientes pasos:

Linux  : 

- Verificamos que tengamos instalado `nanopass`:

```Python
\proyecto-equipo_azul> raco pkg install nanopass
```

- Usamos el siguiente comando para brindar los permisos de ejecucion:

```Python
\src> chmod +x script.sh
```

- Ejecutamos desde linea de comandos lo siguiente para obtener nuestro archivo.java

```Python
\src> ./script.sh archivo.jly
```

### **Ejemplo de uso 01:**

Archivo original en Jelly:

```Java
yeah:string = "Choco"
main{
    ave_g4:int[] = {1,3,4,5}
    a:string = "Batman"
    b_2:string[] = {"gato", "Maximo", "Donna", yeah}
    dummyVar:bool
    println(a)
}
```

Ejecucion:

```Python
\src> chmod +x script.sh
\src> ./script.sh ejemplos/string1.jly                          
4 shift/reduce conflicts
Archivo generado: String1.java
```

Archivo generado en Java:

```Java
public class String1 {

public static String variable_bonita_0 = "Choco";

public static void main(String[] args) {
int[] variable_bonita_2 = {1, 3, 4, 5};
String variable_bonita_1 = "Batman";
String[] variable_bonita_3 = {"gato", "Maximo", "Donna", variable_bonita_0};
boolean variable_bonita_5;
System.out.println(variable_bonita_1);
}

}

```

### **Ejemplo de uso 02:**

Archivo original en Jelly:

```Java
numero:int = 99
c:bool = True
numerito:int[] = {1,2}

main{
    println("algo")
    println(c)
    println(1+3)
    cadena:string = "pato"
    aux:int = 77
    aux = 78
    z:int[]
    p:int
    p = 1
    q:int = 0
    q:int = 1
    y:int[] = {1,2,3}
    z:int[] = {1,2}
    y:int[] = {1,4+1}
    g:int = y[0]
    fact(1, !True)
    j:int = True ? 1 : 0
    g = len(y)
    cadena:string = "pato2"
}
// metodo
fact(num:int, b:bool):int{
    algo:int = 0
    if (algo < 1) {
        algo = 1+1
    } else {
        algo = 2+2
    }
    algo = 2+2
    aux:int = 14
    aux = 15
    return numero
}

a(num:int){
    while (num > 3) {
        if (1 < 2) num = 3 - 1
        else num = 4 - 1
    }
}

d(){
    if 1>2 {a:int = 2+2}
}
```

Ejecucion:

```Python
\src> chmod +x script.sh
\src> ./script.sh ejemplos/b.jly
 4 shift/reduce conflicts
 Archivo generado: B.java
```

Archivo generado en Java:

```Java
public class B {

    public static int variable_bonita_10 = 99;
    public static boolean variable_bonita_8 = true;
    public static int[] variable_bonita_9 = {1, 2};
    
    public static void main(String[] args) {
        System.out.println("algo");
        System.out.println(variable_bonita_8);
        System.out.println(1 + 3);
        String variable_bonita_19 = "pato";
        int variable_bonita_12 = 77;
        variable_bonita_12 = 78;
        int[] variable_bonita_13;
        int variable_bonita_15;
        variable_bonita_15 = 1;
        int variable_bonita_11 = 0;
        variable_bonita_11 = 1;
        int[] variable_bonita_17 = {1, 2, 3};
        variable_bonita_13 = new int[]{1, 2};
        variable_bonita_17 = new int[]{1, 4 + 1};
        int variable_bonita_18 = variable_bonita_17[0];
        fact(1, !true);
        int variable_bonita_14 = true ? 1 : 0;
        variable_bonita_18 = variable_bonita_17.length;
        variable_bonita_19 = "pato2";
    }
    
    public static int fact(int variable_bonita_24, boolean variable_bonita_23) {
        int variable_bonita_20 = 0;
        if (variable_bonita_20 < 1) {
            variable_bonita_20 = 1 + 1;
        } else {
            variable_bonita_20 = 2 + 2;
        };
        variable_bonita_20 = 2 + 2;
        int variable_bonita_21 = 14;
        variable_bonita_21 = 15;
        return variable_bonita_10;
    }
    
    public static void a(int variable_bonita_25) {
        while (variable_bonita_25 > 3) {
            if (1 < 2) {
                variable_bonita_25 = 3 - 1;
            } else {
                variable_bonita_25 = 4 - 1;
            };
        };
    }
    
    public static void d() {
        if (1 > 2) {
            int variable_bonita_26 = 2 + 2;
        } else {
        };
    }
}
```
