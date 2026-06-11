# Migrate Solr containers from Bitnami (legacy) to the official Solr image

## Context

In August 2025 Bitnami moved its free/community images to the `bitnamilegacy/*`
namespace and now gates the maintained `bitnami/*` catalog behind a paid
subscription. The repo's Solr containers are pinned to `bitnami/solr:*`, which
will stop receiving updates and effectively resolves to `bitnamilegacy/solr`.
To stay on a maintained, free, upstream-supported base we migrate to the
**official Apache Solr image** (`docker.io/_/solr`, i.e. `library/solr`).

Two setups are in scope (per the user's choice):

1. **`solr9/`** — a Dockerfile that builds the custom base image
   `bireme/solr:9` FROM `bitnami/solr:9.9.0`. It bakes in the **DeCS Lucene
   index** (`resources/decs/`) used by the BIREME *iahx* custom analyzers, and
   has a currently **commented-out** COPY of the iahx analyzer jar.
2. **`solr9-std/`** — a runtime deployment (`docker-compose` + `Makefile`) that
   runs `bitnami/solr:9.8.1` directly with host-mounted data/logs, behind the
   external `nginx-proxy` network.

`solr5/` already uses the official `solr:5.5.5` image and is **out of scope**.

### Why the official image differs (the crux of the migration)

| Concern            | Bitnami (`bitnami/solr`)                         | Official (`solr`)                                  |
|--------------------|--------------------------------------------------|----------------------------------------------------|
| Install dir        | `/opt/bitnami/solr`                              | `/opt/solr`                                        |
| `bin/solr`         | `/opt/bitnami/solr/bin/solr`                     | `/opt/solr/bin/solr`                               |
| Server resources   | `/opt/bitnami/solr/server/resources`             | `/opt/solr/server/resources`                       |
| Webapp lib         | `/opt/bitnami/solr/server/solr-webapp/webapp/WEB-INF/lib` | `/opt/solr/server/solr-webapp/webapp/WEB-INF/lib` |
| `SOLR_HOME`        | `/bitnami/solr/server/solr`                      | `/var/solr/data`                                   |
| Data volume        | `/bitnami`                                        | `/var/solr`                                         |
| Logs               | `/opt/bitnami/solr/logs`                          | `/var/solr/logs` (`SOLR_LOGS_DIR`)                 |
| Runtime user       | uid/gid **1001**                                  | user `solr`, uid/gid **8983**                      |
| Heap / host env    | `SOLR_HEAP`, `SOLR_HOST` (supported)             | `SOLR_HEAP`, `SOLR_HOST` (supported — unchanged)   |

We pin to the **floating `solr:9` tag** (not `9.9.0`) so each rebuild picks up
the latest release of the Solr 9 branch. Confirmed: the `9` tag exists on Docker
Hub (currently resolving to 9.9.0); the official image runs as user `solr`
(8983), uses `/var/solr` as the data volume, ships `init-var-solr` to seed/own
`/var/solr`, and reads `SOLR_HEAP` / `SOLR_HOST`. The internal Solr
directory layout is identical to Bitnami's except for the `/opt/solr` (vs
`/opt/bitnami/solr`) prefix, so the analyzer classpath lookup of
`server/resources/decs` works unchanged once paths are translated.

---

## Part 1 — `solr9/` Dockerfile (base image build)

**File: `solr9/Dockerfile`** — replace contents with:

```dockerfile
FROM solr:9

# DeCS Lucene index consumed by the iahx custom analyzers
# (loaded from the classpath under server/resources/decs)
COPY --chown=solr:solr ./resources/decs /opt/solr/server/resources/decs

# Bundle the iahx custom analyzer into Solr's webapp lib
COPY --chown=solr:solr ./lib/iahx-analyzer-20250825.jar \
     /opt/solr/server/solr-webapp/webapp/WEB-INF/lib/
```

