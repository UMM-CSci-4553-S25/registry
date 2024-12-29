#!/usr/bin/env bash
set -euo pipefail

current_path=$(realpath "$(dirname "$BASH_SOURCE[0]")")

cd  "$current_path"

if [[ $(git status --porcelain) != "" ]]; then
  echo "Please make sure your git state is clean before proceeding"
  exit 1
fi

if ! command -v cargo-http-registry 2>&1 >/dev/null
then
  echo "command cargo-http-registry not found, installing using cargo ..."
  cargo install --locked cargo-http-registry
fi

if ! command -v tomli 2>&1 >/dev/null
then
  echo "command tomli not found, installing using cargo ..."
  cargo install --locked tomli
fi

pre_start_commit=$(git log --format="%H" -n 1)

cargo-http-registry "$current_path" -a 127.0.0.1:35503 &
registry_pid=$!

sleep 1

if [[ $(git log --format="%H" -n 1) != $pre_start_commit ]]; then
  if [[ $(git log --format="%s" -n 1) =~ "Update config.json" ]]; then
      commit_id=$(git log --format="%H" -n 1 | xargs)
      trap "kill -15 $registry_pid; git rebase --onto '${commit_id}^' '$commit_id'" EXIT HUP INT TERM
  else
      trap "kill -15 $registry_pid" EXIT HUP INT TERM
  fi
else
  trap "kill -15 $registry_pid" EXIT HUP INT TERM
fi

set +e

mkdir -p "$HOME/.cargo"
touch "$HOME/.cargo/config.toml"

registry_alias="local-server"

if [[ $(tomli query -f "$HOME/.cargo/config.toml" "registries.$registry_alias.index" 2>&1) =~ "not found" ]]
then
  out=$(tomli set -f "$HOME/.cargo/config.toml" "registries.$registry_alias.index" "http://127.0.0.1:35503/git")
  printf "%s" "$out" | tee "$HOME/.cargo/config.toml" 2>&1 >/dev/null
else 
  if [[ $(tomli query -f "$HOME/.cargo/config.toml" "registries.$registry_alias.index" | xargs) != "http://127.0.0.1:35503/git"  ]]; then
    echo "==== [WARNING] ===="
    echo "Couldn't set config value registries.local-server.index in ~/.cargo/config.toml"
    echo "This means that the cargo registry alias local-server isn't set correctly"
    echo "Please manually add a local registry called local-server with the url 'http://127.0.0.1:35503/git' to your ~/.cargo/config.toml"
    echo "==================="
    echo ""
  fi
fi

out=$(tomli set -f "$HOME/.cargo/config.toml" net.git-fetch-with-cli -t bool true)
printf "%s" "$out" | tee "$HOME/.cargo/config.toml" 2>&1 >/dev/null
  
set -e

echo "Cargo registry started under 127.0.0.1:35503"
echo "cargo registry alias:  $registry_alias"
echo "    use 'cargo publish --registry $registry_alias ...' to publish to this registry"
echo ""
echo "Press Ctrl+C to stop the local registy server"
wait
