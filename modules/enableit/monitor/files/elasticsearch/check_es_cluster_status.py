#!/usr/bin/python
from nagioscheck import NagiosCheck, UsageError
from nagioscheck import PerformanceMetric, Status
import urllib2
import optparse

try:
    import json
except ImportError:
    import simplejson as json


class ESClusterHealthCheck(NagiosCheck):

    def __init__(self):

        NagiosCheck.__init__(self)

        self.add_option('H', 'host', 'host', 'The cluster to check')
        self.add_option('P', 'port', 'port', 'The ES port - defaults to 9200')
        self.add_option('W', 'warning', 'warning', 'The ES cluster status - defaults to warning')
        self.add_option('C', 'critical', 'critical', 'The ES cluster status - defaults to critical')

    def check(self, opts, args):
        host = opts.host
        port = int(opts.port or '9200')
        warning = str(opts.warning or 'warning')
        critical = str(opts.critical or 'critical')

        try:
            response = urllib2.urlopen(r'http://%s:%d/_cluster/health'
                                       % (host, port))
        except urllib2.HTTPError, e:
            raise Status('unknown', ("API failure", None,
                         "API failure:\n\n%s" % str(e)))
        except urllib2.URLError, e:
            raise Status('critical', (e.reason))

        response_body = response.read()

        try:
            es_cluster_health = json.loads(response_body)
        except ValueError:
            raise Status('unknown', ("API returned nonsense",))

        cluster_status = es_cluster_health['status'].lower()

        if cluster_status == 'red':
            raise Status("CRITICAL", "Cluster status is currently reporting as "
                         "Red")
        elif cluster_status == 'yellow':
            if warning == 'yellow':
                raise Status("WARNING", "Cluster status is currently reporting as "
                         "Yellow")
            elif critical == 'yellow':
                raise Status("CRITICAL", "Cluster status is currently reporting as "
                         "Yellow")
            else:
                raise Status("OK", "Cluster status is currently reporting as "
                         "Yellow")
        else:
            raise Status("OK",
                         "Cluster status is currently reporting as Green")

if __name__ == "__main__":
    ESClusterHealthCheck().run()
