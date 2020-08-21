# lua-oop
This is an OOP library that supports multiple inheritance and runtime
type-checking.  I wrote it in order to better understand how Lua works,
and because I wanted to use OOP in a couple of personal projects.

Override the default (empty) constructor by defining a member function    
called "new" that takes any number of arguments; the first of which is
"self" or ignored.
  
## Usage
      
`MyClass = class({ [members...] } [, base1, base2, ...])`
 
Example:

```lua
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
```
