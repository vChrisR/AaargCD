#!/bin/bash

name=$1
repo=$2
folder=$3

tmpfile=$(mktemp)
cat <<EOF >$tmpfile
---
apiVersion: batch/v1
kind: CronJob
metadata:
  name: $name
spec:
  schedule: "*/5 * * * *"
  successfulJobsHistoryLimit: 4
  failedJobsHistoryLimit: 4
  jobTemplate:
    spec:
      template:
        spec:
          containers:
          - name: cd
            image: bitnami/kubectl
            imagePullPolicy: IfNotPresent
            command:
            - /bin/sh
            - -c
            - cd /tmp;git clone $repo repo; cd repo/$folder; kubectl apply -f .            
          restartPolicy: Never
---
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: aaargcd
subjects:
- kind: ServiceAccount
  name: default
roleRef:
  kind: ClusterRole
  name: admin
  apiGroup: rbac.authorization.k8s.io
EOF

kubectl apply -f $tmpfile
rm -f $tmpfile