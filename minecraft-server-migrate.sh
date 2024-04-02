#!/bin/bash

MCDIR=$1

rm -r $MCDIR/version-upgrade-backup
echo backup erased

mv $MCDIR/running $MCDIR/version-upgrade-backup
echo created new backup

mkdir $MCDIR/running
unzip /home/brian/maintenance/bedrock-server* -d $MCDIR/running > /dev/null
mv /home/brian/maintenance/bedrock-server* /home/brian/maintenance/minecraft-bedrock-server-versions/
echo new server unzipped

cp -r $MCDIR/version-upgrade-backup/worlds/ $MCDIR/running
echo world migrated

cp $MCDIR/version-upgrade-backup/allowlist.json $MCDIR/running
cp $MCDIR/version-upgrade-backup/server.properties $MCDIR/running
echo server setting migrated
