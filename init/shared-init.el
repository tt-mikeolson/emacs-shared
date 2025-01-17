;;; Emacs initialization settings common to multiple computers
;;
;; Author: Michael Olson
;;
;; The contents of this file may be used, distributed, and modified
;; without restriction.

(require 'cl-seq)

;;; Options that change behavior of this file

(defvar my-default-font      (cond
                              ((eq system-type 'darwin) "Inconsolata-20")
                              ((eq system-type 'windows-nt) "Inconsolata-14")
                              (t "Inconsolata-18")))
(defvar my-theme             'sanityinc-tomorrow-eighties)
(defvar my-use-themes-p      (boundp 'custom-theme-load-path))
(defvar my-eslint-fix-enabled-p nil)
(defvar my-frame-height      50)
(defvar my-frame-width       120)
(defvar my-frame-maximize-if-pixel-width-lte 1440)
(defvar my-frame-maximize-p  t)
(defvar my-frame-pad-width   (if (eq system-type 'darwin) 65 nil))
(defvar my-frame-pad-height  (if (eq system-type 'darwin) 15 nil))
(defvar my-remap-cmd-key-p   t)
(defvar my-default-directory "~/")
(defvar my-changelog-address "user@example.com")
(defvar my-email-address     "user@example.com")
(defvar my-full-name         "Jane Doe")
(defvar my-emacs-path)
(setq my-emacs-path          (file-name-as-directory (expand-file-name my-emacs-path)))

(defvar my-server-start-p    t)
(defvar my-recent-files      nil)
(defvar my-settings-shared-p (not (file-exists-p (locate-user-emacs-file "settings.el"))))
(defvar my-system-paths
  (cond ((eq system-type 'darwin)
         '("~/emacs-shared/bin"
           "~/bin"
           "/Applications/Xcode.app/Contents/Developer/usr/bin"
           "/usr/local/bin"))
        ((eq system-type 'windows-nt)
         `(,(concat "C:/Program Files/Emacs/emacs-" emacs-version "/bin")
	   "C:/msys64/usr/bin"
	   "c:/msys64/mingw64/bin"
           "C:/Program Files/maven/bin"
	   "C:/Program Files (x86)/Aspell/bin"
	   "C:/Program Files/Git/bin"
	   "C:/Program Files/PuTTY"))
        (t '("/opt/maven/bin"))))
(setq my-system-paths (cl-remove-if-not #'file-exists-p my-system-paths))

;;; Display

;; Add shared elisp directory (but prefer system libs)
(add-to-list 'load-path (concat my-emacs-path "elisp") t)

;; Support for libgit
(if (eq system-type 'windows-nt)
    (setq libgit--module-file (concat my-emacs-path "elisp/libegit2/build/libegit2.dll"))
  (setq libgit--module-file (concat my-emacs-path "elisp/libegit2/build/libegit2.so")))

(when (file-exists-p libgit--module-file)
  (add-to-list 'load-path (concat my-emacs-path "elisp/libegit2") t))

;; Allow maximizing frame
(require 'maxframe)
(when my-frame-pad-width
  (setq mf-max-width (- (display-pixel-width) my-frame-pad-width)))
(when my-frame-pad-height
  (setq mf-max-height (- (display-pixel-height) my-frame-pad-height)))

(defun my-reset-font ()
  (interactive)
  (when my-default-font
    (set-frame-font my-default-font nil t)))

(defun my-reset-frame-size ()
  "Reset the size of the current frame according to `default-frame-alist'."
  (interactive)
  (let ((maximize-p my-frame-maximize-p))
    (when (and maximize-p my-frame-maximize-if-pixel-width-lte)
      (setq maximize-p (<= (display-pixel-width) my-frame-maximize-if-pixel-width-lte)))
    (cond ((and maximize-p (memq window-system '(x w32)))
           (set-frame-parameter nil 'fullscreen 'maximized))
          (maximize-p
           (maximize-frame))
          (t
           (dolist (param '(width height))
             (set-frame-parameter nil param (cdr (assoc param default-frame-alist))))))))

(defun my-reset-theme ()
  (interactive)
  (when my-use-themes-p
    (load-theme my-theme t)))

;; This function should be called on the emacsclient commandline in cases where no file is being passed on commandline.
(defun my-init-client ()
  (interactive)
  (if window-system
      (progn
        (my-reset-font)
        (when my-default-font
          (add-to-list 'default-frame-alist
                       (cons 'font (cdr (assq 'font (frame-parameters))))))
        (when (or (not my-frame-maximize-p) my-frame-maximize-if-pixel-width-lte)
          (add-to-list 'default-frame-alist (cons 'height my-frame-height))
          (add-to-list 'default-frame-alist (cons 'width my-frame-width)))
        (when (eq window-system 'mac)
          ;; redisplay slowness https://github.com/hlissner/doom-emacs/issues/2217
          (add-to-list 'default-frame-alist '(inhibit-double-buffering . t))
          (ignore-errors
            (mac-auto-operator-composition-mode)))
        ;; Make sure DEL key does what I want
        (normal-erase-is-backspace-mode 1)
        ;; Show the menu if we are using X
        (set-frame-parameter nil 'menu-bar-lines 1))
    ;; Don't show the menu unless we are using X
    (set-frame-parameter nil 'menu-bar-lines 0))
  ;; Don't show scroll bars
  (ignore-errors (scroll-bar-mode -1))
  ;; Don't show the tool bar
  (ignore-errors (tool-bar-mode -1))
  ;; Initialize color theme
  (my-reset-theme)
  ;; Maximize frame or re-apply frame settings
  (when window-system
    (global-tab-line-mode 1)
    (my-reset-frame-size)))

;; Initialize display settings on startup
(my-init-client)

;; Give people something to look at while we load
(display-startup-screen)
(redisplay t)
(add-hook 'server-visit-hook 'my-init-client)

;; Modeline theme
; currently too large
;(require 'spaceline-config)
;(spaceline-emacs-theme)

;; Tasks that are run after initial startup for appearance of speed
(defvar my-deferred-startup-hook '(display-startup-echo-area-message))
(defun my-defer-startup (func)
  "Defer running a task until sometime after Emacs has started."
  (add-hook 'my-deferred-startup-hook func))
(defun my-run-deferred-tasks ()
  (unless (eq system-type 'windows-nt)
    (run-hooks 'my-deferred-startup-hook)))

(run-with-idle-timer 0.2 nil #'my-run-deferred-tasks)

;;; OS Setup

;; Make it easier to use find-library to get to this file
(add-to-list 'load-path (concat my-emacs-path "init"))

(when my-system-paths
  (setq exec-path (append my-system-paths exec-path))
  (setenv "PATH" (mapconcat (lambda (path)
                              (if (eq system-type 'windows-nt)
                                  (replace-regexp-in-string "/" "\\\\" path)
                                path))
                            (append my-system-paths (list (getenv "PATH")))
                            (if (eq system-type 'windows-nt) ";" ":"))))

;; Setup manpage browsing
(when (eq system-type 'windows-nt)
  (setenv "MANPATH" (concat "C:\\msys64\\usr\\share\\man;"
                            "C:\\msys64\\mingw64\\share\\man;"
                            "C:\\Program Files\\Git\\man;"
                            "C:\\Program Files\\Emacs\\emacs-" emacs-version "\\share\\man"))
  (require 'woman)
  (defalias 'man 'woman))

;;; Customizations

;; Default values for some customization options
(setq directory-free-space-args "-Pkl")

(when (eq system-type 'windows-nt)
  (setq directory-free-space-args nil))

;; Load customizations
(setq custom-file (if my-settings-shared-p
                      (concat my-emacs-path "init/settings.el")
                    (locate-user-emacs-file "settings.el")))
(when (file-exists-p custom-file)
  (load custom-file))

;;; Functions

(defmacro match-data-changed (&rest body)
  "Determine whether the match data has been modified by BODY."
  (let ((mdata (make-symbol "temp-buffer")))
    `(let ((,mdata (match-data)))
       (prog1 ,@body
         (if (equal ,mdata (match-data))
             (message "Match data has not been changed")
           (message "Match data has been changed!"))))))

(put 'match-data-changed 'lisp-indent-function 0)
(put 'match-data-changed 'edebug-form-spec '(body))

(defun byte-compile-this-file-temporarily ()
  (interactive)
  (let ((file buffer-file-name))
    (byte-compile-file file)
    (save-match-data
      (when (string-match "\\.el\\'" file)
        (delete-file (concat file "c"))))))

(defun my-fetch-url (url)
  "Fetch the given URL into a buffer and switch to it."
  (interactive (list (read-string "URL: ")))
  (require 'url-handlers)
  (let ((outer (generate-new-buffer (format "*URL: %s*"
                                            (substring url 0 40)))))
    (message "Fetching URL ...")
    (url-retrieve
     url
     `(lambda (status)
        (let ((results (current-buffer))
              size-and-charset)
          (with-current-buffer ,outer
            (setq success (url-insert results))
            (kill-buffer results)
            (unless (cadr size-and-charset)
              (decode-coding-inserted-region
               (point-min) (point-max) (buffer-name ,outer)))
            (goto-char (point-min)))
          (switch-to-buffer ,outer))))))

(defun my-replace-cdrs-in-alist (old-mode new-mode alist)
  "Replace cdr instances of OLD-MODE with NEW-MODE in ALIST."
  (mapc #'(lambda (el)
            (when (eq (cdr el) old-mode)
              (setcdr el new-mode)))
        (symbol-value alist)))

;;; Things that can't be changed easily using `customize'

;; Enable some commands
(put 'downcase-region 'disabled nil)
(put 'scroll-left 'disabled nil)
(put 'upcase-region 'disabled nil)

;; Personal info
(defun my-update-personal-info ()
  (interactive)
  ;; full name
  (setq debian-changelog-full-name my-full-name)
  (setq user-full-name my-full-name)
  ;; changelog email addresses
  (setq add-log-mailing-address my-changelog-address)
  (setq debian-changelog-mailing-address my-changelog-address)
  ;; email addresses
  (setq post-email-address my-email-address)
  (setq user-mail-address my-email-address))
(my-update-personal-info)

;;; Programs and features

;; Load `dired' itself, with `tramp' extension
(require 'dired)
(require 'dired-x)
(require 'wdired)
(require 'ffap)

;; Load tramp
(require 'tramp)

;; List directories first in dired
(require 'ls-lisp)

;; Don't slow down ls and don't make dired output too wide on w32 systems
(setq w32-get-true-file-attributes nil)

;; Make shell commands run in unique buffer so we can have multiple at once, and run all shell
;; asynchronously.  Taken in part from EmacsWiki: ExecuteExternalCommand page.

(defadvice erase-buffer (around erase-buffer-noop disable)
  "Make erase-buffer do nothing; only used in conjunction with shell-command.")

(defadvice shell-command (around shell-command-unique-buffer activate)
  (if (or current-prefix-arg
          output-buffer)
      ;; if this is used programmatically, allow it to be synchronous
      ad-do-it

    (save-match-data
      (let ((lisp-exp (and (string-match "\\`[[:blank:]]*([^&|]+)[[:blank:]]*\\'" command)
                           (condition-case nil (read command) (error nil)))))
        ;; if we accidentally entered a readable lisp expression, eval it
        (if lisp-exp
            (eval-expression lisp-exp nil)

          (unless (string-match "&[ \t]*\\'" command)
            (setq command (concat command " &")))

          ;; set match data for buffer name
          (string-match "[ \t]*&[ \t]*\\'" command)

          (let* ((command-name (substring command 0 (min 40 (match-beginning 0))))
                 (command-name (car (split-string command-name "\n" t)))
                 (command-buffer-name (format "*Shell Command: %s*" command-name))
                 (command-buffer (get-buffer command-buffer-name)))

            ;; if the buffer exists and has a live process, rename it uniquely
            (if (and command-buffer (get-buffer-process command-buffer))
                (with-current-buffer command-buffer
                  (rename-uniquely))
              (when (buffer-live-p command-buffer)
                (kill-buffer command-buffer)))
            (setq output-buffer command-buffer-name)

            ;; insert command at top of buffer
            (switch-to-buffer-other-window output-buffer)
            (insert "Running command: " command "\n"
                    (make-string (- (window-width) 1) ?\~)
                    "\n\n")

            ;; temporarily blow away erase-buffer while doing it, to avoid erasing the above
            (ad-activate-regexp "erase-buffer-noop")
            (unwind-protect
                (let ((process-environment (cons "PAGER=" process-environment)))
                  ad-do-it)
              (ad-deactivate-regexp "erase-buffer-noop"))))))))

;; Docker support
(require 'docker-tramp)

(defun my-docker-machine-env ()
  (interactive)
  (let* ((machine "default")
         (out (if (file-exists-p "~/.docker-env")
                  (with-temp-buffer
                    (insert-file-contents-literally "~/.docker-env")
                    (buffer-substring (point-min) (point-max)))
                (shell-command-to-string (concat "docker-machine env " machine))))
         (changes 0))
    (save-match-data
      (dolist (line (split-string out "\n" t))
        (when (string-match "\\`export \\([^=]+\\)=\"\\(.+\\)\"\\'" line)
          (let ((env-var (match-string 1 line))
                (env-setting (match-string 2 line)))
            (incf changes)
            (setenv env-var env-setting)))))
    (if (= changes 0)
        (message "Could not load docker changes, output:\n%s" out)
      (message "Loaded Docker env for machine: %s" machine))))

;; .env file support
(add-to-list 'auto-mode-alist '("\\.env\\..*\\'" . dotenv-mode))

;; Editorconfig support
(editorconfig-mode 1)

;; Edit Server support through Atomic Chrome / GhostText
(defun my-start-atomic-chrome ()
  (require 'atomic-chrome)
  (atomic-chrome-start-server))

(when my-server-start-p
  (my-defer-startup #'my-start-atomic-chrome))

;; Long lines support
(global-so-long-mode 1)
(add-to-list 'so-long-target-modes 'fundamental-mode)
(add-to-list 'so-long-target-modes 'web-mode)

;; Lisp REPL using SLIME
(require 'slime)
(slime-setup '(slime-repl))
(setq slime-auto-connect 'always)
(setq slime-kill-without-query-p t)
(setq slime-protocol-version 'ignore)

;; Improved JSX support (disabled)
;;
;; (my-replace-cdrs-in-alist 'js-mode 'rjsx-mode 'interpreter-mode-alist)
;; (add-to-list 'auto-mode-alist '("\\.jsx?\\'" . rjsx-mode))
;;
;; Use plain old js-mode since it doesn't freeze when loading ES7 code with decorators
;; (add-to-list 'auto-mode-alist '("\\.jsx?\\'" . js-mode))

;; Flymake setup

(require 'flymake-stylelint)
(add-hook 'scss-mode-hook 'add-node-modules-path t)
(add-hook 'scss-mode-hook 'flymake-stylelint-enable t)
(add-hook 'scss-mode-hook 'display-line-numbers-mode t)

;; NodeJS REPL setup

(require 'js-comint)

(defun my-js-comint-send-last-sexp ()
  "Send the previous sexp to the inferior Javascript process."
  (interactive)
  (let* ((b (save-excursion
              (backward-sexp)
              (move-beginning-of-line nil)
              (point)))
         (e (point))
         (str (buffer-substring-no-properties b e)))
    (js-comint-start-or-switch-to-repl)
    (js-comint-send-string str)))

(defun my-js-comint-send-line ()
  "Send the buffer to the inferior Javascript process."
  (interactive)
  (let ((text (buffer-substring-no-properties (point-at-bol) (point-at-eol))))
    (js-comint-start-or-switch-to-repl)
    (js-comint-send-string text)))

(defun my-js-comint-send-region (start end)
  "Send the region to the inferior Javascript process."
  (interactive "r")
  (let ((text (buffer-substring-no-properties start end)))
    (js-comint-start-or-switch-to-repl)
    (js-comint-send-string text)))

(defvar node-repl-interaction-mode-map
  (let ((map (make-sparse-keymap)))
    (define-key map (kbd "C-x C-e") 'my-js-comint-send-last-sexp)
    (define-key map (kbd "C-c C-l") 'my-js-comint-send-line)
    (define-key map (kbd "C-c C-r") 'my-js-comint-send-region)
    (define-key map (kbd "C-c C-z") 'js-comint-start-or-switch-to-repl)
    map)
  "Keymap for node-repl-interaction-mode.")

(define-minor-mode node-repl-interaction-mode
  "Minor mode to interact with a NodeJS REPL in combination with the `nodejs-repl' package.

When called interactively, toggle `node-repl-interaction-mode'.
With prefix ARG, enable `node-repl-interaction-mode' if ARG is
positive, otherwise disable it.

When called from Lisp, enable `node-repl-interaction-mode' if ARG
is omitted, nil or positive.  If ARG is `toggle', toggle
`node-repl-interaction-mode'.  Otherwise behave as if called
interactively.

\\{node-repl-interaction-mode-map}"
  :keymap node-repl-interaction-mode-map
  (cond
   (node-repl-interaction-mode nil)
   (t nil)))

;; (when (eq system-type 'windows-nt)
;;   (setq js-comint-program-command "C:/Program Files/nodejs/node.exe"))

(defun inferior-js-mode-hook-setup ()
  (add-hook 'comint-output-filter-functions 'js-comint-process-output))

(add-hook 'inferior-js-mode-hook 'inferior-js-mode-hook-setup t)

;; Web Mode setup
;;
;; Taken from https://gist.github.com/CodyReichert/9dbc8bd2a104780b64891d8736682cea

(defvar my--js-files-regex "\\.\\([jt]sx?\\|mjs\\)\\'")

(add-to-list 'auto-mode-alist '("\\.hbs\\'" . web-mode))
(add-to-list 'auto-mode-alist '("\\.html\\'" . web-mode))
(add-to-list 'auto-mode-alist '("\\.json\\'" . web-mode))
(add-to-list 'auto-mode-alist `(,my--js-files-regex . web-mode))

(setq web-mode-content-types-alist `(("jsx" . ,my--js-files-regex)))

(defun my-define-web-mode (file-ext)
  (let* ((sym-name (symbol-name file-ext))
         (filename (concat "." sym-name))
         (mode-sym (intern (concat "my-" sym-name "-mode")))
         (mode-name-alias (intern (concat "my-" sym-name))))
    (eval `(defun ,mode-sym (&rest mode-args)
             (cl-letf (((symbol-function 'buffer-file-name)
                        (lambda () ,filename)))
               (apply #'web-mode mode-args))))))

(my-define-web-mode 'js)
(my-replace-cdrs-in-alist 'js-mode 'my-js-mode 'interpreter-mode-alist)

;; (eval-after-load "web-mode"
;;   '(progn
;;      (define-key web-mode-map (kbd "C-c C-j") nil)))

(defun eslint-fix-file ()
  (interactive)
  (message "Running eslint --fix")
  (redisplay t)
  (call-process "eslint" nil nil nil "--fix" (buffer-file-name))
  (message "Running eslint --fix...done"))

(defun eslint-fix-file-and-revert-maybe ()
  (interactive)
  (when (and my-eslint-fix-enabled-p (fboundp #'flymake-diagnostics))
    (eslint-fix-file)
    (revert-buffer t t)))

(defun my-web-mode-init-hook ()
  "Hooks for Web mode."
  (add-node-modules-path)
  (display-line-numbers-mode)
  (let ((buf-name (buffer-name))
        (buf-filename (buffer-file-name)))
    (when (and (not (string-match-p "\\.mdx?" buf-name))
               (string-match-p my--js-files-regex buf-filename))
      (node-repl-interaction-mode 1)
      (when (and (not (string-match-p "/node_modules/" default-directory))
                 (executable-find "eslint"))
        (flymake-eslint-enable)
        (add-hook 'after-save-hook #'eslint-fix-file-and-revert-maybe t t)))))

(defun my-eslint-disable-in-current-buffer ()
  (interactive)
  (flymake-mode nil)
  (set (make-local-variable 'my-eslint-fix-enabled-p) nil))

(add-hook 'web-mode-hook #'my-web-mode-init-hook t)

;; JS2 Mode setup (disabled)

(defun my-set-js2-mocha-externs ()
  (setq js2-additional-externs
        (mapcar 'symbol-name '(after afterEach before beforeEach describe expect it))))

(eval-after-load "js2-mode"
  '(progn
     ;; BUG: self is not a browser extern, just a convention that needs checking
     (setq js2-browser-externs (delete "self" js2-browser-externs))

     ;; Consider the chai 'expect()' statement to have side-effects, so we don't warn about it
     (defun js2-add-strict-warning (msg-id &optional msg-arg beg end)
       (if (and js2-compiler-strict-mode
                (not (and (string= msg-id "msg.no.side.effects")
                          (string= (buffer-substring-no-properties beg (+ beg 7)) "expect("))))
           (js2-report-warning msg-id msg-arg beg
                               (and beg end (- end beg)))))

     ;; Add support for some mocha testing externs
     (add-hook 'js2-init-hook #'my-set-js2-mocha-externs t)))

;; Highlight node.js stacktraces in *compile* buffers
(defvar my-nodejs-compilation-regexp
  '("^[ \t]+at +\\(?:.+(\\)?\\([^()\n]+\\):\\([0-9]+\\):\\([0-9]+\\))?$" 1 2 3))

(eval-after-load "compile"
  '(progn
     (add-to-list 'compilation-error-regexp-alist-alist
                  (cons 'nodejs my-nodejs-compilation-regexp))
     (add-to-list 'compilation-error-regexp-alist 'nodejs)))

;; Highlight current line
(require 'hl-line-plus)
(hl-line-when-idle-interval 0.3)
(toggle-hl-line-when-idle 1)

;; Enable dumb-jump, which makes `C-c . .' jump to a function's definition
(require 'dumb-jump)
(setq dumb-jump-selector 'ivy)

;; typescript support from https://github.com/amake/.emacs.d/blob/master/init.el
;; see https://github.com/jacktasia/dumb-jump/issues/97
(unless (dumb-jump-get-language-by-filename "foo.ts")
  (mapc (lambda (item) (add-to-list 'dumb-jump-language-file-exts item))
        '((:language "typescript" :ext "ts" :agtype "ts" :rgtype "ts")
          (:language "typescript" :ext "tsx" :agtype "ts" :rgtype "ts")))

  (mapc (lambda (item) (add-to-list 'dumb-jump-language-comments item))
        '((:comment "//" :language "typescript")))

  (mapc (lambda (item) (add-to-list 'dumb-jump-find-rules item))
        ;; Rules translated from link below, except where noted
        ;; https://github.com/jacktasia/dumb-jump/issues/97#issuecomment-346441412
        ;;
        ;; --regex-typescript=/^[ \t]*(export[ \t]+(abstract[ \t]+)?)?class[ \t]+([a-zA-Z0-9_$]+)/\3/c,classes/
        '((:type "type" :supports ("ag" "grep" "rg" "git-grep") :language "typescript"
                 :regex "(export\\s+(abstract\\s+)?)?class\\s+JJJ\\b"
                 :tests ("class test" "export class test" "abstract class test"
                         "export abstract class test")
                 :not ("class testnot"))
          ;; --regex-typescript=/^[ \t]*(declare[ \t]+)?namespace[ \t]+([a-zA-Z0-9_$]+)/\2/c,modules/
          (:type "module" :supports ("ag" "grep" "rg" "git-grep") :language "typescript"
                 :regex "(declare\\s+)?namespace\\s+JJJ\\b"
                 :tests ("declare namespace test" "namespace test")
                 :not ("declare testnot"))
          ;; --regex-typescript=/^[ \t]*(export[ \t]+)?module[ \t]+([a-zA-Z0-9_$]+)/\2/n,modules/
          (:type "module" :supports ("ag" "grep" "rg" "git-grep") :language "typescript"
                 :regex "(export\\s+)?module\\s+JJJ\\b"
                 :tests ("export module test" "module test")
                 :not ("module testnot"))
          ;; --regex-typescript=/^[ \t]*(export[ \t]+)?(async[ \t]+)?function[ \t]+([a-zA-Z0-9_$]+)/\3/f,functions/
          (:type "function" :supports ("ag" "grep" "rg" "git-grep") :language "typescript"
                 :regex "(export\\s+)?(async\\s+)?function\\s+JJJ\\b"
                 :tests ("function test" "export function test" "export async function test"
                         "async function test")
                 :not ("function testnot"))
          ;;--regex-typescript=/^[ \t]*export[ \t]+(var|let|const)[ \t]+([a-zA-Z0-9_$]+)/\2/v,variables/
          (:type "variable" :supports ("ag" "grep" "rg" "git-grep") :language "typescript"
                 :regex "export\\s+(var|let|const)\\s+JJJ\\b"
                 :tests ("export var test" "export let test" "export const test")
                 :not ("export var testnot"))
          ;; --regex-typescript=/^[ \t]*(var|let|const)[ \t]+([a-zA-Z0-9_$]+)[ \t]*=[ \t]*function[ \t]*[*]?[ \t]*\(\)/\2/v,varlambdas/
          (:type "variable" :supports ("ag" "grep" "rg" "git-grep") :language "typescript"
                 :regex "(var|let|const)\\s+JJJ\\s*=\\s*function\\s*\\*?\\s*\\\(\\\)"
                 :tests ("var test = function ()" "let test = function()" "const test=function*()")
                 :not ("var testnot = function ()"))
          ;; --regex-typescript=/^[ \t]*(export[ \t]+)?(public|protected|private)[ \t]+(static[ \t]+)?(abstract[ \t]+)?(((get|set)[ \t]+)|(async[ \t]+[*]*[ \t]*))?([a-zA-Z1-9_$]+)/\9/m,members/
          (:type "variable" :supports ("ag" "grep" "rg" "git-grep") :language "typescript"
                 :regex "(export\\s+)?(public|protected|private)\\s+(static\\s+)?(abstract\\s+)?(((get|set)\\s+)|(async\\s+))?JJJ\\b"
                 :tests ("public test" "protected static test" "private abstract get test"
                         "export public static set test" "export protected abstract async test")
                 :not ("public testnot"))
          ;; --regex-typescript=/^[ \t]*(export[ \t]+)?interface[ \t]+([a-zA-Z0-9_$]+)/\2/i,interfaces/
          (:type "type" :supports ("ag" "grep" "rg" "git-grep") :language "typescript"
                 :regex "(export\\s+)?interface\\s+JJJ\\b"
                 :tests ("interface test" "export interface test")
                 :not ("interface testnot"))
          ;; --regex-typescript=/^[ \t]*(export[ \t]+)?type[ \t]+([a-zA-Z0-9_$]+)/\2/t,types/
          (:type "type" :supports ("ag" "grep" "rg" "git-grep") :language "typescript"
                 :regex "(export\\s+)?type\\s+JJJ\\b"
                 :tests ("type test" "export type test")
                 :not ("type testnot"))
          ;; --regex-typescript=/^[ \t]*(export[ \t]+)?enum[ \t]+([a-zA-Z0-9_$]+)/\2/e,enums/
          (:type "type" :supports ("ag" "grep" "rg" "git-grep") :language "typescript"
                 :regex "(export\\s+)?enum\\s+JJJ\\b"
                 :tests ("enum test" "export enum test")
                 :not ("enum testnot"))
          ;; --regex-typescript=/^[ \t]*import[ \t]+([a-zA-Z0-9_$]+)/\1/I,imports/
          (:type "type" :supports ("ag" "grep" "rg" "git-grep") :language "typescript"
                 :regex "import\\s+JJJ\\b"
                 :tests ("import test")
                 :not ("import testnot"))
          ;; Custom definition for public methods without "public" keyword.
          ;; Fragile! Requires brace on same line.
          (:type "function" :supports ("ag" "grep" "rg" "git-grep") :language "typescript"
                 :regex "\\bJJJ\\s*\\(.*\\{"
                 :tests ("test() {" "test(foo: bar) {")
                 :not ("testnot() {"))
          )))

(defvar my-jump-map
  (let ((map (make-sparse-keymap)))
    (define-key map "." #'dumb-jump-go)
    (define-key map "," #'dumb-jump-back)
    (define-key map "/" #'dumb-jump-quick-look)
    (define-key map "o" #'dumb-jump-go-other-window)
    map)
  "My key customizations for dumb-jump.")

(global-set-key (kbd "C-c .") my-jump-map)

(defvar my-dumb-jump-minor-mode-map
  (let ((map (make-sparse-keymap)))
    (define-key map (kbd "C-c .") my-jump-map)
    map))

(define-minor-mode my-dumb-jump-minor-mode
  "Minor mode for jumping to variable and function definitions"
  :keymap my-dumb-jump-minor-mode-map)

;; Java
(require 'java-mode-indent-annotations)
(require 'google-c-style)
(add-hook 'c-mode-common-hook 'google-set-c-style t)
(add-hook 'c-mode-common-hook 'display-line-numbers-mode t)
(add-hook 'c-mode-common-hook 'my-dumb-jump-minor-mode t)

;; Kotlin
(add-to-list 'auto-mode-alist '("\\.kts?\\'" . kotlin-mode) t)
(autoload 'kotlin-mode "kotlin-mode" "Major mode for editing Kotlin." t nil)

;; C#
(eval-after-load "csharp-mode"
  '(progn
     (define-key csharp-mode-map (kbd "C-c .") nil)))

;; ANSI colors in compile buffer
(require 'ansi-color)
(defun colorize-compilation-buffer ()
  (toggle-read-only)
  (ansi-color-apply-on-region (point-min) (point-max))
  (toggle-read-only))
(add-hook 'compilation-filter-hook 'colorize-compilation-buffer t)

;; Load amx, which makes M-x work better on Ivy
(add-hook 'after-init-hook 'amx-mode t)

;; Ivy, Counsel, and Swiper
(require 'counsel)
(ivy-mode 1)
(setq ivy-use-virtual-buffers t)
(setq ivy-count-format "(%d/%d) ")
(setq ivy-re-builders-alist
      '((t . ivy--regex-plus)))
(setq counsel-find-file-at-point t)
(setq counsel-mode-override-describe-bindings t)
(counsel-mode 1)

(define-key ivy-minibuffer-map (kbd "C-r") 'ivy-previous-line-or-history)
(define-key ivy-occur-grep-mode-map "r" 'ivy-wgrep-change-to-wgrep-mode)

(global-set-key (kbd "C-s") 'swiper-isearch)
(global-set-key (kbd "C-r") 'swiper-isearch)
(global-set-key (kbd "C-c C-r") 'ivy-resume)

;; Enable projectile, a way to quickly find files in projects
(require 'projectile)
(projectile-global-mode 1)
(setq projectile-completion-system 'ivy)
(setq projectile-indexing-method 'alien)

(defun my-projectile-test-suffix (project-type)
  "Find default test files suffix based on PROJECT-TYPE."
  (cond
   ((member project-type '(grunt gulp npm)) ".spec")
   (t (projectile-test-suffix project-type))))
(setq projectile-test-suffix-function #'my-projectile-test-suffix)

;; Insinuate with ripgrep
(defvar my-default-ripgrep-args "--hidden -i")

(defun my-projectile-ripgrep (regexp rg-args &optional arg)
  "Run a Ripgrep search with `REGEXP' rooted at the current projectile project root.

With \\[universal-argument], also prompt for extra rg arguments and set into RG-ARGS."
  (interactive
   (list (read-from-minibuffer "Ripgrep search for: "
                               (and (use-region-p) (buffer-substring-no-properties (region-beginning) (region-end))))
         (if current-prefix-arg
             (read-from-minibuffer "Additional rg args: " my-default-ripgrep-args nil nil nil my-default-ripgrep-args)
           my-default-ripgrep-args)))
  (ripgrep-regexp regexp (projectile-project-root)
                  (and rg-args (not (string= rg-args "")) (list rg-args))))

(defun my-projectile-counsel-ripgrep (regexp rg-args &optional arg)
  "Run a Counsel Ripgrep search with `REGEXP' rooted at the current projectile project root.

With \\[universal-argument], also prompt for extra rg arguments and set into RG-ARGS."
  (interactive
   (list (and (use-region-p) (buffer-substring-no-properties (region-beginning) (region-end)))
         (if current-prefix-arg
             (read-from-minibuffer "Additional rg args: " my-default-ripgrep-args nil nil nil my-default-ripgrep-args)
           my-default-ripgrep-args)))
  (let ((counsel-rg-base-command "rg --no-heading --line-number %s ."))
    (counsel-rg regexp (projectile-project-root) rg-args)))

(define-key projectile-command-map (kbd "s r") #'my-projectile-ripgrep)
(define-key projectile-command-map (kbd "s s") #'my-projectile-counsel-ripgrep)

;; Support copying paths relative to the current buffer
(defun my-path-of-current-buffer ()
  (expand-file-name (or (buffer-file-name) default-directory)))

(defun my-copy-path-of-current-buffer ()
  (interactive)
  (let ((filepath (my-path-of-current-buffer)))
    (kill-new filepath)
    (message "Copied '%s' to clipboard" filepath)))

(defun my-copy-project-relative-path-of-current-buffer ()
  (interactive)
  (let ((filepath (file-relative-name (my-path-of-current-buffer) (projectile-project-root))))
    (kill-new filepath)
    (message "Copied '%s' to clipboard" filepath)))

(define-key projectile-command-map (kbd "w p") #'my-copy-project-relative-path-of-current-buffer)
(define-key projectile-command-map (kbd "w w") #'my-copy-path-of-current-buffer)

(global-set-key (kbd "C-c p") projectile-command-map)
(global-set-key (kbd "C-c C-p") projectile-command-map)

(eval-after-load "ripgrep"
  '(progn
     (define-key ripgrep-search-mode-map (kbd "TAB") #'compilation-next-error)
     (define-key ripgrep-search-mode-map (kbd "<backtab>") #'compilation-previous-error)))

;; Bind N and P in ediff so that I don't leave the control buffer
(defun my-ediff-next-difference (&rest args)
  (interactive)
  (save-selected-window
    (call-interactively 'ediff-next-difference)))

(defun my-ediff-previous-difference (&rest args)
  (interactive)
  (save-selected-window
    (call-interactively 'ediff-previous-difference)))

(defun my-ediff-extra-keys ()
  (define-key ediff-mode-map (kbd "N") #'my-ediff-next-difference)
  (define-key ediff-mode-map (kbd "P") #'my-ediff-previous-difference))
(add-hook 'ediff-keymap-setup-hook 'my-ediff-extra-keys t)

;; Make TexInfo easier to work with
(defun my-texinfo-view-file ()
  "View the published version of the current file."
  (interactive)
  (let ((file (buffer-file-name)))
    (when (string-match "\\.tex\\(i\\|info\\)?\\'" file)
      (setq file (replace-match ".info" t t file))
      (when (buffer-live-p (get-buffer "*info*"))
        (kill-buffer "*info*"))
      (info file))))

(defun my-texinfo-extra-keys ()
  "Make texinfo stuff easier to work with."
  (define-key texinfo-mode-map (kbd "C-c C-p") #'makeinfo-buffer)
  (define-key texinfo-mode-map (kbd "C-c C-v") #'my-texinfo-view-file))
(add-hook 'texinfo-mode-hook 'my-texinfo-extra-keys t)

;; Don't warn me when opening some Common Lisp files
(put 'package 'safe-local-variable 'symbolp)
(put 'Package 'safe-local-variable 'symbolp)
(put 'syntax 'safe-local-variable 'symbolp)
(put 'Syntax 'safe-local-variable 'symbolp)
(put 'Base 'safe-local-variable 'integerp)
(put 'base 'safe-local-variable 'integerp)

;; Enable wdired on "r"
(define-key dired-mode-map "r" 'wdired-change-to-wdired-mode)

;; Make tramp's backup directories the same as the normal ones
(setq tramp-backup-directory-alist backup-directory-alist)

;; Navigate the kill ring when doing M-y
(browse-kill-ring-default-keybindings)

;; extension of mine to make list editing easy
(require 'edit-list)

;; Markdown support

;(add-to-list 'auto-mode-alist '("\\.md\\'" . poly-markdown-mode))
;(add-to-list 'auto-mode-alist '("\\.mdx\\'" . poly-markdown-mode))
(add-to-list 'auto-mode-alist '("\\.md\\'" . gfm-mode))
(add-to-list 'auto-mode-alist '("\\.mdx\\'" . gfm-mode))

(defun my-define-web-polymode (file-ext)
  (let* ((sym-name (symbol-name file-ext))
         (filename (concat "." sym-name))
         (mode-sym (intern (concat "my-" sym-name "-mode")))
         (mode-name-alias (intern (concat "my-" sym-name))))
    (eval `(defun ,mode-sym (&rest mode-args)
             (cl-letf (((symbol-function 'buffer-file-name)
                        (lambda () ,filename)))
               (apply #'web-mode mode-args))))
    (add-to-list 'polymode-mode-name-aliases (cons file-ext mode-name-alias))))

(eval-after-load "polymode-core"
  '(progn
     ;; Commented out since the font-locking tends to bleed into other areas
     ;; of the file.
     ;(dolist (file-ext '(hbs html js json jsx))
     ;  (my-define-web-polymode file-ext))
     (add-to-list 'polymode-mode-name-aliases '(bash . sh))
     ;(add-to-list 'polymode-mode-name-aliases '(javascript . my-js))
     (add-to-list 'polymode-mode-name-aliases '(javascript . js))
     ))

;; Prefer Github-flavored Markdown
(my-replace-cdrs-in-alist 'markdown-link-face 'gfm-mode 'auto-mode-alist)

;; Don't mess with keys that I'm used to
(defun my-markdown-mode-keys ()
  (define-key markdown-mode-map (kbd "<M-right>") #'forward-word)
  (define-key markdown-mode-map (kbd "<M-left>") #'backward-word))
(add-hook 'markdown-mode-hook #'my-markdown-mode-keys t)

;; Support for .nsh files
(autoload 'nsis-mode "nsis-mode" "NSIS mode" t)
(setq auto-mode-alist (append '(("\\.[Nn][Ss][HhIi]\\'" . nsis-mode)) auto-mode-alist))

;; Profiling
(require 'profiler)
(cl-defmacro with-cpu-profiling (&rest body)
  `(unwind-protect
       (progn
         (ignore-errors (profiler-cpu-log))
         (profiler-cpu-start profiler-sampling-interval)
         ,@body)
     (profiler-report-cpu)
     (profiler-cpu-stop)))

;; Company: auto-completion for various modes
(setq company-idle-delay 0.3)
(add-hook 'after-init-hook 'global-company-mode t)
(add-hook 'after-init-hook 'company-statistics-mode t)

;; Setup info for manually compiled packages
(add-to-list 'Info-default-directory-list (concat my-emacs-path "share/info"))

;; Magit settings
(eval-after-load "git-commit"
  '(progn
     ;; Kill auto-fill in git-commit mode
     (remove-hook 'git-commit-setup-hook #'git-commit-turn-on-auto-fill)))

;; Don't overwrite M-w in magit mode, and clear mark when done
(defun my-magit-kill-ring-save ()
  (interactive)
  (call-interactively #'kill-ring-save)
  (deactivate-mark))

(eval-after-load "magit"
  '(progn
     (setq magit-completing-read-function 'ivy-completing-read)
     (define-key magit-mode-map (kbd "M-w") #'my-magit-kill-ring-save)))

(defun my-preload-magit ()
  (require 'magit)
  (require 'git-commit))

(my-defer-startup #'my-preload-magit)

;; Map some magit keys globally
(global-set-key "\C-xV" nil)
(global-set-key "\C-xVa" 'magit-blame)
(global-set-key "\C-xVb" 'magit-show-refs-current)
(global-set-key "\C-xVl" 'magit-log-head)
(global-set-key "\C-xVs" 'magit-status)

;; Don't display some minor modes on the mode-line
(eval-after-load "autorevert" '(diminish 'auto-revert-mode))
(eval-after-load "company" '(diminish 'company-mode))
(eval-after-load "counsel" '(diminish 'counsel-mode))
(eval-after-load "editorconfig" '(diminish 'editorconfig-mode))
(eval-after-load "ivy" '(diminish 'ivy-mode))
(eval-after-load "poly-markdown" '(diminish 'poly-markdown-mode))
(eval-after-load "org-indent" '(diminish 'org-indent-mode))
(eval-after-load "slime-js" '(diminish 'slime-js-minor-mode))

;; Patch security vulnerability fixed in Emacs 25.3
(eval-after-load "enriched"
  '(defun enriched-decode-display-prop (start end &optional param)
     (list start end)))

;; Clojure mode settings
(eval-after-load "clojure-mode"
  '(progn
     (require 'cider)))

;; Org Mode settings
(defun my-org-find-notes-file ()
  (interactive)
  (require 'org)
  (find-file org-default-notes-file))

(defun my-org-capture-note ()
  (interactive)
  (require 'org-capture)
  (org-capture nil "n"))

(define-key projectile-command-map "n" #'my-org-find-notes-file)
(define-key projectile-command-map " " #'my-org-capture-note)

(eval-after-load "org"
  '(progn
     (define-key org-mode-map (kbd "<M-left>") #'left-word)
     (define-key org-mode-map (kbd "<M-right>") #'right-word)))

;; Helm settings
; also to try: https://github.com/bling/fzf.el

(eval-after-load "helm-files"
  '(progn
     (define-key helm-find-files-map "/" #'helm-execute-persistent-action)
     (define-key helm-find-files-map (kbd "TAB") #'helm-execute-persistent-action)))

(global-set-key "\C-x\C-f" 'helm-find-files)

(defun my-preload-helm ()
  (require 'helm-files))

(my-defer-startup #'my-preload-helm)

;;; Key customizations

(global-set-key "\C-xg" 'goto-line)

(defun my-kill-emacs ()
  (interactive)
  (call-interactively 'save-buffers-kill-emacs t))
(global-set-key (kbd "C-x C-M-s") #'my-kill-emacs)

;; Make adding entries to debian/changelog easy
(global-set-key "\C-xD" nil)
(global-set-key "\C-xDa" 'debian-changelog-add-entry)

;; Map some keys to find-function/find-variable
(defvar my-find-things-map
  (let ((map (make-sparse-keymap)))
    (define-key map "f" #'find-function)
    (define-key map "v" #'find-variable)
    (define-key map "l" #'find-library)
    (define-key map "a" #'find-face-definition)
    map)
  "My key customizations for find-function and related things.")

(global-set-key "\C-xF" my-find-things-map)
(global-set-key "\C-xf" my-find-things-map)

(eval-after-load "view"
  '(progn
     ;; Make the `q' key bury the current buffer when viewing help
     (define-key view-mode-map "q" 'bury-buffer)
     ;; Make the <DEL> key scroll backwards in View mode
     (define-key view-mode-map [delete] 'View-scroll-page-backward)))

(eval-after-load "info"
  '(progn
     ;; Make the <DEL> key scroll backwards in Info mode
     (define-key Info-mode-map [delete] 'Info-scroll-down)))

;; diff-mode: Don't mess with M-q
(eval-after-load "diff-mode"
  '(progn
     (define-key diff-mode-map (kbd "M-q") 'fill-paragraph)))

(eval-after-load "cider-repl"
  '(progn
     (define-key cider-repl-mode-map (kbd "C-d") #'cider-quit)))

;; Use Ivy instead of the buffer list when I typo it
(global-set-key "\C-x\C-b" 'ivy-switch-buffer)

;; Disable some keybinds to avoid typos
(global-set-key [insert] (lambda () (interactive)))
(global-set-key [insertchar] (lambda () (interactive)))
(global-set-key "\C-t" (lambda () (interactive)))
(global-set-key "\C-z" (lambda () (interactive)))
(global-set-key "\C-x\C-z" (lambda () (interactive)))

;; Bind Apple-<key> to Alt-<key> for some Mac keys
(when (and my-remap-cmd-key-p (eq system-type 'darwin))
  (setq mac-option-modifier 'meta)
  (setq mac-command-modifier 'super))

(defun my-set-super-bindings ()
  (interactive)
  (eval-after-load "cider-repl"
    '(progn
       (define-key cider-repl-mode-map (kbd "s-n") #'cider-repl-next-input)
       (define-key cider-repl-mode-map (kbd "s-p") #'cider-repl-previous-input)))

  (eval-after-load "magit"
    '(progn
       (define-key magit-status-mode-map (kbd "S-c") #'my-magit-kill-ring-save)
       (define-key magit-status-mode-map (kbd "S-w") #'my-magit-kill-ring-save)))

  (global-set-key (kbd "s-:") #'eval-expression)
  (global-set-key (kbd "s-;") #'eval-expression)
  (global-set-key (kbd "s-<") #'beginning-of-buffer)
  (global-set-key (kbd "s-,") #'beginning-of-buffer)
  (global-set-key (kbd "s->") #'end-of-buffer)
  (global-set-key (kbd "s-.") #'end-of-buffer)
  (global-set-key (kbd "<s-left>") #'left-word)
  (global-set-key (kbd "<s-right>") #'right-word)
  (global-set-key (kbd "s-1") #'shell-command)
  (global-set-key (kbd "s-!") #'shell-command)
  (global-set-key (kbd "s-4") #'ispell-word)
  (global-set-key (kbd "s-$") #'ispell-word)
  (global-set-key (kbd "s-a") #'mark-whole-buffer)
  (global-set-key (kbd "s-c") #'kill-ring-save)
  (global-set-key (kbd "s-m") (lambda () (interactive)))
  (global-set-key (kbd "s-p") #'projectile-find-file)
  (global-set-key (kbd "s-q") #'save-buffers-kill-terminal)
  (global-set-key (kbd "s-w") #'kill-ring-save)
  (global-set-key (kbd "s-v") #'yank)
  (global-set-key (kbd "s-x") #'counsel-M-x)
  (global-set-key (kbd "<C-s-left>") #'backward-sexp)
  (global-set-key (kbd "<C-s-right>") #'forward-sexp)
  (global-set-key (kbd "C-s-n") #'forward-list)
  (global-set-key (kbd "C-s-p") #'backward-list)
  (global-set-key (kbd "C-s-x") #'eval-defun))

(when (and my-remap-cmd-key-p (or (eq window-system 'x) (eq system-type 'darwin)))
  (my-set-super-bindings))

;; Change to home dir
(defun my-change-to-default-dir ()
  (interactive)
  (setq-default default-directory (expand-file-name my-default-directory))
  (setq default-directory (expand-file-name my-default-directory)))
(add-hook 'after-init-hook #'my-change-to-default-dir t)

;; Start server
(when my-server-start-p (server-start))

;; Open a few frequently-used files
(mapc #'find-file-noselect my-recent-files)

;; Kill the startup screen that we displayed earlier
(defun my-kill-splash-screen ()
  (interactive)
  (let ((buf (get-buffer "*GNU Emacs*")))
    (when (and buf (buffer-live-p buf))
      (kill-buffer buf))))
(add-hook 'after-init-hook #'my-kill-splash-screen t)

(provide 'shared-init)
;;; shared-init.el ends here
