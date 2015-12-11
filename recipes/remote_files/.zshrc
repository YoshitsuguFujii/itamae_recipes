# 補完の有効化
autoload -U compinit && compinit

# キーバインドをemacs風にする(CTRL+aと)
bindkey -e

# 大文字小文字を区別しない
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'

#zsh補完候補一覧をカラー表示する方法
export LSCOLORS=exfxcxdxbxegedabagacad
export LS_COLORS='di=34:ln=35:so=32:pi=33:ex=31:bd=46;34:cd=43;34:su=41;30:sg=46;30:tw=42;30:ow=43;30'
zstyle ':completion:*' list-colors 'di=34' 'ln=35' 'so=32' 'ex=31' 'bd=46;34' 'cd=43;34'

#cdを打たずにディレクトリの移動を可能とする
setopt auto_cd

#cd -で<tab>を打つと今まで、移動したディレクトリを数値付きで表示してくれる
setopt auto_pushd

#入力したコマンド名が間違っている場合には修正
setopt correct

#補完候補を詰めて表示する設定
setopt list_packed

#補完候補表示時などにピッピとビープ音をならないように設定
setopt nolistbeep

#aliasでも補完できるようにする
setopt complete_aliases

# 履歴 -> http://qiita.com/items/c1a1567b2b76051f50c4
# 履歴ファイルの保存先
export HISTFILE=${HOME}/.zsh_history
# メモリに保存される履歴の件数
export HISTSIZE=1000
# 履歴ファイルに保存される履歴の件数
export SAVEHIST=100000
# 重複を記録しない
setopt hist_ignore_dups
# 開始と終了を記録
setopt EXTENDED_HISTORY
# ヒストリに追加されるコマンド行が古いものと同じなら古いものを削除
setopt hist_ignore_all_dups
# スペースで始まるコマンド行はヒストリリストから削除
setopt hist_ignore_space
# ヒストリを呼び出してから実行する間に一旦編集可能
setopt hist_verify
# 余分な空白は詰めて記録
setopt hist_reduce_blanks
# 古いコマンドと同じものは無視
setopt hist_save_no_dups
# historyコマンドは履歴に登録しない
setopt hist_no_store
# 補完時にヒストリを自動的に展開
setopt hist_expand
# 履歴をインクリメンタルに追加
setopt inc_append_history
# インクリメンタルからの検索
bindkey "^R" history-incremental-search-backward
bindkey "^S" history-incremental-search-forward

#========================
# zsh-syntax-highlighting
#========================
if [ -f ~/.zsh_plugin/zsh-syntax-highlighting/zsh-syntax-highlighting.plugin.zsh ]; then
  source ~/.zsh_plugin/zsh-syntax-highlighting/zsh-syntax-highlighting.plugin.zsh
fi

# zshの補完にも同じ色を設定 -> http://qiita.com/items/84fa4e051c3325098be3
if [ -n "$LS_COLORS" ]; then
  zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}
fi

# direnv設定
# some more ls aliases
alias up='cd ..'
alias upp='cd ../..'
alias uppp='cd ../../..'
alias ll='ls -alF'
alias lsd='ls -Gal | grep ^d' #Only list directories, including hidden ones
alias g='git'
alias gs='git status'
alias gst='git status -sb'
alias gd='git diff -w'
alias gdd='git diff -w --word-diff'
alias ga='git add'
alias gr='git rm'
alias gc='git checkout'
alias gb='git branch'
alias zsh_reload="exec $SHELL -l"
alias s='ssh $(grep -iE "host[[:space:]]+[^*]" ~/.ssh/config|peco|awk "{print \$2}")'
alias be="bundle exec"
alias gem-std="vim ~/Desktop/\[20150209\]GEM\ Standard/gem_standard.rb"
alias v="vagrant"

alias netlisteners='lsof -i -P | grep LISTEN'
case ${OSTYPE} in
  darwin*)
    #ここにMac向けの設定
    ;;
  linux*)
    #ここにLinux向けの設定
    alias listening='netstat -alnp | grep -i list | grep -i tcp | sort'
    ;;
esac

# プロジェクト個別設定

# cdコマンドで自動実行
function chpwd() {
  ls -lAh -color
  #ls_abbrev
  touch ~/dir0.txt && rm ~/dir0.txt && echo $PWD > ~/dir0.txt
}


