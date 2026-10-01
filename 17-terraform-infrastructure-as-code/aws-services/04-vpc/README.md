# AWS VPC (Virtual Private Cloud)

**Student Name:** Ujjwal Jain
**Roll Number:** 24bcs10173
**Section:** Section B

## What is VPC?

A VPC is a logically isolated private network inside AWS, within which EC2 instances, databases, and most other networked AWS resources run. It is the cloud equivalent of the private Docker network this repo's own [Docker networking module](../../../07-docker-networking-and-volumes/README.md) demonstrates, just at AWS account scale rather than on one machine: its own IP address range, its own routing, its own isolation from every other customer's traffic by default.

## CIDR

CIDR notation (for example `10.0.0.0/16`) defines a VPC's IP address range: the base address plus a prefix length stating how many leading bits are fixed, leaving the rest available for subnets and hosts. `/16` gives 65,536 addresses; a `/24` subnet carved out of it gives 256. This is the same CIDR math already covered in [module 03](../../../03-networking-fundamentals/README.md)'s subnetting section, applied here to a cloud-defined network instead of a physical one.

## Subnets

A subnet is a segment of the VPC's CIDR range, tied to exactly one Availability Zone. Every resource that needs an IP (an EC2 instance, an RDS database) is launched into a specific subnet, not directly into the VPC itself. Subnets are the mechanism by which "public" and "private" actually get defined, through which route table each subnet is associated with, not through any property of the subnet itself.

## Route tables

A route table is a set of rules deciding where network traffic from a subnet is sent next, matched by destination CIDR. The default, implicit rule always routes traffic within the VPC's own CIDR locally. An explicit route for `0.0.0.0/0` (everything else) pointing at an Internet Gateway is what actually makes a subnet "public"; without that route, a subnet is private even if nothing else about it looks restricted.

## Internet Gateway

An Internet Gateway is attached once per VPC and provides the path between the VPC and the public internet. A subnet only becomes internet-reachable once its route table sends `0.0.0.0/0` traffic to this gateway; attaching the gateway to the VPC is necessary but not sufficient on its own.

## NAT Gateway

A NAT Gateway lives in a public subnet and lets resources in a private subnet (no public IP, not directly reachable from outside) still initiate outbound connections to the internet, for example to download OS packages, while remaining unreachable from the internet themselves. This is the standard pattern for a private database or backend service that needs outbound internet access but should never accept an inbound connection from outside the VPC.

## Security Groups

Covered in more operational detail in the [EC2 writeup](../02-ec2/README.md#security-groups); in VPC terms, a security group is the instance-level (not subnet-level) firewall: stateful, allow-only rules attached to individual resources' network interfaces rather than to a subnet as a whole.

## Network ACLs

A Network ACL is a stateless firewall at the subnet boundary, evaluated before security groups for inbound traffic. Stateless means return traffic has to be explicitly allowed by its own rule; nothing is implicitly permitted back in just because the outbound request was allowed, unlike a security group. Rules are numbered and evaluated in order, and can explicitly `DENY`, which security groups cannot do. Most workloads never need a custom Network ACL since the VPC's default one allows everything and lets security groups do the real filtering, but it is the one network-layer tool in a VPC that can deny by IP outright.

## Public vs. private subnet

The distinction is entirely about that subnet's route table, not a label or a checkbox:

| | Public subnet | Private subnet |
|---|---|---|
| Route to `0.0.0.0/0` | Via Internet Gateway | Via NAT Gateway (outbound only), or no route at all |
| Reachable from the internet | Yes, if also assigned a public IP | No |
| Typical resident | Load balancers, bastion hosts | Application servers, databases |

## Common use cases

- A standard two-tier layout: public subnets holding load balancers, private subnets holding application servers and databases behind them.
- VPC peering, connecting two separate VPCs (for example a shared-services VPC and an application VPC) so resources in each can reach the other privately.
- Isolating environments: a separate VPC per environment (dev/staging/prod) so a misconfiguration in one can never reach another.
