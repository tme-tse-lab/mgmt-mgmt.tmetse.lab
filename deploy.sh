if [ ! $1 ]; then 
   echo "You must specify the FQDN of the cluster"
   echo "Example:"
   echo "     bash deploy.sh manage.lab.diktio.net"
   exit 1
else
  export MGMT=$1
fi

cd bp-mgmt/init-gitops-install
helm install -f ../../values/global/values.yaml -f ../../values/$MGMT/values.yaml gitops-install .
echo -n "Waiting for OpenShift GitOps to commence installation."
while ! `oc get crds| egrep argo -q`; do
sleep 3
echo -n "."
done
echo
echo -n "Waiting 60 seconds for all CRDs to apply."
for i in {1..60}; do
  echo -n "."
  sleep 1
done
echo
cd ../init-gitops-config/
helm install -f ../../values/global/values.yaml -f ../../values/$MGMT/values.yaml gitops-config . 
cd ../..
echo "Deploy kick-started!"
