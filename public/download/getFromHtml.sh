#!/bin/bash
#sh getFromHtml.sh under the template fold
#Change filelist.csv to excel file, and give it to translator

LANG=C grep -r -n -v '^[[:cntrl:][:print:]]*$' . | grep -v "using UnityEngine;" | grep -v svn | grep -v //  | grep -v \* |  grep -v "\{\*" |  grep -v "\"Name\"" > ~/lj_2_3_server.csv

sed -i 's@\t@ @g' ~/lj_2_3_server.csv
sed -i 's@\([^:]*\):\([0-9]*\):@\1\t\2\t@' ~/lj_2_3_server.csv
