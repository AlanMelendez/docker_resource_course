

# Primero creamos el volumen para guardar la informacion:
docker volume create laboratorio
    #? docker volume inspect laboratorio
        # [
        #     {
        #         "CreatedAt": "2024-04-24T20:05:28-06:00",
        #         "Driver": "local",
        #         "Labels": null,
        #         "Mountpoint": "/var/lib/docker/volumes/laboratorio/_data",
        #         "Name": "laboratorio",
        #         "Options": null,
        #         "Scope": "local"
        #     }
        # ]

# Luego creamos la imagen de postregres:
docker container run \
--name postgres-db \
-dp 5432:5432 \
--env POSTGRES_PASSWORD=123456 \
--volume laboratorio:/var/lib/docker/volumes/laboratorio/_data \
postgres:alpine3.19

    #? CONTAINER ID   IMAGE                 COMMAND                  CREATED         STATUS         PORTS                                       NAMES
    # dddb3a2a79ac   postgres:alpine3.19   "docker-entrypoint.s…"   7 seconds ago   Up 6 seconds   0.0.0.0:5432->5432/tcp, :::5432->5432/tcp   postgres-db


# Luego creamos la imagen de pgadmin:
docker container run \
--name pgAdmin \
--env PGADMIN_DEFAULT_PASSWORD=123456 \
--env PGADMIN_DEFAULT_EMAIL=superman@google.com \
-dp 8080:80 \
dpage/pgadmin4:6.17

    #? CONTAINER ID   IMAGE                 COMMAND                  CREATED         STATUS         PORTS                                            NAMES
    # 0672eadb8d24   dpage/pgadmin4:6.17   "/entrypoint.sh"         4 seconds ago   Up 3 seconds   443/tcp, 0.0.0.0:8080->80/tcp, :::8080->80/tcp   pgAdmin
    # dddb3a2a79ac   postgres:alpine3.19   "docker-entrypoint.s…"   4 minutes ago   Up 4 minutes   0.0.0.0:5432->5432/tcp, :::5432->5432/tcp        postgres-db



#CREMOS LA RED PARA CONECTAR LOS CONTENEDORES
docker network create postgres-net
        #? alandev@alandev:~/Documents/docker-dev$ docker network ls
        # NETWORK ID     NAME           DRIVER    SCOPE
        # 9331875b63bd   bridge         bridge    local
        # 8b24c0aaf9c7   host           host      local
        # 429646926bad   none           null      local
        #! 5aa4851d669e   postgres-net   bridge    local

        #Ahora conectamos los contenedores a la red
        docker container ls
            #? CONTAINER ID   IMAGE                 COMMAND                  CREATED         STATUS         PORTS                                       NAMES
            # 0672eadb8d24   dpage/pgadmin4:6.17   "/entrypoint.sh"         7 minutes ago    Up 7 minutes    443/tcp, 0.0.0.0:8080->80/tcp, :::8080->80/tcp   pgAdmin
            # dddb3a2a79ac   postgres:alpine3.19   "docker-entrypoint.s…"   11 minutes ago   Up 11 minutes   0.0.0.0:5432->5432/tcp, :::5432->5432/tcp        postgres-db        
        
        docker network connect postgres-db 0672 
        docker network connect postgres-db dddb

        #Inspeccionamos la red para ver si estan conectados los contenedor
        docker network inspect postgres-net
            # [
            #     {
            #         "Name": "postgres-net",
            #         "Id": "5aa4851d669eabf491b174e7024c83bdc93c9f9693978b7498a66458d4470f2f",
            #         "Created": "2024-04-24T20:15:38.393763828-06:00",
            #         "Scope": "local",
            #         "Driver": "bridge",
            #         "EnableIPv6": false,
            #         "IPAM": {
            #             "Driver": "default",
            #             "Options": {},
            #             "Config": [
            #                 {
            #                     "Subnet": "172.18.0.0/16",
            #                     "Gateway": "172.18.0.1"
            #                 }
            #             ]
            #         },
            #         "Internal": false,
            #         "Attachable": false,
            #         "Ingress": false,
            #         "ConfigFrom": {
            #             "Network": ""
            #         },
            #         "ConfigOnly": false,
            #!         "Containers": {
            #!             "0672eadb8d241a9d792ffd97c2f37226bd476e15e52c1a80ba036f9ba48365b6": {
            #!                 "Name": "pgAdmin",
            #!                 "EndpointID": "a4dca02340b55a144b04140ddbd454cd5265b5bca2e86829b025e50cb154bc4b",
            #!                 "MacAddress": "02:42:ac:12:00:02",
            #!                 "IPv4Address": "172.18.0.2/16",
            #!                 "IPv6Address": ""
            #!             }
            #!         },
            #         "Options": {},
            #         "Labels": {}
            #     }
            # ]

# Ahora ingresamos al puerto 8080 con las credenciales de la BDD que creamos.