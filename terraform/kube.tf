locals {
  # Fill first and foremost your Hetzner API token, found in your project, Security, API Token, of type Read & Write.
  hcloud_token = var.hcloud_token
}

module "kube-hetzner" {
  providers = {
    hcloud = hcloud
  }
  hcloud_token = local.hcloud_token

  # Then fill or edit the below values. Only the first values starting with a * are obligatory; the rest can remain with their default values, or you
  # could adapt them to your needs.

  # * For local dev, path to the git repo
  # source = "../../kube-hetzner/"
  # If you want to use the latest master branch
  # source = "github.com/kube-hetzner/terraform-hcloud-kube-hetzner"
  # For normal use, this is the path to the terraform registry
  source = "kube-hetzner/kube-hetzner/hcloud"

  # you can optionally specify a version number
  # version = "1.2.0"

  # Note that some values, notably "location" and "public_key" have no effect after initializing the cluster.
  # This is to keep Terraform from re-provisioning all nodes at once, which would lose data. If you want to update
  # those, you should instead change the value here and manually re-provision each node. Grep for "lifecycle".

  # Customize the SSH port (by default 22)
  # ssh_port = 2222

  # * Your ssh public key
  ssh_public_key  = file("/Users/ravil/.ssh/id_ed25519.pub")
  # * Your private key must be "ssh_private_key = null" when you want to use ssh-agent for a Yubikey-like device authentification or an SSH key-pair with a passphrase.
  # For more details on SSH see https://github.com/kube-hetzner/kube-hetzner/blob/master/docs/ssh.md
  ssh_private_key = file("/Users/ravil/.ssh/id_ed25519")
  # You can add additional SSH public Keys to grant other team members root access to your cluster nodes.
  # ssh_additional_public_keys = []

  # You can also add additional SSH public Keys which are saved in the hetzner cloud by a label.
  # See https://docs.hetzner.cloud/#label-selector
  # ssh_hcloud_key_label = "role=admin"

  # If you want to use an ssh key that is already registered within hetzner cloud, you can pass its id.
  # If no id is passed, a new ssh key will be registered within hetzner cloud.
  # It is important that exactly this key is passed via `ssh_public_key` & `ssh_private_key` vars.
  # hcloud_ssh_key_id = ""

  # These can be customized, or left with the default values
  # * For Hetzner locations see https://docs.hetzner.com/general/others/data-centers-and-connection/
  network_region = "eu-central" # change to `us-east` if location is ash

  # For the control planes, at least three nodes are the minimum for HA. Otherwise, you need to turn off the automatic upgrade (see ReadMe).
  # As per Rancher docs, it must always be an odd number, never even! See https://rancher.com/docs/k3s/latest/en/installation/ha-embedded/
  # For instance, one is ok (non-HA), two is not ok, and three is ok (becomes HA). It does not matter if they are in the same nodepool or not! So they can be in different locations and of various types.

  # Of course, you can choose any number of nodepools you want, with the location you want. The only constraint on the location is that you need to stay in the same network region, Europe, or the US.
  # For the server type, the minimum instance supported is cpx11 (just a few cents more than cx11); see https://www.hetzner.com/cloud.

  # IMPORTANT: Before you create your cluster, you can do anything you want with the nodepools, but you need at least one of each control plane and agent.
  # Once the cluster is up and running, you can change nodepool count and even set it to 0 (in the case of the first control-plane nodepool, the minimum is 1),
  # you can also rename it (if the count is 0), but do not remove a nodepool from the list.

  # The only nodepools that are safe to remove from the list when you edit it are at the end of the lists. That is due to how subnets and IPs get allocated (FILO).
  # You can, however, freely add other nodepools at the end of each list if you want! The maximum number of nodepools you can create combined for both lists is 255.
  # Also, before decreasing the count of any nodepools to 0, it's essential to drain and cordon the nodes in question. Otherwise, it will leave your cluster in a bad state.

  # Before initializing the cluster, you can change all parameters and add or remove any nodepools. You need at least one nodepool of each kind, control plane, and agent.
  # The nodepool names are entirely arbitrary, you can choose whatever you want, but no special characters or underscore, and they must be unique; only alphanumeric characters and dashes are allowed.

  # If you want to have a single node cluster, have one control plane nodepools with a count of 1, and one agent nodepool with a count of 0.

  # Please note that changing labels and taints after the first run will have no effect. If needed, you will need to do that through Kubernetes directly.

  # * Example below:

