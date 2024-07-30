# EKS Exercise

Note, the CI/CD part of the below solution was originally built on GitLab CI/CD.

## Table of Contents

- [Requirements](#requirements)
- [Deliverables Summary](#deliverables-summary)
- [High-Level Remarks/Decisions](#high-level-remarksdecisions)
- [Setup Instructions/Log - Infrastructure Code](#setup-instructionslog---infrastructure-code)
  - [Local Laptop Install](#local-laptop-install)
  - [Create Terraform IAM user](#create-terraform-iam-user)
  - [Create Terraform Backend](#create-terraform-backend)
  - [Terraform Authentication and Deploy](#terraform-authentication-and-deploy)
  - [Grant Kubernetes Permissions To Other Users](#grant-kubernetes-permissions-to-other-users)
  - [Check New Rights via kubebctl](#check-new-rights-via-kubebctl)
- [Detailed Decision Log - Infrastructure](#detailed-decision-log---infrastructure)
- [Setup Instructions/Log - Infrastructure Pipeline](#setup-instructionslog---infrastructure-pipeline)
  - [Configure for Terraform](#configure-for-terraform)
- [Setup Instructions/Log - Application Pipeline](#setup-instructionslog---application-pipeline)
  - [Install GitLab Agent](#install-gitlab-agent)
  - [Configure for Helm](#configure-for-helm)
  - [Connect Load Balancer to Domain Name](#connect-load-balancer-to-domain-name)
- [Suggested Improvements](#suggested-improvements)
- [Tear-Down Instructions](#tear-down-instructions)

## Requirements

* Deploy Kubernetes cluster.
* Deploy stateful application with stateless web service (domain name provided).
* Cluster/resources - consider security, scalability, availability and repeatability.
* Include automation (i.e. pipelines).
* Use well-known and tested components.
* Follow official recommendations.

## Deliverables Summary
* Infrastructure repo: Repo is ["1.infra-terraform" repo](https://github.com/chrisbuckleycode/eks-infra/blob/main/1.infra-terraform/)
* Infrastructure pipeline dashboard: [NOT AVAILABLE]()
* Application repo: ["2.app-helm" repo](https://github.com/chrisbuckleycode/eks-infra/blob/main/2.app-helm/)
* Application pipeline dashboard: [NOT AVAILABLE]()
* Live site: [NOT AVAILABLE]()

## High-Level Remarks/Decisions

Most of these are a trade-off between increased functionality/security vs complexity. As this project is a proof-of-concept/MVP, I've endeavored to keep the solution simple and of educational value, and reject over-complexity where it doesn't demonstrate good value for our time.

* Repeatability - used Terraform and yaml pipelines throughout for repeatibility.
* Region not specified in requirements. Due to maturity of AWS region, made a nominal choice of "us-east-1".
* AWS is highly available within a region. By way of demonstration, networking and compute span across two availability zones within the above region (three is preferred but to keep costs low and for demonstration purposes I chose two).
* Elected to choose a standard node size of "T3-medium", on-demand class, default EBS disk 20gb. These are good starting categories for "general" workloads and will allow for horizontal scaling (increasing nodes) across availability zones as and when required and can be fine-tuned later.
* Security is a feature that could be improved by working on for several weeks, so hardening to production level standard is clearly beyond scope. Some key architectural decisions have been made with security in mind. But to save time I have also sometimes accepted default settings and suggested customization as a future improvement. Security is defense through depth but there are simply too many layers here to configure in good time.
* Additionally, there is no substitute for having infrastructure security assessed not by the DevOps engineer but by a dedicated security professional.
* Infrastructure code was devised from scratch: (1) AWS does not provide official Terraform modules (unlike other clouds), (2) I could gain more personal educational value from inspecting all the parameters for an AWS Kubernetes cluster. There is a Terraform community module that is quite advanced and I think my approach gives me a better handle on the architecture and parameters.
* GitLab chosen as repository and CI/CD vendor. Very popular choice among industry peers, has good integration with major cloud providers and other vendors as well as a rich feature set. I have no prior experience with this vendor so also of educational value.
* Note: GitLab can provide it's own backend for Terraform and Terraform-specific templates. However, we will use a more typical cloud-provider object storage backend and no templates (rather, use command-line commands).
* Two repositories - one for *infrastructure* deployment, the other for *application* deployment. There could be reasons or preferences to have a single repo, I don't consider this especially important for this small project. Important to note that GitLab CI allows only one pipeline per repo. While it is possible to combine Terraform and Helm commands in a single pipeline, I chose to instead de-couple the infrastructure and application which is easier to implement if coupling is not required.
* Due to going back and forth between features in development dependent on each other, being a sole developer and having time span of a few days, I elected to use a single branch "develop" rather than multiple feature branches. Note: refer only to the "develop"branch as almost nothing is committed to "main" yet, something I intend to do only after evaluation and feedback. I consider this a long term project to which I will be making many merges to main in future (just not quite yet).
* Pipelines will be the typical and (currently) more common "push" deployment model, for brevity of solution. "Pull" deployment model (GitOps e.g. Argo CD, Flux CD) is of greater complexity.
* Shared runners (i.e. SaaS-hosted) have been used. Some prefer self-hosted runners mostly for security reasons. This adds significant complexity to this project and I have therefore elected not to go down this route.
* CI not specified in requirements and will not be included to save time and complexity. Container images to be drawn from public registries.
* Helm is a popular choice for deploying applications and will be used here.
* Code could be imrpoved through refactoring (modularization, parameterization) for hours. I propose this as a future improvement. 


## Setup Instructions/Log - Infrastructure Code

* Repo is ["1.infra-terraform"](https://github.com/chrisbuckleycode/eks-infra/blob/main/1.infra-terraform/)

### Local Laptop Install
Install the following:
* [aws cli](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html).
* [eksctl](https://docs.aws.amazon.com/eks/latest/userguide/eksctl.html).
* [terraform](https://www.terraform.io/downloads).
* [helm](https://helm.sh/docs/intro/install/).
* [kubectl](https://kubernetes.io/docs/tasks/tools/).

### Create Terraform IAM user

* No console access. Record access key id/secret access key for later.

### Create Terraform Backend

* Create backend (S3 bucket and DynamoDB table) ONLY, with Terraform and local state.
* Copy state file to bucket, enable backend Terraform code and re-initialize.
* Deploy remaining Terraform.

### Terraform Authentication and Deploy

These Terraform commands can be found as various stages in an automation pipeline later.
* Export keys as environment variables (examples shown, NOT real keys!):
* ```` export AWS_ACCESS_KEY_ID=AKIAIOSFODNN7EXAMPLE ````
* ```` export AWS_SECRET_ACCESS_KEY=wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY ````
* Initialize: contains bucket name and key:
* ```` terraform init --backend-config=backend.conf ````
* Recommend planfile for local applying:
* ```` terraform plan --out=planfile ````
* ```` terraform apply planfile ````

### Grant Kubernetes Permissions To Other Users

* The below is not automated but could be if desired. Some companies treat their clusters as ephemeral/"cattle" and may prefer to include in a pipeline.
* EKS cluster by default grants "system:masters" permissions to cluster creator only.
* Perform identity-mapping in ConfigMap to grant to others (role or standard user or Federated user) similar/suitable permissions:
* ```` eksctl create iamidentitymapping --cluster cluster_eks --region=us-east-1 --arn <user/role arn> --group system:masters --no-duplicate-arns ```` (or a lesser cluster role).
* More info: [Enabling IAM user and role access to your cluster](https://docs.aws.amazon.com/eks/latest/userguide/add-user-role.html)


### Check New Rights via kubebctl

For same reasons as mentioned above, the below task could be automated in a pipeline if desired.
* Reset AWS environment variables to user with newly assigned rights.
* Update kubeconfig and switch context:
* ```` aws eks update-kubeconfig --region us-east-1 --name cluster_eks  ````
* ```` kubectl config use-context arn:aws:eks:us-east-1:<accountid>:cluster/cluster_eks ```` 
* ````kubectl get svc````

## Detailed Decision Log - Infrastructure

| Decision Point | Explanation |
| --- | ----------- |
| Terraform IAM User | AdministratorAccess policy chosen initially. Recommend this should be changed to the limit of what is required to limit blast radius. |
| Terraform partial backend config | Standard practice but is really most useful when switching environments. It only offers security by obscurity, even when hidden via .gitignore. |
| Terraform partial backend config in code | It is a matter of preference and argument whether to include the backend bucket and table as code or not. One advantage of doing this is it allows monitoring of backend configuration. Should anything break, drift should be detected. |
| EKS Terraform file structure | Unique to AWS is the three-layer resource concept of Kubernetes networking, cluster and nodes. I have chosen to keep these as three separate Terraform files for educational value. |
| Networking | I chose [AWS' recommended EKS network architecture](https://docs.aws.amazon.com/eks/latest/userguide/creating-a-vpc.html) "Public and private subnets", "public and private endpoint". This allows nodes to be deployed to private subnets and load balancers to public subnets. We need a public endpoint to receive traffic from the public internet (our domain name) and to administer the control plane (without VPN/Direct Connect). Even with the public endpoint, node to cluster traffic will leave our VPC but not AWS' network. The recommended architecture is a CloudFormation file which I studied/installed and then converted the resources into Terraform.|
| Security Groups | Accepted defaults. Strongly recommend research and modification as future improvement. |
| AmazonEKS_CNI_Policy policy attachment | Again for brevity, attached this to the node IAM role. Recommend as a future improvement: [configuring the Amazon VPC CNI plugin for Kubernetes to use IAM roles for service accounts](https://docs.aws.amazon.com/eks/latest/userguide/cni-iam-role.html). |
| Node SSH access | This is a simple switch and has been turned off. While this can make troubleshooting more difficult, in general [the concensus](https://www.reddit.com/r/kubernetes/comments/t3xun8/proscons_of_disabling_ssh_access/) is to set this as "None". Regardless, AWS System Manager is still available for this purpose.|
| system:masters assignment | I'm aware that this role should only be used as a stop-gap and not for long term use. Instead, choosing a lesser role. For brevity, I did not commit time to researching this and it will depend to a large extent anyway on the team and existing infrastructure of the organization. In general, as with anything AWS, I would recommend binding to an IAM role if at all possible (due to short-lived rights). Failing that, a federated user. [Enabling IAM user and role access to your cluster](https://docs.aws.amazon.com/eks/latest/userguide/add-user-role.html) |

## Setup Instructions/Log - Infrastructure Pipeline

* Again, repo is ["1.infra-terraform"](https://github.com/chrisbuckleycode/eks-infra/blob/main/1.infra-terraform/).
* Pipeline can be seen here: [NOT AVAILABLE]().

General reference instructions here: [Using GitLab CI/CD with a Kubernetes cluster](https://docs.gitlab.com/ee/user/clusters/agent/ci_cd_workflow.html).

### Configure for Terraform
Yaml file created for Terraform pipeline but using S3 as remote backend. General information here:
[Infrastructure as Code with Terraform and GitLab](https://docs.gitlab.com/ee/user/infrastructure/iac/).

* Terraform IAM user keys configured as environment variables.
* Standard Terraform pipeline stages: Validate, Plan, Apply, Destroy.
* Pipeline automatically triggers on push to "develop" (remember, as a development project we are not using "main" branch yet).
* Manual trigger for destroy (note: as the state file bucket is composed in Terraform, it will remain if this trigger is activated - therefore if infra is desired to be more "ephemeral", I suggest moving state file bucket and table out of Terraform, so as to be independent).

## Setup Instructions/Log - Application Pipeline

* Repo is ["2.app-helm"](https://github.com/chrisbuckleycode/eks-infra/blob/main/2.app-helm).
* Pipeline can be seen here: [NOT AVAILABLE]().

### Install GitLab Agent

* Register a GitLab Kubernetes agent and install it with Helm | [Documentation](https://docs.gitlab.com/ee/user/clusters/agent/install/) - defaults used for simplicity. This could be scripted as a future improvement.
* One advantage of this agent is it will automatically have rights to administer the cluster and there is no need for any application pipeline to include AWS credentials.
* Note: if the cluster is destroyed and re-created, this should be performed again.

### Configure for Helm

Note: Helm is a package manager for Kubernetes and is probably the most common way to deploy applications as even small applications often consist of a dozen or more manifests. Hence, our pipeline will use helm commands to deploy a common web-based application, Wordpress.

* We use an image "dtzar/helm-kubectl:latest" which is a popular image that comes ready with both heml and kubectl executables.
* The first commands are a dependecy for helm, to initialize kubectl on the agent's context.
* Next, commands are executed to install Helm charts for ["WordPress packaged by Bitnami"](https://artifacthub.io/packages/helm/bitnami/wordpress).

### Connect Load Balancer to Domain Name

* A LoadBalancer service can be found after install. Make a note of the url.
* In Route 53, find the domain name's hosted zone and create a new record.
* Choose a record name e.g. "wp", Record Type "A".
* Choose where to route your traffic to: "ELB/Classic", "region" and choose the url you took note of earlier.
* (Note: this will also work with a CNAME to the same url but you will have to paste the url if choosing this option).
* Now wait 60 seconds for DNS to propagate and open a browser window to the url.
* Note: you will see certificate warnings. However, as SSL hand-off is not specified in the requirements and involves extra complexity (at minimum obtaining certificate from a CA and preferred setting up the ExternalDNS plugin), I have elected not to implement it. If desired, here are instructions: [Associate an ACM SSL certificate with a Classic Load Balancer](https://aws.amazon.com/premiumsupport/knowledge-center/associate-acm-certificate-alb-nlb/) | [EKS - Set up ExternalDNS](https://aws.amazon.com/premiumsupport/knowledge-center/eks-set-up-externaldns/). Additionally, this will terminate SSL at the load-balancer, the easiest way to do it. However, some may prefer for security reasons to terminate at the pod level.

## Suggested Improvements

| Improvement | Remarks |
| ----------- | ----------- |
| Peer Review | Review entire work with peers. |
| Testing | Perform rigorous testing of infrastructure and application, including under load. |
| Security | At minimum: IAM scope of permissions, security groups, RBAC, image-hardening, secrets encryption and all others mentioned above. As mentioned earlier, better to consult a security professional and conduct an overall security assessment including benchmarking - a DevOps engineer can be security minded but should not make all security decisions - this should be delegated to a security professional.|
| Terraform code improvements | Re-factor, modularize, parameterize, formatting. |
| SSL at Load Balancer |  |
| Self-hosted/GitLab-hosted image registry, own images | Including CI, tests. |
| Self-hosted Helm charts/manifests | Allows for further deployments over and above initial. |
| Observability & Monitoring | AWS-native and third-party. |
| Automate more | Automate some/all of the few manual steps, if desired. |
| GitOps | "Pull" based deployment |

Frankly, there are too many improvements to name. You can always continuously improve your infrastructure and the Kubernetes ecosystem offers ample opportunities to do so (so long as you deduce it is worth the investment of time and/or money).

## Tear-Down Instructions

* Run the "destroy" stage of the Terraform pipeline. Alternatively run ````terraform destroy ```` from the command-line.
* Remove the A record in the domain name's hosted zone.
* Remove the leftover state file bucket manually.
* Ideally, delete the AWS account itself. AWS accounts should be treated as disposable.
* To delete only the application, run ````helm delete my-release````.
