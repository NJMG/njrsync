#!/usr/bin/env bash
#
##################################################################################################################
# NJrsync
# Desc: Backup with Rsync and Zip rsyncfolder ( folder and file list in njrsync.list )
#
# rsync options :: https://download.samba.org/pub/rsync/rsync.html
# zip options :: http://www.info-zip.org/mans/zip.html
##################################################################################################################
#path & nom du script & mod debug( 0=false ; 1=true ):
SCRIPT=$0
SCRIPTPATH=$(dirname $SCRIPT)
SCRIPTNAME=$(basename ${SCRIPT%.*})
Sdebug=0
SbeROOT=1
Scolor=1
#####################################
#Script Test if in terminal ( verbose OK )
#fd=1 ; [[ -t "$fd"  ]] && { SinTerm=1 ;}
[[ -t 1 ]] && { SinTerm=1 ;}
#####################################
#ROOT ONLY:

msg_beroot="<!> Must be root to run this script. <!>"

ROOT_UID=0 # Only users with $UID 0 have root privileges.
E_NOTROOT=67 # Non-root exit error.
# Run as root, of course.
if ((SbeROOT)) && [ "$UID" -ne "$ROOT_UID" ]
then
((SinTerm)) && echo "$msg_beroot"
exit $E_NOTROOT
fi
######################################
#Variables
#var to enable functions ::
Nj_CREATE_DIR_BACKUP=1
Nj_CMDRSYNC=1
Nj_CMDZIP_IF_RSYNC=1
Nj_CMDZIP_GITCLONE=1

#Rep & Destination ::
# ${HOSTNAME,,} >> host name in lower case
NjGitRep="/home/nj/git"
NjRepDest="/home/nj/rsyncbackup"
NjRepZip="/home/nj/rsyncbackupzip"
NjZipfile="/home/nj/rsyncbackupzip/rsyncbackup-${HOSTNAME,,}.zip"
NjZipGit="/home/nj/rsyncbackupzip/gitclone-${HOSTNAME,,}.zip"

############################
# create directory if not exist ( "mkdir -p" )
((Nj_CREATE_DIR_BACKUP)) && { mkdir -p ${NjRepDest} ; mkdir -p ${NjRepZip} ;}
############################

#NjFlags="-ar"
NjFlags="-air" 	# i pour le mode info sur l'update des fichiers si modifier. 
#	pourra servir ensuite si mod du script
######################################
#RSYNC function
fct__CMDRSYNC()
{
[[ -x "/usr/bin/rsync" ]] && { XRSYNC="/usr/bin/rsync" ;} || { echo "Install Rsync Package First!" ; exit 1 ;}
#Create new log file
echo "###LOG INIT###" > $SCRIPTPATH/$SCRIPTNAME.log
# bash cmd : rsync -ar --delete-after --log-file=FILE --files-from=/dirpath/njrsync.list / /home/nj/rsyncbackup/
RSYNCCMD=$( $XRSYNC $NjFlags --delete-after --log-file=$SCRIPTPATH/$SCRIPTNAME.log --files-from=$SCRIPTPATH/$SCRIPTNAME.list / $NjRepDest/ )


#[[ $RSYNCCMD ]] && echo -e "$RSYNCCMD"

((SinTerm)) && echo -e "$RSYNCCMD"

}
################
fct__CMDZIP_IF_RSYNC()
{
[[ -x "/usr/bin/zip" ]] && { XZIP="/usr/bin/zip" ;} || { echo "Install Zip Package First!" ; exit 1 ;}

((SinTerm)) && { ZipFlag="-vou" ;} || { ZipFlag="-qou" ;}

##[[ $RSYNCCMD ]] && { ZIPCMD=$( $XZIP $NjFlagQ -r $NjZipfile $NjRepDest ) ;}

[[ $RSYNCCMD ]] && { ZIPCMD=$( $XZIP $ZipFlag -r $NjZipfile $NjRepDest | grep "updating\|warning\|total" ) ;}

((SinTerm)) && echo -e "$ZIPCMD"

}
################
fct__CMDZIP_GITCLONE()
{
[[ -x "/usr/bin/zip" ]] && { XZIP="/usr/bin/zip" ;} || { echo "Install Zip Package First!" ; exit 1 ;}

((SinTerm)) && { ZipFlag="-vou" ;} || { ZipFlag="-qou" ;}

##[[ -d $NjGitRep ]] && { ZIPGIT=$( $XZIP $ZipFlag -r $NjZipGit $NjGitRep | grep "updating\|warning\|total" ) ; ((SinTerm)) && echo -e "$ZIPGIT" ;}
# test si non empty : if [ "$(ls -A /path/to/dir)" ]; then
[[ "$(ls -A $NjGitRep)" ]] && { ZIPGIT=$( $XZIP $ZipFlag -r $NjZipGit $NjGitRep | grep "updating\|warning\|total" ) ; ((SinTerm)) && echo -e "$ZIPGIT" ;}

}


######################################
#test njrsync.list ( dans le meme repertoire que l'exe njrsync )

if [ -r $SCRIPTPATH/$SCRIPTNAME.list ] ; then	 
	((Nj_CMDRSYNC)) && fct__CMDRSYNC
	((Nj_CMDZIP_IF_RSYNC)) && fct__CMDZIP_IF_RSYNC
	((Nj_CMDZIP_GITCLONE)) && fct__CMDZIP_GITCLONE
else
	echo "Rsync list file missing: $SCRIPTNAME.list : Exiting!"
	exit 1
fi

exit 0


