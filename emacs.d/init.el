;; List of installed packages
(setq package-list
     '(autopair
	undo-tree
	company
	monokai-theme
	powerline
	nlinum
	))

;; List the repositories containing them
(setq package-archives '(("elpa" . "http://tromey.com/elpa/")
			 ("gnu" . "http://elpa.gnu.org/packages/")
			 ("marmalade" . "http://marmalade-repo.org/packages/")))

;; Activate all the packages
(package-initialize)

; Fetch the list of packages available
(unless package-archive-contents
  (package-refresh-contents))

; Install the missing packages
(dolist (package package-list)
  (unless (package-installed-p package)
    (package-install package)))

;; ----------------------------

;; Activate company-mode on startup
(add-hook 'after-init-hook 'global-company-mode)

;; Theme
(load-theme 'monokai t)

;; Don't show the startup screen
(setq inhibit-startup-screen t)

;; Change the cursor type to horizontal bar
(set-default 'cursor-type 'bar)

;; Disable menu bar
(menu-bar-mode 1)

;; Disable toolbar also
(tool-bar-mode -1)

;; Highlight matching parenthesis
(show-paren-mode)

;; Auto close pairs
(electric-pair-mode)

;; Show column number
(column-number-mode)

;; Highlight the current line
(global-hl-line-mode)

;; Change default framesize
(add-to-list 'default-frame-alist '(height . 30))
(add-to-list 'default-frame-alist '(width . 120))

;; Enable layout change or something...
(winner-mode t)

;; Enable window navigation shortcuts (C-c <arrow>)
(windmove-default-keybindings)

;; Turn on line number with package nlinum
(global-nlinum-mode t)

;; Remap command search shortcut key to active smex
(global-set-key (kbd "M-x") 'smex)

;; Undo-tree visualization
(undo-tree-mode)
(global-set-key (kbd "M-/") 'undo-tree-visualize)

;; Powerline for emacs
(powerline-default-theme)

;; Clean whitespace before save
(add-hook 'before-save-hook 'whitespace-cleanup)

;; Show whitespace
(global-whitespace-mode)

;; Auto generate stuff
(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(package-selected-packages
   (quote
    (powerline autopair undo-tree monokai-theme nlinum auto-complete smex))))

;; Auto generaete stuff
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )
