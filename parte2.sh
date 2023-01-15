#!/bin/bash

# Monitorización de cambios en tiempo real (icron/inotify):
#	
#   Se trata de llevar un registro automático de versiones de los archivos de un directorio. Se elaborará
#   un script que reciba como argumento uno o varios directorios. Sobre cada directorio, mediante
#   inotify se detectarán las modificaciones en todos sus ficheros, que se irán guardando en una carpeta
#   ".versiones" del directorio. La versión del archivo A se guardará como
#   A.YYYYMMDDTHH:MM:SS (o sea, el nombre del archivo, seguido de una marca de tiempo con
#   formato estándar). Se valorará positivamente que se elabore alguna utilidad para recuperar el estado
#   del directorio en una fecha y hora determinadas.
#
# Uso:
#
#	script [directory...]
# 	
#	en caso de que alguno de los parametros no sea un directorio saltara error
#

#función que redirecciona el parámetro que le pasemos al stderr
error(){
	echo $1>&2
	exit 1
}

#revisar si el número de argumentos es mayor a 1
if [[ $# -lt 1 ]]
then
	error "usage: script [directory...]"
fi


#recorremos toda la lista de argumentos
for x in $@
do

    #revismos que el argumento sea un directorio
    if [[ ! -d $x ]]
    then
        error "Parameter must be a directory $x"
    fi

    #sino existe la carpeta .versions la creamos
    if [[ ! -d $x/.versions ]]
    then
        mkdir $x/.versions
    fi

    #usamos el comando inotifywait de inotify para realizar acciones cada vez que haya un cambio en el directorio en segundo plano.
    inotifywait -m $x -e create,modify | while read DIRECTORY EVENT FILE; do
        DATE=$(date +%Y%m%d%H:%M:%S)
        cp $DIRECTORY/$FILE $x/.versions/$FILE.$DATE
    done &

    echo "Changes observer in directory $x initialized with PID: $!"
done


