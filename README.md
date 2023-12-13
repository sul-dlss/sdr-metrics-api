# SDR Metrics API

[![CI](https://github.com/sul-dlss/sdr-metrics-api/actions/workflows/ci.yml/badge.svg)](https://github.com/sul-dlss/sdr-metrics-api/actions/workflows/ci.yml)

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

## Usage

### Tracking metrics

Event tracking is done via [Ahoy](https://github.com/ankane/ahoy)'s built-in API. Clients should use the [ahoy.js](https://github.com/ankane/ahoy.js) library, which handles submitting POST requests to the API automatically.

Event submissions should include the DRUID of the object being tracked, which will be used to associate the event with the object. Other attributes can be included as needed.

Each time an event is logged, it is associated with a visit, which identifies the device and user. If the cookie provided by the client does not match an existing visit or a configurable amount of time has elapsed, a new visit will be created.

#### Views

To track views of an object, use the `trackView()` method, which creates an event with the built-in type `$view`:

```javascript
ahoy.trackView({ druid: "py305sy7961" });
```

#### Downloads

Downloads are tracked by creating an event with the type `download`:

```javascript
ahoy.track("download", { druid: "py305sy7961" });
```

### Querying metrics

Metrics can be queried by a given object's DRUID:

```bash
curl http://localhost:3000/py305sy7961/metrics
```

The response is a single JSON object with total counts for each tracked event type.
  
```json
{
  "views": 2340,
  "downloads": 223,
  "unique_views": 993,
  "unique_downloads": 220
}
```

Counts labeled "unique" are deduplicated by visit, so that multiple events coming from the same device in a short time period are only counted once.

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

The application is deployed automatically by Jenkins (sul-ci).

Merging to `main` will trigger a staging deploy, and creating a github release with a `v` tag will trigger a production deploy.

To deploy manually, you can use capistrano:

```bash
cap stage deploy
cap prod deploy
```
