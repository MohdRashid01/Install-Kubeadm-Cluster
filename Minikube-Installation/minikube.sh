#!/bin/bash

Step1 :- sudo apt install docker.io
Step2 :- sudo usermod -aG docker $USER && newgrp docker
Step3 :- curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube_latest_amd64.deb
Step4 :- sudo dpkg -i minikube_latest_amd64.deb
Step5 :- minikube start
Step6 :- kubectl get po -A
Step7 :- minikube kubectl -- get po -A
Step8 :- alias kubectl="minikube kubectl --"
