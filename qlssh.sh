#!/bin/sh

# HOST=upi-0.snowdrop.lab.psi.pnq2.redhat.com
# ./qlssh.sh $HOST "cat /home/quicklab/oc4/auth/kubeconfig" > ql_ocp4.cfg
# konfig import --save ql_ocp4.cfg
# kubecontext admin


if [ -d $1 ]; then
	echo "Usage: qlssh <host>"
	exit 1;
fi
ssh -i config/quicklab.key -o "UserKnownHostsFile /dev/null" -o "StrictHostKeyChecking no" -o "IdentitiesOnly yes" quicklab@$1 "${@:2}"
