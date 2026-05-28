local M = {}

local top_prompt_cfg = {
    sorting_strategy = "ascending",
    layout_config = {
        prompt_position = "top",
    },
}

function M.with_top_prompt(opts)
    return vim.tbl_deep_extend("force", vim.deepcopy(top_prompt_cfg), opts or {})
end

return M
