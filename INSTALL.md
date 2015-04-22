--------
Installation instructions (or something close to that)
--------

--------
Scripts to execute
--------

repack.sh 
   Converts the original package-release.tar.gz filename to package_release.orig.tar.gz
   Creates the package_release directory


./uploadppa.sh 
```
--------------------------------------
--- Prep Release and Upload to PPA ---
--------------------------------------
1) rsyslog-7.6.6/      4) rsyslog-8.5.0/      7) rsyslog-8.8.0.ad1/
2) rsyslog-8.4.1/      5) rsyslog-8.6.0.r1/   8) rsyslog-8.9.0/
3) rsyslog-8.4.2.ad1/  6) rsyslog-8.7.0/
#? 
```
   You then type the number to select the version you want to package.

```
Select BRANCH:
1) v7-stable
2) v8-stable
3) v8-devel
#? 
```
   Again, type the number for the branch. Usually 2) v8-stable.

```
Select Ubuntu DIST:
1) precise
2) trusty
#? 
```
   Select the Ubuntu DIST the package is for. If both, you need to repeat the whole process.

```
Generate Changelog entry for trusty/v8-stable (y/n)? 
```

   Usually (y). An editor will open the .dsc file for the package version and dist. Enter your Changelog content here. Save and close.

```
-------------------------------------
--- Select change file for upload ---
-------------------------------------
```

   Select the change file for the release to upload to launchpad. There the package will be built according to the specifications.



---------
Important Notes
---------

- Make sure, the root directory in the tar file has the same name as the base name of the tar.
- The changelog files are stored in the subdirectory of the DIST, like rsyslog-pkg-ubuntu/rsyslog/trusty/v8-stable/debian/


---------
Important Files
---------
config.sh  
   Global configs that are common to all/most of the scripts. Among other things, it identifies you (GPG Key) so you can sign your package. Edit to customize this installation for your needs; the other scripts should be left alone.

control
   Determines how the packages are built and names specific dependencies for the packages

rsyslog.install
   File locations for modules to be installed

rsyslog-*.install
   Specific module locations for separate packages

rsyslog.conf
   Default configuration file to be included in packages

rules
   Build parameters
