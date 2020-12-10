# DeepFactor Orb
[![CircleCI Build Status](https://circleci.com/gh/deepfactor-io/deepfactor-orb.svg?style=shield "CircleCI Build Status")](https://circleci.com/gh/deepfactor-io/deepfactor-orb) [![CircleCI Orb Version](https://img.shields.io/badge/endpoint.svg?url=https://badges.circleci.io/orb/deepfactor/deepfactor-orb)](https://circleci.com/orbs/registry/orb/deepfactor/deepfactor-orb) [![GitHub License](https://img.shields.io/badge/license-MIT-lightgrey.svg)](https://raw.githubusercontent.com/deepfactor-io/deepfactor-orb/master/LICENSE) [![CircleCI Community](https://img.shields.io/badge/community-CircleCI%20Discuss-343434.svg)](https://discuss.circleci.com/c/ecosystem/orbs)

[![DeepFactor](https://static.deepfactor.io/logo.png)](https://deepfactor.io)

A CircleCI Orb for adding DeepFactor’s 'Continuous Observability for DevSecOps' into your CI/CD pipeline to identify runtime security, privacy, and compliance risks in your application without changing a single line of code.
To use this orb you simply need a running instance of the DeepFactor portal. Register [here](https://my.deepfactor.io/register) and get started today.


## Usage Examples
### Scan Application

```yaml
version: 2.1

orbs:
  deepfactor: deepfactor/deepfactor-orb@1.0.0

workflows:
  scan-workflow:
    jobs:
      - deepfactor/scan:
          portal-url: deepfactor.mycompany.org
          app-name: sample-app
          component-name: demo-express 
          pre-run: steps-to-run-before-test
          cmd: command-to-run-tests
          post-run: steps-to-run-after-test 
```

## Get DeepFactor
1. Sign up for [DeepFactor.io](htts://deepfactor.io) community edition
2. Install DeepFactor portal using the following the instructions [here](https://docs.deepfactor.io/hc/en-us/categories/360004380213-Getting-Started)
3. Within Circle CI, build your app & scan your code/build artifacts/containers for static visibility
4. Test: turn on your automated tests
5. Observe: Use this orb to run your app with DeepFactor for runtime visibility

