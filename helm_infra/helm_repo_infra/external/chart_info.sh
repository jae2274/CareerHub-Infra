#!/bin/bash
set -e


CHART_NAME=`helm show chart $1 | grep name | awk '{print $2}'`
CHART_VERSION=`helm show chart $1 | grep version | awk '{print $2}'`

echo "{\"chart_name\":\"$CHART_NAME\",\"chart_version\":\"$CHART_VERSION\"}"