  control_plane_nodepools = [
    #    {
    #      name        = "control-plane-fsn1",
    #      server_type = "cpx11",
    #      location    = "fsn1",
    #      labels      = [],
    #      taints      = [],
    #      count       = 1
    #    },
    #    {
    #      name        = "control-plane-nbg1",
    #      server_type = "cpx11",
    #      location    = "nbg1",
    #      labels      = [],
    #      taints      = [],
    #      count       = 1
    #    },
    {
      name        = "control-plane-hel1",
      server_type = "cpx11",
      location    = "hel1",
      labels      = [],
      taints      = [],
      count       = 1
    }
  ]

  agent_nodepools = [
    {
      name        = "agent-small",
      server_type = "cpx11",
      location    = "hel1",
      labels      = [],
      # To exclude from Longhorn if that is used for instance. Completely optional.
      taints      = [
        #        "server-usage=storage:NoSchedule"
      ],
      count = 1
    },
    {
      name        = "agent-medium",
      server_type = "cx21",
      location    = "hel1",
      labels      = [],
      taints      = [],
      count       = 1
    },
    #    {
    #      name        = "agent-large",
    #      server_type = "cpx21",
    #      location    = "nbg1",
    #      labels      = [],
    #      taints      = [],
    #      count = 1
    #    },
    #    {
    #      name        = "storage",
    #      server_type = "cpx21",
    #      location    = "fsn1",
    #      # Fully optional, just a demo.
    #      labels = [
    #        "node.kubernetes.io/server-usage=storage"
    #      ],
    #      taints = [],
    #      count = 1
    #      # In the case of using Longhorn, you can use Hetzner volumes instead of using the node's own storage by specifying a value from 10 to 10000 (in GB)
    #      # It will create one volume per node in the nodepool, and configure Longhorn to use them.
    #      # Something worth noting is that Volume storage is slower than node storage, which is achieved by not mentioning longhorn_volume_size or setting it to 0.
    #      # So for something like DBs, you definitely want node storage, for other things like backups, volume storage is fine, and cheaper.
    #      # longhorn_volume_size = 20
    #    }
  ]

  # * LB location and type, the latter will depend on how much load you want it to handle, see https://www.hetzner.com/cloud/load-balancer
  load_balancer_type     = "lb11"
  load_balancer_location = "hel1"

  ### The following values are entirely optional (and can be removed from this if unused)

  # You can refine a base domain name to be use in this form of nodename.base_domain for setting the reserve dns inside Hetzner
  # base_domain = "mycluster.example.com"

  # Cluster Autoscaler
  # Providing at least one map for the array enables the cluster autoscaler feature, default is disabled
  # * Example below:
  # autoscaler_nodepools = [
  #   {
  #     name        = "autoscaler"
  #     server_type = "cpx21" # must be same or better than the control_plane server type (regarding disk size)!
  #     location    = "fsn1"
  #     min_nodes   = 0
  #     max_nodes   = 5
  #   }
  # ]

  # Enable etcd snapshot backups to S3 storage.
  # Just provide a map with the needed settings (according to your S3 storage provider) and backups to S3 will
  # be enabled (with the default settings for etcd scnapshots).
  # For proper context, please have a look at https://docs.k3s.io/backup-restore.
  # etcd_s3_backup = {
  #   etcd-s3-endpoint        = "xxxx.r2.cloudflarestorage.com"
  #   etcd-s3-access-key      = "<access-key>"
  #   etcd-s3-secret-key      = "<secret-key>"
  #   etcd-s3-bucket          = "k3s-etcd-snapshots"
  # }

  # To use local storage on the nodes, you can enable Longhorn, default is "false".
  # See a full recap on how to configure agent nodepools for longhorn here https://github.com/kube-hetzner/terraform-hcloud-kube-hetzner/discussions/373#discussioncomment-3983159
  # enable_longhorn = true

  # The file system type for Longhorn, if enabled (ext4 is the default, otherwise you can choose xfs)
  # longhorn_fstype = "xfs"

  # how many replica volumes should longhorn create (default is 3)
  # longhorn_replica_count = 1

  # When you enable Longhorn, you can go with the default settings and just modify the above two variables OR you can add a longhorn_values variable
  # with all needed helm values, see towards the end of the file in the advanced section.
  # If that file is present, the system will use it during the deploy, if not it will use the default values with the two variable above that can be customized.
  # After the cluster is deployed, you can always use HelmChartConfig definition to tweak the configuration.

