#!/bin/bash

# Monitorización de cambios en tiempo real (icron/inotify):
#	
# 	Por tanto, se debe desarrollar un script que admita la siguiente sintaxis:
#	registrar_creacion_ficheros DIRECTORIO fichero_registro
#	donde DIRECTORIO se corresponde con el directorio que debemos monitorizar y por cada
#	creación de un fichero que se haga en su interior debemos insertar una línea en
#	fichero_registro indicando la fecha y hora de la creación, el nombre del fichero creado y el
#	usuario que ha realizado dicha operación.
#
# Uso:
#
#	script [directory] [register_file]
# 	
#	en caso e que no exista el directorio saldrá error y si no existe el archivo de 
#	registro se creará
#

#función que redirecciona el parámetro que le pasemos al stderr
error(){
	echo $1>&2
	exit 1
}

#revisar si el número de argumentos es igual a dos
if [[ $# -ne 2 ]]
then
	error "usage: script [directory] [register_file]"
fi

#comprobamos que exista el fichero de logs
if [[ ! -f $2 ]]
then
	touch $2
fi

#comprobamos que el directorio exista
if [[ ! -d $1 ]]
then 
	error "Incorrect parameter [directory]: Is not a directory"
fi

#usamos el comando inotifywait de inotify para realizar acciones cada vez que haya un cambio en el directorio en segundo plano.
inotifywait -m $1 -e create | while read DIRECTORY EVENT FILE; do
	DATE=$(date +"%H:%M %d/%m/%y")
	echo $DATE, $DIRECTORY, $EVENT, $FILE >> $2
done & 

echo "Changes observer initialized with PID: $!"





