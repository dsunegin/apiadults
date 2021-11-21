#!/bin/bash
# Written by: Denis Sunegin
# Date: 11/13/2021
######## CHECK DEPS ##########

if [ -e /usr/bin/sw_vers ]; then
  if [ ! -d /usr/local/Cellar/gnu-getopt ] ; then
    printf "\x1b[38;5;1mERROR:\x1b[m gnu-getopt must be installed\n"
    exit 0
  fi
  GETOPT=$(find /usr/local/Cellar/gnu-getopt/ -name 'getopt')
else
  GETOPT=$(which getopt)
fi

for DEP in getopt youtube-dl mysql
do
  if [ -z $(which $DEP) ] ; then
    printf "\x1b[38;5;1mERROR:\x1b[m $DEP must be installed\n"
    exit 0
  fi
done
###### SET SET TMPDIR ########

if [ -z ${TMPDIR} ] ; then
  if [ -w /tmp ] ; then
    TMPDIR="/tmp"
  elif [ -w ~/ ] ; then
    TMPDIR="~/.ripyt"
  fi
fi

if [ ! -w ${TMPDIR} ] ; then
  printf "\x1b[38;5;1mERROR:\x1b[m \$TMPDIR $TMPDIR does not have a writable directory set\n"
  exit 0
fi


####### SET VARIABLES ########
TEMPDIR=$(mktemp -d 2>/dev/null || mktemp -dt ripyt 2>/dev/null)
verifymatches="0"
skipyes="0"
slink=""
sname=""
SHOWHELP="0"
DOINTERACTIVE="0"
DOYES="0"
HASSEARCH="0"
HASFILE="0"

  dbUser="adult_user"
  dbPass="psw_adult_user"
  dbName="video"
  dbTable="adult"

  ru="0"
  uk="0"
  be="0"
  pl="0"
  en="0"
  fr="0"
  de="0"
  es="0"
  it="0"
  bg="0"



helpmsg="""
RIPYT(1) (written by Denis Sunegin)\n\n
ABOUT:\n
This program is a wrapper for youtube-dl\n
\n
\t-t,--table \"dbTable\"\n
\t\t will put result to dbTable (default = adult).\n
\n
\t-s,--search \"some string\"\n
\t\t will search for the string you enter.\n
\n
\t-f,--file \"path/to/file\"\n
\t\t this enabled a batch mode. it will search\n
\t\t for each line in the file.\n
\n
\n
\t-h,--help\n
\t\t view this help page.\n
\n
\t-ru,--ru  Push tu Russian\n
\t-uk,--uk  Push tu Ukrainian\n
\t-be,--be  Push tu Belarus\n
\t-pl,--pl  Push tu Polski\n
\t-en,--en  Push tu English\n
\t-fr,--fr  Push tu French\n
\t-de,--de  Push tu Deutch\n
\t-es,--es  Push tu Spanish\n
\t-it,--it  Push tu Italian\n
\t-bg,--bg  Push tu Bulgarian\n
\n
\tExample:
\tyoutube-db.sh --ru --table cartoon --search b7GTyBvniVQ
\t/youtube-db.sh --en --ru --table adult --search DtuJ55tmjps
\t/youtube-db.sh  --ru --uk --be --pl --en --fr --de --es --it --bg --table adult --search DtuJ55tmjps
"""

###### NOT ENOUGH ARGS #######

