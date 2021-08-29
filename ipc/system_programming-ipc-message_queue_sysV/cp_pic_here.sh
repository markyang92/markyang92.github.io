#!/bin/bash
# This script copy .PNG file from src_file to dst_file
# Image file locate in "category lowercase/POST_FILE_NAME/"
# ex)
# Post Title: 2020-12-15-IPC-pipe.md
# category: IPC
# Then, System will find img file in ipc/IPC-pipe/

src_file="*.[pP]*"
dst_file="."

cp /mnt/c/Users/pllpo/OneDrive/사진/$src_file $dst_file
