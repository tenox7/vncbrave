#!/bin/bash
ratpoison &

profile=/home/vncbrave/.config/BraveSoftware/Brave-Origin

# Container Chromium flags: no sandbox (non-root, no userns), avoid the tiny
# default /dev/shm, and the basic password store so Brave does not block on a
# missing keyring. dbus-run-session gives it a session bus to silence the dbus
# connection errors Chromium otherwise logs.
while true
do
  # The profile lives on a volume, so a lock left behind by a previous run
  # names a container hostname that is gone; Brave reads that as "profile in
  # use on another computer" and exits. Each aborted launch also leaks a
  # preallocated 4MB metrics file that nothing ever collects.
  rm -f "$profile"/Singleton{Lock,Cookie,Socket}
  rm -rf "$profile/DeferredBrowserMetrics"

  dbus-run-session -- brave-origin --no-sandbox --disable-dev-shm-usage \
                      --password-store=basic --no-first-run --no-default-browser-check
  sleep 5
done
