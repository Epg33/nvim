require('feline').setup()

local lsp = require 'feline.providers.lsp'
local vi_mode_utils = require 'feline.providers.vi_mode'

local vi_mode_colors = {
    NORMAL = '#282c34',
    INSERT = '#e86671',
    VISUAL = '#c678dd',
    OP = '#282c34',
    BLOCK = '#61afef',
    REPLACE = '#a9a1e1',
    ['V-REPLACE'] = '#a9a1e1',
    ENTER = '#56b6c2',
    MORE = '#56b6c2',
    SELECT = '#d19a66',
    COMMAND = '#282c34',
    SHELL = '#282c34',
    TERM = '#282c34',
    NONE = '#e0af68'
}

local icons = {
    linux = ' ',
    macos = ' ',
    windows = ' ',

    errs = ' ',
    warns = ' ',
    infos = ' ',
    hints = ' ',

    lsp = ' ',
    git = ''
}

local function file_osinfo()
    local os = vim.bo.fileformat:upper()
    local icon
    if os == 'UNIX' then
        icon = icons.linux
    elseif os == 'MAC' then
        icon = icons.macos
    else
        icon = icons.windows
    end
    return icon .. os
end

local function lsp_diagnostics_info()
    return {
        errs = lsp.get_diagnostics_count('Error'),
        warns = lsp.get_diagnostics_count('Warning'),
        infos = lsp.get_diagnostics_count('Information'),
        hints = lsp.get_diagnostics_count('Hint')
    }
end

local function diag_enable(f, s)
    return function()
        local diag = f()[s]
        return diag and diag ~= 0
    end
end

local function diag_of(f, s)
    local icon = icons[s]
    return function()
        local diag = f()[s]
        return icon .. diag
    end
end

local function vimode_hl()
    return {
        name = vi_mode_utils.get_mode_highlight_name(),
        fg = vi_mode_utils.get_mode_color()
    }
end

-- LuaFormatter off

local comps = {
    vi_mode = {
        left = {
            provider = '▊',
            hl = vimode_hl,
            right_sep = ' '
        },
        right = {
            provider = '▊',
            hl = vimode_hl,
            left_sep = ' '
        }
    },
    file = {
        info = {
            provider = 'file_info',
            hl = {
                fg = '#61afef',
                style = 'bold'
            }
        },
        encoding = {
            provider = 'file_encoding',
            left_sep = ' ',
            hl = {
                fg = '#a9a1e1',
                style = 'bold'
            }
        },
        type = {
            provider = 'file_type'
        },
        os = {
            provider = file_osinfo,
            left_sep = ' ',
            hl = {
                fg = '#a9a1e1',
                style = 'bold'
            }
        }
    },
    line_percentage = {
        provider = 'line_percentage',
        left_sep = ' ',
        hl = {
            style = 'bold'
        }
    },
    scroll_bar = {
        provider = 'scroll_bar',
        left_sep = ' ',
        hl = {
            fg = '#61afef',
            style = 'bold'
        }
    },
    diagnos = {
        err = {
            provider = diag_of(lsp_diagnostics_info, 'errs'),
            left_sep = ' ',
            enabled = diag_enable(lsp_diagnostics_info, 'errs'),
            hl = {
                fg = '#e86671'
            }
        },
        warn = {
            provider = diag_of(lsp_diagnostics_info, 'warns'),
            left_sep = ' ',
            enabled = diag_enable(lsp_diagnostics_info, 'warns'),
            hl = {
                fg = '#e0af68'
            }
        },
        info = {
            provider = diag_of(lsp_diagnostics_info, 'infos'),
            left_sep = ' ',
            enabled = diag_enable(lsp_diagnostics_info, 'infos'),
            hl = {
                fg = '#61afef'
            }
        },
        hint = {
            provider = diag_of(lsp_diagnostics_info, 'hints'),
            left_sep = ' ',
            enabled = diag_enable(lsp_diagnostics_info, 'hints'),
            hl = {
                fg = '#56b6c2'
            }
        },
    },
    lsp = {
        name = {
            provider = 'lsp_client_names',
            left_sep = ' ',
            icon = icons.lsp,
            hl = {
                fg = '#e0af68'
            }
        }
    },
    git = {
        branch = {
            provider = 'git_branch',
            icon = icons.git,
            left_sep = ' ',
            hl = {
                fg = '#a9a1e1',
                style = 'bold'
            },
        },
        add = {
            provider = 'git_diff_added',
            hl = {
                fg = '#98c379'
            }
        },
        change = {
            provider = 'git_diff_changed',
            hl = {
                fg = '#d19a66'
            }
        },
        remove = {
            provider = 'git_diff_removed',
            hl = {
                fg = '#e86671'
            }
        }
    }
}

local properties = {
    force_inactive = {
        filetypes = {
            'NvimTree',
            'dbui',
            'packer',
            'startify',
            'fugitive',
            'fugitiveblame'
        },
        buftypes = {'terminal'},
        bufnames = {}
    }
}

local components = {
    left = {
        active = {
            comps.vi_mode.left,
            comps.file.info,
            comps.lsp.name,
            comps.diagnos.err,
            comps.diagnos.warn,
            comps.diagnos.hint,
            comps.diagnos.info
        },
        inactive = {
            comps.vi_mode.left,
            comps.file.info
        }
    },
    mid = {
        active = {},
        inactive = {}
    },
    right = {
        active = {
            comps.git.add,
            comps.git.change,
            comps.git.remove,
            comps.file.os,
            comps.git.branch,
            comps.line_percentage,
            comps.scroll_bar,
            comps.vi_mode.right
        },
        inactive = {}
    }
}

-- LuaFormatter on

require'feline'.setup {
    default_bg = '#282c34',
    default_fg = '#abb2bf',
    components = components,
    properties = properties,
    vi_mode_colors = vi_mode_colors
}

