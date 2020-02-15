#!/usr/local/bin/bash

echo "before script"
java -version
if uname -a | grep x86_64 >/dev/null; then
    ARCH_SUFFIX=amd64
else
    ARCH_SUFFIX=i386
fi

: "${JDK_SWITCHER_DEFAULT:=openjdk8}"
: "${UJA:=update-java-alternatives}"

MAKE_FILE_PATH="/etc/make.conf"
OPENJDK_VENDOR="openjdk"
OPENJDK8_VERSION="8"
OPENJDK8_JAVA_HOME="/usr/local/openjdk8"

OPENJDK11_VERSION="11"
OPENJDK11_JAVA_HOME="/usr/local/openjdk11"

OPENJDK12_VERSION="12"
OPENJDK12_JAVA_HOME="/usr/local/openjdk12"

OPENJDK13_VERSION="13"
OPENJDK13_JAVA_HOME="/usr/local/openjdk13"


for config_file in /etc/default/jdk-switcher "${HOME}/.jdk_switcherrc" "${JDK_SWITCHER_CONFIG}"; do
    if [[ -f "${config_file}" ]]; then
        # shellcheck source=/dev/null
        source "${config_file}"
    fi
done

switch_to_specified_openjdk() {
	JAVA_VERSION="$1"
	JAVA_HOME="$2"
	echo "Switching to Openjdk version ($JAVA_VERSION) with java_home ($JAVA_HOME)"
	#create_make_file
	#replace_vendor_and_version "$JAVA_VERSION" "$OPENJDK_VENDOR"
	echo "Set JAVA_HOME to $JAVA_HOME"
	set JAVA_HOME="$JAVA_HOME"
	export JAVA_HOME
}

create_make_file() {
	if [[ -e "$MAKE_FILE_PATH" ]]; then
	  echo "File make already exists!"
	else
	  echo >> "$MAKE_FILE_PATH"
	fi
}

replace_vendor_and_version() {
	JAVA_VERSION="$1"
	JAVA_VENDOR="$2"
	sed -i '' '/^JAVA_VENDOR=/ d' "$MAKE_FILE_PATH"
	sed -i '' '/^JAVA_VERSION=/ d' "$MAKE_FILE_PATH"
	echo "JAVA_VENDOR=$JAVA_VENDOR">>"$MAKE_FILE_PATH"
	echo "JAVA_VERSION=$JAVA_VERSION">>"$MAKE_FILE_PATH"
}


print_home_of_openjdk() {
    JAVA_HOME="$1"
	echo "$JAVA_HOME"
}

warn_jdk_not_known() {
    echo "Sorry, but JDK '$1' is not known." >&2
}

warn_gcj_user() {
    echo "We do not support GCJ. I mean, come on. Are you Richard Stallman?" >&2
}

switch_jdk() {
    case "${1:-default}" in
        *gcj*)
            warn_gcj_user
            false
            ;;
        openjdk8 | jdk8 | 1.8.0 | 1.8 | 8.0)
            switch_to_specified_openjdk "$OPENJDK8_VERSION" "$OPENJDK8_JAVA_HOME"
            ;;
		openjdk11 | jdk11 | 1.11.0 | 1.11 | 11.0)
            switch_to_specified_openjdk "$OPENJDK11_VERSION" "$OPENJDK11_JAVA_HOME"
            ;;
		openjdk12 | jdk12 | 1.12.0 | 1.12 | 12.0)
            switch_to_specified_openjdk "$OPENJDK12_VERSION" "$OPENJDK12_JAVA_HOME"
            ;;
		openjdk13 | jdk13 | 1.13.0 | 1.13 | 13.0)
            switch_to_specified_openjdk "$OPENJDK13_VERSION" "$OPENJDK13_JAVA_HOME"
            ;;
        default)
            switch_to_specified_openjdk "$OPENJDK8_VERSION" "$OPENJDK8_JAVA_HOME"
            ;;
        *)
            warn_jdk_not_known "$1"
            false
            ;;
    esac
}

print_java_home() {
    typeset JDK
    JDK="$1"

    case "$JDK" in
        *gcj*)
            warn_gcj_user
            ;;
		openjdk8 | jdk8 | 1.8.0 | 1.8 | 8.0)
            print_home_of_openjdk "$OPENJDK8_JAVA_HOME"
            ;;
		openjdk11 | jdk11 | 1.11.0 | 1.11 | 11.0)
            print_home_of_openjdk "$OPENJDK11_JAVA_HOME"
            ;;
		openjdk12 | jdk12 | 1.12.0 | 1.12 | 12.0)
            print_home_of_openjdk "$OPENJDK12_JAVA_HOME"
            ;;
		openjdk13 | jdk13 | 1.13.0 | 1.13 | 13.0)
            print_home_of_openjdk "$OPENJDK13_JAVA_HOME"
            ;;
        default)
            print_home_of_openjdk "$OPENJDK8_JAVA_HOME"
            ;;
        *)
            warn_jdk_not_known "$JDK"
            ;;
    esac
}

jdk_switcher() {
    typeset COMMAND JDK
    COMMAND="$1"
    JDK="$2"

    case "$COMMAND" in
        use)
            switch_jdk "$JDK"
            ;;
        home)
            print_java_home "$JDK"
            ;;
        *)
            echo "Usage: jdk_switcher {use|home} [ JDK version ]" >&2
            false
            ;;
    esac

    return $?
}
