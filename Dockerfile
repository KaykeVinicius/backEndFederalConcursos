ARG RUBY_VERSION=3.4.1
ARG RAILS_ENV=production

FROM ruby:${RUBY_VERSION}-slim AS base
WORKDIR /rails

RUN apt-get update -qq && apt-get install --no-install-recommends -y \
    curl libpq5 libvips \
    && rm -rf /var/lib/apt/lists /var/cache/apt/archives

FROM base AS build
ARG RAILS_ENV
ENV BUNDLE_PATH="/usr/local/bundle"

RUN apt-get update -qq && apt-get install --no-install-recommends -y \
    build-essential git libpq-dev libyaml-dev pkg-config \
    && rm -rf /var/lib/apt/lists /var/cache/apt/archives

RUN if [ "$RAILS_ENV" = "production" ]; then \
      bundle config set --global without 'development test'; \
    fi

COPY Gemfile Gemfile.lock ./
RUN bundle install && \
    rm -rf ~/.bundle/ "${BUNDLE_PATH}"/ruby/*/cache "${BUNDLE_PATH}"/ruby/*/bundler/gems/*/.git

COPY . .
RUN bundle exec bootsnap precompile --gemfile app/ lib/ 2>/dev/null || true

FROM base
ARG RAILS_ENV
ENV RAILS_ENV=${RAILS_ENV} \
    BUNDLE_PATH="/usr/local/bundle"

COPY --from=build /usr/local/bundle /usr/local/bundle
COPY --from=build /rails /rails

RUN groupadd --system --gid 1000 rails && \
    useradd rails --uid 1000 --gid 1000 --create-home --shell /bin/bash && \
    chown -R rails:rails db log storage tmp Gemfile.lock
USER rails

ENTRYPOINT ["/rails/bin/docker-entrypoint"]
EXPOSE 3000
CMD ["./bin/rails", "server", "-b", "0.0.0.0"]
