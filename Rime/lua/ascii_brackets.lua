-- ascii_brackets.lua
-- 英文模式（ascii_mode）或英文標點（ascii_punct）下，
-- 把 [ / ] 直接上屏為全角方括號 ［ / ］；
-- 中文模式不攔截，交給 punctuator 輸出【】。
--
-- 只在沒有組字時攔截，避免破壞 inline ASCII 的暫存輸入。

local function ascii_brackets(key, env)
  if key:release() then
    return
  end

  local ctx = env.engine.context
  local ascii_mode = ctx:get_option("ascii_mode")
  local ascii_punct = ctx:get_option("ascii_punct")

  if not (ascii_mode or ascii_punct) then
    return
  end
  if ctx:is_composing() then
    return
  end

  local repr = key:repr()
  if repr == "bracketleft" then
    env.engine:commit_text("［")
    return 1
  elseif repr == "bracketright" then
    env.engine:commit_text("］")
    return 1
  end
end

return ascii_brackets
