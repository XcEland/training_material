#python variables

# A variable can have a short name (like x and y) or a more descriptive name (age, carname, total_volume).

# Rules for Python variables:

# A variable name must start with a letter or the underscore character
# A variable name cannot start with a number
# A variable name can only contain alpha-numeric characters and underscores (A-z, 0-9, and _ )
# Variable names are case-sensitive (age, Age and AGE are three different variables)
# A variable name cannot be any of the Python keywords.

myvar = "John"
my_var = "John"
_my_var = "John"
myVar = "John"
MYVAR = "John"
myvar2 = "John"

# Camel Case: myVariableName = "John"
# Pascal Case: MyVariableName = "John"
# Snake Case: my_variable_name = "John"

# Variables are containers for storing data values.
# Creating Variables
# A variable is created the moment you first assign a value to it.
# Variables do not need to be declared with any particular type, and can even change type after they have been set.
# Variable names are case-sensitive.
a = 4
A = "Sally"

x = 5  # x is of type int
y = "John"  # y is of type str
print(x)
print(y)

# The print() function is often used to output variables.

# String variables can be declared either by using single or double quotes:
x = "John"
# is the same as
x = 'John'

# Get the Type
x = 5
y = "John"
print(type(x))
print(type(y))

# Assign Multiple Values
x, y, z = "Orange", "Banana", "Cherry"
print(x)
print(y)
print(z)

# Global Variables: Variables that are created outside of a function
x = "awesome"

def myfunc():
  x = "fantastic"
  print("Python is " + x)

myfunc()

print("Python is " + x)
