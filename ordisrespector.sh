#!/bin/bash
if [ "$EUID" -ne 0 ]
  then echo "Please run with sudo."
  exit
fi
echo "Remoging previously created Ordisrespector images"
docker image rm ordisrespector/bitcoinknots:v23.0
echo "Building Bitcoin Knots v23.0 with Ordisrespector patch.... This will take a while."
docker build -t ordisrespector/bitcoinknots:v23.0 /home/$SUDO_USER/.ordisrespector
if [ $? -eq 0 ]; then
    echo "Finished building. Stopping Citadel."
    /home/$SUDO_USER/citadel/scripts/stop
    if [ $? -eq 0 ]; then
        echo "Citadel stopped, tagging docker images"
        docker tag $(docker images | grep "ghcr.io/runcitadel/bitcoinknots" | awk '{ print $3 }') runcitadel/bitcoinknots:original
        if [ $? -eq 0 ]; then
            docker tag ordisrespector/bitcoinknots:v23.0 runcitadel/bitcoinknots:v23.0
            echo "Images tagged successfully, applying compiled Knots to Citadel..."
            if [ $? -eq 0 ]; then
                sed -i 's/ghcr\.io\/runcitadel\/bitcoinknots:main@sha256:\.\?[a-zA-Z0-9]\{64\}/runcitadel\/bitcoinknots:v23\.0/g' /home/$SUDO_USER/citadel/services/bitcoin/knots.yml
                if [ $? -eq 0 ]; then
                    echo "Starting Citadel again...."
                    /home/$SUDO_USER/citadel/scripts/start
                    echo ""
                    echo ""
                    echo "Ordisrespector applied successfully"
                fi
            fi
        fi
    fi
fi