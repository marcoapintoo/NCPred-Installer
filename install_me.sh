#!/bin/bash

function install_packages(){
	apt-get -y install $@ > /dev/null 2> /dev/null
}

function install_zenity(){
	zenity -h > /dev/null 2> /dev/null
	if [ $? -ne 0 ]; then 
		install_packages zenity
	fi
}

function check_sudo(){
	if [ "$EUID" -ne 0 ]
		then echo "Please run as root"
		exit
	fi
}

function install_java(){
	java -version > /dev/null 2> /dev/null
	if [ $? -ne 0 ]; then 
		add-apt-repository -y ppa:webupd8team/java > /dev/null 2> /dev/null
		apt-get -y update > /dev/null 2> /dev/null
		install_packages oracle-java7-installer
	fi
}

function install_additional_libraries(){
	install_packages infernal blast2 ncbi-blast+ ncbi-rrna-data wget bioperl bioperl-run python-biopython-sql libbiojava-java libperl-dev
	install_packages libbz2-dev:i386
}

function install_perl_utilities(){
	cpan Algorithm::Numerical::Shuffle
	cpan Statistics::Basic::StdDev
}


function install_ct_energy(){
	cp -f ct-energy /usr/bin/ct-energy
	chmod a+x /usr/bin/ct-energy
}

function install_other_tools(){
	#ln -Fs $( readlink -f  ./NCPred/blastn) /usr/bin
	ln -Fs $( readlink -f  ./NCPred/Conv.exe) /usr/bin
	ln -Fs $( readlink -f  ./NCPred/Extract_PP.exe) /usr/bin
	ln -Fs $( readlink -f  ./NCPred/randfold) /usr/bin
	ln -Fs $( readlink -f  ./NCPred/RNAspectral.exe) /usr/bin
	ln -Fs $( readlink -f  ./NCPred/RNAtopological.exe) /usr/bin
	ln -Fs $( readlink -f  ./NCPred/runmodel.exe) /usr/bin
	ln -Fs $( readlink -f  ./NCPred/selfcontain.py) /usr/bin
	ln -Fs $( readlink -f  ./NCPred/framefinder) /usr/bin
	ln -Fs $( readlink -f  ./NCPred/hybrid-ss-min) /usr/bin
}

function install_vienna_rna(){
	#wget -c --no-check-certificate --content-disposition "https://www.tbi.univie.ac.at/RNA/download/package=viennarna-src-tbi&flavor=sourcecode&dist=2_2_x&arch=src&version=2.2.4"
	curl -L -o "ViennaRNA-2.2.4.tar.gz" -C - -k -J "https://www.tbi.univie.ac.at/RNA/download/package=viennarna-src-tbi&flavor=sourcecode&dist=2_2_x&arch=src&version=2.2.4"
	tar -zxvf ViennaRNA-2.2.4.tar.gz
	if [ $? -ne 0 ]; then 
		echo "100" #"Error installing ViennaRNA package"
		zenity --error --text "Error installing ViennaRNA package. Finishing now!"
		exit -1
	fi
	chown -hRf $USER2 ViennaRNA-2.2.4/
	make
	make install
}

function install_ncpred(){
	#wget -c --no-check-certificate --content-disposition "https://dl.dropboxusercontent.com/u/11067180/NCPred.tar.gz"
	curl -L -o "NCPred.tar.gz" -C - -k -J "https://dl.dropboxusercontent.com/u/11067180/NCPred.tar.gz"
	tar -zxvf NCPred.tar.gz
	if [ $? -ne 0 ]; then 
		echo "100" #"Error installing NCPred package"
		zenity --error --text "Error installing NCPred package. Finishing now!"
		exit -2
	fi
	chown -hRf $USER2 NCPred/
	make
	make install
}

function install_additiona_files(){
	cp additional_files/* ./NCPred
}

function install_all(){
	check_sudo;
	(
		echo "0" ; 
		echo "# Installing Java" ;
		install_java;
		echo "10" ;
		echo "# Installing libraries" ;
		install_additional_libraries;
		echo "20" ;
		echo "# Installing Perl utilities" ;
		install_perl_utilities > /dev/null 2> /dev/null;
		echo "30" ;
		echo "# Installing ViennaRNA" ;
		install_vienna_rna > /dev/null 2> /dev/null;
		echo "70" ;
		echo "# Installing NCPred package" ;
		install_ncpred > /dev/null 2> /dev/null;
		echo "99" ;
		echo "# Installing ct-energy" ;
		install_ct_energy > /dev/null 2> /dev/null;
		install_other_tools > /dev/null 2> /dev/null;
		install_additiona_files > /dev/null 2> /dev/null;
		zenity --info --text="Installion finished. Good luck $USER2!"
		echo "100" ;
	) | zenity --progress --width=600 --height=300 \
	  --title="Installing NCPred complete package" \
	  --text="Starting process..." \
	  --auto-close --percentage=0
}


USER2=$1
if [ "$EUID" -ne 0 ]; then
	gksu -m "Installing NCPred..." "bash $0 $USER"
	exit
fi
install_all;








