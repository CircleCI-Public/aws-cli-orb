# AWS CLI Orb [![CircleCI status](https://circleci.com/gh/CircleCI-Public/aws-cli-orb.svg?style=shield "CircleCI status")](https://circleci.com/gh/CircleCI-Public/aws-cli-orb) [![CircleCI Orb Version](https://badges.circleci.com/orbs/circleci/slack.svg)](https://circleci.com/developer/orbs/orb/circleci/aws-cli) [![GitHub license](https://img.shields.io/badge/license-MIT-blue.svg)](https://raw.githubusercontent.com/CircleCI-Public/aws-cli-orb/master/LICENSE) [![CircleCI Community](https://img.shields.io/badge/community-CircleCI%20Discuss-343434.svg)](https://discuss.circleci.com/c/ecosystem/orbs)

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
