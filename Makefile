install: check-install check-requirements create-project git configure-project end

check-requirements: check-git check-php check-composer

check-install:
	@if test -f "composer.json";\
	then\
        echo "Your project is already installed.";\
        exit 1;\
    fi;

create-project:
	@composer create-project symfony/skeleton ./project; \
	composer require symfony/process; \
	mv project/* .
	mv project/.env .
	mv project/.gitignore .
	mv Command src
	rmdir project

git:
	@read -p "What is your Git repository url ? " repositoryurl;\
	rm -fr .git;\
	git init;\
	git remote add origin $$repositoryurl;\
	cat .gitignore.wizard >> .gitignore
	rm .gitignore.wizard

configure-project:
	@bin/console configure:project
	bin/console cache:clear

end:
	@echo "Your project is successfully installed. You can now delete the Makefile and the README.md file and rename the symfony-wizard folder with your project name."

check-git:
	@if [ $(shell git --version > /dev/null; echo $$?) -ne 0 ];\
	then\
		echo "\033[1;41mGit is not installed on this computer. Please run make install-git command.\033[0m";\
		exit 1;\
	else\
		echo "Git is installed.";\
		git --version; \
	fi;

check-php:
	@if [ $(shell php --version > /dev/null; echo $$?) -ne 0 ];\
	then\
		echo "\033[1;41mPHP is not installed on this computer. Please run make install-php command.\033[0m";\
		exit 1;\
	else\
		echo "PHP is installed.";\
		php --version; \
  	fi;

check-composer:
	@if [ $(shell composer --version > /dev/null; echo $$?) -ne 0 ];\
	then\
		echo "\033[1;41mComposer is not installed on this computer. Please run make install-composer command.\033[0m";\
		exit 1;\
	else\
		echo "Composer is installed.";\
		composer --version; \
  	fi;

install-git:
	@sudo apt install git-all

install-php:
	@sudo apt install software-properties-common ca-certificates lsb-release apt-transport-https;\
	LC_ALL=C.UTF-8 sudo add-apt-repository ppa:ondrej/php; \
	sudo apt update; \
	sudo apt install php8.2; \
	sudo apt install php8.2-xml

install-composer:
	@php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"; \
    php -r "if (hash_file('sha384', 'composer-setup.php') === 'e21205b207c3ff031906575712edab6f13eb0b361f2085f1f1237b7126d785e826a450292b6cfd1d64d92e6563bbde02') { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;"; \
    php composer-setup.php; \
    php -r "unlink('composer-setup.php');"; \
    sudo mv composer.phar /usr/local/bin/composer