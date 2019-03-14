DEBUG_MODE = true

function isInstrumentTrack(track)
    -- Iterate over all FX and look for FX names prefixed with
    -- "VSTi:".  We can't use TrackFX_GetInstrument because it skips
    -- offlined instruments.
    for fxIdx = 0, reaper.TrackFX_GetCount(track) - 1 do
        r, name = reaper.TrackFX_GetFXName(track, fxIdx, "")
        if string.sub(name, 0, 5) == "VSTi:" then
            return true
        end
    end
    return false
end

function getScore(track, term)
    local termPos = 1
    local lastMatchPos = 0
    local score = 0
    local match = false
    local instrument = isInstrumentTrack(track)
    local enabled = reaper.GetMediaTrackInfo_Value(track, "I_FXEN") > 0

    if term:sub(1, 1) == '/' then
        if not enabled then
            return 0
        end
        term = term:sub(2, #term)
    end

    if not instrument and INSTRUMENT_TRACKS_ONLY then
        return 0
    end

    local termCh = term:sub(termPos, termPos):lower()
    local name, flags = reaper.GetTrackState(track)
    visible = reaper.GetMediaTrackInfo_Value(track, "B_SHOWINTCP")
    if visible == 0 then
        return 0
    end

    for namePos = 1, #name do
        local nameCh = name:sub(namePos, namePos):lower()
        if nameCh == termCh then
            if lastMatchPos > 0 then
                local distance = namePos - lastMatchPos
                score = score + (100 - distance)
            end
            if termPos == #term then
                -- We have matched all characters in the term
                match = true
                break
            else
                lastMatchPos = namePos
                termPos = termPos + 1
                termCh = term:sub(termPos, termPos):lower()
            end
        end
    end
    if not match then
        return 0
    else
        -- Add 0.1 if this is an instrument track.
        if instrument then
            score = score + 0.1
        end
        -- Add another 0.1 if the track is enabled
        if reaper.GetMediaTrackInfo_Value(track, "I_FXEN") > 0 then
            score = score + 0.1
        end
        -- reaper.ShowConsoleMsg(name .. " -- " .. score .. "\n")
        return score
    end
end

function getBabyTracks()
  babyTracks = {}
  babyFXIds = {}
  for trackIdx = 0, reaper.CountTracks(0) - 1 do
        local track = reaper.GetTrack(0, trackIdx)
        -- TBD: Check if there is a track selected
        --local trackGUID = reaper.GetTrackGUID(track)                
        --if not (trackGUID == nil) then
          --local visible = reaper.IsTrackVisible(track,1)
          --log( trackIdx .. " visibility: " .. tostring(visible) )
          --local visibleStateKey = trackGUID .. "_VISIBLE_" .. tostring(NAV_DEPTH)
          --reaper.SetProjExtState(0, SCRIPT_NAME, visibleStateKey, tostring(visible))      
          
          --local trackName = reaper.GetMediaTrackInfo_Value(track, "P_NAME")  
         -- local trackName = reaper.GetSetMediaTrackInfo_String(track, "P_NAME", "", 0)
         -- local name, flags = reaper.GetTrackState(track)
          --log(name)
          
          --local score = getScore(track, "baby")
          --log("Name: " .. name .. ", Score: " .. score);
          --reaper.ShowConsoleMsg(name)
          for fxIdx = 0, reaper.TrackFX_GetCount(track) - 1 do
            retval, name = reaper.TrackFX_GetFXName(track, fxIdx,"")
            --log(name)
            --log("name: " .. name .. ", fxidx: " .. fxIdx)
            if string.find(name,'baby') then
              --log(tostring(track))
             -- table.insert
              table.insert(babyTracks, track)
            end
        end
  end
  --log(toString(babyTracks))
  return babyTracks
end


function log(msg)
  if(DEBUG_MODE) then
    
    local callingFunc = debug.getinfo(2).name
    if callingFunc == "" or callingFunc == nil then
      callingFunc = "Ext: "
    end
    reaper.ShowConsoleMsg(callingFunc .. ":: " .. msg .. "\n")
  end
end

  
function run()
  
  is_new,name,sec,cmd,rel,res,val = reaper.get_action_context()
    
  if is_new then
  
    --log("is new is true")
    babyTracks = getBabyTracks()
    for key in pairs(babyTracks) do
      local track = babyTracks[key]
      reaper.SetMediaTrackInfo_Value( track, 'I_RECINPUT', -1 )
      reaper.SetMediaTrackInfo_Value(track,"I_MIDIHWOUT", 0 | (0 << 5))
      if val == key then 
        --log("match")
        reaper.SetMediaTrackInfo_Value( track, 'I_RECINPUT', 4096 )
        reaper.SetMediaTrackInfo_Value( track, 'I_RECINPUT', 4096 | 0 | (0 << 5) )
        reaper.SetMediaTrackInfo_Value(track,"I_MIDIHWOUT", 0 | (2 << 5))
        reaper.TrackFX_SetParam(track, 2, 26, 1)
      end
    end
    --log("called");
    
   
   -- reaper.StuffMIDIMessage(1, 0x90, 100, 1)
    
    
  end
  reaper.defer(run)
end

function onexit()
  --log("finished")
end


--run()

reaper.defer(run)
reaper.atexit(onexit)



--log(reaper.GetSetMediaTrackInfo_String(reaper.GetSelectedTrack(0, 0), "P_NAME", "", 0))
