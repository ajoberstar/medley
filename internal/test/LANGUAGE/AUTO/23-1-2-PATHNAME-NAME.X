;; Function To Be Tested: PATHNAME-NAME
;;
;; Source:        Steele's book    
;;                Section 23.1.2	PATHNAME Functions        
;;                Page: 417
;;
;; Created By:    Henry Cate III
;;
;; Creation Date: November 5,1986
;;
;; Last Update:    
;;
;; Filed As:      {ERIS}<LISPCORE>CML>TEST>23-1-2-PATHNAME-NAME.TEST
;;
;;
;; Syntax:        (PATHNAME-NAME pathname)
;;
;;
;;
;; Function Description:
;;     returns the name of the file as a string or symbol
;; 
;; 
;; 
;; Argument(s):   pathname - pointing to a file 
;;
;; Returns:       the name of the file 
;;


(do-test "load functions for chapter 23 tests"
(unless (fboundp '23check-parse-list)   (load "{eris}<lispcore>cml>test>23-functions.def"))
  T)			; get here and functions were defined


(do-test "test a simple case"
	; test on dsk, lispfiles, so atleast the basics work.
	:before (progn (setq temp-name (string (gensym)))
	   (setq simple-list (23BUILD-LIST-OF-FILENAME-PATHNAMES 
		"dsk" 1 nil "lispfiles>cmltest" temp-name)))
	:after (progn (23Delete-file-list simple-list))
	(23TEST-PATHNAME-VALUE-list simple-list 'name temp-name))

(do-test "test a simple case"
	; test on pollux, lispfiles, so atleast the basics work.
	:before (progn (setq temp-name (string (gensym)))
	   (setq simple-list (23BUILD-LIST-OF-FILENAME-PATHNAMES 
		"pollux:aisnorth:xerox" 1 nil "cmltest" temp-name)))
	:after (progn (23Delete-file-list simple-list))
	(23TEST-PATHNAME-VALUE-list simple-list 'name temp-name))

;(do-test "make sure can have a file like HELLO.GOOD.BYE & be consistent"
;	:before (progn 
;	   (setq expect-name (concatenate 'string (string (gensym)) ".bye"))
;	   (setq temp-name (concatenate 'string expect-name ".solong"))
;	   (setq delete-list (23BUILD-LIST-OF-FILENAME-PATHNAMES 
;		"core" 1 nil "tempdir" temp-name))
;	   (setq simple-list (23Multiply-stream delete-list)))
;	:after (progn (23Delete-file-list delete-list))
;	(23TEST-PATHNAME-VALUE-list simple-list 'name expect-name))


(do-test-group "test do same type of test on several different HOSTS"
	:before (PROGN

; this function is just for this test case.
(test-defun 23BUILD-NAME-LIST (host name result-type usedevice InOneDir)
	"create a list of files of one type"
    (append 
	(if (not InOneDir) (append 
	  (23file-generator result-type host 1 nil nil name)
	  (23file-generator result-type host 1 nil "TEMPDIR12-23" name)))
	(if usedevice (append 
	  (23file-generator result-type host 1 "TEMPDEVICE" nil name)))
	(23file-generator result-type host 1 nil "cmltest" name)
	(23file-generator result-type host 1 nil "cmltest" name "temptype12")
    ))

(test-defun 23DRIVE-NAME-LIST (host name-create name-match usedevice InOneDir)
	"push the list through the checker, valid function?"
  (let* ((delete-list (23BUILD-NAME-LIST 
			host name-create 'STREAM  usedevice InOneDir))
	    (big-list (23Multiply-stream delete-list))
	    (result (23TEST-PATHNAME-VALUE-list big-list 'name name-match)))
	(23Delete-file-list delete-list)
	result))

)	; End of defining functions for this test group.


(do-test "test lots of variations in {CORE}"
  (let ((temp-name (concatenate 'string "MM" (string (gensym)))))
	(23DRIVE-NAME-LIST "core" (string-downcase temp-name) temp-name T nil)))

(do-test "test lots of variations in {DSK}"
  (let* ((name-create (concatenate 'string "LL" (string (gensym))))
	    (delete-list (23file-generator 
			'STREAM "dsk" 1 nil "lispfiles>sub" name-create  "temptype12"))
	    (big-list (23Multiply-stream delete-list))
	    (result (23TEST-PATHNAME-VALUE-list 
			big-list 'name (string-downcase name-create))))
	(23Delete-file-list delete-list)
	result))

(do-test "test lots of variations in {ERINYES}"
  (let ((temp-name (concatenate 'string "HC" (string (gensym)))))
	(23DRIVE-NAME-LIST "erinyes" (string-downcase temp-name) 
		temp-name nil T)))


)	; end of do-test-group
	

(do-test "test error conditions"
   (flet ((handle-expect-errors (value) 
		  (xcl-test:expect-errors (cl:error) 
			(PATHNAME-NAME value))
		))
   (and
	(handle-expect-errors 54)
	(handle-expect-errors #\h)
	(handle-expect-errors (list 'hi 'bye))
	(handle-expect-errors (make-array '(2 3 4)))
	(handle-expect-errors (make-hash-table))
	(handle-expect-errors (copy-readtable))
	(handle-expect-errors (find-package 'Lisp))
;	(handle-expect-errors (make-random-state))
	(not (PATHNAME-NAME (make-broadcast-stream *terminal-io*)))
   )))



STOP
