#!/usr/bin/env bash
set -Eeuo pipefail
on_error() {
  local exit_code=$?
  local line=$1
  local cmd=$2

  echo "\e[31m[ERROR]\e[0m Command failed at line $line with exit code $exit_code: $cmd"
  exit "$exit_code"
}
trap 'on_error "$LINENO" "$BASH_COMMAND"' ERR

source ./env.sh

reload_services() {
  docker restart nginx
}

MODE="${1:-}"
if [[ "$MODE" != "issue" && "$MODE" != "renew" ]]; then
  echo "Usage: $0 {issue|renew}"
  exit 1
fi

ACME_DNS_PROVIDER="dns_hetznercloud"
ACME_DIR_CERT="/acme.sh/cert"

certificate_changed=false

for domain in "${DOMAINS[@]}"; do
  cert_dir="$(pwd)/cert/$domain"
  fullchain="$cert_dir/cert/fullchain.pem"

  mkdir -p "$cert_dir"

  domain_args=(-d "$domain")

  for sub_domain in ${SUB_DOMAINS[$domain]:-}; do
    domain_args+=(-d "$sub_domain.$domain")
  done

  echo "Running $MODE with domain args: ${domain_args[*]}"

  old_checksum=""
  if [[ -f "$fullchain" ]]; then
    old_checksum="$(sha256sum "$fullchain" | cut -d' ' -f1)"
  fi

  acme_args=(
    "--$MODE"
    "${domain_args[@]}"
    --server letsencrypt
    --dns "$ACME_DNS_PROVIDER"
    --cert-file "$ACME_DIR_CERT/cert.pem"
    --key-file "$ACME_DIR_CERT/key.pem"
    --fullchain-file "$ACME_DIR_CERT/fullchain.pem"
  )

  if [[ "$MODE" == "issue" ]]; then
    acme_args+=(--force)
  fi

  # acme.sh returns exit code 2 when no action was required.
  if docker run --rm \
    -v "$cert_dir:/acme.sh:z" \
    --net=host \
    -e HETZNER_TOKEN="$HETZNER_TOKEN" \
    neilpang/acme.sh \
    "${acme_args[@]}"; then

    exit_code=0
  else
    exit_code=$?
  fi

  if (( exit_code != 0 && exit_code != 2 )); then
    echo "acme.sh failed with exit code $exit_code" >&2
    exit "$exit_code"
  fi

  if [[ -f "$fullchain" ]]; then
    new_checksum="$(sha256sum "$fullchain" | cut -d' ' -f1)"

    if [[ "$new_checksum" != "$old_checksum" ]]; then
      echo "Certificate changed for $domain"
      certificate_changed=true
    fi
  fi
done

if $certificate_changed; then
  echo "Certificate changed, reloading services."
  reload_services
else
  echo "No certificates changed; nginx reload not required."
fi

