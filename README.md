# OpenVPN Docker Image

## How To Run
This docker image requires some initialisation steps if there are no certificates / keys already present. If you already have a CA certificate and server certificate / key pair, place them in the following directories:
* CA: `<data>/pki/ca.crt`
* Server certificate: `<data>/pki/issued/server.crt`
* Server key: `<data>/pki/private/server.key`

If not, follow the steps below:
1. Generate the CA and key pair:
```
$ docker run -it -v "/path/to/data:/data" eyedevelop/openvpn
```
Enter a name for your CA and hit enter. After this, look in your data folder and edit the client.cfg and server.cfg to suit your needs. In client.cfg, you NEED to change $$remote$$ to your public ip or domain name.
2. Running the server.
This docker container requires a few extra permissions. On your host, make sure you have a TUN device. On Linux, this is usually `/dev/net/tun`. To run the image, do:
```
$ docker run -d --net=host --cap-add=NET_ADMIN --device="/path/to/tun:/dev/net/tun" -v "/path/to/data:/data" eyedevelop/openvpn

## How To Connect A Client
Adding a client profile is easy. You can generate a certificate/key pair and OpenVPN profile in one go:
```
$ docker exec -it <container_id> /entrypoint.sh make-client <client name>
```
Or with
```
$ docker run -it -v "/path/to/data:/data" eyedevelop/openvpn make-client <client name>
```
Then, a client will be generated and their profile will be put in your data folder under the `clients` directory with the chosen name. All the client needs is this profile, since the key and certificates are embedded.

# Good luck and have fun!
If you like this image, please [donate a coffee](https://paypal.me/eyegaming2) :)