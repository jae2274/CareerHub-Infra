#!/bin/bash

result=$(git branch|grep '^\*')


echo "{ \"branch\": \"${result//[\*\ ]/}\" }"