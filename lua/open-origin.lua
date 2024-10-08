local a = vim.api
local M = {
    ns = a.nvim_create_namespace "open-origin",
}

local unpack = unpack or table.unpack

local function get_cursor_word(line, tnum)
    local word_start = 1
    for i = 1, #line do
        if i > tnum then
            break
        elseif line:sub(i, i):find('%s') then
            word_start = i + 1
        end
    end
    local word_end = line:find('%s', word_start)
    return line:sub(word_start, word_end and word_end - 1), word_start
end

local function git_call(command, ...)
    local res = vim.fn.system({'git', command, ...})
    return res:gsub('%s*$', '')
end

local function origin_url(view_type, path)
    local orig_url = git_call('remote', 'get-url', 'origin')
    local base_url = orig_url:gsub('.git$', '/' .. view_type .. '/')
    if view_type == 'commit' then
        return base_url .. path
    else
        local git_dir = git_call('rev-parse', '--show-toplevel')
        local commit_hash = git_call('rev-parse', '@~1')
        return path:gsub(git_dir, base_url .. commit_hash)
    end
end

local function netrw_line()
    local path = a.nvim_get_current_line():gsub('^.%s(%S+)$', '%1')
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
        local linenr = '#L' .. tostring(a.nvim_win_get_cursor(0)[1])
        path = a.nvim_buf_get_name(0) .. linenr
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

function M.open_origin_hash()
    local line = a.nvim_get_current_line()
    local lnum, tnum = unpack(a.nvim_win_get_cursor(0))
    local cursor_word, word_col = get_cursor_word(line, tnum)
    local commit_hash
    if cursor_word:match('^[A-Fa-f0-9]+$') then
        commit_hash = cursor_word
    else
        commit_hash = ''
        for hash in line:gmatch( '[A-Fa-f0-9]+') do
            if #hash > #commit_hash then
                commit_hash = hash
            end
        end
    end
    if #commit_hash >= 7 then
        local url = origin_url('commit', commit_hash)
        local msg = url
        local diagnostics = {}
        table.insert(
            diagnostics,
            {
                lnum = lnum - 1,
                end_lnum = lnum - 1,
                col = word_col - 1,
                end_col = word_col - 1 + #cursor_word,
                message = msg,
                severity = "HINT",
            })
        vim.diagnostic.set(M.ns, 0, diagnostics)
        vim.on_key(
            function()
                vim.diagnostic.reset(M.ns)
                vim.on_key(nil, M.ns)
            end,
            M.ns
        )
        return vim.fn.system({'open', url})
    else
        local msg = "No valid commit hash detected"
        local diagnostics = {}
        table.insert(
            diagnostics,
            {
                lnum = lnum - 1,
                end_lnum = lnum - 1,
                col = word_col - 1,
                end_col = word_col - 1 + #cursor_word,
                message = msg,
                severity = "HINT",
            })
        vim.diagnostic.set(M.ns, 0, diagnostics)
        vim.on_key(
            function()
                vim.diagnostic.reset(M.ns)
                vim.on_key(nil, M.ns)
            end,
            M.ns
        )
    end
end

return M
