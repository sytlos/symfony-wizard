install: check-install check-requirements symfony-docker git configure-project

check-requirements: check-git check-docker check-docker-compose

check-install:
	@if test -f "composer.json";\
	then\
        echo "Your project is already installed.";\
        exit 1;\
    fi;

symfony-docker:
	@git clone https://github.com/dunglas/symfony-docker.git;\
	mv symfony-docker/* .;\
	rm -fr symfony-docker;\
	docker-compose build --pull --no-cache;\
	docker-compose down;\
	docker-compose up -d;\
	sudo chmod -R 777 .;\
	docker-compose -f docker-compose.yml -f docker-compose.override.yml exec php mkdir src/Command;\
	docker-compose -f docker-compose.yml -f docker-compose.override.yml exec php mv Command/* src/Command;\
	docker-compose -f docker-compose.yml -f docker-compose.override.yml exec php rmdir Command;\
	docker-compose -f docker-compose.yml -f docker-compose.override.yml exec php composer require symfony/process;

git:
	@read -p "What is your Git repository url ? " repositoryurl;\
	rm -fr .git;\
	git config --global --add safe.directory '*';\
	git init;\
	git remote add origin $$repositoryurl;\
	cat .gitignore.wizard >> .gitignore;\
	rm .gitignore.wizard;

configure-project:
	@docker-compose -f docker-compose.yml -f docker-compose.override.yml exec php bin/console configure:project
	docker-compose -f docker-compose.yml -f docker-compose.override.yml exec php bin/console cache:clear

check-git:
	@if [ $(shell git --version > /dev/null; echo $$?) -ne 0 ];\
	then\
		echo "\033[1;41mGit is not installed on this computer. Please run make install-git command.\033[0m";\
		exit 1;\
	else\
		echo "Git is installed.";\
		git --version; \
	fi;

check-docker:
	@if [ $(shell docker --version > /dev/null; echo $$?) -ne 0 ];\
	then\
		echo "\033[1;41mDocker is not installed on this computer. Please run make install-docker command.\033[0m";\
		exit 1;\
	else\
		echo "Docker is installed.";\
		docker --version; \
	fi;

check-docker-compose:
	@if [ $(shell docker-compose --version > /dev/null; echo $$?) -ne 0 ];\
	then\
		echo "\033[1;41mdocker-compose is not installed on this computer. Please run make install-docker-compose command.\033[0m";\
		exit 1;\
	else\
		echo "docker-compose is installed.";\
		docker-compose --version; \
	fi;

install-git:
	@sudo apt install -y git-all

install-docker:
	@sudo apt install -y docker

install-docker-compose:
	@sudo apt install -y docker-compose