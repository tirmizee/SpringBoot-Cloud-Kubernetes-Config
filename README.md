### kubernetes properties

- spring.cloud.kubernetes.enabled เปิดใช้งานการตั้งค่าย่อยทั้งหมด
- spring.cloud.kubernetes.config.enabled เปิดใช้งานการดึง configmap


### bootstrap-kubernetes.properties

```properties

# OVERRIDE BOOTSTRAP BY PROFILE ACTIVE
spring.cloud.kubernetes.config.enabled=true
spring.cloud.kubernetes.config.sources[0].name=app-kube-config
spring.cloud.kubernetes.config.sources[0].namespace=default
spring.cloud.kubernetes.reload.enabled=true
spring.cloud.kubernetes.reload.strategy=restart_context
spring.cloud.kubernetes.reload.monitoring-config-maps=true
spring.cloud.kubernetes.reload.mode=event

```

### configmap.yaml

```yaml

apiVersion: v1
kind: ConfigMap
metadata:
  name: app-kube-config
data:
  application-kubernetes.yaml: |-
    spring:
      cloud.config.enabled: false
      application:
        name: dev

```

### deployment.yaml

```yaml

apiVersion: apps/v1
kind: Deployment
metadata:
  name: app-kube
spec:
  selector:
    matchLabels:
      app: app-kube
  replicas: 1
  template:
    metadata:
      labels:
        app: app-kube
    spec:
      containers:
        - name: app-kube
          image: tirmizee/app-kube:0.1
          imagePullPolicy: Always
          ports:
            - containerPort: 8080
          env:
            - name: SPRING_PROFILES_ACTIVE
              value: "kubernetes"
          securityContext:
            privileged: false
      serviceAccountName: spring-boot

```

### rbac.yaml

```yaml

apiVersion: v1
kind: ServiceAccount
metadata:
  name: spring-boot
  namespace: default
---
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: spring-boot-view
rules:
  - apiGroups: [""]
    resources: ["pods","configmaps", "services"]
    verbs: ["get", "watch", "list"]
---
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: spring-boot-view
roleRef:
  kind: Role
  apiGroup: rbac.authorization.k8s.io
  name: spring-boot-view
subjects:
  - kind: ServiceAccount
    name: spring-boot

```

### DummyConfig.java

```java

@Configuration(proxyBeanMethods = false)
@ConfigurationProperties(prefix = "spring.application")
public class DummyConfig {

    private String name;

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

}

```

### Dockerfile

```yaml

FROM adoptopenjdk/openjdk11:alpine-jre

WORKDIR /app

ADD target/*.jar app.jar

ENTRYPOINT exec java -jar /app/app.jar


```

### Makefile

```makefile

redeploy: pack-jar build-img push-img delete-po create-po get-po

pack-jar:
	./mvnw clean package -DskipTests

build-img:
	docker build -t tirmizee/app-kube:0.1 .

push-img:
	docker push tirmizee/app-kube:0.1

delete-po:
	kubectl delete -f .k8s/deployment.yaml

create-po:
	kubectl apply -f .k8s/deployment.yaml

get-po:
	kubectl get po

create-cm:
	kubectl apply -f .k8s/configmap.yaml

```

### Demo

    makefile redeploy