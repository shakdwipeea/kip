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
			      (text "%sapper.scripts%")))))




(list? template)
(define t template)

;; todo write macro to abstract test macro (check)

(define (open-html-tag sym)
  (string-append "<" (symbol->string sym) ">"))

(define (close-html-tag sym)
  (string-append "</" (symbol->string sym) ">"))

;; some tests

(check (open-html-tag 'html) => "<html>")
(check (close-html-tag 'html) => "</html>")

;; tests end


;; used to inject a literal string in html
(define (literal-string str)
  (string-append "\"" str "\""))


(define (pair->string attr-pair-list)
  (string-join (map (lambda (attr-value-pair)
		      (string-append
		       (symbol->string (car attr-value-pair))
		       "="
		       (literal-string (cdr attr-value-pair))))
		    attr-pair-list)
	       " "))


(define (open-html-tag-with-attr tag-list)
  (string-append "<"
		 (symbol->string (car tag-list))
		 " "
		 (pair->string (cadr tag-list))
		 ">"))

;; attribute tests

(define script-tag '(script ((src . "some.js")
			     (type . "application/javascript"))))

(define script-str "<script src=\"some.js\" type=\"application/javascript\" >")

(check (open-html-tag-with-attr	script-tag) => script-str)

;; tests end

(define (node-contains-attribute? node)
  (and (>= (length node) 2)
     (pair? (caadr node))))

;; repl tests

(define meta-tag '(meta ((charset . "utf-8"))))

(define div-tag '(div (p "hello")
		      (p "hello")))

(define p-tag '(p "as"))

;; why caadr
(check (caadr meta-tag) => '(charset . "utf-8"))
(check (caadr div-tag) => 'p)

(check (node-contains-attribute? meta-tag) => #t)
(check (node-contains-attribute? div-tag) => #f)

;;; test end

(define (tree->html tree) 
  (cond
   [(equal? tree '()) ""]

   [(string? (cadr tree))
    (string-append (open-html-tag (car tree))
		   (cadr tree)
		   (close-html-tag (car tree)))]
   
   [(symbol? (caadr tree))
    (string-append (open-html-tag (car tree))
		   (string-join (map tree->html (cdr tree)) "\n")
		   (close-html-tag  (car tree)))]

   [(pair? (caadr tree))
    (string-append (open-html-tag-with-attr tree)
		   (string-join (map tree->html (cddr tree)) "\n")
		   (close-html-tag  (car tree)))]))



;; todo add some tests here

;; (string-join  (map tree->html (cddr meta-tag))
;; 	      "\n")

;; (string? (cadr meta-tag))
;; (equal? (string-join (cddr meta-tag) "\n") '())
;; (string-join (map tree->html  (cdr div-tag))
;; 	     "\n")

;; (tree->html t)


;; tests end

#!eof


;;;;;;;;;;;
;; tests ;;
;;;;;;;;;;;

;; 
;; todo move this test to some other file and integrate to
;; some ci

(load "../check.scm")

(length (cadr t))

(pair?  (caadr '(meta
		 ((name . "viewport")
		  (content . "width=device-width,initial-scale=1.0")))))

