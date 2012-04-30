#!/bin/bash
LOG="${HOME}/apt-cacher-ng_dns-test.log"
APTCACHERNG_MAINT="/etc/cron.daily/apt-cacher-ng"

QUERY1="www.google.co.uk"
QUERY2="repo.yaffas.org"
QUERY3="packages.vmware.com"
QUERY4="archive.canonical.com"

# Test script setup to run some DNS queries around the apt-cacher-ng maintenance script to help diagnose DNS issues when this is run from cron.
echo "apt-cacher-ng Diagnostic script started `date`" >> ${LOG}

# First DNS query (before apt-cacher-ng maintenance is run)
echo "Starting preliminary DNS query checks." >> ${LOG}
dig @ ${QUERY1} any >> ${LOG}
dig @ ${QUERY2} any >> ${LOG}
dig @ ${QUERY3} any >> ${LOG}
dig @ ${QUERY4} any >> ${LOG}
echo "" >> ${LOG}

echo "Querying Web..." >> ${LOG}
dig @ ${QUERY1} any >> ${LOG}
dig @ ${QUERY2} any >> ${LOG}
dig @ ${QUERY3} any >> ${LOG}
dig @ ${QUERY4} any >> ${LOG}
echo "" >> ${LOG}

echo "Querying ..." >> ${LOG}
dig @ ${QUERY1} any >> ${LOG}
dig @ ${QUERY2} any >> ${LOG}
dig @ ${QUERY3} any >> ${LOG}
dig @ ${QUERY4} any >> ${LOG}
echo "" >> ${LOG}

echo "Querying Google OpenDNS..." >> ${LOG}
dig @8.8.8.8 ${QUERY1} any >> ${LOG}
dig @8.8.8.8 ${QUERY2} any >> ${LOG}
dig @8.8.8.8 ${QUERY3} any >> ${LOG}
dig @8.8.8.8 ${QUERY4} any >> ${LOG}
echo "" >> ${LOG}
# End first query


# Call the apt-cacher-ng maintenance job
echo "Calling ${APT-CACHER-NG_MAINT}..." >> ${LOG}
bash ${APTCACHERNG_MAINT} >> ${LOG}


# Second DNS query (after apt-cacher-ng maintenance is run)
 echo "Starting final DNS query checks." >> ${LOG}
dig @ ${QUERY1} any >> ${LOG}
dig @ ${QUERY2} any >> ${LOG}
dig @ ${QUERY3} any >> ${LOG}
dig @ ${QUERY4} any >> ${LOG}
echo "" >> ${LOG}

echo "Querying Web..." >> ${LOG}
dig @ ${QUERY1} any >> ${LOG}
dig @ ${QUERY2} any >> ${LOG}
dig @ ${QUERY3} any >> ${LOG}
dig @ ${QUERY4} any >> ${LOG}
echo "" >> ${LOG}

echo "Querying ..." >> ${LOG}
dig @ ${QUERY1} any >> ${LOG}
dig @ ${QUERY2} any >> ${LOG}
dig @ ${QUERY3} any >> ${LOG}
dig @ ${QUERY4} any >> ${LOG}
echo "" >> ${LOG}

echo "Querying Google OpenDNS..." >> ${LOG}
dig @8.8.8.8 ${QUERY1} any >> ${LOG}
dig @8.8.8.8 ${QUERY2} any >> ${LOG}
dig @8.8.8.8 ${QUERY3} any >> ${LOG}
dig @8.8.8.8 ${QUERY4} any >> ${LOG}
echo "" >> ${LOG}
# End second query

echo "apt-cacher-ng Diagnostic script finished `date`" >> ${LOG}