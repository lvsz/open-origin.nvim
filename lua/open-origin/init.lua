local util = require "open-origin.util"

local M = {
    ns = vim.api.nvim_create_namespace("open-origin"),
}

local unpack = unpack or table.unpack

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
    local url = util.origin_url(view_type, path)
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
    local url = util.origin_url("tree", path)
    return action_open(url)
end

function M.open_origin_commit()
    local line = vim.api.nvim_get_current_line()
    local lnum, tnum = unpack(vim.api.nvim_win_get_cursor(0))
    local cursor_word, word_col = util.get_cursor_word(line, tnum)
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
        local url = util.origin_url("commit", commit_hash)
        return action_open(url)
    else
        local msg = "No valid commit hash detected"
        vim.notify(msg, vim.log.levels.WARN)
    end
end

return M
