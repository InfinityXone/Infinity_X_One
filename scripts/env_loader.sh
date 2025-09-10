#!/bin/bash
set -a
if [ -f /opt/infinity_x_one/INFINITY_X_ONE_MASTER_ENV.txt ]; then
  source /opt/infinity_x_one/INFINITY_X_ONE_MASTER_ENV.txt
else
  echo "⚠️ No master env file found at /opt/infinity_x_one/INFINITY_X_ONE_MASTER_ENV.txt"
fi
set +a
