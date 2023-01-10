#!/bin/bash

#  Monitorización de cambios en tiempo real (icron/inotify):
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
#		recover Recover version from a concete snapshot
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
	echo "	recover Recover the state of a file in a given date"
	echo "	goto 	Recover the state of the directory in a given date"
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
			echo "	pic watch [repository]"
			echo ""
			echo "If a repository is not given will watch in current directory"
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
			echo "Recover brings back a file of the current directory to its state in a given date"
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
			echo "Change the current directory state to a past dated state"
			echo ""
			echo "Usage:"
			echo ""
			echo "	pic goto <file> <date>"
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
		error "$1 not a pic repository"
	fi
}

init(){
	repo=$1
	is_repository_error $repo
	mkdir $repo/.pic
	mkdir $repo/.pic/versions
	touch $repo/.pic/logs.txt
	echo "Initialized a pic repository in $repo"
}

watch(){
	is_not_repository_error $1
	inotifywait -m $repo -e create,modify | while read DIRECTORY EVENT FILE; do
	        DATE=$(date +"%H:%M %d/%m/%y")
		        echo $DATE, $DIRECTORY, $EVENT, $FILE >> $1/.pic/logs.txt
			#copy the file inside ./.pic/versions/
		done &
	echo "Started watching changes in $repo with PID: $!"
}

log(){
	#implement -file optional parameter
	cat ./.pic/logs.txt
}

goto(){
	echo "Is not implemented yet"
}

recover(){
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
		watch $2
	;;
	log )
		log
	;;
	goto )
		goto
	;;
	recover )
		recover
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
