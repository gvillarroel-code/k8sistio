cat > policy.rego <<EOF
package envoy.authz
import input.attributes.request.http as http_request

default allow = false

claims := payload {
#    io.jwt.verify_hs256(bearer_token, "B41BD5F462719C6D6118E673A2389")  # Ensure token authorization with certificate
    [_, payload, _] := io.jwt.decode(bearer_token)  # Return token information
}

bearer_token := t {    # Sanitize token string
    v := input.attributes.request.http.headers.authorization   # Take raw string
    startswith(v, "Bearer ")  # Get start
    t := substring(v, count("Bearer "), -1)  # Retrieve full JWT Token
}


##############################
### INICIO DE LAS REGLAS   ###
##############################
allow {
    claims.preferred_username == "test"                 # read preferred_username from jwt claims
#   http_request.host == "helloworld.cluster.local"     # read host from http header
}

allow {
    claims.preferred_username == "user2"                 # read preferred_username from jwt claims
}


EOF

kubectl delete secret opa-policy -n oauth2-proxy
kubectl create secret generic opa-policy --from-file policy.rego -n oauth2-proxy

kubectl apply -f - <<EOF
apiVersion: v1
kind: Service
metadata:
  name: opa
  namespace: oauth2-proxy
  labels:
    app: opa
spec:
  ports:
  - name: grpc
    port: 9191
    targetPort: 9191
  selector:
    app: opa
---
kind: Deployment
apiVersion: apps/v1
metadata:
  name: opa
  namespace: oauth2-proxy
  labels:
    app: opa
spec:
  replicas: 1
  selector:
    matchLabels:
      app: opa
  template:
    metadata:
      labels:
        app: opa
    spec:
      containers:
        - name: opa
          image: openpolicyagent/opa:latest-envoy
          securityContext:
            runAsUser: 1111
          volumeMounts:
          - readOnly: true
            mountPath: /policy
            name: opa-policy
          args:
          - "run"
          - "--server"
          - "--addr=localhost:8181"
          - "--diagnostic-addr=0.0.0.0:8282"
          - "--set=plugins.envoy_ext_authz_grpc.addr=:9191"
          - "--set=plugins.envoy_ext_authz_grpc.query=data.envoy.authz.allow"
          - "--set=decision_logs.console=true"
          - "--ignore=.*"
          - "/policy/policy.rego"
          ports:
          - containerPort: 9191
          livenessProbe:
            httpGet:
              path: /health?plugins
              scheme: HTTP
              port: 8282
            initialDelaySeconds: 5
            periodSeconds: 5
          readinessProbe:
            httpGet:
              path: /health?plugins
              scheme: HTTP
              port: 8282
            initialDelaySeconds: 5
            periodSeconds: 5
      volumes:
        - name: proxy-config
          configMap:
            name: proxy-config
        - name: opa-policy
          secret:
            secretName: opa-policy
EOF

kubectl scale deployment.v1.apps/opa --replicas=0
sleep 3
kubectl scale deployment.v1.apps/opa --replicas=1


