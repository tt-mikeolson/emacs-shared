;;; Customizations

(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(Man-notify-method (quote bully))
 '(add-log-keep-changes-together t)
 '(allout-auto-activation t)
 '(apropos-do-all t)
 '(auto-compression-mode t nil (jka-compr))
 '(backup-directory-alist (quote (("." . "~/.emacs.d/backup"))))
 '(blink-cursor-mode nil nil (frame))
 '(blink-matching-delay 10)
 '(blink-matching-paren-on-screen t)
 '(browse-url-new-window-flag t)
 '(bsh-classpath (quote ("/usr/share/java")))
 '(bsh-jar "/usr/share/java/bsh.jar")
 '(case-replace nil)
 '(change-log-mode-hook (quote ((lambda nil (flyspell-mode 1)))))
 '(column-number-mode t)
 '(confluence-save-page-comments nil)
 '(confluence-save-page-minor-edits nil)
 '(cperl-close-paren-offset -4)
 '(cperl-indent-level 4)
 '(cperl-indent-parens-as-block t)
 '(cperl-merge-trailing-else nil)
 '(current-language-environment "UTF-8")
 '(custom-safe-themes t)
 '(debian-changelog-mode-hook (quote (turn-on-auto-fill flyspell-mode turn-on-muse-list-edit-minor-mode)))
 '(default-input-method "TeX")
 '(delete-selection-mode t)
 '(dict-noauth t)
 '(dictionary-server "www.flyingtux.com")
 '(dictionary-use-single-buffer t)
 '(diff-switches "-u")
 '(dired-dwim-target t)
 '(dired-recursive-copies (quote always))
 '(dired-recursive-deletes (quote always))
 '(doc-view-resolution 132)
 '(ediff-window-setup-function (quote ediff-setup-windows-plain))
 '(edit-server-new-frame nil)
 '(edit-server-new-frame-alist (quote ((name . "Emacs TEXTAREA") (width . 120) (height . 30) (minibuffer . t) (menu-bar-lines . t))))
 '(eldoc-minor-mode-string " E")
 '(emms-cache-file "~/.emacs.d/.emms-cache")
 '(emms-info-asynchronously nil)
 '(emms-info-functions (quote (emms-info-mpd my-emms-info-fromname)))
 '(emms-lastfm-radio-metadata-period nil)
 '(emms-player-list (quote (emms-player-mpd emms-player-lastfm-radio)))
 '(emms-player-mpd-verbose nil)
 '(emms-playlist-buffer-name "*EMMS Playlist*")
 '(emms-playlist-default-major-mode (quote emms-playlist-mode))
 '(emms-playlist-mode-open-playlists t)
 '(emms-show-format "NP: %s")
 '(emms-stream-default-action "play")
 '(emms-track-description-function (quote my-emms-info-track-description))
 '(emms-track-info-filters (quote (my-emms-info-filter-titles)))
 '(emms-track-initialize-functions (quote (emms-info-initialize-track)))
 '(emms-volume-change-amount 3)
 '(emms-volume-change-function (quote emms-volume-mpd-change))
 '(enable-recursive-minibuffers t)
 '(erc-anonymous-login nil)
 '(erc-auto-query (quote bury))
 '(erc-autoaway-idle-seconds 1200)
 '(erc-beep-match-types nil)
 '(erc-button-buttonize-nicks t)
 '(erc-button-nickname-face nil)
 '(erc-current-nick-highlight-type nil)
 '(erc-dcc-get-default-directory "~/Downloads/")
 '(erc-dcc-port-range (quote (6888 . 6889)))
 '(erc-enable-logging (quote erc-log-all-but-server-buffers))
 '(erc-fill-function (quote erc-fill-static))
 '(erc-fill-static-center 0)
 '(erc-fool-highlight-type (quote all))
 '(erc-generate-log-file-name-function (quote erc-generate-log-file-name-short))
 '(erc-hide-prompt t)
 '(erc-hide-timestamps nil)
 '(erc-insert-timestamp-function (quote erc-insert-timestamp-left))
 '(erc-interpret-mirc-color t)
 '(erc-join-buffer (quote bury))
 '(erc-kill-buffer-on-part t)
 '(erc-kill-queries-on-quit t)
 '(erc-kill-server-buffer-on-quit t)
 '(erc-log-write-after-insert t)
 '(erc-match-exclude-server-buffer t)
 '(erc-modules (quote (autojoin button capab-identify completion dcc fill identd irccontrols keep-place list match menu move-to-prompt netsplit networks noncommands readonly ring services stamp track)))
 '(erc-notify-signoff-hook (quote (erc-notify-signoff)))
 '(erc-notify-signon-hook (quote (erc-notify-signon)))
 '(erc-prompt-for-nickserv-password nil)
 '(erc-prompt-for-password nil)
 '(erc-server "localhost")
 '(erc-server-reconnect-timeout 30)
 '(erc-server-send-ping-timeout 240)
 '(erc-timestamp-format "[%H:%M] ")
 '(erc-timestamp-intangible nil)
 '(erc-timestamp-only-if-changed-flag nil)
 '(erc-track-exclude-types (quote ("JOIN" "NICK" "PART" "QUIT" "MODE" "001" "305" "306" "333" "353")))
 '(erc-track-switch-direction (quote importance))
 '(erc-user-full-name (quote user-full-name))
 '(erc-verbose-dcc nil)
 '(erc-whowas-on-nosuchnick t)
 '(ffap-machine-p-known (quote reject))
 '(fill-column 119)
 '(flyspell-issue-welcome-flag nil)
 '(footnote-body-tag-spacing 1)
 '(icomplete-mode t)
 '(ido-default-buffer-method (quote selected-window))
 '(ido-mode (quote buffer) nil (ido))
 '(ido-save-directory-list-file "~/.emacs.d/.ido.last")
 '(ido-ubiquitous-function-exceptions (quote (grep-read-files find-file-at-point)))
 '(ido-ubiquitous-mode t)
 '(imaxima-fnt-size "LARGE")
 '(imaxima-use-maxima-mode-flag t)
 '(indent-tabs-mode nil)
 '(inhibit-startup-screen t)
 '(ispell-local-dictionary "american")
 '(ispell-personal-dictionary nil)
 '(ispell-silently-savep t)
 '(js2-allow-keywords-as-property-names nil)
 '(js2-auto-indent-flag nil)
 '(js2-basic-offset 2)
 '(js2-bounce-indent-flag nil)
 '(js2-cleanup-whitespace nil)
 '(js2-concat-multiline-strings nil)
 '(js2-highlight-level 1)
 '(js2-include-node-externs t)
 '(js2-mirror-mode nil)
 '(js2-mode-escape-quotes nil)
 '(js2-rebind-eol-bol-keys nil)
 '(ls-lisp-dirs-first t)
 '(ls-lisp-ignore-case t)
 '(ls-lisp-support-shell-wildcards nil)
 '(ls-lisp-use-insert-directory-program nil)
 '(ls-lisp-verbosity (quote (uid gid)))
 '(mail-interactive t)
 '(mail-user-agent (quote gnus-user-agent))
 '(mark-diary-entries-in-calendar t)
 '(max-lisp-eval-depth 1000)
 '(max-specpdl-size 1000)
 '(message-log-max 500)
 '(mouse-autoselect-window nil)
 '(mouse-wheel-mode t)
 '(muse-colors-inline-image-method (quote muse-colors-use-publishing-directory))
 '(muse-completing-read-function (quote ido-completing-read))
 '(muse-html-charset-default "utf-8")
 '(muse-html-encoding-default (quote utf-8))
 '(muse-html-meta-content-encoding (quote utf-8))
 '(muse-mode-hook (quote (footnote-mode)))
 '(muse-publish-comments-p t)
 '(muse-publish-date-format "%b. %e, %Y")
 '(muse-publish-desc-transforms (quote (muse-wiki-publish-pretty-title muse-wiki-publish-pretty-interwiki muse-publish-strip-URL)))
 '(muse-wiki-publish-small-title-words (quote ("the" "and" "at" "on" "of" "for" "in" "an" "a" "page")))
 '(org-startup-folded nil)
 '(post-jump-header nil)
 '(recentf-mode nil)
 '(recentf-save-file "~/.emacs.d/.recentf")
 '(remember-data-file "~/Documents/notes.muse")
 '(remember-filter-functions (quote ((lambda nil (delete-trailing-whitespace)))))
 '(remember-mode-hook (quote (muse-list-edit-minor-mode)))
 '(require-final-newline nil)
 '(safe-local-variable-values (quote ((allout-layout * 0 :))))
 '(save-place t nil (saveplace))
 '(save-place-file "~/.emacs.d/.places")
 '(save-place-limit 20)
 '(show-paren-mode t)
 '(show-paren-style (quote parenthesis))
 '(smex-save-file "~/.emacs.d/.smex-items")
 '(sql-product (quote mysql))
 '(tab-stop-list (quote (4 8 12 16 20 24 28 32 36 40 44 48 52 56 60 64 68 72 76 80 84 88 92 96 100 104 108 112 116 120)))
 '(tab-width 8)
 '(tooltip-use-echo-area t)
 '(tramp-auto-save-directory "~/.emacs.d/.autosave.d")
 '(tramp-backup-directory-alist (quote (("." . "~/.emacs.d/backup"))))
 '(vc-handled-backends (quote (RCS CVS SVN)))
 '(visible-bell t)
 '(winner-mode t nil (winner))
 '(woman-fill-column 95)
 '(woman-fontify t)
 '(woman-use-own-frame nil)
 '(wtf-custom-alist nil)
 '(wtf-removed-acronyms nil)
 '(x-select-enable-clipboard t))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(woman-italic ((t (:underline t :slant italic))) t))
