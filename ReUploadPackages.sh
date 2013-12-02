!#/bin/sh
TARGZFILES=`ls *.dsc`
PLATFORM="precise saucy"
ARCHTECT="amd64 i386"
BRANCHES="v7-stable v7-devel v8-devel"

echo "------------------------------------------"
echo "--- Re Upload existing debs to archive ---"
echo "------------------------------------------"

echo "Select Ubuntu DIST:"
select szPlatform in $PLATFORM
do
        break;
done

echo "Select CPU Platform:"
select szArch in $ARCHTECT "All"
do
        case $szArch in "All")
                szArch=$ARCHTECT;
        esac
        break;
done

echo "Select RSyslog BRANCH:"
select szBranch in $BRANCHES
do
        echo "Making Packages for '$szDscFile' ($szBranch) on '$szPlatform'/'$szArch' "
        break;
done

# Helper variable
szAddArch="";
if [ $szArchitect = "i386" ]; then
	szAddArch="-i386";
fi


echo "Select DSC Filebasename:"
select szDscFile in `ls ./pbuilder/$szPlatform$szAddArch\_result/*.dsc`
do
        break;
done

# Loop through architects
for szArchitect in $szArch;
do
	# Helper variable
	szAddArch="";
	if [ $szArchitect = "i386" ]; then
	        szAddArch="-i386";
	fi

        # Set Basename!
        szDscFileBase=`basename $szDscFile .dsc`

        #pbuilder-dist precise create
        APPENDSUFFIX="_$szArchitect.changes"
#       pbuilder-dist $szPlatform $szArchitect build $szDscFile 
        dput $szBranch ./pbuilder/$szPlatform$szAddArch\_result/$szDscFileBase$APPENDSUFFIX
done;


