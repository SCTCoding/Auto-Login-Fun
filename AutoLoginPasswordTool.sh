#! /bin/bash

#Copyright (c) 2016, Simon Carlson-Thies
#All rights reserved.

#Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

#1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.

#2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the
#documentation and/or other materials provided with the distribution.

#3. Neither the name of the copyright holder nor the names of its contributors may be used to endorse or promote products derived from this software
#without specific prior written permission.

#THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO,
#THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS
#BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE
#GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
#LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH
#DAMAGE.

echo "THIS SCRIPT WILL RECOVER PASSWORDS FROM AUTOLOGIN"
echo ""

# Obtain Basic Information
uname=$(whoami)
read -p "What is the password for $uname? " pw
echo ""
read -p "Where is the password to recover? Typical Path: /Volumes/Macintosh\ HD/private/etc/ " path
cd "$path"
pwd
echo ""

# Get Values For XOR
target=$(echo $pw | sudo -S xxd -l 240 -ps -u kcpassword)
mn=7D895223D2BCDDEAA3B91F7D895223D2BCDDEAA3B91F7D895223D2BCDDEAA3B91F7D895223D2BCDDEAA3B91F

# XOR Function
# Obtained from here:
# http://www.codeproject.com/Tips/470308/XOR-Hex-Strings-in-Linux-Shell-Script
# Author is Sanjay1982 (see http://www.codeproject.com/Members/Sanjay1982)
function  xor()
{
	local res=(`echo "$1" | sed "s/../0x& /g"`)
	shift 1
	while [[ "$1" ]]; do
	    local one=(`echo "$1" | sed "s/../0x& /g"`)
	    local count1=${#res[@]}
	    if [ $count1 -lt ${#one[@]} ]
	    then
	          count1=${#one[@]}
	    fi
	    for (( i = 0; i < $count1; i++ ))
	    do
	          res[$i]=$((${one[$i]:-0} ^ ${res[$i]:-0}))
	    done
	    shift 1
	done
	printf "%02x" "${res[@]}"
}

# Obtain HEX Password And Convert To ASCII
#recpw=$(xor $target $mn | xxd -r -p)
recpw=$(xor $target $mn | sed 's/0067.*//' | xxd -r -p)

echo "Here is your password."
echo $recpw

exit
