-- TNS|ELRS Loan|TNE
local function isConnected()
    crossfireTelemetryPush(0x2D, { 0xEE, 0xEF, 0x00, 0x00 }) 

    -- Poll for up to 0.1s for a elrs TX state response
    local start = getTime()
    while getTime() - start < 10 do
        local command, data = crossfireTelemetryPop()
        if command == 0x2E then
            -- IsConnected is the low bit of the flags byte
            return data[2] == 0xEE and bit32.btest(data[6], 1)
        end
    end
end

local function run(event)
    local CRSF_FRAMETYPE_COMMAND = 0x32
    local CRSF_ADDRESS_RADIO_TRANSMITTER = 0xEA
    local CRSF_ADDRESS_CRSF_RECEIVER = 0xEC
    local CRSF_ADDRESS_CRSF_TRANSMITTER = 0xEE
    local CRSF_COMMAND_SUBCMD_RX = 0x10
    local CRSF_COMMAND_SUBCMD_RX_BIND = 0x01

	local dest = isConnected() and CRSF_ADDRESS_CRSF_RECEIVER or CRSF_ADDRESS_CRSF_TRANSMITTER
	crossfireTelemetryPush(CRSF_FRAMETYPE_COMMAND,
		{ dest, CRSF_ADDRESS_RADIO_TRANSMITTER, CRSF_COMMAND_SUBCMD_RX, CRSF_COMMAND_SUBCMD_RX_BIND }
	)
	return 1
end

return { run = run }
  