if [ $# -lt 2 ] ; then
  echo -e $helpmsg
  exit 1
fi

########## FUNCTIONS #########

function returnlink() {
  #echo ${TEMPDIR}
  video=$(echo $* )
  tries="0"
  while [ $tries -lt 3 ] ; do
    #searchurl=$(echo "https://www.youtube.com/results?search_query="$searchvideo 2> /dev/null)
    #echo $video
    youtube-dl -s  --get-id  --get-title ${video} | iconv -f WINDOWS-1251 -t UTF-8//IGNORE > ${TEMPDIR}/search_result.tmp 2> /dev/null
    #file -b ${TEMPDIR}/search_result.tmp
    #findedvideo=$(wc -l ${TEMPDIR}/search_result.tmp | awk '{print $1 }' )
    findedvideo=$(grep ${video} ${TEMPDIR}/search_result.tmp | head -n 1 )
    if [ "$findedvideo" = "$video" ] ; then
      youtube-dl -s --list-thumbnails ${video} > ${TEMPDIR}/thumbs.tmp 2> /dev/null
      #thumb=$(wc -l ${TEMPDIR}/thumbs.tmp | awk '{print $1 }' )
      thumblinenumber=$( awk '{ printf "%s\n", $1 }' ${TEMPDIR}/thumbs.tmp | grep -n 2 | head -n 1 | cut -d \: -f 1 )
      thumbhref=$( head -n ${thumblinenumber} ${TEMPDIR}/thumbs.tmp | tail -1 | sed -nE 's/^.*(https?:\/\/.*)/\1/p' )
      #echo $thumbhref
      #exit
      #echo $findedvideo
      videotitle=$(sed -i /$findedvideo/d ${TEMPDIR}/search_result.tmp | head -n 1 ${TEMPDIR}/search_result.tmp)
      #videotitle=$(head -n 1 ${TEMPDIR}/search_result.tmp )
      #echo $videotitle
    break
    fi
    #cat ${TEMPDIR}/search_result.tmp
    #echo ${TEMPDIR}/search_result.tmp
    #frlength=$(grep -n yt-lockup2-content ${TEMPDIR}/search_result.tmp | head -n 1 | cut -d \: -f 1 )
    #echo $frlength
    #grep  DfFlBWCQjzA /tmp/tmp.qFu2fBMYQs/search_result.tmp | head -n 1

    #matches=$(tail -n $(( $srlength - $frlength )) ${TEMPDIR}/search_result.tmp | grep -e '^[ ]*<h3[ ]*class=\"[-a-zA-Z0-9]*\"[ ]*><a' | sed -nE 's/(^.*title="([^"]*)".*href="([^"]*)".*)/\3\|\2/p' | sed -e 's/[\ ]/_/g' -e 's/[\!]//g' | grep -v results_main )
    #matches=$(tail -n $(( $srlength - $frlength )) ${TEMPDIR}/search_result.tmp | grep -e '^[ ]*<h3[ ]*class=\"[-a-zA-Z0-9]*\"[ ]*><a' | sed -nE 's/(^.*title="([^"]*)".*href="([^"]*)".*)/\3\|\2/p' | sed -e 's/[\ ]/_/g' -e 's/[\!]//g' | grep -v results_main )
    #totalmatches=$(echo $matches | wc -w | awk '{print $1}')
    #if [ $totalmatches -gt 0 ] ; then
    #break
    #fi
    tries=$(( $tries + 1 ))
    sleep 1
  done
  if [ $tries -gt 2 ] ; then
    printf "\x1b[38;5;1mERROR: Could not find video: $video .... SKIPPING\x1b[m\n"
  else
    if [ $verifymatches -eq "0" ] ; then
      link=$(echo $matches | head -n 1 | cut -d \| -f 1)
      sname=$(echo $matches | head -n 1 | cut -d \| -f 2 | sed -e 's/_/\ /g' -e 's/\/wa.*.$//g' )
    else
      count="1"
      printf "\x1b[38;5;6mSearch results generated for: $(echo $videotitle : $video )\x1b[m\n"
      for match in $(echo $matches) ; do
        echo "$count) $(echo $match | cut -d ' ' -f $count | cut -d \| -f 2 | sed -e 's/_/\ /g' -e 's/^[\ ]*//g' -e 's/\ \ /\ /g' ) "  >&2
        count=$(expr $count + 1 )
      done
      validreply="0"
      while [ "$validreply" -ne "1" ] ; do
        read -e -p "Enter choice number: " prompt
        if [ $prompt -le $totalmatches ] ; then
          link="$(echo $matches | cut -d ' ' -f $prompt | cut -d \| -f 1)"
          sname="$(echo $matches | cut -d ' ' -f $prompt | cut -d \| -f 2| sed 's/_/\ /g')"
          validreply="1"
        else
          printf "\x1b[38;5;1mThat is not a valid choice\x1b[m\n"
        fi
      done
    fi
  fi
  rm ${TEMPDIR}/search_result.tmp
}

function ripvideo {
  echo -e "Pushing video to DATABASE video.${dbTable}:\n${video} : ${videotitle}"
  sql='INSERT INTO '${dbTable}' (`title`, `alias`, `video`, `image`,`ru`,`uk`,`be`,`pl`,`en`,`fr`,`de`,`es`,`it`,`bg`) VALUES ('"'${videotitle}'"','"'${1}'"','"'${1}'"','"'${thumbhref}'"',
  '"'${ru}'"','"'${uk}'"','"'${be}'"','"'${pl}'"','"'${en}'"','"'${fr}'"','"'${de}'"','"'${es}'"','"'${it}'"','"'${bg}'"')'
  mysql -u$dbUser -p$dbPass  -D$dbName  -P3306 -h127.0.0.1 --default_character_set utf8 -A -e "${sql}"
  printf "\x1b[38;5;2mDone\x1b[m\n"
}


function ripvideolist {
  youtube-dl -q --output="%(title)s.%(ext)s" --extract-audio --audio-format=mp3 --batch-file="${TEMPDIR}/urllist.tmp" | pv -t
  rm ${TEMPDIR}/urllist.tmp ${TEMPDIR}/namelist.tmp
  printf "\x1b[38;5;2mDone\x1b[m"
}

