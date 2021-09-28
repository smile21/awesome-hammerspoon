--- === UnsplashZ ===
---
--- Use unsplash images as wallpaper
---
--- Download: [https://github.com/Hammerspoon/Spoons/raw/master/Spoons/UnsplashZ.spoon.zip](https://github.com/Hammerspoon/Spoons/raw/master/Spoons/UnsplashZ.spoon.zip)
local obj = {}
obj.__index = obj

-- Metadata
obj.name = "UnsplashZ"
obj.version = "1.0"
obj.author = "ashfinal <ashfinal@gmail.com>"
obj.homepage = "https://github.com/Hammerspoon/Spoons"
obj.license = "MIT - https://opensource.org/licenses/MIT"
obj.interval = 3 * 60 * 60

local function unsplashRequest()
    local user_agent_str =
        "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_12_5) AppleWebKit/603.2.4 (KHTML, like Gecko) Version/10.1.1 Safari/603.2.4"
    obj.pic_url = hs.execute(
        [[ /usr/bin/curl 'https://source.unsplash.com/2560x1600/?wallpapers,desktop' |  perl -ne ' print "$1" if /href="([^"]+)"/ ' ]])
    if obj.pic_url == nil or obj.pic_url == '' then
        return
    end
    if obj.task then
        obj.task:terminate()
        obj.task = nil
    end
    local screens = hs.screen.allScreens()
    -- print(obj.pic_url)
    obj.localpath = os.getenv("HOME") .. "/.Trash/" .. hs.http.urlParts(obj.pic_url).lastPathComponent .. ".jpg"
    -- aria2c --enable-rpc=false https://images.unsplash.com/photo-1483510694115-9ba02b9f3eee -o a.jpg --dir=/tmp/
    obj.task = hs.task.new("/opt/homebrew/bin/aria2c", function(exitCode, stdOut, stdErr)
        if exitCode == 0 then
            obj.task = nil
            for k, v in pairs(screens) do
                screens[k]:desktopImageURL("file://" .. obj.localpath)
            end
            hs.notify.show(obj.name, "", "Done.")
        else
            print(stdOut, stdErr)
            hs.notify.show(obj.name, "", "Failed.")
        end
    end, {"--enable-rpc=false", "-d", os.getenv("HOME") .. "/.Trash", "-o",
          hs.http.urlParts(obj.pic_url).lastPathComponent .. ".jpg", "-s", "10", "-x", "10", "-j", "10", obj.pic_url})
    obj.task:start()
    hs.notify.show(obj.name, "", "Start download.")
end

function obj:init()
    if obj.timer == nil then
        obj.timer = hs.timer.doEvery(obj.interval, function()
            unsplashRequest()
        end)
        obj.timer:setNextTrigger(5)
    else
        obj.timer:setNextTrigger(obj.interval)
    end
    obj.timer:start()
end

function obj:refresh()
    obj.timer:fire()
    obj.timer:setNextTrigger(obj.interval)
end

return obj
