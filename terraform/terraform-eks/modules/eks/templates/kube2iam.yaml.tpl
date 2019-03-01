---
# ------------------- Kube2iam ServiceAccount ------------------- #
apiVersion: v1
kind: ServiceAccount
metadata:
  name: kube2iam
  namespace: kube-system
---
# ------------------- Kube2iam ClusterRole ------------------- #
apiVersion: v1
items:
  - apiVersion: rbac.authorization.k8s.io/v1
    kind: ClusterRole
    metadata:
      name: kube2iam
    rules:
      - apiGroups: [""]
        resources: ["namespaces","pods"]
        verbs: ["get","watch","list"]
  - apiVersion: rbac.authorization.k8s.io/v1
    kind: ClusterRoleBinding
    metadata:
      name: kube2iam
    subjects:
    - kind: ServiceAccount
      name: kube2iam
      namespace: kube-system
    roleRef:
      kind: ClusterRole
      name: kube2iam
      apiGroup: rbac.authorization.k8s.io
kind: List

---
# ------------------- Kube2iam Daemonset ------------------- #
apiVersion: extensions/v1beta1
kind: DaemonSet
metadata:
  name: kube2iam
  namespace: kube-system
  labels:
    app: kube2iam
spec:
  updateStrategy:
    type: RollingUpdate
  template:
    metadata:
      labels:
        name: kube2iam
    spec:
      serviceAccountName: kube2iam
      hostNetwork: true
      containers:
        - image: jtblin/kube2iam:${kube2iam_version}
          imagePullPolicy: Always
          name: kube2iam
          args:
            - "--app-port=8181"
            - "--base-role-arn=arn:aws:iam::${account_id}:role/"
            - "--iptables=true"
            - "--host-ip=$(HOST_IP)"
            - "--host-interface=eni+"
            - "--verbose"
            - "--debug"
          env:
            - name: HOST_IP
              valueFrom:
                fieldRef:
                  fieldPath: status.podIP
          ports:
            - containerPort: 8181
              hostPort: 8181
              name: http
          securityContext:
            privileged: true