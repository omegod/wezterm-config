local wezterm = require 'wezterm'
local config = wezterm.config_builder()


-- 窗口启动位置：偏左的居中
wezterm.on('gui-startup', function(cmd)
  local screen = wezterm.gui.screens().main
  local width = 720
  local height = 520
  local _, _, window = wezterm.mux.spawn_window(cmd or {
    position = {
      x = screen.width * 0.15,
      y = (screen.height - height) / 2.5,
    },
  })
end)

-- 字体配置：SF Mono + 400字重（Regular） + 原生 Emoji
config.font = wezterm.font_with_fallback({
  { family = 'SF Mono', weight = 'Regular' },
  { family = 'Menlo', weight = 'Regular' },
})
config.font_size = 13.0

-- 字体渲染深度微调：增强“肉感”和厚度
config.freetype_load_target = "HorizontalLcd" -- 相比 Light，Normal 有时更扎实
config.freetype_render_target = "HorizontalLcd"
config.line_height = 1.05 -- 稍微拉开行高，让文字看起来更饱满
config.cell_width = 1.00


-- 关键：禁用加粗时颜色变亮，保持色彩浓度一致
config.bold_brightens_ansi_colors = false
config.term = "xterm-256color"

config.set_environment_variables = {
  LANG = 'zh_CN.UTF-8',
  LC_ALL = 'zh_CN.UTF-8',
}

-- 根据系统外观返回配色方案
local function get_appearance()
  if wezterm.gui then
    return wezterm.gui.get_appearance()
  end
  return 'Light'
end

-- 官方 macOS Terminal 颜色值
local function scheme_for_appearance(appearance)
  if appearance:find 'Dark' then
    -- 模拟 macOS Terminal 的 Pro (Dark) 官方配色
    return {
      colors = {
        foreground = '#ffffff',
        background = '#1d1d1d',
        cursor_bg = '#7f7f7f', -- 官方中灰色光标
        cursor_fg = '#ffffff',
        cursor_border = '#7f7f7f',
        selection_bg = '#414141',
        selection_fg = '#ffffff',
        ansi = {
          '#000000', '#B43A2C', '#00b02c', '#B6B045', '#6F64D8', '#A420AD', '#19aac0', '#C0BFBF',
        },
        brights = {
          '#666666', '#E64A3C', '#65d26c', '#F2F06A', '#9A8CFF', '#D32DDE', '#68E1E5', '#E5E6E6',
        },
        tab_bar = {
          background = '#1e1e1e',
          active_tab = { bg_color = '#000000', fg_color = '#ffffff', intensity = 'Normal' },
          inactive_tab = { bg_color = '#1e1e1e', fg_color = '#aaaaaa' },
          inactive_tab_hover = { bg_color = '#333333', fg_color = '#ffffff' },
          new_tab = { bg_color = '#1e1e1e', fg_color = '#aaaaaa' },
          new_tab_hover = { bg_color = '#333333', fg_color = '#ffffff' },
        },
      },
      window_frame = {
        active_titlebar_bg = '#1e1e1e',
        inactive_titlebar_bg = '#1e1e1e',
        button_bg = '#1e1e1e',
        button_hover_bg = '#333333',
        font_size = 13.0,
      },
    }
  else
    -- 模拟 macOS Terminal 的 Basic (Light) 官方配色
    return {
      colors = {
        foreground = '#1d1d1d',
        background = '#ffffff',
        cursor_bg = '#7f7f7f', -- 官方中灰色光标，不再是纯黑
        cursor_fg = '#ffffff',
        cursor_border = '#7f7f7f',
        selection_bg = '#a5cdff',
        selection_fg = '#1d1d1d',
        ansi = {
          '#000000', '#cc3b2a', '#00b02c', '#9A992F', '#4737d1', '#ad12b8', '#18b3cb', '#C0BFBF',
        },
        brights = {
          '#666666', '#E64A3C', '#5ad262', '#E6E54B', '#5540f0', '#d437df', '#12e5ed', '#E5E6E6',
        },
        tab_bar = {
          background = '#f3f3f3',
          active_tab = { bg_color = '#ffffff', fg_color = '#000000', intensity = 'Bold' },
          inactive_tab = { bg_color = '#f3f3f3', fg_color = '#666666' },
          inactive_tab_hover = { bg_color = '#e0e0e0', fg_color = '#000000' },
          new_tab = { bg_color = '#f3f3f3', fg_color = '#666666' },
          new_tab_hover = { bg_color = '#f3f3f3', fg_color = '#000000' },
        },
      },
      window_frame = {
        active_titlebar_bg = '#f3f3f3',
        inactive_titlebar_bg = '#f3f3f3',
        button_bg = '#f3f3f3',
        button_hover_bg = '#f3f3f3',
        font_size = 13.0,
      },
    }
  end
end

local appearance = get_appearance()
local scheme = scheme_for_appearance(appearance)
config.colors = scheme.colors
config.window_frame = scheme.window_frame

-- 标签栏设置
config.enable_tab_bar = true
config.use_fancy_tab_bar = true
config.tab_bar_at_bottom = true
config.hide_tab_bar_if_only_one_tab = false

-- 窗口装饰与布局
config.window_decorations = "RESIZE | TITLE" 
config.window_padding = { left = 20, right = 20, top = 20, bottom = 10 }

-- 渲染引擎
config.front_end = "WebGpu"
config.window_close_confirmation = 'NeverPrompt'
config.scrollback_lines = 10000
config.enable_scroll_bar = false

-- 分屏
config.keys = {
  -- 垂直分屏（左右）
  { key = '\\', mods = 'CMD', action = wezterm.action.SplitHorizontal { domain = 'CurrentPaneDomain' }},
  -- 水平分屏（上下）
  { key = '-', mods = 'CMD', action = wezterm.action.SplitVertical { domain = 'CurrentPaneDomain' }},
  -- 关闭分屏
  {key = 'q', mods = 'CMD|ALT', action = wezterm.action.CloseCurrentPane { confirm = false }},
  -- 切换光标
  { key = 'h', mods = 'CMD', action = wezterm.action.ActivatePaneDirection 'Left' },
  { key = 'l', mods = 'CMD', action = wezterm.action.ActivatePaneDirection 'Right' },
  { key = 'k', mods = 'CMD', action = wezterm.action.ActivatePaneDirection 'Up' },
  { key = 'j', mods = 'CMD', action = wezterm.action.ActivatePaneDirection 'Down' },
}
return config
