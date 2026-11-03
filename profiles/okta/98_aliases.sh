#!/usr/bin/env bash

alias tf.sh="\$(git rev-parse --show-toplevel)/ispm-tf/infrastructure/base-layer/tf.sh"
deploy() {
    "$(git rev-parse --show-toplevel)/deploy-manager/.venv/bin/deploy" "$@"
}
