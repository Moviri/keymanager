cd test

vagrant up

vagrant keymanager
vagrant keymanager

echo "[server1] SSH keys:"
vagrant ssh server1 -c 'cat ~/.ssh/authorized_keys'
echo "[server2] SSH keys:"
vagrant ssh server2 -c 'cat ~/.ssh/authorized_keys'

vagrant destroy -f

cd ..
