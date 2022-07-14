#######################################
## Crea cluster con 16G RAM y 4 Proc ##
#######################################
k-create-minikube

######################################
## Instalar kube-prometheus via helm ##
#######################################
helm repo add bitnami https://charts.bitnami.com/bitnami
helm install my-release bitnami/kube-prometheus

kubectl create namespace istio-system
kubectl create namespace apps
######################
## Instalar jaeger  ##
######################
kubectl apply -f https://raw.githubusercontent.com/istio/istio/release-1.13/samples/addons/jaeger.yaml


#####################
##  Instalar Istio ##  
#####################
istioctl install --set profile=default -y
kubectl label namespace istio-system istio-injection=enabled
kubectl label namespace apps istio-injection=enabled

##############################
## Instalar kiali via helm  ##
##############################
helm install --namespace istio-system --set auth.strategy="anonymous" --repo https://kiali.org/helm-charts kiali-server kiali-server

########################################
## Instalar istio-prometheus via helm ##
########################################
kubectl apply -f https://raw.githubusercontent.com/istio/istio/release-1.13/samples/addons/prometheus.yaml


########################################
##  Instalar microservicio helloworld ##
########################################
k-load-images mspy:0.0 
k-load-images postgres:9.6
k-load-images dpage/pgadmin4:5.1
k-default-namespace apps
k apply -f ~/k8s/lab/00-microservicio/deploy-helloworld.yml

########################################
# istioctl dashboard kiali
########################################


VARIOS
kubectl get svc istio-ingressgateway -n istio-system  --- VER IP INGRESS 
minikube start --mount-string="/home/horse1/k8s/lab/01-database:/database" --mount 


