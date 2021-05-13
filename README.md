# My Dotfiles

## How to use

```sh
# Replace <PROFILE> with the dotfiles profile this system should use.
git clone --no-checkout https://github.com/lixquid/dotfiles $HOME/.dotfiles
git --git-dir=$HOME/.dotfiles/.git --work-tree=$HOME checkout <PROFILE>
```

While you could just clone this directly into your `$HOME`, a lot of tooling
will then treat your entire home directory as being under version control.

Instead, we clone to a subdirectory, then specifically reference it from the
home directory to checkout a profile. After this point, the `dotfiles` alias
should automatically resolve the right git directory for you.

```sh
dotfiles add <changed_dotfile>
dotfiles commit -m "Change the dotfile"
dotfiles push
```
