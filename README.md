# Custom CKAN Image

This directory is intended to become a separate repo for building the SEAMWARE CKAN image.

The image installs the custom extensions directly from GitHub, so it does not depend on local source checkouts or bind mounts.

## Included extensions

Official extensions installed during build:

- `ckanext-envvars`
- `ckanext-harvest`
- `ckanext-scheming`
- `ckanext-dcat`

SEAMWARE extensions installed during build:

- `ckanext-oidc4vc`
- `ckanext-tmforum`
- `ckanext-dsif`
- `ckanext-ngsild`

## Default configuration baked into the image

The Dockerfile sets non-secret defaults that match the current custom stack:

- `CKAN__PLUGINS`
- Scheming/DCAT dataset schema defaults
- DSIF catalog defaults
- OIDC4VC defaults except the client secret
- TMForum default owner role

These values can still be overridden at runtime with environment variables.

## Build

Build the image from this directory:

```bash
docker build --platform=linux/amd64 -t seamware/ckan:2.11-custom .
```

You can also override the CKAN version or plugin refs:

```bash
docker build \
  --platform=linux/amd64 \
  --build-arg CKAN_VERSION=2.11.5 \
  --build-arg CKANEXT_DCAT_REF=v2.4.3 \
  --build-arg CKANEXT_OIDC4VC_REF=main \
  --build-arg CKANEXT_TMFORUM_REF=main \
  --build-arg CKANEXT_NGSILD_REF=main \
  --build-arg CKANEXT_DSIF_REF=main \
  -t seamware/ckan:2.11-custom .
```

The upstream `ckan/ckan-base` tags are currently published as `linux/amd64` images only, so ARM hosts such as Apple Silicon need the explicit platform setting during build and runtime.

## Run with Docker Compose

This repo includes a standalone `docker-compose.yml` that assumes the CKAN image has already been built and tagged.

1. Create the runtime env file:

   ```bash
   cp .env.example .env
   ```

2. Adjust the values in `.env`, especially:

   - `CKAN_IMAGE`
   - `CKAN_SITE_URL`
   - `CKAN___BEAKER__SESSION__SECRET`
   - `CKAN___API_TOKEN__JWT__ENCODE__SECRET`
   - `CKAN___API_TOKEN__JWT__DECODE__SECRET`
   - `CKAN_SYSADMIN_EMAIL`
   - `CKANEXT_OIDC4VC_CLIENT_SECRET`

3. Start the stack:

   ```bash
   docker compose up -d
   ```

This compose stack starts:

- `ckan`
- `gather-consumer`
- `fetch-consumer`
- `db`
- `solr`
- `redis`

The PostgreSQL init scripts under `postgresql/docker-entrypoint-initdb.d/` create the CKAN and DataStore databases automatically on first boot.

## Runtime requirements

This repo only builds the CKAN image. A working deployment still needs the usual CKAN runtime services:

- PostgreSQL
- Solr
- Redis
- optionally DataPusher

At runtime you still need to provide the site-specific and secret values, for example:

```bash
CKAN_SITE_URL=https://catalog.example.com
CKAN_SQLALCHEMY_URL=postgresql://ckan:pass@db/ckan
CKAN_SOLR_URL=http://solr:8983/solr/ckan
CKAN_REDIS_URL=redis://redis:6379/1
CKANEXT_OIDC4VC_CLIENT_SECRET=replace-me
```

Depending on your deployment, you may also need:

- `CKAN__BEAKER__SESSION__SECRET`
- `CKAN__API_TOKEN__JWT__ENCODE__SECRET`
- sysadmin bootstrap variables
- SMTP settings
- DataStore settings

## Plugin notes

### OIDC4VC

The image includes the default OIDC4VC settings currently used by the project, but the client secret is intentionally left for runtime injection.

### TMForum

The `tmforum` extension is installed in the image, but TMForum API endpoints are configured per harvest source, not globally in the image.

### Harvest consumers

If you use TMForum harvesting, the web container is not enough by itself. You still need the two harvest consumers running:

```bash
ckan -c /srv/app/ckan.ini harvester gather-consumer
ckan -c /srv/app/ckan.ini harvester fetch-consumer
```

## Suggested next repo additions

Useful next additions for this standalone repo are:

- optional `docker-entrypoint.d/` scripts for instance-specific config
- NGINX or reverse-proxy config
- CI workflow to build and publish the image