function confirm() {
  validreply="0"
  while [ "$validreply" -ne "1" ] ; do
    read -p "[(Y)es/(N)o]: " prompt
    if [[ $prompt =~ ^([yY][eE][sS]|[yY])$ ]] ; then
      validreply="1"
    elif [[ $prompt =~ ^([nN][oO]|[nN])$ ]] ;then
      exit 0
    else
      exit 1
    fi
done
}

####### PARSE OPTIONS ########

TEMP=`$GETOPT -o hiys:f: --long help,ru,uk,be,pl,en,fr,de,es,it,bg,table:,search:,file: \
     -n $0 -- "$@"`

if [ $? != 0 ] ; then echo "Terminating..." >&2 ; exit 1 ; fi

# Note the quotes around `$TEMP': they are essential!
eval set -- "$TEMP"

while true ; do
    case "$1" in
        -h|--help)
            SHOWHELP="1"
            shift
            ;;
        -ru|--ru)
            ru="1"
            shift
            ;;
        -uk|--uk)
            uk="1"
            shift
            ;;
        -be|--be)
            be="1"
            shift
            ;;
        -pl|--pl)
            pl="1"
            shift
            ;;
        -en|--en)
            en="1"
            shift
            ;;
        -fr|--fr)
            fr="1"
            shift
            ;;
        -de|--de)
            de="1"
            shift
            ;;
        -es|--es)
            es="1"
            shift
            ;;
        -it|--it)
            it="1"
            shift
            ;;
        -bg|--bg)
            bg="1"
            shift
            ;;

          -t|--table)
            if [ "$2" = "" ] ; then
              echo "Default: dbTable = adult"
              exit 1
            fi
            dbTable="$2"
            shift 2
            ;;
        -s|--search)
            HASSEARCH="1"
            if [ "$2" = "" ] ; then
              echo "ERROR: no search string entered"
              exit 1
            fi
            SEARCHSTRING="$2"
            shift 2
            ;;
        -f|--file)
            HASFILE="1"
            if [ ! -f $2 ] ; then
              printf "\x1b[38;5;1mERROR: File \"$2\" doesnt exist\x1b[m\n"
              exit 1
            fi
            THEFILE="$2"

            shift 2
            ;;
        --) shift ; break ;;
        *) printf "\x1b[38;5;1mInternal error!\x1b[m\n" ; exit 1 ;;
    esac
done
count="0"
for arg
do
  bargs[$count]="$arg"
  count="$(( $count + 1 ))"
done
if [ "${#bargs}" -ne "0" ] ; then
 printf "\x1b[38;5;1mERROR:\x1b[m The following arguments are invalid: "
  for var in "${bargs[@]}"
  do
    printf " \"${var}\" "
  done
  echo
  exit 1
fi

############ MAIN ############

if [ $SHOWHELP -eq 1 ] ; then
  echo -e $helpmsg
  exit 0
fi

if [ $DOINTERACTIVE -eq 1 ] ; then
  verifymatches="1"
fi

if [ $DOYES -eq 1 ] ; then
  skipyes="1"
fi

if [ $HASFILE -eq 1 ] && [ $HASSEARCH -eq 1 ] ; then
  printf "\x1b[38;5;1mERROR:\x1b[m you may not select a search string and a file at the same time\n"
  exit 1
fi

if [ $HASFILE -eq 1 ] ; then
  for line in `cat $THEFILE | sed 's/\ /_/g'` ; do
    returnlink  $(echo $line | sed 's/_/\ /g')
    echo "$slink" >> ${TEMPDIR}/urllist.tmp
    echo "$sname" >> ${TEMPDIR}/namelist.tmp
    if [ "$verifymatches" -ne "0" ] ; then
      echo ""
      echo ""
    fi
  done
  printf "\x1b[38;5;2mGoing to download the following :\x1b[m\n"
  echo "---------------------------------"
  cat ${TEMPDIR}/namelist.tmp
  echo "---------------------------------"
  echo ""
  if  [  "$skipyes" -eq "0" ] ; then
    printf "\x1b[38;5;2mWould you like to proceed? \x1b[m"
    confirm
  fi
  ripvideolist
fi

if [ $HASSEARCH -eq 1 ] ; then
  #generate slink with returnlink function
  returnlink $SEARCHSTRING

  #videoalias=$( echo $videotitle | sed -e "y/абвгдезийклмнопрстуфхьы/abvgdezijklmnoprstufx/" -e "s/ъ|ь|ы//g;s/ж/zh/g;s/ш/sh/g;s/ч/ch/g;s/щ/shh/g;s/ю/yu/g;s/я/ya/g;s/э/eh/g" )
  #echo $videoalias
  #exit

  #if  [  "\$skipyes" -eq "0" ] ; then
  #  printf "\x1b[38;5;2mWould you like to proceed? \x1b[m"
  #  confirm
  #fi
  ripvideo $video
fi
########## CLEAN UP ##########

rm -rf $TEMPDIR 2> /dev/null

############ END #############

exit 0

}