# Hogwarts: The installation wizard creator

A simple application to generate an installation wizard for your program from a JSON configuration file.

## Generating the installation wizard

Currently, the repository contains a sample installation wizard. A future version will contain the code to generate a wizard for a custom program.

## Using the installation wizard

1. Generate the binary executable using your project's build chain. For this sample project, run the following commands:

   ```bash
   cd src
   make
   ```

2. Run the Installation Wizard, `installer_linux.sh`. A Windows installer has not yet been developed.
3. Close programs and logout if necessary to complete the installation.

## Notes

File extensions, *inter alia*, are used to determine the Multipurpose Internet Mail Extension (MIME) type of a file. The installer saves the icons for any associated file MIME types in the default `hicolor` theme. See Freedesktop's article on [Directory Layout](https://specifications.freedesktop.org/icon-theme-spec/latest/ar01s03.html). If using a different theme, the displayed icon will prefer a more general icon from the same theme than a more specific icon from an inherited theme in order to preserve a consistent style. See [Icon Naming Guidelines](https://specifications.freedesktop.org/icon-naming-spec/latest/ar01s03.html). Therefore, if using the `text` MIME type, and if an icon theme defines an icon to display for generic text icons, then a custom icon will not appear for a specialized `text` MIME type unless that MIME type icon is specifically installed in the icon theme being used.

However, this rule does not apply to the `application` MIME type, as a specialized icon should be preferred for binary data over a themed icon. **To set an icon for a file with a MIME type to be processed by the installed application, prefer the `application` MIME type rather than other MIME types such as `text`.**  Even if the file is human-readable text, if it is in a format specifically tailored to your application, use the `application` MIME type.