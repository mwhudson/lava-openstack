# Just some stuff to make later steps easier to read.

sudo apt-get install -y python-openstackclient python-virtualenv
sudo cp utils/* /usr/local/bin
sudo virtualenv /usr/local/venv
sudo /usr/local/venv/bin/pip install shyaml
sudo ln -s /usr/local/venv/bin/shyaml /usr/local/bin
