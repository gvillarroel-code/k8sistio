kubectl apply -f - <<EOF
apiVersion: security.istio.io/v1beta1
kind: AuthorizationPolicy
metadata:
  name: helloworld-opa
  namespace: istio-system
spec:
  selector:
    matchLabels:
      app: helloworld
  action: CUSTOM
  provider:
    name: "opa.oauth2-proxy"
  rules:
  - to:
    - operation:
       paths: ["//helloworld"]
#       notPaths: ["keycloak","oauth2-proxy"]

EOF

