--- === TheHitList ===
---
--- Show # of todos in The Hit List application

local THL = {
    --- TheHitList.tickRate
    --- Variable
    --- Show The Hit List prompt every X seconds, default 300
    tickRate = 300,
    --- TheHitList.duration
    --- Variable
    --- The Hit List prompt will be visible for Y seconds, default 5
    duration = 5,
    style = {
        strokeWidth  = 2,
        strokeColor = { white = 0, alpha = 1 },
        fillColor   = { white = 0, alpha = 0.8 },
        textColor = { white = 1, alpha = 1 },
        textFont  = ".AppleSystemUIFont",
        textSize  = 16,
        radius = 8,
        atScreenEdge = 1,
    }
}

--- TheHitList.openApp()
--- Method
--- Open The Hit List application
---
--- Parameters:
---  * None
---
--- Returns:
---  * None
THL.openApp = function()
    hs.osascript.applescript('tell application "The Hit List" to activate')
end

--- TheHitList.getSummary()
--- Method
--- summary of current THL status, either "X tasks / Y done" or "Working for ABC for X minutes"
---
--- Parameters:
---  * None
---
--- Returns:
---  * None
THL.getSummary = function()
    local a,b,c = hs.osascript.applescript([[tell application "The Hit List"
        set t to number of tasks in today list
        set c to count of tasks of group "Completed" of folders group
        set k to timing task
        if k is missing value then
            return {t, c}
        else
            set tn to title of k
            set ta to round (1 * (actual time of k))
            set te to round (1 * (estimated time of k))
            return {t, c, tn, ta, te}
        end if
    end tell]])
    local s = ""
    if b then
        if b[3] then
            s = "Working on " .. b[3] .. " for " .. math.floor(b[4] / 60) .. "m"
        else
            s = "Today: " .. b[1] .. " task(s) / " .. b[2] .. " done"
        end
    else 
        s = "THL not running"
    end
    return s
end

function THL:init()
    self.timer = nil
    self.watcher = hs.application.watcher.new(function(app,ev,obj) self:show() end)
end

--- TheHitList:start()
--- Method
--- The Hit List prompt will start to be visible every tickRate sec or app change
---
--- Parameters:
---  * None
---
--- Returns:
---  * None
function THL:start()
    self:stop()
    local me = self
    self.timer = hs.timer.doEvery(self.tickRate, function() me:show() end)
    self.watcher:start()
end

function THL:show()
    hs.alert.show(self.getSummary(), self.style, hs.screen.mainScreen(), self.duration)
end

--- TheHitList:stop()
--- Method
--- Stop The Hit List prompt automatically show up
---
--- Parameters:
---  * None
---
--- Returns:
---  * None
function THL:stop()
    if self.timer then
        self.timer:stop()
        self.timer = nil
        self.watcher:stop()
    end
end

return THL