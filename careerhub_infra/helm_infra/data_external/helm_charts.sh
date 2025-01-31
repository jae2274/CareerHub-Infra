#!/bin/bash

# ls 명령어를 통해 디렉토리 리스트를 가져옴
directories=$(ls -d $1/*/)

# 출력을 JSON 형식으로 변환
json_output='{"list":"'

# 디렉토리 리스트를 반복하면서 JSON 배열에 추가
for dir in $directories; do
    json_output+="$dir,"
done

# 마지막 쉼표(,) 제거
json_output="${json_output%,}"

# JSON 출력 완성
json_output+='"}'

# 최종 JSON 출력
echo $json_output
