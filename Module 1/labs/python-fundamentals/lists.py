# List
# Lists are used to store multiple items in a single variable.
my_list = ["apple", "banana", "cherry"]
print(my_list)


# List items are ordered, changeable, and allow duplicate values.
# List items are indexed, the first item has index [0], the second item has index [1] etc.

# Access List Items: List items are indexed and you can access them by referring to the index number:

thislist = ["apple", "banana", "cherry", "orange", "kiwi", "melon", "mango"]
print(thislist[1])

# Range of Indexes: ou can specify a range of indexes by specifying where to start and where to end the range.
print(thislist[2:5])

# Change Item Values: To change the value of a specific item, refer to the index number:
thislist[1] = "blackcurrant"
print(thislist)

# Add List Items: To add an item to the end of the list, use the append() method:
thislist.append("orange")
print(thislist)

# Insert Items: To insert a list item at a specified index, use the insert() method.
thislist.insert(1, "watermelon")
print(thislist)

# Extend List: To append elements from another list to the current list, use the extend() method.
tropical = ["mango", "pineapple", "papaya"]
thislist.extend(tropical)
print(thislist)

# Remove Specified Item: The remove() method removes the specified item.
thislist.remove("banana")
print(thislist)

# Remove Specified Index: The pop() method removes the specified index, or the last item if index is not specified.
thislist.pop(1)
print(thislist)

# If you do not specify the index, the pop() method removes the last item.
thislist.pop()
print(thislist)


# Loop Through a List: You can loop through the list items by using a for loop:
thislist = ["apple", "banana", "cherry"]
for x in thislist:
  print(x)  


# Sort List Alphanumerically: List objects have a sort() method that will sort the list alphanumerically, ascending, by default:
thislist = ["orange", "mango", "kiwi", "pineapple", "banana"]
thislist.sort()
print(thislist)

thislist = [100, 50, 65, 82, 23]
thislist.sort()
print(thislist)

# Sort Descending: To sort descending, use the keyword argument reverse = True:
thislist = ["orange", "mango", "kiwi", "pineapple", "banana"]
thislist.sort(reverse = True)
print(thislist)

thislist = [100, 50, 65, 82, 23]
thislist.sort(reverse = True)
print(thislist)

# Join Two Lists: There are several ways to join, or concatenate, two or more lists in Python.
# One of the easiest ways are by using the + operator.
list1 = ["a", "b" , "c"]
list2 = [1, 2, 3]
list3 = list1 + list2
print(list3)    

# Another way to join two lists is by appending all the items from list2 into list1, one by one:
list1 = ["a", "b" , "c"]
list2 = [1, 2, 3]
for x in list2:
  list1.append(x)
print(list1)    
