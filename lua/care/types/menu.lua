--- This is the main class of the care completion menu. The menu is used to display
--- completion entries and also contains the logic for selecting and inserting the
--- completions.
---@class care.menu
--- Creates a new instance of the completion menu.
---@field new fun(): care.menu
--- Draws the menu. This includes formatting the entries with the function from the
--- config and setting the virtual text used to display the labels. It also adds the
--- highlights for the selected entry and for the matched chars.
---@field draw fun(self: care.menu): nil
--- This is a function which can be used to determine whether the completion menu is
--- open or not. This is especially useful for mappings which have a fallback action
--- when the menu isn't visible.
---@field is_open fun(self: care.menu): boolean
--- This function can be used to select the next entry. It accepts a count to skip
--- over some entries. It automatically wraps at the bottom and jumps up again.
---@field select_next fun(self: care.menu, count: integer): nil
--- This function is used to select the previous entry analogous to
--- [Select next](#select-next)
---@field select_prev fun(self: care.menu, count: integer): nil
--- The `open` function is used to open the completion menu with a specified set of
--- entries. This includes opening the window and displaying the text.
---@field open fun(self: care.menu, entries: care.entry[], offset: integer): nil
--- This function closes the menu and resets some internal things.
---@field close fun(self: care.menu): nil
--- With this function you can get the currently selected entry. This can be used
--- for the docs view or some other api functions. It is also used when the
--- selection is confirmed.
---@field get_active_entry fun(self: care.menu): care.entry?
--- This is the function to trigger the completion with a selected entry. It gets
--- the selected entry closes the menu and completes.
---@field confirm fun(self: care.menu): nil
--- This function completes with a given entry. That means it removes text used for
--- filtering (if necessary), expands snippet with the configured function, applies
--- text edits and lsp commands.
---@field complete fun(self: care.menu, entry: care.entry): nil
--- This function readjusts the size of the completion window without reopening it.
---@field readjust_win fun(self: care.menu, offset: integer): nil
--- Checks whether docs are visible or not
---@field docs_visible fun(self: care.menu): boolean
--- Scroll up or down in the docs window by `delta` lines.
---@field scroll_docs fun(self: care.menu, delta: integer): nil
--- Wrapper for utilities for the window of the menu
---@field menu_window care.window
--- Wrapper for utilities for the window of the docs
---@field docs_window care.window
--- The ghost text instance used to draw the ghost text.
---@field ghost_text care.ghost_text
--- This field is used to store all the entries of the completion menu.
---@field entries care.entry[]
--- The namespace is used to draw the extmarks and add the additional highlights.
---@field ns integer
--- In this field the user config is stored for easier access.
---@field config care.config
--- This is the buffer used for the menu. It's just created once when initially
--- creating a new instance.
---@field buf integer
--- The index is used to determine the selected entry. It is used to get this entry
--- when confirming the completion. The function to select the next and previous
--- entries simply change this index.
---@field index integer
--- This field is used to store the buffer for drawing the scrollbar.
---@field scrollbar_buf integer
--- This method is used for selection. It's called in `select_prev` and `select_next` and is responsible
--- for redrawing the menu, opening documentation and inserting the selected entry if required.
---@field select fun(self: care.menu): nil
