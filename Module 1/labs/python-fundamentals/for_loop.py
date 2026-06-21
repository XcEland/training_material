# Python For Loops
# A for loop is used for iterating over a sequence (that is either a list, a tuple, a dictionary, a set, or a string).

fruits = ["apple", "banana", "cherry"]
for x in fruits:
  print(x)

# Looping Through a String

for x in "banana":
  print(x)

# The break Statement
# With the break statement we can stop the loop before it has looped through all the items:
fruits = ["apple", "banana", "cherry"]
for x in fruits:
    print(x)
    if x == "banana":
        break