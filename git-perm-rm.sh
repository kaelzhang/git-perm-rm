#!/bin/bash

# Copyright (c) 2013 Kael Zhang <i@kael.me>, contributors
# http://kael.me/

# The MIT license

# Permission is hereby granted, free of charge, to any person obtaining
# a copy of this software and associated documentation files (the
# "Software"), to deal in the Software without restriction, including
# without limitation the rights to use, copy, modify, merge, publish,
# distribute, sublicense, and/or sell copies of the Software, and to
# permit persons to whom the Software is furnished to do so, subject to
# the following conditions:

# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.

# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
# LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
# OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
# WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
# ------------------------------------------------------------------------

# START #######################################################################

# For most cases, you should change these settings

# Print debug info or not
DEBUG=

# Usage information of your command.
# For most cases, you should change this.
# Take `rm` command for example
usage(){
    echo "usage: $COMMAND [-options] blah-blah ..."
    echo "       remove"
}

STRICT_ARGV=


##############################################################################
# DO NOT CHANGE THE LINES BELOW >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

# Simple basename: /bin/rm -> rm
COMMAND=${0##*/}

# tools
debug(){
    if [ -n "$DEBUG" ]; then
        echo "[D] $@" >&2
    fi
}

# parse argv --------------------------------------------------------------------------------

invalid_option(){
    # if there's an invalid option, `rm` only takes the second char of the option string
    # case:
    # rm -c
    # -> rm: illegal option -- c
    echo "$COMMAND: illegal option -- ${1:1:1}"
    usage

    # if has an invalid option, exit with 64
    exit 64
}

# print usage
if [[ "$#" = 0 ]]; then
    echo "git-perm-rm"
    usage

    # if has an invalid option, exit with 64
    exit 64
fi

REMAINS=
FLAGS=

FLAG_END=

remain_i=0
arg_i=0

split_push_arg(){
    # remove leading '-' and split combined short options
    # -vif -> vif -> v, i, f
    split=`echo ${1:1} | fold -w1`

    local arg
    for arg in ${split[@]}
    do
        FLAGS[arg_i]="-$arg"
        ((arg_i += 1))
    done
}

push_arg(){
    FLAGS[arg_i]=$1
    ((arg_i += 1))
}

push_remain(){
    REMAINS[remain_i]=$1
    ((remain_i += 1))
}

# pre-parse argument vector
while [ -n "$1" ]
do
    # case:
    # rm -v abc -r --force
    # -> -r will be ignored
    # -> args: ['-v'], files: ['abc', '-r', 'force']
    if [[ -n "$FLAG_END" ]]; then
        push_remain $1

    else
        case $1 in

            # case:
            # rm -v -f -i a b

            # case:
            # rm -vf -ir a b

            # ATTENSION: 
            # A wildcard in bash is not perl regex,
            # in which `'*'` means "anything" (including nothing)
            -[a-zA-Z]*)
                split_push_arg $1; debug "short option $1"
                ;;

            # rm --force a
            --[a-zA-Z]*)
                push_arg $1; debug "option $1"
                ;;

            # rm -- -a
            --)
                FLAG_END=1; debug "divider --"
                ;;

            # case:
            # rm -
            # -> args: [], files: ['-']
            *)
                push_remain $1; debug "file $1"

                # If strict mode on, flags must come before any remain items
                if [[ -n "$STRICT_ARGV" ]]; then
                    FLAG_END=1
                fi
                ;;
        esac
    fi

    shift
done

# END #######################################################################

# Your own logic >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

# parse options
for arg in ${FLAGS[@]}
do
    case $arg in

        # There's no --help|-h option for rm on Mac OS 
        # [hH]|--[hH]elp)
        # help
        # shift
        # ;;

        -r)
            RECURSIVE=" -r";        debug "force        : $arg"
            ;;

        *)
            invalid_option $arg
            ;;
    esac
done

# --------------------------------------------------------------------------------------------------------

if [[ ${#REMAINS[@]} = "0" ]];then
    echo "Please provide a path!"
    exit 1
fi

for file in ${REMAINS[@]}
do
    read -p "This operation will permanent remove \"${file}\" from your git repository, are you sure?(y/n) " -n 1 -r

    if [[ $REPLY =~ ^[Yy]$ ]]; then
        git filter-branch --force --index-filter "git rm --cached --ignore-unmatch ${file}${RECURSIVE}"  --prune-empty --tag-name-filter cat -- --all
    fi
done


