# Multi-k8s

Deploys a multi-container application to Kubernetes cluster running in GCE-GKE.

## Setup Google Cloud

You need to:

* Create a [Google account](https://www.google.com)
* Go to [Google Cloud console](https://console.cloud.google.com/), create a new project, e.g. `multi-k8s`
* Set up billing for this project
* Create a service account for this project
* Create a new key (credentials) for this service account, we will use this for deployment

Following steps are also needed before running deployment.

* Create a new cluster `multi-cluster`
* Use cloud console, install [`helm`](https://helm.sh/) if needed
* Configure environment to use our project

  ```sh
  gcloud config set project multi-k8s-225102
  gcloud config set compute/zone australia-southeast1-a
  ```

* Configure `kubectl` to use our cluster

  ```sh
  gcloud container clusters get-credentials multi-cluster
  ```

* Install [ingress-nginx](https://github.com/kubernetes/ingress-nginx) using [helm](https://kubernetes.github.io/ingress-nginx/deploy/#using-helm)

  ```sh
  helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
  helm repo update
  
  helm install ingress-nginx ingress-nginx/ingress-nginx
  ```

* Create a secret `pgpassword` using `kubectl`.

  ```sh
  kubectl create secret generic pgpassword --from-literal 'PGPASSWORD=Passw@rd123!!'
  ```

Once above steps are done, we can deployment successfully.

## Setup GCP credentials in travis-ci.com

This step is needed because we want to use `travis-ci` to deploy our application into GCE-GKE. We will encrypt our GCE credentials first. Decryption key will be configured as a secret in travis-ci. Encrypted credentials file will be added to the repo.

### Start a new container based on `ruby`

```sh
docker run -it --name my-travis -v $(pwd):/app ruby:latest bash
```

### Install `travis`

Then inside terminal, run following command to install `travis`.

```sh
gem install travis
```

### Login travis-ci.com and then encrypt credentials file

First, we need to login, we can use `--com` to log into `travis-ci.com`.

```txt
$ travis login -g your-github-token --com
Successfully logged in as your-github-username!
```

Then run `encrypt-file` command to add encrypted data into your repo settings, note `--com` was used.

```txt
$ travis encrypt-file service-account.json -r your-github-username/your-repo-name --com
encrypting service-account.json for your-github-username/your-repo-name
storing result as service-account.json.enc
storing secure env variables for decryption

Please add the following to your build script (before_install stage in your .travis.yml, for instance):

    openssl aes-256-cbc -K $encrypted_9f3b5599b056_key -iv $encrypted_9f3b5599b056_iv -in service-account.json.enc -out service-account.json -d

Pro Tip: You can add it automatically by running with --add.

Make sure to add service-account.json.enc to the git repository.
Make sure not to add service-account.json to the git repository.
Commit all changes to your .travis.yml.
```

### Add encrypted credential file

Don't forget to add `service-account.json.enc` into your repo, _*NOT*_ `service-account.json`.

## Configure our cluster to support https

We will need to setup our cluster to automatically apply for a certificate from [Letsencrypt](https://letsencrypt.org/).

### Install cert manager

Using cloud console, run following commands to [install cert manager](https://cert-manager.io/docs/installation/kubernetes/#installing-with-helm).

Create the namespace for cert-manager:

```sh
kubectl create namespace cert-manager
```

Add the Jetstack Helm repository:

```sh
helm repo add jetstack https://charts.jetstack.io
```

Update your local Helm chart repository cache:

```sh
helm repo update
```

Install the cert-manager Helm chart:

```sh
helm install \
  cert-manager jetstack/cert-manager \
  --namespace cert-manager \
  --version v1.2.0 \
  --create-namespace
```

Install the CRDs:

```sh
kubectl apply -f https://github.com/jetstack/cert-manager/releases/download/v1.2.0/cert-manager.crds.yaml
```

### Create configuration for issuer and certificate
