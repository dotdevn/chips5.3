#!/usr/bin/env bash
set -euo pipefail

bundle install
# Keep this assignment separate from any other app sharing the Postgres instance.
if [[ -n "${DATABASE_SCHEMA:-}" ]]; then
  bundle exec rails runner 'ActiveRecord::Base.connection.create_schema(ENV.fetch("DATABASE_SCHEMA"), if_not_exists: true)'
fi
bundle exec rails db:migrate
bundle exec rails db:seed
bundle exec rails assets:precompile
bundle exec rails assets:clean

