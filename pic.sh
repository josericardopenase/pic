#!/bin/bash 
#  monitorización de cambios en tiempo real (icron/inotify):
#	un script que reciba como argumento uno o varios directorios. Sobre cada directorio, mediante
#	inotify se detectarán las modificaciones en todos sus ficheros, que se irán guardando en una carpeta
#	".versiones" del directorio. La versión del archivo A se guardará como
#	A.YYYYMMDDTHH:MM:SS (o sea, el nombre del archivo, seguido de una marca de tiempo con
#	formato estándar). Se valorará positivamente que se elabore alguna utilidad para recuperar el estado
#	del directorio en una fecha y hora determinadas.
# Uso:
# 
#	script [-v|--version] [-h|--help] <command> [<args>]
#	
#	These are the implemented commands:
# 		init	Create a control version repository
#		watch 	Make the control version work in current directory
#		log 	Show the changes history of the directory
#		snap 	Create a snapshot of the current version of the directory
#		goto Recover version from a concete snapshot
#
pam=$2
error(){
	echo $1>&2
	exit 1
}

version(){
	echo "pic version 0.0.1"
}

default(){
	echo "Usage:"
	echo ""
	echo "	pic [--version] [--help] <command> [<args>]"
}

base_help(){
	echo "Usage:"
	echo ""
	echo "	pic [--version] [--help] <command> [<args>]"
	echo ""
	echo "These are the implemented commands:"
	echo ""
	echo " 	init	Create a control version repository"
	echo "	watch 	Make the control version work in current directory"
	echo "	log 	Show the changes history of the directory"
	echo "	status 	See changes in the directory"
	echo "	snap 	Create a snapshot with current changes"
	echo "	goto 	Recover the state of the directory in a given snapshot"
	echo "	help 	get help with a concrete command"
	echo ""
	echo "You can use pic --help or pic --version to get additional information"
}

help(){
	case "$1" in
		init )
			echo "Manual of init:"
			echo ""
			echo "Description:"
			echo ""
			echo "init is used to make a directory a pic repository."
			echo "If you want to track the changes of a directory you first must"
			echo "create inside a pic repository."
			echo "this will create a .pic folder in your dir which is used internally"
			echo "to save all the snapshots and internal stuff"
			echo ""
			echo "Usage:"
			echo ""
			echo "	pic init [directory]"
			echo ""
		;;
		watch )
			echo "Manual of watch:"
			echo ""
			echo "Description:"
			echo ""
			echo "watch is used to start tracking changes of a repository"
			echo "if you modify your repository without watching it the control version"
			echo "will not track the changes of the directory"
			echo ""
			echo "Usage:"
			echo ""
			echo "	pic watch"
			echo ""
			echo "By default gets the current directory"
		;;
		log )
			echo "Manual of log:"
			echo ""
			echo "Description:"
			echo ""
			echo "Log is used to see the history of changes of the current directory"
			echo ""
			echo "Usage:"
			echo ""
			echo "	pic log [-file <file>]"
			echo ""
			echo "The current directory must be a pic repository."
		;;
		recover )
			echo "Manual of recover:"
			echo ""
			echo "Description:"
			echo ""
			echo "Recover brings back a file of the current directory to the state of a snapshot"
			echo ""
			echo "Usage:"
			echo ""
			echo "	pic recover <file> <date>"
			echo ""
			echo "The current directory must be a pic repository."
			
		;;
		goto )
			echo "Manual of goto:"
			echo ""
			echo "Description:"
			echo ""
			echo "Change the current directory state to a past snapshot"
			echo ""
			echo "Usage:"
			echo ""
			echo "	pic goto <file> <date>"
			echo ""
			echo "The current directory must be a pic repository."
		;;
		snap )
			echo "Manual of snap:"
			echo ""
			echo "Description:"
			echo ""
			echo "Create a snapshot with the changes of the directory"
			echo ""
			echo "Usage:"
			echo ""
			echo "	pic snap [-m <message>]"
			echo ""
			echo "The current directory must be a pic repository."
		;;
		status )
			echo "Manual of status:"
			echo ""
			echo "Description:"
			echo ""
			echo "See the current changes in the directory"
			echo ""
			echo "Usage:"
			echo ""
			echo "	pic status"
			echo ""
			echo "The current directory must be a pic repository."
		;;
		* )
			error "No manual entry for that command or the command does not exist"
		;;
	esac	
}

