# Python Functions

# A function is a block of code which only runs when it is called.
# A function can return data as a result.
# A function helps avoiding code repetition.
# Function names follow the same rules as variable names in Python

# Creating a Function
# In Python, a function is defined using the def keyword, followed by a function name and parentheses:
def my_function():
  print("Hello from a function")

# Calling a Function
# To call a function, write its name followed by parentheses:
def my_function():
  print("Hello from a function")

my_function()

# Return Values
# Functions can send data back to the code that called them using the return statement.
# When a function reaches a return statement, it stops executing and sends the result back:
def get_greeting():
  return "Hello from a function"

message = get_greeting()
print(message)


# Python Function Arguments
# Information can be passed into functions as arguments.
# Arguments are specified after the function name, inside the parentheses. You can add as many arguments as you want, just separate them with a comma.

def my_function(fname):
  print(fname + " Refsnes")

my_function("Emil")
my_function("Tobias")
my_function("Linus")

# Parameters vs Arguments
# The terms parameter and argument can be used for the same thing: information that are passed into a function.
# A parameter is the variable listed inside the parentheses in the function definition.
# An argument is the actual value that is sent to the function when it is called.

def my_function(name): # name is a parameter
  print("Hello", name)

my_function("Emil") # "Emil" is an argument



# Python Scope
# A variable is only available from inside the region it is created. This is called scope.

# Local Scope
# A variable created inside a function belongs to the local scope of that function, and can only be used inside that function.
def myfunc():
  x = 300
  print(x)

myfunc()

# Function Inside Function
# The local variable can be accessed from a function within the function
def myfunc():
  x = 300
  def myinnerfunc():
    print(x)
  myinnerfunc()

myfunc()