!#/bin/sh
TARGZFILES=` ls -d */`
PLATFORM="precise saucy"

echo "-------------------------------------"
echo "--- Prepare Release               ---"
echo "-------------------------------------"

select szPrepareDir in $TARGZFILES
do
        echo "Select Ubuntu DIST:"
        select szPlatform in $PLATFORM
        do
                echo "Preparing '$szPrepareDir'"
                break;
        done
        break;
done

#szSourceBase=`basename $szSourceFile .tar.gz`
#szSourceBase=`echo $szSourceBase | sed 's/_/-/'`

#echo "$szSourceBase";
#exit; 

#tar xfz $szSourceFile 
#mv $szSourceFile $szReplaceFile.orig.tar.gz

cp -r $szPlatform/debian $szPrepareDir
cd $szPrepareDir
dch -D $szPlatform -i
debuild -S -rfakeroot -kAEF0CF8E

# Save Changes back now
cd ..
szDebian="debian"
echo    # (optional) move to a new line
read -p "Copy $szPrepareDir$szDebian folder back to $szPlatform/$szDebian (y/n)? " RESULT
echo    # (optional) move to a new line
if [ "$RESULT" == "y" ]; then

	cp -r $szPrepareDir$szDebian $szPlatform
	echo "$szPrepareDir$szDebian copied back."
fi

