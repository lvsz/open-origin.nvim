local M = {
    ns = vim.api.nvim_create_namespace("open-origin"),
}

local unpack = unpack or table.unpack

local function get_cursor_word(line, tnum)
    local word_start = 1
    for i = 1, #line do
        if i > tnum then
            break
        elseif line:sub(i, i):find("%s") then
            word_start = i + 1
        end
    end
    local word_end = line:find("%s", word_start)
    return line:sub(word_start, word_end and word_end - 1), word_start
end

local function git_call(command, ...)
    local res = vim.fn.system({ "git", command, ... })
    return res:gsub("%s*$", "")
end

local function prefix_sub(s, prefix, repl)
    local i = 1
    while s:byte(i) == prefix:byte(i) do
        i = i + 1
    end
    return repl .. s:sub(i)
end

local function origin_url(view_type, path)
    local orig_url = git_call("remote", "get-url", "origin")
    local base_url = orig_url:gsub(".git$", "/" .. view_type .. "/")
    if view_type == "commit" then
        return base_url .. path
    else
        local git_dir = git_call("rev-parse", "--show-toplevel")
        local commit_hash = git_call("rev-parse", "@~1")
        return prefix_sub(path, git_dir, base_url .. commit_hash)
    end
end

local function action_open(url)
    vim.notify("Opening " .. url, 1)
    return vim.fn.system({ "open", url })
end

function M.open_origin(view_type)
    local path
    if vim.bo.filetype == "netrw" then
        path = vim.fn.getcwd()
        view_type = "tree"
    else
        local linenr = "#L" .. tostring(vim.api.nvim_win_get_cursor(0)[1])
        path = vim.api.nvim_buf_get_name(0) .. linenr
        view_type = view_type or "blob"
    end
    local url = origin_url(view_type, path)
    return action_open(url)
end

function M.open_origin_blame()
    return M.open_origin("blame")
end

function M.open_origin_tree()
    local path
    if vim.bo.filetype == "netrw" then
        path = vim.fn.getcwd()
    else
        path = vim.fn.expand("%:p:h")
    end
    local url = origin_url("tree", path)
    return action_open(url)
end

function M.open_origin_commit()
    local line = vim.api.nvim_get_current_line()
    local lnum, tnum = unpack(vim.api.nvim_win_get_cursor(0))
    local cursor_word, word_col = get_cursor_word(line, tnum)
    local commit_hash
    if cursor_word:match("^[A-Fa-f0-9]+$") then
        commit_hash = cursor_word
    else
        commit_hash = ""
        for hash in line:gmatch("[A-Fa-f0-9]+") do
            if #hash > #commit_hash then
                commit_hash = hash
            end
        end
    end
    if #commit_hash >= 7 then
        local url = origin_url("commit", commit_hash)
        return action_open(url)
    else
        local msg = "No valid commit hash detected"
        vim.notify(msg, vim.log.levels.WARN)
    end
end

return M
