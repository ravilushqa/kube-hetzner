## kube-hetzner

## About The Project
This project aims to create a highly optimized Kubernetes installation on Hetzner Cloud. It is based 
on the great work of [kube-hetzner/terraform-hcloud-kube-hetzner](https://github.com/kube-hetzner/terraform-hcloud-kube-hetzner)

## Getting Started

Follow those simple steps, and your world's cheapest Kube cluster will be up and running.

### ✔️ Prerequisites

First and foremost, you need to have a Hetzner Cloud account. You can sign up for free [here](https://hetzner.com/cloud/).

Then you'll need to have [terraform](https://learn.hashicorp.com/tutorials/terraform/install-cli),  [kubectl](https://kubernetes.io/docs/tasks/tools/) cli and [hcloud](<https://github.com/hetznercloud/cli>) the Hetzner cli. The easiest way is to use the [homebrew](https://brew.sh/) package manager to install them (available on Linux, Mac, and Windows Linux Subsystem).

```sh
brew install terraform
brew install kubectl
brew install hcloud
```

```shell
cp terraform/credentials.auto.tfvars.example terraform/credentials.auto.tfvars
```
Setup cloudflare_api_key, cloudflare_email, cloudflare_zone_id, hcloud_token on terraform/credentials.auto.tfvars

Place your email in the cert-manager.tf file in placeholer {your-email}

```shell

### 🚀 Installation
```sh
cd terraform
terraform init --upgrade
terraform validate
terraform apply -auto-approve
```

## Usage

When your brand-new cluster is up and running, the sky is your limit! 🎉

You can immediately kubectl into it (using the `clustername_kubeconfig.yaml` saved to the project's directory after the installation). By doing `kubectl --kubeconfig clustername_kubeconfig.yaml`, but for more convenience, either create a symlink from `~/.kube/config` to `clustername_kubeconfig.yaml` or add an export statement to your `~/.bashrc` or `~/.zshrc` file, as follows (you can get the path of `clustername_kubeconfig.yaml` by running `pwd`):

```sh
export KUBECONFIG=/<path-to>/clustername_kubeconfig.yaml
```

If chose to turn `create_kubeconfig` to false in your kube.tf (good practice), you can still create this file by running `terraform output --raw kubeconfig_file > clustername_kubeconfig.yaml` and then use it as described above.

You can also use it in an automated flow, in which case `create_kubeconfig` should be set to false, and you can use the `kubeconfig` output variable to get the kubeconfig file in a structured data format.

_You can view all kinds of details about the cluster by running `terraform output kubeconfig` or `terraform output -json kubeconfig | jq`._

More information about the cluster can be found in the [kube-hetzner/terraform-hcloud-kube-hetzner](https://github.com/kube-hetzner/terraform-hcloud-kube-hetzner)
