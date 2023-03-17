Install with something similar to:

kubectl create namespace "spire-system"
kubectl label namespace "spire-system" pod-security.kubernetes.io/enforce=privileged
kubectl create namespace "spire-server"
kubectl label namespace "spire-server" pod-security.kubernetes.io/enforce=restricted

```
helm upgrade --install --namespace spire-server spire charts/spire -f values.yaml
```

If your using ingress-nginx and want to expose spire outside the cluster, add the
following to the end of the helm upgrade example:
```
-f values-export-ingress-nginx.yaml
```
