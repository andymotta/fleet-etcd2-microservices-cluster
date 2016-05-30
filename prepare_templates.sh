#!/bin/bash
perl -pi -e 's/10.0.101.100/<MasterIPaz1>/g' `grep -ril 10.0.101.100 *`
perl -pi -e 's/10.0.102.100/<MasterIPaz2>/g' `grep -ril 10.0.102.100 *`
perl -pi -e 's/10.0.103.100/<MasterIPaz3>/g' `grep -ril 10.0.103.100 *`

# perl -pi -e 's/FleetCluster/<YourClusterName>/g' `grep -ril FleetCluster *`
# oregon=$(curl -s http://stable.release.core-os.net/amd64-usr/current/coreos_production_ami_hvm_us-west-2.txt)
# virginia=$(curl -s http://stable.release.core-os.net/amd64-usr/current/coreos_production_ami_hvm_us-east-1.txt)
# sed -i s/OREGON/${oregon}/g variables.tf
# sed -i s/VIRGINIA/${virginia}/g variables.tf
