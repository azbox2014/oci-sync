#!/bin/bash

filter=$1

if [[ -z ${filter} ]]; then
    echo "Please input filter type"
    exit 1
fi

if [[ ${filter} == 1 ]]; then
    grep -E '^v[0-9]+(\.[0-9]+){2}$'
elif [[ ${filter} == 2 ]]; then
    grep -E '^[0-9]+(\.[0-9]+){2}$'
else
    echo "Not supported filter type"
    exit 1
fi
