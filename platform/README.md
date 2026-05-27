# Platform Prerequisites

Application overlays depend on AWS Load Balancer Controller Gateway API support
and External Secrets Operator.

## Gateway API and ALB Controller

AWS Load Balancer Controller must be version 2.14.0 or newer for ALB-backed
`HTTPRoute` support. Install the required CRDs before applying the application:

```bash
kubectl apply --server-side=true -f https://github.com/kubernetes-sigs/gateway-api/releases/download/v1.5.0/standard-install.yaml
kubectl apply -f https://raw.githubusercontent.com/kubernetes-sigs/aws-load-balancer-controller/refs/heads/main/config/crd/gateway/gateway-crds.yaml
```

Install the controller using the IRSA role output from Terraform and
`aws-load-balancer-controller/values.example.yaml`, then apply the shared class:

```bash
kubectl apply -k platform/gateway-api
```

The application creates an internet-facing ALB through `Gateway`,
`LoadBalancerConfiguration`, `TargetGroupConfiguration`, and `HTTPRoute`.
Targets use VPC CNI pod IPs and the health check path
`/actuator/health/readiness`.

## External Secrets Operator

Install ESO with the `external-secrets-sa` service account and the
`eso_role_arn` Terraform output, using `external-secrets/values.example.yaml`.
The shared store uses the ESO controller IRSA identity to read AWS Secrets
Manager:

```bash
kubectl apply -k platform/external-secrets
```

The dev overlay reads the RDS-managed master credential secret created by
Terraform (`manage_master_user_password = true`):

```text
arn:aws:secretsmanager:ap-northeast-2:495599735720:secret:rds!db-3af6352b-e7f0-4fdc-9c52-4910b0dd815c-lMb7qs
```

It maps the JSON properties `username` and `password` into the generated
Kubernetes Secret. Configure `SPRING_DATASOURCE_URL` in the dev ConfigMap
after confirming the RDS endpoint. The production overlay must receive its
own production RDS Secret ARN and endpoint before deployment.

## Render and Verify

```bash
kubectl kustomize apps/resource-ops/overlays/dev
kubectl apply -k apps/resource-ops/overlays/dev
kubectl -n resource-ops-dev get deploy,pod,service,externalsecret,gateway,httproute
kubectl -n resource-ops-dev get gateway resource-app-gateway -o jsonpath='{.status.addresses[0].value}'
```
