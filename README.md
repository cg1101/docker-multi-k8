# Multi-k8s

Deploys a multi-container application to Kubernetes cluster running in GCE-GKE.

## Setup GCP credentials in travis-ci.com

```sh
docker run -it --name my-travis -v $(pwd):/app ruby:latest bash
```

Then inside terminal, run following command to install `travis`.

```sh
gem install travis
```

First, we need to login, we can use `--com` to log into `travis.com`.

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

Don't forget to add `service-account.json.enc` into your repo, _*NOT*_ `service-account.json`.
