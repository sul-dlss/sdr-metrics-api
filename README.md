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

Each time an event is logged it is associated with a visit that identifies characteristics of the device being used, including its user agent and [masked IP address](https://github.com/ankane/ahoy?tab=readme-ov-file#ip-masking). Visits are created automatically by `ahoy.js`.

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

You can also specify a particular file being downloaded:

```javascript
ahoy.track("download", { druid: "py305sy7961", file: "file_1.pdf" });
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

Counts labeled "unique" are deduplicated by visit, so that multiple events coming from the same device in a short time period are only counted once. This time period is configurable when initializing `ahoy.js`.

### Reports

If you would like to generate a CSV that reports views and downloads by DRUID you can:

```shell
bin/rake "report:downloads_and_views
```

That will generate a report from 2024-01-01 to the present. If you want to get the stats from 2024-06-01 to present you can:

```shell
bin/rake "report:downloads_and_views[2024-06-01]"
```

And similarly if you just want the month of June 2024 you can:

```shell
bin/rake "report:downloads_and_views[2024-06-01,2024-06-30]"
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

The application is deployed automatically by Jenkins (sul-ci).

Merging to `main` will trigger a staging deploy, and creating a github release with a `v` tag will trigger a production deploy.

To deploy manually, you can use capistrano:

```bash
cap stage deploy
cap prod deploy
```

## Design

*Why not use Google Analytics?*

Google Analytics includes a lot of features that we don't need, especially around marketing and advertising. It also doesn't record events in a useful way when triggered from an embedded iframe like we do in sul-embed. The "enhanced measurement" feature in GA4 captures some events, but not all, so we'd need to do some work to manually trigger the ones we want. And of course, Google can change the API at any time, which would break our integration.

*Why not use another hosted analytics service?*

Keeping the analytics tracking first-party means we have control over the data and can ensure it's not shared with third parties, as well as make guarantees about anonymization and retention. We also don't have to worry about a third-party service going out of business or changing their pricing model.

*Why not make metrics tracking a part of PURL?*

We need a database in which to store tracked metrics, but PURL was designed as a static site that serves XML from the filesystem. Rather than adding this database to PURL, we decided to create a separate service that can be used by other applications as well.
