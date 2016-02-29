-- Convert an image into the form that we'll put on the Flash.

-- Basically, uses Floyd-Steinberg to reduce the colour to 6 bits, and
-- reduce the horizontal resolution by half, to get an image we can
-- display.
--
-- As input, it takes a file saved in Gimp's raw .data format (as I
-- couldn't find a low-dep image processing library for Lua), and
-- produces a file in the same format.

local width = 768
local height = 480

-- width must be am multiple of pixel_width
local pixel_width = 2
local colour_levels = 4

local in_file = "in.data"

local out_file = "out.data"

function read_pixel(fin)
  local r = 0
  local g = 0
  local b = 0
  for i = 1, pixel_width do
    local pixel = fin:read(3)
    r = r + pixel:byte(1)
    g = g + pixel:byte(2)
    b = b + pixel:byte(3)
  end
  return { r = r / pixel_width, g = g / pixel_width, b = b / pixel_width }
end

function write_pixel(fout, p)
  local data = string.char((p.r), (p.g), (p.b))
  for i = 1, pixel_width do
    fout:write(data)
  end
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

  local wide_pixels = width / pixel_width

  -- Initialise error diffuser thing
  local prev_line = {}
  for x = 1, wide_pixels do
    prev_line[x] = black
  end

  -- Fraction to diffuse horizontally
  local h_fract = 1 / (pixel_width + 1)
  -- And vertically
  local v_fract = 1 - h_fract

  for y = 1, height do
    local prev_pixel = black
    for x = 1, wide_pixels do
      local pixel = read_pixel(fin)
      pixel = add(add(pixel, prev_line[x]), prev_pixel)
      local qpixel = quantize(pixel)
      local err = add(pixel, mult(-1, qpixel))
      local prev_pixel = mult(h_fract, err)
      prev_line[x] = mult(v_fract, err)
      write_pixel(fout, qpixel)
    end
  end

  assert(fin:close())
  assert(fout:close())
end

main(in_file, out_file)