# chpwd内のlsでファイル数が多い場合に省略表示する -> http://qiita.com/yuyuchu3333/items/b10542db482c3ac8b059
ls_abbrev() {
    # -a : Do not ignore entries starting with ..
    # -C : Force multi-column output.
    # -F : Append indicator (one of */=>@|) to entries.
    local cmd_ls='ls -lAh -color'
    local -a opt_ls
    opt_ls=('-aCF' '--color=always')
    case "${OSTYPE}" in
        freebsd*|darwin*)
            if type gls > /dev/null 2>&1; then
                cmd_ls='gls'
            else
                # -G : Enable colorized output.
                opt_ls=('-aCFG')
            fi
            ;;
    esac

    local ls_result
    ls_result=$(CLICOLOR_FORCE=1 COLUMNS=$COLUMNS command $cmd_ls ${opt_ls[@]} | sed $'/^\e\[[0-9;]*m$/d')

    local ls_lines=$(echo "$ls_result" | wc -l | tr -d ' ')

    if [ $ls_lines -gt 10 ]; then
        echo "$ls_result" | head -n 5
        echo '...'
        echo "$ls_result" | tail -n 5
        echo "$(command ls -1 -A | wc -l | tr -d ' ') files exist"
    else
        echo "$ls_result"
    fi
}


# Enter で ls と git status を表示すると便利
  function do_enter() {
      if [ -n "$BUFFER" ]; then
          zle accept-line
          return 0
      fi
      echo
      ls -lAh -color
      #ls_abbrev
      if [ "$(git rev-parse --is-inside-work-tree 2> /dev/null)" = 'true' ]; then
          echo
          echo -e "\e[0;33m--- git status ---\e[0m"
          git status -sb
      fi
      zle reset-prompt
      return 0
  }

  zle -N do_enter
  bindkey '^m' do_enter

function peco-snippets() {

    local line
    local snippet
    local cwd
    local local_snippet
    if [ ! -e ~/.snippets ]; then
        echo "~/.snippets is not found." >&2
        return 1
    fi

    # Get snippets in the current directory if it exists.
    cwd=`pwd`
    if [ -e "$cwd/.snippets" ]; then
      local_snippet="$cwd/.snippets"
    else
      local_snippet=""
    fi

    line=$(cat $local_snippet ~/.snippets | grep -v "^\s*#" | grep -v '^\s*$' | peco --query "$LBUFFER")
    if [ -z "$line" ]; then
        return 1
    fi

    snippet=$(echo "$line" | sed "s/^[ |\*]*\[[^]]*\] *//g")
    if [ -z "$snippet" ]; then
        return 1
    fi

    BUFFER="$snippet"
    # 決定時にそのまま実行
    zle accept-line

    # 決定時にそのまま実行しない
    #zle clear-screen
}
zle -N peco-snippets
bindkey '^x^x' peco-snippets

function peco-select-history() {  # {{{
    local tac
    if which tac > /dev/null; then
        tac="tac"
    else
        tac="tail -r"
    fi
    BUFFER=$(\history -n 1 | \
        eval $tac | \
        peco --query "$LBUFFER")
    CURSOR=$#BUFFER
    zle clear-screen
}
zle -N peco-select-history
bindkey '^r' peco-select-history
# }}}

# プロンプト設定 #################################################### {{{
## PROMPT内で変数展開・コマンド置換・算術演算を実行する。
setopt prompt_subst
## PROMPT内で「%」文字から始まる置換機能を有効にする。
setopt prompt_percent
## コピペしやすいようにコマンド実行後は右プロンプトを消す。
setopt transient_rprompt

### プロンプトバーの左側
prompt_bar_left_self="%{%F{white}%K{yellow}%}  %n%{%k%f%}%{%F{white}%K{yellow}%}@%{%k%f%}%{%F{white}%K{yellow}%}%m %{%k%f%}%{%B%F{white}%K{yellow}%}＋ %{%b%f%k%}%{%B%F{white}%K{cyan}%}  [%~]  %{%k%f%b%}%{%k%f%}%(?.%F{white}%K{red}%}  COMP  %k%f.%B%K{red}%F{red}%}  ERROR  %b%k%f)%{%F{white}%K{green}%}  -%h  %{%k%f%}%{%B%F{white}%K{black}%}  %D{%Y/%m/%d %H:%M}  %{%b%f%k%}"
prompt_bar_left="${prompt_bar_left_self} ${prompt_bar_left_status} ${prompt_bar_left_date}"

