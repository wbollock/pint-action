# pint action

This action will run [pint](https://github.com/cloudflare/pint)
to validate Prometheus rules.
It will run `pint ci` for pull requests and `pint lint` for
merges.

## Inputs

### `token`

Github token to use when reporting problems on the pull request.
Required, no default.

### `workdir`

Directory to run check against on pushes (for example after a merge).
To set directories tested when running checks on a pull request please
create a config file for pint and set `ci { include = [...] }` option.
See [pint docs](https://cloudflare.github.io/pint/configuration.html#ci) for details.
Default is `"."`.

### `config`

Config file to use. Default is `""`, meaning no `--config` flag will be passed
to `pint` and it will use defaults.

### `loglevel`

Log level for pint. Default is `""`, meaning no `--log-level` flag will be passed
to `pint` and it will use defaults.

### `minSeverity`

Minimum severity reported by the **lint** command. Default is `""`, meaning no `--min-severity` flag will be passed
to `pint` and it will use defaults.

Available options : `info`, `warning` *(lint default)*, `bug` `fatal`.

### `requireOwner`

If set to any non-empty string pint will be run with `--require-owner` flag.
Passing this flag will require all rule files or individual rules to have owner set via comment.

## Requirements

Validating PRs require full git history and so `actions/checkout` must be used
with `fetch-depth: 0` option.

Be sure to use a token with write access to the `pull-requests` scope.

## Example usage

```YAML
name: pint

on:
  push:
    branches:
      - main
  pull_request:
    branches:
      - main

permissions:
  pull-requests: write

jobs:
  pint:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
        with:
          fetch-depth: 0

      - name: Run pint
        uses: prymitive/pint-action@v1
        with:
          token: ${{ github.token }}
          workdir: 'rules'
          requireOwner: 'true'
```

## Pull Requests from Forks

It is possible to use Pint with pull requests originating from forked repositories. There is some additional configuration. An example configuration could look like:

```YAML
name: pint

on:
  push:
    branches:
      - main
  pull_request:
    branches:
      - main

permissions:
  pull-requests: write

jobs:
  pint:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
        with:
          fetch-depth: 0

      - name: Run pint
        uses: prymitive/pint-action@v1
        with:
          token: ${{ github.token }}
          workdir: 'rules'
          requireOwner: 'true'
          pr_target_repo: ${{ github.event.pull_request.base.repo.full_name }} # REQUIRED FOR PRs FROM FORKS
          pr_source_repo: ${{ github.event.pull_request.head.repo.full_name }} # REQUIRED FOR PRs FROM FORKS
```

Some caveats:

- The `pull_requests` permission will *not* be granted "write" access by default (TODO link to internal docs)
- `pr_target_repo` and `pr_source_repo` must both be set to the values indicated
