# A Cloud Guru - The Serverless Framework with GraphQL

Code for the [acloud.guru](https://acloud.guru) GraphQL and Serverless course, translated to use [Terraform](https://www.terraform.io) instead of [Serverless](https://serverless.com).

## Setup

- Get [Docker](https://www.docker.com/get-docker)
- Add your credentials in `./.terraform_env` (or just export them in your shell):
```
export AWS_ACCESS_KEY_ID=MY_KEY_ID
export AWS_SECRET_ACCESS_KEY=MY_SECRET
export AWS_REGION=us-east-1
```
- Run `bin/deploy`

---

Note: There may be some hardcoded settings in `deploy/main.tf` related to domain names and SSL certs. If you want to deploy this in your own account, fork this repo and change the settings to suit your needs.
