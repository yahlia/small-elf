#!/usr/bin/env bash

# x86 ELF executable in 76 bytes
#
# this work exploits the permissive implementation of the kernel's parser/loader
# to:
# - embed code/data in the unused bytes in the binary.
# - reduce the binary size by removing some unused fields.
#
# you can modify 36 out of 76 bytes with some limitations.
# this requires the common 4KiB page size.
#
# layout of the binary is as follows. the non-hexadecimal values are the
# bytes you can modify.
#
# hex="\            #
# 7f454c46\         #
# 01\               #
# 01\               #
# 01\               #
# 00\               #
# pppppppppppppppp\ # entrypoint
# 0200\             #
# 0300\             #
# 01vvvvvv\         #
# 0800rrrr\         #
# 34000000\         # -=S
# oooooooo\         #
# llllllll\         #
# 3400\             # -=S
# 2000\             #
# 0100\             # | you can optionally remove these 8 bytes because the
# ssss\             # | following 8 bytes coincides with e_phnum=0x0001 and
# 0000\             # | e_shnum=0x0000. adjust other fields by S=8.
# iiii\             # | the example binary does remove it.
# 01000000\         #
# 00000000\         #
# 0000rrrr\         # must be a multiple of the page size.
# PPPPPPPP\         #
# 54000000\         # -=S
# mmmmmmmm\         # >= 0x54-S
# 07LLLLLL\         # +W to use p_memsz otherwise SEGV's during zero fill init
# 00100000\         # page size
# "                 #
#
# reference:
# - https://man7.org/linux/man-pages/man5/elf.5.html
# - https://github.com/torvalds/linux/blob/master/fs/binfmt_elf.c

hex="\
7f454c46\
01\
01\
01\
00\
b93600696343eb10\
0200\
0300\
01696365\
08006963\
2c000000\
b206b004\
cd80eb18\
2c00\
2000\
01000000\
00000000\
00006963\
65636174\
4c000000\
b001cd80\
07636174\
00100000\
"

cd $(dirname $(realpath ${BASH_SOURCE[0]}))

FILE=frieren

echo -n $hex | xxd -p -r > $FILE && chmod +x $FILE && ./$FILE
