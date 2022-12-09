#!/bin/bash

alias gcommit='gitCommit'
alias gmerge='gitMerge'

gitCommit() {

    local COMMIT_MESSAGE=

    while getopts :m: FLAG; do
        case $FLAG in
            m)  COMMIT_MESSAGE=$OPTARG
                ;;
        esac
    done

    local BRANCH=$(currentBranch)
    if [[ -z $BRANCH ]]; then
        echo 'Not a git branch!'
        return 1
    fi

    if [[ -z $COMMIT_MESSAGE ]]; then
        git commit && git push origin $BRANCH
    else
        git commit -m $COMMIT_MESSAGE && git push origin $BRANCH 
    fi

}

gitMerge() {

    local CURRENT_BRANCH=$(currentBranch)
    local MERGE_BRANCH=$1

    if [[ -z $MERGE_BRANCH ]]; then
        echo 'Specify the branch to merge!'
        return 1
    fi

    if [[ $CURRENT_BRANCH == "master" ]]; then
        git merge $MERGE_BRANCH &&
            git push origin master &&
            git branch -d $MERGE_BRANCH &&
            git push origin :$MERGE_BRANCH
    else
        echo "Switch to master branch to merge!"
    fi
}

currentBranch() {

    local BRANCH=`git branch 2>&1 | grep "^*" | awk '{print $2}'`
    echo $BRANCH
}
