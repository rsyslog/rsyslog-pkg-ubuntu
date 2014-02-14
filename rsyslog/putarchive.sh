#!/bin/sh
TARGZFILES=`ls *.dsc`
PLATFORM="precise quantal"
ARCHTECT="amd64 i386"

echo "-------------------------------------"
echo "--- RPMMaker                      ---"
echo "-------------------------------------"
echo "Select DSC Filebasename:"
select szDscFile in $TARGZFILES
do
        echo "Select Ubuntu DIST:"
        select szPlatform in $PLATFORM
        do
                echo "Select CPU Platform:"
                select szArchitect in $ARCHTECT
                do
                        echo "Moving Packages for  '$szDscFile' on '$szPlatform'/'$szArchitect' "
                        break;
                done
                break;
        done
        break;
done

szAddArch="";
if [ $szArchitect = "i386" ]; then
        szAddArch="-i386";
fi

szDscFileBase=`basename $szDscFile .dsc`

APPENDSUFFIX="_$szArchitect.changes"
# pbuilder-dist $szPlatform $szArchitect build $szDscFile
dput local ../pbuilder/$szPlatform$szAddArch\_result/$szDscFileBase$APPENDSUFFIX

