# AWS CLI Orb

Easily install and configure the AWS CLI in your CircleCI jobs.

## Usage

See [this orb's listing in CircleCI's Orbs Registry](https://circleci.com/orbs/registry/orb/circleci/aws-cli) for details on usage, or see below example:

## Example

In this example `config.yml` snippet, the required AWS secrets (Access Key ID, Secret Access Key) are stored, via [Contexts](https://circleci.com/docs/2.0/contexts), as environment variables in the `aws` context and then read as default parameter values by the `aws-cli/configure` command.

```yaml
version: 2.1

orbs:
  aws-cli: circleci/aws-cli@0.1.1

jobs:
  aws-cli:
    executor: aws-cli/default
    steps:
      - checkout
      - aws-cli/install
      - aws-cli/configure:
          profile-name: example

workflows:
  version: 2
  aws-cli:
    jobs:
      - aws-cli:
          context: aws
```