Notes / rationale:
- Per the user's decision, the analyzer jar is now **bundled** (the previous
  `COPY ./lib …` was commented out and copied the whole dir; we copy the single
  jar explicitly). `lib/iahx-analyzer-20250825.jar` currently exists but is
  untracked (`?? lib/`) — it must be committed so the build is reproducible.
- `--chown=solr:solr` ensures the runtime user (8983) can read the files. The
  official image's final stage is `USER solr`; plain `COPY` would leave files
  root-owned (still world-readable, but explicit chown is cleaner and avoids
  surprises if the analyzer ever needs to open the index read-write).
- The DeCS index dirs include a `write.lock`; the analyzer opens them read-only,
  so this is harmless.

**File: `solr9/docker-compose.yml`** — retag the built image to `bireme/solr:9`
(was `bireme/solr:9`) so the output tag matches the floating-`9` base rather
than implying a specific patch version. The build context line is unchanged.

**File: `solr9/Makefile`** — fix the two pre-existing typos while here (optional
but recommended): `shell` target uses `docker -compose` (stray space), and
`index_example` uses the legacy `docker-compose` hyphenated form. Low priority.

---

## Part 2 — `solr9-std/` deployment (compose + Makefile)

Use the floating **`solr:9`** tag for both services (was `bitnami/solr:9.8.1`),
matching `solr9/` so every rebuild tracks the latest Solr 9 release.

**File: `solr9-std/docker-compose.yml`** — rewrite to the official image:

```yaml
services:
  solr_setup:
    image: solr:9
    user: root
    command: bash -c "chown -R 8983:8983 /var/solr"
    volumes:
      - ${SOLR_INDEX_PATH}:/var/solr
      - ${SOLR_LOG_PATH}:/var/solr/logs
  solr:
    image: solr:9
    restart: unless-stopped
    container_name: ${CONTAINER_NAME}
    depends_on:
      - solr_setup
    ports:
      - "${CONTAINER_PORT}:8983"
    env_file:
      - .env
    environment:
      - SOLR_HOST=${SOLR_HOST}
      - SOLR_HEAP=${SOLR_MEMORY}
    volumes:
      - ${SOLR_INDEX_PATH}:/var/solr
      - ${SOLR_LOG_PATH}:/var/solr/logs
    networks:
      - nginx-proxy

networks:
  nginx-proxy:
    external: true
```

Key changes vs current:
- Image `bitnami/solr:9.8.1` → `solr:9` (both services).
- Volume `/bitnami` → `/var/solr`; logs `/opt/bitnami/solr/logs` → `/var/solr/logs`
  (nested bind under the data volume — Docker handles this fine).
- Setup chown target `1001` → `8983` (matches the official runtime user, since
  the image runs as `solr` and cannot chown a root-owned host mount itself).
- `SOLR_HOST` / `SOLR_HEAP` env wiring is unchanged (both honored by the
  official image). The current `.env` (`SOLR_HOST` is referenced but note the
  real `.env` only sets `CONTAINER_*`, `SOLR_INDEX_PATH`, `SOLR_LOG_PATH`,
  `SOLR_MEMORY`) — `${SOLR_HOST}` resolves empty today, which is acceptable for
  standalone mode; leave behavior as-is.

**File: `solr9-std/Makefile`** — translate Bitnami paths/user to official:

| Target              | Current                                                        | New                                                      |
|---------------------|----------------------------------------------------------------|----------------------------------------------------------|
| `sh`                | `exec --user bireme solr bash`                                 | `exec --user solr solr bash`                             |
| `sh_root`           | `exec --user root solr bash`                                   | unchanged                                                |
| `update_configsets` | `docker cp ./conf/configsets/ $(container):/bitnami/solr/server/solr/` | `… $(container):/var/solr/data/`                  |
| `update_core_config`| `… $(container):/bitnami/solr/server/solr/$(core)/`           | `… $(container):/var/solr/data/$(core)/`                 |
| `create_core`       | `/opt/bitnami/solr/bin/solr create_core …`                    | `/opt/solr/bin/solr create_core …`                       |
| `zk_upconfig`       | `/opt/bitnami/solr/bin/solr zk upconfig -d /bitnami/solr/server/solr/configsets/$(core)/` | `/opt/solr/bin/solr zk upconfig -d /var/solr/data/configsets/$(core)/` |
| `create_collection_cloud` | `/opt/bitnami/solr/bin/solr create_collection …`        | `/opt/solr/bin/solr create_collection …`                 |

