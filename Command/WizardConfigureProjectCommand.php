<?php

namespace App\Command;

use Symfony\Component\Console\Attribute\AsCommand;
use Symfony\Component\Console\Command\Command;
use Symfony\Component\Console\Input\InputInterface;
use Symfony\Component\Console\Output\OutputInterface;
use Symfony\Component\Console\Style\SymfonyStyle;
use Symfony\Component\Process\Exception\ProcessFailedException;
use Symfony\Component\Process\Process;

#[AsCommand(name: 'configure:project')]
class WizardConfigureProjectCommand extends Command
{
    private SymfonyStyle $io;

    protected function configure(): void
    {
        $this
            ->setDescription('Provides all you need in your new project.')
        ;
    }

    protected function execute(InputInterface $input, OutputInterface $output): int
    {
        ini_set('max_execution_time', '0');

        $this->io = new SymfonyStyle($input, $output);
        $this->io->title("Welcome to the Symfony Wizard Tool 🧙");
        $this->io->writeln("We will now configure your project.");

        $this->database();
        $this->api();
        $this->users();

        $this->io->success('Your Symfony app was successfully configured. Open https://localhost in your favorite web browser to access it.');
        $this->io->info('You can now delete the Makefile and the README.md file and rename the symfony-wizard folder with your project name.');

        return Command::SUCCESS;
    }

    private function database(): void
    {
        $this->io->section("📚 Database");

        $withDatabase = $this->io->ask("Do you need a database ? (y/n)", "y", function (string $answer): string {
            if (!in_array(strtolower($answer), ['y', 'n'])) {
                throw new \RuntimeException('You must answer with y or n.');
            }

            return strtolower($answer);
        });

        if ('n' === $withDatabase) {
            return;
        }

        $process = new Process(['composer', 'require', 'symfony/orm-pack', '--no-scripts']);
        $process->run(function ($type, $buffer): void {
            $this->io->writeln($buffer);
        });

        if (!$process->isSuccessful()) {
            throw new ProcessFailedException($process);
        }

        $this->io->block($process->getOutput());

        $process = new Process(['composer', 'require', '--dev', 'symfony/maker-bundle', '--no-scripts']);
        $process->run(function ($type, $buffer): void {
            $this->io->writeln($buffer);
        });

        if (!$process->isSuccessful()) {
            throw new ProcessFailedException($process);
        }

        $this->io->success('Doctrine successfully installed !');
    }

    private function api(): void
    {
        $this->io->section("🔎 API");

        $withApi = $this->io->ask("Do you need APIs ? (y/n)", "y", function (string $answer): string {
            if (!in_array(strtolower($answer), ['y', 'n'])) {
                throw new \RuntimeException('You must answer with y or n.');
            }

            return strtolower($answer);
        });

        if ('n' === $withApi) {
            return;
        }

        $process = new Process(['composer', 'require', 'api', '--no-scripts']);
        $process->run(function ($type, $buffer): void {
            $this->io->writeln($buffer);
        });

        if (!$process->isSuccessful()) {
            throw new ProcessFailedException($process);
        }

        $this->io->block($process->getOutput());
        $this->io->success('ApiPlatform successfully installed !');
    }

    private function users(): void
    {
        $this->io->section("👤 Users");

        $withUsers = $this->io->ask("Do you need Users ? (y/n)", "y", function (string $answer): string {
            if (!in_array(strtolower($answer), ['y', 'n'])) {
                throw new \RuntimeException('You must answer with y or n.');
            }

            return strtolower($answer);
        });

        if ('n' === $withUsers) {
            return;
        }

        $process = new Process(['bin/console', 'make:user']);
        $process->setTty(true);
        $process->run();

        if (!$process->isSuccessful()) {
            throw new ProcessFailedException($process);
        }

        $process = new Process(['bin/console', 'make:migration']);
        $process->run(function ($type, $buffer): void {
            $this->io->writeln($buffer);
        });

        if (!$process->isSuccessful()) {
            throw new ProcessFailedException($process);
        }

        $this->io->block($process->getOutput());
        $this->io->success('User entity successfully created !');
    }
}