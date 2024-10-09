local M = {}

local function git_call(command, ...)
    local res = vim.fn.system({'git', command, ...})
    return res:gsub('%s*$', '')
end

local function origin_url(view_type, path)
    local hash = git_call('rev-parse', '@~1')
    local git_dir = git_call('rev-parse', '--show-toplevel')
    local orig_url = git_call('remote', 'get-url', 'origin')
    local base_url = orig_url:gsub('.git$', '/'..view_type..'/'..hash)
    return path:gsub(git_dir, base_url)
end

local function netrw_line()
    local path = vim.api.nvim_get_current_line():gsub('^.%s(%S+)$', '%1')
    if path:match('%w+/$') then
        return 'TODO'
    end
end

function M.open_origin(view_type)
    local path
    if vim.bo.filetype == 'netrw' then
        path = vim.fn.getcwd()
        view_type = 'tree'
    else
        local linenr = '#L'..tostring(vim.api.nvim_win_get_cursor(0)[1])
        path = vim.api.nvim_buf_get_name(0)..linenr
        view_type = view_type or 'blob'
    end
    local url = origin_url(view_type, path)
    return vim.fn.system({'open', url})
end

function M.open_origin_blame()
    return M.open_origin('blame')
end

function M.open_origin_tree()
    local path
    if vim.bo.filetype == 'netrw' then
        path = vim.fn.getcwd()
    else
        path = vim.fn.expand('%:p:h')
    end
    local url = origin_url('tree', path)
    return vim.fn.system({'open', url})
end

return M
