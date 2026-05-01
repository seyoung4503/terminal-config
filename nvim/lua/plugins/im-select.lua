-- IME 자동 전환 (Smart Input Source)
-- - Insert 모드 종료 / 명령어 모드 종료 시 → 자동으로 영문 (com.apple.keylayout.ABC)
-- - Insert 모드 재진입 시 → 직전에 쓰던 IME 복원
-- 의존: macism (brew tap laishulu/homebrew && brew install macism)
return {
  {
    "keaising/im-select.nvim",
    event = "InsertEnter",
    opts = {
      -- 노멀 모드/명령창 진입 시 강제로 돌아갈 IME
      default_im_select = "com.apple.keylayout.ABC",
      -- 사용할 CLI 도구 (Apple Silicon에선 macism 권장)
      default_command = "macism",
      -- 영문으로 자동 전환되는 시점
      set_default_events = { "VimEnter", "FocusGained", "InsertLeave", "CmdlineLeave" },
      -- Insert 모드 진입 시 직전 IME 복원
      set_previous_events = { "InsertEnter" },
      -- 관련 메시지/알림 숨김
      keep_quiet_on_no_binary = false,
      async_switch_im = true,
    },
  },
}
