# SEAMWARE CKAN Helm chart

This chart deploys the same custom CKAN stack currently described by `docker-compose.yml`:

- the custom `seamware/ckan:2.11-custom` image
- the CKAN web workload
- the `gather-consumer` and `fetch-consumer` harvester workers
- PostgreSQL with the same CKAN/DataStore bootstrap scripts
- Solr
- Redis

## Install

```bash
helm install seamware-ckan ./ckan-docker/ckan-docker/helm
```

For a first real deployment, override at least these values:

```bash
helm install seamware-ckan ./ckan-docker/ckan-docker/helm \
  --set ckan.siteUrl=https://catalog.example.com \
  --set ckan.security.beakerSessionSecret=replace-me \
  --set ckan.security.apiTokenJwtEncodeSecret=string:replace-me \
  --set ckan.security.apiTokenJwtDecodeSecret=string:replace-me \
  --set ckan.sysadmin.email=admin@example.com \
  --set ckan.sysadmin.password=replace-me \
  --set ckan.oidc4vc.clientSecret=replace-me \
  --set postgresql.auth.password=replace-me
```

## Main values

- `image.repository` / `image.tag`: custom CKAN image to deploy.
- `ckan.siteUrl`: public CKAN URL.
- `ckan.plugins`: runtime plugin list passed to `CKAN__PLUGINS`.
- `web.storage.*`: persistent storage for `/var/lib/ckan`.
- `postgresql.enabled`, `solr.enabled`, `redis.enabled`: disable these when using external services.
- `postgresql.host`, `solr.host`, `redis.host`: external service hostnames when the corresponding internal service is disabled.
- `workers.*.replicaCount`: replicas for the two harvest consumers.
- `ingress.*`: optional ingress configuration.

## External services

When using managed PostgreSQL, Solr, or Redis:

1. Set `postgresql.enabled=false`, `solr.enabled=false`, or `redis.enabled=false`.
2. Provide the matching `*.host` value.
3. Keep the CKAN database and Redis DB settings aligned with the target service.

The chart will still compute the CKAN connection URLs from the same values file.

## Notes

- The default web deployment uses a single replica and a ReadWriteOnce volume for CKAN storage.
- The CKAN image already performs its `prerun.py` bootstrap, so the chart relies on the same startup behavior as the Docker setup.
