# MacBook setup

## 1. Install Homebrew

```sh
xcode-select --install
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
eval "$(/opt/homebrew/bin/brew shellenv)"
```

## 2. Clone the dotfiles and run the Brewfile

```sh
git clone https://github.com/sdebruijn/.dotfiles.git ~/.dotfiles
brew bundle --file ~/.dotfiles/Brewfile
brew bundle check --file ~/.dotfiles/Brewfile
```

`brew bundle check` lists anything that failed to install.

Then link the configs. Stow the four config packages by name. `make all` would also stow the zsh plugin folders and put their files in your home directory.

```sh
cd ~/.dotfiles
stow git nvim tmux zsh
```

## 3. Make PHP 8.4 the default

`composer` depends on Homebrew's `php` formula, which is 8.5. Point `php` at 8.4, the version on the Linux laptop and the one `shipment-api` needs (`^8.4.18`):

```sh
brew unlink php && brew link --force php@8.4
php -v
```

If `php -v` shows 8.5 after a `brew upgrade`, rerun the command.

The repos run PHP inside Docker, and the containers have `ext-imagick`, so the Mac's PHP doesn't need it. If you want it on the host anyway, Homebrew's PHP comes with `pecl`:

```sh
brew install imagemagick pkgconf
pecl install imagick
```

Homebrew's PHP keeps pecl extensions outside its install folder, so they survive `brew upgrade php@8.4`.

## 4. Install global packages

Composer. Put the `composer.json` you copied in the directory that `composer config --global home` prints, then:

```sh
composer global install
```

That brings back `laravel/installer`, `php_codesniffer`, `php-cs-fixer`, `phpstan` and `pint`.