is_repository_error(){
	if [[ -d $1/.pic ]]
	then
		error "$1 is already a pic repository"
	fi
}

is_not_repository_error(){
	if [[ ! -d $1/.pic ]]
	then
		error "$1 is not a pic repository"
	fi
}

init(){
	repo=$1
	is_repository_error $repo
	mkdir $repo/.pic
	mkdir $repo/.pic/versions
	touch $repo/.pic/logs
	touch $repo/.pic/snap
	echo "Initialized a pic repository in $repo"
}

watch(){
	is_not_repository_error .
	inotifywait -m . -e create,modify,delete | while read DIRECTORY EVENT FILE; do
			DATE=$(date +"%H-%M-%d-%m-%y")
			echo $DATE:$DIRECTORY:$EVENT:$FILE >> ./.pic/snap
		done &
	echo "Started watching changes in $repo with PID: $!"
}

snap(){
	is_not_repository_error .
	
	
	# Se almacena la fecha de la captura y se obtiene la información  del fichero snap
	DATE=$(date +%Y%m%d%H:%M:%S)
	list=$(cat ./.pic/snap | cut -d: -f4 | sort -u | grep -v "^\.")
	if [[ -z "$list" ]]
	then echo "No hay cambios que registrar"
		exit 1
	fi
	
	#Se obtiene la lista de ficheros borrados
	cat ./.pic/snap | cut -d: -f3,4 | grep '^DELETE'| cut -d: -f2 | sort -u >> ./.pic/deletions

	# Los archivos modificados se utilizan como parámetros del comando tar
	input="./.pic/deletions"
	for i in $list; do
        	input="$input $i"
        done
	tar czf ./.pic/versions/$DATE.tgz $input 1 > /dev/null 2> /dev/null

	# Se escribe en el ./.pic/log el snap y los archivos modificados
	echo "========================================" >> ./.pic/logs
	echo "Snap with ID: $DATE.tgz added to versions " >> ./.pic/logs
	if [[ $1 -eq "-m" ]]
	then
		echo "Snap Message: $2" >> ./.pic/logs
	fi
	echo "	Files changed:" >> ./.pic/logs
	for i in $list; do
        	echo "	 ._$i" >> ./.pic/logs
        done

	# Se muestra un mensaje por la consola del snap creado y su ID
	echo "Created a snap with ID: $DATE"
	if [[ $1 -eq "-m" ]]
	then
		echo "Snap Message: $2"
	fi
	echo "	Files changed:"
	for i in $list; do
		aux=$(grep "$i" ./.pic/deletions)
		if [ "$i" == "$aux" ]; then
			echo "	  --"$i""
  		else
			echo "	  ++"$i""
		fi
        done
	# Se vacía el fichero snap
	cat /dev/null > ./.pic/snap
}

status(){
	is_not_repository_error .
	#implement -file optional parameter
	echo "The changes of the directory are:"
	cat ./.pic/snap
}

log(){
	#implement -file optional parameter
	cat ./.pic/logs
}

goto(){
	is_not_repository_error .

	#Controlar que el snap existe
	if [[ ! -f ".pic/versions/$1.tgz" ]]
	then 
		error "El ID del snap dado no existe"
	fi

	find ./* -type f ! -iwholename "**/.pic/*" -exec rm {} \;

	echo "Comenzamos a recuperar el estado del directorio en  $1"

	for file in $(find ./.pic/versions/ -type f -iname "*.tgz" | sort -n)
	do
		echo "Descomprimiendo $file"
		tar -xf $file
		if [[ $(echo $file | grep $1) ]]
		then
			break
		fi
	done
	
	#Remove de files written in ./.pic/deletions 
	if [[ -f ./.pic/deletions ]]
	then
		for file in $(cat ./.pic/deletions) 
			do
			echo "Deleting $file"
			rm $file
		done
	fi
	echo "Recuperado con exito el estado a $1"
	
}

case "$1" in
	-v | --version ) 
		version	
	;;
	-h | --help )
		base_help
	;;
	watch )
		watch
	;;
	log )
		log
	;;
	snap )
		snap $2 $3
	;;
	status )
		status
	;;
	goto )
		goto $2
	;;
	init )
		init $2
	;;
	help )
		help $2
	;;
	* )
		default
	;;
esac
