# Citadel Bitcoin Node #ordisrespector hack
This guide is heavily based on [Umbrel's Bitcoin Node #ordirespector hack](https://github.com/printer-jam/umbrel-ordisrespector)

With this guide you can copy&paste some terminal commands to get your node patched. 

Keep in mind that future node updates will break this patch.

**Citadel node #ordisrespector hack**
Do it at your own risk.
The following guide just clones this repo, builds a docker image with Ordisrespector patch applied and replaces the docker-compose.yml configuration file to use this new created image.

## TL:DR
Get Ordisrespector automatically applied by running this one-liner command
```sh
~ $ mkdir ~/.ordisrespector && git clone https://github.com/zehks/citadel-ordisrespector/ ~/.ordisrespector && sudo chmod +x ~/.ordisrespector/ordisrespector.sh && sudo ~/.ordisrespector/ordisrespector.sh
```
You are done.
## Put the Dockerfile in a folder on your Citadel node, and build it.

```sh
~ $ mkdir ~/.ordisrespector
~ $ git clone https://github.com/zehks/citadel-ordisrespector/ ~/.ordisrespector
~ $ docker build -t ordisrespector/bitcoinknots:v23.0 ~/.ordisrespector
``` 
This may take a long while depending on the specs of your node, like 30+ minutes, so do maybe do it in screen or tmux or if you want to do it off your node and you know how, do that.

## Backup Citadel image, and retag this imaage:
We are assuming you run Citadel on a systemd unit called "citadel". If you don't run Citadel as a service, run the stop script manually.
```sh
~ $ sudo systemctl stop citadel
```
or
``` sh
~ $ sudo ~/citadel/scripts/stop
```
Then
```sh
~ $ docker tag $(docker images | grep "ghcr.io/runcitadel/bitcoinknots" | awk '{ print $3 }') runcitadel/bitcoinknots:original
~ $ docker tag ordisrespector/bitcoinknots:v23.0 runcitadel/bitcoinknots:v23.0
```

## Edit the bitcoind docker-compose.yml
and change the bitcoind image to remove the hash part and replace with the tag:

```sh
~ $ sed -i 's/ghcr\.io\/runcitadel\/bitcoinknots:main@sha256:\.\?[a-zA-Z0-9]\{64\}/runcitadel\/bitcoinknots:v23\.0/g' ~/citadel/services/bitcoin/knots.yml
```
Then

```sh
~ $ sudo systemctl start citadel
```
or
``` sh
~ $ sudo ~/citadel/scripts/start
```

## Ignore the low fee full blocks.

## **Rollback**
If it messes up another Citadel application, to revert the changes just:

```sh
$ docker image rm runcitadel/bitcoinknots:v23.0
$ docker tag runcitadel/bitcoinknots:original runcitadel/bitcoinknots:v23.0
```

Then restart Citadel however it worked to get the new image above.
