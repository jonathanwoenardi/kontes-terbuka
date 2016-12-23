wget http://mirror.ctan.org/systems/texlive/tlnet/install-tl-unx.tar.gz
tar -xzf install-tl-unx.tar.gz
cd install-tl-*
sudo ./install-tl -profile=../scripts/texlive.profile
export PATH="/usr/local/texlive/2016/bin/x86_64-linux:$PATH"
printf "\nexport PATH=/usr/local/texlive/2016/bin/x86_64-linux:\$PATH" >> ~/.bashrc
cd ..
rm -r install-tl-*
