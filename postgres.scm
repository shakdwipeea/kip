(load-shared-object "libpq.so")

(library (postgres)
  
  (export make-connection
	  query)

  (import (scheme))

  ;;; FFI functions

  (define pg-connect  (foreign-procedure "PQconnectdb"
					 (string) void*))
  
  (define pg-status (foreign-procedure "PQstatus" (void*) int))

  (define pg-error-message (foreign-procedure "PQerrorMessage"
					      (void*)
					      string))

  (define pg-exec (foreign-procedure "PQexec"
				     (void* string)
				     void*))

  (define pg-get-num-fields (foreign-procedure "PQnfields"
					       (void*)
					       int))

  (define pg-get-num-tuples (foreign-procedure "PQntuples"
					       (void*)
					       int))

  (define pg-result-status (foreign-procedure "PQresultStatus"
					      (void*)
					      int))


  ;;; Error condition
  ;;; raised if connection fails with db
  
  (define-condition-type &postgres-connect-fail &condition
    make-connect-fail
    connect-fail?
    (type connect-fail-type))

  (define-record-type postgres-profile
    (nongenerative)
    (fields user password dbname host))

  (define postgres-profile-keys
    (record-type-field-names (record-type-descriptor postgres-profile)))

  
  (define (config->string profile)
    (fold-left (lambda (str kv)
		 (string-append str
				(symbol->string (car kv))
				"="
				(cdr kv)
				" "))
	       ""
	       profile))
  
  (define (read-config config-file)
    (call-with-input-file config-file read))


  (define (read-postgres-from-config config-file)
    (config->string (read-config config-file)))
  
  
  (define (make-connection profile)
    (let ((conn (pg-connect (read-postgres-from-config profile))))
      (if (= 0 (pg-status conn))
	  conn
	  (make-connect-fail (pg-error-message conn)))))

  
  (define (query conn sql)
    (let* ((res      (pg-exec conn sql))
	   (num-rows (pg-get-num-tuples res)))
      (printf "~a : rows present" num-rows))))

#!eof

(printf "~s can't touch me here \n" "here")

Basic usage from repl:

> (import (postgres))

> (define conn (make-connection "config.scm"))

> (query conn "select * from accounts")