### プロンプトバーの右側
#prompt_bar_right="-[%{%B%K{magenta}%F{white}%}%d%{%f%k%b%}]-"

### 2行目左にでるプロンプト。
#prompt_left="-[%h]%(1j,(%j),)%{%B%}%#%{%b%} "
prompt_left='%{%F{white}%K{magenta}%}  $SHELL  %{%k%f%}%{%B%F{white}%K{black}%} %# %{%b%k%f%} > '


## プロンプトフォーマットを展開した後の文字数を返す。
## 日本語未対応。
count_prompt_characters()
{
    print -n -P -- "$1" | sed -e $'s/\e\[[0-9;]*m//g' | wc -m | sed -e 's/ //g'
}

## プロンプトを更新する。
update_prompt()
{
    local bar_left_length=$(count_prompt_characters "$prompt_bar_left")
    local bar_rest_length=$[COLUMNS - bar_left_length]
    local bar_left="$prompt_bar_left"
    # パスに展開される「%d」を削除。
    local bar_right_without_path="${prompt_bar_right:s/%d//}"
    # 「%d」を抜いた文字数を計算する。
    local bar_right_without_path_length=$(count_prompt_characters "$bar_right_without_path")
    # パスの最大長を計算する。
    #   $[...]: 「...」を算術演算した結果で展開する。
    local max_path_length=$[bar_rest_length - bar_right_without_path_length]
    bar_right=${prompt_bar_right:s/%d/%(C,%${max_path_length}<...<%d%<<,)/}
    bar_right="%${bar_rest_length}<<${separator}${bar_right}%<<"
    # プロンプトバーと左プロンプトを設定
    PROMPT="${bar_left}${bar_right}"$'\n'"${prompt_left}"
    # 右プロンプト
    RPROMPT="%{%F{white}%K{black}%}  %l  %{%k%f%}%{%F{black}%K{white}%}  $LANG  %{%k%f%}"
    case "$TERM_PROGRAM" in
    Apple_Terminal)
        # Mac OS Xのターミナルでは$COLUMNSに右余白が含まれていないので
        # 右プロンプトに「-」を追加して調整。
        ## 2011-09-05
        RPROMPT="${RPROMPT}"
        ;;
    esac

    # バージョン管理システムの情報を取得する。
    LANG=C vcs_info >&/dev/null
    # バージョン管理システムの情報があったら右プロンプトに表示する。
    if [ -n "$vcs_info_msg_0_" ]; then
    RPROMPT="${vcs_info_msg_0_}${RPROMPT}"
    fi
}

## コマンド実行前に呼び出されるフック。
precmd_functions=($precmd_functions update_prompt)
################################################################################################### }}}

# zsh で特定の文字列を入力すると自動で return を押したことにさせる -> http://qiita.com/lpm11/items/fb180f510b3852d1ab77 {{{
typeset -A aaaliases
aaaliases=(
  "ll"    "ll"
  "gb"    "gb"
)

self-insert-aa() {
  local self_insert_next
  zstyle -s ":self-insert-aa" self-insert-next self_insert_next

  local aamatch
  local aastroke
  local aacommand
  local aacontext
  local aakey

  aamatch=0
  for aastroke in "${(@k)aaaliases}"; do
    aacommand=$aaaliases[$aastroke]
    aacontext=$aastroke[0,-2]
    aakey=$aastroke[-1]

    if [[ $LBUFFER == $aacontext && $KEYS == $aakey ]]; then
      LBUFFER=$aacommand
      zle .accept-line

      aamatch=1
      break
    fi
  done

  if [[ $aamatch == 0 ]]; then
    zle "$self_insert_next"
  fi
}

self-insert-aa.on() {
  # Find self-insert wrapper
  # reference: knu/zsh-git-escape-magic (https://github.com/knu/zsh-git-escape-magic)
  emulate -L zsh
  local self_insert_next="${$(zle -lL | awk '$1=="zle"&&$2=="-N"&&$3=="self-insert"{print $4;exit}'):-.self-insert}"

  zle -la "$self_insert_next" || zle -N "$self_insert_next"
  zstyle ":self-insert-aa" self-insert-next "$self_insert_next"
  zle -A self-insert-aa self-insert
}
zle -N self-insert-aa
self-insert-aa.on
# }}}}
