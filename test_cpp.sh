#!/bin/bash
set -euo pipefail
cd "$(dirname "$0")/cpp"
g++ -std=c++17 -O2 main.cpp -o /tmp/aisd_kr_v15_test
printf '1\n-3 4\n' | /tmp/aisd_kr_v15_test >/dev/null
printf '2\n9001\n' | /tmp/aisd_kr_v15_test >/dev/null
printf '4\n3\n' | /tmp/aisd_kr_v15_test >/dev/null
printf '8\n110\n17\n' | /tmp/aisd_kr_v15_test >/dev/null
printf '14\n1+2i\n2-i\n3+i\n' | /tmp/aisd_kr_v15_test >/dev/null
printf '16\n' | /tmp/aisd_kr_v15_test >/dev/null
printf '17\n1 2 3 4 5\n' | /tmp/aisd_kr_v15_test >/dev/null
echo 'OK: базовые тесты пройдены'
