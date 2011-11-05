;;; popup-frame.el --- Popup frame management

;; Copyright (C) 2011

;; Author:  <guillaume.papin@epitech.eu>
;; Keywords: convenience, frames

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <http://www.gnu.org/licenses/>.

;;; Commentary:

;; This file aimed to provide some utility functions for the
;; management of popup frames. A popup frame is a 'X Window' with no
;; decoration (no titlebar, not in the taskbar) that can be considered
;; as a subwindow for Emacs. It can be useful for example to create a
;; temporary completion UI.
;;
;; Currently it works only in a the 'x `window-system'. Contributions
;; are welcome mainly for the 'ns and 'w32 window systems.

;;; Usage example:

;; (let ((the-frame (popup-frame-create)))
;;   (popup-frame-show the-frame)
;;   (set-frame-position the-frame 200 200)
;;   (set-frame-size the-frame 80 24)
;;   (popup-frame-hide the-frame)
;;   (popup-frame-destroy the-frame))

;;; Code:

(eval-when-compile
  (require 'cl))

(defgroup popup-frame nil
  "Popup frame management."
  :version "23.3"
  :group 'frames)

(defcustom popup-frame-x-window-type
;; "_NET_WM_WINDOW_TYPE_DESKTOP"
;; "_NET_WM_WINDOW_TYPE_DOCK"
;; "_NET_WM_WINDOW_TYPE_TOOLBAR"
;; "_NET_WM_WINDOW_TYPE_MENU"
"_NET_WM_WINDOW_TYPE_UTILITY"
;; "_NET_WM_WINDOW_TYPE_SPLASH"
;; "_NET_WM_WINDOW_TYPE_DIALOG"
;; "_NET_WM_WINDOW_TYPE_DROPDOWN_MENU"
;; "_NET_WM_WINDOW_TYPE_POPUP_MENU"
;; "_NET_WM_WINDOW_TYPE_TOOLTIP"
;; "_NET_WM_WINDOW_TYPE_NOTIFICATION"
;; "_NET_WM_WINDOW_TYPE_COMBO"
;; "_NET_WM_WINDOW_TYPE_DND"
;; "_NET_WM_WINDOW_TYPE_NORMAL"
  "If non-nil the X window type to use when making a popup-frame.
This can property say to the window manager on how to handle the
window. For tiling window manager it can prevent the tiling for
example.

see: http://standards.freedesktop.org/wm-spec/wm-spec-latest.html#id2551529"
  :type 'string
  :group 'popup-frame)

(defun popup-frame/x-make-floating (&optional frame)
  "Try to force the window to be a floatting window for tiling
window manager who thinks it's a good idea to move/resize the
window."
  (when popup-frame-x-window-type
    (x-change-window-property "_NET_WM_WINDOW_TYPE"
                              (list popup-frame-x-window-type)
                              frame
                              "ATOM" 32 t)))

(defun popup-frame/x-skip-taskbar (&optional frame)
  (x-send-client-message frame 0 frame "_NET_WM_STATE" 32
	    		 '(2 "_NET_WM_STATE_SKIP_TASKBAR" 0)))

(defun* popup-frame-create (&key title name minibuffer scroll-bar)
  "Create a popup frame and return it.
The frame will not be displayed you should call
`popup-frame-show' for that.

If specified (see the corresponding frame parameters):
- :title will be the title of the frame
- :name will be the name of the frame
- :minibuffer if non-nil a minibuffer will be displayed (by
  default no minibuffer is created for the frame)
- :scroll-bar if non-nil can be set to 'left or 'right"
  (cond
   ((eq window-system 'x)
    (let ((after-make-frame-functions (cons 'popup-frame/x-make-floating
                                            after-make-frame-functions))
          (frame-param `((window-system           . x)
                         (minibuffer              . ,minibuffer)
                         ;; Without that the frame is tiled before the
                         ;; floating property is set
                         (visibility              . nil) ;invisible
                         (border-width            . 0)
                         (internal-border-width   . 0)
                         (menu-bar-lines          . nil) ;no menu-bar
                         (tool-bar-lines          . nil) ;no tool-bar
                         (left-fringe             . 0)   ;no fringes
                         (right-fringe            . 0))))
      (when title
        (setq frame-param `(title . ,title)))
      (when name
        (setq frame-param `(name . ,name)))
      (when scroll-bar
        (setq frame-param `(vertical-scroll-bars . ,scroll-bar)))
      (make-frame frame-param)))
   (t
    (error "couldn't create popup-frame: window system not supported"))))

(defalias 'popup-frame-destroy 'delete-frame)

(defun popup-frame-show (popup-frame)
  "Display a previously created popup frame."
    (make-frame-visible popup-frame)
    (cond
     ((eq window-system 'x)
      (popup-frame/x-skip-taskbar popup-frame))))

(defun popup-frame-hide (popup-frame)
  (make-frame-invisible popup-frame t))

(provide 'popup-frame)
;;; popup-frame.el ends here
