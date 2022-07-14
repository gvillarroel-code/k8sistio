docker run --network=kong-net --rm --name keycloak_auto_build -p 8080:8080 \
        -e KEYCLOAK_USER="admin" -e KEYCLOAK_PASSWORD="password" \
	-e DB_VENDOR=POSTGRES -e DB_ADDR=kong-database -e DB_PORT=5432 -e DB_DATABASE=keycloak_db -e DB_USER=keycloak -e DB_PASSWORD=kc \
        jboss/keycloak:16.1.1  


