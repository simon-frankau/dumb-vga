-- Generates an animated spinning radial pattern useful for
-- psychodelic animation.

local width = 384
local height = 240

local c1 = { r = 244, g = 97, b = 27 }
local c2 = { r = 255, g = 235, b = 1 }
local num_rays = 15
local num_phases = 4

local out_file = "out%d.data"

function write_pixel(fout, p)
  local data = string.char((p.r), (p.g), (p.b))
  fout:write(data)
end

-- Interpolate between from and to, based on angle.
function wobble(angle, from, to)
  value = math.cos(angle * num_rays)
  -- Bunch the values up around the extremes by sqrting the abs value.
  if value < 0 then
    value = -math.sqrt(math.sqrt(-value))
  else
    value =  math.sqrt(math.sqrt(value))
  end
  -- Normalise 0..1
  value = value / 2.0 + 0.5
  -- And linear interpolate
  return from * (1 - value) + to * value
end

function main(out_file)
  for i = 1, num_phases do
    local file_name = out_file:format(i)
    local fout = assert(io.open(file_name, "wb"))

    for y = 1, height do
      for x = 1, width do
        angle = math.atan2(y - height / 2, x - width / 2)
        -- Fix NaN
        if angle ~= angle then angle = 0.0 end
        -- Add phase for animation
        angle = angle + 2 * math.pi * i / num_phases
        -- and colour pixel...
        pixel = {
          r = wobble(angle, 244, 255),
          g = wobble(angle, 97, 235),
          b = wobble(angle, 27, 1)
        }
        write_pixel(fout, pixel)
      end
    end

    assert(fout:close())
  end
end

main(out_file)
