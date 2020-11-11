# AWS CLI Orb [![CircleCI status](https://circleci.com/gh/CircleCI-Public/aws-cli-orb.svg "CircleCI status")](https://circleci.com/gh/CircleCI-Public/aws-cli-orb) [![CircleCI Orb Version](https://img.shields.io/badge/endpoint.svg?url=https://badges.circleci.io/orb/circleci/aws-cli)](https://circleci.com/orbs/registry/orb/circleci/aws-cli) [![GitHub license](https://img.shields.io/badge/license-MIT-blue.svg)](https://raw.githubusercontent.com/CircleCI-Public/aws-cli-orb/master/LICENSE) [![CircleCI Community](https://img.shields.io/badge/community-CircleCI%20Discuss-343434.svg)](https://discuss.circleci.com/c/ecosystem/orbs)

Easily install and configure the AWS CLI in your CircleCI jobs.

## Usage

See [this orb's listing in CircleCI's Orbs Registry](https://circleci.com/orbs/registry/orb/circleci/aws-cli) for details on usage, or see below example:

## Example

In this example `config.yml` snippet, the required AWS secrets (Access Key ID, Secret Access Key) are stored, via [Contexts](https://circleci.com/docs/2.0/contexts), as environment variables in the `aws` context and then read as default parameter values by the `aws-cli/setup` command.

```yaml
version: 2.1

orbs:
  aws-cli: circleci/aws-cli@x.y

jobs:
  aws-cli-example:
    executor: aws-cli/default
    steps:
      - checkout
      - aws-cli/setup:
          profile-name: example
      - run: echo "Run your code here"

workflows:
  version: 2
  aws-cli:
    jobs:
      - aws-cli-example:
          context: aws
```

## Example with `role-arn`
To let aws-cli assume a given role, you need 2 profiles:
- eg. `[default]` with static credentials (see above)
- eg. `[role]` with `role_arn` and `source_profile` configured

Please note that you have to specify the profile to use on each `aws` command with `--profile role`.
Alternatively you can configure the `default` profile to ue a `role-arn` and a second profile to have the static credentials.

```yaml
version: 2.1

orbs:
  aws-cli: circleci/aws-cli@x.y

jobs:
  aws-cli-example:
    executor: aws-cli/default
    steps:
      - checkout
      - aws-cli/setup  # set up the `default` profile with static credentials
      - aws-cli/setup: # set up the profile with to be assumed role
          profile-name: role
          source-profile: default
          role-arn: "arn:aws:iam::0123456789:role/circleci"
      - run:
          name: "Run your code here"
          command: aws --profile role s3 ls s3://your-bucket-here


workflows:
  version: 2
  aws-cli:
    jobs:
      - aws-cli-example:
          context: aws
```