# Dockerfile for deploying the dummy app (spec/dummy) to Fly.io.
# Build context must be the repo root so the engine (path: "../../") is available.

ARG RUBY_VERSION=4.0.1
FROM docker.io/library/ruby:${RUBY_VERSION}-slim AS build

WORKDIR /app
COPY . .

# Install build deps and install gems from spec/dummy (Gemfile has path: "../../")
RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y build-essential libyaml-dev pkg-config git && \
    rm -rf /var/lib/apt/lists /var/cache/apt/archives

WORKDIR /app/spec/dummy
ENV BUNDLE_DEPLOYMENT=1 \
    BUNDLE_PATH=/usr/local/bundle \
    BUNDLE_WITHOUT=development:test

RUN bundle install && \
    rm -rf ~/.bundle/ "${BUNDLE_PATH}"/ruby/*/cache "${BUNDLE_PATH}"/ruby/*/bundler/gems/*/.git

RUN bundle exec bootsnap precompile -j 1 --gemfile
RUN bundle exec bootsnap precompile -j 1 app/ lib/ 2>/dev/null || true
# Rails needs SECRET_KEY_BASE in production; use a build-time dummy. DB in /tmp so precompile never touches real storage.
RUN RAILS_ENV=production \
    SECRET_KEY_BASE=buildkey \
    DATABASE_URL=sqlite3:///tmp/precompile.sqlite3 \
    bundle exec rails assets:precompile

# Final stage
FROM docker.io/library/ruby:${RUBY_VERSION}-slim

WORKDIR /rails

RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y curl libjemalloc2 sqlite3 && \
    ln -sf /usr/lib/$(uname -m)-linux-gnu/libjemalloc.so.2 /usr/local/lib/libjemalloc.so && \
    rm -rf /var/lib/apt/lists /var/cache/apt/archives

ENV RAILS_ENV=production \
    BUNDLE_PATH=/usr/local/bundle \
    LD_PRELOAD=/usr/local/lib/libjemalloc.so

RUN groupadd --system --gid 1000 rails && \
    useradd rails --uid 1000 --gid 1000 --create-home --shell /bin/bash
USER 1000:1000

COPY --from=build /usr/local/bundle /usr/local/bundle
COPY --from=build /app/spec/dummy /rails

ENTRYPOINT ["/rails/bin/docker-entrypoint"]
EXPOSE 8080
CMD ["bundle", "exec", "rails", "server", "-b", "0.0.0.0"]
