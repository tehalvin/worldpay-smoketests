#!/bin/sh

# arguments for the environments we accept
export POKPROD="POKPROD"
export POKTEST="POKTEST"

# env filepath - construct the full path with the arguments above
export FILE_PATH="./resource/postman/environment/"
export PATH_EXT=".postman_environment.json"

# collection filepath
export COLLECTION_PATH="postman/collection/swagger.postman_collection.json"

# tmp path
export TMP_PATH="./resource/tmp"

# search keys - we look for these in the environment json files
export WUSERNAME_PLACEHOLDER="\"USERNAMEPLACEHOLDER\""
export WXMLPASSWORD_PLACEHOLDER="\"XMLPLACEHOLDER\""

# define the exit codes
export WUSERNAME_NOT_SET=1
export WXMLPASSWORD_NOT_SET=2
export ENV_FILE_NOT_FOUND=3
export INVALID_ENV_SPECIFIED=4

# usage
usage() { 
	echo "$0 usage: \
		\n\trun smoketest on worldpay VGWPOKUSD production: $0 -e $POKPROD\
		\n\trun smoketest on worldpay VGWPOK USD test: $0 -e $POKTEST"
}

# check if $LLCAUTHKEY is set
function checkUserName {
	if [ -z $WUSERNAME ]
	then
		(>&2 echo "ERROR: Local environment variable '\$WUSERNAME' not set.\
			\n set it with command \`export WUSERNAME=\"\$VALUE\"\` and try again")
		exit $WUSERNAME_NOT_SET
	fi
}


# check if $PLAYERPROCESSMANAGERAUTHKEY is set
function checkXMLPassword {
	if [ -z $WXMLPASSWORD ]
	then
		(>&2 echo "ERROR: Local environment variable '\$WXMLPASSWORD' not set.\
			\n set it with command \`export WXMLPASSWORD=\"\$VALUE\"\` and try again")
		exit $WXMLPASSWORD_NOT_SET
	fi
}

# check if passed in file exists
function fileExists {
	if [ ! -f $1 ]
	then
		(>&2 echo "ERROR: expected environment file $1 not found.")
		exit $ENV_FILE_NOT_FOUND
	fi
}

# check -e options
function checkEOption {
	case $1 in
		$POKPROD)
		;;
		$POKTEST)
		;;
		*)
			(>&2 echo "ERROR: Invalid environment set.")
			usage
			exit $INVALID_ENV_SPECIFIED
		;;		
	esac
}

# sed the environement file
function buildEnvFile {
	cp $FILE_PATH$OPTARG$PATH_EXT $TMP_PATH"/"$OPTARG$PATH_EXT
	sed -i '.bak' "s/$WUSERNAME_PLACEHOLDER/\"$WUSERNAME\"/g" $TMP_PATH"/"$OPTARG$PATH_EXT
	sed -i '.bak' "s/$WXMLPASSWORD_PLACEHOLDER/\"$WXMLPASSWORD\"/g" $TMP_PATH"/"$OPTARG$PATH_EXT	
}

# now run the newman via docker commands
function run_newman {
	docker pull postman/newman_ubuntu1404
	docker run -v `pwd`/resource:/etc/newman -t postman/newman_ubuntu1404 \
    --collection=$COLLECTION_PATH \
    --environment="tmp/$1.postman_environment.json"
}

# delete the tmp files - clean up after yourself...
function cleanup {
	rm -f $TMP_PATH"/"$OPTARG$PATH_EXT
	rm -f $TMP_PATH"/"$OPTARG$PATH_EXT".bak"
}

# --- main --- #

if [ $# -eq 0 ]
then
	usage
	exit 0
fi
while getopts "he:" opt; do
	case $opt in
		e)
			checkUserName
			checkXMLPassword
			checkEOption $OPTARG
			fileExists $FILE_PATH$OPTARG$PATH_EXT
			mkdir -p $TMP_PATH
			buildEnvFile
			run_newman $OPTARG
			cleanup
		;;
		h | *)
			echo "set the WUSERNAME and WXMLPASSWORD environments before running this script.\
				\nYou can do this with the following commands: \
				\n\t\`export WUSERNAME=\"\$VALUE\"\` and \
				\n\t\`export WXMLPASSWORD=\"\$VALUE\"\`"
			usage
			exit 0
		;;
	esac
done

