---
name: kubernetes-master
description: Deploy and manage containerized applications on Kubernetes. Covers pods, deployments, services, Helm, operators, networking, security, and GitOps.
license: MIT
compatibility: opencode
metadata:
  audience: developers
  workflow: devops
  category: devops
---

# Kubernetes Master

## What I Do

I help deploy and manage containerized applications on Kubernetes. I ensure proper resource management, security, networking, and operational practices.

## Core Concepts

### Architecture
```
Control Plane:
├── API Server (kube-apiserver) — REST interface, authentication
├── etcd — Distributed key-value store (cluster state)
├── Scheduler (kube-scheduler) — Assigns pods to nodes
├── Controller Manager — Node, replication, endpoint controllers
└── Cloud Controller Manager — Cloud provider integration

Worker Node:
├── kubelet — Agent that manages pods
├── kube-proxy — Network proxy, service routing
├── Container Runtime — containerd, CRI-O
└── Pods — Smallest deployable unit
```

### Pod
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: web-app
  labels:
    app: web-app
    tier: frontend
spec:
  containers:
    - name: app
      image: myapp:1.2.3
      ports:
        - containerPort: 3000
      resources:
        requests:
          cpu: 100m
          memory: 128Mi
        limits:
          cpu: 500m
          memory: 256Mi
      livenessProbe:
        httpGet:
          path: /health
          port: 3000
        initialDelaySeconds: 10
        periodSeconds: 5
      readinessProbe:
        httpGet:
          path: /ready
          port: 3000
        initialDelaySeconds: 5
        periodSeconds: 3
      env:
        - name: DATABASE_URL
          valueFrom:
            secretKeyRef:
              name: app-secrets
              key: database-url
        - name: NODE_ENV
          valueFrom:
            configMapKeyRef:
              name: app-config
              key: node-env
      volumeMounts:
        - name: data
          mountPath: /data
  volumes:
    - name: data
      persistentVolumeClaim:
        claimName: app-data-pvc
```

### Deployment
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: web-app
spec:
  replicas: 3
  strategy:
    type: RollingUpdate
    rollingUpdate:
      maxSurge: 1
      maxUnavailable: 0  # Zero-downtime deployment
  selector:
    matchLabels:
      app: web-app
  template:
    metadata:
      labels:
        app: web-app
    spec:
      containers:
        - name: app
          image: myapp:1.2.3
          ports:
            - containerPort: 3000
```

### Service
```yaml
# ClusterIP — internal only (default)
apiVersion: v1
kind: Service
metadata:
  name: web-app
spec:
  type: ClusterIP
  selector:
    app: web-app
  ports:
    - port: 80
      targetPort: 3000
      protocol: TCP

# NodePort — accessible on node IP
# type: NodePort

# LoadBalancer — cloud provider LB
# type: LoadBalancer
```

## Configuration

### ConfigMap
```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: app-config
data:
  NODE_ENV: production
  LOG_LEVEL: info
  MAX_CONNECTIONS: "100"
  config.json: |
    {
      "featureFlags": {
        "newUI": true,
        "darkMode": false
      }
    }
```

### Secret
```yaml
apiVersion: v1
kind: Secret
metadata:
  name: app-secrets
type: Opaque
data:
  # Values must be base64 encoded
  database-url: cG9zdGdyZXNxbDovL3VzZXI6cGFzc0BkYjo1NDMyL2FwcA==
  api-key: c2VjcmV0LWtleS12YWx1ZQ==

# Best Practices:
# - Use external secret managers (Vault, AWS Secrets Manager)
# - Enable encryption at rest for etcd
# - Never commit secrets to git
# - Use sealed-secrets or external-secrets operator
```

## Networking

### Ingress
```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: app-ingress
  annotations:
    nginx.ingress.kubernetes.io/ssl-redirect: "true"
    nginx.ingress.kubernetes.io/rate-limit: "100"
    cert-manager.io/cluster-issuer: letsencrypt-prod
spec:
  tls:
    - hosts:
        - app.example.com
      secretName: app-tls
  rules:
    - host: app.example.com
      http:
        paths:
          - path: /
            pathType: Prefix
            backend:
              service:
                name: web-app
                port:
                  number: 80
          - path: /api
            pathType: Prefix
            backend:
              service:
                name: api-service
                port:
                  number: 8080
```

### Network Policies
```yaml
# Deny all ingress traffic by default
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: default-deny-ingress
spec:
  podSelector: {}
  policyTypes:
    - Ingress

# Allow specific traffic
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-api-to-db
spec:
  podSelector:
    matchLabels:
      app: database
  policyTypes:
    - Ingress
  ingress:
    - from:
        - podSelector:
            matchLabels:
              app: api-server
      ports:
        - protocol: TCP
          port: 5432
```

### DNS
```
Services get DNS names:
  <service>.<namespace>.svc.cluster.local

Examples:
  web-app.default.svc.cluster.local
  database.production.svc.cluster.local

Short form within same namespace:
  web-app
  database
```

## Storage

### PersistentVolume and Claim
```yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: app-data-pvc
spec:
  accessModes:
    - ReadWriteOnce  # Single node
    # ReadWriteMany  # Multiple nodes (NFS, EFS)
    # ReadOnlyMany   # Multiple nodes, read-only
  storageClassName: gp3  # AWS EBS
  resources:
    requests:
      storage: 10Gi

# Storage Classes:
# AWS: gp3, io2, st1
# GCP: standard, premium
# Azure: managed-premium, managed-standard
```

## Helm

