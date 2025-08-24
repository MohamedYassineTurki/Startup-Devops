This folder will contain CI/CD pipeline templates and examples. Current plan:

Use GitLab CI as the primary pipeline engine (or GitHub Actions/ArgoCD for GitOps flows).

Pipelines:

build stage: build Docker image, run unit tests.

push stage: push image to ECR.

deploy stage: apply manifest or update Helm release (to dev namespace automatically; qa/prod via manual approvals).

Future work: i will add pipeline templates per environment that use the dedicated ServiceAccount tokens for namespace-scoped access.