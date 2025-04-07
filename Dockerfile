FROM buildpack-deps:stable-curl AS downloader

WORKDIR /tmp

RUN curl -fsSLo setup_16.x https://deb.nodesource.com/setup_20.x \
 && curl -fsSLo setup_14.x https://deb.nodesource.com/setup_22.x \
 && curl -fsSLo volta.sh https://get.volta.sh

FROM buildpack-deps:stable

RUN groupadd -g 1000 amplify \
 && useradd -g 1000 -l -m -s /usr/bin/zsh -u 1000 amplify

COPY --from=downloader /tmp/setup_14.x /tmp/setup_20.x
COPY --from=downloader /tmp/setup_16.x /tmp/setup_22.x
COPY --from=downloader /tmp/volta.sh /tmp/volta.sh

ENV PATH="${PATH}:/root/.volta/bin"

RUN apt-get update -qq \
 && apt-get install -qqy --no-install-recommends gcc g++ make openssl git \
 && bash /tmp/setup_20.x \
 && bash /tmp/setup_22.x \
 && apt-get install -qqy --no-install-recommends nodejs \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/* /var/log/apt/* /var/log/alternatives.log /var/log/dpkg.log /var/log/faillog /var/log/lastlog /tmp/setup_20.x /tmp/setup_22.x

RUN bash /tmp/volta.sh \
 && volta install node@lts yarn

USER amplify

ENV PATH="${HOME}/.local/bin:${PATH}:${HOME}.volta/bin"

WORKDIR /home/amplify

RUN bash /tmp/volta.sh \
 && npm config set prefix "${HOME}/.local" \
 && volta install node@lts yarn
