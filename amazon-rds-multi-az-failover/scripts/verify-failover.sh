##Script to test failover

#!/bin/bash
echo "Testing connection to writer endpoint..."
mysql -h myauroracluster.cluster-xxx.rds.amazonaws.com -u WhizlabsAdmin -pWhizlabs123 -e "SELECT @@server_id, @@hostname;"

echo "Testing connection to reader endpoint..."
mysql -h myauroracluster.cluster-ro-xxx.rds.amazonaws.com -u WhizlabsAdmin -pWhizlabs123 -e "SELECT @@server_id, @@hostname;"

