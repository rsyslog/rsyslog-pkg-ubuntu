PLATFORM="precise saucy"
ARCHTECT="amd64 i386"

echo "-------------------------------------"
echo "--- Login Virtual                 ---"
echo "-------------------------------------"
echo "Select Platform:"
select szPlatform in $PLATFORM
do
        echo "Select CPU Platform:"
        select szArchitect in $ARCHTECT
        do
		echo "Login into '$szPlatform'/'$szArchitect' "
		pbuilder-dist $szPlatform $szArchitect login --save-after-login
                break;
        done
        break;
done

#pbuilder-dist precise login --save-after-login
#pbuilder-dist precise i386 login --save-after-login

