#!/bin/sh
set -e
export LIBGL_ALWAYS_SOFTWARE=1

# Prefer eglfs if available, otherwise use xcb
if [ -d "$(dirname "$(qmake -query QT_INSTALL_PLUGINS 2>/dev/null)/platforms")" ] && \
   [ -f "$(qmake -query QT_INSTALL_PLUGINS 2>/dev/null)/platforms/eglfs" ] ; then
  export QT_QPA_PLATFORM=eglfs
else
  export QT_QPA_PLATFORM=xcb
fi

export QML_IMPORT_PATH="$PWD/build/qml_modules${QML_IMPORT_PATH:+:$QML_IMPORT_PATH}"
exec "$PWD/build/tests/qm_grab" "$1" "$2"
