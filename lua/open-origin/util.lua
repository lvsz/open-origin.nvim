local M = {}

local CURL_LIMIT = 7

local function git_call(command, ...)
    local res = vim.fn.system({ "git", command, ... })
    return res:gsub("%s*$", "")
end

local function remote_exists(url)
    local res = vim.fn.system({ "curl", "-s", url })
    return res ~= "Not Found"
end

local function find_last_upstream_commit()
    -- try recent local commits first
    local hash = git_call("rev-parse", "@")
    local url = M.origin_url("commit", "")
    local limit = CURL_LIMIT
    while limit > 0 do
        if remote_exists(url .. hash) then
            return hash
        else
            hash = git_call("rev-parse", hash .. "~")
            limit = limit - 1
        end
    end
    -- else check current branch on remotes
    local branch = git_call("branch", "--show-current")
    local remotes = git_call("remote", "show")
    for remote in remotes:gmatch("%S+") do
        hash = git_call("rev-parse", "--revs-only", remote .. "/" .. branch)
        if remote_exists(url .. hash) then
            return hash
        end
    end
    -- as final resort, return origin HEAD
    return git_call("rev-parse", "origin/HEAD")
end

local function prefix_sub(s, prefix, repl)
    local i = 1
    while s:byte(i) == prefix:byte(i) do
        i = i + 1
    end
    return repl .. s:sub(i)
end

function M.get_cursor_word(line, tnum)
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

function M.origin_url(view_type, path)
    local orig_url = git_call("remote", "get-url", "origin")
    local base_url = orig_url:gsub(".git$", "/" .. view_type .. "/")
    if view_type == "commit" then
        return base_url .. path
    else
        local git_dir = git_call("rev-parse", "--show-toplevel")
        local commit_hash = find_last_upstream_commit()
        return prefix_sub(path, git_dir, base_url .. commit_hash)
    end
end

return M
