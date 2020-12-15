# DeepFactor Orb

[![DeepFactor](https://static.deepfactor.io/logo.png)](https://deepfactor.io)

A CircleCI Orb for adding DeepFactor’s 'Continuous Observability for DevSecOps' into your CI/CD pipeline to identify runtime security, privacy, and compliance risks in your application without changing a single line of code.
To use this orb you simply need a running instance of the DeepFactor portal. Register [here](https://my.deepfactor.io/register) and get started today.

## About DeepFactor
DeepFactor is the first Continuous Observability platform in the industry. Developers can find and triage runtime Security, Privacy, and Compliance risks within the DevOps pipeline, with zero code; the application security team can set guardrails, receive alerts, and have continuous visibility with every build.

DeepFactor delivers four (4) groups of powerful insights:

1. Code Execution Risks
Risks in process, memory, filesystem, and network behaviors determined by observing system and library calls

2. AppSec Policy Alerts
Deviations from expected application behaviors based on policies defined by the AppSec team

3. OWASP Scan Results
Results of One-Click OWASP ZAP scans, built into DeepFactor

4. Usage-Based Vulnerable Dependencies
Dependency vulnerabilities prioritized based on actual usage

With actionable evidence, DeepFactor allows you to instantly pinpoint root cause and remediate runtime risks earlier in dev, before shipping to production. You can also compare the behaviors of one version of an app against another to highlight any unexpected changes.

#### DeepFactor: Continuous Observability for DevSecOps. Go from Runtime Blind™ to Runtime Ready™.


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
