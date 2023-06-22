# Create NFS directories
sudo mkdir -p /srv/nfs/k8s
sudo chown nobody:nogroup /srv/nfs/k8s
sudo chmod 777 /srv/nfs/k8s


kubectl create namespace jenkins-ns

kubectl apply -f /home/vagrant/Jenkins_with_TF/jenkins-pv.yaml -n jenkins-ns
kubectl apply -f /home/vagrant/Jenkins_with_TF/jenkins-pvc.yaml -n jenkins-ns
kubectl apply -f /home/vagrant/Jenkins_with_TF/jenkins-deployment.yaml -n jenkins-ns
kubectl apply -f /home/vagrant/Jenkins_with_TF/jenkins-service.yaml -n jenkins-ns

# Define the animation
animation="-\|/"

while true; do
  for ns in $(kubectl get namespaces -o=jsonpath='{range .items[*]}{.metadata.name}{"\n"}{end}'); do
    for pod in $(kubectl get pods -n $ns -o=jsonpath='{range .items[*]}{.metadata.name}{"\n"}{end}'); do
      total=$(kubectl get pod $pod -n $ns -o=jsonpath='{range .spec.containers[*]}{.name}{"\n"}{end}' | wc -l)
      running=$(kubectl get pod $pod -n $ns -o=jsonpath='{range .status.containerStatuses[*]}{.state.running}{end}' | grep -c true)
      if [[ $total -ne $running ]]; then
        for i in $(seq 0 3); do
          echo -ne "\r[${animation:$i:1}]"
          sleep 0.1
          done
        echo -e "\033[33m---\033[0m"
        echo -e "\033[33mWaiting for all containers to be running in pod $pod in namespace $ns \033[0m"
        sleep 1
      fi
    done
  done
  echo -e "\e[32mAll pods are ready!\e[0m"
  break
done

sleep 30

echo -e "!!!Use below to access Jenkins!!!"
kubectl get po -A -o wide
kubectl get no -A -o wide
kubectl get service -A
POD_NAME=$(kubectl get pods -n jenkins-ns -l app=jenkins -o jsonpath='{.items[0].metadata.name}')

while [ -z "$POD_NAME" ]
do
    echo -ne "\rWaiting for Jenkins pod name... /"
    sleep 0.2
    echo -ne "\rWaiting for Jenkins pod name... -"
    sleep 0.2
    echo -ne "\rWaiting for Jenkins pod name... \\"
    sleep 0.2
    echo -ne "\rWaiting for Jenkins pod name... |"
    sleep 0.2
    POD_NAME=$(kubectl get pods -n jenkins-ns -l app=jenkins -o jsonpath='{.items[0].metadata.name}')
done
sleep 5
echo "Jenkins pod name: $POD_NAME"
kubectl exec $POD_NAME -c jenkins -n jenkins-ns -- cat /var/jenkins_home/secrets/initialAdminPassword

echo -e "********How to access Jenkins*********"
echo -e "1. Check on which node jenkins pod is running"
echo -e "2. Access it with http://nodeip:30000"
echo -e "3. Use 'kubectl exec <jenkins-pod-name> -c jenkins -n jenkins-ns -- cat /var/jenkins_home/secrets/initialAdminPassword' to get jenkins admin creds"
