;;; dashboard.el --- A startup screen extracted from Spacemacs

;; Copyright (c) 2016 Rakan Al-Hneiti & Contributors
;;
;; Author: Rakan Al-Hneiti
;; URL: https://github.com/emacs-dashboard/emacs-dashboard
;;
;; This file is not part of GNU Emacs.
;;
;;; License: GPLv3
;;
;; Created: October 05, 2016
;; Modified: December 30, 2016
;; Version: 1.2.5
;; Keywords: startup screen tools
;; Package-Requires: ((emacs "24.4") (page-break-lines "0.11"))
;;; Commentary:

;; An extensible Emacs dashboard, with sections for
;; bookmarks, projectile projects, org-agenda and more.

;;; Code:

(require 'dashboard-widgets)

;; Custom splash screen
(defvar dashboard-mode-map
  (let ((map (make-sparse-keymap)))
    (define-key map (kbd "g") #'dashboard-refresh-buffer)
    map)
  "Keymap for dashboard mode.")

(define-derived-mode dashboard-mode special-mode "Dashboard"
  "Dashboard major mode for startup screen.
\\<dashboard-mode-map>
"
  :group 'dashboard
  :syntax-table nil
  :abbrev-table nil
  (whitespace-mode -1)
  (linum-mode -1)
  (overwrite-mode)
  (setq inhibit-startup-screen t)
  (setq buffer-read-only t
        truncate-lines t))

(defgroup dashboard nil
  "Extensible startup screen."
  :group 'applications)

(defcustom dashboard-center-content nil
  "Whether to center content within the window."
  :type 'boolean
  :group 'dashboard)

(defconst dashboard-buffer-name "*dashboard*"
  "Dashboard's buffer name.")

(defun draw-box (title top left width height)
  "Draw a box with TITLE starting at TOP LEFT with dimensions WIDTH x HEIGHT (in characters)."
  (goto-char (point-min))
  (forward-line top)
  (forward-char left)
  (insert "┌")
  (let* ((half (/ (- width 4 (length title)) 2.0))
        (l (floor half))
        (r (ceiling half)))
    (insert (make-string l ?─))
    (insert (propertize (format " %s " title) 'face 'dashboard-heading))
    (insert (make-string r ?─))
    (insert "┐")
    (newline))
  (dotimes (i (- height 2))
    (insert "│")
    (insert (make-string (- width 2) ?\ ))
    (insert "│")
    (newline))
  (insert "└")
  (insert (make-string (- width 2) ?─))
  (insert "┘"))

(defun dashboard-insert-startupify-lists ()
  "Insert the list of widgets into the buffer."
  (interactive)
  ;; (let ((buffer-exists (buffer-live-p (get-buffer dashboard-buffer-name)))
  ;;       (save-line nil)
  ;;       (recentf-is-on (recentf-enabled-p))
  ;;       (origial-recentf-list recentf-list)
  ;;       (dashboard-num-recents (or (cdr (assoc 'recents dashboard-items)) 0))
  ;;       (max-line-length 0))
  ;;   ;; disable recentf mode,
  ;;   ;; so we don't flood the recent files list with org mode files
  ;;   ;; do this by making a copy of the part of the list we'll use
  ;;   ;; let dashboard widgets change that
  ;;   ;; then restore the orginal list afterwards
  ;;   ;; (this avoids many saves/loads that would result from
  ;;   ;; disabling/enabling recentf-mode)
  ;;   (if recentf-is-on
  ;;       (setq recentf-list (seq-take recentf-list dashboard-num-recents))
  ;;     )
  ;;   (when (or (not (eq dashboard-buffer-last-width (window-width)))
  ;;             (not buffer-exists))
  ;;     (setq dashboard-banner-length (window-width)
  ;;           dashboard-buffer-last-width dashboard-banner-length)
  ;;     (with-current-buffer (get-buffer-create dashboard-buffer-name)
  ;;       (let ((buffer-read-only nil)
  ;;             (list-separator "\n\n"))
  ;;         (erase-buffer)
  ;;         (dashboard-insert-banner)
  ;;         (dashboard-insert-page-break)
  ;;         (setq dashboard--section-starts nil)
  ;;         (mapc (lambda (els)
  ;;                 (let* ((el (or (car-safe els) els))
  ;;                        (list-size
  ;;                         (or (cdr-safe els)
  ;;                             dashboard-items-default-length))
  ;;                        (item-generator
  ;;                         (cdr-safe (assoc el dashboard-item-generators))))
  ;;                   (add-to-list 'dashboard--section-starts (point))
  ;;                   (funcall item-generator list-size)
  ;;                   (setq max-line-length
  ;;                         (max max-line-length (dashboard-maximum-section-length)))
  ;;                   (dashboard-insert-page-break)))
  ;;               dashboard-items)
  ;;         (when dashboard-center-content
  ;;           (goto-char (car (last dashboard--section-starts)))
  ;;           (let ((margin (floor (/ (max (- (window-width) max-line-length) 0)  2))))
  ;;             (while (not (eobp))
  ;;               (and (not (eq ? (char-after)))
  ;;                    (insert (make-string margin ?\ )))
  ;;               (forward-line 1)))))
  ;;       (dashboard-mode)
  ;;       (goto-char (point-min))))
  ;;   (if recentf-is-on
  ;;       (setq recentf-list origial-recentf-list)))
  (with-current-buffer (get-buffer-create dashboard-buffer-name)
    (dashboard-mode)
    (let ((buffer-read-only nil))
      (draw-box "stuff" 0 0 30 30))))

(add-hook 'window-setup-hook
          (lambda ()
            (add-hook 'window-size-change-functions 'dashboard-resize-on-hook)
            (dashboard-resize-on-hook)))

(defun dashboard-refresh-buffer ()
  "Refresh buffer."
  (interactive)
  (kill-buffer dashboard-buffer-name)
  (dashboard-insert-startupify-lists)
  (switch-to-buffer dashboard-buffer-name))

(defun dashboard-resize-on-hook (&optional _)
  "Re-render dashboard on window size change."
  (let ((space-win (get-buffer-window dashboard-buffer-name))
        (frame-win (frame-selected-window)))
    (when (and space-win
               (not (window-minibuffer-p frame-win)))
      (with-selected-window space-win
        (dashboard-insert-startupify-lists)))))

;;;###autoload
(defun dashboard-setup-startup-hook ()
  "Setup post initialization hooks.
If a command line argument is provided,
assume a filename and skip displaying Dashboard."
  (if (< (length command-line-args) 2 )
      (progn
        (add-hook 'after-init-hook (lambda ()
                                     ;; Display useful lists of items
                                     (dashboard-insert-startupify-lists)))
        (add-hook 'emacs-startup-hook '(lambda ()
                                         (switch-to-buffer "*dashboard*")
                                         (goto-char (point-min))
                                         (redisplay))))))

(provide 'dashboard)
;;; dashboard.el ends here
