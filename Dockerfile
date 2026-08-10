FROM docker.io/debian:trixie-slim
EXPOSE 5900

# Brave Origin is Chromium-based and needs glibc, so this uses Debian
# (not Alpine/musl). TigerVNC, ratpoison for a minimal single-window WM,
# and enough fonts to cover nearly all web content including CJK and emoji.
# procps provides pgrep, used by /init to watch the Xtigervnc process.
RUN apt-get update && apt-get install -y --no-install-recommends \
        ca-certificates curl procps \
        tigervnc-standalone-server tigervnc-common tigervnc-tools \
        ratpoison xterm dbus-x11 \
        fonts-dejavu fonts-liberation fonts-noto fonts-noto-cjk \
        fonts-noto-color-emoji fonts-freefont-ttf fonts-terminus \
    && rm -rf /var/lib/apt/lists/*

# Brave Origin from the official APT repository. Architectures: amd64 arm64.
RUN curl -fsSL https://brave-browser-apt-release.s3.brave.com/brave-browser-archive-keyring.gpg \
        -o /usr/share/keyrings/brave-browser-archive-keyring.gpg \
    && curl -fsSL https://brave-browser-apt-release.s3.brave.com/brave-browser.sources \
        -o /etc/apt/sources.list.d/brave-browser-release.sources \
    && apt-get update \
    && apt-get install -y --no-install-recommends brave-origin \
    && rm -rf /var/lib/apt/lists/*

# Enterprise policy: suppress the "--no-sandbox is unsupported" warning infobar
# (the sandbox is intentionally off because we run non-root with no user namespaces).
RUN mkdir -p /etc/brave/policies/managed \
    && printf '%s' '{"CommandLineFlagSecurityWarningsEnabled":false}' \
       > /etc/brave/policies/managed/vncbrave.json

RUN useradd -m vncbrave
ADD xinitrc /home/vncbrave/.xinitrc
RUN chmod +x /home/vncbrave/.xinitrc
# Mirror the active Brave tab title into the VNC desktop name: ratpoison hooks
# fire on every title change and hand the title to vncconfig, which pushes it
# to connected clients via the RFB DesktopName pseudo-encoding.
ADD ratpoisonrc /home/vncbrave/.ratpoisonrc
ADD vncdesktopname /usr/local/bin/vncdesktopname
RUN chmod +x /usr/local/bin/vncdesktopname
RUN mkdir -p /home/vncbrave/.config/BraveSoftware/Brave-Origin/Default /home/vncbrave/.config/tigervnc
# Accept the Brave Origin "free on Linux" tier (browser-level, Local State) so the
# one-time first-run dialog is skipped.
RUN printf '%s' '{"brave":{"origin":{"free_tier_accepted":true}}}' \
    > '/home/vncbrave/.config/BraveSoftware/Brave-Origin/Local State'
# Turn off the new-tab background photo (profile-level pref) — a solid background
# is far cheaper to push over VNC than a full-bleed image.
RUN printf '%s' '{"brave":{"new_tab_page":{"show_background_image":false}}}' \
    > '/home/vncbrave/.config/BraveSoftware/Brave-Origin/Default/Preferences'
RUN sh -c 'echo vncbrave | vncpasswd -f > /home/vncbrave/.config/tigervnc/passwd'
RUN chmod 600 /home/vncbrave/.config/tigervnc/passwd
RUN chown -R vncbrave /home/vncbrave
ADD init /init
USER vncbrave
ENV USER=vncbrave
ENV WIDTH=1024
ENV HEIGHT=768
ENTRYPOINT ["/init"]
