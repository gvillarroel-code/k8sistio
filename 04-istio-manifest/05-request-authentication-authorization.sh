kubectl $1 -f - <<EOF
apiVersion: security.istio.io/v1beta1
kind: RequestAuthentication
metadata:
  name: istio-ingressgateway
  namespace: istio-system
spec:
  selector:
    matchLabels:
      app: istio-ingressgateway
  jwtRules:
  - issuer: "http://keycloak.keycloakns.svc.cluster.local/auth/realms/master"
    jwksUri: "http://keycloak.keycloakns.svc.cluster.local/auth/realms/master/protocol/openid-connect/certs"
    forwardOriginalToken: true
    outputPayloadToHeader: x-jwt-payload
---
apiVersion: security.istio.io/v1beta1
kind: AuthorizationPolicy
metadata:
  name: oauth-policy
  namespace: istio-system
spec:
  selector:
    matchLabels:
      app: istio-ingressgateway
  action: CUSTOM
  provider:
    # Extension provider configured when we installed Istio
    name: oauth2-proxy
  rules:
    - to:
      - operation:
          hosts:
          - "helloworld.cluster.local"
EOF
