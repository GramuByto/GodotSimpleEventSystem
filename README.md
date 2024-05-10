# SimpleEventSystem
An simple addon for Godot 4.0 (Work well with Godot 4.2)
Create sequences of events in nodes themselves.

---

# How to use
Add a child node and search for SimpleEventSystem (Simply searching 'event' will also work)
![image](https://github.com/GramuByto/GodotSimpleEventSystem/assets/64369270/3e878036-678f-4ca4-988a-80ec9e8788bf)

After adding a listener, assign the node where you want a function to be called and apply the values leading to that function
![image](https://github.com/GramuByto/GodotSimpleEventSystem/assets/64369270/c47a46e0-6812-4718-92f6-d45078471a24)

Arguments will show in the Args array variable and will change type if functions have static typing on their parameters.

---

# Limitations
Any changes in the Event System Node from the parent will not reflect properly on the child node. Worst, it could break the child node's Event System.
It can only currently apply static listeners and does not have dynamic listeners.
