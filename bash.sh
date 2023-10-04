#/bin/bash

###
#127.0.0.1       smongo1
#127.0.0.2       smongo2
#127.0.0.3       smongo3
#
#127.0.1.1       dmongo1
#127.0.1.2       dmongo2
#127.0.1.3       dmongo3


sudo ifconfig lo0 alias 127.0.0.2 up
sudo ifconfig lo0 alias 127.0.0.3 up

#source
docker network create smongoCluster

docker run -d --rm -p 127.0.0.1:27017:27017 --name smongo1 --network smongoCluster mongo:6 mongod --replSet rs_src --bind_ip localhost,smongo1
docker run -d --rm -p 127.0.0.2:27017:27017 --name smongo2 --network smongoCluster mongo:6 mongod --replSet rs_src --bind_ip localhost,smongo2
docker run -d --rm -p 127.0.0.3:27017:27017 --name smongo3 --network smongoCluster mongo:6 mongod --replSet rs_src --bind_ip localhost,smongo3

docker exec -it smongo1 mongosh --eval "rs.initiate({
    _id: \"rs_src\",
    members: [
      {_id: 0, host: \"smongo1\"},
      {_id: 1, host: \"smongo2\"},
      {_id: 2, host: \"smongo3\"}
    ]
})"


#dest
sudo ifconfig lo0 alias 127.0.1.1 up
sudo ifconfig lo0 alias 127.0.1.2 up
sudo ifconfig lo0 alias 127.0.1.3 up

docker network create dmongoCluster
docker run -d --rm -p 127.0.1.1:27017:27017 --name dmongo1 --network dmongoCluster mongo:6 mongod --replSet rs_dst --bind_ip localhost,dmongo1
docker run -d --rm -p 127.0.1.2:27017:27017 --name dmongo2 --network dmongoCluster mongo:6 mongod --replSet rs_dst --bind_ip localhost,dmongo2
docker run -d --rm -p 127.0.1.3:27017:27017 --name dmongo3 --network dmongoCluster mongo:6 mongod --replSet rs_dst --bind_ip localhost,dmongo3

docker exec -it dmongo1 mongosh --eval "rs.initiate({
    _id: \"rs_dst\",
    members: [
      {_id: 0, host: \"dmongo1\"},
      {_id: 1, host: \"dmongo2\"},
      {_id: 2, host: \"dmongo3\"}
    ]
})"
