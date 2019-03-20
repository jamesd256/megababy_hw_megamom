function reaperDoFile(file) local info = debug.getinfo(1,'S'); script_path = info.source:match[[^@?(.*[\/])[^\/]-$]]; dofile(script_path .. file); end
reaperDoFile("megamom_lib.lua")

TRACK_NUMBER = 1
 
function runlocal()
  is_new,name,sec,cmd,rel,res,val = reaper.get_action_context()
  if is_new then
    selectMBTtrack(TRACK_NUMBER)
  end
  reaper.defer(runlocal)
end

log("TRACK : " .. TRACK_NUMBER)
reaper.defer(runlocal)
reaper.atexit(onexit)