  # Also, you choose to create a hetzner volume to be used with Longhorn. By default, it will use the nodes own storage space, BUT if you an attribute of
  # longhorn_volume_size (⚠️ not a variable, just a possible agent nodepool attribute) with a value of 10 to 10000 GB to your agent nodepool definition, it will create and use the volume in question.
  # See the agent nodepool section for an example of how to do that.

  # To disable Hetzner CSI storage, you can set the following to true, default is "false".
  # disable_hetzner_csi = true

  # If you want to use a specific Hetzner CCM and CSI version, set them below; otherwise, leave them as-is for the latest versions.
  # hetzner_ccm_version = ""
  # hetzner_csi_version = ""

  # If you want to specify the Kured version, set it below - otherwise it'll use the latest version available.
  # kured_version = ""

  # If you want to enable the Nginx ingress controller (https://kubernetes.github.io/ingress-nginx/) instead of Traefik, you can set this to "true". Default is "false".
  # FOR THIS TO NOT BE IGNORED, you also need to set "enable_traefik = false".
  # By the default we load an optimal Nginx ingress controller config for Hetzner, however you may need to tweak it to your needs, so to do,
  # we allow you to add a nginx_ingress_values, see towards the end of this file in the advanced section.
  # After the cluster is deployed, you can always use HelmChartConfig definition to tweak the configuration.
  # enable_nginx = true

  # If you want to disable the Traefik ingress controller, to use the Nginx ingress controller for instance, you can can set this to "false". Default is "true".
  # enable_traefik = false

  # Use the klipper LB (similar to metalLB), instead of the default Hetzner one, that has an advantage of dropping the cost of the setup.
  # Automatically "true" in the case of single node cluster (as it does not make sense to use the Hetzner LB in that situation).
  # It can work with any ingress controller that you choose to deploy.
  # Please note that because the klipper lb points to all nodes, we automatically allow scheduling on the control plane when it is active.
  # enable_klipper_metal_lb = "true"

  # We give you the possibility to use letsencrypt directly with Traefik because it's an easy setup, however it's not optimal,
  # as the free version of Traefik causes a little bit of downtime when when the certificates get renewed. For proper SSL management,
  # we instead recommend you to use cert-manager, that you can easily deploy with helm; see https://cert-manager.io/.
  # traefik_acme_tls = true
  # traefik_acme_email = "mail@example.com"

  # If you want to configure additional Arguments for traefik, enter them here as a list and in the form of traefik CLI arguments; see https://doc.traefik.io/traefik/reference/static-configuration/cli/
  # They are the options that go into the additionalArguments section of the Traefik helm values file.
  # Example: traefik_additional_options = ["--log.level=DEBUG", "--tracing=true"]
  traefik_additional_options = [
    "--log.level=DEBUG",
    "--serversTransport.insecureSkipVerify=true",
  ]

  # If you want to disable the metric server, you can! Default is "true".
  # enable_metrics_server = false

  # If you want to allow non-control-plane workloads to run on the control-plane nodes, set "true" below. The default is "false".
  # True by default for single node clusters, and when enable_klipper_metal_lb is true. In those cases, the value below will be ignored.
  # allow_scheduling_on_control_plane = true

  # If you want to disable the automatic upgrade of k3s, you can set this to false.
  # Ideally, keep it on, to always have the latest and greatest Kubernetes version, but lock the initial_k3s_channel to a kube major version,
  # of your choice, like v1.24 or v1.25. That way you get the best of both worlds without the breaking changes risk.
  # The default is "true" (If you are in HA i.e. at least 3 control plane nodes & 2 agents, just keep it, it works great!)
  # automatically_upgrade_k3s = false

  # For non-HA clusters i.e. when the number of control-plane nodes is < 3, you have to turn it off.
  # Ideally, for production use, always use an HA setup with at least 3 control-plane nodes and 2 agents, and keep this on for max security.
  # The default is "true" (in HA it works wonderfully well, with automatically roll-back to the previous snapshot in case of an issue).
  automatically_upgrade_os = false

  # Allows you to specify either stable, latest, testing or supported minor versions (defaults to stable)
  # see https://rancher.com/docs/k3s/latest/en/upgrades/basic/ and https://update.k3s.io/v1-release/channels
  # ⚠️ If you are going to use Rancher addons for instance, it's always a good idea to fix the kube version to latest - 0.01,
  # at the time of writing the latest is v1.25, so setting the value below to "v1.24" will insure maximum compatibility with Rancher, Longhorn and so on!
  # The default is "v1.24".
  # initial_k3s_channel = "stable"

  # The cluster name, by default "k3s"
  # cluster_name = ""

