(require 'ido)

(defvar emacs-octopress--load-file-name load-file-name
  "Store the filename that octopress.el was originally loaded from.")

(setq preview-macs (expand-file-name (concat (file-name-directory emacs-octopress--load-file-name) "preview.el")))

(setq octopress-posts (concat octopress-workdir "source/_posts/"))

(defun octopress-rake (command)
  "run rake commands"
  (let ((command-str (format "/bin/bash -l -c 'source $HOME/.rvm/scripts/rvm && rvm use ruby-1.9.3-p545 && cd %s && rake %s'" octopress-workdir command)))
    (shell-command-to-string command-str)))

(defun octopress-new (class title)
  (let* ((command-str (format "new_%s[\"%s\"]" class title))
         (command-result (octopress-rake command-str))
         (regexp-str (format "Creating new %s: " class))
         (filename))
    (progn
      (setq filename (concat octopress-workdir "/"
                             (replace-regexp-in-string regexp-str ""
                                                       (car (cdr (reverse (split-string command-result "\n")))))))
      (find-file filename))))

(defun octopress-new-post (title)
  "begin a new post in source/_posts"
  (interactive "MTitle: ")
  (octopress-new "post" title))

(defun octopress-new-page (title)
  "create a new page in source/(filename)/index.markdown"
  (interactive "MTitle: ")
  (octopress-new "page" title))

(defun octopress-generate ()
  "generate jekyll site"
  (interactive)
  (octopress-rake "generate")
  (message "Generate site OK"))

(defun octopress-deploy ()
  "default deploy task"
  (interactive)
  (octopress-rake "deploy")
  (message "Deploy site OK"))

(defun octopress-gen-deploy ()
  "generate website and deploy"
  (interactive)
  (octopress-rake "gen_deploy")
  (octopress-qrsync "/Users/venmos/.script/venmos-com.json")
  (message "Generate and Deploy OK"))

(defun octopress-posts ()
  "use ack to search  your posts"
  (interactive)
  (octopress-posts (ido-find-file-in-dir octopress-posts)))

(defun octopress-dired ()
  (interactive)
  (octopress-dired (find-file octopress-posts)))

(defun octopress-shell ()
  (interactive)
  (octopress-shell (load-file preview-macs)))

(prodigy-define-tag
    :name 'octopress
    :env '(("LANG" "en_US.UTF-8")
           ("LC_ALL" "en_US.UTF-8")))

(prodigy-define-service
    :name "Octopress preview"
    :command "rake"
    :args '("preview")
    :cwd octopress-workdir
    :tags '(octopress)
    :kill-signal 'sigkill)

(prodigy-define-service
    :name "Octopress generate"
    :command "rake"
    :args '("generate")
    :cwd octopress-workdir
    :tags '(octopress)
    :kill-signal 'sigkill)

(prodigy-define-service
    :name "Octopress deploy"
    :command "rake"
    :args '("deploy")
    :cwd octopress-workdir
    :tags '(octopress)
    :kill-signal 'sigkill)

(prodigy-define-service
    :name "Octopress generate_deploy"
    :command "rake"
    :args '("gen_deploy")
    :cwd octopress-workdir
    :tags '(octopress)
    :kill-signal 'sigkill)

(provide 'octopress-emacs)
;;; octopress-emacs.el ends here
