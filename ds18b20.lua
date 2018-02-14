local pin=3
local tbl = {}
temprtbl = {}
local count = 5

ow.setup(pin)
ow.reset(pin)
ow.write(pin, 0xCC, 1)	-- Address all sensors
ow.write(pin, 0x44, 1)	-- Start Temperature Conversion
repeat until (ow.read(pin) > 0)	-- read time slot and wait until Temperature Conversion is completed


tbl[1] = string.char(40)..string.char(21)..string.char(168)..string.char(138)..string.char(8)..string.char(0)..string.char(0)..string.char(68)  --sensor Out
tbl[2] = string.char(40)..string.char(57)..string.char(101)..string.char(139)..string.char(8)..string.char(0)..string.char(0)..string.char(206) --sensor Boiler 
tbl[3] = string.char(40)..string.char(230)..string.char(19)..string.char(138)..string.char(8)..string.char(0)..string.char(0)..string.char(80)  --sensor Loop
tbl[4] = string.char(40)..string.char(75)..string.char(199)..string.char(138)..string.char(8)..string.char(0)..string.char(0)..string.char(7)   --sensor Down
tbl[5] = string.char(40)..string.char(79)..string.char(48)..string.char(139)..string.char(8)..string.char(0)..string.char(0)..string.char(163)  --sensor UP

--Read Sensors
repeat
  local addr=tbl[count];
  local crc = ow.crc8(string.sub(addr,1,7))
  if (crc == addr:byte(8)) then
    if ((addr:byte(1) == 0x10) or (addr:byte(1) == 0x28)) then
--        print("Device is a DS18S20 or DS18B20 family device.")
          ow.reset(pin)
          ow.select(pin, addr)
          ow.write(pin,0xBE,1)	--Read Scratchpad 
          local data = nil
          data = string.char(ow.read(pin))
          for i = 1, 8 do
            data = data .. string.char(ow.read(pin))
          end
--          print(data:byte(1,9))
          crc = ow.crc8(string.sub(data,1,8))
           -- print("CRC="..crc)
          if (crc == data:byte(9)) then
             local t = (data:byte(1) + data:byte(2) * 256)
             -- handle negative temperatures			 
			 local sign = "+"
             if (t > 0x7fff) then
                t = t - 0x10000
				sign = "-"
				t = -1 * t
             end
			              -- Separate integral and decimal portions, for integer firmware only
			 local t1 = ""
			 local t2 = ""
             if (addr:byte(1) == 0x28) then
                t = t * 625  -- DS18B20, 4 fractional bits
				t1 = string.format("%04u", t / 100)
             else
                t = (t * 5000 -2500 + (data:byte(8)- data:byte(7)) /data:byte(8))/100 -- DS18S20, 1 fractional bit
				t1 = string.format("%02u", t / 100)
                t2 = string.format("%02u", t % 100)
             end
             local temp = sign .. t1 .. t2
             table.insert(temprtbl,temp)
--             print("Temperature "..count.." =" .. temp .. " Celsius")
             --print("\n\r")
          else
            table.insert(temprtbl,0)
          end      
			 tmr.wdclr()
    else
       --print("Device family is not recognized.")
    end
  else
     --print("CRC is not valid!")
  end
  count = count - 1
until(count == 0)

