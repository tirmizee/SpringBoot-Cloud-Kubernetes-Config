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