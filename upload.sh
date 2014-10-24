!#/bin/sh
BRANCHES="v7-stable v7-devel v8-devel"
PLATFORM="precise quantal saucy"

echo "-------------------------------------"
echo "--- Upload Packages               ---"
echo "-------------------------------------"
echo "Upload into which branch?"
select szBranch in $BRANCHES
do
        echo "Uploading into Branch '$szBranch'
        "
        break;
done

# Sign Release first!

# Loop through PLATFORMS
for szPlattform in $PLATFORM;
do
	rm /home/al/archive/$szBranch/$szPlattform/Release.gpg
	gpg -bao /home/al/archive/$szBranch/$szPlattform/Release.gpg /home/al/archive/$szBranch/$szPlattform/Release
done;

# upload to server
# scp -r /home/al/archive/$szBranch/* makerpm@vserver.adiscon.com:/home/makerpm/ubunturepo/$szBranch/
rsync -au -e ssh --progress /home/al/archive/$szBranch/* makerpm@vserver.adiscon.com:/home/makerpm/ubunturepo/$szBranch/