  # Whether to use the cluster name in the node name, in the form of {cluster_name}-{nodepool_name}, the default is "true".
  # use_cluster_name_in_node_name = false

  # Adding extra firewall rules, like opening a port
  # More info on the format here https://registry.terraform.io/providers/hetznercloud/hcloud/latest/docs/resources/firewall
  # extra_firewall_rules = [
  #   # For Postgres
  #   {
  #     direction       = "in"
  #     protocol        = "tcp"
  #     port            = "5432"
  #     source_ips      = ["0.0.0.0/0", "::/0"]
  #     destination_ips = [] # Won't be used for this rule
  #   },
  #   # To Allow ArgoCD access to resources via SSH
  #   {
  #     direction       = "out"
  #     protocol        = "tcp"
  #     port            = "22"
  #     source_ips      = [] # Won't be used for this rule
  #     destination_ips = ["0.0.0.0/0", "::/0"]
  #   }
  # ]

  # If you want to configure a different CNI for k3s, use this flag
  # possible values: flannel (Default), calico, and cilium
  # As for Cilium, we allow infinite configurations via helm values, please check the CNI section of the readme over at https://github.com/kube-hetzner/terraform-hcloud-kube-hetzner/#cni.
  # Also, see the cilium_values at towards the end of this file, in the advanced section.
  # cni_plugin = "cilium"

  # If you want to disable the k3s default network policy controller, use this flag!
  # Both Calico and Ciliun cni_plugin values override this value to true automatically, the default is "false".
  # disable_network_policy = true

  # If you want to disable the automatic use of placement group "spread". See https://docs.hetzner.com/cloud/placement-groups/overview/
  # That may be useful if you need to deploy more than 500 nodes! The default is "false".
  # placement_group_disable = true

  # By default, we allow ICMP ping in to the nodes, to check for liveness for instance. If you do not want to allow that, you can. Just set this flag to true (false by default).
  # block_icmp_ping_in = true

  # You can enable cert-manager (installed by Helm behind the scenes) with the following flag, the default is "false".
  # enable_cert_manager = true

  # IP Addresses to use for the DNS Servers, set to an empty list to use the ones provided by Hetzner, defaults to ["1.1.1.1", " 1.0.0.1", "8.8.8.8"].
  # For rancher installs, best to leave it as default.
  # dns_servers = []

  # When this is enabled, rather than the first node, all external traffic will be routed via a control-plane loadbalancer, allowing for high availability.
  # The default is false.
  # use_control_plane_lb = true

  # You can enable Rancher (installed by Helm behind the scenes) with the following flag, the default is "false".
  # When Rancher is enabled, it automatically installs cert-manager too, and it uses rancher's own self-signed certificates.
  # See for options https://rancher.com/docs/rancher/v2.0-v2.4/en/installation/resources/advanced/helm2/helm-rancher/#choose-your-ssl-configuration
  # The easiest thing is to leave everything as is (using the default rancher self-signed certificate) and put Cloudflare in front of it.
  # As for the number of replicas, by default it is set to the numbe of control plane nodes.
  # You can customized all of the above by adding a rancher_values variable see at the end of this file in the advanced section.
  # After the cluster is deployed, you can always use HelmChartConfig definition to tweak the configuration.
  # IMPORTANT: Rancher's install is quite memory intensive, you will require at least 4GB if RAM, meaning cx21 server type (for your control plane).
  # ALSO, in order for Rancher to successfully deploy, you have to set the "rancher_hostname".
  # enable_rancher = true

  # If using Rancher you can set the Rancher hostname, it must be unique hostname even if you do not use it.
  # If not pointing the DNS, you can just port-forward locally via kubectl to get access to the dashboard.
  # rancher_hostname = "rancher.xyz.dev"

  # When Rancher is deployed, by default is uses the "latest" channel. But this can be customized.
  # The allowed values are "stable" or "latest".
  # rancher_install_channel = "stable"

  # Finally, you can specify a bootstrap-password for your rancher instance. Minimum 48 characters long!
  # If you leave empty, one will be generated for you.
  # (Can be used by another rancher2 provider to continue setup of rancher outside this module.)
  # rancher_bootstrap_password = ""

