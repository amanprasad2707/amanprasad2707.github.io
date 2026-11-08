
FROM ruby:3.2

RUN apt-get update && apt-get install -y \
    build-essential \
    nodejs \
    && rm -rf /var/lib/apt/lists/*

ENV BUNDLE_PATH=/usr/local/bundle
ENV BUNDLE_BIN=/usr/local/bundle/bin

WORKDIR /usr/src/app

RUN groupadd -g 1000 vscode && \
    useradd -m -u 1000 -g vscode vscode && \
    mkdir -p /usr/local/bundle && \
    chown -R vscode:vscode /usr/local/bundle

COPY --chown=vscode:vscode Gemfile Gemfile.lock ./

RUN gem install bundler -v "~> 4.0"

ENV PATH="/usr/local/bundle/bin:${PATH}"

USER vscode

RUN bundle install

COPY --chown=vscode:vscode . .

EXPOSE 4000

CMD ["bundle", "exec", "jekyll", "serve", "-H", "0.0.0.0", "-w", "--config", "_config.yml,_config_docker.yml"]
