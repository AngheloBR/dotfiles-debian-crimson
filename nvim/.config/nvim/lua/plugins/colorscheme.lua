-- Tema "Debian Crimson" para LazyVim
-- Paleta del rice: fondo #0f0f12, carmesi #D70A53, dorado #E8B04B
return {
  {
    "folke/tokyonight.nvim",
    opts = {
      style = "night",
      transparent = true, -- deja ver el blur/opacity de kitty+picom
      styles = {
        sidebars = "transparent",
        floats = "transparent",
      },
      on_colors = function(c)
        c.bg = "#0f0f12"
        c.bg_dark = "#0a0a0d"
        c.bg_popup = "#0f0f12"
        c.bg_sidebar = "#0f0f12"
        c.fg = "#d6d6d6"
        c.fg_dark = "#b3b3b8"
        c.comment = "#45474e"
        -- acentos
        c.magenta = "#D70A53"
        c.red = "#ff2e6e"
        c.yellow = "#E8B04B"
        c.yellow1 = "#ffd080"
        -- tokyonight usa estos para highlight de cursor/seleccion
        c.bg_highlight = "#2b2b2e"
      end,
      on_highlights = function(hl, c)
        -- cursor y seleccion con el carmesi del rice
        hl.CursorLineNr = { fg = "#E8B04B", bold = true }
        hl.Visual = { bg = "#D70A53", fg = "#0f0f12" }
        hl.Search = { bg = "#E8B04B", fg = "#0f0f12" }
        -- ventana flotante con borde carmesi
        hl.FloatBorder = { fg = "#D70A53" }
        hl.WinSeparator = { fg = "#2b2b2e" }
        -- lualine/tabarline se heredan de tokyonight, quedan bien
      end,
    },
  },
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "tokyonight",
    },
  },
}
