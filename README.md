# Starting point

[![build-ublue](https://github.com/CharlieQLe/startingpoint/actions/workflows/build.yml/badge.svg)](https://github.com/CharlieQLe/startingpoint/actions/workflows/build.yml)

This is a constantly updating template repository for creating [a native container image](https://fedoraproject.org/wiki/Changes/OstreeNativeContainerStable) designed to be customized however you want. GitHub will build your image for you, and then host it for you on [ghcr.io](https://github.com/features/packages). You then just tell your computer to boot off of that image. GitHub keeps 90 days worth image backups for you, thanks Microsoft!

For more info, check out the [uBlue homepage](https://universal-blue.org/) and the [main uBlue repo](https://github.com/ublue-os/main/)

## Getting started

See the [Make Your Own-page in the documentation](https://universal-blue.org/tinker/make-your-own/) for quick setup instructions for setting up your own repository based on this template.

Don't worry, it only requires some basic knowledge about using the terminal and git.

After setup, it is recommended you update this README to describe your custom image.

> **Note**
> Everywhere in this repository, make sure to replace `ublue-os/startingpoint` with the details of your own repository. Unless you used one of the automatic repository setup tools in which case the previous repo identifier should already be your repo's details.

> **Warning**
> To start, you *must* create a branch called `live` which is exclusively for your customizations. That is the **only** branch the GitHub workflow will deploy to your container registry. Don't make any changes to the original "template" branch. It should remain untouched. By using this branch structure, you ensure a clear separation between your own "published image" branch, your development branches, and the original upstream "template" branch. Periodically sync and fast-forward the upstream "template" branch to the most recent revision. Then, simply rebase your `live` branch onto the updated template to effortlessly incorporate the latest improvements into your own repository, without the need for any messy, manual "merge commits".

## Customization

The easiest way to start customizing is by looking at and modifying `config/recipe.yml`. It's documented using comments and should be pretty easy to understand.

If you want to add custom configuration files, you can just add them in the `/usr/etc/` directory, which is the official OSTree "configuration template" directory and will be applied to `/etc/` on boot. `config/files/usr` is copied into your image's `/usr` by default. If you need to add other directories in the root of your image, that can be done using the `files` module. Writing to `/var/` in the image builds of OSTree-based distros isn't supported and will not work, as that is a local user-managed directory!

For more information about customization, see [the README in the config directory](config/README.md)

> **Note**
> The configuration files you put in `/usr/etc/` will automatically be applied to your local `/etc/` by `systemd` whenever you rebase an OSTree system or update the image. If a config file in `/etc/` has been *modified* (compared to the same deployment's defaults), then OSTree [won't overwrite it](https://github.com/ostreedev/ostree/blob/16cb47489e582da9c139fee20acdac7079867843/docs/atomic-upgrades.md?plain=1#L76), but the new version will be available in `/usr/etc/`. Run `sudo ostree admin config-diff` to see the difference between `/etc/` and `/usr/etc/` (`man ostree-admin-config-diff` for further documentation).

### Custom build scripts

If you want to execute custom shell scripts or commands in the image build, you shouldn't edit the `scripts/build.sh` or the `Containerfile` directly.

Instead, you should create your own custom shell scripts in the `scripts/` directory (look at the `example.sh`). After creating your scripts, enable them in the `scripts:` section of your `recipe.yml`, within the specific "build stage" category where the scripts are intended to be executed. Alternatively, enable the `autorun.sh` helper script in your recipe to automatically execute your custom scripts.

Read [the README in the `scripts/` directory](https://github.com/CharlieQLe/startingpoint/blob/main/scripts/README.md) for more information.

### Custom package repositories

If you want to add custom package repositories to your image, you can include them in the `recipe.yml` as a list of URLs under the `rpm.repos:` section. They **must** be proper `.repo` files (such as `https://copr.fedorainfracloud.org/coprs/atim/starship/repo/fedora-38/atim-starship-fedora-38.repo`). In the build process, the `.repo` file will be downloaded and placed inside `/etc/yum.repos.d/` where rpm-ostree can access it.

You can use this to add [COPR repositories](https://copr.fedorainfracloud.org/) to your image.
COPR is like the Arch User Repository for Fedora, where you can find extra packages that wouldn't otherwise be available. The repositories are community-created, so use them at your own risk. [Read more](https://docs.pagure.org/copr.copr/user_documentation.html)

Tip: You can use the magic string `%FEDORA_VERSION%` in your repo URLs, to automatically refer to the correct repository for your current Fedora version.

If your `.repo` file is not available as a hosted URL and you need to copy it manually, you can upload the file in your github repository or a gist and add the raw link to the file under `rpm.repos:`. Another option in this scenario would be to create a folder for `.repo` files in your repository and add `COPY repos /etc/yum.repos.d/` in the `Containerfile`.

### Building multiple images

You can build multiple images using multiple `recipe.yml` files. They will share the Containerfile and everything else, but things like packages declared in the recipe will be different between the images. For a more robust multibuild setup, you could consider forking from the [ublue-os/main](https://github.com/ublue-os/main/) repo, which was built from the purpose.

In order to build multiple recipes, you need to declare each one below line ~33 in `build.yml`. The files should be in the root of the repository.

Example: Adding a new recipe called `recipe-2.yml` (snippets from the `matrix` section of `build.yml`)

Before:

```yml
matrix:
  recipe:
    - recipe.yml
```

After:

```yml
matrix:
  recipe:
    - recipe.yml
    - recipe-2.yml
```

### [yafti](https://github.com/ublue-os/yafti/)

`yafti` is the uBlue "first boot" installer. It shows up the first time a user logs into uBlue. By default, the menu also shows up again anytime the image's yafti configuration differs from the user's last encounter, so feel free to expand or modify your custom image's yafti configuration over time. Your users will then see the yafti menu again after the OS update, and will be given a chance to install any new additions.

Its configuration can be found in `/usr/share/ublue-os/firstboot/yafti.yml` of the installed OS. It includes an optional selection of Flatpaks to install, along with a new group that's automatically added for all Flatpaks declared in `recipe.yml`. You can look at what's done in the `yafti.yml` config and modify it to your liking (in the repository, before building the image, since the installed system file is immutable).

If you want to completely disable yafti, simply set the recipe's `firstboot.yafti` flag to `false`, which then removes all yafti-related files and configurations from your final image. The files in `usr/share/ublue-os/firstboot/` are responsible for automatically running yafti at login, and they will *only* be bundled in your image if `yafti` is enabled in your recipe!

## Installation

> **Warning**
> [This is an experimental feature](https://www.fedoraproject.org/wiki/Changes/OstreeNativeContainerStable) and should not be used in production, try it in a VM for a while!

To rebase an existing Silverblue/Kinoite installation to the latest build:

- First rebase to the unsigned image, to get the proper signing keys and policies installed:
  ```
  rpm-ostree rebase ostree-unverified-registry:ghcr.io/charlieqle/startingpoint:latest
  ```
- Reboot to complete the rebase:
  ```
  systemctl reboot
  ```
- Then rebase to the signed image, like so:
  ```
  rpm-ostree rebase ostree-image-signed:docker://ghcr.io/charlieqle/startingpoint:latest
  ```
- Reboot again to complete the installation
  ```
  systemctl reboot
  ```

This repository builds date tags as well, so if you want to rebase to a particular day's build:

```
rpm-ostree rebase ostree-image-signed:docker://ghcr.io/charlieqle/startingpoint:20230403
```

This repository by default also supports signing.

The `latest` tag will automatically point to the latest build. That build will still always use the Fedora version specified in `recipe.yml`, so you won't get accidentally updated to the next major version.

## ISO

This template includes a simple Github Action to build and release an ISO of your image. 

To run the action, simply edit the `boot_menu.yml` by changing all the references to startingpoint to your repository. This should trigger the action automatically.

The Action uses [isogenerator](https://github.com/ublue-os/isogenerator) and works in a similar manner to the official Universal Blue ISO. If you have any issues, you should first check [the documentation page on installation](https://universal-blue.org/installation/). The ISO is a netinstaller and should always pull the latest version of your image.

Note that this release-iso action is not a replacement for a full-blown release automation like [release-please](https://github.com/googleapis/release-please).

## `just`

The [`just`](https://just.systems/) command runner is included in all `ublue-os/main`-derived images.

You need to have a `~/.justfile` with the following contents and `just` aliased to `just --unstable` (default in posix-compatible shells on ublue) to get started with just locally.
```
!include /usr/share/ublue-os/just/main.just
!include /usr/share/ublue-os/just/nvidia.just
!include /usr/share/ublue-os/just/custom.just
```
Then type `just` to list the just recipes available.

The file `/usr/share/ublue-os/just/custom.just` is intended for the custom just commands (recipes) you wish to include in your image. By default, it includes the justfiles from [`ublue-os/bling`](https://github.com/ublue-os/bling), if you wish to disable that, you need to just remove the line that includes bling.just.

See [the just-page in the Universal Blue documentation](https://universal-blue.org/guide/just/) for more information.
