wget http://download.nus.edu.sg/mirror/ctan/systems/texlive/Source/install-tl-unx.tar.gz
tar -xzf install-tl-unx.tar.gz
cd install-tl-*
sudo ./install-tl -profile=../texlive.profile
printf "\nexport PATH=/usr/local/texlive/2016/bin/x86_64-linux:\$PATH" >> ~/.bashrc
cd ..
rm -r install-tl-*
