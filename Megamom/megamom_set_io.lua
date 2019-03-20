DEBUG_MODE = true
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

function strSplit(str, sep)
  j = 1
  vars = {}
  for tok in string.gmatch(str, "([^"..sep.."]+)") do
    vars[j] = tok
    j = j + 1
  end
  return vars
end

function listMidiDevices()
  moreInDevices = true
  nextInDeviceId = 0
  while(moreInDevices) do
    moreInDevices, namein = reaper.GetMIDIInputName(nextInDeviceId, "nameout")
    log("Input device - ID: " .. nextInDeviceId .. ", Name: " .. namein)
    nextInDeviceId = nextInDeviceId +1
  end
  moreOutDevices = true
  nextOutDeviceId = 0
  while(moreOutDevices) do
    moreOutDevices, nameout = reaper.GetMIDIOutputName(nextOutDeviceId, "nameout")
    log("Output device - ID: " .. nextOutDeviceId .. ", " .. nameout)
    nextOutDeviceId = nextOutDeviceId +1
  end
end

function getSetUserMidiIds()
  retval1, midiIOCSV = reaper.GetUserInputs("Supply midi device ids for Megamom", 2, "Midi input device,Midi output device","") 
  local midiIOArr= strSplit(midiIOCSV, ",")
  local midiInId= midiIOArr[1]
  local midiOutId = midiIOArr[2]
  log("Midi in: " .. midiInId)
  log("Midi out: " .. midiOutId)
   
  reaper.SetProjExtState(0, SCRIPT_NAME, "MIDI_IN_ID", midiInId)
  reaper.SetProjExtState(0, SCRIPT_NAME, "MIDI_OUT_ID", midiOutId)  
end

function main()
    listMidiDevices()
    getSetUserMidiIds() 
end

main()

--log(n);  
