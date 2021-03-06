#!/bin/bash

dir="$(dirname "$0")"
: ${NETLIFY_REPO_URL="/opt/repo"}
NETLIFY_BUILD_BASE="/opt/buildhome"

cmd=$*

BUILD_COMMAND_PARSER=$(cat <<EOF
$cmd
EOF
)

. "$dir/run-build-functions.sh"

if [[ ! -d $NETLIFY_REPO_DIR ]]; then
  git clone $NETLIFY_REPO_URL $NETLIFY_REPO_DIR
fi
cd $NETLIFY_REPO_DIR

: ${NODE_VERSION="12.18.0"}
: ${RUBY_VERSION="2.7.1"}
: ${YARN_VERSION="1.22.4"}
: ${PHP_VERSION="5.6"}
: ${GO_VERSION="1.14.4"}
: ${SWIFT_VERSION="5.2"}
: ${PYTHON_VERSION="2.7"}

if [[ -n $SKIP_DEPENDENCIES ]]; then
  echo "SKIP_DEPENDENCIES set, skipping dependencies installation"
else
  echo "Installing dependencies"
  install_dependencies $NODE_VERSION $RUBY_VERSION $YARN_VERSION $PHP_VERSION $GO_VERSION $SWIFT_VERSION $PYTHON_VERSION

  echo "Installing missing commands"
  install_missing_commands

  echo "Verify run directory"
  set_go_import_path
fi

echo "Executing user command: $cmd"
eval "$cmd"
CODE=$?

exit $CODE
