#!/usr/bin/env bash
HETZNER_TOKEN=""

DOMAINS=(
  "kira.rip"
  "erikwelander.se"
)

# Space separated list of sub domains for each domain
declare -A SUB_DOMAINS=(
  ["kira.rip"]="git"
  ["erikwelander.se"]="git"
)
