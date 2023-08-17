# Dotfiles

My dotfiles, managed with help of
[dotbot](https://github.com/anishathalye/dotbot), strongly inspired by this
post: [Managing your dotfiles](https://github.com/anishathalye/dotbot)

**DON'T USE THIS**

Note to self:

- If `nvim` having problem with `TERM` inside `tmux`, might need to install
  `tmux-256color` term info: https://gist.github.com/bbqtd/a4ac060d6f6b9ea6fe3aabe735aa9d95

## Using Neovide as external editor in Jetbrains IDE

Config external tools:

- Program: `$DOTFILES/tools/nv.sh`
- Args: `$FilePath$ $LineNumber$ $ColumnNumber$`
- Working dir: `$ProjectFileDir$`
