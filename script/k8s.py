# encoding: utf-8
import json
import requests
class KubeClient(object):

    def __init__(self, debug=False, env='mp', cluster='test'):
        """
        Creates an instance of the KubeHTTPClient.

        :Parameters:
           - `api_server`: The URL (IP or FQHN and port) of the Kubernetes API server to use, defaults to
           `http://localhost:8080`
        """
        #server = KubuServer(env, cluster)

        self.api_server = 'https://192.168.210.48:6443'
        self.prometheus_server = 'http://192.168.132.62:8090'
        self.namespace = 'default'
        self.cert = ('/Users/wangyiqing/myapp/kube-ca/mp-kube-test.crt',
                     '/Users/wangyiqing/myapp/kube-ca/mp-kube-test.key')

        DEBUG = debug
        if DEBUG:
            FORMAT = "%(asctime)-0s %(levelname)s %(message)s [at line %(lineno)d]"
            #logging.basicConfig(level=logging.DEBUG, format=FORMAT, datefmt="%Y-%m-%dT%I:%M:%S")
        else:
            FORMAT = "%(asctime)-0s %(message)s"
            #logging.basicConfig(level=logging.INFO, format=FORMAT, datefmt="%Y-%m-%dT%I:%M:%S")

    def execute_operation(self, method="GET", ops_path="", payload="", is_k8s=True):
        """
        Executes a Kubernetes operation using the specified method against a path.
        This is part of the low-level API.
        :Parameters:
           - `method`: The HTTP method to use, defaults to `GET`
           - `ops_path`: The path of the operation, for example, `/api/v1/events` which would result in an overall:
           `GET http://localhost:8080/api/v1/events`
           - `payload`: The optional payload which is relevant for `POST` or `PUT` methods only
        """
        if is_k8s:
            operation_path_URL = "".join([self.api_server, ops_path])
        else:
            operation_path_URL = "".join([self.prometheus_server, ops_path])
        #logger.info("%s %s" % (method, operation_path_URL))
        if is_k8s:
            if payload == "":
                res = getattr(requests, method.lower())(operation_path_URL, cert=self.cert, verify=False)
            else:
                res = getattr(requests, method.lower())(operation_path_URL, data=payload, cert=self.cert, verify=False)
        else:
            res = getattr(requests, method.lower())(operation_path_URL)
        try:
            res.json()
        except:
            pass
        print("wangyiqing:"+ str(res))
        return res
    def get_namespaces(self):
        """
        get namespace
        - `/api/v1/namespaces`
        :return:
        """
        namespace_path = '/api/v1/namespaces'
        res = self.execute_operation(method="GET", ops_path=namespace_path)
        try:
            items = res.json()["items"]
        except:
            return []
        return [item.get('metadata').get('name') for item in items]
    def load_namespace(self, name='default'):
        """
        load namespace
        :param name:
           -  `/api/v1/namespaces`
        :return:
        """
        namespace_path = '/api/v1/namespaces'
        if name not in self.get_namespaces():
            data = json.dumps(dict(metadata={'name': name}))
            res = self.execute_operation(method="POST", ops_path=namespace_path, payload=data)
            try:
                res.json()["metadata"]["selfLink"]
            except KeyError:
                return
        return name
if __name__ == "__main__":
    k = KubeClient()
    name = k.load_namespace()
    print(name)
