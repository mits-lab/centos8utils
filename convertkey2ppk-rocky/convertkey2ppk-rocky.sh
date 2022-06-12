#!/usr/bin/bash

## Monocle IT Solutions Labs ##
## Server - Utility - convertkey2ppk-rocky.sh / Rocky Linux 8.5 ##
## Rev. 2022021920 ##

# The MIT License (MIT)
# 
# Copyright (c) 2022 Monocle IT Solutions/convertkey2ppk-rocky.sh
# 
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
# 
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.
#

# Convert RSA key from encrypted OpenSSH format (in the root directory) to Putty encrypted key format.

red='\e[0;31m'
green='\e[0;32'
yellow='\e[1;33'
normal='\e[0m' # No Color

_hostname=$(echo "$HOSTNAME")

echo -n -e "\n\nWelcome to the$red Key Converter Utility $normal\n"
echo -n -e "$red------------------------------------ $normal\n\n"

echo -n -e "Scanning the ROOT user's home directory for a key to convert.$red \n\nOne moment please.. $normal\n\n"

rm -f /root/decrypted_key.key >/dev/null 2>&1
rm -f /root/passphrase.txt >/dev/null 2>&1

ls /root | grep "\.key"

echo -n -e "\n\n"
echo -n -e "Enter the full name of the key from the list above you would like to convert.\n"
echo -n -e "key: "
read _key

if [ -z "$_key" ]; then
    echo -n -e "\nMissing key name...try again.\n"
    exit 1
fi

echo -n -e "\n\n"
echo -n -e "Enter any applicable password to unlock the key, if required.\n"
echo -n -e "password: "
read _password

echo -n -e "\n\nProcessing request.$red One moment please.. $normal\n\n"

# Install Convert RSA key from encrypted OpenSSH format to Putty encrypted key format.
echo -n -e "\nCompleting encryption key conversion... \n"

dnf -y --quiet install putty >/dev/null 2>&1

# Add below variable to passphrase.txt file to feed input into puttygen 
echo "$_password" > /root/passphrase.txt
chmod 600 /root/passphrase.txt

cp /root/${_key} /root/${_key}.ppk
chmod 600 /root/${_key}.ppk
ssh-keygen -p -P "${_password}" -N "" -m pem -f /root/${_key}.ppk >/dev/null 2>&1
openssl rsa -in /root/${_key}.ppk -out /root/${_key}.ppk >/dev/null 2>&1
ssh-keygen -N "${_password}" -p -f /root/${_key}.ppk >/dev/null 2>&1
puttygen /root/${_key}.ppk -O private -o /root/${_key}.ppk --old-passphrase /root/passphrase.txt  >/dev/null 2>&1

dnf -y --quiet remove putty >/dev/null 2>&1

echo -n -e "\nCleaning up temp files.. \n"

rm -f /root/passphrase.txt
#rm -f /root/putty_plz-delete.key

echo -n -e "\nHere's your key. \n\n"
cat /root/${_key}.ppk

#rm -f *.ppk

echo -n -e "\n\n\n"

exit 0
