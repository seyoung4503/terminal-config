# terminal-config

내 Mac 터미널/에디터 환경 dotfiles. 새 머신에서 `bash install.sh` 한 번이면 동일 환경 복원.

구성:
- **zsh** (oh-my-zsh + agnoster) — `zshrc`, `zprofile`
- **tmux** — `tmux.conf` (vim-tmux-navigator, mouse scroll, Shift+Enter passthrough)
- **ghostty** — `ghostty-config` (JetBrains Mono Nerd Font + cursor shaders)
- **nvim** — LazyVim 기반, `nvim/`
- **brew formulae**: zsh-syntax-highlighting, fastfetch, pyenv, nvm, tmux, neovim, ripgrep, fd, lazygit
- **brew casks**: font-jetbrains-mono-nerd-font, ghostty
- **추가 CLI**: macism (IME 자동 전환), pokemon-colorscripts

## 설치

```bash
bash install.sh
```

각 단계마다 y/n 묻고 진행. `/Users/seyeong` 경로는 자동으로 `$HOME`으로 치환.

---

## Neovim — LazyVim 메모

### 활성화된 LazyVim Extras

`nvim/lazyvim.json`에 명시. 새 머신에서 `bash install.sh`로 설치하면 첫 nvim 실행 시 자동 적용.

| Extra | 용도 |
|---|---|
| `lazyvim.plugins.extras.lang.python` | Python LSP/디버거/테스트 — `nvim-lspconfig`, `mason.nvim`, `basedpyright`, `nvim-dap-python`, `neotest-python`, `venv-selector.nvim` 등 |

추가하려면 `:LazyExtras` → 해당 줄에 `x` → 재시작.

### 사용자 플러그인 (`nvim/lua/plugins/`)

| 파일 | 플러그인 | 용도 |
|---|---|---|
| `neogit.lua` | `NeogitOrg/neogit` | git UI (`<leader>gm` Neogit) |
| `vim-tmux-navigator.lua` | tmux 창 ↔ vim 창 통합 이동 | `Ctrl-h/j/k/l`로 panes 넘나들기 |
| `im-select.lua` | `keaising/im-select.nvim` | **IME 자동 전환** (smart-input-source) |
| `example.lua` | (비활성, 예시용) | LazyVim 플러그인 커스터마이징 패턴 참고용 |

### IME 자동 전환 — `im-select.nvim`

흔히 "smart input source"라고 부르는 기능. nvim에서 모드 전환할 때 자동으로 영문/한글 토글.

**동작**:
- Insert 모드 종료 → 자동으로 영문 (`com.apple.keylayout.ABC`)
- 명령어 모드(`:`, `/`) 종료 → 영문
- Insert 모드 재진입 → 직전에 쓰던 IME 복원
- VimEnter / FocusGained 시점에도 영문으로

**의존**: `macism` CLI (Apple Silicon 권장)
```bash
brew tap laishulu/homebrew
brew install macism
```

`install.sh`가 이미 자동으로 처리.

---

## Troubleshooting

### `gd` (goto definition)이 정의가 아니라 import 줄로 점프

**원인**: LazyVim 코어에는 에디터 기능만 있고, **언어별 LSP는 extras로 따로 활성화**해야 함. 비활성 상태에선 `gd`가 vim 기본 동작(현재 파일 안에서 단어 검색)으로 fallback되어 가장 먼저 매치되는 import 줄로 점프.

**해결**:
```vim
:LazyExtras
```
→ Recommended Languages 섹션에서 `lang.python` 줄에 커서 놓고 **`x` 누름** (○ → ●) → `q`로 닫기 → **nvim 재시작**.

첫 .py 파일 열 때 Mason이 `basedpyright`를 자동 설치 (10~30초). 그 후 `gd`는 LSP 기반으로 진짜 정의 위치로 점프.

**확인**:
```vim
:checkhealth vim.lsp        " "Active Clients"에 basedpyright 표시되어야 정상
:Mason                      " basedpyright에 ✓ 있는지
:lua =vim.lsp.get_clients() " 빈 {} 가 아니어야 함
```

다른 언어(TS/Go/Rust 등)도 동일 패턴 — `:LazyExtras` → `lang.<언어>` 활성화.

### LSP 매핑 확인

```vim
:verbose nmap gd   " Snacks.picker.lsp_definitions 또는 vim.lsp.buf.definition이 보여야 정상
```

### live_grep / 프로젝트 전체 텍스트 검색

LazyVim + snacks.picker 기본 매핑 (별도 설치 불필요):

| 키 | 동작 |
|---|---|
| `<Space>/` | 프로젝트 루트에서 live grep |
| `<Space>sg` | 동일 |
| `<Space>sG` | 현재 디렉토리(cwd)에서 grep |
| `<Space>sw` | 커서 단어 검색 |
| `<Space><Space>` | 파일 fuzzy 찾기 |

직접 호출:
```vim
:lua Snacks.picker.grep()
```

### `:LspInfo`가 없다고 나옴

nvim 0.11에서 `:LspInfo`는 `:checkhealth vim.lsp` 로 대체됨.

```vim
:checkhealth vim.lsp
```

또는 LazyVim 기본 매핑 `<Space>cl`.

---

## 디렉토리 구조

```
terminal-config/
├── README.md                ← 이 문서
├── install.sh               ← 8단계 설치 스크립트
├── zshrc, zprofile          ← shell dotfiles
├── tmux.conf                ← tmux 설정
├── ghostty-config           ← ghostty 터미널 설정
├── stylua.toml              ← lua 포매터 설정
└── nvim/                    ← LazyVim 설정 (~/.config/nvim 으로 복사됨)
    ├── init.lua             ← LazyVim bootstrap
    ├── lazyvim.json         ← 활성화된 extras 목록
    ├── lazy-lock.json       ← 플러그인 버전 lock
    ├── .neoconf.json        ← LSP 워크스페이스 설정
    └── lua/
        ├── config/          ← LazyVim 코어 설정 override (autocmds, keymaps, options)
        └── plugins/         ← 사용자 플러그인 정의
            ├── example.lua
            ├── neogit.lua
            ├── vim-tmux-navigator.lua
            └── im-select.lua    ← IME 자동 전환
```
