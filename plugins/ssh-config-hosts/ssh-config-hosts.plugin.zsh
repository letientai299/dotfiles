# ssh-config-hosts: let `ssh <TAB>` complete Host aliases from ~/.ssh/config
# (and its Includes), not just known_hosts.
#
# Why this is needed: zsh's _ssh_hosts does parse config aliases and follows
# Include, but only *after* `_combination ... hosts && return`, which completes
# from known_hosts first. On an empty/ambiguous prefix known_hosts always match,
# so it returns before the alias-parsing code runs and aliases never show.
#
# Fix: merge the config aliases into the `hosts` zstyle that _hosts consults.
# Setting that zstyle makes _hosts use *only* it (skipping known_hosts), so we
# feed the union of both. Runs once per shell; reopen a shell to pick up new
# aliases (e.g. after a colossus lease rotates config.colossus).
() {
  emulate -L zsh
  setopt localoptions extendedglob

  local -a config_hosts lines
  lines=("${(@f)$(<$HOME/.ssh/config)}") 2>/dev/null || return
  local idx=1 line key rest h tok
  while (( idx <= $#lines )); do
    line=${lines[idx]}; key=${line%%[[:space:]=]*}
    rest=${line#$key}; rest=${rest##[[:space:]=]##}
    case ${key:l} in
      include)                        # splice included file(s) in place
        local -a inc=()
        for tok in ${(z)rest}; do
          inc+=("${(@f)$(cd $HOME/.ssh 2>/dev/null && cat ${~tok} 2>/dev/null)}")
        done
        lines[idx]=("${inc[@]}"); (( ${#inc} )) || (( ++idx )) ;;
      host|hostname)                  # skip wildcard patterns
        for h in ${(z)rest}; do [[ $h == *[*?]* ]] || config_hosts+=$h; done
        (( ++idx )) ;;
      *) (( ++idx )) ;;
    esac
  done

  local -aU kh names; local f n
  for f in /etc/ssh/ssh_known_hosts ~/.ssh/known_hosts; do
    [[ -r $f ]] || continue
    names=(${${(f)"$(<$f)"}%%[ |$'\t']*})
    for n in ${(s:,:)${(j:,:)names}}; do
      [[ $n == (\|*|*[*?]*) ]] && continue            # skip hashed / wildcard
      [[ $n == (#b)\[(*)\]:[0-9]##* ]] && n=$match[1]  # unwrap [host]:port
      kh+=$n
    done
  done

  local -aU all=($config_hosts $kh)
  (( $#all )) && zstyle ':completion:*:hosts' hosts $all
}
