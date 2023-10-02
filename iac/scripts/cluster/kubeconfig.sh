mkdir -p /home/ubuntu/.kube
sudo cp -i /home/ubuntu/scripts/config /home/ubuntu/.kube/config
sudo chown $(id -u):$(id -g) /home/ubuntu/.kube/config