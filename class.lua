--[[

This is an OOP library that supports multiple inheritance and runtime
type-checking.  I wrote it in order to better understand how Lua works,
and because I wanted to use OOP in a couple of personal projects.

Override the default (empty) constructor by defining a member function
called "new" that takes any number of arguments; the first of which is
"self" or ignored.

Usage:

MyClass = class({ [members...] } [, base1, base2, ...])

Example:

Dog = class({
  height = 0,
  mass = 0
})

Fluffy = class({})

Collie = class({
  new = function(_, h, m)
    self.height = h
    self.mass = m
  end
}, Dog, Fluffy)

jake = Collie(10, 20)

assert(jake.height = 10 and jake.mass = 20)
assert(jake:is(Animal) and jake:is(Dog) and jake:is(Fluffy))

--------------------------------------------------------------------------------
MIT License

Copyright (c) 2020 Addison Schuhardt

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

  The above copyright notice and this permission notice shall be included in all
  copies or substantial portions of the Software.

  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
  SOFTWARE.

--]]

local current_class_id = 0

local function has_base(bases, class_id)
  for _, base in ipairs(bases) do
    if base.class_id ~= nil
      and (base.class_id == class_id or has_base(base.bases, class_id)) then
      return true
    end
  end

  return false
end

function class(members, ...)

  local bases = {...}

  -- set up inheritance
  if #bases == 1 then 

    -- single inheritance
    setmetatable(members, { __index = bases[1] })
  elseif #bases > 1 then

    -- multiple inheritance
    setmetatable(members, {
        __index = function(t, key)

          -- search for a member 'key' in any of the base classes
          for _, base in ipairs(bases) do
            if base[key] ~= nil then

              -- pull the inherited member down to this one in order
              -- to bypass __index the next time it's accessed 
              t[key] = base[key]

              return base[key]
            end
          end

          -- nothing found
          return nil
        end
    })
  end

  -- add type-checking plumbing
  if rawget(members, "is") == nil then
    current_class_id = current_class_id + 1
    members.class_id = current_class_id
    members.bases = bases
    members.is = function(self, t)
      local id = t.class_id
      return id ~= nil and (self.class_id == id or has_base(self.bases, id))
    end
  end

  -- set up the class prototype
  local impl = {}
  local mt = {
    __index = members,
    __call = function(cls, ...)
      local inst = {}
      setmetatable(inst, { __index = cls })

      -- if we are provided a constructor, call it
      if inst.new ~= nil then
        inst:new(...)
      end

      return inst
    end
  }

  setmetatable(impl, mt)

  return impl
end