### Chart Structure
```
my-chart/
├── Chart.yaml          # Chart metadata
├── values.yaml         # Default values
├── values-prod.yaml    # Production overrides
├── charts/             # Dependencies
└── templates/
    ├── deployment.yaml
    ├── service.yaml
    ├── ingress.yaml
    ├── configmap.yaml
    ├── secret.yaml
    └── _helpers.tpl    # Template helpers
```

### Template Example
```yaml
# templates/deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: {{ include "my-chart.fullname" . }}
  labels:
    {{- include "my-chart.labels" . | nindent 4 }}
spec:
  replicas: {{ .Values.replicaCount }}
  selector:
    matchLabels:
      {{- include "my-chart.selectorLabels" . | nindent 6 }}
  template:
    metadata:
      labels:
        {{- include "my-chart.selectorLabels" . | nindent 8 }}
    spec:
      containers:
        - name: {{ .Chart.Name }}
          image: "{{ .Values.image.repository }}:{{ .Values.image.tag }}"
          ports:
            - containerPort: {{ .Values.containerPort }}
          resources:
            {{- toYaml .Values.resources | nindent 12 }}
```

### Values
```yaml
# values.yaml
replicaCount: 3
image:
  repository: myapp
  tag: 1.2.3
  pullPolicy: IfNotPresent
containerPort: 3000
resources:
  requests:
    cpu: 100m
    memory: 128Mi
  limits:
    cpu: 500m
    memory: 256Mi
service:
  type: ClusterIP
  port: 80
```

### Commands
```bash
helm install my-release ./my-chart -f values-prod.yaml
helm upgrade my-release ./my-chart --set image.tag=1.2.4
helm rollback my-release 1  # Rollback to revision 1
helm list
helm history my-release
```

## Resource Management

### QoS Classes
```
Guaranteed:    requests == limits (highest priority, last to evict)
Burstable:     requests < limits (medium priority)
BestEffort:    no requests or limits (lowest priority, first to evict)

# Always set requests and limits!
```

### Horizontal Pod Autoscaler
```yaml
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: web-app-hpa
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: web-app
  minReplicas: 2
  maxReplicas: 10
  metrics:
    - type: Resource
      resource:
        name: cpu
        target:
          type: Utilization
          averageUtilization: 70
    - type: Resource
      resource:
        name: memory
        target:
          type: Utilization
          averageUtilization: 80
```

## Security

### RBAC
```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  namespace: production
  name: pod-reader
rules:
  - apiGroups: [""]
    resources: ["pods", "pods/log"]
    verbs: ["get", "list", "watch"]

---
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: read-pods
  namespace: production
subjects:
  - kind: User
    name: developer
    apiGroup: rbac.authorization.k8s.io
roleRef:
  kind: Role
  name: pod-reader
  apiGroup: rbac.authorization.k8s.io
```

### Pod Security
```yaml
apiVersion: v1
kind: Pod
spec:
  securityContext:
    runAsNonRoot: true
    runAsUser: 1000
    fsGroup: 2000
  containers:
    - name: app
      securityContext:
        allowPrivilegeEscalation: false
        readOnlyRootFilesystem: true
        capabilities:
          drop:
            - ALL
        seccompProfile:
          type: RuntimeDefault
```

## Troubleshooting

### Common Commands
```bash
# Check pod status
kubectl get pods -n <namespace>
kubectl describe pod <pod-name> -n <namespace>

# View logs
kubectl logs <pod-name> -n <namespace>
kubectl logs <pod-name> -n <namespace> --previous  # Previous container
kubectl logs -f <pod-name> -n <namespace>           # Follow

# Exec into pod
kubectl exec -it <pod-name> -n <namespace> -- /bin/sh

# Port forward
kubectl port-forward svc/<service-name> 8080:80 -n <namespace>

# Check events
kubectl get events -n <namespace> --sort-by='.lastTimestamp'

# Check resource usage
kubectl top pods -n <namespace>
kubectl top nodes

# Debug ephemeral container
kubectl debug -it <pod-name> --image=busybox -n <namespace> --target=<container-name>
```

### Common Issues
```
CrashLoopBackOff:
  - Check logs: kubectl logs <pod>
  - Check liveness probe configuration
  - Verify application starts correctly

ImagePullBackOff:
  - Check image name and tag
  - Verify imagePullSecrets for private registries
  - Check network connectivity to registry

Pending:
  - Check node resources: kubectl describe nodes
  - Check PVC binding: kubectl get pvc
  - Check node selectors/tolerations

OOMKilled:
  - Increase memory limits
  - Check for memory leaks
  - Review application memory usage
```

## GitOps

### ArgoCD
```yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: web-app
  namespace: argocd
spec:
  project: default
  source:
    repoURL: https://github.com/org/k8s-manifests.git
    targetRevision: main
    path: apps/web-app
  destination:
    server: https://kubernetes.default.svc
    namespace: production
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
    syncOptions:
      - CreateNamespace=true
```

## When to Use Me

Use this skill when:
- Writing Kubernetes manifests
- Setting up Helm charts
- Configuring ingress and networking
- Implementing RBAC and pod security
- Setting up autoscaling
- Troubleshooting pod issues
- Implementing GitOps with ArgoCD
- Managing storage and volumes

## Quality Checklist

- [ ] Resource requests and limits set on all containers
- [ ] Liveness and readiness probes configured
- [ ] Security context: run as non-root, drop capabilities
- [ ] Secrets not committed to git
- [ ] Network policies restrict pod-to-pod traffic
- [ ] HPA configured for production workloads
- [ ] Rolling update strategy with zero downtime
- [ ] Pod disruption budgets for critical services
- [ ] Labels and selectors consistent
- [ ] Namespace isolation for environments
