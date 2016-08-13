-- Compose a 4-channel RGBA raw image over a 3-channel RGB image,
-- generating a new 3-channel RGB image.

local in1_file
local in2_file
local out_file

do
    local i = 1
    while i <= #arg do
        if arg[i] == "-1" then
            i = i + 1
            in1_file = arg[i]
        elseif arg[i] == "-2" then
            i = i + 1
            in2_file = arg[i]
        elseif arg[i] == "-o" then
            i = i + 1
            out_file = arg[i]
        else
            print(arg[0] .. ": Unrecognised option: " .. arg[i])
            os.exit(1)
        end
        i = i + 1
    end
end

if in1_file == nil then
    print(arg[0] .. ": Overlay input filename required")
    os.exit(1)
end

if in2_file == nil then
    print(arg[0] .. ": Base input filename required")
    os.exit(1)
end

if out_file == nil then
    print(arg[0] .. ": Output filename required")
    os.exit(1)
end

------------------------------------------------------------------------
-- Do the work

function read_pixel_rgba(fin)
  local pixel = fin:read(4)
  if pixel == nil then
    return nil
  end
  r = pixel:byte(1)
  g = pixel:byte(2)
  b = pixel:byte(3)
  a = pixel:byte(4)
  return { r = r, g = g, b = b, a = a }
end

function read_pixel_rgb(fin)
  local pixel = fin:read(3)
  if pixel == nil then
    return nil
  end
  r = pixel:byte(1)
  g = pixel:byte(2)
  b = pixel:byte(3)
  return { r = r, g = g, b = b }
end

function write_pixel_rgb(fout, p)
  local data = string.char((p.r + 0.5), (p.g + 0.5), (p.b + 0.5))
  fout:write(data)
end

-- Pixel maths!

function overlay(p1, p2)
  local w1 = p1.a / 255
  local w2 = 1 - w1
  return { r = p1.r * w1 + p2.r * w2,
           g = p1.g * w1 + p2.g * w2,
           b = p1.b * w1 + p2.b * w2 }
end

function main(in_file, out_file)
  local fin1 = assert(io.open(in1_file, "rb"))
  local fin2 = assert(io.open(in2_file, "rb"))
  local fout = assert(io.open(out_file, "wb"))

  while true do
    local front = read_pixel_rgba(fin1)
    local base = read_pixel_rgb(fin2)
    if front == nil and base == nil then
      break
    end
    assert(front ~= nil and base ~= nil)
    write_pixel_rgb(fout, overlay(front, base))
  end

  assert(fin1:close())
  assert(fin2:close())
  assert(fout:close())
end

main(in_file, out_file)
