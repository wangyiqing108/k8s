FROM hub/ops/mp-sre-logstash:base
COPY redis-mp-safe-audit-statistics_analyse.conf /root/redis-mp-safe-audit-statistics_analyse.conf
CMD ["/root/logstash/bin/logstash", "-f", "/root/redis-mp-safe-audit-statistics_analyse.conf", "--path.data", "/tmp", "-w", "16", "-b", "1000", "-u", "10"]
