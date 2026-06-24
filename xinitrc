#!/bin/bash
ratpoison &
# Container Chromium flags: no sandbox (non-root, no userns), avoid the tiny
# default /dev/shm, and the basic password store so Brave does not block on a
# missing keyring. dbus-run-session gives it a session bus to silence the dbus
# connection errors Chromium otherwise logs.
while true
do
  dbus-run-session -- brave-origin --no-sandbox --disable-dev-shm-usage \
                      --password-store=basic --no-first-run --no-default-browser-check
done
