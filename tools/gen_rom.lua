-- Generate a ROM file from a .data file.
--
-- Processes a Gimp raw .data file into a ROM image. Assumes all the
-- dithering etc. has been done already (e.g. by prep_img.lua).
--
-- Note that this only generates one frame, but you can concatenate
-- two frames to fill a 512KB device.

local h_front_porch = 16
local h_sync = 64
local h_back_porch = 48
local h_visible = 384

local v_front_porch = 1
local v_sync =  1
local v_back_porch = 14
local v_visible = 240

------------------------------------------------------------------------
-- Argument reading

local in_file
local out_file

do
    local i = 1
    while i <= #arg do
        if arg[i] == "-i" then
            i = i + 1
            in_file = arg[i]
        elseif arg[i] == "-o" then
            i = i + 1
            out_file = arg[i]
        elseif arg[i] == "-w" then
            i = i + 1
            width = arg[i]
        elseif arg[i] == "-h" then
            i = i + 1
            height = arg[i]
        elseif arg[i] == "-c" then
            i = i + 1
            colour_levels = arg[i]
        else
            print(arg[0] .. ": Unrecognised option: " .. arg[i])
            os.exit(1)
        end
        i = i + 1
    end
end

if in_file == nil then
    print(arg[0] .. ": Input filename required")
    os.exit(1)
end

if out_file == nil then
    print(arg[0] .. ": Output filename required")
    os.exit(1)
end

------------------------------------------------------------------------
-- Image reading part
--

local data = {}

function read_pixel(f, x, y)
  local pixel = f:read(3)
  r = pixel:byte(1)
  g = pixel:byte(2)
  b = pixel:byte(3)
  r = math.floor(r + 0.5)
  g = math.floor(g + 0.5)
  b = math.floor(b + 0.5)
  -- Extract top two bits.
  r = math.floor(r / 64) % 4
  g = math.floor(g / 64) % 4
  b = math.floor(b / 64) % 4
  -- Assemble and store the value
  data[y][x] = (r * 16 + g * 4 + b) * 4
end

function read_image(f)
  for y = 1, v_visible do
    data[y] = {}
    for x = 1, h_visible do
      read_pixel(f, x, y)
    end
  end
end

------------------------------------------------------------------------
-- ROM writing part
--

local v_sync_val = 0x02
local h_sync_val = 0x01

function pixel_at(x, y)
  return data[y][x]
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

------------------------------------------------------------------------
-- Put it all together...
--

function main(filename)
  local fin = assert(io.open(in_file, "rb"))
  read_image(fin)
  assert(fin:close())

  local fout = assert(io.open(out_file, "wb"))
  write_frame(fout)
  assert(fout:close())
end

main(in_file, out_file)
