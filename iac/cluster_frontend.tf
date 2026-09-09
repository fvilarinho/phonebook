locals {
  phonebook_frontend_settings_filename        = abspath(pathexpand("../etc/nginx.conf"))
  phonebook_frontend_credentials_filename     = abspath(pathexpand("../etc/.htpasswd"))
  phonebook_frontend_certificate_filename     = abspath(pathexpand("../etc/tls/certs/fullchain.pem"))
  phonebook_frontend_certificate_key_filename = abspath(pathexpand("../etc/tls/private/privkey.pem"))
}

locals {
  phonebook_cluster_frontend_settings_manifest_filename = "frontend-settings.yaml"
  phonebook_cluster_frontend_manifest_filename          = "frontend.yaml"
}

locals {
  phonebook_cluster_frontend_settings_manifest = <<EOT
apiVersion: v1
kind: ConfigMap
metadata:
  name: frontend-settings
  namespace: ${local.build.name}
data:
  default.conf.template: |
      ${indent(6, chomp(file(local.phonebook_frontend_settings_filename)))}
  .htpasswd: |
      ${indent(6, chomp(file(local.phonebook_frontend_credentials_filename)))}
  fullchain.pem: |
      ${indent(6, chomp(file(local.phonebook_frontend_certificate_filename)))}
  privkey.pem: |
      ${indent(6, chomp(file(local.phonebook_frontend_certificate_key_filename)))}
EOT

  phonebook_cluster_frontend_manifest = <<EOT
apiVersion: apps/v1
kind: DaemonSet
metadata:
  name: frontend
  namespace: ${local.build.name}
spec:
  selector:
    matchLabels:
      app: frontend
  template:
    metadata:
      labels:
        app: frontend
    spec:
      containers:
        - name: frontend
          imagePullPolicy: Always
          image: nginx:1.29.3
          env:
            - name: FRONTEND_HOST
              value: ${local.secrets.frontend.host}
            - name: FRONTEND_DOMAIN
              value: ${local.secrets.frontend.domain}
            - name: BACKEND_HOST
              value: backend.${local.build.name}.svc.cluster.local
          volumeMounts:
            - name: frontend-settings
              mountPath: /etc/nginx/templates/default.conf.template
              subPath: default.conf.template
            - name: frontend-settings
              mountPath: /etc/nginx/conf.d/.htpasswd
              subPath: .htpasswd
            - name: frontend-settings
              mountPath: /etc/tls/certs/fullchain.pem
              subPath: fullchain.pem
            - name: frontend-settings
              mountPath: /etc/tls/private/privkey.pem
              subPath: privkey.pem
          ports:
            - name: http
              containerPort: 80
              protocol: TCP
            - name: https
              containerPort: 443
              protocol: TCP
      volumes:
        - name: frontend-settings
          configMap:
            name: frontend-settings
---
apiVersion: v1
kind: Service
metadata:
  name: frontend
  namespace: ${local.build.name}
spec:
  type: ClusterIP
  selector:
    app: frontend
  ports:
    - name: http
      port: 80
      targetPort: 80
      protocol: TCP
    - name: https
      port: 443
      targetPort: 443
      protocol: TCP
---
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: ingress
  namespace: ${local.build.name}
spec:
  ingressClassName: traefik
  rules:
    - host: ${local.secrets.frontend.host}.${local.secrets.frontend.domain}
      http:
        paths:
          - path: /
            pathType: Prefix
            backend:
              service:
                name: frontend
                port:
                  name: http
EOT
}