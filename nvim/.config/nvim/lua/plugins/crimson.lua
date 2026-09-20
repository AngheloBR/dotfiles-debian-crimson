-- Ajustes propios del Rice "Debian Crimson" sobre LazyVim
return {
  -- LazyVim trae catppuccin como tema alternativo: no se usa (regla 3:
  -- nada de temas ajenos), asi que ni se carga
  { "catppuccin/nvim", enabled = false },

  -- bash: shellcheck (ya instalado por apt) avisa de errores al guardar.
  -- Este repo es casi todo bash; sin esto el editor no lo revisaba.
  {
    "mfussenegger/nvim-lint",
    opts = {
      linters_by_ft = {
        sh = { "shellcheck" },
        bash = { "shellcheck" },
      },
    },
  },
}
