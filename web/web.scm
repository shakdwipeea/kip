(load "scheme-to-js/compiler.scm")

(define template '(html

		   (head
		    (meta ((charset . "utf-8")))
		    (meta ((name . "viewport")
			   (content . "width=device-width,initial-scale=1.0")))
		    (meta ((name . "theme-color")
			   (content . "#333333")))

		    (text "%sapper.base%")
		    
		    (link ((rel . "stylesheet")
			   (href . "global.css")))
		    (link ((rel . "manifest")
			   (href . "manifest.json")))
		    (link ((rel . "icon")
			   (type . "image/png")
			   (href . "favicon.png")))

		    (text "%sapper.styles%")

		    (text "%sapper.head%"))
		   
		   (body (div ((id . "sapper"))
			      "%sapper.scripts%"))))




(list? template)
(define t template)

;; todo write tests

(define (open-html sym)
  (string-append "<" (symbol->string sym) ">"))

(define (close-html sym)
  (string-append "</" (symbol->string sym) ">"))


(define (open-html-with-attr sym attribute-pair)
  (string-append "<"
		 (symbol->string sym)
		 (string-join attribute-pair)
		 ">"))


(define (template->html t)
  (if (not (list? t))
      #f
      (let ((tag (car t)))
	(if (and (>= (length t) 2)
	       (pair? (caadr t)))
	    
	    ;; attribute
	    (string-append (open-html tag)
			   (close-tag))

	    ;; no attribute
	    (string-append (open-html tag)
			   (string-join (map template->html (cdr t))
					"\n")
			   (close-html tag))))))

#!eof


;;;;;;;;;;;
;; tests ;;
;;;;;;;;;;;

;; 
;; todo move this test to some other file and integrate to
;; some ci

(load "../check.scm")

(check (open-html 'html) => "<html>")
(check (close-html 'html) => "</html>")

(length (cadr t))

(pair?  (caadr '(meta
		 ((name . "viewport")
		  (content . "width=device-width,initial-scale=1.0")))))

(template->html 'template)
