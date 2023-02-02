# my-stonesoup

To play/test the tekton pipeline, create a kubernetes cluster (using kind by example) and docker registry cluster

```bash
curl -s -L "https://raw.githubusercontent.com/snowdrop/k8s-infra/main/kind/kind-reg-ingress.sh" | bash -s y latest 0
```

Next, install Tekton
```bash
kubectl apply -f \
   https://storage.googleapis.com/tekton-releases/pipeline/latest/release.yaml
```

Play with our Tasks and Pipeline

```bash
kubectl delete -f ./tekton/buildpacks
kubectl apply -f ./tekton/buildpacks
```
