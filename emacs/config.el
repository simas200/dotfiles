(defvar elpaca-installer-version 0.4)
(defvar elpaca-directory (expand-file-name "elpaca/" user-emacs-directory))
(defvar elpaca-builds-directory (expand-file-name "builds/" elpaca-directory))
(defvar elpaca-repos-directory (expand-file-name "repos/" elpaca-directory))
(defvar elpaca-order '(elpaca :repo "https://github.com/progfolio/elpaca.git"
			      :ref nil
			      :files (:defaults (:exclude "extensions"))
			      :build (:not elpaca--activate-package)))
(let* ((repo  (expand-file-name "elpaca/" elpaca-repos-directory))
       (build (expand-file-name "elpaca/" elpaca-builds-directory))
       (order (cdr elpaca-order))
       (default-directory repo))
  (add-to-list 'load-path (if (file-exists-p build) build repo))
  (unless (file-exists-p repo)
    (make-directory repo t)
    (when (< emacs-major-version 28) (require 'subr-x))
    (condition-case-unless-debug err
	(if-let ((buffer (pop-to-buffer-same-window "*elpaca-bootstrap*"))
		 ((zerop (call-process "git" nil buffer t "clone"
				       (plist-get order :repo) repo)))
		 ((zerop (call-process "git" nil buffer t "checkout"
				       (or (plist-get order :ref) "--"))))
		 (emacs (concat invocation-directory invocation-name))
		 ((zerop (call-process emacs nil buffer nil "-Q" "-L" "." "--batch"
				       "--eval" "(byte-recompile-directory \".\" 0 'force)")))
		 ((require 'elpaca))
		 ((elpaca-generate-autoloads "elpaca" repo)))
	    (kill-buffer buffer)
	  (error "%s" (with-current-buffer buffer (buffer-string))))
      ((error) (warn "%s" err) (delete-directory repo 'recursive))))
  (unless (require 'elpaca-autoloads nil t)
    (require 'elpaca)
    (elpaca-generate-autoloads "elpaca" repo)
    (load "./elpaca-autoloads")))
(add-hook 'after-init-hook #'elpaca-process-queues)
(elpaca `(,@elpaca-order))

;; Install use-package support
(elpaca elpaca-use-package
  ;; Enable :elpaca use-package keyword.
  (elpaca-use-package-mode)
  ;; Assume :elpaca t unless otherwise specified.
  (setq elpaca-use-package-by-default t))

;; Block until current queue processed.
(elpaca-wait)

;;When installing a package which modifies a form used at the top-level
;;(e.g. a package which adds a use-package key word),
;;use `elpaca-wait' to block until that package has been installed/configured.
;;For example:
;;(use-package general :demand t)
;;(elpaca-wait)

;; Expands to: (elpaca evil (use-package evil :demand t))
(use-package evil
    :init
    (setq evil-want-integration t)
    (setq evil-want-keybinding nil)
    (setq evil-vsplit-window-right t)
    (setq evil-split-window-belo t)
    (evil-mode))
  (use-package evil-collection
    :after evil
    :config
    (setq evil-collection-mode-list '(dashboard dired ibuffer))
    (evil-collection-init))
  (use-package evil-tutor)

;;Turns off elpaca-use-package-mode current declartion
;;Note this will cause the declaration to be interpreted immediately (not deferred).
;;Useful for configuring built-in emacs features.
(use-package emacs :elpaca nil :config (setq ring-bell-function #'ignore))

;; Don't install anything. Defer execution of BODY
;;(elpaca nil (message "deferred"))

(use-package general
  :config
  (general-evil-setup)
  ;; set up 'SPC' as global leader key
  (general-create-definer kh/leader-keys
    :states '(normal insert visual emacs)
    :keymaps 'override
    :prefix "SPC" ;; set leader
    :global-prefix "M-SPC") ;; access leader in insert mode

    (kh/leader-keys
      "SPC" '(counsel-M-x : "Counsel M-x")
      "." '(find-file :wk "Find file")
      "fc" '((lambda () (interactive) (find-file "~/.config/emacs/config.org")) :wk "Edit emacs config")
      "fr" '(counsel-recentf :wk "Find recent files")
      "TAB TAB" '(comment-line :wk "Comment lines"))

    (kh/leader-keys
      "b" '(:ignore t :wk "buffer")
      "bb" '(switch-to-buffer :wk "Switch buffer")
      "bi" '(ibuffer :wk "Ibuffer")
      "bk" '(kill-this-buffer :wk "Kill this buffer")
      "bn" '(next-buffer :wk "Next buffer")
      "bp" '(previous-buffer :wk "Previous buffer")
      "br" '(revert-buffer :wk "Reload buffer"))

    (kh/leader-keys
      "e" '(:ignore t :wk "Eshell/Evaluate")
      "eb" '(eval-buffer :wk "Evaluate elisp in buffer")
      "ed" '(eval-defuf :wk "Evaluate defun containing or after point")
      "ee" '(eval-expression :wk "Evaluate an elisp expression")
      "eh" '(cousel-esh-history :wk "Eshell history")
      "el" '(eval-last-sexp :wk "Evaluate elisp expression before point")
      "er" '(eval-region :wk "Evaluate elisp in region")
      "es" '(eshell :wk "Eshell"))

    (kh/leader-keys
     "h" '(:ignore t :wk "Help")
     "hf" '(describe-function :wk "Describe function")
     "hv" '(describe-variable :wk "Describe variable")
     ;;"hrr" '((lambda () (interactive) (load-file "~/.config/emacs/init.el")) :wk "Reload emacs config")
     "hrr" '(reload-init-file :wk "Reload emacs config"))

    (kh/leader-keys
     "m" '(:ignore t :wk "Org")
     "ma" '(org-agenda :wk "Org agenda")
     "me" '(org-export-dispatch :wk "Org export dispatch")
     "mi" '(org-toggle-item :wk "Org toggle item")
     "mt" '(org-todo :wk "Org todo")
     "mB" '(org-babel-tangle :wk "Org babel tangle")
     "mT" '(org-todo-list :wk "Org todo list"))

    (kh/leader-keys
     "mb" '(:ignore t :wk "Tables")
     "mb-" '(org-table-insert-hline :wk "Insert hline in the table"))

    (kh/leader-keys
     "md" '(:ignore t :wk "Date/deadline")
     "mdt" '(org-time-stamp :wk "Org time stamp"))
    
    (kh/leader-keys
     "t" '(:ignore t :wk "Toggle")
     "tl" '(display-line-numbers-mode :wk "Toggle line numbers")
     "tt" '(visual-line-mode :wk "Toggle truncated lines")
     "tv" '(vterm-toggle :wk "Toggle vterm"))

    (kh/leader-keys
     "w" '(:ignore t :wk "Windows")
     ;; Window splits
     "wc" '(evil-window-delete :wk "Close window")
     "wn" '(evil-window-new :wk "New window")
     "ws" '(evil-window-split :wk "Horizontal split window")
     "wv" '(evil-window-vsplit :wk "Vertical split window")
     ;; Window motion
     "wh" '(evil-window-left :wk "Window left")
     "wj" '(evil-window-down :wk "Window down")
     "wk" '(evil-window-up :wk "Window up")
     "wl" '(evil-window-right :wk "Window right")
     "ww" '(evil-window-next :wk "Goto next window")
     ;; Move windows
     "wH" '(buf-move-left  :wk "Buffer move left")
     "wJ" '(buf-move-down  :wk "Buffer move down")
     "wK" '(buf-move-up    :wk "Buffer move up")
     "wL" '(buf-move-right :wk "Buffer move right"))
)

(use-package all-the-icons
  :ensure t
  :if (display-graphic-p))

(use-package all-the-icons-dired
  :hook (dired-mode . (lambda () (all-the-icons-dired-mode t))))

(defun emacs-counsel-launcher ()
  "Create and select a frame called emacs-cousel-launcher which consists only of a minibuffer and has specific dimensions. Run counsel-linux-app on that frame, which is an emacs command that prompts you to select an app and open it in a dmenu like behaviour. Delete the frame after that command has exited"
  (interactive)
  (with-selected-frame
    (make-frame '((name . "emacs-run-launcher")
                  (minibuffer . only)
                  (fullscreen . 0)
                  (undecorated . t)
                  ;;(auto-raise . t)
                  ;;(tool-bar-lines . 0)
                  ;;(menu-bar-lines . 0)
                  (internal-border-width . 10)
                  (width . 80)
                  (height . 11)))
                  (unwind-protect
                    (counsel-linux-app)
                    (delete-frame))))

(require 'windmove)

;;;###autoload
(defun buf-move-up ()
  "Swap the current buffer and the buffer above the split.
If there is no split, ie now window above the current one, an
error is signaled."
;;  "Switches between the current buffer, and the buffer above the
;;  split, if possible."
  (interactive)
  (let* ((other-win (windmove-find-other-window 'up))
	 (buf-this-buf (window-buffer (selected-window))))
    (if (null other-win)
        (error "No window above this one")
      ;; swap top with this one
      (set-window-buffer (selected-window) (window-buffer other-win))
      ;; move this one to top
      (set-window-buffer other-win buf-this-buf)
      (select-window other-win))))

;;;###autoload
(defun buf-move-down ()
"Swap the current buffer and the buffer under the split.
If there is no split, ie now window under the current one, an
error is signaled."
  (interactive)
  (let* ((other-win (windmove-find-other-window 'down))
	 (buf-this-buf (window-buffer (selected-window))))
    (if (or (null other-win)
            (string-match "^ \\*Minibuf" (buffer-name (window-buffer other-win))))
        (error "No window under this one")
      ;; swap top with this one
      (set-window-buffer (selected-window) (window-buffer other-win))
      ;; move this one to top
      (set-window-buffer other-win buf-this-buf)
      (select-window other-win))))

;;;###autoload
(defun buf-move-left ()
"Swap the current buffer and the buffer on the left of the split.
If there is no split, ie now window on the left of the current
one, an error is signaled."
  (interactive)
  (let* ((other-win (windmove-find-other-window 'left))
	 (buf-this-buf (window-buffer (selected-window))))
    (if (null other-win)
        (error "No left split")
      ;; swap top with this one
      (set-window-buffer (selected-window) (window-buffer other-win))
      ;; move this one to top
      (set-window-buffer other-win buf-this-buf)
      (select-window other-win))))

;;;###autoload
(defun buf-move-right ()
"Swap the current buffer and the buffer on the right of the split.
If there is no split, ie now window on the right of the current
one, an error is signaled."
  (interactive)
  (let* ((other-win (windmove-find-other-window 'right))
	 (buf-this-buf (window-buffer (selected-window))))
    (if (null other-win)
        (error "No right split")
      ;; swap top with this one
      (set-window-buffer (selected-window) (window-buffer other-win))
      ;; move this one to top
      (set-window-buffer other-win buf-this-buf)
      (select-window other-win))))

(use-package dashboard
  :ensure t
  :init
  (setq initial-buffer-choice 'dashboard-open)
  (setq dashboard-set-heading-icon t)
  (setq dashboard-set-file-icons t)
  (setq dashboard-banner-logo-title "Emacs Is More Than A Text Editor!")
  (setq dashboard-startup-banner "~/.config/emacs/images/emacs-dash.png")
  (setq dashboard-senter-content nil)
  (setq dashboard-items '((recents . 5)
                          (agenda . 5)
                          (bookmarks . 3)
                          (projects . 3)
                          (registers . 3)))
  (dashboard-modify-heading-icons '((recents . "file-text")
                                    (bookmarks . "book")))
  :config
  (dashboard-setup-startup-hook))

(set-face-attribute 'default nil
  ;:font "FiraCode Nerd Font Mono"
  ;:font "3270 Nerd Font Mono"
  :font "JetBrains Mono"
  :height 130
  :weight 'medium)

(set-face-attribute 'variable-pitch nil
  ;:font "FiraCode Nerd Font"
  ;:font "3270 Nerd Font"
  :font "Ubuntu"
  :height 140
  :weight 'medium)

(set-face-attribute 'fixed-pitch nil
  ;:font "FiraCode Nerd Font Mono"
  ;:font "3270 Nerd Font Mono"
  :font "JetBrains Mono"
  :height 130
  :weight 'medium)

(set-face-attribute 'font-lock-comment-face nil
  :slant 'italic)

(set-face-attribute 'font-lock-keyword-face nil
  :slant 'italic)

;(add-to-list 'default-frame-alist '(font . "FiraCode Nerd Font Mono-11"))
;(add-to-list 'default-frame-alist '(font . "3270 Nerd Font Mono-13"))
(add-to-list 'default-frame-alist '(font . "JetBrains Mono-13"))

(setq-default line-spacing 0.12)

(global-set-key (kbd "C-=") 'text-scale-increase)
(global-set-key (kbd "C--") 'text-scale-decrease)
(global-set-key (kbd "<C-wheel-up>") 'text-scale-increase)
(global-set-key (kbd "<C-wheel-down>") 'text-scale-decrease)

(menu-bar-mode -1)
(tool-bar-mode -1)
(scroll-bar-mode -1)

(global-display-line-numbers-mode 1)
(global-visual-line-mode t)

(use-package counsel
  :after ivy
  :config (counsel-mode))

(use-package ivy
  :bind
  ;; ivy-resume resumes the past Ivy-based completion.
  (("C-c C-r" . ivy-resume)
   ("C-x B" . ivy-swithch-buffer-other-window))
  :custom
  (setq ivy-use-virtual-buffers t)
  (setq ivy-count-format "(%d/%d) ")
  (setq enable-recursive-minibuffers t)
  :config
  (ivy-mode))

(use-package all-the-icons-ivy-rich
  :ensure t
  :init (all-the-icons-ivy-rich-mode 1))

(use-package ivy-rich
  :after ivy
  :ensure t
  :init (ivy-rich-mode 1) ;; this gets us descriptions in M-x
  :custom
  (ivy-virtual-abbreviate 'full
   ivy-rich-switch-buffer-align-virtual-buffer t
   ivy-rich-path-style 'abbrev)
  :config
  (ivy-set-display-transformer 'ivy-switch-buffer
                               'ivy-rich-switch-buffer-transformer))

(use-package lua-mode)
(use-package haskell-mode)
(use-package rust-mode)

(use-package toc-org
  :commands toc-org-enable
  :init (add-hook 'org-mode-hook 'toc-org-enable))

(add-hook 'org-mode-hook 'org-indent-mode)
(use-package org-bullets)
(add-hook 'org-mode-hook (lambda () (org-bullets-mode 1)))

(electric-indent-mode -1)
(setq org-edit-src-content-indentation 0)

(require 'org-tempo)

(use-package projectile
  :config
  (projectile-mode 1))

(use-package rainbow-mode
  :hook org-mode prog-mode)

(defun reload-init-file ()
"Reload hack, since one load sometimes does not fully work."
  (interactive)
  (load-file user-init-file)
  (load-file user-init-file))

(use-package eshell-syntax-highlighting
  :after esh-mode
  :config
  (eshell-syntax-highlighting-global-mode +1))

;; eshell-syntax-highlighting -- adds fish.zsh-likesyntax highlighting.
;; eshell-rc-script -- your profile for eshell; like bashrc for eshell.
;; eshell-aliases-file -- sets an aliases file for the eshell.

(setq eshell-rc-script "~/.config/emacs/eshell/profile"
      ;;eshell-aliases-file "~/.config/emacs/eshell/aliases"
      eshell-history-size 5000
      eshell-buffer-maximum-lines 5000
      eshell-hist-ignoredups t
      eshell-scroll-to-bottom-on-input t
      eshell-destroy-buffer-when-process-dies t
      eshell-visual-commands'("bash" "fish" "htop" "ssh" "top" "zsh"))

(use-package vterm)
(setq shell-file-name "/bin/sh"
      vterm-max-scrollback 5000)

(use-package vterm-toggle
  :after vterm
  :config
  (setq vterm-toggle-fullscreen-p nil)
  (setq vterm-toggle-scope 'project)
  (add-to-list 'display-buffer-alist
               '((lambda (buffer-or-name _)
                   (let ((buffer (get-buffer buffer-or-name)))
                     (with-current-buffer buffer
                       (or (equal major-mode 'vterm-mode)
                         (string-prefix-p vterm-buffer-name (buffer-name buffer))))))
                 (display-buffer-reuse-window display-buffer-at-bottom)
                 ;;(display-buffer-reuse-window display-buffer-in-direction)
                 ;;display-buffer-in-direction/direction/dedicated is added in emacs27
                 ;;(direction . bottom)
                 ;;(dedicated . t) ;dedicated is supported in emacs27
                 (reuasable-frames . visible)
                 (window-height . 0.3))))

(use-package sudo-edit
  :config
    (kh/leader-keys
      "fu" '(sudo-edit-find-file :wk "Sudo find file")
      "fU" '(sudo-edit :wk "Sudo edit file")))

(add-to-list 'custom-theme-load-path "~/.config/emacs/themes/")
(load-theme 'dtmacs t)

(use-package which-key
 :init
  (which-key-mode 1)
 :config
  (setq which-key-side-window-location 'bottom
        which-key-sort-order #'which-key-key-order-alpha
        which-key-sort-uppercase-first nil
        which-key-add-column-padding 1
        which-key-max-display-columns nil
        which-key-min-display-lines 6
        which-key-side-window-slot -10
        which-key-side-window-max-height 0.25
        which-key-idle-delay 0.8
        which-key-max-descrition-length 25
        which-key-allow-imprecise-window-fit nil
        which-key-seperator "->"))

