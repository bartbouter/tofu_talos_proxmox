#!/bin/bash
tofu output -raw kubeconfig > kubeconfig.yaml
tofu output -raw talosconfig > talosconfig.yaml
export TALOSCONFIG=$PWD/talosconfig.yaml
export KUBECONFIG=$PWD/kubeconfig.yaml
