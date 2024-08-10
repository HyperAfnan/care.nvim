---@param entry lsp.CompletionItem
---@return lsp.CompletionItem
local function normalize_entry(entry)
    entry.insertTextFormat = entry.insertTextFormat or 1
    -- TODO: make this earlier because the sorting won't happen here
    -- TODO: perhaps remove? are these fields even relevant to complete?
    entry.filterText = entry.filterText or entry.label
    entry.sortText = entry.sortText or entry.label
    entry.insertText = entry.insertText or entry.label
    return entry
end

---@param entry care.entry
return function(entry)
    local config = require("care.config").options
    if _G.care_debug then
        print("Confirming Entry")
        print("Completion item:")
        vim.print(entry.completion_item)
        print("------")
        print("Entry context:")
        vim.print(entry.context)
        print("------")
    end

    local cur_ctx = require("care.context").new()
    local unblock = require("care").core:block()

    local completion_item = entry.completion_item
    completion_item = normalize_entry(completion_item)

    -- Restore context where entry was completed
    vim.api.nvim_buf_set_text(
        cur_ctx.bufnr,
        cur_ctx.cursor.row - 1,
        entry:get_offset(),
        cur_ctx.cursor.row - 1,
        cur_ctx.cursor.col,
        {
            string.sub(entry.context.line_before_cursor, entry:get_offset() + 1),
        }
    )
    vim.api.nvim_win_set_cursor(0, { entry.context.cursor.row, entry.context.cursor.col })

    cur_ctx = require("care.context").new()

    ---@param e care.entry
    local function get_insert_range(e)
        if e.completion_item.textEdit then
            if e.completion_item.textEdit.insert then
                return e.completion_item.textEdit.insert
            else
                return e.completion_item.textEdit.range
            end
        else
            return {
                start = {
                    character = e:get_offset(),
                    line = e.context.cursor.row - 1,
                },
                ["end"] = {
                    character = e.context.cursor.col,
                    line = e.context.cursor.row - 1,
                },
            }
        end
    end
    local range = get_insert_range(entry)

    if _G.care_debug then
        print("Range before adjustments:")
        vim.print(range)
        print("------")
    end

    -- TODO: entry.insertTextMode
    local is_snippet = completion_item.insertTextFormat == 2
    local snippet_text

    if not completion_item.textEdit then
        ---@diagnostic disable-next-line: missing-fields
        completion_item.textEdit = {
            newText = completion_item.insertText,
        }
    end

    -- TODO: check out cmp insert and replace range
    completion_item.textEdit.range = range

    local diff_before = math.max(0, entry.context.cursor.col - completion_item.textEdit.range.start.character)
    local diff_after = math.max(0, completion_item.textEdit.range["end"].character - entry.context.cursor.col)

    completion_item.textEdit.range.start.line = cur_ctx.cursor.row - 1
    completion_item.textEdit.range.start.character = cur_ctx.cursor.col - diff_before
    completion_item.textEdit.range["end"].line = cur_ctx.cursor.row - 1
    completion_item.textEdit.range["end"].character = cur_ctx.cursor.col + diff_after

    if is_snippet then
        snippet_text = completion_item.textEdit.newText or completion_item.insertText
        completion_item.textEdit.newText = ""
    end

    if _G.care_debug then
        print("Text Edit:")
        vim.print(completion_item.textEdit)
        print("------")
        print("Snippet Text:")
        vim.print(snippet_text)
        print("------")
    end

    vim.lsp.util.apply_text_edits({ completion_item.textEdit }, cur_ctx.bufnr, "utf-16")

    local start = completion_item.textEdit.range.start
    if is_snippet then
        vim.api.nvim_win_set_cursor(0, { start.line + 1, start.character })
        config.snippet_expansion(snippet_text)
    else
        -- TODO: revert when https://github.com/neovim/neovim/issues/29811 if fixed
        local text_edit_lines = vim.split(completion_item.textEdit.newText, "\n")
        vim.api.nvim_win_set_cursor(0, {
            start.line + #text_edit_lines,
            #text_edit_lines == 1 and start.character + #completion_item.textEdit.newText
                or #text_edit_lines[#text_edit_lines],
        })
    end

    if completion_item.additionalTextEdits and #completion_item.additionalTextEdits > 0 then
        vim.lsp.util.apply_text_edits(completion_item.additionalTextEdits, cur_ctx.bufnr, "utf-16")
    end

    unblock()

    if completion_item.command then
        ---@diagnostic disable-next-line: param-type-mismatch
        vim.lsp.buf.execute_command(completion_item.command)
    end
end
