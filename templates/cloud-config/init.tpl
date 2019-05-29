#cloud-config
#
# Cloud-Config template for the Apache Zookeeper instances.
#
# Copyright 2016-2019, Frederico Martins
#   Author: Frederico Martins <http://github.com/fscm>
#
# SPDX-License-Identifier: MIT
#

fqdn: ${hostname}.${domain}
hostname: ${hostname}
manage_etc_hosts: false

write_files:
  - content: |
      #!/bin/bash
      echo "=== Setting up Apache Zookeeper Instance ==="
      echo "  instance: ${hostname}.${domain}"
      sudo echo 'JVMFLAGS="$JVMFLAGS -Djava.net.preferIPv4Stack=true"' > /srv/zookeeper/conf/java.env
      #$(hostname -I)
      sudo sed -i -r -e "/^clientPortAddress/s/=.*/=0.0.0.0/" /srv/zookeeper/conf/zoo.cfg
      sudo /usr/local/bin/zookeeper_config ${zookeeper_args} -E -S -W 60
      sleep 1
      sudo /usr/local/bin/kafka_config ${kafka_args} -E -S -W 60
      /srv/kafka/bin/kafka-topics.sh --create --bootstrap-server ${hostname}:9092 --replication-factor 2 --partitions 1 --topic sdi.brivo20.JOURNAL_EVENT
      echo "=== All Done ==="
    path: /tmp/setup_zookeeper.sh
    permissions: '0755'

runcmd:
  - /tmp/setup_zookeeper.sh
  - rm /tmp/setup_zookeeper.sh