  # Separate from the above Rancher config (only use one or the other). You can import this cluster directly on an
  # an already active Rancher install. By clicking "import cluster" choosing "generic", giving it a name and pasting
  # the cluster registration url below. However, you can also ignore that and apply the url via kubectl as instructed
  # by Rancher in the wizard, and that would register your cluster too.
  # More information about the registration can be found here https://rancher.com/docs/rancher/v2.6/en/cluster-provisioning/registered-clusters/
  # rancher_registration_manifest_url = "https://rancher.xyz.dev/v3/import/xxxxxxxxxxxxxxxxxxYYYYYYYYYYYYYYYYYYYzzzzzzzzzzzzzzzzzzzzz.yaml"

  # Extra values that will be passed to the `extra-manifests/kustomization.yaml.tpl` if its present.
  # extra_kustomize_parameters={}

  # It is best practice to turn this off, but for backwards compatibility it is set to "true" by default.
  # See https://github.com/kube-hetzner/terraform-hcloud-kube-hetzner/issues/349
  # When "false". The kubeconfig file can instead be created by executing: "terraform output --raw kubeconfig_file > cluster_kubeconfig.yaml"
  # Always be careful to not commit this file!
  # create_kubeconfig = false

  # Don't create the kustomize backup. This can be helpful for automation.
  # create_kustomization = false

  ### ADVANCED - Custom helm values for packages above (search _values if you want to located where those are mentioned upper in this file)
  # ⚠️ Inside the _values variable below are examples, up to you to find out the best helm values possible, we do not provide support for customized helm values.
  # Please understand that the indentation is very important, inside the EOTs, as those are proper yaml helm values.
  # We advise you to use the default values, and only change them if you know what you are doing!

  # Cilium, all Cilium helm values can be found at https://github.com/cilium/cilium/blob/master/install/kubernetes/cilium/values.yaml
  # The following is an example, please note that the current indentation inside the EOT is important.
  /*   cilium_values = <<EOT
ipam:
  mode: kubernetes
devices: "eth1"
k8s:
  requireIPv4PodCIDR: true
kubeProxyReplacement: strict
  EOT */

  # Cert manager, all cert-manager helm values can be found at https://github.com/cert-manager/cert-manager/blob/master/deploy/charts/cert-manager/values.yaml
  # The following is an example, please note that the current indentation inside the EOT is important.
  /*   cert_manager_values = <<EOT
installCRDs: true
replicaCount: 3
webhook:
  replicaCount: 3
cainjector:
  replicaCount: 3
  EOT */

  # Longhorn, all Longhorn helm values can be found at https://github.com/longhorn/longhorn/blob/master/chart/values.yaml
  # The following is an example, please note that the current indentation inside the EOT is important.
  /*   longhorn_values = <<EOT
defaultSettings:
  defaultDataPath: /var/longhorn
persistence:
  defaultFsType: ext4
  defaultClassReplicaCount: 3
  defaultClass: true
  EOT */

  # Nginx, all Nginx helm values can be found at https://github.com/kubernetes/ingress-nginx/blob/main/charts/ingress-nginx/values.yaml
  # You can also have a look at https://kubernetes.github.io/ingress-nginx/, to understand how it works, and all the options at your disposal.
  # The following is an example, please note that the current indentation inside the EOT is important.
  /*   nginx_ingress_values = <<EOT
controller:
  watchIngressWithoutClass: "true"
  kind: "DaemonSet"
  config:
    "use-forwarded-headers": "true"
    "compute-full-forwarded-for": "true"
    "use-proxy-protocol": "true"
  service:
    annotations:
      "load-balancer.hetzner.cloud/name": "k3s"
      "load-balancer.hetzner.cloud/use-private-ip": "true"
      "load-balancer.hetzner.cloud/disable-private-ingress": "true"
      "load-balancer.hetzner.cloud/location": "nbg1"
      "load-balancer.hetzner.cloud/type": "lb11"
      "load-balancer.hetzner.cloud/uses-proxyprotocol": "true"
  EOT */

  # Rancher, all Rancher helm values can be found at https://rancher.com/docs/rancher/v2.5/en/installation/install-rancher-on-k8s/chart-options/
  # The following is an example, please note that the current indentation inside the EOT is important.
  /*   rancher_values = <<EOT
ingress:
  tls:
    source: "rancher"
hostname: "rancher.example.com"
replicas: 1
bootstrapPassword: "supermario"
  EOT */

}

output "kubeconfig" {
  value     = module.kube-hetzner.kubeconfig_file
  sensitive = true
}

output "ingress_public_ipv4" {
  value = module.kube-hetzner.ingress_public_ipv4
}

resource "time_sleep" "wait_for_kubernetes" {

  depends_on = [
    module.kube-hetzner.kubeconfig
  ]

  create_duration = "20s"
}