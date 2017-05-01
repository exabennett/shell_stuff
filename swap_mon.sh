#!/bin/sh
# Robert Bennett
# v1.0
# swap_mon.sh

free -m | grep -i swap | while read junk SW_TOTAL SW_USED SW_FREE
do
PERCENT_USED=$(bc <<EOF
scale =4
($SW_USED/$SW_TOTAL) * 100
EOF
)
PERCENT_FREE=$(bc <<EOF
scale=2
($SW_FREE/$SW_TOTAL) * 100
EOF
)

echo "Total Amount of Swap Space: $SW_TOTAL MB"
echo "Total Amount of Swap Space Used: $SW_USED MB"
echo "Total Amount of Swap Space Free: $SW_FREE MB"
echo "Percent of Swap Space Used: $PERCENT_USED %"
echo "Percent of Swap Space Free: $PERCENT_FREE %"
done
