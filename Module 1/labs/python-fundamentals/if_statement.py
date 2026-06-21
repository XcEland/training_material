# Python Conditions and If statements

# Python supports the usual logical conditions from mathematics:

# Equals: a == b
# Not Equals: a != b
# Less than: a < b
# Less than or equal to: a <= b
# Greater than: a > b
# Greater than or equal to: a >= b
# These conditions can be used in several ways, most commonly in "if statements" and loops.

# An "if statement" is written by using the if keyword.
# Indentation: Python relies on indentation (whitespace at the beginning of a line) to define the scope of code blocks.

a = 33
b = 200
if b > a:
  print("b is greater than a")

is_logged_in = True
if is_logged_in:
  print("Welcome back!")


# Python Elif Statement
# The elif keyword is Python's way of saying "if the previous conditions were not true, then try this condition".

score = 75

if score >= 90:
  print("Grade: A")
elif score >= 80:
  print("Grade: B")
elif score >= 70:
  print("Grade: C")
elif score >= 60:
  print("Grade: D")

# Python Else Statement
# The else keyword catches anything which isn't caught by the preceding conditions.

a = 200
b = 33
if b > a:
  print("b is greater than a")
elif a == b:
  print("a and b are equal")
else:
  print("a is greater than b")

# Python Logical Operators
# Logical operators are used to combine conditional statements. Python has three logical operators:

# and - Returns True if both statements are true
# or - Returns True if one of the statements is true
# not - Reverses the result, returns False if the result is true

# The and Operator
a = 200
b = 33
c = 500
if a > b and c > a:
  print("Both conditions are True")

# The or Operator
a = 200
b = 33
c = 500
if a > b or a > c:
  print("At least one of the conditions is True")


# The not Operator
# The not keyword is a logical operator, and is used to reverse the result of the conditional statement.
a = 33
b = 200
if not a > b:
  print("a is NOT greater than b")


# Combining Multiple Operators
age = 25
is_student = False
has_discount_code = True

if (age < 18 or age > 65) and not is_student or has_discount_code:
  print("Discount applies!")


# Nested If Statements
# You can have if statements inside if statements
x = 41

if x > 10:
  print("Above ten,")
  if x > 20:
    print("and also above 20!")
  else:
    print("but not above 20.")