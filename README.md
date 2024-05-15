# SimpleEventSystem
An simple addon for Godot 4.0 (Work well with Godot 4.2)

Create sequences of events in nodes themselves.

---

# How to use (SimpleEventSystem)
Add a child node and search for SimpleEventSystem (Simply searching 'event' will also work)

![image](https://github.com/GramuByto/GodotSimpleEventSystem/assets/64369270/3e878036-678f-4ca4-988a-80ec9e8788bf)

After adding a callable, assign the node where you want a function to be called and apply the values leading to that function. Arguments will show in the Args array variable and will change type if functions have static typing on their parameters.

![image](https://github.com/GramuByto/GodotSimpleEventSystem/assets/64369270/c47a46e0-6812-4718-92f6-d45078471a24)

Export the variable with a static type of SimpleEventSystem. Call the invoke function to call all the callables.

![image](https://github.com/GramuByto/GodotSimpleEventSystem/assets/64369270/78c84be6-7fe1-4168-a410-491afe476edf)

---

# How to use (SimpleEvent)
This is an older iteration but it still works. The main difference is that adding one fuction will add one child node underneath the event node

![image](https://github.com/GramuByto/GodotSimpleEventSystem/assets/64369270/33180ca8-e3e8-43a5-90bd-0cf225601c1d)

Add a child node and search for SimpleEvent

![image](https://github.com/GramuByto/GodotSimpleEventSystem/assets/64369270/7a0d67f3-519c-4ce4-8917-a33468b5500b)

Add a function

![image](https://github.com/GramuByto/GodotSimpleEventSystem/assets/64369270/b095c879-a6a8-4f89-b7a3-fbf6905394bc)

Assign the node where you want a function to be called and apply the values leading to that function

![image](https://github.com/GramuByto/GodotSimpleEventSystem/assets/64369270/3f04e39b-307f-4506-b6c3-8542e1539d0b)

To run the functions, it's similar to the SimpleEventSystem but change the static type to SimpleEvent

---

# Limitations
Any changes  in the Event System Node, using the SimpleEventSystem node and note the SimpleEvent node, from the parent will not reflect properly on the child node. Worst, it could break the child node's Event System.

It can only currently apply static callables and does not have dynamic callables.
