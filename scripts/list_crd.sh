#!/bin/bash

report_date=$(date '+%d-%b-%Y_%H:%M')
report_file_name="report_crd_${report_date}"
echo "---------------------------------------------" > ${report_file_name}
echo "CRD Report"  >> ${report_file_name}
echo "---------------------------------------------" >> ${report_file_name}
for crd in $(kubectl get crd -o name --sort-by='.metadata.name'); do
     crd_name=$(echo "$crd" | cut -d'/' -f2)
     crd_count=$(kubectl get $crd_name -A -o name | wc -c)
     if (( $crd_count > 0 )); then
        echo "CRD: $crd_name" >> ${report_file_name}
        echo "---------------------------------------------" >> ${report_file_name}
        CRDs=$(kubectl get $crd_name -A -o json)
        printf "%-80s%s\n" NAME NAMESPACE >> ${report_file_name}

        eval "$(echo $CRDs | jq -r ' .items[] | [ "printf", "%-80s%s\n", "\(.metadata.name)~", "\(.metadata.namespace)" ] | @sh' | tr ' ~' ' ')" >> ${report_file_name}
        echo "---------------------------------------------" >> ${report_file_name}
        echo "" >> ${report_file_name}
     fi
done