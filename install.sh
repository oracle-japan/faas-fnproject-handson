#!/bin/sh
set -e

# Install script to install fn

#version=`curl --silent https://api.github.com/repos/fnproject/cli/releases/latest  | grep tag_name | cut -f 2 -d : | cut -f 2 -d '"'`

command_exists() {
  command -v "$@" > /dev/null 2>&1
}

case "$(uname -m)" in
  *64)
    ;;
  *)
    echo >&2 'Error: you are not using a 64bit platform.'
    echo >&2 'Functions CLI currently only supports 64bit platforms.'
    exit 1
    ;;
esac

user="$(id -un 2>/dev/null || true)"

sh_c='sh -c'
if [ "$user" != 'root' ]; then
  if command_exists sudo; then
    sh_c='sudo -E sh -c'
  elif command_exists su; then
    sh_c='su -c'
  else
    echo >&2 'Error: this installer needs the ability to run commands as root.'
    echo >&2 'We are unable to find either "sudo" or "su" available to make this happen.'
    exit 1
  fi
fi

curl=''
if command_exists curl; then
  curl='curl -sSL -o'
elif command_exists wget; then
  curl='wget -qO'
elif command_exists busybox && busybox --list-modules | grep -q wget; then
  curl='busybox wget -qO'
else
    echo >&2 'Error: this installer needs the ability to run wget or curl.'
    echo >&2 'We are unable to find either "wget" or "curl" available to make this happen.'
    exit 1
fi

url='https://github.com/fnproject/cli/releases/download'

# perform some very rudimentary platform detection
case "$(uname)" in
  Linux)
    $sh_c "$curl /tmp/fn_linux $url/0.5.74/fn_linux"
    $sh_c "mv /tmp/fn_linux /usr/local/bin/fn"
    $sh_c "chmod +x /usr/local/bin/fn"
    fn --version
    ;;
  Darwin)
    $sh_c "$curl /tmp/fn_mac $url/$version/fn_mac"
    $sh_c "mv /tmp/fn_mac /usr/local/bin/fn"
    $sh_c "chmod +x /usr/local/bin/fn"
    fn --version
    ;;
  WindowsNT)
    $sh_c "$curl $url/$version/fn.exe"
    # TODO how to make executable? chmod? how to do tmp file and move?
    fn.exe --version
    ;;
  *)
    cat >&2 <<'EOF'

  Either your platform is not easily detectable or is not supported by this
  installer script (yet - PRs welcome! [fn/install]).
  Please visit the following URL for more detailed installation instructions:

    https://github.com/fnproject/fn

EOF
    exit 1
esac

cat >&2 <<'EOF'

        ______
       / ____/___
      / /_  / __ \
     / __/ / / / /
    /_/   /_/ /_/`

EOF
