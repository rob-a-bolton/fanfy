#lang racket

(require net/url)

(provide get-ff-details)

(define (get-ff-url id chapter)
  (format "https://www.fanfiction.net/s/~a/~a" id chapter))

(define (get-ff-details url-or-id)
  (let ((url (string->url
              (if (number? url-or-id)
                  (get-ff-url url-or-id 1)
                  url-or-id))))
    (call/input-url url get-pure-port get-details)))

(define (zip . lists)
  (let zip-loop ((zip-elems '())
                 (elems lists))
    (if (ormap empty? elems)
        (reverse zip-elems)
        (zip-loop (cons (map car elems) zip-elems)
                  (map cdr elems)))))
        

(define (get-details port)
  (let* ((page-str (foldl string-append "" (consume-lines port)))
         (story-id (get-story-id page-str))
         (author (get-author page-str))
         (title (get-title page-str))
         (chapter-titles (get-chapter-titles page-str))
         (chapters (get-chapters story-id (length chapter-titles))))
    (list author title (zip chapter-titles chapters))))

(define (get-story-id page)
  (let ((matches (regexp-match "var storyid = ([0-9]+)" page)))
    (if (> (length matches) 1)
        (cadr matches)
        #f)))

(define (get-chapter-titles page)
  (let ((matches (regexp-match "<SELECT id=chap_select[^>]+>((<option [^>]+>[^<]*)*)</select>" page)))
    (if (> (length matches) 2)
        (split-options (cadr matches))
        #f)))

(define (split-options options)
  (let ((matches (regexp-match* "<option +value=[0-9]+[^>]+>[0-9]+. +([^<]+)" options)))
    (map (λ (str)
           (cadr (regexp-match ">[0-9]+. +(.*)" str)))
         matches)))

(define (get-author page)
  (let ((matches (regexp-match "By:</span> <a class='xcontrast_txt' href='/u/[0-9]+/[^']+'>([^<]*)"page)))
    (if (> (length matches) 1)
        (cadr matches)
        #f)))

(define (get-title page)
  (let ((matches (regexp-match "Follow/Fav</button><b class='xcontrast_txt'>([^<]+(?=<))" page)))
    (if (> (length matches) 1)
        (cadr matches)
        #f)))

(define (get-chapter story-id chapter)
  (let ((url (string->url (get-ff-url story-id chapter))))
    (call/input-url url get-pure-port
      (lambda (port)
        (let ((page (foldl string-append "" (consume-lines port))))
          (get-chapter-text page))))))

(define (get-chapters story-id num-chapters)
  (for/list ((chapter (drop (range (+ 1 num-chapters)) 1)))
    (get-chapter story-id chapter)))

(define (get-chapter-text page)
  (let ((outer-match (regexp-match "(?<=id='storytext'>).*(?=<div role='main)" page)))
    (if outer-match
        (regexp-replace* "<[^>]+>" (car outer-match) "")
        #f)))

(define (consume-lines port)
  (let build-loop ((lines '()))
    (let ((line (read-line port)))      
      (if (eof-object? line)
          (reverse lines)
          (build-loop (cons line lines))))))
