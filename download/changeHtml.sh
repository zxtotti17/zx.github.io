#!/bin/bash
#sh changeHtml.sh  result_file
#result_file' content
#file's path    line_no old_content     new_content

file=$1

if [ -z $file ]
then
        echo "Input result_file"
        exit
fi

while read line
do
        IFS=","
        arr=($line)
        filename=${arr[0]}
        line_num=${arr[1]}
        str_kr=${arr[2]}

        if [ $str_kr ]
        then
        echo $filename
        echo $line_num
        echo $str_kr

                sed -i ''$line_num' c\'$str_kr''  $filename
        else
                echo $line
        fi
done < $file
