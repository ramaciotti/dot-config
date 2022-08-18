;;;; Straight

;; Bootstrap straight.el for package management
(defvar bootstrap-version)
(let ((bootstrap-file
       (expand-file-name "straight/repos/straight.el/bootstrap.el" user-emacs-directory))
      (bootstrap-version 5))
  (unless (file-exists-p bootstrap-file)
    (with-current-buffer
        (url-retrieve-synchronously
         "https://raw.githubusercontent.com/raxod502/straight.el/develop/install.el"
         'silent 'inhibit-cookies)
      (goto-char (point-max))
      (eval-print-last-sexp)))
  (load bootstrap-file nil 'nomessage))

;; Install use-package and set it to use straight by default.
(straight-use-package 'use-package)
(setq straight-use-package-by-default t)

;; By default, straight will try to update all packages on start.
;; Changing the variable below speeds up booting up Emacs.
(setq straight-check-for-modifications '(check-on-save find-when-checking))

;;;; Appearance

;; Set appearance constants
(defconst ars/light-theme 'modus-operandi)
(defconst ars/light-font "Noto Sans Mono")
(defconst ars/light-height 120)
(defconst ars/light-width 'condensed)

(defconst ars/dark-theme 'everforest-hard-dark)
(defconst ars/dark-font "Noto Sans Mono")
(defconst ars/dark-height 120)
(defconst ars/dark-width 'condensed)

;; Install themes
(use-package modus-themes
  :ensure
  :init (modus-themes-load-themes))

;; I can't get use-package/straight to build everforest, not sure
;; why. Let's use it just to download the repository, but let's
;; "build" it on our own.
(use-package everforest
  :straight
  (everforest :type git :repo "https://git.sr.ht/~theorytoe/everforest-theme" t nil)
  :init
  (add-to-list 'custom-theme-load-path "/Users/andre/.config/emacs/straight/repos/everforest")
  :config
  (provide 'everforest-theme))

(use-package gruvbox-theme)
(use-package dracula-theme)

;; Install kaolin-themes, make the theme change with the system (macos
;; only) and create a toggling binding.
(use-package kaolin-themes
  :after modus-themes gruvbox-theme dracula-theme
  :init
  (load-theme ars/dark-theme t)
  (set-face-attribute 'default nil
		      :font ars/dark-font
		      :height ars/dark-height
		      :weight 'normal
		      :width ars/dark-width)

  :config
  (defun ars/system-theme (appearance)
    "Load theme, taking current system APPEARANCE into consideration."
    (mapc #'disable-theme custom-enabled-themes)
    (pcase appearance
      ('light (load-theme ars/light-theme t)
	      (set-face-attribute 'default nil
				  :font ars/light-font
				  :height ars/light-height
				  :weight 'normal
				  :width ars/light-width))
      ('dark (load-theme ars/dark-theme t)
	     (set-face-attribute 'default nil
				 :font ars/dark-font
				 :height ars/dark-height
				 :weight 'normal
				 :width ars/dark-width))))

  (defun ars/toggle-theme ()
    (interactive)
    "Toggle between a light or a dark theme."
    (let ((enabled-themes custom-enabled-themes))
      (mapc #'disable-theme custom-enabled-themes)
      (if (member ars/light-theme enabled-themes)
	  (ars/system-theme 'dark)
	(ars/system-theme 'light))))

  (add-hook 'ns-system-appearance-change-functions #'ars/system-theme)

  :bind
  ("<f5>" . ars/toggle-theme))

;;;; Saner defaults

(setq inhibit-startup-message t)
(scroll-bar-mode -1)
(tool-bar-mode -1)
(set-fringe-mode 10)
(menu-bar-mode 1)
(setq visible-bell t)
(add-hook 'after-init-hook #'global-display-line-numbers-mode)
(setq frame-resize-pixelwise t)

;; Enable auto-revert mode
(setq auto-revert-verbose t)
(add-hook 'after-init-hook #'global-auto-revert-mode)

;; Remove whitespace when saving files
(setq delete-trailing-lines t)
(add-hook 'before-save-hook 'delete-trailing-whitespace)

;; Supress native compilation warnings
(setq warning-suppress-types '((comp)))

;; Uniquify buffer names
(setq uniquify-buffer-name-style 'forward)
(setq uniquify-strip-common-suffix t)
(setq uniquify-after-kill-buffer-p t)

;; Minibuffer history
(setq savehist-file (locate-user-emacs-file "savehist"))
(setq history-length 10000)
(setq history-delete-duplicates t)
(setq savehist-save-minubuffer-history t)
(add-hook 'after-init-hook #'savehist-mode)

;; Backup files
(setq backup-directory-alist
      `(("." . ,(concat user-emacs-directory "backup/"))))
(setq backup-by-copying t)
(setq version-control t)
(setq delete-old-versions t)
(setq kept-new-versions 6)
(setq kept-old-versions 2)
(setq create-lockfiles nil)

;; Enable upcase- (C-x C-u) and downcase-region (C-x C-l)
(put 'upcase-region 'disabled nil)
(put 'downcase-region 'disabled nil)

;; Do not add encoding comment to Ruby files
(setq ruby-insert-encoding-magic-comment nil)

;; Add keybinding to browse URL under point/mouse
(global-set-key (kbd "C-c b") 'browse-url-at-point)
(global-set-key [s-mouse-1] 'browse-url-at-mouse)

;;;; Packages

;;; Emacs

(use-package exec-path-from-shell
  :config
  (when (memq window-system '(mac ns x))
    (exec-path-from-shell-initialize)))

(use-package rg)
(use-package multi-term)

(use-package helm
  :config
  (global-set-key (kbd "M-x") #'helm-M-x)
  (global-set-key (kbd "C-x C-f") #'helm-find-files)

  (helm-mode 1))

(use-package avy
  :config
  (global-set-key (kbd "C-c SPC") 'avy-goto-char-timer)
  (global-set-key (kbd "C-c C-SPC") 'avy-goto-char-timer))

;;; Editing

(use-package editorconfig
  :ensure t
  :config
  (editorconfig-mode 1))

(use-package tree-sitter)
(use-package tree-sitter-langs
  :after tree-sitter
  :init
  (require 'tree-sitter)
  (require 'tree-sitter-langs)
  :hook (after-init . global-tree-sitter-mode))

(use-package rainbow-delimiters
  :hook (prog-mode . rainbow-delimiters-mode))

(use-package rainbow-mode
  :hook prog-mode)

(use-package hl-todo
  :hook (after-init . global-hl-todo-mode))

(use-package smartparens
  :config
  (require 'smartparens-config)
  :hook (after-init . smartparens-global-strict-mode))

(use-package company
  :config
  (setq company-dabbrev-downcase nil)
  (setq company-idle-delay 0.5)
  :hook (after-init . global-company-mode))

;;; Project management

(use-package projectile
  :config
  (projectile-mode 1)
  (define-key projectile-mode-map (kbd "C-c p") 'projectile-command-map))

;;; Version Control

(use-package magit
  :ensure t)

(use-package forge
  :after magit)

(use-package git-gutter
  :hook ((prog-mode text-mode) . git-gutter-mode))

(use-package git-gutter-fringe
  :diminish git-gutter-mode
  :after git-gutter
  :demand fringe-helper
  :config
  ;; subtle diff indicators in the fringe
  ;; places the git gutter outside the margins.
  (setq-default fringes-outside-margins t)
  ;; thin fringe bitmaps
  (define-fringe-bitmap 'git-gutter-fr:added
  [224 224 224 224 224 224 224 224 224 224 224 224 224 224 224 224 224 224 224 224 224 224 224 224 224]
  nil nil 'center)
  (define-fringe-bitmap 'git-gutter-fr:modified
  [224 224 224 224 224 224 224 224 224 224 224 224 224 224 224 224 224 224 224 224 224 224 224 224 224]
  nil nil 'center)
  (define-fringe-bitmap 'git-gutter-fr:deleted
  [0 0 0 0 0 0 0 0 0 0 0 0 0 128 192 224 240 248]
  nil nil 'center))

(use-package git-link
  :config
  (global-set-key (kbd "C-c g l") 'git-link))

(use-package git-timemachine
  :config
  (global-set-key (kbd "C-c g t") 'git-timemachine))

; (use-package gitignore-mode)

;;; Programming Languages

(use-package csv-mode)
(use-package lua-mode)
(use-package markdown-mode)
(use-package yaml-mode)

(use-package clojure-mode)
(use-package cider
  :after clojure-mode)

;;; Appearance

(use-package telephone-line
  :config
  (require 'telephone-line)
  (telephone-line-mode 1))

;; Make the background color of file-buffers different from other buffers.
(use-package solaire-mode
  :hook (after-init . solaire-global-mode))

;;;; Custom functions
;; Most of these functions have been graciously provided by either
;; Laura Viglioni (https://github.com/Viglioni) and Sandro
;; Luiz (https://github.com/ansdor).

(defun ars/previous-files ()
  "Returns a list of buffers visiting files skipping the current one."
  (seq-filter 'buffer-file-name
	      (remq (current-buffer) (buffer-list))))

(defun ars/shift-list (list)
  "Returns a new list with the same elements of LIST shifted one position to the left.
I.e. (ars/shift-list '(a b c d)) returns '(b c d a)."
  (let ((reversed (reverse list)))
    (reverse (cons (car list)
		   (butlast reversed)))))

(defun ars/unshift-list (list)
  "Returns a new list with the same elements of LIST shifted one position to the right.
I.e. (ars/unshift-list '(a b c d)) returns '(d a b c)."
  (append (last list) (butlast list)))

(defun ars/rotate-list (list direction)
  "Returns a new list with the same elements of LIST shifted one
position to the right or to the left depending on the value of
DIRECTION (which must be either 'cw or 'ccw)."
  (if (eq direction 'cw)
      (ars/shift-list list)
    (ars/unshift-list list)))

(defun ars/shift-buffers (direction)
  "Rotates the currently open buffers between the windows of the
current frame. DIRECTION must be either 'cw or 'ccw."
  (let* ((buffers (mapcar #'window-buffer (window-list)))
	 (rotated-buffers (ars/rotate-list buffers direction)))
    (mapc (lambda (window)
	    (let ((window-index (seq-position (window-list) window)))
	      (set-window-buffer window (nth window-index rotated-buffers))))
	  (window-list))))

(defun ars/shift-buffers-cw ()
  "Rotates the currently open buffers between the windows of the
current frame in a clockwise direction."
  (interactive)
  (ars/shift-buffers 'cw))

(defun ars/shift-buffers-ccw ()
  "Rotates the currently open buffers between the windows of the
current frame in a counterclockwise direction."
  (interactive)
  (ars/shift-buffers 'ccw))

(defun ars/split-window-double-columns ()
  "Set the current frame layout to two columns."
  (interactive)
  (let ((previous-file (or (car (ars/previous-files))
			   (current-buffer))))
    (delete-other-windows)
    (set-window-buffer (split-window-right) previous-file)
    (balance-windows)))

(defun ars/split-window-triple-columns ()
  "Set the current frame layout to three columns."
  (interactive)
  (delete-other-windows)
  (let* ((previous-files (ars/previous-files))
	 (second-buffer (or (nth 0 previous-files) (current-buffer)))
	 (third-buffer (or (nth 1 previous-files) (current-buffer)))
	 (second-window (split-window-right))
	 (third-window (split-window second-window nil 'right)))
    (set-window-buffer second-window second-buffer)
    (set-window-buffer third-window third-buffer))
  (balance-windows))

(defun ars/split-window-quadruple-columns ()
  "Set the current frame layout to quadruple columns."
  (interactive)
  (delete-other-windows)
  (let* ((previous-files (ars/previous-files))
	 (second-buffer (or (nth 0 previous-files) (current-buffer)))
	 (third-buffer (or (nth 1 previous-files) (current-buffer)))
	 (fourth-buffer (or (nth 2 previous-files) (current-buffer)))
	 (second-window (split-window-right))
	 (third-window (split-window second-window nil 'right))
	 (fourth-window (split-window third-window nil 'right)))
    (set-window-buffer second-window second-buffer)
    (set-window-buffer third-window third-buffer)
    (set-window-buffer fourth-window fourth-buffer))
  (balance-windows))

(defun ars/split-window-two-by-two-grid ()
  "Set the current frame layout to a two-by-two grid."
  (interactive)
  (delete-other-windows)
  (let* ((previous-files (ars/previous-files))
	 (second-buffer (or (nth 0 previous-files) (current-buffer)))
	 (third-buffer (or (nth 1 previous-files) (current-buffer)))
	 (fourth-buffer (or (nth 2 previous-files) (current-buffer)))
	 (second-window (split-window-right))
	 (third-window (split-window-below))
	 (fourth-window (split-window second-window nil 'below)))
    (set-window-buffer second-window second-buffer)
    (set-window-buffer third-window third-buffer)
    (set-window-buffer fourth-window fourth-buffer))
  (balance-windows))

(defun ars/switch-to-previous-file ()
  "Switch to the most recently used file."
  (interactive)
  (switch-to-buffer (or (car (ars/previous-files))
			(current-buffer))))

(global-set-key (kbd "C-c w s") 'ars/shift-buffers-cw)
(global-set-key (kbd "C-c w u") 'ars/shift-buffers-ccw)
(global-set-key (kbd "C-c w w") 'ars/switch-to-previous-file)
(global-set-key (kbd "C-c w 1") 'delete-other-windows) ; just for consistency's sake
(global-set-key (kbd "C-c w 2") 'ars/split-window-double-columns)
(global-set-key (kbd "C-c w 3") 'ars/split-window-triple-columns)
(global-set-key (kbd "C-c w 4") 'ars/split-window-quadruple-columns)
(global-set-key (kbd "C-c w x") 'ars/split-window-two-by-two-grid)

(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(warning-suppress-types '((use-package) (comp))))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )
