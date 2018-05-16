# Azure and Cloudvision integration demo

## Usage

1. Install [terraform](https://www.terraform.io/intro/getting-started/install.html)
2. Build CVP plugin for terraform

```bash
chmod +x ./build.sh; ./build.sh
```

3. Initialise terraform

```bash
terraform init
```

4. Setup terraform Azure and CVP providers

```bash
cat provider.tf.example
```

5. Adjust input variables

```bash
cat terraform.tfvars
cat secret.tfvars.example
```

6. Review changes to be applied

```bash
terraform plan -var-file="secrets.tfvars"
```

7. Apply terraform configuration

```bash
terraform apply -var-file="secrets.tfvars"
```

Answer 'yes' when prompted

8. Manage vEOS lifecycle from CVP

  * CVP should have new vEOS device and a new IPsec configlet created after the last step
  * Create a reconcile configlet by right-clicking the device -> Manage -> Configlet -> Validate -> Reconcile
  * After reconcile configlet has been created, assign and apploy the new IPsec configlet to the device
  * New local/remote subnets can be created by updating IPsec configlet

9. Destroy terraform configuration

```bash
terraform destroy -var-file="secrets.tfvars"
```

Answer 'yes' when prompted

## Data model

```bash
terraform graph | dot -Tsvg > graph.svg
```

<img src="graph.svg">