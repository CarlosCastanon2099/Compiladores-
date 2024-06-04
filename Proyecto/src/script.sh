#!/bin/bash

# Verificar si se ha proporcionado algún argumento
if [ $# -eq 0 ]; then
    echo "Uso: $0 <ruta-al-archivo.jly>"
    exit 1
fi

# Verificar si se han proporcionado múltiples argumentos
if [ $# -gt 1 ]; then
    echo "Uso: $0 <ruta-al-archivo.jly>"
    echo "Se proporcionaron multiples argumentos. Solo se permite un archivo .jly."
    exit 1
fi

# Ejecutar el script Racket con el argumento proporcionado
racket transform.rkt "$1"
