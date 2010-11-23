#!/bin/bash

cd /home/bergman/bergman
rm crc_old.log
curl ftp://ftp.fu-berlin.de/pub/misc/movies/database/running-times.list.gz | gzip -d > running-times.list && ruby bergman.rb
