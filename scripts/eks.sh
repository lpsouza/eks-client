#!/bin/bash

case "$1" in
    configure)
        echo "Starting configuration..."
        # Check if AWS CLI is installed
        if ! command -v aws &> /dev/null; then
            echo "AWS CLI is not installed. Please install it first."
            exit 1
        fi
        # Running AWS configure
        aws configure
        if [ $? -ne 0 ]; then
            echo "Failed to configure AWS CLI. Please check your credentials."
            exit 1
        fi
        echo "AWS CLI configured successfully."
        # List EKS clusters
        echo "Listing EKS clusters..."
        aws eks list-clusters --output table
        if [ $? -ne 0 ]; then
            echo "Failed to list EKS clusters. Please check your AWS configuration."
            exit 1
        fi
        read -p "Enter the name of the EKS cluster you want to configure: " CLUSTER_NAME
        if [ -z "$CLUSTER_NAME" ]; then
            echo "No cluster name provided. Exiting."
            exit 1
        fi
        echo "Configuring kubectl for cluster: $CLUSTER_NAME"
        aws eks update-kubeconfig --name "$CLUSTER_NAME"
        if [ $? -ne 0 ]; then
            echo "Failed to update kubeconfig for cluster $CLUSTER_NAME. Please check your AWS configuration."
            exit 1
        fi
        echo "Kubeconfig updated successfully for cluster $CLUSTER_NAME."
        echo "You can now use kubectl to interact with your EKS cluster."
        echo "Configuration complete."
        ;;
    *)
        echo "Usage: $0 {configure}"
        exit 1
        ;;
esac
