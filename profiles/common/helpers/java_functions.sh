#!/usr/bin/env bash
# shellcheck disable=SC2155

### Java Environment Functions ###
# http://homepage.mac.com/shawnce/misc/java_functions_bashrc.txt
#
# 2021-04-27 -db - fix aliases; allow setting minor java version; fix shellcheck errors/warnings
#
# 2014-02-10 -bm - edits to use /usr/libexec/java_home instead of JAVA_VERSION_DIRECTORY since 1.6 and 1.7 are in
#                   different location in Mavricks
# 2014-08-19 - only run on macs moved alias here instead of separate file b/c they aren't useful on linux  

# only run on macs
if [ "$(uname -s)" = "Darwin" ] ; then

    # aliases to set java version (don't error if the version doesn't exist)
    alias java7='setJava 1.7'
    alias java8='setJava 1.8'
    alias java9='setJava 9.0'
    alias java11='setJava 11.0'

    JAVA_FUNCTIONS_PATH="${BASH_SOURCE[0]}"
    JAVA_HOMECMD="/usr/libexec/java_home"
    J_BIN_SUBPATH="bin"

    function availableJVMs()
    {
        local jvm_string="JVMPlatformVersion"
        if [ "$1" = "long" ]; then
            jvm_string="JVMVersion"
        fi

        ${JAVA_HOMECMD} -X | grep -A1 "$jvm_string" | grep string | cut -d\> -f2 | cut -d\< -f1 | tr "\n" ' ' && echo ""
    }

    function listJava()
    {
        local jvms=$(availableJVMs "$1")
        echo "Available JVMs: $jvms"

        echo "Current Java:"
        java -version
    }

    function setJava()
    {
        local jvm_version_type="short"

        if [ ${#1} -gt 4 ]; then
            jvm_version_type="long"
        fi

        local target_jvm=""
        local jvms=$(availableJVMs "$jvm_version_type")

        # Validate that the user requested an available JVM present on the system

        for jvm in $jvms ; do
            if [ "$jvm" = "$1" ]; then
                target_jvm=$1   
            fi
        done

        if [ "$target_jvm" = "" ]; then
            echo "Unsupported Java version requested"
            return;
        fi

        echo "Configuring Shell Environment for Java $target_jvm"

        echo "Unsetting current Java version"
        _unsetJava

        # Generate the paths needed for the JVM requested
        local jcmd="$(${JAVA_HOMECMD} -v "$target_jvm")/${J_BIN_SUBPATH}"
        local jhome="$(${JAVA_HOMECMD} -v "$target_jvm")"

        # We save the original path so we can toggle back if unset
        ORIGINAL_PATH="$PATH"
        PATH="$jcmd:${PATH}"

        # We save the original JAVA_HOME so we can toggle back if unset
        ORIGINAL_JAVA_HOME="$JAVA_HOME"
        JAVA_HOME="$jhome"

        # Update command prompt mode tag to note JVM setting
        CURRENT_MODE_STRING="J$target_jvm"

        echo "Current Java:"
        java -version
    }

    function _unsetJava()
    {
        if [ "$CURRENT_MODE_STRING" != "" ]; then
            PATH="$ORIGINAL_PATH"
            JAVA_HOME="$ORIGINAL_JAVA_HOME"
            CURRENT_MODE_STRING=""
        fi
    }

    function unsetJava()
    {
        echo "Configuring Shell Environment for default Java"
        _unsetJava

        echo "Current Java:"
        java -version
    }

    # List the functions this script creates
    function javaFuncts()
    {
        awk '/function/ && !/_/ {if ($1 == "function") print substr($2, 0, length($2)-2)}' "$JAVA_FUNCTIONS_PATH"
    }

fi
