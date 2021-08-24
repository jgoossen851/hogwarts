# Hogwarts: The installation wizard creator

A simple application to generate an installation wizard for your program from a JSON configuration file.

## Generating the installation wizard

Currently, the repository contains a sample installation wizard. A future version will contain the code to generate a wizard for a custom program.

## Using the installation wizard

1. Generate the binary executable using your project's build chain. For this sample project, run the following command:

   ```bash
   g++ sample-program.cpp
   ```

2. Run the Installation Wizard, `installer_linux.sh`. A Windows installer has not yet been developed.
3. Close programs and logout if necessary to complete the installation.

