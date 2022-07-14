kubectl apply -f - <<EOF
apiVersion: v1
kind: Namespace
metadata:
  name: oauth2-proxy
  labels:
    istio-injection: enabled
---
apiVersion: v1
kind: Service
metadata:
  name: oauth2-proxy
  namespace: oauth2-proxy
spec:
  selector:
    app: oauth2-proxy
  ports:
  - name: http
    port: 80
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: oauth2-proxy
  namespace: oauth2-proxy
spec:
  selector:
    matchLabels:
      app: oauth2-proxy
  template:
    metadata:
      labels:
        app: oauth2-proxy
        version: "v1"
    spec:
      containers:
      - name: oauth2-proxy
        image: quay.io/oauth2-proxy/oauth2-proxy:v7.2.0
        args:
        - --redirect-url=http://oauth2-proxy.oauth2-proxy.svc.cluster.local/oauth2/callback
        - --oidc-issuer-url=http://keycloak.keycloakns.svc.cluster.local/auth/realms/master
        - --oidc-jwks-url=http://keycloak.keycloakns.svc.cluster.local/auth/realms/master/protocol/openid-connect/certs
        - --redis-connection-url=redis://redis.oauth2-proxy.svc.cluster.local:6379
        - --session-store-type=redis
        - --provider=oidc
        - --provider-display-name="My OIDC Provider"
        - --email-domain=*
        - --http-address=0.0.0.0:80
        - --upstream=static://200
        - --skip-provider-button=true
        - --whitelist-domain=.cluster.local
        - --cookie-domain=cluster.local
        - --cookie-secure=false
        - --cookie-name=_oauth2_proxy
        - --cookie-samesite=lax
        - --scope=openid
        - --client-id=istio
        - --client-secret=MFfFeye61dD2Qj01vjx5zngp3uA4SwkE
        - --cookie-secret=5NDoilWxZb8c8-PMN_-PxenMsUh37U1KI8iTdqhctc8=
        - --cookie-httponly=false
        - --cookie-expire=1m

        - --set-authorization-header=true
        - --pass-authorization-header=true
        - --set-xauthrequest=true
        - --pass-access-token=true
        - --pass-basic-auth=true
        - --pass-host-header=true
        - --pass-user-headers=true
        resources:
          requests:
            cpu: 10m
            memory: 100Mi
        ports:
        - containerPort: 80
          protocol: TCP
        readinessProbe:
          periodSeconds: 3
          httpGet:
            path: /ping
            port: 80
EOF
