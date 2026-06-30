#!/usr/bin/env bash
set -euo pipefail

# CI_QTDIR may be passed from workflow; fallback to /opt/Qt/6.8.3
QTDIR="${CI_QTDIR:-${QTDIR:-/opt/Qt/6.8.3}}"
echo "Fallback installer (Linux) target QTDIR=${QTDIR}"

# If already installed, exit
if [ -d "${QTDIR}/lib/cmake/Qt6ShaderTools" ]; then
  echo "Qt6ShaderTools already present at ${QTDIR}/lib/cmake/Qt6ShaderTools"
  ls -la "${QTDIR}/lib/cmake/Qt6ShaderTools" || true
  exit 0
fi

# Download Qt online installer (may be large)
INSTALLER="qt-unified-linux-x64-online.run"
if [ ! -f "${INSTALLER}" ]; then
  echo "Downloading Qt online installer..."
  wget -O "${INSTALLER}" "https://download.qt.io/official_releases/online_installers/qt-unified-linux-x64-online.run"
  chmod +x "${INSTALLER}"
fi

# NOTE: scripting the Qt installer reliably requires correct component IDs.
# This script runs the installer non-interactively with a minimal script that
# accepts defaults. If your CI environment blocks the installer, consider
# prebuilding a Qt image or using a self-hosted runner with Qt preinstalled.
echo "Running Qt installer (non-interactive attempt). This may take a while..."
sudo ./"${INSTALLER}" --script <(cat <<'QS'
function Controller() {}
Controller.prototype = {
  run: function() {
    gui.clickButton(buttons.NextButton);
    gui.clickButton(buttons.NextButton);
    gui.clickButton(buttons.NextButton);
    gui.clickButton(buttons.NextButton);
  }
}
QS
) || true

echo "Installer finished. Listing ${QTDIR}/lib/cmake"
ls -la "${QTDIR}/lib/cmake" || true
ls -la "${QTDIR}/lib/cmake/Qt6ShaderTools" || true
