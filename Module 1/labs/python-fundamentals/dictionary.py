# Dictionary
# Dictionaries are used to store data values in key:value pairs.

# A dictionary is a collection which is ordered*, changeable and do not allow duplicates.

thisdict = {
  "brand": "Ford",
  "model": "Mustang",
  "year": 1964
}

# Dictionary Items
# Dictionary items are ordered, changeable, and do not allow duplicates.

# Dictionary items are presented in key:value pairs, and can be referred to by using the key name.

thisdict = {
  "brand": "Ford",
  "model": "Mustang",
  "year": 1964
}
print(thisdict["brand"])


# Dictionary Length
# To determine how many items a dictionary has, use the len() function.
thisdict = {
  "brand": "Ford",
  "model": "Mustang",
  "year": 1964
}           

print(len(thisdict))

# Dictionary Items - Data Types
# The values in dictionary items can be of any data type:

# Accessing Items: You can access the items of a dictionary by referring to its key name, inside square brackets:
thisdict = {
    "brand": "Ford",
    "model": "Mustang",
    "year": 1964
}
print(thisdict["brand"])
x = thisdict["model"]
print(x)

# Get Keys
# The keys() method will return a list of all the keys in the dictionary.
thisdict = {
  "brand": "Ford",
  "model": "Mustang",
  "year": 1964
}
x = thisdict.keys()
print(x)  #before the change

# Get Values
# The values() method will return a list of all the values in the dictionary.
car = {
  "brand": "Ford",
  "model": "Mustang",
  "year": 1964
}
x = car.values()
print(x)  #before the change

car["year"] = 2020

print(x) #after the change

# Change Values: You can change the value of a specific item by referring to its key name.
thisdict = {
  "brand": "Ford",
  "model": "Mustang",
  "year": 1964
}
thisdict["year"] = 2018

# Update Dictionary: The update() method will update the dictionary with the items from the given argument.
thisdict.update({"year": 2020})
print(thisdict)

# Adding Items: Adding an item to the dictionary is done by using a new index key and assigning a value to it.
thisdict = {
  "brand": "Ford",
  "model": "Mustang",
  "year": 1964
}
thisdict["color"] = "red"
print(thisdict) 

# Update Dictionary: The update() method will update the dictionary with the items from the given argument.
thisdict = {
  "brand": "Ford",
  "model": "Mustang",
  "year": 1964
}
thisdict.update({"color": "red"})


# Remove Dictionary Items: There are several methods to remove items from a dictionary:
# The pop() method removes the item with the specified key name:
thisdict = {
  "brand": "Ford",
  "model": "Mustang",
  "year": 1964
}
thisdict.pop("model")
print(thisdict)

# The popitem() method removes the last inserted item (in versions before 3.7, a random item is removed instead):
thisdict = {
  "brand": "Ford",
  "model": "Mustang",
  "year": 1964
}
thisdict.popitem()
print(thisdict)

# The del keyword removes the item with the specified key name:
thisdict = {
  "brand": "Ford",
  "model": "Mustang",
  "year": 1964
}
del thisdict["model"]
print(thisdict)

# The clear() method empties the dictionary:
thisdict = {
  "brand": "Ford",
  "model": "Mustang",
  "year": 1964
}
thisdict.clear()
print(thisdict)

# Loop Through a Dictionary
for x in thisdict:
  print(x)

# You can also use the values() method to return values of a dictionary:
for x in thisdict.values():
  print(x)

# You can use the keys() method to return the keys of a dictionary:
for x in thisdict.keys():
  print(x)

# Loop through both keys and values, by using the items() method:
for x, y in thisdict.items():
  print(x, y)

# Nested Dictionaries: A dictionary can contain dictionaries, this is called nested dictionaries.

myfamily = {
  "child1" : {
    "name" : "Emil",
    "year" : 2004
  },
  "child2" : {
    "name" : "Tobias",
    "year" : 2007
  },
  "child3" : {
    "name" : "Linus",
    "year" : 2011
  }
}

# Or, if you want to add three dictionaries into a new dictionary:
child1 = {
  "name" : "Emil",
  "year" : 2004
}
child2 = {
  "name" : "Tobias",
  "year" : 2007
}
child3 = {
  "name" : "Linus",
  "year" : 2011
}

myfamily = {
  "child1" : child1,
  "child2" : child2,
  "child3" : child3
}


# Access Items in Nested Dictionaries: To access items from a nested dictionary, you use the name of the dictionaries, starting with the outer dictionary:
print(myfamily["child2"]["name"])
