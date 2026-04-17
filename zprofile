
# Setting PATH for Python 3.10
# The original version is saved in .zprofile.pysave
PATH="/Library/Frameworks/Python.framework/Versions/3.10/bin:${PATH}"
export PATH


# Added by Toolbox App
export PATH="$PATH:/Users/seyeong/Library/Application Support/JetBrains/Toolbox/scripts"

eval "$(/opt/homebrew/bin/brew shellenv)"

# Homebrew 바이너리 경로와 pyenv 루트 경로를 먼저 넣습니다
export PYENV_ROOT="$HOME/.pyenv"
export PATH="/opt/homebrew/bin:$PYENV_ROOT/bin:$PATH"

# 로그인 셸에서 pyenv 초기화 (path shims 등록)
eval "$(pyenv init --path)"

