-- Convert an image into the form that we'll put on the Flash.

-- Basically, uses Floyd-Steinberg to reduce the colour to 6 bits, to
-- get an image we can display.
--
-- As input, it takes a file saved in Gimp's raw .data format (as I
-- couldn't find a low-dep image processing library for Lua), and
-- produces a file in the same format.

local width = 384
local height = 240

local colour_levels = 4

local in_file = "in.data"

local out_file = "out.data"

function read_pixel(fin)
  local pixel = fin:read(3)
  r = pixel:byte(1)
  g = pixel:byte(2)
  b = pixel:byte(3)
  return { r = r, g = g, b = b }
end

function write_pixel(fout, p)
  local data = string.char((p.r), (p.g), (p.b))
  fout:write(data)
end

-- Quantize one component
function adjust(x)
  local val = math.floor((x / 255) * colour_levels + 0.5)
  local target = math.floor((val / colour_levels) * 255 + 0.5)
  return target
end

-- Quantize a pixel
function quantize(p)
  return { r = adjust(p.r), g = adjust(p.g), b = adjust(p.b) }
end

-- Pixel maths!
local black = { r = 0.0, g = 0.0, b = 0.0 }

function add(p1, p2)
  return { r = p1.r + p2.r, g = p1.g + p2.g, b = p1.b + p2.b }
end

function mult(x, p)
  return { r = x * p.r, g = x * p.g, b = x * p.b }
end

function main(in_file, out_file)
  local fin = assert(io.open(in_file, "rb"))
  local fout = assert(io.open(out_file, "wb"))

  -- Initialise error diffuser thing
  local prev_line = {}
  for x = 1, width do
    prev_line[x] = black
  end

  for y = 1, height do
    local prev_pixel = black
    for x = 1, width do
      local pixel = read_pixel(fin)
      pixel = add(add(pixel, prev_line[x]), prev_pixel)
      local qpixel = quantize(pixel)
      local err = add(pixel, mult(-1, qpixel))
      local prev_pixel = mult(0.5, err)
      prev_line[x] = mult(0.5, err)
      write_pixel(fout, qpixel)
    end
  end

  assert(fin:close())
  assert(fout:close())
end

main(in_file, out_file)