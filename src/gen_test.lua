-- Generate an EEPROM image suitable for display on VGA

local h_front_porch = 16
local h_sync = 64
local h_back_porch = 48
local h_visible = 384

local v_front_porch = 1
local v_sync =  1
local v_back_porch = 14
local v_visible = 240

local rom_size = 512 * 1024

local out_file = "vga.bin"

local h_total = h_front_porch + h_sync + h_back_porch + h_visible
print ("Total horizontal resolution: " .. h_total)

local v_total = v_front_porch + v_sync + v_back_porch + v_visible
print ("Total vertical resolution: " .. v_total)

local total = h_total * v_total
print ("Total data: " .. total)

if rom_size % total ~= 0 then
  print ("ROM size (" .. rom_size .. ")is not a multiple of image size (" ..
    total .. ")")
  os.exit(1)
end

local repeats = rom_size / total

local v_sync_val = 0x80
local h_sync_val = 0x40

function pixel_at(x, y)
  -- x value controls bottom two bits
  local low = math.floor((x - 1) * 4 / h_visible)
  -- y value controls next 4 bits
  local high = math.floor((y - 1) * 16 / v_visible)
  return high * 4 + low
end

function write_byte(out, b)
  out:write(string.char(b))
end

function write_line(out, mode, line_num)
  local base_val = mode == "sync" and v_sync_val or 0x00

  for i = 1, h_sync do
    write_byte(out, base_val + h_sync_val)
  end
  for i = 1, h_back_porch do
    write_byte(out, base_val)
  end
  for i = 1, h_visible do
    local val = mode == "visible" and pixel_at(i, line_num) or 0
    write_byte(out, base_val + val)
  end
  for i = 1, h_front_porch do
    write_byte(out, base_val)
  end
end

function write_frame(out)
  for i = 1, v_sync do
    write_line(out, "sync", i)
  end
  for i = 1, v_back_porch do
    write_line(out, "blank", i)
  end
  for i = 1, v_visible do
    write_line(out, "visible", i)
  end
  for i = 1, v_front_porch do
    write_line(out, "blank", i)
  end
end

function main(filename)
  local out = assert(io.open(out_file, "wb"))

  for r = 1, repeats do
    write_frame(out)
  end

  assert(out:close())
end

main(out_file)
