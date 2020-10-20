vi $(find . -name $1 | grep v8-st)
# use the following if you do NOT want to edit the generic
# Debian definitions; note: Debian packages for all versions are
# build with these definitions and the changelog must be updated on
# a new upstream release
#vi $(find . -name $1 | grep v8-st|grep -v Deb)