(`SOLR_HOME` is `/var/solr/data` on the official image, hence configsets land in
`/var/solr/data/configsets`.)

**Files `solr9-std/conf/*` and `solr9-std/.env-TEMPLATE`** — no change needed.
`solr.xml` / `zoo.cfg` / `solr.in.sh` are standard upstream Solr files and the
`.env` variable names are container-agnostic.

### Data migration (operational — run on the server, not in the repo)

The on-disk home layout differs between images, so existing data must be
relocated once. Bitnami `SOLR_HOME` = `…/indexes/solr/server/solr`; official
`SOLR_HOME` = `/var/solr/data`. Before first start of the new stack, on the host:

```bash
# $SOLR_INDEX_PATH currently holds the Bitnami layout under solr/server/solr
# Move the Solr home contents (solr.xml, configsets, each <core>/) into data/
mkdir -p "$SOLR_INDEX_PATH/data"
cp -a "$SOLR_INDEX_PATH"/solr/server/solr/. "$SOLR_INDEX_PATH/data/"
chown -R 8983:8983 "$SOLR_INDEX_PATH"
```

The Lucene index files inside each core are version-compatible (same Solr 9.x),
so only the surrounding home directory is reorganized. **Take a backup of
`$SOLR_INDEX_PATH` first.** This step is destructive-adjacent and touches
production data, so confirm before running it on a live host.

---

## Verification

### solr9 base image
```bash
cd solr9
docker compose build --no-cache               # or: make build
# jar bundled?
docker run --rm bireme/solr:9 \
  ls /opt/solr/server/solr-webapp/webapp/WEB-INF/lib/ | grep iahx-analyzer
# decs index present?
docker run --rm bireme/solr:9 ls /opt/solr/server/resources/decs
# container boots & Admin UI responds
docker run --rm -p 8983:8983 bireme/solr:9 &
curl -s localhost:8983/solr/admin/info/system | head
```
If a configset that references the iahx analysis factory + `decs` path is
available, create a throwaway core from it and confirm it loads with no
`ClassNotFoundException`, then exercise the synonym filter via the Analysis API:
```bash
docker exec <c> solr create_core -c decstest -d <configset>
curl 'localhost:8983/solr/decstest/analysis/field?analysis.fieldtype=<ft>&analysis.fieldvalue=temefos'
```

### solr9-std deployment
```bash
cd solr9-std
# ensure .env + data migration done, nginx-proxy network exists
make start && make logs           # watch for clean startup, no perm errors on /var/solr
make ps
curl -s localhost:${CONTAINER_PORT}/solr/admin/cores?action=STATUS | head
make create_core core=test        # uses /opt/solr/bin/solr now
```
Confirm: no `Permission denied` on `/var/solr` (validates the 8983 chown), cores
listed in the Admin UI, logs written to `${SOLR_LOG_PATH}`.

---

## Summary of files changed
- `solr9/Dockerfile` — base image + paths + bundle analyzer jar.
- `solr9/lib/iahx-analyzer-20250825.jar` — commit (currently untracked).
- `solr9-std/docker-compose.yml` — image, volume paths, chown uid.
- `solr9-std/Makefile` — bin paths, `SOLR_HOME` paths, exec user.
- (operational) host data relocation for `solr9-std`.
- (optional) `solr9/Makefile` typo fixes.
