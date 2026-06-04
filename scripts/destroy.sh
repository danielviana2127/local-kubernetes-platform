#!/bin/bash

kubectl delete -f kubernetes/ingress/ --ignore-not-found
kubectl delete -f kubernetes/services/ --ignore-not-found
kubectl delete -f kubernetes/deployments/ --ignore-not-found