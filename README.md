# Azure and Cloudvision integration with Terraform

## Prerequisites

1. Install [terraform](https://www.terraform.io/intro/getting-started/install.html)

2. Setup Azure and CVP access credentials

Follow the instructions in the file

```bash
cat provider.tf.example
```

3. Setup Password and keys

Follow the instructions in the file

```bash
cat secrets.tfvars.examples
```


## (Optional) IPsec headend setup

For a full demo, IPsec headend can be setup beforehand

```bash
cd ./headend
chmod +x ./buildme.sh; ./buildme.sh
```

Note that since tunnel destination is not known at this stage, this will need to be updated once the peer has been setup

## Usage


1. Build CVP plugin for terraform

```bash
chmod +x ./build.sh; ./build.sh
```

2. Initialise terraform

```bash
terraform init
```

3. Review input variables and change if needed

Variables definition and descriptions:

```bash
cat variables.tf
```

Variables values:

```bash 
cat terraform.tfvars 
```

4. Apply terraform configuration

```bash
terraform apply -var-file="secrets.tfvars"
```

Answer 'yes' when prompted

5. Manage vEOS lifecycle from CVP

  * CVP should have the new vEOS device and IPsec configlet created after the last step
  * Create a reconcile configlet by right-clicking the device -> Manage -> Configlet -> Validate -> Reconcile
  * After reconcile configlet has been created, assign and apply the new IPsec configlet to the device
  * Future updates, e.g. new local/remote subnets, can be done by updating IPsec configlet on CVP

## Cleanup 

```bash
terraform destroy -var-file="secrets.tfvars"
```

Answer 'yes' when prompted

## Data model

```bash
terraform graph | dot -Tsvg > graph.svg
```

<img src="graph.svg">