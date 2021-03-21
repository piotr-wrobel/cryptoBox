#!/bin/bash
chmod -R +x bin
mkdir -p ~/bin
cp -a bin/* ~/bin/
mkdir -p ~/.cryptoBox/lib
mkdir -p ~/.cryptoBox/boxes
cp -a lib/* ~/.cryptoBox/lib

if [[ -z $(echo ${PATH} | grep "${HOME}/bin") ]]; then
 cat << EOF

!!! The ${HOME}/bin directory is not contained in the \$PATH variable. Add the following snippet to the ${HOME}/.profile file, then restart the console

### BEGIN OF SNIPPET

home_bin_path="\${HOME}/bin"
if [ -n "\${PATH##*\${home_bin_path}}" ] && [ -n "\${PATH##*\${home_bin_path}:*}" ]; then
    export PATH=\${home_bin_path}:\$PATH
fi

### END OF SNIPPET

After this type cryptoBox -h to start using cryptoBox !

EOF
else
  echo
  echo "Installation completed, type cryptoBox -h to start using cryptoBox !"
  echo
fi
