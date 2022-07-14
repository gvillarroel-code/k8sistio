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


