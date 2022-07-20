local set = vim.opt
-- set commands
set.tabstop = 2
set.shiftwidth = 2
set.expandtab = true
set.wrap = false 
set.mouse = 'a'
-- theme
set.background = 'dark'
set.number = true
set.encoding = 'UTF-8' set.relativenumber = true
local Plug = vim.fn['plug#']

vim.call('plug#begin', '~/.config/nvim/autoload/plugged')
Plug('ellisonleao/gruvbox.nvim')
Plug('preservim/nerdtree')
Plug('ryanoasis/vim-devicons')
Plug('neovim/nvim-lspconfig')
Plug('williamboman/nvim-lsp-installer')
Plug('nvim-treesitter/nvim-treesitter')
Plug('alvan/vim-closetag')
Plug('jiangmiao/auto-pairs')
Plug('tpope/vim-surround')


-- stuff for autocomplete/tree sitter/lsp
Plug('hrsh7th/cmp-nvim-lsp')
Plug('hrsh7th/cmp-buffer')
Plug('hrsh7th/cmp-path')
Plug('hrsh7th/cmp-cmdline')
Plug('hrsh7th/nvim-cmp')
Plug('hrsh7th/cmp-vsnip')
Plug('hrsh7th/vim-vsnip')
Plug('saadparwaiz1/cmp_luasnip') -- Snippets source for nvim-cmp
Plug('L3MON4D3/LuaSnip') -- Snippets plugink

Plug('nvim-lua/plenary.nvim')
Plug('nvim-telescope/telescope.nvim')
Plug('tpope/vim-commentary')
Plug('itchyny/lightline.vim')

-- markdown
Plug('ellisonleao/glow.nvim')
Plug('iamcco/markdown-preview.nvim')

-- indent
Plug("lukas-reineke/indent-blankline.nvim")

vim.call('plug#end')

 -- treesitter
 require('nvim-treesitter.configs').setup {
   -- A list of parser names, or "all"
   ensure_installed = {"javascript", "rst", "cpp", "c", "html", "typescript", "vue", "sparql"},
 
   highlight = {
     enable = true,
 
     -- Setting this to true will run `:h syntax` and tree-sitter at the same time.
     -- Set this to `true` if you depend on 'syntax' being enabled (like for indentation).
     -- Using this option may slow down your editor, and you may see some duplicate highlights.
     -- Instead of true it can also be a list of languages
     additional_vim_regex_highlighting = false,
   },
 }

-- lsp 
 local on_attach = function(client, bufnr)
   local opts = { noremap=true, silent=true }
   -- Mappings.
   -- See `:help vim.lsp.*` for documentation on any of the below functions
   vim.api.nvim_buf_set_keymap(bufnr, 'n', 'gD', '<cmd>lua vim.lsp.buf.declaration()<CR>', opts)
   vim.api.nvim_buf_set_keymap(bufnr, 'n', 'gd', '<cmd>lua vim.lsp.buf.definition()<CR>', opts)
   vim.api.nvim_buf_set_keymap(bufnr, 'n', 'K', '<cmd>lua vim.lsp.buf.hover()<CR>', opts)
   vim.api.nvim_buf_set_keymap(bufnr, 'n', 'gi', '<cmd>lua vim.lsp.buf.implementation()<CR>', opts)
   vim.api.nvim_buf_set_keymap(bufnr, 'n', '<C-k>', '<cmd>lua vim.lsp.buf.signature_help()<CR>', opts)
   vim.api.nvim_buf_set_keymap(bufnr, 'n', '<space>wa', '<cmd>lua vim.lsp.buf.add_workspace_folder()<CR>', opts)
   vim.api.nvim_buf_set_keymap(bufnr, 'n', '<space>wr', '<cmd>lua vim.lsp.buf.remove_workspace_folder()<CR>', opts)
   vim.api.nvim_buf_set_keymap(bufnr, 'n', '<space>wl', '<cmd>lua print(vim.inspect(vim.lsp.buf.list_workspace_folders()))<CR>', opts)
   vim.api.nvim_buf_set_keymap(bufnr, 'n', '<space>D', '<cmd>lua vim.lsp.buf.type_definition()<CR>', opts)
   vim.api.nvim_buf_set_keymap(bufnr, 'n', '<space>rn', '<cmd>lua vim.lsp.buf.rename()<CR>', opts)
   vim.api.nvim_buf_set_keymap(bufnr, 'n', '<space>ca', '<cmd>lua vim.lsp.buf.code_action()<CR>', opts)
   vim.api.nvim_buf_set_keymap(bufnr, 'n', 'gr', '<cmd>lua vim.lsp.buf.references()<CR>', opts)
   vim.api.nvim_buf_set_keymap(bufnr, 'n', '<space>f', '<cmd>lua vim.lsp.buf.formatting()<CR>', opts)
   vim.api.nvim_set_keymap('n', '<space>e', '<cmd>lua vim.diagnostic.open_float()<CR>', opts)
 end

