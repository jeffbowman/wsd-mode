
;; user-customizable sections

;; only required for premium-features.
(defvar wsd-api-key "")

;; "svg" is also a permitted format, but this requires a premium account
;; and thus a api-key.
(defvar wsd-format "png")
(defvar wsd-style "modern-blue")

;; actual code

;; implementation based on documentation as found here:
;; http://www.websequencediagrams.com/embedding.html

(require 'cl)
(require 'url)
(require 'json)

(defconst wsd-base-url "http://www.websequencediagrams.com/")

(defun wsd-get-apikey-section ()
  (if wsd-api-key
      (concatenate 'string "&apikey=" wsd-api-key)
    ""))

(defun wsd-encode (message)
  (let* ((encode1 (replace-regexp-in-string (regexp-quote "+")
                                            (regexp-quote "%2B")
                                            message))
         (encode2 (url-encode-url encode1)))
    encode2))

(defun wsd-get-request-data (message)
  (let* ((encoded (wsd-encode message))
         (apikey  (wsd-get-apikey-section)))
    (concatenate 'string
                 "apiVersion=1"
                 "&format=png" wsd-format
                 "&style=" wsd-style
                 "&message=" encoded
                 apikey)))

(defun wsd-send (message)
  (let* ((url-request-method        "POST")
         (url-request-extra-headers '(("Content-Type" . "application/x-www-form-urlencoded")))
         (url-request-data          (wsd-get-request-data message))
         (wsd-response              (url-retrieve-synchronously wsd-base-url)))
    (save-excursion
      (switch-to-buffer wsd-response)

      (goto-char (point-min))
      ;; move to beginning of JSON response
      (search-forward "{")
      (left-char)
      ;; parse and return json at point

      (let* ((json (json-read)))
        (kill-buffer wsd-response)
        json))))

(defun wsd-get-image-url (json)
  (let* ((url (concatenate 'string
                           wsd-base-url
                           (cdr (assoc 'img json)))))
    url))

(defun wsd-get-image-extension ()
  (concatenate 'string "." wsd-format))

(defun wsd-get-temp-filename ()
  (make-temp-file "wsd-" nil (wsd-get-image-extension)))

(defun wsd-get-image-filename (name)
  (if name
      (concatenate 'string (file-name-sans-extension name) (wsd-get-image-extension))
    (wsd-get-temp-filename)))

(defun wsd-process ()
  (interactive)
  (let* ((file-name (wsd-get-image-filename (buffer-file-name))))
    (save-excursion
      (let* ((message (buffer-substring-no-properties (point-min) (point-max)))
	     (json    (wsd-send message))
	     (url     (wsd-get-image-url json)))
	(url-copy-file url file-name t)
	(browse-url file-name)))))


(provide 'wsd-core)

