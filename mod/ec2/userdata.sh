#!/bin/bash
yum install git* wget nginx* -y
git clone https://github.com/PullaPantangi/colour_picker.git
cd colour_picker
cp *  /usr/share/nginx/html/
systemctl start nginx
systemctl enable nginx
