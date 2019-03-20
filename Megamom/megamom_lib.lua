DEBUG_MODE = false
SCRIPT_NAME = "megamom"
function log(msg)
  if(DEBUG_MODE) then
    
    local callingFunc = debug.getinfo(2).name
    if callingFunc == "" or callingFunc == nil then
      callingFunc = "Ext: " 
    end
    reaper.ShowConsoleMsg(callingFunc .. ":: " .. msg .. "\n")
  end
end

function getBabyTracks()
  local babyTracks = {}
  local babyFXIds = {}
  local inAdaptorFXIds = {}
  for trackIdx = 0, reaper.CountTracks(0) - 1 do
        local track = reaper.GetTrack(0, trackIdx)
       
          for fxIdx = 0, reaper.TrackFX_GetCount(track) - 1 do
            retval, name = reaper.TrackFX_GetFXName(track, fxIdx,"")
            --log(name)
            log("name: " .. name .. ", fxidx: " .. fxIdx)
            if string.find(name,'baby') then
              --log(tostring(track))
             -- table.insert
              table.insert(babyTracks, track)
              table.insert(babyFXIds, fxIdx) 
            end
            if string.find(name,'Input Adaptor') then
              log("input adaptor fx id: " .. fxIdx)
              table.insert(inAdaptorFXIds, fxIdx)
            end
        end
  end
  return babyTracks,babyFXIds,inAdaptorFXIds
end

function globalShiftStateCheck()
  for key in pairs(babyTracks) do
        local track = babyTracks[key]
        local inAdaptorFXId = inAdaptorFXIds[key]
        log("inAdaptorFXId: " .. inAdaptorFXId)
        retVal, maxVal, minVal = reaper.TrackFX_GetParam(track, inAdaptorFXId, 0)
        log("Retval: " .. retVal)
        if retVal == 1 then
          log("Shift is engaged")
          return true
        end
  end
  return false
end

function getProjStateVal(stateKey)
  meta = {}
  i = 0
  repeat
    local retval, key, val = reaper.EnumProjExtState( proj, SCRIPT_NAME, i )
    log(key .. ": " .. val ) 
    if(key == stateKey) then 
      return val
    end
    i = i + 1
  until not retval
end
  
function selectMBTtrack(trackNumber)
  
  log("-----------> Tracknumber: " .. TRACK_NUMBER)
  --is_new,name,sec,cmd,rel,res,val = reaper.get_action_context()
  --trackNumber = val 
  
  babyTracks,babyFXIds,inAdaptorFXIds = getBabyTracks()
  
  
  local isShiftEngaged = globalShiftStateCheck(babyTracks,inAdaptorFXIds)
  -- Don't activate track switching if shift is engaged, instead do nothing, as the 
  -- HW will be in track select mode for the right column  
  if isShiftEngaged == false then
    log("Shift not engaged");
    for key in pairs(babyTracks) do
      local track = babyTracks[key]
      local trackFXId = babyFXIds[key]
      reaper.SetMediaTrackInfo_Value( track, 'I_RECINPUT', -1 )
      reaper.SetMediaTrackInfo_Value(track,"I_MIDIHWOUT", 0 | (0 << 5))
      reaper.TrackFX_SetParam(track, trackFXId, 28, 0)
      if TRACK_NUMBER == key then 
        reaper.SetMediaTrackInfo_Value( track, 'I_RECINPUT', 4096 )
        -- APC
        --midiInputDeviceId = 2
        --midiOutputDeviceId = 3
        -- OSC
        --midiInputDeviceId = 0
        --midiOutputDeviceId = 2
        
        midiInputDeviceId = getProjStateVal("MIDI_IN_ID")
        midiOutputDeviceId = getProjStateVal("MIDI_OUT_ID")
        log("Midi in: " .. midiInputDeviceId)
        log("Midi out: " .. midiOutputDeviceId)
        
        reaper.SetMediaTrackInfo_Value( track, 'I_RECINPUT', 4096 | 0 | (midiInputDeviceId << 5) )
        reaper.SetMediaTrackInfo_Value(track,"I_MIDIHWOUT", 0 | (midiOutputDeviceId << 5))
        
        reaper.TrackFX_SetParam(track, trackFXId, 26, 1)
        reaper.TrackFX_SetParam(track, trackFXId, 28, 1)
               
      end
    end
  end
end

function onexit()
  log("finished")
end
