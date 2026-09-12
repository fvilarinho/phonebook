locals {
  backend_observability_settings_filename = abspath(pathexpand("../etc/logback.xml"))
}

locals {
  cluster_backend_settings_manifest_filename = "backend-settings.yaml"
  cluster_backend_manifest_filename          = "backend.yaml"
}

locals {
  cluster_backend_settings_manifest = <<-EOT
apiVersion: v1
kind: ConfigMap
metadata:
  name: backend-settings
  namespace: ${local.build.name}
data:
  DEBUG_ENABLED: "${local.secrets.backend.debug.enabled}"
  OBSERVABILITY_ENABLED: "${local.secrets.backend.observability.enabled}"
  OBSERVABILITY_LOGS_URL: "${local.secrets.backend.observability.logs.url}"
  logback.xml: |
      ${indent(6, chomp(file(local.backend_observability_settings_filename)))}
EOT

  cluster_backend_manifest = <<-EOT
apiVersion: v1
kind: ServiceAccount
metadata:
  name: backend
  namespace: ${local.build.name}
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: backend-role
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: cluster-admin
subjects:
  - kind: ServiceAccount
    name: backend
    namespace: ${local.build.name}
---
apiVersion: apps/v1
kind: DaemonSet
metadata:
  name: backend
  namespace: ${local.build.name}
spec:
  selector:
    matchLabels:
      app: backend
  template:
    metadata:
      labels:
        app: backend
    spec:
      serviceAccountName: backend
      containers:
        - name: backend
          imagePullPolicy: Always
          image: ${local.secrets.docker.registry.url}/${local.secrets.docker.registry.id}/${local.build.name}:${local.build.version}
          env:
            - name: DEBUG_ENABLED
              valueFrom:
                configMapKeyRef:
                  name: backend-settings
                  key: DEBUG_ENABLED
            - name: OBSERVABILITY_ENABLED
              valueFrom:
                configMapKeyRef:
                  name: backend-settings
                  key: OBSERVABILITY_ENABLED
            - name: DB_HOST
              valueFrom:
                configMapKeyRef:
                  name: database-settings
                  key: DB_HOST
            - name: DB_NAME
              valueFrom:
                configMapKeyRef:
                  name: database-settings
                  key: DB_NAME
            - name: DB_USER
              valueFrom:
                secretKeyRef:
                  name: database-credentials
                  key: DB_USER
            - name: DB_PASSWORD
              valueFrom:
                secretKeyRef:
                  name: database-credentials
                  key: DB_PASSWORD
          volumeMounts:
            - name: backend-settings
              mountPath: /home/${local.build.name}/etc/logback.xml
              subPath: logback.xml
          ports:
            - name: http
              containerPort: 8080
              protocol: TCP
      volumes:
        - name: backend-settings
          configMap:
            name: backend-settings
---
apiVersion: v1
kind: Service
metadata:
  name: backend
  namespace: ${local.build.name}
spec:
  type: ClusterIP
  selector:
    app: backend
  ports:
    - name: http
      port: 8080
      targetPort: 8080
      protocol: TCP
EOT
}
