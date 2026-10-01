# AWS EC2 (Elastic Compute Cloud)

**Student Name:** Ujjwal Jain
**Roll Number:** 24bcs10173
**Section:** Section B

## What is EC2?

EC2 is AWS's virtual machine service: resizable compute capacity rented by the hour or second, launched from a saved disk image, running inside a VPC. It is the direct cloud equivalent of the Minikube node this repo's Kubernetes modules run on, except EC2 instances are real virtual machines billed per second rather than a local Docker container acting as a Kubernetes node.

## AMI (Amazon Machine Image)

An AMI is the disk image an instance boots from: an operating system plus whatever software was baked into it at image-creation time. AWS publishes official AMIs (Amazon Linux, Ubuntu, Windows Server); the AWS Marketplace adds vendor-published ones; and any running instance can be turned back into a new AMI, which is how a team bakes its own golden image with its own software pre-installed.

## Instance types

Instance types describe the hardware shape: how much vCPU, memory, network, and sometimes local disk or GPU an instance gets. The naming follows a family-generation-size pattern, for example `t3.micro` (burstable general purpose, 3rd generation, smallest size) or `m5.large` (general purpose, 5th generation, mid-size). Families are tuned for different workloads: `t` burstable for variable/light load, `m` general purpose, `c` compute-optimized, `r` memory-optimized.

## Key pairs

A key pair is how SSH access to a Linux instance is normally secured: AWS holds the public key, the private key is downloaded once at creation and never recoverable again if lost. Login then uses that private key instead of a password, the same SSH key-based model already used for GitHub access in this repo's own workflow.

## Security Groups

A security group is a stateful virtual firewall attached to an instance's network interface. Stateful means a response to an allowed outbound request is automatically allowed back in, without needing a matching inbound rule. Rules are allow-only (there is no explicit deny), specified as protocol, port range, and a source (an IP range or another security group).

## EBS (Elastic Block Store)

EBS is persistent network-attached block storage for an instance, functionally the cloud equivalent of attaching a virtual disk. Unlike an instance's own ephemeral local storage, an EBS volume survives an instance stop/start and can be detached from one instance and reattached to another. Volumes can be snapshotted to S3 for backup, and several volume types trade off IOPS, throughput, and cost differently (`gp3` general purpose SSD, `io2` high-IOPS SSD, `st1` throughput-optimized HDD).

## Public vs. private IP

A public IP is internet-routable and reachable from outside AWS; a private IP is only reachable from inside the VPC (or over a VPN/peering connection). An instance can hold both at once. The default public IP assigned on launch changes if the instance stops and starts again, unless an Elastic IP, a static public IP reserved independently of any one instance, is allocated and associated instead.

## Instance lifecycle

`pending` (launching) → `running` → `stopping` → `stopped` (EBS-backed instances only; storage persists, compute is released, the public IP is generally lost) → `running` again, or `shutting-down` → `terminated` (the instance and, depending on its `DeleteOnTermination` setting, its root volume are gone for good). Only `running` time is billed for compute; `stopped` instances still incur EBS storage charges, which is the cost mistake this module's security writeup is partly about avoiding.

## Common use cases

- Hosting a web application or API server directly, without a container orchestrator.
- Acting as a Kubernetes worker node in a self-managed or EKS cluster, the cloud-scale version of what the Minikube node does locally in this repo's other modules.
- Short-lived compute for CI/CD build agents or batch jobs, launched on demand and terminated when the job finishes.
