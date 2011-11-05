Popup frame management
======================

This file aimed to provide some utility functions for the management
of popup frames. A popup frame is a 'X Window' with no decoration (no
titlebar, not in the taskbar) that can be considered as a subwindow
for Emacs. It can be useful for example to create a temporary
completion UI.

Currently it works only in a the X `window-system`. Contributions are
welcome mainly for the `'ns` and `'w32` window systems.

Usage example
-------------

~~~~~ lisp
  (let ((the-frame (popup-frame-create)))
    (popup-frame-show the-frame)
    (set-frame-position the-frame 200 200)
    (set-frame-size the-frame 80 24)
    (popup-frame-hide the-frame)
    (popup-frame-destroy the-frame))
~~~~~
