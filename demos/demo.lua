-- Color-scheme demo.
--
-- Just OPEN this file in Neovim with this config (no :luafile, no running it) --
-- the theme highlights it as you read, so you can eyeball every color.
--
-- PALETTE (name -> hex -> where it's used):
--   white       #ffffff   background
--   black       #000000   normal text
--   deep_blue   #00008b   identifiers (variables / functions)
--   dark_green  #006400   strings
--   medium_blue #0000cd   numbers, and the git-changed gutter sign
--   purple      #800080   constants / booleans
--   green       #008000   git-added gutter sign
--   red         #af0000   git-deleted gutter sign
--   light_blue  #cce6ff   cursor line (focused)
--   light_yellow #ffe680   search highlight
--   light_gray  #e4e4e4   cursor line (unfocused -- reserved for focus highlighting)
--   faint_gray  #d0d0d0   whitespace markers (tabs / trailing spaces)
--   gray        #808080   comments (like this line)
--   orange      #ff8800   cursor in the dark popups (Telescope prompt, Claude / LazyGit)
--   float_bg  #1e1e1e   LazyGit / Telescope background
--   float_fg  #d4d4d4   LazyGit / Telescope text
--
-- A colored swatch is shown at the end of each palette line above when you
-- open this file with the config (so every color is visible, not just the
-- syntax ones below).

-- Syntax sample -- each line shows a color from the palette above:

local greeting = "a string literal"      -- strings are dark green
local answer = 42                        -- numbers are medium blue
local pi = 3.14159                       -- floats too
local enabled = true                     -- booleans / constants are purple
local nothing = nil                      -- nil is a constant too

local function identifiers_are_deep_blue(name, count)
  return name .. tostring(count)
end

-- The next line is indented with a real tab and has trailing spaces; both
-- render in faint gray thanks to the whitespace markers:
	local tabbed = "spot the tab and the trailing spaces"    
-- Git-sign colors (green added / blue changed / red deleted) appear in the
-- gutter when this file is tracked by git and you edit it.
