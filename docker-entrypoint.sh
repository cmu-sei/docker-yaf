#!/bin/bash

set -e

eval "LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/netsa/lib/ /netsa/bin/yaf "$@""