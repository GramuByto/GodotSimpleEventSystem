# <img src="addons/simple_event_system/listener_icon.png" width="24" height="24"> SimpleEventSystem
An simple addon for Godot 4.0 (Tested with [Godot 4.4](https://godotengine.org/download/archive/4.4-stable/))

Create sequences of events in nodes themselves.

---

# How to use `SimpleEvent`
Add a child node and search for SimpleEvent (Searching `event` will also work). You can also instead attach the script on any existing nodes with empty scripts.

![image](https://github.com/user-attachments/assets/cfe8c29b-7b62-41c2-bada-9e99ebc47f53)

# Adding Events
Select the `Events` array and add a new element.

![image](https://github.com/user-attachments/assets/1024e85b-b087-4fad-944d-d3d38b338c9f)

You can reference any Nodes or Resources. It will show all the functions on that reference. Select the function

![image](https://github.com/user-attachments/assets/8b86031f-7776-4588-b5ba-40e54b18a1ae)

The arguments will show up once a function is selected. Select the `Args` array to edit the values (It is advisable to refrain from adding or deleting a new element). The types in the array will change if the functions have static typing as their parameter.

![image](https://github.com/user-attachments/assets/e60daf53-e5c5-4708-a9a3-9a203c840718)

Checking the `Is Dynamic` boolean will make the function dynamic and hide the `Args` array from the inspector. When the function is dynamic, it will take the value that is passed on the function or signal called.

![image](https://github.com/user-attachments/assets/dade42b8-fa3f-4b27-bb1d-564f746bc963)

# Calling Events
Invoking will call all of the events in order from top to bottom. You can call them through script by creating a variable exported as SimpleEvent. Using the `invoke()` function, you can pass all the values in the arguments should you wish to make use of dynamic functions.

![image](https://github.com/user-attachments/assets/7cced1e3-9ebd-45d5-bcd4-46a5c192101e)

To use signals instead, reference any Nodes or Resources from the inspector.

![image](https://github.com/user-attachments/assets/abd6edf3-3acc-4f33-b790-3273fdf8e744)

The list of signals will show up once a reference is assigned. Select the signal you wish to use for the events to be called.

![image](https://github.com/user-attachments/assets/47eef6a2-175e-4098-8824-c5800891365e)


---

# How to use `SimpleEvent` (Version 1.0)
This is an older iteration should the user wish to have one event per node (See `Limitations` to know why this might be preferred). The main difference is that adding one fuction will add one child node underneath the event node. This still exists in the 1.0 version on the branch which was tested in Godot `4.2` version.

![image](https://github.com/GramuByto/GodotSimpleEventSystem/assets/64369270/33180ca8-e3e8-43a5-90bd-0cf225601c1d)

Add a child node and search for SimpleEvent

![image](https://github.com/GramuByto/GodotSimpleEventSystem/assets/64369270/7a0d67f3-519c-4ce4-8917-a33468b5500b)

Add a function

![image](https://github.com/GramuByto/GodotSimpleEventSystem/assets/64369270/b095c879-a6a8-4f89-b7a3-fbf6905394bc)

Assign the node where you want a function to be called and apply the values leading to that function

![image](https://github.com/GramuByto/GodotSimpleEventSystem/assets/64369270/3f04e39b-307f-4506-b6c3-8542e1539d0b)

Running the function is the same as the new version


---

# Limitations
- Any changes in the Events array from the parent node will not reflect properly on the child node should another event is added/removed on the child node. If you accidentally did add/remove a new event, you can discard those changes to reapply the parent references.
- You cannot change the child node's argument values. Should you wish to, do not advised, go to the parent node and then to the resource category of the event you wish. Check the `Local to Scene` boolean and save the node. Should any changes happen on the child node, you will no longer be able to change the said event arguments of the parent node.
