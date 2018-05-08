# Truncate zookeeper logs
ZOOKEEPER_VERSION_2=/var/log/zookeeper/version-2/log.*

for f in $ZOOKEEPER_VERSION_2
do
	tail -n 100 $f > $f.tmp && cat $f.tmp > $f && rm $f.tmp
done