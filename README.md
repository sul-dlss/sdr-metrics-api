# Metrics

An API for tracking and querying usage metrics for Stanford SDR objects.

## Requirements

- Ruby 3.2
- A database (SQLite locally, Postgres in production)

## Setup

Run the rails setup script to install dependencies and set up the database:

```bash
bin/setup
```

## Developing

Start a development server:

```bash
bin/rails server
```

## Testing

Code is linted with [Rubocop](https://rubocop.org/) and tested with [RSpec](https://rspec.info/) on each push to GitHub. You can run everything locally with:

```bash
bin/rake
```

For just the linter, or just the tests:

```bash
bin/rake rubocop
bin/rake spec
```

## Deploying

> TODO
