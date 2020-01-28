#!/bin/bash -Ee

export RUBYOPT='-W2'

rackup \
  --env production \
  --host 0.0.0.0   \
  --port ${PORT}   \
  --server thin    \
  --warn           \
    config.ru
