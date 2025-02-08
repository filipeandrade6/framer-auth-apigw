# pedeai-lambda

Repository to provision AWS Lambda function, API Gateway and Cognito onto an existing subnet/vpc using Terraform.

### How to use

#### Github Actions

- Configure the repository secrets.
- PR to main branch or go to actions and manually run **Provision AWS Lambda function, API GW and Cognito** Github Action.

#### Locally

With *terraform*, *Go* and *aws CLI* installed.

Build the program:

- `cd ./lambda && GOARCH=amd64 GOOS=linux go build -o ../bootstrap main.go`
- `zip deployment.zip bootstrap`

Configure aws credentials:

- edit `~/.aws/credentials` file

To create Lambda Function:

- `terraform init` to initialize
- `terraform plan` to plan deploy
- `terraform apply` to create resources

To destroy:

- `terraform destroy` to destroy resources
