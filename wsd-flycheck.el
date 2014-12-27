;;; wsd-flycheck.el --- flycheck-support for wsd-mode  -*- lexical-binding: t; -*-

;; Copyright (C) 2014  Jostein Kjønigsen

;; Author: Jostein Kjønigsen <jostein@gmail.com>
;; Keywords: languages, tools

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

;; Quick support drafted based on sample found here:
;; https://github.com/flycheck/flycheck-ocaml/blob/master/flycheck-ocaml.el

;;; Code:


(defun wsd-flycheck-parse-errors (checker wsd-errors)
  (mapcar (lambda (wsd-error)
	    (let* ((line     (car wsd-error))
		   (message  (cdr wsd-error)))
	      (flycheck-error-new-at line 1 'error message
				     :checker checker
				     :buffer (current-buffer)
				     :filename (buffer-file-name))))
	  wsd-errors))

(defun wsd-flycheck-start (checker callback)
  "Start a wsd website invocation to get rendered results and errors.."

  ;; wsd-errors is set by wsd-mode's rendering functions to be picked up here.

  (condition-case err
      (let ((errors (wsd-flycheck-parse-errors checker wsd-errors)))
        (funcall callback 'finished (delq nil errors)))
    (error (funcall callback 'errored (error-message-string err))))
  ;; the error callback
  (lambda (msg) (funcall callback 'errored msg)))


(flycheck-define-generic-checker 'wsd-mode-checker
  "A syntax-checker for wsd-mode based on the errors reported from the
wsd-mode website itself."

  :modes 'wsd-mode
  :start #'wsd-flycheck-start)

;;;###autoload
(defun wsd-flycheck-setup ()
  "Setup Flycheck for wsd-mode."
  (interactive)
  (add-to-list 'flycheck-checkers 'wsd-mode-checker))

(provide 'wsd-flycheck)
;;; wsd-flycheck.el ends here
