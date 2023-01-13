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
	#1. leer del archivo ./.pic/snap
	#2. sacar una lista de los archivos que sean creado, modificado, etc... cat ./.pic/snap | cut -d: -f4 | sort -u
	#3. crear un gzip comprimido con esos archivos (el nombre debe ser el formato fecha del enunciado) y guardarlo en el directorio ./.pic/versions
	DATE=$(date +%Y%m%d%H%M%S)
	list=$(cat ./.pic/snap | cut -d: -f4 | sort -u | grep -v "^\.")
	cat /dev/null > ./.pic/deletions
	cat ./.pic/snap | cut -d: -f3,4 | grep '^DELETE'| cut -d: -f2 | sort -u >> ./.pic/deletions
	input="./.pic/deletions"
	for i in $list; do
        	input="$input $i"
        done
	tar czf ./.pic/versions/$DATE.tgz $input 1 > /dev/null 2> /dev/null

	#4. escribir en el ./.pic/log el commit al estilo git log.
	echo "========================================" >> ./.pic/logs
	echo "Snap with ID: $DATE.tgz added to versions " >> ./.pic/logs
	echo "	Files changed:" >> ./.pic/logs
	for i in $list; do
        	echo "	 ._$i" >> ./.pic/logs
        done

	#5. vaciar el ./.pic/snap
	#echo "" > ./.pic/snap	
		
	#6. mostrar un mensaje por la consola del snap creado y su ID

	#OPCIONAL: poner un -m con mensaje
	echo "Created a snap with ID: $DATE"
	echo "	Files changed:"
	for i in $list; do
		aux=$(grep "$i" ./.pic/deletions)
		if [ "$i" == "$aux" ]; then
			echo "	  --"$i""
  		else
			echo "	  ++"$i""
		fi
        done
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
	#queda por implementar
	echo "Is not implemented yet"
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
		snap 
	;;
	status )
		status
	;;
	goto )
		goto
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
