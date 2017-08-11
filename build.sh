#!/bin/bash

function semverParseInto() {
    local RE='[^0-9]*\([0-9]*\)[.]\([0-9]*\)[.]\([0-9]*\)\([0-9A-Za-z-]*\)'
    #MAJOR
    eval $2=`echo $1 | sed -e "s#$RE#\1#"`
    #MINOR
    eval $3=`echo $1 | sed -e "s#$RE#\2#"`
    #PATCH
    eval $4=`echo $1 | sed -e "s#$RE#\3#"`
    #SPECIAL
    eval $5=`echo $1 | sed -e "s#$RE#\4#"`
}

DOCKERHUB=digitalcanvasdesign/php-fpm
MAJOR=0
MINOR=0
PATCH=0
SPECIAL=""

semverParseInto $1 MAJOR MINOR PATCH SPECIAL

TAGS=(
    "-t $DOCKERHUB:latest"
    "-t $DOCKERHUB:$MAJOR.$MINOR-fpm"
    "-t $DOCKERHUB:$MAJOR.$MINOR.$PATCH-fpm"
)

docker build . ${TAGS[@]}
docker push $DOCKERHUB
