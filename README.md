# metarepo

Do github operations over the whole api-gateway estate.

## Prerequisites
### `GITHUB_PAT`
You will need an env var named `GITHUB_PAT` which contains a [github personal access token](https://github.com/settings/tokens).

## Usage
### Clone all repos
``` sh
./metarepo.sh
```

### Run a script in each repo
Write a script, called, say `foo.sh`

``` sh
./metarepo.sh foo.sh
```

#### Env available for scripts
There are two additional env vars given to scripts:
* `GITHUB_PAT` - a [github personal access token](https://github.com/settings/tokens)
* `REPO_NAME` - the name of the repo you are in

## Procedures
### Update all repos' autolink references
See `set-ticket-links.sh`, and note the defintion of `PROJECTS`. Add any
additional prefixes and urls, then run `./metarepo.sh set-ticket-links.sh`