local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities = require('cmp_nvim_lsp').update_capabilities(capabilities)

local servers = { 'tsserver', 'vuels' }
for _, lsp in pairs(servers) do
  require('lspconfig')[lsp].setup {
    on_attach = on_attach,
    capabilities = capabilities,
    settings = {
        ["rust-analyzer"] = {
            assist = {
                importGranularity = "module",
                importPrefix = "self",
            },
            cargo = {
                loadOutDirsFromCheck = true
            },
            procMacro = {
                enable = true
            },
        }
    }
  }
end

-- luasnip setup
local luasnip = require 'luasnip'

-- nvim-cmp setup
local cmp = require 'cmp'
cmp.setup {
  snippet = {
    expand = function(args)
      luasnip.lsp_expand(args.body)
    end,
  },
  mapping = cmp.mapping.preset.insert({
    ['<C-d>'] = cmp.mapping.scroll_docs(-4),
    ['<C-f>'] = cmp.mapping.scroll_docs(4),
    ['<C-Space>'] = cmp.mapping.complete(),
    ['<CR>'] = cmp.mapping.confirm {
      behavior = cmp.ConfirmBehavior.Replace,
      select = true,
    },
    ['<Tab>'] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_next_item()
      elseif luasnip.expand_or_jumpable() then
        luasnip.expand_or_jump()
      else
        fallback()
      end
    end, { 'i', 's' }),
    ['<S-Tab>'] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_prev_item()
      elseif luasnip.jumpable(-1) then
        luasnip.jump(-1)
      else
        fallback()
      end
    end, { 'i', 's' }),
  }),
  sources = {
    { name = 'nvim_lsp' },
    { name = 'luasnip' },
  },
}
-- indent
vim.opt.list = true
vim.opt.listchars:append("eol:↴")
require("indent_blankline").setup {
  -- char = "|",
  show_end_of_line = true,
}

vim.cmd([[
" closing tags
let g:closetag_filenames = '*x.html,*.jsx,*.tsx, *.vue'

colorscheme gruvbox 

set guifont=DroidSansMono\ Nerd\ Font\ 18
set termguicolors

inoremap kj <Esc>

filetype on
filetype indent on
filetype plugin on
if has("syntax")
    syntax on
endif

map <C-n> :NERDTreeToggle<CR> 
autocmd BufEnter NERD_tree_* | execute 'normal R'
let NERDTreeShowHidden=1

autocmd BufEnter * if tabpagenr('$') == 1 && winnr('$') == 1 && exists('b:NERDTree') && b:NERDTree.isTabTree() | quit | endif

hi Normal guibg=NONE ctermbg=NONE

" telescope
noremap <silent> ff :Telescope find_files<CR>
" lightline
set noshowmode

let g:lightline = {
 \ 'colorscheme': 'gruvbox',
 \ }

" set clipboard+=unnamedplus

" copy to clipboard
nnoremap  <leader>y  "+y
vnoremap  <leader>y  "+y
]])
