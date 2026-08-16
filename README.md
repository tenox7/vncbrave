# Brave Origin via VNC as a Docker Container

[Brave Origin](https://brave.com/origin/linux/) is a standalone, stripped-down
build of the Brave browser (free on Linux). This container runs it headless on
a TigerVNC X11 server, exposing only the browser over VNC.

## Running

```sh
docker run -d \
    --name vncbrave \
    -p 5900:5900 \
    tenox7/vncbrave:latest
```

This container is dual architecture, AMD64 and ARM64, it can be run on Mac host with Apple Silicon, Raspberry PI, etc.

VNC Password is: `vncbrave`

## Persistent Profiles

If you want the profile to persist between sessions, mount `/home/vncbrave/.config/BraveSoftware` as a volume.
Either create a persistent Docker volume or bind mount to a folder on the host.

```sh
docker volume create vncbrave
docker run -d \
    --name vncbrave \
    -v vncbrave:/home/vncbrave/.config/BraveSoftware \
    -p 5900:5900 \
    tenox7/vncbrave:latest
```

## Download Redirect

I typically bind mount a folder exported via NFS to `/home/vncbrave/Downloads`.

```sh
-v /net/nas/Downloads:/home/vncbrave/Downloads
```

## Resolution

The **default** resolution is 1024x768. This is because I mostly work on workstations with 1280x1024 and I want a smaller window. However you can set custom resolution by using `WIDTH` and `HEIGHT` env variables.

```sh
docker volume create vncbrave
docker run -d \
    --name vncbrave \
    -v vncbrave:/home/vncbrave/.config/BraveSoftware \
    -p 5900:5900 \
    -e WIDTH=1600 -e HEIGHT=1200 \
    tenox7/vncbrave:latest
```

The server side runs TigerVNC which allows remote resizing. Requires TigerVNC compatible viewer.



## Desktop Name

The VNC desktop name follows the active Brave tab title, transliterated to ASCII.
Set `DESKTOP_NAME` to pin a static name instead.

```sh
-e DESKTOP_NAME=mybrowser
```

## VNC Client

It's recommended to use Tight or Tiger VNC client to reduce CPU usage and improve performance.

I have developed a VNC Viewer for Vintage Unix called [TenoxVNC](https://github.com/tenox7/tenoxvnc).

A collection of Tight VNC ports is available here:
http://osarchive.org/apps/vnc/tight/ports

## Useful keyboard shortcuts

- F6  - enters URL input box
- F8  - opens VNC menu, clipboard transfer etc
- F11 - Brave full screen mode

*Note:* As of TigerVNC Client 1.16.0, the default menu shortcut is Ctrl-Alt-M.
This can be changed to use other modifier keys as part of the command line
options with the  -ShortcutModifiers option. It only accepts modifer keys like
Ctrl,Shift,Alt,Win/Super. To set it up to use Control-Shift, use the following
argument.

*-ShortcutModifiers=Ctrl,Shift*

## Notes

Brave runs in the container with `--no-sandbox` (non-root, no user namespaces)
and `--disable-dev-shm-usage`. If you see renderer crashes under heavy use,
give the container more shared memory with `--shm-size=1g`.

The Brave Origin "free on Linux" first-run dialog is pre-accepted in the image
(`brave.origin.free_tier_accepted`), so it goes straight to the browser. With
the named-volume profile this carries over on first use; with an empty host
bind mount the dialog appears once and your choice then persists.

If you use this regularly, please support Brave by [One-time purchase](https://account.brave.com/?intent=checkout&product=origin).

FBI recommends installation of an [ad blocker](https://www.ic3.gov/Media/Y2022/PSA221221) (Brave ships with one built in).
