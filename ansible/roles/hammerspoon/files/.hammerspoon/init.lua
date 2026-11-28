local hyper = { "ctrl", "alt", "shift", "cmd" }

hs.hotkey.bind(hyper, "g", function()
    hs.application.launchOrFocus("Ghostty")
end)

hs.hotkey.bind(hyper, "b", function()
    hs.application.launchOrFocusByBundleID("com.brave.Browser")
end)

hs.hotkey.bind(hyper, "o", function()
    hs.application.launchOrFocusByBundleID("dev.kdrag0n.MacVirt")
end)

hs.hotkey.bind(hyper, "s", function()
    hs.application.launchOrFocusByBundleID("com.tinyspeck.slackmacgap")
end)

local function resizeWindow(offset, width)
    local win = hs.window.focusedWindow()
    if not win or not win:isStandard() or win:isFullScreen() then
        return
    end

    local frame = win:screen():frame()
    win:setFrame(hs.geometry.rect(
        frame.x + frame.w * offset, frame.y, frame.w * width, frame.h
    ), 0)
end

hs.hotkey.bind(hyper, "l", function() resizeWindow(0, 0.5) end)
hs.hotkey.bind(hyper, "r", function() resizeWindow(0.5, 0.5) end)
hs.hotkey.bind(hyper, "f", function() resizeWindow(0, 1) end)
